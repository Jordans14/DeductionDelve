class_name RunGenerator
extends RefCounted

const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")

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

func generate_layout(seed_value: int, room_count: int = 15) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var chain: Array = []
	var bag: Array = ROOM_VARIANTS.duplicate(true)

	for i in room_count:
		if bag.is_empty():
			bag = ROOM_VARIANTS.duplicate(true)
		var pick_index := _pick_room_index(rng, bag, i, room_count)
		var room: Dictionary = bag[pick_index]
		bag.remove_at(pick_index)
		chain.append({
			"slot": i,
			"id": room["id"],
			"type": room["type"],
			"hazard": room["hazard"],
			"risk": _risk_for_slot(rng, i, room_count, str(room["type"]))
		})

	return chain

func generate_evidence_spawns(seed_value: int, room_chain: Array) -> Array:
	return EVIDENCE_SERVICE_SCRIPT.new().spawn_for_chain(seed_value, room_chain)

func _pick_room_index(rng: RandomNumberGenerator, bag: Array, slot: int, room_count: int) -> int:
	var weighted_indices: Array[int] = []
	var allowed_types := _allowed_room_types_for_slot(slot, room_count)
	var type_weights := _room_type_weights_for_slot(slot, room_count)
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

func _room_type_weights_for_slot(slot: int, room_count: int) -> Dictionary:
	if slot <= 0:
		return {"traversal": 6}
	if slot == 1:
		return {"evidence": 6}
	if slot == room_count - 2:
		return {"hazard": 6}
	if slot >= room_count - 1:
		return {"traversal": 6}
	if slot < maxi(int(room_count / 3), 3):
		return {"traversal": 5, "evidence": 4}
	if slot >= maxi(int(room_count * 2 / 3), 1):
		return {"hazard": 5, "evidence": 3, "traversal": 2}
	return {"hazard": 3, "evidence": 3, "traversal": 2}

func _risk_for_slot(rng: RandomNumberGenerator, slot: int, room_count: int, room_type: String) -> int:
	if slot <= 0:
		return 1
	if slot == 1:
		return 1
	if slot == room_count - 2:
		return 3
	if slot >= room_count - 1:
		return 2 if room_type == "traversal" else 3
	if slot < maxi(int(room_count / 3), 3):
		return rng.randi_range(1, 2)
	if slot >= maxi(int(room_count * 2 / 3), 1):
		return rng.randi_range(2, 3)
	return rng.randi_range(1, 3)
