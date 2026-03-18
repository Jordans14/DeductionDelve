class_name CookbookFragmentService
extends RefCounted

const MAX_FRAGMENTS := 12
const MAX_LINES := 6

static func default_state() -> Dictionary:
	return {
		"schema_name": "CookbookState",
		"schema_version": 1,
		"fragment_count": 0,
		"holder_depth": 0,
		"network_pressure": 0,
		"redirection_pressure": 0,
		"holder_state": "none",
		"fragment_lines": [],
		"marginalia_lines": [],
		"network_lines": [],
		"fragments": [],
		"escalation_stage": "dormant",
		"unauthorized_theory_ids": [],
		"unauthorized_theory_links": [],
		"contamination_state": {
			"heat": 0,
			"summary_lines": []
		},
		"doctrine_stress_state": {
			"stress": 0,
			"summary_lines": []
		},
		"power_envelope": {
			"reach": 0,
			"instability": 0,
			"detection_risk": 0,
			"doctrine_stress": 0
		},
		"contradiction_pressure": 0,
		"governance_risk": 0
	}

static func normalize(state: Dictionary) -> Dictionary:
	var current := default_state()
	for key in state.keys():
		current[key] = state[key]
	for key in ["fragment_count", "holder_depth", "network_pressure", "redirection_pressure"]:
		current[key] = maxi(int(current.get(key, 0)), 0)
	current["holder_state"] = str(current.get("holder_state", "none")).strip_edges()
	if current["holder_state"].is_empty():
		current["holder_state"] = "none"
	current["fragment_lines"] = _slice_strings(_string_array(current.get("fragment_lines", [])), MAX_LINES)
	current["marginalia_lines"] = _slice_strings(_string_array(current.get("marginalia_lines", [])), MAX_LINES)
	current["network_lines"] = _slice_strings(_string_array(current.get("network_lines", [])), MAX_LINES)
	current["fragments"] = _normalize_fragments(Array(current.get("fragments", [])))
	current["escalation_stage"] = _resolve_escalation_stage(current)
	current["unauthorized_theory_ids"] = _string_array(current.get("unauthorized_theory_ids", []))
	current["unauthorized_theory_links"] = _string_array(current.get("unauthorized_theory_links", current.get("unauthorized_theory_ids", [])))
	current["contamination_state"] = _normalize_contamination_state(Dictionary(current.get("contamination_state", {})), current)
	current["power_envelope"] = _normalize_power_envelope(Dictionary(current.get("power_envelope", {})), current)
	current["doctrine_stress_state"] = _normalize_doctrine_stress_state(Dictionary(current.get("doctrine_stress_state", {})), current)
	current["contradiction_pressure"] = clampi(int(current.get("contradiction_pressure", int(current.get("redirection_pressure", 0)) + int(current.get("fragment_count", 0)))), 0, 12)
	current["governance_risk"] = clampi(int(current.get("governance_risk", int(Dictionary(current.get("power_envelope", {})).get("instability", 0)) + int(Dictionary(current.get("power_envelope", {})).get("detection_risk", 0)) / 2)), 0, 12)
	return current

static func advance_state(current_state: Dictionary, run_record: Dictionary, frame: Dictionary) -> Dictionary:
	var next := normalize(current_state)
	var fragments := _normalize_fragments(Array(next.get("fragments", [])))
	if int(next.get("fragment_count", 0)) >= 1:
		var fragment_line := _first_non_empty([
			_first_string(Array(next.get("fragment_lines", [])), ""),
			str(frame.get("anomaly_pull", "")).strip_edges(),
			str(frame.get("counterfactual_line", "")).strip_edges(),
			"forbidden marginalia remain in circulation"
		])
		var fragment_id := "fragment_%s" % fragment_line.md5_text().substr(0, 12)
		if not _has_fragment(fragments, fragment_id):
			fragments.push_front({
				"fragment_id": fragment_id,
				"claim": fragment_line,
				"method": _first_non_empty([
					_first_string(Array(next.get("marginalia_lines", [])), ""),
					"marginal reconstruction"
				]),
				"status": _resolve_fragment_status(next),
				"leverage": "route and custody ambiguity",
				"cost": "contamination, contradiction, and detection pressure",
				"risk": "institutional scrutiny",
				"burden": "someone must carry the illicit reading into the next expedition",
				"power_envelope": {
					"reach": clampi(int(next.get("holder_depth", 0)) + int(next.get("network_pressure", 0)), 0, 12),
					"instability": clampi(int(next.get("redirection_pressure", 0)) + 1, 0, 12),
					"detection_risk": clampi(int(next.get("network_pressure", 0)) + int(next.get("holder_depth", 0)), 0, 12),
					"doctrine_stress": clampi(int(next.get("redirection_pressure", 0)) + int(next.get("fragment_count", 0)) / 2, 0, 12)
				},
				"play_routing_tags": ["movement", "burden", "witness", "route_choice", "artifact_custody", "hesitation", "return"],
				"activation_allowed": int(next.get("holder_depth", 0)) >= 1 or int(next.get("fragment_count", 0)) >= 2
			})
		if fragments.size() >= 2 and Array(next.get("unauthorized_theory_ids", [])).is_empty():
			next["unauthorized_theory_ids"] = ["cookbook_shadow_theory"]
			next["unauthorized_theory_links"] = ["cookbook_shadow_theory"]
	var mutation_public_summary: Dictionary = Dictionary(run_record.get("mutation_public_summary", {}))
	if not _string_array(mutation_public_summary.get("public_lines", [])).is_empty():
		next["fragment_lines"] = _slice_strings(Array(next.get("fragment_lines", [])) + _string_array(mutation_public_summary.get("public_lines", [])), MAX_LINES)
	next["fragments"] = fragments.slice(0, MAX_FRAGMENTS)
	next["contradiction_pressure"] = clampi(int(next.get("redirection_pressure", 0)) + int(next.get("fragment_count", 0)) + int(next.get("holder_depth", 0)), 0, 12)
	next["governance_risk"] = clampi(int(next.get("network_pressure", 0)) + int(next.get("holder_depth", 0)) + int(next.get("contradiction_pressure", 0)) / 2, 0, 12)
	return normalize(next)

static func build_public_lines(state: Dictionary) -> Array[String]:
	var current := normalize(state)
	var lines: Array[String] = []
	if not Array(current.get("fragment_lines", [])).is_empty():
		lines.append(str(Array(current.get("fragment_lines", []))[0]))
	if not Array(current.get("marginalia_lines", [])).is_empty():
		lines.append(str(Array(current.get("marginalia_lines", []))[0]))
	if int(current.get("contradiction_pressure", 0)) >= 3:
		lines.append("cookbook pressure is now generating visible contradiction")
	return _slice_strings(lines, 3)

static func _normalize_fragments(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["fragment_id"] = str(current.get("fragment_id", "")).strip_edges()
		current["claim"] = str(current.get("claim", "")).strip_edges()
		current["method"] = str(current.get("method", "")).strip_edges()
		current["status"] = str(current.get("status", "glimpsed")).strip_edges()
		current["leverage"] = str(current.get("leverage", "route and custody ambiguity")).strip_edges()
		current["cost"] = str(current.get("cost", "contamination, contradiction, and detection pressure")).strip_edges()
		current["risk"] = str(current.get("risk", "institutional scrutiny")).strip_edges()
		current["burden"] = str(current.get("burden", "someone must carry the illicit reading into the next expedition")).strip_edges()
		current["power_envelope"] = _normalize_fragment_power(Dictionary(current.get("power_envelope", {})))
		current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
		current["activation_allowed"] = bool(current.get("activation_allowed", false))
		if not current["fragment_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_FRAGMENTS)

static func _normalize_fragment_power(raw: Dictionary) -> Dictionary:
	var current := {
		"reach": 0,
		"instability": 0,
		"detection_risk": 0,
		"doctrine_stress": 0
	}
	for key in raw.keys():
		current[key] = raw[key]
	for key in current.keys():
		current[key] = clampi(int(current.get(key, 0)), 0, 12)
	return current

static func _normalize_contamination_state(raw: Dictionary, cookbook_state: Dictionary) -> Dictionary:
	var current := {
		"heat": 0,
		"summary_lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["heat"] = clampi(int(current.get("heat", int(cookbook_state.get("redirection_pressure", 0)))), 0, 12)
	current["summary_lines"] = _slice_strings(_string_array(current.get("summary_lines", [])) + ["cookbook power remains coupled to contamination, contradiction, and detection"], MAX_LINES)
	return current

static func _normalize_power_envelope(raw: Dictionary, cookbook_state: Dictionary) -> Dictionary:
	var current := {
		"reach": 0,
		"instability": 0,
		"detection_risk": 0,
		"doctrine_stress": 0
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["reach"] = clampi(int(current.get("reach", int(cookbook_state.get("fragment_count", 0)))), 0, 12)
	current["instability"] = clampi(int(current.get("instability", int(cookbook_state.get("redirection_pressure", 0)))), 0, 12)
	current["detection_risk"] = clampi(int(current.get("detection_risk", int(cookbook_state.get("network_pressure", 0)) + int(cookbook_state.get("holder_depth", 0)))), 0, 12)
	current["doctrine_stress"] = clampi(int(current.get("doctrine_stress", int(cookbook_state.get("redirection_pressure", 0)) + int(cookbook_state.get("fragment_count", 0)) / 2)), 0, 12)
	return current

static func _normalize_doctrine_stress_state(raw: Dictionary, cookbook_state: Dictionary) -> Dictionary:
	var current := {
		"stress": 0,
		"summary_lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["stress"] = clampi(int(current.get("stress", int(Dictionary(cookbook_state.get("power_envelope", {})).get("doctrine_stress", 0)))), 0, 12)
	current["summary_lines"] = _slice_strings(
		_string_array(current.get("summary_lines", [])) + ["cookbook doctrine stress remains coupled to contradiction and detection"],
		MAX_LINES
	)
	return current

static func _resolve_escalation_stage(cookbook_state: Dictionary) -> String:
	if int(cookbook_state.get("holder_depth", 0)) >= 2 or int(cookbook_state.get("network_pressure", 0)) >= 3:
		return "networked"
	if int(cookbook_state.get("fragment_count", 0)) >= 2:
		return "assembled"
	if int(cookbook_state.get("fragment_count", 0)) >= 1:
		return "glimpsed"
	return "dormant"

static func _resolve_fragment_status(cookbook_state: Dictionary) -> String:
	match str(cookbook_state.get("escalation_stage", _resolve_escalation_stage(cookbook_state))):
		"networked":
			return "networked"
		"assembled":
			return "assembled"
		_:
			return "glimpsed"

static func _has_fragment(values: Array[Dictionary], fragment_id: String) -> bool:
	for value in values:
		if str(Dictionary(value).get("fragment_id", "")).strip_edges() == fragment_id:
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

static func _slice_strings(values: Array, limit: int) -> Array[String]:
	return _string_array(values).slice(0, limit)

static func _first_string(values: Array, fallback: String) -> String:
	for value in _string_array(values):
		return value
	return fallback

static func _first_non_empty(values: Array) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return ""
