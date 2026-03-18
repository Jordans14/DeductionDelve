class_name ContradictionEngine
extends RefCounted

static func build_contradiction_records(theory_surface: Dictionary, cookbook_state: Dictionary, _world_memory: Dictionary = {}) -> Dictionary:
	var theory_ids := _string_array(theory_surface.get("theory_ids", []))
	var summary_line := "contradiction tracking remains structurally present"
	if not theory_ids.is_empty():
		summary_line = "contradiction tracking is structurally present for %d theory carriers" % theory_ids.size()
	var records: Array[Dictionary] = [{
		"record_id": "contradiction_structural_presence",
		"status": "dormant",
		"summary_lines": [summary_line]
	}]
	return {
		"records": records,
		"anti_bottleneck_report": {
			"report_id": "anti_bottleneck_structural_presence",
			"status": "dormant",
			"bottleneck_flags": [],
			"summary_lines": ["anti-bottleneck review is structurally present but inactive"]
		},
		"play_routing_report": {
			"report_id": "play_routing_structural_presence",
			"status": "dormant",
			"baseline_routes": ["movement", "burden", "rescue", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"],
			"summary_lines": ["play-routing review is structurally present but inactive"]
		},
		"meta_reflection_report": {
			"reflection_id": "meta_reflection_structural_presence",
			"status": "dormant",
			"summary_lines": ["meta-reflection is structurally present but inactive"]
		}
	}

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
