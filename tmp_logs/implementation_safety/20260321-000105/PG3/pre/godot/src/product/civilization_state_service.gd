class_name CivilizationStateService
extends RefCounted

const SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")
const MAX_OBJECTS := 24
const MAX_LINES := 6

static func default_extensions() -> Dictionary:
	return {
		"factions": [],
		"interpretation_regimes": [],
		"market_regimes": [],
		"lifecycle_states": [],
		"regions": [],
		"world_mutations": [],
		"residue_records": [],
		"literacy_tracks": [],
		"strategy_clusters": [],
		"institutional_pressure_surface": {
			"pressure_band": "",
			"claim_lines": [],
			"interpretation_lines": [],
			"reputation_bands": [],
			"quiet_play_lines": []
		},
		"artifact_consequence_surface": {
			"artifact_consequence_version": 0,
			"consequence_event_family": "",
			"burden_band": "",
			"valuation_band": "",
			"return_consequence_state": "",
			"market_regime_id": "",
			"market_carrier_risk_band": "",
			"public_consequence_tags": [],
			"return_pressure_tags": [],
			"lines": []
		},
		"encounter_apex_consequence_surface": {
			"encounter_apex_consequence_version": 0,
			"encounter_resolution_state": "",
			"apex_resolution_state": "",
			"anchored_pressures": [],
			"consequence_classes": [],
			"local_aftermath_tags": [],
			"world_aftermath_tags": [],
			"aftermath_consequence_refs": [],
			"lines": []
		},
		"cognitive_field_climate": {
			"field_state_id": "",
			"dominant_dimensions": [],
			"summary_lines": []
		}
	}

static func is_world_aftermath_ref_shape(record: Dictionary) -> bool:
	return str(record.get("schema_name", "")).strip_edges() == "WorldAftermathRef"

static func is_world_aftermath_record_shape(record: Dictionary) -> bool:
	return str(record.get("schema_name", "")).strip_edges() == "WorldAftermath"

static func world_aftermath_ref_entries(entries: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_raw in Array(entries):
		var entry := Dictionary(entry_raw)
		if is_world_aftermath_ref_shape(entry):
			result.append(entry.duplicate(true))
	return result.slice(0, MAX_OBJECTS)

static func world_aftermath_record_entries(entries: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_raw in Array(entries):
		var entry := Dictionary(entry_raw)
		if is_world_aftermath_record_shape(entry):
			result.append(entry.duplicate(true))
	return result.slice(0, MAX_OBJECTS)

static func normalize_world_memory_extensions(world_memory: Dictionary) -> Dictionary:
	var current := world_memory.duplicate(true)
	for key in default_extensions().keys():
		if not current.has(key):
			current[key] = default_extensions()[key]
	current["factions"] = _normalize_factions(Array(current.get("factions", [])))
	current["interpretation_regimes"] = _normalize_regimes(Array(current.get("interpretation_regimes", [])))
	current["market_regimes"] = _normalize_market_regimes(Array(current.get("market_regimes", [])))
	current["lifecycle_states"] = _normalize_lifecycle_states(Array(current.get("lifecycle_states", [])))
	current["regions"] = _normalize_regions(Array(current.get("regions", [])))
	current["world_mutations"] = _normalize_world_mutations(Array(current.get("world_mutations", [])))
	current["residue_records"] = _normalize_residue(Array(current.get("residue_records", [])))
	current["literacy_tracks"] = _normalize_literacy_tracks(Array(current.get("literacy_tracks", [])))
	current["strategy_clusters"] = _normalize_strategy_clusters(Array(current.get("strategy_clusters", [])))
	current["institutional_pressure_surface"] = _normalize_institutional_pressure_surface(Dictionary(current.get("institutional_pressure_surface", {})))
	current["artifact_consequence_surface"] = _normalize_artifact_consequence_surface(Dictionary(current.get("artifact_consequence_surface", {})))
	current["encounter_apex_consequence_surface"] = _normalize_encounter_apex_consequence_surface(Dictionary(current.get("encounter_apex_consequence_surface", {})))
	current["cognitive_field_climate"] = _normalize_field_climate(Dictionary(current.get("cognitive_field_climate", {})))
	return current

static func build_world_aftermath_records(run_context: Dictionary) -> Array[Dictionary]:
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var constitution_summary: Dictionary = Dictionary(run_record.get("expedition_constitution_summary", {}))
	var local_aftermath: Dictionary = Dictionary(run_record.get("local_aftermath", {}))
	var active_apex_state: Dictionary = Dictionary(run_record.get("active_apex_state", {}))
	var raw_aftermath_refs := Array(run_record.get("world_aftermath_refs", []))
	var aftermath_refs := world_aftermath_ref_entries(raw_aftermath_refs)
	if not raw_aftermath_refs.is_empty() and aftermath_refs.size() != raw_aftermath_refs.size():
		return []
	if aftermath_refs.is_empty() and not local_aftermath.is_empty():
		aftermath_refs = [{
			"schema_name": "WorldAftermathRef",
			"schema_version": 1,
			"encounter_apex_consequence_version": int(local_aftermath.get("encounter_apex_consequence_version", 0)),
			"aftermath_id": "world_aftermath_%s" % str(local_aftermath.get("source_id", "")).strip_edges(),
			"source_id": str(local_aftermath.get("source_id", "")).strip_edges(),
			"source_kind": str(local_aftermath.get("source_kind", "encounter")).strip_edges(),
			"apex_id": str(active_apex_state.get("apex_id", "")),
			"encounter_resolution_state": str(local_aftermath.get("encounter_resolution_state", "")).strip_edges(),
			"apex_resolution_state": str(local_aftermath.get("apex_resolution_state", "")).strip_edges(),
			"anchored_pressures": Array(local_aftermath.get("anchored_pressures", [])).duplicate(true),
			"consequence_classes": Array(local_aftermath.get("consequence_classes", [])).duplicate(true),
			"local_aftermath_id": str(local_aftermath.get("aftermath_id", "")).strip_edges(),
			"continuity_seed_tags": Array(local_aftermath.get("narrative_residue_tags", [])).duplicate(true),
			"return_pressure_tags": Array(local_aftermath.get("residual_telegraph_tags", [])).duplicate(true),
			"route_state_hint": str(local_aftermath.get("immediate_route_state", "")).strip_edges(),
			"successor_hint_ids": Array(constitution_summary.get("apex_class_ids", [])).duplicate(true),
			"local_aftermath_tags": Array(local_aftermath.get("local_aftermath_tags", [])).duplicate(true),
			"world_aftermath_tags": Array(local_aftermath.get("world_aftermath_tags", [])).duplicate(true),
			"aftermath_consequence_refs": Array(local_aftermath.get("aftermath_consequence_refs", [])).duplicate(true)
		}]
	var institutional_surface: Dictionary = Dictionary(diagnostics.get("institutional_pressure_surface", {}))
	var institutional_response_seed := _first_non_empty(
		_string_array(institutional_surface.get("claim_lines", []))
		+ _string_array(institutional_surface.get("interpretation_lines", []))
		+ _string_array(constitution_summary.get("apex_lines", []))
		+ ["institutions are rereading the route through the aftermath"]
	)
	var result: Array[Dictionary] = []
	for aftermath_ref_raw in aftermath_refs:
		var aftermath_ref := Dictionary(aftermath_ref_raw)
		var aftermath_id := str(aftermath_ref.get("aftermath_id", "")).strip_edges()
		var source_id := str(aftermath_ref.get("source_id", local_aftermath.get("source_id", ""))).strip_edges()
		if aftermath_id.is_empty() or source_id.is_empty():
			continue
		var source_kind := str(aftermath_ref.get("source_kind", local_aftermath.get("source_kind", "encounter"))).strip_edges()
		var apex_id := str(aftermath_ref.get("apex_id", active_apex_state.get("apex_id", ""))).strip_edges()
		var route_state_hint := str(aftermath_ref.get("route_state_hint", local_aftermath.get("immediate_route_state", ""))).strip_edges()
		var encounter_resolution_state := str(aftermath_ref.get("encounter_resolution_state", local_aftermath.get("encounter_resolution_state", ""))).strip_edges()
		var apex_resolution_state := str(aftermath_ref.get("apex_resolution_state", local_aftermath.get("apex_resolution_state", ""))).strip_edges()
		var residue_records := _slice_strings(
			_string_array(aftermath_ref.get("continuity_seed_tags", []))
			+ _string_array(aftermath_ref.get("residue_records", []))
			+ _string_array(local_aftermath.get("narrative_residue_tags", [])),
			3
		)
		var return_pressure_tags := _slice_strings(
			_string_array(aftermath_ref.get("return_pressure_tags", []))
			+ _string_array(aftermath_ref.get("residual_telegraph_tags", []))
			+ _string_array(local_aftermath.get("residual_telegraph_tags", [])),
			4
		)
		var successor_claims := _slice_strings(
			_string_array(aftermath_ref.get("successor_hint_ids", []))
			+ _string_array(aftermath_ref.get("successor_claims", []))
			+ _string_array(constitution_summary.get("apex_class_ids", [])),
			4
		)
		var anchored_pressures := _slice_strings(
			_string_array(aftermath_ref.get("anchored_pressures", []))
			+ _string_array(local_aftermath.get("anchored_pressures", [])),
			6
		)
		var consequence_classes := _slice_strings(
			_string_array(aftermath_ref.get("consequence_classes", []))
			+ _string_array(local_aftermath.get("consequence_classes", [])),
			6
		)
		var local_aftermath_tags := _slice_strings(
			_string_array(aftermath_ref.get("local_aftermath_tags", []))
			+ _string_array(local_aftermath.get("local_aftermath_tags", [])),
			6
		)
		var world_aftermath_tags := _slice_strings(
			_string_array(aftermath_ref.get("world_aftermath_tags", []))
			+ _string_array(local_aftermath.get("world_aftermath_tags", [])),
			6
		)
		var aftermath_consequence_refs := _slice_strings(
			_string_array(aftermath_ref.get("aftermath_consequence_refs", []))
			+ _string_array(local_aftermath.get("aftermath_consequence_refs", [])),
			8
		)
		var prestige_climate_delta := str(aftermath_ref.get("prestige_climate_delta", "")).strip_edges()
		if prestige_climate_delta.is_empty():
			prestige_climate_delta = "elevated" if route_state_hint == "rerouted" else "steady"
		var institutional_response := _first_non_empty([
			str(aftermath_ref.get("institutional_response", "")).strip_edges(),
			institutional_response_seed
		])
		var continuity_scars := _slice_strings(
			_string_array(aftermath_ref.get("continuity_scars", []))
			+ ["scar_%s" % source_id],
			6
		)
		var world_mutation_ids := _slice_strings(
			_string_array(aftermath_ref.get("world_mutation_ids", []))
			+ (["wm_%s" % apex_id] if not apex_id.is_empty() and source_kind == "apex" else []),
			6
		)
		result.append({
			"schema_name": "WorldAftermath",
			"schema_version": 1,
			"encounter_apex_consequence_version": int(aftermath_ref.get("encounter_apex_consequence_version", local_aftermath.get("encounter_apex_consequence_version", 0))),
			"aftermath_id": aftermath_id,
			"source_id": source_id,
			"source_kind": source_kind,
			"apex_id": apex_id,
			"encounter_resolution_state": encounter_resolution_state,
			"apex_resolution_state": apex_resolution_state,
			"anchored_pressures": anchored_pressures,
			"consequence_classes": consequence_classes,
			"local_aftermath_tags": local_aftermath_tags,
			"world_aftermath_tags": world_aftermath_tags,
			"aftermath_consequence_refs": aftermath_consequence_refs,
			"world_mutation_ids": world_mutation_ids,
			"residue_records": residue_records,
			"prestige_climate_delta": prestige_climate_delta,
			"institutional_response": institutional_response,
			"return_pressure_tags": return_pressure_tags,
			"continuity_scars": continuity_scars,
			"successor_claims": successor_claims
		})
	return result.slice(0, MAX_OBJECTS)

static func apply_post_run_extensions(world_memory: Dictionary, run_context: Dictionary) -> Dictionary:
	var current := normalize_world_memory_extensions(world_memory)
	var run_record: Dictionary = Dictionary(run_context.get("run_record", {}))
	var diagnostics: Dictionary = Dictionary(run_context.get("diagnostics", {}))
	var frame: Dictionary = Dictionary(run_context.get("frame", {}))
	var profile: Dictionary = Dictionary(run_context.get("profile", {}))
	var constitution_summary: Dictionary = Dictionary(run_record.get("expedition_constitution_summary", {}))
	var cookbook_state: Dictionary = Dictionary(profile.get("cookbook_state", {}))
	var archive_state: Dictionary = Dictionary(profile.get("archive_state", {}))
	var world_market_memory: Dictionary = Dictionary(current.get("market_memory_state", {}))
	var world_lifecycle_registry: Dictionary = Dictionary(current.get("lifecycle_registry", {}))
	var expedition_constitution: Dictionary = Dictionary(run_record.get("expedition_constitution", {}))
	var constitution_market_regime: Dictionary = Dictionary(expedition_constitution.get("market_regime_state", {}))
	var theory_ids := _string_array(diagnostics.get("theory_ids", []))
	var theory_statuses := _string_array(diagnostics.get("theory_statuses", []))
	var residue_records := _normalize_residue(Array(current.get("residue_records", [])))
	var world_aftermath_records := build_world_aftermath_records(run_context)
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
	for aftermath_raw in world_aftermath_records:
		var aftermath := Dictionary(aftermath_raw)
		var aftermath_id := str(aftermath.get("aftermath_id", "")).strip_edges()
		if aftermath_id.is_empty():
			continue
		residue_records.push_front({
			"residue_id": aftermath_id,
			"label": _first_non_empty([
				_first_non_empty(_string_array(aftermath.get("residue_records", []))),
				str(aftermath.get("institutional_response", "")).strip_edges(),
				"aftermath residue remains in circulation"
			]),
			"source_kind": "world_aftermath",
			"play_routing_tags": ["witness", "route_choice", "return"]
		})
	current["residue_records"] = residue_records.slice(0, MAX_OBJECTS)
	var mutation_surface: Dictionary = Dictionary(run_record.get("mutation_public_summary", {}))
	var mutation_lines := _string_array(mutation_surface.get("public_lines", []))
	var world_mutations := _normalize_world_mutations(Array(current.get("world_mutations", [])))
	if not mutation_lines.is_empty():
		world_mutations.push_front({
			"mutation_id": "mutation_%s" % str(run_record.get("seed", 0)),
			"label": mutation_lines[0],
			"status": "approved",
			"reversal_mode": "reversal" if bool(diagnostics.get("safe_mode_active", false)) else "counteraction",
			"play_routing_tags": ["artifact_custody", "route_choice", "return"]
		})
	for aftermath_raw in world_aftermath_records:
		var aftermath := Dictionary(aftermath_raw)
		for mutation_id in _string_array(aftermath.get("world_mutation_ids", [])):
			if _has_entry(world_mutations, mutation_id, "mutation_id"):
				continue
			world_mutations.push_front({
				"mutation_id": mutation_id,
				"label": _first_non_empty([
					str(aftermath.get("institutional_response", "")).strip_edges(),
					"aftermath mutation persists"
				]),
				"status": "approved",
				"reversal_mode": "counteraction",
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
	var market_regimes := _normalize_market_regimes(Array(current.get("market_regimes", [])))
	var active_regime_ids := _string_array(constitution_summary.get("active_regime_ids", world_market_memory.get("active_regime_ids", [])))
	var market_regime_id := str(constitution_summary.get("market_regime_id", _first_non_empty(active_regime_ids))).strip_edges()
	if not market_regime_id.is_empty() and not _has_entry(market_regimes, market_regime_id, "regime_id"):
		market_regimes.append({
			"regime_id": market_regime_id,
			"label": market_regime_id.replace("_", " ").capitalize(),
			"regime_family": str(constitution_summary.get("market_regime_family", "balanced")).strip_edges(),
			"scarcity_band": str(constitution_market_regime.get("scarcity_band", "suppressed")).strip_edges(),
			"prestige_band": str(constitution_summary.get("market_prestige_band", "")),
			"carrier_risk_band": str(constitution_summary.get("market_carrier_risk_band", "")),
			"active": true,
			"play_routing_tags": ["artifact_custody", "route_choice", "extraction", "return"]
		})
	current["market_regimes"] = market_regimes.slice(0, MAX_OBJECTS)
	var lifecycle_states := _normalize_lifecycle_states(Array(current.get("lifecycle_states", [])))
	var constitution_lifecycle: Dictionary = Dictionary(expedition_constitution.get("lifecycle_registry", world_lifecycle_registry))
	for state_raw in Array(constitution_lifecycle.get("families", [])):
		var lifecycle_state := Dictionary(state_raw).duplicate(true)
		lifecycle_state["state_id"] = str(lifecycle_state.get("family_id", lifecycle_state.get("state_id", ""))).strip_edges()
		if str(lifecycle_state.get("state_id", "")).strip_edges().is_empty():
			continue
		if _has_entry(lifecycle_states, str(lifecycle_state.get("state_id", "")), "state_id"):
			continue
		lifecycle_states.append({
			"state_id": str(lifecycle_state.get("state_id", "")).strip_edges(),
			"family_id": str(lifecycle_state.get("family_id", "")).strip_edges(),
			"family_kind": str(lifecycle_state.get("family_kind", "market")).strip_edges(),
			"source_id": str(lifecycle_state.get("source_id", lifecycle_state.get("family_id", ""))).strip_edges(),
			"state": str(lifecycle_state.get("state", "emerging")).strip_edges(),
			"heat": int(lifecycle_state.get("heat", 0)),
			"saturation": int(lifecycle_state.get("saturation", 0)),
			"strain": int(lifecycle_state.get("strain", 0)),
			"cooling_tags": _string_array(lifecycle_state.get("cooling_tags", [])),
			"cooldown_band": str(lifecycle_state.get("cooldown_band", "open")).strip_edges(),
			"successor_hint": str(lifecycle_state.get("successor_hint", "")).strip_edges(),
			"return_window": str(lifecycle_state.get("return_window", "")).strip_edges(),
			"routing_tags": _string_array(lifecycle_state.get("routing_tags", [])),
			"dominance_strain": int(lifecycle_state.get("dominance_strain", lifecycle_state.get("strain", 0))),
			"throttle_state": str(lifecycle_state.get("throttle_state", "open")).strip_edges(),
			"resurrection_priority": int(lifecycle_state.get("resurrection_priority", 0))
		})
	current["lifecycle_states"] = lifecycle_states.slice(0, MAX_OBJECTS)
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
	var outcome_summary: Dictionary = Dictionary(run_record.get("outcome_summary", {}))
	current["institutional_pressure_surface"] = _normalize_institutional_pressure_surface({
		"pressure_band": str(Dictionary(diagnostics.get("institutional_pressure_surface", {})).get("pressure_band", "")).strip_edges(),
		"claim_lines": _string_array(Dictionary(diagnostics.get("institutional_pressure_surface", {})).get("claim_lines", [])),
		"interpretation_lines": _string_array(Dictionary(diagnostics.get("institutional_pressure_surface", {})).get("interpretation_lines", [])),
		"reputation_bands": _string_array([str(diagnostics.get("reputation_band", "")).strip_edges()]),
		"quiet_play_lines": _string_array(diagnostics.get("quiet_play_signals", []))
	})
	current["artifact_consequence_surface"] = _normalize_artifact_consequence_surface({
		"artifact_consequence_version": int(outcome_summary.get("artifact_consequence_version", 0)),
		"consequence_event_family": str(outcome_summary.get("consequence_event_family", "")).strip_edges(),
		"burden_band": str(outcome_summary.get("burden_band", "")).strip_edges(),
		"valuation_band": str(outcome_summary.get("valuation_band", "")).strip_edges(),
		"return_consequence_state": str(outcome_summary.get("return_consequence_state", "")).strip_edges(),
		"market_regime_id": str(outcome_summary.get("market_regime_id", market_regime_id)).strip_edges(),
		"market_carrier_risk_band": str(outcome_summary.get("market_carrier_risk_band", constitution_summary.get("market_carrier_risk_band", ""))).strip_edges(),
		"public_consequence_tags": _string_array(outcome_summary.get("public_consequence_tags", [])),
		"return_pressure_tags": _string_array(outcome_summary.get("return_pressure_tags", [])),
		"lines": _string_array(
			[
				"%s under %s" % [
					str(outcome_summary.get("return_consequence_state", "")).replace("_", " "),
					str(outcome_summary.get("valuation_band", "")).replace("_", " ")
				]
			]
			if not str(outcome_summary.get("return_consequence_state", "")).strip_edges().is_empty() or not str(outcome_summary.get("valuation_band", "")).strip_edges().is_empty()
			else []
		)
	})
	current["encounter_apex_consequence_surface"] = _normalize_encounter_apex_consequence_surface({
		"encounter_apex_consequence_version": int(run_record.get("encounter_apex_consequence_version", Dictionary(run_record.get("local_aftermath", {})).get("encounter_apex_consequence_version", 0))),
		"encounter_resolution_state": str(run_record.get("encounter_resolution_state", Dictionary(run_record.get("local_aftermath", {})).get("encounter_resolution_state", ""))).strip_edges(),
		"apex_resolution_state": str(run_record.get("apex_resolution_state", Dictionary(run_record.get("local_aftermath", {})).get("apex_resolution_state", ""))).strip_edges(),
		"anchored_pressures": _string_array(run_record.get("anchored_pressures", Dictionary(run_record.get("local_aftermath", {})).get("anchored_pressures", []))),
		"consequence_classes": _string_array(run_record.get("consequence_classes", Dictionary(run_record.get("local_aftermath", {})).get("consequence_classes", []))),
		"local_aftermath_tags": _string_array(run_record.get("local_aftermath_tags", Dictionary(run_record.get("local_aftermath", {})).get("local_aftermath_tags", []))),
		"world_aftermath_tags": _string_array(run_record.get("world_aftermath_tags", [])),
		"aftermath_consequence_refs": _string_array(run_record.get("aftermath_consequence_refs", Dictionary(run_record.get("local_aftermath", {})).get("aftermath_consequence_refs", []))),
		"lines": _string_array(
			[
				"%s / %s through %s" % [
					str(run_record.get("encounter_resolution_state", Dictionary(run_record.get("local_aftermath", {})).get("encounter_resolution_state", ""))).replace("_", " "),
					str(run_record.get("apex_resolution_state", Dictionary(run_record.get("local_aftermath", {})).get("apex_resolution_state", ""))).replace("_", " "),
					_first_non_empty(
						_string_array(run_record.get("world_aftermath_tags", []))
						+ _string_array(Dictionary(run_record.get("local_aftermath", {})).get("world_aftermath_tags", []))
					)
				]
			]
			if int(run_record.get("encounter_apex_consequence_version", Dictionary(run_record.get("local_aftermath", {})).get("encounter_apex_consequence_version", 0))) > 0
			else []
		)
	})
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
	var market_regimes := _normalize_market_regimes(Array(current.get("market_regimes", [])))
	var lifecycle_states := _normalize_lifecycle_states(Array(current.get("lifecycle_states", [])))
	var world_mutations := _normalize_world_mutations(Array(current.get("world_mutations", [])))
	var literacy_tracks := _normalize_literacy_tracks(Array(current.get("literacy_tracks", [])))
	var institutional_pressure_surface := _normalize_institutional_pressure_surface(Dictionary(current.get("institutional_pressure_surface", {})))
	var artifact_consequence_surface := _normalize_artifact_consequence_surface(Dictionary(current.get("artifact_consequence_surface", {})))
	var encounter_apex_consequence_surface := _normalize_encounter_apex_consequence_surface(Dictionary(current.get("encounter_apex_consequence_surface", {})))
	var field_climate := _normalize_field_climate(Dictionary(current.get("cognitive_field_climate", {})))
	var lines: Array[String] = []
	if not factions.is_empty():
		var lead_faction := Dictionary(factions[0])
		lines.append("%s is now shaping public legitimacy and custody arguments" % str(lead_faction.get("label", "a faction")).strip_edges())
	if not regimes.is_empty():
		lines.append("%s is framing current interpretation and theory adoption" % str(Dictionary(regimes[0]).get("label", "a regime")).to_lower())
	if not market_regimes.is_empty():
		lines.append("%s is setting the current market climate for carriers and extraction debt" % str(Dictionary(market_regimes[0]).get("label", "a market regime")).to_lower())
	if not _string_array(artifact_consequence_surface.get("lines", [])).is_empty():
		lines.append("artifact consequence is holding at %s" % _string_array(artifact_consequence_surface.get("lines", []))[0].to_lower())
	if not _string_array(encounter_apex_consequence_surface.get("lines", [])).is_empty():
		lines.append("aftermath consequence is holding at %s" % _string_array(encounter_apex_consequence_surface.get("lines", []))[0].to_lower())
	if not lifecycle_states.is_empty():
		lines.append("%s is the dominant lifecycle state for current doctrine families" % str(Dictionary(lifecycle_states[0]).get("state_id", "an active lifecycle")).replace("_", " "))
	if not world_mutations.is_empty():
		lines.append("%s is still redirecting what counts as a safe return path" % str(Dictionary(world_mutations[0]).get("label", "approved world mutation")).strip_edges())
	if not literacy_tracks.is_empty():
		lines.append("%s literacy is deciding which doctrine layers can spread" % str(Dictionary(literacy_tracks[0]).get("label", "public")).to_lower())
	var institutional_claim := _first_non_empty(_string_array(institutional_pressure_surface.get("claim_lines", [])))
	if not institutional_claim.is_empty():
		lines.append("institutional pressure is hardening around %s" % institutional_claim.to_lower())
	if not _string_array(field_climate.get("summary_lines", [])).is_empty():
		lines.append(_string_array(field_climate.get("summary_lines", []))[0])
	return {
		"lines": _slice_strings(lines, MAX_LINES),
		"faction_ids": _pluck_ids(factions, "faction_id"),
		"regime_ids": _pluck_ids(regimes, "regime_id"),
		"market_regime_ids": _pluck_ids(market_regimes, "regime_id"),
		"lifecycle_state_ids": _pluck_ids(lifecycle_states, "state_id"),
		"region_ids": _pluck_ids(_normalize_regions(Array(current.get("regions", []))), "region_id"),
		"world_mutation_ids": _pluck_ids(world_mutations, "mutation_id"),
		"literacy_track_ids": _pluck_ids(literacy_tracks, "track_id"),
		"market_regime_lines": _slice_strings(_pluck_labels(market_regimes, "label"), MAX_LINES),
		"artifact_consequence_lines": _slice_strings(_string_array(artifact_consequence_surface.get("lines", [])), MAX_LINES),
		"artifact_consequence_tags": _slice_strings(_string_array(artifact_consequence_surface.get("public_consequence_tags", [])), MAX_LINES),
		"encounter_apex_consequence_lines": _slice_strings(_string_array(encounter_apex_consequence_surface.get("lines", [])), MAX_LINES),
		"encounter_apex_consequence_tags": _slice_strings(
			_string_array(encounter_apex_consequence_surface.get("world_aftermath_tags", []))
			+ _string_array(encounter_apex_consequence_surface.get("local_aftermath_tags", [])),
			MAX_LINES
		),
		"aftermath_consequence_refs": _slice_strings(_string_array(encounter_apex_consequence_surface.get("aftermath_consequence_refs", [])), MAX_LINES),
		"lifecycle_lines": _slice_strings(_pluck_labels(lifecycle_states, "state_id"), MAX_LINES),
		"institutional_pressure_lines": _slice_strings(
			_string_array(institutional_pressure_surface.get("claim_lines", []))
			+ _string_array(institutional_pressure_surface.get("interpretation_lines", [])),
			MAX_LINES
		),
		"reputation_bands": _slice_strings(_string_array(institutional_pressure_surface.get("reputation_bands", [])), MAX_LINES),
		"quiet_play_lines": _slice_strings(_string_array(institutional_pressure_surface.get("quiet_play_lines", [])), MAX_LINES),
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

static func _normalize_market_regimes(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["regime_id"] = str(current.get("regime_id", "")).strip_edges()
		current["label"] = str(current.get("label", "")).strip_edges()
		current["regime_family"] = str(current.get("regime_family", "balanced")).strip_edges()
		current["scarcity_band"] = str(current.get("scarcity_band", "suppressed")).strip_edges()
		current["prestige_band"] = str(current.get("prestige_band", "suppressed")).strip_edges()
		current["carrier_risk_band"] = str(current.get("carrier_risk_band", "suppressed")).strip_edges()
		current["active"] = bool(current.get("active", true))
		current["play_routing_tags"] = _string_array(current.get("play_routing_tags", []))
		if not current["regime_id"].is_empty():
			result.append(current)
	return result.slice(0, MAX_OBJECTS)

static func _normalize_lifecycle_states(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var current := Dictionary(value).duplicate(true)
		current["state_id"] = str(current.get("state_id", current.get("family_id", ""))).strip_edges()
		current["family_id"] = str(current.get("family_id", current.get("state_id", ""))).strip_edges()
		current["family_kind"] = str(current.get("family_kind", "market")).strip_edges()
		current["source_id"] = str(current.get("source_id", current.get("family_id", ""))).strip_edges()
		current["state"] = str(current.get("state", "emerging")).strip_edges()
		current["heat"] = int(current.get("heat", 0))
		current["saturation"] = int(current.get("saturation", 0))
		current["strain"] = int(current.get("strain", 0))
		current["cooling_tags"] = _string_array(current.get("cooling_tags", []))
		current["cooldown_band"] = str(current.get("cooldown_band", "open")).strip_edges()
		current["successor_hint"] = str(current.get("successor_hint", "")).strip_edges()
		current["return_window"] = str(current.get("return_window", "")).strip_edges()
		current["routing_tags"] = _string_array(current.get("routing_tags", []))
		current["dominance_strain"] = int(current.get("dominance_strain", current.get("strain", 0)))
		current["throttle_state"] = str(current.get("throttle_state", "open")).strip_edges()
		current["resurrection_priority"] = int(current.get("resurrection_priority", 0))
		if not current["state_id"].is_empty():
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

static func _normalize_artifact_consequence_surface(raw: Dictionary) -> Dictionary:
	var current := {
		"artifact_consequence_version": 0,
		"consequence_event_family": "",
		"burden_band": "",
		"valuation_band": "",
		"return_consequence_state": "",
		"market_regime_id": "",
		"market_carrier_risk_band": "",
		"public_consequence_tags": [],
		"return_pressure_tags": [],
		"lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["artifact_consequence_version"] = int(current.get("artifact_consequence_version", 0))
	current["consequence_event_family"] = str(current.get("consequence_event_family", "")).strip_edges()
	current["burden_band"] = str(current.get("burden_band", "")).strip_edges()
	current["valuation_band"] = str(current.get("valuation_band", "")).strip_edges()
	current["return_consequence_state"] = str(current.get("return_consequence_state", "")).strip_edges()
	current["market_regime_id"] = str(current.get("market_regime_id", "")).strip_edges()
	current["market_carrier_risk_band"] = str(current.get("market_carrier_risk_band", "")).strip_edges()
	current["public_consequence_tags"] = _slice_strings(_string_array(current.get("public_consequence_tags", [])), MAX_LINES)
	current["return_pressure_tags"] = _slice_strings(_string_array(current.get("return_pressure_tags", [])), MAX_LINES)
	current["lines"] = _slice_strings(_string_array(current.get("lines", [])), MAX_LINES)
	return current

static func _normalize_encounter_apex_consequence_surface(raw: Dictionary) -> Dictionary:
	var current := {
		"encounter_apex_consequence_version": 0,
		"encounter_resolution_state": "",
		"apex_resolution_state": "",
		"anchored_pressures": [],
		"consequence_classes": [],
		"local_aftermath_tags": [],
		"world_aftermath_tags": [],
		"aftermath_consequence_refs": [],
		"lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["encounter_apex_consequence_version"] = int(current.get("encounter_apex_consequence_version", 0))
	current["encounter_resolution_state"] = str(current.get("encounter_resolution_state", "")).strip_edges()
	current["apex_resolution_state"] = str(current.get("apex_resolution_state", "")).strip_edges()
	current["anchored_pressures"] = _slice_strings(_string_array(current.get("anchored_pressures", [])), MAX_LINES)
	current["consequence_classes"] = _slice_strings(_string_array(current.get("consequence_classes", [])), MAX_LINES)
	current["local_aftermath_tags"] = _slice_strings(_string_array(current.get("local_aftermath_tags", [])), MAX_LINES)
	current["world_aftermath_tags"] = _slice_strings(_string_array(current.get("world_aftermath_tags", [])), MAX_LINES)
	current["aftermath_consequence_refs"] = _slice_strings(_string_array(current.get("aftermath_consequence_refs", [])), MAX_LINES)
	current["lines"] = _slice_strings(_string_array(current.get("lines", [])), MAX_LINES)
	return current

static func _normalize_institutional_pressure_surface(raw: Dictionary) -> Dictionary:
	var current := {
		"pressure_band": "",
		"claim_lines": [],
		"interpretation_lines": [],
		"reputation_bands": [],
		"quiet_play_lines": []
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["pressure_band"] = str(current.get("pressure_band", "")).strip_edges()
	current["claim_lines"] = _slice_strings(_string_array(current.get("claim_lines", [])), MAX_LINES)
	current["interpretation_lines"] = _slice_strings(_string_array(current.get("interpretation_lines", [])), MAX_LINES)
	current["reputation_bands"] = _slice_strings(_string_array(current.get("reputation_bands", [])), MAX_LINES)
	current["quiet_play_lines"] = _slice_strings(_string_array(current.get("quiet_play_lines", [])), MAX_LINES)
	return current

static func _pluck_ids(entries: Array[Dictionary], key: String) -> Array[String]:
	var result: Array[String] = []
	for entry in entries:
		var value := str(Dictionary(entry).get(key, "")).strip_edges()
		if not value.is_empty() and not result.has(value):
			result.append(value)
	return result

static func _pluck_labels(entries: Array[Dictionary], key: String) -> Array[String]:
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
