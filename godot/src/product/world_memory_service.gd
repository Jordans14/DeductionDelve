class_name WorldMemoryService
extends RefCounted

const CIVILIZATION_STATE_SERVICE_SCRIPT = preload("res://src/product/civilization_state_service.gd")

const MYTH_BUCKETS: Array[String] = [
	"branch",
	"item",
	"player",
	"pair",
	"crew",
	"crawl",
	"place",
	"object",
	"run_shape"
]
const BUCKET_LIMIT := 20

static func default_state() -> Dictionary:
	var myths := {}
	for bucket in MYTH_BUCKETS:
		myths[bucket] = {}
	var current := {
		"run_index": 0,
		"myths": myths,
		"fascination": {
			"topics": {},
			"current_focus": "",
			"current_heat": 0,
			"phase": "roaming",
			"pressure": "",
			"cool_streak": 0,
			"focus_history": [],
			"streak": 0,
			"fatigue": 0
		},
		"legend_log": [],
		"myth_field": {
			"resonance_count": 0,
			"damping_count": 0,
			"shadow_count": 0,
			"top_successor": {},
			"active_lines": []
		},
		"cultural_gravity": {
			"top_label": "",
			"top_bucket": "",
			"top_gravity": 0,
			"lines": []
		},
		"topic_interaction": {
			"lines": []
		},
		"myth_cooling": {
			"lines": []
		},
		"myth_collision": {
			"lines": []
		},
		"myth_resurgence": {
			"lines": []
		},
		"institutional_order": {
			"legitimacy_pressure": 0,
			"taboo_heat": 0,
			"custody_pressure": 0,
			"burial_pressure": 0,
			"heresy_pressure": 0,
			"lines": [],
			"taboo_lines": [],
			"claim_lines": []
		},
		"epistemic_order": {
			"orthodoxy_strength": 0,
			"revision_pressure": 0,
			"false_canon_pressure": 0,
			"semantic_drift": 0,
			"forgery_pressure": 0,
			"dominant_tradition": "",
			"lines": [],
			"drift_lines": [],
			"forgery_lines": []
		},
		"affective_climate": {
			"dominant_age": "",
			"shame_heat": 0,
			"reverence_heat": 0,
			"paranoia_heat": 0,
			"punitive_heat": 0,
			"melancholy_heat": 0,
			"hope_heat": 0,
			"martyr_pressure": 0,
			"anti_martyr_pressure": 0,
			"ordinary_life_pressure": 0,
			"lines": [],
			"mourning_lines": [],
			"labor_lines": []
		},
		"ontology_state": {
			"dominant_ontology": "",
			"uncertainty_philosophy": "",
			"counterfactual_heat": 0,
			"lines": [],
			"uncertainty_lines": [],
			"echo_lines": []
		},
		"delve_history": {
			"method_counts": {},
			"dominant_method": "",
			"misclassification_pressure": 0,
			"overcorrection_pressure": 0,
			"abandoned_paradigms": [],
			"lines": [],
			"history_lines": []
		},
		"interpretation_network": {
			"node_heat": 0,
			"spread_heat": 0,
			"contradiction_heat": 0,
			"ritual_spread": 0,
			"institutional_campaigns": 0,
			"dominant_nodes": [],
			"lines": [],
			"spread_lines": [],
			"campaign_lines": []
		},
		"order_tension": {
			"sacred_pressure": 0,
			"administrative_pressure": 0,
			"practical_pressure": 0,
			"forbidden_site_pressure": 0,
			"sacred_artifact_pressure": 0,
			"lines": [],
			"site_lines": [],
			"artifact_lines": []
		},
		"silence_doctrine": {
			"silence_pressure": 0,
			"unclassified_pressure": 0,
			"lines": [],
			"zone_lines": []
		},
		"cookbook_shadow": {
			"fragment_heat": 0,
			"holder_rumor": 0,
			"network_rumor": 0,
			"redirection_pressure": 0,
			"lines": [],
			"rumor_lines": [],
			"redirection_lines": []
		},
		"crawl_network_state": {
			"relay_stress": 0,
			"witness_pressure": 0,
			"bottleneck_pressure": 0,
			"rumor_shock": 0,
			"cohort_pressure": 0,
			"lines": [],
			"witness_lines": [],
			"bottleneck_lines": []
		},
		"epoch_state": {
			"phase": "",
			"transition_pressure": 0,
			"driver": "",
			"lines": []
		}
	}
	for key in CIVILIZATION_STATE_SERVICE_SCRIPT.default_extensions().keys():
		current[key] = CIVILIZATION_STATE_SERVICE_SCRIPT.default_extensions()[key]
	return current

static func normalize(state: Dictionary) -> Dictionary:
	var current := default_state()
	for key in state.keys():
		current[key] = state[key]
	var myths: Dictionary = Dictionary(current.get("myths", {}))
	for bucket in MYTH_BUCKETS:
		var normalized_bucket := {}
		for myth_key in Dictionary(myths.get(bucket, {})).keys():
			var entry: Dictionary = Dictionary(Dictionary(myths.get(bucket, {})).get(myth_key, {}))
			normalized_bucket[str(myth_key)] = _normalize_myth_entry(entry)
		current["myths"][bucket] = normalized_bucket
	var fascination := Dictionary(current.get("fascination", {}))
	if not fascination.has("topics"):
		fascination["topics"] = {}
	if not fascination.has("current_focus"):
		fascination["current_focus"] = ""
	if not fascination.has("current_heat"):
		fascination["current_heat"] = 0
	if not fascination.has("phase"):
		fascination["phase"] = "roaming"
	if not fascination.has("pressure"):
		fascination["pressure"] = ""
	if not fascination.has("cool_streak"):
		fascination["cool_streak"] = 0
	if not fascination.has("focus_history"):
		fascination["focus_history"] = []
	if not fascination.has("streak"):
		fascination["streak"] = 0
	if not fascination.has("fatigue"):
		fascination["fatigue"] = 0
	current["fascination"] = fascination
	for key in ["myth_field", "cultural_gravity", "topic_interaction", "myth_cooling", "myth_collision", "myth_resurgence"]:
		if not current.has(key) or not (current.get(key) is Dictionary):
			current[key] = Dictionary(default_state().get(key, {})).duplicate(true)
	current["institutional_order"] = _normalize_institutional_order(Dictionary(current.get("institutional_order", {})))
	current["epistemic_order"] = _normalize_epistemic_order(Dictionary(current.get("epistemic_order", {})))
	current["affective_climate"] = _normalize_affective_climate(Dictionary(current.get("affective_climate", {})))
	current["ontology_state"] = _normalize_ontology_state(Dictionary(current.get("ontology_state", {})))
	current["delve_history"] = _normalize_delve_history(Dictionary(current.get("delve_history", {})))
	current["interpretation_network"] = _normalize_interpretation_network(Dictionary(current.get("interpretation_network", {})))
	current["order_tension"] = _normalize_order_tension(Dictionary(current.get("order_tension", {})))
	current["silence_doctrine"] = _normalize_silence_doctrine(Dictionary(current.get("silence_doctrine", {})))
	current["cookbook_shadow"] = _normalize_cookbook_shadow(Dictionary(current.get("cookbook_shadow", {})))
	current["crawl_network_state"] = _normalize_crawl_network_state(Dictionary(current.get("crawl_network_state", {})))
	current["epoch_state"] = _normalize_epoch_state(Dictionary(current.get("epoch_state", {})))
	current["legend_log"] = Array(current.get("legend_log", [])).slice(0, 40)
	current["run_index"] = int(current.get("run_index", 0))
	return CIVILIZATION_STATE_SERVICE_SCRIPT.normalize_world_memory_extensions(current)

static func epoch_state_for_test(world_memory: Dictionary) -> Dictionary:
	var current := normalize(world_memory)
	_update_epoch_state(current, {})
	return Dictionary(current.get("epoch_state", {})).duplicate(true)

static func apply_run(world_memory: Dictionary, run_context: Dictionary) -> Dictionary:
	var current := normalize(world_memory)
	current["run_index"] = int(current.get("run_index", 0)) + 1
	_cool_all(current)
	var touches := _build_touches(run_context)
	for touch in touches:
		_touch_entry(current, Dictionary(touch))
	_apply_interactions(current, touches, run_context)
	_trim_buckets(current)
	_refresh_field_state(current)
	_update_fascination(current, touches, run_context)
	_update_institutional_order(current, run_context)
	_update_epistemic_order(current, run_context)
	_update_affective_climate(current, run_context)
	_update_ontology_state(current, run_context)
	_update_delve_history(current, run_context)
	_update_interpretation_network(current, run_context)
	_update_order_tension(current, run_context)
	_update_silence_doctrine(current, run_context)
	_update_cookbook_shadow(current, run_context)
	_update_crawl_network_state(current, run_context)
	_update_epoch_state(current, run_context)
	return CIVILIZATION_STATE_SERVICE_SCRIPT.apply_post_run_extensions(current, run_context)

static func build_world_lines(world_memory: Dictionary) -> Array[String]:
	var current := normalize(world_memory)
	var fascination: Dictionary = Dictionary(current.get("fascination", {}))
	var focus := str(fascination.get("current_focus", "")).strip_edges()
	var heat := int(fascination.get("current_heat", 0))
	var phase := str(fascination.get("phase", "roaming"))
	var lines: Array[String] = []
	var top_branch_entries := top_bucket_entries(current, "branch", 1)
	var top_item_entries := top_bucket_entries(current, "item", 1)
	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(current)
	if focus.is_empty():
		lines.append("World attention: roaming")
	else:
		lines.append("World attention: %s (%s, %s)" % [focus, _heat_band(heat), phase])
		var pressure := str(fascination.get("pressure", "")).strip_edges()
		if not pressure.is_empty():
			lines.append("Cultural pressure: %s" % pressure)
		var fatigue := int(fascination.get("fatigue", 0))
		if fatigue >= 2:
			lines.append("Attention fatigue: the same story is starting to wear thin.")
		var focus_history := _string_array(fascination.get("focus_history", []))
		if focus_history.size() >= 2:
			lines.append("Echo trail: %s" % focus_history[1])
	var gravity_center := _current_gravity_center(current)
	if not gravity_center.is_empty():
		lines.append("Gravity center: %s" % gravity_center)
	var field_lines := _string_array(Dictionary(current.get("myth_field", {})).get("active_lines", []))
	if not field_lines.is_empty():
		lines.append("Field: %s" % field_lines[0])
	var top_successor := Dictionary(Dictionary(current.get("myth_field", {})).get("top_successor", {}))
	if not str(top_successor.get("hint", "")).strip_edges().is_empty():
		lines.append("Recast pressure: %s" % str(top_successor.get("hint", "")))
	if not top_branch_entries.is_empty():
		var branch_drift := str(Dictionary(top_branch_entries[0]).get("successor_hint", "")).strip_edges()
		if not branch_drift.is_empty():
			lines.append("Branch drift: %s" % branch_drift)
	var interaction_lines := _string_array(Dictionary(current.get("topic_interaction", {})).get("lines", []))
	if not interaction_lines.is_empty():
		lines.append("Interaction: %s" % interaction_lines[0])
	var protocol_lines := _string_array(Dictionary(current.get("myth_field", {})).get("protocol_lines", []))
	if not protocol_lines.is_empty():
		lines.append("Protocol: %s" % protocol_lines[0])
	var cooling_lines := _string_array(Dictionary(current.get("myth_cooling", {})).get("lines", []))
	if not cooling_lines.is_empty():
		lines.append("Cooling: %s" % cooling_lines[0])
	var resurgence_lines := _string_array(Dictionary(current.get("myth_resurgence", {})).get("lines", []))
	if not resurgence_lines.is_empty():
		lines.append("Return: %s" % resurgence_lines[0])
	var civilization_lines := _string_array(Dictionary(civilization_surface).get("lines", []))
	if not civilization_lines.is_empty():
		lines.append("Civilization: %s" % civilization_lines[0])
	var institutional_order := Dictionary(current.get("institutional_order", {}))
	var institutional_lines := _string_array(institutional_order.get("lines", []))
	if not institutional_lines.is_empty():
		lines.append("Institution: %s" % institutional_lines[0])
	var taboo_lines := _string_array(institutional_order.get("taboo_lines", []))
	if not taboo_lines.is_empty():
		lines.append("Taboo: %s" % taboo_lines[0])
	var claim_lines := _string_array(institutional_order.get("claim_lines", []))
	if not claim_lines.is_empty():
		lines.append("Legitimacy: %s" % claim_lines[0])
	var epistemic_order := Dictionary(current.get("epistemic_order", {}))
	var canon_lines := _string_array(epistemic_order.get("lines", []))
	if not canon_lines.is_empty():
		lines.append("Canon: %s" % canon_lines[0])
	elif not str(epistemic_order.get("dominant_tradition", "")).strip_edges().is_empty():
		lines.append("Canon: %s is becoming the default proof language." % str(epistemic_order.get("dominant_tradition", "")).to_lower())
	var drift_lines := _string_array(epistemic_order.get("drift_lines", []))
	if not drift_lines.is_empty():
		lines.append("Drift: %s" % drift_lines[0])
	var forgery_lines := _string_array(epistemic_order.get("forgery_lines", []))
	if not forgery_lines.is_empty():
		lines.append("Forgery: %s" % forgery_lines[0])
	var affective_climate := Dictionary(current.get("affective_climate", {}))
	var climate_lines := _string_array(affective_climate.get("lines", []))
	if not climate_lines.is_empty():
		lines.append("Climate: %s" % climate_lines[0])
	elif not str(affective_climate.get("dominant_age", "")).strip_edges().is_empty():
		lines.append("Climate: %s" % str(affective_climate.get("dominant_age", "")))
	var mourning_lines := _string_array(affective_climate.get("mourning_lines", []))
	if not mourning_lines.is_empty():
		lines.append("Mourning: %s" % mourning_lines[0])
	var labor_lines := _string_array(affective_climate.get("labor_lines", []))
	if not labor_lines.is_empty():
		lines.append("Civic: %s" % labor_lines[0])
	var ontology_state := Dictionary(current.get("ontology_state", {}))
	if not str(ontology_state.get("dominant_ontology", "")).strip_edges().is_empty():
		lines.append("Ontology: %s" % str(ontology_state.get("dominant_ontology", "")))
	var uncertainty_lines := _string_array(ontology_state.get("uncertainty_lines", []))
	if not uncertainty_lines.is_empty():
		lines.append("Uncertainty: %s" % uncertainty_lines[0])
	elif not str(ontology_state.get("uncertainty_philosophy", "")).strip_edges().is_empty():
		lines.append("Uncertainty: %s" % str(ontology_state.get("uncertainty_philosophy", "")))
	var echo_lines := _string_array(ontology_state.get("echo_lines", []))
	if not echo_lines.is_empty():
		lines.append("Echo: %s" % echo_lines[0])
	var delve_history := Dictionary(current.get("delve_history", {}))
	var delve_lines := _string_array(delve_history.get("lines", []))
	if not delve_lines.is_empty():
		lines.append("DelveMind: %s" % delve_lines[0])
	var history_lines := _string_array(delve_history.get("history_lines", []))
	if not history_lines.is_empty():
		lines.append("Method history: %s" % history_lines[0])
	var interpretation_network := Dictionary(current.get("interpretation_network", {}))
	var network_lines := _string_array(interpretation_network.get("lines", []))
	if not network_lines.is_empty():
		lines.append("Interpretation: %s" % network_lines[0])
	var spread_lines := _string_array(interpretation_network.get("spread_lines", []))
	if not spread_lines.is_empty():
		lines.append("Spread: %s" % spread_lines[0])
	var campaign_lines := _string_array(interpretation_network.get("campaign_lines", []))
	if not campaign_lines.is_empty():
		lines.append("Campaign: %s" % campaign_lines[0])
	var order_tension := Dictionary(current.get("order_tension", {}))
	var order_lines := _string_array(order_tension.get("lines", []))
	if not order_lines.is_empty():
		lines.append("Order: %s" % order_lines[0])
	var site_lines := _string_array(order_tension.get("site_lines", []))
	if not site_lines.is_empty():
		lines.append("Site: %s" % site_lines[0])
	var artifact_lines := _string_array(order_tension.get("artifact_lines", []))
	if not artifact_lines.is_empty():
		lines.append("Relic: %s" % artifact_lines[0])
	var silence_doctrine := Dictionary(current.get("silence_doctrine", {}))
	var silence_lines := _string_array(silence_doctrine.get("lines", []))
	if not silence_lines.is_empty():
		lines.append("Silence: %s" % silence_lines[0])
	var zone_lines := _string_array(silence_doctrine.get("zone_lines", []))
	if not zone_lines.is_empty():
		lines.append("Unclassified: %s" % zone_lines[0])
	var cookbook_shadow := Dictionary(current.get("cookbook_shadow", {}))
	var cookbook_lines := _string_array(cookbook_shadow.get("lines", []))
	if not cookbook_lines.is_empty():
		lines.append("Margins: %s" % cookbook_lines[0])
	var rumor_lines := _string_array(cookbook_shadow.get("rumor_lines", []))
	if not rumor_lines.is_empty():
		lines.append("Rumor: %s" % rumor_lines[0])
	var redirection_lines := _string_array(cookbook_shadow.get("redirection_lines", []))
	if not redirection_lines.is_empty():
		lines.append("Redirection: %s" % redirection_lines[0])
	var crawl_network_state := Dictionary(current.get("crawl_network_state", {}))
	var relay_lines := _string_array(crawl_network_state.get("lines", []))
	if not relay_lines.is_empty():
		lines.append("Relay: %s" % relay_lines[0])
	var witness_lines := _string_array(crawl_network_state.get("witness_lines", []))
	if not witness_lines.is_empty():
		lines.append("Witness: %s" % witness_lines[0])
	var bottleneck_lines := _string_array(crawl_network_state.get("bottleneck_lines", []))
	if not bottleneck_lines.is_empty():
		lines.append("Bottleneck: %s" % bottleneck_lines[0])
	var epoch_state := Dictionary(current.get("epoch_state", {}))
	var epoch_lines := _string_array(epoch_state.get("lines", []))
	if not epoch_lines.is_empty():
		lines.append("Epoch: %s" % epoch_lines[0])
	elif not str(epoch_state.get("phase", "")).strip_edges().is_empty():
		lines.append("Epoch: %s" % str(epoch_state.get("phase", "")))
	if not top_item_entries.is_empty():
		var artifact_culture := _first_string(_string_array(Dictionary(top_item_entries[0]).get("resonance_tags", [])), "")
		if not artifact_culture.is_empty():
			lines.append("Artifact culture: %s" % artifact_culture)
	var player_focus := top_bucket_entries(current, "player", 1)
	if not player_focus.is_empty():
		lines.append("Public memory: %s" % str(Dictionary(player_focus[0]).get("label", "")))
	for entry in top_branch_entries:
		lines.append("Branch echo: %s" % str(Dictionary(entry).get("label", "")))
	for entry in top_item_entries:
		lines.append("Item echo: %s" % str(Dictionary(entry).get("label", "")))
	return lines

static func field_snapshot(world_memory: Dictionary) -> Dictionary:
	var current := normalize(world_memory)
	return {
		"myth_field": Dictionary(current.get("myth_field", {})).duplicate(true),
		"cultural_gravity": Dictionary(current.get("cultural_gravity", {})).duplicate(true),
		"topic_interaction": Dictionary(current.get("topic_interaction", {})).duplicate(true),
		"myth_cooling": Dictionary(current.get("myth_cooling", {})).duplicate(true),
		"myth_collision": Dictionary(current.get("myth_collision", {})).duplicate(true),
		"myth_resurgence": Dictionary(current.get("myth_resurgence", {})).duplicate(true),
		"institutional_order": Dictionary(current.get("institutional_order", {})).duplicate(true),
		"epistemic_order": Dictionary(current.get("epistemic_order", {})).duplicate(true),
		"affective_climate": Dictionary(current.get("affective_climate", {})).duplicate(true),
		"ontology_state": Dictionary(current.get("ontology_state", {})).duplicate(true),
		"delve_history": Dictionary(current.get("delve_history", {})).duplicate(true),
		"interpretation_network": Dictionary(current.get("interpretation_network", {})).duplicate(true),
		"order_tension": Dictionary(current.get("order_tension", {})).duplicate(true),
		"silence_doctrine": Dictionary(current.get("silence_doctrine", {})).duplicate(true),
		"cookbook_shadow": Dictionary(current.get("cookbook_shadow", {})).duplicate(true),
		"crawl_network_state": Dictionary(current.get("crawl_network_state", {})).duplicate(true)
	}

static func top_bucket_entries(world_memory: Dictionary, bucket: String, limit: int = 4) -> Array[Dictionary]:
	var current := normalize(world_memory)
	var entries: Array[Dictionary] = []
	for myth_key in Dictionary(Dictionary(current.get("myths", {})).get(bucket, {})).keys():
		var entry: Dictionary = Dictionary(Dictionary(Dictionary(current.get("myths", {})).get(bucket, {})).get(myth_key, {})).duplicate(true)
		entry["id"] = str(myth_key)
		entries.append(entry)
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_gravity := int(a.get("gravity", 0))
		var b_gravity := int(b.get("gravity", 0))
		if a_gravity != b_gravity:
			return a_gravity > b_gravity
		var a_heat := int(a.get("heat", 0))
		var b_heat := int(b.get("heat", 0))
		if a_heat != b_heat:
			return a_heat > b_heat
		return str(a.get("label", "")) < str(b.get("label", ""))
	)
	return entries.slice(0, mini(entries.size(), limit))

static func top_fascination_topics(world_memory: Dictionary, limit: int = 4) -> Array[Dictionary]:
	var current := normalize(world_memory)
	var entries: Array[Dictionary] = []
	for topic_key in Dictionary(Dictionary(current.get("fascination", {})).get("topics", {})).keys():
		var entry: Dictionary = Dictionary(Dictionary(Dictionary(current.get("fascination", {})).get("topics", {})).get(topic_key, {})).duplicate(true)
		entry["id"] = str(topic_key)
		entries.append(entry)
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_heat := int(a.get("heat", 0))
		var b_heat := int(b.get("heat", 0))
		if a_heat != b_heat:
			return a_heat > b_heat
		return int(a.get("gravity", 0)) > int(b.get("gravity", 0))
	)
	return entries.slice(0, mini(entries.size(), limit))

static func _normalize_myth_entry(entry: Dictionary) -> Dictionary:
	var current := {
		"label": "",
		"heat": 0,
		"touches": 0,
		"status": "active",
		"last_seen_run": 0,
		"layers": [],
		"signals": [],
		"shorthand_ready": false,
		"phase": "emergence",
		"gravity": 0,
		"volatility": 0,
		"resonance_tags": [],
		"damping_tags": [],
		"shadow_tags": [],
		"successor_hint": "",
		"revivals": 0,
		"cool_streak": 0,
		"consolidation": 0,
		"pull": "watching"
	}
	for key in entry.keys():
		current[key] = entry[key]
	current["heat"] = int(current.get("heat", 0))
	current["touches"] = int(current.get("touches", 0))
	current["last_seen_run"] = int(current.get("last_seen_run", 0))
	current["layers"] = _dedupe_strings(current.get("layers", []))
	current["signals"] = _dedupe_strings(current.get("signals", []))
	current["shorthand_ready"] = bool(current.get("shorthand_ready", false))
	var heat := int(current.get("heat", 0))
	current["gravity"] = int(current.get("gravity", 0))
	current["volatility"] = int(current.get("volatility", 0))
	current["resonance_tags"] = _dedupe_strings(current.get("resonance_tags", []))
	current["damping_tags"] = _dedupe_strings(current.get("damping_tags", []))
	current["shadow_tags"] = _dedupe_strings(current.get("shadow_tags", []))
	current["revivals"] = int(current.get("revivals", 0))
	current["cool_streak"] = int(current.get("cool_streak", 0))
	current["consolidation"] = int(current.get("consolidation", 0))
	current["pull"] = str(current.get("pull", "watching"))
	if heat <= 0:
		current["status"] = "relic"
	elif heat <= 2 and str(current.get("status", "")) == "active":
		current["status"] = "residual"
	elif str(current.get("status", "")).is_empty():
		current["status"] = "active"
	current["phase"] = _myth_phase(heat, current["touches"], current["volatility"])
	return current

static func _cool_all(world_memory: Dictionary) -> void:
	var run_index := int(world_memory.get("run_index", 0))
	var myths: Dictionary = Dictionary(world_memory.get("myths", {}))
	for bucket in MYTH_BUCKETS:
		var bucket_dict: Dictionary = Dictionary(myths.get(bucket, {}))
		for myth_key in bucket_dict.keys():
			var entry: Dictionary = _normalize_myth_entry(Dictionary(bucket_dict.get(myth_key, {})))
			if int(entry.get("last_seen_run", 0)) >= run_index:
				entry["cool_streak"] = 0
				bucket_dict[myth_key] = entry
				continue
			entry["heat"] = maxi(int(entry.get("heat", 0)) - 1, -1)
			entry["gravity"] = maxi(int(entry.get("gravity", 0)) - 1, 0)
			entry["cool_streak"] = int(entry.get("cool_streak", 0)) + 1
			if int(entry.get("heat", 0)) <= 0:
				entry["status"] = "relic"
			elif int(entry.get("heat", 0)) <= 2:
				entry["status"] = "residual"
			if int(entry.get("cool_streak", 0)) >= 3:
				entry["damping_tags"] = _dedupe_strings(Array(entry.get("damping_tags", [])) + ["cooling out"])
				entry["pull"] = "cooling"
			entry["phase"] = _myth_phase(int(entry.get("heat", 0)), int(entry.get("touches", 0)), int(entry.get("volatility", 0)))
			bucket_dict[myth_key] = entry
		myths[bucket] = bucket_dict
	world_memory["myths"] = myths
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	var topics: Dictionary = Dictionary(fascination.get("topics", {}))
	for topic_key in topics.keys():
		var topic: Dictionary = Dictionary(topics.get(topic_key, {}))
		topic["heat"] = maxi(int(topic.get("heat", 0)) - 1, 0)
		topic["cool_streak"] = int(topic.get("cool_streak", 0)) + 1
		if int(topic.get("heat", 0)) <= 1:
			topic["phase"] = "cooling"
		topics[topic_key] = topic
	fascination["topics"] = topics
	world_memory["fascination"] = fascination

static func _build_touches(run_context: Dictionary) -> Array[Dictionary]:
	var touches: Array[Dictionary] = []
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var crawl_packet: Dictionary = Dictionary(run_context.get("crawl_packet", {}))
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var hidden_curriculum := _string_array(diagnostics.get("hidden_curriculum", []))
	var belief_state: Dictionary = Dictionary(diagnostics.get("belief_state", {}))
	var belief_lines := _dedupe_strings([
		str(belief_state.get("rescue_answer", "")),
		str(belief_state.get("fault_line", "")),
		str(belief_state.get("collapse_line", "")),
		str(belief_state.get("myth_attractor", "")),
		str(belief_state.get("attention_sink", ""))
	])
	var counterfactual := _string_array(diagnostics.get("counterfactual_pressure", []))
	var anomaly_signals := _string_array(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("signals", []))
	var build_identity := str(diagnostics.get("build_identity", "")).strip_edges()
	var build_scores: Dictionary = Dictionary(diagnostics.get("build_scores", {}))
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var gameplay_feature_signals := _string_array(diagnostics.get("gameplay_feature_signals", []))
	var gameplay_group_signals := _string_array(diagnostics.get("gameplay_group_signals", []))
	var model_pressure := _string_array(diagnostics.get("model_pressure", []))
	var group_fault_lines := _string_array(diagnostics.get("group_fault_lines", []))
	var gameplay_signals := _string_array(diagnostics.get("gameplay_behavior_signals", []))
	var synergy_labels := _string_array(diagnostics.get("synergy_labels", []))
	var resource_pressure := _string_array(diagnostics.get("resource_pressure", []))
	var inhabitant_pressure := _string_array(diagnostics.get("inhabitant_pressure", []))
	var protocol_hooks := _string_array(diagnostics.get("protocol_hooks", []))
	var ritual_hooks := _string_array(diagnostics.get("ritual_hooks", []))
	var artifact_lineage_hints := _string_array(diagnostics.get("artifact_lineage_hints", []))
	var artifact_branch_markers := _string_array(diagnostics.get("artifact_branch_markers", []))
	var artifact_memory_hints := _string_array(diagnostics.get("artifact_memory_hints", []))
	var artifact_prestige_indicators := _string_array(diagnostics.get("artifact_prestige_indicators", []))
	var artifact_cultural_association := str(diagnostics.get("artifact_cultural_association", "")).strip_edges()
	var branch_caution_markers := _string_array(diagnostics.get("branch_caution_markers", []))
	var branch_reputation_drift := str(diagnostics.get("branch_reputation_drift", "")).strip_edges()
	var doctrine_family := str(diagnostics.get("doctrine_family", "")).strip_edges()
	var doctrine_label := str(diagnostics.get("doctrine_label", "")).strip_edges()
	var doctrine_pressure_line := str(diagnostics.get("doctrine_pressure_line", "")).strip_edges()
	var doctrine_world_goal := str(diagnostics.get("doctrine_world_goal", "")).strip_edges()
	for room_family in Array(run_record.get("room_families", [])):
		touches.append(_touch_payload("branch", "branch:%s" % str(room_family), _title_case(str(room_family)), [
			str(diagnostics.get("atmosphere", "")).replace("_", " "),
			str(diagnostics.get("social_temperature", "")).replace("_", " "),
			protocol_state,
			_first_string(model_pressure, ""),
			doctrine_label
		]))
	var branch_summary: Dictionary = Dictionary(diagnostics.get("branch_summary", {}))
	if not branch_summary.is_empty():
		var branch_id := str(branch_summary.get("branch_family_id", "branch:unknown"))
		touches.append(_touch_payload("branch", "branch:%s" % branch_id, str(branch_summary.get("branch_family_name", branch_id)), [
			str(branch_summary.get("challenge_texture", "")),
			str(branch_summary.get("confrontation_climate", "")),
			str(branch_summary.get("rescue_climate", "")),
			str(branch_summary.get("burden_pressure", "")),
			str(branch_summary.get("witness_pressure", "")),
			_first_string(hidden_curriculum, ""),
			_first_string(counterfactual, ""),
			_first_string(protocol_hooks, ""),
			_first_string(resource_pressure, ""),
			_first_string(group_fault_lines, ""),
			_first_string(branch_caution_markers, ""),
			branch_reputation_drift,
			doctrine_label,
			doctrine_pressure_line
		]))
	for item_id in Array(run_record.get("item_defs", [])):
		touches.append(_touch_payload("item", "item:%s" % str(item_id), _title_case(str(item_id).replace("_", " ")), Array(diagnostics.get("item_story_roles", [])) + artifact_lineage_hints + artifact_branch_markers + artifact_memory_hints + artifact_prestige_indicators + ([artifact_cultural_association] if not artifact_cultural_association.is_empty() else []) + hidden_curriculum + anomaly_signals + synergy_labels + resource_pressure + model_pressure + gameplay_feature_signals + ([build_stability] if not build_stability.is_empty() else []) + ([risk_profile] if not risk_profile.is_empty() else []) + ([doctrine_label] if not doctrine_label.is_empty() else [])))
	for place_label in Array(diagnostics.get("load_bearing_places", [])):
		touches.append(_touch_payload("place", "place:%s" % str(place_label), str(place_label), Array(diagnostics.get("room_identity_highlights", [])) + counterfactual + inhabitant_pressure + group_fault_lines + model_pressure + ([doctrine_pressure_line] if not doctrine_pressure_line.is_empty() else [])))
	for object_label in Array(diagnostics.get("load_bearing_objects", [])):
		touches.append(_touch_payload("object", "object:%s" % str(object_label), str(object_label), Array(diagnostics.get("symbolic_gestures", [])) + Array(diagnostics.get("item_story_roles", [])) + hidden_curriculum + synergy_labels + ritual_hooks + model_pressure + gameplay_feature_signals + ([doctrine_world_goal] if not doctrine_world_goal.is_empty() else [])))
	for pair_key in Array(diagnostics.get("pair_keys", [])):
		touches.append(_touch_payload("pair", str(pair_key), _pair_label(str(pair_key)), Array(diagnostics.get("social_beats_top", [])) + Array(diagnostics.get("pressure_persistence", [])) + Array(Dictionary(run_context.get("frame", {})).get("counter_readings", [])) + belief_lines + gameplay_signals + gameplay_group_signals + inhabitant_pressure + model_pressure + group_fault_lines + ([doctrine_pressure_line] if not doctrine_pressure_line.is_empty() else [])))
	var peer_identities: Dictionary = Dictionary(run_record.get("peer_identities", {}))
	for peer_key in peer_identities.keys():
		var card: Dictionary = Dictionary(peer_identities.get(peer_key, {}))
		var public_id := str(card.get("public_id", "")).strip_edges()
		if public_id.is_empty():
			continue
		touches.append(_touch_payload("player", "player:%s" % public_id, str(card.get("display_name", public_id)), Array(frame.get("story_axes", [])) + Array(diagnostics.get("quest_pressure", [])) + Array(frame.get("counter_readings", [])) + belief_lines + counterfactual + gameplay_signals + gameplay_group_signals + resource_pressure + inhabitant_pressure + model_pressure + group_fault_lines + ([build_identity] if not build_identity.is_empty() else []) + ([build_stability] if not build_stability.is_empty() else []) + ([risk_profile] if not risk_profile.is_empty() else []) + ([doctrine_label] if not doctrine_label.is_empty() else [])))
	var crew_shape := str(diagnostics.get("group_shape_drift", "")).strip_edges()
	if not crew_shape.is_empty():
		touches.append(_touch_payload("crew", "crew:%s" % crew_shape, _title_case(crew_shape.replace("_", " ")), Array(diagnostics.get("crew_hooks", [])) + Array(frame.get("quest_briefs", [])) + hidden_curriculum + gameplay_signals + gameplay_group_signals + resource_pressure + model_pressure + group_fault_lines + ([build_identity] if not build_identity.is_empty() else []) + ([build_stability] if not build_stability.is_empty() else []) + ([doctrine_label] if not doctrine_label.is_empty() else [])))
	var crawl_id := str(crawl_packet.get("crawl_id", "")).strip_edges()
	if not crawl_id.is_empty():
		touches.append(_touch_payload("crawl", crawl_id, str(crawl_packet.get("title", "Active crawl")), Array(crawl_packet.get("signature_tags", [])) + Array(crawl_packet.get("residue", [])) + Array(crawl_packet.get("breaking_points", [])) + artifact_lineage_hints + artifact_memory_hints + ([artifact_cultural_association] if not artifact_cultural_association.is_empty() else []) + ([branch_reputation_drift] if not branch_reputation_drift.is_empty() else []) + belief_lines + hidden_curriculum + anomaly_signals + resource_pressure + inhabitant_pressure + protocol_hooks + model_pressure + group_fault_lines + ([build_identity] if not build_identity.is_empty() else []) + ([build_stability] if not build_stability.is_empty() else []) + ([doctrine_label] if not doctrine_label.is_empty() else []) + ([doctrine_world_goal] if not doctrine_world_goal.is_empty() else [])))
	var run_shape := str(_first_string(Array(diagnostics.get("run_shapes", [])), "")).strip_edges()
	if not run_shape.is_empty():
		var build_pull := _build_pull_text(build_identity, build_scores)
		touches.append(_touch_payload("run_shape", "shape:%s" % run_shape, run_shape, Array(frame.get("narrative_hooks", [])) + Array(frame.get("interpretation_split", [])) + counterfactual + resource_pressure + inhabitant_pressure + model_pressure + group_fault_lines + ([build_pull] if not build_pull.is_empty() else []) + ([doctrine_pressure_line] if not doctrine_pressure_line.is_empty() else [])))
	return touches

static func _touch_payload(bucket: String, key: String, label: String, signals: Array) -> Dictionary:
	return {
		"bucket": bucket,
		"key": key,
		"label": label,
		"signals": _dedupe_strings(signals)
	}

static func _touch_entry(world_memory: Dictionary, payload: Dictionary) -> void:
	var bucket := str(payload.get("bucket", ""))
	if not MYTH_BUCKETS.has(bucket):
		return
	var myths: Dictionary = Dictionary(world_memory.get("myths", {}))
	var bucket_dict: Dictionary = Dictionary(myths.get(bucket, {}))
	var myth_key := str(payload.get("key", ""))
	var entry: Dictionary = _normalize_myth_entry(Dictionary(bucket_dict.get(myth_key, {})))
	var previous_status := str(entry.get("status", ""))
	entry["label"] = str(payload.get("label", entry.get("label", myth_key)))
	entry["heat"] = mini(int(entry.get("heat", 0)) + 2, 12)
	entry["touches"] = int(entry.get("touches", 0)) + 1
	entry["last_seen_run"] = int(world_memory.get("run_index", 0))
	entry["status"] = "active"
	var layers := _dedupe_strings(Array(entry.get("layers", [])) + Array(payload.get("signals", [])))
	entry["layers"] = layers.slice(0, mini(layers.size(), 6))
	entry["signals"] = entry["layers"]
	entry["shorthand_ready"] = int(entry.get("heat", 0)) >= 5 and entry["touches"] >= 2
	entry["gravity"] = mini(int(entry.get("gravity", 0)) + (2 if entry["shorthand_ready"] else 1), 12)
	entry["volatility"] = mini(int(entry.get("volatility", 0)) + (1 if layers.size() >= 3 else 0), 8)
	entry["consolidation"] = mini(int(entry.get("consolidation", 0)) + (1 if entry["touches"] >= 2 else 0), 12)
	entry["cool_streak"] = 0
	if previous_status in ["residual", "relic"]:
		entry["revivals"] = int(entry.get("revivals", 0)) + 1
	entry["pull"] = "pressing" if entry["shorthand_ready"] else "watching" if int(entry.get("heat", 0)) >= 3 else "fading"
	entry["phase"] = _myth_phase(int(entry.get("heat", 0)), int(entry.get("touches", 0)), int(entry.get("volatility", 0)))
	bucket_dict[myth_key] = entry
	myths[bucket] = bucket_dict
	world_memory["myths"] = myths

static func _trim_buckets(world_memory: Dictionary) -> void:
	var myths: Dictionary = Dictionary(world_memory.get("myths", {}))
	for bucket in MYTH_BUCKETS:
		var bucket_dict: Dictionary = Dictionary(myths.get(bucket, {}))
		if bucket_dict.size() <= BUCKET_LIMIT:
			continue
		var keys: Array[String] = []
		for myth_key in bucket_dict.keys():
			keys.append(str(myth_key))
		keys.sort_custom(func(a: String, b: String) -> bool:
			var entry_a: Dictionary = Dictionary(bucket_dict.get(a, {}))
			var entry_b: Dictionary = Dictionary(bucket_dict.get(b, {}))
			var heat_a := int(entry_a.get("heat", 0))
			var heat_b := int(entry_b.get("heat", 0))
			if heat_a != heat_b:
				return heat_a > heat_b
			return int(entry_a.get("touches", 0)) > int(entry_b.get("touches", 0))
		)
		var trimmed := {}
		for myth_key in keys.slice(0, BUCKET_LIMIT):
			trimmed[myth_key] = bucket_dict.get(myth_key, {})
		myths[bucket] = trimmed
	world_memory["myths"] = myths

static func _update_fascination(world_memory: Dictionary, touches: Array[Dictionary], run_context: Dictionary) -> void:
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	var topics: Dictionary = Dictionary(fascination.get("topics", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var field_view := field_snapshot(world_memory)
	var collisions := _string_array(Dictionary(field_view.get("myth_collision", {})).get("lines", []))
	var resurgence := _string_array(Dictionary(field_view.get("myth_resurgence", {})).get("lines", []))
	var top_successor := Dictionary(Dictionary(field_view.get("myth_field", {})).get("top_successor", {}))
	for touch in touches:
		var label := str(Dictionary(touch).get("label", "")).strip_edges()
		if label.is_empty():
			continue
		var topic: Dictionary = Dictionary(topics.get(label, {"label": label, "heat": 0, "phase": "forming", "pull": "watching", "cool_streak": 0, "gravity": 0}))
		topic["label"] = label
		topic["heat"] = mini(int(topic.get("heat", 0)) + 1, 10)
		topic["gravity"] = mini(int(topic.get("gravity", 0)) + 1, 12)
		topic["cool_streak"] = 0
		topic["phase"] = "saturated" if int(topic.get("heat", 0)) >= 8 else "active" if int(topic.get("heat", 0)) >= 4 else "forming"
		topic["pull"] = "watching" if int(topic.get("heat", 0)) < 4 else "circling"
		topics[label] = topic
	for hook in Array(diagnostics.get("quest_pressure", [])):
		var label := str(hook).strip_edges()
		if label.is_empty():
			continue
		var topic: Dictionary = Dictionary(topics.get(label, {"label": label, "heat": 0, "phase": "forming", "pull": "watching", "cool_streak": 0, "gravity": 0}))
		topic["label"] = label
		topic["heat"] = mini(int(topic.get("heat", 0)) + 2, 10)
		topic["gravity"] = mini(int(topic.get("gravity", 0)) + 2, 12)
		topic["cool_streak"] = 0
		topic["phase"] = "saturated" if int(topic.get("heat", 0)) >= 8 else "active" if int(topic.get("heat", 0)) >= 4 else "forming"
		topic["pull"] = "pressing" if int(topic.get("heat", 0)) >= 5 else "circling"
		topics[label] = topic
	for hook in _string_array(diagnostics.get("model_pressure", [])) + _string_array(diagnostics.get("group_fault_lines", [])):
		var model_label := str(hook).strip_edges()
		if model_label.is_empty():
			continue
		var model_topic: Dictionary = Dictionary(topics.get(model_label, {"label": model_label, "heat": 0, "phase": "forming", "pull": "watching", "cool_streak": 0, "gravity": 0}))
		model_topic["label"] = model_label
		model_topic["heat"] = mini(int(model_topic.get("heat", 0)) + 1, 10)
		model_topic["gravity"] = mini(int(model_topic.get("gravity", 0)) + 1, 12)
		model_topic["cool_streak"] = 0
		model_topic["phase"] = "active" if int(model_topic.get("heat", 0)) >= 4 else "forming"
		model_topic["pull"] = "circling"
		topics[model_label] = model_topic
	fascination["topics"] = topics
	world_memory["fascination"] = fascination
	var top := top_fascination_topics(world_memory, 1)
	var previous_focus := str(fascination.get("current_focus", "")).strip_edges()
	if top.is_empty():
		fascination["current_focus"] = ""
		fascination["current_heat"] = 0
		fascination["phase"] = "roaming"
		fascination["pressure"] = ""
		fascination["cool_streak"] = int(fascination.get("cool_streak", 0)) + 1
		fascination["streak"] = 0
	else:
		var current_focus := str(Dictionary(top[0]).get("label", Dictionary(top[0]).get("id", "")))
		fascination["current_focus"] = current_focus
		fascination["current_heat"] = int(Dictionary(top[0]).get("heat", 0))
		var streak := int(fascination.get("streak", 0)) + 1 if current_focus == previous_focus and not current_focus.is_empty() else 1
		fascination["streak"] = streak
		fascination["focus_history"] = _push_front_unique(Array(fascination.get("focus_history", [])), current_focus, 6)
		var fatigue := int(fascination.get("fatigue", 0))
		if streak >= 3 and fascination["current_heat"] <= 7:
			fatigue = mini(fatigue + 1, 6)
		elif current_focus != previous_focus:
			fatigue = maxi(fatigue - 1, 0)
		fascination["fatigue"] = fatigue
		if fatigue >= 3 and fascination["current_heat"] < 8:
			fascination["phase"] = "fatigued"
		elif not previous_focus.is_empty() and current_focus != previous_focus and int(Dictionary(top[0]).get("gravity", 0)) >= 6:
			fascination["phase"] = "turning"
		else:
			fascination["phase"] = "saturated" if fascination["current_heat"] >= 8 else "active" if fascination["current_heat"] >= 4 else "forming"
		fascination["pressure"] = _first_string(
			_string_array([frame.get("challenge_attention", "")])
			+ _string_array([frame.get("world_pull", "")])
			+ _string_array(frame.get("counter_readings", []))
			+ _string_array(diagnostics.get("quest_pressure", [])),
			""
		)
		if streak >= 4 and fascination["current_heat"] >= 6:
			fascination["pressure"] = "The culture is waiting for this pressure to answer itself."
		elif fascination["phase"] == "turning" and not current_focus.is_empty():
			fascination["pressure"] = "%s is displacing the older focus." % current_focus
		elif fascination["phase"] == "fatigued" and not current_focus.is_empty():
			fascination["pressure"] = "%s is still watched, but the old heat is wearing thin." % current_focus
		elif not collisions.is_empty():
			fascination["pressure"] = collisions[0]
		elif not str(top_successor.get("hint", "")).strip_edges().is_empty():
			fascination["pressure"] = "%s keeps inviting a recast toward %s." % [current_focus, str(top_successor.get("hint", "")).to_lower()]
		elif not resurgence.is_empty():
			fascination["pressure"] = resurgence[0]
		fascination["cool_streak"] = 0
	world_memory["fascination"] = fascination

static func _update_institutional_order(world_memory: Dictionary, run_context: Dictionary) -> void:
	var institutional_order := _normalize_institutional_order(Dictionary(world_memory.get("institutional_order", {})))
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	var continuity_state := str(outcome_summary.get("artifact_continuity_state", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	var school_reads := _string_array(frame.get("school_reads", []))
	var school_tension := str(frame.get("school_tension", "")).strip_edges()
	var counter_readings := _string_array(frame.get("counter_readings", []))
	var hidden_curriculum := _string_array(diagnostics.get("hidden_curriculum", []))
	match continuity_state:
		"recoverable_loss":
			institutional_order["custody_pressure"] = mini(int(institutional_order.get("custody_pressure", 0)) + 1, 12)
			institutional_order["claim_lines"] = _merge_limited(Array(institutional_order.get("claim_lines", [])), ["artifact custody is starting to carry legitimacy debt"], 6)
		"burial":
			institutional_order["custody_pressure"] = mini(int(institutional_order.get("custody_pressure", 0)) + 1, 12)
			institutional_order["burial_pressure"] = mini(int(institutional_order.get("burial_pressure", 0)) + 2, 12)
			institutional_order["legitimacy_pressure"] = mini(int(institutional_order.get("legitimacy_pressure", 0)) + 1, 12)
			institutional_order["claim_lines"] = _merge_limited(Array(institutional_order.get("claim_lines", [])), ["burial rights are forming around buried lines"], 6)
			institutional_order["taboo_lines"] = _merge_limited(Array(institutional_order.get("taboo_lines", [])), ["burial violations would now read as public breach"], 6)
		"fragmented_legacy":
			institutional_order["legitimacy_pressure"] = mini(int(institutional_order.get("legitimacy_pressure", 0)) + 1, 12)
			institutional_order["heresy_pressure"] = mini(int(institutional_order.get("heresy_pressure", 0)) + 1, 12)
			institutional_order["claim_lines"] = _merge_limited(Array(institutional_order.get("claim_lines", [])), ["split artifact claims are forcing adjudication"], 6)
		"successor_emergence":
			institutional_order["legitimacy_pressure"] = mini(int(institutional_order.get("legitimacy_pressure", 0)) + 1, 12)
			institutional_order["heresy_pressure"] = mini(int(institutional_order.get("heresy_pressure", 0)) + 2, 12)
			institutional_order["claim_lines"] = _merge_limited(Array(institutional_order.get("claim_lines", [])), ["successor claims are starting to outrun settled custody"], 6)
		"archive_only_residue":
			institutional_order["taboo_heat"] = mini(int(institutional_order.get("taboo_heat", 0)) + 1, 12)
			institutional_order["claim_lines"] = _merge_limited(Array(institutional_order.get("claim_lines", [])), ["only archive residue remains to argue over"], 6)
		"extinction":
			institutional_order["taboo_heat"] = mini(int(institutional_order.get("taboo_heat", 0)) + 2, 12)
			institutional_order["taboo_lines"] = _merge_limited(Array(institutional_order.get("taboo_lines", [])), ["extinct lines now carry taboo weight"], 6)
	if not governance_line.is_empty():
		institutional_order["legitimacy_pressure"] = mini(int(institutional_order.get("legitimacy_pressure", 0)) + 1, 12)
		institutional_order["lines"] = _merge_limited(Array(institutional_order.get("lines", [])), [governance_line], 6)
	if school_reads.size() >= 2 and not school_tension.is_empty():
		institutional_order["legitimacy_pressure"] = mini(int(institutional_order.get("legitimacy_pressure", 0)) + 1, 12)
		institutional_order["heresy_pressure"] = mini(int(institutional_order.get("heresy_pressure", 0)) + 1, 12)
		institutional_order["lines"] = _merge_limited(Array(institutional_order.get("lines", [])), ["competing schools are hardening into legitimacy claims"], 6)
	if counter_readings.size() >= 2 and not belief_line.is_empty():
		institutional_order["taboo_heat"] = mini(int(institutional_order.get("taboo_heat", 0)) + 1, 12)
		institutional_order["heresy_pressure"] = mini(int(institutional_order.get("heresy_pressure", 0)) + 1, 12)
		institutional_order["lines"] = _merge_limited(Array(institutional_order.get("lines", [])), ["counter-read pressure is starting to condemn once-safe explanations"], 6)
	if hidden_curriculum.size() >= 2:
		institutional_order["taboo_heat"] = mini(int(institutional_order.get("taboo_heat", 0)) + 1, 12)
	world_memory["institutional_order"] = institutional_order

static func _update_epistemic_order(world_memory: Dictionary, run_context: Dictionary) -> void:
	var epistemic_order := _normalize_epistemic_order(Dictionary(world_memory.get("epistemic_order", {})))
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	var continuity_state := str(outcome_summary.get("artifact_continuity_state", "")).strip_edges()
	var counterfeit_count := int(outcome_summary.get("counterfeit_count", 0))
	var unresolved_counterfeit := int(outcome_summary.get("artifact_unresolved_counterfeit_count", 0))
	var commentary_lanes := _string_array(frame.get("commentary_lanes", []))
	var counter_readings := _string_array(frame.get("counter_readings", []))
	var school_tension := str(frame.get("school_tension", "")).strip_edges()
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	var counterfactual_pressure := _string_array(diagnostics.get("counterfactual_pressure", []))
	var prestige_indicators := _string_array(diagnostics.get("artifact_prestige_indicators", []))
	var previous_tradition := str(epistemic_order.get("dominant_tradition", "")).strip_edges()
	var dominant_tradition := _dominant_epistemic_tradition(commentary_lanes, diagnostics, frame, continuity_state)
	if not dominant_tradition.is_empty():
		if not previous_tradition.is_empty() and previous_tradition != dominant_tradition:
			epistemic_order["revision_pressure"] = mini(int(epistemic_order.get("revision_pressure", 0)) + 1, 12)
			epistemic_order["semantic_drift"] = mini(int(epistemic_order.get("semantic_drift", 0)) + 1, 12)
			epistemic_order["drift_lines"] = _merge_limited(
				Array(epistemic_order.get("drift_lines", [])),
				["terms once settled by %s are now being re-read through %s" % [previous_tradition.to_lower(), dominant_tradition.to_lower()]],
				6
			)
		else:
			epistemic_order["orthodoxy_strength"] = mini(int(epistemic_order.get("orthodoxy_strength", 0)) + 1, 12)
		epistemic_order["dominant_tradition"] = dominant_tradition
	if counterfeit_count + unresolved_counterfeit > 0:
		epistemic_order["false_canon_pressure"] = mini(int(epistemic_order.get("false_canon_pressure", 0)) + 2, 12)
		epistemic_order["forgery_pressure"] = mini(int(epistemic_order.get("forgery_pressure", 0)) + counterfeit_count + unresolved_counterfeit, 12)
		epistemic_order["lines"] = _merge_limited(Array(epistemic_order.get("lines", [])), ["counterfeit provenance is starting to harden into public memory"], 6)
		epistemic_order["forgery_lines"] = _merge_limited(Array(epistemic_order.get("forgery_lines", [])), ["provenance claims no longer agree on what counts as authentic"], 6)
	if continuity_state == "successor_emergence" or prestige_indicators.has("false succession pressure"):
		epistemic_order["false_canon_pressure"] = mini(int(epistemic_order.get("false_canon_pressure", 0)) + 1, 12)
		epistemic_order["revision_pressure"] = mini(int(epistemic_order.get("revision_pressure", 0)) + 1, 12)
		epistemic_order["lines"] = _merge_limited(Array(epistemic_order.get("lines", [])), ["successor claims are beginning to rewrite the accepted line"], 6)
	if counter_readings.size() >= 2 and not school_tension.is_empty():
		epistemic_order["false_canon_pressure"] = mini(int(epistemic_order.get("false_canon_pressure", 0)) + 1, 12)
		epistemic_order["revision_pressure"] = mini(int(epistemic_order.get("revision_pressure", 0)) + 1, 12)
		epistemic_order["lines"] = _merge_limited(Array(epistemic_order.get("lines", [])), ["the accepted reading is losing its uncontested hold"], 6)
	if not belief_line.is_empty() and (not counterfactual_line.is_empty() or not counterfactual_pressure.is_empty()):
		epistemic_order["semantic_drift"] = mini(int(epistemic_order.get("semantic_drift", 0)) + 1, 12)
		epistemic_order["drift_lines"] = _merge_limited(Array(epistemic_order.get("drift_lines", [])), ["older terms are being judged against newer almost-answers"], 6)
	world_memory["epistemic_order"] = epistemic_order

static func _update_affective_climate(world_memory: Dictionary, run_context: Dictionary) -> void:
	var affective_climate := _normalize_affective_climate(Dictionary(world_memory.get("affective_climate", {})))
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	var continuity_state := str(outcome_summary.get("artifact_continuity_state", "")).strip_edges()
	var status_valence := str(frame.get("status_valence", "")).strip_edges()
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	var recovery_score := int(diagnostics.get("recovery_score", 0))
	var spectacle_pressure := int(diagnostics.get("spectacle_pressure", 0))
	var near_miss_score := int(diagnostics.get("near_miss_score", 0))
	var interrupted := bool(run_record.get("interrupted", false))
	if interrupted or near_miss_score >= 2:
		affective_climate["melancholy_heat"] = mini(int(affective_climate.get("melancholy_heat", 0)) + 1, 12)
		affective_climate["mourning_lines"] = _merge_limited(Array(affective_climate.get("mourning_lines", [])), ["unfinished crews are leaving a civic ache behind them"], 6)
	if continuity_state == "extinction":
		affective_climate["melancholy_heat"] = mini(int(affective_climate.get("melancholy_heat", 0)) + 2, 12)
		affective_climate["mourning_lines"] = _merge_limited(Array(affective_climate.get("mourning_lines", [])), ["extinct artifact lines are now being mourned in public memory"], 6)
	elif continuity_state == "burial":
		affective_climate["reverence_heat"] = mini(int(affective_climate.get("reverence_heat", 0)) + 1, 12)
		affective_climate["mourning_lines"] = _merge_limited(Array(affective_climate.get("mourning_lines", [])), ["burial practice is teaching the world how to grieve without closure"], 6)
	if status_valence in ["Scandal", "Infamy", "Disgrace"] or spectacle_pressure >= 3:
		affective_climate["paranoia_heat"] = mini(int(affective_climate.get("paranoia_heat", 0)) + 1, 12)
		affective_climate["punitive_heat"] = mini(int(affective_climate.get("punitive_heat", 0)) + 1, 12)
		affective_climate["lines"] = _merge_limited(Array(affective_climate.get("lines", [])), ["public scandal is pushing the world toward punitive readings"], 6)
	if recovery_score >= 3:
		affective_climate["hope_heat"] = mini(int(affective_climate.get("hope_heat", 0)) + 1, 12)
		affective_climate["reverence_heat"] = mini(int(affective_climate.get("reverence_heat", 0)) + 1, 12)
		affective_climate["lines"] = _merge_limited(Array(affective_climate.get("lines", [])), ["successful rescues are supporting a hopeful restoration mood"], 6)
	if not belief_line.is_empty() and not counterfactual_line.is_empty():
		affective_climate["melancholy_heat"] = mini(int(affective_climate.get("melancholy_heat", 0)) + 1, 12)
		affective_climate["mourning_lines"] = _merge_limited(Array(affective_climate.get("mourning_lines", [])), ["disproven sacred histories are leaving grief behind them"], 6)
	if interrupted and recovery_score >= 2 and spectacle_pressure >= 2:
		affective_climate["martyr_pressure"] = mini(int(affective_climate.get("martyr_pressure", 0)) + 1, 12)
		affective_climate["lines"] = _merge_limited(Array(affective_climate.get("lines", [])), ["sacrifice stories are starting to overpower practical memory"], 6)
	if recovery_score >= 2 and spectacle_pressure <= 1:
		affective_climate["ordinary_life_pressure"] = mini(int(affective_climate.get("ordinary_life_pressure", 0)) + 2, 12)
		affective_climate["labor_lines"] = _merge_limited(Array(affective_climate.get("labor_lines", [])), ["ordinary rescue work is carrying more legitimacy than spectacle"], 6)
	if int(affective_climate.get("ordinary_life_pressure", 0)) >= 2 and int(affective_climate.get("martyr_pressure", 0)) >= 1:
		affective_climate["anti_martyr_pressure"] = mini(int(affective_climate.get("anti_martyr_pressure", 0)) + 1, 12)
		affective_climate["labor_lines"] = _merge_limited(Array(affective_climate.get("labor_lines", [])), ["ordinary labor is being invoked against spectacle martyr stories"], 6)
	affective_climate["dominant_age"] = _dominant_affective_age(affective_climate, int(Dictionary(world_memory.get("fascination", {})).get("fatigue", 0)))
	world_memory["affective_climate"] = affective_climate

static func _update_ontology_state(world_memory: Dictionary, run_context: Dictionary) -> void:
	var ontology_state := _normalize_ontology_state(Dictionary(world_memory.get("ontology_state", {})))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var commentary_lanes := _string_array(frame.get("commentary_lanes", []))
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	var counterfactual_pressure := _string_array(diagnostics.get("counterfactual_pressure", []))
	var dominant_ontology := _dominant_ontology(commentary_lanes, diagnostics, frame)
	var uncertainty_philosophy := _uncertainty_philosophy(commentary_lanes, diagnostics, frame)
	if not dominant_ontology.is_empty():
		ontology_state["dominant_ontology"] = dominant_ontology
		ontology_state["lines"] = _merge_limited(Array(ontology_state.get("lines", [])), ["the world is increasingly being read as %s" % dominant_ontology.to_lower()], 6)
	if not uncertainty_philosophy.is_empty():
		ontology_state["uncertainty_philosophy"] = uncertainty_philosophy
		ontology_state["uncertainty_lines"] = _merge_limited(Array(ontology_state.get("uncertainty_lines", [])), ["uncertainty is being treated as %s" % uncertainty_philosophy.to_lower()], 6)
	if not counterfactual_line.is_empty() or not counterfactual_pressure.is_empty():
		ontology_state["counterfactual_heat"] = mini(int(ontology_state.get("counterfactual_heat", 0)) + 1, 12)
		ontology_state["echo_lines"] = _merge_limited(
			Array(ontology_state.get("echo_lines", [])),
			[_first_string(counterfactual_pressure, counterfactual_line if not counterfactual_line.is_empty() else "unchosen futures are starting to leave residue")],
			6
		)
	world_memory["ontology_state"] = ontology_state

static func _update_delve_history(world_memory: Dictionary, run_context: Dictionary) -> void:
	var delve_history := _normalize_delve_history(Dictionary(world_memory.get("delve_history", {})))
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var constitution_summary: Dictionary = Dictionary(run_record.get("expedition_constitution_summary", run_record.get("delve_directive_summary", {})))
	var doctrine_family := str(diagnostics.get("doctrine_family", constitution_summary.get("doctrine_family", ""))).strip_edges()
	if doctrine_family.is_empty():
		world_memory["delve_history"] = delve_history
		return
	var method_counts: Dictionary = Dictionary(delve_history.get("method_counts", {}))
	var previous_dominant := str(delve_history.get("dominant_method", "")).strip_edges()
	method_counts[doctrine_family] = int(method_counts.get(doctrine_family, 0)) + 1
	var dominant_method := doctrine_family
	var dominant_weight := int(method_counts.get(doctrine_family, 0))
	for key in method_counts.keys():
		var weight := int(method_counts.get(key, 0))
		if weight > dominant_weight or (weight == dominant_weight and str(key) < dominant_method):
			dominant_method = str(key)
			dominant_weight = weight
	delve_history["method_counts"] = method_counts
	delve_history["dominant_method"] = dominant_method
	if dominant_weight >= 3:
		delve_history["lines"] = _merge_limited(Array(delve_history.get("lines", [])), ["%s is hardening into a methodological school" % doctrine_family.replace("_", " ")], 6)
	var counterfactual_pressure := _string_array(diagnostics.get("counterfactual_pressure", []))
	if (bool(run_record.get("interrupted", false)) or not counterfactual_pressure.is_empty() or int(diagnostics.get("expectation_break_score", 0)) >= 2) and dominant_method == doctrine_family:
		delve_history["misclassification_pressure"] = mini(int(delve_history.get("misclassification_pressure", 0)) + 1, 12)
		delve_history["lines"] = _merge_limited(Array(delve_history.get("lines", [])), ["%s is starting to misread live expedition behavior" % doctrine_family.replace("_", " ")], 6)
	if not previous_dominant.is_empty() and dominant_method != previous_dominant and int(method_counts.get(previous_dominant, 0)) >= 2:
		delve_history["abandoned_paradigms"] = _merge_limited(Array(delve_history.get("abandoned_paradigms", [])), [previous_dominant], 6)
		if int(delve_history.get("misclassification_pressure", 0)) >= 1:
			delve_history["overcorrection_pressure"] = mini(int(delve_history.get("overcorrection_pressure", 0)) + 1, 12)
		delve_history["history_lines"] = _merge_limited(Array(delve_history.get("history_lines", [])), ["DelveMind is leaving behind %s after over-reading it" % previous_dominant.replace("_", " ")], 6)
	if int(delve_history.get("overcorrection_pressure", 0)) >= 1:
		delve_history["history_lines"] = _merge_limited(Array(delve_history.get("history_lines", [])), ["course corrections are becoming visible in DelveMind's own history"], 6)
	world_memory["delve_history"] = delve_history

static func _update_interpretation_network(world_memory: Dictionary, run_context: Dictionary) -> void:
	var interpretation_network := _normalize_interpretation_network(Dictionary(world_memory.get("interpretation_network", {})))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var commentary_lanes := _string_array(frame.get("commentary_lanes", []))
	var school_reads := _string_array(frame.get("school_reads", []))
	var counter_readings := _string_array(frame.get("counter_readings", []))
	var school_tension := str(frame.get("school_tension", "")).strip_edges()
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var ritual_recurrence := _string_array(diagnostics.get("ritual_recurrence", []))
	var places := _string_array(diagnostics.get("load_bearing_places", []))
	var nodes := _string_array(school_reads + commentary_lanes + counter_readings)
	if not nodes.is_empty():
		interpretation_network["node_heat"] = mini(int(interpretation_network.get("node_heat", 0)) + mini(nodes.size(), 3), 12)
		interpretation_network["dominant_nodes"] = _merge_limited(Array(interpretation_network.get("dominant_nodes", [])), nodes, 6)
	if school_reads.size() >= 2 or commentary_lanes.size() >= 2:
		interpretation_network["spread_heat"] = mini(int(interpretation_network.get("spread_heat", 0)) + 1, 12)
		interpretation_network["lines"] = _merge_limited(Array(interpretation_network.get("lines", [])), ["rival schools are now spreading their own account of the same events"], 6)
	if counter_readings.size() >= 2 or not school_tension.is_empty():
		interpretation_network["contradiction_heat"] = mini(int(interpretation_network.get("contradiction_heat", 0)) + 2, 12)
		interpretation_network["lines"] = _merge_limited(Array(interpretation_network.get("lines", [])), ["the accepted story now travels with visible contradiction attached to it"], 6)
	if not ritual_pressure.is_empty() or not ritual_recurrence.is_empty():
		interpretation_network["ritual_spread"] = mini(int(interpretation_network.get("ritual_spread", 0)) + 1, 12)
		interpretation_network["spread_lines"] = _merge_limited(
			Array(interpretation_network.get("spread_lines", [])),
			[_first_string(ritual_recurrence, ritual_pressure if not ritual_pressure.is_empty() else "ritual retellings are now carrying the strongest interpretation pressure")],
			6
		)
	if not governance_line.is_empty():
		interpretation_network["institutional_campaigns"] = mini(int(interpretation_network.get("institutional_campaigns", 0)) + 1, 12)
		interpretation_network["campaign_lines"] = _merge_limited(Array(interpretation_network.get("campaign_lines", [])), ["institutional language is starting to campaign for a preferred explanation"], 6)
	if not belief_line.is_empty() and not nodes.is_empty():
		interpretation_network["spread_heat"] = mini(int(interpretation_network.get("spread_heat", 0)) + 1, 12)
		interpretation_network["lines"] = _merge_limited(Array(interpretation_network.get("lines", [])), ["belief lines are now moving through the world as shared reading habits"], 6)
	if not places.is_empty() and int(interpretation_network.get("ritual_spread", 0)) >= 1:
		interpretation_network["spread_lines"] = _merge_limited(Array(interpretation_network.get("spread_lines", [])), ["%s is now being named through ritual rather than neutral report" % places[0].to_lower()], 6)
	world_memory["interpretation_network"] = interpretation_network

static func _update_order_tension(world_memory: Dictionary, run_context: Dictionary) -> void:
	var order_tension := _normalize_order_tension(Dictionary(world_memory.get("order_tension", {})))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var recovery_score := int(diagnostics.get("recovery_score", 0))
	var resource_pressure := _string_array(diagnostics.get("resource_pressure", []))
	var places := _string_array(diagnostics.get("load_bearing_places", []))
	var objects := _string_array(diagnostics.get("load_bearing_objects", []))
	var artifact_cultural_association := str(diagnostics.get("artifact_cultural_association", "")).strip_edges()
	var ritual_recurrence := _string_array(diagnostics.get("ritual_recurrence", []))
	var inhabitant_pressure := _string_array(diagnostics.get("inhabitant_pressure", []))
	var hidden_curriculum := _string_array(diagnostics.get("hidden_curriculum", []))
	if not ritual_pressure.is_empty() or not ritual_recurrence.is_empty():
		order_tension["sacred_pressure"] = mini(int(order_tension.get("sacred_pressure", 0)) + 1, 12)
		order_tension["lines"] = _merge_limited(Array(order_tension.get("lines", [])), ["sacred readings are starting to claim authority over practical acts"], 6)
	if not governance_line.is_empty() or hidden_curriculum.size() >= 2:
		order_tension["administrative_pressure"] = mini(int(order_tension.get("administrative_pressure", 0)) + 1, 12)
		order_tension["lines"] = _merge_limited(Array(order_tension.get("lines", [])), ["administrative order is trying to settle meanings that lived practice keeps reopening"], 6)
	if recovery_score >= 2 or not resource_pressure.is_empty():
		order_tension["practical_pressure"] = mini(int(order_tension.get("practical_pressure", 0)) + 1, 12)
		order_tension["lines"] = _merge_limited(Array(order_tension.get("lines", [])), ["lived survival custom keeps checking cleaner doctrine"], 6)
	if int(order_tension.get("sacred_pressure", 0)) >= 1 and int(order_tension.get("administrative_pressure", 0)) >= 1:
		order_tension["lines"] = _merge_limited(Array(order_tension.get("lines", [])), ["sacred and administrative order are now disagreeing about the same obligations"], 6)
	if not places.is_empty() and (not ritual_pressure.is_empty() or not inhabitant_pressure.is_empty()):
		order_tension["forbidden_site_pressure"] = mini(int(order_tension.get("forbidden_site_pressure", 0)) + 1, 12)
		order_tension["site_lines"] = _merge_limited(Array(order_tension.get("site_lines", [])), ["%s is starting to read as a place approached through caution and taboo" % places[0].to_lower()], 6)
	if not objects.is_empty() and (not artifact_cultural_association.is_empty() or not ritual_pressure.is_empty()):
		order_tension["sacred_artifact_pressure"] = mini(int(order_tension.get("sacred_artifact_pressure", 0)) + 1, 12)
		order_tension["artifact_lines"] = _merge_limited(Array(order_tension.get("artifact_lines", [])), ["%s is no longer being handled as a merely practical object" % objects[0].to_lower()], 6)
	world_memory["order_tension"] = order_tension

static func _update_silence_doctrine(world_memory: Dictionary, run_context: Dictionary) -> void:
	var silence_doctrine := _normalize_silence_doctrine(Dictionary(world_memory.get("silence_doctrine", {})))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var open_questions := _string_array(frame.get("open_questions", []))
	var counter_readings := _string_array(frame.get("counter_readings", []))
	var school_tension := str(frame.get("school_tension", "")).strip_edges()
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	var anomaly_signals := _string_array(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("signals", []))
	var places := _string_array(diagnostics.get("load_bearing_places", []))
	if not open_questions.is_empty() and (not school_tension.is_empty() or counter_readings.size() >= 1):
		silence_doctrine["silence_pressure"] = mini(int(silence_doctrine.get("silence_pressure", 0)) + 1, 12)
		silence_doctrine["lines"] = _merge_limited(Array(silence_doctrine.get("lines", [])), ["the world is preserving some contradictions through silence rather than false settlement"], 6)
	if not ritual_pressure.is_empty() and not open_questions.is_empty():
		silence_doctrine["silence_pressure"] = mini(int(silence_doctrine.get("silence_pressure", 0)) + 1, 12)
	if not counterfactual_line.is_empty() or not anomaly_signals.is_empty():
		silence_doctrine["unclassified_pressure"] = mini(int(silence_doctrine.get("unclassified_pressure", 0)) + 1, 12)
		var zone_line := _first_string(anomaly_signals, "")
		if zone_line.is_empty():
			zone_line = "%s is starting to be treated as an unclassified zone" % places[0].to_lower() if not places.is_empty() else "some pressures are now being left intentionally unresolved"
		silence_doctrine["zone_lines"] = _merge_limited(Array(silence_doctrine.get("zone_lines", [])), [zone_line], 6)
	world_memory["silence_doctrine"] = silence_doctrine

static func _update_cookbook_shadow(world_memory: Dictionary, run_context: Dictionary) -> void:
	var cookbook_shadow := _normalize_cookbook_shadow(Dictionary(world_memory.get("cookbook_shadow", {})))
	var profile: Dictionary = Dictionary(run_context.get("profile", {}))
	var cookbook_state: Dictionary = Dictionary(profile.get("cookbook_state", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var fragment_count := int(cookbook_state.get("fragment_count", 0))
	var holder_depth := int(cookbook_state.get("holder_depth", 0))
	var network_pressure := int(cookbook_state.get("network_pressure", 0))
	var redirection_pressure := int(cookbook_state.get("redirection_pressure", 0))
	var fragment_lines := _string_array(cookbook_state.get("fragment_lines", []))
	var marginalia_lines := _string_array(cookbook_state.get("marginalia_lines", []))
	var network_lines := _string_array(cookbook_state.get("network_lines", []))
	var anomaly_signals := _string_array(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("signals", []))
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	if fragment_count >= 1:
		cookbook_shadow["fragment_heat"] = mini(int(cookbook_shadow.get("fragment_heat", 0)) + 1, 12)
		var fragment_line := _first_string(fragment_lines, _first_string(anomaly_signals, "forbidden marginalia are beginning to recur around anomalous descents"))
		cookbook_shadow["lines"] = _merge_limited(Array(cookbook_shadow.get("lines", [])), [fragment_line], 6)
	if holder_depth >= 1:
		cookbook_shadow["holder_rumor"] = mini(int(cookbook_shadow.get("holder_rumor", 0)) + 1, 12)
	if network_pressure >= 1:
		cookbook_shadow["network_rumor"] = mini(int(cookbook_shadow.get("network_rumor", 0)) + 1, 12)
		var rumor_line := _first_string(network_lines, "scattered readers are starting to recognize the same impossible margin marks")
		cookbook_shadow["rumor_lines"] = _merge_limited(Array(cookbook_shadow.get("rumor_lines", [])), [rumor_line], 6)
	if redirection_pressure >= 1 or not counterfactual_line.is_empty():
		cookbook_shadow["redirection_pressure"] = mini(int(cookbook_shadow.get("redirection_pressure", 0)) + 1, 12)
		var redirection_line := _first_string(marginalia_lines, counterfactual_line if not counterfactual_line.is_empty() else "some descents are now being remembered as ways around expected protocol pressure")
		cookbook_shadow["redirection_lines"] = _merge_limited(Array(cookbook_shadow.get("redirection_lines", [])), [redirection_line], 6)
	world_memory["cookbook_shadow"] = cookbook_shadow

static func _update_crawl_network_state(world_memory: Dictionary, run_context: Dictionary) -> void:
	var crawl_network_state := _normalize_crawl_network_state(Dictionary(world_memory.get("crawl_network_state", {})))
	var crawl_packet: Dictionary = Dictionary(run_context.get("crawl_packet", {}))
	var relay_stress := int(crawl_packet.get("relay_stress", 0))
	var relay_memory := _string_array(crawl_packet.get("relay_memory", []))
	var witness_network := _string_array(crawl_packet.get("witness_network", []))
	var relay_bottlenecks := _string_array(crawl_packet.get("relay_bottlenecks", []))
	var rumor_shock := _string_array(crawl_packet.get("rumor_shock", []))
	var cohort_pressure := _string_array(crawl_packet.get("cohort_pressure", []))
	if relay_stress >= 1 or not relay_memory.is_empty():
		crawl_network_state["relay_stress"] = mini(int(crawl_network_state.get("relay_stress", 0)) + maxi(relay_stress, 1), 12)
		crawl_network_state["lines"] = _merge_limited(
			Array(crawl_network_state.get("lines", [])),
			[_first_string(relay_memory, "relay stress is starting to accumulate across the wider crawl")],
			6
		)
	if not witness_network.is_empty():
		crawl_network_state["witness_pressure"] = mini(int(crawl_network_state.get("witness_pressure", 0)) + 1, 12)
		crawl_network_state["witness_lines"] = _merge_limited(Array(crawl_network_state.get("witness_lines", [])), [_first_string(witness_network, "")], 6)
	if not relay_bottlenecks.is_empty():
		crawl_network_state["bottleneck_pressure"] = mini(int(crawl_network_state.get("bottleneck_pressure", 0)) + 1, 12)
		crawl_network_state["bottleneck_lines"] = _merge_limited(Array(crawl_network_state.get("bottleneck_lines", [])), [_first_string(relay_bottlenecks, "")], 6)
	if not rumor_shock.is_empty():
		crawl_network_state["rumor_shock"] = mini(int(crawl_network_state.get("rumor_shock", 0)) + 1, 12)
		crawl_network_state["lines"] = _merge_limited(Array(crawl_network_state.get("lines", [])), [_first_string(rumor_shock, "")], 6)
	if not cohort_pressure.is_empty():
		crawl_network_state["cohort_pressure"] = mini(int(crawl_network_state.get("cohort_pressure", 0)) + 1, 12)
		crawl_network_state["lines"] = _merge_limited(Array(crawl_network_state.get("lines", [])), [_first_string(cohort_pressure, "")], 6)
	world_memory["crawl_network_state"] = crawl_network_state

static func _update_epoch_state(world_memory: Dictionary, _run_context: Dictionary) -> void:
	var institutional_order := _normalize_institutional_order(Dictionary(world_memory.get("institutional_order", {})))
	var epistemic_order := _normalize_epistemic_order(Dictionary(world_memory.get("epistemic_order", {})))
	var affective_climate := _normalize_affective_climate(Dictionary(world_memory.get("affective_climate", {})))
	var cookbook_shadow := _normalize_cookbook_shadow(Dictionary(world_memory.get("cookbook_shadow", {})))
	var crawl_network_state := _normalize_crawl_network_state(Dictionary(world_memory.get("crawl_network_state", {})))
	var epoch_state := _normalize_epoch_state(Dictionary(world_memory.get("epoch_state", {})))
	var candidates := [
		{
			"phase": "custody consolidation",
			"driver": "institutional order",
			"score": int(institutional_order.get("legitimacy_pressure", 0)) + int(institutional_order.get("custody_pressure", 0)) + int(institutional_order.get("burial_pressure", 0)),
			"line": _first_string(
				_string_array(institutional_order.get("claim_lines", [])),
				"artifact custody and burial duty are starting to define the age"
			)
		},
		{
			"phase": "relay fracture",
			"driver": "crawl network stress",
			"score": int(crawl_network_state.get("relay_stress", 0)) + int(crawl_network_state.get("bottleneck_pressure", 0)) + int(crawl_network_state.get("rumor_shock", 0)) + int(crawl_network_state.get("cohort_pressure", 0)),
			"line": _first_string(
				_string_array(crawl_network_state.get("lines", [])),
				"relay bottlenecks are starting to decide how the era is remembered"
			)
		},
		{
			"phase": "counter-canon unrest",
			"driver": "epistemic fracture",
			"score": int(epistemic_order.get("false_canon_pressure", 0)) + int(epistemic_order.get("semantic_drift", 0)) + int(epistemic_order.get("forgery_pressure", 0)) + int(cookbook_shadow.get("redirection_pressure", 0)),
			"line": _first_string(
				_string_array(epistemic_order.get("drift_lines", [])) + _string_array(cookbook_shadow.get("redirection_lines", [])),
				"counter-canon pressure is turning interpretation into an era-level dispute"
			)
		},
		{
			"phase": "mourning turn",
			"driver": "affective climate",
			"score": int(affective_climate.get("melancholy_heat", 0)) + int(affective_climate.get("martyr_pressure", 0)) + int(affective_climate.get("reverence_heat", 0)),
			"line": _first_string(
				_string_array(affective_climate.get("mourning_lines", [])),
				"mourning and reverence are starting to set the historical weather"
			)
		}
	]
	var best_phase := ""
	var best_driver := ""
	var best_line := ""
	var best_score := 0
	for candidate_raw in candidates:
		var candidate: Dictionary = candidate_raw
		var score := int(candidate.get("score", 0))
		if score > best_score:
			best_score = score
			best_phase = str(candidate.get("phase", "")).strip_edges()
			best_driver = str(candidate.get("driver", "")).strip_edges()
			best_line = str(candidate.get("line", "")).strip_edges()
	if best_score <= 0:
		epoch_state["phase"] = ""
		epoch_state["driver"] = ""
		epoch_state["transition_pressure"] = 0
		epoch_state["lines"] = []
	else:
		epoch_state["phase"] = best_phase
		epoch_state["driver"] = best_driver
		epoch_state["transition_pressure"] = clampi(int(floor(float(best_score) / 2.0)), 1, 12)
		epoch_state["lines"] = _merge_limited(Array(epoch_state.get("lines", [])), [best_line], 6)
	world_memory["epoch_state"] = epoch_state

static func _myth_phase(heat: int, touches: int, volatility: int) -> String:
	if heat <= 0:
		return "relic"
	if heat <= 2:
		return "residual"
	if heat >= 4 and touches >= 2 and volatility <= 1:
		return "settling"
	if heat >= 7 and volatility >= 4:
		return "volatile"
	if heat >= 8 and touches >= 5:
		return "saturated"
	if heat >= 6 and touches >= 4:
		return "consolidating"
	if heat >= 9 and touches >= 4:
		return "saturated"
	if volatility >= 4:
		return "volatile"
	if heat >= 6 and touches >= 3:
		return "consolidating"
	return "emerging"

static func _apply_interactions(world_memory: Dictionary, touches: Array[Dictionary], run_context: Dictionary) -> void:
	var myths: Dictionary = Dictionary(world_memory.get("myths", {}))
	var branch_ids: Array[String] = []
	var item_ids: Array[String] = []
	var pair_ids: Array[String] = []
	var crawl_ids: Array[String] = []
	var place_ids: Array[String] = []
	var object_ids: Array[String] = []
	for touch_raw in touches:
		var touch: Dictionary = Dictionary(touch_raw)
		match str(touch.get("bucket", "")):
			"branch":
				branch_ids.append(str(touch.get("key", "")))
			"item":
				item_ids.append(str(touch.get("key", "")))
			"pair":
				pair_ids.append(str(touch.get("key", "")))
			"crawl":
				crawl_ids.append(str(touch.get("key", "")))
			"place":
				place_ids.append(str(touch.get("key", "")))
			"object":
				object_ids.append(str(touch.get("key", "")))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	var focus := str(fascination.get("current_focus", "")).strip_edges()
	var focus_phase := str(fascination.get("phase", "roaming"))
	var focus_fatigue := int(fascination.get("fatigue", 0))
	var challenge_attention := str(frame.get("challenge_attention", "")).strip_edges()
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var curriculum := _string_array(diagnostics.get("hidden_curriculum", []))
	var anomaly_signals := _string_array(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("signals", []))
	var build_identity := str(diagnostics.get("build_identity", "")).strip_edges()
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var gameplay_feature_signals := _string_array(diagnostics.get("gameplay_feature_signals", []))
	var gameplay_group_signals := _string_array(diagnostics.get("gameplay_group_signals", []))
	var model_pressure := _string_array(diagnostics.get("model_pressure", []))
	var group_fault_lines := _string_array(diagnostics.get("group_fault_lines", []))
	var gameplay_signals := _string_array(diagnostics.get("gameplay_behavior_signals", []))
	var synergy_labels := _string_array(diagnostics.get("synergy_labels", []))
	var resource_pressure := _string_array(diagnostics.get("resource_pressure", []))
	var inhabitant_pressure := _string_array(diagnostics.get("inhabitant_pressure", []))
	var protocol_hooks := _string_array(diagnostics.get("protocol_hooks", []))
	var ritual_hooks := _string_array(diagnostics.get("ritual_hooks", []))
	var artifact_lineage_hints := _string_array(diagnostics.get("artifact_lineage_hints", []))
	var artifact_branch_markers := _string_array(diagnostics.get("artifact_branch_markers", []))
	var artifact_memory_hints := _string_array(diagnostics.get("artifact_memory_hints", []))
	var artifact_prestige_indicators := _string_array(diagnostics.get("artifact_prestige_indicators", []))
	var artifact_cultural_association := str(diagnostics.get("artifact_cultural_association", "")).strip_edges()
	var branch_caution_markers := _string_array(diagnostics.get("branch_caution_markers", []))
	var branch_reputation_drift := str(diagnostics.get("branch_reputation_drift", "")).strip_edges()
	var belief_state: Dictionary = Dictionary(diagnostics.get("belief_state", {}))
	var fault_line := str(belief_state.get("fault_line", "")).strip_edges()
	var school_reads := _string_array(frame.get("school_reads", []))
	var branch_labels := _touched_labels(myths, "branch", branch_ids)
	var item_labels := _touched_labels(myths, "item", item_ids)
	var pair_labels := _touched_labels(myths, "pair", pair_ids)
	var place_labels := _touched_labels(myths, "place", place_ids)
	var object_labels := _touched_labels(myths, "object", object_ids)
	for branch_id in branch_ids:
		var branch_bucket: Dictionary = Dictionary(myths.get("branch", {}))
		if branch_bucket.has(branch_id):
			var branch_entry: Dictionary = _normalize_myth_entry(Dictionary(branch_bucket.get(branch_id, {})))
			branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + Array(diagnostics.get("room_identity_highlights", [])) + Array(diagnostics.get("pressure_persistence", [])))
			if not item_ids.is_empty():
				branch_entry["resonance_tags"] = _dedupe_strings(Array(branch_entry.get("resonance_tags", [])) + ["item-loaded branch"] + item_labels)
			if not pair_ids.is_empty():
				branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + ["pair-loaded"])
			if not place_labels.is_empty():
				branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + place_labels)
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
				branch_entry["successor_hint"] = "branch myth under revision"
			if Array(diagnostics.get("recovery_ecology", [])).size() >= 2 and str(diagnostics.get("social_temperature", "")).find("discipline") != -1:
				branch_entry["successor_hint"] = "branch remembered for holds, not only ruptures"
			if not challenge_attention.is_empty():
				branch_entry["pull"] = "challenge stage"
			if not ritual_pressure.is_empty():
				branch_entry["resonance_tags"] = _dedupe_strings(Array(branch_entry.get("resonance_tags", [])) + [ritual_pressure])
			if not ritual_hooks.is_empty():
				branch_entry["resonance_tags"] = _dedupe_strings(Array(branch_entry.get("resonance_tags", [])) + ritual_hooks)
			if not model_pressure.is_empty():
				branch_entry["resonance_tags"] = _dedupe_strings(Array(branch_entry.get("resonance_tags", [])) + model_pressure)
			if not group_fault_lines.is_empty():
				branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + group_fault_lines)
			if not protocol_state.is_empty():
				branch_entry["resonance_tags"] = _dedupe_strings(Array(branch_entry.get("resonance_tags", [])) + [protocol_state])
			if not protocol_hooks.is_empty():
				branch_entry["resonance_tags"] = _dedupe_strings(Array(branch_entry.get("resonance_tags", [])) + protocol_hooks)
			if not resource_pressure.is_empty():
				branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + resource_pressure)
			if not inhabitant_pressure.is_empty():
				branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + inhabitant_pressure)
			if not curriculum.is_empty():
				branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + curriculum)
			if not branch_caution_markers.is_empty():
				branch_entry["shadow_tags"] = _dedupe_strings(Array(branch_entry.get("shadow_tags", [])) + branch_caution_markers)
			if not branch_reputation_drift.is_empty():
				branch_entry["successor_hint"] = branch_reputation_drift
			if int(branch_entry.get("cool_streak", 0)) >= 3:
				branch_entry["damping_tags"] = _dedupe_strings(Array(branch_entry.get("damping_tags", [])) + ["branch myth cooling"])
			if _focus_matches(focus, branch_entry):
				branch_entry["pull"] = "under watch"
				if focus_phase == "fatigued" or focus_fatigue >= 3:
					branch_entry["damping_tags"] = _dedupe_strings(Array(branch_entry.get("damping_tags", [])) + ["overexposed branch"])
			branch_bucket[branch_id] = branch_entry
			myths["branch"] = branch_bucket
	for item_id in item_ids:
		var item_bucket: Dictionary = Dictionary(myths.get("item", {}))
		if item_bucket.has(item_id):
			var item_entry: Dictionary = _normalize_myth_entry(Dictionary(item_bucket.get(item_id, {})))
			item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + Array(diagnostics.get("symbolic_gestures", [])) + Array(diagnostics.get("quest_pressure", [])))
			if not branch_ids.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + ["branch-loaded"] + branch_labels)
			if not object_labels.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + object_labels)
			if Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
				item_entry["pull"] = "redemption-loaded"
			if not challenge_attention.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + [challenge_attention])
			if not ritual_pressure.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + [ritual_pressure])
			if not synergy_labels.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + synergy_labels)
			if not model_pressure.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + model_pressure)
			if not resource_pressure.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + resource_pressure)
			if not build_identity.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + [build_identity])
			if not build_stability.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + [build_stability])
			if not risk_profile.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + [risk_profile])
			if not anomaly_signals.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + anomaly_signals)
			if not artifact_lineage_hints.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + artifact_lineage_hints)
			if not artifact_branch_markers.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + artifact_branch_markers)
			if not artifact_memory_hints.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + artifact_memory_hints)
			if not artifact_prestige_indicators.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + artifact_prestige_indicators)
			if not artifact_cultural_association.is_empty():
				item_entry["resonance_tags"] = _dedupe_strings(Array(item_entry.get("resonance_tags", [])) + [artifact_cultural_association])
				item_entry["pull"] = "cultural marker"
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
				item_entry["successor_hint"] = "recast item story"
				if Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
					item_entry["successor_hint"] = "curse softening into a redemption story"
			if not pair_labels.is_empty():
				item_entry["shadow_tags"] = _dedupe_strings(Array(item_entry.get("shadow_tags", [])) + pair_labels)
			if _focus_matches(focus, item_entry):
				item_entry["pull"] = "under watch"
				if focus_phase == "fatigued" or focus_fatigue >= 3:
					item_entry["damping_tags"] = _dedupe_strings(Array(item_entry.get("damping_tags", [])) + ["item overexposure"])
			item_bucket[item_id] = item_entry
			myths["item"] = item_bucket
	for pair_id in pair_ids:
		var pair_bucket: Dictionary = Dictionary(myths.get("pair", {}))
		if pair_bucket.has(pair_id):
			var pair_entry: Dictionary = _normalize_myth_entry(Dictionary(pair_bucket.get(pair_id, {})))
			pair_entry["resonance_tags"] = _dedupe_strings(Array(pair_entry.get("resonance_tags", [])) + Array(diagnostics.get("social_beats_top", [])) + Array(diagnostics.get("pressure_persistence", [])))
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
				pair_entry["successor_hint"] = "pattern break pair"
				if Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
					pair_entry["successor_hint"] = "recast alliance"
			if Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
				pair_entry["shadow_tags"] = _dedupe_strings(Array(pair_entry.get("shadow_tags", [])) + ["rescue debt"])
				pair_entry["pull"] = "owed another answer"
			if Array(diagnostics.get("crew_hooks", [])).size() >= 1:
				pair_entry["resonance_tags"] = _dedupe_strings(Array(pair_entry.get("resonance_tags", [])) + Array(diagnostics.get("crew_hooks", [])))
			if not gameplay_signals.is_empty():
				pair_entry["resonance_tags"] = _dedupe_strings(Array(pair_entry.get("resonance_tags", [])) + gameplay_signals)
			if not gameplay_group_signals.is_empty():
				pair_entry["resonance_tags"] = _dedupe_strings(Array(pair_entry.get("resonance_tags", [])) + gameplay_group_signals)
			if not model_pressure.is_empty():
				pair_entry["resonance_tags"] = _dedupe_strings(Array(pair_entry.get("resonance_tags", [])) + model_pressure)
			if not resource_pressure.is_empty():
				pair_entry["shadow_tags"] = _dedupe_strings(Array(pair_entry.get("shadow_tags", [])) + resource_pressure)
			if not inhabitant_pressure.is_empty():
				pair_entry["shadow_tags"] = _dedupe_strings(Array(pair_entry.get("shadow_tags", [])) + inhabitant_pressure)
			if not challenge_attention.is_empty():
				pair_entry["resonance_tags"] = _dedupe_strings(Array(pair_entry.get("resonance_tags", [])) + [challenge_attention])
			if not fault_line.is_empty():
				pair_entry["shadow_tags"] = _dedupe_strings(Array(pair_entry.get("shadow_tags", [])) + [fault_line])
			if not group_fault_lines.is_empty():
				pair_entry["shadow_tags"] = _dedupe_strings(Array(pair_entry.get("shadow_tags", [])) + group_fault_lines)
			if not branch_labels.is_empty():
				pair_entry["shadow_tags"] = _dedupe_strings(Array(pair_entry.get("shadow_tags", [])) + branch_labels)
			if not object_labels.is_empty():
				pair_entry["shadow_tags"] = _dedupe_strings(Array(pair_entry.get("shadow_tags", [])) + object_labels)
			if _focus_matches(focus, pair_entry):
				pair_entry["pull"] = "story magnet"
				if focus_phase == "fatigued" or focus_fatigue >= 3:
					pair_entry["damping_tags"] = _dedupe_strings(Array(pair_entry.get("damping_tags", [])) + ["pair overexposure"])
			pair_bucket[pair_id] = pair_entry
			myths["pair"] = pair_bucket
	for player_id in Dictionary(myths.get("player", {})).keys():
		var player_bucket: Dictionary = Dictionary(myths.get("player", {}))
		var player_entry: Dictionary = _normalize_myth_entry(Dictionary(player_bucket.get(player_id, {})))
		if Array(diagnostics.get("choice_frames", [])).size() >= 1:
			player_entry["resonance_tags"] = _dedupe_strings(Array(player_entry.get("resonance_tags", [])) + Array(diagnostics.get("choice_frames", [])))
		if not build_identity.is_empty():
			player_entry["resonance_tags"] = _dedupe_strings(Array(player_entry.get("resonance_tags", [])) + [build_identity])
		if not gameplay_signals.is_empty():
			player_entry["resonance_tags"] = _dedupe_strings(Array(player_entry.get("resonance_tags", [])) + gameplay_signals)
		if not gameplay_feature_signals.is_empty():
			player_entry["resonance_tags"] = _dedupe_strings(Array(player_entry.get("resonance_tags", [])) + gameplay_feature_signals)
		if not gameplay_group_signals.is_empty():
			player_entry["resonance_tags"] = _dedupe_strings(Array(player_entry.get("resonance_tags", [])) + gameplay_group_signals)
		if not model_pressure.is_empty():
			player_entry["resonance_tags"] = _dedupe_strings(Array(player_entry.get("resonance_tags", [])) + model_pressure)
		if not resource_pressure.is_empty():
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + resource_pressure)
		if not inhabitant_pressure.is_empty():
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + inhabitant_pressure)
		if not _string_array(diagnostics.get("counterfactual_pressure", [])).is_empty():
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + _string_array(diagnostics.get("counterfactual_pressure", [])))
		if not group_fault_lines.is_empty():
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + group_fault_lines)
		if not build_stability.is_empty():
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + [build_stability])
		if not risk_profile.is_empty():
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + [risk_profile])
		if Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
			player_entry["successor_hint"] = "public reading may shift"
		if str(frame.get("status_valence", "")) in ["Scandal", "Infamy"]:
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + ["status burden"])
		if not challenge_attention.is_empty():
			player_entry["shadow_tags"] = _dedupe_strings(Array(player_entry.get("shadow_tags", [])) + [challenge_attention])
			player_entry["pull"] = "expected to answer"
		if Array(diagnostics.get("expectation_breaks", [])).size() >= 1 and str(frame.get("status_valence", "")) in ["Prestige", "Redemption"]:
			player_entry["successor_hint"] = "public role being recast"
		if _focus_matches(focus, player_entry):
			player_entry["pull"] = "under watch"
		player_bucket[player_id] = player_entry
		myths["player"] = player_bucket
	for crew_id in Dictionary(myths.get("crew", {})).keys():
		var crew_bucket: Dictionary = Dictionary(myths.get("crew", {}))
		var crew_entry: Dictionary = _normalize_myth_entry(Dictionary(crew_bucket.get(crew_id, {})))
		if Array(diagnostics.get("crew_hooks", [])).size() >= 1:
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + Array(diagnostics.get("crew_hooks", [])))
		if not build_identity.is_empty():
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + [build_identity])
		if not gameplay_group_signals.is_empty():
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + gameplay_group_signals)
		if not model_pressure.is_empty():
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + model_pressure)
		if not resource_pressure.is_empty():
			crew_entry["shadow_tags"] = _dedupe_strings(Array(crew_entry.get("shadow_tags", [])) + resource_pressure)
		if not inhabitant_pressure.is_empty():
			crew_entry["shadow_tags"] = _dedupe_strings(Array(crew_entry.get("shadow_tags", [])) + inhabitant_pressure)
		if not group_fault_lines.is_empty():
			crew_entry["shadow_tags"] = _dedupe_strings(Array(crew_entry.get("shadow_tags", [])) + group_fault_lines)
		if str(diagnostics.get("group_shape_drift", "")) in ["unified_to_fragmented", "brittle_to_mythic"]:
			crew_entry["shadow_tags"] = _dedupe_strings(Array(crew_entry.get("shadow_tags", [])) + [str(diagnostics.get("group_shape_drift", "")).replace("_", " ")])
		if not pair_labels.is_empty():
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + pair_labels)
		if not branch_labels.is_empty():
			crew_entry["shadow_tags"] = _dedupe_strings(Array(crew_entry.get("shadow_tags", [])) + branch_labels)
		if Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
			crew_entry["pull"] = "hold together"
		if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"]:
			crew_entry["shadow_tags"] = _dedupe_strings(Array(crew_entry.get("shadow_tags", [])) + ["success burden"])
		if Array(diagnostics.get("pressure_persistence", [])).size() >= 2:
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + Array(diagnostics.get("pressure_persistence", [])))
		if not challenge_attention.is_empty():
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + [challenge_attention])
		if not curriculum.is_empty():
			crew_entry["shadow_tags"] = _dedupe_strings(Array(crew_entry.get("shadow_tags", [])) + curriculum)
		if not protocol_hooks.is_empty():
			crew_entry["resonance_tags"] = _dedupe_strings(Array(crew_entry.get("resonance_tags", [])) + protocol_hooks)
		if _focus_matches(focus, crew_entry) and (focus_phase == "fatigued" or focus_fatigue >= 3):
			crew_entry["damping_tags"] = _dedupe_strings(Array(crew_entry.get("damping_tags", [])) + ["crew overexposure"])
		crew_bucket[crew_id] = crew_entry
		myths["crew"] = crew_bucket
	for crawl_id in crawl_ids:
		var crawl_bucket: Dictionary = Dictionary(myths.get("crawl", {}))
		if crawl_bucket.has(crawl_id):
			var crawl_entry: Dictionary = _normalize_myth_entry(Dictionary(crawl_bucket.get(crawl_id, {})))
			if int(diagnostics.get("near_miss_score", 0)) >= 2:
				crawl_entry["pull"] = "awaiting resolution"
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
				crawl_entry["successor_hint"] = "myth inversion"
			if Array(diagnostics.get("pressure_persistence", [])).size() >= 2:
				crawl_entry["resonance_tags"] = _dedupe_strings(Array(crawl_entry.get("resonance_tags", [])) + Array(diagnostics.get("pressure_persistence", [])))
			if str(frame.get("challenge_attention", "")).strip_edges() != "":
				crawl_entry["pull"] = "public challenge"
			if str(frame.get("challenge_attention", "")).strip_edges() != "" and str(frame.get("ritual_pressure", "")).strip_edges() != "":
				crawl_entry["resonance_tags"] = _dedupe_strings(Array(crawl_entry.get("resonance_tags", [])) + [str(frame.get("ritual_pressure", ""))])
			if not curriculum.is_empty():
				crawl_entry["shadow_tags"] = _dedupe_strings(Array(crawl_entry.get("shadow_tags", [])) + curriculum)
			if not model_pressure.is_empty():
				crawl_entry["resonance_tags"] = _dedupe_strings(Array(crawl_entry.get("resonance_tags", [])) + model_pressure)
			if not group_fault_lines.is_empty():
				crawl_entry["shadow_tags"] = _dedupe_strings(Array(crawl_entry.get("shadow_tags", [])) + group_fault_lines)
			if not build_identity.is_empty():
				crawl_entry["resonance_tags"] = _dedupe_strings(Array(crawl_entry.get("resonance_tags", [])) + [build_identity])
			if not protocol_hooks.is_empty():
				crawl_entry["resonance_tags"] = _dedupe_strings(Array(crawl_entry.get("resonance_tags", [])) + protocol_hooks)
			if not resource_pressure.is_empty():
				crawl_entry["shadow_tags"] = _dedupe_strings(Array(crawl_entry.get("shadow_tags", [])) + resource_pressure)
			if not inhabitant_pressure.is_empty():
				crawl_entry["shadow_tags"] = _dedupe_strings(Array(crawl_entry.get("shadow_tags", [])) + inhabitant_pressure)
			if not build_stability.is_empty():
				crawl_entry["shadow_tags"] = _dedupe_strings(Array(crawl_entry.get("shadow_tags", [])) + [build_stability])
			if not protocol_state.is_empty():
				crawl_entry["resonance_tags"] = _dedupe_strings(Array(crawl_entry.get("resonance_tags", [])) + [protocol_state])
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1 and str(frame.get("status_valence", "")) in ["Prestige", "Redemption"]:
				crawl_entry["successor_hint"] = "crawl story being recast"
			if _focus_matches(focus, crawl_entry) and (focus_phase == "fatigued" or focus_fatigue >= 3):
				crawl_entry["damping_tags"] = _dedupe_strings(Array(crawl_entry.get("damping_tags", [])) + ["saga fatigue"])
			crawl_bucket[crawl_id] = crawl_entry
			myths["crawl"] = crawl_bucket
	for place_id in place_ids:
		var place_bucket: Dictionary = Dictionary(myths.get("place", {}))
		if place_bucket.has(place_id):
			var place_entry: Dictionary = _normalize_myth_entry(Dictionary(place_bucket.get(place_id, {})))
			place_entry["resonance_tags"] = _dedupe_strings(Array(place_entry.get("resonance_tags", [])) + Array(diagnostics.get("room_identity_highlights", [])) + Array(diagnostics.get("run_changing_moments", [])))
			if Array(diagnostics.get("spectacle_windows", [])).size() >= 1:
				place_entry["shadow_tags"] = _dedupe_strings(Array(place_entry.get("shadow_tags", [])) + ["loaded site"])
			if not ritual_pressure.is_empty():
				place_entry["pull"] = "ritual site"
			if not resource_pressure.is_empty():
				place_entry["shadow_tags"] = _dedupe_strings(Array(place_entry.get("shadow_tags", [])) + resource_pressure)
			if not inhabitant_pressure.is_empty():
				place_entry["shadow_tags"] = _dedupe_strings(Array(place_entry.get("shadow_tags", [])) + inhabitant_pressure)
			if not model_pressure.is_empty():
				place_entry["resonance_tags"] = _dedupe_strings(Array(place_entry.get("resonance_tags", [])) + model_pressure)
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1 and Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
				place_entry["successor_hint"] = "site remembered differently now"
			if not branch_labels.is_empty():
				place_entry["shadow_tags"] = _dedupe_strings(Array(place_entry.get("shadow_tags", [])) + branch_labels)
			if not object_labels.is_empty():
				place_entry["resonance_tags"] = _dedupe_strings(Array(place_entry.get("resonance_tags", [])) + object_labels)
			place_bucket[place_id] = place_entry
			myths["place"] = place_bucket
	for object_id in object_ids:
		var object_bucket: Dictionary = Dictionary(myths.get("object", {}))
		if object_bucket.has(object_id):
			var object_entry: Dictionary = _normalize_myth_entry(Dictionary(object_bucket.get(object_id, {})))
			object_entry["resonance_tags"] = _dedupe_strings(Array(object_entry.get("resonance_tags", [])) + Array(diagnostics.get("symbolic_gestures", [])) + Array(diagnostics.get("quest_pressure", [])))
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
				object_entry["successor_hint"] = "object story under revision"
			if not ritual_pressure.is_empty():
				object_entry["pull"] = "ritual object"
			if not synergy_labels.is_empty():
				object_entry["resonance_tags"] = _dedupe_strings(Array(object_entry.get("resonance_tags", [])) + synergy_labels)
			if not model_pressure.is_empty():
				object_entry["resonance_tags"] = _dedupe_strings(Array(object_entry.get("resonance_tags", [])) + model_pressure)
			if not build_identity.is_empty():
				object_entry["shadow_tags"] = _dedupe_strings(Array(object_entry.get("shadow_tags", [])) + [build_identity])
			if not challenge_attention.is_empty():
				object_entry["shadow_tags"] = _dedupe_strings(Array(object_entry.get("shadow_tags", [])) + [challenge_attention])
			if Array(diagnostics.get("expectation_breaks", [])).size() >= 1 and Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
				object_entry["successor_hint"] = "object story recast"
			if not place_labels.is_empty():
				object_entry["shadow_tags"] = _dedupe_strings(Array(object_entry.get("shadow_tags", [])) + place_labels)
			object_bucket[object_id] = object_entry
			myths["object"] = object_bucket
	world_memory["myths"] = myths

static func _refresh_field_state(world_memory: Dictionary) -> void:
	var resonance_lines: Array[String] = []
	var collision_lines: Array[String] = []
	var resurgence_lines: Array[String] = []
	var cooling_lines: Array[String] = []
	var successor_lines: Array[String] = []
	var protocol_lines: Array[String] = []
	var top_successor: Dictionary = {}
	var top_label := ""
	var top_bucket := ""
	var top_gravity := 0
	var resonance_count := 0
	var damping_count := 0
	var shadow_count := 0
	var resonance_buckets := {}
	var shadow_buckets := {}
	for bucket in MYTH_BUCKETS:
		var bucket_dict: Dictionary = Dictionary(Dictionary(world_memory.get("myths", {})).get(bucket, {}))
		for myth_key in bucket_dict.keys():
			var entry: Dictionary = _normalize_myth_entry(Dictionary(bucket_dict.get(myth_key, {})))
			var label := str(entry.get("label", myth_key)).strip_edges()
			if label.is_empty():
				continue
			var gravity := int(entry.get("gravity", 0))
			if gravity > top_gravity:
				top_gravity = gravity
				top_label = label
				top_bucket = bucket
			var resonance := _string_array(entry.get("resonance_tags", []))
			var damping := _string_array(entry.get("damping_tags", []))
			var shadow := _string_array(entry.get("shadow_tags", []))
			for tag in resonance:
				var key := tag.to_lower()
				var buckets: Array[String] = _string_array(resonance_buckets.get(key, []))
				if not buckets.has(bucket):
					buckets.append(bucket)
				resonance_buckets[key] = buckets
			for tag in shadow:
				var shadow_key := tag.to_lower()
				var shadow_list: Array[String] = _string_array(shadow_buckets.get(shadow_key, []))
				if not shadow_list.has(bucket):
					shadow_list.append(bucket)
				shadow_buckets[shadow_key] = shadow_list
			if not resonance.is_empty():
				resonance_count += 1
				if resonance_lines.size() < 3:
					resonance_lines.append("%s is still resonating with %s" % [label, resonance[0].to_lower()])
			if not damping.is_empty():
				damping_count += 1
				if cooling_lines.size() < 3:
					cooling_lines.append("%s is cooling through %s" % [label, damping[0].to_lower()])
			if not shadow.is_empty():
				shadow_count += 1
				if collision_lines.size() < 3:
					collision_lines.append("%s is still shadowed by %s" % [label, shadow[0].to_lower()])
			var successor := str(entry.get("successor_hint", "")).strip_edges()
			if not successor.is_empty() and (top_successor.is_empty() or gravity > int(top_successor.get("gravity", 0))):
				top_successor = {
					"label": label,
					"bucket": bucket,
					"hint": successor,
					"gravity": gravity
				}
			if not successor.is_empty() and successor_lines.size() < 3:
				successor_lines.append("%s is being recast toward %s." % [label, successor.to_lower()])
			if int(entry.get("revivals", 0)) >= 1 and resurgence_lines.size() < 3:
				resurgence_lines.append("%s is returning with a new argument." % label)
			for tag in resonance + shadow:
				if tag.find("Protocol") != -1 or tag.find("Doctrine") != -1 or tag.find("discipline") != -1 or tag.find("caution") != -1 or tag.find("burden respect") != -1 or tag.find("pressure line") != -1 or tag.find("governance") != -1:
					if protocol_lines.size() < 3:
						protocol_lines.append("%s keeps bending stories toward %s." % [label, tag.to_lower()])
	for tag in resonance_buckets.keys():
		var buckets: Array[String] = _string_array(resonance_buckets.get(tag, []))
		if buckets.size() >= 2 and resonance_lines.size() < 4:
			resonance_lines.append("%s is tying %s memory together." % [str(tag), " and ".join(buckets.slice(0, mini(buckets.size(), 3)))])
	for tag in shadow_buckets.keys():
		var buckets: Array[String] = _string_array(shadow_buckets.get(tag, []))
		if buckets.size() >= 2 and collision_lines.size() < 4:
			collision_lines.append("%s is still shadowing %s." % [str(tag), " and ".join(buckets.slice(0, mini(buckets.size(), 3)))])
	world_memory["myth_field"] = {
		"resonance_count": resonance_count,
		"damping_count": damping_count,
		"shadow_count": shadow_count,
		"top_successor": top_successor,
		"active_lines": _dedupe_strings(resonance_lines + collision_lines + successor_lines),
		"protocol_lines": _dedupe_strings(protocol_lines)
	}
	var gravity_lines: Array[String] = []
	if not top_label.is_empty():
		gravity_lines.append("%s is pulling nearby stories into its orbit." % top_label)
		if not top_successor.is_empty():
			gravity_lines.append("%s is being recast as %s." % [top_label, str(top_successor.get("hint", "")).to_lower()])
		if damping_count >= 3:
			gravity_lines.append("%s is still dominant even as other stories cool." % top_label)
	world_memory["cultural_gravity"] = {
		"top_label": top_label,
		"top_bucket": top_bucket,
		"top_gravity": top_gravity,
		"lines": gravity_lines
	}
	world_memory["topic_interaction"] = {
		"lines": _dedupe_strings(resonance_lines + successor_lines + [
			str(Dictionary(world_memory.get("fascination", {})).get("pressure", "")).strip_edges()
		] + protocol_lines).slice(0, 3)
	}
	world_memory["myth_cooling"] = {
		"lines": cooling_lines.slice(0, 3)
	}
	world_memory["myth_collision"] = {
		"lines": collision_lines.slice(0, 3)
	}
	world_memory["myth_resurgence"] = {
		"lines": resurgence_lines.slice(0, 3)
	}

static func _heat_band(heat: int) -> String:
	if heat >= 6:
		return "hot"
	if heat >= 3:
		return "active"
	if heat >= 1:
		return "cooling"
	return "faint"

static func _title_case(text: String) -> String:
	return text.strip_edges().replace("_", " ").capitalize()

static func _push_front_unique(values: Array, value: String, limit: int) -> Array[String]:
	var result: Array[String] = _dedupe_strings(values)
	var text := value.strip_edges()
	if text.is_empty():
		return result
	if result.has(text):
		result.erase(text)
	result.push_front(text)
	if result.size() > limit:
		return result.slice(0, limit)
	return result

static func _merge_limited(existing: Array, additions: Array, limit: int) -> Array[String]:
	var result: Array[String] = _dedupe_strings(existing)
	for addition in additions:
		var text := str(addition).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	if result.size() > limit:
		return result.slice(0, limit)
	return result

static func _current_gravity_center(world_memory: Dictionary) -> String:
	var best_label := ""
	var best_gravity := 0
	for bucket in MYTH_BUCKETS:
		for entry_raw in Dictionary(Dictionary(world_memory.get("myths", {})).get(bucket, {})).values():
			var entry: Dictionary = Dictionary(entry_raw)
			var gravity := int(entry.get("gravity", 0))
			if gravity > best_gravity:
				best_gravity = gravity
				best_label = str(entry.get("label", ""))
	return best_label

static func _touched_labels(myths: Dictionary, bucket: String, ids: Array[String]) -> Array[String]:
	var result: Array[String] = []
	var bucket_dict: Dictionary = Dictionary(myths.get(bucket, {}))
	for myth_id in ids:
		var entry: Dictionary = Dictionary(bucket_dict.get(myth_id, {}))
		var label := str(entry.get("label", "")).strip_edges()
		if not label.is_empty() and not result.has(label):
			result.append(label)
	return result

static func _focus_matches(focus: String, entry: Dictionary) -> bool:
	if focus.is_empty():
		return false
	var label := str(entry.get("label", "")).strip_edges()
	if label == focus:
		return true
	for tag in _string_array(entry.get("layers", [])) + _string_array(entry.get("resonance_tags", [])):
		if tag == focus:
			return true
	return false

static func _build_pull_text(build_identity: String, build_scores: Dictionary) -> String:
	if build_identity.is_empty():
		return ""
	var top_score := 0
	for score in build_scores.values():
		top_score = maxi(top_score, int(score))
	if top_score >= 6:
		return "%s pressure" % build_identity
	return build_identity

static func _pair_label(pair_key: String) -> String:
	var bits := pair_key.split(":")
	if bits.size() == 2:
		return "%s / %s" % [bits[0], bits[1]]
	return pair_key

static func _dominant_epistemic_tradition(commentary_lanes: Array[String], diagnostics: Dictionary, frame: Dictionary, continuity_state: String) -> String:
	if commentary_lanes.has("Ritual"):
		return "ritual-proof truth"
	if commentary_lanes.has("Conspiracy") or int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0)) >= 3:
		return "anomaly-proof truth"
	if commentary_lanes.has("Tactical"):
		return "map-first truth"
	if continuity_state in ["burial", "fragmented_legacy", "successor_emergence"]:
		return "lineage-first truth"
	if not str(frame.get("governance_line", "")).strip_edges().is_empty() and commentary_lanes.has("Systemic"):
		return "sanctioned official proof"
	if commentary_lanes.has("Forensic") or commentary_lanes.has("Analytical"):
		return "archive-first truth"
	if not commentary_lanes.is_empty():
		return "witness-first truth"
	return ""

static func _dominant_affective_age(affective_climate: Dictionary, fatigue: int) -> String:
	var age_scores := {
		"shame-heavy age": int(affective_climate.get("shame_heat", 0)),
		"reverent age": int(affective_climate.get("reverence_heat", 0)),
		"paranoid age": int(affective_climate.get("paranoia_heat", 0)),
		"punitive age": int(affective_climate.get("punitive_heat", 0)),
		"melancholic age": int(affective_climate.get("melancholy_heat", 0)),
		"hopeful restoration age": int(affective_climate.get("hope_heat", 0))
	}
	var best_age := ""
	var best_score := 0
	for age in age_scores.keys():
		var score := int(age_scores.get(age, 0))
		if score > best_score or (score == best_score and not best_age.is_empty() and age < best_age):
			best_age = str(age)
			best_score = score
	if best_score == 0 and fatigue >= 3:
		return "exhausted age"
	return best_age

static func _dominant_ontology(commentary_lanes: Array[String], diagnostics: Dictionary, frame: Dictionary) -> String:
	var anomaly_score := int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0))
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var model_pressure := _string_array(diagnostics.get("model_pressure", []))
	if commentary_lanes.has("Conspiracy") or anomaly_score >= 3:
		return "unknowable anomaly"
	if not ritual_pressure.is_empty() or commentary_lanes.has("Ritual"):
		return "divine instrument"
	if commentary_lanes.has("Systemic") and not governance_line.is_empty():
		return "artificial experiment"
	if commentary_lanes.has("Analytical") or commentary_lanes.has("Forensic"):
		return "ruin"
	if commentary_lanes.has("Tactical") or not model_pressure.is_empty():
		return "test"
	return ""

static func _uncertainty_philosophy(commentary_lanes: Array[String], diagnostics: Dictionary, frame: Dictionary) -> String:
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var anomaly_score := int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0))
	var resource_pressure := _string_array(diagnostics.get("resource_pressure", []))
	if not belief_line.is_empty() and not counterfactual_line.is_empty():
		return "necessary condition of truth"
	if anomaly_score >= 3:
		return "moral burden"
	if not ritual_pressure.is_empty():
		return "sacred trial"
	if commentary_lanes.has("Systemic") and not governance_line.is_empty() and not counterfactual_line.is_empty():
		return "political instrument"
	if not resource_pressure.is_empty():
		return "obstacle to reduce"
	return ""

static func _normalize_institutional_order(order: Dictionary) -> Dictionary:
	var current := {
		"legitimacy_pressure": 0,
		"taboo_heat": 0,
		"custody_pressure": 0,
		"burial_pressure": 0,
		"heresy_pressure": 0,
		"lines": [],
		"taboo_lines": [],
		"claim_lines": []
	}
	for key in order.keys():
		current[key] = order[key]
	for key in ["legitimacy_pressure", "taboo_heat", "custody_pressure", "burial_pressure", "heresy_pressure"]:
		current[key] = int(current.get(key, 0))
	for key in ["lines", "taboo_lines", "claim_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_epistemic_order(order: Dictionary) -> Dictionary:
	var current := {
		"orthodoxy_strength": 0,
		"revision_pressure": 0,
		"false_canon_pressure": 0,
		"semantic_drift": 0,
		"forgery_pressure": 0,
		"dominant_tradition": "",
		"lines": [],
		"drift_lines": [],
		"forgery_lines": []
	}
	for key in order.keys():
		current[key] = order[key]
	for key in ["orthodoxy_strength", "revision_pressure", "false_canon_pressure", "semantic_drift", "forgery_pressure"]:
		current[key] = int(current.get(key, 0))
	current["dominant_tradition"] = str(current.get("dominant_tradition", "")).strip_edges()
	for key in ["lines", "drift_lines", "forgery_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_affective_climate(climate: Dictionary) -> Dictionary:
	var current := {
		"dominant_age": "",
		"shame_heat": 0,
		"reverence_heat": 0,
		"paranoia_heat": 0,
		"punitive_heat": 0,
		"melancholy_heat": 0,
		"hope_heat": 0,
		"martyr_pressure": 0,
		"anti_martyr_pressure": 0,
		"ordinary_life_pressure": 0,
		"lines": [],
		"mourning_lines": [],
		"labor_lines": []
	}
	for key in climate.keys():
		current[key] = climate[key]
	current["dominant_age"] = str(current.get("dominant_age", "")).strip_edges()
	for key in ["shame_heat", "reverence_heat", "paranoia_heat", "punitive_heat", "melancholy_heat", "hope_heat", "martyr_pressure", "anti_martyr_pressure", "ordinary_life_pressure"]:
		current[key] = int(current.get(key, 0))
	for key in ["lines", "mourning_lines", "labor_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_ontology_state(state: Dictionary) -> Dictionary:
	var current := {
		"dominant_ontology": "",
		"uncertainty_philosophy": "",
		"counterfactual_heat": 0,
		"lines": [],
		"uncertainty_lines": [],
		"echo_lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	current["dominant_ontology"] = str(current.get("dominant_ontology", "")).strip_edges()
	current["uncertainty_philosophy"] = str(current.get("uncertainty_philosophy", "")).strip_edges()
	current["counterfactual_heat"] = int(current.get("counterfactual_heat", 0))
	for key in ["lines", "uncertainty_lines", "echo_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_delve_history(state: Dictionary) -> Dictionary:
	var current := {
		"method_counts": {},
		"dominant_method": "",
		"misclassification_pressure": 0,
		"overcorrection_pressure": 0,
		"abandoned_paradigms": [],
		"lines": [],
		"history_lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	current["method_counts"] = Dictionary(current.get("method_counts", {}))
	current["dominant_method"] = str(current.get("dominant_method", "")).strip_edges()
	current["misclassification_pressure"] = int(current.get("misclassification_pressure", 0))
	current["overcorrection_pressure"] = int(current.get("overcorrection_pressure", 0))
	current["abandoned_paradigms"] = _string_array(current.get("abandoned_paradigms", []))
	for key in ["lines", "history_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_interpretation_network(state: Dictionary) -> Dictionary:
	var current := {
		"node_heat": 0,
		"spread_heat": 0,
		"contradiction_heat": 0,
		"ritual_spread": 0,
		"institutional_campaigns": 0,
		"dominant_nodes": [],
		"lines": [],
		"spread_lines": [],
		"campaign_lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	for key in ["node_heat", "spread_heat", "contradiction_heat", "ritual_spread", "institutional_campaigns"]:
		current[key] = int(current.get(key, 0))
	current["dominant_nodes"] = _string_array(current.get("dominant_nodes", []))
	for key in ["lines", "spread_lines", "campaign_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_order_tension(state: Dictionary) -> Dictionary:
	var current := {
		"sacred_pressure": 0,
		"administrative_pressure": 0,
		"practical_pressure": 0,
		"forbidden_site_pressure": 0,
		"sacred_artifact_pressure": 0,
		"lines": [],
		"site_lines": [],
		"artifact_lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	for key in ["sacred_pressure", "administrative_pressure", "practical_pressure", "forbidden_site_pressure", "sacred_artifact_pressure"]:
		current[key] = int(current.get(key, 0))
	for key in ["lines", "site_lines", "artifact_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_silence_doctrine(state: Dictionary) -> Dictionary:
	var current := {
		"silence_pressure": 0,
		"unclassified_pressure": 0,
		"lines": [],
		"zone_lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	current["silence_pressure"] = int(current.get("silence_pressure", 0))
	current["unclassified_pressure"] = int(current.get("unclassified_pressure", 0))
	for key in ["lines", "zone_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_cookbook_shadow(state: Dictionary) -> Dictionary:
	var current := {
		"fragment_heat": 0,
		"holder_rumor": 0,
		"network_rumor": 0,
		"redirection_pressure": 0,
		"lines": [],
		"rumor_lines": [],
		"redirection_lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	for key in ["fragment_heat", "holder_rumor", "network_rumor", "redirection_pressure"]:
		current[key] = int(current.get(key, 0))
	for key in ["lines", "rumor_lines", "redirection_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_crawl_network_state(state: Dictionary) -> Dictionary:
	var current := {
		"relay_stress": 0,
		"witness_pressure": 0,
		"bottleneck_pressure": 0,
		"rumor_shock": 0,
		"cohort_pressure": 0,
		"lines": [],
		"witness_lines": [],
		"bottleneck_lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	for key in ["relay_stress", "witness_pressure", "bottleneck_pressure", "rumor_shock", "cohort_pressure"]:
		current[key] = int(current.get(key, 0))
	for key in ["lines", "witness_lines", "bottleneck_lines"]:
		current[key] = _string_array(current.get(key, []))
	return current

static func _normalize_epoch_state(state: Dictionary) -> Dictionary:
	var current := {
		"phase": "",
		"transition_pressure": 0,
		"driver": "",
		"lines": []
	}
	for key in state.keys():
		current[key] = state[key]
	current["phase"] = str(current.get("phase", "")).strip_edges()
	current["transition_pressure"] = int(current.get("transition_pressure", 0))
	current["driver"] = str(current.get("driver", "")).strip_edges()
	current["lines"] = _string_array(current.get("lines", []))
	return current

static func _dedupe_strings(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _string_array(values: Variant) -> Array[String]:
	return _dedupe_strings(values)

static func _first_string(values: Array, fallback: String) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback
