extends Node2D

const SNAPSHOT_INTERVAL := 0.08
const SPAWN_X_STEP := 80.0
const ROOM_WIDTH := 520.0
const HAZARD_PULSE_PERIOD := 240
const HAZARD_LAUNCH_VELOCITY := -360.0
const WARDEN_CHECK_RANGE := 96.0
const DENIAL_SHOW_SEC := 1.2

@onready var room_root: Node2D = $Rooms
@onready var player_root: Node2D = $Players
@onready var evidence_root: Node2D = $Evidence
@onready var status_label: Label = $CanvasLayer/HUD/Status
@onready var role_label: Label = $CanvasLayer/HUD/Role
@onready var carry_label: Label = $CanvasLayer/HUD/Carry
@onready var prompt_label: Label = $CanvasLayer/HUD/Prompt
@onready var timeline_label: Label = $CanvasLayer/HUD/Timeline
@onready var room_builder: Node2D = $Rooms
@onready var end_screen: PanelContainer = $CanvasLayer/EndScreen
@onready var end_seed_label: Label = $CanvasLayer/EndScreen/VBox/Seed
@onready var end_reason_label: Label = $CanvasLayer/EndScreen/VBox/Reason
@onready var end_roles_label: Label = $CanvasLayer/EndScreen/VBox/Roles
@onready var end_summary_label: Label = $CanvasLayer/EndScreen/VBox/Summary
@onready var end_timeline_label: Label = $CanvasLayer/EndScreen/VBox/Timeline
@onready var end_more_label: Label = $CanvasLayer/EndScreen/VBox/More

var player_scene := preload("res://scenes/Player.tscn")
var evidence_scene := preload("res://scenes/Evidence.tscn")
var players: Dictionary = {}
var evidence_nodes: Dictionary = {}
var hazard_slots: Array[int] = []
var next_hazard_tick_by_slot: Dictionary = {}
var seq_counter: int = 0
var tick_counter: int = 0
var snapshot_timer: float = 0.0
var key_latch: Dictionary = {}
var denial_text: String = ""
var denial_left: float = 0.0
var run_ended: bool = false
var end_timeline_limit: int = 8
var end_payload: Dictionary = {}

func _ready() -> void:
	NetworkManager.state_snapshot.connect(_on_state_snapshot)
	NetworkManager.evidence_state_changed.connect(_on_evidence_state_changed)
	NetworkManager.role_revealed.connect(_on_role_revealed)
	NetworkManager.hazard_pulse_requested.connect(_on_hazard_pulse_requested)
	NetworkManager.action_denied.connect(_on_action_denied)
	NetworkManager.run_ended.connect(_on_run_ended)
	EventLog.timeline_event_added.connect(_on_timeline_event_added)
	_spawn_players()
	_build_rooms()
	_prepare_hazards()
	_on_evidence_state_changed(RunState.evidence_by_id)
	_on_role_revealed(RunState.local_role)
	_refresh_timeline()
	_update_status()
	end_screen.visible = false

func _physics_process(delta: float) -> void:
	seq_counter += 1
	tick_counter += 1

	var local_id := multiplayer.get_unique_id()
	var move_axis := Input.get_axis("ui_left", "ui_right")
	var jump_pressed := Input.is_action_just_pressed("ui_accept")

	if NetworkManager.is_host and NetworkManager.is_run_active():
		for peer_id in players.keys():
			var actor = players[peer_id]
			var input_pack := NetworkManager.consume_peer_input(peer_id)
			var host_local := peer_id == local_id
			if host_local:
				input_pack = {"move": move_axis, "jump": jump_pressed, "seq": seq_counter}
			actor.simulate_step(float(input_pack.get("move", 0.0)), bool(input_pack.get("jump", false)), delta)
			NetworkManager.update_authoritative_player_state(peer_id, actor.global_position, _room_slot_for_position(actor.global_position))

		_process_hazard_cycles()

		snapshot_timer += delta
		if snapshot_timer >= SNAPSHOT_INTERVAL:
			snapshot_timer = 0.0
			var snapshot := {}
			for peer_id in players.keys():
				var actor = players[peer_id]
				snapshot[str(peer_id)] = {
					"p": actor.global_position,
					"v": actor.velocity
				}
			NetworkManager.broadcast_state(snapshot, tick_counter)
	elif not NetworkManager.is_host and not run_ended:
		NetworkManager.send_client_input(move_axis, jump_pressed, seq_counter)
		if players.has(local_id):
			players[local_id].simulate_step(move_axis, jump_pressed, delta)

	if run_ended and _pressed_once(KEY_TAB):
		end_timeline_limit = 20 if end_timeline_limit == 8 else 8
		_refresh_end_timeline()

	denial_left = maxf(0.0, denial_left - delta)
	if not run_ended:
		_handle_local_actions(local_id)
	_update_evidence_visuals()
	_update_interaction_prompt(local_id)
	_update_status()

func _spawn_players() -> void:
	players.clear()
	for child in player_root.get_children():
		child.queue_free()

	var ids: Array[int] = RunState.player_ids
	if ids.is_empty():
		ids = NetworkManager.players

	for i in ids.size():
		var peer_id := ids[i]
		var actor = player_scene.instantiate()
		actor.name = "Player_%d" % peer_id
		actor.global_position = Vector2(80 + SPAWN_X_STEP * i, 300)
		actor.configure_for_peer(peer_id)
		player_root.add_child(actor)
		players[peer_id] = actor

func _build_rooms() -> void:
	if room_builder.has_method("build_from_chain"):
		room_builder.build_from_chain(RunState.room_chain)

func _prepare_hazards() -> void:
	hazard_slots.clear()
	next_hazard_tick_by_slot.clear()
	for room in RunState.room_chain:
		var slot := int(room.get("slot", -1))
		var hazard_name := str(room.get("hazard", "none"))
		if slot < 0 or hazard_name == "none":
			continue
		hazard_slots.append(slot)
		next_hazard_tick_by_slot[slot] = slot * 13 + HAZARD_PULSE_PERIOD

func _process_hazard_cycles() -> void:
	for slot in hazard_slots:
		var due_tick := int(next_hazard_tick_by_slot.get(slot, HAZARD_PULSE_PERIOD))
		if tick_counter < due_tick:
			continue
		next_hazard_tick_by_slot[slot] = due_tick + HAZARD_PULSE_PERIOD
		NetworkManager.broadcast_hazard_pulse(slot, -1, "state_changed")
		NetworkManager.record_public_event("hazard_state_changed", slot, -1, {})

func _on_state_snapshot(snapshot: Dictionary, _tick: int) -> void:
	if NetworkManager.is_host:
		return
	for key in snapshot.keys():
		var peer_id := int(key)
		if not players.has(peer_id):
			continue
		var actor = players[peer_id]
		var state: Dictionary = snapshot[key]
		var pos: Vector2 = state.get("p", actor.global_position)
		var vel: Vector2 = state.get("v", actor.velocity)
		actor.apply_snapshot(pos, vel)

func _on_role_revealed(role_name: String) -> void:
	role_label.text = "Your role: %s" % role_name

func _on_evidence_state_changed(evidence_by_id: Dictionary) -> void:
	_sync_evidence_nodes(evidence_by_id)

func _on_hazard_pulse_requested(room_slot: int, _source_peer_id: int, _reason: String) -> void:
	if room_builder and room_builder.has_method("flash_hazard_indicator"):
		room_builder.flash_hazard_indicator(room_slot, 0.3)
	for peer_id in players.keys():
		var actor = players[peer_id]
		if _room_slot_for_position(actor.global_position) != room_slot:
			continue
		if actor.velocity.y > HAZARD_LAUNCH_VELOCITY:
			actor.velocity.y = HAZARD_LAUNCH_VELOCITY

func _on_timeline_event_added(_event: Dictionary) -> void:
	_refresh_timeline()

func _on_action_denied(reason: String) -> void:
	denial_text = "Denied: %s" % reason
	denial_left = DENIAL_SHOW_SEC

func _on_run_ended(payload: Dictionary) -> void:
	run_ended = true
	end_payload = payload.duplicate(true)
	end_timeline_limit = 8
	_render_end_screen()

func _refresh_timeline() -> void:
	var lines: Array[String] = []
	for item in EventLog.get_recent(8):
		var event: Dictionary = item
		var tick := int(event.get("tick", -1))
		var event_id := int(event.get("event_id", -1))
		var slot := int(event.get("room_slot", -1))
		var actor := int(event.get("actor_peer_id", -1))
		var event_type := str(event.get("event_type", "unknown"))
		var actor_text := "-" if actor < 0 else "P%d" % actor
		var details := ""
		if event_type == "warden_check_result":
			var meta: Dictionary = event.get("meta", {})
			details = " E%d score:%d" % [int(meta.get("artifact_id", 0)), int(meta.get("score", -1))]
		lines.append("t%04d e%04d s%02d %s %s%s" % [tick, event_id, slot, actor_text, event_type, details])
	timeline_label.text = "Timeline\n%s" % "\n".join(lines)

func _handle_local_actions(local_id: int) -> void:
	if not players.has(local_id):
		return
	if _pressed_once(KEY_Q):
		var nearest_pickup := _find_nearest_ground_artifact_id(local_id)
		NetworkManager.request_pickup(nearest_pickup)
	if _pressed_once(KEY_E):
		NetworkManager.request_drop()
	if _pressed_once(KEY_R):
		var steal_target := _find_nearest_carried_artifact_id(local_id)
		NetworkManager.request_steal(steal_target)
	if _pressed_once(KEY_F):
		NetworkManager.request_forge(_room_slot_for_position(players[local_id].global_position))
	if _pressed_once(KEY_G):
		NetworkManager.request_sabotage(_room_slot_for_position(players[local_id].global_position))
	if _pressed_once(KEY_T) and RunState.local_role == RoleService.ROLE_WARDEN:
		var check_target := _find_nearest_artifact_for_check(local_id, WARDEN_CHECK_RANGE)
		NetworkManager.request_check_artifact(check_target)

func _find_nearest_ground_artifact_id(local_id: int) -> int:
	var best_id := 0
	var best_dist := 999999.0
	var local_pos := players[local_id].global_position
	for artifact_id in RunState.evidence_by_id.keys():
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) != 0:
			continue
		var pos: Vector2 = artifact.get("world_pos", Vector2.ZERO)
		var dist := local_pos.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best_id = int(artifact_id)
	return best_id

func _find_nearest_carried_artifact_id(local_id: int) -> int:
	var best_id := 0
	var best_dist := 999999.0
	var local_pos := players[local_id].global_position
	for artifact_id in RunState.evidence_by_id.keys():
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		var owner_peer := int(artifact.get("owner_peer_id", 0))
		if owner_peer == 0 or owner_peer == local_id:
			continue
		if not players.has(owner_peer):
			continue
		var dist := local_pos.distance_to(players[owner_peer].global_position)
		if dist < best_dist:
			best_dist = dist
			best_id = int(artifact_id)
	return best_id

func _find_nearest_artifact_for_check(local_id: int, max_range: float) -> int:
	var best_id := 0
	var best_dist := max_range
	var local_pos := players[local_id].global_position
	for artifact_id in RunState.evidence_by_id.keys():
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		var owner_peer := int(artifact.get("owner_peer_id", 0))
		var target_pos: Vector2 = artifact.get("world_pos", Vector2.ZERO)
		if owner_peer != 0 and players.has(owner_peer):
			target_pos = players[owner_peer].global_position + Vector2(0, -56)
		var dist := local_pos.distance_to(target_pos)
		if dist > best_dist:
			continue
		best_dist = dist
		best_id = int(artifact_id)
	return best_id

func _update_interaction_prompt(local_id: int) -> void:
	if run_ended:
		prompt_label.text = ""
		return
	if not players.has(local_id):
		prompt_label.text = ""
		return
	var prompts: Array[String] = []
	var local_pos := players[local_id].global_position
	var local_slot := _room_slot_for_position(local_pos)
	var carried_id := NetworkManager.get_local_carried_artifact_id()

	var nearest_pickup := _find_nearest_ground_artifact_id(local_id)
	if nearest_pickup > 0 and RunState.evidence_by_id.has(nearest_pickup):
		var ground_artifact: Dictionary = RunState.evidence_by_id[nearest_pickup]
		var ground_pos: Vector2 = ground_artifact.get("world_pos", Vector2.ZERO)
		if local_pos.distance_to(ground_pos) <= EvidenceService.PICKUP_RANGE:
			prompts.append("Q: Pick up E%d" % nearest_pickup)

	if carried_id > 0:
		prompts.append("E: Drop")

	var nearest_steal := _find_nearest_carried_artifact_id(local_id)
	if nearest_steal > 0 and RunState.evidence_by_id.has(nearest_steal):
		var steal_artifact: Dictionary = RunState.evidence_by_id[nearest_steal]
		var owner_peer := int(steal_artifact.get("owner_peer_id", 0))
		if owner_peer != 0 and players.has(owner_peer):
			var owner_pos := players[owner_peer].global_position
			if local_pos.distance_to(owner_pos) <= EvidenceService.STEAL_RANGE:
				prompts.append("R: Steal E%d" % nearest_steal)

	if RunState.local_role == RoleService.ROLE_VEIL:
		prompts.append("F: Forge")
		if NetworkManager.can_local_use_sabotage(local_slot):
			prompts.append("G: Sabotage")

	if RunState.local_role == RoleService.ROLE_WARDEN:
		var check_id := _find_nearest_artifact_for_check(local_id, WARDEN_CHECK_RANGE)
		if check_id > 0 and RunState.evidence_by_id.has(check_id):
			var check_artifact: Dictionary = RunState.evidence_by_id[check_id]
			var check_owner := int(check_artifact.get("owner_peer_id", 0))
			var check_slot := int(check_artifact.get("room_slot", -1))
			if check_owner != 0 and players.has(check_owner):
				check_slot = _room_slot_for_position(players[check_owner].global_position)
			if check_slot == local_slot:
				prompts.append("T: Check")

	prompt_label.text = " | ".join(prompts)

func _sync_evidence_nodes(evidence_by_id: Dictionary) -> void:
	for artifact_id in evidence_nodes.keys().duplicate():
		if evidence_by_id.has(artifact_id):
			continue
		evidence_nodes[artifact_id].queue_free()
		evidence_nodes.erase(artifact_id)

	for artifact_id in evidence_by_id.keys():
		var artifact: Dictionary = evidence_by_id[artifact_id]
		if not evidence_nodes.has(artifact_id):
			var node = evidence_scene.instantiate()
			node.name = "Evidence_%d" % int(artifact_id)
			evidence_root.add_child(node)
			evidence_nodes[artifact_id] = node
		evidence_nodes[artifact_id].configure(artifact)

	_update_evidence_visuals()

func _update_evidence_visuals() -> void:
	var carried_by_peer: Dictionary = {}
	for artifact_id in RunState.evidence_by_id.keys():
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		var owner_peer := int(artifact.get("owner_peer_id", 0))
		if not evidence_nodes.has(artifact_id):
			continue
		var node = evidence_nodes[artifact_id]
		if owner_peer == 0:
			node.sync_state(artifact)
		elif players.has(owner_peer):
			node.sync_state(artifact)
			node.set_visual_position(players[owner_peer].global_position + Vector2(0, -56))
			carried_by_peer[owner_peer] = int(artifact_id)

	for peer_id in players.keys():
		players[peer_id].set_carrying_artifact(carried_by_peer.has(peer_id))

	var local_id := multiplayer.get_unique_id()
	if carried_by_peer.has(local_id):
		carry_label.text = "Carrying: E%d" % int(carried_by_peer[local_id])
	else:
		carry_label.text = "Carrying: None"

func _room_slot_for_position(pos: Vector2) -> int:
	return maxi(int(floor(pos.x / ROOM_WIDTH)), 0)

func _pressed_once(keycode: int) -> bool:
	var now_pressed := Input.is_physical_key_pressed(keycode)
	var was_pressed := bool(key_latch.get(keycode, false))
	key_latch[keycode] = now_pressed
	return now_pressed and not was_pressed

func _update_status() -> void:
	if run_ended:
		status_label.text = "Run ended. TAB toggles more timeline lines."
		return
	if denial_left > 0.0:
		status_label.text = denial_text
		return
	status_label.text = "Seed %d | Players %d | Host %s | Q pick E drop R steal F forge G sabotage T check" % [RunState.run_seed, RunState.player_ids.size(), str(NetworkManager.is_host)]

func _render_end_screen() -> void:
	end_screen.visible = true
	end_seed_label.text = "Seed: %d" % int(end_payload.get("seed", RunState.run_seed))
	end_reason_label.text = "Outcome: RUN COMPLETE (%s)" % str(end_payload.get("reason", "unknown"))
	_render_end_roles()
	_render_end_summary()
	_refresh_end_timeline()

func _render_end_roles() -> void:
	var roles: Dictionary = end_payload.get("roles_reveal", {})
	var ids: Array = roles.keys()
	ids.sort()
	var lines: Array[String] = []
	for peer_key in ids:
		lines.append("P%s: %s" % [str(peer_key), str(roles[peer_key])])
	end_roles_label.text = "Role Reveal\n%s" % "\n".join(lines)

func _render_end_summary() -> void:
	var summary: Dictionary = end_payload.get("summary_by_peer", {})
	var ids: Array = summary.keys()
	ids.sort()
	var lines: Array[String] = []
	for peer_key in ids:
		var row: Dictionary = summary[peer_key]
		lines.append(
			"P%s pick:%d drop:%d steal:%d carry_end:%d" % [
				str(peer_key),
				int(row.get("picked", 0)),
				int(row.get("dropped", 0)),
				int(row.get("stolen", 0)),
				int(row.get("carrying_end", 0))
			]
		)
	end_summary_label.text = "Evidence Summary\n%s" % "\n".join(lines)

func _refresh_end_timeline() -> void:
	var lines: Array[String] = []
	for item in EventLog.get_recent(end_timeline_limit):
		var event: Dictionary = item
		var tick := int(event.get("tick", -1))
		var event_id := int(event.get("event_id", -1))
		var slot := int(event.get("room_slot", -1))
		var actor := int(event.get("actor_peer_id", -1))
		var event_type := str(event.get("event_type", "unknown"))
		var actor_text := "-" if actor < 0 else "P%d" % actor
		lines.append("t%04d e%04d s%02d %s %s" % [tick, event_id, slot, actor_text, event_type])
	end_timeline_label.text = "Timeline (last %d)\n%s" % [end_timeline_limit, "\n".join(lines)]
	end_more_label.text = "TAB: %s timeline" % ["show less" if end_timeline_limit > 8 else "show more"]
