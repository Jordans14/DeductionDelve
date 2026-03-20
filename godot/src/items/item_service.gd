class_name ItemService
extends RefCounted

const SYNERGY_SERVICE_SCRIPT = preload("res://src/items/item_synergy_service.gd")
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")

const PICKUP_RANGE := 68.0
const ROOM_WIDTH := 1024.0
const ROOM_HEIGHT := 768.0
const ROOM_COLUMNS := 5
const TOOL_CARRY_LIMIT := 2
const CATEGORY_IDS: Array[String] = [
	"artifact",
	"tool",
	"relic",
	"trinket",
	"pickup",
	"covenant",
	"curse",
	"transformation",
	"environment_object"
]
const CATEGORY_ALIASES := {
	"world_object": "environment_object",
	"charm": "trinket",
	"consumable": "pickup",
	"burden": "curse"
}
const ITEM_ECOLOGY_LAYERS := {
	"artifact": "custody_objective",
	"relic": "build_economy",
	"tool": "execution_economy",
	"trinket": "micro_passive_economy",
	"pickup": "burst_economy",
	"covenant": "bargain_economy",
	"curse": "negative_economy",
	"transformation": "threshold_metamorphosis",
	"environment_object": "support_object"
}
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
	"zipline_kit",
	"custody_seal",
	"witness_chime",
	"echo_lure",
	"burden_sling"
]

const RESERVE_ITEM_IDS: Array[String] = [
	"hush_bead",
	"flare_ampoule",
	"oath_ribbon",
	"doubt_ink",
	"echo_molt"
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
	},
	"custody_seal": {
		"display_name": "Custody Seal",
		"category": "tool",
		"archetypes": ["support", "signal"],
		"tags": ["custody", "ritual", "public"],
		"rarity": "uncommon",
		"rarity_weight": 3,
		"quality": 2,
		"room_bias": {"traversal": 1, "hazard": 1, "evidence": 4},
		"role_affinity": ["Steward", "Bearer", "Warden"],
		"public_evidence": "custody_seal",
		"sound_profile": "seal_chime",
		"light_profile": "amber_ring",
		"movement_effect": "none",
		"hazard_effect": "stabilize_custody",
		"clue_profile": "seal_imprint",
		"placement_rules": "inventory_only",
		"risk_profile": "public_answer",
		"visibility_profile": "public_certification",
		"inventory_behavior": "active_single_use",
		"route_pressure": "medium",
		"synergy_hooks": ["custody_answer", "artifact_stabilization"],
		"active_use": true,
		"use_label": "Custody seal pressed"
	},
	"witness_chime": {
		"display_name": "Witness Chime",
		"category": "tool",
		"archetypes": ["signal", "support"],
		"tags": ["witness", "public", "loud"],
		"rarity": "uncommon",
		"rarity_weight": 3,
		"quality": 2,
		"room_bias": {"traversal": 1, "hazard": 2, "evidence": 3},
		"role_affinity": ["Steward", "Warden", "Murmur"],
		"public_evidence": "witness_chime",
		"sound_profile": "clear_chime",
		"light_profile": "halo_ping",
		"movement_effect": "none",
		"hazard_effect": "public_callout",
		"clue_profile": "witness_chime",
		"placement_rules": "inventory_only",
		"risk_profile": "public_answer",
		"visibility_profile": "very_visible_world_object",
		"inventory_behavior": "active_single_use",
		"route_pressure": "medium",
		"synergy_hooks": ["witness_line", "public_answer"],
		"active_use": true,
		"use_label": "Witness chime rung"
	},
	"echo_lure": {
		"display_name": "Echo Lure",
		"category": "tool",
		"archetypes": ["deception", "signal"],
		"tags": ["echo", "decoy", "anti_protocol"],
		"rarity": "uncommon",
		"rarity_weight": 3,
		"quality": 2,
		"room_bias": {"traversal": 2, "hazard": 3, "evidence": 1},
		"role_affinity": ["Veil", "Murmur", "Scavenger"],
		"public_evidence": "noise_trace",
		"sound_profile": "whisper_loop",
		"light_profile": "flicker",
		"movement_effect": "false_echo",
		"hazard_effect": "echo_diversion",
		"clue_profile": "echo_lure",
		"placement_rules": "inventory_only",
		"risk_profile": "public_confusion",
		"visibility_profile": "ambiguous_public_noise",
		"inventory_behavior": "active_single_use",
		"route_pressure": "high",
		"synergy_hooks": ["anomaly_redirect", "watch_bait"],
		"active_use": true,
		"use_label": "Echo lure wound"
	},
	"burden_sling": {
		"display_name": "Burden Sling",
		"category": "relic",
		"archetypes": ["support", "movement"],
		"tags": ["burden", "escort", "visible"],
		"rarity": "common",
		"rarity_weight": 4,
		"quality": 2,
		"room_bias": {"traversal": 3, "hazard": 2, "evidence": 1},
		"role_affinity": ["Bearer", "Steward", "Scavenger"],
		"public_evidence": "strap_fiber",
		"sound_profile": "leather_drag",
		"light_profile": "none",
		"movement_effect": "carry_relief",
		"hazard_effect": "rescue_support",
		"clue_profile": "strap_fiber",
		"placement_rules": "inventory_only",
		"risk_profile": "visible_help",
		"visibility_profile": "escort_tell",
		"inventory_behavior": "passive_stack",
		"route_pressure": "medium",
		"synergy_hooks": ["escort_line", "rescue_commitment"],
		"move_speed_mult": 1.02,
		"carry_speed_mult": 1.08,
		"noise_trace_interval": 84,
		"active_use": false
	}
}

const RESERVE_ITEM_DEFS := {
	"hush_bead": {
		"display_name": "Hush Bead",
		"category": "trinket",
		"archetypes": ["stealth", "support"],
		"tags": ["quiet", "micro", "private"],
		"rarity": "uncommon",
		"rarity_weight": 1,
		"quality": 1,
		"quality_band": "minor",
		"room_bias": {"traversal": 1, "hazard": 2, "evidence": 2},
		"role_affinity": ["Veil", "Steward"],
		"public_evidence": "thread_residue",
		"sound_profile": "none",
		"light_profile": "none",
		"movement_effect": "quiet_step_support",
		"hazard_effect": "none",
		"clue_profile": "thread_residue",
		"placement_rules": "inventory_only",
		"risk_profile": "subtle",
		"visibility_profile": "micro_private_tell",
		"inventory_behavior": "passive_stack",
		"route_pressure": "low",
		"synergy_hooks": ["quiet_answer", "low_trace_support"],
		"noise_trace_interval": 102,
		"active_use": false
	},
	"flare_ampoule": {
		"display_name": "Flare Ampoule",
		"category": "pickup",
		"archetypes": ["signal", "support"],
		"tags": ["burst", "public", "light"],
		"rarity": "common",
		"rarity_weight": 1,
		"quality": 1,
		"quality_band": "burst",
		"room_bias": {"traversal": 1, "hazard": 3, "evidence": 2},
		"role_affinity": ["Warden", "Steward"],
		"public_evidence": "flare_bloom",
		"sound_profile": "glass_snap",
		"light_profile": "flare_bloom",
		"movement_effect": "none",
		"hazard_effect": "brief_reveal",
		"clue_profile": "flare_bloom",
		"placement_rules": "inventory_only",
		"risk_profile": "public_answer",
		"visibility_profile": "burst_public_flash",
		"inventory_behavior": "active_single_use",
		"route_pressure": "medium",
		"synergy_hooks": ["witness_bloom", "rescue_ping"],
		"burst_effect": "room_reveal",
		"burst_duration_ticks": 150,
		"light_scale_mult": 1.35,
		"active_use": true,
		"use_label": "Flare ampoule cracked"
	},
	"oath_ribbon": {
		"display_name": "Oath Ribbon",
		"category": "covenant",
		"archetypes": ["support", "signal"],
		"tags": ["bargain", "oath", "custody"],
		"rarity": "rare",
		"rarity_weight": 1,
		"quality": 2,
		"quality_band": "bargain",
		"room_bias": {"traversal": 1, "hazard": 1, "evidence": 3},
		"role_affinity": ["Steward", "Bearer"],
		"public_evidence": "ribbon_fiber",
		"sound_profile": "cloth_tension",
		"light_profile": "none",
		"movement_effect": "none",
		"hazard_effect": "oath_focus",
		"clue_profile": "ribbon_fiber",
		"placement_rules": "inventory_only",
		"risk_profile": "public_answer",
		"visibility_profile": "bargain_tell",
		"inventory_behavior": "passive_stack",
		"route_pressure": "medium",
		"synergy_hooks": ["oath_line", "custody_bargain"],
		"bargain_cost": "public_trace",
		"activation_condition": "artifact_carry",
		"carry_speed_mult": 1.05,
		"noise_trace_interval": 84,
		"active_use": false
	},
	"doubt_ink": {
		"display_name": "Doubt Ink",
		"category": "curse",
		"archetypes": ["deception", "tracking"],
		"tags": ["curse", "residue", "public"],
		"rarity": "rare",
		"rarity_weight": 1,
		"quality": 2,
		"quality_band": "negative",
		"room_bias": {"traversal": 1, "hazard": 2, "evidence": 3},
		"role_affinity": ["Murmur", "Veil"],
		"public_evidence": "ink_smear",
		"sound_profile": "none",
		"light_profile": "ink_sheen",
		"movement_effect": "burden_drag",
		"hazard_effect": "trace_amplifier",
		"clue_profile": "ink_smear",
		"placement_rules": "inventory_only",
		"risk_profile": "loud",
		"visibility_profile": "curse_stain",
		"inventory_behavior": "passive_stack",
		"route_pressure": "high",
		"synergy_hooks": ["public_doubt", "trace_curse"],
		"negative_modifiers": ["carry_speed_mult", "noise_trace_interval"],
		"carry_speed_mult": 0.92,
		"noise_trace_interval": 42,
		"active_use": false
	},
	"echo_molt": {
		"display_name": "Echo Molt",
		"category": "transformation",
		"archetypes": ["movement", "deception"],
		"tags": ["threshold", "mutation", "echo"],
		"rarity": "rare",
		"rarity_weight": 1,
		"quality": 3,
		"quality_band": "threshold",
		"room_bias": {"traversal": 2, "hazard": 3, "evidence": 1},
		"role_affinity": ["Scavenger", "Veil"],
		"public_evidence": "echo_shed",
		"sound_profile": "hollow_peel",
		"light_profile": "echo_outline",
		"movement_effect": "threshold_surge",
		"hazard_effect": "echo_instability",
		"clue_profile": "echo_shed",
		"placement_rules": "threshold_only",
		"risk_profile": "public_confusion",
		"visibility_profile": "major_mutation_outline",
		"inventory_behavior": "passive_stack",
		"route_pressure": "high",
		"synergy_hooks": ["echo_threshold", "mutation_line"],
		"threshold_kind": "echo_pressure",
		"threshold_value": 2,
		"discernibility_flag": "echo_molt_outline",
		"move_speed_mult": 1.04,
		"light_scale_mult": 1.18,
		"active_use": false
	}
}

const CATEGORY_RULES := {
	"artifact": {"active_use_allowed": false, "requires_custody_owner": true, "spawn_pool": "runtime_only"},
	"tool": {"active_use_allowed": true, "carry_limit": TOOL_CARRY_LIMIT, "spawn_pool": "live"},
	"relic": {"active_use_allowed": false, "passive_only": true, "spawn_pool": "live"},
	"trinket": {"active_use_allowed": false, "passive_only": true, "readability_budget": "minor", "spawn_pool": "reserve", "carry_limit": 1},
	"pickup": {"active_use_allowed": true, "consumes_on_use": true, "burst_only": true, "spawn_pool": "reserve", "carry_limit": 1},
	"covenant": {"active_use_allowed": false, "must_declare_bargain": true, "spawn_pool": "reserve", "carry_limit": 1},
	"curse": {"active_use_allowed": false, "must_carry_negative": true, "spawn_pool": "reserve", "carry_limit": 1},
	"transformation": {"active_use_allowed": false, "threshold_only": true, "requires_discernibility": true, "spawn_pool": "reserve", "carry_limit": 1},
	"environment_object": {"active_use_allowed": false, "support_only": true, "spawn_pool": "environment"}
}

const FORBIDDEN_COMBO_RULES := [
	{
		"ids": ["oath_ribbon", "doubt_ink"],
		"reason": "bargain and curse collapse the same custody read into unreadable noise"
	},
	{
		"ids": ["echo_molt", "heavy_boots"],
		"reason": "threshold mutation cannot stack with heavy-footed trace amplification without breaking silhouette discipline"
	}
]

const RESERVE_SPAWN_CATEGORY_CAPS := {
	"trinket": 1,
	"pickup": 1,
	"covenant": 1,
	"curse": 1,
	"transformation": 1
}
const MAX_RESERVE_SPAWNS_PER_EXPEDITION := 3
const MAX_HIGH_INTENSITY_RESERVE_SPAWNS := 2

var synergy_service: RefCounted = SYNERGY_SERVICE_SCRIPT.new()

func generate_item_spawns(seed_value: int, room_chain: Array, directive: Dictionary = {}) -> Array:
	var items: Array = []
	var next_id := 1
	var spawned_counts: Dictionary = {}
	var last_item_def_id := ""
	var generation_contract := RUN_GENERATOR_SCRIPT.new().build_generation_contract(seed_value, directive)
	for room_raw in room_chain:
		var room: Dictionary = room_raw
		var slot := int(room.get("slot", -1))
		if slot < 0 or slot % 2 != 0:
			continue
		var item_def_id := _pick_item_for_room(seed_value, room, room_chain.size(), spawned_counts, last_item_def_id, generation_contract)
		items.append({
			"item_id": next_id,
			"item_def_id": item_def_id,
			"display_name": get_display_name(item_def_id),
			"category": get_category(item_def_id),
			"ecology_layer": item_ecology_layer(item_def_id),
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
	for item_id in item_library_ids():
		var definition: Dictionary = get_definition(item_id)
		if definition.is_empty():
			failures.append("%s missing definition" % item_id)
			continue
		for field in ["display_name", "category", "archetypes", "tags", "room_bias", "public_evidence", "sound_profile", "light_profile", "movement_effect", "hazard_effect", "clue_profile", "placement_rules", "risk_profile", "visibility_profile", "inventory_behavior", "route_pressure", "synergy_hooks", "rarity_weight"]:
			if not definition.has(field):
				failures.append("%s missing %s" % [item_id, field])
		if not CATEGORY_IDS.has(canonical_category(str(definition.get("category", "")))):
			failures.append("%s has invalid category" % item_id)
		for archetype in definition.get("archetypes", []):
			if not ARCHETYPE_IDS.has(str(archetype)):
				failures.append("%s has invalid archetype %s" % [item_id, str(archetype)])
		failures.append_array(_category_specific_validation_failures(item_id, definition))
	return failures

func get_definition(item_def_id: String) -> Dictionary:
	if ITEM_DEFS.has(item_def_id):
		return Dictionary(ITEM_DEFS.get(item_def_id, {})).duplicate(true)
	return Dictionary(RESERVE_ITEM_DEFS.get(item_def_id, {})).duplicate(true)

func live_item_ids() -> Array[String]:
	return ITEM_IDS.duplicate() + RESERVE_ITEM_IDS.duplicate()

func item_library_ids() -> Array[String]:
	return ITEM_IDS.duplicate() + RESERVE_ITEM_IDS.duplicate()

func get_display_name(item_def_id: String) -> String:
	return str(get_definition(item_def_id).get("display_name", item_def_id))

func get_category(item_def_id: String) -> String:
	return canonical_category(str(get_definition(item_def_id).get("category", "tool")))

func canonical_category(category_id: String) -> String:
	var lowered := category_id.strip_edges().to_lower()
	if lowered.is_empty():
		return "tool"
	return str(CATEGORY_ALIASES.get(lowered, lowered))

func category_rules(category_id: String) -> Dictionary:
	return Dictionary(CATEGORY_RULES.get(canonical_category(category_id), {})).duplicate(true)

func category_carry_limit(category_id: String) -> int:
	return int(category_rules(category_id).get("carry_limit", 0))

func item_ecology_layer(item_def_id: String) -> String:
	return str(ITEM_ECOLOGY_LAYERS.get(get_category(item_def_id), "execution_economy"))

func category_readability_profile(category_id: String) -> Dictionary:
	match canonical_category(category_id):
		"artifact":
			return {"major_signal": true, "max_visible_layers": 2, "public_trace_priority": true}
		"tool":
			return {"major_signal": true, "max_visible_layers": 2, "public_trace_priority": true}
		"relic":
			return {"major_signal": false, "max_visible_layers": 1, "public_trace_priority": false}
		"trinket":
			return {"major_signal": false, "max_visible_layers": 1, "public_trace_priority": false}
		"pickup":
			return {"major_signal": true, "max_visible_layers": 1, "public_trace_priority": true}
		"covenant":
			return {"major_signal": true, "max_visible_layers": 2, "public_trace_priority": true}
		"curse":
			return {"major_signal": true, "max_visible_layers": 2, "public_trace_priority": true}
		"transformation":
			return {"major_signal": true, "max_visible_layers": 3, "public_trace_priority": true}
		_:
			return {"major_signal": false, "max_visible_layers": 1, "public_trace_priority": false}

func build_modifier_registry() -> Dictionary:
	return {
		"traversal": ["move_speed_mult", "jump_velocity_mult", "carry_speed_mult"],
		"information": ["noise_trace_interval", "footprint_interval", "footprint_scale"],
		"readability": ["light_scale_mult", "visibility_profile", "sound_profile", "light_profile"],
		"route_pressure": ["route_pressure", "room_bias", "placement_rules"],
		"social": ["role_affinity", "public_evidence", "clue_profile"],
		"ritual": ["synergy_hooks", "tags"],
		"bargain": ["bargain_cost", "activation_condition"],
		"negative": ["negative_modifiers"],
		"threshold": ["threshold_kind", "threshold_value", "discernibility_flag", "burst_effect", "burst_duration_ticks"]
	}

func build_item_ecology_registry() -> Dictionary:
	var category_registry := {}
	for category_id in CATEGORY_IDS:
		var live_count := 0
		var library_count := 0
		for item_id in live_item_ids():
			if get_category(item_id) == category_id:
				live_count += 1
		for item_id in item_library_ids():
			if get_category(item_id) == category_id:
				library_count += 1
		category_registry[category_id] = {
			"economy_layer": str(ITEM_ECOLOGY_LAYERS.get(category_id, "")),
			"readability": category_readability_profile(category_id),
			"rules": Dictionary(CATEGORY_RULES.get(category_id, {})).duplicate(true),
			"live_count": live_count,
			"library_count": library_count
		}
	return {
		"categories": category_registry,
		"modifier_registry": build_modifier_registry(),
		"live_item_ids": live_item_ids(),
		"library_item_ids": item_library_ids(),
		"forbidden_combos": FORBIDDEN_COMBO_RULES.duplicate(true)
	}

func _category_specific_validation_failures(item_id: String, definition: Dictionary) -> Array[String]:
	var failures: Array[String] = []
	var category_id := canonical_category(str(definition.get("category", "")))
	match category_id:
		"trinket":
			if bool(definition.get("active_use", false)):
				failures.append("%s trinkets must remain passive-only" % item_id)
		"pickup":
			if not bool(definition.get("active_use", false)) or str(definition.get("inventory_behavior", "")) != "active_single_use":
				failures.append("%s pickups must be active single-use bursts" % item_id)
			if str(definition.get("burst_effect", "")).strip_edges().is_empty():
				failures.append("%s pickups must declare a burst_effect" % item_id)
		"covenant":
			if str(definition.get("bargain_cost", "")).strip_edges().is_empty() or str(definition.get("activation_condition", "")).strip_edges().is_empty():
				failures.append("%s covenants must declare bargain_cost and activation_condition" % item_id)
		"curse":
			if Array(definition.get("negative_modifiers", [])).is_empty():
				failures.append("%s curses must declare negative_modifiers" % item_id)
		"transformation":
			if str(definition.get("threshold_kind", "")).strip_edges().is_empty() or int(definition.get("threshold_value", 0)) <= 0:
				failures.append("%s transformations must declare threshold_kind and threshold_value" % item_id)
			if str(definition.get("discernibility_flag", "")).strip_edges().is_empty():
				failures.append("%s transformations must declare a discernibility_flag" % item_id)
	return failures

func forbidden_combo_failures(item_def_ids: Array[String]) -> Array[String]:
	var failures: Array[String] = []
	var deduped_ids := _dedupe_strings(item_def_ids)
	for rule_raw in FORBIDDEN_COMBO_RULES:
		var rule: Dictionary = rule_raw
		var required_ids := _string_array(rule.get("ids", []))
		if required_ids.is_empty():
			continue
		var matched := true
		for required_id in required_ids:
			if not deduped_ids.has(required_id):
				matched = false
				break
		if matched:
			failures.append(str(rule.get("reason", "illegal ecology pairing")).strip_edges())
	return failures

func forbidden_combo_failures_with_candidate(item_def_ids: Array[String], candidate_item_def_id: String) -> Array[String]:
	var next_ids := _dedupe_strings(item_def_ids + [candidate_item_def_id])
	return forbidden_combo_failures(next_ids)

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
		"economy_layer": item_ecology_layer(item_def_id),
		"archetypes": get_archetypes(item_def_id),
		"tags": get_tags_for_items([item_def_id]),
		"spawn": get_spawn_profile(item_def_id),
		"evidence": get_evidence_profile(item_def_id),
		"behavior": get_behavior_profile(item_def_id),
		"synergy_hooks": get_synergy_hooks(item_def_id),
		"narrative": build_narrative_profile(item_def_id),
		"gameplay": build_gameplay_profile(item_def_id),
		"readability": category_readability_profile(get_category(item_def_id))
	}

func build_narrative_profile(item_def_id: String) -> Dictionary:
	var behavior := get_behavior_profile(item_def_id)
	var spawn := get_spawn_profile(item_def_id)
	var category_id := get_category(item_def_id)
	var roles: Array[String] = []
	var sociality: Array[String] = []
	var reputation: Array[String] = []
	var plurality: Array[String] = []
	var handling: Array[String] = []
	var branch_affinity: Array[String] = []
	var protocol_affinity: Array[String] = []
	var model_hooks: Array[String] = []
	var lineage_hints: Array[String] = []
	var branch_markers: Array[String] = []
	var memory_hints: Array[String] = []
	var prestige_indicators: Array[String] = []
	var route_pressure := str(behavior.get("route_pressure", "low"))
	var risk_profile := str(behavior.get("risk_profile", "medium"))
	var latent_dimensions := {
		"traversal": 0,
		"rescue": 0,
		"deception": 0,
		"burden": 0,
		"witness_visibility": 0,
		"ritual_significance": 0,
		"instability": 0,
		"scarcity": maxi(int(spawn.get("quality", 1)) - 1, 0),
		"anti_protocol_potential": 0
	}
	if item_def_id.find("zipline") != -1:
		roles.append("escape catalyst")
		sociality.append("visible route commitment")
		plurality.append("rescue prestige")
		handling.append("threshold handoff")
		branch_affinity.append("sundered span")
		protocol_affinity.append("fracture")
		protocol_affinity.append("intimate")
		model_hooks.append("route prediction")
		model_hooks.append("rescue geometry")
		lineage_hints.append("salvage-line lineage")
		branch_markers.append("sundered span bridge-mark")
		memory_hints.append("rescuer carry memory")
		prestige_indicators.append("bridgekeeper prestige")
		latent_dimensions["traversal"] = 3
		latent_dimensions["rescue"] = 3
		latent_dimensions["burden"] = 2
		latent_dimensions["witness_visibility"] = 3
		latent_dimensions["ritual_significance"] = 1
	elif item_def_id.find("decoy") != -1:
		roles.append("obstruction engine")
		sociality.append("baited split")
		plurality.append("scandal risk")
		handling.append("public refusal")
		branch_affinity.append("watcher steps")
		protocol_affinity.append("fracture")
		protocol_affinity.append("exposure")
		model_hooks.append("attention diversion")
		model_hooks.append("false consensus pressure")
		lineage_hints.append("false-signal lineage")
		branch_markers.append("watcher steps misdirection mark")
		memory_hints.append("scandal bait memory")
		prestige_indicators.append("notoriety prestige")
		latent_dimensions["deception"] = 3
		latent_dimensions["witness_visibility"] = 2
		latent_dimensions["instability"] = 3
		latent_dimensions["anti_protocol_potential"] = 1
	elif item_def_id.find("timeline") != -1:
		roles.append("public mark")
		sociality.append("forensic invitation")
		plurality.append("archive prestige")
		handling.append("pressured pass")
		branch_affinity.append("relay hollows")
		protocol_affinity.append("expedition")
		protocol_affinity.append("intimate")
		model_hooks.append("public memory")
		model_hooks.append("route reconstruction")
		lineage_hints.append("archive custody lineage")
		branch_markers.append("relay hollows docket mark")
		memory_hints.append("rescued record memory")
		prestige_indicators.append("archive prestige")
		latent_dimensions["rescue"] = 1
		latent_dimensions["witness_visibility"] = 2
		latent_dimensions["ritual_significance"] = 2
		latent_dimensions["anti_protocol_potential"] = 2
	elif item_def_id.find("lantern") != -1:
		roles.append("cursed invitation")
		sociality.append("private-use tension")
		plurality.append("curse pull")
		handling.append("solo carry")
		branch_affinity.append("grave lattice")
		protocol_affinity.append("exposure")
		protocol_affinity.append("intimate")
		model_hooks.append("fear conditioning")
		model_hooks.append("private anomaly attention")
		lineage_hints.append("grave-watch lineage")
		branch_markers.append("grave lattice hush-mark")
		memory_hints.append("private dread memory")
		prestige_indicators.append("taboo prestige")
		latent_dimensions["traversal"] = 1
		latent_dimensions["deception"] = 1
		latent_dimensions["witness_visibility"] = 1
		latent_dimensions["ritual_significance"] = 3
		latent_dimensions["instability"] = 2
		latent_dimensions["anti_protocol_potential"] = 3
	elif item_def_id.find("boots") != -1:
		roles.append("catastrophe amplifier")
		sociality.append("burden drag")
		plurality.append("fear prestige")
		handling.append("burden transfer")
		branch_affinity.append("forge veins")
		protocol_affinity.append("fracture")
		protocol_affinity.append("exposure")
		model_hooks.append("trace amplification")
		model_hooks.append("route exposure")
		lineage_hints.append("burden-trial lineage")
		branch_markers.append("forge veins carry-mark")
		memory_hints.append("scandal carry memory")
		prestige_indicators.append("fear prestige")
		latent_dimensions["traversal"] = 2
		latent_dimensions["burden"] = 3
		latent_dimensions["witness_visibility"] = 3
		latent_dimensions["instability"] = 2
	elif item_def_id.find("custody_seal") != -1:
		roles.append("custody answer")
		sociality.append("public certification")
		plurality.append("oath pressure")
		handling.append("witnessed burden")
		branch_affinity.append("oath terraces")
		branch_affinity.append("watcher steps")
		protocol_affinity.append("expedition")
		protocol_affinity.append("intimate")
		model_hooks.append("custody stabilization")
		model_hooks.append("public oath pressure")
		lineage_hints.append("custody-seal lineage")
		branch_markers.append("oath terraces seal mark")
		memory_hints.append("public custody memory")
		prestige_indicators.append("oath prestige")
		latent_dimensions["rescue"] = 1
		latent_dimensions["burden"] = 2
		latent_dimensions["witness_visibility"] = 3
		latent_dimensions["ritual_significance"] = 3
	elif item_def_id.find("witness_chime") != -1:
		roles.append("public answer")
		sociality.append("witness flare")
		plurality.append("verification risk")
		handling.append("heard commitment")
		branch_affinity.append("oath terraces")
		branch_affinity.append("relay hollows")
		protocol_affinity.append("expedition")
		protocol_affinity.append("exposure")
		model_hooks.append("witness shaping")
		model_hooks.append("public certainty pressure")
		lineage_hints.append("witness-ledger lineage")
		branch_markers.append("oath terraces bell mark")
		memory_hints.append("heard custody memory")
		prestige_indicators.append("witness prestige")
		latent_dimensions["rescue"] = 1
		latent_dimensions["deception"] = 1
		latent_dimensions["witness_visibility"] = 3
		latent_dimensions["ritual_significance"] = 2
		latent_dimensions["instability"] = 1
	elif item_def_id.find("echo_lure") != -1:
		roles.append("counter-reading lure")
		sociality.append("baited witness split")
		plurality.append("anti-protocol temptation")
		handling.append("redirected pursuit")
		branch_affinity.append("murmur warrens")
		branch_affinity.append("grave lattice")
		protocol_affinity.append("fracture")
		protocol_affinity.append("exposure")
		model_hooks.append("anomaly redirection")
		model_hooks.append("watch bait")
		lineage_hints.append("counter-reading lineage")
		branch_markers.append("murmur warrens echo knot")
		memory_hints.append("misread route memory")
		prestige_indicators.append("forbidden prestige")
		latent_dimensions["traversal"] = 1
		latent_dimensions["deception"] = 3
		latent_dimensions["witness_visibility"] = 2
		latent_dimensions["instability"] = 3
		latent_dimensions["anti_protocol_potential"] = 3
	elif item_def_id.find("burden_sling") != -1:
		roles.append("escort keeper")
		sociality.append("visible relief")
		plurality.append("rescue confidence")
		handling.append("burden support")
		branch_affinity.append("oath terraces")
		branch_affinity.append("sundered span")
		protocol_affinity.append("intimate")
		protocol_affinity.append("expedition")
		model_hooks.append("carry relief")
		model_hooks.append("escort expectation")
		lineage_hints.append("escort-line lineage")
		branch_markers.append("oath terraces harness mark")
		memory_hints.append("carried rescue memory")
		prestige_indicators.append("steadfast prestige")
		latent_dimensions["traversal"] = 2
		latent_dimensions["rescue"] = 3
		latent_dimensions["burden"] = 2
		latent_dimensions["witness_visibility"] = 1
		latent_dimensions["ritual_significance"] = 1
	match category_id:
		"trinket":
			roles.append("micro-aid")
			sociality.append("subtle comfort")
			memory_hints.append("small carry memory")
			latent_dimensions["ritual_significance"] = maxi(int(latent_dimensions["ritual_significance"]), 1)
		"pickup":
			roles.append("burst opener")
			sociality.append("momentary public answer")
			plurality.append("short-form risk")
			latent_dimensions["witness_visibility"] = maxi(int(latent_dimensions["witness_visibility"]), 2)
			latent_dimensions["instability"] = maxi(int(latent_dimensions["instability"]), 1)
		"covenant":
			roles.append("bargain line")
			sociality.append("declared price")
			reputation.append("vowed object")
			latent_dimensions["burden"] = maxi(int(latent_dimensions["burden"]), 1)
			latent_dimensions["ritual_significance"] = maxi(int(latent_dimensions["ritual_significance"]), 2)
		"curse":
			roles.append("pressure debt")
			sociality.append("contested burden")
			plurality.append("suspicion pull")
			latent_dimensions["instability"] = maxi(int(latent_dimensions["instability"]), 2)
			latent_dimensions["witness_visibility"] = maxi(int(latent_dimensions["witness_visibility"]), 2)
		"transformation":
			roles.append("threshold body")
			sociality.append("changed silhouette")
			plurality.append("mutation pressure")
			latent_dimensions["traversal"] = maxi(int(latent_dimensions["traversal"]), 1)
			latent_dimensions["instability"] = maxi(int(latent_dimensions["instability"]), 2)
			latent_dimensions["anti_protocol_potential"] = maxi(int(latent_dimensions["anti_protocol_potential"]), 2)
	if route_pressure == "high" and not roles.has("escalation trigger"):
		roles.append("escalation trigger")
		latent_dimensions["traversal"] = maxi(int(latent_dimensions["traversal"]), 2)
	if risk_profile in ["subtle", "loud"] and not reputation.has("superstition carrier"):
		reputation.append("superstition carrier")
	if int(spawn.get("quality", 1)) >= 2:
		reputation.append("prestige object")
		prestige_indicators.append("collector prestige")
	if category_id in ["relic", "artifact"]:
		reputation.append("fear object")
		lineage_hints.append("artifact custody line")
		latent_dimensions["ritual_significance"] = maxi(int(latent_dimensions["ritual_significance"]), 2)
	if route_pressure == "high":
		plurality.append("temptation pull")
		model_hooks.append("route temptation")
	if risk_profile == "loud":
		plurality.append("public challenge object")
		model_hooks.append("witness amplification")
		latent_dimensions["witness_visibility"] = maxi(int(latent_dimensions["witness_visibility"]), 2)
	if risk_profile == "subtle":
		plurality.append("private fear object")
		model_hooks.append("private suspicion")
	if roles.has("rescue enabler") or item_def_id.find("zipline") != -1:
		plurality.append("redemption pull")
	if category_id == "tool":
		protocol_affinity.append("expedition")
	if category_id == "relic":
		protocol_affinity.append("exposure")
	if int(spawn.get("quality", 1)) >= 2:
		latent_dimensions["scarcity"] = maxi(int(latent_dimensions["scarcity"]), 1)
	if plurality.has("temptation pull"):
		latent_dimensions["anti_protocol_potential"] = maxi(int(latent_dimensions["anti_protocol_potential"]), 1)
	return {
		"roles": roles,
		"sociality": sociality,
		"reputation": reputation,
		"plurality": plurality,
		"handling": handling,
		"branch_affinity": branch_affinity,
		"protocol_affinity": _dedupe_strings(protocol_affinity),
		"model_hooks": _dedupe_strings(model_hooks),
		"lineage_hints": _dedupe_strings(lineage_hints),
		"branch_markers": _dedupe_strings(branch_markers),
		"memory_hints": _dedupe_strings(memory_hints),
		"prestige_indicators": _dedupe_strings(prestige_indicators),
		"latent_dimensions": latent_dimensions,
		"temptation": "high" if route_pressure == "high" else "medium" if int(spawn.get("quality", 1)) >= 2 else "low"
	}

func build_gameplay_profile(item_def_id: String) -> Dictionary:
	var definition := get_definition(item_def_id)
	var narrative := build_narrative_profile(item_def_id)
	var category_id := get_category(item_def_id)
	var behavior_signals: Array[String] = []
	var ritual_hooks: Array[String] = []
	var anomaly_hooks: Array[String] = []
	var resource_hooks: Array[String] = []
	var control_pull := 0
	var runtime_affordances := {
		"light_scale": 1.0,
		"move_speed_mult": 1.0,
		"jump_velocity_mult": 1.0,
		"carry_speed_mult": 1.0,
		"noise_trace_interval": 90,
		"footprint_interval": 48,
		"footprint_scale": 0.8
	}
	runtime_affordances["light_scale"] = float(definition.get("light_scale_mult", runtime_affordances.get("light_scale", 1.0)))
	runtime_affordances["move_speed_mult"] = float(definition.get("move_speed_mult", runtime_affordances.get("move_speed_mult", 1.0)))
	runtime_affordances["jump_velocity_mult"] = float(definition.get("jump_velocity_mult", runtime_affordances.get("jump_velocity_mult", 1.0)))
	runtime_affordances["carry_speed_mult"] = float(definition.get("carry_speed_mult", runtime_affordances.get("carry_speed_mult", 1.0)))
	runtime_affordances["noise_trace_interval"] = int(definition.get("noise_trace_interval", runtime_affordances.get("noise_trace_interval", 90)))
	runtime_affordances["footprint_interval"] = int(definition.get("footprint_interval", runtime_affordances.get("footprint_interval", 48)))
	runtime_affordances["footprint_scale"] = float(definition.get("footprint_scale", runtime_affordances.get("footprint_scale", 0.8)))
	match item_def_id:
		"lantern_snuffer":
			behavior_signals = ["visibility suppression", "private carry", "ritual concealment"]
			ritual_hooks = ["quiet answer", "shadow handling"]
			anomaly_hooks = ["attention sink"]
			control_pull = 1
		"heavy_boots":
			behavior_signals = ["trace pressure", "burden anchor", "route commitment"]
			resource_hooks = ["weight line"]
			control_pull = 2
		"timeline_bookmark":
			behavior_signals = ["route memory", "forensic anchor", "ritual curiosity"]
			ritual_hooks = ["remembered threshold", "quiet revision"]
			anomaly_hooks = ["memory slippage"]
			resource_hooks = ["note trace"]
			control_pull = 1
		"decoy_emitter":
			behavior_signals = ["false route", "attention split", "panic lure"]
			anomaly_hooks = ["route skew"]
			resource_hooks = ["noise pulse"]
			control_pull = 2
		"zipline_kit":
			behavior_signals = ["rescue geometry", "commitment signal", "route control"]
			ritual_hooks = ["visible crossing"]
			resource_hooks = ["anchor line"]
			control_pull = 2
		"custody_seal":
			behavior_signals = ["custody answer", "public certification", "escort vow"]
			ritual_hooks = ["sealed burden", "witnessed answer"]
			resource_hooks = ["seal line"]
			control_pull = 2
		"witness_chime":
			behavior_signals = ["witness flare", "public verification", "noise stake"]
			ritual_hooks = ["heard answer"]
			resource_hooks = ["chime line"]
			control_pull = 2
		"echo_lure":
			behavior_signals = ["echo diversion", "watch bait", "counter-reading route"]
			anomaly_hooks = ["redirected echo", "counter-reading lure"]
			resource_hooks = ["false chorus"]
			control_pull = 3
			runtime_affordances["noise_trace_interval"] = mini(int(runtime_affordances.get("noise_trace_interval", 90)), 78)
		"burden_sling":
			behavior_signals = ["escort line", "burden relief", "carry answer"]
			ritual_hooks = ["shared burden"]
			resource_hooks = ["escort rig"]
			control_pull = 1
		"hush_bead":
			behavior_signals = ["quiet footing", "trace restraint", "measured carry"]
			ritual_hooks = ["held breath", "quiet charm"]
			resource_hooks = ["silent footing"]
			control_pull = 1
		"flare_ampoule":
			behavior_signals = ["public reveal", "rescue flare", "forced witness"]
			ritual_hooks = ["flare answer"]
			resource_hooks = ["single-use burst", "witness bloom"]
			control_pull = 2
		"oath_ribbon":
			behavior_signals = ["declared custody", "escort vow", "visible answer"]
			ritual_hooks = ["public vow", "burden oath"]
			resource_hooks = ["oath cost", "handoff promise"]
			control_pull = 3
		"doubt_ink":
			behavior_signals = ["smear pressure", "public doubt", "burden drag"]
			anomaly_hooks = ["ink suspicion", "residue escalation"]
			resource_hooks = ["trace stain"]
			control_pull = 2
		"echo_molt":
			behavior_signals = ["threshold surge", "unstable silhouette", "pursuit answer"]
			ritual_hooks = ["visible threshold"]
			anomaly_hooks = ["echo shell", "threshold release"]
			resource_hooks = ["metamorphosis pull"]
			control_pull = 3
	match category_id:
		"trinket":
			behavior_signals = _dedupe_strings(behavior_signals + ["micro-passive discipline"])
			ritual_hooks = _dedupe_strings(ritual_hooks + ["minor charm"])
			control_pull = maxi(control_pull, 1)
		"pickup":
			behavior_signals = _dedupe_strings(behavior_signals + ["burst opening"])
			resource_hooks = _dedupe_strings(resource_hooks + ["single-use burst"])
			control_pull = maxi(control_pull, 1)
		"covenant":
			behavior_signals = _dedupe_strings(behavior_signals + ["declared bargain"])
			ritual_hooks = _dedupe_strings(ritual_hooks + ["bargain price"])
			resource_hooks = _dedupe_strings(resource_hooks + ["oath cost"])
			control_pull = maxi(control_pull, 2)
		"curse":
			behavior_signals = _dedupe_strings(behavior_signals + ["negative burden"])
			anomaly_hooks = _dedupe_strings(anomaly_hooks + ["curse residue"])
			control_pull = maxi(control_pull, 2)
		"transformation":
			behavior_signals = _dedupe_strings(behavior_signals + ["threshold metamorphosis"])
			anomaly_hooks = _dedupe_strings(anomaly_hooks + ["silhouette mutation"])
			control_pull = maxi(control_pull, 3)
	return {
		"category": category_id,
		"economy_layer": item_ecology_layer(item_def_id),
		"latent_dimensions": Dictionary(narrative.get("latent_dimensions", {})).duplicate(true),
		"behavior_signals": behavior_signals,
		"protocol_affinity": _dedupe_strings(Array(narrative.get("protocol_affinity", []))),
		"branch_affinity": _dedupe_strings(Array(narrative.get("branch_affinity", []))),
		"ritual_hooks": ritual_hooks,
		"anomaly_hooks": anomaly_hooks,
		"resource_hooks": resource_hooks,
		"control_pull": control_pull,
		"runtime_affordances": runtime_affordances,
		"modifier_surfaces": build_modifier_registry(),
		"readability": category_readability_profile(get_category(item_def_id))
	}

func resolve_loadout_state(item_def_ids: Array[String], context: Dictionary = {}) -> Dictionary:
	var gameplay_profiles := {}
	for item_def_id in _dedupe_strings(item_def_ids):
		if get_definition(item_def_id).is_empty():
			continue
		gameplay_profiles[item_def_id] = _contextualized_gameplay_profile(item_def_id, context)
	return synergy_service.resolve(item_def_ids, gameplay_profiles, context)

func build_runtime_affordances(item_def_ids: Array[String], context: Dictionary = {}) -> Dictionary:
	var state: Dictionary = resolve_loadout_state(item_def_ids, context)
	var affordances: Dictionary = Dictionary(state.get("runtime_affordances", {})).duplicate(true)
	var category_counts := {}
	for item_def_id in item_def_ids:
		var category_id := get_category(item_def_id)
		category_counts[category_id] = int(category_counts.get(category_id, 0)) + 1
	affordances["build_identity"] = str(state.get("build_identity", "Mixed build"))
	affordances["build_scores"] = Dictionary(state.get("build_scores", {})).duplicate(true)
	affordances["behavior_signals"] = Array(state.get("behavior_signals", [])).duplicate()
	affordances["synergy_labels"] = Array(state.get("synergy_labels", [])).duplicate()
	affordances["ritual_hooks"] = Array(state.get("ritual_hooks", [])).duplicate()
	affordances["anomaly_hooks"] = Array(state.get("anomaly_hooks", [])).duplicate()
	affordances["protocol_hooks"] = Array(state.get("protocol_hooks", [])).duplicate()
	affordances["resource_signals"] = Array(state.get("resource_signals", [])).duplicate()
	affordances["latent_totals"] = Dictionary(state.get("latent_totals", {})).duplicate(true)
	affordances["combo_contract_version"] = int(state.get("combo_contract_version", 0))
	affordances["combo_contract_digest"] = str(state.get("combo_contract_digest", "")).strip_edges()
	affordances["combo_family_ids"] = Array(state.get("combo_family_ids", [])).duplicate(true)
	affordances["combo_entries"] = Array(state.get("combo_entries", [])).duplicate(true)
	affordances["combo_pressure_tags"] = Array(state.get("combo_pressure_tags", [])).duplicate(true)
	affordances["public_surface_tags"] = Array(state.get("public_surface_tags", [])).duplicate(true)
	affordances["modifier_surfaces"] = build_modifier_registry()
	affordances["category_counts"] = category_counts
	affordances["forbidden_combo_failures"] = forbidden_combo_failures(item_def_ids)
	affordances["active_covenant_ids"] = active_covenant_item_ids_for_items(item_def_ids, context)
	affordances["active_transformation_ids"] = active_transformation_item_ids_for_items(item_def_ids, context)
	affordances["dormant_transformation_ids"] = dormant_transformation_item_ids_for_items(item_def_ids, context)
	return affordances

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
	return float(build_runtime_affordances(item_def_ids).get("light_scale", 1.0))

func noise_trace_interval_for_items(item_def_ids: Array[String]) -> int:
	return int(build_runtime_affordances(item_def_ids).get("noise_trace_interval", 90))

func carry_speed_multiplier_for_items(item_def_ids: Array[String]) -> float:
	return float(build_runtime_affordances(item_def_ids).get("carry_speed_mult", 1.0))

func move_speed_multiplier_for_items(item_def_ids: Array[String]) -> float:
	return float(build_runtime_affordances(item_def_ids).get("move_speed_mult", 1.0))

func jump_velocity_multiplier_for_items(item_def_ids: Array[String]) -> float:
	return float(build_runtime_affordances(item_def_ids).get("jump_velocity_mult", 1.0))

func footprint_interval_for_items(item_def_ids: Array[String]) -> int:
	return int(build_runtime_affordances(item_def_ids).get("footprint_interval", 48))

func footprint_scale_for_items(item_def_ids: Array[String]) -> float:
	return float(build_runtime_affordances(item_def_ids).get("footprint_scale", 0.8))

func warden_score_bonus_for_items(_item_def_ids: Array[String], _room_recently_disturbed: bool) -> int:
	return 0

func active_item_ids_for_items(item_def_ids: Array[String]) -> Array[String]:
	var active_ids: Array[String] = []
	for def_id in _dedupe_strings(item_def_ids):
		if get_definition(def_id).is_empty():
			continue
		if bool(get_definition(def_id).get("active_use", false)):
			active_ids.append(def_id)
	return active_ids

func is_active_use_item(item_def_id: String) -> bool:
	return bool(get_definition(item_def_id).get("active_use", false))

func get_use_label(item_def_id: String) -> String:
	return str(get_definition(item_def_id).get("use_label", get_display_name(item_def_id)))

func active_covenant_item_ids_for_items(item_def_ids: Array[String], context: Dictionary = {}) -> Array[String]:
	var active_ids: Array[String] = []
	for item_def_id in _dedupe_strings(item_def_ids):
		if get_category(item_def_id) != "covenant":
			continue
		if _covenant_is_active(item_def_id, context):
			active_ids.append(item_def_id)
	return active_ids

func active_transformation_item_ids_for_items(item_def_ids: Array[String], context: Dictionary = {}) -> Array[String]:
	var active_ids: Array[String] = []
	for item_def_id in _dedupe_strings(item_def_ids):
		if get_category(item_def_id) != "transformation":
			continue
		if _transformation_is_active(item_def_id, context):
			active_ids.append(item_def_id)
	return active_ids

func dormant_transformation_item_ids_for_items(item_def_ids: Array[String], context: Dictionary = {}) -> Array[String]:
	var dormant_ids: Array[String] = []
	for item_def_id in _dedupe_strings(item_def_ids):
		if get_category(item_def_id) != "transformation":
			continue
		if not _transformation_is_active(item_def_id, context):
			dormant_ids.append(item_def_id)
	return dormant_ids

func _default_runtime_affordances() -> Dictionary:
	return {
		"light_scale": 1.0,
		"move_speed_mult": 1.0,
		"jump_velocity_mult": 1.0,
		"carry_speed_mult": 1.0,
		"noise_trace_interval": 90,
		"footprint_interval": 48,
		"footprint_scale": 0.8
	}

func _contextualized_gameplay_profile(item_def_id: String, context: Dictionary = {}) -> Dictionary:
	var profile := build_gameplay_profile(item_def_id)
	profile["runtime_affordances"] = _contextual_runtime_affordances(item_def_id, Dictionary(profile.get("runtime_affordances", {})).duplicate(true), context)
	return profile

func _contextual_runtime_affordances(item_def_id: String, base_affordances: Dictionary, context: Dictionary = {}) -> Dictionary:
	var category_id := get_category(item_def_id)
	var affordances := _default_runtime_affordances()
	for key in base_affordances.keys():
		affordances[str(key)] = base_affordances.get(key)
	match category_id:
		"pickup":
			return _default_runtime_affordances()
		"covenant":
			if not _covenant_is_active(item_def_id, context):
				return _default_runtime_affordances()
		"transformation":
			if not _transformation_is_active(item_def_id, context):
				return _default_runtime_affordances()
	return affordances

func _covenant_is_active(item_def_id: String, context: Dictionary = {}) -> bool:
	var definition := get_definition(item_def_id)
	if canonical_category(str(definition.get("category", ""))) != "covenant":
		return false
	match str(definition.get("activation_condition", "")).strip_edges():
		"artifact_carry":
			return bool(context.get("carrying_artifact", false))
		_:
			return true

func _transformation_is_active(item_def_id: String, context: Dictionary = {}) -> bool:
	var definition := get_definition(item_def_id)
	if canonical_category(str(definition.get("category", ""))) != "transformation":
		return false
	var explicitly_active := _string_array(context.get("active_transformation_ids", []))
	if explicitly_active.has(item_def_id):
		return true
	var threshold_kind := str(definition.get("threshold_kind", "")).strip_edges()
	var threshold_value := maxi(int(definition.get("threshold_value", 0)), 0)
	if threshold_kind.is_empty() or threshold_value <= 0:
		return false
	return _threshold_score_for_context(threshold_kind, context) >= threshold_value

func _threshold_score_for_context(threshold_kind: String, context: Dictionary = {}) -> int:
	match threshold_kind.strip_edges():
		"echo_pressure":
			if context.has("echo_pressure_score"):
				return int(context.get("echo_pressure_score", 0))
			var score := 0
			if bool(context.get("ghost_active", false)):
				score += 1
			if bool(context.get("predator_pressure", false)):
				score += 1
			if bool(context.get("protocol_watch_pressure", false)):
				score += 1
			score += maxi(int(context.get("anomaly_bias", 0)), 0)
			return score
		_:
			return 0

func world_pos_for_spawn_for_test(room_slot: int, room_type: String, item_def_id: String) -> Vector2:
	return _world_pos_for_item_spawn(room_slot, room_type, item_def_id)

func _pick_item_for_room(seed_value: int, room: Dictionary, room_count: int, spawned_counts: Dictionary = {}, last_item_def_id: String = "", directive: Dictionary = {}) -> String:
	var room_slot := int(room.get("slot", -1))
	var candidate_ids := _spawn_candidate_item_ids(room, room_count, spawned_counts, directive)
	var reserve_candidates: Array[String] = []
	for candidate_id in candidate_ids:
		if RESERVE_ITEM_IDS.has(candidate_id):
			reserve_candidates.append(candidate_id)
	var reserve_count := _total_reserve_spawn_count(spawned_counts)
	var force_reserve := _should_force_reserve_spawn(room_slot, room_count, reserve_count, reserve_candidates)
	var weighted_ids: Array[String] = []
	for item_id in candidate_ids:
		if force_reserve and not RESERVE_ITEM_IDS.has(item_id):
			continue
		var weight := _room_weight_for_item(item_id, str(room.get("type", "traversal")))
		weight += _phase_bonus_for_item(item_id, room_slot, room_count)
		weight += _directive_bonus_for_item(item_id, directive, room)
		weight += _reserve_spawn_bonus_for_item(item_id, room, room_count, directive)
		if RESERVE_ITEM_IDS.has(item_id):
			if reserve_count == 0:
				weight += 4
			elif reserve_count == 1 and room_slot >= maxi(int(room_count / 2), 2):
				weight += 3
			if _spawned_category_count(spawned_counts, get_category(item_id)) == 0:
				weight += 2
			if room_slot >= maxi(int(room_count / 3), 1) and reserve_count < 2:
				weight += 2
		weight = maxi(weight, 1)
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

func candidate_spawn_item_ids_for_room_for_test(room: Dictionary, room_count: int, spawned_counts: Dictionary = {}, directive: Dictionary = {}) -> Array[String]:
	return _spawn_candidate_item_ids(room, room_count, spawned_counts, directive)

func _spawn_candidate_item_ids(room: Dictionary, room_count: int, spawned_counts: Dictionary, directive: Dictionary = {}) -> Array[String]:
	var candidate_ids: Array[String] = ITEM_IDS.duplicate()
	for reserve_item_id in RESERVE_ITEM_IDS:
		if _reserve_item_is_spawn_eligible(reserve_item_id, room, room_count, spawned_counts, directive):
			candidate_ids.append(reserve_item_id)
	return candidate_ids

func _reserve_item_is_spawn_eligible(item_def_id: String, room: Dictionary, room_count: int, spawned_counts: Dictionary, directive: Dictionary = {}) -> bool:
	var category_id := get_category(item_def_id)
	if not RESERVE_SPAWN_CATEGORY_CAPS.has(category_id):
		return false
	if _total_reserve_spawn_count(spawned_counts) >= MAX_RESERVE_SPAWNS_PER_EXPEDITION:
		return false
	if int(spawned_counts.get(item_def_id, 0)) > 0:
		return false
	var category_cap := int(RESERVE_SPAWN_CATEGORY_CAPS.get(category_id, 0))
	if category_cap > 0 and _spawned_category_count(spawned_counts, category_id) >= category_cap:
		return false
	if _reserve_intensity_band(category_id) == "high" and _spawned_reserve_intensity_count(spawned_counts, "high") >= MAX_HIGH_INTENSITY_RESERVE_SPAWNS:
		return false
	var room_slot := int(room.get("slot", -1))
	var room_type := str(room.get("type", "traversal"))
	var branch_family := str(room.get("branch_family_id", "")).strip_edges()
	var item_ecology_bias := str(directive.get("item_ecology_bias", "")).to_lower()
	var group_tension_bias := str(directive.get("group_tension_bias", "")).to_lower()
	var archive_tone := str(directive.get("archive_tone", "")).to_lower()
	var convergence_axis := str(directive.get("convergence_axis", "")).to_lower()
	var pressure_tokens := _pressure_tokens(directive)
	var ontology_route_tags := _ontology_route_tags(directive)
	var ontology_item_tags := _ontology_item_tags(directive)
	match category_id:
		"trinket":
			if room_type not in ["traversal", "evidence"]:
				return false
			return room_slot < maxi(room_count - 2, 1) or item_ecology_bias.find("memory") != -1 or archive_tone.find("memory") != -1 or ontology_item_tags.has("archive_residue") or ontology_route_tags.has("rediscovery_loop")
		"pickup":
			if room_type not in ["hazard", "evidence"]:
				return false
			return room_type == "hazard" or pressure_tokens.has("exposure") or pressure_tokens.has("convergence") or item_ecology_bias.find("rescue") != -1 or branch_family in ["relay_hollows", "oath_terraces", "grave_lattice"] or ontology_route_tags.has("taboo_threshold")
		"covenant":
			if room_type != "evidence" and branch_family != "oath_terraces":
				return false
			if room_slot < maxi(int(room_count / 3), 1) and branch_family != "oath_terraces":
				return false
			return item_ecology_bias.find("burden") != -1 or item_ecology_bias.find("rescue") != -1 or convergence_axis.find("custody") != -1 or archive_tone.find("custody") != -1 or pressure_tokens.has("convergence") or pressure_tokens.has("exposure") or branch_family == "oath_terraces" or ontology_route_tags.has("ritual_commitment")
		"curse":
			if room_type == "traversal" and branch_family not in ["grave_lattice", "murmur_warrens"]:
				return false
			if room_slot < maxi(int(room_count / 3), 1) and branch_family not in ["grave_lattice", "murmur_warrens"]:
				return false
			return item_ecology_bias.find("deception") != -1 or item_ecology_bias.find("scarcity") != -1 or group_tension_bias.find("ambiguous") != -1 or convergence_axis.find("fragment") != -1 or archive_tone.find("dispute") != -1 or pressure_tokens.has("fragmentation") or pressure_tokens.has("exposure") or branch_family in ["grave_lattice", "murmur_warrens"] or ontology_route_tags.has("taboo_threshold")
		"transformation":
			if room_slot < maxi(int(room_count * 2 / 3), 4):
				return false
			if room_type not in ["hazard", "traversal"]:
				return false
			return _transformation_spawn_bias(directive, room) or ontology_route_tags.has("rediscovery_loop") or (room_type == "hazard" and (pressure_tokens.has("exposure") or branch_family in ["grave_lattice", "murmur_warrens"]))
		_:
			return false

func _reserve_spawn_bonus_for_item(item_def_id: String, room: Dictionary, room_count: int, directive: Dictionary = {}) -> int:
	if not RESERVE_ITEM_IDS.has(item_def_id):
		return 0
	var category_id := get_category(item_def_id)
	var room_type := str(room.get("type", "traversal"))
	var room_slot := int(room.get("slot", -1))
	var branch_family := str(room.get("branch_family_id", "")).strip_edges()
	var ontology_route_tags := _ontology_route_tags(directive)
	var bonus := 0
	match category_id:
		"trinket":
			bonus += 3 if room_type == "traversal" else 2
			if room_slot < maxi(int(room_count / 3), 2):
				bonus += 1
		"pickup":
			bonus += 5 if room_type == "hazard" else 2
			if branch_family in ["relay_hollows", "grave_lattice"]:
				bonus += 1
		"covenant":
			bonus += 7 if room_type == "evidence" else 2
			if branch_family == "oath_terraces":
				bonus += 4
			if room_slot >= maxi(int(room_count / 2), 2):
				bonus += 1
			if ontology_route_tags.has("ritual_commitment"):
				bonus += 2
		"curse":
			bonus += 5 if room_type == "hazard" else 2
			if branch_family in ["grave_lattice", "murmur_warrens"]:
				bonus += 3
			if room_slot >= maxi(int(room_count / 2), 2):
				bonus += 1
			if ontology_route_tags.has("taboo_threshold"):
				bonus += 2
		"transformation":
			bonus += 4 if room_type == "hazard" else 1
			if _transformation_spawn_bias(directive, room):
				bonus += 2
			if branch_family in ["grave_lattice", "murmur_warrens"]:
				bonus += 1
			if room_slot >= maxi(int(room_count * 2 / 3), 2):
				bonus += 1
			if ontology_route_tags.has("rediscovery_loop"):
				bonus += 2
	return bonus

func _transformation_spawn_bias(directive: Dictionary, room: Dictionary = {}) -> bool:
	var item_ecology_bias := str(directive.get("item_ecology_bias", "")).to_lower()
	var archive_tone := str(directive.get("archive_tone", "")).to_lower()
	var convergence_axis := str(directive.get("convergence_axis", "")).to_lower()
	var branch_family := str(room.get("branch_family_id", "")).strip_edges()
	var pressure_tokens := _pressure_tokens(directive)
	var ontology_route_tags := _ontology_route_tags(directive)
	return pressure_tokens.has("exposure") \
		or pressure_tokens.has("fragmentation") \
		or int(Dictionary(directive.get("cookbook_routing", {})).get("counter_reading", 0)) > 0 \
		or int(Dictionary(directive.get("cookbook_routing", {})).get("anti_protocol_pull", 0)) > 0 \
		or item_ecology_bias.find("deception") != -1 \
		or item_ecology_bias.find("scarcity") != -1 \
		or archive_tone.find("memory") != -1 \
		or convergence_axis.find("fragment") != -1 \
		or ontology_route_tags.has("rediscovery_loop") \
		or branch_family in ["grave_lattice", "murmur_warrens"]

func _spawned_category_count(spawned_counts: Dictionary, category_id: String) -> int:
	var total := 0
	for item_id_variant in spawned_counts.keys():
		var item_id := str(item_id_variant)
		if get_category(item_id) != category_id:
			continue
		total += int(spawned_counts.get(item_id_variant, 0))
	return total

func _total_reserve_spawn_count(spawned_counts: Dictionary) -> int:
	var total := 0
	for item_id_variant in spawned_counts.keys():
		if not RESERVE_ITEM_IDS.has(str(item_id_variant)):
			continue
		total += int(spawned_counts.get(item_id_variant, 0))
	return total

func _reserve_intensity_band(category_id: String) -> String:
	match canonical_category(category_id):
		"covenant", "curse", "transformation":
			return "high"
		"pickup":
			return "medium"
		"trinket":
			return "low"
		_:
			return "none"

func _spawned_reserve_intensity_count(spawned_counts: Dictionary, band: String) -> int:
	var total := 0
	for item_id_variant in spawned_counts.keys():
		var item_id := str(item_id_variant)
		if not RESERVE_ITEM_IDS.has(item_id):
			continue
		if _reserve_intensity_band(get_category(item_id)) != band:
			continue
		total += int(spawned_counts.get(item_id_variant, 0))
	return total

func _should_force_reserve_spawn(room_slot: int, room_count: int, reserve_count: int, reserve_candidates: Array[String]) -> bool:
	if reserve_candidates.is_empty():
		return false
	if reserve_count <= 0 and room_slot >= maxi(int(room_count / 3), 2):
		return true
	if reserve_count == 1 and room_slot >= maxi(int(room_count * 2 / 3), 4):
		return true
	return false

func directive_bonus_for_item_for_test(item_def_id: String, directive: Dictionary, room: Dictionary = {}) -> int:
	return _directive_bonus_for_item(item_def_id, RUN_GENERATOR_SCRIPT.new().build_generation_contract(0, directive), room)

func _directive_bonus_for_item(item_def_id: String, directive: Dictionary, room: Dictionary = {}) -> int:
	var generation_contract := directive.duplicate(true)
	var protocol_state := str(generation_contract.get("protocol_state", "")).strip_edges()
	var narrative: Dictionary = build_narrative_profile(item_def_id)
	var gameplay: Dictionary = build_gameplay_profile(item_def_id)
	var latent: Dictionary = Dictionary(gameplay.get("latent_dimensions", {}))
	var market_routing: Dictionary = Dictionary(generation_contract.get("market_routing", {}))
	var branch_affinity := _string_array(narrative.get("branch_affinity", []))
	var protocol_affinity := _string_array(narrative.get("protocol_affinity", []))
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var group_tension_bias := str(generation_contract.get("group_tension_bias", "")).to_lower()
	var archive_tone := str(generation_contract.get("archive_tone", "")).to_lower()
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).to_lower()
	var cookbook_routing: Dictionary = Dictionary(generation_contract.get("cookbook_routing", {}))
	var civilization_routing: Dictionary = Dictionary(generation_contract.get("civilization_routing", {}))
	var ontology_item_tags := _ontology_item_tags(generation_contract)
	var ontology_route_tags := _ontology_route_tags(generation_contract)
	var dominant_forces := _force_tokens(generation_contract)
	var pressure_ids := _pressure_tokens(generation_contract)
	var dominant_minds := _mind_tokens(generation_contract)
	var pacing_id := _pacing_token(generation_contract)
	var bonus := 0
	if item_ecology_bias.find("burden") != -1:
		bonus += int(latent.get("burden", 0)) + int(latent.get("rescue", 0)) / 2
	if item_ecology_bias.find("deception") != -1 or item_ecology_bias.find("scandal") != -1:
		bonus += int(latent.get("deception", 0)) + int(latent.get("instability", 0)) / 2
	if archive_tone.find("memory") != -1 or archive_tone.find("custody") != -1:
		bonus += int(latent.get("ritual_significance", 0)) + int(latent.get("anti_protocol_potential", 0)) / 2
	if item_ecology_bias.find("scarcity") != -1:
		bonus += int(latent.get("scarcity", 0)) + int(latent.get("burden", 0)) / 2
	if item_ecology_bias.find("rescue") != -1:
		bonus += int(latent.get("rescue", 0)) + int(latent.get("traversal", 0)) / 2
	if pressure_ids.has("misdirection") or pressure_ids.has("fragmentation"):
		bonus += int(latent.get("deception", 0)) + int(latent.get("instability", 0)) / 2
	if pressure_ids.has("convergence"):
		bonus += int(latent.get("rescue", 0)) + int(latent.get("traversal", 0)) / 2
	if pressure_ids.has("scarcity"):
		bonus += int(latent.get("scarcity", 0))
	if pressure_ids.has("delay"):
		bonus += int(latent.get("ritual_significance", 0)) / 2
	if pressure_ids.has("exposure"):
		bonus += int(latent.get("witness_visibility", 0)) / 2
	if dominant_minds.has("trickster"):
		bonus += int(latent.get("deception", 0)) + int(latent.get("anti_protocol_potential", 0)) / 2
	if dominant_minds.has("archivist"):
		bonus += int(latent.get("ritual_significance", 0))
	if dominant_minds.has("cartographer"):
		bonus += int(latent.get("traversal", 0))
	if dominant_minds.has("warden"):
		bonus += int(latent.get("burden", 0)) + int(latent.get("scarcity", 0)) / 2
	if dominant_minds.has("examiner"):
		bonus += int(latent.get("witness_visibility", 0)) / 2
	if dominant_forces.has("discovery"):
		bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("traversal", 0)) / 2
	if dominant_forces.has("memory"):
		bonus += int(latent.get("ritual_significance", 0)) / 2
	if dominant_forces.has("deception"):
		bonus += int(latent.get("deception", 0)) / 2
	if dominant_forces.has("containment"):
		bonus += int(latent.get("burden", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	bonus += _market_bonus_for_item(latent, market_routing)
	bonus += _lifecycle_bonus_for_item(item_def_id, latent, generation_contract, room)
	bonus += _public_summary_bonus_for_item(latent, generation_contract)
	if protocol_state == "Exposure Protocol":
		bonus += int(latent.get("scarcity", 0)) / 2
	if protocol_state == "Intimate Protocol":
		bonus += int(latent.get("rescue", 0)) / 2
	if pacing_id in ["volatile", "escalating"]:
		bonus += int(latent.get("instability", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	if group_tension_bias.find("trust") != -1:
		bonus += int(latent.get("deception", 0)) / 2
	if group_tension_bias.find("ambiguous") != -1 or convergence_axis.find("fragment") != -1:
		bonus += int(latent.get("witness_visibility", 0)) / 2
	if int(cookbook_routing.get("fragmentary_reading", 0)) > 0:
		bonus += int(latent.get("ritual_significance", 0)) + int(latent.get("anti_protocol_potential", 0)) / 2
	if int(cookbook_routing.get("holder_network", 0)) > 0:
		bonus += int(latent.get("anti_protocol_potential", 0)) + int(latent.get("deception", 0)) / 2
	if int(cookbook_routing.get("counter_reading", 0)) > 0:
		bonus += int(latent.get("anti_protocol_potential", 0)) + int(latent.get("witness_visibility", 0)) / 2
	if int(cookbook_routing.get("anti_protocol_pull", 0)) > 0:
		bonus += int(latent.get("anti_protocol_potential", 0)) + int(latent.get("traversal", 0)) / 2
	if int(civilization_routing.get("legitimacy_custody", 0)) > 0:
		bonus += int(latent.get("burden", 0)) / 2 + int(latent.get("rescue", 0)) / 2 + int(latent.get("ritual_significance", 0)) / 2
	if int(civilization_routing.get("taboo_silence", 0)) > 0:
		bonus += int(latent.get("anti_protocol_potential", 0)) / 2 + int(latent.get("instability", 0)) / 2
	if int(civilization_routing.get("canon_conflict", 0)) > 0:
		bonus += int(latent.get("deception", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
	if int(civilization_routing.get("sacred_order", 0)) > 0:
		bonus += int(latent.get("ritual_significance", 0)) + int(latent.get("burden", 0)) / 2
	if int(civilization_routing.get("mourning_climate", 0)) > 0:
		bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("ritual_significance", 0)) / 2
	if int(civilization_routing.get("ontology_heat", 0)) > 0:
		bonus += int(latent.get("anti_protocol_potential", 0)) / 2 + int(latent.get("deception", 0)) / 2 + int(latent.get("traversal", 0)) / 2
	if ontology_item_tags.has("verification_dispute"):
		bonus += int(latent.get("witness_visibility", 0)) / 2 + int(latent.get("deception", 0)) / 2
	if ontology_item_tags.has("archive_residue"):
		bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	if ontology_item_tags.has("ritual_significance") or ontology_route_tags.has("ritual_commitment"):
		bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("burden", 0)) / 2
	if ontology_item_tags.has("rediscovered_tooling"):
		bonus += int(latent.get("instability", 0)) / 2 + int(latent.get("traversal", 0)) / 2
	var room_branch := str(room.get("branch_family_id", "")).replace("_", " ").to_lower()
	if not room_branch.is_empty() and branch_affinity.has(room_branch):
		bonus += 5
	var room_protocol := _protocol_affinity_token(str(room.get("protocol_state", protocol_state)))
	if not room_protocol.is_empty() and protocol_affinity.has(room_protocol):
		bonus += 3
	bonus += _room_context_bonus_for_item(latent, room)
	return bonus

func _market_bonus_for_item(latent: Dictionary, market_routing: Dictionary) -> int:
	var bonus := 0
	if int(market_routing.get("market_volatility", 0)) > 0:
		bonus += int(latent.get("instability", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	if int(market_routing.get("prestige_pressure", 0)) > 0:
		bonus += int(latent.get("witness_visibility", 0)) / 2 + int(latent.get("ritual_significance", 0)) / 2
	if int(market_routing.get("hoard_visibility", 0)) > 0:
		bonus += int(latent.get("scarcity", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
	if int(market_routing.get("scarcity_recovery", 0)) > 0 or int(market_routing.get("recovery_credit", 0)) >= 2:
		bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("traversal", 0)) / 2
	if int(market_routing.get("carrier_risk_bias", 0)) > 0:
		bonus += int(latent.get("burden", 0)) / 2 + int(latent.get("rescue", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
	for regime_id in _string_array(market_routing.get("active_regime_ids", [])):
		match regime_id:
			"market_extraction_austerity":
				bonus += int(latent.get("scarcity", 0)) + int(latent.get("burden", 0)) / 2
			"market_prestige_showcase":
				bonus += int(latent.get("witness_visibility", 0)) + int(latent.get("ritual_significance", 0)) / 2
			"market_recovery_weave":
				bonus += int(latent.get("rescue", 0)) + int(latent.get("traversal", 0)) / 2
			"market_distortion_spike":
				bonus += int(latent.get("deception", 0)) + int(latent.get("instability", 0)) / 2
	return bonus

func _lifecycle_bonus_for_item(item_def_id: String, latent: Dictionary, generation_contract: Dictionary, room: Dictionary = {}) -> int:
	var bonus := 0
	var lifecycle_routing: Dictionary = Dictionary(generation_contract.get("lifecycle_routing", {}))
	var room_branch := str(room.get("branch_family_id", "")).to_lower()
	for family_raw in Array(lifecycle_routing.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_kind := str(family.get("family_kind", "")).strip_edges()
		var source_id := str(family.get("source_id", "")).strip_edges()
		var heat := int(family.get("heat", 0))
		var cooldown_band := str(family.get("cooldown_band", "open")).strip_edges()
		var routing_tags := _string_array(family.get("routing_tags", []))
		if family_kind == "combo_family" and heat >= 3:
			if _lifecycle_tag_match(routing_tags, ["route", "return", "artifact_custody"]):
				bonus += int(latent.get("traversal", 0)) / 2 + int(latent.get("rescue", 0)) / 2
			if _lifecycle_tag_match(routing_tags, ["memory", "witness", "combo_private_archive_ritual"]):
				bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
			if cooldown_band == "deep_cooling":
				bonus += maxi(int(latent.get("instability", 0)) / 2, 1)
		elif family_kind == "artifact_continuity":
			match source_id:
				"burial", "archive_only_residue":
					bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("burden", 0)) / 2
				"recoverable_loss", "successor_emergence":
					bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("traversal", 0)) / 2
				"extinction":
					bonus += int(latent.get("scarcity", 0)) / 2 + int(latent.get("burden", 0)) / 2
			if cooldown_band in ["cooling", "warming"] and room_branch.find("relay") != -1:
				bonus += 1
	if item_def_id == "burden_sling" and room_branch.find("oath") != -1:
		bonus += 1
	return bonus

func _lifecycle_tag_match(tags: Array[String], needles: Array[String]) -> bool:
	for tag in tags:
		var lowered := tag.to_lower()
		for needle in needles:
			if lowered.find(needle) != -1:
				return true
	return false

func _public_summary_bonus_for_item(latent: Dictionary, generation_contract: Dictionary) -> int:
	var bonus := 0
	var dominant_forces := _force_tokens(generation_contract)
	var pressure_verbs := _pressure_tokens(generation_contract)
	var item_ecology_bias := str(generation_contract.get("item_ecology_bias", "")).to_lower()
	var archive_tone := str(generation_contract.get("archive_tone", "")).to_lower()
	var group_tension_bias := str(generation_contract.get("group_tension_bias", "")).to_lower()
	var convergence_axis := str(generation_contract.get("convergence_axis", "")).to_lower()
	var ontology_item_tags := _ontology_item_tags(generation_contract)
	var ontology_route_tags := _ontology_route_tags(generation_contract)
	if dominant_forces.has("discovery"):
		bonus += int(latent.get("traversal", 0)) / 2 + int(latent.get("rescue", 0)) / 2
	if dominant_forces.has("memory") or archive_tone.find("memory") != -1:
		bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	if dominant_forces.has("deception") or group_tension_bias.find("fault") != -1 or group_tension_bias.find("ambiguous") != -1:
		bonus += int(latent.get("deception", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
	if pressure_verbs.has("exposure"):
		bonus += int(latent.get("witness_visibility", 0)) / 2
	bonus += _text_axis_bonus(item_ecology_bias, latent)
	if convergence_axis.find("fragment") != -1:
		bonus += int(latent.get("deception", 0)) / 2 + int(latent.get("instability", 0)) / 2
	elif convergence_axis.find("custody") != -1 or convergence_axis.find("converg") != -1:
		bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("burden", 0)) / 2
	if archive_tone.find("memory") != -1 or archive_tone.find("custody") != -1:
		bonus += int(latent.get("ritual_significance", 0)) / 2
	elif archive_tone.find("forensic") != -1 or archive_tone.find("dispute") != -1:
		bonus += int(latent.get("witness_visibility", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	if group_tension_bias.find("fault") != -1 or group_tension_bias.find("ambiguous") != -1:
		bonus += int(latent.get("deception", 0)) / 2
	if ontology_item_tags.has("verification_dispute"):
		bonus += int(latent.get("witness_visibility", 0)) / 2
	if ontology_item_tags.has("archive_residue"):
		bonus += int(latent.get("ritual_significance", 0)) / 2
	if ontology_route_tags.has("rediscovery_loop"):
		bonus += int(latent.get("instability", 0)) / 2
	return bonus

func _room_context_bonus_for_item(latent: Dictionary, room: Dictionary) -> int:
	var room_context: Dictionary = Dictionary(room.get("branch_context", {}))
	if room_context.is_empty():
		return 0
	var bonus := 0
	var constitution_summary: Dictionary = Dictionary(room_context.get("constitution_summary", room_context.get("directive_summary", {})))
	var dominant_forces := _force_tokens(constitution_summary)
	var pressure_verbs := _pressure_tokens(constitution_summary)
	var item_ecology_bias := str(constitution_summary.get("item_ecology_bias", "")).to_lower()
	var archive_tone := str(constitution_summary.get("archive_tone", "")).to_lower()
	var convergence_axis := str(Dictionary(room_context.get("run_identity_summary", {})).get("convergence_axis", constitution_summary.get("convergence_axis", ""))).to_lower()
	var slot_band := str(room_context.get("slot_band", ""))
	var symbolic_anchor := str(room_context.get("symbolic_anchor", "")).to_lower()
	var reputation_seeds := _string_array(room_context.get("reputation_seeds", []))
	var surface_lines := _string_array(Dictionary(room_context.get("surface_summary", {})).get("lines", []))
	var ontology_item_tags := _ontology_item_tags(room_context.get("constitution_summary", {}))
	if dominant_forces.has("discovery"):
		bonus += int(latent.get("traversal", 0)) / 2 + int(latent.get("rescue", 0)) / 2
	if dominant_forces.has("memory") or archive_tone.find("memory") != -1:
		bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	if dominant_forces.has("deception") or pressure_verbs.has("fragmentation"):
		bonus += int(latent.get("deception", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
	bonus += _text_axis_bonus(item_ecology_bias, latent)
	if convergence_axis.find("fragment") != -1:
		bonus += int(latent.get("deception", 0)) / 2 + int(latent.get("instability", 0)) / 2
	elif convergence_axis.find("custody") != -1 or convergence_axis.find("converg") != -1:
		bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("burden", 0)) / 2
	if archive_tone.find("memory") != -1 or archive_tone.find("custody") != -1:
		bonus += int(latent.get("ritual_significance", 0)) / 2
	elif archive_tone.find("forensic") != -1 or archive_tone.find("dispute") != -1:
		bonus += int(latent.get("witness_visibility", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	match symbolic_anchor:
		"relay gate", "bridge", "regroup lane", "handoff point", "handoff arch", "threshold":
			bonus += int(latent.get("traversal", 0)) / 2 + int(latent.get("rescue", 0)) / 2
		"pedestal", "drop line", "return threshold", "vault route":
			bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	if slot_band == "deep":
		bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("scarcity", 0)) / 2
	for seed in reputation_seeds:
		var lowered := seed.to_lower()
		if lowered.find("recovery") != -1 or lowered.find("retreat") != -1 or lowered.find("escort") != -1 or lowered.find("handoff") != -1:
			bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("burden", 0)) / 2
		elif lowered.find("temptation") != -1 or lowered.find("cursed") != -1 or lowered.find("conflict") != -1 or lowered.find("cutoff") != -1:
			bonus += int(latent.get("deception", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
		if lowered.find("witness") != -1 or lowered.find("public") != -1:
			bonus += int(latent.get("witness_visibility", 0)) / 2
		if lowered.find("value") != -1:
			bonus += int(latent.get("scarcity", 0)) / 2
	for line in surface_lines:
		var lowered_line := line.to_lower()
		if lowered_line.find("rescue") != -1:
			bonus += int(latent.get("rescue", 0)) / 2
		elif lowered_line.find("residue") != -1 or lowered_line.find("proof") != -1 or lowered_line.find("ritual") != -1:
			bonus += int(latent.get("ritual_significance", 0)) / 2 + int(latent.get("witness_visibility", 0)) / 2
		if lowered_line.find("public answer") != -1 or lowered_line.find("witness") != -1:
			bonus += int(latent.get("witness_visibility", 0)) / 2
		if lowered_line.find("artifact") != -1 or lowered_line.find("custody") != -1:
			bonus += int(latent.get("ritual_significance", 0)) / 2
	if ontology_item_tags.has("verification_dispute"):
		bonus += int(latent.get("witness_visibility", 0)) / 2
	if ontology_item_tags.has("archive_residue"):
		bonus += int(latent.get("ritual_significance", 0)) / 2
	return bonus

func _ontology_route_tags(contract_like: Variant) -> Array[String]:
	return _string_array(Dictionary(Dictionary(contract_like).get("ontology_routing", {})).get("route_bias_tags", []))

func _ontology_item_tags(contract_like: Variant) -> Array[String]:
	return _string_array(Dictionary(Dictionary(contract_like).get("ontology_routing", {})).get("item_bias_tags", []))

func _text_axis_bonus(summary_text: String, latent: Dictionary) -> int:
	var bonus := 0
	if summary_text.find("rescue") != -1:
		bonus += int(latent.get("rescue", 0)) / 2 + int(latent.get("traversal", 0)) / 2
	if summary_text.find("burden") != -1 or summary_text.find("custody") != -1:
		bonus += int(latent.get("burden", 0)) / 2 + int(latent.get("ritual_significance", 0)) / 2
	if summary_text.find("deception") != -1 or summary_text.find("scandal") != -1:
		bonus += int(latent.get("deception", 0)) / 2 + int(latent.get("instability", 0)) / 2
	if summary_text.find("scarcity") != -1:
		bonus += int(latent.get("scarcity", 0)) / 2
	return bonus

func _pressure_tokens(contract_like: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var values := _string_array(contract_like.get("pressure_verbs", contract_like.get("pressure_grammar", [])))
	for value in values:
		var token := value.to_lower().replace(" ", "_")
		if not token.is_empty() and not result.has(token):
			result.append(token)
	return result

func _mind_tokens(contract_like: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in _string_array(contract_like.get("dominant_minds", [])):
		var lowered := value.to_lower()
		for token in ["cartographer", "trickster", "archivist", "warden", "examiner"]:
			if lowered.find(token) != -1 and not result.has(token):
				result.append(token)
	return result

func _force_tokens(contract_like: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for value in _string_array(contract_like.get("dominant_forces", [])):
		var lowered := value.to_lower()
		for token in ["discovery", "deception", "memory", "containment", "trial"]:
			if lowered.find(token) != -1 and not result.has(token):
				result.append(token)
	return result

func _pacing_token(contract_like: Dictionary) -> String:
	var lowered := str(contract_like.get("pacing_profile", "")).to_lower().strip_edges()
	for token in ["volatile", "escalating", "calm", "steady"]:
		if lowered.find(token) != -1:
			return token
	return lowered

func _protocol_affinity_token(protocol_state: String) -> String:
	match protocol_state.strip_edges():
		"Expedition Protocol":
			return "expedition"
		"Fracture Protocol":
			return "fracture"
		"Intimate Protocol":
			return "intimate"
		"Exposure Protocol":
			return "exposure"
	return ""

func _total_room_weight(room_type: String) -> int:
	var total := 0
	for item_id in live_item_ids():
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
			"zipline_kit", "heavy_boots", "burden_sling":
				return 3
			"timeline_bookmark", "custody_seal":
				return 2
			"hush_bead":
				return 2
			"lantern_snuffer":
				return 1
			_:
				return 0
	if room_slot >= maxi(int(room_count * 2 / 3), 1):
		match item_def_id:
			"decoy_emitter", "echo_lure":
				return 3
			"doubt_ink", "echo_molt":
				return 2
			"lantern_snuffer":
				return 2
			"timeline_bookmark", "witness_chime", "flare_ampoule", "oath_ribbon":
				return 1
			_:
				return 0
	match item_def_id:
		"timeline_bookmark", "decoy_emitter", "custody_seal", "witness_chime", "flare_ampoule", "oath_ribbon":
			return 1
		_:
			return 0

func _world_pos_for_item_spawn(room_slot: int, room_type: String, item_def_id: String) -> Vector2:
	var grid_x := posmod(room_slot, ROOM_COLUMNS)
	var grid_y := int(floor(float(room_slot) / float(ROOM_COLUMNS)))
	var room_origin := Vector2(float(grid_x) * ROOM_WIDTH, float(grid_y) * ROOM_HEIGHT)
	match room_type:
		"traversal":
			if item_def_id == "hush_bead":
				return room_origin + Vector2(212.0, 278.0)
			if item_def_id == "echo_molt":
				return room_origin + Vector2(756.0, 284.0)
			if item_def_id in ["zipline_kit", "heavy_boots", "burden_sling"]:
				return room_origin + Vector2(736.0, 236.0)
			if item_def_id == "echo_lure":
				return room_origin + Vector2(332.0, 266.0)
			return room_origin + Vector2(256.0, 404.0)
		"hazard":
			if item_def_id == "flare_ampoule":
				return room_origin + Vector2(280.0, 244.0)
			if item_def_id == "doubt_ink":
				return room_origin + Vector2(738.0, 470.0)
			if item_def_id == "echo_molt":
				return room_origin + Vector2(700.0, 226.0)
			if item_def_id == "decoy_emitter":
				return room_origin + Vector2(760.0, 454.0)
			if item_def_id == "echo_lure":
				return room_origin + Vector2(740.0, 256.0)
			if item_def_id == "heavy_boots":
				return room_origin + Vector2(256.0, 240.0)
			return room_origin + Vector2(300.0, 404.0)
		"evidence":
			if item_def_id == "oath_ribbon":
				return room_origin + Vector2(536.0, 238.0)
			if item_def_id == "hush_bead":
				return room_origin + Vector2(248.0, 432.0)
			if item_def_id == "flare_ampoule":
				return room_origin + Vector2(676.0, 418.0)
			if item_def_id == "timeline_bookmark":
				return room_origin + Vector2(748.0, 232.0)
			if item_def_id == "custody_seal":
				return room_origin + Vector2(700.0, 256.0)
			if item_def_id == "witness_chime":
				return room_origin + Vector2(512.0, 212.0)
			if item_def_id == "lantern_snuffer":
				return room_origin + Vector2(236.0, 456.0)
			return room_origin + Vector2(700.0, 438.0)
		_:
			return room_origin + Vector2(128.0, 262.0)

func _dedupe_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		var text := str(value).strip_edges()
		if text.is_empty() or result.has(text):
			continue
		result.append(text)
	return result

func _entry_ids(entries: Array) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var id := str(entry.get("id", "")).strip_edges()
		if not id.is_empty() and not result.has(id):
			result.append(id)
	return result

func _mind_ids(entries: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var id := str(entry.get("id", "")).strip_edges()
		if id.is_empty():
			continue
		result.append(id)
		if result.size() >= limit:
			break
	return result

func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
