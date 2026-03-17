class_name CrawlService
extends RefCounted

const CRAWL_HISTORY_LIMIT := 18
const FRAMING_SERVICE_SCRIPT = preload("res://src/product/framing_service.gd")

static func normalize_profile_fields(profile: Dictionary) -> void:
	if not profile.has("narrative_progress"):
		profile["narrative_progress"] = {
			"layer": "public",
			"core_reached": false,
			"post_core_flags": []
		}
	if not profile.has("active_crawl"):
		profile["active_crawl"] = {}
	if not profile.has("crawl_history"):
		profile["crawl_history"] = []
	if not profile.has("relationship_fabric"):
		profile["relationship_fabric"] = {
			"pairs": {},
			"players": {},
			"crews": {},
			"recent_pairs": [],
			"recent_crews": []
		}
	if not profile.has("persona_state"):
		profile["persona_state"] = {
			"archetype_scores": {},
			"risk_posture": {},
			"public_expectations": []
		}

static func apply_run(profile: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> Dictionary:
	normalize_profile_fields(profile)
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	if active_crawl.is_empty():
		active_crawl = _new_crawl(profile, run_record, diagnostics, frame)
	var run_count := int(active_crawl.get("run_count", 0)) + 1
	active_crawl["run_count"] = run_count
	active_crawl["latest_seed"] = int(run_record.get("seed", 0))
	active_crawl["latest_role"] = str(run_record.get("local_role", ""))
	active_crawl["latest_finish_identity"] = str(frame.get("finish_identity", ""))
	active_crawl["public_heat"] = clampi(int(active_crawl.get("public_heat", 0)) + int(frame.get("public_heat", 0)) / 2, 0, 12)
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	var challenge_attention := str(frame.get("challenge_attention", "")).strip_edges()
	var counter_readings := _string_array(frame.get("counter_readings", []))
	var build_identity := str(diagnostics.get("build_identity", "")).strip_edges()
	var build_scores := Dictionary(diagnostics.get("build_scores", {}))
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var build_pressure := str(frame.get("build_line", "")).strip_edges()
	var gameplay_feature_signals := _string_array(diagnostics.get("gameplay_feature_signals", []))
	var gameplay_group_signals := _string_array(diagnostics.get("gameplay_group_signals", []))
	var model_pressure := _string_array(diagnostics.get("model_pressure", []))
	var group_fault_lines := _string_array(diagnostics.get("group_fault_lines", []))
	var crew_hooks := _string_array(diagnostics.get("crew_hooks", []))
	var resource_pressure := _string_array(diagnostics.get("resource_pressure", []))
	var inhabitant_pressure := _string_array(diagnostics.get("inhabitant_pressure", []))
	var protocol_hooks := _string_array(diagnostics.get("protocol_hooks", []))
	var ritual_hooks := _string_array(diagnostics.get("ritual_hooks", []))
	var belief_state: Dictionary = Dictionary(diagnostics.get("belief_state", {}))
	var counterfactual_lines := _string_array(diagnostics.get("counterfactual_pressure", []))
	var curriculum_lines := _string_array(diagnostics.get("hidden_curriculum", []))
	var anomaly_signals := _string_array(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("signals", []))
	var ecology_signal_highlights := _string_array(diagnostics.get("ecology_signal_highlights", []))
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var doctrine_family := str(diagnostics.get("doctrine_family", "")).strip_edges()
	var doctrine_label := str(diagnostics.get("doctrine_label", "")).strip_edges()
	var doctrine_pressure_line := str(diagnostics.get("doctrine_pressure_line", "")).strip_edges()
	var doctrine_world_goal := str(diagnostics.get("doctrine_world_goal", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var artifact_lineage_hints := _string_array(diagnostics.get("artifact_lineage_hints", []))
	var artifact_branch_markers := _string_array(diagnostics.get("artifact_branch_markers", []))
	var artifact_memory_hints := _string_array(diagnostics.get("artifact_memory_hints", []))
	var artifact_prestige_indicators := _string_array(diagnostics.get("artifact_prestige_indicators", []))
	var artifact_cultural_association := str(diagnostics.get("artifact_cultural_association", "")).strip_edges()
	var branch_caution_markers := _string_array(diagnostics.get("branch_caution_markers", []))
	var branch_reputation_drift := str(diagnostics.get("branch_reputation_drift", "")).strip_edges()
	var belief_lines := _string_array([
		str(belief_state.get("rescue_answer", "")),
		str(belief_state.get("fault_line", "")),
		str(belief_state.get("collapse_line", "")),
		str(belief_state.get("myth_attractor", "")),
		str(belief_state.get("attention_sink", ""))
	])
	active_crawl["risk_stake"] = clampi(
		int(active_crawl.get("risk_stake", 0))
		+ Array(diagnostics.get("quest_pressure", [])).size()
		+ int(diagnostics.get("near_miss_score", 0))
		+ (2 if not challenge_attention.is_empty() else 0)
		+ (1 if not counter_readings.is_empty() else 0)
		+ (1 if Array(diagnostics.get("quest_collisions", [])).size() >= 1 else 0)
		+ (1 if not counterfactual_lines.is_empty() else 0)
		+ (1 if not belief_lines.is_empty() else 0)
		+ (1 if not curriculum_lines.is_empty() else 0),
		0,
		24
	)
	if not model_pressure.is_empty():
		active_crawl["risk_stake"] = clampi(int(active_crawl.get("risk_stake", 0)) + 1, 0, 24)
	if not group_fault_lines.is_empty():
		active_crawl["risk_stake"] = clampi(int(active_crawl.get("risk_stake", 0)) + 1, 0, 24)
	if not build_identity.is_empty():
		active_crawl["risk_stake"] = clampi(int(active_crawl.get("risk_stake", 0)) + 1, 0, 24)
	if not resource_pressure.is_empty():
		active_crawl["risk_stake"] = clampi(int(active_crawl.get("risk_stake", 0)) + 1, 0, 24)
	if not inhabitant_pressure.is_empty():
		active_crawl["risk_stake"] = clampi(int(active_crawl.get("risk_stake", 0)) + 1, 0, 24)
	active_crawl["bank_pressure"] = clampi(
		int(active_crawl.get("bank_pressure", 0))
		+ (2 if int(diagnostics.get("recovery_score", 0)) >= 2 else 0)
		+ (2 if str(diagnostics.get("momentum_profile", "")) in ["coming_together", "steadying", "stabilizing"] else 0)
		+ (1 if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"] else 0),
		0,
		14
	)
	active_crawl["push_pressure"] = clampi(
		int(active_crawl.get("push_pressure", 0))
		+ int(diagnostics.get("spectacle_pressure", 0))
		+ int(diagnostics.get("near_miss_score", 0))
		+ (1 if not ritual_pressure.is_empty() else 0)
		+ (2 if str(frame.get("status_valence", "")) in ["Almost", "Scandal", "Infamy"] else 0),
		0,
		14
	)
	if not inhabitant_pressure.is_empty():
		active_crawl["push_pressure"] = clampi(int(active_crawl.get("push_pressure", 0)) + 1, 0, 14)
	active_crawl["signature_tags"] = _merge_limited(
		Array(active_crawl.get("signature_tags", [])),
		Array(frame.get("story_axes", []))
		+ Array(diagnostics.get("quest_pressure", []))
		+ Array(diagnostics.get("room_identity_highlights", []))
		+ Array(diagnostics.get("run_shapes", []))
		+ Array(frame.get("commentary_lanes", []))
		+ model_pressure
		+ gameplay_group_signals
		+ ([build_identity] if not build_identity.is_empty() else [])
		+ resource_pressure
		+ inhabitant_pressure
		+ protocol_hooks
		+ artifact_branch_markers
		+ artifact_prestige_indicators
		+ ([branch_reputation_drift] if not branch_reputation_drift.is_empty() else [])
		+ ([doctrine_family] if not doctrine_family.is_empty() else [])
		+ ([doctrine_label] if not doctrine_label.is_empty() else []),
		12
	)
	active_crawl["turning_points"] = _merge_limited(
		Array(active_crawl.get("turning_points", [])),
		Array(diagnostics.get("run_changing_moments", [])) + Array(diagnostics.get("spectacle_windows", [])),
		10
	)
	active_crawl["breaking_points"] = _merge_limited(
		Array(active_crawl.get("breaking_points", [])),
		Array(diagnostics.get("expectation_breaks", [])) + Array(diagnostics.get("spectacle_windows", [])),
		6
	)
	active_crawl["open_questions"] = _merge_limited(
		Array(active_crawl.get("open_questions", [])),
		Array(frame.get("open_questions", [])) + Array(diagnostics.get("anticipation_hooks", [])) + Array(diagnostics.get("pressure_persistence", [])),
		3
	)
	active_crawl["atmosphere_history"] = _push_front_limited(Array(active_crawl.get("atmosphere_history", [])), str(diagnostics.get("atmosphere", "")), 6)
	active_crawl["momentum_history"] = _push_front_limited(Array(active_crawl.get("momentum_history", [])), str(diagnostics.get("momentum_profile", "")), 6)
	active_crawl["finish_history"] = _push_front_limited(Array(active_crawl.get("finish_history", [])), str(frame.get("finish_identity", "")), 6)
	active_crawl["quest_history"] = _merge_limited(Array(active_crawl.get("quest_history", [])), Array(frame.get("quest_briefs", [])), 8)
	active_crawl["residue"] = _merge_limited(
		Array(active_crawl.get("residue", [])),
		Array(diagnostics.get("pressure_persistence", []))
		+ Array(diagnostics.get("within_run_echoes", []))
		+ Array(frame.get("counter_readings", []))
		+ Array(diagnostics.get("quest_collisions", []))
		+ Array(diagnostics.get("ritual_recurrence", []))
		+ model_pressure
		+ group_fault_lines
		+ resource_pressure
		+ inhabitant_pressure
		+ artifact_memory_hints
		+ branch_caution_markers
		+ ([doctrine_pressure_line] if not doctrine_pressure_line.is_empty() else [])
		+ ([governance_line] if not governance_line.is_empty() else []),
		10
	)
	active_crawl["unfinished_pressure"] = _merge_limited(
		Array(active_crawl.get("unfinished_pressure", [])),
		Array(diagnostics.get("pressure_persistence", []))
		+ Array(diagnostics.get("quest_collisions", []))
		+ Array(frame.get("counter_readings", []))
		+ Array(diagnostics.get("anticipation_hooks", []))
		+ counterfactual_lines
		+ belief_lines
		+ model_pressure
		+ group_fault_lines
		+ resource_pressure
		+ inhabitant_pressure
		+ artifact_memory_hints
		+ branch_caution_markers
		+ ([doctrine_pressure_line] if not doctrine_pressure_line.is_empty() else [])
		+ ([governance_line] if not governance_line.is_empty() else []),
		10
	)
	active_crawl["memorial_residue"] = _merge_limited(
		Array(active_crawl.get("memorial_residue", [])),
		Array(diagnostics.get("run_changing_moments", []))
		+ Array(diagnostics.get("spectacle_windows", []))
		+ Array(diagnostics.get("expectation_breaks", []))
		+ Array(diagnostics.get("quest_collisions", [])),
		8
	)
	active_crawl["status_valence"] = str(frame.get("status_valence", "Noted"))
	active_crawl["stage"] = _crawl_stage(active_crawl)
	active_crawl["title"] = _crawl_title(active_crawl, diagnostics, frame)
	active_crawl["run_shape"] = _first_string(Array(diagnostics.get("run_shapes", [])), "Run pattern")
	active_crawl["expectation_pressure"] = _crawl_expectation(active_crawl, diagnostics, frame)
	active_crawl["crew_key"] = _crew_key(run_record)
	active_crawl["last_resolution"] = _resolution_state(frame, diagnostics)
	active_crawl["bank_vs_push_state"] = _bank_push_state(active_crawl, frame)
	active_crawl["ending_hint"] = _ending_label(run_record, diagnostics, frame)
	active_crawl["obligation_residue"] = _merge_limited(
		Array(active_crawl.get("obligation_residue", [])),
		Array(frame.get("quest_briefs", [])) + Array(frame.get("counter_readings", [])),
		8
	)
	active_crawl["crawl_identity"] = _merge_limited(
		Array(active_crawl.get("crawl_identity", [])),
		Array(frame.get("story_axes", []))
		+ Array(diagnostics.get("run_shapes", []))
		+ Array(diagnostics.get("symbolic_gestures", []))
		+ Array(diagnostics.get("ritual_recurrence", []))
		+ artifact_lineage_hints
		+ artifact_branch_markers
		+ curriculum_lines
		+ model_pressure
		+ ([protocol_state] if not protocol_state.is_empty() else [])
		+ ([build_identity] if not build_identity.is_empty() else [])
		+ ([artifact_cultural_association] if not artifact_cultural_association.is_empty() else [])
		+ protocol_hooks,
		10
	)
	active_crawl["crawl_promises"] = _merge_limited(
		Array(active_crawl.get("crawl_promises", [])),
		Array(frame.get("quest_briefs", []))
		+ Array(diagnostics.get("recovery_ecology", []))
		+ Array(diagnostics.get("pressure_persistence", []))
		+ artifact_memory_hints
		+ curriculum_lines
		+ model_pressure
		+ ritual_hooks
		+ resource_pressure,
		8
	)
	active_crawl["crawl_rivalries"] = _merge_limited(
		Array(active_crawl.get("crawl_rivalries", [])),
		Array(diagnostics.get("quest_collisions", []))
		+ Array(diagnostics.get("expectation_breaks", []))
		+ ([str(diagnostics.get("social_temperature", "")).replace("_", " ")] if str(diagnostics.get("social_temperature", "")).find("rival") != -1 else [])
		+ ([branch_reputation_drift] if not branch_reputation_drift.is_empty() else [])
		+ ([str(belief_state.get("fault_line", ""))] if not str(belief_state.get("fault_line", "")).strip_edges().is_empty() else []),
		6
	)
	active_crawl["belief_pressure"] = _merge_limited(Array(active_crawl.get("belief_pressure", [])), belief_lines, 6)
	active_crawl["fault_memory"] = _merge_limited(Array(active_crawl.get("fault_memory", [])), group_fault_lines, 6)
	active_crawl["curriculum_pressure"] = _merge_limited(Array(active_crawl.get("curriculum_pressure", [])), curriculum_lines, 4)
	active_crawl["anomaly_pressure"] = _merge_limited(Array(active_crawl.get("anomaly_pressure", [])), anomaly_signals, 4)
	active_crawl["model_memory"] = _merge_limited(Array(active_crawl.get("model_memory", [])), model_pressure, 6)
	active_crawl["feature_memory"] = _merge_limited(
		Array(active_crawl.get("feature_memory", [])),
		artifact_prestige_indicators
		+ ([artifact_cultural_association] if not artifact_cultural_association.is_empty() else [])
		+ gameplay_feature_signals
		+ gameplay_group_signals,
		8
	)
	active_crawl["protocol_memory"] = _push_front_limited(Array(active_crawl.get("protocol_memory", [])), protocol_state, 4)
	active_crawl["doctrine_memory"] = _merge_limited(
		Array(active_crawl.get("doctrine_memory", [])),
		([doctrine_label] if not doctrine_label.is_empty() else []) + ([doctrine_pressure_line] if not doctrine_pressure_line.is_empty() else []),
		6
	)
	active_crawl["governance_memory"] = _merge_limited(
		Array(active_crawl.get("governance_memory", [])),
		([doctrine_world_goal] if not doctrine_world_goal.is_empty() else []) + ([governance_line] if not governance_line.is_empty() else []),
		6
	)
	active_crawl["build_memory"] = _merge_limited(
		Array(active_crawl.get("build_memory", [])),
		([build_identity] if not build_identity.is_empty() else []) + ([build_pressure] if not build_pressure.is_empty() else []) + _build_memory_lines(build_scores),
		6
	)
	var stability_line := ""
	if not build_stability.is_empty() and not risk_profile.is_empty():
		stability_line = "%s / %s" % [build_stability, risk_profile]
	elif not build_stability.is_empty():
		stability_line = build_stability
	else:
		stability_line = risk_profile
	active_crawl["stability_memory"] = _push_front_limited(
		Array(active_crawl.get("stability_memory", [])),
		stability_line,
		4
	)
	active_crawl["resource_memory"] = _merge_limited(Array(active_crawl.get("resource_memory", [])), resource_pressure, 6)
	active_crawl["inhabitant_memory"] = _merge_limited(Array(active_crawl.get("inhabitant_memory", [])), ecology_signal_highlights + inhabitant_pressure, 6)
	if protocol_state == "Expedition Protocol":
		active_crawl["relay_stress"] = clampi(
			int(active_crawl.get("relay_stress", 0))
			+ 1
			+ (1 if int(Dictionary(run_record.get("communication_summary", {})).get("total", 0)) >= 4 else 0)
			+ (1 if int(frame.get("public_heat", 0)) >= 6 else 0),
			0,
			18
		)
		active_crawl["relay_memory"] = _merge_limited(
			Array(active_crawl.get("relay_memory", [])),
			["multiple crews are now pressing on the same crawl line"]
			+ branch_caution_markers
			+ model_pressure,
			6
		)
		if int(Dictionary(run_record.get("communication_summary", {})).get("total", 0)) >= 4 or Array(diagnostics.get("pair_keys", [])).size() >= 2:
			active_crawl["witness_network"] = _merge_limited(
				Array(active_crawl.get("witness_network", [])),
				["distributed witnesses are now carrying different parts of the same story"]
				+ belief_lines
				+ gameplay_group_signals,
				6
			)
		if int(active_crawl.get("risk_stake", 0)) >= 8 or Array(diagnostics.get("load_bearing_places", [])).size() >= 2:
			active_crawl["relay_bottlenecks"] = _merge_limited(
				Array(active_crawl.get("relay_bottlenecks", [])),
				["the crawl is starting to bottleneck around a few overloaded passages"]
				+ branch_caution_markers,
				6
			)
		if not group_fault_lines.is_empty() or not crew_hooks.is_empty():
			active_crawl["cohort_pressure"] = _merge_limited(
				Array(active_crawl.get("cohort_pressure", [])),
				["sub-cohorts are beginning to carry different duties through the same crawl"]
				+ crew_hooks
				+ group_fault_lines,
				6
			)
		if not counter_readings.is_empty() or not belief_lines.is_empty():
			active_crawl["rumor_shock"] = _merge_limited(
				Array(active_crawl.get("rumor_shock", [])),
				["rumor is starting to outrun proof across the wider expedition memory"]
				+ counter_readings
				+ belief_lines,
				6
			)
	active_crawl["public_challenge"] = _public_challenge(active_crawl, diagnostics, frame)
	active_crawl["promise_pressure"] = _promise_pressure(active_crawl, diagnostics, frame)
	profile["active_crawl"] = active_crawl
	_update_relationship_fabric(profile, run_record, diagnostics, frame)
	_update_persona_state(profile, diagnostics, frame)
	var archived := false
	if _should_archive_crawl(active_crawl, run_record, diagnostics, frame):
		var crawl_history: Array = Array(profile.get("crawl_history", []))
		crawl_history.push_front(_archive_entry(active_crawl, run_record, diagnostics, frame))
		profile["crawl_history"] = crawl_history.slice(0, CRAWL_HISTORY_LIMIT)
		profile["active_crawl"] = {}
		archived = true
	return {
		"active_crawl": Dictionary(profile.get("active_crawl", {})).duplicate(true),
		"archived": archived,
		"crawl_packet": active_crawl.duplicate(true),
		"relationship_fabric": Dictionary(profile.get("relationship_fabric", {})).duplicate(true),
		"persona_state": Dictionary(profile.get("persona_state", {})).duplicate(true)
	}

static func build_active_crawl_lines(profile: Dictionary) -> Array[String]:
	normalize_profile_fields(profile)
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	if active_crawl.is_empty():
		var carryover_lines: Array[String] = ["Current crawl: between sagas."]
		var crawl_history := _dict_array(profile.get("crawl_history", []))
		if not crawl_history.is_empty():
			var latest: Dictionary = crawl_history[0]
			var memorial := _first_string(_string_array(latest.get("memorial_residue", [])), "")
			var belief := _first_string(_string_array(latest.get("belief_pressure", [])), "")
			var model := _first_string(_string_array(latest.get("model_memory", [])), "")
			var fault := _first_string(_string_array(latest.get("fault_memory", [])), "")
			var curriculum := _first_string(_string_array(latest.get("curriculum_pressure", [])), "")
			var anomaly := _first_string(_string_array(latest.get("anomaly_pressure", [])), "")
			var doctrine := _first_string(_string_array(latest.get("doctrine_memory", [])), "")
			var governance := _first_string(_string_array(latest.get("governance_memory", [])), "")
			if not memorial.is_empty():
				carryover_lines.append("Memorial pull: %s" % memorial)
			if not belief.is_empty():
				carryover_lines.append("Belief: %s" % belief)
			if not model.is_empty():
				carryover_lines.append("Answer shape: %s" % model)
			if not fault.is_empty():
				carryover_lines.append("Fault line: %s" % fault)
			if not curriculum.is_empty():
				carryover_lines.append("Lesson: %s" % curriculum)
			if not anomaly.is_empty():
				carryover_lines.append("Uneasy pull: %s" % anomaly)
			if not doctrine.is_empty():
				carryover_lines.append("Doctrine: %s" % doctrine)
			if not governance.is_empty():
				carryover_lines.append("Governance: %s" % governance)
		return FRAMING_SERVICE_SCRIPT.guard_lines(carryover_lines)
	var lines: Array[String] = []
	lines.append("Current crawl: %s" % str(active_crawl.get("title", "Active crawl")))
	lines.append("Stage: %s | Heat: %d | Stake: %d" % [_title_case(str(active_crawl.get("stage", "forming"))), int(active_crawl.get("public_heat", 0)), int(active_crawl.get("risk_stake", 0))])
	var questions := _string_array(active_crawl.get("open_questions", []))
	if not questions.is_empty():
		lines.append("Open: %s" % questions[0])
	lines.append("Bank vs push: %d / %d" % [int(active_crawl.get("bank_pressure", 0)), int(active_crawl.get("push_pressure", 0))])
	var state := str(active_crawl.get("bank_vs_push_state", "")).strip_edges()
	if not state.is_empty():
		lines.append("Decision pull: %s" % _title_case(state.replace("_", " ")))
	var expectation := str(active_crawl.get("expectation_pressure", "")).strip_edges()
	if not expectation.is_empty():
		lines.append("Pressure: %s" % expectation)
	var residue := _string_array(active_crawl.get("residue", []))
	if not residue.is_empty():
		lines.append("Residue: %s" % residue[0])
	var memorial := _string_array(active_crawl.get("memorial_residue", []))
	if not memorial.is_empty():
		lines.append("Memorial pull: %s" % memorial[0])
	if memorial.size() >= 2:
		lines.append("Historical weight: %s memory points are still hanging over this crawl." % memorial[0])
	var obligation := _string_array(active_crawl.get("obligation_residue", []))
	if not obligation.is_empty():
		lines.append("Debt: %s" % obligation[0])
	var unfinished := _string_array(active_crawl.get("unfinished_pressure", []))
	if not unfinished.is_empty():
		lines.append("Unfinished: %s" % unfinished[0])
	var public_challenge := str(active_crawl.get("public_challenge", "")).strip_edges()
	if not public_challenge.is_empty():
		lines.append("Challenge: %s" % public_challenge)
	var promise_pressure := str(active_crawl.get("promise_pressure", "")).strip_edges()
	if not promise_pressure.is_empty():
		lines.append("Promise: %s" % promise_pressure)
	var doctrine_bits := _string_array(active_crawl.get("doctrine_memory", []))
	if not doctrine_bits.is_empty():
		lines.append("Doctrine: %s" % doctrine_bits[0])
	var governance_bits := _string_array(active_crawl.get("governance_memory", []))
	if not governance_bits.is_empty():
		lines.append("Governance: %s" % governance_bits[0])
	var build_bits := _string_array(active_crawl.get("build_memory", []))
	if not build_bits.is_empty():
		lines.append("Build: %s" % build_bits[0])
	var stability_bits := _string_array(active_crawl.get("stability_memory", []))
	if not stability_bits.is_empty():
		lines.append("Stability: %s" % stability_bits[0])
	var feature_bits := _string_array(active_crawl.get("feature_memory", []))
	if not feature_bits.is_empty():
		lines.append("Artifact echo: %s" % feature_bits[0])
	var resource_bits := _string_array(active_crawl.get("resource_memory", []))
	if not resource_bits.is_empty():
		lines.append("Resource pull: %s" % resource_bits[0])
	var inhabitant_bits := _string_array(active_crawl.get("inhabitant_memory", []))
	if not inhabitant_bits.is_empty():
		lines.append("Presence: %s" % inhabitant_bits[0])
	var identity_bits := _string_array(active_crawl.get("crawl_identity", []))
	if not identity_bits.is_empty():
		lines.append("Identity: %s" % identity_bits[0])
	var belief_bits := _string_array(active_crawl.get("belief_pressure", []))
	if not belief_bits.is_empty():
		lines.append("Belief: %s" % belief_bits[0])
	var model_bits := _string_array(active_crawl.get("model_memory", []))
	if not model_bits.is_empty():
		lines.append("Answer shape: %s" % model_bits[0])
	var fault_bits := _string_array(active_crawl.get("fault_memory", []))
	if not fault_bits.is_empty():
		lines.append("Fault line: %s" % fault_bits[0])
	var rivalry_bits := _string_array(active_crawl.get("crawl_rivalries", []))
	if not rivalry_bits.is_empty():
		lines.append("Rivalry: %s" % rivalry_bits[0])
	var curriculum_bits := _string_array(active_crawl.get("curriculum_pressure", []))
	if not curriculum_bits.is_empty():
		lines.append("Lesson: %s" % curriculum_bits[0])
	var anomaly_bits := _string_array(active_crawl.get("anomaly_pressure", []))
	if not anomaly_bits.is_empty():
		lines.append("Uneasy pull: %s" % anomaly_bits[0])
	var ending_hint := str(active_crawl.get("ending_hint", "")).strip_edges()
	if not ending_hint.is_empty():
		lines.append("If it ends now: %s" % ending_hint)
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func build_crawl_entries(profile: Dictionary) -> Array[Dictionary]:
	normalize_profile_fields(profile)
	var entries: Array[Dictionary] = []
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	if not active_crawl.is_empty():
		entries.append({
			"id": str(active_crawl.get("crawl_id", "active")),
			"label": "Active | %s" % str(active_crawl.get("title", "Current crawl")),
			"detail": "\n".join(build_active_crawl_lines(profile)),
			"discovered": true
		})
	for crawl_raw in Array(profile.get("crawl_history", [])):
		var crawl: Dictionary = Dictionary(crawl_raw)
		entries.append({
			"id": str(crawl.get("crawl_id", "")),
			"label": "%s | %s" % [_title_case(str(crawl.get("stage", "legend"))), str(crawl.get("title", "Past crawl"))],
			"detail": FRAMING_SERVICE_SCRIPT.guard_text(_crawl_detail(crawl)),
			"discovered": true
		})
	return entries

static func build_relationship_entries(profile: Dictionary) -> Array[Dictionary]:
	normalize_profile_fields(profile)
	var entries: Array[Dictionary] = []
	var players: Dictionary = Dictionary(Dictionary(profile.get("relationship_fabric", {})).get("players", {}))
	for player_key in players.keys():
		var player_entry: Dictionary = Dictionary(players.get(player_key, {}))
		entries.append({
			"id": "player:%s" % str(player_key),
			"label": "%s | %s" % [str(player_entry.get("display_name", player_key)), str(player_entry.get("title", "Remembered delver"))],
			"detail": FRAMING_SERVICE_SCRIPT.guard_text(_relationship_detail(player_entry)),
			"discovered": true
		})
	var pairs: Dictionary = Dictionary(Dictionary(profile.get("relationship_fabric", {})).get("pairs", {}))
	for pair_key in pairs.keys():
		var pair: Dictionary = Dictionary(pairs.get(pair_key, {}))
		entries.append({
			"id": str(pair_key),
			"label": "%s | %s" % [str(pair.get("display_label", _pair_label(str(pair_key)))), str(pair.get("title", "Pair echo"))],
			"detail": FRAMING_SERVICE_SCRIPT.guard_text(_relationship_detail(pair)),
			"discovered": true
		})
	var crews: Dictionary = Dictionary(Dictionary(profile.get("relationship_fabric", {})).get("crews", {}))
	for crew_key in crews.keys():
		var crew: Dictionary = Dictionary(crews.get(crew_key, {}))
		entries.append({
			"id": "crew:%s" % str(crew_key),
			"label": "%s | %s" % [str(crew.get("display_label", _crew_label(str(crew_key)))), str(crew.get("title", "Crew echo"))],
			"detail": FRAMING_SERVICE_SCRIPT.guard_text(_relationship_detail(crew)),
			"discovered": true
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("label", "")) < str(b.get("label", ""))
	)
	if entries.is_empty():
		entries.append({
			"id": "relationships:none",
			"label": "No strong relationship echoes yet",
			"detail": "Repeat rescues, hesitations, handoffs, and confrontations start building relationship memory here.",
			"discovered": true
		})
	return entries

static func build_persona_lines(profile: Dictionary) -> Array[String]:
	normalize_profile_fields(profile)
	var persona: Dictionary = Dictionary(profile.get("persona_state", {}))
	var scores: Dictionary = Dictionary(persona.get("archetype_scores", {}))
	var sorted_keys: Array[String] = []
	for key in scores.keys():
		sorted_keys.append(str(key))
	sorted_keys.sort_custom(func(a: String, b: String) -> bool:
		return int(scores.get(a, 0)) > int(scores.get(b, 0))
	)
	if sorted_keys.is_empty():
		return ["Persona: still forming."]
	var lines: Array[String] = []
	for key in sorted_keys.slice(0, mini(sorted_keys.size(), 3)):
		lines.append("Persona: %s (%d)" % [_title_case(key.replace("_", " ")), int(scores.get(key, 0))])
	return lines

static func _new_crawl(profile: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> Dictionary:
	var history: Array = Array(profile.get("crawl_history", []))
	var crawl_number := history.size() + 1
	return {
		"crawl_id": "crawl_%03d" % crawl_number,
		"title": _crawl_title({}, diagnostics, frame),
		"run_count": 0,
		"public_heat": 0,
		"risk_stake": 0,
		"bank_pressure": 0,
		"push_pressure": 0,
		"stage": "forming",
		"signature_tags": [],
		"turning_points": [],
		"breaking_points": [],
		"open_questions": [],
		"atmosphere_history": [],
		"momentum_history": [],
		"finish_history": [],
		"quest_history": [],
		"residue": [],
		"unfinished_pressure": [],
		"memorial_residue": [],
		"obligation_residue": [],
		"crawl_identity": [],
		"crawl_promises": [],
		"crawl_rivalries": [],
		"belief_pressure": [],
		"fault_memory": [],
		"curriculum_pressure": [],
		"anomaly_pressure": [],
		"model_memory": [],
		"feature_memory": [],
		"protocol_memory": [],
		"doctrine_memory": [],
		"governance_memory": [],
		"build_memory": [],
		"stability_memory": [],
		"resource_memory": [],
		"inhabitant_memory": [],
		"relay_stress": 0,
		"relay_memory": [],
		"witness_network": [],
		"relay_bottlenecks": [],
		"cohort_pressure": [],
		"rumor_shock": [],
		"status_valence": "Noted",
		"latest_seed": int(run_record.get("seed", 0)),
		"latest_role": str(run_record.get("local_role", "")),
		"run_shape": "",
		"crew_key": _crew_key(run_record),
		"expectation_pressure": "",
		"last_resolution": "open"
	}

static func _crawl_stage(active_crawl: Dictionary) -> String:
	var run_count := int(active_crawl.get("run_count", 0))
	var heat := int(active_crawl.get("public_heat", 0))
	var risk_stake := int(active_crawl.get("risk_stake", 0))
	if run_count >= 4 or heat >= 8 or risk_stake >= 10:
		return "legible"
	if run_count >= 2 or heat >= 4 or risk_stake >= 5:
		return "patterned"
	return "forming"

static func _crawl_title(active_crawl: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> String:
	var atmosphere := _title_case(str(diagnostics.get("atmosphere", "steady")).replace("_", " "))
	var momentum := _title_case(str(diagnostics.get("momentum_profile", "steadying")).replace("_", " "))
	var valence := str(frame.get("status_valence", "Noted"))
	if not str(active_crawl.get("title", "")).strip_edges().is_empty() and int(active_crawl.get("run_count", 0)) >= 1:
		return str(active_crawl.get("title", ""))
	return "%s %s crawl" % [atmosphere, "%s-%s" % [momentum.to_lower(), valence.to_lower()]]

static func _should_archive_crawl(active_crawl: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> bool:
	var run_count := int(active_crawl.get("run_count", 0))
	if run_count < 3:
		return false
	if str(active_crawl.get("bank_vs_push_state", "")) == "bank_now" and int(active_crawl.get("risk_stake", 0)) >= 6:
		return true
	if str(active_crawl.get("bank_vs_push_state", "")) == "hold_together" and run_count >= 4:
		return true
	if not str(active_crawl.get("public_challenge", "")).strip_edges().is_empty() and run_count >= 4:
		return true
	if int(active_crawl.get("bank_pressure", 0)) >= 8 and int(active_crawl.get("push_pressure", 0)) <= 4:
		return true
	if int(active_crawl.get("risk_stake", 0)) >= 12 and Array(active_crawl.get("memorial_residue", [])).size() >= 2:
		return true
	if int(frame.get("legend_density_score", 0)) >= 9:
		return true
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	if bool(outcome_summary.get("expedition_success", false)) or bool(outcome_summary.get("sabotage_success", false)):
		return true
	if bool(run_record.get("interrupted", false)):
		return false
	return str(diagnostics.get("momentum_profile", "")) in ["collapsing_late", "coming_together", "steadying"]

static func _archive_entry(active_crawl: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> Dictionary:
	return {
		"crawl_id": str(active_crawl.get("crawl_id", "")),
		"title": str(active_crawl.get("title", "Past crawl")),
		"stage": str(active_crawl.get("stage", "legible")),
		"run_count": int(active_crawl.get("run_count", 0)),
		"public_heat": int(active_crawl.get("public_heat", 0)),
		"signature_tags": Array(active_crawl.get("signature_tags", [])).duplicate(),
		"turning_points": Array(active_crawl.get("turning_points", [])).duplicate(),
		"open_questions": Array(active_crawl.get("open_questions", [])).duplicate(),
		"atmosphere_history": Array(active_crawl.get("atmosphere_history", [])).duplicate(),
		"momentum_history": Array(active_crawl.get("momentum_history", [])).duplicate(),
		"status_valence": str(active_crawl.get("status_valence", "Noted")),
		"risk_stake": int(active_crawl.get("risk_stake", 0)),
		"breaking_points": Array(active_crawl.get("breaking_points", [])).duplicate(),
		"residue": Array(active_crawl.get("residue", [])).duplicate(),
		"memorial_residue": Array(active_crawl.get("memorial_residue", [])).duplicate(),
		"obligation_residue": Array(active_crawl.get("obligation_residue", [])).duplicate(),
		"unfinished_pressure": Array(active_crawl.get("unfinished_pressure", [])).duplicate(),
		"crawl_identity": Array(active_crawl.get("crawl_identity", [])).duplicate(),
		"crawl_promises": Array(active_crawl.get("crawl_promises", [])).duplicate(),
		"crawl_rivalries": Array(active_crawl.get("crawl_rivalries", [])).duplicate(),
		"belief_pressure": Array(active_crawl.get("belief_pressure", [])).duplicate(),
		"fault_memory": Array(active_crawl.get("fault_memory", [])).duplicate(),
		"curriculum_pressure": Array(active_crawl.get("curriculum_pressure", [])).duplicate(),
		"anomaly_pressure": Array(active_crawl.get("anomaly_pressure", [])).duplicate(),
		"model_memory": Array(active_crawl.get("model_memory", [])).duplicate(),
		"feature_memory": Array(active_crawl.get("feature_memory", [])).duplicate(),
		"protocol_memory": Array(active_crawl.get("protocol_memory", [])).duplicate(),
		"doctrine_memory": Array(active_crawl.get("doctrine_memory", [])).duplicate(),
		"governance_memory": Array(active_crawl.get("governance_memory", [])).duplicate(),
		"build_memory": Array(active_crawl.get("build_memory", [])).duplicate(),
		"stability_memory": Array(active_crawl.get("stability_memory", [])).duplicate(),
		"resource_memory": Array(active_crawl.get("resource_memory", [])).duplicate(),
		"inhabitant_memory": Array(active_crawl.get("inhabitant_memory", [])).duplicate(),
		"relay_stress": int(active_crawl.get("relay_stress", 0)),
		"relay_memory": Array(active_crawl.get("relay_memory", [])).duplicate(),
		"witness_network": Array(active_crawl.get("witness_network", [])).duplicate(),
		"relay_bottlenecks": Array(active_crawl.get("relay_bottlenecks", [])).duplicate(),
		"cohort_pressure": Array(active_crawl.get("cohort_pressure", [])).duplicate(),
		"rumor_shock": Array(active_crawl.get("rumor_shock", [])).duplicate(),
		"expectation_pressure": str(active_crawl.get("expectation_pressure", "")),
		"bank_vs_push_state": str(active_crawl.get("bank_vs_push_state", "")),
		"public_challenge": str(active_crawl.get("public_challenge", "")),
		"promise_pressure": str(active_crawl.get("promise_pressure", "")),
		"last_resolution": str(active_crawl.get("last_resolution", "")),
		"finish_identity": str(frame.get("finish_identity", "")),
		"ending": _ending_label(run_record, diagnostics, frame)
	}

static func _update_relationship_fabric(profile: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> void:
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var players: Dictionary = Dictionary(fabric.get("players", {}))
	var pairs: Dictionary = Dictionary(fabric.get("pairs", {}))
	var peer_identities: Dictionary = Dictionary(run_record.get("peer_identities", {}))
	for pair_key_variant in Array(diagnostics.get("pair_keys", [])):
		var pair_key := str(pair_key_variant)
		var pair: Dictionary = Dictionary(pairs.get(pair_key, {
			"title": "Recurring pair",
			"heat": 0,
			"signals": [],
			"obligations": [],
			"status_burden": "",
			"display_label": _pair_label(pair_key),
			"history_count": 0,
			"members": [],
			"rescues": 0,
			"refusals": 0,
			"shared_burdens": 0,
			"mutual_extractions": 0,
			"betrayals": 0,
			"near_misses": 0,
			"spectacle_moments": 0,
			"public_reputation": ""
		}))
		pair["heat"] = int(pair.get("heat", 0)) + 1
		pair["title"] = _pair_title(pair_key, diagnostics)
		pair["signals"] = _merge_limited(
			Array(pair.get("signals", [])),
			Array(diagnostics.get("social_beats_top", []))
			+ Array(diagnostics.get("symbolic_gestures", []))
			+ Array(diagnostics.get("quest_pressure", []))
			+ Array(diagnostics.get("recovery_ecology", []))
			+ Array(diagnostics.get("quest_collisions", []))
			+ ([str(diagnostics.get("build_identity", ""))] if not str(diagnostics.get("build_identity", "")).strip_edges().is_empty() else [])
			+ _string_array(diagnostics.get("gameplay_feature_signals", []))
			+ _string_array(diagnostics.get("gameplay_group_signals", []))
			+ _string_array(diagnostics.get("model_pressure", []))
			+ Array(diagnostics.get("gameplay_behavior_signals", []))
			+ Array(diagnostics.get("synergy_labels", []))
			+ Array(diagnostics.get("ritual_hooks", []))
			+ Array(diagnostics.get("protocol_hooks", []))
			+ Array(diagnostics.get("inhabitant_pressure", [])),
			8
		)
		pair["obligations"] = _merge_limited(
			Array(pair.get("obligations", [])),
			Array(frame.get("quest_briefs", []))
			+ Array(diagnostics.get("pressure_persistence", []))
			+ Array(frame.get("counter_readings", []))
			+ Array(diagnostics.get("ritual_recurrence", []))
			+ _string_array(diagnostics.get("group_fault_lines", []))
			+ Array(diagnostics.get("resource_pressure", []))
			+ Array(diagnostics.get("protocol_hooks", [])),
			8
		)
		pair["status_burden"] = _status_burden_label(frame, diagnostics)
		pair["display_label"] = _pair_display_label(pair_key, peer_identities)
		pair["history_count"] = int(pair.get("history_count", 0)) + 1
		pair["members"] = pair_key.split(":")
		pair["rescues"] = int(pair.get("rescues", 0)) + (1 if int(diagnostics.get("recovery_score", 0)) >= 2 else 0)
		pair["refusals"] = int(pair.get("refusals", 0)) + (1 if Array(diagnostics.get("expectation_breaks", [])).size() >= 1 and Array(diagnostics.get("recovery_ecology", [])).is_empty() else 0)
		pair["shared_burdens"] = int(pair.get("shared_burdens", 0)) + (1 if int(diagnostics.get("burden_score", 0)) >= 2 else 0)
		pair["mutual_extractions"] = int(pair.get("mutual_extractions", 0)) + (1 if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"] else 0)
		pair["betrayals"] = int(pair.get("betrayals", 0)) + (1 if int(diagnostics.get("confrontation_score", 0)) >= 2 and str(diagnostics.get("social_temperature", "")).find("rival") != -1 else 0)
		pair["near_misses"] = int(pair.get("near_misses", 0)) + int(diagnostics.get("near_miss_score", 0))
		pair["spectacle_moments"] = int(pair.get("spectacle_moments", 0)) + Array(diagnostics.get("spectacle_windows", [])).size()
		pair["public_reputation"] = _pair_reputation_label(pair)
		pairs[pair_key] = pair
		fabric["recent_pairs"] = _push_front_limited(Array(fabric.get("recent_pairs", [])), pair_key, 8)
	for peer_key in peer_identities.keys():
		var card: Dictionary = Dictionary(peer_identities.get(peer_key, {}))
		var public_id := str(card.get("public_id", "")).strip_edges()
		if public_id.is_empty():
			continue
		var player_entry: Dictionary = Dictionary(players.get(public_id, {
			"title": "Remembered delver",
			"heat": 0,
			"signals": [],
			"obligations": [],
			"status_burden": "",
			"display_name": str(card.get("display_name", public_id)),
			"history_count": 0,
			"rescues": 0,
			"refusals": 0,
			"near_misses": 0,
			"spectacle_moments": 0,
			"public_reputation": ""
		}))
		player_entry["heat"] = int(player_entry.get("heat", 0)) + 1
		player_entry["title"] = _player_title(public_id, diagnostics, frame)
		player_entry["signals"] = _merge_limited(
			Array(player_entry.get("signals", [])),
			Array(diagnostics.get("quest_pressure", []))
			+ Array(diagnostics.get("social_beats_top", []))
			+ Array(diagnostics.get("choice_frames", []))
			+ Array(diagnostics.get("recovery_ecology", []))
			+ ([str(diagnostics.get("build_identity", ""))] if not str(diagnostics.get("build_identity", "")).strip_edges().is_empty() else [])
			+ _string_array(diagnostics.get("gameplay_feature_signals", []))
			+ _string_array(diagnostics.get("gameplay_group_signals", []))
			+ _string_array(diagnostics.get("model_pressure", []))
			+ Array(diagnostics.get("gameplay_behavior_signals", []))
			+ Array(diagnostics.get("synergy_labels", []))
			+ Array(diagnostics.get("ritual_hooks", []))
			+ Array(diagnostics.get("protocol_hooks", []))
			+ Array(diagnostics.get("inhabitant_pressure", [])),
			8
		)
		player_entry["obligations"] = _merge_limited(
			Array(player_entry.get("obligations", [])),
			Array(frame.get("quest_briefs", [])) + Array(frame.get("counter_readings", [])) + Array(diagnostics.get("pressure_persistence", [])) + _string_array(diagnostics.get("group_fault_lines", [])) + Array(diagnostics.get("resource_pressure", [])),
			8
		)
		player_entry["status_burden"] = _status_burden_label(frame, diagnostics)
		player_entry["display_name"] = str(card.get("display_name", public_id))
		player_entry["history_count"] = int(player_entry.get("history_count", 0)) + 1
		player_entry["rescues"] = int(player_entry.get("rescues", 0)) + (1 if int(diagnostics.get("recovery_score", 0)) >= 2 else 0)
		player_entry["refusals"] = int(player_entry.get("refusals", 0)) + (1 if Array(diagnostics.get("expectation_breaks", [])).size() >= 1 else 0)
		player_entry["near_misses"] = int(player_entry.get("near_misses", 0)) + int(diagnostics.get("near_miss_score", 0))
		player_entry["spectacle_moments"] = int(player_entry.get("spectacle_moments", 0)) + Array(diagnostics.get("spectacle_windows", [])).size()
		player_entry["public_reputation"] = _player_reputation_label(player_entry, frame)
		players[public_id] = player_entry
	var crew_key := _crew_key(run_record)
	var crews: Dictionary = Dictionary(fabric.get("crews", {}))
	if not crew_key.is_empty():
		var crew_entry: Dictionary = Dictionary(crews.get(crew_key, {
			"title": "Recurring crew",
			"heat": 0,
			"signals": [],
			"obligations": [],
			"status_burden": "",
			"display_label": _crew_label(crew_key),
			"history_count": 0,
			"members": [],
			"shared_crawls": [],
			"successful_pushes": 0,
			"collapse_moments": 0,
			"public_reputation": "",
			"recoveries": 0,
			"escalations": 0
		}))
		crew_entry["heat"] = int(crew_entry.get("heat", 0)) + 1
		crew_entry["title"] = _crew_title(diagnostics, frame)
		crew_entry["signals"] = _merge_limited(
			Array(crew_entry.get("signals", [])),
			Array(diagnostics.get("crew_hooks", []))
			+ Array(frame.get("quest_briefs", []))
			+ Array(diagnostics.get("recovery_ecology", []))
			+ Array(diagnostics.get("quest_collisions", []))
			+ ([str(diagnostics.get("build_identity", ""))] if not str(diagnostics.get("build_identity", "")).strip_edges().is_empty() else [])
			+ _string_array(diagnostics.get("gameplay_feature_signals", []))
			+ _string_array(diagnostics.get("gameplay_group_signals", []))
			+ _string_array(diagnostics.get("model_pressure", []))
			+ Array(diagnostics.get("gameplay_behavior_signals", []))
			+ Array(diagnostics.get("synergy_labels", []))
			+ Array(diagnostics.get("ritual_hooks", []))
			+ Array(diagnostics.get("protocol_hooks", []))
			+ Array(diagnostics.get("inhabitant_pressure", [])),
			8
		)
		crew_entry["obligations"] = _merge_limited(
			Array(crew_entry.get("obligations", [])),
			Array(diagnostics.get("pressure_persistence", []))
			+ Array(frame.get("quest_briefs", []))
			+ Array(frame.get("counter_readings", []))
			+ Array(diagnostics.get("ritual_recurrence", []))
			+ _string_array(diagnostics.get("group_fault_lines", []))
			+ Array(diagnostics.get("resource_pressure", []))
			+ Array(diagnostics.get("protocol_hooks", [])),
			8
		)
		crew_entry["status_burden"] = _status_burden_label(frame, diagnostics)
		crew_entry["display_label"] = _crew_display_label(peer_identities)
		crew_entry["history_count"] = int(crew_entry.get("history_count", 0)) + 1
		crew_entry["members"] = _crew_member_ids(peer_identities)
		crew_entry["shared_crawls"] = _merge_limited(Array(crew_entry.get("shared_crawls", [])), [str(Dictionary(profile.get("active_crawl", {})).get("crawl_id", ""))], 6)
		crew_entry["successful_pushes"] = int(crew_entry.get("successful_pushes", 0)) + (1 if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"] and str(Dictionary(profile.get("active_crawl", {})).get("bank_vs_push_state", "")) in ["push_deeper", "risk_the_story"] else 0)
		crew_entry["collapse_moments"] = int(crew_entry.get("collapse_moments", 0)) + (1 if str(diagnostics.get("group_shape_drift", "")) == "unified_to_fragmented" else 0)
		crew_entry["recoveries"] = int(crew_entry.get("recoveries", 0)) + int(diagnostics.get("recovery_score", 0))
		crew_entry["escalations"] = int(crew_entry.get("escalations", 0)) + int(diagnostics.get("confrontation_score", 0))
		crew_entry["public_reputation"] = _crew_reputation_label(crew_entry, frame)
		crews[crew_key] = crew_entry
		fabric["recent_crews"] = _push_front_limited(Array(fabric.get("recent_crews", [])), crew_key, 6)
	fabric["players"] = players
	fabric["pairs"] = pairs
	fabric["crews"] = crews
	profile["relationship_fabric"] = fabric

static func _update_persona_state(profile: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> void:
	var persona: Dictionary = Dictionary(profile.get("persona_state", {}))
	var archetype_scores: Dictionary = Dictionary(persona.get("archetype_scores", {}))
	_add_score(archetype_scores, "rescuer", int(diagnostics.get("recovery_score", 0)))
	_add_score(archetype_scores, "stabilizer", 2 if str(diagnostics.get("momentum_profile", "")) in ["coming_together", "steadying", "stabilizing"] else 0)
	_add_score(archetype_scores, "escalator", int(diagnostics.get("confrontation_score", 0)) + int(diagnostics.get("spectacle_pressure", 0)) / 2)
	_add_score(archetype_scores, "survivor", 2 if str(frame.get("status_valence", "")) in ["Almost", "Unfinished"] else 0)
	_add_score(archetype_scores, "wildcard", int(diagnostics.get("expectation_break_score", 0)))
	_add_score(archetype_scores, "quiet_closer", 2 if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"] and int(diagnostics.get("spectacle_pressure", 0)) <= 1 else 0)
	_add_score(archetype_scores, "burden_carrier", int(diagnostics.get("burden_score", 0)))
	_add_score(archetype_scores, "pattern_reader", int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0)) / 2)
	_add_score(archetype_scores, "ritual_answerer", Array(diagnostics.get("hidden_curriculum", [])).size())
	persona["archetype_scores"] = archetype_scores
	persona["public_expectations"] = _merge_limited(
		Array(persona.get("public_expectations", [])),
		Array(frame.get("quest_briefs", []))
		+ Array(frame.get("story_axes", []))
		+ Array(diagnostics.get("counterfactual_pressure", []))
		+ Array(diagnostics.get("hidden_curriculum", []))
		+ _string_array(diagnostics.get("model_pressure", []))
		+ _string_array(diagnostics.get("group_fault_lines", [])),
		6
	)
	persona["risk_posture"] = {
		"tendency": _first_string(Array(diagnostics.get("purpose_vector", [])), "hold together"),
		"temperature": str(diagnostics.get("social_temperature", "")),
		"momentum": str(diagnostics.get("momentum_profile", "")),
		"profile": str(diagnostics.get("risk_profile", "")),
		"stability": str(diagnostics.get("build_stability", ""))
	}
	profile["persona_state"] = persona

static func _crawl_detail(crawl: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append(str(crawl.get("title", "Past crawl")))
	lines.append("Stage: %s | Runs: %d | Heat: %d" % [
		_title_case(str(crawl.get("stage", "legend"))),
		int(crawl.get("run_count", 0)),
		int(crawl.get("public_heat", 0))
	])
	var turning_points := _string_array(crawl.get("turning_points", []))
	if not turning_points.is_empty():
		lines.append("Turning point: %s" % turning_points[0])
	var questions := _string_array(crawl.get("open_questions", []))
	if not questions.is_empty():
		lines.append("Lingering: %s" % questions[0])
	lines.append("Ending: %s | Stake: %d" % [_title_case(str(crawl.get("ending", "carried-forward")).replace("_", " ")), int(crawl.get("risk_stake", 0))])
	if int(crawl.get("public_heat", 0)) >= 6 or int(crawl.get("risk_stake", 0)) >= 8:
		lines.append("Weight: this crawl still reads as one people measure later runs against.")
	var residue := _string_array(crawl.get("memorial_residue", []))
	if not residue.is_empty():
		lines.append("Residue: %s" % residue[0])
	var all_residue := _string_array(crawl.get("residue", []))
	if all_residue.size() >= 2:
		lines.append("Echo trail: %s" % all_residue[0])
	var obligation := _string_array(crawl.get("obligation_residue", []))
	if not obligation.is_empty():
		lines.append("Debt: %s" % obligation[0])
	var unfinished := _string_array(crawl.get("unfinished_pressure", []))
	if not unfinished.is_empty():
		lines.append("Unfinished: %s" % unfinished[0])
	var identity_bits := _string_array(crawl.get("crawl_identity", []))
	if not identity_bits.is_empty():
		lines.append("Identity: %s" % identity_bits[0])
	var belief_bits := _string_array(crawl.get("belief_pressure", []))
	if not belief_bits.is_empty():
		lines.append("Belief: %s" % belief_bits[0])
	var model_bits := _string_array(crawl.get("model_memory", []))
	if not model_bits.is_empty():
		lines.append("Answer shape: %s" % model_bits[0])
	var fault_bits := _string_array(crawl.get("fault_memory", []))
	if not fault_bits.is_empty():
		lines.append("Fault line: %s" % fault_bits[0])
	var expectation := str(crawl.get("expectation_pressure", "")).strip_edges()
	if not expectation.is_empty():
		lines.append("Pressure: %s" % expectation)
	var state := str(crawl.get("bank_vs_push_state", "")).strip_edges()
	if not state.is_empty():
		lines.append("Decision pull: %s" % _title_case(state.replace("_", " ")))
	var public_challenge := str(crawl.get("public_challenge", "")).strip_edges()
	if not public_challenge.is_empty():
		lines.append("Challenge: %s" % public_challenge)
	var promise_pressure := str(crawl.get("promise_pressure", "")).strip_edges()
	if not promise_pressure.is_empty():
		lines.append("Promise: %s" % promise_pressure)
	var stability_bits := _string_array(crawl.get("stability_memory", []))
	if not stability_bits.is_empty():
		lines.append("Stability: %s" % stability_bits[0])
	var rivalry_bits := _string_array(crawl.get("crawl_rivalries", []))
	if not rivalry_bits.is_empty():
		lines.append("Tension: %s" % rivalry_bits[0])
	var promises := _string_array(crawl.get("crawl_promises", []))
	if not promises.is_empty():
		lines.append("Promise trail: %s" % promises[0])
	var curriculum_bits := _string_array(crawl.get("curriculum_pressure", []))
	if not curriculum_bits.is_empty():
		lines.append("Lesson trail: %s" % curriculum_bits[0])
	var anomaly_bits := _string_array(crawl.get("anomaly_pressure", []))
	if not anomaly_bits.is_empty():
		lines.append("Uneasy pull: %s" % anomaly_bits[0])
	return "\n".join(lines)

static func _relationship_detail(pair: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append(str(pair.get("title", "Pair echo")))
	lines.append("Heat: %d" % int(pair.get("heat", 0)))
	var history_count := int(pair.get("history_count", 0))
	if history_count > 0:
		lines.append("Recurrences: %d" % history_count)
	var signals := _string_array(pair.get("signals", []))
	if not signals.is_empty():
		lines.append("Signals: %s" % ", ".join(signals.slice(0, mini(signals.size(), 3))))
	var obligations := _string_array(pair.get("obligations", []))
	if not obligations.is_empty():
		lines.append("Obligation: %s" % obligations[0])
	var reputation := str(pair.get("public_reputation", "")).strip_edges()
	if not reputation.is_empty():
		lines.append("Public read: %s" % reputation)
	var rescues := int(pair.get("rescues", 0))
	var refusals := int(pair.get("refusals", 0))
	var shared_burdens := int(pair.get("shared_burdens", 0))
	var betrayals := int(pair.get("betrayals", 0))
	var mutual_extractions := int(pair.get("mutual_extractions", 0))
	var near_misses := int(pair.get("near_misses", 0))
	var spectacle_moments := int(pair.get("spectacle_moments", 0))
	if rescues > 0 or refusals > 0 or shared_burdens > 0 or betrayals > 0:
		lines.append("History: R%s | F%s | B%s | X%s" % [rescues, refusals, shared_burdens, betrayals])
	if mutual_extractions > 0 or near_misses > 0 or spectacle_moments > 0:
		lines.append("Turns: E%s | N%s | S%s" % [mutual_extractions, near_misses, spectacle_moments])
	if rescues >= 2 and near_misses >= 1:
		lines.append("Pattern: keeps answering danger after almost losing it.")
	elif shared_burdens >= 2 and refusals >= 1:
		lines.append("Pattern: burden duty and reluctance keep colliding here.")
	elif betrayals >= 1 and mutual_extractions >= 1:
		lines.append("Pattern: rupture and recovery are both still attached to this echo.")
	elif rescues >= 1 and refusals >= 1 and near_misses >= 1:
		lines.append("Pattern: the pair keeps oscillating between answer and hesitation.")
	var burden := str(pair.get("status_burden", "")).strip_edges()
	if not burden.is_empty():
		lines.append("Burden: %s" % burden)
	var shared_crawls := _string_array(pair.get("shared_crawls", []))
	if not shared_crawls.is_empty():
		lines.append("Shared crawls: %d" % shared_crawls.size())
	var successful_pushes := int(pair.get("successful_pushes", 0))
	var collapse_moments := int(pair.get("collapse_moments", 0))
	var recoveries := int(pair.get("recoveries", 0))
	var escalations := int(pair.get("escalations", 0))
	if successful_pushes > 0 or collapse_moments > 0 or recoveries > 0 or escalations > 0:
		lines.append("Crew marks: P%s | C%s | R%s | E%s" % [successful_pushes, collapse_moments, recoveries, escalations])
	if collapse_moments >= 2 and recoveries >= 2:
		lines.append("Crew reading: this group keeps living between collapse and repair.")
	elif successful_pushes >= 2:
		lines.append("Crew reading: the push has become part of its public memory.")
	var display_name := str(pair.get("display_name", "")).strip_edges()
	if not display_name.is_empty():
		lines.append("Delver: %s" % display_name)
	return "\n".join(lines)

static func _pair_title(pair_key: String, diagnostics: Dictionary) -> String:
	var rescue_score := int(diagnostics.get("recovery_score", 0))
	if rescue_score >= 3:
		return "Rescue pair"
	if str(diagnostics.get("social_temperature", "")).find("rival") != -1:
		return "Rival pair"
	if Array(diagnostics.get("symbolic_gestures", [])).has("burden handoff"):
		return "Burden pair"
	if Array(diagnostics.get("quest_collisions", [])).size() >= 1:
		return "Torn pair"
	if str(diagnostics.get("group_shape_drift", "")).find("cooperative") != -1:
		return "Hold-together pair"
	return "Recurring pair"

static func _player_title(public_id: String, diagnostics: Dictionary, frame: Dictionary) -> String:
	if int(diagnostics.get("recovery_score", 0)) >= 3:
		return "Rescuer under pressure"
	if str(frame.get("status_valence", "")) in ["Scandal", "Infamy"]:
		return "Scandal-marked delver"
	if int(diagnostics.get("expectation_break_score", 0)) >= 1:
		return "Pattern breaker"
	if Array(diagnostics.get("ritual_recurrence", [])).size() >= 1:
		return "Ritual-marked delver"
	return "Remembered delver"

static func _crew_title(diagnostics: Dictionary, frame: Dictionary) -> String:
	var drift := str(diagnostics.get("group_shape_drift", ""))
	if drift == "chaotic_to_disciplined":
		return "Disciplined crew"
	if drift == "unified_to_fragmented":
		return "Brittle crew"
	if drift == "brittle_to_mythic":
		return "Mythic crew"
	if int(diagnostics.get("recovery_score", 0)) >= 3:
		return "Rescue crew"
	if Array(diagnostics.get("quest_collisions", [])).size() >= 1:
		return "Pressure crew"
	if str(frame.get("status_valence", "")) == "Redemption":
		return "Redeeming crew"
	if str(frame.get("status_valence", "")) in ["Scandal", "Infamy"]:
		return "Overheated crew"
	return "Recurring crew"

static func _pair_reputation_label(pair: Dictionary) -> String:
	if int(pair.get("rescues", 0)) >= 2:
		return "keeps answering with rescue"
	if int(pair.get("rescues", 0)) >= 1 and int(pair.get("betrayals", 0)) >= 1:
		return "still reads as torn between rescue and rupture"
	if int(pair.get("mutual_extractions", 0)) >= 2:
		return "keeps getting out together"
	if int(pair.get("betrayals", 0)) >= 2:
		return "still reads as volatile"
	if int(pair.get("shared_burdens", 0)) >= 2:
		return "keeps taking the burden line"
	if int(pair.get("near_misses", 0)) >= 2:
		return "keeps surviving the almost-failure"
	if int(pair.get("refusals", 0)) >= 2:
		return "keeps resisting the expected move"
	if int(pair.get("rescues", 0)) >= 1 and int(pair.get("refusals", 0)) >= 1:
		return "keeps being read through answer and refusal together"
	return ""

static func _crew_reputation_label(crew_entry: Dictionary, frame: Dictionary) -> String:
	if int(crew_entry.get("successful_pushes", 0)) >= 2:
		return "known for carrying the push"
	if int(crew_entry.get("successful_pushes", 0)) >= 1 and int(crew_entry.get("collapse_moments", 0)) >= 1:
		return "known for surviving the push after it starts to break"
	if int(crew_entry.get("collapse_moments", 0)) >= 2:
		return "watched for collapse"
	if int(crew_entry.get("recoveries", 0)) >= 4:
		return "keeps dragging itself back together"
	if int(crew_entry.get("escalations", 0)) >= 3:
		return "keeps heating up under pressure"
	if str(frame.get("status_valence", "")) in ["Scandal", "Infamy"]:
		return "still under hotter scrutiny"
	if int(crew_entry.get("recoveries", 0)) >= 2 and int(crew_entry.get("collapse_moments", 0)) >= 1:
		return "keeps being judged on whether it can hold together after the slip"
	return ""

static func _player_reputation_label(player_entry: Dictionary, frame: Dictionary) -> String:
	if int(player_entry.get("rescues", 0)) >= 2:
		return "expected to answer with rescue"
	if int(player_entry.get("rescues", 0)) >= 1 and int(player_entry.get("refusals", 0)) >= 1:
		return "keeps being read through rescue and refusal together"
	if int(player_entry.get("spectacle_moments", 0)) >= 2 and str(frame.get("status_valence", "")) in ["Scandal", "Infamy", "Prestige"]:
		return "keeps drawing public heat"
	if int(player_entry.get("refusals", 0)) >= 2:
		return "keeps refusing the hotter move"
	if int(player_entry.get("near_misses", 0)) >= 2:
		return "still carrying unfinished pressure"
	if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"] and int(player_entry.get("rescues", 0)) >= 1:
		return "is starting to look like a steadier answer"
	return ""

static func _pair_label(pair_key: String) -> String:
	var bits := pair_key.split(":")
	if bits.size() == 2:
		return "%s / %s" % [bits[0], bits[1]]
	return pair_key

static func _crew_label(crew_key: String) -> String:
	var bits := crew_key.split("|")
	if bits.size() >= 2:
		return "%s delvers" % str(bits.size())
	return crew_key

static func _merge_limited(existing: Array, incoming: Array, limit: int) -> Array:
	var result: Array[String] = _string_array(existing)
	for value in incoming:
		var text := str(value).strip_edges()
		if text.is_empty() or result.has(text):
			continue
		result.append(text)
	if result.size() > limit:
		return result.slice(0, limit)
	return result

static func _push_front_limited(existing: Array, value: String, limit: int) -> Array:
	var result: Array[String] = []
	var text := value.strip_edges()
	if not text.is_empty():
		result.append(text)
	for current in existing:
		var current_text := str(current).strip_edges()
		if current_text.is_empty() or result.has(current_text):
			continue
		result.append(current_text)
		if result.size() >= limit:
			break
	return result

static func _add_score(scores: Dictionary, key: String, delta: int) -> void:
	if delta <= 0:
		return
	scores[key] = int(scores.get(key, 0)) + delta

static func _crew_key(run_record: Dictionary) -> String:
	var peer_identities: Dictionary = Dictionary(run_record.get("peer_identities", {}))
	var ids: Array[String] = []
	for peer_key in peer_identities.keys():
		var card: Dictionary = Dictionary(peer_identities.get(peer_key, {}))
		var public_id := str(card.get("public_id", "")).strip_edges()
		if not public_id.is_empty():
			ids.append(public_id)
	ids.sort()
	return "|".join(ids)

static func _resolution_state(frame: Dictionary, diagnostics: Dictionary) -> String:
	if int(diagnostics.get("expectation_break_score", 0)) >= 1:
		return "inverted"
	if int(diagnostics.get("near_miss_score", 0)) >= 2:
		return "unfinished"
	if Array(diagnostics.get("quest_collisions", [])).size() >= 2:
		return "contested"
	if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"]:
		return "closed"
	return "open"

static func _ending_label(run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> String:
	if bool(run_record.get("interrupted", false)):
		return "memorialized interruption"
	if Array(diagnostics.get("expectation_breaks", [])).size() >= 1 and Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
		return "pattern broken under pressure"
	if int(diagnostics.get("near_miss_score", 0)) >= 2:
		return "almost held"
	if Array(diagnostics.get("quest_collisions", [])).size() >= 2:
		return "carried through collision"
	if str(frame.get("status_valence", "")) == "Prestige":
		return "banked legend"
	if str(frame.get("status_valence", "")) == "Scandal":
		return "ruptured under heat"
	if str(frame.get("status_valence", "")) == "Redemption":
		return "redeemed hold"
	return "carried forward"

static func _crawl_expectation(active_crawl: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> String:
	var line := str(frame.get("challenge_attention", "")).strip_edges()
	if line.is_empty():
		line = str(active_crawl.get("public_challenge", "")).strip_edges()
	if line.is_empty():
		line = str(active_crawl.get("promise_pressure", "")).strip_edges()
	if line.is_empty():
		line = _first_string(Array(active_crawl.get("unfinished_pressure", [])), "")
	if line.is_empty():
		line = _first_string(Array(active_crawl.get("crawl_promises", [])), "")
	if line.is_empty():
		line = _first_string(Array(active_crawl.get("crawl_rivalries", [])), "")
	if line.is_empty():
		line = _first_string(Array(active_crawl.get("belief_pressure", [])), "")
	if line.is_empty():
		line = _first_string(Array(active_crawl.get("memorial_residue", [])), "")
	if line.is_empty():
		line = _first_string(Array(frame.get("open_questions", [])), "")
	if line.is_empty():
		line = _first_string(Array(diagnostics.get("pressure_persistence", [])), "")
	if line.is_empty():
		line = _first_string(Array(active_crawl.get("obligation_residue", [])), "")
	if line.is_empty():
		line = str(active_crawl.get("promise_pressure", "")).strip_edges()
	if line.is_empty():
		line = _first_string(Array(active_crawl.get("quest_history", [])), "")
	if line.is_empty() and str(active_crawl.get("bank_vs_push_state", "")) == "hold_together":
		line = "The crawl is being asked to hold together once more."
	if line.is_empty() and str(active_crawl.get("bank_vs_push_state", "")) == "risk_the_story":
		line = "The crawl is being dared to risk itself for a hotter answer."
	if line.is_empty() and str(active_crawl.get("bank_vs_push_state", "")) == "bank_now":
		line = "The crawl is being asked to bank what it still has."
	return line

static func _bank_push_state(active_crawl: Dictionary, frame: Dictionary) -> String:
	var bank_pressure := int(active_crawl.get("bank_pressure", 0))
	var push_pressure := int(active_crawl.get("push_pressure", 0))
	var stake := int(active_crawl.get("risk_stake", 0))
	var memorial_count := Array(active_crawl.get("memorial_residue", [])).size()
	var obligation_count := Array(active_crawl.get("obligation_residue", [])).size()
	if bank_pressure >= push_pressure + 3:
		return "bank_now"
	if bank_pressure >= 6 and push_pressure >= 6:
		return "hold_together"
	if bank_pressure >= 5 and stake >= 8 and push_pressure >= 5:
		return "risk_the_story"
	if obligation_count >= 3 and bank_pressure >= 5:
		return "hold_together"
	if memorial_count >= 2 and push_pressure >= 6:
		return "risk_the_story"
	if stake >= 10 and push_pressure >= bank_pressure:
		return "push_deeper"
	if push_pressure >= bank_pressure + 2:
		return "push_deeper"
	if str(frame.get("status_valence", "")) in ["Almost", "Scandal", "Infamy"]:
		return "risk_the_story"
	return "balanced"

static func _status_burden_label(frame: Dictionary, diagnostics: Dictionary) -> String:
	var status := str(frame.get("status_valence", "")).strip_edges()
	if status in ["Prestige", "Redemption"]:
		return "expected to repeat the save"
	if status in ["Scandal", "Infamy", "Disgrace"]:
		return "watched for another rupture"
	if Array(diagnostics.get("quest_collisions", [])).size() >= 1:
		return "owes a harder answer"
	if int(diagnostics.get("near_miss_score", 0)) >= 2:
		return "unfinished business"
	return ""

static func _public_challenge(active_crawl: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> String:
	var line := str(frame.get("challenge_attention", "")).strip_edges()
	if not line.is_empty():
		return line
	var doctrine_bits := _string_array(active_crawl.get("doctrine_memory", []))
	if not doctrine_bits.is_empty() and int(active_crawl.get("public_heat", 0)) >= 5:
		return "This crawl is being watched through %s." % doctrine_bits[0].to_lower()
	var rivalries := _string_array(active_crawl.get("crawl_rivalries", []))
	if not rivalries.is_empty() and int(active_crawl.get("public_heat", 0)) >= 6:
		return "This crawl is being watched for whether %s." % rivalries[0].to_lower()
	var memorial := _string_array(active_crawl.get("memorial_residue", []))
	if not memorial.is_empty() and int(active_crawl.get("public_heat", 0)) >= 6:
		return "This crawl is being watched for whether it can answer %s." % memorial[0].to_lower()
	if Array(diagnostics.get("quest_collisions", [])).size() >= 2:
		return "The crawl is being watched for whether it holds together."
	if Array(diagnostics.get("ritual_recurrence", [])).size() >= 1:
		return "%s keeps coming back." % _first_string(Array(diagnostics.get("ritual_recurrence", [])), "The same pressure")
	var promises := _string_array(active_crawl.get("crawl_promises", []))
	if not promises.is_empty() and int(active_crawl.get("public_heat", 0)) >= 5:
		return "This crawl is being watched for whether %s." % promises[0].to_lower()
	var belief_bits := _string_array(active_crawl.get("belief_pressure", []))
	if not belief_bits.is_empty() and int(active_crawl.get("public_heat", 0)) >= 5:
		return "This crawl is being read through whether %s." % belief_bits[0].to_lower()
	if int(active_crawl.get("public_heat", 0)) >= 7 and int(active_crawl.get("risk_stake", 0)) >= 8:
		return "The crawl is carrying public challenge heat."
	return ""

static func _promise_pressure(active_crawl: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> String:
	var line := _first_string(Array(active_crawl.get("obligation_residue", [])), "")
	if not line.is_empty():
		return line
	var governance_bits := _string_array(active_crawl.get("governance_memory", []))
	if not governance_bits.is_empty():
		return "The crawl is still being steered toward %s." % governance_bits[0].to_lower()
	var memorial := _string_array(active_crawl.get("memorial_residue", []))
	if not memorial.is_empty():
		return "The crawl still owes an answer to %s." % memorial[0].to_lower()
	var promises := _string_array(active_crawl.get("crawl_promises", []))
	if not promises.is_empty():
		return promises[0]
	var unfinished := _string_array(active_crawl.get("unfinished_pressure", []))
	if not unfinished.is_empty():
		return unfinished[0]
	var curriculum_bits := _string_array(active_crawl.get("curriculum_pressure", []))
	if not curriculum_bits.is_empty():
		return "The crawl is being pressed toward %s." % curriculum_bits[0].to_lower()
	var rivalries := _string_array(active_crawl.get("crawl_rivalries", []))
	if not rivalries.is_empty():
		return rivalries[0]
	if Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
		return "The crawl is being asked to repair what it nearly lost."
	if str(frame.get("status_valence", "")) in ["Prestige", "Redemption"] and int(active_crawl.get("run_count", 0)) >= 2:
		return "The better version of this crawl now feels expected."
	return ""

static func _build_memory_lines(build_scores: Dictionary) -> Array[String]:
	var scores: Array[Dictionary] = []
	for build_label in build_scores.keys():
		var score := int(build_scores.get(build_label, 0))
		if score <= 0:
			continue
		scores.append({"label": str(build_label), "score": score})
	scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("score", 0)) == int(b.get("score", 0)):
			return str(a.get("label", "")) < str(b.get("label", ""))
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	var lines: Array[String] = []
	for entry in scores.slice(0, 2):
		var label := str(Dictionary(entry).get("label", "")).strip_edges()
		if label.is_empty():
			continue
		lines.append("%s memory" % label)
	return lines

static func _pair_display_label(pair_key: String, peer_identities: Dictionary) -> String:
	var bits := pair_key.split(":")
	if bits.size() != 2:
		return _pair_label(pair_key)
	var names: Array[String] = []
	for peer_raw in peer_identities.values():
		var card: Dictionary = Dictionary(peer_raw)
		var public_id := str(card.get("public_id", "")).strip_edges()
		if public_id.is_empty():
			continue
		if bits.has(public_id):
			names.append(str(card.get("display_name", public_id)))
	if names.size() == 2:
		names.sort()
		return "%s / %s" % [names[0], names[1]]
	return _pair_label(pair_key)

static func _crew_display_label(peer_identities: Dictionary) -> String:
	var names: Array[String] = []
	for peer_raw in peer_identities.values():
		var card: Dictionary = Dictionary(peer_raw)
		var display_name := str(card.get("display_name", "")).strip_edges()
		if not display_name.is_empty():
			names.append(display_name)
	names.sort()
	if names.is_empty():
		return ""
	return ", ".join(names.slice(0, mini(names.size(), 3)))

static func _crew_member_ids(peer_identities: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	for peer_raw in peer_identities.values():
		var card: Dictionary = Dictionary(peer_raw)
		var public_id := str(card.get("public_id", "")).strip_edges()
		if not public_id.is_empty():
			ids.append(public_id)
	ids.sort()
	return ids

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value))
	return result

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty():
				result.append(text)
	return result

static func _first_string(values: Array, fallback: String) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _title_case(text: String) -> String:
	return text.strip_edges().replace("_", " ").capitalize()
