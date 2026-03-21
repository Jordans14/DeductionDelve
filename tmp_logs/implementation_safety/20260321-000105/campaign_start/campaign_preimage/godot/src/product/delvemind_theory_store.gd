class_name DelveMindTheoryStore
extends RefCounted

const MAX_THEORIES := 48
const MAX_SCHOOLS := 12

static func default_store() -> Dictionary:
	return {
		"schema_name": "TheoryStore",
		"schema_version": 1,
		"theories": [],
		"schools": [{
			"school_id": "official",
			"label": "Official school",
			"stance": "stabilizing",
			"visibility": "public"
		}],
		"lineage_registry": {}
	}

static func normalize(store: Dictionary) -> Dictionary:
	var current := default_store()
	for key in store.keys():
		current[key] = store[key]
	var schools: Array[Dictionary] = []
	for value in Array(current.get("schools", [])):
		var school := Dictionary(value).duplicate(true)
		school["school_id"] = str(school.get("school_id", "")).strip_edges()
		school["label"] = str(school.get("label", "")).strip_edges()
		school["stance"] = str(school.get("stance", "stabilizing")).strip_edges()
		school["visibility"] = str(school.get("visibility", "public")).strip_edges()
		if not school["school_id"].is_empty():
			schools.append(school)
	if schools.is_empty():
		schools = Array(default_store().get("schools", [])).duplicate(true)
	current["schools"] = schools.slice(0, MAX_SCHOOLS)
	var theories: Array[Dictionary] = []
	for value in Array(current.get("theories", [])):
		var theory := Dictionary(value).duplicate(true)
		theory["theory_id"] = str(theory.get("theory_id", "")).strip_edges()
		theory["label"] = str(theory.get("label", "")).strip_edges()
		theory["status"] = str(theory.get("status", "proto")).strip_edges()
		theory["school_id"] = str(theory.get("school_id", "official")).strip_edges()
		theory["observable_ids"] = _string_array(theory.get("observable_ids", []))
		theory["play_routing_tags"] = _string_array(theory.get("play_routing_tags", []))
		if not theory["theory_id"].is_empty():
			theories.append(theory)
	current["theories"] = theories.slice(0, MAX_THEORIES)
	current["lineage_registry"] = Dictionary(current.get("lineage_registry", {})).duplicate(true)
	return current

static func sync_from_experiments(store: Dictionary, experiment_state: Dictionary) -> Dictionary:
	var current := normalize(store)
	var theories := Array(current.get("theories", [])).duplicate(true)
	var experiments := Dictionary(experiment_state.get("experiments", {}))
	for experiment_id in _sorted_strings(experiments.keys()):
		var experiment := Dictionary(experiments.get(experiment_id, {}))
		var theory_id := "theory_%s" % str(experiment.get("experiment_id", experiment_id)).strip_edges()
		if _has_theory(theories, theory_id):
			continue
		var state := str(experiment.get("state", "dormant")).strip_edges()
		var status := "proto"
		if state == "foundational" or state == "active":
			status = "official"
		elif state == "recurring":
			status = "rival"
		elif state == "archival":
			status = "failed_archival"
		var label := _first_non_empty([
			_first_string(experiment.get("public_lines", []), ""),
			str(experiment.get("family_label", experiment.get("family_id", theory_id))).strip_edges()
		])
		theories.push_back({
			"theory_id": theory_id,
			"label": label,
			"status": status,
			"school_id": "official" if status == "official" else "proto_school",
			"observable_ids": _string_array([
				str(experiment.get("target", "")).strip_edges(),
				str(experiment.get("axis", "")).strip_edges(),
				str(experiment.get("stressor", "")).strip_edges()
			]),
			"play_routing_tags": ["movement", "burden", "witness", "route_choice", "artifact_custody", "extraction", "return"]
		})
		var lineage_registry: Dictionary = Dictionary(current.get("lineage_registry", {})).duplicate(true)
		lineage_registry[theory_id] = {
			"lineage_id": theory_id,
			"kind": "theory",
			"label": label,
			"source_ids": _string_array([str(experiment.get("experiment_id", experiment_id)).strip_edges()]),
			"state": status,
			"visibility": "public" if status == "official" else "operator",
			"play_routing_tags": ["witness", "route_choice", "return"]
		}
		current["lineage_registry"] = lineage_registry
	current["theories"] = theories.slice(0, MAX_THEORIES)
	if not _has_school(Array(current.get("schools", [])), "proto_school"):
		var schools := Array(current.get("schools", [])).duplicate(true)
		schools.push_back({
			"school_id": "proto_school",
			"label": "Proto school",
			"stance": "exploratory",
			"visibility": "operator"
		})
		current["schools"] = schools.slice(0, MAX_SCHOOLS)
	return normalize(current)

static func build_public_surface(store: Dictionary) -> Dictionary:
	var current := normalize(store)
	var theories := Array(current.get("theories", []))
	var lines: Array[String] = []
	if not theories.is_empty():
		var primary := Dictionary(theories[0])
		lines.append("%s remains active as a %s theory" % [str(primary.get("label", "theory")).strip_edges(), str(primary.get("status", "proto")).replace("_", " ")])
	return {
		"lines": lines.slice(0, 2),
		"theory_ids": _pluck_ids(theories, "theory_id"),
		"school_ids": _pluck_ids(Array(current.get("schools", [])), "school_id"),
		"statuses": _pluck_statuses(theories)
	}

static func _has_theory(values: Array, theory_id: String) -> bool:
	for value in values:
		if str(Dictionary(value).get("theory_id", "")).strip_edges() == theory_id:
			return true
	return false

static func _has_school(values: Array, school_id: String) -> bool:
	for value in values:
		if str(Dictionary(value).get("school_id", "")).strip_edges() == school_id:
			return true
	return false

static func _pluck_ids(values: Array, key: String) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(Dictionary(value).get(key, "")).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _pluck_statuses(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(Dictionary(value).get("status", "")).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result

static func _sorted_strings(values: Array) -> Array[String]:
	var result := _string_array(values)
	result.sort()
	return result

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _first_string(values: Variant, fallback: String) -> String:
	for value in _string_array(values):
		return value
	return fallback

static func _first_non_empty(values: Array) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return ""
