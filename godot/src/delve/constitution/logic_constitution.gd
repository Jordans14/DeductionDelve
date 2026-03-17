class_name LogicConstitution
extends RefCounted

static func validate(bundle: Dictionary) -> Array[String]:
	var simulation: Dictionary = Dictionary(bundle.get("simulation", {}))
	var doctrine: Dictionary = Dictionary(bundle.get("doctrine", {}))
	var policy: Dictionary = Dictionary(bundle.get("policy", {}))
	var violations: Array[String] = []
	if int(simulation.get("logic_risk", 0)) >= 3:
		violations.append("candidate breaks logic tolerance")
	var session_model: Dictionary = Dictionary(Dictionary(bundle.get("world_model", {})).get("session_model", {}))
	var protocol_state := str(session_model.get("protocol_state", ""))
	var focus_tags := _string_array(doctrine.get("focus_tags", []))
	if protocol_state == "Exposure Protocol" and focus_tags.has("crowd"):
		violations.append("crowd-focused doctrine conflicts with exposure protocol")
	if protocol_state == "Expedition Protocol" and focus_tags.has("solitude"):
		violations.append("solitude-focused doctrine conflicts with expedition protocol")
	if int(Dictionary(policy.get("generation", {})).get("loop_probability", 0)) >= 2 and int(Dictionary(policy.get("generation", {})).get("bottleneck_severity", 0)) >= 2:
		violations.append("loop and bottleneck pressure are both too extreme")
	return violations

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
