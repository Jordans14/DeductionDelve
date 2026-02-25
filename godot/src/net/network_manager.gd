extends Node

signal lobby_updated(players: Array, ready_state: Dictionary, is_host: bool)
signal connection_changed(status: String)
signal run_started(seed_value: int, room_chain: Array)
signal state_snapshot(snapshot: Dictionary, tick: int)
signal role_revealed(role_name: String)
signal evidence_state_changed(evidence_by_id: Dictionary)
signal hazard_pulse_requested(room_slot: int, source_peer_id: int, reason: String)
signal action_denied(reason: String)
signal run_ended(payload: Dictionary)

const DEFAULT_PORT := 2456
const SABOTAGE_COOLDOWN_TICKS := 180
const RUN_TICK_LIMIT := 1800
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")

var players: Array[int] = []
var ready_by_id: Dictionary = {}
var is_host: bool = false
var latest_snapshot: Dictionary = {}
var latest_tick: int = 0
var input_by_peer: Dictionary = {}
var roles_by_peer: Dictionary = {}
var artifacts_by_id: Dictionary = {}
var next_artifact_id: int = 1
var player_pos_by_peer: Dictionary = {}
var player_room_by_peer: Dictionary = {}
var sabotage_cooldown_until_by_peer: Dictionary = {}
var current_server_tick: int = 0
var evidence_service := EVIDENCE_SERVICE_SCRIPT.new()
var forge_counter_by_room: Dictionary = {}
var next_event_id: int = 1
var check_counter_by_peer: Dictionary = {}
var local_sabotage_cooldown_until_tick: int = 0
var run_active: bool = false
var extraction_room_slot: int = -1

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_host(port: int = DEFAULT_PORT) -> bool:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 8)
	if err != OK:
		emit_signal("connection_changed", "Host failed on port %d" % port)
		return false
	multiplayer.multiplayer_peer = peer
	is_host = true
	players = [multiplayer.get_unique_id()]
	ready_by_id.clear()
	ready_by_id[multiplayer.get_unique_id()] = false
	emit_signal("connection_changed", "Hosting on port %d" % port)
	_broadcast_lobby()
	return true

func join_host(address: String, port: int = DEFAULT_PORT) -> bool:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		emit_signal("connection_changed", "Join failed %s:%d" % [address, port])
		return false
	multiplayer.multiplayer_peer = peer
	is_host = false
	emit_signal("connection_changed", "Joining %s:%d" % [address, port])
	return true

func disconnect_peer() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	players.clear()
	ready_by_id.clear()
	input_by_peer.clear()
	latest_snapshot.clear()
	roles_by_peer.clear()
	artifacts_by_id.clear()
	player_pos_by_peer.clear()
	player_room_by_peer.clear()
	sabotage_cooldown_until_by_peer.clear()
	forge_counter_by_room.clear()
	check_counter_by_peer.clear()
	current_server_tick = 0
	next_artifact_id = 1
	next_event_id = 1
	local_sabotage_cooldown_until_tick = 0
	run_active = false
	extraction_room_slot = -1
	is_host = false
	var run_state := _run_state()
	if run_state != null:
		run_state.clear()
	var event_log := _event_log()
	if event_log != null:
		event_log.clear()
	emit_signal("connection_changed", "Disconnected")
	emit_signal("lobby_updated", players, ready_by_id, is_host)

func set_local_ready(ready: bool) -> void:
	var uid := multiplayer.get_unique_id()
	if is_host:
		ready_by_id[uid] = ready
		_broadcast_lobby()
		return
	client_set_ready.rpc_id(1, ready)

func start_run(seed_override: int = 0, room_count: int = 8) -> void:
	if not is_host:
		return
	var generator := RUN_GENERATOR_SCRIPT.new()
	var role_service := ROLE_SERVICE_SCRIPT.new()
	var run_seed := seed_override
	if run_seed == 0:
		run_seed = int(Time.get_unix_time_from_system())
	var chain := generator.generate_layout(run_seed, room_count)
	roles_by_peer = role_service.assign_roles(players, run_seed)
	var artifacts := generator.generate_evidence_spawns(run_seed, chain)
	artifacts_by_id.clear()
	for artifact in artifacts:
		var artifact_id := int(artifact["artifact_id"])
		artifacts_by_id[artifact_id] = artifact
	next_artifact_id = artifacts.size() + 1
	forge_counter_by_room.clear()
	check_counter_by_peer.clear()
	next_event_id = 1
	local_sabotage_cooldown_until_tick = 0
	run_active = true
	extraction_room_slot = maxi(chain.size() - 1, 0)

	var event_log := _event_log()
	if event_log != null:
		event_log.clear()
	var payload := build_run_start_payload(run_seed, chain, players)
	host_start_run.rpc(payload["seed"], payload["room_chain"], payload["peer_ids"])
	_reveal_roles_to_clients()
	_broadcast_artifact_state()
	record_public_event("run_started", -1, -1, {"seed": run_seed})

func send_client_input(move_axis: float, jump_pressed: bool, seq: int) -> void:
	if is_host:
		input_by_peer[multiplayer.get_unique_id()] = {"move": move_axis, "jump": jump_pressed, "seq": seq}
		return
	client_input.rpc_id(1, move_axis, jump_pressed, seq)

func consume_peer_input(peer_id: int) -> Dictionary:
	if not input_by_peer.has(peer_id):
		return {"move": 0.0, "jump": false, "seq": -1}
	return input_by_peer[peer_id]

func broadcast_state(snapshot: Dictionary, tick: int) -> void:
	if not is_host:
		return
	current_server_tick = tick
	host_push_state.rpc(snapshot, tick)
	if run_active:
		var reason := compute_end_reason_for_tick(current_server_tick)
		if reason != "":
			_host_end_run(reason)

func all_ready() -> bool:
	if players.is_empty():
		return false
	for peer_id in players:
		if not bool(ready_by_id.get(peer_id, false)):
			return false
	return true

func _broadcast_lobby() -> void:
	host_sync_lobby.rpc(players, ready_by_id, is_host)

func _on_peer_connected(peer_id: int) -> void:
	if not is_host:
		return
	if not players.has(peer_id):
		players.append(peer_id)
	ready_by_id[peer_id] = false
	_broadcast_lobby()

func _on_peer_disconnected(peer_id: int) -> void:
	players.erase(peer_id)
	ready_by_id.erase(peer_id)
	input_by_peer.erase(peer_id)
	if is_host:
		_broadcast_lobby()
	else:
		emit_signal("lobby_updated", players, ready_by_id, is_host)

func _on_connected_to_server() -> void:
	emit_signal("connection_changed", "Connected to host")

func _on_connection_failed() -> void:
	emit_signal("connection_changed", "Connection failed")

func _on_server_disconnected() -> void:
	disconnect_peer()
	emit_signal("connection_changed", "Host disconnected")

@rpc("any_peer", "reliable")
func client_set_ready(ready: bool) -> void:
	if not is_host:
		return
	var sender := multiplayer.get_remote_sender_id()
	ready_by_id[sender] = ready
	_broadcast_lobby()

@rpc("authority", "call_local", "reliable")
func host_sync_lobby(peer_ids: Array, ready_state: Dictionary, host_flag: bool) -> void:
	players.clear()
	for peer_id in peer_ids:
		players.append(int(peer_id))
	ready_by_id = ready_state.duplicate(true)
	is_host = host_flag and multiplayer.is_server()
	emit_signal("lobby_updated", players, ready_by_id, is_host)

@rpc("authority", "call_local", "reliable")
func host_start_run(seed_value: int, room_chain: Array, peer_ids: Array) -> void:
	var local_players: Array[int] = []
	for peer_id in peer_ids:
		local_players.append(int(peer_id))
	var run_state := _run_state()
	if run_state != null:
		run_state.set_run(seed_value, room_chain, local_players)
	var event_log := _event_log()
	if event_log != null:
		event_log.clear()
	run_active = true
	emit_signal("run_started", seed_value, room_chain)

@rpc("any_peer", "unreliable_ordered")
func client_input(move_axis: float, jump_pressed: bool, seq: int) -> void:
	if not is_host:
		return
	var sender := multiplayer.get_remote_sender_id()
	input_by_peer[sender] = {"move": move_axis, "jump": jump_pressed, "seq": seq}

@rpc("authority", "call_local", "unreliable_ordered")
func host_push_state(snapshot: Dictionary, tick: int) -> void:
	latest_snapshot = snapshot
	latest_tick = tick
	emit_signal("state_snapshot", snapshot, tick)

func update_authoritative_player_state(peer_id: int, world_pos: Vector2, room_slot: int) -> void:
	if not is_host:
		return
	player_pos_by_peer[peer_id] = world_pos
	player_room_by_peer[peer_id] = room_slot

func request_pickup(artifact_id: int) -> void:
	if is_host:
		_host_pickup(multiplayer.get_unique_id(), artifact_id)
		return
	client_pickup_request.rpc_id(1, artifact_id)

func request_drop() -> void:
	if is_host:
		_host_drop(multiplayer.get_unique_id())
		return
	client_drop_request.rpc_id(1)

func request_steal(artifact_id: int) -> void:
	if is_host:
		_host_steal(multiplayer.get_unique_id(), artifact_id)
		return
	client_steal_request.rpc_id(1, artifact_id)

func request_forge(room_slot: int) -> void:
	if is_host:
		_host_forge(multiplayer.get_unique_id(), room_slot)
		return
	client_forge_request.rpc_id(1, room_slot)

func request_sabotage(room_slot: int) -> void:
	if is_host:
		_host_sabotage(multiplayer.get_unique_id(), room_slot)
		return
	client_sabotage_request.rpc_id(1, room_slot)

func request_check_artifact(artifact_id: int) -> void:
	if is_host:
		_host_check_artifact(multiplayer.get_unique_id(), artifact_id)
		return
	client_check_artifact_request.rpc_id(1, artifact_id)

func can_local_use_sabotage(_room_slot: int) -> bool:
	var run_state := _run_state()
	if run_state == null:
		return false
	if str(run_state.local_role) != ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		return false
	var local_tick := latest_tick
	if is_host:
		local_tick = current_server_tick
	return local_tick >= local_sabotage_cooldown_until_tick

func is_run_active() -> bool:
	return run_active

func should_end_run_for_tick(tick: int) -> bool:
	return tick >= RUN_TICK_LIMIT

func should_end_run_for_extraction() -> bool:
	if extraction_room_slot < 0:
		return false
	for artifact_id in artifacts_by_id.keys():
		var artifact: Dictionary = artifacts_by_id[artifact_id]
		var owner_peer_id := int(artifact.get("owner_peer_id", 0))
		if owner_peer_id == 0:
			continue
		var owner_slot := int(player_room_by_peer.get(owner_peer_id, -1))
		if owner_slot == extraction_room_slot:
			return true
	return false

func compute_end_reason_for_tick(tick: int) -> String:
	if should_end_run_for_extraction():
		return "extraction_objective"
	if should_end_run_for_tick(tick):
		return "tick_limit"
	return ""

func build_run_start_payload(seed_value: int, room_chain: Array, peer_ids: Array) -> Dictionary:
	return {
		"seed": seed_value,
		"room_chain": room_chain.duplicate(true),
		"peer_ids": peer_ids.duplicate()
	}

func compute_summary_from_events(events: Array, peer_ids: Array[int], artifacts_state: Dictionary) -> Dictionary:
	var summary: Dictionary = {}
	for peer_id in peer_ids:
		summary[str(peer_id)] = {
			"picked": 0,
			"dropped": 0,
			"stolen": 0,
			"carrying_end": 0
		}
	for event_raw in events:
		var event: Dictionary = event_raw
		var actor := int(event.get("actor_peer_id", -1))
		if actor < 0:
			continue
		var actor_key := str(actor)
		if not summary.has(actor_key):
			continue
		var event_type := str(event.get("event_type", ""))
		if event_type == "artifact_picked":
			summary[actor_key]["picked"] = int(summary[actor_key]["picked"]) + 1
		elif event_type == "artifact_dropped":
			summary[actor_key]["dropped"] = int(summary[actor_key]["dropped"]) + 1
		elif event_type == "artifact_stolen":
			summary[actor_key]["stolen"] = int(summary[actor_key]["stolen"]) + 1
	for artifact_id in artifacts_state.keys():
		var artifact: Dictionary = artifacts_state[artifact_id]
		var owner := int(artifact.get("owner_peer_id", 0))
		if owner <= 0:
			continue
		var owner_key := str(owner)
		if not summary.has(owner_key):
			continue
		summary[owner_key]["carrying_end"] = int(summary[owner_key]["carrying_end"]) + 1
	return summary

func build_run_end_payload(reason: String, seed_override: int = -1) -> Dictionary:
	var roles_reveal: Dictionary = {}
	for peer_id in roles_by_peer.keys():
		roles_reveal[str(peer_id)] = str(roles_by_peer[peer_id])
	var run_seed_value := seed_override
	if run_seed_value < 0:
		run_seed_value = _run_seed()
	var events: Array = []
	var event_log := _event_log()
	if event_log != null:
		events = event_log.events
	return {
		"seed": run_seed_value,
		"reason": reason,
		"end_tick": current_server_tick,
		"roles_reveal": roles_reveal,
		"summary_by_peer": compute_summary_from_events(events, players, artifacts_by_id)
	}

func get_local_carried_artifact_id() -> int:
	var local_id := multiplayer.get_unique_id()
	for artifact_id in artifacts_by_id.keys():
		var artifact: Dictionary = artifacts_by_id[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) == local_id:
			return int(artifact_id)
	return 0

func get_known_role_for_peer(peer_id: int) -> String:
	if not is_host:
		return ""
	return str(roles_by_peer.get(peer_id, "Unknown"))

func broadcast_hazard_pulse(room_slot: int, source_peer_id: int, reason: String) -> void:
	if not is_host:
		return
	host_hazard_pulse.rpc(room_slot, source_peer_id, reason)

func record_public_event(event_type: String, room_slot: int, actor_peer_id: int, meta: Dictionary = {}) -> void:
	if not is_host:
		return
	var event := _build_event("public", event_type, room_slot, actor_peer_id, _public_meta_allowlist(event_type, meta))
	host_push_public_event.rpc(event)

func record_private_event(target_peer_id: int, event_type: String, room_slot: int, actor_peer_id: int, meta: Dictionary = {}) -> void:
	if not is_host:
		return
	var event := _build_event("private", event_type, room_slot, actor_peer_id, meta)
	if target_peer_id == multiplayer.get_unique_id():
		_consume_private_side_effect(event)
	else:
		host_push_private_event.rpc_id(target_peer_id, event)

@rpc("any_peer", "reliable")
func client_pickup_request(artifact_id: int) -> void:
	if not is_host:
		return
	_host_pickup(multiplayer.get_remote_sender_id(), artifact_id)

@rpc("any_peer", "reliable")
func client_drop_request() -> void:
	if not is_host:
		return
	_host_drop(multiplayer.get_remote_sender_id())

@rpc("any_peer", "reliable")
func client_steal_request(artifact_id: int) -> void:
	if not is_host:
		return
	_host_steal(multiplayer.get_remote_sender_id(), artifact_id)

@rpc("any_peer", "reliable")
func client_forge_request(room_slot: int) -> void:
	if not is_host:
		return
	_host_forge(multiplayer.get_remote_sender_id(), room_slot)

@rpc("any_peer", "reliable")
func client_sabotage_request(room_slot: int) -> void:
	if not is_host:
		return
	_host_sabotage(multiplayer.get_remote_sender_id(), room_slot)

@rpc("any_peer", "reliable")
func client_check_artifact_request(artifact_id: int) -> void:
	if not is_host:
		return
	_host_check_artifact(multiplayer.get_remote_sender_id(), artifact_id)

@rpc("authority", "reliable")
func host_reveal_role(payload: Dictionary) -> void:
	var run_state := _run_state()
	if run_state == null:
		return
	run_state.local_role = str(payload.get("role", "Unknown"))
	emit_signal("role_revealed", str(run_state.local_role))

@rpc("authority", "call_local", "reliable")
func host_sync_artifact_state(payload: Array) -> void:
	artifacts_by_id.clear()
	var run_state := _run_state()
	if run_state == null:
		return
	run_state.evidence_by_id.clear()
	for artifact_raw in payload:
		var artifact: Dictionary = artifact_raw
		var artifact_id := int(artifact.get("artifact_id", 0))
		artifacts_by_id[artifact_id] = artifact
		run_state.evidence_by_id[artifact_id] = artifact.duplicate(true)
	emit_signal("evidence_state_changed", run_state.evidence_by_id)

@rpc("authority", "call_local", "reliable")
func host_push_public_event(event: Dictionary) -> void:
	var event_log := _event_log()
	if event_log != null:
		event_log.add_event(event)

@rpc("authority", "reliable")
func host_push_private_event(event: Dictionary) -> void:
	_consume_private_side_effect(event)

@rpc("authority", "call_local", "reliable")
func host_hazard_pulse(room_slot: int, source_peer_id: int, reason: String) -> void:
	emit_signal("hazard_pulse_requested", room_slot, source_peer_id, reason)

@rpc("authority", "call_local", "reliable")
func host_run_ended(payload: Dictionary) -> void:
	run_active = false
	emit_signal("run_ended", payload)

func _host_pickup(requester_id: int, artifact_id: int) -> void:
	if not artifacts_by_id.has(artifact_id):
		_deny_action(requester_id, "no_target")
		return
	if _find_carried_artifact_by_peer(requester_id) != 0:
		_deny_action(requester_id, "already_carrying")
		return
	var artifact: Dictionary = artifacts_by_id[artifact_id]
	var requester_slot := int(player_room_by_peer.get(requester_id, -99))
	var artifact_slot := _artifact_room_slot(artifact)
	if requester_slot != artifact_slot:
		_deny_action(requester_id, "wrong_room", requester_slot)
		return
	var player_pos: Vector2 = player_pos_by_peer.get(requester_id, Vector2(999999, 999999))
	if not evidence_service.can_pickup(artifact, player_pos):
		_deny_action(requester_id, "out_of_range", requester_slot)
		return
	var next := evidence_service.apply_owner(artifact, requester_id, player_pos)
	next["room_slot"] = requester_slot
	artifacts_by_id[artifact_id] = next
	_broadcast_artifact_state()
	record_public_event("artifact_picked", int(next.get("room_slot", -1)), requester_id, {"artifact_id": artifact_id})

func _host_drop(requester_id: int) -> void:
	var carried_id := _find_carried_artifact_by_peer(requester_id)
	if carried_id == 0:
		_deny_action(requester_id, "no_target")
		return
	var artifact: Dictionary = artifacts_by_id[carried_id]
	if not evidence_service.can_drop(artifact, requester_id):
		_deny_action(requester_id, "not_owner")
		return
	var requester_slot := int(player_room_by_peer.get(requester_id, int(artifact.get("room_slot", -1))))
	var pos: Vector2 = player_pos_by_peer.get(requester_id, Vector2.ZERO) + Vector2(0, 10)
	var next := evidence_service.apply_owner(artifact, 0, pos)
	next["room_slot"] = requester_slot
	artifacts_by_id[carried_id] = next
	_broadcast_artifact_state()
	record_public_event("artifact_dropped", int(next.get("room_slot", -1)), requester_id, {"artifact_id": carried_id})

func _host_steal(requester_id: int, artifact_id: int) -> void:
	if not artifacts_by_id.has(artifact_id):
		_deny_action(requester_id, "no_target")
		return
	if _find_carried_artifact_by_peer(requester_id) != 0:
		_deny_action(requester_id, "already_carrying")
		return
	var artifact: Dictionary = artifacts_by_id[artifact_id]
	var victim_id := int(artifact.get("owner_peer_id", 0))
	if victim_id == 0 or victim_id == requester_id:
		_deny_action(requester_id, "no_target")
		return
	var requester_slot := int(player_room_by_peer.get(requester_id, -99))
	var victim_slot := int(player_room_by_peer.get(victim_id, -98))
	var artifact_slot := _artifact_room_slot(artifact)
	if requester_slot != victim_slot or requester_slot != artifact_slot:
		_deny_action(requester_id, "wrong_room", requester_slot)
		return
	var stealer_pos: Vector2 = player_pos_by_peer.get(requester_id, Vector2(999999, 999999))
	var victim_pos: Vector2 = player_pos_by_peer.get(victim_id, Vector2(999999, 999999))
	if not evidence_service.can_steal(artifact, stealer_pos, victim_pos):
		_deny_action(requester_id, "out_of_range", requester_slot)
		return
	var next := evidence_service.apply_owner(artifact, requester_id, stealer_pos)
	next["room_slot"] = requester_slot
	artifacts_by_id[artifact_id] = next
	_broadcast_artifact_state()
	record_public_event("artifact_stolen", int(next.get("room_slot", -1)), requester_id, {"artifact_id": artifact_id, "from_peer": victim_id})

func _host_forge(requester_id: int, room_slot: int) -> void:
	if str(roles_by_peer.get(requester_id, "")) != ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		_deny_action(requester_id, "not_role", room_slot)
		return
	if _find_carried_artifact_by_peer(requester_id) != 0:
		_deny_action(requester_id, "already_carrying", room_slot)
		return
	var player_slot := int(player_room_by_peer.get(requester_id, -99))
	if player_slot != room_slot:
		_deny_action(requester_id, "wrong_room", room_slot)
		return
	var forge_counter := int(forge_counter_by_room.get(room_slot, 0))
	var forged := evidence_service.build_forged_artifact(
		_run_seed(),
		next_artifact_id,
		room_slot,
		forge_counter,
		player_pos_by_peer.get(requester_id, Vector2.ZERO) + Vector2(18, 0)
	)
	forge_counter_by_room[room_slot] = forge_counter + 1
	artifacts_by_id[next_artifact_id] = forged
	next_artifact_id += 1
	_broadcast_artifact_state()
	record_private_event(requester_id, "artifact_forged", room_slot, requester_id, {"artifact_id": int(forged["artifact_id"])})
	record_public_event("artifact_spawned", room_slot, -1, {"artifact_id": int(forged["artifact_id"])})

func _host_sabotage(requester_id: int, room_slot: int) -> void:
	if str(roles_by_peer.get(requester_id, "")) != ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		_deny_action(requester_id, "not_role", room_slot)
		return
	var player_slot := int(player_room_by_peer.get(requester_id, -99))
	if player_slot != room_slot:
		_deny_action(requester_id, "wrong_room", room_slot)
		return
	var lock_until := int(sabotage_cooldown_until_by_peer.get(requester_id, -1))
	if current_server_tick < lock_until:
		_deny_action(requester_id, "cooldown", room_slot)
		return
	sabotage_cooldown_until_by_peer[requester_id] = current_server_tick + SABOTAGE_COOLDOWN_TICKS
	broadcast_hazard_pulse(room_slot, -1, "state_changed")
	record_public_event("hazard_state_changed", room_slot, -1, {})
	record_private_event(requester_id, "sabotage_used", room_slot, requester_id, {})

func _host_check_artifact(requester_id: int, artifact_id: int) -> void:
	if str(roles_by_peer.get(requester_id, "")) != ROLE_SERVICE_SCRIPT.ROLE_WARDEN:
		_deny_action(requester_id, "not_role")
		return
	if not artifacts_by_id.has(artifact_id):
		_deny_action(requester_id, "no_target")
		return
	var artifact: Dictionary = artifacts_by_id[artifact_id]
	var player_slot := int(player_room_by_peer.get(requester_id, -99))
	var artifact_slot := _artifact_room_slot(artifact)
	if player_slot != artifact_slot:
		_deny_action(requester_id, "wrong_room", player_slot)
		return
	var check_counter := int(check_counter_by_peer.get(requester_id, 0))
	var score := _compute_warden_check_score(artifact, check_counter)
	check_counter_by_peer[requester_id] = check_counter + 1
	record_private_event(requester_id, "warden_check_result", artifact_slot, requester_id, {
		"artifact_id": artifact_id,
		"score": score
	})
	record_public_event("evidence_checked", artifact_slot, requester_id, {})

func _find_carried_artifact_by_peer(peer_id: int) -> int:
	for artifact_id in artifacts_by_id.keys():
		var artifact: Dictionary = artifacts_by_id[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) == peer_id:
			return int(artifact_id)
	return 0

func _reveal_roles_to_clients() -> void:
	var role_service := ROLE_SERVICE_SCRIPT.new()
	var host_id := multiplayer.get_unique_id()
	for peer_id in players:
		var role_name := str(roles_by_peer.get(peer_id, "Unknown"))
		var payload := role_service.build_private_role_payload(role_name)
		if peer_id == host_id:
			var run_state := _run_state()
			if run_state != null:
				run_state.local_role = role_name
			emit_signal("role_revealed", role_name)
		else:
			host_reveal_role.rpc_id(peer_id, payload)

func _broadcast_artifact_state() -> void:
	if not is_host:
		return
	host_sync_artifact_state.rpc(_serialize_artifacts())

func _serialize_artifacts() -> Array:
	var ids: Array = artifacts_by_id.keys()
	ids.sort()
	var data: Array = []
	for artifact_id in ids:
		data.append(artifacts_by_id[artifact_id])
	return data

func _build_event(visibility: String, event_type: String, room_slot: int, actor_peer_id: int, meta: Dictionary) -> Dictionary:
	var event := {
		"event_id": next_event_id,
		"tick": current_server_tick,
		"room_slot": room_slot,
		"actor_peer_id": actor_peer_id,
		"event_type": event_type,
		"visibility": visibility,
		"meta": meta
	}
	next_event_id += 1
	return event

func _public_meta_allowlist(event_type: String, meta: Dictionary) -> Dictionary:
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
		"run_started":
			return _pick_meta_fields(meta, ["seed"])
		"evidence_checked":
			return {}
		"run_ended":
			return {}
		_:
			return {}

func _pick_meta_fields(meta: Dictionary, allowed_keys: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	for key in allowed_keys:
		if meta.has(key):
			result[key] = meta[key]
	return result

func _artifact_room_slot(artifact: Dictionary) -> int:
	var owner_peer := int(artifact.get("owner_peer_id", 0))
	if owner_peer != 0:
		return int(player_room_by_peer.get(owner_peer, int(artifact.get("room_slot", -1))))
	return int(artifact.get("room_slot", -1))

func _compute_warden_check_score(artifact: Dictionary, check_counter: int) -> int:
	var signature := str(artifact.get("signature", ""))
	var artifact_id := int(artifact.get("artifact_id", 0))
	var room_slot := int(artifact.get("room_slot", -1))
	var mixed := int((_run_seed() * 1103515245) & 0x7FFFFFFF)
	mixed = mixed ^ int((artifact_id * 265443576) & 0x7FFFFFFF)
	mixed = mixed ^ int((room_slot * 7919) & 0x7FFFFFFF)
	mixed = mixed ^ int((check_counter * 19349663) & 0x7FFFFFFF)
	for i in signature.length():
		mixed = mixed ^ int(signature.unicode_at(i) * 83492791)
		mixed = int((mixed * 1664525 + 1013904223) & 0x7FFFFFFF)
	return mixed % 101

func _deny_action(target_peer_id: int, reason: String, room_slot: int = -1) -> void:
	record_private_event(target_peer_id, "action_denied_ui", room_slot, target_peer_id, {"reason": reason})

func _consume_private_side_effect(event: Dictionary) -> void:
	var event_type := str(event.get("event_type", ""))
	if event_type == "action_denied_ui":
		var meta: Dictionary = event.get("meta", {})
		emit_signal("action_denied", str(meta.get("reason", "unknown")))
		return
	if event_type == "sabotage_used":
		var tick := int(event.get("tick", 0))
		local_sabotage_cooldown_until_tick = tick + SABOTAGE_COOLDOWN_TICKS
	var event_log := _event_log()
	if event_log != null:
		event_log.add_event(event)

func _run_state() -> Node:
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop.root.get_node_or_null("/root/RunState")
	return null

func _event_log() -> Node:
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop.root.get_node_or_null("/root/EventLog")
	return null

func _run_seed() -> int:
	var run_state := _run_state()
	if run_state == null:
		return 0
	return int(run_state.run_seed)

func _host_end_run(reason: String) -> void:
	if not is_host or not run_active:
		return
	run_active = false
	record_public_event("run_ended", -1, -1, {})
	var payload := build_run_end_payload(reason)
	host_run_ended.rpc(payload)
