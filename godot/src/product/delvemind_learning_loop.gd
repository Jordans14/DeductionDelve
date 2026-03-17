class_name DelveMindLearningLoop
extends RefCounted

const SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")

const MAX_EVALUATION_RECORDS := 24
const MAX_TRACE_LINES := 6
const MAX_GUIDANCE_VALUES := 3

const RUNTIME_FORBIDDEN_FIELDS := [
	"peer_ids",
	"runtime_state",
	"event_log",
	"physics_override",
	"legality_override",
	"artifact_truth_override",
	"runtime_ai_arbitration"
]

static func default_learning_state() -> Dictionary:
	return normalize_learning_state({})

static func normalize_learning_state(raw: Dictionary) -> Dictionary:
	var current := {
		"schema_name": "DelveMindLearningState",
		"schema_version": 1,
		"evaluation_records": [],
		"meta_learning": _default_meta_learning(),
		"compiler_guidance": _default_compiler_guidance(),
		"public_lines": [],
		"operator_lines": [],
		"validation_failures": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["evaluation_records"] = _normalize_evaluation_records(Array(current.get("evaluation_records", [])))
	current["meta_learning"] = _normalize_meta_learning(Dictionary(current.get("meta_learning", {})))
	current["compiler_guidance"] = normalize_compiler_guidance(Dictionary(current.get("compiler_guidance", {})))
	current["public_lines"] = _slice_strings(
		_merge_string_arrays(
			_string_array(current.get("public_lines", [])),
			_string_array(Dictionary(current.get("compiler_guidance", {})).get("public_lines", []))
		),
		MAX_TRACE_LINES
	)
	current["operator_lines"] = _slice_strings(
		_merge_string_arrays(
			_string_array(current.get("operator_lines", [])),
			_string_array(Dictionary(current.get("compiler_guidance", {})).get("operator_lines", []))
		),
		MAX_TRACE_LINES
	)
	current["validation_failures"] = validate_learning_state(current)
	return current

static func normalize_compiler_guidance(raw: Dictionary) -> Dictionary:
	var current := _default_compiler_guidance()
	for key in raw.keys():
		current[key] = raw[key]
	for key in [
		"preferred_topologies",
		"suppressed_topologies",
		"preferred_horizons",
		"suppressed_horizons",
		"preferred_media",
		"suppressed_media",
		"branch_pressure_families",
		"synthesis_candidates",
		"revive_candidates",
		"public_lines",
		"operator_lines"
	]:
		current[key] = _slice_strings(_string_array(current.get(key, [])), MAX_GUIDANCE_VALUES if key.find("lines") == -1 else MAX_TRACE_LINES)
	return current

static func guidance_from_learning_state(raw: Dictionary) -> Dictionary:
	return normalize_compiler_guidance(Dictionary(normalize_learning_state(raw).get("compiler_guidance", {})))

static func validate_learning_state(learning_state: Dictionary, hypotheses: Dictionary = {}, experiments: Dictionary = {}) -> Array[String]:
	var schema := SCHEMA_REGISTRY_SCRIPT.evaluation_schema()
	var failures: Array[String] = []
	for key in ["evaluation_records", "meta_learning", "compiler_guidance", "public_lines", "operator_lines"]:
		if not learning_state.has(key):
			failures.append("DelveMindLearningState missing %s" % key)
	var meta_learning: Dictionary = Dictionary(learning_state.get("meta_learning", {}))
	for key in _string_array(schema.get("meta_learning_required_fields", [])):
		if not meta_learning.has(key):
			failures.append("DelveMindLearningState meta_learning missing %s" % key)
	var guidance_failures := validate_compiler_guidance(Dictionary(learning_state.get("compiler_guidance", {})))
	if not guidance_failures.is_empty():
		failures.append_array(guidance_failures)
	for record_raw in Array(learning_state.get("evaluation_records", [])):
		failures.append_array(validate_evaluation_record(Dictionary(record_raw), hypotheses, experiments))
	if _contains_runtime_key(learning_state):
		failures.append("DelveMindLearningState must not expose runtime-only fields")
	return _sorted_strings(failures)

static func validate_compiler_guidance(guidance: Dictionary) -> Array[String]:
	var schema := SCHEMA_REGISTRY_SCRIPT.evaluation_schema()
	var failures: Array[String] = []
	for key in _string_array(schema.get("guidance_required_fields", [])):
		if not guidance.has(key):
			failures.append("DelveMind compiler_guidance missing %s" % key)
	if _contains_runtime_key(guidance):
		failures.append("DelveMind compiler_guidance must not expose runtime-only fields")
	return _sorted_strings(failures)

static func validate_evaluation_record(record: Dictionary, hypotheses: Dictionary = {}, experiments: Dictionary = {}) -> Array[String]:
	var schema := SCHEMA_REGISTRY_SCRIPT.evaluation_schema()
	var failures: Array[String] = []
	for field in _string_array(schema.get("evaluation_required_fields", [])):
		if not record.has(field):
			failures.append("evaluation record missing %s" % field)
	var dimensions: Dictionary = Dictionary(record.get("dimensions", {}))
	for key in _string_array(schema.get("dimension_keys", [])):
		if not dimensions.has(key):
			failures.append("evaluation record dimensions missing %s" % key)
		elif int(dimensions.get(key, -1)) < 0 or int(dimensions.get(key, -1)) > 4:
			failures.append("evaluation record dimension %s must remain within 0..4" % key)
	for outcome in _string_array(record.get("outcomes", [])):
		if not _string_array(schema.get("allowed_outcomes", [])).has(outcome):
			failures.append("evaluation outcome %s is not allowed" % outcome)
	var hypothesis_id := str(record.get("hypothesis_id", "")).strip_edges()
	var experiment_id := str(record.get("experiment_id", "")).strip_edges()
	if not hypotheses.is_empty() and not _registry_has(hypotheses, hypothesis_id, "hypothesis_id"):
		failures.append("evaluation record references missing hypothesis %s" % hypothesis_id)
	if not experiments.is_empty():
		if not _registry_has(experiments, experiment_id, "experiment_id"):
			failures.append("evaluation record references missing experiment %s" % experiment_id)
		else:
			var experiment: Dictionary = Dictionary(experiments.get(experiment_id, {}))
			if str(experiment.get("hypothesis_id", "")).strip_edges() != hypothesis_id:
				failures.append("evaluation record experiment %s does not match hypothesis %s" % [experiment_id, hypothesis_id])
	var continuity_effects: Dictionary = Dictionary(record.get("continuity_effects", {}))
	var state_transition: Dictionary = Dictionary(continuity_effects.get("state_transition", {}))
	var from_state := str(state_transition.get("from", "")).strip_edges()
	var to_state := str(state_transition.get("to", "")).strip_edges()
	if not from_state.is_empty() and not to_state.is_empty() and not _allowed_state_transition(from_state, to_state):
		failures.append("evaluation record state transition %s -> %s is not allowed" % [from_state, to_state])
	var persistence_transition: Dictionary = Dictionary(continuity_effects.get("persistence_transition", {}))
	var from_persistence := str(persistence_transition.get("from", "")).strip_edges()
	var to_persistence := str(persistence_transition.get("to", "")).strip_edges()
	if not from_persistence.is_empty() and not to_persistence.is_empty() and not _allowed_persistence_transition(from_persistence, to_persistence):
		failures.append("evaluation record persistence transition %s -> %s is not allowed" % [from_persistence, to_persistence])
	var confidence_delta := int(continuity_effects.get("confidence_delta", 0))
	if confidence_delta < -1 or confidence_delta > 1:
		failures.append("evaluation record confidence_delta must remain within -1..1")
	var recurrence_delta := int(continuity_effects.get("recurrence_delta", 0))
	if recurrence_delta < -1 or recurrence_delta > 1:
		failures.append("evaluation record recurrence_delta must remain within -1..1")
	if _contains_runtime_key(record):
		failures.append("evaluation record must not expose runtime-only fields")
	return _sorted_strings(failures)

static func apply_post_run_learning(
	state: Dictionary,
	run_record: Dictionary,
	diagnostics: Dictionary = {},
	frame: Dictionary = {}
) -> Dictionary:
	var hypotheses := Dictionary(state.get("hypotheses", {})).duplicate(true)
	var experiments := Dictionary(state.get("experiments", {})).duplicate(true)
	var learning_state := normalize_learning_state(Dictionary(state.get("learning_state", {})))
	var evaluation_records: Array = Array(learning_state.get("evaluation_records", [])).duplicate(true)
	var manifested_ids := _manifested_experiment_ids(experiments, run_record, diagnostics)
	if manifested_ids.is_empty():
		var untouched := state.duplicate(true)
		untouched["learning_state"] = learning_state
		return untouched
	var recent_records: Array[Dictionary] = []
	for experiment_id in manifested_ids:
		var experiment: Dictionary = Dictionary(experiments.get(experiment_id, {})).duplicate(true)
		var hypothesis: Dictionary = Dictionary(hypotheses.get(str(experiment.get("hypothesis_id", "")), {})).duplicate(true)
		if experiment.is_empty() or hypothesis.is_empty():
			continue
		var record := _build_evaluation_record(experiment, hypothesis, run_record, diagnostics, frame)
		recent_records.append(record)
		evaluation_records.push_front(record)
		hypotheses[record["hypothesis_id"]] = _apply_hypothesis_update(hypothesis, record)
		experiments[record["experiment_id"]] = _apply_experiment_update(experiment, record)
	var normalized_records := _normalize_evaluation_records(evaluation_records)
	var meta_learning := _normalize_meta_learning(Dictionary(learning_state.get("meta_learning", {})))
	for record_raw in recent_records:
		meta_learning = _apply_meta_learning(meta_learning, Dictionary(record_raw))
	var compiler_guidance := _derive_compiler_guidance(meta_learning, normalized_records, experiments)
	learning_state["evaluation_records"] = normalized_records
	learning_state["meta_learning"] = meta_learning
	learning_state["compiler_guidance"] = compiler_guidance
	learning_state["public_lines"] = _slice_strings(_merge_string_arrays(
		_slice_strings(_trace_lines_from_records(recent_records, "public_trace_lines"), 2),
		_string_array(compiler_guidance.get("public_lines", []))
	), MAX_TRACE_LINES)
	learning_state["operator_lines"] = _slice_strings(_merge_string_arrays(
		_slice_strings(_trace_lines_from_records(recent_records, "operator_trace_lines"), 2),
		_string_array(compiler_guidance.get("operator_lines", []))
	), MAX_TRACE_LINES)
	learning_state["validation_failures"] = validate_learning_state(learning_state, hypotheses, experiments)
	var next := state.duplicate(true)
	next["hypotheses"] = hypotheses
	next["experiments"] = experiments
	next["learning_state"] = learning_state
	return next

static func _build_evaluation_record(
	experiment: Dictionary,
	hypothesis: Dictionary,
	run_record: Dictionary,
	diagnostics: Dictionary,
	_frame: Dictionary
) -> Dictionary:
	var dimensions := _build_dimensions(experiment, hypothesis, run_record, diagnostics)
	var target_state := _target_state_for_evaluation(experiment, dimensions)
	var target_persistence := _target_persistence_for_evaluation(hypothesis, target_state)
	var outcomes := _derive_outcomes(experiment, dimensions, target_state)
	var continuity_effects := {
		"confidence_delta": _confidence_delta(outcomes),
		"recurrence_delta": _recurrence_delta(experiment, target_state, outcomes),
		"state_transition": {
			"from": str(experiment.get("state", "dormant")).strip_edges(),
			"to": target_state
		},
		"persistence_transition": {
			"from": str(hypothesis.get("persistence_state", hypothesis.get("dormancy_state", "dormant"))).strip_edges(),
			"to": target_persistence
		},
		"branch_pressure_family": str(experiment.get("family_id", "")).strip_edges() if outcomes.has("split_hypothesis") else "",
		"synthesis_cue": str(experiment.get("experiment_id", "")).strip_edges() if outcomes.has("synthesize_broader_theory") else "",
		"revive_candidate": str(experiment.get("experiment_id", "")).strip_edges() if _revived_state(str(experiment.get("state", "")), target_state) else "",
		"fairness_vetoed": int(dimensions.get("fairness_stability", 0)) <= 1
	}
	var record := {
		"evaluation_id": "",
		"run_seed": int(run_record.get("seed", 0)),
		"hypothesis_id": str(hypothesis.get("hypothesis_id", "")).strip_edges(),
		"experiment_id": str(experiment.get("experiment_id", "")).strip_edges(),
		"family_id": str(experiment.get("family_id", "")).strip_edges(),
		"dimensions": dimensions,
		"outcomes": outcomes,
		"supporting_evidence": _supporting_evidence_ids(experiment, run_record, diagnostics, dimensions, outcomes),
		"contradicting_evidence": _contradicting_evidence_ids(experiment, run_record, diagnostics, dimensions, outcomes),
		"continuity_effects": continuity_effects,
		"observation_signature": _observation_signature(experiment, run_record, diagnostics),
		"public_trace_lines": _public_trace_lines(experiment, dimensions, outcomes, target_state),
		"operator_trace_lines": _operator_trace_lines(experiment, dimensions, outcomes, target_state)
	}
	record["evaluation_id"] = _evaluation_id(record)
	return _normalize_evaluation_record(record)

static func _normalize_evaluation_records(values: Array) -> Array:
	var deduped: Array[Dictionary] = []
	var seen: Dictionary = {}
	for value in values:
		if not (value is Dictionary):
			continue
		var record := _normalize_evaluation_record(Dictionary(value))
		var evaluation_id := str(record.get("evaluation_id", "")).strip_edges()
		if evaluation_id.is_empty() or seen.has(evaluation_id):
			continue
		seen[evaluation_id] = true
		deduped.append(record)
	return deduped.slice(0, MAX_EVALUATION_RECORDS)

static func _normalize_evaluation_record(raw: Dictionary) -> Dictionary:
	var schema := SCHEMA_REGISTRY_SCRIPT.evaluation_schema()
	var dimensions: Dictionary = {}
	for key in _string_array(schema.get("dimension_keys", [])):
		dimensions[key] = clampi(int(Dictionary(raw.get("dimensions", {})).get(key, 0)), 0, 4)
	var current := {
		"evaluation_id": str(raw.get("evaluation_id", "")).strip_edges(),
		"run_seed": int(raw.get("run_seed", 0)),
		"hypothesis_id": str(raw.get("hypothesis_id", "")).strip_edges(),
		"experiment_id": str(raw.get("experiment_id", "")).strip_edges(),
		"family_id": str(raw.get("family_id", "")).strip_edges(),
		"dimensions": dimensions,
		"outcomes": _slice_strings(_string_array(raw.get("outcomes", [])), 6),
		"supporting_evidence": _slice_strings(_string_array(raw.get("supporting_evidence", [])), 6),
		"contradicting_evidence": _slice_strings(_string_array(raw.get("contradicting_evidence", [])), 6),
		"continuity_effects": {
			"confidence_delta": clampi(int(Dictionary(raw.get("continuity_effects", {})).get("confidence_delta", 0)), -1, 1),
			"recurrence_delta": clampi(int(Dictionary(raw.get("continuity_effects", {})).get("recurrence_delta", 0)), -1, 1),
			"state_transition": {
				"from": str(Dictionary(Dictionary(raw.get("continuity_effects", {})).get("state_transition", {})).get("from", "")).strip_edges(),
				"to": str(Dictionary(Dictionary(raw.get("continuity_effects", {})).get("state_transition", {})).get("to", "")).strip_edges()
			},
			"persistence_transition": {
				"from": str(Dictionary(Dictionary(raw.get("continuity_effects", {})).get("persistence_transition", {})).get("from", "")).strip_edges(),
				"to": str(Dictionary(Dictionary(raw.get("continuity_effects", {})).get("persistence_transition", {})).get("to", "")).strip_edges()
			},
			"branch_pressure_family": str(Dictionary(raw.get("continuity_effects", {})).get("branch_pressure_family", "")).strip_edges(),
			"synthesis_cue": str(Dictionary(raw.get("continuity_effects", {})).get("synthesis_cue", "")).strip_edges(),
			"revive_candidate": str(Dictionary(raw.get("continuity_effects", {})).get("revive_candidate", "")).strip_edges(),
			"fairness_vetoed": bool(Dictionary(raw.get("continuity_effects", {})).get("fairness_vetoed", false))
		},
		"observation_signature": Dictionary(raw.get("observation_signature", {})).duplicate(true),
		"public_trace_lines": _slice_strings(_string_array(raw.get("public_trace_lines", [])), 3),
		"operator_trace_lines": _slice_strings(_string_array(raw.get("operator_trace_lines", [])), 4)
	}
	if current["evaluation_id"].is_empty():
		current["evaluation_id"] = _evaluation_id(current)
	return current

static func _apply_hypothesis_update(hypothesis: Dictionary, record: Dictionary) -> Dictionary:
	var current := hypothesis.duplicate(true)
	var continuity_effects: Dictionary = Dictionary(record.get("continuity_effects", {}))
	if not bool(current.get("foundational_flag", false)):
		var target_persistence := str(Dictionary(continuity_effects.get("persistence_transition", {})).get("to", current.get("persistence_state", "dormant"))).strip_edges()
		if _allowed_persistence_transition(str(current.get("persistence_state", "dormant")), target_persistence):
			current["persistence_state"] = target_persistence
			current["dormancy_state"] = target_persistence
	current["confidence"] = clampi(int(current.get("confidence", 2)) + int(continuity_effects.get("confidence_delta", 0)), 0, 4)
	current["recurrence_weight"] = clampi(int(current.get("recurrence_weight", 1)) + int(continuity_effects.get("recurrence_delta", 0)), 0, 4)
	current["supporting_evidence_ids"] = _merge_string_arrays(
		_string_array(current.get("supporting_evidence_ids", [])),
		_string_array(record.get("supporting_evidence", []))
	)
	current["contradicting_evidence_ids"] = _merge_string_arrays(
		_string_array(current.get("contradicting_evidence_ids", [])),
		_string_array(record.get("contradicting_evidence", []))
	)
	return current

static func _apply_experiment_update(experiment: Dictionary, record: Dictionary) -> Dictionary:
	var current := experiment.duplicate(true)
	var continuity_effects: Dictionary = Dictionary(record.get("continuity_effects", {}))
	var target_state := str(Dictionary(continuity_effects.get("state_transition", {})).get("to", current.get("state", "dormant"))).strip_edges()
	if _allowed_state_transition(str(current.get("state", "dormant")), target_state):
		current["state"] = target_state
	current["recurrence_weight"] = clampi(int(current.get("recurrence_weight", 1)) + int(continuity_effects.get("recurrence_delta", 0)), 0, 4)
	return current

static func _apply_meta_learning(meta_learning: Dictionary, record: Dictionary) -> Dictionary:
	var current := _normalize_meta_learning(meta_learning)
	var observation_signature: Dictionary = Dictionary(record.get("observation_signature", {}))
	var dimensions: Dictionary = Dictionary(record.get("dimensions", {}))
	var aggregate := _aggregate_dimension_score(dimensions)
	_increment_effectiveness(current, "topology_effectiveness", "topology_counts", str(observation_signature.get("topology_type", "")), aggregate)
	_increment_effectiveness(current, "horizon_effectiveness", "horizon_counts", str(observation_signature.get("time_horizon", "")), aggregate)
	_increment_effectiveness(current, "medium_effectiveness", "medium_counts", str(observation_signature.get("cultural_medium", "")), aggregate)
	_increment_effectiveness(current, "expression_mode_effectiveness", "expression_mode_counts", str(observation_signature.get("expression_mode", "")), aggregate)
	var noise_signatures := _string_array(current.get("noise_signatures", []))
	if int(dimensions.get("replay_distinctiveness", 0)) >= 2 and int(dimensions.get("hypothesis_yield", 0)) <= 1 and int(dimensions.get("cultural_richness", 0)) <= 1:
		noise_signatures = _push_front_limited(noise_signatures, "%s:novel_without_insight" % str(record.get("family_id", "")), 8)
	current["noise_signatures"] = noise_signatures
	return current

static func _derive_compiler_guidance(meta_learning: Dictionary, evaluation_records: Array, experiments: Dictionary) -> Dictionary:
	var current := _default_compiler_guidance()
	current["preferred_topologies"] = _ranked_effective_keys(meta_learning, "topology_effectiveness", "topology_counts", true)
	current["suppressed_topologies"] = _ranked_effective_keys(meta_learning, "topology_effectiveness", "topology_counts", false)
	current["preferred_horizons"] = _ranked_effective_keys(meta_learning, "horizon_effectiveness", "horizon_counts", true)
	current["suppressed_horizons"] = _ranked_effective_keys(meta_learning, "horizon_effectiveness", "horizon_counts", false)
	current["preferred_media"] = _ranked_effective_keys(meta_learning, "medium_effectiveness", "medium_counts", true)
	current["suppressed_media"] = _ranked_effective_keys(meta_learning, "medium_effectiveness", "medium_counts", false)
	for record_raw in _dict_array(evaluation_records).slice(0, 8):
		var record: Dictionary = Dictionary(record_raw)
		var continuity_effects: Dictionary = Dictionary(record.get("continuity_effects", {}))
		if _string_array(record.get("outcomes", [])).has("split_hypothesis"):
			current["branch_pressure_families"] = _merge_string_arrays(_string_array(current.get("branch_pressure_families", [])), [str(continuity_effects.get("branch_pressure_family", record.get("family_id", ""))).strip_edges()])
		if _string_array(record.get("outcomes", [])).has("synthesize_broader_theory"):
			current["synthesis_candidates"] = _merge_string_arrays(_string_array(current.get("synthesis_candidates", [])), [str(continuity_effects.get("synthesis_cue", record.get("experiment_id", ""))).strip_edges()])
		var revive_candidate := str(continuity_effects.get("revive_candidate", "")).strip_edges()
		if not revive_candidate.is_empty():
			current["revive_candidates"] = _merge_string_arrays(_string_array(current.get("revive_candidates", [])), [revive_candidate])
	current["branch_pressure_families"] = _filter_to_existing_families(_slice_strings(_string_array(current.get("branch_pressure_families", [])), MAX_GUIDANCE_VALUES), experiments)
	current["synthesis_candidates"] = _filter_to_existing_experiments(_slice_strings(_string_array(current.get("synthesis_candidates", [])), MAX_GUIDANCE_VALUES), experiments)
	current["revive_candidates"] = _filter_to_existing_experiments(_slice_strings(_string_array(current.get("revive_candidates", [])), MAX_GUIDANCE_VALUES), experiments)
	current["public_lines"] = _build_public_guidance_lines(current, meta_learning)
	current["operator_lines"] = _build_operator_guidance_lines(current, meta_learning)
	return normalize_compiler_guidance(current)

static func _build_dimensions(experiment: Dictionary, _hypothesis: Dictionary, run_record: Dictionary, diagnostics: Dictionary) -> Dictionary:
	var summary := Dictionary(run_record.get("expedition_constitution_summary", {}))
	var experiment_surface_lines := _string_array(summary.get("experiment_surface_lines", diagnostics.get("experiment_surface_lines", [])))
	var constitution_surface_lines := _string_array(Dictionary(summary.get("surface_summary", {})).get("lines", []))
	var story_density := int(diagnostics.get("story_density", 0))
	var retellability := int(diagnostics.get("retellability_score", 0))
	var legend_density := int(diagnostics.get("legend_density_score", 0))
	var revisit_score := int(diagnostics.get("revisit_score", 0))
	var recovery_score := int(diagnostics.get("recovery_score", 0))
	var confrontation_score := int(diagnostics.get("confrontation_score", 0))
	var narrative_pressure_resonance := int(diagnostics.get("narrative_pressure_resonance", 0))
	var consensus_risk := int(diagnostics.get("consensus_risk", 0))
	var anomaly_score := int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0))
	var symbolic_gestures := _string_array(diagnostics.get("symbolic_gestures", []))
	var run_shapes := _string_array(diagnostics.get("run_shapes", []))
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var story_tone := str(diagnostics.get("story_tone", "Quiet")).strip_edges()
	var interrupted := bool(run_record.get("interrupted", false))
	var hypothesis_yield := 0
	hypothesis_yield += 1 if not interrupted else 0
	hypothesis_yield += 1 if retellability >= 4 else 0
	hypothesis_yield += 1 if not experiment_surface_lines.is_empty() else 0
	hypothesis_yield += 1 if recovery_score + confrontation_score >= 2 or revisit_score >= 2 else 0
	var cultural_richness := 0
	cultural_richness += 1 if legend_density >= 6 else 0
	cultural_richness += 1 if story_density >= 8 else 0
	cultural_richness += 1 if symbolic_gestures.size() >= 1 else 0
	cultural_richness += 1 if not _string_array(diagnostics.get("narrative_pressure_lines", [])).is_empty() else 0
	var ontological_productivity := 0
	ontological_productivity += 1 if anomaly_score >= 2 else 0
	ontological_productivity += 1 if revisit_score >= 2 else 0
	ontological_productivity += 1 if _string_array(diagnostics.get("run_changing_moments", [])).size() >= 1 else 0
	ontological_productivity += 1 if str(experiment.get("ontology_condition", "")).strip_edges() in [
		"missing_verification_classes",
		"rediscovered_extinct_categories",
		"hybrid_lineage_emergence",
		"ritual_fragment_return"
	] else 0
	var narrative_resonance := 0
	narrative_resonance += 1 if retellability >= 3 else 0
	narrative_resonance += 1 if legend_density >= 8 else 0
	narrative_resonance += 1 if narrative_pressure_resonance >= 2 else 0
	narrative_resonance += 1 if story_tone in ["Charged", "Chaotic"] else 0
	var fairness_stability := 4
	fairness_stability -= mini(consensus_risk, 2)
	fairness_stability -= 1 if build_stability == "unstable" else 0
	fairness_stability -= 1 if interrupted else 0
	var readability := 0
	readability += 1 if not experiment_surface_lines.is_empty() else 0
	readability += 1 if not constitution_surface_lines.is_empty() else 0
	readability += 1 if story_tone in ["Quiet", "Charged"] else 0
	readability += 1 if build_stability == "stable" else 0
	var replay_distinctiveness := 0
	replay_distinctiveness += 1 if revisit_score >= 2 else 0
	replay_distinctiveness += 1 if run_shapes.size() >= 2 else 0
	replay_distinctiveness += 1 if retellability >= 3 else 0
	replay_distinctiveness += 1 if not experiment_surface_lines.is_empty() else 0
	var long_horizon_branch_value := 0
	long_horizon_branch_value += 1 if str(experiment.get("time_horizon", "")).strip_edges() in ["season", "era", "seasonal", "long_arc"] else 0
	long_horizon_branch_value += 1 if str(experiment.get("state", "")).strip_edges() in ["recurring", "dormant", "archival", "foundational"] else 0
	long_horizon_branch_value += 1 if legend_density >= 6 or revisit_score >= 2 else 0
	long_horizon_branch_value += 1 if not _string_array(experiment.get("branch_ids", [])).is_empty() or not _string_array(experiment.get("synthesis_sources", [])).is_empty() else 0
	return {
		"hypothesis_yield": clampi(hypothesis_yield, 0, 4),
		"cultural_richness": clampi(cultural_richness, 0, 4),
		"ontological_productivity": clampi(ontological_productivity, 0, 4),
		"narrative_resonance": clampi(narrative_resonance, 0, 4),
		"fairness_stability": clampi(fairness_stability, 0, 4),
		"readability": clampi(readability, 0, 4),
		"replay_distinctiveness": clampi(replay_distinctiveness, 0, 4),
		"long_horizon_branch_value": clampi(long_horizon_branch_value, 0, 4)
	}

static func _target_state_for_evaluation(experiment: Dictionary, dimensions: Dictionary) -> String:
	var current_state := str(experiment.get("state", "dormant")).strip_edges()
	if current_state == "foundational":
		return "foundational"
	var fairness_veto := int(dimensions.get("fairness_stability", 0)) <= 1
	var anti_noise := int(dimensions.get("replay_distinctiveness", 0)) >= 2 and int(dimensions.get("hypothesis_yield", 0)) <= 1 and int(dimensions.get("cultural_richness", 0)) <= 1
	if fairness_veto or anti_noise:
		return "dormant"
	if int(dimensions.get("hypothesis_yield", 0)) >= 3 and int(dimensions.get("readability", 0)) >= 3 and int(dimensions.get("long_horizon_branch_value", 0)) >= 4 and int(dimensions.get("fairness_stability", 0)) >= 3:
		return "foundational"
	if int(dimensions.get("hypothesis_yield", 0)) >= 3 and int(dimensions.get("readability", 0)) >= 2:
		if current_state in ["dormant", "archival"]:
			return "rare"
		return "recurring"
	if current_state == "archival":
		return "archival"
	return current_state

static func _target_persistence_for_evaluation(hypothesis: Dictionary, target_state: String) -> String:
	if bool(hypothesis.get("foundational_flag", false)):
		return "foundational"
	var current_state := str(hypothesis.get("persistence_state", hypothesis.get("dormancy_state", "dormant"))).strip_edges()
	return target_state if _allowed_persistence_transition(current_state, target_state) else current_state

static func _derive_outcomes(experiment: Dictionary, dimensions: Dictionary, target_state: String) -> Array[String]:
	var current_state := str(experiment.get("state", "dormant")).strip_edges()
	var outcomes: Array[String] = []
	var fairness_veto := int(dimensions.get("fairness_stability", 0)) <= 1
	var anti_noise := int(dimensions.get("replay_distinctiveness", 0)) >= 2 and int(dimensions.get("hypothesis_yield", 0)) <= 1 and int(dimensions.get("cultural_richness", 0)) <= 1
	if fairness_veto or anti_noise:
		outcomes.append("weaken_hypothesis")
	else:
		if int(dimensions.get("hypothesis_yield", 0)) >= 3:
			outcomes.append("strengthen_hypothesis")
		elif int(dimensions.get("hypothesis_yield", 0)) <= 1:
			outcomes.append("weaken_hypothesis")
		if int(dimensions.get("ontological_productivity", 0)) >= 3 and int(dimensions.get("long_horizon_branch_value", 0)) >= 3 and not _string_array(experiment.get("synthesis_sources", [])).is_empty():
			outcomes.append("synthesize_broader_theory")
		if int(dimensions.get("ontological_productivity", 0)) >= 3 and int(dimensions.get("readability", 0)) >= 2 and not _string_array(experiment.get("branch_ids", [])).is_empty():
			outcomes.append("split_hypothesis")
	match target_state:
		"recurring":
			if current_state != "recurring":
				outcomes.append("move_to_recurring")
		"rare":
			if current_state != "rare":
				outcomes.append("move_to_rare")
		"dormant":
			if current_state != "dormant" and current_state != "foundational":
				outcomes.append("move_to_dormant")
		"foundational":
			if current_state != "foundational":
				outcomes.append("elevate_foundational_inquiry")
		"archival":
			outcomes.append("preserve_archival_lineage")
	if current_state == "archival" and not outcomes.has("preserve_archival_lineage"):
		outcomes.append("preserve_archival_lineage")
	return _slice_strings(outcomes, 6)

static func _confidence_delta(outcomes: Array) -> int:
	if _string_array(outcomes).has("weaken_hypothesis"):
		return -1
	if _string_array(outcomes).has("strengthen_hypothesis") or _string_array(outcomes).has("elevate_foundational_inquiry"):
		return 1
	return 0

static func _recurrence_delta(experiment: Dictionary, target_state: String, outcomes: Array) -> int:
	if str(experiment.get("state", "dormant")).strip_edges() == "foundational":
		return 0
	if _string_array(outcomes).has("move_to_dormant"):
		return -1
	if target_state in ["recurring", "foundational"]:
		return 1
	if target_state == "rare" and str(experiment.get("state", "")).strip_edges() in ["dormant", "archival"]:
		return 1
	return 0

static func _supporting_evidence_ids(experiment: Dictionary, run_record: Dictionary, diagnostics: Dictionary, dimensions: Dictionary, outcomes: Array) -> Array[String]:
	var result: Array[String] = []
	result.append("seed_%d" % int(run_record.get("seed", 0)))
	var artifact_result := str(Dictionary(run_record.get("outcome_summary", {})).get("artifact_result", "")).strip_edges()
	if not artifact_result.is_empty():
		result.append("artifact_%s" % artifact_result)
	var story_tone := str(diagnostics.get("story_tone", "")).strip_edges().to_lower()
	if not story_tone.is_empty():
		result.append("tone_%s" % story_tone)
	if int(dimensions.get("hypothesis_yield", 0)) >= 3:
		result.append("yield_confirmed")
	if _string_array(outcomes).has("synthesize_broader_theory"):
		result.append("synthesis_pressure")
	return _slice_strings(result, 4)

static func _contradicting_evidence_ids(experiment: Dictionary, run_record: Dictionary, diagnostics: Dictionary, dimensions: Dictionary, outcomes: Array) -> Array[String]:
	var result: Array[String] = []
	if bool(run_record.get("interrupted", false)):
		result.append("interrupted_run")
	if int(dimensions.get("fairness_stability", 0)) <= 1:
		result.append("fairness_veto")
	if int(dimensions.get("readability", 0)) <= 1:
		result.append("low_readability")
	if _string_array(outcomes).has("weaken_hypothesis"):
		result.append("yield_failed")
	if str(experiment.get("state", "")).strip_edges() == "archival":
		result.append("archival_drag")
	return _slice_strings(result, 4)

static func _observation_signature(experiment: Dictionary, run_record: Dictionary, diagnostics: Dictionary) -> Dictionary:
	return {
		"story_tone": str(diagnostics.get("story_tone", "Quiet")).strip_edges(),
		"artifact_result": str(Dictionary(run_record.get("outcome_summary", {})).get("artifact_result", "")).strip_edges(),
		"local_role": str(run_record.get("local_role", "")).strip_edges(),
		"build_identity": str(diagnostics.get("build_identity", "")).strip_edges(),
		"topology_type": str(experiment.get("topology_type", "")).strip_edges(),
		"time_horizon": str(experiment.get("time_horizon", "")).strip_edges(),
		"cultural_medium": str(experiment.get("cultural_medium", "")).strip_edges(),
		"expression_mode": str(experiment.get("expression_mode", "")).strip_edges(),
		"retellability_score": int(diagnostics.get("retellability_score", 0)),
		"legend_density_score": int(diagnostics.get("legend_density_score", 0)),
		"revisit_score": int(diagnostics.get("revisit_score", 0)),
		"interrupted": bool(run_record.get("interrupted", false))
	}

static func _public_trace_lines(experiment: Dictionary, dimensions: Dictionary, outcomes: Array, target_state: String) -> Array[String]:
	var label := str(experiment.get("family_label", experiment.get("family_id", "experiment"))).strip_edges()
	var line := ""
	if _string_array(outcomes).has("elevate_foundational_inquiry"):
		line = "%s keeps producing legible long-horizon pressure." % label
	elif _string_array(outcomes).has("move_to_recurring"):
		line = "%s keeps returning with enough clarity to matter again." % label
	elif _string_array(outcomes).has("move_to_rare"):
		line = "%s is worth reopening when the world leans the right way." % label
	elif _string_array(outcomes).has("move_to_dormant"):
		line = "%s is producing more turbulence than insight right now." % label
	elif target_state == "archival":
		line = "%s remains useful as an archival pressure line." % label
	elif int(dimensions.get("hypothesis_yield", 0)) >= 3:
		line = "%s is still yielding usable continuity pressure." % label
	var result: Array[String] = []
	if not line.is_empty():
		result.append(line)
	return result

static func _operator_trace_lines(experiment: Dictionary, dimensions: Dictionary, outcomes: Array, target_state: String) -> Array[String]:
	return [
		"%s -> %s | yield=%d readability=%d fairness=%d branch=%d" % [
			str(experiment.get("experiment_id", "")),
			target_state,
			int(dimensions.get("hypothesis_yield", 0)),
			int(dimensions.get("readability", 0)),
			int(dimensions.get("fairness_stability", 0)),
			int(dimensions.get("long_horizon_branch_value", 0))
		],
		"Outcomes: %s" % ", ".join(_string_array(outcomes))
	]

static func _default_meta_learning() -> Dictionary:
	return {
		"topology_effectiveness": {},
		"topology_counts": {},
		"horizon_effectiveness": {},
		"horizon_counts": {},
		"medium_effectiveness": {},
		"medium_counts": {},
		"expression_mode_effectiveness": {},
		"expression_mode_counts": {},
		"noise_signatures": []
	}

static func _normalize_meta_learning(raw: Dictionary) -> Dictionary:
	var current := _default_meta_learning()
	for key in raw.keys():
		current[key] = raw[key]
	for key in [
		"topology_effectiveness",
		"topology_counts",
		"horizon_effectiveness",
		"horizon_counts",
		"medium_effectiveness",
		"medium_counts",
		"expression_mode_effectiveness",
		"expression_mode_counts"
	]:
		var normalized_map: Dictionary = {}
		for map_key in Dictionary(current.get(key, {})).keys():
			var text := str(map_key).strip_edges()
			if text.is_empty():
				continue
			normalized_map[text] = int(Dictionary(current.get(key, {})).get(map_key, 0))
		current[key] = normalized_map
	current["noise_signatures"] = _slice_strings(_string_array(current.get("noise_signatures", [])), 8)
	return current

static func _default_compiler_guidance() -> Dictionary:
	return {
		"preferred_topologies": [],
		"suppressed_topologies": [],
		"preferred_horizons": [],
		"suppressed_horizons": [],
		"preferred_media": [],
		"suppressed_media": [],
		"branch_pressure_families": [],
		"synthesis_candidates": [],
		"revive_candidates": [],
		"public_lines": [],
		"operator_lines": []
	}

static func _aggregate_dimension_score(dimensions: Dictionary) -> int:
	var total := 0
	var count := 0
	for value in Dictionary(dimensions).values():
		total += int(value)
		count += 1
	return clampi(int(round(float(total) / float(maxi(count, 1)))), 0, 4)

static func _increment_effectiveness(meta_learning: Dictionary, score_key: String, count_key: String, token: String, value: int) -> void:
	var text := token.strip_edges()
	if text.is_empty():
		return
	var scores := Dictionary(meta_learning.get(score_key, {})).duplicate(true)
	var counts := Dictionary(meta_learning.get(count_key, {})).duplicate(true)
	scores[text] = int(scores.get(text, 0)) + value
	counts[text] = int(counts.get(text, 0)) + 1
	meta_learning[score_key] = scores
	meta_learning[count_key] = counts

static func _ranked_effective_keys(meta_learning: Dictionary, score_key: String, count_key: String, prefer_high: bool) -> Array[String]:
	var scored: Array[Dictionary] = []
	var scores := Dictionary(meta_learning.get(score_key, {}))
	var counts := Dictionary(meta_learning.get(count_key, {}))
	for token_variant in scores.keys():
		var token := str(token_variant).strip_edges()
		var count := int(counts.get(token_variant, counts.get(token, 0)))
		if token.is_empty() or count <= 0:
			continue
		var average := float(int(scores.get(token_variant, scores.get(token, 0)))) / float(count)
		if prefer_high and average < 2.0:
			continue
		if not prefer_high and average > 1.0:
			continue
		scored.append({"token": token, "average": average})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if is_equal_approx(float(a.get("average", 0.0)), float(b.get("average", 0.0))):
			return str(a.get("token", "")) < str(b.get("token", ""))
		return float(a.get("average", 0.0)) > float(b.get("average", 0.0)) if prefer_high else float(a.get("average", 0.0)) < float(b.get("average", 0.0))
	)
	var result: Array[String] = []
	for entry_raw in scored.slice(0, MAX_GUIDANCE_VALUES):
		result.append(str(Dictionary(entry_raw).get("token", "")))
	return result

static func _build_public_guidance_lines(guidance: Dictionary, meta_learning: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var preferred_topologies := _string_array(guidance.get("preferred_topologies", []))
	var preferred_horizons := _string_array(guidance.get("preferred_horizons", []))
	var preferred_media := _string_array(guidance.get("preferred_media", []))
	if not preferred_topologies.is_empty() and not preferred_horizons.is_empty():
		lines.append("%s patterns keep paying off best over %s horizons." % [
			preferred_topologies[0].replace("_", " "),
			preferred_horizons[0].replace("_", " ")
		])
	if not preferred_media.is_empty():
		lines.append("%s is currently the clearest place to expose these pressures." % preferred_media[0].replace("_", " "))
	if not _string_array(guidance.get("revive_candidates", [])).is_empty():
		lines.append("A dormant line looks worth revisiting when the world turns that way again.")
	if lines.is_empty() and not _string_array(meta_learning.get("noise_signatures", [])).is_empty():
		lines.append("Recent novelty has been noisier than useful.")
	return _slice_strings(lines, 3)

static func _build_operator_guidance_lines(guidance: Dictionary, meta_learning: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var preferred_topologies := _string_array(guidance.get("preferred_topologies", []))
	var suppressed_topologies := _string_array(guidance.get("suppressed_topologies", []))
	var preferred_horizons := _string_array(guidance.get("preferred_horizons", []))
	var preferred_media := _string_array(guidance.get("preferred_media", []))
	if not preferred_topologies.is_empty() or not preferred_horizons.is_empty() or not preferred_media.is_empty():
		lines.append("Prefer topology=%s horizon=%s medium=%s" % [
			_first_string(preferred_topologies, "-"),
			_first_string(preferred_horizons, "-"),
			_first_string(preferred_media, "-")
		])
	if not suppressed_topologies.is_empty():
		lines.append("Suppress topology=%s until yield improves" % suppressed_topologies[0])
	if not _string_array(guidance.get("branch_pressure_families", [])).is_empty():
		lines.append("Branch pressure families: %s" % ", ".join(_string_array(guidance.get("branch_pressure_families", []))))
	if not _string_array(guidance.get("synthesis_candidates", [])).is_empty():
		lines.append("Synthesis candidates: %s" % ", ".join(_string_array(guidance.get("synthesis_candidates", []))))
	if not _string_array(guidance.get("revive_candidates", [])).is_empty():
		lines.append("Revive candidates: %s" % ", ".join(_string_array(guidance.get("revive_candidates", []))))
	if not _string_array(meta_learning.get("noise_signatures", [])).is_empty():
		lines.append("Noise signatures: %s" % ", ".join(_string_array(meta_learning.get("noise_signatures", [])).slice(0, 2)))
	return _slice_strings(lines, 4)

static func _trace_lines_from_records(records: Array[Dictionary], field: String) -> Array[String]:
	var result: Array[String] = []
	for record_raw in records:
		result = _merge_string_arrays(result, _string_array(Dictionary(record_raw).get(field, [])))
	return result

static func _manifested_experiment_ids(experiments: Dictionary, run_record: Dictionary, diagnostics: Dictionary) -> Array[String]:
	var labels := _merge_string_arrays(
		_string_array(Dictionary(run_record.get("expedition_constitution_summary", {})).get("experiment_families", [])),
		_string_array(diagnostics.get("experiment_families", []))
	)
	var surface_lines := _merge_string_arrays(
		_string_array(Dictionary(run_record.get("expedition_constitution_summary", {})).get("experiment_surface_lines", [])),
		_string_array(diagnostics.get("experiment_surface_lines", []))
	)
	var ids: Array[String] = []
	for experiment_id in _sorted_strings(experiments.keys()):
		var experiment: Dictionary = Dictionary(experiments.get(experiment_id, {}))
		var family_label := str(experiment.get("family_label", experiment.get("family_id", ""))).strip_edges()
		var family_id := str(experiment.get("family_id", "")).strip_edges()
		var public_lines := _string_array(experiment.get("public_lines", []))
		if labels.has(family_label) or labels.has(family_id):
			ids.append(str(experiment.get("experiment_id", experiment_id)).strip_edges())
			continue
		for public_line in public_lines:
			if surface_lines.has(public_line):
				ids.append(str(experiment.get("experiment_id", experiment_id)).strip_edges())
				break
	return _sorted_strings(ids)

static func _allowed_state_transition(from_state: String, to_state: String) -> bool:
	if from_state == to_state:
		return true
	match from_state:
		"foundational":
			return to_state == "foundational"
		"active":
			return to_state in ["recurring", "rare", "dormant", "foundational"]
		"recurring":
			return to_state in ["recurring", "rare", "dormant", "foundational"]
		"rare":
			return to_state in ["recurring", "rare", "dormant", "archival", "foundational"]
		"dormant":
			return to_state in ["dormant", "rare", "recurring", "archival"]
		"archival":
			return to_state in ["archival", "rare", "dormant"]
		_:
			return false

static func _allowed_persistence_transition(from_state: String, to_state: String) -> bool:
	return _allowed_state_transition(from_state, to_state)

static func _revived_state(from_state: String, to_state: String) -> bool:
	return from_state in ["dormant", "archival"] and to_state in ["rare", "recurring"]

static func _evaluation_id(record: Dictionary) -> String:
	var canonical := {
		"run_seed": int(record.get("run_seed", 0)),
		"hypothesis_id": str(record.get("hypothesis_id", "")).strip_edges(),
		"experiment_id": str(record.get("experiment_id", "")).strip_edges(),
		"family_id": str(record.get("family_id", "")).strip_edges(),
		"dimensions": Dictionary(record.get("dimensions", {})).duplicate(true),
		"outcomes": _string_array(record.get("outcomes", [])),
		"observation_signature": Dictionary(record.get("observation_signature", {})).duplicate(true)
	}
	return "eval_%s" % JSON.stringify(canonical).md5_text().substr(0, 16)

static func _filter_to_existing_experiments(ids: Array[String], experiments: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for experiment_id in ids:
		if _registry_has(experiments, experiment_id, "experiment_id"):
			result.append(experiment_id)
	return result

static func _filter_to_existing_families(ids: Array[String], experiments: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var family_ids: Array[String] = []
	for experiment_raw in experiments.values():
		family_ids = _merge_string_arrays(family_ids, [str(Dictionary(experiment_raw).get("family_id", "")).strip_edges()])
	for family_id in ids:
		if family_ids.has(family_id):
			result.append(family_id)
	return result

static func _registry_has(registry: Dictionary, token: String, key_field: String) -> bool:
	var text := token.strip_edges()
	if text.is_empty():
		return false
	if registry.has(text):
		return true
	for entry_raw in registry.values():
		if str(Dictionary(entry_raw).get(key_field, "")).strip_edges() == text:
			return true
	return false

static func _contains_runtime_key(value: Variant) -> bool:
	for banned in RUNTIME_FORBIDDEN_FIELDS:
		if _contains_key(value, banned):
			return true
	for banned in _string_array(SCHEMA_REGISTRY_SCRIPT.evaluation_schema().get("forbidden_runtime_fields", [])):
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

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _merge_string_arrays(base: Array[String], addition: Array[String]) -> Array[String]:
	var result := base.duplicate()
	for value in addition:
		var text := str(value).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _push_front_limited(existing: Array[String], value: String, limit: int) -> Array[String]:
	var result := existing.duplicate()
	var text := value.strip_edges()
	if text.is_empty():
		return result
	result.erase(text)
	result.push_front(text)
	return result.slice(0, limit)

static func _slice_strings(values: Array[String], limit: int) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
		if result.size() >= limit:
			break
	return result

static func _first_string(values: Array[String], fallback: String) -> String:
	return values[0] if not values.is_empty() else fallback

static func _sorted_strings(values: Variant) -> Array[String]:
	var result := _string_array(values)
	result.sort()
	return result
