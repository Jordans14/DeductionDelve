class_name EpistemicConstitution
extends RefCounted

static func validate(bundle: Dictionary) -> Array[String]:
	var counter: Dictionary = Dictionary(bundle.get("counter", {}))
	var policy: Dictionary = Dictionary(bundle.get("policy", {}))
	var violations: Array[String] = []
	var anomaly: Dictionary = Dictionary(counter.get("anomaly", {}))
	if str(anomaly.get("layer", "public")) == "public" and int(Dictionary(policy.get("ecology", {})).get("anomaly_contamination", 0)) >= 2:
		violations.append("anomaly pressure is too explicit for public-layer play")
	return violations
