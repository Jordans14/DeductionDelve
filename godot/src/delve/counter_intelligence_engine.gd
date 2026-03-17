class_name CounterIntelligenceEngine
extends RefCounted

static func evaluate(profile: Dictionary, world_model: Dictionary, _session_context: Dictionary) -> Dictionary:
	var progress: Dictionary = Dictionary(profile.get("narrative_progress", {}))
	var layer := str(progress.get("layer", "public"))
	var world_memory: Dictionary = Dictionary(profile.get("world_memory", {}))
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	var anomaly_pressure := ""
	if int(fascination.get("streak", 0)) >= 3 and layer != "public":
		anomaly_pressure = "repeated pressure lines are no longer staying in their expected place"
	var anti_consensus := ""
	if int(Dictionary(world_model.get("social_model", {})).get("fault_recurrence", 0)) >= 4:
		anti_consensus = "group answers keep splitting along the same hidden seams"
	return {
		"anomaly": {
			"pressure": anomaly_pressure,
			"anti_consensus": anti_consensus,
			"layer": layer
		}
	}
