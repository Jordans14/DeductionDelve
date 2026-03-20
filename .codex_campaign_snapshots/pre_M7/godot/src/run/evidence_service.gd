class_name EvidenceService
extends RefCounted

const ARTIFACT_SERVICE_SCRIPT = preload("res://src/run/artifact_service.gd")

var _delegate = ARTIFACT_SERVICE_SCRIPT.new()

func spawn_for_chain(seed_value: int, room_chain: Array) -> Array:
	return _delegate.spawn_for_chain(seed_value, room_chain)

func real_signature(seed_value: int, artifact_id: int, room_slot: int, spawn_index: int) -> String:
	return _delegate.real_signature(seed_value, artifact_id, room_slot, spawn_index)

func forged_signature(seed_value: int, artifact_id: int, room_slot: int, spawn_index: int) -> String:
	return _delegate.forged_signature(seed_value, artifact_id, room_slot, spawn_index)

func forge_spawn_index_from_counter(forge_counter: int) -> int:
	return _delegate.forge_spawn_index_from_counter(forge_counter)

func build_forged_artifact(seed_value: int, artifact_id: int, room_slot: int, forge_counter: int, world_pos: Vector2) -> Dictionary:
	return _delegate.build_forged_artifact(seed_value, artifact_id, room_slot, forge_counter, world_pos)

func authenticity_state(artifact: Dictionary) -> String:
	return _delegate.authenticity_state(artifact)

func summarize_authenticity(artifacts_state: Dictionary) -> Dictionary:
	return _delegate.summarize_authenticity(artifacts_state)

func summarize_custody_chain(artifacts_state: Dictionary, extraction_details: Dictionary = {}) -> Dictionary:
	return _delegate.summarize_custody_chain(artifacts_state, extraction_details)

func build_consequence_contract(
	reason: String,
	artifacts_state: Dictionary,
	continuity_summary: Dictionary,
	extraction_details: Dictionary = {},
	market_regime_id: String = "",
	market_carrier_risk_band: String = ""
) -> Dictionary:
	return _delegate.build_consequence_contract(
		reason,
		artifacts_state,
		continuity_summary,
		extraction_details,
		market_regime_id,
		market_carrier_risk_band
	)

func can_pickup(artifact: Dictionary, player_pos: Vector2, max_range: float = 72.0) -> bool:
	return _delegate.can_pickup(artifact, player_pos, max_range)

func can_drop(artifact: Dictionary, actor_peer_id: int) -> bool:
	return _delegate.can_drop(artifact, actor_peer_id)

func can_steal(artifact: Dictionary, stealer_pos: Vector2, carrier_pos: Vector2, max_range: float = 78.0) -> bool:
	return _delegate.can_steal(artifact, stealer_pos, carrier_pos, max_range)

func apply_owner(artifact: Dictionary, owner_peer_id: int, world_pos: Vector2) -> Dictionary:
	return _delegate.apply_owner(artifact, owner_peer_id, world_pos)

func world_pos_for_room_spawn_for_test(room: Dictionary, spawn_index: int) -> Vector2:
	return _delegate.world_pos_for_room_spawn_for_test(room, spawn_index)
