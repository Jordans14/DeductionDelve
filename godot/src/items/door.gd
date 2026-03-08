extends Area2D
class_name SpelunkyDoor

var linked_pos: Vector2 = Vector2.ZERO
var is_background: bool = false
var door_id: int = -1

var _visual: ColorRect

func _ready() -> void:
	collision_layer = 16 # specific layer for interactables like doors
	collision_mask = 0
	
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 48) # 1 tile wide, 1.5 tiles tall
	col.shape = rect
	col.position = Vector2(0, -24)
	add_child(col)
	
	_visual = ColorRect.new()
	_visual.size = rect.size
	_visual.position = col.position - rect.size / 2.0
	_visual.color = Color(0.1, 0.05, 0.05) if not is_background else Color(0.05, 0.1, 0.05)
	
	# Add a small wooden frame
	var frame := ReferenceRect.new()
	frame.size = _visual.size
	frame.border_color = Color(0.2, 0.1, 0.05)
	frame.border_width = 3.0
	frame.editor_only = false
	_visual.add_child(frame)
	
	# Small dark opening indicator
	var hole := ColorRect.new()
	hole.size = Vector2(24, 40)
	hole.position = Vector2(4, 8)
	hole.color = Color(0.0, 0.0, 0.0, 0.8)
	_visual.add_child(hole)
	
	add_child(_visual)

func set_link(pos: Vector2, id: int, bg: bool) -> void:
	linked_pos = pos
	door_id = id
	is_background = bg
