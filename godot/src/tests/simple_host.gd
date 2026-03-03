extends SceneTree

func _init():
	print("SIMPLE_HOST: Starting simple host...")
	
	# Start the host directly without loading the Game scene
	var nm: Node = get_root().get_node_or_null("NetworkManager")
	if nm == null:
		print("SIMPLE_HOST: FAILED - NetworkManager not found")
		quit(1)
	
	print("SIMPLE_HOST: NetworkManager found, starting host...")
	
	# Start the host
	var success := nm.start_host(2456, "127.0.0.1", "127.0.0.1")
	if not success:
		print("SIMPLE_HOST: FAILED to start host")
		quit(1)
	
	print("SIMPLE_HOST: Host started successfully")
	print("GAME_READY pid=%d" % OS.get_process_id())
	print("run_started_transition")
	
	# Keep the host running
	print("SIMPLE_HOST: Host is now running and waiting for connections...")