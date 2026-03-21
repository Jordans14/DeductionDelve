class_name ProfileService
extends RefCounted

const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const RUN_STORY_DIAGNOSTICS_SCRIPT = preload("res://src/product/run_story_diagnostics.gd")
const CRAWL_SERVICE_SCRIPT = preload("res://src/product/crawl_service.gd")
const FRAMING_SERVICE_SCRIPT = preload("res://src/product/framing_service.gd")
const ARCHIVE_SERVICE_SCRIPT = preload("res://src/product/archive_service.gd")
const WORLD_MEMORY_SERVICE_SCRIPT = preload("res://src/product/world_memory_service.gd")
const CIVILIZATION_STATE_SERVICE_SCRIPT = preload("res://src/product/civilization_state_service.gd")
const WORDING_GUARD_SCRIPT = preload("res://src/product/narrative_wording_guard.gd")
const PROFILE_PERSISTENCE_SCRIPT = preload("res://src/product/profile_persistence.gd")
const PROFILE_PROGRESSION_SCRIPT = preload("res://src/product/profile_progression.gd")
const PROFILE_SHELL_BUILDERS_SCRIPT = preload("res://src/product/profile_shell_builders.gd")
const PROFILE_IDENTITY_STATE_SCRIPT = preload("res://src/product/profile_identity_state.gd")
const MULTIMODAL_CONTRACT_SERVICE_SCRIPT = preload("res://src/product/multimodal_contract_service.gd")
const DELVEMIND_EXPERIMENT_ENGINE_SCRIPT = preload("res://src/product/delvemind_experiment_engine.gd")
const DELVEMIND_LEARNING_LOOP_SCRIPT = preload("res://src/product/delvemind_learning_loop.gd")
const GOVERNANCE_SERVICE_SCRIPT = preload("res://src/product/governance_service.gd")
const COOKBOOK_FRAGMENT_SERVICE_SCRIPT = preload("res://src/product/cookbook_fragment_service.gd")

const SAVE_PATH := "user://profile/player_profile.json"
const HISTORY_LIMIT := 24

static func load_profile(path: String = SAVE_PATH, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var parsed := PROFILE_PERSISTENCE_SCRIPT.load_json(path)
	if parsed.is_empty():
		return create_default_profile(current_catalog)
	return normalize_profile(parsed, current_catalog)

static func save_profile(profile: Dictionary, path: String = SAVE_PATH, catalog: Dictionary = {}) -> bool:
	var normalized := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	return PROFILE_PERSISTENCE_SCRIPT.save_json(path, normalized)

static func record_run(run_record: Dictionary, path: String = SAVE_PATH, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var profile := load_profile(path, current_catalog)
	var result := apply_run_record(profile, run_record, current_catalog)
	save_profile(Dictionary(result.get("profile", {})), path, current_catalog)
	return result

static func create_default_profile(catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	return normalize_profile(_base_default_profile(current_catalog), current_catalog)

static func _base_default_profile(current_catalog: Dictionary) -> Dictionary:
	var mastery_defaults := {}
	for role_name in ROLE_SERVICE_SCRIPT.new().all_role_names():
		mastery_defaults[role_name] = {"xp": 0, "level": 1, "runs": 0, "wins": 0}
	var default_equipped: Dictionary = PRODUCT_CATALOG_SCRIPT.default_equipped(current_catalog)
	return {
		"schema_version": 3,
		"account": {
			"display_name": "Delver",
			"public_id": _default_public_id("Delver"),
			"xp": 0,
			"level": 1,
			"runs": 0,
			"expedition_wins": 0,
			"sabotage_wins": 0
		},
		"career_stats": {
			"notes_written": 0,
			"pins_used": 0,
			"inspections": 0,
			"authentic_extractions": 0,
			"counterfeit_extractions": 0,
			"interrupted_runs": 0
		},
		"mastery": mastery_defaults,
		"discoveries": {
			"item_defs": [],
			"room_families": [],
			"artifact_states": [],
			"roles": [],
			"clue_families": []
		},
		"cosmetics": {
			"owned": PRODUCT_CATALOG_SCRIPT.starter_owned_ids(current_catalog),
			"equipped": default_equipped
		},
		"normalization_mode": "default",
		"equipped_modulation_loadout": PRODUCT_CATALOG_SCRIPT.modulation_loadout_for_equipped(default_equipped, "default", current_catalog),
		"achievements": {
			"unlocked": [],
			"last_unlocked": []
		},
		"settings": Dictionary(current_catalog.get("settings_defaults", {})).duplicate(true),
		"multimodal_contract": MULTIMODAL_CONTRACT_SERVICE_SCRIPT.default_state(),
		"delvemind_experiment_state": DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.default_state(),
		"last_run": {},
		"run_history": [],
		"active_crawl": {},
		"crawl_history": [],
		"relationship_fabric": {
			"players": {},
			"pairs": {},
			"crews": {},
			"recent_pairs": [],
			"recent_crews": []
		},
		"persona_state": {
			"archetype_scores": {},
			"risk_posture": {},
			"public_expectations": []
		},
		"archive_state": ARCHIVE_SERVICE_SCRIPT.default_state(),
		"world_memory": WORLD_MEMORY_SERVICE_SCRIPT.default_state(),
		"cookbook_state": _normalize_cookbook_state({}),
		"governance_state": GOVERNANCE_SERVICE_SCRIPT.default_state(),
		"legacy_tracks": [],
		"reentry_hooks": [],
		"narrative_progress": {
			"layer": "public",
			"core_reached": false,
			"post_core_flags": []
		},
		"first_run_pending": true
	}

static func normalize_profile(profile: Dictionary, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var normalized := _base_default_profile(current_catalog)
	for key in profile.keys():
		normalized[key] = profile[key]

	var account: Dictionary = Dictionary(normalized.get("account", {}))
	var default_account: Dictionary = _base_default_profile(current_catalog).get("account", {})
	for key in default_account.keys():
		if not account.has(key):
			account[key] = default_account[key]
	account["public_id"] = str(account.get("public_id", "")).strip_edges()
	if account["public_id"].is_empty():
		account["public_id"] = PROFILE_IDENTITY_STATE_SCRIPT.default_public_id(str(account.get("display_name", "Delver")))
	account["xp"] = int(account.get("xp", 0))
	account["level"] = int(account.get("level", 1))
	account["runs"] = int(account.get("runs", 0))
	account["expedition_wins"] = int(account.get("expedition_wins", 0))
	account["sabotage_wins"] = int(account.get("sabotage_wins", 0))
	normalized["account"] = account

	var career_defaults: Dictionary = _base_default_profile(current_catalog).get("career_stats", {})
	var career_stats: Dictionary = Dictionary(normalized.get("career_stats", {}))
	for key in career_defaults.keys():
		if not career_stats.has(key):
			career_stats[key] = career_defaults[key]
		career_stats[key] = int(career_stats.get(key, 0))
	normalized["career_stats"] = career_stats

	var mastery_defaults: Dictionary = _base_default_profile(current_catalog).get("mastery", {})
	var mastery: Dictionary = Dictionary(normalized.get("mastery", {}))
	for role_name in mastery_defaults.keys():
		var track: Dictionary = Dictionary(mastery.get(role_name, {}))
		var default_track: Dictionary = mastery_defaults[role_name]
		for key in default_track.keys():
			if not track.has(key):
				track[key] = default_track[key]
		track["xp"] = int(track.get("xp", 0))
		track["level"] = int(track.get("level", 1))
		track["runs"] = int(track.get("runs", 0))
		track["wins"] = int(track.get("wins", 0))
		mastery[role_name] = track
	normalized["mastery"] = mastery

	var discoveries_defaults: Dictionary = _base_default_profile(current_catalog).get("discoveries", {})
	var discoveries: Dictionary = Dictionary(normalized.get("discoveries", {}))
	for key in discoveries_defaults.keys():
		var values: Array = discoveries.get(key, [])
		var strings: Array[String] = []
		for value in values:
			var text := str(value)
			if not text.is_empty() and not strings.has(text):
				strings.append(text)
		strings.sort()
		discoveries[key] = strings
	normalized["discoveries"] = discoveries

	var cosmetics: Dictionary = Dictionary(normalized.get("cosmetics", {}))
	var owned: Array[String] = PRODUCT_CATALOG_SCRIPT.starter_owned_ids(current_catalog)
	for cosmetic_id in cosmetics.get("owned", []):
		var text := str(cosmetic_id)
		if not text.is_empty() and not owned.has(text):
			owned.append(text)
	owned.sort()
	cosmetics["owned"] = owned
	var equipped: Dictionary = PRODUCT_CATALOG_SCRIPT.default_equipped(current_catalog)
	for slot in Dictionary(cosmetics.get("equipped", {})).keys():
		equipped[str(slot)] = str(Dictionary(cosmetics.get("equipped", {})).get(slot, ""))
	cosmetics["equipped"] = equipped
	normalized["cosmetics"] = cosmetics
	normalized["normalization_mode"] = PRODUCT_CATALOG_SCRIPT.normalize_normalization_mode(str(normalized.get("normalization_mode", "default")), current_catalog)
	normalized["equipped_modulation_loadout"] = PRODUCT_CATALOG_SCRIPT.modulation_loadout_for_equipped(
		equipped,
		str(normalized.get("normalization_mode", "default")),
		current_catalog
	)

	var achievements_defaults: Dictionary = _base_default_profile(current_catalog).get("achievements", {})
	var achievements: Dictionary = Dictionary(normalized.get("achievements", {}))
	for key in achievements_defaults.keys():
		var values: Array = achievements.get(key, [])
		var strings: Array[String] = []
		for value in values:
			var text := str(value)
			if not text.is_empty() and not strings.has(text):
				strings.append(text)
		strings.sort()
		achievements[key] = strings
	normalized["achievements"] = achievements

	var settings: Dictionary = Dictionary(current_catalog.get("settings_defaults", {})).duplicate(true)
	for key in Dictionary(normalized.get("settings", {})).keys():
		settings[key] = Dictionary(normalized.get("settings", {})).get(key)
	normalized["settings"] = settings
	normalized["multimodal_contract"] = MULTIMODAL_CONTRACT_SERVICE_SCRIPT.normalize(Dictionary(normalized.get("multimodal_contract", {})))
	normalized["delvemind_experiment_state"] = DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(normalized.get("delvemind_experiment_state", {})))
	normalized["run_history"] = Array(normalized.get("run_history", [])).slice(0, HISTORY_LIMIT)
	normalized["crawl_history"] = Array(normalized.get("crawl_history", [])).slice(0, CRAWL_SERVICE_SCRIPT.CRAWL_HISTORY_LIMIT)
	normalized["archive_state"] = ARCHIVE_SERVICE_SCRIPT.normalize(Dictionary(normalized.get("archive_state", {})))
	normalized["world_memory"] = WORLD_MEMORY_SERVICE_SCRIPT.normalize(Dictionary(normalized.get("world_memory", {})))
	normalized["cookbook_state"] = _normalize_cookbook_state(Dictionary(normalized.get("cookbook_state", {})))
	normalized["governance_state"] = GOVERNANCE_SERVICE_SCRIPT.normalize(Dictionary(normalized.get("governance_state", {})))
	normalized["legacy_tracks"] = _normalize_legacy_tracks(Array(normalized.get("legacy_tracks", [])))
	normalized["reentry_hooks"] = _normalize_reentry_hooks(Array(normalized.get("reentry_hooks", [])))
	CRAWL_SERVICE_SCRIPT.normalize_profile_fields(normalized)
	normalized["schema_version"] = 3
	normalized["first_run_pending"] = bool(normalized.get("first_run_pending", true))
	_unlock_progression_cosmetics(normalized, current_catalog)
	return normalized

static func _to_string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			result.append(str(value))
	return result

static func _to_dictionary_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value))
	return result

static func compute_run_rewards(run_record: Dictionary) -> Dictionary:
	if bool(run_record.get("interrupted", false)):
		return {
			"account_xp": 0,
			"mastery_xp": 0
		}
	var stats: Dictionary = Dictionary(run_record.get("stats", {}))
	var notes_count := int(stats.get("notes_count", 0))
	var inspections_count := int(stats.get("inspections_count", 0))
	var pinned_count := int(stats.get("pinned_count", 0))
	var extraction_completed := bool(stats.get("extraction_completed", false))
	var role_result_success := bool(run_record.get("role_result_success", false))
	var account_xp := 100
	account_xp += 40 if role_result_success else 10
	account_xp += mini(notes_count * 5, 20)
	account_xp += mini(inspections_count * 8, 24)
	account_xp += 20 if extraction_completed else 0
	account_xp += mini(pinned_count * 4, 8)
	var mastery_xp := 60
	mastery_xp += 20 if role_result_success else 0
	mastery_xp += mini(inspections_count * 5, 20)
	mastery_xp += mini(notes_count * 3, 12)
	return {
		"account_xp": account_xp,
		"mastery_xp": mastery_xp
	}

static func apply_run_record(profile: Dictionary, run_record: Dictionary, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var next_profile := normalize_profile(profile, current_catalog)
	var rewards := compute_run_rewards(run_record)
	var local_role := str(run_record.get("local_role", "Unknown"))
	var role_result_success := bool(run_record.get("role_result_success", false))
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	var interrupted := bool(run_record.get("interrupted", false))
	var account: Dictionary = Dictionary(next_profile.get("account", {}))
	if not interrupted:
		account["runs"] = int(account.get("runs", 0)) + 1
		account["xp"] = int(account.get("xp", 0)) + int(rewards.get("account_xp", 0))
		account["level"] = level_for_track_xp("account", int(account.get("xp", 0)), current_catalog)
		if bool(outcome_summary.get("expedition_success", false)):
			account["expedition_wins"] = int(account.get("expedition_wins", 0)) + 1
		if bool(outcome_summary.get("sabotage_success", false)):
			account["sabotage_wins"] = int(account.get("sabotage_wins", 0)) + 1
	next_profile["account"] = account

	_apply_career_stats(next_profile, run_record, outcome_summary)

	var mastery: Dictionary = Dictionary(next_profile.get("mastery", {}))
	if not interrupted and mastery.has(local_role):
		var role_track: Dictionary = Dictionary(mastery.get(local_role, {}))
		role_track["runs"] = int(role_track.get("runs", 0)) + 1
		role_track["xp"] = int(role_track.get("xp", 0)) + int(rewards.get("mastery_xp", 0))
		role_track["level"] = level_for_track_xp(local_role, int(role_track.get("xp", 0)), current_catalog)
		if role_result_success:
			role_track["wins"] = int(role_track.get("wins", 0)) + 1
		mastery[local_role] = role_track
	next_profile["mastery"] = mastery

	_apply_discoveries(next_profile, run_record)
	var owned_before: Array = Array(Dictionary(next_profile.get("cosmetics", {})).get("owned", [])).duplicate()
	_unlock_progression_cosmetics(next_profile, current_catalog)
	var unlocked_cosmetics := _new_string_entries(owned_before, Array(Dictionary(next_profile.get("cosmetics", {})).get("owned", [])))
	var unlocked_achievements := _unlock_achievements(next_profile, run_record, current_catalog)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var frame := FRAMING_SERVICE_SCRIPT.build_run_frame(run_record, diagnostics, next_profile)
	var experiment_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.advance_persistence(
		Dictionary(next_profile.get("delvemind_experiment_state", {})),
		run_record,
		diagnostics,
		frame
	)
	experiment_state = DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(
		experiment_state,
		run_record,
		diagnostics,
		frame
	)
	next_profile["delvemind_experiment_state"] = DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(experiment_state)
	var crawl_result := CRAWL_SERVICE_SCRIPT.apply_run(next_profile, run_record, diagnostics, frame)
	var continuity_world_aftermath_records := CIVILIZATION_STATE_SERVICE_SCRIPT.build_world_aftermath_records({
		"profile": next_profile,
		"run_record": run_record,
		"diagnostics": diagnostics,
		"frame": frame,
		"crawl_packet": Dictionary(crawl_result.get("crawl_packet", {}))
	})
	var legacy_track := _build_phase8_legacy_track(run_record, diagnostics, frame, Dictionary(crawl_result.get("crawl_packet", {})), continuity_world_aftermath_records)
	var reentry_hook := _build_phase8_reentry_hook(run_record, diagnostics, frame, legacy_track)
	next_profile["legacy_tracks"] = _merge_front_dictionary_entries(Array(next_profile.get("legacy_tracks", [])), legacy_track, "track_id", 18)
	next_profile["reentry_hooks"] = _merge_front_dictionary_entries(Array(next_profile.get("reentry_hooks", [])), reentry_hook, "hook_id", 18)
	next_profile["cookbook_state"] = _advance_cookbook_state(
		Dictionary(next_profile.get("cookbook_state", {})),
		next_profile,
		run_record,
		diagnostics,
		frame
	)
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		Dictionary(next_profile.get("world_memory", {})),
		{
			"profile": next_profile,
			"narrative_progress": Dictionary(next_profile.get("narrative_progress", {})),
			"run_record": run_record,
			"diagnostics": diagnostics,
			"frame": frame,
			"crawl_packet": Dictionary(crawl_result.get("crawl_packet", {}))
		}
	)
	next_profile["world_memory"] = world_memory
	var archive_state := ARCHIVE_SERVICE_SCRIPT.apply_run(
		Dictionary(next_profile.get("archive_state", {})),
		{
			"archive_state": Dictionary(next_profile.get("archive_state", {})),
			"profile": next_profile,
			"narrative_progress": Dictionary(next_profile.get("narrative_progress", {})),
			"run_record": run_record,
			"diagnostics": diagnostics,
			"frame": frame,
			"crawl_packet": Dictionary(crawl_result.get("crawl_packet", {})),
			"world_memory": world_memory
		}
	)
	next_profile["archive_state"] = archive_state
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.apply_post_run(
		Dictionary(next_profile.get("governance_state", {})),
		run_record,
		diagnostics,
		frame,
		Dictionary(run_record.get("expedition_constitution_summary", {}))
	)
	next_profile["governance_state"] = governance_state
	next_profile["narrative_progress"] = PROFILE_PROGRESSION_SCRIPT.advance_narrative_progress(
		Dictionary(next_profile.get("narrative_progress", {})),
		run_record,
		diagnostics,
		frame,
		Dictionary(crawl_result.get("crawl_packet", {})),
		world_memory,
		archive_state
	)
	var learning_state: Dictionary = DELVEMIND_LEARNING_LOOP_SCRIPT.normalize_learning_state(
		Dictionary(Dictionary(next_profile.get("delvemind_experiment_state", {})).get("learning_state", {}))
	)
	var learning_public_lines := _to_string_array(learning_state.get("public_lines", []))
	var learning_operator_lines := _to_string_array(learning_state.get("operator_lines", []))
	var manifested_experiment_ids := _to_string_array(run_record.get("manifested_experiment_ids", []))
	var live_experiment_ids := _to_string_array(run_record.get("live_experiment_ids", []))
	var live_hypothesis_ids := _to_string_array(run_record.get("live_hypothesis_ids", []))
	var normalization_mode := str(run_record.get("normalization_mode", next_profile.get("normalization_mode", "default"))).strip_edges()
	var equipped_modulation_loadout: Array = Array(run_record.get("equipped_modulation_loadout", next_profile.get("equipped_modulation_loadout", []))).duplicate(true)
	var local_aftermath: Dictionary = Dictionary(run_record.get("local_aftermath", {})).duplicate(true)
	var world_aftermath_records: Array = continuity_world_aftermath_records.duplicate(true)
	var governance_action_snapshot := GOVERNANCE_SERVICE_SCRIPT.build_forensic_action_snapshot(governance_state)
	var world_memory_snapshot_hash := _canonical_phase9_hash(world_memory)
	var forensic_bundle_header := _build_phase9_forensic_bundle_header(run_record, world_memory_snapshot_hash, governance_action_snapshot)
	var consequence_bridge: Dictionary = Dictionary(diagnostics.get("consequence_bridge", {})).duplicate(true)
	var onboarding_public_safe_ref: Dictionary = Dictionary(consequence_bridge.get("onboarding_public_safe_ref", {})).duplicate(true)
	onboarding_public_safe_ref["explanation_packet_lines"] = _to_string_array(
		onboarding_public_safe_ref.get("explanation_packet_lines", Dictionary(run_record.get("expedition_constitution_summary", {})).get("explanation_packet_lines", []))
	).slice(0, 6)
	onboarding_public_safe_ref["review_surface_lines"] = _to_string_array(
		onboarding_public_safe_ref.get("review_surface_lines", Dictionary(run_record.get("expedition_constitution_summary", {})).get("review_surface_lines", []))
	).slice(0, 6)
	onboarding_public_safe_ref["signal_budget_lines"] = _to_string_array(
		onboarding_public_safe_ref.get("signal_budget_lines", Dictionary(run_record.get("expedition_constitution_summary", {})).get("signal_budget_lines", []))
	).slice(0, 6)
	onboarding_public_safe_ref["legacy_track_id"] = str(legacy_track.get("track_id", "")).strip_edges()
	onboarding_public_safe_ref["reentry_hook_id"] = str(reentry_hook.get("hook_id", "")).strip_edges()
	consequence_bridge["onboarding_public_safe_ref"] = onboarding_public_safe_ref.duplicate(true)
	if str(consequence_bridge.get("constitution_hash", "")).strip_edges().is_empty():
		consequence_bridge["constitution_hash"] = str(run_record.get("constitution_hash", Dictionary(run_record.get("expedition_constitution_summary", {})).get("constitution_hash", ""))).strip_edges()
	if not consequence_bridge.is_empty():
		var consequence_bridge_seed := consequence_bridge.duplicate(true)
		consequence_bridge_seed.erase("bridge_id")
		consequence_bridge["bridge_id"] = "consequence_bridge_%s" % JSON.stringify(consequence_bridge_seed).md5_text().substr(0, 12)

	var last_run := {
		"seed": int(run_record.get("seed", 0)),
		"end_reason": str(run_record.get("end_reason", "")),
		"local_peer_id": int(run_record.get("local_peer_id", -1)),
		"local_role": local_role,
		"role_result_success": role_result_success,
		"interrupted": interrupted,
		"interruption_reason": str(run_record.get("interruption_reason", "")),
		"session_wait_for_lobby": bool(run_record.get("session_wait_for_lobby", false)),
		"session_reconnect_ready": bool(run_record.get("session_reconnect_ready", false)),
		"summary_text": str(outcome_summary.get("summary_text", "Run complete")),
		"artifact_result_text": str(outcome_summary.get("artifact_result_text", "-")),
		"artifact_consequence_version": int(outcome_summary.get("artifact_consequence_version", 0)),
		"consequence_event_family": str(outcome_summary.get("consequence_event_family", "")).strip_edges(),
		"public_consequence_tags": _to_string_array(outcome_summary.get("public_consequence_tags", [])),
		"burden_band": str(outcome_summary.get("burden_band", "")).strip_edges(),
		"valuation_band": str(outcome_summary.get("valuation_band", "")).strip_edges(),
		"return_consequence_state": str(outcome_summary.get("return_consequence_state", "")).strip_edges(),
		"market_regime_id": str(outcome_summary.get("market_regime_id", "")).strip_edges(),
		"market_carrier_risk_band": str(outcome_summary.get("market_carrier_risk_band", "")).strip_edges(),
		"report_path": str(run_record.get("report_path", "")),
		"xp_gain": int(rewards.get("account_xp", 0)),
		"mastery_gain": int(rewards.get("mastery_xp", 0)),
		"reward_breakdown": _build_reward_breakdown(run_record, rewards),
		"unlocked_cosmetics": unlocked_cosmetics.duplicate(),
		"unlocked_achievements": unlocked_achievements.duplicate(),
		"diagnostics": diagnostics.duplicate(true),
		"frame": frame.duplicate(true),
		"crawl_id": str(Dictionary(crawl_result.get("crawl_packet", {})).get("crawl_id", "")),
		"crawl_title": str(Dictionary(crawl_result.get("crawl_packet", {})).get("title", "")),
		"archive_preview": ARCHIVE_SERVICE_SCRIPT.build_archive_lines(next_profile),
		"world_memory_lines": WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory),
		"normalization_mode": normalization_mode,
		"equipped_modulation_loadout": equipped_modulation_loadout.duplicate(true),
		"suppressed_modulation_count": PRODUCT_CATALOG_SCRIPT.suppressed_delta_count(equipped_modulation_loadout),
		"manifested_experiment_ids": manifested_experiment_ids.slice(0, 8),
		"live_experiment_ids": live_experiment_ids.slice(0, 8),
		"live_hypothesis_ids": live_hypothesis_ids.slice(0, 8),
		"experiment_learning_lines": learning_public_lines.slice(0, 2),
		"experiment_learning_operator_lines": learning_operator_lines.slice(0, 2),
		"communication_summary": Dictionary(run_record.get("communication_summary", {})).duplicate(true),
		"key_clues": Array(run_record.get("key_clues", [])).duplicate(),
		"action_summary": Array(run_record.get("action_summary", [])).duplicate(),
		"stats_lines": Array(run_record.get("stats_lines", [])).duplicate(),
		"legacy_track_id": str(legacy_track.get("track_id", "")).strip_edges(),
		"legacy_track": legacy_track.duplicate(true),
		"reentry_hook_id": str(reentry_hook.get("hook_id", "")).strip_edges(),
		"reentry_hook": reentry_hook.duplicate(true),
		"quiet_play_signals": _to_string_array(diagnostics.get("quiet_play_signals", [])),
		"meaningful_non_action": str(diagnostics.get("meaningful_non_action", "")).strip_edges(),
		"social_safety_flags": _to_string_array(diagnostics.get("social_safety_flags", [])),
		"reputation_band": str(diagnostics.get("reputation_band", "")).strip_edges(),
		"institutional_pressure_surface": Dictionary(diagnostics.get("institutional_pressure_surface", {})).duplicate(true),
		"continuity_burden_score": int(diagnostics.get("continuity_burden_score", 0)),
		"local_aftermath": local_aftermath.duplicate(true),
		"world_aftermath_refs": world_aftermath_records.duplicate(true),
		"consequence_bridge": consequence_bridge.duplicate(true),
		"world_memory_snapshot_hash": world_memory_snapshot_hash,
		"forensic_bundle_header": forensic_bundle_header.duplicate(true),
		"rollback_action": Dictionary(governance_action_snapshot.get("rollback_action", {})).duplicate(true),
		"quarantine_action": Dictionary(governance_action_snapshot.get("quarantine_action", {})).duplicate(true),
		"fairness_trigger_ids": _to_string_array(governance_action_snapshot.get("fairness_triggers", [])),
		"dignity_trigger_ids": _to_string_array(governance_action_snapshot.get("dignity_triggers", [])),
		"dominant_strategy_strain": Dictionary(governance_action_snapshot.get("dominant_strategy_strain", {})).duplicate(true),
		"experiment_outcomes": Dictionary(run_record.get("experiment_outcomes", {})).duplicate(true)
	}
	next_profile["last_run"] = last_run
	next_profile["first_run_pending"] = false

	var history_entry := {
		"seed": int(run_record.get("seed", 0)),
		"summary_text": str(outcome_summary.get("summary_text", "Run complete")),
		"artifact_result_text": str(outcome_summary.get("artifact_result_text", "-")),
		"artifact_consequence_version": int(outcome_summary.get("artifact_consequence_version", 0)),
		"consequence_event_family": str(outcome_summary.get("consequence_event_family", "")).strip_edges(),
		"public_consequence_tags": _to_string_array(outcome_summary.get("public_consequence_tags", [])),
		"burden_band": str(outcome_summary.get("burden_band", "")).strip_edges(),
		"valuation_band": str(outcome_summary.get("valuation_band", "")).strip_edges(),
		"return_consequence_state": str(outcome_summary.get("return_consequence_state", "")).strip_edges(),
		"market_regime_id": str(outcome_summary.get("market_regime_id", "")).strip_edges(),
		"market_carrier_risk_band": str(outcome_summary.get("market_carrier_risk_band", "")).strip_edges(),
		"local_role": local_role,
		"role_result_success": role_result_success,
		"story_tone": str(diagnostics.get("story_tone", "Quiet")),
		"interrupted": interrupted,
		"interruption_reason": str(run_record.get("interruption_reason", "")),
		"session_wait_for_lobby": bool(run_record.get("session_wait_for_lobby", false)),
		"session_reconnect_ready": bool(run_record.get("session_reconnect_ready", false)),
		"xp_gain": int(rewards.get("account_xp", 0)),
		"mastery_gain": int(rewards.get("mastery_xp", 0)),
		"report_path": str(run_record.get("report_path", "")),
		"diagnostics": diagnostics.duplicate(true),
		"frame": frame.duplicate(true),
		"normalization_mode": normalization_mode,
		"equipped_modulation_loadout": equipped_modulation_loadout.duplicate(true),
		"crawl_id": str(Dictionary(crawl_result.get("crawl_packet", {})).get("crawl_id", "")),
		"crawl_title": str(Dictionary(crawl_result.get("crawl_packet", {})).get("title", "")),
		"manifested_experiment_ids": manifested_experiment_ids.slice(0, 4),
		"live_experiment_ids": live_experiment_ids.slice(0, 4),
		"communication_summary": Dictionary(run_record.get("communication_summary", {})).duplicate(true),
		"key_clues": Array(run_record.get("key_clues", [])).slice(0, 3),
		"action_summary": Array(run_record.get("action_summary", [])).slice(0, 3),
		"experiment_learning_lines": learning_public_lines.slice(0, 2),
		"legacy_track_id": str(legacy_track.get("track_id", "")).strip_edges(),
		"reentry_hook_id": str(reentry_hook.get("hook_id", "")).strip_edges(),
		"quiet_play_signals": _to_string_array(diagnostics.get("quiet_play_signals", [])).slice(0, 2),
		"social_safety_flags": _to_string_array(diagnostics.get("social_safety_flags", [])).slice(0, 3),
		"reputation_band": str(diagnostics.get("reputation_band", "")).strip_edges(),
		"local_aftermath": local_aftermath.duplicate(true),
		"world_aftermath_refs": world_aftermath_records.duplicate(true),
		"consequence_bridge": consequence_bridge.duplicate(true),
		"world_memory_snapshot_hash": world_memory_snapshot_hash,
		"forensic_bundle_header": forensic_bundle_header.duplicate(true)
	}
	var history: Array = Array(next_profile.get("run_history", []))
	history.push_front(history_entry)
	next_profile["run_history"] = history.slice(0, HISTORY_LIMIT)
	return {
		"profile": normalize_profile(next_profile, current_catalog),
		"rewards": rewards
	}

static func level_for_track_xp(track_id: String, xp: int, catalog: Dictionary = {}) -> int:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var track := PRODUCT_CATALOG_SCRIPT.get_mastery_track(track_id, current_catalog)
	var thresholds: Array = track.get("levels", [0])
	var level := 1
	for threshold_variant in thresholds:
		if xp >= int(threshold_variant):
			level += 1
	return maxi(level - 1, 1)

static func build_profile_summary_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	var account: Dictionary = current.get("account", {})
	var equipped: Dictionary = Dictionary(Dictionary(current.get("cosmetics", {})).get("equipped", {}))
	var title := _display_name_for_cosmetic(str(equipped.get("title", "")), catalog)
	var banner := _display_name_for_cosmetic(str(equipped.get("banner", "")), catalog)
	var lines: Array[String] = []
	lines.append("Rank %d | XP %d" % [int(account.get("level", 1)), int(account.get("xp", 0))])
	lines.append(
		"Runs: %d | Expedition wins: %d | Sabotage wins: %d"
		% [int(account.get("runs", 0)), int(account.get("expedition_wins", 0)), int(account.get("sabotage_wins", 0))]
	)
	lines.append("Title: %s | Banner: %s" % [title, banner])
	lines.append_array(CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(current))
	lines.append_array(CRAWL_SERVICE_SCRIPT.build_persona_lines(current).slice(0, 1))
	return _to_string_array(lines.slice(0, 5))

static func build_profile_card_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var account: Dictionary = current.get("account", {})
	var equipped: Dictionary = Dictionary(Dictionary(current.get("cosmetics", {})).get("equipped", {}))
	var title := _display_name_for_cosmetic(str(equipped.get("title", "")), current_catalog)
	var banner := _display_name_for_cosmetic(str(equipped.get("banner", "")), current_catalog)
	var lines: Array[String] = []
	lines.append("%s // %s" % [title, banner])
	lines.append("Expedition Rank %d" % int(account.get("level", 1)))
	lines.append("Delver history: %d runs logged" % int(account.get("runs", 0)))
	var crawl_lines := CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(current)
	if crawl_lines.size() > 0:
		lines.append(crawl_lines[0])
	var persona_lines := CRAWL_SERVICE_SCRIPT.build_persona_lines(current)
	if not persona_lines.is_empty():
		lines.append(persona_lines[0])
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines.slice(0, 4))

static func build_public_identity_card(profile: Dictionary, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	return FRAMING_SERVICE_SCRIPT.guard_entry(PROFILE_IDENTITY_STATE_SCRIPT.build_public_identity_card(
		current,
		func(cosmetic_id: String) -> String:
			return _display_name_for_cosmetic(cosmetic_id, current_catalog),
		FRAMING_SERVICE_SCRIPT.build_home_heat_line(Dictionary(Dictionary(current.get("last_run", {})).get("frame", {})))
	))

static func build_progression_preview_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var lines: Array[String] = []
	var account: Dictionary = current.get("account", {})
	var next_account := next_track_preview("account", int(account.get("xp", 0)), current_catalog)
	lines.append("Next rank: %s" % next_account)
	lines.append("Next cosmetic: %s" % next_cosmetic_unlock_text(current, current_catalog))
	var last_run: Dictionary = Dictionary(current.get("last_run", {}))
	var unlocked_cosmetics: Array = Array(last_run.get("unlocked_cosmetics", []))
	var unlocked_achievements: Array = Array(last_run.get("unlocked_achievements", []))
	if not unlocked_cosmetics.is_empty():
		lines.append("Recent unlock: %s" % _display_name_for_cosmetic(str(unlocked_cosmetics[0]), current_catalog))
	elif not unlocked_achievements.is_empty():
		var achievement := PRODUCT_CATALOG_SCRIPT.get_achievement(str(unlocked_achievements[0]), current_catalog)
		lines.append("Recent milestone: %s" % str(achievement.get("display_name", unlocked_achievements[0])))
	var archive_lines := ARCHIVE_SERVICE_SCRIPT.build_archive_lines(current)
	if not archive_lines.is_empty():
		lines.append(archive_lines[0])
	var progress_lines := PROFILE_PROGRESSION_SCRIPT.build_narrative_progress_lines(
		Dictionary(current.get("narrative_progress", {})),
		Dictionary(current.get("archive_state", {})),
		Dictionary(current.get("world_memory", {}))
	)
	var narrative_progress: Dictionary = Dictionary(current.get("narrative_progress", {}))
	var progress_flags := _to_string_array(narrative_progress.get("post_core_flags", []))
	var progress_layer := str(narrative_progress.get("layer", "public"))
	var world_memory := Dictionary(current.get("world_memory", {}))
	var myth_field := Dictionary(world_memory.get("myth_field", {}))
	var top_successor := Dictionary(myth_field.get("top_successor", {}))
	var archive_legends := Array(Dictionary(current.get("archive_state", {})).get("legends", []))
	var archive_depth_line := ""
	var progression_signal_line := ""
	var preferred_progression_markers := [
		"Separate echoes are beginning to answer each other directly.",
		"A familiar reading is starting to bend away from itself.",
		"Competing readings are starting to matter as much as the events themselves.",
		"Recent reversals are forcing older legends to answer for themselves.",
		"A newer reading is starting to displace an older legend.",
		"Archive depth: repeated challenges are starting to read like lessons with motives.",
		"Archive depth: the same pressures now feel like they are being anticipated in advance."
	]
	for line in progress_lines:
		var text := str(line).strip_edges()
		if text.is_empty():
			continue
		if archive_depth_line.is_empty() and text.begins_with("Archive depth:"):
			archive_depth_line = text
			continue
		var preferred := false
		for marker in preferred_progression_markers:
			if text == marker:
				preferred = true
				break
		if preferred:
			progression_signal_line = text
			continue
		if progression_signal_line.is_empty():
			progression_signal_line = text
	if not archive_depth_line.is_empty():
		lines.append(archive_depth_line)
	if progression_signal_line.is_empty():
		if progress_flags.has("field_resonance"):
			progression_signal_line = "Separate echoes are beginning to answer each other directly."
		elif progress_flags.has("pattern_revision") or progress_flags.has("attention_model") or progress_flags.has("curriculum_drift"):
			progression_signal_line = "A familiar reading is starting to bend away from itself."
		elif progress_flags.has("school_split"):
			progression_signal_line = "Competing readings are starting to matter as much as the events themselves."
	if progression_signal_line.is_empty():
		if Array(myth_field.get("active_lines", [])).size() >= 1 and archive_legends.size() >= 1:
			progression_signal_line = "Separate echoes are beginning to answer each other directly."
		elif not str(top_successor.get("hint", "")).strip_edges().is_empty():
			progression_signal_line = "A familiar reading is starting to bend away from itself."
		elif not str(Dictionary(last_run.get("frame", {})).get("school_tension", "")).strip_edges().is_empty():
			progression_signal_line = "Competing readings are starting to matter as much as the events themselves."
	if progression_signal_line.is_empty() and progress_layer != "public":
		if progress_layer == "deepening" or progress_layer == "post_core":
			progression_signal_line = "A familiar reading is starting to bend away from itself."
		else:
			progression_signal_line = "Competing readings are starting to matter as much as the events themselves."
	if not progression_signal_line.is_empty():
		lines.append(progression_signal_line)
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines.slice(0, 8))

static func build_home_overview_lines(profile: Dictionary, session_overview: Dictionary = {}, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var account: Dictionary = Dictionary(current.get("account", {}))
	var lines: Array[String] = []
	lines.append("Rank %d | %d runs logged" % [int(account.get("level", 1)), int(account.get("runs", 0))])
	var crawl_lines := CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(current)
	var relationship_lines := PROFILE_SHELL_BUILDERS_SCRIPT.build_relationship_preview_lines(current)
	var next_rank := next_track_preview("account", int(account.get("xp", 0)), current_catalog)
	lines.append("Next rank: %s" % next_rank)
	lines.append("Momentum: %s" % PROFILE_SHELL_BUILDERS_SCRIPT.build_home_momentum_line(current, next_rank, crawl_lines, relationship_lines))
	lines.append("Continuity: %s" % PROFILE_SHELL_BUILDERS_SCRIPT.build_party_continuity_line(current, session_overview))
	var live_brief := _session_delve_brief_line(session_overview)
	if not live_brief.is_empty():
		lines.append("Live briefing: %s" % live_brief)
	if crawl_lines.size() > 1:
		lines.append(crawl_lines[1])
	var world_lines := WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(Dictionary(current.get("world_memory", {})))
	if not world_lines.is_empty():
		lines.append(world_lines[0])
		if world_lines.size() >= 2:
			lines.append(world_lines[1])
	if not relationship_lines.is_empty():
		lines.append(relationship_lines[0])
	var archive_lines := ARCHIVE_SERVICE_SCRIPT.build_archive_lines(current)
	var archive_compare := ""
	for archive_line in archive_lines:
		var text := str(archive_line).strip_edges()
		if text.begins_with("Compare:"):
			archive_compare = text
			break
	if not archive_compare.is_empty():
		lines.append(archive_compare)
	var last_frame := Dictionary(Dictionary(current.get("last_run", {})).get("frame", {}))
	var challenge_attention := str(last_frame.get("challenge_attention", "")).strip_edges()
	if not challenge_attention.is_empty():
		lines.append("Challenge: %s" % challenge_attention)
	var doctrine_line := str(last_frame.get("doctrine_line", "")).strip_edges()
	if not doctrine_line.is_empty():
		lines.append("Doctrine: %s" % doctrine_line)
	var build_line := str(last_frame.get("build_line", "")).strip_edges()
	var presence_line := str(last_frame.get("inhabitant_line", "")).strip_edges()
	var build_presence_line := _home_overview_build_presence_line(build_line, presence_line)
	if not build_presence_line.is_empty():
		lines.append(build_presence_line)
	var governance_line := str(last_frame.get("governance_line", "")).strip_edges()
	if not governance_line.is_empty():
		lines.append("World pressure: %s" % governance_line)
	var learning_lines := _to_string_array(Dictionary(current.get("last_run", {})).get("experiment_learning_lines", []))
	if not learning_lines.is_empty():
		lines.append("Research: %s" % learning_lines[0])
	var latest_legacy_track := _latest_legacy_track(current)
	if not latest_legacy_track.is_empty():
		lines.append("Legacy: %s" % str(latest_legacy_track.get("label", "")).strip_edges())
	var latest_reentry_hook := _latest_reentry_hook(current)
	if not latest_reentry_hook.is_empty():
		lines.append("Reentry: %s" % str(latest_reentry_hook.get("prompt_line", "")).strip_edges())
	var quiet_play_line := _first_string(_to_string_array(Dictionary(current.get("last_run", {})).get("quiet_play_signals", [])), "")
	if not quiet_play_line.is_empty():
		lines.append("Quiet play: %s" % quiet_play_line)
	var carryover := str(last_frame.get("ritual_pressure", "")).strip_edges()
	if carryover.is_empty():
		carryover = str(Dictionary(current.get("active_crawl", {})).get("promise_pressure", "")).strip_edges()
	if carryover.is_empty():
		carryover = str(Dictionary(current.get("active_crawl", {})).get("public_challenge", "")).strip_edges()
	if carryover.is_empty():
		carryover = str(last_frame.get("belief_line", "")).strip_edges()
	if not carryover.is_empty():
		lines.append("Carryover: %s" % carryover)
	var active_crawl: Dictionary = Dictionary(current.get("active_crawl", {}))
	var memorial := _first_string(_to_string_array(active_crawl.get("memorial_residue", [])), "")
	if not memorial.is_empty():
		lines.append("Memorial: %s" % memorial)
	var progress_lines := PROFILE_PROGRESSION_SCRIPT.build_narrative_progress_lines(
		Dictionary(current.get("narrative_progress", {})),
		Dictionary(current.get("archive_state", {})),
		Dictionary(current.get("world_memory", {}))
	)
	if not progress_lines.is_empty():
		lines.append(progress_lines[0])
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func _home_overview_build_presence_line(build_line: String, presence_line: String) -> String:
	var build_text := str(build_line).strip_edges()
	var presence_text := str(presence_line).strip_edges()
	if not build_text.is_empty() and not presence_text.is_empty():
		return "Build / Presence: %s; %s" % [build_text, presence_text]
	if not build_text.is_empty():
		return "Build: %s" % build_text
	if not presence_text.is_empty():
		return "Presence: %s" % presence_text
	return ""

static func build_mastery_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var lines: Array[String] = []
	var mastery: Dictionary = current.get("mastery", {})
	var keys: Array = mastery.keys()
	keys.sort()
	for key in keys:
		var track: Dictionary = mastery[key]
		lines.append("%s Lv.%d | XP %d | Runs %d | Wins %d | %s" % [
			str(key),
			int(track.get("level", 1)),
			int(track.get("xp", 0)),
			int(track.get("runs", 0)),
			int(track.get("wins", 0)),
			next_track_preview(str(key), int(track.get("xp", 0)), current_catalog)
		])
	return lines

static func build_achievement_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var unlocked: Array = Dictionary(current.get("achievements", {})).get("unlocked", [])
	var lines: Array[String] = []
	for achievement in PRODUCT_CATALOG_SCRIPT.achievement_entries(current_catalog):
		var achievement_id := str(achievement.get("id", ""))
		var prefix := "[Unlocked]" if unlocked.has(achievement_id) else "[Locked]"
		lines.append("%s %s - %s" % [
			prefix,
			str(achievement.get("display_name", "")),
			str(achievement.get("description", ""))
		])
	return lines

static func build_history_lines(profile: Dictionary) -> Array[String]:
	return build_recent_history_digest_lines(profile)

static func history_filter_modes() -> Array[String]:
	return [
		"ALL",
		"INTERRUPTED",
		"EXPEDITION",
		"SABOTAGE",
		"WARDEN",
		"VEIL",
		"SCAVENGER",
		"CHARGED",
		"CHAOTIC",
		"DISRUPTED",
		"HIGH_CALLOUTS",
		"REWARDING"
	]

static func history_sort_modes() -> Array[String]:
	return [
		"RECENT",
		"DRAMATIC",
		"REWARDING",
		"CALLOUT_HEAVY",
		"INTERRUPTED_FIRST"
	]

static func build_recent_history_digest_lines(profile: Dictionary) -> Array[String]:
	var current := normalize_profile(profile)
	var history: Array = Array(current.get("run_history", []))
	if history.is_empty():
		return ["Recent runs: none yet."]
	var slots := _curate_recent_run_slots(history)
	var lines: Array[String] = []
	for slot in slots:
		lines.append(_format_recent_run_strip_line(str(slot.get("label", "")), Dictionary(slot.get("model", {}))))
	return lines

static func build_home_recent_run_lines(profile: Dictionary) -> Array[String]:
	var current := normalize_profile(profile)
	var history: Array = Array(current.get("run_history", []))
	if history.is_empty():
		return ["Recent runs: none yet."]
	var lines: Array[String] = []
	for slot in _curate_recent_run_slots(history).slice(0, 3):
		lines.append(_format_recent_run_strip_line(str(slot.get("label", "")), Dictionary(slot.get("model", {}))))
	return lines

static func build_recent_run_cluster_lines(profile: Dictionary, filter_mode: String = "ALL") -> Array[String]:
	var current := normalize_profile(profile)
	var history: Array = Array(current.get("run_history", []))
	var filtered := _filter_history(history, filter_mode)
	if filtered.is_empty():
		return ["Recent clusters: no runs in this view."]
	var slots := _curate_recent_run_slots(filtered)
	var used_keys: Dictionary = {}
	for slot in slots:
		used_keys[str(Dictionary(slot.get("model", {})).get("key", ""))] = true
	var communication_model := _select_curated_history_model(filtered, "communication", used_keys)
	if not communication_model.is_empty() and _communication_slot_earns_inclusion(communication_model):
		slots.append({
			"label": "Most callout-heavy",
			"model": communication_model
		})
	var lines: Array[String] = []
	for slot in slots:
		var model: Dictionary = Dictionary(slot.get("model", {}))
		lines.append("%s: %s" % [
			str(slot.get("label", "")),
			_format_cluster_snippet(model)
		])
	return lines

static func build_run_memory_tuning_lines(profile: Dictionary, filter_mode: String = "ALL", sort_mode: String = "RECENT") -> Array[String]:
	var current := normalize_profile(profile)
	var history: Array = Array(current.get("run_history", []))
	var filtered := _filter_history(history, filter_mode)
	if filtered.is_empty():
		return ["Run memory tuning: no runs in this view."]
	var lines: Array[String] = []
	var standout_slots := _curate_recent_run_slots(filtered)
	if not standout_slots.is_empty():
		var standout_bits: Array[String] = []
		for slot in standout_slots.slice(0, 3):
			var model: Dictionary = Dictionary(slot.get("model", {}))
			standout_bits.append("%s S%d" % [str(slot.get("label", "")), int(model.get("seed", 0))])
		lines.append("Standout cluster: %s" % " | ".join(standout_bits))
	var strongest_bits := _build_strongest_cluster_bits(filtered)
	if not strongest_bits.is_empty():
		lines.append("Strongest cluster: %s" % " | ".join(strongest_bits))
	var communication_slot := _select_curated_history_model(filtered, "communication", {})
	if not communication_slot.is_empty() and _communication_slot_earns_inclusion(communication_slot):
		lines.append("Communication cluster: S%d | %s" % [
			int(communication_slot.get("seed", 0)),
			str(communication_slot.get("standout_reason", "Run review ready"))
		])
	var revisit_bits := _build_revisit_cluster_bits(filtered)
	if not revisit_bits.is_empty():
		lines.append("Revisit cluster: %s" % " | ".join(revisit_bits))
	var compare_digest := build_history_compare_digest_lines(current, filter_mode, 0, sort_mode)
	if not compare_digest.is_empty():
		lines.append("Compare digest: %s" % str(compare_digest[0]))
	var interruption_lines := build_interruption_pattern_lines(current)
	if not interruption_lines.is_empty():
		lines.append("Interruption pattern: %s" % str(interruption_lines[0]))
		if interruption_lines.size() > 1:
			lines.append("Interruption recovery: %s" % str(interruption_lines[1]))
	return lines

static func build_history_compare_digest_lines(profile: Dictionary, filter_mode: String = "ALL", selected_index: int = 0, sort_mode: String = "RECENT", selected_key: String = "") -> Array[String]:
	var state := build_history_browser_state(profile, filter_mode, sort_mode, selected_key, selected_index)
	var digest_line := str(state.get("compare_digest", ""))
	if digest_line.is_empty():
		return ["Compare digest: no runs in this view."]
	return [digest_line]

static func build_interruption_pattern_lines(profile: Dictionary) -> Array[String]:
	var current := normalize_profile(profile)
	var history: Array = Array(current.get("run_history", []))
	if history.is_empty():
		return ["Interruption pattern: no runs recorded."]
	var interrupted := 0
	var reconnect_ready := 0
	var wait_for_lobby := 0
	for entry_raw in history:
		var entry: Dictionary = Dictionary(entry_raw)
		if bool(entry.get("interrupted", false)):
			interrupted += 1
			var diagnostics: Dictionary = Dictionary(entry.get("diagnostics", {}))
			if bool(diagnostics.get("reconnect_ready", false)):
				reconnect_ready += 1
			if bool(diagnostics.get("wait_for_lobby", false)):
				wait_for_lobby += 1
	var lines: Array[String] = []
	lines.append("Interrupted: %d / %d recent runs" % [interrupted, history.size()])
	if interrupted > 0:
		lines.append("Recovery mix: %d reconnect-ready | %d wait-for-lobby" % [reconnect_ready, wait_for_lobby])
		var review_only := maxi(interrupted - reconnect_ready - wait_for_lobby, 0)
		if wait_for_lobby >= reconnect_ready and wait_for_lobby >= review_only:
			lines.append("Pattern: interruptions usually wait for host lobby recovery.")
		elif reconnect_ready >= review_only:
			lines.append("Pattern: interruptions usually return via reconnect-ready recovery.")
		else:
			lines.append("Pattern: interruptions usually end as review-only context.")
	return lines

static func build_history_browser_state(profile: Dictionary, filter_mode: String = "ALL", sort_mode: String = "RECENT", selected_key: String = "", fallback_index: int = 0) -> Dictionary:
	var current := normalize_profile(profile)
	var history: Array = Array(current.get("run_history", []))
	var filtered := _filter_history(history, filter_mode)
	var sorted_context := _sort_history_context(filtered, sort_mode)
	var entries: Array[Dictionary] = []
	var models: Array[Dictionary] = []
	for browser_index in range(sorted_context.size()):
		var context_item: Dictionary = Dictionary(sorted_context[browser_index])
		var entry: Dictionary = Dictionary(context_item.get("entry", {}))
		var model := _build_run_review_model(entry)
		model["canonical_index"] = int(context_item.get("index", browser_index))
		model["browser_index"] = browser_index
		models.append(model)
		entries.append({
			"key": str(model.get("key", "")),
			"label": str(model.get("compact_label", "")),
			"detail": "\n".join(_to_string_array(model.get("full_review_lines", [])))
		})
	var resolved_index := _resolve_history_selection_index(entries, selected_key, fallback_index)
	var resolved_key := ""
	if resolved_index >= 0 and resolved_index < entries.size():
		resolved_key = str(entries[resolved_index].get("key", ""))
	var compare_index := _resolve_history_compare_index(models, resolved_index)
	var summary_lines := _build_history_browser_summary_lines(history, filtered, models, sort_mode, filter_mode)
	var focus_lines: Array[String] = ["Filter: %s | Sort: %s" % [_history_filter_display_name(filter_mode), _history_sort_display_name(sort_mode)], "No runs match the current filter."]
	var compare_bundle := {
		"lines": ["Comparison: no runs in this filter."],
		"digest": "Compare digest: no runs in this view."
	}
	var compare_lines: Array[String] = _to_string_array(compare_bundle.get("lines", []))
	var detail_lines: Array[String] = ["No runs match the current history filter."]
	if resolved_index >= 0 and resolved_index < models.size():
		focus_lines = _format_run_review_focus_lines(models[resolved_index], filter_mode, sort_mode, resolved_index, models.size())
		detail_lines = _to_string_array(models[resolved_index].get("full_review_lines", []))
		compare_bundle = _build_run_review_compare_bundle(models, resolved_index, compare_index, filter_mode, sort_mode)
		compare_lines = _to_string_array(compare_bundle.get("lines", []))
	summary_lines = FRAMING_SERVICE_SCRIPT.guard_lines(summary_lines)
	focus_lines = FRAMING_SERVICE_SCRIPT.guard_lines(focus_lines)
	compare_lines = FRAMING_SERVICE_SCRIPT.guard_lines(compare_lines)
	detail_lines = FRAMING_SERVICE_SCRIPT.guard_lines(detail_lines)
	entries = FRAMING_SERVICE_SCRIPT.guard_entries(entries)
	return {
		"entries": entries,
		"selected_index": resolved_index,
		"selected_key": resolved_key,
		"compare_index": compare_index,
		"compare_digest": str(compare_bundle.get("digest", "")),
		"summary_lines": summary_lines,
		"focus_lines": focus_lines,
		"compare_lines": compare_lines,
		"detail_lines": detail_lines
	}

static func build_history_summary_lines(profile: Dictionary, filter_mode: String = "ALL", sort_mode: String = "RECENT") -> Array[String]:
	return _to_string_array(build_history_browser_state(profile, filter_mode, sort_mode).get("summary_lines", []))

static func build_history_focus_lines(profile: Dictionary, filter_mode: String = "ALL", selected_index: int = 0, sort_mode: String = "RECENT", selected_key: String = "") -> Array[String]:
	return _to_string_array(build_history_browser_state(profile, filter_mode, sort_mode, selected_key, selected_index).get("focus_lines", []))

static func build_history_compare_lines(profile: Dictionary, filter_mode: String = "ALL", selected_index: int = 0, sort_mode: String = "RECENT", selected_key: String = "") -> Array[String]:
	return _to_string_array(build_history_browser_state(profile, filter_mode, sort_mode, selected_key, selected_index).get("compare_lines", []))

static func build_history_entries(profile: Dictionary, filter_mode: String = "ALL", sort_mode: String = "RECENT", selected_key: String = "") -> Array[Dictionary]:
	return _to_dictionary_array(build_history_browser_state(profile, filter_mode, sort_mode, selected_key).get("entries", []))

static func build_collection_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	var item_service: RefCounted = ITEM_SERVICE_SCRIPT.new()
	var discoveries: Dictionary = current.get("discoveries", {})
	var discovered_items: Array = discoveries.get("item_defs", [])
	var item_library_ids: Array[String] = item_service.item_library_ids()
	var lines: Array[String] = []
	lines.append("Items discovered: %d / %d" % [discovered_items.size(), item_library_ids.size()])
	var world_memory: Dictionary = Dictionary(current.get("world_memory", {}))
	var top_item_entries := WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, "item", 1)
	if not top_item_entries.is_empty():
		var top_item: Dictionary = Dictionary(top_item_entries[0])
		lines.append("Current item field: %s | %s" % [str(top_item.get("label", "")), str(top_item.get("pull", "watching")).replace("_", " ")])
	for item_id in item_library_ids:
		var status := "[Seen]" if discovered_items.has(item_id) else "[Locked]"
		lines.append("%s %s" % [status, item_service.get_display_name(item_id)])
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func collection_sections() -> Array[String]:
	return ["Items", "Rooms", "Artifacts", "Clues", "Roles"]

static func build_collection_entries(profile: Dictionary, section: String, catalog: Dictionary = {}) -> Array[Dictionary]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var discoveries: Dictionary = current.get("discoveries", {})
	var entries: Array[Dictionary] = []
	match section:
		"Items":
			var item_service = ITEM_SERVICE_SCRIPT.new()
			var item_library_ids: Array[String] = item_service.item_library_ids()
			var world_items: Dictionary = Dictionary(Dictionary(Dictionary(current.get("world_memory", {})).get("myths", {})).get("item", {}))
			for item_id in item_library_ids:
				var item_def: Dictionary = item_service.get_definition(item_id)
				var authoring: Dictionary = item_service.build_authoring_profile(item_id)
				var narrative: Dictionary = Dictionary(authoring.get("narrative", {}))
				var gameplay: Dictionary = Dictionary(authoring.get("gameplay", {}))
				var world_entry: Dictionary = Dictionary(world_items.get("item:%s" % str(item_id), {}))
				var discovered := Array(discoveries.get("item_defs", [])).has(item_id)
				var successor_hint := str(world_entry.get("successor_hint", "")).strip_edges()
				var resonance_tags := _to_string_array(world_entry.get("resonance_tags", []))
				var shadow_tags := _to_string_array(world_entry.get("shadow_tags", []))
				var damping_tags := _to_string_array(world_entry.get("damping_tags", []))
				var latent_dimensions: Dictionary = Dictionary(gameplay.get("latent_dimensions", {}))
				var detail_lines := [
					item_service.get_display_name(item_id),
					"Type: %s" % str(item_def.get("category", "tool")).capitalize(),
					"Archetypes: %s" % ", ".join(item_service.get_archetypes(item_id)),
					"Public trace: %s" % str(item_def.get("public_evidence", "none")).replace("_", " "),
					"Drama roles: %s" % ", ".join(Array(narrative.get("roles", []))),
					"Sociality: %s" % ", ".join(Array(narrative.get("sociality", []))),
					"Reputation: %s" % ", ".join(Array(narrative.get("reputation", []))),
					"Plurality: %s" % ", ".join(Array(narrative.get("plurality", []))),
					"Handling: %s" % ", ".join(Array(narrative.get("handling", []))),
					"Branch pull: %s" % ", ".join(Array(narrative.get("branch_affinity", []))),
					"Protocol affinity: %s" % ", ".join(Array(gameplay.get("protocol_affinity", []))),
					"Model hooks: %s" % ", ".join(Array(narrative.get("model_hooks", []))),
					"Latent pull: %s" % ("%s / %s / %s" % [
						str(latent_dimensions.get("rescue", 0)),
						str(latent_dimensions.get("burden", 0)),
						str(latent_dimensions.get("anti_protocol_potential", 0))
					]),
					"Behavior signals: %s" % ", ".join(Array(gameplay.get("behavior_signals", []))),
					"Ritual hooks: %s" % ", ".join(Array(gameplay.get("ritual_hooks", []))),
					"Anomaly hooks: %s" % ", ".join(Array(gameplay.get("anomaly_hooks", []))),
					"Resource hooks: %s" % ", ".join(Array(gameplay.get("resource_hooks", []))),
					"Control pull: %s" % str(gameplay.get("control_pull", 0)),
					"Field: %s" % _title_case(str(world_entry.get("phase", "emergence")).replace("_", " ")),
					"Current pull: %s" % str(world_entry.get("pull", "watching")).replace("_", " "),
					"Resonance: %s" % _first_string(resonance_tags, "-"),
					"Shadow: %s" % _first_string(shadow_tags, "-"),
					"Cooling: %s" % _first_string(damping_tags, "-"),
					"Revision: %s" % (successor_hint if not successor_hint.is_empty() else "-"),
					"History pressure: %s" % _first_string(_to_string_array(world_entry.get("layers", [])), "-")
				]
				entries.append({
					"id": item_id,
					"label": "%s %s" % ["[Seen]" if discovered else "[Locked]", item_service.get_display_name(item_id)],
					"detail": "\n".join(detail_lines),
					"discovered": discovered
				})
		"Rooms":
			entries = _build_catalog_section_entries(current_catalog, "room_families", Array(discoveries.get("room_families", [])))
		"Artifacts":
			entries = _build_catalog_section_entries(current_catalog, "artifact_states", Array(discoveries.get("artifact_states", [])))
		"Clues":
			entries = _build_catalog_section_entries(current_catalog, "clue_families", Array(discoveries.get("clue_families", [])))
		"Roles":
			entries = _build_catalog_section_entries(current_catalog, "roles", Array(discoveries.get("roles", [])))
	return FRAMING_SERVICE_SCRIPT.guard_entries(entries)

static func build_codex_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var discoveries: Dictionary = current.get("discoveries", {})
	var lines: Array[String] = []
	for section in build_codex_sections(current, current_catalog):
		if ARCHIVE_SERVICE_SCRIPT.dynamic_sections().has(section):
			lines.append(_title_case(section))
			for entry in ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(current, section).slice(0, 3):
				lines.append("[Known] %s" % str(Dictionary(entry).get("label", "")))
			lines.append("")
			continue
		lines.append(section.replace("_", " ").capitalize())
		for entry in PRODUCT_CATALOG_SCRIPT.codex_entries(section, current_catalog):
			var entry_id := str(entry.get("id", ""))
			var status := "[Seen]" if Array(discoveries.get(section_to_discovery_key(section), [])).has(entry_id) else "[Unknown]"
			lines.append("%s %s" % [status, str(entry.get("display_name", ""))])
		lines.append("")
	if not lines.is_empty() and str(lines[lines.size() - 1]).is_empty():
		lines.remove_at(lines.size() - 1)
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func build_codex_sections(profile: Dictionary = {}, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var sections := PRODUCT_CATALOG_SCRIPT.codex_sections(current_catalog)
	for section in ARCHIVE_SERVICE_SCRIPT.dynamic_sections():
		if not sections.has(section):
			sections.append(section)
	return sections

static func build_codex_entries(profile: Dictionary, section: String, catalog: Dictionary = {}) -> Array[Dictionary]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	if ARCHIVE_SERVICE_SCRIPT.dynamic_sections().has(section):
		return FRAMING_SERVICE_SCRIPT.guard_entries(ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(current, section))
	var discovery_key := section_to_discovery_key(section)
	return FRAMING_SERVICE_SCRIPT.guard_entries(_build_catalog_section_entries(current_catalog, section, Array(Dictionary(current.get("discoveries", {})).get(discovery_key, []))))

static func build_last_run_lines(profile: Dictionary) -> Array[String]:
	var current := normalize_profile(profile)
	var last_run: Dictionary = Dictionary(current.get("last_run", {}))
	if last_run.is_empty():
		return ["No runs recorded yet."]
	var model := _build_run_review_model(last_run)
	var lines: Array[String] = Array(model.get("focus_packet_lines", []))
	lines.append_array(FRAMING_SERVICE_SCRIPT.build_focus_lines(Dictionary(last_run.get("frame", {}))).slice(0, 2))
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines.slice(0, 8))

static func build_last_run_reward_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var last_run: Dictionary = Dictionary(current.get("last_run", {}))
	if last_run.is_empty():
		return ["No rewards earned yet."]
	if bool(last_run.get("interrupted", false)):
		return ["Interrupted run: no progression awarded."]
	var lines: Array[String] = []
	for line_variant in Array(last_run.get("reward_breakdown", [])):
		lines.append(str(line_variant))
	for cosmetic_id in Array(last_run.get("unlocked_cosmetics", [])):
		lines.append("Unlocked cosmetic: %s" % _display_name_for_cosmetic(str(cosmetic_id), current_catalog))
	for achievement_id in Array(last_run.get("unlocked_achievements", [])):
		var achievement := PRODUCT_CATALOG_SCRIPT.get_achievement(str(achievement_id), current_catalog)
		lines.append("Milestone unlocked: %s" % str(achievement.get("display_name", achievement_id)))
	return lines if not lines.is_empty() else ["No rewards earned yet."]

static func build_last_run_diagnostic_lines(profile: Dictionary) -> Array[String]:
	var current := normalize_profile(profile)
	var last_run: Dictionary = Dictionary(current.get("last_run", {}))
	if last_run.is_empty():
		return ["No run story recorded yet."]
	var model := _build_run_review_model(last_run)
	var lines: Array[String] = []
	lines.append("Signals: %s" % RUN_STORY_DIAGNOSTICS_SCRIPT.build_signal_stack(Dictionary(model.get("diagnostics", {}))))
	if bool(model.get("interrupted", false)):
		lines.append("Recovery: %s" % str(model.get("interruption_context", "Review only")))
	else:
		lines.append("Reopen cue: %s" % str(model.get("standout_reason", "Run review ready")))
	var learning_lines := _to_string_array(last_run.get("experiment_learning_lines", []))
	if not learning_lines.is_empty():
		lines.append("Research: %s" % learning_lines[0])
	var quiet_play_line := _first_string(_to_string_array(last_run.get("quiet_play_signals", [])), "")
	if not quiet_play_line.is_empty():
		lines.append("Quiet play: %s" % quiet_play_line)
	var reentry_hook: Dictionary = Dictionary(last_run.get("reentry_hook", {}))
	var reentry_line := str(reentry_hook.get("prompt_line", "")).strip_edges()
	if not reentry_line.is_empty():
		lines.append("Reentry: %s" % reentry_line)
	var frame: Dictionary = Dictionary(last_run.get("frame", {}))
	if not frame.is_empty():
		lines.append("Broadcast: %s" % str(frame.get("broadcast_headline", "Run story ready")))
		lines.append("Heat: %s" % FRAMING_SERVICE_SCRIPT.build_home_heat_line(frame))
	return lines.slice(0, 5)

static func build_home_quick_start_lines(profile: Dictionary, session_overview: Dictionary = {}) -> Array[String]:
	var current := normalize_profile(profile)
	var lines: Array[String] = []
	var live_brief := _session_delve_brief_line(session_overview)
	if bool(current.get("first_run_pending", true)):
		lines.append("First run: recover an authentic Artifact and hold it in Extraction.")
		lines.append("Warden reads clues. Veil hides sabotage. Scavenger keeps the route alive.")
	else:
		var last_run: Dictionary = Dictionary(current.get("last_run", {}))
		var returning_result := _build_returning_run_onboarding_result_line(last_run)
		if returning_result.is_empty():
			lines.append("Returning run: host a room, ready up, and commit when the route starts forcing choices.")
		else:
			lines.append("Returning run: %s" % returning_result)
		var continuity_line := _build_returning_run_onboarding_continuity_line(last_run)
		if not continuity_line.is_empty():
			lines.append("Continuity: %s" % continuity_line)
		var reentry_hook: Dictionary = Dictionary(last_run.get("reentry_hook", {}))
		var reentry_line := str(reentry_hook.get("prompt_line", "")).strip_edges()
		if reentry_line.is_empty():
			reentry_line = str(_latest_reentry_hook(current).get("prompt_line", "")).strip_edges()
		if not reentry_line.is_empty():
			lines.append("Reentry cue: %s" % reentry_line)
	if not live_brief.is_empty():
		lines.append("Current read: %s" % live_brief)
	lines.append("Artifacts are the objective. Tools are active. Relics are passive.")
	lines.append("Progression unlocks identity only: titles, banners, notebook themes, and future cosmetics.")
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func _build_returning_run_onboarding_result_line(last_run: Dictionary) -> String:
	var artifact_result_text := str(last_run.get("artifact_result_text", "")).strip_edges()
	if artifact_result_text == "-":
		artifact_result_text = ""
	if not artifact_result_text.is_empty():
		return artifact_result_text
	return str(last_run.get("summary_text", "")).strip_edges()

static func _build_returning_run_onboarding_continuity_line(last_run: Dictionary) -> String:
	var parts: Array[String] = []
	var return_state := str(last_run.get("return_consequence_state", "")).strip_edges()
	if not return_state.is_empty():
		parts.append("Return: %s" % _humanize_onboarding_public_token(return_state))
	var burden_band := str(last_run.get("burden_band", "")).strip_edges()
	if not burden_band.is_empty():
		parts.append("Burden: %s" % _humanize_onboarding_public_token(burden_band))
	var valuation_band := str(last_run.get("valuation_band", "")).strip_edges()
	if not valuation_band.is_empty():
		parts.append("Value: %s" % _humanize_onboarding_public_token(valuation_band))
	var market_regime_id := str(last_run.get("market_regime_id", "")).strip_edges()
	if not market_regime_id.is_empty():
		parts.append("Market: %s" % _humanize_onboarding_public_sentence_token(market_regime_id.trim_prefix("market_")))
	var risk_band := str(last_run.get("market_carrier_risk_band", "")).strip_edges()
	if not risk_band.is_empty():
		parts.append("Risk: %s" % _humanize_onboarding_public_token(risk_band))
	return " | ".join(parts)

static func _humanize_onboarding_public_token(value: String) -> String:
	return _title_case(value.strip_edges().replace("_", " "))

static func _humanize_onboarding_public_sentence_token(value: String) -> String:
	var normalized := value.strip_edges().replace("_", " ").to_lower()
	if normalized.is_empty():
		return ""
	return normalized.substr(0, 1).to_upper() + normalized.substr(1)

static func build_continue_guidance_lines(profile: Dictionary, session_overview: Dictionary = {}) -> Array[String]:
	var current := normalize_profile(profile)
	var last_run: Dictionary = Dictionary(current.get("last_run", {}))
	var live_brief := _session_delve_brief_line(session_overview)
	var reconnect_target := ""
	if str(session_overview.get("join_address", "")).strip_edges() != "" and int(session_overview.get("join_port", 0)) > 0:
		reconnect_target = "%s:%d" % [str(session_overview.get("join_address", "")), int(session_overview.get("join_port", 0))]
	if bool(session_overview.get("reconnect_wait_for_lobby", false)):
		var lines: Array[String] = [
			"Next: wait for the host lobby, then reconnect.",
			"Why: this interrupted run can only regroup safely from lobby state.",
			"Also: reopen the interrupted run in Profile."
		]
		if not live_brief.is_empty():
			lines[1] = "Why: %s, and this interrupted run can only regroup safely from lobby state." % live_brief
		return lines
	if bool(session_overview.get("reconnect_available", false)):
		var lines: Array[String] = [
			"Next: reconnect to the current lobby%s." % [" (%s)" % reconnect_target if not reconnect_target.is_empty() else ""],
			"Why: the session is back in a reconnect-safe state.",
			"Also: reopen the last run first for a quick recap."
		]
		if not live_brief.is_empty():
			lines[1] = "Why: the session is back in a reconnect-safe state and currently reads as %s." % live_brief
		return lines
	if bool(session_overview.get("connected", false)):
		var lines: Array[String] = [
			"Next: ready up and start another run.",
			"Why: the current lobby can start another run right now.",
			"Also: reopen the strongest recent run in Profile."
		]
		if not live_brief.is_empty():
			lines[1] = "Why: the current lobby can start another run right now, and the live brief is %s." % live_brief
		return FRAMING_SERVICE_SCRIPT.guard_lines(lines)
	if bool(last_run.get("interrupted", false)):
		return [
			"Next: regroup, then host again or rejoin later.",
			"Why: interrupted runs stay reviewable, but they do not reserve a rematch or hold the room open.",
			"Also: reopen the interrupted run in Profile."
		]
	if not last_run.is_empty():
		var next_rank := next_track_preview("account", int(Dictionary(current.get("account", {})).get("xp", 0)))
		if int(last_run.get("xp_gain", 0)) > 0 or not Array(last_run.get("unlocked_cosmetics", [])).is_empty() or not Array(last_run.get("unlocked_achievements", [])).is_empty():
			return FRAMING_SERVICE_SCRIPT.guard_lines([
				"Next: queue another run while this one is easy to compare.",
				"Why: the last run paid progression and moved the next reward closer.",
				"Also: %s" % next_rank
			])
		return [
			"Next: queue another run or browse Profile for the last story beat.",
			"Why: recent runs are ready to compare by interruption, tone, and callouts.",
			"Also: use Profile to reopen the strongest recent run."
		]
	if bool(current.get("first_run_pending", true)):
		return [
			"Next: host a room or join a session.",
			"Why: your first expedition will start building history, mastery, and discoveries.",
			"Also: use the Home quick-start summary if you need a refresher."
		]
	return [
		"Next: host a lobby or join a session.",
		"Why: the next run will add to history, mastery, and discoveries.",
		"Also: browse Profile to compare your strongest recent runs."
	]

static func _session_delve_brief_line(session_overview: Dictionary) -> String:
	var delve_protocol: Dictionary = Dictionary(session_overview.get("delve_protocol", {}))
	if delve_protocol.is_empty():
		return ""
	var parts: Array[String] = []
	var protocol_state := str(delve_protocol.get("protocol_state", "")).strip_edges()
	var doctrine_label := str(delve_protocol.get("doctrine_label", delve_protocol.get("doctrine_family", ""))).strip_edges()
	var pressure_line := str(delve_protocol.get("pressure_line", "")).strip_edges()
	var world_goal := str(delve_protocol.get("world_goal", "")).strip_edges()
	if not protocol_state.is_empty():
		parts.append(protocol_state)
	if not doctrine_label.is_empty():
		parts.append(doctrine_label)
	if not pressure_line.is_empty():
		parts.append(pressure_line)
	elif not world_goal.is_empty():
		parts.append(world_goal)
	return " | ".join(parts)

static func build_lobby_roster_lines(profile: Dictionary, ready_state: Dictionary, public_cards: Dictionary, local_peer_id: int = -1) -> Array[String]:
	var current := normalize_profile(profile)
	var fabric: Dictionary = Dictionary(current.get("relationship_fabric", {}))
	var players_memory: Dictionary = Dictionary(fabric.get("players", {}))
	var pair_memory: Dictionary = Dictionary(fabric.get("pairs", {}))
	var crew_memory: Dictionary = Dictionary(fabric.get("crews", {}))
	var active_crawl: Dictionary = Dictionary(current.get("active_crawl", {}))
	var world_memory: Dictionary = Dictionary(current.get("world_memory", {}))
	var ready_keys: Array[int] = []
	for key in ready_state.keys():
		ready_keys.append(int(key))
	ready_keys.sort()
	var lines: Array[String] = []
	var local_card: Dictionary = Dictionary(public_cards.get(str(local_peer_id), public_cards.get(local_peer_id, {})))
	var local_public_id := str(local_card.get("public_id", "")).strip_edges()
	var world_focus := str(Dictionary(world_memory.get("fascination", {})).get("current_focus", "")).strip_edges()
	var world_pressure := str(Dictionary(world_memory.get("fascination", {})).get("pressure", "")).strip_edges()
	var shared_crew_detail := ""
	for crew_key in _to_string_array(fabric.get("recent_crews", [])):
		var crew_entry: Dictionary = Dictionary(crew_memory.get(crew_key, {}))
		if _to_string_array(crew_entry.get("members", [])).has(local_public_id):
			shared_crew_detail = _first_string(
				Array(crew_entry.get("obligations", [])),
				str(crew_entry.get("public_reputation", crew_entry.get("status_burden", "")))
			)
			break
	var crawl_memory_line := _first_string(_to_string_array(active_crawl.get("memorial_residue", [])), str(active_crawl.get("expectation_pressure", "")))
	for peer_id in ready_keys:
		var raw_card: Dictionary = Dictionary(public_cards.get(str(peer_id), public_cards.get(peer_id, {})))
		var name := str(raw_card.get("display_name", "Delver"))
		var public_id := str(raw_card.get("public_id", "peer_%d" % peer_id))
		var state := "Ready" if bool(ready_state.get(peer_id, false)) else "Not Ready"
		var title := str(raw_card.get("legend_hint", raw_card.get("title", ""))).strip_edges()
		var challenge := str(raw_card.get("challenge_hint", "")).strip_edges()
		var crew_tag := str(raw_card.get("crew_tag", "")).strip_edges()
		var build_hint := str(raw_card.get("build_hint", "")).strip_edges()
		var presence_hint := str(raw_card.get("presence_hint", "")).strip_edges()
		var heat_band := str(raw_card.get("heat_band", "")).strip_edges()
		var remembered: Dictionary = Dictionary(players_memory.get(public_id, {}))
		if title.is_empty() and not build_hint.is_empty():
			title = build_hint
		if title.is_empty():
			title = str(remembered.get("title", "Remembered delver"))
		if challenge.is_empty():
			challenge = _first_string(
				Array(remembered.get("obligations", [])),
				str(remembered.get("public_reputation", _first_string(Array(remembered.get("signals", [])), "")))
			)
		if challenge.is_empty() and not local_public_id.is_empty() and local_public_id != public_id:
			for pair_key in _to_string_array(fabric.get("recent_pairs", [])):
				var pair_entry: Dictionary = Dictionary(pair_memory.get(pair_key, {}))
				var members := _to_string_array(pair_entry.get("members", []))
				if members.has(local_public_id) and members.has(public_id):
					challenge = _first_string(
						Array(pair_entry.get("obligations", [])),
						str(pair_entry.get("public_reputation", pair_entry.get("status_burden", _first_string(Array(pair_entry.get("signals", [])), ""))))
					)
					if title.is_empty():
						title = str(pair_entry.get("title", "Recurring pair"))
					break
		if challenge.is_empty() and not shared_crew_detail.is_empty():
			challenge = shared_crew_detail
		if challenge.is_empty():
			for crew_key in _to_string_array(fabric.get("recent_crews", [])):
				var crew_entry: Dictionary = Dictionary(crew_memory.get(crew_key, {}))
				if _to_string_array(crew_entry.get("members", [])).has(public_id):
					challenge = _first_string(Array(crew_entry.get("signals", [])), "")
					if crew_tag.is_empty():
						crew_tag = str(crew_entry.get("title", "")).strip_edges()
					break
		if challenge.is_empty() and not crawl_memory_line.is_empty():
			challenge = crawl_memory_line
		if challenge.is_empty() and not str(active_crawl.get("public_challenge", "")).strip_edges().is_empty():
			challenge = str(active_crawl.get("public_challenge", ""))
		if challenge.is_empty():
			challenge = _first_string(_to_string_array(active_crawl.get("belief_pressure", [])), "")
		if challenge.is_empty() and not presence_hint.is_empty():
			challenge = presence_hint
		if challenge.is_empty() and not world_focus.is_empty():
			challenge = "Watching %s" % world_focus
		if challenge.is_empty() and not world_pressure.is_empty():
			challenge = world_pressure
		var prefix := "You (%s)" % name if peer_id == local_peer_id and local_peer_id > 0 else name
		var line := "%s - %s" % [prefix, state]
		if not title.is_empty():
			line += " | %s" % title
		if not crew_tag.is_empty():
			line += " | %s" % crew_tag
		if not challenge.is_empty():
			var challenge_text := challenge
			var challenge_lower := challenge_text.to_lower()
			if not challenge_lower.begins_with("challenge:") and not challenge_lower.begins_with("watching ") and not challenge_lower.begins_with("owes "):
				challenge_text = "Challenge: %s" % challenge_text
			line += " | %s" % challenge_text
		if not heat_band.is_empty() and heat_band != "-":
			line += " | Heat %s" % heat_band
		lines.append(line)
	if lines.is_empty():
		lines.append("No delvers connected.")
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func build_cosmetic_lines(profile: Dictionary, category: String, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var owned: Array = Dictionary(current.get("cosmetics", {})).get("owned", [])
	var equipped: Dictionary = Dictionary(Dictionary(current.get("cosmetics", {})).get("equipped", {}))
	var lines: Array[String] = []
	for cosmetic in PRODUCT_CATALOG_SCRIPT.get_cosmetics(category, current_catalog):
		var cosmetic_id := str(cosmetic.get("id", ""))
		var slot := str(cosmetic.get("slot", ""))
		var prefix := "[Owned]" if owned.has(cosmetic_id) else "[Locked]"
		if str(equipped.get(slot, "")) == cosmetic_id:
			prefix = "[Equipped]"
		lines.append("%s %s - %s" % [prefix, str(cosmetic.get("display_name", "")), PRODUCT_CATALOG_SCRIPT.describe_source(cosmetic)])
	return lines

static func build_cosmetic_detail_lines(profile: Dictionary, cosmetic_id: String, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var cosmetic := PRODUCT_CATALOG_SCRIPT.get_cosmetic(cosmetic_id, current_catalog)
	if cosmetic.is_empty():
		return ["Select a cosmetic to preview it."]
	var current := normalize_profile(profile, current_catalog)
	var owned: Array = Dictionary(current.get("cosmetics", {})).get("owned", [])
	var equipped: Dictionary = Dictionary(Dictionary(current.get("cosmetics", {})).get("equipped", {}))
	var slot := str(cosmetic.get("slot", ""))
	var lines: Array[String] = []
	lines.append(str(cosmetic.get("display_name", "")))
	lines.append("Family: %s | Rarity: %s" % [str(cosmetic.get("family", "")).capitalize(), str(cosmetic.get("rarity", "common")).capitalize()])
	lines.append("Source: %s" % PRODUCT_CATALOG_SCRIPT.describe_source(cosmetic))
	lines.append("State: %s" % ["Equipped" if str(equipped.get(slot, "")) == cosmetic_id else ("Owned" if owned.has(cosmetic_id) else "Locked")])
	lines.append("Route: %s" % str(cosmetic.get("acquisition_route", "unknown")).replace("_", " "))
	var modulation_profile: Dictionary = Dictionary(cosmetic.get("modulation_profile", {}))
	var equivalence_class_id := str(modulation_profile.get("equivalence_class_id", "")).strip_edges()
	if not equivalence_class_id.is_empty():
		var behavior: Dictionary = Dictionary(cosmetic.get("normalization_behavior", {}))
		lines.append("Modulation: %s" % str(modulation_profile.get("summary_line", "Bounded zero-advantage modulation")))
		lines.append("Equivalence class: %s" % equivalence_class_id)
		lines.append("Normalization: default=%s | fairness=%s" % [
			str(behavior.get("default", "allow")),
			str(behavior.get("fairness_sensitive", "collapse_to_canonical"))
		])
	var palette: Dictionary = cosmetic.get("palette", {})
	if not palette.is_empty():
		lines.append("Palette: %s / %s" % [str(palette.get("border", "-")), str(palette.get("accent", "-"))])
	return lines

static func build_settings_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	var settings: Dictionary = current.get("settings", {})
	return [
		"Large Text: %s" % ["On" if bool(settings.get("large_text", false)) else "Off"],
		"Hints: %s" % str(settings.get("hint_mode", "full")).capitalize(),
		"Controller Glyphs: %s" % ["On" if bool(settings.get("controller_glyphs", false)) else "Off"],
		"Voice: %s" % _describe_voice_mode(str(settings.get("voice_mode", "off"))),
		"Push-to-talk: %s" % ["On" if bool(settings.get("push_to_talk", true)) else "Off"],
		"Mute Voice: %s" % ["On" if bool(settings.get("mute_voice", false)) else "Off"],
		"Normalization: %s" % _title_case(str(current.get("normalization_mode", "default")).replace("_", " "))
	]

static func build_settings_help_lines(profile: Dictionary) -> Array[String]:
	var current := normalize_profile(profile)
	var settings: Dictionary = current.get("settings", {})
	return [
		"LB/RB or PgUp/PgDn: switch shell tabs",
		"Enter/Space: activate focused control",
		"Esc / B: return to Home tab",
		"Profile flow: filter -> sort -> run list",
		"Hint mode: %s" % str(settings.get("hint_mode", "full")).capitalize(),
		"Voice mode: %s" % _describe_voice_mode(str(settings.get("voice_mode", "off"))),
		"Room callouts are public and safe to use while platforming.",
		"Voice stays fairness-safe: callouts remain the fallback during movement and hidden roles never gain extra info."
	]

static func build_voice_surface_lines(profile: Dictionary, session_overview: Dictionary = {}) -> Array[String]:
	var current := normalize_profile(profile)
	var settings: Dictionary = current.get("settings", {})
	var multimodal_contract: Dictionary = Dictionary(current.get("multimodal_contract", {}))
	var voice_contract_ready := MULTIMODAL_CONTRACT_SERVICE_SCRIPT.can_emit_summary(multimodal_contract, "voice_policy", "archive_summary")
	var mode := str(settings.get("voice_mode", "off"))
	var lines: Array[String] = []
	match mode:
		"push_to_talk":
			lines.append("Voice mode: Push-to-talk policy is armed for future lobby transport.")
		"open_mic":
			lines.append("Voice mode: Open mic policy is armed for future lobby transport.")
		_:
			lines.append("Voice mode: Off. Room callouts cover movement-heavy play.")
	if bool(settings.get("push_to_talk", true)):
		lines.append("PTT setting: Hold-to-speak behavior is preferred if transport is added later.")
	else:
		lines.append("PTT setting: Off; mode policy decides behavior if transport is added later.")
	if bool(settings.get("mute_voice", false)):
		lines.append("Mute setting: incoming voice would be muted locally.")
	else:
		lines.append("Mute setting: incoming voice would stay unmuted locally.")
	if bool(session_overview.get("connected", false)):
		lines.append("Lifecycle: this active lobby can carry voice policy state when transport is introduced.")
	elif bool(session_overview.get("reconnect_available", false)) or bool(session_overview.get("reconnect_wait_for_lobby", false)):
		lines.append("Lifecycle: reconnect state keeps voice policy ready for the next lobby rejoin.")
	else:
		lines.append("Lifecycle: voice policy is saved locally for the next hosted or joined lobby.")
	if voice_contract_ready:
		lines.append("Consent: voice policy is explicitly opted in for shell/archive-safe summaries only.")
	else:
		lines.append("Consent: multimodal summaries stay disabled until explicit opt-in is granted.")
	lines.append("Fallback: room callouts remain the fairness-safe option during platforming.")
	return lines

static func cycle_equipped_cosmetic(profile: Dictionary, category: String, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var choices: Array[String] = []
	var owned: Array = Dictionary(current.get("cosmetics", {})).get("owned", [])
	for cosmetic in PRODUCT_CATALOG_SCRIPT.get_cosmetics(category, current_catalog):
		var cosmetic_id := str(cosmetic.get("id", ""))
		if owned.has(cosmetic_id):
			choices.append(cosmetic_id)
	if choices.is_empty():
		return current
	choices.sort()
	var slot := category
	var cosmetics: Dictionary = Dictionary(current.get("cosmetics", {}))
	var equipped: Dictionary = Dictionary(cosmetics.get("equipped", {}))
	var current_id := str(equipped.get(slot, ""))
	var index := choices.find(current_id)
	var next_id := choices[(index + 1) % choices.size()] if index >= 0 else choices[0]
	equipped[slot] = next_id
	cosmetics["equipped"] = equipped
	current["cosmetics"] = cosmetics
	return normalize_profile(current, current_catalog)

static func equip_cosmetic(profile: Dictionary, cosmetic_id: String, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var cosmetic := PRODUCT_CATALOG_SCRIPT.get_cosmetic(cosmetic_id, current_catalog)
	if cosmetic.is_empty():
		return current
	var owned: Array = Dictionary(current.get("cosmetics", {})).get("owned", [])
	if not owned.has(cosmetic_id):
		return current
	var cosmetics: Dictionary = Dictionary(current.get("cosmetics", {}))
	var equipped: Dictionary = Dictionary(cosmetics.get("equipped", {}))
	equipped[str(cosmetic.get("slot", ""))] = cosmetic_id
	cosmetics["equipped"] = equipped
	current["cosmetics"] = cosmetics
	return normalize_profile(current, current_catalog)

static func set_setting(profile: Dictionary, key: String, value, catalog: Dictionary = {}) -> Dictionary:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	var settings: Dictionary = Dictionary(current.get("settings", {}))
	settings[key] = value
	current["settings"] = settings
	return current

static func toggle_hint_mode(profile: Dictionary, catalog: Dictionary = {}) -> Dictionary:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	var current_mode := str(Dictionary(current.get("settings", {})).get("hint_mode", "full"))
	var next_mode := "minimal" if current_mode == "full" else "full"
	return set_setting(current, "hint_mode", next_mode, catalog)

static func toggle_voice_mode(profile: Dictionary, catalog: Dictionary = {}) -> Dictionary:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	var current_mode := str(Dictionary(current.get("settings", {})).get("voice_mode", "off"))
	var next_mode := "push_to_talk"
	if current_mode == "push_to_talk":
		next_mode = "open_mic"
	elif current_mode == "open_mic":
		next_mode = "off"
	return set_setting(current, "voice_mode", next_mode, catalog)

static func set_multimodal_modality_consent(profile: Dictionary, modality_id: String, enabled: bool, catalog: Dictionary = {}) -> Dictionary:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	current["multimodal_contract"] = MULTIMODAL_CONTRACT_SERVICE_SCRIPT.set_modality_consent(
		Dictionary(current.get("multimodal_contract", {})),
		modality_id,
		enabled
	)
	return current

static func reset_settings(profile: Dictionary, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	current["settings"] = Dictionary(current_catalog.get("settings_defaults", {})).duplicate(true)
	return normalize_profile(current, current_catalog)

static func section_to_discovery_key(section: String) -> String:
	match section:
		"room_families":
			return "room_families"
		"artifact_states":
			return "artifact_states"
		"clue_families":
			return "clue_families"
		_:
			return section

static func _apply_discoveries(profile: Dictionary, run_record: Dictionary) -> void:
	var discoveries: Dictionary = Dictionary(profile.get("discoveries", {}))
	for key in ["item_defs", "room_families", "artifact_states", "roles", "clue_families"]:
		var values: Array = discoveries.get(key, [])
		for value in Array(run_record.get(key, [])):
			var text := str(value)
			if not text.is_empty() and not values.has(text):
				values.append(text)
		values.sort()
		discoveries[key] = values
	profile["discoveries"] = discoveries

static func _apply_career_stats(profile: Dictionary, run_record: Dictionary, outcome_summary: Dictionary) -> void:
	var stats: Dictionary = Dictionary(run_record.get("stats", {}))
	var career_stats: Dictionary = Dictionary(profile.get("career_stats", {}))
	career_stats["notes_written"] = int(career_stats.get("notes_written", 0)) + int(stats.get("notes_count", 0))
	career_stats["pins_used"] = int(career_stats.get("pins_used", 0)) + int(stats.get("pinned_count", 0))
	career_stats["inspections"] = int(career_stats.get("inspections", 0)) + int(stats.get("inspections_count", 0))
	if bool(run_record.get("interrupted", false)):
		career_stats["interrupted_runs"] = int(career_stats.get("interrupted_runs", 0)) + 1
	var artifact_result := str(outcome_summary.get("artifact_result", ""))
	if artifact_result == "authentic":
		career_stats["authentic_extractions"] = int(career_stats.get("authentic_extractions", 0)) + 1
	elif artifact_result == "counterfeit":
		career_stats["counterfeit_extractions"] = int(career_stats.get("counterfeit_extractions", 0)) + 1
	profile["career_stats"] = career_stats

static func _filter_history(history: Array, filter_mode: String) -> Array:
	var filtered: Array = []
	for entry_raw in history:
		var entry: Dictionary = entry_raw
		if _history_entry_matches_filter(entry, filter_mode):
			filtered.append(entry)
	return filtered

static func _history_entry_matches_filter(entry: Dictionary, filter_mode: String) -> bool:
	match filter_mode:
		"INTERRUPTED":
			return bool(entry.get("interrupted", false))
		"EXPEDITION":
			return str(entry.get("artifact_result_text", "")).to_lower().find("authentic") != -1
		"SABOTAGE":
			return str(entry.get("artifact_result_text", "")).to_lower().find("counterfeit") != -1 or str(entry.get("summary_text", "")).to_lower().find("sabotage") != -1
		"WARDEN", "VEIL", "SCAVENGER":
			return str(entry.get("local_role", "")).to_upper() == filter_mode
		"CHARGED", "CHAOTIC", "DISRUPTED":
			return str(entry.get("story_tone", "")).to_upper() == filter_mode
		"HIGH_CALLOUTS":
			var diagnostics: Dictionary = Dictionary(entry.get("diagnostics", {}))
			return int(diagnostics.get("communication_beats", 0)) >= 2
		"REWARDING":
			return int(entry.get("xp_gain", 0)) >= 150 or int(entry.get("mastery_gain", 0)) >= 80
		_:
			return true

static func _history_filter_display_name(filter_mode: String) -> String:
	return filter_mode.capitalize().replace("_", " ")

static func _history_sort_display_name(sort_mode: String) -> String:
	return sort_mode.capitalize().replace("_", " ")

static func _history_entry_key(entry: Dictionary) -> String:
	var report_path := str(entry.get("report_path", "")).strip_edges()
	if not report_path.is_empty():
		return report_path
	return "%d|%s|%s|%s" % [
		int(entry.get("seed", 0)),
		str(entry.get("local_role", "")),
		str(entry.get("summary_text", "")),
		str(entry.get("interruption_reason", ""))
	]

static func current_normalization_mode(profile: Dictionary, catalog: Dictionary = {}) -> String:
	var current := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	return str(current.get("normalization_mode", "default")).strip_edges()

static func build_equipped_modulation_loadout(profile: Dictionary, catalog: Dictionary = {}) -> Array[Dictionary]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	return Array(current.get("equipped_modulation_loadout", [])).duplicate(true)

static func _build_run_review_model(entry: Dictionary) -> Dictionary:
	var diagnostics: Dictionary = Dictionary(entry.get("diagnostics", {}))
	var tags := RUN_STORY_DIAGNOSTICS_SCRIPT.build_highlight_tags(diagnostics)
	var compact_tags: Array[String] = []
	for tag in tags:
		if compact_tags.size() >= 2:
			break
		compact_tags.append("[%s]" % str(tag))
	var role := str(entry.get("local_role", "Unknown"))
	var summary_text := str(entry.get("summary_text", "Run complete"))
	var interrupted := bool(entry.get("interrupted", false))
	var xp_gain := int(entry.get("xp_gain", 0))
	var mastery_gain := int(entry.get("mastery_gain", 0))
	var reward_band := _reward_significance_band(entry)
	var communication_band := RUN_STORY_DIAGNOSTICS_SCRIPT.build_communication_density_band(diagnostics)
	var dramatic_band := RUN_STORY_DIAGNOSTICS_SCRIPT.build_dramatic_intensity_band(diagnostics)
	var revisit_band := RUN_STORY_DIAGNOSTICS_SCRIPT.build_revisit_worthiness_band(diagnostics)
	var revisit_score := RUN_STORY_DIAGNOSTICS_SCRIPT.revisit_worthiness_score(diagnostics)
	var revisit_reason := RUN_STORY_DIAGNOSTICS_SCRIPT.build_revisit_worthiness_reason(diagnostics)
	var interruption_context := RUN_STORY_DIAGNOSTICS_SCRIPT.build_interruption_context(diagnostics)
	var interruption_bucket := RUN_STORY_DIAGNOSTICS_SCRIPT.build_interruption_pattern_bucket(diagnostics)
	var key_clues := Array(entry.get("key_clues", []))
	var actions := Array(entry.get("action_summary", []))
	var standout_reason := _build_run_review_standout_reason(entry, diagnostics)
	var frame: Dictionary = Dictionary(entry.get("frame", {}))
	var key := _history_entry_key(entry)
	var model := {
		"key": key,
		"seed": int(entry.get("seed", 0)),
		"role": role,
		"summary_text": summary_text,
		"artifact_text": str(entry.get("artifact_result_text", "-")),
		"role_result_success": bool(entry.get("role_result_success", false)),
		"xp_gain": xp_gain,
		"mastery_gain": mastery_gain,
		"report_path": str(entry.get("report_path", "")),
		"interrupted": interrupted,
		"interruption_reason": str(entry.get("interruption_reason", "")),
		"reward_band": reward_band,
		"reward_rank": _reward_significance_rank(entry),
		"communication_band": communication_band,
		"communication_rank": RUN_STORY_DIAGNOSTICS_SCRIPT.communication_density_rank(diagnostics),
		"dramatic_band": dramatic_band,
		"dramatic_rank": RUN_STORY_DIAGNOSTICS_SCRIPT.dramatic_intensity_rank(diagnostics),
		"revisit_band": revisit_band,
		"revisit_score": revisit_score,
		"revisit_reason": revisit_reason,
		"interruption_context": interruption_context,
		"interruption_bucket": interruption_bucket,
		"standout_reason": standout_reason,
		"memorable_reason": RUN_STORY_DIAGNOSTICS_SCRIPT.build_memorable_reason(diagnostics),
		"highlight_tags": tags,
		"compact_tags": compact_tags,
		"diagnostics": diagnostics,
		"frame": frame,
		"crawl_id": str(entry.get("crawl_id", "")),
		"crawl_title": str(entry.get("crawl_title", "")),
		"legacy_track": Dictionary(entry.get("legacy_track", {})).duplicate(true),
		"reentry_hook": Dictionary(entry.get("reentry_hook", {})).duplicate(true),
		"key_clues": key_clues,
		"actions": actions
	}
	model["compact_label"] = _format_run_review_label(model)
	model["focus_packet_lines"] = _format_run_review_focus_packet_lines(model)
	model["full_review_lines"] = _format_run_review_packet_lines(model)
	model["digest_snippet"] = _format_run_review_digest_snippet(model)
	model["reentry_snippet"] = _format_run_review_reentry_snippet(model)
	model["developer_summary_lines"] = _format_run_review_developer_summary_lines(model)
	return model

static func _build_history_browser_summary_lines(history: Array, filtered_history: Array, models: Array[Dictionary], sort_mode: String, filter_mode: String) -> Array[String]:
	var interrupted := 0
	for entry_raw in history:
		if bool(Dictionary(entry_raw).get("interrupted", false)):
			interrupted += 1
	var lines: Array[String] = []
	lines.append("View: %s | Sort: %s" % [_history_filter_display_name(filter_mode), _history_sort_display_name(sort_mode)])
	lines.append("Runs: %d shown / %d logged%s" % [
		filtered_history.size(),
		history.size(),
		" | %d interrupted" % interrupted if interrupted > 0 else ""
	])
	if not models.is_empty():
		var standout_labels: Array[String] = []
		for slot in _curate_recent_run_slots(filtered_history).slice(0, 2):
			var model: Dictionary = Dictionary(slot.get("model", {}))
			standout_labels.append("%s S%d" % [str(slot.get("label", "")), int(model.get("seed", 0))])
		if not standout_labels.is_empty():
			lines.append("Standouts: %s" % " | ".join(standout_labels))
	return lines

static func _format_run_review_label(model: Dictionary) -> String:
	var badge_text := " ".join(Array(model.get("compact_tags", [])))
	if not badge_text.is_empty():
		badge_text = " " + badge_text
	return "S%d | %s | %s%s" % [
		int(model.get("seed", 0)),
		str(model.get("role", "Unknown")),
		str(model.get("summary_text", "Run complete")),
		badge_text
	]

static func _format_run_review_focus_lines(model: Dictionary, filter_mode: String, sort_mode: String, selected_index: int, total: int) -> Array[String]:
	var lines: Array[String] = []
	lines.append("Selected %d/%d: %s" % [selected_index + 1, total, str(model.get("compact_label", ""))])
	lines.append("Why reopen: %s" % _build_run_review_reopen_reason(model))
	lines.append("Standout: %s" % str(model.get("standout_reason", "Run review ready")))
	lines.append("Signals: %s | %s | %s" % [
		str(model.get("revisit_band", "Low")),
		str(model.get("dramatic_band", "Steady")),
		str(model.get("communication_band", "Quiet"))
	])
	return lines

static func _format_run_review_focus_packet_lines(model: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	lines.append("Latest: %s" % str(model.get("compact_label", "")))
	lines.append("Outcome: %s | %s" % [str(model.get("artifact_text", "-")), _format_run_review_progress_line(model)])
	lines.append("Why reopen now: %s" % _build_run_review_reopen_reason(model))
	return lines

static func _format_run_review_packet_lines(model: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	lines.append("RUN")
	lines.append(str(model.get("compact_label", "")))
	lines.append("Outcome: %s" % str(model.get("artifact_text", "-")))
	lines.append("Progression: %s" % _format_run_review_progress_line(model))
	var diagnostics: Dictionary = Dictionary(model.get("diagnostics", {}))
	var communication_beats := int(diagnostics.get("communication_beats", 0))
	if communication_beats > 0 or int(diagnostics.get("pressure_beats", 0)) > 0:
		lines.append("Callouts: %d | Pressure beats: %d" % [communication_beats, int(diagnostics.get("pressure_beats", 0))])
	lines.append("Review value: %s | %s | %s" % [
		str(model.get("revisit_band", "Low")),
		str(model.get("dramatic_band", "Steady")),
		str(model.get("communication_band", "Quiet"))
	])
	lines.append("Why revisit: %s" % str(model.get("memorable_reason", "")))
	lines.append("Standout: %s" % str(model.get("standout_reason", "Run review ready")))
	lines.append("Session: %s" % str(model.get("interruption_context", "Completed")))
	var clue_preview := _build_preview_lines(Array(model.get("key_clues", [])), 3)
	if not clue_preview.is_empty():
		lines.append("Key clues:")
		for clue in clue_preview:
			lines.append("- %s" % clue)
		var total_clues := Array(model.get("key_clues", [])).size()
		if total_clues > clue_preview.size():
			lines.append("- ... %d more logged" % (total_clues - clue_preview.size()))
	var action_preview := _build_preview_lines(Array(model.get("actions", [])), 3)
	if not action_preview.is_empty():
		lines.append("Action summary:")
		for action in action_preview:
			lines.append("- %s" % action)
		var total_actions := Array(model.get("actions", [])).size()
		if total_actions > action_preview.size():
			lines.append("- ... %d more logged" % (total_actions - action_preview.size()))
	if not str(model.get("report_path", "")).is_empty():
		lines.append("Report: %s" % str(model.get("report_path", "")))
	return lines

static func _format_run_review_digest_snippet(model: Dictionary) -> String:
	return "%s | %s | %s" % [
		"Seed %d" % int(model.get("seed", 0)),
		str(model.get("standout_reason", "Run review ready")),
		str(model.get("revisit_band", "Low"))
	]

static func _format_run_review_reentry_snippet(model: Dictionary) -> String:
	var reentry_hook: Dictionary = Dictionary(model.get("reentry_hook", {}))
	var reentry_line := str(reentry_hook.get("prompt_line", "")).strip_edges()
	if not reentry_line.is_empty():
		return "%s | %s" % [str(model.get("summary_text", "Run complete")), reentry_line]
	return "%s | %s" % [str(model.get("summary_text", "Run complete")), str(model.get("standout_reason", "Run review ready"))]

static func _format_run_review_developer_summary_lines(model: Dictionary) -> Array[String]:
	var diagnostics: Dictionary = Dictionary(model.get("diagnostics", {}))
	return [
		"Revisit=%s (%d) | Reward=%s | Communication=%s" % [
			str(model.get("revisit_band", "Low")),
			int(model.get("revisit_score", 0)),
			str(model.get("reward_band", "None")),
			str(model.get("communication_band", "Quiet"))
		],
		"Interrupt=%s | Dramatic=%s | Cluster=%s" % [
			str(model.get("interruption_context", "Completed")),
			str(model.get("dramatic_band", "Steady")),
			RUN_STORY_DIAGNOSTICS_SCRIPT.build_run_cluster_label(diagnostics)
		],
		"Reason=%s | Bucket=%s" % [
			str(model.get("revisit_reason", "light recap value")),
			str(model.get("interruption_bucket", "Completed"))
		],
		"Seed=%d | Report=%s" % [int(model.get("seed", 0)), str(model.get("report_path", "-"))]
	]

static func _format_run_review_compare_lines(models: Array[Dictionary], selected_index: int, compare_index: int, filter_mode: String, sort_mode: String) -> Array[String]:
	return Array(_build_run_review_compare_bundle(models, selected_index, compare_index, filter_mode, sort_mode).get("lines", []))

static func _build_run_review_compare_bundle(models: Array[Dictionary], selected_index: int, compare_index: int, filter_mode: String, sort_mode: String) -> Dictionary:
	if models.is_empty():
		return {
			"lines": ["Comparison: no runs in this filter."],
			"digest": "No runs in this view."
		}
	var selected: Dictionary = models[selected_index]
	if compare_index < 0 or compare_index >= models.size():
		return {
			"lines": [
				"Compare: this is the only run in the current filter.",
				"Context: no peer run is available inside %s / %s." % [_history_filter_display_name(filter_mode), _history_sort_display_name(sort_mode)]
			],
			"digest": "Only run in %s / %s." % [_history_filter_display_name(filter_mode), _history_sort_display_name(sort_mode)]
		}
	var peer: Dictionary = models[compare_index]
	var compare_line := "Contrast: %s versus S%d." % [
		_build_compare_primary_contrast_phrase(selected, peer),
		int(peer.get("seed", 0))
	]
	var reason_line := "Why reopen: %s." % _build_compare_action_reason(models, selected_index, compare_index)
	var dimensions := _build_compare_difference_dimensions(selected, peer)
	var dimension_label := dimensions[0] if not dimensions.is_empty() else "closest_peer"
	var digest := "%s | %s" % [
		compare_line.replace("Contrast: ", "").trim_suffix("."),
		reason_line.replace("Why reopen: ", "").trim_suffix(".")
	]
	if dimension_label != "closest_peer":
		digest += " | Dimension: %s" % dimension_label
	return {
		"lines": [compare_line, reason_line],
		"digest": digest
	}

static func _resolve_history_selection_index(entries: Array[Dictionary], selected_key: String, fallback_index: int) -> int:
	if entries.is_empty():
		return -1
	if not selected_key.is_empty():
		for i in range(entries.size()):
			if str(entries[i].get("key", "")) == selected_key:
				return i
	return clampi(fallback_index, 0, entries.size() - 1)

static func _resolve_history_compare_index(models: Array[Dictionary], selected_index: int) -> int:
	if models.size() <= 1 or selected_index < 0 or selected_index >= models.size():
		return -1
	var selected := models[selected_index]
	var nearest := _resolve_nearest_peer_index(models, selected_index)
	if nearest == -1:
		return -1
	var best_index := nearest
	var best_signature := _build_compare_priority_signature(selected, Dictionary(models[nearest]), nearest, selected_index)
	for i in range(models.size()):
		if i == selected_index:
			continue
		var candidate: Dictionary = models[i]
		var candidate_signature := _build_compare_priority_signature(selected, candidate, i, selected_index)
		if _compare_priority_signature_better(candidate_signature, best_signature):
			best_signature = candidate_signature
			best_index = i
	if _compare_contrast_score(selected, Dictionary(models[best_index])) <= 0:
		return nearest
	return best_index

static func _compare_contrast_score(selected: Dictionary, peer: Dictionary) -> int:
	var score := 0
	if bool(selected.get("interrupted", false)) != bool(peer.get("interrupted", false)):
		score += 100
	score += absi(int(selected.get("reward_rank", 0)) - int(peer.get("reward_rank", 0))) * 30
	score += absi(int(selected.get("communication_rank", 0)) - int(peer.get("communication_rank", 0))) * 20
	score += absi(int(selected.get("dramatic_rank", 0)) - int(peer.get("dramatic_rank", 0))) * 15
	if str(selected.get("role", "")) != str(peer.get("role", "")):
		score += 5
	return score

static func _resolve_nearest_peer_index(models: Array[Dictionary], selected_index: int) -> int:
	var left_index := selected_index - 1
	var right_index := selected_index + 1
	if left_index < 0:
		return right_index if right_index < models.size() else -1
	if right_index >= models.size():
		return left_index
	var left_distance: int = absi(left_index - selected_index)
	var right_distance: int = absi(right_index - selected_index)
	if left_distance == right_distance:
		return left_index if int(Dictionary(models[left_index]).get("canonical_index", left_index)) <= int(Dictionary(models[right_index]).get("canonical_index", right_index)) else right_index
	return left_index if left_distance < right_distance else right_index

static func _build_compare_priority_signature(selected: Dictionary, peer: Dictionary, peer_index: int, selected_index: int) -> Array[int]:
	return [
		1 if bool(selected.get("interrupted", false)) != bool(peer.get("interrupted", false)) else 0,
		absi(int(selected.get("reward_rank", 0)) - int(peer.get("reward_rank", 0))),
		absi(int(selected.get("communication_rank", 0)) - int(peer.get("communication_rank", 0))),
		absi(int(selected.get("dramatic_rank", 0)) - int(peer.get("dramatic_rank", 0))),
		-abs(peer_index - selected_index),
		-int(peer.get("canonical_index", peer_index))
	]

static func _build_compare_contrast_bits(selected: Dictionary, peer: Dictionary) -> Array[String]:
	var bits: Array[String] = []
	if int(selected.get("reward_rank", 0)) != int(peer.get("reward_rank", 0)):
		bits.append("%s rewarding" % ["more" if int(selected.get("reward_rank", 0)) > int(peer.get("reward_rank", 0)) else "less"])
	if int(selected.get("communication_rank", 0)) != int(peer.get("communication_rank", 0)):
		bits.append("%s callout-heavy" % ["more" if int(selected.get("communication_rank", 0)) > int(peer.get("communication_rank", 0)) else "less"])
	if int(selected.get("dramatic_rank", 0)) != int(peer.get("dramatic_rank", 0)):
		bits.append("%s dramatic" % ["more" if int(selected.get("dramatic_rank", 0)) > int(peer.get("dramatic_rank", 0)) else "less"])
	if bits.is_empty() and bool(selected.get("interrupted", false)) != bool(peer.get("interrupted", false)):
		bits.append("interrupted instead of completed" if bool(selected.get("interrupted", false)) else "completed instead of interrupted")
	return bits

static func _build_compare_difference_dimensions(selected: Dictionary, peer: Dictionary) -> Array[String]:
	var dimensions: Array[String] = []
	if bool(selected.get("interrupted", false)) != bool(peer.get("interrupted", false)):
		dimensions.append("interruption")
	if int(selected.get("reward_rank", 0)) != int(peer.get("reward_rank", 0)):
		dimensions.append("reward")
	if int(selected.get("communication_rank", 0)) != int(peer.get("communication_rank", 0)):
		dimensions.append("communication")
	if int(selected.get("dramatic_rank", 0)) != int(peer.get("dramatic_rank", 0)):
		dimensions.append("dramatic")
	return dimensions

static func _build_compare_primary_contrast_phrase(selected: Dictionary, peer: Dictionary) -> String:
	if bool(selected.get("interrupted", false)) != bool(peer.get("interrupted", false)):
		return "interrupted instead of completed" if bool(selected.get("interrupted", false)) else "completed instead of interrupted"
	if int(selected.get("reward_rank", 0)) != int(peer.get("reward_rank", 0)):
		return "%s reward signal" % ["higher" if int(selected.get("reward_rank", 0)) > int(peer.get("reward_rank", 0)) else "lower"]
	if int(selected.get("communication_rank", 0)) != int(peer.get("communication_rank", 0)):
		return "%s callout density" % ["heavier" if int(selected.get("communication_rank", 0)) > int(peer.get("communication_rank", 0)) else "lighter"]
	if int(selected.get("dramatic_rank", 0)) != int(peer.get("dramatic_rank", 0)):
		return "%s dramatic swing" % ["sharper" if int(selected.get("dramatic_rank", 0)) > int(peer.get("dramatic_rank", 0)) else "steadier"]
	return "closest peer reads the same overall"

static func _compare_priority_signature_better(candidate: Array[int], incumbent: Array[int]) -> bool:
	var count := mini(candidate.size(), incumbent.size())
	for i in range(count):
		var candidate_value := int(candidate[i])
		var incumbent_value := int(incumbent[i])
		if candidate_value == incumbent_value:
			continue
		return candidate_value > incumbent_value
	return false

static func _build_preview_lines(source_lines: Array, limit: int) -> Array[String]:
	var preview: Array[String] = []
	for line_variant in source_lines.slice(0, limit):
		preview.append(str(line_variant))
	return preview

static func _reward_significance_rank(entry: Dictionary) -> int:
	if bool(entry.get("interrupted", false)):
		return 0
	var reward_total := int(entry.get("xp_gain", 0)) + int(entry.get("mastery_gain", 0))
	if reward_total >= 240:
		return 3
	if reward_total >= 160:
		return 2
	if reward_total > 0:
		return 1
	return 0

static func _reward_significance_band(entry: Dictionary) -> String:
	match _reward_significance_rank(entry):
		3:
			return "Major"
		2:
			return "Strong"
		1:
			return "Light"
		_:
			return "None"

static func _build_run_review_standout_reason(entry: Dictionary, diagnostics: Dictionary) -> String:
	if bool(entry.get("interrupted", false)):
		return "Best interruption review"
	if _reward_significance_rank(entry) >= 2:
		return "Strong reward run"
	if RUN_STORY_DIAGNOSTICS_SCRIPT.communication_density_rank(diagnostics) >= 2:
		return "Communication-heavy run"
	if RUN_STORY_DIAGNOSTICS_SCRIPT.dramatic_intensity_rank(diagnostics) >= 3:
		return "Dramatic run"
	return RUN_STORY_DIAGNOSTICS_SCRIPT.build_memorable_reason(diagnostics)

static func _build_run_review_reopen_reason(model: Dictionary) -> String:
	if bool(model.get("interrupted", false)):
		return "interruption review plus lobby regroup context" if str(model.get("interruption_context", "")) == "Wait for lobby" else "interruption review with reconnect-safe context"
	var revisit_reason := str(model.get("revisit_reason", "")).strip_edges()
	if revisit_reason.is_empty() or revisit_reason == "light recap value":
		return str(model.get("memorable_reason", "Run review ready"))
	if str(model.get("revisit_band", "Low")) == "Low":
		return str(model.get("memorable_reason", "Run review ready"))
	return revisit_reason

static func _format_run_review_progress_line(model: Dictionary) -> String:
	if bool(model.get("interrupted", false)):
		return "Interrupted run | No progression"
	return "XP +%d | Mastery +%d | Reward %s" % [
		int(model.get("xp_gain", 0)),
		int(model.get("mastery_gain", 0)),
		str(model.get("reward_band", "None"))
	]

static func _curate_recent_run_slots(history: Array) -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	if history.is_empty():
		return slots
	var used_keys: Dictionary = {}
	for slot_rule in [
		{"label": "Latest", "mode": "latest"},
		{"label": "Most dramatic", "mode": "dramatic"},
		{"label": "Most rewarding", "mode": "rewarding"},
		{"label": "Best interruption review", "mode": "interrupted"}
	]:
		var model := _select_curated_history_model(history, str(slot_rule.get("mode", "")), used_keys)
		if not model.is_empty():
			slots.append({
				"label": str(slot_rule.get("label", "")),
				"model": model
			})
			used_keys[str(model.get("key", ""))] = true
	var communication_model := _select_curated_history_model(history, "communication", used_keys)
	if not communication_model.is_empty() and _communication_slot_earns_inclusion(communication_model):
		slots.append({
			"label": "Most callout-heavy",
			"model": communication_model
		})
	return slots

static func _build_revisit_cluster_bits(history: Array) -> Array[String]:
	var decorated: Array[Dictionary] = []
	for canonical_index in range(history.size()):
		var model := _build_run_review_model(Dictionary(history[canonical_index]))
		decorated.append({
			"model": model,
			"index": canonical_index,
			"score": _revisit_cluster_score(model, canonical_index)
		})
	decorated.sort_custom(_revisit_cluster_less)
	var bits: Array[String] = []
	for item_variant in decorated:
		var item: Dictionary = Dictionary(item_variant)
		var model: Dictionary = Dictionary(item.get("model", {}))
		var revisit_rank := _revisit_band_rank(str(model.get("revisit_band", "Low")))
		if revisit_rank <= 0:
			continue
		bits.append("S%d %s" % [int(model.get("seed", 0)), str(model.get("revisit_band", "Low"))])
		if bits.size() >= 2:
			break
	return bits

static func _build_strongest_cluster_bits(history: Array) -> Array[String]:
	var decorated: Array[Dictionary] = []
	for canonical_index in range(history.size()):
		var model := _build_run_review_model(Dictionary(history[canonical_index]))
		decorated.append({
			"model": model,
			"index": canonical_index,
			"score": _strongest_cluster_score(model, canonical_index)
		})
	decorated.sort_custom(_strongest_cluster_less)
	var bits: Array[String] = []
	for item_variant in decorated:
		var item: Dictionary = Dictionary(item_variant)
		var model: Dictionary = Dictionary(item.get("model", {}))
		var summary := "S%d %s/%s/%s" % [
			int(model.get("seed", 0)),
			str(model.get("reward_band", "None")),
			str(model.get("dramatic_band", "Steady")),
			str(model.get("communication_band", "Quiet"))
		]
		bits.append(summary)
		if bits.size() >= 3:
			break
	return bits

static func _strongest_cluster_score(model: Dictionary, canonical_index: int) -> int:
	return int(model.get("revisit_score", 0)) * 25 + int(model.get("reward_rank", 0)) * 20 + int(model.get("communication_rank", 0)) * 10 + int(model.get("dramatic_rank", 0)) * 5 - canonical_index

static func _strongest_cluster_less(a: Dictionary, b: Dictionary) -> bool:
	var a_score := int(a.get("score", 0))
	var b_score := int(b.get("score", 0))
	if a_score == b_score:
		return int(a.get("index", 0)) < int(b.get("index", 0))
	return a_score > b_score

static func _revisit_cluster_score(model: Dictionary, canonical_index: int) -> int:
	return int(model.get("revisit_score", 0)) * 20 + _revisit_band_rank(str(model.get("revisit_band", "Low"))) * 50 + int(model.get("communication_rank", 0)) * 10 + int(model.get("dramatic_rank", 0)) * 5 - canonical_index

static func _revisit_band_rank(revisit_band: String) -> int:
	match revisit_band:
		"High":
			return 3
		"Medium":
			return 2
		"Low":
			return 1
		_:
			return 0

static func _revisit_cluster_less(a: Dictionary, b: Dictionary) -> bool:
	var a_score := int(a.get("score", 0))
	var b_score := int(b.get("score", 0))
	if a_score == b_score:
		return int(a.get("index", 0)) < int(b.get("index", 0))
	return a_score > b_score

static func _select_curated_history_model(history: Array, mode: String, used_keys: Dictionary) -> Dictionary:
	var best_model: Dictionary = {}
	var best_score := -2147483648
	for i in range(history.size()):
		var entry: Dictionary = Dictionary(history[i])
		var model := _build_run_review_model(entry)
		if used_keys.has(str(model.get("key", ""))):
			continue
		var score := _curated_history_score(entry, model, mode, i)
		if score > best_score:
			best_score = score
			best_model = model
	return best_model if best_score > -2147483648 else {}

static func _curated_history_score(entry: Dictionary, model: Dictionary, mode: String, canonical_index: int) -> int:
	match mode:
		"latest":
			return 100000 - canonical_index
		"dramatic":
			if bool(entry.get("interrupted", false)):
				return -2147483648
			return int(Dictionary(model.get("diagnostics", {})).get("story_density", 0)) * 4 + int(model.get("dramatic_rank", 0)) * 25 - canonical_index
		"rewarding":
			return _reward_significance_rank(entry) * 100 + int(entry.get("xp_gain", 0)) + int(entry.get("mastery_gain", 0)) - canonical_index
		"communication":
			return int(model.get("communication_rank", 0)) * 100 + int(Dictionary(model.get("diagnostics", {})).get("communication_beats", 0)) * 10 - canonical_index
		"interrupted":
			if not bool(entry.get("interrupted", false)):
				return -2147483648
			return 1000 + int(model.get("communication_rank", 0)) * 20 + int(Dictionary(model.get("diagnostics", {})).get("communication_beats", 0)) - canonical_index
		_:
			return -canonical_index

static func _sort_history_context(history: Array, sort_mode: String) -> Array[Dictionary]:
	if sort_mode == "RECENT":
		var recent: Array[Dictionary] = []
		for i in range(history.size()):
			recent.append({
				"entry": Dictionary(history[i]),
				"index": i,
				"score": 0
			})
		return recent
	var decorated: Array[Dictionary] = []
	for i in range(history.size()):
		var entry: Dictionary = Dictionary(history[i])
		decorated.append({
			"entry": entry,
			"index": i,
			"score": _history_sort_score(entry, sort_mode)
		})
	decorated.sort_custom(_history_decorated_less)
	return decorated

static func _history_sort_score(entry: Dictionary, sort_mode: String) -> int:
	var diagnostics: Dictionary = Dictionary(entry.get("diagnostics", {}))
	match sort_mode:
		"DRAMATIC":
			return int(diagnostics.get("story_density", 0)) * 5 + RUN_STORY_DIAGNOSTICS_SCRIPT.dramatic_intensity_rank(diagnostics) * 30
		"REWARDING":
			return _reward_significance_rank(entry) * 100 + int(entry.get("xp_gain", 0)) + int(entry.get("mastery_gain", 0))
		"CALLOUT_HEAVY":
			return RUN_STORY_DIAGNOSTICS_SCRIPT.communication_density_rank(diagnostics) * 50 + int(diagnostics.get("communication_beats", 0)) * 10
		"INTERRUPTED_FIRST":
			return (1000 if bool(entry.get("interrupted", false)) else 0) + int(diagnostics.get("story_density", 0))
		_:
			return 0

static func _history_decorated_less(a: Dictionary, b: Dictionary) -> bool:
	var a_score := int(a.get("score", 0))
	var b_score := int(b.get("score", 0))
	if a_score == b_score:
		return int(a.get("index", 0)) < int(b.get("index", 0))
	return a_score > b_score

static func _compare_rank_line(label: String, selected_rank: int, peer_rank: int) -> String:
	if selected_rank == peer_rank:
		return "%s matched" % label.capitalize()
	return "%s %s" % ["More" if selected_rank > peer_rank else "Less", label]

static func _compare_completion_line(selected_interrupted: bool, peer_interrupted: bool) -> String:
	if selected_interrupted == peer_interrupted:
		return "Same completion state"
	return "Interrupted vs completed" if selected_interrupted else "Completed vs interrupted"

static func _describe_history_standout(models: Array[Dictionary], selected_index: int, compare_index: int) -> String:
	if selected_index < 0 or selected_index >= models.size():
		return "Run review ready"
	var selected: Dictionary = models[selected_index]
	var best_reward_index := -1
	var best_reward_rank := -1
	var best_callout_index := -1
	var best_callout_rank := -1
	for i in range(models.size()):
		var model: Dictionary = models[i]
		var reward_rank := int(model.get("reward_rank", 0))
		if reward_rank > best_reward_rank:
			best_reward_rank = reward_rank
			best_reward_index = i
		var callout_rank := int(model.get("communication_rank", 0))
		if callout_rank > best_callout_rank:
			best_callout_rank = callout_rank
			best_callout_index = i
	if bool(selected.get("interrupted", false)):
		return "Best interruption review in this context"
	if selected_index == best_reward_index and best_reward_rank > 0:
		return "Most rewarding run in this context"
	if selected_index == best_callout_index and best_callout_rank > 0:
		return "Most callout-heavy run in this view"
	return str(selected.get("standout_reason", "Run review ready"))

static func _format_recent_run_strip_line(label: String, model: Dictionary) -> String:
	return "%s: Seed %d | %s" % [
		label,
		int(model.get("seed", 0)),
		_format_recent_run_home_snippet(model)
	]

static func _format_cluster_snippet(model: Dictionary) -> String:
	var diagnostics: Dictionary = Dictionary(model.get("diagnostics", {}))
	return "%s | %s | %s revisit" % [
		RUN_STORY_DIAGNOSTICS_SCRIPT.build_run_cluster_label(diagnostics),
		str(model.get("standout_reason", "Run review ready")),
		str(model.get("revisit_band", "Low"))
	]

static func _communication_slot_earns_inclusion(model: Dictionary) -> bool:
	return int(model.get("communication_rank", 0)) >= 2 or int(Dictionary(model.get("diagnostics", {})).get("communication_beats", 0)) >= 3

static func _build_home_momentum_line(profile: Dictionary, catalog: Dictionary) -> String:
	var last_run: Dictionary = Dictionary(profile.get("last_run", {}))
	if last_run.is_empty():
		return next_cosmetic_unlock_text(profile, catalog)
	var model := _build_run_review_model(last_run)
	if bool(model.get("interrupted", false)):
		return "reopen S%d before regrouping" % int(model.get("seed", 0))
	var unlocked_cosmetics: Array = Array(last_run.get("unlocked_cosmetics", []))
	if not unlocked_cosmetics.is_empty():
		return "unlocked %s" % _display_name_for_cosmetic(str(unlocked_cosmetics[0]), catalog)
	var unlocked_achievements: Array = Array(last_run.get("unlocked_achievements", []))
	if not unlocked_achievements.is_empty():
		var achievement := PRODUCT_CATALOG_SCRIPT.get_achievement(str(unlocked_achievements[0]), catalog)
		return "milestone %s" % str(achievement.get("display_name", unlocked_achievements[0]))
	if int(model.get("reward_rank", 0)) >= 2:
		return "S%d paid %s progression" % [int(model.get("seed", 0)), str(model.get("reward_band", "Light")).to_lower()]
	return str(model.get("standout_reason", "run story ready")).to_lower()

static func _build_party_continuity_line(profile: Dictionary, session_overview: Dictionary) -> String:
	var last_run: Dictionary = Dictionary(profile.get("last_run", {}))
	if bool(session_overview.get("reconnect_available", false)):
		return "continue with the current lobby now"
	if bool(session_overview.get("reconnect_wait_for_lobby", false)):
		return "wait for the host lobby, then rejoin"
	if bool(session_overview.get("connected", false)):
		return "continue with the current lobby"
	if bool(last_run.get("interrupted", false)):
		return "review now, then regroup and rejoin later"
	return "host or join the next lobby"

static func _format_recent_run_home_snippet(model: Dictionary) -> String:
	return "%s | %s revisit" % [
		str(model.get("standout_reason", "Run review ready")),
		str(model.get("revisit_band", "Low"))
	]

static func _describe_selected_contrast_reason(selected: Dictionary, peer: Dictionary) -> String:
	if bool(selected.get("interrupted", false)) != bool(peer.get("interrupted", false)):
		return "the interruption context matters more here"
	if int(selected.get("reward_rank", 0)) != int(peer.get("reward_rank", 0)):
		return "the reward signal is stronger here"
	if int(selected.get("communication_rank", 0)) != int(peer.get("communication_rank", 0)):
		return "the callout density changes the read"
	if int(selected.get("dramatic_rank", 0)) != int(peer.get("dramatic_rank", 0)):
		return "the dramatic swing is sharper here"
	return "it is the clearer run to reopen"

static func _build_compare_action_reason(models: Array[Dictionary], selected_index: int, compare_index: int) -> String:
	if selected_index < 0 or selected_index >= models.size():
		return "it is the clearest run to reopen in this view"
	var selected: Dictionary = models[selected_index]
	if compare_index < 0 or compare_index >= models.size():
		return "it stands out more clearly in this view"
	var peer: Dictionary = models[compare_index]
	var primary_dimension := ""
	var difference_dimensions := _build_compare_difference_dimensions(selected, peer)
	if not difference_dimensions.is_empty():
		primary_dimension = difference_dimensions[0]
	var secondary_reason := _build_compare_secondary_reason(selected, peer, primary_dimension)
	if not secondary_reason.is_empty():
		return secondary_reason
	return _build_contextual_reopen_reason(selected, peer)

static func _build_compare_secondary_reason(selected: Dictionary, peer: Dictionary, primary_dimension: String) -> String:
	var difference_dimensions := _build_compare_difference_dimensions(selected, peer)
	for dimension in difference_dimensions:
		if dimension == primary_dimension:
			continue
		match dimension:
			"reward":
				if int(selected.get("reward_rank", 0)) > int(peer.get("reward_rank", 0)):
					return "it keeps the stronger progression result in this view"
			"communication":
				if int(selected.get("communication_rank", 0)) > int(peer.get("communication_rank", 0)):
					return "its callout density is heavier in this view"
			"dramatic":
				if int(selected.get("dramatic_rank", 0)) > int(peer.get("dramatic_rank", 0)):
					return "its pressure swing is sharper in this view"
			"interruption":
				if bool(selected.get("interrupted", false)):
					return "it is the clearest interruption review in this view"
	return ""

static func _build_contextual_reopen_reason(selected: Dictionary, peer: Dictionary) -> String:
	var selected_reason := str(selected.get("standout_reason", "Run review ready")).to_lower()
	var peer_reason := str(peer.get("standout_reason", "")).to_lower()
	if selected_reason != "" and selected_reason != peer_reason:
		match selected_reason:
			"best interruption review":
				return "it is the clearest interruption review in this view"
			"strong reward run":
				return "it is the strongest reward run in this view"
			"communication-heavy run":
				return "it carries the heavier callout picture in this view"
			"dramatic run":
				return "it carries the sharper dramatic swing in this view"
			_:
				return "its review signal is clearer in this view"
	return "it is the clearer run to reopen in this view"

static func _title_case(text: String) -> String:
	return text.strip_edges().replace("_", " ").capitalize()

static func _unlock_achievements(profile: Dictionary, run_record: Dictionary, catalog: Dictionary) -> Array[String]:
	var achievements_state: Dictionary = Dictionary(profile.get("achievements", {}))
	var unlocked: Array[String] = _to_string_array(achievements_state.get("unlocked", []))
	var newly_unlocked: Array[String] = []
	var account: Dictionary = Dictionary(profile.get("account", {}))
	var mastery: Dictionary = Dictionary(profile.get("mastery", {}))
	var discoveries: Dictionary = Dictionary(profile.get("discoveries", {}))
	for achievement in PRODUCT_CATALOG_SCRIPT.achievement_entries(catalog):
		var achievement_id := str(achievement.get("id", ""))
		if achievement_id.is_empty() or unlocked.has(achievement_id):
			continue
		var rule: Dictionary = achievement.get("rule", {})
		var unlocked_now := false
		match str(rule.get("type", "")):
			"runs":
				unlocked_now = int(account.get("runs", 0)) >= int(rule.get("count", 1))
			"expedition_wins":
				unlocked_now = int(account.get("expedition_wins", 0)) >= int(rule.get("count", 1))
			"sabotage_wins":
				unlocked_now = int(account.get("sabotage_wins", 0)) >= int(rule.get("count", 1))
			"account_level":
				unlocked_now = int(account.get("level", 1)) >= int(rule.get("level", 1))
			"role_level":
				var role_name := str(rule.get("role", ""))
				var role_track: Dictionary = Dictionary(mastery.get(role_name, {}))
				unlocked_now = int(role_track.get("level", 1)) >= int(rule.get("level", 1))
			"discoveries":
				var section := str(rule.get("section", ""))
				unlocked_now = Array(discoveries.get(section, [])).size() >= int(rule.get("count", 1))
		if unlocked_now:
			unlocked.append(achievement_id)
			newly_unlocked.append(achievement_id)
	unlocked.sort()
	achievements_state["unlocked"] = unlocked
	achievements_state["last_unlocked"] = newly_unlocked.duplicate()
	profile["achievements"] = achievements_state
	return newly_unlocked

static func _build_reward_breakdown(run_record: Dictionary, rewards: Dictionary) -> Array[String]:
	var stats: Dictionary = Dictionary(run_record.get("stats", {}))
	var lines: Array[String] = []
	lines.append("Base run: 100 XP")
	if bool(run_record.get("role_result_success", false)):
		lines.append("Role goal completed: +40 XP")
	else:
		lines.append("Run survived to recap: +10 XP")
	if int(stats.get("notes_count", 0)) > 0:
		lines.append("Notes logged: +%d XP" % mini(int(stats.get("notes_count", 0)) * 5, 20))
	if int(stats.get("inspections_count", 0)) > 0:
		lines.append("Inspections: +%d XP" % mini(int(stats.get("inspections_count", 0)) * 8, 24))
	if bool(stats.get("extraction_completed", false)):
		lines.append("Extraction completed: +20 XP")
	lines.append("Role mastery: +%d XP" % int(rewards.get("mastery_xp", 0)))
	return lines

static func next_track_preview(track_id: String, xp: int, catalog: Dictionary = {}) -> String:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var track := PRODUCT_CATALOG_SCRIPT.get_mastery_track(track_id, current_catalog)
	var levels: Array = track.get("levels", [])
	for threshold_variant in levels:
		var threshold := int(threshold_variant)
		if threshold > xp:
			return "%d XP to Lv.%d" % [threshold - xp, level_for_track_xp(track_id, xp, current_catalog) + 1]
	return "Track complete"

static func next_cosmetic_unlock_text(profile: Dictionary, catalog: Dictionary = {}) -> String:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var owned: Array = Dictionary(current.get("cosmetics", {})).get("owned", [])
	var account_level := int(Dictionary(current.get("account", {})).get("level", 1))
	var mastery: Dictionary = Dictionary(current.get("mastery", {}))
	for cosmetic in PRODUCT_CATALOG_SCRIPT.get_cosmetics("", current_catalog):
		var cosmetic_id := str(cosmetic.get("id", ""))
		if owned.has(cosmetic_id):
			continue
		var source: Dictionary = cosmetic.get("source", {})
		match str(source.get("type", "")):
			"account_level":
				return "%s at account Lv.%d" % [str(cosmetic.get("display_name", cosmetic_id)), int(source.get("level", 1))]
			"role_mastery":
				var role_name := str(source.get("role", ""))
				var target_level := int(source.get("level", 1))
				var role_track: Dictionary = Dictionary(mastery.get(role_name, {}))
				if int(role_track.get("level", 1)) < target_level:
					return "%s at %s mastery Lv.%d" % [str(cosmetic.get("display_name", cosmetic_id)), role_name, target_level]
	return "All current cosmetics unlocked"

static func _describe_voice_mode(mode: String) -> String:
	match mode:
		"push_to_talk":
			return "Push-to-talk"
		"open_mic":
			return "Open mic"
		_:
			return "Off"

static func _build_catalog_section_entries(catalog: Dictionary, section: String, discovered_ids: Array) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry in PRODUCT_CATALOG_SCRIPT.codex_entries(section, catalog):
		var entry_id := str(entry.get("id", ""))
		var discovered := discovered_ids.has(entry_id)
		entries.append({
			"id": entry_id,
			"label": "%s %s" % ["[Seen]" if discovered else "[Unknown]", str(entry.get("display_name", ""))],
			"detail": "%s\n%s" % [str(entry.get("display_name", "")), str(entry.get("description", ""))],
			"discovered": discovered
		})
	return entries

static func _new_string_entries(previous: Array, current: Array) -> Array[String]:
	var result: Array[String] = []
	for value in current:
		var text := str(value)
		if not previous.has(text) and not result.has(text):
			result.append(text)
	result.sort()
	return result

static func _unlock_progression_cosmetics(profile: Dictionary, catalog: Dictionary) -> void:
	var cosmetics: Dictionary = Dictionary(profile.get("cosmetics", {}))
	var owned: Array[String] = _to_string_array(cosmetics.get("owned", []))
	var account_level := int(Dictionary(profile.get("account", {})).get("level", 1))
	var mastery: Dictionary = profile.get("mastery", {})
	for cosmetic in PRODUCT_CATALOG_SCRIPT.get_cosmetics("", catalog):
		var cosmetic_id := str(cosmetic.get("id", ""))
		var source: Dictionary = cosmetic.get("source", {})
		var source_type := str(source.get("type", ""))
		var unlocked := source_type == "starter"
		if source_type == "account_level":
			unlocked = account_level >= int(source.get("level", 1))
		elif source_type == "role_mastery":
			var role_name := str(source.get("role", ""))
			var required_level := int(source.get("level", 1))
			var role_track: Dictionary = Dictionary(mastery.get(role_name, {}))
			unlocked = int(role_track.get("level", 1)) >= required_level
		if unlocked and not owned.has(cosmetic_id):
			owned.append(cosmetic_id)
	owned.sort()
	cosmetics["owned"] = owned
	profile["cosmetics"] = cosmetics

static func _display_name_for_cosmetic(cosmetic_id: String, catalog: Dictionary = {}) -> String:
	if cosmetic_id.is_empty():
		return "-"
	var cosmetic := PRODUCT_CATALOG_SCRIPT.get_cosmetic(cosmetic_id, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	return str(cosmetic.get("display_name", cosmetic_id))

static func _public_legend_hint(profile: Dictionary) -> String:
	var persona: Dictionary = Dictionary(profile.get("persona_state", {}))
	var scores: Dictionary = Dictionary(persona.get("archetype_scores", {}))
	var best_key := ""
	var best_score := -1
	for key in scores.keys():
		var score := int(scores.get(key, 0))
		if score > best_score:
			best_score = score
			best_key = str(key)
	if best_key.is_empty():
		return "Delver"
	return _title_case(best_key.replace("_", " "))

static func _public_challenge_hint(profile: Dictionary) -> String:
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var pressure := str(active_crawl.get("expectation_pressure", "")).strip_edges()
	if not pressure.is_empty():
		return pressure
	var persona: Dictionary = Dictionary(profile.get("persona_state", {}))
	return _first_string(Array(persona.get("public_expectations", [])), "")

static func _public_crew_tag(profile: Dictionary) -> String:
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var crews: Dictionary = Dictionary(fabric.get("crews", {}))
	var recent_crews := _to_string_array(fabric.get("recent_crews", []))
	if recent_crews.is_empty():
		return ""
	var entry: Dictionary = Dictionary(crews.get(recent_crews[0], {}))
	return str(entry.get("title", "")).strip_edges()

static func _build_relationship_preview_lines(profile: Dictionary) -> Array[String]:
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var players: Dictionary = Dictionary(fabric.get("players", {}))
	var pairs: Dictionary = Dictionary(fabric.get("pairs", {}))
	var crews: Dictionary = Dictionary(fabric.get("crews", {}))
	var recent_players := _to_string_array(players.keys())
	recent_players.sort()
	var recent_pairs := _to_string_array(fabric.get("recent_pairs", []))
	var recent_crews := _to_string_array(fabric.get("recent_crews", []))
	var lines: Array[String] = []
	if not recent_players.is_empty():
		var player_entry: Dictionary = Dictionary(players.get(recent_players[0], {}))
		var player_line := "Delver echo: %s" % str(player_entry.get("title", "Remembered delver"))
		var player_expectation := _first_string(Array(player_entry.get("obligations", [])), "")
		if not player_expectation.is_empty():
			player_line += " | %s" % player_expectation
		lines.append(player_line)
	if not recent_pairs.is_empty():
		var pair: Dictionary = Dictionary(pairs.get(recent_pairs[0], {}))
		var pair_line := "Pair echo: %s" % str(pair.get("title", "Recurring pair"))
		var obligation := _first_string(Array(pair.get("obligations", [])), "")
		if not obligation.is_empty():
			pair_line += " | %s" % obligation
		var status_burden := str(pair.get("status_burden", "")).strip_edges()
		if not status_burden.is_empty():
			pair_line += " | %s" % status_burden
		lines.append(pair_line)
	if not recent_crews.is_empty():
		var crew: Dictionary = Dictionary(crews.get(recent_crews[0], {}))
		var crew_line := "Crew echo: %s" % str(crew.get("title", "Recurring crew"))
		var burden := str(crew.get("status_burden", "")).strip_edges()
		if not burden.is_empty():
			crew_line += " | %s" % burden
		var obligation := _first_string(Array(crew.get("obligations", [])), "")
		if not obligation.is_empty():
			crew_line += " | %s" % obligation
		lines.append(crew_line)
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func _build_narrative_progress_lines(profile: Dictionary) -> Array[String]:
	var progress: Dictionary = Dictionary(profile.get("narrative_progress", {}))
	var archive_state: Dictionary = Dictionary(profile.get("archive_state", {}))
	var world_memory: Dictionary = Dictionary(profile.get("world_memory", {}))
	var layer := str(progress.get("layer", "public"))
	var flags := _to_string_array(progress.get("post_core_flags", []))
	var lines: Array[String] = []
	match layer:
		"patterned":
			lines.append("Archive depth: pressure patterns are beginning to line up.")
		"deepening":
			lines.append("Archive depth: later echoes are getting stranger.")
		"post_core":
			lines.append("Archive depth: old patterns are starting to answer each other.")
		_:
			lines.append("Archive depth: public records only.")
	if flags.has("echo_strain"):
		lines.append("Recent runs are carrying stronger echo strain.")
	elif flags.has("ritual_return"):
		lines.append("Some pressures are starting to feel ritualized.")
	if flags.has("attention_lock"):
		lines.append("The same challenge keeps drawing the world back.")
	if flags.has("counterweight"):
		lines.append("Older readings are starting to compete with the obvious story.")
	if flags.has("deep_archive"):
		lines.append("Archive echoes are starting to talk to each other.")
	if flags.has("gravity_lock"):
		lines.append("One pressure has started pulling the whole field toward it.")
	if flags.has("recast_pressure"):
		lines.append("Recent reversals are forcing older legends to answer for themselves.")
	if Array(archive_state.get("legends", [])).size() >= 4:
		lines.append("Legend pressure: enough dense cases now point to the same returning shapes.")
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	if str(fascination.get("phase", "")).strip_edges() == "turning":
		lines.append("World attention: the current pressure is displacing an older obsession.")
	return FRAMING_SERVICE_SCRIPT.guard_lines(lines)

static func _advance_narrative_progress(progress: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary, crawl_packet: Dictionary, world_memory: Dictionary, archive_state: Dictionary) -> Dictionary:
	var next := {
		"layer": "public",
		"core_reached": false,
		"post_core_flags": []
	}
	for key in progress.keys():
		next[key] = progress[key]
	var layer := str(next.get("layer", "public"))
	var flags := _to_string_array(next.get("post_core_flags", []))
	var legends := Array(archive_state.get("legends", []))
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	var heat := int(fascination.get("current_heat", 0))
	if layer == "public" and (Array(crawl_packet.get("turning_points", [])).size() >= 2 or legends.size() >= 2 or heat >= 6):
		layer = "patterned"
	if layer == "patterned" and (Array(crawl_packet.get("breaking_points", [])).size() >= 2 or legends.size() >= 3 or heat >= 7):
		layer = "deepening"
	if layer == "deepening" and (bool(next.get("core_reached", false)) or legends.size() >= 4 or Array(crawl_packet.get("breaking_points", [])).size() >= 3):
		layer = "post_core"
		next["core_reached"] = true
	if str(frame.get("delve_trace", "")).strip_edges() != "" and not flags.has("echo_strain"):
		flags.append("echo_strain")
	if Array(diagnostics.get("within_run_echoes", [])).size() >= 2 and not flags.has("ritual_return"):
		flags.append("ritual_return")
	if int(diagnostics.get("expectation_break_score", 0)) >= 2 and not flags.has("pattern_slip"):
		flags.append("pattern_slip")
	if int(fascination.get("streak", 0)) >= 3 and not flags.has("attention_lock"):
		flags.append("attention_lock")
	if Array(frame.get("counter_readings", [])).size() >= 2 and not flags.has("counterweight"):
		flags.append("counterweight")
	if Dictionary(archive_state.get("shorthand", {})).size() >= 2 and not flags.has("deep_archive"):
		flags.append("deep_archive")
	if int(fascination.get("streak", 0)) >= 4 and not flags.has("gravity_lock"):
		flags.append("gravity_lock")
	if str(fascination.get("phase", "")).strip_edges() == "turning" and not flags.has("recast_pressure"):
		flags.append("recast_pressure")
	next["layer"] = layer
	next["post_core_flags"] = flags.slice(0, 8)
	return next

static func _first_string(values: Array, fallback: String) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _normalize_cookbook_state(state: Dictionary) -> Dictionary:
	return COOKBOOK_FRAGMENT_SERVICE_SCRIPT.normalize(state)

static func _advance_cookbook_state(current_state: Dictionary, profile: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary) -> Dictionary:
	var next := _normalize_cookbook_state(current_state)
	var progress: Dictionary = Dictionary(profile.get("narrative_progress", {}))
	var archive_state: Dictionary = Dictionary(profile.get("archive_state", {}))
	var stats: Dictionary = Dictionary(run_record.get("stats", {}))
	var anomaly: Dictionary = Dictionary(diagnostics.get("anomaly_sensitivity", {}))
	var anomaly_signals := _to_string_array(anomaly.get("signals", []))
	var feature_scores: Dictionary = Dictionary(diagnostics.get("gameplay_feature_scores", {}))
	var counter_readings := _to_string_array(frame.get("counter_readings", []))
	var school_tension := str(frame.get("school_tension", "")).strip_edges()
	var counterfactual_line := str(frame.get("counterfactual_line", "")).strip_edges()
	var anomaly_pull := str(frame.get("anomaly_pull", "")).strip_edges()
	var delve_trace := str(frame.get("delve_trace", "")).strip_edges()
	var build_identity := str(diagnostics.get("build_identity", "")).strip_edges()
	var anomaly_score := int(anomaly.get("score", 0))
	var anomaly_curiosity := int(feature_scores.get("anomaly_curiosity", 0))
	var notes_count := int(stats.get("notes_count", 0))
	var pinned_count := int(stats.get("pinned_count", 0))
	var fragment_gain := 0
	var post_public := str(progress.get("layer", "public")) != "public" or bool(progress.get("core_reached", false))
	if anomaly_score >= 3 or anomaly_curiosity >= 4 or build_identity == "Anomaly build":
		fragment_gain += 1
	if (not anomaly_pull.is_empty() or not counterfactual_line.is_empty() or not delve_trace.is_empty()) and (post_public or Array(archive_state.get("legends", [])).size() >= 2):
		fragment_gain += 1
	if (notes_count + pinned_count) >= 2 and (counter_readings.size() >= 2 or not school_tension.is_empty()):
		fragment_gain += 1
	if fragment_gain >= 1:
		next["fragment_count"] = mini(int(next.get("fragment_count", 0)) + mini(fragment_gain, 2), 12)
		var fragment_line := _first_string(anomaly_signals, anomaly_pull)
		if fragment_line.is_empty():
			fragment_line = _first_string(counter_readings, counterfactual_line)
		if fragment_line.is_empty():
			fragment_line = "forbidden marginalia keep collecting around anomalous runs"
		next["fragment_lines"] = _merge_limited_strings(Array(next.get("fragment_lines", [])), [fragment_line], 6)
		var marginal_line := ""
		if not counter_readings.is_empty():
			marginal_line = "private notes keep returning to %s" % counter_readings[0].to_lower()
		elif not counterfactual_line.is_empty():
			marginal_line = "private revisions keep orbiting %s" % counterfactual_line.to_lower()
		elif not school_tension.is_empty():
			marginal_line = "private revisions keep circling what official readings cannot settle"
		elif not anomaly_pull.is_empty():
			marginal_line = "marginal notes keep following %s" % anomaly_pull.to_lower()
		if not marginal_line.is_empty():
			next["marginalia_lines"] = _merge_limited_strings(Array(next.get("marginalia_lines", [])), [marginal_line], 6)
	if int(next.get("fragment_count", 0)) >= 2 and ((notes_count >= 1 and counter_readings.size() >= 2) or (anomaly_score >= 4 and post_public)):
		next["holder_depth"] = mini(int(next.get("holder_depth", 0)) + 1, 8)
		next["network_lines"] = _merge_limited_strings(
			Array(next.get("network_lines", [])),
			["scattered readers are starting to recognize the same impossible margin marks"],
			6
		)
	if int(next.get("fragment_count", 0)) >= 1 and (not counterfactual_line.is_empty() or anomaly_curiosity >= 4 or build_identity == "Anomaly build"):
		next["redirection_pressure"] = mini(int(next.get("redirection_pressure", 0)) + 1, 12)
		var redirection_line := _first_string(counter_readings, counterfactual_line)
		if redirection_line.is_empty():
			redirection_line = "some marginal readings now feel like ways around expected protocol pressure"
		next["marginalia_lines"] = _merge_limited_strings(Array(next.get("marginalia_lines", [])), [redirection_line], 6)
	if int(next.get("holder_depth", 0)) >= 1 and (counter_readings.size() >= 2 or not school_tension.is_empty() or int(next.get("redirection_pressure", 0)) >= 1):
		next["network_pressure"] = mini(int(next.get("network_pressure", 0)) + 1, 12)
		var recognition_line := _first_string(Array(next.get("network_lines", [])), "")
		if recognition_line.is_empty():
			recognition_line = "anti-Protocol recognition is starting to travel by indirection rather than open declaration"
		next["network_lines"] = _merge_limited_strings(Array(next.get("network_lines", [])), [recognition_line], 6)
	if int(next.get("holder_depth", 0)) >= 2 or (int(next.get("fragment_count", 0)) >= 4 and int(next.get("network_pressure", 0)) >= 2):
		next["holder_state"] = "holder"
	elif int(next.get("holder_depth", 0)) >= 1 or int(next.get("fragment_count", 0)) >= 2:
		next["holder_state"] = "margin_reader"
	elif int(next.get("fragment_count", 0)) >= 1:
		next["holder_state"] = "glimpsed"
	else:
		next["holder_state"] = "none"
	return COOKBOOK_FRAGMENT_SERVICE_SCRIPT.advance_state(next, run_record, frame)

static func _merge_limited_strings(existing: Array, additions: Array, limit: int) -> Array[String]:
	var result: Array[String] = _to_string_array(existing)
	for addition in additions:
		var text := str(addition).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	if result.size() > limit:
		return result.slice(0, limit)
	return result

static func _normalize_legacy_tracks(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["track_id"] = str(current.get("track_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["reputation_band"] = str(current.get("reputation_band", "measured_return")).strip_edges()
		current["continuity_scars"] = _to_string_array(current.get("continuity_scars", []))
		current["quiet_play_signals"] = _to_string_array(current.get("quiet_play_signals", []))
		current["institutional_pressure_lines"] = _to_string_array(current.get("institutional_pressure_lines", []))
		current["world_aftermath_ids"] = _to_string_array(current.get("world_aftermath_ids", []))
		current["meaningful_non_action"] = str(current.get("meaningful_non_action", "")).strip_edges()
		current["source_seed"] = int(current.get("source_seed", 0))
		if not current["track_id"].is_empty():
			result.append(current)
	return result.slice(0, 18)

static func _normalize_reentry_hooks(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["hook_id"] = str(current.get("hook_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["prompt_line"] = str(current.get("prompt_line", "")).strip_edges()
		current["reputation_band"] = str(current.get("reputation_band", "measured_return")).strip_edges()
		current["quiet_play_signals"] = _to_string_array(current.get("quiet_play_signals", []))
		current["social_safety_flags"] = _to_string_array(current.get("social_safety_flags", []))
		current["source_seed"] = int(current.get("source_seed", 0))
		if not current["hook_id"].is_empty():
			result.append(current)
	return result.slice(0, 18)

static func _merge_front_dictionary_entries(existing: Array, entry: Dictionary, key_field: String, limit: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var normalized_entry := Dictionary(entry).duplicate(true)
	var key := str(normalized_entry.get(key_field, "")).strip_edges()
	if key.is_empty():
		for value in existing:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
		return result.slice(0, limit)
	result.append(normalized_entry)
	for value in existing:
		if not (value is Dictionary):
			continue
		var current := Dictionary(value).duplicate(true)
		if str(current.get(key_field, "")).strip_edges() == key:
			continue
		result.append(current)
	return result.slice(0, limit)

static func _build_phase8_legacy_track(run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary, crawl_packet: Dictionary, world_aftermath_records: Array = []) -> Dictionary:
	var source_seed := int(run_record.get("seed", 0))
	var reputation_band := str(diagnostics.get("reputation_band", "measured_return")).strip_edges()
	var quiet_play_signals := _to_string_array(diagnostics.get("quiet_play_signals", []))
	var institutional_pressure_surface: Dictionary = Dictionary(diagnostics.get("institutional_pressure_surface", {}))
	var continuity_scars: Array[String] = _to_string_array(Dictionary(crawl_packet).get("memorial_residue", []))
	var world_aftermath_ids: Array[String] = []
	var aftermath_records := CIVILIZATION_STATE_SERVICE_SCRIPT.world_aftermath_record_entries(world_aftermath_records)
	if aftermath_records.is_empty():
		aftermath_records = CIVILIZATION_STATE_SERVICE_SCRIPT.build_world_aftermath_records({
			"run_record": run_record,
			"diagnostics": diagnostics
		})
	for aftermath_raw in aftermath_records:
		var aftermath := Dictionary(aftermath_raw)
		var aftermath_id := str(aftermath.get("aftermath_id", "")).strip_edges()
		if not aftermath_id.is_empty() and not world_aftermath_ids.has(aftermath_id):
			world_aftermath_ids.append(aftermath_id)
		for scar in _to_string_array(aftermath.get("continuity_scars", [])):
			if not continuity_scars.has(scar):
				continuity_scars.append(scar)
	var label := _first_string([
		str(frame.get("challenge_attention", "")).strip_edges(),
		str(frame.get("belief_line", "")).strip_edges(),
		str(run_record.get("local_role", "")).strip_edges()
	], "Return pressure remembered")
	return {
		"track_id": "legacy_%d" % source_seed,
		"label": label,
		"reputation_band": reputation_band,
		"continuity_scars": continuity_scars.slice(0, 6),
		"quiet_play_signals": quiet_play_signals.slice(0, 3),
		"institutional_pressure_lines": _to_string_array(institutional_pressure_surface.get("claim_lines", [])) + _to_string_array(institutional_pressure_surface.get("interpretation_lines", [])),
		"world_aftermath_ids": world_aftermath_ids.slice(0, 6),
		"meaningful_non_action": str(diagnostics.get("meaningful_non_action", "")).strip_edges(),
		"source_seed": source_seed
	}

static func _build_phase8_reentry_hook(run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary, legacy_track: Dictionary) -> Dictionary:
	var source_seed := int(run_record.get("seed", 0))
	var prompt_line := _first_string([
		str(frame.get("challenge_attention", "")).strip_edges(),
		str(frame.get("belief_line", "")).strip_edges(),
		str(diagnostics.get("meaningful_non_action", "")).strip_edges(),
		str(legacy_track.get("label", "")).strip_edges()
	], "Reopen the last run through its lingering pressure")
	return {
		"hook_id": "reentry_%d" % source_seed,
		"label": "Return through seed %d" % source_seed,
		"prompt_line": prompt_line,
		"reputation_band": str(diagnostics.get("reputation_band", "measured_return")).strip_edges(),
		"quiet_play_signals": _to_string_array(diagnostics.get("quiet_play_signals", [])).slice(0, 2),
		"social_safety_flags": _to_string_array(diagnostics.get("social_safety_flags", [])).slice(0, 4),
		"source_seed": source_seed
	}

static func _latest_legacy_track(profile: Dictionary) -> Dictionary:
	var tracks := _normalize_legacy_tracks(Array(profile.get("legacy_tracks", [])))
	return Dictionary(tracks[0]).duplicate(true) if not tracks.is_empty() else {}

static func _latest_reentry_hook(profile: Dictionary) -> Dictionary:
	var hooks := _normalize_reentry_hooks(Array(profile.get("reentry_hooks", [])))
	return Dictionary(hooks[0]).duplicate(true) if not hooks.is_empty() else {}

static func _build_phase9_forensic_bundle_header(run_record: Dictionary, world_memory_snapshot_hash: String, governance_action_snapshot: Dictionary) -> Dictionary:
	var forensic_bundle: Dictionary = Dictionary(run_record.get("forensic_bundle", {}))
	var replay_identity: Dictionary = Dictionary(run_record.get("replay_identity", {}))
	return {
		"bundle_id": str(forensic_bundle.get("bundle_id", "")).strip_edges(),
		"bundle_digest": str(forensic_bundle.get("bundle_digest", "")).strip_edges(),
		"bundle_schema_version": int(forensic_bundle.get("bundle_schema_version", 0)),
		"replay_id": str(replay_identity.get("replay_id", forensic_bundle.get("replay_id", ""))).strip_edges(),
		"world_memory_snapshot_hash": world_memory_snapshot_hash,
		"rollback_action": Dictionary(governance_action_snapshot.get("rollback_action", {})).duplicate(true),
		"quarantine_action": Dictionary(governance_action_snapshot.get("quarantine_action", {})).duplicate(true),
		"fairness_trigger_ids": _to_string_array(governance_action_snapshot.get("fairness_triggers", [])),
		"dignity_trigger_ids": _to_string_array(governance_action_snapshot.get("dignity_triggers", [])),
		"dominant_strategy_strain": Dictionary(governance_action_snapshot.get("dominant_strategy_strain", {})).duplicate(true),
		"experiment_outcomes": Dictionary(run_record.get("experiment_outcomes", {})).duplicate(true)
	}

static func _canonical_phase9_hash(value: Variant) -> String:
	return _canonical_phase9_string(value).md5_text()

static func _canonical_phase9_string(value: Variant) -> String:
	match typeof(value):
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			var key_texts: Array[String] = []
			var key_lookup: Dictionary = {}
			for key in dict.keys():
				var text := str(key)
				key_texts.append(text)
				key_lookup[text] = key
			key_texts.sort()
			var segments: Array[String] = []
			for key_text in key_texts:
				segments.append("%s:%s" % [key_text, _canonical_phase9_string(dict.get(key_lookup[key_text]))])
			return "{%s}" % ",".join(segments)
		TYPE_ARRAY:
			var segments: Array[String] = []
			for item in value:
				segments.append(_canonical_phase9_string(item))
			return "[%s]" % ",".join(segments)
		TYPE_STRING:
			return JSON.stringify(value)
		_:
			return str(value)

static func _default_public_id(display_name: String) -> String:
	return PROFILE_IDENTITY_STATE_SCRIPT.default_public_id(display_name)
