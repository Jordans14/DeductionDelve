class_name GovernanceService
extends RefCounted

const MAX_HISTORY := 24
const MAX_REPORTS := 24
const MAX_LINES := 6
const BASELINE_ROUTES := ["movement", "burden", "rescue", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"]
const ALL_CHANNELS := ["constitution", "archive", "world_memory", "inquiry", "theory", "cognitive_field", "factions", "world_mutation", "cookbook", "contradiction", "safe_mode"]

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
	current["quarantine_registry"] = _normalize_reports(Array(current.get("quarantine_registry", [])))
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
	current["epoch"] = str(current.get("epoch", "activated")).strip_edges()
	if current["epoch"].is_empty():
		current["epoch"] = "activated"
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

static func evaluate_planning_state(governance_state: Dictionary, world_model: Dictionary, theory_surface: Dictionary, civilization_surface: Dictionary, contradiction_packet: Dictionary, cookbook_state: Dictionary) -> Dictionary:
	var current := normalize(governance_state)
	var contradiction_records := _normalize_reports(Array(contradiction_packet.get("records", [])))
	var anti_bottleneck_report := Dictionary(contradiction_packet.get("anti_bottleneck_report", {})).duplicate(true)
	var play_routing_report := Dictionary(contradiction_packet.get("play_routing_report", {})).duplicate(true)
	var meta_reflection_report := Dictionary(contradiction_packet.get("meta_reflection_report", {})).duplicate(true)
	var active_channels: Array[String] = ["constitution", "archive", "world_memory", "inquiry", "theory", "cognitive_field", "contradiction"]
	if not _string_array(civilization_surface.get("faction_ids", [])).is_empty():
		active_channels.append("factions")
	if not _string_array(civilization_surface.get("world_mutation_ids", [])).is_empty():
		active_channels.append("world_mutation")
	if int(cookbook_state.get("fragment_count", 0)) >= 1 or not _string_array(cookbook_state.get("unauthorized_theory_ids", [])).is_empty():
		active_channels.append("cookbook")
	var quarantine_registry: Array[Dictionary] = []
	var quarantine_ids: Array[String] = []
	for theory in _dict_array(theory_surface.get("theories", [])):
		var theory_id := str(Dictionary(theory).get("theory_id", "")).strip_edges()
		var status := str(Dictionary(theory).get("status", "")).strip_edges()
		if theory_id.is_empty():
			continue
		if status == "suppressed":
			quarantine_ids.append(theory_id)
			quarantine_registry.append({
				"entry_id": "quarantine_%s" % theory_id,
				"status": "quarantined",
				"summary_lines": ["%s remains quarantined until contradiction pressure cools" % theory_id.replace("_", " ")]
			})
	if int(Dictionary(cookbook_state.get("power_envelope", {})).get("instability", 0)) >= 6:
		quarantine_ids.append("cookbook_fragment_network")
		quarantine_registry.append({
			"entry_id": "quarantine_cookbook_network",
			"status": "quarantined",
			"summary_lines": ["cookbook escalation is quarantined from clean promotion until doctrine stress drops"]
		})
	var safe_mode_enabled := false
	var safe_mode_reason := ""
	if str(play_routing_report.get("status", "stable")).strip_edges() == "blocked":
		safe_mode_enabled = true
		safe_mode_reason = "play-routing coverage failed"
	elif str(anti_bottleneck_report.get("status", "stable")).strip_edges() == "blocked" and quarantine_ids.size() >= 2:
		safe_mode_enabled = true
		safe_mode_reason = "theory monopoly and quarantine pressure are colliding"
	elif contradiction_records.size() >= 3 and int(Dictionary(cookbook_state.get("power_envelope", {})).get("doctrine_stress", 0)) >= 5:
		safe_mode_enabled = true
		safe_mode_reason = "contradiction and cookbook stress exceeded the cooling threshold"
	var safe_mode_state := normalize_safe_mode_state({
		"enabled": safe_mode_enabled,
		"reason": safe_mode_reason,
		"cooling_tags": ["theory", "cookbook", "world_mutation"] if safe_mode_enabled else [],
		"summary_lines": ["safe mode is cooling contested doctrine layers" if safe_mode_enabled else "safe mode is standing by while active governance remains stable"]
	})
	if safe_mode_enabled and not active_channels.has("safe_mode"):
		active_channels.append("safe_mode")
	var active_unique := _string_array(active_channels)
	var dormant_channels: Array[String] = []
	for channel in ALL_CHANNELS:
		if not active_unique.has(channel):
			dormant_channels.append(channel)
	var activation_state := normalize_activation_state({
		"epoch": "cooled" if safe_mode_enabled else "fully_active",
		"active_channels": active_unique,
		"dormant_channels": dormant_channels,
		"safe_mode_active": safe_mode_enabled,
		"quarantine_ids": quarantine_ids,
		"activation_lines": [
			"active channels: %s" % ", ".join(active_unique),
			"quarantine count: %d" % quarantine_ids.size(),
			"court posture: %s" % ("cool and quarantine" if safe_mode_enabled else "promote and contest")
		]
	})
	var stability_report := {
		"report_id": "stability_%s" % str(active_unique.size()),
		"status": "cooling" if safe_mode_enabled else "stable",
		"summary_lines": ["governance %s while preserving runtime truth boundaries" % ("entered cooling mode" if safe_mode_enabled else "kept all high layers active")]
	}
	var court_decision := {
		"decision_id": "court_%s" % str(active_unique.size()),
		"status": "cooling" if safe_mode_enabled else "promote",
		"summary_lines": [
			"court %s" % ("ordered cooling and quarantine for unstable doctrine carriers" if safe_mode_enabled else "authorized active multi-theory governance under continued review")
		]
	}
	current["activation_state"] = activation_state
	current["safe_mode_state"] = safe_mode_state
	current["quarantine_registry"] = _normalize_reports(quarantine_registry)
	current["stability_reports"] = _prepend_report(Array(current.get("stability_reports", [])), stability_report)
	current["anti_bottleneck_reports"] = _prepend_report(Array(current.get("anti_bottleneck_reports", [])), anti_bottleneck_report)
	current["play_routing_reports"] = _prepend_report(Array(current.get("play_routing_reports", [])), play_routing_report)
	current["court_decisions"] = _prepend_report(Array(current.get("court_decisions", [])), court_decision)
	current["meta_reflection_reports"] = _prepend_report(Array(current.get("meta_reflection_reports", [])), meta_reflection_report)
	current["contradiction_records"] = _normalize_reports(contradiction_records)
	return normalize(current)

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
	var lines: Array[String] = []
	for report_key in ["stability_reports", "anti_bottleneck_reports", "play_routing_reports", "court_decisions", "meta_reflection_reports"]:
		var reports := _dict_array(current.get(report_key, []))
		if not reports.is_empty():
			lines.append(_first_string(Dictionary(reports[0]).get("summary_lines", []), "review report present"))
	if bool(Dictionary(current.get("safe_mode_state", {})).get("enabled", false)):
		lines.append(_first_string(Dictionary(current.get("safe_mode_state", {})).get("summary_lines", []), "safe mode remains active"))
	return {
		"lines": _slice_strings(lines, MAX_LINES),
		"active_channels": _string_array(Dictionary(current.get("activation_state", {})).get("active_channels", [])),
		"dormant_channels": _string_array(Dictionary(current.get("activation_state", {})).get("dormant_channels", []))
	}

static func apply_post_run(governance_state: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary, constitution_summary: Dictionary) -> Dictionary:
	var current := normalize(governance_state)
	var constitution_id := str(constitution_summary.get("constitution_id", constitution_summary.get("constitution_hash", ""))).strip_edges()
	var doctrine_goal := str(diagnostics.get("doctrine_world_goal", constitution_summary.get("world_goal", ""))).strip_edges()
	var pressure_line := str(diagnostics.get("doctrine_pressure_line", constitution_summary.get("pressure_line", ""))).strip_edges()
	if not constitution_id.is_empty():
		var history := _dict_array(current.get("constitution_history", []))
		history.push_front({
			"constitution_id": constitution_id,
			"constitution_hash": str(constitution_summary.get("constitution_hash", "")).strip_edges(),
			"doctrine_family": str(constitution_summary.get("doctrine_family", diagnostics.get("doctrine_family", ""))).strip_edges(),
			"world_goal": doctrine_goal,
			"pressure_line": pressure_line,
			"seed": int(run_record.get("seed", 0)),
			"summary_lines": [pressure_line if not pressure_line.is_empty() else doctrine_goal]
		})
		current["constitution_history"] = history.slice(0, MAX_HISTORY)
	var activation_state := normalize_activation_state({
		"epoch": str(constitution_summary.get("activation_epoch", "activated")).strip_edges(),
		"active_channels": _string_array(constitution_summary.get("activation_active_channels", [])),
		"dormant_channels": _string_array(constitution_summary.get("activation_dormant_channels", [])),
		"safe_mode_active": bool(constitution_summary.get("safe_mode_active", false)),
		"activation_lines": _string_array(constitution_summary.get("activation_lines", []))
	})
	var safe_mode_state := normalize_safe_mode_state({
		"enabled": bool(constitution_summary.get("safe_mode_active", false)),
		"reason": _first_string(constitution_summary.get("safe_mode_lines", []), ""),
		"summary_lines": _string_array(constitution_summary.get("safe_mode_lines", []))
	})
	var theory_statuses := _string_array(diagnostics.get("theory_statuses", []))
	var contradiction_records: Array[Dictionary] = []
	if theory_statuses.has("rival") or theory_statuses.has("cookbook") or theory_statuses.has("anomaly"):
		contradiction_records.append({
			"record_id": "run_contradiction_%s" % str(run_record.get("seed", 0)),
			"status": "active",
			"summary_lines": ["the completed run preserved visible contradiction between active doctrine carriers"]
		})
	current["activation_state"] = activation_state
	current["safe_mode_state"] = safe_mode_state
	current["contradiction_records"] = _normalize_reports(Array(current.get("contradiction_records", [])) + contradiction_records)
	current["stability_reports"] = _prepend_report(Array(current.get("stability_reports", [])), {
		"report_id": "stability_%s" % str(run_record.get("seed", 0)),
		"status": "cooling" if bool(safe_mode_state.get("enabled", false)) else "stable",
		"summary_lines": _slice_strings([
			_first_non_empty([
				_first_string(constitution_summary.get("review_surface_lines", []), ""),
				str(frame.get("governance_line", "")).strip_edges(),
				"post-run governance review completed"
			])
		], 1)
	})
	current["anti_bottleneck_reports"] = _prepend_report(Array(current.get("anti_bottleneck_reports", [])), {
		"report_id": "anti_bottleneck_%s" % str(run_record.get("seed", 0)),
		"status": "blocked" if theory_statuses.size() <= 1 else "stable",
		"summary_lines": ["post-run anti-bottleneck review %s" % ("found a theory monopoly risk" if theory_statuses.size() <= 1 else "kept plural theory pressure alive")]
	})
	current["play_routing_reports"] = _prepend_report(Array(current.get("play_routing_reports", [])), {
		"report_id": "play_routing_%s" % str(run_record.get("seed", 0)),
		"status": "stable",
		"baseline_routes": BASELINE_ROUTES.duplicate(),
		"summary_lines": ["advanced doctrine remained routed through embodied expedition play"]
	})
	current["court_decisions"] = _prepend_report(Array(current.get("court_decisions", [])), {
		"decision_id": "court_%s" % str(run_record.get("seed", 0)),
		"status": "cooling" if bool(safe_mode_state.get("enabled", false)) else "promote",
		"summary_lines": ["court %s" % ("kept cooling active for the next constitution" if bool(safe_mode_state.get("enabled", false)) else "left active doctrine channels in circulation for the next constitution")]
	})
	current["meta_reflection_reports"] = _prepend_report(Array(current.get("meta_reflection_reports", [])), {
		"reflection_id": "meta_%s" % str(run_record.get("seed", 0)),
		"status": "cooling" if bool(safe_mode_state.get("enabled", false)) else "stable",
		"summary_lines": [_first_non_empty([
			_first_string(diagnostics.get("review_surface_lines", []), ""),
			"meta reflection retained cumulative doctrine memory without rewriting run truth"
		])]
	})
	return normalize(current)

static func _default_activation_state() -> Dictionary:
	return {
		"epoch": "activated",
		"active_channels": ["constitution", "archive", "world_memory", "inquiry", "theory", "cognitive_field"],
		"dormant_channels": ["cookbook", "factions", "world_mutation", "contradiction", "safe_mode"],
		"safe_mode_active": false,
		"quarantine_ids": [],
		"activation_lines": ["governance is prepared to promote doctrine carriers once their inputs appear"]
	}

static func _default_safe_mode_state() -> Dictionary:
	return {
		"enabled": false,
		"reason": "",
		"fallback_constitution_id": "",
		"cooling_tags": ["theory", "cookbook", "world_mutation"],
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
