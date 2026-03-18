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
		record["recommended_status"] = str(record.get("recommended_status", "observe")).strip_edges()
		record["play_routing_tags"] = _string_array(record.get("play_routing_tags", []))
		record["governance_signal"] = str(record.get("governance_signal", "observe")).strip_edges()
		if not record["forecast_id"].is_empty():
			records.append(record)
	current["records"] = records
	return current

static func build_state(theory_surface: Dictionary, world_model: Dictionary = {}, governance_state: Dictionary = {}, judgment_store: Dictionary = {}) -> Dictionary:
	var theories := _normalized_theories(theory_surface)
	var theory_ids := _string_array(theory_surface.get("theory_ids", []))
	var statuses := _string_array(theory_surface.get("statuses", []))
	var social: Dictionary = Dictionary(world_model.get("social_model", {}))
	var route: Dictionary = Dictionary(world_model.get("route_model", {}))
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var ecology: Dictionary = Dictionary(world_model.get("ecology_model", {}))
	var economy: Dictionary = Dictionary(world_model.get("economy_model", {}))
	var activation_state: Dictionary = Dictionary(governance_state.get("activation_state", {}))
	var safe_mode_state: Dictionary = Dictionary(governance_state.get("safe_mode_state", {}))
	var judgments := _dict_array(judgment_store.get("judgments", []))
	var accepted_count := _count_outcomes(judgments, ["accepted", "official", "promote", "synthesize"])
	var rejected_count := _count_outcomes(judgments, ["rejected", "suppressed", "abstain"])
	var rivalry_count := _status_count(statuses, ["rival", "suppressed", "cookbook", "anomaly"])
	var theory_pressure := theory_ids.size() + rivalry_count
	var dominant_theory_id := _dominant_theory_id(theories, theory_ids)
	var records: Array[Dictionary] = []
	for chamber_id in CHAMBER_IDS:
		var pressure := 0
		var recommended_status := "observe"
		var governance_signal := "observe"
		var prediction := ""
		var play_routing_tags: Array[String] = []
		match chamber_id:
			"tactical":
				pressure = int(route.get("route_control", 0)) + int(route.get("rescue_geometry", 0)) + int(economy.get("burden_tolerance", 0)) + theory_pressure
				recommended_status = "promote" if pressure >= 6 else "observe"
				governance_signal = "promote_tactical" if pressure >= 6 else "observe_tactical"
				play_routing_tags = ["movement", "burden", "rescue", "artifact_custody", "hesitation", "extraction"]
				prediction = "%s will keep steering movement, burden, and extraction through contested route geometry" % _theory_label(theories, dominant_theory_id)
			"crawl":
				pressure = int(route.get("relay_stress", 0)) + Array(route.get("witness_network", [])).size() + Array(route.get("relay_bottlenecks", [])).size() + int(social.get("obligation_heat", 0))
				recommended_status = "promote" if pressure >= 5 else "observe"
				governance_signal = "stabilize_return" if pressure >= 5 else "observe_return"
				play_routing_tags = ["movement", "witness", "route_choice", "return"]
				prediction = "relay stress will keep witness chains and return lanes under review"
			"cultural":
				pressure = int(cultural.get("contradiction_heat", 0)) + int(cultural.get("faction_count", 0)) + int(cultural.get("regime_count", 0)) + rivalry_count
				recommended_status = "synthesize" if pressure >= 6 else "observe"
				governance_signal = "adoption_conflict" if pressure >= 6 else "observe_adoption"
				play_routing_tags = ["witness", "artifact_custody", "hesitation", "return"]
				prediction = "factions and regimes will argue over which theory deserves public legitimacy"
			"epoch":
				pressure = int(cultural.get("world_mutation_count", 0)) + int(cultural.get("cookbook_fragment_count", 0)) + int(cultural.get("literacy_depth", 0)) + int(cultural.get("cookbook_redirection_pressure", 0))
				recommended_status = "counteract" if pressure >= 6 else "observe"
				governance_signal = "world_mutation_review" if pressure >= 6 else "observe_epoch"
				play_routing_tags = ["route_choice", "artifact_custody", "extraction", "return"]
				prediction = "world scars and illicit marginalia will keep mutating what the next expedition inherits"
			"constitutional":
				pressure = theory_pressure + accepted_count - rejected_count + int(ecology.get("anomaly_recurrence", 0)) + Array(activation_state.get("active_channels", [])).size()
				if bool(safe_mode_state.get("enabled", false)):
					pressure += 1
				recommended_status = "quarantine" if bool(safe_mode_state.get("enabled", false)) and rivalry_count >= 2 else "promote" if pressure >= 7 else "observe"
				governance_signal = "constitutional_quarantine" if recommended_status == "quarantine" else "constitutional_promotion" if recommended_status == "promote" else "observe_constitution"
				play_routing_tags = ["movement", "rescue", "witness", "route_choice", "artifact_custody", "extraction", "return"]
				prediction = "the constitution will keep selecting between promotion, synthesis, and quarantine instead of a single settled reading"
		records.append({
			"forecast_id": "forecast_%s" % chamber_id,
			"chamber_id": chamber_id,
			"theory_id": dominant_theory_id,
			"prediction": prediction,
			"confidence": clampi(int(round(float(pressure) / 2.5)), 1, 4),
			"recommended_status": recommended_status,
			"play_routing_tags": play_routing_tags,
			"governance_signal": governance_signal,
			"pressure": pressure
		})
	return normalize({"records": records})

static func build_surface(state: Dictionary) -> Dictionary:
	var current := normalize(state)
	var sorted_records := _dict_array(current.get("records", []))
	sorted_records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("confidence", 0)) == int(b.get("confidence", 0)):
			return str(a.get("chamber_id", "")) < str(b.get("chamber_id", ""))
		return int(a.get("confidence", 0)) > int(b.get("confidence", 0))
	)
	var lines: Array[String] = []
	for record in sorted_records:
		var prediction := str(Dictionary(record).get("prediction", "")).strip_edges()
		if not prediction.is_empty():
			lines.append("%s (%s)" % [prediction, str(Dictionary(record).get("recommended_status", "observe")).replace("_", " ")])
		if lines.size() >= 3:
			break
	return {
		"lines": lines,
		"records": Array(current.get("records", [])).duplicate(true)
	}

static func _normalized_theories(theory_surface: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in Array(theory_surface.get("theories", [])):
		if value is Dictionary:
			result.append(Dictionary(value).duplicate(true))
	if result.is_empty():
		var theory_ids := _string_array(theory_surface.get("theory_ids", []))
		var statuses := _string_array(theory_surface.get("statuses", []))
		for index in range(theory_ids.size()):
			result.append({
				"theory_id": theory_ids[index],
				"label": theory_ids[index].replace("_", " "),
				"status": statuses[index] if index < statuses.size() else "proto"
			})
	return result

static func _dominant_theory_id(theories: Array[Dictionary], theory_ids: Array[String]) -> String:
	if not theories.is_empty():
		return str(Dictionary(theories[0]).get("theory_id", "")).strip_edges()
	return _first_string(theory_ids, "")

static func _theory_label(theories: Array[Dictionary], theory_id: String) -> String:
	for theory in theories:
		if str(Dictionary(theory).get("theory_id", "")).strip_edges() == theory_id:
			return str(Dictionary(theory).get("label", theory_id)).strip_edges()
	return _first_non_empty([theory_id.replace("_", " "), "the current theory"])

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

static func _count_outcomes(values: Array[Dictionary], targets: Array[String]) -> int:
	var count := 0
	for value in values:
		if targets.has(str(Dictionary(value).get("outcome", "")).strip_edges()):
			count += 1
	return count

static func _status_count(values: Array[String], targets: Array[String]) -> int:
	var count := 0
	for value in values:
		if targets.has(value):
			count += 1
	return count

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
