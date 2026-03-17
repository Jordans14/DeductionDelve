class_name LegibilityConstitution
extends RefCounted

static func validate(bundle: Dictionary) -> Array[String]:
	var policy: Dictionary = Dictionary(bundle.get("policy", {}))
	var social: Dictionary = Dictionary(policy.get("social", {}))
	var violations: Array[String] = []
	if int(social.get("private_evidence_ratio", 0)) >= 2 and int(social.get("blame_ambiguity", 0)) >= 2 and int(social.get("hidden_role_density", 0)) >= 1:
		violations.append("too much ambiguity for a readable public game")
	if int(Dictionary(policy.get("generation", {})).get("witness_exposure", 0)) <= -2 and int(social.get("private_evidence_ratio", 0)) >= 1:
		violations.append("evidence visibility is too suppressed")
	return violations
