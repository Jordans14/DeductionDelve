class_name SimulationChambers
extends RefCounted

const CHAMBER_IDS := ["tactical", "crawl", "cultural", "epoch", "constitutional"]

static func default_state() -> Dictionary:
	return {
		"schema_name": "SimulationChambers",
		"schema_version": 1,
		"records": []
	}

static func normalize(state: Dictionary) -> Dictionary:
	var current := default_state()
	for key in state.keys():
		current[key] = state[key]
	var records: Array[Dictionary] = []
	for value in Array(current.get("records", [])):
		var record := Dictionary(value).duplicate(true)
		record["forecast_id"] = str(record.get("forecast_id", "")).strip_edges()
		record["chamber_id"] = str(record.get("chamber_id", "")).strip_edges()
		record["theory_id"] = str(record.get("theory_id", "")).strip_edges()
		record["prediction"] = str(record.get("prediction", "")).strip_edges()
		record["confidence"] = clampi(int(record.get("confidence", 0)), 0, 4)
		if not record["forecast_id"].is_empty():
			records.append(record)
	current["records"] = records
	return current

static func build_state(theory_surface: Dictionary, world_model: Dictionary = {}) -> Dictionary:
	var theory_ids := _string_array(theory_surface.get("theory_ids", []))
	var records: Array[Dictionary] = []
	for chamber_id in CHAMBER_IDS:
		records.append({
			"forecast_id": "forecast_%s" % chamber_id,
			"chamber_id": chamber_id,
			"theory_id": theory_ids[0] if not theory_ids.is_empty() else "",
			"prediction": "%s chamber remains structurally present" % chamber_id,
			"confidence": 0
		})
	return normalize({"records": records})

static func build_surface(state: Dictionary) -> Dictionary:
	var current := normalize(state)
	var lines: Array[String] = []
	for record in Array(current.get("records", [])):
		var prediction := str(Dictionary(record).get("prediction", "")).strip_edges()
		if not prediction.is_empty():
			lines.append(prediction)
		if lines.size() >= 2:
			break
	return {
		"lines": lines,
		"records": Array(current.get("records", [])).duplicate(true)
	}

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
