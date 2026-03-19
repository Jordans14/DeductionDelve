class_name ProductCatalog
extends RefCounted

const CATALOG_PATH := "res://config/product_catalog.json"
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const FALLBACK_CATALOG := {
	"schema_version": 2,
	"cosmetic_categories": ["title", "banner", "notebook_theme"],
	"cosmetics": [],
	"normalization_modes": ["default", "fairness_sensitive", "all_ages", "forensic_replay"],
	"modulation_equivalence_classes": [],
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
const REQUIRED_NORMALIZATION_MODES := ["default", "fairness_sensitive", "all_ages", "forensic_replay"]
const EQUIVALENCE_INVARIANT_FIELDS := [
	"timing_surface",
	"information_surface",
	"reward_surface",
	"risk_surface",
	"consequence_class",
	"fairness_impact_score"
]

static func load_catalog() -> Dictionary:
	if not FileAccess.file_exists(CATALOG_PATH):
		return FALLBACK_CATALOG.duplicate(true)
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		return FALLBACK_CATALOG.duplicate(true)
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return FALLBACK_CATALOG.duplicate(true)
	return normalize_catalog(Dictionary(parsed))

static func normalize_catalog(raw_catalog: Dictionary) -> Dictionary:
	var catalog := FALLBACK_CATALOG.duplicate(true)
	for key in raw_catalog.keys():
		catalog[key] = raw_catalog[key]
	catalog["schema_version"] = maxi(int(catalog.get("schema_version", 0)), int(FALLBACK_CATALOG.get("schema_version", 2)))
	catalog["normalization_modes"] = normalization_modes(catalog)
	var normalized_classes: Array[Dictionary] = []
	for class_raw in Array(catalog.get("modulation_equivalence_classes", [])):
		normalized_classes.append(_normalize_modulation_equivalence_class(Dictionary(class_raw)))
	catalog["modulation_equivalence_classes"] = normalized_classes
	var normalized_cosmetics: Array[Dictionary] = []
	for cosmetic_raw in Array(catalog.get("cosmetics", [])):
		normalized_cosmetics.append(_normalize_cosmetic(Dictionary(cosmetic_raw), catalog))
	catalog["cosmetics"] = normalized_cosmetics
	return catalog

static func validate_catalog(catalog: Dictionary = {}) -> Array[String]:
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
	var failures: Array[String] = []
	for key in ["schema_version", "cosmetic_categories", "cosmetics", "normalization_modes", "modulation_equivalence_classes", "mastery_tracks", "achievements", "codex", "settings_defaults"]:
		if not current.has(key):
			failures.append("catalog missing %s" % key)
	for mode in REQUIRED_NORMALIZATION_MODES:
		if not normalization_modes(current).has(mode):
			failures.append("normalization_modes missing %s" % mode)
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
		for field in ["category", "slot", "display_name", "family", "source", "acquisition_route", "fairness_contract", "normalization_behavior", "modulation_profile"]:
			if not cosmetic.has(field):
				failures.append("%s missing %s" % [cosmetic_id, field])
		if not category_ids.has(str(cosmetic.get("category", ""))):
			failures.append("%s has unknown category %s" % [cosmetic_id, str(cosmetic.get("category", ""))])
		if str(cosmetic.get("slot", "")).is_empty():
			failures.append("%s missing slot" % cosmetic_id)
		var source: Dictionary = cosmetic.get("source", {})
		if str(source.get("type", "")).is_empty():
			failures.append("%s missing source.type" % cosmetic_id)
		var fairness_contract: Dictionary = Dictionary(cosmetic.get("fairness_contract", {}))
		for key in [
			"informational_advantage_forbidden",
			"power_advantage_forbidden",
			"reward_advantage_forbidden",
			"timing_advantage_forbidden",
			"randomized_acquisition_forbidden"
		]:
			if not fairness_contract.has(key):
				failures.append("%s fairness_contract missing %s" % [cosmetic_id, key])
		var normalization_behavior: Dictionary = Dictionary(cosmetic.get("normalization_behavior", {}))
		for mode in REQUIRED_NORMALIZATION_MODES:
			if not normalization_behavior.has(mode):
				failures.append("%s normalization_behavior missing %s" % [cosmetic_id, mode])
		var modulation_profile: Dictionary = Dictionary(cosmetic.get("modulation_profile", {}))
		var equivalence_class_id := str(modulation_profile.get("equivalence_class_id", "")).strip_edges()
		if not equivalence_class_id.is_empty():
			if modulation_equivalence_class(equivalence_class_id, current).is_empty():
				failures.append("%s references unknown modulation equivalence class %s" % [cosmetic_id, equivalence_class_id])
			for invariant_key in EQUIVALENCE_INVARIANT_FIELDS:
				if not modulation_profile.has(invariant_key):
					failures.append("%s modulation_profile missing %s" % [cosmetic_id, invariant_key])
			for delta_key in ["intel_delta", "power_delta", "reward_delta", "timing_delta"]:
				if float(modulation_profile.get(delta_key, 0.0)) != 0.0:
					failures.append("%s modulation_profile.%s must stay zero under no-pay-to-win doctrine" % [cosmetic_id, delta_key])
			if float(modulation_profile.get("fairness_impact_score", 0.0)) != 0.0:
				failures.append("%s modulation_profile.fairness_impact_score must stay zero under no-pay-to-win doctrine" % cosmetic_id)
	var seen_class_ids: Dictionary = {}
	for class_raw in Array(current.get("modulation_equivalence_classes", [])):
		var class_def: Dictionary = Dictionary(class_raw)
		var class_id := str(class_def.get("id", "")).strip_edges()
		if class_id.is_empty():
			failures.append("modulation_equivalence_classes entry missing id")
			continue
		if seen_class_ids.has(class_id):
			failures.append("duplicate modulation equivalence class %s" % class_id)
		seen_class_ids[class_id] = true
		var member_ids := _string_array_from_variant(class_def.get("member_ids", []))
		if member_ids.size() < 2:
			failures.append("%s must declare at least two member_ids" % class_id)
		var canonical_member_id := str(class_def.get("canonical_member_id", "")).strip_edges()
		if canonical_member_id.is_empty() or not member_ids.has(canonical_member_id):
			failures.append("%s canonical_member_id must name one of its members" % class_id)
		for invariant_key in EQUIVALENCE_INVARIANT_FIELDS:
			if not class_def.has(invariant_key):
				failures.append("%s missing invariant %s" % [class_id, invariant_key])
		if float(class_def.get("fairness_impact_score", 0.0)) != 0.0:
			failures.append("%s fairness_impact_score must stay zero under no-pay-to-win doctrine" % class_id)
		for member_id in member_ids:
			var member_cosmetic := get_cosmetic(member_id, current)
			if member_cosmetic.is_empty():
				failures.append("%s references unknown member %s" % [class_id, member_id])
				continue
			var member_profile: Dictionary = Dictionary(member_cosmetic.get("modulation_profile", {}))
			if str(member_profile.get("equivalence_class_id", "")).strip_edges() != class_id:
				failures.append("%s member %s must point back to the same equivalence class" % [class_id, member_id])
			for invariant_key in EQUIVALENCE_INVARIANT_FIELDS:
				if _canonical_invariant_string(member_profile.get(invariant_key, null)) != _canonical_invariant_string(class_def.get(invariant_key, null)):
					failures.append("%s member %s must match invariant %s exactly" % [class_id, member_id, invariant_key])
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
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
	var result: Array[String] = []
	for category in current.get("cosmetic_categories", []):
		result.append(str(category))
	return result

static func normalization_modes(catalog: Dictionary = {}) -> Array[String]:
	var current := FALLBACK_CATALOG.duplicate(true) if catalog.is_empty() else catalog
	var modes: Array[String] = []
	for mode_variant in Array(current.get("normalization_modes", REQUIRED_NORMALIZATION_MODES)):
		var mode := str(mode_variant).strip_edges()
		if not mode.is_empty() and not modes.has(mode):
			modes.append(mode)
	for required_mode in REQUIRED_NORMALIZATION_MODES:
		if not modes.has(required_mode):
			modes.append(required_mode)
	return modes

static func normalize_normalization_mode(mode: String, catalog: Dictionary = {}) -> String:
	var normalized := mode.strip_edges().to_lower()
	return normalized if normalization_modes(catalog).has(normalized) else "default"

static func codex_sections(catalog: Dictionary = {}) -> Array[String]:
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
	var ordered := ["roles", "room_families", "item_families", "artifact_states", "clue_families"]
	var codex: Dictionary = current.get("codex", {})
	var result: Array[String] = []
	for section in ordered:
		if codex.has(section):
			result.append(section)
	return result

static func get_cosmetics(category: String = "", catalog: Dictionary = {}) -> Array[Dictionary]:
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
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
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
	return Dictionary(current.get("mastery_tracks", {})).get(track_id, {})

static func achievement_entries(catalog: Dictionary = {}) -> Array[Dictionary]:
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
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
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
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

static func modulation_equivalence_class(class_id: String, catalog: Dictionary = {}) -> Dictionary:
	var current := load_catalog() if catalog.is_empty() else catalog
	for class_raw in Array(current.get("modulation_equivalence_classes", [])):
		var class_def: Dictionary = Dictionary(class_raw)
		if str(class_def.get("id", "")).strip_edges() == class_id:
			return class_def.duplicate(true)
	return {}

static func modulation_loadout_for_equipped(equipped: Dictionary, normalization_mode: String = "default", catalog: Dictionary = {}) -> Array[Dictionary]:
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
	var normalized_mode := normalize_normalization_mode(normalization_mode, current)
	var loadout: Array[Dictionary] = []
	for slot_variant in Dictionary(equipped).keys():
		var slot := str(slot_variant)
		var cosmetic_id := str(Dictionary(equipped).get(slot_variant, "")).strip_edges()
		if cosmetic_id.is_empty():
			continue
		var equipped_cosmetic := get_cosmetic(cosmetic_id, current)
		if equipped_cosmetic.is_empty():
			continue
		var modulation_profile: Dictionary = Dictionary(equipped_cosmetic.get("modulation_profile", {}))
		var class_id := str(modulation_profile.get("equivalence_class_id", "")).strip_edges()
		if class_id.is_empty():
			continue
		var class_def := modulation_equivalence_class(class_id, current)
		if class_def.is_empty():
			continue
		var normalization_behavior := Dictionary(equipped_cosmetic.get("normalization_behavior", {}))
		var behavior := str(normalization_behavior.get(normalized_mode, normalization_behavior.get("default", "allow"))).strip_edges()
		var selected_cosmetic_id := cosmetic_id
		if behavior == "collapse_to_canonical":
			selected_cosmetic_id = str(class_def.get("canonical_member_id", cosmetic_id)).strip_edges()
		var selected_cosmetic := get_cosmetic(selected_cosmetic_id, current)
		var selected_profile: Dictionary = Dictionary(selected_cosmetic.get("modulation_profile", modulation_profile))
		loadout.append({
			"slot": slot,
			"equipped_cosmetic_id": cosmetic_id,
			"selected_cosmetic_id": selected_cosmetic_id,
			"equivalence_class_id": class_id,
			"variant_id": str(selected_profile.get("variant_id", "")),
			"allowed_axis": str(selected_profile.get("allowed_axis", "")),
			"preferred_explanation_lane": str(selected_profile.get("preferred_explanation_lane", "")),
			"summary_line": str(selected_profile.get("summary_line", "")),
			"timing_surface": str(selected_profile.get("timing_surface", "")),
			"information_surface": str(selected_profile.get("information_surface", "")),
			"reward_surface": str(selected_profile.get("reward_surface", "")),
			"risk_surface": str(selected_profile.get("risk_surface", "")),
			"consequence_class": str(selected_profile.get("consequence_class", "")),
			"fairness_impact_score": float(selected_profile.get("fairness_impact_score", 0.0)),
			"intel_delta": float(selected_profile.get("intel_delta", 0.0)),
			"power_delta": float(selected_profile.get("power_delta", 0.0)),
			"reward_delta": float(selected_profile.get("reward_delta", 0.0)),
			"timing_delta": float(selected_profile.get("timing_delta", 0.0)),
			"collapsed": selected_cosmetic_id != cosmetic_id,
			"suppressed_reason": "normalized_to_canonical" if selected_cosmetic_id != cosmetic_id else "",
			"normalization_mode": normalized_mode
		})
	loadout.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("slot", "")) < str(b.get("slot", ""))
	)
	return loadout

static func suppressed_delta_count(loadout: Array) -> int:
	var count := 0
	for entry_raw in loadout:
		if bool(Dictionary(entry_raw).get("collapsed", false)):
			count += 1
	return count

static func equivalence_class_ids_for_loadout(loadout: Array) -> Array[String]:
	var ids: Array[String] = []
	for entry_raw in loadout:
		var class_id := str(Dictionary(entry_raw).get("equivalence_class_id", "")).strip_edges()
		if not class_id.is_empty() and not ids.has(class_id):
			ids.append(class_id)
	return ids

static func build_validation_report_lines(catalog: Dictionary = {}) -> Array[String]:
	var current := load_catalog() if catalog.is_empty() else normalize_catalog(catalog)
	var failures := validate_catalog(current)
	var lines: Array[String] = []
	if failures.is_empty():
		lines.append("Catalog: OK")
	else:
		lines.append("Catalog: %d issue(s)" % failures.size())
		for failure in failures.slice(0, mini(failures.size(), 3)):
			lines.append("- %s" % failure)
	lines.append("Cosmetics: %d" % get_cosmetics("", current).size())
	lines.append("Modulation classes: %d" % Array(current.get("modulation_equivalence_classes", [])).size())
	lines.append("Achievements: %d" % achievement_entries(current).size())
	lines.append("Codex sections: %d" % codex_sections(current).size())
	lines.append("Normalization modes: %s" % " / ".join(normalization_modes(current)))
	lines.append("Voice modes: off / push_to_talk / open_mic")
	return lines

static func _normalize_cosmetic(cosmetic: Dictionary, catalog: Dictionary) -> Dictionary:
	var current := cosmetic.duplicate(true)
	var source: Dictionary = Dictionary(current.get("source", {})).duplicate(true)
	current["source"] = source
	current["acquisition_route"] = str(current.get("acquisition_route", _acquisition_route_from_source(source))).strip_edges()
	current["fairness_contract"] = _normalize_fairness_contract(Dictionary(current.get("fairness_contract", {})))
	current["normalization_behavior"] = _normalize_normalization_behavior(Dictionary(current.get("normalization_behavior", {})))
	current["modulation_profile"] = _normalize_modulation_profile(Dictionary(current.get("modulation_profile", {})), catalog)
	return current

static func _normalize_fairness_contract(contract: Dictionary) -> Dictionary:
	var current := {
		"acquisition_route": "",
		"earnable_path": true,
		"optional_paid_adjacent_allowed": false,
		"randomized_acquisition_forbidden": true,
		"informational_advantage_forbidden": true,
		"power_advantage_forbidden": true,
		"reward_advantage_forbidden": true,
		"timing_advantage_forbidden": true
	}
	for key in contract.keys():
		current[key] = contract[key]
	return current

static func _normalize_normalization_behavior(behavior: Dictionary) -> Dictionary:
	var current := {
		"default": "allow",
		"fairness_sensitive": "collapse_to_canonical",
		"all_ages": "collapse_to_canonical",
		"forensic_replay": "collapse_to_canonical"
	}
	for key in behavior.keys():
		current[str(key)] = behavior[key]
	return current

static func _normalize_modulation_profile(profile: Dictionary, catalog: Dictionary) -> Dictionary:
	var current := {
		"equivalence_class_id": "",
		"variant_id": "",
		"allowed_axis": "",
		"preferred_explanation_lane": "",
		"summary_line": "",
		"timing_surface": "",
		"information_surface": "",
		"reward_surface": "",
		"risk_surface": "",
		"consequence_class": "",
		"fairness_impact_score": 0.0,
		"intel_delta": 0.0,
		"power_delta": 0.0,
		"reward_delta": 0.0,
		"timing_delta": 0.0
	}
	for key in profile.keys():
		current[key] = profile[key]
	var class_id := str(current.get("equivalence_class_id", "")).strip_edges()
	if not class_id.is_empty():
		var class_def := modulation_equivalence_class(class_id, catalog)
		if not class_def.is_empty():
			for invariant_key in EQUIVALENCE_INVARIANT_FIELDS:
				if _canonical_invariant_string(current.get(invariant_key, null)).is_empty():
					current[invariant_key] = class_def.get(invariant_key, current.get(invariant_key))
	return current

static func _normalize_modulation_equivalence_class(class_def: Dictionary) -> Dictionary:
	var current := {
		"id": "",
		"member_ids": [],
		"canonical_member_id": "",
		"allowed_axes": [],
		"timing_surface": "",
		"information_surface": "",
		"reward_surface": "",
		"risk_surface": "",
		"consequence_class": "",
		"fairness_impact_score": 0.0
	}
	for key in class_def.keys():
		current[key] = class_def[key]
	current["member_ids"] = _string_array_from_variant(current.get("member_ids", []))
	current["allowed_axes"] = _string_array_from_variant(current.get("allowed_axes", []))
	return current

static func _acquisition_route_from_source(source: Dictionary) -> String:
	match str(source.get("type", "")):
		"starter":
			return "starter"
		"account_level":
			return "earned_account"
		"role_mastery":
			return "earned_mastery"
		"catalog_only":
			return "catalog_only"
		_:
			return "unknown"

static func _string_array_from_variant(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _canonical_invariant_string(value: Variant) -> String:
	return JSON.stringify(value)
