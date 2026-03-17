class_name OntologyEngine
extends RefCounted

const SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")

static func build_snapshot(seed_value: int, world_model: Dictionary, doctrine: Dictionary, public_summary: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var schema := SCHEMA_REGISTRY_SCRIPT.ontology_schema()
	var doctrine_family: Dictionary = SCHEMA_REGISTRY_SCRIPT.doctrine_family(str(doctrine.get("id", "")))
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var doctrine_model: Dictionary = Dictionary(world_model.get("doctrine_model", {}))
	var route_model: Dictionary = Dictionary(world_model.get("route_model", {}))
	var nodes: Array[Dictionary] = []
	nodes.append(_artifact_node(public_summary, cultural))
	nodes.append(_chamber_node(generation_surface, route_model))
	nodes.append(_pressure_node(public_summary, generation_surface, cultural))
	nodes.append(_doctrine_node(doctrine, doctrine_family, doctrine_model))
	nodes.append(_ritual_node(doctrine, doctrine_family, cultural, generation_surface))
	nodes.append(_transformation_node(public_summary, cultural, generation_surface))
	nodes.append(_taxonomy_node(public_summary, cultural))
	nodes.append(_verification_node(cultural))
	nodes.append(_residue_node(public_summary, cultural))
	for family_raw in SCHEMA_REGISTRY_SCRIPT.experiment_families():
		nodes.append(_experiment_node(Dictionary(family_raw)))
	var hybrids := _hybrid_nodes(nodes, cultural, generation_surface)
	var absent_nodes := _absence_nodes(cultural, public_summary)
	var snapshot := {
		"schema_name": str(schema.get("schema_name", "OntologySnapshot")),
		"schema_version": int(schema.get("schema_version", 1)),
		"seed": seed_value,
		"nodes": _sorted_dict_array(nodes),
		"hybrid_nodes": _sorted_dict_array(hybrids),
		"absent_nodes": _sorted_dict_array(absent_nodes),
		"lineages": _lineages_from_nodes(nodes, hybrids),
		"niche_pressure": _niche_pressure(nodes, hybrids),
		"dominant_domains": _dominant_domains(nodes, hybrids),
		"rediscovery_candidates": _rediscovery_candidates(nodes, absent_nodes),
		"public_lines": _public_lines(nodes, hybrids, absent_nodes),
		"trace": {
			"doctrine_family": str(doctrine.get("id", "")),
			"branch_family": str(generation_surface.get("branch_family", "")),
			"archive_tone": str(public_summary.get("archive_tone", generation_surface.get("archive_tone", ""))),
			"convergence_axis": str(public_summary.get("convergence_axis", generation_surface.get("convergence_axis", "")))
		}
	}
	snapshot["validation_failures"] = validate_snapshot(snapshot)
	return snapshot

static func build_generation_routing(snapshot: Dictionary, generation_surface: Dictionary, doctrine_family: Dictionary = {}) -> Dictionary:
	var nodes: Array = Array(snapshot.get("nodes", []))
	var hybrids: Array = Array(snapshot.get("hybrid_nodes", []))
	var absent_nodes: Array = Array(snapshot.get("absent_nodes", []))
	var niche_pressure: Dictionary = Dictionary(snapshot.get("niche_pressure", {}))
	var route_bias_tags: Array[String] = []
	var item_bias_tags: Array[String] = []
	var pressure_bias_tags: Array[String] = []
	for node_raw in nodes:
		var node: Dictionary = Dictionary(node_raw)
		var domain := str(node.get("domain", ""))
		var lifecycle_state := str(node.get("lifecycle_state", ""))
		var status := str(node.get("status", ""))
		var lineage_id := str(node.get("lineage_id", ""))
		var niches := _string_array(node.get("niches", []))
		if domain == "artifact_families" and status == "active":
			item_bias_tags.append("artifact_lineage:%s" % lineage_id)
			if niches.has("civic_trust_niche"):
				route_bias_tags.append("custody_routes")
		if domain == "chamber_families" and status == "active":
			route_bias_tags.append("chamber_lineage:%s" % lineage_id)
		if domain == "pressure_families" and status == "active":
			pressure_bias_tags.append("pressure_lineage:%s" % lineage_id)
		if domain == "ritual_families" and status in ["active", "rediscovered"]:
			item_bias_tags.append("ritual_significance")
			route_bias_tags.append("ritual_commitment")
		if domain == "verification_classes" and status in ["active", "contested"]:
			item_bias_tags.append("verification_dispute")
			pressure_bias_tags.append("verification_instability")
		if domain == "residue_classes" and status in ["active", "residue_only"]:
			item_bias_tags.append("archive_residue")
		if lifecycle_state == "rediscovery":
			route_bias_tags.append("rediscovery_loop")
			item_bias_tags.append("rediscovered_tooling")
		if lifecycle_state == "fragmentation":
			pressure_bias_tags.append("fragmented_publics")
		if lifecycle_state == "contestation":
			pressure_bias_tags.append("contested_legitimacy")
	for hybrid_raw in hybrids:
		var hybrid: Dictionary = Dictionary(hybrid_raw)
		var hybrid_id := str(hybrid.get("id", ""))
		if not hybrid_id.is_empty():
			route_bias_tags.append("hybrid:%s" % hybrid_id)
			item_bias_tags.append("hybrid:%s" % hybrid_id)
	for absent_raw in absent_nodes:
		var absent: Dictionary = Dictionary(absent_raw)
		match str(absent.get("absence_type", "")):
			"taboo_class":
				route_bias_tags.append("taboo_threshold")
				pressure_bias_tags.append("taboo_pressure")
			"missing_verification_method":
				item_bias_tags.append("verification_dispute")
				pressure_bias_tags.append("contested_legitimacy")
			"dormant_ritual_mode":
				item_bias_tags.append("rediscovered_tooling")
			"residue_only_class":
				item_bias_tags.append("archive_residue")
	var routing := {
		"dominant_domains": _string_array(snapshot.get("dominant_domains", [])),
		"dominant_lineages": _dominant_lineage_ids(nodes, hybrids),
		"route_bias_tags": _string_array(route_bias_tags),
		"item_bias_tags": _string_array(item_bias_tags),
		"pressure_bias_tags": _string_array(pressure_bias_tags),
		"hybridization_bias": mini(Array(hybrids).size(), 3),
		"rediscovery_bias": mini(Array(snapshot.get("rediscovery_candidates", [])).size(), 3),
		"taboo_bias": mini(_absence_count(absent_nodes, "taboo_class"), 3),
		"verification_instability": mini(int(niche_pressure.get("verification_niche", 0)), 3),
		"public_lines": _string_array(snapshot.get("public_lines", [])).slice(0, 2)
	}
	if str(Dictionary(doctrine_family.get("inheritance", {})).get("archive_tone", "")).to_lower().find("memory") != -1:
		routing["item_bias_tags"] = _string_array(Array(routing.get("item_bias_tags", [])) + ["archive_residue"])
	if str(generation_surface.get("convergence_axis", "")).to_lower().find("fragment") != -1:
		routing["pressure_bias_tags"] = _string_array(Array(routing.get("pressure_bias_tags", [])) + ["fragmented_publics"])
	return routing

static func validate_snapshot(snapshot: Dictionary) -> Array[String]:
	var schema := SCHEMA_REGISTRY_SCRIPT.ontology_schema()
	var failures: Array[String] = []
	var allowed_domains := _string_array(schema.get("domains", []))
	var allowed_states := _string_array(schema.get("lifecycle_states", []))
	var required_node_fields := _string_array(schema.get("required_node_fields", []))
	for node_raw in Array(snapshot.get("nodes", [])) + Array(snapshot.get("hybrid_nodes", [])):
		var node: Dictionary = Dictionary(node_raw)
		for field in required_node_fields:
			if not node.has(field):
				failures.append("ontology node missing %s" % field)
		if not allowed_domains.has(str(node.get("domain", ""))):
			failures.append("ontology node has invalid domain %s" % str(node.get("domain", "")))
		if not allowed_states.has(str(node.get("lifecycle_state", ""))):
			failures.append("ontology node has invalid lifecycle_state %s" % str(node.get("lifecycle_state", "")))
	return failures

static func _artifact_node(public_summary: Dictionary, cultural: Dictionary) -> Dictionary:
	var archive_tone := str(public_summary.get("archive_tone", "")).to_lower()
	var item_bias := str(public_summary.get("item_ecology_bias", "")).to_lower()
	var label := "Artifact Custody"
	var lineage_id := "artifact_custody_lineage"
	if archive_tone.find("memory") != -1 or item_bias.find("burden") != -1:
		label = "Memory Custody"
		lineage_id = "artifact_memory_lineage"
	var heat := 2 + int(cultural.get("custody_pressure", 0)) + int(cultural.get("legitimacy_pressure", 0))
	var gravity := 1 + int(cultural.get("burial_pressure", 0)) + int(cultural.get("sacred_pressure", 0))
	return _build_node("artifact:%s" % lineage_id, label, "artifact_families", lineage_id, ["civic_trust_niche", "verification_niche"], heat, gravity, _resolve_lifecycle_state(heat, gravity, false, false, false, false), "active", ["artifact centrality", "custody law"], "Artifact custody is pulling proof toward %s." % label.to_lower())

static func _chamber_node(generation_surface: Dictionary, route_model: Dictionary) -> Dictionary:
	var branch_family := str(generation_surface.get("branch_family", "watcher_steps")).strip_edges()
	var label := branch_family.replace("_", " ").capitalize()
	var heat := 1 + int(route_model.get("route_control", 0)) + int(route_model.get("rescue_geometry", 0)) / 2
	var gravity := 1 + int(route_model.get("bottleneck_sensitivity", 0)) + int(route_model.get("loop_familiarity", 0)) / 2
	var fragment := str(generation_surface.get("convergence_axis", "")).to_lower().find("fragment") != -1
	return _build_node("chamber:%s" % branch_family, label, "chamber_families", "chamber_%s" % branch_family, ["traversal_pressure_niche", "archive_classification_niche"], heat, gravity, _resolve_lifecycle_state(heat, gravity, false, fragment, false, false), "active", ["branch family"], "%s is steering where the argument can travel." % label)

static func _pressure_node(public_summary: Dictionary, generation_surface: Dictionary, cultural: Dictionary) -> Dictionary:
	var pressure_verbs := _string_array(public_summary.get("pressure_grammar", generation_surface.get("pressure_verbs", [])))
	var label := "Measured Pressure"
	if not pressure_verbs.is_empty():
		label = "%s Pressure" % pressure_verbs[0]
	var heat := pressure_verbs.size() + int(cultural.get("paranoia_heat", 0)) + int(cultural.get("contradiction_heat", 0))
	var gravity := 1 + int(cultural.get("witness_network_pressure", 0)) + int(cultural.get("rumor_shock_pressure", 0))
	var fragment := false
	for token in pressure_verbs:
		if token.to_lower().find("fragment") != -1 or token.to_lower().find("misdirection") != -1:
			fragment = true
			break
	return _build_node("pressure:%s" % label.to_lower().replace(" ", "_"), label, "pressure_families", "pressure_%s" % label.to_lower().replace(" ", "_"), ["public_argument_niche", "traversal_pressure_niche"], heat, gravity, _resolve_lifecycle_state(heat, gravity, false, fragment, false, false), "active", pressure_verbs, "%s is shaping what the route keeps asking." % label)

static func _doctrine_node(doctrine: Dictionary, doctrine_family: Dictionary, doctrine_model: Dictionary) -> Dictionary:
	var doctrine_id := str(doctrine.get("id", "delve_trial")).strip_edges()
	var label := str(doctrine.get("label", "Delve Trial")).strip_edges()
	var stale := _string_array(doctrine_model.get("stale_doctrines", [])).has(doctrine_id)
	var heat := 2 + int(Dictionary(doctrine_model.get("doctrine_counts", {})).get(doctrine_id, 0))
	var gravity := 1 + _string_array(doctrine_family.get("niches", [])).size()
	return _build_node("doctrine:%s" % doctrine_id, label, "doctrine_families", str(doctrine_family.get("lineage_id", "%s_lineage" % doctrine_id)), _string_array(doctrine_family.get("niches", [])), heat, gravity, _resolve_lifecycle_state(heat, gravity, stale, false, stale, false), "active" if not stale else "contested", _string_array(doctrine_family.get("focus_tags", [])), "%s is still coloring the expedition doctrine." % label)

static func _ritual_node(doctrine: Dictionary, doctrine_family: Dictionary, cultural: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var focus_tags := _string_array(doctrine.get("focus_tags", doctrine_family.get("focus_tags", [])))
	var archive_tone := str(generation_surface.get("archive_tone", "")).to_lower()
	var heat := int(cultural.get("burial_pressure", 0)) + int(cultural.get("sacred_pressure", 0))
	if focus_tags.has("ritual") or archive_tone.find("custody") != -1:
		heat += 2
	var taboo := int(cultural.get("taboo_heat", 0)) >= 2
	var dormant := heat <= 1 and int(cultural.get("silence_pressure", 0)) >= 2
	var rediscovery := dormant and int(cultural.get("revision_pressure", 0)) >= 2
	return _build_node("ritual:custody_rite", "Custody Rite", "ritual_families", "ritual_custody_lineage", ["ritual_legitimacy_niche", "archive_classification_niche"], heat, 1 + int(cultural.get("legitimacy_pressure", 0)), _resolve_lifecycle_state(heat, 1 + int(cultural.get("legitimacy_pressure", 0)), false, taboo, dormant, rediscovery), "taboo" if taboo else ("rediscovered" if rediscovery else ("dormant" if dormant else "active")), ["ritual custody", "witness rite"], "Ritual custody keeps bending the route toward witnessable proof.")

static func _transformation_node(public_summary: Dictionary, cultural: Dictionary, generation_surface: Dictionary) -> Dictionary:
	var convergence_axis := str(public_summary.get("convergence_axis", generation_surface.get("convergence_axis", ""))).to_lower()
	var heat := int(cultural.get("counterfactual_heat", 0)) + int(cultural.get("ontology_heat", 0))
	if convergence_axis.find("fragment") != -1:
		heat += 2
	var dormant := heat <= 1
	var rediscovery := dormant and int(cultural.get("myth_gravity", 0)) >= 4
	return _build_node("transformation:threshold_shift", "Threshold Shift", "transformation_families", "threshold_shift_lineage", ["threshold_pressure_niche", "public_argument_niche"], heat, 1 + int(cultural.get("counterfactual_heat", 0)), _resolve_lifecycle_state(heat, 1 + int(cultural.get("counterfactual_heat", 0)), false, convergence_axis.find("fragment") != -1, dormant, rediscovery), "rediscovered" if rediscovery else ("dormant" if dormant else "active"), ["threshold pressure", "visible shift"], "Threshold shifts are making old categories feel unstable again.")

static func _taxonomy_node(public_summary: Dictionary, cultural: Dictionary) -> Dictionary:
	var archive_tone := str(public_summary.get("archive_tone", "")).to_lower()
	var label := "Forensic Taxonomy"
	if archive_tone.find("memory") != -1:
		label = "Memory Taxonomy"
	var heat := 2 + int(cultural.get("orthodoxy_strength", 0)) + int(cultural.get("semantic_drift", 0))
	var gravity := 1 + int(cultural.get("revision_pressure", 0))
	var contested := int(cultural.get("semantic_drift", 0)) >= 2 or int(cultural.get("false_canon_pressure", 0)) >= 2
	return _build_node("taxonomy:%s" % label.to_lower().replace(" ", "_"), label, "taxonomy_classes", "taxonomy_%s" % label.to_lower().replace(" ", "_"), ["archive_classification_niche", "verification_niche"], heat, gravity, _resolve_lifecycle_state(heat, gravity, false, contested, false, false), "contested" if contested else "active", ["archive indexing"], "%s is deciding which records feel legitimate." % label)

static func _verification_node(cultural: Dictionary) -> Dictionary:
	var dominant_ontology := str(cultural.get("dominant_ontology", "")).strip_edges()
	var uncertainty := str(cultural.get("uncertainty_philosophy", "")).strip_edges()
	var label := "Witness Verification"
	if not dominant_ontology.is_empty():
		label = dominant_ontology.capitalize()
	var contested := int(cultural.get("false_canon_pressure", 0)) >= 2 or int(cultural.get("revision_pressure", 0)) >= 2
	var heat := 2 + int(cultural.get("orthodoxy_strength", 0)) + int(cultural.get("counterfactual_heat", 0))
	if not uncertainty.is_empty():
		heat += 1
	return _build_node("verification:%s" % label.to_lower().replace(" ", "_"), label, "verification_classes", "verification_%s" % label.to_lower().replace(" ", "_"), ["verification_niche", "public_argument_niche"], heat, 1 + int(cultural.get("revision_pressure", 0)), _resolve_lifecycle_state(heat, 1 + int(cultural.get("revision_pressure", 0)), false, contested, false, false), "contested" if contested else "active", ["verification", uncertainty], "%s keeps changing what counts as proof." % label)

static func _residue_node(public_summary: Dictionary, cultural: Dictionary) -> Dictionary:
	var archive_tone := str(public_summary.get("archive_tone", "")).to_lower()
	var heat := 1 + int(cultural.get("silence_pressure", 0)) + int(cultural.get("cookbook_fragment_count", 0))
	var residue_only := archive_tone.find("memory") != -1 or int(cultural.get("unclassified_pressure", 0)) >= 2
	return _build_node("residue:archive_trace", "Archive Trace", "residue_classes", "residue_archive_trace", ["residue_memory_niche", "archive_classification_niche"], heat, 1 + int(cultural.get("cookbook_fragment_count", 0)), _resolve_lifecycle_state(heat, 1 + int(cultural.get("cookbook_fragment_count", 0)), false, false, residue_only, false), "residue_only" if residue_only else "active", ["residue", "echo"], "Residue is keeping absent categories legible through trace.")

static func _experiment_node(family: Dictionary) -> Dictionary:
	var family_id := str(family.get("id", "")).strip_edges()
	var persistence_state := str(family.get("state", family.get("status", "phase_locked"))).strip_edges()
	return _build_node("experiment:%s" % family_id, str(family.get("label", family_id)).strip_edges(), "experiment_families", "experiment_%s" % family_id, ["preparation_culture_niche"], 0, 0, "dormancy", persistence_state, _string_array(family.get("target_layers", [])), "")

static func _hybrid_nodes(nodes: Array[Dictionary], cultural: Dictionary, generation_surface: Dictionary) -> Array[Dictionary]:
	var hybrids: Array[Dictionary] = []
	var chamber_node := _node_for_domain(nodes, "chamber_families")
	var pressure_node := _node_for_domain(nodes, "pressure_families")
	var ritual_node := _node_for_domain(nodes, "ritual_families")
	var artifact_node := _node_for_domain(nodes, "artifact_families")
	var verification_node := _node_for_domain(nodes, "verification_classes")
	if not chamber_node.is_empty():
		var allow_pressure_hybrid := not pressure_node.is_empty() and (int(cultural.get("counterfactual_heat", 0)) >= 1 or str(generation_surface.get("convergence_axis", "")).to_lower().find("fragment") != -1)
		if allow_pressure_hybrid:
			hybrids.append(_build_node("hybrid:chamber_pressure", "Pressure-Worn Chambers", "chamber_families", "hybrid_chamber_pressure", ["traversal_pressure_niche", "public_argument_niche"], mini(int(chamber_node.get("heat", 0)) + int(pressure_node.get("heat", 0)), 9), mini(int(chamber_node.get("gravity", 0)) + int(pressure_node.get("gravity", 0)), 9), "contestation", "active", ["hybrid", "pressure lineages"], "Pressure and chamber memory are collapsing into the same route read."))
	if not ritual_node.is_empty() and not artifact_node.is_empty() and int(cultural.get("legitimacy_pressure", 0)) >= 2:
		hybrids.append(_build_node("hybrid:artifact_ritual", "Custody Relics", "ritual_families", "hybrid_artifact_ritual", ["ritual_legitimacy_niche", "civic_trust_niche"], mini(int(ritual_node.get("heat", 0)) + int(artifact_node.get("heat", 0)), 9), mini(int(ritual_node.get("gravity", 0)) + int(artifact_node.get("gravity", 0)), 9), "rediscovery" if int(cultural.get("burial_pressure", 0)) >= 2 else "contestation", "active", ["hybrid", "custody rite"], "Artifact custody is being re-read as ritual obligation."))
	if not verification_node.is_empty() and int(cultural.get("semantic_drift", 0)) >= 2:
		hybrids.append(_build_node("hybrid:doctrine_taxonomy", "Disputed Proof Taxonomy", "verification_classes", "hybrid_doctrine_taxonomy", ["verification_niche", "archive_classification_niche"], mini(int(verification_node.get("heat", 0)) + int(cultural.get("revision_pressure", 0)), 9), mini(int(verification_node.get("gravity", 0)) + int(cultural.get("false_canon_pressure", 0)), 9), "fragmentation", "contested", ["hybrid", "archive dispute"], "Verification and classification are starting to fracture together."))
	return _sorted_dict_array(hybrids)

static func _absence_nodes(cultural: Dictionary, public_summary: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if int(cultural.get("taboo_heat", 0)) >= 2:
		result.append({"id": "absence:taboo_ritual", "label": "Forbidden Rite", "domain": "ritual_families", "absence_type": "taboo_class", "niches": ["ritual_legitimacy_niche"], "reason": "taboo heat is suppressing open ritual legitimacy"})
	if int(cultural.get("false_canon_pressure", 0)) >= 2 or int(cultural.get("revision_pressure", 0)) >= 2:
		result.append({"id": "absence:stable_verification", "label": "Stable Verification", "domain": "verification_classes", "absence_type": "missing_verification_method", "niches": ["verification_niche"], "reason": "verification classes are being contested by revision pressure"})
	if int(cultural.get("silence_pressure", 0)) >= 2:
		result.append({"id": "absence:dormant_rite", "label": "Dormant Witness Mode", "domain": "ritual_families", "absence_type": "dormant_ritual_mode", "niches": ["public_argument_niche"], "reason": "silence pressure is pushing a ritual mode out of ordinary play"})
	if str(public_summary.get("archive_tone", "")).to_lower().find("memory") != -1 or int(cultural.get("unclassified_pressure", 0)) >= 2:
		result.append({"id": "absence:residue_only_taxonomy", "label": "Residue-Only Taxonomy", "domain": "residue_classes", "absence_type": "residue_only_class", "niches": ["residue_memory_niche", "archive_classification_niche"], "reason": "residue is standing in for a missing class"})
	return _sorted_dict_array(result)

static func _lineages_from_nodes(nodes: Array[Dictionary], hybrids: Array[Dictionary]) -> Array[Dictionary]:
	var grouped: Dictionary = {}
	for node_raw in nodes + hybrids:
		var node: Dictionary = Dictionary(node_raw)
		var lineage_id := str(node.get("lineage_id", "")).strip_edges()
		if lineage_id.is_empty():
			continue
		var entry: Dictionary = Dictionary(grouped.get(lineage_id, {
			"id": lineage_id,
			"domains": [],
			"niches": [],
			"heat": 0,
			"gravity": 0,
			"lifecycle_states": [],
			"status": []
		}))
		entry["domains"] = _string_array(Array(entry.get("domains", [])) + [str(node.get("domain", ""))])
		entry["niches"] = _string_array(Array(entry.get("niches", [])) + _string_array(node.get("niches", [])))
		entry["heat"] = maxi(int(entry.get("heat", 0)), int(node.get("heat", 0)))
		entry["gravity"] = maxi(int(entry.get("gravity", 0)), int(node.get("gravity", 0)))
		entry["lifecycle_states"] = _string_array(Array(entry.get("lifecycle_states", [])) + [str(node.get("lifecycle_state", ""))])
		entry["status"] = _string_array(Array(entry.get("status", [])) + [str(node.get("status", ""))])
		grouped[lineage_id] = entry
	var result: Array[Dictionary] = []
	for lineage in grouped.values():
		result.append(Dictionary(lineage).duplicate(true))
	return _sorted_dict_array(result)

static func _niche_pressure(nodes: Array[Dictionary], hybrids: Array[Dictionary]) -> Dictionary:
	var pressures: Dictionary = {}
	for node_raw in nodes + hybrids:
		var node: Dictionary = Dictionary(node_raw)
		for niche in _string_array(node.get("niches", [])):
			pressures[niche] = int(pressures.get(niche, 0)) + maxi(int(node.get("heat", 0)), 0)
	return pressures

static func _dominant_domains(nodes: Array[Dictionary], hybrids: Array[Dictionary]) -> Array[String]:
	var scores: Dictionary = {}
	for node_raw in nodes + hybrids:
		var node: Dictionary = Dictionary(node_raw)
		var domain := str(node.get("domain", "")).strip_edges()
		if domain.is_empty():
			continue
		scores[domain] = int(scores.get(domain, 0)) + int(node.get("heat", 0)) + int(node.get("gravity", 0))
	var ordered: Array[Dictionary] = []
	for domain in scores.keys():
		ordered.append({"domain": str(domain), "score": int(scores.get(domain, 0))})
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("score", 0)) == int(b.get("score", 0)):
			return str(a.get("domain", "")) < str(b.get("domain", ""))
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	var result: Array[String] = []
	for entry in ordered.slice(0, 4):
		result.append(str(Dictionary(entry).get("domain", "")))
	return result

static func _rediscovery_candidates(nodes: Array[Dictionary], absent_nodes: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node_raw in nodes:
		var node: Dictionary = Dictionary(node_raw)
		if str(node.get("lifecycle_state", "")) == "rediscovery":
			result.append({"id": str(node.get("id", "")), "label": str(node.get("label", "")), "domain": str(node.get("domain", "")), "heat": int(node.get("heat", 0))})
	for absent_raw in absent_nodes:
		var absent: Dictionary = Dictionary(absent_raw)
		if str(absent.get("absence_type", "")) == "dormant_ritual_mode":
			result.append({"id": "%s:rediscovery" % str(absent.get("id", "")), "label": str(absent.get("label", "")), "domain": str(absent.get("domain", "")), "heat": 1})
	return _sorted_dict_array(result)

static func _public_lines(nodes: Array[Dictionary], hybrids: Array[Dictionary], absent_nodes: Array[Dictionary]) -> Array[String]:
	var lines: Array[String] = []
	for node_raw in nodes:
		var line := str(Dictionary(node_raw).get("public_line", "")).strip_edges()
		if not line.is_empty() and not lines.has(line):
			lines.append(line)
		if lines.size() >= 2:
			return lines
	for hybrid_raw in hybrids:
		var hybrid_line := str(Dictionary(hybrid_raw).get("public_line", "")).strip_edges()
		if not hybrid_line.is_empty() and not lines.has(hybrid_line):
			lines.append(hybrid_line)
		if lines.size() >= 2:
			return lines
	for absent_raw in absent_nodes:
		var absent: Dictionary = Dictionary(absent_raw)
		var line := "%s is being felt mostly through residue." % str(absent.get("label", "A missing class"))
		if not lines.has(line):
			lines.append(line)
		if lines.size() >= 2:
			return lines
	return lines

static func _build_node(id: String, label: String, domain: String, lineage_id: String, niches: Array[String], heat: int, gravity: int, lifecycle_state: String, status: String, tags: Array[String], public_line: String) -> Dictionary:
	return {
		"id": id,
		"label": label,
		"domain": domain,
		"lineage_id": lineage_id,
		"niches": _string_array(niches),
		"heat": maxi(heat, 0),
		"gravity": maxi(gravity, 0),
		"lifecycle_state": lifecycle_state,
		"status": status,
		"tags": _string_array(tags),
		"public_line": public_line.strip_edges()
	}

static func _resolve_lifecycle_state(heat: int, gravity: int, stale: bool, fragmented: bool, dormant: bool, rediscovery: bool) -> String:
	if rediscovery:
		return "rediscovery"
	if dormant:
		return "dormancy"
	if stale:
		return "decline"
	if fragmented:
		return "fragmentation"
	if heat <= 1:
		return "birth"
	if heat >= 6 or gravity >= 5:
		return "stabilization"
	if heat >= 4:
		return "expansion"
	return "contestation"

static func _node_for_domain(nodes: Array[Dictionary], domain: String) -> Dictionary:
	for node_raw in nodes:
		var node: Dictionary = Dictionary(node_raw)
		if str(node.get("domain", "")) == domain:
			return node
	return {}

static func _dominant_lineage_ids(nodes: Array, hybrids: Array) -> Array[String]:
	var pairs: Array[Dictionary] = []
	for node_raw in nodes + hybrids:
		var node: Dictionary = Dictionary(node_raw)
		pairs.append({"lineage_id": str(node.get("lineage_id", "")), "score": int(node.get("heat", 0)) + int(node.get("gravity", 0))})
	pairs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("score", 0)) == int(b.get("score", 0)):
			return str(a.get("lineage_id", "")) < str(b.get("lineage_id", ""))
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	var result: Array[String] = []
	for pair in pairs:
		var lineage_id := str(Dictionary(pair).get("lineage_id", "")).strip_edges()
		if lineage_id.is_empty() or result.has(lineage_id):
			continue
		result.append(lineage_id)
		if result.size() >= 4:
			break
	return result

static func _absence_count(absent_nodes: Array, absence_type: String) -> int:
	var total := 0
	for absent_raw in absent_nodes:
		if str(Dictionary(absent_raw).get("absence_type", "")) == absence_type:
			total += 1
	return total

static func _sorted_dict_array(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		result.append(Dictionary(value).duplicate(true))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return result

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
