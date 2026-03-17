class_name FairnessMind
extends RefCounted

static func propose(world_model: Dictionary, _session_context: Dictionary, _planner: Dictionary, _meta: Dictionary, _counter: Dictionary) -> Dictionary:
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", ""))
	var pushes := {"economy": {"recovery_cushion": 1}, "generation": {"rescue_geometry": 1}, "social": {"hidden_role_density": -1}}
	if protocol_state == "Expedition Protocol":
		Dictionary(pushes["social"])["hidden_role_density"] = 0
	return {"name": "fairness", "weight": 3, "doctrine_biases": {}, "surface_pushes": pushes, "notes": ["anti-cheapness"]}
