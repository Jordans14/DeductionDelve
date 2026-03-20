class_name ArtifactService
extends RefCounted

const PICKUP_RANGE := 72.0
const STEAL_RANGE := 78.0
const ROOM_WIDTH := 1024.0
const ROOM_HEIGHT := 768.0
const ROOM_COLUMNS := 5
const ARTIFACT_CONSEQUENCE_VERSION := 1

func spawn_for_chain(seed_value: int, room_chain: Array) -> Array:
	var artifacts: Array = []
	var next_id := 1
	for room in room_chain:
		var slot := int(room.get("slot", -1))
		if slot < 0:
			continue
		var spawn_count := _spawn_count_for_room(room)
		for spawn_index in spawn_count:
			var artifact := _create_artifact(seed_value, next_id, room, spawn_index)
			artifacts.append(artifact)
			next_id += 1
	return artifacts

func real_signature(seed_value: int, artifact_id: int, room_slot: int, spawn_index: int) -> String:
	var raw := _signature_raw(seed_value, artifact_id, room_slot, spawn_index)
	return "A%08X" % raw

func forged_signature(seed_value: int, artifact_id: int, room_slot: int, spawn_index: int) -> String:
	var real_raw := _signature_raw(seed_value, artifact_id, room_slot, spawn_index)
	var forged_raw := real_raw ^ 0x00A5A5A5
	return "F%08X" % (forged_raw & 0x7FFFFFFF)

func forge_spawn_index_from_counter(forge_counter: int) -> int:
	return posmod(forge_counter, 4)

func build_forged_artifact(seed_value: int, artifact_id: int, room_slot: int, forge_counter: int, world_pos: Vector2) -> Dictionary:
	var spawn_index := forge_spawn_index_from_counter(forge_counter)
	return {
		"artifact_id": artifact_id,
		"room_slot": room_slot,
		"spawn_index": spawn_index,
		"signature": forged_signature(seed_value, artifact_id, room_slot, spawn_index),
		"is_forged": true,
		"owner_peer_id": 0,
		"world_pos": world_pos
	}

func authenticity_state(artifact: Dictionary) -> String:
	return "counterfeit" if bool(artifact.get("is_forged", false)) else "authentic"

func summarize_authenticity(artifacts_state: Dictionary) -> Dictionary:
	var summary := {
		"authentic": 0,
		"counterfeit": 0,
		"total": 0
	}
	for artifact_raw in artifacts_state.values():
		var artifact: Dictionary = artifact_raw
		var state := authenticity_state(artifact)
		summary[state] = int(summary.get(state, 0)) + 1
		summary["total"] = int(summary.get("total", 0)) + 1
	return summary

func summarize_custody_chain(artifacts_state: Dictionary, extraction_details: Dictionary = {}) -> Dictionary:
	var extracted_artifact_id := int(extraction_details.get("artifact_id", 0))
	var carried_authentic := 0
	var carried_counterfeit := 0
	var buried_authentic := 0
	var buried_counterfeit := 0
	for artifact_id_variant in artifacts_state.keys():
		var artifact_id := int(artifact_id_variant)
		if artifact_id == extracted_artifact_id:
			continue
		var artifact: Dictionary = Dictionary(artifacts_state.get(artifact_id_variant, {}))
		var owner_peer_id := int(artifact.get("owner_peer_id", 0))
		if authenticity_state(artifact) == "counterfeit":
			if owner_peer_id > 0:
				carried_counterfeit += 1
			else:
				buried_counterfeit += 1
		elif owner_peer_id > 0:
			carried_authentic += 1
		else:
			buried_authentic += 1
	var summary_id := "settled"
	if carried_authentic > 0 and carried_counterfeit > 0:
		summary_id = "contested_carry"
	elif carried_counterfeit > 0:
		summary_id = "counterfeit_carry"
	elif carried_authentic > 0:
		summary_id = "authentic_carry"
	elif buried_authentic > 0 and buried_counterfeit > 0:
		summary_id = "contested_burial"
	elif buried_counterfeit > 0:
		summary_id = "counterfeit_residue"
	elif buried_authentic > 0:
		summary_id = "buried_line"
	return {
		"summary_id": summary_id,
		"authentic_carried_count": carried_authentic,
		"counterfeit_carried_count": carried_counterfeit,
		"authentic_buried_count": buried_authentic,
		"counterfeit_buried_count": buried_counterfeit,
		"carried_unresolved_count": carried_authentic + carried_counterfeit,
		"buried_unresolved_count": buried_authentic + buried_counterfeit
	}

func build_consequence_contract(
	reason: String,
	artifacts_state: Dictionary,
	continuity_summary: Dictionary,
	extraction_details: Dictionary = {},
	market_regime_id: String = "",
	market_carrier_risk_band: String = ""
) -> Dictionary:
	var authenticity: Dictionary = summarize_authenticity(artifacts_state)
	var custody_summary: Dictionary = summarize_custody_chain(artifacts_state, extraction_details)
	var continuity_state := str(continuity_summary.get("state", "")).strip_edges()
	var unresolved_counterfeit := int(continuity_summary.get("unresolved_counterfeit_count", 0))
	var carried_unresolved := int(custody_summary.get("carried_unresolved_count", continuity_summary.get("carried_unresolved_count", 0)))
	var buried_unresolved := int(custody_summary.get("buried_unresolved_count", continuity_summary.get("buried_unresolved_count", 0)))
	var extracted_artifact_id := int(extraction_details.get("artifact_id", 0))
	var extracted_authenticity := ""
	if extracted_artifact_id != 0 and artifacts_state.has(extracted_artifact_id):
		extracted_authenticity = authenticity_state(Dictionary(artifacts_state.get(extracted_artifact_id, {})))
	var authenticity_state_id := _artifact_authenticity_state_for_consequence(authenticity, extracted_authenticity)
	var custody_chain_summary := str(custody_summary.get("summary_id", "settled")).strip_edges()
	var burden_band := _artifact_burden_band_for_consequence(reason, continuity_state, carried_unresolved, buried_unresolved, extracted_authenticity)
	var valuation_band := _artifact_valuation_band_for_consequence(continuity_state, extracted_authenticity, market_regime_id)
	var return_consequence_state := _artifact_return_state_for_consequence(reason, continuity_state, extracted_authenticity)
	var consequence_event_family := _artifact_consequence_event_family(reason, continuity_state, extracted_authenticity)
	var public_consequence_tags := _artifact_public_consequence_tags(
		consequence_event_family,
		burden_band,
		return_consequence_state,
		continuity_state,
		market_regime_id
	)
	var encounter_hook_tags := _artifact_encounter_hook_tags(
		burden_band,
		return_consequence_state,
		continuity_state,
		market_carrier_risk_band,
		extracted_authenticity
	)
	var social_hook_tags := _artifact_social_hook_tags(
		custody_chain_summary,
		continuity_state,
		extracted_authenticity,
		unresolved_counterfeit
	)
	var return_pressure_tags := _artifact_return_pressure_tags(
		return_consequence_state,
		burden_band,
		market_carrier_risk_band
	)
	return {
		"artifact_consequence_version": ARTIFACT_CONSEQUENCE_VERSION,
		"authenticity_state": authenticity_state_id,
		"custody_chain_summary": custody_chain_summary,
		"burden_band": burden_band,
		"valuation_band": valuation_band,
		"return_consequence_state": return_consequence_state,
		"artifact_continuity_state": continuity_state,
		"artifact_continuity_text": str(continuity_summary.get("text", "")).strip_edges(),
		"artifact_unresolved_counterfeit_count": unresolved_counterfeit,
		"market_regime_id": market_regime_id.strip_edges(),
		"market_carrier_risk_band": market_carrier_risk_band.strip_edges(),
		"public_consequence_tags": public_consequence_tags.duplicate(),
		"consequence_event_family": consequence_event_family,
		"encounter_hook_tags": encounter_hook_tags.duplicate(),
		"social_hook_tags": social_hook_tags.duplicate(),
		"return_pressure_tags": return_pressure_tags.duplicate()
	}

func can_pickup(artifact: Dictionary, player_pos: Vector2, max_range: float = PICKUP_RANGE) -> bool:
	if int(artifact.get("owner_peer_id", 0)) != 0:
		return false
	var pos: Vector2 = artifact.get("world_pos", Vector2.ZERO)
	return pos.distance_to(player_pos) <= max_range

func can_drop(artifact: Dictionary, actor_peer_id: int) -> bool:
	return int(artifact.get("owner_peer_id", 0)) == actor_peer_id

func can_steal(artifact: Dictionary, stealer_pos: Vector2, carrier_pos: Vector2, max_range: float = STEAL_RANGE) -> bool:
	var owner := int(artifact.get("owner_peer_id", 0))
	if owner == 0:
		return false
	return stealer_pos.distance_to(carrier_pos) <= max_range

func apply_owner(artifact: Dictionary, owner_peer_id: int, world_pos: Vector2) -> Dictionary:
	var next := artifact.duplicate(true)
	next["owner_peer_id"] = owner_peer_id
	next["world_pos"] = world_pos
	return next

func world_pos_for_room_spawn_for_test(room: Dictionary, spawn_index: int) -> Vector2:
	return _world_pos_for_room_spawn(room, spawn_index)

func _create_artifact(seed_value: int, artifact_id: int, room: Dictionary, spawn_index: int) -> Dictionary:
	var room_slot := int(room.get("slot", -1))
	return {
		"artifact_id": artifact_id,
		"room_slot": room_slot,
		"spawn_index": spawn_index,
		"signature": real_signature(seed_value, artifact_id, room_slot, spawn_index),
		"is_forged": false,
		"owner_peer_id": 0,
		"world_pos": _world_pos_for_room_spawn(room, spawn_index)
	}

func _spawn_count_for_room(room: Dictionary) -> int:
	var room_type := str(room.get("type", "traversal"))
	var risk := int(room.get("risk", 1))
	if room_type == "evidence":
		return 2
	if risk >= 3:
		return 1
	return 0

func _world_pos_for_room_spawn(room: Dictionary, spawn_index: int) -> Vector2:
	var room_slot := int(room.get("slot", -1))
	var room_type := str(room.get("type", "traversal"))
	var room_id := str(room.get("id", ""))
	var grid_x := posmod(room_slot, ROOM_COLUMNS)
	var grid_y := int(floor(float(room_slot) / float(ROOM_COLUMNS)))
	var room_origin := Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	var local_positions: Array[Vector2] = []
	match room_type:
		"evidence":
			match room_id:
				"evidence_vault":
					local_positions = [Vector2(512.0, 316.0), Vector2(752.0, 456.0)]
				"evidence_gap":
					local_positions = [Vector2(748.0, 258.0), Vector2(324.0, 460.0)]
				"evidence_choke":
					local_positions = [Vector2(516.0, 304.0), Vector2(272.0, 236.0)]
				_:
					local_positions = [Vector2(512.0, 320.0), Vector2(720.0, 448.0)]
		"hazard":
			match room_id:
				"hazard_push":
					local_positions = [Vector2(760.0, 286.0)]
				"hazard_collapse":
					local_positions = [Vector2(520.0, 492.0)]
				_:
					local_positions = [Vector2(712.0, 330.0)]
		_:
			local_positions = [Vector2(220.0, 336.0), Vector2(360.0, 420.0)]
	return room_origin + local_positions[min(spawn_index, local_positions.size() - 1)]

func _signature_raw(seed_value: int, artifact_id: int, room_slot: int, spawn_index: int) -> int:
	var seed_mix := int((seed_value * 1103515245) & 0x7FFFFFFF)
	var id_mix := int((artifact_id * 265443576) & 0x7FFFFFFF)
	var slot_mix := int((room_slot * 97531) & 0x7FFFFFFF)
	var spawn_mix := int((spawn_index * 7919) & 0x7FFFFFFF)
	var raw := seed_mix ^ id_mix ^ slot_mix ^ spawn_mix
	return raw & 0x7FFFFFFF

func _artifact_authenticity_state_for_consequence(authenticity: Dictionary, extracted_authenticity: String) -> String:
	if not extracted_authenticity.is_empty():
		return extracted_authenticity
	if int(authenticity.get("authentic", 0)) > 0 and int(authenticity.get("counterfeit", 0)) > 0:
		return "contested"
	if int(authenticity.get("authentic", 0)) > 0:
		return "authentic"
	if int(authenticity.get("counterfeit", 0)) > 0:
		return "counterfeit"
	return "unresolved"

func _artifact_burden_band_for_consequence(reason: String, continuity_state: String, carried_unresolved: int, buried_unresolved: int, extracted_authenticity: String) -> String:
	if reason == "session_interrupted":
		return "interrupted_burden"
	if extracted_authenticity == "authentic":
		return "released"
	if extracted_authenticity == "counterfeit":
		return "counterfeit_drag"
	if continuity_state == "burial" or buried_unresolved > 0:
		return "burial_weight"
	if carried_unresolved >= 2:
		return "heavy_carry"
	if carried_unresolved == 1:
		return "held_burden"
	if continuity_state == "archive_only_residue":
		return "residual_weight"
	return "light"

func _artifact_valuation_band_for_consequence(continuity_state: String, extracted_authenticity: String, market_regime_id: String) -> String:
	if extracted_authenticity == "authentic":
		return "sanctified"
	if extracted_authenticity == "counterfeit":
		return "disputed"
	if continuity_state == "fragmented_legacy":
		return "split_claim"
	if continuity_state == "archive_only_residue":
		return "residual"
	if continuity_state == "extinction":
		return "extinct"
	if market_regime_id.find("recovery") != -1:
		return "recovered"
	return "held"

func _artifact_return_state_for_consequence(reason: String, continuity_state: String, extracted_authenticity: String) -> String:
	if extracted_authenticity == "authentic":
		return "secured_return"
	if extracted_authenticity == "counterfeit":
		return "counterfeit_return"
	if reason == "tick_limit":
		return "stalled_return"
	if reason == "session_interrupted":
		return "interrupted_return"
	match continuity_state:
		"burial":
			return "buried_return"
		"recoverable_loss":
			return "recoverable_return"
		"fragmented_legacy":
			return "split_return"
		"archive_only_residue":
			return "residual_return"
		"extinction":
			return "extinguished_return"
		_:
			return "unresolved_return"

func _artifact_consequence_event_family(reason: String, continuity_state: String, extracted_authenticity: String) -> String:
	if extracted_authenticity == "authentic":
		return "artifact_authentic_resolution"
	if extracted_authenticity == "counterfeit":
		return "artifact_counterfeit_resolution"
	if reason == "session_interrupted":
		return "artifact_interrupted_continuity"
	match continuity_state:
		"burial":
			return "artifact_burial_line"
		"recoverable_loss":
			return "artifact_recoverable_loss"
		"fragmented_legacy":
			return "artifact_fragmented_legacy"
		"archive_only_residue":
			return "artifact_archive_residue"
		"extinction":
			return "artifact_line_extinction"
		_:
			return "artifact_unresolved_return"

func _artifact_public_consequence_tags(
	consequence_event_family: String,
	burden_band: String,
	return_consequence_state: String,
	continuity_state: String,
	market_regime_id: String
) -> Array[String]:
	var tags: Array[String] = []
	for tag in [consequence_event_family, "burden_%s" % burden_band, "return_%s" % return_consequence_state]:
		if not tag.is_empty() and not tags.has(tag):
			tags.append(tag)
	if continuity_state in ["burial", "recoverable_loss", "fragmented_legacy", "archive_only_residue", "extinction"]:
		var continuity_tag := "artifact_%s" % continuity_state
		if not tags.has(continuity_tag):
			tags.append(continuity_tag)
	if not market_regime_id.is_empty() and not tags.has(market_regime_id):
		tags.append(market_regime_id)
	return tags.slice(0, 6)

func _artifact_encounter_hook_tags(
	burden_band: String,
	return_consequence_state: String,
	continuity_state: String,
	market_carrier_risk_band: String,
	extracted_authenticity: String
) -> Array[String]:
	var tags: Array[String] = []
	if burden_band in ["heavy_carry", "held_burden", "counterfeit_drag"]:
		tags.append("custody_pressure")
	if burden_band == "burial_weight":
		tags.append("burial_pressure")
	if return_consequence_state in ["stalled_return", "counterfeit_return", "split_return"]:
		tags.append("route_pressure")
	if return_consequence_state in ["secured_return", "recoverable_return"]:
		tags.append("return_window")
	if continuity_state == "archive_only_residue":
		tags.append("archive_residue")
	if extracted_authenticity == "counterfeit":
		tags.append("false_line_pressure")
	if market_carrier_risk_band in ["volatile", "high", "contested"]:
		tags.append("carrier_risk_pressure")
	return tags

func _artifact_social_hook_tags(
	custody_chain_summary: String,
	continuity_state: String,
	extracted_authenticity: String,
	unresolved_counterfeit: int
) -> Array[String]:
	var tags: Array[String] = []
	if custody_chain_summary.find("carry") != -1:
		tags.append("public_obligation")
	if custody_chain_summary.find("contested") != -1:
		tags.append("custody_dispute")
	if extracted_authenticity == "counterfeit":
		tags.append("counterfeit_pressure")
	elif unresolved_counterfeit > 0:
		tags.append("contested_provenance")
	if continuity_state == "burial":
		tags.append("mourning_pressure")
	if continuity_state == "fragmented_legacy":
		tags.append("blame_pressure")
	return tags

func _artifact_return_pressure_tags(return_consequence_state: String, burden_band: String, market_carrier_risk_band: String) -> Array[String]:
	var tags: Array[String] = []
	match return_consequence_state:
		"secured_return":
			tags.append("steady_return")
		"recoverable_return":
			tags.append("measured_return")
		"counterfeit_return":
			tags.append("contested_return")
		"stalled_return", "split_return":
			tags.append("route_pressure")
		"buried_return", "residual_return":
			tags.append("quiet_reentry")
		_:
			tags.append("uncertain_return")
	if burden_band in ["heavy_carry", "held_burden", "burial_weight"]:
		tags.append("burden_pressure")
	if market_carrier_risk_band in ["volatile", "high", "contested"]:
		tags.append("carrier_risk_pressure")
	return tags
