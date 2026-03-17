extends Area2D
class_name SpelunkyDoor

const VISUAL_GOVERNANCE_SCRIPT = preload("res://src/visual/visual_governance.gd")

var linked_pos: Vector2 = Vector2.ZERO
var is_background: bool = false
var door_id: int = -1

var _visual: Polygon2D
var _frame: Line2D
var _hole: Polygon2D
var _lintel: Line2D
var _brace_left: Line2D
var _brace_right: Line2D
var _threshold_mark: Line2D
var _visual_governance: RefCounted = VISUAL_GOVERNANCE_SCRIPT.new()

func _ready() -> void:
	collision_layer = 16 # specific layer for interactables like doors
	collision_mask = 0
	
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 48) # 1 tile wide, 1.5 tiles tall
	col.shape = rect
	col.position = Vector2(0, -24)
	add_child(col)
	
	_visual = Polygon2D.new()
	_visual.position = Vector2(0, -24)
	_visual.polygon = PackedVector2Array([
		Vector2(-16, 24), Vector2(-16, -8), Vector2(-10, -20), Vector2(10, -20), Vector2(16, -8), Vector2(16, 24)
	])

	_frame = Line2D.new()
	_frame.width = 3.0
	_frame.antialiased = true
	_frame.points = PackedVector2Array([
		Vector2(-16, 24), Vector2(-16, -8), Vector2(-10, -20), Vector2(10, -20), Vector2(16, -8), Vector2(16, 24)
	])
	_visual.add_child(_frame)

	_hole = Polygon2D.new()
	_hole.polygon = PackedVector2Array([
		Vector2(-10, 18), Vector2(-10, -2), Vector2(-6, -12), Vector2(6, -12), Vector2(10, -2), Vector2(10, 18)
	])
	_visual.add_child(_hole)

	_lintel = Line2D.new()
	_lintel.width = 2.0
	_lintel.antialiased = true
	_lintel.points = PackedVector2Array([
		Vector2(-12, -14), Vector2(12, -14)
	])
	_visual.add_child(_lintel)

	_brace_left = Line2D.new()
	_brace_left.width = 2.0
	_brace_left.antialiased = true
	_brace_left.points = PackedVector2Array([
		Vector2(-12, 20), Vector2(-16, 8), Vector2(-16, -6)
	])
	_visual.add_child(_brace_left)

	_brace_right = Line2D.new()
	_brace_right.width = 2.0
	_brace_right.antialiased = true
	_brace_right.points = PackedVector2Array([
		Vector2(12, 20), Vector2(16, 8), Vector2(16, -6)
	])
	_visual.add_child(_brace_right)

	_threshold_mark = Line2D.new()
	_threshold_mark.width = 1.6
	_threshold_mark.antialiased = true
	_threshold_mark.points = PackedVector2Array([
		Vector2(-10, 20), Vector2(0, 16), Vector2(10, 20)
	])
	_visual.add_child(_threshold_mark)
	
	add_child(_visual)
	z_index = _visual_governance.motion_priority_for("environment")
	_refresh_visual_state()

func set_link(pos: Vector2, id: int, bg: bool) -> void:
	linked_pos = pos
	door_id = id
	is_background = bg
	_refresh_visual_state()

func _refresh_visual_state() -> void:
	if _visual == null:
		return
	if is_background:
		_visual.color = Color(0.08, 0.10, 0.10, 0.45)
		if _frame:
			_frame.default_color = Color(0.18, 0.28, 0.26, 0.55)
		if _hole:
			_hole.color = Color(0.0, 0.0, 0.0, 0.42)
		if _lintel:
			_lintel.default_color = Color(0.22, 0.34, 0.32, 0.45)
		if _brace_left:
			_brace_left.default_color = Color(0.20, 0.30, 0.28, 0.42)
		if _brace_right:
			_brace_right.default_color = Color(0.20, 0.30, 0.28, 0.42)
		if _threshold_mark:
			_threshold_mark.default_color = Color(0.28, 0.40, 0.38, 0.32)
		_visual.modulate = Color(1.0, 1.0, 1.0, 0.65)
		z_index = _visual_governance.motion_priority_for("cosmetic")
	else:
		_visual.color = Color(0.14, 0.08, 0.06, 0.95)
		if _frame:
			_frame.default_color = Color(0.46, 0.30, 0.14, 0.95)
		if _hole:
			_hole.color = Color(0.0, 0.0, 0.0, 0.82)
		if _lintel:
			_lintel.default_color = Color(0.76, 0.58, 0.30, 0.64)
		if _brace_left:
			_brace_left.default_color = Color(0.64, 0.48, 0.24, 0.62)
		if _brace_right:
			_brace_right.default_color = Color(0.64, 0.48, 0.24, 0.62)
		if _threshold_mark:
			_threshold_mark.default_color = Color(0.92, 0.72, 0.34, 0.52)
		_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
		z_index = _visual_governance.motion_priority_for("environment")
