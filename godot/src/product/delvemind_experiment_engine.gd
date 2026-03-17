class_name DelveMindExperimentEngine
extends RefCounted

const SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")

const RUNTIME_FORBIDDEN_FIELDS := [
	"peer_ids",
	"runtime_state",
	"event_log",
	"physics_override",
	"legality_override",
	"artifact_truth_override",
	"runtime_ai_arbitration"
]

static func default_state() -> Dictionary:
	return normalize(_default_shell())

static func normalize(state: Dictionary) -> Dictionary:
	var current := _default_shell()
	for key in state.keys():
		current[key] = state[key]
	var current_hypotheses: Dictionary = Dictionary(current.get("hypotheses", {}))
	var current_experiments: Dictionary = Dictionary(current.get("experiments", {}))
	var hypothesis_registry: Dictionary = {}
	var experiment_registry: Dictionary = {}
	for family_raw in SCHEMA_REGISTRY_SCRIPT.experiment_families():
		var family: Dictionary = Dictionary(family_raw)
		var seeded_hypothesis := _build_family_hypothesis(family)
		var hypothesis_id := str(seeded_hypothesis.get("hypothesis_id", "")).strip_edges()
		var existing_hypothesis: Dictionary = Dictionary(current_hypotheses.get(hypothesis_id, {})).duplicate(true)
		hypothesis_registry[hypothesis_id] = _normalize_hypothesis(_merge_dicts(seeded_hypothesis, existing_hypothesis))
		var seeded_experiment := _build_family_experiment(family, hypothesis_id)
		var experiment_id := str(seeded_experiment.get("experiment_id", "")).strip_edges()
		var existing_experiment: Dictionary = Dictionary(current_experiments.get(experiment_id, {})).duplicate(true)
		experiment_registry[experiment_id] = _normalize_experiment(_merge_dicts(seeded_experiment, existing_experiment))
	for hypothesis_key in current_hypotheses.keys():
		var hypothesis_id := str(hypothesis_key).strip_edges()
		if hypothesis_id.is_empty() or hypothesis_registry.has(hypothesis_id):
			continue
		var existing_hypothesis: Dictionary = Dictionary(current_hypotheses.get(hypothesis_key, {})).duplicate(true)
		existing_hypothesis["hypothesis_id"] = str(existing_hypothesis.get("hypothesis_id", hypothesis_id)).strip_edges()
		hypothesis_registry[hypothesis_id] = _normalize_hypothesis(existing_hypothesis)
	for experiment_key in current_experiments.keys():
		var experiment_id := str(experiment_key).strip_edges()
		if experiment_id.is_empty() or experiment_registry.has(experiment_id):
			continue
		var existing_experiment: Dictionary = Dictionary(current_experiments.get(experiment_key, {})).duplicate(true)
		existing_experiment["experiment_id"] = str(existing_experiment.get("experiment_id", experiment_id)).strip_edges()
		experiment_registry[experiment_id] = _normalize_experiment(existing_experiment)
	current["schema_name"] = "DelveMindExperimentState"
	current["schema_version"] = 1
	current["history_lines"] = _string_array(current.get("history_lines", []))
	current["hypotheses"] = hypothesis_registry
	current["experiments"] = experiment_registry
	current["foundational_ids"] = _sorted_strings(_foundational_ids(experiment_registry))
	current["archival_ids"] = _sorted_strings(_archival_ids(experiment_registry))
	current["lineage_index"] = _build_lineage_index(experiment_registry)
	current["validation_failures"] = validate_state(current)
	return current

static func validate_state(state: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	for hypothesis_raw in Dictionary(state.get("hypotheses", {})).values():
		failures.append_array(validate_hypothesis(Dictionary(hypothesis_raw)))
	for experiment_raw in Dictionary(state.get("experiments", {})).values():
		failures.append_array(validate_experiment(Dictionary(experiment_raw)))
	return _sorted_strings(failures)

static func validate_hypothesis(hypothesis: Dictionary) -> Array[String]:
	var schema := SCHEMA_REGISTRY_SCRIPT.experiment_schema()
	var failures: Array[String] = []
	for field in _string_array(schema.get("hypothesis_required_fields", [])):
		if not hypothesis.has(field):
			failures.append("hypothesis missing %s" % field)
	var domain := str(hypothesis.get("domain", "")).strip_edges()
	if not _string_array(schema.get("allowed_domains", [])).has(domain):
		failures.append("hypothesis domain %s is not allowed" % domain)
	var persistence_state := str(hypothesis.get("persistence_state", hypothesis.get("dormancy_state", ""))).strip_edges()
	if not _string_array(schema.get("allowed_persistence_states", schema.get("allowed_status_values", []))).has(persistence_state):
		failures.append("hypothesis persistence_state %s is not allowed" % persistence_state)
	for target_layer in _string_array(hypothesis.get("target_layers", [])):
		if not _string_array(schema.get("allowed_target_layers", [])).has(target_layer):
			failures.append("hypothesis target layer %s is not allowed" % target_layer)
	var confidence := int(hypothesis.get("confidence", -1))
	if confidence < 0 or confidence > 4:
		failures.append("hypothesis confidence must remain within 0..4")
	if _contains_runtime_key(hypothesis):
		failures.append("hypothesis must not expose runtime-only fields")
	return _sorted_strings(failures)

static func validate_experiment(experiment: Dictionary) -> Array[String]:
	var schema := SCHEMA_REGISTRY_SCRIPT.experiment_schema()
	var failures: Array[String] = []
	for field in _string_array(schema.get("experiment_required_fields", [])):
		if not experiment.has(field):
			failures.append("experiment missing %s" % field)
	var state := str(experiment.get("state", "")).strip_edges()
	if not _string_array(schema.get("allowed_persistence_states", schema.get("allowed_status_values", []))).has(state):
		failures.append("experiment state %s is not allowed" % state)
	for pair in [
		["target", "allowed_targets"],
		["axis", "allowed_axes"],
		["stressor", "allowed_stressors"],
		["ontology_condition", "allowed_ontology_conditions"],
		["cultural_medium", "allowed_cultural_media"],
		["time_horizon", "allowed_time_horizons"],
		["observation_contract", "allowed_observation_contracts"],
		["topology_type", "allowed_topology_types"],
		["expression_mode", "allowed_expression_modes"]
	]:
		var field := str(pair[0])
		var schema_key := str(pair[1])
		var value := str(experiment.get(field, "")).strip_edges()
		if not _string_array(schema.get(schema_key, [])).has(value):
			failures.append("experiment %s %s is not allowed" % [field, value])
	for compile_target in _string_array(Dictionary(experiment.get("compile_outputs", {})).get("compile_targets", [])):
		if not _string_array(schema.get("allowed_compile_targets", [])).has(compile_target):
			failures.append("experiment compile target %s is not allowed" % compile_target)
	failures.append_array(_validate_grammar_slots(experiment, schema))
	var fairness_bounds: Dictionary = Dictionary(experiment.get("fairness_bounds", {}))
	for fairness_key in [
		"artifact_trust_floor",
		"mechanic_legibility_floor",
		"strategic_readability_floor",
		"role_fairness_required",
		"runtime_non_mutation_required",
		"no_hidden_targeting_required"
	]:
		if not fairness_bounds.has(fairness_key):
			failures.append("experiment fairness_bounds missing %s" % fairness_key)
	if _contains_runtime_key(fairness_bounds) or _contains_runtime_key(Dictionary(experiment.get("compile_outputs", {}))):
		failures.append("experiment outputs must not expose runtime-only fields")
	return _sorted_strings(failures)

static func compile_state(
	state: Dictionary,
	world_model: Dictionary,
	doctrine: Dictionary,
	public_summary: Dictionary,
	generation_surface: Dictionary,
	ontology_snapshot: Dictionary,
	ontology_routing: Dictionary
) -> Dictionary:
	var current := normalize(state)
	var hypothesis_registry: Dictionary = Dictionary(current.get("hypotheses", {}))
	var experiment_registry: Dictionary = Dictionary(current.get("experiments", {}))
	var activation_scores: Dictionary = {}
	var selected_experiments: Array[Dictionary] = []
	for experiment_id in _sorted_strings(experiment_registry.keys()):
		var experiment: Dictionary = Dictionary(experiment_registry.get(experiment_id, {})).duplicate(true)
		var score := _activation_score(experiment, hypothesis_registry, world_model, ontology_snapshot, ontology_routing)
		activation_scores[experiment_id] = score
		if _is_live_experiment(experiment, score, world_model, ontology_snapshot):
			experiment["activation_score"] = score
			selected_experiments.append(experiment)
	selected_experiments.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("activation_score", 0)) == int(b.get("activation_score", 0)):
			return str(a.get("experiment_id", "")) < str(b.get("experiment_id", ""))
		return int(a.get("activation_score", 0)) > int(b.get("activation_score", 0))
	)
	selected_experiments = selected_experiments.slice(0, 3)
	var selected_experiment_ids: Array[String] = []
	var selected_hypothesis_ids: Array[String] = []
	var dominant_families: Array[String] = []
	var expression_modes: Array[String] = []
	var horizons: Array[String] = []
	var public_lines: Array[String] = []
	var grammar_manifest: Array[Dictionary] = []
	var compile_outputs := _default_compile_outputs()
	for experiment in selected_experiments:
		var experiment_id := str(experiment.get("experiment_id", "")).strip_edges()
		if not experiment_id.is_empty():
			selected_experiment_ids.append(experiment_id)
		var hypothesis_id := str(experiment.get("hypothesis_id", "")).strip_edges()
		if not hypothesis_id.is_empty() and not selected_hypothesis_ids.has(hypothesis_id):
			selected_hypothesis_ids.append(hypothesis_id)
		var family_id := str(experiment.get("family_id", "")).strip_edges()
		if not family_id.is_empty() and not dominant_families.has(family_id):
			dominant_families.append(family_id)
		var expression_mode := str(experiment.get("expression_mode", "")).strip_edges()
		if not expression_mode.is_empty() and not expression_modes.has(expression_mode):
			expression_modes.append(expression_mode)
		var horizon := str(experiment.get("time_horizon", "")).strip_edges()
		if not horizon.is_empty() and not horizons.has(horizon):
			horizons.append(horizon)
		public_lines = _merge_string_arrays(public_lines, _string_array(experiment.get("public_lines", [])))
		grammar_manifest.append(_grammar_manifest_entry(experiment))
		compile_outputs = _merge_compile_outputs(compile_outputs, Dictionary(experiment.get("compile_outputs", {})))
	public_lines = _merge_string_arrays(public_lines, _string_array(Dictionary(compile_outputs.get("public_activation", {})).get("surface_lines", [])))
	var selected_hypotheses: Array[Dictionary] = []
	for hypothesis_id in selected_hypothesis_ids:
		if hypothesis_registry.has(hypothesis_id):
			selected_hypotheses.append(Dictionary(hypothesis_registry.get(hypothesis_id, {})).duplicate(true))
	var compiled := {
		"schema_name": "ExperimentalOntologyState",
		"schema_version": 1,
		"hypothesis_registry": _sorted_dict_array_from_map(hypothesis_registry, "hypothesis_id"),
		"experiment_registry": _sorted_dict_array_from_map(experiment_registry, "experiment_id"),
		"live_hypothesis_ids": _sorted_strings(selected_hypothesis_ids),
		"live_experiment_ids": _sorted_strings(selected_experiment_ids),
		"live_hypotheses": _sorted_dict_array(selected_hypotheses, "hypothesis_id"),
		"live_experiments": _sorted_dict_array(selected_experiments, "experiment_id"),
		"dominant_families": _sorted_strings(dominant_families),
		"grammar_manifest": _sorted_dict_array(grammar_manifest, "experiment_id"),
		"compile_outputs": compile_outputs,
		"public_surface": {
			"lines": public_lines.slice(0, 3),
			"family_labels": _family_labels(_sorted_strings(dominant_families)),
			"expression_modes": _sorted_strings(expression_modes),
			"horizons": _sorted_strings(horizons)
		},
		"compiler_trace": {
			"experiment_schema": str(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("schema_name", "DelveMindExperiment")),
			"doctrine_family": str(doctrine.get("id", "")),
			"pressure_line": str(public_summary.get("pressure_line", "")),
			"branch_family": str(generation_surface.get("branch_family", "")),
			"selected_experiment_ids": _sorted_strings(selected_experiment_ids),
			"selected_hypothesis_ids": _sorted_strings(selected_hypothesis_ids),
			"dominant_families": _sorted_strings(dominant_families),
			"activation_scores": activation_scores.duplicate(true),
			"ontology_domains": _string_array(ontology_snapshot.get("dominant_domains", [])),
			"route_bias_tags": _string_array(ontology_routing.get("route_bias_tags", [])),
			"archival_ids": _sorted_strings(Array(current.get("archival_ids", []))),
			"foundational_ids": _sorted_strings(Array(current.get("foundational_ids", [])))
		},
		"validation_failures": _merge_string_arrays(_string_array(current.get("validation_failures", [])), [])
	}
	compiled["validation_failures"] = _merge_string_arrays(_string_array(compiled.get("validation_failures", [])), validate_compile_state(compiled))
	return compiled

static func validate_compile_state(compiled: Dictionary) -> Array[String]:
	var failures := validate_state({
		"hypotheses": _map_from_registry(_dict_array(compiled.get("hypothesis_registry", [])), "hypothesis_id"),
		"experiments": _map_from_registry(_dict_array(compiled.get("experiment_registry", [])), "experiment_id")
	})
	for field in [
		"hypothesis_registry",
		"experiment_registry",
		"live_hypothesis_ids",
		"live_experiment_ids",
		"live_hypotheses",
		"live_experiments",
		"dominant_families",
		"grammar_manifest",
		"compile_outputs",
		"public_surface",
		"compiler_trace"
	]:
		if not compiled.has(field):
			failures.append("experimental ontology compile output missing %s" % field)
	for experiment_id in _string_array(compiled.get("live_experiment_ids", [])):
		var exists := false
		for experiment_raw in _dict_array(compiled.get("experiment_registry", [])):
			if str(Dictionary(experiment_raw).get("experiment_id", "")) == experiment_id:
				exists = true
				break
		if not exists:
			failures.append("live experiment id %s is missing from experiment_registry" % experiment_id)
	var compile_outputs: Dictionary = Dictionary(compiled.get("compile_outputs", {}))
	for target in _string_array(compile_outputs.get("compile_targets", [])):
		if not _string_array(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("allowed_compile_targets", [])).has(target):
			failures.append("experimental ontology compile target %s is not allowed" % target)
	if _contains_runtime_key(compile_outputs) or _contains_runtime_key(Dictionary(compiled.get("compiler_trace", {}))):
		failures.append("experimental ontology compile outputs must not expose runtime-only fields")
	return _sorted_strings(failures)

static func build_world_lines(state: Dictionary) -> Array[String]:
	var current := normalize(state)
	var lines: Array[String] = []
	for experiment_raw in _sorted_dict_array_from_map(Dictionary(current.get("experiments", {})), "experiment_id"):
		var experiment: Dictionary = Dictionary(experiment_raw)
		var public_lines := _string_array(experiment.get("public_lines", []))
		if not public_lines.is_empty():
			lines.append(public_lines[0])
		if lines.size() >= 2:
			break
	return lines

static func _default_shell() -> Dictionary:
	return {
		"schema_name": "DelveMindExperimentState",
		"schema_version": 1,
		"hypotheses": {},
		"experiments": {},
		"history_lines": [],
		"foundational_ids": [],
		"archival_ids": [],
		"lineage_index": {}
	}

static func _build_family_hypothesis(family: Dictionary) -> Dictionary:
	var family_id := str(family.get("id", "")).strip_edges()
	var hypothesis: Dictionary = Dictionary(family.get("hypothesis", {})).duplicate(true)
	return {
		"hypothesis_id": str(hypothesis.get("hypothesis_id", "hyp_%s" % family_id)).strip_edges(),
		"domain": str(hypothesis.get("domain", family.get("domain", ""))).strip_edges(),
		"thesis": str(hypothesis.get("thesis", "")).strip_edges(),
		"confidence": clampi(int(hypothesis.get("confidence", 2)), 0, 4),
		"target_layers": _string_array(hypothesis.get("target_layers", family.get("target_layers", []))),
		"target_populations": _string_array(hypothesis.get("target_populations", [])),
		"supporting_evidence_ids": _string_array(hypothesis.get("supporting_evidence_ids", [])),
		"contradicting_evidence_ids": _string_array(hypothesis.get("contradicting_evidence_ids", [])),
		"open_branches": _string_array(hypothesis.get("open_branches", [])),
		"persistence_state": str(hypothesis.get("persistence_state", family.get("state", "dormant"))).strip_edges(),
		"dormancy_state": str(hypothesis.get("dormancy_state", hypothesis.get("persistence_state", family.get("state", "dormant")))).strip_edges(),
		"recurrence_weight": clampi(int(hypothesis.get("recurrence_weight", family.get("recurrence_weight", 1))), 0, 4),
		"foundational_flag": bool(hypothesis.get("foundational_flag", false))
	}

static func _build_family_experiment(family: Dictionary, hypothesis_id: String) -> Dictionary:
	var family_id := str(family.get("id", "")).strip_edges()
	var experiment: Dictionary = Dictionary(family.get("experiment", {})).duplicate(true)
	return {
		"experiment_id": str(experiment.get("experiment_id", "exp_%s" % family_id)).strip_edges(),
		"family_id": family_id,
		"family_label": str(family.get("label", family_id)).strip_edges(),
		"program_id": str(experiment.get("program_id", family_id)).strip_edges(),
		"hypothesis_id": str(experiment.get("hypothesis_id", hypothesis_id)).strip_edges(),
		"topology_type": str(experiment.get("topology_type", "linear")).strip_edges(),
		"target": str(experiment.get("target", "")).strip_edges(),
		"axis": str(experiment.get("axis", "")).strip_edges(),
		"stressor": str(experiment.get("stressor", "")).strip_edges(),
		"ontology_condition": str(experiment.get("ontology_condition", "")).strip_edges(),
		"cultural_medium": str(experiment.get("cultural_medium", "")).strip_edges(),
		"time_horizon": str(experiment.get("time_horizon", "short_cycle")).strip_edges(),
		"observation_contract": str(experiment.get("observation_contract", "constitution_trace")).strip_edges(),
		"fairness_bounds": _normalize_fairness_bounds(Dictionary(experiment.get("fairness_bounds", {}))),
		"state": str(experiment.get("state", family.get("state", "dormant"))).strip_edges(),
		"expression_mode": str(experiment.get("expression_mode", "whisper_mode")).strip_edges(),
		"compile_outputs": _normalize_compile_outputs(Dictionary(experiment.get("compile_outputs", {}))),
		"fitness_scores": Dictionary(experiment.get("fitness_scores", {})).duplicate(true),
		"lineage_parent_id": str(experiment.get("lineage_parent_id", "")).strip_edges(),
		"branch_ids": _string_array(experiment.get("branch_ids", [])),
		"synthesis_sources": _string_array(experiment.get("synthesis_sources", [])),
		"recurrence_weight": clampi(int(experiment.get("recurrence_weight", family.get("recurrence_weight", 1))), 0, 4),
		"public_lines": _string_array(experiment.get("public_lines", family.get("public_lines", [])))
	}

static func _normalize_hypothesis(raw: Dictionary) -> Dictionary:
	var current := {
		"hypothesis_id": str(raw.get("hypothesis_id", raw.get("id", ""))).strip_edges(),
		"domain": str(raw.get("domain", "")).strip_edges(),
		"thesis": str(raw.get("thesis", "")).strip_edges(),
		"confidence": clampi(int(raw.get("confidence", 2)), 0, 4),
		"target_layers": _string_array(raw.get("target_layers", [])),
		"target_populations": _string_array(raw.get("target_populations", [])),
		"supporting_evidence_ids": _string_array(raw.get("supporting_evidence_ids", raw.get("supporting_evidence", []))),
		"contradicting_evidence_ids": _string_array(raw.get("contradicting_evidence_ids", raw.get("contradicting_evidence", []))),
		"open_branches": _string_array(raw.get("open_branches", [])),
		"persistence_state": str(raw.get("persistence_state", raw.get("dormancy_state", "dormant"))).strip_edges(),
		"dormancy_state": str(raw.get("dormancy_state", raw.get("persistence_state", "dormant"))).strip_edges(),
		"recurrence_weight": clampi(int(raw.get("recurrence_weight", 1)), 0, 4),
		"foundational_flag": bool(raw.get("foundational_flag", false))
	}
	if current["foundational_flag"]:
		current["persistence_state"] = "foundational"
		current["dormancy_state"] = "foundational"
	return current

static func _normalize_experiment(raw: Dictionary) -> Dictionary:
	var current := {
		"experiment_id": str(raw.get("experiment_id", raw.get("id", ""))).strip_edges(),
		"family_id": str(raw.get("family_id", raw.get("family", ""))).strip_edges(),
		"family_label": str(raw.get("family_label", raw.get("label", ""))).strip_edges(),
		"program_id": str(raw.get("program_id", raw.get("experiment_id", raw.get("id", "")))).strip_edges(),
		"hypothesis_id": str(raw.get("hypothesis_id", "")).strip_edges(),
		"topology_type": str(raw.get("topology_type", "linear")).strip_edges(),
		"target": str(raw.get("target", "")).strip_edges(),
		"axis": str(raw.get("axis", "")).strip_edges(),
		"stressor": str(raw.get("stressor", "")).strip_edges(),
		"ontology_condition": str(raw.get("ontology_condition", "")).strip_edges(),
		"cultural_medium": str(raw.get("cultural_medium", "")).strip_edges(),
		"time_horizon": str(raw.get("time_horizon", raw.get("horizon", "short_cycle"))).strip_edges(),
		"observation_contract": str(raw.get("observation_contract", "constitution_trace")).strip_edges(),
		"fairness_bounds": _normalize_fairness_bounds(Dictionary(raw.get("fairness_bounds", {}))),
		"state": str(raw.get("state", raw.get("status", "dormant"))).strip_edges(),
		"expression_mode": str(raw.get("expression_mode", "whisper_mode")).strip_edges(),
		"compile_outputs": _normalize_compile_outputs(Dictionary(raw.get("compile_outputs", {}))),
		"fitness_scores": Dictionary(raw.get("fitness_scores", {})).duplicate(true),
		"lineage_parent_id": str(raw.get("lineage_parent_id", "")).strip_edges(),
		"branch_ids": _string_array(raw.get("branch_ids", [])),
		"synthesis_sources": _string_array(raw.get("synthesis_sources", [])),
		"recurrence_weight": clampi(int(raw.get("recurrence_weight", 1)), 0, 4),
		"public_lines": _string_array(raw.get("public_lines", []))
	}
	if current["state"] == "foundational":
		current["recurrence_weight"] = maxi(current["recurrence_weight"], 2)
	return current

static func _normalize_fairness_bounds(raw: Dictionary) -> Dictionary:
	return {
		"artifact_trust_floor": str(raw.get("artifact_trust_floor", "objective_central")).strip_edges(),
		"mechanic_legibility_floor": str(raw.get("mechanic_legibility_floor", "readable")).strip_edges(),
		"strategic_readability_floor": str(raw.get("strategic_readability_floor", "arguable")).strip_edges(),
		"role_fairness_required": bool(raw.get("role_fairness_required", true)),
		"runtime_non_mutation_required": bool(raw.get("runtime_non_mutation_required", true)),
		"no_hidden_targeting_required": bool(raw.get("no_hidden_targeting_required", true))
	}

static func _normalize_compile_outputs(raw: Dictionary) -> Dictionary:
	var current := _default_compile_outputs()
	for key in raw.keys():
		current[key] = raw[key]
	var constitution_weighting: Dictionary = Dictionary(current.get("constitution_weighting", {})).duplicate(true)
	constitution_weighting["pressure_verbs"] = _string_array(constitution_weighting.get("pressure_verbs", []))
	constitution_weighting["symbolic_motifs"] = _string_array(constitution_weighting.get("symbolic_motifs", []))
	constitution_weighting["public_lines"] = _string_array(constitution_weighting.get("public_lines", []))
	for scalar_key in ["item_ecology_bias_hint", "group_tension_bias_hint", "archive_tone_hint", "convergence_axis_hint"]:
		constitution_weighting[scalar_key] = str(constitution_weighting.get(scalar_key, "")).strip_edges()
	current["constitution_weighting"] = constitution_weighting
	var ontology_weighting: Dictionary = Dictionary(current.get("ontology_weighting", {})).duplicate(true)
	ontology_weighting["lineage_bias_tags"] = _string_array(ontology_weighting.get("lineage_bias_tags", []))
	ontology_weighting["niche_bias_tags"] = _string_array(ontology_weighting.get("niche_bias_tags", []))
	ontology_weighting["rediscovery_bias"] = clampi(int(ontology_weighting.get("rediscovery_bias", 0)), 0, 2)
	ontology_weighting["hybridization_bias"] = clampi(int(ontology_weighting.get("hybridization_bias", 0)), 0, 2)
	current["ontology_weighting"] = ontology_weighting
	var pressure_input_bias: Dictionary = Dictionary(current.get("pressure_input_bias", {})).duplicate(true)
	for axis in [
		"stability", "disruption", "authority", "skepticism", "fear", "curiosity",
		"certainty", "ambiguity", "ritual", "innovation", "extraction", "stewardship"
	]:
		pressure_input_bias[axis] = clampi(int(pressure_input_bias.get(axis, 0)), -1, 1)
	current["pressure_input_bias"] = pressure_input_bias
	var archive_bias: Dictionary = Dictionary(current.get("archive_framing_bias", {})).duplicate(true)
	archive_bias["lines"] = _string_array(archive_bias.get("lines", []))
	archive_bias["emphasis_tags"] = _string_array(archive_bias.get("emphasis_tags", []))
	current["archive_framing_bias"] = archive_bias
	var public_activation: Dictionary = Dictionary(current.get("public_activation", {})).duplicate(true)
	public_activation["surface_lines"] = _string_array(public_activation.get("surface_lines", []))
	current["public_activation"] = public_activation
	current["legitimacy_stress"] = clampi(int(current.get("legitimacy_stress", 0)), 0, 2)
	current["rumor_volatility"] = clampi(int(current.get("rumor_volatility", 0)), 0, 2)
	current["wonder_allocation"] = clampi(int(current.get("wonder_allocation", 0)), 0, 2)
	current["compile_targets"] = _string_array(current.get("compile_targets", []))
	return current

static func _validate_grammar_slots(experiment: Dictionary, _schema: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	var target := str(experiment.get("target", "")).strip_edges()
	var medium := str(experiment.get("cultural_medium", "")).strip_edges()
	var axis := str(experiment.get("axis", "")).strip_edges()
	var stressor := str(experiment.get("stressor", "")).strip_edges()
	var topology := str(experiment.get("topology_type", "")).strip_edges()
	var horizon := str(experiment.get("time_horizon", "")).strip_edges()
	if not _allowed_media_for_target(target).has(medium):
		failures.append("experiment cultural_medium %s is incompatible with target %s" % [medium, target])
	if not _allowed_stressors_for_axis(axis).has(stressor):
		failures.append("experiment stressor %s is incompatible with axis %s" % [stressor, axis])
	if not _allowed_horizons_for_topology(topology).has(horizon):
		failures.append("experiment time_horizon %s is incompatible with topology_type %s" % [horizon, topology])
	return failures

static func _is_live_experiment(experiment: Dictionary, score: int, world_model: Dictionary, ontology_snapshot: Dictionary) -> bool:
	var state := str(experiment.get("state", "dormant")).strip_edges()
	match state:
		"foundational":
			return score >= 2
		"active":
			return score >= 2
		"recurring":
			return score >= 3
		"rare":
			return score >= 4
		"dormant":
			return score >= 4 and _rediscovery_ready(experiment, world_model, ontology_snapshot)
		"archival":
			return score >= 5 and _rediscovery_ready(experiment, world_model, ontology_snapshot)
		_:
			return false

static func _rediscovery_ready(experiment: Dictionary, world_model: Dictionary, ontology_snapshot: Dictionary) -> bool:
	var condition := str(experiment.get("ontology_condition", "")).strip_edges()
	if condition in ["missing_verification_classes", "taboo_category_activation", "rediscovered_extinct_categories", "hybrid_lineage_emergence"]:
		if _absence_present(ontology_snapshot, condition):
			return true
		if not _string_array(ontology_snapshot.get("rediscovery_candidates", [])).is_empty():
			return true
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	return int(cultural.get("counterfactual_heat", 0)) >= 2 or int(cultural.get("revision_pressure", 0)) >= 2

static func _activation_score(experiment: Dictionary, hypotheses: Dictionary, world_model: Dictionary, ontology_snapshot: Dictionary, ontology_routing: Dictionary) -> int:
	var score := int(experiment.get("recurrence_weight", 0))
	match str(experiment.get("state", "dormant")).strip_edges():
		"foundational":
			score += 2
		"active":
			score += 2
		"recurring":
			score += 1
		"rare":
			score += 1
		"dormant":
			score -= 1
	var hypothesis: Dictionary = Dictionary(hypotheses.get(str(experiment.get("hypothesis_id", "")), {}))
	score += int(hypothesis.get("confidence", 0))
	score += _axis_signal_score(str(experiment.get("axis", "")), world_model)
	score += _stressor_signal_score(str(experiment.get("stressor", "")), world_model)
	score += _ontology_condition_score(str(experiment.get("ontology_condition", "")), ontology_snapshot, ontology_routing)
	if bool(hypothesis.get("foundational_flag", false)):
		score += 1
	return clampi(score, 0, 12)

static func _axis_signal_score(axis: String, world_model: Dictionary) -> int:
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var social: Dictionary = Dictionary(world_model.get("social_model", {}))
	match axis:
		"stability":
			return _band(int(cultural.get("legitimacy_pressure", 0)) + int(social.get("alliance_stability", 0)))
		"disruption":
			return _band(int(cultural.get("contradiction_heat", 0)) + int(cultural.get("revision_pressure", 0)))
		"authority":
			return _band(int(cultural.get("orthodoxy_strength", 0)) + int(cultural.get("legitimacy_pressure", 0)))
		"skepticism":
			return _band(int(cultural.get("revision_pressure", 0)) + int(cultural.get("semantic_drift", 0)))
		"fear":
			return _band(int(cultural.get("paranoia_heat", 0)) + int(cultural.get("taboo_heat", 0)))
		"curiosity":
			return _band(int(cultural.get("counterfactual_heat", 0)) + int(cultural.get("hope_heat", 0)))
		"certainty":
			return _band(int(cultural.get("orthodoxy_strength", 0)) + int(cultural.get("witness_network_pressure", 0)))
		"ambiguity":
			return _band(int(cultural.get("semantic_drift", 0)) + int(cultural.get("false_canon_pressure", 0)))
		"ritual":
			return _band(int(cultural.get("sacred_pressure", 0)) + int(cultural.get("ritual_spread", 0)))
		"innovation":
			return _band(int(cultural.get("counterfactual_heat", 0)) + int(cultural.get("revision_pressure", 0)))
		"extraction":
			return _band(int(cultural.get("practical_pressure", 0)) + int(Dictionary(world_model.get("route_model", {})).get("route_control", 0)))
		"stewardship":
			return _band(int(cultural.get("custody_pressure", 0)) + int(Dictionary(world_model.get("economy_model", {})).get("burden_tolerance", 0)))
		_:
			return 0

static func _stressor_signal_score(stressor: String, world_model: Dictionary) -> int:
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var route: Dictionary = Dictionary(world_model.get("route_model", {}))
	match stressor:
		"contradiction":
			return _band(int(cultural.get("contradiction_heat", 0)) + int(cultural.get("false_canon_pressure", 0)))
		"classification_drift":
			return _band(int(cultural.get("semantic_drift", 0)) + int(cultural.get("revision_pressure", 0)))
		"public_attention":
			return _band(int(cultural.get("spread_heat", 0)) + int(cultural.get("legitimacy_pressure", 0)))
		"ritual_load":
			return _band(int(cultural.get("sacred_pressure", 0)) + int(cultural.get("burial_pressure", 0)))
		"archive_echo":
			return _band(int(world_model.get("archive_legends", 0)) + int(cultural.get("myth_gravity", 0)))
		"stewardship_debt":
			return _band(int(cultural.get("custody_pressure", 0)) + int(cultural.get("burial_pressure", 0)) + int(route.get("relay_stress", 0)))
		_:
			return 0

static func _ontology_condition_score(condition: String, ontology_snapshot: Dictionary, ontology_routing: Dictionary) -> int:
	match condition:
		"missing_verification_classes":
			return 2 if _absence_present(ontology_snapshot, condition) or _string_array(ontology_routing.get("item_bias_tags", [])).has("verification_dispute") else 0
		"taboo_category_activation":
			return 2 if _absence_present(ontology_snapshot, condition) or _string_array(ontology_routing.get("route_bias_tags", [])).has("taboo_threshold") else 0
		"rediscovered_extinct_categories":
			return 2 if _absence_present(ontology_snapshot, condition) or not _string_array(ontology_snapshot.get("rediscovery_candidates", [])).is_empty() else 0
		"hybrid_lineage_emergence":
			return clampi(int(Dictionary(ontology_routing.get("hybridization", {})).get("hybridization_bias", 0)), 0, 2)
		"residue_density_spike":
			return 2 if _string_array(ontology_snapshot.get("dominant_domains", [])).has("residue_classes") else 1 if not _string_array(ontology_snapshot.get("public_lines", [])).is_empty() else 0
		"ritual_fragment_return":
			return 2 if _string_array(ontology_routing.get("dominant_lineages", [])).has("ritual_custody_lineage") else 1 if _string_array(ontology_snapshot.get("dominant_domains", [])).has("ritual_families") else 0
		_:
			return 0

static func _merge_compile_outputs(base_outputs: Dictionary, addition_outputs: Dictionary) -> Dictionary:
	var base := _normalize_compile_outputs(base_outputs)
	var addition := _normalize_compile_outputs(addition_outputs)
	var merged := _default_compile_outputs()
	var constitution_weighting: Dictionary = Dictionary(base.get("constitution_weighting", {})).duplicate(true)
	var addition_constitution: Dictionary = Dictionary(addition.get("constitution_weighting", {})).duplicate(true)
	constitution_weighting["pressure_verbs"] = _merge_string_arrays(_string_array(constitution_weighting.get("pressure_verbs", [])), _string_array(addition_constitution.get("pressure_verbs", [])))
	constitution_weighting["symbolic_motifs"] = _merge_string_arrays(_string_array(constitution_weighting.get("symbolic_motifs", [])), _string_array(addition_constitution.get("symbolic_motifs", [])))
	constitution_weighting["public_lines"] = _merge_string_arrays(_string_array(constitution_weighting.get("public_lines", [])), _string_array(addition_constitution.get("public_lines", [])))
	for scalar_key in ["item_ecology_bias_hint", "group_tension_bias_hint", "archive_tone_hint", "convergence_axis_hint"]:
		constitution_weighting[scalar_key] = str(addition_constitution.get(scalar_key, constitution_weighting.get(scalar_key, ""))).strip_edges()
	var ontology_weighting: Dictionary = Dictionary(base.get("ontology_weighting", {})).duplicate(true)
	var addition_ontology: Dictionary = Dictionary(addition.get("ontology_weighting", {})).duplicate(true)
	ontology_weighting["lineage_bias_tags"] = _merge_string_arrays(_string_array(ontology_weighting.get("lineage_bias_tags", [])), _string_array(addition_ontology.get("lineage_bias_tags", [])))
	ontology_weighting["niche_bias_tags"] = _merge_string_arrays(_string_array(ontology_weighting.get("niche_bias_tags", [])), _string_array(addition_ontology.get("niche_bias_tags", [])))
	ontology_weighting["rediscovery_bias"] = clampi(int(ontology_weighting.get("rediscovery_bias", 0)) + int(addition_ontology.get("rediscovery_bias", 0)), 0, 2)
	ontology_weighting["hybridization_bias"] = clampi(int(ontology_weighting.get("hybridization_bias", 0)) + int(addition_ontology.get("hybridization_bias", 0)), 0, 2)
	var pressure_input_bias: Dictionary = {}
	for axis in [
		"stability", "disruption", "authority", "skepticism", "fear", "curiosity",
		"certainty", "ambiguity", "ritual", "innovation", "extraction", "stewardship"
	]:
		pressure_input_bias[axis] = clampi(int(Dictionary(base.get("pressure_input_bias", {})).get(axis, 0)) + int(Dictionary(addition.get("pressure_input_bias", {})).get(axis, 0)), -1, 1)
	var archive_bias: Dictionary = Dictionary(base.get("archive_framing_bias", {})).duplicate(true)
	var addition_archive: Dictionary = Dictionary(addition.get("archive_framing_bias", {})).duplicate(true)
	archive_bias["lines"] = _merge_string_arrays(_string_array(archive_bias.get("lines", [])), _string_array(addition_archive.get("lines", [])))
	archive_bias["emphasis_tags"] = _merge_string_arrays(_string_array(archive_bias.get("emphasis_tags", [])), _string_array(addition_archive.get("emphasis_tags", [])))
	var public_activation: Dictionary = Dictionary(base.get("public_activation", {})).duplicate(true)
	var addition_public: Dictionary = Dictionary(addition.get("public_activation", {})).duplicate(true)
	public_activation["surface_lines"] = _merge_string_arrays(_string_array(public_activation.get("surface_lines", [])), _string_array(addition_public.get("surface_lines", [])))
	merged["constitution_weighting"] = constitution_weighting
	merged["ontology_weighting"] = ontology_weighting
	merged["pressure_input_bias"] = pressure_input_bias
	merged["archive_framing_bias"] = archive_bias
	merged["public_activation"] = public_activation
	merged["legitimacy_stress"] = clampi(int(base.get("legitimacy_stress", 0)) + int(addition.get("legitimacy_stress", 0)), 0, 2)
	merged["rumor_volatility"] = clampi(int(base.get("rumor_volatility", 0)) + int(addition.get("rumor_volatility", 0)), 0, 2)
	merged["wonder_allocation"] = clampi(int(base.get("wonder_allocation", 0)) + int(addition.get("wonder_allocation", 0)), 0, 2)
	merged["compile_targets"] = _merge_string_arrays(_string_array(base.get("compile_targets", [])), _string_array(addition.get("compile_targets", [])))
	return merged

static func _default_compile_outputs() -> Dictionary:
	return {
		"constitution_weighting": {
			"pressure_verbs": [],
			"symbolic_motifs": [],
			"public_lines": [],
			"item_ecology_bias_hint": "",
			"group_tension_bias_hint": "",
			"archive_tone_hint": "",
			"convergence_axis_hint": ""
		},
		"ontology_weighting": {
			"lineage_bias_tags": [],
			"niche_bias_tags": [],
			"rediscovery_bias": 0,
			"hybridization_bias": 0
		},
		"pressure_input_bias": {
			"stability": 0,
			"disruption": 0,
			"authority": 0,
			"skepticism": 0,
			"fear": 0,
			"curiosity": 0,
			"certainty": 0,
			"ambiguity": 0,
			"ritual": 0,
			"innovation": 0,
			"extraction": 0,
			"stewardship": 0
		},
		"archive_framing_bias": {
			"lines": [],
			"emphasis_tags": []
		},
		"public_activation": {
			"surface_lines": []
		},
		"legitimacy_stress": 0,
		"rumor_volatility": 0,
		"wonder_allocation": 0,
		"compile_targets": []
	}

static func _grammar_manifest_entry(experiment: Dictionary) -> Dictionary:
	return {
		"experiment_id": str(experiment.get("experiment_id", "")),
		"target": str(experiment.get("target", "")),
		"axis": str(experiment.get("axis", "")),
		"stressor": str(experiment.get("stressor", "")),
		"ontology_condition": str(experiment.get("ontology_condition", "")),
		"cultural_medium": str(experiment.get("cultural_medium", "")),
		"time_horizon": str(experiment.get("time_horizon", "")),
		"observation_contract": str(experiment.get("observation_contract", "")),
		"topology_type": str(experiment.get("topology_type", "")),
		"expression_mode": str(experiment.get("expression_mode", "")),
		"compile_targets": _string_array(Dictionary(experiment.get("compile_outputs", {})).get("compile_targets", []))
	}

static func _allowed_media_for_target(target: String) -> Array[String]:
	match target:
		"constitution":
			return ["institutional_memo", "archive_case", "legend_cluster"]
		"ontology":
			return ["archive_case", "legend_cluster", "ritual_annotation"]
		"archive":
			return ["archive_case", "legend_cluster", "institutional_memo"]
		"pressure_ecology":
			return ["rumor_field", "public_shorthand", "archive_case"]
		"framing":
			return ["public_shorthand", "legend_cluster", "archive_case"]
		"continuity":
			return ["archive_case", "legend_cluster", "ritual_annotation"]
		_:
			return _string_array(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("allowed_cultural_media", []))

static func _allowed_stressors_for_axis(axis: String) -> Array[String]:
	match axis:
		"stability", "authority", "certainty":
			return ["classification_drift", "public_attention", "ritual_load"]
		"disruption", "skepticism", "ambiguity":
			return ["contradiction", "classification_drift", "archive_echo"]
		"fear", "curiosity":
			return ["archive_echo", "public_attention", "contradiction"]
		"ritual", "innovation":
			return ["ritual_load", "archive_echo", "classification_drift"]
		"extraction", "stewardship":
			return ["public_attention", "stewardship_debt", "archive_echo"]
		_:
			return _string_array(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("allowed_stressors", []))

static func _allowed_horizons_for_topology(topology: String) -> Array[String]:
	match topology:
		"linear":
			return ["immediate", "short_cycle", "seasonal", "long_arc"]
		"branching":
			return ["short_cycle", "seasonal", "long_arc"]
		"recurring":
			return ["seasonal", "long_arc"]
		"synthesis":
			return ["seasonal", "long_arc"]
		_:
			return _string_array(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("allowed_time_horizons", []))

static func _family_labels(family_ids: Array[String]) -> Array[String]:
	var result: Array[String] = []
	var families: Dictionary = {}
	for family_raw in SCHEMA_REGISTRY_SCRIPT.experiment_families():
		var family: Dictionary = Dictionary(family_raw)
		families[str(family.get("id", ""))] = str(family.get("label", family.get("id", "")))
	for family_id in family_ids:
		var label := str(families.get(family_id, family_id)).strip_edges()
		if not label.is_empty() and not result.has(label):
			result.append(label)
	return result

static func _foundational_ids(experiment_registry: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for experiment_id in experiment_registry.keys():
		var experiment: Dictionary = Dictionary(experiment_registry.get(experiment_id, {}))
		if str(experiment.get("state", "")).strip_edges() == "foundational":
			ids.append(str(experiment.get("experiment_id", experiment_id)))
	return ids

static func _archival_ids(experiment_registry: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for experiment_id in experiment_registry.keys():
		var experiment: Dictionary = Dictionary(experiment_registry.get(experiment_id, {}))
		if str(experiment.get("state", "")).strip_edges() == "archival":
			ids.append(str(experiment.get("experiment_id", experiment_id)))
	return ids

static func _build_lineage_index(experiment_registry: Dictionary) -> Dictionary:
	var parent_to_branches: Dictionary = {}
	var synthesis_to_children: Dictionary = {}
	var state_bands: Dictionary = {}
	var recurrence_weights: Dictionary = {}
	for experiment_id in _sorted_strings(experiment_registry.keys()):
		var experiment: Dictionary = Dictionary(experiment_registry.get(experiment_id, {}))
		var canonical_id := str(experiment.get("experiment_id", experiment_id)).strip_edges()
		var parent_id := str(experiment.get("lineage_parent_id", "")).strip_edges()
		if not parent_id.is_empty():
			var children := _string_array(parent_to_branches.get(parent_id, []))
			children = _merge_string_arrays(children, [canonical_id])
			parent_to_branches[parent_id] = children
		for source in _string_array(experiment.get("synthesis_sources", [])):
			var children := _string_array(synthesis_to_children.get(source, []))
			children = _merge_string_arrays(children, [canonical_id])
			synthesis_to_children[source] = children
		var state := str(experiment.get("state", "dormant")).strip_edges()
		var bucket := _string_array(state_bands.get(state, []))
		bucket = _merge_string_arrays(bucket, [canonical_id])
		state_bands[state] = bucket
		recurrence_weights[canonical_id] = int(experiment.get("recurrence_weight", 0))
	return {
		"parent_to_branches": parent_to_branches,
		"synthesis_to_children": synthesis_to_children,
		"state_bands": state_bands,
		"recurrence_weights": recurrence_weights
	}

static func _merge_dicts(base: Dictionary, addition: Dictionary) -> Dictionary:
	var merged := base.duplicate(true)
	for key in addition.keys():
		var base_value: Variant = merged.get(key)
		var addition_value: Variant = addition.get(key)
		if base_value is Dictionary and addition_value is Dictionary:
			merged[key] = _merge_dicts(Dictionary(base_value), Dictionary(addition_value))
		else:
			merged[key] = addition_value
	return merged

static func _contains_runtime_key(value: Variant) -> bool:
	for banned in RUNTIME_FORBIDDEN_FIELDS:
		if _contains_key(value, banned):
			return true
	for banned in _string_array(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("forbidden_runtime_fields", [])):
		if _contains_key(value, banned):
			return true
	return false

static func _contains_key(value: Variant, banned_key: String) -> bool:
	match typeof(value):
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			if dict.has(banned_key):
				return true
			for child in dict.values():
				if _contains_key(child, banned_key):
					return true
		TYPE_ARRAY:
			for child in value:
				if _contains_key(child, banned_key):
					return true
	return false

static func _absence_present(ontology_snapshot: Dictionary, condition: String) -> bool:
	var absent_nodes := _dict_array(ontology_snapshot.get("absent_nodes", []))
	for absence_raw in absent_nodes:
		var absence: Dictionary = Dictionary(absence_raw)
		var absence_type := str(absence.get("absence_type", "")).strip_edges()
		if condition == "missing_verification_classes" and absence_type == "missing_verification_method":
			return true
		if condition == "taboo_category_activation" and absence_type == "taboo_class":
			return true
		if condition == "rediscovered_extinct_categories" and absence_type == "extinct_class":
			return true
		if condition == "ritual_fragment_return" and absence_type == "dormant_ritual_mode":
			return true
	return false

static func _band(total: int) -> int:
	if total >= 8:
		return 2
	if total >= 4:
		return 1
	return 0

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array or values is PackedStringArray:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _sorted_strings(values: Variant) -> Array[String]:
	var result := _string_array(values)
	result.sort()
	return result

static func _merge_string_arrays(base_values: Variant, extra_values: Variant) -> Array[String]:
	var result := _string_array(base_values)
	for value in _string_array(extra_values):
		if not result.has(value):
			result.append(value)
	return _sorted_strings(result)

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

static func _sorted_dict_array(values: Array[Dictionary], key_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		result.append(Dictionary(value).duplicate(true))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get(key_name, "")) < str(b.get(key_name, ""))
	)
	return result

static func _sorted_dict_array_from_map(values: Dictionary, key_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key in _sorted_strings(values.keys()):
		var entry: Dictionary = Dictionary(values.get(key, {})).duplicate(true)
		if not entry.has(key_name):
			entry[key_name] = str(key)
		result.append(entry)
	return _sorted_dict_array(result, key_name)

static func _map_from_registry(values: Array[Dictionary], key_name: String) -> Dictionary:
	var result: Dictionary = {}
	for value_raw in values:
		var value: Dictionary = Dictionary(value_raw)
		var key := str(value.get(key_name, "")).strip_edges()
		if not key.is_empty():
			result[key] = value.duplicate(true)
	return result
