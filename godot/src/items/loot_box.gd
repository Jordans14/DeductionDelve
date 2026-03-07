extends StaticBody2D
class_name SpelunkyLootBox

var health := 1

func _ready() -> void:
	collision_layer = 1
	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 24)
	col.shape = rect
	add_child(col)
	
	var visual = Polygon2D.new()
	visual.color = Color(0.6, 0.4, 0.2) # Wooden brown
	visual.polygon = PackedVector2Array([Vector2(-12,-12), Vector2(12,-12), Vector2(12,12), Vector2(-12,12)])
	add_child(visual)

@rpc("any_peer", "call_local", "reliable")
func rpc_break() -> void:
	# Spawns loot, visually breaks
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var type = "bomb" if rng.randf() < 0.5 else "rope"
	var amount = rng.randi_range(2, 4)
	
	var pickup = preload("res://src/items/pickup.gd").new()
	pickup.type = type
	pickup.amount = amount
	pickup.global_position = global_position
	get_parent().add_child(pickup)
	
	queue_free()

func apply_damage(amt: int) -> void:
	health -= amt
	if health <= 0 and is_multiplayer_authority():
		rpc_break.rpc()
