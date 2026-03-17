class_name ExpeditionConstitutionSchema
extends RefCounted

const SCHEMA_VERSION := 1
const DELVEMIND_EXPERIMENT_ENGINE_SCRIPT = preload("res://src/product/delvemind_experiment_engine.gd")

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
		"constitution_summary": public_summary.duplicate(true),
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
		"information_doctrine_profile": Dictionary(compile_outputs.get("information_doctrine_profile", _default_information_doctrine_profile(policy, public_summary))).duplicate(true),
		"pacing_profile": Dictionary(compile_outputs.get("pacing_profile", _default_pacing_profile(public_summary, generation_surface))).duplicate(true),
		"custody_profile": Dictionary(compile_outputs.get("custody_profile", _default_custody_profile(public_summary, generation_surface))).duplicate(true),
		"mutation_permissions": Dictionary(compile_outputs.get("mutation_permissions", _default_mutation_permissions(policy))).duplicate(true),
		"symbolic_motifs": Array(compile_outputs.get("symbolic_motifs", public_summary.get("symbolic_motifs", generation_surface.get("symbolic_motifs", [])))).duplicate(true),
		"fairness_bounds": Dictionary(compile_outputs.get("fairness_bounds", _default_fairness_bounds())).duplicate(true),
		"route_chamber_model": _build_route_chamber_model(generation_surface, room_count),
		"role_surface_model": _build_role_surface_model(policy, public_summary),
		"item_ecology": _build_item_ecology(public_summary, generation_surface),
		"pressure_ecology": _build_pressure_ecology(policy, public_summary),
		"information_doctrine": _build_information_doctrine(policy, public_summary),
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
	if not normalized.has("schema_version"):
		normalized["schema_version"] = SCHEMA_VERSION
	if not normalized.has("constitution_version"):
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
	return {
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
		"experiment_surface_lines": [],
		"experiment_families": [],
		"experiment_expression_modes": [],
		"experiment_horizons": [],
		"surface_summary": {
			"lines": Array(surface_summary.get("lines", [])).duplicate(true)
		}
	}

static func build_runtime_summary(summary: Dictionary, constitution_hash: String = "") -> Dictionary:
	var normalized_summary := Dictionary(summary).duplicate(true)
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
	var summary: Dictionary = Dictionary(normalized.get("constitution_summary", normalized.get("public_summary", {}))).duplicate(true)
	if not str(normalized.get("constitution_hash", "")).strip_edges().is_empty():
		summary["constitution_hash"] = str(normalized.get("constitution_hash", ""))
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
		"ontology_routing": Dictionary(generation_surface.get("ontology_routing", {})).duplicate(true)
	}

static func _default_item_ecology_profile(public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	return {
		"item_ecology_bias": str(public_summary.get("item_ecology_bias", generation_surface.get("item_ecology_bias", ""))),
		"symbolic_motifs": Array(public_summary.get("symbolic_motifs", generation_surface.get("symbolic_motifs", []))).duplicate(true),
		"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", "")))
	}

static func _default_pressure_ecology_profile(policy: Dictionary, public_summary: Dictionary) -> Dictionary:
	return {
		"pressure_line": str(public_summary.get("pressure_line", "")),
		"pressure_verbs": Array(public_summary.get("pressure_grammar", [])).duplicate(true),
		"inhabitant_pressure": int(Dictionary(policy.get("ecology", {})).get("inhabitant_pressure", 0)),
		"stalking_bias": int(Dictionary(policy.get("ecology", {})).get("stalking_bias", 0)),
		"anomaly_contamination": int(Dictionary(policy.get("ecology", {})).get("anomaly_contamination", 0))
	}

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
		"compile_outputs": {},
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
	var rebuilt_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({
		"hypotheses": _registry_map(Array(normalized.get("hypothesis_registry", [])), "hypothesis_id"),
		"experiments": _registry_map(Array(normalized.get("experiment_registry", [])), "experiment_id")
	})
	normalized["hypothesis_registry"] = _sorted_registry_array(Dictionary(rebuilt_state.get("hypotheses", {})), "hypothesis_id")
	normalized["experiment_registry"] = _sorted_registry_array(Dictionary(rebuilt_state.get("experiments", {})), "experiment_id")
	normalized["live_hypothesis_ids"] = _unique_string_array(Array(normalized.get("live_hypothesis_ids", [])))
	normalized["live_experiment_ids"] = _unique_string_array(Array(normalized.get("live_experiment_ids", [])))
	normalized["live_hypotheses"] = _sorted_registry_array(_registry_map(Array(normalized.get("live_hypotheses", [])), "hypothesis_id"), "hypothesis_id")
	normalized["live_experiments"] = _sorted_registry_array(_registry_map(Array(normalized.get("live_experiments", [])), "experiment_id"), "experiment_id")
	normalized["dominant_families"] = _unique_string_array(Array(normalized.get("dominant_families", [])))
	normalized["lineage_index"] = Dictionary(rebuilt_state.get("lineage_index", {})).duplicate(true)
	normalized["grammar_manifest"] = Array(normalized.get("grammar_manifest", [])).duplicate(true)
	normalized["compile_outputs"] = Dictionary(normalized.get("compile_outputs", {})).duplicate(true)
	var public_surface: Dictionary = Dictionary(normalized.get("public_surface", {})).duplicate(true)
	public_surface["lines"] = _unique_string_array(Array(public_surface.get("lines", [])))
	public_surface["family_labels"] = _unique_string_array(Array(public_surface.get("family_labels", [])))
	public_surface["expression_modes"] = _unique_string_array(Array(public_surface.get("expression_modes", [])))
	public_surface["horizons"] = _unique_string_array(Array(public_surface.get("horizons", [])))
	normalized["public_surface"] = public_surface
	normalized["compiler_trace"] = Dictionary(normalized.get("compiler_trace", {})).duplicate(true)
	normalized["validation_failures"] = DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.validate_compile_state(normalized)
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
		"anti_synergy_rules": []
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
		"silhouette_integrity_required": true
	}

static func _build_safety_law(policy: Dictionary) -> Dictionary:
	return {
		"host_authoritative": true,
		"deterministic": true,
		"inspectable": true,
		"opaque_guilt_automation": false,
		"allow_multimodal_authority": false,
		"pressure_budget": Dictionary(policy.get("ecology", {})).duplicate(true)
	}

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
