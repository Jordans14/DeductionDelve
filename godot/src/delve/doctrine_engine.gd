class_name DoctrineEngine
extends RefCounted

const DOCTRINE_SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")

static func build_candidates(world_model: Dictionary, session_context: Dictionary, planner: Dictionary, meta: Dictionary = {}) -> Array[Dictionary]:
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", session_context.get("protocol_state", "")))
	var stale_doctrines := _string_array(meta.get("stale_doctrines", []))
	var doctrine_model: Dictionary = Dictionary(world_model.get("doctrine_model", {}))
	var cultural_model: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var session_model: Dictionary = Dictionary(world_model.get("session_model", {}))
	var active_crawl: Dictionary = Dictionary(world_model.get("active_crawl", {}))
	var doctrine_counts: Dictionary = Dictionary(doctrine_model.get("doctrine_counts", {}))
	var dominant_doctrine := ""
	var dominant_weight := 0
	for key in doctrine_counts.keys():
		var weight := int(doctrine_counts.get(key, 0))
		if weight > dominant_weight or (weight == dominant_weight and str(key) < dominant_doctrine):
			dominant_doctrine = str(key)
			dominant_weight = weight
	var active_doctrine_memory := _string_array(active_crawl.get("doctrine_memory", []))
	var build_convergence := int(session_model.get("build_convergence", 0))
	var dominant_build := str(session_model.get("dominant_build", "")).to_lower()
	var world_focus := str(cultural_model.get("current_focus", "")).to_lower()
	var myth_gravity := int(cultural_model.get("myth_gravity", 0))
	var legitimacy_pressure := int(cultural_model.get("legitimacy_pressure", 0))
	var taboo_heat := int(cultural_model.get("taboo_heat", 0))
	var burial_pressure := int(cultural_model.get("burial_pressure", 0))
	var heresy_pressure := int(cultural_model.get("heresy_pressure", 0))
	var candidates: Array[Dictionary] = []
	for doctrine_raw in DOCTRINE_SCHEMA_REGISTRY_SCRIPT.doctrine_families():
		var doctrine: Dictionary = Dictionary(doctrine_raw).duplicate(true)
		var base_weight := 4
		var doctrine_id := str(doctrine.get("id", ""))
		if _string_array(doctrine.get("protocol_affinities", [])).has(protocol_state):
			base_weight += 2
		if stale_doctrines.has(doctrine_id):
			base_weight -= 2
		if Array(Dictionary(planner).get("session", [])).size() >= 1 and _string_array(doctrine.get("focus_tags", [])).has("split_read"):
			base_weight += 1
		if dominant_weight >= 2 and doctrine_id == dominant_doctrine:
			base_weight -= 1
		if not active_doctrine_memory.is_empty() and active_doctrine_memory[0] == doctrine_id and int(active_crawl.get("public_heat", 0)) >= 5:
			base_weight -= 1
		if myth_gravity >= 5 and _focus_aligns(_string_array(doctrine.get("focus_tags", [])), world_focus):
			base_weight += 1
		if burial_pressure >= 2 and doctrine_id == "custody_ritual":
			base_weight += 2
		if legitimacy_pressure >= 2 and doctrine_id in ["burden_chain", "custody_ritual"]:
			base_weight += 1
		if taboo_heat >= 2 and doctrine_id in ["custody_ritual", "exposure_test"]:
			base_weight += 1
		if heresy_pressure >= 2 and doctrine_id == "split_truth":
			base_weight += 1
		base_weight += _build_alignment_delta(doctrine_id, dominant_build, build_convergence)
		doctrine["base_weight"] = base_weight
		candidates.append(doctrine)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("base_weight", 0)) == int(b.get("base_weight", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("base_weight", 0)) > int(b.get("base_weight", 0))
	)
	return candidates

static func public_label(doctrine: Dictionary) -> String:
	return str(doctrine.get("label", "Measured Pressure"))

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _focus_aligns(focus_tags: Array[String], world_focus: String) -> bool:
	if world_focus.is_empty():
		return false
	for tag in focus_tags:
		if world_focus.find(tag.to_lower()) != -1:
			return true
	return false

static func _build_alignment_delta(doctrine_id: String, dominant_build: String, build_convergence: int) -> int:
	if build_convergence <= 0 or dominant_build.is_empty():
		return 0
	match doctrine_id:
		"burden_chain":
			if dominant_build.find("rescue") != -1 or dominant_build.find("burden") != -1:
				return build_convergence
		"witness_pressure":
			if dominant_build.find("spectacle") != -1 or dominant_build.find("rescue") != -1:
				return 1
		"split_truth":
			if dominant_build.find("control") != -1 or dominant_build.find("deception") != -1:
				return build_convergence
		"custody_ritual":
			if dominant_build.find("anomaly") != -1 or dominant_build.find("ritual") != -1:
				return build_convergence
		"relay_pressure":
			if dominant_build.find("traversal") != -1 or dominant_build.find("control") != -1:
				return 1
		"exposure_test":
			if dominant_build.find("solitude") != -1 or dominant_build.find("anomaly") != -1:
				return 1
	return 0
