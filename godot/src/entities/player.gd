extends CharacterBody2D

const MOVE_SPEED := 220.0
const ACCEL := 1400.0
const FRICTION := 1800.0
const JUMP_VELOCITY := -430.0
const GRAVITY := 1100.0

@onready var body_poly: Polygon2D = $Body
@onready var name_label: Label = $Name
@onready var carry_label: Label = $Carry

var peer_id: int = 0
var carrying_artifact: bool = false
var visual_root: Node2D
var eyes: Node2D
var shadow: Polygon2D

func _ready() -> void:
	# Visual polish setup via script
	visual_root = Node2D.new()
	add_child(visual_root)
	
	# Move body_poly under visual_root for scaling
	remove_child(body_poly)
	visual_root.add_child(body_poly)
	
	shadow = Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.3)
	shadow.polygon = PackedVector2Array([-12, 19, 12, 19, 8, 23, -8, 23])
	add_child(shadow)
	
	eyes = Node2D.new()
	var eye_l = Polygon2D.new()
	eye_l.polygon = PackedVector2Array([-4, -4, 4, -4, 4, 4, -4, 4])
	eye_l.position = Vector2(-5, -6)
	eye_l.color = Color.WHITE
	
	var pupil_l = Polygon2D.new()
	pupil_l.polygon = PackedVector2Array([-2, -2, 2, -2, 2, 2, -2, 2])
	pupil_l.color = Color.BLACK
	eye_l.add_child(pupil_l)
	
	var eye_r = eye_l.duplicate(true)
	eye_r.position = Vector2(5, -6)
	
	eyes.add_child(eye_l)
	eyes.add_child(eye_r)
	visual_root.add_child(eyes)

func configure_for_peer(id_value: int) -> void:
	peer_id = id_value
	name_label.text = "P%d" % id_value
	var hue := float((id_value * 47) % 255) / 255.0
	body_poly.color = Color.from_hsv(hue, 0.75, 0.95)

func _process(delta: float) -> void:
	# Squash and stretch visually
	visual_root.scale.x = lerpf(visual_root.scale.x, 1.0, 10.0 * delta)
	visual_root.scale.y = lerpf(visual_root.scale.y, 1.0, 10.0 * delta)
	
	# Eye direction
	if velocity.x > 10:
		eyes.position.x = lerpf(eyes.position.x, 4.0, 15.0 * delta)
	elif velocity.x < -10:
		eyes.position.x = lerpf(eyes.position.x, -4.0, 15.0 * delta)
	else:
		eyes.position.x = lerpf(eyes.position.x, 0.0, 15.0 * delta)
		
	# Shadow visibility
	shadow.color.a = clampf(0.4 - (abs(velocity.y) / JUMP_VELOCITY) * 0.4, 0.0, 0.4)

func simulate_step(move_axis: float, jump_pressed: bool, delta: float) -> void:
	var target := move_axis * MOVE_SPEED
	if absf(target) > 0.01:
		velocity.x = move_toward(velocity.x, target, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Jump stretch
		visual_root.scale = Vector2(0.7, 1.3)

	var was_on_floor = is_on_floor()
	velocity.y += GRAVITY * delta
	move_and_slide()
	
	# Landing squash
	if not was_on_floor and is_on_floor():
		visual_root.scale = Vector2(1.3, 0.7)

func apply_snapshot(pos: Vector2, vel: Vector2, alpha: float = 0.35) -> void:
	global_position = global_position.lerp(pos, alpha)
	velocity = velocity.lerp(vel, alpha)

func set_carrying_artifact(carrying: bool) -> void:
	carrying_artifact = carrying
	carry_label.visible = carrying
	if carrying:
		carry_label.text = "ARTIFACT"
		carry_label.modulate = Color(1.0, 0.8, 0.2)
	else:
		carry_label.text = ""

func is_carrying_artifact() -> bool:
	return carrying_artifact
