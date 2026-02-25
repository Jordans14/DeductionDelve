extends Control

@onready var status_label: Label = $Panel/VBox/Status
@onready var players_label: Label = $Panel/VBox/Players
@onready var address_edit: LineEdit = $Panel/VBox/Grid/AddressEdit
@onready var port_edit: LineEdit = $Panel/VBox/Grid/PortEdit
@onready var seed_edit: LineEdit = $Panel/VBox/Grid/SeedEdit
@onready var ready_button: Button = $Panel/VBox/Buttons/ReadyButton
@onready var start_button: Button = $Panel/VBox/Buttons/StartButton

var local_ready: bool = false

func _ready() -> void:
	NetworkManager.connection_changed.connect(_on_connection_changed)
	NetworkManager.lobby_updated.connect(_on_lobby_updated)
	NetworkManager.run_started.connect(_on_run_started)
	_apply_cli_args()
	_refresh_buttons()

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

func _on_ready_button_pressed() -> void:
	local_ready = not local_ready
	NetworkManager.set_local_ready(local_ready)
	_refresh_buttons()

func _on_start_button_pressed() -> void:
	if not NetworkManager.is_host:
		return
	var seed := int(seed_edit.text)
	NetworkManager.start_run(seed, 8)

func _on_connection_changed(status: String) -> void:
	status_label.text = status
	_refresh_buttons()

func _on_lobby_updated(players: Array, ready_state: Dictionary, host_flag: bool) -> void:
	var lines: Array[String] = []
	for peer_id in players:
		var state := "Not Ready"
		if bool(ready_state.get(peer_id, false)):
			state = "Ready"
		lines.append("P%d - %s" % [int(peer_id), state])
	players_label.text = "\n".join(lines)
	start_button.visible = host_flag
	start_button.disabled = not NetworkManager.all_ready()
	local_ready = bool(ready_state.get(multiplayer.get_unique_id(), false))
	ready_button.text = "Ready: %s" % ["YES" if local_ready else "NO"]

func _on_run_started(_seed: int, _chain: Array) -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _refresh_buttons() -> void:
	var connected := multiplayer.multiplayer_peer != null
	ready_button.disabled = not connected
	start_button.disabled = not (connected and NetworkManager.is_host and NetworkManager.all_ready())
	start_button.visible = NetworkManager.is_host

func _apply_cli_args() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "--mode=host":
			_on_host_button_pressed()
		elif arg.begins_with("--address="):
			address_edit.text = arg.trim_prefix("--address=")
		elif arg.begins_with("--port="):
			port_edit.text = arg.trim_prefix("--port=")
		elif arg.begins_with("--seed="):
			seed_edit.text = arg.trim_prefix("--seed=")
		elif arg == "--mode=client":
			_on_join_button_pressed()
