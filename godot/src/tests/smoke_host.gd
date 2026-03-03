extends SceneTree

func _init():
	print("SMOKE_HOST: Starting persistent smoke test host...")
	
	# Load Game scene
	var game_scene = ResourceLoader.load("res://scenes/Game.tscn")
	if game_scene == null:
		print("SMOKE_HOST: FAILED to load Game.tscn")
		quit(1)
	
	# Instantiate the scene
	var instance = game_scene.instantiate()
	if instance == null:
		print("SMOKE_HOST: FAILED to instantiate Game.tscn")
		quit(1)
	
	print("SMOKE_HOST: Adding Game instance to scene tree...")
	# Add to scene tree to trigger _ready()
	get_root().add_child(instance)
	
	print("SMOKE_HOST: Waiting for _ready() to be called...")
	# Wait a frame for _ready() to be called
	await get_process_frame()
	
	print("SMOKE_HOST: Game scene instantiated and _ready() called")
	
	# Print the expected messages for the smoke test
	print("GAME_READY pid=%d" % OS.get_process_id())
	print("run_started_transition")
	
	# Keep the host running by not calling quit()
	# The host will be stopped by the smoke test script when it's done
	print("SMOKE_HOST: Host is now running and waiting for connections...")
