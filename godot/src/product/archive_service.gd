class_name ArchiveService
extends RefCounted

const CRAWL_SERVICE_SCRIPT = preload("res://src/product/crawl_service.gd")
const WORLD_MEMORY_SERVICE_SCRIPT = preload("res://src/product/world_memory_service.gd")
const FRAMING_SERVICE_SCRIPT = preload("res://src/product/framing_service.gd")

const CASE_LIMIT := 36
const LEGEND_LIMIT := 18
const DYNAMIC_SECTIONS: Array[String] = [
	"archive_cases",
	"crawl_echoes",
	"relationship_echoes",
	"world_fascination"
]

static func default_state() -> Dictionary:
	return {
		"cases": [],
		"legends": [],
		"shorthand": {},
		"entries": []
	}

static func normalize(state: Dictionary) -> Dictionary:
	var current := default_state()
	for key in state.keys():
		current[key] = state[key]
	current["cases"] = Array(current.get("cases", [])).slice(0, CASE_LIMIT)
	current["legends"] = Array(current.get("legends", [])).slice(0, LEGEND_LIMIT)
	current["shorthand"] = Dictionary(current.get("shorthand", {}))
	current["entries"] = _normalize_entries(Array(current.get("entries", [])))
	return current

static func apply_run(archive_state: Dictionary, run_context: Dictionary) -> Dictionary:
	var current := normalize(archive_state)
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var crawl_packet: Dictionary = Dictionary(run_context.get("crawl_packet", {}))
	var world_memory: Dictionary = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(run_context.get("world_memory", {})))
	var case_entry := _build_case_entry(run_context)
	var cases: Array = Array(current.get("cases", []))
	cases.push_front(case_entry)
	current["cases"] = cases.slice(0, CASE_LIMIT)
	var entries: Array = Array(current.get("entries", []))
	entries.push_front(_build_archive_entry(case_entry, run_context))
	current["entries"] = _normalize_entries(entries)
	if _passes_legend_threshold(diagnostics, frame, world_memory):
		var legends: Array = Array(current.get("legends", []))
		legends.push_front(_build_legend_entry(case_entry, crawl_packet))
		current["legends"] = legends.slice(0, LEGEND_LIMIT)
		var shorthand: Dictionary = Dictionary(current.get("shorthand", {}))
		shorthand[str(case_entry.get("id", ""))] = str(case_entry.get("short_label", ""))
		current["shorthand"] = shorthand
	return current

static func dynamic_sections() -> Array[String]:
	return DYNAMIC_SECTIONS.duplicate()

static func build_dynamic_entries(profile: Dictionary, section: String) -> Array[Dictionary]:
	var archive_state := normalize(Dictionary(profile.get("archive_state", {})))
	match section:
		"archive_cases":
			return FRAMING_SERVICE_SCRIPT.guard_entries(_build_case_entries(archive_state))
		"crawl_echoes":
			return FRAMING_SERVICE_SCRIPT.guard_entries(CRAWL_SERVICE_SCRIPT.build_crawl_entries(profile))
		"relationship_echoes":
			return FRAMING_SERVICE_SCRIPT.guard_entries(CRAWL_SERVICE_SCRIPT.build_relationship_entries(profile))
		"world_fascination":
			return FRAMING_SERVICE_SCRIPT.guard_entries(_build_world_entries(Dictionary(profile.get("world_memory", {}))))
		_:
			return []

static func build_archive_lines(profile: Dictionary) -> Array[String]:
	var archive_state := normalize(Dictionary(profile.get("archive_state", {})))
	var world_memory: Dictionary = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(profile.get("world_memory", {})))
	var lines: Array[String] = []
	var cases: Array = Array(archive_state.get("cases", []))
	if cases.is_empty():
		return ["Archive: no strong cases recorded yet."]
	lines.append("Archive: %d cases | %d legends" % [cases.size(), Array(archive_state.get("legends", [])).size()])
	lines.append("Latest: %s" % str(Dictionary(cases[0]).get("label", "Recent echo")))
	var latest_echoes := _string_array(Dictionary(cases[0]).get("echoes", []))
	if not latest_echoes.is_empty():
		lines.append("Echo: %s" % latest_echoes[0])
	var myth_line := str(Dictionary(cases[0]).get("myth_line", "")).strip_edges()
	if not myth_line.is_empty():
		lines.append("Field: %s" % myth_line)
	var school_line := str(Dictionary(cases[0]).get("school_line", "")).strip_edges()
	if not school_line.is_empty():
		lines.append("Reading: %s" % school_line)
	var comparison_line := str(Dictionary(cases[0]).get("comparison_line", "")).strip_edges()
	if not comparison_line.is_empty():
		lines.append("Compare: %s" % comparison_line)
	var continuity_line := str(Dictionary(cases[0]).get("continuity_line", "")).strip_edges()
	if not continuity_line.is_empty():
		lines.append("Continuity: %s" % continuity_line)
	var world_relation := str(Dictionary(cases[0]).get("world_relation_line", "")).strip_edges()
	if not world_relation.is_empty():
		lines.append("Field pull: %s" % world_relation)
	var artifact_signal := str(Dictionary(cases[0]).get("artifact_signal_line", "")).strip_edges()
	if not artifact_signal.is_empty():
		lines.append("Artifact echo: %s" % artifact_signal)
	var branch_signal := str(Dictionary(cases[0]).get("branch_signal_line", "")).strip_edges()
	if not branch_signal.is_empty():
		lines.append("Branch drift: %s" % branch_signal)
	var retell_line := str(Dictionary(cases[0]).get("retell_line", "")).strip_edges()
	if not retell_line.is_empty():
		lines.append("Retell as: %s" % retell_line)
	var focus_topics := WORLD_MEMORY_SERVICE_SCRIPT.top_fascination_topics(world_memory, 1)
	if not focus_topics.is_empty():
		lines.append("Watch next: %s" % str(Dictionary(focus_topics[0]).get("label", "")))
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func _build_case_entry(run_context: Dictionary) -> Dictionary:
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var branch_summary: Dictionary = Dictionary(diagnostics.get("branch_summary", {}))
	var archive_state: Dictionary = normalize(Dictionary(run_context.get("archive_state", {})))
	var profile: Dictionary = Dictionary(run_context.get("profile", {}))
	var artifact_signal_line := _artifact_signal_line(diagnostics)
	var branch_signal_line := _branch_signal_line(diagnostics)
	var run_key := "%d|%s|%s" % [
		int(run_record.get("seed", 0)),
		str(run_record.get("local_role", "")),
		str(frame.get("archive_title", "archive"))
	]
	var detail_lines: Array[String] = []
	detail_lines.append(str(frame.get("archive_title", "Recent run echo")))
	detail_lines.append("Atmosphere: %s | Momentum: %s" % [
		str(diagnostics.get("atmosphere", "steady")).replace("_", " ").capitalize(),
		str(diagnostics.get("momentum_profile", "steadying")).replace("_", " ")
	])
	var pattern_line := _pattern_line(diagnostics, frame)
	if not pattern_line.is_empty():
		detail_lines.append("Pattern: %s" % pattern_line)
	var room_highlights := _string_array(diagnostics.get("room_identity_highlights", []))
	if not room_highlights.is_empty():
		detail_lines.append("Room echo: %s" % room_highlights[0])
	if not branch_summary.is_empty():
		detail_lines.append("Branch echo: %s" % str(branch_summary.get("branch_family_name", "Unknown branch")))
	if not artifact_signal_line.is_empty():
		detail_lines.append("Artifact echo: %s" % artifact_signal_line)
	if not branch_signal_line.is_empty():
		detail_lines.append("Branch drift: %s" % branch_signal_line)
	var changing := _string_array(diagnostics.get("run_changing_moments", []))
	if not changing.is_empty():
		detail_lines.append("Turn: %s" % changing[0])
	var windows := _string_array(diagnostics.get("spectacle_windows", []))
	if not windows.is_empty():
		detail_lines.append("Window: %s" % windows[0])
	var questions := _string_array(frame.get("open_questions", []))
	if not questions.is_empty():
		detail_lines.append("Question: %s" % questions[0])
	var hooks := _string_array(diagnostics.get("pressure_persistence", []))
	if not hooks.is_empty():
		detail_lines.append("Watch next: %s" % hooks[0])
	var schools := _string_array(frame.get("commentary_lanes", []))
	if not schools.is_empty():
		detail_lines.append("Read by: %s" % ", ".join(schools))
	var challenge_attention := str(frame.get("challenge_attention", "")).strip_edges()
	if not challenge_attention.is_empty():
		detail_lines.append("Challenge: %s" % challenge_attention)
	var ritual_pressure := str(frame.get("ritual_pressure", "")).strip_edges()
	if not ritual_pressure.is_empty():
		detail_lines.append("Ritual pull: %s" % ritual_pressure)
	var protocol_state := str(frame.get("protocol_state", "")).strip_edges()
	if not protocol_state.is_empty():
		detail_lines.append("Protocol: %s" % protocol_state)
	var doctrine_line := str(frame.get("doctrine_line", "")).strip_edges()
	if not doctrine_line.is_empty():
		detail_lines.append("Doctrine: %s" % doctrine_line)
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	if not governance_line.is_empty():
		detail_lines.append("Governance: %s" % governance_line)
	var quiet_play_line := _first_string(_string_array(diagnostics.get("quiet_play_signals", [])), "")
	if not quiet_play_line.is_empty():
		detail_lines.append("Quiet play: %s" % quiet_play_line)
	var meaningful_non_action := str(diagnostics.get("meaningful_non_action", "")).strip_edges()
	if not meaningful_non_action.is_empty():
		detail_lines.append("Still mattered: %s" % meaningful_non_action)
	var institutional_claim := _first_string(_string_array(Dictionary(diagnostics.get("institutional_pressure_surface", {})).get("claim_lines", [])), "")
	if not institutional_claim.is_empty():
		detail_lines.append("Institution: %s" % institutional_claim)
	var reentry_prompt := ""
	for hook_raw in Array(profile.get("reentry_hooks", [])):
		var hook := Dictionary(hook_raw)
		reentry_prompt = str(hook.get("prompt_line", "")).strip_edges()
		if not reentry_prompt.is_empty():
			break
	if not reentry_prompt.is_empty():
		detail_lines.append("Return pull: %s" % reentry_prompt)
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	if not belief_line.is_empty():
		detail_lines.append("Belief: %s" % belief_line)
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	if not counterfactual_line.is_empty():
		detail_lines.append("Counterfactual: %s" % counterfactual_line)
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	if not model_pressure.is_empty():
		detail_lines.append("Answer shape: %s" % model_pressure)
	var group_fault := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	if not group_fault.is_empty():
		detail_lines.append("Fault line: %s" % group_fault)
	var curriculum_line := str(frame.get("curriculum_line", "")).strip_edges()
	if not curriculum_line.is_empty():
		detail_lines.append("Pressure lesson: %s" % curriculum_line)
	var anomaly_pull := str(frame.get("anomaly_pull", "")).strip_edges()
	if not anomaly_pull.is_empty():
		detail_lines.append("Uneasy pull: %s" % anomaly_pull)
	var build_line := str(frame.get("build_line", "")).strip_edges()
	if not build_line.is_empty():
		detail_lines.append("Build: %s" % build_line)
	var resource_line := str(frame.get("resource_line", "")).strip_edges()
	if not resource_line.is_empty():
		detail_lines.append("Pressure: %s" % resource_line)
	var inhabitant_line := str(frame.get("inhabitant_line", "")).strip_edges()
	if not inhabitant_line.is_empty():
		detail_lines.append("Presence: %s" % inhabitant_line)
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var risk_profile := str(diagnostics.get("risk_profile", "")).strip_edges()
	if not build_stability.is_empty() or not risk_profile.is_empty():
		var stability_line := build_stability
		if not risk_profile.is_empty():
			stability_line = "%s | %s" % [build_stability if not build_stability.is_empty() else "shape", risk_profile]
		detail_lines.append("Stability: %s" % stability_line)
	var echoes := _find_case_echoes(archive_state, diagnostics, frame, branch_summary)
	if not echoes.is_empty():
		detail_lines.append("Prior echo: %s" % echoes[0])
	var current_layer := _current_layer(world_memory_layer(run_context, diagnostics, branch_summary))
	if not current_layer.is_empty():
		detail_lines.append("Layer: %s" % current_layer)
	var myth_line := _related_myth_line(run_context, diagnostics, frame, branch_summary)
	if not myth_line.is_empty():
		detail_lines.append("Field: %s" % myth_line)
	var school_line := _school_line(frame)
	if not school_line.is_empty():
		detail_lines.append("Reading: %s" % school_line)
	var comparison_line := _comparison_line(archive_state, run_context, diagnostics, frame, branch_summary)
	if not comparison_line.is_empty():
		detail_lines.append("Compare: %s" % comparison_line)
	var continuity_line := _continuity_line(run_context, frame)
	if not continuity_line.is_empty():
		detail_lines.append("Continuity: %s" % continuity_line)
	var world_relation_line := _world_relation_line(run_context, diagnostics, frame, branch_summary)
	if not world_relation_line.is_empty():
		detail_lines.append("Field pull: %s" % world_relation_line)
	var retell_line := _retell_line(diagnostics, frame)
	if not retell_line.is_empty():
		detail_lines.append("Retell as: %s" % retell_line)
	var shorthand_key := _shorthand_key(case_entry_axes(diagnostics, frame, branch_summary))
	return {
		"id": run_key,
		"label": str(frame.get("archive_title", "Recent run echo")),
		"detail": FRAMING_SERVICE_SCRIPT.guard_text("\n".join(detail_lines)),
		"weight": int(frame.get("compression_quality", 0)),
		"short_label": _short_label(frame, diagnostics, shorthand_key),
		"story_axes": Array(frame.get("story_axes", [])).duplicate(),
		"legend_candidate": _passes_legend_threshold(diagnostics, frame),
		"pattern_line": pattern_line,
		"watch_next": _first_string(_string_array(diagnostics.get("anticipation_hooks", [])), _first_string(_string_array(diagnostics.get("pressure_persistence", [])), "")),
		"echoes": echoes,
		"layer": current_layer,
		"myth_line": myth_line,
		"school_line": school_line,
		"comparison_line": comparison_line,
		"continuity_line": continuity_line,
		"world_relation_line": world_relation_line,
		"retell_line": retell_line,
		"artifact_signal_line": artifact_signal_line,
		"branch_signal_line": branch_signal_line,
		"case_axes": case_entry_axes(diagnostics, frame, branch_summary),
		"shorthand_key": shorthand_key
	}

static func _build_legend_entry(case_entry: Dictionary, crawl_packet: Dictionary) -> Dictionary:
	return {
		"id": "%s|legend" % str(case_entry.get("id", "")),
		"label": str(case_entry.get("label", "Legend echo")),
		"detail": "%s\nCrawl: %s" % [
			str(case_entry.get("detail", "")),
			str(crawl_packet.get("title", "Current crawl"))
		],
		"short_label": str(case_entry.get("short_label", "Legend echo")),
		"discovered": true
	}

static func _build_case_entries(archive_state: Dictionary) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for legend_raw in Array(archive_state.get("legends", [])):
		var legend: Dictionary = Dictionary(legend_raw)
		entries.append({
			"id": str(legend.get("id", "")),
			"label": "Legend | %s" % str(legend.get("label", "Legend echo")),
			"detail": "%s\nShorthand: %s" % [str(legend.get("detail", "")), str(legend.get("short_label", "Legend echo"))],
			"discovered": true
		})
	for case_raw in Array(archive_state.get("cases", [])):
		var case_entry: Dictionary = Dictionary(case_raw)
		var detail_lines := [str(case_entry.get("detail", ""))]
		var echoes := _string_array(case_entry.get("echoes", []))
		if not echoes.is_empty():
			detail_lines.append("Echoes: %s" % ", ".join(echoes.slice(0, mini(echoes.size(), 2))))
		if not str(case_entry.get("myth_line", "")).strip_edges().is_empty():
			detail_lines.append("Field: %s" % str(case_entry.get("myth_line", "")))
		if not str(case_entry.get("school_line", "")).strip_edges().is_empty():
			detail_lines.append("Reading: %s" % str(case_entry.get("school_line", "")))
		if not str(case_entry.get("comparison_line", "")).strip_edges().is_empty():
			detail_lines.append("Compare: %s" % str(case_entry.get("comparison_line", "")))
		if not str(case_entry.get("continuity_line", "")).strip_edges().is_empty():
			detail_lines.append("Continuity: %s" % str(case_entry.get("continuity_line", "")))
		if not str(case_entry.get("world_relation_line", "")).strip_edges().is_empty():
			detail_lines.append("Field pull: %s" % str(case_entry.get("world_relation_line", "")))
		if not str(case_entry.get("artifact_signal_line", "")).strip_edges().is_empty():
			detail_lines.append("Artifact echo: %s" % str(case_entry.get("artifact_signal_line", "")))
		if not str(case_entry.get("branch_signal_line", "")).strip_edges().is_empty():
			detail_lines.append("Branch drift: %s" % str(case_entry.get("branch_signal_line", "")))
		if not str(case_entry.get("retell_line", "")).strip_edges().is_empty():
			detail_lines.append("Retell as: %s" % str(case_entry.get("retell_line", "")))
		if not str(case_entry.get("watch_next", "")).strip_edges().is_empty():
			detail_lines.append("Watch next: %s" % str(case_entry.get("watch_next", "")))
		entries.append({
			"id": str(case_entry.get("id", "")),
			"label": "Case | %s" % str(case_entry.get("label", "Recent echo")),
			"detail": "\n".join(detail_lines),
			"discovered": true
		})
	if entries.is_empty():
		entries.append({
			"id": "archive:none",
			"label": "No archive cases yet",
			"detail": "High-density runs with clear story compression start surfacing here.",
			"discovered": true
		})
	return entries.slice(0, mini(entries.size(), CASE_LIMIT))

static func _build_world_entries(world_memory: Dictionary) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var field_snapshot := WORLD_MEMORY_SERVICE_SCRIPT.field_snapshot(world_memory)
	var gravity := Dictionary(field_snapshot.get("cultural_gravity", {}))
	var myth_field := Dictionary(field_snapshot.get("myth_field", {}))
	var collision_lines := _string_array(Dictionary(field_snapshot.get("myth_collision", {})).get("lines", []))
	var resurgence_lines := _string_array(Dictionary(field_snapshot.get("myth_resurgence", {})).get("lines", []))
	var cooling_lines := _string_array(Dictionary(field_snapshot.get("myth_cooling", {})).get("lines", []))
	var epistemic_order := Dictionary(field_snapshot.get("epistemic_order", {}))
	var canon_lines := _string_array(epistemic_order.get("lines", []))
	var drift_lines := _string_array(epistemic_order.get("drift_lines", []))
	var forgery_lines := _string_array(epistemic_order.get("forgery_lines", []))
	var dominant_tradition := str(epistemic_order.get("dominant_tradition", "")).strip_edges()
	var affective_climate := Dictionary(field_snapshot.get("affective_climate", {}))
	var climate_lines := _string_array(affective_climate.get("lines", []))
	var mourning_lines := _string_array(affective_climate.get("mourning_lines", []))
	var labor_lines := _string_array(affective_climate.get("labor_lines", []))
	var dominant_age := str(affective_climate.get("dominant_age", "")).strip_edges()
	var ontology_state := Dictionary(field_snapshot.get("ontology_state", {}))
	var ontology_lines := _string_array(ontology_state.get("lines", []))
	var uncertainty_lines := _string_array(ontology_state.get("uncertainty_lines", []))
	var echo_lines := _string_array(ontology_state.get("echo_lines", []))
	var dominant_ontology := str(ontology_state.get("dominant_ontology", "")).strip_edges()
	var delve_history := Dictionary(field_snapshot.get("delve_history", {}))
	var delve_lines := _string_array(delve_history.get("lines", []))
	var history_lines := _string_array(delve_history.get("history_lines", []))
	var dominant_method := str(delve_history.get("dominant_method", "")).strip_edges()
	var interpretation_network := Dictionary(field_snapshot.get("interpretation_network", {}))
	var dominant_nodes := _string_array(interpretation_network.get("dominant_nodes", []))
	var network_lines := _string_array(interpretation_network.get("lines", []))
	var spread_lines := _string_array(interpretation_network.get("spread_lines", []))
	var campaign_lines := _string_array(interpretation_network.get("campaign_lines", []))
	var order_tension := Dictionary(field_snapshot.get("order_tension", {}))
	var order_lines := _string_array(order_tension.get("lines", []))
	var site_lines := _string_array(order_tension.get("site_lines", []))
	var artifact_lines := _string_array(order_tension.get("artifact_lines", []))
	var silence_doctrine := Dictionary(field_snapshot.get("silence_doctrine", {}))
	var silence_lines := _string_array(silence_doctrine.get("lines", []))
	var zone_lines := _string_array(silence_doctrine.get("zone_lines", []))
	var cookbook_shadow := Dictionary(field_snapshot.get("cookbook_shadow", {}))
	var cookbook_lines := _string_array(cookbook_shadow.get("lines", []))
	var rumor_lines := _string_array(cookbook_shadow.get("rumor_lines", []))
	var redirection_lines := _string_array(cookbook_shadow.get("redirection_lines", []))
	var crawl_network_state := Dictionary(field_snapshot.get("crawl_network_state", {}))
	var relay_lines := _string_array(crawl_network_state.get("lines", []))
	var witness_lines := _string_array(crawl_network_state.get("witness_lines", []))
	var bottleneck_lines := _string_array(crawl_network_state.get("bottleneck_lines", []))
	if not str(gravity.get("top_label", "")).strip_edges().is_empty():
		entries.append({
			"id": "field:gravity",
			"label": "Field | %s" % str(gravity.get("top_label", "")),
			"detail": "Gravity: %d | Bucket: %s | Pull: %s" % [
				int(gravity.get("top_gravity", 0)),
				str(gravity.get("top_bucket", "world")),
				_first_string(_string_array(gravity.get("lines", [])), "still pulling nearby stories")
			],
			"discovered": true
		})
	if not collision_lines.is_empty():
		entries.append({
			"id": "field:collision",
			"label": "Field | Collision",
			"detail": collision_lines[0],
			"discovered": true
		})
	if not resurgence_lines.is_empty():
		entries.append({
			"id": "field:return",
			"label": "Field | Return",
			"detail": resurgence_lines[0],
			"discovered": true
		})
	if not cooling_lines.is_empty():
		entries.append({
			"id": "field:cooling",
			"label": "Field | Cooling",
			"detail": cooling_lines[0],
			"discovered": true
		})
	if not dominant_tradition.is_empty() or not canon_lines.is_empty():
		entries.append({
			"id": "field:canon",
			"label": "Canon | %s" % (dominant_tradition if not dominant_tradition.is_empty() else "contested record"),
			"detail": "Orthodoxy: %d | Revision: %d | Pull: %s" % [
				int(epistemic_order.get("orthodoxy_strength", 0)),
				int(epistemic_order.get("revision_pressure", 0)),
				_first_string(canon_lines, "the accepted proof language is still being contested")
			],
			"discovered": true
		})
	if not drift_lines.is_empty():
		entries.append({
			"id": "field:drift",
			"label": "Field | Drift",
			"detail": drift_lines[0],
			"discovered": true
		})
	if not forgery_lines.is_empty():
		entries.append({
			"id": "field:forgery",
			"label": "Field | Forgery",
			"detail": forgery_lines[0],
			"discovered": true
		})
	if not dominant_age.is_empty() or not climate_lines.is_empty():
		entries.append({
			"id": "field:climate",
			"label": "Climate | %s" % (dominant_age if not dominant_age.is_empty() else "contested weather"),
			"detail": _first_string(climate_lines, "civilian mood is shifting between pressure and recovery"),
			"discovered": true
		})
	if not mourning_lines.is_empty():
		entries.append({
			"id": "field:mourning",
			"label": "Field | Mourning",
			"detail": mourning_lines[0],
			"discovered": true
		})
	if not labor_lines.is_empty():
		entries.append({
			"id": "field:civic",
			"label": "Field | Civic",
			"detail": labor_lines[0],
			"discovered": true
		})
	if not dominant_ontology.is_empty() or not ontology_lines.is_empty():
		entries.append({
			"id": "field:ontology",
			"label": "Ontology | %s" % (dominant_ontology if not dominant_ontology.is_empty() else "contested world"),
			"detail": _first_string(ontology_lines, "the world is being argued into a new shape"),
			"discovered": true
		})
	if not uncertainty_lines.is_empty():
		entries.append({
			"id": "field:uncertainty",
			"label": "Field | Uncertainty",
			"detail": uncertainty_lines[0],
			"discovered": true
		})
	if not echo_lines.is_empty():
		entries.append({
			"id": "field:echo",
			"label": "Field | Counterfactual",
			"detail": echo_lines[0],
			"discovered": true
		})
	if not dominant_method.is_empty() or not delve_lines.is_empty():
		entries.append({
			"id": "field:delve",
			"label": "DelveMind | %s" % (dominant_method if not dominant_method.is_empty() else "method history"),
			"detail": _first_string(delve_lines, "DelveMind is starting to acquire a readable institutional method history"),
			"discovered": true
		})
	if not history_lines.is_empty():
		entries.append({
			"id": "field:delve_history",
			"label": "Field | Method history",
			"detail": history_lines[0],
			"discovered": true
		})
	if not dominant_nodes.is_empty() or not network_lines.is_empty():
		entries.append({
			"id": "field:network",
			"label": "Network | %s" % (_first_string(dominant_nodes, "contested reading")),
			"detail": "Spread: %d | Contradiction: %d | Campaigns: %d | Pull: %s" % [
				int(interpretation_network.get("spread_heat", 0)),
				int(interpretation_network.get("contradiction_heat", 0)),
				int(interpretation_network.get("institutional_campaigns", 0)),
				_first_string(network_lines, "interpretations are spreading faster than they are settling")
			],
			"discovered": true
		})
	if not spread_lines.is_empty():
		entries.append({
			"id": "field:spread",
			"label": "Field | Spread",
			"detail": spread_lines[0],
			"discovered": true
		})
	if not campaign_lines.is_empty():
		entries.append({
			"id": "field:campaign",
			"label": "Field | Campaign",
			"detail": campaign_lines[0],
			"discovered": true
		})
	if not order_lines.is_empty():
		entries.append({
			"id": "field:order",
			"label": "Order | contested",
			"detail": order_lines[0],
			"discovered": true
		})
	if not site_lines.is_empty():
		entries.append({
			"id": "field:site",
			"label": "Field | Site",
			"detail": site_lines[0],
			"discovered": true
		})
	if not artifact_lines.is_empty():
		entries.append({
			"id": "field:relic",
			"label": "Field | Relic",
			"detail": artifact_lines[0],
			"discovered": true
		})
	if not silence_lines.is_empty():
		entries.append({
			"id": "field:silence",
			"label": "Silence | preserved",
			"detail": silence_lines[0],
			"discovered": true
		})
	if not zone_lines.is_empty():
		entries.append({
			"id": "field:unclassified",
			"label": "Field | Unclassified",
			"detail": zone_lines[0],
			"discovered": true
		})
	if not cookbook_lines.is_empty():
		entries.append({
			"id": "field:margins",
			"label": "Margins | forbidden residue",
			"detail": "Fragments: %d | %s" % [
				int(cookbook_shadow.get("fragment_heat", 0)),
				cookbook_lines[0]
			],
			"discovered": true
		})
	if not rumor_lines.is_empty():
		entries.append({
			"id": "field:rumor",
			"label": "Rumor | indirect recognition",
			"detail": "Rumor: %d | Network: %d | %s" % [
				int(cookbook_shadow.get("holder_rumor", 0)),
				int(cookbook_shadow.get("network_rumor", 0)),
				rumor_lines[0]
			],
			"discovered": true
		})
	if not redirection_lines.is_empty():
		entries.append({
			"id": "field:redirection",
			"label": "Field | Redirection",
			"detail": redirection_lines[0],
			"discovered": true
		})
	if not relay_lines.is_empty():
		entries.append({
			"id": "field:relay",
			"label": "Network | Relay",
			"detail": "Stress: %d | Rumor shock: %d | %s" % [
				int(crawl_network_state.get("relay_stress", 0)),
				int(crawl_network_state.get("rumor_shock", 0)),
				relay_lines[0]
			],
			"discovered": true
		})
	if not witness_lines.is_empty():
		entries.append({
			"id": "field:witness",
			"label": "Field | Witness",
			"detail": "Witness pressure: %d | Cohort pressure: %d | %s" % [
				int(crawl_network_state.get("witness_pressure", 0)),
				int(crawl_network_state.get("cohort_pressure", 0)),
				witness_lines[0]
			],
			"discovered": true
		})
	if not bottleneck_lines.is_empty():
		entries.append({
			"id": "field:bottleneck",
			"label": "Field | Bottleneck",
			"detail": "Bottleneck: %d | %s" % [
				int(crawl_network_state.get("bottleneck_pressure", 0)),
				bottleneck_lines[0]
			],
			"discovered": true
		})
	for topic in WORLD_MEMORY_SERVICE_SCRIPT.top_fascination_topics(world_memory, 4):
		var topic_dict: Dictionary = Dictionary(topic)
		entries.append({
			"id": "focus:%s" % str(topic_dict.get("id", "")),
			"label": "Focus | %s" % str(topic_dict.get("label", topic_dict.get("id", ""))),
			"detail": "Heat: %d | Phase: %s | Pull: %s" % [int(topic_dict.get("heat", 0)), str(topic_dict.get("phase", "active")), str(topic_dict.get("pull", "watching"))],
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "branch", 2):
		var branch_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "branch:%s" % str(branch_entry.get("id", "")),
			"label": "Branch | %s" % str(branch_entry.get("label", "")),
			"detail": "Status: %s | Heat: %d | Phase: %s | Gravity: %d | Shadow: %s" % [
				str(branch_entry.get("status", "active")),
				int(branch_entry.get("heat", 0)),
				str(branch_entry.get("phase", "emerging")),
				int(branch_entry.get("gravity", 0)),
				str(_first_string(_string_array(branch_entry.get("shadow_tags", [])), "none"))
			],
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "item", 2):
		var item_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "item:%s" % str(item_entry.get("id", "")),
			"label": "Item | %s" % str(item_entry.get("label", "")),
			"detail": "Status: %s | Heat: %d | Phase: %s | Gravity: %d | Pull: %s" % [
				str(item_entry.get("status", "active")),
				int(item_entry.get("heat", 0)),
				str(item_entry.get("phase", "emerging")),
				int(item_entry.get("gravity", 0)),
				str(_first_string(_string_array(item_entry.get("resonance_tags", [])), "none"))
			],
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "pair", 2):
		var pair_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "pair:%s" % str(pair_entry.get("id", "")),
			"label": "Pair | %s" % str(pair_entry.get("label", "")),
			"detail": "Status: %s | Heat: %d | Resonance: %s" % [
				str(pair_entry.get("status", "active")),
				int(pair_entry.get("heat", 0)),
				str(_first_string(_string_array(pair_entry.get("resonance_tags", [])), "none"))
			],
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "crew", 1):
		var crew_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "crew:%s" % str(crew_entry.get("id", "")),
			"label": "Crew | %s" % str(crew_entry.get("label", "")),
			"detail": "Status: %s | Heat: %d | Shadow: %s" % [
				str(crew_entry.get("status", "active")),
				int(crew_entry.get("heat", 0)),
				str(_first_string(_string_array(crew_entry.get("shadow_tags", [])), "none"))
			],
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "crawl", 1):
		var crawl_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "crawl:%s" % str(crawl_entry.get("id", "")),
			"label": "Crawl | %s" % str(crawl_entry.get("label", "")),
			"detail": "Phase: %s | Pull: %s | Successor: %s | Resonance: %s" % [
				str(crawl_entry.get("phase", "emerging")),
				str(crawl_entry.get("pull", "watching")),
				str(crawl_entry.get("successor_hint", "none")),
				str(_first_string(_string_array(crawl_entry.get("resonance_tags", [])), "none"))
			],
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "player", 2):
		var player_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "player:%s" % str(player_entry.get("id", "")),
			"label": "Delver | %s" % str(player_entry.get("label", "")),
			"detail": _world_entry_detail(player_entry),
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "place", 1):
		var place_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "place:%s" % str(place_entry.get("id", "")),
			"label": "Place | %s" % str(place_entry.get("label", "")),
			"detail": _world_entry_detail(place_entry),
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "object", 1):
		var object_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "object:%s" % str(object_entry.get("id", "")),
			"label": "Object | %s" % str(object_entry.get("label", "")),
			"detail": _world_entry_detail(object_entry),
			"discovered": true
		})
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "run_shape", 1):
		var shape_entry: Dictionary = Dictionary(entry)
		entries.append({
			"id": "run_shape:%s" % str(shape_entry.get("id", "")),
			"label": "Run shape | %s" % str(shape_entry.get("label", "")),
			"detail": _world_entry_detail(shape_entry),
			"discovered": true
		})
	if entries.is_empty():
		entries.append({
			"id": "world:none",
			"label": "No active fascination wave",
			"detail": "World attention gathers when repeated quests, rescues, scandals, or refusals keep returning.",
			"discovered": true
		})
	return entries

static func _passes_legend_threshold(diagnostics: Dictionary, frame: Dictionary, world_memory: Dictionary = {}) -> bool:
	if int(frame.get("compression_quality", 0)) < 5:
		return false
	if int(frame.get("legend_density_score", 0)) < 7:
		return false
	var reinforcing := 0
	if int(diagnostics.get("retellability_score", 0)) >= 3:
		reinforcing += 1
	if int(diagnostics.get("symbolic_gesture_score", 0)) >= 1:
		reinforcing += 1
	if int(diagnostics.get("expectation_break_score", 0)) >= 1:
		reinforcing += 1
	if int(diagnostics.get("recovery_score", 0)) >= 2:
		reinforcing += 1
	if not WORLD_MEMORY_SERVICE_SCRIPT.top_fascination_topics(world_memory, 1).is_empty():
		reinforcing += 1
	return reinforcing >= 3

static func _short_label(frame: Dictionary, diagnostics: Dictionary, shorthand_key: String = "") -> String:
	var atmosphere := str(diagnostics.get("atmosphere", "steady")).replace("_", " ").capitalize()
	var valence := str(frame.get("status_valence", "Noted"))
	if not shorthand_key.is_empty():
		return "%s // %s" % [atmosphere, shorthand_key]
	return "%s %s" % [atmosphere, valence]

static func case_entry_axes(diagnostics: Dictionary, frame: Dictionary, branch_summary: Dictionary) -> Array[String]:
	return _string_array(
		Array(frame.get("story_axes", []))
		+ Array(diagnostics.get("run_shapes", []))
		+ [str(branch_summary.get("branch_family_name", ""))]
		+ Array(diagnostics.get("artifact_lineage_hints", []))
		+ Array(diagnostics.get("artifact_prestige_indicators", []))
	)

static func world_memory_layer(run_context: Dictionary, diagnostics: Dictionary, branch_summary: Dictionary) -> Dictionary:
	var world_memory: Dictionary = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(run_context.get("world_memory", {})))
	var layers: Array[String] = []
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "branch", 1):
		layers.append(str(Dictionary(entry).get("phase", "")))
	for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "item", 1):
		layers.append(str(Dictionary(entry).get("phase", "")))
	if layers.is_empty():
		layers = _string_array(diagnostics.get("pressure_persistence", []))
	if layers.is_empty() and not branch_summary.is_empty():
		layers.append(str(branch_summary.get("challenge_texture", "")))
	return {
		"layers": layers
	}

static func _current_layer(layer_packet: Dictionary) -> String:
	return _first_string(_string_array(layer_packet.get("layers", [])), "")

static func _find_case_echoes(archive_state: Dictionary, diagnostics: Dictionary, frame: Dictionary, branch_summary: Dictionary) -> Array[String]:
	var echoes: Array[String] = []
	var axes := case_entry_axes(diagnostics, frame, branch_summary)
	for legend_raw in Array(archive_state.get("legends", [])):
		var legend: Dictionary = Dictionary(legend_raw)
		var legend_label := str(legend.get("short_label", legend.get("label", ""))).strip_edges()
		if legend_label.is_empty():
			continue
		var legend_detail := str(legend.get("detail", "")).to_lower()
		var matches := 0
		for axis in axes:
			if axis.to_lower().is_empty():
				continue
			if legend_detail.find(axis.to_lower()) != -1:
				matches += 1
		if matches >= 1:
			echoes.append(legend_label)
		if echoes.size() >= 2:
			break
	for case_raw in Array(archive_state.get("cases", [])):
		var case_entry: Dictionary = Dictionary(case_raw)
		var matches := 0
		for axis in axes:
			if _string_array(case_entry.get("case_axes", [])).has(axis):
				matches += 1
			elif str(case_entry.get("detail", "")).to_lower().find(axis.to_lower()) != -1:
				matches += 1
		if matches >= 2:
			echoes.append(str(case_entry.get("short_label", case_entry.get("label", "prior echo"))))
		if echoes.size() >= 2:
			break
	return _string_array(echoes)

static func _related_myth_line(run_context: Dictionary, diagnostics: Dictionary, frame: Dictionary, branch_summary: Dictionary) -> String:
	var world_memory: Dictionary = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(run_context.get("world_memory", {})))
	var pair_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "pair", 1)
	var crew_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "crew", 1)
	var branch_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "branch", 1)
	var item_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "item", 1)
	var place_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "place", 1)
	var object_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "object", 1)
	var branch_name := str(branch_summary.get("branch_family_name", "")).strip_edges()
	if not branch_entries.is_empty():
		var branch_entry: Dictionary = Dictionary(branch_entries[0])
		if branch_name == str(branch_entry.get("label", "")) or Array(frame.get("story_axes", [])).has(str(branch_entry.get("label", ""))):
			return "%s is carrying older pressure" % branch_name
	if not item_entries.is_empty() and Array(diagnostics.get("item_story_roles", [])).size() >= 1:
		return "%s keeps returning in charged contexts" % str(Dictionary(item_entries[0]).get("label", "that item"))
	if not pair_entries.is_empty() and Array(diagnostics.get("pair_keys", [])).size() >= 1:
		return "%s still reads as unfinished" % str(Dictionary(pair_entries[0]).get("label", "that pair"))
	if not crew_entries.is_empty() and Array(diagnostics.get("crew_hooks", [])).size() >= 1:
		return "%s keeps dragging older crew pressure back into view" % str(Dictionary(crew_entries[0]).get("label", "that crew"))
	if not place_entries.is_empty() and not _string_array(diagnostics.get("load_bearing_places", [])).is_empty():
		return "%s is still making later choices feel loaded" % str(Dictionary(place_entries[0]).get("label", "that place"))
	if not object_entries.is_empty() and not _string_array(diagnostics.get("load_bearing_objects", [])).is_empty():
		return "%s keeps carrying a remembered argument" % str(Dictionary(object_entries[0]).get("label", "that object"))
	return ""

static func _comparison_line(archive_state: Dictionary, run_context: Dictionary, diagnostics: Dictionary, frame: Dictionary, branch_summary: Dictionary) -> String:
	var echoes := _find_case_echoes(archive_state, diagnostics, frame, branch_summary)
	var breaks := _string_array(diagnostics.get("expectation_breaks", []))
	var counter := _string_array(frame.get("counter_readings", []))
	var school_reads := _string_array(frame.get("school_reads", []))
	var places := _string_array(diagnostics.get("load_bearing_places", []))
	var objects := _string_array(diagnostics.get("load_bearing_objects", []))
	var pair_keys := _string_array(diagnostics.get("pair_keys", []))
	var crew_hooks := _string_array(diagnostics.get("crew_hooks", []))
	var field_snapshot := WORLD_MEMORY_SERVICE_SCRIPT.field_snapshot(Dictionary(run_context.get("world_memory", {})))
	var successor := str(Dictionary(Dictionary(field_snapshot.get("myth_field", {})).get("top_successor", {})).get("hint", "")).strip_edges()
	var rituals := _string_array(diagnostics.get("ritual_recurrence", []))
	var recovery := _string_array(diagnostics.get("recovery_ecology", []))
	var counterfactual := str(frame.get("counterfactual_line", "")).strip_edges()
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	var build_line := str(frame.get("build_line", "")).strip_edges()
	var resource_line := str(frame.get("resource_line", "")).strip_edges()
	var inhabitant_line := str(frame.get("inhabitant_line", "")).strip_edges()
	var doctrine_line := str(frame.get("doctrine_line", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var group_fault := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	var branch_reputation_drift := str(diagnostics.get("branch_reputation_drift", "")).strip_edges()
	var artifact_cultural_association := str(diagnostics.get("artifact_cultural_association", "")).strip_edges()
	var artifact_lineage := _first_string(_string_array(diagnostics.get("artifact_lineage_hints", [])), "")
	if not echoes.is_empty():
		if not branch_reputation_drift.is_empty():
			return "echoes %s while %s" % [echoes[0], branch_reputation_drift.to_lower()]
		if not artifact_cultural_association.is_empty():
			return "echoes %s while %s keeps carrying the newer charge" % [echoes[0], artifact_cultural_association.to_lower()]
		if not artifact_lineage.is_empty():
			return "echoes %s while %s keeps returning through the artifact line" % [echoes[0], artifact_lineage.to_lower()]
		if not doctrine_line.is_empty() and not governance_line.is_empty():
			return "echoes %s while %s keeps steering it toward %s" % [echoes[0], doctrine_line.to_lower(), governance_line.to_lower()]
		if not counterfactual.is_empty():
			return "echoes %s while still being judged against %s" % [echoes[0], counterfactual.to_lower()]
		if not model_pressure.is_empty() and not group_fault.is_empty():
			return "echoes %s while %s keeps reopening %s" % [echoes[0], model_pressure.to_lower(), group_fault.to_lower()]
		if not breaks.is_empty():
			return "breaks from %s while reopening %s" % [echoes[0], breaks[0]]
		if not school_reads.is_empty() and school_reads.size() >= 2:
			return "echoes %s while newer readings are already splitting against it" % echoes[0]
		if not rituals.is_empty():
			return "repeats %s while making %s feel ritual again" % [echoes[0], rituals[0].to_lower()]
		if not recovery.is_empty():
			return "answers %s with %s" % [echoes[0], recovery[0].to_lower()]
		if not places.is_empty():
			return "echoes %s while %s starts reading like the same kind of site" % [echoes[0], places[0].to_lower()]
		if not objects.is_empty():
			return "echoes %s while %s keeps carrying the same charge" % [echoes[0], objects[0].to_lower()]
		if not pair_keys.is_empty():
			return "echoes %s while %s keeps reopening the same pressure" % [echoes[0], _pair_label(pair_keys[0]).to_lower()]
		if not crew_hooks.is_empty():
			return "echoes %s while the crew shape starts answering it again" % echoes[0]
		if not belief_line.is_empty():
			return "echoes %s while belief keeps narrowing around %s" % [echoes[0], belief_line.to_lower()]
		if not build_line.is_empty():
			return "echoes %s while %s keeps carrying the answer shape" % [echoes[0], build_line.to_lower()]
		if not resource_line.is_empty():
			return "echoes %s while %s keeps changing the cost of the answer" % [echoes[0], resource_line.to_lower()]
		if not inhabitant_line.is_empty():
			return "echoes %s while %s keeps leaning on the route" % [echoes[0], inhabitant_line.to_lower()]
		if not build_stability.is_empty():
			return "echoes %s while the answer shape still looks %s" % [echoes[0], build_stability.to_lower()]
		if not counter.is_empty():
			return "echoes %s but keeps inviting %s" % [echoes[0], counter[0]]
		if not successor.is_empty():
			return "echoes %s while the field keeps recasting it toward %s" % [echoes[0], successor.to_lower()]
		return "echoes %s while pulling toward %s" % [echoes[0], _first_string(counter, "a new reading")]
	var world_memory: Dictionary = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(run_context.get("world_memory", {})))
	var focus_topics := WORLD_MEMORY_SERVICE_SCRIPT.top_fascination_topics(world_memory, 1)
	if not focus_topics.is_empty():
		return "lands inside %s while the culture is still watching" % str(Dictionary(focus_topics[0]).get("label", "that pressure"))
	return ""

static func _artifact_signal_line(diagnostics: Dictionary) -> String:
	var continuity_text := str(diagnostics.get("artifact_continuity_text", "")).strip_edges()
	if not continuity_text.is_empty():
		return continuity_text
	var cultural_association := str(diagnostics.get("artifact_cultural_association", "")).strip_edges()
	if not cultural_association.is_empty():
		return cultural_association
	var prestige := _first_string(_string_array(diagnostics.get("artifact_prestige_indicators", [])), "")
	if not prestige.is_empty():
		return prestige
	return _first_string(_string_array(diagnostics.get("artifact_lineage_hints", [])), "")

static func _branch_signal_line(diagnostics: Dictionary) -> String:
	var drift := str(diagnostics.get("branch_reputation_drift", "")).strip_edges()
	if not drift.is_empty():
		return drift
	return _first_string(_string_array(diagnostics.get("branch_caution_markers", [])), "")

static func _continuity_line(run_context: Dictionary, frame: Dictionary) -> String:
	var profile: Dictionary = Dictionary(run_context.get("profile", {}))
	var crawl_packet: Dictionary = Dictionary(run_context.get("crawl_packet", {}))
	var residue := _first_string(_string_array(crawl_packet.get("memorial_residue", [])), "")
	var public_challenge := str(crawl_packet.get("public_challenge", "")).strip_edges()
	var build_line := str(frame.get("build_line", "")).strip_edges()
	var resource_line := str(frame.get("resource_line", "")).strip_edges()
	var doctrine_line := str(frame.get("doctrine_line", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var model_pressure := _first_string(_string_array(crawl_packet.get("model_memory", [])), "")
	var fault_memory := _first_string(_string_array(crawl_packet.get("fault_memory", [])), "")
	if not public_challenge.is_empty():
		return public_challenge
	var promise_pressure := str(crawl_packet.get("promise_pressure", "")).strip_edges()
	if not promise_pressure.is_empty():
		return promise_pressure
	var belief_bits := _first_string(_string_array(crawl_packet.get("belief_pressure", [])), "")
	if not belief_bits.is_empty():
		return belief_bits
	if not model_pressure.is_empty():
		return model_pressure
	if not fault_memory.is_empty():
		return fault_memory
	if not residue.is_empty():
		return "still carrying %s" % residue.to_lower()
	var expectation := str(crawl_packet.get("expectation_pressure", "")).strip_edges()
	if not expectation.is_empty():
		return expectation
	var unfinished := _first_string(_string_array(crawl_packet.get("unfinished_pressure", [])), "")
	if not unfinished.is_empty():
		return unfinished
	if not build_line.is_empty():
		return build_line
	if not doctrine_line.is_empty():
		return doctrine_line
	if not governance_line.is_empty():
		return governance_line
	if not resource_line.is_empty():
		return resource_line
	var promise := _first_string(_string_array(crawl_packet.get("crawl_promises", [])), "")
	if not promise.is_empty():
		return promise
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var recent_pairs := _string_array(fabric.get("recent_pairs", []))
	if not recent_pairs.is_empty():
		var pair_entry: Dictionary = Dictionary(Dictionary(fabric.get("pairs", {})).get(recent_pairs[0], {}))
		var pair_obligation := _first_string(_string_array(pair_entry.get("obligations", [])), "")
		if not pair_obligation.is_empty():
			return pair_obligation
		if int(pair_entry.get("near_misses", 0)) >= 2:
			return "%s keeps carrying unfinished near-miss pressure" % str(pair_entry.get("display_label", "That pair"))
		var pair_rep := str(pair_entry.get("public_reputation", "")).strip_edges()
		if not pair_rep.is_empty():
			return pair_rep
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	if not recent_crews.is_empty():
		var crew_entry: Dictionary = Dictionary(Dictionary(fabric.get("crews", {})).get(recent_crews[0], {}))
		var crew_obligation := _first_string(_string_array(crew_entry.get("obligations", [])), "")
		if not crew_obligation.is_empty():
			return crew_obligation
		if int(crew_entry.get("collapse_moments", 0)) >= 2:
			return "%s is still being read against earlier collapse pressure" % str(crew_entry.get("display_label", "That crew"))
		var crew_rep := str(crew_entry.get("public_reputation", "")).strip_edges()
		if not crew_rep.is_empty():
			return crew_rep
	var state := str(crawl_packet.get("bank_vs_push_state", "")).strip_edges()
	if not state.is_empty():
		return "crawl pull: %s" % state.replace("_", " ")
	var world_memory: Dictionary = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(run_context.get("world_memory", {})))
	var continuity_review_line := str(WORLD_MEMORY_SERVICE_SCRIPT.build_continuity_review(world_memory).get("summary_line", "")).strip_edges()
	if not continuity_review_line.is_empty():
		return continuity_review_line
	var world_pull := str(frame.get("world_pull", "")).strip_edges()
	if not world_pull.is_empty():
		return world_pull
	return ""

static func _school_line(frame: Dictionary) -> String:
	var primary := _first_string(_string_array(frame.get("school_reads", [])), "")
	var tension := str(frame.get("school_tension", "")).strip_edges()
	if not tension.is_empty():
		return "%s | %s" % [primary, tension] if not primary.is_empty() else tension
	return primary

static func _world_relation_line(run_context: Dictionary, diagnostics: Dictionary, frame: Dictionary, branch_summary: Dictionary) -> String:
	var world_memory: Dictionary = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(run_context.get("world_memory", {})))
	var field_snapshot := WORLD_MEMORY_SERVICE_SCRIPT.field_snapshot(world_memory)
	var gravity := Dictionary(field_snapshot.get("cultural_gravity", {}))
	var focus_topics := WORLD_MEMORY_SERVICE_SCRIPT.top_fascination_topics(world_memory, 1)
	var pair_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "pair", 1)
	var crew_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "crew", 1)
	var place_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "place", 1)
	var object_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "object", 1)
	var collision_lines := _string_array(Dictionary(field_snapshot.get("myth_collision", {})).get("lines", []))
	var resurgence_lines := _string_array(Dictionary(field_snapshot.get("myth_resurgence", {})).get("lines", []))
	var gravity_lines := _string_array(gravity.get("lines", []))
	var belief_line := str(frame.get("belief_line", "")).strip_edges()
	var protocol_state := str(frame.get("protocol_state", "")).strip_edges()
	var resource_line := str(frame.get("resource_line", "")).strip_edges()
	var inhabitant_line := str(frame.get("inhabitant_line", "")).strip_edges()
	var build_line := str(frame.get("build_line", "")).strip_edges()
	var doctrine_line := str(frame.get("doctrine_line", "")).strip_edges()
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var group_fault := _first_string(_string_array(diagnostics.get("group_fault_lines", [])), "")
	if not doctrine_line.is_empty() and not governance_line.is_empty():
		return "%s is still being pushed toward %s." % [doctrine_line, governance_line.to_lower()]
	if not focus_topics.is_empty() and not pair_entries.is_empty():
		return "%s is being read against %s." % [
			str(Dictionary(pair_entries[0]).get("label", "that pair")),
			str(Dictionary(focus_topics[0]).get("label", "current attention")).to_lower()
		]
	if not focus_topics.is_empty() and not crew_entries.is_empty():
		return "%s is being dragged into %s." % [
			str(Dictionary(crew_entries[0]).get("label", "that crew")),
			str(Dictionary(focus_topics[0]).get("label", "current attention")).to_lower()
		]
	if not gravity_lines.is_empty():
		return gravity_lines[0]
	if not collision_lines.is_empty():
		return collision_lines[0]
	if not resurgence_lines.is_empty():
		return resurgence_lines[0]
	if not model_pressure.is_empty() and not group_fault.is_empty():
		return "%s is still being judged through %s." % [model_pressure, group_fault.to_lower()]
	if not belief_line.is_empty() and not protocol_state.is_empty():
		return "%s is still being tightened by %s." % [belief_line, protocol_state.to_lower()]
	if not build_line.is_empty() and not str(Dictionary(gravity).get("top_label", "")).strip_edges().is_empty():
		return "%s is being pulled into %s." % [build_line, str(Dictionary(gravity).get("top_label", "")).to_lower()]
	if not resource_line.is_empty() and not inhabitant_line.is_empty():
		return "%s while %s keeps sharpening the route." % [resource_line, inhabitant_line.to_lower()]
	if not place_entries.is_empty() and not _string_array(diagnostics.get("load_bearing_places", [])).is_empty():
		return "%s is still making nearby choices feel loaded." % str(Dictionary(place_entries[0]).get("label", "that place"))
	if not object_entries.is_empty() and not _string_array(diagnostics.get("load_bearing_objects", [])).is_empty():
		return "%s is still making the object line feel charged." % str(Dictionary(object_entries[0]).get("label", "that object"))
	if not branch_summary.is_empty() and not str(frame.get("world_pull", "")).strip_edges().is_empty():
		return "%s is still carrying older branch pressure." % str(branch_summary.get("branch_family_name", "This branch"))
	return ""

static func _retell_line(diagnostics: Dictionary, frame: Dictionary) -> String:
	var model_pressure := _first_string(_string_array(diagnostics.get("model_pressure", [])), "")
	var build_stability := str(diagnostics.get("build_stability", "")).strip_edges()
	if int(diagnostics.get("expectation_break_score", 0)) >= 1 and int(diagnostics.get("recovery_score", 0)) >= 2:
		return "a pressure run that bent toward repair"
	if not model_pressure.is_empty() and build_stability == "unstable":
		return "the run where %s never fully settled" % model_pressure.to_lower()
	if Array(frame.get("counter_readings", [])).size() >= 2 and int(diagnostics.get("spectacle_pressure", 0)) >= 2:
		return "the run where the reading split before the dust settled"
	if Array(diagnostics.get("ritual_recurrence", [])).size() >= 1 and int(diagnostics.get("symbolic_gesture_score", 0)) >= 1:
		return "the one where the gesture became the ritual"
	if int(diagnostics.get("near_miss_score", 0)) >= 2:
		return "the run that almost held together"
	if int(diagnostics.get("symbolic_gesture_score", 0)) >= 2:
		return "the one where the gesture carried the argument"
	if not str(frame.get("belief_line", "")).strip_edges().is_empty() and not str(frame.get("counterfactual_line", "")).strip_edges().is_empty():
		return "the run where the public answer and the almost-answer refused to align"
	if int(diagnostics.get("spectacle_pressure", 0)) >= 3:
		return "a run that kept taking the hotter shape"
	return _first_string(_string_array(frame.get("interpretation_split", [])), "")

static func _pair_label(pair_key: String) -> String:
	var bits := pair_key.split(":")
	if bits.size() == 2:
		return "%s / %s" % [bits[0], bits[1]]
	return pair_key

static func _world_entry_detail(entry: Dictionary) -> String:
	var detail_lines: Array[String] = []
	detail_lines.append("Status: %s | Heat: %d | Phase: %s | Gravity: %d" % [
		str(entry.get("status", "active")),
		int(entry.get("heat", 0)),
		str(entry.get("phase", "emerging")),
		int(entry.get("gravity", 0))
	])
	var pull := str(entry.get("pull", "")).strip_edges()
	if not pull.is_empty():
		detail_lines.append("Pull: %s" % pull)
	var resonance := _string_array(entry.get("resonance_tags", []))
	if not resonance.is_empty():
		detail_lines.append("Resonance: %s" % ", ".join(resonance.slice(0, mini(resonance.size(), 2))))
	var damping := _string_array(entry.get("damping_tags", []))
	if not damping.is_empty():
		detail_lines.append("Damping: %s" % damping[0])
	var shadow := _string_array(entry.get("shadow_tags", []))
	if not shadow.is_empty():
		detail_lines.append("Shadow: %s" % shadow[0])
	var consolidation := int(entry.get("consolidation", 0))
	if consolidation >= 2:
		detail_lines.append("Settling: %d" % consolidation)
	var revivals := int(entry.get("revivals", 0))
	if revivals >= 1:
		detail_lines.append("Returns: %d" % revivals)
	var successor := str(entry.get("successor_hint", "")).strip_edges()
	if not successor.is_empty():
		detail_lines.append("Revision: %s" % successor)
	return "\n".join(detail_lines)

static func _pattern_line(diagnostics: Dictionary, frame: Dictionary) -> String:
	var run_shapes := _string_array(diagnostics.get("run_shapes", []))
	var split := _string_array(frame.get("interpretation_split", []))
	if not run_shapes.is_empty() and not split.is_empty():
		return "%s under %s" % [run_shapes[0], split[0]]
	if not run_shapes.is_empty():
		return run_shapes[0]
	return _first_string(_string_array(diagnostics.get("quest_pressure", [])), "")

static func _shorthand_key(case_axes: Array[String]) -> String:
	if case_axes.is_empty():
		return ""
	var first := str(case_axes[0]).strip_edges().replace(" ", "-").to_lower()
	var second := str(_first_string(case_axes.slice(1, case_axes.size()), "")).strip_edges().replace(" ", "-").to_lower()
	return first if second.is_empty() else "%s/%s" % [first, second]

static func _build_archive_entry(case_entry: Dictionary, run_context: Dictionary) -> Dictionary:
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	return {
		"entry_id": "archive_%s" % str(case_entry.get("id", "")).strip_edges(),
		"label": str(case_entry.get("label", "Archive case")).strip_edges(),
		"entry_type": "case",
		"summary_lines": _string_array([
			str(case_entry.get("comparison_line", "")).strip_edges(),
			str(case_entry.get("world_relation_line", "")).strip_edges(),
			str(frame.get("governance_line", "")).strip_edges()
		]).slice(0, 3),
		"world_relation_line": str(case_entry.get("world_relation_line", diagnostics.get("doctrine_world_goal", ""))).strip_edges(),
		"play_routing_tags": ["witness", "artifact_custody", "route_choice", "return"]
	}

static func _normalize_entries(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var entry := Dictionary(value).duplicate(true)
		entry["entry_id"] = str(entry.get("entry_id", "")).strip_edges()
		entry["label"] = str(entry.get("label", "")).strip_edges()
		entry["entry_type"] = str(entry.get("entry_type", "case")).strip_edges()
		entry["summary_lines"] = _string_array(entry.get("summary_lines", [])).slice(0, 4)
		entry["world_relation_line"] = str(entry.get("world_relation_line", "")).strip_edges()
		entry["play_routing_tags"] = _string_array(entry.get("play_routing_tags", []))
		if not entry["entry_id"].is_empty():
			result.append(entry)
	return result.slice(0, CASE_LIMIT)

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
