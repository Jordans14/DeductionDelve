class_name ProfileProgression
extends RefCounted

static func build_narrative_progress_lines(progress: Dictionary, archive_state: Dictionary, world_memory: Dictionary) -> Array[String]:
	var layer := str(progress.get("layer", "public"))
	var flags := _string_array(progress.get("post_core_flags", []))
	var lines: Array[String] = []
	var field: Dictionary = Dictionary(world_memory.get("myth_field", {}))
	var gravity: Dictionary = Dictionary(world_memory.get("cultural_gravity", {}))
	var top_successor := Dictionary(field.get("top_successor", {}))
	var layer_line := ""
	match layer:
		"patterned":
			layer_line = "Archive depth: pressure patterns are beginning to line up."
		"deepening":
			layer_line = "Archive depth: later echoes are getting stranger."
		"post_core":
			layer_line = "Archive depth: old patterns are starting to answer each other."
		_:
			layer_line = "Archive depth: public records only."
	if flags.has("echo_strain"):
		lines.append("Recent runs are carrying stronger echo strain.")
	elif flags.has("ritual_return"):
		lines.append("Some pressures are starting to feel ritualized.")
	if flags.has("attention_lock"):
		lines.append("The same challenge keeps drawing the world back.")
	if flags.has("counterweight"):
		lines.append("Older readings are starting to compete with the obvious story.")
	if flags.has("deep_archive"):
		lines.append("Archive echoes are starting to talk to each other.")
	if flags.has("gravity_lock"):
		lines.append("One pressure has started pulling the whole field toward it.")
	if flags.has("recast_pressure"):
		lines.append("Recent reversals are forcing older legends to answer for themselves.")
	if flags.has("pattern_revision"):
		lines.append("A familiar reading is starting to bend away from itself.")
	if flags.has("field_resonance"):
		lines.append("Separate echoes are beginning to answer each other directly.")
	if flags.has("ritual_pressure"):
		lines.append("Some challenges now feel more like obligations than invitations.")
	if flags.has("successor_pressure"):
		lines.append("A newer reading is starting to displace an older legend.")
	if flags.has("fatigue_turn"):
		lines.append("The world is tiring of repetition and waiting for a different answer.")
	if flags.has("school_split"):
		lines.append("Competing readings are starting to matter as much as the events themselves.")
	if not str(top_successor.get("hint", "")).strip_edges().is_empty() and layer != "public":
		lines.append("Field recast: older pressure keeps bending toward %s." % str(top_successor.get("hint", "")).to_lower())
	if int(gravity.get("top_gravity", 0)) >= 8 and not str(gravity.get("top_label", "")).strip_edges().is_empty():
		lines.append("Field gravity: %s is pulling newer stories into orbit." % str(gravity.get("top_label", "")))
	if Array(archive_state.get("legends", [])).size() >= 4:
		lines.append("Legend pressure: enough dense cases now point to the same returning shapes.")
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	if str(fascination.get("phase", "")).strip_edges() == "turning":
		lines.append("World attention: the current pressure is displacing an older obsession.")
	if str(fascination.get("phase", "")).strip_edges() == "fatigued":
		lines.append("World attention: the current fixation is starting to wear thin.")
	if flags.has("attention_model"):
		lines.append("Archive depth: the same pressures now feel like they are being anticipated in advance.")
	if flags.has("curriculum_drift"):
		lines.append("Archive depth: repeated challenges are starting to read like lessons with motives.")
	if not layer_line.is_empty():
		lines.append(layer_line)
	return lines

static func advance_narrative_progress(progress: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary, crawl_packet: Dictionary, world_memory: Dictionary, archive_state: Dictionary) -> Dictionary:
	var next := {
		"layer": "public",
		"core_reached": false,
		"post_core_flags": []
	}
	for key in progress.keys():
		next[key] = progress[key]
	var layer := str(next.get("layer", "public"))
	var flags := _string_array(next.get("post_core_flags", []))
	var legends := Array(archive_state.get("legends", []))
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	var field: Dictionary = Dictionary(world_memory.get("myth_field", {}))
	var gravity: Dictionary = Dictionary(world_memory.get("cultural_gravity", {}))
	var collisions: Dictionary = Dictionary(world_memory.get("myth_collision", {}))
	var resurgence: Dictionary = Dictionary(world_memory.get("myth_resurgence", {}))
	var heat := int(fascination.get("current_heat", 0))
	var branch_revision := not str(Dictionary(field.get("top_successor", {})).get("label", "")).strip_edges().is_empty()
	var recast_hint := not str(Dictionary(field.get("top_successor", {})).get("hint", "")).strip_edges().is_empty()
	var resonance_count := int(field.get("resonance_count", 0))
	var gravity_level := int(gravity.get("top_gravity", 0))
	var anomaly_score := int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0))
	var shorthand_count := Dictionary(archive_state.get("shorthand", {})).size()
	var echo_count := Array(diagnostics.get("within_run_echoes", [])).size()
	if layer == "public" and (
		Array(crawl_packet.get("turning_points", [])).size() >= 2
		or legends.size() >= 2
		or heat >= 6
		or shorthand_count >= 1
		or (echo_count >= 1 and not str(frame.get("belief_line", "")).strip_edges().is_empty())
		or not str(frame.get("school_tension", "")).strip_edges().is_empty()
	):
		layer = "patterned"
	if layer == "patterned" and (Array(crawl_packet.get("breaking_points", [])).size() >= 2 or legends.size() >= 3 or heat >= 7 or resonance_count >= 2 or recast_hint):
		layer = "deepening"
	if layer == "deepening" and (bool(next.get("core_reached", false)) or legends.size() >= 4 or Array(crawl_packet.get("breaking_points", [])).size() >= 3 or gravity_level >= 8 or (recast_hint and int(fascination.get("streak", 0)) >= 3)):
		layer = "post_core"
		next["core_reached"] = true
	if str(frame.get("delve_trace", "")).strip_edges() != "" and not flags.has("echo_strain"):
		flags.append("echo_strain")
	if Array(diagnostics.get("within_run_echoes", [])).size() >= 2 and not flags.has("ritual_return"):
		flags.append("ritual_return")
	if int(diagnostics.get("expectation_break_score", 0)) >= 2 and not flags.has("pattern_slip"):
		flags.append("pattern_slip")
	if int(fascination.get("streak", 0)) >= 3 and not flags.has("attention_lock"):
		flags.append("attention_lock")
	if Array(frame.get("counter_readings", [])).size() >= 2 and not flags.has("counterweight"):
		flags.append("counterweight")
	if Dictionary(archive_state.get("shorthand", {})).size() >= 2 and not flags.has("deep_archive"):
		flags.append("deep_archive")
	if int(fascination.get("streak", 0)) >= 4 and not flags.has("gravity_lock"):
		flags.append("gravity_lock")
	if str(fascination.get("phase", "")).strip_edges() == "turning" and not flags.has("recast_pressure"):
		flags.append("recast_pressure")
	if branch_revision and not flags.has("pattern_revision"):
		flags.append("pattern_revision")
	if recast_hint and not flags.has("recast_pressure"):
		flags.append("recast_pressure")
	if resonance_count >= 2 and not flags.has("field_resonance"):
		flags.append("field_resonance")
	if not str(frame.get("ritual_pressure", "")).strip_edges().is_empty() and not flags.has("ritual_pressure"):
		flags.append("ritual_pressure")
	if branch_revision and not flags.has("successor_pressure"):
		flags.append("successor_pressure")
	if int(fascination.get("fatigue", 0)) >= 2 and not flags.has("fatigue_turn"):
		flags.append("fatigue_turn")
	if Array(frame.get("school_reads", [])).size() >= 2 and not str(frame.get("school_tension", "")).strip_edges().is_empty() and not flags.has("school_split"):
		flags.append("school_split")
	if not str(frame.get("belief_line", "")).strip_edges().is_empty() and int(fascination.get("streak", 0)) >= 2 and not flags.has("attention_model"):
		flags.append("attention_model")
	if Array(diagnostics.get("hidden_curriculum", [])).size() >= 2 and not flags.has("curriculum_drift"):
		flags.append("curriculum_drift")
	if not str(frame.get("belief_line", "")).strip_edges().is_empty() and not Array(diagnostics.get("counterfactual_pressure", [])).is_empty() and not flags.has("pattern_revision"):
		flags.append("pattern_revision")
	if Array(frame.get("school_reads", [])).size() >= 2 and not str(frame.get("school_tension", "")).strip_edges().is_empty() and Array(frame.get("counter_readings", [])).size() >= 1 and not flags.has("school_split"):
		flags.append("school_split")
	if _string_array(collisions.get("lines", [])).size() >= 2 and not flags.has("field_resonance"):
		flags.append("field_resonance")
	if _string_array(resurgence.get("lines", [])).size() >= 1 and not flags.has("successor_pressure"):
		flags.append("successor_pressure")
	if anomaly_score >= 4 and not flags.has("echo_strain"):
		flags.append("echo_strain")
	if (flags.has("attention_model") or flags.has("curriculum_drift")) and layer != "public" and not flags.has("pattern_revision"):
		flags.append("pattern_revision")
	if Array(field.get("active_lines", [])).size() >= 1 and legends.size() >= 2 and not flags.has("field_resonance"):
		flags.append("field_resonance")
	if Array(frame.get("school_reads", [])).size() >= 2 and not str(frame.get("school_tension", "")).strip_edges().is_empty() and not flags.has("school_split"):
		flags.append("school_split")
	next["layer"] = layer
	next["post_core_flags"] = flags.slice(0, 14)
	return next

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
