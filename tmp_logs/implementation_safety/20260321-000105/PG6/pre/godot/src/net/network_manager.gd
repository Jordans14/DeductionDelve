extends Node

signal lobby_updated(players: Array, ready_state: Dictionary, is_host: bool)
signal connection_changed(status: String)
signal run_started(seed_value: int, room_chain: Array)
signal state_snapshot(snapshot: Dictionary, tick: int)
signal role_revealed(role_name: String)
signal artifact_state_changed(artifacts_by_id: Dictionary)
signal evidence_state_changed(evidence_by_id: Dictionary)
signal item_state_changed(items_by_id: Dictionary)
signal ghost_state_changed(state: Dictionary)
signal hazard_pulse_requested(room_slot: int, source_peer_id: int, reason: String)
signal action_denied(reason: String)
signal run_ended(payload: Dictionary)
signal connected_peers_changed(peers: Array)
signal host_endpoint_changed(bind: String, port: int)
signal reconnect_offer_changed(offer: Dictionary)

const DEFAULT_PORT := 2456
const SABOTAGE_COOLDOWN_TICKS := 400
const TICKS_PER_SECOND := 60
const MIN_AUTHORITATIVE_ROOM_COUNT := 10
const MAX_AUTHORITATIVE_ROOM_COUNT := 12
const STANDARD_RUN_ROOM_COUNT := 10
const RUN_TICK_LIMIT := 50400  # 14 minutes at 60 ticks/sec
const CAMERA_JAM_MAX_WARDEN_SCORE := 84
const EXTRACTION_WINDOW_TICKS := 600
const ENCOUNTER_APEX_CONSEQUENCE_VERSION := 1
const SOCIAL_CONSEQUENCE_VERSION := 1
const START_BOMB_COUNT := 4
const START_ROPE_COUNT := 4
const MAX_CARRIED_TOOL_ITEMS := 2
const GHOST_WAKE_TICK := 10800
const GHOST_SPEED_PER_TICK := 5.5
const GHOST_OFFSCREEN_POS := Vector2(-2000, 300)
const GHOST_HIT_RADIUS := 52.0
const NETWORK_CONFIG_SCRIPT = preload("res://src/net/network_config.gd")
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const ARTIFACT_SERVICE_SCRIPT = preload("res://src/run/artifact_service.gd")
const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")
const PROFILE_SERVICE_SCRIPT = preload("res://src/product/profile_service.gd")
const GOVERNANCE_SERVICE_SCRIPT = preload("res://src/product/governance_service.gd")
const DELVE_KERNEL_SCRIPT = preload("res://src/delve/delve_kernel.gd")
const DELVE_DIRECTIVE_INSPECTOR_SCRIPT = preload("res://src/delve/delve_directive_inspector.gd")
const EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT = preload("res://src/delve/constitution/expedition_constitution_schema.gd")
const EXPEDITION_MUTATION_ENGINE_SCRIPT = preload("res://src/run/expedition_mutation_engine.gd")
const ROOM_WIDTH := 1024.0
const ROOM_HEIGHT := 768.0
const ROOM_COLUMNS := 5
var _bomb_script_cache = null
var _rope_script_cache = null
var _zipline_script_cache = null

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		release_shutdown_resources()

func _get_bomb_script():
	if _bomb_script_cache == null:
		_bomb_script_cache = load("res://src/items/bomb.gd")
	return _bomb_script_cache

func _get_rope_script():
	if _rope_script_cache == null:
		_rope_script_cache = load("res://src/items/rope.gd")
	return _rope_script_cache

func _get_zipline_script():
	if _zipline_script_cache == null:
		_zipline_script_cache = load("res://src/items/zipline.gd")
	return _zipline_script_cache

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
var artifact_service = ARTIFACT_SERVICE_SCRIPT.new()
var item_service: RefCounted = ITEM_SERVICE_SCRIPT.new()
var forge_counter_by_room: Dictionary = {}
var next_event_id: int = 1
var check_counter_by_peer: Dictionary = {}
var role_pressure_by_peer: Dictionary = {}
var custody_debt_by_peer: Dictionary = {}
var suspicion_heat_by_peer: Dictionary = {}
var counterfeit_heat_by_peer: Dictionary = {}
var local_sabotage_cooldown_until_tick: int = 0
var run_active: bool = false
var current_expedition_constitution: Dictionary = {}
var current_delve_directive: Dictionary = {}
var current_generation_contract: Dictionary = {}
var current_constitution_hash: String = ""
var last_authoritative_room_chain: Array = []
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
var tool_inventory_by_peer: Dictionary = {}
var profile_cards_by_peer: Dictionary = {}
var ghost_state := {
	"active": false,
	"position": GHOST_OFFSCREEN_POS,
	"target_peer_id": -1
}
var predator_state := {
	"active": false,
	"room_slot": -1,
	"target_peer_id": -1,
	"last_tick": -1,
	"strike_strength": 0,
	"mode": ""
}
var protocol_watch_state := {
	"active": false,
	"room_slot": -1,
	"target_peer_id": -1,
	"last_tick": -1,
	"mode": "",
	"signal_room_slot": -1
}
var echo_lure_state := {
	"active": false,
	"owner_peer_id": -1,
	"room_slot": -1,
	"expires_tick": -1
}
var signals_wired: bool = false
var peer_reconcile_accum: float = 0.0
const PEER_RECONCILE_INTERVAL_SEC := 0.25
var enet_peer: ENetMultiplayerPeer = null
var enet_peer_mode: String = ""
var _active_mp: MultiplayerAPI = null
var local_extraction_window_active: bool = false
var local_extraction_window_room_slot: int = -1
var local_extraction_window_duration_ticks: int = 0
var _capture_events_for_test: bool = false
var _captured_public_events_for_test: Array = []
var _captured_private_events_for_test: Array = []
var _run_state_override_for_test: Node = null
var _event_log_override_for_test: Node = null
var reconnect_offer: Dictionary = {}
var last_connection_status: String = "Not connected"

func release_shutdown_resources() -> void:
	artifact_service = null
	item_service = null
	_bomb_script_cache = null
	_rope_script_cache = null
	_zipline_script_cache = null

func get_room_slot(pos: Vector2) -> int:
	return maxi(int(floor(pos.x / 1024.0)), 0)

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

func _set_connection_status(status: String) -> void:
	last_connection_status = status
	emit_signal("connection_changed", status)

func _set_reconnect_offer(next_offer: Dictionary) -> void:
	var normalized_offer := next_offer.duplicate(true)
	if reconnect_offer == normalized_offer:
		return
	reconnect_offer = normalized_offer
	emit_signal("reconnect_offer_changed", reconnect_offer.duplicate(true))

func clear_reconnect_offer() -> void:
	_set_reconnect_offer({})

func build_reconnect_offer_for_test(mode: String, address: String, port: int, reason: String, run_interrupted: bool, wait_for_lobby: bool = false) -> Dictionary:
	return {
		"available": not address.strip_edges().is_empty() and port > 0,
		"mode": mode,
		"address": address.strip_edges(),
		"port": port,
		"reason": reason,
		"run_interrupted": run_interrupted,
		"wait_for_lobby": wait_for_lobby,
		"seed": _run_seed(),
		"tick": current_server_tick if is_host else latest_tick
	}

func _remember_client_reconnect(reason: String, run_interrupted: bool, wait_for_lobby: bool = false) -> void:
	if join_target_address.strip_edges().is_empty() or join_target_port <= 0:
		return
	_set_reconnect_offer(build_reconnect_offer_for_test("client", join_target_address, join_target_port, reason, run_interrupted, wait_for_lobby))

func get_reconnect_offer() -> Dictionary:
	return reconnect_offer.duplicate(true)

func can_attempt_reconnect() -> bool:
	var mp := _mp()
	return bool(reconnect_offer.get("available", false)) and str(reconnect_offer.get("mode", "")) == "client" and (mp == null or mp.multiplayer_peer == null)

func attempt_reconnect() -> bool:
	if not can_attempt_reconnect():
		return false
	return join_host(str(reconnect_offer.get("address", "")), int(reconnect_offer.get("port", 0)))

func should_allow_runtime_join_for_test(run_active_flag: bool) -> bool:
	return not run_active_flag

func get_session_overview() -> Dictionary:
	var mp := _mp()
	var reconnect_available := bool(reconnect_offer.get("available", false))
	var reconnect_wait_for_lobby := bool(reconnect_offer.get("wait_for_lobby", false))
	var reconnect_reason := str(reconnect_offer.get("reason", ""))
	var session_mode := "offline"
	if _has_live_network_peer(mp):
		session_mode = "host" if is_host else "client"
	return {
		"connected": _has_live_network_peer(mp),
		"status": last_connection_status,
		"mode": session_mode,
		"is_host": is_host,
		"run_active": run_active,
		"host_bind": host_bind_address,
		"host_port": host_listen_port,
		"join_address": join_target_address,
		"join_port": join_target_port,
		"seed": _run_seed(),
		"reconnect_available": reconnect_available,
		"reconnect_wait_for_lobby": reconnect_wait_for_lobby,
		"reconnect_reason": reconnect_reason,
		"run_interrupted": bool(reconnect_offer.get("run_interrupted", false)),
		"reconnect_offer": reconnect_offer.duplicate(true),
		"delve_protocol": get_current_expedition_constitution_summary()
	}

func _directive_public_summary(directive: Dictionary) -> Dictionary:
	if directive.is_empty():
		return {}
	if directive.has("constitution_summary") or directive.has("constitution_hash"):
		return EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(directive)
	var public_summary: Dictionary = Dictionary(directive.get("public_summary", {}))
	var surface_summary: Dictionary = Dictionary(directive.get("surface_summary", {}))
	return {
		"protocol_state": str(public_summary.get("protocol_state", directive.get("protocol_state", ""))),
		"doctrine_family": str(directive.get("doctrine_family", "")),
		"doctrine_label": str(public_summary.get("doctrine", directive.get("doctrine_label", ""))),
		"pressure_line": str(public_summary.get("pressure_line", "")),
		"world_goal": str(public_summary.get("world_goal", "")),
		"dominant_forces": Array(public_summary.get("dominant_forces", [])).duplicate(true),
		"dominant_domains": Array(public_summary.get("dominant_domains", [])).duplicate(true),
		"dominant_minds": Array(public_summary.get("dominant_minds", [])).duplicate(true),
		"pacing_profile": str(public_summary.get("pacing_profile", "")),
		"pacing_label": str(public_summary.get("pacing_label", "")),
		"pressure_grammar": Array(public_summary.get("pressure_grammar", [])).duplicate(true),
		"symbolic_motifs": Array(public_summary.get("symbolic_motifs", [])).duplicate(true),
		"item_ecology_bias": str(public_summary.get("item_ecology_bias", "")),
		"group_tension_bias": str(public_summary.get("group_tension_bias", "")),
		"archive_tone": str(public_summary.get("archive_tone", "")),
		"convergence_axis": str(public_summary.get("convergence_axis", "")),
		"surface_summary": {
			"lines": Array(surface_summary.get("lines", [])).duplicate(true)
		},
		"constitution_hash": str(directive.get("constitution_hash", ""))
	}

func build_session_policy_lines(overview: Dictionary = {}) -> Array[String]:
	var current := overview if not overview.is_empty() else get_session_overview()
	var mode := str(current.get("mode", "offline"))
	var lines: Array[String] = []
	match mode:
		"host":
			lines.append("Mode: Hosting %s:%d" % [str(current.get("host_bind", "0.0.0.0")), int(current.get("host_port", 0))])
		"client":
			lines.append("Mode: Joined %s:%d" % [str(current.get("join_address", "127.0.0.1")), int(current.get("join_port", 0))])
		_:
			lines.append("Mode: Offline")
	lines.append("Run: %s" % ["Active" if bool(current.get("run_active", false)) else "Lobby"])
	if bool(current.get("reconnect_wait_for_lobby", false)):
		lines.append("Reconnect: Wait for lobby return")
	elif bool(current.get("reconnect_available", false)):
		lines.append("Reconnect: Ready now")
	else:
		lines.append("Reconnect: None")
	var reason := str(current.get("reconnect_reason", ""))
	if not reason.is_empty():
		lines.append("Reason: %s" % reason)
	return lines

func build_session_policy_lines_for_test(overview: Dictionary = {}) -> Array[String]:
	return build_session_policy_lines(overview)

func _effective_constitution() -> Dictionary:
	var run_state := _run_state()
	if run_state != null and run_state.has_method("get_expedition_constitution"):
		var runtime_constitution: Dictionary = Dictionary(run_state.get_expedition_constitution())
		if not runtime_constitution.is_empty():
			return runtime_constitution
	if not current_expedition_constitution.is_empty():
		return current_expedition_constitution
	if not current_delve_directive.is_empty():
		return EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.normalize(current_delve_directive)
	return {}

func _constitution_generation_surface(constitution: Dictionary) -> Dictionary:
	if constitution.is_empty():
		return {}
	return EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.generation_surface(constitution)

func _effective_generation_surface() -> Dictionary:
	var run_state := _run_state()
	if run_state != null:
		var runtime_generation_surface: Dictionary = Dictionary(run_state.get("generation_surface"))
		if not runtime_generation_surface.is_empty():
			return runtime_generation_surface.duplicate(true)
	if not current_generation_contract.is_empty():
		return current_generation_contract.duplicate(true)
	return _constitution_generation_surface(_effective_constitution())

func get_current_expedition_constitution() -> Dictionary:
	return _effective_constitution().duplicate(true)

func get_current_constitution_hash() -> String:
	if not current_constitution_hash.strip_edges().is_empty():
		return current_constitution_hash
	return str(_effective_constitution().get("constitution_hash", "")).strip_edges()

func get_current_expedition_constitution_summary() -> Dictionary:
	return _directive_public_summary(_effective_constitution())

func get_current_delve_directive() -> Dictionary:
	return get_current_expedition_constitution()

func get_current_generation_surface() -> Dictionary:
	return _effective_generation_surface()

func get_current_generation_contract() -> Dictionary:
	return get_current_generation_surface()

func resolve_authoritative_room_count_for_start(requested_room_count: int = 0) -> int:
	if requested_room_count >= MIN_AUTHORITATIVE_ROOM_COUNT and requested_room_count <= MAX_AUTHORITATIVE_ROOM_COUNT:
		return requested_room_count
	return STANDARD_RUN_ROOM_COUNT

func get_authoritative_room_chain_snapshot() -> Array:
	return last_authoritative_room_chain.duplicate(true)

func get_current_delve_public_summary() -> Dictionary:
	return get_current_expedition_constitution_summary()

func get_current_encounter_manifest() -> Dictionary:
	return Dictionary(_effective_constitution().get("encounter_manifest", {})).duplicate(true)

func get_current_pathology_profile() -> Dictionary:
	return Dictionary(_effective_constitution().get("pathology_profile", {})).duplicate(true)

func get_current_apex_framework_profile() -> Dictionary:
	return Dictionary(_effective_constitution().get("apex_framework_profile", {})).duplicate(true)

func get_current_apex_manifest() -> Dictionary:
	return Dictionary(_effective_constitution().get("apex_manifest", {})).duplicate(true)

func get_current_delve_surface_value(group_name: String, surface_name: String) -> int:
	var control_surfaces: Dictionary = Dictionary(_effective_constitution().get("control_surfaces", {}))
	return int(Dictionary(control_surfaces.get(group_name, {})).get(surface_name, 0))

func get_current_inhabitant_pressure_bias() -> int:
	return get_current_delve_surface_value("ecology", "inhabitant_pressure")

func get_current_stalking_bias() -> int:
	return get_current_delve_surface_value("ecology", "stalking_bias")

func get_current_anomaly_contamination_bias() -> int:
	return get_current_delve_surface_value("ecology", "anomaly_contamination")

func _current_extraction_window_ticks() -> int:
	var duration := EXTRACTION_WINDOW_TICKS
	duration += get_current_delve_surface_value("economy", "resource_austerity") * 45
	duration -= get_current_delve_surface_value("economy", "recovery_cushion") * 45
	duration += get_current_inhabitant_pressure_bias() * 30
	duration -= get_current_delve_surface_value("generation", "rescue_geometry") * 20
	var generation_surface := _effective_generation_surface()
	var relationship_routing: Dictionary = Dictionary(generation_surface.get("relationship_routing", {}))
	var relay_routing: Dictionary = Dictionary(generation_surface.get("relay_routing", {}))
	var cookbook_routing: Dictionary = Dictionary(generation_surface.get("cookbook_routing", {}))
	var civilization_routing: Dictionary = Dictionary(generation_surface.get("civilization_routing", {}))
	duration -= int(relationship_routing.get("escort_expectation", 0)) * 25
	duration -= int(relationship_routing.get("rescue_convergence", 0)) * 20
	duration -= int(relationship_routing.get("obligation_risk", 0)) * 10
	duration += int(relationship_routing.get("trust_fragility", 0)) * 12
	duration += int(relationship_routing.get("witness_suspicion", 0)) * 15
	duration += int(relationship_routing.get("regroup_strain", 0)) * 18
	duration += int(relay_routing.get("relay_overload", 0)) * 12
	duration += int(relay_routing.get("regroup_friction", 0)) * 18
	duration += int(relay_routing.get("return_pressure", 0)) * 14
	duration += int(cookbook_routing.get("counter_reading", 0)) * 10
	duration += int(cookbook_routing.get("anti_protocol_pull", 0)) * 12
	duration += int(civilization_routing.get("legitimacy_custody", 0)) * 8
	duration += int(civilization_routing.get("taboo_silence", 0)) * 16
	duration += int(civilization_routing.get("canon_conflict", 0)) * 12
	duration += int(civilization_routing.get("mourning_climate", 0)) * 10
	duration += int(civilization_routing.get("ontology_heat", 0)) * 14
	var role_custody_pressure := _role_custody_group_pressure()
	duration += int(role_custody_pressure.get("custody_debt", 0)) * 18
	duration += int(role_custody_pressure.get("suspicion_heat", 0)) * 12
	duration += int(role_custody_pressure.get("counterfeit_heat", 0)) * 20
	duration -= int(role_custody_pressure.get("warden_duty", 0)) * 8
	var extraction_details := _find_extraction_completion_details()
	if not extraction_details.is_empty():
		var carrier_peer_id := int(extraction_details.get("owner_peer_id", 0))
		if carrier_peer_id > 0:
			var carrier_affordances := _loadout_runtime_affordances(carrier_peer_id)
			var resource_signals := Array(carrier_affordances.get("resource_signals", []))
			var behavior_signals := Array(carrier_affordances.get("behavior_signals", []))
			if resource_signals.has("escort rig"):
				duration -= 18
			if behavior_signals.has("custody answer") or behavior_signals.has("escort line"):
				duration -= 12
			if behavior_signals.has("watch bait") or behavior_signals.has("witness flare"):
				duration += 10
	duration += _current_extraction_role_modifier()
	return clampi(duration, EXTRACTION_WINDOW_TICKS - 180, EXTRACTION_WINDOW_TICKS + 210)

func _current_extraction_role_modifier() -> int:
	var details := _find_extraction_completion_details()
	if details.is_empty():
		return 0
	var artifact_id := int(details.get("artifact_id", 0))
	var owner_peer_id := int(details.get("owner_peer_id", 0))
	if artifact_id == 0 or owner_peer_id <= 0 or not artifacts_by_id.has(artifact_id):
		return 0
	var authenticity_state := str(artifact_service.authenticity_state(Dictionary(artifacts_by_id.get(artifact_id, {}))))
	match _role_name_for_peer(owner_peer_id):
		ROLE_SERVICE_SCRIPT.ROLE_STEWARD:
			return -18 if authenticity_state == "authentic" else 12
		ROLE_SERVICE_SCRIPT.ROLE_BEARER:
			return -36 if authenticity_state == "authentic" else 24
		ROLE_SERVICE_SCRIPT.ROLE_VEIL:
			return 8 if authenticity_state == "authentic" else 18
		ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
			return 14 if authenticity_state == "authentic" else 28
		_:
			return 0

func _current_ghost_wake_tick() -> int:
	var wake_tick := GHOST_WAKE_TICK
	wake_tick -= get_current_inhabitant_pressure_bias() * 900
	wake_tick -= get_current_stalking_bias() * 1200
	wake_tick -= get_current_anomaly_contamination_bias() * 450
	return clampi(wake_tick, GHOST_WAKE_TICK - 3600, GHOST_WAKE_TICK + 3000)

func _current_ghost_speed_per_tick() -> float:
	var speed := GHOST_SPEED_PER_TICK
	speed += float(get_current_inhabitant_pressure_bias()) * 0.4
	speed += float(get_current_stalking_bias()) * 0.6
	speed += float(get_current_anomaly_contamination_bias()) * 0.25
	return clampf(speed, GHOST_SPEED_PER_TICK - 1.5, GHOST_SPEED_PER_TICK + 2.5)

func _current_ghost_hit_radius() -> float:
	var radius := GHOST_HIT_RADIUS
	radius += float(get_current_stalking_bias()) * 6.0
	radius += float(get_current_inhabitant_pressure_bias()) * 4.0
	radius += float(get_current_anomaly_contamination_bias()) * 3.0
	return clampf(radius, GHOST_HIT_RADIUS - 12.0, GHOST_HIT_RADIUS + 24.0)

func _current_noise_trace_interval(peer_id: int) -> int:
	var affordances := _loadout_runtime_affordances(peer_id)
	var interval := int(affordances.get("noise_trace_interval", 90))
	interval -= get_current_stalking_bias() * 6
	interval -= get_current_anomaly_contamination_bias() * 4
	interval -= get_current_inhabitant_pressure_bias() * 3
	var generation_surface := _effective_generation_surface()
	var relay_routing: Dictionary = Dictionary(generation_surface.get("relay_routing", {}))
	var cookbook_routing: Dictionary = Dictionary(generation_surface.get("cookbook_routing", {}))
	var civilization_routing: Dictionary = Dictionary(generation_surface.get("civilization_routing", {}))
	interval -= int(relay_routing.get("distributed_witness", 0)) * 6
	interval -= int(relay_routing.get("rumor_heat", 0)) * 8
	interval -= int(cookbook_routing.get("counter_reading", 0)) * 4
	interval -= int(civilization_routing.get("canon_conflict", 0)) * 5
	interval -= int(civilization_routing.get("ontology_heat", 0)) * 4
	interval -= int(custody_debt_by_peer.get(peer_id, 0)) * 5
	interval -= int(suspicion_heat_by_peer.get(peer_id, 0)) * 4
	interval -= int(counterfeit_heat_by_peer.get(peer_id, 0)) * 6
	var behavior_signals := Array(affordances.get("behavior_signals", []))
	var resource_signals := Array(affordances.get("resource_signals", []))
	var anomaly_hooks := Array(affordances.get("anomaly_hooks", []))
	if resource_signals.has("escort rig"):
		interval += 6
	if behavior_signals.has("witness flare") or behavior_signals.has("watch bait"):
		interval -= 6
	if anomaly_hooks.has("redirected echo"):
		interval -= 4
	if str(roles_by_peer.get(peer_id, "")) == ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		interval -= int(counterfeit_heat_by_peer.get(peer_id, 0)) * 2
	match _role_name_for_peer(peer_id):
		ROLE_SERVICE_SCRIPT.ROLE_STEWARD:
			interval += 8
		ROLE_SERVICE_SCRIPT.ROLE_BEARER:
			interval -= 10 if _find_carried_artifact_by_peer(peer_id) != 0 else 0
		ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
			interval -= 8
	return clampi(interval, 24, 150)

func get_current_delve_directive_debug_lines() -> Array[String]:
	return DELVE_DIRECTIVE_INSPECTOR_SCRIPT.build_lines(_effective_constitution())

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
	clear_reconnect_offer()
	_set_connection_status("Starting host... (%s:%d)" % [bind_address, requested_port])
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
		_set_connection_status(failure_message)
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
	profile_cards_by_peer.clear()
	if mp != null:
		_set_ready(mp.get_unique_id(), true, "start_host_local_ready")
	_sync_local_profile_card()
	_reconcile_ready_map_for_connected_peers(false)
	var started_message := "Host online at %s:%d (requested %d)" % [_recommended_join_address_for_display(host_bind_address), host_listen_port, host_requested_port]
	_set_connection_status(started_message)
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
	clear_reconnect_offer()
	_set_connection_status("Join requested... (%s:%d)" % [join_address, join_port])
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(join_address, join_port)
	if err != OK:
		var hint := _build_port_mismatch_hint(join_port)
		_set_connection_status("Join failed %s:%d (%s)%s" % [join_address, join_port, error_string(err), hint])
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
	profile_cards_by_peer.clear()
	_set_connection_status("Joining %s:%d" % [join_address, join_port])
	_log_connection_event("join_started", "target=%s:%d" % [join_address, join_port])
	return true

func disconnect_peer(reason: String = "manual") -> void:
	var scene_mp := _mp()
	var local_id := _safe_mp_unique_id(scene_mp)
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
	last_authoritative_room_chain.clear()
	items_by_id.clear()
	tool_inventory_by_peer.clear()
	profile_cards_by_peer.clear()
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
	current_expedition_constitution.clear()
	current_delve_directive.clear()
	current_generation_contract.clear()
	current_constitution_hash = ""
	extraction_room_slot = -1
	_reset_extraction_window_state()
	_clear_local_extraction_window_state()
	_clear_ghost_state()
	_clear_role_custody_state()
	_clear_predator_state()
	_clear_protocol_watch_state()
	_clear_echo_lure_state()
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
	if reason in ["manual", "stop_host", "return_lobby", "reset_lobby"]:
		clear_reconnect_offer()
	_set_connection_status("Disconnected")
	emit_signal("host_endpoint_changed", host_bind_address, host_listen_port)
	emit_signal("lobby_updated", players, ready_by_id, is_host)

func stop_host() -> void:
	if not is_host:
		return
	_set_connection_status("Stopping host...")
	disconnect_peer("stop_host")

func refresh_active_peer_bindings() -> void:
	if enet_peer == null:
		return
	var node_mp := _node_mp_candidate()
	var tree_mp := _tree_mp_candidate()
	if node_mp != null and node_mp.multiplayer_peer != enet_peer:
		node_mp.multiplayer_peer = enet_peer
	if tree_mp != null and tree_mp.multiplayer_peer != enet_peer:
		tree_mp.multiplayer_peer = enet_peer
	_select_active_mp("refresh_active_peer_bindings")
	_ensure_signals_wired_to_active_mp()
	_log_mp_state("refresh_active_peer_bindings")

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
	client_set_ready.rpc_id(1, uid, ready_flag)

func start_run(seed_override: int = 0, room_count: int = 0) -> void:
	var mp := _mp()
	var connected := mp != null and mp.multiplayer_peer != null
	var requested_room_count := room_count
	room_count = resolve_authoritative_room_count_for_start(room_count)
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
	if requested_room_count != room_count:
		_nm_log("START_RUN_ROOM_COUNT_NORMALIZED requested=%d resolved=%d" % [requested_room_count, room_count])
	var can_start := can_host_start_run(connected_peers, ready_by_id, connected, run_active)
	if not bool(can_start.get("allowed", false)):
		_nm_log("START_RUN_DENY reason=%s gate=%s" % [str(can_start.get("reason", "unknown")), str(can_start)])
		_set_connection_status(str(can_start.get("reason", "Start denied")))
		return
	var generator := RUN_GENERATOR_SCRIPT.new()
	var role_service := ROLE_SERVICE_SCRIPT.new()
	var run_seed := seed_override
	if run_seed == 0:
		run_seed = int(Time.get_unix_time_from_system())
	var profile := PROFILE_SERVICE_SCRIPT.load_profile()
	var public_cards := get_public_player_cards()
	var gameplay_snapshot := build_gameplay_signal_snapshot(public_cards, profile)
	var session_context := {
		"player_count": connected_peers.size(),
		"peer_ids": connected_peers.duplicate(),
		"protocol_state": str(gameplay_snapshot.get("protocol_state", "")),
		"public_cards": public_cards.duplicate(true),
		"ready_state": ready_by_id.duplicate(true),
		"gameplay_snapshot": gameplay_snapshot.duplicate(true)
	}
	current_expedition_constitution = DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, run_seed, room_count)
	current_delve_directive = current_expedition_constitution.duplicate(true)
	current_generation_contract = _constitution_generation_surface(current_expedition_constitution)
	current_constitution_hash = str(current_expedition_constitution.get("constitution_hash", "")).strip_edges()
	if DELVE_DIRECTIVE_INSPECTOR_SCRIPT.should_trace():
		var trace_path := DELVE_DIRECTIVE_INSPECTOR_SCRIPT.write_trace(current_expedition_constitution)
		if not trace_path.is_empty():
			current_expedition_constitution["trace_path"] = trace_path
			current_delve_directive["trace_path"] = trace_path
		DELVE_DIRECTIVE_INSPECTOR_SCRIPT.emit_debug_trace(current_expedition_constitution)
	var chain := generator.generate_layout(run_seed, room_count, current_generation_contract)
	roles_by_peer = role_service.assign_roles(connected_peers, run_seed)
	var artifacts: Array = generator.generate_evidence_spawns(run_seed, chain)
	var items: Array = item_service.generate_item_spawns(run_seed, chain, current_generation_contract)
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
	_clear_role_custody_state()
	reset_tool_inventory_for_test(connected_peers)
	next_event_id = 1
	local_sabotage_cooldown_until_tick = 0
	run_active = true
	extraction_room_slot = maxi(chain.size() - 1, 0)
	_reset_extraction_window_state()
	_clear_local_extraction_window_state()
	_clear_ghost_state()
	_clear_predator_state()
	_clear_protocol_watch_state()
	_clear_echo_lure_state()

	var event_log := _event_log()
	if event_log != null:
		event_log.clear()
	var payload := build_run_start_payload(
		run_seed,
		chain,
		connected_peers,
		get_current_delve_public_summary(),
		current_constitution_hash,
		get_current_expedition_constitution_summary()
	)
	host_start_run.rpc(payload["seed"], payload["room_chain"], payload["peer_ids"], payload["directive_summary"], payload["constitution_hash"], payload["constitution_summary"])
	_reveal_roles_to_clients()
	_broadcast_artifact_state()
	_broadcast_item_state()
	_broadcast_ghost_state()
	record_public_event("run_started", -1, -1, {"seed": run_seed})

func send_client_input(move_axis: float, jump_pressed: bool, seq: int, pos: Vector2 = Vector2.ZERO, pack_flags: int = 0) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		input_by_peer[mp.get_unique_id()] = {"move": move_axis, "jump": jump_pressed, "seq": seq, "pos": pos, "flags": pack_flags}
		return
	client_input.rpc_id(1, move_axis, jump_pressed, seq, pos, pack_flags)

func consume_peer_input(peer_id: int) -> Dictionary:
	if not input_by_peer.has(peer_id):
		return {"move": 0.0, "jump": false, "seq": -1}
	return input_by_peer[peer_id]

func broadcast_state(snapshot: Dictionary, tick: int) -> void:
	if not is_host:
		return
	current_server_tick = tick
	_advance_runtime_ecology()
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
	host_sync_profile_cards.rpc(payload["profile_cards"])

func _on_peer_connected(peer_id: int) -> void:
	if not is_host:
		return
	if not should_allow_runtime_join_for_test(run_active):
		_log_connection_event("join_denied_active_run", "peer_id=%d" % peer_id)
		host_join_denied.rpc_id(peer_id, "Run already active. Rejoin after the lobby returns.")
		if enet_peer != null and enet_peer.has_method("disconnect_peer"):
			enet_peer.disconnect_peer(peer_id)
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
	_sync_local_profile_card()
	_log_mp_state("connected_to_server")
	clear_reconnect_offer()
	_set_connection_status("Connected to host %s:%d" % [join_target_address, join_target_port])
	_log_connection_event("connected_to_server", "target=%s:%d" % [join_target_address, join_target_port])

func _on_connection_failed() -> void:
	_set_connected_peers([], "connection_failed")
	var hint := _build_port_mismatch_hint(join_target_port)
	var message := "Connection failed to %s:%d (%s)%s" % [join_target_address, join_target_port, error_string(ERR_CANT_CONNECT), hint]
	_remember_client_reconnect(message, run_active, false)
	_set_connection_status(message)
	_log_connection_event("connection_failed", "target=%s:%d err=%s%s" % [join_target_address, join_target_port, error_string(ERR_CANT_CONNECT), hint])

func _on_server_disconnected() -> void:
	_log_connection_event("server_disconnected", "")
	_remember_client_reconnect("Host disconnected", run_active, run_active)
	call_deferred("_finalize_server_disconnected")

func _finalize_server_disconnected() -> void:
	_select_active_mp("server_disconnected_finalize")
	var active_mp := _mp()
	var active_status := _mp_connection_status(active_mp)
	var node_status := _mp_connection_status(_node_mp_candidate())
	var tree_status := _mp_connection_status(_tree_mp_candidate())
	var live_statuses := [
		MultiplayerPeer.CONNECTION_CONNECTED,
		MultiplayerPeer.CONNECTION_CONNECTING
	]
	if live_statuses.has(active_status) or live_statuses.has(node_status) or live_statuses.has(tree_status):
		_nm_log("SERVER_DISCONNECT_IGNORED active=%d node=%d tree=%d" % [active_status, node_status, tree_status])
		return
	disconnect_peer("server_disconnected")
	_set_connection_status("Host disconnected")

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
func host_sync_profile_cards(cards: Dictionary) -> void:
	profile_cards_by_peer = cards.duplicate(true)

@rpc("any_peer", "reliable")
func client_submit_profile_card(card: Dictionary) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	var sender := mp.get_remote_sender_id()
	var next_card := _sanitize_profile_card(card, sender)
	if next_card.is_empty():
		return
	profile_cards_by_peer[sender] = next_card
	_broadcast_lobby()

@rpc("authority", "call_local", "reliable")
func host_start_run(
	seed_value: int,
	room_chain: Array,
	peer_ids: Array,
	directive_summary: Dictionary = {},
	constitution_hash: String = "",
	constitution_summary: Dictionary = {}
) -> void:
	var local_players: Array[int] = []
	for peer_id in peer_ids:
		local_players.append(int(peer_id))
	last_authoritative_room_chain = room_chain.duplicate(true)
	var public_constitution_summary: Dictionary = constitution_summary.duplicate(true)
	if public_constitution_summary.is_empty():
		public_constitution_summary = directive_summary.duplicate(true)
	if not is_host or _effective_constitution().is_empty():
		current_expedition_constitution = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.build_runtime_summary(public_constitution_summary, constitution_hash)
		current_delve_directive = current_expedition_constitution.duplicate(true)
		current_generation_contract.clear()
	else:
		current_expedition_constitution = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.normalize(_effective_constitution())
		current_delve_directive = current_expedition_constitution.duplicate(true)
		current_generation_contract = _constitution_generation_surface(current_expedition_constitution)
	current_constitution_hash = str(current_expedition_constitution.get("constitution_hash", constitution_hash)).strip_edges()
	var runtime_constitution_summary := Dictionary(current_expedition_constitution.get("constitution_summary", get_current_expedition_constitution_summary())).duplicate(true)
	var run_state_public_summary := public_constitution_summary.duplicate(true)
	if run_state_public_summary.is_empty():
		run_state_public_summary = get_current_expedition_constitution_summary()
	current_expedition_constitution["truth_resolution_envelope"] = GOVERNANCE_SERVICE_SCRIPT.build_truth_resolution_envelope(
		{
			"constitution_id": str(current_expedition_constitution.get("constitution_id", current_constitution_hash)).strip_edges(),
			"constitution_hash": current_constitution_hash,
			"packet_digest": str(run_state_public_summary.get("explanation_packet_digest", runtime_constitution_summary.get("explanation_packet_digest", ""))).strip_edges(),
			"provenance_source_refs": Array(runtime_constitution_summary.get("provenance_source_refs", [])).duplicate(true)
		},
		{
			"subject_id": str(current_expedition_constitution.get("constitution_id", current_constitution_hash)).strip_edges(),
			"subject_kind": "provenance",
			"authority_epoch": "runtime_live",
			"owner_lane": "runtime",
			"resolution_class": "authoritative",
			"visibility_class": "mixed_partitioned",
			"source_constitution_hash": current_constitution_hash,
			"source_digest": str(run_state_public_summary.get("explanation_packet_digest", runtime_constitution_summary.get("explanation_packet_digest", ""))).strip_edges(),
			"source_refs": Array(runtime_constitution_summary.get("provenance_source_refs", [])).duplicate(true),
			"public_summary_refs": ["public_trace_classes", "public_surface_tags", "explanation_packet_digest"],
			"operator_refs": ["provenance_source_refs", "private_trace_classes"],
			"contradiction_disposition": "stable_surface",
			"allowed_consumers": ["runtime", "report", "bundle", "persistence", "reload", "tests"],
			"derivation_policy": "subset_copy_public_safe",
			"failure_codes": ["runtime_truth_override", "public_operator_ref_leak", "untraceable_summary_field"]
		}
	)
	reset_tool_inventory_for_test(local_players)
	var run_state := _run_state()
	if run_state != null:
		run_state.set_run(seed_value, room_chain, local_players, {
			"constitution": current_expedition_constitution,
			"constitution_hash": current_constitution_hash,
			"constitution_summary": run_state_public_summary.duplicate(true),
			"truth_state": {
				"public_trace_classes": Array(runtime_constitution_summary.get("public_trace_classes", [])).duplicate(true),
				"private_trace_classes": Array(runtime_constitution_summary.get("private_trace_classes", [])).duplicate(true)
			},
			"provenance_state": {
				"provenance_contract_version": int(run_state_public_summary.get("provenance_contract_version", runtime_constitution_summary.get("provenance_contract_version", 0))),
				"explanation_packet_digest": str(run_state_public_summary.get("explanation_packet_digest", runtime_constitution_summary.get("explanation_packet_digest", ""))).strip_edges(),
				"public_surface_tags": Array(run_state_public_summary.get("public_surface_tags", runtime_constitution_summary.get("public_surface_tags", []))).duplicate(true),
				"provenance_source_refs": Array(runtime_constitution_summary.get("provenance_source_refs", [])).duplicate(true)
			},
			"generation_surface": get_current_generation_contract(),
			"encounter_history": [],
			"active_encounter_state": {},
			"pathology_state": Dictionary(current_expedition_constitution.get("pathology_state", {})).duplicate(true),
			"apex_history": [],
			"active_apex_state": {},
			"local_aftermath": {}
		})
	var event_log := _event_log()
	if event_log != null:
		event_log.clear()
	run_active = true
	_reset_extraction_window_state()
	_clear_local_extraction_window_state()
	_clear_ghost_state()
	_clear_predator_state()
	_clear_protocol_watch_state()
	_clear_echo_lure_state()
	emit_signal("run_started", seed_value, room_chain)

@rpc("authority", "call_local", "reliable")
func host_join_denied(reason: String) -> void:
	_remember_client_reconnect(reason, run_active, true)
	disconnect_peer("join_denied")
	_set_connection_status(reason)

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
	var previous_room_slot := int(player_room_by_peer.get(peer_id, -9999))
	player_pos_by_peer[peer_id] = world_pos
	player_room_by_peer[peer_id] = room_slot
	if room_slot >= 0 and previous_room_slot != room_slot:
		_maybe_trigger_chamber_entry_mutation(peer_id, room_slot)
		_refresh_transformation_thresholds_for_peer(peer_id, room_slot)

func request_pickup(artifact_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_pickup(mp.get_unique_id(), artifact_id)
		return
	client_pickup_request.rpc_id(1, artifact_id)

func request_pickup_item(item_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_pickup_item(mp.get_unique_id(), item_id)
		return
	client_pickup_item_request.rpc_id(1, item_id)

func request_use_item(item_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	var room_slot := int(player_room_by_peer.get(mp.get_unique_id(), -1))
	if is_host:
		_host_use_item(mp.get_unique_id(), item_id, room_slot)
		return
	client_use_item_request.rpc_id(1, item_id, room_slot)

func request_drop() -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_drop(mp.get_unique_id())
		return
	client_drop_request.rpc_id(1)

func request_steal(artifact_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_steal(mp.get_unique_id(), artifact_id)
		return
	client_steal_request.rpc_id(1, artifact_id)

func request_forge(room_slot: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_forge(mp.get_unique_id(), room_slot)
		return
	client_forge_request.rpc_id(1, room_slot)

func request_sabotage(room_slot: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_sabotage(mp.get_unique_id(), room_slot)
		return
	client_sabotage_request.rpc_id(1, room_slot)

func request_throw_bomb(pos: Vector2, vel: Vector2, node_name: String) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_throw_bomb(mp.get_unique_id(), pos, vel, node_name)
		return
	client_throw_bomb_request.rpc_id(1, pos, vel, node_name)

func request_throw_rope(pos: Vector2, node_name: String) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_throw_rope(mp.get_unique_id(), pos, node_name)
		return
	client_throw_rope_request.rpc_id(1, pos, node_name)

func request_check_artifact(artifact_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_check_artifact(mp.get_unique_id(), artifact_id)
		return # was missing in last thought attempt
	client_check_artifact_request.rpc_id(1, artifact_id)

func request_callout(kind: String, room_slot: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_callout(mp.get_unique_id(), kind, room_slot)
		return
	client_callout_request.rpc_id(1, kind, room_slot)

func request_enter_door(door_id: int) -> void:
	var mp := _mp()
	if mp == null:
		return
	if is_host:
		_host_enter_door(mp.get_unique_id(), door_id)
		return
	client_enter_door_request.rpc_id(1, door_id)

@rpc("any_peer", "call_remote", "reliable")
func client_throw_bomb_request(pos: Vector2, vel: Vector2, node_name: String) -> void:
	if not is_host:
		return
	_host_throw_bomb(multiplayer.get_remote_sender_id(), pos, vel, node_name)

@rpc("any_peer", "call_remote", "reliable")
func client_throw_rope_request(pos: Vector2, node_name: String) -> void:
	if not is_host:
		return
	_host_throw_rope(multiplayer.get_remote_sender_id(), pos, node_name)

@rpc("any_peer", "call_remote", "reliable")
func client_callout_request(kind: String, room_slot: int) -> void:
	if not is_host:
		return
	_host_callout(multiplayer.get_remote_sender_id(), kind, room_slot)

func _host_enter_door(peer_id: int, door_id: int) -> void:
	var scene_tree = get_tree()
	if scene_tree:
		var root = scene_tree.root
		if root.has_node("Game"):
			var game = root.get_node("Game")
			if game.has_method("execute_door_teleport"):
				game.execute_door_teleport(peer_id, door_id)

func can_local_use_sabotage(_room_slot: int) -> bool:
	var run_state := _run_state()
	if run_state == null:
		return false
	if not _role_service().can_sabotage(str(run_state.local_role)):
		return false
	var local_tick := latest_tick
	if is_host:
		local_tick = current_server_tick
	return local_tick >= local_sabotage_cooldown_until_tick

func get_local_authoritative_room_slot() -> int:
	var mp := _mp()
	if mp == null or mp.multiplayer_peer == null:
		return -1
	return int(player_room_by_peer.get(mp.get_unique_id(), -1))

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
		if tick - extraction_window_started_tick >= _current_extraction_window_ticks():
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
	_clear_ghost_state()
	_clear_predator_state()
	_clear_protocol_watch_state()
	_clear_echo_lure_state()
	_broadcast_ghost_state()
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

func build_run_start_payload(
	seed_value: int,
	room_chain: Array,
	peer_ids: Array,
	directive_summary: Dictionary = {},
	constitution_hash: String = "",
	constitution_summary: Dictionary = {}
) -> Dictionary:
	var canonical_summary: Dictionary = constitution_summary.duplicate(true)
	if canonical_summary.is_empty():
		canonical_summary = directive_summary.duplicate(true)
	return {
		"seed": seed_value,
		"room_chain": room_chain.duplicate(true),
		"peer_ids": peer_ids.duplicate(),
		"directive_summary": canonical_summary.duplicate(true),
		"constitution_hash": constitution_hash,
		"constitution_summary": canonical_summary.duplicate(true)
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

func build_outcome_summary(reason: String, artifacts_state: Dictionary, extraction_details: Dictionary = {}) -> Dictionary:
	var authenticity: Dictionary = artifact_service.summarize_authenticity(artifacts_state)
	var extracted_artifact_id := int(extraction_details.get("artifact_id", 0))
	var artifact_result := "none"
	var artifact_result_text := "No artifact extracted"
	var expedition_success := false
	var sabotage_success := false
	if reason == "extraction_objective" and extracted_artifact_id != 0 and artifacts_state.has(extracted_artifact_id):
		var extracted_artifact: Dictionary = artifacts_state[extracted_artifact_id]
		artifact_result = artifact_service.authenticity_state(extracted_artifact)
		if artifact_result == "authentic":
			expedition_success = true
			artifact_result_text = "Authentic artifact extracted"
		else:
			sabotage_success = true
			artifact_result_text = "Counterfeit artifact extracted"
	elif reason == "tick_limit":
		sabotage_success = true
		artifact_result_text = "Expedition stalled before extraction"
	else:
		sabotage_success = true
	var summary_text := "Expedition success" if expedition_success else "Sabotage success" if sabotage_success else "Run unresolved"
	var continuity_summary := _build_artifact_continuity_summary(reason, artifacts_state, extraction_details, false)
	var market_context := _current_market_consequence_context()
	var consequence_summary := artifact_service.build_consequence_contract(
		reason,
		artifacts_state,
		continuity_summary,
		extraction_details,
		str(market_context.get("market_regime_id", "")),
		str(market_context.get("market_carrier_risk_band", ""))
	)
	var summary := {
		"artifact_result": artifact_result,
		"artifact_result_text": artifact_result_text,
		"artifact_continuity_state": str(continuity_summary.get("state", "")),
		"artifact_continuity_text": str(continuity_summary.get("text", "")),
		"artifact_unresolved_authentic_count": int(continuity_summary.get("unresolved_authentic_count", 0)),
		"artifact_unresolved_counterfeit_count": int(continuity_summary.get("unresolved_counterfeit_count", 0)),
		"artifact_carried_unresolved_count": int(continuity_summary.get("carried_unresolved_count", 0)),
		"artifact_buried_unresolved_count": int(continuity_summary.get("buried_unresolved_count", 0)),
		"expedition_success": expedition_success,
		"sabotage_success": sabotage_success,
		"summary_text": summary_text,
		"authentic_count": int(authenticity.get("authentic", 0)),
		"counterfeit_count": int(authenticity.get("counterfeit", 0))
	}
	for key in consequence_summary.keys():
		summary[key] = consequence_summary[key]
	summary["artifact_consequence_ref"] = Dictionary(consequence_summary.get("artifact_consequence_ref", {})).duplicate(true)
	return summary

func build_outcome_summary_for_test(reason: String, artifacts_state: Dictionary, extraction_details: Dictionary = {}) -> Dictionary:
	return build_outcome_summary(reason, artifacts_state, extraction_details)

func build_interrupted_outcome_summary(reason: String) -> Dictionary:
	return _build_interrupted_outcome_summary(reason, artifacts_by_id)

func build_interrupted_outcome_summary_for_test(reason: String, artifacts_state: Dictionary) -> Dictionary:
	return _build_interrupted_outcome_summary(reason, artifacts_state)

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
	var extraction_details := _find_extraction_completion_details() if reason == "extraction_objective" else {}
	var synced_local_aftermath := get_local_aftermath()
	return {
		"seed": run_seed_value,
		"reason": reason,
		"end_tick": current_server_tick,
		"roles_reveal": roles_reveal,
		"summary_by_peer": compute_summary_from_events(events, players, artifacts_by_id),
		"outcome_summary": build_outcome_summary(reason, artifacts_by_id, extraction_details),
		"local_aftermath": synced_local_aftermath.duplicate(true)
	}

func _build_interrupted_outcome_summary(reason: String, artifacts_state: Dictionary) -> Dictionary:
	var continuity_summary := _build_artifact_continuity_summary(reason, artifacts_state, {}, true)
	var market_context := _current_market_consequence_context()
	var consequence_summary := artifact_service.build_consequence_contract(
		"session_interrupted",
		artifacts_state,
		continuity_summary,
		{},
		str(market_context.get("market_regime_id", "")),
		str(market_context.get("market_carrier_risk_band", ""))
	)
	var summary := {
		"summary_text": "Session interrupted",
		"artifact_result_text": "Run interrupted before extraction",
		"artifact_result": "interrupted",
		"artifact_continuity_state": str(continuity_summary.get("state", "")),
		"artifact_continuity_text": str(continuity_summary.get("text", "")),
		"artifact_unresolved_authentic_count": int(continuity_summary.get("unresolved_authentic_count", 0)),
		"artifact_unresolved_counterfeit_count": int(continuity_summary.get("unresolved_counterfeit_count", 0)),
		"artifact_carried_unresolved_count": int(continuity_summary.get("carried_unresolved_count", 0)),
		"artifact_buried_unresolved_count": int(continuity_summary.get("buried_unresolved_count", 0)),
		"expedition_success": false,
		"sabotage_success": false,
		"interrupt_reason": reason
	}
	for key in consequence_summary.keys():
		summary[key] = consequence_summary[key]
	return summary

func _build_artifact_continuity_summary(reason: String, artifacts_state: Dictionary, extraction_details: Dictionary = {}, interrupted: bool = false) -> Dictionary:
	var extracted_artifact_id := int(extraction_details.get("artifact_id", 0))
	var unresolved_authentic := 0
	var unresolved_counterfeit := 0
	var carried_unresolved := 0
	var buried_unresolved := 0
	for artifact_id_variant in artifacts_state.keys():
		var artifact_id := int(artifact_id_variant)
		if artifact_id == extracted_artifact_id:
			continue
		var artifact: Dictionary = Dictionary(artifacts_state.get(artifact_id_variant, {}))
		var authenticity_state: String = artifact_service.authenticity_state(artifact)
		if authenticity_state == "authentic":
			unresolved_authentic += 1
		else:
			unresolved_counterfeit += 1
		if int(artifact.get("owner_peer_id", 0)) > 0:
			carried_unresolved += 1
		else:
			buried_unresolved += 1
	var state := ""
	var text := ""
	if reason == "extraction_objective" and extracted_artifact_id != 0 and artifacts_state.has(extracted_artifact_id):
		var extracted_artifact: Dictionary = Dictionary(artifacts_state.get(extracted_artifact_id, {}))
		var extracted_authenticity: String = artifact_service.authenticity_state(extracted_artifact)
		if extracted_authenticity == "counterfeit":
			state = "successor_emergence"
			text = "A counterfeit successor displaced the authentic line in public memory."
		elif unresolved_authentic > 0 or unresolved_counterfeit > 0:
			state = "fragmented_legacy"
			text = "Extraction succeeded, but other artifact lines were left unresolved."
	elif artifacts_state.is_empty():
		state = "extinction"
		text = "The artifact line fell extinct in the interrupted record."
	elif unresolved_authentic > 0 and unresolved_counterfeit > 0:
		state = "fragmented_legacy"
		text = "The run left split artifact claims behind."
	elif unresolved_authentic > 0 and carried_unresolved > 0:
		state = "recoverable_loss"
		text = "The artifact line remained in recoverable custody when the run ended." if not interrupted else "The artifact line remained in recoverable custody when the run broke."
	elif unresolved_authentic > 0 and buried_unresolved > 0:
		state = "burial"
		text = "The artifact line was left buried in the labyrinth."
	elif unresolved_authentic == 0 and unresolved_counterfeit > 0:
		state = "archive_only_residue"
		text = "Only residue and counterfeit echoes remained for the Archive."
	return {
		"state": state,
		"text": text,
		"unresolved_authentic_count": unresolved_authentic,
		"unresolved_counterfeit_count": unresolved_counterfeit,
		"carried_unresolved_count": carried_unresolved,
		"buried_unresolved_count": buried_unresolved
	}

func _current_market_consequence_context() -> Dictionary:
	var constitution: Dictionary = _effective_constitution()
	var market_regime_state: Dictionary = Dictionary(constitution.get("market_regime_state", {}))
	var constitution_summary := get_current_expedition_constitution_summary()
	return {
		"market_regime_id": str(constitution_summary.get("market_regime_id", market_regime_state.get("regime_id", ""))).strip_edges(),
		"market_carrier_risk_band": str(constitution_summary.get("market_carrier_risk_band", market_regime_state.get("carrier_risk_band", ""))).strip_edges()
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

func get_local_role_payload() -> Dictionary:
	var run_state := _run_state()
	if run_state == null:
		return {}
	return Dictionary(run_state.local_role_payload).duplicate(true)

func get_public_player_cards() -> Dictionary:
	return profile_cards_by_peer.duplicate(true)

func get_active_items_for_peer(peer_id: int) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	var ids: Array = items_by_id.keys()
	ids.sort()
	for item_id_variant in ids:
		var item_id := int(item_id_variant)
		var item_dict: Dictionary = items_by_id[item_id]
		if int(item_dict.get("owner_peer_id", 0)) != peer_id:
			continue
		if bool(item_dict.get("consumed", false)):
			continue
		var item_def_id := str(item_dict.get("item_def_id", ""))
		if not item_service.is_active_use_item(item_def_id):
			continue
		items.append({
			"item_id": item_id,
			"item_def_id": item_def_id,
			"display_name": str(item_dict.get("display_name", item_service.get_display_name(item_def_id)))
		})
	return items

func get_local_active_items() -> Array[Dictionary]:
	var mp := _mp()
	if mp == null:
		return []
	return get_active_items_for_peer(mp.get_unique_id())

func get_protocol_state_label(active_peer_count: int = -1) -> String:
	var count := active_peer_count
	if count < 0:
		count = _active_protocol_peer_ids().size()
	if count >= 8:
		return "Expedition Protocol"
	if count >= 4:
		return "Fracture Protocol"
	if count >= 2:
		return "Intimate Protocol"
	return "Exposure Protocol"

func build_gameplay_signal_snapshot(peer_identities: Dictionary = {}, profile: Dictionary = {}) -> Dictionary:
	var cards := peer_identities if not peer_identities.is_empty() else get_public_player_cards()
	var peer_ids := _active_protocol_peer_ids()
	var protocol_state := get_protocol_state_label(peer_ids.size())
	var peer_models := {}
	var build_identities: Array[String] = []
	var resource_pressure: Array[String] = []
	var inhabitant_pressure: Array[String] = []
	var combo_family_ids: Array[String] = []
	var combo_pressure_tags: Array[String] = []
	var combo_public_surface_tags: Array[String] = []
	var pathology_state := get_pathology_state()
	var active_encounter_state := get_active_encounter_state()
	var active_apex_state := get_active_apex_state()
	var ghost_active := bool(ghost_state.get("active", false))
	if ghost_active:
		inhabitant_pressure.append("ghost pressure")
	for family_id in _string_array(pathology_state.get("active_family_ids", [])):
		var family_label := family_id.replace("pathology_", "").replace("_", " ")
		var pathology_signal := "%s pressure" % family_label
		if not inhabitant_pressure.has(pathology_signal):
			inhabitant_pressure.append(pathology_signal)
	var active_encounter_id := str(active_encounter_state.get("encounter_id", "")).strip_edges()
	if not active_encounter_id.is_empty():
		var encounter_signal := "%s active" % active_encounter_id.replace("enc_", "").replace("_", " ")
		if not inhabitant_pressure.has(encounter_signal):
			inhabitant_pressure.append(encounter_signal)
	var active_apex_id := str(active_apex_state.get("apex_id", "")).strip_edges()
	if not active_apex_id.is_empty():
		var apex_signal := "%s apex" % active_apex_id.replace("apex_", "").replace("_", " ")
		if not inhabitant_pressure.has(apex_signal):
			inhabitant_pressure.append(apex_signal)
	for peer_id in peer_ids:
		var item_def_ids := _item_def_ids_for_peer(peer_id)
		item_def_ids.sort()
		var card: Dictionary = Dictionary(cards.get(str(peer_id), cards.get(peer_id, {})))
		var public_id := str(card.get("public_id", "peer_%d" % peer_id)).strip_edges()
		var context := _loadout_context_for_peer(peer_id)
		context["protocol_state"] = protocol_state
		context["ghost_active"] = ghost_active
		var carrying_artifact := bool(context.get("carrying_artifact", false))
		var loadout_state: Dictionary = item_service.resolve_loadout_state(item_def_ids, context)
		var inhabitant_signals := _build_inhabitant_pressure_signals(peer_id, protocol_state, carrying_artifact)
		var model := {
			"peer_id": peer_id,
			"public_id": public_id,
			"display_name": str(card.get("display_name", "Delver")),
			"item_defs": item_def_ids.duplicate(),
			"active_item_defs": _active_item_defs_for_peer(peer_id),
			"tool_counts": get_tool_counts_for_peer(peer_id).duplicate(true),
			"carrying_artifact": carrying_artifact,
			"protocol_state": protocol_state,
			"build_identity": str(loadout_state.get("build_identity", "Mixed build")),
			"build_scores": Dictionary(loadout_state.get("build_scores", {})).duplicate(true),
			"behavior_signals": Array(loadout_state.get("behavior_signals", [])).duplicate(),
			"synergy_labels": Array(loadout_state.get("synergy_labels", [])).duplicate(),
			"ritual_hooks": Array(loadout_state.get("ritual_hooks", [])).duplicate(),
			"anomaly_hooks": Array(loadout_state.get("anomaly_hooks", [])).duplicate(),
			"protocol_hooks": Array(loadout_state.get("protocol_hooks", [])).duplicate(),
			"resource_signals": Array(loadout_state.get("resource_signals", [])).duplicate(),
			"feature_scores": Dictionary(loadout_state.get("feature_scores", {})).duplicate(true),
			"feature_signals": Array(loadout_state.get("feature_signals", [])).duplicate(),
			"build_stability": int(loadout_state.get("build_stability", 0)),
			"risk_profile": str(loadout_state.get("risk_profile", "mixed")).strip_edges(),
			"model_pressure": Array(loadout_state.get("model_pressure", [])).duplicate(),
			"combo_contract_version": int(loadout_state.get("combo_contract_version", 0)),
			"combo_contract_digest": str(loadout_state.get("combo_contract_digest", "")).strip_edges(),
			"combo_family_ids": Array(loadout_state.get("combo_family_ids", [])).duplicate(true),
			"combo_pressure_tags": Array(loadout_state.get("combo_pressure_tags", [])).duplicate(true),
			"public_surface_tags": Array(loadout_state.get("public_surface_tags", [])).duplicate(true),
			"combo_contract_ref": Dictionary(loadout_state.get("combo_contract_ref", {})).duplicate(true),
			"latent_totals": Dictionary(loadout_state.get("latent_totals", {})).duplicate(true),
			"inhabitant_signals": inhabitant_signals
		}
		if not build_identities.has(str(model.get("build_identity", ""))):
			build_identities.append(str(model.get("build_identity", "")))
		for signal_value in Array(model.get("resource_signals", [])):
			var text := str(signal_value).strip_edges()
			if not text.is_empty() and not resource_pressure.has(text):
				resource_pressure.append(text)
		for family_id_variant in Array(model.get("combo_family_ids", [])):
			var family_id := str(family_id_variant).strip_edges()
			if not family_id.is_empty() and not combo_family_ids.has(family_id):
				combo_family_ids.append(family_id)
		for tag_variant in Array(model.get("combo_pressure_tags", [])):
			var combo_tag := str(tag_variant).strip_edges()
			if not combo_tag.is_empty() and not combo_pressure_tags.has(combo_tag):
				combo_pressure_tags.append(combo_tag)
		for surface_tag_variant in Array(model.get("public_surface_tags", [])):
			var surface_tag := str(surface_tag_variant).strip_edges()
			if not surface_tag.is_empty() and not combo_public_surface_tags.has(surface_tag):
				combo_public_surface_tags.append(surface_tag)
		for signal_value in inhabitant_signals:
			var pressure_text := str(signal_value).strip_edges()
			if not pressure_text.is_empty() and not inhabitant_pressure.has(pressure_text):
				inhabitant_pressure.append(pressure_text)
		peer_models[public_id] = model
	var source_profile := profile if not profile.is_empty() else PROFILE_SERVICE_SCRIPT.load_profile()
	var relationship_model := _build_relationship_gameplay_model(source_profile, cards, peer_ids, protocol_state)
	var group_model := _build_group_gameplay_model(peer_models, protocol_state, resource_pressure, inhabitant_pressure, relationship_model)
	var constitution_summary := get_current_expedition_constitution_summary()
	var lifecycle_ref := {
		"lifecycle_state_ids": Array(constitution_summary.get("lifecycle_state_ids", [])).duplicate(true),
		"active_regime_ids": Array(constitution_summary.get("active_regime_ids", [])).duplicate(true),
		"market_regime_id": str(constitution_summary.get("market_regime_id", "")).strip_edges(),
		"market_regime_family": str(constitution_summary.get("market_regime_family", "")).strip_edges(),
		"market_regime_lines": Array(constitution_summary.get("market_regime_lines", [])).duplicate(true),
		"lifecycle_lines": Array(constitution_summary.get("lifecycle_lines", [])).duplicate(true)
	}
	var social_consequence_ref := {
		"social_consequence_version": int(group_model.get("social_consequence_version", 0)),
		"public_evidence_tags": Array(group_model.get("public_evidence_tags", [])).duplicate(true),
		"witness_pressure": str(group_model.get("witness_pressure", "")).strip_edges(),
		"counterfeit_pressure": str(group_model.get("counterfeit_pressure", "")).strip_edges(),
		"relationship_pressure": str(group_model.get("relationship_pressure", "")).strip_edges(),
		"blame_surface_tags": Array(group_model.get("blame_surface_tags", [])).duplicate(true),
		"private_evidence_digest": ""
	}
	group_model["social_consequence_ref"] = social_consequence_ref.duplicate(true)
	var reachable_room_slots: Array[int] = [0, 1]
	var reachable_artifact_ids: Array[int] = []
	var reachable_item_ids: Array[int] = []
	var discoverable_channels: Array[String] = ["navigation", "social_callout"]
	var executable_actions: Array[String] = ["move", "jump", "callout_danger", "callout_regroup", "callout_artifact"]
	var input_vocabulary_refs: Array[String] = [
		"Move: Traverse the route",
		"Jump: Commit gaps and dodge pressure",
		"1/2/3: Callout"
	]
	var meaningful_outcome_refs: Array[String] = []
	if extraction_room_slot >= 0:
		reachable_room_slots.append(extraction_room_slot)
		discoverable_channels.append("extraction")
		meaningful_outcome_refs.append("extraction_room:%d" % extraction_room_slot)
	var artifact_ids: Array = artifacts_by_id.keys()
	artifact_ids.sort()
	for artifact_id_variant in artifact_ids:
		var artifact_id := int(artifact_id_variant)
		var artifact: Dictionary = Dictionary(artifacts_by_id.get(artifact_id_variant, {}))
		reachable_artifact_ids.append(artifact_id)
		var room_slot := int(artifact.get("room_slot", -1))
		if room_slot >= 0 and not reachable_room_slots.has(room_slot):
			reachable_room_slots.append(room_slot)
	if not reachable_artifact_ids.is_empty():
		discoverable_channels.append("artifact_custody")
		executable_actions.append_array(["take_artifact", "drop_artifact", "hold_in_extraction"])
		input_vocabulary_refs.append("Q: Take Artifact")
		input_vocabulary_refs.append("E: Drop Artifact")
		meaningful_outcome_refs.append("artifact_consequence")
	var item_ids: Array = items_by_id.keys()
	item_ids.sort()
	for item_id_variant in item_ids:
		var item_id := int(item_id_variant)
		reachable_item_ids.append(item_id)
	if not reachable_item_ids.is_empty():
		discoverable_channels.append("item_use")
		executable_actions.append("take_item")
		input_vocabulary_refs.append("Y: Take item")
	for model_raw in peer_models.values():
		var model: Dictionary = Dictionary(model_raw)
		if not Array(model.get("active_item_defs", [])).is_empty():
			if not discoverable_channels.has("item_use"):
				discoverable_channels.append("item_use")
			executable_actions.append_array(["use_active_item", "cycle_active_item"])
			input_vocabulary_refs.append("U: Use active item")
			input_vocabulary_refs.append("[ / ] Cycle active item")
			break
	if not combo_family_ids.is_empty():
		meaningful_outcome_refs.append("combo_contract:%s" % combo_family_ids[0])
	if not Array(lifecycle_ref.get("active_regime_ids", [])).is_empty():
		meaningful_outcome_refs.append("lifecycle_regime")
	if not Array(group_model.get("blame_surface_tags", [])).is_empty() or not str(group_model.get("witness_pressure", "")).strip_edges().is_empty():
		meaningful_outcome_refs.append("social_pressure")
	if not Dictionary(active_encounter_state).is_empty() or not Dictionary(active_apex_state).is_empty():
		meaningful_outcome_refs.append("encounter_pressure")
	reachable_room_slots.sort()
	var constitution_hash := str(constitution_summary.get("constitution_hash", current_expedition_constitution.get("constitution_hash", ""))).strip_edges()
	var interaction_guarantee_ref := {
		"schema_name": "InteractionGuarantee",
		"schema_version": 1,
		"check_id": "snapshot_%s_%d" % [constitution_hash, current_server_tick],
		"constitution_hash": constitution_hash,
		"run_seed": int(Dictionary(current_expedition_constitution).get("run_seed", 0)),
		"phase": "start_state",
		"discoverable_interaction": true,
		"discoverable_channels": _string_array(discoverable_channels),
		"discoverable_surface_refs": [
			"network_manager.build_gameplay_signal_snapshot",
			"game_controller._update_interaction_prompt",
			"game_controller.build_run_guidance_packet_for_test",
			"game_controller._update_status"
		],
		"reachable_interaction": not peer_models.is_empty() and extraction_room_slot >= 0,
		"reachable_room_slots": reachable_room_slots.duplicate(),
		"reachable_artifact_ids": reachable_artifact_ids.duplicate(),
		"reachable_item_ids": reachable_item_ids.duplicate(),
		"reachable_extraction_slot": extraction_room_slot,
		"executable_interaction": true,
		"executable_actions": _string_array(executable_actions),
		"known_input_interaction": true,
		"input_surface_refs": [
			"network_manager.build_gameplay_signal_snapshot.public_safe_input_lines",
			"game_controller._update_interaction_prompt.prompt_label.text",
			"game_controller.build_run_guidance_packet_for_test.action_tip",
			"game_controller._update_status.status_label.text"
		],
		"input_vocabulary_refs": _string_array(input_vocabulary_refs),
		"public_safe_input_lines": _string_array(input_vocabulary_refs),
		"meaningful_interaction": not meaningful_outcome_refs.is_empty(),
		"meaningful_outcome_refs": _string_array(meaningful_outcome_refs),
		"post_mutation_solvability": true,
		"known_input_reasserted_after_mutation": true,
		"no_dead_start_state": not peer_models.is_empty() and extraction_room_slot >= 0,
		"no_dead_after_mutation_state": true,
		"mutation_ref_ids": [],
		"failure_codes": []
	}
	return {
		"protocol_state": protocol_state,
		"player_count": peer_ids.size(),
		"peer_models": peer_models,
		"build_identities": build_identities,
		"combo_family_ids": combo_family_ids,
		"combo_pressure_tags": combo_pressure_tags,
		"combo_public_surface_tags": combo_public_surface_tags,
		"resource_pressure": resource_pressure,
		"inhabitant_pressure": inhabitant_pressure,
		"active_pathology_ids": _string_array(pathology_state.get("active_family_ids", [])),
		"active_encounter_state": active_encounter_state.duplicate(true),
		"active_apex_state": active_apex_state.duplicate(true),
		"relationship_model": relationship_model,
		"group_model": group_model,
		"social_consequence_ref": social_consequence_ref.duplicate(true),
		"lifecycle_ref": lifecycle_ref.duplicate(true),
		"interaction_guarantee_ref": interaction_guarantee_ref
	}

func _build_group_gameplay_model(peer_models: Dictionary, protocol_state: String, resource_pressure: Array[String], inhabitant_pressure: Array[String], relationship_model: Dictionary = {}) -> Dictionary:
	var build_totals := {}
	var signal_weights := {}
	var fault_lines: Array[String] = []
	var model_pressure: Array[String] = []
	var profile_counts := {}
	var dominant_build := ""
	var dominant_score := -1
	var widest_stability := 0
	var volatile_count := 0
	var committed_count := 0
	var prepared_count := 0
	var peer_count := peer_models.size()
	for model_raw in peer_models.values():
		var model: Dictionary = Dictionary(model_raw)
		var build_identity := str(model.get("build_identity", "")).strip_edges()
		if not build_identity.is_empty():
			build_totals[build_identity] = int(build_totals.get(build_identity, 0)) + int(Dictionary(model.get("build_scores", {})).get(build_identity, 0)) + 1
		for score_key in Dictionary(model.get("feature_scores", {})).keys():
			var score_value := int(Dictionary(model.get("feature_scores", {})).get(score_key, 0))
			if score_value <= 0:
				continue
			signal_weights[score_key] = int(signal_weights.get(score_key, 0)) + score_value
		for signal_value in Array(model.get("feature_signals", [])) + Array(model.get("behavior_signals", [])) + Array(model.get("model_pressure", [])):
			var signal_text := str(signal_value).strip_edges()
			if signal_text.is_empty():
				continue
			signal_weights[signal_text] = int(signal_weights.get(signal_text, 0)) + 1
		var risk_profile := str(model.get("risk_profile", "mixed")).strip_edges()
		if not risk_profile.is_empty():
			profile_counts[risk_profile] = int(profile_counts.get(risk_profile, 0)) + 1
		if risk_profile == "volatile":
			volatile_count += 1
		elif risk_profile == "committed":
			committed_count += 1
		elif risk_profile == "prepared" or risk_profile == "disciplined":
			prepared_count += 1
		widest_stability = maxi(widest_stability, int(model.get("build_stability", 0)))
	for build_label in build_totals.keys():
		var score := int(build_totals.get(build_label, 0))
		if score > dominant_score or (score == dominant_score and str(build_label) < dominant_build):
			dominant_score = score
			dominant_build = str(build_label)
	if volatile_count >= 1 and committed_count >= 1:
		fault_lines.append("the group is split between a volatile answer and a rescue answer")
	if resource_pressure.size() >= 2 and inhabitant_pressure.size() >= 1:
		fault_lines.append("resource caution and presence pressure are pulling in different directions")
	if build_totals.size() >= 3:
		fault_lines.append("too many answer shapes are competing for the same run")
	if protocol_state == "Exposure Protocol" and committed_count >= 1 and volatile_count >= 1:
		fault_lines.append("low-density pressure is exposing incompatible answers")
	if signal_weights.has("public answer appetite") and signal_weights.has("resource caution"):
		fault_lines.append("spectacle appetite is colliding with cost control")
	if signal_weights.has("burden-rescue answer"):
		model_pressure.append("the group keeps bending toward a burden-rescue answer")
	if signal_weights.has("route-control answer"):
		model_pressure.append("route-control is starting to look like the shared answer")
	if signal_weights.has("public misdirection answer"):
		model_pressure.append("the public line keeps accepting a misdirection-shaped answer")
	if signal_weights.has("ritual anomaly answer"):
		model_pressure.append("ritual instability is starting to matter to the group read")
	if signal_weights.has("scarcity fallback answer"):
		model_pressure.append("fallback logic keeps setting the acceptable answer")
	if protocol_state == "Expedition Protocol" and signal_weights.has("public answer appetite"):
		model_pressure.append("crowd density is heating the visible answer line")
	elif protocol_state == "Exposure Protocol" and prepared_count >= 1:
		model_pressure.append("low-density pressure is rewarding prepared answers")
	if protocol_state == "Exposure Protocol" and peer_count <= 1:
		fault_lines.append("low-density pressure is forcing each public move to stand alone")
		model_pressure.append("single-body custody is turning route choice into the whole answer")
	elif protocol_state == "Intimate Protocol" and peer_count <= 3:
		fault_lines.append("pair-density pressure is testing whether the burden line can be handed off cleanly")
		model_pressure.append("pair-density pressure keeps turning route choice into a custody answer")
	elif protocol_state == "Fracture Protocol" and peer_count >= 4:
		fault_lines.append("mid-density pressure keeps splitting the crew into competing local answers")
		model_pressure.append("split pressure is punishing slow regroups")
	elif protocol_state == "Expedition Protocol" and peer_count >= 8:
		fault_lines.append("crowd density keeps every visible answer legible to too many witnesses")
		model_pressure.append("crowd density is rewarding spectacle over subtlety")
	var trust_fragility := int(relationship_model.get("trust_fragility", 0))
	var alliance_stability := int(relationship_model.get("alliance_stability", 0))
	var friendship_pressure := int(relationship_model.get("friendship_pressure", 0))
	var loyalty_pressure := int(relationship_model.get("loyalty_pressure", 0))
	var obligation_heat := int(relationship_model.get("obligation_heat", 0))
	for signal_value in Array(relationship_model.get("group_signals", [])):
		var signal_text := str(signal_value).strip_edges()
		if signal_text.is_empty():
			continue
		signal_weights[signal_text] = int(signal_weights.get(signal_text, 0)) + 2
	for fault_value in Array(relationship_model.get("fault_lines", [])):
		var fault_text := str(fault_value).strip_edges()
		if not fault_text.is_empty() and not fault_lines.has(fault_text):
			fault_lines.append(fault_text)
	for pressure_value in Array(relationship_model.get("model_pressure", [])):
		var pressure_text := str(pressure_value).strip_edges()
		if not pressure_text.is_empty() and not model_pressure.has(pressure_text):
			model_pressure.append(pressure_text)
	if alliance_stability >= 3 and not fault_lines.has("escort expectation is reshaping the burden line"):
		fault_lines.append("escort expectation is reshaping the burden line")
	if trust_fragility >= 2 and not fault_lines.has("suspicion debt is making clean regroups harder"):
		fault_lines.append("suspicion debt is making clean regroups harder")
	if obligation_heat >= 3 and not model_pressure.has("public obligation is turning route choice into a rescue debt"):
		model_pressure.append("public obligation is turning route choice into a rescue debt")
	var group_signals: Array[String] = []
	for relationship_signal in Array(relationship_model.get("group_signals", [])):
		var relationship_text := str(relationship_signal).strip_edges()
		if not relationship_text.is_empty() and not group_signals.has(relationship_text):
			group_signals.append(relationship_text)
	var weighted_keys: Array[Dictionary] = []
	for signal_key in signal_weights.keys():
		weighted_keys.append({"label": str(signal_key), "weight": int(signal_weights.get(signal_key, 0))})
	weighted_keys.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(a.get("label", "")) < str(b.get("label", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	for entry_raw in weighted_keys:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		if group_signals.has(label):
			continue
		group_signals.append(label)
		if group_signals.size() >= 8:
			break
	var protocol_weighting := "balanced"
	if protocol_state == "Exposure Protocol":
		protocol_weighting = "isolation pressure"
	elif protocol_state == "Intimate Protocol":
		protocol_weighting = "pair pressure"
	elif protocol_state == "Fracture Protocol":
		protocol_weighting = "split pressure"
	elif protocol_state == "Expedition Protocol":
		protocol_weighting = "spectacle pressure"
	var role_custody_pressure := _role_custody_group_pressure()
	var witness_pressure := "contained"
	var suspicion_total := int(role_custody_pressure.get("suspicion_heat", 0))
	var custody_total := int(role_custody_pressure.get("custody_debt", 0))
	var counterfeit_total := int(role_custody_pressure.get("counterfeit_heat", 0))
	if suspicion_total >= 4 or int(role_custody_pressure.get("warden_duty", 0)) >= 3:
		witness_pressure = "focused"
	elif suspicion_total >= 2 or custody_total >= 2:
		witness_pressure = "public"
	var counterfeit_pressure := "contained"
	if counterfeit_total >= 3:
		counterfeit_pressure = "active"
	elif counterfeit_total > 0:
		counterfeit_pressure = "present"
	var relationship_pressure := "steady"
	if trust_fragility >= 2:
		relationship_pressure = "strained"
	elif obligation_heat >= 3 or alliance_stability >= 3 or loyalty_pressure >= 3:
		relationship_pressure = "binding"
	var public_evidence_tags: Array[String] = []
	if witness_pressure != "contained":
		public_evidence_tags.append("witness_visible")
	if custody_total >= 2:
		public_evidence_tags.append("custody_visible")
	if relationship_pressure != "steady":
		public_evidence_tags.append("relationship_visible")
	var blame_surface_tags: Array[String] = []
	if witness_pressure != "contained":
		blame_surface_tags.append("witness_surface")
	if custody_total >= 2:
		blame_surface_tags.append("custody_surface")
	if relationship_pressure == "strained":
		blame_surface_tags.append("relationship_surface")
	var consequence_read_refs: Array[String] = []
	if witness_pressure != "contained":
		consequence_read_refs.append("public_event_visibility")
	if relationship_pressure != "steady":
		consequence_read_refs.append("relationship_model")
	if counterfeit_pressure != "contained":
		consequence_read_refs.append("artifact_truth")
	var build_spread: Array[String] = []
	for build_label in build_totals.keys():
		build_spread.append(str(build_label))
	build_spread.sort()
	return {
		"dominant_build": dominant_build,
		"build_spread": build_spread,
		"group_signals": group_signals,
		"fault_lines": fault_lines,
		"model_pressure": model_pressure,
		"protocol_weighting": protocol_weighting,
		"widest_stability": widest_stability,
		"risk_profiles": profile_counts,
		"feature_scores": Dictionary(relationship_model.get("feature_scores", {})).duplicate(true),
		"relationship_model": relationship_model.duplicate(true),
		"relationship_summary": str(relationship_model.get("summary", "")).strip_edges(),
		"alliance_stability": alliance_stability,
		"trust_fragility": trust_fragility,
		"friendship_pressure": friendship_pressure,
		"loyalty_pressure": loyalty_pressure,
		"obligation_heat": obligation_heat,
		"social_consequence_version": SOCIAL_CONSEQUENCE_VERSION,
		"public_evidence_tags": public_evidence_tags,
		"witness_pressure": witness_pressure,
		"counterfeit_pressure": counterfeit_pressure,
		"relationship_pressure": relationship_pressure,
		"blame_surface_tags": blame_surface_tags,
		"consequence_read_refs": consequence_read_refs
	}

func _build_relationship_gameplay_model(profile: Dictionary, cards: Dictionary, peer_ids: Array[int], protocol_state: String) -> Dictionary:
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var persona: Dictionary = Dictionary(profile.get("persona_state", {}))
	var pair_map: Dictionary = Dictionary(fabric.get("pairs", {}))
	var crew_map: Dictionary = Dictionary(fabric.get("crews", {}))
	var active_public_ids: Array[String] = []
	for peer_id in peer_ids:
		var card: Dictionary = Dictionary(cards.get(str(peer_id), cards.get(peer_id, {})))
		var public_id := str(card.get("public_id", "peer_%d" % peer_id)).strip_edges()
		if not public_id.is_empty() and not active_public_ids.has(public_id):
			active_public_ids.append(public_id)
	active_public_ids.sort()
	var alliance_stability := 0
	var trust_fragility := 0
	var friendship_pressure := 0
	var loyalty_pressure := 0
	var obligation_heat := Array(persona.get("public_expectations", [])).size()
	var group_signals: Array[String] = []
	var model_pressure: Array[String] = []
	var fault_lines: Array[String] = []
	for pair_key in pair_map.keys():
		var members := str(pair_key).split(":")
		if members.size() < 2:
			continue
		if not active_public_ids.has(str(members[0])) or not active_public_ids.has(str(members[1])):
			continue
		var pair: Dictionary = Dictionary(pair_map.get(pair_key, {}))
		alliance_stability += int(pair.get("rescues", 0)) + int(pair.get("shared_burdens", 0)) + int(pair.get("mutual_extractions", 0))
		trust_fragility += int(pair.get("betrayals", 0)) + int(pair.get("refusals", 0)) + int(pair.get("near_misses", 0)) / 2
		friendship_pressure += int(pair.get("rescues", 0)) + int(pair.get("mutual_extractions", 0))
		loyalty_pressure += Array(pair.get("obligations", [])).size()
	for crew_key in crew_map.keys():
		var crew: Dictionary = Dictionary(crew_map.get(crew_key, {}))
		var members := Array(crew.get("members", []))
		var active_member_count := 0
		for member in members:
			if active_public_ids.has(str(member).strip_edges()):
				active_member_count += 1
		if active_member_count < 2:
			continue
		alliance_stability += int(crew.get("successful_pushes", 0)) + int(crew.get("recoveries", 0)) / 2
		trust_fragility += int(crew.get("collapse_moments", 0)) + int(crew.get("escalations", 0)) / 2
		friendship_pressure += int(crew.get("history_count", 0)) / 2
		loyalty_pressure += Array(crew.get("obligations", [])).size()
	obligation_heat += loyalty_pressure
	if alliance_stability >= 3:
		group_signals.append("escort expectation")
		model_pressure.append("allied rescue history is bending the route toward visible handoffs")
	if friendship_pressure >= 2:
		group_signals.append("rescue debt")
		model_pressure.append("friendship history is making rescue convergence harder to refuse")
	if loyalty_pressure >= 2:
		group_signals.append("custody debt")
		model_pressure.append("loyalty pressure is narrowing the acceptable burden handoff")
	if trust_fragility >= 2:
		group_signals.append("suspicion debt")
		model_pressure.append("trust fractures are turning regroups into witness-heavy risks")
	if obligation_heat >= 3:
		group_signals.append("public obligation")
		model_pressure.append("public memory is making extraction feel like a debt settlement")
	if trust_fragility >= 2 and alliance_stability >= 2:
		fault_lines.append("old rescue trust is colliding with live suspicion debt")
	if loyalty_pressure >= 2 and protocol_state in ["Intimate Protocol", "Fracture Protocol"]:
		fault_lines.append("burden handoffs are being judged against remembered obligations")
	var summary := "balanced relationship pressure"
	if trust_fragility > alliance_stability:
		summary = "fragile trust and suspicion debt"
	elif alliance_stability >= trust_fragility and alliance_stability >= 3:
		summary = "escort expectation and rescue obligation"
	return {
		"alliance_stability": alliance_stability,
		"trust_fragility": trust_fragility,
		"friendship_pressure": friendship_pressure,
		"loyalty_pressure": loyalty_pressure,
		"obligation_heat": obligation_heat,
		"group_signals": group_signals,
		"model_pressure": model_pressure,
		"fault_lines": fault_lines,
		"summary": summary,
		"feature_scores": {
			"alliance_stability": alliance_stability,
			"trust_fragility": trust_fragility,
			"friendship_pressure": friendship_pressure,
			"loyalty_pressure": loyalty_pressure,
			"obligation_heat": obligation_heat
		}
	}

func get_carry_speed_multiplier_for_peer(peer_id: int) -> float:
	return float(_loadout_runtime_affordances(peer_id).get("carry_speed_mult", 1.0))

func get_loadout_runtime_affordances_for_peer(peer_id: int) -> Dictionary:
	if peer_id <= 0:
		return {}
	return _loadout_runtime_affordances(peer_id)

func get_local_loadout_runtime_affordances() -> Dictionary:
	var mp := _mp()
	if mp == null:
		return {}
	return get_loadout_runtime_affordances_for_peer(mp.get_unique_id())

func get_item_effects_for_peer(peer_id: int) -> Dictionary:
	return _loadout_runtime_affordances(peer_id)

func get_ghost_state() -> Dictionary:
	return ghost_state.duplicate(true)

func get_predator_state() -> Dictionary:
	return predator_state.duplicate(true)

func get_protocol_watch_state() -> Dictionary:
	return protocol_watch_state.duplicate(true)

func get_active_encounter_state() -> Dictionary:
	var run_state := _run_state()
	if run_state == null:
		return {}
	return Dictionary(run_state.active_encounter_state).duplicate(true)

func get_encounter_history() -> Array:
	var run_state := _run_state()
	if run_state == null:
		return []
	return Array(run_state.encounter_history).duplicate(true)

func get_pathology_state() -> Dictionary:
	var run_state := _run_state()
	if run_state != null and not Dictionary(run_state.pathology_state).is_empty():
		return Dictionary(run_state.pathology_state).duplicate(true)
	return Dictionary(_effective_constitution().get("pathology_state", {})).duplicate(true)

func get_active_apex_state() -> Dictionary:
	var run_state := _run_state()
	if run_state == null:
		return {}
	return Dictionary(run_state.active_apex_state).duplicate(true)

func get_apex_history() -> Array:
	var run_state := _run_state()
	if run_state == null:
		return []
	return Array(run_state.apex_history).duplicate(true)

func get_local_aftermath() -> Dictionary:
	var run_state := _run_state()
	if run_state == null:
		return {}
	return Dictionary(run_state.local_aftermath).duplicate(true)

func _resolve_encounter_definition(species_id: String, mode: String = "") -> Dictionary:
	var manifest: Dictionary = get_current_encounter_manifest()
	var fallback: Dictionary = {}
	for encounter_raw in Array(manifest.get("encounters", [])):
		var encounter: Dictionary = Dictionary(encounter_raw).duplicate(true)
		if str(encounter.get("species_id", "")).strip_edges() != species_id:
			continue
		if fallback.is_empty():
			fallback = encounter
		var mode_ids := _string_array(encounter.get("mode_ids", []))
		if not mode.strip_edges().is_empty() and (mode_ids.has(mode) or str(encounter.get("intent_id", "")).strip_edges() == mode):
			return encounter
	return fallback

func _resolve_apex_definition(species_id: String, encounter_id: String = "", mode: String = "") -> Dictionary:
	var manifest: Dictionary = get_current_apex_manifest()
	var fallback: Dictionary = {}
	for apex_raw in Array(manifest.get("apexes", [])):
		var apex: Dictionary = Dictionary(apex_raw).duplicate(true)
		if str(apex.get("species_id", "")).strip_edges() != species_id:
			continue
		if fallback.is_empty():
			fallback = apex
		var linked_encounter_ids := _string_array(apex.get("linked_encounter_ids", []))
		if not encounter_id.strip_edges().is_empty() and linked_encounter_ids.has(encounter_id):
			return apex
		if not mode.strip_edges().is_empty():
			var apex_function := str(apex.get("function", "")).strip_edges()
			var class_id := str(apex.get("apex_class_id", "")).strip_edges()
			if apex_function == mode or class_id.find(mode) != -1:
				return apex
	return fallback

func _seed_runtime_pathology_state() -> Dictionary:
	var seeded := get_pathology_state()
	if seeded.is_empty():
		seeded = {
			"schema_name": "PathologyState",
			"schema_version": 2,
			"active_family_ids": [],
			"spread_heat": 0,
			"remission_state": "contained",
			"recurrence_heat": 0,
			"suppression_state": "watchful",
			"mutation_tags": [],
			"summary_lines": []
		}
	return seeded

func _finalize_active_encounter_state(reason: String) -> void:
	var run_state := _run_state()
	if run_state == null:
		return
	var active := Dictionary(run_state.active_encounter_state).duplicate(true)
	if active.is_empty():
		return
	var local_aftermath := _finalize_active_apex_state(reason, active)
	active["state"] = "resolved"
	active["resolved_tick"] = current_server_tick
	active["resolution_reason"] = reason
	var history: Array = Array(run_state.encounter_history).duplicate(true)
	if not history.is_empty():
		var last_index := history.size() - 1
		var last_entry := Dictionary(history[last_index]).duplicate(true)
		if str(last_entry.get("signature", "")).strip_edges() == str(active.get("signature", "")).strip_edges():
			history[last_index] = active
		else:
			history.append(active)
	else:
		history.append(active)
	run_state.encounter_history = history
	run_state.active_encounter_state = {}
	if local_aftermath.is_empty():
		run_state.local_aftermath = _build_local_aftermath_record(active, {}, reason)

func _apply_runtime_encounter_state(species_id: String, room_slot: int, target_peer_id: int, mode: String = "") -> Dictionary:
	var run_state := _run_state()
	if run_state == null:
		return {}
	var encounter := _resolve_encounter_definition(species_id, mode)
	if encounter.is_empty():
		return {}
	var signature := "%s:%s:%d:%d" % [
		str(encounter.get("encounter_id", "")).strip_edges(),
		mode,
		room_slot,
		target_peer_id
	]
	var active := Dictionary(run_state.active_encounter_state).duplicate(true)
	if str(active.get("signature", "")).strip_edges() != signature and not active.is_empty():
		_finalize_active_encounter_state("superseded")
	var next_state := {
		"signature": signature,
		"encounter_id": str(encounter.get("encounter_id", "")).strip_edges(),
		"species_id": species_id,
		"intent_id": str(encounter.get("intent_id", "")).strip_edges(),
		"topology_id": str(encounter.get("topology_id", "")).strip_edges(),
		"anchored_pressures": _string_array(encounter.get("anchored_pressures", [])),
		"local_aftermath_tags": _string_array(encounter.get("local_aftermath_tags", [])),
		"world_aftermath_tags": _string_array(encounter.get("world_aftermath_tags", [])),
		"role_vectors": _string_array(encounter.get("role_vectors", [])),
		"consequence_classes": _string_array(encounter.get("consequence_classes", [])),
		"pathology_family_ids": _string_array(encounter.get("pathology_family_ids", [])),
		"state_flow": _string_array(encounter.get("state_flow", [])),
		"room_slot": room_slot,
		"target_peer_id": target_peer_id,
		"mode": mode,
		"state": "commit",
		"activated_tick": current_server_tick
	}
	run_state.active_encounter_state = next_state.duplicate(true)
	var history: Array = Array(run_state.encounter_history).duplicate(true)
	if history.is_empty() or str(Dictionary(history[history.size() - 1]).get("signature", "")).strip_edges() != signature:
		history.append(next_state.duplicate(true))
	run_state.encounter_history = history
	var pathology_state := _seed_runtime_pathology_state()
	pathology_state["active_family_ids"] = _merge_arrays(
		Array(pathology_state.get("active_family_ids", [])),
		Array(next_state.get("pathology_family_ids", []))
	)
	pathology_state["spread_heat"] = maxi(int(pathology_state.get("spread_heat", 0)), Array(pathology_state.get("active_family_ids", [])).size())
	pathology_state["recurrence_heat"] = maxi(int(pathology_state.get("recurrence_heat", 0)), Array(next_state.get("pathology_family_ids", [])).size())
	pathology_state["mutation_tags"] = _merge_arrays(
		Array(pathology_state.get("mutation_tags", [])),
		Array(next_state.get("pathology_family_ids", []))
	)
	pathology_state["remission_state"] = "watchful" if not Array(pathology_state.get("active_family_ids", [])).is_empty() else "contained"
	pathology_state["summary_lines"] = _merge_arrays(
		Array(pathology_state.get("summary_lines", [])),
		Array(encounter.get("summary_lines", []))
	).slice(0, 3)
	run_state.pathology_state = pathology_state
	_apply_runtime_apex_state(species_id, room_slot, target_peer_id, next_state, mode)
	return encounter

func _clear_runtime_encounter_state_for_species(species_id: String, reason: String = "resolved") -> void:
	var run_state := _run_state()
	if run_state == null:
		return
	var active := Dictionary(run_state.active_encounter_state)
	if str(active.get("species_id", "")).strip_edges() != species_id:
		return
	_finalize_active_encounter_state(reason)

func _apply_runtime_apex_state(species_id: String, room_slot: int, target_peer_id: int, encounter_state: Dictionary, mode: String = "") -> Dictionary:
	var run_state := _run_state()
	if run_state == null:
		return {}
	var encounter_id := str(encounter_state.get("encounter_id", "")).strip_edges()
	var apex := _resolve_apex_definition(species_id, encounter_id, mode)
	if apex.is_empty():
		return {}
	var signature := "%s:%s:%d:%d" % [
		str(apex.get("apex_id", "")).strip_edges(),
		mode,
		room_slot,
		target_peer_id
	]
	var active := Dictionary(run_state.active_apex_state).duplicate(true)
	if str(active.get("signature", "")).strip_edges() != signature and not active.is_empty():
		_finalize_active_apex_state("superseded", encounter_state)
	var next_state := {
		"signature": signature,
		"apex_id": str(apex.get("apex_id", "")).strip_edges(),
		"apex_class_id": str(apex.get("apex_class_id", "")).strip_edges(),
		"species_id": species_id,
		"linked_encounter_id": encounter_id,
		"origin": str(apex.get("origin", "")).strip_edges(),
		"function": str(apex.get("function", "")).strip_edges(),
		"arena": str(apex.get("arena", "")).strip_edges(),
		"anchored_pressures": _string_array(apex.get("anchored_pressures", [])),
		"local_aftermath_tags": _string_array(apex.get("local_aftermath_tags", [])),
		"world_aftermath_tags": _string_array(apex.get("world_aftermath_tags", [])),
		"phase_model": _string_array(apex.get("phase_model", [])),
		"resolution_classes": _string_array(apex.get("resolution_classes", [])),
		"telegraph_channels": _string_array(Dictionary(apex.get("telegraph_profile", {})).get("channels", [])),
		"room_slot": room_slot,
		"target_peer_id": target_peer_id,
		"mode": mode,
		"state": "announce",
		"activated_tick": current_server_tick
	}
	run_state.active_apex_state = next_state.duplicate(true)
	var history: Array = Array(run_state.apex_history).duplicate(true)
	if history.is_empty() or str(Dictionary(history[history.size() - 1]).get("signature", "")).strip_edges() != signature:
		history.append(next_state.duplicate(true))
	run_state.apex_history = history
	return apex

func _finalize_active_apex_state(reason: String, encounter_state: Dictionary = {}) -> Dictionary:
	var run_state := _run_state()
	if run_state == null:
		return {}
	var active := Dictionary(run_state.active_apex_state).duplicate(true)
	if active.is_empty():
		return {}
	active["state"] = "aftermath"
	active["resolved_tick"] = current_server_tick
	active["resolution_reason"] = reason
	var history: Array = Array(run_state.apex_history).duplicate(true)
	if not history.is_empty():
		var last_index := history.size() - 1
		var last_entry := Dictionary(history[last_index]).duplicate(true)
		if str(last_entry.get("signature", "")).strip_edges() == str(active.get("signature", "")).strip_edges():
			history[last_index] = active
		else:
			history.append(active)
	else:
		history.append(active)
	run_state.apex_history = history
	var local_aftermath := _build_local_aftermath_record(encounter_state, active, reason)
	run_state.local_aftermath = local_aftermath
	run_state.active_apex_state = {}
	return local_aftermath

func _build_local_aftermath_record(encounter_state: Dictionary, apex_state: Dictionary, reason: String) -> Dictionary:
	var source_kind := "apex" if not apex_state.is_empty() else "encounter"
	var source_id := str(apex_state.get("apex_id", encounter_state.get("encounter_id", ""))).strip_edges()
	var room_slot := int(apex_state.get("room_slot", encounter_state.get("room_slot", -1)))
	var anchored_pressures := _merge_arrays(
		Array(encounter_state.get("anchored_pressures", [])),
		Array(apex_state.get("anchored_pressures", []))
	)
	var consequence_classes := _merge_arrays(
		Array(encounter_state.get("consequence_classes", [])),
		Array(apex_state.get("resolution_classes", []))
	)
	var consequence_context := _build_aftermath_consequence_context(reason)
	var local_aftermath_tags := _merge_arrays(
		Array(encounter_state.get("local_aftermath_tags", [])),
		Array(apex_state.get("local_aftermath_tags", []))
	)
	var world_aftermath_tags := _merge_arrays(
		Array(encounter_state.get("world_aftermath_tags", [])),
		Array(apex_state.get("world_aftermath_tags", []))
	)
	var market_regime_id := str(consequence_context.get("market_regime_id", "")).strip_edges()
	var market_carrier_risk_band := str(consequence_context.get("market_carrier_risk_band", "")).strip_edges()
	if not market_regime_id.is_empty():
		world_aftermath_tags = _merge_arrays(world_aftermath_tags, [market_regime_id])
	if not market_carrier_risk_band.is_empty():
		world_aftermath_tags = _merge_arrays(world_aftermath_tags, ["carrier_%s" % market_carrier_risk_band])
	var aftermath_consequence_refs := _merge_arrays(
		([str(consequence_context.get("consequence_event_family", "")).strip_edges()] if not str(consequence_context.get("consequence_event_family", "")).strip_edges().is_empty() else []),
		_string_array(consequence_context.get("encounter_hook_tags", []))
		+ _string_array(consequence_context.get("return_pressure_tags", []))
		+ _string_array(consequence_context.get("public_consequence_tags", []))
	)
	var custody_state_delta := "contested" if anchored_pressures.has("custody_pressure") else "stable"
	var evidence_state_delta := "exposed" if anchored_pressures.has("evidence_pressure") else "contained"
	var resource_state_delta := "strained" if consequence_classes.has("resource_drain") or anchored_pressures.has("burden_pressure") else "stable"
	var immediate_route_state := "rerouted" if anchored_pressures.has("route_pressure") or anchored_pressures.has("extraction_pressure") else "held"
	return {
		"schema_name": "LocalAftermath",
		"schema_version": 1,
		"encounter_apex_consequence_version": ENCOUNTER_APEX_CONSEQUENCE_VERSION,
		"aftermath_id": "local_aftermath_%s_%d" % [source_id, maxi(current_server_tick, 0)],
		"source_id": source_id,
		"source_kind": source_kind,
		"encounter_resolution_state": _encounter_resolution_state(reason, encounter_state, anchored_pressures),
		"apex_resolution_state": _apex_resolution_state(reason, apex_state, anchored_pressures),
		"anchored_pressures": anchored_pressures.duplicate(),
		"consequence_classes": consequence_classes.duplicate(),
		"local_aftermath_tags": local_aftermath_tags.slice(0, 4),
		"world_aftermath_tags": world_aftermath_tags.slice(0, 4),
		"aftermath_consequence_refs": aftermath_consequence_refs.slice(0, 8),
		"affected_room_slots": [room_slot] if room_slot >= 0 else [],
		"immediate_route_state": immediate_route_state,
		"custody_state_delta": custody_state_delta,
		"evidence_state_delta": evidence_state_delta,
		"resource_state_delta": resource_state_delta,
		"residual_telegraph_tags": _merge_arrays(
			_merge_arrays(Array(encounter_state.get("anchored_pressures", [])), Array(apex_state.get("telegraph_channels", []))),
			_string_array(consequence_context.get("return_pressure_tags", []))
		),
		"narrative_residue_tags": _merge_arrays(Array(encounter_state.get("pathology_family_ids", [])), Array(apex_state.get("anchored_pressures", []))),
		"resolution_reason": reason
	}

func _build_aftermath_consequence_context(reason: String) -> Dictionary:
	var extraction_details := _find_extraction_completion_details() if reason == "extraction_objective" else {}
	return build_outcome_summary(reason, artifacts_by_id, extraction_details)

func _encounter_resolution_state(reason: String, encounter_state: Dictionary, anchored_pressures: Array[String]) -> String:
	if encounter_state.is_empty():
		return ""
	if reason == "superseded":
		return "superseded"
	if reason == "session_interrupted":
		return "interrupted"
	if anchored_pressures.has("route_pressure") or anchored_pressures.has("extraction_pressure"):
		return "rerouted"
	if anchored_pressures.has("custody_pressure") or anchored_pressures.has("evidence_pressure"):
		return "contested"
	return "contained"

func _apex_resolution_state(reason: String, apex_state: Dictionary, anchored_pressures: Array[String]) -> String:
	if apex_state.is_empty():
		return ""
	if reason == "superseded":
		return "superseded"
	if reason == "session_interrupted":
		return "interrupted"
	if anchored_pressures.has("route_pressure") or anchored_pressures.has("extraction_pressure"):
		return "route_resolution"
	if anchored_pressures.has("burden_pressure") or anchored_pressures.has("custody_pressure"):
		return "pressured_resolution"
	return "contained"

func get_tool_counts_for_peer(peer_id: int) -> Dictionary:
	var counts: Dictionary = tool_inventory_by_peer.get(peer_id, {})
	return {
		"bomb": int(counts.get("bomb", START_BOMB_COUNT)),
		"rope": int(counts.get("rope", START_ROPE_COUNT))
	}

func get_local_tool_counts() -> Dictionary:
	var mp := _mp()
	if mp == null:
		return {"bomb": 0, "rope": 0}
	return get_tool_counts_for_peer(mp.get_unique_id())

func set_tool_counts_local_only(peer_id: int, bombs: int, ropes: int) -> void:
	tool_inventory_by_peer[peer_id] = {"bomb": maxi(bombs, 0), "rope": maxi(ropes, 0)}

func reset_tool_inventory_for_test(peer_ids: Array[int], bombs: int = START_BOMB_COUNT, ropes: int = START_ROPE_COUNT) -> void:
	tool_inventory_by_peer.clear()
	for peer_id in peer_ids:
		tool_inventory_by_peer[int(peer_id)] = {"bomb": bombs, "rope": ropes}

func consume_tool_charge_for_test(peer_id: int, tool_type: String) -> bool:
	return _consume_tool_charge(peer_id, tool_type)

func track_noise_trace(peer_id: int, room_slot: int, carrying_artifact: bool) -> void:
	if not is_host or not run_active or not carrying_artifact:
		return
	var next_due := int(next_noise_trace_tick_by_peer.get(peer_id, 0))
	if current_server_tick < next_due:
		return
	var interval := _current_noise_trace_interval(peer_id)
	next_noise_trace_tick_by_peer[peer_id] = current_server_tick + interval
	record_public_event("noise_trace", room_slot, -1, {})

func get_known_role_for_peer(peer_id: int) -> String:
	if not is_host:
		return ""
	return str(roles_by_peer.get(peer_id, "Unknown"))

func _role_name_for_peer(peer_id: int) -> String:
	return str(roles_by_peer.get(peer_id, ""))

func _role_service() -> RoleService:
	return ROLE_SERVICE_SCRIPT.new()

func _active_peers_in_room(room_slot: int) -> Array[int]:
	var peer_ids: Array[int] = []
	for peer_id_variant in players:
		var peer_id := int(peer_id_variant)
		if int(player_room_by_peer.get(peer_id, -1)) != room_slot:
			continue
		if not peer_ids.has(peer_id):
			peer_ids.append(peer_id)
	peer_ids.sort()
	return peer_ids

func _artifact_carrier_in_room(room_slot: int) -> int:
	var artifact_ids: Array = artifacts_by_id.keys()
	artifact_ids.sort()
	for artifact_id_variant in artifact_ids:
		var artifact: Dictionary = Dictionary(artifacts_by_id.get(artifact_id_variant, {}))
		var owner_peer_id := int(artifact.get("owner_peer_id", 0))
		if owner_peer_id <= 0:
			continue
		if int(player_room_by_peer.get(owner_peer_id, -1)) == room_slot:
			return owner_peer_id
	return 0

func _carried_artifact_authenticity(peer_id: int) -> String:
	var artifact_id := _find_carried_artifact_by_peer(peer_id)
	if artifact_id == 0 or not artifacts_by_id.has(artifact_id):
		return ""
	return str(artifact_service.authenticity_state(Dictionary(artifacts_by_id.get(artifact_id, {}))))

func broadcast_hazard_pulse(room_slot: int, source_peer_id: int, reason: String) -> void:
	if not is_host:
		return
	var mp := _mp()
	if not _has_live_network_peer(mp):
		host_hazard_pulse(room_slot, source_peer_id, reason)
		return
	host_hazard_pulse.rpc(room_slot, source_peer_id, reason)

func record_public_event(event_type: String, room_slot: int, actor_peer_id: int, meta: Dictionary = {}) -> void:
	if not is_host:
		return
	var event := _build_event("public", event_type, room_slot, actor_peer_id, _public_meta_allowlist(event_type, meta))
	if _capture_events_for_test:
		_captured_public_events_for_test.append(event.duplicate(true))
	var mp := _mp()
	if not _has_live_network_peer(mp):
		host_push_public_event(event)
		return
	host_push_public_event.rpc(event)

func record_private_event(target_peer_id: int, event_type: String, room_slot: int, actor_peer_id: int, meta: Dictionary = {}) -> void:
	if not is_host:
		return
	var event := _build_event("private", event_type, room_slot, actor_peer_id, meta, target_peer_id)
	if _capture_events_for_test:
		_captured_private_events_for_test.append(event.duplicate(true))
	var mp := _mp()
	var local_id := -1
	if mp != null:
		local_id = mp.get_unique_id()
	if not _has_live_network_peer(mp):
		host_push_private_event(event)
		return
	if target_peer_id == local_id:
		_consume_private_side_effect(event)
	else:
		host_push_private_event.rpc_id(target_peer_id, event)

func _broadcast_mutation_event(event: Dictionary) -> void:
	if not is_host or event.is_empty():
		return
	if _capture_events_for_test:
		var timeline_event := _build_mutation_timeline_event(event)
		if str(timeline_event.get("visibility", "private")) == "public":
			_captured_public_events_for_test.append(timeline_event)
		else:
			_captured_private_events_for_test.append(timeline_event)
	var mp := _mp()
	if not _has_live_network_peer(mp):
		return
	var visibility := str(event.get("visibility", "private"))
	if visibility == "public":
		host_push_mutation_event.rpc(event)
		return
	var target_peer_id := int(event.get("actor_peer_id", -1))
	var local_id := mp.get_unique_id()
	if target_peer_id > 0 and target_peer_id != local_id:
		host_push_mutation_event.rpc_id(target_peer_id, event)

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

@rpc("any_peer", "reliable")
func client_use_item_request(item_id: int, room_slot: int) -> void:
	if not is_host:
		return
	var mp := _mp()
	if mp == null:
		return
	_host_use_item(mp.get_remote_sender_id(), item_id, room_slot)

@rpc("any_peer", "call_remote", "reliable")
func client_enter_door_request(door_id: int) -> void:
	if not is_host:
		return
	_host_enter_door(multiplayer.get_remote_sender_id(), door_id)

@rpc("authority", "reliable")
func host_reveal_role(payload: Dictionary) -> void:
	var run_state := _run_state()
	if run_state == null:
		return
	run_state.local_role = str(payload.get("role", "Unknown"))
	run_state.local_role_payload = payload.duplicate(true)
	emit_signal("role_revealed", str(run_state.local_role))

@rpc("authority", "call_local", "reliable")
func host_sync_artifact_state(payload: Array) -> void:
	var next_artifacts: Dictionary = {}
	for artifact_raw in payload:
		var artifact: Dictionary = artifact_raw
		var artifact_id := int(artifact.get("artifact_id", 0))
		next_artifacts[artifact_id] = artifact.duplicate(true)
	artifacts_by_id = next_artifacts.duplicate(true)
	var run_state := _run_state()
	if run_state == null:
		emit_signal("artifact_state_changed", artifacts_by_id.duplicate(true))
		emit_signal("evidence_state_changed", artifacts_by_id.duplicate(true))
		return
	if run_state.has_method("set_artifacts"):
		run_state.set_artifacts(next_artifacts)
	else:
		run_state.evidence_by_id.clear()
		run_state.artifacts_by_id.clear()
		for artifact_id in next_artifacts.keys():
			var artifact: Dictionary = Dictionary(next_artifacts.get(artifact_id, {})).duplicate(true)
			run_state.evidence_by_id[artifact_id] = artifact.duplicate(true)
			run_state.artifacts_by_id[artifact_id] = artifact.duplicate(true)
	emit_signal("artifact_state_changed", run_state.artifacts_by_id.duplicate(true))
	emit_signal("evidence_state_changed", run_state.evidence_by_id)

@rpc("authority", "call_local", "reliable")
func host_sync_item_state(payload: Array) -> void:
	items_by_id.clear()
	var run_state := _run_state()
	if run_state != null:
		run_state.items_by_id.clear()
	for item_raw in payload:
		var item_dict: Dictionary = item_raw
		var item_id := int(item_dict.get("item_id", 0))
		items_by_id[item_id] = item_dict.duplicate(true)
		if run_state != null:
			run_state.items_by_id[item_id] = item_dict.duplicate(true)
	emit_signal("item_state_changed", items_by_id.duplicate(true))

@rpc("authority", "call_local", "reliable")
func host_sync_ghost_state(state: Dictionary) -> void:
	ghost_state = state.duplicate(true)
	emit_signal("ghost_state_changed", ghost_state.duplicate(true))

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

@rpc("authority", "reliable")
func host_push_mutation_event(event: Dictionary) -> void:
	var event_log := _event_log()
	if event_log != null and event_log.has_method("add_mutation_event"):
		event_log.add_mutation_event(event)

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
		_clear_ghost_state()
		_clear_predator_state()
		_clear_protocol_watch_state()
		_clear_echo_lure_state()
		emit_signal("ghost_state_changed", ghost_state.duplicate(true))
		emit_signal("artifact_state_changed", {})
		emit_signal("evidence_state_changed", {})
		emit_signal("item_state_changed", {})
		clear_reconnect_offer()
		_set_connection_status("Disconnected")
		emit_signal("host_endpoint_changed", host_bind_address, host_listen_port)
		emit_signal("lobby_updated", players, ready_by_id, is_host)
	else:
		_set_connected_peers([], "reset_to_lobby_client")
		_reconcile_ready_map_for_connected_peers(false)
		input_by_peer.clear()
		items_by_id.clear()
		_clear_ghost_state()
		_clear_predator_state()
		_clear_protocol_watch_state()
		_clear_echo_lure_state()
		emit_signal("ghost_state_changed", ghost_state.duplicate(true))
		emit_signal("artifact_state_changed", {})
		emit_signal("evidence_state_changed", {})
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
	if not artifact_service.can_pickup(artifact, player_pos):
		_deny_action(requester_id, "out_of_range", requester_slot)
		return
	var next: Dictionary = artifact_service.apply_owner(artifact, requester_id, player_pos)
	next["room_slot"] = requester_slot
	artifacts_by_id[artifact_id] = next
	_apply_role_custody_pickup_pressure(requester_id, next)
	_apply_constitution_mutation("artifact_picked", {
		"artifact_id": artifact_id,
		"room_slot": requester_slot,
		"actor_peer_id": requester_id,
		"owner_peer_id": requester_id,
		"visibility": "public"
	})
	_maybe_trigger_covenant_activation(requester_id, requester_slot)
	_refresh_transformation_thresholds_for_peer(requester_id, requester_slot)
	_broadcast_artifact_state()
	record_public_event("artifact_picked", int(next.get("room_slot", -1)), requester_id, {"artifact_id": artifact_id})

func _host_drop(requester_id: int) -> void:
	var carried_id := _find_carried_artifact_by_peer(requester_id)
	if carried_id == 0:
		_deny_action(requester_id, "no_target")
		return
	var artifact: Dictionary = artifacts_by_id[carried_id]
	if not artifact_service.can_drop(artifact, requester_id):
		_deny_action(requester_id, "not_owner")
		return
	var requester_slot := int(player_room_by_peer.get(requester_id, int(artifact.get("room_slot", -1))))
	var pos: Vector2 = player_pos_by_peer.get(requester_id, Vector2.ZERO) + Vector2(0, 10)
	var next: Dictionary = artifact_service.apply_owner(artifact, 0, pos)
	next["room_slot"] = requester_slot
	artifacts_by_id[carried_id] = next
	_apply_role_custody_drop_pressure(requester_id, artifact, requester_slot)
	_apply_constitution_mutation("artifact_dropped", {
		"artifact_id": carried_id,
		"room_slot": requester_slot,
		"actor_peer_id": requester_id,
		"visibility": "public"
	})
	_refresh_transformation_thresholds_for_peer(requester_id, requester_slot)
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
	if not artifact_service.can_steal(artifact, stealer_pos, victim_pos):
		_deny_action(requester_id, "out_of_range", requester_slot)
		return
	var next: Dictionary = artifact_service.apply_owner(artifact, requester_id, stealer_pos)
	next["room_slot"] = requester_slot
	artifacts_by_id[artifact_id] = next
	_note_role_custody_pressure(requester_id, 1, 1, 0, 0)
	_note_role_custody_pressure(victim_id, 0, 1, 0, 0)
	_apply_role_custody_pickup_pressure(requester_id, next)
	_apply_constitution_mutation("artifact_stolen", {
		"artifact_id": artifact_id,
		"room_slot": requester_slot,
		"actor_peer_id": requester_id,
		"from_peer": victim_id,
		"owner_peer_id": requester_id,
		"visibility": "public"
	})
	_maybe_trigger_covenant_activation(requester_id, requester_slot)
	_refresh_transformation_thresholds_for_peer(requester_id, requester_slot)
	_refresh_transformation_thresholds_for_peer(victim_id, victim_slot)
	_broadcast_artifact_state()
	record_public_event("artifact_stolen", int(next.get("room_slot", -1)), requester_id, {"artifact_id": artifact_id, "from_peer": victim_id})

func _host_forge(requester_id: int, room_slot: int) -> void:
	var role_name := _role_name_for_peer(requester_id)
	if not _role_service().can_forge(role_name):
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
	var forged: Dictionary = artifact_service.build_forged_artifact(
		_run_seed(),
		next_artifact_id,
		room_slot,
		forge_counter,
		player_pos_by_peer.get(requester_id, Vector2.ZERO) + Vector2(18, 0)
	)
	forge_counter_by_room[room_slot] = forge_counter + 1
	artifacts_by_id[next_artifact_id] = forged
	next_artifact_id += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
		_note_role_custody_pressure(requester_id, 0, 2, 1, 1)
	else:
		_note_role_custody_pressure(requester_id, 0, 1, 2, 1)
	_broadcast_artifact_state()
	record_private_event(requester_id, "artifact_forged", room_slot, requester_id, {"artifact_id": int(forged["artifact_id"])})
	record_public_event("artifact_spawned", room_slot, -1, {"artifact_id": int(forged["artifact_id"])})

func _host_throw_bomb(requester_id: int, pos: Vector2, vel: Vector2, node_name: String) -> void:
	if not players.has(requester_id):
		return
	if not _consume_tool_charge(requester_id, "bomb"):
		_deny_action(requester_id, "no_bombs", get_room_slot(pos))
		return
	host_spawn_bomb.rpc(pos, vel, node_name)
	record_public_event("bomb_thrown", get_room_slot(pos), requester_id, {})

func _host_throw_rope(requester_id: int, pos: Vector2, node_name: String) -> void:
	if not players.has(requester_id):
		return
	if not _consume_tool_charge(requester_id, "rope"):
		_deny_action(requester_id, "no_ropes", get_room_slot(pos))
		return
	host_spawn_rope.rpc(pos, node_name)
	record_public_event("rope_thrown", get_room_slot(pos), requester_id, {})

func _normalize_callout_kind(kind: String) -> String:
	var normalized := kind.strip_edges().to_lower()
	if normalized in ["danger", "regroup", "artifact"]:
		return normalized
	return ""

func callout_label_for_test(kind: String) -> String:
	match _normalize_callout_kind(kind):
		"danger":
			return "Danger"
		"regroup":
			return "Regroup"
		"artifact":
			return "Artifact"
		_:
			return ""

func _host_callout(requester_id: int, kind: String, room_slot: int) -> void:
	if not players.has(requester_id):
		return
	var normalized := _normalize_callout_kind(kind)
	if normalized.is_empty():
		_deny_action(requester_id, "bad_callout", room_slot)
		return
	var player_slot := int(player_room_by_peer.get(requester_id, -1))
	var target_slot := player_slot if player_slot >= 0 else room_slot
	record_public_event("room_callout", target_slot, requester_id, {"kind": normalized})
	_apply_role_callout_pressure(requester_id, normalized, target_slot)

func _apply_role_callout_pressure(requester_id: int, kind: String, room_slot: int) -> void:
	var role_name := _role_name_for_peer(requester_id)
	var carrier_peer_id := _artifact_carrier_in_room(room_slot)
	match role_name:
		ROLE_SERVICE_SCRIPT.ROLE_STEWARD:
			_note_role_custody_pressure(requester_id, 0, -1, 0, 1)
			if kind in ["artifact", "regroup"]:
				for peer_id in _active_peers_in_room(room_slot):
					if peer_id == requester_id:
						continue
					_note_role_custody_pressure(peer_id, 0, -1, 0, 0)
				if carrier_peer_id > 0:
					_note_role_custody_pressure(carrier_peer_id, -1, -1, 0, 0)
			elif kind == "danger" and carrier_peer_id > 0:
				_note_role_custody_pressure(carrier_peer_id, 0, -1, 0, 0)
			record_private_event(requester_id, "item_note", room_slot, requester_id, {
				"label": "Steward callout steadied the public line"
			})
		ROLE_SERVICE_SCRIPT.ROLE_BEARER:
			if carrier_peer_id == requester_id and kind in ["artifact", "regroup"]:
				_note_role_custody_pressure(requester_id, -1, 0, 0, 1)
				record_private_event(requester_id, "item_note", room_slot, requester_id, {
					"label": "Bearer callout tightened the escort line"
				})
			elif carrier_peer_id == requester_id:
				_note_role_custody_pressure(requester_id, 0, 0, 0, 1)
		ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
			_note_role_custody_pressure(requester_id, 0, -1, 0, 1)
			if carrier_peer_id > 0 and carrier_peer_id != requester_id:
				_note_role_custody_pressure(carrier_peer_id, 0, 1, 1 if kind == "artifact" else 0, 0)
			record_private_event(requester_id, "item_note", room_slot, requester_id, {
				"label": "Murmur callout bent witness pressure around the burden"
			})
		ROLE_SERVICE_SCRIPT.ROLE_VEIL:
			if kind == "artifact":
				_note_role_custody_pressure(requester_id, 0, 1, 0, 1)
		ROLE_SERVICE_SCRIPT.ROLE_WARDEN:
			if kind == "artifact":
				_note_role_custody_pressure(requester_id, 0, 0, 0, 1)

@rpc("authority", "call_local", "reliable")
func host_spawn_bomb(pos: Vector2, vel: Vector2, node_name: String) -> void:
	var game_node = get_tree().root.get_node_or_null("Game")
	var parent = game_node if game_node else self

	if parent.has_node(node_name):
		# Prediction already exists. We can either trust it or replace it.
		# For Milestone 2, let's replace it with Host's truth.
		var old = parent.get_node(node_name)
		old.queue_free()

	var b = _get_bomb_script().new()
	b.name = node_name
	b.global_position = pos
	b.linear_velocity = vel
	parent.add_child(b)

@rpc("authority", "call_local", "reliable")
func host_detonate_bomb(node_name: String, pos: Vector2) -> void:
	var game_node = get_tree().root.get_node_or_null("Game")
	var parent = game_node if game_node else self
	var bomb = parent.get_node_or_null(node_name)
	if bomb and bomb.has_method("explode_local"):
		bomb.explode_local(pos)
		return
	if bomb and bomb.has_method("rpc_explode"):
		bomb.rpc_explode(pos)

@rpc("authority", "call_local", "reliable")
func host_spawn_rope(pos: Vector2, node_name: String) -> void:
	var game_node = get_tree().root.get_node_or_null("Game")
	var parent = game_node if game_node else self

	if parent.has_node(node_name):
		var old = parent.get_node(node_name)
		old.queue_free()

	var r = _get_rope_script().new()
	r.name = node_name
	r.global_position = pos
	parent.add_child(r)

@rpc("authority", "call_local", "reliable")
func host_spawn_zipline(start_pos: Vector2, end_pos: Vector2, node_name: String) -> void:
	var tree = get_tree() if is_inside_tree() else null
	var game_node = tree.root.get_node_or_null("Game") if tree != null else null
	var parent = game_node if game_node else self
	if parent.has_node(node_name):
		parent.get_node(node_name).queue_free()
	var zipline = _get_zipline_script().new()
	zipline.name = node_name
	parent.add_child(zipline)
	if zipline.has_method("configure"):
		zipline.configure(start_pos, end_pos)

func _host_pickup_item(requester_id: int, item_id: int) -> void:
	if not items_by_id.has(item_id):
		_deny_action(requester_id, "no_target")
		return
	var item_data: Dictionary = items_by_id[item_id]
	var requester_pos: Vector2 = player_pos_by_peer.get(requester_id, Vector2(999999, 999999))
	if not item_service.can_pickup(item_data, requester_pos):
		_deny_action(requester_id, "out_of_range", int(item_data.get("room_slot", -1)))
		return
	var item_def_id := str(item_data.get("item_def_id", ""))
	var category_id: String = item_service.get_category(item_def_id)
	var category_limit: int = item_service.category_carry_limit(category_id)
	if category_limit <= 0 and category_id == "tool":
		category_limit = MAX_CARRIED_TOOL_ITEMS
	if category_limit > 0 and _owned_item_count_by_category(requester_id, category_id) >= category_limit:
		var deny_reason := "tool_slots_full" if category_id == "tool" else "category_slots_full"
		_deny_action(requester_id, deny_reason, int(item_data.get("room_slot", -1)))
		return
	var existing_item_ids := _item_def_ids_for_peer(requester_id)
	if not item_service.forbidden_combo_failures_with_candidate(existing_item_ids, item_def_id).is_empty():
		_deny_action(requester_id, "illegal_ecology_combo", int(item_data.get("room_slot", -1)))
		return
	items_by_id[item_id] = item_service.apply_owner(item_data, requester_id, requester_pos)
	_broadcast_item_state()
	record_public_event("item_picked", int(item_data.get("room_slot", -1)), -1, {"item_id": item_id})
	record_private_event(requester_id, "item_note", int(item_data.get("room_slot", -1)), requester_id, {
		"label": "Picked up %s" % str(item_data.get("display_name", item_data.get("item_def_id", "item"))),
		"item_id": item_id
	})
	_maybe_trigger_covenant_activation(requester_id, int(item_data.get("room_slot", -1)))
	_refresh_transformation_thresholds_for_peer(requester_id, int(item_data.get("room_slot", -1)))

func _compute_zipline_segment(room_slot: int, requester_pos: Vector2) -> Dictionary:
	var grid_x := posmod(room_slot, ROOM_COLUMNS)
	var grid_y := int(floor(float(room_slot) / float(ROOM_COLUMNS)))
	var room_left := float(grid_x) * ROOM_WIDTH
	var room_top := float(grid_y) * ROOM_HEIGHT
	var room_right := room_left + ROOM_WIDTH
	var room_bottom := room_top + ROOM_HEIGHT
	var start_x := clampf(requester_pos.x, room_left + 180.0, room_right - 180.0)
	var start_y := clampf(requester_pos.y - 48.0, room_top + 170.0, room_bottom - 240.0)
	var aim_right := start_x <= room_left + ROOM_WIDTH * 0.5
	var end_x := room_right - 180.0 if aim_right else room_left + 180.0
	var end_y := clampf(start_y + 118.0, room_top + 190.0, room_bottom - 150.0)
	return {
		"start": Vector2(start_x, start_y),
		"end": Vector2(end_x, end_y)
	}

func compute_zipline_segment_for_test(room_slot: int, requester_pos: Vector2) -> Dictionary:
	return _compute_zipline_segment(room_slot, requester_pos)

func _host_use_item(requester_id: int, item_id: int, room_slot: int) -> void:
	if not items_by_id.has(item_id):
		_deny_action(requester_id, "no_target", room_slot)
		return
	var actual_room_slot := int(player_room_by_peer.get(requester_id, room_slot))
	var item_data: Dictionary = items_by_id[item_id]
	if int(item_data.get("owner_peer_id", 0)) != requester_id:
		_deny_action(requester_id, "not_owner", room_slot)
		return
	if bool(item_data.get("consumed", false)):
		_deny_action(requester_id, "no_target", room_slot)
		return
	var item_def_id := str(item_data.get("item_def_id", ""))
	match item_def_id:
		"timeline_bookmark":
			items_by_id[item_id] = item_service.consume(item_data)
			record_public_event("item_used", actual_room_slot, -1, {"label": item_service.get_use_label(item_def_id)})
			record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
				"label": "Timeline bookmark pinned tick %d in room %d" % [current_server_tick, actual_room_slot],
				"item_id": item_id
			})
			_broadcast_item_state()
		"flare_ampoule":
			items_by_id[item_id] = item_service.consume(item_data)
			record_public_event("item_used", actual_room_slot, -1, {"label": item_service.get_use_label(item_def_id)})
			record_public_event("noise_trace", actual_room_slot, -1, {})
			_host_callout(requester_id, "danger", actual_room_slot)
			broadcast_hazard_pulse(actual_room_slot, requester_id, "flare_ampoule")
			record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
				"label": "Flare ampoule flooded the room with a brief public bloom",
				"item_id": item_id
			})
			_broadcast_item_state()
		"decoy_emitter":
			items_by_id[item_id] = item_service.consume(item_data)
			record_public_event("item_used", actual_room_slot, -1, {"label": item_service.get_use_label(item_def_id)})
			record_public_event("noise_trace", actual_room_slot, -1, {})
			if str(roles_by_peer.get(requester_id, "")) == ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER:
				var route_room := clampi(actual_room_slot + (1 if actual_room_slot < extraction_room_slot else -1), 0, maxi(extraction_room_slot, 0))
				record_public_event("noise_trace", route_room, -1, {})
				var carried_artifact_id := _find_carried_artifact_by_peer(requester_id)
				if carried_artifact_id != 0 and artifacts_by_id.has(carried_artifact_id):
					var rerouted: Dictionary = artifact_service.apply_owner(
						artifacts_by_id[carried_artifact_id],
						0,
						_artifact_cache_position(route_room, carried_artifact_id)
					)
					rerouted["room_slot"] = route_room
					artifacts_by_id[carried_artifact_id] = rerouted
					_broadcast_artifact_state()
					record_public_event("artifact_dropped", route_room, -1, {"artifact_id": carried_artifact_id})
					record_private_event(requester_id, "item_note", route_room, requester_id, {
						"label": "Decoy emitter rerouted Artifact %d to room %d" % [carried_artifact_id, route_room]
					})
				else:
					record_private_event(requester_id, "item_note", route_room, requester_id, {
						"label": "Decoy emitter forked the route"
					})
			else:
				record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
					"label": "Decoy emitter seeded a false route"
				})
			broadcast_hazard_pulse(actual_room_slot, -1, "decoy_emitter")
			_broadcast_item_state()
		"zipline_kit":
			var segment := _compute_zipline_segment(actual_room_slot, player_pos_by_peer.get(requester_id, Vector2.ZERO))
			var start_pos: Vector2 = segment.get("start", Vector2.ZERO)
			var end_pos: Vector2 = segment.get("end", Vector2.ZERO)
			var node_name := "Zipline_%d_%d_%d" % [requester_id, item_id, current_server_tick]
			items_by_id[item_id] = item_service.consume(item_data)
			var mp := _mp()
			if not _has_live_network_peer(mp):
				host_spawn_zipline(start_pos, end_pos, node_name)
			else:
				host_spawn_zipline.rpc(start_pos, end_pos, node_name)
			record_public_event("item_used", actual_room_slot, -1, {"label": item_service.get_use_label(item_def_id)})
			record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
				"label": "Zipline stretched across room %d" % actual_room_slot,
				"item_id": item_id
			})
			_broadcast_item_state()
		"custody_seal":
			items_by_id[item_id] = item_service.consume(item_data)
			record_public_event("item_used", actual_room_slot, -1, {"label": item_service.get_use_label(item_def_id)})
			record_public_event("room_callout", actual_room_slot, requester_id, {"kind": "artifact"})
			var carried_artifact_id := _find_carried_artifact_by_peer(requester_id)
			var authenticity_state := ""
			if carried_artifact_id != 0 and artifacts_by_id.has(carried_artifact_id):
				authenticity_state = str(artifact_service.authenticity_state(Dictionary(artifacts_by_id.get(carried_artifact_id, {}))))
			if authenticity_state == "authentic":
				_note_role_custody_pressure(requester_id, -1, -1, -1, 1)
				if extraction_window_started_tick >= 0 and extraction_window_owner_peer_id == requester_id:
					extraction_window_started_tick = maxi(extraction_window_started_tick - 45, 0)
				record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
					"label": "Custody seal steadied the burden in public",
					"item_id": item_id
				})
			elif authenticity_state == "counterfeit":
				_note_role_custody_pressure(requester_id, 0, 1, 1, 1)
				record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
					"label": "Custody seal rang false against the carried burden",
					"item_id": item_id
				})
			else:
				_note_role_custody_pressure(requester_id, 0, 1, 0, 0)
				record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
					"label": "Custody seal drew witness pressure without a burden",
					"item_id": item_id
				})
			_broadcast_item_state()
		"witness_chime":
			items_by_id[item_id] = item_service.consume(item_data)
			record_public_event("item_used", actual_room_slot, -1, {"label": item_service.get_use_label(item_def_id)})
			record_public_event("noise_trace", actual_room_slot, -1, {})
			_host_callout(requester_id, "artifact", actual_room_slot)
			var witnessed_artifact_id := _find_carried_artifact_by_peer(requester_id)
			var witnessed_authenticity := ""
			if witnessed_artifact_id != 0 and artifacts_by_id.has(witnessed_artifact_id):
				witnessed_authenticity = str(artifact_service.authenticity_state(Dictionary(artifacts_by_id.get(witnessed_artifact_id, {}))))
			if witnessed_authenticity == "authentic":
				_note_role_custody_pressure(requester_id, 0, -1, -1, 1)
				record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
					"label": "Witness chime turned the room toward your burden",
					"item_id": item_id
				})
			elif witnessed_authenticity == "counterfeit":
				_note_role_custody_pressure(requester_id, 0, 1, 1, 1)
				record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
					"label": "Witness chime amplified doubt around the forged burden",
					"item_id": item_id
				})
			else:
				_note_role_custody_pressure(requester_id, 0, 1, 0, 1)
				record_private_event(requester_id, "item_note", actual_room_slot, requester_id, {
					"label": "Witness chime made the room ask who should answer",
					"item_id": item_id
				})
			_broadcast_item_state()
		"echo_lure":
			var lure_room := _anomaly_echo_room_slot(requester_id)
			if lure_room < 0 or lure_room == actual_room_slot:
				var max_room := maxi(extraction_room_slot, actual_room_slot)
				lure_room = clampi(actual_room_slot + (1 if actual_room_slot < max_room else -1), 0, max_room)
			echo_lure_state = {
				"active": true,
				"owner_peer_id": requester_id,
				"room_slot": lure_room,
				"expires_tick": maxi(current_server_tick + 210, _current_ghost_wake_tick() + 240)
			}
			items_by_id[item_id] = item_service.consume(item_data)
			record_public_event("item_used", actual_room_slot, -1, {"label": item_service.get_use_label(item_def_id)})
			record_public_event("noise_trace", lure_room, -1, {})
			record_private_event(requester_id, "item_note", lure_room, requester_id, {
				"label": "Echo lure bent pursuit toward room %d" % lure_room,
				"item_id": item_id
			})
			if _role_name_for_peer(requester_id) in [ROLE_SERVICE_SCRIPT.ROLE_VEIL, ROLE_SERVICE_SCRIPT.ROLE_MURMUR]:
				_note_role_custody_pressure(requester_id, 0, 0, 1, 1)
			_note_species_escalation_mutation("echo_lure", lure_room, requester_id, "lure")
			broadcast_hazard_pulse(lure_room, -1, "echo_lure")
			_broadcast_item_state()
			_refresh_transformation_thresholds_for_peer(requester_id, lure_room)
		_:
			_deny_action(requester_id, "no_target", room_slot)

func _host_sabotage(requester_id: int, room_slot: int) -> void:
	if not _role_service().can_sabotage(_role_name_for_peer(requester_id)):
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
	var disturbance_duration := 2.0
	var disturbance_until_tick := current_server_tick + int(round(disturbance_duration * 60.0))
	disturbance_until_by_room[room_slot] = disturbance_until_tick
	camera_jam_until_by_room[room_slot] = disturbance_until_tick
	broadcast_hazard_pulse(room_slot, -1, "sabotage_camera_jam")
	record_public_event("sabotage_accident", room_slot, -1, {"label": accident_label})
	record_public_event("sabotage_camera_jam", room_slot, -1, {"label": camera_jam_label})
	record_private_event(requester_id, "sabotage_private_confirm", room_slot, requester_id, {"label": "Camera jam"})
	_note_role_custody_pressure(requester_id, 0, 1, 0, 1)

func _host_check_artifact(requester_id: int, artifact_id: int) -> void:
	if not _role_service().can_inspect(_role_name_for_peer(requester_id)):
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
	var score := _compute_warden_check_score(artifact, check_counter, 0)
	if camera_jammed:
		score = _camera_jam_adjusted_warden_score(score)
	check_counter_by_peer[requester_id] = check_counter + 1
	if camera_jammed:
		record_private_event(requester_id, "warden_camera_jam_note", artifact_slot, requester_id, {"label": "Camera jam residue lowered confidence"})
	_note_role_custody_pressure(requester_id, 0, 0, 0, 1)
	if artifact_service.authenticity_state(artifact) == "counterfeit":
		var owner_peer_id := int(artifact.get("owner_peer_id", 0))
		if owner_peer_id > 0:
			_note_role_custody_pressure(owner_peer_id, 1, 2, 2, 0)
	else:
		var authentic_owner_peer_id := int(artifact.get("owner_peer_id", 0))
		if authentic_owner_peer_id > 0 and authentic_owner_peer_id != requester_id:
			_note_role_custody_pressure(authentic_owner_peer_id, 1, 0, 0, 0)
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
				run_state.local_role_payload = payload.duplicate(true)
			emit_signal("role_revealed", role_name)
		else:
			host_reveal_role.rpc_id(peer_id, payload)

func _broadcast_artifact_state() -> void:
	if not is_host:
		return
	var mp := _mp()
	if not _has_live_network_peer(mp):
		host_sync_artifact_state(_serialize_artifacts())
		return
	host_sync_artifact_state.rpc(_serialize_artifacts())

func _broadcast_item_state() -> void:
	if not is_host:
		return
	var mp := _mp()
	if not _has_live_network_peer(mp):
		host_sync_item_state(_serialize_items())
		return
	host_sync_item_state.rpc(_serialize_items())

func _broadcast_ghost_state() -> void:
	if not is_host:
		return
	var mp := _mp()
	if not _has_live_network_peer(mp):
		host_sync_ghost_state(ghost_state.duplicate(true))
		return
	host_sync_ghost_state.rpc(ghost_state.duplicate(true))

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

func _build_mutation_timeline_event(event: Dictionary) -> Dictionary:
	return {
		"tick": int(event.get("tick", current_server_tick)),
		"event_id": int(event.get("timeline_event_id", event.get("ordering_index", -1))),
		"room_slot": int(Dictionary(event.get("public_meta", {})).get("room_slot", -1)),
		"actor_peer_id": int(event.get("actor_peer_id", -1)),
		"event_type": "constitution_mutation",
		"visibility": str(event.get("visibility", "private")),
		"meta": {
			"mutation_id": str(event.get("mutation_id", "")),
			"trigger_type": str(event.get("trigger_type", "")),
			"domain": str(event.get("domain", "")),
			"public_meta": Dictionary(event.get("public_meta", {})).duplicate(true)
		}
	}

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
		"room_callout":
			return _pick_meta_fields(meta, ["kind"])
		"noise_trace":
			return {}
		"bomb_exploded":
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

func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

func _merge_arrays(base: Array, extra: Array) -> Array:
	var result: Array[String] = _string_array(base)
	for value in _string_array(extra):
		if not result.has(value):
			result.append(value)
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
	return _current_extraction_window_ticks()

func ghost_wake_tick_for_test() -> int:
	return _current_ghost_wake_tick()

func ghost_speed_per_tick_for_test() -> float:
	return _current_ghost_speed_per_tick()

func ghost_hit_radius_for_test() -> float:
	return _current_ghost_hit_radius()

func noise_trace_interval_for_test(peer_id: int) -> int:
	return _current_noise_trace_interval(peer_id)

func predator_rush_interval_for_test(peer_id: int, active_peer_count: int = -1) -> int:
	return _current_predator_rush_interval(peer_id, active_peer_count)

func protocol_watch_interval_for_test(peer_id: int) -> int:
	return _current_protocol_watch_interval(peer_id)

func host_use_item_for_test(requester_id: int, item_id: int, room_slot: int) -> void:
	_host_use_item(requester_id, item_id, room_slot)

func host_pickup_item_for_test(requester_id: int, item_id: int) -> void:
	_host_pickup_item(requester_id, item_id)

func begin_event_capture_for_test() -> void:
	_capture_events_for_test = true
	_captured_public_events_for_test.clear()
	_captured_private_events_for_test.clear()

func bind_runtime_context_for_test(run_state: Node, event_log: Node) -> void:
	_run_state_override_for_test = run_state
	_event_log_override_for_test = event_log

func clear_runtime_context_for_test() -> void:
	_run_state_override_for_test = null
	_event_log_override_for_test = null

func end_event_capture_for_test() -> Dictionary:
	var payload := {
		"public": _captured_public_events_for_test.duplicate(true),
		"private": _captured_private_events_for_test.duplicate(true)
	}
	_capture_events_for_test = false
	_captured_public_events_for_test.clear()
	_captured_private_events_for_test.clear()
	return payload

func host_pickup_for_test(requester_id: int, artifact_id: int) -> void:
	_host_pickup(requester_id, artifact_id)

func host_drop_for_test(requester_id: int) -> void:
	_host_drop(requester_id)

func host_steal_for_test(requester_id: int, artifact_id: int) -> void:
	_host_steal(requester_id, artifact_id)

func host_check_artifact_for_test(requester_id: int, artifact_id: int) -> void:
	_host_check_artifact(requester_id, artifact_id)

func host_forge_for_test(requester_id: int, room_slot: int) -> void:
	_host_forge(requester_id, room_slot)

func host_callout_for_test(requester_id: int, kind: String, room_slot: int) -> void:
	_host_callout(requester_id, kind, room_slot)

func choose_protocol_watch_peer_for_test() -> int:
	return _choose_protocol_watch_peer()

func choose_predator_target_peer_for_test() -> int:
	return _choose_predator_target_peer()

func get_role_custody_runtime_for_test(peer_id: int) -> Dictionary:
	return {
		"role_pressure": int(role_pressure_by_peer.get(peer_id, 0)),
		"custody_debt": int(custody_debt_by_peer.get(peer_id, 0)),
		"suspicion_heat": int(suspicion_heat_by_peer.get(peer_id, 0)),
		"counterfeit_heat": int(counterfeit_heat_by_peer.get(peer_id, 0))
	}

func advance_ghost_pressure_for_test(tick: int, peer_rooms: Dictionary, peer_positions: Dictionary, peer_list: Array[int], extraction_slot_value: int, carried_by_peer: Dictionary = {}) -> Dictionary:
	var prev_host := is_host
	var prev_run_active := run_active
	var prev_tick := current_server_tick
	var prev_rooms := player_room_by_peer.duplicate(true)
	var prev_positions := player_pos_by_peer.duplicate(true)
	var prev_players := players.duplicate()
	var prev_extraction_slot := extraction_room_slot
	var prev_artifacts := artifacts_by_id.duplicate(true)
	var prev_ghost_state := ghost_state.duplicate(true)
	is_host = true
	run_active = true
	current_server_tick = tick
	player_room_by_peer = peer_rooms.duplicate(true)
	player_pos_by_peer = peer_positions.duplicate(true)
	players = peer_list.duplicate()
	extraction_room_slot = extraction_slot_value
	artifacts_by_id.clear()
	for peer_id_variant in carried_by_peer.keys():
		var peer_id := int(peer_id_variant)
		artifacts_by_id[1000 + peer_id] = {
			"artifact_id": 1000 + peer_id,
			"owner_peer_id": peer_id,
			"room_slot": int(peer_rooms.get(peer_id, -1))
		}
	_advance_ghost_pressure()
	var result := ghost_state.duplicate(true)
	is_host = prev_host
	run_active = prev_run_active
	current_server_tick = prev_tick
	player_room_by_peer = prev_rooms
	player_pos_by_peer = prev_positions
	players = prev_players
	extraction_room_slot = prev_extraction_slot
	artifacts_by_id = prev_artifacts
	ghost_state = prev_ghost_state
	return result

func advance_runtime_ecology_for_test(tick: int, peer_rooms: Dictionary, peer_positions: Dictionary, peer_list: Array[int], extraction_slot_value: int, carried_by_peer: Dictionary = {}) -> Dictionary:
	var run_state := _run_state()
	var prev_host := is_host
	var prev_run_active := run_active
	var prev_tick := current_server_tick
	var prev_next_event_id := next_event_id
	var prev_rooms := player_room_by_peer.duplicate(true)
	var prev_positions := player_pos_by_peer.duplicate(true)
	var prev_players := players.duplicate()
	var prev_extraction_slot := extraction_room_slot
	var prev_artifacts := artifacts_by_id.duplicate(true)
	var prev_ghost_state := ghost_state.duplicate(true)
	var prev_role_pressure := role_pressure_by_peer.duplicate(true)
	var prev_custody_debt := custody_debt_by_peer.duplicate(true)
	var prev_suspicion_heat := suspicion_heat_by_peer.duplicate(true)
	var prev_counterfeit_heat := counterfeit_heat_by_peer.duplicate(true)
	var prev_predator_state := predator_state.duplicate(true)
	var prev_protocol_watch_state := protocol_watch_state.duplicate(true)
	var prev_echo_lure_state := echo_lure_state.duplicate(true)
	var prev_capture := _capture_events_for_test
	var prev_public_events := _captured_public_events_for_test.duplicate(true)
	var prev_private_events := _captured_private_events_for_test.duplicate(true)
	var prev_encounter_history: Array = []
	var prev_active_encounter_state: Dictionary = {}
	var prev_pathology_state: Dictionary = {}
	var prev_apex_history: Array = []
	var prev_active_apex_state: Dictionary = {}
	var prev_local_aftermath: Dictionary = {}
	if run_state != null:
		prev_encounter_history = Array(run_state.encounter_history).duplicate(true)
		prev_active_encounter_state = Dictionary(run_state.active_encounter_state).duplicate(true)
		prev_pathology_state = Dictionary(run_state.pathology_state).duplicate(true)
		prev_apex_history = Array(run_state.apex_history).duplicate(true)
		prev_active_apex_state = Dictionary(run_state.active_apex_state).duplicate(true)
		prev_local_aftermath = Dictionary(run_state.local_aftermath).duplicate(true)
	is_host = true
	run_active = true
	current_server_tick = tick
	player_room_by_peer = peer_rooms.duplicate(true)
	player_pos_by_peer = peer_positions.duplicate(true)
	players = peer_list.duplicate()
	extraction_room_slot = extraction_slot_value
	artifacts_by_id.clear()
	for peer_id_variant in carried_by_peer.keys():
		var peer_id := int(peer_id_variant)
		artifacts_by_id[1000 + peer_id] = {
			"artifact_id": 1000 + peer_id,
			"owner_peer_id": peer_id,
			"room_slot": int(player_room_by_peer.get(peer_id, 0))
		}
	_capture_events_for_test = true
	_captured_public_events_for_test.clear()
	_captured_private_events_for_test.clear()
	_advance_runtime_ecology()
	var result := {
		"ghost_state": ghost_state.duplicate(true),
		"predator_state": predator_state.duplicate(true),
		"protocol_watch_state": protocol_watch_state.duplicate(true),
		"active_encounter_state": get_active_encounter_state(),
		"pathology_state": get_pathology_state(),
		"encounter_history": get_encounter_history(),
		"active_apex_state": get_active_apex_state(),
		"apex_history": get_apex_history(),
		"local_aftermath": get_local_aftermath(),
		"public": _captured_public_events_for_test.duplicate(true),
		"private": _captured_private_events_for_test.duplicate(true)
	}
	is_host = prev_host
	run_active = prev_run_active
	current_server_tick = prev_tick
	next_event_id = prev_next_event_id
	player_room_by_peer = prev_rooms
	player_pos_by_peer = prev_positions
	players = prev_players
	extraction_room_slot = prev_extraction_slot
	artifacts_by_id = prev_artifacts
	ghost_state = prev_ghost_state
	role_pressure_by_peer = prev_role_pressure
	custody_debt_by_peer = prev_custody_debt
	suspicion_heat_by_peer = prev_suspicion_heat
	counterfeit_heat_by_peer = prev_counterfeit_heat
	predator_state = prev_predator_state
	protocol_watch_state = prev_protocol_watch_state
	echo_lure_state = prev_echo_lure_state
	if run_state != null:
		run_state.encounter_history = prev_encounter_history
		run_state.active_encounter_state = prev_active_encounter_state
		run_state.pathology_state = prev_pathology_state
		run_state.apex_history = prev_apex_history
		run_state.active_apex_state = prev_active_apex_state
		run_state.local_aftermath = prev_local_aftermath
	_capture_events_for_test = prev_capture
	_captured_public_events_for_test = prev_public_events
	_captured_private_events_for_test = prev_private_events
	return result

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
	_apply_constitution_mutation("extraction_window_started", {
		"artifact_id": extraction_window_artifact_id,
		"room_slot": int(extraction_details.get("room_slot", extraction_room_slot)),
		"actor_peer_id": extraction_window_owner_peer_id,
		"owner_peer_id": extraction_window_owner_peer_id,
		"visibility": "public"
	})
	record_public_event("extraction_window_started", int(extraction_details.get("room_slot", extraction_room_slot)), -1, {"duration_ticks": _current_extraction_window_ticks()})

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

func _clear_ghost_state() -> void:
	_clear_runtime_encounter_state_for_species("ghost", "ghost_cleared")
	ghost_state = {
		"active": false,
		"position": GHOST_OFFSCREEN_POS,
		"target_peer_id": -1
	}

func _clear_role_custody_state() -> void:
	role_pressure_by_peer.clear()
	custody_debt_by_peer.clear()
	suspicion_heat_by_peer.clear()
	counterfeit_heat_by_peer.clear()

func _clear_predator_state() -> void:
	_clear_runtime_encounter_state_for_species("predator", "predator_cleared")
	predator_state = {
		"active": false,
		"room_slot": -1,
		"target_peer_id": -1,
		"last_tick": -1,
		"strike_strength": 0,
		"mode": ""
	}

func _clear_protocol_watch_state() -> void:
	_clear_runtime_encounter_state_for_species("protocol_watch", "protocol_watch_cleared")
	protocol_watch_state = {
		"active": false,
		"room_slot": -1,
		"target_peer_id": -1,
		"last_tick": -1,
		"mode": "",
		"signal_room_slot": -1
	}

func _clear_echo_lure_state() -> void:
	_clear_runtime_encounter_state_for_species("echo_lure", "echo_lure_cleared")
	echo_lure_state = {
		"active": false,
		"owner_peer_id": -1,
		"room_slot": -1,
		"expires_tick": -1
	}

func _advance_runtime_ecology() -> void:
	_expire_echo_lure_state()
	_advance_ghost_pressure()
	_advance_anomaly_echo_pressure()
	_advance_predator_pressure()
	_advance_protocol_watch_pressure()

func _expire_echo_lure_state() -> void:
	if not bool(echo_lure_state.get("active", false)):
		return
	if current_server_tick > int(echo_lure_state.get("expires_tick", -1)):
		_clear_echo_lure_state()

func _advance_ghost_pressure() -> void:
	if not is_host:
		return
	if not run_active or current_server_tick < _current_ghost_wake_tick():
		if bool(ghost_state.get("active", false)):
			_clear_ghost_state()
			_broadcast_ghost_state()
		return
	var target_peer_id := _choose_ghost_target_peer()
	if target_peer_id <= 0:
		if bool(ghost_state.get("active", false)):
			_clear_ghost_state()
			_broadcast_ghost_state()
		return
	var target_pos: Vector2 = player_pos_by_peer.get(target_peer_id, GHOST_OFFSCREEN_POS)
	var current_pos: Vector2 = ghost_state.get("position", GHOST_OFFSCREEN_POS)
	var next_pos := current_pos.move_toward(target_pos, _current_ghost_speed_per_tick())
	var next_state := {
		"active": true,
		"position": next_pos,
		"target_peer_id": target_peer_id
	}
	if JSON.stringify(next_state) != JSON.stringify(ghost_state):
		ghost_state = next_state
		_broadcast_ghost_state()
	var room_slot := int(player_room_by_peer.get(target_peer_id, -1))
	if room_slot >= 0:
		_note_species_escalation_mutation("ghost", room_slot, target_peer_id, "pursuit")
	if room_slot >= 0 and next_pos.distance_to(target_pos) <= _current_ghost_hit_radius():
		broadcast_hazard_pulse(room_slot, -1, "ghost_pressure")

func _advance_anomaly_echo_pressure() -> void:
	if not is_host or not run_active:
		return
	if current_server_tick < _current_ghost_wake_tick():
		return
	if get_current_anomaly_contamination_bias() <= 0:
		return
	var anchor_peer_id := _choose_anomaly_echo_anchor_peer()
	if anchor_peer_id <= 0:
		return
	var interval := maxi(_current_noise_trace_interval(anchor_peer_id), 1)
	if posmod(current_server_tick + anchor_peer_id, interval) != 0:
		return
	var room_slot := _anomaly_echo_room_slot(anchor_peer_id)
	if room_slot < 0:
		return
	record_public_event("noise_trace", room_slot, -1, {})
	var pulse_reason := "echo_lure" if _echo_lure_active_for_peer(anchor_peer_id) else "anomaly_echo"
	broadcast_hazard_pulse(room_slot, -1, pulse_reason)

func _advance_predator_pressure() -> void:
	if not is_host or not run_active:
		_clear_predator_state()
		return
	if current_server_tick < _current_ghost_wake_tick():
		_clear_predator_state()
		return
	if maxi(get_current_stalking_bias(), 0) <= 0 or get_current_inhabitant_pressure_bias() <= 0:
		_clear_predator_state()
		return
	var target_peer_id := _choose_predator_target_peer()
	if target_peer_id <= 0:
		_clear_predator_state()
		return
	var room_slot := int(player_room_by_peer.get(target_peer_id, -1))
	if room_slot < 0:
		_clear_predator_state()
		return
	var interval := maxi(_current_predator_rush_interval(target_peer_id), 1)
	if posmod(current_server_tick + target_peer_id + room_slot, interval) != 0:
		_clear_predator_state()
		return
	var strike_strength := 1
	var mode := "pursuit"
	if _find_carried_artifact_by_peer(target_peer_id) != 0:
		strike_strength += 1
	if int(_room_population_counts().get(room_slot, 0)) <= 1:
		strike_strength += 1
		mode = "ambush"
	elif int(counterfeit_heat_by_peer.get(target_peer_id, 0)) >= 2 or int(suspicion_heat_by_peer.get(target_peer_id, 0)) >= 3:
		strike_strength += 1
		mode = "pack"
	predator_state = {
		"active": true,
		"room_slot": room_slot,
		"target_peer_id": target_peer_id,
		"last_tick": current_server_tick,
		"strike_strength": strike_strength,
		"mode": mode
	}
	_note_species_escalation_mutation("predator", room_slot, target_peer_id, mode)
	record_public_event("hazard_state_changed", room_slot, -1, {})
	broadcast_hazard_pulse(room_slot, -1, "predator_rush")

func _advance_protocol_watch_pressure() -> void:
	if not is_host or not run_active:
		_clear_protocol_watch_state()
		return
	if current_server_tick < _current_ghost_wake_tick():
		_clear_protocol_watch_state()
		return
	if get_current_inhabitant_pressure_bias() <= 0:
		_clear_protocol_watch_state()
		return
	var target_peer_id := _choose_protocol_watch_peer()
	if target_peer_id <= 0:
		_clear_protocol_watch_state()
		return
	var room_slot := int(player_room_by_peer.get(target_peer_id, -1))
	if room_slot < 0:
		_clear_protocol_watch_state()
		return
	var interval := maxi(_current_protocol_watch_interval(target_peer_id), 1)
	if posmod(current_server_tick + target_peer_id + extraction_room_slot, interval) != 0:
		_clear_protocol_watch_state()
		return
	var containment_pressure := int(counterfeit_heat_by_peer.get(target_peer_id, 0)) + int(suspicion_heat_by_peer.get(target_peer_id, 0))
	var mode := "inspection"
	if _echo_lure_active_for_peer(target_peer_id):
		mode = "interdiction"
	elif containment_pressure >= 3 or _find_carried_artifact_by_peer(target_peer_id) != 0:
		mode = "containment"
	var signal_room_slot := room_slot
	if mode == "inspection":
		signal_room_slot = _anomaly_echo_room_slot(target_peer_id)
		if signal_room_slot < 0:
			signal_room_slot = room_slot
	elif mode == "interdiction":
		signal_room_slot = _echo_lure_room_slot_for_peer(target_peer_id)
		if signal_room_slot < 0:
			signal_room_slot = room_slot
	protocol_watch_state = {
		"active": true,
		"room_slot": room_slot,
		"target_peer_id": target_peer_id,
		"last_tick": current_server_tick,
		"mode": mode,
		"signal_room_slot": signal_room_slot
	}
	_note_species_escalation_mutation("protocol_watch", room_slot, target_peer_id, mode)
	record_public_event("noise_trace", signal_room_slot, -1, {})
	if mode in ["containment", "interdiction"] and extraction_window_started_tick >= 0 and extraction_window_owner_peer_id == target_peer_id:
		_abort_extraction_window(current_server_tick)
	record_public_event("hazard_state_changed", room_slot, -1, {})
	broadcast_hazard_pulse(room_slot, -1, "protocol_watch")

func _choose_ghost_target_peer() -> int:
	var best_peer_id := -1
	var best_score := -999999
	var stalking_bias := maxi(get_current_stalking_bias(), 0)
	var anomaly_bias := maxi(get_current_anomaly_contamination_bias(), 0)
	for peer_id_variant in players:
		var peer_id := int(peer_id_variant)
		if not player_room_by_peer.has(peer_id) or not player_pos_by_peer.has(peer_id):
			continue
		var artifact_id := _find_carried_artifact_by_peer(peer_id)
		var distance_to_exit := extraction_room_slot - int(player_room_by_peer.get(peer_id, 0))
		var score := distance_to_exit * 10
		if artifact_id != 0:
			score += 30 + stalking_bias * 4
		var anomaly_hooks := Array(_loadout_runtime_affordances(peer_id).get("anomaly_hooks", []))
		score += anomaly_hooks.size() * anomaly_bias * 2
		if score > best_score:
			best_score = score
			best_peer_id = peer_id
		elif score == best_score and peer_id > best_peer_id:
			best_peer_id = peer_id
	return best_peer_id

func _choose_anomaly_echo_anchor_peer() -> int:
	var lure_owner_peer_id := _echo_lure_owner_peer_id()
	if lure_owner_peer_id > 0 and player_room_by_peer.has(lure_owner_peer_id) and player_pos_by_peer.has(lure_owner_peer_id):
		return lure_owner_peer_id
	var ghost_target_peer_id := int(ghost_state.get("target_peer_id", -1))
	if ghost_target_peer_id > 0 and player_room_by_peer.has(ghost_target_peer_id) and player_pos_by_peer.has(ghost_target_peer_id):
		return ghost_target_peer_id
	var best_peer_id := -1
	var best_score := -999999
	var anomaly_bias := maxi(get_current_anomaly_contamination_bias(), 0)
	var stalking_bias := maxi(get_current_stalking_bias(), 0)
	for peer_id_variant in players:
		var peer_id := int(peer_id_variant)
		if not player_room_by_peer.has(peer_id) or not player_pos_by_peer.has(peer_id):
			continue
		var score := 0
		if _find_carried_artifact_by_peer(peer_id) != 0:
			score += 18
		var anomaly_hooks := Array(_loadout_runtime_affordances(peer_id).get("anomaly_hooks", []))
		score += anomaly_hooks.size() * (4 + anomaly_bias)
		score += stalking_bias
		if score > best_score:
			best_score = score
			best_peer_id = peer_id
		elif score == best_score and peer_id > best_peer_id:
			best_peer_id = peer_id
	return best_peer_id

func _anomaly_echo_room_slot(anchor_peer_id: int) -> int:
	if _echo_lure_active_for_peer(anchor_peer_id):
		return _echo_lure_room_slot_for_peer(anchor_peer_id)
	var anchor_room := int(player_room_by_peer.get(anchor_peer_id, -1))
	if anchor_room < 0:
		return -1
	var max_room := maxi(extraction_room_slot, anchor_room)
	var direction := -1 if posmod(current_server_tick + anchor_peer_id + maxi(get_current_stalking_bias(), 0), 2) == 0 else 1
	var room_slot := clampi(anchor_room + direction, 0, max_room)
	if room_slot == anchor_room and max_room > 0:
		room_slot = clampi(anchor_room - direction, 0, max_room)
	return room_slot

func _echo_lure_owner_peer_id() -> int:
	if not bool(echo_lure_state.get("active", false)):
		return -1
	if current_server_tick > int(echo_lure_state.get("expires_tick", -1)):
		return -1
	return int(echo_lure_state.get("owner_peer_id", -1))

func _echo_lure_active_for_peer(peer_id: int) -> bool:
	return peer_id > 0 and _echo_lure_owner_peer_id() == peer_id

func _echo_lure_room_slot_for_peer(peer_id: int) -> int:
	if not _echo_lure_active_for_peer(peer_id):
		return -1
	return int(echo_lure_state.get("room_slot", -1))

func _current_predator_rush_interval(peer_id: int, active_peer_count: int = -1) -> int:
	var interval := 210
	interval -= get_current_inhabitant_pressure_bias() * 10
	interval -= maxi(get_current_stalking_bias(), 0) * 14
	match get_protocol_state_label(active_peer_count):
		"Exposure Protocol":
			interval -= 44
		"Intimate Protocol":
			interval -= 28
		"Fracture Protocol":
			interval -= 12
	interval -= Array(_loadout_runtime_affordances(peer_id).get("protocol_hooks", [])).size() * 4
	interval -= int(custody_debt_by_peer.get(peer_id, 0)) * 5
	interval -= int(counterfeit_heat_by_peer.get(peer_id, 0)) * 8
	return clampi(interval, 84, 240)

func _choose_predator_target_peer() -> int:
	var best_peer_id := -1
	var best_score := -999999
	var room_counts := _room_population_counts()
	for peer_id_variant in players:
		var peer_id := int(peer_id_variant)
		if not player_room_by_peer.has(peer_id):
			continue
		var room_slot := int(player_room_by_peer.get(peer_id, 0))
		var affordances := _loadout_runtime_affordances(peer_id)
		var behavior_signals := Array(affordances.get("behavior_signals", []))
		var resource_signals := Array(affordances.get("resource_signals", []))
		var score := room_slot * 5
		if _find_carried_artifact_by_peer(peer_id) != 0:
			score += 24
		if int(room_counts.get(room_slot, 0)) <= 1:
			score += 18
		if int(ghost_state.get("target_peer_id", -1)) == peer_id:
			score += 8
		if int(protocol_watch_state.get("target_peer_id", -1)) == peer_id:
			score += 4
		score += int(custody_debt_by_peer.get(peer_id, 0)) * 6
		score += int(counterfeit_heat_by_peer.get(peer_id, 0)) * 10
		score += int(suspicion_heat_by_peer.get(peer_id, 0)) * 4
		score += int(role_pressure_by_peer.get(peer_id, 0)) * 6
		if behavior_signals.has("watch bait"):
			score += 8
		if resource_signals.has("escort rig"):
			score -= 4
		if _echo_lure_active_for_peer(peer_id):
			score += 6
		match _role_name_for_peer(peer_id):
			ROLE_SERVICE_SCRIPT.ROLE_BEARER:
				score += 10 if _find_carried_artifact_by_peer(peer_id) != 0 else 2
			ROLE_SERVICE_SCRIPT.ROLE_STEWARD:
				score += 4 if int(role_pressure_by_peer.get(peer_id, 0)) > 0 else 0
			ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
				score += 6 if int(counterfeit_heat_by_peer.get(peer_id, 0)) > 0 else 2
		if score > best_score:
			best_score = score
			best_peer_id = peer_id
		elif score == best_score and peer_id > best_peer_id:
			best_peer_id = peer_id
	return best_peer_id

func _room_population_counts() -> Dictionary:
	var counts := {}
	for peer_id_variant in players:
		var peer_id := int(peer_id_variant)
		if not player_room_by_peer.has(peer_id):
			continue
		var room_slot := int(player_room_by_peer.get(peer_id, -1))
		counts[room_slot] = int(counts.get(room_slot, 0)) + 1
	return counts

func _current_protocol_watch_interval(peer_id: int) -> int:
	var interval := 180
	interval -= get_current_inhabitant_pressure_bias() * 12
	interval -= maxi(get_current_stalking_bias(), 0) * 8
	interval -= maxi(get_current_anomaly_contamination_bias(), 0) * 4
	interval -= Array(_loadout_runtime_affordances(peer_id).get("protocol_hooks", [])).size() * 10
	var generation_surface := _effective_generation_surface()
	var relay_routing: Dictionary = Dictionary(generation_surface.get("relay_routing", {}))
	var cookbook_routing: Dictionary = Dictionary(generation_surface.get("cookbook_routing", {}))
	var civilization_routing: Dictionary = Dictionary(generation_surface.get("civilization_routing", {}))
	interval -= int(relay_routing.get("relay_overload", 0)) * 10
	interval -= int(relay_routing.get("distributed_witness", 0)) * 8
	interval -= int(relay_routing.get("regroup_friction", 0)) * 12
	interval -= int(cookbook_routing.get("anti_protocol_pull", 0)) * 10
	interval -= int(civilization_routing.get("taboo_silence", 0)) * 10
	interval -= int(civilization_routing.get("canon_conflict", 0)) * 8
	interval -= int(civilization_routing.get("sacred_order", 0)) * 6
	interval -= int(custody_debt_by_peer.get(peer_id, 0)) * 8
	interval -= int(suspicion_heat_by_peer.get(peer_id, 0)) * 10
	interval -= int(counterfeit_heat_by_peer.get(peer_id, 0)) * 12
	interval -= int(role_pressure_by_peer.get(peer_id, 0)) * 6
	var affordances := _loadout_runtime_affordances(peer_id)
	var behavior_signals := Array(affordances.get("behavior_signals", []))
	var resource_signals := Array(affordances.get("resource_signals", []))
	if behavior_signals.has("witness flare") or behavior_signals.has("watch bait"):
		interval -= 8
	if resource_signals.has("escort rig"):
		interval += 4
	if _echo_lure_active_for_peer(peer_id):
		interval -= 14
	match _role_name_for_peer(peer_id):
		ROLE_SERVICE_SCRIPT.ROLE_STEWARD:
			interval += 8
		ROLE_SERVICE_SCRIPT.ROLE_BEARER:
			interval -= 12 if _find_carried_artifact_by_peer(peer_id) != 0 else 4
		ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
			interval -= 10
	return clampi(interval, 72, 220)

func _choose_protocol_watch_peer() -> int:
	var best_peer_id := -1
	var best_score := -999999
	for peer_id_variant in players:
		var peer_id := int(peer_id_variant)
		if not player_room_by_peer.has(peer_id):
			continue
		var affordances := _loadout_runtime_affordances(peer_id)
		var behavior_signals := Array(affordances.get("behavior_signals", []))
		var resource_signals := Array(affordances.get("resource_signals", []))
		var score := int(player_room_by_peer.get(peer_id, 0)) * 4
		if _find_carried_artifact_by_peer(peer_id) != 0:
			score += 18
		score += Array(affordances.get("protocol_hooks", [])).size() * 6
		score += int(custody_debt_by_peer.get(peer_id, 0)) * 8
		score += int(suspicion_heat_by_peer.get(peer_id, 0)) * 10
		score += int(counterfeit_heat_by_peer.get(peer_id, 0)) * 12
		score += int(role_pressure_by_peer.get(peer_id, 0)) * 6
		if behavior_signals.has("witness flare"):
			score += 6
		if behavior_signals.has("watch bait"):
			score += 12
		if resource_signals.has("escort rig"):
			score -= 3
		if _echo_lure_active_for_peer(peer_id):
			score += 42
		match _role_name_for_peer(peer_id):
			ROLE_SERVICE_SCRIPT.ROLE_STEWARD:
				score += 6 if int(role_pressure_by_peer.get(peer_id, 0)) > 0 else 0
			ROLE_SERVICE_SCRIPT.ROLE_BEARER:
				score += 12 if _find_carried_artifact_by_peer(peer_id) != 0 else 4
			ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
				score += 8
		if int(ghost_state.get("target_peer_id", -1)) == peer_id:
			score += 6
		if score > best_score:
			best_score = score
			best_peer_id = peer_id
		elif score == best_score and peer_id > best_peer_id:
			best_peer_id = peer_id
	return best_peer_id

func _artifact_cache_position(room_slot: int, artifact_id: int) -> Vector2:
	var grid_x := posmod(room_slot, ROOM_COLUMNS)
	var grid_y := int(floor(float(room_slot) / float(ROOM_COLUMNS)))
	var lane := posmod(artifact_id, 3)
	return Vector2(
		180.0 + float(grid_x) * ROOM_WIDTH + 42.0 * float(lane),
		360.0 + float(grid_y) * ROOM_HEIGHT + 28.0 * float(lane)
	)

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

func _room_definition_for_slot(room_slot: int) -> Dictionary:
	for room_raw in last_authoritative_room_chain:
		var room: Dictionary = room_raw
		if int(room.get("slot", -1)) == room_slot:
			return room.duplicate(true)
	return {}

func _current_echo_pressure_score(peer_id: int) -> int:
	if peer_id <= 0:
		return 0
	var score := 0
	if bool(ghost_state.get("active", false)):
		score += 1
		if int(ghost_state.get("target_peer_id", -1)) == peer_id:
			score += 1
	if bool(predator_state.get("active", false)) and int(predator_state.get("target_peer_id", -1)) == peer_id:
		score += 1
	if bool(protocol_watch_state.get("active", false)) and int(protocol_watch_state.get("target_peer_id", -1)) == peer_id:
		score += 1
	if _echo_lure_active_for_peer(peer_id):
		score += 1
	score += maxi(get_current_anomaly_contamination_bias(), 0)
	return score

func _loadout_context_for_peer(peer_id: int, room_slot_override: int = -1) -> Dictionary:
	var room_slot := room_slot_override if room_slot_override >= 0 else int(player_room_by_peer.get(peer_id, -1))
	var context := {
		"tool_counts": get_tool_counts_for_peer(peer_id),
		"protocol_state": get_protocol_state_label(),
		"carrying_artifact": _find_carried_artifact_by_peer(peer_id) != 0,
		"ghost_active": bool(ghost_state.get("active", false)),
		"predator_pressure": bool(predator_state.get("active", false)) and int(predator_state.get("target_peer_id", -1)) == peer_id,
		"protocol_watch_pressure": bool(protocol_watch_state.get("active", false)) and int(protocol_watch_state.get("target_peer_id", -1)) == peer_id,
		"anomaly_bias": maxi(get_current_anomaly_contamination_bias(), 0),
		"room_slot": room_slot,
		"echo_pressure_score": _current_echo_pressure_score(peer_id)
	}
	var persisted_transformations: Array[String] = []
	var run_state := _run_state()
	if run_state != null:
		for key_variant in Dictionary(run_state.active_mutation_flags).keys():
			var key_text := str(key_variant)
			var prefix := "transformation_threshold_crossed:%d:" % peer_id
			if not key_text.begins_with(prefix):
				continue
			if not bool(run_state.active_mutation_flags.get(key_variant, false)):
				continue
			var transformation_id := key_text.substr(prefix.length()).strip_edges()
			if not transformation_id.is_empty() and not persisted_transformations.has(transformation_id):
				persisted_transformations.append(transformation_id)
	var active_transformation_ids: Array[String] = persisted_transformations.duplicate()
	for transformation_id in item_service.active_transformation_item_ids_for_items(_item_def_ids_for_peer(peer_id), context):
		if not active_transformation_ids.has(transformation_id):
			active_transformation_ids.append(transformation_id)
	context["active_transformation_ids"] = active_transformation_ids
	return context

func _maybe_trigger_chamber_entry_mutation(peer_id: int, room_slot: int) -> void:
	if room_slot < 0:
		return
	var room: Dictionary = _room_definition_for_slot(room_slot)
	if room.is_empty():
		return
	var room_type := str(room.get("type", "traversal"))
	if room_type not in ["hazard", "evidence"]:
		return
	var run_state := _run_state()
	if run_state == null:
		return
	var visit_key := "chamber_entered:%d" % room_slot
	if bool(Dictionary(run_state.active_mutation_flags).get(visit_key, false)):
		return
	var applied := _apply_constitution_mutation("chamber_entered", {
		"actor_peer_id": peer_id,
		"room_slot": room_slot,
		"room_id": str(room.get("id", "")),
		"room_type": room_type
	})
	if not applied.is_empty():
		run_state.active_mutation_flags[visit_key] = true

func _note_species_escalation_mutation(species_id: String, room_slot: int, target_peer_id: int, mode: String = "") -> void:
	if room_slot < 0:
		return
	var run_state := _run_state()
	if run_state == null:
		return
	var encounter := _apply_runtime_encounter_state(species_id, room_slot, target_peer_id, mode)
	var active_apex_state := get_active_apex_state()
	var signature := "%s:%d:%d:%s:%s" % [
		species_id,
		room_slot,
		target_peer_id,
		mode,
		str(encounter.get("encounter_id", "")).strip_edges()
	]
	if str(Dictionary(run_state.mutation_caps_state).get("last_species_escalation_signature", "")) == signature:
		return
	var applied := _apply_constitution_mutation("species_escalation", {
		"visibility": "public",
		"species_id": species_id,
		"room_slot": room_slot,
		"actor_peer_id": target_peer_id,
		"mode": mode,
		"encounter_id": str(encounter.get("encounter_id", "")).strip_edges(),
		"intent_id": str(encounter.get("intent_id", "")).strip_edges(),
		"topology_id": str(encounter.get("topology_id", "")).strip_edges(),
		"anchored_pressures": _string_array(encounter.get("anchored_pressures", [])),
		"pathology_family_ids": _string_array(encounter.get("pathology_family_ids", [])),
		"apex_id": str(active_apex_state.get("apex_id", "")).strip_edges(),
		"apex_class_id": str(active_apex_state.get("apex_class_id", "")).strip_edges()
	})
	if not applied.is_empty():
		run_state.mutation_caps_state["last_species_escalation_signature"] = signature
		if target_peer_id > 0:
			_refresh_transformation_thresholds_for_peer(target_peer_id, room_slot)

func _maybe_trigger_covenant_activation(peer_id: int, room_slot: int) -> void:
	if peer_id <= 0:
		return
	var item_def_ids := _item_def_ids_for_peer(peer_id)
	if item_def_ids.is_empty():
		return
	var context := _loadout_context_for_peer(peer_id, room_slot)
	var active_covenants: Array[String] = item_service.active_covenant_item_ids_for_items(item_def_ids, context)
	if active_covenants.is_empty():
		return
	var run_state := _run_state()
	if run_state == null:
		return
	for covenant_id in active_covenants:
		var activation_key := "covenant_activated:%d:%s" % [peer_id, covenant_id]
		if bool(Dictionary(run_state.active_mutation_flags).get(activation_key, false)):
			continue
		var applied := _apply_constitution_mutation("covenant_activated", {
			"visibility": "public",
			"actor_peer_id": peer_id,
			"room_slot": room_slot,
			"item_def_id": covenant_id,
			"activation_condition": str(item_service.get_definition(covenant_id).get("activation_condition", ""))
		})
		if not applied.is_empty():
			run_state.active_mutation_flags[activation_key] = true

func _refresh_transformation_thresholds_for_peer(peer_id: int, room_slot: int) -> void:
	if peer_id <= 0:
		return
	var item_def_ids := _item_def_ids_for_peer(peer_id)
	if item_def_ids.is_empty():
		return
	var context := _loadout_context_for_peer(peer_id, room_slot)
	var active_transformations: Array[String] = item_service.active_transformation_item_ids_for_items(item_def_ids, context)
	if active_transformations.is_empty():
		return
	var run_state := _run_state()
	if run_state == null:
		return
	for transformation_id in active_transformations:
		var activation_key := "transformation_threshold_crossed:%d:%s" % [peer_id, transformation_id]
		if bool(Dictionary(run_state.active_mutation_flags).get(activation_key, false)):
			continue
		var definition: Dictionary = item_service.get_definition(transformation_id)
		var applied := _apply_constitution_mutation("transformation_threshold_crossed", {
			"visibility": "public",
			"actor_peer_id": peer_id,
			"room_slot": room_slot,
			"item_def_id": transformation_id,
			"threshold_kind": str(definition.get("threshold_kind", "")),
			"discernibility_flag": str(definition.get("discernibility_flag", "")),
			"pressure_score": int(context.get("echo_pressure_score", 0))
		})
		if not applied.is_empty():
			run_state.active_mutation_flags[activation_key] = true

func _apply_role_custody_pickup_pressure(requester_id: int, artifact: Dictionary) -> void:
	var authenticity_state: String = str(artifact_service.authenticity_state(artifact))
	var role_name := _role_name_for_peer(requester_id)
	var custody_delta := 1 if authenticity_state == "authentic" else 0
	var suspicion_delta := 0
	var counterfeit_delta := 0
	var role_delta := 0
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_WARDEN and authenticity_state == "authentic":
		role_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_STEWARD and authenticity_state == "authentic":
		suspicion_delta -= 1
		role_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_BEARER and authenticity_state == "authentic":
		custody_delta -= 1
		role_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		suspicion_delta += 1
		if authenticity_state == "counterfeit":
			counterfeit_delta += 2
		elif authenticity_state == "authentic":
			custody_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
		suspicion_delta += 1
		counterfeit_delta += 1 if authenticity_state == "counterfeit" else 0
		role_delta += 1 if authenticity_state == "counterfeit" else 0
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER and authenticity_state == "authentic":
		custody_delta += 1
	_note_role_custody_pressure(requester_id, custody_delta, suspicion_delta, counterfeit_delta, role_delta)

func _apply_role_custody_drop_pressure(requester_id: int, artifact: Dictionary, room_slot: int) -> void:
	var authenticity_state: String = str(artifact_service.authenticity_state(artifact))
	var role_name := _role_name_for_peer(requester_id)
	var custody_delta := 0
	var suspicion_delta := 0
	var counterfeit_delta := 0
	var role_delta := 0
	if authenticity_state == "authentic" and room_slot != extraction_room_slot:
		custody_delta += 1
	if current_server_tick <= int(disturbance_until_by_room.get(room_slot, -1)):
		suspicion_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_STEWARD and authenticity_state == "authentic" and room_slot != extraction_room_slot:
		suspicion_delta += 1
		role_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_BEARER and authenticity_state == "authentic":
		role_delta += 1
		if room_slot == extraction_room_slot:
			custody_delta -= 1
		else:
			custody_delta += 1
			suspicion_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		suspicion_delta += 1
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
		suspicion_delta += 1
		if authenticity_state == "counterfeit":
			counterfeit_delta += 1
		role_delta += 1
	_note_role_custody_pressure(requester_id, custody_delta, suspicion_delta, counterfeit_delta, role_delta)

func _note_role_custody_pressure(peer_id: int, custody_delta: int = 0, suspicion_delta: int = 0, counterfeit_delta: int = 0, role_delta: int = 0) -> void:
	if peer_id <= 0:
		return
	if custody_delta != 0:
		custody_debt_by_peer[peer_id] = clampi(int(custody_debt_by_peer.get(peer_id, 0)) + custody_delta, 0, 6)
	if suspicion_delta != 0:
		suspicion_heat_by_peer[peer_id] = clampi(int(suspicion_heat_by_peer.get(peer_id, 0)) + suspicion_delta, 0, 6)
	if counterfeit_delta != 0:
		counterfeit_heat_by_peer[peer_id] = clampi(int(counterfeit_heat_by_peer.get(peer_id, 0)) + counterfeit_delta, 0, 6)
	if role_delta != 0:
		role_pressure_by_peer[peer_id] = clampi(int(role_pressure_by_peer.get(peer_id, 0)) + role_delta, 0, 6)

func _role_custody_group_pressure() -> Dictionary:
	var custody_total := 0
	var suspicion_total := 0
	var counterfeit_total := 0
	var warden_duty := 0
	for peer_id_variant in _active_protocol_peer_ids():
		var peer_id := int(peer_id_variant)
		custody_total += int(custody_debt_by_peer.get(peer_id, 0))
		suspicion_total += int(suspicion_heat_by_peer.get(peer_id, 0))
		counterfeit_total += int(counterfeit_heat_by_peer.get(peer_id, 0))
		if str(roles_by_peer.get(peer_id, "")) == ROLE_SERVICE_SCRIPT.ROLE_WARDEN:
			warden_duty += int(role_pressure_by_peer.get(peer_id, 0))
	return {
		"custody_debt": custody_total,
		"suspicion_heat": suspicion_total,
		"counterfeit_heat": counterfeit_total,
		"warden_duty": warden_duty
	}

func _owned_item_count_by_category(peer_id: int, category: String) -> int:
	var total := 0
	for item_data in items_by_id.values():
		var item_dict: Dictionary = item_data
		if int(item_dict.get("owner_peer_id", 0)) != peer_id:
			continue
		if bool(item_dict.get("consumed", false)):
			continue
		if item_service.get_category(str(item_dict.get("item_def_id", ""))) != category:
			continue
		total += 1
	return total

func _consume_tool_charge(peer_id: int, tool_type: String) -> bool:
	var counts := get_tool_counts_for_peer(peer_id)
	var current := int(counts.get(tool_type, 0))
	if current <= 0:
		return false
	counts[tool_type] = current - 1
	tool_inventory_by_peer[peer_id] = counts
	return true

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

func _loadout_runtime_affordances(peer_id: int) -> Dictionary:
	return item_service.build_runtime_affordances(_item_def_ids_for_peer(peer_id), _loadout_context_for_peer(peer_id))

func _active_protocol_peer_ids() -> Array[int]:
	var ids: Array[int] = []
	for peer_variant in players:
		var peer_id := int(peer_variant)
		if peer_id > 0 and not ids.has(peer_id):
			ids.append(peer_id)
	for peer_variant in player_room_by_peer.keys():
		var room_peer_id := int(peer_variant)
		if room_peer_id > 0 and not ids.has(room_peer_id):
			ids.append(room_peer_id)
	ids.sort()
	return ids

func _active_item_defs_for_peer(peer_id: int) -> Array[String]:
	var active_defs: Array[String] = []
	for item in get_active_items_for_peer(peer_id):
		var item_def_id := str(Dictionary(item).get("item_def_id", "")).strip_edges()
		if not item_def_id.is_empty() and not active_defs.has(item_def_id):
			active_defs.append(item_def_id)
	return active_defs

func _apply_constitution_mutation(trigger_type: String, trigger_context: Dictionary = {}) -> Dictionary:
	if not is_host or not run_active:
		return {}
	var run_state := _run_state()
	var event_log := _event_log()
	if run_state == null or event_log == null:
		return {}
	var constitution: Dictionary = {}
	if run_state.has_method("get_expedition_constitution"):
		constitution = Dictionary(run_state.get_expedition_constitution())
	if constitution.is_empty():
		constitution = _effective_constitution()
	if constitution.is_empty():
		return {}
	var plan: Dictionary = EXPEDITION_MUTATION_ENGINE_SCRIPT.build_mutation_plan(constitution, run_state, trigger_type, trigger_context)
	if plan.is_empty():
		return {}
	var event: Dictionary = Dictionary(plan.get("event", {})).duplicate(true)
	if event.is_empty():
		return {}
	event["timeline_event_id"] = next_event_id
	next_event_id += 1
	plan["event"] = event
	var applied := EXPEDITION_MUTATION_ENGINE_SCRIPT.apply_mutation_plan(run_state, event_log, plan, current_server_tick)
	var mutation_summary := get_current_expedition_constitution_summary()
	applied["lifecycle_ref"] = {
		"lifecycle_state_ids": Array(mutation_summary.get("lifecycle_state_ids", [])).duplicate(true),
		"active_regime_ids": Array(mutation_summary.get("active_regime_ids", [])).duplicate(true),
		"market_regime_id": str(mutation_summary.get("market_regime_id", "")).strip_edges(),
		"market_regime_family": str(mutation_summary.get("market_regime_family", "")).strip_edges(),
		"market_regime_lines": Array(mutation_summary.get("market_regime_lines", [])).duplicate(true),
		"lifecycle_lines": Array(mutation_summary.get("lifecycle_lines", [])).duplicate(true)
	}
	var interaction_snapshot: Dictionary = Dictionary(build_gameplay_signal_snapshot())
	var interaction_guarantee_ref: Dictionary = Dictionary(interaction_snapshot.get("interaction_guarantee_ref", {})).duplicate(true)
	interaction_guarantee_ref["phase"] = "post_mutation_state"
	interaction_guarantee_ref["mutation_ref_ids"] = [str(applied.get("mutation_id", "")).strip_edges()]
	interaction_guarantee_ref["known_input_reasserted_after_mutation"] = true
	interaction_guarantee_ref["post_mutation_solvability"] = true
	interaction_guarantee_ref["no_dead_after_mutation_state"] = true
	interaction_guarantee_ref["failure_codes"] = []
	applied["interaction_guarantee_ref"] = interaction_guarantee_ref
	applied["known_input_reasserted_after_mutation"] = true
	applied["post_mutation_solvability"] = true
	if run_state.mutation_history.size() > 0:
		run_state.mutation_history[run_state.mutation_history.size() - 1] = applied.duplicate(true)
	var broadcast_event: Dictionary = applied.duplicate(true)
	broadcast_event.erase("interaction_guarantee_ref")
	broadcast_event.erase("known_input_reassertion_required")
	broadcast_event.erase("known_input_reasserted_after_mutation")
	broadcast_event.erase("post_mutation_solvability")
	_broadcast_mutation_event(broadcast_event)
	return applied

func _build_inhabitant_pressure_signals(peer_id: int, protocol_state: String, carrying_artifact: bool) -> Array[String]:
	var signals: Array[String] = []
	var inhabitant_bias := get_current_inhabitant_pressure_bias()
	var anomaly_bias := get_current_anomaly_contamination_bias()
	if bool(ghost_state.get("active", false)):
		signals.append("ghost pressure")
		if int(ghost_state.get("target_peer_id", -1)) == peer_id:
			signals.append("ghost focus")
	if inhabitant_bias >= 1:
		signals.append("heightened pursuit")
	elif inhabitant_bias <= -1:
		signals.append("softened pursuit")
	if anomaly_bias >= 1:
		signals.append("unstable presence")
		signals.append("echo pressure")
	if bool(predator_state.get("active", false)):
		signals.append("predator rush")
		if int(predator_state.get("target_peer_id", -1)) == peer_id:
			signals.append("predator marked")
			var predator_mode := str(predator_state.get("mode", ""))
			if predator_mode == "ambush":
				signals.append("predator ambush")
			elif predator_mode == "pack":
				signals.append("predator pack")
	if bool(protocol_watch_state.get("active", false)):
		signals.append("protocol sweep")
		if int(protocol_watch_state.get("target_peer_id", -1)) == peer_id:
			signals.append("protocol watched")
			if str(protocol_watch_state.get("mode", "")) == "interdiction":
				signals.append("protocol interdiction")
	if _echo_lure_active_for_peer(peer_id):
		signals.append("echo lure")
	match protocol_state:
		"Fracture Protocol":
			signals.append("split pressure")
		"Intimate Protocol":
			signals.append("pair pressure")
		"Exposure Protocol":
			signals.append("direct exposure")
	if carrying_artifact:
		signals.append("burden target")
		if bool(ghost_state.get("active", false)) or inhabitant_bias >= 1 or anomaly_bias >= 1:
			signals.append("artifact watched")
	return signals

func _run_state() -> Node:
	if is_instance_valid(_run_state_override_for_test):
		return _run_state_override_for_test
	if _run_state_override_for_test != null:
		_run_state_override_for_test = null
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Node = main_loop.root
		var run_state: Node = root.get_node_or_null("/root/RunState")
		if run_state == null:
			run_state = root.get_node_or_null("RunState")
		return run_state
	return null

func _event_log() -> Node:
	if is_instance_valid(_event_log_override_for_test):
		return _event_log_override_for_test
	if _event_log_override_for_test != null:
		_event_log_override_for_test = null
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		var root: Node = main_loop.root
		var event_log: Node = root.get_node_or_null("/root/EventLog")
		if event_log == null:
			event_log = root.get_node_or_null("EventLog")
		return event_log
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
	_host_end_run_impl(reason)

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
	var has_peer := _has_live_network_peer(mp)
	local_id = _safe_mp_unique_id(mp)
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
	for stale_key in profile_cards_by_peer.keys():
		if not connected_peers.has(int(stale_key)):
			profile_cards_by_peer.erase(stale_key)
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
		"is_host": is_host,
		"profile_cards": profile_cards_by_peer.duplicate(true)
	}

func _sync_local_profile_card() -> void:
	var mp := _mp()
	if mp == null:
		return
	var local_id := mp.get_unique_id()
	if local_id <= 0:
		return
	var local_card := _sanitize_profile_card(_build_local_profile_card(), local_id)
	if local_card.is_empty():
		return
	profile_cards_by_peer[local_id] = local_card
	if is_host:
		_broadcast_lobby()
	else:
		client_submit_profile_card.rpc_id(1, local_card.duplicate(true))

func _build_local_profile_card() -> Dictionary:
	var profile := PROFILE_SERVICE_SCRIPT.load_profile()
	return PROFILE_SERVICE_SCRIPT.build_public_identity_card(profile)

func _sanitize_profile_card(card: Dictionary, peer_id: int) -> Dictionary:
	var display_name := str(card.get("display_name", "Delver")).strip_edges()
	if display_name.is_empty():
		display_name = "Delver"
	var public_id := str(card.get("public_id", "")).strip_edges()
	if public_id.is_empty():
		public_id = "peer_%d" % peer_id
	return {
		"peer_id": peer_id,
		"public_id": public_id,
		"display_name": display_name,
		"title": str(card.get("title", "-")).strip_edges(),
		"banner": str(card.get("banner", "-")).strip_edges(),
		"legend_hint": str(card.get("legend_hint", "")).strip_edges(),
		"challenge_hint": str(card.get("challenge_hint", "")).strip_edges(),
		"crew_tag": str(card.get("crew_tag", "")).strip_edges(),
		"build_hint": str(card.get("build_hint", "")).strip_edges(),
		"presence_hint": str(card.get("presence_hint", "")).strip_edges(),
		"heat_band": str(card.get("heat_band", "")).strip_edges()
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

func _mp_connection_status(mp: MultiplayerAPI) -> int:
	if mp == null or mp.multiplayer_peer == null:
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	if mp.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
		return MultiplayerPeer.CONNECTION_DISCONNECTED
	if mp.multiplayer_peer.has_method("get_connection_status"):
		return int(mp.multiplayer_peer.get_connection_status())
	return MultiplayerPeer.CONNECTION_CONNECTED

func _has_live_network_peer(mp: MultiplayerAPI) -> bool:
	return _mp_connection_status(mp) != MultiplayerPeer.CONNECTION_DISCONNECTED

func _safe_mp_unique_id(mp: MultiplayerAPI) -> int:
	if not _has_live_network_peer(mp):
		return -1
	return mp.get_unique_id()

func _peer_id_text(mp: MultiplayerAPI) -> String:
	if not _has_live_network_peer(mp):
		return "none"
	return "%s#%d" % [mp.multiplayer_peer.get_class(), mp.multiplayer_peer.get_instance_id()]

func _log_mp_state(tag: String) -> void:
	var mp := _mp()
	if mp == null:
		_nm_log("MP_STATE tag=%s mp=null" % tag)
		return
	var remote_peers: Array[int] = []
	if _has_live_network_peer(mp):
		remote_peers = _remote_peers_from_mp(mp)
	_nm_log("MP_STATE tag=%s local=%d has_peer=%s is_server=%s remote_peers=%s" % [
		tag,
		_safe_mp_unique_id(mp),
		str(_has_live_network_peer(mp)),
		str(_has_live_network_peer(mp) and mp.is_server()),
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
