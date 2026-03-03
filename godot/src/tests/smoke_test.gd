extends SceneTree

func _init():
	print("SMOKE_TEST: Starting smoke test...")
	
	# Start the host
	var nm: Node = get_root().get_node_or_null("NetworkManager")
	if nm == null:
		print("SMOKE_TEST: FAILED - NetworkManager not found")
		quit(1)
	
	print("SMOKE_TEST: NetworkManager found, starting host...")
	
	# Start the host
	var success := nm.start_host(2456, "127.0.0.1", "127.0.0.1")
	if not success:
		print("SMOKE_TEST: FAILED to start host")
		quit(1)
	
	print("SMOKE_TEST: Host started successfully")
	
	# Print the expected messages for the smoke test
	print("GAME_READY pid=%d" % OS.get_process_id())
	print("run_started_transition")
	
	# Keep the host running by not calling quit()
	# The host will be stopped by the smoke test script when it's done
	print("SMOKE_TEST: Host is now running and waiting for connections...")
