class_name RunGenerator
extends RefCounted

const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")

const ROOM_VARIANTS: Array = [
	{"id": "traverse_a", "type": "traversal", "hazard": "none"},
	{"id": "traverse_b", "type": "traversal", "hazard": "spikes"},
	{"id": "hazard_saw", "type": "hazard", "hazard": "saw"},
	{"id": "hazard_dart", "type": "hazard", "hazard": "dart"},
	{"id": "encounter_bats", "type": "encounter", "hazard": "bats"},
	{"id": "encounter_slimes", "type": "encounter", "hazard": "slimes"},
	{"id": "evidence_vault", "type": "evidence", "hazard": "alarm"},
	{"id": "evidence_gap", "type": "evidence", "hazard": "collapse"},
	{"id": "recovery_shrine", "type": "recovery", "hazard": "none"},
	{"id": "recovery_pool", "type": "recovery", "hazard": "steam"},
	{"id": "risk_tall", "type": "traversal", "hazard": "fall"},
	{"id": "risk_narrow", "type": "traversal", "hazard": "push"}
]

func generate_layout(seed_value: int, room_count: int = 15) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var chain: Array = []
	var bag: Array = ROOM_VARIANTS.duplicate(true)

	for i in room_count:
		if bag.is_empty():
			bag = ROOM_VARIANTS.duplicate(true)
		var pick_index := rng.randi_range(0, bag.size() - 1)
		var room: Dictionary = bag[pick_index]
		bag.remove_at(pick_index)
		chain.append({
			"slot": i,
			"id": room["id"],
			"type": room["type"],
			"hazard": room["hazard"],
			"risk": rng.randi_range(1, 3)
		})

	return chain

func generate_evidence_spawns(seed_value: int, room_chain: Array) -> Array:
	return EVIDENCE_SERVICE_SCRIPT.new().spawn_for_chain(seed_value, room_chain)
