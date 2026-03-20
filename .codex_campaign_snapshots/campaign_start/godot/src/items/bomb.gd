extends RigidBody2D
class_name SpelunkyBomb

var timer := 2.5
var visual: Polygon2D
var flash_timer := 0.0

@rpc("authority", "call_local", "reliable")
func rpc_explode(pos: Vector2) -> void:
	explode_local(pos)

func explode_local(pos: Vector2) -> void:
	var rb = get_node_or_null("/root/Game/Rooms")
	if rb and rb.has_method("carve_hole"):
		rb.carve_hole(pos, 65.0) # ~2 tile radius — destructive but not overwhelming

	# Blast physics / Damage
	var parent = get_parent()
	if parent:
		_spawn_scorch_mark(parent, pos)
		var blast = Polygon2D.new()
		blast.color = Color(1.0, 0.5, 0.1, 0.8)
		blast.polygon = _build_circle(100)
		blast.position = pos
		parent.add_child(blast)
		var tween = blast.create_tween()
		tween.tween_property(blast, "color:a", 0.0, 0.3)
		tween.tween_callback(blast.queue_free)

		# apply impulse to players
		for child in parent.get_children():
			if child.has_method("simulate_step") and child is CharacterBody2D:
				var dist = child.global_position.distance_to(pos)
				if dist < 80.0:
					var dir = (child.global_position - pos).normalized()
					child.velocity += dir * (80.0 - dist) * 15.0
					if child.has_method("apply_damage"): child.apply_damage(1) # pseudo damage

	# Record explosion event for tracing
	if NetworkManager.is_host:
		NetworkManager.record_public_event("bomb_exploded", NetworkManager.get_room_slot(pos), -1, {})

	queue_free()

func _spawn_scorch_mark(parent: Node, pos: Vector2) -> void:
	var scorch := Polygon2D.new()
	scorch.color = Color(0.14, 0.08, 0.06, 0.55)
	scorch.position = pos
	scorch.polygon = PackedVector2Array([
		Vector2(-34, -12), Vector2(-18, -24), Vector2(10, -22), Vector2(30, -8),
		Vector2(26, 10), Vector2(8, 18), Vector2(-20, 16), Vector2(-36, 4)
	])
	parent.add_child(scorch)
	var tween = scorch.create_tween()
	tween.tween_interval(12.0)
	tween.tween_property(scorch, "color:a", 0.0, 2.0)
	tween.tween_callback(scorch.queue_free)

func _build_circle(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var segments := 16
	for i in range(segments):
		var ang = float(i) / float(segments) * TAU
		pts.append(Vector2(cos(ang)*r, sin(ang)*r))
	return pts

func _ready() -> void:
	# RigidBody config
	gravity_scale = 1.0
	mass = 1.0
	collision_layer = 0
	collision_mask = 1 # hits walls
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.4
	physics_material_override.friction = 0.5

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 6.0
	col.shape = shape
	add_child(col)

	visual = Polygon2D.new()
	visual.color = Color(0.1, 0.1, 0.1) # Black bomb
	visual.polygon = _build_circle(6.0)
	add_child(visual)

func _process(delta: float) -> void:
	timer -= delta
	flash_timer += delta
	# Flashing effect
	var flash_speed = 3.0 if timer > 1.0 else 15.0
	if sin(flash_timer * flash_speed) > 0.0:
		visual.color = Color(1.0, 0.2, 0.0)
	else:
		visual.color = Color(0.1, 0.1, 0.1)

	var mp := get_multiplayer()
	var has_peer := mp != null and mp.multiplayer_peer != null
	if timer <= 0.0 and has_peer and is_multiplayer_authority():
		var network_manager = get_node_or_null("/root/NetworkManager")
		if network_manager and network_manager.has_method("host_detonate_bomb"):
			network_manager.host_detonate_bomb.rpc(name, global_position)
		else:
			explode_local(global_position)
