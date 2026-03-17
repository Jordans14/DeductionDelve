extends SceneTree
func _init() -> void:
	var script = load("res://src/gen/narrative_pressure_engine.gd")
	if script == null:
		push_error("failed")
		quit(1)
		return
	print("loaded")
	quit(0)
