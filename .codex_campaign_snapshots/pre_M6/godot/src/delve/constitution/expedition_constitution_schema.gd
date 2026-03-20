class_name ExpeditionConstitutionSchema
extends RefCounted

const SCHEMA_VERSION := 2
const DELVEMIND_EXPERIMENT_ENGINE_SCRIPT = preload("res://src/product/delvemind_experiment_engine.gd")
const DELVEMIND_LEARNING_LOOP_SCRIPT = preload("res://src/product/delvemind_learning_loop.gd")
const GOVERNANCE_SERVICE_SCRIPT = preload("res://src/product/governance_service.gd")
const CIVILIZATION_STATE_SERVICE_SCRIPT = preload("res://src/product/civilization_state_service.gd")
const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")

static func build(
	seed_value: int,
	room_count: int,
	world_model: Dictionary,
	doctrine: Dictionary,
	policy: Dictionary,
	surface_summary: Dictionary,
	public_doctrine: Dictionary,
	world_goals: Array,
	mind_balance: Dictionary,
	audit: Dictionary,
	run_identity: Dictionary,
	generation_surface: Dictionary,
	compile_outputs: Dictionary = {}
) -> Dictionary:
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", "")).strip_edges()
	var public_summary := build_public_summary(
		protocol_state,
		doctrine,
		public_doctrine,
		surface_summary,
		world_goals,
		generation_surface
	)
	var narrative_pressure_state := Dictionary(compile_outputs.get("narrative_pressure_state", _default_narrative_pressure_state(policy, public_summary, generation_surface))).duplicate(true)
	var experimental_ontology_state := Dictionary(compile_outputs.get("experimental_ontology_state", _default_experimental_ontology_state())).duplicate(true)
	public_summary = _apply_narrative_pressure_summary(public_summary, narrative_pressure_state)
	public_summary = _apply_experimental_summary(public_summary, experimental_ontology_state)
	var lineage_registry := Dictionary(compile_outputs.get("lineage_registry", {})).duplicate(true)
	var civilization_surface := _normalize_civilization_surface(
		Dictionary(
			compile_outputs.get(
				"civilization_surface",
				CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(Dictionary(world_model.get("world_memory_snapshot", world_model.get("world_memory", {}))))
			)
		)
	)
	var cognitive_field_state := _normalize_cognitive_field_state(Dictionary(compile_outputs.get("cognitive_field_state", {})))
	var mind_projections := _normalize_mind_projections(Array(compile_outputs.get("mind_projections", [])))
	var theory_surface := _normalize_theory_surface(Dictionary(compile_outputs.get("theory_surface", {})))
	var market_regime_state := _normalize_market_regime_state(Dictionary(compile_outputs.get("market_regime_state", {})))
	var market_memory_state := _normalize_market_memory_state(Dictionary(compile_outputs.get("market_memory_state", {})))
	var lifecycle_registry := _normalize_lifecycle_registry(Dictionary(compile_outputs.get("lifecycle_registry", {})))
	var encounter_language_profile := _normalize_encounter_language_profile(Dictionary(compile_outputs.get("encounter_language_profile", {})))
	var pathology_profile := _normalize_pathology_profile(Dictionary(compile_outputs.get("pathology_profile", {})))
	var pathology_state := _normalize_pathology_state(Dictionary(compile_outputs.get("pathology_state", {})))
	var encounter_manifest := _normalize_encounter_manifest(Dictionary(compile_outputs.get("encounter_manifest", {})))
	var creative_governance := _normalize_creative_governance(Dictionary(compile_outputs.get("creative_governance", Dictionary(experimental_ontology_state.get("creative_governance", {})))))
	var apex_framework_profile := _normalize_apex_framework_profile(Dictionary(compile_outputs.get("apex_framework_profile", {})))
	var apex_manifest := _normalize_apex_manifest(Dictionary(compile_outputs.get("apex_manifest", {})))
	var peak_structure_profile := _normalize_peak_structure_profile(Dictionary(compile_outputs.get("peak_structure_profile", {})))
	var activation_state := GOVERNANCE_SERVICE_SCRIPT.normalize_activation_state(Dictionary(compile_outputs.get("activation_state", {})))
	var explanation_packet := _normalize_explanation_packet(Dictionary(compile_outputs.get("explanation_packet", {})))
	var review_surface := _normalize_review_surface(Dictionary(compile_outputs.get("review_surface", {})))
	public_summary = _apply_phase_v3_summary(
		public_summary,
		lineage_registry,
		civilization_surface,
		cognitive_field_state,
		mind_projections,
		theory_surface,
		activation_state,
		explanation_packet,
		review_surface
	)
	public_summary = _apply_phase3_market_summary(public_summary, market_regime_state, lifecycle_registry)
	public_summary = _apply_phase4_encounter_summary(public_summary, encounter_manifest, pathology_state)
	public_summary = _apply_phase5_apex_summary(public_summary, apex_manifest, peak_structure_profile)
	var information_doctrine := _build_information_doctrine(policy, public_summary)
	public_summary["provenance_contract_version"] = int(explanation_packet.get("provenance_contract_version", GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION))
	public_summary["public_trace_classes"] = _string_array(information_doctrine.get("public_trace_classes", []))
	public_summary["public_surface_tags"] = _string_array(explanation_packet.get("public_surface_tags", []))
	var constitution_summary := public_summary.duplicate(true)
	constitution_summary["private_trace_classes"] = _string_array(information_doctrine.get("private_trace_classes", []))
	constitution_summary["provenance_source_refs"] = _string_array(explanation_packet.get("provenance_source_refs", []))
	var constitution := {
		"artifact_type": "expedition_constitution",
		"schema_name": "ExpeditionConstitution",
		"schema_version": SCHEMA_VERSION,
		"seed": seed_value,
		"room_count": room_count,
		"protocol_state": protocol_state,
		"doctrine_family_id": str(compile_outputs.get("doctrine_family_id", doctrine.get("id", ""))),
		"doctrine_variant_id": str(compile_outputs.get("doctrine_variant_id", "variant_%s" % str(doctrine.get("id", "")).md5_text().substr(0, 12))),
		"generation_seed": seed_value,
		"identity": {
			"protocol_state": protocol_state,
			"room_count": room_count,
			"world_goal": str(public_summary.get("world_goal", ""))
		},
		"doctrine": doctrine.duplicate(true),
		"control_surfaces": policy.duplicate(true),
		"surface_summary": surface_summary.duplicate(true),
		"public_summary": public_summary.duplicate(true),
		"constitution_summary": constitution_summary.duplicate(true),
		"generation_surface": generation_surface.duplicate(true),
		"generation_contract": generation_surface.duplicate(true),
		"ontology_snapshot": Dictionary(compile_outputs.get("ontology_snapshot", {})).duplicate(true),
		"narrative_pressure_state": narrative_pressure_state.duplicate(true),
		"experimental_ontology_state": experimental_ontology_state.duplicate(true),
		"doctrine_inheritance": Dictionary(compile_outputs.get("doctrine_inheritance", {})).duplicate(true),
		"compiler_trace": Dictionary(compile_outputs.get("compiler_trace", {})).duplicate(true),
		"compile_metadata": Dictionary(compile_outputs.get("compile_metadata", {})).duplicate(true),
		"topology_profile": Dictionary(compile_outputs.get("topology_profile", _default_topology_profile(generation_surface, room_count))).duplicate(true),
		"chamber_grammar_profile": Dictionary(compile_outputs.get("chamber_grammar_profile", _default_chamber_grammar_profile(generation_surface))).duplicate(true),
		"route_profile": Dictionary(compile_outputs.get("route_profile", _default_route_profile(generation_surface))).duplicate(true),
		"item_ecology_profile": Dictionary(compile_outputs.get("item_ecology_profile", _default_item_ecology_profile(public_summary, generation_surface))).duplicate(true),
		"pressure_ecology_profile": Dictionary(compile_outputs.get("pressure_ecology_profile", _default_pressure_ecology_profile(policy, public_summary))).duplicate(true),
		"market_regime_state": market_regime_state.duplicate(true),
		"market_memory_state": market_memory_state.duplicate(true),
		"lifecycle_registry": lifecycle_registry.duplicate(true),
		"encounter_language_profile": encounter_language_profile.duplicate(true),
		"encounter_manifest": encounter_manifest.duplicate(true),
		"pathology_profile": pathology_profile.duplicate(true),
		"pathology_state": pathology_state.duplicate(true),
		"creative_governance": creative_governance.duplicate(true),
		"apex_framework_profile": apex_framework_profile.duplicate(true),
		"apex_manifest": apex_manifest.duplicate(true),
		"peak_structure_profile": peak_structure_profile.duplicate(true),
		"information_doctrine_profile": Dictionary(compile_outputs.get("information_doctrine_profile", _default_information_doctrine_profile(policy, public_summary))).duplicate(true),
		"pacing_profile": Dictionary(compile_outputs.get("pacing_profile", _default_pacing_profile(public_summary, generation_surface))).duplicate(true),
		"custody_profile": Dictionary(compile_outputs.get("custody_profile", _default_custody_profile(public_summary, generation_surface))).duplicate(true),
		"mutation_permissions": Dictionary(compile_outputs.get("mutation_permissions", _default_mutation_permissions(policy))).duplicate(true),
		"symbolic_motifs": Array(compile_outputs.get("symbolic_motifs", public_summary.get("symbolic_motifs", generation_surface.get("symbolic_motifs", [])))).duplicate(true),
		"fairness_bounds": Dictionary(compile_outputs.get("fairness_bounds", _default_fairness_bounds())).duplicate(true),
		"lineage_registry": lineage_registry.duplicate(true),
		"civilization_surface": civilization_surface.duplicate(true),
		"cognitive_field_state": cognitive_field_state.duplicate(true),
		"mind_projections": mind_projections.duplicate(true),
		"theory_surface": theory_surface.duplicate(true),
		"activation_state": activation_state.duplicate(true),
		"explanation_packet": explanation_packet.duplicate(true),
		"review_surface": review_surface.duplicate(true),
		"route_chamber_model": _build_route_chamber_model(generation_surface, room_count),
		"role_surface_model": _build_role_surface_model(policy, public_summary),
		"item_ecology": _build_item_ecology(public_summary, generation_surface),
		"pressure_ecology": _build_pressure_ecology(policy, public_summary),
		"information_doctrine": information_doctrine.duplicate(true),
		"custody_law": _build_custody_law(public_summary, generation_surface),
		"mutation_envelope": _build_mutation_envelope(policy, public_summary, generation_surface),
		"continuity_hooks": _build_continuity_hooks(public_summary, world_goals),
		"multimodal_contract": _default_multimodal_contract(),
		"cosmetic_readability_law": _build_readability_law(public_summary),
		"safety_law": _build_safety_law(policy),
		"world_goals": world_goals.duplicate(true),
		"mind_balance": mind_balance.duplicate(true),
		"causal_audit": audit.duplicate(true),
		"run_identity": run_identity.duplicate(true),
		"legacy_term_aliases": {
			"directive": true,
			"generation_contract": true,
			"evidence": true
		}
	}
	var constitution_hash := build_hash(constitution)
	constitution["constitution_hash"] = constitution_hash
	constitution["constitution_id"] = "expedition_constitution_%s" % constitution_hash.substr(0, 12)
	constitution["constitution_version"] = SCHEMA_VERSION
	var compile_metadata: Dictionary = Dictionary(constitution.get("compile_metadata", {})).duplicate(true)
	compile_metadata["constitution_hash"] = constitution_hash
	compile_metadata["constitution_id"] = constitution["constitution_id"]
	compile_metadata["doctrine_family_id"] = str(constitution.get("doctrine_family_id", ""))
	compile_metadata["doctrine_variant_id"] = str(constitution.get("doctrine_variant_id", ""))
	compile_metadata["narrative_pressure_family"] = str(Dictionary(constitution.get("narrative_pressure_state", {})).get("pressure_family", ""))
	constitution["compile_metadata"] = compile_metadata
	return constitution

static func normalize(raw: Dictionary) -> Dictionary:
	if raw.is_empty():
		return {}
	var normalized := raw.duplicate(true)
	var summary_seed: Dictionary = Dictionary(normalized.get("constitution_summary", normalized.get("public_summary", {}))).duplicate(true)
	if not normalized.has("artifact_type"):
		normalized["artifact_type"] = "expedition_constitution"
	if not normalized.has("schema_name"):
		normalized["schema_name"] = "ExpeditionConstitution"
	if not normalized.has("schema_version") or int(normalized.get("schema_version", 0)) < SCHEMA_VERSION:
		normalized["schema_version"] = SCHEMA_VERSION
	if not normalized.has("constitution_version") or int(normalized.get("constitution_version", 0)) < SCHEMA_VERSION:
		normalized["constitution_version"] = int(normalized.get("schema_version", SCHEMA_VERSION))
	if not normalized.has("generation_surface"):
		normalized["generation_surface"] = Dictionary(normalized.get("generation_contract", {})).duplicate(true)
	if not normalized.has("generation_contract"):
		normalized["generation_contract"] = Dictionary(normalized.get("generation_surface", {})).duplicate(true)
	if not normalized.has("constitution_summary"):
		normalized["constitution_summary"] = Dictionary(normalized.get("public_summary", {})).duplicate(true)
	if not normalized.has("public_summary"):
		normalized["public_summary"] = Dictionary(normalized.get("constitution_summary", {})).duplicate(true)
	summary_seed = Dictionary(normalized.get("constitution_summary", normalized.get("public_summary", {}))).duplicate(true)
	if not normalized.has("protocol_state"):
		normalized["protocol_state"] = str(summary_seed.get("protocol_state", ""))
	if not normalized.has("doctrine_family_id"):
		normalized["doctrine_family_id"] = str(normalized.get("doctrine_family", summary_seed.get("doctrine_family", "")))
	if not normalized.has("doctrine_variant_id"):
		normalized["doctrine_variant_id"] = "variant_%s" % str(normalized.get("doctrine_family_id", "")).md5_text().substr(0, 12)
	if not normalized.has("generation_seed"):
		normalized["generation_seed"] = int(normalized.get("seed", 0))
	if not normalized.has("doctrine_family"):
		normalized["doctrine_family"] = str(summary_seed.get("doctrine_family", ""))
	if not normalized.has("doctrine_label"):
		normalized["doctrine_label"] = str(summary_seed.get("doctrine_label", summary_seed.get("doctrine", "")))
	if not normalized.has("pressure_line"):
		normalized["pressure_line"] = str(summary_seed.get("pressure_line", ""))
	if not normalized.has("world_goal"):
		normalized["world_goal"] = str(summary_seed.get("world_goal", ""))
	if not normalized.has("dominant_minds"):
		normalized["dominant_minds"] = Array(summary_seed.get("dominant_minds", [])).duplicate(true)
	if not normalized.has("dominant_forces"):
		normalized["dominant_forces"] = Array(summary_seed.get("dominant_forces", [])).duplicate(true)
	if not normalized.has("dominant_domains"):
		normalized["dominant_domains"] = Array(summary_seed.get("dominant_domains", [])).duplicate(true)
	if not normalized.has("pressure_grammar"):
		normalized["pressure_grammar"] = Array(summary_seed.get("pressure_grammar", [])).duplicate(true)
	if not normalized.has("symbolic_motifs"):
		normalized["symbolic_motifs"] = Array(summary_seed.get("symbolic_motifs", [])).duplicate(true)
	if not normalized.has("archive_tone"):
		normalized["archive_tone"] = str(summary_seed.get("archive_tone", ""))
	if not normalized.has("item_ecology_bias"):
		normalized["item_ecology_bias"] = str(summary_seed.get("item_ecology_bias", ""))
	if not normalized.has("group_tension_bias"):
		normalized["group_tension_bias"] = str(summary_seed.get("group_tension_bias", ""))
	if not normalized.has("convergence_axis"):
		normalized["convergence_axis"] = str(summary_seed.get("convergence_axis", ""))
	if not normalized.has("surface_summary"):
		normalized["surface_summary"] = Dictionary(summary_seed.get("surface_summary", {})).duplicate(true)
	if not normalized.has("identity"):
		normalized["identity"] = {
			"protocol_state": str(normalized.get("protocol_state", "")),
			"room_count": int(normalized.get("room_count", 0)),
			"world_goal": str(Dictionary(normalized.get("constitution_summary", {})).get("world_goal", ""))
		}
	if not normalized.has("mutation_envelope"):
		normalized["mutation_envelope"] = _build_mutation_envelope(
			Dictionary(normalized.get("control_surfaces", {})),
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("ontology_snapshot"):
		normalized["ontology_snapshot"] = {}
	if not normalized.has("narrative_pressure_state"):
		normalized["narrative_pressure_state"] = _default_narrative_pressure_state(
			Dictionary(normalized.get("control_surfaces", {})),
			Dictionary(normalized.get("constitution_summary", normalized.get("public_summary", {}))),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("experimental_ontology_state"):
		normalized["experimental_ontology_state"] = _default_experimental_ontology_state()
	if not normalized.has("doctrine_inheritance"):
		normalized["doctrine_inheritance"] = {}
	if not normalized.has("compiler_trace"):
		normalized["compiler_trace"] = {}
	if not normalized.has("compile_metadata"):
		normalized["compile_metadata"] = {}
	if not normalized.has("topology_profile"):
		normalized["topology_profile"] = _default_topology_profile(Dictionary(normalized.get("generation_surface", {})), int(normalized.get("room_count", 0)))
	if not normalized.has("chamber_grammar_profile"):
		normalized["chamber_grammar_profile"] = _default_chamber_grammar_profile(Dictionary(normalized.get("generation_surface", {})))
	if not normalized.has("route_profile"):
		normalized["route_profile"] = _default_route_profile(Dictionary(normalized.get("generation_surface", {})))
	if not normalized.has("item_ecology_profile"):
		normalized["item_ecology_profile"] = _default_item_ecology_profile(Dictionary(normalized.get("constitution_summary", {})), Dictionary(normalized.get("generation_surface", {})))
	if not normalized.has("pressure_ecology_profile"):
		normalized["pressure_ecology_profile"] = _default_pressure_ecology_profile(Dictionary(normalized.get("control_surfaces", {})), Dictionary(normalized.get("constitution_summary", {})))
	if not normalized.has("market_regime_state"):
		normalized["market_regime_state"] = _default_market_regime_state(Dictionary(normalized.get("constitution_summary", {})))
	if not normalized.has("market_memory_state"):
		normalized["market_memory_state"] = _default_market_memory_state(Dictionary(normalized.get("market_regime_state", {})))
	if not normalized.has("lifecycle_registry"):
		normalized["lifecycle_registry"] = _default_lifecycle_registry(Dictionary(normalized.get("market_regime_state", {})))
	if not normalized.has("encounter_language_profile"):
		normalized["encounter_language_profile"] = _default_encounter_language_profile(
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("pathology_profile"):
		normalized["pathology_profile"] = _default_pathology_profile(
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("pathology_state"):
		normalized["pathology_state"] = _default_pathology_state(
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("pathology_profile", {}))
		)
	if not normalized.has("encounter_manifest"):
		normalized["encounter_manifest"] = _default_encounter_manifest(
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("creative_governance"):
		normalized["creative_governance"] = _default_creative_governance()
	if not normalized.has("apex_framework_profile"):
		normalized["apex_framework_profile"] = _default_apex_framework_profile(
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("apex_manifest"):
		normalized["apex_manifest"] = _default_apex_manifest(
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("peak_structure_profile"):
		normalized["peak_structure_profile"] = _default_peak_structure_profile(
			Dictionary(normalized.get("constitution_summary", {})),
			Dictionary(normalized.get("generation_surface", {}))
		)
	if not normalized.has("information_doctrine_profile"):
		normalized["information_doctrine_profile"] = _default_information_doctrine_profile(Dictionary(normalized.get("control_surfaces", {})), Dictionary(normalized.get("constitution_summary", {})))
	if not normalized.has("pacing_profile"):
		normalized["pacing_profile"] = _default_pacing_profile(Dictionary(normalized.get("constitution_summary", {})), Dictionary(normalized.get("generation_surface", {})))
	if not normalized.has("custody_profile"):
		normalized["custody_profile"] = _default_custody_profile(Dictionary(normalized.get("constitution_summary", {})), Dictionary(normalized.get("generation_surface", {})))
	if not normalized.has("mutation_permissions"):
		normalized["mutation_permissions"] = _default_mutation_permissions(Dictionary(normalized.get("control_surfaces", {})))
	if not normalized.has("fairness_bounds"):
		normalized["fairness_bounds"] = _default_fairness_bounds()
	if not normalized.has("lineage_registry"):
		normalized["lineage_registry"] = {}
	if not normalized.has("civilization_surface"):
		normalized["civilization_surface"] = {}
	if not normalized.has("cognitive_field_state"):
		normalized["cognitive_field_state"] = {}
	if not normalized.has("mind_projections"):
		normalized["mind_projections"] = []
	if not normalized.has("theory_surface"):
		normalized["theory_surface"] = {}
	if not normalized.has("activation_state"):
		normalized["activation_state"] = {}
	if not normalized.has("explanation_packet"):
		normalized["explanation_packet"] = {}
	if not normalized.has("review_surface"):
		normalized["review_surface"] = {}
	if not normalized.has("multimodal_contract"):
		normalized["multimodal_contract"] = _default_multimodal_contract()
	if not normalized.has("cosmetic_readability_law"):
		normalized["cosmetic_readability_law"] = _build_readability_law(Dictionary(normalized.get("constitution_summary", {})))
	if not normalized.has("safety_law"):
		normalized["safety_law"] = _build_safety_law(Dictionary(normalized.get("control_surfaces", {})))
	normalized["narrative_pressure_state"] = _normalize_narrative_pressure_state(
		Dictionary(normalized.get("narrative_pressure_state", {})),
		Dictionary(normalized.get("constitution_summary", normalized.get("public_summary", {}))),
		Dictionary(normalized.get("generation_surface", {}))
	)
	normalized["experimental_ontology_state"] = _normalize_experimental_ontology_state(
		Dictionary(normalized.get("experimental_ontology_state", {}))
	)
	normalized["lineage_registry"] = Dictionary(normalized.get("lineage_registry", {})).duplicate(true)
	normalized["civilization_surface"] = _normalize_civilization_surface(Dictionary(normalized.get("civilization_surface", {})))
	normalized["cognitive_field_state"] = _normalize_cognitive_field_state(Dictionary(normalized.get("cognitive_field_state", {})))
	normalized["mind_projections"] = _normalize_mind_projections(Array(normalized.get("mind_projections", [])))
	normalized["theory_surface"] = _normalize_theory_surface(Dictionary(normalized.get("theory_surface", {})))
	normalized["market_regime_state"] = _normalize_market_regime_state(Dictionary(normalized.get("market_regime_state", {})))
	normalized["market_memory_state"] = _normalize_market_memory_state(Dictionary(normalized.get("market_memory_state", {})))
	normalized["lifecycle_registry"] = _normalize_lifecycle_registry(Dictionary(normalized.get("lifecycle_registry", {})))
	normalized["encounter_language_profile"] = _normalize_encounter_language_profile(Dictionary(normalized.get("encounter_language_profile", {})))
	normalized["pathology_profile"] = _normalize_pathology_profile(Dictionary(normalized.get("pathology_profile", {})))
	normalized["pathology_state"] = _normalize_pathology_state(Dictionary(normalized.get("pathology_state", {})))
	normalized["encounter_manifest"] = _normalize_encounter_manifest(Dictionary(normalized.get("encounter_manifest", {})))
	normalized["creative_governance"] = _normalize_creative_governance(Dictionary(normalized.get("creative_governance", {})))
	normalized["apex_framework_profile"] = _normalize_apex_framework_profile(Dictionary(normalized.get("apex_framework_profile", {})))
	normalized["apex_manifest"] = _normalize_apex_manifest(Dictionary(normalized.get("apex_manifest", {})))
	normalized["peak_structure_profile"] = _normalize_peak_structure_profile(Dictionary(normalized.get("peak_structure_profile", {})))
	normalized["activation_state"] = GOVERNANCE_SERVICE_SCRIPT.normalize_activation_state(Dictionary(normalized.get("activation_state", {})))
	normalized["explanation_packet"] = _normalize_explanation_packet(Dictionary(normalized.get("explanation_packet", {})))
	normalized["review_surface"] = _normalize_review_surface(Dictionary(normalized.get("review_surface", {})))
	normalized["constitution_summary"] = _apply_narrative_pressure_summary(
		Dictionary(normalized.get("constitution_summary", {})),
		Dictionary(normalized.get("narrative_pressure_state", {}))
	)
	normalized["public_summary"] = _apply_narrative_pressure_summary(
		Dictionary(normalized.get("public_summary", {})),
		Dictionary(normalized.get("narrative_pressure_state", {}))
	)
	normalized["constitution_summary"] = _apply_experimental_summary(
		Dictionary(normalized.get("constitution_summary", {})),
		Dictionary(normalized.get("experimental_ontology_state", {}))
	)
	normalized["public_summary"] = _apply_experimental_summary(
		Dictionary(normalized.get("public_summary", {})),
		Dictionary(normalized.get("experimental_ontology_state", {}))
	)
	normalized["constitution_summary"] = _apply_phase_v3_summary(
		Dictionary(normalized.get("constitution_summary", {})),
		Dictionary(normalized.get("lineage_registry", {})),
		Dictionary(normalized.get("civilization_surface", {})),
		Dictionary(normalized.get("cognitive_field_state", {})),
		Array(normalized.get("mind_projections", [])),
		Dictionary(normalized.get("theory_surface", {})),
		Dictionary(normalized.get("activation_state", {})),
		Dictionary(normalized.get("explanation_packet", {})),
		Dictionary(normalized.get("review_surface", {}))
	)
	normalized["constitution_summary"] = _apply_phase2_cosmetic_summary(Dictionary(normalized.get("constitution_summary", {})))
	normalized["public_summary"] = _apply_phase_v3_summary(
		Dictionary(normalized.get("public_summary", {})),
		Dictionary(normalized.get("lineage_registry", {})),
		Dictionary(normalized.get("civilization_surface", {})),
		Dictionary(normalized.get("cognitive_field_state", {})),
		Array(normalized.get("mind_projections", [])),
		Dictionary(normalized.get("theory_surface", {})),
		Dictionary(normalized.get("activation_state", {})),
		Dictionary(normalized.get("explanation_packet", {})),
		Dictionary(normalized.get("review_surface", {}))
	)
	normalized["constitution_summary"] = _apply_phase3_market_summary(
		Dictionary(normalized.get("constitution_summary", {})),
		Dictionary(normalized.get("market_regime_state", {})),
		Dictionary(normalized.get("lifecycle_registry", {}))
	)
	normalized["constitution_summary"] = _apply_phase4_encounter_summary(
		Dictionary(normalized.get("constitution_summary", {})),
		Dictionary(normalized.get("encounter_manifest", {})),
		Dictionary(normalized.get("pathology_state", {}))
	)
	normalized["constitution_summary"] = _apply_phase5_apex_summary(
		Dictionary(normalized.get("constitution_summary", {})),
		Dictionary(normalized.get("apex_manifest", {})),
		Dictionary(normalized.get("peak_structure_profile", {}))
	)
	normalized["public_summary"] = _apply_phase3_market_summary(
		Dictionary(normalized.get("public_summary", {})),
		Dictionary(normalized.get("market_regime_state", {})),
		Dictionary(normalized.get("lifecycle_registry", {}))
	)
	normalized["public_summary"] = _apply_phase4_encounter_summary(
		Dictionary(normalized.get("public_summary", {})),
		Dictionary(normalized.get("encounter_manifest", {})),
		Dictionary(normalized.get("pathology_state", {}))
	)
	normalized["public_summary"] = _apply_phase5_apex_summary(
		Dictionary(normalized.get("public_summary", {})),
		Dictionary(normalized.get("apex_manifest", {})),
		Dictionary(normalized.get("peak_structure_profile", {}))
	)
	normalized["public_summary"] = _apply_phase2_cosmetic_summary(Dictionary(normalized.get("public_summary", {})))
	if not normalized.has("constitution_hash") or str(normalized.get("constitution_hash", "")).strip_edges().is_empty():
		normalized["constitution_hash"] = build_hash(normalized)
	if not normalized.has("constitution_id") or str(normalized.get("constitution_id", "")).strip_edges().is_empty():
		normalized["constitution_id"] = "expedition_constitution_%s" % str(normalized.get("constitution_hash", "")).substr(0, 12)
	return normalized

static func build_public_summary(
	protocol_state: String,
	doctrine: Dictionary,
	public_doctrine: Dictionary,
	surface_summary: Dictionary,
	world_goals: Array,
	generation_surface: Dictionary
) -> Dictionary:
	return _apply_phase2_cosmetic_summary({
		"artifact_type": "constitution_summary",
		"protocol_state": protocol_state,
		"doctrine_family": str(doctrine.get("id", "")),
		"doctrine_label": str(doctrine.get("label", "")),
		"doctrine": str(doctrine.get("label", "")),
		"pressure_line": str(public_doctrine.get("pressure_line", _first_string(Array(surface_summary.get("lines", [])), ""))),
		"world_goal": str(public_doctrine.get("world_goal", _first_string(world_goals, ""))),
		"dominant_minds": Array(public_doctrine.get("dominant_minds", [])).duplicate(true),
		"dominant_forces": Array(public_doctrine.get("dominant_forces", [])).duplicate(true),
		"dominant_domains": Array(public_doctrine.get("dominant_domains", [])).duplicate(true),
		"pacing_profile": str(public_doctrine.get("pacing_profile", generation_surface.get("pacing_profile", ""))),
		"pacing_label": str(public_doctrine.get("pacing_label", public_doctrine.get("pacing_profile", generation_surface.get("pacing_profile", "")))),
		"pressure_grammar": Array(public_doctrine.get("pressure_grammar", generation_surface.get("pressure_verbs", []))).duplicate(true),
		"symbolic_motifs": Array(public_doctrine.get("symbolic_motifs", generation_surface.get("symbolic_motifs", []))).duplicate(true),
		"item_ecology_bias": str(public_doctrine.get("item_ecology_bias", generation_surface.get("item_ecology_bias", ""))),
		"group_tension_bias": str(public_doctrine.get("group_tension_bias", generation_surface.get("group_tension_bias", ""))),
		"archive_tone": str(public_doctrine.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"convergence_axis": str(public_doctrine.get("convergence_axis", generation_surface.get("convergence_axis", ""))),
		"normalization_modes_supported": PRODUCT_CATALOG_SCRIPT.normalization_modes(),
		"normalization_mode_default": "default",
		"cosmetic_modulation_lines": [
			"Cosmetic modulation stays inside zero-advantage equivalence classes.",
			"Fairness-sensitive and replay-safe modes collapse to the canonical member."
		],
		"active_regime_ids": [],
		"lifecycle_state_ids": [],
		"market_regime_lines": [],
		"lifecycle_lines": [],
		"market_regime_id": "",
		"market_regime_family": "",
		"market_prestige_band": "",
		"market_carrier_risk_band": "",
		"active_pathology_ids": [],
		"pathology_lines": [],
		"encounter_lines": [],
		"encounter_manifest_ids": [],
		"encounter_intent_ids": [],
		"encounter_topology_ids": [],
		"apex_manifest_ids": [],
		"apex_class_ids": [],
		"apex_lines": [],
		"peak_structure_lines": [],
		"experiment_surface_lines": [],
		"experiment_families": [],
		"experiment_expression_modes": [],
		"experiment_horizons": [],
		"live_hypothesis_ids": [],
		"live_experiment_ids": [],
		"lineage_registry_ids": [],
		"civilization_surface_lines": [],
		"civilization_faction_ids": [],
		"civilization_regime_ids": [],
		"world_mutation_ids": [],
		"cognitive_field_summary_lines": [],
		"cognitive_field_dimensions": [],
		"mind_projection_ids": [],
		"theory_surface_lines": [],
		"theory_ids": [],
		"theory_school_ids": [],
		"theory_statuses": [],
		"activation_epoch": "inactive",
		"activation_active_channels": [],
		"activation_dormant_channels": [],
		"activation_lines": [],
		"safe_mode_active": false,
		"safe_mode_lines": [],
		"provenance_contract_version": GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION,
		"public_trace_classes": ["artifact", "noise", "hazard", "extraction"],
		"public_surface_tags": [],
		"packet_schema_version": GOVERNANCE_SERVICE_SCRIPT.PACKET_SCHEMA_VERSION,
		"explanation_packet_digest": "",
		"explanation_packet_lines": [],
		"explanation_immediate_lines": [],
		"explanation_run_lines": [],
		"explanation_meta_lines": [],
		"review_surface_lines": [],
		"signal_budget_lines": [],
		"surface_summary": {
			"lines": Array(surface_summary.get("lines", [])).duplicate(true)
		}
	})

static func build_runtime_summary(summary: Dictionary, constitution_hash: String = "") -> Dictionary:
	var normalized_summary := _apply_phase2_cosmetic_summary(Dictionary(summary).duplicate(true))
	if not normalized_summary.has("artifact_type"):
		normalized_summary["artifact_type"] = "constitution_summary"
	if not constitution_hash.strip_edges().is_empty():
		normalized_summary["constitution_hash"] = constitution_hash
	return normalize({
		"artifact_type": "expedition_constitution",
		"schema_name": "ExpeditionConstitution",
		"schema_version": SCHEMA_VERSION,
		"constitution_version": SCHEMA_VERSION,
		"constitution_hash": constitution_hash,
		"public_summary": normalized_summary.duplicate(true),
		"constitution_summary": normalized_summary.duplicate(true),
		"surface_summary": Dictionary(normalized_summary.get("surface_summary", {})).duplicate(true),
		"protocol_state": str(normalized_summary.get("protocol_state", "")),
		"doctrine_family": str(normalized_summary.get("doctrine_family", "")),
		"doctrine_label": str(normalized_summary.get("doctrine_label", normalized_summary.get("doctrine", ""))),
		"pressure_line": str(normalized_summary.get("pressure_line", "")),
		"world_goal": str(normalized_summary.get("world_goal", "")),
		"dominant_minds": Array(normalized_summary.get("dominant_minds", [])).duplicate(true),
		"dominant_forces": Array(normalized_summary.get("dominant_forces", [])).duplicate(true),
		"dominant_domains": Array(normalized_summary.get("dominant_domains", [])).duplicate(true),
		"pressure_grammar": Array(normalized_summary.get("pressure_grammar", [])).duplicate(true),
		"symbolic_motifs": Array(normalized_summary.get("symbolic_motifs", [])).duplicate(true),
		"archive_tone": str(normalized_summary.get("archive_tone", "")),
		"item_ecology_bias": str(normalized_summary.get("item_ecology_bias", "")),
		"group_tension_bias": str(normalized_summary.get("group_tension_bias", "")),
		"convergence_axis": str(normalized_summary.get("convergence_axis", "")),
		"experiment_surface_lines": Array(normalized_summary.get("experiment_surface_lines", [])).duplicate(true),
		"experiment_families": Array(normalized_summary.get("experiment_families", [])).duplicate(true),
		"experiment_expression_modes": Array(normalized_summary.get("experiment_expression_modes", [])).duplicate(true),
		"experiment_horizons": Array(normalized_summary.get("experiment_horizons", [])).duplicate(true),
		"live_hypothesis_ids": Array(normalized_summary.get("live_hypothesis_ids", [])).duplicate(true),
		"live_experiment_ids": Array(normalized_summary.get("live_experiment_ids", [])).duplicate(true),
		"lineage_registry_ids": Array(normalized_summary.get("lineage_registry_ids", [])).duplicate(true),
		"civilization_surface_lines": Array(normalized_summary.get("civilization_surface_lines", [])).duplicate(true),
		"civilization_faction_ids": Array(normalized_summary.get("civilization_faction_ids", [])).duplicate(true),
		"civilization_regime_ids": Array(normalized_summary.get("civilization_regime_ids", [])).duplicate(true),
		"world_mutation_ids": Array(normalized_summary.get("world_mutation_ids", [])).duplicate(true),
		"cognitive_field_summary_lines": Array(normalized_summary.get("cognitive_field_summary_lines", [])).duplicate(true),
		"cognitive_field_dimensions": Array(normalized_summary.get("cognitive_field_dimensions", [])).duplicate(true),
		"mind_projection_ids": Array(normalized_summary.get("mind_projection_ids", [])).duplicate(true),
		"theory_surface_lines": Array(normalized_summary.get("theory_surface_lines", [])).duplicate(true),
		"theory_ids": Array(normalized_summary.get("theory_ids", [])).duplicate(true),
		"theory_school_ids": Array(normalized_summary.get("theory_school_ids", [])).duplicate(true),
		"theory_statuses": Array(normalized_summary.get("theory_statuses", [])).duplicate(true),
		"activation_epoch": str(normalized_summary.get("activation_epoch", "inactive")),
		"activation_active_channels": Array(normalized_summary.get("activation_active_channels", [])).duplicate(true),
		"activation_dormant_channels": Array(normalized_summary.get("activation_dormant_channels", [])).duplicate(true),
		"activation_lines": Array(normalized_summary.get("activation_lines", [])).duplicate(true),
		"safe_mode_active": bool(normalized_summary.get("safe_mode_active", false)),
		"safe_mode_lines": Array(normalized_summary.get("safe_mode_lines", [])).duplicate(true),
		"provenance_contract_version": int(normalized_summary.get("provenance_contract_version", GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION)),
		"public_trace_classes": Array(normalized_summary.get("public_trace_classes", [])).duplicate(true),
		"private_trace_classes": Array(normalized_summary.get("private_trace_classes", [])).duplicate(true),
		"public_surface_tags": Array(normalized_summary.get("public_surface_tags", [])).duplicate(true),
		"provenance_source_refs": Array(normalized_summary.get("provenance_source_refs", [])).duplicate(true),
		"normalization_modes_supported": Array(normalized_summary.get("normalization_modes_supported", PRODUCT_CATALOG_SCRIPT.normalization_modes())).duplicate(true),
		"normalization_mode_default": str(normalized_summary.get("normalization_mode_default", "default")),
		"cosmetic_modulation_lines": Array(normalized_summary.get("cosmetic_modulation_lines", [])).duplicate(true),
		"active_regime_ids": Array(normalized_summary.get("active_regime_ids", [])).duplicate(true),
		"lifecycle_state_ids": Array(normalized_summary.get("lifecycle_state_ids", [])).duplicate(true),
		"market_regime_lines": Array(normalized_summary.get("market_regime_lines", [])).duplicate(true),
		"lifecycle_lines": Array(normalized_summary.get("lifecycle_lines", [])).duplicate(true),
		"market_regime_id": str(normalized_summary.get("market_regime_id", "")),
		"market_regime_family": str(normalized_summary.get("market_regime_family", "")),
		"market_prestige_band": str(normalized_summary.get("market_prestige_band", "")),
		"market_carrier_risk_band": str(normalized_summary.get("market_carrier_risk_band", "")),
		"active_pathology_ids": Array(normalized_summary.get("active_pathology_ids", [])).duplicate(true),
		"pathology_lines": Array(normalized_summary.get("pathology_lines", [])).duplicate(true),
		"encounter_lines": Array(normalized_summary.get("encounter_lines", [])).duplicate(true),
		"encounter_manifest_ids": Array(normalized_summary.get("encounter_manifest_ids", [])).duplicate(true),
		"encounter_intent_ids": Array(normalized_summary.get("encounter_intent_ids", [])).duplicate(true),
		"encounter_topology_ids": Array(normalized_summary.get("encounter_topology_ids", [])).duplicate(true),
		"apex_manifest_ids": Array(normalized_summary.get("apex_manifest_ids", [])).duplicate(true),
		"apex_class_ids": Array(normalized_summary.get("apex_class_ids", [])).duplicate(true),
		"apex_lines": Array(normalized_summary.get("apex_lines", [])).duplicate(true),
		"peak_structure_lines": Array(normalized_summary.get("peak_structure_lines", [])).duplicate(true),
		"packet_schema_version": int(normalized_summary.get("packet_schema_version", GOVERNANCE_SERVICE_SCRIPT.PACKET_SCHEMA_VERSION)),
		"explanation_packet_digest": str(normalized_summary.get("explanation_packet_digest", "")),
		"explanation_packet_lines": Array(normalized_summary.get("explanation_packet_lines", [])).duplicate(true),
		"explanation_immediate_lines": Array(normalized_summary.get("explanation_immediate_lines", [])).duplicate(true),
		"explanation_run_lines": Array(normalized_summary.get("explanation_run_lines", [])).duplicate(true),
		"explanation_meta_lines": Array(normalized_summary.get("explanation_meta_lines", [])).duplicate(true),
		"review_surface_lines": Array(normalized_summary.get("review_surface_lines", [])).duplicate(true),
		"signal_budget_lines": Array(normalized_summary.get("signal_budget_lines", [])).duplicate(true),
		"generation_surface": {},
		"generation_contract": {},
		"control_surfaces": {}
	})

static func build_hash(raw_constitution: Dictionary) -> String:
	var snapshot := raw_constitution.duplicate(true)
	snapshot.erase("constitution_hash")
	snapshot.erase("constitution_id")
	snapshot.erase("trace_path")
	return _canonical_string(snapshot).md5_text()

static func public_summary(constitution: Dictionary) -> Dictionary:
	var normalized := normalize(constitution)
	var summary: Dictionary = Dictionary(normalized.get("public_summary", normalized.get("constitution_summary", {}))).duplicate(true)
	if not str(normalized.get("constitution_hash", "")).strip_edges().is_empty():
		summary["constitution_hash"] = str(normalized.get("constitution_hash", ""))
	if not str(normalized.get("constitution_id", "")).strip_edges().is_empty():
		summary["constitution_id"] = str(normalized.get("constitution_id", ""))
	return summary

static func generation_surface(constitution: Dictionary) -> Dictionary:
	var normalized := normalize(constitution)
	return Dictionary(normalized.get("generation_surface", normalized.get("generation_contract", {}))).duplicate(true)

static func _default_topology_profile(generation_surface: Dictionary, room_count: int) -> Dictionary:
	return {
		"room_count": room_count,
		"branch_family": str(generation_surface.get("branch_family", "")),
		"protocol_state": str(generation_surface.get("protocol_state", "")),
		"route_bias_tags": Array(Dictionary(generation_surface.get("ontology_routing", {})).get("route_bias_tags", [])).duplicate(true)
	}

static func _default_chamber_grammar_profile(generation_surface: Dictionary) -> Dictionary:
	return {
		"pressure_verbs": Array(generation_surface.get("pressure_verbs", [])).duplicate(true),
		"symbolic_motifs": Array(generation_surface.get("symbolic_motifs", [])).duplicate(true),
		"public_lines": Array(Dictionary(generation_surface.get("ontology_routing", {})).get("public_lines", [])).duplicate(true)
	}

static func _default_route_profile(generation_surface: Dictionary) -> Dictionary:
	return {
		"relationship_routing": Dictionary(generation_surface.get("relationship_routing", {})).duplicate(true),
		"relay_routing": Dictionary(generation_surface.get("relay_routing", {})).duplicate(true),
		"cookbook_routing": Dictionary(generation_surface.get("cookbook_routing", {})).duplicate(true),
		"civilization_routing": Dictionary(generation_surface.get("civilization_routing", {})).duplicate(true),
		"market_routing": Dictionary(generation_surface.get("market_routing", {})).duplicate(true),
		"encounter_routing": Dictionary(generation_surface.get("encounter_routing", {})).duplicate(true),
		"apex_routing": Dictionary(generation_surface.get("apex_routing", {})).duplicate(true),
		"ontology_routing": Dictionary(generation_surface.get("ontology_routing", {})).duplicate(true)
	}

static func _default_item_ecology_profile(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	return {
		"item_ecology_bias": str(public_summary.get("item_ecology_bias", generation_surface.get("item_ecology_bias", ""))),
		"symbolic_motifs": Array(public_summary.get("symbolic_motifs", generation_surface.get("symbolic_motifs", []))).duplicate(true),
		"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"market_regime_ids": Array(public_summary.get("active_regime_ids", [])).duplicate(true),
		"lifecycle_state_ids": Array(public_summary.get("lifecycle_state_ids", [])).duplicate(true)
	}

static func _default_pressure_ecology_profile(policy: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"pressure_line": str(public_summary.get("pressure_line", "")),
		"pressure_verbs": Array(public_summary.get("pressure_grammar", [])).duplicate(true),
		"inhabitant_pressure": int(Dictionary(policy.get("ecology", {})).get("inhabitant_pressure", 0)),
		"stalking_bias": int(Dictionary(policy.get("ecology", {})).get("stalking_bias", 0)),
		"anomaly_contamination": int(Dictionary(policy.get("ecology", {})).get("anomaly_contamination", 0)),
		"market_regime_lines": Array(public_summary.get("market_regime_lines", [])).duplicate(true)
	}

static func _default_market_regime_state(public_summary: Dictionary) -> Dictionary:
	return {
		"regime_id": str(public_summary.get("market_regime_id", "market_balanced_exchange")).strip_edges(),
		"regime_family": str(public_summary.get("market_regime_family", "balanced")).strip_edges(),
		"scarcity_band": "suppressed",
		"prestige_band": str(public_summary.get("market_prestige_band", "suppressed")).strip_edges(),
		"carrier_risk_band": str(public_summary.get("market_carrier_risk_band", "suppressed")).strip_edges(),
		"anomaly_significance_band": "suppressed",
		"institutional_pressure_band": "suppressed",
		"active_regime_ids": Array(public_summary.get("active_regime_ids", [])).duplicate(true),
		"summary_lines": Array(public_summary.get("market_regime_lines", [])).duplicate(true)
	}

static func _default_market_memory_state(market_regime_state: Dictionary) -> Dictionary:
	return {
		"active_regime_ids": Array(market_regime_state.get("active_regime_ids", [])).duplicate(true),
		"extraction_debt": 0,
		"hoard_heat": 0,
		"neglect_heat": 0,
		"distortion_heat": 0,
		"recovery_credit": 0,
		"prestige_climate": "",
		"carrier_risk_band": str(market_regime_state.get("carrier_risk_band", "suppressed")).strip_edges(),
		"lines": Array(market_regime_state.get("summary_lines", [])).duplicate(true)
	}

static func _default_lifecycle_registry(market_regime_state: Dictionary) -> Dictionary:
	return {
		"families": [{
			"family_id": str(market_regime_state.get("regime_id", "market_balanced_exchange")).strip_edges(),
			"family_kind": "market",
			"source_id": str(market_regime_state.get("regime_id", "market_balanced_exchange")).strip_edges(),
			"state": "emerging",
			"heat": 0,
			"saturation": 0,
			"strain": 0,
			"cooling_tags": [],
			"cooldown_band": "open",
			"successor_hint": "market_balanced_exchange",
			"return_window": "near_horizon",
			"routing_tags": ["market", "return"],
			"dominance_strain": 0,
			"throttle_state": "open",
			"resurrection_priority": 0
		}],
		"active_state_ids": Array(market_regime_state.get("active_regime_ids", [])).duplicate(true),
		"lines": Array(market_regime_state.get("summary_lines", [])).duplicate(true)
	}

static func _encounter_anchor_categories() -> Array[String]:
	return [
		"custody_pressure",
		"route_pressure",
		"regroup_pressure",
		"extraction_pressure",
		"evidence_pressure",
		"burden_pressure"
	]

static func _encounter_state_flow_defaults() -> Array[String]:
	return ["foreshadow", "telegraph", "commit", "contest", "resolve", "residue"]

static func _encounter_intent_taxonomy_defaults() -> Array[Dictionary]:
	return [
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
	]

static func _encounter_topology_taxonomy_defaults() -> Array[Dictionary]:
	return [
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
	]

static func _pathology_family_defaults(active_regime_ids: Array[String] = []) -> Array[Dictionary]:
	var regime_affinity := active_regime_ids.duplicate()
	return [
		{
			"family_id": "pathology_haunt_pressure",
			"spread_mode": "echo pursuit",
			"adaptation_tags": ["artifact_focus", "route_focus"],
			"suppression_tags": ["escort_cover", "recovery_geometry"],
			"recurrence_affinity": "steady",
			"regime_affinity": regime_affinity,
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
			"regime_affinity": regime_affinity,
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
			"regime_affinity": regime_affinity,
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
			"regime_affinity": regime_affinity,
			"public_signals": ["echo lure", "echo pressure"],
			"linked_species_ids": ["echo_lure"],
			"encounter_ids": ["enc_echo_split_displacement"]
		}
	]

static func _encounter_defaults() -> Array[Dictionary]:
	return [
		{
			"encounter_id": "enc_ghost_corridor_pursuit",
			"species_id": "ghost",
			"mode_ids": ["pursuit"],
			"intent_id": "pursuit",
			"topology_id": "corridor_chase",
			"anchored_pressures": ["route_pressure", "extraction_pressure"],
			"role_vectors": ["carrier", "escort", "decoy"],
			"telegraph_channels": ["position_shadow", "noise_trace", "hazard_pulse"],
			"consequence_classes": ["route_displacement", "stability_loss", "aftermath_seed"],
			"pathology_family_ids": ["pathology_haunt_pressure"],
			"room_tags": ["traversal", "hazard"],
			"hazard_tags": ["none", "push", "collapse"],
			"summary_lines": ["Ghost pursuit is pulling the route toward extraction pressure."]
		},
		{
			"encounter_id": "enc_predator_carrier_intercept",
			"species_id": "predator",
			"mode_ids": ["pursuit", "ambush"],
			"intent_id": "interdiction",
			"topology_id": "carrier_intercept",
			"anchored_pressures": ["custody_pressure", "burden_pressure"],
			"role_vectors": ["carrier", "escort", "breaker"],
			"telegraph_channels": ["hazard_pulse", "position_shadow"],
			"consequence_classes": ["custody_disruption", "stability_loss", "resource_drain"],
			"pathology_family_ids": ["pathology_predator_pack"],
			"room_tags": ["traversal", "hazard"],
			"hazard_tags": ["none", "push", "collapse"],
			"summary_lines": ["Predator intercept is testing who can carry through pressure."]
		},
		{
			"encounter_id": "enc_predator_pack_surround",
			"species_id": "predator",
			"mode_ids": ["pack"],
			"intent_id": "suppression",
			"topology_id": "pack_surround",
			"anchored_pressures": ["regroup_pressure", "burden_pressure"],
			"role_vectors": ["carrier", "escort", "decoy", "rescuer"],
			"telegraph_channels": ["hazard_pulse", "noise_trace"],
			"consequence_classes": ["route_displacement", "pathology_spread", "regroup_pressure"],
			"pathology_family_ids": ["pathology_predator_pack"],
			"room_tags": ["hazard", "traversal"],
			"hazard_tags": ["push", "spikes", "collapse"],
			"summary_lines": ["Predator pack pressure is forcing regroup decisions under load."]
		},
		{
			"encounter_id": "enc_protocol_threshold_hold",
			"species_id": "protocol_watch",
			"mode_ids": ["inspection", "containment"],
			"intent_id": "suppression",
			"topology_id": "threshold_hold",
			"anchored_pressures": ["evidence_pressure", "custody_pressure"],
			"role_vectors": ["carrier", "witness", "breaker", "recoverer"],
			"telegraph_channels": ["noise_trace", "hazard_pulse"],
			"consequence_classes": ["evidence_exposure", "route_displacement", "resource_drain"],
			"pathology_family_ids": ["pathology_protocol_interdiction"],
			"room_tags": ["evidence", "hazard"],
			"hazard_tags": ["none", "collapse", "spikes"],
			"summary_lines": ["Protocol watch is turning the threshold into a public answer test."]
		},
		{
			"encounter_id": "enc_protocol_extraction_interdict",
			"species_id": "protocol_watch",
			"mode_ids": ["interdiction"],
			"intent_id": "interdiction",
			"topology_id": "extraction_lane",
			"anchored_pressures": ["extraction_pressure", "custody_pressure"],
			"role_vectors": ["carrier", "escort", "rescuer", "suppressor"],
			"telegraph_channels": ["hazard_pulse", "noise_trace"],
			"consequence_classes": ["custody_disruption", "regroup_pressure", "aftermath_seed"],
			"pathology_family_ids": ["pathology_protocol_interdiction"],
			"room_tags": ["traversal", "hazard"],
			"hazard_tags": ["none", "push", "collapse"],
			"summary_lines": ["Protocol interdiction is tightening the extraction lane."]
		},
		{
			"encounter_id": "enc_echo_split_displacement",
			"species_id": "echo_lure",
			"mode_ids": ["lure", "anomaly_echo"],
			"intent_id": "displacement",
			"topology_id": "split_room",
			"anchored_pressures": ["route_pressure", "regroup_pressure"],
			"role_vectors": ["decoy", "recoverer", "escort"],
			"telegraph_channels": ["noise_trace", "hazard_pulse"],
			"consequence_classes": ["route_displacement", "noise_witness_generation", "pathology_spread"],
			"pathology_family_ids": ["pathology_echo_lure"],
			"room_tags": ["traversal", "evidence"],
			"hazard_tags": ["none", "push"],
			"summary_lines": ["Echo lure pressure is splitting the route into false answers."]
		}
	]

static func _default_encounter_language_profile(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var summary_lines := _string_array(public_summary.get("encounter_lines", []))
	if summary_lines.is_empty():
		summary_lines = [
			"Encounters stay anchored to custody, route, regroup, extraction, evidence, or burden pressure.",
			"Ecology pressure remains subordinate to expedition logic."
		]
	return {
		"schema_name": "EncounterLanguageProfile",
		"schema_version": SCHEMA_VERSION,
		"intent_taxonomy": _encounter_intent_taxonomy_defaults(),
		"topology_taxonomy": _encounter_topology_taxonomy_defaults(),
		"role_vectors": ["carrier", "escort", "witness", "breaker", "decoy", "rescuer", "suppressor", "recoverer"],
		"state_flow": _encounter_state_flow_defaults(),
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
			"readability_floor": 2
		},
		"summary_lines": summary_lines.slice(0, 3),
		"pacing_profile": str(public_summary.get("pacing_profile", generation_surface.get("pacing_profile", ""))).strip_edges()
	}

static func _default_pathology_profile(public_summary: Dictionary, _generation_surface: Dictionary) -> Dictionary:
	var active_regime_ids := _string_array(public_summary.get("active_regime_ids", []))
	return {
		"schema_name": "PathologyProfile",
		"schema_version": SCHEMA_VERSION,
		"families": _pathology_family_defaults(active_regime_ids)
	}

static func _default_pathology_state(public_summary: Dictionary, pathology_profile: Dictionary) -> Dictionary:
	var active_family_ids := _string_array(public_summary.get("active_pathology_ids", []))
	if active_family_ids.is_empty():
		for family_raw in Array(pathology_profile.get("families", [])):
			var family_id := str(Dictionary(family_raw).get("family_id", "")).strip_edges()
			if not family_id.is_empty() and active_family_ids.size() < 2:
				active_family_ids.append(family_id)
	var summary_lines := _string_array(public_summary.get("pathology_lines", []))
	if summary_lines.is_empty():
		summary_lines = ["Pathology pressure is staying legible while shaping live encounters."]
	return {
		"schema_name": "PathologyState",
		"schema_version": SCHEMA_VERSION,
		"active_family_ids": active_family_ids,
		"spread_heat": 1 if not active_family_ids.is_empty() else 0,
		"remission_state": "watchful" if not active_family_ids.is_empty() else "contained",
		"recurrence_heat": active_family_ids.size(),
		"suppression_state": "watchful",
		"mutation_tags": active_family_ids.duplicate(),
		"summary_lines": summary_lines.slice(0, 3)
	}

static func _default_encounter_manifest(public_summary: Dictionary, _generation_surface: Dictionary) -> Dictionary:
	var encounters := _encounter_defaults()
	var summary_lines := _string_array(public_summary.get("encounter_lines", []))
	if summary_lines.is_empty():
		for encounter_raw in encounters:
			summary_lines = _merge_limited(summary_lines, Array(Dictionary(encounter_raw).get("summary_lines", [])), 3)
	return {
		"schema_name": "EncounterManifest",
		"schema_version": SCHEMA_VERSION,
		"encounters": encounters,
		"summary_lines": summary_lines.slice(0, 3)
	}

static func _default_apex_framework_profile(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var summary_lines := _string_array(public_summary.get("apex_lines", []))
	if summary_lines.is_empty():
		summary_lines = [
			"Apex encounters remain readable escalations of expedition pressure.",
			"Apex resolution stays objective-driven rather than HP-sponge driven."
		]
	return {
		"schema_name": "ApexFrameworkProfile",
		"schema_version": SCHEMA_VERSION,
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
			"detached_boss_minigame_forbidden": true
		},
		"summary_lines": summary_lines.slice(0, 3),
		"pacing_profile": str(public_summary.get("pacing_profile", generation_surface.get("pacing_profile", ""))).strip_edges()
	}

static func _default_apex_manifest(public_summary: Dictionary, _generation_surface: Dictionary) -> Dictionary:
	var apexes: Array[Dictionary] = [
		{
			"apex_id": "apex_ghost_threshold_trial",
			"apex_class_id": "witness_trial_apex",
			"species_id": "ghost",
			"linked_encounter_ids": ["enc_ghost_corridor_pursuit"],
			"origin": "ecology",
			"function": "witness_trial",
			"arena": "threshold_lattice",
			"phase_model": ["announce", "shape", "commit", "crisis", "reversal", "resolution", "aftermath"],
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
			"phase_model": ["announce", "shape", "commit", "crisis", "reversal", "resolution", "aftermath"],
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
			"phase_model": ["announce", "shape", "commit", "crisis", "reversal", "resolution", "aftermath"],
			"resolution_classes": ["appease", "contain", "complete_objective_under_pressure", "split_and_recover"],
			"consequence_strata": ["local_state", "run_state", "world_memory_state"],
			"telegraph_profile": {"channels": ["hazard_pulse", "noise_trace"], "minimum_readability_floor": 2},
			"anchored_pressures": ["extraction_pressure", "custody_pressure", "evidence_pressure"],
			"local_aftermath_tags": ["public_trace", "custody_residue", "regroup_pressure"],
			"world_aftermath_tags": ["institutional_response", "successor_claim", "residue_record"],
			"summary_lines": ["Protocol extraction pressure is turning the return lane into a readable public trial."]
		}
	]
	var summary_lines := _string_array(public_summary.get("apex_lines", []))
	if summary_lines.is_empty():
		for apex_raw in apexes:
			summary_lines = _merge_limited(summary_lines, Array(Dictionary(apex_raw).get("summary_lines", [])), 3)
	return {
		"schema_name": "ApexManifest",
		"schema_version": SCHEMA_VERSION,
		"apexes": apexes,
		"summary_lines": summary_lines.slice(0, 3)
	}

static func _default_peak_structure_profile(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var summary_lines := _string_array(public_summary.get("peak_structure_lines", []))
	if summary_lines.is_empty():
		summary_lines = ["Peak structure keeps spectacle spaced around readable expedition consequences."]
	return {
		"schema_name": "PeakStructureProfile",
		"schema_version": SCHEMA_VERSION,
		"emotional_band": "charged" if str(public_summary.get("pacing_profile", generation_surface.get("pacing_profile", ""))).to_lower().find("volatile") != -1 else "measured",
		"peak_spacing_score": 2 if str(public_summary.get("pacing_profile", generation_surface.get("pacing_profile", ""))).to_lower().find("steady") != -1 else 3,
		"spectacle_window_profile": ["announce_window", "crisis_window", "aftermath_window"],
		"burden_unification_score": 2 if _string_array(public_summary.get("active_pathology_ids", [])).size() >= 1 else 1,
		"summary_lines": summary_lines.slice(0, 3)
	}

static func _normalize_encounter_language_profile(raw: Dictionary) -> Dictionary:
	var normalized := _default_encounter_language_profile({}, {})
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["schema_name"] = "EncounterLanguageProfile"
	normalized["schema_version"] = maxi(int(normalized.get("schema_version", SCHEMA_VERSION)), SCHEMA_VERSION)
	normalized["intent_taxonomy"] = _normalize_encounter_taxonomy_entries(
		Array(normalized.get("intent_taxonomy", [])),
		"intent_id",
		_encounter_intent_taxonomy_defaults()
	)
	normalized["topology_taxonomy"] = _normalize_encounter_taxonomy_entries(
		Array(normalized.get("topology_taxonomy", [])),
		"topology_id",
		_encounter_topology_taxonomy_defaults()
	)
	normalized["role_vectors"] = _unique_string_array(Array(normalized.get("role_vectors", [])))
	if Array(normalized.get("role_vectors", [])).is_empty():
		normalized["role_vectors"] = Array(_default_encounter_language_profile({}, {}).get("role_vectors", [])).duplicate(true)
	normalized["state_flow"] = _unique_string_array(Array(normalized.get("state_flow", _encounter_state_flow_defaults())))
	if Array(normalized.get("state_flow", [])).is_empty():
		normalized["state_flow"] = _encounter_state_flow_defaults()
	normalized["consequence_classes"] = _unique_string_array(Array(normalized.get("consequence_classes", [])))
	if Array(normalized.get("consequence_classes", [])).is_empty():
		normalized["consequence_classes"] = Array(_default_encounter_language_profile({}, {}).get("consequence_classes", [])).duplicate(true)
	normalized["expedition_pressure_categories"] = _unique_string_array(Array(normalized.get("expedition_pressure_categories", _encounter_anchor_categories())))
	if Array(normalized.get("expedition_pressure_categories", [])).is_empty():
		normalized["expedition_pressure_categories"] = _encounter_anchor_categories()
	normalized["readability_contract"] = Dictionary(normalized.get("readability_contract", {})).duplicate(true)
	normalized["summary_lines"] = _unique_string_array(Array(normalized.get("summary_lines", []))).slice(0, 3)
	return normalized

static func _normalize_pathology_profile(raw: Dictionary) -> Dictionary:
	var normalized := _default_pathology_profile({}, {})
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["schema_name"] = "PathologyProfile"
	normalized["schema_version"] = maxi(int(normalized.get("schema_version", SCHEMA_VERSION)), SCHEMA_VERSION)
	var family_defaults := _pathology_family_defaults()
	var families_by_id := {}
	for family_raw in family_defaults:
		var family := Dictionary(family_raw).duplicate(true)
		var family_id := str(family.get("family_id", "")).strip_edges()
		if family_id.is_empty():
			continue
		families_by_id[family_id] = family
	for family_raw in Array(normalized.get("families", [])):
		var family := Dictionary(family_raw).duplicate(true)
		var family_id := str(family.get("family_id", "")).strip_edges()
		if family_id.is_empty():
			continue
		var merged := Dictionary(families_by_id.get(family_id, {})).duplicate(true)
		for key in family.keys():
			merged[key] = family[key]
		merged["adaptation_tags"] = _unique_string_array(Array(merged.get("adaptation_tags", [])))
		merged["suppression_tags"] = _unique_string_array(Array(merged.get("suppression_tags", [])))
		merged["public_signals"] = _unique_string_array(Array(merged.get("public_signals", [])))
		merged["linked_species_ids"] = _unique_string_array(Array(merged.get("linked_species_ids", [])))
		merged["encounter_ids"] = _unique_string_array(Array(merged.get("encounter_ids", [])))
		merged["regime_affinity"] = _unique_string_array(Array(merged.get("regime_affinity", [])))
		families_by_id[family_id] = merged
	var family_ids: Array[String] = []
	for family_id in families_by_id.keys():
		family_ids.append(str(family_id))
	family_ids.sort()
	var normalized_families: Array[Dictionary] = []
	for family_id in family_ids:
		normalized_families.append(Dictionary(families_by_id.get(family_id, {})).duplicate(true))
	normalized["families"] = normalized_families
	return normalized

static func _normalize_pathology_state(raw: Dictionary) -> Dictionary:
	var normalized := _default_pathology_state({}, _default_pathology_profile({}, {}))
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["schema_name"] = "PathologyState"
	normalized["schema_version"] = maxi(int(normalized.get("schema_version", SCHEMA_VERSION)), SCHEMA_VERSION)
	normalized["active_family_ids"] = _unique_string_array(Array(normalized.get("active_family_ids", [])))
	normalized["spread_heat"] = maxi(int(normalized.get("spread_heat", 0)), 0)
	normalized["remission_state"] = str(normalized.get("remission_state", "contained")).strip_edges()
	normalized["recurrence_heat"] = maxi(int(normalized.get("recurrence_heat", 0)), 0)
	normalized["suppression_state"] = str(normalized.get("suppression_state", "watchful")).strip_edges()
	normalized["mutation_tags"] = _unique_string_array(Array(normalized.get("mutation_tags", [])))
	normalized["summary_lines"] = _unique_string_array(Array(normalized.get("summary_lines", []))).slice(0, 3)
	return normalized

static func _normalize_encounter_manifest(raw: Dictionary) -> Dictionary:
	var normalized := _default_encounter_manifest({}, {})
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["schema_name"] = "EncounterManifest"
	normalized["schema_version"] = maxi(int(normalized.get("schema_version", SCHEMA_VERSION)), SCHEMA_VERSION)
	var encounter_defaults := {}
	for encounter_raw in _encounter_defaults():
		var encounter := Dictionary(encounter_raw).duplicate(true)
		var encounter_id := str(encounter.get("encounter_id", "")).strip_edges()
		if encounter_id.is_empty():
			continue
		encounter_defaults[encounter_id] = encounter
	var normalized_encounters: Array[Dictionary] = []
	for encounter_raw in Array(normalized.get("encounters", [])):
		var encounter := Dictionary(encounter_raw).duplicate(true)
		var encounter_id := str(encounter.get("encounter_id", "")).strip_edges()
		if encounter_id.is_empty():
			continue
		var merged := Dictionary(encounter_defaults.get(encounter_id, {})).duplicate(true)
		for key in encounter.keys():
			merged[key] = encounter[key]
		merged["mode_ids"] = _unique_string_array(Array(merged.get("mode_ids", [])))
		merged["anchored_pressures"] = _normalize_encounter_anchor_pressures(Array(merged.get("anchored_pressures", [])))
		merged["role_vectors"] = _unique_string_array(Array(merged.get("role_vectors", [])))
		merged["telegraph_channels"] = _unique_string_array(Array(merged.get("telegraph_channels", [])))
		merged["consequence_classes"] = _unique_string_array(Array(merged.get("consequence_classes", [])))
		merged["pathology_family_ids"] = _unique_string_array(Array(merged.get("pathology_family_ids", [])))
		merged["room_tags"] = _unique_string_array(Array(merged.get("room_tags", [])))
		merged["hazard_tags"] = _unique_string_array(Array(merged.get("hazard_tags", [])))
		merged["summary_lines"] = _unique_string_array(Array(merged.get("summary_lines", []))).slice(0, 2)
		if not merged.has("state_flow"):
			merged["state_flow"] = _encounter_state_flow_defaults()
		else:
			merged["state_flow"] = _unique_string_array(Array(merged.get("state_flow", [])))
		if not merged.has("fairness_bounds"):
			merged["fairness_bounds"] = {
				"expedition_anchor_required": true,
				"no_hidden_targeting_required": true,
				"detached_genre_forbidden": true
			}
		else:
			merged["fairness_bounds"] = Dictionary(merged.get("fairness_bounds", {})).duplicate(true)
		if not merged.has("public_trace_class"):
			merged["public_trace_class"] = "pressure_ecology"
		if not merged.has("private_trace_class"):
			merged["private_trace_class"] = "escalation"
		normalized_encounters.append(merged)
	if normalized_encounters.is_empty():
		normalized_encounters = Array(_default_encounter_manifest({}, {}).get("encounters", [])).duplicate(true)
	normalized_encounters.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("encounter_id", "")) < str(b.get("encounter_id", ""))
	)
	normalized["encounters"] = normalized_encounters
	normalized["summary_lines"] = _unique_string_array(Array(normalized.get("summary_lines", []))).slice(0, 3)
	if Array(normalized.get("summary_lines", [])).is_empty():
		var summary_lines: Array[String] = []
		for encounter_raw in normalized_encounters:
			summary_lines = _merge_limited(summary_lines, Array(Dictionary(encounter_raw).get("summary_lines", [])), 3)
		normalized["summary_lines"] = summary_lines
	return normalized

static func _normalize_apex_framework_profile(raw: Dictionary) -> Dictionary:
	var normalized := _default_apex_framework_profile({}, {})
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["schema_name"] = "ApexFrameworkProfile"
	normalized["schema_version"] = maxi(int(normalized.get("schema_version", SCHEMA_VERSION)), SCHEMA_VERSION)
	for key in ["origin_taxonomy", "function_taxonomy", "arena_taxonomy", "class_taxonomy", "phase_model", "resolution_set"]:
		normalized[key] = _unique_string_array(Array(normalized.get(key, [])))
	normalized["readability_contract"] = Dictionary(normalized.get("readability_contract", {})).duplicate(true)
	normalized["summary_lines"] = _unique_string_array(Array(normalized.get("summary_lines", []))).slice(0, 3)
	return normalized

static func _normalize_apex_manifest(raw: Dictionary) -> Dictionary:
	var normalized := _default_apex_manifest({}, {})
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["schema_name"] = "ApexManifest"
	normalized["schema_version"] = maxi(int(normalized.get("schema_version", SCHEMA_VERSION)), SCHEMA_VERSION)
	var defaults_by_id := {}
	for apex_raw in Array(_default_apex_manifest({}, {}).get("apexes", [])):
		var apex := Dictionary(apex_raw).duplicate(true)
		var apex_id := str(apex.get("apex_id", "")).strip_edges()
		if not apex_id.is_empty():
			defaults_by_id[apex_id] = apex
	var normalized_apexes: Array[Dictionary] = []
	for apex_raw in Array(normalized.get("apexes", [])):
		var apex := Dictionary(apex_raw).duplicate(true)
		var apex_id := str(apex.get("apex_id", "")).strip_edges()
		if apex_id.is_empty():
			continue
		var merged := Dictionary(defaults_by_id.get(apex_id, {})).duplicate(true)
		for key in apex.keys():
			merged[key] = apex[key]
		for key in ["linked_encounter_ids", "phase_model", "resolution_classes", "consequence_strata", "anchored_pressures", "local_aftermath_tags", "world_aftermath_tags"]:
			merged[key] = _unique_string_array(Array(merged.get(key, [])))
		merged["telegraph_profile"] = Dictionary(merged.get("telegraph_profile", {})).duplicate(true)
		merged["summary_lines"] = _unique_string_array(Array(merged.get("summary_lines", []))).slice(0, 2)
		normalized_apexes.append(merged)
	if normalized_apexes.is_empty():
		normalized_apexes = Array(_default_apex_manifest({}, {}).get("apexes", [])).duplicate(true)
	normalized_apexes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("apex_id", "")) < str(b.get("apex_id", ""))
	)
	normalized["apexes"] = normalized_apexes
	normalized["summary_lines"] = _unique_string_array(Array(normalized.get("summary_lines", []))).slice(0, 3)
	if Array(normalized.get("summary_lines", [])).is_empty():
		var summary_lines: Array[String] = []
		for apex_raw in normalized_apexes:
			summary_lines = _merge_limited(summary_lines, Array(Dictionary(apex_raw).get("summary_lines", [])), 3)
		normalized["summary_lines"] = summary_lines
	return normalized

static func _normalize_peak_structure_profile(raw: Dictionary) -> Dictionary:
	var normalized := _default_peak_structure_profile({}, {})
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["schema_name"] = "PeakStructureProfile"
	normalized["schema_version"] = maxi(int(normalized.get("schema_version", SCHEMA_VERSION)), SCHEMA_VERSION)
	normalized["emotional_band"] = str(normalized.get("emotional_band", "measured")).strip_edges()
	normalized["peak_spacing_score"] = maxi(int(normalized.get("peak_spacing_score", 0)), 0)
	normalized["spectacle_window_profile"] = _unique_string_array(Array(normalized.get("spectacle_window_profile", [])))
	normalized["burden_unification_score"] = maxi(int(normalized.get("burden_unification_score", 0)), 0)
	normalized["summary_lines"] = _unique_string_array(Array(normalized.get("summary_lines", []))).slice(0, 3)
	return normalized

static func _apply_phase4_encounter_summary(summary: Dictionary, encounter_manifest: Dictionary, pathology_state: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	var encounters := Array(Dictionary(encounter_manifest).get("encounters", []))
	var active_pathology_ids := _unique_string_array(Array(Dictionary(pathology_state).get("active_family_ids", [])))
	var encounter_manifest_ids: Array[String] = []
	var encounter_intent_ids: Array[String] = []
	var encounter_topology_ids: Array[String] = []
	var encounter_lines: Array[String] = _string_array(Dictionary(encounter_manifest).get("summary_lines", []))
	for encounter_raw in encounters:
		var encounter := Dictionary(encounter_raw)
		var encounter_id := str(encounter.get("encounter_id", "")).strip_edges()
		var intent_id := str(encounter.get("intent_id", "")).strip_edges()
		var topology_id := str(encounter.get("topology_id", "")).strip_edges()
		if not encounter_id.is_empty() and not encounter_manifest_ids.has(encounter_id):
			encounter_manifest_ids.append(encounter_id)
		if not intent_id.is_empty() and not encounter_intent_ids.has(intent_id):
			encounter_intent_ids.append(intent_id)
		if not topology_id.is_empty() and not encounter_topology_ids.has(topology_id):
			encounter_topology_ids.append(topology_id)
		encounter_lines = _merge_limited(encounter_lines, Array(encounter.get("summary_lines", [])), 3)
	next["active_pathology_ids"] = active_pathology_ids
	next["pathology_lines"] = _merge_limited(
		_string_array(next.get("pathology_lines", [])),
		Array(Dictionary(pathology_state).get("summary_lines", [])),
		3
	)
	next["encounter_lines"] = encounter_lines.slice(0, 3)
	next["encounter_manifest_ids"] = encounter_manifest_ids
	next["encounter_intent_ids"] = encounter_intent_ids
	next["encounter_topology_ids"] = encounter_topology_ids
	return next

static func _apply_phase5_apex_summary(summary: Dictionary, apex_manifest: Dictionary, peak_structure_profile: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	var apex_manifest_ids: Array[String] = []
	var apex_class_ids: Array[String] = []
	var apex_lines: Array[String] = _string_array(Dictionary(apex_manifest).get("summary_lines", []))
	for apex_raw in Array(Dictionary(apex_manifest).get("apexes", [])):
		var apex := Dictionary(apex_raw)
		var apex_id := str(apex.get("apex_id", "")).strip_edges()
		var apex_class_id := str(apex.get("apex_class_id", "")).strip_edges()
		if not apex_id.is_empty() and not apex_manifest_ids.has(apex_id):
			apex_manifest_ids.append(apex_id)
		if not apex_class_id.is_empty() and not apex_class_ids.has(apex_class_id):
			apex_class_ids.append(apex_class_id)
		apex_lines = _merge_limited(apex_lines, Array(apex.get("summary_lines", [])), 3)
	next["apex_manifest_ids"] = apex_manifest_ids
	next["apex_class_ids"] = apex_class_ids
	next["apex_lines"] = apex_lines.slice(0, 3)
	next["peak_structure_lines"] = _merge_limited(
		_string_array(next.get("peak_structure_lines", [])),
		Array(Dictionary(peak_structure_profile).get("summary_lines", [])),
		3
	)
	return next

static func _normalize_encounter_taxonomy_entries(values: Array, key_field: String, defaults: Array) -> Array:
	var mapped := {}
	for entry_raw in defaults:
		var entry := Dictionary(entry_raw).duplicate(true)
		var entry_id := str(entry.get(key_field, "")).strip_edges()
		if not entry_id.is_empty():
			mapped[entry_id] = entry
	for entry_raw in values:
		var entry := Dictionary(entry_raw).duplicate(true)
		var entry_id := str(entry.get(key_field, "")).strip_edges()
		if entry_id.is_empty():
			continue
		var merged := Dictionary(mapped.get(entry_id, {})).duplicate(true)
		for key in entry.keys():
			merged[key] = entry[key]
		if merged.has("room_tags"):
			merged["room_tags"] = _unique_string_array(Array(merged.get("room_tags", [])))
		mapped[entry_id] = merged
	var ids: Array[String] = []
	for entry_id in mapped.keys():
		ids.append(str(entry_id))
	ids.sort()
	var normalized: Array = []
	for entry_id in ids:
		normalized.append(Dictionary(mapped.get(entry_id, {})).duplicate(true))
	return normalized

static func _normalize_encounter_anchor_pressures(values: Array) -> Array[String]:
	var allowed := _encounter_anchor_categories()
	var normalized: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if text.is_empty() or not allowed.has(text) or normalized.has(text):
			continue
		normalized.append(text)
	return normalized

static func _default_narrative_pressure_state(policy: Dictionary, public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var pressure_line := str(public_summary.get("pressure_line", "")).strip_edges()
	var archive_tone := str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))).strip_edges()
	var convergence_axis := str(public_summary.get("convergence_axis", generation_surface.get("convergence_axis", ""))).strip_edges()
	var item_ecology_bias := str(public_summary.get("item_ecology_bias", generation_surface.get("item_ecology_bias", ""))).strip_edges()
	var family := "measured_balance"
	if convergence_axis.to_lower().find("fragment") != -1:
		family = "skeptical_fragmentation"
	elif archive_tone.to_lower().find("custody") != -1 or item_ecology_bias.to_lower().find("burden") != -1:
		family = "stewardship_ritual"
	var lines: Array[String] = []
	if not pressure_line.is_empty():
		lines.append(pressure_line)
	return {
		"schema_name": "NarrativePressureState",
		"schema_version": SCHEMA_VERSION,
		"id": "pressure_legacy_%s" % family,
		"pressure_family": family,
		"stability": 2,
		"disruption": 2 if family == "skeptical_fragmentation" else 1,
		"authority": 2 if family == "stewardship_ritual" else 1,
		"skepticism": 2 if family == "skeptical_fragmentation" else 1,
		"fear": 1,
		"curiosity": 1,
		"certainty": 1 if family == "skeptical_fragmentation" else 2,
		"ambiguity": 2 if family == "skeptical_fragmentation" else 1,
		"ritual": 2 if family == "stewardship_ritual" else 1,
		"innovation": 1,
		"extraction": 1,
		"stewardship": 2 if family == "stewardship_ritual" else 1,
		"momentum": 1,
		"resonance": 1,
		"cascade_risk": 1 if family == "skeptical_fragmentation" else 0,
		"dominant_tensions": ["%s pressure" % family.replace("_", " ")],
		"generation_weighting": {
			"pressure_verbs": Array(public_summary.get("pressure_grammar", generation_surface.get("pressure_verbs", []))).duplicate(true),
			"symbolic_motifs": Array(public_summary.get("symbolic_motifs", generation_surface.get("symbolic_motifs", []))).duplicate(true),
			"item_ecology_bias": item_ecology_bias,
			"group_tension_bias": str(public_summary.get("group_tension_bias", generation_surface.get("group_tension_bias", ""))),
			"archive_tone": archive_tone,
			"convergence_axis": convergence_axis,
			"civilization_routing_bias": {}
		},
		"constitution_bias": {
			"pressure_line": pressure_line,
			"world_goal_hint": str(public_summary.get("world_goal", "")),
			"public_lines": lines.duplicate(),
			"tension_tags": ["legacy pressure"]
		},
		"archive_bias": {
			"framing_focus": ["legacy pressure"],
			"cascade_channels": [],
			"resonant_legends": false,
			"pressure_family": family,
			"dominant_tensions": ["legacy pressure"]
		},
		"allowed_outputs": ["generation_weighting", "archive_bias", "constitution_bias"],
		"safety_bounds": {
			"min_axis_value": 0,
			"max_axis_value": 4,
			"runtime_legality_mutation": false,
			"artifact_trust_floor": "objective_central",
			"legibility_floor": 2
		},
		"public_lines": lines.duplicate(),
		"trace": {
			"legacy_adapter": true
		}
	}

static func _normalize_narrative_pressure_state(raw: Dictionary, public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var normalized := _default_narrative_pressure_state({}, public_summary, generation_surface)
	for key in raw.keys():
		normalized[key] = raw[key]
	normalized["dominant_tensions"] = Array(normalized.get("dominant_tensions", [])).duplicate(true)
	normalized["allowed_outputs"] = Array(normalized.get("allowed_outputs", ["generation_weighting", "archive_bias", "constitution_bias"])).duplicate(true)
	normalized["public_lines"] = Array(normalized.get("public_lines", [])).duplicate(true)
	normalized["generation_weighting"] = Dictionary(normalized.get("generation_weighting", {})).duplicate(true)
	normalized["constitution_bias"] = Dictionary(normalized.get("constitution_bias", {})).duplicate(true)
	normalized["archive_bias"] = Dictionary(normalized.get("archive_bias", {})).duplicate(true)
	normalized["safety_bounds"] = Dictionary(normalized.get("safety_bounds", {})).duplicate(true)
	normalized["trace"] = Dictionary(normalized.get("trace", {})).duplicate(true)
	return normalized

static func _default_experimental_ontology_state() -> Dictionary:
	return {
		"schema_name": "ExperimentalOntologyState",
		"schema_version": SCHEMA_VERSION,
		"hypothesis_registry": [],
		"experiment_registry": [],
		"live_hypothesis_ids": [],
		"live_experiment_ids": [],
		"live_hypotheses": [],
		"live_experiments": [],
		"dominant_families": [],
		"lineage_index": {},
		"grammar_manifest": [],
		"learning_guidance": DELVEMIND_LEARNING_LOOP_SCRIPT.normalize_compiler_guidance({}),
		"compile_outputs": {},
		"creative_governance": _default_creative_governance(),
		"public_surface": {
			"lines": [],
			"family_labels": [],
			"expression_modes": [],
			"horizons": []
		},
		"compiler_trace": {},
		"validation_failures": []
	}

static func _normalize_experimental_ontology_state(raw: Dictionary) -> Dictionary:
	var normalized := _default_experimental_ontology_state()
	for key in raw.keys():
		normalized[key] = raw[key]
	var raw_hypothesis_registry := Array(raw.get("hypothesis_registry", []))
	var raw_experiment_registry := Array(raw.get("experiment_registry", []))
	var has_registry_payload := not raw_hypothesis_registry.is_empty() or not raw_experiment_registry.is_empty()
	if not has_registry_payload:
		normalized["hypothesis_registry"] = _sorted_registry_array(_registry_map(Array(normalized.get("hypothesis_registry", [])), "hypothesis_id"), "hypothesis_id")
		normalized["experiment_registry"] = _sorted_registry_array(_registry_map(Array(normalized.get("experiment_registry", [])), "experiment_id"), "experiment_id")
		normalized["live_hypothesis_ids"] = _unique_string_array(Array(normalized.get("live_hypothesis_ids", [])))
		normalized["live_experiment_ids"] = _unique_string_array(Array(normalized.get("live_experiment_ids", [])))
		if Array(normalized.get("live_hypothesis_ids", [])).is_empty():
			var derived_live_hypothesis_ids: Array = []
			for entry_raw in _sorted_registry_array(_registry_map(Array(normalized.get("live_hypotheses", [])), "hypothesis_id"), "hypothesis_id"):
				var entry: Dictionary = Dictionary(entry_raw)
				var hypothesis_id := str(entry.get("hypothesis_id", "")).strip_edges()
				if not hypothesis_id.is_empty():
					derived_live_hypothesis_ids.append(hypothesis_id)
			normalized["live_hypothesis_ids"] = _unique_string_array(derived_live_hypothesis_ids)
		if Array(normalized.get("live_experiment_ids", [])).is_empty():
			var derived_live_experiment_ids: Array = []
			for entry_raw in _sorted_registry_array(_registry_map(Array(normalized.get("live_experiments", [])), "experiment_id"), "experiment_id"):
				var entry: Dictionary = Dictionary(entry_raw)
				var experiment_id := str(entry.get("experiment_id", "")).strip_edges()
				if not experiment_id.is_empty():
					derived_live_experiment_ids.append(experiment_id)
			normalized["live_experiment_ids"] = _unique_string_array(derived_live_experiment_ids)
		normalized["live_hypotheses"] = _sorted_registry_array(_registry_map(Array(normalized.get("live_hypotheses", [])), "hypothesis_id"), "hypothesis_id")
		normalized["live_experiments"] = _sorted_registry_array(_registry_map(Array(normalized.get("live_experiments", [])), "experiment_id"), "experiment_id")
		normalized["dominant_families"] = _unique_string_array(Array(normalized.get("dominant_families", [])))
		normalized["lineage_index"] = Dictionary(normalized.get("lineage_index", {})).duplicate(true)
		normalized["grammar_manifest"] = Array(normalized.get("grammar_manifest", [])).duplicate(true)
		normalized["learning_guidance"] = DELVEMIND_LEARNING_LOOP_SCRIPT.normalize_compiler_guidance(
			Dictionary(normalized.get("learning_guidance", {}))
		)
		normalized["compile_outputs"] = Dictionary(normalized.get("compile_outputs", {})).duplicate(true)
		normalized["creative_governance"] = _normalize_creative_governance(Dictionary(normalized.get("creative_governance", {})))
		var shell_public_surface: Dictionary = Dictionary(normalized.get("public_surface", {})).duplicate(true)
		shell_public_surface["lines"] = _unique_string_array(Array(shell_public_surface.get("lines", [])))
		shell_public_surface["family_labels"] = _unique_string_array(Array(shell_public_surface.get("family_labels", [])))
		shell_public_surface["expression_modes"] = _unique_string_array(Array(shell_public_surface.get("expression_modes", [])))
		shell_public_surface["horizons"] = _unique_string_array(Array(shell_public_surface.get("horizons", [])))
		normalized["public_surface"] = shell_public_surface
		normalized["compiler_trace"] = Dictionary(normalized.get("compiler_trace", {})).duplicate(true)
		normalized["validation_failures"] = _unique_string_array(Array(normalized.get("validation_failures", [])))
		return normalized
	var rebuilt_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({
		"hypotheses": _registry_map(Array(normalized.get("hypothesis_registry", [])), "hypothesis_id"),
		"experiments": _registry_map(Array(normalized.get("experiment_registry", [])), "experiment_id")
	})
	var rebuilt_hypotheses: Dictionary = Dictionary(rebuilt_state.get("hypotheses", {}))
	var rebuilt_experiments: Dictionary = Dictionary(rebuilt_state.get("experiments", {}))
	normalized["hypothesis_registry"] = _sorted_registry_array(Dictionary(rebuilt_state.get("hypotheses", {})), "hypothesis_id")
	normalized["experiment_registry"] = _sorted_registry_array(Dictionary(rebuilt_state.get("experiments", {})), "experiment_id")
	normalized["live_hypothesis_ids"] = _unique_string_array(Array(normalized.get("live_hypothesis_ids", [])))
	normalized["live_experiment_ids"] = _unique_string_array(Array(normalized.get("live_experiment_ids", [])))
	if Array(normalized.get("live_hypothesis_ids", [])).is_empty():
		var derived_live_hypothesis_ids: Array = []
		for entry_raw in _sorted_registry_array(_registry_map(Array(normalized.get("live_hypotheses", [])), "hypothesis_id"), "hypothesis_id"):
			var entry: Dictionary = Dictionary(entry_raw)
			var hypothesis_id := str(entry.get("hypothesis_id", "")).strip_edges()
			if not hypothesis_id.is_empty():
				derived_live_hypothesis_ids.append(hypothesis_id)
		normalized["live_hypothesis_ids"] = _unique_string_array(derived_live_hypothesis_ids)
	if Array(normalized.get("live_experiment_ids", [])).is_empty():
		var derived_live_experiment_ids: Array = []
		for entry_raw in _sorted_registry_array(_registry_map(Array(normalized.get("live_experiments", [])), "experiment_id"), "experiment_id"):
			var entry: Dictionary = Dictionary(entry_raw)
			var experiment_id := str(entry.get("experiment_id", "")).strip_edges()
			if not experiment_id.is_empty():
				derived_live_experiment_ids.append(experiment_id)
		normalized["live_experiment_ids"] = _unique_string_array(derived_live_experiment_ids)
	var live_hypothesis_map := _registry_map(Array(normalized.get("live_hypotheses", [])), "hypothesis_id")
	for hypothesis_id in Array(normalized.get("live_hypothesis_ids", [])):
		var text := str(hypothesis_id).strip_edges()
		if text.is_empty() or live_hypothesis_map.has(text):
			continue
		if rebuilt_hypotheses.has(text):
			live_hypothesis_map[text] = Dictionary(rebuilt_hypotheses.get(text, {})).duplicate(true)
	normalized["live_hypotheses"] = _sorted_registry_array(live_hypothesis_map, "hypothesis_id")
	var live_experiment_map := _registry_map(Array(normalized.get("live_experiments", [])), "experiment_id")
	for experiment_id in Array(normalized.get("live_experiment_ids", [])):
		var text := str(experiment_id).strip_edges()
		if text.is_empty() or live_experiment_map.has(text):
			continue
		if rebuilt_experiments.has(text):
			live_experiment_map[text] = Dictionary(rebuilt_experiments.get(text, {})).duplicate(true)
	normalized["live_experiments"] = _sorted_registry_array(live_experiment_map, "experiment_id")
	normalized["dominant_families"] = _unique_string_array(Array(normalized.get("dominant_families", [])))
	normalized["lineage_index"] = Dictionary(rebuilt_state.get("lineage_index", {})).duplicate(true)
	normalized["grammar_manifest"] = Array(normalized.get("grammar_manifest", [])).duplicate(true)
	normalized["learning_guidance"] = DELVEMIND_LEARNING_LOOP_SCRIPT.normalize_compiler_guidance(
		Dictionary(normalized.get("learning_guidance", {}))
	)
	normalized["compile_outputs"] = Dictionary(normalized.get("compile_outputs", {})).duplicate(true)
	normalized["creative_governance"] = _normalize_creative_governance(Dictionary(normalized.get("creative_governance", {})))
	var public_surface: Dictionary = Dictionary(normalized.get("public_surface", {})).duplicate(true)
	public_surface["lines"] = _unique_string_array(Array(public_surface.get("lines", [])))
	public_surface["family_labels"] = _unique_string_array(Array(public_surface.get("family_labels", [])))
	public_surface["expression_modes"] = _unique_string_array(Array(public_surface.get("expression_modes", [])))
	public_surface["horizons"] = _unique_string_array(Array(public_surface.get("horizons", [])))
	normalized["public_surface"] = public_surface
	normalized["compiler_trace"] = Dictionary(normalized.get("compiler_trace", {})).duplicate(true)
	normalized["validation_failures"] = DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.validate_compile_state(normalized)
	return normalized

static func _default_creative_governance() -> Dictionary:
	return {
		"schema_name": "CreativeGovernanceProfile",
		"schema_version": 1,
		"novelty_envelope": {
			"active_band": "anchored_core",
			"occupancy": 0,
			"evaluation_count": 0,
			"allowed_range": ["anchored_core", "disciplined_frontier", "wide_frontier"]
		},
		"taste_profile": {
			"preferred_topologies": [],
			"preferred_horizons": [],
			"preferred_media": [],
			"dominant_family_labels": [],
			"expression_modes": [],
			"horizons": []
		},
		"personality_band": "disciplined_curiosity",
		"bounded_surface_ids": ["constitution", "archive", "framing"],
		"suppressed_patterns": [],
		"revive_candidates": [],
		"summary_lines": []
	}

static func _normalize_creative_governance(raw: Dictionary) -> Dictionary:
	var normalized := _default_creative_governance()
	for key in raw.keys():
		normalized[key] = raw[key]
	var novelty_envelope: Dictionary = Dictionary(normalized.get("novelty_envelope", {})).duplicate(true)
	novelty_envelope["active_band"] = str(novelty_envelope.get("active_band", "anchored_core")).strip_edges()
	novelty_envelope["occupancy"] = int(novelty_envelope.get("occupancy", 0))
	novelty_envelope["evaluation_count"] = int(novelty_envelope.get("evaluation_count", 0))
	novelty_envelope["allowed_range"] = _unique_string_array(Array(novelty_envelope.get("allowed_range", [])))
	normalized["novelty_envelope"] = novelty_envelope
	var taste_profile: Dictionary = Dictionary(normalized.get("taste_profile", {})).duplicate(true)
	for key in ["preferred_topologies", "preferred_horizons", "preferred_media", "dominant_family_labels", "expression_modes", "horizons"]:
		taste_profile[key] = _unique_string_array(Array(taste_profile.get(key, [])))
	normalized["taste_profile"] = taste_profile
	normalized["personality_band"] = str(normalized.get("personality_band", "disciplined_curiosity")).strip_edges()
	normalized["bounded_surface_ids"] = _unique_string_array(Array(normalized.get("bounded_surface_ids", [])))
	normalized["suppressed_patterns"] = _unique_string_array(Array(normalized.get("suppressed_patterns", [])))
	normalized["revive_candidates"] = _unique_string_array(Array(normalized.get("revive_candidates", [])))
	normalized["summary_lines"] = _unique_string_array(Array(normalized.get("summary_lines", [])))
	return normalized

static func _registry_map(values: Array, key_field: String) -> Dictionary:
	var mapped := {}
	for value in values:
		if not (value is Dictionary):
			continue
		var entry: Dictionary = Dictionary(value).duplicate(true)
		var key := str(entry.get(key_field, "")).strip_edges()
		if key.is_empty():
			continue
		mapped[key] = entry
	return mapped

static func _sorted_registry_array(values: Dictionary, key_field: String) -> Array:
	var entries: Array = []
	var keys: Array[String] = []
	for key in values.keys():
		keys.append(str(key))
	keys.sort()
	for key in keys:
		var entry: Dictionary = Dictionary(values.get(key, {})).duplicate(true)
		if str(entry.get(key_field, "")).strip_edges().is_empty():
			entry[key_field] = key
		entries.append(entry)
	return entries

static func _unique_string_array(values: Array) -> Array:
	var result: Array = []
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _merge_limited(base: Array, extra: Array, limit: int) -> Array[String]:
	var result: Array[String] = _string_array(base)
	for value in _string_array(extra):
		if result.has(value):
			continue
		result.append(value)
		if limit > 0 and result.size() >= limit:
			break
	return result

static func _apply_narrative_pressure_summary(summary: Dictionary, pressure_state: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	var public_lines: Array = Array(pressure_state.get("public_lines", Dictionary(pressure_state.get("constitution_bias", {})).get("public_lines", []))).duplicate(true)
	var surface_summary: Dictionary = Dictionary(next.get("surface_summary", {})).duplicate(true)
	var merged_lines: Array = Array(surface_summary.get("lines", [])).duplicate(true)
	for line in public_lines:
		var text := str(line).strip_edges()
		if not text.is_empty() and not merged_lines.has(text):
			merged_lines.append(text)
		if merged_lines.size() >= 3:
			break
	surface_summary["lines"] = merged_lines
	next["surface_summary"] = surface_summary
	var pressure_line := str(Dictionary(pressure_state.get("constitution_bias", {})).get("pressure_line", next.get("pressure_line", ""))).strip_edges()
	if not pressure_line.is_empty():
		next["pressure_line"] = pressure_line
	var world_goal_hint := str(Dictionary(pressure_state.get("constitution_bias", {})).get("world_goal_hint", next.get("world_goal", ""))).strip_edges()
	if str(next.get("world_goal", "")).strip_edges().is_empty() and not world_goal_hint.is_empty():
		next["world_goal"] = world_goal_hint
	next["narrative_pressure_family"] = str(pressure_state.get("pressure_family", "")).strip_edges()
	next["narrative_pressure_lines"] = public_lines.duplicate()
	next["narrative_pressure_tensions"] = Array(pressure_state.get("dominant_tensions", [])).duplicate(true)
	next["narrative_pressure_momentum"] = int(pressure_state.get("momentum", 0))
	next["narrative_pressure_resonance"] = int(pressure_state.get("resonance", 0))
	next["narrative_pressure_cascade_risk"] = int(pressure_state.get("cascade_risk", 0))
	return next

static func _apply_experimental_summary(summary: Dictionary, experimental_ontology_state: Dictionary) -> Dictionary:
	var next := summary.duplicate(true)
	var public_surface: Dictionary = Dictionary(experimental_ontology_state.get("public_surface", {}))
	var surface_lines: Array = Array(public_surface.get("lines", [])).duplicate(true)
	next["experiment_surface_lines"] = surface_lines.duplicate()
	next["experiment_families"] = Array(public_surface.get("family_labels", [])).duplicate(true)
	next["experiment_expression_modes"] = Array(public_surface.get("expression_modes", [])).duplicate(true)
	next["experiment_horizons"] = Array(public_surface.get("horizons", [])).duplicate(true)
	next["live_hypothesis_ids"] = Array(experimental_ontology_state.get("live_hypothesis_ids", [])).duplicate(true)
	next["live_experiment_ids"] = Array(experimental_ontology_state.get("live_experiment_ids", [])).duplicate(true)
	var surface_summary: Dictionary = Dictionary(next.get("surface_summary", {})).duplicate(true)
	var merged_lines: Array = Array(surface_summary.get("lines", [])).duplicate(true)
	for line in surface_lines:
		var text := str(line).strip_edges()
		if not text.is_empty() and not merged_lines.has(text):
			merged_lines.append(text)
		if merged_lines.size() >= 3:
			break
	surface_summary["lines"] = merged_lines
	next["surface_summary"] = surface_summary
	return next

static func _default_information_doctrine_profile(policy: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"group_tension_bias": str(public_summary.get("group_tension_bias", "")),
		"private_evidence_ratio": int(Dictionary(policy.get("social", {})).get("private_evidence_ratio", 0)),
		"blame_ambiguity": int(Dictionary(policy.get("social", {})).get("blame_ambiguity", 0)),
		"witness_exposure": int(Dictionary(policy.get("generation", {})).get("witness_exposure", 0))
	}

static func _default_pacing_profile(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	return {
		"id": str(public_summary.get("pacing_profile", generation_surface.get("pacing_profile", ""))),
		"label": str(public_summary.get("pacing_label", public_summary.get("pacing_profile", generation_surface.get("pacing_profile", ""))))
	}

static func _default_custody_profile(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	return {
		"artifact_centrality": true,
		"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"convergence_axis": str(public_summary.get("convergence_axis", generation_surface.get("convergence_axis", "")))
	}

static func _default_mutation_permissions(policy: Dictionary) -> Dictionary:
	return {
		"allowed_domains": [
			"route_state",
			"chamber_state",
			"artifact_custody",
			"trace_visibility",
			"pressure_ecology",
			"readability_flags"
		],
		"runtime_non_authority": true,
		"anomaly_budget": int(Dictionary(policy.get("ecology", {})).get("anomaly_contamination", 0))
	}

static func _default_fairness_bounds() -> Dictionary:
	return {
		"artifact_trust_floor": "objective_central",
		"mechanic_legibility_floor": 2,
		"strategic_readability_floor": 2,
		"role_fairness_required": true,
		"runtime_non_mutation_required": true,
		"no_hidden_targeting_required": true,
		"compile_failures": []
	}

static func _build_route_chamber_model(generation_surface: Dictionary, room_count: int) -> Dictionary:
	return {
		"room_count": room_count,
		"branch_family": str(generation_surface.get("branch_family", "")),
		"pressure_verbs": Array(generation_surface.get("pressure_verbs", [])).duplicate(true),
		"symbolic_motifs": Array(generation_surface.get("symbolic_motifs", [])).duplicate(true),
		"item_ecology_bias": str(generation_surface.get("item_ecology_bias", "")),
		"group_tension_bias": str(generation_surface.get("group_tension_bias", "")),
		"archive_tone": str(generation_surface.get("archive_tone", "")),
		"convergence_axis": str(generation_surface.get("convergence_axis", ""))
	}

static func _build_role_surface_model(policy: Dictionary, public_summary: Dictionary) -> Dictionary:
	var social: Dictionary = Dictionary(policy.get("social", {}))
	return {
		"hidden_role_density": int(social.get("hidden_role_density", 0)),
		"obligation_pressure": int(social.get("obligation_pressure", 0)),
		"group_tension_bias": str(public_summary.get("group_tension_bias", "")),
		"dominant_domains": Array(public_summary.get("dominant_domains", [])).duplicate(true)
	}

static func _build_item_ecology(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	return {
		"artifact_families": ["custody_objective"],
		"relic_pools": [],
		"tool_pools": [],
		"trinket_pools": [],
		"pickup_pools": [],
		"covenant_pools": [],
		"curse_pools": [],
		"transformation_lanes": [],
		"item_ecology_bias": str(public_summary.get("item_ecology_bias", generation_surface.get("item_ecology_bias", ""))),
		"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))),
		"modifier_registry": {
			"traversal": ["move_speed_mult", "jump_velocity_mult", "carry_speed_mult"],
			"information": ["noise_trace_interval", "footprint_interval", "trace_visibility_scale"],
			"artifact_custody": ["artifact_aura_radius", "inspection_risk", "custody_seal_strength"]
		},
		"readability_rules": {
			"artifact_carrier_priority": true,
			"max_major_signals": 3
		},
		"forbidden_combos": [],
		"synergy_rules": [],
		"anti_synergy_rules": [],
		"market_regime_ids": Array(public_summary.get("active_regime_ids", [])).duplicate(true),
		"lifecycle_state_ids": Array(public_summary.get("lifecycle_state_ids", [])).duplicate(true)
	}

static func _build_pressure_ecology(policy: Dictionary, public_summary: Dictionary) -> Dictionary:
	var ecology: Dictionary = Dictionary(policy.get("ecology", {}))
	return {
		"inhabitant_pressure": int(ecology.get("inhabitant_pressure", 0)),
		"stalking_bias": int(ecology.get("stalking_bias", 0)),
		"anomaly_contamination": int(ecology.get("anomaly_contamination", 0)),
		"pressure_line": str(public_summary.get("pressure_line", "")),
		"dominant_forces": Array(public_summary.get("dominant_forces", [])).duplicate(true)
	}

static func _build_information_doctrine(policy: Dictionary, public_summary: Dictionary) -> Dictionary:
	var social: Dictionary = Dictionary(policy.get("social", {}))
	return {
		"private_evidence_ratio": int(social.get("private_evidence_ratio", 0)),
		"blame_ambiguity": int(social.get("blame_ambiguity", 0)),
		"witness_exposure": int(Dictionary(policy.get("generation", {})).get("witness_exposure", 0)),
		"pressure_grammar": Array(public_summary.get("pressure_grammar", [])).duplicate(true),
		"public_trace_classes": ["artifact", "noise", "hazard", "extraction"],
		"private_trace_classes": ["inspection", "role_surface", "counterfeit_hint"]
	}

static func _build_custody_law(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	return {
		"artifact_is_objective": true,
		"authenticity_visible_only_by_lawful_checks": true,
		"item_ecology_bias": str(public_summary.get("item_ecology_bias", generation_surface.get("item_ecology_bias", ""))),
		"convergence_axis": str(public_summary.get("convergence_axis", generation_surface.get("convergence_axis", "")))
	}

static func _build_mutation_envelope(policy: Dictionary, public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	return {
		"triggers": [
			"chamber_entered",
			"artifact_picked",
			"artifact_dropped",
			"artifact_stolen",
			"extraction_window_started",
			"stability_threshold_crossed",
			"trust_threshold_crossed",
			"species_escalation",
			"covenant_activated",
			"transformation_threshold_crossed"
		],
		"domains": [
			"route_state",
			"chamber_state",
			"artifact_custody",
			"trace_visibility",
			"pressure_ecology",
			"stability",
			"social_trust",
			"readability_flags"
		],
		"caps": {
			"per_chamber": 1,
			"per_domain": 3,
			"per_expedition": 8
		},
		"pressure_line": str(public_summary.get("pressure_line", "")),
		"convergence_axis": str(public_summary.get("convergence_axis", generation_surface.get("convergence_axis", ""))),
		"anomaly_budget": int(Dictionary(policy.get("ecology", {})).get("anomaly_contamination", 0))
	}

static func _build_continuity_hooks(public_summary: Dictionary, world_goals: Array) -> Dictionary:
	return {
		"archive_tone": str(public_summary.get("archive_tone", "")),
		"world_goals": world_goals.duplicate(true),
		"active_regime_ids": Array(public_summary.get("active_regime_ids", [])).duplicate(true),
		"lifecycle_state_ids": Array(public_summary.get("lifecycle_state_ids", [])).duplicate(true),
		"identity_reward_channel": true,
		"combat_power_carryover": false,
		"traversal_power_carryover": false
	}

static func _default_multimodal_contract() -> Dictionary:
	return {
		"opt_in_only": true,
		"runtime_authority": false,
		"allowed_modalities": ["voice_policy", "gesture_summary", "camera_summary"],
		"allowed_outputs": ["policy_state", "archive_summary", "shell_summary"],
		"forbidden_outputs": ["guilt_score", "role_truth", "artifact_truth", "runtime_targeting"]
	}

static func _build_readability_law(public_summary: Dictionary) -> Dictionary:
	return {
		"artifact_carrier_priority": true,
		"public_trace_priority": true,
		"max_major_vfx_layers": 3,
		"archive_tone": str(public_summary.get("archive_tone", "")),
		"silhouette_integrity_required": true,
		"supported_normalization_modes": Array(public_summary.get("normalization_modes_supported", PRODUCT_CATALOG_SCRIPT.normalization_modes())).duplicate(true),
		"default_normalization_mode": str(public_summary.get("normalization_mode_default", "default")),
		"fairness_sensitive_behavior": "collapse_modulation_to_canonical",
		"all_ages_behavior": "collapse_modulation_to_canonical",
		"forensic_replay_behavior": "collapse_modulation_to_canonical"
	}

static func _build_safety_law(policy: Dictionary) -> Dictionary:
	return {
		"host_authoritative": true,
		"deterministic": true,
		"inspectable": true,
		"opaque_guilt_automation": false,
		"allow_multimodal_authority": false,
		"pressure_budget": Dictionary(policy.get("ecology", {})).duplicate(true),
		"supported_normalization_modes": PRODUCT_CATALOG_SCRIPT.normalization_modes(),
		"all_ages_enforced_surfaces": ["public_guidance", "prestige_urgency_copy", "spectacle_intensity"]
	}

static func _apply_phase2_cosmetic_summary(summary: Dictionary) -> Dictionary:
	var current := Dictionary(summary).duplicate(true)
	current["normalization_modes_supported"] = Array(current.get("normalization_modes_supported", PRODUCT_CATALOG_SCRIPT.normalization_modes())).duplicate(true)
	current["normalization_mode_default"] = str(current.get("normalization_mode_default", "default"))
	if _string_array(current.get("cosmetic_modulation_lines", [])).is_empty():
		current["cosmetic_modulation_lines"] = [
			"Cosmetic modulation stays inside zero-advantage equivalence classes.",
			"Fairness-sensitive and replay-safe modes collapse to the canonical member."
		]
	return current

static func _apply_phase3_market_summary(summary: Dictionary, market_regime_state: Dictionary, lifecycle_registry: Dictionary) -> Dictionary:
	var current := Dictionary(summary).duplicate(true)
	var active_regime_ids := _string_array(current.get("active_regime_ids", []))
	if active_regime_ids.is_empty():
		active_regime_ids = _string_array(market_regime_state.get("active_regime_ids", []))
	current["active_regime_ids"] = active_regime_ids
	var lifecycle_state_ids := _string_array(current.get("lifecycle_state_ids", []))
	if lifecycle_state_ids.is_empty():
		lifecycle_state_ids = _string_array(lifecycle_registry.get("active_state_ids", []))
	current["lifecycle_state_ids"] = lifecycle_state_ids
	var market_regime_lines := _string_array(current.get("market_regime_lines", []))
	if market_regime_lines.is_empty():
		market_regime_lines = _string_array(market_regime_state.get("summary_lines", []))
	current["market_regime_lines"] = market_regime_lines
	var lifecycle_lines := _string_array(current.get("lifecycle_lines", []))
	if lifecycle_lines.is_empty():
		lifecycle_lines = _string_array(lifecycle_registry.get("lines", []))
	current["lifecycle_lines"] = lifecycle_lines
	var market_regime_id := str(current.get("market_regime_id", "")).strip_edges()
	if market_regime_id.is_empty():
		market_regime_id = str(market_regime_state.get("regime_id", "")).strip_edges()
	current["market_regime_id"] = market_regime_id
	var market_regime_family := str(current.get("market_regime_family", "")).strip_edges()
	if market_regime_family.is_empty():
		market_regime_family = str(market_regime_state.get("regime_family", "")).strip_edges()
	current["market_regime_family"] = market_regime_family
	var market_prestige_band := str(current.get("market_prestige_band", "")).strip_edges()
	if market_prestige_band.is_empty():
		market_prestige_band = str(market_regime_state.get("prestige_band", "")).strip_edges()
	current["market_prestige_band"] = market_prestige_band
	var market_carrier_risk_band := str(current.get("market_carrier_risk_band", "")).strip_edges()
	if market_carrier_risk_band.is_empty():
		market_carrier_risk_band = str(market_regime_state.get("carrier_risk_band", "")).strip_edges()
	current["market_carrier_risk_band"] = market_carrier_risk_band
	return current

static func _apply_phase_v3_summary(
	summary: Dictionary,
	lineage_registry: Dictionary,
	civilization_surface: Dictionary,
	cognitive_field_state: Dictionary,
	mind_projections: Array,
	theory_surface: Dictionary,
	activation_state: Dictionary,
	explanation_packet: Dictionary,
	review_surface: Dictionary
) -> Dictionary:
	var current := Dictionary(summary).duplicate(true)
	var packet_provenance_version := int(explanation_packet.get("provenance_contract_version", 0))
	if packet_provenance_version <= 0:
		packet_provenance_version = int(current.get("provenance_contract_version", GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION))
	var packet_public_surface_tags := _string_array(explanation_packet.get("public_surface_tags", []))
	if packet_public_surface_tags.is_empty():
		packet_public_surface_tags = _string_array(current.get("public_surface_tags", []))
	var packet_schema_version := int(explanation_packet.get("packet_schema_version", 0))
	if packet_schema_version <= 0:
		packet_schema_version = int(current.get("packet_schema_version", GOVERNANCE_SERVICE_SCRIPT.PACKET_SCHEMA_VERSION))
	var packet_digest := str(explanation_packet.get("packet_digest", "")).strip_edges()
	if packet_digest.is_empty():
		packet_digest = str(current.get("explanation_packet_digest", "")).strip_edges()
	var packet_summary_lines := _string_array(explanation_packet.get("summary_lines", []))
	if packet_summary_lines.is_empty():
		packet_summary_lines = _string_array(current.get("explanation_packet_lines", []))
	var packet_immediate_lines := _lane_summary_lines(Array(explanation_packet.get("immediate", [])))
	if packet_immediate_lines.is_empty():
		packet_immediate_lines = _string_array(current.get("explanation_immediate_lines", []))
	var packet_run_lines := _lane_summary_lines(Array(explanation_packet.get("run", [])))
	if packet_run_lines.is_empty():
		packet_run_lines = _string_array(current.get("explanation_run_lines", []))
	var packet_meta_lines := _lane_summary_lines(Array(explanation_packet.get("meta", [])))
	if packet_meta_lines.is_empty():
		packet_meta_lines = _string_array(current.get("explanation_meta_lines", []))
	var packet_signal_budget_lines := _signal_budget_lines(Dictionary(explanation_packet.get("compression_profile", {})))
	if packet_signal_budget_lines.is_empty():
		packet_signal_budget_lines = _string_array(current.get("signal_budget_lines", []))
	current["lineage_registry_ids"] = _sorted_strings(lineage_registry.keys())
	current["civilization_surface_lines"] = _string_array(civilization_surface.get("lines", []))
	current["civilization_faction_ids"] = _string_array(civilization_surface.get("faction_ids", []))
	current["civilization_regime_ids"] = _string_array(civilization_surface.get("regime_ids", []))
	current["world_mutation_ids"] = _string_array(civilization_surface.get("world_mutation_ids", []))
	current["cognitive_field_summary_lines"] = _string_array(cognitive_field_state.get("summary_lines", []))
	current["cognitive_field_dimensions"] = _sorted_strings(Dictionary(cognitive_field_state.get("field_vectors", {})).keys())
	current["mind_projection_ids"] = _mind_projection_ids(mind_projections)
	current["theory_surface_lines"] = _string_array(theory_surface.get("lines", []))
	current["theory_ids"] = _string_array(theory_surface.get("theory_ids", []))
	current["theory_school_ids"] = _string_array(theory_surface.get("school_ids", []))
	current["theory_statuses"] = _string_array(theory_surface.get("statuses", []))
	current["activation_epoch"] = str(activation_state.get("epoch", "inactive")).strip_edges()
	current["activation_active_channels"] = _string_array(activation_state.get("active_channels", []))
	current["activation_dormant_channels"] = _string_array(activation_state.get("dormant_channels", []))
	current["activation_lines"] = _string_array(activation_state.get("activation_lines", []))
	current["safe_mode_active"] = bool(activation_state.get("safe_mode_active", false))
	current["safe_mode_lines"] = _string_array(Dictionary(activation_state.get("safe_mode_state", {})).get("summary_lines", []))
	current["provenance_contract_version"] = packet_provenance_version
	current["public_surface_tags"] = packet_public_surface_tags
	current["packet_schema_version"] = packet_schema_version
	current["explanation_packet_digest"] = packet_digest
	current["explanation_packet_lines"] = packet_summary_lines
	current["explanation_immediate_lines"] = packet_immediate_lines
	current["explanation_run_lines"] = packet_run_lines
	current["explanation_meta_lines"] = packet_meta_lines
	current["review_surface_lines"] = _string_array(review_surface.get("lines", []))
	current["signal_budget_lines"] = packet_signal_budget_lines
	return current

static func _normalize_civilization_surface(raw: Dictionary) -> Dictionary:
	var current := {
		"lines": [],
		"faction_ids": [],
		"regime_ids": [],
		"market_regime_ids": [],
		"lifecycle_state_ids": [],
		"region_ids": [],
		"world_mutation_ids": [],
		"literacy_track_ids": [],
		"market_regime_lines": [],
		"lifecycle_lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["lines"] = _string_array(current.get("lines", []))
	current["faction_ids"] = _string_array(current.get("faction_ids", []))
	current["regime_ids"] = _string_array(current.get("regime_ids", []))
	current["market_regime_ids"] = _string_array(current.get("market_regime_ids", []))
	current["lifecycle_state_ids"] = _string_array(current.get("lifecycle_state_ids", []))
	current["region_ids"] = _string_array(current.get("region_ids", []))
	current["world_mutation_ids"] = _string_array(current.get("world_mutation_ids", []))
	current["literacy_track_ids"] = _string_array(current.get("literacy_track_ids", []))
	current["market_regime_lines"] = _string_array(current.get("market_regime_lines", []))
	current["lifecycle_lines"] = _string_array(current.get("lifecycle_lines", []))
	return current

static func _normalize_cognitive_field_state(raw: Dictionary) -> Dictionary:
	var current := {
		"schema_name": "CognitiveFieldState",
		"schema_version": 1,
		"field_vectors": {},
		"interaction_rules": [],
		"derived_mind_ids": [],
		"personality_band": "disciplined_curiosity",
		"self_interpretation_trace": [],
		"unknown_space_markers": [],
		"summary_lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["field_vectors"] = Dictionary(current.get("field_vectors", {})).duplicate(true)
	current["interaction_rules"] = _string_array(current.get("interaction_rules", []))
	current["derived_mind_ids"] = _string_array(current.get("derived_mind_ids", []))
	current["personality_band"] = str(current.get("personality_band", "disciplined_curiosity")).strip_edges()
	if current["personality_band"].is_empty():
		current["personality_band"] = "disciplined_curiosity"
	current["self_interpretation_trace"] = _string_array(current.get("self_interpretation_trace", []))
	current["unknown_space_markers"] = _string_array(current.get("unknown_space_markers", []))
	current["summary_lines"] = _string_array(current.get("summary_lines", []))
	return current

static func _normalize_mind_projections(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["mind_id"] = str(current.get("mind_id", "")).strip_edges()
		current["label"] = str(current.get("label", current.get("mind_id", ""))).strip_edges()
		current["intensity"] = int(current.get("intensity", 0))
		current["derived_from_dimensions"] = _string_array(current.get("derived_from_dimensions", []))
		current["personality_mode"] = str(current.get("personality_mode", "disciplined_curiosity")).strip_edges()
		if current["personality_mode"].is_empty():
			current["personality_mode"] = "disciplined_curiosity"
		current["mind_projection_intent"] = str(current.get("mind_projection_intent", "bounded_interpretation")).strip_edges()
		if current["mind_projection_intent"].is_empty():
			current["mind_projection_intent"] = "bounded_interpretation"
		current["unknown_space_markers"] = _string_array(current.get("unknown_space_markers", []))
		current["self_interpretation_line"] = str(current.get("self_interpretation_line", "")).strip_edges()
		if not current["mind_id"].is_empty():
			result.append(current)
	return result

static func _normalize_theory_surface(raw: Dictionary) -> Dictionary:
	var current := {
		"lines": [],
		"theory_ids": [],
		"school_ids": [],
		"statuses": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["lines"] = _string_array(current.get("lines", []))
	current["theory_ids"] = _string_array(current.get("theory_ids", []))
	current["school_ids"] = _string_array(current.get("school_ids", []))
	current["statuses"] = _string_array(current.get("statuses", []))
	return current

static func _normalize_market_regime_state(raw: Dictionary) -> Dictionary:
	var current := {
		"regime_id": "market_balanced_exchange",
		"regime_family": "balanced",
		"scarcity_band": "suppressed",
		"prestige_band": "suppressed",
		"carrier_risk_band": "suppressed",
		"anomaly_significance_band": "suppressed",
		"institutional_pressure_band": "suppressed",
		"active_regime_ids": [],
		"summary_lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["regime_id"] = str(current.get("regime_id", "market_balanced_exchange")).strip_edges()
	current["regime_family"] = str(current.get("regime_family", "balanced")).strip_edges()
	current["scarcity_band"] = str(current.get("scarcity_band", "suppressed")).strip_edges()
	current["prestige_band"] = str(current.get("prestige_band", "suppressed")).strip_edges()
	current["carrier_risk_band"] = str(current.get("carrier_risk_band", "suppressed")).strip_edges()
	current["anomaly_significance_band"] = str(current.get("anomaly_significance_band", "suppressed")).strip_edges()
	current["institutional_pressure_band"] = str(current.get("institutional_pressure_band", "suppressed")).strip_edges()
	current["active_regime_ids"] = _string_array(current.get("active_regime_ids", []))
	if current["active_regime_ids"].is_empty() and not str(current.get("regime_id", "")).strip_edges().is_empty():
		current["active_regime_ids"] = [str(current.get("regime_id", "")).strip_edges()]
	current["summary_lines"] = _string_array(current.get("summary_lines", []))
	return current

static func _normalize_market_memory_state(raw: Dictionary) -> Dictionary:
	var current := {
		"active_regime_ids": [],
		"extraction_debt": 0,
		"hoard_heat": 0,
		"neglect_heat": 0,
		"distortion_heat": 0,
		"recovery_credit": 0,
		"prestige_climate": "",
		"carrier_risk_band": "suppressed",
		"lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["active_regime_ids"] = _string_array(current.get("active_regime_ids", []))
	current["extraction_debt"] = int(current.get("extraction_debt", 0))
	current["hoard_heat"] = int(current.get("hoard_heat", 0))
	current["neglect_heat"] = int(current.get("neglect_heat", 0))
	current["distortion_heat"] = int(current.get("distortion_heat", 0))
	current["recovery_credit"] = int(current.get("recovery_credit", 0))
	current["prestige_climate"] = str(current.get("prestige_climate", "")).strip_edges()
	current["carrier_risk_band"] = str(current.get("carrier_risk_band", "suppressed")).strip_edges()
	current["lines"] = _string_array(current.get("lines", []))
	return current

static func _normalize_lifecycle_registry(raw: Dictionary) -> Dictionary:
	var current := {
		"families": [],
		"active_state_ids": [],
		"lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	var families: Array[Dictionary] = []
	for family_raw in Array(current.get("families", [])):
		var family: Dictionary = Dictionary(family_raw).duplicate(true)
		family["family_id"] = str(family.get("family_id", "")).strip_edges()
		family["family_kind"] = str(family.get("family_kind", "market")).strip_edges()
		family["source_id"] = str(family.get("source_id", family.get("family_id", ""))).strip_edges()
		family["state"] = str(family.get("state", "emerging")).strip_edges()
		family["heat"] = int(family.get("heat", 0))
		family["saturation"] = int(family.get("saturation", 0))
		family["strain"] = int(family.get("strain", 0))
		family["cooling_tags"] = _string_array(family.get("cooling_tags", []))
		family["cooldown_band"] = str(family.get("cooldown_band", "open")).strip_edges()
		family["successor_hint"] = str(family.get("successor_hint", "")).strip_edges()
		family["return_window"] = str(family.get("return_window", "")).strip_edges()
		family["routing_tags"] = _string_array(family.get("routing_tags", []))
		family["dominance_strain"] = int(family.get("dominance_strain", family.get("strain", 0)))
		family["throttle_state"] = str(family.get("throttle_state", "open")).strip_edges()
		family["resurrection_priority"] = int(family.get("resurrection_priority", 0))
		if not str(family.get("family_id", "")).strip_edges().is_empty():
			families.append(family)
	current["families"] = families
	current["active_state_ids"] = _string_array(current.get("active_state_ids", []))
	if current["active_state_ids"].is_empty():
		for family in families:
			var family_id := str(Dictionary(family).get("family_id", "")).strip_edges()
			if not family_id.is_empty():
				current["active_state_ids"].append(family_id)
	current["lines"] = _string_array(current.get("lines", []))
	return current

static func _normalize_explanation_packet(raw: Dictionary) -> Dictionary:
	var current := GOVERNANCE_SERVICE_SCRIPT.build_explanation_packet({}, [], [], [])
	for key in raw.keys():
		current[key] = raw[key]
	current["packet_id"] = str(current.get("packet_id", "packet_constitution")).strip_edges()
	if current["packet_id"].is_empty():
		current["packet_id"] = "packet_constitution"
	current["artifact_type"] = str(current.get("artifact_type", "expedition_constitution")).strip_edges()
	current["packet_schema_version"] = int(current.get("packet_schema_version", GOVERNANCE_SERVICE_SCRIPT.PACKET_SCHEMA_VERSION))
	current["provenance_contract_version"] = int(current.get("provenance_contract_version", GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION))
	current["summary_lines"] = _string_array(current.get("summary_lines", []))
	current["operator_lines"] = _string_array(current.get("operator_lines", []))
	current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
	current["public_surface_tags"] = _string_array(current.get("public_surface_tags", []))
	current["provenance_source_refs"] = _string_array(current.get("provenance_source_refs", []))
	current["play_routing_contract"] = Dictionary(current.get("play_routing_contract", {})).duplicate(true)
	current["compression_profile"] = GOVERNANCE_SERVICE_SCRIPT.normalize_signal_compression_profile(
		Dictionary(current.get("compression_profile", {}))
	)
	current["priority_channels"] = _string_array(current.get("priority_channels", []))
	current["fairness_flags"] = _string_array(current.get("fairness_flags", []))
	current["immediate"] = GOVERNANCE_SERVICE_SCRIPT._normalize_explanation_layer(Array(current.get("immediate", [])))
	current["run"] = GOVERNANCE_SERVICE_SCRIPT._normalize_explanation_layer(Array(current.get("run", [])))
	current["meta"] = GOVERNANCE_SERVICE_SCRIPT._normalize_explanation_layer(Array(current.get("meta", [])))
	current["packet_digest"] = str(current.get("packet_digest", "")).strip_edges()
	return current

static func _normalize_review_surface(raw: Dictionary) -> Dictionary:
	var current := {
		"lines": [],
		"active_channels": [],
		"dormant_channels": [],
		"promotion_review": {}
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["lines"] = _string_array(current.get("lines", []))
	current["active_channels"] = _string_array(current.get("active_channels", []))
	current["dormant_channels"] = _string_array(current.get("dormant_channels", []))
	var promotion_review: Dictionary = Dictionary(current.get("promotion_review", {})).duplicate(true)
	current["promotion_review"] = {
		"eligible_count": maxi(int(promotion_review.get("eligible_count", 0)), 0),
		"cooling_count": maxi(int(promotion_review.get("cooling_count", 0)), 0),
		"contested_count": maxi(int(promotion_review.get("contested_count", 0)), 0),
		"summary_line": str(promotion_review.get("summary_line", "")).strip_edges()
	}
	return current

static func _lane_summary_lines(values: Array) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in values:
		var entry := Dictionary(entry_raw)
		var line := _first_string([
			str(entry.get("interpretation", "")).strip_edges(),
			str(entry.get("trigger", "")).strip_edges(),
			str(entry.get("consequence", "")).strip_edges()
		], "")
		if not line.is_empty() and not result.has(line):
			result.append(line)
	return result

static func _signal_budget_lines(profile: Dictionary) -> Array[String]:
	if profile.is_empty():
		return []
	var priority := _string_array(profile.get("telegraph_priority", []))
	var lines: Array[String] = []
	lines.append("Signal budget: %d channels, %d lines per layer" % [
		int(profile.get("max_visible_channels", 0)),
		int(profile.get("max_lines_per_layer", 0))
	])
	if not priority.is_empty():
		lines.append("Priority: %s" % ", ".join(priority))
	lines.append("Residue budget: %d" % int(profile.get("residue_budget", 0)))
	return _string_array(lines)

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _sorted_strings(values: Array) -> Array[String]:
	var result := _string_array(values)
	result.sort()
	return result

static func _mind_projection_ids(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var mind_id := str(Dictionary(value).get("mind_id", "")).strip_edges()
		if not mind_id.is_empty() and not result.has(mind_id):
			result.append(mind_id)
	return result

static func _first_string(values: Array, fallback: String = "") -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _canonical_string(value: Variant) -> String:
	match typeof(value):
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			var key_texts: Array[String] = []
			var key_lookup: Dictionary = {}
			for key in dict.keys():
				var text := str(key)
				key_texts.append(text)
				key_lookup[text] = key
			key_texts.sort()
			var parts: Array[String] = []
			for key_text in key_texts:
				parts.append("%s:%s" % [JSON.stringify(key_text), _canonical_string(dict.get(key_lookup[key_text]))])
			return "{%s}" % ",".join(parts)
		TYPE_ARRAY:
			var parts: Array[String] = []
			for entry in value:
				parts.append(_canonical_string(entry))
			return "[%s]" % ",".join(parts)
		_:
			return JSON.stringify(value)
