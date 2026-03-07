extends Node2D

const ROOM_WIDTH := 520.0
const ROOM_HEIGHT := 600.0
const T_SIZE := 40.0

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
		var grid_x := slot % 5
		var grid_y := slot / 5
		
		var room_node := Node2D.new()
		room_node.position = Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
		add_child(room_node)

		var base_color = _color_for_type(str(room.get("type", "traversal")))
		
		var bg := Polygon2D.new()
		bg.color = base_color.darkened(0.5)
		bg.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(ROOM_WIDTH, 0),
			Vector2(ROOM_WIDTH, ROOM_HEIGHT), Vector2(0, ROOM_HEIGHT)
		])
		room_node.add_child(bg)

		var p_seed: int = slot * 7919 + 12345
		var cells_w := int(ROOM_WIDTH / T_SIZE)
		var cells_h := int(ROOM_HEIGHT / T_SIZE)
		
		var grid := []
		for x in range(cells_w):
			var col := []
			for y in range(cells_h):
				var is_wall = (p_seed + x * 13 + y * 71) % 100 < 48
				if grid_x == 0 and x == 0: is_wall = true
				if grid_x == 4 and x == cells_w - 1: is_wall = true
				if grid_y == 0 and y == 0: is_wall = true
				if grid_y == 2 and y == cells_h - 1: is_wall = true
				col.append(is_wall)
			grid.append(col)
			
		for iter in range(4):
			var next_grid := []
			for x in range(cells_w):
				var next_col := []
				for y in range(cells_h):
					var neighbors = 0
					for dx in [-1, 0, 1]:
						for dy in [-1, 0, 1]:
							if dx == 0 and dy == 0: continue
							var nx = x + dx
							var ny = y + dy
							if nx < 0 or ny < 0 or nx >= cells_w or ny >= cells_h:
								neighbors += 1
							elif grid[nx][ny]:
								neighbors += 1
					
					var wall = grid[x][y]
					if neighbors > 4: wall = true
					elif neighbors < 4: wall = false
					
					if x > 4 and x < 8:
						if y < 3 or y > cells_h - 4:
							wall = false
					
					if grid_y == 2 and y == cells_h - 1: wall = true
					if grid_x == 0 and x == 0: wall = true
					if grid_x == 4 and x == cells_w - 1: wall = true
					next_col.append(wall)
				next_grid.append(next_col)
			grid = next_grid

		for x in range(cells_w):
			for y in range(cells_h):
				if grid[x][y]:
					_add_solid_box(room_node, base_color.darkened(0.2), x * T_SIZE, y * T_SIZE, T_SIZE, T_SIZE)

		if str(room.get("hazard", "")) == "spikes":
			var gap_spikes_x = 80.0 + float((p_seed * 31) % int(ROOM_WIDTH - 200.0))
			if grid_y < 2:
				_add_spikes(room_node, gap_spikes_x, ROOM_HEIGHT - 32.0, 120.0)
			else:
				_add_spikes(room_node, gap_spikes_x, ROOM_HEIGHT - T_SIZE - 8.0, 120.0)

		var label := Label.new()
		label.position = Vector2(14, 14)
		label.text = "%d:%s [%s] (%d,%d)" % [slot, str(room.get("id", "?")), str(room.get("hazard", "none")), grid_x, grid_y]
		label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 0.8))
		label.add_theme_font_size_override("font_size", 16)
		room_node.add_child(label)

		var indicator := Label.new()
		indicator.position = Vector2(ROOM_WIDTH - 48.0, 28.0)
		indicator.text = "!"
		indicator.visible = false
		indicator.modulate = Color(1.0, 0.18, 0.20, 1.0)
		indicator.add_theme_font_size_override("font_size", 32)
		room_node.add_child(indicator)
		indicator_by_slot[slot] = indicator
		indicator_time_left_by_slot[slot] = 0.0

func _add_solid_box(parent: Node2D, color: Color, x: float, y: float, w: float, h: float) -> void:
	var body = StaticBody2D.new()
	body.position = Vector2(x, y)
	var poly = Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)
	])
	body.add_child(poly)
	
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
