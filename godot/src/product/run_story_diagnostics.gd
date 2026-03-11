class_name RunStoryDiagnostics
extends RefCounted

static func analyze(run_record: Dictionary) -> Dictionary:
	var key_clues: Array = Array(run_record.get("key_clues", []))
	var action_summary: Array = Array(run_record.get("action_summary", []))
	var communication_summary: Dictionary = Dictionary(run_record.get("communication_summary", {}))
	var route_commits := 0
	var pressure_beats := 0
	var clue_beats := 0
	var artifact_beats := 0
	var suspicion_beats := 0
	var communication_beats := int(communication_summary.get("total", 0))
	var danger_callouts := int(communication_summary.get("danger", 0))
	var regroup_callouts := int(communication_summary.get("regroup", 0))
	var artifact_callouts := int(communication_summary.get("artifact", 0))
	var interrupted := bool(run_record.get("interrupted", false))
	var wait_for_lobby := bool(run_record.get("session_wait_for_lobby", false))
	var reconnect_ready := bool(run_record.get("session_reconnect_ready", false))
	for line_variant in key_clues:
		var line := str(line_variant)
		route_commits += _keyword_hits(line, ["zipline", "rope", "route", "reroute"])
		pressure_beats += _keyword_hits(line, ["extraction", "trap", "ghost", "blast"])
		clue_beats += _keyword_hits(line, ["inspect", "decoy", "noise", "mark", "pulse"])
		artifact_beats += _keyword_hits(line, ["artifact", "counterfeit", "authentic"])
	for line_variant in action_summary:
		var line := str(line_variant)
		suspicion_beats += _keyword_hits(line, ["pinned", "inspected", "rerouted", "decoy", "route", "trap", "blast", "callout"])
	var story_density := key_clues.size() + action_summary.size() + communication_beats
	var story_tone := "Quiet"
	if story_density >= 10 or suspicion_beats >= 5:
		story_tone = "Chaotic"
	elif story_density >= 6 or suspicion_beats >= 3:
		story_tone = "Charged"
	elif interrupted:
		story_tone = "Disrupted"
	return {
		"route_commits": route_commits,
		"pressure_beats": pressure_beats,
		"clue_beats": clue_beats,
		"artifact_beats": artifact_beats,
		"suspicion_beats": suspicion_beats,
		"communication_beats": communication_beats,
		"danger_callouts": danger_callouts,
		"regroup_callouts": regroup_callouts,
		"artifact_callouts": artifact_callouts,
		"interrupted": interrupted,
		"wait_for_lobby": wait_for_lobby,
		"reconnect_ready": reconnect_ready,
		"story_density": story_density,
		"story_tone": story_tone
	}

static func build_summary_lines(diagnostics: Dictionary) -> Array[String]:
	var lines: Array[String] = [
		"Story tone: %s" % str(diagnostics.get("story_tone", "Quiet")),
		"Suspicion beats: %d | Route commits: %d" % [int(diagnostics.get("suspicion_beats", 0)), int(diagnostics.get("route_commits", 0))],
		"Pressure beats: %d | Artifact beats: %d" % [int(diagnostics.get("pressure_beats", 0)), int(diagnostics.get("artifact_beats", 0))]
	]
	var communication_beats := int(diagnostics.get("communication_beats", 0))
	if communication_beats > 0:
		lines.append("Callouts: %d | Danger %d | Regroup %d | Artifact %d" % [
			communication_beats,
			int(diagnostics.get("danger_callouts", 0)),
			int(diagnostics.get("regroup_callouts", 0)),
			int(diagnostics.get("artifact_callouts", 0))
		])
	if bool(diagnostics.get("interrupted", false)):
		lines.append("Session: Interrupted%s" % [" | Wait for lobby" if bool(diagnostics.get("wait_for_lobby", false)) else ""])
	return lines

static func build_review_lines(diagnostics: Dictionary) -> Array[String]:
	var lines := build_summary_lines(diagnostics)
	lines.append("Why revisit: %s" % build_memorable_reason(diagnostics))
	if bool(diagnostics.get("interrupted", false)) and bool(diagnostics.get("reconnect_ready", false)):
		lines.append("Reconnect: Offer ready")
	elif bool(diagnostics.get("interrupted", false)):
		lines.append("Reconnect: Review only")
	var has_session_line := false
	for line_variant in lines:
		if str(line_variant).begins_with("Session:"):
			has_session_line = true
			break
	if not has_session_line:
		lines.append("Session: Completed normally")
	return lines

static func build_highlight_tags(diagnostics: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var story_tone := str(diagnostics.get("story_tone", "Quiet"))
	if story_tone != "" and story_tone != "Quiet":
		tags.append(story_tone)
	if bool(diagnostics.get("interrupted", false)) and not tags.has("Interrupted"):
		tags.append("Interrupted")
	var communication_beats := int(diagnostics.get("communication_beats", 0))
	if communication_beats > 0:
		tags.append("%d callouts" % communication_beats)
	var route_commits := int(diagnostics.get("route_commits", 0))
	if route_commits > 0:
		tags.append("%d route shifts" % route_commits)
	var pressure_beats := int(diagnostics.get("pressure_beats", 0))
	if pressure_beats > 0:
		tags.append("%d pressure" % pressure_beats)
	if tags.is_empty():
		tags.append("Steady")
	return tags

static func build_memorable_reason(diagnostics: Dictionary) -> String:
	var communication_beats := int(diagnostics.get("communication_beats", 0))
	var route_commits := int(diagnostics.get("route_commits", 0))
	var pressure_beats := int(diagnostics.get("pressure_beats", 0))
	var artifact_beats := int(diagnostics.get("artifact_beats", 0))
	if bool(diagnostics.get("interrupted", false)):
		return "Interrupted after %d public callouts" % communication_beats if communication_beats > 0 else "Interrupted before the run could resolve"
	if str(diagnostics.get("story_tone", "Quiet")) == "Chaotic":
		if route_commits > 0:
			return "Route changes and pressure stacked up fast"
		return "Multiple suspicious beats landed in one run"
	if communication_beats >= 2:
		return "Frequent callouts shaped how the team read the run"
	if route_commits >= 2:
		return "Traversal tools changed the route story repeatedly"
	if pressure_beats >= 2:
		return "Pressure beats forced late bad choices"
	if artifact_beats > 0:
		return "Artifact handling stayed central to the story"
	return "A quieter run with fewer public tells"

static func build_revisit_worthiness_band(diagnostics: Dictionary) -> String:
	var score := revisit_worthiness_score(diagnostics)
	if score >= 8:
		return "High"
	if score >= 4:
		return "Medium"
	return "Low"

static func revisit_worthiness_score(diagnostics: Dictionary) -> int:
	var score := dramatic_intensity_rank(diagnostics) * 2
	score += communication_density_rank(diagnostics)
	score += mini(int(diagnostics.get("pressure_beats", 0)), 2)
	if bool(diagnostics.get("interrupted", false)):
		score += 2
	if int(diagnostics.get("artifact_beats", 0)) > 0 and int(diagnostics.get("clue_beats", 0)) > 0:
		score += 1
	return score

static func build_revisit_worthiness_reason(diagnostics: Dictionary) -> String:
	if bool(diagnostics.get("interrupted", false)):
		if bool(diagnostics.get("wait_for_lobby", false)):
			return "interruption review plus lobby regroup context"
		if bool(diagnostics.get("reconnect_ready", false)):
			return "interruption review with reconnect context"
		return "interruption review still unresolved"
	if communication_density_rank(diagnostics) >= 2 and dramatic_intensity_rank(diagnostics) >= 2:
		return "high callout pressure with a sharp dramatic swing"
	if communication_density_rank(diagnostics) >= 2:
		return "callout-heavy public read"
	if dramatic_intensity_rank(diagnostics) >= 2:
		return "dramatic pressure beats worth re-reading"
	if int(diagnostics.get("artifact_beats", 0)) > 0:
		return "artifact handling stayed central"
	return "light recap value"

static func build_communication_density_band(diagnostics: Dictionary) -> String:
	match communication_density_rank(diagnostics):
		3:
			return "Heavy"
		2:
			return "Active"
		1:
			return "Light"
		_:
			return "Quiet"

static func communication_density_rank(diagnostics: Dictionary) -> int:
	var communication_beats := int(diagnostics.get("communication_beats", 0))
	if communication_beats >= 4:
		return 3
	if communication_beats >= 2:
		return 2
	if communication_beats >= 1:
		return 1
	return 0

static func build_dramatic_intensity_band(diagnostics: Dictionary) -> String:
	match dramatic_intensity_rank(diagnostics):
		3:
			return "Volatile"
		2:
			return "Heated"
		1:
			return "Uneasy"
		_:
			return "Steady"

static func dramatic_intensity_rank(diagnostics: Dictionary) -> int:
	if bool(diagnostics.get("interrupted", false)):
		return 3
	match str(diagnostics.get("story_tone", "Quiet")):
		"Chaotic":
			return 3
		"Charged":
			return 2
		"Disrupted":
			return 2
		_:
			return 1 if int(diagnostics.get("pressure_beats", 0)) > 0 or int(diagnostics.get("artifact_beats", 0)) > 0 else 0

static func build_interruption_context(diagnostics: Dictionary) -> String:
	if not bool(diagnostics.get("interrupted", false)):
		return "Completed"
	if bool(diagnostics.get("wait_for_lobby", false)):
		return "Wait for lobby"
	if bool(diagnostics.get("reconnect_ready", false)):
		return "Reconnect ready"
	return "Review only"

static func build_interruption_pattern_bucket(diagnostics: Dictionary) -> String:
	if not bool(diagnostics.get("interrupted", false)):
		return "Completed"
	if bool(diagnostics.get("wait_for_lobby", false)):
		return "Wait-lobby interruption"
	if bool(diagnostics.get("reconnect_ready", false)):
		return "Reconnect-ready interruption"
	return "Review-only interruption"

static func build_run_cluster_label(diagnostics: Dictionary) -> String:
	if bool(diagnostics.get("interrupted", false)):
		if bool(diagnostics.get("wait_for_lobby", false)):
			return "Lobby-gated interruption"
		if bool(diagnostics.get("reconnect_ready", false)):
			return "Reconnect-safe interruption"
		return "Review-only interruption"
	if communication_density_rank(diagnostics) >= 2 and dramatic_intensity_rank(diagnostics) >= 2:
		return "High-signal chaos"
	if communication_density_rank(diagnostics) >= 2:
		return "Callout-heavy"
	if dramatic_intensity_rank(diagnostics) >= 2:
		return "Pressure-heavy"
	if int(diagnostics.get("artifact_beats", 0)) > 0 and int(diagnostics.get("clue_beats", 0)) > 0:
		return "Artifact clue run"
	if int(diagnostics.get("artifact_beats", 0)) > 0:
		return "Artifact-centered"
	return "Steady"

static func build_signal_stack(diagnostics: Dictionary) -> String:
	return "%s | %s | %s" % [
		build_revisit_worthiness_band(diagnostics),
		build_dramatic_intensity_band(diagnostics),
		build_communication_density_band(diagnostics)
	]

static func build_debug_lines(diagnostics: Dictionary) -> Array[String]:
	return [
		"story_density=%d" % int(diagnostics.get("story_density", 0)),
		"clue_beats=%d" % int(diagnostics.get("clue_beats", 0)),
		"suspicion_beats=%d" % int(diagnostics.get("suspicion_beats", 0)),
		"communication_beats=%d" % int(diagnostics.get("communication_beats", 0)),
		"interrupted=%s" % str(bool(diagnostics.get("interrupted", false))).to_lower()
	]

static func _keyword_hits(text: String, keywords: Array[String]) -> int:
	var normalized := text.to_lower()
	var hits := 0
	for keyword in keywords:
		if normalized.find(keyword) != -1:
			hits += 1
	return hits
