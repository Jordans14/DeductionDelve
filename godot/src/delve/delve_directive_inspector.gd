class_name DelveDirectiveInspector
extends RefCounted

static func should_trace() -> bool:
	return OS.is_debug_build() or DisplayServer.get_name() == "headless"

static func build_snapshot(directive: Dictionary) -> Dictionary:
	var snapshot := _extract_snapshot(directive)
	snapshot["trace_lines"] = _build_lines_from_snapshot(snapshot)
	return snapshot

static func build_lines(directive: Dictionary) -> Array[String]:
	return _build_lines_from_snapshot(_extract_snapshot(directive))

static func _extract_snapshot(directive: Dictionary) -> Dictionary:
	var audit: Dictionary = Dictionary(directive.get("causal_audit", {}))
	var surface_summary: Dictionary = Dictionary(directive.get("surface_summary", {}))
	var public_summary: Dictionary = Dictionary(directive.get("public_summary", {}))
	var mind_balance: Dictionary = Dictionary(audit.get("mind_balance", {}))
	var run_identity: Dictionary = Dictionary(directive.get("run_identity", audit.get("run_identity", {})))
	return {
		"seed": int(directive.get("seed", audit.get("seed", 0))),
		"protocol_state": str(directive.get("protocol_state", public_summary.get("protocol_state", audit.get("protocol_state", "")))),
		"doctrine_family": str(directive.get("doctrine_family", audit.get("doctrine", ""))),
		"doctrine_label": str(directive.get("doctrine_label", public_summary.get("doctrine", audit.get("doctrine_label", "")))),
		"pressure_line": str(public_summary.get("pressure_line", "")),
		"world_goal": str(public_summary.get("world_goal", "")),
		"control_surfaces": Dictionary(directive.get("control_surfaces", {})).duplicate(true),
		"surface_summary": surface_summary.duplicate(true),
		"mind_influence": Dictionary(mind_balance.get("influence", {})).duplicate(true),
		"mind_notes": Array(mind_balance.get("notes", [])).duplicate(true),
		"simulation": Dictionary(audit.get("simulation", {})).duplicate(true),
		"constitution_violations": Array(audit.get("violations", [])).duplicate(),
		"world_goals": Array(directive.get("world_goals", [])).duplicate(true),
		"run_identity": run_identity.duplicate(true),
		"pacing_profile": str(Dictionary(run_identity.get("pacing_profile", {})).get("label", "")),
		"pressure_grammar": _entry_labels(Array(run_identity.get("pressure_grammar", []))),
		"symbolic_motifs": _entry_labels(Array(run_identity.get("symbolic_motifs", []))),
		"dominant_minds": _state_labels(Array(run_identity.get("active_minds", [])), 2)
	}

static func _build_lines_from_snapshot(snapshot: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	lines.append("Doctrine: %s" % str(snapshot.get("doctrine_label", "Measured Pressure")))
	lines.append("Protocol: %s" % str(snapshot.get("protocol_state", "")))
	var pressure_line := str(snapshot.get("pressure_line", "")).strip_edges()
	if not pressure_line.is_empty():
		lines.append("Pressure: %s" % pressure_line)
	var world_goal := str(snapshot.get("world_goal", "")).strip_edges()
	if not world_goal.is_empty():
		lines.append("Goal: %s" % world_goal)
	var pacing_profile := str(snapshot.get("pacing_profile", "")).strip_edges()
	if not pacing_profile.is_empty():
		lines.append("Pacing: %s" % pacing_profile)
	var pressure_grammar := _string_array(snapshot.get("pressure_grammar", []))
	if not pressure_grammar.is_empty():
		lines.append("Verbs: %s" % ", ".join(pressure_grammar.slice(0, 2)))
	var dominant_minds := _string_array(snapshot.get("dominant_minds", []))
	if not dominant_minds.is_empty():
		lines.append("Authors: %s" % ", ".join(dominant_minds))
	var strongest: Array = Array(Dictionary(snapshot.get("surface_summary", {})).get("strongest", []))
	if not strongest.is_empty():
		var strongest_entry: Dictionary = Dictionary(strongest[0])
		lines.append("Surface: %s (%+d)" % [str(strongest_entry.get("label", "Pressure")), int(strongest_entry.get("value", 0))])
	var influence: Dictionary = Dictionary(snapshot.get("mind_influence", {}))
	if not influence.is_empty():
		var lead_name := ""
		var lead_weight := -999999
		for key in influence.keys():
			var weight := int(influence.get(key, 0))
			if weight > lead_weight or (weight == lead_weight and str(key) < lead_name):
				lead_name = str(key)
				lead_weight = weight
		if not lead_name.is_empty():
			lines.append("Lead mind: %s (%d)" % [lead_name, lead_weight])
	var simulation: Dictionary = Dictionary(snapshot.get("simulation", {}))
	if not simulation.is_empty():
		lines.append("Scores: clarity=%d rescue=%d ambiguity=%d myth=%d" % [
			int(simulation.get("deduction_clarity", 0)),
			int(simulation.get("rescue_viability", 0)),
			int(simulation.get("ambiguity_quality", 0)),
			int(simulation.get("myth_weight", 0))
		])
	var violations := _string_array(snapshot.get("constitution_violations", []))
	if not violations.is_empty():
		lines.append("Violations: %s" % ", ".join(violations))
	return lines

static func write_trace(directive: Dictionary) -> String:
	if directive.is_empty():
		return ""
	DirAccess.make_dir_recursive_absolute("user://reports")
	var snapshot: Dictionary = build_snapshot(directive)
	var seed_value := int(snapshot.get("seed", 0))
	var path := "user://reports/delve_directive_trace_%d.json" % seed_value
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(JSON.stringify(snapshot, "\t"))
	return path

static func emit_debug_trace(directive: Dictionary) -> void:
	if directive.is_empty() or not should_trace():
		return
	for line in build_lines(directive):
		print("DELVE_DIRECTIVE ", line)

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _entry_labels(entries: Array) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if not label.is_empty() and not result.has(label):
			result.append(label)
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
