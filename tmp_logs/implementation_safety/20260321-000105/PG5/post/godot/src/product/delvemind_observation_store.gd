class_name DelveMindObservationStore
extends RefCounted

const MAX_RECORDS := 48

static func default_store() -> Dictionary:
	return {
		"schema_name": "ObservationStore",
		"schema_version": 1,
		"records": [],
		"behavior_field_snapshots": [],
		"observable_ids": []
	}

static func normalize(store: Dictionary) -> Dictionary:
	var current := default_store()
	for key in store.keys():
		current[key] = store[key]
	current["records"] = _normalize_records(Array(current.get("records", [])))
	current["behavior_field_snapshots"] = _normalize_records(Array(current.get("behavior_field_snapshots", [])))
	current["observable_ids"] = _string_array(current.get("observable_ids", []))
	return current

static func record_run(store: Dictionary, run_record: Dictionary, diagnostics: Dictionary, field_snapshot: Dictionary = {}) -> Dictionary:
	var current := normalize(store)
	var records := Array(current.get("records", [])).duplicate(true)
	records.push_front({
		"observable_id": "obs_%s" % str(run_record.get("seed", 0)),
		"label": _first_non_empty([
			str(diagnostics.get("story_tone", "")).strip_edges(),
			str(diagnostics.get("momentum_profile", "")).strip_edges(),
			"run observation"
		]),
		"category": "run_trace",
		"capture_mode": "post_run",
		"observation_contract": "traceable_archive_only",
		"status_domain": "traceable_archive_only",
		"runtime_authority": false,
		"uncertainty_state": "contextual_non_final",
		"play_routing_tags": ["movement", "witness", "extraction", "return"]
	})
	current["records"] = _normalize_records(records)
	current["observable_ids"] = _string_array(Array(current.get("observable_ids", [])) + ["obs_%s" % str(run_record.get("seed", 0))])
	if not field_snapshot.is_empty():
		var snapshots := Array(current.get("behavior_field_snapshots", [])).duplicate(true)
		var snapshot := field_snapshot.duplicate(true)
		snapshot["observation_contract"] = "constitution_trace"
		snapshot["status_domain"] = "constitution_trace"
		snapshot["runtime_authority"] = false
		snapshot["uncertainty_state"] = "contextual_non_final"
		snapshots.push_front(snapshot)
		current["behavior_field_snapshots"] = _normalize_records(snapshots)
	return normalize(current)

static func build_surface_lines(store: Dictionary) -> Array[String]:
	var current := normalize(store)
	var lines: Array[String] = []
	if not Array(current.get("records", [])).is_empty():
		lines.append(str(Dictionary(Array(current.get("records", []))[0]).get("label", "observation store active")))
	if not Array(current.get("behavior_field_snapshots", [])).is_empty():
		lines.append("field traces remain cumulative")
	return lines.slice(0, 2)

static func _normalize_records(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		if value is Dictionary:
			result.append(Dictionary(value).duplicate(true))
	return result.slice(0, MAX_RECORDS)

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
