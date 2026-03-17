class_name RoleService
extends RefCounted

const ROLE_WARDEN := "Warden"
const ROLE_VEIL := "Veil"
const ROLE_SCAVENGER := "Scavenger"
const ROLE_STEWARD := "Steward"
const ROLE_BEARER := "Bearer"
const ROLE_MURMUR := "Murmur"
const ALIGNMENT_EXPEDITION := "expedition"
const ALIGNMENT_SABOTEUR := "saboteur"

func all_role_names() -> Array[String]:
	return [
		ROLE_WARDEN,
		ROLE_STEWARD,
		ROLE_BEARER,
		ROLE_SCAVENGER,
		ROLE_VEIL,
		ROLE_MURMUR
	]

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
	for _i in range(int(counts.get("steward", 0))):
		role_pool.append(ROLE_STEWARD)
	for _i in range(int(counts.get("bearer", 0))):
		role_pool.append(ROLE_BEARER)
	for _i in range(int(counts.get("veil", 0))):
		role_pool.append(ROLE_VEIL)
	for _i in range(int(counts.get("murmur", 0))):
		role_pool.append(ROLE_MURMUR)
	while role_pool.size() < ids.size():
		role_pool.append(ROLE_SCAVENGER)

	_shuffle_array(role_pool, rng)

	var result: Dictionary = {}
	for i in ids.size():
		result[ids[i]] = role_pool[i]
	return result

func role_counts_for_player_count(player_count: int) -> Dictionary:
	var counts := {
		"warden": 0,
		"steward": 0,
		"bearer": 0,
		"veil": 0,
		"murmur": 0,
		"scavenger": 0
	}
	if player_count <= 0:
		return counts
	if player_count == 1:
		counts["warden"] = 1
		return counts
	if player_count == 2:
		counts["warden"] = 1
		counts["veil"] = 1
		return counts
	if player_count == 3:
		counts["warden"] = 1
		counts["veil"] = 1
		counts["scavenger"] = 1
		return counts
	if player_count <= 5:
		counts["warden"] = 1
		counts["veil"] = 1
		counts["steward"] = 1
		counts["scavenger"] = maxi(player_count - 3, 0)
		return counts
	if player_count <= 7:
		counts["warden"] = 1
		counts["veil"] = 1
		counts["steward"] = 1
		counts["bearer"] = 1
		counts["scavenger"] = maxi(player_count - 4, 0)
		return counts
	counts["warden"] = 1
	counts["veil"] = 1
	counts["murmur"] = 1
	counts["steward"] = 1
	counts["bearer"] = 1
	counts["scavenger"] = maxi(player_count - 5, 0)
	return counts

func alignment_for_role(role_name: String) -> String:
	if role_name == ROLE_VEIL or role_name == ROLE_MURMUR:
		return ALIGNMENT_SABOTEUR
	return ALIGNMENT_EXPEDITION

func can_forge(role_name: String) -> bool:
	return role_name == ROLE_VEIL or role_name == ROLE_MURMUR

func can_sabotage(role_name: String) -> bool:
	return role_name == ROLE_VEIL

func can_inspect(role_name: String) -> bool:
	return role_name == ROLE_WARDEN

func goal_text_for_role(role_name: String) -> String:
	match role_name:
		ROLE_WARDEN:
			return "Help extract authentic artifacts and reconstruct what happened."
		ROLE_STEWARD:
			return "Keep contested custody legible long enough for the expedition to believe the right answer."
		ROLE_BEARER:
			return "Move authentic custody through danger and make the extraction line hold."
		ROLE_VEIL:
			return "Sabotage the expedition and make failure look ambiguous."
		ROLE_MURMUR:
			return "Harden public witness around the wrong answer and let counterfeit custody feel earned."
		ROLE_SCAVENGER:
			return "Survive the descent and help authentic artifacts reach extraction."
		_:
			return "Survive the cavern and read the clues."

func role_wins(role_name: String, expedition_success: bool, sabotage_success: bool) -> bool:
	if alignment_for_role(role_name) == ALIGNMENT_SABOTEUR:
		return sabotage_success
	return expedition_success

func build_private_role_payload(role_name: String) -> Dictionary:
	var duty_line := ""
	var caution_line := ""
	var affordance_tags: Array[String] = []
	match role_name:
		ROLE_WARDEN:
			duty_line = "Read contested artifacts before the route hardens around them."
			caution_line = "Your checks can pull more watch pressure toward unstable custody."
			affordance_tags = ["custody duty", "verification pressure", "witness answer"]
		ROLE_STEWARD:
			duty_line = "Make the burden legible before rumor chooses a carrier for you."
			caution_line = "Public certainty only helps if you stay close enough to the custody line to be believed."
			affordance_tags = ["public custody", "witness pressure", "regroup credibility"]
		ROLE_BEARER:
			duty_line = "Carry the authentic line through ugly handoffs before the route closes around it."
			caution_line = "Visible carries shorten extraction, but they also make you the body pursuit and blame settle on."
			affordance_tags = ["burden relay", "escort heat", "extraction commitment"]
		ROLE_VEIL:
			duty_line = "Bend custody into doubt without making the answer too clean."
			caution_line = "Forgery, sabotage, and volatile handoffs now draw sharper watch pressure."
			affordance_tags = ["counterfeit leverage", "suspicion heat", "ambiguous sabotage"]
		ROLE_MURMUR:
			duty_line = "Let witness pressure settle around the wrong carrier, then give that answer a counterfeit body."
			caution_line = "False witness only works when it stays near real burden and real hesitation."
			affordance_tags = ["false witness", "counterfeit escort", "callout distortion"]
		ROLE_SCAVENGER:
			duty_line = "Keep the route moving when burden, rescue, and handoff pressure splinter the group."
			caution_line = "Rescue reroutes and authentic custody now leave a stronger trail."
			affordance_tags = ["rescue debt", "handoff pressure", "route salvage"]
		_:
			duty_line = "Survive the cavern and read the clues."
			caution_line = ""
	return {
		"role": role_name,
		"duty_line": duty_line,
		"caution_line": caution_line,
		"affordance_tags": affordance_tags
	}

func _shuffle_array(items: Array, rng: RandomNumberGenerator) -> void:
	for i in range(items.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = items[i]
		items[i] = items[j]
		items[j] = tmp
