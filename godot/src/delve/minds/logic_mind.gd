class_name LogicMind
extends RefCounted

static func propose(world_model: Dictionary, _session_context: Dictionary, _planner: Dictionary, _meta: Dictionary, _counter: Dictionary) -> Dictionary:
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", ""))
	var pushes := {"generation": {"witness_exposure": 1}, "social": {"private_evidence_ratio": 0, "blame_ambiguity": 0}}
	if protocol_state == "Exposure Protocol":
		Dictionary(pushes["generation"])["witness_exposure"] = 0
		Dictionary(pushes["social"])["private_evidence_ratio"] = 1
	return {"name": "logic", "weight": 3, "doctrine_biases": {"witness_pressure": 1, "split_truth": 1}, "surface_pushes": pushes, "notes": ["causal coherence"]}
