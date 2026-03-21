class_name DelveMindJudgmentStore
extends RefCounted

const MAX_JUDGMENTS := 48

static func default_store() -> Dictionary:
	return {
		"schema_name": "JudgmentStore",
		"schema_version": 1,
		"judgments": [],
		"contradiction_ids": []
	}

static func normalize(store: Dictionary) -> Dictionary:
	var current := default_store()
	for key in store.keys():
		current[key] = store[key]
	var judgments: Array[Dictionary] = []
	for value in Array(current.get("judgments", [])):
		var judgment := Dictionary(value).duplicate(true)
		judgment["judgment_id"] = str(judgment.get("judgment_id", "")).strip_edges()
		judgment["theory_id"] = str(judgment.get("theory_id", "")).strip_edges()
		judgment["outcome"] = str(judgment.get("outcome", "abstain")).strip_edges()
		judgment["confidence"] = clampi(int(judgment.get("confidence", 0)), 0, 4)
		judgment["play_routing_tags"] = _string_array(judgment.get("play_routing_tags", []))
		if not judgment["judgment_id"].is_empty():
			judgments.append(judgment)
	current["judgments"] = judgments.slice(0, MAX_JUDGMENTS)
	current["contradiction_ids"] = _string_array(current.get("contradiction_ids", []))
	return current

static func sync_from_learning(store: Dictionary, learning_state: Dictionary) -> Dictionary:
	var current := normalize(store)
	var judgments := Array(current.get("judgments", [])).duplicate(true)
	for record_raw in Array(Dictionary(learning_state).get("evaluation_records", [])):
		var record := Dictionary(record_raw)
		var evaluation_id := str(record.get("evaluation_id", "")).strip_edges()
		if evaluation_id.is_empty():
			continue
		var judgment_id := "judgment_%s" % evaluation_id
		if _has_judgment(judgments, judgment_id):
			continue
		var outcomes := _string_array(record.get("outcomes", []))
		judgments.push_back({
			"judgment_id": judgment_id,
			"theory_id": "theory_%s" % str(record.get("experiment_id", "")).strip_edges(),
			"outcome": _first_non_empty(outcomes + ["abstain"]),
			"confidence": clampi(int(Dictionary(record.get("dimensions", {})).get("hypothesis_yield", 0)), 0, 4),
			"play_routing_tags": ["witness", "route_choice", "return"]
		})
	current["judgments"] = judgments.slice(0, MAX_JUDGMENTS)
	return normalize(current)

static func _has_judgment(values: Array, judgment_id: String) -> bool:
	for value in values:
		if str(Dictionary(value).get("judgment_id", "")).strip_edges() == judgment_id:
			return true
	return false

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _first_non_empty(values: Array) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return ""
