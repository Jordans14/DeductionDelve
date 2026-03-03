class_name ItemService
extends RefCounted

const PICKUP_RANGE := 68.0

const ITEM_IDS: Array[String] = [
	"soft_boots",
	"grease_rag",
	"mule_strap",
	"chalk_seal"
]

const ITEM_DEFS := {
	"soft_boots": {
		"display_name": "Soft Boots",
		"tags": ["stealth"],
		"noise_trace_interval": 120
	},
	"grease_rag": {
		"display_name": "Grease Rag",
		"tags": ["sabotage"],
		"disturbance_duration_sec": 3.5
	},
	"mule_strap": {
		"display_name": "Mule Strap",
		"tags": ["logistics"],
		"carry_speed_mult": 1.12,
		"noise_trace_interval": 45
	},
	"chalk_seal": {
		"display_name": "Chalk Seal",
		"tags": ["forensics"],
		"warden_score_bonus": 6
	}
}

func generate_item_spawns(seed_value: int, room_chain: Array) -> Array:
	var items: Array = []
	var next_id := 1
	for room in room_chain:
		var slot := int(room.get("slot", -1))
		if slot < 0 or slot % 2 != 0:
			continue
		var item_def_id := ITEM_IDS[posmod(seed_value + slot, ITEM_IDS.size())]
		items.append({
			"item_id": next_id,
			"item_def_id": item_def_id,
			"display_name": str(get_definition(item_def_id).get("display_name", item_def_id)),
			"room_slot": slot,
			"owner_peer_id": 0,
			"world_pos": Vector2(128 + 520 * slot, 262),
			"consumed": false
		})
		next_id += 1
	return items

func get_definition(item_def_id: String) -> Dictionary:
	return ITEM_DEFS.get(item_def_id, {})

func get_display_name(item_def_id: String) -> String:
	return str(get_definition(item_def_id).get("display_name", item_def_id))

func can_pickup(item_data: Dictionary, player_pos: Vector2, max_range: float = PICKUP_RANGE) -> bool:
	if bool(item_data.get("consumed", false)):
		return false
	if int(item_data.get("owner_peer_id", 0)) != 0:
		return false
	var pos: Vector2 = item_data.get("world_pos", Vector2.ZERO)
	return pos.distance_to(player_pos) <= max_range

func apply_owner(item_data: Dictionary, owner_peer_id: int, world_pos: Vector2) -> Dictionary:
	var next := item_data.duplicate(true)
	next["owner_peer_id"] = owner_peer_id
	next["world_pos"] = world_pos
	return next

func consume(item_data: Dictionary) -> Dictionary:
	var next := item_data.duplicate(true)
	next["consumed"] = true
	next["owner_peer_id"] = 0
	return next

func noise_trace_interval_for_items(item_def_ids: Array[String]) -> int:
	var has_soft_boots := item_def_ids.has("soft_boots")
	var has_mule_strap := item_def_ids.has("mule_strap")
	if has_soft_boots and has_mule_strap:
		return 70
	if has_mule_strap:
		return int(get_definition("mule_strap").get("noise_trace_interval", 60))
	if has_soft_boots:
		return int(get_definition("soft_boots").get("noise_trace_interval", 120))
	return 90

func carry_speed_multiplier_for_items(item_def_ids: Array[String]) -> float:
	if item_def_ids.has("mule_strap"):
		return float(get_definition("mule_strap").get("carry_speed_mult", 1.0))
	return 1.0

func sabotage_disturbance_duration_for_items(item_def_ids: Array[String]) -> float:
	if item_def_ids.has("grease_rag"):
		return float(get_definition("grease_rag").get("disturbance_duration_sec", 2.0))
	return 2.0

func warden_score_bonus_for_items(item_def_ids: Array[String], room_recently_disturbed: bool) -> int:
	var bonus := 0
	if item_def_ids.has("chalk_seal") and room_recently_disturbed:
		bonus += int(get_definition("chalk_seal").get("warden_score_bonus", 0))
	return bonus

