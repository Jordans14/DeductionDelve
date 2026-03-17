class_name MythMind
extends RefCounted

static func propose(world_model: Dictionary, _session_context: Dictionary, _planner: Dictionary, _meta: Dictionary, _counter: Dictionary) -> Dictionary:
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var pushes := {"culture": {"public_heat_bias": 1, "archive_emphasis": 1}, "generation": {"ritual_frequency": 1}}
	if int(cultural.get("myth_gravity", 0)) >= 7:
		Dictionary(pushes["culture"])["public_heat_bias"] = 0
	return {"name": "myth", "weight": 1, "doctrine_biases": {"custody_ritual": 1, "witness_pressure": 1}, "surface_pushes": pushes, "notes": ["symbolic recurrence"]}
