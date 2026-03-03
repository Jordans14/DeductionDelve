extends Node

var run_seed: int = 0
var run_counter: int = 0
var room_chain: Array = []
var player_ids: Array[int] = []
var local_role: String = "Unknown"
var evidence_by_id: Dictionary = {}

func set_run(seed_value: int, chain: Array, peers: Array[int]) -> void:
	run_counter += 1
	run_seed = seed_value
	room_chain = chain.duplicate(true)
	player_ids = peers.duplicate()
	local_role = "Unknown"
	evidence_by_id.clear()

func clear() -> void:
	run_seed = 0
	room_chain.clear()
	player_ids.clear()
	local_role = "Unknown"
	evidence_by_id.clear()
