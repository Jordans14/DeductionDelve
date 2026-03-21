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
const ENCOUNTER_APEX_CONSEQUENCE_VERSION := 1

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
	var contradiction_packet := CONTRADICTION_ENGINE_SCRIPT.build_contradiction_records(
		theory_surface,
		Dictionary(world_model.get("cookbook_state_snapshot", {})),
		Dictionary(world_model.get("world_memory_snapshot", {}))
	)
	governance_state = GOVERNANCE_SERVICE_SCRIPT.evaluate_planning_state(
		governance_state,
		world_model,
		theory_surface,
		civilization_surface,
		contradiction_packet,
		Dictionary(world_model.get("cookbook_state_snapshot", {}))
	)
	theory_surface = THEORY_ENGINE_SCRIPT.build_surface(experimental_ontology_state, world_model, governance_state)
	contradiction_packet = CONTRADICTION_ENGINE_SCRIPT.build_contradiction_records(
		theory_surface,
		Dictionary(world_model.get("cookbook_state_snapshot", {})),
		Dictionary(world_model.get("world_memory_snapshot", {}))
	)
	var creative_governance := Dictionary(experimental_ontology_state.get("creative_governance", world_model.get("creative_governance", {}))).duplicate(true)
	var cognitive_field_state := _build_cognitive_field_state(world_model, compiler_public_summary, theory_surface, run_identity)
	var mind_projections := _build_mind_projections(compiler_public_summary, cognitive_field_state, run_identity)
	var activation_state := GOVERNANCE_SERVICE_SCRIPT.normalize_activation_state(Dictionary(governance_state.get("activation_state", {})))
	activation_state["safe_mode_state"] = Dictionary(governance_state.get("safe_mode_state", {})).duplicate(true)
	var review_surface := GOVERNANCE_SERVICE_SCRIPT.build_review_surface(governance_state, theory_surface)
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
			_first_string(Array(civilization_surface.get("lines", [])), ""),
			_first_string(Array(Dictionary(contradiction_packet.get("meta_reflection_report", {})).get("summary_lines", [])), "")
		],
		Array(review_surface.get("lines", [])),
		["movement", "burden", "witness", "route_choice", "artifact_custody", "extraction", "return"],
		{
			"immediate": [{
				"trigger": str(compiler_public_summary.get("pressure_line", compiler_public_summary.get("world_goal", ""))).strip_edges(),
				"escalation": _first_string(Array(narrative_pressure_state.get("lines", [])), ""),
				"consequence": _first_string(Array(review_surface.get("lines", [])), ""),
				"interpretation": str(compiler_public_summary.get("world_goal", "")).strip_edges(),
				"priority": 3,
				"public_safe": true
			}],
			"run": [{
				"trigger": _first_string(Array(theory_surface.get("lines", [])), ""),
				"escalation": _first_string(Array(civilization_surface.get("lines", [])), ""),
				"consequence": _first_string(Array(Dictionary(contradiction_packet.get("anti_bottleneck_report", {})).get("summary_lines", [])), ""),
				"interpretation": _first_string(Array(review_surface.get("lines", [])), ""),
				"priority": 2,
				"public_safe": true
			}],
			"meta": [{
				"trigger": _first_string(Array(activation_state.get("activation_lines", [])), ""),
				"escalation": _first_string(Array(Dictionary(activation_state.get("safe_mode_state", {})).get("summary_lines", [])), ""),
				"consequence": _first_string(Array(Dictionary(contradiction_packet.get("meta_reflection_report", {})).get("summary_lines", [])), ""),
				"interpretation": _first_string(Array(review_surface.get("lines", [])), ""),
				"priority": 1,
				"public_safe": true
			}]
		},
		{
			"priority_channels": ["immediate", "run", "meta"],
			"fairness_flags": ["runtime_non_mutation_required", "no_hidden_targeting_required"],
			"public_surface_tags": ["movement", "burden", "witness", "route_choice", "artifact_custody", "extraction", "return"],
			"provenance_source_refs": [
				"compiler_public_summary",
				"theory_surface",
				"civilization_surface",
				"review_surface",
				"activation_state"
			],
			"max_visible_channels": 3,
			"max_lines_per_layer": 2,
			"max_total_lines": 6,
			"residue_budget": 2
		}
	)
	var market_regime_state := _build_market_regime_state(world_model, compiled_policy, compiler_public_summary, compiled_generation_surface)
	var market_memory_state := _build_market_memory_state(world_model, market_regime_state)
	var lifecycle_registry := _build_lifecycle_registry(market_regime_state, market_memory_state, world_model)
	compiled_generation_surface["market_routing"] = _build_market_routing(compiled_generation_surface, market_regime_state, market_memory_state, lifecycle_registry)
	compiled_generation_surface["lifecycle_routing"] = _build_lifecycle_routing(lifecycle_registry)
	compiler_public_summary = _apply_phase3_public_summary(compiler_public_summary, market_regime_state, lifecycle_registry)
	var encounter_language_profile := _build_encounter_language_profile(compiled_generation_surface, compiler_public_summary)
	var pathology_profile := _build_pathology_profile(market_regime_state, compiler_public_summary)
	var pathology_state := _build_pathology_state(pathology_profile, market_regime_state)
	var encounter_manifest := _build_encounter_manifest(pathology_profile, encounter_language_profile, compiled_generation_surface)
	compiled_generation_surface["encounter_routing"] = _build_encounter_routing(compiled_generation_surface, encounter_manifest, pathology_state)
	compiler_public_summary = _apply_phase4_public_summary(compiler_public_summary, encounter_manifest, pathology_state)
	var apex_framework_profile := _build_apex_framework_profile(encounter_language_profile, encounter_manifest, pathology_profile, compiled_generation_surface, compiler_public_summary)
	var apex_manifest := _build_apex_manifest(apex_framework_profile, encounter_manifest, pathology_profile, compiled_generation_surface, compiler_public_summary)
	var peak_structure_profile := _build_peak_structure_profile(compiler_public_summary, compiled_generation_surface, apex_manifest)
	compiled_generation_surface["apex_routing"] = _build_apex_routing(compiled_generation_surface, apex_manifest, peak_structure_profile)
	compiler_public_summary = _apply_phase5_public_summary(compiler_public_summary, apex_manifest, peak_structure_profile)
	lifecycle_registry = _expand_phase6_lifecycle_registry(lifecycle_registry, pathology_state, encounter_manifest, apex_manifest, peak_structure_profile)
	compiled_generation_surface["market_routing"] = _build_market_routing(compiled_generation_surface, market_regime_state, market_memory_state, lifecycle_registry)
	compiled_generation_surface["lifecycle_routing"] = _build_lifecycle_routing(lifecycle_registry)
	compiler_public_summary = _apply_phase3_public_summary(compiler_public_summary, market_regime_state, lifecycle_registry)
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
			"convergence_axis": str(compiled_generation_surface.get("convergence_axis", "")),
			"active_regime_ids": _string_array(market_regime_state.get("active_regime_ids", [])),
			"lifecycle_state_ids": _string_array(lifecycle_registry.get("active_state_ids", [])),
			"lifecycle_family_kinds": _lifecycle_family_kinds(lifecycle_registry),
			"active_pathology_ids": _string_array(pathology_state.get("active_family_ids", [])),
			"encounter_manifest_ids": _encounter_manifest_ids(encounter_manifest),
			"apex_manifest_ids": _apex_manifest_ids(apex_manifest),
			"apex_class_ids": _apex_class_ids(apex_manifest)
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
			"learning_guidance_bias_trace": Dictionary(Dictionary(experimental_ontology_state.get("compiler_trace", {})).get("learning_guidance_bias_trace", {})).duplicate(true),
			"creative_governance": {
				"novelty_envelope": Dictionary(creative_governance.get("novelty_envelope", {})).duplicate(true),
				"taste_profile": Dictionary(creative_governance.get("taste_profile", {})).duplicate(true),
				"personality_band": str(creative_governance.get("personality_band", "")).strip_edges(),
				"bounded_surface_ids": _string_array(creative_governance.get("bounded_surface_ids", [])),
				"suppressed_patterns": _string_array(creative_governance.get("suppressed_patterns", [])),
				"revive_candidates": _string_array(creative_governance.get("revive_candidates", []))
			}
		},
		"encounter_language": {
			"intent_ids": _string_array(_encounter_intent_ids(encounter_manifest)),
			"topology_ids": _string_array(_encounter_topology_ids(encounter_manifest)),
			"active_pathology_ids": _string_array(pathology_state.get("active_family_ids", [])),
			"encounter_manifest_ids": _encounter_manifest_ids(encounter_manifest),
			"anchored_pressures": _encounter_anchor_coverage(encounter_manifest),
			"encounter_apex_consequence_version": ENCOUNTER_APEX_CONSEQUENCE_VERSION
		},
		"apex_framework": {
			"apex_manifest_ids": _apex_manifest_ids(apex_manifest),
			"apex_class_ids": _apex_class_ids(apex_manifest),
			"resolution_classes": _apex_resolution_coverage(apex_manifest),
			"peak_spacing_score": int(peak_structure_profile.get("peak_spacing_score", 0)),
			"encounter_apex_consequence_version": ENCOUNTER_APEX_CONSEQUENCE_VERSION
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
		"creative_novelty_band": str(Dictionary(creative_governance.get("novelty_envelope", {})).get("active_band", "")).strip_edges(),
		"creative_personality_band": str(creative_governance.get("personality_band", "")).strip_edges(),
		"creative_bounded_surface_ids": _string_array(creative_governance.get("bounded_surface_ids", [])),
		"creative_suppressed_patterns": _string_array(creative_governance.get("suppressed_patterns", [])),
		"dominant_lineages": Array(ontology_routing.get("dominant_lineages", [])).duplicate(true),
		"active_regime_ids": _string_array(market_regime_state.get("active_regime_ids", [])),
		"lifecycle_state_ids": _string_array(lifecycle_registry.get("active_state_ids", [])),
		"lifecycle_family_kinds": _lifecycle_family_kinds(lifecycle_registry),
		"active_pathology_ids": _string_array(pathology_state.get("active_family_ids", [])),
		"encounter_manifest_ids": _encounter_manifest_ids(encounter_manifest),
		"encounter_intent_ids": _encounter_intent_ids(encounter_manifest),
		"encounter_topology_ids": _encounter_topology_ids(encounter_manifest),
		"encounter_anchor_categories": _encounter_anchor_coverage(encounter_manifest),
		"apex_manifest_ids": _apex_manifest_ids(apex_manifest),
		"apex_class_ids": _apex_class_ids(apex_manifest),
		"apex_resolution_classes": _apex_resolution_coverage(apex_manifest),
		"peak_spacing_score": int(peak_structure_profile.get("peak_spacing_score", 0)),
		"encounter_apex_consequence_version": ENCOUNTER_APEX_CONSEQUENCE_VERSION,
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
		"creative_governance": creative_governance,
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
		"market_regime_state": market_regime_state,
		"market_memory_state": market_memory_state,
		"lifecycle_registry": lifecycle_registry,
		"encounter_language_profile": encounter_language_profile,
		"pathology_profile": pathology_profile,
		"pathology_state": pathology_state,
		"encounter_manifest": encounter_manifest,
		"apex_framework_profile": apex_framework_profile,
		"apex_manifest": apex_manifest,
		"peak_structure_profile": peak_structure_profile,
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
	var constitution_schema := SCHEMA_REGISTRY_SCRIPT.constitution_schema()
	if not _string_array(constitution_schema.get("required_sections", [])).has("semantic_lock_registry"):
		failures.append("constitution schema must require semantic_lock_registry")
	var semantic_lock_required_fields := _string_array(constitution_schema.get("semantic_lock_required_fields", []))
	for field in ["schema_name", "schema_version", "registry_id", "constitution_hash", "constitution_id", "tuple_records"]:
		if not semantic_lock_required_fields.has(field):
			failures.append("constitution schema semantic_lock_required_fields missing %s" % field)
	var governance_schema := SCHEMA_REGISTRY_SCRIPT.governance_schema()
	var semantic_lock_registry_required_fields := _string_array(governance_schema.get("semantic_lock_registry_required_fields", []))
	for field in ["schema_name", "schema_version", "registry_id", "constitution_hash", "constitution_id", "tuple_records"]:
		if not semantic_lock_registry_required_fields.has(field):
			failures.append("governance schema semantic_lock_registry_required_fields missing %s" % field)
	var semantic_lock_tuple_required_fields := _string_array(governance_schema.get("semantic_lock_tuple_required_fields", []))
	for field in ["tuple_id", "subject_class", "owner_lane", "canonical_source_owner", "canonical_source_fields", "digest_fields", "allowed_consumers", "visibility_class", "derivation_policy", "failure_codes"]:
		if not semantic_lock_tuple_required_fields.has(field):
			failures.append("governance schema semantic_lock_tuple_required_fields missing %s" % field)
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
	var creative_governance: Dictionary = Dictionary(bundle.get("creative_governance", {}))
	for key in ["novelty_envelope", "taste_profile", "personality_band", "bounded_surface_ids", "suppressed_patterns", "revive_candidates"]:
		if not creative_governance.has(key):
			failures.append("compile output creative_governance missing %s" % key)
	if not Array(compile_metadata.get("experiment_validation_failures", [])).is_empty():
		failures.append_array(_string_array(compile_metadata.get("experiment_validation_failures", [])))
	var fairness_bounds: Dictionary = Dictionary(bundle.get("fairness_bounds", {}))
	if not fairness_bounds.has("runtime_non_mutation_required") or not bool(fairness_bounds.get("runtime_non_mutation_required", false)):
		failures.append("fairness bounds must preserve runtime_non_mutation_required")
	if not fairness_bounds.has("no_hidden_targeting_required") or not bool(fairness_bounds.get("no_hidden_targeting_required", false)):
		failures.append("fairness bounds must preserve no_hidden_targeting_required")
	failures.append_array(_validate_encounter_contracts(bundle))
	failures.append_array(_validate_apex_contracts(bundle))
	failures.append_array(_validate_phase6_lifecycle_registry(bundle))
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

static func _build_cognitive_field_state(world_model: Dictionary, public_summary: Dictionary, theory_surface: Dictionary, run_identity: Dictionary = {}) -> Dictionary:
	var creative_governance: Dictionary = Dictionary(world_model.get("creative_governance", {}))
	var run_field_state: Dictionary = Dictionary(run_identity.get("cognitive_field_state", {}))
	if not run_field_state.is_empty():
		var current := run_field_state.duplicate(true)
		var personality_band := str(current.get("personality_band", creative_governance.get("personality_band", "disciplined_curiosity"))).strip_edges()
		if personality_band.is_empty():
			personality_band = "disciplined_curiosity"
		var novelty_band := str(Dictionary(creative_governance.get("novelty_envelope", {})).get("active_band", "anchored_core")).strip_edges()
		var suppressed_patterns := _string_array(creative_governance.get("suppressed_patterns", []))
		current["summary_lines"] = _string_array(
			Array(current.get("summary_lines", []))
			+ Array(theory_surface.get("lines", []))
			+ Array(Dictionary(world_model.get("theory_surface", {})).get("chamber_lines", []))
		).slice(0, 4)
		current["self_interpretation_trace"] = _string_array(
			Array(current.get("self_interpretation_trace", []))
			+ [
				"DelveMind is reading itself through %s." % personality_band.replace("_", " "),
				"Novelty envelope remains at %s while theory surfaces stay bounded." % novelty_band.replace("_", " ")
			]
		).slice(0, 4)
		current["unknown_space_markers"] = _string_array(
			Array(current.get("unknown_space_markers", []))
			+ (suppressed_patterns if not suppressed_patterns.is_empty() else ["unknown_space:bounded_frontier"])
		)
		current["personality_band"] = personality_band
		return current
	var dominant_forces := _string_array(public_summary.get("dominant_forces", []))
	var dominant_domains := _string_array(public_summary.get("dominant_domains", []))
	var theory_ids := _string_array(theory_surface.get("theory_ids", []))
	var personality_band := str(creative_governance.get("personality_band", "disciplined_curiosity")).strip_edges()
	var novelty_band := str(Dictionary(creative_governance.get("novelty_envelope", {})).get("active_band", "anchored_core")).strip_edges()
	var suppressed_patterns := _string_array(creative_governance.get("suppressed_patterns", []))
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
		"personality_band": personality_band,
		"self_interpretation_trace": _string_array([
			"DelveMind is reading itself through %s." % personality_band.replace("_", " "),
			"Novelty envelope remains at %s while theory surfaces stay bounded." % novelty_band.replace("_", " ")
		]),
		"unknown_space_markers": _string_array(suppressed_patterns if not suppressed_patterns.is_empty() else ["unknown_space:bounded_frontier"]),
		"summary_lines": _string_array(Array(theory_surface.get("lines", [])) + ["field vectors are actively shaping doctrine pressure"])
	}

static func _build_mind_projections(public_summary: Dictionary, cognitive_field_state: Dictionary, run_identity: Dictionary = {}) -> Array[Dictionary]:
	var projected: Array[Dictionary] = []
	for mind_raw in Array(run_identity.get("active_minds", [])):
		var mind_state: Dictionary = Dictionary(mind_raw)
		var mind_id := str(mind_state.get("id", "")).strip_edges()
		if mind_id.is_empty():
			continue
		projected.append({
			"mind_id": mind_id,
			"label": str(mind_state.get("label", mind_id)).strip_edges(),
			"intensity": clampi(int(mind_state.get("intensity", 0)), 0, 8),
			"derived_from_dimensions": _string_array(mind_state.get("derived_from_dimensions", Dictionary(cognitive_field_state.get("field_vectors", {})).keys())),
			"personality_mode": str(mind_state.get("personality_mode", Dictionary(cognitive_field_state).get("personality_band", "disciplined_curiosity"))).strip_edges(),
			"mind_projection_intent": str(mind_state.get("mind_projection_intent", "interpretive_projection")).strip_edges(),
			"unknown_space_markers": _string_array(mind_state.get("unknown_space_markers", Dictionary(cognitive_field_state).get("unknown_space_markers", []))),
			"self_interpretation_line": _first_string(Dictionary(cognitive_field_state).get("self_interpretation_trace", []), "")
		})
	if not projected.is_empty():
		return projected
	var projections: Array[Dictionary] = []
	var dominant_minds := _string_array(public_summary.get("dominant_minds", []))
	var dimensions := Dictionary(cognitive_field_state.get("field_vectors", {}))
	var personality_band := str(cognitive_field_state.get("personality_band", "disciplined_curiosity")).strip_edges()
	var unknown_space_markers := _string_array(cognitive_field_state.get("unknown_space_markers", []))
	for mind_id in dominant_minds:
		projections.append({
			"mind_id": mind_id,
			"label": mind_id.capitalize(),
			"intensity": clampi(int(dimensions.get("judgment", 0)) + int(dimensions.get("memory", 0)), 0, 8),
			"derived_from_dimensions": _string_array(dimensions.keys()),
			"personality_mode": personality_band,
			"mind_projection_intent": "bounded_interpretation",
			"unknown_space_markers": unknown_space_markers,
			"self_interpretation_line": _first_string(cognitive_field_state.get("self_interpretation_trace", []), "")
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
		"market_routing": Dictionary(generation_surface.get("market_routing", {})).duplicate(true),
		"encounter_routing": Dictionary(generation_surface.get("encounter_routing", {})).duplicate(true),
		"route_bias_tags": _string_array(ontology_routing.get("route_bias_tags", []))
	}

static func _build_item_ecology_profile(generation_surface: Dictionary, ontology_routing: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"item_ecology_bias": str(generation_surface.get("item_ecology_bias", "")),
		"item_bias_tags": _string_array(ontology_routing.get("item_bias_tags", [])),
		"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"dominant_forces": _string_array(public_summary.get("dominant_forces", [])),
		"market_regime_ids": _string_array(public_summary.get("active_regime_ids", [])),
		"lifecycle_state_ids": _string_array(public_summary.get("lifecycle_state_ids", []))
	}

static func _build_pressure_ecology_profile(generation_surface: Dictionary, ontology_routing: Dictionary, simulation: Dictionary) -> Dictionary:
	return {
		"pressure_verbs": _string_array(generation_surface.get("pressure_verbs", [])),
		"pressure_bias_tags": _string_array(ontology_routing.get("pressure_bias_tags", [])),
		"pacing_profile": str(generation_surface.get("pacing_profile", "")),
		"fairness_risk": int(simulation.get("fairness_risk", 0)),
		"logic_risk": int(simulation.get("logic_risk", 0)),
		"market_lines": _string_array(Dictionary(generation_surface.get("market_routing", {})).get("market_lines", []))
	}

static func _build_market_regime_state(world_model: Dictionary, policy: Dictionary, public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var economy_model: Dictionary = Dictionary(world_model.get("economy_model", {}))
	var cultural_model: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var economy_policy: Dictionary = Dictionary(policy.get("economy", {}))
	var ecology_policy: Dictionary = Dictionary(policy.get("ecology", {}))
	var scorecard := {
		"austerity": maxi(int(economy_policy.get("market_volatility", 0)), 0) + maxi(int(economy_policy.get("hoard_visibility", 0)), 0) + maxi(int(economy_model.get("extraction_debt", 0)), 0) / 2 + maxi(int(economy_model.get("hoard_heat", 0)), 0) / 2,
		"prestige": maxi(int(economy_policy.get("prestige_pressure", 0)), 0) + maxi(int(cultural_model.get("legitimacy_pressure", 0)), 0) / 2 + maxi(int(cultural_model.get("witness_network_pressure", 0)), 0) / 2,
		"recovery": maxi(int(economy_policy.get("scarcity_recovery", 0)), 0) + maxi(int(economy_model.get("recovery_credit", 0)), 0) / 2 + maxi(int(economy_model.get("recovery_appetite", 0)), 0),
		"distortion": maxi(int(ecology_policy.get("anomaly_contamination", 0)), 0) + maxi(int(economy_model.get("distortion_heat", 0)), 0) / 2 + maxi(int(cultural_model.get("false_canon_pressure", 0)), 0) / 2,
		"balanced": 1
	}
	var ordered_ids := _ordered_scorecard_ids(scorecard)
	var primary_family := "balanced"
	if not ordered_ids.is_empty():
		primary_family = ordered_ids[0]
	var active_regime_ids: Array[String] = []
	match primary_family:
		"austerity":
			active_regime_ids.append("market_extraction_austerity")
		"prestige":
			active_regime_ids.append("market_prestige_showcase")
		"recovery":
			active_regime_ids.append("market_recovery_weave")
		"distortion":
			active_regime_ids.append("market_distortion_spike")
		_:
			active_regime_ids.append("market_balanced_exchange")
	if ordered_ids.size() >= 2 and int(scorecard.get(ordered_ids[1], 0)) >= maxi(int(scorecard.get(primary_family, 0)) - 1, 1):
		match str(ordered_ids[1]):
			"austerity":
				if not active_regime_ids.has("market_extraction_austerity"):
					active_regime_ids.append("market_extraction_austerity")
			"prestige":
				if not active_regime_ids.has("market_prestige_showcase"):
					active_regime_ids.append("market_prestige_showcase")
			"recovery":
				if not active_regime_ids.has("market_recovery_weave"):
					active_regime_ids.append("market_recovery_weave")
			"distortion":
				if not active_regime_ids.has("market_distortion_spike"):
					active_regime_ids.append("market_distortion_spike")
	var summary_lines: Array[String] = []
	if active_regime_ids.has("market_extraction_austerity"):
		summary_lines.append("Extraction debt is tightening the route economy.")
	if active_regime_ids.has("market_prestige_showcase"):
		summary_lines.append("Prestige pressure is making high-visibility carriers matter more.")
	if active_regime_ids.has("market_recovery_weave"):
		summary_lines.append("Recovery credit is keeping scarcity from sealing the route shut.")
	if active_regime_ids.has("market_distortion_spike"):
		summary_lines.append("Distortion pressure is warping how value is being read.")
	if summary_lines.is_empty():
		summary_lines.append("Market pressure is staying within a balanced exchange band.")
	return {
		"regime_id": active_regime_ids[0],
		"regime_family": primary_family,
		"scarcity_band": _market_band(maxi(int(economy_policy.get("market_volatility", 0)), 0) + maxi(int(economy_model.get("extraction_debt", 0)), 0) / 2),
		"prestige_band": _market_band(maxi(int(economy_policy.get("prestige_pressure", 0)), 0) + maxi(int(cultural_model.get("legitimacy_pressure", 0)), 0) / 2),
		"carrier_risk_band": _market_band(maxi(int(economy_policy.get("carrier_risk_bias", 0)), 0) + maxi(int(economy_model.get("burden_tolerance", 0)), 0) / 2),
		"anomaly_significance_band": _market_band(maxi(int(ecology_policy.get("anomaly_contamination", 0)), 0) + maxi(int(economy_model.get("distortion_heat", 0)), 0) / 2),
		"institutional_pressure_band": _market_band(maxi(int(cultural_model.get("legitimacy_pressure", 0)), 0) + maxi(int(cultural_model.get("revision_pressure", 0)), 0) / 2),
		"active_regime_ids": active_regime_ids,
		"scorecard": scorecard,
		"summary_lines": summary_lines.slice(0, 3),
		"pressure_line": str(public_summary.get("pressure_line", generation_surface.get("archive_tone", ""))).strip_edges()
	}

static func _build_market_memory_state(world_model: Dictionary, market_regime_state: Dictionary) -> Dictionary:
	var economy_model: Dictionary = Dictionary(world_model.get("economy_model", {}))
	var lines := _string_array(market_regime_state.get("summary_lines", []))
	return {
		"active_regime_ids": _string_array(market_regime_state.get("active_regime_ids", [])),
		"extraction_debt": int(economy_model.get("extraction_debt", 0)),
		"hoard_heat": int(economy_model.get("hoard_heat", 0)),
		"neglect_heat": int(economy_model.get("neglect_heat", 0)),
		"distortion_heat": int(economy_model.get("distortion_heat", 0)),
		"recovery_credit": int(economy_model.get("recovery_credit", 0)),
		"prestige_climate": str(economy_model.get("prestige_climate", "")).strip_edges(),
		"carrier_risk_band": str(market_regime_state.get("carrier_risk_band", "")).strip_edges(),
		"lines": lines
	}

static func _build_lifecycle_registry(market_regime_state: Dictionary, market_memory_state: Dictionary, world_model: Dictionary = {}) -> Dictionary:
	var active_regime_ids := _string_array(market_regime_state.get("active_regime_ids", []))
	var families: Array[Dictionary] = []
	var extraction_debt := int(market_memory_state.get("extraction_debt", 0))
	var hoard_heat := int(market_memory_state.get("hoard_heat", 0))
	var recovery_credit := int(market_memory_state.get("recovery_credit", 0))
	for regime_id in active_regime_ids:
		var heat := clampi(extraction_debt + hoard_heat + 1, 0, 8)
		var saturation := clampi(maxi(extraction_debt, hoard_heat), 0, 8)
		var strain := clampi(abs(extraction_debt - recovery_credit) + int(market_memory_state.get("distortion_heat", 0)), 0, 8)
		var state := "emerging"
		if saturation >= 4:
			state = "saturated"
		elif heat >= 3:
			state = "active"
		elif recovery_credit >= extraction_debt and recovery_credit >= 2:
			state = "cooling"
		families.append(_normalize_phase6_lifecycle_family({
			"family_id": regime_id,
			"family_kind": "market",
			"source_id": regime_id,
			"state": state,
			"heat": heat,
			"saturation": saturation,
			"strain": strain,
			"cooling_tags": ["recovery_credit"] if recovery_credit >= extraction_debt else ["extraction_debt"],
			"cooldown_band": _cooldown_band_for_family(heat, saturation, state, "market"),
			"successor_hint": "market_recovery_weave" if regime_id == "market_extraction_austerity" else ("market_prestige_showcase" if regime_id == "market_balanced_exchange" else "market_balanced_exchange"),
			"return_window": "near_horizon" if state in ["active", "cooling"] else "mid_horizon",
			"routing_tags": _merge_arrays(["market", "return"], _market_family_routing_tags(regime_id, market_regime_state, market_memory_state)),
			"dominance_strain": strain,
			"throttle_state": "cooling" if state in ["cooling", "saturated"] else "open",
			"resurrection_priority": clampi(heat / 2, 0, 4)
		}))
	var lines: Array[String] = []
	families.append_array(_combo_lifecycle_families(world_model))
	families.append_array(_artifact_continuity_lifecycle_families(world_model))
	families.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_rank := int(a.get("heat", 0)) + int(a.get("saturation", 0)) + int(a.get("dominance_strain", a.get("strain", 0)))
		var b_rank := int(b.get("heat", 0)) + int(b.get("saturation", 0)) + int(b.get("dominance_strain", b.get("strain", 0)))
		if a_rank == b_rank:
			return str(a.get("family_id", "")) < str(b.get("family_id", ""))
		return a_rank > b_rank
	)
	for family_raw in families:
		var family: Dictionary = Dictionary(family_raw)
		lines.append("%s is %s with %s strain." % [
			str(family.get("family_id", "")).replace("_", " "),
			str(family.get("state", "")),
			_market_band(int(family.get("strain", 0)))
		])
	return {
		"families": families.slice(0, 12),
		"active_state_ids": _active_lifecycle_state_ids(families),
		"lines": lines.slice(0, 3)
	}

static func _expand_phase6_lifecycle_registry(base_registry: Dictionary, pathology_state: Dictionary, encounter_manifest: Dictionary, apex_manifest: Dictionary, peak_structure_profile: Dictionary) -> Dictionary:
	var current := Dictionary(base_registry).duplicate(true)
	var family_index := {}
	for family_raw in Array(current.get("families", [])):
		var family := _normalize_phase6_lifecycle_family(Dictionary(family_raw))
		var family_id := str(family.get("family_id", "")).strip_edges()
		if not family_id.is_empty():
			family_index[family_id] = family
	for pathology_id in _string_array(pathology_state.get("active_family_ids", [])):
		var spread_heat := clampi(int(pathology_state.get("spread_heat", 0)), 0, 8)
		var recurrence_heat := clampi(int(pathology_state.get("recurrence_heat", 0)), 0, 8)
		var family := _normalize_phase6_lifecycle_family({
			"family_id": pathology_id,
			"family_kind": "pathology",
			"source_id": pathology_id,
			"state": "saturated" if spread_heat >= 4 else ("active" if spread_heat >= 2 else "cooling"),
			"heat": clampi(spread_heat + 1, 0, 8),
			"saturation": clampi(maxi(spread_heat, recurrence_heat - 1), 0, 8),
			"strain": clampi(abs(spread_heat - recurrence_heat), 0, 8),
			"cooling_tags": ["remission", "suppression"],
			"cooldown_band": _cooldown_band_for_family(clampi(spread_heat + 1, 0, 8), clampi(maxi(spread_heat, recurrence_heat - 1), 0, 8), "active" if spread_heat >= 2 else "cooling", "pathology"),
			"successor_hint": "%s_successor" % pathology_id,
			"return_window": "near_horizon",
			"routing_tags": ["pathology", "hazard", "return"],
			"dominance_strain": clampi(spread_heat + recurrence_heat - 1, 0, 8),
			"throttle_state": "cooling" if spread_heat >= 4 else "open",
			"resurrection_priority": clampi(recurrence_heat + 1, 0, 4)
		})
		family_index[pathology_id] = _merge_phase6_lifecycle_family(Dictionary(family_index.get(pathology_id, {})), family)
	var encounter_counts := {}
	var encounter_topology_hints := {}
	for encounter_raw in Array(encounter_manifest.get("encounters", [])):
		var encounter := Dictionary(encounter_raw)
		var intent_id := str(encounter.get("intent_id", "")).strip_edges()
		if intent_id.is_empty():
			continue
		encounter_counts[intent_id] = int(encounter_counts.get(intent_id, 0)) + 1
		encounter_topology_hints[intent_id] = str(encounter.get("topology_id", encounter_topology_hints.get(intent_id, ""))).strip_edges()
	for intent_id in encounter_counts.keys():
		var count := int(encounter_counts.get(intent_id, 0))
		var family_id := "encounter_%s" % str(intent_id)
		var family := _normalize_phase6_lifecycle_family({
			"family_id": family_id,
			"family_kind": "encounter",
			"source_id": str(intent_id),
			"state": "saturated" if count >= 3 else ("active" if count >= 1 else "cooling"),
			"heat": clampi(count + 1, 0, 8),
			"saturation": clampi(count, 0, 8),
			"strain": clampi(count - 1, 0, 8),
			"cooling_tags": ["resolution_diversity", "quiet_play"],
			"cooldown_band": _cooldown_band_for_family(clampi(count + 1, 0, 8), clampi(count, 0, 8), "active" if count >= 1 else "cooling", "encounter"),
			"successor_hint": str(encounter_topology_hints.get(intent_id, "encounter_successor")).strip_edges(),
			"return_window": "near_horizon",
			"routing_tags": ["encounter", str(intent_id), str(encounter_topology_hints.get(intent_id, "")).strip_edges()],
			"dominance_strain": clampi(count + 1, 0, 8),
			"throttle_state": "cooling" if count >= 3 else "open",
			"resurrection_priority": clampi(4 - mini(count, 3), 0, 4)
		})
		family_index[family_id] = _merge_phase6_lifecycle_family(Dictionary(family_index.get(family_id, {})), family)
	var apex_class_counts := {}
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		var apex := Dictionary(apex_raw)
		var class_id := str(apex.get("apex_class_id", apex.get("class_id", ""))).strip_edges()
		if class_id.is_empty():
			continue
		apex_class_counts[class_id] = int(apex_class_counts.get(class_id, 0)) + 1
	for class_id in apex_class_counts.keys():
		var count := int(apex_class_counts.get(class_id, 0))
		var peak_spacing_score := clampi(int(peak_structure_profile.get("peak_spacing_score", 0)), 0, 4)
		var family_id := "apex_%s" % str(class_id)
		var family := _normalize_phase6_lifecycle_family({
			"family_id": family_id,
			"family_kind": "apex",
			"source_id": str(class_id),
			"state": "saturated" if count >= 2 and peak_spacing_score <= 2 else "active",
			"heat": clampi(count + 2, 0, 8),
			"saturation": clampi(count + maxi(0, 3 - peak_spacing_score), 0, 8),
			"strain": clampi(maxi(0, 3 - peak_spacing_score), 0, 8),
			"cooling_tags": ["peak_spacing", "aftermath_space"],
			"cooldown_band": _cooldown_band_for_family(clampi(count + 2, 0, 8), clampi(count + maxi(0, 3 - peak_spacing_score), 0, 8), "active", "apex"),
			"successor_hint": "encounter_%s" % class_id,
			"return_window": "mid_horizon",
			"routing_tags": ["apex", str(class_id), "return"],
			"dominance_strain": clampi(count + maxi(0, 3 - peak_spacing_score), 0, 8),
			"throttle_state": "cooling" if peak_spacing_score <= 2 else "open",
			"resurrection_priority": clampi(peak_spacing_score, 0, 4)
		})
		family_index[family_id] = _merge_phase6_lifecycle_family(Dictionary(family_index.get(family_id, {})), family)
	var families: Array[Dictionary] = []
	for family_id in family_index.keys():
		families.append(_normalize_phase6_lifecycle_family(Dictionary(family_index.get(family_id, {}))))
	families.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_rank := int(a.get("heat", 0)) + int(a.get("saturation", 0)) + int(a.get("dominance_strain", 0))
		var b_rank := int(b.get("heat", 0)) + int(b.get("saturation", 0)) + int(b.get("dominance_strain", 0))
		if a_rank == b_rank:
			return str(a.get("family_id", "")) < str(b.get("family_id", ""))
		return a_rank > b_rank
	)
	current["families"] = families.slice(0, 12)
	var active_state_ids: Array[String] = []
	for family_raw in families:
		var family := Dictionary(family_raw)
		var family_id := str(family.get("family_id", "")).strip_edges()
		if not family_id.is_empty() and not active_state_ids.has(family_id):
			active_state_ids.append(family_id)
	current["active_state_ids"] = active_state_ids.slice(0, 12)
	var lines: Array[String] = []
	for family_raw in families.slice(0, 4):
		var family := Dictionary(family_raw)
		lines.append("%s is %s with %s strain and %s throttle." % [
			str(family.get("family_id", "")).replace("_", " "),
			str(family.get("state", "active")),
			_market_band(int(family.get("dominance_strain", family.get("strain", 0)))),
			str(family.get("throttle_state", "open"))
		])
	current["lines"] = lines.slice(0, 4)
	return current

static func _merge_phase6_lifecycle_family(existing: Dictionary, incoming: Dictionary) -> Dictionary:
	if existing.is_empty():
		return incoming
	var merged := existing.duplicate(true)
	merged["state"] = str(incoming.get("state", merged.get("state", "emerging"))).strip_edges()
	merged["heat"] = maxi(int(merged.get("heat", 0)), int(incoming.get("heat", 0)))
	merged["saturation"] = maxi(int(merged.get("saturation", 0)), int(incoming.get("saturation", 0)))
	merged["strain"] = maxi(int(merged.get("strain", 0)), int(incoming.get("strain", 0)))
	merged["cooling_tags"] = _merge_arrays(_string_array(merged.get("cooling_tags", [])), _string_array(incoming.get("cooling_tags", [])))
	merged["source_id"] = str(incoming.get("source_id", merged.get("source_id", merged.get("family_id", "")))).strip_edges()
	merged["cooldown_band"] = str(incoming.get("cooldown_band", merged.get("cooldown_band", "open"))).strip_edges()
	merged["successor_hint"] = str(incoming.get("successor_hint", merged.get("successor_hint", ""))).strip_edges()
	merged["return_window"] = str(incoming.get("return_window", merged.get("return_window", ""))).strip_edges()
	merged["routing_tags"] = _merge_arrays(_string_array(merged.get("routing_tags", [])), _string_array(incoming.get("routing_tags", [])))
	merged["dominance_strain"] = maxi(int(merged.get("dominance_strain", 0)), int(incoming.get("dominance_strain", 0)))
	merged["throttle_state"] = str(incoming.get("throttle_state", merged.get("throttle_state", "open"))).strip_edges()
	merged["resurrection_priority"] = maxi(int(merged.get("resurrection_priority", 0)), int(incoming.get("resurrection_priority", 0)))
	return merged

static func _normalize_phase6_lifecycle_family(raw: Dictionary) -> Dictionary:
	var family := Dictionary(raw).duplicate(true)
	family["family_id"] = str(family.get("family_id", "")).strip_edges()
	family["family_kind"] = str(family.get("family_kind", "market")).strip_edges()
	family["state"] = str(family.get("state", "emerging")).strip_edges()
	family["heat"] = clampi(int(family.get("heat", 0)), 0, 8)
	family["saturation"] = clampi(int(family.get("saturation", 0)), 0, 8)
	family["strain"] = clampi(int(family.get("strain", 0)), 0, 8)
	family["cooling_tags"] = _string_array(family.get("cooling_tags", []))
	family["source_id"] = str(family.get("source_id", family.get("family_id", ""))).strip_edges()
	family["cooldown_band"] = str(family.get("cooldown_band", _cooldown_band_for_family(int(family.get("heat", 0)), int(family.get("saturation", 0)), str(family.get("state", "emerging")), str(family.get("family_kind", "market"))))).strip_edges()
	family["successor_hint"] = str(family.get("successor_hint", "")).strip_edges()
	family["return_window"] = str(family.get("return_window", "near_horizon")).strip_edges()
	family["routing_tags"] = _string_array(family.get("routing_tags", []))
	family["dominance_strain"] = clampi(int(family.get("dominance_strain", family.get("strain", 0))), 0, 8)
	family["throttle_state"] = str(family.get("throttle_state", "open")).strip_edges()
	if family["throttle_state"].is_empty():
		family["throttle_state"] = "open"
	family["resurrection_priority"] = clampi(int(family.get("resurrection_priority", 0)), 0, 4)
	return family

static func _lifecycle_family_kinds(lifecycle_registry: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for family_raw in Array(lifecycle_registry.get("families", [])):
		var family_kind := str(Dictionary(family_raw).get("family_kind", "")).strip_edges()
		if not family_kind.is_empty() and not result.has(family_kind):
			result.append(family_kind)
	return result

static func _active_lifecycle_state_ids(families: Array) -> Array[String]:
	var result: Array[String] = []
	for family_raw in families:
		var family_id := str(Dictionary(family_raw).get("family_id", "")).strip_edges()
		if not family_id.is_empty() and not result.has(family_id):
			result.append(family_id)
	return result.slice(0, 12)

static func _cooldown_band_for_family(heat: int, saturation: int, state: String, family_kind: String) -> String:
	if state == "cooling":
		return "cooling"
	if heat >= 6 or saturation >= 5:
		return "deep_cooling"
	if family_kind in ["combo_family", "artifact_continuity"] and heat >= 3:
		return "warming"
	if heat >= 3:
		return "watchful"
	return "open"

static func _market_family_routing_tags(regime_id: String, market_regime_state: Dictionary, market_memory_state: Dictionary) -> Array[String]:
	var tags := [regime_id]
	if str(market_regime_state.get("carrier_risk_band", "")).strip_edges().find("high") != -1:
		tags.append("artifact_custody")
	if int(market_memory_state.get("recovery_credit", 0)) >= int(market_memory_state.get("extraction_debt", 0)):
		tags.append("return")
	if int(market_memory_state.get("hoard_heat", 0)) >= 2:
		tags.append("scarcity")
	return _string_array(tags)

static func _combo_lifecycle_families(world_model: Dictionary) -> Array[Dictionary]:
	var counts := {}
	var routing_index := {}
	for run_raw in Array(world_model.get("recent_runs", [])):
		var run_record: Dictionary = Dictionary(run_raw)
		var diagnostics: Dictionary = Dictionary(run_record.get("diagnostics", {}))
		var combo_family_ids := _string_array(diagnostics.get("combo_family_ids", []))
		var routing_tags := _merge_arrays(
			_string_array(run_record.get("combo_pressure_tags", [])),
			_string_array(run_record.get("combo_public_surface_tags", []))
		)
		var gameplay_snapshot: Dictionary = Dictionary(run_record.get("gameplay_signal_snapshot", {}))
		for peer_model_raw in Dictionary(gameplay_snapshot.get("peer_models", {})).values():
			var peer_model: Dictionary = Dictionary(peer_model_raw)
			combo_family_ids = _merge_arrays(combo_family_ids, _string_array(peer_model.get("combo_family_ids", [])))
			routing_tags = _merge_arrays(routing_tags, _string_array(peer_model.get("combo_pressure_tags", [])))
			routing_tags = _merge_arrays(routing_tags, _string_array(peer_model.get("public_surface_tags", [])))
		for family_id in combo_family_ids:
			counts[family_id] = int(counts.get(family_id, 0)) + 1
			routing_index[family_id] = _merge_arrays(_string_array(routing_index.get(family_id, [])), routing_tags)
	var families: Array[Dictionary] = []
	for family_id_variant in counts.keys():
		var family_id := str(family_id_variant).strip_edges()
		if family_id.is_empty():
			continue
		var count := int(counts.get(family_id, 0))
		var routing_tags := _string_array(routing_index.get(family_id, []))
		var heat := clampi(count + maxi(int(routing_tags.size() / 2), 1), 0, 8)
		var saturation := clampi(count, 0, 8)
		var state := "saturated" if heat >= 6 else ("active" if heat >= 3 else "cooling")
		families.append(_normalize_phase6_lifecycle_family({
			"family_id": family_id,
			"family_kind": "combo_family",
			"source_id": family_id,
			"state": state,
			"heat": heat,
			"saturation": saturation,
			"strain": clampi(maxi(count - 1, routing_tags.size() - 2), 0, 8),
			"cooling_tags": ["combo_repeat", "build_memory"],
			"cooldown_band": _cooldown_band_for_family(heat, saturation, state, "combo_family"),
			"successor_hint": "%s_successor" % family_id,
			"return_window": "near_horizon",
			"routing_tags": _merge_arrays(["route_choice", "build_memory"], routing_tags),
			"dominance_strain": clampi(count + maxi(routing_tags.size() - 1, 0), 0, 8),
			"throttle_state": "cooling" if heat >= 6 else "open",
			"resurrection_priority": clampi(4 - mini(count, 3), 0, 4)
		}))
	return families

static func _artifact_continuity_lifecycle_families(world_model: Dictionary) -> Array[Dictionary]:
	var counts := {}
	var routing_index := {}
	for run_raw in Array(world_model.get("recent_runs", [])):
		var run_record: Dictionary = Dictionary(run_raw)
		var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
		var continuity_state := str(outcome_summary.get("artifact_continuity_state", "")).strip_edges()
		if continuity_state.is_empty():
			continue
		var family_id := "artifact_continuity_%s" % continuity_state
		counts[family_id] = int(counts.get(family_id, 0)) + 1
		var routing_tags := ["artifact_custody", "return", continuity_state]
		var market_regime_id := str(outcome_summary.get("market_regime_id", "")).strip_edges()
		if not market_regime_id.is_empty():
			routing_tags.append(market_regime_id)
		routing_index[family_id] = _merge_arrays(_string_array(routing_index.get(family_id, [])), routing_tags)
	var families: Array[Dictionary] = []
	for family_id_variant in counts.keys():
		var family_id := str(family_id_variant).strip_edges()
		if family_id.is_empty():
			continue
		var count := int(counts.get(family_id, 0))
		var continuity_state := family_id.trim_prefix("artifact_continuity_")
		var routing_tags := _string_array(routing_index.get(family_id, []))
		var heat := clampi(count + 1, 0, 8)
		var saturation := clampi(count - 1, 0, 8)
		var state := "active" if count >= 2 else "cooling"
		families.append(_normalize_phase6_lifecycle_family({
			"family_id": family_id,
			"family_kind": "artifact_continuity",
			"source_id": continuity_state,
			"state": state,
			"heat": heat,
			"saturation": saturation,
			"strain": clampi(routing_tags.size() - 1, 0, 8),
			"cooling_tags": ["return_window", "custody_memory"],
			"cooldown_band": _cooldown_band_for_family(heat, saturation, state, "artifact_continuity"),
			"successor_hint": _artifact_continuity_successor_hint(continuity_state),
			"return_window": "mid_horizon" if continuity_state in ["burial", "archive_only_residue"] else "near_horizon",
			"routing_tags": routing_tags,
			"dominance_strain": clampi(count + routing_tags.size() - 1, 0, 8),
			"throttle_state": "cooling" if count >= 2 else "open",
			"resurrection_priority": clampi(count + 1, 0, 4)
		}))
	return families

static func _artifact_continuity_successor_hint(continuity_state: String) -> String:
	match continuity_state:
		"burial":
			return "artifact_recovery_weave"
		"recoverable_loss":
			return "artifact_return_window"
		"successor_emergence":
			return "artifact_successor_line"
		"archive_only_residue":
			return "artifact_archive_echo"
		"extinction":
			return "artifact_memory_only"
		_:
			return "artifact_continuity_return"

static func _build_lifecycle_routing(lifecycle_registry: Dictionary) -> Dictionary:
	var families: Array[Dictionary] = []
	var routing_tags: Array[String] = []
	var cooling_family_ids: Array[String] = []
	for family_raw in Array(lifecycle_registry.get("families", [])):
		var family := _normalize_phase6_lifecycle_family(Dictionary(family_raw))
		families.append({
			"family_id": str(family.get("family_id", "")).strip_edges(),
			"family_kind": str(family.get("family_kind", "")).strip_edges(),
			"source_id": str(family.get("source_id", family.get("family_id", ""))).strip_edges(),
			"heat": int(family.get("heat", 0)),
			"cooldown_band": str(family.get("cooldown_band", "open")).strip_edges(),
			"successor_hint": str(family.get("successor_hint", "")).strip_edges(),
			"routing_tags": _string_array(family.get("routing_tags", []))
		})
		routing_tags = _merge_arrays(routing_tags, _string_array(family.get("routing_tags", [])))
		if str(family.get("cooldown_band", "")).strip_edges() in ["cooling", "deep_cooling", "warming"]:
			cooling_family_ids.append(str(family.get("family_id", "")).strip_edges())
	var top_family: Dictionary = Dictionary(families[0]) if not families.is_empty() else {}
	return {
		"families": families.slice(0, 8),
		"active_family_ids": _active_lifecycle_state_ids(families),
		"cooling_family_ids": _string_array(cooling_family_ids),
		"routing_tags": routing_tags.slice(0, 8),
		"top_family_id": str(top_family.get("family_id", "")).strip_edges(),
		"top_successor_hint": str(top_family.get("successor_hint", "")).strip_edges(),
		"top_cooldown_band": str(top_family.get("cooldown_band", "open")).strip_edges(),
		"top_routing_tags": _string_array(top_family.get("routing_tags", []))
	}

static func _build_market_routing(generation_surface: Dictionary, market_regime_state: Dictionary, market_memory_state: Dictionary, lifecycle_registry: Dictionary) -> Dictionary:
	var current := Dictionary(generation_surface.get("market_routing", {})).duplicate(true)
	current["market_volatility"] = int(current.get("market_volatility", 0))
	current["prestige_pressure"] = int(current.get("prestige_pressure", 0))
	current["hoard_visibility"] = int(current.get("hoard_visibility", 0))
	current["scarcity_recovery"] = int(current.get("scarcity_recovery", 0))
	current["carrier_risk_bias"] = int(current.get("carrier_risk_bias", 0))
	current["extraction_debt"] = int(market_memory_state.get("extraction_debt", 0))
	current["hoard_heat"] = int(market_memory_state.get("hoard_heat", 0))
	current["neglect_heat"] = int(market_memory_state.get("neglect_heat", 0))
	current["distortion_heat"] = int(market_memory_state.get("distortion_heat", 0))
	current["recovery_credit"] = int(market_memory_state.get("recovery_credit", 0))
	current["prestige_climate"] = str(market_memory_state.get("prestige_climate", "")).strip_edges()
	current["carrier_risk_band"] = str(market_regime_state.get("carrier_risk_band", "")).strip_edges()
	current["active_regime_ids"] = _string_array(market_regime_state.get("active_regime_ids", []))
	current["lifecycle_state_ids"] = _string_array(lifecycle_registry.get("active_state_ids", []))
	current["market_lines"] = _string_array(market_regime_state.get("summary_lines", []))
	current["lifecycle_lines"] = _string_array(lifecycle_registry.get("lines", []))
	return current

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

static func _apply_phase3_public_summary(summary: Dictionary, market_regime_state: Dictionary, lifecycle_registry: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	next["active_regime_ids"] = _string_array(market_regime_state.get("active_regime_ids", []))
	next["lifecycle_state_ids"] = _string_array(lifecycle_registry.get("active_state_ids", []))
	next["market_regime_lines"] = _string_array(market_regime_state.get("summary_lines", []))
	next["lifecycle_lines"] = _string_array(lifecycle_registry.get("lines", []))
	next["market_regime_id"] = str(market_regime_state.get("regime_id", "")).strip_edges()
	next["market_regime_family"] = str(market_regime_state.get("regime_family", "")).strip_edges()
	next["market_prestige_band"] = str(market_regime_state.get("prestige_band", "")).strip_edges()
	next["market_carrier_risk_band"] = str(market_regime_state.get("carrier_risk_band", "")).strip_edges()
	return next

static func _build_encounter_language_profile(generation_surface: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"schema_name": "EncounterLanguageProfile",
		"schema_version": 2,
		"intent_taxonomy": [
			{"intent_id": "pursuit", "anchor_category": "route_pressure"},
			{"intent_id": "interdiction", "anchor_category": "custody_pressure"},
			{"intent_id": "displacement", "anchor_category": "regroup_pressure"},
			{"intent_id": "attrition", "anchor_category": "burden_pressure"},
			{"intent_id": "exposure", "anchor_category": "evidence_pressure"},
			{"intent_id": "custody_break", "anchor_category": "custody_pressure"},
			{"intent_id": "rescue_inversion", "anchor_category": "regroup_pressure"},
			{"intent_id": "contamination", "anchor_category": "evidence_pressure"},
			{"intent_id": "siege", "anchor_category": "extraction_pressure"},
			{"intent_id": "suppression", "anchor_category": "evidence_pressure"}
		],
		"topology_taxonomy": [
			{"topology_id": "corridor_chase", "room_tags": ["traversal", "hazard"]},
			{"topology_id": "threshold_hold", "room_tags": ["evidence", "hazard"]},
			{"topology_id": "chamber_squeeze", "room_tags": ["hazard", "evidence"]},
			{"topology_id": "carrier_intercept", "room_tags": ["traversal", "hazard"]},
			{"topology_id": "split_room", "room_tags": ["traversal", "evidence"]},
			{"topology_id": "relay_defense", "room_tags": ["traversal", "evidence"]},
			{"topology_id": "moving_front", "room_tags": ["traversal", "hazard"]},
			{"topology_id": "ambush_pocket", "room_tags": ["hazard"]},
			{"topology_id": "pack_surround", "room_tags": ["hazard", "traversal"]},
			{"topology_id": "extraction_lane", "room_tags": ["traversal", "hazard"]}
		],
		"role_vectors": ["carrier", "escort", "witness", "breaker", "decoy", "rescuer", "suppressor", "recoverer"],
		"state_flow": ["foreshadow", "telegraph", "commit", "contest", "resolve", "residue"],
		"consequence_classes": [
			"health_loss",
			"stability_loss",
			"route_displacement",
			"custody_disruption",
			"evidence_exposure",
			"resource_drain",
			"pathology_spread",
			"noise_witness_generation",
			"regroup_pressure",
			"aftermath_seed"
		],
		"expedition_pressure_categories": _encounter_anchor_categories(),
		"readability_contract": {
			"expedition_anchor_required": true,
			"no_hidden_targeting_required": true,
			"detached_genre_forbidden": true
		},
		"summary_lines": _merge_arrays(
			[
				"Encounters remain anchored to expedition pressure instead of detached action scoring.",
				"Ecology escalation stays legible through telegraph and consequence class."
			],
			_string_array(public_summary.get("encounter_lines", []))
		).slice(0, 3),
		"pacing_profile": str(generation_surface.get("pacing_profile", public_summary.get("pacing_profile", ""))).strip_edges()
	}

static func _build_pathology_profile(market_regime_state: Dictionary, _public_summary: Dictionary) -> Dictionary:
	var regime_ids := _string_array(market_regime_state.get("active_regime_ids", []))
	return {
		"schema_name": "PathologyProfile",
		"schema_version": 2,
		"families": [
			{
				"family_id": "pathology_haunt_pressure",
				"spread_mode": "echo pursuit",
				"adaptation_tags": ["artifact_focus", "route_focus"],
				"suppression_tags": ["escort_cover", "recovery_geometry"],
				"recurrence_affinity": "steady",
				"regime_affinity": regime_ids.duplicate(),
				"public_signals": ["ghost pressure", "artifact watched"],
				"linked_species_ids": ["ghost"],
				"encounter_ids": ["enc_ghost_corridor_pursuit"]
			},
			{
				"family_id": "pathology_predator_pack",
				"spread_mode": "carrier intercept",
				"adaptation_tags": ["burden_focus", "room_isolation"],
				"suppression_tags": ["escort_rotation", "regroup_cover"],
				"recurrence_affinity": "elevated",
				"regime_affinity": regime_ids.duplicate(),
				"public_signals": ["predator rush", "predator marked"],
				"linked_species_ids": ["predator"],
				"encounter_ids": ["enc_predator_carrier_intercept", "enc_predator_pack_surround"]
			},
			{
				"family_id": "pathology_protocol_interdiction",
				"spread_mode": "witness clamp",
				"adaptation_tags": ["inspection_focus", "custody_pressure"],
				"suppression_tags": ["clean relay", "quiet regroup"],
				"recurrence_affinity": "steady",
				"regime_affinity": regime_ids.duplicate(),
				"public_signals": ["protocol sweep", "protocol watched"],
				"linked_species_ids": ["protocol_watch"],
				"encounter_ids": ["enc_protocol_threshold_hold", "enc_protocol_extraction_interdict"]
			},
			{
				"family_id": "pathology_echo_lure",
				"spread_mode": "echo displacement",
				"adaptation_tags": ["misdirection", "split attention"],
				"suppression_tags": ["counter_reading", "stable route"],
				"recurrence_affinity": "elevated",
				"regime_affinity": regime_ids.duplicate(),
				"public_signals": ["echo lure", "echo pressure"],
				"linked_species_ids": ["echo_lure"],
				"encounter_ids": ["enc_echo_split_displacement"]
			}
		]
	}

static func _build_pathology_state(pathology_profile: Dictionary, market_regime_state: Dictionary) -> Dictionary:
	var regime_ids := _string_array(market_regime_state.get("active_regime_ids", []))
	var active_family_ids: Array[String] = []
	for family_raw in Array(pathology_profile.get("families", [])):
		var family := Dictionary(family_raw)
		var family_id := str(family.get("family_id", "")).strip_edges()
		if family_id.is_empty():
			continue
		if active_family_ids.size() < 2 or regime_ids.has("market_distortion_spike") or family_id == "pathology_protocol_interdiction":
			active_family_ids.append(family_id)
	return {
		"schema_name": "PathologyState",
		"schema_version": 2,
		"active_family_ids": active_family_ids,
		"spread_heat": clampi(active_family_ids.size(), 0, 8),
		"remission_state": "watchful" if not active_family_ids.is_empty() else "contained",
		"recurrence_heat": active_family_ids.size(),
		"suppression_state": "watchful",
		"mutation_tags": active_family_ids.duplicate(),
		"summary_lines": [
			"Pathology pressure is being routed through live ecology instead of detached combat layers."
		]
	}

static func _build_encounter_manifest(pathology_profile: Dictionary, encounter_language_profile: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var pressure_verbs := _string_array(generation_surface.get("pressure_verbs", []))
	var pacing_profile := str(generation_surface.get("pacing_profile", "")).strip_edges()
	var encounters: Array[Dictionary] = [
		{
			"encounter_id": "enc_ghost_corridor_pursuit",
			"species_id": "ghost",
			"mode_ids": ["pursuit"],
			"intent_id": "pursuit",
			"topology_id": "corridor_chase",
			"anchored_pressures": ["route_pressure", "extraction_pressure"],
			"local_aftermath_tags": ["route_residue", "extraction_residue"],
			"world_aftermath_tags": ["return_pressure", "residue_record"],
			"role_vectors": ["carrier", "escort", "decoy"],
			"telegraph_channels": ["position_shadow", "noise_trace", "hazard_pulse"],
			"consequence_classes": ["route_displacement", "stability_loss", "aftermath_seed"],
			"pathology_family_ids": ["pathology_haunt_pressure"],
			"state_flow": Array(encounter_language_profile.get("state_flow", [])).duplicate(true),
			"room_tags": ["traversal", "hazard"],
			"hazard_tags": ["none", "push", "collapse"],
			"fairness_bounds": {"expedition_anchor_required": true, "no_hidden_targeting_required": true, "detached_genre_forbidden": true},
			"public_trace_class": "pressure_ecology",
			"private_trace_class": "escalation",
			"summary_lines": ["Ghost pursuit is pulling the route toward extraction pressure."]
		},
		{
			"encounter_id": "enc_predator_carrier_intercept",
			"species_id": "predator",
			"mode_ids": ["pursuit", "ambush"],
			"intent_id": "interdiction",
			"topology_id": "carrier_intercept",
			"anchored_pressures": ["custody_pressure", "burden_pressure"],
			"local_aftermath_tags": ["custody_residue", "burden_strain"],
			"world_aftermath_tags": ["successor_claim", "world_mutation"],
			"role_vectors": ["carrier", "escort", "breaker"],
			"telegraph_channels": ["hazard_pulse", "position_shadow"],
			"consequence_classes": ["custody_disruption", "stability_loss", "resource_drain"],
			"pathology_family_ids": ["pathology_predator_pack"],
			"state_flow": Array(encounter_language_profile.get("state_flow", [])).duplicate(true),
			"room_tags": ["traversal", "hazard"],
			"hazard_tags": ["none", "push", "collapse"],
			"fairness_bounds": {"expedition_anchor_required": true, "no_hidden_targeting_required": true, "detached_genre_forbidden": true},
			"public_trace_class": "pressure_ecology",
			"private_trace_class": "escalation",
			"summary_lines": ["Predator intercept is testing who can carry through pressure."]
		},
		{
			"encounter_id": "enc_predator_pack_surround",
			"species_id": "predator",
			"mode_ids": ["pack"],
			"intent_id": "suppression",
			"topology_id": "pack_surround",
			"anchored_pressures": ["regroup_pressure", "burden_pressure"],
			"local_aftermath_tags": ["regroup_pressure", "burden_strain"],
			"world_aftermath_tags": ["world_mutation", "return_pressure"],
			"role_vectors": ["carrier", "escort", "decoy", "rescuer"],
			"telegraph_channels": ["hazard_pulse", "noise_trace"],
			"consequence_classes": ["route_displacement", "pathology_spread", "regroup_pressure"],
			"pathology_family_ids": ["pathology_predator_pack"],
			"state_flow": Array(encounter_language_profile.get("state_flow", [])).duplicate(true),
			"room_tags": ["hazard", "traversal"],
			"hazard_tags": ["push", "spikes", "collapse"],
			"fairness_bounds": {"expedition_anchor_required": true, "no_hidden_targeting_required": true, "detached_genre_forbidden": true},
			"public_trace_class": "pressure_ecology",
			"private_trace_class": "escalation",
			"summary_lines": ["Predator pack pressure is forcing regroup decisions under load."]
		},
		{
			"encounter_id": "enc_protocol_threshold_hold",
			"species_id": "protocol_watch",
			"mode_ids": ["inspection", "containment"],
			"intent_id": "suppression",
			"topology_id": "threshold_hold",
			"anchored_pressures": ["evidence_pressure", "custody_pressure"],
			"local_aftermath_tags": ["evidence_exposure", "custody_residue"],
			"world_aftermath_tags": ["institutional_response", "successor_claim"],
			"role_vectors": ["carrier", "witness", "breaker", "recoverer"],
			"telegraph_channels": ["noise_trace", "hazard_pulse"],
			"consequence_classes": ["evidence_exposure", "route_displacement", "resource_drain"],
			"pathology_family_ids": ["pathology_protocol_interdiction"],
			"state_flow": Array(encounter_language_profile.get("state_flow", [])).duplicate(true),
			"room_tags": ["evidence", "hazard"],
			"hazard_tags": ["none", "collapse", "spikes"],
			"fairness_bounds": {"expedition_anchor_required": true, "no_hidden_targeting_required": true, "detached_genre_forbidden": true},
			"public_trace_class": "pressure_ecology",
			"private_trace_class": "escalation",
			"summary_lines": ["Protocol watch is turning the threshold into a public answer test."]
		},
		{
			"encounter_id": "enc_protocol_extraction_interdict",
			"species_id": "protocol_watch",
			"mode_ids": ["interdiction"],
			"intent_id": "interdiction",
			"topology_id": "extraction_lane",
			"anchored_pressures": ["extraction_pressure", "custody_pressure"],
			"local_aftermath_tags": ["extraction_residue", "custody_residue"],
			"world_aftermath_tags": ["return_pressure", "institutional_response"],
			"role_vectors": ["carrier", "escort", "rescuer", "suppressor"],
			"telegraph_channels": ["hazard_pulse", "noise_trace"],
			"consequence_classes": ["custody_disruption", "regroup_pressure", "aftermath_seed"],
			"pathology_family_ids": ["pathology_protocol_interdiction"],
			"state_flow": Array(encounter_language_profile.get("state_flow", [])).duplicate(true),
			"room_tags": ["traversal", "hazard"],
			"hazard_tags": ["none", "push", "collapse"],
			"fairness_bounds": {"expedition_anchor_required": true, "no_hidden_targeting_required": true, "detached_genre_forbidden": true},
			"public_trace_class": "pressure_ecology",
			"private_trace_class": "escalation",
			"summary_lines": ["Protocol interdiction is tightening the extraction lane."]
		},
		{
			"encounter_id": "enc_echo_split_displacement",
			"species_id": "echo_lure",
			"mode_ids": ["lure", "anomaly_echo"],
			"intent_id": "displacement",
			"topology_id": "split_room",
			"anchored_pressures": ["route_pressure", "regroup_pressure"],
			"local_aftermath_tags": ["route_residue", "regroup_pressure"],
			"world_aftermath_tags": ["world_mutation", "residue_record"],
			"role_vectors": ["decoy", "recoverer", "escort"],
			"telegraph_channels": ["noise_trace", "hazard_pulse"],
			"consequence_classes": ["route_displacement", "noise_witness_generation", "pathology_spread"],
			"pathology_family_ids": ["pathology_echo_lure"],
			"state_flow": Array(encounter_language_profile.get("state_flow", [])).duplicate(true),
			"room_tags": ["traversal", "evidence"],
			"hazard_tags": ["none", "push"],
			"fairness_bounds": {"expedition_anchor_required": true, "no_hidden_targeting_required": true, "detached_genre_forbidden": true},
			"public_trace_class": "pressure_ecology",
			"private_trace_class": "escalation",
			"summary_lines": ["Echo lure pressure is splitting the route into false answers."]
		}
	]
	for i in range(encounters.size()):
		var encounter := Dictionary(encounters[i]).duplicate(true)
		encounter["encounter_apex_consequence_version"] = ENCOUNTER_APEX_CONSEQUENCE_VERSION
		encounter["local_aftermath_tags"] = _merge_arrays(
			_encounter_local_aftermath_tags(encounter),
			_string_array(encounter.get("local_aftermath_tags", []))
		).slice(0, 4)
		encounter["world_aftermath_tags"] = _merge_arrays(
			_encounter_world_aftermath_tags(encounter),
			_string_array(encounter.get("world_aftermath_tags", []))
		).slice(0, 4)
		encounters[i] = encounter
	var summary_lines: Array[String] = []
	for encounter_raw in encounters:
		summary_lines = _merge_arrays(summary_lines, _string_array(Dictionary(encounter_raw).get("summary_lines", [])))
	for family_raw in Array(pathology_profile.get("families", [])):
		summary_lines = _merge_arrays(summary_lines, _string_array(Dictionary(family_raw).get("public_signals", [])))
	if not pressure_verbs.is_empty():
		summary_lines = _merge_arrays(summary_lines, ["Pressure verbs shaping encounters: %s." % ", ".join(pressure_verbs.slice(0, 3))])
	if not pacing_profile.is_empty():
		summary_lines = _merge_arrays(summary_lines, ["Encounter pacing is being read through %s." % pacing_profile.replace("_", " ")])
	return {
		"schema_name": "EncounterManifest",
		"schema_version": 2,
		"encounter_apex_consequence_version": ENCOUNTER_APEX_CONSEQUENCE_VERSION,
		"encounters": encounters,
		"summary_lines": summary_lines.slice(0, 3)
	}

static func _build_encounter_routing(generation_surface: Dictionary, encounter_manifest: Dictionary, pathology_state: Dictionary) -> Dictionary:
	var current := Dictionary(generation_surface.get("encounter_routing", {})).duplicate(true)
	current["active_pathology_ids"] = _string_array(pathology_state.get("active_family_ids", []))
	current["encounter_manifest_ids"] = _encounter_manifest_ids(encounter_manifest)
	current["encounter_intent_ids"] = _encounter_intent_ids(encounter_manifest)
	current["encounter_topology_ids"] = _encounter_topology_ids(encounter_manifest)
	current["anchored_pressures"] = _encounter_anchor_coverage(encounter_manifest)
	current["encounter_lines"] = _string_array(encounter_manifest.get("summary_lines", []))
	current["pathology_lines"] = _string_array(pathology_state.get("summary_lines", []))
	current["branch_family"] = str(generation_surface.get("branch_family", "")).strip_edges()
	return current

static func _apply_phase4_public_summary(summary: Dictionary, encounter_manifest: Dictionary, pathology_state: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	next["active_pathology_ids"] = _string_array(pathology_state.get("active_family_ids", []))
	next["pathology_lines"] = _string_array(pathology_state.get("summary_lines", []))
	next["encounter_lines"] = _string_array(encounter_manifest.get("summary_lines", []))
	next["encounter_manifest_ids"] = _encounter_manifest_ids(encounter_manifest)
	next["encounter_intent_ids"] = _encounter_intent_ids(encounter_manifest)
	next["encounter_topology_ids"] = _encounter_topology_ids(encounter_manifest)
	return next

static func _build_apex_framework_profile(encounter_language_profile: Dictionary, encounter_manifest: Dictionary, pathology_profile: Dictionary, generation_surface: Dictionary, public_summary: Dictionary) -> Dictionary:
	var summary_lines := _merge_arrays(
		[
			"Apex pressure escalates encounter language without detaching from expedition logic.",
			"Primary apex resolution remains objective-driven and readable."
		],
		_string_array(public_summary.get("apex_lines", []))
	)
	summary_lines = _merge_arrays(summary_lines, _string_array(encounter_manifest.get("summary_lines", [])))
	for family_raw in Array(pathology_profile.get("families", [])):
		summary_lines = _merge_arrays(summary_lines, _string_array(Dictionary(family_raw).get("public_signals", [])))
	return {
		"schema_name": "ApexFrameworkProfile",
		"schema_version": 2,
		"origin_taxonomy": ["ecology", "pathology", "institution", "market", "hybrid"],
		"function_taxonomy": ["pursuit", "siege", "duel", "burden_break", "interceptor", "packmind", "witness_trial", "extraction_trial"],
		"arena_taxonomy": ["corridor", "chamber_cluster", "threshold_lattice", "moving_route", "carrier_gauntlet", "public_stage"],
		"class_taxonomy": ["pursuit_apex", "siege_apex", "duel_apex", "interceptor_apex", "packmind_apex", "burden_apex", "witness_trial_apex", "extraction_trial_apex", "relay_breaker_apex"],
		"phase_model": ["announce", "shape", "commit", "crisis", "reversal", "resolution", "aftermath"],
		"resolution_set": ["evade", "outlast", "escort_through", "split_and_recover", "bait_and_redirect", "expose", "contain", "appease", "break_route_cleanly", "sacrifice_for_return", "complete_objective_under_pressure"],
		"readability_contract": {
			"announce_required": true,
			"commit_required": true,
			"resolution_required": true,
			"no_hp_sponge_primary_resolution": true,
			"detached_boss_minigame_forbidden": true,
			"expedition_anchor_required": true
		},
		"summary_lines": summary_lines.slice(0, 3),
		"pacing_profile": str(generation_surface.get("pacing_profile", public_summary.get("pacing_profile", ""))).strip_edges(),
		"linked_encounter_count": Array(encounter_manifest.get("encounters", [])).size(),
		"state_flow": Array(encounter_language_profile.get("state_flow", [])).duplicate(true)
	}

static func _build_apex_manifest(apex_framework_profile: Dictionary, encounter_manifest: Dictionary, _pathology_profile: Dictionary, generation_surface: Dictionary, public_summary: Dictionary) -> Dictionary:
	var pacing_profile := str(generation_surface.get("pacing_profile", public_summary.get("pacing_profile", ""))).strip_edges()
	var apexes: Array[Dictionary] = [
		{
			"apex_id": "apex_ghost_threshold_trial",
			"apex_class_id": "witness_trial_apex",
			"species_id": "ghost",
			"linked_encounter_ids": ["enc_ghost_corridor_pursuit"],
			"origin": "ecology",
			"function": "witness_trial",
			"arena": "threshold_lattice",
			"phase_model": Array(apex_framework_profile.get("phase_model", [])).duplicate(true),
			"resolution_classes": ["expose", "contain", "complete_objective_under_pressure"],
			"consequence_strata": ["local_state", "world_memory_state"],
			"telegraph_profile": {"channels": ["hazard_pulse", "noise_trace"], "minimum_readability_floor": 2},
			"anchored_pressures": ["route_pressure", "evidence_pressure"],
			"local_aftermath_tags": ["threshold_residue", "evidence_exposure", "route_pressure"],
			"world_aftermath_tags": ["residue_record", "institutional_response", "continuity_scar"],
			"summary_lines": ["Ghost threshold pressure is forcing the crew to prove the route in public."]
		},
		{
			"apex_id": "apex_predator_packmind",
			"apex_class_id": "packmind_apex",
			"species_id": "predator",
			"linked_encounter_ids": ["enc_predator_pack_surround", "enc_predator_carrier_intercept"],
			"origin": "pathology",
			"function": "packmind",
			"arena": "carrier_gauntlet",
			"phase_model": Array(apex_framework_profile.get("phase_model", [])).duplicate(true),
			"resolution_classes": ["outlast", "bait_and_redirect", "escort_through", "break_route_cleanly"],
			"consequence_strata": ["local_state", "run_state", "world_memory_state"],
			"telegraph_profile": {"channels": ["hazard_pulse", "noise_trace"], "minimum_readability_floor": 2},
			"anchored_pressures": ["custody_pressure", "burden_pressure", "regroup_pressure"],
			"local_aftermath_tags": ["carrier_strain", "pack_residue", "resource_drain"],
			"world_aftermath_tags": ["world_mutation", "prestige_climate_delta", "return_pressure"],
			"summary_lines": ["Predator packmind pressure is converging on the carrier path without detaching from the expedition."]
		},
		{
			"apex_id": "apex_protocol_extraction_trial",
			"apex_class_id": "extraction_trial_apex",
			"species_id": "protocol_watch",
			"linked_encounter_ids": ["enc_protocol_threshold_hold", "enc_protocol_extraction_interdict"],
			"origin": "institution",
			"function": "extraction_trial",
			"arena": "public_stage",
			"phase_model": Array(apex_framework_profile.get("phase_model", [])).duplicate(true),
			"resolution_classes": ["appease", "contain", "complete_objective_under_pressure", "split_and_recover"],
			"consequence_strata": ["local_state", "run_state", "world_memory_state"],
			"telegraph_profile": {"channels": ["hazard_pulse", "noise_trace"], "minimum_readability_floor": 2},
			"anchored_pressures": ["extraction_pressure", "custody_pressure", "evidence_pressure"],
			"local_aftermath_tags": ["public_trace", "custody_residue", "regroup_pressure"],
			"world_aftermath_tags": ["institutional_response", "successor_claim", "residue_record"],
			"summary_lines": ["Protocol extraction pressure is turning the return lane into a readable public trial."]
		}
	]
	for i in range(apexes.size()):
		var apex := Dictionary(apexes[i]).duplicate(true)
		apex["encounter_apex_consequence_version"] = ENCOUNTER_APEX_CONSEQUENCE_VERSION
		apexes[i] = apex
	var summary_lines := _merge_arrays(_string_array(public_summary.get("apex_lines", [])), _string_array(Dictionary(encounter_manifest).get("summary_lines", [])))
	for apex_raw in apexes:
		summary_lines = _merge_arrays(summary_lines, _string_array(Dictionary(apex_raw).get("summary_lines", [])))
	if not pacing_profile.is_empty():
		summary_lines = _merge_arrays(summary_lines, ["Apex pacing is being staged through %s." % pacing_profile.replace("_", " ")])
	return {
		"schema_name": "ApexManifest",
		"schema_version": 2,
		"encounter_apex_consequence_version": ENCOUNTER_APEX_CONSEQUENCE_VERSION,
		"apexes": apexes,
		"summary_lines": summary_lines.slice(0, 3)
	}

static func _build_peak_structure_profile(public_summary: Dictionary, generation_surface: Dictionary, apex_manifest: Dictionary) -> Dictionary:
	var pacing_profile := str(generation_surface.get("pacing_profile", public_summary.get("pacing_profile", ""))).strip_edges()
	var apex_count := Array(apex_manifest.get("apexes", [])).size()
	var summary_lines := _merge_arrays(
		[
			"Peak structure keeps spectacle spaced around readable aftermath.",
			"Apex escalation remains subordinate to burden, custody, and return."
		],
		_string_array(public_summary.get("peak_structure_lines", []))
	)
	return {
		"schema_name": "PeakStructureProfile",
		"schema_version": 2,
		"emotional_band": "charged" if pacing_profile in ["volatile", "escalating"] else "measured",
		"peak_spacing_score": clampi(2 + apex_count, 0, 5),
		"spectacle_window_profile": ["announce_window", "crisis_window", "aftermath_window"],
		"burden_unification_score": clampi(apex_count, 1, 4),
		"summary_lines": summary_lines.slice(0, 3)
	}

static func _build_apex_routing(generation_surface: Dictionary, apex_manifest: Dictionary, peak_structure_profile: Dictionary) -> Dictionary:
	var current := Dictionary(generation_surface.get("apex_routing", {})).duplicate(true)
	current["apex_manifest_ids"] = _apex_manifest_ids(apex_manifest)
	current["apex_class_ids"] = _apex_class_ids(apex_manifest)
	current["apex_lines"] = _string_array(apex_manifest.get("summary_lines", []))
	current["peak_structure_lines"] = _string_array(peak_structure_profile.get("summary_lines", []))
	current["peak_spacing_score"] = int(peak_structure_profile.get("peak_spacing_score", 0))
	current["encounter_apex_consequence_version"] = int(apex_manifest.get("encounter_apex_consequence_version", ENCOUNTER_APEX_CONSEQUENCE_VERSION))
	current["anchored_pressures"] = _apex_anchor_coverage(apex_manifest)
	current["local_aftermath_tags"] = _apex_local_aftermath_coverage(apex_manifest)
	current["world_aftermath_tags"] = _apex_world_aftermath_coverage(apex_manifest)
	current["primary_apex_id"] = _first_string(current.get("apex_manifest_ids", []), "")
	current["branch_family"] = str(generation_surface.get("branch_family", "")).strip_edges()
	return current

static func _apply_phase5_public_summary(summary: Dictionary, apex_manifest: Dictionary, peak_structure_profile: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	next["encounter_apex_consequence_version"] = int(apex_manifest.get("encounter_apex_consequence_version", next.get("encounter_apex_consequence_version", ENCOUNTER_APEX_CONSEQUENCE_VERSION)))
	next["apex_manifest_ids"] = _apex_manifest_ids(apex_manifest)
	next["apex_class_ids"] = _apex_class_ids(apex_manifest)
	next["apex_lines"] = _string_array(apex_manifest.get("summary_lines", []))
	next["peak_structure_lines"] = _string_array(peak_structure_profile.get("summary_lines", []))
	return next

static func _validate_encounter_contracts(bundle: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	var encounter_language_profile: Dictionary = Dictionary(bundle.get("encounter_language_profile", {}))
	var encounter_manifest: Dictionary = Dictionary(bundle.get("encounter_manifest", {}))
	var pathology_profile: Dictionary = Dictionary(bundle.get("pathology_profile", {}))
	var pathology_state: Dictionary = Dictionary(bundle.get("pathology_state", {}))
	var allowed_pressures := _string_array(encounter_language_profile.get("expedition_pressure_categories", _encounter_anchor_categories()))
	if allowed_pressures.is_empty():
		failures.append("encounter language profile must expose expedition pressure categories")
	var active_family_ids := _string_array(pathology_state.get("active_family_ids", []))
	var known_family_ids: Array[String] = []
	for family_raw in Array(pathology_profile.get("families", [])):
		var family := Dictionary(family_raw)
		var family_id := str(family.get("family_id", "")).strip_edges()
		if not family_id.is_empty():
			known_family_ids.append(family_id)
	for family_id in active_family_ids:
		if not known_family_ids.has(family_id):
			failures.append("pathology state references unknown family %s" % family_id)
	for encounter_raw in Array(encounter_manifest.get("encounters", [])):
		var encounter := Dictionary(encounter_raw)
		var encounter_id := str(encounter.get("encounter_id", "")).strip_edges()
		if encounter_id.is_empty():
			failures.append("encounter manifest entries require encounter_id")
			continue
		var anchored_pressures := _string_array(encounter.get("anchored_pressures", []))
		if anchored_pressures.is_empty():
			failures.append("encounter %s must declare anchored_pressures" % encounter_id)
		for pressure_id in anchored_pressures:
			if not allowed_pressures.has(pressure_id):
				failures.append("encounter %s declares invalid anchored pressure %s" % [encounter_id, pressure_id])
		if _string_array(encounter.get("consequence_classes", [])).is_empty():
			failures.append("encounter %s must declare consequence_classes" % encounter_id)
		if _string_array(encounter.get("role_vectors", [])).is_empty():
			failures.append("encounter %s must declare role_vectors" % encounter_id)
		var fairness_bounds := Dictionary(encounter.get("fairness_bounds", {}))
		if not bool(fairness_bounds.get("detached_genre_forbidden", false)):
			failures.append("encounter %s must preserve detached_genre_forbidden" % encounter_id)
	return failures

static func _validate_apex_contracts(bundle: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	var apex_framework_profile: Dictionary = Dictionary(bundle.get("apex_framework_profile", {}))
	var apex_manifest: Dictionary = Dictionary(bundle.get("apex_manifest", {}))
	var class_taxonomy := _string_array(apex_framework_profile.get("class_taxonomy", []))
	var phase_model := _string_array(apex_framework_profile.get("phase_model", []))
	var resolution_set := _string_array(apex_framework_profile.get("resolution_set", []))
	var readability_contract := Dictionary(apex_framework_profile.get("readability_contract", {}))
	if class_taxonomy.is_empty():
		failures.append("apex framework profile must expose class_taxonomy")
	if phase_model.is_empty():
		failures.append("apex framework profile must expose phase_model")
	if resolution_set.is_empty():
		failures.append("apex framework profile must expose resolution_set")
	if not bool(readability_contract.get("detached_boss_minigame_forbidden", false)):
		failures.append("apex framework profile must preserve detached_boss_minigame_forbidden")
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		var apex := Dictionary(apex_raw)
		var apex_id := str(apex.get("apex_id", "")).strip_edges()
		if apex_id.is_empty():
			failures.append("apex manifest entries require apex_id")
			continue
		var apex_class_id := str(apex.get("apex_class_id", "")).strip_edges()
		if apex_class_id.is_empty() or not class_taxonomy.has(apex_class_id):
			failures.append("apex %s must declare apex_class_id from class_taxonomy" % apex_id)
		var linked_encounter_ids := _string_array(apex.get("linked_encounter_ids", []))
		if linked_encounter_ids.is_empty():
			failures.append("apex %s must link back to at least one encounter id" % apex_id)
		var phases := _string_array(apex.get("phase_model", []))
		for required_phase in ["announce", "commit", "resolution", "aftermath"]:
			if not phases.has(required_phase):
				failures.append("apex %s must preserve %s in phase_model" % [apex_id, required_phase])
		var resolutions := _string_array(apex.get("resolution_classes", []))
		if resolutions.is_empty():
			failures.append("apex %s must declare resolution_classes" % apex_id)
		for resolution_id in resolutions:
			if not resolution_set.has(resolution_id):
				failures.append("apex %s declares invalid resolution class %s" % [apex_id, resolution_id])
		if resolutions.size() == 1 and resolutions.has("outlast"):
			failures.append("apex %s must not collapse to a single outlast/HP-sponge resolution" % apex_id)
		var telegraph_profile := Dictionary(apex.get("telegraph_profile", {}))
		if _string_array(telegraph_profile.get("channels", [])).is_empty():
			failures.append("apex %s must declare telegraph_profile channels" % apex_id)
		if _string_array(apex.get("anchored_pressures", [])).is_empty():
			failures.append("apex %s must preserve expedition pressure anchors" % apex_id)
	return failures

static func _validate_phase6_lifecycle_registry(bundle: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	var lifecycle_registry: Dictionary = Dictionary(bundle.get("lifecycle_registry", {}))
	var families := Array(lifecycle_registry.get("families", []))
	if families.is_empty():
		failures.append("lifecycle registry must expose at least one family")
		return failures
	var family_kinds := _lifecycle_family_kinds(lifecycle_registry)
	var has_non_market := false
	for family_raw in families:
		var family := Dictionary(family_raw)
		if not family.has("dominance_strain"):
			failures.append("lifecycle family %s missing dominance_strain" % str(family.get("family_id", "")))
		if not family.has("throttle_state"):
			failures.append("lifecycle family %s missing throttle_state" % str(family.get("family_id", "")))
		if not family.has("resurrection_priority"):
			failures.append("lifecycle family %s missing resurrection_priority" % str(family.get("family_id", "")))
		if str(family.get("family_kind", "market")).strip_edges() != "market":
			has_non_market = true
	var pathology_ids := _string_array(Dictionary(bundle.get("pathology_state", {})).get("active_family_ids", []))
	var encounter_ids := _encounter_manifest_ids(Dictionary(bundle.get("encounter_manifest", {})))
	var apex_ids := _apex_manifest_ids(Dictionary(bundle.get("apex_manifest", {})))
	if (not pathology_ids.is_empty() or not encounter_ids.is_empty() or not apex_ids.is_empty()) and not has_non_market:
		failures.append("expanded lifecycle registry must include non-market family kinds once pathology, encounter, or apex systems are active")
	if not family_kinds.has("market"):
		failures.append("expanded lifecycle registry must preserve market family kinds")
	return failures

static func _encounter_manifest_ids(encounter_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for encounter_raw in Array(encounter_manifest.get("encounters", [])):
		var encounter_id := str(Dictionary(encounter_raw).get("encounter_id", "")).strip_edges()
		if not encounter_id.is_empty() and not ids.has(encounter_id):
			ids.append(encounter_id)
	return ids

static func _encounter_intent_ids(encounter_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for encounter_raw in Array(encounter_manifest.get("encounters", [])):
		var intent_id := str(Dictionary(encounter_raw).get("intent_id", "")).strip_edges()
		if not intent_id.is_empty() and not ids.has(intent_id):
			ids.append(intent_id)
	return ids

static func _encounter_topology_ids(encounter_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for encounter_raw in Array(encounter_manifest.get("encounters", [])):
		var topology_id := str(Dictionary(encounter_raw).get("topology_id", "")).strip_edges()
		if not topology_id.is_empty() and not ids.has(topology_id):
			ids.append(topology_id)
	return ids

static func _encounter_anchor_coverage(encounter_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for encounter_raw in Array(encounter_manifest.get("encounters", [])):
		for pressure_id in _string_array(Dictionary(encounter_raw).get("anchored_pressures", [])):
			if not ids.has(pressure_id):
				ids.append(pressure_id)
	return ids

static func _encounter_local_aftermath_tags(encounter: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	for pressure_id in _string_array(encounter.get("anchored_pressures", [])):
		match pressure_id:
			"route_pressure":
				tags.append("route_residue")
			"custody_pressure":
				tags.append("custody_residue")
			"evidence_pressure":
				tags.append("evidence_exposure")
			"burden_pressure":
				tags.append("burden_strain")
			"regroup_pressure":
				tags.append("regroup_pressure")
			"extraction_pressure":
				tags.append("extraction_residue")
	for consequence_class in _string_array(encounter.get("consequence_classes", [])):
		match consequence_class:
			"resource_drain":
				tags.append("resource_drain")
			"route_displacement":
				tags.append("route_residue")
			"evidence_exposure":
				tags.append("evidence_exposure")
	return _string_array(tags)

static func _encounter_world_aftermath_tags(encounter: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var anchored_pressures := _string_array(encounter.get("anchored_pressures", []))
	var consequence_classes := _string_array(encounter.get("consequence_classes", []))
	if anchored_pressures.has("route_pressure") or anchored_pressures.has("extraction_pressure"):
		tags.append("return_pressure")
	if anchored_pressures.has("custody_pressure") or consequence_classes.has("custody_disruption"):
		tags.append("successor_claim")
	if anchored_pressures.has("evidence_pressure") or consequence_classes.has("evidence_exposure"):
		tags.append("institutional_response")
	if consequence_classes.has("resource_drain") or consequence_classes.has("pathology_spread") or consequence_classes.has("aftermath_seed"):
		tags.append("world_mutation")
	if tags.is_empty():
		tags.append("residue_record")
	return _string_array(tags)

static func _encounter_anchor_categories() -> Array[String]:
	return [
		"custody_pressure",
		"route_pressure",
		"regroup_pressure",
		"extraction_pressure",
		"evidence_pressure",
		"burden_pressure"
	]

static func _apex_manifest_ids(apex_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		var apex_id := str(Dictionary(apex_raw).get("apex_id", "")).strip_edges()
		if not apex_id.is_empty() and not ids.has(apex_id):
			ids.append(apex_id)
	return ids

static func _apex_class_ids(apex_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		var class_id := str(Dictionary(apex_raw).get("apex_class_id", "")).strip_edges()
		if not class_id.is_empty() and not ids.has(class_id):
			ids.append(class_id)
	return ids

static func _apex_resolution_coverage(apex_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		for resolution_id in _string_array(Dictionary(apex_raw).get("resolution_classes", [])):
			if not ids.has(resolution_id):
				ids.append(resolution_id)
	return ids

static func _apex_anchor_coverage(apex_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		for pressure_id in _string_array(Dictionary(apex_raw).get("anchored_pressures", [])):
			if not ids.has(pressure_id):
				ids.append(pressure_id)
	return ids

static func _apex_local_aftermath_coverage(apex_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		for tag in _string_array(Dictionary(apex_raw).get("local_aftermath_tags", [])):
			if not ids.has(tag):
				ids.append(tag)
	return ids

static func _apex_world_aftermath_coverage(apex_manifest: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for apex_raw in Array(apex_manifest.get("apexes", [])):
		for tag in _string_array(Dictionary(apex_raw).get("world_aftermath_tags", [])):
			if not ids.has(tag):
				ids.append(tag)
	return ids

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

static func _ordered_scorecard_ids(scorecard: Dictionary) -> Array[String]:
	var ids := _string_array(scorecard.keys())
	ids.sort_custom(func(a: String, b: String) -> bool:
		var a_score := int(scorecard.get(a, 0))
		var b_score := int(scorecard.get(b, 0))
		if a_score == b_score:
			return a < b
		return a_score > b_score
	)
	return ids

static func _market_band(score: int) -> String:
	if score >= 5:
		return "dominant"
	if score >= 3:
		return "elevated"
	if score >= 1:
		return "steady"
	return "suppressed"

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
