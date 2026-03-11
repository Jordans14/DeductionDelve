class_name ItemService
extends RefCounted

const PICKUP_RANGE := 68.0
const ROOM_WIDTH := 1024.0
const ROOM_HEIGHT := 768.0
const ROOM_COLUMNS := 5
const CATEGORY_IDS: Array[String] = ["artifact", "tool", "relic", "world_object"]
const ARCHETYPE_IDS: Array[String] = [
	"movement",
	"mobility infrastructure",
	"explosive",
	"stealth",
	"signal",
	"hazard control",
	"tracking",
	"deception",
	"support",
	"environmental manipulation"
]

const ITEM_IDS: Array[String] = [
	"lantern_snuffer",
	"heavy_boots",
	"timeline_bookmark",
	"decoy_emitter",
	"zipline_kit"
]

const ITEM_DEFS := {
	"lantern_snuffer": {
		"display_name": "Lantern Snuffer",
		"category": "relic",
		"archetypes": ["stealth", "signal"],
		"tags": ["signal", "shadow", "private"],
		"rarity": "common",
		"rarity_weight": 5,
		"quality": 1,
		"room_bias": {"traversal": 1, "hazard": 1, "evidence": 3},
		"role_affinity": ["Veil", "Scavenger"],
		"public_evidence": "light_change",
		"sound_profile": "quiet",
		"light_profile": "dim_local_light",
		"movement_effect": "none",
		"hazard_effect": "conceals_visibility",
		"clue_profile": "light_change",
		"placement_rules": "inventory_only",
		"risk_profile": "subtle",
		"visibility_profile": "private_use_visible_effect",
		"inventory_behavior": "passive_stack",
		"route_pressure": "medium",
		"synergy_hooks": ["shadow_route", "low_light_pickup"],
		"light_scale_mult": 0.55,
		"active_use": false
	},
	"heavy_boots": {
		"display_name": "Heavy Boots",
		"category": "relic",
		"archetypes": ["movement", "tracking"],
		"tags": ["mobility", "trace", "loud"],
		"rarity": "common",
		"rarity_weight": 5,
		"quality": 1,
		"room_bias": {"traversal": 2, "hazard": 3, "evidence": 1},
		"role_affinity": ["Scavenger"],
		"public_evidence": "footprints",
		"sound_profile": "heavy_steps",
		"light_profile": "none",
		"movement_effect": "lower_speed_higher_trace",
		"hazard_effect": "stable_footing",
		"clue_profile": "footprints",
		"placement_rules": "inventory_only",
		"risk_profile": "loud",
		"visibility_profile": "strong_route_tell",
		"inventory_behavior": "passive_stack",
		"route_pressure": "high",
		"synergy_hooks": ["trace_amplifier", "hazard_push_through"],
		"move_speed_mult": 0.93,
		"jump_velocity_mult": 0.88,
		"carry_speed_mult": 0.9,
		"noise_trace_interval": 36,
		"footprint_interval": 18,
		"footprint_scale": 1.2,
		"active_use": false
	},
	"timeline_bookmark": {
		"display_name": "Timeline Bookmark",
		"category": "tool",
		"archetypes": ["tracking", "support"],
		"tags": ["forensics", "signal", "precise"],
		"rarity": "uncommon",
		"rarity_weight": 3,
		"quality": 2,
		"room_bias": {"traversal": 1, "hazard": 1, "evidence": 4},
		"role_affinity": ["Warden"],
		"public_evidence": "timeline_anchor",
		"sound_profile": "paper_click",
		"light_profile": "none",
		"movement_effect": "none",
		"hazard_effect": "none",
		"clue_profile": "timeline_anchor",
		"placement_rules": "inventory_only",
		"risk_profile": "obvious_after_use",
		"visibility_profile": "public_timeline_fact",
		"inventory_behavior": "active_single_use",
		"route_pressure": "low",
		"synergy_hooks": ["forensics_lock", "route_reconstruction"],
		"active_use": true,
		"use_label": "Timeline bookmark anchored"
	},
	"decoy_emitter": {
		"display_name": "Decoy Emitter",
		"category": "tool",
		"archetypes": ["deception", "signal"],
		"tags": ["decoy", "noise", "route"],
		"rarity": "uncommon",
		"rarity_weight": 3,
		"quality": 2,
		"room_bias": {"traversal": 1, "hazard": 2, "evidence": 3},
		"role_affinity": ["Veil", "Scavenger"],
		"public_evidence": "noise_trace",
		"sound_profile": "loud_decoy",
		"light_profile": "blink",
		"movement_effect": "false_route",
		"hazard_effect": "misdirect_pulse",
		"clue_profile": "noise_trace",
		"placement_rules": "inventory_only",
		"risk_profile": "public_confusion",
		"visibility_profile": "ambiguous_public_noise",
		"inventory_behavior": "active_single_use",
		"route_pressure": "high",
		"synergy_hooks": ["route_split", "artifact_reroute"],
		"active_use": true,
		"use_label": "Decoy emitter clicked"
	},
	"zipline_kit": {
		"display_name": "Zipline Kit",
		"category": "tool",
		"archetypes": ["mobility infrastructure", "movement"],
		"tags": ["anchor", "route", "visible"],
		"rarity": "uncommon",
		"rarity_weight": 3,
		"quality": 2,
		"room_bias": {"traversal": 5, "hazard": 1, "evidence": 1},
		"role_affinity": ["Scavenger", "Warden"],
		"public_evidence": "placed_zipline",
		"sound_profile": "cable_whine",
		"light_profile": "none",
		"movement_effect": "lateral_route",
		"hazard_effect": "bypass_some_gaps",
		"clue_profile": "placed_zipline",
		"placement_rules": "valid_room_edges_only",
		"risk_profile": "public_route_commitment",
		"visibility_profile": "very_visible_world_object",
		"inventory_behavior": "active_single_use",
		"route_pressure": "high",
		"synergy_hooks": ["route_commitment", "team_splitter"],
		"active_use": true,
		"use_label": "Zipline deployed"
	}
}

func generate_item_spawns(seed_value: int, room_chain: Array) -> Array:
	var items: Array = []
	var next_id := 1
	var spawned_counts: Dictionary = {}
	var last_item_def_id := ""
	for room_raw in room_chain:
		var room: Dictionary = room_raw
		var slot := int(room.get("slot", -1))
		if slot < 0 or slot % 2 != 0:
			continue
		var item_def_id := _pick_item_for_room(seed_value, slot, str(room.get("type", "traversal")), room_chain.size(), spawned_counts, last_item_def_id)
		items.append({
			"item_id": next_id,
			"item_def_id": item_def_id,
			"display_name": get_display_name(item_def_id),
			"room_slot": slot,
			"owner_peer_id": 0,
			"world_pos": _world_pos_for_item_spawn(slot, str(room.get("type", "traversal")), item_def_id),
			"consumed": false
		})
		spawned_counts[item_def_id] = int(spawned_counts.get(item_def_id, 0)) + 1
		last_item_def_id = item_def_id
		next_id += 1
	return items

func validate_item_defs() -> Array[String]:
	var failures: Array[String] = []
	for item_id in ITEM_IDS:
		var definition: Dictionary = get_definition(item_id)
		if definition.is_empty():
			failures.append("%s missing definition" % item_id)
			continue
		for field in ["display_name", "category", "archetypes", "tags", "room_bias", "public_evidence", "sound_profile", "light_profile", "movement_effect", "hazard_effect", "clue_profile", "placement_rules", "risk_profile", "visibility_profile", "inventory_behavior", "route_pressure", "synergy_hooks", "rarity_weight"]:
			if not definition.has(field):
				failures.append("%s missing %s" % [item_id, field])
		if not CATEGORY_IDS.has(str(definition.get("category", ""))):
			failures.append("%s has invalid category" % item_id)
		for archetype in definition.get("archetypes", []):
			if not ARCHETYPE_IDS.has(str(archetype)):
				failures.append("%s has invalid archetype %s" % [item_id, str(archetype)])
	return failures

func get_definition(item_def_id: String) -> Dictionary:
	return ITEM_DEFS.get(item_def_id, {})

func get_display_name(item_def_id: String) -> String:
	return str(get_definition(item_def_id).get("display_name", item_def_id))

func get_category(item_def_id: String) -> String:
	return str(get_definition(item_def_id).get("category", "tool"))

func get_archetypes(item_def_id: String) -> Array[String]:
	var result: Array[String] = []
	for archetype in get_definition(item_def_id).get("archetypes", []):
		result.append(str(archetype))
	return result

func get_role_affinity(item_def_id: String) -> Array[String]:
	var result: Array[String] = []
	for role_name in get_definition(item_def_id).get("role_affinity", []):
		result.append(str(role_name))
	return result

func get_spawn_profile(item_def_id: String) -> Dictionary:
	var definition := get_definition(item_def_id)
	return {
		"rarity": str(definition.get("rarity", "common")),
		"rarity_weight": int(definition.get("rarity_weight", 1)),
		"quality": int(definition.get("quality", 1)),
		"room_bias": Dictionary(definition.get("room_bias", {})),
		"role_affinity": get_role_affinity(item_def_id)
	}

func get_evidence_profile(item_def_id: String) -> Dictionary:
	var definition := get_definition(item_def_id)
	return {
		"public_evidence": str(definition.get("public_evidence", "")),
		"sound_profile": str(definition.get("sound_profile", "none")),
		"light_profile": str(definition.get("light_profile", "none")),
		"clue_profile": str(definition.get("clue_profile", "none")),
		"visibility_profile": str(definition.get("visibility_profile", "none"))
	}

func get_behavior_profile(item_def_id: String) -> Dictionary:
	var definition := get_definition(item_def_id)
	return {
		"active_use": bool(definition.get("active_use", false)),
		"inventory_behavior": str(definition.get("inventory_behavior", "active_single_use")),
		"movement_effect": str(definition.get("movement_effect", "none")),
		"hazard_effect": str(definition.get("hazard_effect", "none")),
		"placement_rules": str(definition.get("placement_rules", "inventory_only")),
		"risk_profile": str(definition.get("risk_profile", "medium")),
		"route_pressure": str(definition.get("route_pressure", "low"))
	}

func get_synergy_hooks(item_def_id: String) -> Array[String]:
	var result: Array[String] = []
	for hook in get_definition(item_def_id).get("synergy_hooks", []):
		result.append(str(hook))
	return result

func build_authoring_profile(item_def_id: String) -> Dictionary:
	return {
		"category": get_category(item_def_id),
		"archetypes": get_archetypes(item_def_id),
		"tags": get_tags_for_items([item_def_id]),
		"spawn": get_spawn_profile(item_def_id),
		"evidence": get_evidence_profile(item_def_id),
		"behavior": get_behavior_profile(item_def_id),
		"synergy_hooks": get_synergy_hooks(item_def_id)
	}

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

func get_tags_for_items(item_def_ids: Array[String]) -> Array[String]:
	var tags: Array[String] = []
	for def_id in item_def_ids:
		var def_tags = get_definition(def_id).get("tags", [])
		for tag in def_tags:
			if not tags.has(tag):
				tags.append(tag)
	return tags

func get_light_scale_for_items(item_def_ids: Array[String]) -> float:
	if item_def_ids.has("lantern_snuffer"):
		return float(get_definition("lantern_snuffer").get("light_scale_mult", 1.0))
	return 1.0

func noise_trace_interval_for_items(item_def_ids: Array[String]) -> int:
	if item_def_ids.has("heavy_boots"):
		return int(get_definition("heavy_boots").get("noise_trace_interval", 60))
	return 90

func carry_speed_multiplier_for_items(item_def_ids: Array[String]) -> float:
	if item_def_ids.has("heavy_boots"):
		return float(get_definition("heavy_boots").get("carry_speed_mult", 1.0))
	return 1.0

func move_speed_multiplier_for_items(item_def_ids: Array[String]) -> float:
	if item_def_ids.has("heavy_boots"):
		return float(get_definition("heavy_boots").get("move_speed_mult", 1.0))
	return 1.0

func jump_velocity_multiplier_for_items(item_def_ids: Array[String]) -> float:
	if item_def_ids.has("heavy_boots"):
		return float(get_definition("heavy_boots").get("jump_velocity_mult", 1.0))
	return 1.0

func footprint_interval_for_items(item_def_ids: Array[String]) -> int:
	if item_def_ids.has("heavy_boots"):
		return int(get_definition("heavy_boots").get("footprint_interval", 24))
	return 48

func footprint_scale_for_items(item_def_ids: Array[String]) -> float:
	if item_def_ids.has("heavy_boots"):
		return float(get_definition("heavy_boots").get("footprint_scale", 1.1))
	return 0.8

func warden_score_bonus_for_items(_item_def_ids: Array[String], _room_recently_disturbed: bool) -> int:
	return 0

func active_item_ids_for_items(item_def_ids: Array[String]) -> Array[String]:
	var active_ids: Array[String] = []
	for def_id in ITEM_IDS:
		if not item_def_ids.has(def_id):
			continue
		if bool(get_definition(def_id).get("active_use", false)):
			active_ids.append(def_id)
	return active_ids

func is_active_use_item(item_def_id: String) -> bool:
	return bool(get_definition(item_def_id).get("active_use", false))

func get_use_label(item_def_id: String) -> String:
	return str(get_definition(item_def_id).get("use_label", get_display_name(item_def_id)))

func world_pos_for_spawn_for_test(room_slot: int, room_type: String, item_def_id: String) -> Vector2:
	return _world_pos_for_item_spawn(room_slot, room_type, item_def_id)

func _pick_item_for_room(seed_value: int, room_slot: int, room_type: String, room_count: int, spawned_counts: Dictionary = {}, last_item_def_id: String = "") -> String:
	var weighted_ids: Array[String] = []
	for item_id in ITEM_IDS:
		var weight := _room_weight_for_item(item_id, room_type)
		weight += _phase_bonus_for_item(item_id, room_slot, room_count)
		if int(spawned_counts.get(item_id, 0)) == 0:
			weight += 2
		elif int(spawned_counts.get(item_id, 0)) >= 2:
			weight = maxi(weight - 1, 1)
		if item_id == last_item_def_id:
			weight = maxi(weight - 2, 1)
		for _copy in range(weight):
			weighted_ids.append(item_id)
	if weighted_ids.is_empty():
		return ITEM_IDS[0]
	if not last_item_def_id.is_empty():
		var non_repeat_ids: Array[String] = []
		for item_id in weighted_ids:
			if item_id != last_item_def_id:
				non_repeat_ids.append(item_id)
		if not non_repeat_ids.is_empty():
			weighted_ids = non_repeat_ids
	var roll := posmod(int((seed_value * 31 + room_slot * 17) & 0x7fffffff), weighted_ids.size())
	return weighted_ids[roll]

func _total_room_weight(room_type: String) -> int:
	var total := 0
	for item_id in ITEM_IDS:
		total += _room_weight_for_item(item_id, room_type)
	return maxi(total, 1)

func _room_weight_for_item(item_def_id: String, room_type: String) -> int:
	var spawn_profile := get_spawn_profile(item_def_id)
	var bias: Dictionary = spawn_profile.get("room_bias", {})
	var rarity_weight := int(spawn_profile.get("rarity_weight", 1))
	return maxi(int(bias.get(room_type, 1)) * rarity_weight, 1)

func _phase_bonus_for_item(item_def_id: String, room_slot: int, room_count: int) -> int:
	if room_count <= 0:
		return 0
	if room_slot < maxi(int(room_count / 3), 3):
		match item_def_id:
			"zipline_kit", "heavy_boots":
				return 3
			"timeline_bookmark":
				return 2
			"lantern_snuffer":
				return 1
			_:
				return 0
	if room_slot >= maxi(int(room_count * 2 / 3), 1):
		match item_def_id:
			"decoy_emitter":
				return 3
			"lantern_snuffer":
				return 2
			"timeline_bookmark":
				return 1
			_:
				return 0
	match item_def_id:
		"timeline_bookmark", "decoy_emitter":
			return 1
		_:
			return 0

func _world_pos_for_item_spawn(room_slot: int, room_type: String, item_def_id: String) -> Vector2:
	var grid_x := posmod(room_slot, ROOM_COLUMNS)
	var grid_y := int(floor(float(room_slot) / float(ROOM_COLUMNS)))
	var room_origin := Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	match room_type:
		"traversal":
			if item_def_id in ["zipline_kit", "heavy_boots"]:
				return room_origin + Vector2(736.0, 236.0)
			return room_origin + Vector2(256.0, 404.0)
		"hazard":
			if item_def_id == "decoy_emitter":
				return room_origin + Vector2(760.0, 454.0)
			if item_def_id == "heavy_boots":
				return room_origin + Vector2(256.0, 240.0)
			return room_origin + Vector2(300.0, 404.0)
		"evidence":
			if item_def_id == "timeline_bookmark":
				return room_origin + Vector2(748.0, 232.0)
			if item_def_id == "lantern_snuffer":
				return room_origin + Vector2(236.0, 456.0)
			return room_origin + Vector2(700.0, 438.0)
		_:
			return room_origin + Vector2(128.0, 262.0)
