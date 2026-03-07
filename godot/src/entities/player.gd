extends CharacterBody2D

const MOVE_SPEED := 420.0
const ACCEL := 2000.0
const FRICTION := 2000.0
const JUMP_VELOCITY := -680.0
const GRAVITY := 1500.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER_TIME := 0.12

@onready var body_poly: Polygon2D = $Body
@onready var name_label: Label = $Name
@onready var carry_label: Label = $Carry

var peer_id: int = 0
var carrying_artifact: bool = false
var visual_root: Node2D
var eyes: Node2D
var shadow: Polygon2D

var hand_l: Polygon2D
var hand_r: Polygon2D
var foot_l: Polygon2D
var foot_r: Polygon2D

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_jump_pressed := false
var has_double_jumped := false
var whip_visual: Line2D
var whip_timer := 0.0
var wall_grab_latch := 0.0  # stays > 0 for a short window after whip swing
var whip_ray: RayCast2D
var net_pos: Vector2
var net_vel: Vector2
var net_initialized := false

var health: int = 3
var dead: bool = false
var hazard_detector: Area2D
var light: PointLight2D
var camera: Camera2D
var shake_intensity: float = 0.0
var dust: CPUParticles2D

func _ready() -> void:
	visual_root = Node2D.new()
	add_child(visual_root)
	
	remove_child(body_poly)
	
	# Remodel body into character shape
	body_poly.polygon = PackedVector2Array([
		Vector2(-9, -12), Vector2(9, -12), Vector2(13, -2), Vector2(13, 8), 
		Vector2(10, 16), Vector2(-10, 16), Vector2(-13, 8), Vector2(-13, -2)
	])
	visual_root.add_child(body_poly)
	
	var head = Polygon2D.new()
	head.polygon = PackedVector2Array([
		Vector2(-10, -26), Vector2(10, -26), Vector2(14, -18), Vector2(14, -10), 
		Vector2(10, -2), Vector2(-10, -2), Vector2(-14, -10), Vector2(-14, -18)
	])
	body_poly.add_child(head)
	
	shadow = Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.3)
	shadow.polygon = PackedVector2Array([-12, 19, 12, 19, 8, 23, -8, 23])
	add_child(shadow)
	
	hand_l = Polygon2D.new()
	hand_l.polygon = PackedVector2Array([-4, -4, 4, -4, 4, 4, -4, 4])
	visual_root.add_child(hand_l)

	hand_r = hand_l.duplicate(true)
	visual_root.add_child(hand_r)

	foot_l = hand_l.duplicate(true)
	visual_root.add_child(foot_l)

	foot_r = hand_l.duplicate(true)
	visual_root.add_child(foot_r)
	
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

	# Hazard detector
	hazard_detector = Area2D.new()
	var col2 = CollisionShape2D.new()
	var rect2 = RectangleShape2D.new()
	rect2.size = Vector2(24, 34)
	col2.shape = rect2
	hazard_detector.add_child(col2)
	add_child(hazard_detector)
	hazard_detector.area_entered.connect(_on_hazard_entered)
	
	# Main player lantern — warm golden illumination
	var gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient.colors = PackedColorArray([Color(1,1,1,1), Color(0,0,0,1)])
	var tex = GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 256; tex.height = 256
	light = PointLight2D.new()
	light.texture = tex
	light.color = Color(1.0, 0.85, 0.55)   # warm lantern yellow
	light.energy = 2.2
	light.scale = Vector2(4.0, 4.0)
	light.shadow_enabled = true
	light.shadow_color = Color(0, 0, 0, 0.7)
	add_child(light)

	# Soft ambient fill — cool-tinted, wide radius, low energy
	var tex2 = GradientTexture2D.new()
	tex2.gradient = gradient; tex2.fill = GradientTexture2D.FILL_RADIAL
	tex2.fill_from = Vector2(0.5, 0.5); tex2.fill_to = Vector2(1.0, 0.5)
	tex2.width = 256; tex2.height = 256
	var ambient_light := PointLight2D.new()
	ambient_light.texture = tex2
	ambient_light.color = Color(0.55, 0.60, 0.80)  # cool blue-purple ambient
	ambient_light.energy = 0.45
	ambient_light.scale = Vector2(7.0, 7.0)
	add_child(ambient_light)

	# Particles
	dust = CPUParticles2D.new()
	dust.emitting = false
	dust.one_shot = true
	dust.explosiveness = 1.0
	dust.amount = 8
	dust.direction = Vector2(0, -1)
	dust.spread = 90.0
	dust.initial_velocity_min = 20.0
	dust.initial_velocity_max = 60.0
	dust.scale_amount_min = 2.0
	dust.scale_amount_max = 6.0
	dust.color = Color(0.8, 0.8, 0.8, 0.5)
	dust.position = Vector2(0, 19)
	add_child(dust)

	whip_visual = Line2D.new()
	whip_visual.default_color = Color(0.45, 0.22, 0.06)
	whip_visual.width = 3.0
	whip_visual.begin_cap_mode = Line2D.LINE_CAP_ROUND
	whip_visual.end_cap_mode = Line2D.LINE_CAP_ROUND
	whip_visual.antialiased = true
	# 8 segments for smooth curve during animation
	for _i in range(8):
		whip_visual.add_point(Vector2.ZERO)
	whip_visual.visible = false
	whip_visual.position = Vector2(8, 0)
	visual_root.add_child(whip_visual)
	
	whip_ray = RayCast2D.new()
	whip_ray.enabled = false
	whip_ray.collision_mask = 1 # World layer
	add_child(whip_ray)

	# Initialize network targets to current position to prevent corner dragging
	net_pos = global_position
	net_vel = Vector2.ZERO
	net_initialized = false

func _on_hazard_entered(area: Area2D) -> void:
	if dead: return
	if area.is_in_group("hazards"):
		health -= 1
		velocity.y = -350
		velocity.x = -sign(velocity.x) * 200
		shake_intensity = 15.0
		var net = get_node_or_null("/root/NetworkManager")
		if health <= 0:
			dead = true
			if net and carrying_artifact:
				net.request_drop()
			modulate = Color(1.0, 1.0, 1.0, 0.4)
		else:
			modulate = Color(1.0, 0.2, 0.2, 1.0)
			get_tree().create_timer(0.3).timeout.connect(func(): if not dead: modulate = Color.WHITE)

func configure_for_peer(id_value: int) -> void:
	peer_id = id_value
	set_multiplayer_authority(id_value) # CRITICAL: Ensure player controls themselves
	name_label.text = "P%d" % id_value
	var hue := float((id_value * 47) % 255) / 255.0
	var base_color = Color.from_hsv(hue, 0.75, 0.95)
	body_poly.color = base_color
	
	var head = body_poly.get_child(0)
	if head:
		head.color = base_color.lightened(0.15)
		
	var limb_color = base_color.darkened(0.2)
	hand_l.color = limb_color
	hand_r.color = limb_color
	foot_l.color = limb_color
	foot_r.color = limb_color
	
	var net = get_node_or_null("/root/NetworkManager")
	if net and net.get_multiplayer().has_multiplayer_peer() and net.get_multiplayer().get_unique_id() == id_value:
		camera = Camera2D.new()
		camera.zoom = Vector2(1.2, 1.2)
		camera.position_smoothing_enabled = true
		add_child(camera)

func _process(delta: float) -> void:
	if camera and shake_intensity > 0.1:
		camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = lerpf(shake_intensity, 0.0, 10.0 * delta)
	elif camera:
		camera.offset = Vector2.ZERO

	if not is_multiplayer_authority() and net_initialized:
		# Dynamic interpolation: adjust and buffer targets for fluid network motion
		var dist = global_position.distance_to(net_pos)
		if dist > 400.0:
			global_position = net_pos
			velocity = net_vel
		elif dist > 1.0:
			var lerp_alpha = 14.0 * delta
			# Soften the position lerp to absorb jitter
			global_position = global_position.lerp(net_pos, lerp_alpha)
			velocity = velocity.lerp(net_vel, lerp_alpha * 0.8)

	visual_root.scale.x = lerpf(visual_root.scale.x, 1.0, 10.0 * delta)
	visual_root.scale.y = lerpf(visual_root.scale.y, 1.0, 10.0 * delta)
	
	if velocity.x > 10:
		eyes.position.x = lerpf(eyes.position.x, 4.0, 15.0 * delta)
	elif velocity.x < -10:
		eyes.position.x = lerpf(eyes.position.x, -4.0, 15.0 * delta)
	else:
		eyes.position.x = lerpf(eyes.position.x, 0.0, 15.0 * delta)

	var local_uid = get_node_or_null("/root/NetworkManager").get_multiplayer().get_unique_id() if get_node_or_null("/root/NetworkManager") and get_node_or_null("/root/NetworkManager").get_multiplayer().has_multiplayer_peer() else 0
	if Input.is_key_pressed(KEY_X) and whip_timer <= 0.0 and peer_id == local_uid and not dead:
		whip_timer = 0.40
		wall_grab_latch = 0.65  # whip duration + 0.25s latch window
		
	if whip_timer > 0.0:
		whip_timer -= delta
		whip_visual.visible = true
		var dir = 1.0 if eyes.position.x >= 0 else -1.0
		var progress : float = 1.0 - (whip_timer / 0.40)  # 0→1 over lifetime
		
		# Animate each of the 8 points based on progress
		var seg_count := whip_visual.get_point_count()
		var total_reach := 70.0   # max horizontal extent (kept short to avoid wall clipping)
		# Check for wall collision to clip whip reach
		whip_ray.target_position = Vector2(total_reach * dir, -5.0)
		whip_ray.enabled = true
		whip_ray.force_raycast_update()
		
		var draw_reach := total_reach
		if whip_ray.is_colliding():
			var hit_pos = whip_ray.get_collision_point()
			draw_reach = global_position.distance_to(hit_pos) - 5.0
		
		whip_ray.enabled = false

		for i in range(seg_count):
			var frac = float(i) / float(seg_count - 1)
			
			# How far along has THIS segment unrolled?
			var seg_progress = clampf((progress - frac * 0.4) / 0.5, 0.0, 1.0)
			
			# X: starts coiled behind, extends forward, constrained by draw_reach
			var base_x = lerpf(-10.0, draw_reach * frac, seg_progress) * dir
			
			# Y: starts low (coiled), rises to wave shape, then snaps flat
			var wave = sin(frac * PI * 2.5 - progress * PI * 3.0) * (1.0 - seg_progress) * 20.0
			var snap_y = 0.0
			if progress > 0.7:
				# Snap phase — tip whips downward then rebounds
				var snap_t = (progress - 0.7) / 0.3
				snap_y = sin(snap_t * PI) * 14.0 * frac
			var base_y = wave + snap_y - frac * 4.0
			
			whip_visual.set_point_position(i, Vector2(base_x, base_y))
		
		# Width tapers toward tip
		var curve := Curve.new()
		curve.add_point(Vector2(0.0, 3.5))
		curve.add_point(Vector2(1.0, 0.8))
		whip_visual.width_curve = curve
	else:
		whip_visual.visible = false
		
	shadow.color.a = clampf(0.4 - (abs(velocity.y) / JUMP_VELOCITY) * 0.4, 0.0, 0.4)
	
	var time = Time.get_ticks_msec() / 1000.0
	if dead:
		foot_l.position = Vector2(-6.0, 19.0)
		foot_r.position = Vector2(6.0, 19.0)
		hand_l.position = Vector2(-12.0, 4.0)
		hand_r.position = Vector2(12.0, 4.0)
		body_poly.rotation = sin(time * 2.0) * 0.2
	elif is_on_floor():
		if absf(velocity.x) > 10.0:
			var cycle = time * 20.0
			foot_l.position = Vector2(-6.0 + sin(cycle) * 8.0, 19.0 + cos(cycle) * 4.0)
			foot_r.position = Vector2(6.0 + sin(cycle + PI) * 8.0, 19.0 + cos(cycle + PI) * 4.0)
			hand_l.position = Vector2(-12.0, 4.0 + sin(cycle + PI) * 6.0)
			hand_r.position = Vector2(12.0, 4.0 + sin(cycle) * 6.0)
			body_poly.rotation = sin(cycle) * 0.05
		else:
			foot_l.position = Vector2(-6.0, 19.0)
			foot_r.position = Vector2(6.0, 19.0)
			hand_l.position = Vector2(-12.0, 4.0 + sin(time * 3.0) * 2.0)
			hand_r.position = Vector2(12.0, 4.0 + cos(time * 3.0) * 2.0)
			body_poly.rotation = lerp_angle(body_poly.rotation, 0.0, 10.0 * delta)
	else:
		foot_l.position = Vector2(-6.0, 15.0 - clampf(velocity.y / 50.0, -10.0, 10.0))
		foot_r.position = Vector2(6.0, 17.0 - clampf(velocity.y / 50.0, -10.0, 10.0))
		hand_l.position = Vector2(-12.0, -4.0)
		hand_r.position = Vector2(12.0, -8.0)
		body_poly.rotation = lerp_angle(body_poly.rotation, velocity.x * 0.001, 10.0 * delta)

func simulate_step(move_axis: float, jump_pressed: bool, delta: float) -> void:
	if dead:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		velocity.y = move_toward(velocity.y, -100.0, ACCEL * delta * 0.2)
		var cw = is_on_floor()
		move_and_slide()
		return

	if is_on_floor():
		coyote_timer = COYOTE_TIME
		has_double_jumped = false
	else:
		coyote_timer -= delta
		
	if jump_pressed and not was_jump_pressed:
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta
		
	var just_released_jump = not jump_pressed and was_jump_pressed
	was_jump_pressed = jump_pressed

	var target := move_axis * MOVE_SPEED
	if absf(target) > 0.01:
		velocity.x = move_toward(velocity.x, target, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	# Wall grab latch timer
	if wall_grab_latch > 0.0:
		wall_grab_latch -= delta

	var is_grabbing_wall = false
	if is_on_wall() and velocity.y > -50 and move_axis != 0 and wall_grab_latch > 0.0:
		is_grabbing_wall = true
		# "Hang" effect: very slow descent if pressing towards wall during latch
		velocity.y = min(velocity.y, 20.0) 
		has_double_jumped = false

	if jump_buffer_timer > 0.0:
		if coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0
			coyote_timer = 0.0
			visual_root.scale = Vector2(0.7, 1.3)
			dust.restart()
		elif is_grabbing_wall:
			velocity.y = JUMP_VELOCITY * 0.9
			velocity.x = -sign(move_axis) * 350.0
			jump_buffer_timer = 0.0
			visual_root.scale = Vector2(1.2, 0.8)
			dust.restart()
		elif not has_double_jumped and not is_on_floor():
			velocity.y = JUMP_VELOCITY * 1.15
			jump_buffer_timer = 0.0
			has_double_jumped = true
			visual_root.scale = Vector2(0.5, 1.5)
			dust.restart()
		
	if just_released_jump and velocity.y < 0:
		velocity.y *= 0.5 

	var was_on_floor = is_on_floor()
	if not is_grabbing_wall:
		velocity.y += GRAVITY * delta
	move_and_slide()
	
	if not was_on_floor and is_on_floor():
		visual_root.scale = Vector2(1.3, 0.7)
		dust.restart()
		if velocity.y > 800:
			shake_intensity = 5.0


func apply_snapshot(pos: Vector2, vel: Vector2, _alpha: float = 0.0) -> void:
	# Update networked targets.
	if not net_initialized:
		global_position = pos
		net_initialized = true
	
	net_pos = pos
	net_vel = vel
	# If within 4px, don't lerp at all — prevents micro-jitter

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
