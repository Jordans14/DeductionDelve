class_name ProductCatalog
extends RefCounted

const CATALOG_PATH := "res://config/product_catalog.json"
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const FALLBACK_CATALOG := {
	"schema_version": 1,
	"cosmetic_categories": ["title", "banner", "notebook_theme"],
	"cosmetics": [],
	"mastery_tracks": {},
	"achievements": [],
	"codex": {
		"roles": [],
		"room_families": [],
		"item_families": [],
		"artifact_states": [],
		"clue_families": []
	},
	"settings_defaults": {
		"large_text": false,
		"hint_mode": "full",
		"controller_glyphs": false,
		"voice_mode": "off",
		"push_to_talk": true,
		"mute_voice": false
	}
}

static func load_catalog() -> Dictionary:
	if not FileAccess.file_exists(CATALOG_PATH):
		return FALLBACK_CATALOG.duplicate(true)
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		return FALLBACK_CATALOG.duplicate(true)
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return FALLBACK_CATALOG.duplicate(true)
	var catalog := FALLBACK_CATALOG.duplicate(true)
	for key in parsed.keys():
		catalog[key] = parsed[key]
	return catalog

static func validate_catalog(catalog: Dictionary = {}) -> Array[String]:
	var current := load_catalog() if catalog.is_empty() else catalog
	var failures: Array[String] = []
	for key in ["schema_version", "cosmetic_categories", "cosmetics", "mastery_tracks", "achievements", "codex", "settings_defaults"]:
		if not current.has(key):
			failures.append("catalog missing %s" % key)
	var settings_defaults: Dictionary = current.get("settings_defaults", {})
	for key in ["large_text", "hint_mode", "controller_glyphs", "voice_mode", "push_to_talk", "mute_voice"]:
		if not settings_defaults.has(key):
			failures.append("settings_defaults missing %s" % key)
	if str(settings_defaults.get("hint_mode", "")) not in ["full", "minimal"]:
		failures.append("settings_defaults.hint_mode must be full or minimal")
	if str(settings_defaults.get("voice_mode", "")) not in ["off", "push_to_talk", "open_mic"]:
		failures.append("settings_defaults.voice_mode must be off, push_to_talk, or open_mic")
	var category_ids := cosmetic_categories(current)
	var seen_categories: Dictionary = {}
	for category in category_ids:
		if seen_categories.has(category):
			failures.append("duplicate cosmetic category %s" % category)
		seen_categories[category] = true
	var seen_ids: Dictionary = {}
	for cosmetic_raw in current.get("cosmetics", []):
		var cosmetic: Dictionary = cosmetic_raw
		var cosmetic_id := str(cosmetic.get("id", ""))
		if cosmetic_id.is_empty():
			failures.append("catalog cosmetic missing id")
			continue
		if seen_ids.has(cosmetic_id):
			failures.append("duplicate cosmetic id %s" % cosmetic_id)
		seen_ids[cosmetic_id] = true
		for field in ["category", "slot", "display_name", "family", "source"]:
			if not cosmetic.has(field):
				failures.append("%s missing %s" % [cosmetic_id, field])
		if not category_ids.has(str(cosmetic.get("category", ""))):
			failures.append("%s has unknown category %s" % [cosmetic_id, str(cosmetic.get("category", ""))])
		if str(cosmetic.get("slot", "")).is_empty():
			failures.append("%s missing slot" % cosmetic_id)
		var source: Dictionary = cosmetic.get("source", {})
		if str(source.get("type", "")).is_empty():
			failures.append("%s missing source.type" % cosmetic_id)
	var mastery_tracks: Dictionary = current.get("mastery_tracks", {})
	var required_tracks: Array[String] = ["account"]
	for role_name in ROLE_SERVICE_SCRIPT.new().all_role_names():
		required_tracks.append(role_name)
	for role_name in required_tracks:
		if not mastery_tracks.has(role_name):
			failures.append("mastery_tracks missing %s" % role_name)
		else:
			var levels: Array = Dictionary(mastery_tracks.get(role_name, {})).get("levels", [])
			if levels.is_empty():
				failures.append("%s mastery track missing levels" % role_name)
			else:
				var last_level := -1
				for level_variant in levels:
					var level_value := int(level_variant)
					if level_value < last_level:
						failures.append("%s mastery levels must be ascending" % role_name)
						break
					last_level = level_value
	var seen_achievement_ids: Dictionary = {}
	for achievement_raw in current.get("achievements", []):
		var achievement: Dictionary = achievement_raw
		var achievement_id := str(achievement.get("id", ""))
		if achievement_id.is_empty():
			failures.append("catalog achievement missing id")
			continue
		if seen_achievement_ids.has(achievement_id):
			failures.append("duplicate achievement id %s" % achievement_id)
		seen_achievement_ids[achievement_id] = true
		for field in ["display_name", "description", "rule"]:
			if not achievement.has(field):
				failures.append("%s missing %s" % [achievement_id, field])
		var rule: Dictionary = achievement.get("rule", {})
		var rule_type := str(rule.get("type", ""))
		if rule_type.is_empty():
			failures.append("%s missing rule.type" % achievement_id)
		elif rule_type not in ["runs", "expedition_wins", "sabotage_wins", "account_level", "role_level", "discoveries"]:
			failures.append("%s has unsupported rule.type %s" % [achievement_id, rule_type])
		elif rule_type == "role_level" and str(rule.get("role", "")).is_empty():
			failures.append("%s missing rule.role" % achievement_id)
		elif rule_type == "discoveries" and str(rule.get("section", "")).is_empty():
			failures.append("%s missing rule.section" % achievement_id)
	var codex: Dictionary = current.get("codex", {})
	var valid_sections := codex_sections(current)
	for section in valid_sections:
		var seen_entry_ids: Dictionary = {}
		for entry_raw in codex.get(section, []):
			var entry: Dictionary = entry_raw
			var entry_id := str(entry.get("id", ""))
			if entry_id.is_empty():
				failures.append("codex.%s entry missing id" % section)
				continue
			if seen_entry_ids.has(entry_id):
				failures.append("codex.%s duplicate id %s" % [section, entry_id])
			seen_entry_ids[entry_id] = true
			for field in ["display_name", "description"]:
				if not entry.has(field):
					failures.append("codex.%s.%s missing %s" % [section, entry_id, field])
	return failures

static func cosmetic_categories(catalog: Dictionary = {}) -> Array[String]:
	var current := load_catalog() if catalog.is_empty() else catalog
	var result: Array[String] = []
	for category in current.get("cosmetic_categories", []):
		result.append(str(category))
	return result

static func codex_sections(catalog: Dictionary = {}) -> Array[String]:
	var current := load_catalog() if catalog.is_empty() else catalog
	var ordered := ["roles", "room_families", "item_families", "artifact_states", "clue_families"]
	var codex: Dictionary = current.get("codex", {})
	var result: Array[String] = []
	for section in ordered:
		if codex.has(section):
			result.append(section)
	return result

static func get_cosmetics(category: String = "", catalog: Dictionary = {}) -> Array[Dictionary]:
	var current := load_catalog() if catalog.is_empty() else catalog
	var cosmetics: Array[Dictionary] = []
	for cosmetic_raw in current.get("cosmetics", []):
		var cosmetic: Dictionary = cosmetic_raw
		if not category.is_empty() and str(cosmetic.get("category", "")) != category:
			continue
		cosmetics.append(cosmetic.duplicate(true))
	cosmetics.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("display_name", "")) < str(b.get("display_name", ""))
	)
	return cosmetics

static func get_cosmetic(cosmetic_id: String, catalog: Dictionary = {}) -> Dictionary:
	for cosmetic in get_cosmetics("", catalog):
		if str(cosmetic.get("id", "")) == cosmetic_id:
			return cosmetic
	return {}

static func starter_owned_ids(catalog: Dictionary = {}) -> Array[String]:
	var result: Array[String] = []
	for cosmetic in get_cosmetics("", catalog):
		var source: Dictionary = cosmetic.get("source", {})
		if str(source.get("type", "")) == "starter":
			result.append(str(cosmetic.get("id", "")))
	result.sort()
	return result

static func default_equipped(catalog: Dictionary = {}) -> Dictionary:
	var equipped := {}
	for cosmetic in get_cosmetics("", catalog):
		var source: Dictionary = cosmetic.get("source", {})
		if str(source.get("type", "")) != "starter":
			continue
		var slot := str(cosmetic.get("slot", ""))
		if slot.is_empty() or equipped.has(slot):
			continue
		equipped[slot] = str(cosmetic.get("id", ""))
	return equipped

static func get_mastery_track(track_id: String, catalog: Dictionary = {}) -> Dictionary:
	var current := load_catalog() if catalog.is_empty() else catalog
	return Dictionary(current.get("mastery_tracks", {})).get(track_id, {})

static func achievement_entries(catalog: Dictionary = {}) -> Array[Dictionary]:
	var current := load_catalog() if catalog.is_empty() else catalog
	var entries: Array[Dictionary] = []
	for entry_raw in current.get("achievements", []):
		entries.append(Dictionary(entry_raw).duplicate(true))
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("display_name", "")) < str(b.get("display_name", ""))
	)
	return entries

static func get_achievement(achievement_id: String, catalog: Dictionary = {}) -> Dictionary:
	for achievement in achievement_entries(catalog):
		if str(achievement.get("id", "")) == achievement_id:
			return achievement
	return {}

static func codex_entries(section: String, catalog: Dictionary = {}) -> Array[Dictionary]:
	var current := load_catalog() if catalog.is_empty() else catalog
	var codex: Dictionary = current.get("codex", {})
	var entries: Array[Dictionary] = []
	for entry_raw in codex.get(section, []):
		entries.append(Dictionary(entry_raw).duplicate(true))
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("display_name", "")) < str(b.get("display_name", ""))
	)
	return entries

static func get_notebook_theme_palette(theme_id: String, catalog: Dictionary = {}) -> Dictionary:
	var cosmetic := get_cosmetic(theme_id, catalog)
	return Dictionary(cosmetic.get("palette", {}))

static func describe_source(cosmetic: Dictionary) -> String:
	var source: Dictionary = cosmetic.get("source", {})
	match str(source.get("type", "")):
		"starter":
			return "Starter"
		"account_level":
			return "Account Lv.%d" % int(source.get("level", 1))
		"role_mastery":
			return "%s Mastery Lv.%d" % [str(source.get("role", "")), int(source.get("level", 1))]
		"catalog_only":
			return "Catalog ready"
		_:
			return "Unknown"

static func build_validation_report_lines(catalog: Dictionary = {}) -> Array[String]:
	var current := load_catalog() if catalog.is_empty() else catalog
	var failures := validate_catalog(current)
	var lines: Array[String] = []
	if failures.is_empty():
		lines.append("Catalog: OK")
	else:
		lines.append("Catalog: %d issue(s)" % failures.size())
		for failure in failures.slice(0, mini(failures.size(), 3)):
			lines.append("- %s" % failure)
	lines.append("Cosmetics: %d" % get_cosmetics("", current).size())
	lines.append("Achievements: %d" % achievement_entries(current).size())
	lines.append("Codex sections: %d" % codex_sections(current).size())
	lines.append("Voice modes: off / push_to_talk / open_mic")
	return lines
