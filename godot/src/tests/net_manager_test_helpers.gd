class_name NetManagerTestHelpers
extends RefCounted

const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")

var evidence_service := EVIDENCE_SERVICE_SCRIPT.new()

func public_meta_allowlist(event_type: String, meta: Dictionary) -> Dictionary:
	match event_type:
		"artifact_spawned":
			return _pick_meta_fields(meta, ["artifact_id"])
		"artifact_picked":
			return _pick_meta_fields(meta, ["artifact_id"])
		"artifact_dropped":
			return _pick_meta_fields(meta, ["artifact_id"])
		"artifact_stolen":
			return _pick_meta_fields(meta, ["artifact_id", "from_peer"])
		"hazard_state_changed":
			return {}
		"sabotage_accident":
			return _pick_meta_fields(meta, ["label"])
		"sabotage_camera_jam":
			return _pick_meta_fields(meta, ["label"])
		"run_started":
			return _pick_meta_fields(meta, ["seed"])
		"evidence_checked":
			return {}
		"extraction_window_started":
			return _pick_meta_fields(meta, ["duration_ticks"])
		"extraction_window_aborted":
			return {}
		"item_picked":
			return _pick_meta_fields(meta, ["item_id"])
		"item_used":
			return _pick_meta_fields(meta, ["label"])
		"noise_trace":
			return {}
		"bomb_exploded":
			return {}
		"room_callout":
			return _pick_meta_fields(meta, ["kind"])
		"extraction_completed":
			return _pick_meta_fields(meta, ["artifact_id"])
		_:
			return {}

func build_event_for_test(event_type: String, tick: int, event_id: int, room_slot: int, actor_peer_id: int, visibility: String, meta: Dictionary, target_peer_id: int = -1) -> Dictionary:
	return {
		"event_id": event_id,
		"tick": tick,
		"room_slot": room_slot,
		"actor_peer_id": actor_peer_id,
		"event_type": event_type,
		"visibility": visibility,
		"meta": meta,
		"target_peer_id": target_peer_id
	}

func compute_warden_score_for_test(run_seed: int, artifact: Dictionary, check_counter: int) -> int:
	var signature := str(artifact.get("signature", ""))
	var artifact_id := int(artifact.get("artifact_id", 0))
	var room_slot := int(artifact.get("room_slot", -1))
	var mixed := int((run_seed * 1103515245) & 0x7FFFFFFF)
	mixed = mixed ^ int((artifact_id * 265443576) & 0x7FFFFFFF)
	mixed = mixed ^ int((room_slot * 7919) & 0x7FFFFFFF)
	mixed = mixed ^ int((check_counter * 19349663) & 0x7FFFFFFF)
	for i in signature.length():
		mixed = mixed ^ int(signature.unicode_at(i) * 83492791)
		mixed = int((mixed * 1664525 + 1013904223) & 0x7FFFFFFF)
	return mixed % 101

func simulate_pickup_request_for_test(artifacts_state: Dictionary, requester_id: int, artifact_id: int, player_pos: Vector2, requester_room_slot: int) -> Dictionary:
	var state := artifacts_state.duplicate(true)
	var result := {"changed": false, "public_event_emitted": false, "artifacts_state": state}
	if _find_carried_artifact_by_peer_in_state(state, requester_id) != 0:
		return result
	if not state.has(artifact_id):
		return result
	var artifact: Dictionary = state[artifact_id]
	var artifact_slot := int(artifact.get("room_slot", -1))
	if requester_room_slot != artifact_slot:
		return result
	if not evidence_service.can_pickup(artifact, player_pos):
		return result
	var next := evidence_service.apply_owner(artifact, requester_id, player_pos)
	next["room_slot"] = requester_room_slot
	state[artifact_id] = next
	result["changed"] = true
	result["public_event_emitted"] = true
	return result

func simulate_steal_request_for_test(
	artifacts_state: Dictionary,
	requester_id: int,
	artifact_id: int,
	stealer_pos: Vector2,
	victim_pos: Vector2,
	requester_room_slot: int,
	victim_room_slot: int
) -> Dictionary:
	var state := artifacts_state.duplicate(true)
	var result := {"changed": false, "public_event_emitted": false, "artifacts_state": state}
	if _find_carried_artifact_by_peer_in_state(state, requester_id) != 0:
		return result
	if not state.has(artifact_id):
		return result
	var artifact: Dictionary = state[artifact_id]
	var owner := int(artifact.get("owner_peer_id", 0))
	if owner == 0 or owner == requester_id:
		return result
	var artifact_slot := int(artifact.get("room_slot", -1))
	if requester_room_slot != victim_room_slot or requester_room_slot != artifact_slot:
		return result
	if not evidence_service.can_steal(artifact, stealer_pos, victim_pos):
		return result
	var next := evidence_service.apply_owner(artifact, requester_id, stealer_pos)
	next["room_slot"] = requester_room_slot
	state[artifact_id] = next
	result["changed"] = true
	result["public_event_emitted"] = true
	return result

func _find_carried_artifact_by_peer_in_state(state: Dictionary, peer_id: int) -> int:
	for artifact_id in state.keys():
		var artifact: Dictionary = state[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) == peer_id:
			return int(artifact_id)
	return 0

func _pick_meta_fields(meta: Dictionary, allowed_keys: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	for key in allowed_keys:
		if meta.has(key):
			result[key] = meta[key]
	return result
