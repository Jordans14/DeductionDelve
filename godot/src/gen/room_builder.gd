extends Node2D

const ROOM_WIDTH := 520.0
const ROOM_HEIGHT := 320.0

var indicator_by_slot: Dictionary = {}
var indicator_time_left_by_slot: Dictionary = {}

func _ready() -> void:
	set_process(true)

func build_from_chain(room_chain: Array) -> void:
	set_process(true)
	for child in get_children():
		child.queue_free()
	indicator_by_slot.clear()
	indicator_time_left_by_slot.clear()

	for room in room_chain:
		var slot := int(room.get("slot", 0))
		var room_node := Node2D.new()
		room_node.position = Vector2(float(slot) * ROOM_WIDTH, 0.0)
		add_child(room_node)

		var base_color = _color_for_type(str(room.get("type", "traversal")))
		
		# Outline/Shadow
		var outline := Polygon2D.new()
		outline.color = Color(0.1, 0.1, 0.1, 0.6)
		outline.polygon = PackedVector2Array([
			Vector2(-4, -ROOM_HEIGHT - 4),
			Vector2(ROOM_WIDTH - 4.0, -ROOM_HEIGHT - 4),
			Vector2(ROOM_WIDTH - 4.0, 4),
			Vector2(-4, 4)
		])
		room_node.add_child(outline)

		# Main panel
		var panel := Polygon2D.new()
		panel.color = base_color
		var panel_poly = PackedVector2Array([
			Vector2(0, -ROOM_HEIGHT),
			Vector2(ROOM_WIDTH - 8.0, -ROOM_HEIGHT),
			Vector2(ROOM_WIDTH - 8.0, 0),
			Vector2(0, 0)
		])
		panel.polygon = panel_poly
		room_node.add_child(panel)
		
		# Grid overlay
		var grid := Line2D.new()
		grid.default_color = Color(1.0, 1.0, 1.0, 0.15)
		grid.width = 2.0
		for i in range(1, int(ROOM_WIDTH / 40)):
			grid.add_point(Vector2(i * 40.0, -ROOM_HEIGHT))
			grid.add_point(Vector2(i * 40.0, 0))
			grid.add_point(Vector2((i + 1) * 40.0, -ROOM_HEIGHT))
		room_node.add_child(grid)

		var label := Label.new()
		label.position = Vector2(14, -ROOM_HEIGHT + 24)
		label.text = "%d:%s [%s]" % [slot, str(room.get("id", "?")), str(room.get("hazard", "none"))]
		label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15, 0.8))
		label.add_theme_font_size_override("font_size", 16)
		room_node.add_child(label)

		var indicator := Label.new()
		indicator.position = Vector2(ROOM_WIDTH - 48.0, -ROOM_HEIGHT + 28.0)
		indicator.text = "!"
		indicator.visible = false
		indicator.modulate = Color(1.0, 0.18, 0.20, 1.0)
		indicator.add_theme_font_size_override("font_size", 32)
		room_node.add_child(indicator)
		indicator_by_slot[slot] = indicator
		indicator_time_left_by_slot[slot] = 0.0

func _process(delta: float) -> void:
	for slot in indicator_time_left_by_slot.keys():
		var left := float(indicator_time_left_by_slot[slot]) - delta
		indicator_time_left_by_slot[slot] = maxf(left, 0.0)
		var indicator: Label = indicator_by_slot.get(slot, null)
		if indicator:
			indicator.visible = left > 0.0

func flash_hazard_indicator(room_slot: int, duration_sec: float = 0.3) -> void:
	if not indicator_time_left_by_slot.has(room_slot):
		return
	indicator_time_left_by_slot[room_slot] = maxf(float(indicator_time_left_by_slot[room_slot]), duration_sec)
	var indicator: Label = indicator_by_slot.get(room_slot, null)
	if indicator:
		indicator.visible = true

func _color_for_type(room_type: String) -> Color:
	match room_type:
		"hazard":
			return Color(0.98, 0.73, 0.73, 1.0)
		"encounter":
			return Color(0.86, 0.83, 0.95, 1.0)
		"evidence":
			return Color(0.80, 0.95, 0.84, 1.0)
		"recovery":
			return Color(0.84, 0.91, 0.98, 1.0)
		_:
			return Color(0.95, 0.91, 0.78, 1.0)
