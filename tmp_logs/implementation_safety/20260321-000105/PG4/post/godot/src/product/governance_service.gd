class_name GovernanceService
extends RefCounted

const MAX_HISTORY := 24
const MAX_REPORTS := 24
const MAX_LINES := 6
const PACKET_SCHEMA_VERSION := 2
const PROVENANCE_CONTRACT_VERSION := 1
const SIGNAL_COMPRESSION_SCHEMA_VERSION := 1
const GOVERNANCE_HOOK_SCHEMA_VERSION := 1
const TRUTH_RESOLUTION_ENVELOPE_SCHEMA_VERSION := 1
const BASELINE_ROUTES := ["movement", "burden", "rescue", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"]
const ALL_CHANNELS := ["constitution", "archive", "world_memory", "inquiry", "theory", "cognitive_field", "factions", "world_mutation", "cookbook", "contradiction", "safe_mode"]

static func default_state() -> Dictionary:
	return {
		"schema_name": "GovernanceState",
		"schema_version": 1,
		"constitution_history": [],
		"activation_state": _default_activation_state(),
		"safe_mode_state": _default_safe_mode_state(),
		"quarantine_registry": [],
		"stability_reports": [],
		"anti_bottleneck_reports": [],
		"play_routing_reports": [],
		"court_decisions": [],
		"meta_reflection_reports": [],
		"contradiction_records": [],
		"fairness_trigger_records": [],
		"dignity_trigger_records": [],
		"normalization_records": [],
		"rollback_candidates": [],
		"saturation_reports": [],
		"dominance_strain_reports": [],
		"throttle_records": [],
		"fairness_veto_registry": [],
		"dignity_veto_registry": [],
		"rollback_registry": [],
		"exploit_absorption_reports": [],
		"meta_collapse_reports": [],
		"resurrection_priority": _default_resurrection_priority(),
		"truth_resolution_defaults": {}
	}

static func normalize(state: Dictionary) -> Dictionary:
	var current := default_state()
	for key in state.keys():
		current[key] = state[key]
	current["activation_state"] = normalize_activation_state(Dictionary(current.get("activation_state", {})))
	current["safe_mode_state"] = normalize_safe_mode_state(Dictionary(current.get("safe_mode_state", {})))
	current["quarantine_registry"] = _normalize_reports(Array(current.get("quarantine_registry", [])))
	current["constitution_history"] = _normalize_history(Array(current.get("constitution_history", [])))
	current["stability_reports"] = _normalize_reports(Array(current.get("stability_reports", [])))
	current["anti_bottleneck_reports"] = _normalize_reports(Array(current.get("anti_bottleneck_reports", [])))
	current["play_routing_reports"] = _normalize_reports(Array(current.get("play_routing_reports", [])))
	current["court_decisions"] = _normalize_reports(Array(current.get("court_decisions", [])))
	current["meta_reflection_reports"] = _normalize_reports(Array(current.get("meta_reflection_reports", [])))
	current["contradiction_records"] = _normalize_reports(Array(current.get("contradiction_records", [])))
	current["fairness_trigger_records"] = _normalize_reports(Array(current.get("fairness_trigger_records", [])))
	current["dignity_trigger_records"] = _normalize_reports(Array(current.get("dignity_trigger_records", [])))
	current["normalization_records"] = _normalize_reports(Array(current.get("normalization_records", [])))
	current["rollback_candidates"] = _normalize_reports(Array(current.get("rollback_candidates", [])))
	current["saturation_reports"] = _normalize_reports(Array(current.get("saturation_reports", [])))
	current["dominance_strain_reports"] = _normalize_reports(Array(current.get("dominance_strain_reports", [])))
	current["throttle_records"] = _normalize_reports(Array(current.get("throttle_records", [])))
	current["fairness_veto_registry"] = _normalize_reports(Array(current.get("fairness_veto_registry", [])))
	current["dignity_veto_registry"] = _normalize_reports(Array(current.get("dignity_veto_registry", [])))
	current["rollback_registry"] = _normalize_reports(Array(current.get("rollback_registry", [])))
	current["exploit_absorption_reports"] = _normalize_reports(Array(current.get("exploit_absorption_reports", [])))
	current["meta_collapse_reports"] = _normalize_reports(Array(current.get("meta_collapse_reports", [])))
	current["resurrection_priority"] = _normalize_resurrection_priority(Dictionary(current.get("resurrection_priority", {})))
	current["truth_resolution_defaults"] = Dictionary(current.get("truth_resolution_defaults", {})).duplicate(true)
	return current

static func normalize_activation_state(raw: Dictionary) -> Dictionary:
	var current := _default_activation_state()
	for key in raw.keys():
		current[key] = raw[key]
	current["epoch"] = str(current.get("epoch", "activated")).strip_edges()
	if current["epoch"].is_empty():
		current["epoch"] = "activated"
	current["active_channels"] = _string_array(current.get("active_channels", []))
	current["dormant_channels"] = _string_array(current.get("dormant_channels", []))
	current["safe_mode_active"] = bool(current.get("safe_mode_active", false))
	current["quarantine_ids"] = _string_array(current.get("quarantine_ids", []))
	current["activation_lines"] = _slice_strings(_string_array(current.get("activation_lines", [])), MAX_LINES)
	return current

static func normalize_safe_mode_state(raw: Dictionary) -> Dictionary:
	var current := _default_safe_mode_state()
	for key in raw.keys():
		current[key] = raw[key]
	current["enabled"] = bool(current.get("enabled", false))
	current["reason"] = str(current.get("reason", "")).strip_edges()
	current["fallback_constitution_id"] = str(current.get("fallback_constitution_id", "")).strip_edges()
	current["cooling_tags"] = _string_array(current.get("cooling_tags", []))
	current["summary_lines"] = _slice_strings(_string_array(current.get("summary_lines", [])), MAX_LINES)
	return current

static func evaluate_planning_state(governance_state: Dictionary, world_model: Dictionary, theory_surface: Dictionary, civilization_surface: Dictionary, contradiction_packet: Dictionary, cookbook_state: Dictionary) -> Dictionary:
	var current := normalize(governance_state)
	var contradiction_records := _normalize_reports(Array(contradiction_packet.get("records", [])))
	var anti_bottleneck_report := Dictionary(contradiction_packet.get("anti_bottleneck_report", {})).duplicate(true)
	var play_routing_report := Dictionary(contradiction_packet.get("play_routing_report", {})).duplicate(true)
	var meta_reflection_report := Dictionary(contradiction_packet.get("meta_reflection_report", {})).duplicate(true)
	var active_channels: Array[String] = ["constitution", "archive", "world_memory", "inquiry", "theory", "cognitive_field", "contradiction"]
	if not _string_array(civilization_surface.get("faction_ids", [])).is_empty():
		active_channels.append("factions")
	if not _string_array(civilization_surface.get("world_mutation_ids", [])).is_empty():
		active_channels.append("world_mutation")
	if int(cookbook_state.get("fragment_count", 0)) >= 1 or not _string_array(cookbook_state.get("unauthorized_theory_ids", [])).is_empty():
		active_channels.append("cookbook")
	var quarantine_registry: Array[Dictionary] = []
	var quarantine_ids: Array[String] = []
	for theory in _dict_array(theory_surface.get("theories", [])):
		var theory_id := str(Dictionary(theory).get("theory_id", "")).strip_edges()
		var status := str(Dictionary(theory).get("status", "")).strip_edges()
		if theory_id.is_empty():
			continue
		if status == "suppressed":
			quarantine_ids.append(theory_id)
			quarantine_registry.append({
				"entry_id": "quarantine_%s" % theory_id,
				"status": "quarantined",
				"summary_lines": ["%s remains quarantined until contradiction pressure cools" % theory_id.replace("_", " ")]
			})
	if int(Dictionary(cookbook_state.get("power_envelope", {})).get("instability", 0)) >= 6:
		quarantine_ids.append("cookbook_fragment_network")
		quarantine_registry.append({
			"entry_id": "quarantine_cookbook_network",
			"status": "quarantined",
			"summary_lines": ["cookbook escalation is quarantined from clean promotion until doctrine stress drops"]
		})
	var safe_mode_enabled := false
	var safe_mode_reason := ""
	if str(play_routing_report.get("status", "stable")).strip_edges() == "blocked":
		safe_mode_enabled = true
		safe_mode_reason = "play-routing coverage failed"
	elif str(anti_bottleneck_report.get("status", "stable")).strip_edges() == "blocked" and quarantine_ids.size() >= 2:
		safe_mode_enabled = true
		safe_mode_reason = "theory monopoly and quarantine pressure are colliding"
	elif contradiction_records.size() >= 3 and int(Dictionary(cookbook_state.get("power_envelope", {})).get("doctrine_stress", 0)) >= 5:
		safe_mode_enabled = true
		safe_mode_reason = "contradiction and cookbook stress exceeded the cooling threshold"
	var safe_mode_state := normalize_safe_mode_state({
		"enabled": safe_mode_enabled,
		"reason": safe_mode_reason,
		"cooling_tags": ["theory", "cookbook", "world_mutation"] if safe_mode_enabled else [],
		"summary_lines": ["safe mode is cooling contested doctrine layers" if safe_mode_enabled else "safe mode is standing by while active governance remains stable"]
	})
	if safe_mode_enabled and not active_channels.has("safe_mode"):
		active_channels.append("safe_mode")
	var active_unique := _string_array(active_channels)
	var dormant_channels: Array[String] = []
	for channel in ALL_CHANNELS:
		if not active_unique.has(channel):
			dormant_channels.append(channel)
	var activation_state := normalize_activation_state({
		"epoch": "cooled" if safe_mode_enabled else "fully_active",
		"active_channels": active_unique,
		"dormant_channels": dormant_channels,
		"safe_mode_active": safe_mode_enabled,
		"quarantine_ids": quarantine_ids,
		"activation_lines": [
			"active channels: %s" % ", ".join(active_unique),
			"quarantine count: %d" % quarantine_ids.size(),
			"court posture: %s" % ("cool and quarantine" if safe_mode_enabled else "promote and contest")
		]
	})
	var stability_report := {
		"report_id": "stability_%s" % str(active_unique.size()),
		"status": "cooling" if safe_mode_enabled else "stable",
		"summary_lines": ["governance %s while preserving runtime truth boundaries" % ("entered cooling mode" if safe_mode_enabled else "kept all high layers active")]
	}
	var court_decision := {
		"decision_id": "court_%s" % str(active_unique.size()),
		"status": "cooling" if safe_mode_enabled else "promote",
		"summary_lines": [
			"court %s" % ("ordered cooling and quarantine for unstable doctrine carriers" if safe_mode_enabled else "authorized active multi-theory governance under continued review")
		]
	}
	current["truth_resolution_defaults"] = {
		"authority_epoch": "compile_pre_start",
		"owner_lane": "compile",
		"resolution_class": "authoritative",
		"visibility_class": "mixed_partitioned",
		"contradiction_disposition": "cooled_review" if safe_mode_enabled else "stable_surface",
		"allowed_consumers": ["runtime", "report", "bundle", "persistence", "reload", "tests"],
		"derivation_policy": "subset_copy_public_safe",
		"failure_codes": ["runtime_truth_override", "public_operator_ref_leak", "untraceable_summary_field"],
		"summary_lines": [
			"compile truth remains authoritative until runtime ownership begins",
			"contradiction review stays explanatory and never rewrites live truth"
		]
	}
	current["activation_state"] = activation_state
	current["safe_mode_state"] = safe_mode_state
	current["quarantine_registry"] = _normalize_reports(quarantine_registry)
	current["stability_reports"] = _prepend_report(Array(current.get("stability_reports", [])), stability_report)
	current["anti_bottleneck_reports"] = _prepend_report(Array(current.get("anti_bottleneck_reports", [])), anti_bottleneck_report)
	current["play_routing_reports"] = _prepend_report(Array(current.get("play_routing_reports", [])), play_routing_report)
	current["court_decisions"] = _prepend_report(Array(current.get("court_decisions", [])), court_decision)
	current["meta_reflection_reports"] = _prepend_report(Array(current.get("meta_reflection_reports", [])), meta_reflection_report)
	current["contradiction_records"] = _normalize_reports(contradiction_records)
	return normalize(current)

static func normalize_signal_compression_profile(raw: Dictionary) -> Dictionary:
	var current := {
		"schema_name": "SignalCompressionProfile",
		"schema_version": SIGNAL_COMPRESSION_SCHEMA_VERSION,
		"max_visible_channels": 3,
		"max_lines_per_layer": 2,
		"max_total_lines": MAX_LINES,
		"drop_policy": "priority_then_truncate",
		"residue_budget": 2,
		"max_major_vfx_layers": 3,
		"telegraph_priority": ["immediate", "run", "meta"],
		"warning_flags": [],
		"drop_counts": {
			"immediate": 0,
			"run": 0,
			"meta": 0,
			"summary": 0,
			"operator": 0
		}
	}
	for key in raw.keys():
		current[key] = raw[key]
	current["max_visible_channels"] = clampi(int(current.get("max_visible_channels", 3)), 1, 4)
	current["max_lines_per_layer"] = clampi(int(current.get("max_lines_per_layer", 2)), 1, MAX_LINES)
	current["max_total_lines"] = clampi(int(current.get("max_total_lines", MAX_LINES)), 1, MAX_LINES)
	current["drop_policy"] = str(current.get("drop_policy", "priority_then_truncate")).strip_edges()
	if current["drop_policy"].is_empty():
		current["drop_policy"] = "priority_then_truncate"
	current["residue_budget"] = clampi(int(current.get("residue_budget", 2)), 0, 3)
	current["max_major_vfx_layers"] = clampi(int(current.get("max_major_vfx_layers", 3)), 0, 3)
	current["telegraph_priority"] = _slice_strings(current.get("telegraph_priority", ["immediate", "run", "meta"]), 6)
	current["warning_flags"] = _slice_strings(current.get("warning_flags", []), 8)
	var drop_counts: Dictionary = Dictionary(current.get("drop_counts", {})).duplicate(true)
	var normalized_drop_counts := {}
	for lane_id in ["immediate", "run", "meta", "summary", "operator"]:
		normalized_drop_counts[lane_id] = maxi(int(drop_counts.get(lane_id, 0)), 0)
	current["drop_counts"] = normalized_drop_counts
	current["cognitive_budget_envelope"] = {
		"schema_name": "CognitiveBudgetEnvelope",
		"schema_version": 1,
		"budget_id": str(raw.get("budget_id", "signal_public_safe")).strip_edges(),
		"constitution_hash": str(raw.get("constitution_hash", "")).strip_edges(),
		"explanation_budget": {
			"max_lines_per_layer": int(current.get("max_lines_per_layer", 2)),
			"max_total_lines": int(current.get("max_total_lines", MAX_LINES)),
			"telegraph_priority": Array(current.get("telegraph_priority", [])).duplicate(true),
			"drop_policy": str(current.get("drop_policy", "priority_then_truncate")).strip_edges(),
			"drop_counts": Dictionary(current.get("drop_counts", {})).duplicate(true)
		},
		"visual_budget": {
			"max_visible_channels": int(current.get("max_visible_channels", 3)),
			"residue_budget": int(current.get("residue_budget", 2)),
			"max_major_vfx_layers": int(current.get("max_major_vfx_layers", 3))
		},
		"onboarding_budget": {
			"home_overview_lines_max": 8,
			"progression_preview_lines_max": 8,
			"profile_card_lines_max": 4,
			"reentry_summary_lines_max": 8
		},
		"warning_flags": Array(current.get("warning_flags", [])).duplicate(true),
		"failure_codes": []
	}
	return current

static func build_truth_resolution_envelope(source: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
	var subject_id := str(options.get("subject_id", source.get("subject_id", source.get("packet_id", source.get("constitution_id", source.get("constitution_hash", "")))))).strip_edges()
	var subject_kind := str(options.get("subject_kind", source.get("subject_kind", "explanation_packet"))).strip_edges()
	if subject_kind.is_empty():
		subject_kind = "explanation_packet"
	var authority_epoch := str(options.get("authority_epoch", source.get("authority_epoch", "compile_pre_start"))).strip_edges()
	if not ["compile_pre_start", "runtime_live", "post_run_derived"].has(authority_epoch):
		authority_epoch = "compile_pre_start"
	var owner_lane := str(options.get("owner_lane", source.get("owner_lane", "compile"))).strip_edges()
	if not ["compile", "runtime", "report", "bundle", "persistence", "reload"].has(owner_lane):
		owner_lane = "compile"
	var resolution_class := str(options.get("resolution_class", source.get("resolution_class", "authoritative"))).strip_edges()
	if not ["authoritative", "derived", "contested_public", "operator_review", "bundle_only_reference"].has(resolution_class):
		resolution_class = "authoritative"
	var visibility_class := str(options.get("visibility_class", source.get("visibility_class", "mixed_partitioned"))).strip_edges()
	if not ["public", "private", "operator", "bundle_only", "mixed_partitioned"].has(visibility_class):
		visibility_class = "mixed_partitioned"
	var contradiction_disposition := str(options.get("contradiction_disposition", source.get("contradiction_disposition", "stable_surface"))).strip_edges()
	if not ["stable_surface", "public_contestation", "cooled_review"].has(contradiction_disposition):
		contradiction_disposition = "stable_surface"
	var derivation_policy := str(options.get("derivation_policy", source.get("derivation_policy", "subset_copy_public_safe"))).strip_edges()
	if not ["copy_only", "subset_copy_public_safe", "digest_only", "commentary_only"].has(derivation_policy):
		derivation_policy = "subset_copy_public_safe"
	var allowed_consumers := _slice_strings(
		_string_array(options.get("allowed_consumers", source.get("allowed_consumers", ["runtime", "report", "bundle", "persistence", "reload", "tests"]))),
		8
	)
	var source_digest := str(options.get("source_digest", source.get("source_digest", source.get("packet_digest", "")))).strip_edges()
	var source_constitution_hash := str(options.get("source_constitution_hash", source.get("source_constitution_hash", source.get("constitution_hash", "")))).strip_edges()
	var source_refs := _slice_strings(
		_string_array(options.get("source_refs", source.get("source_refs", source.get("provenance_source_refs", [])))),
		8
	)
	var public_summary_refs := _slice_strings(
		_string_array(options.get("public_summary_refs", source.get("public_summary_refs", ["summary_lines", "immediate", "run", "meta", "public_surface_tags"]))),
		8
	)
	var operator_refs := _slice_strings(
		_string_array(options.get("operator_refs", source.get("operator_refs", ["operator_lines", "provenance_source_refs"]))),
		8
	)
	var failure_codes := _slice_strings(
		_string_array(options.get("failure_codes", source.get("failure_codes", ["runtime_truth_override", "public_operator_ref_leak", "untraceable_summary_field"]))),
		8
	)
	var envelope_seed := "%s|%s|%s|%s|%s" % [subject_id, subject_kind, authority_epoch, owner_lane, source_digest]
	return {
		"schema_name": "TruthResolutionEnvelope",
		"schema_version": TRUTH_RESOLUTION_ENVELOPE_SCHEMA_VERSION,
		"envelope_id": "truth_resolution_%s" % envelope_seed.md5_text().substr(0, 12),
		"subject_id": subject_id,
		"subject_kind": subject_kind,
		"authority_epoch": authority_epoch,
		"owner_lane": owner_lane,
		"resolution_class": resolution_class,
		"visibility_class": visibility_class,
		"source_constitution_hash": source_constitution_hash,
		"source_digest": source_digest,
		"source_refs": source_refs,
		"public_summary_refs": public_summary_refs,
		"operator_refs": operator_refs,
		"contradiction_disposition": contradiction_disposition,
		"allowed_consumers": allowed_consumers,
		"derivation_policy": derivation_policy,
		"failure_codes": failure_codes
	}

static func derive_truth_resolution_envelope(base_envelope: Dictionary, overrides: Dictionary = {}) -> Dictionary:
	var current := Dictionary(base_envelope).duplicate(true)
	for key in overrides.keys():
		current[key] = overrides[key]
	return build_truth_resolution_envelope(current, current)

static func build_governance_hook_set(governance_state: Dictionary, constitution_summary: Dictionary = {}, explanation_packet: Dictionary = {}) -> Dictionary:
	var current := normalize(governance_state)
	var activation_state: Dictionary = normalize_activation_state(Dictionary(current.get("activation_state", {})))
	var safe_mode_state: Dictionary = normalize_safe_mode_state(Dictionary(current.get("safe_mode_state", {})))
	var packet := Dictionary(explanation_packet).duplicate(true)
	packet["packet_schema_version"] = int(packet.get("packet_schema_version", PACKET_SCHEMA_VERSION))
	packet["packet_digest"] = str(packet.get("packet_digest", "")).strip_edges()
	return {
		"schema_name": "GovernanceHookSet",
		"schema_version": GOVERNANCE_HOOK_SCHEMA_VERSION,
		"activation_epoch": str(activation_state.get("epoch", "inactive")).strip_edges(),
		"active_channels": _slice_strings(activation_state.get("active_channels", []), 12),
		"dormant_channels": _slice_strings(activation_state.get("dormant_channels", []), 12),
		"safe_mode_active": bool(activation_state.get("safe_mode_active", false)),
		"quarantine_ids": _slice_strings(activation_state.get("quarantine_ids", []), 12),
		"safe_mode_reason": str(safe_mode_state.get("reason", "")).strip_edges(),
		"packet_id": str(packet.get("packet_id", "")).strip_edges(),
		"packet_schema_version": int(packet.get("packet_schema_version", PACKET_SCHEMA_VERSION)),
		"packet_digest": str(packet.get("packet_digest", "")).strip_edges(),
		"fairness_flags": _slice_strings(packet.get("fairness_flags", []), 8),
		"priority_channels": _slice_strings(packet.get("priority_channels", []), 6),
		"available_actions": ["observe", "normalize", "throttle", "quarantine", "rollback", "veto"],
		"trigger_slots": {
			"fairness": _report_ids(Array(current.get("fairness_trigger_records", []))),
			"dignity": _report_ids(Array(current.get("dignity_trigger_records", []))),
			"normalization": _report_ids(Array(current.get("normalization_records", []))),
			"rollback": _report_ids(Array(current.get("rollback_candidates", []))),
			"throttle": _report_ids(Array(current.get("throttle_records", []))),
			"fairness_veto": _report_ids(Array(current.get("fairness_veto_registry", []))),
			"dignity_veto": _report_ids(Array(current.get("dignity_veto_registry", []))),
			"meta_collapse": _report_ids(Array(current.get("meta_collapse_reports", [])))
		},
		"resurrection_candidates": _slice_strings(Dictionary(current.get("resurrection_priority", {})).get("candidate_ids", []), 6),
		"summary_lines": _slice_strings([
			_first_non_empty([
				_first_string(activation_state.get("activation_lines", []), ""),
				_first_string(Dictionary(constitution_summary).get("activation_lines", []), ""),
				_first_string(Dictionary(constitution_summary).get("review_surface_lines", []), "")
			]),
			_first_non_empty([
				_first_string(safe_mode_state.get("summary_lines", []), ""),
				_first_string(Dictionary(constitution_summary).get("safe_mode_lines", []), "")
			]),
			_first_string(packet.get("summary_lines", []), "")
		], 3)
	}

static func build_forensic_action_snapshot(governance_state: Dictionary) -> Dictionary:
	var current := normalize(governance_state)
	var fairness_triggers := _report_ids(Array(current.get("fairness_trigger_records", [])))
	if fairness_triggers.is_empty():
		fairness_triggers = _report_ids(Array(current.get("fairness_veto_registry", [])))
	var dignity_triggers := _report_ids(Array(current.get("dignity_trigger_records", [])))
	if dignity_triggers.is_empty():
		dignity_triggers = _report_ids(Array(current.get("dignity_veto_registry", [])))
	var dominant_strategy_strain := {
		"report_ids": _report_ids(Array(current.get("dominance_strain_reports", []))),
		"meta_collapse_ids": _report_ids(Array(current.get("meta_collapse_reports", []))),
		"summary_lines": _summary_lines_for_reports(Array(current.get("dominance_strain_reports", [])), 2)
	}
	return {
		"fairness_triggers": fairness_triggers,
		"dignity_triggers": dignity_triggers,
		"rollback_action": _forensic_action_record(Array(current.get("rollback_registry", [])), "rollback_review"),
		"quarantine_action": _forensic_action_record(Array(current.get("quarantine_registry", [])), "quarantined"),
		"dominant_strategy_strain": dominant_strategy_strain
	}

static func build_explanation_packet(source: Dictionary, summary_lines: Array = [], operator_lines: Array = [], play_routing_tags: Array = [], lane_entries: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
	var artifact_type := str(source.get("artifact_type", "governance_packet")).strip_edges()
	var packet_id_seed := "%s|%s|%s" % [
		artifact_type,
		str(source.get("constitution_id", source.get("constitution_hash", source.get("entry_id", "")))).strip_edges(),
		str(source.get("packet_id", "")).strip_edges()
	]
	if packet_id_seed.strip_edges().is_empty():
		packet_id_seed = JSON.stringify(source)
	var immediate := _normalize_explanation_layer(Array(lane_entries.get("immediate", [])))
	var run_lane := _normalize_explanation_layer(Array(lane_entries.get("run", [])))
	var meta := _normalize_explanation_layer(Array(lane_entries.get("meta", [])))
	if immediate.is_empty():
		immediate = _derive_explanation_lane_entries(summary_lines, "immediate")
	if run_lane.is_empty():
		run_lane = _derive_explanation_lane_entries(summary_lines + play_routing_tags, "run")
	if meta.is_empty():
		meta = _derive_explanation_lane_entries(operator_lines, "meta")
	var compression_profile := normalize_signal_compression_profile({
		"max_visible_channels": int(options.get("max_visible_channels", 3)),
		"max_lines_per_layer": int(options.get("max_lines_per_layer", 2)),
		"max_total_lines": int(options.get("max_total_lines", MAX_LINES)),
		"drop_policy": str(options.get("drop_policy", "priority_then_truncate")),
		"residue_budget": int(options.get("residue_budget", 2)),
		"telegraph_priority": options.get("priority_channels", ["immediate", "run", "meta"])
	})
	var packet_summary_lines := _slice_strings(
		_string_array(summary_lines) if not _string_array(summary_lines).is_empty() else _derived_lane_lines(immediate, run_lane, meta),
		int(compression_profile.get("max_total_lines", MAX_LINES))
	)
	var packet_operator_lines := _slice_strings(
		_string_array(operator_lines) if not _string_array(operator_lines).is_empty() else _derived_operator_lines(meta, run_lane),
		int(compression_profile.get("max_total_lines", MAX_LINES))
	)
	var drop_counts: Dictionary = Dictionary(compression_profile.get("drop_counts", {})).duplicate(true)
	drop_counts["immediate"] = maxi(immediate.size() - int(compression_profile.get("max_lines_per_layer", 2)), 0)
	drop_counts["run"] = maxi(run_lane.size() - int(compression_profile.get("max_lines_per_layer", 2)), 0)
	drop_counts["meta"] = maxi(meta.size() - int(compression_profile.get("max_lines_per_layer", 2)), 0)
	drop_counts["summary"] = maxi(_string_array(summary_lines).size() - packet_summary_lines.size(), 0)
	drop_counts["operator"] = maxi(_string_array(operator_lines).size() - packet_operator_lines.size(), 0)
	compression_profile["drop_counts"] = drop_counts
	var packet := {
		"packet_id": "packet_%s" % packet_id_seed.md5_text().substr(0, 12),
		"artifact_type": artifact_type,
		"packet_schema_version": PACKET_SCHEMA_VERSION,
		"provenance_contract_version": PROVENANCE_CONTRACT_VERSION,
		"summary_lines": packet_summary_lines,
		"operator_lines": packet_operator_lines,
		"play_routing_tags": _string_array(play_routing_tags),
		"public_surface_tags": _string_array(options.get("public_surface_tags", play_routing_tags)),
		"provenance_source_refs": _string_array(options.get("provenance_source_refs", [
			"constitution_summary",
			"explanation_packet",
			"governance_state"
		])),
		"play_routing_contract": {
			"baseline_routes": _string_array(play_routing_tags),
			"artifact_type": artifact_type
		},
		"compression_profile": compression_profile,
		"priority_channels": _slice_strings(options.get("priority_channels", ["immediate", "run", "meta"]), 6),
		"fairness_flags": _slice_strings(options.get("fairness_flags", []), 8),
		"immediate": immediate.slice(0, int(compression_profile.get("max_lines_per_layer", 2))),
		"run": run_lane.slice(0, int(compression_profile.get("max_lines_per_layer", 2))),
		"meta": meta.slice(0, int(compression_profile.get("max_lines_per_layer", 2)))
	}
	var digest_source := packet.duplicate(true)
	digest_source.erase("packet_digest")
	packet["packet_digest"] = _canonical_string(digest_source).md5_text()
	var truth_resolution_defaults := Dictionary(source.get("truth_resolution_defaults", options.get("truth_resolution", {}))).duplicate(true)
	packet["truth_resolution_envelope"] = build_truth_resolution_envelope(
		{
			"packet_id": packet["packet_id"],
			"constitution_hash": str(options.get("source_constitution_hash", source.get("constitution_hash", ""))).strip_edges(),
			"packet_digest": packet["packet_digest"],
			"provenance_source_refs": packet["provenance_source_refs"]
		},
		{
			"subject_id": str(packet.get("packet_id", "")).strip_edges(),
			"subject_kind": "explanation_packet",
			"authority_epoch": str(truth_resolution_defaults.get("authority_epoch", "compile_pre_start")).strip_edges(),
			"owner_lane": str(truth_resolution_defaults.get("owner_lane", "compile")).strip_edges(),
			"resolution_class": str(truth_resolution_defaults.get("resolution_class", "authoritative")).strip_edges(),
			"visibility_class": str(truth_resolution_defaults.get("visibility_class", "mixed_partitioned")).strip_edges(),
			"contradiction_disposition": str(truth_resolution_defaults.get("contradiction_disposition", "stable_surface")).strip_edges(),
			"allowed_consumers": Array(truth_resolution_defaults.get("allowed_consumers", ["runtime", "report", "bundle", "persistence", "reload", "tests"])).duplicate(true),
			"derivation_policy": str(truth_resolution_defaults.get("derivation_policy", "subset_copy_public_safe")).strip_edges(),
			"public_summary_refs": Array(options.get("public_summary_refs", ["summary_lines", "immediate", "run", "meta", "public_surface_tags"])).duplicate(true),
			"operator_refs": Array(options.get("operator_refs", ["operator_lines", "provenance_source_refs"])).duplicate(true),
			"failure_codes": Array(truth_resolution_defaults.get("failure_codes", ["runtime_truth_override", "public_operator_ref_leak", "untraceable_summary_field"])).duplicate(true)
		}
	)
	return packet

static func _forensic_action_record(reports: Array, fallback_status: String) -> Dictionary:
	var normalized := _dict_array(reports)
	if normalized.is_empty():
		return {}
	var first_report: Dictionary = Dictionary(normalized[0]).duplicate(true)
	return {
		"report_id": str(first_report.get("report_id", first_report.get("entry_id", first_report.get("decision_id", first_report.get("reflection_id", ""))))).strip_edges(),
		"status": str(first_report.get("status", fallback_status)).strip_edges(),
		"summary_lines": _summary_lines_for_reports(normalized, 2)
	}

static func _summary_lines_for_reports(reports: Array, limit: int) -> Array[String]:
	var result: Array[String] = []
	for report_raw in _dict_array(reports):
		var report := Dictionary(report_raw)
		var line := _first_string(report.get("summary_lines", []), "")
		if line.is_empty():
			line = str(report.get("status", "")).strip_edges()
		if not line.is_empty() and not result.has(line):
			result.append(line)
		if result.size() >= limit:
			break
	return result

static func build_review_surface(governance_state: Dictionary, theory_surface: Dictionary = {}) -> Dictionary:
	var current := normalize(governance_state)
	var lines: Array[String] = []
	var truth_resolution_defaults: Dictionary = Dictionary(current.get("truth_resolution_defaults", {})).duplicate(true)
	var truth_resolution_line := _first_string(Array(truth_resolution_defaults.get("summary_lines", [])), "")
	if not truth_resolution_line.is_empty():
		lines.append(truth_resolution_line)
	var promotion_review := _promotion_review(theory_surface)
	var promotion_line := str(promotion_review.get("summary_line", "")).strip_edges()
	if not promotion_line.is_empty():
		lines.append(promotion_line)
	for report_key in [
		"stability_reports",
		"anti_bottleneck_reports",
		"play_routing_reports",
		"court_decisions",
		"meta_reflection_reports",
		"saturation_reports",
		"dominance_strain_reports",
		"throttle_records",
		"exploit_absorption_reports",
		"meta_collapse_reports",
		"fairness_veto_registry",
		"dignity_veto_registry"
	]:
		var reports := _dict_array(current.get(report_key, []))
		if not reports.is_empty():
			lines.append(_first_string(Dictionary(reports[0]).get("summary_lines", []), "review report present"))
	if bool(Dictionary(current.get("safe_mode_state", {})).get("enabled", false)):
		lines.append(_first_string(Dictionary(current.get("safe_mode_state", {})).get("summary_lines", []), "safe mode remains active"))
	lines = _slice_strings(lines + _string_array(Dictionary(current.get("resurrection_priority", {})).get("summary_lines", [])), MAX_LINES)
	return {
		"lines": lines,
		"active_channels": _string_array(Dictionary(current.get("activation_state", {})).get("active_channels", [])),
		"dormant_channels": _string_array(Dictionary(current.get("activation_state", {})).get("dormant_channels", [])),
		"promotion_review": promotion_review.duplicate(true)
	}

static func apply_post_run(governance_state: Dictionary, run_record: Dictionary, diagnostics: Dictionary, frame: Dictionary, constitution_summary: Dictionary) -> Dictionary:
	var current := normalize(governance_state)
	var constitution_id := str(constitution_summary.get("constitution_id", constitution_summary.get("constitution_hash", ""))).strip_edges()
	var doctrine_goal := str(diagnostics.get("doctrine_world_goal", constitution_summary.get("world_goal", ""))).strip_edges()
	var pressure_line := str(diagnostics.get("doctrine_pressure_line", constitution_summary.get("pressure_line", ""))).strip_edges()
	if not constitution_id.is_empty():
		var history := _dict_array(current.get("constitution_history", []))
		history.push_front({
			"constitution_id": constitution_id,
			"constitution_hash": str(constitution_summary.get("constitution_hash", "")).strip_edges(),
			"doctrine_family": str(constitution_summary.get("doctrine_family", diagnostics.get("doctrine_family", ""))).strip_edges(),
			"world_goal": doctrine_goal,
			"pressure_line": pressure_line,
			"seed": int(run_record.get("seed", 0)),
			"summary_lines": [pressure_line if not pressure_line.is_empty() else doctrine_goal]
		})
		current["constitution_history"] = history.slice(0, MAX_HISTORY)
	var activation_state := normalize_activation_state({
		"epoch": str(constitution_summary.get("activation_epoch", "activated")).strip_edges(),
		"active_channels": _string_array(constitution_summary.get("activation_active_channels", [])),
		"dormant_channels": _string_array(constitution_summary.get("activation_dormant_channels", [])),
		"safe_mode_active": bool(constitution_summary.get("safe_mode_active", false)),
		"activation_lines": _string_array(constitution_summary.get("activation_lines", []))
	})
	var safe_mode_state := normalize_safe_mode_state({
		"enabled": bool(constitution_summary.get("safe_mode_active", false)),
		"reason": _first_string(constitution_summary.get("safe_mode_lines", []), ""),
		"summary_lines": _string_array(constitution_summary.get("safe_mode_lines", []))
	})
	var theory_statuses := _string_array(diagnostics.get("theory_statuses", []))
	var expedition_constitution: Dictionary = Dictionary(run_record.get("expedition_constitution", {}))
	var lifecycle_registry: Dictionary = Dictionary(expedition_constitution.get("lifecycle_registry", {})).duplicate(true)
	var lifecycle_families := _sorted_lifecycle_families(lifecycle_registry, constitution_summary)
	var fairness_flags := _string_array(diagnostics.get("fairness_flags", []))
	var dignity_flags := _string_array(diagnostics.get("dignity_flags", []))
	var saturation_reports: Array[Dictionary] = []
	var dominance_strain_reports: Array[Dictionary] = []
	var throttle_records: Array[Dictionary] = []
	var exploit_absorption_reports: Array[Dictionary] = []
	var meta_collapse_reports: Array[Dictionary] = []
	var fairness_veto_registry: Array[Dictionary] = []
	var dignity_veto_registry: Array[Dictionary] = []
	var rollback_registry: Array[Dictionary] = []
	var rollback_candidates: Array[Dictionary] = []
	var contradiction_records: Array[Dictionary] = []
	if theory_statuses.has("rival") or theory_statuses.has("cookbook") or theory_statuses.has("anomaly"):
		contradiction_records.append({
			"record_id": "run_contradiction_%s" % str(run_record.get("seed", 0)),
			"status": "active",
			"summary_lines": ["the completed run preserved visible contradiction between active doctrine carriers"]
		})
	for family_raw in lifecycle_families:
		var family: Dictionary = Dictionary(family_raw)
		var family_id := str(family.get("family_id", "")).strip_edges()
		if family_id.is_empty():
			continue
		var saturation := int(family.get("saturation", 0))
		var strain := maxi(int(family.get("strain", 0)), int(family.get("dominance_strain", 0)))
		var successor_hint := str(family.get("successor_hint", "")).strip_edges()
		if saturation >= 4:
			saturation_reports.append({
				"report_id": "saturation_%s_%s" % [family_id, str(run_record.get("seed", 0))],
				"status": "cooling",
				"summary_lines": ["%s is saturating hard enough to require cooling before the next constitution" % family_id.replace("_", " ")]
			})
			throttle_records.append({
				"report_id": "throttle_%s_%s" % [family_id, str(run_record.get("seed", 0))],
				"status": "cooling",
				"summary_lines": ["throttle %s through cooling and successor drift" % family_id.replace("_", " ")]
			})
		if strain >= 4:
			dominance_strain_reports.append({
				"report_id": "dominance_%s_%s" % [family_id, str(run_record.get("seed", 0))],
				"status": "warning",
				"summary_lines": ["%s is pulling too much doctrine weight for one family line" % family_id.replace("_", " ")]
			})
			exploit_absorption_reports.append({
				"report_id": "absorb_%s_%s" % [family_id, str(run_record.get("seed", 0))],
				"status": "cooling",
				"summary_lines": ["exploit absorption is redirecting %s toward %s" % [
					family_id.replace("_", " "),
					successor_hint.replace("_", " ") if not successor_hint.is_empty() else "a cooler successor weave"
				]]
			})
	if lifecycle_families.size() >= 3:
		var dominant_family: Dictionary = Dictionary(lifecycle_families[0])
		var dominant_kind := str(dominant_family.get("family_kind", "")).strip_edges()
		var same_kind_count := 0
		for family_raw in lifecycle_families:
			if str(Dictionary(family_raw).get("family_kind", "")).strip_edges() == dominant_kind:
				same_kind_count += 1
		if (same_kind_count >= 2 or maxi(int(dominant_family.get("strain", 0)), int(dominant_family.get("dominance_strain", 0))) >= 5) and maxi(int(dominant_family.get("strain", 0)), int(dominant_family.get("dominance_strain", 0))) >= 4:
			meta_collapse_reports.append({
				"report_id": "meta_collapse_%s_%s" % [dominant_kind, str(run_record.get("seed", 0))],
				"status": "warning",
				"summary_lines": ["meta collapse risk is rising because %s families are monopolizing the current doctrine climate" % dominant_kind.replace("_", " ")]
			})
	if int(diagnostics.get("consensus_risk", 0)) >= 3 and fairness_flags.is_empty():
		fairness_flags.append("consensus_pressure")
	if int(diagnostics.get("spectacle_pressure", 0)) >= 3 and dignity_flags.is_empty():
		dignity_flags.append("spectacle_burden")
	for fairness_flag in fairness_flags:
		fairness_veto_registry.append({
			"report_id": "fairness_veto_%s_%s" % [fairness_flag, str(run_record.get("seed", 0))],
			"status": "warning",
			"summary_lines": ["fairness veto review is holding on %s" % fairness_flag.replace("_", " ")]
		})
	for dignity_flag in dignity_flags:
		dignity_veto_registry.append({
			"report_id": "dignity_veto_%s_%s" % [dignity_flag, str(run_record.get("seed", 0))],
			"status": "warning",
			"summary_lines": ["dignity veto review is holding on %s" % dignity_flag.replace("_", " ")]
		})
	if not fairness_veto_registry.is_empty() or not dignity_veto_registry.is_empty() or not meta_collapse_reports.is_empty():
		rollback_candidates.append({
			"report_id": "rollback_candidate_%s" % str(run_record.get("seed", 0)),
			"status": "warning",
			"summary_lines": ["rollback review is open while veto or meta-collapse pressure remains unresolved"]
		})
		rollback_registry.append({
			"report_id": "rollback_registry_%s" % str(run_record.get("seed", 0)),
			"status": "cooling",
			"summary_lines": ["rollback registry captured the current doctrine surface before promotion continues"]
		})
	current["activation_state"] = activation_state
	current["safe_mode_state"] = safe_mode_state
	current["contradiction_records"] = _normalize_reports(Array(current.get("contradiction_records", [])) + contradiction_records)
	current["stability_reports"] = _prepend_report(Array(current.get("stability_reports", [])), {
		"report_id": "stability_%s" % str(run_record.get("seed", 0)),
		"status": "cooling" if bool(safe_mode_state.get("enabled", false)) else "stable",
		"summary_lines": _slice_strings([
			_first_non_empty([
				_first_string(constitution_summary.get("review_surface_lines", []), ""),
				str(frame.get("governance_line", "")).strip_edges(),
				"post-run governance review completed"
			])
		], 1)
	})
	current["anti_bottleneck_reports"] = _prepend_report(Array(current.get("anti_bottleneck_reports", [])), {
		"report_id": "anti_bottleneck_%s" % str(run_record.get("seed", 0)),
		"status": "blocked" if theory_statuses.size() <= 1 else "stable",
		"summary_lines": ["post-run anti-bottleneck review %s" % ("found a theory monopoly risk" if theory_statuses.size() <= 1 else "kept plural theory pressure alive")]
	})
	current["play_routing_reports"] = _prepend_report(Array(current.get("play_routing_reports", [])), {
		"report_id": "play_routing_%s" % str(run_record.get("seed", 0)),
		"status": "stable",
		"baseline_routes": BASELINE_ROUTES.duplicate(),
		"summary_lines": ["advanced doctrine remained routed through embodied expedition play"]
	})
	current["court_decisions"] = _prepend_report(Array(current.get("court_decisions", [])), {
		"decision_id": "court_%s" % str(run_record.get("seed", 0)),
		"status": "cooling" if bool(safe_mode_state.get("enabled", false)) else "promote",
		"summary_lines": ["court %s" % ("kept cooling active for the next constitution" if bool(safe_mode_state.get("enabled", false)) else "left active doctrine channels in circulation for the next constitution")]
	})
	current["meta_reflection_reports"] = _prepend_report(Array(current.get("meta_reflection_reports", [])), {
		"reflection_id": "meta_%s" % str(run_record.get("seed", 0)),
		"status": "cooling" if bool(safe_mode_state.get("enabled", false)) else "stable",
		"summary_lines": [_first_non_empty([
			_first_string(diagnostics.get("review_surface_lines", []), ""),
			"meta reflection retained cumulative doctrine memory without rewriting run truth"
		])]
	})
	current["saturation_reports"] = _normalize_reports(saturation_reports + Array(current.get("saturation_reports", [])))
	current["dominance_strain_reports"] = _normalize_reports(dominance_strain_reports + Array(current.get("dominance_strain_reports", [])))
	current["throttle_records"] = _normalize_reports(throttle_records + Array(current.get("throttle_records", [])))
	current["exploit_absorption_reports"] = _normalize_reports(exploit_absorption_reports + Array(current.get("exploit_absorption_reports", [])))
	current["meta_collapse_reports"] = _normalize_reports(meta_collapse_reports + Array(current.get("meta_collapse_reports", [])))
	current["fairness_trigger_records"] = _normalize_reports(fairness_veto_registry + Array(current.get("fairness_trigger_records", [])))
	current["dignity_trigger_records"] = _normalize_reports(dignity_veto_registry + Array(current.get("dignity_trigger_records", [])))
	current["fairness_veto_registry"] = _normalize_reports(fairness_veto_registry + Array(current.get("fairness_veto_registry", [])))
	current["dignity_veto_registry"] = _normalize_reports(dignity_veto_registry + Array(current.get("dignity_veto_registry", [])))
	current["rollback_candidates"] = _normalize_reports(rollback_candidates + Array(current.get("rollback_candidates", [])))
	current["rollback_registry"] = _normalize_reports(rollback_registry + Array(current.get("rollback_registry", [])))
	current["resurrection_priority"] = _normalize_resurrection_priority(_build_resurrection_priority(lifecycle_families))
	return normalize(current)

static func _default_activation_state() -> Dictionary:
	return {
		"epoch": "activated",
		"active_channels": ["constitution", "archive", "world_memory", "inquiry", "theory", "cognitive_field"],
		"dormant_channels": ["cookbook", "factions", "world_mutation", "contradiction", "safe_mode"],
		"safe_mode_active": false,
		"quarantine_ids": [],
		"activation_lines": ["governance is prepared to promote doctrine carriers once their inputs appear"]
	}

static func _default_safe_mode_state() -> Dictionary:
	return {
		"enabled": false,
		"reason": "",
		"fallback_constitution_id": "",
		"cooling_tags": ["theory", "cookbook", "world_mutation"],
		"summary_lines": []
	}

static func _default_resurrection_priority() -> Dictionary:
	return {
		"schema_name": "ResurrectionPriority",
		"schema_version": 1,
		"candidate_ids": [],
		"summary_lines": []
	}

static func _normalize_history(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_raw in entries:
		var entry := Dictionary(entry_raw).duplicate(true)
		entry["constitution_id"] = str(entry.get("constitution_id", "")).strip_edges()
		entry["constitution_hash"] = str(entry.get("constitution_hash", "")).strip_edges()
		entry["doctrine_family"] = str(entry.get("doctrine_family", "")).strip_edges()
		entry["world_goal"] = str(entry.get("world_goal", "")).strip_edges()
		entry["pressure_line"] = str(entry.get("pressure_line", "")).strip_edges()
		entry["seed"] = int(entry.get("seed", 0))
		entry["summary_lines"] = _slice_strings(_string_array(entry.get("summary_lines", [])), MAX_LINES)
		if not entry["constitution_id"].is_empty():
			result.append(entry)
	return result.slice(0, MAX_HISTORY)

static func _normalize_reports(entries: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_raw in entries:
		var entry := Dictionary(entry_raw).duplicate(true)
		entry["status"] = str(entry.get("status", "stable")).strip_edges()
		if entry["status"].is_empty():
			entry["status"] = "stable"
		entry["summary_lines"] = _slice_strings(_string_array(entry.get("summary_lines", [])), MAX_LINES)
		result.append(entry)
	return result.slice(0, MAX_REPORTS)

static func _prepend_report(entries: Array, entry: Dictionary) -> Array[Dictionary]:
	var next := _dict_array(entries)
	next.push_front(entry)
	return _normalize_reports(next)

static func _normalize_resurrection_priority(raw: Dictionary) -> Dictionary:
	var current := _default_resurrection_priority()
	for key in raw.keys():
		current[key] = raw[key]
	current["candidate_ids"] = _slice_strings(current.get("candidate_ids", []), 8)
	current["summary_lines"] = _slice_strings(current.get("summary_lines", []), MAX_LINES)
	return current

static func _sorted_lifecycle_families(lifecycle_registry: Dictionary, constitution_summary: Dictionary) -> Array[Dictionary]:
	var families := _dict_array(lifecycle_registry.get("families", []))
	if families.is_empty():
		var fallback_id := _first_string(constitution_summary.get("lifecycle_state_ids", []), "market_balanced_exchange")
		families.append({
			"family_id": fallback_id,
			"family_kind": "market",
			"source_id": fallback_id,
			"state": "emerging",
			"heat": 1,
			"saturation": 1,
			"strain": 0,
			"dominance_strain": 0,
			"cooldown_band": "open",
			"successor_hint": fallback_id,
			"return_window": "near_horizon",
			"routing_tags": ["market", "return"],
			"throttle_state": "open",
			"resurrection_priority": 0
		})
	families.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_rank := int(a.get("heat", 0)) + int(a.get("saturation", 0)) + maxi(int(a.get("strain", 0)), int(a.get("dominance_strain", 0)))
		var b_rank := int(b.get("heat", 0)) + int(b.get("saturation", 0)) + maxi(int(b.get("strain", 0)), int(b.get("dominance_strain", 0)))
		if a_rank == b_rank:
			return str(a.get("family_id", "")) < str(b.get("family_id", ""))
		return a_rank > b_rank
	)
	return families

static func _build_resurrection_priority(lifecycle_families: Array[Dictionary]) -> Dictionary:
	var candidate_ids: Array[String] = []
	for family_raw in lifecycle_families:
		var family: Dictionary = Dictionary(family_raw)
		var family_id := str(family.get("family_id", "")).strip_edges()
		if family_id.is_empty():
			continue
		var state := str(family.get("state", "emerging")).strip_edges()
		var cooldown_band := str(family.get("cooldown_band", "open")).strip_edges()
		if state in ["cooling", "dormant", "recurring"] or cooldown_band in ["cooling", "deep_cooling", "warming"]:
			candidate_ids.append(family_id)
		elif int(family.get("resurrection_priority", 0)) >= 3:
			candidate_ids.append(family_id)
	return {
		"candidate_ids": candidate_ids.slice(0, 6),
		"summary_lines": ["resurrection priority is tracking %s for later return" % candidate_ids[0].replace("_", " ")] if not candidate_ids.is_empty() else []
	}

static func _promotion_review(theory_surface: Dictionary) -> Dictionary:
	var theories := _dict_array(Dictionary(theory_surface).get("theories", []))
	if theories.is_empty():
		return {}
	var eligible_count := 0
	var cooling_count := 0
	var contested_count := 0
	for theory_raw in theories:
		var theory := Dictionary(theory_raw)
		match str(theory.get("promotion_status", "")).strip_edges():
			"eligible":
				eligible_count += 1
			"cooling", "blocked":
				cooling_count += 1
			"contested":
				contested_count += 1
	var summary_line := ""
	if eligible_count > 0:
		summary_line = "promotion review kept %d admissible carrier%s ready" % [eligible_count, "" if eligible_count == 1 else "s"]
	else:
		summary_line = "promotion review is holding until admissible evidence stabilizes"
	var delayed_count := cooling_count + contested_count
	if delayed_count > 0:
		summary_line += "; %d line%s stay cooling or contested" % [delayed_count, "" if delayed_count == 1 else "s"]
	return {
		"eligible_count": eligible_count,
		"cooling_count": cooling_count,
		"contested_count": contested_count,
		"summary_line": summary_line
	}

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

static func _slice_strings(values: Array, limit: int) -> Array[String]:
	return _string_array(values).slice(0, limit)

static func _first_string(values: Variant, fallback: String) -> String:
	for value in _string_array(values):
		return value
	return fallback

static func _first_non_empty(values: Array) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return ""

static func _normalize_explanation_layer(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in values:
		var entry := Dictionary(value).duplicate(true)
		entry["trigger"] = str(entry.get("trigger", "")).strip_edges()
		entry["escalation"] = str(entry.get("escalation", "")).strip_edges()
		entry["consequence"] = str(entry.get("consequence", "")).strip_edges()
		entry["interpretation"] = str(entry.get("interpretation", "")).strip_edges()
		entry["priority"] = clampi(int(entry.get("priority", 1)), 1, 5)
		entry["public_safe"] = bool(entry.get("public_safe", true))
		if _first_non_empty([entry["trigger"], entry["escalation"], entry["consequence"], entry["interpretation"]]).is_empty():
			continue
		result.append(entry)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("priority", 0)) > int(b.get("priority", 0))
	)
	return result

static func _derive_explanation_lane_entries(lines: Array, lane_id: String) -> Array[Dictionary]:
	var values := _slice_strings(lines, 4)
	if values.is_empty():
		return []
	var entry := {
		"trigger": _first_string(values, ""),
		"escalation": values[1] if values.size() > 1 else "",
		"consequence": values[2] if values.size() > 2 else "",
		"interpretation": values[3] if values.size() > 3 else _first_string(values, ""),
		"priority": 3 if lane_id == "immediate" else 2 if lane_id == "run" else 1,
		"public_safe": true
	}
	return _normalize_explanation_layer([entry])

static func _derived_lane_lines(immediate: Array[Dictionary], run_lane: Array[Dictionary], meta: Array[Dictionary]) -> Array[String]:
	return _slice_strings([
		_lane_line(immediate),
		_lane_line(run_lane),
		_lane_line(meta)
	], MAX_LINES)

static func _derived_operator_lines(meta: Array[Dictionary], run_lane: Array[Dictionary]) -> Array[String]:
	return _slice_strings([
		_lane_operator_line(meta),
		_lane_operator_line(run_lane)
	], MAX_LINES)

static func _lane_line(entries: Array[Dictionary]) -> String:
	if entries.is_empty():
		return ""
	var entry: Dictionary = entries[0]
	return _first_non_empty([
		str(entry.get("interpretation", "")).strip_edges(),
		str(entry.get("trigger", "")).strip_edges(),
		str(entry.get("consequence", "")).strip_edges()
	])

static func _lane_operator_line(entries: Array[Dictionary]) -> String:
	if entries.is_empty():
		return ""
	var entry: Dictionary = entries[0]
	return _first_non_empty([
		str(entry.get("escalation", "")).strip_edges(),
		str(entry.get("consequence", "")).strip_edges(),
		str(entry.get("interpretation", "")).strip_edges()
	])

static func _report_ids(entries: Array) -> Array[String]:
	var result: Array[String] = []
	for entry_raw in entries:
		var entry := Dictionary(entry_raw)
		var entry_id := _first_non_empty([
			str(entry.get("report_id", "")).strip_edges(),
			str(entry.get("decision_id", "")).strip_edges(),
			str(entry.get("reflection_id", "")).strip_edges(),
			str(entry.get("record_id", "")).strip_edges(),
			str(entry.get("entry_id", "")).strip_edges()
		])
		if not entry_id.is_empty() and not result.has(entry_id):
			result.append(entry_id)
	return result

static func _canonical_string(value: Variant) -> String:
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
				segments.append("%s:%s" % [key_text, _canonical_string(dict.get(key_lookup[key_text]))])
			return "{%s}" % ",".join(segments)
		TYPE_ARRAY:
			var segments: Array[String] = []
			for item in value:
				segments.append(_canonical_string(item))
			return "[%s]" % ",".join(segments)
		TYPE_STRING:
			return JSON.stringify(value)
		_:
			return str(value)
