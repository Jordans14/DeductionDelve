class_name RoleService
extends RefCounted

const ROLE_WARDEN := "Warden"
const ROLE_VEIL := "Veil"
const ROLE_SCAVENGER := "Scavenger"
const ALIGNMENT_EXPEDITION := "expedition"
const ALIGNMENT_SABOTEUR := "saboteur"

func assign_roles(peer_ids: Array[int], seed_value: int) -> Dictionary:
	var ids := peer_ids.duplicate()
	ids.sort()
	if ids.is_empty():
		return {}

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value ^ 0x5F3759DF

	var counts := role_counts_for_player_count(ids.size())
	var role_pool: Array[String] = []
	for _i in range(int(counts.get("warden", 0))):
		role_pool.append(ROLE_WARDEN)
	for _i in range(int(counts.get("veil", 0))):
		role_pool.append(ROLE_VEIL)
	while role_pool.size() < ids.size():
		role_pool.append(ROLE_SCAVENGER)

	_shuffle_array(role_pool, rng)

	var result: Dictionary = {}
	for i in ids.size():
		result[ids[i]] = role_pool[i]
	return result

func role_counts_for_player_count(player_count: int) -> Dictionary:
	if player_count <= 0:
		return {"warden": 0, "veil": 0, "scavenger": 0}
	if player_count == 1:
		return {"warden": 1, "veil": 0, "scavenger": 0}
	if player_count <= 8:
		return {"warden": 1, "veil": 1, "scavenger": maxi(player_count - 2, 0)}
	return {"warden": 1, "veil": 2, "scavenger": maxi(player_count - 3, 0)}

func alignment_for_role(role_name: String) -> String:
	if role_name == ROLE_VEIL:
		return ALIGNMENT_SABOTEUR
	return ALIGNMENT_EXPEDITION

func goal_text_for_role(role_name: String) -> String:
	match role_name:
		ROLE_WARDEN:
			return "Help extract authentic artifacts and reconstruct what happened."
		ROLE_VEIL:
			return "Sabotage the expedition and make failure look ambiguous."
		ROLE_SCAVENGER:
			return "Survive the descent and help authentic artifacts reach extraction."
		_:
			return "Survive the cavern and read the clues."

func role_wins(role_name: String, expedition_success: bool, sabotage_success: bool) -> bool:
	if role_name == ROLE_VEIL:
		return sabotage_success
	return expedition_success

func build_private_role_payload(role_name: String) -> Dictionary:
	return {"role": role_name}

func _shuffle_array(items: Array, rng: RandomNumberGenerator) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = items[i]
		items[i] = items[j]
		items[j] = tmp
