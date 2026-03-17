class_name ProtocolMind
extends RefCounted

static func propose(world_model: Dictionary, _session_context: Dictionary, _planner: Dictionary, _meta: Dictionary, _counter: Dictionary) -> Dictionary:
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", ""))
	var pushes := {"social": {"obligation_pressure": 1, "coalition_visibility": 1}}
	var doctrine_biases := {"relay_pressure": 1, "burden_chain": 1}
	if protocol_state == "Exposure Protocol":
		doctrine_biases["exposure_test"] = 2
		Dictionary(pushes["social"])["hidden_role_density"] = -1
	return {"name": "protocol", "weight": 2, "doctrine_biases": doctrine_biases, "surface_pushes": pushes, "notes": ["system hierarchy"]}
