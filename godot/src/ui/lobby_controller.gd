extends Control

const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const PROFILE_SERVICE_SCRIPT = preload("res://src/product/profile_service.gd")
const VISUAL_GOVERNANCE_SCRIPT = preload("res://src/visual/visual_governance.gd")

@onready var title_label: Label = $Panel/VBox/Title
@onready var banner_label: Label = $Panel/VBox/BannerLabel
@onready var status_label: Label = $Panel/VBox/Status
@onready var players_label: Label = $Panel/VBox/Players
@onready var address_edit: LineEdit = $Panel/VBox/Grid/AddressEdit
@onready var port_edit: LineEdit = $Panel/VBox/Grid/PortEdit
@onready var seed_edit: LineEdit = $Panel/VBox/Grid/SeedEdit
@onready var host_button: Button = $Panel/VBox/Buttons/HostButton
@onready var join_button: Button = $Panel/VBox/Buttons/JoinButton
@onready var leave_button: Button = $Panel/VBox/Buttons/LeaveButton
@onready var reconnect_button: Button = $Panel/VBox/Buttons/ReconnectButton
@onready var ready_button: Button = $Panel/VBox/Buttons/ReadyButton
@onready var start_button: Button = $Panel/VBox/Buttons/StartButton
@onready var session_summary_label: Label = $Panel/VBox/SessionSummary
@onready var shell_hint_label: Label = $Panel/VBox/ShellHint
@onready var shell_tabs: TabContainer = $Panel/VBox/ShellTabs
@onready var home_hero_label: Label = $Panel/VBox/ShellTabs/HomeTab/HeroCard
@onready var home_overview_label: Label = $Panel/VBox/ShellTabs/HomeTab/Overview
@onready var home_quick_start_label: Label = $Panel/VBox/ShellTabs/HomeTab/QuickStart
@onready var home_continue_label: Label = $Panel/VBox/ShellTabs/HomeTab/Continue
@onready var home_last_run_label: Label = $Panel/VBox/ShellTabs/HomeTab/LastRun
@onready var home_recent_runs_label: Label = $Panel/VBox/ShellTabs/HomeTab/RecentRuns
@onready var home_run_diagnostics_label: Label = $Panel/VBox/ShellTabs/HomeTab/RunDiagnostics
@onready var profile_summary_label: Label = $Panel/VBox/ShellTabs/ProfileTab/ProfileSummary
@onready var mastery_summary_label: Label = $Panel/VBox/ShellTabs/ProfileTab/MasterySummary
@onready var progress_summary_label: Label = $Panel/VBox/ShellTabs/ProfileTab/ProgressSummary
@onready var achievement_summary_label: Label = $Panel/VBox/ShellTabs/ProfileTab/AchievementSummary
@onready var history_summary_label: Label = $Panel/VBox/ShellTabs/ProfileTab/HistorySummary
@onready var history_focus_label: Label = $Panel/VBox/ShellTabs/ProfileTab/HistoryFocus
@onready var history_compare_label: Label = $Panel/VBox/ShellTabs/ProfileTab/HistoryCompare
@onready var history_filter_option: OptionButton = $Panel/VBox/ShellTabs/ProfileTab/HistoryFilter
@onready var history_sort_option: OptionButton = $Panel/VBox/ShellTabs/ProfileTab/HistorySort
@onready var history_entries_list: ItemList = $Panel/VBox/ShellTabs/ProfileTab/RunHistoryEntries
@onready var history_detail_label: Label = $Panel/VBox/ShellTabs/ProfileTab/RunHistoryDetail
@onready var collection_section_option: OptionButton = $Panel/VBox/ShellTabs/CollectionTab/CollectionSection
@onready var collection_entries_list: ItemList = $Panel/VBox/ShellTabs/CollectionTab/CollectionEntries
@onready var collection_detail_label: Label = $Panel/VBox/ShellTabs/CollectionTab/CollectionDetail
@onready var collection_summary_label: Label = $Panel/VBox/ShellTabs/CollectionTab/CollectionSummary
@onready var codex_section_option: OptionButton = $Panel/VBox/ShellTabs/CodexTab/CodexSection
@onready var codex_entries_list: ItemList = $Panel/VBox/ShellTabs/CodexTab/CodexEntries
@onready var codex_detail_label: Label = $Panel/VBox/ShellTabs/CodexTab/CodexDetail
@onready var codex_summary_label: Label = $Panel/VBox/ShellTabs/CodexTab/CodexSummary
@onready var cosmetic_category_option: OptionButton = $Panel/VBox/ShellTabs/CosmeticsTab/CosmeticCategory
@onready var cosmetic_entries_list: ItemList = $Panel/VBox/ShellTabs/CosmeticsTab/CosmeticEntries
@onready var equip_next_button: Button = $Panel/VBox/ShellTabs/CosmeticsTab/EquipNextButton
@onready var cosmetic_preview_label: Label = $Panel/VBox/ShellTabs/CosmeticsTab/CosmeticPreview
@onready var cosmetic_summary_label: Label = $Panel/VBox/ShellTabs/CosmeticsTab/CosmeticSummary
@onready var large_text_check: CheckBox = $Panel/VBox/ShellTabs/SettingsTab/LargeTextCheck
@onready var controller_glyphs_check: CheckBox = $Panel/VBox/ShellTabs/SettingsTab/ControllerGlyphsCheck
@onready var hint_mode_button: Button = $Panel/VBox/ShellTabs/SettingsTab/HintModeButton
@onready var voice_mode_button: Button = $Panel/VBox/ShellTabs/SettingsTab/VoiceModeButton
@onready var push_to_talk_check: CheckBox = $Panel/VBox/ShellTabs/SettingsTab/PushToTalkCheck
@onready var mute_voice_check: CheckBox = $Panel/VBox/ShellTabs/SettingsTab/MuteVoiceCheck
@onready var reset_settings_button: Button = $Panel/VBox/ShellTabs/SettingsTab/ResetSettingsButton
@onready var settings_summary_label: Label = $Panel/VBox/ShellTabs/SettingsTab/SettingsSummary
@onready var data_health_label: Label = $Panel/VBox/ShellTabs/SettingsTab/DataHealth
@onready var controls_summary_label: Label = $Panel/VBox/ShellTabs/SettingsTab/ControlsSummary

var local_ready: bool = false
var cli_mode: String = ""
var cli_auto_ready: bool = false
var cli_auto_ready_done: bool = false
var cli_auto_start: bool = false
var cli_auto_start_done: bool = false
var product_catalog: Dictionary = {}
var profile_state: Dictionary = {}
var cosmetic_category: String = "title"
var product_ui_refreshing: bool = false
var collection_section: String = "Items"
var codex_section: String = "roles"
var collection_entries_cache: Array[Dictionary] = []
var codex_entries_cache: Array[Dictionary] = []
var cosmetic_entries_cache: Array[Dictionary] = []
var history_entries_cache: Array[Dictionary] = []
var collection_selected_index: int = 0
var codex_selected_index: int = 0
var cosmetic_selected_index: int = 0
var history_selected_index: int = 0
var history_filter_mode: String = "ALL"
var history_sort_mode: String = "RECENT"
var history_selected_key: String = ""
var history_focus_target: String = "filter"
var selected_cosmetic_id: String = ""
var visual_governance: RefCounted = VISUAL_GOVERNANCE_SCRIPT.new()
var product_shell_refresh_queued: bool = false
var headless_cli_shell_latched: bool = false

func _ready() -> void:
	print("LOBBY_READY")
	product_catalog = PRODUCT_CATALOG_SCRIPT.load_catalog()
	profile_state = PROFILE_SERVICE_SCRIPT.load_profile(PROFILE_SERVICE_SCRIPT.SAVE_PATH, product_catalog)
	NetworkManager.connection_changed.connect(_on_connection_changed)
	if NetworkManager.has_signal("reconnect_offer_changed"):
		NetworkManager.reconnect_offer_changed.connect(_on_reconnect_offer_changed)
	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	NetworkManager.run_started.connect(_on_run_started)
	_configure_tab_titles()
	_populate_history_filters()
	_populate_history_sorts()
	_populate_cosmetic_categories()
	_populate_collection_sections()
	_populate_codex_sections()
	_apply_profile_defaults_to_inputs()
	_apply_cli_args()
	headless_cli_shell_latched = headless_cli_shell_mode_for_test(DisplayServer.get_name(), cli_mode, cli_auto_ready, cli_auto_start)
	if not _headless_cli_shell_mode():
		_refresh_product_shell()
	set_process(true)
	set_process_unhandled_input(true)
	status_label.text = str(Dictionary(NetworkManager.get_session_overview()).get("status", "Not connected"))
	_refresh_buttons()
	_focus_current_tab_primary()

func _process(_delta: float) -> void:
	if cli_mode == "host":
		print("LOBBY_CLI_HOST")
		cli_mode = ""
		_on_host_button_pressed()
	elif cli_mode == "client":
		print("LOBBY_CLI_CLIENT")
		cli_mode = ""
		_on_join_button_pressed()
	_run_cli_automation()

func _unhandled_input(event: InputEvent) -> void:
	if shell_tabs == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_PAGEUP:
			_cycle_tab(-1)
			get_viewport().set_input_as_handled()
		elif key_event.keycode == KEY_PAGEDOWN:
			_cycle_tab(1)
			get_viewport().set_input_as_handled()
		elif key_event.keycode == KEY_ESCAPE:
			_go_home_tab()
			get_viewport().set_input_as_handled()
		elif shell_tabs.current_tab == 1 and (key_event.keycode == KEY_LEFT or key_event.keycode == KEY_RIGHT):
			if _handle_history_focus_shift(key_event.keycode == KEY_RIGHT):
				get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		var joy_event := event as InputEventJoypadButton
		if joy_event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			_cycle_tab(-1)
			get_viewport().set_input_as_handled()
		elif joy_event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			_cycle_tab(1)
			get_viewport().set_input_as_handled()
		elif joy_event.button_index == JOY_BUTTON_B:
			_go_home_tab()
			get_viewport().set_input_as_handled()
	elif event is InputEventJoypadMotion and shell_tabs.current_tab == 1:
		var joy_motion := event as InputEventJoypadMotion
		if joy_motion.axis == JOY_AXIS_LEFT_X and absf(joy_motion.axis_value) > 0.6:
			if _handle_history_focus_shift(joy_motion.axis_value > 0.0):
				get_viewport().set_input_as_handled()

func _cycle_tab(direction: int) -> void:
	if shell_tabs == null or shell_tabs.get_tab_count() <= 0:
		return
	shell_tabs.current_tab = posmod(shell_tabs.current_tab + direction, shell_tabs.get_tab_count())
	_focus_current_tab_primary()

func _go_home_tab() -> void:
	if shell_tabs == null:
		return
	if shell_tabs.current_tab != 0:
		shell_tabs.current_tab = 0
	_focus_current_tab_primary()

func _on_host_button_pressed() -> void:
	var port := int(port_edit.text)
	NetworkManager.start_host(port)
	_refresh_buttons()

func _on_join_button_pressed() -> void:
	var port := int(port_edit.text)
	NetworkManager.join_host(address_edit.text.strip_edges(), port)
	_refresh_buttons()

func _on_leave_button_pressed() -> void:
	NetworkManager.disconnect_peer()
	local_ready = false
	_refresh_buttons()

func _on_reconnect_button_pressed() -> void:
	if NetworkManager.attempt_reconnect():
		_refresh_buttons()

func _on_ready_button_pressed() -> void:
	var current_ready := local_ready
	var mp := _multiplayer_api()
	if mp != null and mp.multiplayer_peer != null:
		current_ready = bool(NetworkManager.ready_by_id.get(mp.get_unique_id(), local_ready))
	local_ready = not current_ready
	NetworkManager.set_local_ready(local_ready)
	_refresh_buttons()

func _on_start_button_pressed() -> void:
	if not NetworkManager.is_host:
		return
	var seed := int(seed_edit.text)
	NetworkManager.start_run(seed)

func _on_connection_changed(status: String) -> void:
	status_label.text = status
	if _headless_cli_shell_mode():
		_refresh_buttons()
		_run_cli_automation()
		return
	_queue_product_shell_refresh()
	_run_cli_automation()

func _on_reconnect_offer_changed(_offer: Dictionary) -> void:
	if _headless_cli_shell_mode():
		_refresh_buttons()
		return
	_queue_product_shell_refresh()

func _on_lobby_updated(players: Array, ready_state: Dictionary, host_flag: bool) -> void:
	var mp := _multiplayer_api()
	var local_id := -1
	if mp != null and mp.multiplayer_peer != null:
		local_id = mp.get_unique_id()
		local_ready = bool(ready_state.get(local_id, local_ready))
	var public_cards := NetworkManager.get_public_player_cards() if NetworkManager.has_method("get_public_player_cards") else {}
	players_label.text = "\n".join(
		PROFILE_SERVICE_SCRIPT.build_lobby_roster_lines(
			profile_state,
			ready_state,
			public_cards,
			local_id
		)
	)
	start_button.visible = host_flag
	start_button.disabled = not NetworkManager.all_ready()
	local_ready = local_id > 0 and bool(ready_state.get(local_id, false))
	ready_button.text = "Ready: %s" % ["YES" if local_ready else "NO"]
	_run_cli_automation()

func _on_run_started(_seed: int, _chain: Array) -> void:
	call_deferred("_deferred_change_to_game_scene")

func _deferred_change_to_game_scene() -> void:
	var tree := get_tree()
	if tree == null:
		return
	tree.change_scene_to_file("res://scenes/Game.tscn")

func _refresh_buttons() -> void:
	var mp := _multiplayer_api()
	var connected := mp != null and mp.multiplayer_peer != null
	ready_button.disabled = not connected
	start_button.disabled = not (connected and NetworkManager.is_host and NetworkManager.all_ready())
	start_button.visible = NetworkManager.is_host
	if reconnect_button:
		reconnect_button.disabled = connected or not NetworkManager.can_attempt_reconnect()

func _queue_product_shell_refresh() -> void:
	if product_shell_refresh_queued:
		return
	product_shell_refresh_queued = true
	call_deferred("_flush_product_shell_refresh")

func _flush_product_shell_refresh() -> void:
	product_shell_refresh_queued = false
	_refresh_product_shell()
	_refresh_buttons()

func _headless_cli_shell_mode() -> bool:
	return headless_cli_shell_latched

static func headless_cli_shell_mode_for_test(display_name: String, mode: String, auto_ready: bool, auto_start: bool) -> bool:
	var normalized_display := display_name.to_lower()
	return normalized_display.find("headless") != -1 and (not mode.is_empty() or auto_ready or auto_start)

func _multiplayer_api() -> MultiplayerAPI:
	if not is_inside_tree():
		return null
	return get_tree().get_multiplayer()

func _run_cli_automation() -> void:
	var mp := _multiplayer_api()
	var connected := mp != null and mp.multiplayer_peer != null
	if cli_auto_ready and not cli_auto_ready_done and connected:
		var local_id := mp.get_unique_id()
		var can_ready := NetworkManager.is_host or (NetworkManager.connected_peers.has(local_id) and NetworkManager.connected_peers.has(1) and NetworkManager.connected_peers.size() >= 2)
		if can_ready:
			if not bool(NetworkManager.ready_by_id.get(local_id, false)):
				_on_ready_button_pressed()
			cli_auto_ready_done = true
	if cli_auto_start and not cli_auto_start_done and connected and NetworkManager.is_host:
		var gate: Dictionary = NetworkManager.can_host_start_run(NetworkManager.connected_peers, NetworkManager.ready_by_id, true, NetworkManager.is_run_active())
		print("START_GATE allowed=%s reason=%s" % [
			str(bool(gate.get("allowed", false))).to_lower(),
			str(gate.get("reason", ""))
		])
		if bool(gate.get("allowed", false)):
			_on_start_button_pressed()
			cli_auto_start_done = true

func _apply_cli_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--mode=host":
			cli_mode = "host"
		elif arg.begins_with("--address="):
			address_edit.text = arg.trim_prefix("--address=")
		elif arg.begins_with("--port="):
			port_edit.text = arg.trim_prefix("--port=")
		elif arg.begins_with("--seed="):
			seed_edit.text = arg.trim_prefix("--seed=")
		elif arg == "--mode=client":
			cli_mode = "client"
		elif arg == "--auto-ready":
			cli_auto_ready = true
		elif arg == "--auto-start":
			cli_auto_start = true

func _populate_cosmetic_categories() -> void:
	if cosmetic_category_option == null:
		return
	product_ui_refreshing = true
	cosmetic_category_option.clear()
	var categories := PRODUCT_CATALOG_SCRIPT.cosmetic_categories(product_catalog)
	for category in categories:
		cosmetic_category_option.add_item(_title_case(category))
	if not categories.is_empty():
		cosmetic_category = categories[0]
		cosmetic_category_option.select(0)
	product_ui_refreshing = false

func _populate_collection_sections() -> void:
	if collection_section_option == null:
		return
	product_ui_refreshing = true
	collection_section_option.clear()
	var sections := PROFILE_SERVICE_SCRIPT.collection_sections()
	for section in sections:
		collection_section_option.add_item(section)
	if not sections.is_empty():
		collection_section = sections[0]
		collection_section_option.select(0)
	product_ui_refreshing = false

func _populate_codex_sections() -> void:
	if codex_section_option == null:
		return
	product_ui_refreshing = true
	codex_section_option.clear()
	var sections := PROFILE_SERVICE_SCRIPT.build_codex_sections(profile_state, product_catalog)
	for section in sections:
		codex_section_option.add_item(_title_case(section))
	if not sections.is_empty():
		codex_section = sections[0]
		codex_section_option.select(0)
	product_ui_refreshing = false

func _configure_tab_titles() -> void:
	if shell_tabs == null:
		return
	var titles := [
		"%s Home" % visual_governance.shell_symbol_for_symbol_family("threshold"),
		"%s Profile" % visual_governance.shell_symbol_for_symbol_family("burden"),
		"%s Collection" % visual_governance.shell_symbol_for_symbol_family("witness"),
		"%s Archive" % visual_governance.shell_symbol_for_symbol_family("recursion"),
		"%s Cosmetics" % visual_governance.shell_symbol_for_symbol_family("witness"),
		"%s Settings" % visual_governance.shell_symbol_for_symbol_family("threshold")
	]
	for i in range(mini(shell_tabs.get_tab_count(), titles.size())):
		shell_tabs.set_tab_title(i, titles[i])

func _apply_profile_defaults_to_inputs() -> void:
	var last_run: Dictionary = Dictionary(profile_state.get("last_run", {}))
	if seed_edit != null and (seed_edit.text.strip_edges().is_empty() or seed_edit.text == "1337") and not last_run.is_empty():
		seed_edit.text = str(int(last_run.get("seed", 1337)))

func _refresh_product_shell() -> void:
	product_ui_refreshing = true
	_apply_shell_accessibility()
	if title_label:
		title_label.text = visual_governance.shell_title()
	if banner_label:
		banner_label.text = "  //  ".join(PROFILE_SERVICE_SCRIPT.build_profile_card_lines(profile_state, product_catalog))
	if session_summary_label:
		session_summary_label.text = "\n".join(_build_session_summary_lines())
	if shell_hint_label:
		shell_hint_label.text = "PgUp/PgDn or LB/RB: switch tabs | Esc/B: return Home"
	if home_hero_label:
		home_hero_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_profile_card_lines(profile_state, product_catalog))
	if home_overview_label:
		home_overview_label.text = "\n".join(_build_home_overview_lines())
	if home_quick_start_label:
		home_quick_start_label.text = _build_home_quick_start_text()
	if home_continue_label:
		home_continue_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_continue_guidance_lines(profile_state, NetworkManager.get_session_overview()))
	if home_last_run_label:
		home_last_run_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_last_run_lines(profile_state))
	if home_recent_runs_label:
		home_recent_runs_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_home_recent_run_lines(profile_state))
	if home_run_diagnostics_label:
		home_run_diagnostics_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_last_run_diagnostic_lines(profile_state))
	if profile_summary_label:
		profile_summary_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_profile_summary_lines(profile_state, product_catalog))
	if progress_summary_label:
		progress_summary_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_progression_preview_lines(profile_state, product_catalog))
	if mastery_summary_label:
		mastery_summary_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_mastery_lines(profile_state, product_catalog))
	if achievement_summary_label:
		achievement_summary_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_achievement_lines(profile_state, product_catalog))
	var history_browser_state := PROFILE_SERVICE_SCRIPT.build_history_browser_state(
		profile_state,
		history_filter_mode,
		history_sort_mode,
		history_selected_key,
		history_selected_index
	)
	if history_summary_label:
		history_summary_label.text = "\n".join(Array(history_browser_state.get("summary_lines", [])))
	if history_focus_label:
		history_focus_label.text = "\n".join(Array(history_browser_state.get("focus_lines", [])))
	if history_compare_label:
		history_compare_label.text = "\n".join(Array(history_browser_state.get("compare_lines", [])))
	if history_filter_option:
		var filter_index := _history_filter_index(history_filter_mode)
		if filter_index >= 0 and filter_index < history_filter_option.item_count:
			history_filter_option.select(filter_index)
	if history_sort_option:
		var sort_index := _history_sort_index(history_sort_mode)
		if sort_index >= 0 and sort_index < history_sort_option.item_count:
			history_sort_option.select(sort_index)
	_refresh_history_entries(history_browser_state)
	_refresh_collection_entries()
	_refresh_codex_entries()
	_refresh_cosmetic_entries()
	if large_text_check:
		large_text_check.button_pressed = bool(Dictionary(profile_state.get("settings", {})).get("large_text", false))
	if controller_glyphs_check:
		controller_glyphs_check.button_pressed = bool(Dictionary(profile_state.get("settings", {})).get("controller_glyphs", false))
	if hint_mode_button:
		hint_mode_button.text = "Hints: %s" % str(Dictionary(profile_state.get("settings", {})).get("hint_mode", "full")).capitalize()
	if voice_mode_button:
		voice_mode_button.text = "Voice: %s" % str(Dictionary(profile_state.get("settings", {})).get("voice_mode", "off")).replace("_", " ").capitalize()
	if push_to_talk_check:
		push_to_talk_check.button_pressed = bool(Dictionary(profile_state.get("settings", {})).get("push_to_talk", true))
	if mute_voice_check:
		mute_voice_check.button_pressed = bool(Dictionary(profile_state.get("settings", {})).get("mute_voice", false))
	if settings_summary_label:
		settings_summary_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_settings_lines(profile_state, product_catalog))
	if data_health_label:
		data_health_label.text = "\n".join(PRODUCT_CATALOG_SCRIPT.build_validation_report_lines(product_catalog))
	if controls_summary_label:
		var control_lines := PROFILE_SERVICE_SCRIPT.build_settings_help_lines(profile_state)
		control_lines.append("")
		control_lines.append_array(PROFILE_SERVICE_SCRIPT.build_voice_surface_lines(profile_state, NetworkManager.get_session_overview()))
		controls_summary_label.text = "\n".join(control_lines)
	product_ui_refreshing = false

func _refresh_collection_entries() -> void:
	collection_entries_cache = PROFILE_SERVICE_SCRIPT.build_collection_entries(profile_state, collection_section, product_catalog)
	if collection_summary_label:
		var seen_count := 0
		for entry in collection_entries_cache:
			if bool(entry.get("discovered", false)):
				seen_count += 1
		collection_summary_label.text = "%s: %d / %d discovered" % [collection_section, seen_count, collection_entries_cache.size()]
	if collection_entries_list == null:
		return
	collection_entries_list.clear()
	for entry in collection_entries_cache:
		collection_entries_list.add_item(str(entry.get("label", "")))
	if collection_entries_cache.is_empty():
		if collection_detail_label:
			collection_detail_label.text = "No entries in this collection section."
		return
	collection_selected_index = clampi(collection_selected_index, 0, collection_entries_cache.size() - 1)
	collection_entries_list.select(collection_selected_index)
	if collection_detail_label:
		collection_detail_label.text = str(collection_entries_cache[collection_selected_index].get("detail", ""))

func _refresh_codex_entries() -> void:
	codex_entries_cache = PROFILE_SERVICE_SCRIPT.build_codex_entries(profile_state, codex_section, product_catalog)
	if codex_summary_label:
		var seen_count := 0
		for entry in codex_entries_cache:
			if bool(entry.get("discovered", false)):
				seen_count += 1
		codex_summary_label.text = "%s: %d / %d known" % [_title_case(codex_section), seen_count, codex_entries_cache.size()]
	if codex_entries_list == null:
		return
	codex_entries_list.clear()
	for entry in codex_entries_cache:
		codex_entries_list.add_item(str(entry.get("label", "")))
	if codex_entries_cache.is_empty():
		if codex_detail_label:
			codex_detail_label.text = "No archive entries available."
		return
	codex_selected_index = clampi(codex_selected_index, 0, codex_entries_cache.size() - 1)
	codex_entries_list.select(codex_selected_index)
	if codex_detail_label:
		codex_detail_label.text = str(codex_entries_cache[codex_selected_index].get("detail", ""))

func _refresh_cosmetic_entries() -> void:
	cosmetic_entries_cache = PRODUCT_CATALOG_SCRIPT.get_cosmetics(cosmetic_category, product_catalog)
	if cosmetic_entries_list:
		cosmetic_entries_list.clear()
	for cosmetic in cosmetic_entries_cache:
		var cosmetic_id := str(cosmetic.get("id", ""))
		var owned: Array = Dictionary(profile_state.get("cosmetics", {})).get("owned", [])
		var equipped: Dictionary = Dictionary(Dictionary(profile_state.get("cosmetics", {})).get("equipped", {}))
		var slot := str(cosmetic.get("slot", ""))
		var prefix := "[Locked]"
		if owned.has(cosmetic_id):
			prefix = "[Owned]"
		if str(equipped.get(slot, "")) == cosmetic_id:
			prefix = "[Equipped]"
		if cosmetic_entries_list:
			cosmetic_entries_list.add_item("%s %s" % [prefix, str(cosmetic.get("display_name", ""))])
	if cosmetic_entries_cache.is_empty():
		selected_cosmetic_id = ""
		if cosmetic_preview_label:
			cosmetic_preview_label.text = "No cosmetics in this category."
		if cosmetic_summary_label:
			cosmetic_summary_label.text = "No cosmetics in this category."
		if equip_next_button:
			equip_next_button.disabled = true
		return
	var selected_index := _find_selected_cosmetic_index()
	cosmetic_selected_index = clampi(selected_index, 0, cosmetic_entries_cache.size() - 1)
	selected_cosmetic_id = str(cosmetic_entries_cache[cosmetic_selected_index].get("id", ""))
	if cosmetic_entries_list:
		cosmetic_entries_list.select(cosmetic_selected_index)
	if cosmetic_preview_label:
		cosmetic_preview_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_cosmetic_detail_lines(profile_state, selected_cosmetic_id, product_catalog))
	if cosmetic_summary_label:
		cosmetic_summary_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_cosmetic_lines(profile_state, cosmetic_category, product_catalog))
	if equip_next_button:
		var owned_ids := _owned_cosmetics_for_category(cosmetic_category)
		equip_next_button.disabled = owned_ids.is_empty()
		equip_next_button.text = "Equip selected" if owned_ids.has(selected_cosmetic_id) else "Equip next owned"

func _find_selected_cosmetic_index() -> int:
	if selected_cosmetic_id.is_empty():
		var equipped: Dictionary = Dictionary(Dictionary(profile_state.get("cosmetics", {})).get("equipped", {}))
		var equipped_id := str(equipped.get(cosmetic_category, ""))
		for i in range(cosmetic_entries_cache.size()):
			if str(cosmetic_entries_cache[i].get("id", "")) == equipped_id:
				return i
		return 0
	for i in range(cosmetic_entries_cache.size()):
		if str(cosmetic_entries_cache[i].get("id", "")) == selected_cosmetic_id:
			return i
	return 0

func _build_home_overview_lines() -> Array[String]:
	return PROFILE_SERVICE_SCRIPT.build_home_overview_lines(profile_state, NetworkManager.get_session_overview(), product_catalog)

func _focus_home_primary_control() -> void:
	var session: Dictionary = NetworkManager.get_session_overview() if NetworkManager.has_method("get_session_overview") else {}
	if reconnect_button != null and not reconnect_button.disabled and bool(session.get("reconnect_available", false)):
		reconnect_button.grab_focus()
		return
	if bool(session.get("connected", false)):
		if start_button != null and start_button.visible and not start_button.disabled:
			start_button.grab_focus()
			return
		if ready_button != null and not ready_button.disabled:
			ready_button.grab_focus()
			return
		if leave_button != null:
			leave_button.grab_focus()
			return
	if host_button != null:
		host_button.grab_focus()

func _build_home_quick_start_text() -> String:
	var session: Dictionary = NetworkManager.get_session_overview() if NetworkManager.has_method("get_session_overview") else {}
	return "\n".join(PROFILE_SERVICE_SCRIPT.build_home_quick_start_lines(profile_state, session))

func _build_session_summary_lines() -> Array[String]:
	var session: Dictionary = NetworkManager.get_session_overview() if NetworkManager.has_method("get_session_overview") else {}
	var lines: Array[String] = NetworkManager.build_session_policy_lines(session) if NetworkManager.has_method("build_session_policy_lines") else []
	if lines.is_empty():
		lines.append("Session: Offline")
	var seed_value := int(session.get("seed", 0))
	if seed_value > 0:
		lines.append("Seed: %d" % seed_value)
	var profile_lines := PROFILE_SERVICE_SCRIPT.build_home_overview_lines(profile_state, session, product_catalog)
	if profile_lines.size() >= 4:
		lines.append(profile_lines[3])
	return lines

func _owned_cosmetics_for_category(category: String) -> Array[String]:
	var owned: Array = Dictionary(profile_state.get("cosmetics", {})).get("owned", [])
	var result: Array[String] = []
	for cosmetic in PRODUCT_CATALOG_SCRIPT.get_cosmetics(category, product_catalog):
		var cosmetic_id := str(cosmetic.get("id", ""))
		if owned.has(cosmetic_id):
			result.append(cosmetic_id)
	return result

func _refresh_history_entries(browser_state: Dictionary = {}) -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	var restore_filter_focus := focus_owner == history_filter_option
	var restore_sort_focus := focus_owner == history_sort_option
	var restore_list_focus := focus_owner == history_entries_list
	if restore_filter_focus:
		history_focus_target = "filter"
	elif restore_sort_focus:
		history_focus_target = "sort"
	elif restore_list_focus:
		history_focus_target = "list"
	var state := browser_state
	if state.is_empty():
		state = PROFILE_SERVICE_SCRIPT.build_history_browser_state(
			profile_state,
			history_filter_mode,
			history_sort_mode,
			history_selected_key,
			history_selected_index
		)
	history_entries_cache = Array(state.get("entries", []))
	history_selected_index = int(state.get("selected_index", -1))
	history_selected_key = str(state.get("selected_key", ""))
	if history_entries_list == null:
		return
	history_entries_list.clear()
	for i in range(history_entries_cache.size()):
		var entry: Dictionary = Dictionary(history_entries_cache[i])
		var prefix := ">> " if i == history_selected_index else "   "
		history_entries_list.add_item("%s%s" % [prefix, str(entry.get("label", ""))])
	if history_entries_cache.is_empty():
		history_selected_index = -1
		history_selected_key = ""
		if history_focus_label:
			history_focus_label.text = "\n".join(Array(state.get("focus_lines", [])))
		if history_compare_label:
			history_compare_label.text = "\n".join(Array(state.get("compare_lines", [])))
		if history_detail_label:
			history_detail_label.text = "\n".join(Array(state.get("detail_lines", ["No runs match the current history filter."])))
		if restore_filter_focus and history_filter_option != null:
			history_filter_option.grab_focus()
		elif restore_sort_focus and history_sort_option != null:
			history_sort_option.grab_focus()
		elif history_filter_option != null:
			history_filter_option.grab_focus()
		return
	history_entries_list.select(history_selected_index)
	if history_focus_label:
		history_focus_label.text = "\n".join(Array(state.get("focus_lines", [])))
	if history_compare_label:
		history_compare_label.text = "\n".join(Array(state.get("compare_lines", [])))
	if history_detail_label:
		history_detail_label.text = "\n".join(Array(state.get("detail_lines", [])))
	if restore_list_focus and history_entries_list != null:
		history_entries_list.grab_focus()
	elif restore_sort_focus and history_sort_option != null:
		history_sort_option.grab_focus()
	elif restore_filter_focus and history_filter_option != null:
		history_filter_option.grab_focus()

func _save_profile_state() -> void:
	PROFILE_SERVICE_SCRIPT.save_profile(profile_state, PROFILE_SERVICE_SCRIPT.SAVE_PATH, product_catalog)

func _apply_shell_accessibility() -> void:
	var large_text := bool(Dictionary(profile_state.get("settings", {})).get("large_text", false))
	var label_size := 20 if large_text else 16
	var title_size := 28 if large_text else 22
	var emphasis_size := label_size + 2
	var shell_palette: Dictionary = visual_governance.shell_palette()
	var shell_title_color: Color = shell_palette.get("title", Color(0.92, 0.82, 0.58))
	var shell_banner_color: Color = shell_palette.get("banner", Color(0.69, 0.77, 0.84))
	var shell_hint_color: Color = shell_palette.get("muted", Color(0.58, 0.62, 0.70))
	var shell_focus_color: Color = shell_palette.get("focus", Color(0.86, 0.84, 0.70))
	var shell_secondary: Color = shell_palette.get("secondary", Color(0.76, 0.76, 0.74))
	var shell_archive: Color = shell_palette.get("archive", Color(0.76, 0.70, 0.58))
	var shell_broadcast: Color = shell_palette.get("broadcast", Color(0.80, 0.73, 0.62))
	for control in [title_label, banner_label, status_label, players_label, shell_hint_label, home_hero_label, home_overview_label, home_quick_start_label, home_continue_label, home_last_run_label, home_recent_runs_label, home_run_diagnostics_label, profile_summary_label, mastery_summary_label, progress_summary_label, achievement_summary_label, history_summary_label, history_focus_label, history_compare_label, history_detail_label, collection_detail_label, collection_summary_label, codex_detail_label, codex_summary_label, cosmetic_preview_label, cosmetic_summary_label, settings_summary_label, data_health_label, controls_summary_label]:
		if control == null:
			continue
		control.add_theme_font_size_override("font_size", title_size if control == title_label else label_size)
		control.add_theme_color_override("font_color", shell_palette.get("primary", Color(0.84, 0.84, 0.84)))
	if title_label:
		title_label.add_theme_color_override("font_color", shell_title_color)
	if banner_label:
		banner_label.add_theme_color_override("font_color", shell_banner_color)
		banner_label.add_theme_font_size_override("font_size", emphasis_size)
	if session_summary_label:
		session_summary_label.add_theme_color_override("font_color", shell_secondary)
	if shell_hint_label:
		shell_hint_label.add_theme_color_override("font_color", shell_hint_color)
	for secondary_control in [home_overview_label, home_last_run_label, history_summary_label, history_detail_label, collection_summary_label, collection_detail_label]:
		if secondary_control == null:
			continue
		secondary_control.add_theme_color_override("font_color", shell_secondary)
	for archive_control in [codex_summary_label, codex_detail_label, history_compare_label]:
		if archive_control == null:
			continue
		archive_control.add_theme_color_override("font_color", shell_archive)
	for broadcast_control in [home_recent_runs_label, home_run_diagnostics_label]:
		if broadcast_control == null:
			continue
		broadcast_control.add_theme_color_override("font_color", shell_broadcast)
	for emphasis_control in [home_hero_label, home_continue_label, history_focus_label, profile_summary_label]:
		if emphasis_control == null:
			continue
		emphasis_control.add_theme_color_override("font_color", shell_focus_color)
	for emphasis_control in [home_continue_label, history_focus_label, profile_summary_label]:
		if emphasis_control == null:
			continue
		emphasis_control.add_theme_font_size_override("font_size", emphasis_size)
	for control in [host_button, join_button, leave_button, reconnect_button, ready_button, start_button, history_filter_option, history_sort_option, history_entries_list, collection_section_option, collection_entries_list, codex_section_option, codex_entries_list, cosmetic_category_option, cosmetic_entries_list, equip_next_button, large_text_check, controller_glyphs_check, hint_mode_button, voice_mode_button, push_to_talk_check, mute_voice_check, reset_settings_button]:
		if control == null:
			continue
		control.add_theme_font_size_override("font_size", label_size)

func _focus_current_tab_primary() -> void:
	match shell_tabs.current_tab:
		0:
			_focus_home_primary_control()
		1:
			if history_focus_target == "list" and history_entries_list != null and not history_entries_cache.is_empty():
				history_entries_list.grab_focus()
			elif history_focus_target == "sort" and history_sort_option != null:
				history_sort_option.grab_focus()
			elif history_filter_option != null:
				history_filter_option.grab_focus()
			elif history_sort_option != null:
				history_sort_option.grab_focus()
			elif history_entries_list != null:
				history_entries_list.grab_focus()
			else:
				host_button.grab_focus()
		2:
			collection_section_option.grab_focus()
		3:
			codex_section_option.grab_focus()
		4:
			cosmetic_category_option.grab_focus()
		5:
			if large_text_check != null:
				large_text_check.grab_focus()
			elif voice_mode_button != null:
				voice_mode_button.grab_focus()
			else:
				host_button.grab_focus()

func _on_shell_tab_changed(_index: int) -> void:
	_focus_current_tab_primary()

func _on_collection_section_selected(index: int) -> void:
	if product_ui_refreshing:
		return
	var sections := PROFILE_SERVICE_SCRIPT.collection_sections()
	if index < 0 or index >= sections.size():
		return
	collection_section = sections[index]
	collection_selected_index = 0
	_refresh_collection_entries()

func _on_collection_entry_selected(index: int) -> void:
	if index < 0 or index >= collection_entries_cache.size():
		return
	collection_selected_index = index
	if collection_detail_label:
		collection_detail_label.text = str(collection_entries_cache[index].get("detail", ""))

func _on_codex_section_selected(index: int) -> void:
	if product_ui_refreshing:
		return
	var sections := PROFILE_SERVICE_SCRIPT.build_codex_sections(profile_state, product_catalog)
	if index < 0 or index >= sections.size():
		return
	codex_section = sections[index]
	codex_selected_index = 0
	_refresh_codex_entries()

func _on_codex_entry_selected(index: int) -> void:
	if index < 0 or index >= codex_entries_cache.size():
		return
	codex_selected_index = index
	if codex_detail_label:
		codex_detail_label.text = str(codex_entries_cache[index].get("detail", ""))

func _on_cosmetic_category_selected(index: int) -> void:
	if product_ui_refreshing:
		return
	var categories := PRODUCT_CATALOG_SCRIPT.cosmetic_categories(product_catalog)
	if index < 0 or index >= categories.size():
		return
	cosmetic_category = categories[index]
	selected_cosmetic_id = ""
	cosmetic_selected_index = 0
	_refresh_cosmetic_entries()

func _on_cosmetic_entry_selected(index: int) -> void:
	if index < 0 or index >= cosmetic_entries_cache.size():
		return
	cosmetic_selected_index = index
	selected_cosmetic_id = str(cosmetic_entries_cache[index].get("id", ""))
	if cosmetic_preview_label:
		cosmetic_preview_label.text = "\n".join(PROFILE_SERVICE_SCRIPT.build_cosmetic_detail_lines(profile_state, selected_cosmetic_id, product_catalog))
	if equip_next_button:
		var owned_ids := _owned_cosmetics_for_category(cosmetic_category)
		equip_next_button.text = "Equip selected" if owned_ids.has(selected_cosmetic_id) else "Equip next owned"

func _on_history_entry_selected(index: int) -> void:
	if index < 0 or index >= history_entries_cache.size():
		return
	history_selected_index = index
	history_selected_key = str(history_entries_cache[index].get("key", ""))
	history_focus_target = "list"
	_refresh_product_shell()

func _populate_history_filters() -> void:
	if history_filter_option == null:
		return
	history_filter_option.clear()
	for mode in PROFILE_SERVICE_SCRIPT.history_filter_modes():
		history_filter_option.add_item(mode)

func _populate_history_sorts() -> void:
	if history_sort_option == null:
		return
	history_sort_option.clear()
	for mode in PROFILE_SERVICE_SCRIPT.history_sort_modes():
		history_sort_option.add_item(_title_case(mode))

func _history_filter_index(mode: String) -> int:
	var modes := PROFILE_SERVICE_SCRIPT.history_filter_modes()
	return modes.find(mode)

func _history_sort_index(mode: String) -> int:
	var modes := PROFILE_SERVICE_SCRIPT.history_sort_modes()
	return modes.find(mode)

func _on_history_filter_selected(index: int) -> void:
	if product_ui_refreshing:
		return
	var modes := PROFILE_SERVICE_SCRIPT.history_filter_modes()
	if index < 0 or index >= modes.size():
		return
	history_filter_mode = modes[index]
	history_focus_target = "filter"
	_refresh_product_shell()

func _on_history_sort_selected(index: int) -> void:
	if product_ui_refreshing:
		return
	var modes := PROFILE_SERVICE_SCRIPT.history_sort_modes()
	if index < 0 or index >= modes.size():
		return
	history_sort_mode = modes[index]
	history_focus_target = "sort"
	_refresh_product_shell()

func _handle_history_focus_shift(move_right: bool) -> bool:
	if history_filter_option == null or history_entries_list == null:
		return false
	var owner := get_viewport().gui_get_focus_owner()
	if move_right:
		if owner == history_filter_option and history_sort_option != null:
			history_focus_target = "sort"
			history_sort_option.grab_focus()
			return true
		if (owner == history_filter_option and history_sort_option == null) or owner == history_sort_option:
			if not history_entries_cache.is_empty():
				history_focus_target = "list"
				history_entries_list.grab_focus()
				return true
	else:
		if owner == history_entries_list and history_sort_option != null:
			history_focus_target = "sort"
			history_sort_option.grab_focus()
			return true
		if owner == history_entries_list and history_sort_option == null:
			history_focus_target = "filter"
			history_filter_option.grab_focus()
			return true
		if owner == history_sort_option:
			history_focus_target = "filter"
			history_filter_option.grab_focus()
			return true
	return false

func _on_equip_next_button_pressed() -> void:
	var owned_ids := _owned_cosmetics_for_category(cosmetic_category)
	if owned_ids.has(selected_cosmetic_id):
		profile_state = PROFILE_SERVICE_SCRIPT.equip_cosmetic(profile_state, selected_cosmetic_id, product_catalog)
	else:
		profile_state = PROFILE_SERVICE_SCRIPT.cycle_equipped_cosmetic(profile_state, cosmetic_category, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _on_large_text_toggled(button_pressed: bool) -> void:
	if product_ui_refreshing:
		return
	profile_state = PROFILE_SERVICE_SCRIPT.set_setting(profile_state, "large_text", button_pressed, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _on_controller_glyphs_toggled(button_pressed: bool) -> void:
	if product_ui_refreshing:
		return
	profile_state = PROFILE_SERVICE_SCRIPT.set_setting(profile_state, "controller_glyphs", button_pressed, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _on_hint_mode_button_pressed() -> void:
	profile_state = PROFILE_SERVICE_SCRIPT.toggle_hint_mode(profile_state, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _on_voice_mode_button_pressed() -> void:
	profile_state = PROFILE_SERVICE_SCRIPT.toggle_voice_mode(profile_state, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _on_push_to_talk_toggled(button_pressed: bool) -> void:
	if product_ui_refreshing:
		return
	profile_state = PROFILE_SERVICE_SCRIPT.set_setting(profile_state, "push_to_talk", button_pressed, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _on_mute_voice_toggled(button_pressed: bool) -> void:
	if product_ui_refreshing:
		return
	profile_state = PROFILE_SERVICE_SCRIPT.set_setting(profile_state, "mute_voice", button_pressed, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _on_reset_settings_button_pressed() -> void:
	profile_state = PROFILE_SERVICE_SCRIPT.reset_settings(profile_state, product_catalog)
	_save_profile_state()
	_refresh_product_shell()

func _title_case(value: String) -> String:
	return value.replace("_", " ").capitalize()
