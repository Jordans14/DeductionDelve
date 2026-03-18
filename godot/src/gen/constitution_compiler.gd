class_name ConstitutionCompiler
extends RefCounted

const SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")
const ONTOLOGY_ENGINE_SCRIPT = preload("res://src/gen/ontology_engine.gd")
const NARRATIVE_PRESSURE_ENGINE_SCRIPT = preload("res://src/gen/narrative_pressure_engine.gd")
const DELVEMIND_EXPERIMENT_ENGINE_SCRIPT = preload("res://src/product/delvemind_experiment_engine.gd")
const GOVERNANCE_SERVICE_SCRIPT = preload("res://src/product/governance_service.gd")
const CIVILIZATION_STATE_SERVICE_SCRIPT = preload("res://src/product/civilization_state_service.gd")
const CONTRADICTION_ENGINE_SCRIPT = preload("res://src/product/contradiction_engine.gd")
const THEORY_ENGINE_SCRIPT = preload("res://src/delve/theory_engine.gd")
const FAIRNESS_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/fairness_constitution.gd")
const LOGIC_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/logic_constitution.gd")
const LEGIBILITY_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/legibility_constitution.gd")
const DEDUCTION_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/deduction_constitution.gd")
const COHERENCE_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/coherence_constitution.gd")
const EPISTEMIC_CONSTITUTION_SCRIPT = preload("res://src/delve/constitution/epistemic_constitution.gd")
const CONTROL_SURFACE_REGISTRY_SCRIPT = preload("res://src/delve/control_surface_registry.gd")

static func compile(
	seed_value: int,
	room_count: int,
	world_model: Dictionary,
	doctrine: Dictionary,
	surface_summary: Dictionary,
	public_doctrine: Dictionary,
	run_identity: Dictionary,
	generation_surface: Dictionary,
	policy: Dictionary = {},
	simulation: Dictionary = {},
	validation_violations: Array = [],
	counter: Dictionary = {}
) -> Dictionary:
	var doctrine_family: Dictionary = SCHEMA_REGISTRY_SCRIPT.doctrine_family(str(doctrine.get("id", "")))
	var compiled_doctrine := doctrine.duplicate(true)
	var compiled_policy := CONTROL_SURFACE_REGISTRY_SCRIPT.clamp_policy(policy)
	var inheritance: Dictionary = Dictionary(doctrine_family.get("inheritance", {})).duplicate(true)
	if not doctrine_family.is_empty():
		compiled_doctrine["lineage_id"] = str(doctrine_family.get("lineage_id", ""))
		compiled_doctrine["niches"] = _string_array(doctrine_family.get("niches", []))
		compiled_doctrine["protocol_affinities"] = _string_array(doctrine_family.get("protocol_affinities", []))
	var compiled_generation_surface := generation_surface.duplicate(true)
	compiled_generation_surface["pressure_verbs"] = _merge_arrays(Array(compiled_generation_surface.get("pressure_verbs", [])), Array(inheritance.get("pressure_verbs", [])))
	compiled_generation_surface["symbolic_motifs"] = _merge_arrays(Array(compiled_generation_surface.get("symbolic_motifs", [])), Array(inheritance.get("symbolic_motifs", [])))
	compiled_generation_surface["item_ecology_bias"] = _merge_axis_text(str(compiled_generation_surface.get("item_ecology_bias", "")), str(inheritance.get("item_ecology_bias", "")))
	compiled_generation_surface["group_tension_bias"] = _merge_axis_text(str(compiled_generation_surface.get("group_tension_bias", "")), str(inheritance.get("group_tension_bias", "")))
	compiled_generation_surface["archive_tone"] = _preferred_scalar(str(compiled_generation_surface.get("archive_tone", "")), str(inheritance.get("archive_tone", "")))
	compiled_generation_surface["convergence_axis"] = _preferred_scalar(str(compiled_generation_surface.get("convergence_axis", "")), str(inheritance.get("convergence_axis", "")))
	var compiler_public_summary := _build_public_summary(public_doctrine, compiled_generation_surface, surface_summary, run_identity)
	var ontology_snapshot := ONTOLOGY_ENGINE_SCRIPT.build_snapshot(seed_value, world_model, compiled_doctrine, compiler_public_summary, compiled_generation_surface)
	var ontology_routing := ONTOLOGY_ENGINE_SCRIPT.build_generation_routing(ontology_snapshot, compiled_generation_surface, doctrine_family)
	var experimental_ontology_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.compile_state(
		Dictionary(world_model.get("experiment_state", {})),
		world_model,
		compiled_doctrine,
		compiler_public_summary,
		compiled_generation_surface,
		ontology_snapshot,
		ontology_routing
	)
	ontology_routing = _apply_experiment_ontology_weighting(ontology_routing, experimental_ontology_state)
	compiled_generation_surface["ontology_routing"] = ontology_routing.duplicate(true)
	compiled_generation_surface = _apply_experiment_generation_weighting(compiled_generation_surface, experimental_ontology_state)
	compiler_public_summary = _apply_experiment_public_summary(compiler_public_summary, experimental_ontology_state)
	var narrative_pressure_state := NARRATIVE_PRESSURE_ENGINE_SCRIPT.build_state(
		world_model,
		compiled_doctrine,
		compiler_public_summary,
		compiled_generation_surface,
		ontology_snapshot,
		doctrine_family,
		simulation,
		experimental_ontology_state
	)
	compiled_generation_surface = _apply_narrative_pressure_generation_weighting(compiled_generation_surface, narrative_pressure_state)
	compiler_public_summary = _apply_narrative_pressure_public_summary(compiler_public_summary, narrative_pressure_state)
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.normalize(Dictionary(world_model.get("governance_state", {})))
	var theory_surface := THEORY_ENGINE_SCRIPT.build_surface(experimental_ontology_state, world_model, governance_state)
	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(Dictionary(world_model.get("world_memory_snapshot", {})))
	var cognitive_field_state := _build_cognitive_field_state(world_model, compiler_public_summary, theory_surface)
	var mind_projections := _build_mind_projections(compiler_public_summary, cognitive_field_state)
	var contradiction_packet := CONTRADICTION_ENGINE_SCRIPT.build_contradiction_records(
		theory_surface,
		Dictionary(world_model.get("cookbook_state_snapshot", {})),
		Dictionary(world_model.get("world_memory_snapshot", {}))
	)
	var activation_state := GOVERNANCE_SERVICE_SCRIPT.normalize_activation_state(Dictionary(governance_state.get("activation_state", {})))
	var review_surface := GOVERNANCE_SERVICE_SCRIPT.build_review_surface(governance_state)
	review_surface["lines"] = _merge_arrays(
		Array(review_surface.get("lines", [])),
		Array(Dictionary(contradiction_packet.get("anti_bottleneck_report", {})).get("summary_lines", []))
	).slice(0, 4)
	var explanation_packet := GOVERNANCE_SERVICE_SCRIPT.build_explanation_packet(
		{
			"artifact_type": "constitution_compile_metadata",
			"constitution_id": "pending_%s" % str(seed_value)
		},
		[
			str(compiler_public_summary.get("world_goal", "")).strip_edges(),
			_first_string(Array(theory_surface.get("lines", [])), ""),
			_first_string(Array(civilization_surface.get("lines", [])), "")
		],
		Array(review_surface.get("lines", [])),
		["movement", "burden", "witness", "route_choice", "artifact_custody", "extraction", "return"]
	)
	var lineage_registry := _build_compile_lineage_registry(experimental_ontology_state, theory_surface)
	var doctrine_variant_id := _build_doctrine_variant_id(compiled_doctrine, compiled_generation_surface)
	var compile_bound_failures := _compile_bound_failures(world_model, compiled_doctrine, compiled_policy, simulation, validation_violations, counter)
	var topology_profile := _build_topology_profile(compiled_generation_surface, ontology_routing)
	var chamber_grammar_profile := _build_chamber_grammar_profile(compiled_generation_surface, ontology_routing)
	var route_profile := _build_route_profile(compiled_generation_surface, ontology_routing)
	var item_ecology_profile := _build_item_ecology_profile(compiled_generation_surface, ontology_routing, compiler_public_summary)
	var pressure_ecology_profile := _build_pressure_ecology_profile(compiled_generation_surface, ontology_routing, simulation)
	var information_doctrine_profile := _build_information_doctrine_profile(compiled_generation_surface, ontology_routing, compiler_public_summary, compiled_policy)
	var pacing_profile := _build_pacing_profile(compiled_generation_surface, compiler_public_summary)
	var custody_profile := _build_custody_profile(compiled_generation_surface, ontology_routing, compiler_public_summary)
	var mutation_permissions := _build_mutation_permissions(compiled_generation_surface, ontology_routing, compiled_policy)
	var fairness_bounds := _build_fairness_bounds(compiled_policy, simulation, compile_bound_failures)
	var compiler_trace := {
		"compiler_schema": "constitution_compiler_v1",
		"seed": seed_value,
		"room_count": room_count,
		"doctrine_family": str(compiled_doctrine.get("id", "")),
		"doctrine_variant_id": doctrine_variant_id,
		"inherited_fields": {
			"pressure_verbs": _string_array(inheritance.get("pressure_verbs", [])),
			"symbolic_motifs": _string_array(inheritance.get("symbolic_motifs", [])),
			"item_ecology_bias": str(inheritance.get("item_ecology_bias", "")),
			"group_tension_bias": str(inheritance.get("group_tension_bias", "")),
			"archive_tone": str(inheritance.get("archive_tone", "")),
			"convergence_axis": str(inheritance.get("convergence_axis", ""))
		},
		"dominant_lineages": Array(Dictionary(ontology_routing).get("dominant_lineages", [])).duplicate(true),
		"validation_failures": _merge_arrays(Array(Dictionary(ontology_snapshot).get("validation_failures", [])), compile_bound_failures),
		"source_summary": {
			"pressure_line": str(public_doctrine.get("pressure_line", "")),
			"world_goal": str(public_doctrine.get("world_goal", "")),
			"archive_tone": str(compiled_generation_surface.get("archive_tone", "")),
			"convergence_axis": str(compiled_generation_surface.get("convergence_axis", ""))
		},
		"narrative_pressure": {
			"pressure_family": str(narrative_pressure_state.get("pressure_family", "")),
			"dominant_tensions": _string_array(narrative_pressure_state.get("dominant_tensions", [])),
			"momentum": int(narrative_pressure_state.get("momentum", 0)),
			"resonance": int(narrative_pressure_state.get("resonance", 0)),
			"cascade_risk": int(narrative_pressure_state.get("cascade_risk", 0))
		},
		"experimental_ontology": {
			"dominant_families": _string_array(experimental_ontology_state.get("dominant_families", [])),
			"live_experiment_ids": _string_array(experimental_ontology_state.get("live_experiment_ids", [])),
			"expression_modes": _string_array(Dictionary(experimental_ontology_state.get("public_surface", {})).get("expression_modes", [])),
			"compile_targets": _string_array(Dictionary(experimental_ontology_state.get("compile_outputs", {})).get("compile_targets", [])),
			"lineage_state_bands": Dictionary(Dictionary(experimental_ontology_state.get("lineage_index", {})).get("state_bands", {})).duplicate(true),
			"learning_guidance": {
				"preferred_topologies": _string_array(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("preferred_topologies", [])),
				"preferred_horizons": _string_array(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("preferred_horizons", [])),
				"preferred_media": _string_array(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("preferred_media", [])),
				"branch_pressure_families": _string_array(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("branch_pressure_families", [])),
				"synthesis_candidates": _string_array(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("synthesis_candidates", [])),
				"revive_candidates": _string_array(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("revive_candidates", [])),
				"accepted_evaluation_ids": _string_array(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("accepted_evaluation_ids", [])),
				"evaluation_count": int(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("evaluation_count", 0)),
				"bias_basis": Dictionary(Dictionary(experimental_ontology_state.get("learning_guidance", {})).get("bias_basis", {})).duplicate(true)
			},
			"learning_guidance_bias_trace": Dictionary(Dictionary(experimental_ontology_state.get("compiler_trace", {})).get("learning_guidance_bias_trace", {})).duplicate(true)
		}
	}
	var compile_metadata := {
		"artifact_type": "constitution_compile_metadata",
		"compiler_schema": "constitution_compiler_v1",
		"constitution_schema": str(SCHEMA_REGISTRY_SCRIPT.constitution_schema().get("schema_name", "ExpeditionConstitution")),
		"constitution_schema_version": int(SCHEMA_REGISTRY_SCRIPT.constitution_schema().get("schema_version", 1)),
		"ontology_schema": str(SCHEMA_REGISTRY_SCRIPT.ontology_schema().get("schema_name", "OntologySnapshot")),
		"ontology_schema_version": int(SCHEMA_REGISTRY_SCRIPT.ontology_schema().get("schema_version", 1)),
		"narrative_pressure_schema": str(SCHEMA_REGISTRY_SCRIPT.narrative_pressure_schema().get("schema_name", "NarrativePressureState")),
		"narrative_pressure_schema_version": int(SCHEMA_REGISTRY_SCRIPT.narrative_pressure_schema().get("schema_version", 1)),
		"experiment_schema": str(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("schema_name", "DelveMindExperiment")),
		"experiment_schema_version": int(SCHEMA_REGISTRY_SCRIPT.experiment_schema().get("schema_version", 1)),
		"evaluation_schema": str(SCHEMA_REGISTRY_SCRIPT.evaluation_schema().get("schema_name", "DelveMindEvaluation")),
		"evaluation_schema_version": int(SCHEMA_REGISTRY_SCRIPT.evaluation_schema().get("schema_version", 1)),
		"lineage_schema": str(SCHEMA_REGISTRY_SCRIPT.lineage_schema().get("schema_name", "Lineage")),
		"lineage_schema_version": int(SCHEMA_REGISTRY_SCRIPT.lineage_schema().get("schema_version", 1)),
		"inquiry_schema": str(SCHEMA_REGISTRY_SCRIPT.inquiry_schema().get("schema_name", "DelveMindInquiry")),
		"inquiry_schema_version": int(SCHEMA_REGISTRY_SCRIPT.inquiry_schema().get("schema_version", 1)),
		"cognitive_field_schema": str(SCHEMA_REGISTRY_SCRIPT.cognitive_field_schema().get("schema_name", "CognitiveField")),
		"cognitive_field_schema_version": int(SCHEMA_REGISTRY_SCRIPT.cognitive_field_schema().get("schema_version", 1)),
		"civilization_schema": str(SCHEMA_REGISTRY_SCRIPT.civilization_schema().get("schema_name", "CivilizationState")),
		"civilization_schema_version": int(SCHEMA_REGISTRY_SCRIPT.civilization_schema().get("schema_version", 1)),
		"governance_schema": str(SCHEMA_REGISTRY_SCRIPT.governance_schema().get("schema_name", "GovernanceState")),
		"governance_schema_version": int(SCHEMA_REGISTRY_SCRIPT.governance_schema().get("schema_version", 1)),
		"doctrine_family": str(compiled_doctrine.get("id", "")),
		"doctrine_variant_id": doctrine_variant_id,
		"lineage_id": str(compiled_doctrine.get("lineage_id", doctrine_family.get("lineage_id", ""))),
		"narrative_pressure_family": str(narrative_pressure_state.get("pressure_family", "")),
		"narrative_pressure_allowed_outputs": _string_array(narrative_pressure_state.get("allowed_outputs", [])),
		"experiment_families": _string_array(experimental_ontology_state.get("dominant_families", [])),
		"experiment_expression_modes": _string_array(Dictionary(experimental_ontology_state.get("public_surface", {})).get("expression_modes", [])),
		"experiment_compile_targets": _string_array(Dictionary(experimental_ontology_state.get("compile_outputs", {})).get("compile_targets", [])),
		"experiment_learning_guidance": Dictionary(experimental_ontology_state.get("learning_guidance", {})).duplicate(true),
		"experiment_learning_bias_trace": Dictionary(Dictionary(experimental_ontology_state.get("compiler_trace", {})).get("learning_guidance_bias_trace", {})).duplicate(true),
		"dominant_lineages": Array(ontology_routing.get("dominant_lineages", [])).duplicate(true),
		"required_generation_surface_keys": Array(SCHEMA_REGISTRY_SCRIPT.constitution_schema().get("required_generation_surface_keys", [])).duplicate(true),
		"required_symbolic_fields": Array(SCHEMA_REGISTRY_SCRIPT.constitution_schema().get("required_symbolic_fields", [])).duplicate(true),
		"validation_failures": Array(compiler_trace.get("validation_failures", [])).duplicate(true),
		"fairness_bound_failures": compile_bound_failures.duplicate(true),
		"pressure_validation_failures": Array(narrative_pressure_state.get("validation_failures", [])).duplicate(true),
		"experiment_validation_failures": Array(experimental_ontology_state.get("validation_failures", [])).duplicate(true)
	}
	var bundle := {
		"doctrine": compiled_doctrine,
		"generation_surface": compiled_generation_surface,
		"ontology_snapshot": ontology_snapshot,
		"narrative_pressure_state": narrative_pressure_state,
		"experimental_ontology_state": experimental_ontology_state,
		"doctrine_inheritance": inheritance,
		"compiler_trace": compiler_trace,
		"compile_metadata": compile_metadata,
		"doctrine_family_id": str(compiled_doctrine.get("id", "")),
		"doctrine_variant_id": doctrine_variant_id,
		"generation_seed": seed_value,
		"topology_profile": topology_profile,
		"chamber_grammar_profile": chamber_grammar_profile,
		"route_profile": route_profile,
		"item_ecology_profile": item_ecology_profile,
		"pressure_ecology_profile": pressure_ecology_profile,
		"information_doctrine_profile": information_doctrine_profile,
		"pacing_profile": pacing_profile,
		"custody_profile": custody_profile,
		"mutation_permissions": mutation_permissions,
		"symbolic_motifs": Array(compiled_generation_surface.get("symbolic_motifs", [])).duplicate(true),
		"fairness_bounds": fairness_bounds,
		"lineage_registry": lineage_registry,
		"civilization_surface": civilization_surface,
		"cognitive_field_state": cognitive_field_state,
		"mind_projections": mind_projections,
		"theory_surface": theory_surface,
		"activation_state": activation_state,
		"explanation_packet": explanation_packet,
		"review_surface": review_surface
	}
	var validation_failures := validate_compile_output(bundle)
	compiler_trace["validation_failures"] = _merge_arrays(Array(compiler_trace.get("validation_failures", [])), validation_failures)
	compile_metadata["validation_failures"] = _merge_arrays(Array(compile_metadata.get("validation_failures", [])), validation_failures)
	bundle["compiler_trace"] = compiler_trace
	bundle["compile_metadata"] = compile_metadata
	return bundle

static func validate_compile_output(bundle: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	var generation_surface: Dictionary = Dictionary(bundle.get("generation_surface", {}))
	for key in _string_array(SCHEMA_REGISTRY_SCRIPT.constitution_schema().get("required_generation_surface_keys", [])):
		if not generation_surface.has(key):
			failures.append("compiled generation surface missing %s" % key)
	var ontology_snapshot: Dictionary = Dictionary(bundle.get("ontology_snapshot", {}))
	failures.append_array(Array(ontology_snapshot.get("validation_failures", [])))
	var compiler_trace: Dictionary = Dictionary(bundle.get("compiler_trace", {}))
	if str(compiler_trace.get("compiler_schema", "")).strip_edges().is_empty():
		failures.append("compiler trace missing compiler_schema")
	var compile_metadata: Dictionary = Dictionary(bundle.get("compile_metadata", {}))
	if str(compile_metadata.get("compiler_schema", "")).strip_edges().is_empty():
		failures.append("compile metadata missing compiler_schema")
	if str(compile_metadata.get("ontology_schema", "")).strip_edges().is_empty():
		failures.append("compile metadata missing ontology_schema")
	if str(compile_metadata.get("narrative_pressure_schema", "")).strip_edges().is_empty():
		failures.append("compile metadata missing narrative_pressure_schema")
	if str(compile_metadata.get("experiment_schema", "")).strip_edges().is_empty():
		failures.append("compile metadata missing experiment_schema")
	if str(compile_metadata.get("evaluation_schema", "")).strip_edges().is_empty():
		failures.append("compile metadata missing evaluation_schema")
	if not compile_metadata.has("experiment_learning_bias_trace"):
		failures.append("compile metadata missing experiment_learning_bias_trace")
	for field in _string_array(SCHEMA_REGISTRY_SCRIPT.constitution_schema().get("required_symbolic_fields", [])):
		if field == "constitution_id" or field == "continuity_hooks":
			continue
		if not bundle.has(field):
			failures.append("compile output missing symbolic field %s" % field)
	var narrative_pressure_state: Dictionary = Dictionary(bundle.get("narrative_pressure_state", {}))
	for field in _string_array(SCHEMA_REGISTRY_SCRIPT.narrative_pressure_schema().get("required_fields", [])):
		if not narrative_pressure_state.has(field):
			failures.append("compile output narrative_pressure_state missing %s" % field)
	failures.append_array(_string_array(narrative_pressure_state.get("validation_failures", [])))
	if not Array(compile_metadata.get("pressure_validation_failures", [])).is_empty():
		failures.append_array(_string_array(compile_metadata.get("pressure_validation_failures", [])))
	var experimental_ontology_state: Dictionary = Dictionary(bundle.get("experimental_ontology_state", {}))
	var experiment_failures := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.validate_compile_state(experimental_ontology_state)
	if not experiment_failures.is_empty():
		failures.append_array(experiment_failures)
	var experimental_trace: Dictionary = Dictionary(Dictionary(compiler_trace.get("experimental_ontology", {})).get("learning_guidance_bias_trace", {}))
	if experimental_trace.is_empty():
		failures.append("compiler trace missing experimental_ontology learning_guidance_bias_trace")
	if not Array(compile_metadata.get("experiment_validation_failures", [])).is_empty():
		failures.append_array(_string_array(compile_metadata.get("experiment_validation_failures", [])))
	var fairness_bounds: Dictionary = Dictionary(bundle.get("fairness_bounds", {}))
	if not fairness_bounds.has("runtime_non_mutation_required") or not bool(fairness_bounds.get("runtime_non_mutation_required", false)):
		failures.append("fairness bounds must preserve runtime_non_mutation_required")
	if not fairness_bounds.has("no_hidden_targeting_required") or not bool(fairness_bounds.get("no_hidden_targeting_required", false)):
		failures.append("fairness bounds must preserve no_hidden_targeting_required")
	if not Array(compile_metadata.get("fairness_bound_failures", [])).is_empty():
		failures.append_array(_string_array(compile_metadata.get("fairness_bound_failures", [])))
	for banned in ["peer_ids", "role_payload", "runtime_state", "event_log"]:
		if generation_surface.has(banned) or ontology_snapshot.has(banned) or compiler_trace.has(banned) or compile_metadata.has(banned) or _contains_key(experimental_ontology_state, banned):
			failures.append("compile output must not expose runtime-only field %s" % banned)
		if Dictionary(bundle.get("fairness_bounds", {})).has(banned):
			failures.append("fairness bounds must not expose runtime-only field %s" % banned)
	for banned in _string_array(SCHEMA_REGISTRY_SCRIPT.narrative_pressure_schema().get("forbidden_runtime_fields", [])):
		if _contains_key(narrative_pressure_state, banned):
			failures.append("narrative pressure state must not expose runtime-only field %s" % banned)
	return failures

static func _build_cognitive_field_state(world_model: Dictionary, public_summary: Dictionary, theory_surface: Dictionary) -> Dictionary:
	var dominant_forces := _string_array(public_summary.get("dominant_forces", []))
	var dominant_domains := _string_array(public_summary.get("dominant_domains", []))
	var theory_ids := _string_array(theory_surface.get("theory_ids", []))
	return {
		"schema_name": "CognitiveFieldState",
		"schema_version": 1,
		"field_vectors": {
			"judgment": theory_ids.size(),
			"instability": Array(theory_surface.get("statuses", [])).size() - theory_ids.size(),
			"memory": dominant_forces.size(),
			"structure": dominant_domains.size(),
			"containment": 1 if str(public_summary.get("archive_tone", "")).strip_edges() == "memory custody" else 0,
			"reconciliation": 1 if str(public_summary.get("convergence_axis", "")).strip_edges().find("conver") != -1 else 0,
			"mourning": 1 if str(public_summary.get("archive_tone", "")).strip_edges().find("mour") != -1 else 0,
			"anticipation": 1 if not str(public_summary.get("world_goal", "")).strip_edges().is_empty() else 0
		},
		"interaction_rules": ["dominant theory surfaces remain routed through public-safe summaries"],
		"derived_mind_ids": _string_array(public_summary.get("dominant_minds", [])),
		"summary_lines": _string_array(Array(theory_surface.get("lines", [])) + ["field state remains structurally present"])
	}

static func _build_mind_projections(public_summary: Dictionary, cognitive_field_state: Dictionary) -> Array[Dictionary]:
	var projections: Array[Dictionary] = []
	var dominant_minds := _string_array(public_summary.get("dominant_minds", []))
	var dimensions := Dictionary(cognitive_field_state.get("field_vectors", {}))
	for mind_id in dominant_minds:
		projections.append({
			"mind_id": mind_id,
			"label": mind_id.capitalize(),
			"intensity": clampi(int(dimensions.get("judgment", 0)) + int(dimensions.get("memory", 0)), 0, 8),
			"derived_from_dimensions": _string_array(dimensions.keys())
		})
	return projections

static func _build_compile_lineage_registry(experimental_ontology_state: Dictionary, theory_surface: Dictionary) -> Dictionary:
	var registry: Dictionary = {}
	for experiment_id in _string_array(experimental_ontology_state.get("live_experiment_ids", [])):
		registry[experiment_id] = {
			"lineage_id": experiment_id,
			"kind": "experiment",
			"label": experiment_id,
			"source_ids": [],
			"state": "active",
			"visibility": "operator",
			"play_routing_tags": ["witness", "route_choice", "return"]
		}
	for theory_id in _string_array(theory_surface.get("theory_ids", [])):
		registry[theory_id] = {
			"lineage_id": theory_id,
			"kind": "theory",
			"label": theory_id,
			"source_ids": [],
			"state": "active",
			"visibility": "operator",
			"play_routing_tags": ["witness", "route_choice", "return"]
		}
	return registry

static func _compile_bound_failures(
	world_model: Dictionary,
	doctrine: Dictionary,
	policy: Dictionary,
	simulation: Dictionary,
	validation_violations: Array,
	counter: Dictionary
) -> Array[String]:
	var bundle := {
		"world_model": world_model.duplicate(true),
		"doctrine": doctrine.duplicate(true),
		"policy": CONTROL_SURFACE_REGISTRY_SCRIPT.clamp_policy(policy),
		"simulation": simulation.duplicate(true),
		"counter": counter.duplicate(true)
	}
	var failures: Array[String] = []
	failures.append_array(_string_array(validation_violations))
	for validator in [
		FAIRNESS_CONSTITUTION_SCRIPT,
		LOGIC_CONSTITUTION_SCRIPT,
		LEGIBILITY_CONSTITUTION_SCRIPT,
		DEDUCTION_CONSTITUTION_SCRIPT,
		COHERENCE_CONSTITUTION_SCRIPT,
		EPISTEMIC_CONSTITUTION_SCRIPT
	]:
		failures = _merge_arrays(failures, Array(validator.validate(bundle)))
	return failures

static func _build_doctrine_variant_id(doctrine: Dictionary, generation_surface: Dictionary) -> String:
	var identity_text := "%s|%s|%s|%s" % [
		str(doctrine.get("id", "")).strip_edges(),
		str(generation_surface.get("branch_family", "")).strip_edges(),
		str(generation_surface.get("archive_tone", "")).strip_edges(),
		str(generation_surface.get("convergence_axis", "")).strip_edges()
	]
	return "variant_%s" % identity_text.md5_text().substr(0, 12)

static func _build_topology_profile(generation_surface: Dictionary, ontology_routing: Dictionary) -> Dictionary:
	return {
		"branch_family": str(generation_surface.get("branch_family", "")),
		"protocol_state": str(generation_surface.get("protocol_state", "")),
		"route_bias_tags": _string_array(ontology_routing.get("route_bias_tags", [])),
		"dominant_lineages": _string_array(ontology_routing.get("dominant_lineages", []))
	}

static func _build_chamber_grammar_profile(generation_surface: Dictionary, ontology_routing: Dictionary) -> Dictionary:
	return {
		"pressure_verbs": _string_array(generation_surface.get("pressure_verbs", [])),
		"symbolic_motifs": _string_array(generation_surface.get("symbolic_motifs", [])),
		"public_lines": _string_array(ontology_routing.get("public_lines", [])),
		"verification_instability": int(ontology_routing.get("verification_instability", 0))
	}

static func _build_route_profile(generation_surface: Dictionary, ontology_routing: Dictionary) -> Dictionary:
	return {
		"relationship_routing": Dictionary(generation_surface.get("relationship_routing", {})).duplicate(true),
		"relay_routing": Dictionary(generation_surface.get("relay_routing", {})).duplicate(true),
		"cookbook_routing": Dictionary(generation_surface.get("cookbook_routing", {})).duplicate(true),
		"civilization_routing": Dictionary(generation_surface.get("civilization_routing", {})).duplicate(true),
		"route_bias_tags": _string_array(ontology_routing.get("route_bias_tags", []))
	}

static func _build_item_ecology_profile(generation_surface: Dictionary, ontology_routing: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"item_ecology_bias": str(generation_surface.get("item_ecology_bias", "")),
		"item_bias_tags": _string_array(ontology_routing.get("item_bias_tags", [])),
		"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"dominant_forces": _string_array(public_summary.get("dominant_forces", []))
	}

static func _build_pressure_ecology_profile(generation_surface: Dictionary, ontology_routing: Dictionary, simulation: Dictionary) -> Dictionary:
	return {
		"pressure_verbs": _string_array(generation_surface.get("pressure_verbs", [])),
		"pressure_bias_tags": _string_array(ontology_routing.get("pressure_bias_tags", [])),
		"pacing_profile": str(generation_surface.get("pacing_profile", "")),
		"fairness_risk": int(simulation.get("fairness_risk", 0)),
		"logic_risk": int(simulation.get("logic_risk", 0))
	}

static func _build_information_doctrine_profile(generation_surface: Dictionary, ontology_routing: Dictionary, public_summary: Dictionary, policy: Dictionary) -> Dictionary:
	return {
		"group_tension_bias": str(generation_surface.get("group_tension_bias", "")),
		"dominant_domains": _string_array(public_summary.get("dominant_domains", [])),
		"verification_instability": int(ontology_routing.get("verification_instability", 0)),
		"private_evidence_ratio": int(Dictionary(policy.get("social", {})).get("private_evidence_ratio", 0)),
		"witness_exposure": int(Dictionary(policy.get("generation", {})).get("witness_exposure", 0))
	}

static func _build_pacing_profile(generation_surface: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"id": str(generation_surface.get("pacing_profile", "")),
		"label": str(public_summary.get("pacing_profile", generation_surface.get("pacing_profile", ""))),
		"pressure_line": str(public_summary.get("pressure_line", ""))
	}

static func _build_custody_profile(generation_surface: Dictionary, ontology_routing: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"artifact_centrality": true,
		"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"convergence_axis": str(generation_surface.get("convergence_axis", "")),
		"custody_route_bias": _string_array(ontology_routing.get("route_bias_tags", []))
	}

static func _build_mutation_permissions(generation_surface: Dictionary, ontology_routing: Dictionary, policy: Dictionary) -> Dictionary:
	return {
		"allowed_domains": [
			"route_state",
			"chamber_state",
			"artifact_custody",
			"trace_visibility",
			"pressure_ecology",
			"readability_flags"
		],
		"artifact_centrality_required": true,
		"runtime_non_authority": true,
		"anomaly_budget": int(Dictionary(policy.get("ecology", {})).get("anomaly_contamination", 0)),
		"ontology_sensitive_tags": _string_array(ontology_routing.get("item_bias_tags", [])) + _string_array(ontology_routing.get("route_bias_tags", []))
	}

static func _build_fairness_bounds(policy: Dictionary, simulation: Dictionary, failures: Array[String]) -> Dictionary:
	return {
		"artifact_trust_floor": "objective_central",
		"mechanic_legibility_floor": maxi(int(simulation.get("deduction_clarity", 0)), 2),
		"strategic_readability_floor": maxi(int(simulation.get("ambiguity_quality", 0)), 2),
		"role_fairness_required": true,
		"runtime_non_mutation_required": true,
		"no_hidden_targeting_required": true,
		"witness_exposure_floor": maxi(int(Dictionary(policy.get("generation", {})).get("witness_exposure", 0)), -1),
		"private_evidence_ratio_ceiling": mini(int(Dictionary(policy.get("social", {})).get("private_evidence_ratio", 0)), 1),
		"hidden_role_density_ceiling": mini(int(Dictionary(policy.get("social", {})).get("hidden_role_density", 0)), 1),
		"anomaly_public_ceiling": 1,
		"compile_failures": _string_array(failures)
	}

static func _build_public_summary(public_doctrine: Dictionary, generation_surface: Dictionary, surface_summary: Dictionary, run_identity: Dictionary) -> Dictionary:
	return {
		"pressure_line": str(public_doctrine.get("pressure_line", "")),
		"world_goal": str(public_doctrine.get("world_goal", "")),
		"dominant_minds": Array(public_doctrine.get("dominant_minds", [])).duplicate(true),
		"dominant_forces": Array(public_doctrine.get("dominant_forces", [])).duplicate(true),
		"dominant_domains": Array(public_doctrine.get("dominant_domains", [])).duplicate(true),
		"pressure_grammar": Array(public_doctrine.get("pressure_grammar", generation_surface.get("pressure_verbs", []))).duplicate(true),
		"symbolic_motifs": Array(public_doctrine.get("symbolic_motifs", generation_surface.get("symbolic_motifs", []))).duplicate(true),
		"item_ecology_bias": str(public_doctrine.get("item_ecology_bias", generation_surface.get("item_ecology_bias", ""))),
		"group_tension_bias": str(public_doctrine.get("group_tension_bias", generation_surface.get("group_tension_bias", ""))),
		"archive_tone": str(public_doctrine.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"convergence_axis": str(public_doctrine.get("convergence_axis", generation_surface.get("convergence_axis", ""))),
		"surface_summary": Dictionary(surface_summary).duplicate(true),
		"run_identity": run_identity.duplicate(true)
	}

static func _apply_experiment_generation_weighting(generation_surface: Dictionary, experimental_ontology_state: Dictionary) -> Dictionary:
	var weighting: Dictionary = Dictionary(Dictionary(experimental_ontology_state.get("compile_outputs", {})).get("constitution_weighting", {}))
	if weighting.is_empty():
		return generation_surface.duplicate(true)
	var next := generation_surface.duplicate(true)
	next["pressure_verbs"] = _merge_arrays(Array(next.get("pressure_verbs", [])), Array(weighting.get("pressure_verbs", [])))
	next["symbolic_motifs"] = _merge_arrays(Array(next.get("symbolic_motifs", [])), Array(weighting.get("symbolic_motifs", [])))
	next["item_ecology_bias"] = _merge_axis_text(str(next.get("item_ecology_bias", "")), str(weighting.get("item_ecology_bias_hint", "")))
	next["group_tension_bias"] = _merge_axis_text(str(next.get("group_tension_bias", "")), str(weighting.get("group_tension_bias_hint", "")))
	next["archive_tone"] = _preferred_scalar(str(next.get("archive_tone", "")), str(weighting.get("archive_tone_hint", "")))
	next["convergence_axis"] = _preferred_scalar(str(next.get("convergence_axis", "")), str(weighting.get("convergence_axis_hint", "")))
	return next

static func _apply_experiment_ontology_weighting(ontology_routing: Dictionary, experimental_ontology_state: Dictionary) -> Dictionary:
	var weighting: Dictionary = Dictionary(Dictionary(experimental_ontology_state.get("compile_outputs", {})).get("ontology_weighting", {}))
	if weighting.is_empty():
		return ontology_routing.duplicate(true)
	var next := ontology_routing.duplicate(true)
	next["route_bias_tags"] = _merge_arrays(Array(next.get("route_bias_tags", [])), Array(weighting.get("lineage_bias_tags", [])))
	next["item_bias_tags"] = _merge_arrays(Array(next.get("item_bias_tags", [])), Array(weighting.get("niche_bias_tags", [])))
	var hybridization := Dictionary(next.get("hybridization", {})).duplicate(true)
	hybridization["hybridization_bias"] = clampi(int(hybridization.get("hybridization_bias", 0)) + int(weighting.get("hybridization_bias", 0)), 0, 2)
	next["hybridization"] = hybridization
	next["rediscovery_bias"] = clampi(int(next.get("rediscovery_bias", 0)) + int(weighting.get("rediscovery_bias", 0)), 0, 2)
	return next

static func _apply_experiment_public_summary(summary: Dictionary, experimental_ontology_state: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	var public_surface: Dictionary = Dictionary(experimental_ontology_state.get("public_surface", {}))
	var compile_outputs: Dictionary = Dictionary(experimental_ontology_state.get("compile_outputs", {}))
	var public_lines := _merge_arrays(
		Array(public_surface.get("lines", [])),
		Array(Dictionary(compile_outputs.get("public_activation", {})).get("surface_lines", []))
	)
	var surface_summary: Dictionary = Dictionary(next.get("surface_summary", {})).duplicate(true)
	surface_summary["lines"] = _merge_arrays(Array(surface_summary.get("lines", [])), public_lines)
	next["surface_summary"] = surface_summary
	next["experiment_surface_lines"] = public_lines
	next["experiment_families"] = Array(public_surface.get("family_labels", [])).duplicate(true)
	next["experiment_expression_modes"] = Array(public_surface.get("expression_modes", [])).duplicate(true)
	next["experiment_horizons"] = Array(public_surface.get("horizons", [])).duplicate(true)
	return next

static func _apply_narrative_pressure_generation_weighting(generation_surface: Dictionary, pressure_state: Dictionary) -> Dictionary:
	var weighting: Dictionary = Dictionary(pressure_state.get("generation_weighting", {}))
	if weighting.is_empty():
		return generation_surface.duplicate(true)
	var next := generation_surface.duplicate(true)
	next["pressure_verbs"] = _merge_arrays(Array(next.get("pressure_verbs", [])), Array(weighting.get("pressure_verbs", [])))
	next["symbolic_motifs"] = _merge_arrays(Array(next.get("symbolic_motifs", [])), Array(weighting.get("symbolic_motifs", [])))
	next["item_ecology_bias"] = _merge_axis_text(str(next.get("item_ecology_bias", "")), str(weighting.get("item_ecology_bias", "")))
	next["group_tension_bias"] = _merge_axis_text(str(next.get("group_tension_bias", "")), str(weighting.get("group_tension_bias", "")))
	next["archive_tone"] = _pressure_weighted_scalar(
		str(next.get("archive_tone", "")),
		str(weighting.get("archive_tone", "")),
		int(pressure_state.get("momentum", 0)),
		int(pressure_state.get("resonance", 0))
	)
	next["convergence_axis"] = _pressure_weighted_scalar(
		str(next.get("convergence_axis", "")),
		str(weighting.get("convergence_axis", "")),
		int(pressure_state.get("cascade_risk", 0)),
		int(pressure_state.get("momentum", 0))
	)
	var civilization_routing := Dictionary(next.get("civilization_routing", {})).duplicate(true)
	for key in Dictionary(weighting.get("civilization_routing_bias", {})).keys():
		civilization_routing[str(key)] = clampi(int(civilization_routing.get(key, 0)) + int(Dictionary(weighting.get("civilization_routing_bias", {})).get(key, 0)), 0, 2)
	next["civilization_routing"] = civilization_routing
	return next

static func _apply_narrative_pressure_public_summary(summary: Dictionary, pressure_state: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	var constitution_bias: Dictionary = Dictionary(pressure_state.get("constitution_bias", {}))
	var public_lines := _string_array(pressure_state.get("public_lines", constitution_bias.get("public_lines", [])))
	var surface_summary: Dictionary = Dictionary(next.get("surface_summary", {})).duplicate(true)
	surface_summary["lines"] = _merge_arrays(Array(surface_summary.get("lines", [])), public_lines)
	next["surface_summary"] = surface_summary
	var pressure_line_hint := str(constitution_bias.get("pressure_line", "")).strip_edges()
	if not pressure_line_hint.is_empty() and (str(next.get("pressure_line", "")).strip_edges().is_empty() or int(pressure_state.get("momentum", 0)) >= 3):
		next["pressure_line"] = pressure_line_hint
	var world_goal_hint := str(constitution_bias.get("world_goal_hint", "")).strip_edges()
	if not world_goal_hint.is_empty() and (str(next.get("world_goal", "")).strip_edges().is_empty() or int(pressure_state.get("resonance", 0)) >= 3):
		next["world_goal"] = world_goal_hint
	next["narrative_pressure_family"] = str(pressure_state.get("pressure_family", "")).strip_edges()
	next["narrative_pressure_lines"] = public_lines
	next["narrative_pressure_tensions"] = _string_array(pressure_state.get("dominant_tensions", []))
	next["narrative_pressure_momentum"] = int(pressure_state.get("momentum", 0))
	next["narrative_pressure_resonance"] = int(pressure_state.get("resonance", 0))
	next["narrative_pressure_cascade_risk"] = int(pressure_state.get("cascade_risk", 0))
	return next

static func _merge_arrays(base_values: Array, inherited_values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in base_values + inherited_values:
		var text := str(value).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _merge_axis_text(base_text: String, inherited_text: String) -> String:
	var base_tokens := _string_array(base_text.split(" ", false))
	for token in _string_array(inherited_text.split(" ", false)):
		if not base_tokens.has(token):
			base_tokens.append(token)
	return " ".join(base_tokens).strip_edges()

static func _preferred_scalar(base_text: String, inherited_text: String) -> String:
	var text := base_text.strip_edges()
	return text if not text.is_empty() else inherited_text.strip_edges()

static func _pressure_weighted_scalar(base_text: String, pressure_text: String, major_score: int, support_score: int) -> String:
	var hint := pressure_text.strip_edges()
	if hint.is_empty():
		return base_text.strip_edges()
	if major_score >= 3 or (major_score >= 2 and support_score >= 2):
		return hint
	return _preferred_scalar(base_text, hint)

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

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array or values is PackedStringArray:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _first_string(values: Variant, fallback: String = "") -> String:
	for value in _string_array(values):
		return value
	return fallback
