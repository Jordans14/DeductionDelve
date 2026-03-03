extends SceneTree

# Inner class for the actual client logic
class SmokeClientRunner extends Node:
	var network_manager: Node = null
	var connected: bool = false
	var ready_sent: bool = false
	var timeout_counter: int = 0
	var max_timeout: int = 1200  # 60 seconds at 20 FPS
	var max_poll_frames: int = 300  # 15 seconds to find NetworkManager
	var poll_counter: int = 0

	func _process(delta: float):
		poll_counter += 1
		
		# First, wait for NetworkManager to be available
		if network_manager == null:
			if poll_counter > max_poll_frames:
				print("SMOKE_CLIENT: TIMEOUT - NetworkManager not found after polling")
				get_tree().quit(1)
				return
			
			network_manager = get_tree().root.get_node_or_null("NetworkManager")
			if network_manager == null:
				return  # Continue polling
			
			print("SMOKE_CLIENT: NetworkManager found, proceeding with connection")
			_setup_connection()
			return
		
		# Connection and ready logic
		timeout_counter += 1
		
		if timeout_counter > max_timeout:
			print("SMOKE_CLIENT: TIMEOUT - Connection took too long")
			get_tree().quit(1)
			return
		
		if connected and ready_sent:
			# Success condition reached - exit with success
			print("SMOKE_CLIENT: Connection and ready state achieved, exiting successfully")
			get_tree().quit(0)

	func _setup_connection():
		var host_address = "127.0.0.1"
		var host_port = 2456
		
		print("SMOKE_CLIENT: Connecting to host %s:%d" % [host_address, host_port])
		
		# Set up signals first, then connect
		network_manager.connection_changed.connect(_on_connection_changed)
		network_manager.lobby_updated.connect(_on_lobby_updated)
		
		network_manager.join_host(host_address, host_port)

	func _on_connection_changed(status: String):
		print("SMOKE_CLIENT: Connection status: %s" % status)
		if status.contains("Connected to host"):
			connected = true
			print("SMOKE_CLIENT: Setting ready...")
			network_manager.set_local_ready(true)
			ready_sent = true

	func _on_lobby_updated(players: Array, ready_state: Dictionary, is_host: bool):
		print("SMOKE_CLIENT: Lobby updated - players: %s, ready: %s" % [players, ready_state])

	func _finalize():
		print("SMOKE_CLIENT: Runner finalizing...")
		if network_manager:
			network_manager.disconnect_peer("smoke_client_exit")

# SceneTree wrapper implementation
func _init():
	print("SMOKE_CLIENT: Starting smoke test client wrapper...")
	
	# Create and add the runner node to the root
	var runner = SmokeClientRunner.new()
	get_root().add_child(runner)
	
	# Start processing
	get_root().set_process(true)