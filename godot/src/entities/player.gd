extends CharacterBody2D

const MOVE_SPEED := 220.0
const ACCEL := 1400.0
const FRICTION := 1800.0
const JUMP_VELOCITY := -430.0
const GRAVITY := 1100.0

@onready var body_poly: Polygon2D = $Body
@onready var name_label: Label2D = $Name
@onready var carry_label: Label2D = $Carry

var peer_id: int = 0

func configure_for_peer(id_value: int) -> void:
	peer_id = id_value
	name_label.text = "P%d" % id_value
	var hue := float((id_value * 47) % 255) / 255.0
	body_poly.color = Color.from_hsv(hue, 0.75, 0.95)

func simulate_step(move_axis: float, jump_pressed: bool, delta: float) -> void:
	var target := move_axis * MOVE_SPEED
	if absf(target) > 0.01:
		velocity.x = move_toward(velocity.x, target, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity.y += GRAVITY * delta
	move_and_slide()

func apply_snapshot(pos: Vector2, vel: Vector2, alpha: float = 0.35) -> void:
	global_position = global_position.lerp(pos, alpha)
	velocity = velocity.lerp(vel, alpha)

func set_carrying_artifact(carrying: bool) -> void:
	carry_label.visible = carrying
