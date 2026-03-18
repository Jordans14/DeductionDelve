class_name GovernanceService
extends RefCounted

const MAX_HISTORY := 24
const MAX_REPORTS := 24
const MAX_LINES := 6

static func default_state() -> Dictionary:
	return {
		"schema_name": "GovernanceState",
		"schema_version": 1,
		"constitution_history": [],
		"activation_state": _default_activation_state(),
		"safe_mode_state": _default_safe_mode_state(),
		"quarantine_registry": [],
		"stability_reports": [],
		"anti_bottleneck_reports": [],
		"play_routing_reports": [],
		"court_decisions": [],
		"meta_reflection_reports": [],
		"contradiction_records": []
	}

static func normalize(state: Dictionary) -> Dictionary:
	var current := default_state()
	for key in state.keys():
		current[key] = state[key]
	current["activation_state"] = normalize_activation_state(Dictionary(current.get("activation_state", {})))
	current["safe_mode_state"] = normalize_safe_mode_state(Dictionary(current.get("safe_mode_state", {})))
	current["quarantine_registry"] = _dict_array(current.get("quarantine_registry", [])).slice(0, MAX_REPORTS)
	current["constitution_history"] = _normalize_history(Array(current.get("constitution_history", [])))
	current["stability_reports"] = _normalize_reports(Array(current.get("stability_reports", [])))
	current["anti_bottleneck_reports"] = _normalize_reports(Array(current.get("anti_bottleneck_reports", [])))
	current["play_routing_reports"] = _normalize_reports(Array(current.get("play_routing_reports", [])))
	current["court_decisions"] = _normalize_reports(Array(current.get("court_decisions", [])))
	current["meta_reflection_reports"] = _normalize_reports(Array(current.get("meta_reflection_reports", [])))
	current["contradiction_records"] = _normalize_reports(Array(current.get("contradiction_records", [])))
	return current

static func normalize_activation_state(raw: Dictionary) -> Dictionary:
	var current := _default_activation_state()
	for key in raw.keys():
		current[key] = raw[key]
	current["epoch"] = str(current.get("epoch", "structural_presence")).strip_edges()
	if current["epoch"].is_empty():
		current["epoch"] = "structural_presence"
	current["active_channels"] = _string_array(current.get("active_channels", []))
	current["dormant_channels"] = _string_array(current.get("dormant_channels", []))
	current["safe_mode_active"] = bool(current.get("safe_mode_active", false))
	current["quarantine_ids"] = _string_array(current.get("quarantine_ids", []))
	current["activation_lines"] = _slice_strings(_string_array(current.get("activation_lines", [])), MAX_LINES)
	return current

static func normalize_safe_mode_state(raw: Dictionary) -> Dictionary:
	var current := _default_safe_mode_state()
	for key in raw.keys():
		current[key] = raw[key]
	current["enabled"] = bool(current.get("enabled", false))
	current["reason"] = str(current.get("reason", "")).strip_edges()
	current["fallback_constitution_id"] = str(current.get("fallback_constitution_id", "")).strip_edges()
	current["cooling_tags"] = _string_array(current.get("cooling_tags", []))
	current["summary_lines"] = _slice_strings(_string_array(current.get("summary_lines", [])), MAX_LINES)
	return current

static func build_explanation_packet(source: Dictionary, summary_lines: Array = [], operator_lines: Array = [], play_routing_tags: Array = []) -> Dictionary:
	var artifact_type := str(source.get("artifact_type", "governance_packet")).strip_edges()
	var packet_id_seed := "%s|%s|%s" % [
		artifact_type,
		str(source.get("constitution_id", source.get("constitution_hash", source.get("entry_id", "")))).strip_edges(),
		str(source.get("packet_id", "")).strip_edges()
	]
	if packet_id_seed.strip_edges().is_empty():
		packet_id_seed = JSON.stringify(source)
	return {
		"packet_id": "packet_%s" % packet_id_seed.md5_text().substr(0, 12),
		"artifact_type": artifact_type,
		"summary_lines": _slice_strings(_string_array(summary_lines), MAX_LINES),
		"operator_lines": _slice_strings(_string_array(operator_lines), MAX_LINES),
		"play_routing_tags": _string_array(play_routing_tags)
	}

static func build_review_surface(governance_state: Dictionary) -> Dictionary:
	var current := normalize(governance_state)
	var stability_reports := _dict_array(current.get("stability_reports", []))
	var play_routing_reports := _dict_array(current.get("play_routing_reports", []))
	var lines: Array[String] = []
	if not stability_reports.is_empty():
		lines.append(_first_string(Dictionary(stability_reports[0]).get("summary_lines", []), "stability review present"))
	if not play_routing_reports.is_empty():
		lines.append(_first_string(Dictionary(play_routing_reports[0]).get("summary_lines", []), "play-routing review present"))
	var safe_mode_state := normalize_safe_mode_state(Dictionary(current.get("safe_mode_state", {})))
	if bool(safe_mode_state.get("enabled", false)):
		lines.append(_first_string(Array(safe_mode_state.get("summary_lines", [])), "safe mode remains active"))
	return {
		"lines": _slice_strings(lines, MAX_LINES),
		"active_channels": _string_array(Dictionary(current.get("activation_state", {})).get("active_channels", [])),
		"dormant_channels": _string_array(Dictionary(current.get("activation_state", {})).get("dormant_channels", []))
	}

static func apply_post_run(governance_state: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary, constitution_summary: Dictionary) -> Dictionary:
	var current := normalize(governance_state)
	var activation_state := normalize_activation_state(Dictionary(current.get("activation_state", {})))
	var safe_mode_state := normalize_safe_mode_state(Dictionary(current.get("safe_mode_state", {})))
	var doctrine_goal := str(diagnostics.get("doctrine_world_goal", constitution_summary.get("world_goal", ""))).strip_edges()
	var pressure_line := str(diagnostics.get("doctrine_pressure_line", constitution_summary.get("pressure_line", ""))).strip_edges()
	var constitution_id := str(constitution_summary.get("constitution_id", constitution_summary.get("constitution_hash", ""))).strip_edges()
	if not constitution_id.is_empty():
		var history := _dict_array(current.get("constitution_history", []))
		history.push_front({
			"constitution_id": constitution_id,
			"constitution_hash": str(constitution_summary.get("constitution_hash", "")).strip_edges(),
			"doctrine_family": str(constitution_summary.get("doctrine_family", diagnostics.get("doctrine_family", ""))).strip_edges(),
			"world_goal": doctrine_goal,
			"pressure_line": pressure_line,
			"seed": int(run_record.get("seed", 0)),
			"summary_lines": _slice_strings([
				_first_non_empty([
					str(frame.get("governance_line", "")).strip_edges(),
					pressure_line,
					doctrine_goal,
					"constitution history updated"
				])
			], 1)
		})
		current["constitution_history"] = history.slice(0, MAX_HISTORY)
	var review_lines := _slice_strings([
		_first_non_empty([
			str(frame.get("governance_line", "")).strip_edges(),
			pressure_line,
			"surface review remains active"
		])
	], 1)
	current["stability_reports"] = _prepend_report(
		Array(current.get("stability_reports", [])),
		{
			"report_id": "stability_%s" % str(run_record.get("seed", 0)),
			"status": "stable" if not bool(safe_mode_state.get("enabled", false)) else "cooling",
			"summary_lines": review_lines
		}
	)
	current["anti_bottleneck_reports"] = _prepend_report(
		Array(current.get("anti_bottleneck_reports", [])),
		{
			"report_id": "antibottleneck_%s" % str(run_record.get("seed", 0)),
			"status": "stable",
			"summary_lines": _slice_strings([
				_first_non_empty([
					_first_string(diagnostics.get("experiment_surface_lines", []), ""),
					"multi-channel review remains distributed"
				])
			], 1)
		}
	)
	current["play_routing_reports"] = _prepend_report(
		Array(current.get("play_routing_reports", [])),
		{
			"report_id": "playrouting_%s" % str(run_record.get("seed", 0)),
			"status": "stable",
			"baseline_routes": ["movement", "burden", "rescue", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"],
			"summary_lines": _slice_strings(["advanced doctrine remains routed through embodied expedition play"], 1)
		}
	)
	current["meta_reflection_reports"] = _prepend_report(
		Array(current.get("meta_reflection_reports", [])),
		{
			"reflection_id": "reflection_%s" % str(run_record.get("seed", 0)),
			"status": "stable",
			"summary_lines": _slice_strings([
				_first_non_empty([
					str(frame.get("school_tension", "")).strip_edges(),
					"meta reflection remains cumulative and non-destructive"
				])
			], 1)
		}
	)
	current["court_decisions"] = _prepend_report(
		Array(current.get("court_decisions", [])),
		{
			"decision_id": "court_%s" % str(run_record.get("seed", 0)),
			"status": "stable",
			"summary_lines": _slice_strings(["no activation channel received independent runtime authority"], 1)
		}
	)
	activation_state["active_channels"] = _string_array(Array(activation_state.get("active_channels", [])) + ["constitution", "archive", "world_memory", "inquiry"])
	activation_state["dormant_channels"] = _string_array(Array(activation_state.get("dormant_channels", [])) + ["theory", "cognitive_field", "cookbook", "factions", "world_mutation", "safe_mode", "contradiction"])
	activation_state["safe_mode_active"] = bool(safe_mode_state.get("enabled", false))
	activation_state["activation_lines"] = _slice_strings(Array(activation_state.get("activation_lines", [])) + review_lines, MAX_LINES)
	current["activation_state"] = activation_state
	current["safe_mode_state"] = safe_mode_state
	return normalize(current)

static func _default_activation_state() -> Dictionary:
	return {
		"epoch": "structural_presence",
		"active_channels": ["constitution", "archive", "world_memory", "inquiry"],
		"dormant_channels": ["theory", "cognitive_field", "cookbook", "factions", "world_mutation", "safe_mode", "contradiction"],
		"safe_mode_active": false,
		"quarantine_ids": [],
		"activation_lines": ["structural presence established while higher-order channels remain dormant"]
	}

static func _default_safe_mode_state() -> Dictionary:
	return {
		"enabled": false,
		"reason": "",
		"fallback_constitution_id": "",
		"cooling_tags": ["theory_weather", "cookbook_escalation", "world_mutation"],
		"summary_lines": []
	}

static func _normalize_history(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_raw in entries:
		var entry := Dictionary(entry_raw).duplicate(true)
		entry["constitution_id"] = str(entry.get("constitution_id", "")).strip_edges()
		entry["constitution_hash"] = str(entry.get("constitution_hash", "")).strip_edges()
		entry["doctrine_family"] = str(entry.get("doctrine_family", "")).strip_edges()
		entry["world_goal"] = str(entry.get("world_goal", "")).strip_edges()
		entry["pressure_line"] = str(entry.get("pressure_line", "")).strip_edges()
		entry["seed"] = int(entry.get("seed", 0))
		entry["summary_lines"] = _slice_strings(_string_array(entry.get("summary_lines", [])), MAX_LINES)
		if not entry["constitution_id"].is_empty():
			result.append(entry)
	return result.slice(0, MAX_HISTORY)

static func _normalize_reports(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_raw in entries:
		var entry := Dictionary(entry_raw).duplicate(true)
		entry["status"] = str(entry.get("status", "stable")).strip_edges()
		if entry["status"].is_empty():
			entry["status"] = "stable"
		entry["summary_lines"] = _slice_strings(_string_array(entry.get("summary_lines", [])), MAX_LINES)
		result.append(entry)
	return result.slice(0, MAX_REPORTS)

static func _prepend_report(entries: Array, entry: Dictionary) -> Array[Dictionary]:
	var next := _dict_array(entries)
	next.push_front(entry)
	return _normalize_reports(next)

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

static func _slice_strings(values: Array, limit: int) -> Array[String]:
	return _string_array(values).slice(0, limit)

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
