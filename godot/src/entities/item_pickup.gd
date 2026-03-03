extends Node2D

@onready var core: Polygon2D = $Core
@onready var label: Label = $Label

var item_id: int = 0
var item_def_id: String = ""
var display_name: String = ""
var owner_peer_id: int = 0
var consumed: bool = false

func configure(data: Dictionary) -> void:
	item_id = int(data.get("item_id", 0))
	item_def_id = str(data.get("item_def_id", ""))
	display_name = str(data.get("display_name", item_def_id))
	owner_peer_id = int(data.get("owner_peer_id", 0))
	consumed = bool(data.get("consumed", false))
	global_position = data.get("world_pos", Vector2.ZERO)
	_apply_visuals()

func sync_state(data: Dictionary) -> void:
	owner_peer_id = int(data.get("owner_peer_id", 0))
	consumed = bool(data.get("consumed", consumed))
	display_name = str(data.get("display_name", display_name))
	item_def_id = str(data.get("item_def_id", item_def_id))
	if owner_peer_id == 0:
		global_position = data.get("world_pos", global_position)
	_apply_visuals()

func set_visual_position(pos: Vector2) -> void:
	global_position = pos

func _apply_visuals() -> void:
	visible = not consumed and owner_peer_id == 0
	if not visible:
		return
	core.color = Color(0.93, 0.81, 0.36, 1.0)
	if label:
		label.text = display_name
