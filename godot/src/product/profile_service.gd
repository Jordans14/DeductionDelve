class_name ProfileService
extends RefCounted

const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const RUN_STORY_DIAGNOSTICS_SCRIPT = preload("res://src/product/run_story_diagnostics.gd")

const SAVE_PATH := "user://profile/player_profile.json"
const HISTORY_LIMIT := 12

static func load_profile(path: String = SAVE_PATH, catalog: Dictionary = {}) -> Dictionary:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	if not FileAccess.file_exists(path):
		return create_default_profile(current_catalog)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return create_default_profile(current_catalog)
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return create_default_profile(current_catalog)
	return normalize_profile(parsed, current_catalog)

static func save_profile(profile: Dictionary, path: String = SAVE_PATH, catalog: Dictionary = {}) -> bool:
	var normalized := normalize_profile(profile, PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog)
	DirAccess.make_dir_recursive_absolute("user://profile")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(normalized, "\t"))
	file.close()
	return true

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
	return {
		"schema_version": 1,
		"account": {
			"display_name": "Delver",
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
		"mastery": {
			"Warden": {"xp": 0, "level": 1, "runs": 0, "wins": 0},
			"Veil": {"xp": 0, "level": 1, "runs": 0, "wins": 0},
			"Scavenger": {"xp": 0, "level": 1, "runs": 0, "wins": 0}
		},
		"discoveries": {
			"item_defs": [],
			"room_families": [],
			"artifact_states": [],
			"roles": [],
			"clue_families": []
		},
		"cosmetics": {
			"owned": PRODUCT_CATALOG_SCRIPT.starter_owned_ids(current_catalog),
			"equipped": PRODUCT_CATALOG_SCRIPT.default_equipped(current_catalog)
		},
		"achievements": {
			"unlocked": [],
			"last_unlocked": []
		},
		"settings": Dictionary(current_catalog.get("settings_defaults", {})).duplicate(true),
		"last_run": {},
		"run_history": [],
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
	normalized["run_history"] = Array(normalized.get("run_history", [])).slice(0, HISTORY_LIMIT)
	normalized["schema_version"] = 1
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

	var last_run := {
		"seed": int(run_record.get("seed", 0)),
		"end_reason": str(run_record.get("end_reason", "")),
		"local_role": local_role,
		"role_result_success": role_result_success,
		"interrupted": interrupted,
		"interruption_reason": str(run_record.get("interruption_reason", "")),
		"session_wait_for_lobby": bool(run_record.get("session_wait_for_lobby", false)),
		"session_reconnect_ready": bool(run_record.get("session_reconnect_ready", false)),
		"summary_text": str(outcome_summary.get("summary_text", "Run complete")),
		"artifact_result_text": str(outcome_summary.get("artifact_result_text", "-")),
		"report_path": str(run_record.get("report_path", "")),
		"xp_gain": int(rewards.get("account_xp", 0)),
		"mastery_gain": int(rewards.get("mastery_xp", 0)),
		"reward_breakdown": _build_reward_breakdown(run_record, rewards),
		"unlocked_cosmetics": unlocked_cosmetics.duplicate(),
		"unlocked_achievements": unlocked_achievements.duplicate(),
		"diagnostics": diagnostics.duplicate(true),
		"communication_summary": Dictionary(run_record.get("communication_summary", {})).duplicate(true),
		"key_clues": Array(run_record.get("key_clues", [])).duplicate(),
		"action_summary": Array(run_record.get("action_summary", [])).duplicate(),
		"stats_lines": Array(run_record.get("stats_lines", [])).duplicate()
	}
	next_profile["last_run"] = last_run
	next_profile["first_run_pending"] = false

	var history_entry := {
		"seed": int(run_record.get("seed", 0)),
		"summary_text": str(outcome_summary.get("summary_text", "Run complete")),
		"artifact_result_text": str(outcome_summary.get("artifact_result_text", "-")),
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
		"communication_summary": Dictionary(run_record.get("communication_summary", {})).duplicate(true),
		"key_clues": Array(run_record.get("key_clues", [])).slice(0, 3),
		"action_summary": Array(run_record.get("action_summary", [])).slice(0, 3)
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
	return [
		"Rank %d | XP %d" % [int(account.get("level", 1)), int(account.get("xp", 0))],
		"Runs: %d | Expedition wins: %d | Sabotage wins: %d" % [
			int(account.get("runs", 0)),
			int(account.get("expedition_wins", 0)),
			int(account.get("sabotage_wins", 0))
		],
		"Title: %s | Banner: %s" % [title, banner]
	]

static func build_profile_card_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var account: Dictionary = current.get("account", {})
	var equipped: Dictionary = Dictionary(Dictionary(current.get("cosmetics", {})).get("equipped", {}))
	var title := _display_name_for_cosmetic(str(equipped.get("title", "")), current_catalog)
	var banner := _display_name_for_cosmetic(str(equipped.get("banner", "")), current_catalog)
	return [
		"%s // %s" % [title, banner],
		"Expedition Rank %d" % int(account.get("level", 1)),
		"Delver history: %d runs logged" % int(account.get("runs", 0))
	]

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
	return lines

static func build_home_overview_lines(profile: Dictionary, session_overview: Dictionary = {}, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var account: Dictionary = Dictionary(current.get("account", {}))
	var lines: Array[String] = []
	lines.append("Rank %d | %d runs logged" % [int(account.get("level", 1)), int(account.get("runs", 0))])
	lines.append("Next rank: %s" % next_track_preview("account", int(account.get("xp", 0)), current_catalog))
	lines.append("Momentum: %s" % _build_home_momentum_line(current, current_catalog))
	lines.append("Continuity: %s" % _build_party_continuity_line(current, session_overview))
	return lines

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
	var lines: Array[String] = []
	lines.append("Items discovered: %d / %d" % [discovered_items.size(), item_service.ITEM_IDS.size()])
	for item_id in item_service.ITEM_IDS:
		var status := "[Seen]" if discovered_items.has(item_id) else "[Locked]"
		lines.append("%s %s" % [status, item_service.get_display_name(item_id)])
	return lines

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
			for item_id in item_service.ITEM_IDS:
				var item_def: Dictionary = item_service.get_definition(item_id)
				var discovered := Array(discoveries.get("item_defs", [])).has(item_id)
				entries.append({
					"id": item_id,
					"label": "%s %s" % ["[Seen]" if discovered else "[Locked]", item_service.get_display_name(item_id)],
					"detail": "%s\nType: %s\nArchetypes: %s\nPublic evidence: %s" % [
						item_service.get_display_name(item_id),
						str(item_def.get("category", "tool")).capitalize(),
						", ".join(item_service.get_archetypes(item_id)),
						str(item_def.get("public_evidence", "none")).replace("_", " ")
					],
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
	return entries

static func build_codex_lines(profile: Dictionary, catalog: Dictionary = {}) -> Array[String]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var discoveries: Dictionary = current.get("discoveries", {})
	var lines: Array[String] = []
	for section in ["room_families", "artifact_states", "clue_families"]:
		lines.append(section.replace("_", " ").capitalize())
		for entry in PRODUCT_CATALOG_SCRIPT.codex_entries(section, current_catalog):
			var entry_id := str(entry.get("id", ""))
			var status := "[Seen]" if Array(discoveries.get(section_to_discovery_key(section), [])).has(entry_id) else "[Unknown]"
			lines.append("%s %s" % [status, str(entry.get("display_name", ""))])
		lines.append("")
	if not lines.is_empty() and str(lines[lines.size() - 1]).is_empty():
		lines.remove_at(lines.size() - 1)
	return lines

static func build_codex_entries(profile: Dictionary, section: String, catalog: Dictionary = {}) -> Array[Dictionary]:
	var current_catalog := PRODUCT_CATALOG_SCRIPT.load_catalog() if catalog.is_empty() else catalog
	var current := normalize_profile(profile, current_catalog)
	var discovery_key := section_to_discovery_key(section)
	return _build_catalog_section_entries(current_catalog, section, Array(Dictionary(current.get("discoveries", {})).get(discovery_key, [])))

static func build_last_run_lines(profile: Dictionary) -> Array[String]:
	var current := normalize_profile(profile)
	var last_run: Dictionary = Dictionary(current.get("last_run", {}))
	if last_run.is_empty():
		return ["No runs recorded yet."]
	var model := _build_run_review_model(last_run)
	return Array(model.get("focus_packet_lines", []))

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
	return lines.slice(0, 2)

static func build_continue_guidance_lines(profile: Dictionary, session_overview: Dictionary = {}) -> Array[String]:
	var current := normalize_profile(profile)
	var last_run: Dictionary = Dictionary(current.get("last_run", {}))
	var reconnect_target := ""
	if str(session_overview.get("join_address", "")).strip_edges() != "" and int(session_overview.get("join_port", 0)) > 0:
		reconnect_target = "%s:%d" % [str(session_overview.get("join_address", "")), int(session_overview.get("join_port", 0))]
	if bool(session_overview.get("reconnect_wait_for_lobby", false)):
		return [
			"Next: wait for the host lobby, then reconnect.",
			"Why: this interrupted run can only regroup safely from lobby state.",
			"Also: reopen the interrupted run in Profile."
		]
	if bool(session_overview.get("reconnect_available", false)):
		return [
			"Next: reconnect to the current lobby%s." % [" (%s)" % reconnect_target if not reconnect_target.is_empty() else ""],
			"Why: the session is back in a reconnect-safe state.",
			"Also: reopen the last run first for a quick recap."
		]
	if bool(session_overview.get("connected", false)):
		return [
			"Next: ready up and start another run.",
			"Why: the current lobby can start another run right now.",
			"Also: reopen the strongest recent run in Profile."
		]
	if bool(last_run.get("interrupted", false)):
		return [
			"Next: regroup, then host again or rejoin later.",
			"Why: interrupted runs stay reviewable, but they do not reserve a rematch or hold the room open.",
			"Also: reopen the interrupted run in Profile."
		]
	if not last_run.is_empty():
		var next_rank := next_track_preview("account", int(Dictionary(current.get("account", {})).get("xp", 0)))
		if int(last_run.get("xp_gain", 0)) > 0 or not Array(last_run.get("unlocked_cosmetics", [])).is_empty() or not Array(last_run.get("unlocked_achievements", [])).is_empty():
			return [
				"Next: queue another run while this one is easy to compare.",
				"Why: the last run paid progression and moved the next reward closer.",
				"Also: %s" % next_rank
			]
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
		"Mute Voice: %s" % ["On" if bool(settings.get("mute_voice", false)) else "Off"]
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

static func _unlock_achievements(profile: Dictionary, run_record: Dictionary, catalog: Dictionary) -> Array[String]:
	var achievements_state: Dictionary = Dictionary(profile.get("achievements", {}))
	var unlocked: Array[String] = Array(achievements_state.get("unlocked", []))
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
	var owned: Array[String] = cosmetics.get("owned", [])
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
