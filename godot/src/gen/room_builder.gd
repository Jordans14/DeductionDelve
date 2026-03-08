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
var cached_glow_tex : GradientTexture2D
var world_grid := []

func _ready() -> void:
	set_process(true)

# ============================================================
# MAIN ENTRY POINT
# ============================================================
func build_from_chain(room_chain: Array, run_seed: int = 99991) -> void:
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

	# Organic area-based biome noise — very low frequency so regions are large blobs
	biome_noise = FastNoiseLite.new()
	biome_noise.seed = run_seed + 555
	biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	biome_noise.frequency = 0.012
	biome_noise.fractal_octaves = 2

	# Cache textures for performance
	cached_glow_tex = GradientTexture2D.new()
	cached_glow_tex.gradient = Gradient.new()
	cached_glow_tex.gradient.colors = [Color.WHITE, Color(1,1,1,0)]
	cached_glow_tex.fill = GradientTexture2D.FILL_RADIAL
	cached_glow_tex.fill_from = Vector2(0.5, 0.5)
	cached_glow_tex.width = 128; cached_glow_tex.height = 128
	
	# Aesthetic Lighting Pass
	var env_night := CanvasModulate.new()
	env_night.color = Color(0.08, 0.05, 0.12) # Deep creepy cavern purple
	add_child(env_night)

	# ── Stage 1: Domain-warped noise grid ──────────────────
	var grid := _build_noise_grid(run_seed)

	# ── Stage 2: Spelunky biased critical path ─────────────
	_carve_critical_path(grid, run_seed, 2.8) # Tighter narrative tunnels

	# ── Stage 3: Guaranteed chunk-boundary connectors ──────
	_carve_chunk_connectors(grid, run_seed)

	# ── Stage 4: Winding horizontal pathways ──────────────
	_carve_pathways(grid, run_seed)

	# ── Stage 5: Smooth with cellular automata ─────────────
	# Smoothing AFTER carving makes tunnels look naturally eroded!
	grid = _smooth_ca(grid, 3)

	# ── Stage 6: Settlement pockets — flat-floored rooms ───
	# Carved strictly AFTER smoothing so they keep their hard angles
	_carve_settlement_pockets(grid, run_seed)

	# ── Stage 7: Cleanup floating rock fragments ──────────
	_cleanup_floating_islands(grid)

	# ── Stage 8: Enforce hard borders + global floor ───────
	_enforce_borders(grid)

	# ── Stage 8: Collect spawn points ─────────────────────
	_collect_spawn_points(grid)

	# ── Stage 9: Draw atmosphere background ───────────────
	_draw_background(run_seed)

	# ── Stage 10: Render GLOBAL walls with horizontal merging ──
	_render_all_walls(grid)

	# ── Stage 11: Render generic room decorations for ALL chunks ──
	for cy in range(ROWS):
		for cx in range(COLS):
			var sx = cx * CHUNK_W
			var sy = cy * CHUNK_H
			_render_global_decorations(cx, cy, sx, sy, grid, run_seed)

	# ── Stage 11b: Render specific critical path room triggers ──
	for room in room_chain:
		_render_room_specifics(room, grid, run_seed)

	# ── Stage 12: Floating platforms in vertical drops ─────
	_place_platforms(grid, run_seed)

	# ── Stage 13: Procedural Scaffolding Buildings ─────────
	_place_scaffolding(grid, run_seed)

	# ── Stage 14: Spelunky 2 Style Background Doors ────────
	_place_background_doors(grid, run_seed)
	
	world_grid = grid

# ============================================================
# RUNTIME DESTRUCTION
# ============================================================
func carve_hole(world_pos: Vector2, radius_px: float) -> void:
	if world_grid.is_empty(): return
	var tx = int(world_pos.x / T_SIZE)
	var ty = int(world_pos.y / T_SIZE)
	var r = int(radius_px / T_SIZE)
	var changed = false
	for dx in range(-r, r + 1):
		for dy in range(-r, r + 1):
			if dx*dx + dy*dy <= r*r:
				var nx = tx + dx
				var ny = ty + dy
				if nx > 0 and ny > 0 and nx < GW-1 and ny < GH-1:
					if world_grid[nx][ny]: 
						world_grid[nx][ny] = false
						changed = true
	if changed:
		var old_walls = get_node_or_null("Walls")
		if old_walls: old_walls.queue_free()
		call_deferred("_render_all_walls", world_grid)

# ============================================================
# STAGE 1: DOMAIN-WARPED LAYERED NOISE
# ============================================================
func _build_noise_grid(run_seed: int) -> Array:
	var cave_noise := FastNoiseLite.new()
	cave_noise.seed = run_seed
	cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	cave_noise.frequency = 0.06 # Higher frequency for tighter, ant-farm squiggles
	cave_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	cave_noise.fractal_octaves = 3
	
	var chamber_noise := FastNoiseLite.new()
	chamber_noise.seed = run_seed + 1337
	chamber_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	chamber_noise.frequency = 0.04
	chamber_noise.fractal_octaves = 2

	var grid := []
	for x in range(GW):
		var col := []
		for y in range(GH):
			var n : float = cave_noise.get_noise_2d(float(x), float(y))
			var nc : float = chamber_noise.get_noise_2d(float(x), float(y))
			
			# Ant-Farm thin squiggles, widened slightly to prevent getting stuck
			var is_tunnel : bool = abs(n) < 0.12
			
			# Rare tiny rooms
			var is_chamber : bool = nc > 0.45
				
			var is_wall : bool = not (is_tunnel or is_chamber)
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
func _carve_critical_path(grid: Array, run_seed: int, radius: float = 2.5) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed + 7777
	var cx : int = GW / 2; var cy : int = 3
	while cy < GH - 4:
		var r_var := rng.randf_range(0.8, 1.2)
		_carve_circle(grid, cx, cy, int(radius * r_var)) # Clear wide main pathway
		var r := rng.randf()
		if r < 0.65:   cy += 1 # Increased vertical bias
		elif r < 0.70: cy = max(cy - 1, 2)
		elif r < 0.85: cx = clamp(cx + rng.randi_range(1, 3), 2, GW - 3)
		else:          cx = clamp(cx - rng.randi_range(1, 3), 2, GW - 3)
	# Horizontal exploration branches — fewer for more rock
	for _b in range(6):
		var bx : int = rng.randi_range(6, GW - 7)
		var by : int = rng.randi_range(4, GH - 5)
		var blen : int = rng.randi_range(3, 10)
		var bdir : int = 1 if (rng.randi() % 2 == 0) else -1
		for b in range(blen): _carve_circle(grid, bx + b * bdir, by, 1)

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
	# Disabled to prevent "flat platformer rooms" look!
	pass

# ============================================================
# STAGE 4b: WINDING PATHWAYS (The Ant Farm Diggers)
# ============================================================
func _carve_pathways(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = run_seed + 54321
	
	# Spawn 50 "Ant Farm Diggers" to create a web of thin paths
	for _i in range(50):
		var px : float = rng.randf_range(10, GW - 10)
		var py : float = rng.randf_range(10, GH - 10)
		var dir : float = rng.randf_range(0, TAU)
		var length : int = rng.randi_range(60, 110)
		var thickness : int = rng.randi_range(2, 4) # Thicker passages so players don't bottleneck easily
		
		for i in range(length):
			# Dig
			for dx in range(-thickness, thickness + 1):
				for dy in range(-thickness, thickness + 1):
					if dx*dx + dy*dy <= thickness * thickness:
						var fx : int = int(px) + dx
						var fy : int = int(py) + dy
						if fx > 0 and fy > 0 and fx < GW - 1 and fy < GH - 1:
							grid[fx][fy] = false
							
			# Random organic drift (Brownian motion)
			dir += rng.randf_range(-0.5, 0.5)
			px += cos(dir) * 1.5
			py += sin(dir) * 1.5
			
			if px <= 2 or px >= GW - 3 or py <= 2 or py >= GH - 3: break

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


func _cleanup_floating_islands(grid: Array) -> void:
	# Delete small groups of rock tiles that are isolated in the air
	for x in range(2, GW - 2):
		for y in range(2, GH - 2):
			if bool(grid[x][y]):
				var neighbors : int = 0
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0: continue
						if bool(grid[x+dx][y+dy]): neighbors += 1
				if neighbors <= 1: # Isolated single block or small edge
					grid[x][y] = false



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
	# Global floor: solid base significantly RAISED (higher than absolute bottom)
	var floor_top = GH - 12 # Raised by approx 400px (12 tiles * 32px)
	var floor_rng := RandomNumberGenerator.new()
	floor_rng.seed = 4224 
	for x in range(GW):
		# Solid footer
		for fy in range(floor_top + 1, GH):
			grid[x][fy] = true
		# Rocky surface variation
		var h := floor_rng.randi_range(0, 3)
		for fy in range(floor_top - h, floor_top + 1):
			grid[x][fy] = true
			
	# Ensure massive clearance above the global floor
	for x in range(2, GW - 2):
		for cy in range(floor_top - 12, floor_top - 3):
			grid[x][cy] = false

# ============================================================
# STAGE 8: SPAWN POINTS (Search from Floor UPWARDS)
# ============================================================
func _collect_spawn_points(grid: Array) -> void:
	# Search from Floor UPWARDS
	var floor_search_start = GH - 16
	for col in range(COLS):
		var tx := col * CHUNK_W + CHUNK_W / 2
		for ty in range(floor_search_start, 5, -1):
			if not bool(grid[tx][ty]) and not bool(grid[tx][ty - 1]) and bool(grid[tx][ty + 1]):
				spawn_points.append(global_position + Vector2(float(tx) * T_SIZE + T_SIZE * 0.5, float(ty) * T_SIZE + T_SIZE))
				break
		# Fallback if no spot found near floor: use world center
		if spawn_points.size() <= col:
			spawn_points.append(global_position + Vector2(float(tx) * T_SIZE + T_SIZE * 0.5, float(GH) * 0.5 * T_SIZE))
	if spawn_points.is_empty():
		spawn_points.append(global_position + Vector2(float(GW)*0.5*T_SIZE, float(GH)*0.5*T_SIZE))

# ============================================================
# STAGE 9: ATMOSPHERIC BACKGROUND (layers + cave darkness)
# ============================================================
func _draw_background(run_seed: int) -> void:
	var world_w := float(COLS) * ROOM_WIDTH
	var world_h := float(ROWS) * ROOM_HEIGHT

	# Far-distance: deep void black
	var bg0 := Polygon2D.new()
	bg0.color = Color(0.04, 0.03, 0.05)
	bg0.polygon = PackedVector2Array([Vector2(0,0), Vector2(world_w,0), Vector2(world_w,world_h), Vector2(0,world_h)])
	add_child(bg0)

	# Deep-distance suggestion: slightly lighter, offset — depth parallax feel
	var bg1 := Polygon2D.new()
	bg1.color = Color(0.06, 0.05, 0.07, 1.0)
	bg1.polygon = bg0.polygon.duplicate()
	bg1.position = Vector2(1, 1) # Parallax suggestion
	add_child(bg1)

	# Parallax silhouettes: suggested depth with distant giant rock arches
	var parallax_root := Node2D.new()
	parallax_root.name = "ParallaxBack"
	add_child(parallax_root)
	
	var p_rng := RandomNumberGenerator.new(); p_rng.seed = run_seed + 12345
	for i in range(16):
		var px := p_rng.randf_range(0, world_w)
		var py := p_rng.randf_range(0, world_h)
		var pw := p_rng.randf_range(400, 1000)
		var ph := p_rng.randf_range(300, 600)
		var sil := Polygon2D.new()
		sil.color = Color(0.08, 0.07, 0.10, 0.5)
		sil.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(pw, 0), Vector2(pw*1.3, ph), 
			Vector2(pw*0.5, ph*1.6), Vector2(-pw*0.3, ph)
		])
		sil.position = Vector2(px, py)
		sil.rotation = p_rng.randf_range(-0.5, 0.5)
		parallax_root.add_child(sil)

	# Cave darkness modulate — Truly dark exploration!
	var darkness := CanvasModulate.new()
	darkness.color = Color(0.12, 0.10, 0.13)
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
	var is_global_floor = ty >= GH - 16 # Match new raised floor level
	if is_global_floor:
		wc = Color(0.12, 0.12, 0.18).lerp(Color(0.2, 0.2, 0.4), 0.4) # Brighter Deep Shale
	
	var world_x := float(tx) * T_SIZE
	var world_y := float(ty) * T_SIZE
	var world_w := float(length) * T_SIZE
	
	_add_solid_box(parent, wc, world_x, world_y, world_w, T_SIZE)
	
	# Add rims and ores for the whole segment
	for i in range(length):
		var cur_x := tx + i
		# Render embedded ores randomly in walls
		if randf() < 0.04:
			_add_ore(parent, float(cur_x) * T_SIZE, world_y)
			
		# Check if air above
		if ty > 0 and not bool(grid[cur_x][ty - 1]):
			var rim_col := _biome_rim_at(cur_x, ty)
			if ty >= GH - 16:
				rim_col = rim_col.lerp(Color(0.0, 0.8, 1.0, 0.8), 0.5) # Cyan-shale glow for ground
			_add_rim(parent, float(cur_x) * T_SIZE, world_y, T_SIZE, rim_col)

# ============================================================
# STAGE 11: GLOBAL CHUNK DECORATIONS
# ============================================================
func _render_global_decorations(grid_x: int, grid_y: int, sx: int, sy: int, grid: Array, run_seed: int) -> void:
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

	_add_bioluminescence(room_node, grid, sx, sy, amb)
	_add_crystals(room_node, grid, sx, sy, amb)
	_add_vines(room_node, grid, sx, sy, amb)
	_add_ambient_atmosphere(room_node)
	_add_formations(room_node, grid, sx, sy, amb)

# ============================================================
# STAGE 11b: ROOM-SPECIFIC TRIGGERS / SPIKES
# ============================================================
func _render_room_specifics(room: Dictionary, grid: Array, run_seed: int) -> void:
	var slot   : int = int(room.get("slot", 0))
	var grid_x : int = slot % COLS
	var grid_y : int = slot / COLS
	var sx     : int = grid_x * CHUNK_W
	var sy     : int = grid_y * CHUNK_H

	var room_node = _room_node_for_chunk(grid_x, grid_y)
	if not room_node: return

	# Hazard spikes
	if str(room.get("hazard", "")) == "spikes":
		var rng := RandomNumberGenerator.new(); rng.seed = slot * 7919 + run_seed
		var valid_x = -1; var valid_y = -1
		for attempt in range(30):
			var rx = rng.randi_range(2, CHUNK_W - 6)
			var ry = rng.randi_range(CHUNK_H / 2, CHUNK_H - 2)
			var flat = true
			for i in range(4):
				if not grid[sx + rx + i][sy + ry]: flat = false
				if grid[sx + rx + i][sy + ry - 1]: flat = false
			if flat:
				valid_x = rx; valid_y = ry - 1; break
		if valid_x != -1:
			_add_spikes(room_node, float(valid_x)*T_SIZE, float(valid_y)*T_SIZE + T_SIZE - 8.0, 4.0 * T_SIZE)

	# Labels and Indicators
	var type_str : String = str(room.get("type", "?"))
	var label := Label.new(); label.position = Vector2(10, 10)
	label.text = type_str[0].to_upper()
	var cx_t : int = sx + CHUNK_W / 2
	var cy_t : int = sy + CHUNK_H / 2
	var amb := _biome_ambient_at(cx_t, cy_t)
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
# BIOLUMINESCENT FLORA (The "Glow")
# ============================================================
func _add_bioluminescence(parent: Node2D, grid: Array, sx: int, sy: int, biome_amb: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = sx * 31 + sy * 53
	# Colorful flora: Magenta, Lime-green, Cyan blue
	var colors : Array[Color] = [Color(0.8, 0.3, 1.0), Color(0.1, 0.9, 0.4), Color(0.0, 0.8, 1.0)]
	var glow_col : Color = colors[rng.randi() % colors.size()]
	
	# Scatters cluster nodes on solid surfaces
	for lx in range(CHUNK_W):
		for ly in range(CHUNK_H):
			if bool(grid[sx + lx][sy + ly]):
				# Only grow on surfaces (exposed to air)
				var exposed := false
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						var ex := sx + lx + dx; var ey := sy + ly + dy
						if ex >= 0 and ey >= 0 and ex < GW and ey < GH:
							if not bool(grid[ex][ey]): exposed = true; break
				
				if exposed and rng.randf() < 0.03:
					var world_pos := Vector2(float(lx)*T_SIZE + T_SIZE*0.5, float(ly)*T_SIZE + T_SIZE*0.5)
					
					# Light node
					var light := PointLight2D.new()
					light.color = glow_col
					light.energy = 0.8
					light.texture = cached_glow_tex
					light.position = world_pos
					parent.add_child(light)
					
					# Flora visual (cluster of tiny glowing dots)
					for _j in range(rng.randi_range(3, 5)):
						var dot := Polygon2D.new()
						dot.color = glow_col.lightened(0.2)
						dot.polygon = PackedVector2Array([Vector2(-2,-2), Vector2(2,-2), Vector2(2,2), Vector2(-2,2)])
						dot.position = world_pos + Vector2(rng.randf_range(-10, 10), rng.randf_range(-10, 10))
						parent.add_child(dot)

func _add_crystals(parent: Node2D, grid: Array, sx: int, sy: int, biome_amb: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = sx * 13 + sy * 37
	var crystal_cols : Array[Color] = [Color(0.2, 0.6, 1.0), Color(1.0, 0.2, 0.6), Color(0.9, 0.9, 0.1)]
	
	for lx in range(CHUNK_W):
		for ly in range(CHUNK_H):
			if bool(grid[sx + lx][sy + ly]):
				# Check if exposed above (on the floor)
				if ly > 0 and not bool(grid[sx + lx][sy + ly - 1]) and rng.randf() < 0.015:
					var world_pos := Vector2(float(lx)*T_SIZE + T_SIZE*0.5, float(ly)*T_SIZE)
					var col : Color = crystal_cols[rng.randi() % crystal_cols.size()]
					
					# Crystal shard
					var shard := Polygon2D.new()
					shard.color = col
					shard.polygon = PackedVector2Array([Vector2(-4,0), Vector2(4,0), Vector2(0,-16)])
					shard.position = world_pos
					shard.rotation = rng.randf_range(-0.4, 0.4)
					parent.add_child(shard)
					
					# Light aura
					var clight := PointLight2D.new()
					clight.color = col; clight.energy = 0.5
					clight.texture = cached_glow_tex
					clight.scale = Vector2(0.8, 0.8)
					clight.position = world_pos + Vector2(0, -8)
					parent.add_child(clight)

func _add_vines(parent: Node2D, grid: Array, sx: int, sy: int, biome_amb: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = sx * 7 + sy * 19
	for lx in range(CHUNK_W):
		if rng.randf() < 0.1: # 10% chance per column
			# Find ceiling
			for ly in range(1, CHUNK_H - 1):
				if bool(grid[sx + lx][sy + ly]) and not bool(grid[sx + lx][sy + ly + 1]):
					if rng.randf() < 0.2:
						var v_len := rng.randi_range(2, 5)
						var world_x := float(lx) * T_SIZE + T_SIZE * 0.5
						var world_y := float(ly + 1) * T_SIZE
						
						var l2d := Line2D.new()
						l2d.default_color = Color(0.1, 0.35, 0.15)
						l2d.width = 2.0
						l2d.antialiased = true
						for i in range(v_len):
							l2d.add_point(Vector2(sin(i * 0.5) * 4.0, i * 16.0))
						l2d.position = Vector2(world_x, world_y)
						parent.add_child(l2d)
						
						# Glowing tips
						var glow := Polygon2D.new()
						glow.color = Color(0.3, 0.9, 0.3)
						glow.polygon = PackedVector2Array([Vector2(-3,-3), Vector2(3,-3), Vector2(3,3), Vector2(-3,3)])
						glow.position = Vector2(world_x + sin((v_len-1) * 0.5) * 4.0, world_y + (v_len-1) * 16.0)
						parent.add_child(glow)
					break


func _add_ambient_atmosphere(parent: Node2D) -> void:
	var dust := CPUParticles2D.new()
	dust.amount = 12
	dust.lifetime = 6.0
	dust.preprocess = 10.0
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(ROOM_WIDTH/2, ROOM_HEIGHT/2)
	dust.position = Vector2(ROOM_WIDTH/2, ROOM_HEIGHT/2)
	dust.gravity = Vector2(0, 2)
	dust.direction = Vector2(1, 0.5)
	dust.spread = 180.0
	dust.initial_velocity_min = 5.0; dust.initial_velocity_max = 15.0
	dust.scale_amount_min = 1.0; dust.scale_amount_max = 3.0
	dust.color = Color(0.7, 0.8, 1.0, 0.15)
	parent.add_child(dust)

# ============================================================
# STALACTITES & STALAGMITES (decorative only)
# ============================================================
func _add_formations(room_node: Node2D, grid: Array, sx: int, sy: int, biome_amb: Color) -> void:
	# Scan every-other column for ceiling and floor exposure
	for lx in range(1, CHUNK_W - 1, 2):
		# Stalactite: blended with biome ambient
		for ly in range(1, CHUNK_H - 2):
			if grid[sx + lx][sy + ly] and not grid[sx + lx][sy + ly + 1]:
				var h := T_SIZE * randf_range(0.6, 2.2)
				var w := h * 0.38
				var cx := float(lx) * T_SIZE + T_SIZE * 0.5 + randf_range(-4, 4)
				var cy := float(ly + 1) * T_SIZE
				var p := Polygon2D.new()
				p.color = biome_amb.darkened(0.6)
				p.polygon = PackedVector2Array([Vector2(-w, 0), Vector2(w, 0), Vector2(0, h)])
				p.position = Vector2(cx, cy)
				room_node.add_child(p)
				break
		# Stalagmite: blended with biome
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
# STAGE 12: FLOATING PLATFORMS (VERTICAL TRAVERSAL ESCAPE)
# ============================================================
func _place_platforms(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = run_seed + 8888
	# Scan every 8th column to find massively vertical drops (more sparse, less clutter)
	for x in range(3, GW - 3, 8):
		var open_start := -1
		for y in range(1, GH - 1):
			if not grid[x][y]:
				if open_start < 0: open_start = y
			else:
				if open_start >= 0:
					var drop := y - open_start
					if drop >= 12:
                        # Massive drop! Place a platform every 6 blocks so players can jump out
						var num_plats : int = int(drop) / 6
						for i in range(1, num_plats + 1):
							var plat_y : int = open_start + (i * 6)
							if plat_y >= GH - 4: continue # Don't place right on the floor
							var plat_len : int = rng.randi_range(3, 4)
							var plat_off : int = rng.randi_range(-1, 0)
							for px in range(plat_len):
								var tx : int = x + px + plat_off
								if tx > 0 and tx < GW - 1 and not grid[tx][plat_y]:
									var chunk_col : int = tx / CHUNK_W
									var chunk_row : int = plat_y / CHUNK_H
									var rn = _room_node_for_chunk(chunk_col, chunk_row)
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
	body.collision_layer = 2 # Scaffold / One-Way Platform layer
	body.collision_mask = 0
	
	# Background wooden anchor / scaffold chain hooking it to the wall behind it
	var anchor := ColorRect.new()
	anchor.size = Vector2(4, T_SIZE * 1.5)
	anchor.position = Vector2(T_SIZE/2 - 2, -T_SIZE * 0.5)
	anchor.color = Color(0.12, 0.08, 0.06, 0.5)
	body.add_child(anchor)
	
	var poly := Polygon2D.new()
	poly.color = Color(0.42, 0.32, 0.22, 1.0) # Wooden board visual
	poly.polygon = PackedVector2Array([Vector2(0,0), Vector2(T_SIZE,0), Vector2(T_SIZE,6), Vector2(0,6)])
	body.add_child(poly)
	
	var col := CollisionPolygon2D.new()
	col.polygon = poly.polygon
	col.one_way_collision = true # CRITICAL: Allows players to jump UP through the platforms!
	body.add_child(col)
	parent.add_child(body)
	
	if randf() < 0.1: # 10% chance per platform block to spawn a loot box
		var box = load("res://src/items/loot_box.gd").new()
		box.position = Vector2(x + T_SIZE/2, y - 12)
		parent.add_child(box)

# ============================================================
# STAGE 13: PROCEDURAL SCAFFOLDING BUILDINGS
# ============================================================
func _place_scaffolding(grid: Array, run_seed: int) -> void:
	var rng := RandomNumberGenerator.new(); rng.seed = run_seed + 11111
	var num_towers = rng.randi_range(8, 14) # Scaled back from 16-24 so they feel special and un-cluttered
	var placed = 0
	for _attempt in range(2500):
		if placed >= num_towers: break
		var x = rng.randi_range(6, GW - 8)
		# Spread heavily across the bottom half as well as the top
		var y = rng.randi_range(16, GH - 5)
		var w = min(rng.randi_range(4, 9), GW - x - 1) # Structure width in tiles clamped
		var h = min(rng.randi_range(4, 7), y - 1) # Structure height in tiles clamped
		
		var block_count = 0
		var total_cells = w * h
		for cx in range(x, x + w):
			for cy in range(y - h, y):
				if cx >= 0 and cx < GW and cy >= 0 and cy < GH:
					if grid[cx][cy]: block_count += 1
		
		# Allow it to carve out huge chunks of rock (up to 75% solid block)
		if block_count > total_cells * 0.75:
			continue
			
		var floor_support = 0
		for cx in range(x, x + w):
			if y < GH and grid[cx][y]:
				floor_support += 1
		
		# Extremely forgiving, only 25% floor support needed
		if floor_support < w / 4:
			continue

		# Precalculate continuous flat floors for the building
		var has_floor_by_y = {}
		for cy in range(y - h, y):
			has_floor_by_y[cy] = false
		has_floor_by_y[y - h] = true # Solid Roof
		
		# Platform every 3 units down
		for cy in range(y - h + 3, y, 3):
			has_floor_by_y[cy] = true

		# Cleanly carve out the new room's airspace, avoiding clipping into rock unnecessarily
		for cx in range(x, x + w):
			for cy in range(y - h, y):
				grid[cx][cy] = false 
				
		for cx in range(x, x + w):
			# Determine how far down the "legs" need to stretch into the cave abyss to hit floor
			var base_y = y
			while base_y < GH - 2 and not grid[cx][base_y]:
				base_y += 1
				
			for cy in range(y - h, base_y):
				var chunk_col: int = cx / CHUNK_W
				var chunk_row: int = cy / CHUNK_H
				var rn = _room_node_for_chunk(chunk_col, chunk_row)
				if rn:
					var lx := float(cx - chunk_col * CHUNK_W) * T_SIZE
					var ly := float(cy - chunk_row * CHUNK_H) * T_SIZE
					var is_left = (cx == x)
					var is_right = (cx == x + w - 1)
					var has_plat = false
					var is_base = (cy >= y)
					if not is_base and has_floor_by_y.has(cy):
						has_plat = has_floor_by_y[cy]
					_add_scaffold_tile(rn, lx, ly, has_plat, is_left, is_right, is_base)
		placed += 1

func _add_scaffold_tile(parent: Node2D, x: float, y: float, has_platform: bool, is_left: bool, is_right: bool, is_base_leg: bool = false) -> void:
	var vis := Node2D.new()
	vis.position = Vector2(x, y)
	
	if not is_base_leg:
		# Solid dark wooden backwall backing like a constructed cabin inside the cave
		var bg := ColorRect.new()
		bg.size = Vector2(T_SIZE, T_SIZE)
		bg.color = Color(0.14, 0.10, 0.08)
		vis.add_child(bg)
		
		# Background vertical wood panels
		for i in range(4):
			var plank = ColorRect.new()
			plank.size = Vector2(6, T_SIZE)
			plank.position = Vector2(i * 8, 0)
			plank.color = Color(0.18, 0.12, 0.09)
			vis.add_child(plank)
			var plank_sh = ColorRect.new()
			plank_sh.size = Vector2(1, T_SIZE)
			plank_sh.position = Vector2(i * 8, 0)
			plank_sh.color = Color(0.10, 0.06, 0.04)
			vis.add_child(plank_sh)
	
	# Big structural pillars on the outer edges OR holding up the base legs
	var draw_pillar = false
	var px = 0
	if is_left:
		draw_pillar = true; px = 0
	elif is_right:
		draw_pillar = true; px = T_SIZE - 12
	elif is_base_leg and randf() < 0.3:
		draw_pillar = true; px = T_SIZE / 2 - 6

	if draw_pillar:
		var pillar := ColorRect.new()
		pillar.size = Vector2(12, T_SIZE)
		pillar.position = Vector2(px, 0)
		pillar.color = Color(0.28, 0.18, 0.12)
		vis.add_child(pillar)
		
		# Edge highlight
		var highl := ColorRect.new()
		highl.size = Vector2(2, T_SIZE)
		highl.position = Vector2(px, 0)
		highl.color = Color(0.35, 0.25, 0.18)
		vis.add_child(highl)

	# Small decorative structural corner brace beneath platforms
	if not is_left and not is_right and not is_base_leg and has_platform and randf() < 0.6:
		var brace := Polygon2D.new()
		brace.color = Color(0.20, 0.14, 0.08)
		brace.polygon = PackedVector2Array([Vector2(0,0), Vector2(T_SIZE,0), Vector2(T_SIZE/2, 10)])
		vis.add_child(brace)
	
	parent.add_child(vis)
	
	if has_platform:
		var body := StaticBody2D.new(); body.position = Vector2(x, y)
		body.collision_layer = 2 # Scaffold layer map
		body.collision_mask = 0
		
		var poly := Polygon2D.new()
		poly.color = Color(0.40, 0.28, 0.18) # Solid continuous wood floor
		poly.polygon = PackedVector2Array([Vector2(0,0), Vector2(T_SIZE,0), Vector2(T_SIZE,8), Vector2(0,8)])
		body.add_child(poly)
		
		var trim := ColorRect.new()
		trim.size = Vector2(T_SIZE, 2)
		trim.color = Color(0.50, 0.38, 0.24)
		poly.add_child(trim)
		
		var col := CollisionPolygon2D.new()
		col.polygon = poly.polygon
		col.one_way_collision = true # CRITICAL! Allows players to jump through the solid floor seamlessly
		body.add_child(col)
		parent.add_child(body)
# PUBLIC API
# ============================================================
func get_spawn_point(index: int) -> Vector2:
	if spawn_points.is_empty(): return global_position + Vector2(float(GW)*0.5*T_SIZE, float(GH)*0.5*T_SIZE)
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

func _add_ore(parent: Node2D, x: float, y: float) -> void:
	# Spelunky style gold/diamond chunks embedded in caverock
	var colors = [Color(1.0, 0.84, 0.0), Color(0.8, 0.95, 1.0), Color(0.2, 0.8, 0.4)]
	var col = colors[randi() % colors.size()]
	
	var num_chunks = randi_range(3, 5)
	for j in range(num_chunks):
		var chunk = Polygon2D.new()
		chunk.color = col.darkened(randf_range(0.0, 0.3))
		# Irregular jewels instead of blocks
		var cx = randf_range(4.0, T_SIZE - 8.0)
		var cy = randf_range(4.0, T_SIZE - 8.0)
		var rad = randf_range(2.0, 6.0)
		var pts = PackedVector2Array()
		for a in range(5):
			var ang = float(a) * TAU / 5.0 + randf_range(-0.2, 0.2)
			pts.append(Vector2(cos(ang) * rad, sin(ang) * rad))
		chunk.polygon = pts
		chunk.position = Vector2(x + cx, y + cy)
		parent.add_child(chunk)

func _add_spikes(parent: Node2D, x: float, y: float, w: float) -> void:
	var area := Area2D.new(); area.position = Vector2(x, y); area.add_to_group("hazards")
	var base := ColorRect.new(); base.size = Vector2(w, 8); base.position = Vector2(0, 0)
	base.color = Color(0.15, 0.1, 0.12); area.add_child(base)
	
	var poly := Polygon2D.new(); poly.color = Color(0.72, 0.15, 0.15)
	var pts := PackedVector2Array(); pts.append(Vector2(0, 8))
	var count = int(w / 10.0)
	for i in range(count):
		pts.append(Vector2(float(i)*10.0+5.0, -8.0))
		pts.append(Vector2(float(i+1)*10.0, 8.0))
	poly.polygon = pts; area.add_child(poly)
	
	var col := CollisionShape2D.new(); var rect := RectangleShape2D.new()
	rect.size = Vector2(w, 12.0); col.shape = rect; col.position = Vector2(w*0.5, 2.0)
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

func _place_background_doors(grid: Array, run_seed: int) -> void:
	var p_rng := RandomNumberGenerator.new()
	p_rng.seed = run_seed + 99999
	
	var num_doors = p_rng.randi_range(3, 5)
	var placed = 0
	var door_script = load("res://src/items/door.gd")
	if not door_script: return
	
	for _attempt in range(150):
		if placed >= num_doors: break
		
		var x = p_rng.randi_range(10, GW - 10)
		var y = p_rng.randi_range(5, GH - 10)
		
		if not grid[x][y] and grid[x][y+1]: # Empty space with solid floor below
			var is_clear = true
			for cx in range(x-1, x+2):
				for cy in range(y-2, y+1):
					if grid[cx][cy]: is_clear = false
			if is_clear:
				var front_door = door_script.new()
				var back_door = door_script.new()
				
				var door_id = p_rng.randi()
				
				var bg_x = x * T_SIZE
				var bg_y = (y + 500) * T_SIZE
				
				front_door.global_position = Vector2(x * T_SIZE + 16, y * T_SIZE + 16)
				back_door.global_position = Vector2(bg_x + 16, bg_y + 16)
				
				_build_backroom_box(x, y + 500)
				
				front_door.set_link(back_door.global_position, door_id, false)
				back_door.set_link(front_door.global_position, door_id, true)
				
				add_child(front_door)
				add_child(back_door)
				placed += 1

func _build_backroom_box(cx: int, cy: int) -> void:
	var sb = StaticBody2D.new()
	var coll = CollisionPolygon2D.new()
	
	var r = 5.0
	var t = T_SIZE
	var pts = PackedVector2Array([
		Vector2((cx-r)*t, (cy-r)*t),
		Vector2((cx+r)*t, (cy-r)*t),
		Vector2((cx+r)*t, (cy+r)*t),
		Vector2((cx-r)*t, (cy+r)*t)
	])
	
	coll.polygon = pts
	coll.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	
	var poly = Polygon2D.new()
	poly.polygon = pts
	poly.color = Color(0.12, 0.08, 0.15)
	
	sb.add_child(poly)
	sb.add_child(coll)
	
	var wall_phys = CollisionPolygon2D.new()
	wall_phys.polygon = PackedVector2Array([
		Vector2((cx-r)*t - 100, (cy-r)*t - 100),
		Vector2((cx+r)*t + 100, (cy-r)*t - 100),
		Vector2((cx+r)*t + 100, (cy+r)*t + 100),
		Vector2((cx-r)*t - 100, (cy+r)*t + 100)
	])
	wall_phys.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	sb.add_child(wall_phys)
	
	var pl := PointLight2D.new()
	pl.texture = cached_glow_tex
	pl.color = Color(0.9, 0.7, 0.5)
	pl.energy = 0.5
	pl.global_position = Vector2(cx*t + 16, (cy-2)*t)
	pl.scale = Vector2(6.0, 6.0)
	
	sb.add_child(pl)
	add_child(sb)
