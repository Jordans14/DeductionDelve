extends Node2D

const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")
const VISUAL_GOVERNANCE_SCRIPT = preload("res://src/visual/visual_governance.gd")

@onready var core: Polygon2D = $Core
@onready var label: Label = $Label
var item_service: RefCounted = ITEM_SERVICE_SCRIPT.new()
var visual_governance: RefCounted = VISUAL_GOVERNANCE_SCRIPT.new()
var glow: Polygon2D
var glyph: Node2D

var item_id: int = 0
var item_def_id: String = ""
var display_name: String = ""
var owner_peer_id: int = 0
var consumed: bool = false

func configure(data: Dictionary) -> void:
	item_id = int(data.get("item_id", 0))
	item_def_id = str(data.get("item_def_id", ""))
	display_name = str(data.get("display_name", item_def_id))
	owner_peer_id = int(data.get("owner_peer_id", 0))
	consumed = bool(data.get("consumed", false))
	global_position = data.get("world_pos", Vector2.ZERO)
	_apply_visuals()

func sync_state(data: Dictionary) -> void:
	owner_peer_id = int(data.get("owner_peer_id", 0))
	consumed = bool(data.get("consumed", consumed))
	display_name = str(data.get("display_name", display_name))
	item_def_id = str(data.get("item_def_id", item_def_id))
	if owner_peer_id == 0:
		global_position = data.get("world_pos", global_position)
	_apply_visuals()

func set_visual_position(pos: Vector2) -> void:
	global_position = pos

func _apply_visuals() -> void:
	_ensure_visual_overlays()
	visible = not consumed and owner_peer_id == 0
	if not visible:
		return
	var profile: Dictionary = visual_governance.item_visual_profile(item_def_id, str(item_service.get_category(item_def_id)))
	core.color = Color(profile.get("accent", Color(0.93, 0.81, 0.36, 1.0)))
	if glow:
		glow.color = Color(profile.get("glow", core.color)).darkened(0.08)
	if glyph:
		_apply_symbol_points(glyph, str(profile.get("symbol_family", "threshold")), Color(profile.get("outline", core.color)).lightened(0.1))
	z_index = visual_governance.motion_priority_for("artifact")
	if label:
		var category := str(item_service.get_category(item_def_id)).capitalize()
		label.text = "%s: %s" % [category, display_name]
		label.modulate = Color(profile.get("outline", core.color)).lightened(0.1)
		label.modulate.a = float(profile.get("label_alpha", 0.92))

func _ensure_visual_overlays() -> void:
	if glow == null:
		glow = Polygon2D.new()
		glow.polygon = PackedVector2Array([
			Vector2(-12, -18), Vector2(12, -18), Vector2(18, -12), Vector2(18, 12),
			Vector2(12, 18), Vector2(-12, 18), Vector2(-18, 12), Vector2(-18, -12)
		])
		glow.color = Color(1, 1, 1, 0.12)
		add_child(glow)
		move_child(glow, 0)
	if glyph == null:
		glyph = Node2D.new()
		add_child(glyph)

func _apply_symbol_points(host: Node2D, symbol_family: String, color: Color) -> void:
	for child in host.get_children():
		child.free()
	var backing := Polygon2D.new()
	backing.color = Color(color.darkened(0.45), 0.18)
	backing.polygon = visual_governance.symbol_plate_points(symbol_family, 0.68)
	host.add_child(backing)
	var segments: Array = visual_governance.symbol_segments(symbol_family)
	for segment_raw in segments:
		var segment: Array = segment_raw
		if segment.size() < 2:
			continue
		var a: Vector2 = segment[0] * 0.45
		var b: Vector2 = segment[1] * 0.45
		var line := Line2D.new()
		line.width = 2.0
		line.antialiased = true
		line.default_color = color
		line.points = PackedVector2Array([a, b])
		host.add_child(line)
