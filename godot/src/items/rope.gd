extends Node2D
class_name SpelunkyRope

var velocity := Vector2(0, -600.0)
var state := 0 # 0 = flying, 1 = attached
var hook_pos := Vector2.ZERO
var max_up := 300.0 # ~9.3 tiles up
var max_down := 540.0 # ~16.8 tiles down
var start_y := 0.0
var line: Line2D
var climb_area: Area2D
var climb_col: CollisionShape2D

@rpc("any_peer", "call_local", "reliable")
func rpc_deploy(top_pos: Vector2, bottom_y: float) -> void:
	if state == 1: return
	state = 1
	global_position = top_pos
	
	if line: line.clear_points()
	else:
		line = Line2D.new()
		line.default_color = Color(0.8, 0.7, 0.5)
		line.width = 4.0
		add_child(line)
		
	var rope_len = abs(bottom_y - top_pos.y)
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2(0, rope_len))
	
	climb_area = Area2D.new()
	# Set climbing layer to something specific. We'll use collision layer 4 mask (value 8) for ropes
	climb_area.collision_layer = 8
	climb_area.collision_mask = 0
	
	climb_col = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(8, rope_len)
	climb_col.shape = rect
	climb_col.position = Vector2(0, rope_len * 0.5)
	climb_area.add_child(climb_col)
	add_child(climb_area)

func _ready() -> void:
	start_y = global_position.y
	line = Line2D.new()
	line.default_color = Color(0.8, 0.7, 0.5)
	line.width = 4.0
	add_child(line)

func _physics_process(delta: float) -> void:
	if state == 0 and is_multiplayer_authority():
		var old_pos = global_position
		global_position += velocity * delta
		
		var space_state = get_world_2d().direct_space_state
		var q = PhysicsRayQueryParameters2D.create(old_pos, global_position)
		q.collision_mask = 1 # walls
		var result = space_state.intersect_ray(q)
		var deployed := false
		var top_p := global_position
		
		if result:
			top_p = result.position
			deployed = true
		elif start_y - global_position.y >= max_up:
			top_p = global_position
			deployed = true
			
		if deployed:
			# Raycast downward to see if it hits floor
			var bot_q = PhysicsRayQueryParameters2D.create(top_p, top_p + Vector2(0, max_down))
			bot_q.collision_mask = 1
			var bot_res = space_state.intersect_ray(bot_q)
			var bot_y = bot_res.position.y if bot_res else top_p.y + max_down
			rpc_deploy.rpc(top_p, bot_y)
			
	elif state == 0:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2(0, 10))

