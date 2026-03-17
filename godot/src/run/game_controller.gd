extends Node2D

const SNAPSHOT_INTERVAL := 0.04
const SPAWN_X_STEP := 80.0
const ROOM_WIDTH := 1024.0
const ROOM_HEIGHT := 768.0
const ROOM_COLUMNS := 5
const WARDEN_CHECK_RANGE := 96.0
const NOTEBOOK_RECENT_LIMIT := 8
const NOTEBOOK_MAX_LEN := 120
const NOTEBOOK_INSPECTION_AUTONOTE_TICKS := 30
const ACTION_SUMMARY_MAX_LINE_LEN := 60
const NARRATIVE_SAMPLE_INTERVAL_TICKS := 12
const NOTEBOOK_FILTER_ALL := "ALL"
const NOTEBOOK_FILTER_PINNED := "PINNED"
const NOTEBOOK_FILTER_EVIDENCE := "EVIDENCE"
const NOTEBOOK_FILTER_SUSPECT := "SUSPECT"
const NOTEBOOK_FILTER_ALIBI := "ALIBI"
const NOTEBOOK_FILTER_OTHER := "OTHER"
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const EXPEDITION_MUTATION_ENGINE_SCRIPT = preload("res://src/run/expedition_mutation_engine.gd")
const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")
const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const PROFILE_SERVICE_SCRIPT = preload("res://src/product/profile_service.gd")
const VISUAL_GOVERNANCE_SCRIPT = preload("res://src/visual/visual_governance.gd")
const ITEM_PICKUP_SCENE = preload("res://scenes/Item.tscn")

var NetworkManager: Node:
	get:
		var tree = get_tree() if is_inside_tree() else Engine.get_main_loop()
		return tree.root.get_node_or_null("/root/NetworkManager") if tree != null else null

var EventLog: Node:
	get:
		var tree = get_tree() if is_inside_tree() else Engine.get_main_loop()
		return tree.root.get_node_or_null("/root/EventLog") if tree != null else null

var RunState: Node:
	get:
		var tree = get_tree() if is_inside_tree() else Engine.get_main_loop()
		return tree.root.get_node_or_null("/root/RunState") if tree != null else null

@onready var room_root: Node2D = get_node_or_null("Rooms") as Node2D
@onready var player_root: Node2D = get_node_or_null("Players") as Node2D
@onready var evidence_root: Node2D = get_node_or_null("Evidence") as Node2D
@onready var item_root: Node2D = get_node_or_null("Items") as Node2D
@onready var status_label: Label = get_node_or_null("CanvasLayer/HUD/Status") as Label
@onready var role_label: Label = get_node_or_null("CanvasLayer/HUD/Role") as Label
@onready var carry_label: Label = get_node_or_null("CanvasLayer/HUD/Carry") as Label
@onready var goal_label: Label = get_node_or_null("CanvasLayer/HUD/Goal") as Label
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
var item_service: RefCounted = ITEM_SERVICE_SCRIPT.new()
var players: Dictionary = {}
var evidence_nodes: Dictionary = {}
var item_nodes: Dictionary = {}
var trace_root: Node2D
var footprint_nodes: Array[Node2D] = []
var last_footprint_tick_by_peer: Dictionary = {}
var last_footprint_pos_by_peer: Dictionary = {}
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
var selected_active_item_id: int = -1
var cli_auto_pickup: bool = false
var cli_auto_pickup_done: bool = false
var cli_auto_role_action: bool = false
var cli_auto_role_action_done: bool = false
var cli_auto_bomb: bool = false
var cli_auto_bomb_done: bool = false
var cli_auto_rope: bool = false
var cli_auto_rope_done: bool = false
var last_report_user_path: String = ""
var last_verify_status: String = ""
var product_run_recorded: bool = false
var last_known_local_peer_id: int = -1
var narrative_samples: Array[Dictionary] = []
var narrative_prev_sample_by_peer: Dictionary = {}
var warden_ghost: Area2D
var profile_settings: Dictionary = {}
var equipped_notebook_theme_id: String = ""
var equipped_banner_id: String = ""
var equipped_title_id: String = ""
var visual_governance: RefCounted = VISUAL_GOVERNANCE_SCRIPT.new()

func _ready() -> void:
	if NetworkManager.has_signal("state_snapshot"):
		NetworkManager.state_snapshot.connect(_on_state_snapshot)
	if NetworkManager.has_signal("artifact_state_changed"):
		NetworkManager.artifact_state_changed.connect(_on_artifact_state_changed)
	elif NetworkManager.has_signal("evidence_state_changed"):
		NetworkManager.evidence_state_changed.connect(_on_artifact_state_changed)
	if NetworkManager.has_signal("item_state_changed"):
		NetworkManager.item_state_changed.connect(_on_item_state_changed)
	if NetworkManager.has_signal("ghost_state_changed"):
		NetworkManager.ghost_state_changed.connect(_on_ghost_state_changed)
	if NetworkManager.has_signal("role_revealed"):
		NetworkManager.role_revealed.connect(_on_role_revealed)
	if NetworkManager.has_signal("hazard_pulse_requested"):
		NetworkManager.hazard_pulse_requested.connect(_on_hazard_pulse_requested)
	if NetworkManager.has_signal("action_denied"):
		NetworkManager.action_denied.connect(_on_action_denied)
	if NetworkManager.has_signal("run_ended"):
		NetworkManager.run_ended.connect(_on_run_ended)
	if NetworkManager.has_signal("connection_changed"):
		NetworkManager.connection_changed.connect(_on_connection_state_changed)
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
	_load_profile_preferences()
	_apply_cli_args()
	_build_rooms()   # Must happen first so spawn_points[] is populated
	_spawn_players()
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
	trace_root = Node2D.new()
	trace_root.name = "TraceRoot"
	add_child(trace_root)

	var custom_theme := _build_panel_theme(Color(0.06, 0.05, 0.08, 0.95), Color(0.26, 0.24, 0.34, 0.8))
	var notebook_theme := _build_notebook_panel_theme()
	if notebook_panel:
		notebook_panel.theme = notebook_theme
	if help_panel:
		help_panel.theme = custom_theme
	if end_screen:
		end_screen.theme = custom_theme
	_apply_accessibility_preferences()

	warden_ghost = Area2D.new()
	warden_ghost.position = Vector2(-2000, 300)
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 48.0
	col.shape = circle
	warden_ghost.add_child(col)
	warden_ghost.add_to_group("hazards")

	var ghost_poly = Polygon2D.new()
	ghost_poly.color = Color(0.2, 0.0, 0.4, 0.8)
	ghost_poly.polygon = PackedVector2Array([
		Vector2(0, -48), Vector2(30, -20), Vector2(30, 20), Vector2(15, 48),
		Vector2(0, 35), Vector2(-15, 48), Vector2(-30, 20), Vector2(-30, -20)
	])
	warden_ghost.add_child(ghost_poly)

	var ghost_eyes = Polygon2D.new()
	ghost_eyes.color = Color.RED
	ghost_eyes.polygon = PackedVector2Array([-12, -10, -4, -10, -4, -2, -12, -2, 4, -10, 12, -10, 12, -2, 4, -2])
	warden_ghost.add_child(ghost_eyes)

	add_child(warden_ghost)

	print("run_started_transition")
	print("GAME_READY pid=%d" % OS.get_process_id())

func _load_profile_preferences() -> void:
	var profile := PROFILE_SERVICE_SCRIPT.load_profile()
	profile_settings = Dictionary(profile.get("settings", {})).duplicate(true)
	var equipped: Dictionary = Dictionary(Dictionary(profile.get("cosmetics", {})).get("equipped", {}))
	equipped_notebook_theme_id = str(equipped.get("notebook_theme", ""))
	equipped_banner_id = str(equipped.get("banner", ""))
	equipped_title_id = str(equipped.get("title", ""))

func _build_panel_theme(background: Color, border: Color) -> Theme:
	var theme := Theme.new()
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = background
	bg_style.border_width_bottom = 2
	bg_style.border_width_right = 2
	bg_style.border_width_top = 2
	bg_style.border_width_left = 2
	bg_style.border_color = border
	bg_style.corner_radius_bottom_right = 8
	bg_style.corner_radius_bottom_left = 8
	bg_style.corner_radius_top_left = 8
	bg_style.corner_radius_top_right = 8
	bg_style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	bg_style.shadow_size = 10
	bg_style.content_margin_left = 10.0
	bg_style.content_margin_top = 10.0
	bg_style.content_margin_right = 10.0
	bg_style.content_margin_bottom = 10.0
	theme.set_stylebox("panel", "PanelContainer", bg_style)
	return theme

func _build_notebook_panel_theme() -> Theme:
	var palette := PRODUCT_CATALOG_SCRIPT.get_notebook_theme_palette(equipped_notebook_theme_id)
	if palette.is_empty():
		palette = PRODUCT_CATALOG_SCRIPT.get_notebook_theme_palette("theme_amber_fieldnotes")
	palette = visual_governance.clamp_palette_strings(palette)
	var background := Color(str(palette.get("panel_bg", "#221A14")))
	var border := Color(str(palette.get("border", "#C6914A")))
	return _build_panel_theme(background, border)

func _apply_accessibility_preferences() -> void:
	if not bool(profile_settings.get("large_text", false)):
		return
	for label in [
		status_label, role_label, carry_label, goal_label, prompt_label, timeline_label, hint_label,
		notebook_hint_label, notebook_toast_label, notebook_notes_label,
		end_seed_label, end_reason_label, end_roles_label, end_summary_label, end_timeline_label, end_more_label
	]:
		if label:
			var current_size := int(label.get_theme_font_size("font_size"))
			if current_size <= 0:
				current_size = 16
			label.add_theme_font_size_override("font_size", current_size + 2)

func _physics_process(delta: float) -> void:
	tick_counter += 1
	snapshot_timer += delta
	var local_id := _local_peer_id()
	if not run_ended:
		if NetworkManager.is_host:
			for peer_id in players.keys():
				_run_cli_automation(peer_id)
		else:
			_run_cli_automation(local_id)
		_handle_local_actions(local_id)
	_update_authoritative_sim(delta, local_id)
	_update_artifact_visuals()
	_update_item_visuals()
	_update_interaction_prompt(local_id)
	_update_status()
	_update_goal_label(local_id)
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

	_update_forensic_traces()
	if warden_ghost:
		warden_ghost.rotation = sin(tick_counter * 0.1) * 0.1
	_record_narrative_sample()

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
	_on_artifact_state_changed(_artifact_state())
	_on_item_state_changed(NetworkManager.get_items_snapshot() if NetworkManager.has_method("get_items_snapshot") else {})
	_on_ghost_state_changed(NetworkManager.get_ghost_state() if NetworkManager.has_method("get_ghost_state") else {"active": false})
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
		var spawn_slot = int(i % max(1, 5))
		actor.global_position = room_builder.get_spawn_point(spawn_slot)
		if actor.has_method("configure_for_peer"):
			actor.configure_for_peer(peer_id)
		players[peer_id] = actor

func _build_rooms() -> void:
	if RunState.room_chain.is_empty():
		var resolution := resolve_room_chain_for_build_for_test(RunState.room_chain, RunState.run_seed, NetworkManager)
		RunState.room_chain = Array(resolution.get("room_chain", [])).duplicate(true)
		print("BUILD_ROOMS_RECOVER source=%s chain_size=%d" % [str(resolution.get("source", "unknown")), RunState.room_chain.size()])
	if room_builder and room_builder.has_method("build_from_chain"):
		print("BUILD_ROOMS chain_size=%d" % RunState.room_chain.size())
		room_builder.build_from_chain(RunState.room_chain, RunState.run_seed)

func resolve_room_chain_for_build_for_test(current_chain: Array, run_seed: int, network_manager: Object) -> Dictionary:
	if not current_chain.is_empty():
		return {
			"source": "run_state",
			"room_chain": current_chain.duplicate(true)
		}
	if network_manager != null and network_manager.has_method("get_authoritative_room_chain_snapshot"):
		var authoritative_chain: Array = network_manager.get_authoritative_room_chain_snapshot()
		if not authoritative_chain.is_empty():
			return {
				"source": "authoritative_snapshot",
				"room_chain": authoritative_chain.duplicate(true)
			}
	var resolved_seed := run_seed if run_seed != 0 else randi()
	var resolved_room_count := 10
	var directive: Dictionary = {}
	if network_manager != null:
		if network_manager.has_method("resolve_authoritative_room_count_for_start"):
			resolved_room_count = int(network_manager.resolve_authoritative_room_count_for_start())
		if network_manager.has_method("get_current_expedition_constitution"):
			directive = network_manager.get_current_expedition_constitution()
		elif network_manager.has_method("get_current_delve_directive"):
			directive = network_manager.get_current_delve_directive()
	push_warning("GameController: room_chain missing at _build_rooms; using emergency fallback generation")
	var gen := RunGenerator.new()
	return {
		"source": "emergency_fallback",
		"room_chain": gen.generate_layout(resolved_seed, resolved_room_count, directive)
	}

func _update_authoritative_sim(delta: float, local_id: int) -> void:
	var move_axis := Input.get_axis("ui_left", "ui_right")
	var jump_pressed := Input.is_action_just_pressed("ui_accept")
	if NetworkManager.is_host and NetworkManager.is_run_active():
		for peer_id in players.keys():
			var actor = players[peer_id]
			if peer_id == local_id:
				# Host owns their own player — simulate normally
				actor.simulate_step(move_axis, jump_pressed, delta)
			else:
				# Remote player on host: client is authoritative for its own position.
				# DO NOT run simulate_step — it creates a physics conflict that causes lag.
				var input_pack: Dictionary = NetworkManager.consume_peer_input(peer_id)
				if input_pack.has("pos") and typeof(input_pack["pos"]) == TYPE_VECTOR2:
					var client_pos: Vector2 = input_pack["pos"]
					if client_pos != Vector2.ZERO:
						# Estimate velocity so animations play correctly on host screen.
						var est_vel = (client_pos - actor.global_position) / max(delta, 0.001)
						var r_flags = int(input_pack.get("flags", 0))
						actor.apply_snapshot({
							"p": client_pos,
							"v": est_vel,
							"h": actor.health
						}, bool(r_flags & 1))
			var room_slot := _room_slot_for_position(actor.global_position)
			NetworkManager.update_authoritative_player_state(peer_id, actor.global_position, room_slot)
			if NetworkManager.has_method("track_noise_trace") and actor.has_method("is_carrying_artifact"):
				NetworkManager.track_noise_trace(peer_id, room_slot, actor.is_carrying_artifact())
			_sync_tool_counts_to_actor(peer_id, actor)
			_sync_item_affordances_to_actor(peer_id, actor)
		if snapshot_timer >= SNAPSHOT_INTERVAL:
			snapshot_timer = 0.0
			var snapshot := {}
			for peer_id in players.keys():
				var actor = players[peer_id]
				var is_floor = actor.is_on_floor() if peer_id == local_id else actor._remote_on_floor
				var tool_counts: Dictionary = NetworkManager.get_tool_counts_for_peer(peer_id) if NetworkManager.has_method("get_tool_counts_for_peer") else {}
				snapshot[str(peer_id)] = {
					"p": actor.global_position,
					"v": actor.velocity,
					"f": is_floor,
					"h": actor.health,
					"b": int(tool_counts.get("bomb", 0)),
					"r": int(tool_counts.get("rope", 0))
				}
			NetworkManager.broadcast_state(snapshot, tick_counter)
	elif not NetworkManager.is_host and not run_ended:
		var send_pos : Vector2 = players[local_id].global_position if players.has(local_id) else Vector2.ZERO
		var floor_flags : int = 1 if (players.has(local_id) and players[local_id].is_on_floor()) else 0
		NetworkManager.send_client_input(move_axis, jump_pressed, tick_counter, send_pos, floor_flags)
		if players.has(local_id):
			players[local_id].simulate_step(move_axis, jump_pressed, delta)

func _handle_local_actions(local_id: int) -> void:
	if notebook_open or not players.has(local_id) or run_ended:
		return
	var local_slot := _room_slot_for_position(players[local_id].global_position)
	if _pressed_once(KEY_Q):
		var artifact_id := _find_nearest_ground_artifact_id(local_id)
		if artifact_id > 0:
			NetworkManager.request_pickup(artifact_id)
	if _pressed_once(KEY_Y):
		var item_id := _find_nearest_ground_item_id(local_id)
		if item_id > 0:
			NetworkManager.request_pickup_item(item_id)
	if _pressed_once(KEY_U):
		var active_item := _get_selected_active_item()
		if not active_item.is_empty():
			NetworkManager.request_use_item(int(active_item.get("item_id", -1)))
	if _pressed_once(KEY_BRACKETLEFT):
		_cycle_active_item(-1)
	if _pressed_once(KEY_BRACKETRIGHT):
		_cycle_active_item(1)
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
	if _pressed_once(KEY_1):
		NetworkManager.request_callout("danger", local_slot)
	if _pressed_once(KEY_2):
		NetworkManager.request_callout("regroup", local_slot)
	if _pressed_once(KEY_3):
		NetworkManager.request_callout("artifact", local_slot)

func _run_cli_automation(target_id: int) -> void:
	if target_id <= 0 or not players.has(target_id):
		return

	# Check if this player has already picked up their item and ported
	# We use a dictionary to track multiple players if we are the host
	var is_ported: bool = players[target_id].get_meta("cli_auto_ported", false)

	if cli_auto_pickup and not is_ported and NetworkManager.is_run_active():
		var artifact_id := _find_nearest_carried_artifact_id_for(target_id)
		if artifact_id > 0:
			var extraction_slot := _extraction_room_slot()
			players[target_id].global_position = _room_slot_anchor(extraction_slot)
			players[target_id].set_meta("cli_auto_ported", true)
			# Only set the global done flag if it was our local player
			if target_id == _local_peer_id():
				cli_auto_pickup_done = true
		else:
			var evidence_by_id := _evidence_state()
			var pickup_id := int(players[target_id].get_meta("cli_auto_pickup_id", 0))
			if pickup_id <= 0 or not evidence_by_id.has(pickup_id) or int(Dictionary(evidence_by_id.get(pickup_id, {})).get("owner_peer_id", 0)) != 0:
				pickup_id = _find_nearest_ground_artifact_id(target_id)
			if pickup_id > 0 and evidence_by_id.has(pickup_id):
				var artifact: Dictionary = evidence_by_id[pickup_id]
				var target_pos: Vector2 = artifact.get("world_pos", players[target_id].global_position)
				var tracked_pickup_id := int(players[target_id].get_meta("cli_auto_pickup_id", 0))
				if tracked_pickup_id != pickup_id:
					players[target_id].set_meta("cli_auto_pickup_id", pickup_id)
					players[target_id].set_meta("cli_auto_seek_tick", tick_counter)
				if players[target_id].global_position.distance_to(target_pos) > 64.0:
					players[target_id].global_position = target_pos
				if target_id == _local_peer_id():
					var seek_tick := int(players[target_id].get_meta("cli_auto_seek_tick", -999999))
					if tick_counter - seek_tick >= 2:
						if NetworkManager.is_host:
							var local_pos: Vector2 = players[target_id].global_position
							NetworkManager.update_authoritative_player_state(target_id, local_pos, _room_slot_for_position(local_pos))
							NetworkManager._host_pickup(target_id, pickup_id)
						else:
							NetworkManager.request_pickup(pickup_id)

	if cli_auto_role_action and not cli_auto_role_action_done and NetworkManager.is_run_active() and tick_counter > 60:
		if target_id == _local_peer_id():
			var room_slot := _room_slot_for_position(players[target_id].global_position)
			if NetworkManager.can_local_use_sabotage(room_slot):
				NetworkManager.request_sabotage(room_slot)
				cli_auto_role_action_done = true

	if cli_auto_bomb and not cli_auto_bomb_done and NetworkManager.is_run_active() and tick_counter > 120:
		if target_id == _local_peer_id():
			var dir = 1.0 # arbitrary
			var bname := "Bomb_CLI_%d" % target_id
			NetworkManager.request_throw_bomb(players[target_id].global_position + Vector2(dir * 10, -5), Vector2(dir * 300, -200), bname)
			cli_auto_bomb_done = true
			print("CLI_AUTO_BOMB_DONE tick=%d" % tick_counter)

	if cli_auto_rope and not cli_auto_rope_done and NetworkManager.is_run_active() and tick_counter > 180:
		if target_id == _local_peer_id():
			var rname := "Rope_CLI_%d" % target_id
			NetworkManager.request_throw_rope(players[target_id].global_position + Vector2(16, -10), rname)
			cli_auto_rope_done = true
			print("CLI_AUTO_ROPE_DONE tick=%d" % tick_counter)

	# CLI End condition check (only on host, once all tasks done)
	if NetworkManager.is_host and NetworkManager.is_run_active():
		if target_id == _local_peer_id():
			# Check tasks (if they were enabled)
			var tasks_done = true
			if cli_auto_pickup and not cli_auto_pickup_done: tasks_done = false
			if cli_auto_role_action and not cli_auto_role_action_done: tasks_done = false
			if cli_auto_bomb and not cli_auto_bomb_done: tasks_done = false
			if cli_auto_rope and not cli_auto_rope_done: tasks_done = false

			# Give some grace ticks for effects/explosions to finish and log events (about 2 seconds)
			if tasks_done and tick_counter > 360:
				print("CLI_AUTO_COMPLETE tick=%d. Requesting run end." % tick_counter)
				NetworkManager._host_end_run("cli_done")

func _find_nearest_carried_artifact_id_for(target_id: int) -> int:
	var evidence_by_id := _evidence_state()
	for artifact_raw in evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = evidence_by_id[artifact_id]
		if int(artifact.get("owner_peer_id", 0)) == target_id:
			return artifact_id
	return 0

func _find_nearest_ground_artifact_id(local_id: int) -> int:
	if not players.has(local_id):
		return 0
	var evidence_by_id := _evidence_state()
	var best_id := 0
	var best_dist := INF
	var local_pos: Vector2 = players[local_id].global_position
	for artifact_raw in evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = evidence_by_id[artifact_id]
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
	var evidence_by_id := _evidence_state()
	var best_id := 0
	var best_dist := INF
	var local_pos: Vector2 = players[local_id].global_position
	for artifact_raw in evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = evidence_by_id[artifact_id]
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
	var evidence_by_id := _evidence_state()
	var best_id := 0
	var best_dist := max_range
	var local_pos: Vector2 = players[local_id].global_position
	for artifact_raw in evidence_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = evidence_by_id[artifact_id]
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
	var local_id := _local_peer_id()
	for key in snapshot.keys():
		var peer_id := int(key)
		if not players.has(peer_id):
			continue
		var actor = players[peer_id]
		var state: Dictionary = snapshot[key]

		if peer_id == local_id:
			# Host-authoritative correction: Compare local predictive position to server truth.
			# We softly pull the local player toward the server state if there is a divergence,
			# but allow local simulation to lead. This ensures buttery-smooth prediction while
			# strictly enforcing Host authority against desyncs (e.g. trap impacts).
			var server_pos: Vector2 = state.get("p", actor.global_position)
			var dist = actor.global_position.distance_to(server_pos)

			if dist > 3000.0:
				# CLI Auto-teleport or valid cross-map respawn. Do not snap back, trust local.
				continue
			elif dist > 200.0:
				# Major desync (e.g., knocked back, fell off a missed ledge) - Snap immediately
				actor.global_position = server_pos
				actor.velocity = state.get("v", actor.velocity)
			elif dist > 15.0:
				# Minor desync - Smooth buttery lerp correction
				actor.global_position = actor.global_position.lerp(server_pos, 0.15)

			# We still sync floor state to ensure animation matches host reality
			actor._remote_on_floor = state.get("f", false)
			_sync_snapshot_tool_counts(peer_id, actor, state)
			_sync_item_affordances_to_actor(peer_id, actor)
			continue

		actor.apply_snapshot(state, state.get("f", false))
		_sync_snapshot_tool_counts(peer_id, actor, state)
		_sync_item_affordances_to_actor(peer_id, actor)

func _on_artifact_state_changed(artifacts_by_id: Dictionary) -> void:
	_sync_artifact_nodes(artifacts_by_id)

func _on_evidence_state_changed(evidence_by_id: Dictionary) -> void:
	_on_artifact_state_changed(evidence_by_id)

func _on_item_state_changed(items_by_id: Dictionary) -> void:
	_sync_item_nodes(items_by_id)
	_sync_selected_active_item()

func _on_ghost_state_changed(state: Dictionary) -> void:
	if warden_ghost == null:
		return
	if not bool(state.get("active", false)):
		warden_ghost.position = Vector2(-2000, 300)
		return
	warden_ghost.position = state.get("position", Vector2(-2000, 300))

func _on_role_revealed(role_name: String) -> void:
	if role_label:
		var role_summary := _local_role_goal(role_name)
		var payload := _local_role_payload()
		var duty_line := str(payload.get("duty_line", "")).strip_edges()
		if not duty_line.is_empty():
			role_summary = duty_line
		role_label.text = "Role: %s | %s" % [role_name, role_summary]

func _local_role_goal(role_name: String) -> String:
	return ROLE_SERVICE_SCRIPT.new().goal_text_for_role(role_name)

func _local_role_payload() -> Dictionary:
	if NetworkManager != null and NetworkManager.has_method("get_local_role_payload"):
		return Dictionary(NetworkManager.get_local_role_payload()).duplicate(true)
	return {}

func build_run_guidance_packet_for_test(public_summary: Dictionary, branch_context: Dictionary = {}, role_payload: Dictionary = {}, runtime_state: Dictionary = {}) -> Dictionary:
	var protocol_state := str(public_summary.get("protocol_state", branch_context.get("protocol_state", ""))).strip_edges()
	var doctrine_label := str(public_summary.get("doctrine_label", public_summary.get("doctrine_family", ""))).strip_edges()
	var branch_name := str(branch_context.get("branch_family_name", branch_context.get("display_name", branch_context.get("branch_family_id", "")))).replace("_", " ").strip_edges()
	var pressure_line := str(public_summary.get("pressure_line", "")).strip_edges()
	var world_goal := str(public_summary.get("world_goal", "")).strip_edges()
	var group_tension_bias := str(public_summary.get("group_tension_bias", "")).strip_edges()
	var item_ecology_bias := str(public_summary.get("item_ecology_bias", "")).strip_edges()
	var convergence_axis := str(public_summary.get("convergence_axis", "")).strip_edges()
	var branch_witness := str(branch_context.get("witness_pressure", "")).strip_edges()
	var route_commitment := str(branch_context.get("route_commitment", "")).strip_edges()
	var rescue_climate := str(branch_context.get("rescue_climate", "")).strip_edges()
	var challenge_texture := str(branch_context.get("challenge_texture", "")).strip_edges()
	var affordance_tags: Array[String] = []
	for tag in Array(role_payload.get("affordance_tags", [])):
		var text := str(tag).strip_edges()
		if not text.is_empty():
			affordance_tags.append(text)
	var duty_line := str(role_payload.get("duty_line", "")).strip_edges()
	var caution_line := str(role_payload.get("caution_line", "")).strip_edges()
	var run_parts: Array[String] = []
	if not protocol_state.is_empty():
		run_parts.append(protocol_state)
	if not branch_name.is_empty():
		run_parts.append(branch_name)
	if not doctrine_label.is_empty():
		run_parts.append(doctrine_label)
	var focus_lines: Array[String] = []
	if not pressure_line.is_empty():
		focus_lines.append("Pressure: %s" % pressure_line)
	if not world_goal.is_empty():
		focus_lines.append("Stakes: %s" % world_goal)
	var route_parts: Array[String] = []
	if not branch_name.is_empty():
		route_parts.append(branch_name)
	if not challenge_texture.is_empty():
		route_parts.append(challenge_texture.replace("_", " "))
	if not rescue_climate.is_empty():
		route_parts.append(rescue_climate.replace("_", " "))
	if not route_parts.is_empty():
		focus_lines.append("Route: %s" % " | ".join(route_parts))
	var social_parts: Array[String] = []
	if not group_tension_bias.is_empty():
		social_parts.append(group_tension_bias)
	if not branch_witness.is_empty():
		social_parts.append("%s witness pressure" % branch_witness)
	if not route_commitment.is_empty():
		social_parts.append("%s commitment" % route_commitment.replace("_", " "))
	if not social_parts.is_empty():
		focus_lines.append("Social: %s" % " | ".join(social_parts))
	var artifact_parts: Array[String] = []
	if not item_ecology_bias.is_empty():
		artifact_parts.append(item_ecology_bias)
	if not convergence_axis.is_empty():
		artifact_parts.append(convergence_axis)
	if not artifact_parts.is_empty():
		focus_lines.append("Artifact line: %s" % " | ".join(artifact_parts))
	if not duty_line.is_empty():
		focus_lines.append("Role duty: %s" % duty_line)
	if not caution_line.is_empty():
		focus_lines.append("Role caution: %s" % caution_line)
	if not affordance_tags.is_empty():
		focus_lines.append("Role affordances: %s" % ", ".join(affordance_tags.slice(0, 3)))
	var carrying_artifact := bool(runtime_state.get("carrying_artifact", false))
	var extraction_active := bool(runtime_state.get("extraction_active", false))
	var ghost_target_local := bool(runtime_state.get("ghost_target_local", false))
	var ghost_active := bool(runtime_state.get("ghost_active", false))
	var predator_target_local := bool(runtime_state.get("predator_target_local", false))
	var predator_active := bool(runtime_state.get("predator_active", false))
	var protocol_watch_target_local := bool(runtime_state.get("protocol_watch_target_local", false))
	var protocol_watch_active := bool(runtime_state.get("protocol_watch_active", false))
	var action_tip := ""
	if extraction_active and carrying_artifact:
		action_tip = "hold the artifact steady in extraction until the stabilizing window clears"
	elif predator_target_local:
		action_tip = "break line of pursuit, keep the artifact moving only if the route stays readable"
	elif ghost_target_local:
		action_tip = "keep moving and avoid isolated reversals while the ghost is focused on you"
	elif protocol_watch_target_local:
		action_tip = "expect containment pressure and keep your next public move explainable"
	elif carrying_artifact:
		action_tip = "move the artifact toward extraction and call the handoff before the route hardens"
	elif not duty_line.is_empty():
		action_tip = duty_line
	elif ghost_active or predator_active or protocol_watch_active:
		action_tip = "treat the route like a live pressure puzzle, not a sightseeing pass"
	elif branch_witness in ["high", "public", "focused"]:
		action_tip = "expect public thresholds and call your route before the story outruns the facts"
	elif route_commitment in ["hard_commitment", "staged_commitment", "greedy_detour"]:
		action_tip = "commit earlier than usual; hesitation is part of the danger on this route"
	elif not world_goal.is_empty():
		action_tip = world_goal
	elif not pressure_line.is_empty():
		action_tip = pressure_line
	return {
		"run_kind_line": " / ".join(run_parts),
		"focus_lines": focus_lines,
		"action_tip": action_tip
	}

func _build_run_guidance_packet() -> Dictionary:
	var public_summary: Dictionary = {}
	if RunState != null:
		public_summary = RunState.constitution_summary.duplicate(true)
	if public_summary.is_empty() and NetworkManager != null:
		if NetworkManager.has_method("get_current_expedition_constitution_summary"):
			public_summary = NetworkManager.get_current_expedition_constitution_summary()
		elif NetworkManager.has_method("get_current_delve_public_summary"):
			public_summary = NetworkManager.get_current_delve_public_summary()
	var branch_context: Dictionary = {}
	var run_state := RunState
	if run_state != null and not run_state.room_chain.is_empty():
		var anchor_room: Dictionary = Dictionary(run_state.room_chain[min(1, run_state.room_chain.size() - 1)])
		branch_context = Dictionary(anchor_room.get("branch_context", {})).duplicate(true)
		if not branch_context.has("branch_family_name"):
			branch_context["branch_family_name"] = str(anchor_room.get("branch_family_name", ""))
		if not branch_context.has("branch_family_id"):
			branch_context["branch_family_id"] = str(anchor_room.get("branch_family_id", ""))
	var ghost_snapshot: Dictionary = NetworkManager.get_ghost_state() if NetworkManager != null and NetworkManager.has_method("get_ghost_state") else {}
	var predator_snapshot: Dictionary = NetworkManager.get_predator_state() if NetworkManager != null and NetworkManager.has_method("get_predator_state") else {}
	var protocol_watch_snapshot: Dictionary = NetworkManager.get_protocol_watch_state() if NetworkManager != null and NetworkManager.has_method("get_protocol_watch_state") else {}
	var runtime_state: Dictionary = {
		"carrying_artifact": NetworkManager != null and NetworkManager.has_method("get_local_carried_artifact_id") and int(NetworkManager.get_local_carried_artifact_id()) > 0,
		"extraction_active": bool(NetworkManager.is_local_extraction_window_active()) if NetworkManager != null and NetworkManager.has_method("is_local_extraction_window_active") else false,
		"ghost_active": bool(ghost_snapshot.get("active", false)),
		"ghost_target_local": int(ghost_snapshot.get("target_peer_id", -1)) == _local_peer_id(),
		"predator_active": bool(predator_snapshot.get("active", false)),
		"predator_target_local": int(predator_snapshot.get("target_peer_id", -1)) == _local_peer_id(),
		"protocol_watch_active": bool(protocol_watch_snapshot.get("active", false)),
		"protocol_watch_target_local": int(protocol_watch_snapshot.get("target_peer_id", -1)) == _local_peer_id()
	}
	return build_run_guidance_packet_for_test(public_summary, branch_context, _local_role_payload(), runtime_state)

func _on_hazard_pulse_requested(room_slot: int, _source_peer_id: int, reason: String) -> void:
	if room_builder and room_builder.has_method("flash_hazard_indicator"):
		room_builder.flash_hazard_indicator(room_slot, 0.3)
	if room_builder and room_builder.has_method("flash_disturbance_indicator") and reason.find("camera_jam") != -1:
		room_builder.flash_disturbance_indicator(room_slot, 0.3, "CAM")
	if reason == "predator_rush":
		_apply_predator_rush_damage(room_slot)

func _apply_predator_rush_damage(room_slot: int) -> void:
	if NetworkManager == null or not NetworkManager.is_host:
		return
	var predator_snapshot: Dictionary = NetworkManager.get_predator_state() if NetworkManager.has_method("get_predator_state") else {}
	var room_lookup: Dictionary = NetworkManager.player_room_by_peer if NetworkManager != null else {}
	_apply_predator_rush_damage_to_actors(room_slot, predator_snapshot, room_lookup, players)

func apply_predator_rush_damage_for_test(room_slot: int, predator_snapshot: Dictionary, room_lookup: Dictionary, actors_by_peer: Dictionary) -> Array[int]:
	return _apply_predator_rush_damage_to_actors(room_slot, predator_snapshot, room_lookup, actors_by_peer)

func predator_damage_targets_for_test(room_slot: int, predator_snapshot: Dictionary, room_lookup: Dictionary) -> Array[int]:
	return _predator_damage_targets_from_state(room_slot, predator_snapshot, room_lookup)

func _apply_predator_rush_damage_to_actors(room_slot: int, predator_snapshot: Dictionary, room_lookup: Dictionary, actors_by_peer: Dictionary) -> Array[int]:
	var hits: Array[int] = []
	for peer_id in _predator_damage_targets_from_state(room_slot, predator_snapshot, room_lookup):
		var actor: Variant = actors_by_peer.get(peer_id, null)
		if actor != null and actor.has_method("apply_damage"):
			actor.apply_damage(1)
			hits.append(peer_id)
	return hits

func _predator_damage_targets_from_state(room_slot: int, predator_snapshot: Dictionary, room_lookup: Dictionary) -> Array[int]:
	var result: Array[int] = []
	if not bool(predator_snapshot.get("active", false)):
		return result
	if int(predator_snapshot.get("room_slot", -1)) != room_slot:
		return result
	var target_peer_id := int(predator_snapshot.get("target_peer_id", -1))
	if target_peer_id <= 0:
		return result
	if int(room_lookup.get(target_peer_id, -1)) != room_slot:
		return result
	result.append(target_peer_id)
	return result

func _on_action_denied(reason: String) -> void:
	feedback_text = "Denied: %s" % reason
	feedback_left = 1.2

func _on_connection_state_changed(status: String) -> void:
	if run_ended or NetworkManager == null:
		return
	var normalized := status.to_lower()
	if NetworkManager.is_run_active():
		return
	if normalized.find("host disconnected") == -1 and normalized.find("run already active") == -1 and normalized.find("connection failed") == -1:
		return
	_record_interrupted_product_run(status)
	get_tree().change_scene_to_file("res://scenes/Lobby.tscn")

func _on_timeline_event_added(event: Dictionary) -> void:
	if str(event.get("event_type", "")) == "notebook_note_added":
		if int(event.get("target_peer_id", -1)) == _local_peer_id():
			_refresh_notebook_panel()
	elif str(event.get("event_type", "")) == "warden_check_result":
		_maybe_autonote_on_inspection(event)
	elif str(event.get("event_type", "")) == "item_used" and room_builder and room_builder.has_method("flash_disturbance_indicator"):
		var meta: Dictionary = event.get("meta", {})
		var label := str(meta.get("label", "")).to_lower()
		if label.find("bookmark") != -1:
			room_builder.flash_disturbance_indicator(int(event.get("room_slot", -1)), 0.45, "BK")
		elif label.find("decoy") != -1:
			room_builder.flash_disturbance_indicator(int(event.get("room_slot", -1)), 0.45, "DC")
		elif label.find("zipline") != -1:
			room_builder.flash_disturbance_indicator(int(event.get("room_slot", -1)), 0.45, "ZL")
	elif str(event.get("event_type", "")) == "bomb_exploded" and room_builder and room_builder.has_method("flash_hazard_indicator"):
		room_builder.flash_hazard_indicator(int(event.get("room_slot", -1)), 0.45)
	elif str(event.get("event_type", "")) == "room_callout":
		var meta: Dictionary = event.get("meta", {})
		var kind := str(meta.get("kind", ""))
		if room_builder and room_builder.has_method("flash_room_indicator"):
			room_builder.flash_room_indicator(int(event.get("room_slot", -1)), _callout_indicator_text(kind), _callout_indicator_color(kind), 0.55)
		if int(event.get("actor_peer_id", -1)) == _local_peer_id():
			feedback_text = "%s callout sent" % _callout_label(kind)
			feedback_left = 1.2
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
	_record_product_run()
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

func _callout_label(kind: String) -> String:
	match kind.to_lower():
		"danger":
			return "Danger"
		"regroup":
			return "Regroup"
		"artifact":
			return "Artifact"
		_:
			return "Room"

func _callout_indicator_text(kind: String) -> String:
	match kind.to_lower():
		"danger":
			return "!"
		"regroup":
			return "GO"
		"artifact":
			return "ART"
		_:
			return "?"

func _callout_indicator_color(kind: String) -> Color:
	match kind.to_lower():
		"danger":
			return Color(1.0, 0.24, 0.2, 1.0)
		"regroup":
			return Color(0.28, 0.86, 0.72, 1.0)
		"artifact":
			return Color(0.96, 0.82, 0.3, 1.0)
		_:
			return Color(0.84, 0.84, 0.84, 1.0)

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
			return "[ART]"
		"constitution_mutation":
			return "[SHIFT]"
		"sabotage_accident", "sabotage_camera_jam", "hazard_state_changed", "bomb_exploded":
			return "[HAZ]"
		"evidence_checked", "warden_check_result", "warden_camera_jam_note":
			return "[WARD]"
		"room_callout":
			return "[INFO]"
		"item_picked", "item_used", "item_note", "noise_trace", "rope_deployed":
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
			return "ARTIFACT MOVES"
		"extraction_window_started", "extraction_window_aborted", "extraction_completed":
			return "EXTRACTION"
		"constitution_mutation":
			return "PRESSURE SHIFTS" if not private_feed else "PRIVATE SHIFTS"
		"sabotage_accident", "sabotage_camera_jam", "hazard_state_changed", "bomb_exploded":
			return "DISTURBANCES"
		"evidence_checked", "warden_check_result", "warden_camera_jam_note":
			return "INSPECTIONS"
		"room_callout":
			return "ROOM SIGNALS"
		"item_picked", "item_used", "item_note", "noise_trace", "rope_deployed":
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
		"constitution_mutation":
			return "SHIFT"
		"sabotage_accident", "sabotage_camera_jam", "bomb_exploded":
			return "SABOTAGE"
		"evidence_checked", "warden_check_result":
			return "INSPECTION"
		"extraction_window_started", "extraction_window_aborted", "extraction_completed":
			return "EXTRACTION"
		"room_callout":
			return "CALLOUT"
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
			return "Run ended: %s" % str(meta.get("reason", "Outcome revealed"))
		"artifact_picked":
			return "%s picked up Artifact %d" % [actor_text, int(meta.get("artifact_id", 0))]
		"artifact_dropped":
			if actor < 0:
				return "Artifact %d was rerouted" % int(meta.get("artifact_id", 0))
			return "%s dropped Artifact %d" % [actor_text, int(meta.get("artifact_id", 0))]
		"artifact_stolen":
			return "%s stole Artifact %d" % [actor_text, int(meta.get("artifact_id", 0))]
		"constitution_mutation":
			return _summarize_constitution_mutation(meta, slot, private_feed)
		"sabotage_accident":
			return str(meta.get("label", "Power flicker disturbed the room"))
		"sabotage_camera_jam":
			return str(meta.get("label", "Camera feed glitched in the room"))
		"hazard_state_changed":
			return "Trap timing shifted in room %d" % slot
		"bomb_exploded":
			return "Bomb blast scarred the room"
		"room_callout":
			return "%s callout marked room %d" % [_callout_label(str(meta.get("kind", ""))), slot]
		"rope_deployed":
			return "A rope changed the route"
		"evidence_checked":
			return "Artifact inspected in room %d" % slot
		"warden_check_result":
			return "Inspection Artifact %d scored %d" % [int(meta.get("artifact_id", 0)), int(meta.get("score", -1))]
		"warden_camera_jam_note":
			return str(meta.get("label", "Camera jam residue lowered confidence"))
		"item_picked":
			var picked_label := str(meta.get("label", ""))
			return picked_label if not picked_label.is_empty() else "Tool recovered"
		"item_used":
			return str(meta.get("label", "Item used"))
		"item_note":
			return str(meta.get("label", "Item note"))
		"noise_trace":
			return "A decoy trail echoed"
		"extraction_window_started":
			return "Extraction stabilizing (%s)" % _format_ticks_short(int(meta.get("duration_ticks", 0)))
		"extraction_window_aborted":
			return "Extraction window collapsed"
		"extraction_completed":
			return "%s completed extraction with Artifact %d" % [actor_text, int(meta.get("artifact_id", 0))]
		"notebook_note_added":
			return str(meta.get("text", "")) if private_feed else "Notebook note"
		"notebook_note_pin_toggled":
			return "Notebook pin updated"
		_:
			return event_type

func _summarize_constitution_mutation(meta: Dictionary, slot: int, private_feed: bool = false) -> String:
	var trigger_type := str(meta.get("trigger_type", "")).strip_edges()
	var public_meta: Dictionary = Dictionary(meta.get("public_meta", {}))
	match trigger_type:
		"species_escalation":
			var species_id: String = _title_case(str(public_meta.get("species_id", "")).replace("_", " "))
			var mode := str(public_meta.get("mode", "")).replace("_", " ").strip_edges()
			if mode.is_empty():
				return "%s pressure sharpened in room %d" % [species_id, slot]
			return "%s pressure sharpened into %s in room %d" % [species_id, mode, slot]
		"covenant_activated":
			return "%s took hold in room %d" % [_title_case(str(public_meta.get("item_def_id", "")).replace("_", " ")), slot]
		"transformation_threshold_crossed":
			return "%s surfaced in room %d" % [_title_case(str(public_meta.get("item_def_id", "")).replace("_", " ")), slot]
		"chamber_entered":
			var room_type := str(public_meta.get("room_type", "")).replace("_", " ").strip_edges()
			if private_feed and not room_type.is_empty():
				return "A %s threshold sharpened in room %d" % [room_type, slot]
			return "The route shifted in room %d" % slot
		_:
			return "The route shifted in room %d" % slot

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
	var local_actor = players.get(local_id, null)
	if local_actor and local_actor.has_method("is_ziplining_now") and bool(local_actor.is_ziplining_now()):
		prompts.append("Zipline: move sideways | Jump/Down to drop")
	elif local_actor and local_actor.has_method("can_mount_zipline_now") and bool(local_actor.can_mount_zipline_now()):
		prompts.append("Up: Grab zipline")
	if carried_id > 0:
		prompts.append(_carry_objective_prompt(local_slot))
	else:
		var pickup_id := _find_nearest_ground_artifact_id(local_id)
		if pickup_id > 0 and RunState.evidence_by_id.has(pickup_id):
			prompts.append("Q: Take Artifact %d" % pickup_id)
	var item_id := _find_nearest_ground_item_id(local_id)
	if item_id > 0 and NetworkManager.has_method("get_items_snapshot"):
		var items: Dictionary = NetworkManager.get_items_snapshot()
		if items.has(item_id):
			prompts.append("Y: Take %s" % _describe_item_pickup(Dictionary(items[item_id])))
	var active_item := _get_selected_active_item()
	if not active_item.is_empty():
		prompts.append("U: Use %s" % _describe_active_item(active_item))
		prompts.append("[ / ] Cycle")
	if carried_id > 0:
		prompts.append("E: Drop")
	var steal_id := _find_nearest_carried_artifact_id(local_id)
	if steal_id > 0:
		prompts.append("R: Steal Artifact %d" % steal_id)
	var local_role := str(RunState.local_role)
	var role_service := ROLE_SERVICE_SCRIPT.new()
	if role_service.can_forge(local_role):
		prompts.append("F: Forge")
	if role_service.can_sabotage(local_role):
		prompts.append("G: Camera Jam" if NetworkManager.can_local_use_sabotage(local_slot) else "G: Camera Jam (cooldown)")
	if role_service.can_inspect(local_role):
		var check_id := _find_nearest_artifact_for_check(local_id, WARDEN_CHECK_RANGE)
		if check_id > 0:
			prompts.append("T: Inspect Artifact %d" % check_id)
	if prompts.size() < 6:
		prompts.append("1/2/3: Callout")
	prompt_label.text = " | ".join(prompts)

func _carry_objective_prompt(local_slot: int) -> String:
	var extraction_slot := _extraction_room_slot()
	if local_slot == extraction_slot:
		if NetworkManager.is_local_extraction_window_active():
			var remaining_ticks := _current_extraction_window_remaining_ticks(EventLog, tick_counter)
			return "Hold Artifact in Extraction room %d | stabilizing %s" % [extraction_slot, _format_ticks_short(remaining_ticks)]
		return "Artifact is in Extraction room %d | hold position" % extraction_slot
	var room_delta := extraction_slot - local_slot
	var direction := "right" if room_delta > 0 else "left"
	return "Carry Artifact to Extraction room %d | %d room %s" % [extraction_slot, abs(room_delta), direction]

func _describe_item_pickup(item_data: Dictionary) -> String:
	var item_def_id := str(item_data.get("item_def_id", ""))
	var display_name := str(item_data.get("display_name", item_def_id))
	if item_def_id.is_empty():
		return display_name
	var category := str(item_service.get_category(item_def_id)).capitalize()
	return "%s - %s" % [category, display_name]

func _describe_active_item(active_item: Dictionary) -> String:
	var item_def_id := str(active_item.get("item_def_id", ""))
	if item_def_id.is_empty():
		return str(active_item.get("display_name", "item"))
	return item_service.get_use_label(item_def_id)

func _current_extraction_window_remaining_ticks(event_log: Node, now_tick: int) -> int:
	if event_log == null:
		return 0
	for i in range(event_log.events.size() - 1, -1, -1):
		var event: Dictionary = event_log.events[i]
		match str(event.get("event_type", "")):
			"extraction_window_aborted", "extraction_completed", "run_ended":
				return 0
			"extraction_window_started":
				var duration_ticks := int(Dictionary(event.get("meta", {})).get("duration_ticks", 0))
				return maxi(duration_ticks - (now_tick - int(event.get("tick", now_tick))), 0)
	return 0

func _format_ticks_short(ticks: int) -> String:
	return "%.1fs" % (float(maxi(ticks, 0)) / 60.0)

func _update_status() -> void:
	if status_label == null:
		return
	var parts: Array[String] = []
	parts.append("Phase %s" % _compute_run_phase(EventLog, _local_peer_id()))
	parts.append("Seed %d" % int(RunState.run_seed))
	parts.append("Extract room %d" % _extraction_room_slot())
	var local_tool_counts := _get_local_tool_counts()
	parts.append("Bombs %d" % int(local_tool_counts.get("bomb", 0)))
	parts.append("Ropes %d" % int(local_tool_counts.get("rope", 0)))
	var local_items: Array = NetworkManager.get_local_item_names() if NetworkManager.has_method("get_local_item_names") else []
	if not local_items.is_empty():
		parts.append("Kit %s" % ", ".join(local_items))
	var active_item := _get_selected_active_item()
	if not active_item.is_empty():
		parts.append("Ready %s" % _describe_active_item(active_item))
	if NetworkManager.is_local_extraction_window_active():
		parts.append("Extraction %s" % _format_ticks_short(_current_extraction_window_remaining_ticks(EventLog, tick_counter)))
	if NetworkManager != null and NetworkManager.has_method("get_local_loadout_runtime_affordances"):
		var local_affordances := Dictionary(NetworkManager.get_local_loadout_runtime_affordances())
		var active_covenant_ids := _string_array(local_affordances.get("active_covenant_ids", []))
		var active_transformation_ids := _string_array(local_affordances.get("active_transformation_ids", []))
		if not active_covenant_ids.is_empty():
			parts.append("Vow %s" % item_service.get_display_name(active_covenant_ids[0]))
		if not active_transformation_ids.is_empty():
			parts.append("Shift %s" % item_service.get_display_name(active_transformation_ids[0]))
	var ghost_state: Dictionary = NetworkManager.get_ghost_state() if NetworkManager.has_method("get_ghost_state") else {}
	if bool(ghost_state.get("active", false)):
		var local_id := _local_peer_id()
		if int(ghost_state.get("target_peer_id", -1)) == local_id:
			parts.append("Ghost on you")
		else:
			parts.append("Ghost active")
	if feedback_left > 0.0 and not feedback_text.is_empty():
		parts.append(feedback_text)
	status_label.text = " | ".join(parts)
	if carry_label:
		var carried_id: int = int(NetworkManager.get_local_carried_artifact_id())
		carry_label.text = "Artifact: %d (objective carry)" % carried_id if carried_id > 0 else "Artifact: None"

func _sync_tool_counts_to_actor(peer_id: int, actor: Node) -> void:
	if actor == null or not actor.has_method("set_spelunky_item_counts") or not NetworkManager.has_method("get_tool_counts_for_peer"):
		return
	var tool_counts: Dictionary = NetworkManager.get_tool_counts_for_peer(peer_id)
	var bombs := int(tool_counts.get("bomb", 0))
	var ropes := int(tool_counts.get("rope", 0))
	actor.set_spelunky_item_counts(bombs, ropes)
	if NetworkManager.has_method("set_tool_counts_local_only"):
		NetworkManager.set_tool_counts_local_only(peer_id, bombs, ropes)

func _sync_snapshot_tool_counts(peer_id: int, actor: Node, state: Dictionary) -> void:
	if actor == null or not actor.has_method("set_spelunky_item_counts"):
		return
	if not state.has("b") and not state.has("r"):
		return
	var bombs := int(state.get("b", 0))
	var ropes := int(state.get("r", 0))
	actor.set_spelunky_item_counts(bombs, ropes)
	if NetworkManager.has_method("set_tool_counts_local_only"):
		NetworkManager.set_tool_counts_local_only(peer_id, bombs, ropes)

func _get_local_tool_counts() -> Dictionary:
	var local_id := _local_peer_id()
	if local_id > 0 and players.has(local_id) and players[local_id].has_method("get_spelunky_item_counts"):
		return players[local_id].get_spelunky_item_counts()
	if NetworkManager.has_method("get_local_tool_counts"):
		return NetworkManager.get_local_tool_counts()
	return {"bomb": 0, "rope": 0}

func _sync_item_affordances_to_actor(peer_id: int, actor: Node) -> void:
	if actor == null or not actor.has_method("set_item_affordances") or not NetworkManager.has_method("get_item_effects_for_peer"):
		return
	var effects: Dictionary = NetworkManager.get_item_effects_for_peer(peer_id)
	actor.set_item_affordances(
		float(effects.get("light_scale", 1.0)),
		float(effects.get("move_speed_mult", 1.0)),
		float(effects.get("jump_velocity_mult", 1.0))
	)

func _local_active_items() -> Array[Dictionary]:
	if NetworkManager == null or not NetworkManager.has_method("get_local_active_items"):
		return []
	return NetworkManager.get_local_active_items()

func _sync_selected_active_item() -> void:
	var active_items := _local_active_items()
	if active_items.is_empty():
		selected_active_item_id = -1
		return
	for item in active_items:
		if int(item.get("item_id", -1)) == selected_active_item_id:
			return
	selected_active_item_id = int(active_items[0].get("item_id", -1))

func _get_selected_active_item() -> Dictionary:
	_sync_selected_active_item()
	for item in _local_active_items():
		if int(item.get("item_id", -1)) == selected_active_item_id:
			return item
	return {}

func _cycle_active_item(direction: int) -> void:
	var active_items := _local_active_items()
	if active_items.is_empty():
		selected_active_item_id = -1
		return
	var selected_index := 0
	for i in range(active_items.size()):
		if int(active_items[i].get("item_id", -1)) == selected_active_item_id:
			selected_index = i
			break
	selected_index = posmod(selected_index + direction, active_items.size())
	selected_active_item_id = int(active_items[selected_index].get("item_id", -1))
	_private_toast("Ready %s" % str(active_items[selected_index].get("display_name", "item")))

func _update_forensic_traces() -> void:
	if trace_root == null:
		return
	var expiry_tick := tick_counter
	for trace in footprint_nodes.duplicate():
		if not is_instance_valid(trace):
			footprint_nodes.erase(trace)
			continue
		if expiry_tick >= int(trace.get_meta("expires_tick", -1)):
			footprint_nodes.erase(trace)
			trace.queue_free()
	for peer_id in players.keys():
		var actor = players[peer_id]
		if actor == null:
			continue
		var on_floor: bool = actor._sync_is_on_floor() if actor.has_method("_sync_is_on_floor") else actor.is_on_floor()
		if not on_floor:
			continue
		var item_effects: Dictionary = NetworkManager.get_item_effects_for_peer(peer_id) if NetworkManager.has_method("get_item_effects_for_peer") else {}
		var carrying: bool = actor.has_method("is_carrying_artifact") and actor.is_carrying_artifact()
		var interval := int(item_effects.get("footprint_interval", 48))
		var scale := float(item_effects.get("footprint_scale", 0.8))
		if not carrying and scale < 1.0:
			continue
		var last_tick := int(last_footprint_tick_by_peer.get(peer_id, -999999))
		var last_pos: Vector2 = last_footprint_pos_by_peer.get(peer_id, Vector2(-99999, -99999))
		if tick_counter - last_tick < interval:
			continue
		if actor.global_position.distance_to(last_pos) < 28.0:
			continue
		last_footprint_tick_by_peer[peer_id] = tick_counter
		last_footprint_pos_by_peer[peer_id] = actor.global_position
		_spawn_footprint(actor.global_position + Vector2(0, 18), scale, carrying)

func _spawn_footprint(world_pos: Vector2, scale_mult: float, carrying: bool) -> void:
	if trace_root == null:
		return
	if footprint_nodes.size() >= 96:
		var oldest: Node2D = footprint_nodes.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	var node := Node2D.new()
	node.position = world_pos
	node.set_meta("expires_tick", tick_counter + 540)
	var left := Polygon2D.new()
	left.color = Color(0.46, 0.40, 0.32, 0.42 if carrying else 0.28)
	left.scale = Vector2.ONE * scale_mult
	left.position = Vector2(-8, 0)
	left.polygon = PackedVector2Array([
		Vector2(-5, -2), Vector2(0, -7), Vector2(5, -2), Vector2(3, 7), Vector2(-3, 7)
	])
	var right := left.duplicate(true)
	right.position = Vector2(8, 2)
	node.add_child(left)
	node.add_child(right)
	trace_root.add_child(node)
	footprint_nodes.append(node)

func _sync_artifact_nodes(artifacts_by_id: Dictionary) -> void:
	if evidence_root == null:
		return
	for artifact_key in evidence_nodes.keys().duplicate():
		if artifacts_by_id.has(artifact_key):
			continue
		evidence_nodes[artifact_key].queue_free()
		evidence_nodes.erase(artifact_key)
	for artifact_raw in artifacts_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = artifacts_by_id[artifact_id]
		if not evidence_nodes.has(artifact_id):
			var node = evidence_scene.instantiate()
			node.name = "Evidence_%d" % artifact_id
			evidence_root.add_child(node)
			evidence_nodes[artifact_id] = node
		evidence_nodes[artifact_id].configure(artifact)

func _sync_evidence_nodes(evidence_by_id: Dictionary) -> void:
	_sync_artifact_nodes(evidence_by_id)

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

func _update_artifact_visuals() -> void:
	var artifacts_by_id := _artifact_state()
	var carried_by_peer: Dictionary = {}
	for artifact_raw in artifacts_by_id.keys():
		var artifact_id := int(artifact_raw)
		var artifact: Dictionary = artifacts_by_id[artifact_id]
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

func _update_evidence_visuals() -> void:
	_update_artifact_visuals()

func _artifact_state() -> Dictionary:
	if NetworkManager != null and not NetworkManager.artifacts_by_id.is_empty():
		return NetworkManager.artifacts_by_id
	return RunState.evidence_by_id

func _evidence_state() -> Dictionary:
	return _artifact_state()

func _update_item_visuals() -> void:
	pass

func _render_end_screen() -> void:
	if end_screen == null:
		return
	end_screen.visible = true
	if end_seed_label:
		end_seed_label.text = "Seed: %d" % int(end_payload.get("seed", RunState.run_seed))
	if end_reason_label:
		var outcome_summary: Dictionary = end_payload.get("outcome_summary", {})
		end_reason_label.text = "Outcome: %s | %s" % [
			str(outcome_summary.get("summary_text", "Run complete")),
			str(outcome_summary.get("artifact_result_text", str(end_payload.get("reason", "unknown"))))
		]
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
	var outcome_summary: Dictionary = end_payload.get("outcome_summary", {})
	var local_role := str(RunState.local_role)
	var role_result := ""
	if not local_role.is_empty() and local_role != "Unknown":
		role_result = "Success" if ROLE_SERVICE_SCRIPT.new().role_wins(local_role, bool(outcome_summary.get("expedition_success", false)), bool(outcome_summary.get("sabotage_success", false))) else "Defeat"
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
	var clue_lines := _build_key_clue_lines(EventLog, 6)
	var outcome_lines: Array[String] = [
		"Summary: %s" % str(outcome_summary.get("summary_text", "Run complete")),
		"Artifact Result: %s" % str(outcome_summary.get("artifact_result_text", "-"))
	]
	if not role_result.is_empty():
		outcome_lines.append("Role Result: %s" % role_result)
	var sections: Array[String] = [
		"Run Outcome",
		_join_or_placeholder(outcome_lines, "No outcome"),
		"",
		"Evidence Summary",
		_join_or_placeholder(lines, "No summary"),
		"",
		"Stats",
		_join_or_placeholder(stats_lines, "No stats"),
		"",
		"Action Summary",
		_join_or_placeholder(action_lines, "No actions"),
		"",
		"Key Clues",
		_join_or_placeholder(clue_lines, "No shared clues")
	]
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
	var outcome_summary: Dictionary = end_payload.get("outcome_summary", {})
	var local_role := str(RunState.local_role)
	lines.append("DeductionDelve Run Report")
	lines.append("Seed: %d" % seed_value)
	lines.append("Local Peer: P%d" % local_peer_id)
	if RunState != null and local_role != "" and local_role != "Unknown":
		lines.append("Role: %s" % local_role)
	lines.append("End Reason: %s" % end_reason)
	lines.append("Duration: %s" % _format_report_duration(duration_ticks))
	lines.append("Run Counter: %d" % run_counter)
	lines.append("")
	lines.append("RUN OUTCOME")
	lines.append("Summary: %s" % str(outcome_summary.get("summary_text", "Run complete")))
	lines.append("Artifact Result: %s" % str(outcome_summary.get("artifact_result_text", "-")))
	if local_role != "" and local_role != "Unknown":
		var role_result := "Success" if ROLE_SERVICE_SCRIPT.new().role_wins(local_role, bool(outcome_summary.get("expedition_success", false)), bool(outcome_summary.get("sabotage_success", false))) else "Defeat"
		lines.append("Role Result: %s" % role_result)
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
	lines.append("Authentic: %d | Counterfeit: %d" % [
		int(outcome_summary.get("authentic_count", 0)),
		int(outcome_summary.get("counterfeit_count", 0))
	])
	lines.append("")
	lines.append("FACTS")
	for line in fact_lines:
		lines.append(line)
	lines.append("")
	lines.append("KEY CLUES")
	for line in _build_key_clue_lines(EventLog, 8):
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

func _record_product_run() -> void:
	if product_run_recorded:
		return
	var run_record := _build_product_run_record()
	if run_record.is_empty():
		return
	PROFILE_SERVICE_SCRIPT.record_run(run_record)
	product_run_recorded = true

func _record_interrupted_product_run(reason: String) -> void:
	if product_run_recorded:
		return
	var run_record := _build_product_run_record(true, reason)
	if run_record.is_empty():
		return
	PROFILE_SERVICE_SCRIPT.record_run(run_record)
	product_run_recorded = true

func _build_product_run_record(interrupted: bool = false, interruption_reason: String = "") -> Dictionary:
	var local_id := _local_peer_id()
	if local_id <= 0:
		return {}
	var local_role := str(RunState.local_role)
	var outcome_summary: Dictionary = Dictionary(end_payload.get("outcome_summary", {}))
	if outcome_summary.is_empty() and interrupted:
		outcome_summary = _interrupted_outcome_summary(interruption_reason)
	var role_result_success := false
	if not interrupted and local_role != "" and local_role != "Unknown":
		role_result_success = ROLE_SERVICE_SCRIPT.new().role_wins(
			local_role,
			bool(outcome_summary.get("expedition_success", false)),
			bool(outcome_summary.get("sabotage_success", false))
		)
	var room_families: Array[String] = []
	for room_raw in RunState.room_chain:
		var room: Dictionary = room_raw
		var room_type := str(room.get("type", ""))
		if not room_type.is_empty() and not room_families.has(room_type):
			room_families.append(room_type)
	room_families.sort()
	var clue_families: Array[String] = []
	for event_raw in EventLog.get_recent_public(9999):
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type in ["bomb_exploded", "placed_zipline", "noise_trace", "light_change", "rope_deployed", "room_callout"]:
			if not clue_families.has(event_type):
				clue_families.append(event_type)
		elif event_type == "item_used":
			var label := str(Dictionary(event.get("meta", {})).get("label", "")).to_lower()
			if label.find("zipline") != -1 and not clue_families.has("placed_zipline"):
				clue_families.append("placed_zipline")
			elif label.find("decoy") != -1 and not clue_families.has("noise_trace"):
				clue_families.append("noise_trace")
	clue_families.sort()
	var item_defs_seen: Array[String] = []
	if NetworkManager != null and NetworkManager.has_method("get_items_snapshot"):
		var items_snapshot: Dictionary = NetworkManager.get_items_snapshot()
		for item_data in items_snapshot.values():
			var item_dict: Dictionary = item_data
			var item_def_id := str(item_dict.get("item_def_id", ""))
			if not item_def_id.is_empty() and not item_defs_seen.has(item_def_id):
				item_defs_seen.append(item_def_id)
	item_defs_seen.sort()
	var artifact_states: Array[String] = []
	var artifact_result := str(outcome_summary.get("artifact_result", ""))
	if artifact_result in ["authentic", "counterfeit", "lost"]:
		artifact_states.append(artifact_result)
	var artifact_continuity_state := str(outcome_summary.get("artifact_continuity_state", "")).strip_edges()
	if not artifact_continuity_state.is_empty() and not artifact_states.has(artifact_continuity_state):
		artifact_states.append(artifact_continuity_state)
	var reconnect_offer: Dictionary = NetworkManager.get_reconnect_offer() if NetworkManager != null and NetworkManager.has_method("get_reconnect_offer") else {}
	var stats := _build_run_stats(EventLog, local_id)
	var timeline_public_events: Array = EventLog.get_recent_public(9999).duplicate(true)
	var timeline_private_events: Array = EventLog.get_recent_private_for(local_id, 9999).duplicate(true)
	var room_chain_summary: Array[Dictionary] = []
	var branch_context_summary := {}
	for room_raw in RunState.room_chain:
		var room: Dictionary = room_raw
		var branch_family_id := str(room.get("branch_family_id", ""))
		var branch_context := Dictionary(room.get("branch_context", {}))
		if not branch_family_id.is_empty():
			branch_context_summary[branch_family_id] = {
				"id": branch_family_id,
				"name": str(room.get("branch_family_name", branch_family_id)),
				"context": branch_context.duplicate(true)
			}
		room_chain_summary.append({
			"slot": int(room.get("slot", -1)),
			"type": str(room.get("type", "")),
			"hazard": str(room.get("hazard", "")),
			"risk": int(room.get("risk", 0)),
			"branch_family_id": branch_family_id,
			"branch_family_name": str(room.get("branch_family_name", "")),
			"branch_context": branch_context.duplicate(true)
		})
	var peer_identities: Dictionary = NetworkManager.get_public_player_cards() if NetworkManager != null and NetworkManager.has_method("get_public_player_cards") else {}
	var motion_facts := _build_narrative_motion_facts(peer_identities)
	var gameplay_signal_snapshot: Dictionary = NetworkManager.build_gameplay_signal_snapshot(peer_identities) if NetworkManager != null and NetworkManager.has_method("build_gameplay_signal_snapshot") else {}
	var expedition_constitution_summary: Dictionary = {}
	var constitution_hash := str(RunState.constitution_hash).strip_edges() if RunState != null else ""
	var mutation_history: Array = Array(RunState.mutation_history).duplicate(true) if RunState != null else []
	var mutation_summary := EXPEDITION_MUTATION_ENGINE_SCRIPT.summarize_mutations(mutation_history)
	if RunState != null:
		expedition_constitution_summary = RunState.constitution_summary.duplicate(true)
	if expedition_constitution_summary.is_empty() and NetworkManager != null:
		if NetworkManager.has_method("get_current_expedition_constitution_summary"):
			expedition_constitution_summary = NetworkManager.get_current_expedition_constitution_summary()
		elif NetworkManager.has_method("get_current_delve_public_summary"):
			expedition_constitution_summary = NetworkManager.get_current_delve_public_summary()
	if constitution_hash.is_empty() and NetworkManager != null and NetworkManager.has_method("get_current_constitution_hash"):
		constitution_hash = str(NetworkManager.get_current_constitution_hash()).strip_edges()
	var live_experiment_ids: Array[String] = []
	var live_hypothesis_ids: Array[String] = []
	if RunState != null:
		var expedition_constitution: Dictionary = Dictionary(RunState.expedition_constitution)
		var experimental_ontology_state: Dictionary = Dictionary(expedition_constitution.get("experimental_ontology_state", {}))
		for experiment_id_variant in Array(experimental_ontology_state.get("live_experiment_ids", [])):
			var experiment_id := str(experiment_id_variant).strip_edges()
			if not experiment_id.is_empty() and not live_experiment_ids.has(experiment_id):
				live_experiment_ids.append(experiment_id)
		for hypothesis_id_variant in Array(experimental_ontology_state.get("live_hypothesis_ids", [])):
			var hypothesis_id := str(hypothesis_id_variant).strip_edges()
			if not hypothesis_id.is_empty() and not live_hypothesis_ids.has(hypothesis_id):
				live_hypothesis_ids.append(hypothesis_id)
	for experiment_id_variant in Array(expedition_constitution_summary.get("live_experiment_ids", [])):
		var experiment_id := str(experiment_id_variant).strip_edges()
		if not experiment_id.is_empty() and not live_experiment_ids.has(experiment_id):
			live_experiment_ids.append(experiment_id)
	for hypothesis_id_variant in Array(expedition_constitution_summary.get("live_hypothesis_ids", [])):
		var hypothesis_id := str(hypothesis_id_variant).strip_edges()
		if not hypothesis_id.is_empty() and not live_hypothesis_ids.has(hypothesis_id):
			live_hypothesis_ids.append(hypothesis_id)
	live_experiment_ids.sort()
	live_hypothesis_ids.sort()
	expedition_constitution_summary["live_experiment_ids"] = live_experiment_ids.duplicate()
	expedition_constitution_summary["live_hypothesis_ids"] = live_hypothesis_ids.duplicate()
	var mutation_replay_signature := EXPEDITION_MUTATION_ENGINE_SCRIPT.replay_signature(mutation_history)
	return {
		"seed": int(end_payload.get("seed", RunState.run_seed)),
		"end_reason": str(end_payload.get("reason", "session_interrupted" if interrupted else "unknown")),
		"local_peer_id": local_id,
		"local_role": local_role,
		"role_result_success": role_result_success,
		"outcome_summary": outcome_summary.duplicate(true),
		"stats": stats.duplicate(true),
		"stats_lines": _build_run_stats_lines(stats),
		"action_summary": _build_action_summary_lines(EventLog, local_id, 12),
		"key_clues": _build_key_clue_lines(EventLog, 8),
		"report_path": last_report_user_path,
		"item_defs": item_defs_seen,
		"room_families": room_families,
		"artifact_states": artifact_states,
		"roles": [local_role],
		"clue_families": clue_families,
		"communication_summary": _build_communication_summary(EventLog),
		"timeline_public_events": timeline_public_events,
		"timeline_private_events": timeline_private_events,
		"room_chain_summary": room_chain_summary,
		"branch_context_summary": branch_context_summary,
		"peer_identities": peer_identities.duplicate(true),
		"narrative_motion_facts": motion_facts,
		"gameplay_signal_snapshot": gameplay_signal_snapshot,
		"constitution_hash": constitution_hash,
		"manifested_experiment_ids": live_experiment_ids.duplicate(),
		"live_experiment_ids": live_experiment_ids.duplicate(),
		"live_hypothesis_ids": live_hypothesis_ids.duplicate(),
		"expedition_constitution_summary": expedition_constitution_summary.duplicate(true),
		"delve_directive_summary": expedition_constitution_summary.duplicate(true),
		"mutation_history": mutation_history,
		"mutation_replay_signature": mutation_replay_signature,
		"mutation_public_summary": mutation_summary.duplicate(true),
		"mutation_private_summary": mutation_summary.duplicate(true),
		"interrupted": interrupted,
		"interruption_reason": interruption_reason,
		"session_wait_for_lobby": bool(reconnect_offer.get("wait_for_lobby", false)),
		"session_reconnect_ready": bool(reconnect_offer.get("available", false))
	}

func _record_narrative_sample() -> void:
	if tick_counter % NARRATIVE_SAMPLE_INTERVAL_TICKS != 0:
		return
	if players.is_empty():
		return
	var sample_peers := {}
	for peer_id_variant in players.keys():
		var peer_id := int(peer_id_variant)
		var actor = players[peer_id]
		if actor == null:
			continue
		var room_slot := _room_slot_for_position(actor.global_position)
		var pos: Vector2 = actor.global_position
		var prev: Dictionary = Dictionary(narrative_prev_sample_by_peer.get(peer_id, {}))
		var delta_vec: Vector2 = pos - Vector2(float(prev.get("x", pos.x)), float(prev.get("y", pos.y)))
		var speed: float = delta_vec.length()
		var x_mod := fposmod(pos.x, ROOM_WIDTH)
		var near_threshold := x_mod <= 96.0 or x_mod >= ROOM_WIDTH - 96.0
		sample_peers[str(peer_id)] = {
			"peer_id": peer_id,
			"room_slot": room_slot,
			"x": snapped(pos.x, 0.1),
			"y": snapped(pos.y, 0.1),
			"speed": snapped(speed, 0.1),
			"near_threshold": near_threshold,
			"carrying": actor.has_method("is_carrying_artifact") and actor.is_carrying_artifact()
		}
		narrative_prev_sample_by_peer[peer_id] = {"x": pos.x, "y": pos.y, "room_slot": room_slot}
	var sample := {
		"tick": tick_counter,
		"extraction_active": NetworkManager.is_local_extraction_window_active() if NetworkManager != null and NetworkManager.has_method("is_local_extraction_window_active") else false,
		"peers": sample_peers
	}
	narrative_samples.append(sample)
	if narrative_samples.size() > 256:
		narrative_samples = narrative_samples.slice(narrative_samples.size() - 256, narrative_samples.size())

func _build_narrative_motion_facts(peer_identities: Dictionary) -> Dictionary:
	var peer_summaries := {}
	var room_summaries := {}
	var pair_summaries := {}
	var echo_tags: Array[String] = []
	var strong_rooms := {
		"threshold_hesitation": 0,
		"collective_hesitations": 0,
		"returns": 0,
		"lingers": 0,
		"burden_pressure": 0
	}
	var previous_rooms_by_peer := {}
	var threshold_waits_by_peer := {}
	var repeat_room_hits := {}
	for sample_raw in narrative_samples:
		var sample: Dictionary = sample_raw
		var peers_dict: Dictionary = Dictionary(sample.get("peers", {}))
		var stationary_peers := 0
		var threshold_peers := 0
		for peer_key in peers_dict.keys():
			var peer_sample: Dictionary = Dictionary(peers_dict.get(peer_key, {}))
			var peer_id := int(peer_sample.get("peer_id", -1))
			var card: Dictionary = Dictionary(peer_identities.get(str(peer_id), peer_identities.get(peer_id, {})))
			var stable_id := str(card.get("public_id", "peer_%d" % peer_id))
			var label := str(card.get("display_name", "P%d" % peer_id))
			var summary: Dictionary = Dictionary(peer_summaries.get(stable_id, {
				"stable_id": stable_id,
				"label": label,
				"threshold_hesitations": 0,
				"lingers": 0,
				"returns": 0,
				"first_entries": 0,
				"rear_guard": 0,
				"burden_carries": 0
			}))
			var room_slot := int(peer_sample.get("room_slot", -1))
			if bool(peer_sample.get("carrying", false)):
				summary["burden_carries"] = int(summary.get("burden_carries", 0)) + 1
			if float(peer_sample.get("speed", 0.0)) <= 10.0:
				summary["lingers"] = int(summary.get("lingers", 0)) + 1
				stationary_peers += 1
			if bool(peer_sample.get("near_threshold", false)):
				threshold_peers += 1
				var threshold_key := "%s:%d" % [stable_id, room_slot]
				threshold_waits_by_peer[threshold_key] = int(threshold_waits_by_peer.get(threshold_key, 0)) + 1
				if int(threshold_waits_by_peer.get(threshold_key, 0)) >= 2:
					summary["threshold_hesitations"] = maxi(int(summary.get("threshold_hesitations", 0)), 1)
			var previous_room := int(previous_rooms_by_peer.get(stable_id, room_slot))
			if previous_room != room_slot:
				var repeat_key := "%s:%d" % [stable_id, room_slot]
				repeat_room_hits[repeat_key] = int(repeat_room_hits.get(repeat_key, 0)) + 1
				if int(repeat_room_hits.get(repeat_key, 0)) >= 2:
					summary["returns"] = int(summary.get("returns", 0)) + 1
			previous_rooms_by_peer[stable_id] = room_slot
			var room_key := "room:%d" % room_slot
			var room_summary: Dictionary = Dictionary(room_summaries.get(room_key, {
				"room_slot": room_slot,
				"threshold_waits": 0,
				"collective_hesitations": 0,
				"territory_holds": 0,
				"revisits": 0,
				"returns": 0,
				"lingers": 0,
				"burden_pressure": 0
			}))
			if bool(peer_sample.get("near_threshold", false)):
				room_summary["threshold_waits"] = int(room_summary.get("threshold_waits", 0)) + 1
				strong_rooms["threshold_hesitation"] = int(strong_rooms.get("threshold_hesitation", 0)) + 1
			if float(peer_sample.get("speed", 0.0)) <= 10.0:
				room_summary["revisits"] = int(room_summary.get("revisits", 0)) + 1
				room_summary["lingers"] = int(room_summary.get("lingers", 0)) + 1
				strong_rooms["lingers"] = int(strong_rooms.get("lingers", 0)) + 1
			if bool(peer_sample.get("carrying", false)):
				room_summary["burden_pressure"] = int(room_summary.get("burden_pressure", 0)) + 1
				strong_rooms["burden_pressure"] = int(strong_rooms.get("burden_pressure", 0)) + 1
			if previous_room != room_slot and int(repeat_room_hits.get("%s:%d" % [stable_id, room_slot], 0)) >= 2:
				room_summary["returns"] = int(room_summary.get("returns", 0)) + 1
				strong_rooms["returns"] = int(strong_rooms.get("returns", 0)) + 1
			room_summaries[room_key] = room_summary
			peer_summaries[stable_id] = summary
		if stationary_peers >= 2:
			for room_key in room_summaries.keys():
				var room_summary: Dictionary = Dictionary(room_summaries.get(room_key, {}))
				room_summary["collective_hesitations"] = int(room_summary.get("collective_hesitations", 0)) + 1
				room_summaries[room_key] = room_summary
				strong_rooms["collective_hesitations"] = int(strong_rooms.get("collective_hesitations", 0)) + 1
				break
		if threshold_peers >= 1:
			echo_tags.append("threshold attention")
		var peer_keys := peers_dict.keys()
		for i in range(peer_keys.size()):
			for j in range(i + 1, peer_keys.size()):
				var a: Dictionary = Dictionary(peers_dict.get(peer_keys[i], {}))
				var b: Dictionary = Dictionary(peers_dict.get(peer_keys[j], {}))
				var pair_key := _stable_pair_key(peer_identities, int(a.get("peer_id", -1)), int(b.get("peer_id", -1)))
				var pair_summary: Dictionary = Dictionary(pair_summaries.get(pair_key, {
					"pair_key": pair_key,
					"proximity": 0,
					"following": 0,
					"separation": 0,
					"shared_carry_pressure": 0
				}))
				var a_pos := Vector2(float(a.get("x", 0.0)), float(a.get("y", 0.0)))
				var b_pos := Vector2(float(b.get("x", 0.0)), float(b.get("y", 0.0)))
				var same_room := int(a.get("room_slot", -1)) == int(b.get("room_slot", -1))
				if same_room and a_pos.distance_to(b_pos) <= 180.0:
					pair_summary["proximity"] = int(pair_summary.get("proximity", 0)) + 1
					if absf(a_pos.x - b_pos.x) <= 64.0:
						pair_summary["following"] = int(pair_summary.get("following", 0)) + 1
				elif not same_room:
					pair_summary["separation"] = int(pair_summary.get("separation", 0)) + 1
				if bool(a.get("carrying", false)) or bool(b.get("carrying", false)):
					pair_summary["shared_carry_pressure"] = int(pair_summary.get("shared_carry_pressure", 0)) + 1
				pair_summaries[pair_key] = pair_summary
	var strong_room_list: Array[Dictionary] = []
	for room_summary_raw in room_summaries.values():
		var room_summary: Dictionary = Dictionary(room_summary_raw)
		if int(room_summary.get("threshold_waits", 0)) > 0 or int(room_summary.get("collective_hesitations", 0)) > 0:
			strong_room_list.append(room_summary)
	strong_room_list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("threshold_waits", 0)) + int(a.get("collective_hesitations", 0)) > int(b.get("threshold_waits", 0)) + int(b.get("collective_hesitations", 0))
	)
	return {
		"sample_count": narrative_samples.size(),
		"peer_summaries": peer_summaries,
		"pair_summaries": pair_summaries,
		"room_summaries": room_summaries,
		"strong_rooms": strong_rooms,
		"strong_room_list": strong_room_list.slice(0, 6),
		"echo_tags": _dedupe_strings(echo_tags)
	}

func _stable_pair_key(peer_identities: Dictionary, a_peer_id: int, b_peer_id: int) -> String:
	var a_card: Dictionary = Dictionary(peer_identities.get(str(a_peer_id), peer_identities.get(a_peer_id, {})))
	var b_card: Dictionary = Dictionary(peer_identities.get(str(b_peer_id), peer_identities.get(b_peer_id, {})))
	var a_id := str(a_card.get("public_id", "peer_%d" % a_peer_id))
	var b_id := str(b_card.get("public_id", "peer_%d" % b_peer_id))
	return "%s:%s" % [a_id, b_id] if a_id < b_id else "%s:%s" % [b_id, a_id]

func _dedupe_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if text.is_empty() or result.has(text):
			continue
		result.append(text)
	return result

func _interrupted_outcome_summary(reason: String) -> Dictionary:
	if NetworkManager != null and NetworkManager.has_method("build_interrupted_outcome_summary"):
		return NetworkManager.build_interrupted_outcome_summary(reason)
	return {
		"summary_text": "Session interrupted",
		"artifact_result_text": "Run interrupted before extraction",
		"artifact_result": "interrupted",
		"artifact_continuity_state": "",
		"artifact_continuity_text": "",
		"expedition_success": false,
		"sabotage_success": false,
		"interrupt_reason": reason
	}

func _build_communication_summary(event_log: Node) -> Dictionary:
	var summary := {"total": 0, "danger": 0, "regroup": 0, "artifact": 0}
	if event_log == null:
		return summary
	for event_raw in event_log.get_recent_public(9999):
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) != "room_callout":
			continue
		var kind := str(Dictionary(event.get("meta", {})).get("kind", ""))
		if not summary.has(kind):
			continue
		summary[kind] = int(summary.get(kind, 0)) + 1
		summary["total"] = int(summary.get("total", 0)) + 1
	return summary

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

func _room_slot_anchor(room_slot: int) -> Vector2:
	var grid_x := posmod(room_slot, ROOM_COLUMNS)
	var grid_y := int(floor(float(room_slot) / float(ROOM_COLUMNS)))
	return Vector2(SPAWN_X_STEP + float(grid_x) * ROOM_WIDTH, 300.0 + float(grid_y) * ROOM_HEIGHT)

func _room_slot_for_position(pos: Vector2) -> int:
	var grid_x := maxi(int(floor(pos.x / ROOM_WIDTH)), 0)
	var grid_y := maxi(int(floor(pos.y / ROOM_HEIGHT)), 0)
	return grid_x + grid_y * ROOM_COLUMNS

func _room_slot_for_local_peer(local_id: int) -> int:
	if local_id > 0 and players.has(local_id):
		return _room_slot_for_position(players[local_id].global_position)
	return -1

func _local_peer_id() -> int:
	if multiplayer and multiplayer.multiplayer_peer != null:
		last_known_local_peer_id = multiplayer.get_unique_id()
		return last_known_local_peer_id
	if NetworkManager != null and NetworkManager.has_method("_mp"):
		var mp = NetworkManager._mp()
		if mp != null and mp.multiplayer_peer != null:
			last_known_local_peer_id = mp.get_unique_id()
			return last_known_local_peer_id
	if last_known_local_peer_id > 0:
		return last_known_local_peer_id
	return 1

func _local_role_hint(role_name: String) -> String:
	match role_name:
		ROLE_SERVICE_SCRIPT.ROLE_VEIL:
			return " | G camera jam"
		ROLE_SERVICE_SCRIPT.ROLE_WARDEN:
			return " | T inspect artifact"
		ROLE_SERVICE_SCRIPT.ROLE_STEWARD:
			return " | callouts steady public custody"
		ROLE_SERVICE_SCRIPT.ROLE_BEARER:
			return " | visible carries shorten extraction but draw pursuit"
		ROLE_SERVICE_SCRIPT.ROLE_MURMUR:
			return " | F forge a second answer through witness pressure"
		ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER:
			return " | decoys can reroute an artifact into cache"
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

func build_key_clue_lines_for_test(event_log: Node, limit: int) -> Array[String]:
	return _build_key_clue_lines(event_log, limit)

func build_run_stats_lines_for_test(event_log: Node, local_peer_id: int) -> Array[String]:
	return _build_run_stats_lines(_build_run_stats(event_log, local_peer_id))

func compute_next_step_hint_for_test(event_log: Node, local_peer_id: int) -> String:
	return _compute_next_step_hint_with_state(event_log, local_peer_id, NetworkManager.get_local_carried_artifact_id() > 0 if NetworkManager != null and NetworkManager.has_method("get_local_carried_artifact_id") else false, _extraction_room_slot())

func compute_next_step_hint_for_test_with_state(event_log: Node, local_peer_id: int, has_carrying: bool, extraction_slot: int) -> String:
	return _compute_next_step_hint_with_state(event_log, local_peer_id, has_carrying, extraction_slot)

func compute_next_step_hint_for_test_with_full_state(event_log: Node, local_peer_id: int, has_carrying: bool, extraction_slot: int, role_name: String, ghost_active: bool, ghost_target_local: bool, extraction_active: bool) -> String:
	return _compute_next_step_hint_with_state(event_log, local_peer_id, has_carrying, extraction_slot, role_name, ghost_active, ghost_target_local, extraction_active)

func apply_quick_tag_shortcuts_for_test(current_text: String, shortcut: String) -> String:
	return _apply_quick_tag_shortcuts(current_text, shortcut)

func describe_item_pickup_for_test(item_data: Dictionary) -> String:
	return _describe_item_pickup(item_data)

func describe_active_item_for_test(item_data: Dictionary) -> String:
	return _describe_active_item(item_data)

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
	var controller_mode := bool(profile_settings.get("controller_glyphs", false))
	var notebook_line := "View: notebook  A: save note" if controller_mode else "N: notebook, Enter: save note"
	var quick_tag_line := "Hold modifiers on keyboard for quick tags" if controller_mode else "Shift+Enter: SUSPECT  Ctrl+Enter: ALIBI  Alt+Enter: EVIDENCE"
	var lines: Array[String] = []
	var packet := _build_run_guidance_packet()
	var focus_lines: Array[String] = []
	for line_value in Array(packet.get("focus_lines", [])):
		var text := str(line_value).strip_edges()
		if not text.is_empty():
			focus_lines.append(text)
	if not focus_lines.is_empty():
		lines.append("Run Brief")
		lines.append_array(focus_lines.slice(0, 6))
		lines.append("")
	lines.append_array([
		"Goal: recover an authentic Artifact and hold it in Extraction.",
		"Counterfeit extraction helps sabotage. Read clues before you commit.",
		"Artifacts are the objective. Tools are active. Relics are passive.",
		"Move: arrow keys / input axis",
		"Q: take Artifact  Y: take Tool/Relic",
		"C: bomb  V: rope  U: use tool  [ / ] cycle tool",
		"1: danger callout  2: regroup callout  3: artifact callout",
		"Up: grab zipline  move sideways to ride  Jump/Down: drop",
		"Role actions: T inspect (Warden)  F forge (Veil/Murmur)  G camera jam (Veil)",
		notebook_line,
		quick_tag_line,
		"Pin notes, filter notes, and copy notes from the notebook",
		"Ghost pressure means the run is closing. Commit to a route.",
		"F1/H: toggle help"
	])
	return "\n".join(lines)

func _update_hint_label(local_id: int) -> void:
	if hint_label == null:
		return
	if help_open or notebook_open or run_ended:
		hint_label.text = ""
		return
	hint_label.text = _update_next_step_hint_state(EventLog, local_id, tick_counter)

func _update_goal_label(local_id: int) -> void:
	if goal_label == null:
		return
	if run_ended:
		goal_label.text = ""
		return
	var phase := _compute_run_phase(EventLog, local_id)
	var line := _compute_objective_line(local_id)
	var packet := _build_run_guidance_packet()
	var run_kind_line := str(packet.get("run_kind_line", "")).strip_edges()
	goal_label.text = "Phase: %s | %s" % [phase, line]
	if not run_kind_line.is_empty():
		goal_label.text += "\nRun: %s" % run_kind_line

func _compute_objective_line(local_id: int) -> String:
	var carried_id := int(NetworkManager.get_local_carried_artifact_id()) if NetworkManager != null and NetworkManager.has_method("get_local_carried_artifact_id") else 0
	var extraction_slot := _extraction_room_slot()
	if NetworkManager != null and NetworkManager.is_local_extraction_window_active():
		return "Hold the artifact in Extraction room %d until the window completes (%s)." % [extraction_slot, _format_ticks_short(_current_extraction_window_remaining_ticks(EventLog, tick_counter))]
	if carried_id > 0:
		return "Carry Artifact %d to Extraction room %d." % [carried_id, extraction_slot]
	return "Recover an artifact, watch for counterfeit signs, and escape together."

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
				line = "Inspected Artifact %d (room %d)" % [artifact_id, int(event.get("room_slot", -1))]
			"item_note":
				line = str(meta.get("label", ""))
			"item_used":
				line = _action_summary_item_line(str(meta.get("label", "Item used")))
			"room_callout":
				if int(event.get("actor_peer_id", -1)) == local_peer_id:
					line = "%s callout in room %d" % [_callout_label(str(meta.get("kind", ""))), int(event.get("room_slot", -1))]
			"rope_deployed":
				line = "Rope changed the route"
			"artifact_picked":
				if int(event.get("actor_peer_id", -1)) == local_peer_id:
					line = "Picked up Artifact %d" % int(meta.get("artifact_id", 0))
			"artifact_dropped":
				if int(event.get("actor_peer_id", -1)) == -1:
					line = "Artifact rerouted"
			"constitution_mutation":
				line = _action_summary_mutation_line(meta, int(event.get("room_slot", -1)))
			"hazard_state_changed":
				line = "Trap timing shifted"
			"extraction_window_started":
				line = "Extraction window started"
			"extraction_completed":
				line = "Extraction completed"
			"noise_trace":
				line = "A decoy trail echoed"
			"bomb_exploded":
				line = "Bomb blast left a scorch mark"
			"run_ended":
				line = "Run ended"
		if line.is_empty():
			continue
		lines.append(_truncate_summary_line(line))
	if limit > 0 and lines.size() > limit:
		return lines.slice(maxi(lines.size() - limit, 0), lines.size())
	return lines

func _build_key_clue_lines(event_log: Node, limit: int) -> Array[String]:
	var lines: Array[String] = []
	if event_log == null:
		return lines
	for event_raw in event_log.get_recent_public(9999):
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		var meta: Dictionary = event.get("meta", {})
		var slot := int(event.get("room_slot", -1))
		var line := ""
		match event_type:
			"artifact_dropped":
				if int(event.get("actor_peer_id", -1)) == -1:
					line = "Artifact route changed in room %d" % slot
			"bomb_exploded":
				line = "Bomb blast scarred room %d" % slot
			"room_callout":
				line = "A %s callout rang out in room %d" % [_callout_label(str(meta.get("kind", ""))).to_lower(), slot]
			"rope_deployed":
				line = "A rope rewrote room %d" % slot
			"noise_trace":
				line = "A decoy trail echoed through room %d" % slot
			"hazard_state_changed":
				line = "A trap pulsed in room %d" % slot
			"item_used":
				line = _key_clue_item_line(str(meta.get("label", "Item used")), slot)
			"sabotage_accident":
				line = "Power flickered in room %d" % slot
			"sabotage_camera_jam":
				line = "Camera feed glitched in room %d" % slot
			"evidence_checked":
				line = "Someone inspected an artifact in room %d" % slot
			"constitution_mutation":
				line = _key_clue_mutation_line(meta, slot)
			"extraction_window_started":
				line = "Extraction hold began in room %d" % slot
			"extraction_completed":
				line = "Artifact extraction finished in room %d" % slot
		if line.is_empty():
			continue
		lines.append(_truncate_summary_line(line))
	if limit > 0 and lines.size() > limit:
		return lines.slice(maxi(lines.size() - limit, 0), lines.size())
	return lines

func _action_summary_item_line(label: String) -> String:
	var normalized := label.to_lower()
	if normalized.find("zipline") != -1:
		return "Zipline changed the route"
	if normalized.find("decoy") != -1:
		return "Decoy emitter split the route"
	if normalized.find("flare ampoule") != -1:
		return "Flare ampoule flooded the room"
	if normalized.find("timeline") != -1:
		return "Timeline bookmark marked the route"
	return label

func _key_clue_item_line(label: String, room_slot: int) -> String:
	var normalized := label.to_lower()
	if normalized.find("zipline") != -1:
		return "A zipline committed the route in room %d" % room_slot
	if normalized.find("decoy") != -1:
		return "A decoy pulse muddied room %d" % room_slot
	if normalized.find("flare ampoule") != -1:
		return "A flare bloom exposed room %d" % room_slot
	if normalized.find("timeline") != -1:
		return "A timeline mark fixed room %d in memory" % room_slot
	return "%s (room %d)" % [label, room_slot]

func _action_summary_mutation_line(meta: Dictionary, room_slot: int) -> String:
	var trigger_type := str(meta.get("trigger_type", "")).strip_edges()
	var public_meta: Dictionary = Dictionary(meta.get("public_meta", {}))
	match trigger_type:
		"species_escalation":
			var species_label := _title_case(str(public_meta.get("species_id", "")).replace("_", " "))
			var mode_label := str(public_meta.get("mode", "")).replace("_", " ").strip_edges()
			return "%s pressure sharpened into %s" % [species_label, mode_label] if not mode_label.is_empty() else "%s pressure sharpened" % species_label
		"covenant_activated":
			return "%s took hold" % _title_case(str(public_meta.get("item_def_id", "")).replace("_", " "))
		"transformation_threshold_crossed":
			return "%s surfaced" % _title_case(str(public_meta.get("item_def_id", "")).replace("_", " "))
		"chamber_entered":
			var room_type := str(public_meta.get("room_type", "")).replace("_", " ").strip_edges()
			return "%s room tightened" % _title_case(room_type) if not room_type.is_empty() else "Room %d tightened" % room_slot
		_:
			return ""

func _key_clue_mutation_line(meta: Dictionary, room_slot: int) -> String:
	var trigger_type := str(meta.get("trigger_type", "")).strip_edges()
	var public_meta: Dictionary = Dictionary(meta.get("public_meta", {}))
	match trigger_type:
		"species_escalation":
			var species_label := _title_case(str(public_meta.get("species_id", "")).replace("_", " "))
			var mode_label := str(public_meta.get("mode", "")).replace("_", " ").strip_edges()
			if not mode_label.is_empty():
				return "%s pressure sharpened into %s in room %d" % [species_label, mode_label, room_slot]
			return "%s pressure sharpened in room %d" % [species_label, room_slot]
		"covenant_activated":
			var item_label := _title_case(str(public_meta.get("item_def_id", "")).replace("_", " "))
			return "%s vow marked room %d" % [item_label, room_slot] if not item_label.is_empty() else "A public vow took hold in room %d" % room_slot
		"transformation_threshold_crossed":
			var item_label := _title_case(str(public_meta.get("item_def_id", "")).replace("_", " "))
			return "%s marked a visible threshold shift in room %d" % [item_label, room_slot] if not item_label.is_empty() else "A visible threshold shift marked room %d" % room_slot
		_:
			return ""

func _title_case(value: String) -> String:
	var parts: PackedStringArray = value.split(" ", false)
	var titled: Array[String] = []
	for raw_part in parts:
		var part := raw_part.strip_edges()
		if part.is_empty():
			continue
		titled.append(part.substr(0, 1).to_upper() + part.substr(1).to_lower())
	return " ".join(titled)

func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

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
	lines.append("Inspections: %d (Artifacts: %d)" % [int(stats.get("inspections_count", 0)), int(stats.get("distinct_artifacts_inspected", 0))])
	var extraction_text := "Completed" if bool(stats.get("extraction_completed", false)) else "Started" if bool(stats.get("extraction_started", false)) else "-"
	lines.append("Extraction: %s" % extraction_text)
	return lines

func _compute_next_step_hint(event_log: Node, local_peer_id: int) -> String:
	var carrying := NetworkManager != null and NetworkManager.has_method("get_local_carried_artifact_id") and int(NetworkManager.get_local_carried_artifact_id()) > 0
	var ghost_state: Dictionary = NetworkManager.get_ghost_state() if NetworkManager != null and NetworkManager.has_method("get_ghost_state") else {}
	var ghost_active := bool(ghost_state.get("active", false))
	var ghost_target_local := int(ghost_state.get("target_peer_id", -1)) == local_peer_id
	var base_hint := _compute_next_step_hint_with_state(event_log, local_peer_id, carrying, _extraction_room_slot(), str(RunState.local_role), ghost_active, ghost_target_local, bool(NetworkManager.is_local_extraction_window_active()))
	var packet := _build_run_guidance_packet()
	var action_tip := str(packet.get("action_tip", "")).strip_edges()
	if action_tip.is_empty():
		return base_hint
	if base_hint == "" or base_hint == "Tip: Pin key notes, watch routes, and seek more evidence.":
		return "Tip: %s." % action_tip.trim_suffix(".")
	return base_hint

func _compute_next_step_hint_with_state(event_log: Node, local_peer_id: int, has_carrying: bool, extraction_slot: int, role_name: String = "", ghost_active: bool = false, ghost_target_local: bool = false, extraction_active: bool = false) -> String:
	var hint_mode := str(profile_settings.get("hint_mode", "full"))
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
	if extraction_active:
		return "Tip: Hold still in Extraction room %d until the stabilizing window finishes." % extraction_slot
	if ghost_target_local:
		return "Tip: The Ghost is on you. Keep moving and don't lose the route."
	if ghost_active:
		return "Tip: Ghost pressure is live. Stay grouped and commit to the route."
	if has_carrying:
		return "Tip: Bring Artifact to Extraction room %d." % extraction_slot
	if hint_mode != "full":
		return ""
	if notes_count == 0:
		return "Tip: N -> notebook. Write SUSPECT:/ALIBI: notes."
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_WARDEN and inspections_count == 0:
		return "Tip: Hold T near an artifact to inspect."
	if role_name == ROLE_SERVICE_SCRIPT.ROLE_VEIL:
		return "Tip: Use chaos, route tools, and timing. Do not make guilt obvious."
	return "Tip: Pin key notes, watch routes, and seek more clues."

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

func _compute_run_phase(event_log: Node, local_peer_id: int) -> String:
	var ghost_state: Dictionary = NetworkManager.get_ghost_state() if NetworkManager != null and NetworkManager.has_method("get_ghost_state") else {}
	return _compute_run_phase_with_state(event_log, local_peer_id, bool(ghost_state.get("active", false)), bool(NetworkManager.is_local_extraction_window_active()))

func _compute_run_phase_with_state(event_log: Node, local_peer_id: int, ghost_active: bool, extraction_active: bool) -> String:
	if run_ended:
		return "Revelation"
	if extraction_active:
		return "Extraction"
	if ghost_active:
		return "Pressure"
	var disturbance_score := 0
	var saw_progress := false
	if event_log != null:
		for event_raw in event_log.events:
			var event: Dictionary = event_raw
			var visibility := str(event.get("visibility", "public"))
			if visibility == "private" and int(event.get("target_peer_id", -1)) != local_peer_id:
				continue
			match str(event.get("event_type", "")):
				"artifact_picked", "item_used", "warden_check_result", "notebook_note_added":
					saw_progress = true
				"sabotage_accident", "sabotage_camera_jam", "bomb_exploded", "noise_trace", "artifact_dropped":
					saw_progress = true
					disturbance_score += 1
	if disturbance_score >= 2:
		return "Chaos"
	if saw_progress:
		return "Suspicion"
	return "Exploration"

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
		elif arg == "--auto-bomb":
			cli_auto_bomb = true
		elif arg == "--auto-rope":
			cli_auto_rope = true

func execute_door_teleport(peer_id: int, door_id: int) -> void:
	if not NetworkManager.is_host: return
	if not room_builder: return

	var doors = _find_doors_in_node(room_builder)
	var target_door = null
	for d in doors:
		if d.door_id == door_id and not _is_door_same_origin(players[peer_id].global_position, d.global_position):
			target_door = d
			break

	if target_door and players.has(peer_id):
		players[peer_id].global_position = target_door.linked_pos
		players[peer_id].velocity = Vector2.ZERO

func _is_door_same_origin(player_pos: Vector2, door_pos: Vector2) -> bool:
	return player_pos.distance_to(door_pos) < 64.0

func _find_doors_in_node(node: Node) -> Array:
	var res = []
	if node is Area2D and "door_id" in node:
		res.append(node)
	for child in node.get_children():
		res.append_array(_find_doors_in_node(child))
	return res
