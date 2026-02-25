class_name RoleService
extends RefCounted

const ROLE_WARDEN := "Warden"
const ROLE_VEIL := "Veil"
const ROLE_SCAVENGER := "Scavenger"

func assign_roles(peer_ids: Array[int], seed_value: int) -> Dictionary:
	var ids := peer_ids.duplicate()
	ids.sort()

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value ^ 0x5F3759DF

	var role_pool: Array[String] = [ROLE_WARDEN, ROLE_VEIL, ROLE_SCAVENGER]
	while role_pool.size() < ids.size():
		var roll := rng.randi_range(0, 3)
		if roll == 0:
			role_pool.append(ROLE_WARDEN)
		elif roll == 1:
			role_pool.append(ROLE_VEIL)
		else:
			role_pool.append(ROLE_SCAVENGER)

	_shuffle_array(role_pool, rng)

	var result: Dictionary = {}
	for i in ids.size():
		result[ids[i]] = role_pool[i]
	return result

func build_private_role_payload(role_name: String) -> Dictionary:
	return {"role": role_name}

func _shuffle_array(items: Array, rng: RandomNumberGenerator) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = items[i]
		items[i] = items[j]
		items[j] = tmp
