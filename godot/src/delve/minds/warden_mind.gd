class_name WardenMind
extends RefCounted

static func propose(world_model: Dictionary, _session_context: Dictionary, _planner: Dictionary, _meta: Dictionary, _counter: Dictionary) -> Dictionary:
	var ecology: Dictionary = Dictionary(world_model.get("ecology_model", {}))
	var pushes := {"generation": {"bottleneck_severity": 1, "traversal_harshness": 1}, "ecology": {"inhabitant_pressure": 1}}
	if int(ecology.get("presence_pressure", 0)) >= 3:
		Dictionary(pushes["generation"])["traversal_harshness"] = 0
	return {"name": "warden", "weight": 2, "doctrine_biases": {"exposure_test": 1, "burden_chain": 1}, "surface_pushes": pushes, "notes": ["pressure discipline"]}
