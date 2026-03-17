extends Node2D

const CRUSHER_SCRIPT = preload("res://src/entities/crusher.gd")
const VISUAL_GOVERNANCE_SCRIPT = preload("res://src/visual/visual_governance.gd")

# ============================================================
# WORLD CONSTANTS
# ============================================================
const ROOM_COLUMNS := 5
const ROOM_ROWS := 3
const COLS := ROOM_COLUMNS
const ROWS := ROOM_ROWS
const ROOM_WIDTH  : float = 1024.0
const ROOM_HEIGHT : float = 768.0
const T_SIZE      : float = 32.0
const ROUTE_FAST_COLOR := Color(0.92, 0.62, 0.18, 0.22)
const ROUTE_SAFE_COLOR := Color(0.24, 0.72, 0.74, 0.18)
const ROUTE_WATCH_COLOR := Color(0.84, 0.82, 0.38, 0.18)
const ROUTE_DANGER_COLOR := Color(0.86, 0.22, 0.24, 0.18)

var GW : int       # global tile width  (160)
var GH : int       # global tile height  (72)
var CHUNK_W : int  # tiles per room wide  (32)
var CHUNK_H : int  # tiles per room tall  (24)

var indicator_by_slot      : Dictionary = {}
var indicator_time_left_by_slot : Dictionary = {}
var indicator_text_by_slot : Dictionary = {}
var indicator_color_by_slot : Dictionary = {}
var spawn_points : Array[Vector2] = []
var biome_noise  : FastNoiseLite
var cached_glow_tex : GradientTexture2D
var world_grid := []
var room_nodes_by_chunk: Dictionary = {}
var layer_roots: Dictionary = {}
var visual_profile_by_slot: Dictionary = {}
var visual_validation_failures: Array[String] = []
var visual_governance: RefCounted = VISUAL_GOVERNANCE_SCRIPT.new()
var current_protocol_state: String = "expedition"

func _ready() -> void:
	set_process(true)

func build_visual_doctrine_report_for_test() -> Dictionary:
	var background_failures: Array[String] = visual_governance.validate_background_layer(_layer_root("BackgroundLayer"))
	var doctrine_failures: Array[String] = []
	for room_root_raw in room_nodes_by_chunk.values():
		var room_root: Node2D = room_root_raw
		doctrine_failures.append_array(visual_governance.validate_doctrine_layer(_room_layer(room_root, "Doctrine")))
	return {
		"protocol_state": current_protocol_state,
		"layer_roots": layer_roots.keys().duplicate(),
		"profiles": visual_profile_by_slot.duplicate(true),
		"failures": visual_validation_failures.duplicate() + background_failures + doctrine_failures,
		"background_failures": background_failures,
		"doctrine_failures": doctrine_failures,
		"motion_hierarchy_failures": visual_governance.validate_motion_hierarchy()
	}

func _reset_visual_state() -> void:
	room_nodes_by_chunk.clear()
	layer_roots.clear()
	visual_profile_by_slot.clear()
	visual_validation_failures.clear()
	current_protocol_state = "expedition"

func _setup_visual_layers() -> void:
	_reset_visual_state()
	var layer_specs := [
		{"name": "BackgroundLayer", "z": -40},
		{"name": "MidgroundLayer", "z": -10},
		{"name": "ForegroundLayer", "z": 15},
		{"name": "OverlayLayer", "z": 40},
		{"name": "SecretLayer", "z": 5}
	]
	for spec_raw in layer_specs:
		var spec: Dictionary = spec_raw
		var layer := Node2D.new()
		layer.name = str(spec.get("name", "Layer"))
		layer.z_index = int(spec.get("z", 0))
		add_child(layer)
		layer_roots[layer.name] = layer

func _layer_root(name: String) -> Node2D:
	return layer_roots.get(name, null)

func _chunk_key(grid_x: int, grid_y: int) -> String:
	return "%d:%d" % [grid_x, grid_y]

func _ensure_room_root(grid_x: int, grid_y: int) -> Node2D:
	var key := _chunk_key(grid_x, grid_y)
	if room_nodes_by_chunk.has(key):
		return room_nodes_by_chunk[key]
	var room_root := Node2D.new()
	room_root.name = "Room_%d_%d" % [grid_x, grid_y]
	room_root.position = Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	var host := _layer_root("MidgroundLayer")
	if host == null:
		host = self
	host.add_child(room_root)
	for spec_raw in [
		{"name": "Background", "z": -5},
		{"name": "Midground", "z": 0},
		{"name": "Doctrine", "z": 3},
		{"name": "Foreground", "z": 5},
		{"name": "Overlay", "z": 10}
	]:
		var spec: Dictionary = spec_raw
		var layer := Node2D.new()
		layer.name = str(spec.get("name", "Layer"))
		layer.z_index = int(spec.get("z", 0))
		room_root.add_child(layer)
	room_nodes_by_chunk[key] = room_root
	return room_root

func _room_layer(room_root: Node2D, layer_name: String) -> Node2D:
	if room_root == null:
		return null
	var node := room_root.get_node_or_null(layer_name)
	return node if node is Node2D else room_root

func _room_visual_layers(room_root: Node2D) -> Dictionary:
	return {
		"background": _room_layer(room_root, "Background"),
		"midground": _room_layer(room_root, "Midground"),
		"doctrine": _room_layer(room_root, "Doctrine"),
		"foreground": _room_layer(room_root, "Foreground"),
		"overlay": _room_layer(room_root, "Overlay")
	}

# ============================================================
# MAIN ENTRY POINT
# ============================================================
func build_from_chain(room_chain: Array, run_seed: int = 99991) -> void:
	set_process(true)
	for child in get_children():
		child.free()
	indicator_by_slot.clear()
	indicator_time_left_by_slot.clear()
	indicator_text_by_slot.clear()
	indicator_color_by_slot.clear()
	spawn_points.clear()
	_setup_visual_layers()
	if not room_chain.is_empty():
		current_protocol_state = visual_governance.normalize_protocol_state(
			str(Dictionary(room_chain[0]).get("protocol_state", Dictionary(Dictionary(room_chain[0]).get("branch_context", {})).get("protocol_state", "expedition")))
		)

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
	_draw_background(room_chain, run_seed)

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
func _draw_background(room_chain: Array, run_seed: int) -> void:
	var world_w := float(COLS) * ROOM_WIDTH
	var world_h := float(ROWS) * ROOM_HEIGHT
	var dominant_room: Dictionary = Dictionary(room_chain[0]) if not room_chain.is_empty() else {}
	var packet: Dictionary = visual_governance.room_visual_packet(dominant_room)
	var visual_profile: Dictionary = Dictionary(packet.get("visual_profile", {}))
	var palette: Dictionary = Dictionary(visual_profile.get("palette", {}))
	var protocol_profile: Dictionary = Dictionary(visual_profile.get("protocol_profile", {}))
	var background_root: Node2D = _layer_root("BackgroundLayer")
	if background_root == null:
		background_root = self

	# Far-distance: deep void black
	var bg0 := Polygon2D.new()
	bg0.color = Color(palette.get("background", Color(0.04, 0.03, 0.05)))
	bg0.polygon = PackedVector2Array([Vector2(0,0), Vector2(world_w,0), Vector2(world_w,world_h), Vector2(0,world_h)])
	background_root.add_child(bg0)

	# Deep-distance suggestion: slightly lighter, offset — depth parallax feel
	var bg1 := Polygon2D.new()
	bg1.color = Color(palette.get("midground", Color(0.06, 0.05, 0.07, 1.0)))
	bg1.polygon = bg0.polygon.duplicate()
	bg1.position = Vector2(1, 1) # Parallax suggestion
	bg1.scale = Vector2.ONE * float(protocol_profile.get("background_scale", 1.0))
	background_root.add_child(bg1)

	# Parallax silhouettes: suggested depth with distant giant rock arches
	var parallax_root := Node2D.new()
	parallax_root.name = "ParallaxBack"
	background_root.add_child(parallax_root)
	
	var p_rng := RandomNumberGenerator.new(); p_rng.seed = run_seed + 12345
	var silhouette_count := 12 + int(round(float(packet.get("midground_density", 1.0)) * 4.0))
	for i in range(silhouette_count):
		var px := p_rng.randf_range(0, world_w)
		var py := p_rng.randf_range(0, world_h * 0.82)
		var pw := p_rng.randf_range(400, 1000)
		var ph := p_rng.randf_range(300, 600) * float(protocol_profile.get("background_scale", 1.0))
		var sil := Polygon2D.new()
		sil.color = Color(palette.get("background", Color(0.08, 0.07, 0.10, 0.5))).darkened(0.08)
		sil.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(pw, 0), Vector2(pw*1.3, ph), 
			Vector2(pw*0.5, ph*1.6), Vector2(-pw*0.3, ph)
		])
		sil.position = Vector2(px, py)
		sil.rotation = p_rng.randf_range(-0.5, 0.5)
		parallax_root.add_child(sil)

	# Cave darkness modulate — Truly dark exploration!
	var darkness := CanvasModulate.new()
	darkness.color = Color(palette.get("background", Color(0.12, 0.10, 0.13))).darkened(0.05)
	add_child(darkness)

# ============================================================
# STAGE 10: RENDER GLOBAL WALLS (Optimized with merging)
# ============================================================
func _render_all_walls(grid: Array) -> void:
	var wall_root := Node2D.new()
	wall_root.name = "Walls"
	var foreground_root := _layer_root("ForegroundLayer")
	if foreground_root == null:
		foreground_root = self
	foreground_root.add_child(wall_root)
	
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
	var room_node := _ensure_room_root(grid_x, grid_y)
	var background_layer := _room_layer(room_node, "Background")
	var midground_layer := _room_layer(room_node, "Midground")

	# Very subtle ambient biome tint
	var cx_t : int = sx + CHUNK_W / 2
	var cy_t : int = sy + CHUNK_H / 2
	var amb := _biome_ambient_at(cx_t, cy_t)
	var tint := Polygon2D.new()
	tint.color = Color(amb.r, amb.g, amb.b, 0.05)
	tint.polygon = PackedVector2Array([Vector2(0,0), Vector2(ROOM_WIDTH,0), Vector2(ROOM_WIDTH,ROOM_HEIGHT), Vector2(0,ROOM_HEIGHT)])
	background_layer.add_child(tint)

	_add_bioluminescence(midground_layer, grid, sx, sy, amb)
	_add_crystals(midground_layer, grid, sx, sy, amb)
	_add_vines(midground_layer, grid, sx, sy, amb)
	_add_ambient_atmosphere(midground_layer)
	_add_formations(midground_layer, grid, sx, sy, amb)

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
	var layers := _room_visual_layers(room_node)
	var background_layer: Node2D = layers.get("background", room_node)
	var midground_layer: Node2D = layers.get("midground", room_node)
	var doctrine_layer: Node2D = layers.get("doctrine", room_node)
	var foreground_layer: Node2D = layers.get("foreground", room_node)
	var overlay_layer: Node2D = layers.get("overlay", room_node)
	var visual_packet: Dictionary = visual_governance.room_visual_packet(room)
	var profile: Dictionary = Dictionary(visual_packet.get("visual_profile", {}))
	var palette: Dictionary = Dictionary(profile.get("palette", {}))
	visual_profile_by_slot[slot] = {
		"room": room.duplicate(true),
		"packet": visual_packet.duplicate(true)
	}
	for failure in visual_governance.validate_room_packet(visual_packet):
		visual_validation_failures.append("slot %d: %s" % [slot, failure])
	_apply_room_visual_identity(background_layer, midground_layer, doctrine_layer, foreground_layer, room, visual_packet, run_seed)

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
			_add_spikes(foreground_layer, float(valid_x)*T_SIZE, float(valid_y)*T_SIZE + T_SIZE - 8.0, 4.0 * T_SIZE)
	elif str(room.get("hazard", "")) == "collapse":
		_add_crusher(foreground_layer, Vector2(ROOM_WIDTH * 0.5 - 48.0, 72.0), Vector2(0, 224.0), slot)
	elif str(room.get("hazard", "")) == "push":
		_add_crusher(foreground_layer, Vector2(ROOM_WIDTH * 0.18, ROOM_HEIGHT * 0.5 - 48.0), Vector2(220.0, 0), slot)

	# Labels and Indicators
	var type_str : String = str(room.get("type", "?"))
	var label := Label.new(); label.position = Vector2(10, 10)
	label.text = _room_title(type_str)
	var cx_t : int = sx + CHUNK_W / 2
	var cy_t : int = sy + CHUNK_H / 2
	var amb := _biome_ambient_at(cx_t, cy_t)
	label.add_theme_color_override("font_color", Color(palette.get("accent", Color(amb.r, amb.g, amb.b, 0.4))))
	label.add_theme_font_size_override("font_size", 12)
	overlay_layer.add_child(label)
	var subtitle := Label.new()
	subtitle.position = Vector2(10, 28)
	subtitle.text = _room_subtitle(room)
	subtitle.add_theme_color_override("font_color", Color(palette.get("foreground", Color(amb.r, amb.g, amb.b, 0.3))))
	subtitle.add_theme_font_size_override("font_size", 10)
	overlay_layer.add_child(subtitle)

	var indicator := Label.new(); indicator.position = Vector2(ROOM_WIDTH - 48.0, 24.0)
	indicator.text = visual_governance.shell_symbol_for_symbol_family(str(Array(visual_packet.get("symbol_families", []))[0])) if not Array(visual_packet.get("symbol_families", [])).is_empty() else "!"
	indicator.visible = false
	indicator.modulate = Color(palette.get("accent", Color(1.0, 0.18, 0.2, 1.0)))
	indicator.add_theme_font_size_override("font_size", 32)
	overlay_layer.add_child(indicator)
	indicator_by_slot[slot]           = indicator
	indicator_time_left_by_slot[slot] = 0.0
	indicator_text_by_slot[slot] = indicator.text
	indicator_color_by_slot[slot] = indicator.modulate
	_render_room_micro_plan(room_node, room, run_seed)

func build_room_micro_plan_for_test(room: Dictionary, run_seed: int) -> Dictionary:
	return _build_room_micro_plan(room, run_seed)

func _room_title(room_type: String) -> String:
	match room_type:
		"traversal":
			return "Traversal Shaft"
		"hazard":
			return "Hazard Chokepoint"
		"evidence":
			return "Evidence Pocket"
		_:
			return room_type.capitalize()

func _room_subtitle(room: Dictionary) -> String:
	var branch_context: Dictionary = Dictionary(room.get("branch_context", {}))
	var pressure_profile := Array(branch_context.get("pressure_profile", []))
	if not pressure_profile.is_empty():
		if pressure_profile.has("hazard_commitment") or pressure_profile.has("collapse_watch"):
			return "Commitment pressure and visible recoveries"
		if pressure_profile.has("temptation_focus") or pressure_profile.has("risk_for_value"):
			return "Temptation pressure and contested carries"
		if pressure_profile.has("witness_high") or pressure_profile.has("witness_public"):
			return "Witness-heavy routes and public thresholds"
	match str(room.get("type", "")):
		"traversal":
			return "Split routes and regroup points"
		"hazard":
			return "Timing pressure and risky shortcuts"
		"evidence":
			return "Exposed pickup and contested exits"
		_:
			return ""

func _build_room_micro_plan(room: Dictionary, run_seed: int) -> Dictionary:
	var slot := int(room.get("slot", 0))
	var room_type := str(room.get("type", "traversal"))
	var room_id := str(room.get("id", ""))
	var hazard := str(room.get("hazard", ""))
	var mirrored := posmod(run_seed + slot * 17, 2) == 0
	var left_x := 160.0 if not mirrored else 672.0
	var right_x := 672.0 if not mirrored else 160.0
	var plan := {
		"platforms": [],
		"markers": [],
		"pedestal": {},
		"watch_light": Vector2(-1, -1)
	}
	match room_type:
		"traversal":
			plan["platforms"] = [
				{"x": left_x, "y": 236.0, "tiles": 4, "kind": "fast"},
				{"x": right_x, "y": 420.0, "tiles": 5, "kind": "safe"},
				{"x": ROOM_WIDTH * 0.5 - 64.0, "y": 564.0, "tiles": 4, "kind": "regroup"}
			]
			plan["markers"] = [
				{"x": left_x, "y": 228.0, "w": 160.0, "h": 12.0, "kind": "fast"},
				{"x": right_x, "y": 412.0, "w": 192.0, "h": 12.0, "kind": "safe"}
			]
		"evidence":
			plan["pedestal"] = {"x": ROOM_WIDTH * 0.5 - 80.0, "y": 332.0, "w": 160.0, "h": 18.0}
			plan["watch_light"] = Vector2(ROOM_WIDTH * 0.5, 286.0)
			plan["platforms"] = [
				{"x": left_x, "y": 232.0, "tiles": 4, "kind": "watch"},
				{"x": ROOM_WIDTH * 0.5 - 64.0, "y": 384.0, "tiles": 4, "kind": "exposed"},
				{"x": right_x, "y": 500.0, "tiles": 5, "kind": "safe"}
			]
			plan["markers"] = [
				{"x": ROOM_WIDTH * 0.5 - 88.0, "y": 352.0, "w": 176.0, "h": 14.0, "kind": "watch"},
				{"x": left_x, "y": 224.0, "w": 160.0, "h": 12.0, "kind": "fast"},
				{"x": right_x, "y": 492.0, "w": 192.0, "h": 12.0, "kind": "safe"}
			]
			if room_id == "evidence_gap":
				plan["platforms"].append({"x": right_x, "y": 272.0, "tiles": 3, "kind": "fast"})
			elif room_id == "evidence_choke":
				plan["platforms"].append({"x": left_x + 96.0, "y": 300.0, "tiles": 3, "kind": "watch"})
		"hazard":
			match hazard:
				"collapse":
					plan["platforms"] = [
						{"x": 176.0, "y": 196.0, "tiles": 3, "kind": "safe"},
						{"x": ROOM_WIDTH - 272.0, "y": 196.0, "tiles": 3, "kind": "safe"},
						{"x": ROOM_WIDTH * 0.5 - 80.0, "y": 476.0, "tiles": 5, "kind": "regroup"}
					]
					plan["markers"] = [
						{"x": ROOM_WIDTH * 0.5 - 88.0, "y": 84.0, "w": 176.0, "h": 308.0, "kind": "danger"},
						{"x": ROOM_WIDTH * 0.5 - 96.0, "y": 468.0, "w": 192.0, "h": 12.0, "kind": "safe"}
					]
				"push":
					plan["platforms"] = [
						{"x": 180.0, "y": 192.0, "tiles": 4, "kind": "safe"},
						{"x": ROOM_WIDTH - 340.0, "y": 280.0, "tiles": 4, "kind": "fast"},
						{"x": ROOM_WIDTH - 280.0, "y": 520.0, "tiles": 4, "kind": "regroup"}
					]
					plan["markers"] = [
						{"x": 160.0, "y": ROOM_HEIGHT * 0.5 - 72.0, "w": 320.0, "h": 144.0, "kind": "danger"},
						{"x": ROOM_WIDTH - 360.0, "y": 272.0, "w": 160.0, "h": 12.0, "kind": "fast"}
					]
				_:
					plan["platforms"] = [
						{"x": 204.0, "y": 228.0, "tiles": 4, "kind": "safe"},
						{"x": ROOM_WIDTH - 332.0, "y": 320.0, "tiles": 3, "kind": "fast"},
						{"x": ROOM_WIDTH - 280.0, "y": 548.0, "tiles": 4, "kind": "regroup"}
					]
					plan["markers"] = [
						{"x": ROOM_WIDTH * 0.5 - 180.0, "y": ROOM_HEIGHT - 112.0, "w": 360.0, "h": 18.0, "kind": "danger"},
						{"x": ROOM_WIDTH - 332.0, "y": 312.0, "w": 128.0, "h": 12.0, "kind": "fast"}
					]
	var branch_context: Dictionary = Dictionary(room.get("branch_context", {}))
	var pressure_profile := Array(branch_context.get("pressure_profile", []))
	var visual_packet: Dictionary = visual_governance.room_visual_packet(room)
	var stagecraft: Dictionary = Dictionary(visual_packet.get("stagecraft", {}))
	if pressure_profile.has("witness_high") or pressure_profile.has("witness_public"):
		Array(plan["markers"]).append({"x": ROOM_WIDTH * 0.5 - 128.0, "y": 148.0, "w": 256.0, "h": 10.0, "kind": "watch"})
	if pressure_profile.has("route_hard_commitment") or pressure_profile.has("route_staged_commitment"):
		Array(plan["markers"]).append({"x": ROOM_WIDTH * 0.5 - 96.0, "y": ROOM_HEIGHT - 144.0, "w": 192.0, "h": 10.0, "kind": "danger"})
	if pressure_profile.has("escape_broad") or pressure_profile.has("escape_swinging"):
		Array(plan["platforms"]).append({"x": ROOM_WIDTH * 0.5 - 48.0, "y": 308.0, "tiles": 3, "kind": "safe"})
	if bool(stagecraft.get("escort_lane", false)):
		Array(plan["markers"]).append({"x": ROOM_WIDTH * 0.5 - 42.0, "y": 156.0, "w": 84.0, "h": ROOM_HEIGHT - 260.0, "kind": "escort"})
	if bool(stagecraft.get("carrier_isolation", false)):
		Array(plan["markers"]).append({"x": ROOM_WIDTH * 0.5 - 112.0, "y": ROOM_HEIGHT * 0.58, "w": 224.0, "h": 18.0, "kind": "burden"})
	if bool(stagecraft.get("rescue_convergence", false)):
		Array(plan["markers"]).append({"x": ROOM_WIDTH * 0.5 - 120.0, "y": ROOM_HEIGHT * 0.44, "w": 240.0, "h": 12.0, "kind": "rescue"})
	if bool(stagecraft.get("confrontation_triangle", false)):
		Array(plan["markers"]).append({"x": ROOM_WIDTH * 0.5 - 132.0, "y": ROOM_HEIGHT * 0.30, "w": 264.0, "h": 10.0, "kind": "witness"})
	plan["branch_family_name"] = str(room.get("branch_family_name", ""))
	plan["branch_pressure_profile"] = pressure_profile.duplicate()
	plan["visual_packet"] = visual_packet.duplicate(true)
	return plan

func _render_room_micro_plan(room_node: Node2D, room: Dictionary, run_seed: int) -> void:
	var plan := _build_room_micro_plan(room, run_seed)
	var layers := _room_visual_layers(room_node)
	var doctrine_layer: Node2D = layers.get("doctrine", room_node)
	var midground_layer: Node2D = layers.get("midground", room_node)
	var foreground_layer: Node2D = layers.get("foreground", room_node)
	for marker_raw in Array(plan.get("markers", [])):
		var marker: Dictionary = marker_raw
		_add_route_marker(
			doctrine_layer,
			float(marker.get("x", 0.0)),
			float(marker.get("y", 0.0)),
			float(marker.get("w", 0.0)),
			float(marker.get("h", 0.0)),
			str(marker.get("kind", "safe"))
		)
	for platform_raw in Array(plan.get("platforms", [])):
		var platform: Dictionary = platform_raw
		_add_platform_run(
			foreground_layer,
			float(platform.get("x", 0.0)),
			float(platform.get("y", 0.0)),
			int(platform.get("tiles", 3)),
			str(platform.get("kind", "safe"))
		)
	var pedestal: Dictionary = plan.get("pedestal", {})
	if not pedestal.is_empty():
		_add_evidence_pedestal(
			doctrine_layer,
			float(pedestal.get("x", 0.0)),
			float(pedestal.get("y", 0.0)),
			float(pedestal.get("w", 160.0)),
			float(pedestal.get("h", 18.0))
		)
	var watch_light: Vector2 = plan.get("watch_light", Vector2(-1, -1))
	if watch_light.x >= 0.0:
		_add_focus_light(doctrine_layer, watch_light)

func _route_color(kind: String) -> Color:
	match kind:
		"fast":
			return ROUTE_FAST_COLOR
		"watch", "exposed":
			return ROUTE_WATCH_COLOR
		"escort":
			return ROUTE_WATCH_COLOR.lightened(0.12)
		"burden":
			return Color(0.96, 0.58, 0.24, 0.22)
		"rescue":
			return ROUTE_SAFE_COLOR.lightened(0.10)
		"witness":
			return Color(0.82, 0.78, 0.38, 0.18)
		"danger":
			return ROUTE_DANGER_COLOR
		_:
			return ROUTE_SAFE_COLOR

func _add_route_marker(parent: Node2D, x: float, y: float, w: float, h: float, kind: String) -> void:
	var color := _route_color(kind)
	_add_stage_strip(parent, Rect2(x, y, w, h), color, h * 0.55, 0.84)
	_add_stage_brackets(parent, Vector2(x + w * 0.5, y + h * 0.5), maxf(w - 18.0, 20.0), maxf(h * 1.6, 12.0), color.lightened(0.12))

func _add_platform_run(parent: Node2D, x: float, y: float, tiles: int, kind: String) -> void:
	var width := float(maxi(tiles, 1)) * T_SIZE
	_add_stage_strip(parent, Rect2(x, y - 8.0, width, 8.0), _route_color(kind).lightened(0.08), 4.0, 0.78)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			Vector2(x + 10.0, y - 7.0),
			Vector2(x + width - 10.0, y - 7.0)
		]),
		_route_color(kind).lightened(0.20),
		1.4,
		0.72
	)
	for i in range(maxi(tiles, 1)):
		_add_platform_tile(parent, x + float(i) * T_SIZE, y)

func _add_evidence_pedestal(parent: Node2D, x: float, y: float, w: float, h: float) -> void:
	var base := Polygon2D.new()
	base.color = Color(0.30, 0.22, 0.16, 0.82)
	base.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(w, 0), Vector2(w - 18.0, h), Vector2(18.0, h)
	])
	base.position = Vector2(x, y)
	parent.add_child(base)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			Vector2(x + 10.0, y - 2.0),
			Vector2(x + w - 10.0, y - 2.0)
		]),
		Color(0.70, 0.60, 0.34, 0.68),
		3.0
	)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			Vector2(x + 18.0, y + h * 0.52),
			Vector2(x - 2.0, y + h + 7.0),
			Vector2(x - 18.0, y + h + 7.0)
		]),
		Color(0.56, 0.44, 0.26, 0.48),
		1.8
	)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			Vector2(x + w - 18.0, y + h * 0.52),
			Vector2(x + w + 2.0, y + h + 7.0),
			Vector2(x + w + 18.0, y + h + 7.0)
		]),
		Color(0.56, 0.44, 0.26, 0.48),
		1.8
	)
	_add_stage_strip(parent, Rect2(x - 12.0, y + h + 1.0, w + 24.0, 8.0), ROUTE_WATCH_COLOR, 6.0, 0.62)

func _add_focus_light(parent: Node2D, world_pos: Vector2) -> void:
	var light := PointLight2D.new()
	light.texture = cached_glow_tex
	light.color = Color(0.94, 0.84, 0.54, 0.9)
	light.energy = 0.45
	light.scale = Vector2(1.6, 1.2)
	light.position = world_pos
	parent.add_child(light)

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
	var protocol_profile: Dictionary = Dictionary(Dictionary(visual_governance.branch_visual_profile("watcher_steps", current_protocol_state)).get("protocol_profile", {}))
	var dust := CPUParticles2D.new()
	dust.amount = 6 + int(round(float(protocol_profile.get("midground_density", 1.0)) * 4.0))
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
	dust.color = Color(0.7, 0.8, 1.0, lerpf(0.10, 0.18, float(protocol_profile.get("light_mult", 1.0)) / 1.2))
	parent.add_child(dust)

func _add_visual_dust(parent: Node2D, packet: Dictionary) -> void:
	var dust := CPUParticles2D.new()
	dust.amount = int(packet.get("particle_density", 10))
	dust.lifetime = 5.0
	dust.preprocess = 8.0
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(ROOM_WIDTH / 2.0, ROOM_HEIGHT / 2.0)
	dust.position = Vector2(ROOM_WIDTH * 0.5, ROOM_HEIGHT * 0.5)
	var weathering := float(Dictionary(packet.get("visual_profile", {})).get("weathering", 0.9))
	var weather_factor := clampf((weathering - 0.72) / 0.46, 0.0, 1.0)
	dust.gravity = Vector2(0, lerpf(1.1, 2.1, weather_factor))
	dust.direction = Vector2(1, 0.18 + weathering * 0.12)
	dust.spread = 180.0
	dust.initial_velocity_min = lerpf(3.0, 5.0, weather_factor)
	dust.initial_velocity_max = lerpf(8.0, 12.0, weather_factor)
	dust.scale_amount_min = 0.8
	dust.scale_amount_max = 2.2
	var palette: Dictionary = Dictionary(Dictionary(packet.get("visual_profile", {})).get("palette", {}))
	dust.color = Color(palette.get("midground", Color(0.7, 0.8, 1.0, 0.12))).lightened(0.1)
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

func _apply_room_visual_identity(background_layer: Node2D, midground_layer: Node2D, doctrine_layer: Node2D, foreground_layer: Node2D, room: Dictionary, packet: Dictionary, run_seed: int) -> void:
	if background_layer == null or midground_layer == null or foreground_layer == null:
		return
	var visual_profile: Dictionary = Dictionary(packet.get("visual_profile", {}))
	var palette: Dictionary = Dictionary(visual_profile.get("palette", {}))
	var far_shape := str(visual_profile.get("far_shape", "arches"))
	var mid_rhythm := str(visual_profile.get("mid_rhythm", "watch_ribs"))
	var symbols := Array(packet.get("symbol_families", []))
	var irregularity := float(visual_profile.get("macro_irregularity", 0.18))
	var scar_density := float(visual_profile.get("scar_density", 0.34))
	var anchor_spread := float(visual_profile.get("anchor_spread", 1.0))
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed * 131 + int(room.get("slot", 0)) * 17

	var macro_band := Node2D.new()
	macro_band.name = "FarMacro"
	background_layer.add_child(macro_band)
	var macro_count := 2 if float(packet.get("openness", 1.0)) < 0.9 else 3
	if irregularity > 0.26 and rng.randf() > 0.55:
		macro_count += 1
	var macro_origin := 48.0 + rng.randf_range(-36.0, 24.0) * (1.0 + irregularity)
	var macro_stride := (ROOM_WIDTH - 132.0) / maxf(float(maxi(macro_count - 1, 1)), 1.0)
	for i in range(macro_count):
		var poly := Polygon2D.new()
		poly.color = Color(palette.get("background", Color(0.08, 0.07, 0.10, 0.18))).lightened(0.06)
		var width := rng.randf_range(176.0, 348.0) * float(packet.get("landmark_scale", 1.0))
		var height := rng.randf_range(96.0, 228.0)
		match far_shape:
			"broken_spans":
				poly.polygon = PackedVector2Array([
					Vector2(0, 0), Vector2(width * 0.5, -height * 0.35), Vector2(width, 0),
					Vector2(width * 0.82, height), Vector2(width * 0.22, height * 0.9)
				])
			"terraces":
				poly.polygon = PackedVector2Array([
					Vector2(0, height), Vector2(width * 0.08, height * 0.62), Vector2(width * 0.34, height * 0.62),
					Vector2(width * 0.42, height * 0.28), Vector2(width * 0.66, height * 0.28), Vector2(width * 0.74, 0),
					Vector2(width, 0), Vector2(width, height)
				])
			"vaults", "vault_graves":
				poly.polygon = PackedVector2Array([
					Vector2(0, height), Vector2(width * 0.12, 0), Vector2(width * 0.88, 0), Vector2(width, height)
				])
			"warrens":
				poly.polygon = PackedVector2Array([
					Vector2(0, height * 0.92), Vector2(width * 0.12, height * 0.26), Vector2(width * 0.34, 0),
					Vector2(width * 0.68, height * 0.12), Vector2(width * 0.88, height * 0.42), Vector2(width, height)
				])
			"veins":
				poly.polygon = PackedVector2Array([
					Vector2(0, 0), Vector2(width * 0.5, -height * 0.2), Vector2(width, height * 0.08),
					Vector2(width * 0.68, height), Vector2(width * 0.12, height * 0.92)
				])
			_:
				poly.polygon = PackedVector2Array([
					Vector2(0, height), Vector2(width * 0.22, 0), Vector2(width * 0.78, 0), Vector2(width, height)
				])
		var macro_x := macro_origin + float(i) * macro_stride + rng.randf_range(-28.0, 26.0) * (1.0 + irregularity)
		var macro_y := 134.0 + rng.randf_range(-18.0, 26.0) * (1.0 + irregularity * 0.45)
		poly.position = Vector2(macro_x, macro_y)
		macro_band.add_child(poly)
		if rng.randf() < 0.72:
			_add_far_recess(
				macro_band,
				Vector2(macro_x + width * rng.randf_range(0.18, 0.72), macro_y + height * rng.randf_range(0.18, 0.42)),
				Vector2(width * rng.randf_range(0.08, 0.16), height * rng.randf_range(0.18, 0.34)),
				Color(palette.get("background", Color(0.08, 0.07, 0.10, 0.18))).darkened(0.18)
			)

	var frame := Node2D.new()
	frame.name = "MidgroundFrame"
	midground_layer.add_child(frame)
	var rhythm_count := 3 + int(round(float(packet.get("midground_density", 1.0)) * 2.0))
	for i in range(rhythm_count):
		var brace := Line2D.new()
		brace.width = 4.0
		brace.default_color = Color(palette.get("midground", Color(0.22, 0.26, 0.36, 0.45)))
		var x := 80.0 + float(i) * (ROOM_WIDTH - 160.0) / maxf(float(rhythm_count - 1), 1.0)
		x += rng.randf_range(-18.0, 18.0) * (0.4 + irregularity)
		match mid_rhythm:
			"fracture_struts":
				brace.points = PackedVector2Array([Vector2(x - 14.0, ROOM_HEIGHT), Vector2(x + 12.0, ROOM_HEIGHT * 0.42)])
			"oath_pillars":
				brace.points = PackedVector2Array([Vector2(x, ROOM_HEIGHT), Vector2(x, ROOM_HEIGHT * 0.22)])
			"relay_lanterns":
				brace.points = PackedVector2Array([Vector2(x, ROOM_HEIGHT), Vector2(x, ROOM_HEIGHT * 0.24)])
			"lattice":
				brace.points = PackedVector2Array([Vector2(x - 10.0, ROOM_HEIGHT), Vector2(x + 10.0, ROOM_HEIGHT * 0.36)])
			"murmur_threads":
				brace.points = PackedVector2Array([Vector2(x - 16.0, ROOM_HEIGHT * 0.86), Vector2(x + 12.0, ROOM_HEIGHT * 0.18)])
			"forge_channels":
				brace.points = PackedVector2Array([Vector2(x - 18.0, ROOM_HEIGHT * 0.85), Vector2(x + 18.0, ROOM_HEIGHT * 0.24)])
			_:
				brace.points = PackedVector2Array([Vector2(x, ROOM_HEIGHT), Vector2(x, ROOM_HEIGHT * 0.32)])
		frame.add_child(brace)
		if rng.randf() < scar_density:
			_add_stage_trace(
				frame,
				PackedVector2Array([
					Vector2(x - 6.0, ROOM_HEIGHT * rng.randf_range(0.36, 0.72)),
					Vector2(x + rng.randf_range(8.0, 14.0), ROOM_HEIGHT * rng.randf_range(0.34, 0.74))
				]),
				Color(palette.get("midground", Color(0.22, 0.26, 0.36, 0.45))).darkened(0.18),
				1.2,
				0.34
			)
	_add_structural_scars(frame, palette, packet, rng, scar_density)

	var symbol_layer := Node2D.new()
	symbol_layer.name = "CloseSymbols"
	doctrine_layer.add_child(symbol_layer)
	var anchors: Array[Vector2] = [
		Vector2(112.0, ROOM_HEIGHT - 124.0),
		Vector2(ROOM_WIDTH * 0.5, ROOM_HEIGHT - 156.0),
		Vector2(ROOM_WIDTH - 112.0, ROOM_HEIGHT - 124.0)
	]
	for i in range(mini(symbols.size(), anchors.size())):
		var symbol_family := str(symbols[i])
		var anchor: Vector2 = anchors[i] + visual_governance.symbol_anchor_offset(symbol_family, int(packet.get("room_slot", 0)), i, anchor_spread)
		_add_symbol_carving(symbol_layer, anchor, symbol_family)
	_add_social_stagecraft(doctrine_layer, packet)
	_add_visual_dust(midground_layer, packet)

func _add_symbol_carving(parent: Node2D, pos: Vector2, symbol_family: String) -> void:
	var scar := Polygon2D.new()
	scar.color = visual_governance.symbol_color(symbol_family).darkened(0.55)
	scar.color.a = 0.14
	scar.polygon = visual_governance.symbol_plate_points(symbol_family, 1.12)
	scar.position = pos
	parent.add_child(scar)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			pos + Vector2(-14.0, -10.0),
			pos + Vector2(14.0, -10.0)
		]),
		visual_governance.symbol_color(symbol_family).darkened(0.22),
		1.4,
		0.46
	)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			pos + Vector2(-10.0, 8.0),
			pos + Vector2(10.0, 8.0)
		]),
		visual_governance.symbol_color(symbol_family).darkened(0.34),
		1.1,
		0.34
	)
	for segment_raw in visual_governance.symbol_segments(symbol_family):
		var segment: Array = segment_raw
		if segment.size() < 2:
			continue
		var a: Vector2 = segment[0]
		var b: Vector2 = segment[1]
		_add_stage_trace(
			parent,
			PackedVector2Array([pos + a, pos + b]),
			visual_governance.symbol_color(symbol_family).darkened(0.08),
			2.1,
			0.92
		)

func _add_social_stagecraft(doctrine_layer: Node2D, packet: Dictionary) -> void:
	var stagecraft: Dictionary = Dictionary(packet.get("stagecraft", {}))
	var center_x := ROOM_WIDTH * 0.5 + _packet_visual_phase(packet, 22.0)
	var center_y := ROOM_HEIGHT * 0.54 + _packet_visual_phase(packet, 12.0, 23)
	var flank_bias := _packet_visual_phase(packet, 18.0, 91)
	if bool(stagecraft.get("escort_lane", false)):
		var lane_x := center_x + flank_bias * 0.18
		_add_stage_strip(doctrine_layer, Rect2(lane_x - 18.0, 148.0, 36.0, ROOM_HEIGHT - 266.0), ROUTE_WATCH_COLOR, 8.0, 0.64)
		_add_stage_trace(
			doctrine_layer,
			PackedVector2Array([
				Vector2(lane_x, 152.0),
				Vector2(lane_x, ROOM_HEIGHT - 120.0)
			]),
			ROUTE_WATCH_COLOR.lightened(0.18),
			1.6,
			0.62
		)
		_add_stage_brackets(doctrine_layer, Vector2(lane_x, ROOM_HEIGHT * 0.38 + _packet_visual_phase(packet, 8.0, 97)), 88.0, 24.0, ROUTE_WATCH_COLOR.lightened(0.14))
	if bool(stagecraft.get("carrier_isolation", false)):
		var isolation_y := center_y + _packet_visual_phase(packet, 8.0, 101)
		_add_stage_strip(doctrine_layer, Rect2(center_x - 90.0 + flank_bias * 0.12, isolation_y, 180.0, 14.0), ROUTE_DANGER_COLOR, 12.0, 0.56)
		_add_stage_trace(
			doctrine_layer,
			PackedVector2Array([
				Vector2(center_x - 72.0 + flank_bias * 0.08, isolation_y + 4.0),
				Vector2(center_x + 72.0 + flank_bias * 0.08, isolation_y + 4.0)
			]),
			ROUTE_DANGER_COLOR.lightened(0.12),
			1.6,
			0.56
		)
		_add_stage_brackets(doctrine_layer, Vector2(center_x + flank_bias * 0.16, ROOM_HEIGHT * 0.61 + _packet_visual_phase(packet, 10.0, 29)), 164.0, 28.0, ROUTE_DANGER_COLOR.lightened(0.10))
	if bool(stagecraft.get("rescue_convergence", false)):
		for index in range(2):
			var x := ROOM_WIDTH * (0.28 if index == 0 else 0.72) + _packet_visual_phase(packet, 18.0 if index == 0 else -18.0, 41 + index) + flank_bias * (0.08 if index == 0 else -0.08)
			var y := ROOM_HEIGHT * 0.42 + 6.0 + _packet_visual_phase(packet, 8.0, 51 + index)
			_add_stage_brackets(doctrine_layer, Vector2(x, y), 76.0, 18.0, ROUTE_SAFE_COLOR.lightened(0.12))
			_add_stage_strip(doctrine_layer, Rect2(x - 26.0, y - 6.0, 52.0, 5.0), ROUTE_SAFE_COLOR, 5.0, 0.54)
	if bool(stagecraft.get("confrontation_triangle", false)):
		_add_open_triangle(
			doctrine_layer,
			[
				Vector2(ROOM_WIDTH * 0.32 + _packet_visual_phase(packet, 14.0, 61), ROOM_HEIGHT * 0.56 + _packet_visual_phase(packet, 9.0, 67)),
				Vector2(ROOM_WIDTH * 0.68 + _packet_visual_phase(packet, -14.0, 71), ROOM_HEIGHT * 0.56 + _packet_visual_phase(packet, 7.0, 73)),
				Vector2(center_x, ROOM_HEIGHT * 0.28 + _packet_visual_phase(packet, 12.0, 79))
			],
			ROUTE_DANGER_COLOR.lightened(0.10)
		)
	if bool(stagecraft.get("suspicious_distance", false)):
		var suspect_y := ROOM_HEIGHT * 0.66 + 4.0 + _packet_visual_phase(packet, 6.0, 83)
		_add_stage_brackets(doctrine_layer, Vector2(center_x - 52.0 + flank_bias * 0.2, suspect_y), 40.0, 14.0, ROUTE_WATCH_COLOR.darkened(0.08))
		_add_stage_brackets(doctrine_layer, Vector2(center_x + 52.0 + flank_bias * 0.2, suspect_y), 40.0, 14.0, ROUTE_WATCH_COLOR.darkened(0.08))
		_add_stage_trace(
			doctrine_layer,
			PackedVector2Array([
				Vector2(center_x - 22.0 + flank_bias * 0.2, suspect_y),
				Vector2(center_x + 22.0 + flank_bias * 0.2, suspect_y)
			]),
			ROUTE_WATCH_COLOR.darkened(0.14),
			1.2,
			0.38
		)

func _packet_visual_phase(packet: Dictionary, magnitude: float, salt: int = 17) -> float:
	var slot := int(packet.get("room_slot", 0))
	var phase_seed := slot * 97 + salt
	return sin(float(phase_seed)) * magnitude

func _add_stage_strip(parent: Node2D, rect: Rect2, color: Color, slant: float = 0.0, alpha_scale: float = 1.0) -> void:
	var strip := Polygon2D.new()
	var tint := color
	tint.a *= alpha_scale
	strip.color = tint
	var bevel := minf(maxf(rect.size.y * 0.52, 2.0), maxf(rect.size.x * 0.14, 2.0))
	strip.polygon = PackedVector2Array([
		Vector2(bevel, 0),
		Vector2(rect.size.x - bevel, 0),
		Vector2(rect.size.x + slant, rect.size.y * 0.5),
		Vector2(rect.size.x - bevel, rect.size.y),
		Vector2(bevel + slant, rect.size.y),
		Vector2(slant, rect.size.y * 0.5)
	])
	strip.position = rect.position
	parent.add_child(strip)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			rect.position + Vector2(bevel + 2.0, rect.size.y * 0.3),
			rect.position + Vector2(rect.size.x - bevel - 2.0, rect.size.y * 0.3)
		]),
		color.lightened(0.18),
		1.4,
		alpha_scale * 0.74
	)
	_add_stage_trace(
		parent,
		PackedVector2Array([
			rect.position + Vector2(bevel + slant + 4.0, rect.size.y * 0.74),
			rect.position + Vector2(rect.size.x - bevel + slant - 4.0, rect.size.y * 0.74)
		]),
		color.darkened(0.16),
		1.2,
		alpha_scale * 0.42
	)

func _add_stage_trace(parent: Node2D, points: PackedVector2Array, color: Color, width: float = 2.0, alpha_scale: float = 1.0) -> void:
	if points.size() < 2:
		return
	var trace := Line2D.new()
	trace.width = width
	trace.antialiased = true
	var tint := color
	tint.a *= alpha_scale
	trace.default_color = tint
	trace.points = points
	parent.add_child(trace)

func _add_far_recess(parent: Node2D, center: Vector2, size: Vector2, color: Color) -> void:
	var recess := Polygon2D.new()
	var recess_color := color
	recess_color.a = 0.18
	recess.color = recess_color
	recess.polygon = PackedVector2Array([
		Vector2(-size.x, size.y * 0.42),
		Vector2(-size.x * 0.42, -size.y),
		Vector2(size.x * 0.42, -size.y),
		Vector2(size.x, size.y * 0.42)
	])
	recess.position = center
	parent.add_child(recess)

func _add_structural_scars(parent: Node2D, palette: Dictionary, packet: Dictionary, rng: RandomNumberGenerator, scar_density: float) -> void:
	var scar_count := maxi(1, int(round(scar_density * 4.0)))
	for index in range(scar_count):
		var start := Vector2(
			rng.randf_range(48.0, ROOM_WIDTH - 48.0),
			rng.randf_range(ROOM_HEIGHT * 0.26, ROOM_HEIGHT * 0.78)
		)
		var finish := start + Vector2(rng.randf_range(-28.0, 28.0), rng.randf_range(-14.0, 20.0))
		_add_stage_trace(
			parent,
			PackedVector2Array([start, finish]),
			Color(palette.get("midground", Color(0.22, 0.26, 0.36, 0.45))).darkened(0.22),
			1.0 + float(index % 2) * 0.2,
			0.26 + _packet_visual_phase(packet, 0.06, 143 + index)
		)

func _add_stage_brackets(parent: Node2D, center: Vector2, span: float, height: float, color: Color) -> void:
	var half_span := span * 0.5
	for direction in [-1.0, 1.0]:
		var dirf: float = direction
		var anchor: Vector2 = center + Vector2(half_span * dirf, 0.0)
		var outer: float = 14.0 * dirf
		_add_stage_trace(
			parent,
			PackedVector2Array([
				anchor + Vector2(outer, -height * 0.5),
				anchor,
				anchor + Vector2(outer, height * 0.5)
			]),
			color,
			2.0
		)
		_add_stage_trace(
			parent,
			PackedVector2Array([
				anchor + Vector2(outer * 0.45, 0.0),
				anchor + Vector2(outer * 0.9, 0.0)
			]),
			color.lightened(0.10),
			1.2,
			0.72
		)

func _add_open_triangle(parent: Node2D, points: Array[Vector2], color: Color) -> void:
	for index in range(points.size()):
		var next_index := (index + 1) % points.size()
		var a := points[index]
		var b := points[next_index]
		var direction := (b - a).normalized()
		_add_stage_trace(
			parent,
			PackedVector2Array([
				a + direction * 10.0,
				b - direction * 10.0
			]),
			color,
			2.5
		)

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
	return room_nodes_by_chunk.get(_chunk_key(grid_x, grid_y), null)

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

func flash_room_indicator(room_slot: int, label: String, color: Color, duration_sec: float = 0.3) -> void:
	if not indicator_time_left_by_slot.has(room_slot):
		return
	indicator_time_left_by_slot[room_slot] = maxf(float(indicator_time_left_by_slot[room_slot]), duration_sec)
	indicator_text_by_slot[room_slot] = label
	indicator_color_by_slot[room_slot] = color
	var ind: Label = indicator_by_slot.get(room_slot, null)
	if ind:
		ind.text = label
		ind.modulate = color
		ind.visible = true

func flash_hazard_indicator(room_slot: int, duration_sec: float = 0.3) -> void:
	flash_room_indicator(room_slot, "!", Color(1.0, 0.18, 0.2, 1.0), duration_sec)

func _process(delta: float) -> void:
	for slot in indicator_time_left_by_slot.keys():
		var left : float = float(indicator_time_left_by_slot[slot]) - delta
		indicator_time_left_by_slot[slot] = maxf(left, 0.0)
		var ind : Label = indicator_by_slot.get(slot, null)
		if ind:
			if left > 0.0:
				ind.text = str(indicator_text_by_slot.get(slot, "!"))
				ind.modulate = Color(indicator_color_by_slot.get(slot, Color(1.0, 0.18, 0.2, 1.0)))
				ind.visible = true
			else:
				ind.text = "!"
				ind.modulate = Color(1.0, 0.18, 0.2, 1.0)
				ind.visible = false

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

func _add_crusher(parent: Node2D, anchor: Vector2, travel: Vector2, slot: int) -> void:
	var crusher := CRUSHER_SCRIPT.new()
	crusher.name = "Crusher_%d" % slot
	crusher.configure(anchor, travel, slot * 23)
	parent.add_child(crusher)

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
	var secret_root := _layer_root("SecretLayer")
	if secret_root == null:
		secret_root = self
	
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
				
				secret_root.add_child(front_door)
				secret_root.add_child(back_door)
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
	var secret_root := _layer_root("SecretLayer")
	if secret_root == null:
		secret_root = self
	secret_root.add_child(sb)
