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

	# Global Background
	var global_bg := Polygon2D.new()
	global_bg.color = Color(0.12, 0.08, 0.08) # Cohesive dark cave background
	global_bg.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(5.0 * ROOM_WIDTH, 0),
		Vector2(5.0 * ROOM_WIDTH, 3.0 * ROOM_HEIGHT), Vector2(0, 3.0 * ROOM_HEIGHT)
	])
	add_child(global_bg)

	# Global Cave Generation (65x45 tiles)
	var g_cells_w = int(5.0 * ROOM_WIDTH / T_SIZE)
	var g_cells_h = int(3.0 * ROOM_HEIGHT / T_SIZE)
	var grid := []
	var shared_seed = int((room_chain[0].get("slot", 0) + 1) * 12345)

	var noise := FastNoiseLite.new()
	noise.seed = shared_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.09
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3

	for x in range(g_cells_w):
		var col := []
		for y in range(g_cells_h):
			var n_val = noise.get_noise_2d(float(x), float(y))
			var is_wall = n_val > -0.1
			
			if x % 13 > 4 and x % 13 < 8:
				if y % 15 < 4 or y % 15 > 13: # Widen the drop shafts slightly
					is_wall = false
					
			if y % 15 > 10 and y % 15 < 14: # Tunneling near floor
				if x % 13 < 4 or x % 13 > 9:
					is_wall = false

			if x == 0 or x == g_cells_w - 1: is_wall = true
			if y == 0 or y == g_cells_h - 1: is_wall = true
			col.append(is_wall)
		grid.append(col)

	for room in room_chain:
		var slot := int(room.get("slot", 0))
		var grid_x := slot % 5
		var grid_y := slot / 5
		
		var room_node := Node2D.new()
		room_node.position = Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
		add_child(room_node)

		var base_color = _color_for_type(str(room.get("type", "traversal")))
		
		# Subtle chunk tint
		var bg_tint := Polygon2D.new()
		bg_tint.color = Color(base_color, 0.05)
		bg_tint.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(ROOM_WIDTH, 0),
			Vector2(ROOM_WIDTH, ROOM_HEIGHT), Vector2(0, ROOM_HEIGHT)
		])
		room_node.add_child(bg_tint)

		var room_w_cells = int(ROOM_WIDTH / T_SIZE)
		var room_h_cells = int(ROOM_HEIGHT / T_SIZE)
		var start_x = grid_x * room_w_cells
		var start_y = grid_y * room_h_cells

		for local_x in range(room_w_cells):
			for local_y in range(room_h_cells):
				if grid[start_x + local_x][start_y + local_y]:
					_add_solid_box(room_node, Color(0.22, 0.18, 0.16), local_x * T_SIZE, local_y * T_SIZE, T_SIZE, T_SIZE)

		if str(room.get("hazard", "")) == "spikes":
			var gap_spikes_x = 80.0 + float(((slot * 7919 + 12345) * 31) % int(ROOM_WIDTH - 200.0))
			var spike_y = ROOM_HEIGHT - T_SIZE - 8.0
			# place on highest lower ground
			for local_y in range(room_h_cells - 2, room_h_cells / 2, -1):
				if grid[start_x + int(gap_spikes_x / T_SIZE)][start_y + local_y]:
					spike_y = local_y * T_SIZE - 8.0
					break
			_add_spikes(room_node, gap_spikes_x, spike_y, 120.0)

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
