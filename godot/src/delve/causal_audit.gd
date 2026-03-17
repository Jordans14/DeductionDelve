class_name DelveCausalAudit
extends RefCounted

static func build(seed_value: int, doctrine: Dictionary, policy: Dictionary, planner: Dictionary, world_model: Dictionary, mind_balance: Dictionary, simulation: Dictionary, violations: Array[String], meta: Dictionary, counter: Dictionary, run_identity: Dictionary = {}) -> Dictionary:
	return {
		"seed": seed_value,
		"doctrine": str(doctrine.get("id", "")),
		"doctrine_label": str(doctrine.get("label", "")),
		"policy": policy.duplicate(true),
		"planner": planner.duplicate(true),
		"mind_balance": mind_balance.duplicate(true),
		"simulation": simulation.duplicate(true),
		"violations": violations.duplicate(),
		"meta": meta.duplicate(true),
		"counter": counter.duplicate(true),
		"run_identity": run_identity.duplicate(true),
		"world_focus": str(world_model.get("world_focus", "")),
		"protocol_state": str(Dictionary(world_model.get("session_model", {})).get("protocol_state", ""))
	}
