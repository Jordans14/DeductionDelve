extends SceneTree

func _init():
	print("DETAILED_LOAD_CHECK: Starting detailed resource load tests...")
	
	print("Testing Player.tscn...")
	var player_result = ResourceLoader.load("res://scenes/Player.tscn")
	if player_result == null:
		print("DETAILED_LOAD_CHECK: FAILED to load Player.tscn")
		quit(1)
	else:
		print("DETAILED_LOAD_CHECK: Player.tscn loaded successfully")
		print("DETAILED_LOAD_CHECK: Player.tscn type: " + str(player_result.get_class()))
	
	print("Testing Evidence.tscn...")
	var evidence_result = ResourceLoader.load("res://scenes/Evidence.tscn")
	if evidence_result == null:
		print("DETAILED_LOAD_CHECK: FAILED to load Evidence.tscn")
		quit(1)
	else:
		print("DETAILED_LOAD_CHECK: Evidence.tscn loaded successfully")
		print("DETAILED_LOAD_CHECK: Evidence.tscn type: " + str(evidence_result.get_class()))
	
	print("DETAILED_LOAD_CHECK: All resources loaded successfully!")
	quit(0)
