extends Node2D

# ============================================================
# WORLD CONSTANTS
# ============================================================
const COLS := 5
const ROWS := 3
const ROOM_WIDTH  : float = 1024.0
const ROOM_HEIGHT : float = 768.0
const T_SIZE      : float = 32.0   # smaller tile = more detail

# Derived (computed at runtime because GDScript can't eval const expressions)
var GW : int     # total tiles wide  (160)
var GH : int     # total tiles tall  (72)
var CHUNK_W : int # tiles per room wide (32)
var CHUNK_H : int # tiles per room tall (24)

var indicator_by_slot      : Dictionary = {}
var indicator_time_left_by_slot : Dictionary = {}
var spawn_points : Array[Vector2] = []
var biome_noise  : FastNoiseLite  # organic blob biomes, not column slices

func _ready() -> void:
	set_process(true)

# ============================================================
# MAIN ENTRY POINT
# ============================================================
func build_from_chain(room_chain: Array) -> void:
	set_process(true)
	for child in get_children():
		child.queue_free()
	indicator_by_slot.clear()
	indicator_time_left_by_slot.clear()
	spawn_points.clear()

	CHUNK_W = int(ROOM_WIDTH  / T_SIZE)   # 32
	CHUNK_H = int(ROOM_HEIGHT / T_SIZE)   # 24
	GW      = COLS * CHUNK_W              # 160
	GH      = ROWS * CHUNK_H             # 72

	var run_seed : int = int(room_chain[0].get("slot", 0) + 1) * 31337 if not room_chain.is_empty() else 99991

	# Biome noise — very low frequency so blobs span multiple chunks organically
	biome_noise = FastNoiseLite.new()
	biome_noise.seed = run_seed + 555
	biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	biome_noise.frequency = 0.012
	biome_noise.fractal_octaves = 2

	# -- Stage 1: Build global tile grid via domain-warped noise
	var grid := _build_noise_grid(run_seed)

	# -- Stage 2: Cellular automata — 2 passes for smooth organic walls
	grid = _smooth_ca(grid, 2)

	# -- Stage 3: Spelunky biased-walk carves guaranteed critical path
	_carve_critical_path(grid, run_seed)

	# -- Stage 4: Carve guaranteed connectors at every chunk boundary
	_carve_chunk_connectors(grid, run_seed)

	# -- Stage 5: Carve giant open chambers at each chunk center
	_carve_chambers(grid, run_seed)

	# -- Stage 6: Re-etch hard borders (can't be overridden)
	_enforce_borders(grid)

	# -- Stage 7: Collect spawn points from top row of grid
	_collect_spawn_points(grid)

	# -- Stage 8: Draw global dark background
	_draw_background()

	# -- Stage 9: Render all room chunks
	for room in room_chain:
		_render_room(room, grid, run_seed)

	# -- Stage 10: Add floating platforms inside large open areas
	_place_platforms(grid, run_seed)

# ============================================================
# STAGE 1: DOMAIN-WARPED NOISE GRID
# ============================================================
func _build_noise_grid(run_seed: int) -> Array:
	# Primary cave shape — low frequency for large caverns
	var cave_noise := FastNoiseLite.new()
	cave_noise.seed = run_seed
	cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	cave_noise.frequency = 0.045
	cave_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	cave_noise.fractal_octaves = 4
	cave_noise.fractal_lacunarity = 2.0
	cave_noise.fractal_gain = 0.5
	# Domain warp makes caves twist and feel organic
	cave_noise.domain_warp_enabled = true
	cave_noise.domain_warp_amplitude = 45.0
	cave_noise.domain_warp_frequency = 0.03

	# Secondary detail noise — high frequency, low amplitude
	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = run_seed + 1337
	detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	detail_noise.frequency = 0.12
	detail_noise.fractal_octaves = 2

	var grid : Array = []
	for x in range(GW):
		var col := []
		for y in range(GH):
			var fx := float(x)
			var fy := float(y)
			var n1 : float = cave_noise.get_noise_2d(fx, fy)
			var n2 : float = detail_noise.get_noise_2d(fx, fy) * 0.2

			# Depth bias: open up more as we go deeper
			var depth_bias : float = float(y) / float(GH) * 0.18

			# Wall density ~45% at surface, ~35% at bottom → very traversable
			var threshold : float = -0.08 + depth_bias
			var is_wall : bool = (n1 + n2) > threshold
			col.append(is_wall)
		grid.append(col)
	return grid

# ============================================================
# STAGE 2: CELLULAR AUTOMATA SMOOTHING
# ============================================================
func _smooth_ca(grid: Array, passes: int) -> Array:
	for _p in range(passes):
		var next : Array = []
		for x in range(GW):
			var col := []
			for y in range(GH):
				var walls := 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0:
							continue
						var nx := x + dx
						var ny := y + dy
						if nx < 0 or ny < 0 or nx >= GW or ny >= GH:
							walls += 1
						elif grid[nx][ny]:
							walls += 1
				# Standard B678/S345678 cave rule
				if grid[x][y]:
					col.append(walls >= 3)
				else:
					col.append(walls >= 5)
			next.append(col)
		grid = next
	return grid

# ============================================================
# STAGE 3: SPELUNKY BIASED-WALK CRITICAL PATH
# ============================================================
func _carve_critical_path(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + 7777

	# Begin at top-center
	var cx : int = GW / 2
	var cy : int = 3
	var target_y : int = GH - 4

	# The walk is biased: 55% down, 20% sideways, 25% small up-back
	while cy < target_y:
		# Carve a 4-tile radius circle at current walker position
		_carve_circle(grid, cx, cy, 4)

		var r := rng.randf()
		if r < 0.55:
			cy += 1
		elif r < 0.65:
			cy = max(cy - 1, 2)
		elif r < 0.80:
			cx = clamp(cx + rng.randi_range(1, 3), 2, GW - 3)
		else:
			cx = clamp(cx - rng.randi_range(1, 3), 2, GW - 3)

	# Also carve horizontal branches off the critical spine
	for _branch in range(8):
		var bx : int = rng.randi_range(4, GW - 5)
		var by : int = rng.randi_range(4, GH - 5)
		var blen : int = rng.randi_range(6, 18)
		var bdir : int = 1 if rng.randb() else -1
		for b in range(blen):
			_carve_circle(grid, bx + b * bdir, by, 2)

func _carve_circle(grid: Array, cx: int, cy: int, radius: int) -> void:
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				var nx := cx + dx
				var ny := cy + dy
				if nx > 0 and ny > 0 and nx < GW - 1 and ny < GH - 1:
					grid[nx][ny] = false

# ============================================================
# STAGE 4: GUARANTEED CHUNK BOUNDARY CONNECTORS
# Like Spelunky — every chunk is reachable from its neighbors
# ============================================================
func _carve_chunk_connectors(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + 99

	# Vertical passages (top/bottom of each chunk row boundary)
	for col in range(COLS):
		for row in range(ROWS - 1):
			# Random x offset within this chunk column
			var ox : int = rng.randi_range(CHUNK_W / 4, 3 * CHUNK_W / 4)
			var tile_x : int = col * CHUNK_W + ox
			var seam_y : int = (row + 1) * CHUNK_H
			# Carve 5-wide passage through the seam
			for py in range(seam_y - 3, seam_y + 4):
				for px in range(tile_x - 2, tile_x + 3):
					if px > 0 and py > 0 and px < GW - 1 and py < GH - 1:
						grid[px][py] = false

	# Horizontal passages (left/right of each chunk column boundary)
	for col in range(COLS - 1):
		for row in range(ROWS):
			var oy : int = rng.randi_range(CHUNK_H / 4, 3 * CHUNK_H / 4)
			var seam_x : int = (col + 1) * CHUNK_W
			var tile_y : int = row * CHUNK_H + oy
			# Carve 5-tall passage through the seam
			for px in range(seam_x - 3, seam_x + 4):
				for py in range(tile_y - 2, tile_y + 3):
					if px > 0 and py > 0 and px < GW - 1 and py < GH - 1:
						grid[px][py] = false

# ============================================================
# STAGE 5: OPEN CHAMBERS — one big open area per chunk
# ============================================================
func _carve_chambers(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + 54321
	for col in range(COLS):
		for row in range(ROWS):
			# Carve a large elliptical chamber in each chunk
			var cx : int = col * CHUNK_W + rng.randi_range(CHUNK_W / 3, 2 * CHUNK_W / 3)
			var cy : int = row * CHUNK_H + rng.randi_range(CHUNK_H / 3, 2 * CHUNK_H / 3)
			var rx : int = rng.randi_range(5, CHUNK_W / 3)
			var ry : int = rng.randi_range(3, CHUNK_H / 3)
			for dx in range(-rx, rx + 1):
				for dy in range(-ry, ry + 1):
					# Ellipse equation
					if float(dx * dx) / float(rx * rx) + float(dy * dy) / float(ry * ry) <= 1.0:
						var nx := cx + dx
						var ny := cy + dy
						if nx > 0 and ny > 0 and nx < GW - 1 and ny < GH - 1:
							grid[nx][ny] = false

# ============================================================
# STAGE 6: HARD BORDERS — always solid
# ============================================================
func _enforce_borders(grid: Array) -> void:
	for x in range(GW):
		grid[x][0] = true
		grid[x][GH - 1] = true
	for y in range(GH):
		grid[0][y] = true
		grid[GW - 1][y] = true

# ============================================================
# STAGE 7: COLLECT SPAWN POINTS
# Find the first open cell from top in each column's safe zone
# ============================================================
func _collect_spawn_points(grid: Array) -> void:
	for col in range(COLS):
		# Try from the center of each chunk column
		var tile_x : int = col * CHUNK_W + CHUNK_W / 2
		for tile_y in range(1, GH - 1):
			if not grid[tile_x][tile_y] and not grid[tile_x][tile_y + 1]:
				var wx := global_position.x + float(tile_x) * T_SIZE + T_SIZE * 0.5
				var wy := global_position.y + float(tile_y) * T_SIZE + T_SIZE
				spawn_points.append(Vector2(wx, wy))
				break
	# Fallback if somehow empty
	if spawn_points.is_empty():
		spawn_points.append(global_position + Vector2(ROOM_WIDTH * 0.5, 120.0))

# ============================================================
# STAGE 8: BACKGROUND
# ============================================================
func _draw_background() -> void:
	var bg := Polygon2D.new()
	bg.color = Color(0.07, 0.05, 0.06)
	bg.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(float(COLS) * ROOM_WIDTH, 0),
		Vector2(float(COLS) * ROOM_WIDTH, float(ROWS) * ROOM_HEIGHT),
		Vector2(0, float(ROWS) * ROOM_HEIGHT)
	])
	add_child(bg)

# ============================================================
# STAGE 9: RENDER EACH ROOM CHUNK
# ============================================================
func _render_room(room: Dictionary, grid: Array, run_seed: int) -> void:
	var slot   : int = int(room.get("slot", 0))
	var grid_x : int = slot % COLS
	var grid_y : int = slot / COLS

	var room_node := Node2D.new()
	room_node.position = Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	add_child(room_node)

	var sx : int = grid_x * CHUNK_W
	var sy : int = grid_y * CHUNK_H

	# Subtle ambient tint — sampled at chunk centre so tint is biome-appropriate
	var cx_tile : int = sx + CHUNK_W / 2
	var cy_tile : int = sy + CHUNK_H / 2
	var biome_col := _biome_ambient_at(cx_tile, cy_tile)
	var tint := Polygon2D.new()
	tint.color = Color(biome_col.r, biome_col.g, biome_col.b, 0.05)
	tint.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(ROOM_WIDTH, 0),
		Vector2(ROOM_WIDTH, ROOM_HEIGHT), Vector2(0, ROOM_HEIGHT)
	])
	room_node.add_child(tint)

	# Wall tiles — each tile samples biome noise individually for organic regions
	for lx in range(CHUNK_W):
		for ly in range(CHUNK_H):
			if grid[sx + lx][sy + ly]:
				var wall_col := _wall_color_at(sx + lx, sy + ly)
				_add_solid_box(room_node, wall_col, float(lx) * T_SIZE, float(ly) * T_SIZE, T_SIZE, T_SIZE)

	# Hazard spikes placed on nearest open cave floor
	if str(room.get("hazard", "")) == "spikes":
		var rng := RandomNumberGenerator.new()
		rng.seed = slot * 7919 + run_seed
		var spike_x_tile : int = CHUNK_W / 4 + rng.randi() % (CHUNK_W / 2)
		var spike_y_px   : float = ROOM_HEIGHT - T_SIZE - 8.0
		for ly in range(CHUNK_H - 2, CHUNK_H / 2, -1):
			if grid[sx + spike_x_tile][sy + ly]:
				spike_y_px = float(ly) * T_SIZE - 8.0
				break
		_add_spikes(room_node, float(spike_x_tile) * T_SIZE - 60.0, spike_y_px, 120.0)

	# Room type indicator label (small, subtle)
	var label := Label.new()
	label.position = Vector2(10, 10)
	label.text = "  %s" % str(room.get("type", "?"))[0].to_upper()
	label.add_theme_color_override("font_color", Color(biome_col, 0.5))
	label.add_theme_font_size_override("font_size", 12)
	room_node.add_child(label)

	var indicator := Label.new()
	indicator.position = Vector2(ROOM_WIDTH - 48.0, 24.0)
	indicator.text = "!"
	indicator.visible = false
	indicator.modulate = Color(1.0, 0.18, 0.2, 1.0)
	indicator.add_theme_font_size_override("font_size", 32)
	room_node.add_child(indicator)
	indicator_by_slot[slot]           = indicator
	indicator_time_left_by_slot[slot] = 0.0

# ============================================================
# STAGE 10: FLOATING PLATFORMS (Spelunky feel)
# Scan vertical columns, place ledge where drop > 8 tiles
# ============================================================
func _place_platforms(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + 8888
	# Walk in steps of 3 tiles across X to find candidate columns
	for x in range(2, GW - 2, 3):
		var open_start : int = -1
		for y in range(1, GH - 1):
			if not grid[x][y]:
				if open_start < 0:
					open_start = y
			else:
				if open_start >= 0:
					var drop : int = y - open_start
					# Only place platform in tall vertical drops
					if drop >= 9:
						var plat_y : int = open_start + drop / 2
						var plat_len : int = 3 + rng.randi() % 5   # 3–7 tiles wide
						var plat_off : int = rng.randi_range(-2, 0)
						# Render platform as a thin StaticBody row
						for px in range(plat_len):
							var tx : int = x + px + plat_off
							if tx > 0 and tx < GW - 1:
								# Find which chunk this tile is in
								var chunk_col : int = tx / CHUNK_W
								var chunk_row : int = plat_y / CHUNK_H
								# Get the room's Node2D we already rendered
								var room_node := _room_node_for_chunk(chunk_col, chunk_row)
								if room_node:
									var local_x : float = float(tx - chunk_col * CHUNK_W) * T_SIZE
									var local_y : float = float(plat_y - chunk_row * CHUNK_H) * T_SIZE
									_add_platform_tile(room_node, local_x, local_y)
				open_start = -1

func _room_node_for_chunk(grid_x: int, grid_y: int) -> Node2D:
	var slot : int = grid_y * COLS + grid_x
	# Room nodes were added in slot order as children after the global bg
	var target_pos := Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	for child in get_children():
		if child is Node2D and child.position == target_pos and child.get_child_count() > 0:
			return child as Node2D
	return null

func _add_platform_tile(parent: Node2D, x: float, y: float) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(x, y)
	var poly := Polygon2D.new()
	poly.color = Color(0.45, 0.35, 0.25)  # lighter brown — visually distinct
	poly.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(T_SIZE, 0),
		Vector2(T_SIZE, T_SIZE * 0.35), Vector2(0, T_SIZE * 0.35)
	])
	body.add_child(poly)
	var col := CollisionPolygon2D.new()
	col.polygon = poly.polygon
	body.add_child(col)
	parent.add_child(body)

# ============================================================
# PUBLIC API
# ============================================================
func get_spawn_point(index: int) -> Vector2:
	if spawn_points.is_empty():
		return global_position + Vector2(ROOM_WIDTH * 0.5, 120.0)
	return spawn_points[index % spawn_points.size()]

func flash_hazard_indicator(room_slot: int, duration_sec: float = 0.3) -> void:
	if not indicator_time_left_by_slot.has(room_slot):
		return
	indicator_time_left_by_slot[room_slot] = maxf(float(indicator_time_left_by_slot[room_slot]), duration_sec)
	var ind : Label = indicator_by_slot.get(room_slot, null)
	if ind:
		ind.visible = true

func _process(delta: float) -> void:
	for slot in indicator_time_left_by_slot.keys():
		var left : float = float(indicator_time_left_by_slot[slot]) - delta
		indicator_time_left_by_slot[slot] = maxf(left, 0.0)
		var ind : Label = indicator_by_slot.get(slot, null)
		if ind:
			ind.visible = left > 0.0

# ============================================================
# HELPERS
# ============================================================
func _add_solid_box(parent: Node2D, color: Color, x: float, y: float, w: float, h: float) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(x, y)
	var poly := Polygon2D.new()
	poly.color = color
	poly.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)
	])
	body.add_child(poly)
	var col := CollisionPolygon2D.new()
	col.polygon = poly.polygon
	body.add_child(col)
	parent.add_child(body)

func _add_spikes(parent: Node2D, x: float, y: float, w: float) -> void:
	var area := Area2D.new()
	area.position = Vector2(x, y)
	area.add_to_group("hazards")
	var poly := Polygon2D.new()
	poly.color = Color(0.75, 0.1, 0.1)
	var pts := PackedVector2Array()
	pts.append(Vector2(0, 8))
	var n_spikes : int = int(w / 10.0)
	for i in range(n_spikes):
		pts.append(Vector2(float(i) * 10.0 + 5.0, 0.0))
		pts.append(Vector2(float(i + 1) * 10.0, 8.0))
	poly.polygon = pts
	area.add_child(poly)
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, 8.0)
	col.shape = rect
	col.position = Vector2(w * 0.5, 4.0)
	area.add_child(col)
	parent.add_child(area)

# ------ Noise-based biome helpers (organic blobs, not columns) ----------
#
# biome_noise maps the world to 5 distinct cave biomes whose regions spread
# organically in all directions — no vertical slices.

func _biome_ambient_at(tile_x: int, tile_y: int) -> Color:
	# Used for the subtle ambient tint of each chunk's background
	var n : float = biome_noise.get_noise_2d(float(tile_x), float(tile_y))
	if n < -0.55:
		return Color(0.40, 0.55, 0.40)   # Mossy grotto — green
	elif n < -0.15:
		return Color(0.40, 0.48, 0.65)   # Crystal hall — steel blue
	elif n < 0.15:
		return Color(0.55, 0.48, 0.38)   # Stone depths — warm ochre
	elif n < 0.55:
		return Color(0.62, 0.35, 0.35)   # Blood cave — dusty crimson
	else:
		return Color(0.65, 0.60, 0.32)   # Ancient ruins — temple gold

func _wall_color_at(tile_x: int, tile_y: int) -> Color:
	# Each wall tile independently samples the biome map → organic region edges
	var n : float = biome_noise.get_noise_2d(float(tile_x), float(tile_y))
	var depth_darken : float = float(tile_y) / float(GH) * 0.10
	if n < -0.55:
		return Color(0.18, 0.25, 0.18).darkened(depth_darken)   # Mossy
	elif n < -0.15:
		return Color(0.16, 0.21, 0.32).darkened(depth_darken)   # Crystal
	elif n < 0.15:
		return Color(0.24, 0.19, 0.16).darkened(depth_darken)   # Stone
	elif n < 0.55:
		return Color(0.27, 0.15, 0.16).darkened(depth_darken)   # Blood
	else:
		return Color(0.29, 0.24, 0.12).darkened(depth_darken)   # Temple
