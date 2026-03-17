extends Node2D

const VISUAL_GOVERNANCE_SCRIPT = preload("res://src/visual/visual_governance.gd")

@onready var core: Polygon2D = $Core
@onready var label: Label = $Label
var corruption_ring: Polygon2D
var corruption_glyph: Line2D
var burden_beacon: PointLight2D
var burden_frame: Line2D
var burden_cradle: Polygon2D
var visual_governance: RefCounted = VISUAL_GOVERNANCE_SCRIPT.new()

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
		Vector2(-6, -18), Vector2(6, -18), Vector2(14, -12), Vector2(18, -2),
		Vector2(16, 10), Vector2(6, 18), Vector2(-6, 18), Vector2(-16, 10),
		Vector2(-18, -2), Vector2(-14, -12)
	])
	add_child(corruption_ring)
	corruption_glyph = Line2D.new()
	corruption_glyph.default_color = Color(1.0, 0.55, 0.62, 0.0)
	corruption_glyph.width = 2.0
	corruption_glyph.antialiased = true
	corruption_glyph.points = PackedVector2Array([
		Vector2(-10, -6), Vector2(-3, -10), Vector2(2, -3), Vector2(8, -8), Vector2(12, 0), Vector2(6, 8)
	])
	add_child(corruption_glyph)
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(0, 0, 0, 1)])
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 128
	tex.height = 128
	burden_beacon = PointLight2D.new()
	burden_beacon.texture = tex
	burden_beacon.color = Color(0.96, 0.72, 0.28, 0.0)
	burden_beacon.energy = 0.0
	burden_beacon.scale = Vector2(1.2, 1.2)
	add_child(burden_beacon)
	burden_frame = Line2D.new()
	burden_frame.width = 2.0
	burden_frame.antialiased = true
	add_child(burden_frame)
	burden_cradle = Polygon2D.new()
	burden_cradle.color = Color(0.96, 0.72, 0.28, 0.0)
	burden_cradle.polygon = PackedVector2Array([
		Vector2(-18, 8), Vector2(-10, 2), Vector2(10, 2), Vector2(18, 8), Vector2(10, 16), Vector2(-10, 16)
	])
	add_child(burden_cradle)

func _apply_visuals() -> void:
	var carried := owner_peer_id != 0
	var profile: Dictionary = visual_governance.evidence_visual_profile(is_forged, carried)
	core.color = Color(profile.get("accent", Color(0.67, 0.90, 0.72, 1.0)))
	if corruption_ring:
		corruption_ring.color.a = float(profile.get("ring_alpha", 0.0))
	if corruption_glyph:
		corruption_glyph.default_color.a = float(profile.get("glyph_alpha", 0.0))
	if burden_beacon:
		burden_beacon.color = Color(profile.get("accent", core.color))
		burden_beacon.energy = 0.42 if carried else 0.0
		burden_beacon.scale = Vector2.ONE * float(profile.get("beacon_scale", 1.0))
	if burden_frame:
		burden_frame.default_color = Color(profile.get("accent", core.color)).lightened(0.1)
		burden_frame.width = float(profile.get("frame_width", 2.0))
		burden_frame.visible = carried
		burden_frame.points = PackedVector2Array([
			Vector2(-18, -4), Vector2(-14, -16), Vector2(-4, -20), Vector2(4, -20), Vector2(14, -16), Vector2(18, -4)
		]) if carried else PackedVector2Array()
	if burden_cradle:
		burden_cradle.color = Color(profile.get("accent", core.color))
		burden_cradle.color.a = float(profile.get("cradle_alpha", 0.0))
		burden_cradle.visible = carried
	z_index = visual_governance.motion_priority_for("artifact")
	label.text = "Artifact E%d" % artifact_id
	label.modulate = Color(profile.get("accent", core.color)).lightened(0.08)
