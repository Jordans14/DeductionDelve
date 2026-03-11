extends Node2D
class_name SpelunkyZipline

const TRACK_LAYER := 16
const TRACK_HALF_WIDTH := 10.0

var start_world := Vector2.ZERO
var end_world := Vector2.ZERO
var track_area: Area2D
var track_line: Line2D

func configure(world_start: Vector2, world_end: Vector2) -> void:
	start_world = world_start
	end_world = world_end
	global_position = world_start
	_ensure_visuals()
	_refresh_geometry()

func nearest_ratio(world_pos: Vector2) -> float:
	var segment := end_world - start_world
	var length_sq := maxf(segment.length_squared(), 0.001)
	var projected := clampf((world_pos - start_world).dot(segment) / length_sq, 0.0, 1.0)
	return projected

func point_at_ratio(ratio: float) -> Vector2:
	return start_world.lerp(end_world, clampf(ratio, 0.0, 1.0))

func travel_direction() -> Vector2:
	return (end_world - start_world).normalized()

func travel_length() -> float:
	return start_world.distance_to(end_world)

func _ready() -> void:
	_ensure_visuals()
	if start_world == Vector2.ZERO and end_world == Vector2.ZERO:
		start_world = global_position
		end_world = global_position + Vector2(240, 0)
	_refresh_geometry()

func _ensure_visuals() -> void:
	if track_line == null:
		track_line = Line2D.new()
		track_line.default_color = Color(0.72, 0.76, 0.86, 0.95)
		track_line.width = 4.0
		track_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		track_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		add_child(track_line)
	if track_area == null:
		track_area = Area2D.new()
		track_area.collision_layer = TRACK_LAYER
		track_area.collision_mask = 0
		track_area.add_to_group("zipline_track")
		var shape := CollisionPolygon2D.new()
		track_area.add_child(shape)
		add_child(track_area)

func _refresh_geometry() -> void:
	var local_end := end_world - start_world
	if track_line:
		track_line.clear_points()
		track_line.add_point(Vector2.ZERO)
		track_line.add_point(local_end)
	if track_area and track_area.get_child_count() > 0:
		var collision := track_area.get_child(0) as CollisionPolygon2D
		if collision:
			var tangent := local_end.normalized()
			var normal := Vector2(-tangent.y, tangent.x) * TRACK_HALF_WIDTH
			collision.polygon = PackedVector2Array([
				Vector2.ZERO + normal,
				local_end + normal,
				local_end - normal,
				Vector2.ZERO - normal
			])
