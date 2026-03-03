extends Node2D

const SNAPSHOT_INTERVAL := 0.08
const SPAWN_X_STEP := 80.0
const ROOM_WIDTH := 520.0
const WARDEN_CHECK_RANGE := 96.0
const NOTEBOOK_RECENT_LIMIT := 8
const NOTEBOOK_MAX_LEN := 120
const NOTEBOOK_INSPECTION_AUTONOTE_TICKS := 30
const ACTION_SUMMARY_MAX_LINE_LEN := 60
const NOTEBOOK_FILTER_ALL := "ALL"
const NOTEBOOK_FILTER_PINNED := "PINNED"
const NOTEBOOK_FILTER_EVIDENCE := "EVIDENCE"
const NOTEBOOK_FILTER_SUSPECT := "SUSPECT"
const NOTEBOOK_FILTER_ALIBI := "ALIBI"
const NOTEBOOK_FILTER_OTHER := "OTHER"
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")
const ITEM_PICKUP_SCENE = preload("res://scenes/Item.tscn")

var NetworkManager: Node:
	get:
		var tree := get_tree()
		return tree.root.get_node_or_null("/root/NetworkManager") if tree != null else null

var EventLog: Node:
	get:
		var tree := get_tree()
		return tree.root.get_node_or_null("/root/EventLog") if tree != null else null

var RunState: Node:
	get:
		var tree := get_tree()
		return tree.root.get_node_or_null("/root/RunState") if tree != null else null

@onready var room_root: Node2D = get_node_or_null("Rooms") as Node2D
@onready var player_root: Node2D = get_node_or_null("Players") as Node2D
@onready var evidence_root: Node2D = get_node_or_null("Evidence") as Node2D
@onready var item_root: Node2D = get_node_or_null("Items") as Node2D
@onready var status_label: Label = get_node_or_null("CanvasLayer/HUD/Status") as Label
@onready var role_label: Label = get_node_or_null("CanvasLayer/HUD/Role") as Label
@onready var carry_label: Label = get_node_or_null("CanvasLayer/HUD/Carry") as Label
@onready var prompt_label: Label = get_node_or_null("CanvasLayer/HUD/Prompt") as Label
@onready var timeline_label: Label = get_node_or_null("CanvasLayer/HUD/Timeline") as Label
@onready var hint_label: Label = get_node_or_null("CanvasLayer/HUD/HintLabel") as Label
@onready var room_builder: Node2D = get_node_or_null("Rooms") as Node2D
@onready var help_panel: Control = get_node_or_null("CanvasLayer/HelpPanel") as Control
@onready var help_label: Label = get_node_or_null("CanvasLayer/HelpPanel/HelpLabel") as Label
@onready var notebook_panel: Control = get_node_or_null("CanvasLayer/NotebookPanel") as Control
@onready var notebook_hint_label: Label = get_node_or_null("CanvasLayer/NotebookPanel/VBox/Hint") as Label
@onready var notebook_input: LineEdit = get_node_or_null("CanvasLayer/NotebookPanel/VBox/Input") as LineEdit
@onready var notebook_filter_option: OptionButton = get_node_or_null("CanvasLayer/NotebookPanel/VBox/FilterOption") as OptionButton
@onready var notebook_pin_button: Button = get_node_or_null("CanvasLayer/NotebookPanel/VBox/PinLatestButton") as Button
@onready var notebook_copy_button: Button = get_node_or_null("CanvasLayer/NotebookPanel/VBox/CopyNotesButton") as Button
@onready var notebook_toast_label: Label = get_node_or_null("CanvasLayer/NotebookPanel/VBox/ToastLabel") as Label
@onready var notebook_notes_label: Label = get_node_or_null("CanvasLayer/NotebookPanel/VBox/Notes") as Label
@onready var end_screen: PanelContainer = get_node_or_null("CanvasLayer/EndScreen") as PanelContainer
@onready var end_seed_label: Label = get_node_or_null("CanvasLayer/EndScreen/VBox/Seed") as Label
@onready var end_reason_label: Label = get_node_or_null("CanvasLayer/EndScreen/VBox/Reason") as Label
@onready var end_roles_label: Label = get_node_or_null("CanvasLayer/EndScreen/VBox/Roles") as Label
@onready var end_summary_label: Label = get_node_or_null("CanvasLayer/EndScreen/VBox/Summary") as Label
@onready var end_timeline_label: Label = get_node_or_null("CanvasLayer/EndScreen/VBox/Timeline") as Label
@onready var end_more_label: Label = get_node_or_null("CanvasLayer/EndScreen/VBox/More") as Label
@onready var return_lobby_button: Button = get_node_or_null("CanvasLayer/EndScreen/VBox/ReturnLobbyButton") as Button

var player_scene := preload("res://scenes/Player.tscn")
var evidence_scene := preload("res://scenes/Evidence.tscn")
var evidence_service: Object = EVIDENCE_SERVICE_SCRIPT.new()
var players: Dictionary = {}
var evidence_nodes: Dictionary = {}
var item_nodes: Dictionary = {}
var tick_counter: int = 0
var snapshot_timer: float = 0.0
var key_latch: Dictionary = {}
var feedback_text: String = ""
var feedback_left: float = 0.0
var run_ended: bool = false
var end_timeline_limit: int = 8
var end_payload: Dictionary = {}
var notebook_open: bool = false
var help_open: bool = false
var notebook_last_autonote_tick_by_key: Dictionary = {}
var notebook_filter_mode: String = NOTEBOOK_FILTER_ALL
var notebook_toast_expires_tick: int = -1
var hint_last_text: String = ""
var hint_last_tick: int = -999999
var next_step_hint_text: String = ""
var cli_auto_pickup: bool = false
var cli_auto_pickup_done: bool = false
var cli_auto_role_action: bool = false
var cli_auto_role_action_done: bool = false
var last_report_user_path: String = ""
var last_verify_status: String = ""

func _ready() -> void:
	if NetworkManager.has_signal("state_snapshot"):
		NetworkManager.state_snapshot.connect(_on_state_snapshot)
	if NetworkManager.has_signal("evidence_state_changed"):
		NetworkManager.evidence_state_changed.connect(_on_evidence_state_changed)
	if NetworkManager.has_signal("item_state_changed"):
		NetworkManager.item_state_changed.connect(_on_item_state_changed)
	if NetworkManager.has_signal("role_revealed"):
		NetworkManager.role_revealed.connect(_on_role_revealed)
	if NetworkManager.has_signal("hazard_pulse_requested"):
		NetworkManager.hazard_pulse_requested.connect(_on_hazard_pulse_requested)
	if NetworkManager.has_signal("action_denied"):
		NetworkManager.action_denied.connect(_on_action_denied)
	if NetworkManager.has_signal("run_ended"):
		NetworkManager.run_ended.connect(_on_run_ended)
	if EventLog.has_signal("timeline_event_added"):
		EventLog.timeline_event_added.connect(_on_timeline_event_added)
	if return_lobby_button:
		return_lobby_button.pressed.connect(_on_return_lobby_pressed)
	if notebook_filter_option:
		_populate_notebook_filter_options()
		notebook_filter_option.item_selected.connect(_on_notebook_filter_selected)
	if notebook_pin_button:
		notebook_pin_button.pressed.connect(_on_pin_latest_note_pressed)
	if notebook_copy_button:
		notebook_copy_button.pressed.connect(_on_copy_notes_pressed)
	_apply_cli_args()
	_spawn_players()
	_build_rooms()
	_prepare_run_state()
	_refresh_timeline()
	_refresh_notebook_panel()
	_update_status()
	_update_interaction_prompt(_local_peer_id())
	if end_screen:
		end_screen.visible = false
	if notebook_panel:
		notebook_panel.visible = false
	if notebook_hint_label:
		notebook_hint_label.text = "Enter to save, Esc to close"
	if notebook_toast_label:
		notebook_toast_label.text = ""
	if help_panel:
		help_panel.visible = false
	if help_label:
		help_label.text = _build_help_overlay_text()
	print("run_started_transition")
	print("GAME_READY pid=%d" % OS.get_process_id())

func _physics_process(delta: float) -> void:
	tick_counter += 1
	snapshot_timer += delta
	var local_id := _local_peer_id()
	if not run_ended:
		_run_cli_automation(local_id)
		_handle_local_actions(local_id)
	_update_authoritative_sim(delta, local_id)
	_update_evidence_visuals()
	_update_item_visuals()
	_update_interaction_prompt(local_id)
	_update_status()
	if feedback_left > 0.0:
		feedback_left = maxf(feedback_left - delta, 0.0)
		if feedback_left <= 0.0:
			feedback_text = ""
	if notebook_toast_expires_tick >= 0 and tick_counter >= notebook_toast_expires_tick:
		notebook_toast_expires_tick = -1
		if notebook_toast_label:
			notebook_toast_label.text = ""
	_update_hint_label(local_id)
	if run_ended and _pressed_once(KEY_TAB):
		end_timeline_limit = 20 if end_timeline_limit == 8 else 8
		_refresh_end_timeline()
	if notebook_open and Input.is_key_pressed(KEY_ESCAPE):
		_toggle_notebook(false)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_N:
			_toggle_notebook(not notebook_open)
			get_viewport().set_input_as_handled()
			return
		if key_event.keycode == KEY_F1 or key_event.keycode == KEY_H:
			_toggle_help_overlay(not help_open)
			get_viewport().set_input_as_handled()
			return
		if notebook_open and key_event.keycode == KEY_ESCAPE:
			_toggle_notebook(false)
			get_viewport().set_input_as_handled()
			return
		if notebook_open and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER):
			if notebook_input and notebook_input.has_focus():
				if key_event.shift_pressed:
					notebook_input.text = _apply_quick_tag_shortcuts(notebook_input.text, NOTEBOOK_FILTER_SUSPECT)
					notebook_input.caret_column = notebook_input.text.length()
					get_viewport().set_input_as_handled()
					return
				if key_event.ctrl_pressed:
					notebook_input.text = _apply_quick_tag_shortcuts(notebook_input.text, NOTEBOOK_FILTER_ALIBI)
					notebook_input.caret_column = notebook_input.text.length()
					get_viewport().set_input_as_handled()
					return
				if key_event.alt_pressed:
					notebook_input.text = _apply_quick_tag_shortcuts(notebook_input.text, NOTEBOOK_FILTER_EVIDENCE)
					notebook_input.caret_column = notebook_input.text.length()
					get_viewport().set_input_as_handled()
					return
			_submit_notebook_note()
			get_viewport().set_input_as_handled()

func _prepare_run_state() -> void:
	_on_evidence_state_changed(RunState.evidence_by_id)
	_on_item_state_changed(NetworkManager.get_items_snapshot() if NetworkManager.has_method("get_items_snapshot") else {})
	_on_role_revealed(str(RunState.local_role))

func _spawn_players() -> void:
	players.clear()
	if player_root == null:
		return
	for child in player_root.get_children():
		child.queue_free()
	var ids: Array = RunState.player_ids
	if ids.is_empty():
		ids = NetworkManager.players
	var sorted_ids: Array[int] = []
	for peer_raw in ids:
		sorted_ids.append(int(peer_raw))
	sorted_ids.sort()
	for i in range(sorted_ids.size()):
		var peer_id := sorted_ids[i]
		var actor = player_scene.instantiate()
		actor.name = "Player_%d" % peer_id
		player_root.add_child(actor)
		actor.global_position = Vector2(80 + SPAWN_X_STEP * i, 300)
		if actor.has_method("configure_for_peer"):
			actor.configure_for_peer(peer_id)
		players[peer_id] = actor

func _build_rooms() -> void:
	if room_builder and room_builder.has_method("build_from_chain"):
		room_builder.build_from_chain(RunState.room_chain)

func _update_authoritative_sim(delta: float, local_id: int) -> void:
	var move_axis := Input.get_axis("ui_left", "ui_right")
	var jump_pressed := Input.is_action_just_pressed("ui_accept")
	if NetworkManager.is_host and NetworkManager.is_run_active():
		for peer_id in players.keys():
			var actor = players[peer_id]
			var input_pack: Dictionary = NetworkManager.consume_peer_input(peer_id)
			if peer_id == local_id:
				input_pack = {"move": move_axis, "jump": jump_pressed, "seq": tick_counter}
			actor.simulate_step(float(input_pack.get("move", 0.0)), bool(input_pack.get("jump", false)), delta)
			var room_slot := _room_slot_for_position(actor.global_position)
			NetworkManager.update_authoritative_player_state(peer_id, actor.global_position, room_slot)
			if NetworkManager.has_method("track_noise_trace") and actor.has_method("is_carrying_artifact"):
				NetworkManager.track_noise_trace(peer_id, room_slot, actor.is_carrying_artifact())
		if snapshot_timer >= SNAPSHOT_INTERVAL:
			snapshot_timer = 0.0
			var snapshot := {}
			for peer_id in players.keys():
				var actor = players[peer_id]
				snapshot[str(peer_id)] = {"p": actor.global_position, "v": actor.velocity}
			NetworkManager.broadcast_state(snapshot, tick_counter)
	elif not NetworkManager.is_host and not run_ended:
		NetworkManager.send_client_input(move_axis, jump_pressed, tick_counter)
		if players.has(local_id):
			players[local_id].simulate_step(move_axis, jump_pressed, delta)

func _handle_local_actions(local_id: int) -> void:
	if notebook_open or not players.has(local_id) or run_ended:
		return
	if _pressed_once(KEY_Q):
		var artifact_id := _find_nearest_ground_artifact_id(local_id)
		if artifact_id > 0:
			NetworkManager.request_pickup(artifact_id)
	if _pressed_once(KEY_Y):
		var item_id := _find_nearest_ground_item_id(local_id)
		if item_id > 0:
			NetworkManager.request_pickup_item(item_id)
	if _pressed_once(KEY_E):
		NetworkManager.request_drop()
	if _pressed_once(KEY_R):
		var steal_id := _find_nearest_carried_artifact_id(local_id)
		if steal_id > 0:
			NetworkManager.request_steal(steal_id)
	if _pressed_once(KEY_F):
		NetworkManager.request_forge(_room_slot_for_position(players[local_id].global_position))
	if _pressed_once(KEY_G):
		NetworkManager.request_sabotage(_room_slot_for_position(players[local_id].global_position))
	if _pressed_once(KEY_T):
		var check_id := _find_nearest_artifact_for_check(local_id, WARDEN_CHECK_RANGE)
		if check_id > 0:
			NetworkManager.request_check_artifact(check_id)

func _run_cli_automation(local_id: int) -> void:
	if local_id <= 0 or not players.has(local_id):
		return
	if cli_auto_pickup and not cli_auto_pickup_done and NetworkManager.is_run_active():
		if NetworkManager.get_local_carried_artifact_id() > 0:
			var extraction_slot := _extraction_room_slot()
			players[local_id].global_position = Vector2(80 + float(extraction_slot) * ROOM_WIDTH, 300)
			cli_auto_pickup_done = true
		else:
			var pickup_id := _find_nearest_ground_artifact_id(local_id)
			if pickup_id > 0 and RunState.evidence_by_id.has(pickup_id):
				var artifact: Dictionary = RunState.evidence_by_id[pickup_id]
				players[local_id].global_position = artifact.get("world_pos", players[local_id].global_position)
				NetworkManager.request_pickup(pickup_id)
	if cli_auto_role_action and not cli_auto_role_action_done and NetworkManager.is_run_active():
		if str(RunState.local_role) == ROLE_SERVICE_SCRIPT.ROLE_VEIL:
			NetworkManager.request_sabotage(_room_slot_for_position(players[local_id].global_position))
			cli_auto_role_action_done = true

func _find_nearest_ground_artifact_id(local_id: int) -> int:
	if not players.has(local_id):
		return 0
	var best_id := 0
	var best_dist := INF
	var local_pos: Vector2 = players[local_id].global_position
	for artifact_raw in RunState.evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) != 0:
			continue
		var pos: Vector2 = artifact.get("world_pos", Vector2.ZERO)
		var dist := local_pos.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best_id = artifact_id
	return best_id

func _find_nearest_ground_item_id(local_id: int) -> int:
	if not players.has(local_id) or not NetworkManager.has_method("get_items_snapshot"):
		return 0
	var items: Dictionary = NetworkManager.get_items_snapshot()
	var best_id := 0
	var best_dist := INF
	var local_pos: Vector2 = players[local_id].global_position
	for item_raw in items.keys():
		var item_id := int(item_raw)
		var item_data: Dictionary = items[item_id]
		if int(item_data.get("owner_peer_id", 0)) != 0:
			continue
		if bool(item_data.get("consumed", false)):
			continue
		var pos: Vector2 = item_data.get("world_pos", Vector2.ZERO)
		var dist := local_pos.distance_to(pos)
		if dist < best_dist:
			best_dist = dist
			best_id = item_id
	return best_id

func _find_nearest_carried_artifact_id(local_id: int) -> int:
	if not players.has(local_id):
		return 0
	var best_id := 0
	var best_dist := INF
	var local_pos: Vector2 = players[local_id].global_position
	for artifact_raw in RunState.evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		var owner_peer := int(artifact.get("owner_peer_id", 0))
		if owner_peer == 0 or owner_peer == local_id or not players.has(owner_peer):
			continue
		var dist := local_pos.distance_to(players[owner_peer].global_position)
		if dist < best_dist:
			best_dist = dist
			best_id = artifact_id
	return best_id

func _find_nearest_artifact_for_check(local_id: int, max_range: float) -> int:
	if not players.has(local_id):
		return 0
	var best_id := 0
	var best_dist := max_range
	var local_pos: Vector2 = players[local_id].global_position
	for artifact_raw in RunState.evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		var owner_peer := int(artifact.get("owner_peer_id", 0))
		var target_pos: Vector2 = artifact.get("world_pos", Vector2.ZERO)
		if owner_peer != 0 and players.has(owner_peer):
			target_pos = players[owner_peer].global_position + Vector2(0, -56)
		var dist := local_pos.distance_to(target_pos)
		if dist <= best_dist:
			best_dist = dist
			best_id = artifact_id
	return best_id

func _on_state_snapshot(snapshot: Dictionary, _tick: int) -> void:
	if NetworkManager.is_host:
		return
	for key in snapshot.keys():
		var peer_id := int(key)
		if not players.has(peer_id):
			continue
		var actor = players[peer_id]
		var state: Dictionary = snapshot[key]
		actor.apply_snapshot(state.get("p", actor.global_position), state.get("v", actor.velocity))

func _on_evidence_state_changed(evidence_by_id: Dictionary) -> void:
	_sync_evidence_nodes(evidence_by_id)

func _on_item_state_changed(items_by_id: Dictionary) -> void:
	_sync_item_nodes(items_by_id)

func _on_role_revealed(role_name: String) -> void:
	if role_label:
		role_label.text = "Your role: %s%s" % [role_name, _local_role_hint(role_name)]

func _on_hazard_pulse_requested(room_slot: int, _source_peer_id: int, reason: String) -> void:
	if room_builder and room_builder.has_method("flash_hazard_indicator"):
		room_builder.flash_hazard_indicator(room_slot, 0.3)
	if room_builder and room_builder.has_method("flash_disturbance_indicator") and reason.find("camera_jam") != -1:
		room_builder.flash_disturbance_indicator(room_slot, 0.3, "CAM")

func _on_action_denied(reason: String) -> void:
	feedback_text = "Denied: %s" % reason
	feedback_left = 1.2

func _on_timeline_event_added(event: Dictionary) -> void:
	if str(event.get("event_type", "")) == "notebook_note_added":
		if int(event.get("target_peer_id", -1)) == _local_peer_id():
			_refresh_notebook_panel()
	elif str(event.get("event_type", "")) == "warden_check_result":
		_maybe_autonote_on_inspection(event)
	_refresh_timeline()

func _on_run_ended(payload: Dictionary) -> void:
	run_ended = true
	end_payload = payload.duplicate(true)
	end_timeline_limit = 8
	last_verify_status = ""
	if NetworkManager.is_host:
		var verify_result := _verify_run_event_stream()
		last_verify_status = _verify_status_text(verify_result)
	last_report_user_path = _write_run_report()
	_render_end_screen()

func _toggle_notebook(force_open: Variant = null) -> void:
	notebook_open = not notebook_open if force_open == null else bool(force_open)
	if notebook_panel:
		notebook_panel.visible = notebook_open
	if notebook_open:
		_refresh_notebook_panel()
		if notebook_hint_label:
			notebook_hint_label.text = "Enter to save, Esc to close"
		if notebook_filter_option:
			notebook_filter_option.select(_notebook_filter_index(notebook_filter_mode))
		if notebook_input:
			notebook_input.grab_focus()
	elif notebook_input:
		notebook_input.release_focus()

func _refresh_notebook_panel() -> void:
	if notebook_notes_label == null:
		return
	var local_id := _local_peer_id()
	var lines := _build_private_notes_sections(EventLog, local_id, NOTEBOOK_RECENT_LIMIT, notebook_filter_mode)
	if lines.is_empty():
		notebook_notes_label.text = "No notes yet"
	else:
		notebook_notes_label.text = "\n".join(lines)
	if notebook_pin_button:
		var latest_note := _latest_notebook_note(EventLog, local_id)
		var has_note := not latest_note.is_empty()
		notebook_pin_button.disabled = not has_note
		if has_note:
			notebook_pin_button.text = "Unpin latest note" if bool(latest_note.get("pinned", false)) else "Pin latest note"
		else:
			notebook_pin_button.text = "Pin latest note"
	if notebook_toast_label and notebook_toast_expires_tick < 0:
		notebook_toast_label.text = ""

func _submit_notebook_note() -> void:
	if notebook_input == null:
		return
	var note_text := _sanitize_notebook_text(notebook_input.text)
	if note_text.is_empty():
		feedback_text = "Empty note"
		feedback_left = 1.2
		return
	var local_id := _local_peer_id()
	var room_slot := _room_slot_for_local_peer(local_id)
	_add_notebook_note(note_text, local_id, tick_counter, room_slot)
	notebook_input.text = ""
	_refresh_notebook_panel()

func _add_notebook_note(text: String, local_peer_id: int, note_tick: int, room_slot: int, event_log: Node = null) -> void:
	var note_text := _sanitize_notebook_text(text)
	if note_text.is_empty():
		return
	var el: Node = event_log if event_log != null else EventLog
	if el == null:
		return
	el.add_event(_build_notebook_note_event(note_text, local_peer_id, note_tick, _next_local_event_id(el), room_slot))

func _build_notebook_note_event(text: String, local_peer_id: int, note_tick: int, event_id: int, room_slot: int) -> Dictionary:
	var normalized := _normalize_notebook_note(text)
	return {
		"event_id": event_id,
		"tick": note_tick,
		"room_slot": room_slot,
		"actor_peer_id": local_peer_id,
		"event_type": "notebook_note_added",
		"visibility": "private",
		"target_peer_id": local_peer_id,
		"meta": {
			"text": str(normalized.get("text", "")),
			"tag": str(normalized.get("tag", ""))
		}
	}

func _sanitize_notebook_text(text: String) -> String:
	return text.replace("\n", " ").replace("\r", " ").strip_edges().left(NOTEBOOK_MAX_LEN)

func _normalize_notebook_note(text: String) -> Dictionary:
	var cleaned := _sanitize_notebook_text(text)
	var upper := cleaned.to_upper()
	var tag := ""
	var parts := cleaned.split(":", false, 1)
	if parts.size() == 2:
		var prefix := _sanitize_notebook_text(parts[0]).to_upper()
		if not prefix.is_empty() and prefix.length() <= 16 and prefix.find(" ") == -1:
			tag = prefix
			cleaned = _sanitize_notebook_text(parts[1])
	if tag.is_empty() and (upper.begins_with("ALIBI:") or upper.find("ALIBI") != -1):
		tag = NOTEBOOK_FILTER_ALIBI
	elif tag.is_empty() and (upper.begins_with("SUSPECT:") or upper.find("SUSPECT") != -1):
		tag = NOTEBOOK_FILTER_SUSPECT
	elif tag.is_empty() and (upper.begins_with("CHECKED E") or upper.begins_with("E") and cleaned.length() > 1 and cleaned[1].is_valid_int()):
		tag = "EVIDENCE"
	return {"text": cleaned, "tag": tag}

func _build_notebook_pin_event(note_event_id: int, pinned: bool, local_peer_id: int, note_tick: int) -> Dictionary:
	return {
		"event_id": _next_local_event_id(EventLog),
		"tick": note_tick,
		"room_slot": _room_slot_for_local_peer(local_peer_id),
		"actor_peer_id": local_peer_id,
		"event_type": "notebook_note_pin_toggled",
		"visibility": "private",
		"target_peer_id": local_peer_id,
		"meta": {"note_event_id": note_event_id, "pinned": pinned}
	}

func _next_local_event_id(event_log: Node) -> int:
	var max_id := 0
	for event_raw in event_log.events:
		var event: Dictionary = event_raw
		max_id = maxi(max_id, int(event.get("event_id", 0)))
	return max_id + 1

func _maybe_autonote_on_inspection(event: Dictionary) -> void:
	var local_peer_id := _local_peer_id()
	if local_peer_id <= 0:
		return
	_maybe_autonote_on_inspection_with_event_log(EventLog, event, local_peer_id, int(event.get("tick", tick_counter)))
	_refresh_notebook_panel()

func _maybe_autonote_on_inspection_with_event_log(event_log: Node, event: Dictionary, local_peer_id: int, now_tick: int) -> void:
	if event_log == null or local_peer_id <= 0:
		return
	if str(event.get("event_type", "")) != "warden_check_result":
		return
	if int(event.get("target_peer_id", -1)) != local_peer_id:
		return
	var meta: Dictionary = event.get("meta", {})
	var artifact_id := int(meta.get("artifact_id", 0))
	if artifact_id <= 0:
		return
	var note_key := "artifact_%d" % artifact_id
	var last_tick := int(notebook_last_autonote_tick_by_key.get(note_key, -999999))
	if now_tick - last_tick < NOTEBOOK_INSPECTION_AUTONOTE_TICKS:
		return
	notebook_last_autonote_tick_by_key[note_key] = now_tick
	var room_slot := int(event.get("room_slot", -1))
	var note_text := "Checked E%d" % artifact_id
	if room_slot >= 0:
		note_text += " in room %d" % room_slot
	var label := _sanitize_notebook_text(str(meta.get("label", "")))
	if not label.is_empty():
		note_text += ": %s" % label
	_add_notebook_note(note_text, local_peer_id, now_tick, room_slot, event_log)

func apply_autonote_for_test(event_log: Node, event: Dictionary, local_peer_id: int, now_tick: int) -> void:
	_maybe_autonote_on_inspection_with_event_log(event_log, event, local_peer_id, now_tick)

func _refresh_timeline() -> void:
	if timeline_label == null:
		return
	var local_id := _local_peer_id()
	var fact_lines := _format_timeline_grouped(EventLog.get_recent_public(6))
	var note_lines := _build_private_notes_feed_lines(EventLog, local_id, 4)
	timeline_label.text = "Facts\n%s\n\nYour Notes\n%s" % [
		_join_or_placeholder(fact_lines, "No facts yet"),
		_join_or_placeholder(note_lines, "No notes yet")
	]

func _normalize_notebook_filter_mode(filter_mode: String) -> String:
	var mode := filter_mode.to_upper().strip_edges()
	if mode in [
		NOTEBOOK_FILTER_ALL,
		NOTEBOOK_FILTER_PINNED,
		NOTEBOOK_FILTER_EVIDENCE,
		NOTEBOOK_FILTER_SUSPECT,
		NOTEBOOK_FILTER_ALIBI,
		NOTEBOOK_FILTER_OTHER
	]:
		return mode
	return NOTEBOOK_FILTER_ALL

func _effective_notebook_tag(tag: String) -> String:
	var normalized := tag.to_upper().strip_edges()
	return NOTEBOOK_FILTER_OTHER if normalized.is_empty() else normalized

func _note_matches_filter(note: Dictionary, filter_mode: String) -> bool:
	var mode := _normalize_notebook_filter_mode(filter_mode)
	if mode == NOTEBOOK_FILTER_ALL:
		return true
	if mode == NOTEBOOK_FILTER_PINNED:
		return bool(note.get("pinned", false))
	return _effective_notebook_tag(str(note.get("tag", ""))) == mode

func _render_notebook_note_line(note: Dictionary) -> String:
	var prefix := "[PIN] " if bool(note.get("pinned", false)) else ""
	var tick := int(note.get("tick", -1))
	var text := str(note.get("text", ""))
	var tag := str(note.get("tag", ""))
	var effective_tag := _effective_notebook_tag(tag)
	if effective_tag != NOTEBOOK_FILTER_OTHER:
		text = "%s: %s" % [effective_tag, text]
	return "%st%04d: %s" % [prefix, tick, text] if tick >= 0 else "%s%s" % [prefix, text]

func _build_private_notes_sections(event_log: Node, local_peer_id: int, limit: int, filter_mode: String) -> Array[String]:
	var lines: Array[String] = []
	var filtered_notes := _collect_notebook_notes(event_log, local_peer_id, limit, filter_mode)
	var pinned_notes: Array = []
	var other_notes: Array = []
	for note_raw in filtered_notes:
		var note: Dictionary = note_raw
		if bool(note.get("pinned", false)):
			pinned_notes.append(note)
		else:
			other_notes.append(note)
	if not pinned_notes.is_empty():
		lines.append("PINNED NOTES")
		for note_raw in pinned_notes:
			lines.append(_render_notebook_note_line(note_raw))
	if not other_notes.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("OTHER NOTES")
		for note_raw in other_notes:
			lines.append(_render_notebook_note_line(note_raw))
	return lines

func _build_notebook_copy_text(event_log: Node, local_peer_id: int, limit: int, filter_mode: String) -> String:
	return "\n".join(_build_private_notes_sections(event_log, local_peer_id, limit, filter_mode))

func _private_toast(_msg: String) -> void:
	if notebook_toast_label == null:
		return
	notebook_toast_label.text = _msg
	notebook_toast_expires_tick = tick_counter + 90

func _format_timeline_grouped(events: Array, private_feed: bool = false) -> Array[String]:
	var lines: Array[String] = []
	var last_chapter := ""
	var last_bookmark := ""
	for event_raw in events:
		var event: Dictionary = event_raw
		var chapter := _event_chapter(str(event.get("event_type", "")), private_feed)
		if chapter != last_chapter:
			if not lines.is_empty():
				lines.append("")
			lines.append(chapter)
			last_chapter = chapter
			last_bookmark = ""
		var bookmark := _event_bookmark(str(event.get("event_type", "")))
		if not bookmark.is_empty() and bookmark != last_bookmark:
			lines.append("--- BOOKMARK: %s ---" % bookmark)
			last_bookmark = bookmark
		lines.append(_format_timeline_line(event, private_feed))
	return lines

func _format_timeline_line(event: Dictionary, private_feed: bool = false) -> String:
	var tick := int(event.get("tick", -1))
	var event_id := int(event.get("event_id", -1))
	var slot := int(event.get("room_slot", -1))
	var tag := _event_tag(str(event.get("event_type", "")), private_feed)
	return "%s t%04d e%04d s%02d %s" % [tag, tick, event_id, slot, _event_summary(event, private_feed)]

func _event_tag(event_type: String, private_feed: bool = false) -> String:
	match event_type:
		"run_started", "run_ended":
			return "[RUN]"
		"artifact_picked", "artifact_dropped", "artifact_stolen", "extraction_window_started", "extraction_window_aborted", "extraction_completed":
			return "[EVID]"
		"sabotage_accident", "sabotage_camera_jam", "hazard_state_changed":
			return "[HAZ]"
		"evidence_checked", "warden_check_result", "warden_camera_jam_note":
			return "[WARD]"
		"item_picked", "item_used", "item_note", "noise_trace":
			return "[ITEM]"
		"notebook_note_added":
			return "[NOTE]" if private_feed else "[INFO]"
		_:
			return "[INFO]"

func _event_chapter(event_type: String, private_feed: bool = false) -> String:
	match event_type:
		"run_started":
			return "RUN START"
		"artifact_picked", "artifact_dropped", "artifact_stolen":
			return "EVIDENCE MOVES"
		"extraction_window_started", "extraction_window_aborted", "extraction_completed":
			return "EXTRACTION"
		"sabotage_accident", "sabotage_camera_jam", "hazard_state_changed":
			return "DISTURBANCES"
		"evidence_checked", "warden_check_result", "warden_camera_jam_note":
			return "INSPECTIONS"
		"item_picked", "item_used", "item_note", "noise_trace":
			return "ITEM EFFECTS / TRACES"
		"run_ended":
			return "RUN END"
		"notebook_note_added":
			return "YOUR NOTES" if private_feed else "OTHER"
		"notebook_note_pin_toggled":
			return "YOUR NOTES" if private_feed else "OTHER"
		_:
			return "OTHER"

func _event_bookmark(event_type: String) -> String:
	match event_type:
		"run_started":
			return "RUN START"
		"artifact_stolen":
			return "THEFT"
		"sabotage_accident", "sabotage_camera_jam":
			return "SABOTAGE"
		"evidence_checked", "warden_check_result":
			return "INSPECTION"
		"extraction_window_started", "extraction_window_aborted", "extraction_completed":
			return "EXTRACTION"
		"run_ended":
			return "RUN END"
		_:
			return ""

func _event_summary(event: Dictionary, private_feed: bool = false) -> String:
	var event_type := str(event.get("event_type", "unknown"))
	var actor := int(event.get("actor_peer_id", -1))
	var actor_text := "P%d" % actor if actor >= 0 else "-"
	var slot := int(event.get("room_slot", -1))
	var meta: Dictionary = event.get("meta", {})
	match event_type:
		"run_started":
			return "Run started"
		"run_ended":
			return "Run ended"
		"artifact_picked":
			return "%s picked E%d" % [actor_text, int(meta.get("artifact_id", 0))]
		"artifact_dropped":
			return "%s dropped E%d" % [actor_text, int(meta.get("artifact_id", 0))]
		"artifact_stolen":
			return "%s stole E%d" % [actor_text, int(meta.get("artifact_id", 0))]
		"sabotage_accident":
			return str(meta.get("label", "Power flicker disturbed the room"))
		"sabotage_camera_jam":
			return str(meta.get("label", "Camera feed glitched in the room"))
		"hazard_state_changed":
			return "Hazard pulse"
		"evidence_checked":
			return "Inspection occurred in room %d" % slot
		"warden_check_result":
			return "Inspection E%d scored %d" % [int(meta.get("artifact_id", 0)), int(meta.get("score", -1))]
		"warden_camera_jam_note":
			return str(meta.get("label", "Camera jam residue lowered confidence"))
		"item_picked":
			return "Item picked"
		"item_used":
			return str(meta.get("label", "Item used"))
		"item_note":
			return str(meta.get("label", "Item note"))
		"noise_trace":
			return "Noise trace"
		"extraction_window_started":
			return "Extraction stabilizing (%dt)" % int(meta.get("duration_ticks", 0))
		"extraction_window_aborted":
			return "Extraction window collapsed"
		"extraction_completed":
			return "%s completed extraction with E%d" % [actor_text, int(meta.get("artifact_id", 0))]
		"notebook_note_added":
			return str(meta.get("text", "")) if private_feed else "Notebook note"
		"notebook_note_pin_toggled":
			return "Notebook pin updated"
		_:
			return event_type

func _update_interaction_prompt(local_id: int) -> void:
	if prompt_label == null:
		return
	if run_ended or not players.has(local_id):
		prompt_label.text = ""
		return
	var prompts: Array[String] = []
	var local_pos: Vector2 = players[local_id].global_position
	var local_slot := _room_slot_for_position(local_pos)
	var carried_id: int = int(NetworkManager.get_local_carried_artifact_id())
	if carried_id > 0:
		prompts.append(_carry_objective_prompt(local_slot))
	else:
		var pickup_id := _find_nearest_ground_artifact_id(local_id)
		if pickup_id > 0 and RunState.evidence_by_id.has(pickup_id):
			prompts.append("Find Evidence (press Q to pick up)")
	var item_id := _find_nearest_ground_item_id(local_id)
	if item_id > 0 and NetworkManager.has_method("get_items_snapshot"):
		var items: Dictionary = NetworkManager.get_items_snapshot()
		if items.has(item_id):
			prompts.append("Y: Pick up %s" % str(Dictionary(items[item_id]).get("display_name", "Item")))
	if carried_id > 0:
		prompts.append("E: Drop")
	var steal_id := _find_nearest_carried_artifact_id(local_id)
	if steal_id > 0:
		prompts.append("R: Steal E%d" % steal_id)
	if str(RunState.local_role) == ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		prompts.append("F: Forge")
		prompts.append("G: Camera Jam" if NetworkManager.can_local_use_sabotage(local_slot) else "G: Camera Jam (cooldown)")
	if str(RunState.local_role) == ROLE_SERVICE_SCRIPT.ROLE_WARDEN:
		var check_id := _find_nearest_artifact_for_check(local_id, WARDEN_CHECK_RANGE)
		if check_id > 0:
			prompts.append("T: Check")
	prompt_label.text = " | ".join(prompts)

func _carry_objective_prompt(local_slot: int) -> String:
	var extraction_slot := _extraction_room_slot()
	if local_slot == extraction_slot:
		if NetworkManager.is_local_extraction_window_active():
			return "Deliver Evidence now: EXTRACT room (%d) ready | Extraction stabilizing..." % extraction_slot
		return "Deliver Evidence now: EXTRACT room (%d) ready" % extraction_slot
	var room_delta := extraction_slot - local_slot
	var direction := "right" if room_delta > 0 else "left"
	return "Deliver Evidence to EXTRACT room (%d) | %d room %s" % [extraction_slot, abs(room_delta), direction]

func _update_status() -> void:
	if status_label == null:
		return
	var parts: Array[String] = []
	parts.append("Seed %d" % int(RunState.run_seed))
	parts.append("Players %d" % int(RunState.player_ids.size()))
	parts.append("Host %s" % str(NetworkManager.is_host))
	parts.append("Extract: room %d" % _extraction_room_slot())
	var local_items: Array = NetworkManager.get_local_item_names() if NetworkManager.has_method("get_local_item_names") else []
	if not local_items.is_empty():
		parts.append("Items: %s" % ", ".join(local_items))
	if NetworkManager.is_local_extraction_window_active():
		parts.append("Extraction stabilizing...")
	if feedback_left > 0.0 and not feedback_text.is_empty():
		parts.append(feedback_text)
	status_label.text = " | ".join(parts)
	if carry_label:
		var carried_id: int = int(NetworkManager.get_local_carried_artifact_id())
		carry_label.text = "Carrying: E%d" % carried_id if carried_id > 0 else "Carrying: None"

func _sync_evidence_nodes(evidence_by_id: Dictionary) -> void:
	if evidence_root == null:
		return
	for artifact_key in evidence_nodes.keys().duplicate():
		if evidence_by_id.has(artifact_key):
			continue
		evidence_nodes[artifact_key].queue_free()
		evidence_nodes.erase(artifact_key)
	for artifact_raw in evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = evidence_by_id[artifact_id]
		if not evidence_nodes.has(artifact_id):
			var node = evidence_scene.instantiate()
			node.name = "Evidence_%d" % artifact_id
			evidence_root.add_child(node)
			evidence_nodes[artifact_id] = node
		evidence_nodes[artifact_id].configure(artifact)

func _sync_item_nodes(items_by_id: Dictionary) -> void:
	if item_root == null:
		return
	for item_key in item_nodes.keys().duplicate():
		if items_by_id.has(item_key) and not bool(Dictionary(items_by_id[item_key]).get("consumed", false)):
			continue
		item_nodes[item_key].queue_free()
		item_nodes.erase(item_key)
	for item_raw in items_by_id.keys():
		var item_id := int(item_raw)
		var item_data: Dictionary = items_by_id[item_id]
		if bool(item_data.get("consumed", false)) or int(item_data.get("owner_peer_id", 0)) != 0:
			continue
		if not item_nodes.has(item_id):
			var node = ITEM_PICKUP_SCENE.instantiate()
			node.name = "Item_%d" % item_id
			item_root.add_child(node)
			item_nodes[item_id] = node
		if item_nodes[item_id].has_method("configure"):
			item_nodes[item_id].configure(item_data)

func _update_evidence_visuals() -> void:
	var carried_by_peer: Dictionary = {}
	for artifact_raw in RunState.evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = RunState.evidence_by_id[artifact_id]
		if not evidence_nodes.has(artifact_id):
			continue
		var owner_peer := int(artifact.get("owner_peer_id", 0))
		var node = evidence_nodes[artifact_id]
		if owner_peer == 0:
			node.sync_state(artifact)
		elif players.has(owner_peer):
			node.sync_state(artifact)
			node.set_visual_position(players[owner_peer].global_position + Vector2(0, -56))
			carried_by_peer[owner_peer] = artifact_id
	for peer_id in players.keys():
		if players[peer_id].has_method("set_carrying_artifact"):
			players[peer_id].set_carrying_artifact(carried_by_peer.has(peer_id))

func _update_item_visuals() -> void:
	pass

func _render_end_screen() -> void:
	if end_screen == null:
		return
	end_screen.visible = true
	if end_seed_label:
		end_seed_label.text = "Seed: %d" % int(end_payload.get("seed", RunState.run_seed))
	if end_reason_label:
		end_reason_label.text = "Outcome: RUN COMPLETE (%s)" % str(end_payload.get("reason", "unknown"))
	_render_end_roles()
	_render_end_summary()
	_refresh_end_timeline()

func _render_end_roles() -> void:
	if end_roles_label == null:
		return
	var roles: Dictionary = end_payload.get("roles_reveal", {})
	var ids: Array = roles.keys()
	ids.sort()
	var lines: Array[String] = []
	for peer_key in ids:
		lines.append("P%s: %s" % [str(peer_key), str(roles[peer_key])])
	end_roles_label.text = "Role Reveal\n%s" % _join_or_placeholder(lines, "No roles")

func _render_end_summary() -> void:
	if end_summary_label == null:
		return
	var summary: Dictionary = end_payload.get("summary_by_peer", {})
	var ids: Array = summary.keys()
	ids.sort()
	var lines: Array[String] = []
	for peer_key in ids:
		var row: Dictionary = summary[peer_key]
		lines.append("P%s pick:%d drop:%d steal:%d carry_end:%d" % [
			str(peer_key),
			int(row.get("picked", 0)),
			int(row.get("dropped", 0)),
			int(row.get("stolen", 0)),
			int(row.get("carrying_end", 0))
		])
	var local_id := _local_peer_id()
	var stats_lines := _build_run_stats_lines(_build_run_stats(EventLog, local_id))
	var action_lines := _build_action_summary_lines(EventLog, local_id, 8)
	var sections: Array[String] = ["Evidence Summary", _join_or_placeholder(lines, "No summary"), "", "Stats", _join_or_placeholder(stats_lines, "No stats"), "", "Action Summary", _join_or_placeholder(action_lines, "No actions")]
	end_summary_label.text = "\n".join(sections)

func _refresh_end_timeline() -> void:
	if end_timeline_label == null:
		return
	var local_id := _local_peer_id()
	var fact_lines := _format_timeline_grouped(EventLog.get_recent_public(end_timeline_limit))
	var note_lines := _build_private_notes_feed_lines(EventLog, local_id, end_timeline_limit)
	end_timeline_label.text = "FACTS\n%s\n\nYOUR NOTES (private)\n%s" % [
		_join_or_placeholder(fact_lines, "No facts recorded"),
		_join_or_placeholder(note_lines, "No private notes")
	]
	if end_more_label:
		var extra: Array[String] = ["TAB: %s timeline" % ("show less" if end_timeline_limit > 8 else "show more")]
		if not last_verify_status.is_empty():
			extra.append(last_verify_status)
		if not last_report_user_path.is_empty():
			extra.append("Report: written to %s" % last_report_user_path)
			# REPORT_DIFF is handled by scripts/diff_run_reports.ps1 against the FACTS block.
		end_more_label.text = "\n\n".join(extra)

func _build_run_report_lines(seed_value: int, end_reason: String, local_peer_id: int, run_counter: int, fact_lines: Array[String], note_lines: Array[String]) -> Array[String]:
	var lines: Array[String] = []
	var duration_ticks := _report_duration_ticks(EventLog)
	lines.append("DeductionDelve Run Report")
	lines.append("Seed: %d" % seed_value)
	lines.append("Local Peer: P%d" % local_peer_id)
	if RunState != null and str(RunState.local_role) != "" and str(RunState.local_role) != "Unknown":
		lines.append("Role: %s" % str(RunState.local_role))
	lines.append("End Reason: %s" % end_reason)
	lines.append("Duration: %s" % _format_report_duration(duration_ticks))
	lines.append("Run Counter: %d" % run_counter)
	lines.append("Outcome: RUN COMPLETE")
	lines.append("")
	lines.append("Role Reveal")
	var roles: Dictionary = end_payload.get("roles_reveal", {})
	var role_ids: Array = roles.keys()
	role_ids.sort()
	for peer_key in role_ids:
		lines.append("P%s: %s" % [str(peer_key), str(roles[peer_key])])
	lines.append("")
	lines.append("Evidence Summary")
	var summary: Dictionary = end_payload.get("summary_by_peer", {})
	var summary_ids: Array = summary.keys()
	summary_ids.sort()
	for peer_key in summary_ids:
		var row: Dictionary = summary[peer_key]
		lines.append("P%s pick:%d drop:%d steal:%d carry_end:%d" % [
			str(peer_key), int(row.get("picked", 0)), int(row.get("dropped", 0)), int(row.get("stolen", 0)), int(row.get("carrying_end", 0))
		])
	lines.append("")
	lines.append("FACTS")
	for line in fact_lines:
		lines.append(line)
	lines.append("")
	lines.append("YOUR NOTES (private)")
	for line in note_lines:
		lines.append(line)
	lines.append("")
	lines.append("STATS")
	for line in _build_run_stats_lines(_build_run_stats(EventLog, local_peer_id)):
		lines.append(line)
	lines.append("")
	lines.append("ACTION SUMMARY")
	for line in _build_action_summary_lines(EventLog, local_peer_id, 12):
		lines.append(line)
	return lines

func _build_run_report_user_path(seed_value: int, end_reason: String, local_peer_id: int, run_counter: int) -> String:
	return "user://reports/run_%d_%s_%d_%d.txt" % [seed_value, end_reason, local_peer_id, run_counter]

func _write_run_report() -> String:
	var local_id := _local_peer_id()
	var seed_value := int(end_payload.get("seed", RunState.run_seed))
	var end_reason := str(end_payload.get("reason", "unknown"))
	var run_counter := int(RunState.run_counter)
	var fact_lines := _format_timeline_grouped(EventLog.get_recent_public(9999))
	var note_lines := _build_private_notes_feed_lines(EventLog, local_id, 9999)
	var lines := _build_run_report_lines(seed_value, end_reason, local_id, run_counter, fact_lines, note_lines)
	DirAccess.make_dir_recursive_absolute("user://reports")
	var user_path := _build_run_report_user_path(seed_value, end_reason, local_id, run_counter)
	var file := FileAccess.open(user_path, FileAccess.WRITE)
	if file == null:
		push_warning("GameController: failed to write report %s" % user_path)
		return ""
	file.store_string("\n".join(lines) + "\n")
	file.close()
	print("RUN_REPORT_WRITTEN path=%s seed=%d local=%d" % [user_path, seed_value, local_id])
	return user_path

func _verify_run_event_stream() -> Dictionary:
	var result := {"ok": true, "checks": 5, "failures": 0, "first": ""}
	var events: Array = EventLog.events.duplicate(true)
	var public_events: Array = EventLog.get_recent_public(9999)
	var private_events: Array = EventLog.get_recent_private_for(_local_peer_id(), 9999)
	var failures: Array[String] = []
	if not _events_sorted_by_tick_and_id(events):
		failures.append("event_order")
	if not _all_events_have_visibility(public_events, "public"):
		failures.append("public_visibility")
	if not _all_events_have_visibility(private_events, "private"):
		failures.append("private_visibility")
	var extraction_slot := _extraction_room_slot()
	for event_raw in public_events:
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) == "extraction_completed" and int(event.get("room_slot", -999)) != extraction_slot:
			failures.append("extraction_slot")
			break
	var run_started_tick := -1
	var run_ended_tick := -1
	for event_raw in events:
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type == "run_started" and run_started_tick < 0:
			run_started_tick = int(event.get("tick", -1))
		if event_type == "run_ended" and run_ended_tick < 0:
			run_ended_tick = int(event.get("tick", -1))
	if run_ended_tick >= 0 and (run_started_tick < 0 or run_ended_tick < run_started_tick):
		failures.append("run_end_order")
	if not failures.is_empty():
		result["ok"] = false
		result["failures"] = failures.size()
		result["first"] = failures[0]
	_print_verify_result(result)
	return result

func _verify_status_text(result: Dictionary) -> String:
	if bool(result.get("ok", false)):
		return "Verify: OK"
	return "Verify: FAIL (%s)" % str(result.get("first", "unknown"))

func _print_verify_result(result: Dictionary) -> void:
	if bool(result.get("ok", false)):
		print("RUN_VERIFY ok=true checks=%d failures=0" % int(result.get("checks", 0)))
	else:
		print("RUN_VERIFY ok=false failures=%d first=%s" % [int(result.get("failures", 0)), str(result.get("first", "unknown"))])

func _events_sorted_by_tick_and_id(events: Array) -> bool:
	var prev_tick := -2147483648
	var prev_event_id := -2147483648
	for event_raw in events:
		var event: Dictionary = event_raw
		var tick := int(event.get("tick", -1))
		var event_id := int(event.get("event_id", -1))
		if tick < prev_tick:
			return false
		if tick == prev_tick and event_id < prev_event_id:
			return false
		prev_tick = tick
		prev_event_id = event_id
	return true

func _all_events_have_visibility(events: Array, expected_visibility: String) -> bool:
	for event_raw in events:
		var event: Dictionary = event_raw
		if str(event.get("visibility", "")) != expected_visibility:
			return false
	return true

func _room_slot_for_position(pos: Vector2) -> int:
	return maxi(int(floor(pos.x / ROOM_WIDTH)), 0)

func _room_slot_for_local_peer(local_id: int) -> int:
	if local_id > 0 and players.has(local_id):
		return _room_slot_for_position(players[local_id].global_position)
	return -1

func _local_peer_id() -> int:
	if multiplayer and multiplayer.multiplayer_peer != null:
		return multiplayer.get_unique_id()
	if NetworkManager.has_method("_mp"):
		var mp = NetworkManager._mp()
		if mp != null and mp.multiplayer_peer != null:
			return mp.get_unique_id()
	return 1

func _local_role_hint(role_name: String) -> String:
	match role_name:
		ROLE_SERVICE_SCRIPT.ROLE_VEIL:
			return " | G camera jam"
		ROLE_SERVICE_SCRIPT.ROLE_WARDEN:
			return " | T inspect evidence"
		_:
			return ""

func _extraction_room_slot() -> int:
	if NetworkManager.extraction_room_slot >= 0:
		return int(NetworkManager.extraction_room_slot)
	return maxi(RunState.room_chain.size() - 1, 0)

func _pressed_once(keycode: int) -> bool:
	var now_pressed := Input.is_key_pressed(keycode)
	var was_pressed := bool(key_latch.get(keycode, false))
	key_latch[keycode] = now_pressed
	return now_pressed and not was_pressed

func _join_or_placeholder(lines: Array[String], placeholder: String) -> String:
	return placeholder if lines.is_empty() else "\n".join(lines)

func _on_return_lobby_pressed() -> void:
	NetworkManager.reset_to_lobby("return_lobby")
	get_tree().change_scene_to_file("res://scenes/Lobby.tscn")

func _on_pin_latest_note_pressed() -> void:
	var local_id := _local_peer_id()
	var latest_note := _latest_notebook_note(EventLog, local_id)
	if latest_note.is_empty():
		return
	EventLog.add_event(_build_notebook_pin_event(
		int(latest_note.get("note_event_id", -1)),
		not bool(latest_note.get("pinned", false)),
		local_id,
		tick_counter
	))
	_refresh_notebook_panel()
	_refresh_timeline()

func _collect_notebook_notes(event_log: Node, local_peer_id: int, limit: int = NOTEBOOK_RECENT_LIMIT, filter_mode: String = NOTEBOOK_FILTER_ALL) -> Array:
	var notes_by_id: Dictionary = {}
	var pin_state_by_id: Dictionary = {}
	if event_log == null:
		return []
	for event_raw in event_log.get_recent_private_for(local_peer_id, 9999):
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type == "notebook_note_added":
			var meta: Dictionary = event.get("meta", {})
			notes_by_id[int(event.get("event_id", -1))] = {
				"note_event_id": int(event.get("event_id", -1)),
				"tick": int(event.get("tick", -1)),
				"text": str(meta.get("text", "")),
				"tag": str(meta.get("tag", "")),
				"pinned": false
			}
		elif event_type == "notebook_note_pin_toggled":
			var meta: Dictionary = event.get("meta", {})
			var note_event_id := int(meta.get("note_event_id", -1))
			if note_event_id >= 0:
				pin_state_by_id[note_event_id] = bool(meta.get("pinned", false))
	var notes: Array = []
	for note_id in notes_by_id.keys():
		var note: Dictionary = notes_by_id[note_id]
		note["pinned"] = bool(pin_state_by_id.get(note_id, false))
		if _note_matches_filter(note, filter_mode):
			notes.append(note)
	notes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if bool(a.get("pinned", false)) != bool(b.get("pinned", false)):
			return bool(a.get("pinned", false))
		var a_tick := int(a.get("tick", -1))
		var b_tick := int(b.get("tick", -1))
		if a_tick != b_tick:
			return a_tick > b_tick
		return int(a.get("note_event_id", -1)) > int(b.get("note_event_id", -1))
	)
	if limit > 0 and notes.size() > limit:
		return notes.slice(0, limit)
	return notes

func _latest_notebook_note(event_log: Node, local_peer_id: int) -> Dictionary:
	if event_log == null:
		return {}
	var latest: Dictionary = {}
	for event_raw in event_log.get_recent_private_for(local_peer_id, 9999):
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) != "notebook_note_added":
			continue
		if latest.is_empty() or int(event.get("tick", -1)) > int(latest.get("tick", -1)) or (int(event.get("tick", -1)) == int(latest.get("tick", -1)) and int(event.get("event_id", -1)) > int(latest.get("note_event_id", -1))):
			var meta: Dictionary = event.get("meta", {})
			latest = {
				"note_event_id": int(event.get("event_id", -1)),
				"tick": int(event.get("tick", -1)),
				"text": str(meta.get("text", "")),
				"tag": str(meta.get("tag", "")),
				"pinned": false
			}
	if latest.is_empty():
		return {}
	for event_raw in event_log.get_recent_private_for(local_peer_id, 9999):
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) != "notebook_note_pin_toggled":
			continue
		var meta: Dictionary = event.get("meta", {})
		if int(meta.get("note_event_id", -1)) == int(latest.get("note_event_id", -2)):
			latest["pinned"] = bool(meta.get("pinned", false))
	return latest

func _build_private_notes_feed_lines(event_log: Node, local_peer_id: int, limit: int) -> Array[String]:
	var lines: Array[String] = []
	var notebook_lines := _build_private_notes_sections(event_log, local_peer_id, limit, NOTEBOOK_FILTER_ALL)
	if not notebook_lines.is_empty():
		lines.append_array(notebook_lines)
	var other_private: Array = []
	if event_log == null:
		return lines
	for event_raw in event_log.get_recent_private_for(local_peer_id, 9999):
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type in ["notebook_note_added", "notebook_note_pin_toggled"]:
			continue
		other_private.append(event)
	if limit > 0 and other_private.size() > limit:
		other_private = other_private.slice(other_private.size() - limit, other_private.size())
	var timeline_lines := _format_timeline_grouped(other_private, true)
	if not timeline_lines.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append_array(timeline_lines)
	return lines

func get_notebook_notes_for_test(event_log: Node, local_peer_id: int, limit: int = NOTEBOOK_RECENT_LIMIT) -> Array:
	return _collect_notebook_notes(event_log, local_peer_id, limit)

func build_private_notes_feed_lines_for_test(event_log: Node, local_peer_id: int, limit: int) -> Array[String]:
	return _build_private_notes_feed_lines(event_log, local_peer_id, limit)

func build_private_notes_sections_for_test(event_log: Node, local_peer_id: int, limit: int, filter_mode: String) -> Array[String]:
	return _build_private_notes_sections(event_log, local_peer_id, limit, filter_mode)

func build_notebook_copy_text_for_test(event_log: Node, local_peer_id: int, limit: int, filter_mode: String) -> String:
	return _build_notebook_copy_text(event_log, local_peer_id, limit, filter_mode)

func get_notebook_notes_filtered_for_test(event_log: Node, local_peer_id: int, limit: int, filter_mode: String) -> Array:
	return _collect_notebook_notes(event_log, local_peer_id, limit, filter_mode)

func build_action_summary_lines_for_test(event_log: Node, local_peer_id: int, limit: int) -> Array[String]:
	return _build_action_summary_lines(event_log, local_peer_id, limit)

func build_run_stats_lines_for_test(event_log: Node, local_peer_id: int) -> Array[String]:
	return _build_run_stats_lines(_build_run_stats(event_log, local_peer_id))

func compute_next_step_hint_for_test(event_log: Node, local_peer_id: int) -> String:
	return _compute_next_step_hint_with_state(event_log, local_peer_id, NetworkManager.get_local_carried_artifact_id() > 0 if NetworkManager != null and NetworkManager.has_method("get_local_carried_artifact_id") else false, _extraction_room_slot())

func compute_next_step_hint_for_test_with_state(event_log: Node, local_peer_id: int, has_carrying: bool, extraction_slot: int) -> String:
	return _compute_next_step_hint_with_state(event_log, local_peer_id, has_carrying, extraction_slot)

func apply_quick_tag_shortcuts_for_test(current_text: String, shortcut: String) -> String:
	return _apply_quick_tag_shortcuts(current_text, shortcut)

func _populate_notebook_filter_options() -> void:
	if notebook_filter_option == null:
		return
	notebook_filter_option.clear()
	for mode in _notebook_filter_modes():
		notebook_filter_option.add_item(mode)

func _notebook_filter_modes() -> Array[String]:
	return [
		NOTEBOOK_FILTER_ALL,
		NOTEBOOK_FILTER_PINNED,
		NOTEBOOK_FILTER_EVIDENCE,
		NOTEBOOK_FILTER_SUSPECT,
		NOTEBOOK_FILTER_ALIBI,
		NOTEBOOK_FILTER_OTHER
	]

func _notebook_filter_index(filter_mode: String) -> int:
	return maxi(_notebook_filter_modes().find(_normalize_notebook_filter_mode(filter_mode)), 0)

func _on_notebook_filter_selected(index: int) -> void:
	var modes := _notebook_filter_modes()
	if index < 0 or index >= modes.size():
		notebook_filter_mode = NOTEBOOK_FILTER_ALL
	else:
		notebook_filter_mode = modes[index]
	_refresh_notebook_panel()

func _on_copy_notes_pressed() -> void:
	var local_id := _local_peer_id()
	var payload := _build_notebook_copy_text(EventLog, local_id, NOTEBOOK_RECENT_LIMIT, notebook_filter_mode)
	if payload.is_empty():
		_private_toast("No notes to copy")
		return
	DisplayServer.clipboard_set(payload)
	_private_toast("Notes copied")

func _toggle_help_overlay(force_open: Variant = null) -> void:
	help_open = not help_open if force_open == null else bool(force_open)
	if help_panel:
		help_panel.visible = help_open
	if help_open and notebook_open:
		_toggle_notebook(false)

func _build_help_overlay_text() -> String:
	return "\n".join([
		"Goal: collect evidence -> extract.",
		"Move: arrow keys / input axis",
		"N: notebook, Enter: save note",
		"Shift+Enter: SUSPECT  Ctrl+Enter: ALIBI  Alt+Enter: EVIDENCE",
		"T: inspect evidence when nearby",
		"Pin latest note, filter notes, copy notes",
		"F1/H: toggle help"
	])

func _update_hint_label(local_id: int) -> void:
	if hint_label == null:
		return
	if help_open or notebook_open or run_ended:
		hint_label.text = ""
		return
	hint_label.text = _update_next_step_hint_state(EventLog, local_id, tick_counter)

func _build_action_summary_lines(event_log: Node, local_peer_id: int, limit: int) -> Array[String]:
	var lines: Array[String] = []
	if event_log == null:
		return lines
	var last_inspection_tick_by_artifact: Dictionary = {}
	for event_raw in event_log.events:
		var event: Dictionary = event_raw
		var visibility := str(event.get("visibility", "public"))
		if visibility == "private" and int(event.get("target_peer_id", -1)) != local_peer_id:
			continue
		var event_type := str(event.get("event_type", ""))
		var meta: Dictionary = event.get("meta", {})
		var line := ""
		match event_type:
			"notebook_note_added":
				var tag := _effective_notebook_tag(str(meta.get("tag", "")))
				var text := str(meta.get("text", ""))
				var prefix := "Note"
				if tag != NOTEBOOK_FILTER_OTHER:
					prefix += ": %s" % tag
				line = "%s: %s" % [prefix, text]
			"notebook_note_pin_toggled":
				line = "Pinned a note" if bool(meta.get("pinned", false)) else "Unpinned a note"
			"warden_check_result":
				var artifact_id := int(meta.get("artifact_id", 0))
				if artifact_id <= 0:
					continue
				var tick := int(event.get("tick", -1))
				var last_tick := int(last_inspection_tick_by_artifact.get(artifact_id, -999999))
				if tick - last_tick < NOTEBOOK_INSPECTION_AUTONOTE_TICKS:
					continue
				last_inspection_tick_by_artifact[artifact_id] = tick
				line = "Inspected E%d (room %d)" % [artifact_id, int(event.get("room_slot", -1))]
			"item_note":
				line = str(meta.get("label", ""))
			"artifact_picked":
				if int(event.get("actor_peer_id", -1)) == local_peer_id:
					line = "Picked up E%d" % int(meta.get("artifact_id", 0))
			"extraction_window_started":
				line = "Extraction window started"
			"extraction_completed":
				line = "Extraction completed"
			"run_ended":
				line = "Run ended"
		if line.is_empty():
			continue
		lines.append(_truncate_summary_line(line))
	if limit > 0 and lines.size() > limit:
		return lines.slice(maxi(lines.size() - limit, 0), lines.size())
	return lines

func _build_run_stats(event_log: Node, local_peer_id: int) -> Dictionary:
	var stats := {
		"notes_count": 0,
		"pinned_count": 0,
		"inspections_count": 0,
		"distinct_artifacts_inspected": 0,
		"extraction_started": false,
		"extraction_completed": false
	}
	if event_log == null:
		return stats
	var pinned_state_by_note: Dictionary = {}
	var inspected_artifacts: Dictionary = {}
	for event_raw in event_log.events:
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if str(event.get("visibility", "public")) == "private" and int(event.get("target_peer_id", -1)) != local_peer_id:
			continue
		var meta: Dictionary = event.get("meta", {})
		match event_type:
			"notebook_note_added":
				stats["notes_count"] = int(stats["notes_count"]) + 1
			"notebook_note_pin_toggled":
				pinned_state_by_note[int(meta.get("note_event_id", -1))] = bool(meta.get("pinned", false))
			"warden_check_result":
				stats["inspections_count"] = int(stats.get("inspections_count", 0)) + 1
				var artifact_id := int(meta.get("artifact_id", 0))
				if artifact_id > 0:
					inspected_artifacts[artifact_id] = true
			"extraction_window_started":
				stats["extraction_started"] = true
			"extraction_completed":
				stats["extraction_completed"] = true
	stats["pinned_count"] = _count_true_values(pinned_state_by_note)
	stats["distinct_artifacts_inspected"] = inspected_artifacts.size()
	return stats

func _build_run_stats_lines(stats: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	lines.append("Notes: %d (Pinned: %d)" % [int(stats.get("notes_count", 0)), int(stats.get("pinned_count", 0))])
	lines.append("Inspections: %d (E:%d)" % [int(stats.get("inspections_count", 0)), int(stats.get("distinct_artifacts_inspected", 0))])
	var extraction_text := "Completed" if bool(stats.get("extraction_completed", false)) else "Started" if bool(stats.get("extraction_started", false)) else "-"
	lines.append("Extraction: %s" % extraction_text)
	return lines

func _compute_next_step_hint(event_log: Node, local_peer_id: int) -> String:
	var carrying := NetworkManager != null and NetworkManager.has_method("get_local_carried_artifact_id") and int(NetworkManager.get_local_carried_artifact_id()) > 0
	return _compute_next_step_hint_with_state(event_log, local_peer_id, carrying, _extraction_room_slot())

func _compute_next_step_hint_with_state(event_log: Node, local_peer_id: int, has_carrying: bool, extraction_slot: int) -> String:
	var notes_count := 0
	var inspections_count := 0
	if event_log != null:
		for event_raw in event_log.get_recent_private_for(local_peer_id, 9999):
			var event: Dictionary = event_raw
			match str(event.get("event_type", "")):
				"notebook_note_added":
					notes_count += 1
				"warden_check_result":
					inspections_count += 1
	if notes_count == 0:
		return "Tip: TAB -> notebook. Write SUSPECT:/ALIBI: notes."
	if inspections_count == 0:
		return "Tip: Hold T near evidence to inspect."
	if has_carrying:
		return "Tip: Bring evidence to Extraction room %d." % extraction_slot
	return "Tip: Pin key notes, then seek more evidence."

func _update_next_step_hint_state(event_log: Node, local_peer_id: int, now_tick: int) -> String:
	var next_text := _compute_next_step_hint(event_log, local_peer_id)
	if next_text == hint_last_text:
		if now_tick - hint_last_tick >= 180:
			hint_last_tick = now_tick
			next_step_hint_text = next_text
		return next_step_hint_text
	if now_tick - hint_last_tick >= 30:
		hint_last_text = next_text
		hint_last_tick = now_tick
		next_step_hint_text = next_text
	return next_step_hint_text

func _apply_quick_tag_shortcuts(current_text: String, shortcut: String) -> String:
	var normalized_shortcut := _sanitize_notebook_text(shortcut).to_upper()
	if normalized_shortcut.is_empty():
		return _sanitize_notebook_text(current_text)
	var current := _sanitize_notebook_text(current_text)
	if current.to_upper().begins_with("%s:" % normalized_shortcut):
		return current
	if current.is_empty():
		return "%s: " % normalized_shortcut
	return "%s: %s" % [normalized_shortcut, current]

func _truncate_summary_line(text: String, max_len: int = ACTION_SUMMARY_MAX_LINE_LEN) -> String:
	var clean := _sanitize_notebook_text(text)
	if clean.length() <= max_len:
		return clean
	return clean.left(max_len - 1) + "..."

func _report_duration_ticks(event_log: Node) -> int:
	if event_log == null:
		return 0
	var max_tick := 0
	for event_raw in event_log.events:
		var event: Dictionary = event_raw
		max_tick = maxi(max_tick, int(event.get("tick", 0)))
	return max_tick

func _format_report_duration(duration_ticks: int) -> String:
	var total_seconds := float(duration_ticks) / 60.0
	return "%dt (~%.1fs)" % [duration_ticks, total_seconds]

func _count_true_values(values: Dictionary) -> int:
	var count := 0
	for value in values.values():
		if bool(value):
			count += 1
	return count

func _apply_cli_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--auto-pickup":
			cli_auto_pickup = true
		elif arg == "--auto-role-action":
			cli_auto_role_action = true
