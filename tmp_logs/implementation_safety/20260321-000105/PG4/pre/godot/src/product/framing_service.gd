class_name FramingService
extends RefCounted

const WORDING_GUARD_SCRIPT = preload("res://src/product/narrative_wording_guard.gd")

static func build_run_frame(run_record: Dictionary, diagnostics: Dictionary, profile: Dictionary = {}) -> Dictionary:
	var status_valence := _build_status_valence(run_record, diagnostics)
	var commentary_style := _build_commentary_style(run_record, diagnostics, status_valence)
	var choice_frame := str(_first_string(Array(diagnostics.get("choice_frames", [])), "Practical"))
	var quest_briefs := _quest_briefs(diagnostics, profile)
	var public_heat := _public_heat(diagnostics, status_valence)
	var finish_identity := _finish_identity(run_record, diagnostics, status_valence)
	var headline := _broadcast_headline(run_record, diagnostics, status_valence)
	var subhead := _broadcast_subhead(diagnostics, commentary_style)
	var open_questions := _open_questions(diagnostics, profile)
	var interpretation_split := _interpretation_split(diagnostics, status_valence)
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var doctrine_family := str(diagnostics.get("doctrine_family", "")).strip_edges()
	var doctrine_label := str(diagnostics.get("doctrine_label", "")).strip_edges()
	var doctrine_pressure_line := str(diagnostics.get("doctrine_pressure_line", "")).strip_edges()
	var doctrine_world_goal := str(diagnostics.get("doctrine_world_goal", "")).strip_edges()
	var build_line := _build_line(diagnostics, profile)
	var resource_line := _resource_line(diagnostics, profile)
	var inhabitant_line := _inhabitant_line(diagnostics, profile)
	var belief_line := _belief_line(diagnostics, profile)
	var counterfactual_line := _counterfactual_line(diagnostics, profile)
	var curriculum_line := _curriculum_line(diagnostics, profile)
	var anomaly_pull := _anomaly_pull(diagnostics, profile)
	var doctrine_line := _doctrine_line(diagnostics, profile)
	var governance_line := _governance_line(diagnostics, profile)
	var quiet_play_line := _quiet_play_line(diagnostics)
	var reentry_line := _reentry_line(diagnostics, profile)
	var social_consequence_line := _social_consequence_line(diagnostics)
	var social_safety_line := _social_safety_line(diagnostics)
	var institutional_line := _institutional_line(diagnostics)
	var reputation_line := _reputation_line(diagnostics)
	var delve_trace := _delve_trace(diagnostics, profile)
	var commentary_lanes := _commentary_lanes(diagnostics, profile, status_valence, commentary_style)
	var counter_readings := _counter_readings(diagnostics, profile, status_valence)
	var school_reads := _school_reads(commentary_lanes, diagnostics, profile, status_valence)
	var school_tension := _school_tension(commentary_lanes, interpretation_split, counter_readings)
	var challenge_attention := _challenge_attention(diagnostics, profile, status_valence)
	var ritual_pressure := _ritual_pressure(diagnostics, profile)
	var world_pull := _world_pull(profile, diagnostics)
	return {
		"choice_frame": guard_text(choice_frame),
		"status_valence": status_valence,
		"commentary_style": guard_text(commentary_style),
		"public_heat": public_heat,
		"quest_briefs": guard_lines(quest_briefs),
		"broadcast_headline": guard_text(headline),
		"broadcast_subhead": guard_text(subhead),
		"finish_identity": guard_text(finish_identity),
		"open_questions": guard_lines(open_questions),
		"archive_title": guard_text(_archive_title(run_record, diagnostics, status_valence)),
		"story_axes": _story_axes(diagnostics),
		"narrative_hooks": _narrative_hooks(diagnostics, status_valence),
		"compression_quality": _compression_quality(diagnostics),
		"legend_density_score": _legend_density_score(diagnostics),
		"interpretation_split": guard_lines(interpretation_split),
		"commentary_lanes": guard_lines(commentary_lanes),
		"counter_readings": guard_lines(counter_readings),
		"primary_school": guard_text(_first_string(commentary_lanes, commentary_style)),
		"school_reads": guard_lines(school_reads),
		"school_tension": guard_text(school_tension),
		"protocol_state": guard_text(protocol_state),
		"doctrine_family": guard_text(doctrine_family),
		"doctrine_label": guard_text(doctrine_label),
		"doctrine_pressure_line": guard_text(doctrine_pressure_line),
		"doctrine_world_goal": guard_text(doctrine_world_goal),
		"doctrine_line": guard_text(doctrine_line),
		"governance_line": guard_text(governance_line),
		"quiet_play_line": guard_text(quiet_play_line),
		"reentry_line": guard_text(reentry_line),
		"social_consequence_line": guard_text(social_consequence_line),
		"social_safety_line": guard_text(social_safety_line),
		"institutional_line": guard_text(institutional_line),
		"reputation_line": guard_text(reputation_line),
		"build_line": guard_text(build_line),
		"resource_line": guard_text(resource_line),
		"inhabitant_line": guard_text(inhabitant_line),
		"belief_line": guard_text(belief_line),
		"counterfactual_line": guard_text(counterfactual_line),
		"curriculum_line": guard_text(curriculum_line),
		"consensus_risk": guard_text(str(diagnostics.get("consensus_risk", ""))),
		"anomaly_pull": guard_text(anomaly_pull),
		"challenge_attention": guard_text(challenge_attention),
		"ritual_pressure": guard_text(ritual_pressure),
		"world_pull": guard_text(world_pull),
		"delve_trace": guard_text(delve_trace),
		"layer_safe": true
	}

static func build_focus_lines(frame: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	lines.append("Quest pressure: %s" % ", ".join(_string_array(frame.get("quest_briefs", []))))
	lines.append("Broadcast: %s" % str(frame.get("broadcast_headline", "Run story ready")))
	lines.append("Finish identity: %s" % str(frame.get("finish_identity", "Run resolved")))
	var school_reads := _string_array(frame.get("school_reads", []))
	if not school_reads.is_empty():
		lines.append("Reading: %s" % school_reads[0])
	var school_tension := str(frame.get("school_tension", "")).strip_edges()
	if not school_tension.is_empty():
		lines.append("Tension: %s" % school_tension)
	var challenge_attention := str(frame.get("challenge_attention", "")).strip_edges()
	if not challenge_attention.is_empty():
		lines.append("Challenge pressure: %s" % challenge_attention)
	var doctrine_line := str(frame.get("doctrine_line", "")).strip_edges()
	if not doctrine_line.is_empty():
		lines.append("Doctrine: %s" % doctrine_line)
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	if not governance_line.is_empty():
		lines.append("Governance: %s" % governance_line)
	var quiet_play_line := str(frame.get("quiet_play_line", "")).strip_edges()
	if not quiet_play_line.is_empty():
		lines.append("Quiet play: %s" % quiet_play_line)
	var social_consequence_line := str(frame.get("social_consequence_line", "")).strip_edges()
	if not social_consequence_line.is_empty():
		lines.append("Social: %s" % social_consequence_line)
	var institutional_line := str(frame.get("institutional_line", "")).strip_edges()
	if not institutional_line.is_empty():
		lines.append("Institution: %s" % institutional_line)
	var build_line := str(frame.get("build_line", "")).strip_edges()
	if not build_line.is_empty():
		lines.append("Build pull: %s" % build_line)
	var resource_line := str(frame.get("resource_line", "")).strip_edges()
	if not resource_line.is_empty():
		lines.append("Resource pressure: %s" % resource_line)
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	if not ritual_pressure.is_empty():
		lines.append("Ritual pressure: %s" % ritual_pressure)
	var inhabitant_line := str(frame.get("inhabitant_line", "")).strip_edges()
	if not inhabitant_line.is_empty():
		lines.append("Presence: %s" % inhabitant_line)
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	if not belief_line.is_empty():
		lines.append("Belief: %s" % belief_line)
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	if not counterfactual_line.is_empty():
		lines.append("Counterfactual: %s" % counterfactual_line)
	return guard_lines(lines)

static func build_archive_preview_lines(frame: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	lines.append("Archive pull: %s" % str(frame.get("archive_title", "Recent run echo")))
	lines.append("Commentary: %s" % str(frame.get("commentary_style", "Measured")))
	var school_reads := _string_array(frame.get("school_reads", []))
	if not school_reads.is_empty():
		lines.append("Reading: %s" % school_reads[0])
	var school_tension := str(frame.get("school_tension", "")).strip_edges()
	if not school_tension.is_empty():
		lines.append("Tension: %s" % school_tension)
	var protocol_state := str(frame.get("protocol_state", "")).strip_edges()
	if not protocol_state.is_empty():
		lines.append("Protocol: %s" % protocol_state)
	var doctrine_line := str(frame.get("doctrine_line", "")).strip_edges()
	if not doctrine_line.is_empty():
		lines.append("Doctrine: %s" % doctrine_line)
	var build_line := str(frame.get("build_line", "")).strip_edges()
	if not build_line.is_empty():
		lines.append("Build: %s" % build_line)
	var open_questions := _string_array(frame.get("open_questions", []))
	if not open_questions.is_empty():
		lines.append("Open question: %s" % open_questions[0])
	var resource_line := str(frame.get("resource_line", "")).strip_edges()
	if not resource_line.is_empty():
		lines.append("Pressure: %s" % resource_line)
	var counter_readings := _string_array(frame.get("counter_readings", []))
	if not counter_readings.is_empty():
		lines.append("Counter-read: %s" % counter_readings[0])
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	if not governance_line.is_empty():
		lines.append("Pressure line: %s" % governance_line)
	var reentry_line := str(frame.get("reentry_line", "")).strip_edges()
	if not reentry_line.is_empty():
		lines.append("Reentry: %s" % reentry_line)
	var quiet_play_line := str(frame.get("quiet_play_line", "")).strip_edges()
	if not quiet_play_line.is_empty():
		lines.append("Quiet play: %s" % quiet_play_line)
	var social_consequence_line := str(frame.get("social_consequence_line", "")).strip_edges()
	if not social_consequence_line.is_empty():
		lines.append("Social: %s" % social_consequence_line)
	var anomaly_pull := str(frame.get("anomaly_pull", "")).strip_edges()
	if not anomaly_pull.is_empty():
		lines.append("Uneasy pull: %s" % anomaly_pull)
	var inhabitant_line := str(frame.get("inhabitant_line", "")).strip_edges()
	if not inhabitant_line.is_empty():
		lines.append("Presence: %s" % inhabitant_line)
	return guard_lines(lines)

static func build_home_heat_line(frame: Dictionary) -> String:
	var heat := int(frame.get("public_heat", 0))
	if heat >= 8:
		return "Overexposed"
	if heat >= 6:
		return "Hot"
	if heat >= 4:
		return "Tracked"
	if heat >= 2:
		return "Noticed"
	return "Quiet"

static func _build_status_valence(run_record: Dictionary, diagnostics: Dictionary) -> String:
	var interrupted := bool(run_record.get("interrupted", false))
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	var expedition_success := bool(outcome_summary.get("expedition_success", false))
	var sabotage_success := bool(outcome_summary.get("sabotage_success", false))
	var atmosphere := str(diagnostics.get("atmosphere", "steady")).to_lower()
	var recovery_score := int(diagnostics.get("recovery_score", 0))
	var spectacle_pressure := int(diagnostics.get("spectacle_pressure", 0))
	if expedition_success and recovery_score >= 3:
		return "Prestige"
	if sabotage_success and spectacle_pressure >= 3:
		return "Infamy"
	if atmosphere.find("humiliat") != -1:
		return "Disgrace"
	if interrupted:
		return "Unfinished"
	if spectacle_pressure >= 4 and int(diagnostics.get("confrontation_score", 0)) >= 3:
		return "Scandal"
	if recovery_score >= 2 and int(diagnostics.get("expectation_break_score", 0)) >= 2:
		return "Redemption"
	if int(diagnostics.get("near_miss_score", 0)) >= 3:
		return "Almost"
	return "Noted"

static func _build_commentary_style(run_record: Dictionary, diagnostics: Dictionary, status_valence: String) -> String:
	var atmosphere := str(diagnostics.get("atmosphere", "")).to_lower()
	if status_valence in ["Prestige", "Redemption"]:
		return "Heroic"
	if status_valence in ["Scandal", "Infamy", "Disgrace"]:
		return "Skeptical"
	if bool(run_record.get("interrupted", false)):
		return "Wary"
	if atmosphere.find("solemn") != -1 or atmosphere.find("ominous") != -1:
		return "Tragic"
	if int(diagnostics.get("clue_beats", 0)) >= 2 and int(diagnostics.get("spectacle_pressure", 0)) >= 2:
		return "Sociological"
	if int(diagnostics.get("clue_beats", 0)) >= 2:
		return "Analytical"
	return "Measured"

static func _commentary_lanes(diagnostics: Dictionary, profile: Dictionary, status_valence: String, commentary_style: String) -> Array[String]:
	var lanes: Array[String] = [commentary_style]
	var fascination: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("fascination", {}))
	var field: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("myth_field", {}))
	var progress: Dictionary = Dictionary(profile.get("narrative_progress", {}))
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var archive_state: Dictionary = Dictionary(profile.get("archive_state", {}))
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var hidden_curriculum := _string_array(diagnostics.get("hidden_curriculum", []))
	var model_pressure := _string_array(diagnostics.get("model_pressure", []))
	var group_fault_lines := _string_array(diagnostics.get("group_fault_lines", []))
	var gameplay_group_signals := _string_array(diagnostics.get("gameplay_group_signals", []))
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var anomaly_score := int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0))
	var consensus_risk := str(diagnostics.get("consensus_risk", "")).strip_edges()
	if int(diagnostics.get("recovery_score", 0)) >= 3:
		lanes.append("Moral")
	if int(diagnostics.get("spectacle_pressure", 0)) >= 3 or str(fascination.get("phase", "")) in ["active", "saturated"]:
		lanes.append("Spectacle")
	if str(active_crawl.get("bank_vs_push_state", "")) in ["risk_the_story", "push_deeper"]:
		lanes.append("Challenge")
	if int(diagnostics.get("clue_beats", 0)) >= 2 or str(status_valence) == "Unfinished":
		lanes.append("Analytical")
	if Array(diagnostics.get("territory_claims", [])).size() >= 1 or str(diagnostics.get("transition_tension", "")).strip_edges() != "":
		lanes.append("Tactical")
	if str(diagnostics.get("social_temperature", "")).find("rival") != -1 or Array(diagnostics.get("pair_keys", [])).size() >= 2:
		lanes.append("Sociological")
	if str(diagnostics.get("atmosphere", "")).find("solemn") != -1 or str(diagnostics.get("atmosphere", "")).find("ominous") != -1:
		lanes.append("Tragic")
	if Array(diagnostics.get("run_changing_moments", [])).size() >= 2 or Array(archive_state.get("legends", [])).size() >= 2:
		lanes.append("Forensic")
	if not str(_ritual_pressure(diagnostics, profile)).strip_edges().is_empty() or Array(diagnostics.get("ritual_recurrence", [])).size() >= 1:
		lanes.append("Ritual")
	if int(field.get("resonance_count", 0)) >= 2 or not str(_world_pull(profile, diagnostics)).strip_edges().is_empty():
		lanes.append("Systemic")
	if not protocol_state.is_empty() and protocol_state in ["Exposure Protocol", "Intimate Protocol"]:
		lanes.append("Tactical")
		lanes.append("Systemic")
	if hidden_curriculum.size() >= 2:
		lanes.append("Moral")
	if not model_pressure.is_empty():
		lanes.append("Analytical")
	if not group_fault_lines.is_empty():
		lanes.append("Counterweight")
	if not gameplay_group_signals.is_empty():
		lanes.append("Sociological")
	if risk_profile in ["performative", "volatile"]:
		lanes.append("Spectacle")
	if build_stability in ["unstable", "mixed"]:
		lanes.append("Counterweight")
	if risk_profile in ["disciplined", "committed"]:
		lanes.append("Tactical")
	if not consensus_risk.is_empty():
		lanes.append("Counterweight")
	if anomaly_score >= 3:
		lanes.append("Conspiracy")
	if str(progress.get("layer", "public")) != "public" and (Array(diagnostics.get("within_run_echoes", [])).size() >= 2 or not str(_delve_trace(diagnostics, profile)).strip_edges().is_empty()):
		lanes.append("Conspiracy")
	if int(fascination.get("fatigue", 0)) >= 2 or Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
		lanes.append("Counterweight")
	if str(progress.get("layer", "public")) != "public":
		lanes.append("Uneasy archive")
	return _take_unique(lanes, 5)
	
static func _school_reads(lanes: Array[String], diagnostics: Dictionary, profile: Dictionary, status_valence: String) -> Array[String]:
	var result: Array[String] = []
	for lane in lanes:
		var reading := _school_read(lane, diagnostics, profile, status_valence)
		if not reading.is_empty():
			result.append(reading)
	return _take_unique(result, 3)

static func _school_read(lane: String, diagnostics: Dictionary, profile: Dictionary, status_valence: String) -> String:
	var fascination: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("fascination", {}))
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var branch_summary: Dictionary = Dictionary(diagnostics.get("branch_summary", {}))
	var belief_state: Dictionary = Dictionary(diagnostics.get("belief_state", {}))
	var rescue := _first_string(_string_array(diagnostics.get("recovery_ecology", [])), "")
	var collision := _first_string(_string_array(diagnostics.get("quest_collisions", [])), "")
	var persistence := _first_string(_string_array(diagnostics.get("pressure_persistence", [])), "")
	var ritual := _first_string(_string_array(diagnostics.get("ritual_recurrence", [])), "")
	var gesture := _first_string(_string_array(diagnostics.get("symbolic_gestures", [])), "")
	var changing := _first_string(_string_array(diagnostics.get("run_changing_moments", [])), "")
	var branch_name := str(branch_summary.get("branch_family_name", "")).strip_edges()
	var pair_focus := _first_string(_string_array(diagnostics.get("pair_keys", [])), "")
	var world_focus := str(fascination.get("current_focus", "")).strip_edges()
	var expectation := str(active_crawl.get("expectation_pressure", "")).strip_edges()
	var public_challenge := str(active_crawl.get("public_challenge", "")).strip_edges()
	var counterfactual := _first_string(_string_array(diagnostics.get("counterfactual_pressure", [])), "")
	var curriculum := _first_string(_string_array(diagnostics.get("hidden_curriculum", [])), "")
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var consensus_risk := str(diagnostics.get("consensus_risk", "")).strip_edges()
	var doctrine_label := str(diagnostics.get("doctrine_label", "")).strip_edges()
	var doctrine_family := str(diagnostics.get("doctrine_family", "")).strip_edges()
	var doctrine_pressure_line := str(diagnostics.get("doctrine_pressure_line", "")).strip_edges()
	var doctrine_world_goal := str(diagnostics.get("doctrine_world_goal", "")).strip_edges()
	var anomaly_signal := _first_string(_string_array(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("signals", [])), "")
	var build_identity := str(diagnostics.get("build_identity", "")).strip_edges()
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var resource_pressure := _first_string(_string_array(diagnostics.get("resource_pressure", [])), "")
	var inhabitant_pressure := _first_string(_string_array(diagnostics.get("inhabitant_pressure", [])), "")
	var synergy_label := _first_string(_string_array(diagnostics.get("synergy_labels", [])), "")
	var feature_signal := _first_string(_string_array(diagnostics.get("gameplay_feature_signals", [])), "")
	var group_signal := _first_string(_string_array(diagnostics.get("gameplay_group_signals", [])), "")
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var group_fault_line := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	var rescue_answer := str(belief_state.get("rescue_answer", "")).strip_edges()
	var fault_line := str(belief_state.get("fault_line", "")).strip_edges()
	var collapse_line := str(belief_state.get("collapse_line", "")).strip_edges()
	var myth_attractor := str(belief_state.get("myth_attractor", "")).strip_edges()
	var attention_sink := str(belief_state.get("attention_sink", "")).strip_edges()
	match lane:
		"Heroic":
			if not rescue_answer.is_empty():
				return "Heroic read: %s." % rescue_answer
			if not rescue.is_empty():
				return "Heroic read: %s turned the pressure into duty." % rescue
			if not expectation.is_empty():
				return "Heroic read: the crawl kept trying to answer %s cleanly." % expectation.to_lower()
			return "Heroic read: the run kept trying to answer pressure with duty."
		"Skeptical":
			if risk_profile == "performative" and not model_pressure.is_empty():
				return "Skeptical read: %s may have looked cleaner because it knew how to draw a witness." % model_pressure
			if not consensus_risk.is_empty():
				return "Skeptical read: %s." % consensus_risk
			if not collision.is_empty():
				return "Skeptical read: %s may have mattered less than the appetite around it." % collision
			if not world_focus.is_empty():
				return "Skeptical read: %s may have made the hotter answer look cleaner than it was." % world_focus
			return "Skeptical read: the loudest answer may not have been the cleanest one."
		"Measured":
			if not build_stability.is_empty() and not model_pressure.is_empty():
				return "Measured read: %s, but %s never fully settled." % [model_pressure, build_stability.to_lower()]
			if not counterfactual.is_empty():
				return "Measured read: %s, but it still has not settled." % counterfactual
			if not persistence.is_empty():
				return "Measured read: %s kept returning, but the meaning is still arguable." % persistence
			return "Measured read: the pattern is visible, but still arguable."
		"Wary":
			if not group_fault_line.is_empty():
				return "Wary read: %s." % group_fault_line
			if not collapse_line.is_empty():
				return "Wary read: %s." % collapse_line
			if not branch_name.is_empty():
				return "Wary read: %s never let the run trust its own shape." % branch_name
			return "Wary read: the run never fully trusted its own shape."
		"Moral":
			if not risk_profile.is_empty() and not model_pressure.is_empty() and risk_profile in ["disciplined", "committed"]:
				return "Moral read: %s mattered because the run kept choosing %s." % [model_pressure, risk_profile]
			if not curriculum.is_empty():
				return "Moral read: the run kept being asked for %s." % curriculum
			if not rescue.is_empty():
				return "Moral read: %s mattered as much as the outcome." % rescue
			if not public_challenge.is_empty():
				return "Moral read: %s was also an obligation, not only a dare." % public_challenge.to_lower()
			return "Moral read: the obligation mattered as much as the outcome."
		"Spectacle":
			if not model_pressure.is_empty() and risk_profile == "performative":
				return "Spectacle read: %s kept turning into a public answer shape." % model_pressure
			if not world_focus.is_empty():
				return "Spectacle read: %s kept inviting the hotter answer." % world_focus
			return "Spectacle read: the pressure kept inviting a hotter answer."
		"Challenge":
			if not doctrine_label.is_empty() and not model_pressure.is_empty():
				return "Challenge read: %s keeps asking whether %s can still hold." % [doctrine_label, model_pressure.to_lower()]
			if not model_pressure.is_empty() and not expectation.is_empty():
				return "Challenge read: %s was being tested against %s." % [model_pressure, expectation.to_lower()]
			if not public_challenge.is_empty():
				return "Challenge read: the crawl was being asked to prove %s." % public_challenge.to_lower()
			if not counterfactual.is_empty():
				return "Challenge read: %s is still what this story is being measured against." % counterfactual
			if not expectation.is_empty():
				return "Challenge read: the crawl was being asked to answer %s again." % expectation.to_lower()
			return "Challenge read: the crawl was being asked to prove itself again."
		"Analytical":
			if not doctrine_family.is_empty() and not doctrine_world_goal.is_empty():
				return "Analytical read: %s was selected to pressure %s." % [_title_case(doctrine_family.replace("_", " ")), doctrine_world_goal.to_lower()]
			if not model_pressure.is_empty() and not group_fault_line.is_empty():
				return "Analytical read: %s kept opening %s." % [model_pressure, group_fault_line.to_lower()]
			if not fault_line.is_empty():
				return "Analytical read: %s." % fault_line
			if not build_identity.is_empty() and not resource_pressure.is_empty():
				return "Analytical read: %s made %s the cost line." % [build_identity, resource_pressure.to_lower()]
			if not changing.is_empty():
				return "Analytical read: %s is where the run started resolving into a pattern." % changing
			return "Analytical read: repeated signals made the story easier to track than to settle."
		"Forensic":
			if not model_pressure.is_empty() and not feature_signal.is_empty():
				return "Forensic read: %s kept recurring through %s." % [model_pressure, feature_signal.to_lower()]
			if not myth_attractor.is_empty():
				return "Forensic read: %s." % myth_attractor
			if not synergy_label.is_empty():
				return "Forensic read: %s kept reappearing with too much continuity to ignore." % synergy_label.capitalize()
			if not persistence.is_empty():
				return "Forensic read: %s lines up too neatly against older echoes." % persistence
			return "Forensic read: the strongest turns line up against older echoes."
		"Tactical":
			if not doctrine_label.is_empty() and not resource_pressure.is_empty():
				return "Tactical read: %s made %s the route tax." % [doctrine_label, resource_pressure.to_lower()]
			if not model_pressure.is_empty() and not resource_pressure.is_empty():
				return "Tactical read: %s only worked because %s kept narrowing the route." % [model_pressure, resource_pressure.to_lower()]
			if not protocol_state.is_empty():
				return "Tactical read: %s changed how safe any answer looked." % protocol_state
			if not inhabitant_pressure.is_empty():
				return "Tactical read: %s kept forcing the route to answer in public." % inhabitant_pressure.capitalize()
			if not changing.is_empty():
				return "Tactical read: %s mattered because space and timing made it unavoidable." % changing
			return "Tactical read: thresholds, corridors, and timing carried the argument."
		"Sociological":
			if not group_signal.is_empty():
				return "Sociological read: %s kept teaching the group what kind of answer to expect." % group_signal
			if not pair_focus.is_empty():
				return "Sociological read: %s kept changing what the same gesture meant." % _pair_label(pair_focus).to_lower()
			if not build_identity.is_empty():
				return "Sociological read: %s changed what the group expected this answer to look like." % build_identity
			if not attention_sink.is_empty():
				return "Sociological read: %s." % attention_sink
			return "Sociological read: the group shape changed what every gesture meant."
		"Tragic":
			if not build_stability.is_empty() and build_stability in ["unstable", "mixed"]:
				return "Tragic read: the answer kept forming, but the shape never fully held."
			if not counterfactual.is_empty():
				return "Tragic read: %s is what makes the ending feel heavier." % counterfactual
			if not persistence.is_empty():
				return "Tragic read: even when %s steadied, it still carried a cost." % persistence.to_lower()
			return "Tragic read: even the steadier answers arrived with a cost."
		"Ritual":
			if not doctrine_label.is_empty() and not ritual.is_empty():
				return "Ritual read: %s kept making %s feel expected." % [doctrine_label, ritual.to_lower()]
			if not model_pressure.is_empty() and not ritual.is_empty():
				return "Ritual read: %s kept making %s feel expected." % [model_pressure, ritual.to_lower()]
			if not ritual.is_empty():
				return "Ritual read: %s was already starting to feel expected." % ritual.to_lower()
			if not gesture.is_empty():
				return "Ritual read: %s carried more weight than the act alone." % gesture.to_lower()
			return "Ritual read: the pressure kept asking for a gesture it already knew."
		"Systemic":
			if not doctrine_label.is_empty() and not doctrine_world_goal.is_empty():
				return "Systemic read: %s kept steering the run toward %s." % [doctrine_label, doctrine_world_goal.to_lower()]
			if not model_pressure.is_empty() and not protocol_state.is_empty():
				return "Systemic read: %s kept getting reinforced under %s." % [model_pressure, protocol_state]
			if not curriculum.is_empty() and not protocol_state.is_empty():
				return "Systemic read: %s kept pressing %s." % [protocol_state, curriculum]
			if not build_identity.is_empty() and not resource_pressure.is_empty():
				return "Systemic read: %s and %s kept reinforcing the same answer." % [build_identity, resource_pressure.to_lower()]
			if not branch_name.is_empty() and not world_focus.is_empty():
				return "Systemic read: %s and %s kept reinforcing the same answer." % [branch_name, world_focus.to_lower()]
			return "Systemic read: branch, item, pair, and crawl pressure kept reinforcing the same answer."
		"Conspiracy":
			if not doctrine_pressure_line.is_empty() and not anomaly_signal.is_empty():
				return "Conspiracy read: %s and %s keep lining up too neatly." % [doctrine_pressure_line, anomaly_signal.to_lower()]
			if not model_pressure.is_empty() and not anomaly_signal.is_empty():
				return "Conspiracy read: %s and %s keep lining up too neatly." % [model_pressure, anomaly_signal.to_lower()]
			if not anomaly_signal.is_empty():
				return "Conspiracy read: %s keeps returning too neatly." % anomaly_signal
			if not synergy_label.is_empty() and synergy_label.find("ritual") != -1:
				return "Conspiracy read: %s is starting to feel rehearsed." % synergy_label.capitalize()
			if not persistence.is_empty():
				return "Conspiracy read: %s feels too exact to dismiss as luck." % persistence
			return "Conspiracy read: the recurrence feels too exact to dismiss as luck."
		"Counterweight":
			if not group_fault_line.is_empty():
				return "Counterweight read: %s is why the obvious story still feels too clean." % group_fault_line
			if not consensus_risk.is_empty():
				return "Counterweight read: %s." % consensus_risk
			if not counterfactual.is_empty():
				return "Counterweight read: %s is still crowding out the cleaner story." % counterfactual
			if not world_focus.is_empty() and int(fascination.get("fatigue", 0)) >= 2:
				return "Counterweight read: the culture may be simplifying %s because it is tired of it." % world_focus
			return "Counterweight read: the obvious story may be too simple for the pressure it survived."
		"Uneasy archive":
			if not anomaly_signal.is_empty():
				return "Archive read: %s is starting to feel like a known disturbance." % anomaly_signal
			if str(fascination.get("current_focus", "")).strip_edges().is_empty():
				return "Archive read: this pressure feels older than the run that carried it."
			return "Archive read: this looks like another answer to %s." % str(fascination.get("current_focus", "")).to_lower()
		_:
			if status_valence in ["Prestige", "Redemption"]:
				return "Counter-read: praise and burden are both hanging over this run."
			if status_valence in ["Scandal", "Infamy", "Disgrace"]:
				return "Counter-read: failure, appetite, and judgment are all still in the frame."
			return ""

static func _school_tension(lanes: Array[String], interpretation_split: Array[String], counter_readings: Array[String]) -> String:
	if lanes.size() >= 3 and not interpretation_split.is_empty():
		return "%s, %s, and %s schools are all trying to claim %s." % [lanes[0], lanes[1], lanes[2], interpretation_split[0]]
	if lanes.size() >= 2 and not interpretation_split.is_empty():
		return "%s school and %s school keep pulling this toward %s." % [lanes[0], lanes[1], interpretation_split[0]]
	if lanes.size() >= 2 and not counter_readings.is_empty():
		return "%s school leans one way while %s school keeps insisting on %s." % [lanes[0], lanes[1], counter_readings[0]]
	if not counter_readings.is_empty():
		return counter_readings[0]
	return ""

static func _quest_briefs(diagnostics: Dictionary, profile: Dictionary) -> Array[String]:
	var result: Array[String] = []
	result.append_array(_string_array(diagnostics.get("quest_pressure", [])))
	result.append_array(_string_array(diagnostics.get("quest_collisions", [])))
	result.append_array(_string_array(diagnostics.get("ritual_recurrence", [])))
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var expectation := str(active_crawl.get("expectation_pressure", "")).strip_edges()
	if not expectation.is_empty():
		result.append(expectation)
	match str(active_crawl.get("bank_vs_push_state", "")):
		"bank_now":
			result.append("Bank the crawl")
		"push_deeper":
			result.append("Push the crawl")
		"risk_the_story":
			result.append("Risk the saga")
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var recent_pairs := _string_array(fabric.get("recent_pairs", []))
	if not recent_pairs.is_empty():
		var pair_entry: Dictionary = Dictionary(Dictionary(fabric.get("pairs", {})).get(recent_pairs[0], {}))
		result.append_array(_string_array(pair_entry.get("obligations", [])))
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	if not recent_crews.is_empty():
		var crew_entry: Dictionary = Dictionary(Dictionary(fabric.get("crews", {})).get(recent_crews[0], {}))
		result.append_array(_string_array(crew_entry.get("obligations", [])))
	var fascination: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("fascination", {}))
	var focus := str(fascination.get("current_focus", "")).strip_edges()
	if not focus.is_empty() and str(fascination.get("phase", "")) in ["active", "saturated"]:
		result.append("World focus: %s" % focus)
	var clipped := _take_unique(result, 4)
	if clipped.is_empty():
		return ["Steady challenge"]
	return clipped

static func _public_heat(diagnostics: Dictionary, status_valence: String) -> int:
	var heat := int(diagnostics.get("legend_density_score", 0))
	heat += int(diagnostics.get("spectacle_pressure", 0))
	heat += int(diagnostics.get("revisit_score", 0))
	if status_valence in ["Scandal", "Prestige", "Infamy", "Redemption"]:
		heat += 2
	return clampi(heat, 0, 12)

static func _finish_identity(run_record: Dictionary, diagnostics: Dictionary, status_valence: String) -> String:
	var momentum := str(diagnostics.get("momentum_profile", "steadying")).replace("_", " ")
	var atmosphere := str(diagnostics.get("atmosphere", "steady")).replace("_", " ")
	var counterfactual := _string_array(diagnostics.get("expectation_breaks", []))
	if not counterfactual.is_empty():
		return "%s after %s" % [counterfactual[0], momentum]
	if status_valence == "Prestige":
		return "Held together through %s pressure" % atmosphere
	if status_valence == "Redemption":
		return "Recovered after %s pressure" % atmosphere
	if status_valence == "Scandal":
		return "Overheated into %s pressure" % atmosphere
	if bool(run_record.get("interrupted", false)):
		return "Left hanging under %s pressure" % momentum
	return "Ended with %s momentum" % momentum

static func _broadcast_headline(run_record: Dictionary, diagnostics: Dictionary, status_valence: String) -> String:
	var run_shape := str(_first_string(Array(diagnostics.get("run_shapes", [])), "run"))
	var atmosphere := str(diagnostics.get("atmosphere", "steady")).replace("_", " ")
	match status_valence:
		"Prestige":
			return "A %s run turned %s" % [atmosphere, run_shape]
		"Redemption":
			return "A loaded quest bent toward redemption"
		"Scandal":
			return "A %s run pushed into scandal" % atmosphere
		"Infamy":
			return "The run took the hotter path and everyone noticed"
		"Disgrace":
			return "A run under heat collapsed into public embarrassment"
		"Unfinished":
			return "The run never fully settled"
		"Almost":
			return "The run nearly became something larger"
		_:
			return "A %s run built its own pressure" % atmosphere

static func _broadcast_subhead(diagnostics: Dictionary, commentary_style: String) -> String:
	var momentum := str(diagnostics.get("momentum_profile", "steadying")).replace("_", " ")
	var social_temperature := str(diagnostics.get("social_temperature", "quiet_discipline")).replace("_", " ")
	return "%s tone | %s momentum | %s group feel" % [commentary_style, momentum, social_temperature]

static func _open_questions(diagnostics: Dictionary, profile: Dictionary) -> Array[String]:
	var questions: Array[String] = []
	for question in _string_array(diagnostics.get("anticipation_hooks", [])):
		if not questions.has(question):
			questions.append(question)
	if questions.is_empty():
		questions.append("Will this pressure pattern return?")
	var last_run: Dictionary = Dictionary(profile.get("last_run", {}))
	if not last_run.is_empty() and bool(last_run.get("interrupted", false)):
		questions.append("Does the interruption change the story or delay it?")
	return questions.slice(0, mini(questions.size(), 3))

static func _interpretation_split(diagnostics: Dictionary, status_valence: String) -> Array[String]:
	var result: Array[String] = []
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	if status_valence in ["Prestige", "Redemption"]:
		result.append("heroism vs overreach")
	if status_valence in ["Scandal", "Infamy", "Disgrace"]:
		result.append("desperation vs performance")
	if int(diagnostics.get("expectation_break_score", 0)) >= 1:
		result.append("restraint vs calculation")
	if int(diagnostics.get("recovery_score", 0)) >= 2:
		result.append("duty vs obligation")
	if int(diagnostics.get("spectacle_pressure", 0)) >= 3 and int(diagnostics.get("recovery_score", 0)) >= 2:
		result.append("care vs performance")
	if str(diagnostics.get("social_temperature", "")).find("discipline") != -1:
		result.append("discipline vs caution")
	if build_stability == "unstable":
		result.append("forming answer vs collapsing answer")
	if risk_profile == "performative":
		result.append("public answer vs private need")
	if not model_pressure.is_empty():
		result.append("answer shape vs cleaner story")
	return guard_lines(result.slice(0, mini(result.size(), 3)))

static func _counter_readings(diagnostics: Dictionary, profile: Dictionary, status_valence: String) -> Array[String]:
	var result: Array[String] = []
	var fascination: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("fascination", {}))
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var belief_state: Dictionary = Dictionary(diagnostics.get("belief_state", {}))
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var consensus_risk := str(diagnostics.get("consensus_risk", "")).strip_edges()
	var counterfactual := _first_string(_string_array(diagnostics.get("counterfactual_pressure", [])), "")
	var curriculum := _first_string(_string_array(diagnostics.get("hidden_curriculum", [])), "")
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var group_fault := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	if status_valence in ["Scandal", "Infamy"]:
		result.append("bravery vs overreach")
	if status_valence in ["Prestige", "Redemption"]:
		result.append("duty vs self-preservation")
	if int(diagnostics.get("expectation_break_score", 0)) >= 1:
		result.append("restraint vs calculation")
	if str(fascination.get("phase", "")) in ["active", "saturated"] and int(diagnostics.get("spectacle_pressure", 0)) >= 2:
		result.append("public challenge vs private need")
	if int(diagnostics.get("near_miss_score", 0)) >= 2:
		result.append("almost-legend vs cautionary failure")
	if str(active_crawl.get("bank_vs_push_state", "")) == "push_deeper":
		result.append("push deeper vs protect the crawl")
	if Array(diagnostics.get("quest_collisions", [])).size() >= 1:
		result.append("duty collision vs clean extraction")
	if Array(diagnostics.get("recovery_ecology", [])).size() >= 2:
		result.append("repair vs self-preservation")
	if int(diagnostics.get("spectacle_pressure", 0)) >= 3 and str(diagnostics.get("social_temperature", "")).find("discipline") != -1:
		result.append("show pressure vs restraint")
	if int(fascination.get("fatigue", 0)) >= 2 and not str(fascination.get("current_focus", "")).strip_edges().is_empty():
		result.append("resolution vs repetition")
	if not str(_ritual_pressure(diagnostics, profile)).strip_edges().is_empty():
		result.append("ritual repetition vs lived necessity")
	if str(active_crawl.get("bank_vs_push_state", "")) == "hold_together":
		result.append("hold together vs public pull")
	if not counterfactual.is_empty():
		result.append("expected answer vs what almost happened")
	if not consensus_risk.is_empty():
		result.append("public certainty vs a messier read")
	if not curriculum.is_empty():
		result.append("what the pressure wanted vs what the run gave back")
	if not model_pressure.is_empty():
		result.append("public read vs the answer shape underneath it")
	if not group_fault.is_empty():
		result.append("visible fault line vs cleaner collective story")
	if build_stability == "unstable":
		result.append("forming answer vs answer that never settled")
	if risk_profile == "performative":
		result.append("show answer vs costly answer")
	if not protocol_state.is_empty() and protocol_state in ["Exposure Protocol", "Intimate Protocol"]:
		result.append("survival logic vs public mythology")
	if not str(belief_state.get("fault_line", "")).strip_edges().is_empty():
		result.append("social fault line vs cleaner story")
	return _take_unique(result, 3)

static func _delve_trace(diagnostics: Dictionary, profile: Dictionary) -> String:
	var progress: Dictionary = Dictionary(profile.get("narrative_progress", {}))
	var layer := str(progress.get("layer", "public"))
	var flags := _string_array(progress.get("post_core_flags", []))
	var anomaly: Dictionary = Dictionary(diagnostics.get("anomaly_sensitivity", {}))
	var anomaly_signals := _string_array(anomaly.get("signals", []))
	var curriculum := _string_array(diagnostics.get("hidden_curriculum", []))
	var dominant_minds := _string_array(diagnostics.get("run_identity_dominant_minds", []))
	var motifs := _string_array(diagnostics.get("run_identity_symbolic_motifs", []))
	var pacing_profile := str(diagnostics.get("run_identity_pacing_profile", "")).strip_edges()
	var archive_tone := str(diagnostics.get("run_identity_archive_tone", "")).strip_edges()
	var group_tension_bias := str(diagnostics.get("run_identity_group_tension_bias", "")).strip_edges()
	if not dominant_minds.is_empty() and not motifs.is_empty():
		return "%s kept shaping the run through %s." % [dominant_minds[0], motifs[0].to_lower()]
	if not pacing_profile.is_empty() and not Array(diagnostics.get("run_identity_pressure_grammar", [])).is_empty():
		return "%s pacing kept leaning into %s." % [pacing_profile, str(Array(diagnostics.get("run_identity_pressure_grammar", []))[0]).to_lower()]
	if not archive_tone.is_empty() and not group_tension_bias.is_empty():
		return "%s kept reading like %s." % [group_tension_bias.capitalize(), archive_tone.to_lower()]
	if layer != "public" and Array(diagnostics.get("within_run_echoes", [])).size() >= 2:
		return "The route felt uncomfortably familiar, as if it expected the same answer."
	if flags.has("field_resonance") and not anomaly_signals.is_empty():
		return "The pressure kept recognizing %s before the run had finished deciding." % anomaly_signals[0].to_lower()
	if flags.has("attention_lock") and not curriculum.is_empty():
		return "The same lesson kept returning with an increasingly uneasy patience."
	if flags.has("echo_strain") and int(diagnostics.get("revisit_score", 0)) >= 3:
		return "The pressure returned with an almost knowing calm."
	if flags.has("ritual_return") and Array(diagnostics.get("symbolic_gestures", [])).size() >= 1:
		return "The same gesture seemed to matter more than it should."
	if int(diagnostics.get("revisit_score", 0)) >= 4:
		return "The pressure returned in a shape the Delve seemed to recognize."
	if int(anomaly.get("score", 0)) >= 4:
		return "The run kept leaning toward a pattern that felt older than it should."
	if Array(diagnostics.get("within_run_echoes", [])).size() >= 2:
		return "The run kept echoing itself."
	return ""

static func _challenge_attention(diagnostics: Dictionary, profile: Dictionary, status_valence: String) -> String:
	var fascination: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("fascination", {}))
	var focus := str(fascination.get("current_focus", "")).strip_edges()
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var quest_pressure := _string_array(diagnostics.get("quest_pressure", []))
	var expectation := str(active_crawl.get("expectation_pressure", "")).strip_edges()
	var public_challenge := str(active_crawl.get("public_challenge", "")).strip_edges()
	var promise_pressure := str(active_crawl.get("promise_pressure", "")).strip_edges()
	var recent_pairs := _string_array(fabric.get("recent_pairs", []))
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	var counterfactual := _first_string(_string_array(diagnostics.get("counterfactual_pressure", [])), "")
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var group_fault_line := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	var doctrine_label := str(diagnostics.get("doctrine_label", "")).strip_edges()
	var doctrine_pressure_line := str(diagnostics.get("doctrine_pressure_line", "")).strip_edges()
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var belief_state: Dictionary = Dictionary(diagnostics.get("belief_state", {}))
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	if not public_challenge.is_empty() and not promise_pressure.is_empty():
		return "%s is colliding with %s" % [public_challenge, promise_pressure.to_lower()]
	if not doctrine_label.is_empty() and not doctrine_pressure_line.is_empty():
		return "%s keeps tightening around %s" % [doctrine_label, doctrine_pressure_line.to_lower()]
	if not model_pressure.is_empty() and not group_fault_line.is_empty():
		return "%s keeps attracting judgment because %s" % [model_pressure, group_fault_line.to_lower()]
	if risk_profile == "performative" and not model_pressure.is_empty():
		return "%s is drawing attention because it keeps answering in public." % model_pressure
	if not counterfactual.is_empty() and not public_challenge.is_empty():
		return "%s is now being judged against %s" % [public_challenge, counterfactual.to_lower()]
	if not focus.is_empty() and str(fascination.get("phase", "")) in ["active", "saturated"]:
		return "%s is drawing live attention" % focus
	if not focus.is_empty() and str(fascination.get("phase", "")) == "fatigued":
		return "%s is still being watched, but the culture wants a different answer" % focus
	if not str(belief_state.get("fault_line", "")).strip_edges().is_empty() and not expectation.is_empty():
		return "%s is still carrying a visible fault line" % expectation
	if not expectation.is_empty() and str(active_crawl.get("stage", "")) in ["patterned", "legible"]:
		return "%s is already attached to this crawl" % expectation
	if build_stability in ["unstable", "mixed"] and not expectation.is_empty():
		return "%s is carrying a run that still looks unstable" % expectation
	if not promise_pressure.is_empty() and str(active_crawl.get("stage", "")) in ["patterned", "legible"]:
		return "%s is now riding with the crawl." % promise_pressure
	if protocol_state == "Exposure Protocol" and not expectation.is_empty():
		return "%s now feels harsher under low-density pressure" % expectation
	if not public_challenge.is_empty():
		return "%s is starting to feel public." % public_challenge
	if not quest_pressure.is_empty() and status_valence in ["Prestige", "Scandal", "Redemption", "Almost"]:
		return "%s is becoming the thing people are waiting on" % quest_pressure[0]
	if not quest_pressure.is_empty():
		return "%s is carrying the run's expectation" % quest_pressure[0]
	if not recent_pairs.is_empty() and str(active_crawl.get("stage", "")) in ["patterned", "legible"]:
		return "The same pair pressure is starting to draw attention."
	if not recent_crews.is_empty() and str(active_crawl.get("stage", "")) in ["patterned", "legible"]:
		return "The current crew pressure is starting to look like a public challenge."
	return ""

static func _ritual_pressure(diagnostics: Dictionary, profile: Dictionary) -> String:
	var repeats := _string_array(diagnostics.get("within_run_echoes", []))
	var rituals := _string_array(diagnostics.get("ritual_recurrence", []))
	var changing := _string_array(diagnostics.get("run_changing_moments", []))
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	if not repeats.is_empty():
		return "%s kept returning as if it were becoming ritual" % repeats[0].to_lower()
	if not model_pressure.is_empty() and model_pressure.find("ritual") != -1:
		return "%s kept coming back like an answer the run already knew." % model_pressure
	if not rituals.is_empty():
		return "%s started feeling expected" % rituals[0].to_lower()
	if not changing.is_empty() and Array(diagnostics.get("symbolic_gestures", [])).size() >= 1:
		return "%s started to feel like the moment everyone was waiting for" % changing[0].to_lower()
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var recent_pairs := _string_array(fabric.get("recent_pairs", []))
	if not recent_pairs.is_empty():
		var pair_entry: Dictionary = Dictionary(Dictionary(fabric.get("pairs", {})).get(recent_pairs[0], {}))
		var obligation := _first_string(Array(pair_entry.get("obligations", [])), "")
		if not obligation.is_empty():
			return "%s is starting to feel owed" % obligation.to_lower()
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	if not recent_crews.is_empty():
		var crew_entry: Dictionary = Dictionary(Dictionary(fabric.get("crews", {})).get(recent_crews[0], {}))
		var crew_obligation := _first_string(Array(crew_entry.get("obligations", [])), "")
		if not crew_obligation.is_empty():
			return "%s is starting to feel like a crew promise" % crew_obligation.to_lower()
	var recent := _string_array(Dictionary(profile.get("persona_state", {})).get("public_expectations", []))
	if not recent.is_empty():
		return "%s is starting to feel expected" % recent[0].to_lower()
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var public_challenge := str(active_crawl.get("public_challenge", "")).strip_edges()
	if not public_challenge.is_empty():
		return "%s is starting to feel like a recurring dare" % public_challenge.to_lower()
	var crawl_promise := _first_string(_string_array(active_crawl.get("crawl_promises", [])), "")
	if not crawl_promise.is_empty():
		return "%s is starting to feel owed" % crawl_promise.to_lower()
	return ""

static func _world_pull(profile: Dictionary, diagnostics: Dictionary) -> String:
	var fascination: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("fascination", {}))
	var field: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("myth_field", {}))
	var gravity: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("cultural_gravity", {}))
	var focus := str(fascination.get("current_focus", "")).strip_edges()
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var protocol_state := str(diagnostics.get("protocol_state_hint", "")).strip_edges()
	var doctrine_label := str(diagnostics.get("doctrine_label", "")).strip_edges()
	var doctrine_world_goal := str(diagnostics.get("doctrine_world_goal", "")).strip_edges()
	var curriculum := _first_string(_string_array(diagnostics.get("hidden_curriculum", [])), "")
	var anomaly: Dictionary = Dictionary(diagnostics.get("anomaly_sensitivity", {}))
	var anomaly_signals := _string_array(anomaly.get("signals", []))
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var group_fault_line := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	var build_identity := str(diagnostics.get("build_identity", "")).strip_edges()
	var narrative_pressure_lines := _string_array(diagnostics.get("narrative_pressure_lines", []))
	var experiment_surface_lines := _string_array(diagnostics.get("experiment_surface_lines", []))
	if int(diagnostics.get("narrative_pressure_resonance", 0)) >= 3 and not narrative_pressure_lines.is_empty():
		if not experiment_surface_lines.is_empty() and experiment_surface_lines[0] != narrative_pressure_lines[0]:
			return "%s %s" % [narrative_pressure_lines[0], experiment_surface_lines[0]]
		return narrative_pressure_lines[0]
	if not experiment_surface_lines.is_empty():
		return experiment_surface_lines[0]
	if not focus.is_empty() and int(fascination.get("current_heat", 0)) >= 4:
		return "The world keeps leaning toward %s" % focus.to_lower()
	if str(fascination.get("phase", "")) == "fatigued" and not focus.is_empty():
		return "The world is still watching %s, but with a harder edge." % focus.to_lower()
	if not doctrine_label.is_empty() and not doctrine_world_goal.is_empty():
		return "%s is trying to keep %s in view." % [doctrine_label, doctrine_world_goal.to_lower()]
	var gravity_label := str(gravity.get("top_label", "")).strip_edges()
	if not gravity_label.is_empty() and int(gravity.get("top_gravity", 0)) >= 8:
		return "%s is pulling nearby stories into its orbit." % gravity_label
	var successor_hint := str(Dictionary(field.get("top_successor", {})).get("hint", "")).strip_edges()
	if not successor_hint.is_empty() and int(field.get("resonance_count", 0)) >= 2:
		return "Older stories keep trying to recast themselves toward %s" % successor_hint.to_lower()
	if not model_pressure.is_empty() and not build_identity.is_empty():
		return "%s is starting to inherit the pull around %s." % [build_identity, model_pressure.to_lower()]
	if not group_fault_line.is_empty() and not protocol_state.is_empty():
		return "%s is making %s more visible." % [protocol_state, group_fault_line.to_lower()]
	if not curriculum.is_empty() and not protocol_state.is_empty():
		return "%s is making %s feel increasingly unavoidable." % [protocol_state, curriculum]
	if int(anomaly.get("score", 0)) >= 4 and not anomaly_signals.is_empty():
		return "%s keeps returning with the feel of an old answer." % anomaly_signals[0].capitalize()
	if str(active_crawl.get("bank_vs_push_state", "")) == "push_deeper" and int(active_crawl.get("risk_stake", 0)) >= 6:
		return "The crawl feels like it wants another answer"
	var shapes := _string_array(diagnostics.get("run_shapes", []))
	if not shapes.is_empty() and int(diagnostics.get("revisit_score", 0)) >= 3:
		return "This run is slipping toward a familiar shape"
	return ""

static func _build_line(diagnostics: Dictionary, profile: Dictionary) -> String:
	var build_identity := str(diagnostics.get("build_identity", "")).strip_edges()
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var synergy_labels := _string_array(diagnostics.get("synergy_labels", []))
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	if not build_identity.is_empty() and not model_pressure.is_empty():
		if build_stability == "stable":
			return "%s kept settling into %s." % [build_identity, model_pressure.to_lower()]
		if build_stability == "unstable":
			return "%s kept reaching for %s without fully holding it." % [build_identity, model_pressure.to_lower()]
		if not risk_profile.is_empty():
			return "%s kept answering through %s in a %s way." % [build_identity, model_pressure.to_lower(), risk_profile]
		return "%s kept answering through %s." % [build_identity, model_pressure.to_lower()]
	if not build_identity.is_empty() and not synergy_labels.is_empty():
		return "%s answered through %s." % [build_identity, synergy_labels[0].to_lower()]
	if not build_identity.is_empty():
		return "%s kept shaping the answer." % build_identity
	var expectations := _string_array(Dictionary(profile.get("persona_state", {})).get("public_expectations", []))
	if not expectations.is_empty():
		return "%s is still shaping how this run is being read." % expectations[0]
	return ""

static func _resource_line(diagnostics: Dictionary, _profile: Dictionary) -> String:
	var resource_pressure := _string_array(diagnostics.get("resource_pressure", []))
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	var item_ecology_bias := str(diagnostics.get("run_identity_item_ecology_bias", "")).strip_edges()
	if not resource_pressure.is_empty():
		if risk_profile == "disciplined":
			return "%s kept making the careful answer look necessary." % resource_pressure[0].capitalize()
		return "%s kept changing what answers looked affordable." % resource_pressure[0].capitalize()
	if not item_ecology_bias.is_empty():
		return "%s kept shaping which tools felt worth the commitment." % item_ecology_bias.capitalize()
	return ""

static func _inhabitant_line(diagnostics: Dictionary, _profile: Dictionary) -> String:
	var pressure := _string_array(diagnostics.get("ecology_signal_highlights", []))
	if pressure.is_empty():
		pressure = _string_array(diagnostics.get("inhabitant_pressure", []))
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	if not pressure.is_empty():
		if not model_pressure.is_empty():
			return "%s kept leaning on %s." % [pressure[0].capitalize(), model_pressure.to_lower()]
		return "%s kept leaning on the route." % pressure[0].capitalize()
	return ""

static func _belief_line(diagnostics: Dictionary, profile: Dictionary) -> String:
	var belief_state: Dictionary = Dictionary(diagnostics.get("belief_state", {}))
	for key in ["rescue_answer", "fault_line", "collapse_line", "myth_attractor", "attention_sink"]:
		var line := str(belief_state.get(key, "")).strip_edges()
		if not line.is_empty():
			return line
	var group_fault_line := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	if not group_fault_line.is_empty():
		return group_fault_line
	var group_tension_bias := str(diagnostics.get("run_identity_group_tension_bias", "")).strip_edges()
	if not group_tension_bias.is_empty():
		return group_tension_bias.capitalize()
	var recent := _string_array(Dictionary(profile.get("persona_state", {})).get("public_expectations", []))
	if not recent.is_empty():
		return "The public is already reading this through %s." % recent[0].to_lower()
	return ""

static func _counterfactual_line(diagnostics: Dictionary, profile: Dictionary) -> String:
	var line := _first_string(_string_array(diagnostics.get("counterfactual_pressure", [])), "")
	if not line.is_empty():
		return line
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	if not model_pressure.is_empty() and build_stability == "unstable":
		return "%s was never as settled as the public answer wanted it to be." % model_pressure.capitalize()
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var expectation := str(active_crawl.get("expectation_pressure", "")).strip_edges()
	if not expectation.is_empty() and Array(diagnostics.get("expectation_breaks", [])).size() >= 1:
		return "The crawl is still being measured against %s." % expectation.to_lower()
	return ""

static func _curriculum_line(diagnostics: Dictionary, profile: Dictionary) -> String:
	var curriculum := _first_string(_string_array(diagnostics.get("hidden_curriculum", [])), "")
	if not curriculum.is_empty():
		return "The pressure keeps asking for %s." % curriculum
	var protocol_hooks := _string_array(diagnostics.get("protocol_hooks", []))
	if not protocol_hooks.is_empty():
		return "The route keeps tightening around %s." % protocol_hooks[0].to_lower()
	var ritual := str(_ritual_pressure(diagnostics, profile)).strip_edges()
	if not ritual.is_empty():
		return ritual
	return ""

static func _anomaly_pull(diagnostics: Dictionary, profile: Dictionary) -> String:
	var anomaly: Dictionary = Dictionary(diagnostics.get("anomaly_sensitivity", {}))
	var signals := _string_array(anomaly.get("signals", []))
	if int(anomaly.get("score", 0)) >= 4 and not signals.is_empty():
		return "%s keeps returning too neatly." % signals[0].capitalize()
	var hooks := _string_array(diagnostics.get("synergy_labels", []))
	if not hooks.is_empty() and hooks[0].find("ritual") != -1:
		return "%s is starting to look a little too rehearsed." % hooks[0].capitalize()
	if int(anomaly.get("score", 0)) >= 3:
		return "The route keeps leaning toward an older pressure shape."
	var delve_trace := _delve_trace(diagnostics, profile)
	if not delve_trace.is_empty():
		return delve_trace
	return ""

static func _doctrine_line(diagnostics: Dictionary, _profile: Dictionary) -> String:
	var doctrine_label := str(diagnostics.get("doctrine_label", "")).strip_edges()
	var doctrine_pressure_line := str(diagnostics.get("doctrine_pressure_line", "")).strip_edges()
	var pacing_profile := str(diagnostics.get("run_identity_pacing_profile", "")).strip_edges()
	var dominant_minds := _string_array(diagnostics.get("run_identity_dominant_minds", []))
	var doctrine_bits: Array[String] = []
	if not pacing_profile.is_empty():
		doctrine_bits.append("%s pacing" % pacing_profile.capitalize())
	if not dominant_minds.is_empty():
		doctrine_bits.append("%s lead" % dominant_minds[0])
	if not doctrine_label.is_empty() and not doctrine_pressure_line.is_empty():
		return _compact_shell_clause("%s: %s" % [doctrine_label, doctrine_pressure_line], doctrine_bits)
	if not doctrine_label.is_empty():
		return _compact_shell_clause(doctrine_label, doctrine_bits)
	if not doctrine_pressure_line.is_empty():
		return _compact_shell_clause(doctrine_pressure_line, doctrine_bits)
	if not doctrine_bits.is_empty():
		return _compact_shell_clause("", doctrine_bits)
	return ""

static func _governance_line(diagnostics: Dictionary, profile: Dictionary) -> String:
	var doctrine_world_goal := str(diagnostics.get("doctrine_world_goal", "")).strip_edges()
	var surface_summary_value: Variant = diagnostics.get("constitution_surface_summary", diagnostics.get("directive_surface_summary", []))
	var surface_summary: Array[String] = []
	if surface_summary_value is Dictionary:
		surface_summary = _string_array(Dictionary(surface_summary_value).get("lines", []))
	else:
		surface_summary = _string_array(surface_summary_value)
	var world_pull := _world_pull(profile, diagnostics)
	var motifs := _string_array(diagnostics.get("run_identity_symbolic_motifs", []))
	var mutation_surface_lines := _string_array(diagnostics.get("mutation_surface_lines", []))
	var narrative_pressure_lines := _string_array(diagnostics.get("narrative_pressure_lines", []))
	var experiment_surface_lines := _string_array(diagnostics.get("experiment_surface_lines", []))
	var theory_surface_lines := _string_array(diagnostics.get("theory_surface_lines", []))
	var civilization_surface_lines := _string_array(diagnostics.get("civilization_surface_lines", []))
	var cognitive_field_summary_lines := _string_array(diagnostics.get("cognitive_field_summary_lines", []))
	var activation_lines := _string_array(diagnostics.get("activation_lines", []))
	var safe_mode_lines := _string_array(diagnostics.get("safe_mode_lines", []))
	var signal_budget_lines := _string_array(diagnostics.get("signal_budget_lines", []))
	var review_surface_lines := _string_array(diagnostics.get("review_surface_lines", []))
	var explanation_packet_lines := _string_array(diagnostics.get("explanation_packet_lines", []))
	var explanation_immediate_lines := _string_array(diagnostics.get("explanation_immediate_lines", []))
	var explanation_run_lines := _string_array(diagnostics.get("explanation_run_lines", []))
	var surface_line := _first_string(surface_summary, "")
	var pressure_line := _first_string(narrative_pressure_lines, "")
	var experiment_line := _first_string(experiment_surface_lines, "")
	var theory_line := _first_string(theory_surface_lines, "")
	var civilization_line := _first_string(civilization_surface_lines, "")
	var field_line := _first_string(cognitive_field_summary_lines, "")
	var activation_line := _first_string(activation_lines, "")
	var safe_mode_line := _first_string(safe_mode_lines, "")
	var signal_budget_line := _first_string(signal_budget_lines, "")
	var review_line := _first_string(review_surface_lines, "")
	var explanation_line := _first_string(explanation_packet_lines, "")
	var explanation_immediate_line := _first_string(explanation_immediate_lines, "")
	var explanation_run_line := _first_string(explanation_run_lines, "")
	var motif_line := _first_string(motifs, "")
	var mutation_line := _first_string(mutation_surface_lines, "")
	var archive_tone := str(diagnostics.get("run_identity_archive_tone", "")).strip_edges()
	var convergence_axis := str(diagnostics.get("run_identity_convergence_axis", "")).strip_edges()
	if not doctrine_world_goal.is_empty():
		var governance_bits: Array[String] = []
		if not surface_line.is_empty():
			governance_bits.append("Surface: %s" % surface_line)
		if not pressure_line.is_empty() and pressure_line != surface_line:
			governance_bits.append("Pressure: %s" % pressure_line)
		if not experiment_line.is_empty() and experiment_line != surface_line and experiment_line != pressure_line:
			governance_bits.append("Current: %s" % experiment_line)
		if not theory_line.is_empty() and theory_line != experiment_line:
			governance_bits.append("Theory: %s" % theory_line)
		if not civilization_line.is_empty() and civilization_line != theory_line:
			governance_bits.append("World: %s" % civilization_line)
		if not mutation_line.is_empty() and mutation_line != experiment_line:
			governance_bits.append("Shift: %s" % mutation_line)
		if not activation_line.is_empty():
			governance_bits.append("Activation: %s" % activation_line)
		if not safe_mode_line.is_empty():
			governance_bits.append("Safe mode: %s" % safe_mode_line)
		if not signal_budget_line.is_empty():
			governance_bits.append("Signal budget: %s" % signal_budget_line)
		if not review_line.is_empty():
			governance_bits.append("Review: %s" % review_line)
		if governance_bits.is_empty() and not field_line.is_empty():
			governance_bits.append("Field: %s" % field_line)
		if governance_bits.is_empty() and not explanation_immediate_line.is_empty():
			governance_bits.append("Immediate: %s" % explanation_immediate_line)
		if governance_bits.is_empty() and not explanation_run_line.is_empty():
			governance_bits.append("Run: %s" % explanation_run_line)
		if governance_bits.is_empty() and not explanation_line.is_empty():
			governance_bits.append("Why: %s" % explanation_line)
		if governance_bits.is_empty() and not motif_line.is_empty():
			governance_bits.append("Motif: %s" % motif_line)
		if governance_bits.is_empty() and not archive_tone.is_empty():
			governance_bits.append("Tone: %s" % archive_tone)
		if not convergence_axis.is_empty():
			governance_bits.append("Axis: %s" % convergence_axis)
		return _compact_shell_clause(doctrine_world_goal, governance_bits)
	if not surface_line.is_empty():
		var surface_bits: Array[String] = []
		if not pressure_line.is_empty() and pressure_line != surface_line:
			surface_bits.append("Pressure: %s" % pressure_line)
		if not experiment_line.is_empty() and experiment_line != surface_line and experiment_line != pressure_line:
			surface_bits.append("Current: %s" % experiment_line)
		if not theory_line.is_empty() and theory_line != experiment_line:
			surface_bits.append("Theory: %s" % theory_line)
		if not civilization_line.is_empty():
			surface_bits.append("World: %s" % civilization_line)
		if not mutation_line.is_empty():
			surface_bits.append("Shift: %s" % mutation_line)
		if not activation_line.is_empty():
			surface_bits.append("Activation: %s" % activation_line)
		if not convergence_axis.is_empty():
			surface_bits.append("Axis: %s" % convergence_axis)
		return _compact_shell_clause(surface_line, surface_bits)
	if not pressure_line.is_empty():
		var pressure_bits: Array[String] = []
		if not experiment_line.is_empty():
			pressure_bits.append("Current: %s" % experiment_line)
		if not theory_line.is_empty():
			pressure_bits.append("Theory: %s" % theory_line)
		if not mutation_line.is_empty():
			pressure_bits.append("Shift: %s" % mutation_line)
		if not civilization_line.is_empty():
			pressure_bits.append("World: %s" % civilization_line)
		if not safe_mode_line.is_empty():
			pressure_bits.append("Safe mode: %s" % safe_mode_line)
		if not signal_budget_line.is_empty():
			pressure_bits.append("Signal budget: %s" % signal_budget_line)
		if not convergence_axis.is_empty():
			pressure_bits.append("Axis: %s" % convergence_axis)
		return _compact_shell_clause(pressure_line, pressure_bits)
	if not experiment_line.is_empty():
		var experiment_bits: Array[String] = []
		if not theory_line.is_empty():
			experiment_bits.append("Theory: %s" % theory_line)
		if not civilization_line.is_empty():
			experiment_bits.append("World: %s" % civilization_line)
		if not mutation_line.is_empty():
			experiment_bits.append("Shift: %s" % mutation_line)
		if not activation_line.is_empty():
			experiment_bits.append("Activation: %s" % activation_line)
		if not convergence_axis.is_empty():
			experiment_bits.append("Axis: %s" % convergence_axis)
		return _compact_shell_clause(experiment_line, experiment_bits)
	if not theory_line.is_empty():
		var theory_bits: Array[String] = []
		if not civilization_line.is_empty():
			theory_bits.append("World: %s" % civilization_line)
		if not field_line.is_empty():
			theory_bits.append("Field: %s" % field_line)
		if not activation_line.is_empty():
			theory_bits.append("Activation: %s" % activation_line)
		return _compact_shell_clause(theory_line, theory_bits)
	if not mutation_line.is_empty():
		var mutation_bits: Array[String] = []
		if not civilization_line.is_empty():
			mutation_bits.append("World: %s" % civilization_line)
		if not convergence_axis.is_empty():
			mutation_bits.append("Axis: %s" % convergence_axis)
		return _compact_shell_clause(mutation_line, mutation_bits)
	if not civilization_line.is_empty():
		var civilization_bits: Array[String] = []
		if not field_line.is_empty():
			civilization_bits.append("Field: %s" % field_line)
		if not review_line.is_empty():
			civilization_bits.append("Review: %s" % review_line)
		return _compact_shell_clause(civilization_line, civilization_bits)
	if not archive_tone.is_empty():
		var tone_bits: Array[String] = []
		if not motif_line.is_empty():
			tone_bits.append("Motif: %s" % motif_line)
		if not convergence_axis.is_empty():
			tone_bits.append("Axis: %s" % convergence_axis)
		return _compact_shell_clause(archive_tone, tone_bits)
	if not motif_line.is_empty():
		var motif_bits: Array[String] = []
		if not convergence_axis.is_empty():
			motif_bits.append("Axis: %s" % convergence_axis)
		return _compact_shell_clause("Motif: %s" % motif_line, motif_bits)
	if not world_pull.is_empty():
		return world_pull
	return ""

static func _compact_shell_clause(primary: String, detail_bits: Array[String]) -> String:
	var base := str(primary).strip_edges()
	var details: Array[String] = []
	for value in detail_bits:
		var text := _compact_shell_fragment(str(value))
		if not text.is_empty():
			details.append(text)
	if details.is_empty():
		return base
	if base.is_empty():
		return "; ".join(details)
	return "%s (%s)" % [base, "; ".join(details)]

static func _compact_shell_fragment(text: String) -> String:
	var value := str(text).strip_edges()
	while value.ends_with(".") or value.ends_with("!") or value.ends_with("?"):
		value = value.left(value.length() - 1).strip_edges()
	return value

static func _archive_title(run_record: Dictionary, diagnostics: Dictionary, status_valence: String) -> String:
	var atmosphere := str(diagnostics.get("atmosphere", "steady")).replace("_", " ").capitalize()
	var momentum := str(diagnostics.get("momentum_profile", "steadying")).replace("_", " ")
	if status_valence in ["Prestige", "Redemption"]:
		return "%s recovery under %s momentum" % [atmosphere, momentum]
	if status_valence in ["Scandal", "Infamy", "Disgrace"]:
		return "%s scandal under %s momentum" % [atmosphere, momentum]
	if bool(run_record.get("interrupted", false)):
		return "%s interruption echo" % atmosphere
	return "%s run echo" % atmosphere

static func _story_axes(diagnostics: Dictionary) -> Array[String]:
	var axes: Array[String] = []
	for value in [
		str(diagnostics.get("atmosphere", "")),
		str(diagnostics.get("social_temperature", "")),
		str(diagnostics.get("momentum_profile", "")),
		str(diagnostics.get("pace_profile", ""))
	]:
		var text: String = str(value).replace("_", " ").strip_edges()
		if text.is_empty():
			continue
		if not axes.has(text):
			axes.append(text)
	return axes.slice(0, mini(axes.size(), 4))

static func _narrative_hooks(diagnostics: Dictionary, status_valence: String) -> Array[String]:
	var hooks: Array[String] = []
	for hook in _string_array(diagnostics.get("quest_pressure", [])):
		if not hooks.has(hook):
			hooks.append(hook)
	for hook in _string_array(diagnostics.get("run_changing_moments", [])):
		if hooks.size() >= 4:
			break
		if not hooks.has(hook):
			hooks.append(hook)
	if hooks.is_empty():
		hooks.append("%s pressure" % status_valence.to_lower())
	return hooks

static func _quiet_play_line(diagnostics: Dictionary) -> String:
	return _first_string(_string_array(diagnostics.get("quiet_play_signals", [])), "")

static func _reentry_line(diagnostics: Dictionary, profile: Dictionary) -> String:
	for hook_raw in Array(profile.get("reentry_hooks", [])):
		var hook := Dictionary(hook_raw)
		var prompt := str(hook.get("prompt_line", "")).strip_edges()
		if not prompt.is_empty():
			return prompt
	var meaningful_non_action := str(diagnostics.get("meaningful_non_action", "")).strip_edges()
	if not meaningful_non_action.is_empty():
		return meaningful_non_action
	return _first_string(_string_array(diagnostics.get("anticipation_hooks", [])), "")

static func _social_consequence_line(diagnostics: Dictionary) -> String:
	var witness_pressure := str(diagnostics.get("witness_pressure", "")).strip_edges()
	var relationship_pressure := str(diagnostics.get("relationship_pressure", "")).strip_edges()
	var public_evidence_tags := _string_array(diagnostics.get("public_evidence_tags", []))
	var blame_surface_tags := _string_array(diagnostics.get("blame_surface_tags", []))
	var parts: Array[String] = []
	if not witness_pressure.is_empty():
		parts.append("witness %s" % witness_pressure.replace("_", " "))
	if not relationship_pressure.is_empty():
		parts.append("relationship %s" % relationship_pressure.replace("_", " "))
	if not public_evidence_tags.is_empty():
		parts.append(public_evidence_tags[0].replace("_", " "))
	if not blame_surface_tags.is_empty():
		parts.append("blame %s" % blame_surface_tags[0].replace("_", " "))
	if parts.is_empty():
		return ""
	return "; ".join(parts)

static func _social_safety_line(diagnostics: Dictionary) -> String:
	var flags := _string_array(diagnostics.get("social_safety_flags", []))
	if flags.has("quiet_play_viable") and flags.has("non_performative_viable"):
		return "quiet and non-performative play both remain valid"
	if flags.has("quiet_play_viable"):
		return "quiet play remains fully readable here"
	if flags.has("no_public_shaming"):
		return "public framing avoids humiliation pressure"
	return ""

static func _institutional_line(diagnostics: Dictionary) -> String:
	return _first_string(_string_array(Dictionary(diagnostics.get("institutional_pressure_surface", {})).get("claim_lines", [])), "")

static func _reputation_line(diagnostics: Dictionary) -> String:
	var reputation_band := str(diagnostics.get("reputation_band", "")).strip_edges()
	return reputation_band.replace("_", " ") if not reputation_band.is_empty() else ""

static func _compression_quality(diagnostics: Dictionary) -> int:
	return clampi(
		int(diagnostics.get("retellability_score", 0))
		+ int(diagnostics.get("symbolic_gesture_score", 0))
		+ int(diagnostics.get("expectation_break_score", 0)),
		0,
		12
	)

static func _legend_density_score(diagnostics: Dictionary) -> int:
	return clampi(
		int(diagnostics.get("compression_quality", 0))
		+ int(diagnostics.get("spectacle_pressure", 0))
		+ int(diagnostics.get("recovery_score", 0))
		+ int(diagnostics.get("near_miss_score", 0)),
		0,
		16
	)

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty():
				result.append(text)
	return result

static func _take_unique(values: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if text.is_empty():
			continue
		if result.has(text):
			continue
		result.append(text)
		if result.size() >= limit:
			break
	return result

static func _first_string(values: Array, fallback: String) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _pair_label(pair_key: String) -> String:
	var bits := pair_key.split(":")
	if bits.size() == 2:
		return "%s / %s" % [bits[0], bits[1]]
	return pair_key

static func _title_case(text: String) -> String:
	var words := text.replace("_", " ").split(" ")
	var result: Array[String] = []
	for word_raw in words:
		var word := str(word_raw).strip_edges()
		if word.is_empty():
			continue
		result.append(word.left(1).to_upper() + word.substr(1).to_lower())
	return " ".join(result)

static func _safe_lines(values: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(guard_text(value))
	return result

static func _safe_text(text: String) -> String:
	return guard_text(text)

static func guard_text(text: String) -> String:
	return WORDING_GUARD_SCRIPT.guard_text(text)

static func guard_lines(values: Array) -> Array[String]:
	return WORDING_GUARD_SCRIPT.guard_lines(values)

static func guard_entry(entry: Dictionary) -> Dictionary:
	return WORDING_GUARD_SCRIPT.guard_entry(entry)

static func guard_entries(entries: Array) -> Array[Dictionary]:
	return WORDING_GUARD_SCRIPT.guard_entries(entries)
