extends Node2D

@onready var core: Polygon2D = $Core
@onready var label: Label = $Label
var corruption_ring: Polygon2D
var corruption_glyph: Line2D

var artifact_id: int = 0
var room_slot: int = -1
var signature: String = ""
var is_forged: bool = false
var owner_peer_id: int = 0

func configure(data: Dictionary) -> void:
	artifact_id = int(data.get("artifact_id", 0))
	room_slot = int(data.get("room_slot", -1))
	signature = str(data.get("signature", ""))
	is_forged = bool(data.get("is_forged", false))
	owner_peer_id = int(data.get("owner_peer_id", 0))
	global_position = data.get("world_pos", Vector2.ZERO)
	_apply_visuals()

func sync_state(data: Dictionary) -> void:
	owner_peer_id = int(data.get("owner_peer_id", 0))
	signature = str(data.get("signature", signature))
	is_forged = bool(data.get("is_forged", is_forged))
	if owner_peer_id == 0:
		global_position = data.get("world_pos", global_position)
	_apply_visuals()

func set_visual_position(pos: Vector2) -> void:
	global_position = pos

func _ready() -> void:
	corruption_ring = Polygon2D.new()
	corruption_ring.color = Color(0.80, 0.24, 0.36, 0.0)
	corruption_ring.polygon = PackedVector2Array([
		Vector2(0, -18), Vector2(12, -10), Vector2(16, 0), Vector2(12, 10),
		Vector2(0, 18), Vector2(-12, 10), Vector2(-16, 0), Vector2(-12, -10)
	])
	add_child(corruption_ring)
	corruption_glyph = Line2D.new()
	corruption_glyph.default_color = Color(1.0, 0.55, 0.62, 0.0)
	corruption_glyph.width = 2.0
	corruption_glyph.points = PackedVector2Array([
		Vector2(-8, -8), Vector2(-2, -2), Vector2(4, -10), Vector2(10, -2)
	])
	add_child(corruption_glyph)

func _apply_visuals() -> void:
	if is_forged:
		core.color = Color(0.92, 0.57, 0.59, 1.0)
		if corruption_ring:
			corruption_ring.color.a = 0.65
		if corruption_glyph:
			corruption_glyph.default_color.a = 0.85
	else:
		core.color = Color(0.67, 0.90, 0.72, 1.0)
		if corruption_ring:
			corruption_ring.color.a = 0.0
		if corruption_glyph:
			corruption_glyph.default_color.a = 0.0
	label.text = "Artifact E%d" % artifact_id
