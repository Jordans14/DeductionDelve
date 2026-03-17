class_name DelveSimulator
extends RefCounted

static func evaluate(world_model: Dictionary, session_context: Dictionary, doctrine: Dictionary, policy: Dictionary, meta: Dictionary = {}, counter: Dictionary = {}) -> Dictionary:
	var social: Dictionary = Dictionary(policy.get("social", {}))
	var generation: Dictionary = Dictionary(policy.get("generation", {}))
	var ecology: Dictionary = Dictionary(policy.get("ecology", {}))
	var economy: Dictionary = Dictionary(policy.get("economy", {}))
	var doctrine_focus := _string_array(doctrine.get("focus_tags", []))
	var run_identity: Dictionary = Dictionary(doctrine.get("run_identity", {}))
	var pacing_profile: Dictionary = Dictionary(run_identity.get("pacing_profile", {}))
	var group_tension_bias: Dictionary = Dictionary(run_identity.get("group_tension_bias", {}))
	var archive_interpretation: Dictionary = Dictionary(run_identity.get("archive_interpretation", {}))
	var pressure_ids := _entry_ids(Array(run_identity.get("pressure_grammar", [])))
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", session_context.get("protocol_state", "")))
	var deduction_clarity := 4 + int(generation.get("witness_exposure", 0)) - int(social.get("private_evidence_ratio", 0)) - int(social.get("hidden_role_density", 0))
	if doctrine_focus.has("public_read"):
		deduction_clarity += 1
	if protocol_state == "Exposure Protocol":
		deduction_clarity += 1
	if pressure_ids.has("exposure") or pressure_ids.has("convergence"):
		deduction_clarity += 1
	if pressure_ids.has("route_doubt") and pressure_ids.has("misdirection"):
		deduction_clarity -= 1
	var rescue_viability := 3 + int(generation.get("rescue_geometry", 0)) + int(economy.get("recovery_cushion", 0)) - int(generation.get("bottleneck_severity", 0)) - int(ecology.get("inhabitant_pressure", 0))
	if str(Dictionary(run_identity.get("convergence_fragmentation", {})).get("axis", "")) == "convergence":
		rescue_viability += 1
	var ambiguity_quality := 3 + int(social.get("blame_ambiguity", 0)) + int(social.get("private_evidence_ratio", 0)) - int(social.get("hidden_role_density", 0))
	if doctrine_focus.has("split_read"):
		ambiguity_quality += 1
	if pressure_ids.has("fragmentation") or pressure_ids.has("misdirection"):
		ambiguity_quality += 1
	ambiguity_quality += mini(int(group_tension_bias.get("ambiguous_cause", 0)), 1)
	var myth_weight := 2 + int(Dictionary(policy.get("culture", {})).get("public_heat_bias", 0)) + int(Dictionary(policy.get("culture", {})).get("archive_emphasis", 0))
	if doctrine_focus.has("ritual") or doctrine_focus.has("burden"):
		myth_weight += 1
	if not str(archive_interpretation.get("tone", "")).strip_edges().is_empty():
		myth_weight += 1
	var fairness_risk := maxi(int(generation.get("traversal_harshness", 0)), 0) + maxi(int(ecology.get("inhabitant_pressure", 0)), 0) + maxi(int(economy.get("resource_austerity", 0)), 0) - maxi(int(economy.get("recovery_cushion", 0)), 0)
	if str(pacing_profile.get("id", "")) == "volatile":
		fairness_risk += 1
	var logic_risk := 0
	if protocol_state == "Exposure Protocol" and doctrine_focus.has("crowd"):
		logic_risk += 2
	if protocol_state == "Expedition Protocol" and doctrine_focus.has("solitude"):
		logic_risk += 2
	var stagnation_risk := int(Dictionary(meta.get("dominance", {})).get("weight", 0))
	if Array(meta.get("stale_doctrines", [])).has(str(doctrine.get("id", ""))):
		stagnation_risk += 2
	if not str(Dictionary(counter.get("anomaly", {})).get("pressure", "")).strip_edges().is_empty():
		logic_risk += 1 if int(Dictionary(policy.get("ecology", {})).get("anomaly_contamination", 0)) > 1 else 0
	var total_score := deduction_clarity * 3 + rescue_viability * 2 + ambiguity_quality * 2 + myth_weight * 2 - fairness_risk * 4 - logic_risk * 4 - stagnation_risk * 3
	return {
		"deduction_clarity": deduction_clarity,
		"rescue_viability": rescue_viability,
		"ambiguity_quality": ambiguity_quality,
		"myth_weight": myth_weight,
		"fairness_risk": fairness_risk,
		"logic_risk": logic_risk,
		"stagnation_risk": stagnation_risk,
		"total_score": total_score
	}

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _entry_ids(entries: Array) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var id := str(entry.get("id", "")).strip_edges()
		if not id.is_empty() and not result.has(id):
			result.append(id)
	return result
