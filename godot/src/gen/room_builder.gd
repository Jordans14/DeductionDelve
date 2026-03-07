extends Node2D

const ROOM_WIDTH := 520.0
const ROOM_HEIGHT := 800.0

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
		
		# Background Panel
		var bg := Polygon2D.new()
		bg.color = base_color.darkened(0.5)
		bg.polygon = PackedVector2Array([
			Vector2(0, -ROOM_HEIGHT), Vector2(ROOM_WIDTH, -ROOM_HEIGHT),
			Vector2(ROOM_WIDTH, 0), Vector2(0, 0)
		])
		room_node.add_child(bg)

		# Add solid floor
		_add_solid_box(room_node, base_color, 0, -16, ROOM_WIDTH, 16)
		
		# Procedural Cave Generation
		var p_seed: int = slot * 7919 + 12345
		
		# Generate jagged cave walls scaling all the way down
		for i in range(12):
			var wy = -int(ROOM_HEIGHT) + i * 80.0
			var wxl = 20.0 + float((p_seed + i * 3) % 60)
			_add_solid_box(room_node, base_color.darkened(0.3), 0, wy, wxl, 85)
			
			var wxr = float(ROOM_WIDTH) - 20.0 - float((p_seed + i * 7) % 60)
			var w_w = float(ROOM_WIDTH) - wxr
			_add_solid_box(room_node, base_color.darkened(0.3), wxr, wy, w_w, 85)

		# Generate floors with drop-through gaps every 150px
		for y_level in range(int(-ROOM_HEIGHT + 150), -50, 150):
			var gap_start = 80.0 + float((p_seed + y_level * 11) % int(ROOM_WIDTH - 260.0))
			var gap_width = 80.0 + float((p_seed + y_level * 17) % 100)
			
			if (p_seed + y_level) % 10 > 2: # 80% chance for a floor layer
				_add_solid_box(room_node, base_color.lightened(0.1), 0, float(y_level), gap_start, 24)
				_add_solid_box(room_node, base_color.lightened(0.1), gap_start + gap_width, float(y_level), float(ROOM_WIDTH) - (gap_start + gap_width), 24)
				
				# Occasional floating isolated block
				if (p_seed + y_level) % 10 > 7:
					var isolated_x = gap_start + gap_width / 2.0 - 20.0
					_add_solid_box(room_node, base_color.lightened(0.2), isolated_x, float(y_level) - 50.0, 40, 20)

		# Lethal Hazards (Spikes)
		if str(room.get("hazard", "")) == "spikes":
			var gap_spikes_x = 80.0 + float((p_seed * 31) % int(ROOM_WIDTH - 200.0))
			_add_spikes(room_node, gap_spikes_x, -24, 120)

		var label := Label.new()
		label.position = Vector2(14, -ROOM_HEIGHT + 24)
		label.text = "%d:%s [%s]" % [slot, str(room.get("id", "?")), str(room.get("hazard", "none"))]
		label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 0.8))
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

	# Add Map Boundaries
	_add_solid_box(self, Color(0.2, 0.2, 0.2), -40, -1500, 40, 2000)
	_add_solid_box(self, Color(0.2, 0.2, 0.2), float(room_chain.size()) * ROOM_WIDTH, -1500, 40, 2000)

func _add_solid_box(parent: Node2D, color: Color, x: float, y: float, w: float, h: float) -> void:
	var body = StaticBody2D.new()
	body.position = Vector2(x, y)
	var poly = Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)
	])
	body.add_child(poly)
	
	var highlight = Line2D.new()
	highlight.add_point(Vector2(0, 0))
	highlight.add_point(Vector2(w, 0))
	highlight.width = 4.0
	highlight.default_color = color.lightened(0.3)
	body.add_child(highlight)
	
	var col = CollisionPolygon2D.new()
	col.polygon = poly.polygon
	body.add_child(col)
	parent.add_child(body)

func _add_spikes(parent: Node2D, x: float, y: float, w: float) -> void:
	var area = Area2D.new()
	area.position = Vector2(x, y)
	area.add_to_group("hazards")
	
	var poly = Polygon2D.new()
	poly.color = Color(0.8, 0.1, 0.1)
	var points := PackedVector2Array()
	points.append(Vector2(0, 8))
	var spikes_count = int(w / 10.0)
	for i in range(spikes_count):
		points.append(Vector2(float(i) * 10.0 + 5.0, 0))
		points.append(Vector2(float(i + 1) * 10.0, 8))
	poly.polygon = points
	area.add_child(poly)
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(w, 8)
	col.shape = rect
	col.position = Vector2(w / 2.0, 4.0)
	area.add_child(col)
	parent.add_child(area)

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
