extends Node2D

@onready var core: Polygon2D = $Core
@onready var label: Label = $Label

var artifact_id: int = 0
var room_slot: int = -1
var signature: String = ""
var is_forged: bool = false
var owner_peer_id: int = 0

func configure(data: Dictionary) -> void:
	artifact_id = int(data.get("artifact_id", 0))
	room_slot = int(data.get("room_slot", -1))
	signature = str(data.get("signature", ""))
	is_forged = bool(data.get("is_forged", false))
	owner_peer_id = int(data.get("owner_peer_id", 0))
	global_position = data.get("world_pos", Vector2.ZERO)
	_apply_visuals()

func sync_state(data: Dictionary) -> void:
	owner_peer_id = int(data.get("owner_peer_id", 0))
	signature = str(data.get("signature", signature))
	is_forged = bool(data.get("is_forged", is_forged))
	if owner_peer_id == 0:
		global_position = data.get("world_pos", global_position)
	_apply_visuals()

func set_visual_position(pos: Vector2) -> void:
	global_position = pos

func _apply_visuals() -> void:
	if is_forged:
		core.color = Color(0.92, 0.57, 0.59, 1.0)
	else:
		core.color = Color(0.67, 0.90, 0.72, 1.0)
	var short_sig := signature.right(maxi(signature.length() - 4, 0))
	label.text = "E%d %s" % [artifact_id, short_sig]
