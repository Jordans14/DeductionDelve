extends SceneTree

func _init():
	print("GAME_READY_CHECK: Starting game scene load test...")
	
	var game_scene = ResourceLoader.load("res://scenes/Game.tscn")
	if game_scene == null:
		print("GAME_READY_CHECK: FAILED to load Game.tscn")
		quit(1)
	else:
		print("GAME_READY_CHECK: Game.tscn loaded successfully")
	
	# Instantiate the scene to test if it can be instantiated without errors
	var instance = game_scene.instantiate()
	if instance == null:
		print("GAME_READY_CHECK: FAILED to instantiate Game.tscn")
		quit(1)
	else:
		print("GAME_READY_CHECK: Game.tscn instantiated successfully")
		instance.queue_free()
	
	print("GAME_READY_CHECK: All tests passed!")
	quit(0)
