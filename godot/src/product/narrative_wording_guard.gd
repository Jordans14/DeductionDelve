class_name NarrativeWordingGuard
extends RefCounted

const BASE_REPLACEMENTS := {
	"experiment": "pattern",
	"experiments": "patterns",
	"observer": "watcher",
	"observers": "watchers",
	"behavioral system": "pressure pattern",
	"behavioral systems": "pressure patterns",
	"behavioral experiment": "pressure pattern",
	"behavioral experiments": "pressure patterns",
	"behavioral trial": "pressure pattern",
	"behavioral trials": "pressure patterns",
	"test subject": "delver",
	"test subjects": "delvers",
	"control group": "delve cluster",
	"control groups": "delve clusters",
	"planetary system": "labyrinth",
	"planetary-scale": "world-spanning",
	"simulation": "broadcast frame",
	"experimental protocol": "pressure ritual",
	"experimental protocols": "pressure rituals",
	"observer-adjacent": "unsettling",
	"behavioral": "patterned",
	"meta layer": "late layer",
	"run identity": "run signal",
	"causal audit": "pressure reading",
	"mind balance": "reading balance",
	"control surface": "pressure line",
	"control surfaces": "pressure lines",
	"planner": "routing frame",
	"world goal": "world pull"
}

static func guard_text(text: String) -> String:
	var safe_text := text
	for token in BASE_REPLACEMENTS.keys():
		safe_text = _replace_case_variants(safe_text, str(token), str(BASE_REPLACEMENTS[token]))
	return safe_text

static func guard_lines(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(guard_text(str(value)))
	return result

static func guard_entry(entry: Dictionary) -> Dictionary:
	var next := entry.duplicate(true)
	for key in [
		"label",
		"detail",
		"summary",
		"title",
		"headline",
		"subhead",
		"compare",
		"field",
		"reading",
		"comparison_line",
		"continuity_line",
		"world_relation_line",
		"retell_line",
		"watch_next",
		"school_line",
		"challenge_attention",
		"ritual_pressure",
		"world_pull",
		"delve_trace",
		"belief_line",
		"counterfactual_line",
		"curriculum_line",
		"anomaly_pull",
		"build_line",
		"resource_line",
		"inhabitant_line",
		"school_tension",
		"legend_hint",
		"challenge_hint",
		"crew_tag",
		"build_hint",
		"presence_hint"
	]:
		if next.has(key):
			next[key] = guard_text(str(next.get(key, "")))
	return next

static func guard_entries(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in entries:
		if value is Dictionary:
			result.append(guard_entry(Dictionary(value)))
	return result

static func guard_packet(packet: Dictionary, keys: Array[String]) -> Dictionary:
	var next := packet.duplicate(true)
	for key in keys:
		if not next.has(key):
			continue
		var value = next.get(key)
		if value is String:
			next[key] = guard_text(str(value))
		elif value is Array:
			next[key] = guard_lines(Array(value))
	return next

static func _replace_case_variants(text: String, token: String, replacement: String) -> String:
	var next := text.replace(token, replacement)
	next = next.replace(token.capitalize(), replacement.capitalize())
	next = next.replace(token.to_upper(), replacement.to_upper())
	return next
