class_name ExperimenterMind
extends RefCounted

static func propose(_world_model: Dictionary, _session_context: Dictionary, _planner: Dictionary, meta: Dictionary, _counter: Dictionary) -> Dictionary:
	var doctrine_biases := {}
	for doctrine_id in _string_array(meta.get("stale_doctrines", [])):
		doctrine_biases[doctrine_id] = -2
	var pushes := {"generation": {"loop_probability": 1}, "culture": {"archive_emphasis": 1}}
	return {"name": "experimenter", "weight": 2, "doctrine_biases": doctrine_biases, "surface_pushes": pushes, "notes": ["anti-stagnation"]}

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
