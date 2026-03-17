class_name CoherenceConstitution
extends RefCounted

static func validate(bundle: Dictionary) -> Array[String]:
	var doctrine: Dictionary = Dictionary(bundle.get("doctrine", {}))
	var policy: Dictionary = Dictionary(bundle.get("policy", {}))
	var violations: Array[String] = []
	var focus_tags := _string_array(doctrine.get("focus_tags", []))
	if focus_tags.has("ritual") and int(Dictionary(policy.get("generation", {})).get("ritual_frequency", 0)) <= -1:
		violations.append("ritual doctrine without ritual pressure is incoherent")
	if focus_tags.has("burden") and int(Dictionary(policy.get("social", {})).get("obligation_pressure", 0)) <= 0:
		violations.append("burden doctrine without obligation pressure is incoherent")
	return violations

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
