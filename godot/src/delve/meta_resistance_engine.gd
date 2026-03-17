class_name MetaResistanceEngine
extends RefCounted

static func evaluate(world_model: Dictionary, _session_context: Dictionary) -> Dictionary:
	var doctrine_model: Dictionary = Dictionary(world_model.get("doctrine_model", {}))
	var doctrine_counts: Dictionary = Dictionary(doctrine_model.get("doctrine_counts", {}))
	var dominant := ""
	var dominant_weight := 0
	for key in doctrine_counts.keys():
		var weight := int(doctrine_counts.get(key, 0))
		if weight > dominant_weight or (weight == dominant_weight and str(key) < dominant):
			dominant = str(key)
			dominant_weight = weight
	var stale_doctrines := _string_array(doctrine_model.get("stale_doctrines", []))
	var abandoned_paradigms := _string_array(doctrine_model.get("abandoned_paradigms", []))
	for doctrine_id in abandoned_paradigms:
		if not stale_doctrines.has(doctrine_id):
			stale_doctrines.append(doctrine_id)
	var anti_stagnation_lines: Array[String] = []
	if dominant_weight >= 3 and not dominant.is_empty():
		anti_stagnation_lines.append("recent crawls are over-answering through %s" % dominant.replace("_", " "))
	if Array(Dictionary(world_model.get("cultural_model", {})).get("field_lines", [])).size() >= 2:
		anti_stagnation_lines.append("public interpretation is starting to overfit the same field lines")
	if int(doctrine_model.get("misclassification_pressure", 0)) >= 1 and not dominant.is_empty():
		if not stale_doctrines.has(dominant):
			stale_doctrines.append(dominant)
		anti_stagnation_lines.append("%s is starting to misread live expedition behavior" % dominant.replace("_", " "))
	if int(doctrine_model.get("overcorrection_pressure", 0)) >= 1:
		anti_stagnation_lines.append("DelveMind is correcting so hard its own history is showing")
	return {
		"dominance": {"id": dominant, "weight": dominant_weight + int(doctrine_model.get("misclassification_pressure", 0))},
		"stale_doctrines": stale_doctrines,
		"anti_stagnation_lines": anti_stagnation_lines,
		"abandoned_paradigms": abandoned_paradigms,
		"misclassification_pressure": int(doctrine_model.get("misclassification_pressure", 0)),
		"overcorrection_pressure": int(doctrine_model.get("overcorrection_pressure", 0))
	}

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
