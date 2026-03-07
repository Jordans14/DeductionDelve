extends Area2D

var type := "bomb" # "bomb" or "rope"
var amount := 3
var life_timer := 60.0 # despawns after 60s
var velocity := Vector2(0, -150)
var gravity := 600.0

@rpc("any_peer", "call_local", "reliable")
func rpc_collect() -> void:
	queue_free()

func _ready() -> void:
	# Bounces a little out of the box
	velocity.x = randf_range(-100, 100)
	collision_mask = 1 # world
	collision_layer = 0
	
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	col.shape = rect
	add_child(col)
	
	var visual = Polygon2D.new()
	if type == "bomb":
		visual.color = Color(0.2, 0.2, 0.2) # Black bag
	else:
		visual.color = Color(0.8, 0.7, 0.4) # Tan rope pile
	visual.polygon = PackedVector2Array([Vector2(-6,-6), Vector2(6,-6), Vector2(8,6), Vector2(-8,6)])
	add_child(visual)
	
	body_entered.connect(_on_body_entered)
	# Also need monitorable setup to let player grab it
	monitorable = true
	monitoring = true

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	global_position += velocity * delta
	
	# Basic floor stop
	var space = get_world_2d().direct_space_state
	var q = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, 8))
	q.collision_mask = 1
	var hit = space.intersect_ray(q)
	if hit:
		global_position.y = hit.position.y - 8
		velocity = Vector2.ZERO
		
	life_timer -= delta
	if life_timer <= 0: queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("add_spelunky_item"):
		body.add_spelunky_item(type, amount)
		if is_multiplayer_authority() or body.is_multiplayer_authority():
			rpc_collect.rpc()
