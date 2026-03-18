class_name CivilizationStateService
extends RefCounted

const SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")
const MAX_OBJECTS := 24
const MAX_LINES := 6

static func default_extensions() -> Dictionary:
	return {
		"factions": [],
		"interpretation_regimes": [],
		"regions": [],
		"world_mutations": [],
		"residue_records": [],
		"literacy_tracks": [],
		"strategy_clusters": [],
		"cognitive_field_climate": {
			"field_state_id": "",
			"dominant_dimensions": [],
			"summary_lines": []
		}
	}

static func normalize_world_memory_extensions(world_memory: Dictionary) -> Dictionary:
	var current := world_memory.duplicate(true)
	for key in default_extensions().keys():
		if not current.has(key):
			current[key] = default_extensions()[key]
	current["factions"] = _normalize_factions(Array(current.get("factions", [])))
	current["interpretation_regimes"] = _normalize_regimes(Array(current.get("interpretation_regimes", [])))
	current["regions"] = _normalize_regions(Array(current.get("regions", [])))
	current["world_mutations"] = _normalize_world_mutations(Array(current.get("world_mutations", [])))
	current["residue_records"] = _normalize_residue(Array(current.get("residue_records", [])))
	current["literacy_tracks"] = _normalize_literacy_tracks(Array(current.get("literacy_tracks", [])))
	current["strategy_clusters"] = _normalize_strategy_clusters(Array(current.get("strategy_clusters", [])))
	current["cognitive_field_climate"] = _normalize_field_climate(Dictionary(current.get("cognitive_field_climate", {})))
	return current

static func apply_post_run_extensions(world_memory: Dictionary, run_context: Dictionary) -> Dictionary:
	var current := normalize_world_memory_extensions(world_memory)
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var profile: Dictionary = Dictionary(run_context.get("profile", {}))
	var constitution_summary: Dictionary = Dictionary(run_record.get("expedition_constitution_summary", {}))
	var cookbook_state: Dictionary = Dictionary(profile.get("cookbook_state", {}))
	var archive_state: Dictionary = Dictionary(profile.get("archive_state", {}))
	var theory_ids := _string_array(diagnostics.get("theory_ids", []))
	var theory_statuses := _string_array(diagnostics.get("theory_statuses", []))
	var residue_records := _normalize_residue(Array(current.get("residue_records", [])))
	residue_records.push_front({
		"residue_id": "residue_%s" % str(run_record.get("seed", 0)),
		"label": _first_non_empty([
			str(frame.get("world_pull", "")).strip_edges(),
			str(diagnostics.get("doctrine_world_goal", "")).strip_edges(),
			"run residue remains in circulation"
		]),
		"source_kind": "run",
		"play_routing_tags": ["witness", "route_choice", "return"]
	})
	current["residue_records"] = residue_records.slice(0, MAX_OBJECTS)
	var mutation_surface: Dictionary = Dictionary(run_record.get("mutation_public_summary", {}))
	var mutation_lines := _string_array(mutation_surface.get("public_lines", []))
	if not mutation_lines.is_empty():
		var world_mutations := _normalize_world_mutations(Array(current.get("world_mutations", [])))
		world_mutations.push_front({
			"mutation_id": "mutation_%s" % str(run_record.get("seed", 0)),
			"label": mutation_lines[0],
			"status": "approved",
			"reversal_mode": "reversal" if bool(diagnostics.get("safe_mode_active", false)) else "counteraction",
			"play_routing_tags": ["artifact_custody", "route_choice", "return"]
		})
		current["world_mutations"] = world_mutations.slice(0, MAX_OBJECTS)
	var factions := _normalize_factions(Array(current.get("factions", [])))
	var doctrine_family := str(constitution_summary.get("doctrine_family", diagnostics.get("doctrine_family", ""))).strip_edges()
	if not doctrine_family.is_empty() and factions.is_empty():
		factions.append({
			"faction_id": "faction_%s" % doctrine_family,
			"label": doctrine_family.capitalize(),
			"actor_type": "institution",
			"id": "faction_%s" % doctrine_family,
			"legitimacy_sources": ["doctrine_family"],
			"rumor_vectors": ["archive"],
			"archive_position": "primary",
			"legibility": 2,
			"play_routing_tags": ["witness", "artifact_custody", "route_choice"]
		})
	if theory_statuses.has("rival") and not _has_entry(factions, "faction_rival_interpreters", "faction_id"):
		factions.append({
			"faction_id": "faction_rival_interpreters",
			"label": "Rival interpreters",
			"actor_type": "institution",
			"id": "faction_rival_interpreters",
			"legitimacy_sources": ["theory_rivalry", "field_conflict"],
			"rumor_vectors": ["witness", "route"],
			"archive_position": "contesting",
			"legibility": 2,
			"play_routing_tags": ["witness", "route_choice", "return"]
		})
	if int(cookbook_state.get("fragment_count", 0)) >= 1 and not _has_entry(factions, "faction_cookbook_cell", "faction_id"):
		factions.append({
			"faction_id": "faction_cookbook_cell",
			"label": "Cookbook cell",
			"actor_type": "collective",
			"id": "faction_cookbook_cell",
			"legitimacy_sources": ["marginalia", "forbidden_method"],
			"rumor_vectors": ["archive", "artifact", "silence"],
			"archive_position": "shadow",
			"legibility": 1,
			"play_routing_tags": ["movement", "burden", "artifact_custody", "hesitation", "return"]
		})
	current["factions"] = factions.slice(0, MAX_OBJECTS)
	var regimes := _normalize_regimes(Array(current.get("interpretation_regimes", [])))
	if regimes.is_empty():
		regimes.append({
			"regime_id": "regime_primary",
			"label": _first_non_empty([str(frame.get("primary_school", "")).strip_edges(), "Primary reading"]),
			"mode": "archive",
			"faction_ids": _string_array([Dictionary(factions[0]).get("faction_id", "")]) if not factions.is_empty() else []
		})
	if theory_statuses.has("rival") and not _has_entry(regimes, "regime_rival_adoption", "regime_id"):
		regimes.append({
			"regime_id": "regime_rival_adoption",
			"label": "Contested adoption",
			"mode": "plural",
			"faction_ids": ["faction_rival_interpreters"]
		})
	if int(cookbook_state.get("fragment_count", 0)) >= 1 and not _has_entry(regimes, "regime_marginal", "regime_id"):
		regimes.append({
			"regime_id": "regime_marginal",
			"label": "Marginal reading",
			"mode": "shadow",
			"faction_ids": ["faction_cookbook_cell"]
		})
	current["interpretation_regimes"] = regimes.slice(0, MAX_OBJECTS)
	var literacy_tracks := _normalize_literacy_tracks(Array(current.get("literacy_tracks", [])))
	if literacy_tracks.is_empty():
		literacy_tracks.append({
			"track_id": "lit_public",
			"label": "Public literacy",
			"tier": 1 if Array(archive_state.get("entries", [])).size() >= 1 else 0,
			"activation_tags": ["archive", "theory"]
		})
	if theory_ids.size() >= 2 and not _has_entry(literacy_tracks, "lit_competing", "track_id"):
		literacy_tracks.append({
			"track_id": "lit_competing",
			"label": "Competing schools",
			"tier": 2,
			"activation_tags": ["theory", "factions", "world_mutation"]
		})
	if int(cookbook_state.get("fragment_count", 0)) >= 1 and not _has_entry(literacy_tracks, "lit_marginal", "track_id"):
		literacy_tracks.append({
			"track_id": "lit_marginal",
			"label": "Marginal literacy",
			"tier": 2 + mini(int(cookbook_state.get("holder_depth", 0)), 1),
			"activation_tags": ["cookbook", "contradiction", "archive"]
		})
	current["literacy_tracks"] = literacy_tracks.slice(0, MAX_OBJECTS)
	var strategy_clusters := _normalize_strategy_clusters(Array(current.get("strategy_clusters", [])))
	if strategy_clusters.is_empty():
		strategy_clusters.append({
			"cluster_id": "cluster_recovery",
			"label": "Recovery cluster",
			"pressure_tags": ["rescue", "burden", "return"],
			"play_routing_tags": ["rescue", "burden", "return"]
		})
	if theory_statuses.has("rival") and not _has_entry(strategy_clusters, "cluster_contestation", "cluster_id"):
		strategy_clusters.append({
			"cluster_id": "cluster_contestation",
			"label": "Contestation cluster",
			"pressure_tags": ["witness", "route_choice", "artifact_custody"],
			"play_routing_tags": ["witness", "route_choice", "artifact_custody", "hesitation"]
		})
	current["strategy_clusters"] = strategy_clusters.slice(0, MAX_OBJECTS)
	current["cognitive_field_climate"] = _normalize_field_climate({
		"field_state_id": str(constitution_summary.get("constitution_hash", run_record.get("seed", ""))).strip_edges(),
		"dominant_dimensions": _string_array(diagnostics.get("cognitive_field_dimensions", [])),
		"summary_lines": _string_array(diagnostics.get("cognitive_field_summary_lines", []))
	})
	return normalize_world_memory_extensions(current)

static func build_civilization_surface(world_memory: Dictionary) -> Dictionary:
	var current := normalize_world_memory_extensions(world_memory)
	var factions := _normalize_factions(Array(current.get("factions", [])))
	var regimes := _normalize_regimes(Array(current.get("interpretation_regimes", [])))
	var world_mutations := _normalize_world_mutations(Array(current.get("world_mutations", [])))
	var literacy_tracks := _normalize_literacy_tracks(Array(current.get("literacy_tracks", [])))
	var field_climate := _normalize_field_climate(Dictionary(current.get("cognitive_field_climate", {})))
	var lines: Array[String] = []
	if not factions.is_empty():
		var lead_faction := Dictionary(factions[0])
		lines.append("%s is now shaping public legitimacy and custody arguments" % str(lead_faction.get("label", "a faction")).strip_edges())
	if not regimes.is_empty():
		lines.append("%s is framing current interpretation and theory adoption" % str(Dictionary(regimes[0]).get("label", "a regime")).to_lower())
	if not world_mutations.is_empty():
		lines.append("%s is still redirecting what counts as a safe return path" % str(Dictionary(world_mutations[0]).get("label", "approved world mutation")).strip_edges())
	if not literacy_tracks.is_empty():
		lines.append("%s literacy is deciding which doctrine layers can spread" % str(Dictionary(literacy_tracks[0]).get("label", "public")).to_lower())
	if not _string_array(field_climate.get("summary_lines", [])).is_empty():
		lines.append(_string_array(field_climate.get("summary_lines", []))[0])
	return {
		"lines": _slice_strings(lines, MAX_LINES),
		"faction_ids": _pluck_ids(factions, "faction_id"),
		"regime_ids": _pluck_ids(regimes, "regime_id"),
		"region_ids": _pluck_ids(_normalize_regions(Array(current.get("regions", []))), "region_id"),
		"world_mutation_ids": _pluck_ids(world_mutations, "mutation_id"),
		"literacy_track_ids": _pluck_ids(literacy_tracks, "track_id"),
		"play_routing_tags": ["movement", "burden", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"]
	}

static func _normalize_factions(values: Array) -> Array[Dictionary]:
	var actor_schema: Dictionary = SCHEMA_REGISTRY_SCRIPT.cultural_actor_schema()
	var allowed_actor_types := _string_array(actor_schema.get("allowed_actor_types", []))
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["faction_id"] = str(current.get("faction_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["actor_type"] = str(current.get("actor_type", "institution")).strip_edges()
		if not allowed_actor_types.is_empty() and not allowed_actor_types.has(current["actor_type"]):
			current["actor_type"] = allowed_actor_types[0]
		current["id"] = str(current.get("id", current["faction_id"])).strip_edges()
		current["legitimacy_sources"] = _string_array(current.get("legitimacy_sources", []))
		current["rumor_vectors"] = _string_array(current.get("rumor_vectors", []))
		current["archive_position"] = str(current.get("archive_position", "primary")).strip_edges()
		current["legibility"] = clampi(int(current.get("legibility", 0)), 0, 4)
		current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
		if not current["faction_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_regimes(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["regime_id"] = str(current.get("regime_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["mode"] = str(current.get("mode", "archive")).strip_edges()
		current["faction_ids"] = _string_array(current.get("faction_ids", []))
		if not current["regime_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_regions(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["region_id"] = str(current.get("region_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["pressure_profile"] = _string_array(current.get("pressure_profile", []))
		current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
		if not current["region_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_world_mutations(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["mutation_id"] = str(current.get("mutation_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["status"] = str(current.get("status", "recorded")).strip_edges()
		current["reversal_mode"] = str(current.get("reversal_mode", "counteraction")).strip_edges()
		current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
		if not current["mutation_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_residue(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["residue_id"] = str(current.get("residue_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["source_kind"] = str(current.get("source_kind", "run")).strip_edges()
		current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
		if not current["residue_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_literacy_tracks(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["track_id"] = str(current.get("track_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["tier"] = maxi(int(current.get("tier", 0)), 0)
		current["activation_tags"] = _string_array(current.get("activation_tags", []))
		if not current["track_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_strategy_clusters(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["cluster_id"] = str(current.get("cluster_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["pressure_tags"] = _string_array(current.get("pressure_tags", []))
		current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
		if not current["cluster_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_field_climate(raw: Dictionary) -> Dictionary:
	var current := {
		"field_state_id": "",
		"dominant_dimensions": [],
		"summary_lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["field_state_id"] = str(current.get("field_state_id", "")).strip_edges()
	current["dominant_dimensions"] = _string_array(current.get("dominant_dimensions", []))
	current["summary_lines"] = _slice_strings(_string_array(current.get("summary_lines", [])), MAX_LINES)
	return current

static func _pluck_ids(entries: Array[Dictionary], key: String) -> Array[String]:
	var result: Array[String] = []
	for entry in entries:
		var value := str(Dictionary(entry).get(key, "")).strip_edges()
		if not value.is_empty() and not result.has(value):
			result.append(value)
	return result

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _slice_strings(values: Array, limit: int) -> Array[String]:
	return _string_array(values).slice(0, limit)

static func _first_non_empty(values: Array) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return ""

static func _has_entry(values: Array, id_value: String, key: String) -> bool:
	for value in values:
		if str(Dictionary(value).get(key, "")).strip_edges() == id_value:
			return true
	return false
