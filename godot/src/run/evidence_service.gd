class_name EvidenceService
extends RefCounted

const PICKUP_RANGE := 72.0
const STEAL_RANGE := 78.0

func spawn_for_chain(seed_value: int, room_chain: Array) -> Array:
	var artifacts: Array = []
	var next_id := 1
	for room in room_chain:
		var slot := int(room.get("slot", -1))
		if slot < 0:
			continue

		var spawn_count := _spawn_count_for_room(room)
		for spawn_index in spawn_count:
			var artifact := _create_artifact(seed_value, next_id, slot, spawn_index)
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

func _create_artifact(seed_value: int, artifact_id: int, room_slot: int, spawn_index: int) -> Dictionary:
	return {
		"artifact_id": artifact_id,
		"room_slot": room_slot,
		"spawn_index": spawn_index,
		"signature": real_signature(seed_value, artifact_id, room_slot, spawn_index),
		"is_forged": false,
		"owner_peer_id": 0,
		"world_pos": Vector2(86 + 520 * room_slot + 44 * spawn_index, 294)
	}

func _spawn_count_for_room(room: Dictionary) -> int:
	var room_type := str(room.get("type", "traversal"))
	var risk := int(room.get("risk", 1))
	if room_type == "evidence":
		return 2
	if risk >= 3:
		return 1
	return 0

func _signature_raw(seed_value: int, artifact_id: int, room_slot: int, spawn_index: int) -> int:
	var seed_mix := int((seed_value * 1103515245) & 0x7FFFFFFF)
	var id_mix := int((artifact_id * 265443576) & 0x7FFFFFFF)
	var slot_mix := int((room_slot * 97531) & 0x7FFFFFFF)
	var spawn_mix := int((spawn_index * 7919) & 0x7FFFFFFF)
	var raw := seed_mix ^ id_mix ^ slot_mix ^ spawn_mix
	return raw & 0x7FFFFFFF
