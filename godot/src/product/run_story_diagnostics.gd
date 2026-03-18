class_name RunStoryDiagnostics
extends RefCounted

const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")

static func analyze(run_record: Dictionary) -> Dictionary:
	var key_clues := _string_array(run_record.get("key_clues", []))
	var action_summary := _string_array(run_record.get("action_summary", []))
	var communication: Dictionary = Dictionary(run_record.get("communication_summary", {}))
	var public_events := _dict_array(run_record.get("timeline_public_events", []))
	var motion_facts: Dictionary = Dictionary(run_record.get("narrative_motion_facts", {}))
	var gameplay_snapshot: Dictionary = Dictionary(run_record.get("gameplay_signal_snapshot", {}))
	var expedition_constitution_summary: Dictionary = _public_safe_constitution_summary(
		Dictionary(run_record.get("expedition_constitution_summary", run_record.get("delve_directive_summary", {})))
	)
	var doctrine_family := str(expedition_constitution_summary.get("doctrine_family", "")).strip_edges()
	var doctrine_label := str(expedition_constitution_summary.get("doctrine_label", "")).strip_edges()
	var doctrine_pressure_line := str(expedition_constitution_summary.get("pressure_line", "")).strip_edges()
	var doctrine_world_goal := str(expedition_constitution_summary.get("world_goal", "")).strip_edges()
	var constitution_surface_summary: Dictionary = Dictionary(expedition_constitution_summary.get("surface_summary", {}))
	var constitution_surface_lines := _string_array(constitution_surface_summary.get("lines", []))
	var run_identity_dominant_minds := _take_unique(_string_array(expedition_constitution_summary.get("dominant_minds", [])), 2)
	var run_identity_pressure_grammar := _take_unique(_string_array(expedition_constitution_summary.get("pressure_grammar", [])), 2)
	var run_identity_symbolic_motifs := _take_unique(_string_array(expedition_constitution_summary.get("symbolic_motifs", [])), 2)
	var run_identity_pacing_profile := str(expedition_constitution_summary.get("pacing_label", expedition_constitution_summary.get("pacing_profile", ""))).strip_edges()
	var run_identity_item_ecology_bias := str(expedition_constitution_summary.get("item_ecology_bias", "")).strip_edges()
	var run_identity_group_tension_bias := str(expedition_constitution_summary.get("group_tension_bias", "")).strip_edges()
	var run_identity_archive_tone := str(expedition_constitution_summary.get("archive_tone", "")).strip_edges()
	var run_identity_convergence_axis := str(expedition_constitution_summary.get("convergence_axis", "")).strip_edges()
	var narrative_pressure_family := str(expedition_constitution_summary.get("narrative_pressure_family", "")).strip_edges()
	var narrative_pressure_lines := _take_unique(_string_array(expedition_constitution_summary.get("narrative_pressure_lines", [])), 3)
	var narrative_pressure_tensions := _take_unique(_string_array(expedition_constitution_summary.get("narrative_pressure_tensions", [])), 3)
	var narrative_pressure_momentum := int(expedition_constitution_summary.get("narrative_pressure_momentum", 0))
	var narrative_pressure_resonance := int(expedition_constitution_summary.get("narrative_pressure_resonance", 0))
	var narrative_pressure_cascade_risk := int(expedition_constitution_summary.get("narrative_pressure_cascade_risk", 0))
	var experiment_surface_lines := _take_unique(_string_array(expedition_constitution_summary.get("experiment_surface_lines", [])), 3)
	var experiment_families := _take_unique(_string_array(expedition_constitution_summary.get("experiment_families", [])), 3)
	var experiment_expression_modes := _take_unique(_string_array(expedition_constitution_summary.get("experiment_expression_modes", [])), 3)
	var experiment_horizons := _take_unique(_string_array(expedition_constitution_summary.get("experiment_horizons", [])), 3)
	var lineage_registry_ids := _take_unique(_string_array(expedition_constitution_summary.get("lineage_registry_ids", [])), 4)
	var civilization_surface_lines := _take_unique(_string_array(expedition_constitution_summary.get("civilization_surface_lines", [])), 3)
	var civilization_faction_ids := _take_unique(_string_array(expedition_constitution_summary.get("civilization_faction_ids", [])), 3)
	var civilization_regime_ids := _take_unique(_string_array(expedition_constitution_summary.get("civilization_regime_ids", [])), 3)
	var world_mutation_ids := _take_unique(_string_array(expedition_constitution_summary.get("world_mutation_ids", [])), 3)
	var cognitive_field_summary_lines := _take_unique(_string_array(expedition_constitution_summary.get("cognitive_field_summary_lines", [])), 3)
	var cognitive_field_dimensions := _take_unique(_string_array(expedition_constitution_summary.get("cognitive_field_dimensions", [])), 4)
	var mind_projection_ids := _take_unique(_string_array(expedition_constitution_summary.get("mind_projection_ids", [])), 4)
	var theory_surface_lines := _take_unique(_string_array(expedition_constitution_summary.get("theory_surface_lines", [])), 3)
	var theory_ids := _take_unique(_string_array(expedition_constitution_summary.get("theory_ids", [])), 4)
	var theory_school_ids := _take_unique(_string_array(expedition_constitution_summary.get("theory_school_ids", [])), 4)
	var theory_statuses := _take_unique(_string_array(expedition_constitution_summary.get("theory_statuses", [])), 4)
	var activation_epoch := str(expedition_constitution_summary.get("activation_epoch", "structural_presence")).strip_edges()
	var activation_active_channels := _take_unique(_string_array(expedition_constitution_summary.get("activation_active_channels", [])), 6)
	var activation_dormant_channels := _take_unique(_string_array(expedition_constitution_summary.get("activation_dormant_channels", [])), 8)
	var activation_lines := _take_unique(_string_array(expedition_constitution_summary.get("activation_lines", [])), 3)
	var safe_mode_active := bool(expedition_constitution_summary.get("safe_mode_active", false))
	var safe_mode_lines := _take_unique(_string_array(expedition_constitution_summary.get("safe_mode_lines", [])), 3)
	var explanation_packet_lines := _take_unique(_string_array(expedition_constitution_summary.get("explanation_packet_lines", [])), 3)
	var review_surface_lines := _take_unique(_string_array(expedition_constitution_summary.get("review_surface_lines", [])), 3)
	var mutation_surface_lines := _mutation_surface_lines(Dictionary(run_record.get("mutation_public_summary", {})))
	var gameplay_model := _local_gameplay_model(run_record, gameplay_snapshot)
	var group_gameplay_model := _group_gameplay_model(gameplay_snapshot)
	var branch_summary: Dictionary = _branch_summary(run_record)
	var interrupted := bool(run_record.get("interrupted", false))
	var build_identity := str(gameplay_model.get("build_identity", "")).strip_edges()
	var build_stability := int(gameplay_model.get("build_stability", 0))
	var risk_profile := str(gameplay_model.get("risk_profile", "")).strip_edges()
	var gameplay_feature_scores: Dictionary = Dictionary(gameplay_model.get("feature_scores", {}))
	var gameplay_feature_signals := _string_array(gameplay_model.get("feature_signals", []))
	var gameplay_behavior_signals := _string_array(gameplay_model.get("behavior_signals", []))
	var synergy_labels := _string_array(gameplay_model.get("synergy_labels", []))
	var item_ecology_signals := _item_ecology_signals(run_record, branch_summary, build_identity, synergy_labels, gameplay_behavior_signals)
	var artifact_lineage_hints := _string_array(item_ecology_signals.get("lineage_hints", []))
	var artifact_branch_markers := _string_array(item_ecology_signals.get("branch_markers", []))
	var artifact_memory_hints := _string_array(item_ecology_signals.get("memory_hints", []))
	var artifact_prestige_indicators := _string_array(item_ecology_signals.get("prestige_indicators", []))
	var artifact_continuity_state := str(item_ecology_signals.get("continuity_state", "")).strip_edges()
	var artifact_continuity_text := str(item_ecology_signals.get("continuity_text", "")).strip_edges()
	var gameplay_model_pressure := _take_unique(
		_string_array(gameplay_model.get("model_pressure", [])) + _string_array(group_gameplay_model.get("model_pressure", [])),
		4
	)
	if not doctrine_pressure_line.is_empty():
		gameplay_model_pressure = _take_unique(gameplay_model_pressure + [doctrine_pressure_line], 5)
	if not run_identity_pacing_profile.is_empty():
		gameplay_model_pressure = _take_unique(gameplay_model_pressure + ["%s pacing" % run_identity_pacing_profile.to_lower()], 5)
	if not run_identity_pressure_grammar.is_empty():
		gameplay_model_pressure = _take_unique(gameplay_model_pressure + run_identity_pressure_grammar, 5)
	if not run_identity_group_tension_bias.is_empty():
		gameplay_model_pressure = _take_unique(gameplay_model_pressure + [run_identity_group_tension_bias], 5)
	var gameplay_group_signals := _string_array(group_gameplay_model.get("group_signals", []))
	var group_fault_lines := _string_array(group_gameplay_model.get("fault_lines", []))
	var gameplay_resource_pressure := _take_unique(
		_string_array(gameplay_model.get("resource_signals", [])) + _string_array(gameplay_snapshot.get("resource_pressure", [])),
		4
	)
	if not run_identity_item_ecology_bias.is_empty():
		gameplay_resource_pressure = _take_unique(gameplay_resource_pressure + [run_identity_item_ecology_bias], 4)
	var inhabitant_pressure := _take_unique(
		_string_array(gameplay_model.get("inhabitant_signals", [])) + _string_array(gameplay_snapshot.get("inhabitant_pressure", [])),
		4
	)
	var prioritized_ecology_signals := _ecology_signal_highlights(inhabitant_pressure)
	var gameplay_protocol_hooks := _string_array(gameplay_model.get("protocol_hooks", []))
	var gameplay_ritual_hooks := _string_array(gameplay_model.get("ritual_hooks", []))
	var gameplay_anomaly_hooks := _string_array(gameplay_model.get("anomaly_hooks", []))
	var route_commits := 0
	var pressure_beats := 0
	var clue_beats := 0
	var artifact_beats := 0
	var suspicion_beats := 0
	for line in key_clues:
		route_commits += _hits(line, ["zipline", "rope", "route", "threshold"])
		pressure_beats += _hits(line, ["extraction", "trap", "ghost", "blast", "hold", "collapse"])
		clue_beats += _hits(line, ["inspect", "noise", "mark", "pulse", "echo"])
		artifact_beats += _hits(line, ["artifact", "counterfeit", "authentic", "evidence"])
	for line in action_summary:
		suspicion_beats += _hits(line, ["pinned", "inspected", "rerouted", "decoy", "route", "trap", "blast", "callout", "picked up"])
	var room_clusters := _room_clusters(public_events)
	var pair_keys := _pair_keys(public_events, int(run_record.get("local_peer_id", -1)), motion_facts)
	var symbolic_gestures := _symbolic_gestures(public_events, run_record, motion_facts)
	var recovery_score := int(communication.get("regroup", 0)) + (2 if symbolic_gestures.has("burden handoff") else 0)
	var confrontation_score := _count_type(public_events, "bomb_exploded") + _count_type(public_events, "artifact_stolen") + _count_type(public_events, "sabotage_accident") + _count_type(public_events, "sabotage_camera_jam")
	var burden_score := _count_type(public_events, "artifact_picked") + _count_type(public_events, "artifact_dropped") + (2 if symbolic_gestures.has("burden handoff") else 0)
	var spectacle_pressure := _spectacle_pressure(public_events, communication, pair_keys, motion_facts, confrontation_score)
	var attention_patterns := _attention_patterns(public_events, motion_facts)
	var expectation_tension := _expectation_tension(public_events, communication, motion_facts, spectacle_pressure)
	var expectation_breaks := _expectation_breaks(run_record, public_events, confrontation_score, recovery_score, spectacle_pressure, motion_facts)
	var pace_profile := _pace_profile(public_events, communication, confrontation_score, recovery_score, motion_facts)
	var group_shape_drift := _group_shape_drift(pair_keys, recovery_score, confrontation_score, communication)
	var momentum_profile := _momentum_profile(pace_profile, group_shape_drift, recovery_score, confrontation_score, burden_score, motion_facts)
	var social_temperature := _social_temperature(communication, confrontation_score, recovery_score, spectacle_pressure, pair_keys, motion_facts)
	var silence_clusters := _silence_clusters(motion_facts)
	var atmosphere := _atmosphere(momentum_profile, social_temperature, spectacle_pressure, confrontation_score, expectation_breaks, silence_clusters)
	var room_identity_highlights := _room_identities(room_clusters, confrontation_score, recovery_score, burden_score, motion_facts, branch_summary)
	var escalation_arc := _escalation_arc(public_events, communication, motion_facts, confrontation_score, recovery_score, spectacle_pressure)
	var spectacle_windows := _spectacle_windows(public_events, symbolic_gestures, motion_facts, confrontation_score, recovery_score, burden_score, spectacle_pressure)
	var recovery_ecology := _recovery_ecology(recovery_score, confrontation_score, motion_facts, symbolic_gestures)
	var ritual_recurrence := _ritual_recurrence(symbolic_gestures, motion_facts, branch_summary)
	var territory_claims := _territory_claims(motion_facts, branch_summary, confrontation_score)
	var run_changing_moments := _run_changing_moments(symbolic_gestures, expectation_breaks, confrontation_score, recovery_score, spectacle_windows, motion_facts)
	var pressure_persistence := _pressure_persistence(escalation_arc, attention_patterns, symbolic_gestures, spectacle_windows)
	var quest_collisions := _quest_collisions(recovery_score, confrontation_score, burden_score, spectacle_pressure, expectation_breaks, branch_summary, motion_facts)
	var near_miss_score := (2 if interrupted else 0) + (1 if _count_type(public_events, "extraction_window_started") > 0 and _count_type(public_events, "extraction_completed") == 0 else 0) + (1 if confrontation_score >= 2 and recovery_score >= 2 else 0)
	var story_density := key_clues.size() + action_summary.size() + int(communication.get("total", 0)) + public_events.size()
	var story_tone := "Disrupted" if interrupted else "Chaotic" if story_density >= 14 or suspicion_beats >= 6 or atmosphere in ["overexposed", "desperate", "ugly"] else "Charged" if story_density >= 8 or suspicion_beats >= 3 else "Quiet"
	var retellability_score := clampi(symbolic_gestures.size() + near_miss_score + run_changing_moments.size() + spectacle_windows.size() + (2 if not expectation_breaks.is_empty() else 0) + (1 if momentum_profile in ["coming_together", "slipping_away", "spiraling", "collapsing_late"] else 0), 0, 12)
	var compression_quality := clampi(retellability_score + symbolic_gestures.size() + spectacle_windows.size() + (2 if expectation_tension == "loaded" else 1 if expectation_tension == "tightening" else 0), 0, 14)
	var legend_density_score := clampi(compression_quality + spectacle_pressure + recovery_score + near_miss_score + mini(spectacle_windows.size(), 2), 0, 18)
	var purpose_vector := _purpose_vector(recovery_score, confrontation_score, burden_score, expectation_breaks, branch_summary, spectacle_pressure)
	var micro_signal_clusters := _micro_signal_clusters(symbolic_gestures, attention_patterns, motion_facts, expectation_tension, spectacle_pressure)
	var protocol_state_hint := _protocol_state_hint(run_record, public_events, gameplay_snapshot)
	var belief_state := _belief_state(
		run_record,
		branch_summary,
		attention_patterns,
		expectation_breaks,
		spectacle_windows,
		quest_collisions,
		recovery_ecology,
		pressure_persistence,
		momentum_profile,
		social_temperature,
		protocol_state_hint,
		build_identity,
		gameplay_feature_signals,
		gameplay_behavior_signals,
		inhabitant_pressure,
		group_fault_lines,
		gameplay_model_pressure
	)
	var counterfactual_pressure := _counterfactual_pressure(
		expectation_breaks,
		near_miss_score,
		pressure_persistence,
		recovery_ecology,
		interrupted,
		protocol_state_hint,
		gameplay_resource_pressure,
		risk_profile,
		group_fault_lines,
		gameplay_model_pressure
	)
	var consensus_risk := _consensus_risk(spectacle_pressure, recovery_score, social_temperature, expectation_breaks, protocol_state_hint, branch_summary, group_fault_lines, gameplay_model_pressure)
	var hidden_curriculum := _hidden_curriculum(recovery_ecology, burden_score, expectation_tension, ritual_recurrence, spectacle_pressure, expectation_breaks, gameplay_protocol_hooks, gameplay_feature_signals, gameplay_model_pressure)
	var anomaly_sensitivity := _anomaly_sensitivity(motion_facts, attention_patterns, pressure_persistence, expectation_breaks, interrupted)
	var branch_caution_markers := _branch_caution_markers(branch_summary, protocol_state_hint, gameplay_resource_pressure, prioritized_ecology_signals, constitution_surface_lines)
	var branch_reputation_drift := _branch_reputation_drift(branch_summary, recovery_score, confrontation_score, burden_score, expectation_breaks, protocol_state_hint)
	var artifact_cultural_association := _artifact_cultural_association(artifact_lineage_hints, artifact_branch_markers, artifact_prestige_indicators, run_identity_archive_tone)
	if not gameplay_anomaly_hooks.is_empty() or not inhabitant_pressure.is_empty():
		var anomaly_copy: Dictionary = anomaly_sensitivity.duplicate(true)
		anomaly_copy["score"] = clampi(int(anomaly_copy.get("score", 0)) + mini(gameplay_anomaly_hooks.size(), 2) + (1 if not inhabitant_pressure.is_empty() else 0), 0, 8)
		anomaly_copy["signals"] = _take_unique(_string_array(anomaly_copy.get("signals", [])) + gameplay_anomaly_hooks + inhabitant_pressure, 5)
		anomaly_sensitivity = anomaly_copy
	return {
		"route_commits": route_commits,
		"pressure_beats": pressure_beats,
		"clue_beats": clue_beats,
		"artifact_beats": artifact_beats,
		"suspicion_beats": suspicion_beats,
		"communication_beats": int(communication.get("total", 0)),
		"danger_callouts": int(communication.get("danger", 0)),
		"regroup_callouts": int(communication.get("regroup", 0)),
		"artifact_callouts": int(communication.get("artifact", 0)),
		"interrupted": interrupted,
		"wait_for_lobby": bool(run_record.get("session_wait_for_lobby", false)),
		"reconnect_ready": bool(run_record.get("session_reconnect_ready", false)),
		"story_density": story_density,
		"story_tone": story_tone,
		"branch_summary": branch_summary,
		"micro_signal_clusters": micro_signal_clusters,
		"symbolic_gestures": symbolic_gestures,
		"symbolic_gesture_score": symbolic_gestures.size(),
		"choice_frames": _choice_frames(interrupted, public_events, symbolic_gestures, spectacle_pressure, confrontation_score, motion_facts, branch_summary),
		"attention_patterns": attention_patterns,
		"social_temperature": social_temperature,
		"silence_clusters": silence_clusters,
		"recovery_score": recovery_score,
		"recovery_ecology": recovery_ecology,
		"ritual_recurrence": ritual_recurrence,
		"transition_tension": _transition_tension(room_clusters, public_events, motion_facts),
		"room_identity_highlights": room_identity_highlights,
		"load_bearing_places": _load_bearing_places(room_clusters, room_identity_highlights, motion_facts, branch_summary),
		"load_bearing_objects": _load_bearing_objects(run_record, symbolic_gestures, motion_facts),
		"confrontation_score": confrontation_score,
		"burden_score": burden_score,
		"territory_claims": territory_claims,
		"witness_topology": _witness_topology(public_events, communication, confrontation_score, spectacle_pressure, motion_facts),
		"social_topology": _social_topology(pair_keys, public_events, communication, motion_facts),
		"spectacle_pressure": spectacle_pressure,
		"spectacle_windows": spectacle_windows,
		"pace_profile": pace_profile,
		"escalation_arc": escalation_arc,
		"momentum_profile": momentum_profile,
		"pressure_persistence": pressure_persistence,
		"quest_collisions": quest_collisions,
		"emotional_trajectory": _emotional_trajectory(pace_profile, momentum_profile, social_temperature, expectation_breaks, escalation_arc),
		"atmosphere": atmosphere,
		"run_changing_moments": run_changing_moments,
		"within_run_echoes": _within_run_echoes(public_events, symbolic_gestures, motion_facts),
		"expectation_tension": expectation_tension,
		"expectation_breaks": expectation_breaks,
		"expectation_break_score": expectation_breaks.size(),
		"anticipation_hooks": _anticipation_hooks(expectation_tension, interrupted, attention_patterns, expectation_breaks, branch_summary, pressure_persistence),
		"protocol_state_hint": protocol_state_hint,
		"doctrine_family": doctrine_family,
		"doctrine_label": doctrine_label,
		"doctrine_pressure_line": doctrine_pressure_line,
		"doctrine_world_goal": doctrine_world_goal,
		"constitution_surface_summary": constitution_surface_lines,
		"directive_surface_summary": constitution_surface_lines,
		"mutation_surface_lines": mutation_surface_lines,
		"run_identity_pacing_profile": run_identity_pacing_profile,
		"run_identity_pressure_grammar": run_identity_pressure_grammar,
		"run_identity_symbolic_motifs": run_identity_symbolic_motifs,
		"run_identity_dominant_minds": run_identity_dominant_minds,
		"run_identity_item_ecology_bias": run_identity_item_ecology_bias,
		"run_identity_group_tension_bias": run_identity_group_tension_bias,
		"run_identity_archive_tone": run_identity_archive_tone,
		"run_identity_convergence_axis": run_identity_convergence_axis,
		"narrative_pressure_family": narrative_pressure_family,
		"narrative_pressure_lines": narrative_pressure_lines,
		"narrative_pressure_tensions": narrative_pressure_tensions,
		"narrative_pressure_momentum": narrative_pressure_momentum,
		"narrative_pressure_resonance": narrative_pressure_resonance,
		"narrative_pressure_cascade_risk": narrative_pressure_cascade_risk,
		"experiment_surface_lines": experiment_surface_lines,
		"experiment_families": experiment_families,
		"experiment_expression_modes": experiment_expression_modes,
		"experiment_horizons": experiment_horizons,
		"lineage_registry_ids": lineage_registry_ids,
		"civilization_surface_lines": civilization_surface_lines,
		"civilization_faction_ids": civilization_faction_ids,
		"civilization_regime_ids": civilization_regime_ids,
		"world_mutation_ids": world_mutation_ids,
		"cognitive_field_summary_lines": cognitive_field_summary_lines,
		"cognitive_field_dimensions": cognitive_field_dimensions,
		"mind_projection_ids": mind_projection_ids,
		"theory_surface_lines": theory_surface_lines,
		"theory_ids": theory_ids,
		"theory_school_ids": theory_school_ids,
		"theory_statuses": theory_statuses,
		"activation_epoch": activation_epoch,
		"activation_active_channels": activation_active_channels,
		"activation_dormant_channels": activation_dormant_channels,
		"activation_lines": activation_lines,
		"safe_mode_active": safe_mode_active,
		"safe_mode_lines": safe_mode_lines,
		"explanation_packet_lines": explanation_packet_lines,
		"review_surface_lines": review_surface_lines,
		"build_identity": build_identity,
		"build_stability": build_stability,
		"risk_profile": risk_profile,
		"build_scores": Dictionary(gameplay_model.get("build_scores", {})).duplicate(true),
		"gameplay_feature_scores": gameplay_feature_scores.duplicate(true),
		"gameplay_feature_signals": gameplay_feature_signals,
		"gameplay_behavior_signals": gameplay_behavior_signals,
		"gameplay_group_signals": gameplay_group_signals,
		"group_fault_lines": group_fault_lines,
		"model_pressure": gameplay_model_pressure,
		"synergy_labels": synergy_labels,
		"resource_pressure": gameplay_resource_pressure,
		"inhabitant_pressure": inhabitant_pressure,
		"ecology_signal_highlights": prioritized_ecology_signals,
		"protocol_hooks": gameplay_protocol_hooks,
		"ritual_hooks": gameplay_ritual_hooks,
		"artifact_lineage_hints": artifact_lineage_hints,
		"artifact_branch_markers": artifact_branch_markers,
		"artifact_memory_hints": artifact_memory_hints,
		"artifact_prestige_indicators": artifact_prestige_indicators,
		"artifact_continuity_state": artifact_continuity_state,
		"artifact_continuity_text": artifact_continuity_text,
		"artifact_cultural_association": artifact_cultural_association,
		"branch_caution_markers": branch_caution_markers,
		"branch_reputation_drift": branch_reputation_drift,
		"belief_state": belief_state,
		"counterfactual_pressure": counterfactual_pressure,
		"consensus_risk": consensus_risk,
		"hidden_curriculum": hidden_curriculum,
		"anomaly_sensitivity": anomaly_sensitivity,
		"pair_keys": pair_keys,
		"crew_hooks": _crew_hooks(group_shape_drift, social_temperature, recovery_score, confrontation_score),
		"group_shape_drift": group_shape_drift,
		"quest_pressure": _quest_pressure(interrupted, confrontation_score, recovery_score, burden_score, spectacle_pressure, expectation_breaks, symbolic_gestures, room_identity_highlights, branch_summary, pressure_persistence, motion_facts),
		"purpose_vector": purpose_vector,
		"retellability_score": retellability_score,
		"compression_quality": compression_quality,
		"legend_density_score": legend_density_score,
		"near_miss_score": near_miss_score,
		"run_shapes": _run_shapes(recovery_score, confrontation_score, burden_score, atmosphere, expectation_breaks, spectacle_windows, momentum_profile),
		"item_story_roles": _item_story_roles(run_record, symbolic_gestures, confrontation_score, recovery_score, burden_score, branch_summary, motion_facts, build_identity, synergy_labels, gameplay_behavior_signals),
		"social_beats_top": _social_beats_top(recovery_score, confrontation_score, burden_score, expectation_breaks),
		"revisit_score": _revisit_score(spectacle_windows, pressure_persistence, branch_summary)
	}

static func _public_safe_constitution_summary(raw: Dictionary) -> Dictionary:
	var public_summary: Dictionary = Dictionary(raw.get("public_summary", {}))
	var surface_summary: Dictionary = Dictionary(raw.get("surface_summary", {}))
	return {
		"protocol_state": str(raw.get("protocol_state", public_summary.get("protocol_state", ""))).strip_edges(),
		"doctrine_family": str(raw.get("doctrine_family", public_summary.get("doctrine_family", ""))).strip_edges(),
		"doctrine_label": str(raw.get("doctrine_label", public_summary.get("doctrine", ""))).strip_edges(),
		"pressure_line": str(raw.get("pressure_line", public_summary.get("pressure_line", ""))).strip_edges(),
		"world_goal": str(raw.get("world_goal", public_summary.get("world_goal", ""))).strip_edges(),
		"dominant_minds": _string_array(public_summary.get("dominant_minds", raw.get("dominant_minds", []))),
		"dominant_forces": _string_array(public_summary.get("dominant_forces", raw.get("dominant_forces", []))),
		"dominant_domains": _string_array(public_summary.get("dominant_domains", raw.get("dominant_domains", []))),
		"pacing_profile": str(public_summary.get("pacing_profile", raw.get("pacing_profile", ""))).strip_edges(),
		"pacing_label": str(public_summary.get("pacing_label", raw.get("pacing_label", ""))).strip_edges(),
		"pressure_grammar": _string_array(public_summary.get("pressure_grammar", raw.get("pressure_grammar", []))),
		"symbolic_motifs": _string_array(public_summary.get("symbolic_motifs", raw.get("symbolic_motifs", []))),
		"item_ecology_bias": str(public_summary.get("item_ecology_bias", raw.get("item_ecology_bias", ""))).strip_edges(),
		"group_tension_bias": str(public_summary.get("group_tension_bias", raw.get("group_tension_bias", ""))).strip_edges(),
		"archive_tone": str(public_summary.get("archive_tone", raw.get("archive_tone", ""))).strip_edges(),
		"convergence_axis": str(public_summary.get("convergence_axis", raw.get("convergence_axis", ""))).strip_edges(),
		"narrative_pressure_family": str(public_summary.get("narrative_pressure_family", raw.get("narrative_pressure_family", ""))).strip_edges(),
		"narrative_pressure_lines": _string_array(public_summary.get("narrative_pressure_lines", raw.get("narrative_pressure_lines", []))),
		"narrative_pressure_tensions": _string_array(public_summary.get("narrative_pressure_tensions", raw.get("narrative_pressure_tensions", []))),
		"narrative_pressure_momentum": int(public_summary.get("narrative_pressure_momentum", raw.get("narrative_pressure_momentum", 0))),
		"narrative_pressure_resonance": int(public_summary.get("narrative_pressure_resonance", raw.get("narrative_pressure_resonance", 0))),
		"narrative_pressure_cascade_risk": int(public_summary.get("narrative_pressure_cascade_risk", raw.get("narrative_pressure_cascade_risk", 0))),
		"experiment_surface_lines": _string_array(public_summary.get("experiment_surface_lines", raw.get("experiment_surface_lines", []))),
		"experiment_families": _string_array(public_summary.get("experiment_families", raw.get("experiment_families", []))),
		"experiment_expression_modes": _string_array(public_summary.get("experiment_expression_modes", raw.get("experiment_expression_modes", []))),
		"experiment_horizons": _string_array(public_summary.get("experiment_horizons", raw.get("experiment_horizons", []))),
		"lineage_registry_ids": _string_array(public_summary.get("lineage_registry_ids", raw.get("lineage_registry_ids", []))),
		"civilization_surface_lines": _string_array(public_summary.get("civilization_surface_lines", raw.get("civilization_surface_lines", []))),
		"civilization_faction_ids": _string_array(public_summary.get("civilization_faction_ids", raw.get("civilization_faction_ids", []))),
		"civilization_regime_ids": _string_array(public_summary.get("civilization_regime_ids", raw.get("civilization_regime_ids", []))),
		"world_mutation_ids": _string_array(public_summary.get("world_mutation_ids", raw.get("world_mutation_ids", []))),
		"cognitive_field_summary_lines": _string_array(public_summary.get("cognitive_field_summary_lines", raw.get("cognitive_field_summary_lines", []))),
		"cognitive_field_dimensions": _string_array(public_summary.get("cognitive_field_dimensions", raw.get("cognitive_field_dimensions", []))),
		"mind_projection_ids": _string_array(public_summary.get("mind_projection_ids", raw.get("mind_projection_ids", []))),
		"theory_surface_lines": _string_array(public_summary.get("theory_surface_lines", raw.get("theory_surface_lines", []))),
		"theory_ids": _string_array(public_summary.get("theory_ids", raw.get("theory_ids", []))),
		"theory_school_ids": _string_array(public_summary.get("theory_school_ids", raw.get("theory_school_ids", []))),
		"theory_statuses": _string_array(public_summary.get("theory_statuses", raw.get("theory_statuses", []))),
		"activation_epoch": str(public_summary.get("activation_epoch", raw.get("activation_epoch", "structural_presence"))).strip_edges(),
		"activation_active_channels": _string_array(public_summary.get("activation_active_channels", raw.get("activation_active_channels", []))),
		"activation_dormant_channels": _string_array(public_summary.get("activation_dormant_channels", raw.get("activation_dormant_channels", []))),
		"activation_lines": _string_array(public_summary.get("activation_lines", raw.get("activation_lines", []))),
		"safe_mode_active": bool(public_summary.get("safe_mode_active", raw.get("safe_mode_active", false))),
		"safe_mode_lines": _string_array(public_summary.get("safe_mode_lines", raw.get("safe_mode_lines", []))),
		"explanation_packet_lines": _string_array(public_summary.get("explanation_packet_lines", raw.get("explanation_packet_lines", []))),
		"review_surface_lines": _string_array(public_summary.get("review_surface_lines", raw.get("review_surface_lines", []))),
		"surface_summary": {
			"lines": _string_array(surface_summary.get("lines", []))
		}
	}

static func _public_safe_delve_directive(raw: Dictionary) -> Dictionary:
	return _public_safe_constitution_summary(raw)

static func build_summary_lines(diagnostics: Dictionary) -> Array[String]:
	return [
		"Story tone: %s | Atmosphere: %s" % [str(diagnostics.get("story_tone", "Quiet")), _nice(str(diagnostics.get("atmosphere", "steady")))],
		"Momentum: %s | Social temp: %s" % [_nice(str(diagnostics.get("momentum_profile", "steadying"))), _nice(str(diagnostics.get("social_temperature", "quiet_discipline")))],
		"Pressure beats: %d | Spectacle: %d" % [int(diagnostics.get("pressure_beats", 0)), int(diagnostics.get("spectacle_pressure", 0))]
	]

static func build_review_lines(diagnostics: Dictionary) -> Array[String]:
	var lines := build_summary_lines(diagnostics)
	lines.append("Why revisit: %s" % build_memorable_reason(diagnostics))
	lines.append("Quest pull: %s" % _first(Array(diagnostics.get("quest_pressure", [])), "Steady challenge"))
	lines.append("Archive pull: %s" % _first(Array(diagnostics.get("anticipation_hooks", [])), "Watch for the next echo"))
	return lines

static func build_highlight_tags(diagnostics: Dictionary) -> Array[String]:
	var tags := _take_unique([_nice(str(diagnostics.get("atmosphere", ""))), _nice(str(diagnostics.get("momentum_profile", "")))], 2)
	if int(diagnostics.get("spectacle_pressure", 0)) >= 3:
		tags.append("Hot")
	if not Array(diagnostics.get("expectation_breaks", [])).is_empty():
		tags.append("Inversion")
	if bool(diagnostics.get("interrupted", false)):
		tags.append("Interrupted")
	if not tags.is_empty():
		return tags
	return ["Steady"]

static func build_memorable_reason(diagnostics: Dictionary) -> String:
	if not Array(diagnostics.get("symbolic_gestures", [])).is_empty():
		return "%s shifted the whole read of the run" % str(Array(diagnostics.get("symbolic_gestures", []))[0]).capitalize()
	if not Array(diagnostics.get("run_identity_symbolic_motifs", [])).is_empty():
		return "%s kept giving the run a recognizable authored pattern" % str(Array(diagnostics.get("run_identity_symbolic_motifs", []))[0]).to_lower()
	if not Array(diagnostics.get("run_changing_moments", [])).is_empty():
		return str(Array(diagnostics.get("run_changing_moments", []))[0])
	if str(diagnostics.get("momentum_profile", "")) == "slipping_away":
		return "The run kept slipping as pressure stacked up"
	if str(diagnostics.get("momentum_profile", "")) == "coming_together":
		return "The group slowly pulled the run back together"
	return "The run built a readable pressure pattern"

static func build_revisit_worthiness_band(diagnostics: Dictionary) -> String:
	var score := revisit_worthiness_score(diagnostics)
	return "High" if score >= 8 else "Medium" if score >= 4 else "Low"

static func revisit_worthiness_score(diagnostics: Dictionary) -> int:
	return dramatic_intensity_rank(diagnostics) * 2 + communication_density_rank(diagnostics) + mini(int(diagnostics.get("pressure_beats", 0)), 2) + mini(int(diagnostics.get("retellability_score", 0)) / 2, 3) + (2 if bool(diagnostics.get("interrupted", false)) else 0)

static func build_revisit_worthiness_reason(diagnostics: Dictionary) -> String:
	return "interruption review still unresolved" if bool(diagnostics.get("interrupted", false)) else "a retellable turning run under heavy attention" if int(diagnostics.get("retellability_score", 0)) >= 4 and int(diagnostics.get("spectacle_pressure", 0)) >= 3 else "recovery choices changed the shape of the story" if int(diagnostics.get("recovery_score", 0)) >= 2 else "the run has enough pressure texture to reopen"

static func build_communication_density_band(diagnostics: Dictionary) -> String:
	return "Heavy" if communication_density_rank(diagnostics) == 3 else "Active" if communication_density_rank(diagnostics) == 2 else "Light" if communication_density_rank(diagnostics) == 1 else "Quiet"

static func communication_density_rank(diagnostics: Dictionary) -> int:
	var value := int(diagnostics.get("communication_beats", 0))
	return 3 if value >= 4 else 2 if value >= 2 else 1 if value >= 1 else 0

static func build_dramatic_intensity_band(diagnostics: Dictionary) -> String:
	return "Volatile" if dramatic_intensity_rank(diagnostics) == 3 else "Heated" if dramatic_intensity_rank(diagnostics) == 2 else "Uneasy" if dramatic_intensity_rank(diagnostics) == 1 else "Steady"

static func dramatic_intensity_rank(diagnostics: Dictionary) -> int:
	if bool(diagnostics.get("interrupted", false)) or int(diagnostics.get("spectacle_pressure", 0)) >= 4 or str(diagnostics.get("momentum_profile", "")) in ["spiraling", "slipping_away", "collapsing_late"]:
		return 3
	if int(diagnostics.get("confrontation_score", 0)) >= 2 or int(diagnostics.get("recovery_score", 0)) >= 2:
		return 2
	return 1 if int(diagnostics.get("pressure_beats", 0)) > 0 or int(diagnostics.get("artifact_beats", 0)) > 0 else 0

static func build_interruption_context(diagnostics: Dictionary) -> String:
	return "Completed" if not bool(diagnostics.get("interrupted", false)) else "Wait for lobby" if bool(diagnostics.get("wait_for_lobby", false)) else "Reconnect ready" if bool(diagnostics.get("reconnect_ready", false)) else "Review only"

static func build_interruption_pattern_bucket(diagnostics: Dictionary) -> String:
	return build_interruption_context(diagnostics) if bool(diagnostics.get("interrupted", false)) else "Completed"

static func build_run_cluster_label(diagnostics: Dictionary) -> String:
	if bool(diagnostics.get("interrupted", false)):
		return build_interruption_pattern_bucket(diagnostics)
	if int(diagnostics.get("legend_density_score", 0)) >= 8:
		return "Legend-dense run"
	if int(diagnostics.get("recovery_score", 0)) >= 3:
		return "Recovery-heavy"
	if int(diagnostics.get("spectacle_pressure", 0)) >= 3:
		return "Spectacle-heavy"
	return "Steady"

static func build_signal_stack(diagnostics: Dictionary) -> String:
	return "%s | %s | %s" % [build_revisit_worthiness_band(diagnostics), build_dramatic_intensity_band(diagnostics), _nice(str(diagnostics.get("momentum_profile", "steadying")))]

static func build_debug_lines(diagnostics: Dictionary) -> Array[String]:
	return ["story_density=%d" % int(diagnostics.get("story_density", 0)), "symbolic_gesture_score=%d" % int(diagnostics.get("symbolic_gesture_score", 0)), "recovery_score=%d" % int(diagnostics.get("recovery_score", 0)), "spectacle_pressure=%d" % int(diagnostics.get("spectacle_pressure", 0)), "legend_density_score=%d" % int(diagnostics.get("legend_density_score", 0))]

static func _count_type(events: Array[Dictionary], event_type: String) -> int:
	var count := 0
	for event in events:
		if str(event.get("event_type", "")) == event_type:
			count += 1
	return count

static func _entry_labels(entries: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		result.append(label)
		if result.size() >= limit:
			break
	return result

static func _state_labels(entries: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		var role_name := str(entry.get("role", "")).strip_edges()
		result.append("%s (%s)" % [label, role_name] if not role_name.is_empty() else label)
		if result.size() >= limit:
			break
	return result

static func _room_clusters(events: Array[Dictionary]) -> Array[Dictionary]:
	var by_room := {}
	for event in events:
		var slot := int(event.get("room_slot", -1))
		if not by_room.has(slot):
			by_room[slot] = {"slot": slot, "events": [], "callouts": 0, "pressure": 0, "artifact": 0, "confrontation": 0, "recovery": 0}
		var cluster: Dictionary = by_room[slot]
		cluster["events"].append(event)
		match str(event.get("event_type", "")):
			"room_callout":
				cluster["callouts"] = int(cluster.get("callouts", 0)) + 1
				if str(Dictionary(event.get("meta", {})).get("kind", "")) == "regroup":
					cluster["recovery"] = int(cluster.get("recovery", 0)) + 1
			"artifact_picked", "artifact_dropped", "artifact_stolen", "extraction_window_started", "extraction_completed":
				cluster["artifact"] = int(cluster.get("artifact", 0)) + 1
			"bomb_exploded", "sabotage_accident", "sabotage_camera_jam":
				cluster["confrontation"] = int(cluster.get("confrontation", 0)) + 1
				cluster["pressure"] = int(cluster.get("pressure", 0)) + 1
			"hazard_state_changed", "noise_trace":
				cluster["pressure"] = int(cluster.get("pressure", 0)) + 1
		by_room[slot] = cluster
	var clusters: Array[Dictionary] = []
	for cluster in by_room.values():
		clusters.append(Dictionary(cluster))
	clusters.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return Array(a.get("events", [])).size() > Array(b.get("events", [])).size())
	return clusters

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty():
				result.append(text)
	return result

static func _hits(text: String, keys: Array[String]) -> int:
	var normalized := text.to_lower()
	var hits := 0
	for key in keys:
		if normalized.find(key) != -1:
			hits += 1
	return hits

static func _take_unique(values: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if text.is_empty() or result.has(text):
			continue
		result.append(text)
		if result.size() >= limit:
			break
	return result

static func _actor_label(peer_id: int, local_peer_id: int) -> String:
	return "You" if peer_id == local_peer_id and local_peer_id > 0 else "P%d" % peer_id

static func _nice(text: String) -> String:
	var trimmed := text.strip_edges()
	return trimmed.replace("_", " ").capitalize() if not trimmed.is_empty() else ""

static func _first(values: Array, fallback: String) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _branch_summary(run_record: Dictionary) -> Dictionary:
	var summary: Dictionary = Dictionary(run_record.get("branch_context_summary", {})).duplicate(true)
	if summary.is_empty():
		var rooms := _dict_array(run_record.get("room_chain_summary", []))
		if not rooms.is_empty():
			var first_room: Dictionary = rooms[0]
			summary = Dictionary(first_room.get("branch_context", {})).duplicate(true)
			if not summary.is_empty():
				summary["branch_family_id"] = str(first_room.get("branch_family_id", ""))
				summary["branch_family_name"] = str(first_room.get("branch_family_name", ""))
	if summary.is_empty():
		summary = {
			"branch_family_id": "unknown",
			"branch_family_name": "Unknown Branch",
			"social_pressure": "measured",
			"challenge_texture": "uneven",
			"confrontation_climate": "guarded",
			"rescue_climate": "costly",
			"burden_pressure": "moderate",
			"witness_pressure": "partial",
			"route_commitment": "variable",
			"regroup_friction": "moderate",
			"escape_bandwidth": "tight",
			"pressure_profile": "measured_watch"
		}
	return summary

static func _motion_list(motion_facts: Dictionary, key: String) -> Array:
	var values: Variant = motion_facts.get(key, [])
	return values if values is Array else []

static func _motion_dict(motion_facts: Dictionary, key: String) -> Dictionary:
	var values: Variant = motion_facts.get(key, {})
	return Dictionary(values) if values is Dictionary else {}

static func _motion_room_metric(motion_facts: Dictionary, room_slot: int, key: String) -> int:
	var room_summaries: Dictionary = _motion_dict(motion_facts, "room_summaries")
	var room_key := str(room_slot)
	if not room_summaries.has(room_key):
		return 0
	return int(Dictionary(room_summaries.get(room_key, {})).get(key, 0))

static func _local_gameplay_model(run_record: Dictionary, gameplay_snapshot: Dictionary) -> Dictionary:
	if gameplay_snapshot.is_empty():
		return {}
	var peer_identities: Dictionary = Dictionary(run_record.get("peer_identities", {}))
	var local_peer_id: int = int(run_record.get("local_peer_id", -1))
	var local_card: Dictionary = Dictionary(peer_identities.get(str(local_peer_id), peer_identities.get(local_peer_id, {})))
	var public_id: String = str(local_card.get("public_id", "")).strip_edges()
	var peer_models: Dictionary = Dictionary(gameplay_snapshot.get("peer_models", {}))
	if not public_id.is_empty() and peer_models.has(public_id):
		return _normalize_gameplay_model(Dictionary(peer_models.get(public_id, {})), gameplay_snapshot)
	for model_raw in peer_models.values():
		var model: Dictionary = Dictionary(model_raw)
		if int(model.get("peer_id", -1)) == local_peer_id:
			return _normalize_gameplay_model(model, gameplay_snapshot)
	return {}

static func _group_gameplay_model(gameplay_snapshot: Dictionary) -> Dictionary:
	if gameplay_snapshot.is_empty():
		return {}
	var explicit_group: Dictionary = Dictionary(gameplay_snapshot.get("group_model", {}))
	if not explicit_group.is_empty():
		return explicit_group
	return _derive_group_gameplay_model(
		Dictionary(gameplay_snapshot.get("peer_models", {})),
		str(gameplay_snapshot.get("protocol_state", "")).strip_edges(),
		_string_array(gameplay_snapshot.get("resource_pressure", [])),
		_string_array(gameplay_snapshot.get("inhabitant_pressure", []))
	)

static func _normalize_gameplay_model(model: Dictionary, gameplay_snapshot: Dictionary) -> Dictionary:
	if model.is_empty():
		return {}
	if not Dictionary(model.get("feature_scores", {})).is_empty() and not _string_array(model.get("feature_signals", [])).is_empty() and not _string_array(model.get("model_pressure", [])).is_empty():
		return model
	var normalized: Dictionary = model.duplicate(true)
	var build_identity: String = str(normalized.get("build_identity", "Mixed build")).strip_edges()
	var build_scores: Dictionary = Dictionary(normalized.get("build_scores", {})).duplicate(true)
	var behavior_signals: Array[String] = _string_array(normalized.get("behavior_signals", []))
	var ritual_hooks: Array[String] = _string_array(normalized.get("ritual_hooks", []))
	var anomaly_hooks: Array[String] = _string_array(normalized.get("anomaly_hooks", []))
	var protocol_hooks: Array[String] = _string_array(normalized.get("protocol_hooks", []))
	var resource_signals: Array[String] = _string_array(normalized.get("resource_signals", []))
	var inhabitant_signals: Array[String] = _string_array(normalized.get("inhabitant_signals", []))
	var feature_scores: Dictionary = {
		"rescue_geometry": 0,
		"control_posture": 0,
		"scarcity_tolerance": 0,
		"visibility_pressure": 0,
		"burden_commitment": 0,
		"exposure_handling": 0,
		"spectacle_appetite": 0,
		"resource_caution": 0
	}
	match build_identity:
		"Rescue build":
			feature_scores["rescue_geometry"] = 3
			feature_scores["burden_commitment"] = 2
		"Control build":
			feature_scores["control_posture"] = 3
			feature_scores["visibility_pressure"] = 2
		"Traversal build":
			feature_scores["control_posture"] = 2
		"Exposure build":
			feature_scores["exposure_handling"] = 3
			feature_scores["resource_caution"] = 2
	for behavior_signal in behavior_signals:
		match str(behavior_signal):
			"rescue geometry":
				feature_scores["rescue_geometry"] = int(feature_scores.get("rescue_geometry", 0)) + 2
			"route control", "route memory":
				feature_scores["control_posture"] = int(feature_scores.get("control_posture", 0)) + 2
			"attention split":
				feature_scores["visibility_pressure"] = int(feature_scores.get("visibility_pressure", 0)) + 2
				feature_scores["spectacle_appetite"] = int(feature_scores.get("spectacle_appetite", 0)) + 1
			"burden commitment":
				feature_scores["burden_commitment"] = int(feature_scores.get("burden_commitment", 0)) + 2
	for protocol_hook in protocol_hooks:
		var lowered: String = str(protocol_hook).to_lower()
		if lowered.find("exposure") != -1 or lowered.find("direct pressure") != -1:
			feature_scores["scarcity_tolerance"] = int(feature_scores.get("scarcity_tolerance", 0)) + 2
			feature_scores["resource_caution"] = int(feature_scores.get("resource_caution", 0)) + 1
		if lowered.find("public") != -1 or lowered.find("witness") != -1:
			feature_scores["visibility_pressure"] = int(feature_scores.get("visibility_pressure", 0)) + 1
			feature_scores["spectacle_appetite"] = int(feature_scores.get("spectacle_appetite", 0)) + 1
	for resource_signal in resource_signals:
		var lowered: String = str(resource_signal).to_lower()
		if lowered.find("anchor") != -1 or lowered.find("burden") != -1:
			feature_scores["burden_commitment"] = int(feature_scores.get("burden_commitment", 0)) + 1
		feature_scores["resource_caution"] = int(feature_scores.get("resource_caution", 0)) + 1
	for _inhabitant_signal in inhabitant_signals:
		feature_scores["exposure_handling"] = int(feature_scores.get("exposure_handling", 0)) + 1
	var feature_signals: Array[String] = _string_array(normalized.get("feature_signals", []))
	if int(feature_scores.get("rescue_geometry", 0)) >= 3:
		feature_signals.append("rescue answer geometry")
	if int(feature_scores.get("burden_commitment", 0)) >= 2:
		feature_signals.append("burden answer")
	if int(feature_scores.get("resource_caution", 0)) >= 2:
		feature_signals.append("resource caution")
	if int(feature_scores.get("spectacle_appetite", 0)) >= 2:
		feature_signals.append("public answer appetite")
	feature_signals = _take_unique(feature_signals, 6)
	var build_stability: int = int(normalized.get("build_stability", 0))
	if build_stability <= 0:
		var primary_score: int = int(build_scores.get(build_identity, 0))
		build_stability = clampi(primary_score + (2 if feature_signals.size() >= 2 else 0) + (1 if not ritual_hooks.is_empty() else 0), 1, 6)
	var risk_profile: String = str(normalized.get("risk_profile", "")).strip_edges()
	if risk_profile.is_empty():
		if int(feature_scores.get("spectacle_appetite", 0)) >= 2:
			risk_profile = "performative"
		elif int(feature_scores.get("resource_caution", 0)) >= 2:
			risk_profile = "disciplined"
		elif int(feature_scores.get("burden_commitment", 0)) >= 2:
			risk_profile = "committed"
		else:
			risk_profile = "mixed"
	var model_pressure: Array[String] = _string_array(normalized.get("model_pressure", []))
	if model_pressure.is_empty():
		if feature_signals.has("burden answer"):
			model_pressure.append("burden-rescue answer")
		if int(feature_scores.get("control_posture", 0)) >= 3:
			model_pressure.append("route-control answer")
		if int(feature_scores.get("spectacle_appetite", 0)) >= 2:
			model_pressure.append("public misdirection answer")
		if not ritual_hooks.is_empty() or not anomaly_hooks.is_empty():
			model_pressure.append("ritual anomaly answer")
		if int(feature_scores.get("resource_caution", 0)) >= 2 or str(gameplay_snapshot.get("protocol_state", "")) == "Exposure Protocol":
			model_pressure.append("scarcity fallback answer")
		model_pressure = _take_unique(model_pressure, 4)
	normalized["feature_scores"] = feature_scores
	normalized["feature_signals"] = feature_signals
	normalized["build_stability"] = build_stability
	normalized["risk_profile"] = risk_profile
	normalized["model_pressure"] = model_pressure
	return normalized

static func _derive_group_gameplay_model(peer_models: Dictionary, protocol_state: String, resource_pressure: Array[String], inhabitant_pressure: Array[String]) -> Dictionary:
	var build_totals: Dictionary = {}
	var signal_weights: Dictionary = {}
	var fault_lines: Array[String] = []
	var model_pressure: Array[String] = []
	var profile_counts: Dictionary = {}
	var dominant_build: String = ""
	var dominant_score: int = -1
	var widest_stability: int = 0
	var volatile_count: int = 0
	var committed_count: int = 0
	var prepared_count: int = 0
	for model_raw in peer_models.values():
		var model: Dictionary = _normalize_gameplay_model(Dictionary(model_raw), {"protocol_state": protocol_state})
		var build_identity: String = str(model.get("build_identity", "")).strip_edges()
		if not build_identity.is_empty():
			build_totals[build_identity] = int(build_totals.get(build_identity, 0)) + int(Dictionary(model.get("build_scores", {})).get(build_identity, 0)) + 1
		for score_key in Dictionary(model.get("feature_scores", {})).keys():
			var score_value: int = int(Dictionary(model.get("feature_scores", {})).get(score_key, 0))
			if score_value > 0:
				signal_weights[score_key] = int(signal_weights.get(score_key, 0)) + score_value
		for signal_value in _string_array(model.get("feature_signals", [])) + _string_array(model.get("behavior_signals", [])) + _string_array(model.get("model_pressure", [])):
			var signal_text: String = str(signal_value).strip_edges()
			if not signal_text.is_empty():
				signal_weights[signal_text] = int(signal_weights.get(signal_text, 0)) + 1
		var risk_profile: String = str(model.get("risk_profile", "mixed")).strip_edges()
		if not risk_profile.is_empty():
			profile_counts[risk_profile] = int(profile_counts.get(risk_profile, 0)) + 1
		if risk_profile in ["volatile", "performative"]:
			volatile_count += 1
		elif risk_profile == "committed":
			committed_count += 1
		elif risk_profile in ["prepared", "disciplined"]:
			prepared_count += 1
		widest_stability = maxi(widest_stability, int(model.get("build_stability", 0)))
	for build_label in build_totals.keys():
		var score: int = int(build_totals.get(build_label, 0))
		if score > dominant_score or (score == dominant_score and str(build_label) < dominant_build):
			dominant_score = score
			dominant_build = str(build_label)
	if volatile_count >= 1 and committed_count >= 1:
		fault_lines.append("the group is split between a volatile answer and a rescue answer")
	if resource_pressure.size() >= 2 and inhabitant_pressure.size() >= 1:
		fault_lines.append("resource caution and presence pressure are pulling in different directions")
	if build_totals.size() >= 2:
		fault_lines.append("too many answer shapes are competing for the same run")
	if protocol_state == "Exposure Protocol" and committed_count >= 1 and volatile_count >= 1:
		fault_lines.append("low-density pressure is exposing incompatible answers")
	if signal_weights.has("public answer appetite") and signal_weights.has("resource caution"):
		fault_lines.append("spectacle appetite is colliding with cost control")
	if signal_weights.has("burden-rescue answer"):
		model_pressure.append("the group keeps bending toward a burden-rescue answer")
	if signal_weights.has("route-control answer"):
		model_pressure.append("route-control is starting to look like the shared answer")
	if signal_weights.has("public misdirection answer"):
		model_pressure.append("the public line keeps accepting a misdirection-shaped answer")
	if signal_weights.has("ritual anomaly answer"):
		model_pressure.append("ritual instability is starting to matter to the group read")
	if signal_weights.has("scarcity fallback answer"):
		model_pressure.append("fallback logic keeps setting the acceptable answer")
	if protocol_state == "Exposure Protocol" and prepared_count >= 1:
		model_pressure.append("low-density pressure is rewarding prepared answers")
	var group_signals: Array[String] = []
	var weighted_keys: Array[Dictionary] = []
	for signal_key in signal_weights.keys():
		weighted_keys.append({"label": str(signal_key), "weight": int(signal_weights.get(signal_key, 0))})
	weighted_keys.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(a.get("label", "")) < str(b.get("label", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	for entry_raw in weighted_keys:
		var entry: Dictionary = Dictionary(entry_raw)
		var label: String = str(entry.get("label", "")).strip_edges()
		if not label.is_empty():
			group_signals.append(label)
		if group_signals.size() >= 4:
			break
	var protocol_weighting: String = "balanced"
	if protocol_state == "Exposure Protocol":
		protocol_weighting = "isolation pressure"
	elif protocol_state == "Intimate Protocol":
		protocol_weighting = "pair pressure"
	elif protocol_state == "Fracture Protocol":
		protocol_weighting = "split pressure"
	elif protocol_state == "Expedition Protocol":
		protocol_weighting = "spectacle pressure"
	var build_spread: Array[String] = []
	for build_label in build_totals.keys():
		build_spread.append(str(build_label))
	build_spread.sort()
	return {
		"dominant_build": dominant_build,
		"build_spread": build_spread,
		"group_signals": group_signals,
		"fault_lines": _take_unique(fault_lines, 4),
		"model_pressure": _take_unique(model_pressure, 4),
		"protocol_weighting": protocol_weighting,
		"widest_stability": widest_stability,
		"risk_profiles": profile_counts
	}

static func _pair_metric(motion_facts: Dictionary, pair_key: String, key: String) -> int:
	var pair_summaries: Dictionary = _motion_dict(motion_facts, "pair_summaries")
	if not pair_summaries.has(pair_key):
		return 0
	return int(Dictionary(pair_summaries.get(pair_key, {})).get(key, 0))

static func _saturation_adjusted_strings(values: Array[String], limit: int) -> Array[String]:
	if values.is_empty():
		return []
	var adjusted := _take_unique(values, limit)
	if values.size() > limit + 2:
		return adjusted
	if adjusted.size() > limit:
		return adjusted.slice(0, limit)
	return adjusted

static func _pair_keys(events: Array[Dictionary], local_peer_id: int, motion_facts: Dictionary = {}) -> Array[String]:
	var last_by_room := {}
	var scores := {}
	for event in events:
		var slot := int(event.get("room_slot", -1))
		var actor := int(event.get("actor_peer_id", -1))
		if actor <= 0:
			continue
		var previous := int(last_by_room.get(slot, -1))
		if previous > 0 and previous != actor:
			var pair_key := _actor_label(previous, local_peer_id) + ":" + _actor_label(actor, local_peer_id)
			if pair_key.get_slice(":", 0) > pair_key.get_slice(":", 1):
				pair_key = pair_key.get_slice(":", 1) + ":" + pair_key.get_slice(":", 0)
			scores[pair_key] = int(scores.get(pair_key, 0)) + 1
		last_by_room[slot] = actor
	var keys: Array[String] = []
	for pair_key in scores.keys():
		if int(scores.get(pair_key, 0)) >= 2:
			keys.append(str(pair_key))
	for pair_key in _motion_dict(motion_facts, "pair_summaries").keys():
		if _pair_metric(motion_facts, str(pair_key), "proximity") >= 3 or _pair_metric(motion_facts, str(pair_key), "following") >= 2:
			keys.append(str(pair_key))
	keys.sort()
	return _take_unique(keys, 4)

static func _symbolic_gestures(events: Array[Dictionary], run_record: Dictionary, motion_facts: Dictionary = {}) -> Array[String]:
	var gestures: Array[String] = []
	var last_drop_by_artifact := {}
	for event in events:
		var event_type := str(event.get("event_type", ""))
		var meta: Dictionary = Dictionary(event.get("meta", {}))
		if event_type == "artifact_dropped":
			var artifact_id := int(meta.get("artifact_id", 0))
			if artifact_id > 0:
				last_drop_by_artifact[artifact_id] = event
			if not gestures.has("deliberate drop"):
				gestures.append("deliberate drop")
		elif event_type == "artifact_picked":
			var artifact_id := int(meta.get("artifact_id", 0))
			if artifact_id > 0 and last_drop_by_artifact.has(artifact_id):
				var drop_event: Dictionary = Dictionary(last_drop_by_artifact.get(artifact_id, {}))
				if int(drop_event.get("actor_peer_id", -1)) != int(event.get("actor_peer_id", -1)) and not gestures.has("burden handoff"):
					gestures.append("burden handoff")
		elif event_type == "artifact_stolen" and not gestures.has("forced handoff"):
			gestures.append("forced handoff")
		elif event_type == "item_used":
			var label := str(meta.get("label", "")).to_lower()
			if label.find("zipline") != -1 and not gestures.has("threshold commitment"):
				gestures.append("threshold commitment")
			elif label.find("decoy") != -1 and not gestures.has("baited split"):
				gestures.append("baited split")
			elif label.find("timeline") != -1 and not gestures.has("public mark"):
				gestures.append("public mark")
	for pair_key in _motion_dict(motion_facts, "pair_summaries").keys():
		if _pair_metric(motion_facts, str(pair_key), "shared_carry_pressure") >= 2 and not gestures.has("burden handoff"):
			gestures.append("burden handoff")
	var room_summaries := _motion_dict(motion_facts, "room_summaries")
	for room_key in room_summaries.keys():
		var room_summary: Dictionary = Dictionary(room_summaries.get(room_key, {}))
		if int(room_summary.get("threshold_waits", 0)) >= 2 and not gestures.has("yielded threshold"):
			gestures.append("yielded threshold")
		if int(room_summary.get("collective_hesitations", 0)) >= 2 and not gestures.has("making space under pressure"):
			gestures.append("making space under pressure")
	if Array(run_record.get("item_defs", [])).size() == 1 and not gestures.has("solo carry"):
		gestures.append("solo carry")
	return _saturation_adjusted_strings(gestures, 5)

static func _choice_frames(interrupted: bool, events: Array[Dictionary], symbolic_gestures: Array[String], spectacle_pressure: int, confrontation_score: int, motion_facts: Dictionary = {}, branch_summary: Dictionary = {}) -> Array[String]:
	var frames: Array[String] = []
	if confrontation_score >= 2 and spectacle_pressure >= 3:
		frames.append("performative choice")
	if symbolic_gestures.has("burden handoff") or symbolic_gestures.has("solo carry"):
		frames.append("loyalty-first choice")
	if symbolic_gestures.has("threshold commitment"):
		frames.append("baited choice")
	if interrupted:
		frames.append("resigned choice")
	if _count_type(events, "artifact_picked") > _count_type(events, "artifact_dropped"):
		frames.append("dutiful choice")
	if int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0)) > 0:
		frames.append("baited choice")
	if str(branch_summary.get("route_commitment", "")) == "severe":
		frames.append("desperate choice")
	if frames.is_empty():
		frames.append("quietly practical choice")
	return _take_unique(frames, 4)

static func _attention_patterns(events: Array[Dictionary], motion_facts: Dictionary = {}) -> Array[String]:
	var counts := {
		"threshold return": 0,
		"artifact recheck": 0,
		"public watch": 0,
		"route revisit": 0
	}
	var last_room := -999
	for event in events:
		var event_type := str(event.get("event_type", ""))
		var slot := int(event.get("room_slot", -1))
		if last_room == slot and slot >= 0:
			counts["route revisit"] = int(counts.get("route revisit", 0)) + 1
		last_room = slot
		if event_type == "artifact_picked" or event_type == "artifact_dropped" or event_type == "artifact_stolen":
			counts["artifact recheck"] = int(counts.get("artifact recheck", 0)) + 1
		elif event_type == "room_callout":
			counts["public watch"] = int(counts.get("public watch", 0)) + 1
		elif event_type == "item_used":
			var label := str(Dictionary(event.get("meta", {})).get("label", "")).to_lower()
			if label.find("zipline") != -1 or label.find("rope") != -1:
				counts["threshold return"] = int(counts.get("threshold return", 0)) + 1
	var patterns: Array[String] = []
	for key in ["artifact recheck", "public watch", "route revisit", "threshold return"]:
		if int(counts.get(key, 0)) >= 2:
			patterns.append(key)
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if int(strong_rooms.get("returns", 0)) >= 2:
		patterns.append("repeated returns")
	if int(strong_rooms.get("lingers", 0)) >= 2:
		patterns.append("loaded lingering")
	for pair_key in _motion_dict(motion_facts, "pair_summaries").keys():
		if _pair_metric(motion_facts, str(pair_key), "following") >= 2:
			patterns.append("repeated following")
			break
	return _saturation_adjusted_strings(patterns, 4)

static func _expectation_breaks(run_record: Dictionary, events: Array[Dictionary], confrontation_score: int, recovery_score: int, spectacle_pressure: int, motion_facts: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	if spectacle_pressure >= 3 and confrontation_score <= 1 and bool(outcome_summary.get("expedition_success", false)):
		result.append("Restraint after buildup")
	if confrontation_score >= 1 and recovery_score >= 2:
		result.append("Rescue after hesitation")
	if _count_type(events, "artifact_stolen") > 0 and recovery_score >= 2:
		result.append("Mercy after rivalry")
	if int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0)) >= 2 and recovery_score >= 2:
		result.append("Commitment after repeated hesitation")
	return _take_unique(result, 4)

static func _timeline_thirds(events: Array[Dictionary]) -> Dictionary:
	var result := {"early": 0, "mid": 0, "late": 0}
	if events.is_empty():
		return result
	var count := maxi(events.size(), 1)
	for i in range(events.size()):
		var bucket := "early"
		if i >= int(ceil(float(count) * 0.66)):
			bucket = "late"
		elif i >= int(ceil(float(count) * 0.33)):
			bucket = "mid"
		result[bucket] = int(result.get(bucket, 0)) + 1
	return result

static func _pace_profile(events: Array[Dictionary], communication: Dictionary, confrontation_score: int, recovery_score: int, motion_facts: Dictionary = {}) -> String:
	if events.is_empty():
		return "low_signal"
	var thirds := _timeline_thirds(events)
	var room_summaries := _motion_dict(motion_facts, "room_summaries")
	var late_hesitation := 0
	for room_summary_variant in room_summaries.values():
		var room_summary: Dictionary = Dictionary(room_summary_variant)
		late_hesitation += int(room_summary.get("threshold_waits", 0))
	if int(thirds.get("late", 0)) >= int(thirds.get("early", 0)) + 2:
		return "delayed_climax"
	if int(thirds.get("early", 0)) >= int(thirds.get("late", 0)) + 2:
		return "abrupt_collapse"
	if confrontation_score >= 2 and recovery_score >= 2:
		return "oscillating_tension"
	if late_hesitation >= 3:
		return "false_calm_before_rupture"
	if int(communication.get("total", 0)) >= 3:
		return "slow_burn"
	return "steady_progress"

static func _group_shape_drift(pair_keys: Array[String], recovery_score: int, confrontation_score: int, communication: Dictionary) -> String:
	if confrontation_score >= 3 and recovery_score <= 1:
		return "unified_to_fragmented"
	if confrontation_score >= 1 and recovery_score >= 2:
		return "wary_to_loyal"
	if int(communication.get("regroup", 0)) >= 2 and recovery_score >= 3:
		return "chaotic_to_disciplined"
	if pair_keys.size() >= 2:
		return "brittle_to_mythic"
	return "stable_to_overexposed" if int(communication.get("total", 0)) >= 3 else "steady"

static func _crew_hooks(group_shape_drift: String, social_temperature: String, recovery_score: int, confrontation_score: int) -> Array[String]:
	var hooks: Array[String] = []
	if group_shape_drift == "wary_to_loyal":
		hooks.append("crew trust recovery")
	elif group_shape_drift == "unified_to_fragmented":
		hooks.append("crew fracture")
	elif group_shape_drift == "chaotic_to_disciplined":
		hooks.append("hold-together crew")
	elif group_shape_drift == "brittle_to_mythic":
		hooks.append("mythic crew turn")
	if social_temperature == "performative_bravado":
		hooks.append("public crew heat")
	if recovery_score >= 3:
		hooks.append("recovery chain")
	if confrontation_score >= 3:
		hooks.append("conflict-heavy crew")
	return hooks.slice(0, mini(hooks.size(), 4))

static func _recovery_ecology(recovery_score: int, confrontation_score: int, motion_facts: Dictionary, symbolic_gestures: Array[String]) -> Array[String]:
	var result: Array[String] = []
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if recovery_score >= 2:
		result.append("regrouping under pressure")
	if int(strong_rooms.get("returns", 0)) >= 2:
		result.append("re-forming after split")
	if symbolic_gestures.has("burden handoff"):
		result.append("resuming burden after disruption")
	if confrontation_score >= 2 and recovery_score >= 2:
		result.append("covering retreat under threat")
	if int(strong_rooms.get("collective_hesitations", 0)) >= 2 and recovery_score >= 1:
		result.append("stabilizing after hesitation")
	return _saturation_adjusted_strings(result, 4)

static func _ritual_recurrence(symbolic_gestures: Array[String], motion_facts: Dictionary, branch_summary: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if symbolic_gestures.has("threshold commitment") and int(strong_rooms.get("threshold_hesitation", 0)) >= 2:
		result.append("returning threshold ritual")
	if symbolic_gestures.has("burden handoff") and int(strong_rooms.get("burden_pressure", 0)) >= 2:
		result.append("shared burden rite")
	if int(strong_rooms.get("returns", 0)) >= 2:
		result.append("route return ritual")
	if str(branch_summary.get("challenge_texture", "")) == "high ceremony":
		result.append("branch dare recurrence")
	return _saturation_adjusted_strings(result, 4)

static func _territory_claims(motion_facts: Dictionary, branch_summary: Dictionary, confrontation_score: int) -> Array[String]:
	var result: Array[String] = []
	for room_key in _motion_dict(motion_facts, "room_summaries").keys():
		var room_summary: Dictionary = Dictionary(_motion_dict(motion_facts, "room_summaries").get(room_key, {}))
		if int(room_summary.get("threshold_waits", 0)) >= 2:
			result.append("%s held the threshold" % room_key)
		if int(room_summary.get("territory_holds", 0)) >= 2:
			result.append("%s became defended ground" % room_key)
	if confrontation_score >= 2 and str(branch_summary.get("confrontation_climate", "")).find("cutoff") != -1:
		result.append("route control mattered")
	return _saturation_adjusted_strings(result, 3)

static func _quest_collisions(recovery_score: int, confrontation_score: int, burden_score: int, spectacle_pressure: int, expectation_breaks: Array[String], branch_summary: Dictionary, motion_facts: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if recovery_score >= 2 and spectacle_pressure >= 3:
		result.append("rescue obligation vs public dare")
	if burden_score >= 2 and confrontation_score >= 2:
		result.append("carry pressure vs conflict line")
	if str(branch_summary.get("challenge_texture", "")) == "high ceremony" and not expectation_breaks.is_empty():
		result.append("branch dare vs restraint")
	if int(_motion_dict(motion_facts, "strong_rooms").get("collective_hesitations", 0)) >= 2 and confrontation_score >= 1:
		result.append("hold together vs rivalry")
	return _saturation_adjusted_strings(result, 3)

static func _momentum_profile(pace_profile: String, group_shape_drift: String, recovery_score: int, confrontation_score: int, burden_score: int, motion_facts: Dictionary = {}) -> String:
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if confrontation_score >= 3 and recovery_score <= 1:
		return "spiraling"
	if pace_profile == "delayed_climax" and recovery_score <= 1:
		return "slipping_away"
	if recovery_score >= 3 and group_shape_drift in ["wary_to_loyal", "chaotic_to_disciplined"]:
		return "coming_together"
	if recovery_score >= 2 and confrontation_score <= 1:
		return "steadying"
	if int(strong_rooms.get("collective_hesitations", 0)) >= 3:
		return "hanging_on"
	if burden_score >= 3:
		return "wobbling"
	if pace_profile == "abrupt_collapse":
		return "collapsing_late"
	return "grinding_forward"

static func _social_temperature(communication: Dictionary, confrontation_score: int, recovery_score: int, spectacle_pressure: int, pair_keys: Array[String], motion_facts: Dictionary = {}) -> String:
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if confrontation_score >= 3 and spectacle_pressure >= 3:
		return "performative_bravado"
	if recovery_score >= 3 and confrontation_score <= 1:
		return "quiet_discipline"
	if recovery_score >= 2 and confrontation_score >= 1:
		return "brittle_cooperation"
	if pair_keys.size() >= 1 and confrontation_score >= 1:
		return "simmering_rivalry"
	if int(strong_rooms.get("collective_hesitations", 0)) >= 2:
		return "wary_civility"
	return "calm_trust" if int(communication.get("regroup", 0)) > 0 else "fatalistic_teamwork"

static func _atmosphere(momentum_profile: String, social_temperature: String, spectacle_pressure: int, confrontation_score: int, expectation_breaks: Array[String], silence_clusters: Array[String] = []) -> String:
	if not expectation_breaks.is_empty() and momentum_profile == "coming_together":
		return "redemptive"
	if spectacle_pressure >= 4 and confrontation_score >= 3:
		return "overexposed"
	if confrontation_score >= 3:
		return "ugly"
	if not silence_clusters.is_empty() and social_temperature in ["wary_civility", "brittle_cooperation"]:
		return "ominous"
	if social_temperature == "quiet_discipline":
		return "hard_won"
	if momentum_profile in ["slipping_away", "spiraling", "collapsing_late"]:
		return "desperate"
	return "disciplined"

static func _room_identities(room_clusters: Array[Dictionary], confrontation_score: int, recovery_score: int, burden_score: int, motion_facts: Dictionary = {}, branch_summary: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for cluster in room_clusters.slice(0, 3):
		var label := ""
		var slot := int(cluster.get("slot", -1))
		var threshold_waits := _motion_room_metric(motion_facts, slot, "threshold_waits")
		var collective_hesitations := _motion_room_metric(motion_facts, slot, "collective_hesitations")
		if int(cluster.get("confrontation", 0)) + confrontation_score >= 3:
			label = "standoff zone"
		elif int(cluster.get("artifact", 0)) > 0 and int(cluster.get("recovery", 0)) + recovery_score >= 2:
			label = "rescue decision site"
		elif int(cluster.get("artifact", 0)) > 0 and burden_score >= 2:
			label = "temptation chamber"
		elif threshold_waits >= 2:
			label = "ritual location"
		elif collective_hesitations >= 2:
			label = "negotiation space"
		elif int(cluster.get("pressure", 0)) >= 2:
			label = "sacrifice point"
		elif int(cluster.get("callouts", 0)) >= 2:
			label = "negotiation space"
		if str(branch_summary.get("confrontation_climate", "")) == "precarious" and label == "standoff zone":
			label = "confrontation chamber"
		if not label.is_empty() and not result.has(label):
			result.append(label)
	return _saturation_adjusted_strings(result, 4)

static func _run_changing_moments(symbolic_gestures: Array[String], expectation_breaks: Array[String], confrontation_score: int, recovery_score: int, spectacle_windows: Array[String] = [], motion_facts: Dictionary = {}) -> Array[String]:
	var moments: Array[String] = []
	for gesture in symbolic_gestures:
		if moments.size() >= 3:
			break
		moments.append("%s changed the read of the run" % gesture.capitalize())
	for value in expectation_breaks:
		if moments.size() >= 3:
			break
		moments.append(value)
	if moments.is_empty() and recovery_score >= 2:
		moments.append("Recovery effort changed the run's direction")
	if moments.is_empty() and confrontation_score >= 2:
		moments.append("A confrontation changed the social weather")
	for window in spectacle_windows:
		if moments.size() >= 4:
			break
		moments.append(window)
	if int(_motion_dict(motion_facts, "strong_rooms").get("returns", 0)) >= 3 and moments.size() < 4:
		moments.append("Returning pressure changed the route's meaning")
	return _saturation_adjusted_strings(moments, 3)

static func _transition_tension(room_clusters: Array[Dictionary], events: Array[Dictionary], motion_facts: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	if events.size() >= 2 and int(events[0].get("room_slot", -1)) != int(events[events.size() - 1].get("room_slot", -1)):
		result.append("threshold drift across the route")
	if not room_clusters.is_empty() and int(Dictionary(room_clusters[0]).get("callouts", 0)) >= 2:
		result.append("threshold waiting before commitment")
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if int(strong_rooms.get("threshold_hesitation", 0)) >= 2:
		result.append("hesitation gathered at the threshold")
	if int(strong_rooms.get("returns", 0)) >= 2:
		result.append("the route kept pulling the group back")
	return _saturation_adjusted_strings(result, 3)

static func _load_bearing_places(room_clusters: Array[Dictionary], highlights: Array[String], motion_facts: Dictionary = {}, branch_summary: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for i in range(mini(room_clusters.size(), highlights.size())):
		result.append("room %d - %s" % [int(Dictionary(room_clusters[i]).get("slot", -1)), highlights[i]])
	for room_key in _motion_dict(motion_facts, "room_summaries").keys():
		var room_summary: Dictionary = Dictionary(_motion_dict(motion_facts, "room_summaries").get(room_key, {}))
		if int(room_summary.get("threshold_waits", 0)) >= 2:
			result.append("threshold %s - hesitation point" % room_key)
		elif int(room_summary.get("returns", 0)) >= 2:
			result.append("route %s - return pressure" % room_key)
	if str(branch_summary.get("symbolic_anchor", "")) != "":
		result.append("%s - branch echo" % str(branch_summary.get("symbolic_anchor", "")))
	return _saturation_adjusted_strings(result, 4)

static func _load_bearing_objects(run_record: Dictionary, symbolic_gestures: Array[String], motion_facts: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for item_id in Array(run_record.get("item_defs", [])):
		result.append(str(item_id).replace("_", " "))
	if symbolic_gestures.has("burden handoff"):
		result.append("carry line")
	if int(_motion_dict(motion_facts, "strong_rooms").get("burden_pressure", 0)) >= 2:
		result.append("shared burden")
	return _saturation_adjusted_strings(result, 4)

static func _witness_topology(events: Array[Dictionary], communication: Dictionary, confrontation_score: int, spectacle_pressure: int, motion_facts: Dictionary = {}) -> String:
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if spectacle_pressure >= 4 or int(communication.get("total", 0)) >= 4:
		return "public_chain"
	if int(strong_rooms.get("collective_hesitations", 0)) >= 2:
		return "witnessed_pause"
	if confrontation_score >= 2:
		return "split_witness"
	if events.size() <= 2:
		return "private_edge"
	return "partial_chain"

static func _social_topology(pair_keys: Array[String], events: Array[Dictionary], communication: Dictionary, motion_facts: Dictionary = {}) -> String:
	var pair_summaries: Dictionary = _motion_dict(motion_facts, "pair_summaries")
	for pair_key in pair_summaries.keys():
		if _pair_metric(motion_facts, str(pair_key), "following") >= 2 and _pair_metric(motion_facts, str(pair_key), "proximity") >= 3:
			return "shadow_pair"
	if pair_keys.size() >= 2:
		return "fractured_crew"
	if pair_keys.size() == 1:
		return "paired_focus"
	if int(communication.get("regroup", 0)) >= 2:
		return "grouped_push"
	return "loose_spacing" if events.size() >= 4 else "sparse_contact"

static func _emotional_trajectory(pace_profile: String, momentum_profile: String, social_temperature: String, expectation_breaks: Array[String], escalation_arc: String = "") -> String:
	if not expectation_breaks.is_empty():
		return "pressure bent into inversion"
	if escalation_arc == "calm_to_suspicion_to_standoff":
		return "stable teamwork into creeping distrust"
	if escalation_arc == "crisis_to_rescue_under_threat":
		return "near-disaster into redemption"
	if pace_profile == "oscillating_tension":
		return "chaos into recovery into collapse"
	if momentum_profile == "coming_together":
		return "near-disaster into redemption"
	if social_temperature == "simmering_rivalry":
		return "stable teamwork into creeping distrust"
	if pace_profile == "slow_burn":
		return "cautious beginning into reckless escalation"
	return "steady pressure into resolution"

static func _within_run_echoes(events: Array[Dictionary], symbolic_gestures: Array[String], motion_facts: Dictionary = {}) -> Array[String]:
	var echoes: Array[String] = []
	if _count_type(events, "artifact_dropped") >= 2:
		echoes.append("Repeated burden drops")
	if _count_type(events, "room_callout") >= 3:
		echoes.append("Repeated public warnings")
	if symbolic_gestures.has("burden handoff"):
		echoes.append("Repeated handoff pressure")
	if int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0)) >= 2:
		echoes.append("Repeated threshold hesitation")
	return _saturation_adjusted_strings(echoes, 4)

static func _anticipation_hooks(expectation_tension: String, interrupted: bool, attention_patterns: Array[String], expectation_breaks: Array[String], branch_summary: Dictionary = {}, pressure_persistence: Array[String] = []) -> Array[String]:
	var hooks: Array[String] = []
	if expectation_tension == "loaded":
		hooks.append("Will the next room pay off the pressure?")
	if not attention_patterns.is_empty():
		hooks.append("Why did the run keep returning to the same pressure?")
	if not expectation_breaks.is_empty():
		hooks.append("Does the inversion hold next time?")
	if str(branch_summary.get("challenge_texture", "")) == "high ceremony":
		hooks.append("What does this branch keep asking for?")
	if not pressure_persistence.is_empty():
		hooks.append("Which pressure returns the next time this line opens?")
	if interrupted:
		hooks.append("What would have happened if the run had resolved?")
	return _take_unique(hooks, 4)

static func _protocol_state_hint(run_record: Dictionary, events: Array[Dictionary], gameplay_snapshot: Dictionary = {}) -> String:
	var snapshot_state := str(gameplay_snapshot.get("protocol_state", "")).strip_edges()
	if not snapshot_state.is_empty():
		return snapshot_state
	var peer_identities: Dictionary = Dictionary(run_record.get("peer_identities", {}))
	var actor_ids := {}
	for peer_key in peer_identities.keys():
		actor_ids[str(peer_key)] = true
	for event in events:
		var actor_peer_id := int(Dictionary(event).get("actor_peer_id", -1))
		if actor_peer_id > 0:
			actor_ids[str(actor_peer_id)] = true
	var player_count := actor_ids.size()
	if player_count <= 1:
		return "Exposure Protocol"
	if player_count <= 3:
		return "Intimate Protocol"
	if player_count <= 7:
		return "Fracture Protocol"
	return "Expedition Protocol"

static func _belief_state(
	run_record: Dictionary,
	branch_summary: Dictionary,
	attention_patterns: Array[String],
	expectation_breaks: Array[String],
	spectacle_windows: Array[String],
	quest_collisions: Array[String],
	recovery_ecology: Array[String],
	pressure_persistence: Array[String],
	momentum_profile: String,
	social_temperature: String,
	protocol_state_hint: String,
	build_identity: String,
	gameplay_feature_signals: Array[String],
	gameplay_behavior_signals: Array[String],
	inhabitant_pressure: Array[String],
	group_fault_lines: Array[String],
	model_pressure: Array[String]
) -> Dictionary:
	var pair_key := _first(_pair_keys(_dict_array(run_record.get("timeline_public_events", [])), int(run_record.get("local_peer_id", -1)), Dictionary(run_record.get("narrative_motion_facts", {}))), "")
	var rescue_answer := _first(recovery_ecology, "")
	var fault_line := _first(expectation_breaks, _first(quest_collisions, ""))
	var myth_attractor := _first(spectacle_windows, _first(pressure_persistence, ""))
	var branch_name := str(branch_summary.get("branch_family_name", "")).strip_edges()
	if rescue_answer.is_empty() and not pair_key.is_empty():
		rescue_answer = "%s keeps looking like the likely answer line" % _pair_label(pair_key)
	elif not rescue_answer.is_empty():
		rescue_answer = "%s still looks like the likely answer" % rescue_answer
	if fault_line.is_empty() and social_temperature.find("rival") != -1:
		fault_line = "the social line still looks unstable"
	elif not fault_line.is_empty():
		fault_line = "%s still looks like the likely fault line" % fault_line
	if myth_attractor.is_empty() and not branch_name.is_empty():
		myth_attractor = "%s keeps attracting the same pressure" % branch_name
	elif not myth_attractor.is_empty():
		myth_attractor = "%s is still acting like the myth attractor" % myth_attractor
	if myth_attractor.is_empty() and not build_identity.is_empty():
		myth_attractor = "%s kept bending the answer line" % build_identity.to_lower()
	if myth_attractor.is_empty() and not model_pressure.is_empty():
		myth_attractor = "%s kept bending the group answer" % model_pressure[0]
	var collapse_line := ""
	if momentum_profile in ["slipping_away", "spiraling", "collapsing_late"]:
		collapse_line = _first(pressure_persistence, "the same pressure stack")
		collapse_line = "%s still looks like the likely collapse line" % collapse_line
	elif not group_fault_lines.is_empty():
		collapse_line = "%s still looks like the likely collapse line" % group_fault_lines[0]
	var attention_sink := ""
	if attention_patterns.has("repeated attention"):
		attention_sink = "attention kept circling the same line"
	elif attention_patterns.has("repeated following"):
		attention_sink = "attention kept following the same answer"
	elif not inhabitant_pressure.is_empty():
		attention_sink = "pressure kept bending around %s" % inhabitant_pressure[0]
	if rescue_answer.is_empty() and not build_identity.is_empty() and build_identity == "Rescue build":
		rescue_answer = "the run kept leaning on a rescue-shaped loadout"
	if rescue_answer.is_empty() and gameplay_feature_signals.has("burden answer"):
		rescue_answer = "the run kept leaning on the burden answer"
	if rescue_answer.is_empty() and gameplay_feature_signals.has("rescue answer geometry"):
		rescue_answer = "the run kept leaning on a rescue-shaped answer"
	if fault_line.is_empty() and gameplay_behavior_signals.has("panic lure"):
		fault_line = "baited pressure kept threatening the group read"
	if fault_line.is_empty() and not group_fault_lines.is_empty():
		fault_line = "%s still looks like the likely fault line" % group_fault_lines[0]
	return {
		"rescue_answer": rescue_answer,
		"fault_line": fault_line,
		"collapse_line": collapse_line,
		"myth_attractor": myth_attractor,
		"attention_sink": attention_sink,
		"protocol_state": protocol_state_hint
	}

static func _counterfactual_pressure(
	expectation_breaks: Array[String],
	near_miss_score: int,
	pressure_persistence: Array[String],
	recovery_ecology: Array[String],
	interrupted: bool,
	protocol_state_hint: String,
	resource_pressure: Array[String],
	risk_profile: String,
	group_fault_lines: Array[String],
	model_pressure: Array[String]
) -> Array[String]:
	var result: Array[String] = []
	if not expectation_breaks.is_empty():
		result.append("the run is still being judged against %s" % expectation_breaks[0].to_lower())
	if near_miss_score >= 2:
		result.append("the almost-answer is still hanging over the run")
	if not pressure_persistence.is_empty() and not recovery_ecology.is_empty():
		result.append("%s is still being measured against %s" % [recovery_ecology[0].to_lower(), pressure_persistence[0].to_lower()])
	if interrupted:
		result.append("the unresolved ending still changes the read")
	if protocol_state_hint == "Exposure Protocol":
		result.append("low-density pressure is sharpening what almost happened")
	if not resource_pressure.is_empty():
		result.append("%s kept setting the cost of the answer" % resource_pressure[0].to_lower())
	if not group_fault_lines.is_empty():
		result.append("%s kept threatening the answer line" % group_fault_lines[0].to_lower())
	if not model_pressure.is_empty() and risk_profile in ["volatile", "performative", "exposed"]:
		result.append("%s almost became the whole public answer" % model_pressure[0].to_lower())
	return _saturation_adjusted_strings(result, 4)

static func _consensus_risk(
	spectacle_pressure: int,
	recovery_score: int,
	social_temperature: String,
	expectation_breaks: Array[String],
	protocol_state_hint: String,
	branch_summary: Dictionary,
	group_fault_lines: Array[String],
	model_pressure: Array[String]
) -> String:
	var branch_name := str(branch_summary.get("branch_family_name", "")).strip_edges()
	if spectacle_pressure >= 4 and not expectation_breaks.is_empty():
		return "the hottest public read may be flattening the pressure"
	if social_temperature.find("rival") != -1 and recovery_score >= 2:
		return "the public read may be oversimplifying a mixed pair story"
	if protocol_state_hint == "Exposure Protocol" and not branch_name.is_empty():
		return "%s may be making the run look cleaner than it was" % branch_name
	if recovery_score >= 3 and expectation_breaks.size() >= 1:
		return "the cleanest rescue reading may not be the whole story"
	if not group_fault_lines.is_empty():
		return "the public read may be flattening %s" % group_fault_lines[0].to_lower()
	if not model_pressure.is_empty() and spectacle_pressure >= 3:
		return "the public read may be treating %s as cleaner than it was" % model_pressure[0].to_lower()
	return ""

static func _hidden_curriculum(
	recovery_ecology: Array[String],
	burden_score: int,
	expectation_tension: String,
	ritual_recurrence: Array[String],
	spectacle_pressure: int,
	expectation_breaks: Array[String],
	protocol_hooks: Array[String],
	gameplay_feature_signals: Array[String],
	model_pressure: Array[String]
) -> Array[String]:
	var result: Array[String] = []
	if not recovery_ecology.is_empty():
		result.append("rescue discipline")
	if burden_score >= 2:
		result.append("burden respect")
	if expectation_tension == "loaded":
		result.append("threshold caution")
	if not ritual_recurrence.is_empty():
		result.append("ritual acceptance")
	if spectacle_pressure >= 3 and not expectation_breaks.is_empty():
		result.append("resist spectacle bait")
	if not protocol_hooks.is_empty():
		result.append(protocol_hooks[0])
	if gameplay_feature_signals.has("burden answer") and not result.has("burden respect"):
		result.append("burden respect")
	if gameplay_feature_signals.has("resource caution"):
		result.append("cost discipline")
	if not model_pressure.is_empty():
		result.append(model_pressure[0])
	return _saturation_adjusted_strings(result, 4)

static func _anomaly_sensitivity(
	motion_facts: Dictionary,
	attention_patterns: Array[String],
	pressure_persistence: Array[String],
	expectation_breaks: Array[String],
	interrupted: bool
) -> Dictionary:
	var signals: Array[String] = []
	var strong_rooms := _motion_dict(motion_facts, "strong_rooms")
	var score := 0
	if int(strong_rooms.get("returns", 0)) >= 2:
		signals.append("repeated returns")
		score += 1
	if int(strong_rooms.get("threshold_hesitation", 0)) >= 2:
		signals.append("threshold repetition")
		score += 1
	if attention_patterns.has("repeated attention"):
		signals.append("fixed attention")
		score += 1
	if not pressure_persistence.is_empty():
		signals.append("persistent pressure")
		score += 1
	if not expectation_breaks.is_empty():
		signals.append("anti-consensus turn")
		score += 1
	if interrupted:
		signals.append("unfinished pattern")
		score += 1
	return {
		"score": clampi(score, 0, 6),
		"signals": _saturation_adjusted_strings(signals, 4)
	}

static func _run_shapes(recovery_score: int, confrontation_score: int, burden_score: int, atmosphere: String, expectation_breaks: Array[String], spectacle_windows: Array[String] = [], momentum_profile: String = "") -> Array[String]:
	var shapes: Array[String] = []
	if recovery_score >= 3:
		shapes.append("rescue chain run")
	if confrontation_score >= 3:
		shapes.append("artifact conflict run")
	if burden_score >= 3:
		shapes.append("burden pressure run")
	if not expectation_breaks.is_empty():
		shapes.append("pattern break run")
	if atmosphere == "desperate":
		shapes.append("survival scramble")
	if spectacle_windows.size() >= 2:
		shapes.append("spectacle-heavy run")
	if momentum_profile == "coming_together":
		shapes.append("hold-together run")
	if shapes.is_empty():
		shapes.append("steady pressure run")
	return _take_unique(shapes, 4)

static func _item_story_roles(run_record: Dictionary, symbolic_gestures: Array[String], confrontation_score: int, recovery_score: int, burden_score: int, branch_summary: Dictionary = {}, motion_facts: Dictionary = {}, build_identity: String = "", synergy_labels: Array[String] = [], gameplay_behavior_signals: Array[String] = []) -> Array[String]:
	var roles: Array[String] = []
	for item_id_variant in Array(run_record.get("item_defs", [])):
		var item_id := str(item_id_variant)
		if item_id.find("zipline") != -1:
			roles.append("escape catalyst")
		elif item_id.find("decoy") != -1:
			roles.append("obstruction engine")
		elif item_id.find("timeline") != -1:
			roles.append("public mark")
		elif item_id.find("lantern") != -1:
			roles.append("cursed invitation")
		elif item_id.find("boots") != -1:
			roles.append("catastrophe amplifier")
	if burden_score >= 2 and not roles.has("burden stabilizer"):
		roles.append("burden stabilizer")
	if recovery_score >= 2 and not roles.has("rescue enabler"):
		roles.append("rescue enabler")
	if confrontation_score >= 2 and not roles.has("escalation trigger"):
		roles.append("escalation trigger")
	if symbolic_gestures.has("burden handoff") and not roles.has("social object"):
		roles.append("social object")
	if str(branch_summary.get("rescue_climate", "")) == "communal" and not roles.has("recovery object"):
		roles.append("recovery object")
	if int(_motion_dict(motion_facts, "strong_rooms").get("returns", 0)) >= 2 and not roles.has("ritual object"):
		roles.append("ritual object")
	if not build_identity.is_empty() and not roles.has(build_identity.to_lower()):
		roles.append(build_identity.to_lower())
	for label in synergy_labels:
		if label.find("ritual") != -1 and not roles.has("ritual object"):
			roles.append("ritual object")
		elif label.find("route") != -1 and not roles.has("route answer"):
			roles.append("route answer")
	if gameplay_behavior_signals.has("rescue geometry") and not roles.has("rescue geometry"):
		roles.append("rescue geometry")
	return _saturation_adjusted_strings(roles, 5)

static func _item_ecology_signals(run_record: Dictionary, branch_summary: Dictionary, build_identity: String, synergy_labels: Array[String], gameplay_behavior_signals: Array[String]) -> Dictionary:
	var lineage_hints: Array[String] = []
	var branch_markers: Array[String] = []
	var memory_hints: Array[String] = []
	var prestige_indicators: Array[String] = []
	var continuity_state := str(Dictionary(run_record.get("outcome_summary", {})).get("artifact_continuity_state", "")).strip_edges()
	var continuity_text := str(Dictionary(run_record.get("outcome_summary", {})).get("artifact_continuity_text", "")).strip_edges()
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var branch_id := str(branch_summary.get("branch_family_id", "")).replace("_", " ").to_lower()
	var branch_name := str(branch_summary.get("branch_family_name", "")).strip_edges()
	for item_id_variant in Array(run_record.get("item_defs", [])):
		var narrative: Dictionary = item_service.build_narrative_profile(str(item_id_variant))
		lineage_hints = _take_unique(lineage_hints + _string_array(narrative.get("lineage_hints", [])), 4)
		branch_markers = _take_unique(branch_markers + _string_array(narrative.get("branch_markers", [])), 4)
		memory_hints = _take_unique(memory_hints + _string_array(narrative.get("memory_hints", [])), 4)
		prestige_indicators = _take_unique(prestige_indicators + _string_array(narrative.get("prestige_indicators", [])), 4)
		var branch_affinity := _string_array(narrative.get("branch_affinity", []))
		if not branch_id.is_empty() and branch_affinity.has(branch_id) and not branch_name.is_empty():
			branch_markers = _take_unique(branch_markers + ["%s is still claiming the carry" % branch_name], 4)
	if build_identity == "Rescue build" and not prestige_indicators.has("rescue prestige"):
		prestige_indicators = _take_unique(prestige_indicators + ["rescue prestige"], 4)
	if gameplay_behavior_signals.has("rescue geometry") and not memory_hints.has("rescue geometry memory"):
		memory_hints = _take_unique(memory_hints + ["rescue geometry memory"], 4)
	if gameplay_behavior_signals.has("panic lure") and not memory_hints.has("scandal bait memory"):
		memory_hints = _take_unique(memory_hints + ["scandal bait memory"], 4)
	for label in synergy_labels:
		if label.find("ritual") != -1 and not lineage_hints.has("ritual carry lineage"):
			lineage_hints = _take_unique(lineage_hints + ["ritual carry lineage"], 4)
		if label.find("route") != -1 and not prestige_indicators.has("route prestige"):
			prestige_indicators = _take_unique(prestige_indicators + ["route prestige"], 4)
	match continuity_state:
		"recoverable_loss":
			lineage_hints = _take_unique(lineage_hints + ["unfinished custody line"], 4)
			memory_hints = _take_unique(memory_hints + ["recoverable artifact loss"], 4)
			prestige_indicators = _take_unique(prestige_indicators + ["custody debt"], 4)
		"burial":
			lineage_hints = _take_unique(lineage_hints + ["artifact burial line"], 4)
			memory_hints = _take_unique(memory_hints + ["burial memory"], 4)
		"fragmented_legacy":
			lineage_hints = _take_unique(lineage_hints + ["fragmented artifact legacy"], 4)
			memory_hints = _take_unique(memory_hints + ["split lineage memory"], 4)
		"successor_emergence":
			lineage_hints = _take_unique(lineage_hints + ["successor artifact line"], 4)
			prestige_indicators = _take_unique(prestige_indicators + ["false succession pressure"], 4)
		"archive_only_residue":
			memory_hints = _take_unique(memory_hints + ["archive-only artifact residue"], 4)
		"extinction":
			memory_hints = _take_unique(memory_hints + ["artifact extinction memory"], 4)
			prestige_indicators = _take_unique(prestige_indicators + ["extinction taboo"], 4)
	return {
		"lineage_hints": lineage_hints,
		"branch_markers": branch_markers,
		"memory_hints": memory_hints,
		"prestige_indicators": prestige_indicators,
		"continuity_state": continuity_state,
		"continuity_text": continuity_text
	}

static func _branch_caution_markers(branch_summary: Dictionary, protocol_state_hint: String, resource_pressure: Array[String], inhabitant_pressure: Array[String], surface_lines: Array[String]) -> Array[String]:
	var result: Array[String] = []
	var escape_bandwidth := str(branch_summary.get("escape_bandwidth", "")).strip_edges()
	var witness_pressure := str(branch_summary.get("witness_pressure", "")).strip_edges()
	var rescue_climate := str(branch_summary.get("rescue_climate", "")).strip_edges()
	var confrontation_climate := str(branch_summary.get("confrontation_climate", "")).strip_edges()
	if escape_bandwidth in ["tight", "narrow", "uncertain"]:
		result.append("exit lines close early")
	if witness_pressure in ["high", "public", "focused"]:
		result.append("public eyes arrive early")
	if rescue_climate in ["visible_recovery", "covering_retreat", "burden_defense"]:
		result.append("rescue routes stay visible")
	if confrontation_climate.find("public") != -1 or confrontation_climate.find("cutoff") != -1 or confrontation_climate.find("loaded") != -1:
		result.append("conflict turns public fast")
	if protocol_state_hint == "Exposure Protocol":
		result.append("low-density rooms keep the caution readable")
	if not resource_pressure.is_empty():
		result.append(resource_pressure[0])
	if not inhabitant_pressure.is_empty():
		result.append(inhabitant_pressure[0])
	for line in surface_lines:
		var lowered := line.to_lower()
		if lowered.find("rescue") != -1 and not result.has("rescue routes stay visible"):
			result.append("rescue routes stay visible")
		elif lowered.find("public") != -1 and not result.has("public eyes arrive early"):
			result.append("public eyes arrive early")
	return _saturation_adjusted_strings(result, 4)

static func _ecology_signal_highlights(inhabitant_pressure: Array[String]) -> Array[String]:
	var highlights: Array[String] = []
	var priority_terms: Array[String] = [
		"predator rush",
		"predator marked",
		"protocol watched",
		"protocol sweep",
		"echo pressure",
		"artifact watched",
		"unstable presence",
		"ghost focus",
		"ghost pressure"
	]
	for term in priority_terms:
		for pressure_signal in inhabitant_pressure:
			if pressure_signal.find(term) != -1 and not highlights.has(pressure_signal):
				highlights.append(pressure_signal)
	for pressure_signal in inhabitant_pressure:
		if not highlights.has(pressure_signal):
			highlights.append(pressure_signal)
	return highlights

static func _branch_reputation_drift(branch_summary: Dictionary, recovery_score: int, confrontation_score: int, burden_score: int, expectation_breaks: Array[String], protocol_state_hint: String) -> String:
	var branch_name := str(branch_summary.get("branch_family_name", "")).strip_edges()
	if branch_name.is_empty():
		return ""
	var rescue_climate := str(branch_summary.get("rescue_climate", "")).strip_edges()
	var confrontation_climate := str(branch_summary.get("confrontation_climate", "")).strip_edges()
	var burden_pressure := str(branch_summary.get("burden_pressure", "")).strip_edges()
	var witness_pressure := str(branch_summary.get("witness_pressure", "")).strip_edges()
	if recovery_score >= 2 and (confrontation_climate.find("public") != -1 or confrontation_climate.find("loaded") != -1 or confrontation_climate.find("cutoff") != -1):
		return "%s is no longer reading as pure threat" % branch_name
	if confrontation_score >= 2 and rescue_climate in ["visible_recovery", "covering_retreat", "burden_defense"]:
		return "%s is picking up a harsher public memory" % branch_name
	if burden_score >= 2 and (burden_pressure.find("carry") != -1 or burden_pressure.find("handoff") != -1 or burden_pressure.find("escort") != -1 or burden_pressure.find("value") != -1):
		return "%s is starting to read like a custody branch" % branch_name
	if protocol_state_hint == "Exposure Protocol" and witness_pressure in ["high", "public", "focused"]:
		return "%s is drawing a stricter public reading" % branch_name
	if recovery_score >= 2 and not expectation_breaks.is_empty():
		return "%s is being remembered for who kept the answer moving" % branch_name
	return ""

static func _artifact_cultural_association(lineage_hints: Array[String], branch_markers: Array[String], prestige_indicators: Array[String], archive_tone: String) -> String:
	var tone := archive_tone.to_lower()
	if tone.find("memory") != -1 or tone.find("custody") != -1:
		var lineage := _first(lineage_hints, "")
		if not lineage.is_empty():
			return "%s is being treated like inherited custody" % lineage
	if tone.find("forensic") != -1 or tone.find("dispute") != -1:
		var prestige := _first(prestige_indicators, "")
		if not prestige.is_empty():
			return "%s is reading like a contested artifact record" % prestige
	var branch_marker := _first(branch_markers, "")
	if not branch_marker.is_empty():
		return "%s keeps reading like branch property" % branch_marker
	var prestige_fallback := _first(prestige_indicators, "")
	if not prestige_fallback.is_empty():
		return "%s is carrying cultural weight" % prestige_fallback
	return ""

static func _mutation_surface_lines(mutation_summary: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var triggers: Dictionary = Dictionary(mutation_summary.get("triggers", {}))
	var public_surfaces: Dictionary = Dictionary(mutation_summary.get("public_surfaces", {}))
	if int(triggers.get("species_escalation", 0)) > 0:
		var surface_id := _first(_string_array(public_surfaces.get("species_escalation", [])), "")
		if not surface_id.is_empty():
			var species_id := surface_id.split(":")[0]
			lines.append("%s pressure kept changing shape in public." % _title_case(str(species_id).replace("_", " ")))
		else:
			lines.append("Pressure kept changing shape in public.")
	if int(triggers.get("covenant_activated", 0)) > 0:
		var covenant_id := _first(_string_array(public_surfaces.get("covenant_activated", [])), "")
		if not covenant_id.is_empty():
			lines.append("%s bent custody into the open." % _title_case(covenant_id.replace("_", " ")))
		else:
			lines.append("A public vow bent custody into the open.")
	if int(triggers.get("transformation_threshold_crossed", 0)) > 0:
		var transformation_id := _first(_string_array(public_surfaces.get("transformation_threshold_crossed", [])), "")
		if not transformation_id.is_empty():
			lines.append("%s marked a visible threshold shift." % _title_case(transformation_id.replace("_", " ")))
		else:
			lines.append("A visible threshold shift marked the route.")
	return lines.slice(0, 2)

static func _title_case(value: String) -> String:
	var parts: PackedStringArray = value.split(" ", false)
	var titled: Array[String] = []
	for raw_part in parts:
		var part := raw_part.strip_edges()
		if part.is_empty():
			continue
		titled.append(part.substr(0, 1).to_upper() + part.substr(1).to_lower())
	return " ".join(titled)

static func _social_beats_top(recovery_score: int, confrontation_score: int, burden_score: int, expectation_breaks: Array[String]) -> Array[String]:
	var beats: Array[String] = []
	if recovery_score >= 2:
		beats.append("stayed with the pressure")
	if burden_score >= 2:
		beats.append("protected the burden")
	if confrontation_score >= 2:
		beats.append("pushed the conflict line")
	if not expectation_breaks.is_empty():
		beats.append("broke the expected line")
	if not beats.is_empty():
		return beats
	return ["held position"]

static func _quest_pressure(interrupted: bool, confrontation_score: int, recovery_score: int, burden_score: int, spectacle_pressure: int, expectation_breaks: Array[String], symbolic_gestures: Array[String], room_identity_highlights: Array[String], branch_summary: Dictionary = {}, pressure_persistence: Array[String] = [], motion_facts: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	if recovery_score >= 2:
		result.append("Rescue obligation")
	if burden_score >= 2:
		result.append("Burden challenge")
	if confrontation_score >= 2:
		result.append("Rivalry provocation")
	if spectacle_pressure >= 3:
		result.append("Public dare")
	if symbolic_gestures.has("threshold commitment"):
		result.append("Route commitment")
	if not expectation_breaks.is_empty():
		result.append("Anti-spectacle refusal")
	if interrupted:
		result.append("Interrupted obligation")
	if spectacle_pressure >= 4 and confrontation_score >= 2:
		result.append("Show challenge")
	if int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0)) >= 2:
		result.append("Threshold dare")
	if str(branch_summary.get("challenge_texture", "")) == "high ceremony":
		result.append("Branch challenge")
	if not pressure_persistence.is_empty():
		result.append("Returning pressure")
	for value in room_identity_highlights:
		if result.size() >= 4:
			break
		if not result.has(value):
			result.append(value.capitalize())
	return _saturation_adjusted_strings(result, 4)

static func _spectacle_pressure(events: Array[Dictionary], communication: Dictionary, pair_keys: Array[String], motion_facts: Dictionary, confrontation_score: int) -> int:
	var value := confrontation_score
	value += mini(int(communication.get("total", 0)), 2)
	value += mini(pair_keys.size(), 1)
	value += mini(int(_motion_dict(motion_facts, "strong_rooms").get("collective_hesitations", 0)), 2)
	value += mini(int(_motion_dict(motion_facts, "strong_rooms").get("returns", 0)), 1)
	if _count_type(events, "artifact_stolen") > 0:
		value += 1
	return clampi(value, 0, 6)

static func _expectation_tension(events: Array[Dictionary], communication: Dictionary, motion_facts: Dictionary, spectacle_pressure: int) -> String:
	var threshold_hesitation := int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0))
	var collective_hesitation := int(_motion_dict(motion_facts, "strong_rooms").get("collective_hesitations", 0))
	if spectacle_pressure >= 4 or threshold_hesitation >= 3:
		return "loaded"
	if collective_hesitation >= 2 or int(communication.get("danger", 0)) >= 2 or _count_type(events, "artifact_picked") > 0:
		return "tightening"
	return "steady"

static func _silence_clusters(motion_facts: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var strong_rooms: Dictionary = _motion_dict(motion_facts, "strong_rooms")
	if int(strong_rooms.get("collective_hesitations", 0)) >= 3:
		result.append("silent standoff")
	if int(strong_rooms.get("threshold_hesitation", 0)) >= 2:
		result.append("collective hesitation")
	if int(strong_rooms.get("returns", 0)) >= 2 and int(strong_rooms.get("lingers", 0)) >= 2:
		result.append("tense regrouping")
	return _saturation_adjusted_strings(result, 3)

static func _escalation_arc(events: Array[Dictionary], communication: Dictionary, motion_facts: Dictionary, confrontation_score: int, recovery_score: int, spectacle_pressure: int) -> String:
	var threshold_hesitation := int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0))
	var collective_hesitation := int(_motion_dict(motion_facts, "strong_rooms").get("collective_hesitations", 0))
	if recovery_score >= 2 and confrontation_score >= 2 and spectacle_pressure >= 3:
		return "crisis_to_rescue_under_threat"
	if confrontation_score >= 2 and threshold_hesitation >= 2:
		return "calm_to_suspicion_to_standoff"
	if confrontation_score >= 3 and collective_hesitation >= 2:
		return "cooperation_to_pressure_to_rupture"
	if recovery_score >= 3:
		return "crisis_to_recovery"
	return "steady_to_pressure"

static func _spectacle_windows(events: Array[Dictionary], symbolic_gestures: Array[String], motion_facts: Dictionary, confrontation_score: int, recovery_score: int, burden_score: int, spectacle_pressure: int) -> Array[String]:
	var result: Array[String] = []
	if recovery_score >= 2 and burden_score >= 2:
		result.append("Burden rescue under pressure")
	if confrontation_score >= 2 and spectacle_pressure >= 3:
		result.append("Witnessed confrontation at the pressure line")
	if symbolic_gestures.has("burden handoff") and spectacle_pressure >= 2:
		result.append("Visible burden handoff under heat")
	if symbolic_gestures.has("threshold commitment") and int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0)) >= 2:
		result.append("Threshold commitment after visible hesitation")
	return _saturation_adjusted_strings(result, 3)

static func _pressure_persistence(escalation_arc: String, attention_patterns: Array[String], symbolic_gestures: Array[String], spectacle_windows: Array[String]) -> Array[String]:
	var result: Array[String] = []
	if escalation_arc in ["calm_to_suspicion_to_standoff", "cooperation_to_pressure_to_rupture"]:
		result.append("rising confrontation pressure")
	if attention_patterns.has("repeated returns"):
		result.append("returning route pressure")
	if symbolic_gestures.has("burden handoff"):
		result.append("shared burden pressure")
	if not spectacle_windows.is_empty():
		result.append("witness heat")
	return _saturation_adjusted_strings(result, 4)

static func _purpose_vector(recovery_score: int, confrontation_score: int, burden_score: int, expectation_breaks: Array[String], branch_summary: Dictionary, spectacle_pressure: int) -> Array[String]:
	var result: Array[String] = []
	if recovery_score >= 2:
		result.append("hold together")
	if burden_score >= 2:
		result.append("carry through")
	if confrontation_score >= 2:
		result.append("survive conflict")
	if spectacle_pressure >= 3:
		result.append("withstand attention")
	if not expectation_breaks.is_empty():
		result.append("break the expected line")
	if str(branch_summary.get("challenge_texture", "")) == "high ceremony":
		result.append("meet the branch challenge")
	return _saturation_adjusted_strings(result, 4)

static func _micro_signal_clusters(symbolic_gestures: Array[String], attention_patterns: Array[String], motion_facts: Dictionary, expectation_tension: String, spectacle_pressure: int) -> Array[String]:
	var result: Array[String] = []
	if symbolic_gestures.has("burden handoff") and attention_patterns.has("loaded lingering"):
		result.append("handoff under watch")
	if expectation_tension == "loaded" and int(_motion_dict(motion_facts, "strong_rooms").get("threshold_hesitation", 0)) >= 2:
		result.append("hesitation under pressure")
	if spectacle_pressure >= 3 and attention_patterns.has("repeated following"):
		result.append("followed commitment")
	return _saturation_adjusted_strings(result, 3)

static func _revisit_score(spectacle_windows: Array[String], pressure_persistence: Array[String], branch_summary: Dictionary) -> int:
	var value := spectacle_windows.size() + pressure_persistence.size()
	if str(branch_summary.get("challenge_texture", "")) == "high ceremony":
		value += 1
	return clampi(value, 0, 8)

static func _pair_label(pair_key: String) -> String:
	var bits := pair_key.split(":")
	if bits.size() == 2:
		return "%s / %s" % [bits[0], bits[1]]
	return pair_key
