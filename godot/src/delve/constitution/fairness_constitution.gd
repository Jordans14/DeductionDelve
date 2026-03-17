class_name FairnessConstitution
extends RefCounted

static func validate(bundle: Dictionary) -> Array[String]:
	var simulation: Dictionary = Dictionary(bundle.get("simulation", {}))
	var policy: Dictionary = Dictionary(bundle.get("policy", {}))
	var violations: Array[String] = []
	if int(simulation.get("fairness_risk", 0)) >= 4:
		violations.append("policy exceeds fairness tolerance")
	var generation: Dictionary = Dictionary(policy.get("generation", {}))
	var ecology: Dictionary = Dictionary(policy.get("ecology", {}))
	var economy: Dictionary = Dictionary(policy.get("economy", {}))
	if int(generation.get("traversal_harshness", 0)) + int(ecology.get("inhabitant_pressure", 0)) + int(economy.get("resource_austerity", 0)) >= 5:
		violations.append("pressure stack is too punitive")
	if int(economy.get("recovery_cushion", 0)) <= -2 and int(generation.get("rescue_geometry", 0)) <= -1:
		violations.append("recovery routes are too constrained")
	return violations
