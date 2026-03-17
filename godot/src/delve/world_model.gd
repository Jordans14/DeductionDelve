class_name DelveWorldModel
extends RefCounted

const DELVEMIND_EXPERIMENT_ENGINE_SCRIPT = preload("res://src/product/delvemind_experiment_engine.gd")

static func build_model(profile: Dictionary, session_context: Dictionary) -> Dictionary:
	var run_history := Array(profile.get("run_history", []))
	var crawl_history := Array(profile.get("crawl_history", []))
	var active_crawl := Dictionary(profile.get("active_crawl", {}))
	var world_memory := Dictionary(profile.get("world_memory", {}))
	var archive_state := Dictionary(profile.get("archive_state", {}))
	var cookbook_state := Dictionary(profile.get("cookbook_state", {}))
	var experiment_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(profile.get("delvemind_experiment_state", {})))
	var recent_runs := _recent_runs(run_history, 8)
	var gameplay_snapshot := Dictionary(session_context.get("gameplay_snapshot", {}))
	return {
		"social_model": _social_model(profile, recent_runs, active_crawl, gameplay_snapshot),
		"route_model": _route_model(recent_runs, active_crawl, gameplay_snapshot),
		"ecology_model": _ecology_model(recent_runs, gameplay_snapshot),
		"economy_model": _economy_model(recent_runs, gameplay_snapshot),
		"cultural_model": _cultural_model(world_memory, archive_state, crawl_history, cookbook_state),
		"epoch_model": _epoch_model(world_memory),
		"doctrine_model": _doctrine_model(recent_runs, archive_state, world_memory),
		"session_model": _session_model(session_context, gameplay_snapshot),
		"experiment_state": experiment_state,
		"experiment_lines": DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.build_world_lines(experiment_state),
		"recent_runs": recent_runs,
		"active_crawl": active_crawl.duplicate(true),
		"world_focus": str(Dictionary(world_memory.get("fascination", {})).get("current_focus", "")),
		"world_phase": str(Dictionary(world_memory.get("fascination", {})).get("phase", "")),
		"archive_legends": Array(archive_state.get("legends", [])).size()
	}

static func _recent_runs(run_history: Array, limit: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var start := maxi(run_history.size() - limit, 0)
	for i in range(start, run_history.size()):
		result.append(Dictionary(run_history[i]))
	return result

static func _social_model(profile: Dictionary, recent_runs: Array[Dictionary], active_crawl: Dictionary, gameplay_snapshot: Dictionary) -> Dictionary:
	var rescue_expectation := 0
	var betrayal_heat := 0
	var fault_recurrence := 0
	var obligation_heat := 0
	for entry_raw in recent_runs:
		var entry: Dictionary = Dictionary(entry_raw)
		var diagnostics: Dictionary = Dictionary(entry.get("diagnostics", {}))
		var frame: Dictionary = Dictionary(entry.get("frame", {}))
		rescue_expectation += int(diagnostics.get("recovery_score", 0))
		betrayal_heat += int(diagnostics.get("confrontation_score", 0))
		fault_recurrence += Array(diagnostics.get("group_fault_lines", [])).size()
		if not str(frame.get("challenge_attention", "")).strip_edges().is_empty():
			obligation_heat += 1
	obligation_heat += _string_array(active_crawl.get("crawl_promises", [])).size()
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var persona: Dictionary = Dictionary(profile.get("persona_state", {}))
	var pairs: Dictionary = Dictionary(fabric.get("pairs", {}))
	var crews: Dictionary = Dictionary(fabric.get("crews", {}))
	var recent_pairs := _string_array(fabric.get("recent_pairs", []))
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	var alliance_stability := 0
	var trust_fragility := 0
	var friendship_pressure := 0
	var loyalty_pressure := 0
	var trust_lines: Array[String] = []
	for pair_key in recent_pairs.slice(0, mini(recent_pairs.size(), 3)):
		var pair: Dictionary = Dictionary(pairs.get(pair_key, {}))
		alliance_stability += int(pair.get("rescues", 0)) + int(pair.get("shared_burdens", 0)) + int(pair.get("mutual_extractions", 0))
		trust_fragility += int(pair.get("betrayals", 0)) + int(pair.get("refusals", 0)) + int(pair.get("near_misses", 0)) / 2
		friendship_pressure += int(pair.get("rescues", 0)) + int(pair.get("mutual_extractions", 0))
		loyalty_pressure += _string_array(pair.get("obligations", [])).size()
		var pair_read := str(pair.get("public_reputation", "")).strip_edges()
		var pair_lines := _string_array(pair.get("obligations", []))
		if not pair_read.is_empty():
			pair_lines.append(pair_read)
		trust_lines = _string_array(trust_lines + pair_lines)
	for crew_key in recent_crews.slice(0, mini(recent_crews.size(), 2)):
		var crew: Dictionary = Dictionary(crews.get(crew_key, {}))
		alliance_stability += int(crew.get("successful_pushes", 0)) + int(crew.get("recoveries", 0)) / 2
		trust_fragility += int(crew.get("collapse_moments", 0)) + int(crew.get("escalations", 0)) / 2
		friendship_pressure += int(crew.get("history_count", 0)) / 2
		loyalty_pressure += _string_array(crew.get("obligations", [])).size()
		var crew_read := str(crew.get("public_reputation", "")).strip_edges()
		var crew_lines := _string_array(crew.get("obligations", []))
		if not crew_read.is_empty():
			crew_lines.append(crew_read)
		trust_lines = _string_array(trust_lines + crew_lines)
	var public_expectations := _string_array(persona.get("public_expectations", []))
	loyalty_pressure += public_expectations.size() + _string_array(active_crawl.get("belief_pressure", [])).size()
	trust_lines = _string_array(trust_lines + public_expectations)
	return {
		"rescue_expectation": rescue_expectation,
		"betrayal_heat": betrayal_heat,
		"fault_recurrence": fault_recurrence,
		"obligation_heat": obligation_heat,
		"alliance_stability": alliance_stability,
		"trust_fragility": trust_fragility,
		"friendship_pressure": friendship_pressure,
		"loyalty_pressure": loyalty_pressure,
		"trust_lines": trust_lines,
		"group_signals": _string_array(Dictionary(gameplay_snapshot.get("group_model", {})).get("group_signals", []))
	}

static func _route_model(recent_runs: Array[Dictionary], active_crawl: Dictionary, gameplay_snapshot: Dictionary) -> Dictionary:
	var route_control := 0
	var rescue_geometry := 0
	var bottleneck_sensitivity := 0
	var loop_familiarity := 0
	for entry_raw in recent_runs:
		var diagnostics: Dictionary = Dictionary(Dictionary(entry_raw).get("diagnostics", {}))
		route_control += _string_array(diagnostics.get("territory_claims", [])).size()
		rescue_geometry += _string_array(diagnostics.get("recovery_ecology", [])).size()
		bottleneck_sensitivity += _string_array(diagnostics.get("load_bearing_places", [])).size()
		loop_familiarity += _string_array(diagnostics.get("within_run_echoes", [])).size()
	loop_familiarity += _string_array(active_crawl.get("build_memory", [])).size()
	return {
		"route_control": route_control,
		"rescue_geometry": rescue_geometry,
		"bottleneck_sensitivity": bottleneck_sensitivity,
		"loop_familiarity": loop_familiarity,
		"relay_stress": int(active_crawl.get("relay_stress", 0)),
		"relay_memory": _string_array(active_crawl.get("relay_memory", [])),
		"witness_network": _string_array(active_crawl.get("witness_network", [])),
		"relay_bottlenecks": _string_array(active_crawl.get("relay_bottlenecks", [])),
		"cohort_pressure": _string_array(active_crawl.get("cohort_pressure", [])),
		"rumor_shock": _string_array(active_crawl.get("rumor_shock", [])),
		"group_pressure": _string_array(Dictionary(gameplay_snapshot.get("group_model", {})).get("model_pressure", []))
	}

static func _ecology_model(recent_runs: Array[Dictionary], gameplay_snapshot: Dictionary) -> Dictionary:
	var presence_pressure := 0
	var anomaly_recurrence := 0
	var stalking_preference := 0
	for entry_raw in recent_runs:
		var diagnostics: Dictionary = Dictionary(Dictionary(entry_raw).get("diagnostics", {}))
		presence_pressure += _string_array(diagnostics.get("inhabitant_pressure", [])).size()
		anomaly_recurrence += int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0))
		if _string_array(diagnostics.get("inhabitant_pressure", [])).has("ghost pressure"):
			stalking_preference += 1
	return {
		"presence_pressure": presence_pressure + _string_array(gameplay_snapshot.get("inhabitant_pressure", [])).size(),
		"anomaly_recurrence": anomaly_recurrence,
		"stalking_preference": stalking_preference
	}

static func _economy_model(recent_runs: Array[Dictionary], gameplay_snapshot: Dictionary) -> Dictionary:
	var fallback_dependence := 0
	var austerity_tolerance := 0
	var burden_tolerance := 0
	var recovery_appetite := 0
	for entry_raw in recent_runs:
		var diagnostics: Dictionary = Dictionary(Dictionary(entry_raw).get("diagnostics", {}))
		var resource_pressure := _string_array(diagnostics.get("resource_pressure", []))
		fallback_dependence += resource_pressure.size()
		if resource_pressure.has("rope reserves") or resource_pressure.has("bomb reserves"):
			austerity_tolerance += 1
		if int(diagnostics.get("burden_score", 0)) >= 2:
			burden_tolerance += 1
		if int(diagnostics.get("recovery_score", 0)) >= 2:
			recovery_appetite += 1
	return {
		"fallback_dependence": fallback_dependence + _string_array(gameplay_snapshot.get("resource_pressure", [])).size(),
		"austerity_tolerance": austerity_tolerance,
		"burden_tolerance": burden_tolerance,
		"recovery_appetite": recovery_appetite
	}

static func _cultural_model(world_memory: Dictionary, archive_state: Dictionary, crawl_history: Array, cookbook_state: Dictionary) -> Dictionary:
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	var myth_field: Dictionary = Dictionary(world_memory.get("myth_field", {}))
	var gravity: Dictionary = Dictionary(world_memory.get("cultural_gravity", {}))
	var institutional_order: Dictionary = Dictionary(world_memory.get("institutional_order", {}))
	var epistemic_order: Dictionary = Dictionary(world_memory.get("epistemic_order", {}))
	var affective_climate: Dictionary = Dictionary(world_memory.get("affective_climate", {}))
	var ontology_state: Dictionary = Dictionary(world_memory.get("ontology_state", {}))
	var interpretation_network: Dictionary = Dictionary(world_memory.get("interpretation_network", {}))
	var order_tension: Dictionary = Dictionary(world_memory.get("order_tension", {}))
	var silence_doctrine: Dictionary = Dictionary(world_memory.get("silence_doctrine", {}))
	var cookbook_shadow: Dictionary = Dictionary(world_memory.get("cookbook_shadow", {}))
	var crawl_network_state: Dictionary = Dictionary(world_memory.get("crawl_network_state", {}))
	return {
		"myth_gravity": int(gravity.get("top_gravity", 0)),
		"overfit_risk": int(fascination.get("streak", 0)) + int(fascination.get("fatigue", 0)),
		"current_focus": str(fascination.get("current_focus", "")),
		"top_successor": Dictionary(myth_field.get("top_successor", {})).duplicate(true),
		"shorthand_density": Dictionary(archive_state.get("shorthand", {})).size(),
		"crawl_density": crawl_history.size(),
		"field_lines": _string_array(myth_field.get("active_lines", [])),
		"legitimacy_pressure": int(institutional_order.get("legitimacy_pressure", 0)),
		"taboo_heat": int(institutional_order.get("taboo_heat", 0)),
		"custody_pressure": int(institutional_order.get("custody_pressure", 0)),
		"burial_pressure": int(institutional_order.get("burial_pressure", 0)),
		"heresy_pressure": int(institutional_order.get("heresy_pressure", 0)),
		"institution_lines": _string_array(institutional_order.get("lines", [])),
		"taboo_lines": _string_array(institutional_order.get("taboo_lines", [])),
		"claim_lines": _string_array(institutional_order.get("claim_lines", [])),
		"orthodoxy_strength": int(epistemic_order.get("orthodoxy_strength", 0)),
		"revision_pressure": int(epistemic_order.get("revision_pressure", 0)),
		"false_canon_pressure": int(epistemic_order.get("false_canon_pressure", 0)),
		"semantic_drift": int(epistemic_order.get("semantic_drift", 0)),
		"forgery_pressure": int(epistemic_order.get("forgery_pressure", 0)),
		"dominant_tradition": str(epistemic_order.get("dominant_tradition", "")),
		"canon_lines": _string_array(epistemic_order.get("lines", [])),
		"drift_lines": _string_array(epistemic_order.get("drift_lines", [])),
		"forgery_lines": _string_array(epistemic_order.get("forgery_lines", [])),
		"dominant_age": str(affective_climate.get("dominant_age", "")),
		"shame_heat": int(affective_climate.get("shame_heat", 0)),
		"reverence_heat": int(affective_climate.get("reverence_heat", 0)),
		"paranoia_heat": int(affective_climate.get("paranoia_heat", 0)),
		"punitive_heat": int(affective_climate.get("punitive_heat", 0)),
		"melancholy_heat": int(affective_climate.get("melancholy_heat", 0)),
		"hope_heat": int(affective_climate.get("hope_heat", 0)),
		"martyr_pressure": int(affective_climate.get("martyr_pressure", 0)),
		"anti_martyr_pressure": int(affective_climate.get("anti_martyr_pressure", 0)),
		"ordinary_life_pressure": int(affective_climate.get("ordinary_life_pressure", 0)),
		"climate_lines": _string_array(affective_climate.get("lines", [])),
		"mourning_lines": _string_array(affective_climate.get("mourning_lines", [])),
		"labor_lines": _string_array(affective_climate.get("labor_lines", [])),
		"dominant_ontology": str(ontology_state.get("dominant_ontology", "")),
		"uncertainty_philosophy": str(ontology_state.get("uncertainty_philosophy", "")),
		"counterfactual_heat": int(ontology_state.get("counterfactual_heat", 0)),
		"ontology_lines": _string_array(ontology_state.get("lines", [])),
		"uncertainty_lines": _string_array(ontology_state.get("uncertainty_lines", [])),
		"echo_lines": _string_array(ontology_state.get("echo_lines", [])),
		"node_heat": int(interpretation_network.get("node_heat", 0)),
		"spread_heat": int(interpretation_network.get("spread_heat", 0)),
		"contradiction_heat": int(interpretation_network.get("contradiction_heat", 0)),
		"ritual_spread": int(interpretation_network.get("ritual_spread", 0)),
		"institutional_campaigns": int(interpretation_network.get("institutional_campaigns", 0)),
		"dominant_nodes": _string_array(interpretation_network.get("dominant_nodes", [])),
		"network_lines": _string_array(interpretation_network.get("lines", [])),
		"spread_lines": _string_array(interpretation_network.get("spread_lines", [])),
		"campaign_lines": _string_array(interpretation_network.get("campaign_lines", [])),
		"sacred_pressure": int(order_tension.get("sacred_pressure", 0)),
		"administrative_pressure": int(order_tension.get("administrative_pressure", 0)),
		"practical_pressure": int(order_tension.get("practical_pressure", 0)),
		"forbidden_site_pressure": int(order_tension.get("forbidden_site_pressure", 0)),
		"sacred_artifact_pressure": int(order_tension.get("sacred_artifact_pressure", 0)),
		"order_lines": _string_array(order_tension.get("lines", [])),
		"site_lines": _string_array(order_tension.get("site_lines", [])),
		"artifact_lines": _string_array(order_tension.get("artifact_lines", [])),
		"silence_pressure": int(silence_doctrine.get("silence_pressure", 0)),
		"unclassified_pressure": int(silence_doctrine.get("unclassified_pressure", 0)),
		"silence_lines": _string_array(silence_doctrine.get("lines", [])),
		"zone_lines": _string_array(silence_doctrine.get("zone_lines", [])),
		"cookbook_fragment_count": int(cookbook_state.get("fragment_count", 0)),
		"cookbook_holder_depth": int(cookbook_state.get("holder_depth", 0)),
		"cookbook_network_pressure": int(cookbook_state.get("network_pressure", 0)),
		"cookbook_redirection_pressure": int(cookbook_state.get("redirection_pressure", 0)),
		"cookbook_holder_state": str(cookbook_state.get("holder_state", "")),
		"cookbook_fragment_lines": _string_array(cookbook_state.get("fragment_lines", [])),
		"cookbook_marginalia_lines": _string_array(cookbook_state.get("marginalia_lines", [])),
		"cookbook_network_lines": _string_array(cookbook_state.get("network_lines", [])),
		"cookbook_fragment_heat": int(cookbook_shadow.get("fragment_heat", 0)),
		"cookbook_holder_rumor": int(cookbook_shadow.get("holder_rumor", 0)),
		"cookbook_network_rumor": int(cookbook_shadow.get("network_rumor", 0)),
		"cookbook_redirection_heat": int(cookbook_shadow.get("redirection_pressure", 0)),
		"cookbook_shadow_lines": _string_array(cookbook_shadow.get("lines", [])),
		"cookbook_rumor_lines": _string_array(cookbook_shadow.get("rumor_lines", [])),
		"cookbook_redirection_lines": _string_array(cookbook_shadow.get("redirection_lines", [])),
		"relay_memory_pressure": int(crawl_network_state.get("relay_stress", 0)),
		"witness_network_pressure": int(crawl_network_state.get("witness_pressure", 0)),
		"relay_bottleneck_pressure": int(crawl_network_state.get("bottleneck_pressure", 0)),
		"rumor_shock_pressure": int(crawl_network_state.get("rumor_shock", 0)),
		"cohort_pressure": int(crawl_network_state.get("cohort_pressure", 0)),
		"relay_lines": _string_array(crawl_network_state.get("lines", [])),
		"witness_lines": _string_array(crawl_network_state.get("witness_lines", [])),
		"bottleneck_lines": _string_array(crawl_network_state.get("bottleneck_lines", []))
	}

static func _epoch_model(world_memory: Dictionary) -> Dictionary:
	var epoch_state: Dictionary = Dictionary(world_memory.get("epoch_state", {}))
	return {
		"phase": str(epoch_state.get("phase", "")).strip_edges(),
		"transition_pressure": int(epoch_state.get("transition_pressure", 0)),
		"driver": str(epoch_state.get("driver", "")).strip_edges(),
		"lines": _string_array(epoch_state.get("lines", []))
	}

static func _doctrine_model(recent_runs: Array[Dictionary], archive_state: Dictionary, world_memory: Dictionary) -> Dictionary:
	var doctrine_counts := {}
	var delve_history: Dictionary = Dictionary(world_memory.get("delve_history", {}))
	for entry_raw in recent_runs:
		var diagnostics: Dictionary = Dictionary(Dictionary(entry_raw).get("diagnostics", {}))
		var doctrine := str(diagnostics.get("doctrine_family", "")).strip_edges()
		if doctrine.is_empty():
			continue
		doctrine_counts[doctrine] = int(doctrine_counts.get(doctrine, 0)) + 1
	var stale_doctrines: Array[String] = []
	for key in doctrine_counts.keys():
		if int(doctrine_counts.get(key, 0)) >= 3:
			stale_doctrines.append(str(key))
	for doctrine_id in _string_array(delve_history.get("abandoned_paradigms", [])):
		if not stale_doctrines.has(doctrine_id):
			stale_doctrines.append(doctrine_id)
	stale_doctrines.sort()
	return {
		"doctrine_counts": doctrine_counts,
		"stale_doctrines": stale_doctrines,
		"legend_pressure": Array(archive_state.get("legends", [])).size(),
		"world_focus": str(Dictionary(world_memory.get("fascination", {})).get("current_focus", "")),
		"dominant_method": str(delve_history.get("dominant_method", "")),
		"misclassification_pressure": int(delve_history.get("misclassification_pressure", 0)),
		"overcorrection_pressure": int(delve_history.get("overcorrection_pressure", 0)),
		"abandoned_paradigms": _string_array(delve_history.get("abandoned_paradigms", [])),
		"history_lines": _string_array(delve_history.get("history_lines", []))
	}

static func _session_model(session_context: Dictionary, gameplay_snapshot: Dictionary) -> Dictionary:
	var player_count := int(session_context.get("player_count", int(gameplay_snapshot.get("player_count", 0))))
	var build_identities := _string_array(gameplay_snapshot.get("build_identities", []))
	var group_model: Dictionary = Dictionary(gameplay_snapshot.get("group_model", {})).duplicate(true)
	var dominant_build := str(group_model.get("dominant_build", "")).strip_edges()
	var build_convergence := 0
	if player_count >= 2 and not dominant_build.is_empty():
		if build_identities.size() <= 1:
			build_convergence = 2
		elif build_identities.size() == 2:
			build_convergence = 1
	return {
		"player_count": player_count,
		"protocol_state": str(session_context.get("protocol_state", str(gameplay_snapshot.get("protocol_state", "")))),
		"build_identities": build_identities,
		"group_model": group_model,
		"dominant_build": dominant_build,
		"build_convergence": build_convergence
	}

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
