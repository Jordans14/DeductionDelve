extends Node2D

# ============================================================
# WORLD CONSTANTS
# ============================================================
const COLS := 8
const ROWS := 4
const ROOM_WIDTH  : float = 1024.0
const ROOM_HEIGHT : float = 768.0
const T_SIZE      : float = 32.0

var GW : int       # global tile width  (160)
var GH : int       # global tile height  (72)
var CHUNK_W : int  # tiles per room wide  (32)
var CHUNK_H : int  # tiles per room tall  (24)

var indicator_by_slot      : Dictionary = {}
var indicator_time_left_by_slot : Dictionary = {}
var spawn_points : Array[Vector2] = []
var biome_noise  : FastNoiseLite

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

	if room_chain.is_empty():
		push_warning("build_from_chain called with empty room_chain")
		spawn_points.append(global_position + Vector2(512, 120))
		return

	CHUNK_W = int(ROOM_WIDTH  / T_SIZE)
	CHUNK_H = int(ROOM_HEIGHT / T_SIZE)
	GW      = COLS * CHUNK_W
	GH      = ROWS * CHUNK_H

	var run_seed : int = int(room_chain[0].get("slot", 0) + 1) * 31337 if not room_chain.is_empty() else 99991

	# Organic area-based biome noise — very low frequency so regions are large blobs
	biome_noise = FastNoiseLite.new()
	biome_noise.seed = run_seed + 555
	biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	biome_noise.frequency = 0.012
	biome_noise.fractal_octaves = 2

	# ── Stage 1: Domain-warped noise grid ──────────────────
	var grid := _build_noise_grid(run_seed)

	# ── Stage 2: Smooth with cellular automata ─────────────
	grid = _smooth_ca(grid, 2)

	# ── Stage 3: Spelunky biased critical path ─────────────
	_carve_critical_path(grid, run_seed)

	# ── Stage 4: Guaranteed chunk-boundary connectors ──────
	_carve_chunk_connectors(grid, run_seed)

	# ── Stage 5: Open chambers per chunk ──────────────────
	_carve_chambers(grid, run_seed)

	# ── Stage 6: Settlement pockets — flat-floored rooms ───
	_carve_settlement_pockets(grid, run_seed)

	# ── Stage 6b: Remove chokepoints — any passage < 3 tiles wide ──
	_widen_narrow_passages(grid)

	# ── Stage 7: Enforce hard borders + global floor ───────
	_enforce_borders(grid)

	# ── Stage 8: Collect spawn points ─────────────────────
	_collect_spawn_points(grid)

	# ── Stage 9: Draw atmosphere background ───────────────
	_draw_background()

	# ── Stage 10: Render GLOBAL walls with horizontal merging ──
	_render_all_walls(grid)

	# ── Stage 11: Render specific room decorations ────────
	for room in room_chain:
		_render_room_decorations(room, grid, run_seed)

	# ── Stage 12: Floating platforms in vertical drops ─────
	_place_platforms(grid, run_seed)

# ============================================================
# STAGE 1: DOMAIN-WARPED LAYERED NOISE
# ============================================================
func _build_noise_grid(run_seed: int) -> Array:
	var cave_noise := FastNoiseLite.new()
	cave_noise.seed = run_seed
	cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	cave_noise.frequency = 0.045
	cave_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	cave_noise.fractal_octaves = 4
	cave_noise.fractal_lacunarity = 2.0
	cave_noise.fractal_gain = 0.5
	cave_noise.domain_warp_enabled = true
	cave_noise.domain_warp_amplitude = 45.0
	cave_noise.domain_warp_frequency = 0.03

	var detail := FastNoiseLite.new()
	detail.seed = run_seed + 1337
	detail.noise_type = FastNoiseLite.TYPE_SIMPLEX
	detail.frequency = 0.12
	detail.fractal_octaves = 2

	var grid := []
	for x in range(GW):
		var col := []
		for y in range(GH):
			var n1 : float = cave_noise.get_noise_2d(float(x), float(y))
			var n2 : float = detail.get_noise_2d(float(x), float(y)) * 0.2
			var depth_bias : float = float(y) / float(GH) * 0.18
			var is_wall : bool = (n1 + n2) > (-0.08 + depth_bias)
			col.append(is_wall)
		grid.append(col)
	return grid

# ============================================================
# STAGE 2: CELLULAR AUTOMATA SMOOTHING
# ============================================================
func _smooth_ca(grid: Array, passes: int) -> Array:
	for _p in range(passes):
		var next := []
		for x in range(GW):
			var col := []
			for y in range(GH):
				var walls := 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0: continue
						var nx := x + dx; var ny := y + dy
						if nx < 0 or ny < 0 or nx >= GW or ny >= GH: walls += 1
						elif grid[nx][ny]: walls += 1
				if grid[x][y]: col.append(walls >= 3)
				else: col.append(walls >= 5)
			next.append(col)
		grid = next
	return grid

# ============================================================
# STAGE 3: SPELUNKY DRUNKARD-WALK CRITICAL PATH
# ============================================================
func _carve_critical_path(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + 7777
	var cx := GW / 2; var cy := 3
	while cy < GH - 4:
		_carve_circle(grid, cx, cy, 6)  # Wide enough for comfortable play
		var r := rng.randf()
		if r < 0.55:   cy += 1
		elif r < 0.65: cy = max(cy - 1, 2)
		elif r < 0.80: cx = clamp(cx + rng.randi_range(1, 3), 2, GW - 3)
		else:          cx = clamp(cx - rng.randi_range(1, 3), 2, GW - 3)
	# Horizontal exploration branches — also wide
	for _b in range(12):
		var bx := rng.randi_range(6, GW - 7)
		var by := rng.randi_range(4, GH - 5)
		var blen := rng.randi_range(8, 22)
		var bdir := 1 if (rng.randi() % 2 == 0) else -1
		for b in range(blen): _carve_circle(grid, bx + b * bdir, by, 3)

func _carve_circle(grid: Array, cx: int, cy: int, radius: int) -> void:
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				var nx := cx + dx; var ny := cy + dy
				if nx > 0 and ny > 0 and nx < GW - 1 and ny < GH - 1:
					grid[nx][ny] = false

# ============================================================
# STAGE 4: CHUNK BOUNDARY CONNECTORS
# ============================================================
func _carve_chunk_connectors(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = run_seed + 99
	# Vertical passages between chunk rows — 9 tiles wide
	for col in range(COLS):
		for row in range(ROWS - 1):
			var ox := rng.randi_range(CHUNK_W / 4, 3 * CHUNK_W / 4)
			var tx := col * CHUNK_W + ox; var sy := (row + 1) * CHUNK_H
			for py in range(sy - 5, sy + 6):
				for px in range(tx - 4, tx + 5):
					if px > 0 and py > 0 and px < GW - 1 and py < GH - 1: grid[px][py] = false
	# Horizontal passages between chunk columns — 9 tiles tall
	for col in range(COLS - 1):
		for row in range(ROWS):
			var oy := rng.randi_range(CHUNK_H / 4, 3 * CHUNK_H / 4)
			var sx2 := (col + 1) * CHUNK_W; var ty := row * CHUNK_H + oy
			for px in range(sx2 - 5, sx2 + 6):
				for py in range(ty - 4, ty + 5):
					if px > 0 and py > 0 and px < GW - 1 and py < GH - 1: grid[px][py] = false

# ============================================================
# STAGE 5: OPEN CHAMBERS
# ============================================================
func _carve_chambers(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = run_seed + 54321
	for col in range(COLS):
		for row in range(ROWS):
			var cx := col * CHUNK_W + rng.randi_range(CHUNK_W / 3, 2 * CHUNK_W / 3)
			var cy := row * CHUNK_H + rng.randi_range(CHUNK_H / 3, 2 * CHUNK_H / 3)
			var rx := rng.randi_range(5, CHUNK_W / 3)
			var ry := rng.randi_range(3, CHUNK_H / 3)
			for dx in range(-rx, rx + 1):
				for dy in range(-ry, ry + 1):
					if float(dx*dx)/float(rx*rx) + float(dy*dy)/float(ry*ry) <= 1.0:
						var nx := cx + dx; var ny := cy + dy
						if nx > 0 and ny > 0 and nx < GW - 1 and ny < GH - 1: grid[nx][ny] = false

# ============================================================
# STAGE 6: SETTLEMENT POCKETS — flat-floored meeting areas
# Each chunk gets 2 carved "rooms" with guaranteed flat rock floors.
# ============================================================
func _carve_settlement_pockets(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = run_seed + 22222
	for col in range(COLS):
		for row in range(ROWS):
			for _p in range(2):
				var pw := rng.randi_range(10, 16)   # pocket width in tiles
				var ph := rng.randi_range(5, 8)    # pocket height in tiles
				var margin := 3
				var max_x := CHUNK_W - pw - margin
				var max_y := CHUNK_H - ph - margin
				if max_x <= margin or max_y <= margin: continue
				var px0 := col * CHUNK_W + rng.randi_range(margin, max_x)
				var py0 := row * CHUNK_H + rng.randi_range(margin, max_y)
				# Clear interior (all rows except the last — that's the floor)
				for lx in range(pw):
					for ly in range(ph - 1):
						var tx := px0 + lx; var ty := py0 + ly
						if tx > 0 and ty > 0 and tx < GW - 1 and ty < GH - 1:
							grid[tx][ty] = false
				# Force the bottom row solid — the flat floor
				for lx in range(pw):
					var tx := px0 + lx; var ty := py0 + ph - 1
					if tx > 0 and tx < GW - 1 and ty < GH - 1:
						grid[tx][ty] = true
				# Force the ceiling row solid — the roof
				for lx in range(pw):
					var tx := px0 + lx; var ty := py0
					if tx > 0 and tx < GW - 1 and ty > 0:
						grid[tx][ty] = true

# ============================================================
# STAGE 6b: REMOVE CHOKEPOINTS — widen any passage < 3 tiles
# ============================================================
func _widen_narrow_passages(grid: Array) -> void:
	# Two passes: first horizontal, then vertical. Each pass clears 3 tiles on each side.
	for _pass in range(2):
		for x in range(3, GW - 3):
			for y in range(3, GH - 3):
				if grid[x][y]:
					continue
				# Horizontal bottleneck: walls within 2 tiles on both sides
				var lw = bool(grid[x-1][y]) or bool(grid[x-2][y])
				var rw = bool(grid[x+1][y]) or bool(grid[x+2][y])
				if lw and rw:
					for dx in range(-3, 4):
						var nx := x + dx
						if nx > 0 and nx < GW - 1:
							grid[nx][y] = false
				# Vertical bottleneck: walls within 2 tiles above and below
				var tw = bool(grid[x][y-1]) or bool(grid[x][y-2])
				var bw = bool(grid[x][y+1]) or bool(grid[x][y+2])
				if tw and bw:
					for dy in range(-3, 4):
						var ny := y + dy
						if ny > 0 and ny < GH - 1:
							grid[x][ny] = false

# ============================================================
# STAGE 7: BORDERS + GLOBAL FLOOR
# ============================================================
func _enforce_borders(grid: Array) -> void:
	# Top and side walls
	for x in range(GW):
		grid[x][0] = true
		grid[x][1] = true
	for y in range(GH):
		grid[0][y]      = true
		grid[1][y]      = true
		grid[GW - 1][y] = true
		grid[GW - 2][y] = true
	# Global floor: solid base with rocky height variation
	var floor_rng := RandomNumberGenerator.new()
	floor_rng.seed = 4224 # Deterministic floor look
	for x in range(GW):
		# Base floor row
		grid[x][GH - 1] = true
		grid[x][GH - 2] = true
		# Rocky variation: height 1 to 3
		var h := floor_rng.randi_range(1, 4)
		for fy in range(GH - h, GH):
			grid[x][fy] = true
			
	# Ensure clearance: clear 5 rows above the maximum possible floor height (GH-4)
	for x in range(2, GW - 2):
		for cy in range(GH - 9, GH - 4):
			grid[x][cy] = false

# ============================================================
# STAGE 8: SPAWN POINTS
# ============================================================
func _collect_spawn_points(grid: Array) -> void:
	for col in range(COLS):
		var tx := col * CHUNK_W + CHUNK_W / 2
		for ty in range(1, GH - 4):
			if not grid[tx][ty] and not grid[tx][ty + 1]:
				spawn_points.append(global_position + Vector2(float(tx) * T_SIZE + T_SIZE * 0.5, float(ty) * T_SIZE + T_SIZE))
				break
	if spawn_points.is_empty():
		spawn_points.append(global_position + Vector2(ROOM_WIDTH * 0.5, 120.0))

# ============================================================
# STAGE 9: ATMOSPHERIC BACKGROUND (layers + cave darkness)
# ============================================================
func _draw_background() -> void:
	var world_w := float(COLS) * ROOM_WIDTH
	var world_h := float(ROWS) * ROOM_HEIGHT

	# Far-distance: deep void black
	var bg0 := Polygon2D.new()
	bg0.color = Color(0.04, 0.03, 0.05)
	bg0.polygon = PackedVector2Array([Vector2(0,0), Vector2(world_w,0), Vector2(world_w,world_h), Vector2(0,world_h)])
	add_child(bg0)

	# Mid-distance suggestion: slightly lighter, offset — depth parallax feel
	var bg1 := Polygon2D.new()
	bg1.color = Color(0.07, 0.05, 0.08, 0.6)
	bg1.polygon = bg0.polygon.duplicate()
	bg1.position = Vector2(1, 1) # Parallax suggestion
	add_child(bg1)

	var bg2 := Polygon2D.new()
	bg2.color = Color(0.10, 0.07, 0.10, 0.4)
	bg2.polygon = bg0.polygon.duplicate()
	bg2.position = Vector2(5, 7)
	add_child(bg2)

	# Cave darkness modulate — PointLight2D on players illuminates local area
	# CanvasLayer nodes (the HUD) are immune to CanvasModulate
	var darkness := CanvasModulate.new()
	darkness.color = Color(0.18, 0.14, 0.18)
	add_child(darkness)

# ============================================================
# STAGE 10: RENDER GLOBAL WALLS (Optimized with merging)
# ============================================================
func _render_all_walls(grid: Array) -> void:
	var wall_root := Node2D.new()
	wall_root.name = "Walls"
	add_child(wall_root)
	
	for y in range(GH):
		var start_x := -1
		for x in range(GW):
			var is_wall = bool(grid[x][y])
			if is_wall and start_x < 0:
				start_x = x
			elif not is_wall and start_x >= 0:
				_render_wall_segment(wall_root, start_x, y, x - start_x, grid)
				start_x = -1
		if start_x >= 0:
			_render_wall_segment(wall_root, start_x, y, GW - start_x, grid)

func _render_wall_segment(parent: Node2D, tx: int, ty: int, length: int, grid: Array) -> void:
	var wc := _wall_color_at(tx, ty)
	var is_global_floor = ty >= GH - 4
	if is_global_floor:
		wc = wc.darkened(0.2).lerp(Color(0.2, 0.2, 0.25), 0.5)
	
	var world_x := float(tx) * T_SIZE
	var world_y := float(ty) * T_SIZE
	var world_w := float(length) * T_SIZE
	
	_add_solid_box(parent, wc, world_x, world_y, world_w, T_SIZE)
	
	# Add rims for the whole segment
	for i in range(length):
		var cur_x := tx + i
		# Check if air above
		if ty > 0 and not bool(grid[cur_x][ty - 1]):
			var rim_col := _biome_rim_at(cur_x, ty)
			_add_rim(parent, float(cur_x) * T_SIZE, world_y, T_SIZE, rim_col)

# ============================================================
# STAGE 11: ROOM-SPECIFIC DECORATIONS
# ============================================================
func _render_room_decorations(room: Dictionary, grid: Array, run_seed: int) -> void:
	var slot   : int = int(room.get("slot", 0))
	var grid_x : int = slot % COLS
	var grid_y : int = slot / COLS
	var sx     : int = grid_x * CHUNK_W
	var sy     : int = grid_y * CHUNK_H

	var room_node := Node2D.new()
	room_node.position = Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	add_child(room_node)

	# Very subtle ambient biome tint
	var cx_t : int = sx + CHUNK_W / 2
	var cy_t : int = sy + CHUNK_H / 2
	var amb := _biome_ambient_at(cx_t, cy_t)
	var tint := Polygon2D.new()
	tint.color = Color(amb.r, amb.g, amb.b, 0.05)
	tint.polygon = PackedVector2Array([Vector2(0,0), Vector2(ROOM_WIDTH,0), Vector2(ROOM_WIDTH,ROOM_HEIGHT), Vector2(0,ROOM_HEIGHT)])
	room_node.add_child(tint)

	# Stalactites / stalagmites
	_add_formations(room_node, grid, sx, sy)

	# Hazard spikes
	if str(room.get("hazard", "")) == "spikes":
		var rng := RandomNumberGenerator.new(); rng.seed = slot * 7919 + run_seed
		var stx : int = CHUNK_W / 4 + rng.randi() % (CHUNK_W / 2)
		var spy : float = ROOM_HEIGHT - T_SIZE - 8.0
		for ly in range(CHUNK_H - 2, CHUNK_H / 2, -1):
			if grid[sx + stx][sy + ly]: spy = float(ly)*T_SIZE - 8.0; break
		_add_spikes(room_node, float(stx)*T_SIZE - 60.0, spy, 120.0)

	# Labels and Indicators
	var type_str : String = str(room.get("type", "?"))
	var label := Label.new(); label.position = Vector2(10, 10)
	label.text = type_str[0].to_upper()
	label.add_theme_color_override("font_color", Color(amb.r, amb.g, amb.b, 0.4))
	label.add_theme_font_size_override("font_size", 11)
	room_node.add_child(label)

	var indicator := Label.new(); indicator.position = Vector2(ROOM_WIDTH - 48.0, 24.0)
	indicator.text = "!"; indicator.visible = false
	indicator.modulate = Color(1.0, 0.18, 0.2, 1.0)
	indicator.add_theme_font_size_override("font_size", 32)
	room_node.add_child(indicator)
	indicator_by_slot[slot]           = indicator
	indicator_time_left_by_slot[slot] = 0.0

# ============================================================
# RIM-LIGHT HIGHLIGHT on top edge of wall tiles
# ============================================================
func _add_rim(parent: Node2D, x: float, y: float, w: float, color: Color) -> void:
	# Primary rim
	var rim := Polygon2D.new()
	rim.color = color
	rim.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(w, 0),
		Vector2(w, 3.0), Vector2(0, 3.0)
	])
	rim.position = Vector2(x, y)
	parent.add_child(rim)
	
	# Secondary sub-rim for "shine" effect
	var shine := Polygon2D.new()
	shine.color = color.lightened(0.3)
	shine.color.a = 0.4
	shine.polygon = PackedVector2Array([
		Vector2(2.0, 1.0), Vector2(w - 2.0, 1.0),
		Vector2(w - 2.0, 2.0), Vector2(2.0, 2.0)
	])
	shine.position = Vector2(x, y)
	parent.add_child(shine)

# ============================================================
# STALACTITES & STALAGMITES (decorative only)
# ============================================================
func _add_formations(room_node: Node2D, grid: Array, sx: int, sy: int) -> void:
	# Scan every-other column for ceiling and floor exposure
	for lx in range(1, CHUNK_W - 1, 2):
		# Stalactite: first solid from top where cell below is open
		for ly in range(1, CHUNK_H - 2):
			if grid[sx + lx][sy + ly] and not grid[sx + lx][sy + ly + 1]:
				var h := T_SIZE * randf_range(0.6, 2.2)
				var w := h * 0.38
				var cx := float(lx) * T_SIZE + T_SIZE * 0.5 + randf_range(-4, 4)
				var cy := float(ly + 1) * T_SIZE
				var p := Polygon2D.new()
				p.color = Color(0.12, 0.09, 0.10, 0.88)
				p.polygon = PackedVector2Array([Vector2(-w, 0), Vector2(w, 0), Vector2(0, h)])
				p.position = Vector2(cx, cy)
				room_node.add_child(p)
				break
		# Stalagmite: first solid from bottom where cell above is open (30% chance)
		for ly in range(CHUNK_H - 3, 2, -1):
			if grid[sx + lx][sy + ly] and not grid[sx + lx][sy + ly - 1]:
				if randf() < 0.30:
					var h := T_SIZE * randf_range(0.4, 1.6)
					var w := h * 0.38
					var cx := float(lx) * T_SIZE + T_SIZE * 0.5 + randf_range(-4, 4)
					var cy := float(ly) * T_SIZE
					var p := Polygon2D.new()
					p.color = Color(0.14, 0.11, 0.12, 0.80)
					p.polygon = PackedVector2Array([Vector2(-w, 0), Vector2(w, 0), Vector2(0, -h)])
					p.position = Vector2(cx, cy)
					room_node.add_child(p)
				break

# ============================================================
# STAGE 11: FLOATING PLATFORMS
# ============================================================
func _place_platforms(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = run_seed + 8888
	for x in range(2, GW - 2, 3):
		var open_start := -1
		for y in range(1, GH - 1):
			if not grid[x][y]:
				if open_start < 0: open_start = y
			else:
				if open_start >= 0:
					var drop := y - open_start
					if drop >= 9:
						var plat_y := open_start + drop / 2
						var plat_len := 3 + rng.randi() % 5
						var plat_off := rng.randi_range(-2, 0)
						for px in range(plat_len):
							var tx := x + px + plat_off
							if tx > 0 and tx < GW - 1 and plat_y < GH - 3:
								var chunk_col := tx / CHUNK_W
								var chunk_row := plat_y / CHUNK_H
								var rn := _room_node_for_chunk(chunk_col, chunk_row)
								if rn:
									var lx2 := float(tx - chunk_col * CHUNK_W) * T_SIZE
									var ly2 := float(plat_y - chunk_row * CHUNK_H) * T_SIZE
									_add_platform_tile(rn, lx2, ly2)
				open_start = -1

func _room_node_for_chunk(grid_x: int, grid_y: int) -> Node2D:
	var tp := Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	for child in get_children():
		if child is Node2D and (child as Node2D).position == tp and child.get_child_count() > 0:
			return child as Node2D
	return null

func _add_platform_tile(parent: Node2D, x: float, y: float) -> void:
	var body := StaticBody2D.new(); body.position = Vector2(x, y)
	var poly := Polygon2D.new()
	poly.color = Color(0.42, 0.32, 0.22)
	poly.polygon = PackedVector2Array([Vector2(0,0), Vector2(T_SIZE,0), Vector2(T_SIZE,T_SIZE*0.32), Vector2(0,T_SIZE*0.32)])
	body.add_child(poly)
	var col := CollisionPolygon2D.new(); col.polygon = poly.polygon
	body.add_child(col); parent.add_child(body)

# ============================================================
# PUBLIC API
# ============================================================
func get_spawn_point(index: int) -> Vector2:
	if spawn_points.is_empty(): return global_position + Vector2(ROOM_WIDTH*0.5, 120.0)
	return spawn_points[index % spawn_points.size()]

func flash_hazard_indicator(room_slot: int, duration_sec: float = 0.3) -> void:
	if not indicator_time_left_by_slot.has(room_slot): return
	indicator_time_left_by_slot[room_slot] = maxf(float(indicator_time_left_by_slot[room_slot]), duration_sec)
	var ind : Label = indicator_by_slot.get(room_slot, null)
	if ind: ind.visible = true

func _process(delta: float) -> void:
	for slot in indicator_time_left_by_slot.keys():
		var left : float = float(indicator_time_left_by_slot[slot]) - delta
		indicator_time_left_by_slot[slot] = maxf(left, 0.0)
		var ind : Label = indicator_by_slot.get(slot, null)
		if ind: ind.visible = left > 0.0

# ============================================================
# HELPERS: physics geometry
# ============================================================
func _add_solid_box(parent: Node2D, color: Color, x: float, y: float, w: float, h: float) -> void:
	var body := StaticBody2D.new(); body.position = Vector2(x, y)
	var poly := Polygon2D.new(); poly.color = color
	poly.polygon = PackedVector2Array([Vector2(0,0), Vector2(w,0), Vector2(w,h), Vector2(0,h)])
	body.add_child(poly)
	var col := CollisionPolygon2D.new(); col.polygon = poly.polygon
	body.add_child(col); parent.add_child(body)

func _add_spikes(parent: Node2D, x: float, y: float, w: float) -> void:
	var area := Area2D.new(); area.position = Vector2(x, y); area.add_to_group("hazards")
	var poly := Polygon2D.new(); poly.color = Color(0.72, 0.08, 0.08)
	var pts := PackedVector2Array(); pts.append(Vector2(0, 8))
	for i in range(int(w / 10.0)):
		pts.append(Vector2(float(i)*10.0+5.0, 0.0)); pts.append(Vector2(float(i+1)*10.0, 8.0))
	poly.polygon = pts; area.add_child(poly)
	var col := CollisionShape2D.new(); var rect := RectangleShape2D.new()
	rect.size = Vector2(w, 8.0); col.shape = rect; col.position = Vector2(w*0.5, 4.0)
	area.add_child(col); parent.add_child(area)

# ============================================================
# NOISE-BASED BIOME COLOR HELPERS (organic blobs, not columns)
# ============================================================
func _biome_ambient_at(tile_x: int, tile_y: int) -> Color:
	var n : float = biome_noise.get_noise_2d(float(tile_x), float(tile_y))
	if n < -0.55: return Color(0.38, 0.55, 0.38)   # Mossy — green
	elif n < -0.15: return Color(0.38, 0.46, 0.64)  # Crystal — steel blue
	elif n < 0.15:  return Color(0.56, 0.48, 0.36)  # Stone — warm ochre
	elif n < 0.55:  return Color(0.62, 0.34, 0.34)  # Blood — dusty crimson
	else:           return Color(0.65, 0.60, 0.30)   # Temple — gold

func _wall_color_at(tile_x: int, tile_y: int) -> Color:
	var n : float = biome_noise.get_noise_2d(float(tile_x), float(tile_y))
	var dd : float = float(tile_y) / float(GH) * 0.12
	if n < -0.55: return Color(0.17, 0.24, 0.17).darkened(dd)
	elif n < -0.15: return Color(0.15, 0.20, 0.30).darkened(dd)
	elif n < 0.15:  return Color(0.23, 0.18, 0.15).darkened(dd)
	elif n < 0.55:  return Color(0.25, 0.14, 0.14).darkened(dd)
	else:           return Color(0.27, 0.22, 0.11).darkened(dd)

func _biome_rim_at(tile_x: int, tile_y: int) -> Color:
	var n : float = biome_noise.get_noise_2d(float(tile_x), float(tile_y))
	# Rim highlight — slightly lighter, slightly warm, low alpha
	if n < -0.55: return Color(0.36, 0.52, 0.34, 0.55)
	elif n < -0.15: return Color(0.32, 0.42, 0.60, 0.55)
	elif n < 0.15:  return Color(0.50, 0.40, 0.28, 0.55)
	elif n < 0.55:  return Color(0.55, 0.28, 0.25, 0.55)
	else:           return Color(0.60, 0.52, 0.22, 0.55)
