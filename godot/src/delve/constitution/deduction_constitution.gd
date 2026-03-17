class_name DeductionConstitution
extends RefCounted

static func validate(bundle: Dictionary) -> Array[String]:
	var simulation: Dictionary = Dictionary(bundle.get("simulation", {}))
	var violations: Array[String] = []
	if int(simulation.get("deduction_clarity", 0)) <= 1:
		violations.append("deduction clarity fell below minimum")
	if int(simulation.get("ambiguity_quality", 0)) <= 0:
		violations.append("ambiguity collapsed into noise")
	return violations
