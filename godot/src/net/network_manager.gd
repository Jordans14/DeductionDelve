extends Node

signal lobby_updated(players: Array, ready_state: Dictionary, is_host: bool)
signal connection_changed(status: String)
signal run_started(seed_value: int, room_chain: Array)
signal state_snapshot(snapshot: Dictionary, tick: int)
signal role_revealed(role_name: String)
signal evidence_state_changed(evidence_by_id: Dictionary)
signal item_state_changed(items_by_id: Dictionary)
signal hazard_pulse_requested(room_slot: int, source_peer_id: int, reason: String)
signal action_denied(reason: String)
signal run_ended(payload: Dictionary)
signal connected_peers_changed(peers: Array)
signal host_endpoint_changed(bind: String, port: int)

const DEFAULT_PORT := 2456
const SABOTAGE_COOLDOWN_TICKS := 400
const RUN_TICK_LIMIT := 18000  # 5 minutes at 60 ticks/sec
const CAMERA_JAM_MAX_WARDEN_SCORE := 84
const EXTRACTION_WINDOW_TICKS := 600
const NETWORK_CONFIG_SCRIPT = preload("res://src/net/network_config.gd")
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")
const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")

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
var evidence_service: Object = EVIDENCE_SERVICE_SCRIPT.new()
var item_service: RefCounted = ITEM_SERVICE_SCRIPT.new()
var forge_counter_by_room: Dictionary = {}
var next_event_id: int = 1
var check_counter_by_peer: Dictionary = {}
var local_sabotage_cooldown_until_tick: int = 0
var run_active: bool = false
var extraction_room_slot: int = -1
var extraction_window_started_tick: int = -1
var extraction_window_artifact_id: int = 0
var extraction_window_owner_peer_id: int = 0
var extraction_window_last_abort_tick: int = -1
var match_over: bool = false
var host_requested_port: int = -1
var host_listen_port: int = -1
var host_port: int = -1
var host_bind_address: String = ""
var join_target_address: String = ""
var join_target_port: int = -1
var network_defaults: Dictionary = {}
var connected_peers: Array[int] = []
var items_by_id: Dictionary = {}
var disturbance_until_by_room: Dictionary = {}
var camera_jam_until_by_room: Dictionary = {}
var next_noise_trace_tick_by_peer: Dictionary = {}
var signals_wired: bool = false
var peer_reconcile_accum: float = 0.0
const PEER_RECONCILE_INTERVAL_SEC := 0.25
var enet_peer: ENetMultiplayerPeer = null
var enet_peer_mode: String = ""
var _active_mp: MultiplayerAPI = null
var local_extraction_window_active: bool = false
var local_extraction_window_room_slot: int = -1
var local_extraction_window_duration_ticks: int = 0

func _ready() -> void:
	network_defaults = NETWORK_CONFIG_SCRIPT.load_defaults()
	set_process(true)
	_select_active_mp("ready_boot")
	_init_network_signals()
	var autoload_flag := get_path() == NodePath("/root/NetworkManager")
	var tree_mp := _tree_mp_candidate()
	var node_mp := _node_mp_candidate()
	_nm_log("NM_BOOT autoload=%s tree_mp_peer=%s node_mp_peer=%s" % [
		str(autoload_flag),
		_peer_kind(tree_mp),
		_peer_kind(node_mp)
	])

func _process(delta: float) -> void:
	if not is_host:
		return
	var scene_mp := _mp()
	if scene_mp == null or scene_mp.multiplayer_peer == null:
		return
	peer_reconcile_accum += delta
	if peer_reconcile_accum < PEER_RECONCILE_INTERVAL_SEC:
		return
	peer_reconcile_accum = 0.0
	_server_reconcile_connected_peers(true)

func _init_network_signals() -> void:
	if signals_wired:
		return
	var scene_mp := _mp()
	if scene_mp == null:
		scene_mp = _mp_for_signal_wiring()
	if scene_mp == null:
		return
	signals_wired = true
	scene_mp.peer_connected.connect(_on_peer_connected)
	scene_mp.peer_disconnected.connect(_on_peer_disconnected)
	scene_mp.connected_to_server.connect(_on_connected_to_server)
	scene_mp.connection_failed.connect(_on_connection_failed)
	scene_mp.server_disconnected.connect(_on_server_disconnected)

func start_host(port: int = -1, preferred_join_address: String = "", bind_override: String = "") -> bool:
	var requested_port := port if port > 0 else _default_port()
	var bind_address := _resolve_bind_address(preferred_join_address, bind_override)
	var max_tries := maxi(int(network_defaults.get("host_port_fallback_attempts", 10)), 1)
	var max_peers := maxi(int(network_defaults.get("max_peers", 8)), 1)
	var last_err := ERR_CANT_CREATE
	var chosen_peer: ENetMultiplayerPeer = null
	var chosen_port := -1

	var scene_mp := _mp()
	if scene_mp != null and scene_mp.multiplayer_peer != null:
		disconnect_peer("restart_host")

	_nm_log("HOST_START_REQUEST bind=%s requested_port=%d max_tries=%d max_peers=%d" % [bind_address, requested_port, max_tries, max_peers])
	emit_signal("connection_changed", "Starting host... (%s:%d)" % [bind_address, requested_port])
	for candidate_port in _build_host_port_candidates(requested_port, max_tries):
		var peer := ENetMultiplayerPeer.new()
		var err := peer.create_server(candidate_port, max_peers)
		if err == OK:
			chosen_peer = peer
			chosen_port = candidate_port
			break
		last_err = err

	if chosen_peer == null:
		run_active = false
		is_host = false
		host_requested_port = requested_port
		host_listen_port = -1
		host_port = -1
		host_bind_address = bind_address
		var failure_message := _format_host_failure_message(bind_address, requested_port, max_tries, last_err)
		emit_signal("connection_changed", failure_message)
		emit_signal("host_endpoint_changed", host_bind_address, host_listen_port)
		_nm_log("HOST_FAILED bind=%s requested_port=%d tries=%d err=%s" % [bind_address, requested_port, max_tries, error_string(last_err)])
		return false

	enet_peer = chosen_peer
	enet_peer_mode = "server"
	var node_mp := _node_mp_candidate()
	var tree_mp := _tree_mp_candidate()
	var assign_mp := node_mp if node_mp != null else tree_mp
	if assign_mp != null:
		assign_mp.multiplayer_peer = enet_peer
	_select_active_mp("after_assign_peer")
	_ensure_signals_wired_to_active_mp()
	_warn_if_double_peer_assignment("start_host_after_assign")
	var mp := _mp()
	_log_mp_state("after_start_host_assign_peer")
	is_host = true
	host_requested_port = requested_port
	host_listen_port = chosen_port
	host_port = chosen_port
	host_bind_address = bind_address
	emit_signal("host_endpoint_changed", host_bind_address, host_listen_port)
	_set_connected_peers([], "start_host_init")
	_server_reconcile_connected_peers(true)
	players = connected_peers.duplicate()
	ready_by_id.clear()
	if mp != null:
		_set_ready(mp.get_unique_id(), true, "start_host_local_ready")
	_reconcile_ready_map_for_connected_peers(false)
	var started_message := "Host online at %s:%d (requested %d)" % [_recommended_join_address_for_display(host_bind_address), host_listen_port, host_requested_port]
	emit_signal("connection_changed", started_message)
	_nm_log("HOST_ONLINE bind=%s chosen_port=%d requested_port=%d" % [bind_address, host_listen_port, host_requested_port])
	_log_connection_event("host_started", "bind=%s requested=%d chosen=%d" % [bind_address, host_requested_port, host_listen_port])
	_broadcast_lobby()
	return true

func join_host(address: String, port: int = -1) -> bool:
	var join_address := address.strip_edges()
	if join_address.is_empty():
		join_address = _default_join_address()
	var join_port := port if port > 0 else _default_port()
	join_target_address = join_address
	join_target_port = join_port
	_nm_log("JOIN_REQUEST target=%s:%d" % [join_address, join_port])
	emit_signal("connection_changed", "Join requested... (%s:%d)" % [join_address, join_port])
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(join_address, join_port)
	if err != OK:
		var hint := _build_port_mismatch_hint(join_port)
		emit_signal("connection_changed", "Join failed %s:%d (%s)%s" % [join_address, join_port, error_string(err), hint])
		_log_connection_event("join_failed_create_client", "target=%s:%d err=%s%s" % [join_address, join_port, error_string(err), hint])
		return false
	enet_peer = peer
	enet_peer_mode = "client"
	var node_mp := _node_mp_candidate()
	var tree_mp := _tree_mp_candidate()
	var assign_mp := node_mp if node_mp != null else tree_mp
	if assign_mp != null:
		assign_mp.multiplayer_peer = enet_peer
	_select_active_mp("after_assign_peer")
	_ensure_signals_wired_to_active_mp()
	_warn_if_double_peer_assignment("join_host_after_assign")
	_log_mp_state("after_join_assign_peer")
	is_host = false
	_set_connected_peers([], "join_host_init")
	emit_signal("connection_changed", "Joining %s:%d" % [join_address, join_port])
	_log_connection_event("join_started", "target=%s:%d" % [join_address, join_port])
	return true

func disconnect_peer(reason: String = "manual") -> void:
	var scene_mp := _mp()
	var local_id := -1
	if scene_mp != null:
		local_id = scene_mp.get_unique_id()
	_nm_log("DISCONNECT_PEER is_host=%s local=%d reason=%s" % [str(is_host), local_id, reason])
	if enet_peer != null:
		enet_peer.close()
	enet_peer = null
	enet_peer_mode = ""
	_clear_peer_assignments()
	_select_active_mp("after_disconnect_clear")
	players.clear()
	ready_by_id.clear()
	input_by_peer.clear()
	latest_snapshot.clear()
	roles_by_peer.clear()
	artifacts_by_id.clear()
	items_by_id.clear()
	player_pos_by_peer.clear()
	player_room_by_peer.clear()
	sabotage_cooldown_until_by_peer.clear()
	disturbance_until_by_room.clear()
	camera_jam_until_by_room.clear()
	next_noise_trace_tick_by_peer.clear()
	forge_counter_by_room.clear()
	check_counter_by_peer.clear()
	current_server_tick = 0
	next_artifact_id = 1
	next_event_id = 1
	local_sabotage_cooldown_until_tick = 0
	run_active = false
	extraction_room_slot = -1
	_reset_extraction_window_state()
	_clear_local_extraction_window_state()
	host_port = -1
	host_bind_address = ""
	join_target_address = ""
	join_target_port = -1
	host_requested_port = -1
	host_listen_port = -1
	_set_connected_peers([], "disconnect_peer_%s" % reason)
	peer_reconcile_accum = 0.0
	is_host = false
	emit_signal("item_state_changed", {})
	var run_state := _run_state()
	if run_state != null:
		run_state.clear()
	var event_log := _event_log()
	if event_log != null:
		event_log.clear()
	emit_signal("connection_changed", "Disconnected")
	emit_signal("host_endpoint_changed", host_bind_address, host_listen_port)
	emit_signal("lobby_updated", players, ready_by_id, is_host)

func stop_host() -> void:
	if not is_host:
		return
	emit_signal("connection_changed", "Stopping host...")
	disconnect_peer("stop_host")

func set_local_ready(ready_flag: bool) -> void:
	var mp := _mp()
	if mp == null or mp.multiplayer_peer == null:
		push_warning("NetworkManager: Cannot set ready - not connected to any players")
		return
	var uid := mp.get_unique_id()
	if is_host:
		_set_ready(uid, ready_flag, "set_local_ready_host")
		_reconcile_ready_map_for_connected_peers(false)
		_broadcast_lobby()
		return
	client_set_ready.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, uid, ready_flag)

func start_run(seed_override: int = 0, room_count: int = 15) -> void:
	var mp := _mp()
	var connected := mp != null and mp.multiplayer_peer != null
	_nm_log("START_RUN_REQUEST local=%d connected=%s is_host=%s peers=%s ready=%s run_active=%s seed=%d room_count=%d" % [
		mp.get_unique_id() if mp != null else -1,
		str(connected),
		str(is_host),
		str(connected_peers),
		str(ready_by_id),
		str(run_active),
		seed_override,
		room_count
	])
	var can_start := can_host_start_run(connected_peers, ready_by_id, connected, run_active)
	if not bool(can_start.get("allowed", false)):
		_nm_log("START_RUN_DENY reason=%s gate=%s" % [str(can_start.get("reason", "unknown")), str(can_start)])
		emit_signal("connection_changed", str(can_start.get("reason", "Start denied")))
		return
	var generator := RUN_GENERATOR_SCRIPT.new()
	var role_service := ROLE_SERVICE_SCRIPT.new()
	var run_seed := seed_override
	if run_seed == 0:
		run_seed = int(Time.get_unix_time_from_system())
	var chain := generator.generate_layout(run_seed, room_count)
	roles_by_peer = role_service.assign_roles(connected_peers, run_seed)
	var artifacts: Array = generator.generate_evidence_spawns(run_seed, chain)
	var items: Array = item_service.generate_item_spawns(run_seed, chain)
	artifacts_by_id.clear()
	items_by_id.clear()
	for artifact in artifacts:
		var artifact_id := int(artifact["artifact_id"])
		artifacts_by_id[artifact_id] = artifact
	for item_data in items:
		var item_id := int(item_data["item_id"])
		items_by_id[item_id] = item_data
	next_artifact_id = artifacts.size() + 1
	disturbance_until_by_room.clear()
	camera_jam_until_by_room.clear()
	next_noise_trace_tick_by_peer.clear()
	forge_counter_by_room.clear()
	check_counter_by_peer.clear()
	next_event_id = 1
	local_sabotage_cooldown_until_tick = 0
	run_active = true
	extraction_room_slot = maxi(chain.size() - 1, 0)
	_reset_extraction_window_state()
	_clear_local_extraction_window_state()

	var event_log := _event_log()
	if event_log != null:
		event_log.clear()
	var payload := build_run_start_payload(run_seed, chain, connected_peers)
	host_start_run.rpc(payload["seed"], payload["room_chain"], payload["peer_ids"])
	_reveal_roles_to_clients()
	_broadcast_artifact_state()
	_broadcast_item_state()
	record_public_event("run_started", -1, -1, {"seed": run_seed})

func send_client_input(move_axis: float, jump_pressed: bool, seq: int, pos: Vector2 = Vector2.ZERO, pack_flags: int = 0) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		input_by_peer[mp.get_unique_id()] = {"move": move_axis, "jump": jump_pressed, "seq": seq, "pos": pos, "flags": pack_flags}
		return
	client_input.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, move_axis, jump_pressed, seq, pos, pack_flags)

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
			_host_end_run_impl(reason)

func all_ready() -> bool:
	if connected_peers.is_empty():
		return false
	for peer_id in connected_peers:
		if not bool(ready_by_id.get(peer_id, false)):
			return false
	return true

func can_host_start_run(peer_ids: Array, ready_state: Dictionary, connected_flag: bool, run_active_flag: bool) -> Dictionary:
	if not connected_flag:
		return {"allowed": false, "reason": "Network not in connected state"}
	if run_active_flag:
		return {"allowed": false, "reason": "Run already active"}
	if not is_host:
		return {"allowed": false, "reason": "Only host can start"}
	var min_players := maxi(int(network_defaults.get("min_players_to_start", 1)), 1)
	if peer_ids.size() < min_players:
		var clients_joined := maxi(peer_ids.size() - 1, 0)
		var clients_needed := maxi(min_players - 1, 0)
		return {"allowed": false, "reason": "Waiting for at least %d player to join (currently: %d)" % [clients_needed, clients_joined]}
	var waiting_on: Array[String] = []
	for peer_raw in peer_ids:
		var peer_id := int(peer_raw)
		if not bool(ready_state.get(peer_id, false)):
			waiting_on.append("P%d" % peer_id)
	if not waiting_on.is_empty():
		return {"allowed": false, "reason": "Waiting for ready from: %s" % ", ".join(waiting_on)}
	return {"allowed": true, "reason": ""}

func _broadcast_lobby() -> void:
	var payload := _build_lobby_payload()
	players = payload["players"]
	host_sync_lobby.rpc(payload["players"], payload["ready_state"], payload["is_host"])
	host_sync_peers.rpc(payload["connected_peers"])

func _on_peer_connected(peer_id: int) -> void:
	if not is_host:
		return
	_server_reconcile_connected_peers(true)
	_log_mp_state("peer_connected")
	_log_connection_event("peer_connected", "peer_id=%d" % peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	if is_host:
		_server_reconcile_connected_peers(true)
		_log_mp_state("peer_disconnected")
	else:
		_update_connected_peer(peer_id, false)
		_reconcile_ready_map_for_connected_peers(false)
		input_by_peer.erase(peer_id)
		emit_signal("lobby_updated", players, ready_by_id, is_host)
	_log_connection_event("peer_disconnected", "peer_id=%d" % peer_id)

func _on_connected_to_server() -> void:
	var mp := _mp()
	if mp == null:
		return
	_update_connected_peer(mp.get_unique_id(), true)
	_log_mp_state("connected_to_server")
	emit_signal("connection_changed", "Connected to host %s:%d" % [join_target_address, join_target_port])
	_log_connection_event("connected_to_server", "target=%s:%d" % [join_target_address, join_target_port])

func _on_connection_failed() -> void:
	_set_connected_peers([], "connection_failed")
	var hint := _build_port_mismatch_hint(join_target_port)
	var message := "Connection failed to %s:%d (%s)%s" % [join_target_address, join_target_port, error_string(ERR_CANT_CONNECT), hint]
	emit_signal("connection_changed", message)
	_log_connection_event("connection_failed", "target=%s:%d err=%s%s" % [join_target_address, join_target_port, error_string(ERR_CANT_CONNECT), hint])

func _on_server_disconnected() -> void:
	_log_connection_event("server_disconnected", "")
	disconnect_peer("server_disconnected")
	emit_signal("connection_changed", "Host disconnected")

@rpc("any_peer", "reliable")
func client_set_ready(peer_id: int, ready_flag: bool) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	var sender := mp.get_remote_sender_id()
	var peers_before := connected_peers.duplicate()
	var peers_now := recompute_connected_peers_for_test(mp.get_unique_id(), _remote_peers_from_mp(mp))
	_nm_log("READY_RPC sender=%d peer_id=%d ready=%s peers_now=%s connected_before=%s" % [sender, peer_id, str(ready_flag), str(peers_now), str(peers_before)])
	if not validate_ready_rpc_for_test(sender, peer_id, mp.get_unique_id(), _remote_peers_from_mp(mp)):
		_nm_log("READY_RPC_REJECT sender=%d peer_id=%d peers_now=%s" % [sender, peer_id, str(peers_now)])
		return
	_set_connected_peers(peers_now, "client_set_ready_accept_sender_%d" % sender)
	_set_ready(peer_id, ready_flag, "client_set_ready")
	_reconcile_ready_map_for_connected_peers(false)
	_broadcast_lobby()
	_nm_log("READY_RPC_ACCEPT sender=%d peer_id=%d ready=%s connected_after=%s" % [sender, peer_id, str(ready_flag), str(connected_peers)])
	_warn_if_server_peer_mismatch("ready_rpc_accept_post")

@rpc("authority", "call_local", "reliable")
func host_sync_lobby(peer_ids: Array, ready_state: Dictionary, host_flag: bool) -> void:
	var mp := _mp()
	if is_host and mp != null and mp.is_server():
		return
	players.clear()
	for peer_id in peer_ids:
		players.append(int(peer_id))
	ready_by_id = ready_state.duplicate(true)
	is_host = host_flag and mp != null and mp.is_server()
	emit_signal("lobby_updated", players, ready_by_id, is_host)

@rpc("authority", "call_local", "reliable")
func host_sync_peers(peer_ids: Array) -> void:
	var mp := _mp()
	if not _should_apply_host_sync_peers(is_host, mp != null and mp.is_server()):
		return
	_set_connected_peers(peer_ids, "host_sync_peers_rpc")
	_reconcile_ready_map_for_connected_peers(false)

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
func client_input(move_axis: float, jump_pressed: bool, seq: int, pos: Vector2 = Vector2.ZERO, pack_flags: int = 0) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	var sender := mp.get_remote_sender_id()
	input_by_peer[sender] = {"move": move_axis, "jump": jump_pressed, "seq": seq, "pos": pos, "flags": pack_flags}


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
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_pickup(mp.get_unique_id(), artifact_id)
		return
	client_pickup_request.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, artifact_id)

func request_pickup_item(item_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_pickup_item(mp.get_unique_id(), item_id)
		return
	client_pickup_item_request.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, item_id)

func request_drop() -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_drop(mp.get_unique_id())
		return
	client_drop_request.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)

func request_steal(artifact_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_steal(mp.get_unique_id(), artifact_id)
		return
	client_steal_request.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, artifact_id)

func request_forge(room_slot: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_forge(mp.get_unique_id(), room_slot)
		return
	client_forge_request.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, room_slot)

func request_sabotage(room_slot: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_sabotage(mp.get_unique_id(), room_slot)
		return
	client_sabotage_request.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, room_slot)

func request_check_artifact(artifact_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_check_artifact(mp.get_unique_id(), artifact_id)
		return
	client_check_artifact_request.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, artifact_id)

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

func get_local_sabotage_cooldown_remaining() -> int:
	var local_tick := latest_tick
	if is_host:
		local_tick = current_server_tick
	return maxi(local_sabotage_cooldown_until_tick - local_tick, 0)

func sabotage_cooldown_until_from_tick(start_tick: int) -> int:
	return start_tick + SABOTAGE_COOLDOWN_TICKS

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

func _advance_extraction_window(tick: int) -> String:
	var extraction_details := _find_extraction_completion_details()
	if extraction_window_started_tick >= 0:
		if extraction_details.is_empty():
			_abort_extraction_window(tick)
			return ""
		if int(extraction_details.get("artifact_id", 0)) != extraction_window_artifact_id or int(extraction_details.get("owner_peer_id", 0)) != extraction_window_owner_peer_id:
			_abort_extraction_window(tick)
			return ""
		if tick - extraction_window_started_tick >= EXTRACTION_WINDOW_TICKS:
			return "extraction_objective"
		return ""
	if not extraction_details.is_empty() and extraction_window_last_abort_tick != tick:
		_start_extraction_window(tick, extraction_details)
	return ""

func _host_end_run_impl(reason: String) -> void:
	if not is_host or not run_active:
		return
	run_active = false
	if reason == "extraction_objective":
		var extraction_details := _find_extraction_completion_details()
		if not extraction_details.is_empty():
			record_public_event("extraction_completed", int(extraction_details.get("room_slot", -1)), int(extraction_details.get("owner_peer_id", -1)), {
				"artifact_id": int(extraction_details.get("artifact_id", 0))
			})
	_reset_extraction_window_state()
	record_public_event("run_ended", -1, -1, {})
	var payload := build_run_end_payload(reason)
	host_run_ended.rpc(payload)

func compute_end_reason_for_tick(tick: int) -> String:
	var extraction_reason := _advance_extraction_window(tick)
	if not extraction_reason.is_empty():
		return extraction_reason
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
		var owner_peer_id := int(artifact.get("owner_peer_id", 0))
		if owner_peer_id <= 0:
			continue
		var owner_key := str(owner_peer_id)
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
	var mp := _mp()
	if mp == null:
		return 0
	var local_id := mp.get_unique_id()
	for artifact_id in artifacts_by_id.keys():
		var artifact: Dictionary = artifacts_by_id[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) == local_id:
			return int(artifact_id)
	return 0

func is_local_extraction_window_active() -> bool:
	return local_extraction_window_active

func get_items_snapshot() -> Dictionary:
	return items_by_id.duplicate(true)

func get_item_names_for_peer(peer_id: int) -> Array[String]:
	var names: Array[String] = []
	for item_data in items_by_id.values():
		var item_dict: Dictionary = item_data
		if int(item_dict.get("owner_peer_id", 0)) != peer_id:
			continue
		if bool(item_dict.get("consumed", false)):
			continue
		names.append(str(item_dict.get("display_name", item_dict.get("item_def_id", ""))))
	names.sort()
	return names

func get_local_item_names() -> Array[String]:
	var mp := _mp()
	if mp == null:
		return []
	return get_item_names_for_peer(mp.get_unique_id())

func get_carry_speed_multiplier_for_peer(peer_id: int) -> float:
	return item_service.carry_speed_multiplier_for_items(_item_def_ids_for_peer(peer_id))

func track_noise_trace(peer_id: int, room_slot: int, carrying_artifact: bool) -> void:
	if not is_host or not run_active or not carrying_artifact:
		return
	var next_due := int(next_noise_trace_tick_by_peer.get(peer_id, 0))
	if current_server_tick < next_due:
		return
	var interval: int = item_service.noise_trace_interval_for_items(_item_def_ids_for_peer(peer_id))
	next_noise_trace_tick_by_peer[peer_id] = current_server_tick + interval
	record_public_event("noise_trace", room_slot, -1, {})

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
	var mp := _mp()
	if mp == null or mp.multiplayer_peer == null:
		host_push_public_event(event)
		return
	host_push_public_event.rpc(event)

func record_private_event(target_peer_id: int, event_type: String, room_slot: int, actor_peer_id: int, meta: Dictionary = {}) -> void:
	if not is_host:
		return
	var event := _build_event("private", event_type, room_slot, actor_peer_id, meta, target_peer_id)
	var mp := _mp()
	var local_id := -1
	if mp != null:
		local_id = mp.get_unique_id()
	if mp == null or mp.multiplayer_peer == null:
		host_push_private_event(event)
		return
	if target_peer_id == local_id:
		_consume_private_side_effect(event)
	else:
		host_push_private_event.rpc_id(target_peer_id, event)

@rpc("any_peer", "reliable")
func client_pickup_request(artifact_id: int) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_pickup(mp.get_remote_sender_id(), artifact_id)

@rpc("any_peer", "reliable")
func client_pickup_item_request(item_id: int) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_pickup_item(mp.get_remote_sender_id(), item_id)

@rpc("any_peer", "reliable")
func client_drop_request() -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_drop(mp.get_remote_sender_id())

@rpc("any_peer", "reliable")
func client_steal_request(artifact_id: int) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_steal(mp.get_remote_sender_id(), artifact_id)

@rpc("any_peer", "reliable")
func client_forge_request(room_slot: int) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_forge(mp.get_remote_sender_id(), room_slot)

@rpc("any_peer", "reliable")
func client_sabotage_request(room_slot: int) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_sabotage(mp.get_remote_sender_id(), room_slot)

@rpc("any_peer", "reliable")
func client_check_artifact_request(artifact_id: int) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_check_artifact(mp.get_remote_sender_id(), artifact_id)

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
func host_sync_item_state(payload: Array) -> void:
	items_by_id.clear()
	for item_raw in payload:
		var item_dict: Dictionary = item_raw
		var item_id := int(item_dict.get("item_id", 0))
		items_by_id[item_id] = item_dict.duplicate(true)
	emit_signal("item_state_changed", items_by_id.duplicate(true))

@rpc("authority", "call_local", "reliable")
func host_push_public_event(event: Dictionary) -> void:
	if str(event.get("visibility", "")) != "public":
		return
	_consume_public_side_effect(event)
	var event_log := _event_log()
	if event_log != null:
		event_log.add_event(event)

@rpc("authority", "reliable")
func host_push_private_event(event: Dictionary) -> void:
	if str(event.get("visibility", "")) != "private":
		return
	var mp := _mp()
	if mp != null and mp.multiplayer_peer != null:
		var local_id := mp.get_unique_id()
		var target_peer_id := int(event.get("target_peer_id", -1))
		if target_peer_id != -1 and target_peer_id != local_id:
			return
	_consume_private_side_effect(event)

@rpc("authority", "call_local", "reliable")
func host_hazard_pulse(room_slot: int, source_peer_id: int, reason: String) -> void:
	emit_signal("hazard_pulse_requested", room_slot, source_peer_id, reason)

@rpc("authority", "call_local", "reliable")
func host_run_ended(payload: Dictionary) -> void:
	run_active = false
	emit_signal("run_ended", payload)

func reset_to_lobby(_reason: String = "manual") -> void:
	if is_host:
		_set_connected_peers([], "reset_to_lobby_host")
		_reconcile_ready_map_for_connected_peers(false)
		_broadcast_lobby()
		players.clear()
		ready_by_id.clear()
		input_by_peer.clear()
		latest_snapshot.clear()
		roles_by_peer.clear()
		artifacts_by_id.clear()
		items_by_id.clear()
		player_pos_by_peer.clear()
		player_room_by_peer.clear()
		sabotage_cooldown_until_by_peer.clear()
		disturbance_until_by_room.clear()
		next_noise_trace_tick_by_peer.clear()
		forge_counter_by_room.clear()
		check_counter_by_peer.clear()
		current_server_tick = 0
		next_artifact_id = 1
		next_event_id = 1
		local_sabotage_cooldown_until_tick = 0
		run_active = false
		extraction_room_slot = -1
		host_port = -1
		host_bind_address = ""
		join_target_address = ""
		join_target_port = -1
		host_requested_port = -1
		host_listen_port = -1
		peer_reconcile_accum = 0.0
		is_host = false
		var run_state := _run_state()
		if run_state != null:
			run_state.clear()
		var event_log := _event_log()
		if event_log != null:
			event_log.clear()
		emit_signal("item_state_changed", {})
		emit_signal("connection_changed", "Disconnected")
		emit_signal("host_endpoint_changed", host_bind_address, host_listen_port)
		emit_signal("lobby_updated", players, ready_by_id, is_host)
	else:
		_set_connected_peers([], "reset_to_lobby_client")
		_reconcile_ready_map_for_connected_peers(false)
		input_by_peer.clear()
		items_by_id.clear()
		emit_signal("item_state_changed", {})
		emit_signal("lobby_updated", players, ready_by_id, is_host)

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
	var next: Dictionary = evidence_service.apply_owner(artifact, requester_id, player_pos)
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
	var next: Dictionary = evidence_service.apply_owner(artifact, 0, pos)
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
	var next: Dictionary = evidence_service.apply_owner(artifact, requester_id, stealer_pos)
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
	var forged: Dictionary = evidence_service.build_forged_artifact(
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

func _host_pickup_item(requester_id: int, item_id: int) -> void:
	if not items_by_id.has(item_id):
		_deny_action(requester_id, "no_target")
		return
	var item_data: Dictionary = items_by_id[item_id]
	var requester_pos: Vector2 = player_pos_by_peer.get(requester_id, Vector2(999999, 999999))
	if not item_service.can_pickup(item_data, requester_pos):
		_deny_action(requester_id, "out_of_range", int(item_data.get("room_slot", -1)))
		return
	items_by_id[item_id] = item_service.apply_owner(item_data, requester_id, requester_pos)
	_broadcast_item_state()
	record_public_event("item_picked", int(item_data.get("room_slot", -1)), -1, {"item_id": item_id})
	record_private_event(requester_id, "item_note", int(item_data.get("room_slot", -1)), requester_id, {
		"label": "Picked up %s" % str(item_data.get("display_name", item_data.get("item_def_id", "item"))),
		"item_id": item_id
	})

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
	sabotage_cooldown_until_by_peer[requester_id] = sabotage_cooldown_until_from_tick(current_server_tick)
	var accident_label := "Power flicker"
	var camera_jam_label := "Camera feed glitched"
	var disturbance_duration: float = item_service.sabotage_disturbance_duration_for_items(_item_def_ids_for_peer(requester_id))
	var disturbance_until_tick := current_server_tick + int(round(disturbance_duration * 60.0))
	disturbance_until_by_room[room_slot] = disturbance_until_tick
	camera_jam_until_by_room[room_slot] = disturbance_until_tick
	if _consume_first_item_by_def(requester_id, "grease_rag"):
		record_public_event("item_used", room_slot, -1, {"label": "Disturbance lingered"})
		record_private_event(requester_id, "item_note", room_slot, requester_id, {"label": "Grease Rag extended the disturbance"})
		_broadcast_item_state()
	broadcast_hazard_pulse(room_slot, -1, "sabotage_camera_jam")
	record_public_event("sabotage_accident", room_slot, -1, {"label": accident_label})
	record_public_event("sabotage_camera_jam", room_slot, -1, {"label": camera_jam_label})
	record_private_event(requester_id, "sabotage_private_confirm", room_slot, requester_id, {"label": "Camera jam"})

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
	var disturbed_room := current_server_tick <= int(disturbance_until_by_room.get(artifact_slot, -1))
	var camera_jammed := current_server_tick <= int(camera_jam_until_by_room.get(artifact_slot, -1))
	var bonus: int = item_service.warden_score_bonus_for_items(_item_def_ids_for_peer(requester_id), disturbed_room)
	var score := _compute_warden_check_score(artifact, check_counter, bonus)
	if camera_jammed:
		score = _camera_jam_adjusted_warden_score(score)
	check_counter_by_peer[requester_id] = check_counter + 1
	if disturbed_room and _consume_first_item_by_def(requester_id, "chalk_seal"):
		record_public_event("item_used", artifact_slot, -1, {"label": "Inspection residue stabilized"})
		record_private_event(requester_id, "item_note", artifact_slot, requester_id, {"label": "Chalk Seal sharpened the reading"})
		_broadcast_item_state()
	if camera_jammed:
		record_private_event(requester_id, "warden_camera_jam_note", artifact_slot, requester_id, {"label": "Camera jam residue lowered confidence"})
	record_private_event(requester_id, "warden_check_result", artifact_slot, requester_id, {
		"artifact_id": artifact_id,
		"score": score
	})
	record_public_event("evidence_checked", artifact_slot, -1, {})

func _find_carried_artifact_by_peer(peer_id: int) -> int:
	for artifact_id in artifacts_by_id.keys():
		var artifact: Dictionary = artifacts_by_id[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) == peer_id:
			return int(artifact_id)
	return 0

func _reveal_roles_to_clients() -> void:
	var role_service := ROLE_SERVICE_SCRIPT.new()
	var mp := _mp()
	if mp == null:
		return
	var host_id := mp.get_unique_id()
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

func _broadcast_item_state() -> void:
	if not is_host:
		return
	host_sync_item_state.rpc(_serialize_items())

func _serialize_artifacts() -> Array:
	var ids: Array = artifacts_by_id.keys()
	ids.sort()
	var data: Array = []
	for artifact_id in ids:
		data.append(artifacts_by_id[artifact_id])
	return data

func _serialize_items() -> Array:
	var ids: Array = items_by_id.keys()
	ids.sort()
	var data: Array = []
	for item_id in ids:
		data.append(Dictionary(items_by_id[item_id]).duplicate(true))
	return data

func _build_event(visibility: String, event_type: String, room_slot: int, actor_peer_id: int, meta: Dictionary, target_peer_id: int = -1) -> Dictionary:
	var event := {
		"event_id": next_event_id,
		"tick": current_server_tick,
		"room_slot": room_slot,
		"actor_peer_id": actor_peer_id,
		"event_type": event_type,
		"visibility": visibility,
		"meta": meta,
		"target_peer_id": target_peer_id
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
		"extraction_completed":
			return _pick_meta_fields(meta, ["artifact_id"])
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

func _compute_warden_check_score(artifact: Dictionary, check_counter: int, bonus: int = 0) -> int:
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
	return clampi((mixed % 101) + bonus, 0, 100)

func _camera_jam_adjusted_warden_score(score: int) -> int:
	return mini(clampi(score - 8, 0, 100), CAMERA_JAM_MAX_WARDEN_SCORE)

func camera_jam_adjusted_warden_score_for_test(score: int) -> int:
	return _camera_jam_adjusted_warden_score(score)

func extraction_window_ticks_for_test() -> int:
	return EXTRACTION_WINDOW_TICKS

func _deny_action(target_peer_id: int, reason: String, room_slot: int = -1) -> void:
	record_private_event(target_peer_id, "action_denied_ui", room_slot, target_peer_id, {"reason": reason})

func _consume_private_side_effect(event: Dictionary) -> void:
	var event_type := str(event.get("event_type", ""))
	if event_type == "action_denied_ui":
		var meta: Dictionary = event.get("meta", {})
		emit_signal("action_denied", str(meta.get("reason", "unknown")))
		return
	if event_type == "sabotage_private_confirm":
		var tick := int(event.get("tick", 0))
		local_sabotage_cooldown_until_tick = sabotage_cooldown_until_from_tick(tick)
	var event_log := _event_log()
	if event_log != null:
		event_log.add_event(event)

func _consume_public_side_effect(event: Dictionary) -> void:
	var event_type := str(event.get("event_type", ""))
	match event_type:
		"extraction_window_started":
			local_extraction_window_active = true
			local_extraction_window_room_slot = int(event.get("room_slot", -1))
			var meta: Dictionary = event.get("meta", {})
			local_extraction_window_duration_ticks = int(meta.get("duration_ticks", EXTRACTION_WINDOW_TICKS))
		"extraction_window_aborted", "extraction_completed", "run_ended":
			_clear_local_extraction_window_state()

func _reset_extraction_window_state() -> void:
	extraction_window_started_tick = -1
	extraction_window_artifact_id = 0
	extraction_window_owner_peer_id = 0
	extraction_window_last_abort_tick = -1

func _start_extraction_window(tick: int, extraction_details: Dictionary) -> void:
	extraction_window_started_tick = tick
	extraction_window_artifact_id = int(extraction_details.get("artifact_id", 0))
	extraction_window_owner_peer_id = int(extraction_details.get("owner_peer_id", 0))
	record_public_event("extraction_window_started", int(extraction_details.get("room_slot", extraction_room_slot)), -1, {"duration_ticks": EXTRACTION_WINDOW_TICKS})

func _abort_extraction_window(tick: int) -> void:
	if extraction_window_started_tick < 0:
		return
	record_public_event("extraction_window_aborted", extraction_room_slot, -1, {})
	_reset_extraction_window_state()
	extraction_window_last_abort_tick = tick

func _clear_local_extraction_window_state() -> void:
	local_extraction_window_active = false
	local_extraction_window_room_slot = -1
	local_extraction_window_duration_ticks = 0

func _find_extraction_completion_details() -> Dictionary:
	if extraction_room_slot < 0:
		return {}
	for artifact_id in artifacts_by_id.keys():
		var artifact: Dictionary = artifacts_by_id[artifact_id]
		var owner_peer_id := int(artifact.get("owner_peer_id", 0))
		if owner_peer_id == 0:
			continue
		var owner_slot := int(player_room_by_peer.get(owner_peer_id, -1))
		if owner_slot == extraction_room_slot:
			return {
				"artifact_id": int(artifact_id),
				"owner_peer_id": owner_peer_id,
				"room_slot": extraction_room_slot
			}
	return {}

func _item_def_ids_for_peer(peer_id: int) -> Array[String]:
	var item_ids: Array[String] = []
	for item_data in items_by_id.values():
		var item_dict: Dictionary = item_data
		if int(item_dict.get("owner_peer_id", 0)) != peer_id:
			continue
		if bool(item_dict.get("consumed", false)):
			continue
		item_ids.append(str(item_dict.get("item_def_id", "")))
	return item_ids

func _consume_first_item_by_def(peer_id: int, item_def_id: String) -> bool:
	var ids: Array = items_by_id.keys()
	ids.sort()
	for item_id_variant in ids:
		var item_id := int(item_id_variant)
		var item_dict: Dictionary = items_by_id[item_id]
		if int(item_dict.get("owner_peer_id", 0)) != peer_id:
			continue
		if bool(item_dict.get("consumed", false)):
			continue
		if str(item_dict.get("item_def_id", "")) != item_def_id:
			continue
		items_by_id[item_id] = item_service.consume(item_dict)
		return true
	return false

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

func get_default_network_config() -> Dictionary:
	return network_defaults.duplicate(true)

func get_host_port() -> int:
	return host_listen_port

func get_host_requested_port() -> int:
	return host_requested_port

func get_host_listen_port() -> int:
	return host_listen_port

func get_host_bind_address() -> String:
	return host_bind_address

func get_host_join_endpoint_for_local() -> String:
	if host_listen_port <= 0:
		return ""
	return "%s:%d" % [_recommended_join_address_for_display(host_bind_address), host_listen_port]

func get_join_target() -> String:
	if join_target_address.is_empty() or join_target_port <= 0:
		return ""
	return "%s:%d" % [join_target_address, join_target_port]

func get_connected_peer_ids() -> Array[int]:
	return connected_peers.duplicate()

func get_connected_player_count() -> int:
	return connected_peers.size()

func apply_connected_peer_update(peer_id: int, is_connected: bool) -> void:
	_update_connected_peer(peer_id, is_connected)

func set_connected_peers_for_test(next: Array) -> void:
	_set_connected_peers(next, "set_connected_peers_for_test")

func should_apply_host_sync_peers_for_test(host_flag: bool, is_server: bool) -> bool:
	return _should_apply_host_sync_peers(host_flag, is_server)

func build_lobby_payload_for_test() -> Dictionary:
	return _build_lobby_payload()

func recompute_connected_peers_for_test(self_id: int, remote_peers: Array[int]) -> Array[int]:
	var peers: Array[int] = []
	peers.append(self_id)
	for peer_id in remote_peers:
		if not peers.has(peer_id):
			peers.append(peer_id)
	peers.sort()
	return peers

func reconcile_ready_map_for_connected_peers() -> void:
	_reconcile_ready_map_for_connected_peers(false)

func _default_port() -> int:
	return int(network_defaults.get("default_port", DEFAULT_PORT))

func _default_bind_address() -> String:
	return str(network_defaults.get("default_bind_address", "0.0.0.0"))

func _default_join_address() -> String:
	return str(network_defaults.get("default_join_address", "127.0.0.1"))

func _build_host_port_candidates(requested_port: int, max_tries: int) -> Array[int]:
	var ports: Array[int] = []
	for offset in max_tries:
		ports.append(requested_port + offset)
	return ports

func pick_host_port(requested_port: int, fail_set: Dictionary, max_tries: int) -> int:
	for candidate_port in _build_host_port_candidates(requested_port, max_tries):
		if not fail_set.has(candidate_port):
			return candidate_port
	return -1

func _format_host_failure_message(bind_address: String, requested_port: int, max_tries: int, err: int) -> String:
	return "Host failed at %s:%d (+%d ports). Likely port in use/permission issue (%s). Try closing old hosts or choose another port." % [
		bind_address,
		requested_port,
		max_tries - 1,
		error_string(err)
	]

func _resolve_bind_address(preferred_join_address: String, bind_override: String) -> String:
	var override_value := bind_override.strip_edges()
	if not override_value.is_empty():
		return override_value
	var default_bind := _default_bind_address()
	var requested_join := preferred_join_address.strip_edges().to_lower()
	if requested_join in ["127.0.0.1", "localhost"] and default_bind == "0.0.0.0":
		return "127.0.0.1"
	return default_bind

func _recommended_join_address_for_display(bind_address: String) -> String:
	var normalized := bind_address.strip_edges().to_lower()
	if normalized == "0.0.0.0":
		return "127.0.0.1"
	if normalized == "localhost":
		return "127.0.0.1"
	return bind_address

func _build_port_mismatch_hint(requested_join_port: int) -> String:
	if host_listen_port > 0 and requested_join_port > 0 and host_listen_port != requested_join_port:
		return " Hint: local host is on port %d." % host_listen_port
	return ""

func set_host_endpoint_for_test(requested_port: int, listen_port: int, bind_address: String) -> void:
	host_requested_port = requested_port
	host_listen_port = listen_port
	host_port = listen_port
	host_bind_address = bind_address
	emit_signal("host_endpoint_changed", host_bind_address, host_listen_port)

func _host_end_run(reason: String) -> void:
	if not is_host or not run_active:
		return
	run_active = false
	if reason == "extraction_objective":
		var extraction_details := _find_extraction_completion_details()
		record_public_event(
			"extraction_completed",
			int(extraction_details.get("room_slot", extraction_room_slot)),
			int(extraction_details.get("owner_peer_id", -1)),
			{"artifact_id": int(extraction_details.get("artifact_id", 0))}
		)
	_reset_extraction_window_state()
	record_public_event("run_ended", -1, -1, {})
	var payload := build_run_end_payload(reason)
	host_run_ended.rpc(payload)

func _update_connected_peer(peer_id: int, is_connected: bool) -> void:
	var next_peers := connected_peers.duplicate()
	if is_connected:
		if not next_peers.has(peer_id):
			next_peers.append(peer_id)
	else:
		next_peers.erase(peer_id)
	_set_connected_peers(next_peers, "_update_connected_peer_%d_%s" % [peer_id, str(is_connected)])
	var local_id := -1
	var mp := _mp()
	if mp != null:
		local_id = mp.get_unique_id()
	_nm_log("PEERS_UPDATED local=%d host=%s peers=%s" % [local_id, str(is_host), str(connected_peers)])
	emit_signal("connected_peers_changed", connected_peers.duplicate())

func _server_reconcile_connected_peers(should_broadcast: bool) -> void:
	if not is_host:
		return
	var scene_mp := _mp()
	if scene_mp == null or scene_mp.multiplayer_peer == null:
		return
	var self_id := scene_mp.get_unique_id()
	var remote_peers: Array[int] = []
	for peer_id in scene_mp.get_peers():
		remote_peers.append(int(peer_id))
	var recomputed := recompute_connected_peers_for_test(self_id, remote_peers)
	if _int_array_equal(recomputed, connected_peers):
		return
	_set_connected_peers(recomputed, "_server_reconcile_connected_peers")
	_nm_log("RECONCILE_PEERS server self=%d peers=%s" % [self_id, str(connected_peers)])
	_reconcile_ready_map_for_connected_peers(false)
	if should_broadcast:
		_broadcast_lobby()

func _int_array_equal(a: Array[int], b: Array[int]) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		if a[i] != b[i]:
			return false
	return true

func _mp() -> MultiplayerAPI:
	if not is_inside_tree():
		return null
	if _active_mp != null:
		return _active_mp
	_select_active_mp("lazy_init")
	return _active_mp

func get_active_mp_for_ui() -> MultiplayerAPI:
	return _mp()

func set_active_mp_for_test(mp: MultiplayerAPI) -> void:
	_active_mp = mp

func has_active_mp_for_test() -> bool:
	return _active_mp != null

func choose_mp_kind_for_test(node_has_peer: bool, tree_has_peer: bool) -> String:
	if node_has_peer and not tree_has_peer:
		return "node"
	if tree_has_peer and not node_has_peer:
		return "tree"
	if node_has_peer and tree_has_peer:
		return "node"
	return "none"

func _log_connection_event(event_name: String, detail: String) -> void:
	var local_id := -1
	var mp := _mp()
	var has_peer := mp != null and mp.multiplayer_peer != null
	if mp != null:
		local_id = mp.get_unique_id()
	var is_server := has_peer and mp.is_server()
	_nm_log("NET_EVENT name=%s local=%d is_host=%s is_server=%s peers=%s %s" % [
		event_name,
		local_id,
		str(is_host),
		str(is_server),
		str(connected_peers),
		detail
	])

func _reconcile_ready_map_for_connected_peers(default_ready_for_new: bool) -> void:
	for peer_id in connected_peers:
		if not ready_by_id.has(peer_id):
			_set_ready(peer_id, default_ready_for_new, "reconcile_new_peer")
	var stale_ids: Array = ready_by_id.keys()
	for stale in stale_ids:
		var stale_id := int(stale)
		if not connected_peers.has(stale_id):
			_nm_log("READY_CLEAR peer_id=%d reason=reconcile_stale_peer_removed" % stale_id)
			ready_by_id.erase(stale)

func _set_connected_peers(next: Array, reason: String) -> void:
	var before := connected_peers.duplicate()
	var normalized: Array[int] = []
	for peer_raw in next:
		var peer_id := int(peer_raw)
		if not normalized.has(peer_id):
			normalized.append(peer_id)
	normalized.sort()
	connected_peers = normalized
	_nm_log("CONNECTED_PEERS_SET reason=%s stack_hint=%s before=%s after=%s" % [
		reason,
		reason,
		str(before),
		str(connected_peers)
	])
	emit_signal("connected_peers_changed", connected_peers.duplicate())
	_warn_if_server_peer_mismatch(reason)

func _set_ready(peer_id: int, ready: bool, reason: String) -> void:
	var before: Variant = ready_by_id.get(peer_id, null)
	ready_by_id[peer_id] = ready
	_nm_log("READY_SET peer_id=%d reason=%s before=%s after=%s" % [
		peer_id,
		reason,
		str(before),
		str(ready)
	])

func _build_lobby_payload() -> Dictionary:
	return {
		"players": connected_peers.duplicate(),
		"connected_peers": connected_peers.duplicate(),
		"ready_state": ready_by_id.duplicate(true),
		"is_host": is_host
	}

func _should_apply_host_sync_peers(host_flag: bool, is_server: bool) -> bool:
	return not (host_flag and is_server)

func _warn_if_server_peer_mismatch(reason: String) -> void:
	var mp := _mp()
	if mp == null or mp.multiplayer_peer == null or not mp.is_server():
		return
	var remote_count := _remote_peers_from_mp(mp).size()
	if remote_count > 0 and connected_peers.size() <= 1:
		_nm_log("WARNING stomp_suspected reason=%s remote_count=%d connected_peers=%s" % [reason, remote_count, str(connected_peers)])

func _peer_kind(mp: MultiplayerAPI) -> String:
	if mp == null:
		return "none"
	if mp.multiplayer_peer == null:
		return "no_peer"
	return mp.multiplayer_peer.get_class()

func _peer_id_text(mp: MultiplayerAPI) -> String:
	if mp == null or mp.multiplayer_peer == null:
		return "none"
	return "%s#%d" % [mp.multiplayer_peer.get_class(), mp.multiplayer_peer.get_instance_id()]

func _log_mp_state(tag: String) -> void:
	var mp := _mp()
	if mp == null:
		_nm_log("MP_STATE tag=%s mp=null" % tag)
		return
	var remote_peers := _remote_peers_from_mp(mp)
	_nm_log("MP_STATE tag=%s local=%d has_peer=%s is_server=%s remote_peers=%s" % [
		tag,
		mp.get_unique_id(),
		str(mp.multiplayer_peer != null),
		str(mp.multiplayer_peer != null and mp.is_server()),
		str(remote_peers)
	])

func _nm_log(message: String) -> void:
	var path_text := "<detached>"
	if is_inside_tree():
		path_text = str(get_path())
	print("NM_LOG pid=%d nm_id=%d path=%s %s" % [OS.get_process_id(), get_instance_id(), path_text, message])

func _node_mp_candidate() -> MultiplayerAPI:
	if not is_inside_tree():
		return null
	return get_multiplayer()

func _tree_mp_candidate() -> MultiplayerAPI:
	if not is_inside_tree():
		return null
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_multiplayer()

func _mp_for_signal_wiring() -> MultiplayerAPI:
	var node_mp := _node_mp_candidate()
	if node_mp != null:
		return node_mp
	return _tree_mp_candidate()

func _ensure_signals_wired_to_active_mp() -> void:
	if not signals_wired:
		return
	var mp := _mp()
	if mp == null:
		return
	if not mp.peer_connected.is_connected(_on_peer_connected):
		mp.peer_connected.connect(_on_peer_connected)
	if not mp.peer_disconnected.is_connected(_on_peer_disconnected):
		mp.peer_disconnected.connect(_on_peer_disconnected)
	if not mp.connected_to_server.is_connected(_on_connected_to_server):
		mp.connected_to_server.connect(_on_connected_to_server)
	if not mp.connection_failed.is_connected(_on_connection_failed):
		mp.connection_failed.connect(_on_connection_failed)
	if not mp.server_disconnected.is_connected(_on_server_disconnected):
		mp.server_disconnected.connect(_on_server_disconnected)

func _select_active_mp(tag: String) -> void:
	var node_mp := _node_mp_candidate()
	var tree_mp := _tree_mp_candidate()
	var node_has_peer := node_mp != null and node_mp.multiplayer_peer != null
	var tree_has_peer := tree_mp != null and tree_mp.multiplayer_peer != null
	var chosen_kind := choose_mp_kind_for_test(node_has_peer, tree_has_peer)
	if chosen_kind == "node":
		_active_mp = node_mp
	elif chosen_kind == "tree":
		_active_mp = tree_mp
	else:
		# Keep current pinned MP if no new authoritative peer exists.
		pass
	if node_has_peer and tree_has_peer and node_mp != tree_mp:
		_nm_log("WARNING MP_SELECT both_peers_set choosing=node tag=%s" % tag)
	_nm_log("MP_SELECT tag=%s chosen=%s node_peer=%s tree_peer=%s" % [
		tag,
		chosen_kind,
		_peer_kind(node_mp),
		_peer_kind(tree_mp)
	])

func _warn_if_double_peer_assignment(tag: String) -> void:
	var node_mp := _node_mp_candidate()
	var tree_mp := _tree_mp_candidate()
	if node_mp == null or tree_mp == null:
		return
	if node_mp == tree_mp:
		return
	if node_mp.multiplayer_peer == null or tree_mp.multiplayer_peer == null:
		return
	if node_mp.multiplayer_peer != tree_mp.multiplayer_peer:
		_nm_log("ERROR double_peer_assignment tag=%s node=%s tree=%s" % [tag, _peer_id_text(node_mp), _peer_id_text(tree_mp)])

func _clear_peer_assignments() -> void:
	var node_mp := _node_mp_candidate()
	var tree_mp := _tree_mp_candidate()
	if node_mp != null:
		node_mp.multiplayer_peer = null
	if tree_mp != null and tree_mp != node_mp:
		tree_mp.multiplayer_peer = null

func can_accept_ready_rpc_sender_for_test(sender: int, peer_id: int, peers: Array[int]) -> bool:
	if sender != peer_id:
		return false
	if not peers.has(peer_id):
		return false
	return true

func validate_ready_rpc_for_test(sender: int, peer_id: int, self_id: int, remote_peers: Array[int]) -> bool:
	var peers_now := recompute_connected_peers_for_test(self_id, remote_peers)
	return can_accept_ready_rpc_sender_for_test(sender, peer_id, peers_now)

func _remote_peers_from_mp(mp: MultiplayerAPI) -> Array[int]:
	var peers: Array[int] = []
	for peer_id in mp.get_peers():
		peers.append(int(peer_id))
	return peers
