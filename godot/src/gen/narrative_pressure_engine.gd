class_name NarrativePressureEngine
extends RefCounted

const SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")

static func build_state(
	world_model: Dictionary,
	doctrine: Dictionary,
	public_summary: Dictionary,
	generation_surface: Dictionary,
	ontology_snapshot: Dictionary = {},
	doctrine_family: Dictionary = {},
	simulation: Dictionary = {},
	experimental_ontology_state: Dictionary = {}
) -> Dictionary:
	var schema := SCHEMA_REGISTRY_SCRIPT.narrative_pressure_schema()
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var social: Dictionary = Dictionary(world_model.get("social_model", {}))
	var route: Dictionary = Dictionary(world_model.get("route_model", {}))
	var economy: Dictionary = Dictionary(world_model.get("economy_model", {}))
	var epoch: Dictionary = Dictionary(world_model.get("epoch_model", {}))
	var axes := {
		"stability": _band(
			int(cultural.get("legitimacy_pressure", 0))
			+ int(cultural.get("custody_pressure", 0))
			+ int(cultural.get("sacred_pressure", 0))
			+ int(social.get("alliance_stability", 0))
		),
		"disruption": _band(
			int(cultural.get("revision_pressure", 0))
			+ int(cultural.get("false_canon_pressure", 0))
			+ int(cultural.get("contradiction_heat", 0))
			+ int(cultural.get("rumor_shock_pressure", 0))
			+ int(cultural.get("counterfactual_heat", 0))
		),
		"authority": _band(
			int(cultural.get("legitimacy_pressure", 0))
			+ int(cultural.get("orthodoxy_strength", 0))
			+ int(cultural.get("administrative_pressure", 0))
			+ int(cultural.get("institutional_campaigns", 0))
		),
		"skepticism": _band(
			int(cultural.get("revision_pressure", 0))
			+ int(cultural.get("false_canon_pressure", 0))
			+ int(cultural.get("semantic_drift", 0))
			+ int(social.get("trust_fragility", 0))
		),
		"fear": _band(
			int(cultural.get("paranoia_heat", 0))
			+ int(cultural.get("taboo_heat", 0))
			+ int(cultural.get("punitive_heat", 0))
			+ int(cultural.get("relay_bottleneck_pressure", 0))
		),
		"curiosity": _band(
			int(cultural.get("counterfactual_heat", 0))
			+ int(cultural.get("hope_heat", 0))
			+ int(world_model.get("archive_legends", 0))
			+ (2 if not str(world_model.get("world_focus", "")).strip_edges().is_empty() else 0)
		),
		"certainty": _band(
			int(cultural.get("orthodoxy_strength", 0))
			+ int(cultural.get("legitimacy_pressure", 0))
			+ int(cultural.get("witness_network_pressure", 0))
			+ (1 if not str(cultural.get("dominant_tradition", "")).strip_edges().is_empty() else 0)
		),
		"ambiguity": _band(
			int(cultural.get("semantic_drift", 0))
			+ int(cultural.get("false_canon_pressure", 0))
			+ int(cultural.get("contradiction_heat", 0))
			+ (2 if not str(cultural.get("uncertainty_philosophy", "")).strip_edges().is_empty() else 0)
		),
		"ritual": _band(
			int(cultural.get("burial_pressure", 0))
			+ int(cultural.get("sacred_pressure", 0))
			+ int(cultural.get("ritual_spread", 0))
			+ int(cultural.get("custody_pressure", 0))
		),
		"innovation": _band(
			int(cultural.get("counterfactual_heat", 0))
			+ int(cultural.get("revision_pressure", 0))
			+ int(cultural.get("semantic_drift", 0))
			+ int(epoch.get("transition_pressure", 0))
		),
		"extraction": _band(
			int(route.get("route_control", 0))
			+ int(economy.get("recovery_appetite", 0))
			+ int(cultural.get("practical_pressure", 0))
			+ int(route.get("relay_stress", 0))
		),
		"stewardship": _band(
			int(cultural.get("custody_pressure", 0))
			+ int(cultural.get("burial_pressure", 0))
			+ int(social.get("rescue_expectation", 0))
			+ int(economy.get("burden_tolerance", 0))
		)
	}
	axes = _apply_experiment_pressure_bias(axes, experimental_ontology_state)
	var momentum := _band(
		int(epoch.get("transition_pressure", 0))
		+ int(cultural.get("spread_heat", 0))
		+ int(route.get("relay_stress", 0))
		+ int(world_model.get("crawl_density", 0))
		+ (2 if str(world_model.get("world_phase", "")).strip_edges() == "turning" else 0)
	)
	var resonance := _band(
		int(cultural.get("myth_gravity", 0))
		+ int(world_model.get("archive_legends", 0))
		+ Array(ontology_snapshot.get("public_lines", [])).size()
		+ (2 if not str(world_model.get("world_focus", "")).strip_edges().is_empty() else 0)
	)
	var cascade_risk := _band(
		int(cultural.get("contradiction_heat", 0))
		+ int(cultural.get("spread_heat", 0))
		+ int(cultural.get("false_canon_pressure", 0))
		+ int(cultural.get("rumor_shock_pressure", 0))
		+ momentum
		+ resonance
	)
	var dominant_tensions := _dominant_tensions(axes)
	var pressure_family := _pressure_family(axes, dominant_tensions, generation_surface, doctrine_family)
	var generation_weighting := _build_generation_weighting(pressure_family, axes, momentum, resonance, cascade_risk)
	var constitution_bias := _build_constitution_bias(pressure_family, dominant_tensions, momentum, resonance, cascade_risk)
	var archive_bias := _build_archive_bias(pressure_family, dominant_tensions, resonance, cascade_risk, public_summary)
	var trace := {
		"doctrine_family": str(doctrine.get("id", "")),
		"lineage_id": str(doctrine_family.get("lineage_id", "")),
		"branch_family": str(generation_surface.get("branch_family", "")),
		"world_phase": str(world_model.get("world_phase", "")),
		"epoch_phase": str(epoch.get("phase", "")),
		"world_focus": str(world_model.get("world_focus", "")),
		"dominant_domains": _string_array(ontology_snapshot.get("dominant_domains", [])),
		"cultural_sources": {
			"legitimacy_pressure": int(cultural.get("legitimacy_pressure", 0)),
			"revision_pressure": int(cultural.get("revision_pressure", 0)),
			"contradiction_heat": int(cultural.get("contradiction_heat", 0)),
			"sacred_pressure": int(cultural.get("sacred_pressure", 0)),
			"counterfactual_heat": int(cultural.get("counterfactual_heat", 0)),
			"relay_stress": int(route.get("relay_stress", 0))
		},
		"simulation_hints": {
			"fairness_risk": int(simulation.get("fairness_risk", 0)),
			"logic_risk": int(simulation.get("logic_risk", 0))
		},
		"experiment_families": _string_array(experimental_ontology_state.get("dominant_families", [])),
		"experiment_expression_modes": _string_array(Dictionary(experimental_ontology_state.get("public_surface", {})).get("expression_modes", [])),
		"experiment_pressure_bias": Dictionary(Dictionary(experimental_ontology_state.get("compile_outputs", {})).get("pressure_input_bias", {})).duplicate(true)
	}
	var state := {
		"schema_name": str(schema.get("schema_name", "NarrativePressureState")),
		"schema_version": int(schema.get("schema_version", 1)),
		"id": _build_state_id(doctrine, pressure_family, dominant_tensions, generation_surface),
		"pressure_family": pressure_family,
		"stability": int(axes.get("stability", 0)),
		"disruption": int(axes.get("disruption", 0)),
		"authority": int(axes.get("authority", 0)),
		"skepticism": int(axes.get("skepticism", 0)),
		"fear": int(axes.get("fear", 0)),
		"curiosity": int(axes.get("curiosity", 0)),
		"certainty": int(axes.get("certainty", 0)),
		"ambiguity": int(axes.get("ambiguity", 0)),
		"ritual": int(axes.get("ritual", 0)),
		"innovation": int(axes.get("innovation", 0)),
		"extraction": int(axes.get("extraction", 0)),
		"stewardship": int(axes.get("stewardship", 0)),
		"momentum": momentum,
		"resonance": resonance,
		"cascade_risk": cascade_risk,
		"dominant_tensions": dominant_tensions,
		"generation_weighting": generation_weighting,
		"constitution_bias": constitution_bias,
		"archive_bias": archive_bias,
		"allowed_outputs": _string_array(schema.get("allowed_outputs", [])),
		"safety_bounds": _build_safety_bounds(schema),
		"public_lines": _build_public_lines(pressure_family, constitution_bias, resonance, cascade_risk),
		"trace": trace
	}
	state["validation_failures"] = validate_state(state)
	return state

static func _apply_experiment_pressure_bias(axes: Dictionary, experimental_ontology_state: Dictionary) -> Dictionary:
	var next := axes.duplicate(true)
	var bias: Dictionary = Dictionary(Dictionary(experimental_ontology_state.get("compile_outputs", {})).get("pressure_input_bias", {}))
	if bias.is_empty():
		return next
	for axis in _axis_fields():
		next[axis] = clampi(int(next.get(axis, 0)) + clampi(int(bias.get(axis, 0)), -1, 1), 0, 4)
	return next

static func validate_state(state: Dictionary) -> Array[String]:
	var schema := SCHEMA_REGISTRY_SCRIPT.narrative_pressure_schema()
	var failures: Array[String] = []
	for field in _string_array(schema.get("required_fields", [])):
		if not state.has(field):
			failures.append("narrative pressure state missing %s" % field)
	var min_axis := int(schema.get("min_axis_value", 0))
	var max_axis := int(schema.get("max_axis_value", 4))
	for field in _axis_fields():
		var value := int(state.get(field, min_axis - 1))
		if value < min_axis or value > max_axis:
			failures.append("narrative pressure axis %s out of bounds" % field)
	for field in ["momentum", "resonance", "cascade_risk"]:
		var value := int(state.get(field, min_axis - 1))
		if value < min_axis or value > max_axis:
			failures.append("narrative pressure scalar %s out of bounds" % field)
	var allowed_outputs := _string_array(schema.get("allowed_outputs", []))
	for output_name in _string_array(state.get("allowed_outputs", [])):
		if not allowed_outputs.has(output_name):
			failures.append("narrative pressure output %s is not allowed" % output_name)
	for required_output in allowed_outputs:
		if _string_array(state.get("allowed_outputs", [])).has(required_output) and not state.has(required_output):
			failures.append("narrative pressure state missing %s output" % required_output)
	for banned in _string_array(schema.get("forbidden_runtime_fields", [])):
		if _contains_key(state, banned):
			failures.append("narrative pressure state must not expose runtime-only field %s" % banned)
	return failures

static func _build_state_id(doctrine: Dictionary, pressure_family: String, dominant_tensions: Array[String], generation_surface: Dictionary) -> String:
	var identity_text := "%s|%s|%s|%s" % [
		str(doctrine.get("id", "")).strip_edges(),
		pressure_family,
		"|".join(dominant_tensions),
		str(generation_surface.get("branch_family", "")).strip_edges()
	]
	return "pressure_%s" % identity_text.md5_text().substr(0, 12)

static func _build_generation_weighting(pressure_family: String, axes: Dictionary, momentum: int, resonance: int, cascade_risk: int) -> Dictionary:
	var weighting := {
		"pressure_verbs": [],
		"symbolic_motifs": [],
		"item_ecology_bias": "",
		"group_tension_bias": "",
		"archive_tone": "",
		"convergence_axis": "",
		"civilization_routing_bias": {
			"legitimacy_custody": 0,
			"taboo_silence": 0,
			"canon_conflict": 0,
			"sacred_order": 0,
			"mourning_climate": 0,
			"ontology_heat": 0
		}
	}
	match pressure_family:
		"stewardship_ritual":
			weighting["pressure_verbs"] = ["Delay", "Convergence"]
			weighting["symbolic_motifs"] = ["Burden Halos", "Threshold Marks"]
			weighting["item_ecology_bias"] = "burden rescue"
			weighting["group_tension_bias"] = "measured caution"
			weighting["archive_tone"] = "memory custody"
			weighting["convergence_axis"] = "artifact custody"
			_dict_bump(weighting["civilization_routing_bias"], "legitimacy_custody", 1)
			_dict_bump(weighting["civilization_routing_bias"], "sacred_order", 1)
		"skeptical_fragmentation":
			weighting["pressure_verbs"] = ["Fragmentation", "Misdirection"]
			weighting["symbolic_motifs"] = ["Split Echoes", "Archive Scars"]
			weighting["item_ecology_bias"] = "deception scarcity"
			weighting["group_tension_bias"] = "ambiguous fault pressure"
			weighting["archive_tone"] = "forensic dispute"
			weighting["convergence_axis"] = "fragmentation"
			_dict_bump(weighting["civilization_routing_bias"], "canon_conflict", 1)
			_dict_bump(weighting["civilization_routing_bias"], "ontology_heat", 1)
		"curiosity_surge":
			weighting["pressure_verbs"] = ["Exposure", "Convergence"]
			weighting["symbolic_motifs"] = ["Threshold Marks", "Archive Scars"]
			weighting["item_ecology_bias"] = "rescue discovery"
			weighting["group_tension_bias"] = "public answer appetite"
			weighting["archive_tone"] = "measured memory"
			weighting["convergence_axis"] = "balanced"
			_dict_bump(weighting["civilization_routing_bias"], "ontology_heat", 1)
		"stabilizing_authority":
			weighting["pressure_verbs"] = ["Delay", "Compression"]
			weighting["symbolic_motifs"] = ["Threshold Marks"]
			weighting["item_ecology_bias"] = "burden memory"
			weighting["group_tension_bias"] = "measured caution"
			weighting["archive_tone"] = "memory custody"
			weighting["convergence_axis"] = "balanced"
			_dict_bump(weighting["civilization_routing_bias"], "legitimacy_custody", 1)
		"extractive_anxiety":
			weighting["pressure_verbs"] = ["Scarcity", "Exposure"]
			weighting["symbolic_motifs"] = ["Archive Scars", "Split Echoes"]
			weighting["item_ecology_bias"] = "scarcity deception"
			weighting["group_tension_bias"] = "trust fragility"
			weighting["archive_tone"] = "forensic dispute"
			weighting["convergence_axis"] = "fragmentation"
			_dict_bump(weighting["civilization_routing_bias"], "taboo_silence", 1)
			_dict_bump(weighting["civilization_routing_bias"], "mourning_climate", 1)
		_:
			weighting["pressure_verbs"] = ["Convergence", "Exposure"]
			weighting["symbolic_motifs"] = ["Threshold Marks"]
			weighting["item_ecology_bias"] = "rescue"
			weighting["group_tension_bias"] = "measured caution"
			weighting["archive_tone"] = "measured memory"
			weighting["convergence_axis"] = "balanced"
	if int(axes.get("ambiguity", 0)) > int(axes.get("certainty", 0)):
		weighting["pressure_verbs"] = _string_array(Array(weighting.get("pressure_verbs", [])) + ["Fragmentation"])
	if int(axes.get("ritual", 0)) > int(axes.get("innovation", 0)):
		weighting["symbolic_motifs"] = _string_array(Array(weighting.get("symbolic_motifs", [])) + ["Burden Halos"])
	if resonance >= 3:
		weighting["symbolic_motifs"] = _string_array(Array(weighting.get("symbolic_motifs", [])) + ["Archive Scars"])
	if cascade_risk >= 3:
		_dict_bump(weighting["civilization_routing_bias"], "canon_conflict", 1)
		_dict_bump(weighting["civilization_routing_bias"], "taboo_silence", 1)
	if momentum >= 3 and str(weighting.get("archive_tone", "")).strip_edges() == "measured memory":
		weighting["archive_tone"] = "memory custody"
	return weighting

static func _build_constitution_bias(pressure_family: String, dominant_tensions: Array[String], momentum: int, resonance: int, cascade_risk: int) -> Dictionary:
	var pressure_line := ""
	var world_goal_hint := ""
	match pressure_family:
		"stewardship_ritual":
			pressure_line = "Stewardship is forcing extraction to answer to ritual custody."
			world_goal_hint = "Keep artifact custody legible while older obligations harden."
		"skeptical_fragmentation":
			pressure_line = "Authority is being challenged by skepticism and split readings."
			world_goal_hint = "Keep the route arguable while classification pressure keeps opening new disputes."
		"curiosity_surge":
			pressure_line = "Curiosity is outrunning fear and old classifications."
			world_goal_hint = "Keep discovery visible without letting the answer collapse into spectacle."
		"stabilizing_authority":
			pressure_line = "Stability is trying to hold the answer in a single frame."
			world_goal_hint = "Keep the public answer readable while institutions tighten their claim."
		"extractive_anxiety":
			pressure_line = "Extraction appetite is rising faster than trust can settle."
			world_goal_hint = "Keep custody visible before the route turns scarcity into panic."
		_:
			pressure_line = "The field is trying to keep disruption and stability in argument."
			world_goal_hint = "Keep the answer legible while pressure keeps shifting what the world values."
	var public_lines := []
	if not dominant_tensions.is_empty():
		public_lines.append("%s is setting the tone." % dominant_tensions[0].capitalize())
	if resonance >= 3:
		public_lines.append("Older legends are starting to resonate with the current answer.")
	if cascade_risk >= 3:
		public_lines.append("One dispute is beginning to pull neighboring arguments into it.")
	elif momentum >= 3:
		public_lines.append("The field is accelerating faster than it can fully explain itself.")
	return {
		"pressure_line": pressure_line,
		"world_goal_hint": world_goal_hint,
		"public_lines": _string_array(public_lines),
		"tension_tags": dominant_tensions.duplicate()
	}

static func _build_archive_bias(pressure_family: String, dominant_tensions: Array[String], resonance: int, cascade_risk: int, public_summary: Dictionary) -> Dictionary:
	var framing_focus: Array[String] = []
	match pressure_family:
		"stewardship_ritual":
			framing_focus = ["custody legitimacy", "ritual obligation"]
		"skeptical_fragmentation":
			framing_focus = ["classification dispute", "public skepticism"]
		"curiosity_surge":
			framing_focus = ["rediscovery appetite", "institutional fascination"]
		"stabilizing_authority":
			framing_focus = ["official narrative", "legibility discipline"]
		"extractive_anxiety":
			framing_focus = ["scarcity controversy", "public fear"]
		_:
			framing_focus = ["civil pressure", "archive framing"]
	var cascade_channels: Array[String] = []
	if cascade_risk >= 3:
		cascade_channels.append("archive dispute")
		cascade_channels.append("public retellings")
	if resonance >= 3:
		cascade_channels.append("legend echo")
	if str(public_summary.get("archive_tone", "")).to_lower().find("memory") != -1:
		cascade_channels.append("memory custody")
	return {
		"framing_focus": _string_array(framing_focus),
		"cascade_channels": _string_array(cascade_channels),
		"resonant_legends": resonance >= 3,
		"pressure_family": pressure_family,
		"dominant_tensions": dominant_tensions.duplicate()
	}

static func _build_public_lines(pressure_family: String, constitution_bias: Dictionary, resonance: int, cascade_risk: int) -> Array[String]:
	var lines := _string_array(constitution_bias.get("public_lines", []))
	var pressure_line := str(constitution_bias.get("pressure_line", "")).strip_edges()
	if not pressure_line.is_empty():
		lines.insert(0, pressure_line)
	lines = _string_array(lines)
	if resonance >= 3 and not lines.has("Older legends are starting to resonate with the current answer."):
		lines.append("Older legends are starting to resonate with the current answer.")
	if cascade_risk >= 3 and not lines.has("One dispute is beginning to pull neighboring arguments into it."):
		lines.append("One dispute is beginning to pull neighboring arguments into it.")
	return lines.slice(0, 3)

static func _build_safety_bounds(schema: Dictionary) -> Dictionary:
	return {
		"min_axis_value": int(schema.get("min_axis_value", 0)),
		"max_axis_value": int(schema.get("max_axis_value", 4)),
		"runtime_legality_mutation": false,
		"artifact_trust_floor": "objective_central",
		"legibility_floor": 2
	}

static func _pressure_family(axes: Dictionary, dominant_tensions: Array[String], generation_surface: Dictionary, doctrine_family: Dictionary) -> String:
	if int(axes.get("stewardship", 0)) >= int(axes.get("extraction", 0)) + 1 and int(axes.get("ritual", 0)) >= int(axes.get("innovation", 0)):
		return "stewardship_ritual"
	if int(axes.get("skepticism", 0)) >= int(axes.get("authority", 0)) + 1 and int(axes.get("ambiguity", 0)) >= int(axes.get("certainty", 0)):
		return "skeptical_fragmentation"
	if int(axes.get("curiosity", 0)) >= int(axes.get("fear", 0)) + 1 and int(axes.get("innovation", 0)) >= int(axes.get("ritual", 0)):
		return "curiosity_surge"
	if int(axes.get("authority", 0)) >= int(axes.get("skepticism", 0)) + 1 and int(axes.get("stability", 0)) >= int(axes.get("disruption", 0)):
		return "stabilizing_authority"
	if int(axes.get("extraction", 0)) >= int(axes.get("stewardship", 0)) + 1 and int(axes.get("fear", 0)) >= int(axes.get("curiosity", 0)):
		return "extractive_anxiety"
	if str(generation_surface.get("convergence_axis", "")).to_lower().find("fragment") != -1:
		return "skeptical_fragmentation"
	if str(Dictionary(doctrine_family.get("inheritance", {})).get("archive_tone", "")).to_lower().find("memory") != -1:
		return "stewardship_ritual"
	if not dominant_tensions.is_empty():
		var top := dominant_tensions[0].to_lower()
		if top.find("skepticism") != -1 or top.find("ambiguity") != -1:
			return "skeptical_fragmentation"
		if top.find("stewardship") != -1 or top.find("ritual") != -1:
			return "stewardship_ritual"
		if top.find("curiosity") != -1 or top.find("innovation") != -1:
			return "curiosity_surge"
	return "measured_balance"

static func _dominant_tensions(axes: Dictionary) -> Array[String]:
	var pair_entries := [
		_pair_entry("stability", "disruption", axes),
		_pair_entry("authority", "skepticism", axes),
		_pair_entry("fear", "curiosity", axes),
		_pair_entry("certainty", "ambiguity", axes),
		_pair_entry("ritual", "innovation", axes),
		_pair_entry("extraction", "stewardship", axes)
	]
	pair_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("margin", 0)) == int(b.get("margin", 0)):
			return str(a.get("label", "")) < str(b.get("label", ""))
		return int(a.get("margin", 0)) > int(b.get("margin", 0))
	)
	var lines: Array[String] = []
	for entry in pair_entries:
		if int(entry.get("margin", 0)) <= 0:
			continue
		lines.append(str(entry.get("label", "")))
		if lines.size() >= 3:
			break
	return lines

static func _pair_entry(left_key: String, right_key: String, axes: Dictionary) -> Dictionary:
	var left_value := int(axes.get(left_key, 0))
	var right_value := int(axes.get(right_key, 0))
	if left_value == right_value:
		return {"label": "%s and %s are holding in tension" % [left_key.replace("_", " "), right_key.replace("_", " ")], "margin": 0}
	if left_value > right_value:
		return {"label": "%s over %s" % [left_key.replace("_", " "), right_key.replace("_", " ")], "margin": left_value - right_value}
	return {"label": "%s over %s" % [right_key.replace("_", " "), left_key.replace("_", " ")], "margin": right_value - left_value}

static func _band(total: int) -> int:
	if total >= 8:
		return 4
	if total >= 5:
		return 3
	if total >= 3:
		return 2
	if total >= 1:
		return 1
	return 0

static func _contains_key(value: Variant, banned_key: String) -> bool:
	match typeof(value):
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			if dict.has(banned_key):
				return true
			for child in dict.values():
				if _contains_key(child, banned_key):
					return true
		TYPE_ARRAY:
			for child in value:
				if _contains_key(child, banned_key):
					return true
	return false

static func _dict_bump(target: Variant, key: String, amount: int) -> void:
	if target is Dictionary:
		target[key] = maxi(int(Dictionary(target).get(key, 0)) + amount, 0)

static func _axis_fields() -> Array[String]:
	return [
		"stability",
		"disruption",
		"authority",
		"skepticism",
		"fear",
		"curiosity",
		"certainty",
		"ambiguity",
		"ritual",
		"innovation",
		"extraction",
		"stewardship"
	]

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array or values is PackedStringArray:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
