class_name RunGenerator
extends RefCounted

const ARTIFACT_SERVICE_SCRIPT = preload("res://src/run/artifact_service.gd")

const BRANCH_FAMILIES: Array[Dictionary] = [
	{
		"id": "watcher_steps",
		"display_name": "Watcher Steps",
		"social_pressure": "witness_heat",
		"challenge_texture": "threshold_pressure",
		"confrontation_climate": "public_standoff",
		"rescue_climate": "visible_recovery",
		"burden_pressure": "handoff_heavy",
		"witness_pressure": "high",
		"route_commitment": "staged_commitment",
		"regroup_friction": "moderate",
		"escape_bandwidth": "tight",
		"symbolic_places": ["threshold", "bridge", "handoff point"]
	},
	{
		"id": "sundered_span",
		"display_name": "Sundered Span",
		"social_pressure": "fracture_heat",
		"challenge_texture": "commitment_cost",
		"confrontation_climate": "cutoff_risk",
		"rescue_climate": "desperate_recovery",
		"burden_pressure": "carry_fragile",
		"witness_pressure": "split",
		"route_commitment": "hard_commitment",
		"regroup_friction": "high",
		"escape_bandwidth": "narrow",
		"symbolic_places": ["choke", "lift", "fall line"]
	},
	{
		"id": "relay_hollows",
		"display_name": "Relay Hollows",
		"social_pressure": "callout_chain",
		"challenge_texture": "route_revision",
		"confrontation_climate": "interruption_risk",
		"rescue_climate": "covering_retreat",
		"burden_pressure": "escort_pressure",
		"witness_pressure": "public",
		"route_commitment": "fluid",
		"regroup_friction": "low",
		"escape_bandwidth": "broad",
		"symbolic_places": ["corridor", "relay gate", "regroup lane"]
	},
	{
		"id": "grave_lattice",
		"display_name": "Grave Lattice",
		"social_pressure": "cursed_bait",
		"challenge_texture": "temptation_pressure",
		"confrontation_climate": "loaded_silence",
		"rescue_climate": "late_salvage",
		"burden_pressure": "fear_weight",
		"witness_pressure": "partial",
		"route_commitment": "uneasy_commitment",
		"regroup_friction": "moderate",
		"escape_bandwidth": "uncertain",
		"symbolic_places": ["pedestal", "drop line", "return threshold"]
	},
	{
		"id": "forge_veins",
		"display_name": "Forge Veins",
		"social_pressure": "temptation_heat",
		"challenge_texture": "risk_for_value",
		"confrontation_climate": "artifact_conflict",
		"rescue_climate": "burden_defense",
		"burden_pressure": "value_weight",
		"witness_pressure": "focused",
		"route_commitment": "greedy_detour",
		"regroup_friction": "moderate",
		"escape_bandwidth": "swinging",
		"symbolic_places": ["pedestal", "vault route", "handoff arch"]
	},
	{
		"id": "oath_terraces",
		"display_name": "Oath Terraces",
		"social_pressure": "witness_vow",
		"challenge_texture": "escort_vigil",
		"confrontation_climate": "public_oath",
		"rescue_climate": "burden_defense",
		"burden_pressure": "escort_oath",
		"witness_pressure": "focused",
		"route_commitment": "staged_commitment",
		"regroup_friction": "low",
		"escape_bandwidth": "tight",
		"symbolic_places": ["threshold", "bridge", "handoff point"]
	},
	{
		"id": "murmur_warrens",
		"display_name": "Murmur Warrens",
		"social_pressure": "counter_reading",
		"challenge_texture": "forbidden_revision",
		"confrontation_climate": "misread_cutoff",
		"rescue_climate": "covering_retreat",
		"burden_pressure": "hidden_handoff",
		"witness_pressure": "split",
		"route_commitment": "fluid",
		"regroup_friction": "high",
		"escape_bandwidth": "uncertain",
		"symbolic_places": ["relay gate", "handoff arch", "threshold"]
	}
]

const ROOM_VARIANTS: Array = [
	{"id": "traverse_a", "type": "traversal", "hazard": "none"},
	{"id": "traverse_b", "type": "traversal", "hazard": "spikes"},
	{"id": "hazard_push", "type": "hazard", "hazard": "push"},
	{"id": "hazard_collapse", "type": "hazard", "hazard": "collapse"},
	{"id": "evidence_vault", "type": "evidence", "hazard": "alarm"},
	{"id": "evidence_gap", "type": "evidence", "hazard": "collapse"},
	{"id": "evidence_choke", "type": "evidence", "hazard": "spikes"},
	{"id": "traverse_c", "type": "traversal", "hazard": "push"},
	{"id": "hazard_spike", "type": "hazard", "hazard": "spikes"}
]

func build_generation_contract(seed_value: int, directive: Dictionary = {}) -> Dictionary:
	var embedded: Dictionary = _embedded_generation_contract(directive)
	var public_summary: Dictionary = Dictionary(directive.get("constitution_summary", directive.get("public_summary", {})))
	var run_identity: Dictionary = Dictionary(directive.get("run_identity", {}))
	var surfaces: Dictionary = Dictionary(directive.get("control_surfaces", {}))
	var contract := {
		"seed": int(embedded.get("seed", seed_value)),
		"protocol_state": str(embedded.get("protocol_state", directive.get("protocol_state", public_summary.get("protocol_state", "")))).strip_edges(),
		"doctrine_family": str(embedded.get("doctrine_family", directive.get("doctrine_family", ""))).strip_edges(),
		"branch_family": str(embedded.get("branch_family", directive.get("branch_family", ""))).strip_edges(),
		"dominant_forces": _normalize_contract_array(embedded.get("dominant_forces", _force_labels_from_sources(public_summary, run_identity, surfaces))),
		"dominant_minds": _normalize_contract_array(embedded.get("dominant_minds", _mind_labels_from_sources(public_summary, run_identity, surfaces))),
		"pacing_profile": str(embedded.get("pacing_profile", directive.get("pacing_profile", _pacing_profile_from_sources(public_summary, run_identity, surfaces)))).strip_edges(),
		"pressure_verbs": _normalize_contract_array(embedded.get("pressure_verbs", directive.get("pressure_verbs", _pressure_verbs_from_sources(public_summary, run_identity, surfaces)))),
		"symbolic_motifs": _normalize_contract_array(embedded.get("symbolic_motifs", _symbolic_motifs_from_sources(public_summary, run_identity, surfaces))),
		"item_ecology_bias": str(embedded.get("item_ecology_bias", directive.get("item_ecology_bias", _item_ecology_bias_from_sources(public_summary, run_identity, surfaces)))).strip_edges(),
		"group_tension_bias": str(embedded.get("group_tension_bias", directive.get("group_tension_bias", _group_tension_bias_from_sources(public_summary, run_identity, surfaces)))).strip_edges(),
		"archive_tone": str(embedded.get("archive_tone", directive.get("archive_tone", _archive_tone_from_sources(public_summary, run_identity, surfaces)))).strip_edges(),
		"convergence_axis": str(embedded.get("convergence_axis", directive.get("convergence_axis", _convergence_axis_from_sources(public_summary, run_identity, surfaces)))).strip_edges(),
		"relationship_routing": Dictionary(embedded.get("relationship_routing", directive.get("relationship_routing", {}))).duplicate(true),
		"relay_routing": Dictionary(embedded.get("relay_routing", directive.get("relay_routing", {}))).duplicate(true),
		"cookbook_routing": Dictionary(embedded.get("cookbook_routing", directive.get("cookbook_routing", {}))).duplicate(true),
		"civilization_routing": Dictionary(embedded.get("civilization_routing", directive.get("civilization_routing", {}))).duplicate(true),
		"market_routing": Dictionary(embedded.get("market_routing", directive.get("market_routing", {}))).duplicate(true),
		"lifecycle_routing": Dictionary(embedded.get("lifecycle_routing", directive.get("lifecycle_routing", {}))).duplicate(true),
		"encounter_routing": Dictionary(embedded.get("encounter_routing", directive.get("encounter_routing", {}))).duplicate(true),
		"apex_routing": Dictionary(embedded.get("apex_routing", directive.get("apex_routing", {}))).duplicate(true),
		"ontology_routing": Dictionary(embedded.get("ontology_routing", directive.get("ontology_routing", {}))).duplicate(true)
	}
	if contract["protocol_state"].is_empty():
		contract["protocol_state"] = "Expedition Protocol"
	if contract["doctrine_family"].is_empty():
		contract["doctrine_family"] = "delve_trial"
	if str(contract.get("pacing_profile", "")).is_empty():
		contract["pacing_profile"] = "steady"
	if Array(contract.get("pressure_verbs", [])).is_empty():
		contract["pressure_verbs"] = ["Exposure"]
	if Array(contract.get("symbolic_motifs", [])).is_empty():
		contract["symbolic_motifs"] = ["Threshold Marks"]
	if str(contract.get("item_ecology_bias", "")).is_empty():
		contract["item_ecology_bias"] = "rescue"
	if str(contract.get("group_tension_bias", "")).is_empty():
		contract["group_tension_bias"] = "measured caution"
	if str(contract.get("archive_tone", "")).is_empty():
		contract["archive_tone"] = "measured memory"
	if str(contract.get("convergence_axis", "")).is_empty():
		contract["convergence_axis"] = "balanced"
	if str(contract.get("branch_family", "")).is_empty():
		contract["branch_family"] = _select_branch_family_id(seed_value, contract)
	return contract

func _embedded_generation_contract(directive: Dictionary) -> Dictionary:
	var generation_surface: Dictionary = Dictionary(directive.get("generation_surface", {})).duplicate(true)
	if not generation_surface.is_empty():
		return generation_surface
	var embedded: Dictionary = Dictionary(directive.get("generation_contract", {})).duplicate(true)
	if not embedded.is_empty():
		return embedded
	if _looks_like_generation_contract(directive):
		return directive.duplicate(true)
	return {}

func _looks_like_generation_contract(candidate: Dictionary) -> bool:
	return candidate.has("protocol_state") \
		and candidate.has("doctrine_family") \
		and candidate.has("branch_family") \
		and candidate.has("dominant_forces") \
		and candidate.has("dominant_minds") \
		and candidate.has("pacing_profile") \
		and candidate.has("pressure_verbs") \
		and candidate.has("symbolic_motifs") \
		and candidate.has("item_ecology_bias") \
		and candidate.has("group_tension_bias") \
		and candidate.has("archive_tone") \
		and candidate.has("convergence_axis") \
		and candidate.has("encounter_routing") \
		and candidate.has("apex_routing") \
		and not candidate.has("run_identity") \
		and not candidate.has("control_surfaces")

func generate_layout(seed_value: int, room_count: int = 15, directive: Dictionary = {}) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var chain: Array = []
	var bag: Array = ROOM_VARIANTS.duplicate(true)
	var generation_contract := build_generation_contract(seed_value, directive)
	var branch_family := _branch_family_from_contract(generation_contract)

	for i in room_count:
		if bag.is_empty():
			bag = ROOM_VARIANTS.duplicate(true)
		var pick_index := _pick_room_index(rng, bag, i, room_count, branch_family, generation_contract)
		var room: Dictionary = bag[pick_index]
		bag.remove_at(pick_index)
		var room_entry := _with_branch_context({
			"slot": i,
			"id": room["id"],
			"type": room["type"],
			"hazard": room["hazard"],
			"risk": _risk_for_slot(rng, i, room_count, str(room["type"]), generation_contract)
		}, branch_family, i, room_count, generation_contract)
		var interaction_channels: Array[String] = ["navigation"]
		var solvability_tags: Array[String] = ["meaningful_route"]
		if i == 0:
			solvability_tags.append("discoverable_entry")
		if i == 1 or str(room.get("type", "")) == "evidence":
			interaction_channels.append_array(["artifact_custody", "inspection", "note_logging"])
			solvability_tags.append("reachable_evidence")
		if str(room.get("type", "")) == "hazard":
			interaction_channels.append("social_callout")
			solvability_tags.append("pressure_visible")
		if i >= room_count - 1:
			interaction_channels.append("extraction")
			solvability_tags.append("reachable_extraction")
		room_entry["interaction_channels"] = _string_array(interaction_channels)
		room_entry["solvability_tags"] = _string_array(solvability_tags)
		room_entry["no_dead_state_expected"] = true
		chain.append(room_entry)

	return chain

func generate_evidence_spawns(seed_value: int, room_chain: Array) -> Array:
	return ARTIFACT_SERVICE_SCRIPT.new().spawn_for_chain(seed_value, room_chain)

func _pick_room_index(rng: RandomNumberGenerator, bag: Array, slot: int, room_count: int, branch_family: Dictionary = {}, generation_contract: Dictionary = {}) -> int:
	var weighted_indices: Array[int] = []
	var allowed_types := _allowed_room_types_for_slot(slot, room_count)
	var type_weights := _room_type_weights_for_slot(slot, room_count, branch_family, generation_contract)
	for i in range(bag.size()):
		var room: Dictionary = bag[i]
		var room_type := str(room.get("type", "traversal"))
		if not allowed_types.has(room_type):
			continue
		var copies := int(type_weights.get(room_type, 1))
		for _copy in range(maxi(copies, 1)):
			weighted_indices.append(i)
	if weighted_indices.is_empty():
		return rng.randi_range(0, bag.size() - 1)
	return weighted_indices[rng.randi_range(0, weighted_indices.size() - 1)]

func _allowed_room_types_for_slot(slot: int, room_count: int) -> Array[String]:
	if slot <= 0:
		return ["traversal"]
	if slot == 1:
		return ["evidence"]
	if slot == room_count - 2:
		return ["hazard"]
	if slot >= room_count - 1:
		return ["traversal"]
	if slot < maxi(int(room_count / 3), 3):
		return ["traversal", "evidence"]
	if slot >= maxi(int(room_count * 2 / 3), 1):
		return ["hazard", "evidence", "traversal"]
	return ["traversal", "hazard", "evidence"]

func _room_type_weights_for_slot(slot: int, room_count: int, branch_family: Dictionary = {}, generation_contract: Dictionary = {}) -> Dictionary:
	if slot <= 0:
		return _shape_room_weights({"traversal": 6}, slot, room_count, branch_family, generation_contract)
	if slot == 1:
		return _shape_room_weights({"evidence": 6}, slot, room_count, branch_family, generation_contract)
	if slot == room_count - 2:
		return _shape_room_weights({"hazard": 6}, slot, room_count, branch_family, generation_contract)
	if slot >= room_count - 1:
		return _shape_room_weights({"traversal": 6}, slot, room_count, branch_family, generation_contract)
	if slot < maxi(int(room_count / 3), 3):
		return _shape_room_weights({"traversal": 5, "evidence": 4}, slot, room_count, branch_family, generation_contract)
	if slot >= maxi(int(room_count * 2 / 3), 1):
		return _shape_room_weights({"hazard": 5, "evidence": 3, "traversal": 2}, slot, room_count, branch_family, generation_contract)
	return _shape_room_weights({"hazard": 3, "evidence": 3, "traversal": 2}, slot, room_count, branch_family, generation_contract)

func _shape_room_weights(base: Dictionary, slot: int, room_count: int, branch_family: Dictionary, generation_contract: Dictionary) -> Dictionary:
	return _apply_protocol_room_weights(
		_apply_run_identity_room_weights(
			_apply_branch_family_room_weights(
				_apply_lifecycle_room_weights(
					_apply_surface_slot_room_weights(_apply_doctrine_room_weights(base, generation_contract), slot, room_count, generation_contract),
					generation_contract
				),
				branch_family
			),
			slot,
			room_count,
			branch_family,
			generation_contract
		),
		slot,
		room_count,
		generation_contract
	)

func _apply_lifecycle_room_weights(weights: Dictionary, generation_contract: Dictionary) -> Dictionary:
	var next := weights.duplicate(true)
	var lifecycle_routing: Dictionary = Dictionary(generation_contract.get("lifecycle_routing", {}))
	for family_raw in Array(lifecycle_routing.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_kind := str(family.get("family_kind", "")).strip_edges()
		var source_id := str(family.get("source_id", "")).strip_edges()
		var heat := int(family.get("heat", 0))
		var cooldown_band := str(family.get("cooldown_band", "open")).strip_edges()
		var routing_tags := _string_array(family.get("routing_tags", []))
		if family_kind == "combo_family" and heat >= 3:
			if _lifecycle_has_any_tag(routing_tags, ["route", "return", "combo_private_archive_ritual", "route_memory"]):
				next["traversal"] = int(next.get("traversal", 0)) + 1
			if _lifecycle_has_any_tag(routing_tags, ["memory", "witness", "artifact_custody", "combo_private_archive_ritual"]):
				next["evidence"] = int(next.get("evidence", 0)) + 1
			if cooldown_band == "deep_cooling":
				next["hazard"] = int(next.get("hazard", 0)) + 1
		elif family_kind == "artifact_continuity":
			match source_id:
				"burial", "archive_only_residue":
					next["evidence"] = int(next.get("evidence", 0)) + 2
				"recoverable_loss", "successor_emergence":
					next["traversal"] = int(next.get("traversal", 0)) + 2
				"extinction":
					next["hazard"] = int(next.get("hazard", 0)) + 1
			if cooldown_band in ["cooling", "warming"]:
				next["traversal"] = int(next.get("traversal", 0)) + 1
	for room_type in ["traversal", "evidence", "hazard"]:
		if next.has(room_type):
			next[room_type] = maxi(int(next.get(room_type, 0)), 1)
	return next

func room_type_weights_for_slot_for_test(slot: int, room_count: int, directive: Dictionary = {}) -> Dictionary:
	return _room_type_weights_for_slot(slot, room_count, {}, build_generation_contract(slot * 97 + room_count * 13, directive))

func room_type_weights_for_branch_for_test(slot: int, room_count: int, branch_family_id: String, directive: Dictionary = {}) -> Dictionary:
	return _room_type_weights_for_slot(slot, room_count, _branch_family_from_id(branch_family_id), build_generation_contract(slot * 97 + room_count * 13, directive))

func _risk_for_slot(rng: RandomNumberGenerator, slot: int, room_count: int, room_type: String, generation_contract: Dictionary = {}) -> int:
	var pressure_tokens := _contract_pressure_tokens(generation_contract)
	var motif_tokens := _contract_motif_tokens(generation_contract)
	var pacing_id := _contract_pacing_token(generation_contract)
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var group_tension_bias := str(generation_contract.get("group_tension_bias", "")).to_lower()
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).to_lower()
	var market_routing: Dictionary = Dictionary(generation_contract.get("market_routing", {}))
	var lifecycle_routing: Dictionary = Dictionary(generation_contract.get("lifecycle_routing", {}))
	var risk_bias := 0
	if pressure_tokens.has("fragmentation") or pressure_tokens.has("misdirection"):
		risk_bias += 1
	if pressure_tokens.has("scarcity") or group_tension_bias.find("fault") != -1:
		risk_bias += 1
	if pressure_tokens.has("delay") or motif_tokens.has("archive_scars"):
		risk_bias += 1
	if pressure_tokens.has("exposure"):
		risk_bias += 1
	if item_ecology_bias.find("deception") != -1 or item_ecology_bias.find("scandal") != -1:
		risk_bias += 1
	if convergence_axis.find("fragment") != -1:
		risk_bias += 1
	if int(market_routing.get("market_volatility", 0)) > 0:
		risk_bias += int(market_routing.get("market_volatility", 0))
	if int(market_routing.get("carrier_risk_bias", 0)) > 0:
		risk_bias += int(market_routing.get("carrier_risk_bias", 0))
	if int(market_routing.get("extraction_debt", 0)) >= 2:
		risk_bias += 1
	if int(market_routing.get("hoard_heat", 0)) >= 2:
		risk_bias += 1
	risk_bias += _lifecycle_risk_bias(lifecycle_routing)
	if item_ecology_bias.find("rescue") != -1 or convergence_axis.find("custody") != -1 or pressure_tokens.has("convergence"):
		risk_bias -= 1
	if int(market_routing.get("scarcity_recovery", 0)) > 0:
		risk_bias -= int(market_routing.get("scarcity_recovery", 0))
	if int(market_routing.get("recovery_credit", 0)) >= 2:
		risk_bias -= maxi(int(market_routing.get("recovery_credit", 0)) / 2, 1)
	if pacing_id in ["volatile", "escalating"]:
		risk_bias += 1
	elif pacing_id == "calm":
		risk_bias -= 1
	if slot <= 0:
		return clampi(1 + maxi(risk_bias, 0) / 2, 1, 2)
	if slot == 1:
		return clampi(1 + maxi(risk_bias, 0) / 2, 1, 2)
	if slot == room_count - 2:
		return clampi(3 + risk_bias / 2, 1, 3)
	if slot >= room_count - 1:
		return clampi((2 if room_type == "traversal" else 3) + risk_bias / 2, 1, 3)
	if slot < maxi(int(room_count / 3), 3):
		return clampi(rng.randi_range(1, 2) + mini(risk_bias, 1) / 2, 1, 3)
	if slot >= maxi(int(room_count * 2 / 3), 1):
		return clampi(rng.randi_range(2, 3) + risk_bias / 2, 1, 3)
	return clampi(rng.randi_range(1, 3) + risk_bias / 2, 1, 3)

func risk_for_slot_for_test(seed_value: int, slot: int, room_count: int, room_type: String = "traversal", directive: Dictionary = {}) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 41 + slot * 17 + room_count
	return _risk_for_slot(rng, slot, room_count, room_type, build_generation_contract(seed_value, directive))

func branch_family_weights_for_test(directive: Dictionary = {}) -> Dictionary:
	var generation_contract := build_generation_contract(0, directive)
	var weights := {}
	for family_raw in BRANCH_FAMILIES:
		var family: Dictionary = Dictionary(family_raw)
		weights[str(family.get("id", ""))] = _branch_family_weight(family, generation_contract)
	return weights

func branch_family_for_seed(seed_value: int, directive: Dictionary = {}) -> Dictionary:
	var generation_contract := build_generation_contract(seed_value, directive)
	return _branch_family_from_contract(generation_contract)

func _branch_family_from_contract(generation_contract: Dictionary) -> Dictionary:
	var branch_family_id := str(generation_contract.get("branch_family", "")).strip_edges()
	if not branch_family_id.is_empty():
		var branch_family := _branch_family_from_id(branch_family_id)
		if not branch_family.is_empty():
			return branch_family
	return _branch_family_from_id("watcher_steps")

func _select_branch_family_id(seed_value: int, generation_contract: Dictionary) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value * 29 + 17
	var weighted: Array[Dictionary] = []
	for family_raw in BRANCH_FAMILIES:
		var family: Dictionary = Dictionary(family_raw)
		var weight := _branch_family_weight(family, generation_contract)
		weighted.append({"family": family.duplicate(true), "weight": weight})
	weighted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(Dictionary(a.get("family", {})).get("id", "")) < str(Dictionary(b.get("family", {})).get("id", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	var total := 0
	for entry_raw in weighted:
		total += maxi(int(Dictionary(entry_raw).get("weight", 1)), 1)
	var roll := rng.randi_range(0, maxi(total - 1, 0))
	var cursor := 0
	for entry_raw in weighted:
		var entry: Dictionary = Dictionary(entry_raw)
		var weight := maxi(int(entry.get("weight", 1)), 1)
		if roll < cursor + weight:
			return str(Dictionary(entry.get("family", {})).get("id", "watcher_steps"))
		cursor += weight
	return str(Dictionary(BRANCH_FAMILIES[posmod(seed_value, BRANCH_FAMILIES.size())]).get("id", "watcher_steps"))

func branch_context_for_test(seed_value: int, slot: int, room_count: int, room_type: String = "traversal", room_hazard: String = "none", directive: Dictionary = {}) -> Dictionary:
	var generation_contract := build_generation_contract(seed_value, directive)
	var base := {
		"slot": slot,
		"id": "test_%d" % slot,
		"type": room_type,
		"hazard": room_hazard,
		"risk": 1
	}
	return _with_branch_context(base, _branch_family_from_contract(generation_contract), slot, room_count, generation_contract)

func _with_branch_context(room: Dictionary, branch_family: Dictionary, slot: int, room_count: int, generation_contract: Dictionary = {}) -> Dictionary:
	var context := Dictionary(branch_family).duplicate(true)
	var pressure_grammar := Array(generation_contract.get("pressure_verbs", [])).duplicate(true).slice(0, 2)
	var symbolic_motifs := Array(generation_contract.get("symbolic_motifs", [])).duplicate(true).slice(0, 2)
	var dominant_minds := Array(generation_contract.get("dominant_minds", [])).duplicate(true).slice(0, 2)
	context["slot_band"] = _slot_band(slot, room_count)
	context["pressure_profile"] = _pressure_profile(branch_family, slot, room_count, str(room.get("type", "")), str(room.get("hazard", "")), generation_contract)
	context["symbolic_anchor"] = _symbolic_anchor(branch_family, slot)
	context["doctrine_family"] = str(generation_contract.get("doctrine_family", ""))
	context["protocol_state"] = str(generation_contract.get("protocol_state", ""))
	context["constitution_summary"] = {
		"protocol_state": str(generation_contract.get("protocol_state", "")),
		"doctrine_family": str(generation_contract.get("doctrine_family", "")),
		"dominant_forces": Array(generation_contract.get("dominant_forces", [])).duplicate(true),
		"dominant_minds": Array(generation_contract.get("dominant_minds", [])).duplicate(true),
		"pacing_profile": str(generation_contract.get("pacing_profile", "")),
		"pressure_verbs": Array(generation_contract.get("pressure_verbs", [])).duplicate(true),
		"symbolic_motifs": Array(generation_contract.get("symbolic_motifs", [])).duplicate(true),
		"item_ecology_bias": str(generation_contract.get("item_ecology_bias", "")),
		"group_tension_bias": str(generation_contract.get("group_tension_bias", "")),
		"archive_tone": str(generation_contract.get("archive_tone", "")),
		"convergence_axis": str(generation_contract.get("convergence_axis", ""))
	}
	context["directive_summary"] = Dictionary(context.get("constitution_summary", {})).duplicate(true)
	# Branch context is replicated in the room-chain payload, so keep it on the public-safe side.
	context["surface_summary"] = {
		"lines": _generation_surface_lines(generation_contract)
	}
	context["encounter_preview"] = {
		"active_pathology_ids": _string_array(Dictionary(generation_contract.get("encounter_routing", {})).get("active_pathology_ids", [])),
		"encounter_manifest_ids": _string_array(Dictionary(generation_contract.get("encounter_routing", {})).get("encounter_manifest_ids", [])),
		"encounter_lines": _string_array(Dictionary(generation_contract.get("encounter_routing", {})).get("encounter_lines", []))
	}
	context["apex_preview"] = {
		"apex_manifest_ids": _string_array(Dictionary(generation_contract.get("apex_routing", {})).get("apex_manifest_ids", [])),
		"apex_class_ids": _string_array(Dictionary(generation_contract.get("apex_routing", {})).get("apex_class_ids", [])),
		"apex_lines": _string_array(Dictionary(generation_contract.get("apex_routing", {})).get("apex_lines", [])),
		"peak_structure_lines": _string_array(Dictionary(generation_contract.get("apex_routing", {})).get("peak_structure_lines", [])),
		"peak_spacing_score": int(Dictionary(generation_contract.get("apex_routing", {})).get("peak_spacing_score", 0))
	}
	context["run_identity_summary"] = {
		"pacing_profile": str(generation_contract.get("pacing_profile", "")),
		"pressure_grammar": pressure_grammar,
		"symbolic_motifs": symbolic_motifs,
		"dominant_minds": dominant_minds,
		"convergence_axis": str(generation_contract.get("convergence_axis", ""))
	}
	var relationship_routing: Dictionary = Dictionary(generation_contract.get("relationship_routing", {}))
	var relay_routing: Dictionary = Dictionary(generation_contract.get("relay_routing", {}))
	var cookbook_routing: Dictionary = Dictionary(generation_contract.get("cookbook_routing", {}))
	var civilization_routing: Dictionary = Dictionary(generation_contract.get("civilization_routing", {}))
	var encounter_routing: Dictionary = Dictionary(generation_contract.get("encounter_routing", {}))
	var apex_routing: Dictionary = Dictionary(generation_contract.get("apex_routing", {}))
	var ontology_routing: Dictionary = Dictionary(generation_contract.get("ontology_routing", {}))
	if int(relationship_routing.get("escort_expectation", 0)) > 0:
		Array(context["pressure_profile"]).append("escort_duty")
	if int(relationship_routing.get("rescue_convergence", 0)) > 0:
		Array(context["pressure_profile"]).append("rescue_debt")
	if int(relationship_routing.get("regroup_strain", 0)) > 0:
		Array(context["pressure_profile"]).append("regroup_strain")
	if int(relationship_routing.get("witness_suspicion", 0)) > 0:
		Array(context["pressure_profile"]).append("witness_doubt")
	if int(relationship_routing.get("obligation_risk", 0)) > 0:
		Array(context["pressure_profile"]).append("handoff_obligation")
	if int(relay_routing.get("relay_overload", 0)) > 0:
		Array(context["pressure_profile"]).append("relay_overload")
	if int(relay_routing.get("distributed_witness", 0)) > 0:
		Array(context["pressure_profile"]).append("distributed_witness")
	if int(relay_routing.get("regroup_friction", 0)) > 0:
		Array(context["pressure_profile"]).append("relay_bottleneck")
	if int(relay_routing.get("rumor_heat", 0)) > 0:
		Array(context["pressure_profile"]).append("rumor_heat")
	if int(relay_routing.get("return_pressure", 0)) > 0:
		Array(context["pressure_profile"]).append("cohort_split")
	if int(cookbook_routing.get("fragmentary_reading", 0)) > 0:
		Array(context["pressure_profile"]).append("fragmentary_reading")
	if int(cookbook_routing.get("holder_network", 0)) > 0:
		Array(context["pressure_profile"]).append("holder_network")
	if int(cookbook_routing.get("counter_reading", 0)) > 0:
		Array(context["pressure_profile"]).append("counter_reading")
	if int(cookbook_routing.get("anti_protocol_pull", 0)) > 0:
		Array(context["pressure_profile"]).append("anti_protocol_pull")
	if int(civilization_routing.get("legitimacy_custody", 0)) > 0:
		Array(context["pressure_profile"]).append("legitimacy_custody")
	if int(civilization_routing.get("taboo_silence", 0)) > 0:
		Array(context["pressure_profile"]).append("taboo_silence")
	if int(civilization_routing.get("canon_conflict", 0)) > 0:
		Array(context["pressure_profile"]).append("canon_conflict")
	if int(civilization_routing.get("sacred_order", 0)) > 0:
		Array(context["pressure_profile"]).append("sacred_order")
	if int(civilization_routing.get("mourning_climate", 0)) > 0:
		Array(context["pressure_profile"]).append("mourning_climate")
	if int(civilization_routing.get("ontology_heat", 0)) > 0:
		Array(context["pressure_profile"]).append("ontology_heat")
	for route_tag in _ontology_route_tags(generation_contract):
		Array(context["pressure_profile"]).append(route_tag)
	for encounter_pressure in _string_array(encounter_routing.get("anchored_pressures", [])).slice(0, 2):
		Array(context["pressure_profile"]).append(encounter_pressure)
	if not _string_array(apex_routing.get("apex_manifest_ids", [])).is_empty():
		Array(context["pressure_profile"]).append("peak_pressure")
	if int(apex_routing.get("peak_spacing_score", 0)) >= 3:
		Array(context["pressure_profile"]).append("crisis_window")
	context["reputation_seeds"] = [
		str(branch_family.get("social_pressure", "")),
		str(branch_family.get("confrontation_climate", "")),
		str(branch_family.get("rescue_climate", "")),
		str(branch_family.get("burden_pressure", ""))
	]
	room["branch_family_id"] = str(branch_family.get("id", "watcher_steps"))
	room["branch_family_name"] = str(branch_family.get("display_name", "Unknown Branch"))
	room["doctrine_family"] = str(generation_contract.get("doctrine_family", ""))
	room["protocol_state"] = str(generation_contract.get("protocol_state", ""))
	room["branch_context"] = context
	return room

func _apply_doctrine_room_weights(weights: Dictionary, generation_contract: Dictionary) -> Dictionary:
	var next := weights.duplicate(true)
	var pressure_ids := _contract_pressure_tokens(generation_contract)
	var motif_ids := _contract_motif_tokens(generation_contract)
	var force_tokens := _contract_force_tokens(generation_contract)
	var ontology_route_tags := _ontology_route_tags(generation_contract)
	var pacing_id := _contract_pacing_token(generation_contract)
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).to_lower()
	if pressure_ids.has("exposure") or force_tokens.has("trial"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if pressure_ids.has("compression") or pressure_ids.has("scarcity") or force_tokens.has("containment"):
		next["hazard"] = int(next.get("hazard", 0)) + 1
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if pressure_ids.has("fragmentation") or pressure_ids.has("misdirection") or force_tokens.has("deception"):
		next["hazard"] = int(next.get("hazard", 0)) + 1
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if motif_ids.has("archive_scars") or motif_ids.has("burden_halos") or force_tokens.has("memory"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if pressure_ids.has("convergence") or force_tokens.has("discovery"):
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if pacing_id == "volatile":
		next["hazard"] = int(next.get("hazard", 0)) + 1
	elif pacing_id == "calm":
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if ontology_route_tags.has("rediscovery_loop"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if ontology_route_tags.has("taboo_threshold"):
		next["hazard"] = int(next.get("hazard", 0)) + 1
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if ontology_route_tags.has("ritual_commitment"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if item_ecology_bias.find("rescue") != -1 or convergence_axis.find("custody") != -1:
		next["traversal"] = int(next.get("traversal", 0)) + 1
	return next

func _apply_surface_slot_room_weights(weights: Dictionary, slot: int, room_count: int, generation_contract: Dictionary) -> Dictionary:
	var next := weights.duplicate(true)
	if slot <= 1 or slot >= room_count - 2:
		return next
	var pressure_ids := _contract_pressure_tokens(generation_contract)
	var motif_ids := _contract_motif_tokens(generation_contract)
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var group_tension_bias := str(generation_contract.get("group_tension_bias", "")).to_lower()
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).to_lower()
	if pressure_ids.has("exposure"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if pressure_ids.has("delay"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
		if slot >= int(room_count / 2):
			next["hazard"] = int(next.get("hazard", 0)) + 1
	if pressure_ids.has("fragmentation") or pressure_ids.has("misdirection") or motif_ids.has("split_echoes"):
		next["hazard"] = int(next.get("hazard", 0)) + 1
	if motif_ids.has("archive_scars"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if item_ecology_bias.find("rescue") != -1:
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if item_ecology_bias.find("scarcity") != -1:
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if item_ecology_bias.find("deception") != -1 or group_tension_bias.find("ambiguous") != -1:
		next["hazard"] = int(next.get("hazard", 0)) + 1
	if convergence_axis.find("custody") != -1:
		next["traversal"] = int(next.get("traversal", 0)) + 1
	return next

func _apply_branch_family_room_weights(weights: Dictionary, branch_family: Dictionary) -> Dictionary:
	var next := weights.duplicate(true)
	if branch_family.is_empty():
		return next
	var branch_id := str(branch_family.get("id", ""))
	var witness_pressure := str(branch_family.get("witness_pressure", ""))
	var rescue_climate := str(branch_family.get("rescue_climate", ""))
	var route_commitment := str(branch_family.get("route_commitment", ""))
	var escape_bandwidth := str(branch_family.get("escape_bandwidth", ""))
	var challenge_texture := str(branch_family.get("challenge_texture", ""))
	var social_pressure := str(branch_family.get("social_pressure", ""))
	var symbolic_places := Array(branch_family.get("symbolic_places", []))
	if witness_pressure in ["high", "public", "focused"]:
		next["evidence"] = int(next.get("evidence", 0)) + 2
	elif witness_pressure in ["partial", "split"]:
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if rescue_climate in ["visible_recovery", "covering_retreat", "burden_defense"]:
		next["traversal"] = int(next.get("traversal", 0)) + 2
	elif rescue_climate == "late_salvage":
		next["hazard"] = int(next.get("hazard", 0)) + 1
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if route_commitment == "fluid":
		next["traversal"] = int(next.get("traversal", 0)) + 2
	elif route_commitment in ["hard_commitment", "greedy_detour"]:
		next["hazard"] = int(next.get("hazard", 0)) + 1
	if escape_bandwidth in ["tight", "narrow", "uncertain"]:
		next["hazard"] = int(next.get("hazard", 0)) + 2
	elif escape_bandwidth in ["broad", "swinging"]:
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if challenge_texture.find("temptation") != -1 or social_pressure.find("temptation") != -1 or social_pressure.find("cursed") != -1:
		next["evidence"] = int(next.get("evidence", 0)) + 1
		next["hazard"] = int(next.get("hazard", 0)) + 1
	if symbolic_places.has("pedestal") or symbolic_places.has("drop line"):
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if symbolic_places.has("relay gate") or symbolic_places.has("regroup lane") or symbolic_places.has("bridge"):
		next["traversal"] = int(next.get("traversal", 0)) + 1
	match branch_id:
		"oath_terraces":
			next["evidence"] = int(next.get("evidence", 0)) + 1
			next["traversal"] = int(next.get("traversal", 0)) + 3
		"murmur_warrens":
			next["hazard"] = int(next.get("hazard", 0)) + 1
			next["evidence"] = int(next.get("evidence", 0)) + 1
	return next

func _apply_run_identity_room_weights(weights: Dictionary, slot: int, room_count: int, branch_family: Dictionary, generation_contract: Dictionary) -> Dictionary:
	var next := weights.duplicate(true)
	var force_tokens := _contract_force_tokens(generation_contract)
	var pressure_tokens := _contract_pressure_tokens(generation_contract)
	var motif_tokens := _contract_motif_tokens(generation_contract)
	var archive_tone := str(generation_contract.get("archive_tone", "")).to_lower()
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var group_tension_bias := str(generation_contract.get("group_tension_bias", "")).to_lower()
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).to_lower()
	var witness_pressure := str(branch_family.get("witness_pressure", ""))
	var rescue_climate := str(branch_family.get("rescue_climate", ""))
	var burden_pressure := str(branch_family.get("burden_pressure", ""))
	var social_pressure := str(branch_family.get("social_pressure", ""))
	var challenge_texture := str(branch_family.get("challenge_texture", ""))
	var confrontation_climate := str(branch_family.get("confrontation_climate", ""))
	var regroup_friction := str(branch_family.get("regroup_friction", ""))
	var route_commitment := str(branch_family.get("route_commitment", ""))
	var escape_bandwidth := str(branch_family.get("escape_bandwidth", ""))
	var symbolic_places := _string_array(branch_family.get("symbolic_places", []))
	if force_tokens.has("discovery") or item_ecology_bias.find("rescue") != -1:
		next["traversal"] = int(next.get("traversal", 0)) + 1
		if route_commitment in ["fluid", "staged_commitment"] or symbolic_places.has("relay gate") or symbolic_places.has("bridge") or symbolic_places.has("handoff point"):
			next["traversal"] = int(next.get("traversal", 0)) + 1
		if slot >= int(room_count / 2) and escape_bandwidth in ["tight", "narrow", "uncertain"]:
			next["hazard"] = int(next.get("hazard", 0)) + 1
	if force_tokens.has("memory") or archive_tone.find("memory") != -1 or archive_tone.find("forensic") != -1:
		next["evidence"] = int(next.get("evidence", 0)) + 1
		if archive_tone.find("memory") != -1 or archive_tone.find("forensic") != -1 or symbolic_places.has("pedestal") or symbolic_places.has("drop line") or symbolic_places.has("return threshold"):
			next["evidence"] = int(next.get("evidence", 0)) + 1
	if force_tokens.has("deception") or group_tension_bias.find("fault") != -1 or group_tension_bias.find("ambiguous") != -1:
		if social_pressure.find("fracture") != -1 or social_pressure.find("temptation") != -1 or social_pressure.find("cursed") != -1 or confrontation_climate.find("public") != -1 or confrontation_climate.find("cutoff") != -1:
			next["hazard"] = int(next.get("hazard", 0)) + 1
			next["evidence"] = int(next.get("evidence", 0)) + 1
	if item_ecology_bias.find("burden") != -1:
		next["traversal"] = int(next.get("traversal", 0)) + 1
	if item_ecology_bias.find("deception") != -1 or item_ecology_bias.find("scandal") != -1:
		next["hazard"] = int(next.get("hazard", 0)) + 1
	if item_ecology_bias.find("scarcity") != -1:
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if convergence_axis.find("fragment") != -1:
		next["hazard"] = int(next.get("hazard", 0)) + 1
		if regroup_friction in ["high", "moderate"]:
			next["hazard"] = int(next.get("hazard", 0)) + 1
	elif convergence_axis.find("converg") != -1 or convergence_axis.find("custody") != -1:
		next["traversal"] = int(next.get("traversal", 0)) + 1
		if burden_pressure.find("carry") != -1 or burden_pressure.find("handoff") != -1 or burden_pressure.find("escort") != -1 or symbolic_places.has("pedestal") or symbolic_places.has("handoff point"):
			next["evidence"] = int(next.get("evidence", 0)) + 1
	if (motif_tokens.has("threshold_marks") or motif_tokens.has("archive_scars") or motif_tokens.has("burden_halos")) and (symbolic_places.has("pedestal") or symbolic_places.has("drop line") or symbolic_places.has("threshold") or symbolic_places.has("return threshold")):
		next["evidence"] = int(next.get("evidence", 0)) + 1
	if slot >= int(room_count / 2):
		if challenge_texture.find("temptation") != -1 or challenge_texture.find("risk") != -1:
			next["hazard"] = int(next.get("hazard", 0)) + 1
		if witness_pressure in ["high", "public", "focused"] and pressure_tokens.has("exposure"):
			next["evidence"] = int(next.get("evidence", 0)) + 1
	if archive_tone.find("memory") != -1 or archive_tone.find("custody") != -1:
		next["evidence"] = int(next.get("evidence", 0)) + 1
	elif archive_tone.find("dispute") != -1 and slot >= int(room_count / 2):
		next["hazard"] = int(next.get("hazard", 0)) + 1
	if group_tension_bias.find("fault") != -1 or group_tension_bias.find("ambiguous") != -1:
		next["hazard"] = int(next.get("hazard", 0)) + 1
	if rescue_climate in ["visible_recovery", "covering_retreat", "burden_defense"] and convergence_axis.find("custody") != -1:
		next["traversal"] = int(next.get("traversal", 0)) + 1
	return next

func _apply_protocol_room_weights(weights: Dictionary, slot: int, room_count: int, generation_contract: Dictionary) -> Dictionary:
	var next := weights.duplicate(true)
	var protocol_state := str(generation_contract.get("protocol_state", "")).strip_edges()
	var early_cutoff := maxi(int(room_count / 3), 3)
	var late_start := maxi(int(room_count * 2 / 3), 1)
	match protocol_state:
		"Expedition Protocol":
			next["traversal"] = int(next.get("traversal", 0)) + 3
			next["evidence"] = int(next.get("evidence", 0)) + 1
			if slot < early_cutoff:
				next["evidence"] = int(next.get("evidence", 0)) + 1
			elif slot >= late_start:
				next["traversal"] = int(next.get("traversal", 0)) + 1
		"Fracture Protocol":
			next["hazard"] = int(next.get("hazard", 0)) + 2
			next["traversal"] = int(next.get("traversal", 0)) + 1
			if slot > 1 and slot < late_start:
				next["evidence"] = int(next.get("evidence", 0)) + 1
			if slot >= late_start:
				next["hazard"] = int(next.get("hazard", 0)) + 1
		"Intimate Protocol":
			next["traversal"] = int(next.get("traversal", 0)) + 2
			next["evidence"] = int(next.get("evidence", 0)) + 1
			if slot > 1 and slot < late_start:
				next["evidence"] = int(next.get("evidence", 0)) + 1
			if slot >= late_start:
				next["traversal"] = int(next.get("traversal", 0)) + 1
		"Exposure Protocol":
			next["evidence"] = int(next.get("evidence", 0)) + 3
			if slot < early_cutoff:
				next["evidence"] = int(next.get("evidence", 0)) + 1
			if slot >= late_start:
				next["hazard"] = int(next.get("hazard", 0)) + 2
	return next

func _branch_family_weight(branch_family: Dictionary, generation_contract: Dictionary) -> int:
	var weight := 3
	var branch_id := str(branch_family.get("id", ""))
	var motif_ids := _contract_motif_tokens(generation_contract)
	var dominant_minds := _contract_mind_tokens(generation_contract)
	var relationship_routing: Dictionary = Dictionary(generation_contract.get("relationship_routing", {}))
	var relay_routing: Dictionary = Dictionary(generation_contract.get("relay_routing", {}))
	var cookbook_routing: Dictionary = Dictionary(generation_contract.get("cookbook_routing", {}))
	var lead_mind_id := dominant_minds[0] if not dominant_minds.is_empty() else ""
	var convergence_axis := str(generation_contract.get("convergence_axis", "balanced"))
	var protocol_state := str(generation_contract.get("protocol_state", "")).strip_edges()
	var pressure_tokens := _contract_pressure_tokens(generation_contract)
	var ontology_route_tags := _ontology_route_tags(generation_contract)
	var lifecycle_routing: Dictionary = Dictionary(generation_contract.get("lifecycle_routing", {}))
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	weight += _protocol_branch_bonus(branch_family, protocol_state)
	weight += _lifecycle_branch_bonus(branch_family, lifecycle_routing)
	if motif_ids.has("threshold_marks") and str(branch_family.get("witness_pressure", "")) in ["high", "public", "focused"]:
		weight += 3
	if motif_ids.has("sealed_ribs") and str(branch_family.get("escape_bandwidth", "")) in ["uncertain", "narrow", "tight"]:
		weight += 3
	if motif_ids.has("archive_scars") and (str(branch_family.get("challenge_texture", "")).find("temptation") != -1 or Array(branch_family.get("symbolic_places", [])).has("pedestal")):
		weight += 3
	if motif_ids.has("split_echoes") and (str(branch_family.get("social_pressure", "")).find("fracture") != -1 or str(branch_family.get("confrontation_climate", "")).find("cutoff") != -1):
		weight += 3
	if motif_ids.has("burden_halos") and (str(branch_family.get("burden_pressure", "")).find("carry") != -1 or str(branch_family.get("burden_pressure", "")).find("handoff") != -1):
		weight += 3
	match lead_mind_id:
		"cartographer":
			if str(branch_family.get("route_commitment", "")) == "fluid" or Array(branch_family.get("symbolic_places", [])).has("relay gate"):
				weight += 2
		"trickster":
			if str(branch_family.get("confrontation_climate", "")).find("cutoff") != -1 or str(branch_family.get("social_pressure", "")).find("temptation") != -1:
				weight += 2
		"archivist":
			if Array(branch_family.get("symbolic_places", [])).has("pedestal") or Array(branch_family.get("symbolic_places", [])).has("drop line"):
				weight += 2
		"warden":
			if str(branch_family.get("escape_bandwidth", "")) in ["uncertain", "narrow", "tight"]:
				weight += 2
		"examiner":
			if str(branch_family.get("witness_pressure", "")) in ["high", "public", "focused"]:
				weight += 2
	if convergence_axis == "fragmentation" and str(branch_family.get("regroup_friction", "")) in ["high", "moderate"]:
		weight += 1
	elif convergence_axis == "convergence" and str(branch_family.get("rescue_climate", "")) in ["visible_recovery", "covering_retreat", "burden_defense"]:
		weight += 1
	if pressure_tokens.has("exposure") and str(branch_family.get("witness_pressure", "")) in ["high", "public", "focused"]:
		weight += 2
	if (pressure_tokens.has("convergence") or item_ecology_bias.find("rescue") != -1) and str(branch_family.get("rescue_climate", "")) in ["visible_recovery", "covering_retreat", "burden_defense"]:
		weight += 2
	if pressure_tokens.has("scarcity") and str(branch_family.get("escape_bandwidth", "")) in ["tight", "narrow", "uncertain"]:
		weight += 2
	if (motif_ids.has("archive_scars") or str(generation_contract.get("archive_tone", "")).to_lower().find("memory") != -1) and Array(branch_family.get("symbolic_places", [])).has("pedestal"):
		weight += 2
	if int(relationship_routing.get("escort_expectation", 0)) > 0 and (str(branch_family.get("burden_pressure", "")).find("escort") != -1 or str(branch_family.get("rescue_climate", "")) in ["visible_recovery", "covering_retreat", "burden_defense"]):
		weight += 2
	if int(relationship_routing.get("rescue_convergence", 0)) > 0 and (Array(branch_family.get("symbolic_places", [])).has("handoff point") or Array(branch_family.get("symbolic_places", [])).has("regroup lane") or str(branch_family.get("rescue_climate", "")) in ["visible_recovery", "late_salvage", "burden_defense"]):
		weight += 2
	if int(relationship_routing.get("witness_suspicion", 0)) > 0 and (str(branch_family.get("witness_pressure", "")) in ["high", "public", "focused"] or str(branch_family.get("confrontation_climate", "")).find("public") != -1):
		weight += 2
	if int(relationship_routing.get("regroup_strain", 0)) > 0 and str(branch_family.get("regroup_friction", "")) in ["high", "moderate"]:
		weight += 2
	if int(relay_routing.get("relay_overload", 0)) > 0 and (Array(branch_family.get("symbolic_places", [])).has("relay gate") or Array(branch_family.get("symbolic_places", [])).has("bridge")):
		weight += 3
	if int(relay_routing.get("distributed_witness", 0)) > 0 and str(branch_family.get("witness_pressure", "")) in ["high", "public", "focused"]:
		weight += 2
	if int(relay_routing.get("regroup_friction", 0)) > 0 and str(branch_family.get("regroup_friction", "")) in ["high", "moderate"]:
		weight += 2
	if int(relay_routing.get("rumor_heat", 0)) > 0 and (str(branch_family.get("social_pressure", "")).find("witness") != -1 or str(branch_family.get("confrontation_climate", "")).find("public") != -1):
		weight += 2
	if int(relay_routing.get("return_pressure", 0)) > 0 and (Array(branch_family.get("symbolic_places", [])).has("regroup lane") or str(branch_family.get("route_commitment", "")) in ["fluid", "staged_commitment"]):
		weight += 2
	if int(cookbook_routing.get("fragmentary_reading", 0)) > 0 and (Array(branch_family.get("symbolic_places", [])).has("pedestal") or Array(branch_family.get("symbolic_places", [])).has("threshold") or str(branch_family.get("challenge_texture", "")).find("temptation") != -1):
		weight += 2
	if int(cookbook_routing.get("holder_network", 0)) > 0 and (Array(branch_family.get("symbolic_places", [])).has("relay gate") or Array(branch_family.get("symbolic_places", [])).has("handoff point") or str(branch_family.get("route_commitment", "")) in ["fluid", "staged_commitment"]):
		weight += 2
	if int(cookbook_routing.get("counter_reading", 0)) > 0 and (str(branch_family.get("social_pressure", "")).find("temptation") != -1 or str(branch_family.get("confrontation_climate", "")).find("cutoff") != -1):
		weight += 2
	if int(cookbook_routing.get("anti_protocol_pull", 0)) > 0 and (Array(branch_family.get("symbolic_places", [])).has("relay gate") or Array(branch_family.get("symbolic_places", [])).has("handoff arch") or str(branch_family.get("route_commitment", "")) == "fluid"):
		weight += 3
	if ontology_route_tags.has("rediscovery_loop") and (Array(branch_family.get("symbolic_places", [])).has("pedestal") or Array(branch_family.get("symbolic_places", [])).has("return threshold") or str(branch_family.get("challenge_texture", "")).find("temptation") != -1):
		weight += 2
	if ontology_route_tags.has("taboo_threshold") and (Array(branch_family.get("symbolic_places", [])).has("threshold") or Array(branch_family.get("symbolic_places", [])).has("handoff arch") or str(branch_family.get("confrontation_climate", "")).find("cutoff") != -1):
		weight += 2
	if ontology_route_tags.has("ritual_commitment") and (Array(branch_family.get("symbolic_places", [])).has("bridge") or Array(branch_family.get("symbolic_places", [])).has("handoff point") or str(branch_family.get("rescue_climate", "")).find("burden") != -1):
		weight += 2
	match branch_id:
		"oath_terraces":
			if int(relationship_routing.get("escort_expectation", 0)) > 0 or int(relationship_routing.get("obligation_risk", 0)) > 0:
				weight += 2
			if int(Dictionary(generation_contract.get("civilization_routing", {})).get("legitimacy_custody", 0)) > 0 or int(Dictionary(generation_contract.get("civilization_routing", {})).get("sacred_order", 0)) > 0:
				weight += 3
		"murmur_warrens":
			if int(cookbook_routing.get("counter_reading", 0)) > 0 or int(cookbook_routing.get("anti_protocol_pull", 0)) > 0:
				weight += 3
			if int(Dictionary(generation_contract.get("civilization_routing", {})).get("canon_conflict", 0)) > 0 or int(Dictionary(generation_contract.get("civilization_routing", {})).get("ontology_heat", 0)) > 0:
				weight += 2
	weight += _public_summary_branch_bonus(branch_family, generation_contract)
	return maxi(weight, 1)

func _public_summary_branch_bonus(branch_family: Dictionary, generation_contract: Dictionary) -> int:
	var bonus := 0
	var force_tokens := _contract_force_tokens(generation_contract)
	var pressure_tokens := _contract_pressure_tokens(generation_contract)
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var group_tension_bias := str(generation_contract.get("group_tension_bias", "")).to_lower()
	var archive_tone := str(generation_contract.get("archive_tone", "")).to_lower()
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).to_lower()
	var ontology_route_tags := _ontology_route_tags(generation_contract)
	var rescue_climate := str(branch_family.get("rescue_climate", ""))
	var burden_pressure := str(branch_family.get("burden_pressure", ""))
	var social_pressure := str(branch_family.get("social_pressure", ""))
	var challenge_texture := str(branch_family.get("challenge_texture", ""))
	var confrontation_climate := str(branch_family.get("confrontation_climate", ""))
	var regroup_friction := str(branch_family.get("regroup_friction", ""))
	var route_commitment := str(branch_family.get("route_commitment", ""))
	var escape_bandwidth := str(branch_family.get("escape_bandwidth", ""))
	var witness_pressure := str(branch_family.get("witness_pressure", ""))
	var symbolic_places := _string_array(branch_family.get("symbolic_places", []))
	if (force_tokens.has("discovery") or item_ecology_bias.find("rescue") != -1) and (route_commitment in ["fluid", "staged_commitment"] or symbolic_places.has("relay gate") or symbolic_places.has("bridge")):
		bonus += 2
	if (force_tokens.has("memory") or archive_tone.find("memory") != -1 or archive_tone.find("forensic") != -1) and (symbolic_places.has("pedestal") or symbolic_places.has("drop line") or symbolic_places.has("return threshold")):
		bonus += 2
	if (force_tokens.has("deception") or group_tension_bias.find("fault") != -1 or group_tension_bias.find("ambiguous") != -1) and (social_pressure.find("fracture") != -1 or social_pressure.find("temptation") != -1 or social_pressure.find("cursed") != -1 or confrontation_climate.find("cutoff") != -1):
		bonus += 2
	if item_ecology_bias.find("rescue") != -1 and rescue_climate in ["visible_recovery", "covering_retreat", "burden_defense"]:
		bonus += 2
	if item_ecology_bias.find("burden") != -1 and (burden_pressure.find("carry") != -1 or burden_pressure.find("handoff") != -1 or burden_pressure.find("escort") != -1 or burden_pressure.find("value") != -1):
		bonus += 2
	if (item_ecology_bias.find("deception") != -1 or item_ecology_bias.find("scandal") != -1) and (social_pressure.find("temptation") != -1 or social_pressure.find("cursed") != -1 or confrontation_climate.find("cutoff") != -1):
		bonus += 2
	if item_ecology_bias.find("scarcity") != -1 and escape_bandwidth in ["tight", "narrow", "uncertain"]:
		bonus += 1
	if convergence_axis.find("custody") != -1 and (burden_pressure.find("carry") != -1 or burden_pressure.find("handoff") != -1 or symbolic_places.has("pedestal") or symbolic_places.has("handoff point") or symbolic_places.has("handoff arch")):
		bonus += 2
	elif convergence_axis.find("fragment") != -1 and (regroup_friction in ["high", "moderate"] or confrontation_climate.find("cutoff") != -1):
		bonus += 2
	if archive_tone.find("memory") != -1 or archive_tone.find("custody") != -1:
		if symbolic_places.has("pedestal") or symbolic_places.has("drop line") or symbolic_places.has("return threshold"):
			bonus += 1
	if archive_tone.find("forensic") != -1 and witness_pressure in ["high", "public", "focused"]:
		bonus += 1
	if archive_tone.find("dispute") != -1 and (social_pressure.find("fracture") != -1 or group_tension_bias.find("fault") != -1):
		bonus += 1
	if pressure_tokens.has("exposure") and witness_pressure in ["high", "public", "focused"]:
		bonus += 1
	if pressure_tokens.has("fragmentation") and regroup_friction in ["high", "moderate"]:
		bonus += 1
	if ontology_route_tags.has("rediscovery_loop") and (symbolic_places.has("pedestal") or symbolic_places.has("return threshold")):
		bonus += 1
	if ontology_route_tags.has("taboo_threshold") and (symbolic_places.has("threshold") or confrontation_climate.find("cutoff") != -1):
		bonus += 1
	return bonus

func _lifecycle_branch_bonus(branch_family: Dictionary, lifecycle_routing: Dictionary) -> int:
	var bonus := 0
	var branch_id := str(branch_family.get("id", "")).strip_edges()
	for family_raw in Array(lifecycle_routing.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_kind := str(family.get("family_kind", "")).strip_edges()
		var source_id := str(family.get("source_id", "")).strip_edges()
		var heat := int(family.get("heat", 0))
		var cooldown_band := str(family.get("cooldown_band", "open")).strip_edges()
		var successor_hint := str(family.get("successor_hint", "")).strip_edges().to_lower()
		var routing_tags := _string_array(family.get("routing_tags", []))
		if family_kind == "combo_family" and heat >= 3:
			if branch_id in ["relay_hollows", "watcher_steps", "oath_terraces"] and (_lifecycle_has_any_tag(routing_tags, ["route", "return", "artifact_custody", "route_memory"]) or successor_hint.find("route") != -1):
				bonus += 2
			if branch_id in ["grave_lattice", "forge_veins"] and (_lifecycle_has_any_tag(routing_tags, ["memory", "witness", "combo_private_archive_ritual"]) or successor_hint.find("archive") != -1):
				bonus += 2
			if cooldown_band == "deep_cooling" and branch_id in ["grave_lattice", "murmur_warrens"]:
				bonus += 1
		elif family_kind == "artifact_continuity":
			match source_id:
				"burial", "archive_only_residue":
					if branch_id in ["grave_lattice", "forge_veins"]:
						bonus += 3
				"recoverable_loss", "successor_emergence":
					if branch_id in ["relay_hollows", "oath_terraces", "watcher_steps"]:
						bonus += 3
				"extinction":
					if branch_id in ["sundered_span", "murmur_warrens"]:
						bonus += 2
	return bonus

func _lifecycle_risk_bias(lifecycle_routing: Dictionary) -> int:
	var risk_bias := 0
	for family_raw in Array(lifecycle_routing.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_kind := str(family.get("family_kind", "")).strip_edges()
		var source_id := str(family.get("source_id", "")).strip_edges()
		var cooldown_band := str(family.get("cooldown_band", "open")).strip_edges()
		if family_kind == "combo_family" and cooldown_band == "deep_cooling":
			risk_bias += 1
		elif family_kind == "artifact_continuity":
			if source_id == "extinction":
				risk_bias += 1
			elif source_id in ["recoverable_loss", "successor_emergence"]:
				risk_bias -= 1
	return risk_bias

func _lifecycle_has_any_tag(tags: Array[String], needles: Array[String]) -> bool:
	for tag in tags:
		var lowered := tag.to_lower()
		for needle in needles:
			if lowered.find(needle) != -1:
				return true
	return false

func _protocol_branch_bonus(branch_family: Dictionary, protocol_state: String) -> int:
	var bonus := 0
	var witness_pressure := str(branch_family.get("witness_pressure", ""))
	var rescue_climate := str(branch_family.get("rescue_climate", ""))
	var burden_pressure := str(branch_family.get("burden_pressure", ""))
	var social_pressure := str(branch_family.get("social_pressure", ""))
	var challenge_texture := str(branch_family.get("challenge_texture", ""))
	var confrontation_climate := str(branch_family.get("confrontation_climate", ""))
	var regroup_friction := str(branch_family.get("regroup_friction", ""))
	var escape_bandwidth := str(branch_family.get("escape_bandwidth", ""))
	var symbolic_places := Array(branch_family.get("symbolic_places", []))
	match protocol_state:
		"Expedition Protocol":
			if witness_pressure in ["high", "public", "focused"]:
				bonus += 2
			if str(branch_family.get("route_commitment", "")) in ["fluid", "staged_commitment"]:
				bonus += 2
			if symbolic_places.has("relay gate") or symbolic_places.has("bridge"):
				bonus += 1
		"Fracture Protocol":
			if social_pressure.find("fracture") != -1 or confrontation_climate.find("cutoff") != -1:
				bonus += 3
			if regroup_friction in ["high", "moderate"]:
				bonus += 2
			if escape_bandwidth in ["narrow", "tight", "uncertain"]:
				bonus += 1
		"Intimate Protocol":
			if rescue_climate in ["visible_recovery", "covering_retreat", "burden_defense", "late_salvage"]:
				bonus += 2
			if burden_pressure.find("carry") != -1 or burden_pressure.find("handoff") != -1 or burden_pressure.find("escort") != -1 or burden_pressure.find("fear") != -1:
				bonus += 2
			if symbolic_places.has("handoff point") or symbolic_places.has("regroup lane") or symbolic_places.has("return threshold"):
				bonus += 1
		"Exposure Protocol":
			if witness_pressure in ["high", "public", "focused"]:
				bonus += 2
			if challenge_texture.find("temptation") != -1 or challenge_texture.find("threshold") != -1 or challenge_texture.find("artifact") != -1:
				bonus += 2
			if social_pressure.find("cursed") != -1 or social_pressure.find("temptation") != -1 or social_pressure.find("witness") != -1:
				bonus += 1
	return bonus

func _branch_family_from_id(branch_family_id: String) -> Dictionary:
	for family_raw in BRANCH_FAMILIES:
		var family: Dictionary = Dictionary(family_raw)
		if str(family.get("id", "")) == branch_family_id:
			return family.duplicate(true)
	return {}

func _slot_band(slot: int, room_count: int) -> String:
	if slot <= 1:
		return "entry"
	if slot >= room_count - 2:
		return "deep"
	if slot >= int(room_count / 2):
		return "middle_late"
	return "middle_early"

func _symbolic_anchor(branch_family: Dictionary, slot: int) -> String:
	var anchors := Array(branch_family.get("symbolic_places", []))
	if anchors.is_empty():
		return ""
	return str(anchors[posmod(slot, anchors.size())])

func _pressure_profile(branch_family: Dictionary, slot: int, room_count: int, room_type: String, room_hazard: String, generation_contract: Dictionary = {}) -> Array[String]:
	var profile: Array[String] = [
		str(branch_family.get("social_pressure", "")),
		str(branch_family.get("challenge_texture", "")),
		str(branch_family.get("confrontation_climate", "")),
		str(branch_family.get("rescue_climate", "")),
		str(branch_family.get("burden_pressure", "")),
		"witness_%s" % str(branch_family.get("witness_pressure", "")),
		"route_%s" % str(branch_family.get("route_commitment", "")),
		"regroup_%s" % str(branch_family.get("regroup_friction", "")),
		"escape_%s" % str(branch_family.get("escape_bandwidth", ""))
	]
	if room_type == "hazard":
		profile.append("hazard_commitment")
	if room_type == "evidence":
		profile.append("temptation_focus")
	if room_hazard == "collapse":
		profile.append("collapse_watch")
	elif room_hazard == "push":
		profile.append("displacement_watch")
	elif room_hazard == "spikes":
		profile.append("fall_risk")
	if slot >= room_count - 2:
		profile.append("endgame_pressure")
	var pacing_id := str(generation_contract.get("pacing_profile", "")).strip_edges()
	if not pacing_id.is_empty():
		profile.append("pace_%s" % pacing_id)
	for verb_id in _contract_pressure_tokens(generation_contract).slice(0, 2):
		profile.append("verb_%s" % verb_id)
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).strip_edges()
	if not convergence_axis.is_empty() and convergence_axis != "balanced":
		profile.append(convergence_axis)
	for regime_id in _market_regime_ids(generation_contract).slice(0, 2):
		profile.append("market_%s" % regime_id)
	for pressure_id in _string_array(Dictionary(generation_contract.get("encounter_routing", {})).get("anchored_pressures", [])).slice(0, 2):
		profile.append(pressure_id)
	for pathology_id in _string_array(Dictionary(generation_contract.get("encounter_routing", {})).get("active_pathology_ids", [])).slice(0, 2):
		profile.append("pathology_%s" % pathology_id)
	for route_tag in _ontology_route_tags(generation_contract).slice(0, 2):
		profile.append(route_tag)
	return profile

func _run_identity(directive: Dictionary) -> Dictionary:
	return Dictionary(directive.get("run_identity", {}))

func _public_summary(directive: Dictionary) -> Dictionary:
	return Dictionary(directive.get("public_summary", {}))

func _domain_labels(public_summary: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in _string_array(public_summary.get("dominant_domains", [])):
		result.append(value.to_lower())
	return result

func _domain_has(domain_labels: Array[String], token: String) -> bool:
	var lowered := token.to_lower()
	for label in domain_labels:
		if label.find(lowered) != -1:
			return true
	return false

static func _normalize_contract_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _surface_group(directive: Dictionary, group_name: String) -> Dictionary:
	return Dictionary(Dictionary(directive.get("control_surfaces", {})).get(group_name, {}))

static func _force_labels_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> Array[String]:
	var labels := _normalize_contract_array(public_summary.get("dominant_forces", []))
	if not labels.is_empty():
		return labels
	for entry_raw in Array(run_identity.get("force_order", [])):
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if not label.is_empty() and not labels.has(label):
			labels.append(label)
		if labels.size() >= 2:
			return labels
	var generation := Dictionary(surfaces.get("generation", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	if int(generation.get("witness_exposure", 0)) > 0:
		labels.append("Trial")
	if int(ecology.get("stalking_bias", 0)) > 0 or int(economy.get("lure_abundance", 0)) > 0:
		labels.append("Deception")
	if int(generation.get("rescue_geometry", 0)) > 0 or int(economy.get("recovery_cushion", 0)) > 0:
		labels.append("Discovery")
	if int(economy.get("resource_austerity", 0)) > 0 or int(economy.get("commitment_cost", 0)) > 0:
		labels.append("Containment")
	if int(generation.get("loop_probability", 0)) > 0:
		labels.append("Memory")
	return _normalize_contract_array(labels)

static func _mind_labels_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> Array[String]:
	var labels := _normalize_contract_array(public_summary.get("dominant_minds", []))
	if not labels.is_empty():
		return labels
	for entry_raw in Array(run_identity.get("active_minds", [])):
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", entry.get("id", ""))).strip_edges()
		if not label.is_empty() and not labels.has(label):
			labels.append(label)
		if labels.size() >= 2:
			return labels
	var generation := Dictionary(surfaces.get("generation", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	if int(ecology.get("stalking_bias", 0)) > 0 or int(economy.get("lure_abundance", 0)) > 0:
		labels.append("Trickster")
	if int(generation.get("rescue_geometry", 0)) > 0 or int(economy.get("recovery_cushion", 0)) > 0:
		labels.append("Cartographer")
	if int(economy.get("resource_austerity", 0)) > 0 or int(economy.get("commitment_cost", 0)) > 0:
		labels.append("Warden")
	if int(generation.get("witness_exposure", 0)) > 0:
		labels.append("Examiner")
	if int(generation.get("loop_probability", 0)) > 0:
		labels.append("Archivist")
	return _normalize_contract_array(labels)

static func _pacing_profile_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> String:
	var pacing := str(public_summary.get("pacing_profile", "")).strip_edges()
	if not pacing.is_empty():
		return pacing
	pacing = str(Dictionary(run_identity.get("pacing_profile", {})).get("id", "")).strip_edges()
	if not pacing.is_empty():
		return pacing
	var generation := Dictionary(surfaces.get("generation", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	var harsh_score := maxi(int(ecology.get("inhabitant_pressure", 0)), 0) + maxi(int(ecology.get("stalking_bias", 0)), 0) + maxi(int(economy.get("resource_austerity", 0)), 0) + maxi(int(economy.get("lure_abundance", 0)), 0)
	var recovery_score := maxi(int(generation.get("rescue_geometry", 0)), 0) + maxi(int(economy.get("recovery_cushion", 0)), 0)
	if harsh_score >= 4:
		return "volatile"
	if recovery_score >= 3 and harsh_score <= 1:
		return "calm"
	return "steady"

static func _pressure_verbs_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> Array[String]:
	var verbs := _normalize_contract_array(public_summary.get("pressure_grammar", []))
	if not verbs.is_empty():
		return verbs
	for entry_raw in Array(run_identity.get("pressure_grammar", [])):
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if not label.is_empty() and not verbs.has(label):
			verbs.append(label)
	if not verbs.is_empty():
		return verbs
	var generation := Dictionary(surfaces.get("generation", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	if int(generation.get("witness_exposure", 0)) > 0:
		verbs.append("Exposure")
	if int(generation.get("loop_probability", 0)) > 0:
		verbs.append("Delay")
	if int(ecology.get("stalking_bias", 0)) > 0 or int(ecology.get("anomaly_contamination", 0)) > 0:
		verbs.append("Fragmentation")
	if int(economy.get("resource_austerity", 0)) > 0 or int(economy.get("commitment_cost", 0)) > 0:
		verbs.append("Scarcity")
	if int(economy.get("lure_abundance", 0)) > 0:
		verbs.append("Misdirection")
	if int(generation.get("rescue_geometry", 0)) > 0 or int(economy.get("recovery_cushion", 0)) > 0:
		verbs.append("Convergence")
	return _normalize_contract_array(verbs)

static func _symbolic_motifs_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> Array[String]:
	var motifs := _normalize_contract_array(public_summary.get("symbolic_motifs", []))
	if not motifs.is_empty():
		return motifs
	for entry_raw in Array(run_identity.get("symbolic_motifs", [])):
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if not label.is_empty() and not motifs.has(label):
			motifs.append(label)
	if not motifs.is_empty():
		return motifs
	var generation := Dictionary(surfaces.get("generation", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	if int(generation.get("witness_exposure", 0)) > 0 or int(generation.get("rescue_geometry", 0)) > 0:
		motifs.append("Threshold Marks")
	if int(economy.get("resource_austerity", 0)) > 0 or int(economy.get("commitment_cost", 0)) > 0:
		motifs.append("Burden Halos")
	if int(generation.get("loop_probability", 0)) > 0:
		motifs.append("Archive Scars")
	if int(ecology.get("stalking_bias", 0)) > 0 or int(ecology.get("anomaly_contamination", 0)) > 0 or int(economy.get("lure_abundance", 0)) > 0:
		motifs.append("Split Echoes")
	return _normalize_contract_array(motifs)

static func _item_ecology_bias_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> String:
	var text := str(public_summary.get("item_ecology_bias", "")).strip_edges()
	if not text.is_empty():
		return text
	var run_bias: Dictionary = Dictionary(run_identity.get("item_ecology_bias", {}))
	var axes := _normalize_contract_array(run_bias.get("dominant_axes", []))
	if not axes.is_empty():
		return " ".join(axes).strip_edges()
	var parts: Array[String] = []
	var generation := Dictionary(surfaces.get("generation", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	if int(generation.get("rescue_geometry", 0)) > 0 or int(economy.get("recovery_cushion", 0)) > 0:
		parts.append("rescue")
	if int(economy.get("resource_austerity", 0)) > 0:
		parts.append("scarcity")
	if int(economy.get("commitment_cost", 0)) > 0:
		parts.append("burden")
	if int(economy.get("lure_abundance", 0)) > 0:
		parts.append("deception")
	return " ".join(_normalize_contract_array(parts)).strip_edges()

static func _group_tension_bias_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> String:
	var text := str(public_summary.get("group_tension_bias", "")).strip_edges()
	if not text.is_empty():
		return text
	var run_bias: Dictionary = Dictionary(run_identity.get("group_tension_bias", {}))
	var parts: Array[String] = []
	if int(run_bias.get("trust_fragility", 0)) >= 2:
		parts.append("trust fragility")
	if int(run_bias.get("ambiguous_cause", 0)) >= 2:
		parts.append("ambiguous fault pressure")
	if not parts.is_empty():
		return " ".join(_normalize_contract_array(parts)).strip_edges()
	var generation := Dictionary(surfaces.get("generation", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	if int(generation.get("witness_exposure", 0)) > 0:
		parts.append("public answer appetite")
	if int(economy.get("resource_austerity", 0)) > 0 or int(economy.get("commitment_cost", 0)) > 0:
		parts.append("trust fragility")
	if int(ecology.get("stalking_bias", 0)) > 0 or int(ecology.get("anomaly_contamination", 0)) > 0 or int(economy.get("lure_abundance", 0)) > 0:
		parts.append("ambiguous fault pressure")
	return " ".join(_normalize_contract_array(parts)).strip_edges()

static func _archive_tone_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> String:
	var tone := str(public_summary.get("archive_tone", "")).strip_edges()
	if not tone.is_empty():
		return tone
	var generation := Dictionary(surfaces.get("generation", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	if int(generation.get("loop_probability", 0)) > 0:
		return "forensic memory"
	if int(generation.get("rescue_geometry", 0)) > 0 or int(economy.get("recovery_cushion", 0)) > 0 or int(economy.get("commitment_cost", 0)) > 0:
		return "memory custody"
	if int(ecology.get("anomaly_contamination", 0)) > 0 or int(economy.get("lure_abundance", 0)) > 0:
		return "forensic dispute"
	return "measured memory"

static func _convergence_axis_from_sources(public_summary: Dictionary, run_identity: Dictionary, surfaces: Dictionary) -> String:
	var axis := str(public_summary.get("convergence_axis", "")).strip_edges()
	if not axis.is_empty():
		return axis
	axis = str(Dictionary(run_identity.get("convergence_fragmentation", {})).get("axis", "")).strip_edges()
	if not axis.is_empty():
		return axis
	var generation := Dictionary(surfaces.get("generation", {}))
	var ecology := Dictionary(surfaces.get("ecology", {}))
	var economy := Dictionary(surfaces.get("economy", {}))
	if int(generation.get("rescue_geometry", 0)) > 0 or int(economy.get("recovery_cushion", 0)) > 0:
		return "artifact custody"
	if int(ecology.get("stalking_bias", 0)) > 0 or int(ecology.get("anomaly_contamination", 0)) > 0 or int(economy.get("lure_abundance", 0)) > 0:
		return "fragmentation"
	return "balanced"

func _contract_pressure_tokens(generation_contract: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in _string_array(generation_contract.get("pressure_verbs", [])):
		var token := value.to_lower().replace(" ", "_")
		if not token.is_empty() and not result.has(token):
			result.append(token)
	return result

func _contract_motif_tokens(generation_contract: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in _string_array(generation_contract.get("symbolic_motifs", [])):
		var token := value.to_lower().replace(" ", "_")
		if not token.is_empty() and not result.has(token):
			result.append(token)
	return result

func _contract_force_tokens(generation_contract: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in _string_array(generation_contract.get("dominant_forces", [])):
		var lowered := value.to_lower()
		for token in ["trial", "deception", "memory", "discovery", "containment"]:
			if lowered.find(token) != -1 and not result.has(token):
				result.append(token)
	return result

func _contract_mind_tokens(generation_contract: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in _string_array(generation_contract.get("dominant_minds", [])):
		var lowered := value.to_lower()
		for token in ["cartographer", "trickster", "archivist", "warden", "examiner"]:
			if lowered.find(token) != -1 and not result.has(token):
				result.append(token)
	return result

func _contract_pacing_token(generation_contract: Dictionary) -> String:
	var lowered := str(generation_contract.get("pacing_profile", "")).to_lower().strip_edges()
	for token in ["volatile", "escalating", "calm", "steady"]:
		if lowered.find(token) != -1:
			return token
	return lowered

func _generation_surface_lines(generation_contract: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).strip_edges()
	var archive_tone := str(generation_contract.get("archive_tone", "")).strip_edges()
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var pressure_tokens := _contract_pressure_tokens(generation_contract)
	var market_routing: Dictionary = Dictionary(generation_contract.get("market_routing", {}))
	var encounter_routing: Dictionary = Dictionary(generation_contract.get("encounter_routing", {}))
	var apex_routing: Dictionary = Dictionary(generation_contract.get("apex_routing", {}))
	if convergence_axis.to_lower().find("fragment") != -1:
		lines.append("Fragmentation is splitting the public answer.")
	elif convergence_axis.to_lower().find("custody") != -1 or item_ecology_bias.find("rescue") != -1:
		lines.append("Rescue geometry is drawing the public answer.")
	elif pressure_tokens.has("exposure"):
		lines.append("Exposure is sharpening the public answer.")
	if int(market_routing.get("market_volatility", 0)) > 0:
		lines.append("Market volatility is pushing the route toward unstable commitments.")
	elif int(market_routing.get("scarcity_recovery", 0)) > 0 or int(market_routing.get("recovery_credit", 0)) >= 2:
		lines.append("Recovery credit is keeping the market ecology from collapsing into scarcity.")
	if int(market_routing.get("prestige_pressure", 0)) > 0:
		lines.append("Prestige pressure is making public carriers easier to read.")
	elif int(market_routing.get("hoard_visibility", 0)) > 0:
		lines.append("Hoard visibility is exposing where value is getting stuck.")
	if archive_tone.to_lower().find("memory") != -1 or archive_tone.to_lower().find("custody") != -1:
		lines.append("Artifact custody is shaping what the archive will remember.")
	elif archive_tone.to_lower().find("forensic") != -1 or archive_tone.to_lower().find("dispute") != -1:
		lines.append("Forensic dispute is keeping the route under witness.")
	for line in _string_array(encounter_routing.get("encounter_lines", [])):
		if not lines.has(line):
			lines.append(line)
	if not _string_array(encounter_routing.get("active_pathology_ids", [])).is_empty():
		lines.append("Pathology pressure is feeding live encounter routing.")
	for line in _string_array(apex_routing.get("apex_lines", [])):
		if not lines.has(line):
			lines.append(line)
	if int(apex_routing.get("peak_spacing_score", 0)) >= 3:
		lines.append("Peak structure is staging a readable crisis window.")
	for line in _ontology_public_lines(generation_contract):
		if not lines.has(line):
			lines.append(line)
	if lines.is_empty():
		lines.append("Traversal pressure is staying legible.")
	return lines.slice(0, 2)

func _market_regime_ids(generation_contract: Dictionary) -> Array[String]:
	return _string_array(Dictionary(generation_contract.get("market_routing", {})).get("active_regime_ids", []))

func _ontology_route_tags(generation_contract: Dictionary) -> Array[String]:
	return _string_array(Dictionary(generation_contract.get("ontology_routing", {})).get("route_bias_tags", []))

func _ontology_public_lines(generation_contract: Dictionary) -> Array[String]:
	return _string_array(Dictionary(generation_contract.get("ontology_routing", {})).get("public_lines", []))

func _entry_ids(entries: Array) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var id := str(entry.get("id", "")).strip_edges()
		if not id.is_empty() and not result.has(id):
			result.append(id)
	return result

func _entry_labels(entries: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		result.append(label)
		if result.size() >= limit:
			break
	return result

func _state_labels(entries: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		var role_name := str(entry.get("role", "")).strip_edges()
		result.append("%s (%s)" % [label, role_name] if not role_name.is_empty() else label)
		if result.size() >= limit:
			break
	return result

func _first_mind_id(entries: Array) -> String:
	if entries.is_empty():
		return ""
	return str(Dictionary(entries[0]).get("id", "")).strip_edges()

func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
