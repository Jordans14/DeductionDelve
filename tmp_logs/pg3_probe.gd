extends SceneTree

const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const PROFILE_SERVICE_SCRIPT = preload("res://src/product/profile_service.gd")
const NETWORK_MANAGER_SCRIPT = preload("res://src/net/network_manager.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")

func _initialize() -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.current_expedition_constitution = {
		"market_regime_state": {
			"regime_id": "market_balanced_exchange",
			"carrier_risk_band": "contested"
		}
	}
	var counterfeit_artifacts := {
		12: {"artifact_id": 12, "room_slot": 7, "spawn_index": 0, "signature": "F0012", "is_forged": true, "owner_peer_id": 2, "world_pos": Vector2.ZERO}
	}
	var outcome_summary := manager.build_outcome_summary_for_test("extraction_objective", counterfeit_artifacts, {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7})
	var run_record := {
		"seed": 818181,
		"end_reason": "extraction_objective",
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": bool(outcome_summary.get("expedition_success", false)),
		"outcome_summary": outcome_summary.duplicate(true),
		"stats": {"notes_count": 1, "pinned_count": 0, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["The burden crossed the threshold under pressure."],
		"key_clues": ["The return line stayed legible long enough to resolve the carry."],
		"report_path": "user://reports/execution_artifact_818181.txt",
		"item_defs": ["custody_seal", "timeline_bookmark"],
		"room_families": ["evidence", "hazard"],
		"artifact_states": [str(outcome_summary.get("artifact_result", "")).strip_edges(), str(outcome_summary.get("artifact_continuity_state", "")).strip_edges()],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_picked", "artifact_dropped"],
		"communication_summary": {"total": 2, "danger": 1, "regroup": 1, "artifact": 1},
		"timeline_public_events": [
			{"event_id": 1, "tick": 8, "room_slot": 4, "actor_peer_id": 2, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 12}},
			{"event_id": 2, "tick": 15, "room_slot": 8, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {"artifact_id": 12}}
		],
		"timeline_private_events": [
			{"event_id": 3, "tick": 9, "room_slot": 4, "actor_peer_id": 2, "event_type": "inspection_private_confirm", "visibility": "private", "meta": {"artifact_id": 12}}
		],
		"gameplay_signal_snapshot": {
			"player_count": 3,
			"protocol_state": "Intimate Protocol",
			"group_model": {
				"group_signals": ["burden answer"],
				"model_pressure": ["custody pressure"],
				"feature_scores": {"burden_answer": 2}
			}
		},
		"peer_identities": {"2": {"public_id": "delver_A", "display_name": "Aster"}},
		"narrative_motion_facts": {},
		"replay_identity": {"replay_id": "replay_818181"},
		"forensic_bundle": {"bundle_digest": "bundle_818181", "replay_id": "replay_818181"},
		"delve_directive_summary": {
			"protocol_state": "Intimate Protocol",
			"market_regime_id": str(outcome_summary.get("market_regime_id", "")).strip_edges(),
			"market_carrier_risk_band": str(outcome_summary.get("market_carrier_risk_band", "")).strip_edges()
		},
		"expedition_constitution_summary": {
			"protocol_state": "Intimate Protocol",
			"market_regime_id": str(outcome_summary.get("market_regime_id", "")).strip_edges(),
			"market_carrier_risk_band": str(outcome_summary.get("market_carrier_risk_band", "")).strip_edges(),
			"archive_tone": "custody memory"
		}
	}
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var updated_profile: Dictionary = Dictionary(result.get("profile", {}))
	var last_run: Dictionary = Dictionary(updated_profile.get("last_run", {}))
	var world_memory: Dictionary = Dictionary(updated_profile.get("world_memory", {}))
	var payload := {
		"last_run_return_consequence_state": last_run.get("return_consequence_state", null),
		"last_run_public_consequence_tags": last_run.get("public_consequence_tags", null),
		"last_run_forensic_bundle_header": last_run.get("forensic_bundle_header", null),
		"last_run_keys": last_run.keys(),
		"world_memory_artifact_state": world_memory.get("artifact_consequence_state", null),
		"crawl_active": updated_profile.get("active_crawl", null)
	}
	print(JSON.stringify(payload, "\t"))
	quit()
