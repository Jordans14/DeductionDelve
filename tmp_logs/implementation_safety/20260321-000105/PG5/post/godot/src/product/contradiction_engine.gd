class_name ContradictionEngine
extends RefCounted

const BASELINE_ROUTES := ["movement", "burden", "rescue", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"]

static func build_contradiction_records(theory_surface: Dictionary, cookbook_state: Dictionary, world_memory: Dictionary = {}) -> Dictionary:
	var theories := _dict_array(theory_surface.get("theories", []))
	var theory_ids := _string_array(theory_surface.get("theory_ids", []))
	var statuses := _string_array(theory_surface.get("statuses", []))
	var world_mutations := _dict_array(world_memory.get("world_mutations", []))
	var factions := _dict_array(world_memory.get("factions", []))
	var regimes := _dict_array(world_memory.get("interpretation_regimes", []))
	var cookbook_fragments := _dict_array(cookbook_state.get("fragments", []))
	var records: Array[Dictionary] = []
	if statuses.has("official") and statuses.has("rival"):
		records.append(_record(
			"contradiction_theory_rivalry",
			"active",
			["official and rival theories are both claiming public legitimacy"],
			["theory", "governance", "archive"],
			["witness", "route_choice", "artifact_custody", "return"],
			["theory_surface", "world_memory.factions", "world_memory.interpretation_regimes"]
		))
	if statuses.has("cookbook"):
		records.append(_record(
			"contradiction_cookbook_pressure",
			"active",
			["cookbook theories are exploiting the same route and custody pressures that official readings claim to govern"],
			["cookbook", "theory", "governance"],
			["movement", "burden", "artifact_custody", "hesitation", "return"],
			["cookbook_state", "theory_surface", "world_memory"]
		))
	if factions.size() >= 2 or regimes.size() >= 2:
		records.append(_record(
			"contradiction_civilization_plurality",
			"active",
			["multiple factions or regimes now disagree over adoption, legitimacy, or public interpretation"],
			["civilization", "archive", "governance"],
			["witness", "artifact_custody", "route_choice", "return"],
			["world_memory.factions", "world_memory.interpretation_regimes"]
		))
	if not world_mutations.is_empty():
		records.append(_record(
			"contradiction_world_scars",
			"active",
			["persistent world mutations are now contesting what the next expedition should inherit"],
			["world_mutation", "governance", "constitution"],
			["route_choice", "artifact_custody", "extraction", "return"],
			["world_memory.world_mutations", "world_memory.residue_records"]
		))
	if records.is_empty():
		records.append(_record(
			"contradiction_minor_variance",
			"stable",
			["no dominant contradiction currently exceeds the governance threshold"],
			["governance"],
			BASELINE_ROUTES,
			["theory_surface", "world_memory"]
		))
	var monopoly_flags: Array[String] = []
	if theory_ids.size() <= 1 or (statuses.size() <= 1 and theory_ids.size() >= 1):
		monopoly_flags.append("theory_monopoly")
	if factions.size() <= 1:
		monopoly_flags.append("interpretation_monopoly")
	var route_coverage := _route_coverage(theories, cookbook_fragments, world_mutations, records)
	var missing_routes: Array[String] = []
	for route in BASELINE_ROUTES:
		if not route_coverage.has(route):
			missing_routes.append(route)
	var contradiction_heat := clampi(
		maxi(int(Dictionary(world_memory.get("interpretation_network", {})).get("contradiction_heat", 0)), 0)
		+ maxi(records.size() - 1, 0),
		0,
		12
	)
	return {
		"records": records,
		"contradiction_heat": contradiction_heat,
		"source_refs": ["theory_surface", "cookbook_state", "world_memory"],
		"summary_lines": _summary_lines(records, 3),
		"anti_bottleneck_report": {
			"report_id": "anti_bottleneck_%s" % str(records.size()),
			"status": "blocked" if not monopoly_flags.is_empty() else "stable",
			"bottleneck_flags": monopoly_flags,
			"summary_lines": [
				"anti-bottleneck review %s" % ("detected theory or interpretation monopoly" if not monopoly_flags.is_empty() else "found no single-owner doctrine monopoly")
			]
		},
		"play_routing_report": {
			"report_id": "play_routing_%s" % str(records.size()),
			"status": "blocked" if not missing_routes.is_empty() else "stable",
			"baseline_routes": BASELINE_ROUTES.duplicate(),
			"missing_routes": missing_routes,
			"summary_lines": [
				"play-routing %s" % ("lost coverage for %s" % ", ".join(missing_routes) if not missing_routes.is_empty() else "kept every doctrine layer tied to embodied play")
			]
		},
		"meta_reflection_report": {
			"reflection_id": "meta_reflection_%s" % str(records.size()),
			"status": "cooling" if statuses.has("cookbook") or statuses.has("anomaly") else "stable",
			"summary_lines": [
				"meta-reflection is tracking %d live contradiction vectors across theory, civilization, cookbook, and world mutation" % records.size()
			]
		}
	}

static func _route_coverage(theories: Array[Dictionary], fragments: Array[Dictionary], world_mutations: Array[Dictionary], records: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for entry in theories:
		result = _string_array(result + _string_array(Dictionary(entry).get("play_routing_tags", [])))
	for entry in fragments:
		result = _string_array(result + _string_array(Dictionary(entry).get("play_routing_tags", [])))
	for entry in world_mutations:
		result = _string_array(result + _string_array(Dictionary(entry).get("play_routing_tags", [])))
	for entry in records:
		result = _string_array(result + _string_array(Dictionary(entry).get("play_routing_tags", [])))
	return result

static func _record(record_id: String, status: String, summary_lines: Array, affected_systems: Array, play_routing_tags: Array, source_refs: Array = []) -> Dictionary:
	return {
		"record_id": record_id,
		"status": status,
		"summary_lines": _string_array(summary_lines),
		"affected_systems": _string_array(affected_systems),
		"play_routing_tags": _string_array(play_routing_tags),
		"source_refs": _string_array(source_refs)
	}

static func _summary_lines(records: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for record_raw in _dict_array(records):
		for line in _string_array(Dictionary(record_raw).get("summary_lines", [])):
			if not result.has(line):
				result.append(line)
			if result.size() >= limit:
				return result
	return result

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
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
