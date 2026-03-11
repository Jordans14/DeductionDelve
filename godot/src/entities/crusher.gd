extends Area2D
class_name CrushBlockTrap

const EXTEND_TICKS := 45
const HOLD_TICKS := 24
const RETRACT_TICKS := 45
const CYCLE_TICKS := 180

var base_position: Vector2 = Vector2.ZERO
var travel_vector: Vector2 = Vector2.ZERO
var phase_offset: int = 0

func _ready() -> void:
	add_to_group("hazards")
	collision_layer = 1
	collision_mask = 0
	if get_child_count() == 0:
		_build_visuals()
	set_physics_process(true)

func configure(anchor: Vector2, travel: Vector2, phase: int = 0) -> void:
	base_position = anchor
	travel_vector = travel
	phase_offset = phase
	position = anchor

func _physics_process(_delta: float) -> void:
	position = base_position + travel_vector * _travel_fraction_for_tick(_network_tick())

func travel_fraction_for_tick_for_test(tick: int) -> float:
	return _travel_fraction_for_tick(tick)

func _travel_fraction_for_tick(tick: int) -> float:
	var cycle_tick := posmod(tick + phase_offset, CYCLE_TICKS)
	if cycle_tick < EXTEND_TICKS:
		return float(cycle_tick) / float(EXTEND_TICKS)
	if cycle_tick < EXTEND_TICKS + HOLD_TICKS:
		return 1.0
	if cycle_tick < EXTEND_TICKS + HOLD_TICKS + RETRACT_TICKS:
		var retract_tick := cycle_tick - EXTEND_TICKS - HOLD_TICKS
		return 1.0 - float(retract_tick) / float(RETRACT_TICKS)
	return 0.0

func _network_tick() -> int:
	var net = get_node_or_null("/root/NetworkManager")
	if net == null:
		return 0
	if bool(net.get("is_host")):
		return int(net.get("current_server_tick"))
	return int(net.get("latest_tick"))

func _build_visuals() -> void:
	var poly := Polygon2D.new()
	poly.color = Color(0.58, 0.12, 0.12)
	poly.polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(96, 0),
		Vector2(96, 96),
		Vector2(0, 96)
	])
	add_child(poly)

	var glow := Polygon2D.new()
	glow.color = Color(0.95, 0.35, 0.18, 0.22)
	glow.polygon = PackedVector2Array([
		Vector2(-8, -8),
		Vector2(104, -8),
		Vector2(104, 104),
		Vector2(-8, 104)
	])
	add_child(glow)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(96, 96)
	col.shape = rect
	col.position = Vector2(48, 48)
	add_child(col)
