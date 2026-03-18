class_name TheoryEngine
extends RefCounted

const THEORY_STORE_SCRIPT = preload("res://src/product/delvemind_theory_store.gd")
const SIMULATION_CHAMBERS_SCRIPT = preload("res://src/delve/simulation_chambers.gd")

const BASELINE_ROUTES := ["movement", "burden", "rescue", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"]
const STATUS_PRIORITY := {
	"official": 5,
	"synthesis": 4,
	"rival": 3,
	"cookbook": 2,
	"anomaly": 2,
	"suppressed": 1,
	"proto": 0
}

static func build_surface(experiment_state: Dictionary, world_model: Dictionary = {}, governance_state: Dictionary = {}) -> Dictionary:
	var theory_store := THEORY_STORE_SCRIPT.sync_from_experiments(
		Dictionary(experiment_state.get("theory_store", {})),
		experiment_state
	)
	var experiments := Dictionary(experiment_state.get("experiments", {}))
	var judgments := _dict_array(Dictionary(experiment_state.get("judgment_store", {})).get("judgments", []))
	var observations := _dict_array(Dictionary(experiment_state.get("observation_store", {})).get("records", []))
	var cookbook_state := Dictionary(world_model.get("cookbook_state_snapshot", {}))
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var activation_state: Dictionary = Dictionary(governance_state.get("activation_state", {}))
	var safe_mode_state: Dictionary = Dictionary(governance_state.get("safe_mode_state", {}))
	var quarantine_ids := _string_array(activation_state.get("quarantine_ids", []))
	var theories := _dict_array(theory_store.get("theories", []))
	theories = _merge_special_theories(theories, cookbook_state, cultural, observations)
	var enriched: Array[Dictionary] = []
	for theory_raw in theories:
		var theory := Dictionary(theory_raw).duplicate(true)
		var theory_id := str(theory.get("theory_id", "")).strip_edges()
		if theory_id.is_empty():
			continue
		var score := _theory_score(theory, experiments, judgments, world_model)
		theory["score"] = score
		theory["judgment_confidence"] = _judgment_confidence(theory_id, judgments)
		theory["play_routing_tags"] = _merged_routes(_string_array(theory.get("play_routing_tags", [])))
		theory["status"] = _resolved_status(
			theory,
			score,
			quarantine_ids,
			bool(safe_mode_state.get("enabled", false)),
			cookbook_state,
			cultural
		)
		enriched.append(theory)
	enriched.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_priority := int(STATUS_PRIORITY.get(str(a.get("status", "proto")), 0))
		var b_priority := int(STATUS_PRIORITY.get(str(b.get("status", "proto")), 0))
		if a_priority == b_priority:
			if int(a.get("score", 0)) == int(b.get("score", 0)):
				return str(a.get("theory_id", "")) < str(b.get("theory_id", ""))
			return int(a.get("score", 0)) > int(b.get("score", 0))
		return a_priority > b_priority
	)
	enriched = _maybe_add_synthesis(enriched, judgments, cultural)
	var school_ids := _school_ids_for_theories(theory_store, enriched)
	var statuses := _statuses_for_theories(enriched)
	var chamber_state := SIMULATION_CHAMBERS_SCRIPT.build_state(
		{
			"theories": enriched,
			"theory_ids": _theory_ids(enriched),
			"statuses": statuses
		},
		world_model,
		governance_state,
		Dictionary(experiment_state.get("judgment_store", {}))
	)
	var chamber_surface := Dictionary(SIMULATION_CHAMBERS_SCRIPT.build_surface(chamber_state))
	var lines := _surface_lines(enriched, chamber_surface)
	var next_store := theory_store.duplicate(true)
	next_store["theories"] = enriched
	next_store["schools"] = _schools_for_surface(Array(next_store.get("schools", [])), school_ids)
	next_store["lineage_registry"] = _updated_lineage_registry(Dictionary(next_store.get("lineage_registry", {})), enriched)
	return {
		"lines": lines,
		"theory_ids": _theory_ids(enriched),
		"school_ids": school_ids,
		"statuses": statuses,
		"coexistence_modes": _coexistence_modes(statuses),
		"activation_epoch": _activation_epoch(activation_state, enriched),
		"chamber_forecasts": Array(Dictionary(chamber_state).get("records", [])).duplicate(true),
		"chamber_lines": Array(chamber_surface.get("lines", [])).duplicate(true),
		"theories": enriched,
		"promotion_candidates": _promotion_candidates(enriched),
		"play_routing_tags": BASELINE_ROUTES.duplicate(),
		"theory_store": next_store
	}

static func _merge_special_theories(theories: Array[Dictionary], cookbook_state: Dictionary, cultural: Dictionary, observations: Array[Dictionary]) -> Array[Dictionary]:
	var next := theories.duplicate(true)
	for theory_id in _string_array(cookbook_state.get("unauthorized_theory_ids", [])):
		if _has_theory(next, theory_id):
			continue
		next.append({
			"theory_id": theory_id,
			"label": "Cookbook %s" % theory_id.replace("_", " "),
			"status": "cookbook",
			"school_id": "cookbook_school",
			"observable_ids": _string_array(cookbook_state.get("unauthorized_theory_links", [])),
			"play_routing_tags": BASELINE_ROUTES.duplicate()
		})
	if int(cultural.get("contradiction_heat", 0)) >= 3 or not observations.is_empty():
		var anomaly_id := "theory_anomaly_pressure"
		if not _has_theory(next, anomaly_id):
			next.append({
				"theory_id": anomaly_id,
				"label": "Anomaly pressure",
				"status": "anomaly",
				"school_id": "anomaly_school",
				"observable_ids": ["anomaly", "contradiction", "witness"],
				"play_routing_tags": BASELINE_ROUTES.duplicate()
			})
	return next

static func _theory_score(theory: Dictionary, experiments: Dictionary, judgments: Array[Dictionary], world_model: Dictionary) -> int:
	var theory_id := str(theory.get("theory_id", "")).strip_edges()
	var score := int(theory.get("score", 0))
	var status := str(theory.get("status", "proto")).strip_edges()
	score += int(STATUS_PRIORITY.get(status, 0)) * 3
	for experiment_raw in experiments.values():
		var experiment := Dictionary(experiment_raw)
		if theory_id.find(str(experiment.get("experiment_id", "")).strip_edges()) != -1:
			score += int(experiment.get("manifest_count", 0)) + (2 if str(experiment.get("state", "")).strip_edges() in ["active", "foundational"] else 0)
	for judgment in judgments:
		if str(Dictionary(judgment).get("theory_id", "")).strip_edges() == theory_id:
			score += int(Dictionary(judgment).get("confidence", 0)) * 2
			var outcome := str(Dictionary(judgment).get("outcome", "")).strip_edges()
			if outcome in ["accepted", "official", "promote", "synthesize"]:
				score += 3
			elif outcome in ["rejected", "suppressed"]:
				score -= 2
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	if status == "cookbook":
		score += int(cultural.get("cookbook_fragment_count", 0)) + int(cultural.get("cookbook_holder_depth", 0))
	if status == "anomaly":
		score += int(Dictionary(world_model.get("ecology_model", {})).get("anomaly_recurrence", 0))
	return score

static func _judgment_confidence(theory_id: String, judgments: Array[Dictionary]) -> int:
	var best := 0
	for judgment in judgments:
		if str(Dictionary(judgment).get("theory_id", "")).strip_edges() == theory_id:
			best = maxi(best, int(Dictionary(judgment).get("confidence", 0)))
	return best

static func _resolved_status(theory: Dictionary, score: int, quarantine_ids: Array[String], safe_mode: bool, cookbook_state: Dictionary, cultural: Dictionary) -> String:
	var theory_id := str(theory.get("theory_id", "")).strip_edges()
	var current_status := str(theory.get("status", "proto")).strip_edges()
	if quarantine_ids.has(theory_id):
		return "suppressed"
	if current_status == "cookbook":
		return "suppressed" if safe_mode and int(Dictionary(cookbook_state.get("power_envelope", {})).get("instability", 0)) >= 4 else "cookbook"
	if current_status == "anomaly":
		return "suppressed" if safe_mode else "anomaly"
	if safe_mode and int(cultural.get("contradiction_heat", 0)) >= 4 and score < 12:
		return "suppressed"
	if score >= 16:
		return "official"
	if score >= 11:
		return "rival"
	return "suppressed" if current_status == "suppressed" else current_status if current_status != "proto" else "proto"

static func _maybe_add_synthesis(theories: Array[Dictionary], judgments: Array[Dictionary], cultural: Dictionary) -> Array[Dictionary]:
	var next := theories.duplicate(true)
	var official := _first_by_status(next, "official")
	var rival := _first_by_status(next, "rival")
	if official.is_empty() or rival.is_empty():
		return next
	if int(cultural.get("contradiction_heat", 0)) < 2 and _count_outcome(judgments, "synthesize") <= 0:
		return next
	var official_id := str(official.get("theory_id", "")).strip_edges()
	var rival_id := str(rival.get("theory_id", "")).strip_edges()
	var theory_id := "theory_synthesis_%s_%s" % [official_id.md5_text().substr(0, 4), rival_id.md5_text().substr(0, 4)]
	if _has_theory(next, theory_id):
		return next
	next.append({
		"theory_id": theory_id,
		"label": "%s / %s synthesis" % [str(official.get("label", official_id)).strip_edges(), str(rival.get("label", rival_id)).strip_edges()],
		"status": "synthesis",
		"school_id": "synthesis_school",
		"observable_ids": _string_array(Array(official.get("observable_ids", [])) + Array(rival.get("observable_ids", []))),
		"play_routing_tags": BASELINE_ROUTES.duplicate(),
		"score": int(official.get("score", 0)) + int(rival.get("score", 0)) / 2
	})
	next.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_priority := int(STATUS_PRIORITY.get(str(a.get("status", "proto")), 0))
		var b_priority := int(STATUS_PRIORITY.get(str(b.get("status", "proto")), 0))
		if a_priority == b_priority:
			return int(a.get("score", 0)) > int(b.get("score", 0))
		return a_priority > b_priority
	)
	return next

static func _surface_lines(theories: Array[Dictionary], chamber_surface: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var official := _first_by_status(theories, "official")
	var rival := _first_by_status(theories, "rival")
	var cookbook := _first_by_status(theories, "cookbook")
	if not official.is_empty():
		lines.append("%s is now the official theory carrier" % str(official.get("label", official.get("theory_id", "theory"))).strip_edges())
	if not rival.is_empty():
		lines.append("%s remains active as a rival reading" % str(rival.get("label", rival.get("theory_id", "rival"))).strip_edges())
	if not cookbook.is_empty():
		lines.append("%s is distorting doctrine through illicit marginalia" % str(cookbook.get("label", cookbook.get("theory_id", "cookbook"))).strip_edges())
	for chamber_line in _string_array(chamber_surface.get("lines", [])):
		if not lines.has(chamber_line):
			lines.append(chamber_line)
		if lines.size() >= 4:
			break
	return lines.slice(0, 4)

static func _school_ids_for_theories(theory_store: Dictionary, theories: Array[Dictionary]) -> Array[String]:
	var result := _string_array(Array(THEORY_STORE_SCRIPT.build_public_surface(theory_store).get("school_ids", [])))
	for theory in theories:
		var school_id := str(Dictionary(theory).get("school_id", "")).strip_edges()
		if not school_id.is_empty() and not result.has(school_id):
			result.append(school_id)
	return result

static func _schools_for_surface(existing: Array, school_ids: Array[String]) -> Array[Dictionary]:
	var schools := _dict_array(existing)
	for school_id in school_ids:
		if _has_school(schools, school_id):
			continue
		schools.append({
			"school_id": school_id,
			"label": school_id.replace("_", " ").capitalize(),
			"stance": "contested" if school_id.find("rival") != -1 or school_id.find("cookbook") != -1 or school_id.find("anomaly") != -1 else "stabilizing",
			"visibility": "operator" if school_id.find("cookbook") != -1 or school_id.find("anomaly") != -1 else "public"
		})
	return schools

static func _updated_lineage_registry(existing: Dictionary, theories: Array[Dictionary]) -> Dictionary:
	var registry := Dictionary(existing).duplicate(true)
	for theory in theories:
		var theory_id := str(Dictionary(theory).get("theory_id", "")).strip_edges()
		if theory_id.is_empty():
			continue
		registry[theory_id] = {
			"lineage_id": theory_id,
			"kind": "theory",
			"label": str(Dictionary(theory).get("label", theory_id)).strip_edges(),
			"source_ids": _string_array(Dictionary(theory).get("observable_ids", [])),
			"state": str(Dictionary(theory).get("status", "proto")).strip_edges(),
			"visibility": "operator" if str(Dictionary(theory).get("status", "")).strip_edges() in ["cookbook", "anomaly", "suppressed"] else "public",
			"play_routing_tags": _merged_routes(_string_array(Dictionary(theory).get("play_routing_tags", [])))
		}
	return registry

static func _coexistence_modes(statuses: Array[String]) -> Array[String]:
	var result: Array[String] = []
	if statuses.has("official") and statuses.has("rival"):
		result.append("official_vs_rival")
	if statuses.has("official") and statuses.has("cookbook"):
		result.append("official_vs_cookbook")
	if statuses.has("anomaly"):
		result.append("anomaly_pressure")
	if statuses.has("synthesis"):
		result.append("synthesis")
	if result.is_empty():
		result.append("single_read")
	return result

static func _activation_epoch(activation_state: Dictionary, theories: Array[Dictionary]) -> String:
	var epoch := str(activation_state.get("epoch", "")).strip_edges()
	if not epoch.is_empty():
		return epoch
	return "fully_active" if not theories.is_empty() else "structural_presence"

static func _promotion_candidates(theories: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for theory in theories:
		var status := str(Dictionary(theory).get("status", "")).strip_edges()
		if status in ["official", "rival", "synthesis"]:
			result.append(str(Dictionary(theory).get("theory_id", "")).strip_edges())
	return _string_array(result)

static func _theory_ids(theories: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for theory in theories:
		var theory_id := str(Dictionary(theory).get("theory_id", "")).strip_edges()
		if not theory_id.is_empty() and not result.has(theory_id):
			result.append(theory_id)
	return result

static func _statuses_for_theories(theories: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for theory in theories:
		var status := str(Dictionary(theory).get("status", "")).strip_edges()
		if not status.is_empty() and not result.has(status):
			result.append(status)
	return result

static func _first_by_status(theories: Array[Dictionary], status: String) -> Dictionary:
	for theory in theories:
		if str(Dictionary(theory).get("status", "")).strip_edges() == status:
			return Dictionary(theory).duplicate(true)
	return {}

static func _has_theory(theories: Array[Dictionary], theory_id: String) -> bool:
	for theory in theories:
		if str(Dictionary(theory).get("theory_id", "")).strip_edges() == theory_id:
			return true
	return false

static func _has_school(schools: Array[Dictionary], school_id: String) -> bool:
	for school in schools:
		if str(Dictionary(school).get("school_id", "")).strip_edges() == school_id:
			return true
	return false

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

static func _merged_routes(routes: Array[String]) -> Array[String]:
	return _string_array(routes + BASELINE_ROUTES)

static func _count_outcome(judgments: Array[Dictionary], target: String) -> int:
	var count := 0
	for judgment in judgments:
		if str(Dictionary(judgment).get("outcome", "")).strip_edges() == target:
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
