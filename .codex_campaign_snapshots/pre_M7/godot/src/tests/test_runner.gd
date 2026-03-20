extends SceneTree

var _pending_failures: Array[String] = []
var _initial_root_child_ids: Array[int] = []

const NET_HELPERS_SCRIPT = preload("res://src/tests/net_manager_test_helpers.gd")
const NETWORK_MANAGER_SCRIPT = preload("res://src/net/network_manager.gd")
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")
const DOCTRINE_SCHEMA_REGISTRY_SCRIPT = preload("res://src/gen/doctrine_schema_registry.gd")
const ONTOLOGY_ENGINE_SCRIPT = preload("res://src/gen/ontology_engine.gd")
const CONSTITUTION_COMPILER_SCRIPT = preload("res://src/gen/constitution_compiler.gd")
const CONTROL_SURFACE_REGISTRY_SCRIPT = preload("res://src/delve/control_surface_registry.gd")
const NARRATIVE_PRESSURE_ENGINE_SCRIPT = preload("res://src/gen/narrative_pressure_engine.gd")
const ROOM_BUILDER_SCRIPT = preload("res://src/gen/room_builder.gd")
const GAME_CONTROLLER_SCRIPT = preload("res://src/run/game_controller.gd")
const VISUAL_GOVERNANCE_SCRIPT = preload("res://src/visual/visual_governance.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const ARTIFACT_SERVICE_SCRIPT = preload("res://src/run/artifact_service.gd")
const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")
const EVENT_LOG_SCRIPT = preload("res://src/run/event_log.gd")
const CRUSHER_SCRIPT = preload("res://src/entities/crusher.gd")
const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")
const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const PROFILE_SERVICE_SCRIPT = preload("res://src/product/profile_service.gd")
const GOVERNANCE_SERVICE_SCRIPT = preload("res://src/product/governance_service.gd")
const RUN_STORY_DIAGNOSTICS_SCRIPT = preload("res://src/product/run_story_diagnostics.gd")
const FRAMING_SERVICE_SCRIPT = preload("res://src/product/framing_service.gd")
const ARCHIVE_SERVICE_SCRIPT = preload("res://src/product/archive_service.gd")
const WORLD_MEMORY_SERVICE_SCRIPT = preload("res://src/product/world_memory_service.gd")
const CIVILIZATION_STATE_SERVICE_SCRIPT = preload("res://src/product/civilization_state_service.gd")
const CRAWL_SERVICE_SCRIPT = preload("res://src/product/crawl_service.gd")
const DELVEMIND_LEARNING_LOOP_SCRIPT = preload("res://src/product/delvemind_learning_loop.gd")
const DELVE_KERNEL_SCRIPT = preload("res://src/delve/delve_kernel.gd")
const DELVE_WORLD_MODEL_SCRIPT = preload("res://src/delve/world_model.gd")
const THEORY_ENGINE_SCRIPT = preload("res://src/delve/theory_engine.gd")
const DOCTRINE_ENGINE_SCRIPT = preload("res://src/delve/doctrine_engine.gd")
const HORIZON_PLANNER_SCRIPT = preload("res://src/delve/horizon_planner.gd")
const META_RESISTANCE_SCRIPT = preload("res://src/delve/meta_resistance_engine.gd")
const DELVE_DIRECTIVE_INSPECTOR_SCRIPT = preload("res://src/delve/delve_directive_inspector.gd")
const EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT = preload("res://src/delve/constitution/expedition_constitution_schema.gd")
const EXPEDITION_MUTATION_ENGINE_SCRIPT = preload("res://src/run/expedition_mutation_engine.gd")
const MULTIMODAL_CONTRACT_SERVICE_SCRIPT = preload("res://src/product/multimodal_contract_service.gd")
const DELVEMIND_EXPERIMENT_ENGINE_SCRIPT = preload("res://src/product/delvemind_experiment_engine.gd")

class DummyDamageTarget:
	var health: int = 3
	func apply_damage(amt: int) -> void:
		health -= amt

func _init() -> void:
	_initial_root_child_ids = _capture_initial_root_child_ids()
	var failures: Array[String] = []
	_test_seed_determinism(failures)
	_test_room_count_bounds(failures)
	_test_authoritative_run_start_seam(failures)
	_test_room_archetype_scope_lock(failures)
	_test_room_pacing_and_item_replayability(failures)
	_test_room_interior_microplans_and_exposed_spawns(failures)
	_test_role_scaling_and_alignment(failures)
	_test_role_secrecy_payload(failures)
	_test_role_expansion_social_asymmetry(failures)
	_test_artifact_signature_determinism(failures)
	_test_artifact_ownership_logic(failures)
	_test_public_sabotage_anonymity(failures)
	_test_one_carry_rule(failures)
	_test_spelunky_tool_inventory_authority(failures)
	_test_current_era_tool_slot_limit(failures)
	_test_tool_slot_reopens_after_use(failures)
	_test_relic_pickup_stays_outside_tool_slot_cap(failures)
	_test_forge_determinism(failures)
	_test_public_meta_allowlist(failures)
	_test_event_id_determinism(failures)
	_test_warden_check_determinism(failures)
	_test_pickup_denied_cross_room(failures)
	_test_steal_denied_cross_room(failures)
	_test_room_builder_indicator_visual_only(failures)
	_test_crusher_trap_determinism_and_room_mapping(failures)
	_test_core_item_sandbox_alignment_and_use(failures)
	_test_content_breadth_expansion_and_coupling(failures)
	_test_artifact_outcome_logic(failures)
	_test_artifact_irrecoverability_continuity(failures)
	_test_artifact_continuity_product_carryover(failures)
	_test_institutional_order_carryover_and_delve_intake(failures)
	_test_false_canon_and_semantic_drift_carryover(failures)
	_test_affective_climate_and_ordinary_labor_carryover(failures)
	_test_ontology_and_counterfactual_carryover(failures)
	_test_delve_history_self_anthropology(failures)
	_test_interpretation_network_order_and_silence_carryover(failures)
	_test_cookbook_shadow_and_anti_protocol_carryover(failures)
	_test_relay_and_mass_expedition_carryover(failures)
	_test_epoch_state_world_model_and_horizon_carryover(failures)
	_test_trust_topology_routes_back_into_delve(failures)
	_test_ghost_pressure_determinism(failures)
	_test_runtime_ecology_beyond_ghost(failures)
	_test_predator_rush_and_combat_scaling(failures)
	_test_inhabitant_differentiation_deepening(failures)
	_test_new_item_runtime_and_inhabitant_modes(failures)
	_test_run_end_tick_determinism(failures)
	_test_extraction_objective_end_reason(failures)
	_test_role_reveal_secrecy_until_end(failures)
	_test_end_payload_contract(failures)
	_test_inspection_autonote_private_and_throttled(failures)
	_test_notebook_pin_private_and_export_ordering(failures)
	_test_notebook_filters_copy_and_sections(failures)
	_test_run_report_stats_action_summary_and_hint_logic(failures)
	_test_run_guidance_packet_and_live_briefing(failures)
	_test_product_catalog_and_profile_progression(failures)
	_test_product_shell_deepening_helpers(failures)
	_test_session_reliability_and_callout_helpers(failures)
	_test_product_shell_reconnect_history_and_voice_helpers(failures)
	_test_between_runs_productization_browser_and_cta_helpers(failures)
	_test_item_ecology_registry_and_canonical_categories(failures)
	_test_live_reserve_ecology_activation(failures)
	_test_reserve_ecology_distribution_and_caps(failures)
	_test_expedition_mutation_engine_determinism(failures)
	_test_network_manager_mutation_runtime_integration(failures)
	_test_extended_mutation_trigger_families(failures)
	_test_artifact_service_naming_migration(failures)
	_test_multimodal_contract_non_authority(failures)
	_test_constitution_summary_migration_and_aliases(failures)
	_test_mutation_readability_and_collection_polish(failures)
	_test_visual_mutation_stack_readability(failures)
	_test_master_narrative_v3_interpretive_stack(failures)
	_test_master_narrative_v3_branch_context_and_crawl_memory(failures)
	_test_master_narrative_v3_longform_continuity_and_lobby(failures)
	_test_master_narrative_v3_archive_world_memory_and_progression(failures)
	_test_master_narrative_v3_finalization_depth(failures)
	_test_master_narrative_v35_stabilization_and_culture(failures)
	_test_master_narrative_v3_refinement_richness(failures)
	_test_master_narrative_v35_ai_native_inference(failures)
	_test_gameplay_signal_network_depth(failures)
	_test_protocol_state_player_band_depth(failures)
	_test_relationship_obligation_trust_embodiment(failures)
	_test_relay_crawl_network_embodiment(failures)
	_test_cookbook_anti_protocol_embodiment(failures)
	_test_civilization_conflict_embodiment_diverges(failures)
	_test_role_deception_and_artifact_custody_embodiment(failures)
	_test_delve_intelligence_kernel_governance(failures)
	_test_doctrine_schema_registry_and_phase_groundwork(failures)
	_test_wave1_schema_registry_with_new_doctrine_contracts(failures)
	_test_wave1_profile_v3_additive_migration(failures)
	_test_wave1_constitution_v2_dormant_sections_hash_stability(failures)
	_test_wave1_governance_state_default_visibility(failures)
	_test_wave1_explanation_packet_presence_without_expression(failures)
	_test_phase1_explanation_packet_v2_contract(failures)
	_test_phase1_forensic_bundle_contract(failures)
	_test_phase2_cosmetic_modulation_catalog_contract(failures)
	_test_phase2_profile_normalization_and_loadout(failures)
	_test_phase2_guidance_packet_normalization_collapse(failures)
	_test_phase2_same_seed_fairness_sensitive_bundle_collapse(failures)
	_test_phase2_same_seed_forensic_replay_bundle_collapse(failures)
	_test_phase2_constitution_and_visual_normalization_contract(failures)
	_test_phase3_market_control_surfaces_and_defaults(failures)
	_test_phase3_compiler_and_constitution_market_contract(failures)
	_test_phase3_generation_and_item_market_bias(failures)
	_test_phase3_world_memory_and_civilization_market_persistence(failures)
	_test_phase3_preservation_salience_accessibility_activation_contract(failures)
	_test_phase4_compiler_and_constitution_encounter_contract(failures)
	_test_phase4_generation_contract_and_branch_context(failures)
	_test_phase4_runtime_ecology_encounter_state(failures)
	_test_phase4_world_memory_encounter_persistence(failures)
	_test_phase4_truth_layer_disclosure_matrix_contract(failures)
	_test_phase5_compiler_and_constitution_apex_contract(failures)
	_test_phase5_branch_context_and_visual_apex_preview(failures)
	_test_phase5_runtime_apex_and_local_aftermath(failures)
	_test_phase5_world_aftermath_owner_boundary(failures)
	_test_phase5_world_aftermath_shape_contract(failures)
	_test_phase5_world_aftermath_persistence(failures)
	_test_phase6_lifecycle_hardening_compile_contract(failures)
	_test_phase6_governance_lifecycle_controls(failures)
	_test_phase6_governance_jurisdiction_and_admissibility_contract(failures)
	_test_phase6_evaluation_dimensions_and_persistence(failures)
	_test_wave1_inactive_is_not_optional_defaults(failures)
	_test_generation_contract_narrowing(failures)
	_test_ontology_engine_and_compiler_bridge(failures)
	_test_constitution_compiler_symbolic_profiles_and_bounds(failures)
	_test_narrative_pressure_phase5_compilation_and_surfaces(failures)
	_test_experimental_ontology_phase6_compilation_and_surfaces(failures)
	_test_phase6_doctrine_vocabulary_and_compile_honesty(failures)
	_test_phase6_persistence_and_lineage_cleanup(failures)
	_test_phase6_curated_phenomenon_family_contract(failures)
	_test_phase6_curated_phenomenon_schema_proof(failures)
	_test_phase6_curated_phenomenon_governance_bias_from_persisted_reports(failures)
	_test_phase6_curated_phenomenon_cookbook_containment(failures)
	_test_phase6_curated_phenomenon_rarity_and_plurality(failures)
	_test_phase6_shell_proof_fast_path(failures)
	_test_phase7_evaluation_schema_and_owner(failures)
	_test_phase7_learning_loop_determinism_and_continuity(failures)
	_test_phase7_promotion_requires_admissibility_evidence(failures)
	_test_phase7_immutable_fields_and_invalid_transitions(failures)
	_test_phase7_compiler_guidance_and_public_traces(failures)
	_test_phase7_duplicate_evaluation_dedup_and_meta_consistency(failures)
	_test_phase7_manifestation_identity_and_collision_handling(failures)
	_test_phase7_malformed_persisted_learning_state_cleanup(failures)
	_test_phase7_branch_synthesis_persistence_honesty(failures)
	_test_phase7_summary_only_constitution_normalization_stays_light(failures)
	_test_phase8_quiet_play_diagnostics_and_safety(failures)
	_test_phase8_scale_budget_and_stewardship_audit_projection(failures)
	_test_phase8_legacy_reentry_continuity_surfaces(failures)
	_test_phase9_forensic_bundle_hardening_contract(failures)
	_test_phase9_forensic_bundle_extension_consistency(failures)
	_test_phase9_curated_phenomenon_manifest_builder_contract(failures)
	_test_phase9_curated_phenomenon_manifest_bundle_only(failures)
	_test_phase9_profile_forensic_persistence_and_world_memory_hash(failures)
	_test_expedition_constitution_schema_and_hash(failures)
	_test_delve_live_handoff_and_summary(failures)
	_test_runstate_constitution_handoff(failures)
	_test_delve_live_control_surface_consumption(failures)
	_test_branch_and_protocol_weighting_depth(failures)
	_test_ordered_next_tier_branch_pressure(failures)
	_test_ordered_next_tier_artifact_ecology_signaling(failures)
	_test_ordered_next_tier_crawl_memory_and_archive_signals(failures)
	_test_read_only_ecology_signal_carryover(failures)
	_test_read_only_predator_signal_carryover(failures)
	_test_shell_explainability_tightening(failures)
	_test_delve_kernel_stabilization_and_trace(failures)
	_test_visual_doctrine_refactor(failures)
	_test_phase1_visual_signal_compression_contract(failures)
	_test_execution_provenance_contract_visibility(failures)
	_test_execution_combo_contract_determinism_and_public_projection(failures)
	_test_execution_lifecycle_registry_combo_and_artifact_adoption(failures)
	_test_execution_lifecycle_runtime_bias_and_ev4(failures)
	_test_execution_lifecycle_persistence_and_governance_adoption(failures)
	_test_execution_artifact_consequence_runtime_and_public_projection(failures)
	_test_execution_artifact_consequence_persistence_and_ev5(failures)
	_test_execution_encounter_apex_consequence_runtime_and_persistence(failures)
	_test_execution_encounter_apex_consequence_visibility_and_ev6(failures)
	_test_execution_public_fact_extensions_and_diagnostics_contract(failures)
	_test_lobby_shell_scene_contract(failures)

	_pending_failures = failures.duplicate()
	call_deferred("_finalize_runner_exit")

func _finalize_runner_exit() -> void:
	if _pending_failures.is_empty():
		print("[PASS] Milestone tests passed.")
	else:
		for failure in _pending_failures:
			push_error("[FAIL] %s" % failure)
	await _cleanup_after_tests()
	quit(0 if _pending_failures.is_empty() else 1)

func _cleanup_after_tests() -> void:
	var root := get_root()
	var network_manager := root.get_node_or_null("NetworkManager")
	if network_manager != null:
		if network_manager.has_method("disconnect_peer"):
			network_manager.disconnect_peer("test_runner_cleanup")
		if network_manager.has_method("clear_runtime_context_for_test"):
			network_manager.clear_runtime_context_for_test()
		if network_manager.has_method("reset_to_lobby"):
			network_manager.reset_to_lobby("test_runner_cleanup")
		if network_manager.has_method("release_shutdown_resources"):
			network_manager.release_shutdown_resources()
	var run_state := root.get_node_or_null("RunState")
	if run_state != null and run_state.has_method("clear"):
		run_state.clear()
	for child in root.get_children():
		if child == null:
			continue
		if not (child is Node):
			continue
		var node := child as Node
		if _initial_root_child_ids.has(node.get_instance_id()):
			continue
		node.queue_free()
	if network_manager != null:
		network_manager.queue_free()
	if run_state != null:
		run_state.queue_free()
	await process_frame
	await process_frame
	await process_frame

func _capture_initial_root_child_ids() -> Array[int]:
	var ids: Array[int] = []
	for child in get_root().get_children():
		if child is Node:
			ids.append((child as Node).get_instance_id())
	return ids

func _test_seed_determinism(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var a := generator.generate_layout(424242, 15)
	var b := generator.generate_layout(424242, 15)
	if JSON.stringify(a) != JSON.stringify(b):
		failures.append("same seed produced different room chains")

func _test_room_count_bounds(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var chain := generator.generate_layout(99, 15)
	if chain.size() != 15:
		failures.append("room chain size expected 15 got %d" % chain.size())

func _test_authoritative_run_start_seam(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	if manager.resolve_authoritative_room_count_for_start() != 10:
		failures.append("authoritative run-start room count should default to the current-era baseline when no override is supplied")
	if manager.resolve_authoritative_room_count_for_start(8) != 10:
		failures.append("authoritative run-start room count should reject prototype-era lobby room counts below the current-era band")
	if manager.resolve_authoritative_room_count_for_start(11) != 11:
		failures.append("authoritative run-start room count should allow in-band overrides for narrow test/debug use")
	if manager.resolve_authoritative_room_count_for_start(15) != 10:
		failures.append("authoritative run-start room count should reject oversized prototype defaults outside the current-era band")
	var authoritative_chain := [
		{"slot": 0, "type": "traversal"},
		{"slot": 1, "type": "evidence"}
	]
	manager.host_start_run(4242, authoritative_chain, [1, 2], {})
	if JSON.stringify(manager.get_authoritative_room_chain_snapshot()) != JSON.stringify(authoritative_chain):
		failures.append("host_start_run should cache the authoritative room_chain snapshot for runtime recovery")
	manager.free()

	var controller_script = load("res://src/run/game_controller.gd")
	if controller_script == null:
		failures.append("game_controller script should load for authoritative run-start seam tests")
	else:
		var controller = controller_script.new()
		var recovery_manager := NETWORK_MANAGER_SCRIPT.new()
		recovery_manager.host_start_run(5150, authoritative_chain, [1, 2], {})
		var recovered: Dictionary = controller.resolve_room_chain_for_build_for_test([], 5150, recovery_manager)
		if str(recovered.get("source", "")) != "authoritative_snapshot":
			failures.append("game_controller should recover the cached authoritative room_chain before attempting emergency fallback generation")
		if JSON.stringify(recovered.get("room_chain", [])) != JSON.stringify(authoritative_chain):
			failures.append("game_controller room recovery should restore the cached authoritative room_chain exactly")
		recovery_manager.free()

		var emergency_manager := NETWORK_MANAGER_SCRIPT.new()
		var emergency: Dictionary = controller.resolve_room_chain_for_build_for_test([], 9090, emergency_manager)
		if str(emergency.get("source", "")) != "emergency_fallback":
			failures.append("game_controller should label emergency generation explicitly when no authoritative room_chain snapshot exists")
		elif Array(emergency.get("room_chain", [])).size() != emergency_manager.resolve_authoritative_room_count_for_start():
			failures.append("game_controller emergency fallback should use the authoritative current-era room count instead of legacy prototype defaults")
		emergency_manager.free()
		controller.free()

	var lobby_source := FileAccess.open("res://src/ui/lobby_controller.gd", FileAccess.READ)
	if lobby_source == null:
		failures.append("lobby_controller should be readable for authoritative run-start seam tests")
	else:
		var lobby_text := lobby_source.get_as_text()
		if lobby_text.find("NetworkManager.start_run(seed, 8)") != -1:
			failures.append("lobby start flow should not inject a hardcoded prototype-era room count into the authoritative run-start seam")
		if lobby_text.find("NetworkManager.start_run(seed)") == -1:
			failures.append("lobby start flow should defer room-count ownership to NetworkManager.start_run(seed)")

func _test_room_archetype_scope_lock(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var chain := generator.generate_layout(303, 15)
	for room_raw in chain:
		var room: Dictionary = room_raw
		var room_type := str(room.get("type", ""))
		if room_type not in ["traversal", "hazard", "evidence"]:
			failures.append("room generator should stay inside the design-anchor archetype set")
			break

func _test_room_pacing_and_item_replayability(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var chain := generator.generate_layout(606, 15)
	if str(Dictionary(chain[0]).get("type", "")) != "traversal":
		failures.append("run pacing should open with a traversal room")
	if str(Dictionary(chain[1]).get("type", "")) != "evidence":
		failures.append("run pacing should surface an evidence room immediately after the opener")
	if str(Dictionary(chain[chain.size() - 2]).get("type", "")) != "hazard":
		failures.append("run pacing should force a late hazard chokepoint before extraction")
	if str(Dictionary(chain[chain.size() - 1]).get("type", "")) != "traversal":
		failures.append("run pacing should finish on a readable traversal extraction room")
	if int(Dictionary(chain[0]).get("risk", -1)) != 1 or int(Dictionary(chain[1]).get("risk", -1)) != 1:
		failures.append("early rooms should stay low-risk for readable exploration")
	if int(Dictionary(chain[chain.size() - 2]).get("risk", -1)) != 3:
		failures.append("late hazard chokepoints should reach high risk deterministically")
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var items_a := item_service.generate_item_spawns(606, chain)
	var items_b := item_service.generate_item_spawns(606, chain)
	if JSON.stringify(items_a) != JSON.stringify(items_b):
		failures.append("item spawns should remain deterministic for the same room chain")
	var distinct_defs: Dictionary = {}
	for item_raw in items_a:
		var item: Dictionary = item_raw
		distinct_defs[str(item.get("item_def_id", ""))] = true
	for i in range(1, items_a.size()):
		var current_item: Dictionary = items_a[i]
		var prev_item: Dictionary = items_a[i - 1]
		if str(current_item.get("item_def_id", "")) == str(prev_item.get("item_def_id", "")):
			failures.append("item pacing should avoid immediate duplicate spawns in the active sandbox")
			break
	if distinct_defs.size() < 3:
		failures.append("item pacing should produce at least three distinct tools/relics in a standard run")

func _test_item_ecology_registry_and_canonical_categories(failures: Array[String]) -> void:
	var item_service := ITEM_SERVICE_SCRIPT.new()
	if item_service.canonical_category("world_object") != "environment_object":
		failures.append("world_object should migrate through the canonical environment_object alias")
	var registry: Dictionary = item_service.build_item_ecology_registry()
	var categories: Dictionary = Dictionary(registry.get("categories", {}))
	for category_id in ["artifact", "relic", "tool", "trinket", "pickup", "covenant", "curse", "transformation", "environment_object"]:
		if not categories.has(category_id):
			failures.append("item ecology registry should expose category %s" % category_id)
	if str(item_service.item_ecology_layer("lantern_snuffer")) != "build_economy":
		failures.append("existing relics should stay in the build economy during ecology migration")
	var affordances: Dictionary = item_service.build_runtime_affordances(["lantern_snuffer", "zipline_kit"])
	if not Dictionary(affordances.get("modifier_surfaces", {})).has("traversal"):
		failures.append("item runtime affordances should expose the canonical modifier surface registry")
	var covenant_category: Dictionary = Dictionary(categories.get("covenant", {}))
	if int(covenant_category.get("library_count", 0)) < 1 or int(covenant_category.get("live_count", 0)) < 1:
		failures.append("covenant ecology should now be live in the canonical registry instead of remaining library-only")
	if not bool(Dictionary(covenant_category.get("rules", {})).get("must_declare_bargain", false)):
		failures.append("covenant ecology rules should require explicit bargain declarations")
	var reserve_affordances: Dictionary = item_service.build_runtime_affordances(["hush_bead", "flare_ampoule", "oath_ribbon", "doubt_ink", "echo_molt"])
	var reserve_category_counts: Dictionary = Dictionary(reserve_affordances.get("category_counts", {}))
	for reserve_category in ["trinket", "pickup", "covenant", "curse", "transformation"]:
		if int(reserve_category_counts.get(reserve_category, 0)) != 1:
			failures.append("reserve ecology loadouts should retain category count for %s" % reserve_category)
	if not Array(reserve_affordances.get("forbidden_combo_failures", [])).has("bargain and curse collapse the same custody read into unreadable noise"):
		failures.append("reserve ecology loadouts should expose forbidden combo failures through runtime affordances")
	var reserve_active_ids := item_service.active_item_ids_for_items(["flare_ampoule", "hush_bead"])
	if not reserve_active_ids.has("flare_ampoule") or reserve_active_ids.has("hush_bead"):
		failures.append("active item filtering should respect reserve-category runtime behavior instead of only the original live item set")
	if int(item_service.category_carry_limit("covenant")) != 1 or int(item_service.category_carry_limit("tool")) != 2:
		failures.append("category carry limits should expose bounded reserve ecology caps without changing the live tool cap")
	var covenant_profile: Dictionary = item_service.build_authoring_profile("oath_ribbon")
	if str(covenant_profile.get("category", "")) != "covenant" or str(covenant_profile.get("economy_layer", "")) != "bargain_economy":
		failures.append("reserve covenant items should build canonical authoring profiles with bargain economy ownership")
	var vowed_burden_state: Dictionary = item_service.resolve_loadout_state(["oath_ribbon", "burden_sling"], {"carrying_artifact": true})
	if not Array(vowed_burden_state.get("synergy_labels", [])).has("vowed burden line"):
		failures.append("reserve covenants should materially deepen build identity when paired with the live burden line instead of staying taxonomy-only")
	var threshold_state: Dictionary = item_service.resolve_loadout_state(["echo_molt", "echo_lure"], {"echo_pressure_score": 3, "active_transformation_ids": ["echo_molt"]})
	if not Array(threshold_state.get("synergy_labels", [])).has("threshold echo break"):
		failures.append("transformations should materially deepen anomaly build texture when paired with live echo-routing tools")

func _test_live_reserve_ecology_activation(failures: Array[String]) -> void:
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var hush_room := {
		"slot": 2,
		"type": "traversal",
		"branch_family_id": "relay_hollows",
		"branch_context": {"constitution_summary": {"archive_tone": "measured memory", "item_ecology_bias": "rescue"}}
	}
	var hush_candidates := item_service.candidate_spawn_item_ids_for_room_for_test(hush_room, 10, {}, {
		"item_ecology_bias": "rescue",
		"archive_tone": "measured memory"
	})
	if not hush_candidates.has("hush_bead"):
		failures.append("bounded traversal reserve activation should make trinkets live where the constitution leans rescue or memory")
	var pickup_candidates := item_service.candidate_spawn_item_ids_for_room_for_test({
		"slot": 6,
		"type": "hazard",
		"branch_family_id": "relay_hollows"
	}, 10, {}, {
		"item_ecology_bias": "rescue",
		"pressure_verbs": ["Exposure"],
		"group_tension_bias": "measured caution"
	})
	if not pickup_candidates.has("flare_ampoule"):
		failures.append("hazard reserve activation should make pickups live under public-pressure rescue constitutions")
	var covenant_candidates := item_service.candidate_spawn_item_ids_for_room_for_test({
		"slot": 4,
		"type": "evidence",
		"branch_family_id": "oath_terraces"
	}, 10, {}, {
		"item_ecology_bias": "burden rescue",
		"archive_tone": "custody memory",
		"convergence_axis": "custody"
	})
	if not covenant_candidates.has("oath_ribbon"):
		failures.append("oath-weighted evidence chambers should activate covenant reserve items through the live spawn path")
	var curse_candidates := item_service.candidate_spawn_item_ids_for_room_for_test({
		"slot": 7,
		"type": "hazard",
		"branch_family_id": "grave_lattice"
	}, 10, {}, {
		"item_ecology_bias": "deception scarcity",
		"group_tension_bias": "ambiguous pressure",
		"convergence_axis": "fragment"
	})
	if not curse_candidates.has("doubt_ink"):
		failures.append("deception-heavy hazard runs should activate curse reserve items through the live spawn path")
	var transformation_candidates := item_service.candidate_spawn_item_ids_for_room_for_test({
		"slot": 8,
		"type": "hazard",
		"branch_family_id": "murmur_warrens"
	}, 10, {}, {
		"item_ecology_bias": "deception",
		"convergence_axis": "fragment",
		"cookbook_routing": {"counter_reading": 1},
		"pressure_verbs": ["Fragmentation"]
	})
	if not transformation_candidates.has("echo_molt"):
		failures.append("late anomaly-heavy chambers should activate transformation reserve items through the live spawn path")
	var dormant_affordances: Dictionary = item_service.build_runtime_affordances(["flare_ampoule", "oath_ribbon", "echo_molt"], {
		"carrying_artifact": false,
		"ghost_active": false,
		"echo_pressure_score": 0
	})
	if float(dormant_affordances.get("light_scale", 1.0)) != 1.0:
		failures.append("pickup reserve items should not leak burst runtime power before use")
	if float(dormant_affordances.get("carry_speed_mult", 1.0)) != 1.0:
		failures.append("covenant reserve items should stay dormant until their activation condition is met")
	if not Array(dormant_affordances.get("dormant_transformation_ids", [])).has("echo_molt"):
		failures.append("dormant transformation reserve items should remain visible to runtime bookkeeping before threshold activation")
	var active_affordances: Dictionary = item_service.build_runtime_affordances(["oath_ribbon", "echo_molt"], {
		"carrying_artifact": true,
		"echo_pressure_score": 3,
		"active_transformation_ids": ["echo_molt"]
	})
	if float(active_affordances.get("carry_speed_mult", 1.0)) <= 1.0:
		failures.append("active covenants should materially alter live runtime affordances once their lawful condition is met")
	if not Array(active_affordances.get("active_transformation_ids", [])).has("echo_molt"):
		failures.append("transformation reserve items should expose an active transformation id once the threshold is crossed")

func _test_reserve_ecology_distribution_and_caps(failures: Array[String]) -> void:
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var tuned_chain := [
		{"slot": 0, "type": "traversal", "id": "traverse_a", "branch_family_id": "relay_hollows"},
		{"slot": 2, "type": "hazard", "id": "hazard_push", "branch_family_id": "relay_hollows"},
		{"slot": 4, "type": "evidence", "id": "evidence_vault", "branch_family_id": "oath_terraces"},
		{"slot": 6, "type": "hazard", "id": "hazard_alarm", "branch_family_id": "grave_lattice"},
		{"slot": 8, "type": "hazard", "id": "hazard_drop", "branch_family_id": "murmur_warrens"}
	]
	var tuned_directive := {
		"item_ecology_bias": "burden rescue deception",
		"group_tension_bias": "ambiguous pressure",
		"archive_tone": "custody memory dispute",
		"convergence_axis": "fragment custody",
		"pressure_verbs": ["Exposure", "Fragmentation"],
		"cookbook_routing": {"counter_reading": 1}
	}
	var category_hits := {}
	for category_id in ["trinket", "pickup", "covenant", "curse", "transformation"]:
		category_hits[category_id] = 0
	for seed_value in range(4400, 4420):
		var spawns: Array = item_service.generate_item_spawns(seed_value, tuned_chain, tuned_directive)
		var reserve_count := 0
		var high_intensity_count := 0
		for spawn_raw in spawns:
			var spawn: Dictionary = spawn_raw
			var item_def_id := str(spawn.get("item_def_id", ""))
			if not item_service.RESERVE_ITEM_IDS.has(item_def_id):
				continue
			reserve_count += 1
			var category_id := item_service.get_category(item_def_id)
			category_hits[category_id] = int(category_hits.get(category_id, 0)) + 1
			if category_id in ["covenant", "curse", "transformation"]:
				high_intensity_count += 1
		if reserve_count < 2:
			failures.append("tuned reserve ecology should appear often enough to matter in a pressure-weighted expedition sample")
			break
		if reserve_count > item_service.MAX_RESERVE_SPAWNS_PER_EXPEDITION:
			failures.append("reserve ecology should stay inside the expedition-wide reserve cap")
			break
		if high_intensity_count > item_service.MAX_HIGH_INTENSITY_RESERVE_SPAWNS:
			failures.append("high-intensity reserve ecology should stay inside the bounded expedition cap")
			break
	for category_id in ["pickup", "covenant", "curse", "transformation"]:
		if int(category_hits.get(category_id, 0)) <= 0:
			failures.append("tuned reserve ecology should make %s materially visible across a small deterministic seed sample" % category_id)

func _test_mutation_readability_and_collection_polish(failures: Array[String]) -> void:
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"event_id": 1,
		"tick": 40,
		"room_slot": 4,
		"actor_peer_id": 2,
		"event_type": "constitution_mutation",
		"visibility": "public",
		"meta": {"trigger_type": "species_escalation", "public_meta": {"species_id": "predator", "mode": "ambush", "room_slot": 4}}
	})
	event_log.add_event({
		"event_id": 2,
		"tick": 60,
		"room_slot": 4,
		"actor_peer_id": 2,
		"event_type": "constitution_mutation",
		"visibility": "public",
		"meta": {"trigger_type": "covenant_activated", "public_meta": {"item_def_id": "oath_ribbon", "room_slot": 4}}
	})
	event_log.add_event({
		"event_id": 3,
		"tick": 80,
		"room_slot": 6,
		"actor_peer_id": 2,
		"event_type": "constitution_mutation",
		"visibility": "public",
		"meta": {"trigger_type": "transformation_threshold_crossed", "public_meta": {"item_def_id": "echo_molt", "room_slot": 6}}
	})
	var action_text := "\n".join(controller.build_action_summary_lines_for_test(event_log, 2, 8))
	if action_text.find("Predator pressure sharpened into ambush") == -1 or action_text.find("Oath Ribbon took hold") == -1 or action_text.find("Echo Molt surfaced") == -1:
		failures.append("public mutation events should read like meaningful run texture in the action summary instead of opaque architecture")
	var clue_text := "\n".join(controller.build_key_clue_lines_for_test(event_log, 8))
	if clue_text.find("Predator pressure sharpened into ambush in room 4") == -1 or clue_text.find("Echo Molt marked a visible threshold shift") == -1:
		failures.append("public mutation events should surface as clue-grade route texture in the key clue recap")
	controller.free()
	event_log.free()

	var canonical_summary := {
		"protocol_state": "Exposure Protocol",
		"doctrine_label": "Tight Custody",
		"surface_summary": {"lines": ["Keep the burden explainable."]},
		"archive_tone": "measured memory",
		"convergence_axis": "custody"
	}
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze({
		"timeline_public_events": [],
		"communication_summary": {},
		"key_clues": [],
		"action_summary": [],
		"gameplay_signal_snapshot": {},
		"mutation_public_summary": {
			"triggers": {"species_escalation": 1, "covenant_activated": 1},
			"public_surfaces": {
				"species_escalation": ["predator:ambush"],
				"covenant_activated": ["oath_ribbon"]
			}
		},
		"expedition_constitution_summary": canonical_summary
	})
	var mutation_surface_lines := Array(diagnostics.get("mutation_surface_lines", []))
	if mutation_surface_lines.is_empty():
		failures.append("diagnostics should expose public-safe mutation surface lines once live mutation texture is part of the run")
	if "\n".join(mutation_surface_lines).find("Predator") == -1 and "\n".join(mutation_surface_lines).find("Oath Ribbon") == -1:
		failures.append("diagnostics should preserve named public mutation texture once it is lawfully visible instead of collapsing it back into generic pressure text")
	var frame_line := FRAMING_SERVICE_SCRIPT._governance_line(diagnostics, {})
	if frame_line.find("Shift:") == -1 and frame_line.find("Surface:") == -1:
		failures.append("framing governance lines should cleanly incorporate mutation texture without leaking hidden internals")
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var collection_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_collection_lines(profile, catalog))
	var library_count := ITEM_SERVICE_SCRIPT.new().item_library_ids().size()
	if collection_lines.find("Items discovered: 0 / %d" % library_count) == -1:
		failures.append("collection lines should count the full live item library once reserve ecology is genuinely productized")
	var collection_entries := PROFILE_SERVICE_SCRIPT.build_collection_entries(profile, "Items", catalog)
	var saw_oath_ribbon := false
	var saw_public_trace := false
	for entry_raw in collection_entries:
		var entry: Dictionary = entry_raw
		var label := str(entry.get("label", ""))
		var detail := str(entry.get("detail", ""))
		if label.find("Oath Ribbon") != -1:
			saw_oath_ribbon = true
		if detail.find("Public trace:") != -1:
			saw_public_trace = true
	if not saw_oath_ribbon:
		failures.append("collection entries should expose reserve ecology items once they are live parts of the game")
	if not saw_public_trace:
		failures.append("collection entries should describe public trace surfaces using the cleaned post-migration wording")

func _test_expedition_mutation_engine_determinism(failures: Array[String]) -> void:
	var run_state_script = load("res://src/run/run_state.gd")
	if run_state_script == null:
		failures.append("run_state script should load for mutation engine tests")
		return
	var run_state = run_state_script.new()
	var peer_ids: Array[int] = [1, 2]
	run_state.set_run(8080, [], peer_ids, {
		"constitution": {
			"constitution_hash": "mutation_hash_01",
			"mutation_envelope": {
				"triggers": ["artifact_picked"],
				"caps": {"per_domain": 2, "per_expedition": 4}
			}
		}
	})
	var constitution: Dictionary = run_state.get_expedition_constitution()
	var plan_a := EXPEDITION_MUTATION_ENGINE_SCRIPT.build_mutation_plan(constitution, run_state, "artifact_picked", {"artifact_id": 9})
	var plan_b := EXPEDITION_MUTATION_ENGINE_SCRIPT.build_mutation_plan(constitution, run_state, "artifact_picked", {"artifact_id": 9})
	if JSON.stringify(plan_a) != JSON.stringify(plan_b):
		failures.append("mutation planning should remain deterministic for identical constitution and trigger inputs")
	var event_log := EVENT_LOG_SCRIPT.new()
	var applied: Dictionary = EXPEDITION_MUTATION_ENGINE_SCRIPT.apply_mutation_plan(run_state, event_log, plan_a, 33)
	if str(applied.get("mutation_id", "")).strip_edges().is_empty():
		failures.append("mutation engine should emit a logged mutation event")
	if Array(run_state.mutation_history).is_empty():
		failures.append("mutation application should persist to RunState mutation_history")
	if Array(event_log.get_recent_public(8)).size() != 1:
		failures.append("public mutation events should enter EventLog through the explicit mutation path")
	if not Array(Dictionary(run_state.truth_state).get("public_trace_classes", [])).has("artifact_custody"):
		failures.append("mutation application should materialize public trace classes into runtime truth state")
	if not Array(Dictionary(run_state.truth_state).get("private_trace_classes", [])).has("custody_shift"):
		failures.append("mutation application should materialize private trace classes into runtime truth state")
	if str(Dictionary(run_state.mutation_visibility_state).get("artifact_picked:1", "")) != "public":
		failures.append("mutation visibility state should preserve the logged visibility class per mutation id")
	run_state.free()
	event_log.free()

func _test_network_manager_mutation_runtime_integration(failures: Array[String]) -> void:
	var run_state_script = load("res://src/run/run_state.gd")
	if run_state_script == null:
		failures.append("run_state script should load for network-backed mutation integration tests")
		return
	var root := get_root()
	var run_state = root.get_node_or_null("RunState")
	var created_run_state := false
	if run_state == null:
		run_state = run_state_script.new()
		run_state.name = "RunState"
		root.add_child(run_state)
		created_run_state = true
	var event_log = root.get_node_or_null("EventLog")
	var created_event_log := false
	if event_log == null:
		event_log = EVENT_LOG_SCRIPT.new()
		event_log.name = "EventLog"
		root.add_child(event_log)
		created_event_log = true
	if run_state.has_method("clear"):
		run_state.clear()
	if event_log.has_method("clear"):
		event_log.clear()
	var constitution := {
		"artifact_type": "expedition_constitution",
		"constitution_hash": "mutation_live_hash",
		"constitution_summary": {
			"protocol_state": "Fracture Protocol",
			"doctrine_label": "Custody Pressure",
			"surface_summary": {"lines": ["Carry states should stay public."]}
		},
		"mutation_envelope": {
			"triggers": ["artifact_picked", "artifact_dropped", "artifact_stolen", "extraction_window_started"],
			"caps": {"per_domain": 4, "per_expedition": 8}
		}
	}
	var peer_ids: Array[int] = [2, 3]
	run_state.set_run(9191, [{"slot": 3, "type": "evidence"}, {"slot": 7, "type": "traversal"}], peer_ids, {
		"constitution": constitution,
		"constitution_hash": "mutation_live_hash",
		"constitution_summary": Dictionary(constitution.get("constitution_summary", {}))
	})
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.name = "MutationAuditManager"
	root.add_child(manager)
	manager.bind_runtime_context_for_test(run_state, event_log)
	manager.is_host = true
	manager.run_active = true
	manager.players = [2, 3]
	manager.roles_by_peer = {2: ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER, 3: ROLE_SERVICE_SCRIPT.ROLE_STEWARD}
	manager.player_room_by_peer = {2: 3, 3: 3}
	manager.player_pos_by_peer = {2: Vector2.ZERO, 3: Vector2(18, 0)}
	manager.current_server_tick = 144
	manager.extraction_room_slot = 7
	manager.next_event_id = 1
	manager.current_delve_directive = constitution.duplicate(true)
	manager.current_expedition_constitution = constitution.duplicate(true)
	manager.current_constitution_hash = "mutation_live_hash"
	manager.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 0, "room_slot": 3, "world_pos": Vector2.ZERO, "is_forged": false, "signature": "A0000001", "spawn_index": 0}
	}
	manager.host_pickup_for_test(2, 1)
	if Array(run_state.mutation_history).size() != 1:
		failures.append("host pickup should invoke the mutation engine through the live network owner path")
	else:
		var pickup_mutation: Dictionary = Dictionary(run_state.mutation_history[0])
		if str(pickup_mutation.get("trigger_type", "")) != "artifact_picked":
			failures.append("host pickup should log artifact_picked through the mutation history")
		if int(Dictionary(pickup_mutation.get("public_meta", {})).get("room_slot", -1)) != 3:
			failures.append("pickup mutations should preserve room-slot public meta for replay and summary safety")
	if int(Dictionary(run_state.mutation_budget_by_domain).get("artifact_custody", 0)) != 1:
		failures.append("live pickup mutations should advance the artifact_custody domain budget once")
	manager.player_room_by_peer[2] = 7
	manager.current_server_tick = 188
	var carried_artifact: Dictionary = Dictionary(manager.artifacts_by_id.get(1, {}))
	carried_artifact["room_slot"] = 7
	manager.artifacts_by_id[1] = carried_artifact
	var extraction_reason: String = str(manager.compute_end_reason_for_tick(188))
	if extraction_reason != "":
		failures.append("extraction window should begin with a hold state instead of ending the run immediately")
	if Array(run_state.mutation_history).size() != 2:
		failures.append("starting the extraction window should log a second live mutation event")
	else:
		var extraction_mutation: Dictionary = Dictionary(run_state.mutation_history[1])
		if str(extraction_mutation.get("trigger_type", "")) != "extraction_window_started":
			failures.append("extraction window start should invoke the extraction_window_started mutation trigger")
		if int(Dictionary(extraction_mutation.get("public_meta", {})).get("room_slot", -1)) != 7:
			failures.append("extraction mutations should preserve extraction-room public metadata")
	if int(Dictionary(run_state.mutation_budget_by_domain).get("route_state", 0)) != 1:
		failures.append("extraction-window mutations should advance the route_state budget exactly once")
	var public_events: Array = event_log.get_recent_public(8)
	var saw_mutation_event := false
	var saw_pickup_event := false
	var saw_extraction_event := false
	var event_ids: Array[int] = []
	for event_raw in public_events:
		var event: Dictionary = event_raw
		event_ids.append(int(event.get("event_id", -1)))
		var event_type := str(event.get("event_type", ""))
		if event_type == "constitution_mutation":
			saw_mutation_event = true
		elif event_type == "artifact_picked":
			saw_pickup_event = true
		elif event_type == "extraction_window_started":
			saw_extraction_event = true
	if not saw_mutation_event or not saw_pickup_event or not saw_extraction_event:
		failures.append("live mutation integration should log both mutation events and their paired public gameplay events")
	var unique_event_ids: Dictionary = {}
	for event_id in event_ids:
		unique_event_ids[event_id] = true
	if unique_event_ids.size() != event_ids.size():
		failures.append("mutation timeline event ids should remain unique when mixed with live public gameplay events")
	if not Array(Dictionary(run_state.truth_state).get("public_trace_classes", [])).has("witness"):
		failures.append("extraction-window mutations should deepen runtime truth-state witness traces")
	manager.clear_runtime_context_for_test()
	root.remove_child(manager)
	manager.free()
	if created_run_state:
		root.remove_child(run_state)
		run_state.free()
	else:
		run_state.clear()
	if created_event_log:
		root.remove_child(event_log)
		event_log.free()
	else:
		event_log.clear()

func _test_extended_mutation_trigger_families(failures: Array[String]) -> void:
	var run_state_script = load("res://src/run/run_state.gd")
	if run_state_script == null:
		failures.append("run_state script should load for extended mutation trigger tests")
		return
	var root := get_root()
	var run_state = root.get_node_or_null("RunState")
	var created_run_state := false
	if run_state == null:
		run_state = run_state_script.new()
		run_state.name = "RunState"
		root.add_child(run_state)
		created_run_state = true
	var event_log = root.get_node_or_null("EventLog")
	var created_event_log := false
	if event_log == null:
		event_log = EVENT_LOG_SCRIPT.new()
		event_log.name = "EventLog"
		root.add_child(event_log)
		created_event_log = true
	if run_state.has_method("clear"):
		run_state.clear()
	if event_log.has_method("clear"):
		event_log.clear()
	var constitution := {
		"artifact_type": "expedition_constitution",
		"constitution_hash": "mutation_extended_hash",
		"constitution_summary": {
			"protocol_state": "Exposure Protocol",
			"doctrine_label": "Escalating Custody",
			"surface_summary": {"lines": ["Escalations should stay legible."]}
		},
		"control_surfaces": {
			"ecology": {
				"inhabitant_pressure": 2,
				"stalking_bias": 2,
				"anomaly_contamination": 1
			}
		},
		"mutation_envelope": {
			"triggers": ["chamber_entered", "species_escalation", "covenant_activated", "transformation_threshold_crossed"],
			"caps": {"per_domain": 4, "per_expedition": 8}
		}
	}
	var mutation_chain: Array = [
		{"slot": 0, "type": "traversal", "id": "traverse_a"},
		{"slot": 1, "type": "evidence", "id": "evidence_vault"},
		{"slot": 2, "type": "hazard", "id": "hazard_push"}
	]
	var mutation_peers: Array[int] = [2, 3]
	run_state.set_run(9292, mutation_chain, mutation_peers, {
		"constitution": constitution,
		"constitution_hash": "mutation_extended_hash",
		"constitution_summary": Dictionary(constitution.get("constitution_summary", {}))
	})
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.name = "ExtendedMutationAuditManager"
	root.add_child(manager)
	manager.bind_runtime_context_for_test(run_state, event_log)
	manager.is_host = true
	manager.run_active = true
	manager.players = [2, 3]
	manager.current_server_tick = manager.ghost_wake_tick_for_test() + 30
	manager.extraction_room_slot = 2
	manager.last_authoritative_room_chain = [
		{"slot": 0, "type": "traversal", "id": "traverse_a"},
		{"slot": 1, "type": "evidence", "id": "evidence_vault"},
		{"slot": 2, "type": "hazard", "id": "hazard_push"}
	]
	manager.current_expedition_constitution = constitution.duplicate(true)
	manager.current_delve_directive = constitution.duplicate(true)
	manager.current_constitution_hash = "mutation_extended_hash"
	manager.roles_by_peer = {2: ROLE_SERVICE_SCRIPT.ROLE_STEWARD, 3: ROLE_SERVICE_SCRIPT.ROLE_VEIL}
	manager.player_room_by_peer = {2: 0, 3: 2}
	manager.player_pos_by_peer = {2: Vector2(0, 0), 3: Vector2(1024, 0)}
	manager.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 0, "room_slot": 1, "world_pos": Vector2(1024, 0), "is_forged": false, "signature": "A0000001", "spawn_index": 0}
	}
	manager.items_by_id = {
		10: {"item_id": 10, "item_def_id": "oath_ribbon", "display_name": "Oath Ribbon", "owner_peer_id": 2, "room_slot": 1, "world_pos": Vector2.ZERO, "consumed": false},
		11: {"item_id": 11, "item_def_id": "echo_molt", "display_name": "Echo Molt", "owner_peer_id": 2, "room_slot": 1, "world_pos": Vector2.ZERO, "consumed": false}
	}
	manager.update_authoritative_player_state(2, Vector2(1024, 0), 1)
	manager.host_pickup_for_test(2, 1)
	var watch_interval := manager.protocol_watch_interval_for_test(2)
	var species_tick := -1
	for candidate in range(manager.ghost_wake_tick_for_test() + 1, manager.ghost_wake_tick_for_test() + watch_interval * 4):
		if posmod(candidate + 2 + 2, watch_interval) == 0:
			species_tick = candidate
			break
	if species_tick < 0:
		failures.append("extended mutation trigger audit should find a deterministic ecology tick for protocol-watch escalation")
		manager.clear_runtime_context_for_test()
		root.remove_child(manager)
		manager.free()
		return
	var ecology_state: Dictionary = manager.advance_runtime_ecology_for_test(
		species_tick,
		{2: 1, 3: 2},
		{2: Vector2(1024, 0), 3: Vector2(2048, 0)},
		[2, 3],
		2,
		{2: 1}
	)
	var trigger_counts := {}
	for mutation_raw in Array(run_state.mutation_history):
		var mutation: Dictionary = mutation_raw
		var trigger_type := str(mutation.get("trigger_type", "")).strip_edges()
		trigger_counts[trigger_type] = int(trigger_counts.get(trigger_type, 0)) + 1
	if int(trigger_counts.get("chamber_entered", 0)) < 1:
		failures.append("room transitions into live evidence or hazard chambers should now invoke chamber_entered mutations")
	if int(trigger_counts.get("covenant_activated", 0)) < 1:
		failures.append("lawful covenant activation should now invoke covenant_activated mutations through the live host path")
	if int(trigger_counts.get("transformation_threshold_crossed", 0)) < 1:
		failures.append("threshold-ready reserve transformations should now invoke transformation_threshold_crossed mutations")
	if int(trigger_counts.get("species_escalation", 0)) < 1:
		failures.append("runtime ecology escalations should now invoke species_escalation mutations")
	var public_trace_classes := Array(Dictionary(run_state.truth_state).get("public_trace_classes", []))
	for required_trace in ["bargain", "transformation", "pressure_ecology"]:
		if not public_trace_classes.has(required_trace):
			failures.append("extended mutation triggers should deepen runtime truth-state with %s" % required_trace)
	var public_events: Array = Array(ecology_state.get("public", []))
	var saw_mutation_public := false
	for event_raw in public_events:
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) == "constitution_mutation":
			saw_mutation_public = true
			break
	if not saw_mutation_public:
		failures.append("extended ecology mutations should stay visible in the captured public event stream")
	manager.clear_runtime_context_for_test()
	root.remove_child(manager)
	manager.free()
	if created_run_state:
		root.remove_child(run_state)
		run_state.free()
	else:
		run_state.clear()
	if created_event_log:
		root.remove_child(event_log)
		event_log.free()
	else:
		event_log.clear()

func _test_artifact_service_naming_migration(failures: Array[String]) -> void:
	var artifact_service := ARTIFACT_SERVICE_SCRIPT.new()
	var evidence_service := EVIDENCE_SERVICE_SCRIPT.new()
	var room_chain := [
		{"slot": 1, "type": "evidence", "id": "evidence_vault", "hazard": "alarm"},
		{"slot": 2, "type": "hazard", "id": "hazard_push", "hazard": "push"}
	]
	if JSON.stringify(artifact_service.spawn_for_chain(7070, room_chain)) != JSON.stringify(evidence_service.spawn_for_chain(7070, room_chain)):
		failures.append("artifact_service should now be the canonical implementation owner while evidence_service remains a safe compatibility bridge")
	var forged_artifact: Dictionary = artifact_service.build_forged_artifact(7070, 5, 2, 1, Vector2(10, 20))
	if artifact_service.authenticity_state(forged_artifact) != "counterfeit" or evidence_service.authenticity_state(forged_artifact) != "counterfeit":
		failures.append("artifact authenticity should stay coherent across artifact_service and the evidence compatibility adapter")
	var manager := NETWORK_MANAGER_SCRIPT.new()
	if not manager.has_signal("artifact_state_changed"):
		failures.append("NetworkManager should expose a canonical artifact_state_changed signal during the naming migration")
	manager.free()

func _test_multimodal_contract_non_authority(failures: Array[String]) -> void:
	var state := MULTIMODAL_CONTRACT_SERVICE_SCRIPT.default_state()
	if bool(state.get("runtime_authority", true)):
		failures.append("multimodal contract defaults should remain non-authoritative")
	if MULTIMODAL_CONTRACT_SERVICE_SCRIPT.can_emit_summary(state, "voice_policy", "archive_summary"):
		failures.append("multimodal summaries should stay disabled until explicit consent is granted")
	var enabled := MULTIMODAL_CONTRACT_SERVICE_SCRIPT.set_modality_consent(state, "voice_policy", true)
	if not MULTIMODAL_CONTRACT_SERVICE_SCRIPT.can_emit_summary(enabled, "voice_policy", "archive_summary"):
		failures.append("archive summaries should be allowed after explicit voice consent")
	if MULTIMODAL_CONTRACT_SERVICE_SCRIPT.can_emit_summary(enabled, "voice_policy", "runtime_targeting"):
		failures.append("multimodal contracts must never allow runtime_targeting authority outputs")
	var poisoned_state := {
		"runtime_authority": true,
		"allowed_outputs": ["archive_summary", "runtime_targeting", "shell_summary"],
		"forbidden_outputs": [],
		"modalities": {
			"voice_policy": {"enabled": true, "consented": false}
		}
	}
	var normalized := MULTIMODAL_CONTRACT_SERVICE_SCRIPT.normalize(poisoned_state)
	if bool(normalized.get("runtime_authority", true)):
		failures.append("multimodal normalization should hard-disable runtime authority even when poisoned state requests it")
	if Array(normalized.get("allowed_outputs", [])).has("runtime_targeting"):
		failures.append("multimodal normalization should strip forbidden runtime outputs from the allowlist")
	if not Array(normalized.get("forbidden_outputs", [])).has("runtime_targeting"):
		failures.append("multimodal normalization should preserve the forbidden runtime targeting ban")
	if MULTIMODAL_CONTRACT_SERVICE_SCRIPT.can_emit_summary(poisoned_state, "voice_policy", "archive_summary"):
		failures.append("multimodal archive summaries should still require explicit consent even if enabled is forged true")
	var bounded_summary := MULTIMODAL_CONTRACT_SERVICE_SCRIPT.build_archive_summary(enabled, "voice_policy", "x".repeat(400))
	if str(bounded_summary.get("output_kind", "")) != "archive_summary":
		failures.append("archive summaries should retain an explicit non-authoritative output kind")
	if str(bounded_summary.get("summary_text", "")).length() > 280:
		failures.append("archive summaries should remain bounded under the multimodal contract")

func _test_constitution_summary_migration_and_aliases(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var canonical_summary := {
		"protocol_state": "Fracture Protocol",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Keep the burden readable.",
		"surface_summary": {"lines": ["Rescue geometry is drawing the public answer."]},
		"mind_balance": {"leak": true}
	}
	var payload := manager.build_run_start_payload(
		3030,
		[{"slot": 0, "type": "traversal"}],
		[2, 3],
		{"doctrine_label": "Legacy Drift", "surface_summary": {"lines": ["legacy"]}},
		"constitution_payload_hash",
		canonical_summary
	)
	if JSON.stringify(Dictionary(payload.get("directive_summary", {}))) != JSON.stringify(Dictionary(payload.get("constitution_summary", {}))):
		failures.append("run-start payloads should canonicalize directive_summary and constitution_summary to the same public-safe data")
	if str(Dictionary(payload.get("constitution_summary", {})).get("doctrine_label", "")) != "Measured Pressure":
		failures.append("run-start payloads should prefer constitution_summary over stale directive_summary adapters")
	if Dictionary(payload.get("constitution_summary", {})).has("promotion_review") or Dictionary(payload.get("constitution_summary", {})).has("disclosure_review"):
		failures.append("run-start payloads should not grow new structured governance or disclosure objects on constitution_summary")
	manager.free()

	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze({
		"seed": 3030,
		"local_peer_id": 2,
		"item_defs": ["custody_seal"],
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 3, "actor_peer_id": 2, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 22, "room_slot": 7, "actor_peer_id": -1, "event_type": "extraction_window_started", "visibility": "public", "meta": {"duration_ticks": 180}}
		],
		"communication_summary": {"total": 1, "regroup": 1},
		"key_clues": ["Artifact picked up at the threshold."],
		"action_summary": ["The burden stayed visible."],
		"gameplay_signal_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"group_signals": ["route control"],
				"fault_lines": ["split caution"],
				"model_pressure": ["route control"]
			}
		},
		"expedition_constitution_summary": canonical_summary
	})
	if Array(diagnostics.get("constitution_surface_summary", [])).is_empty():
		failures.append("diagnostics should expose constitution_surface_summary for canonical public-safe governance lines")
	if JSON.stringify(Array(diagnostics.get("constitution_surface_summary", []))) != JSON.stringify(Array(diagnostics.get("directive_surface_summary", []))):
		failures.append("directive_surface_summary should remain a compatibility alias of constitution_surface_summary during migration")
	var diagnostics_text := JSON.stringify(diagnostics)
	if diagnostics_text.find("mind_balance") != -1:
		failures.append("constitution summary readers should strip host-only Delve internals before diagnostics/archive use")

func _test_visual_mutation_stack_readability(failures: Array[String]) -> void:
	var visual_governance := VISUAL_GOVERNANCE_SCRIPT.new()
	var safe_failures := visual_governance.validate_mutation_stack({
		"silhouette_layer": {"major_signal": true},
		"trace_overlay_layer": {"major_signal": false}
	})
	if not safe_failures.is_empty():
		failures.append("safe mutation stacks should pass readability validation")
	var unsafe_failures := visual_governance.validate_mutation_stack({
		"silhouette_layer": {"major_signal": true},
		"carrier_frame_layer": {"major_signal": true, "hides_artifact_carrier": true},
		"trace_overlay_layer": {"major_signal": true},
		"aura_layer": {"major_signal": true}
	})
	if unsafe_failures.is_empty():
		failures.append("mutation stack readability validation should reject hidden carrier state and signal overload")

func _test_room_interior_microplans_and_exposed_spawns(failures: Array[String]) -> void:
	var source := FileAccess.open("res://src/gen/room_builder.gd", FileAccess.READ)
	if source == null:
		failures.append("room_builder should be readable for room interior planning tests")
		return
	var source_text := source.get_as_text()
	if source_text.find("const ROOM_COLUMNS := 5") == -1 or source_text.find("const ROOM_ROWS := 3") == -1:
		failures.append("room_builder should align room-specific interiors to the live 5x3 run grid")
	var builder = ROOM_BUILDER_SCRIPT.new()
	var traversal_plan: Dictionary = builder.build_room_micro_plan_for_test({"slot": 0, "id": "traverse_a", "type": "traversal", "hazard": "none"}, 1337)
	var traversal_plan_b: Dictionary = builder.build_room_micro_plan_for_test({"slot": 0, "id": "traverse_a", "type": "traversal", "hazard": "none"}, 1337)
	if JSON.stringify(traversal_plan) != JSON.stringify(traversal_plan_b):
		failures.append("room micro-plans should be deterministic for the same room and seed")
	var traversal_platforms: Array = traversal_plan.get("platforms", [])
	if traversal_platforms.size() < 3:
		failures.append("traversal rooms should create multiple regroup/split platforms")
	elif float(Dictionary(traversal_platforms[0]).get("y", 0.0)) >= float(Dictionary(traversal_platforms[1]).get("y", 0.0)):
		failures.append("traversal room split platforms should create meaningful height contrast")
	var evidence_plan: Dictionary = builder.build_room_micro_plan_for_test({"slot": 1, "id": "evidence_vault", "type": "evidence", "hazard": "alarm"}, 1337)
	if Dictionary(evidence_plan.get("pedestal", {})).is_empty():
		failures.append("evidence rooms should include an exposed pickup pedestal in the micro-plan")
	if Array(evidence_plan.get("markers", [])).size() < 2:
		failures.append("evidence rooms should include readable clue/route markers")
	var hazard_plan: Dictionary = builder.build_room_micro_plan_for_test({"slot": 13, "id": "hazard_push", "type": "hazard", "hazard": "push"}, 1337)
	var hazard_markers: Array = hazard_plan.get("markers", [])
	var saw_danger := false
	for marker_raw in hazard_markers:
		var marker: Dictionary = marker_raw
		if str(marker.get("kind", "")) == "danger":
			saw_danger = true
			break
	if not saw_danger:
		failures.append("hazard rooms should mark a dangerous commitment lane in the micro-plan")
	builder.free()

	var evidence_service := EVIDENCE_SERVICE_SCRIPT.new()
	var vault_pos := evidence_service.world_pos_for_room_spawn_for_test({"slot": 1, "id": "evidence_vault", "type": "evidence", "hazard": "alarm"}, 0)
	if vault_pos.x < 1400.0 or vault_pos.x > 1700.0 or vault_pos.y < 260.0 or vault_pos.y > 380.0:
		failures.append("evidence vault spawns should stay near the exposed center pedestal")
	var gap_pos := evidence_service.world_pos_for_room_spawn_for_test({"slot": 6, "id": "evidence_gap", "type": "evidence", "hazard": "collapse"}, 0)
	if gap_pos.x < 1700.0:
		failures.append("gap evidence spawns should bias toward the far exposed side of the room")

	var item_service := ITEM_SERVICE_SCRIPT.new()
	var traversal_item := item_service.world_pos_for_spawn_for_test(0, "traversal", "zipline_kit")
	if traversal_item.y >= 300.0:
		failures.append("traversal mobility tools should spawn on high-commitment interior perches")
	var hazard_item := item_service.world_pos_for_spawn_for_test(13, "hazard", "decoy_emitter")
	if hazard_item.x <= 3500.0:
		failures.append("hazard-room decoys should spawn on the far confusion side of the room")

func _test_role_secrecy_payload(failures: Array[String]) -> void:
	var service := ROLE_SERVICE_SCRIPT.new()
	var roles := service.assign_roles([1, 2, 3, 4], 10101)
	var payload := service.build_private_role_payload(str(roles.get(2, "")))
	if not payload.has("role"):
		failures.append("role payload missing role field")
	if str(payload.get("duty_line", "")).strip_edges().is_empty() or str(payload.get("caution_line", "")).strip_edges().is_empty():
		failures.append("role payload should now carry bounded private duty and caution lines without leaking the role map")
	if Array(payload.get("affordance_tags", [])).is_empty():
		failures.append("role payload should now carry bounded private affordance tags for embodied role asymmetry")
	if payload.has("roles_by_peer"):
		failures.append("role payload leaked full role map field")
	var role_name := str(payload.get("role", ""))
	if role_name not in ROLE_SERVICE_SCRIPT.new().all_role_names():
		failures.append("role payload contains invalid role '%s'" % role_name)

func _test_role_scaling_and_alignment(failures: Array[String]) -> void:
	var service := ROLE_SERVICE_SCRIPT.new()
	var midsize := service.role_counts_for_player_count(5)
	if int(midsize.get("warden", 0)) != 1 or int(midsize.get("veil", 0)) != 1 or int(midsize.get("steward", 0)) != 1 or int(midsize.get("scavenger", 0)) != 2:
		failures.append("role scaling should add a Steward before midsize lobbies fall back to pure Scavenger fill")
	var large := service.role_counts_for_player_count(10)
	if int(large.get("murmur", 0)) != 1 or int(large.get("bearer", 0)) != 1:
		failures.append("role scaling should add Murmur and Bearer in large lobbies without replacing the baseline Warden/Veil spine")
	if service.alignment_for_role(ROLE_SERVICE_SCRIPT.ROLE_VEIL) != ROLE_SERVICE_SCRIPT.ALIGNMENT_SABOTEUR:
		failures.append("Veil should align to the saboteur team")
	if service.alignment_for_role(ROLE_SERVICE_SCRIPT.ROLE_MURMUR) != ROLE_SERVICE_SCRIPT.ALIGNMENT_SABOTEUR:
		failures.append("Murmur should align to the saboteur team")
	if service.alignment_for_role(ROLE_SERVICE_SCRIPT.ROLE_WARDEN) != ROLE_SERVICE_SCRIPT.ALIGNMENT_EXPEDITION:
		failures.append("Warden should align to the expedition team")
	if service.alignment_for_role(ROLE_SERVICE_SCRIPT.ROLE_STEWARD) != ROLE_SERVICE_SCRIPT.ALIGNMENT_EXPEDITION or service.alignment_for_role(ROLE_SERVICE_SCRIPT.ROLE_BEARER) != ROLE_SERVICE_SCRIPT.ALIGNMENT_EXPEDITION:
		failures.append("Steward and Bearer should align to the expedition team")
	if not service.can_forge(ROLE_SERVICE_SCRIPT.ROLE_VEIL) or not service.can_forge(ROLE_SERVICE_SCRIPT.ROLE_MURMUR):
		failures.append("Veil and Murmur should both be lawful forge roles on the existing owner path")
	if not service.can_sabotage(ROLE_SERVICE_SCRIPT.ROLE_VEIL) or service.can_sabotage(ROLE_SERVICE_SCRIPT.ROLE_MURMUR):
		failures.append("camera-jam sabotage should stay specific to Veil while Murmur remains a witness-distortion saboteur")
	if not service.can_inspect(ROLE_SERVICE_SCRIPT.ROLE_WARDEN) or service.can_inspect(ROLE_SERVICE_SCRIPT.ROLE_STEWARD):
		failures.append("artifact inspection should stay Warden-specific under the expanded role ecology")
	if not service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_WARDEN, true, false):
		failures.append("Warden should win when the expedition succeeds")
	if not service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_VEIL, false, true):
		failures.append("Veil should win when sabotage succeeds")
	if not service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_MURMUR, false, true):
		failures.append("Murmur should win when sabotage succeeds")
	if service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER, false, true):
		failures.append("Scavenger should not win off sabotage success")
	if service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_BEARER, false, true):
		failures.append("Bearer should not win off sabotage success")

func _test_role_expansion_social_asymmetry(failures: Array[String]) -> void:
	var steward_clean := NETWORK_MANAGER_SCRIPT.new()
	steward_clean.is_host = true
	steward_clean.players = [2, 3]
	steward_clean.roles_by_peer = {
		2: ROLE_SERVICE_SCRIPT.ROLE_STEWARD,
		3: ROLE_SERVICE_SCRIPT.ROLE_BEARER
	}
	steward_clean.player_room_by_peer = {2: 4, 3: 4}
	steward_clean.player_pos_by_peer = {2: Vector2(120, 100), 3: Vector2(126, 100)}
	steward_clean.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 3, "room_slot": 4, "world_pos": Vector2(126, 100), "is_forged": false, "signature": "A0000201", "spawn_index": 0}
	}
	steward_clean.custody_debt_by_peer = {3: 2}
	steward_clean.suspicion_heat_by_peer = {3: 2}
	var steward_watch_before := steward_clean.protocol_watch_interval_for_test(3)
	var steward := NETWORK_MANAGER_SCRIPT.new()
	steward.is_host = true
	steward.players = steward_clean.players.duplicate()
	steward.roles_by_peer = steward_clean.roles_by_peer.duplicate(true)
	steward.player_room_by_peer = steward_clean.player_room_by_peer.duplicate(true)
	steward.player_pos_by_peer = steward_clean.player_pos_by_peer.duplicate(true)
	steward.artifacts_by_id = steward_clean.artifacts_by_id.duplicate(true)
	steward.custody_debt_by_peer = steward_clean.custody_debt_by_peer.duplicate(true)
	steward.suspicion_heat_by_peer = steward_clean.suspicion_heat_by_peer.duplicate(true)
	steward.begin_event_capture_for_test()
	steward.host_callout_for_test(2, "artifact", 4)
	var steward_runtime := steward.get_role_custody_runtime_for_test(3)
	if int(steward_runtime.get("custody_debt", 0)) >= 2 or int(steward_runtime.get("suspicion_heat", 0)) >= 2:
		failures.append("Steward callouts should materially steady contested custody instead of staying pure flavor")
	if steward.protocol_watch_interval_for_test(3) <= steward_watch_before:
		failures.append("Steward witness pressure should materially relax watch cadence once the public line is steadied")
	if Array(Dictionary(steward.end_event_capture_for_test()).get("private", [])).is_empty():
		failures.append("expanded role asymmetry should leave readable private notes on the existing note path")
	steward.free()
	steward_clean.free()

	var murmur_clean := NETWORK_MANAGER_SCRIPT.new()
	murmur_clean.is_host = true
	murmur_clean.players = [4, 5]
	murmur_clean.roles_by_peer = {
		4: ROLE_SERVICE_SCRIPT.ROLE_MURMUR,
		5: ROLE_SERVICE_SCRIPT.ROLE_BEARER
	}
	murmur_clean.player_room_by_peer = {4: 6, 5: 6}
	murmur_clean.player_pos_by_peer = {4: Vector2(220, 100), 5: Vector2(226, 100)}
	murmur_clean.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 5, "room_slot": 6, "world_pos": Vector2(226, 100), "is_forged": false, "signature": "A0000202", "spawn_index": 0}
	}
	var murmur_watch_before := murmur_clean.protocol_watch_interval_for_test(5)
	var murmur := NETWORK_MANAGER_SCRIPT.new()
	murmur.is_host = true
	murmur.players = murmur_clean.players.duplicate()
	murmur.roles_by_peer = murmur_clean.roles_by_peer.duplicate(true)
	murmur.player_room_by_peer = murmur_clean.player_room_by_peer.duplicate(true)
	murmur.player_pos_by_peer = murmur_clean.player_pos_by_peer.duplicate(true)
	murmur.artifacts_by_id = murmur_clean.artifacts_by_id.duplicate(true)
	murmur.host_callout_for_test(4, "artifact", 6)
	var murmur_runtime := murmur.get_role_custody_runtime_for_test(5)
	if int(murmur_runtime.get("suspicion_heat", 0)) <= 0:
		failures.append("Murmur callouts should materially distort witness pressure onto the live carrier")
	if murmur.protocol_watch_interval_for_test(5) >= murmur_watch_before:
		failures.append("Murmur witness distortion should materially tighten watch cadence on the carrier")
	if murmur.choose_protocol_watch_peer_for_test() != 5:
		failures.append("Murmur witness distortion should make the live carrier the preferred watch target")
	murmur.free()
	murmur_clean.free()

	var bearer_clean := NETWORK_MANAGER_SCRIPT.new()
	bearer_clean.is_host = true
	bearer_clean.players = [6, 7]
	bearer_clean.roles_by_peer = {
		6: ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		7: ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER
	}
	bearer_clean.player_room_by_peer = {6: 8, 7: 8}
	bearer_clean.player_pos_by_peer = {6: Vector2(320, 100), 7: Vector2(326, 100)}
	bearer_clean.extraction_room_slot = 8
	bearer_clean.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 6, "room_slot": 8, "world_pos": Vector2(320, 100), "is_forged": false, "signature": "A0000203", "spawn_index": 0}
	}
	var bearer_ticks_clean := bearer_clean.extraction_window_ticks_for_test()
	var bearer_watch_clean := bearer_clean.protocol_watch_interval_for_test(6)
	var bearer := NETWORK_MANAGER_SCRIPT.new()
	bearer.is_host = true
	bearer.players = bearer_clean.players.duplicate()
	bearer.roles_by_peer = {
		6: ROLE_SERVICE_SCRIPT.ROLE_BEARER,
		7: ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER
	}
	bearer.player_room_by_peer = bearer_clean.player_room_by_peer.duplicate(true)
	bearer.player_pos_by_peer = bearer_clean.player_pos_by_peer.duplicate(true)
	bearer.extraction_room_slot = bearer_clean.extraction_room_slot
	bearer.artifacts_by_id = bearer_clean.artifacts_by_id.duplicate(true)
	if bearer.extraction_window_ticks_for_test() >= bearer_ticks_clean:
		failures.append("Bearer custody should materially shorten live extraction pressure once the authentic line reaches extraction")
	if bearer.protocol_watch_interval_for_test(6) >= bearer_watch_clean:
		failures.append("Bearer custody should materially tighten watch cadence once the burden line becomes visible")
	bearer.free()
	bearer_clean.free()

func _test_artifact_signature_determinism(failures: Array[String]) -> void:
	var evidence := EVIDENCE_SERVICE_SCRIPT.new()
	var sig_a := evidence.real_signature(4242, 5, 3, 1)
	var sig_b := evidence.real_signature(4242, 5, 3, 1)
	if sig_a != sig_b:
		failures.append("real signature not deterministic")

	var chain := RUN_GENERATOR_SCRIPT.new().generate_layout(777, 15)
	var artifacts_a := evidence.spawn_for_chain(777, chain)
	var artifacts_b := evidence.spawn_for_chain(777, chain)
	if JSON.stringify(artifacts_a) != JSON.stringify(artifacts_b):
		failures.append("artifact spawn list not deterministic for same seed and chain")

func _test_artifact_ownership_logic(failures: Array[String]) -> void:
	var evidence := EVIDENCE_SERVICE_SCRIPT.new()
	var artifact := {
		"artifact_id": 1,
		"room_slot": 1,
		"spawn_index": 0,
		"signature": "A000001",
		"is_forged": false,
		"owner_peer_id": 0,
		"world_pos": Vector2(100, 100)
	}
	if not evidence.can_pickup(artifact, Vector2(110, 104)):
		failures.append("expected pickup to be valid in range for unowned artifact")

	var carried := evidence.apply_owner(artifact, 2, Vector2(110, 104))
	if evidence.can_pickup(carried, Vector2(110, 104)):
		failures.append("pickup should fail while artifact is owned")
	if not evidence.can_drop(carried, 2):
		failures.append("owner should be allowed to drop artifact")
	if evidence.can_drop(carried, 3):
		failures.append("non-owner should not be allowed to drop artifact")
	if evidence.can_steal(carried, Vector2(10, 10), Vector2(300, 300)):
		failures.append("steal should fail when not in range")
	if not evidence.can_steal(carried, Vector2(110, 104), Vector2(126, 104)):
		failures.append("steal should succeed when in range of carrier")

func _test_public_sabotage_anonymity(failures: Array[String]) -> void:
	var helpers = NET_HELPERS_SCRIPT.new()
	var event := helpers.build_event_for_test("hazard_state_changed", 42, 1, 3, -1, "public", helpers.public_meta_allowlist("hazard_state_changed", {"timing_nudge": true}))
	if int(event.get("actor_peer_id", 999)) != -1:
		failures.append("public hazard event must anonymize actor_peer_id as -1")
	var meta: Dictionary = event.get("meta", {})
	for banned in ["sabotage", "timing_nudge", "forged_hint"]:
		if meta.has(banned):
			failures.append("public hazard event meta leaked '%s'" % banned)

func _test_one_carry_rule(failures: Array[String]) -> void:
	var helpers = NET_HELPERS_SCRIPT.new()
	var artifacts := {
		1: {"artifact_id": 1, "owner_peer_id": 8, "world_pos": Vector2(0, 0), "room_slot": 0},
		2: {"artifact_id": 2, "owner_peer_id": 0, "world_pos": Vector2(10, 0), "room_slot": 0},
		3: {"artifact_id": 3, "owner_peer_id": 9, "world_pos": Vector2(12, 0), "room_slot": 0}
	}
	var pickup_result: Dictionary = helpers.simulate_pickup_request_for_test(artifacts, 8, 2, Vector2(10, 0), 0)
	if bool(pickup_result.get("changed", true)):
		failures.append("pickup should be denied when requester already carries artifact")
	if bool(pickup_result.get("public_event_emitted", true)):
		failures.append("pickup denial should not emit public event")
	if JSON.stringify(pickup_result.get("artifacts_state", {})) != JSON.stringify(artifacts):
		failures.append("pickup denial should not mutate host artifact state")

	var steal_result: Dictionary = helpers.simulate_steal_request_for_test(artifacts, 8, 3, Vector2(12, 0), Vector2(12, 0), 0, 0)
	if bool(steal_result.get("changed", true)):
		failures.append("steal should be denied when requester already carries artifact")
	if bool(steal_result.get("public_event_emitted", true)):
		failures.append("steal denial should not emit public event")
	if JSON.stringify(steal_result.get("artifacts_state", {})) != JSON.stringify(artifacts):
		failures.append("steal denial should not mutate host artifact state")

func _test_spelunky_tool_inventory_authority(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	manager.reset_tool_inventory_for_test([1, 2], 4, 4)
	var peer_one_counts: Dictionary = manager.get_tool_counts_for_peer(1)
	if int(peer_one_counts.get("bomb", -1)) != 4 or int(peer_one_counts.get("rope", -1)) != 4:
		failures.append("tool inventory should initialize deterministically for each peer")
	for _i in range(4):
		if not manager.consume_tool_charge_for_test(1, "bomb"):
			failures.append("bomb charges should be consumable until inventory reaches zero")
			break
	if manager.consume_tool_charge_for_test(1, "bomb"):
		failures.append("bomb consumption should be denied once authoritative inventory reaches zero")
	for _i in range(4):
		if not manager.consume_tool_charge_for_test(2, "rope"):
			failures.append("rope charges should be consumable until inventory reaches zero")
			break
	if manager.consume_tool_charge_for_test(2, "rope"):
		failures.append("rope consumption should be denied once authoritative inventory reaches zero")
	var peer_two_counts: Dictionary = manager.get_tool_counts_for_peer(2)
	if int(peer_two_counts.get("bomb", -1)) != 4 or int(peer_two_counts.get("rope", -1)) != 0:
		failures.append("tool inventory should mutate only the requested tool type for the requested peer")
	manager.free()

func _test_current_era_tool_slot_limit(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	manager.player_pos_by_peer = {2: Vector2(64, 64)}
	manager.player_room_by_peer = {2: 1}
	manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "timeline_bookmark", "display_name": "Timeline Bookmark", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "room_slot": 1, "consumed": false},
		2: {"item_id": 2, "item_def_id": "decoy_emitter", "display_name": "Decoy Emitter", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "room_slot": 1, "consumed": false},
		3: {"item_id": 3, "item_def_id": "zipline_kit", "display_name": "Zipline Kit", "owner_peer_id": 0, "world_pos": Vector2(64, 64), "room_slot": 1, "consumed": false}
	}
	manager.begin_event_capture_for_test()
	manager.host_pickup_item_for_test(2, 3)
	var captured: Dictionary = manager.end_event_capture_for_test()
	if int(Dictionary(manager.items_by_id.get(3, {})).get("owner_peer_id", -1)) != 0:
		failures.append("tool pickup should be denied once the current-era two-tool carry limit is full")
	if manager.get_active_items_for_peer(2).size() != 2:
		failures.append("denied third-tool pickup should not mutate the authoritative active tool inventory")
	if not Array(captured.get("public", [])).is_empty():
		failures.append("denied third-tool pickup should not emit public item events")
	var private_events: Array = captured.get("private", [])
	if private_events.is_empty() or str(Dictionary(Dictionary(private_events[0]).get("meta", {})).get("reason", "")) != "tool_slots_full":
		failures.append("denied third-tool pickup should surface the host-side tool slot denial reason")
	manager.free()

func _test_tool_slot_reopens_after_use(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	manager.player_pos_by_peer = {2: Vector2(64, 64)}
	manager.player_room_by_peer = {2: 3}
	manager.current_server_tick = 120
	manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "timeline_bookmark", "display_name": "Timeline Bookmark", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "room_slot": 3, "consumed": false},
		2: {"item_id": 2, "item_def_id": "decoy_emitter", "display_name": "Decoy Emitter", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "room_slot": 3, "consumed": false},
		3: {"item_id": 3, "item_def_id": "zipline_kit", "display_name": "Zipline Kit", "owner_peer_id": 0, "world_pos": Vector2(64, 64), "room_slot": 3, "consumed": false}
	}
	manager.begin_event_capture_for_test()
	manager.host_use_item_for_test(2, 1, 3)
	manager.host_pickup_item_for_test(2, 3)
	var captured: Dictionary = manager.end_event_capture_for_test()
	if not bool(Dictionary(manager.items_by_id.get(1, {})).get("consumed", false)):
		failures.append("using a carried tool should consume that tool and reopen the slot")
	if int(Dictionary(manager.items_by_id.get(3, {})).get("owner_peer_id", -1)) != 2:
		failures.append("a freed tool slot should allow the next in-range tool pickup on the same host path")
	if manager.get_active_items_for_peer(2).size() != 2:
		failures.append("tool slot recovery should leave the peer with exactly two active tools after replacement pickup")
	var public_events: Array = captured.get("public", [])
	var saw_use := false
	var saw_pickup := false
	for event_raw in public_events:
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type == "item_used":
			saw_use = true
		elif event_type == "item_picked":
			saw_pickup = true
	if not saw_use or not saw_pickup:
		failures.append("freeing and refilling a tool slot should stay on the normal host item-used and item-picked event path")
	manager.free()

func _test_relic_pickup_stays_outside_tool_slot_cap(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	manager.player_pos_by_peer = {2: Vector2(64, 64)}
	manager.player_room_by_peer = {2: 2}
	manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "timeline_bookmark", "display_name": "Timeline Bookmark", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "room_slot": 2, "consumed": false},
		2: {"item_id": 2, "item_def_id": "decoy_emitter", "display_name": "Decoy Emitter", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "room_slot": 2, "consumed": false},
		3: {"item_id": 3, "item_def_id": "heavy_boots", "display_name": "Heavy Boots", "owner_peer_id": 0, "world_pos": Vector2(64, 64), "room_slot": 2, "consumed": false}
	}
	manager.begin_event_capture_for_test()
	manager.host_pickup_item_for_test(2, 3)
	var captured: Dictionary = manager.end_event_capture_for_test()
	if int(Dictionary(manager.items_by_id.get(3, {})).get("owner_peer_id", -1)) != 2:
		failures.append("relic pickup should remain available even when the current-era two-tool carry limit is full")
	if manager.get_active_items_for_peer(2).size() != 2:
		failures.append("relic pickup should not consume an active tool slot")
	if manager.get_carry_speed_multiplier_for_peer(2) >= 1.0:
		failures.append("picked relics should still apply their bounded passive carry effects through the existing owner path")
	if Array(captured.get("public", [])).is_empty():
		failures.append("successful relic pickup should remain on the normal public item pickup path")
	manager.free()

func _test_forge_determinism(failures: Array[String]) -> void:
	var evidence := EVIDENCE_SERVICE_SCRIPT.new()
	var a := evidence.build_forged_artifact(9911, 77, 4, 6, Vector2(100, 200))
	var b := evidence.build_forged_artifact(9911, 77, 4, 6, Vector2(100, 200))
	if int(a.get("spawn_index", -1)) != int(b.get("spawn_index", -2)):
		failures.append("forged spawn_index should be deterministic for same forge counter state")
	if str(a.get("signature", "")) != str(b.get("signature", "")):
		failures.append("forged signature should be deterministic for same seed/counter state")
	if int(a.get("spawn_index", -1)) != posmod(6, 4):
		failures.append("forged spawn_index should derive from forge counter, not server tick")

func _test_public_meta_allowlist(failures: Array[String]) -> void:
	var helpers = NET_HELPERS_SCRIPT.new()
	var contaminated := {
		"artifact_id": 12,
		"from_peer": 8,
		"role": "Veil",
		"forged_hint": true,
		"timing_nudge": true,
		"sabotage": true
	}
	var picked_meta: Dictionary = helpers.public_meta_allowlist("artifact_picked", contaminated)
	if picked_meta.size() != 1 or int(picked_meta.get("artifact_id", -1)) != 12:
		failures.append("artifact_picked allowlist should keep only artifact_id")

	var stolen_meta: Dictionary = helpers.public_meta_allowlist("artifact_stolen", contaminated)
	if not stolen_meta.has("artifact_id") or not stolen_meta.has("from_peer"):
		failures.append("artifact_stolen allowlist should keep artifact_id/from_peer")
	for banned in ["role", "forged_hint", "timing_nudge", "sabotage"]:
		if stolen_meta.has(banned):
			failures.append("artifact_stolen public meta leaked '%s'" % banned)

	var hazard_meta: Dictionary = helpers.public_meta_allowlist("hazard_state_changed", contaminated)
	if not hazard_meta.is_empty():
		failures.append("hazard_state_changed public meta must be empty")

	var unknown_meta: Dictionary = helpers.public_meta_allowlist("unknown_type", contaminated)
	if not unknown_meta.is_empty():
		failures.append("unknown public event type must produce empty meta")

func _test_event_id_determinism(failures: Array[String]) -> void:
	var helpers = NET_HELPERS_SCRIPT.new()
	var event_a: Dictionary = helpers.build_event_for_test("artifact_picked", 10, 1, 1, 2, "public", {})
	var event_b: Dictionary = helpers.build_event_for_test("artifact_dropped", 10, 2, 1, 2, "public", {})
	if int(event_a.get("event_id", -1)) != 1:
		failures.append("first event_id should be 1 on fresh manager")
	if int(event_b.get("event_id", -1)) != 2:
		failures.append("second event_id should increment deterministically")
	if int(event_a.get("tick", -1)) > int(event_b.get("tick", -1)):
		failures.append("event ordering should remain stable by tick/event_id")

func _test_warden_check_determinism(failures: Array[String]) -> void:
	var helpers = NET_HELPERS_SCRIPT.new()
	var artifact := {
		"artifact_id": 19,
		"room_slot": 2,
		"signature": "F1234ABC"
	}
	var score_a := int(helpers.compute_warden_score_for_test(555, artifact, 4))
	var score_b := int(helpers.compute_warden_score_for_test(555, artifact, 4))
	if score_a != score_b:
		failures.append("warden check score should be deterministic for same state")

func _test_pickup_denied_cross_room(failures: Array[String]) -> void:
	var helpers = NET_HELPERS_SCRIPT.new()
	var artifacts := {
		2: {"artifact_id": 2, "owner_peer_id": 0, "world_pos": Vector2(10, 0), "room_slot": 3}
	}
	var result: Dictionary = helpers.simulate_pickup_request_for_test(artifacts, 8, 2, Vector2(10, 0), 2)
	if bool(result.get("changed", true)):
		failures.append("pickup should be denied when requester room slot differs from artifact room slot")
	if bool(result.get("public_event_emitted", true)):
		failures.append("cross-room pickup denial should not emit public event")

func _test_steal_denied_cross_room(failures: Array[String]) -> void:
	var helpers = NET_HELPERS_SCRIPT.new()
	var artifacts := {
		3: {"artifact_id": 3, "owner_peer_id": 9, "world_pos": Vector2(12, 0), "room_slot": 4}
	}
	var result: Dictionary = helpers.simulate_steal_request_for_test(artifacts, 8, 3, Vector2(12, 0), Vector2(12, 0), 2, 4)
	if bool(result.get("changed", true)):
		failures.append("steal should be denied when requester/victim/artifact slots differ")
	if bool(result.get("public_event_emitted", true)):
		failures.append("cross-room steal denial should not emit public event")

func _test_room_builder_indicator_visual_only(failures: Array[String]) -> void:
	var script_path := "res://src/gen/room_builder.gd"
	if not FileAccess.file_exists(script_path):
		failures.append("room_builder script missing for visual-only guard test")
		return
	var file := FileAccess.open(script_path, FileAccess.READ)
	if file == null:
		failures.append("failed to open room_builder script for visual-only guard test")
		return
	var text := file.get_as_text()
	if text.find("RunState.") != -1:
		failures.append("room_builder should not write/read RunState for visual indicator logic")
	if text.find("NetworkManager.") != -1:
		failures.append("room_builder should not write/read NetworkManager for visual indicator logic")

func _test_crusher_trap_determinism_and_room_mapping(failures: Array[String]) -> void:
	var crusher = CRUSHER_SCRIPT.new()
	var extend_a := crusher.travel_fraction_for_tick_for_test(10)
	var extend_b := crusher.travel_fraction_for_tick_for_test(10)
	var hold := crusher.travel_fraction_for_tick_for_test(CRUSHER_SCRIPT.EXTEND_TICKS + 5)
	var retract := crusher.travel_fraction_for_tick_for_test(CRUSHER_SCRIPT.EXTEND_TICKS + CRUSHER_SCRIPT.HOLD_TICKS + 10)
	var idle := crusher.travel_fraction_for_tick_for_test(CRUSHER_SCRIPT.CYCLE_TICKS - 1)
	if !is_equal_approx(extend_a, extend_b):
		failures.append("crusher travel fraction should be deterministic for the same tick")
	if hold < 0.99:
		failures.append("crusher should be fully extended during the hold window")
	if retract >= 1.0 or retract <= 0.0:
		failures.append("crusher should retract smoothly after the hold window")
	if idle > 0.05:
		failures.append("crusher should return close to idle before the next cycle")
	crusher.free()
	var file := FileAccess.open("res://src/gen/room_builder.gd", FileAccess.READ)
	if file == null:
		failures.append("room_builder should be readable for crusher mapping test")
		return
	var text := file.get_as_text()
	if text.find("== \"collapse\"") == -1 or text.find("_add_crusher(") == -1:
		failures.append("room_builder should map collapse hazards to deterministic crusher traps")

func _test_core_item_sandbox_alignment_and_use(failures: Array[String]) -> void:
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var expected_ids: Array[String] = ["lantern_snuffer", "heavy_boots", "timeline_bookmark", "decoy_emitter", "zipline_kit", "custody_seal", "witness_chime", "echo_lure", "burden_sling"]
	if JSON.stringify(item_service.ITEM_IDS) != JSON.stringify(expected_ids):
		failures.append("item sandbox should align to the expanded lawful pickup set")
	var def_failures := item_service.validate_item_defs()
	if not def_failures.is_empty():
		failures.append("item metadata definitions should remain complete for the active sandbox")
	if item_service.get_light_scale_for_items(["lantern_snuffer"]) >= 1.0:
		failures.append("lantern snuffer should deterministically reduce local light scale")
	if item_service.move_speed_multiplier_for_items(["heavy_boots"]) >= 1.0 or item_service.jump_velocity_multiplier_for_items(["heavy_boots"]) >= 1.0:
		failures.append("heavy boots should deterministically trade mobility for trace pressure")
	if item_service.footprint_scale_for_items(["heavy_boots"]) <= 1.0:
		failures.append("heavy boots should amplify footprint readability")
	if not item_service.is_active_use_item("timeline_bookmark") or not item_service.is_active_use_item("decoy_emitter") or not item_service.is_active_use_item("zipline_kit") or not item_service.is_active_use_item("custody_seal") or not item_service.is_active_use_item("witness_chime") or not item_service.is_active_use_item("echo_lure"):
		failures.append("timeline bookmark, decoy emitter, zipline kit, custody seal, witness chime, and echo lure should be active-use items")
	if item_service.is_active_use_item("lantern_snuffer") or item_service.is_active_use_item("heavy_boots") or item_service.is_active_use_item("burden_sling"):
		failures.append("lantern snuffer, heavy boots, and burden sling should remain passive sandbox items")
	if item_service.get_category("zipline_kit") != "tool":
		failures.append("zipline kit should remain a tool-category mobility item")
	if item_service.carry_speed_multiplier_for_items(["burden_sling"]) <= 1.0:
		failures.append("burden sling should materially improve carried-burden speed on the lawful loadout path")
	if not item_service.get_archetypes("zipline_kit").has("mobility infrastructure"):
		failures.append("zipline kit should advertise its mobility infrastructure archetype")
	var zipline_profile := item_service.build_authoring_profile("zipline_kit")
	if str(Dictionary(zipline_profile.get("behavior", {})).get("placement_rules", "")) != "valid_room_edges_only":
		failures.append("zipline kit should codify valid room-edge placement rules in the authoring profile")
	if str(Dictionary(zipline_profile.get("evidence", {})).get("public_evidence", "")) != "placed_zipline":
		failures.append("zipline kit should codify its public evidence output in the authoring profile")
	var spawned_items: Array = item_service.generate_item_spawns(1337, [
		{"slot": 0},
		{"slot": 5},
		{"slot": 6}
	])
	if spawned_items.size() < 2:
		failures.append("item sandbox should deterministically spawn pickups for even room slots")
	else:
		var lower_row_item: Dictionary = spawned_items[1]
		var lower_row_pos: Vector2 = lower_row_item.get("world_pos", Vector2.ZERO)
		if lower_row_pos.y < 768.0:
			failures.append("item pickups should align to the same multi-row room grid as evidence")

func _test_content_breadth_expansion_and_coupling(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var visual_governance := VISUAL_GOVERNANCE_SCRIPT.new()
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var oath_directive := {
		"generation_contract": {
			"protocol_state": "Intimate Protocol",
			"relationship_routing": {
				"escort_expectation": 2,
				"obligation_risk": 1
			},
			"civilization_routing": {
				"legitimacy_custody": 2,
				"sacred_order": 1
			}
		}
	}
	var murmur_directive := {
		"generation_contract": {
			"protocol_state": "Fracture Protocol",
			"cookbook_routing": {
				"counter_reading": 2,
				"anti_protocol_pull": 2
			},
			"civilization_routing": {
				"canon_conflict": 2,
				"ontology_heat": 1
			}
		}
	}
	var oath_weights := generator.branch_family_weights_for_test(oath_directive)
	var murmur_weights := generator.branch_family_weights_for_test(murmur_directive)
	if int(oath_weights.get("oath_terraces", 0)) <= int(oath_weights.get("murmur_warrens", 0)):
		failures.append("content breadth expansion should favor oath_terraces when custody/oath routing is dominant")
	if int(murmur_weights.get("murmur_warrens", 0)) <= int(murmur_weights.get("oath_terraces", 0)):
		failures.append("content breadth expansion should favor murmur_warrens when counter-reading and canon conflict dominate")
	var oath_room_weights := generator.room_type_weights_for_branch_for_test(6, 15, "oath_terraces", oath_directive)
	var murmur_room_weights := generator.room_type_weights_for_branch_for_test(6, 15, "murmur_warrens", murmur_directive)
	if int(oath_room_weights.get("traversal", 0)) <= int(murmur_room_weights.get("traversal", 0)):
		failures.append("oath_terraces should read as a more escorted route than murmur_warrens")
	if int(murmur_room_weights.get("hazard", 0)) <= int(oath_room_weights.get("hazard", 0)):
		failures.append("murmur_warrens should read as a harsher route than oath_terraces")
	var oath_profile := visual_governance.branch_visual_profile("oath_terraces", "Intimate Protocol")
	var murmur_profile := visual_governance.branch_visual_profile("murmur_warrens", "Fracture Protocol")
	if str(oath_profile.get("far_shape", "")) == str(murmur_profile.get("far_shape", "")) or str(oath_profile.get("mid_rhythm", "")) == str(murmur_profile.get("mid_rhythm", "")):
		failures.append("new branch families should have materially distinct visual profiles")
	var oath_room := {
		"slot": 2,
		"type": "evidence",
		"branch_family_id": "oath_terraces",
		"protocol_state": "Intimate Protocol"
	}
	var murmur_room := {
		"slot": 2,
		"type": "hazard",
		"branch_family_id": "murmur_warrens",
		"protocol_state": "Fracture Protocol"
	}
	if item_service.directive_bonus_for_item_for_test("custody_seal", oath_directive, oath_room) <= item_service.directive_bonus_for_item_for_test("echo_lure", oath_directive, oath_room):
		failures.append("custody-aligned rooms should favor custody_seal over echo_lure")
	if item_service.directive_bonus_for_item_for_test("echo_lure", murmur_directive, murmur_room) <= item_service.directive_bonus_for_item_for_test("custody_seal", murmur_directive, murmur_room):
		failures.append("counter-reading rooms should favor echo_lure over custody_seal")
	var oath_chain_a := generator.generate_layout(9021, 15, oath_directive)
	var oath_chain_b := generator.generate_layout(9021, 15, oath_directive)
	if JSON.stringify(oath_chain_a) != JSON.stringify(oath_chain_b):
		failures.append("expanded branch breadth should remain deterministic for identical seeds and directives")
	var murmur_chain := generator.generate_layout(9021, 15, murmur_directive)
	if JSON.stringify(oath_chain_a) == JSON.stringify(murmur_chain):
		failures.append("expanded branch breadth should materially change route generation across new family pressures")
	var oath_spawns_a := item_service.generate_item_spawns(9021, oath_chain_a, oath_directive)
	var oath_spawns_b := item_service.generate_item_spawns(9021, oath_chain_a, oath_directive)
	if JSON.stringify(oath_spawns_a) != JSON.stringify(oath_spawns_b):
		failures.append("expanded item breadth should remain deterministic for identical seeds and directives")
	var murmur_spawns := item_service.generate_item_spawns(9021, murmur_chain, murmur_directive)
	if JSON.stringify(oath_spawns_a) == JSON.stringify(murmur_spawns):
		failures.append("expanded item breadth should materially change item spawns across distinct new route doctrines")

	var root := get_root()
	var event_log = root.get_node_or_null("EventLog")
	var created_log := false
	if event_log == null:
		event_log = EVENT_LOG_SCRIPT.new()
		event_log.name = "EventLog"
		root.add_child(event_log)
		created_log = true
	if event_log.has_method("clear"):
		event_log.clear()
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	manager.run_active = true
	manager.players = [2]
	manager.roles_by_peer = {2: ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER}
	manager.player_room_by_peer = {2: 3}
	manager.current_server_tick = 240
	manager.extraction_room_slot = 7
	manager.next_event_id = 1
	manager.artifacts_by_id = {
		99: {"artifact_id": 99, "owner_peer_id": 2, "room_slot": 3, "world_pos": Vector2.ZERO, "is_forged": false, "signature": "A0000001", "spawn_index": 0}
	}
	manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "timeline_bookmark", "display_name": "Timeline Bookmark", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "consumed": false},
		2: {"item_id": 2, "item_def_id": "decoy_emitter", "display_name": "Decoy Emitter", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "consumed": false},
		3: {"item_id": 3, "item_def_id": "zipline_kit", "display_name": "Zipline Kit", "owner_peer_id": 2, "world_pos": Vector2.ZERO, "consumed": false}
	}
	var zipline_segment_a := manager.compute_zipline_segment_for_test(3, Vector2(3200, 300))
	var zipline_segment_b := manager.compute_zipline_segment_for_test(3, Vector2(3200, 300))
	if JSON.stringify(zipline_segment_a) != JSON.stringify(zipline_segment_b):
		failures.append("zipline placement should be deterministic for the same room slot and anchor position")
	manager.begin_event_capture_for_test()
	manager.host_use_item_for_test(2, 1, 3)
	manager.host_use_item_for_test(2, 2, 3)
	manager.host_use_item_for_test(2, 3, 3)
	var captured: Dictionary = manager.end_event_capture_for_test()
	var public_events: Array = captured.get("public", [])
	var private_events: Array = captured.get("private", [])
	var saw_bookmark := false
	var saw_decoy := false
	var saw_zipline := false
	var decoy_noise_count := 0
	for event_raw in public_events:
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type == "item_used" and str(Dictionary(event.get("meta", {})).get("label", "")).find("Timeline bookmark") != -1:
			saw_bookmark = true
		if event_type == "item_used" and str(Dictionary(event.get("meta", {})).get("label", "")).find("Decoy emitter") != -1:
			saw_decoy = true
		if event_type == "item_used" and str(Dictionary(event.get("meta", {})).get("label", "")).find("Zipline") != -1:
			saw_zipline = true
		if event_type == "noise_trace":
			decoy_noise_count += 1
	if not saw_bookmark:
		failures.append("timeline bookmark use should emit a public item_used fact")
	if not saw_decoy or decoy_noise_count < 2:
		failures.append("scavenger decoy emitter should create public route confusion without authorship")
	if not saw_zipline:
		failures.append("zipline kit use should emit an anonymous public item_used fact")
	if not bool(Dictionary(manager.items_by_id[1]).get("consumed", false)) or not bool(Dictionary(manager.items_by_id[2]).get("consumed", false)) or not bool(Dictionary(manager.items_by_id[3]).get("consumed", false)):
		failures.append("core active items should be consumed by authoritative use")
	var saw_private_note := false
	var saw_reroute_note := false
	var saw_zipline_note := false
	for event_raw in private_events:
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) != "item_note":
			continue
		saw_private_note = true
		if str(Dictionary(event.get("meta", {})).get("label", "")).find("rerouted Artifact 99 to room 4") != -1:
			saw_reroute_note = true
		if str(Dictionary(event.get("meta", {})).get("label", "")).find("Zipline stretched across room 3") != -1:
			saw_zipline_note = true
	if not saw_private_note:
		failures.append("core active item use should create private local notes")
	if not saw_reroute_note:
		failures.append("scavenger decoy emitter should leave a private reroute note for the carrier")
	if not saw_zipline_note:
		failures.append("zipline kit should leave a private local note for later replay review")
	var saw_reroute_drop := false
	for event_raw in public_events:
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) != "artifact_dropped":
			continue
		if int(event.get("actor_peer_id", -2)) == -1 and int(Dictionary(event.get("meta", {})).get("artifact_id", 0)) == 99:
			saw_reroute_drop = true
			break
	if not saw_reroute_drop:
		failures.append("scavenger reroute should surface as an ambiguous public artifact drop fact")
	manager.free()
	if created_log:
		root.remove_child(event_log)
		event_log.free()

func _test_artifact_outcome_logic(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var authentic := {
		11: {"artifact_id": 11, "owner_peer_id": 2, "room_slot": 7, "world_pos": Vector2.ZERO, "is_forged": false, "signature": "A000000B", "spawn_index": 0}
	}
	var counterfeit := {
		12: {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7, "world_pos": Vector2.ZERO, "is_forged": true, "signature": "F000000C", "spawn_index": 1}
	}
	var authentic_outcome := manager.build_outcome_summary_for_test("extraction_objective", authentic, {"artifact_id": 11, "owner_peer_id": 2, "room_slot": 7})
	if not bool(authentic_outcome.get("expedition_success", false)) or bool(authentic_outcome.get("sabotage_success", true)):
		failures.append("authentic extraction should count as expedition success")
	if str(authentic_outcome.get("artifact_result", "")) != "authentic":
		failures.append("authentic extraction should be labeled authentic in the outcome summary")
	var counterfeit_outcome := manager.build_outcome_summary_for_test("extraction_objective", counterfeit, {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7})
	if not bool(counterfeit_outcome.get("sabotage_success", false)) or bool(counterfeit_outcome.get("expedition_success", true)):
		failures.append("counterfeit extraction should count as sabotage success")
	if str(counterfeit_outcome.get("artifact_result_text", "")).find("Counterfeit artifact extracted") == -1:
		failures.append("counterfeit extraction should surface the clarified artifact result text")
	if str(counterfeit_outcome.get("artifact_continuity_state", "")) != "successor_emergence":
		failures.append("counterfeit extraction should now surface successor emergence through the authoritative artifact continuity path")
	var stalled_outcome := manager.build_outcome_summary_for_test("tick_limit", authentic)
	if not bool(stalled_outcome.get("sabotage_success", false)):
		failures.append("tick-limit failure should count as sabotage success in the clarified outcome model")
	if str(stalled_outcome.get("artifact_continuity_state", "")) != "recoverable_loss":
		failures.append("tick-limit shutdown with an authentic carried artifact should remain a recoverable loss")
	manager.free()

func _test_artifact_irrecoverability_continuity(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var buried_authentic := {
		41: {"artifact_id": 41, "owner_peer_id": 0, "room_slot": 8, "world_pos": Vector2.ZERO, "is_forged": false, "signature": "A0000029", "spawn_index": 0}
	}
	var interrupted_burial := manager.build_interrupted_outcome_summary_for_test("disconnect", buried_authentic)
	if str(interrupted_burial.get("artifact_continuity_state", "")) != "burial":
		failures.append("interrupted unresolved authentic artifacts left in the world should surface as burial")
	var counterfeit_only := {
		51: {"artifact_id": 51, "owner_peer_id": 0, "room_slot": 9, "world_pos": Vector2.ZERO, "is_forged": true, "signature": "F0000033", "spawn_index": 0}
	}
	var residue := manager.build_outcome_summary_for_test("tick_limit", counterfeit_only)
	if str(residue.get("artifact_continuity_state", "")) != "archive_only_residue":
		failures.append("counterfeit-only unresolved outcomes should collapse into archive-only residue")
	manager.free()

func _test_artifact_continuity_product_carryover(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var run_record := {
		"seed": 1919,
		"end_reason": "session_interrupted",
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": false,
		"interrupted": true,
		"outcome_summary": {
			"summary_text": "Session interrupted",
			"artifact_result_text": "Run interrupted before extraction",
			"artifact_result": "interrupted",
			"artifact_continuity_state": "burial",
			"artifact_continuity_text": "The artifact line was left buried in the labyrinth.",
			"expedition_success": false,
			"sabotage_success": false
		},
		"stats": {"notes_count": 1, "pinned_count": 0, "inspections_count": 0, "extraction_started": false, "extraction_completed": false},
		"stats_lines": [],
		"action_summary": ["The burden line broke before recovery", "The branch kept the artifact sealed behind the retreat"],
		"key_clues": ["The artifact never came back out of the branch"],
		"report_path": "user://reports/artifact_burial_1919.txt",
		"item_defs": ["lantern_snuffer"],
		"room_families": ["evidence", "hazard"],
		"artifact_states": ["burial"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_dropped"],
		"communication_summary": {"total": 1, "danger": 1, "regroup": 0, "artifact": 1},
		"timeline_public_events": [
			{"event_id": 1, "tick": 18, "room_slot": 6, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 41}}
		],
		"gameplay_signal_snapshot": {
			"player_count": 3,
			"protocol_state": "Intimate Protocol",
			"group_model": {"group_signals": ["burden answer"], "model_pressure": ["custody pressure"], "feature_signals": ["burden answer"], "feature_scores": {"burden_answer": 2}}
		},
		"delve_directive_summary": {"protocol_state": "Intimate Protocol"}
	}
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var next_profile: Dictionary = Dictionary(result.get("profile", {}))
	if not Array(Dictionary(next_profile.get("discoveries", {})).get("artifact_states", [])).has("burial"):
		failures.append("artifact continuity states should now persist as discovered artifact states")
	var last_run: Dictionary = Dictionary(next_profile.get("last_run", {}))
	var diagnostics: Dictionary = Dictionary(last_run.get("diagnostics", {}))
	if str(diagnostics.get("artifact_continuity_state", "")) != "burial":
		failures.append("product diagnostics should retain the authoritative artifact continuity state")
	if not Array(diagnostics.get("artifact_lineage_hints", [])).has("artifact burial line"):
		failures.append("artifact burial should seed lineage hints through the existing diagnostics path")
	if not Array(diagnostics.get("artifact_memory_hints", [])).has("burial memory"):
		failures.append("artifact burial should seed memory hints through the existing diagnostics path")
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(next_profile, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("artifact continuity carryover should still produce archive entries")
	else:
		var detail := str(Dictionary(archive_entries[0]).get("detail", ""))
		if detail.find("Artifact echo: The artifact line was left buried in the labyrinth.") == -1:
			failures.append("archive artifact echoes should prioritize the authoritative artifact continuity text")

func _test_institutional_order_carryover_and_delve_intake(failures: Array[String]) -> void:
	var seeded_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		WORLD_MEMORY_SERVICE_SCRIPT.default_state(),
		{
			"run_record": {
				"outcome_summary": {
					"artifact_continuity_state": "burial"
				}
			},
			"diagnostics": {
				"hidden_curriculum": ["burden respect", "ritual acceptance"]
			},
			"frame": {
				"governance_line": "Keep the route legible. Surface: custody pressure",
				"belief_line": "custody and burial now travel together",
				"school_reads": ["Ritual", "Analytical"],
				"school_tension": "Ritual school leans one way while Analytical school keeps insisting on the burial line.",
				"counter_readings": ["the clean rescue story hides a custody breach", "burial rights now matter"]
			},
			"crawl_packet": {}
		}
	)
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(seeded_world_memory))
	if world_lines.find("Institution:") == -1 or world_lines.find("Taboo:") == -1 or world_lines.find("Legitimacy:") == -1:
		failures.append("world memory should now surface institutional, taboo, and legitimacy carryover once burial pressure and school conflict accumulate")
	var session_context := {
		"protocol_state": "Intimate Protocol",
		"gameplay_snapshot": {
			"player_count": 3,
			"build_identities": [],
			"group_model": {}
		}
	}
	var clean_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(
		{
			"run_history": [],
			"crawl_history": [],
			"active_crawl": {},
			"world_memory": WORLD_MEMORY_SERVICE_SCRIPT.default_state(),
			"archive_state": {}
		},
		session_context
	)
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(
		{
			"run_history": [],
			"crawl_history": [],
			"active_crawl": {},
			"world_memory": seeded_world_memory,
			"archive_state": {}
		},
		session_context
	)
	var cultural_model := Dictionary(seeded_world_model.get("cultural_model", {}))
	if int(cultural_model.get("burial_pressure", 0)) < 2 or int(cultural_model.get("legitimacy_pressure", 0)) < 2 or int(cultural_model.get("taboo_heat", 0)) < 1:
		failures.append("delve world-model cultural intake should now carry burial, legitimacy, and taboo pressure from world memory")
	var clean_candidates := DOCTRINE_ENGINE_SCRIPT.build_candidates(clean_world_model, session_context, {"session": []}, {})
	var seeded_candidates := DOCTRINE_ENGINE_SCRIPT.build_candidates(seeded_world_model, session_context, {"session": []}, {})
	var clean_custody := 0
	var seeded_custody := 0
	var clean_split := 0
	var seeded_split := 0
	for candidate_raw in clean_candidates:
		var candidate: Dictionary = Dictionary(candidate_raw)
		if str(candidate.get("id", "")) == "custody_ritual":
			clean_custody = int(candidate.get("base_weight", 0))
		elif str(candidate.get("id", "")) == "split_truth":
			clean_split = int(candidate.get("base_weight", 0))
	for candidate_raw in seeded_candidates:
		var candidate: Dictionary = Dictionary(candidate_raw)
		if str(candidate.get("id", "")) == "custody_ritual":
			seeded_custody = int(candidate.get("base_weight", 0))
		elif str(candidate.get("id", "")) == "split_truth":
			seeded_split = int(candidate.get("base_weight", 0))
	if seeded_custody <= clean_custody:
		failures.append("burial and legitimacy pressure should raise custody_ritual doctrine candidacy through the existing delve intake path")
	if seeded_split <= clean_split:
		failures.append("heresy pressure should raise split_truth doctrine candidacy through the existing delve intake path")
	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var session_goals := Array(Dictionary(planner).get("session", []))
	var run_goals := Array(Dictionary(planner).get("run", []))
	if "\n".join(session_goals).find("burial pressure") == -1 or "\n".join(session_goals).find("custody obligations") == -1:
		failures.append("horizon planning should respond to institutional burial and legitimacy pressure once it is present")
	if "\n".join(run_goals).find("taboo pressure") == -1:
		failures.append("horizon planning should respond to taboo heat once it is present")

func _test_false_canon_and_semantic_drift_carryover(failures: Array[String]) -> void:
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		WORLD_MEMORY_SERVICE_SCRIPT.default_state(),
		{
			"run_record": {
				"outcome_summary": {
					"artifact_continuity_state": "recoverable_loss"
				}
			},
			"diagnostics": {},
			"frame": {
				"commentary_lanes": ["Analytical", "Systemic"],
				"school_reads": ["Analytical read"],
				"belief_line": "Archive-first proof is still setting the custody terms.",
				"governance_line": "Keep the route legible. Surface: custody pressure"
			},
			"crawl_packet": {}
		}
	)
	world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		world_memory,
		{
			"run_record": {
				"outcome_summary": {
					"artifact_continuity_state": "successor_emergence",
					"artifact_unresolved_counterfeit_count": 1,
					"counterfeit_count": 1
				}
			},
			"diagnostics": {
				"artifact_prestige_indicators": ["false succession pressure"],
				"counterfactual_pressure": ["the accepted lineage no longer explains the surviving chain"]
			},
			"frame": {
				"commentary_lanes": ["Analytical", "Systemic", "Counterweight"],
				"school_reads": ["Analytical read", "Counterweight read"],
				"school_tension": "Analytical school keeps the official story while Counterweight school keeps reopening the counterfeit line.",
				"counter_readings": ["official provenance line", "counterfeit memorial tradition"],
				"belief_line": "Archive-first proof is still deciding what counts as authentic.",
				"counterfactual_line": "older custody terms no longer hold cleanly",
				"governance_line": "Keep the route legible. Surface: custody pressure"
			},
			"crawl_packet": {}
		}
	)
	world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		world_memory,
		{
			"run_record": {
				"outcome_summary": {
					"artifact_continuity_state": "successor_emergence",
					"artifact_unresolved_counterfeit_count": 1
				}
			},
			"diagnostics": {
				"artifact_prestige_indicators": ["false succession pressure"]
			},
			"frame": {
				"commentary_lanes": ["Systemic", "Counterweight"],
				"school_reads": ["Systemic read", "Counterweight read"],
				"school_tension": "Systemic school keeps trying to settle the custody language while Counterweight school keeps reopening the counterfeit residue.",
				"counter_readings": ["residue provenance line", "counterfeit memorial tradition"],
				"belief_line": "Lineage-first proof is now deciding what survives as the accepted line.",
				"governance_line": "Keep the route legible. Surface: custody pressure"
			},
			"crawl_packet": {}
		}
	)
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory))
	if world_lines.find("Canon:") == -1 or world_lines.find("Drift:") == -1 or world_lines.find("Forgery:") == -1:
		failures.append("world memory should surface canon, drift, and forgery carryover once counterfeit succession and interpretive conflict accumulate")

	var world_profile := {
		"world_memory": world_memory,
		"archive_state": {}
	}
	var world_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(world_profile, "world_fascination")
	var world_entry_text := ""
	for world_entry_raw in world_entries:
		var world_entry: Dictionary = Dictionary(world_entry_raw)
		world_entry_text += "%s\n%s\n" % [str(world_entry.get("label", "")), str(world_entry.get("detail", ""))]
	if world_entry_text.find("Canon |") == -1 or world_entry_text.find("Field | Drift") == -1 or world_entry_text.find("Field | Forgery") == -1:
		failures.append("archive world entries should preserve canon, drift, and forgery state through the existing read-only world-fascination path")

	var session_context := {
		"player_count": 4,
		"peer_ids": [2, 3, 4, 5],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "canon_a", "display_name": "Aster"},
			"3": {"public_id": "canon_b", "display_name": "Bram"},
			"4": {"public_id": "canon_c", "display_name": "Cleo"},
			"5": {"public_id": "canon_d", "display_name": "Dax"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Control build",
				"group_signals": ["route control"],
				"fault_lines": ["split answer"],
				"model_pressure": ["split answer"]
			}
		}
	}
	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Canon Delver", "public_id": "canon_delver"}
	}, PRODUCT_CATALOG_SCRIPT.load_catalog())
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["world_memory"] = world_memory
	var clean_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(clean_profile, session_context)
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var cultural_model := Dictionary(seeded_world_model.get("cultural_model", {}))
	if int(cultural_model.get("false_canon_pressure", 0)) < 2 or int(cultural_model.get("semantic_drift", 0)) < 1 or int(cultural_model.get("forgery_pressure", 0)) < 1:
		failures.append("delve world-model cultural intake should now carry false canon, semantic drift, and forgery pressure from world memory")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("false canon") == -1 or planner_text.find("semantic drift") == -1 or planner_text.find("dominant truth tradition") == -1:
		failures.append("horizon planning should respond to canon fracture, semantic drift, and orthodoxy capture pressure once it is present")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 5151, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 5151, 10)
	var clean_force := Dictionary(Dictionary(clean_directive.get("run_identity", {})).get("force_profile", {}))
	var seeded_force := Dictionary(Dictionary(seeded_directive.get("run_identity", {})).get("force_profile", {}))
	var clean_discovery := int(clean_force.get("discovery", 0))
	var seeded_discovery := int(seeded_force.get("discovery", 0))
	if int(seeded_force.get("deception", 0)) <= int(clean_force.get("deception", 0)):
		failures.append("false canon and forgery pressure should raise deception force through the live delve lattice")
	if seeded_discovery < clean_discovery or (seeded_discovery == clean_discovery and clean_discovery < 10):
		failures.append("revision and semantic drift pressure should raise discovery force through the live delve lattice")
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("canon-drift carryover should alter live control-surface shaping, not only product memory text")

func _test_affective_climate_and_ordinary_labor_carryover(failures: Array[String]) -> void:
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		WORLD_MEMORY_SERVICE_SCRIPT.default_state(),
		{
			"run_record": {
				"interrupted": true,
				"outcome_summary": {
					"artifact_continuity_state": "extinction"
				}
			},
			"diagnostics": {
				"recovery_score": 2,
				"spectacle_pressure": 3,
				"near_miss_score": 2
			},
			"frame": {
				"status_valence": "Scandal",
				"belief_line": "the old sacred rescue story no longer holds",
				"counterfactual_line": "the public keeps measuring this against the cleaner rescue that never happened"
			},
			"crawl_packet": {}
		}
	)
	world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		world_memory,
		{
			"run_record": {
				"outcome_summary": {
					"artifact_continuity_state": "burial"
				}
			},
			"diagnostics": {
				"recovery_score": 3,
				"spectacle_pressure": 1,
				"near_miss_score": 0
			},
			"frame": {
				"status_valence": "Redemption",
				"belief_line": "burial and recovery can still hold together"
			},
			"crawl_packet": {}
		}
	)
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory))
	if world_lines.find("Climate:") == -1 or world_lines.find("Mourning:") == -1 or world_lines.find("Civic:") == -1:
		failures.append("world memory should surface climate, mourning, and civic ordinary-life carryover once scandal, extinction, and routine rescue work accumulate")

	var world_profile := {
		"world_memory": world_memory,
		"archive_state": {}
	}
	var world_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(world_profile, "world_fascination")
	var world_entry_text := ""
	for world_entry_raw in world_entries:
		var world_entry: Dictionary = Dictionary(world_entry_raw)
		world_entry_text += "%s\n%s\n" % [str(world_entry.get("label", "")), str(world_entry.get("detail", ""))]
	if world_entry_text.find("Climate |") == -1 or world_entry_text.find("Field | Mourning") == -1 or world_entry_text.find("Field | Civic") == -1:
		failures.append("archive world entries should preserve climate, mourning, and civic ordinary-life state through the read-only world-fascination path")

	var session_context := {
		"player_count": 4,
		"peer_ids": [2, 3, 4, 5],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "climate_a", "display_name": "Aster"},
			"3": {"public_id": "climate_b", "display_name": "Bram"},
			"4": {"public_id": "climate_c", "display_name": "Cleo"},
			"5": {"public_id": "climate_d", "display_name": "Dax"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Rescue build",
				"group_signals": ["rescue geometry"],
				"fault_lines": ["public strain"],
				"model_pressure": ["rescue geometry"]
			}
		}
	}
	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Climate Delver", "public_id": "climate_delver"}
	}, PRODUCT_CATALOG_SCRIPT.load_catalog())
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["world_memory"] = world_memory
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var cultural_model := Dictionary(seeded_world_model.get("cultural_model", {}))
	if int(cultural_model.get("punitive_heat", 0)) < 1 or int(cultural_model.get("melancholy_heat", 0)) < 2 or int(cultural_model.get("ordinary_life_pressure", 0)) < 2:
		failures.append("delve world-model cultural intake should now carry affective climate, mourning, and ordinary-life pressure from world memory")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("mourning") == -1 or planner_text.find("ordinary sanctioned work") == -1 or planner_text.find("ordinary labor") == -1:
		failures.append("horizon planning should respond to mourning, punitive overreaction, and ordinary-life pressure once they are present")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 6262, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 6262, 10)
	var clean_force := Dictionary(Dictionary(clean_directive.get("run_identity", {})).get("force_profile", {}))
	var seeded_force := Dictionary(Dictionary(seeded_directive.get("run_identity", {})).get("force_profile", {}))
	if int(seeded_force.get("risk", 0)) <= int(clean_force.get("risk", 0)):
		failures.append("punitive and paranoid climate pressure should raise risk force through the live delve lattice")
	if int(seeded_force.get("containment", 0)) <= int(clean_force.get("containment", 0)):
		failures.append("ordinary-life pressure should raise containment force through the live delve lattice")
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("affective climate carryover should alter live control-surface shaping, not only world-memory text")

func _test_ontology_and_counterfactual_carryover(failures: Array[String]) -> void:
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		WORLD_MEMORY_SERVICE_SCRIPT.default_state(),
		{
			"run_record": {},
			"diagnostics": {
				"counterfactual_pressure": ["the cleaner rescue path still haunts this route"],
				"anomaly_sensitivity": {"score": 4, "signals": ["echo instability"]},
				"model_pressure": ["route doubt"],
				"inhabitant_pressure": ["echo pressure"]
			},
			"frame": {
				"commentary_lanes": ["Conspiracy", "Systemic", "Analytical"],
				"belief_line": "the world still refuses the clean answer",
				"counterfactual_line": "the unchosen rescue keeps shadowing the official account",
				"governance_line": "Keep the route legible. Surface: route doubt"
			},
			"crawl_packet": {}
		}
	)
	world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		world_memory,
		{
			"run_record": {},
			"diagnostics": {
				"counterfactual_pressure": ["the abandoned route still feels one decision away"],
				"anomaly_sensitivity": {"score": 4, "signals": ["echo instability"]},
				"model_pressure": ["route doubt"]
			},
			"frame": {
				"commentary_lanes": ["Conspiracy", "Analytical"],
				"belief_line": "the world still refuses the clean answer",
				"counterfactual_line": "unchosen futures are starting to leave residue"
			},
			"crawl_packet": {}
		}
	)
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory))
	if world_lines.find("Ontology:") == -1 or world_lines.find("Uncertainty:") == -1 or world_lines.find("Echo:") == -1:
		failures.append("world memory should surface ontology, uncertainty philosophy, and counterfactual echoes once anomaly-heavy counterfactual pressure accumulates")

	var world_profile := {
		"world_memory": world_memory,
		"archive_state": {}
	}
	var world_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(world_profile, "world_fascination")
	var world_entry_text := ""
	for world_entry_raw in world_entries:
		var world_entry: Dictionary = Dictionary(world_entry_raw)
		world_entry_text += "%s\n%s\n" % [str(world_entry.get("label", "")), str(world_entry.get("detail", ""))]
	if world_entry_text.find("Ontology |") == -1 or world_entry_text.find("Field | Uncertainty") == -1 or world_entry_text.find("Field | Counterfactual") == -1:
		failures.append("archive world entries should preserve ontology, uncertainty, and counterfactual echo state through the read-only world-fascination path")

	var session_context := {
		"player_count": 4,
		"peer_ids": [2, 3, 4, 5],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "ontology_a", "display_name": "Aster"},
			"3": {"public_id": "ontology_b", "display_name": "Bram"},
			"4": {"public_id": "ontology_c", "display_name": "Cleo"},
			"5": {"public_id": "ontology_d", "display_name": "Dax"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Control build",
				"group_signals": ["route control"],
				"fault_lines": ["split answer"],
				"model_pressure": ["route doubt"]
			},
			"inhabitant_pressure": ["echo pressure"]
		}
	}
	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Ontology Delver", "public_id": "ontology_delver"}
	}, PRODUCT_CATALOG_SCRIPT.load_catalog())
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["world_memory"] = world_memory
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var cultural_model := Dictionary(seeded_world_model.get("cultural_model", {}))
	if str(cultural_model.get("dominant_ontology", "")).strip_edges().is_empty() or str(cultural_model.get("uncertainty_philosophy", "")).strip_edges().is_empty() or int(cultural_model.get("counterfactual_heat", 0)) < 2:
		failures.append("delve world-model cultural intake should now carry ontology, uncertainty philosophy, and counterfactual heat from world memory")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("unchosen answers") == -1 or planner_text.find("anomaly ontology") == -1 or planner_text.find("uncertainty as part of knowing") == -1:
		failures.append("horizon planning should respond to counterfactual echoes, anomaly ontology, and uncertainty philosophy once they are present")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 7373, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 7373, 10)
	var clean_force := Dictionary(Dictionary(clean_directive.get("run_identity", {})).get("force_profile", {}))
	var seeded_force := Dictionary(Dictionary(seeded_directive.get("run_identity", {})).get("force_profile", {}))
	if int(seeded_force.get("discovery", 0)) <= int(clean_force.get("discovery", 0)):
		failures.append("counterfactual and ontology pressure should raise discovery force through the live delve lattice")
	if int(seeded_force.get("risk", 0)) <= int(clean_force.get("risk", 0)):
		failures.append("unknowable-anomaly ontology should raise risk force through the live delve lattice")
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("ontology and counterfactual carryover should alter live control-surface shaping, not only world-memory text")

func _test_delve_history_self_anthropology(failures: Array[String]) -> void:
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	for run_context in [
		{
			"run_record": {"interrupted": true},
			"diagnostics": {"doctrine_family": "witness_pressure", "counterfactual_pressure": ["the witness model missed what the crew actually did"]},
			"frame": {},
			"crawl_packet": {}
		},
		{
			"run_record": {"interrupted": true},
			"diagnostics": {"doctrine_family": "witness_pressure", "counterfactual_pressure": ["the same witness model is still over-reading the room"]},
			"frame": {},
			"crawl_packet": {}
		},
		{
			"run_record": {},
			"diagnostics": {"doctrine_family": "custody_ritual"},
			"frame": {},
			"crawl_packet": {}
		},
		{
			"run_record": {},
			"diagnostics": {"doctrine_family": "custody_ritual"},
			"frame": {},
			"crawl_packet": {}
		}
	]:
		world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(world_memory, run_context)
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory))
	if world_lines.find("DelveMind:") == -1 or world_lines.find("Method history:") == -1:
		failures.append("world memory should surface DelveMind methodological history once repeated misreads and paradigm shifts accumulate")

	var world_profile := {
		"world_memory": world_memory,
		"archive_state": {}
	}
	var world_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(world_profile, "world_fascination")
	var world_entry_text := ""
	for world_entry_raw in world_entries:
		var world_entry: Dictionary = Dictionary(world_entry_raw)
		world_entry_text += "%s\n%s\n" % [str(world_entry.get("label", "")), str(world_entry.get("detail", ""))]
	if world_entry_text.find("DelveMind |") == -1 or world_entry_text.find("Field | Method history") == -1:
		failures.append("archive world entries should preserve DelveMind methodological history through the read-only world-fascination path")

	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Intimate Protocol",
		"public_cards": {
			"2": {"public_id": "meta_a", "display_name": "Aster"},
			"3": {"public_id": "meta_b", "display_name": "Bram"},
			"4": {"public_id": "meta_c", "display_name": "Cleo"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Intimate Protocol",
			"group_model": {
				"dominant_build": "Ritual build",
				"group_signals": ["ritual answer"],
				"fault_lines": ["overfit pressure"],
				"model_pressure": ["ritual answer"]
			}
		}
	}
	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Meta Delver", "public_id": "meta_delver"}
	}, PRODUCT_CATALOG_SCRIPT.load_catalog())
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["world_memory"] = world_memory
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var doctrine_model := Dictionary(seeded_world_model.get("doctrine_model", {}))
	if str(doctrine_model.get("dominant_method", "")).strip_edges().is_empty() or int(doctrine_model.get("misclassification_pressure", 0)) < 1 or int(doctrine_model.get("overcorrection_pressure", 0)) < 1:
		failures.append("delve world-model doctrine intake should now carry DelveMind methodological history, misclassification, and overcorrection pressure")
	if not Array(doctrine_model.get("abandoned_paradigms", [])).has("witness_pressure"):
		failures.append("DelveMind history should preserve abandoned paradigms once the dominant method shifts away from them")

	var meta := META_RESISTANCE_SCRIPT.evaluate(seeded_world_model, session_context)
	if not Array(meta.get("stale_doctrines", [])).has("witness_pressure"):
		failures.append("meta resistance should surface abandoned or misreading doctrines as stale through the existing owner path")
	if "\n".join(Array(meta.get("anti_stagnation_lines", []))).find("history is showing") == -1:
		failures.append("meta resistance should acknowledge visible DelveMind overcorrection once it accumulates")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("over-reading the same human pattern") == -1 or planner_text.find("remember its own errors") == -1:
		failures.append("horizon planning should respond to DelveMind misclassification and overcorrection history once it is present")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 8484, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 8484, 10)
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("DelveMind self-history should alter live control-surface shaping through the existing meta-resistance path")

func _test_interpretation_network_order_and_silence_carryover(failures: Array[String]) -> void:
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		WORLD_MEMORY_SERVICE_SCRIPT.default_state(),
		{
			"run_record": {},
			"diagnostics": {
				"ritual_recurrence": ["the lower gallery is being retold as a return rite"],
				"load_bearing_places": ["Lower Gallery"],
				"load_bearing_objects": ["Ash Reliquary"],
				"anomaly_sensitivity": {"score": 4, "signals": ["the lower gallery is now being treated as an unclassified hush"]},
				"inhabitant_pressure": ["echo pressure"],
				"recovery_score": 2,
				"resource_pressure": ["rope reserves"],
				"artifact_cultural_association": "custody relic",
				"hidden_curriculum": ["quiet answer", "leave some traces unnamed"]
			},
			"frame": {
				"commentary_lanes": ["Ritual", "Analytical"],
				"school_reads": ["Ritual read", "Analytical read"],
				"school_tension": "Ritual school keeps naming the place while Analytical school keeps classifying it.",
				"counter_readings": ["the site should stay unnamed", "the site needs a proper record"],
				"belief_line": "the lower gallery is becoming a charged place in public memory",
				"ritual_pressure": "the return ritual is spreading faster than explanation",
				"governance_line": "Keep the route legible. Surface: custody pressure",
				"open_questions": ["What should remain unnamed here?"]
			},
			"crawl_packet": {}
		}
	)
	world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(
		world_memory,
		{
			"run_record": {},
			"diagnostics": {
				"ritual_recurrence": ["the reliquary keeps pulling later crews into the same retelling"],
				"load_bearing_places": ["Lower Gallery"],
				"load_bearing_objects": ["Ash Reliquary"],
				"anomaly_sensitivity": {"score": 4, "signals": ["the reliquary is now being left deliberately unclassified"]},
				"recovery_score": 3,
				"resource_pressure": ["bomb reserves"],
				"artifact_cultural_association": "forbidden memorial object",
				"hidden_curriculum": ["do not flatten the site into a clean answer", "leave some pressure unresolved"]
			},
			"frame": {
				"commentary_lanes": ["Counterweight", "Ritual", "Analytical"],
				"school_reads": ["Counterweight read", "Ritual read"],
				"school_tension": "Counterweight and Ritual schools keep contesting the official classification.",
				"counter_readings": ["the site should stay unnamed", "the reliquary should remain unresolved"],
				"belief_line": "institutions are still trying to settle a story the place keeps refusing",
				"counterfactual_line": "the cleaner report omits what the gallery keeps refusing to answer",
				"ritual_pressure": "the old naming ritual is outpacing official explanation",
				"governance_line": "Keep the route legible. Surface: custody pressure",
				"open_questions": ["Why is the reliquary still treated as unclassified?"]
			},
			"crawl_packet": {}
		}
	)
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory))
	if world_lines.find("Interpretation:") == -1 or world_lines.find("Order:") == -1 or world_lines.find("Silence:") == -1:
		failures.append("world memory should surface interpretation-network, sacred-order, and silence-doctrine carryover once rival schools and unresolved ritual pressure accumulate")

	var world_profile := {
		"world_memory": world_memory,
		"archive_state": {}
	}
	var world_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(world_profile, "world_fascination")
	var world_entry_text := ""
	for world_entry_raw in world_entries:
		var world_entry: Dictionary = Dictionary(world_entry_raw)
		world_entry_text += "%s\n%s\n" % [str(world_entry.get("label", "")), str(world_entry.get("detail", ""))]
	if world_entry_text.find("Network |") == -1 or world_entry_text.find("Order |") == -1 or world_entry_text.find("Silence |") == -1 or world_entry_text.find("Field | Unclassified") == -1:
		failures.append("archive world entries should preserve interpretation-network spread, order tension, and unclassified silence state through the existing read-only world-fascination path")

	var session_context := {
		"player_count": 4,
		"peer_ids": [2, 3, 4, 5],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "interp_a", "display_name": "Aster"},
			"3": {"public_id": "interp_b", "display_name": "Bram"},
			"4": {"public_id": "interp_c", "display_name": "Cleo"},
			"5": {"public_id": "interp_d", "display_name": "Dax"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Control build",
				"group_signals": ["route control"],
				"fault_lines": ["split answer"],
				"model_pressure": ["route doubt"]
			}
		}
	}
	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Interpretation Delver", "public_id": "interpretation_delver"}
	}, PRODUCT_CATALOG_SCRIPT.load_catalog())
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["world_memory"] = world_memory
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var cultural_model := Dictionary(seeded_world_model.get("cultural_model", {}))
	if int(cultural_model.get("contradiction_heat", 0)) < 2 or int(cultural_model.get("ritual_spread", 0)) < 1 or int(cultural_model.get("sacred_pressure", 0)) < 1 or int(cultural_model.get("administrative_pressure", 0)) < 1 or int(cultural_model.get("silence_pressure", 0)) < 1 or int(cultural_model.get("unclassified_pressure", 0)) < 1:
		failures.append("delve world-model cultural intake should now carry interpretation-network conflict, order tension, and silence pressure from world memory")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("rival explanations") == -1 or planner_text.find("sacred and administrative order") == -1 or planner_text.find("preserve silence") == -1 or planner_text.find("unresolved") == -1:
		failures.append("horizon planning should respond to interpretation spread, sacred-order tension, and silence doctrine once they are present")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 9595, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 9595, 10)
	var clean_force := Dictionary(Dictionary(clean_directive.get("run_identity", {})).get("force_profile", {}))
	var seeded_force := Dictionary(Dictionary(seeded_directive.get("run_identity", {})).get("force_profile", {}))
	if int(seeded_force.get("deception", 0)) <= int(clean_force.get("deception", 0)):
		failures.append("interpretation contradiction should raise deception force through the live delve lattice")
	if int(seeded_force.get("memory", 0)) <= int(clean_force.get("memory", 0)):
		failures.append("sacred-order and ritual-spread pressure should raise memory force through the live delve lattice")
	if int(seeded_force.get("containment", 0)) <= int(clean_force.get("containment", 0)):
		failures.append("administrative-order and silence pressure should raise containment force through the live delve lattice")
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("interpretation-network and silence carryover should alter live control-surface shaping, not only world-memory text")

func _test_cookbook_shadow_and_anti_protocol_carryover(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Margin Delver", "public_id": "margin_delver"},
		"narrative_progress": {
			"layer": "post_core",
			"core_reached": true,
			"post_core_flags": ["deep_archive", "counterweight"]
		}
	}, catalog)
	var base_run := {
		"seed": 8080,
		"local_peer_id": 2,
		"local_role": "Scavenger",
		"role_result_success": false,
		"interrupted": false,
		"outcome_summary": {
			"summary_text": "The route kept refusing the clean answer.",
			"artifact_result_text": "Artifact custody remained unresolved.",
			"expedition_success": false,
			"sabotage_success": false
		},
		"stats": {
			"notes_count": 2,
			"pinned_count": 1,
			"inspections_count": 1,
			"extraction_started": true,
			"extraction_completed": true
		},
		"report_path": "user://reports/cookbook_a.json",
		"peer_identities": {
			"2": {"public_id": "margin_delver", "display_name": "Aster"}
		},
		"timeline_public_events": [
			{"event_type": "artifact_picked", "room_slot": 2, "actor_peer_id": 2, "tick": 10, "meta": {"artifact_id": 1}},
			{"event_type": "bomb_exploded", "room_slot": 3, "actor_peer_id": 2, "tick": 20, "meta": {}},
			{"event_type": "run_ended", "room_slot": -1, "actor_peer_id": -1, "tick": 200, "meta": {}}
		],
		"key_clues": [
			"the route kept folding back toward the same marked threshold",
			"artifact handling stayed visibly contested"
		],
		"action_summary": [
			"Aster logged private notes about the impossible marks",
			"Aster pinned a contradiction before extraction"
		],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 1, "artifact": 1},
		"gameplay_signal_snapshot": {
			"protocol_state": "Fracture Protocol",
			"peer_models": {
				"margin_delver": {
					"peer_id": 2,
					"build_identity": "Anomaly build",
					"build_scores": {"Anomaly build": 5, "Control build": 2},
					"feature_scores": {"anomaly_curiosity": 4, "resource_caution": 1},
					"feature_signals": ["anomaly curiosity", "forbidden marginalia"],
					"model_pressure": ["answer inversion", "route doubt"],
					"behavior_signals": ["route control", "burden commitment"],
					"synergy_labels": ["ritual inversion"],
					"ritual_hooks": ["ritual inversion"],
					"anomaly_hooks": ["impossible annotation", "attention under pursuit"],
					"protocol_hooks": ["indirect recognition"],
					"resource_signals": ["artifact line"],
					"inhabitant_signals": ["echo pressure"]
				}
			},
			"group_model": {
				"dominant_build": "Anomaly build",
				"group_signals": ["split reading"],
				"fault_lines": ["clean answer strain"],
				"model_pressure": ["answer inversion"]
			},
			"inhabitant_pressure": ["echo pressure"],
			"resource_pressure": ["artifact line"]
		}
	}
	profile = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(profile, base_run, catalog).get("profile", {}))
	var second_run: Dictionary = base_run.duplicate(true)
	second_run["seed"] = 8081
	second_run["report_path"] = "user://reports/cookbook_b.json"
	second_run["stats"] = {
		"notes_count": 3,
		"pinned_count": 1,
		"inspections_count": 1,
		"extraction_started": true,
		"extraction_completed": true
	}
	second_run["action_summary"] = [
		"Aster revised the route notes instead of cleaning them up",
		"Aster kept the impossible annotation pinned"
	]
	second_run["communication_summary"] = {"total": 3, "danger": 1, "regroup": 1, "artifact": 1}
	profile = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(profile, second_run, catalog).get("profile", {}))
	var cookbook_state: Dictionary = Dictionary(profile.get("cookbook_state", {}))
	if int(cookbook_state.get("fragment_count", 0)) < 2:
		failures.append("cookbook continuity should accumulate hidden fragments once anomaly-linked marginalia repeats")
	if int(cookbook_state.get("holder_depth", 0)) < 1 or int(cookbook_state.get("network_pressure", 0)) < 1:
		failures.append("cookbook continuity should recognize holder and network pressure through the existing private profile owner path")
	if int(cookbook_state.get("redirection_pressure", 0)) < 1:
		failures.append("cookbook continuity should accumulate anti-Protocol redirection pressure once repeated anomaly readings persist")
	if str(cookbook_state.get("holder_state", "")) not in ["margin_reader", "holder"]:
		failures.append("cookbook continuity should remain hidden but still classify the local profile as beyond a first glimpse once fragments accumulate")
	if Array(cookbook_state.get("fragment_lines", [])).is_empty() or Array(cookbook_state.get("network_lines", [])).is_empty():
		failures.append("cookbook continuity should preserve private fragment and recognition lines without requiring a public codex track")

	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(Dictionary(profile.get("world_memory", {}))))
	if world_lines.find("Margins:") == -1 or world_lines.find("Rumor:") == -1 or world_lines.find("Redirection:") == -1:
		failures.append("world memory should carry cookbook residue as marginalia, rumor, and redirection without creating a second public progression surface")

	var world_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(profile, "world_fascination")
	var world_entry_text := ""
	for world_entry_raw in world_entries:
		var world_entry: Dictionary = Dictionary(world_entry_raw)
		world_entry_text += "%s\n%s\n" % [str(world_entry.get("label", "")), str(world_entry.get("detail", ""))]
	if world_entry_text.find("Margins |") == -1 or world_entry_text.find("Rumor |") == -1 or world_entry_text.find("Field | Redirection") == -1:
		failures.append("archive world-fascination entries should preserve cookbook residue as public rumor rather than an explicit public upgrade track")

	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Margin Delver", "public_id": "margin_delver"},
		"narrative_progress": {
			"layer": "post_core",
			"core_reached": true,
			"post_core_flags": ["deep_archive", "counterweight"]
		}
	}, catalog)
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["cookbook_state"] = Dictionary(profile.get("cookbook_state", {})).duplicate(true)
	seeded_profile["world_memory"] = WORLD_MEMORY_SERVICE_SCRIPT.normalize({
		"cookbook_shadow": Dictionary(Dictionary(profile.get("world_memory", {})).get("cookbook_shadow", {})).duplicate(true)
	})
	var session_context := {
		"player_count": 4,
		"peer_ids": [2, 3, 4, 5],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "margin_delver", "display_name": "Aster"},
			"3": {"public_id": "peer_b", "display_name": "Bram"},
			"4": {"public_id": "peer_c", "display_name": "Cleo"},
			"5": {"public_id": "peer_d", "display_name": "Dax"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Control build",
				"group_signals": ["route control"],
				"fault_lines": ["split answer"],
				"model_pressure": ["route doubt"]
			}
		}
	}
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var cultural_model := Dictionary(seeded_world_model.get("cultural_model", {}))
	if int(cultural_model.get("cookbook_fragment_count", 0)) < 2 or int(cultural_model.get("cookbook_fragment_heat", 0)) < 1 or int(cultural_model.get("cookbook_network_rumor", 0)) < 1 or int(cultural_model.get("cookbook_redirection_heat", 0)) < 1:
		failures.append("Delve world-model cultural intake should carry private cookbook continuity and public rumor residue together through the existing owner path")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("forbidden marginalia") == -1 or planner_text.find("hidden readers") == -1 or planner_text.find("redirect protocol expectation") == -1:
		failures.append("horizon planning should react to cookbook fragments, holder recognition, and anti-Protocol redirection once they accumulate")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 8181, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 8181, 10)
	var clean_force := Dictionary(Dictionary(clean_directive.get("run_identity", {})).get("force_profile", {}))
	var seeded_force := Dictionary(Dictionary(seeded_directive.get("run_identity", {})).get("force_profile", {}))
	var clean_discovery := int(clean_force.get("discovery", 0))
	var seeded_discovery := int(seeded_force.get("discovery", 0))
	if seeded_discovery < clean_discovery or (seeded_discovery == clean_discovery and clean_discovery < 10):
		failures.append("cookbook fragment and redirection pressure should raise discovery force through the live delve lattice")
	if int(seeded_force.get("deception", 0)) <= int(clean_force.get("deception", 0)):
		failures.append("cookbook holder and recognition pressure should raise deception force through the live delve lattice")
	if int(seeded_force.get("memory", 0)) <= int(clean_force.get("memory", 0)):
		failures.append("cookbook fragment residue should raise memory force through the live delve lattice")
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("cookbook continuity should alter live control-surface shaping through the existing bounded Delve path")

func _test_relay_and_mass_expedition_carryover(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Relay Delver", "public_id": "relay_delver"}
	}, catalog)
	var base_run := {
		"seed": 9090,
		"local_peer_id": 2,
		"local_role": "Scavenger",
		"role_result_success": false,
		"interrupted": false,
		"outcome_summary": {
			"summary_text": "The expedition kept widening the same witness chain.",
			"artifact_result_text": "Custody stayed public and unstable.",
			"expedition_success": false,
			"sabotage_success": false
		},
		"stats": {
			"notes_count": 2,
			"pinned_count": 1,
			"inspections_count": 1,
			"extraction_started": true,
			"extraction_completed": true
		},
		"report_path": "user://reports/relay_a.json",
		"peer_identities": {
			"2": {"public_id": "relay_delver", "display_name": "Aster"},
			"3": {"public_id": "peer_b", "display_name": "Bram"},
			"4": {"public_id": "peer_c", "display_name": "Cleo"},
			"5": {"public_id": "peer_d", "display_name": "Dax"}
		},
		"timeline_public_events": [
			{"event_type": "room_callout", "room_slot": 1, "actor_peer_id": 2, "tick": 10, "meta": {}},
			{"event_type": "artifact_picked", "room_slot": 2, "actor_peer_id": 2, "tick": 20, "meta": {"artifact_id": 1}},
			{"event_type": "bomb_exploded", "room_slot": 3, "actor_peer_id": 3, "tick": 40, "meta": {}},
			{"event_type": "artifact_dropped", "room_slot": 3, "actor_peer_id": 2, "tick": 55, "meta": {"artifact_id": 1}},
			{"event_type": "sabotage_camera_jam", "room_slot": 4, "actor_peer_id": 4, "tick": 70, "meta": {}},
			{"event_type": "room_callout", "room_slot": 4, "actor_peer_id": 5, "tick": 85, "meta": {}},
			{"event_type": "artifact_picked", "room_slot": 5, "actor_peer_id": 5, "tick": 100, "meta": {"artifact_id": 1}},
			{"event_type": "run_ended", "room_slot": -1, "actor_peer_id": -1, "tick": 220, "meta": {}}
		],
		"key_clues": [
			"the relay line kept forcing witnesses through the same overloaded threshold",
			"different crews carried different parts of the same artifact story"
		],
		"action_summary": [
			"Aster kept pushing the same relay line through repeated callouts",
			"Cleo and Dax split witness duties across the same crowded route"
		],
		"communication_summary": {"total": 6, "danger": 3, "regroup": 2, "artifact": 1},
		"narrative_motion_facts": {
			"room_summaries": {
				"room_2": {"threshold_waits": 2},
				"room_4": {"returns": 2}
			},
			"strong_rooms": {
				"threshold_hesitation": 2,
				"returns": 2,
				"collective_hesitations": 2
			},
			"pair_summaries": {
				"2|3": {"following": 2, "proximity": 3},
				"4|5": {"following": 2, "proximity": 3}
			}
		},
		"gameplay_signal_snapshot": {
			"protocol_state": "Expedition Protocol",
			"peer_models": {
				"relay_delver": {
					"peer_id": 2,
					"build_identity": "Coordination build",
					"build_scores": {"Coordination build": 5, "Control build": 2},
					"feature_scores": {"coordination_discipline": 4, "resource_caution": 2},
					"feature_signals": ["distributed witness", "relay discipline"],
					"model_pressure": ["relay load", "public memory shock"],
					"behavior_signals": ["route control", "burden commitment"],
					"synergy_labels": ["relay chain"],
					"ritual_hooks": ["witness cadence"],
					"anomaly_hooks": ["counter-reading residue"],
					"protocol_hooks": ["distributed witness"],
					"resource_signals": ["route scarcity"],
					"inhabitant_signals": ["echo pressure"]
				}
			},
			"group_model": {
				"dominant_build": "Coordination build",
				"group_signals": ["relay chain", "distributed witness"],
				"fault_lines": ["crowd certainty fracture"],
				"model_pressure": ["relay load", "public memory shock"]
			},
			"inhabitant_pressure": ["echo pressure"],
			"resource_pressure": ["route scarcity"]
		}
	}
	profile = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(profile, base_run, catalog).get("profile", {}))
	var second_run: Dictionary = base_run.duplicate(true)
	second_run["seed"] = 9091
	second_run["report_path"] = "user://reports/relay_b.json"
	second_run["interrupted"] = true
	second_run["stats"] = {
		"notes_count": 3,
		"pinned_count": 1,
		"inspections_count": 1,
		"extraction_started": true,
		"extraction_completed": false
	}
	second_run["action_summary"] = [
		"Aster kept the relay warnings public even after the route jammed",
		"Bram and Cleo carried different witness fragments back to the crew"
	]
	second_run["communication_summary"] = {"total": 5, "danger": 3, "regroup": 1, "artifact": 1}
	profile = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(profile, second_run, catalog).get("profile", {}))

	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	if int(active_crawl.get("relay_stress", 0)) < 1:
		failures.append("expedition continuity should accumulate relay stress through the existing crawl owner path")
	if Array(active_crawl.get("relay_memory", [])).is_empty() or Array(active_crawl.get("witness_network", [])).is_empty():
		failures.append("expedition continuity should preserve relay and witness memory without widening runtime networking")
	if Array(active_crawl.get("relay_bottlenecks", [])).is_empty() or Array(active_crawl.get("rumor_shock", [])).is_empty() or Array(active_crawl.get("cohort_pressure", [])).is_empty():
		failures.append("expedition continuity should preserve bottleneck, rumor shock, and cohort pressure once the crawl widens")

	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(Dictionary(profile.get("world_memory", {}))))
	if world_lines.find("Relay:") == -1 or world_lines.find("Witness:") == -1 or world_lines.find("Bottleneck:") == -1:
		failures.append("world memory should surface relay, witness, and bottleneck residue through the existing read-only continuity layer")

	var world_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(profile, "world_fascination")
	var world_entry_text := ""
	for world_entry_raw in world_entries:
		var world_entry: Dictionary = Dictionary(world_entry_raw)
		world_entry_text += "%s\n%s\n" % [str(world_entry.get("label", "")), str(world_entry.get("detail", ""))]
	if world_entry_text.find("Network | Relay") == -1 or world_entry_text.find("Field | Witness") == -1 or world_entry_text.find("Field | Bottleneck") == -1:
		failures.append("archive world-fascination entries should preserve relay, witness, and bottleneck pressure without creating a second crawl authority")

	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Relay Delver", "public_id": "relay_delver"}
	}, catalog)
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["active_crawl"] = Dictionary(profile.get("active_crawl", {})).duplicate(true)
	seeded_profile["world_memory"] = WORLD_MEMORY_SERVICE_SCRIPT.normalize({
		"crawl_network_state": Dictionary(Dictionary(profile.get("world_memory", {})).get("crawl_network_state", {})).duplicate(true)
	})
	var session_context := {
		"player_count": 10,
		"peer_ids": [2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
		"protocol_state": "Expedition Protocol",
		"public_cards": {
			"2": {"public_id": "relay_delver", "display_name": "Aster"},
			"3": {"public_id": "peer_b", "display_name": "Bram"},
			"4": {"public_id": "peer_c", "display_name": "Cleo"},
			"5": {"public_id": "peer_d", "display_name": "Dax"},
			"6": {"public_id": "peer_e", "display_name": "Eli"},
			"7": {"public_id": "peer_f", "display_name": "Faye"},
			"8": {"public_id": "peer_g", "display_name": "Gio"},
			"9": {"public_id": "peer_h", "display_name": "Hera"},
			"10": {"public_id": "peer_i", "display_name": "Ivo"},
			"11": {"public_id": "peer_j", "display_name": "Juno"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Expedition Protocol",
			"group_model": {
				"dominant_build": "Coordination build",
				"group_signals": ["relay chain", "distributed witness"],
				"fault_lines": ["crowd certainty fracture"],
				"model_pressure": ["relay load", "public memory shock"]
			}
		}
	}
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var route_model := Dictionary(seeded_world_model.get("route_model", {}))
	var cultural_model := Dictionary(seeded_world_model.get("cultural_model", {}))
	if int(route_model.get("relay_stress", 0)) < 1 or Array(route_model.get("relay_memory", [])).is_empty():
		failures.append("Delve world-model route intake should carry relay stress and relay memory through active crawl continuity")
	if int(cultural_model.get("relay_memory_pressure", 0)) < 1 or int(cultural_model.get("witness_network_pressure", 0)) < 1 or int(cultural_model.get("relay_bottleneck_pressure", 0)) < 1:
		failures.append("Delve world-model cultural intake should carry relay, witness, and bottleneck pressure from world memory")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("relay stress") == -1 or planner_text.find("distributed witness networks") == -1 or planner_text.find("relay bottleneck") == -1 or planner_text.find("sub-cohort duty") == -1:
		failures.append("horizon planning should react to relay stress, distributed witnesses, bottlenecks, and cohort pressure once expedition continuity accumulates")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 9191, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 9191, 10)
	var clean_force := Dictionary(Dictionary(clean_directive.get("run_identity", {})).get("force_profile", {}))
	var seeded_force := Dictionary(Dictionary(seeded_directive.get("run_identity", {})).get("force_profile", {}))
	if int(seeded_force.get("containment", 0)) <= int(clean_force.get("containment", 0)):
		failures.append("relay stress and bottleneck pressure should raise containment force through the live delve lattice")
	if int(seeded_force.get("discovery", 0)) <= int(clean_force.get("discovery", 0)):
		failures.append("relay memory and rumor shock should raise discovery force through the live delve lattice")
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("relay and mass-expedition continuity should alter live control-surface shaping through the bounded Delve path")

func _test_epoch_state_world_model_and_horizon_carryover(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	world_memory["crawl_network_state"] = {
		"relay_stress": 3,
		"witness_pressure": 1,
		"bottleneck_pressure": 2,
		"rumor_shock": 2,
		"cohort_pressure": 1,
		"lines": ["relay bottlenecks are starting to define the era"],
		"witness_lines": ["distributed witnesses are outrunning local certainty"],
		"bottleneck_lines": ["one relay threshold is taking too much of the crawl"]
	}
	var epoch_state := WORLD_MEMORY_SERVICE_SCRIPT.epoch_state_for_test(world_memory)
	if str(epoch_state.get("phase", "")) != "relay fracture" or int(epoch_state.get("transition_pressure", 0)) < 2:
		failures.append("world memory should derive a relay-fracture epoch state once crawl-network stress dominates")
	world_memory["epoch_state"] = epoch_state.duplicate(true)
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory))
	if world_lines.find("Epoch:") == -1 or world_lines.to_lower().find("relay") == -1:
		failures.append("world lines should surface epoch pressure through the existing world-memory shell path")
	profile["world_memory"] = world_memory
	var session_context := {
		"player_count": 7,
		"peer_ids": [2, 3, 4, 5, 6, 7, 8],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "epoch_delver", "display_name": "Aster"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"group_signals": ["relay chain"],
				"fault_lines": ["crowd certainty fracture"],
				"model_pressure": ["relay load"]
			}
		}
	}
	var world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(profile, session_context)
	var epoch_model := Dictionary(world_model.get("epoch_model", {}))
	if str(epoch_model.get("phase", "")) != "relay fracture" or int(epoch_model.get("transition_pressure", 0)) < 2:
		failures.append("Delve world-model intake should carry epoch state explicitly once world memory derives it")
	var planner := HORIZON_PLANNER_SCRIPT.plan(world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("unfolding epoch shift") == -1 or planner_text.find("relay strain like lived route pressure") == -1:
		failures.append("horizon planning should react to epoch state through the existing Delve intake path")

func _test_trust_topology_routes_back_into_delve(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var clean_profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Trust Delver", "public_id": "trust_delver"}
	}, catalog)
	var seeded_profile := clean_profile.duplicate(true)
	seeded_profile["relationship_fabric"] = {
		"players": {
			"ally_a": {
				"title": "Remembered rescuer",
				"public_reputation": "the one people still trust with the burden"
			},
			"ally_b": {
				"title": "Reliable witness",
				"public_reputation": "the one who comes back for the carry"
			}
		},
		"pairs": {
			"ally_a:ally_b": {
				"title": "Burden pair",
				"obligations": [
					"they still trust each other to carry the burden line",
					"their rescues keep setting the expectation for the room"
				],
				"rescues": 3,
				"shared_burdens": 2,
				"mutual_extractions": 2,
				"betrayals": 1,
				"refusals": 1,
				"near_misses": 2,
				"public_reputation": "a remembered rescue pair"
			}
		},
		"crews": {
			"crew:allied_line": {
				"title": "Hold-together crew",
				"obligations": [
					"the crew is expected to keep the route together under pressure"
				],
				"successful_pushes": 2,
				"recoveries": 3,
				"collapse_moments": 1,
				"escalations": 2,
				"history_count": 3,
				"public_reputation": "they are remembered for holds more than spectacle"
			}
		},
		"recent_pairs": ["ally_a:ally_b"],
		"recent_crews": ["crew:allied_line"]
	}
	seeded_profile["persona_state"] = {
		"archetype_scores": {"rescuer": 4, "stabilizer": 3},
		"risk_posture": {"tendency": "hold together", "temperature": "calm_trust", "momentum": "steadying"},
		"public_expectations": [
			"the next descent still expects someone to hold the line together",
			"rescue obligation is now part of the crew's public memory"
		]
	}
	var session_context := {
		"player_count": 5,
		"peer_ids": [2, 3, 4, 5, 6],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "trust_delver", "display_name": "Aster"},
			"3": {"public_id": "ally_a", "display_name": "Bram"},
			"4": {"public_id": "ally_b", "display_name": "Cleo"},
			"5": {"public_id": "peer_d", "display_name": "Dax"},
			"6": {"public_id": "peer_e", "display_name": "Eli"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Coordination build",
				"group_signals": ["shared burden", "return rescue"],
				"fault_lines": ["trust line under strain"],
				"model_pressure": ["burden line", "rescue expectation"]
			}
		}
	}
	var seeded_world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(seeded_profile, session_context)
	var social_model := Dictionary(seeded_world_model.get("social_model", {}))
	if int(social_model.get("alliance_stability", 0)) < 3 or int(social_model.get("trust_fragility", 0)) < 2:
		failures.append("Delve social intake should carry alliance stability and trust fragility from relationship fabric")
	if int(social_model.get("friendship_pressure", 0)) < 2 or int(social_model.get("loyalty_pressure", 0)) < 2:
		failures.append("Delve social intake should carry friendship and loyalty pressure from profile continuity")

	var planner := HORIZON_PLANNER_SCRIPT.plan(seeded_world_model, session_context)
	var planner_text := "%s\n%s\n%s" % [
		"\n".join(Array(Dictionary(planner).get("run", []))),
		"\n".join(Array(Dictionary(planner).get("session", []))),
		"\n".join(Array(Dictionary(planner).get("campaign", [])))
	]
	if planner_text.find("loyalty and alliance") == -1 or planner_text.find("trust topology") == -1 or planner_text.find("friendship survive") == -1:
		failures.append("horizon planning should react once trust topology and friendship continuity are routed back into Delve")

	var clean_directive := DELVE_KERNEL_SCRIPT.plan_directive(clean_profile, session_context, 6262, 10)
	var seeded_directive := DELVE_KERNEL_SCRIPT.plan_directive(seeded_profile, session_context, 6262, 10)
	var clean_force := Dictionary(Dictionary(clean_directive.get("run_identity", {})).get("force_profile", {}))
	var seeded_force := Dictionary(Dictionary(seeded_directive.get("run_identity", {})).get("force_profile", {}))
	if int(seeded_force.get("containment", 0)) <= int(clean_force.get("containment", 0)):
		failures.append("alliance stability should raise containment force through the live delve lattice")
	if int(seeded_force.get("deception", 0)) <= int(clean_force.get("deception", 0)):
		failures.append("trust fragility should raise deception force through the live delve lattice")
	if int(seeded_force.get("memory", 0)) <= int(clean_force.get("memory", 0)):
		failures.append("friendship continuity should raise memory force through the live delve lattice")
	if JSON.stringify(Dictionary(clean_directive.get("control_surfaces", {}))) == JSON.stringify(Dictionary(seeded_directive.get("control_surfaces", {}))):
		failures.append("trust topology continuity should alter live control-surface shaping rather than staying shell-only")

func _test_ghost_pressure_determinism(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var inactive := manager.advance_ghost_pressure_for_test(100, {1: 1, 2: 5}, {1: Vector2(100, 100), 2: Vector2(500, 100)}, [1, 2], 7)
	if bool(inactive.get("active", false)):
		failures.append("ghost pressure should stay inactive before the wake tick")
	var active := manager.advance_ghost_pressure_for_test(manager.ghost_wake_tick_for_test() + 1, {1: 1, 2: 5}, {1: Vector2(100, 100), 2: Vector2(500, 100)}, [1, 2], 7, {1: true})
	if not bool(active.get("active", false)):
		failures.append("ghost pressure should activate deterministically after the wake tick")
	if int(active.get("target_peer_id", -1)) != 1:
		failures.append("ghost pressure should prioritize the straggling carrier deterministically")
	manager.free()

func _test_runtime_ecology_beyond_ghost(failures: Array[String]) -> void:
	var pressure_manager := NETWORK_MANAGER_SCRIPT.new()
	pressure_manager.current_delve_directive = {
		"control_surfaces": {
			"ecology": {
				"inhabitant_pressure": 2,
				"stalking_bias": 1,
				"anomaly_contamination": 2
			}
		}
	}
	pressure_manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "lantern_snuffer", "owner_peer_id": 2, "consumed": false}
	}
	var echo_interval := pressure_manager.noise_trace_interval_for_test(2)
	var watch_interval := pressure_manager.protocol_watch_interval_for_test(2)
	var echo_tick := pressure_manager.ghost_wake_tick_for_test() + 1
	while posmod(echo_tick + 2, echo_interval) != 0:
		echo_tick += 1
	var pressure_a := pressure_manager.advance_runtime_ecology_for_test(echo_tick, {2: 1, 3: 4}, {2: Vector2(100, 100), 3: Vector2(450, 100)}, [2, 3], 7, {2: true})
	var pressure_b := pressure_manager.advance_runtime_ecology_for_test(echo_tick, {2: 1, 3: 4}, {2: Vector2(100, 100), 3: Vector2(450, 100)}, [2, 3], 7, {2: true})
	if JSON.stringify(pressure_a) != JSON.stringify(pressure_b):
		failures.append("runtime ecology beyond ghost should remain deterministic for identical seeds, pressure, and positions")
	var watch_tick := pressure_manager.ghost_wake_tick_for_test() + 1
	while posmod(watch_tick + 2 + 7, watch_interval) != 0:
		watch_tick += 1
	var watch_a := pressure_manager.advance_runtime_ecology_for_test(watch_tick, {2: 1, 3: 4}, {2: Vector2(100, 100), 3: Vector2(450, 100)}, [2, 3], 7, {2: true})
	var watch_b := pressure_manager.advance_runtime_ecology_for_test(watch_tick, {2: 1, 3: 4}, {2: Vector2(100, 100), 3: Vector2(450, 100)}, [2, 3], 7, {2: true})
	if JSON.stringify(watch_a) != JSON.stringify(watch_b):
		failures.append("protocol-watch pressure should remain deterministic for identical seeds, pressure, and positions")
	var pressure_events: Array = pressure_a.get("public", [])
	var saw_echo_trace := false
	for event_raw in pressure_events:
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) == "noise_trace":
			saw_echo_trace = true
	if not saw_echo_trace:
		failures.append("runtime ecology beyond ghost should emit bounded anomaly echo traces through the existing public event path")
	var watch_events: Array = watch_a.get("public", [])
	var saw_protocol_watch := false
	for event_raw in watch_events:
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) == "hazard_state_changed":
			saw_protocol_watch = true
			break
	if not saw_protocol_watch:
		failures.append("runtime ecology beyond ghost should emit bounded protocol-watch pulses through the existing public hazard path")
	var protocol_watch_snapshot: Dictionary = Dictionary(watch_a.get("protocol_watch_state", {}))
	if str(protocol_watch_snapshot.get("mode", "")).strip_edges().is_empty() or int(protocol_watch_snapshot.get("signal_room_slot", -1)) < 0:
		failures.append("runtime ecology beyond ghost should now expose bounded protocol-watch mode and signal-room distinction")
	if not bool(Dictionary(pressure_a.get("ghost_state", {})).get("active", false)):
		failures.append("runtime ecology extension should remain layered on the existing host ghost authority path")
	pressure_manager.players = [2, 3]
	pressure_manager.profile_cards_by_peer = {
		2: {"public_id": "delver_A", "display_name": "Aster"},
		3: {"public_id": "delver_B", "display_name": "Bram"}
	}
	pressure_manager.artifacts_by_id = {
		10: {"artifact_id": 10, "owner_peer_id": 2, "room_slot": 1}
	}
	pressure_manager.ghost_state = Dictionary(pressure_a.get("ghost_state", {})).duplicate(true)
	pressure_manager.protocol_watch_state = Dictionary(watch_a.get("protocol_watch_state", {})).duplicate(true)
	var pressure_snapshot := pressure_manager.build_gameplay_signal_snapshot()
	var peer_models: Dictionary = Dictionary(pressure_snapshot.get("peer_models", {}))
	var carrier_model: Dictionary = Dictionary(peer_models.get("delver_A", {}))
	var carrier_signals: Array = carrier_model.get("inhabitant_signals", [])
	if not carrier_signals.has("echo pressure") or not carrier_signals.has("artifact watched") or not carrier_signals.has("protocol watched"):
		failures.append("runtime ecology extension should surface echo, artifact-watch, and protocol-watch signals through the existing snapshot path")
	pressure_manager.free()

	var recovery_manager := NETWORK_MANAGER_SCRIPT.new()
	recovery_manager.current_delve_directive = {
		"control_surfaces": {
			"ecology": {
				"inhabitant_pressure": 0,
				"stalking_bias": 0,
				"anomaly_contamination": 0
			}
		}
	}
	var recovery_result := recovery_manager.advance_runtime_ecology_for_test(maxi(echo_tick, watch_tick), {2: 1, 3: 4}, {2: Vector2(100, 100), 3: Vector2(450, 100)}, [2, 3], 7, {2: true})
	for event_raw in Array(recovery_result.get("public", [])):
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type == "noise_trace":
			failures.append("runtime ecology beyond ghost should not emit anomaly echo traces when anomaly contamination is absent")
			break
		if event_type == "hazard_state_changed":
			failures.append("runtime ecology beyond ghost should not emit protocol-watch pulses when inhabitant pressure is absent")
			break
	recovery_manager.free()

func _test_predator_rush_and_combat_scaling(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.current_delve_directive = {
		"control_surfaces": {
			"ecology": {
				"inhabitant_pressure": 2,
				"stalking_bias": 2,
				"anomaly_contamination": 0
			}
		}
	}
	var exposure_interval := manager.predator_rush_interval_for_test(2, 1)
	var intimate_interval := manager.predator_rush_interval_for_test(2, 3)
	var fracture_interval := manager.predator_rush_interval_for_test(2, 7)
	var expedition_interval := manager.predator_rush_interval_for_test(2, 12)
	if not (exposure_interval < intimate_interval and intimate_interval < fracture_interval and fracture_interval < expedition_interval):
		failures.append("predator-rush cadence should intensify as protocol density narrows")
	var watch_interval := manager.protocol_watch_interval_for_test(2)
	var actual_interval := manager.predator_rush_interval_for_test(2, 2)
	var predator_tick := -1
	var start_tick := manager.ghost_wake_tick_for_test() + 1
	for candidate in range(start_tick, start_tick + actual_interval * 4):
		if posmod(candidate + 2 + 5, actual_interval) != 0:
			continue
		if posmod(candidate + 2 + 7, watch_interval) == 0:
			continue
		predator_tick = candidate
		break
	if predator_tick < 0:
		failures.append("predator-rush tests should find a deterministic tick that avoids the protocol-watch cadence")
		manager.free()
		return
	var predator_a := manager.advance_runtime_ecology_for_test(predator_tick, {2: 5, 3: 1}, {2: Vector2(500, 100), 3: Vector2(100, 100)}, [2, 3], 7, {2: true})
	var predator_b := manager.advance_runtime_ecology_for_test(predator_tick, {2: 5, 3: 1}, {2: Vector2(500, 100), 3: Vector2(100, 100)}, [2, 3], 7, {2: true})
	if JSON.stringify(predator_a) != JSON.stringify(predator_b):
		failures.append("predator-rush pressure should remain deterministic for identical seeds, pressure, and positions")
	var predator_snapshot: Dictionary = Dictionary(predator_a.get("predator_state", {}))
	if not bool(predator_snapshot.get("active", false)) or int(predator_snapshot.get("target_peer_id", -1)) != 2:
		failures.append("predator-rush pressure should deterministically target the isolated artifact carrier")
	if int(predator_snapshot.get("strike_strength", 0)) < 2:
		failures.append("predator-rush pressure should now distinguish stronger strikes against isolated or burdened carriers")
	var saw_predator_pulse := false
	for event_raw in Array(predator_a.get("public", [])):
		var event: Dictionary = event_raw
		if str(event.get("event_type", "")) == "hazard_state_changed":
			saw_predator_pulse = true
			break
	if not saw_predator_pulse:
		failures.append("predator-rush pressure should reuse the existing public hazard path")
	manager.players = [2, 3]
	manager.profile_cards_by_peer = {
		2: {"public_id": "delver_A", "display_name": "Aster"},
		3: {"public_id": "delver_B", "display_name": "Bram"}
	}
	manager.artifacts_by_id = {
		10: {"artifact_id": 10, "owner_peer_id": 2, "room_slot": 5}
	}
	manager.predator_state = predator_snapshot.duplicate(true)
	var snapshot := manager.build_gameplay_signal_snapshot()
	var peer_models: Dictionary = Dictionary(snapshot.get("peer_models", {}))
	var carrier_model: Dictionary = Dictionary(peer_models.get("delver_A", {}))
	var carrier_signals: Array = carrier_model.get("inhabitant_signals", [])
	if not carrier_signals.has("predator rush") or not carrier_signals.has("predator marked"):
		failures.append("predator-rush pressure should surface through the existing gameplay snapshot path")
	manager.free()

	var controller := GAME_CONTROLLER_SCRIPT.new()
	var strike_targets := controller.predator_damage_targets_for_test(5, predator_snapshot, {2: 5, 3: 1})
	if strike_targets.size() != 1 or int(strike_targets[0]) != 2:
		failures.append("predator-rush combat should only threaten the marked peer when they remain in the pressured room")
	var moved_targets := controller.predator_damage_targets_for_test(5, predator_snapshot, {2: 4, 3: 1})
	if not moved_targets.is_empty():
		failures.append("predator-rush combat should clear if the marked peer leaves the pressured room")
	var dummy := DummyDamageTarget.new()
	var hits := controller.apply_predator_rush_damage_for_test(5, predator_snapshot, {2: 5, 3: 1}, {2: dummy})
	if hits.size() != 1 or int(hits[0]) != 2 or dummy.health != 2:
		failures.append("predator-rush combat should apply one bounded point of host-side damage through the existing actor path")
	controller.free()

func _test_inhabitant_differentiation_deepening(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.current_delve_directive = {
		"control_surfaces": {
			"ecology": {
				"inhabitant_pressure": 2,
				"stalking_bias": 2,
				"anomaly_contamination": 1
			}
		}
	}
	manager.players = [2, 3]
	manager.roles_by_peer = {2: ROLE_SERVICE_SCRIPT.ROLE_VEIL, 3: ROLE_SERVICE_SCRIPT.ROLE_WARDEN}
	manager.custody_debt_by_peer = {2: 2}
	manager.suspicion_heat_by_peer = {2: 2}
	manager.counterfeit_heat_by_peer = {2: 2}
	manager.extraction_window_started_tick = 30
	manager.extraction_window_owner_peer_id = 2
	var watch_interval := manager.protocol_watch_interval_for_test(2)
	var protocol_tick := -1
	for candidate in range(manager.ghost_wake_tick_for_test() + 1, manager.ghost_wake_tick_for_test() + watch_interval * 4):
		if posmod(candidate + 2 + 7, watch_interval) == 0:
			protocol_tick = candidate
			break
	if protocol_tick < 0:
		failures.append("inhabitant differentiation test should find a deterministic protocol-watch tick")
		manager.free()
		return
	var result := manager.advance_runtime_ecology_for_test(protocol_tick, {2: 5, 3: 2}, {2: Vector2(500, 100), 3: Vector2(220, 100)}, [2, 3], 7, {2: true})
	var protocol_state: Dictionary = Dictionary(result.get("protocol_watch_state", {}))
	if str(protocol_state.get("mode", "")) != "containment":
		failures.append("protocol-watch pressure should now distinguish containment mode under counterfeit custody heat")
	if int(protocol_state.get("signal_room_slot", -1)) != 5:
		failures.append("containment-mode protocol watch should keep its signal on the pressured room")
	var saw_abort := false
	var saw_trace := false
	for event_raw in Array(result.get("public", [])):
		var event: Dictionary = event_raw
		var event_type := str(event.get("event_type", ""))
		if event_type == "extraction_window_aborted":
			saw_abort = true
		elif event_type == "noise_trace":
			saw_trace = true
	if not saw_trace:
		failures.append("protocol-watch differentiation should now emit an explicit sweep trace through the existing public path")
	if not saw_abort:
		failures.append("containment-mode protocol watch should now be able to abort an active extraction window on the same host owner path")
	manager.free()

func _test_new_item_runtime_and_inhabitant_modes(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	manager.run_active = true
	manager.current_server_tick = 180
	manager.players = [2, 3]
	manager.roles_by_peer = {2: ROLE_SERVICE_SCRIPT.ROLE_BEARER, 3: ROLE_SERVICE_SCRIPT.ROLE_MURMUR}
	manager.player_room_by_peer = {2: 5, 3: 4}
	manager.player_pos_by_peer = {2: Vector2(520, 100), 3: Vector2(360, 100)}
	manager.extraction_room_slot = 7
	manager.current_delve_directive = {
		"control_surfaces": {
			"ecology": {
				"inhabitant_pressure": 2,
				"stalking_bias": 2,
				"anomaly_contamination": 1
			}
		}
	}
	manager.current_generation_contract = RUN_GENERATOR_SCRIPT.new().build_generation_contract(0, {
		"generation_contract": {
			"protocol_state": "Fracture Protocol",
			"cookbook_routing": {
				"anti_protocol_pull": 2
			}
		}
	})
	manager.artifacts_by_id = {
		101: {
			"artifact_id": 101,
			"owner_peer_id": 2,
			"room_slot": 5,
			"is_forged": false
		}
	}
	manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "custody_seal", "display_name": "Custody Seal", "owner_peer_id": 2, "room_slot": 5, "world_pos": Vector2.ZERO, "consumed": false},
		2: {"item_id": 2, "item_def_id": "echo_lure", "display_name": "Echo Lure", "owner_peer_id": 3, "room_slot": 4, "world_pos": Vector2.ZERO, "consumed": false},
		3: {"item_id": 3, "item_def_id": "witness_chime", "display_name": "Witness Chime", "owner_peer_id": 2, "room_slot": 5, "world_pos": Vector2.ZERO, "consumed": false},
		4: {"item_id": 4, "item_def_id": "burden_sling", "display_name": "Burden Sling", "owner_peer_id": 2, "room_slot": 5, "world_pos": Vector2.ZERO, "consumed": false}
	}
	manager.custody_debt_by_peer = {2: 2}
	manager.suspicion_heat_by_peer = {2: 1, 3: 1}
	manager.counterfeit_heat_by_peer = {3: 2}
	manager.extraction_window_started_tick = 120
	manager.extraction_window_owner_peer_id = 2
	manager.extraction_window_artifact_id = 101
	var seal_start_tick := manager.extraction_window_started_tick
	manager.host_use_item_for_test(2, 1, 5)
	if manager.extraction_window_started_tick >= seal_start_tick:
		failures.append("custody seal should materially speed an authentic extraction line on the host owner path")
	if int(manager.custody_debt_by_peer.get(2, 0)) >= 2 or int(manager.suspicion_heat_by_peer.get(2, 0)) >= 1:
		failures.append("custody seal should materially steady live custody pressure for an authentic carrier")
	var chime_suspicion := int(manager.suspicion_heat_by_peer.get(2, 0))
	manager.host_use_item_for_test(2, 3, 5)
	if int(manager.suspicion_heat_by_peer.get(2, 0)) > chime_suspicion:
		failures.append("witness chime should not punish an authentic live carrier more than the pre-chime line")
	manager.host_use_item_for_test(3, 2, 4)
	var lure_room := int(Dictionary(manager.echo_lure_state).get("room_slot", -1))
	if lure_room < 0:
		failures.append("echo lure should establish a bounded runtime lure room on the host ecology path")
	var watch_interval := manager.protocol_watch_interval_for_test(3)
	var protocol_tick := -1
	for candidate in range(manager.ghost_wake_tick_for_test() + 1, manager.ghost_wake_tick_for_test() + watch_interval * 4):
		if posmod(candidate + 3 + manager.extraction_room_slot, watch_interval) == 0:
			protocol_tick = candidate
			break
	if protocol_tick < 0:
		failures.append("new item runtime test should find a deterministic protocol-watch tick")
	else:
		var result := manager.advance_runtime_ecology_for_test(protocol_tick, {2: 5, 3: 4}, {2: Vector2(520, 100), 3: Vector2(360, 100)}, [2, 3], 7, {2: true})
		var protocol_state: Dictionary = Dictionary(result.get("protocol_watch_state", {}))
		if str(protocol_state.get("mode", "")) != "interdiction" or int(protocol_state.get("target_peer_id", -1)) != 3:
			failures.append("echo lure should produce a distinct interdiction-mode protocol watch against the lure owner")
		if int(protocol_state.get("signal_room_slot", -1)) != lure_room:
			failures.append("interdiction-mode protocol watch should signal the bounded lure room instead of a generic room")
	var signals := manager._build_inhabitant_pressure_signals(3, "Fracture Protocol", false)
	if not signals.has("echo lure"):
		failures.append("new bounded ecology items should surface through the existing inhabitant signal snapshot")
	manager.free()

func _test_run_end_tick_determinism(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	var tick_limit: int = int(NETWORK_MANAGER_SCRIPT.RUN_TICK_LIMIT)
	var progression: Array[int] = [100, 450, 999, 1400, tick_limit - 1, tick_limit, tick_limit + 50]
	var trigger_a := -1
	var trigger_b := -1
	for tick in progression:
		if manager.should_end_run_for_tick(tick):
			trigger_a = tick
			break
	for tick in progression:
		if manager.should_end_run_for_tick(tick):
			trigger_b = tick
			break
	if trigger_a != tick_limit or trigger_b != tick_limit:
		failures.append("run end should deterministically trigger at tick limit")
	manager.free()

func _test_extraction_objective_end_reason(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	manager.run_active = true
	manager.current_server_tick = 120
	manager.extraction_room_slot = 7
	manager.player_room_by_peer = {2: 7}
	manager.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 2, "room_slot": 4},
		2: {"artifact_id": 2, "owner_peer_id": 0, "room_slot": 7}
	}
	var reason := manager.compute_end_reason_for_tick(120)
	if reason != "":
		failures.append("objective end should wait for extraction window before completing")
	if manager.extraction_window_started_tick != 120:
		failures.append("objective end should capture the extraction window start tick when the carrier reaches extraction room slot")
	if manager.extraction_window_artifact_id != 1 or manager.extraction_window_owner_peer_id != 2:
		failures.append("objective end should capture the extraction window artifact and carrier deterministically")
	if manager.next_event_id != 2:
		failures.append("objective end should emit exactly one extraction_window_started event when the window begins")
	var hold_tick := 120 + manager.extraction_window_ticks_for_test()
	var hold_reason := manager.compute_end_reason_for_tick(hold_tick)
	if hold_reason != "extraction_objective":
		failures.append("objective end should complete after the deterministic extraction window elapses")
	manager.current_server_tick = hold_tick
	var extraction_details: Dictionary = manager._find_extraction_completion_details()
	if extraction_details.is_empty():
		failures.append("objective end should still have extraction details after the hold finishes")
	else:
		manager.record_public_event("extraction_completed", int(extraction_details.get("room_slot", -1)), int(extraction_details.get("owner_peer_id", -1)), {
			"artifact_id": int(extraction_details.get("artifact_id", 0))
		})
		manager.record_public_event("run_ended", -1, -1, {})
	if manager.next_event_id != 4:
		failures.append("objective end should reserve sequential event ids for extraction_completed then run_ended after the hold finishes")
	manager.free()

func _test_role_reveal_secrecy_until_end(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	var start_payload := manager.build_run_start_payload(1337, [], [1, 2, 3])
	if start_payload.has("roles_reveal") or start_payload.has("roles_by_peer"):
		failures.append("run start payload must not include role reveal map")

	manager.roles_by_peer = {1: "Warden", 2: "Veil", 3: "Scavenger"}
	var reveal_peers: Array[int] = [1, 2, 3]
	manager.players = reveal_peers
	var end_payload := manager.build_run_end_payload("tick_limit", 1337)
	if not end_payload.has("roles_reveal"):
		failures.append("run end payload must include role reveal map")
	var roles_reveal: Dictionary = end_payload.get("roles_reveal", {})
	if roles_reveal.is_empty():
		failures.append("run end role reveal map should not be empty")
	manager.free()

func _test_end_payload_contract(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	var helpers = NET_HELPERS_SCRIPT.new()
	var end_peers: Array[int] = [1, 2]
	manager.players = end_peers
	manager.roles_by_peer = {1: "Warden", 2: "Veil"}
	manager.artifacts_by_id = {10: {"artifact_id": 10, "owner_peer_id": 2}}
	var payload := manager.build_run_end_payload("tick_limit", 2026)
	if not payload.has("seed") or not payload.has("roles_reveal") or not payload.has("summary_by_peer"):
		failures.append("run end payload missing required fields (seed/roles_reveal/summary_by_peer)")

	var contaminated := {"seed": 5, "role": "Veil", "sabotage": true}
	var public_meta := helpers.public_meta_allowlist("run_ended", contaminated)
	if not public_meta.is_empty():
		failures.append("run_ended public meta should be empty by allowlist")
	manager.free()

func _test_inspection_autonote_private_and_throttled(failures: Array[String]) -> void:
	var controller_script = load("res://src/run/game_controller.gd")
	if controller_script == null:
		failures.append("game_controller script should load for inspection autonote test")
		return
	var controller = controller_script.new()
	var event_log = EVENT_LOG_SCRIPT.new()
	var inspected_event := {
		"tick": 40,
		"event_id": 5,
		"room_slot": 3,
		"actor_peer_id": 2,
		"event_type": "warden_check_result",
		"visibility": "private",
		"target_peer_id": 2,
		"meta": {"artifact_id": 4, "score": 73}
	}
	controller.apply_autonote_for_test(event_log, inspected_event, 2, 40)
	controller.apply_autonote_for_test(event_log, inspected_event, 2, 45)
	var public_events: Array = event_log.get_recent_public(8)
	var private_events: Array = event_log.get_recent_private_for(2, 8)
	if not public_events.is_empty():
		failures.append("inspection autonote should never appear in the public event feed")
	if private_events.size() != 1:
		failures.append("inspection autonote throttle should allow only one private notebook note inside the throttle window")
	elif str(Dictionary(private_events[0]).get("event_type", "")) != "notebook_note_added":
		failures.append("inspection autonote should emit notebook_note_added")
	else:
		var note: Dictionary = private_events[0]
		if int(note.get("target_peer_id", -1)) != 2:
			failures.append("inspection autonote should remain target-scoped to the local peer")
		var note_text := str(Dictionary(note.get("meta", {})).get("text", ""))
		if note_text.find("Checked E4 in room 3") == -1:
			failures.append("inspection autonote should include the checked artifact and room in the private note text")
	controller.apply_autonote_for_test(event_log, inspected_event, 2, 80)
	if event_log.get_recent_private_for(2, 8).size() != 2:
		failures.append("inspection autonote should create a second note after the deterministic throttle window expires")
	controller.free()
	event_log.free()

func _test_notebook_pin_private_and_export_ordering(failures: Array[String]) -> void:
	var controller_script = load("res://src/run/game_controller.gd")
	if controller_script == null:
		failures.append("game_controller script should load for notebook pin test")
		return
	var controller = controller_script.new()
	var event_log = EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"event_id": 1,
		"tick": 10,
		"room_slot": 1,
		"actor_peer_id": 2,
		"event_type": "notebook_note_added",
		"visibility": "private",
		"target_peer_id": 2,
		"meta": {"text": "Checked E4 in room 3", "tag": "EVIDENCE"}
	})
	event_log.add_event({
		"event_id": 2,
		"tick": 20,
		"room_slot": 1,
		"actor_peer_id": 2,
		"event_type": "notebook_note_added",
		"visibility": "private",
		"target_peer_id": 2,
		"meta": {"text": "SUSPECT: player lingered", "tag": "SUSPECT"}
	})
	event_log.add_event({
		"event_id": 3,
		"tick": 21,
		"room_slot": 1,
		"actor_peer_id": 2,
		"event_type": "notebook_note_pin_toggled",
		"visibility": "private",
		"target_peer_id": 2,
		"meta": {"note_event_id": 1, "pinned": true}
	})
	if not event_log.get_recent_public(8).is_empty():
		failures.append("notebook pin events should not appear in the public event feed")
	var notes: Array = controller.get_notebook_notes_for_test(event_log, 2, 8)
	if notes.size() != 2:
		failures.append("notebook note collection should return both local private notes")
	else:
		var first: Dictionary = notes[0]
		var second: Dictionary = notes[1]
		if int(first.get("note_event_id", -1)) != 1 or not bool(first.get("pinned", false)):
			failures.append("pinned notebook note should sort first in private notebook ordering")
		if int(second.get("note_event_id", -1)) != 2:
			failures.append("unpinned notebook notes should follow pinned notes by time")
	var note_lines: Array[String] = controller.build_private_notes_feed_lines_for_test(event_log, 2, 8)
	var joined := "\n".join(note_lines)
	if joined.find("[PIN] t0010: EVIDENCE: Checked E4 in room 3") == -1:
		failures.append("private notes export/order should render pinned evidence notes first")
	if joined.find("SUSPECT: player lingered") == -1:
		failures.append("private notes export/order should still include unpinned notes")
	controller.free()
	event_log.free()

func _test_notebook_filters_copy_and_sections(failures: Array[String]) -> void:
	var controller_script = load("res://src/run/game_controller.gd")
	if controller_script == null:
		failures.append("game_controller script should load for notebook filter/copy test")
		return
	var controller = controller_script.new()
	var event_log = EVENT_LOG_SCRIPT.new()
	event_log.add_event(controller._build_notebook_note_event("Checked E4 in room 3", 2, 10, 1, 3))
	event_log.add_event(controller._build_notebook_note_event("SUSPECT: player lingered", 2, 20, 2, 3))
	event_log.add_event(controller._build_notebook_note_event("ALIBI: stayed in room 1", 2, 30, 3, 1))
	event_log.add_event(controller._build_notebook_note_event("plain observation", 2, 40, 4, 2))
	event_log.add_event({
		"event_id": 5,
		"tick": 41,
		"room_slot": 2,
		"actor_peer_id": 2,
		"event_type": "notebook_note_pin_toggled",
		"visibility": "private",
		"target_peer_id": 2,
		"meta": {"note_event_id": 1, "pinned": true}
	})
	if not event_log.get_recent_public(8).is_empty():
		failures.append("notebook filter/copy data should never appear in the public event feed")
	if controller.get_notebook_notes_filtered_for_test(event_log, 2, 8, "ALL").size() != 4:
		failures.append("ALL notebook filter should return all local notes")
	var pinned_notes: Array = controller.get_notebook_notes_filtered_for_test(event_log, 2, 8, "PINNED")
	if pinned_notes.size() != 1 or int(Dictionary(pinned_notes[0]).get("note_event_id", -1)) != 1:
		failures.append("PINNED notebook filter should return only the pinned evidence note")
	var evidence_notes: Array = controller.get_notebook_notes_filtered_for_test(event_log, 2, 8, "EVIDENCE")
	if evidence_notes.size() != 1 or not bool(Dictionary(evidence_notes[0]).get("pinned", false)):
		failures.append("EVIDENCE notebook filter should return the pinned evidence note")
	var suspect_notes: Array = controller.get_notebook_notes_filtered_for_test(event_log, 2, 8, "SUSPECT")
	if suspect_notes.size() != 1 or str(Dictionary(suspect_notes[0]).get("tag", "")) != "SUSPECT":
		failures.append("SUSPECT notebook filter should return the suspect-tagged note")
	var alibi_notes: Array = controller.get_notebook_notes_filtered_for_test(event_log, 2, 8, "ALIBI")
	if alibi_notes.size() != 1 or str(Dictionary(alibi_notes[0]).get("tag", "")) != "ALIBI":
		failures.append("ALIBI notebook filter should return the alibi-tagged note")
	var other_notes: Array = controller.get_notebook_notes_filtered_for_test(event_log, 2, 8, "OTHER")
	if other_notes.size() != 1 or controller._effective_notebook_tag(str(Dictionary(other_notes[0]).get("tag", ""))) != "OTHER":
		failures.append("OTHER notebook filter should return only untagged notes")
	var section_lines: Array[String] = controller.build_private_notes_sections_for_test(event_log, 2, 8, "ALL")
	var section_text := "\n".join(section_lines)
	if section_text.find("PINNED NOTES") == -1 or section_text.find("OTHER NOTES") == -1:
		failures.append("private notebook sections should include pinned and other section headers")
	var pinned_index := section_text.find("[PIN] t0010: EVIDENCE: Checked E4 in room 3")
	var suspect_index := section_text.find("t0020: SUSPECT: player lingered")
	if pinned_index == -1 or suspect_index == -1 or pinned_index > suspect_index:
		failures.append("private notebook sections should render the pinned evidence note before other notes")
	var copy_text: String = controller.build_notebook_copy_text_for_test(event_log, 2, 8, "ALL")
	if copy_text.find("PINNED NOTES") == -1 or copy_text.find("OTHER NOTES") == -1:
		failures.append("notebook copy payload should contain the same section headers as the private notes view")
	if copy_text.find("[PIN] t0010: EVIDENCE: Checked E4 in room 3") == -1:
		failures.append("notebook copy payload should include the pinned evidence note")
	controller.free()
	event_log.free()

func _test_run_report_stats_action_summary_and_hint_logic(failures: Array[String]) -> void:
	var controller_script = load("res://src/run/game_controller.gd")
	if controller_script == null:
		failures.append("game_controller script should load for report summary/hint test")
		return
	var controller = controller_script.new()
	var empty_log = EVENT_LOG_SCRIPT.new()
	var no_notes_hint: String = controller.compute_next_step_hint_for_test_with_state(empty_log, 2, false, 7)
	if no_notes_hint.find("notebook") == -1:
		failures.append("next-step hint should recommend the notebook when the player has no notes")
	var ghost_hint: String = controller.compute_next_step_hint_for_test_with_full_state(empty_log, 2, false, 7, ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER, true, true, false)
	if ghost_hint.find("Ghost is on you") == -1:
		failures.append("next-step hint should warn the local player when ghost pressure is targeting them")
	var extraction_hint: String = controller.compute_next_step_hint_for_test_with_full_state(empty_log, 2, true, 7, ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER, false, false, true)
	if extraction_hint.find("Hold still in Extraction room 7") == -1:
		failures.append("next-step hint should explain the extraction hold state clearly")
	var event_log = EVENT_LOG_SCRIPT.new()
	event_log.add_event(controller._build_notebook_note_event("SUSPECT: player lingered in room 3 for too long", 2, 10, 1, 3))
	event_log.add_event({
		"event_id": 2,
		"tick": 11,
		"room_slot": 3,
		"actor_peer_id": 2,
		"event_type": "notebook_note_pin_toggled",
		"visibility": "private",
		"target_peer_id": 2,
		"meta": {"note_event_id": 1, "pinned": true}
	})
	var inspect_hint: String = controller.compute_next_step_hint_for_test_with_full_state(event_log, 2, false, 7, ROLE_SERVICE_SCRIPT.ROLE_WARDEN, false, false, false)
	if inspect_hint.find("inspect") == -1:
		failures.append("next-step hint should recommend inspection once the player has notes but no inspections")
	event_log.add_event({
		"event_id": 3,
		"tick": 20,
		"room_slot": 3,
		"actor_peer_id": 2,
		"event_type": "warden_check_result",
		"visibility": "private",
		"target_peer_id": 2,
		"meta": {"artifact_id": 4, "score": 73}
	})
	event_log.add_event({
		"event_id": 4,
		"tick": 30,
		"room_slot": 7,
		"actor_peer_id": -1,
		"event_type": "extraction_window_started",
		"visibility": "public",
		"meta": {"duration_ticks": 600}
	})
	event_log.add_event({
		"event_id": 5,
		"tick": 40,
		"room_slot": 7,
		"actor_peer_id": 2,
		"event_type": "extraction_completed",
		"visibility": "public",
		"meta": {"artifact_id": 4}
	})
	event_log.add_event({
		"event_id": 6,
		"tick": 41,
		"room_slot": -1,
		"actor_peer_id": -1,
		"event_type": "run_ended",
		"visibility": "public",
		"meta": {}
	})
	event_log.add_event({
		"event_id": 7,
		"tick": 42,
		"room_slot": 3,
		"actor_peer_id": -1,
		"event_type": "bomb_exploded",
		"visibility": "public",
		"meta": {}
	})
	event_log.add_event({
		"event_id": 8,
		"tick": 43,
		"room_slot": 4,
		"actor_peer_id": -1,
		"event_type": "noise_trace",
		"visibility": "public",
		"meta": {}
	})
	event_log.add_event({
		"event_id": 9,
		"tick": 44,
		"room_slot": 4,
		"actor_peer_id": -1,
		"event_type": "artifact_dropped",
		"visibility": "public",
		"meta": {"artifact_id": 4}
	})
	event_log.add_event({
		"event_id": 10,
		"tick": 45,
		"room_slot": 5,
		"actor_peer_id": -1,
		"event_type": "item_used",
		"visibility": "public",
		"meta": {"label": "Zipline deployed"}
	})
	event_log.add_event({
		"event_id": 11,
		"tick": 46,
		"room_slot": 6,
		"actor_peer_id": -1,
		"event_type": "rope_deployed",
		"visibility": "public",
		"meta": {"len": 320}
	})
	event_log.add_event({
		"event_id": 12,
		"tick": 47,
		"room_slot": 6,
		"actor_peer_id": -1,
		"event_type": "hazard_state_changed",
		"visibility": "public",
		"meta": {}
	})
	for public_event in event_log.get_recent_public(16):
		var event_type := str(Dictionary(public_event).get("event_type", ""))
		if event_type in ["notebook_note_added", "notebook_note_pin_toggled", "warden_check_result"]:
			failures.append("private notebook/inspection events should never leak into the public event feed")
			break
	var action_lines: Array[String] = controller.build_action_summary_lines_for_test(event_log, 2, 12)
	var action_text := "\n".join(action_lines)
	if action_text.find("Inspected Artifact 4") == -1:
		failures.append("action summary should include inspected artifact lines")
	if action_text.find("Note: SUSPECT:") == -1:
		failures.append("action summary should include notebook note lines with tags")
	if action_text.find("Extraction completed") == -1:
		failures.append("action summary should include extraction completion lines")
	if action_text.find("Bomb blast left a scorch mark") == -1:
		failures.append("action summary should surface bomb blast forensic recap lines")
	if action_text.find("Artifact rerouted") == -1 or action_text.find("decoy trail") == -1:
		failures.append("action summary should surface decoy reroute confusion lines")
	if action_text.find("Zipline changed the route") == -1:
		failures.append("action summary should surface route-changing zipline use clearly")
	if action_text.find("Rope changed the route") == -1 or action_text.find("Trap timing shifted") == -1:
		failures.append("action summary should surface rope routes and trap timing turns")
	var clue_lines: Array[String] = controller.build_key_clue_lines_for_test(event_log, 8)
	var clue_text := "\n".join(clue_lines)
	if clue_text.find("Bomb blast scarred room 3") == -1:
		failures.append("key clue recap should surface bomb blast rooms")
	if clue_text.find("Artifact route changed in room 4") == -1:
		failures.append("key clue recap should surface ambiguous artifact reroutes")
	if clue_text.find("A zipline committed the route in room 5") == -1:
		failures.append("key clue recap should surface zipline route commitments")
	if clue_text.find("A rope rewrote room 6") == -1 or clue_text.find("A trap pulsed in room 6") == -1:
		failures.append("key clue recap should surface room-level route and timing suspicion")
	if clue_text.find("Extraction hold began in room 7") == -1:
		failures.append("key clue recap should surface extraction pressure timing")
	var stats_lines: Array[String] = controller.build_run_stats_lines_for_test(event_log, 2)
	var stats_text := "\n".join(stats_lines)
	if stats_text.find("Notes: 1 (Pinned: 1)") == -1:
		failures.append("run stats should include note and pinned counts")
	if stats_text.find("Inspections: 1 (Artifacts: 1)") == -1:
		failures.append("run stats should include inspection counts and distinct artifact count")
	if stats_text.find("Extraction: Completed") == -1:
		failures.append("run stats should include extraction completion state")
	var carrying_hint: String = controller.compute_next_step_hint_for_test_with_state(event_log, 2, true, 7)
	if carrying_hint.find("Artifact") == -1 or carrying_hint.find("Extraction room 7") == -1:
		failures.append("next-step hint should point carrying players to the extraction room")
	var quick_tag: String = controller.apply_quick_tag_shortcuts_for_test("lingered near exit", "SUSPECT")
	if quick_tag != "SUSPECT: lingered near exit":
		failures.append("quick-tag helper should prefix suspect notes deterministically")
	var pickup_text: String = controller.describe_item_pickup_for_test({"item_def_id": "zipline_kit", "display_name": "Zipline Kit"})
	if pickup_text != "Tool - Zipline Kit":
		failures.append("item pickup description should distinguish tools from artifacts and relics")
	var active_text: String = controller.describe_active_item_for_test({"item_def_id": "decoy_emitter", "display_name": "Decoy Emitter"})
	if active_text.find("Decoy") == -1:
		failures.append("active item description should use the readable tool label")
	var help_text: String = controller._build_help_overlay_text()
	if help_text.find("authentic Artifact") == -1 or help_text.find("Tools are active. Relics are passive.") == -1 or help_text.find("Up: grab zipline") == -1:
		failures.append("help overlay text should explain the objective, item categories, and zipline usage")
	controller.free()
	empty_log.free()
	event_log.free()

func _test_run_guidance_packet_and_live_briefing(failures: Array[String]) -> void:
	var controller_script = load("res://src/run/game_controller.gd")
	if controller_script == null:
		failures.append("game_controller script should load for run guidance packet tests")
		return
	var controller = controller_script.new()
	var role_payload := ROLE_SERVICE_SCRIPT.new().build_private_role_payload(ROLE_SERVICE_SCRIPT.ROLE_WARDEN)
	var packet: Dictionary = controller.build_run_guidance_packet_for_test(
		{
			"protocol_state": "Intimate Protocol",
			"doctrine_label": "Witness Pressure",
			"pressure_line": "Escort the readable line before rumor hardens.",
			"world_goal": "Keep custody visible under pair pressure.",
			"group_tension_bias": "trust-fragile but obligation-heavy",
			"item_ecology_bias": "rescue burden custody",
			"convergence_axis": "artifact custody"
		},
		{
			"branch_family_name": "Relay Hollows",
			"challenge_texture": "route_revision",
			"rescue_climate": "covering_retreat",
			"witness_pressure": "public",
			"route_commitment": "fluid"
		},
		role_payload,
		{
			"carrying_artifact": true,
			"protocol_watch_active": true,
			"protocol_watch_target_local": true
		}
	)
	var run_kind := str(packet.get("run_kind_line", ""))
	if run_kind.find("Intimate Protocol") == -1 or run_kind.find("Relay Hollows") == -1 or run_kind.find("Witness Pressure") == -1:
		failures.append("run guidance packet should name the protocol, branch family, and doctrine in one readable run-kind line")
	var focus_text := "\n".join(Array(packet.get("focus_lines", [])))
	for required_line in ["Pressure:", "Stakes:", "Route:", "Social:", "Artifact line:", "Role duty:", "Role affordances:"]:
		if focus_text.find(required_line) == -1:
			failures.append("run guidance packet should expose %s through the existing HUD/help owner path" % required_line.replace(":", "").to_lower())
	var action_tip := str(packet.get("action_tip", "")).to_lower()
	if action_tip.find("explainable") == -1 and action_tip.find("handoff") == -1 and action_tip.find("hold") == -1:
		failures.append("run guidance packet should turn live pressure into an actionable tip rather than only a theme line")
	controller.free()

	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var session_overview := {
		"connected": true,
		"delve_protocol": {
			"protocol_state": "Fracture Protocol",
			"doctrine_label": "Burden Chain",
			"pressure_line": "Split accountability is loading the route."
		}
	}
	var continue_text := "\n".join(PROFILE_SERVICE_SCRIPT.build_continue_guidance_lines(profile, session_overview))
	if continue_text.find("Fracture Protocol") == -1 or continue_text.find("Burden Chain") == -1:
		failures.append("continue guidance should surface the live Delve brief instead of staying generic while connected")
	var home_text := "\n".join(PROFILE_SERVICE_SCRIPT.build_home_overview_lines(profile, session_overview, catalog))
	if home_text.find("Live briefing: Fracture Protocol | Burden Chain | Split accountability is loading the route.") == -1:
		failures.append("home overview should expose the same live Delve brief through the existing shell overview path")

func _test_product_catalog_and_profile_progression(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var catalog_failures := PRODUCT_CATALOG_SCRIPT.validate_catalog(catalog)
	if not catalog_failures.is_empty():
		failures.append("product catalog should validate cleanly: %s" % ", ".join(catalog_failures))
		return
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var run_record := {
		"seed": 1337,
		"end_reason": "extraction_objective",
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_WARDEN,
		"role_result_success": true,
		"outcome_summary": {
			"summary_text": "Expedition success",
			"artifact_result_text": "Authentic artifact extracted",
			"expedition_success": true,
			"sabotage_success": false
		},
		"stats": {
			"notes_count": 3,
			"pinned_count": 1,
			"inspections_count": 2,
			"distinct_artifacts_inspected": 1,
			"extraction_started": true,
			"extraction_completed": true
		},
		"stats_lines": ["Notes: 3 (Pinned: 1)", "Inspections: 2 (Artifacts: 1)", "Extraction: Completed"],
		"action_summary": ["Inspected Artifact 4 (room 3)", "Extraction completed"],
		"key_clues": ["A zipline committed the route in room 5"],
		"report_path": "user://reports/run_1337_extraction_objective_1_1.txt",
		"item_defs": ["zipline_kit", "timeline_bookmark"],
		"room_families": ["traversal", "evidence", "hazard"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_WARDEN],
		"clue_families": ["placed_zipline", "bomb_exploded"]
	}
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var next_profile: Dictionary = result.get("profile", {})
	var rewards: Dictionary = result.get("rewards", {})
	if int(Dictionary(next_profile.get("account", {})).get("runs", 0)) != 1:
		failures.append("profile progression should increment total runs")
	if int(Dictionary(next_profile.get("account", {})).get("xp", 0)) != int(rewards.get("account_xp", -1)):
		failures.append("profile progression should add deterministic account xp")
	if int(Dictionary(next_profile.get("account", {})).get("level", 0)) < 2:
		failures.append("profile progression should unlock account level 2 from a successful run")
	var mastery: Dictionary = Dictionary(next_profile.get("mastery", {}))
	if int(Dictionary(mastery.get(ROLE_SERVICE_SCRIPT.ROLE_WARDEN, {})).get("level", 0)) < 2:
		failures.append("profile progression should advance Warden mastery from a successful Warden run")
	for required_role in [ROLE_SERVICE_SCRIPT.ROLE_STEWARD, ROLE_SERVICE_SCRIPT.ROLE_BEARER, ROLE_SERVICE_SCRIPT.ROLE_MURMUR]:
		if not mastery.has(required_role):
			failures.append("default profile mastery should include expanded role track %s" % required_role)
	var discoveries: Dictionary = Dictionary(next_profile.get("discoveries", {}))
	if not Array(discoveries.get("item_defs", [])).has("zipline_kit"):
		failures.append("profile progression should log discovered item defs")
	if not Array(discoveries.get("room_families", [])).has("hazard"):
		failures.append("profile progression should log discovered room families")
	if not Array(discoveries.get("artifact_states", [])).has("authentic"):
		failures.append("profile progression should log artifact outcome families")
	if not Array(discoveries.get("clue_families", [])).has("placed_zipline"):
		failures.append("profile progression should log clue families")
	var owned: Array = Dictionary(next_profile.get("cosmetics", {})).get("owned", [])
	if not owned.has("title_tunnel_scout"):
		failures.append("account level progression should unlock the Tunnel Scout title")
	var last_run_lines := PROFILE_SERVICE_SCRIPT.build_last_run_lines(next_profile)
	var last_run_text := "\n".join(last_run_lines)
	if last_run_text.find("XP +") == -1 or last_run_text.find("Authentic artifact extracted") == -1:
		failures.append("last run summary should include earned xp and artifact result text")
	var title_lines := PROFILE_SERVICE_SCRIPT.build_cosmetic_lines(next_profile, "title", catalog)
	if "\n".join(title_lines).find("Tunnel Scout") == -1:
		failures.append("cosmetic catalog output should surface newly unlocked titles")
	var achievement_lines := PROFILE_SERVICE_SCRIPT.build_achievement_lines(next_profile, catalog)
	if "\n".join(achievement_lines).find("[Unlocked] First Descent") == -1:
		failures.append("profile progression should unlock the First Descent milestone on the first run")
	var preview_lines := PROFILE_SERVICE_SCRIPT.build_progression_preview_lines(next_profile, catalog)
	if "\n".join(preview_lines).find("Next rank:") == -1 or "\n".join(preview_lines).find("Next cosmetic:") == -1:
		failures.append("profile progression should build next-rank and next-cosmetic previews")
	var reward_lines := PROFILE_SERVICE_SCRIPT.build_last_run_reward_lines(next_profile, catalog)
	if "\n".join(reward_lines).find("Base run: 100 XP") == -1:
		failures.append("last run reward lines should include the deterministic XP breakdown")
	var diagnostic_lines := PROFILE_SERVICE_SCRIPT.build_last_run_diagnostic_lines(next_profile)
	var diagnostics_text := "\n".join(diagnostic_lines)
	if diagnostics_text.find("Signals:") == -1 or diagnostics_text.find("Reopen cue:") == -1:
		failures.append("last run diagnostics should summarize signal strength and reopen value compactly")
	var continue_lines := PROFILE_SERVICE_SCRIPT.build_continue_guidance_lines(next_profile, {"connected": false, "reconnect_available": false})
	if "\n".join(continue_lines).find("queue another run") == -1:
		failures.append("continue guidance should create queue-again momentum after a completed run")
	var history_focus_lines := PROFILE_SERVICE_SCRIPT.build_history_focus_lines(next_profile, "ALL", 0)
	var history_focus_text := "\n".join(history_focus_lines)
	if history_focus_text.find("Why reopen:") == -1 or history_focus_text.find("Signals:") == -1 or history_focus_text.find("Standout:") == -1:
		failures.append("history focus lines should explain why a run is worth reopening and why it stands out")
	var recent_digest := "\n".join(PROFILE_SERVICE_SCRIPT.build_recent_history_digest_lines(next_profile))
	if recent_digest.find("Latest:") == -1:
		failures.append("recent history digest should surface the latest run")
	var history_compare := "\n".join(PROFILE_SERVICE_SCRIPT.build_history_compare_lines(next_profile, "ALL", 0))
	if history_compare.find("Compare: this is the only run in the current filter.") == -1:
		failures.append("history compare lines should handle a single-run filter cleanly")

func _test_product_shell_deepening_helpers(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var validation_lines := PRODUCT_CATALOG_SCRIPT.build_validation_report_lines(catalog)
	if "\n".join(validation_lines).find("Catalog: OK") == -1:
		failures.append("product catalog validation report should summarize a clean catalog")
	var collection_entries := PROFILE_SERVICE_SCRIPT.build_collection_entries(profile, "Items", catalog)
	if collection_entries.is_empty():
		failures.append("collection entries should expose item records for the product shell")
	else:
		var first_item: Dictionary = collection_entries[0]
		if str(first_item.get("detail", "")).find("Public trace:") == -1:
			failures.append("collection detail entries should explain the item's public trace")
	var codex_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(profile, "roles", catalog)
	if codex_entries.is_empty():
		failures.append("codex entries should expose role pages for the product shell")
	else:
		var role_detail := str(Dictionary(codex_entries[0]).get("detail", ""))
		if role_detail.find("\n") == -1:
			failures.append("codex role detail should include a readable title and description")
		var codex_role_ids: Array[String] = []
		for entry_raw in codex_entries:
			codex_role_ids.append(str(Dictionary(entry_raw).get("id", "")))
		for required_role in [ROLE_SERVICE_SCRIPT.ROLE_STEWARD, ROLE_SERVICE_SCRIPT.ROLE_BEARER, ROLE_SERVICE_SCRIPT.ROLE_MURMUR]:
			if not codex_role_ids.has(required_role):
				failures.append("codex role pages should include expanded role %s" % required_role)
	var cosmetic_detail := PROFILE_SERVICE_SCRIPT.build_cosmetic_detail_lines(profile, "theme_amber_fieldnotes", catalog)
	if "\n".join(cosmetic_detail).find("Palette:") == -1:
		failures.append("cosmetic preview detail should surface notebook theme palette information")
	var help_lines := PROFILE_SERVICE_SCRIPT.build_settings_help_lines(profile)
	if "\n".join(help_lines).find("Esc / B: return to Home tab") == -1:
		failures.append("settings help lines should explain controller/back navigation")
	if "\n".join(help_lines).find("Profile flow: filter -> sort -> run list") == -1:
		failures.append("settings help lines should explain the profile browser focus rhythm")
	var voice_surface := "\n".join(PROFILE_SERVICE_SCRIPT.build_voice_surface_lines(profile, {"connected": false}))
	if voice_surface.find("Voice mode: Off.") == -1 or voice_surface.find("PTT setting:") == -1 or voice_surface.find("Lifecycle: voice policy is saved locally for the next hosted or joined lobby.") == -1:
		failures.append("voice surface lines should explain saved local voice policy clearly")
	var empty_focus := "\n".join(PROFILE_SERVICE_SCRIPT.build_history_focus_lines(profile, "ALL", 0))
	if empty_focus.find("No runs match the current filter.") == -1:
		failures.append("history focus lines should handle an empty history browser cleanly")
	var empty_compare := "\n".join(PROFILE_SERVICE_SCRIPT.build_history_compare_lines(profile, "ALL", 0))
	if empty_compare.find("Comparison: no runs in this filter.") == -1:
		failures.append("history compare lines should handle an empty history browser cleanly")

func _test_session_reliability_and_callout_helpers(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	if not manager.should_allow_runtime_join_for_test(false):
		failures.append("runtime joins should remain allowed while no run is active")
	if manager.should_allow_runtime_join_for_test(true):
		failures.append("runtime joins should be denied once a run is active")
	var reconnect_offer: Dictionary = manager.build_reconnect_offer_for_test("client", "127.0.0.1", 2456, "Host disconnected", true, true)
	if not bool(reconnect_offer.get("available", false)):
		failures.append("reconnect offers should be marked available when address and port are valid")
	if str(reconnect_offer.get("mode", "")) != "client":
		failures.append("reconnect offers should preserve the reconnect mode")
	if str(reconnect_offer.get("address", "")) != "127.0.0.1" or int(reconnect_offer.get("port", 0)) != 2456:
		failures.append("reconnect offers should preserve address and port")
	if not bool(reconnect_offer.get("run_interrupted", false)) or not bool(reconnect_offer.get("wait_for_lobby", false)):
		failures.append("reconnect offers should remember interruption and lobby wait state")
	var session_lines := "\n".join(manager.build_session_policy_lines_for_test({
		"mode": "client",
		"join_address": "127.0.0.1",
		"join_port": 2456,
		"run_active": false,
		"reconnect_wait_for_lobby": true,
		"reconnect_available": true,
		"reconnect_reason": "Run already active. Rejoin after the lobby returns."
	}))
	if session_lines.find("Mode: Joined 127.0.0.1:2456") == -1:
		failures.append("session policy lines should describe the joined target")
	if session_lines.find("Reconnect: Wait for lobby return") == -1:
		failures.append("session policy lines should prioritize lobby wait policy over ready-now reconnect text")
	if session_lines.find("Reason: Run already active.") == -1:
		failures.append("session policy lines should include the reconnect reason")
	if manager.callout_label_for_test("danger") != "Danger" or manager.callout_label_for_test("artifact") != "Artifact":
		failures.append("callout labels should stay deterministic for supported callout kinds")
	var helpers = NET_HELPERS_SCRIPT.new()
	var public_callout_meta: Dictionary = helpers.public_meta_allowlist("room_callout", {"kind": "danger", "label": "Danger", "role": "Veil"})
	if public_callout_meta.size() != 1 or str(public_callout_meta.get("kind", "")) != "danger":
		failures.append("room_callout public meta should keep only the public callout kind")
	var controller_script = load("res://src/run/game_controller.gd")
	if controller_script == null:
		failures.append("game_controller script should load for room callout helper coverage")
		manager.free()
		return
	var controller = controller_script.new()
	var event_log = EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"event_id": 1,
		"tick": 50,
		"room_slot": 6,
		"actor_peer_id": 2,
		"event_type": "room_callout",
		"visibility": "public",
		"meta": {"kind": "danger"}
	})
	var action_summary := "\n".join(controller.build_action_summary_lines_for_test(event_log, 2, 8))
	if action_summary.find("Danger callout in room 6") == -1:
		failures.append("room callouts should appear in the action summary with readable room context")
	var key_clues := "\n".join(controller.build_key_clue_lines_for_test(event_log, 8))
	if key_clues.find("A danger callout rang out in room 6") == -1:
		failures.append("room callouts should surface in the key clue summary")
	controller.free()
	event_log.free()
	manager.free()

func _test_product_shell_reconnect_history_and_voice_helpers(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var run_record := {
		"seed": 77,
		"end_reason": "host_disconnected",
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": false,
		"outcome_summary": {
			"summary_text": "Expedition stalled",
			"artifact_result_text": "No authentic artifact extracted",
			"expedition_success": false,
			"sabotage_success": true
		},
		"stats": {
			"notes_count": 1,
			"pinned_count": 0,
			"inspections_count": 0,
			"distinct_artifacts_inspected": 0,
			"extraction_started": false,
			"extraction_completed": false
		},
		"stats_lines": ["Notes: 1 (Pinned: 0)", "Inspections: 0 (Artifacts: 0)", "Extraction: -"],
		"action_summary": ["Danger callout in room 6"],
		"key_clues": ["A danger callout rang out in room 6"],
		"report_path": "user://reports/run_77_host_disconnected_2_1.txt",
		"item_defs": ["zipline_kit"],
		"room_families": ["hazard"],
		"artifact_states": ["counterfeit"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["room_callout"],
		"communication_summary": {"total": 2, "danger": 1, "regroup": 1, "artifact": 0},
		"interrupted": true,
		"interruption_reason": "Host disconnected",
		"session_wait_for_lobby": true,
		"session_reconnect_ready": true
	}
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var next_profile: Dictionary = result.get("profile", {})
	var account: Dictionary = Dictionary(next_profile.get("account", {}))
	var mastery: Dictionary = Dictionary(next_profile.get("mastery", {}))
	var scavenger_track: Dictionary = Dictionary(mastery.get(ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER, {}))
	if int(account.get("runs", 0)) != 0 or int(account.get("xp", 0)) != 0:
		failures.append("interrupted runs should not award account progression")
	if int(scavenger_track.get("runs", 0)) != 0 or int(scavenger_track.get("xp", 0)) != 0:
		failures.append("interrupted runs should not award mastery progression")
	var career_stats: Dictionary = Dictionary(next_profile.get("career_stats", {}))
	if int(career_stats.get("interrupted_runs", 0)) != 1:
		failures.append("interrupted runs should increment interrupted session tracking")
	var history_entries := PROFILE_SERVICE_SCRIPT.build_history_entries(next_profile)
	if history_entries.is_empty():
		failures.append("product shell helpers should build readable run history entries")
	else:
		var history_detail := str(Dictionary(history_entries[0]).get("detail", ""))
		if history_detail.find("S77 | Scavenger | Expedition stalled") == -1 or history_detail.find("Outcome: No authentic artifact extracted") == -1 or history_detail.find("Progression: Interrupted run | No progression") == -1:
			failures.append("run history detail should summarize identity, outcome, and interrupted progression honestly")
		if history_detail.find("Session: Wait for lobby") == -1:
			failures.append("run history detail should explain the interrupted session policy context")
		if history_detail.find("Callouts: 2") == -1:
			failures.append("run history detail should include compact callout context")
		if history_detail.find("Report: user://reports/run_77_host_disconnected_2_1.txt") == -1:
			failures.append("run history detail should retain the generated report path")
	var interrupted_entries := PROFILE_SERVICE_SCRIPT.build_history_entries(next_profile, "INTERRUPTED")
	if interrupted_entries.size() != 1:
		failures.append("history filters should surface interrupted runs deterministically")
	if PROFILE_SERVICE_SCRIPT.build_history_entries(next_profile, "SCAVENGER").size() != 1:
		failures.append("history filters should surface role-specific runs")
	if PROFILE_SERVICE_SCRIPT.build_history_entries(next_profile, "DISRUPTED").size() != 1:
		failures.append("history filters should support story-tone browsing")
	if PROFILE_SERVICE_SCRIPT.build_history_entries(next_profile, "HIGH_CALLOUTS").size() != 1:
		failures.append("history filters should support communication-heavy run browsing")
	if not PROFILE_SERVICE_SCRIPT.build_history_entries(next_profile, "REWARDING").is_empty():
		failures.append("rewarding history filters should exclude interrupted zero-reward runs")
	var reward_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_last_run_reward_lines(next_profile, catalog))
	if reward_lines.find("Interrupted run: no progression awarded.") == -1:
		failures.append("last-run reward lines should explain interrupted sessions clearly")
	var history_summary := "\n".join(PROFILE_SERVICE_SCRIPT.build_history_summary_lines(next_profile, "INTERRUPTED"))
	if history_summary.find("Runs: 1 shown / 1 logged | 1 interrupted") == -1:
		failures.append("history summary should surface interrupted run counts compactly")
	var interrupted_focus := "\n".join(PROFILE_SERVICE_SCRIPT.build_history_focus_lines(next_profile, "INTERRUPTED", 0))
	if interrupted_focus.find("Why reopen: interruption review plus lobby regroup context") == -1 or interrupted_focus.find("Standout: Best interruption review") == -1:
		failures.append("history focus should summarize why an interrupted run is worth reopening")
	var interrupted_compare := "\n".join(PROFILE_SERVICE_SCRIPT.build_history_compare_lines(next_profile, "INTERRUPTED", 0))
	if interrupted_compare.find("Compare: this is the only run in the current filter.") == -1:
		failures.append("history compare lines should stay readable for a single interrupted run")
	var continue_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_continue_guidance_lines(next_profile, {
		"join_address": "127.0.0.1",
		"join_port": 2456,
		"reconnect_wait_for_lobby": true,
		"reconnect_available": true
	}))
	if continue_lines.find("wait for the host lobby") == -1 or continue_lines.find("Why: this interrupted run can only regroup safely from lobby state.") == -1:
		failures.append("continue guidance should explain wait-for-lobby reconnect policy clearly")
	var reconnect_now_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_continue_guidance_lines(next_profile, {
		"join_address": "127.0.0.1",
		"join_port": 2456,
		"reconnect_available": true
	}))
	if reconnect_now_lines.find("127.0.0.1:2456") == -1 or reconnect_now_lines.find("Why: the session is back in a reconnect-safe state.") == -1:
		failures.append("continue guidance should surface the reconnect target when reconnect is ready")
	var settings_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_settings_lines(next_profile, catalog))
	if settings_lines.find("Voice:") == -1:
		failures.append("settings summary should include the voice mode line")
	var help_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_settings_help_lines(next_profile))
	if help_lines.find("Room callouts are public") == -1:
		failures.append("settings help should explain room callout behavior")
	var voice_surface_live := "\n".join(PROFILE_SERVICE_SCRIPT.build_voice_surface_lines(next_profile, {"connected": true}))
	if voice_surface_live.find("Lifecycle: this active lobby can carry voice policy state when transport is introduced.") == -1:
		failures.append("voice surface lines should explain the active session seam")
	var voice_toggled := PROFILE_SERVICE_SCRIPT.toggle_voice_mode(next_profile, catalog)
	if str(Dictionary(voice_toggled.get("settings", {})).get("voice_mode", "")) != "push_to_talk":
		failures.append("voice mode should deterministically cycle from off to push_to_talk")

func _test_between_runs_productization_browser_and_cta_helpers(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var run_a := {
		"seed": 401,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_WARDEN,
		"summary_text": "Steady recovery",
		"artifact_result_text": "Authentic artifact extracted",
		"role_result_success": true,
		"xp_gain": 120,
		"mastery_gain": 20,
		"report_path": "user://reports/run_401_extraction_objective_1_1.txt",
		"interrupted": false,
		"interruption_reason": "",
		"key_clues": ["A danger callout rang out in room 3"],
		"action_summary": ["Danger callout in room 3"],
		"diagnostics": {
			"story_density": 4,
			"story_tone": "Quiet",
			"communication_beats": 1,
			"danger_callouts": 1,
			"regroup_callouts": 0,
			"artifact_callouts": 0,
			"pressure_beats": 1,
			"artifact_beats": 1,
			"route_commits": 0,
			"clue_beats": 1,
			"suspicion_beats": 1,
			"interrupted": false,
			"wait_for_lobby": false,
			"reconnect_ready": false
		}
	}
	var run_b := {
		"seed": 402,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_VEIL,
		"summary_text": "Chaotic detour",
		"artifact_result_text": "Counterfeit extraction succeeded",
		"role_result_success": true,
		"xp_gain": 140,
		"mastery_gain": 25,
		"report_path": "user://reports/run_402_counterfeit_1_1.txt",
		"interrupted": false,
		"interruption_reason": "",
		"key_clues": ["A zipline rerouted the team through room 6", "A trap pulse echoed through room 7"],
		"action_summary": ["Zipline changed the route", "Trap timing split the team"],
		"diagnostics": {
			"story_density": 11,
			"story_tone": "Chaotic",
			"communication_beats": 2,
			"danger_callouts": 1,
			"regroup_callouts": 1,
			"artifact_callouts": 0,
			"pressure_beats": 3,
			"artifact_beats": 1,
			"route_commits": 2,
			"clue_beats": 2,
			"suspicion_beats": 5,
			"interrupted": false,
			"wait_for_lobby": false,
			"reconnect_ready": false
		}
	}
	var run_c := {
		"seed": 403,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"summary_text": "Rewarding extraction",
		"artifact_result_text": "Authentic artifact extracted",
		"role_result_success": true,
		"xp_gain": 220,
		"mastery_gain": 40,
		"report_path": "user://reports/run_403_extraction_objective_1_1.txt",
		"interrupted": false,
		"interruption_reason": "",
		"key_clues": ["Artifact carried cleanly through Extraction"],
		"action_summary": ["Extraction completed under pressure"],
		"diagnostics": {
			"story_density": 8,
			"story_tone": "Charged",
			"communication_beats": 1,
			"danger_callouts": 0,
			"regroup_callouts": 1,
			"artifact_callouts": 0,
			"pressure_beats": 2,
			"artifact_beats": 2,
			"route_commits": 1,
			"clue_beats": 1,
			"suspicion_beats": 3,
			"interrupted": false,
			"wait_for_lobby": false,
			"reconnect_ready": false
		}
	}
	var run_d := {
		"seed": 404,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_WARDEN,
		"summary_text": "Interrupted collapse",
		"artifact_result_text": "No authentic artifact extracted",
		"role_result_success": false,
		"xp_gain": 0,
		"mastery_gain": 0,
		"report_path": "user://reports/run_404_interrupted_1_1.txt",
		"interrupted": true,
		"interruption_reason": "Host disconnected",
		"key_clues": ["A regroup callout rang out in room 8"],
		"action_summary": ["Danger callout in room 8", "Regroup callout in room 8"],
		"diagnostics": {
			"story_density": 9,
			"story_tone": "Disrupted",
			"communication_beats": 4,
			"danger_callouts": 2,
			"regroup_callouts": 2,
			"artifact_callouts": 0,
			"pressure_beats": 1,
			"artifact_beats": 0,
			"route_commits": 0,
			"clue_beats": 1,
			"suspicion_beats": 2,
			"interrupted": true,
			"wait_for_lobby": true,
			"reconnect_ready": true
		}
	}
	profile["run_history"] = [run_a, run_b, run_c, run_d]
	profile["last_run"] = run_d
	var sort_modes := PROFILE_SERVICE_SCRIPT.history_sort_modes()
	if not sort_modes.has("DRAMATIC") or not sort_modes.has("INTERRUPTED_FIRST"):
		failures.append("history sort modes should expose dramatic and interrupted-first browsing")
	var recent_digest_lines := PROFILE_SERVICE_SCRIPT.build_recent_history_digest_lines(profile)
	var recent_digest := "\n".join(recent_digest_lines)
	if recent_digest.find("Latest: Seed 401") == -1 or recent_digest.find("Most dramatic: Seed 402") == -1 or recent_digest.find("Most rewarding: Seed 403") == -1 or recent_digest.find("Best interruption review: Seed 404") == -1:
		failures.append("recent history digest should curate distinct recent run slots deterministically")
	var home_recent_lines := PROFILE_SERVICE_SCRIPT.build_home_recent_run_lines(profile)
	if home_recent_lines.size() != 3 or "\n".join(home_recent_lines).find("Best interruption review: Seed 404") != -1:
		failures.append("home recent-run helpers should stay capped and omit the fourth slot when density is tight")
	var cluster_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_recent_run_cluster_lines(profile))
	if cluster_lines.find("Most dramatic:") == -1 or cluster_lines.find("Best interruption review:") == -1:
		failures.append("recent run cluster helpers should expose standout slots for future tuning surfaces")
	var selected_key := "user://reports/run_404_interrupted_1_1.txt"
	var browser_state := PROFILE_SERVICE_SCRIPT.build_history_browser_state(profile, "ALL", "DRAMATIC", selected_key, 0)
	if str(browser_state.get("selected_key", "")) != selected_key:
		failures.append("history browser state should preserve the selected run when it stays in the active set")
	var rewarding_state := PROFILE_SERVICE_SCRIPT.build_history_browser_state(profile, "REWARDING", "RECENT", selected_key, 0)
	if str(rewarding_state.get("selected_key", "")) != "user://reports/run_403_extraction_objective_1_1.txt":
		failures.append("history browser state should fall back deterministically when the selected run leaves the active filter")
	var compare_lines := "\n".join(Array(browser_state.get("compare_lines", [])))
	if compare_lines.find("Contrast: interrupted instead of completed versus S403.") == -1 or compare_lines.find("Why reopen: its callout density is heavier in this view.") == -1:
		failures.append("history compare lines should stay contrast-driven, brief, and decision-useful")
	var compare_digest := "\n".join(PROFILE_SERVICE_SCRIPT.build_history_compare_digest_lines(profile, "ALL", 0, "DRAMATIC", selected_key))
	if compare_digest.find("interrupted instead of completed versus S403") == -1 or compare_digest.find("its callout density is heavier in this view") == -1 or compare_digest.find("Dimension: interruption") == -1:
		failures.append("history compare digest helpers should reuse the same deterministic compare packet")
	var interruption_patterns := "\n".join(PROFILE_SERVICE_SCRIPT.build_interruption_pattern_lines(profile))
	if interruption_patterns.find("Interrupted: 1 / 4") == -1:
		failures.append("interruption pattern helpers should summarize interrupted recent runs deterministically")
	var run_memory_tuning := "\n".join(PROFILE_SERVICE_SCRIPT.build_run_memory_tuning_lines(profile, "ALL", "DRAMATIC"))
	if run_memory_tuning.find("Standout cluster:") == -1 or run_memory_tuning.find("Strongest cluster:") == -1 or run_memory_tuning.find("Revisit cluster:") == -1 or run_memory_tuning.find("Compare digest:") == -1 or run_memory_tuning.find("Interruption recovery:") == -1:
		failures.append("run memory tuning helpers should expose compact standout, revisit, and compare diagnostics")
	var connected_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_continue_guidance_lines(profile, {"connected": true}))
	if connected_lines.find("Next: ready up and start another run.") == -1 or connected_lines.find("Why:") == -1 or connected_lines.find("Also:") == -1:
		failures.append("continue guidance should expose a dominant CTA with supporting reason and secondary route while connected")
	var first_run_profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var first_run_lines := "\n".join(PROFILE_SERVICE_SCRIPT.build_continue_guidance_lines(first_run_profile, {}))
	if first_run_lines.find("Next: host a room or join a session.") == -1:
		failures.append("continue guidance should prioritize host/join actions for first-run players")
	var home_overview := "\n".join(PROFILE_SERVICE_SCRIPT.build_home_overview_lines(profile, {"connected": true}, catalog))
	if home_overview.find("Rank 1 | 0 runs logged") == -1 or home_overview.find("Continuity: continue with the current lobby") == -1:
		failures.append("home overview helpers should summarize progression momentum and party continuity compactly")
	var home_diagnostics := PROFILE_SERVICE_SCRIPT.build_last_run_diagnostic_lines(profile)
	if home_diagnostics.size() > 2 or "\n".join(home_diagnostics).find("Signals:") == -1 or "\n".join(home_diagnostics).find("Recovery: Wait for lobby") == -1:
		failures.append("home diagnostic helpers should stay compact and keep interruption recovery visible")

func _test_master_narrative_v3_interpretive_stack(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var dense_run := {
		"seed": 13371337,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"interruption_reason": "",
		"session_wait_for_lobby": false,
		"session_reconnect_ready": false,
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 2, "actor_peer_id": 2, "event_type": "room_callout", "visibility": "public", "meta": {"kind": "regroup"}},
			{"event_id": 2, "tick": 20, "room_slot": 2, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 21, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 4, "tick": 25, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "zipline_kit"}},
			{"event_id": 5, "tick": 31, "room_slot": 3, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
			{"event_id": 6, "tick": 34, "room_slot": 3, "actor_peer_id": 2, "event_type": "room_callout", "visibility": "public", "meta": {"kind": "danger"}},
			{"event_id": 7, "tick": 40, "room_slot": 3, "actor_peer_id": -1, "event_type": "bomb_exploded", "visibility": "public", "meta": {}},
			{"event_id": 8, "tick": 44, "room_slot": 3, "actor_peer_id": -1, "event_type": "noise_trace", "visibility": "public", "meta": {}},
			{"event_id": 9, "tick": 52, "room_slot": 4, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
			{"event_id": 10, "tick": 66, "room_slot": 7, "actor_peer_id": -1, "event_type": "extraction_window_started", "visibility": "public", "meta": {}},
			{"event_id": 11, "tick": 74, "room_slot": 7, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"timeline_private_events": [],
		"room_chain_summary": [
			{"slot": 2, "type": "evidence", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": {"challenge_texture": "high ceremony", "confrontation_climate": "precarious", "rescue_climate": "communal", "pressure_profile": "watcher_pressure"}},
			{"slot": 3, "type": "hazard", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": {"challenge_texture": "high ceremony", "confrontation_climate": "precarious", "rescue_climate": "communal", "pressure_profile": "watcher_pressure"}},
			{"slot": 4, "type": "traversal", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": {"challenge_texture": "high ceremony", "confrontation_climate": "precarious", "rescue_climate": "communal", "pressure_profile": "watcher_pressure"}},
			{"slot": 7, "type": "traversal", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": {"challenge_texture": "high ceremony", "confrontation_climate": "precarious", "rescue_climate": "communal", "pressure_profile": "watcher_pressure"}}
		],
		"branch_context_summary": {
			"branch_family_id": "grave_lattice",
			"branch_family_name": "Grave Lattice",
			"challenge_texture": "high ceremony",
			"confrontation_climate": "precarious",
			"rescue_climate": "communal",
			"route_commitment": "severe",
			"symbolic_anchor": "echo gate"
		},
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {
				"delver_A": {"threshold_hesitations": 2, "lingers": 2, "returns": 1},
				"delver_B": {"threshold_hesitations": 1, "lingers": 1, "returns": 2}
			},
			"pair_summaries": {
				"delver_A:delver_B": {"proximity": 4, "following": 2, "separation": 1, "shared_carry_pressure": 2}
			},
			"room_summaries": {
				"room:2": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 1},
				"room:3": {"threshold_waits": 1, "collective_hesitations": 2, "returns": 1, "lingers": 1, "burden_pressure": 1}
			},
			"strong_rooms": {"threshold_hesitation": 3, "collective_hesitations": 2, "returns": 2, "lingers": 2, "burden_pressure": 2},
			"strong_room_list": [],
			"echo_tags": ["threshold attention"]
		},
		"stats": {
			"notes_count": 2,
			"pinned_count": 1,
			"inspections_count": 1,
			"distinct_artifacts_inspected": 1,
			"extraction_started": true,
			"extraction_completed": true
		},
		"stats_lines": ["Notes: 2 (Pinned: 1)", "Inspections: 1 (Artifacts: 1)", "Extraction: complete"],
		"action_summary": ["Burden handoff under pressure", "Route commitment drew attention", "Extraction completed under heat"],
		"key_clues": ["A regroup callout rang out in room 2", "A zipline committed the route", "The artifact line turned volatile in room 3"],
		"report_path": "user://reports/run_13371337_story.txt",
		"item_defs": ["zipline_kit", "decoy_emitter", "timeline_bookmark", "lantern_snuffer"],
		"room_families": ["evidence", "hazard", "traversal"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["room_callout", "placed_zipline"],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 2, "artifact": 1},
		"outcome_summary": {
			"summary_text": "Heavy run held together",
			"artifact_result_text": "Authentic artifact extracted",
			"artifact_result": "authentic",
			"expedition_success": true,
			"sabotage_success": false
		}
	}
	var diagnostics_a := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(dense_run)
	var diagnostics_b := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(dense_run)
	if JSON.stringify(diagnostics_a) != JSON.stringify(diagnostics_b):
		failures.append("master narrative diagnostics should remain deterministic for the same run facts")
	if not Array(diagnostics_a.get("symbolic_gestures", [])).has("deliberate drop") or not Array(diagnostics_a.get("symbolic_gestures", [])).has("burden handoff") or not Array(diagnostics_a.get("symbolic_gestures", [])).has("threshold commitment"):
		failures.append("symbolic gesture detection should recognize deliberate drops, burden handoffs, and threshold commitments under pressure")
	if Array(diagnostics_a.get("run_changing_moments", [])).size() > 3 or Array(diagnostics_a.get("quest_pressure", [])).size() > 4:
		failures.append("narrative saturation limits should cap changing moments and quest pressure to the strongest coherent cluster")
	if str(diagnostics_a.get("momentum_profile", "")).is_empty() or str(diagnostics_a.get("social_temperature", "")).is_empty() or str(diagnostics_a.get("atmosphere", "")).is_empty():
		failures.append("diagnostics should derive momentum, social temperature, and atmosphere from dense run signals")
	if str(diagnostics_a.get("escalation_arc", "")).is_empty() or Array(diagnostics_a.get("spectacle_windows", [])).is_empty():
		failures.append("dense runs should derive a readable escalation arc and spectacle windows from reinforced facts")
	if Array(diagnostics_a.get("room_identity_highlights", [])).is_empty() or Array(diagnostics_a.get("load_bearing_places", [])).is_empty() or Array(diagnostics_a.get("load_bearing_objects", [])).is_empty():
		failures.append("dense runs should surface room identity and load-bearing place/object overlays")
	if Array(diagnostics_a.get("anticipation_hooks", [])).is_empty() or Array(diagnostics_a.get("choice_frames", [])).is_empty():
		failures.append("dense runs should build anticipation hooks and pre-outcome choice framing")
	if str(diagnostics_a.get("branch_summary", "")).is_empty() or str(Dictionary(diagnostics_a.get("branch_summary", {})).get("branch_family_id", "")) != "grave_lattice":
		failures.append("dense runs should preserve deterministic branch context through diagnostics")

	var frame := FRAMING_SERVICE_SCRIPT.build_run_frame(dense_run, diagnostics_a, profile)
	var archive_state := ARCHIVE_SERVICE_SCRIPT.apply_run({}, {
		"run_record": dense_run,
		"diagnostics": diagnostics_a,
		"frame": frame,
		"crawl_packet": {"crawl_id": "crawl_001", "title": "Dense crawl"},
		"world_memory": WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	})
	if Array(Dictionary(archive_state).get("cases", [])).is_empty() or Array(Dictionary(archive_state).get("legends", [])).is_empty():
		failures.append("legend density threshold should promote only reinforced high-compression runs into archive legends")
	if Dictionary(Dictionary(archive_state).get("shorthand", {})).is_empty():
		failures.append("archive legend promotion should unlock shorthand readiness for dense memorable cases")

	var low_run := {
		"seed": 9,
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_WARDEN,
		"interrupted": false,
		"timeline_public_events": [{"event_id": 1, "tick": 10, "room_slot": 1, "actor_peer_id": 2, "event_type": "room_callout", "visibility": "public", "meta": {"kind": "danger"}}],
		"timeline_private_events": [],
		"room_chain_summary": [{"slot": 1, "type": "traversal"}],
		"stats": {"notes_count": 0, "pinned_count": 0, "inspections_count": 0, "extraction_started": false, "extraction_completed": false},
		"stats_lines": [],
		"action_summary": ["A warning went out"],
		"key_clues": ["A warning went out"],
		"report_path": "user://reports/run_9_low.txt",
		"item_defs": ["zipline_kit"],
		"room_families": ["traversal"],
		"artifact_states": [],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_WARDEN],
		"clue_families": ["room_callout"],
		"communication_summary": {"total": 1, "danger": 1, "regroup": 0, "artifact": 0},
		"outcome_summary": {"summary_text": "Quiet warning", "artifact_result_text": "-", "artifact_result": "", "expedition_success": false, "sabotage_success": false}
	}
	var low_diag := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(low_run)
	var low_frame := FRAMING_SERVICE_SCRIPT.build_run_frame(low_run, low_diag, profile)
	var low_archive := ARCHIVE_SERVICE_SCRIPT.apply_run({}, {
		"run_record": low_run,
		"diagnostics": low_diag,
		"frame": low_frame,
		"crawl_packet": {"crawl_id": "crawl_002", "title": "Quiet crawl"}
	})
	if not Array(Dictionary(low_archive).get("legends", [])).is_empty():
		failures.append("legend density threshold should block low-density runs from archive legend promotion")

	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(world_memory, {
		"run_record": dense_run,
		"diagnostics": diagnostics_a,
		"frame": frame,
		"crawl_packet": {"crawl_id": "crawl_001", "title": "Dense crawl"}
	})
	for _i in range(4):
		world_memory = WORLD_MEMORY_SERVICE_SCRIPT.apply_run(world_memory, {
			"run_record": low_run,
			"diagnostics": low_diag,
			"frame": low_frame,
			"crawl_packet": {"crawl_id": "crawl_002", "title": "Quiet crawl"}
		})
	var item_myths: Dictionary = Dictionary(Dictionary(world_memory.get("myths", {})).get("item", {}))
	var dense_item: Dictionary = Dictionary(item_myths.get("item:timeline_bookmark", item_myths.get("item:zipline_kit", {})))
	if dense_item.is_empty() or str(dense_item.get("status", "")) == "active":
		failures.append("myth cooling should reduce inactive myth heat from active toward residual or relic state")
	if str(Dictionary(world_memory.get("fascination", {})).get("phase", "")).is_empty():
		failures.append("world fascination should track a readable cultural phase")

	var applied := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, dense_run, catalog)
	var next_profile: Dictionary = Dictionary(applied.get("profile", {}))
	var active_crawl: Dictionary = Dictionary(next_profile.get("active_crawl", {}))
	if active_crawl.is_empty() or int(active_crawl.get("risk_stake", 0)) <= 0 or int(active_crawl.get("bank_pressure", 0)) <= 0:
		failures.append("crawl continuity should absorb stake and bank-vs-push pressure from dense runs")
	var codex_sections := PROFILE_SERVICE_SCRIPT.build_codex_sections(next_profile, catalog)
	for required in ["archive_cases", "crawl_echoes", "relationship_echoes", "world_fascination"]:
		if not codex_sections.has(required):
			failures.append("archive-aware codex sections should expose %s through the existing shell path" % required)
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(next_profile, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("archive cases should surface through the existing codex shell without a parallel archive path")
	var safe_text := "\n".join(
		PROFILE_SERVICE_SCRIPT.build_home_overview_lines(next_profile, {}, catalog)
		+ PROFILE_SERVICE_SCRIPT.build_last_run_lines(next_profile)
		+ PROFILE_SERVICE_SCRIPT.build_last_run_diagnostic_lines(next_profile)
		+ PROFILE_SERVICE_SCRIPT.build_codex_lines(next_profile, catalog)
	)
	for banned in ["experiment", "behavioral system", "observer", "planetary-scale"]:
		if safe_text.to_lower().find(banned) != -1:
			failures.append("player-facing narrative output should stay Layer-1-safe and avoid hidden-truth wording")

func _test_master_narrative_v3_branch_context_and_crawl_memory(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var chain := generator.generate_layout(424242, 10)
	if chain.is_empty():
		failures.append("branch-context generation should still produce a deterministic room chain")
		return
	var first_room: Dictionary = Dictionary(chain[0])
	var branch_context: Dictionary = Dictionary(first_room.get("branch_context", {}))
	if branch_context.is_empty() or str(first_room.get("branch_family_id", "")).is_empty():
		failures.append("generated rooms should carry deterministic branch-family context for V3 memory binding")
	if str(branch_context.get("challenge_texture", "")).is_empty() or str(branch_context.get("pressure_profile", "")).is_empty():
		failures.append("branch-family context should expose authored challenge and pressure texture")
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var base_run := {
		"seed": 101,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"timeline_public_events": [{"event_id": 1, "tick": 10, "room_slot": 1, "actor_peer_id": 2, "event_type": "room_callout", "visibility": "public", "meta": {"kind": "regroup"}}],
		"timeline_private_events": [],
		"room_chain_summary": [{"slot": 1, "type": "traversal", "branch_family_id": str(first_room.get("branch_family_id", "")), "branch_family_name": str(first_room.get("branch_family_name", "")), "branch_context": branch_context}],
		"branch_context_summary": branch_context,
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {},
			"pair_summaries": {"delver_A:delver_B": {"proximity": 3, "following": 2, "shared_carry_pressure": 1}},
			"room_summaries": {"room:1": {"threshold_waits": 1, "collective_hesitations": 0, "returns": 0, "lingers": 1, "burden_pressure": 1}},
			"strong_rooms": {"threshold_hesitation": 1, "collective_hesitations": 0, "returns": 0, "lingers": 1, "burden_pressure": 1},
			"strong_room_list": [],
			"echo_tags": []
		},
		"stats": {"notes_count": 0, "pinned_count": 0, "inspections_count": 0, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["Quiet carry"],
		"key_clues": ["The crawl kept its shape"],
		"report_path": "user://reports/run_101.txt",
		"item_defs": ["zipline_kit"],
		"room_families": [str(first_room.get("type", "traversal"))],
		"artifact_states": [],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["room_callout"],
		"communication_summary": {"total": 1, "danger": 0, "regroup": 1, "artifact": 0},
		"outcome_summary": {"summary_text": "Steady", "artifact_result_text": "-", "artifact_result": "", "expedition_success": true, "sabotage_success": false}
	}
	var first_apply := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, base_run, catalog)
	var after_first: Dictionary = Dictionary(first_apply.get("profile", {}))
	var second_run: Dictionary = base_run.duplicate(true)
	second_run["seed"] = 102
	second_run["action_summary"] = ["Return under pressure"]
	second_run["timeline_public_events"] = [
		{"event_id": 1, "tick": 10, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
		{"event_id": 2, "tick": 12, "room_slot": 1, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}}
	]
	second_run["communication_summary"] = {"total": 2, "danger": 0, "regroup": 1, "artifact": 1}
	var second_apply := PROFILE_SERVICE_SCRIPT.apply_run_record(after_first, second_run, catalog)
	var after_second: Dictionary = Dictionary(second_apply.get("profile", {}))
	var relationships: Dictionary = Dictionary(after_second.get("relationship_fabric", {}))
	if Dictionary(relationships.get("players", {})).is_empty() or Dictionary(relationships.get("pairs", {})).is_empty() or Dictionary(relationships.get("crews", {})).is_empty():
		failures.append("stable player, pair, and crew continuity should persist through profile relationship fabric")

func _test_master_narrative_v3_longform_continuity_and_lobby(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var branch_context := {
		"branch_family_id": "sundered_span",
		"branch_family_name": "Sundered Span",
		"challenge_texture": "exposed crossings",
		"confrontation_climate": "knife-edge",
		"rescue_climate": "public",
		"route_commitment": "severe",
		"symbolic_anchor": "hanging gate"
	}
	var base_run := {
		"seed": 2201,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 1, "actor_peer_id": 2, "event_type": "room_callout", "visibility": "public", "meta": {"kind": "regroup"}},
			{"event_id": 2, "tick": 18, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 19, "room_slot": 1, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 4, "tick": 26, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
			{"event_id": 5, "tick": 34, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}},
			{"event_id": 6, "tick": 44, "room_slot": 3, "actor_peer_id": -1, "event_type": "extraction_window_started", "visibility": "public", "meta": {}},
			{"event_id": 7, "tick": 55, "room_slot": 3, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"timeline_private_events": [],
		"room_chain_summary": [
			{"slot": 1, "type": "traversal", "branch_family_id": "sundered_span", "branch_family_name": "Sundered Span", "branch_context": branch_context},
			{"slot": 2, "type": "hazard", "branch_family_id": "sundered_span", "branch_family_name": "Sundered Span", "branch_context": branch_context},
			{"slot": 3, "type": "traversal", "branch_family_id": "sundered_span", "branch_family_name": "Sundered Span", "branch_context": branch_context}
		],
		"branch_context_summary": branch_context,
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Caro"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {
				"delver_A": {"threshold_hesitations": 2, "lingers": 1, "returns": 1},
				"delver_B": {"threshold_hesitations": 1, "lingers": 1, "returns": 2},
				"delver_C": {"threshold_hesitations": 1, "lingers": 0, "returns": 1}
			},
			"pair_summaries": {
				"delver_A:delver_B": {"proximity": 4, "following": 2, "separation": 1, "shared_carry_pressure": 2},
				"delver_A:delver_C": {"proximity": 2, "following": 1, "separation": 2, "shared_carry_pressure": 0}
			},
			"room_summaries": {
				"room:1": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 1},
				"room:2": {"threshold_waits": 1, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 2}
			},
			"strong_rooms": {"threshold_hesitation": 2, "collective_hesitations": 1, "returns": 1, "lingers": 2, "burden_pressure": 2},
			"strong_room_list": [],
			"echo_tags": ["threshold attention", "carry watch"]
		},
		"stats": {"notes_count": 1, "pinned_count": 0, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["Shared carry pressure", "The branch kept the crew exposed"],
		"key_clues": ["Aster and Bram kept sharing the burden line"],
		"report_path": "user://reports/v3_longform_2201.txt",
		"item_defs": ["lantern_snuffer", "zipline_kit"],
		"room_families": ["traversal", "hazard"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["room_callout", "artifact_handoff"],
		"communication_summary": {"total": 3, "danger": 1, "regroup": 1, "artifact": 1},
		"outcome_summary": {"summary_text": "Held together under exposure", "artifact_result_text": "Authentic artifact extracted", "artifact_result": "authentic", "expedition_success": true, "sabotage_success": false}
	}
	var second_run: Dictionary = base_run.duplicate(true)
	second_run["seed"] = 2202
	second_run["action_summary"] = ["The same pair took the burden again", "The crew nearly fractured and recovered"]
	second_run["timeline_public_events"] = [
		{"event_id": 1, "tick": 11, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
		{"event_id": 2, "tick": 12, "room_slot": 1, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
		{"event_id": 3, "tick": 24, "room_slot": 2, "actor_peer_id": 4, "event_type": "room_callout", "visibility": "public", "meta": {"kind": "danger"}},
		{"event_id": 4, "tick": 39, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "zipline_kit"}},
		{"event_id": 5, "tick": 55, "room_slot": 3, "actor_peer_id": 3, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
	]
	second_run["communication_summary"] = {"total": 4, "danger": 2, "regroup": 1, "artifact": 1}
	second_run["narrative_motion_facts"]["pair_summaries"]["delver_A:delver_B"]["shared_carry_pressure"] = 3
	second_run["narrative_motion_facts"]["room_summaries"]["room:2"]["collective_hesitations"] = 2
	var third_run: Dictionary = second_run.duplicate(true)
	third_run["seed"] = 2203
	third_run["interrupted"] = true
	third_run["end_reason"] = "interrupted"
	third_run["timeline_public_events"] = [
		{"event_id": 1, "tick": 10, "room_slot": 1, "actor_peer_id": 2, "event_type": "room_callout", "visibility": "public", "meta": {"kind": "danger"}},
		{"event_id": 2, "tick": 18, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
		{"event_id": 3, "tick": 21, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}}
	]
	third_run["communication_summary"] = {"total": 3, "danger": 2, "regroup": 0, "artifact": 1}
	third_run["outcome_summary"] = {"summary_text": "Interrupted under pressure", "artifact_result_text": "-", "artifact_result": "", "expedition_success": false, "sabotage_success": false}
	var applied_first := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, base_run, catalog)
	var applied_second := PROFILE_SERVICE_SCRIPT.apply_run_record(Dictionary(applied_first.get("profile", {})), second_run, catalog)
	var applied_third := PROFILE_SERVICE_SCRIPT.apply_run_record(Dictionary(applied_second.get("profile", {})), third_run, catalog)
	var next_profile: Dictionary = Dictionary(applied_third.get("profile", {}))
	var target_crawl: Dictionary = Dictionary(next_profile.get("active_crawl", {}))
	if target_crawl.is_empty():
		var crawl_history := Array(next_profile.get("crawl_history", []))
		if not crawl_history.is_empty():
			target_crawl = Dictionary(crawl_history[0])
	if target_crawl.is_empty() or str(target_crawl.get("expectation_pressure", "")).strip_edges().is_empty():
		failures.append("multi-run crawls should carry expectation pressure forward across repeated loaded runs")
	if Array(target_crawl.get("obligation_residue", [])).is_empty() or Array(target_crawl.get("memorial_residue", [])).is_empty():
		failures.append("crawl continuity should preserve obligation and memorial residue from repeated or broken saga beats")
	var fabric: Dictionary = Dictionary(next_profile.get("relationship_fabric", {}))
	var players: Dictionary = Dictionary(fabric.get("players", {}))
	var pairs: Dictionary = Dictionary(fabric.get("pairs", {}))
	var crews: Dictionary = Dictionary(fabric.get("crews", {}))
	if Dictionary(players.get("delver_A", {})).is_empty() or int(Dictionary(players.get("delver_A", {})).get("history_count", 0)) < 2:
		failures.append("stable player continuity should retain repeat pressure history by public id")
	if Dictionary(pairs.get("delver_A:delver_B", {})).is_empty() or int(Dictionary(pairs.get("delver_A:delver_B", {})).get("history_count", 0)) < 2:
		failures.append("stable pair continuity should retain repeated pair history using stable ids")
	if crews.is_empty():
		failures.append("crew continuity should persist repeated crew history through the same owner path")
	var ready_state := {2: true, 3: false, 4: true}
	var public_cards := {
		"2": {"display_name": "Aster", "public_id": "delver_A", "legend_hint": "Rescuer under pressure"},
		"3": {"display_name": "Bram", "public_id": "delver_B"},
		"4": {"display_name": "Caro", "public_id": "delver_C"}
	}
	var roster_lines := PROFILE_SERVICE_SCRIPT.build_lobby_roster_lines(next_profile, ready_state, public_cards, 2)
	var roster_text := "\n".join(roster_lines)
	if roster_text.find("Aster") == -1 or roster_text.find("Bram") == -1:
		failures.append("lobby continuity should surface stable public names through the existing roster path")
	if roster_text.find("Recurring") == -1 and roster_text.find("Rescue") == -1 and roster_text.find("pressure") == -1:
		failures.append("lobby continuity should surface remembered challenge or relationship context instead of only ready state")
	var history_state := PROFILE_SERVICE_SCRIPT.build_history_browser_state(next_profile)
	if Array(history_state.get("compare_lines", [])).is_empty():
		failures.append("history browser should remain wired through the existing shell path after longform continuity updates")

func _test_master_narrative_v3_archive_world_memory_and_progression(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var branch_context := {
		"branch_family_id": "grave_lattice",
		"branch_family_name": "Grave Lattice",
		"challenge_texture": "high ceremony",
		"confrontation_climate": "precarious",
		"rescue_climate": "communal",
		"route_commitment": "severe",
		"symbolic_anchor": "echo gate"
	}
	var dense_run := {
		"seed": 3301,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 2, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 11, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 18, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
			{"event_id": 4, "tick": 31, "room_slot": 3, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
			{"event_id": 5, "tick": 36, "room_slot": 3, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}},
			{"event_id": 6, "tick": 52, "room_slot": 4, "actor_peer_id": -1, "event_type": "extraction_window_started", "visibility": "public", "meta": {}},
			{"event_id": 7, "tick": 60, "room_slot": 4, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"timeline_private_events": [],
		"room_chain_summary": [
			{"slot": 2, "type": "evidence", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 3, "type": "hazard", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 4, "type": "traversal", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context}
		],
		"branch_context_summary": branch_context,
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {
				"delver_A": {"threshold_hesitations": 2, "lingers": 2, "returns": 2},
				"delver_B": {"threshold_hesitations": 1, "lingers": 1, "returns": 1}
			},
			"pair_summaries": {
				"delver_A:delver_B": {"proximity": 4, "following": 2, "separation": 1, "shared_carry_pressure": 2}
			},
			"room_summaries": {
				"room:2": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 1},
				"room:3": {"threshold_waits": 1, "collective_hesitations": 2, "returns": 1, "lingers": 1, "burden_pressure": 1}
			},
			"strong_rooms": {"threshold_hesitation": 3, "collective_hesitations": 2, "returns": 2, "lingers": 2, "burden_pressure": 2},
			"strong_room_list": [],
			"echo_tags": ["threshold attention", "ritual return"]
		},
		"stats": {"notes_count": 2, "pinned_count": 1, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["Charged carry", "The branch kept repeating itself"],
		"key_clues": ["The same burden pattern kept returning"],
		"report_path": "user://reports/v3_archive_3301.txt",
		"item_defs": ["timeline_bookmark", "lantern_snuffer", "zipline_kit"],
		"room_families": ["evidence", "hazard", "traversal"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_handoff", "room_callout"],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 1, "artifact": 1},
		"outcome_summary": {"summary_text": "Charged extraction", "artifact_result_text": "Authentic artifact extracted", "artifact_result": "authentic", "expedition_success": true, "sabotage_success": false}
	}
	var applied := profile
	for seed in [3301, 3302, 3303, 3304]:
		var run_record: Dictionary = dense_run.duplicate(true)
		run_record["seed"] = seed
		run_record["report_path"] = "user://reports/v3_archive_%d.txt" % seed
		applied = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(applied, run_record, catalog).get("profile", {}))
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("archive should expose comparative cases through the existing codex path")
	else:
		var archive_text := str(Dictionary(archive_entries[0]).get("detail", ""))
		if archive_text.find("Compare:") == -1 and archive_text.find("Prior echo:") == -1:
			failures.append("archive cases should compare current runs against earlier echoes or myth layers")
		if archive_text.find("Watch next:") == -1:
			failures.append("archive cases should preserve a clear what-to-watch-next lure")
	var world_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "world_fascination", catalog)
	var world_text := ""
	for entry in world_entries:
		world_text += str(Dictionary(entry).get("label", "")) + "\n" + str(Dictionary(entry).get("detail", "")) + "\n"
	if world_text.find("Delver |") == -1 or world_text.find("Crawl |") == -1:
		failures.append("world-fascination archive entries should include player and crawl myth layers, not only branch and item heat")
	var progress_lines := PROFILE_SERVICE_SCRIPT.build_progression_preview_lines(applied, catalog)
	var progress_text := "\n".join(progress_lines)
	if progress_text.find("Archive depth:") == -1:
		failures.append("narrative progression should surface meaningful archive-depth continuity through the existing shell path")
	var progress_state: Dictionary = Dictionary(applied.get("narrative_progress", {}))
	if str(progress_state.get("layer", "public")) == "public":
		failures.append("repeated dense runs should advance narrative progression beyond the base public layer")
	var world_memory: Dictionary = Dictionary(applied.get("world_memory", {}))
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	if Array(fascination.get("focus_history", [])).is_empty() or str(fascination.get("phase", "")).is_empty():
		failures.append("world fascination should retain focus history and phase as myths accumulate")
	var guarded := FRAMING_SERVICE_SCRIPT.guard_text("observer experiment behavioral system")
	for banned in ["observer", "experiment", "behavioral system"]:
		if guarded.to_lower().find(banned) != -1:
			failures.append("centralized wording safety should scrub hidden-truth language from guarded text")

func _test_master_narrative_v3_finalization_depth(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var branch_context := {
		"branch_family_id": "grave_lattice",
		"branch_family_name": "Grave Lattice",
		"challenge_texture": "high ceremony",
		"confrontation_climate": "precarious",
		"rescue_climate": "communal",
		"route_commitment": "severe",
		"symbolic_anchor": "echo gate"
	}
	var dense_run := {
		"seed": 4401,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 2, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 11, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 18, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
			{"event_id": 4, "tick": 31, "room_slot": 3, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
			{"event_id": 5, "tick": 36, "room_slot": 3, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}},
			{"event_id": 6, "tick": 52, "room_slot": 4, "actor_peer_id": -1, "event_type": "extraction_window_started", "visibility": "public", "meta": {}},
			{"event_id": 7, "tick": 60, "room_slot": 4, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"timeline_private_events": [],
		"room_chain_summary": [
			{"slot": 2, "type": "evidence", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 3, "type": "hazard", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 4, "type": "traversal", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context}
		],
		"branch_context_summary": branch_context,
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Caro"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {
				"delver_A": {"threshold_hesitations": 2, "lingers": 2, "returns": 2},
				"delver_B": {"threshold_hesitations": 1, "lingers": 1, "returns": 1},
				"delver_C": {"threshold_hesitations": 1, "lingers": 0, "returns": 1}
			},
			"pair_summaries": {
				"delver_A:delver_B": {"proximity": 4, "following": 2, "separation": 1, "shared_carry_pressure": 2}
			},
			"room_summaries": {
				"room:2": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 1},
				"room:3": {"threshold_waits": 1, "collective_hesitations": 2, "returns": 1, "lingers": 1, "burden_pressure": 1}
			},
			"strong_rooms": {"threshold_hesitation": 3, "collective_hesitations": 2, "returns": 2, "lingers": 2, "burden_pressure": 2},
			"strong_room_list": [],
			"echo_tags": ["threshold attention", "ritual return"]
		},
		"stats": {"notes_count": 2, "pinned_count": 1, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["Charged carry", "The branch kept repeating itself"],
		"key_clues": ["The same burden pattern kept returning"],
		"report_path": "user://reports/v3_final_4401.txt",
		"item_defs": ["timeline_bookmark", "lantern_snuffer", "zipline_kit"],
		"room_families": ["evidence", "hazard", "traversal"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_handoff", "room_callout"],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 1, "artifact": 1},
		"outcome_summary": {"summary_text": "Charged extraction", "artifact_result_text": "Authentic artifact extracted", "artifact_result": "authentic", "expedition_success": true, "sabotage_success": false}
	}
	var applied := profile
	for seed in [4401, 4402, 4403, 4404]:
		var run_record: Dictionary = dense_run.duplicate(true)
		run_record["seed"] = seed
		run_record["report_path"] = "user://reports/v3_final_%d.txt" % seed
		applied = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(applied, run_record, catalog).get("profile", {}))
	var home_lines := PROFILE_SERVICE_SCRIPT.build_home_overview_lines(applied, {}, catalog)
	if "\n".join(home_lines).find("Carryover:") == -1:
		failures.append("home overview should surface carryover pressure once repeated challenge or promise weight builds")
	var roster_lines := PROFILE_SERVICE_SCRIPT.build_lobby_roster_lines(
		applied,
		{2: true, 3: true, 4: false},
		{
			"2": {"display_name": "Aster", "public_id": "delver_A", "legend_hint": "Rescuer under pressure", "crew_tag": "Echo crew", "heat_band": "High"},
			"3": {"display_name": "Bram", "public_id": "delver_B", "crew_tag": "Echo crew", "heat_band": "High"},
			"4": {"display_name": "Caro", "public_id": "delver_C", "heat_band": "Warm"}
		},
		2
	)
	var roster_text := "\n".join(roster_lines)
	if roster_text.find("Echo crew") == -1 or roster_text.find("Heat") == -1:
		failures.append("lobby roster should surface crew continuity and public heat through the existing roster path")
	var item_entries := PROFILE_SERVICE_SCRIPT.build_collection_entries(applied, "Items", catalog)
	if item_entries.is_empty():
		failures.append("item collection entries should still build after item-myth depth finalization")
	else:
		var item_detail := str(Dictionary(item_entries[0]).get("detail", ""))
		if item_detail.find("Field:") == -1 or item_detail.find("Current pull:") == -1 or item_detail.find("Revision:") == -1:
			failures.append("item collection detail should surface world-field state, pull, and revision through the existing collection path")
	var archive_lines := ARCHIVE_SERVICE_SCRIPT.build_archive_lines(applied)
	if "\n".join(archive_lines).find("Reading:") == -1:
		failures.append("archive summary should surface interpretive-school reading once legend density builds")
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("finalization depth test requires archive cases to exist")
	else:
		var archive_text := str(Dictionary(archive_entries[0]).get("detail", ""))
		for marker in ["Reading:", "Field pull:", "Retell as:"]:
			if archive_text.find(marker) == -1:
				failures.append("archive cases should surface %s after finalization depth updates" % marker)
	var progress_state: Dictionary = Dictionary(applied.get("narrative_progress", {}))
	var progress_flags := Array(progress_state.get("post_core_flags", []))
	if not progress_flags.has("deep_archive") and not progress_flags.has("gravity_lock"):
		failures.append("repeated dense runs should unlock deeper archive/gravity progression flags")
	var world_memory: Dictionary = Dictionary(applied.get("world_memory", {}))
	var fascination: Dictionary = Dictionary(world_memory.get("fascination", {}))
	if int(fascination.get("fatigue", 0)) < 1:
		failures.append("repeated focus on the same pressure should build world attention fatigue")
	var world_lines := WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory)
	var world_text := "\n".join(world_lines)
	if world_text.find("Attention fatigue:") == -1 and world_text.find("Gravity center:") == -1:
		failures.append("world lines should surface either fatigue or gravity-center pressure once fascination becomes dense")
	var frame := Dictionary(Dictionary(applied.get("last_run", {})).get("frame", {}))
	if Array(frame.get("school_reads", [])).size() < 2 or str(frame.get("school_tension", "")).strip_edges().is_empty():
		failures.append("framing should preserve multiple interpretive-school readings and a clear tension line")
	var poisoned: Dictionary = PROFILE_SERVICE_SCRIPT.normalize_profile(applied, catalog)
	poisoned["archive_state"] = {
		"cases": [{
			"id": "poison",
			"label": "Observer case",
			"detail": "behavioral system experiment entry"
		}],
		"legends": [],
		"shorthand": {}
	}
	poisoned["world_memory"] = {
		"run_index": 0,
		"myths": {},
		"fascination": {
			"topics": {},
			"current_focus": "observer experiment",
			"current_heat": 5,
			"phase": "active",
			"pressure": "behavioral system pressure",
			"cool_streak": 0,
			"focus_history": [],
			"streak": 1,
			"fatigue": 0
		},
		"legend_log": []
	}
	var guarded_archive := PROFILE_SERVICE_SCRIPT.build_codex_entries(poisoned, "archive_cases", catalog)
	var guarded_home := PROFILE_SERVICE_SCRIPT.build_home_overview_lines(poisoned, {}, catalog)
	var guarded_text := "\n".join(guarded_home)
	if not guarded_archive.is_empty():
		guarded_text += "\n" + str(Dictionary(guarded_archive[0]).get("label", "")) + "\n" + str(Dictionary(guarded_archive[0]).get("detail", ""))
	for banned in ["observer", "experiment", "behavioral system"]:
		if guarded_text.to_lower().find(banned) != -1:
			failures.append("centralized wording safety should scrub hidden-truth language from shell and archive emitters, not only direct guard_text calls")

func _test_master_narrative_v35_stabilization_and_culture(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var branch_context := {
		"branch_family_id": "grave_lattice",
		"branch_family_name": "Grave Lattice",
		"challenge_texture": "high ceremony",
		"confrontation_climate": "precarious",
		"rescue_climate": "communal",
		"route_commitment": "severe",
		"symbolic_anchor": "echo gate"
	}
	var base_run := {
		"seed": 5501,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 2, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 11, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 18, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
			{"event_id": 4, "tick": 31, "room_slot": 3, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
			{"event_id": 5, "tick": 36, "room_slot": 3, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}},
			{"event_id": 6, "tick": 52, "room_slot": 4, "actor_peer_id": -1, "event_type": "extraction_window_started", "visibility": "public", "meta": {}},
			{"event_id": 7, "tick": 60, "room_slot": 4, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"timeline_private_events": [],
		"room_chain_summary": [
			{"slot": 2, "type": "evidence", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 3, "type": "hazard", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 4, "type": "traversal", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context}
		],
		"branch_context_summary": branch_context,
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Caro"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {
				"delver_A": {"threshold_hesitations": 2, "lingers": 2, "returns": 2},
				"delver_B": {"threshold_hesitations": 1, "lingers": 1, "returns": 1},
				"delver_C": {"threshold_hesitations": 1, "lingers": 0, "returns": 1}
			},
			"pair_summaries": {
				"delver_A:delver_B": {"proximity": 4, "following": 2, "separation": 1, "shared_carry_pressure": 2},
				"delver_A:delver_C": {"proximity": 2, "following": 1, "separation": 2, "shared_carry_pressure": 0}
			},
			"room_summaries": {
				"room:2": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 1},
				"room:3": {"threshold_waits": 1, "collective_hesitations": 2, "returns": 1, "lingers": 1, "burden_pressure": 2}
			},
			"strong_rooms": {"threshold_hesitation": 3, "collective_hesitations": 2, "returns": 2, "lingers": 2, "burden_pressure": 2},
			"strong_room_list": [],
			"echo_tags": ["threshold attention", "ritual return"]
		},
		"stats": {"notes_count": 2, "pinned_count": 1, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["Charged carry", "The branch kept repeating itself"],
		"key_clues": ["The same burden pattern kept returning"],
		"report_path": "user://reports/v35_final_5501.txt",
		"item_defs": ["timeline_bookmark", "lantern_snuffer", "zipline_kit"],
		"room_families": ["evidence", "hazard", "traversal"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_handoff", "room_callout"],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 1, "artifact": 1},
		"outcome_summary": {"summary_text": "Charged extraction", "artifact_result_text": "Authentic artifact extracted", "artifact_result": "authentic", "expedition_success": true, "sabotage_success": false}
	}
	var applied := profile
	for seed in [5501, 5502, 5503, 5504, 5505]:
		var run_record: Dictionary = base_run.duplicate(true)
		run_record["seed"] = seed
		run_record["report_path"] = "user://reports/v35_final_%d.txt" % seed
		if seed == 5505:
			run_record["timeline_public_events"] = [
				{"event_id": 1, "tick": 10, "room_slot": 2, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
				{"event_id": 2, "tick": 12, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
				{"event_id": 3, "tick": 24, "room_slot": 3, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
				{"event_id": 4, "tick": 42, "room_slot": 4, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
			]
			run_record["action_summary"] = ["The same burden line finally steadied", "The branch refused to collapse on cue"]
			run_record["communication_summary"] = {"total": 3, "danger": 1, "regroup": 2, "artifact": 1}
		applied = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(applied, run_record, catalog).get("profile", {}))
	var last_run: Dictionary = Dictionary(applied.get("last_run", {}))
	var frame: Dictionary = Dictionary(last_run.get("frame", {}))
	if Array(frame.get("school_reads", [])).size() < 2:
		failures.append("commentary ecology should preserve multiple school readings after repeated dense runs")
	if str(frame.get("school_tension", "")).strip_edges().is_empty():
		failures.append("commentary ecology should produce a school tension line when interpretations diverge")
	var active_crawl_lines := CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(applied)
	var crawl_text := "\n".join(active_crawl_lines)
	if crawl_text.find("Challenge:") == -1 or crawl_text.find("Promise:") == -1:
		failures.append("crawl saga depth should surface both public challenge and promise carryover in active crawl lines")
	var archive_lines := ARCHIVE_SERVICE_SCRIPT.build_archive_lines(applied)
	var archive_summary := "\n".join(archive_lines)
	for marker in ["Reading:", "Compare:", "Retell as:"]:
		if archive_summary.find(marker) == -1:
			failures.append("archive summary should surface %s after the finalization pass" % marker)
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("archive cases should still exist after the finalization pass")
	else:
		var archive_detail := str(Dictionary(archive_entries[0]).get("detail", ""))
		for marker in ["Compare:", "Continuity:", "Field pull:", "Retell as:", "Reading:"]:
			if archive_detail.find(marker) == -1:
				failures.append("archive cases should include %s in the finalization pass" % marker)
	var world_memory: Dictionary = Dictionary(applied.get("world_memory", {}))
	var field_snapshot := WORLD_MEMORY_SERVICE_SCRIPT.field_snapshot(world_memory)
	var field_lines := Array(Dictionary(field_snapshot.get("myth_field", {})).get("active_lines", []))
	if field_lines.is_empty():
		failures.append("world memory should retain active myth-field interaction lines after the finalization pass")
	var world_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "world_fascination", catalog)
	var world_text := ""
	for entry in world_entries:
		world_text += str(Dictionary(entry).get("label", "")) + "\n" + str(Dictionary(entry).get("detail", "")) + "\n"
	for marker in ["Field |", "Pair |", "Crew |", "Crawl |"]:
		if world_text.find(marker) == -1:
			failures.append("world fascination entries should surface %s after the finalization pass" % marker)
	var collection_entries := PROFILE_SERVICE_SCRIPT.build_collection_entries(applied, "Items", catalog)
	if collection_entries.is_empty():
		failures.append("collection entries should still build after item-myth deepening")
	else:
		var item_detail := str(Dictionary(collection_entries[0]).get("detail", ""))
		for marker in ["Resonance:", "Shadow:", "Cooling:", "Revision:"]:
			if item_detail.find(marker) == -1:
				failures.append("item collection detail should include %s after the finalization pass" % marker)
	var home_lines := PROFILE_SERVICE_SCRIPT.build_home_overview_lines(applied, {}, catalog)
	var home_text := "\n".join(home_lines)
	if home_text.find("Carryover:") == -1 or home_text.find("Compare:") == -1:
		failures.append("home overview should surface both carryover and archive comparison context after the finalization pass")
	var progress_lines := PROFILE_SERVICE_SCRIPT.build_progression_preview_lines(applied, catalog)
	var progress_text := "\n".join(progress_lines)
	var progress_markers := [
		"Separate echoes are beginning to answer each other directly.",
		"A familiar reading is starting to bend away from itself.",
		"Competing readings are starting to matter as much as the events themselves.",
		"Archive depth: repeated challenges are starting to read like lessons with motives.",
		"Archive depth: the same pressures now feel like they are being anticipated in advance."
	]
	var has_progress_marker := false
	for marker in progress_markers:
		if progress_text.find(marker) != -1:
			has_progress_marker = true
			break
	if not has_progress_marker:
		failures.append("narrative progression should surface richer late-layer continuity after the finalization pass")
	var public_card := PROFILE_SERVICE_SCRIPT.build_public_identity_card(applied, catalog)
	if str(public_card.get("challenge_hint", "")).strip_edges().is_empty() or str(public_card.get("crew_tag", "")).strip_edges().is_empty():
		failures.append("public identity cards should carry challenge and crew continuity hints after the finalization pass")
	var roster_lines := PROFILE_SERVICE_SCRIPT.build_lobby_roster_lines(
		applied,
		{2: true, 3: false, 4: true},
		{
			"2": public_card,
			"3": {"display_name": "Bram", "public_id": "delver_B", "crew_tag": "Echo crew", "heat_band": "High"},
			"4": {"display_name": "Caro", "public_id": "delver_C", "heat_band": "Warm"}
		},
		2
	)
	var roster_text := "\n".join(roster_lines)
	if roster_text.find("Echo crew") == -1 or roster_text.find("Heat") == -1:
		failures.append("lobby continuity should surface crew and heat continuity after the finalization pass")
	var poisoned: Dictionary = PROFILE_SERVICE_SCRIPT.normalize_profile(applied, catalog)
	poisoned["world_memory"] = {
		"run_index": 0,
		"myths": {},
		"fascination": {
			"topics": {},
			"current_focus": "observer experiment",
			"current_heat": 5,
			"phase": "active",
			"pressure": "behavioral system pressure",
			"cool_streak": 0,
			"focus_history": [],
			"streak": 1,
			"fatigue": 0
		},
		"legend_log": [],
		"myth_field": {"resonance_count": 0, "damping_count": 0, "shadow_count": 0, "top_successor": {}, "active_lines": []},
		"cultural_gravity": {"top_label": "", "top_bucket": "", "top_gravity": 0, "lines": []},
		"topic_interaction": {"lines": []},
		"myth_cooling": {"lines": []},
		"myth_collision": {"lines": []},
		"myth_resurgence": {"lines": []}
	}
	var guarded_text := "\n".join(PROFILE_SERVICE_SCRIPT.build_home_overview_lines(poisoned, {}, catalog))
	guarded_text += "\n" + "\n".join(PROFILE_SERVICE_SCRIPT.build_progression_preview_lines(poisoned, catalog))
	guarded_text += "\n" + "\n".join(PROFILE_SERVICE_SCRIPT.build_codex_lines(poisoned, catalog))
	guarded_text += "\n" + "\n".join(PROFILE_SERVICE_SCRIPT.build_collection_lines(poisoned, catalog))
	guarded_text += "\n" + "\n".join(ARCHIVE_SERVICE_SCRIPT.build_archive_lines(poisoned))
	if not collection_entries.is_empty():
		guarded_text += "\n" + str(Dictionary(PROFILE_SERVICE_SCRIPT.build_collection_entries(poisoned, "Items", catalog)[0]).get("detail", ""))
	guarded_text += "\n" + "\n".join(PROFILE_SERVICE_SCRIPT.build_lobby_roster_lines(
		poisoned,
		{2: true, 3: false},
		{
			"2": PROFILE_SERVICE_SCRIPT.build_public_identity_card(poisoned, catalog),
			"3": {"display_name": "Bram", "public_id": "delver_B", "legend_hint": "observer experiment", "crew_tag": "behavioral system crew", "heat_band": "Warm"}
		},
		2
	))
	for banned in ["observer", "experiment", "behavioral system"]:
		if guarded_text.to_lower().find(banned) != -1:
			failures.append("centralized wording safety should scrub hidden-truth language across home, progression, codex, collection, archive, and lobby emitters")

func _test_master_narrative_v3_refinement_richness(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var branch_context := {
		"branch_family_id": "grave_lattice",
		"branch_family_name": "Grave Lattice",
		"challenge_texture": "high ceremony",
		"confrontation_climate": "precarious",
		"rescue_climate": "communal",
		"route_commitment": "severe",
		"symbolic_anchor": "echo gate"
	}
	var base_run := {
		"seed": 6601,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 2, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 12, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 24, "room_slot": 3, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
			{"event_id": 4, "tick": 31, "room_slot": 3, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
			{"event_id": 5, "tick": 43, "room_slot": 4, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"timeline_private_events": [],
		"room_chain_summary": [
			{"slot": 2, "type": "evidence", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 3, "type": "hazard", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context},
			{"slot": 4, "type": "traversal", "branch_family_id": "grave_lattice", "branch_family_name": "Grave Lattice", "branch_context": branch_context}
		],
		"branch_context_summary": branch_context,
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Caro"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {
				"delver_A": {"threshold_hesitations": 2, "lingers": 2, "returns": 2},
				"delver_B": {"threshold_hesitations": 1, "lingers": 1, "returns": 2},
				"delver_C": {"threshold_hesitations": 1, "lingers": 1, "returns": 1}
			},
			"pair_summaries": {
				"delver_A:delver_B": {"proximity": 4, "following": 2, "separation": 1, "shared_carry_pressure": 2},
				"delver_A:delver_C": {"proximity": 2, "following": 1, "separation": 2, "shared_carry_pressure": 0}
			},
			"room_summaries": {
				"room:2": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 1},
				"room:3": {"threshold_waits": 1, "collective_hesitations": 2, "returns": 1, "lingers": 1, "burden_pressure": 2}
			},
			"strong_rooms": {"threshold_hesitation": 3, "collective_hesitations": 2, "returns": 2, "lingers": 2, "burden_pressure": 2},
			"strong_room_list": [],
			"echo_tags": ["threshold attention", "ritual return"]
		},
		"stats": {"notes_count": 2, "pinned_count": 1, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["Charged carry", "The branch kept repeating itself"],
		"key_clues": ["The same burden pattern kept returning"],
		"report_path": "user://reports/v3_refine_6601.txt",
		"item_defs": ["timeline_bookmark", "lantern_snuffer", "zipline_kit"],
		"room_families": ["evidence", "hazard", "traversal"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_handoff", "room_callout"],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 1, "artifact": 1},
		"outcome_summary": {"summary_text": "Charged extraction", "artifact_result_text": "Authentic artifact extracted", "artifact_result": "authentic", "expedition_success": true, "sabotage_success": false}
	}
	var applied := profile
	for seed in [6601, 6602, 6603, 6604, 6605]:
		var run_record: Dictionary = base_run.duplicate(true)
		run_record["seed"] = seed
		run_record["report_path"] = "user://reports/v3_refine_%d.txt" % seed
		if seed == 6604:
			run_record["interrupted"] = true
			run_record["timeline_public_events"] = [
				{"event_id": 1, "tick": 10, "room_slot": 2, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
				{"event_id": 2, "tick": 18, "room_slot": 3, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
				{"event_id": 3, "tick": 26, "room_slot": 3, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}}
			]
			run_record["outcome_summary"] = {"summary_text": "Interrupted under heat", "artifact_result_text": "Artifact lost", "artifact_result": "lost", "expedition_success": false, "sabotage_success": false}
		applied = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(applied, run_record, catalog).get("profile", {}))
	var crawl_text := "\n".join(CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(applied))
	if crawl_text.find("Historical weight:") == -1 and crawl_text.find("Memorial pull:") == -1:
		failures.append("crawl saga refinement should surface historical or memorial weight once a saga accumulates repeated strain")
	var relationship_entries := CRAWL_SERVICE_SCRIPT.build_relationship_entries(applied)
	var relationship_text := ""
	for entry in relationship_entries:
		relationship_text += str(Dictionary(entry).get("detail", "")) + "\n"
	if relationship_text.find("Pattern:") == -1:
		failures.append("pair and crew continuity should surface pattern language once repeated rescues, burdens, or near-misses accumulate")
	var world_lines := WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(Dictionary(applied.get("world_memory", {})))
	var world_text := "\n".join(world_lines)
	if world_text.find("Interaction:") == -1 and world_text.find("Recast pressure:") == -1:
		failures.append("world lines should surface myth interaction or recast pressure after repeated loaded runs")
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("archive refinement requires archive cases to remain available")
	else:
		var archive_detail := str(Dictionary(archive_entries[0]).get("detail", ""))
		if archive_detail.find("Compare:") == -1 or archive_detail.find("Field pull:") == -1:
			failures.append("archive refinement should preserve stronger compare and field-pull lines in case details")
	var home_text := "\n".join(PROFILE_SERVICE_SCRIPT.build_home_overview_lines(applied, {}, catalog))
	if home_text.find("Memorial:") == -1 and home_text.find("Carryover:") == -1:
		failures.append("home overview should surface memorial or carryover weight after repeated saga strain")
	var public_card := PROFILE_SERVICE_SCRIPT.build_public_identity_card(applied, catalog)
	if str(public_card.get("challenge_hint", "")).strip_edges().is_empty() or str(public_card.get("crew_tag", "")).strip_edges().is_empty():
		failures.append("public identity cards should carry both challenge and crew continuity hints once continuity deepens")
	var roster_text := "\n".join(PROFILE_SERVICE_SCRIPT.build_lobby_roster_lines(
		applied,
		{2: true, 3: true, 4: false},
		{
			"2": public_card,
			"3": {"display_name": "Bram", "public_id": "delver_B", "legend_hint": "Rescuer under pressure", "crew_tag": "Echo crew", "heat_band": "High"},
			"4": {"display_name": "Caro", "public_id": "delver_C", "heat_band": "Warm"}
		},
		2
	))
	if roster_text.find("Heat") == -1 or (roster_text.find("Watching") == -1 and roster_text.find("carry") == -1 and roster_text.find("owes") == -1 and roster_text.find("Challenge") == -1):
		failures.append("lobby continuity should surface both public heat and a meaningful carryover pressure line")
	var collection_entries := PROFILE_SERVICE_SCRIPT.build_collection_entries(applied, "Items", catalog)
	if collection_entries.is_empty():
		failures.append("collection entries should still build during refinement richness tests")
	else:
		var item_detail := str(Dictionary(collection_entries[0]).get("detail", ""))
		if item_detail.find("History pressure:") == -1:
			failures.append("collection detail should surface item history pressure once item myths deepen")
	var frame := Dictionary(Dictionary(applied.get("last_run", {})).get("frame", {}))
	var preview_text := "\n".join(FRAMING_SERVICE_SCRIPT.build_archive_preview_lines(frame))
	if preview_text.find("Tension:") == -1:
		failures.append("archive preview lines should surface school tension when commentary schools diverge")

func _test_master_narrative_v35_ai_native_inference(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var branch_context := {
		"branch_family_id": "watcher_steps",
		"branch_family_name": "Watcher Steps",
		"challenge_texture": "measured exposure",
		"confrontation_climate": "watchful",
		"rescue_climate": "narrow",
		"route_commitment": "split ledges",
		"symbolic_anchor": "signal stair"
	}
	var base_run := {
		"seed": 7701,
		"end_reason": "extraction_objective",
		"local_peer_id": 2,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": true,
		"interrupted": false,
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 12, "room_slot": 1, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 18, "room_slot": 1, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
			{"event_id": 4, "tick": 29, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
			{"event_id": 5, "tick": 44, "room_slot": 3, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}},
			{"event_id": 6, "tick": 58, "room_slot": 4, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"timeline_private_events": [],
		"room_chain_summary": [
			{"slot": 1, "type": "evidence", "branch_family_id": "watcher_steps", "branch_family_name": "Watcher Steps", "branch_context": branch_context},
			{"slot": 2, "type": "hazard", "branch_family_id": "watcher_steps", "branch_family_name": "Watcher Steps", "branch_context": branch_context},
			{"slot": 3, "type": "traversal", "branch_family_id": "watcher_steps", "branch_family_name": "Watcher Steps", "branch_context": branch_context}
		],
		"branch_context_summary": branch_context,
		"peer_identities": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"}
		},
		"narrative_motion_facts": {
			"peer_summaries": {
				"delver_A": {"threshold_hesitations": 3, "lingers": 2, "returns": 3},
				"delver_B": {"threshold_hesitations": 1, "lingers": 2, "returns": 2}
			},
			"pair_summaries": {
				"delver_A:delver_B": {"proximity": 4, "following": 2, "separation": 2, "shared_carry_pressure": 2}
			},
			"room_summaries": {
				"room:1": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 1, "lingers": 1, "burden_pressure": 2},
				"room:2": {"threshold_waits": 2, "collective_hesitations": 1, "returns": 2, "lingers": 2, "burden_pressure": 2}
			},
			"strong_rooms": {"threshold_hesitation": 3, "collective_hesitations": 2, "returns": 3, "lingers": 2, "burden_pressure": 2},
			"strong_room_list": [],
			"echo_tags": ["threshold attention", "ritual return", "loaded revisiting"]
		},
		"gameplay_signal_snapshot": {
			"protocol_state": "Exposure Protocol",
			"player_count": 2,
			"peer_models": {
				"delver_A": {
					"build_identity": "Rescue build",
					"build_scores": {"Rescue build": 7},
					"behavior_signals": ["rescue geometry", "route memory"],
					"synergy_labels": ["private archive ritual"],
					"ritual_hooks": ["bookmark ritual"],
					"anomaly_hooks": ["memory seam"],
					"protocol_hooks": ["exposure discipline"],
					"resource_signals": ["anchor line"],
					"inhabitant_signals": ["direct exposure"]
				},
				"delver_B": {
					"build_identity": "Control build",
					"build_scores": {"Control build": 5},
					"behavior_signals": ["attention split"],
					"synergy_labels": [],
					"ritual_hooks": [],
					"anomaly_hooks": [],
					"protocol_hooks": ["pair caution"],
					"resource_signals": ["noise pulse"],
					"inhabitant_signals": ["ghost pressure"]
				}
			},
			"build_identities": ["Rescue build", "Control build"],
			"resource_pressure": ["anchor line", "noise pulse"],
			"inhabitant_pressure": ["direct exposure", "ghost pressure"]
		},
		"stats": {"notes_count": 3, "pinned_count": 1, "inspections_count": 2, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["The same line kept being watched", "The burden answer kept changing hands"],
		"key_clues": ["The branch kept asking for the same answer"],
		"report_path": "user://reports/v35_inference_7701.txt",
		"item_defs": ["timeline_bookmark", "lantern_snuffer", "heavy_boots"],
		"room_families": ["evidence", "hazard", "traversal"],
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_handoff", "room_callout"],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 1, "artifact": 2},
		"outcome_summary": {"summary_text": "Recovered under low density", "artifact_result_text": "Authentic artifact extracted", "artifact_result": "authentic", "expedition_success": true, "sabotage_success": false}
	}
	var applied := profile
	for seed in [7701, 7702, 7703]:
		var run_record: Dictionary = base_run.duplicate(true)
		run_record["seed"] = seed
		run_record["report_path"] = "user://reports/v35_inference_%d.txt" % seed
		if seed == 7702:
			run_record["interrupted"] = true
			run_record["timeline_public_events"] = [
				{"event_id": 1, "tick": 10, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
				{"event_id": 2, "tick": 19, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_stolen", "visibility": "public", "meta": {"artifact_id": 1, "from_peer": 2}},
				{"event_id": 3, "tick": 31, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "lantern_snuffer"}}
			]
			run_record["action_summary"] = ["The answer line hesitated again", "The branch stayed unresolved"]
			run_record["communication_summary"] = {"total": 3, "danger": 2, "regroup": 0, "artifact": 1}
			run_record["outcome_summary"] = {"summary_text": "Interrupted under unresolved pressure", "artifact_result_text": "-", "artifact_result": "", "expedition_success": false, "sabotage_success": false}
		elif seed == 7703:
			run_record["timeline_public_events"] = [
				{"event_id": 1, "tick": 9, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
				{"event_id": 2, "tick": 11, "room_slot": 1, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
				{"event_id": 3, "tick": 22, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
				{"event_id": 4, "tick": 51, "room_slot": 3, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
			]
			run_record["action_summary"] = ["The expected collapse never landed", "The pair answered the burden line cleanly"]
			run_record["communication_summary"] = {"total": 3, "danger": 1, "regroup": 2, "artifact": 1}
		applied = Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(applied, run_record, catalog).get("profile", {}))

	var last_run: Dictionary = Dictionary(applied.get("last_run", {}))
	var diagnostics: Dictionary = Dictionary(last_run.get("diagnostics", {}))
	if str(diagnostics.get("protocol_state_hint", "")).strip_edges().is_empty():
		failures.append("ai-native inference pass should preserve protocol-state hints on live diagnostics")
	if Dictionary(diagnostics.get("belief_state", {})).is_empty():
		failures.append("ai-native inference pass should derive a belief-state packet from repeated low-density pressure")
	if Array(diagnostics.get("counterfactual_pressure", [])).is_empty():
		failures.append("ai-native inference pass should track counterfactual pressure in the diagnostics packet")
	if Array(diagnostics.get("hidden_curriculum", [])).is_empty():
		failures.append("ai-native inference pass should derive hidden-curriculum lines from repeated recovery and burden patterns")
	if int(Dictionary(diagnostics.get("anomaly_sensitivity", {})).get("score", 0)) <= 0:
		failures.append("ai-native inference pass should compute anomaly sensitivity from repeat-return behavior")
	if str(diagnostics.get("build_identity", "")).strip_edges().is_empty():
		failures.append("ai-native inference pass should derive build identity from gameplay signal snapshots")
	if Array(diagnostics.get("resource_pressure", [])).is_empty():
		failures.append("ai-native inference pass should preserve resource pressure from gameplay snapshots")
	if Array(diagnostics.get("inhabitant_pressure", [])).is_empty():
		failures.append("ai-native inference pass should preserve inhabitant pressure from gameplay snapshots")
	if Array(diagnostics.get("synergy_labels", [])).is_empty():
		failures.append("ai-native inference pass should preserve synergy labels from gameplay snapshots")
	if Array(diagnostics.get("model_pressure", [])).is_empty():
		failures.append("ai-native inference pass should derive model-pressure lines from gameplay snapshots")
	if Array(diagnostics.get("group_fault_lines", [])).is_empty():
		failures.append("ai-native inference pass should derive group fault lines from gameplay snapshots")
	if str(diagnostics.get("build_stability", "")).strip_edges().is_empty():
		failures.append("ai-native inference pass should preserve build stability from gameplay snapshots")
	if str(diagnostics.get("risk_profile", "")).strip_edges().is_empty():
		failures.append("ai-native inference pass should preserve risk profile from gameplay snapshots")
	if Array(diagnostics.get("gameplay_feature_signals", [])).is_empty():
		failures.append("ai-native inference pass should preserve feature-level gameplay signals")

	var frame: Dictionary = Dictionary(last_run.get("frame", {}))
	for key in ["protocol_state", "belief_line", "counterfactual_line", "curriculum_line", "anomaly_pull"]:
		if str(frame.get(key, "")).strip_edges().is_empty():
			failures.append("ai-native inference framing should surface %s through the public frame" % key)
	for key in ["build_line", "resource_line", "inhabitant_line"]:
		if str(frame.get(key, "")).strip_edges().is_empty():
			failures.append("ai-native inference framing should surface %s from gameplay-facing signals" % key)
	if str(frame.get("challenge_attention", "")).strip_edges().is_empty():
		failures.append("ai-native inference framing should turn model pressure into challenge attention")
	if Array(frame.get("school_reads", [])).size() < 2:
		failures.append("ai-native inference framing should keep multiple school reads alive around the same low-density pressure run")

	var crawl_text := "\n".join(CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(applied))
	for marker in ["Belief:", "Answer shape:", "Fault line:", "Lesson:", "Uneasy pull:"]:
		if crawl_text.find(marker) == -1:
			failures.append("active crawl lines should surface %s after inference-weighted saga carryover" % marker)

	var world_text := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(Dictionary(applied.get("world_memory", {}))))
	if world_text.find("Protocol:") == -1:
		failures.append("world-memory lines should surface protocol pressure after repeated low-density inference runs")

	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("archive cases should still be available for ai-native inference continuity")
	else:
		var archive_detail := str(Dictionary(archive_entries[0]).get("detail", ""))
		for marker in ["Belief:", "Counterfactual:", "Answer shape:", "Fault line:", "Pressure lesson:", "Uneasy pull:", "Build:", "Pressure:", "Presence:", "Stability:"]:
			if archive_detail.find(marker) == -1:
				failures.append("archive case detail should surface %s after inference-native refinement" % marker)

	var collection_entries := PROFILE_SERVICE_SCRIPT.build_collection_entries(applied, "Items", catalog)
	if collection_entries.is_empty():
		failures.append("collection entries should still build during inference refinement")
	else:
		var item_detail := str(Dictionary(collection_entries[0]).get("detail", ""))
		for marker in ["Protocol affinity:", "Model hooks:", "Latent pull:", "Behavior signals:", "Resource hooks:"]:
			if item_detail.find(marker) == -1:
				failures.append("collection entries should surface %s for item inference profiles" % marker)

	var public_card := PROFILE_SERVICE_SCRIPT.build_public_identity_card(applied, catalog)
	for key in ["challenge_hint", "crew_tag", "build_hint", "presence_hint"]:
		if str(public_card.get(key, "")).strip_edges().is_empty():
			failures.append("public identity cards should surface %s after the inference pass" % key)
	var home_text: String = "\n".join(PROFILE_SERVICE_SCRIPT.build_home_overview_lines(applied))
	var expected_home_pull: String = ""
	var model_pressure: Array = diagnostics.get("model_pressure", [])
	if model_pressure is Array and not model_pressure.is_empty():
		expected_home_pull = str(model_pressure[0]).strip_edges()
	if expected_home_pull.is_empty():
		var belief_state := Dictionary(diagnostics.get("belief_state", {}))
		for value in belief_state.values():
			var text := str(value).strip_edges()
			if not text.is_empty():
				expected_home_pull = text
				break
	if home_text.find("Momentum:") == -1 or (not expected_home_pull.is_empty() and home_text.to_lower().find(expected_home_pull.to_lower()) == -1):
		failures.append("home overview should surface stronger AI-native carryover after the inference pass")

	var roster_text := "\n".join(PROFILE_SERVICE_SCRIPT.build_lobby_roster_lines(
		applied,
		{2: true, 3: false},
		{
			"2": public_card,
			"3": {"display_name": "Bram", "public_id": "delver_B", "legend_hint": "The answer line keeps narrowing", "crew_tag": "Watcher crew", "heat_band": "High"}
		},
		2
	))
	if roster_text.find("Challenge:") == -1 or roster_text.find("Heat") == -1:
		failures.append("lobby roster lines should surface both challenge and heat after the inference pass")

	var poisoned_profile: Dictionary = PROFILE_SERVICE_SCRIPT.normalize_profile(applied, catalog)
	var poisoned_fabric: Dictionary = Dictionary(poisoned_profile.get("relationship_fabric", {})).duplicate(true)
	var poisoned_players: Dictionary = Dictionary(poisoned_fabric.get("players", {}))
	if poisoned_players.has("delver_A"):
		var player_entry: Dictionary = Dictionary(poisoned_players.get("delver_A", {}))
		player_entry["status_burden"] = "observer experiment pressure"
		poisoned_players["delver_A"] = player_entry
	poisoned_fabric["players"] = poisoned_players
	poisoned_profile["relationship_fabric"] = poisoned_fabric
	var poisoned_card := PROFILE_SERVICE_SCRIPT.build_public_identity_card(poisoned_profile, catalog)
	var poisoned_text := JSON.stringify(poisoned_card).to_lower()
	for banned in ["observer", "experiment", "behavioral system"]:
		if poisoned_text.find(banned) != -1:
			failures.append("public identity card emitters should route through the wording guard for hidden-truth language")

func _test_gameplay_signal_network_depth(failures: Array[String]) -> void:
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var loadout_state: Dictionary = item_service.resolve_loadout_state(
		["timeline_bookmark", "lantern_snuffer", "zipline_kit"],
		{
			"protocol_state": "Exposure Protocol",
			"tool_counts": {"bomb": 1, "rope": 2},
			"carrying_artifact": true,
			"ghost_active": true
		}
	)
	if str(loadout_state.get("build_identity", "")).strip_edges().is_empty():
		failures.append("gameplay signal engine should derive a build identity from latent overlap and context")
	if not Array(loadout_state.get("synergy_labels", [])).has("private archive ritual"):
		failures.append("gameplay signal engine should resolve known latent synergies deterministically")
	if Array(loadout_state.get("resource_signals", [])).is_empty():
		failures.append("gameplay signal engine should emit resource signals from item/context state")
	if Array(loadout_state.get("anomaly_hooks", [])).is_empty():
		failures.append("gameplay signal engine should emit anomaly hooks for unstable loadouts")
	if Array(loadout_state.get("protocol_hooks", [])).is_empty():
		failures.append("gameplay signal engine should emit protocol hooks for density-aware contexts")
	if str(loadout_state.get("build_stability", "")).strip_edges().is_empty():
		failures.append("gameplay signal engine should expose build stability for downstream modeling")
	if str(loadout_state.get("risk_profile", "")).strip_edges().is_empty():
		failures.append("gameplay signal engine should expose a risk profile for downstream modeling")
	if Array(loadout_state.get("feature_signals", [])).is_empty():
		failures.append("gameplay signal engine should expose feature-level signals")
	if Array(loadout_state.get("model_pressure", [])).is_empty():
		failures.append("gameplay signal engine should expose model-pressure labels for higher-layer interpretation")

	var network_manager := NETWORK_MANAGER_SCRIPT.new()
	network_manager.players = [2, 3]
	network_manager.player_room_by_peer = {2: 1, 3: 1}
	network_manager.items_by_id = {
		1: {"item_def_id": "timeline_bookmark", "owner_peer_id": 2, "consumed": false},
		2: {"item_def_id": "lantern_snuffer", "owner_peer_id": 2, "consumed": false},
		3: {"item_def_id": "zipline_kit", "owner_peer_id": 3, "consumed": false}
	}
	network_manager.reset_tool_inventory_for_test([2, 3], 1, 2)
	network_manager.profile_cards_by_peer = {
		2: {"public_id": "delver_A", "display_name": "Aster"},
		3: {"public_id": "delver_B", "display_name": "Bram"}
	}
	network_manager.ghost_state["active"] = true
	network_manager.ghost_state["target_peer_id"] = 2
	var snapshot: Dictionary = network_manager.build_gameplay_signal_snapshot()
	if str(snapshot.get("protocol_state", "")).strip_edges().is_empty():
		failures.append("network gameplay snapshots should include protocol-state context")
	var peer_models: Dictionary = Dictionary(snapshot.get("peer_models", {}))
	if peer_models.is_empty():
		failures.append("network gameplay snapshots should export per-player inference models")
	else:
		var aster: Dictionary = Dictionary(peer_models.get("delver_A", {}))
		if str(aster.get("build_identity", "")).strip_edges().is_empty():
			failures.append("network gameplay snapshots should preserve build identity for public-id keyed peers")
		if Array(aster.get("behavior_signals", [])).is_empty():
			failures.append("network gameplay snapshots should preserve behavior signals")
		if Array(aster.get("resource_signals", [])).is_empty():
			failures.append("network gameplay snapshots should preserve resource signals")
		if Array(aster.get("inhabitant_signals", [])).is_empty():
			failures.append("network gameplay snapshots should preserve inhabitant pressure signals")
		if Array(aster.get("synergy_labels", [])).is_empty():
			failures.append("network gameplay snapshots should preserve synergy labels")
		if str(aster.get("build_stability", "")).strip_edges().is_empty():
			failures.append("network gameplay snapshots should preserve build stability")
		if str(aster.get("risk_profile", "")).strip_edges().is_empty():
			failures.append("network gameplay snapshots should preserve risk profile")
		if Array(aster.get("feature_signals", [])).is_empty():
			failures.append("network gameplay snapshots should preserve feature signals")
		if Array(aster.get("model_pressure", [])).is_empty():
			failures.append("network gameplay snapshots should preserve model-pressure labels")
	var group_model: Dictionary = Dictionary(snapshot.get("group_model", {}))
	if group_model.is_empty():
		failures.append("network gameplay snapshots should export a deterministic group gameplay model")
	else:
		if Array(group_model.get("group_signals", [])).is_empty():
			failures.append("group gameplay model should preserve shared answer-shape signals")
		if Array(group_model.get("model_pressure", [])).is_empty():
			failures.append("group gameplay model should preserve aggregate model pressure")
		if str(group_model.get("protocol_weighting", "")).strip_edges().is_empty():
			failures.append("group gameplay model should expose protocol weighting")
	network_manager.free()

func _test_protocol_state_player_band_depth(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	if manager.get_protocol_state_label(1) != "Exposure Protocol":
		failures.append("single-player runs should map to Exposure Protocol")
	if manager.get_protocol_state_label(3) != "Intimate Protocol":
		failures.append("three-player runs should map to Intimate Protocol")
	if manager.get_protocol_state_label(7) != "Fracture Protocol":
		failures.append("seven-player runs should map to Fracture Protocol")
	if manager.get_protocol_state_label(12) != "Expedition Protocol":
		failures.append("twelve-player runs should map to Expedition Protocol")

	var exposure_snapshot := _protocol_state_snapshot_for_test(1)
	var intimate_snapshot := _protocol_state_snapshot_for_test(3)
	var fracture_snapshot := _protocol_state_snapshot_for_test(7)
	var expedition_snapshot := _protocol_state_snapshot_for_test(12)
	var exposure_group: Dictionary = Dictionary(exposure_snapshot.get("group_model", {}))
	var intimate_group: Dictionary = Dictionary(intimate_snapshot.get("group_model", {}))
	var fracture_group: Dictionary = Dictionary(fracture_snapshot.get("group_model", {}))
	var expedition_group: Dictionary = Dictionary(expedition_snapshot.get("group_model", {}))
	if str(exposure_group.get("protocol_weighting", "")) != "isolation pressure":
		failures.append("exposure-band gameplay snapshots should preserve isolation pressure weighting")
	if str(intimate_group.get("protocol_weighting", "")) != "pair pressure":
		failures.append("intimate-band gameplay snapshots should preserve pair pressure weighting")
	if str(fracture_group.get("protocol_weighting", "")) != "split pressure":
		failures.append("fracture-band gameplay snapshots should preserve split pressure weighting")
	if str(expedition_group.get("protocol_weighting", "")) != "spectacle pressure":
		failures.append("expedition-band gameplay snapshots should preserve spectacle pressure weighting")
	if not Array(exposure_group.get("fault_lines", [])).has("low-density pressure is forcing each public move to stand alone"):
		failures.append("exposure-band gameplay snapshots should surface the low-density solo-answer fault line")
	if not Array(intimate_group.get("model_pressure", [])).has("pair-density pressure keeps turning route choice into a custody answer"):
		failures.append("intimate-band gameplay snapshots should surface the pair-density custody pressure line")
	if not Array(fracture_group.get("fault_lines", [])).has("mid-density pressure keeps splitting the crew into competing local answers"):
		failures.append("fracture-band gameplay snapshots should surface the split-local-answers fault line")
	if not Array(expedition_group.get("model_pressure", [])).has("crowd density is rewarding spectacle over subtlety"):
		failures.append("expedition-band gameplay snapshots should surface the crowd-spectacle pressure line")

	var generator := RUN_GENERATOR_SCRIPT.new()
	var exposure_weights := generator.room_type_weights_for_slot_for_test(6, 15, {"protocol_state": "Exposure Protocol"})
	var intimate_weights := generator.room_type_weights_for_slot_for_test(6, 15, {"protocol_state": "Intimate Protocol"})
	var fracture_weights := generator.room_type_weights_for_slot_for_test(6, 15, {"protocol_state": "Fracture Protocol"})
	var expedition_weights := generator.room_type_weights_for_slot_for_test(6, 15, {"protocol_state": "Expedition Protocol"})
	if int(expedition_weights.get("traversal", 0)) - int(fracture_weights.get("traversal", 0)) < 2:
		failures.append("expedition-band room weighting should now read materially more traversal-led than fracture-band weighting")
	if int(fracture_weights.get("hazard", 0)) - int(intimate_weights.get("hazard", 0)) < 2:
		failures.append("fracture-band room weighting should now read materially harsher than intimate-band weighting")
	if int(exposure_weights.get("evidence", 0)) - int(expedition_weights.get("evidence", 0)) < 2:
		failures.append("exposure-band room weighting should now read materially more evidence-led than expedition-band weighting")
	if int(intimate_weights.get("traversal", 0)) - int(exposure_weights.get("traversal", 0)) < 2:
		failures.append("intimate-band room weighting should now preserve a stronger traversal handoff bias than exposure-band weighting")
	manager.free()

func _protocol_state_snapshot_for_test(peer_count: int) -> Dictionary:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.players.clear()
	manager.profile_cards_by_peer.clear()
	manager.items_by_id.clear()
	for offset in range(peer_count):
		var peer_id := offset + 2
		manager.players.append(peer_id)
		manager.profile_cards_by_peer[peer_id] = {
			"public_id": "delver_%d" % peer_id,
			"display_name": "Delver %d" % peer_id
		}
	manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "timeline_bookmark", "owner_peer_id": 2, "consumed": false},
		2: {"item_id": 2, "item_def_id": "decoy_emitter", "owner_peer_id": 3 if peer_count >= 2 else 2, "consumed": false},
		3: {"item_id": 3, "item_def_id": "heavy_boots", "owner_peer_id": 4 if peer_count >= 3 else 2, "consumed": false}
	}
	var snapshot := manager.build_gameplay_signal_snapshot()
	manager.free()
	return snapshot

func _test_relationship_obligation_trust_embodiment(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Embodied Trust", "public_id": "embodied_trust"}
	}, catalog)
	profile["relationship_fabric"] = {
		"players": {
			"ally_a": {"title": "Remembered rescuer", "public_reputation": "trusted carrier"},
			"ally_b": {"title": "Witnessed return", "public_reputation": "returns for the burden"}
		},
		"pairs": {
			"ally_a:ally_b": {
				"title": "Custody pair",
				"obligations": ["they are expected to hand the burden cleanly", "their rescue line is still remembered"],
				"rescues": 4,
				"shared_burdens": 3,
				"mutual_extractions": 2,
				"betrayals": 2,
				"refusals": 1,
				"near_misses": 2,
				"public_reputation": "a watched rescue pair"
			}
		},
		"crews": {
			"crew:burden_line": {
				"title": "Hold-line crew",
				"obligations": ["the crew is expected to answer rescue debt in public"],
				"members": ["embodied_trust", "ally_a", "ally_b"],
				"successful_pushes": 2,
				"recoveries": 3,
				"collapse_moments": 1,
				"escalations": 2,
				"history_count": 3,
				"public_reputation": "they keep regrouping under witness"
			}
		},
		"recent_pairs": ["ally_a:ally_b"],
		"recent_crews": ["crew:burden_line"]
	}
	profile["persona_state"] = {
		"archetype_scores": {"rescuer": 4, "stabilizer": 2},
		"risk_posture": {"tendency": "hold together", "temperature": "calm_trust", "momentum": "steadying"},
		"public_expectations": [
			"someone is expected to keep the burden moving",
			"the next extraction is already being judged as a rescue debt"
		]
	}
	var cards := {
		"2": {"public_id": "embodied_trust", "display_name": "Aster"},
		"3": {"public_id": "ally_a", "display_name": "Bram"},
		"4": {"public_id": "ally_b", "display_name": "Cleo"},
		"5": {"public_id": "peer_d", "display_name": "Dax"}
	}
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.players = [2, 3, 4, 5]
	manager.profile_cards_by_peer = {2: cards["2"], 3: cards["3"], 4: cards["4"], 5: cards["5"]}
	var snapshot := manager.build_gameplay_signal_snapshot(cards, profile)
	var relationship_model: Dictionary = Dictionary(snapshot.get("relationship_model", {}))
	var group_model: Dictionary = Dictionary(snapshot.get("group_model", {}))
	if int(relationship_model.get("alliance_stability", 0)) < 3 or int(relationship_model.get("trust_fragility", 0)) < 2:
		failures.append("relationship embodiment seam should pull alliance stability and trust fragility into the host gameplay snapshot")
	for expected_signal in ["escort expectation", "rescue debt", "custody debt", "suspicion debt", "public obligation"]:
		if not Array(group_model.get("group_signals", [])).has(expected_signal):
			failures.append("relationship embodiment seam should make %s a real group gameplay signal" % expected_signal)
	var session_context := {
		"player_count": 4,
		"peer_ids": [2, 3, 4, 5],
		"protocol_state": "Fracture Protocol",
		"public_cards": cards.duplicate(true),
		"ready_state": {2: true, 3: true, 4: true, 5: true},
		"gameplay_snapshot": snapshot.duplicate(true)
	}
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 7711, 10)
	var contract: Dictionary = Dictionary(directive.get("generation_contract", {}))
	var relationship_routing: Dictionary = Dictionary(contract.get("relationship_routing", {}))
	if int(relationship_routing.get("escort_expectation", 0)) <= 0 or int(relationship_routing.get("witness_suspicion", 0)) <= 0:
		failures.append("explicit generation contract should carry relationship routing once trust topology is strong enough")
	var generator := RUN_GENERATOR_SCRIPT.new()
	var room := generator.branch_context_for_test(7711, 5, 10, "evidence", "none", contract)
	var visual_governance := VISUAL_GOVERNANCE_SCRIPT.new()
	var packet := visual_governance.room_visual_packet(room)
	var stagecraft: Dictionary = Dictionary(packet.get("stagecraft", {}))
	if not bool(stagecraft.get("escort_lane", false)) or not bool(stagecraft.get("rescue_convergence", false)):
		failures.append("relationship routing should change room stagecraft into escort and rescue-convergence geometry")
	if not bool(stagecraft.get("suspicious_distance", false)):
		failures.append("relationship routing should make suspicion debt visible through witness-distance stagecraft")
	var clean_manager := NETWORK_MANAGER_SCRIPT.new()
	clean_manager.current_generation_contract = {}
	var clean_ticks := clean_manager.extraction_window_ticks_for_test()
	var shaped_manager := NETWORK_MANAGER_SCRIPT.new()
	shaped_manager.current_generation_contract = contract.duplicate(true)
	var shaped_ticks := shaped_manager.extraction_window_ticks_for_test()
	if clean_ticks == shaped_ticks:
		failures.append("relationship routing should alter authoritative extraction timing rather than stopping at planner and lattice layers")
	manager.free()
	clean_manager.free()
	shaped_manager.free()

func _test_relay_crawl_network_embodiment(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Relay Embodiment", "public_id": "relay_embodiment"}
	}, catalog)
	profile["active_crawl"] = {
		"relay_stress": 3,
		"relay_memory": ["multiple crews are now pressing on the same crawl line"],
		"witness_network": ["distributed witnesses are now carrying different parts of the same story"],
		"relay_bottlenecks": ["the crawl is bottlenecking around one overloaded relay threshold"],
		"cohort_pressure": ["sub-cohorts are beginning to carry different duties through the same crawl"],
		"rumor_shock": ["rumor is outrunning proof across the wider expedition memory"]
	}
	profile["world_memory"] = Dictionary(profile.get("world_memory", {})).duplicate(true)
	var crawl_network_state: Dictionary = Dictionary(Dictionary(profile.get("world_memory", {})).get("crawl_network_state", {})).duplicate(true)
	crawl_network_state["relay_stress"] = 4
	crawl_network_state["witness_pressure"] = 2
	crawl_network_state["bottleneck_pressure"] = 2
	crawl_network_state["rumor_shock"] = 2
	crawl_network_state["cohort_pressure"] = 1
	profile["world_memory"]["crawl_network_state"] = crawl_network_state
	var session_context := {
		"player_count": 8,
		"peer_ids": [2, 3, 4, 5, 6, 7, 8, 9],
		"protocol_state": "Expedition Protocol",
		"public_cards": {
			"2": {"public_id": "relay_embodiment", "display_name": "Aster"},
			"3": {"public_id": "relay_b", "display_name": "Bram"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Expedition Protocol",
			"group_model": {
				"group_signals": ["relay chain", "distributed witness"],
				"fault_lines": ["crowd certainty fracture"],
				"model_pressure": ["relay load", "public memory shock"]
			}
		}
	}
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 8801, 10)
	var contract: Dictionary = Dictionary(directive.get("generation_contract", {}))
	var relay_routing: Dictionary = Dictionary(contract.get("relay_routing", {}))
	if int(relay_routing.get("relay_overload", 0)) <= 0 or int(relay_routing.get("distributed_witness", 0)) <= 0:
		failures.append("relay embodiment seam should carry relay overload and distributed witness through the explicit generation contract")
	var generator := RUN_GENERATOR_SCRIPT.new()
	var room := generator.branch_context_for_test(8801, 6, 10, "traversal", "none", contract)
	var packet := VISUAL_GOVERNANCE_SCRIPT.new().room_visual_packet(room)
	var stagecraft: Dictionary = Dictionary(packet.get("stagecraft", {}))
	if not bool(stagecraft.get("confrontation_triangle", false)) or not bool(stagecraft.get("suspicious_distance", false)):
		failures.append("relay embodiment seam should turn relay bottlenecks and witness spread into route-stagecraft pressure")
	var clean_manager := NETWORK_MANAGER_SCRIPT.new()
	var clean_watch := clean_manager.protocol_watch_interval_for_test(2)
	var clean_noise := clean_manager.noise_trace_interval_for_test(2)
	var clean_ticks := clean_manager.extraction_window_ticks_for_test()
	var shaped_manager := NETWORK_MANAGER_SCRIPT.new()
	shaped_manager.current_generation_contract = contract.duplicate(true)
	var shaped_watch := shaped_manager.protocol_watch_interval_for_test(2)
	var shaped_noise := shaped_manager.noise_trace_interval_for_test(2)
	var shaped_ticks := shaped_manager.extraction_window_ticks_for_test()
	if clean_watch == shaped_watch or clean_noise == shaped_noise or clean_ticks == shaped_ticks:
		failures.append("relay embodiment seam should change authoritative watch, rumor-trace, and return pressure instead of stopping at continuity memory")
	clean_manager.free()
	shaped_manager.free()

func _test_cookbook_anti_protocol_embodiment(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Cookbook Embodiment", "public_id": "cookbook_embodiment"}
	}, catalog)
	profile["cookbook_state"] = {
		"fragment_count": 3,
		"holder_depth": 2,
		"network_pressure": 2,
		"redirection_pressure": 2,
		"holder_state": "holder",
		"fragment_lines": ["forbidden marginalia keep collecting around anomalous runs"],
		"marginalia_lines": ["some descents are being remembered as ways around expected protocol pressure"],
		"network_lines": ["anti-Protocol recognition is now traveling by indirection"]
	}
	profile["world_memory"] = Dictionary(profile.get("world_memory", {})).duplicate(true)
	profile["world_memory"]["cookbook_shadow"] = {
		"fragment_heat": 2,
		"holder_rumor": 1,
		"network_rumor": 1,
		"redirection_pressure": 2,
		"lines": ["forbidden marginalia are beginning to recur around anomalous descents"],
		"rumor_lines": ["holder rumor is moving through the margins"],
		"redirection_lines": ["some descents are now remembered as ways around expected protocol pressure"]
	}
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Intimate Protocol",
		"public_cards": {
			"2": {"public_id": "cookbook_embodiment", "display_name": "Aster"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Intimate Protocol",
			"group_model": {
				"group_signals": ["counter-reading residue"],
				"fault_lines": ["private line under strain"],
				"model_pressure": ["counter-reading pressure"]
			}
		}
	}
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 9901, 10)
	var contract: Dictionary = Dictionary(directive.get("generation_contract", {}))
	var cookbook_routing: Dictionary = Dictionary(contract.get("cookbook_routing", {}))
	if int(cookbook_routing.get("fragmentary_reading", 0)) <= 0 or int(cookbook_routing.get("anti_protocol_pull", 0)) <= 0:
		failures.append("cookbook embodiment seam should carry fragmentary reading and anti-Protocol pull through the explicit generation contract")
	var generator := RUN_GENERATOR_SCRIPT.new()
	var room := generator.branch_context_for_test(9901, 5, 10, "evidence", "none", contract)
	var packet := VISUAL_GOVERNANCE_SCRIPT.new().room_visual_packet(room)
	var stagecraft: Dictionary = Dictionary(packet.get("stagecraft", {}))
	if not bool(stagecraft.get("carrier_isolation", false)) or not bool(stagecraft.get("suspicious_distance", false)):
		failures.append("cookbook embodiment seam should turn redirection pressure into altered room-stagecraft conditions")
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var anti_bonus := item_service.directive_bonus_for_item_for_test("lantern_snuffer", contract, room)
	var clean_bonus := item_service.directive_bonus_for_item_for_test("lantern_snuffer", {}, room)
	if anti_bonus <= clean_bonus:
		failures.append("cookbook embodiment seam should materially raise anti-Protocol-capable item weighting above the clean-contract baseline")
	var clean_manager := NETWORK_MANAGER_SCRIPT.new()
	var clean_watch := clean_manager.protocol_watch_interval_for_test(2)
	var clean_ticks := clean_manager.extraction_window_ticks_for_test()
	var shaped_manager := NETWORK_MANAGER_SCRIPT.new()
	shaped_manager.current_generation_contract = contract.duplicate(true)
	var shaped_watch := shaped_manager.protocol_watch_interval_for_test(2)
	var shaped_ticks := shaped_manager.extraction_window_ticks_for_test()
	if clean_watch == shaped_watch or clean_ticks == shaped_ticks:
		failures.append("cookbook embodiment seam should alter authoritative watch and extraction pressure instead of staying continuity-only")
	clean_manager.free()
	shaped_manager.free()

func _test_civilization_conflict_embodiment_diverges(failures: Array[String]) -> void:
	var base_contract := {
		"protocol_state": "Fracture Protocol",
		"doctrine_family": "delve_trial",
		"branch_family": "watcher_steps",
		"dominant_forces": ["Trial", "Memory"],
		"dominant_minds": ["Examiner", "Archivist"],
		"pacing_profile": "steady",
		"pressure_verbs": ["Exposure"],
		"symbolic_motifs": ["Threshold Marks"],
		"item_ecology_bias": "rescue burden",
		"group_tension_bias": "trust fragility",
		"archive_tone": "measured memory",
		"convergence_axis": "custody"
	}
	var legitimacy_contract := base_contract.duplicate(true)
	legitimacy_contract["civilization_routing"] = {"legitimacy_custody": 1}
	var taboo_contract := base_contract.duplicate(true)
	taboo_contract["civilization_routing"] = {"taboo_silence": 1}
	var canon_contract := base_contract.duplicate(true)
	canon_contract["civilization_routing"] = {"canon_conflict": 1}
	var sacred_contract := base_contract.duplicate(true)
	sacred_contract["civilization_routing"] = {"sacred_order": 1}
	var mourning_contract := base_contract.duplicate(true)
	mourning_contract["civilization_routing"] = {"mourning_climate": 1}
	var ontology_contract := base_contract.duplicate(true)
	ontology_contract["civilization_routing"] = {"ontology_heat": 1}
	var generator := RUN_GENERATOR_SCRIPT.new()
	var legitimacy_room := generator.branch_context_for_test(10021, 5, 10, "evidence", "none", legitimacy_contract)
	var taboo_room := generator.branch_context_for_test(10022, 5, 10, "evidence", "none", taboo_contract)
	var canon_room := generator.branch_context_for_test(10023, 5, 10, "evidence", "none", canon_contract)
	var sacred_room := generator.branch_context_for_test(10024, 5, 10, "evidence", "none", sacred_contract)
	var mourning_room := generator.branch_context_for_test(10025, 5, 10, "evidence", "none", mourning_contract)
	var ontology_room := generator.branch_context_for_test(10026, 5, 10, "evidence", "none", ontology_contract)
	var visual_governance := VISUAL_GOVERNANCE_SCRIPT.new()
	var legitimacy_stagecraft: Dictionary = Dictionary(visual_governance.room_visual_packet(legitimacy_room).get("stagecraft", {}))
	var taboo_stagecraft: Dictionary = Dictionary(visual_governance.room_visual_packet(taboo_room).get("stagecraft", {}))
	var canon_stagecraft: Dictionary = Dictionary(visual_governance.room_visual_packet(canon_room).get("stagecraft", {}))
	var sacred_stagecraft: Dictionary = Dictionary(visual_governance.room_visual_packet(sacred_room).get("stagecraft", {}))
	var mourning_stagecraft: Dictionary = Dictionary(visual_governance.room_visual_packet(mourning_room).get("stagecraft", {}))
	var ontology_stagecraft: Dictionary = Dictionary(visual_governance.room_visual_packet(ontology_room).get("stagecraft", {}))
	if not bool(legitimacy_stagecraft.get("escort_lane", false)) or not bool(sacred_stagecraft.get("escort_lane", false)):
		failures.append("legitimacy/custody and sacred-order pressure should diverge toward escort-style route conditions")
	if not bool(taboo_stagecraft.get("carrier_isolation", false)):
		failures.append("taboo/silence pressure should diverge toward isolated carry conditions")
	if not bool(canon_stagecraft.get("confrontation_triangle", false)):
		failures.append("canon conflict should diverge toward confrontation-heavy route conditions")
	if not bool(mourning_stagecraft.get("suspicious_distance", false)):
		failures.append("mourning climate should diverge toward hesitation-distance conditions")
	if not bool(ontology_stagecraft.get("confrontation_triangle", false)) or not bool(ontology_stagecraft.get("suspicious_distance", false)):
		failures.append("ontology heat should diverge toward unstable witness and confrontation conditions")
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var legitimacy_bonus := item_service.directive_bonus_for_item_for_test("timeline_bookmark", legitimacy_contract, legitimacy_room)
	var taboo_bonus := item_service.directive_bonus_for_item_for_test("lantern_snuffer", taboo_contract, taboo_room)
	var canon_bonus := item_service.directive_bonus_for_item_for_test("decoy_emitter", canon_contract, canon_room)
	var sacred_bonus := item_service.directive_bonus_for_item_for_test("timeline_bookmark", sacred_contract, sacred_room)
	var mourning_bonus := item_service.directive_bonus_for_item_for_test("zipline_kit", mourning_contract, mourning_room)
	var ontology_bonus := item_service.directive_bonus_for_item_for_test("lantern_snuffer", ontology_contract, ontology_room)
	if legitimacy_bonus <= item_service.directive_bonus_for_item_for_test("timeline_bookmark", {}, legitimacy_room):
		failures.append("legitimacy/custody pressure should materially favor custody-readable tools")
	if taboo_bonus <= item_service.directive_bonus_for_item_for_test("lantern_snuffer", {}, taboo_room):
		failures.append("taboo/silence pressure should materially favor unstable anti-Protocol tools")
	if canon_bonus <= item_service.directive_bonus_for_item_for_test("decoy_emitter", {}, canon_room):
		failures.append("canon conflict should materially favor deceptive witness-shaping tools")
	if sacred_bonus <= item_service.directive_bonus_for_item_for_test("timeline_bookmark", {}, sacred_room):
		failures.append("sacred/order pressure should materially favor ritual-custody tools")
	if mourning_bonus <= item_service.directive_bonus_for_item_for_test("zipline_kit", {}, mourning_room):
		failures.append("mourning climate should materially favor rescue-route tools")
	if ontology_bonus <= item_service.directive_bonus_for_item_for_test("lantern_snuffer", {}, ontology_room):
		failures.append("ontology heat should materially favor unstable counter-reading tools")
	var clean_manager := NETWORK_MANAGER_SCRIPT.new()
	var clean_watch := clean_manager.protocol_watch_interval_for_test(2)
	var clean_ticks := clean_manager.extraction_window_ticks_for_test()
	var taboo_manager := NETWORK_MANAGER_SCRIPT.new()
	taboo_manager.current_generation_contract = taboo_contract.duplicate(true)
	var canon_manager := NETWORK_MANAGER_SCRIPT.new()
	canon_manager.current_generation_contract = canon_contract.duplicate(true)
	var ontology_manager := NETWORK_MANAGER_SCRIPT.new()
	ontology_manager.current_generation_contract = ontology_contract.duplicate(true)
	if taboo_manager.protocol_watch_interval_for_test(2) == clean_watch or canon_manager.noise_trace_interval_for_test(2) == clean_manager.noise_trace_interval_for_test(2) or ontology_manager.extraction_window_ticks_for_test() == clean_ticks:
		failures.append("civilization conflict seam should create divergent runtime watch/noise/extraction pressure across the major cultural families")
	clean_manager.free()
	taboo_manager.free()
	canon_manager.free()
	ontology_manager.free()

func _test_role_deception_and_artifact_custody_embodiment(failures: Array[String]) -> void:
	var clean_manager := NETWORK_MANAGER_SCRIPT.new()
	clean_manager.is_host = true
	clean_manager.players = [2, 3, 4]
	clean_manager.roles_by_peer = {
		2: ROLE_SERVICE_SCRIPT.ROLE_VEIL,
		3: ROLE_SERVICE_SCRIPT.ROLE_WARDEN,
		4: ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER
	}
	clean_manager.player_room_by_peer = {2: 3, 3: 3, 4: 3}
	clean_manager.player_pos_by_peer = {
		2: Vector2(120, 100),
		3: Vector2(126, 100),
		4: Vector2(132, 100)
	}
	clean_manager.extraction_room_slot = 6
	var clean_watch := clean_manager.protocol_watch_interval_for_test(2)
	var clean_noise := clean_manager.noise_trace_interval_for_test(2)
	var clean_ticks := clean_manager.extraction_window_ticks_for_test()

	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	manager.current_server_tick = 180
	manager.players = [2, 3, 4]
	manager.roles_by_peer = clean_manager.roles_by_peer.duplicate(true)
	manager.player_room_by_peer = clean_manager.player_room_by_peer.duplicate(true)
	manager.player_pos_by_peer = clean_manager.player_pos_by_peer.duplicate(true)
	manager.extraction_room_slot = 6
	manager.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 4, "room_slot": 3, "world_pos": Vector2(132, 100), "is_forged": false, "signature": "A0000101", "spawn_index": 0}
	}
	manager.next_artifact_id = 2
	manager.begin_event_capture_for_test()
	manager.host_steal_for_test(2, 1)
	manager.host_drop_for_test(2)
	manager.host_forge_for_test(2, 3)
	manager.host_pickup_for_test(2, 2)
	manager.host_check_artifact_for_test(3, 2)
	var captured := manager.end_event_capture_for_test()
	var runtime := manager.get_role_custody_runtime_for_test(2)
	if int(runtime.get("custody_debt", 0)) <= 0 or int(runtime.get("suspicion_heat", 0)) <= 0 or int(runtime.get("counterfeit_heat", 0)) <= 0:
		failures.append("role/custody embodiment should turn steals, drops, forges, and checks into host-side custody and suspicion pressure")
	if manager.protocol_watch_interval_for_test(2) >= clean_watch:
		failures.append("role/custody embodiment should materially tighten protocol watch pressure on volatile Veil custody")
	if manager.noise_trace_interval_for_test(2) >= clean_noise:
		failures.append("role/custody embodiment should materially tighten artifact noise pressure on volatile custody")
	if manager.extraction_window_ticks_for_test() <= clean_ticks:
		failures.append("role/custody embodiment should materially lengthen extraction pressure once counterfeit custody debt accumulates")
	if manager.choose_protocol_watch_peer_for_test() != 2:
		failures.append("role/custody embodiment should make the volatile carrier the preferred protocol-watch target")
	if manager.choose_predator_target_peer_for_test() != 2:
		failures.append("role/custody embodiment should make the volatile carrier a stronger predator target under the existing ecology owner path")
	var public_types: Array[String] = []
	for event_raw in Array(captured.get("public", [])):
		public_types.append(str(Dictionary(event_raw).get("event_type", "")))
	for required_type in ["artifact_stolen", "artifact_spawned"]:
		if not public_types.has(required_type):
			failures.append("role/custody embodiment should stay on the normal host event path for %s" % required_type)
	if Array(captured.get("private", [])).is_empty():
		failures.append("role/custody embodiment should preserve the normal private event path for checks, notes, and denials")
	manager.free()
	clean_manager.free()

func _test_delve_intelligence_kernel_governance(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {
			"display_name": "Kernel Delver",
			"public_id": "delver_kernel"
		}
	}, catalog)
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Rescue build",
				"group_signals": ["rescue geometry", "route control"],
				"fault_lines": ["shared caution"],
				"model_pressure": ["rescue geometry"],
				"protocol_weighting": "fracture attention"
			}
		}
	}
	var directive_a := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 9091, 15)
	var directive_b := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 9091, 15)
	if JSON.stringify(directive_a) != JSON.stringify(directive_b):
		failures.append("delve kernel directives should remain deterministic for identical profile and session state")
	if str(directive_a.get("doctrine_family", "")).strip_edges().is_empty():
		failures.append("delve kernel should always choose a doctrine family")
	var run_identity: Dictionary = Dictionary(directive_a.get("run_identity", {}))
	if Dictionary(run_identity.get("force_profile", {})).is_empty() or Array(run_identity.get("active_minds", [])).is_empty():
		failures.append("delve kernel should emit a structured run identity trace for balancing and debug inspection")
	if Array(run_identity.get("pressure_grammar", [])).is_empty() or str(Dictionary(run_identity.get("pacing_profile", {})).get("id", "")).strip_edges().is_empty():
		failures.append("run identity traces should include pacing and pressure grammar outputs")
	if Dictionary(run_identity.get("mind_roles", {})).is_empty() or Dictionary(run_identity.get("mind_moods", {})).is_empty():
		failures.append("run identity traces should retain mind role and mood breakdowns")
	if Dictionary(run_identity.get("domain_influence_weights", {})).is_empty() or Dictionary(run_identity.get("readability_budget", {})).is_empty():
		failures.append("run identity traces should retain bounded domain-weight and readability-budget detail")
	if str(Dictionary(directive_a.get("public_summary", {})).get("pressure_line", "")).strip_edges().is_empty():
		failures.append("delve kernel should expose a public-safe directive pressure summary")
	if Array(Dictionary(directive_a.get("public_summary", {})).get("dominant_forces", [])).is_empty() or Array(Dictionary(directive_a.get("public_summary", {})).get("dominant_domains", [])).is_empty():
		failures.append("delve kernel should expose bounded dominant force and domain carryover in the public summary")
	if Array(Dictionary(directive_a.get("public_summary", {})).get("symbolic_motifs", [])).is_empty() or str(Dictionary(directive_a.get("public_summary", {})).get("convergence_axis", "")).strip_edges().is_empty():
		failures.append("delve kernel should expose symbolic and convergence carryover in the public summary")
	if str(Dictionary(directive_a.get("public_summary", {})).get("item_ecology_bias", "")).strip_edges().is_empty() or str(Dictionary(directive_a.get("public_summary", {})).get("archive_tone", "")).strip_edges().is_empty():
		failures.append("delve kernel should expose public-safe item and archive interpretation carryover")
	if not Array(Dictionary(directive_a.get("causal_audit", {})).get("violations", [])).is_empty():
		failures.append("delve kernel directives should pass constitution validation before emission")

	var generator := RUN_GENERATOR_SCRIPT.new()
	var chain := generator.generate_layout(9091, 15, directive_a)
	if chain.is_empty():
		failures.append("delve kernel directives should remain consumable by generation")
	else:
		var first_room: Dictionary = Dictionary(chain[0])
		var branch_context: Dictionary = Dictionary(first_room.get("branch_context", {}))
		var branch_surface_summary: Dictionary = Dictionary(branch_context.get("surface_summary", {}))
		if str(first_room.get("doctrine_family", "")).strip_edges().is_empty():
			failures.append("generation should thread kernel doctrine context into room chain output")
		if str(first_room.get("protocol_state", "")).strip_edges().is_empty():
			failures.append("generation should thread kernel protocol context into room chain output")
		if Dictionary(branch_context.get("run_identity_summary", {})).is_empty():
			failures.append("generation should expose a bounded run-identity summary through branch context")
		if not branch_surface_summary.has("lines"):
			failures.append("generation should only thread line-level surface summaries into replicated branch context")
		if branch_surface_summary.has("strongest") or branch_surface_summary.has("clamped"):
			failures.append("generation should not leak host-only surface-summary internals into branch context")
		if branch_context.has("world_goals"):
			failures.append("generation should not leak planner world-goal arrays into replicated branch context")

	var item_service := ITEM_SERVICE_SCRIPT.new()
	var spawns_a: Array = item_service.generate_item_spawns(9091, chain, directive_a)
	var spawns_b: Array = item_service.generate_item_spawns(9091, chain, directive_a)
	if JSON.stringify(spawns_a) != JSON.stringify(spawns_b):
		failures.append("directive-shaped item spawns should remain deterministic")
	var item_defs: Array[String] = []
	for spawn_raw in spawns_a:
		var spawn: Dictionary = Dictionary(spawn_raw)
		var item_id := str(spawn.get("item_def_id", "")).strip_edges()
		if not item_id.is_empty() and not item_defs.has(item_id):
			item_defs.append(item_id)
	item_defs = item_defs.slice(0, mini(item_defs.size(), 4))
	if item_defs.is_empty():
		item_defs = ["timeline_bookmark", "lantern_snuffer", "zipline_kit"]

	var gameplay_snapshot := {
		"protocol_state": "Fracture Protocol",
		"group_model": {
			"dominant_build": "Rescue build",
			"group_signals": ["rescue geometry", "route control"],
			"fault_lines": ["shared caution"],
			"model_pressure": ["rescue geometry"],
			"protocol_weighting": "fracture attention"
		},
		"peer_models": {
			"delver_A": {
				"build_identity": "Rescue build",
				"build_scores": {"Rescue build": 6, "Control build": 3},
				"behavior_signals": ["route commitment", "rescue answer geometry"],
				"synergy_labels": ["commitment rescue line"],
				"ritual_hooks": ["threshold repeat"],
				"anomaly_hooks": ["echo instability"],
				"protocol_hooks": ["fracture caution"],
				"resource_signals": ["fallback tool pressure"],
				"inhabitant_signals": ["pursuit pressure"],
				"feature_signals": ["rescue geometry", "route control"],
				"model_pressure": ["rescue geometry"],
				"build_stability": "stable",
				"risk_profile": "committed"
			}
		},
		"build_identities": ["Rescue build"],
		"resource_pressure": ["fallback tool pressure"],
		"inhabitant_pressure": ["pursuit pressure"]
	}

	var run_record := {
		"seed": 9091,
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"local_peer_id": 2,
		"local_peer_public_id": "delver_A",
		"room_chain": chain,
		"room_families": ["evidence", "hazard", "traversal"],
		"peer_identities": {
			2: {"public_id": "delver_A", "display_name": "Aster"},
			3: {"public_id": "delver_B", "display_name": "Bram"},
			4: {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"timeline_public_events": [
			{"event_id": 1, "tick": 12, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 19, "room_slot": 1, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 27, "room_slot": 2, "actor_peer_id": 2, "event_type": "item_used", "visibility": "public", "meta": {"label": "timeline_bookmark"}},
			{"event_id": 4, "tick": 49, "room_slot": 3, "actor_peer_id": 2, "event_type": "extraction_completed", "visibility": "public", "meta": {}}
		],
		"action_summary": ["The route answered through rescue geometry", "The doctrine kept narrowing the same answer line"],
		"communication_summary": {"total": 4, "danger": 2, "regroup": 1, "artifact": 2},
		"outcome_summary": {"summary_text": "Recovered under directed pressure", "artifact_result_text": "Authentic artifact extracted", "artifact_result": "authentic", "expedition_success": true, "sabotage_success": false},
		"stats": {"notes_count": 2, "pinned_count": 1, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"report_path": "user://reports/delve_kernel_9091.txt",
		"item_defs": item_defs,
		"artifact_states": ["authentic"],
		"roles": [ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER],
		"clue_families": ["artifact_handoff"],
		"gameplay_signal_snapshot": gameplay_snapshot,
		"delve_directive_summary": directive_a
	}

	var applied := Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog).get("profile", {}))
	var last_run: Dictionary = Dictionary(applied.get("last_run", {}))
	var diagnostics: Dictionary = Dictionary(last_run.get("diagnostics", {}))
	if str(diagnostics.get("doctrine_family", "")).strip_edges().is_empty() or str(diagnostics.get("doctrine_label", "")).strip_edges().is_empty():
		failures.append("kernel doctrine directives should propagate into diagnostics")
	if str(diagnostics.get("doctrine_pressure_line", "")).strip_edges().is_empty():
		failures.append("kernel doctrine directives should propagate a pressure line into diagnostics")
	var frame: Dictionary = Dictionary(last_run.get("frame", {}))
	if str(frame.get("doctrine_line", "")).strip_edges().is_empty() or str(frame.get("governance_line", "")).strip_edges().is_empty():
		failures.append("kernel doctrine directives should surface in the public frame")
	if str(frame.get("governance_line", "")).find("Surface:") == -1 and str(frame.get("governance_line", "")).find("Axis:") == -1:
		failures.append("kernel governance framing should keep compact surface or convergence carryover readable when available")
	if str(frame.get("governance_line", "")).find("|") != -1:
		failures.append("kernel governance framing should prefer compact readable clauses over pipe chains")
	if diagnostics.has("directive_surface_details"):
		failures.append("product diagnostics should not retain full directive surface-detail payloads")

	var crawl_text := "\n".join(CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(applied))
	if crawl_text.find("Doctrine:") == -1 or crawl_text.find("Governance:") == -1:
		failures.append("crawl continuity should retain doctrine and governance memory once the kernel is live")

	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(applied, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("archive cases should still build after kernel directive propagation")
	else:
		var archive_detail := str(Dictionary(archive_entries[0]).get("detail", ""))
		if archive_detail.find("Doctrine:") == -1 or archive_detail.find("Governance:") == -1:
			failures.append("archive case detail should surface doctrine and governance context after kernel propagation")

	var home_text := "\n".join(PROFILE_SERVICE_SCRIPT.build_home_overview_lines(applied))
	if home_text.find("Doctrine:") == -1 and home_text.find("World pressure:") == -1:
		failures.append("home overview should expose doctrine or governance carryover after kernel propagation")

	var public_card := PROFILE_SERVICE_SCRIPT.build_public_identity_card(applied, catalog)
	if str(public_card.get("challenge_hint", "")).strip_edges().is_empty():
		failures.append("public identity cards should retain carryover challenge pressure after kernel propagation")

	var poisoned_run_record: Dictionary = run_record.duplicate(true)
	var poisoned_directive: Dictionary = directive_a.duplicate(true)
	poisoned_directive["run_identity"] = {
		"pacing_profile": {"label": "run_identity leak"},
		"symbolic_motifs": [{"label": "run_identity motif leak"}]
	}
	poisoned_directive["mind_balance"] = {"notes": ["mind_balance leak"]}
	poisoned_directive["causal_audit"] = {"planner": "planner leak", "violations": ["causal_audit leak"]}
	poisoned_directive["world_goals"] = ["world_goals leak"]
	Dictionary(poisoned_directive.get("surface_summary", {}))["strongest"] = [{"label": "strongest leak", "value": 2}]
	Dictionary(poisoned_directive.get("surface_summary", {}))["clamped"] = {"generation": {"witness_exposure": 2}}
	poisoned_run_record["delve_directive_summary"] = poisoned_directive
	var poisoned_applied := Dictionary(PROFILE_SERVICE_SCRIPT.apply_run_record(profile, poisoned_run_record, catalog).get("profile", {}))
	var poisoned_last_run: Dictionary = Dictionary(poisoned_applied.get("last_run", {}))
	var poisoned_diagnostics: Dictionary = Dictionary(poisoned_last_run.get("diagnostics", {}))
	var poisoned_frame: Dictionary = Dictionary(poisoned_last_run.get("frame", {}))
	var poisoned_archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(poisoned_applied, "archive_cases", catalog)
	var poisoned_text := JSON.stringify(poisoned_diagnostics) + "\n" + JSON.stringify(poisoned_frame) + "\n" + "\n".join(PROFILE_SERVICE_SCRIPT.build_home_overview_lines(poisoned_applied, {}, catalog))
	if not poisoned_archive_entries.is_empty():
		poisoned_text += "\n" + str(Dictionary(poisoned_archive_entries[0]).get("detail", ""))
	for banned in ["run_identity leak", "mind_balance leak", "planner leak", "causal_audit leak", "world_goals leak", "strongest leak"]:
		if poisoned_text.to_lower().find(banned.to_lower()) != -1:
			failures.append("product framing and archive outputs should ignore host-only Delve internals and planner leakage")
	if poisoned_diagnostics.has("directive_surface_details"):
		failures.append("sanitized product diagnostics should not recreate stripped surface-detail payloads")
	if Array(poisoned_diagnostics.get("directive_surface_summary", [])).is_empty():
		failures.append("sanitized product diagnostics should still retain public-safe governance summary lines")

func _test_doctrine_schema_registry_and_phase_groundwork(failures: Array[String]) -> void:
	var registry_failures := DOCTRINE_SCHEMA_REGISTRY_SCRIPT.validate_registry()
	if not registry_failures.is_empty():
		failures.append("doctrine schema registry should validate shipped doctrine schemas and catalogs: %s" % "; ".join(registry_failures))
	var constitution_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.constitution_schema()
	if not Array(constitution_schema.get("required_sections", [])).has("compile_metadata"):
		failures.append("constitution schema should require compile_metadata once the constitution compiler is live")
	if not Array(constitution_schema.get("required_generation_surface_keys", [])).has("ontology_routing"):
		failures.append("constitution schema should require ontology_routing once the ontology engine is live")
	if not Array(constitution_schema.get("required_symbolic_fields", [])).has("fairness_bounds"):
		failures.append("constitution schema should require fairness_bounds once the compiler phase is materially complete")
	if not Array(constitution_schema.get("required_sections", [])).has("narrative_pressure_state"):
		failures.append("constitution schema should require narrative_pressure_state once Phase 5 becomes live")
	var narrative_pressure_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.narrative_pressure_schema()
	if not Array(narrative_pressure_schema.get("required_axes", [])).has("stability"):
		failures.append("narrative pressure schema should require the doctrine pressure axes once Phase 5 is live")
	if not Array(narrative_pressure_schema.get("allowed_outputs", [])).has("constitution_bias"):
		failures.append("narrative pressure schema should allow constitution_bias as a lawful non-runtime output")
	if not Array(narrative_pressure_schema.get("forbidden_runtime_fields", [])).has("runtime_state"):
		failures.append("narrative pressure schema should explicitly forbid runtime-only fields")
	var experiment_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.experiment_schema()
	for key in ["hypothesis_required_fields", "experiment_required_fields", "grammar_slots", "allowed_persistence_states", "allowed_compile_targets", "forbidden_runtime_fields"]:
		if not experiment_schema.has(key):
			failures.append("experiment schema should expose %s once Phase 6 is live" % key)
	if not Array(experiment_schema.get("allowed_persistence_states", [])).has("foundational"):
		failures.append("experiment schema should allow foundational persistence for doctrine lineage carryover")
	if not Array(experiment_schema.get("allowed_compile_targets", [])).has("pressure_input_bias"):
		failures.append("experiment schema should allow bounded pressure_input_bias for Phase 6")
	for required_target in ["operators", "institutions", "publics", "archive_systems", "taxonomy_systems", "artifact_careers", "ontology_itself", "mixed_civilizational_layers"]:
		if not Array(experiment_schema.get("allowed_targets", [])).has(required_target):
			failures.append("experiment schema should expose doctrine target %s" % required_target)
	for required_axis in ["trust", "authority_dependence", "ambiguity_tolerance", "curiosity", "fear", "ritual_reliance", "stewardship", "greed", "legitimacy_formation", "classification_hunger", "wonder_receptivity", "memory_fidelity"]:
		if not Array(experiment_schema.get("allowed_axes", [])).has(required_axis):
			failures.append("experiment schema should expose doctrine axis %s" % required_axis)
	for required_stressor in ["scarcity", "lesion_surfacing", "counterfeit_pressure", "taxonomy_split", "rediscovery", "hybridization", "prestige_shock", "rumor_acceleration", "fossil_activation", "anomaly_cluster", "public_schism"]:
		if not Array(experiment_schema.get("allowed_stressors", [])).has(required_stressor):
			failures.append("experiment schema should expose doctrine stressor %s" % required_stressor)
	for required_condition in ["stable_categories", "contested_categories", "category_split", "niche_overcrowding", "hybrid_lineage_emergence", "fossil_density_increase", "rediscovered_extinct_categories"]:
		if not Array(experiment_schema.get("allowed_ontology_conditions", [])).has(required_condition):
			failures.append("experiment schema should expose doctrine ontology condition %s" % required_condition)
	for required_medium in ["archive_framing", "rumor_ecology", "civic_response", "public_naming", "legend_pressure", "market_reaction", "codex_conflict", "chamber_reputation_drift"]:
		if not Array(experiment_schema.get("allowed_cultural_media", [])).has(required_medium):
			failures.append("experiment schema should expose doctrine cultural medium %s" % required_medium)
	for required_horizon in ["expedition", "run_cluster", "season", "era"]:
		if not Array(experiment_schema.get("allowed_time_horizons", [])).has(required_horizon):
			failures.append("experiment schema should expose doctrine time horizon %s" % required_horizon)
	for required_contract in ["extraction_behavior", "verification_use", "legitimacy_movement", "archive_relabeling", "rumor_uptake", "public_divergence", "category_adoption", "canonized_failure_formation", "wonder_retention"]:
		if not Array(experiment_schema.get("allowed_observation_contracts", [])).has(required_contract):
			failures.append("experiment schema should expose doctrine observation contract %s" % required_contract)
	for required_topology in ["linear", "branching", "nested", "recursive", "convergent", "oscillatory"]:
		if not Array(experiment_schema.get("allowed_topology_types", [])).has(required_topology):
			failures.append("experiment schema should expose doctrine topology %s" % required_topology)
	for required_mode in ["whisper_mode", "fracture_mode", "crisis_mode", "renaissance_mode", "fossil_mode", "mirror_mode"]:
		if not Array(experiment_schema.get("allowed_expression_modes", [])).has(required_mode):
			failures.append("experiment schema should expose doctrine expression mode %s" % required_mode)
	for required_target in ["constitution_weighting", "ontology_weighting", "artifact_career_pressure", "pressure_ecosystem_bias", "pressure_input_bias", "archive_framing_bias", "public_activation", "legitimacy_stress", "rumor_volatility", "wonder_allocation"]:
		if not Array(experiment_schema.get("allowed_compile_targets", [])).has(required_target):
			failures.append("experiment schema should expose doctrine compile target %s" % required_target)
	for required_section in ["constitution_weighting", "ontology_weighting", "pressure_input_bias", "archive_framing_bias", "public_activation"]:
		if not Array(experiment_schema.get("supported_compile_output_sections", [])).has(required_section):
			failures.append("experiment schema should expose supported compile output section %s" % required_section)
	for banned_section in ["legitimacy_stress", "rumor_volatility", "wonder_allocation"]:
		if Array(experiment_schema.get("supported_compile_output_sections", [])).has(banned_section):
			failures.append("experiment schema should keep %s out of supported compile output sections until a later doctrine phase wires it lawfully" % banned_section)
	var doctrine_families := DOCTRINE_SCHEMA_REGISTRY_SCRIPT.doctrine_families()
	if doctrine_families.size() < 6:
		failures.append("doctrine family catalog should expose the live doctrine families for compiler inheritance")
	var custody_ritual: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.doctrine_family("custody_ritual")
	if str(custody_ritual.get("lineage_id", "")).strip_edges().is_empty():
		failures.append("doctrine family catalog should expose lineage ownership for constitution compilation")
	if Array(custody_ritual.get("niches", [])).is_empty():
		failures.append("doctrine family catalog should expose doctrine niches for ontology routing")
	if DOCTRINE_SCHEMA_REGISTRY_SCRIPT.experiment_families().size() < 10:
		failures.append("phase groundwork should now ship the full Phase 6 experiment family catalog")
	for required_family_id in ["palimpsest", "negative_space", "echo_literacy", "contraband_lite"]:
		var found_family := false
		for family_raw in DOCTRINE_SCHEMA_REGISTRY_SCRIPT.experiment_families():
			if str(Dictionary(family_raw).get("id", "")).strip_edges() == required_family_id:
				found_family = true
				break
		if not found_family:
			failures.append("phase groundwork should expose curated phenomenon family %s" % required_family_id)

func _test_wave1_schema_registry_with_new_doctrine_contracts(failures: Array[String]) -> void:
	var registry_failures := DOCTRINE_SCHEMA_REGISTRY_SCRIPT.validate_registry()
	if not registry_failures.is_empty():
		failures.append("Wave 1 doctrine schema registry should validate all structural doctrine contracts: %s" % "; ".join(registry_failures))
	var constitution_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.constitution_schema()
	for field in ["lineage_registry", "civilization_surface", "cognitive_field_state", "mind_projections", "theory_surface", "activation_state", "explanation_packet", "review_surface"]:
		if not _string_array_for_test(Array(constitution_schema.get("required_symbolic_fields", []))).has(field):
			failures.append("Wave 1 constitution schema should require symbolic field %s" % field)
	for schema in [
		DOCTRINE_SCHEMA_REGISTRY_SCRIPT.lineage_schema(),
		DOCTRINE_SCHEMA_REGISTRY_SCRIPT.inquiry_schema(),
		DOCTRINE_SCHEMA_REGISTRY_SCRIPT.cognitive_field_schema(),
		DOCTRINE_SCHEMA_REGISTRY_SCRIPT.civilization_schema(),
		DOCTRINE_SCHEMA_REGISTRY_SCRIPT.governance_schema(),
		DOCTRINE_SCHEMA_REGISTRY_SCRIPT.archive_schema(),
		DOCTRINE_SCHEMA_REGISTRY_SCRIPT.cookbook_schema()
	]:
		if str(Dictionary(schema).get("schema_name", "")).strip_edges().is_empty():
			failures.append("Wave 1 doctrine schemas should all expose schema_name")

func _test_wave1_profile_v3_additive_migration(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var legacy_profile := {
		"schema_version": 2,
		"account": {
			"display_name": "Legacy Delver",
			"public_id": "legacy_delver"
		},
		"career_stats": {
			"notes_written": 3
		},
		"world_memory": {},
		"archive_state": {},
		"cookbook_state": {},
		"delvemind_experiment_state": {},
		"last_run": {},
		"run_history": []
	}
	var normalized := PROFILE_SERVICE_SCRIPT.normalize_profile(legacy_profile, catalog)
	if int(normalized.get("schema_version", 0)) != 3:
		failures.append("Wave 1 profile migration should bump schema_version to 3 additively")
	if str(Dictionary(normalized.get("account", {})).get("display_name", "")).strip_edges() != "Legacy Delver":
		failures.append("Wave 1 profile migration should preserve legacy account data")
	if Dictionary(normalized.get("governance_state", {})).is_empty():
		failures.append("Wave 1 profile migration should add governance_state without erasing prior data")
	if Dictionary(normalized.get("world_memory", {})).is_empty():
		failures.append("Wave 1 profile migration should still normalize world_memory")

func _test_wave1_constitution_v2_dormant_sections_hash_stability(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"ready_state": {2: true, 3: true, 4: true}
	}
	var constitution_a := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 17731, 10)
	var constitution_b := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 17731, 10)
	if int(constitution_a.get("schema_version", 0)) != 2:
		failures.append("Wave 1 constitutions should normalize to schema_version 2")
	if str(constitution_a.get("constitution_hash", "")).strip_edges() != str(constitution_b.get("constitution_hash", "")).strip_edges():
		failures.append("Wave 1 dormant doctrine sections should preserve constitution hash stability")
	for key in ["lineage_registry", "civilization_surface", "cognitive_field_state", "mind_projections", "theory_surface", "activation_state", "explanation_packet", "review_surface"]:
		if not constitution_a.has(key):
			failures.append("Wave 1 constitutions should carry %s structurally" % key)

func _test_wave1_governance_state_default_visibility(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	var governance_state: Dictionary = Dictionary(profile.get("governance_state", {}))
	var activation_state: Dictionary = Dictionary(governance_state.get("activation_state", {}))
	var safe_mode_state: Dictionary = Dictionary(governance_state.get("safe_mode_state", {}))
	if _string_array_for_test(Array(activation_state.get("active_channels", []))).is_empty():
		failures.append("Wave 1 governance defaults should expose active_channels")
	if _string_array_for_test(Array(activation_state.get("dormant_channels", []))).is_empty():
		failures.append("Wave 1 governance defaults should expose dormant_channels")
	if safe_mode_state.is_empty():
		failures.append("Wave 1 governance defaults should expose safe_mode_state even while inactive")

func _test_wave1_explanation_packet_presence_without_expression(failures: Array[String]) -> void:
	var runtime_constitution := EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.build_runtime_summary({
		"protocol_state": "Fracture Protocol",
		"doctrine_family": "measured_pressure",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Hold the route together.",
		"world_goal": "Return with the answer.",
		"surface_summary": {"lines": ["Public surface remains narrow."]}
	}, "wave1_runtime_hash")
	var explanation_packet: Dictionary = Dictionary(runtime_constitution.get("explanation_packet", {}))
	var review_surface: Dictionary = Dictionary(runtime_constitution.get("review_surface", {}))
	var public_summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(runtime_constitution)
	if str(explanation_packet.get("packet_id", "")).strip_edges().is_empty():
		failures.append("Wave 1 runtime constitutions should retain an explanation_packet even without high activation")
	if not public_summary.has("explanation_packet_lines"):
		failures.append("Wave 1 public summaries should expose explanation_packet_lines structurally")
	if not public_summary.has("review_surface_lines"):
		failures.append("Wave 1 public summaries should expose review_surface_lines structurally")
	if review_surface.is_empty():
		failures.append("Wave 1 runtime constitutions should retain review_surface even while higher layers stay dormant")

func _test_phase1_explanation_packet_v2_contract(failures: Array[String]) -> void:
	var runtime_constitution := EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.build_runtime_summary({
		"protocol_state": "Fracture Protocol",
		"doctrine_family": "measured_pressure",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Hold the route together.",
		"world_goal": "Return with the answer.",
		"surface_summary": {"lines": ["Public surface remains narrow."]}
	}, "phase1_packet_hash")
	var explanation_packet: Dictionary = Dictionary(runtime_constitution.get("explanation_packet", {}))
	if int(explanation_packet.get("packet_schema_version", 0)) < 2:
		failures.append("Phase 1 explanation packets should expose packet_schema_version 2")
	if str(explanation_packet.get("packet_digest", "")).strip_edges().is_empty():
		failures.append("Phase 1 explanation packets should expose packet_digest")
	if Dictionary(explanation_packet.get("compression_profile", {})).is_empty():
		failures.append("Phase 1 explanation packets should expose compression_profile")
	for lane_key in ["immediate", "run", "meta"]:
		if not explanation_packet.has(lane_key):
			failures.append("Phase 1 explanation packets should expose %s lane entries" % lane_key)
	var public_summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(runtime_constitution)
	for field in ["packet_schema_version", "explanation_packet_digest", "explanation_immediate_lines", "explanation_run_lines", "explanation_meta_lines", "signal_budget_lines"]:
		if not public_summary.has(field):
			failures.append("Phase 1 public summaries should expose %s structurally" % field)

func _test_phase1_forensic_bundle_contract(failures: Array[String]) -> void:
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 4,
		"event_id": 11,
		"event_type": "run_started",
		"room_slot": 0,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	event_log.add_event({
		"tick": 9,
		"event_id": 14,
		"event_type": "artifact_picked",
		"room_slot": 3,
		"actor_peer_id": 2,
		"visibility": "public",
		"meta": {"artifact_id": 1}
	})
	event_log.add_event({
		"tick": 12,
		"event_id": 19,
		"event_type": "notebook_note",
		"room_slot": 3,
		"actor_peer_id": 2,
		"target_peer_id": 2,
		"visibility": "private"
	})
	var controller = GAME_CONTROLLER_SCRIPT.new()
	var bundle := controller.build_forensic_bundle_for_test(5150, "phase1_constitution_hash", {
		"constitution_id": "expedition_constitution_phase1",
		"activation_epoch": "fully_active",
		"activation_active_channels": ["constitution", "archive"],
		"activation_dormant_channels": ["safe_mode"],
		"safe_mode_active": false,
		"safe_mode_lines": [],
		"explanation_packet_lines": ["Return with the answer."],
		"review_surface_lines": ["Review remains stable."]
	}, event_log, [])
	if int(bundle.get("bundle_schema_version", 0)) != 1:
		failures.append("Phase 1 forensic bundles should expose bundle_schema_version 1")
	for key in ["replay_id", "constitution_version_hash", "packet_schema_version", "product_catalog_version", "event_id_range", "timeline_digest", "governance_hook_set", "bundle_digest"]:
		if not bundle.has(key):
			failures.append("Phase 1 forensic bundles should expose %s" % key)
	var event_id_range: Dictionary = Dictionary(bundle.get("event_id_range", {}))
	if int(event_id_range.get("min_event_id", -1)) != 11 or int(event_id_range.get("max_event_id", -1)) != 19:
		failures.append("Phase 1 forensic bundles should preserve deterministic event id ranges")
	var hook_set: Dictionary = Dictionary(bundle.get("governance_hook_set", {}))
	var available_actions: Array = Array(hook_set.get("available_actions", []))
	var expected_actions: Array = ["observe", "normalize", "throttle", "quarantine", "rollback", "veto"]
	if JSON.stringify(available_actions) != JSON.stringify(expected_actions):
		failures.append("Phase 1 forensic bundles should expose the full governance action ladder including throttle")
	var replay_identity := controller._build_replay_identity(5150, "phase1_constitution_hash", "", event_log)
	if str(replay_identity.get("replay_id", "")).strip_edges().is_empty():
		failures.append("Phase 1 replay identities should expose replay_id")
	controller.free()
	event_log.free()

func _test_phase2_cosmetic_modulation_catalog_contract(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var catalog_failures := PRODUCT_CATALOG_SCRIPT.validate_catalog(catalog)
	if not catalog_failures.is_empty():
		failures.append("Phase 2 catalog validation should pass after cosmetic modulation contracts land: %s" % "; ".join(catalog_failures))
	var class_def := PRODUCT_CATALOG_SCRIPT.modulation_equivalence_class("notebook_guidance_focus", catalog)
	if class_def.is_empty():
		failures.append("Phase 2 should define the notebook_guidance_focus equivalence class")
		return
	for key in ["canonical_member_id", "member_ids", "allowed_axes", "timing_surface", "information_surface", "reward_surface", "risk_surface", "consequence_class", "fairness_impact_score"]:
		if not class_def.has(key):
			failures.append("Phase 2 equivalence classes should expose %s" % key)
	var member_ids := _string_array_for_test(Array(class_def.get("member_ids", [])))
	if member_ids.size() < 2:
		failures.append("Phase 2 equivalence classes should have at least two members")
	var canonical_member_id := str(class_def.get("canonical_member_id", "")).strip_edges()
	if not member_ids.has(canonical_member_id):
		failures.append("Phase 2 canonical_member_id should name one of the class members")
	for member_id in member_ids:
		var cosmetic := PRODUCT_CATALOG_SCRIPT.get_cosmetic(member_id, catalog)
		var profile: Dictionary = Dictionary(cosmetic.get("modulation_profile", {}))
		for invariant_key in ["timing_surface", "information_surface", "reward_surface", "risk_surface", "consequence_class", "fairness_impact_score"]:
			if JSON.stringify(profile.get(invariant_key, null)) != JSON.stringify(class_def.get(invariant_key, null)):
				failures.append("Phase 2 modulation member %s should match invariant %s exactly" % [member_id, invariant_key])
		for delta_key in ["intel_delta", "power_delta", "reward_delta", "timing_delta"]:
			if float(profile.get(delta_key, 0.0)) != 0.0:
				failures.append("Phase 2 modulation member %s should keep %s at zero" % [member_id, delta_key])

func _test_phase2_profile_normalization_and_loadout(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	if str(profile.get("normalization_mode", "")).strip_edges() != "default":
		failures.append("Phase 2 profiles should default normalization_mode to default")
	var default_loadout := Array(profile.get("equipped_modulation_loadout", []))
	if default_loadout.is_empty():
		failures.append("Phase 2 profiles should normalize an equipped modulation loadout from the starter cosmetics")
	else:
		var default_entry: Dictionary = Dictionary(default_loadout[0])
		if str(default_entry.get("equivalence_class_id", "")).strip_edges() != "notebook_guidance_focus":
			failures.append("Phase 2 default modulation loadout should include the notebook guidance class")
		if bool(default_entry.get("collapsed", false)):
			failures.append("Phase 2 default modulation loadout should not start collapsed")
	var custom := profile.duplicate(true)
	var cosmetics: Dictionary = Dictionary(custom.get("cosmetics", {}))
	var owned := _string_array_for_test(Array(cosmetics.get("owned", [])))
	if not owned.has("theme_cobalt_archive"):
		owned.append("theme_cobalt_archive")
	cosmetics["owned"] = owned
	var equipped: Dictionary = Dictionary(cosmetics.get("equipped", {}))
	equipped["notebook_theme"] = "theme_cobalt_archive"
	cosmetics["equipped"] = equipped
	custom["cosmetics"] = cosmetics
	custom["normalization_mode"] = "fairness_sensitive"
	var normalized := PROFILE_SERVICE_SCRIPT.normalize_profile(custom, catalog)
	var collapsed_loadout := Array(normalized.get("equipped_modulation_loadout", []))
	if collapsed_loadout.is_empty():
		failures.append("Phase 2 fairness-sensitive normalization should still retain the modulation loadout structurally")
	else:
		var collapsed_entry: Dictionary = Dictionary(collapsed_loadout[0])
		if str(collapsed_entry.get("selected_cosmetic_id", "")).strip_edges() != "theme_amber_fieldnotes":
			failures.append("Phase 2 fairness-sensitive normalization should collapse to the canonical member")
		if not bool(collapsed_entry.get("collapsed", false)):
			failures.append("Phase 2 fairness-sensitive normalization should mark collapsed modulation entries")

func _test_phase2_guidance_packet_normalization_collapse(failures: Array[String]) -> void:
	var controller = GAME_CONTROLLER_SCRIPT.new()
	var public_summary := {
		"protocol_state": "Fracture Protocol",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Hold the route together.",
		"world_goal": "Return with the answer.",
		"explanation_immediate_lines": ["Immediate cue: stabilize the route."],
		"explanation_run_lines": ["Run cue: the route should still read cleanly at the end."],
		"explanation_meta_lines": ["Meta cue: the archive will remember the custody line."]
	}
	var packet_default := controller.build_run_guidance_packet_for_test(public_summary, {}, {}, {
		"normalization_mode": "default",
		"equipped_modulation_loadout": [{
			"allowed_axis": "explanation_lane_bias",
			"preferred_explanation_lane": "run"
		}],
		"suppressed_modulation_count": 0
	})
	if str(packet_default.get("signal_focus_lane", "")).strip_edges() != "run":
		failures.append("Phase 2 default cosmetic modulation should be able to bias the guidance packet toward the run lane")
	var packet_fairness := controller.build_run_guidance_packet_for_test(public_summary, {}, {}, {
		"normalization_mode": "fairness_sensitive",
		"equipped_modulation_loadout": [{
			"allowed_axis": "explanation_lane_bias",
			"preferred_explanation_lane": "run",
			"collapsed": true
		}],
		"suppressed_modulation_count": 1
	})
	if str(packet_fairness.get("signal_focus_lane", "")).strip_edges() != "immediate":
		failures.append("Phase 2 fairness-sensitive normalization should collapse guidance focus to the canonical lane")
	if int(packet_fairness.get("suppressed_modulation_count", 0)) != 1:
		failures.append("Phase 2 guidance packets should surface suppressed modulation counts structurally")
	controller.free()

func _test_phase2_same_seed_fairness_sensitive_bundle_collapse(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var canonical_profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var alternate_profile := canonical_profile.duplicate(true)
	var cosmetics: Dictionary = Dictionary(alternate_profile.get("cosmetics", {}))
	var owned := _string_array_for_test(Array(cosmetics.get("owned", [])))
	if not owned.has("theme_cobalt_archive"):
		owned.append("theme_cobalt_archive")
	cosmetics["owned"] = owned
	var equipped: Dictionary = Dictionary(cosmetics.get("equipped", {}))
	equipped["notebook_theme"] = "theme_cobalt_archive"
	cosmetics["equipped"] = equipped
	alternate_profile["cosmetics"] = cosmetics
	canonical_profile["normalization_mode"] = "fairness_sensitive"
	alternate_profile["normalization_mode"] = "fairness_sensitive"
	var normalized_canonical := PROFILE_SERVICE_SCRIPT.normalize_profile(canonical_profile, catalog)
	var normalized_alternate := PROFILE_SERVICE_SCRIPT.normalize_profile(alternate_profile, catalog)
	var canonical_loadout := Array(normalized_canonical.get("equipped_modulation_loadout", []))
	var alternate_loadout := Array(normalized_alternate.get("equipped_modulation_loadout", []))
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var canonical_signature: Array[Dictionary] = []
	for entry_raw in canonical_loadout:
		var entry := Dictionary(entry_raw)
		canonical_signature.append({
			"equivalence_class_id": str(entry.get("equivalence_class_id", "")).strip_edges(),
			"selected_cosmetic_id": str(entry.get("selected_cosmetic_id", "")).strip_edges(),
			"allowed_axis": str(entry.get("allowed_axis", "")).strip_edges(),
			"preferred_explanation_lane": str(entry.get("preferred_explanation_lane", "")).strip_edges(),
			"timing_surface": str(entry.get("timing_surface", "")).strip_edges(),
			"information_surface": str(entry.get("information_surface", "")).strip_edges(),
			"reward_surface": str(entry.get("reward_surface", "")).strip_edges(),
			"risk_surface": str(entry.get("risk_surface", "")).strip_edges(),
			"consequence_class": str(entry.get("consequence_class", "")).strip_edges(),
			"fairness_impact_score": float(entry.get("fairness_impact_score", 0.0)),
			"normalization_mode": str(entry.get("normalization_mode", "")).strip_edges()
		})
	var alternate_signature: Array[Dictionary] = []
	for entry_raw in alternate_loadout:
		var entry := Dictionary(entry_raw)
		alternate_signature.append({
			"equivalence_class_id": str(entry.get("equivalence_class_id", "")).strip_edges(),
			"selected_cosmetic_id": str(entry.get("selected_cosmetic_id", "")).strip_edges(),
			"allowed_axis": str(entry.get("allowed_axis", "")).strip_edges(),
			"preferred_explanation_lane": str(entry.get("preferred_explanation_lane", "")).strip_edges(),
			"timing_surface": str(entry.get("timing_surface", "")).strip_edges(),
			"information_surface": str(entry.get("information_surface", "")).strip_edges(),
			"reward_surface": str(entry.get("reward_surface", "")).strip_edges(),
			"risk_surface": str(entry.get("risk_surface", "")).strip_edges(),
			"consequence_class": str(entry.get("consequence_class", "")).strip_edges(),
			"fairness_impact_score": float(entry.get("fairness_impact_score", 0.0)),
			"normalization_mode": str(entry.get("normalization_mode", "")).strip_edges()
		})
	if JSON.stringify(canonical_signature) != JSON.stringify(alternate_signature):
		failures.append("Phase 2 fairness-sensitive normalization should collapse same-seed equivalent cosmetics to an identical runtime modulation signature")
	var public_summary := {
		"protocol_state": "Fracture Protocol",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Hold the route together.",
		"world_goal": "Return with the answer.",
		"explanation_immediate_lines": ["Immediate cue: stabilize the route."],
		"explanation_run_lines": ["Run cue: the route should still read cleanly at the end."],
		"explanation_meta_lines": ["Meta cue: the archive will remember the custody line."]
	}
	var canonical_packet := controller.build_run_guidance_packet_for_test(public_summary, {}, {}, {
		"normalization_mode": "fairness_sensitive",
		"equipped_modulation_loadout": canonical_loadout,
		"suppressed_modulation_count": PRODUCT_CATALOG_SCRIPT.suppressed_delta_count(canonical_loadout)
	})
	var alternate_packet := controller.build_run_guidance_packet_for_test(public_summary, {}, {}, {
		"normalization_mode": "fairness_sensitive",
		"equipped_modulation_loadout": alternate_loadout,
		"suppressed_modulation_count": PRODUCT_CATALOG_SCRIPT.suppressed_delta_count(alternate_loadout)
	})
	var comparable_canonical_packet := canonical_packet.duplicate(true)
	comparable_canonical_packet.erase("suppressed_modulation_count")
	var comparable_alternate_packet := alternate_packet.duplicate(true)
	comparable_alternate_packet.erase("suppressed_modulation_count")
	if JSON.stringify(comparable_canonical_packet) != JSON.stringify(comparable_alternate_packet):
		failures.append("Phase 2 fairness-sensitive normalization should collapse same-seed equivalent cosmetics to an identical runtime guidance packet")
	controller.free()

func _test_phase2_same_seed_forensic_replay_bundle_collapse(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var canonical_profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var alternate_profile := canonical_profile.duplicate(true)
	var cosmetics: Dictionary = Dictionary(alternate_profile.get("cosmetics", {}))
	var owned := _string_array_for_test(Array(cosmetics.get("owned", [])))
	if not owned.has("theme_cobalt_archive"):
		owned.append("theme_cobalt_archive")
	cosmetics["owned"] = owned
	var equipped: Dictionary = Dictionary(cosmetics.get("equipped", {}))
	equipped["notebook_theme"] = "theme_cobalt_archive"
	cosmetics["equipped"] = equipped
	alternate_profile["cosmetics"] = cosmetics
	canonical_profile["normalization_mode"] = "forensic_replay"
	alternate_profile["normalization_mode"] = "forensic_replay"
	var normalized_canonical := PROFILE_SERVICE_SCRIPT.normalize_profile(canonical_profile, catalog)
	var normalized_alternate := PROFILE_SERVICE_SCRIPT.normalize_profile(alternate_profile, catalog)
	var canonical_loadout := Array(normalized_canonical.get("equipped_modulation_loadout", []))
	var alternate_loadout := Array(normalized_alternate.get("equipped_modulation_loadout", []))
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var canonical_signature: Array[Dictionary] = []
	for entry_raw in canonical_loadout:
		var entry := Dictionary(entry_raw)
		canonical_signature.append({
			"equivalence_class_id": str(entry.get("equivalence_class_id", "")).strip_edges(),
			"selected_cosmetic_id": str(entry.get("selected_cosmetic_id", "")).strip_edges(),
			"allowed_axis": str(entry.get("allowed_axis", "")).strip_edges(),
			"preferred_explanation_lane": str(entry.get("preferred_explanation_lane", "")).strip_edges(),
			"timing_surface": str(entry.get("timing_surface", "")).strip_edges(),
			"information_surface": str(entry.get("information_surface", "")).strip_edges(),
			"reward_surface": str(entry.get("reward_surface", "")).strip_edges(),
			"risk_surface": str(entry.get("risk_surface", "")).strip_edges(),
			"consequence_class": str(entry.get("consequence_class", "")).strip_edges(),
			"fairness_impact_score": float(entry.get("fairness_impact_score", 0.0)),
			"normalization_mode": str(entry.get("normalization_mode", "")).strip_edges()
		})
	var alternate_signature: Array[Dictionary] = []
	for entry_raw in alternate_loadout:
		var entry := Dictionary(entry_raw)
		alternate_signature.append({
			"equivalence_class_id": str(entry.get("equivalence_class_id", "")).strip_edges(),
			"selected_cosmetic_id": str(entry.get("selected_cosmetic_id", "")).strip_edges(),
			"allowed_axis": str(entry.get("allowed_axis", "")).strip_edges(),
			"preferred_explanation_lane": str(entry.get("preferred_explanation_lane", "")).strip_edges(),
			"timing_surface": str(entry.get("timing_surface", "")).strip_edges(),
			"information_surface": str(entry.get("information_surface", "")).strip_edges(),
			"reward_surface": str(entry.get("reward_surface", "")).strip_edges(),
			"risk_surface": str(entry.get("risk_surface", "")).strip_edges(),
			"consequence_class": str(entry.get("consequence_class", "")).strip_edges(),
			"fairness_impact_score": float(entry.get("fairness_impact_score", 0.0)),
			"normalization_mode": str(entry.get("normalization_mode", "")).strip_edges()
		})
	if JSON.stringify(canonical_signature) != JSON.stringify(alternate_signature):
		failures.append("Phase 2 forensic-replay normalization should collapse same-seed equivalent cosmetics to an identical runtime modulation signature")
	var public_summary := {
		"protocol_state": "Fracture Protocol",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Hold the route together.",
		"world_goal": "Return with the answer.",
		"explanation_immediate_lines": ["Immediate cue: stabilize the route."],
		"explanation_run_lines": ["Run cue: the route should still read cleanly at the end."],
		"explanation_meta_lines": ["Meta cue: the archive will remember the custody line."]
	}
	var canonical_packet := controller.build_run_guidance_packet_for_test(public_summary, {}, {}, {
		"normalization_mode": "forensic_replay",
		"equipped_modulation_loadout": canonical_loadout,
		"suppressed_modulation_count": PRODUCT_CATALOG_SCRIPT.suppressed_delta_count(canonical_loadout)
	})
	var alternate_packet := controller.build_run_guidance_packet_for_test(public_summary, {}, {}, {
		"normalization_mode": "forensic_replay",
		"equipped_modulation_loadout": alternate_loadout,
		"suppressed_modulation_count": PRODUCT_CATALOG_SCRIPT.suppressed_delta_count(alternate_loadout)
	})
	var comparable_canonical_packet := canonical_packet.duplicate(true)
	comparable_canonical_packet.erase("suppressed_modulation_count")
	var comparable_alternate_packet := alternate_packet.duplicate(true)
	comparable_alternate_packet.erase("suppressed_modulation_count")
	if JSON.stringify(comparable_canonical_packet) != JSON.stringify(comparable_alternate_packet):
		failures.append("Phase 2 forensic-replay normalization should collapse same-seed equivalent cosmetics to an identical runtime guidance packet")
	controller.free()

func _test_phase2_constitution_and_visual_normalization_contract(failures: Array[String]) -> void:
	var runtime_constitution := EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.build_runtime_summary({
		"protocol_state": "Exposure Protocol",
		"doctrine_family": "measured_pressure",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Hold the route together.",
		"world_goal": "Return with the answer.",
		"surface_summary": {"lines": ["Public surface remains narrow."]}
	}, "phase2_runtime_hash")
	var public_summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(runtime_constitution)
	for field in ["normalization_modes_supported", "normalization_mode_default", "cosmetic_modulation_lines"]:
		if not public_summary.has(field):
			failures.append("Phase 2 constitution summaries should expose %s" % field)
	var readability_law: Dictionary = Dictionary(runtime_constitution.get("cosmetic_readability_law", {}))
	if not _string_array_for_test(Array(readability_law.get("supported_normalization_modes", []))).has("fairness_sensitive"):
		failures.append("Phase 2 readability law should expose fairness-sensitive normalization support")
	var safety_law: Dictionary = Dictionary(runtime_constitution.get("safety_law", {}))
	if not _string_array_for_test(Array(safety_law.get("supported_normalization_modes", []))).has("all_ages"):
		failures.append("Phase 2 safety law should expose all-ages normalization support")
	var governance := VISUAL_GOVERNANCE_SCRIPT.new()
	var packet := governance.room_visual_packet({
		"slot": 1,
		"type": "evidence",
		"hazard": "none",
		"protocol_state": "Exposure Protocol",
		"branch_context": {
			"id": "watcher_steps",
			"protocol_state": "Exposure Protocol",
			"pressure_profile": ["return_pressure"],
			"run_identity_summary": {
				"pressure_grammar": ["Exposure"],
				"symbolic_motifs": ["Threshold Marks"],
				"pacing_profile": "steady",
				"convergence_axis": "balanced"
			}
		}
	})
	var packet_failures := governance.validate_room_packet(packet)
	if not packet_failures.is_empty():
		failures.append("Phase 2 room visual packets should validate with normalization_visual_rules present: %s" % "; ".join(packet_failures))
	if Dictionary(packet.get("normalization_visual_rules", {})).is_empty():
		failures.append("Phase 2 room visual packets should expose normalization_visual_rules")

func _test_phase3_market_control_surfaces_and_defaults(failures: Array[String]) -> void:
	var definitions: Dictionary = CONTROL_SURFACE_REGISTRY_SCRIPT.definitions()
	var economy_defs: Dictionary = Dictionary(definitions.get("economy", {}))
	for surface_name in ["market_volatility", "prestige_pressure", "hoard_visibility", "scarcity_recovery", "carrier_risk_bias"]:
		if not economy_defs.has(surface_name):
			failures.append("Phase 3 control surfaces should expose %s on the live economy group" % surface_name)
	var default_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	if Dictionary(default_world_memory.get("market_memory_state", {})).is_empty():
		failures.append("Phase 3 world memory defaults should expose market_memory_state")
	if Dictionary(default_world_memory.get("lifecycle_registry", {})).is_empty():
		failures.append("Phase 3 world memory defaults should expose lifecycle_registry")
	var normalized_extensions := CIVILIZATION_STATE_SERVICE_SCRIPT.normalize_world_memory_extensions(default_world_memory)
	for key in ["market_regimes", "lifecycle_states"]:
		if not normalized_extensions.has(key):
			failures.append("Phase 3 civilization extensions should expose %s" % key)

func _test_phase3_compiler_and_constitution_market_contract(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves", "bomb reserves"],
			"group_model": {"group_signals": ["public answer appetite"]}
		}
	}, 303303, 10)
	var summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	for field in ["active_regime_ids", "lifecycle_state_ids", "market_regime_lines", "lifecycle_lines", "market_regime_id", "market_regime_family"]:
		if not summary.has(field):
			failures.append("Phase 3 constitution summaries should expose %s" % field)
	if _string_array_for_test(Array(summary.get("active_regime_ids", []))).is_empty():
		failures.append("Phase 3 constitutions should compile at least one active market regime id")
	if Dictionary(constitution.get("market_regime_state", {})).is_empty():
		failures.append("Phase 3 constitutions should expose market_regime_state")
	if Dictionary(constitution.get("market_memory_state", {})).is_empty():
		failures.append("Phase 3 constitutions should expose market_memory_state")
	if Dictionary(constitution.get("lifecycle_registry", {})).is_empty():
		failures.append("Phase 3 constitutions should expose lifecycle_registry")
	var route_profile: Dictionary = Dictionary(constitution.get("route_profile", {}))
	if Dictionary(route_profile.get("market_routing", {})).is_empty():
		failures.append("Phase 3 route profiles should carry market_routing")
	var item_ecology_profile: Dictionary = Dictionary(constitution.get("item_ecology_profile", {}))
	if _string_array_for_test(Array(item_ecology_profile.get("market_regime_ids", []))).is_empty():
		failures.append("Phase 3 item ecology profiles should carry market regime ids")

func _test_phase3_generation_and_item_market_bias(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var volatile_contract := generator.build_generation_contract(77, {
		"market_routing": {
			"market_volatility": 2,
			"carrier_risk_bias": 2,
			"active_regime_ids": ["market_extraction_austerity"]
		}
	})
	if int(Dictionary(volatile_contract.get("market_routing", {})).get("market_volatility", 0)) != 2:
		failures.append("Phase 3 generation contracts should preserve market_routing")
	var volatile_risk := generator.risk_for_slot_for_test(77, 8, 10, "hazard", volatile_contract)
	var recovery_risk := generator.risk_for_slot_for_test(77, 8, 10, "hazard", {
		"market_routing": {
			"scarcity_recovery": 2,
			"recovery_credit": 3,
			"active_regime_ids": ["market_recovery_weave"]
		}
	})
	if volatile_risk <= recovery_risk:
		failures.append("Phase 3 market routing should be able to push route risk above recovery-biased routing")
	var witness_prestige_bonus := ITEM_SERVICE_SCRIPT.new().directive_bonus_for_item_for_test("witness_chime", {
		"market_routing": {
			"prestige_pressure": 2,
			"active_regime_ids": ["market_prestige_showcase"]
		}
	})
	var witness_recovery_bonus := ITEM_SERVICE_SCRIPT.new().directive_bonus_for_item_for_test("witness_chime", {
		"market_routing": {
			"scarcity_recovery": 2,
			"active_regime_ids": ["market_recovery_weave"]
		}
	})
	if witness_prestige_bonus <= witness_recovery_bonus:
		failures.append("Phase 3 prestige-biased market regimes should weight witness-facing items above recovery-biased regimes")

func _test_phase3_world_memory_and_civilization_market_persistence(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves", "bomb reserves"]
		}
	}, 404404, 10)
	var summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	var updated_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(WORLD_MEMORY_SERVICE_SCRIPT.default_state(), {
		"run_record": {
			"seed": 404404,
			"expedition_constitution": constitution,
			"expedition_constitution_summary": summary
		},
		"diagnostics": {
			"resource_pressure": ["rope reserves", "bomb reserves"],
			"burden_score": 2,
			"recovery_score": 1,
			"anomaly_sensitivity": {"score": 2}
		},
		"frame": {
			"world_pull": "markets are reading the route through extraction debt"
		},
		"profile": profile
	})
	var market_memory_state: Dictionary = Dictionary(updated_world_memory.get("market_memory_state", {}))
	if _string_array_for_test(Array(market_memory_state.get("active_regime_ids", []))).is_empty():
		failures.append("Phase 3 world memory should persist active market regime ids after a run")
	var lifecycle_registry: Dictionary = Dictionary(updated_world_memory.get("lifecycle_registry", {}))
	if Array(lifecycle_registry.get("families", [])).is_empty():
		failures.append("Phase 3 world memory should persist lifecycle families after a run")
	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(updated_world_memory)
	if _string_array_for_test(Array(civilization_surface.get("market_regime_ids", []))).is_empty():
		failures.append("Phase 3 civilization surfaces should expose market_regime_ids")
	if _string_array_for_test(Array(civilization_surface.get("lifecycle_state_ids", []))).is_empty():
		failures.append("Phase 3 civilization surfaces should expose lifecycle_state_ids")

func _test_phase3_preservation_salience_accessibility_activation_contract(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, _phase8_run_record(404405), catalog)
	var updated_profile: Dictionary = Dictionary(result.get("profile", {}))
	var world_memory: Dictionary = Dictionary(updated_profile.get("world_memory", {}))
	var continuity_review: Dictionary = Dictionary(WORLD_MEMORY_SERVICE_SCRIPT.build_continuity_review(world_memory))
	for key in ["preserved_count", "salient_count", "accessible_count", "active_count", "minority_count", "returnable_count", "canon_pressure", "summary_line"]:
		if not continuity_review.has(key):
			failures.append("Phase 3 continuity review should expose %s" % key)
	if int(continuity_review.get("preserved_count", 0)) <= int(continuity_review.get("active_count", 0)):
		failures.append("Phase 3 continuity review should preserve more total continuity than the currently active surface")
	if int(continuity_review.get("accessible_count", 0)) <= 0:
		failures.append("Phase 3 continuity review should keep accessible continuity distinct from zero")
	if int(continuity_review.get("returnable_count", 0)) <= 0:
		failures.append("Phase 3 continuity review should keep returnable continuity visible once reentry hooks exist")
	var world_lines := WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory)
	var continuity_line_count := 0
	for line_variant in world_lines:
		if str(line_variant).begins_with("Continuity: "):
			continuity_line_count += 1
	if continuity_line_count != 1:
		failures.append("Phase 3 world memory lines should add exactly one compact continuity line for the distinction contract")
	var archive_continuity_line := ARCHIVE_SERVICE_SCRIPT._continuity_line({"world_memory": world_memory, "profile": updated_profile, "crawl_packet": {}}, {})
	if archive_continuity_line.strip_edges().is_empty():
		failures.append("Phase 3 archive continuity readers should be able to reuse the compact continuity review when no stronger continuity line is present")

func _test_phase4_compiler_and_constitution_encounter_contract(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure"]
		}
	}, 505505, 10)
	var summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	for field in ["active_pathology_ids", "pathology_lines", "encounter_lines", "encounter_manifest_ids", "encounter_intent_ids", "encounter_topology_ids"]:
		if not summary.has(field):
			failures.append("Phase 4 constitution summaries should expose %s" % field)
	for field in ["encounter_language_profile", "pathology_profile", "pathology_state", "encounter_manifest"]:
		if Dictionary(constitution.get(field, {})).is_empty():
			failures.append("Phase 4 constitutions should expose %s" % field)
	if Dictionary(Dictionary(constitution.get("generation_surface", {})).get("encounter_routing", {})).is_empty():
		failures.append("Phase 4 generation surfaces should expose encounter_routing")
	if _string_array_for_test(Array(summary.get("active_pathology_ids", []))).is_empty():
		failures.append("Phase 4 constitutions should surface active pathology ids")
	var compile_metadata: Dictionary = Dictionary(constitution.get("compile_metadata", {}))
	if _string_array_for_test(Array(compile_metadata.get("encounter_manifest_ids", []))).is_empty():
		failures.append("Phase 4 compile metadata should expose encounter_manifest_ids")

func _test_phase4_generation_contract_and_branch_context(failures: Array[String]) -> void:
	var contract := RUN_GENERATOR_SCRIPT.new().build_generation_contract(6161, {
		"encounter_routing": {
			"active_pathology_ids": ["pathology_haunt_pressure"],
			"encounter_manifest_ids": ["enc_ghost_corridor_pursuit"],
			"encounter_lines": ["Ghost pursuit is pulling the route toward extraction pressure."],
			"anchored_pressures": ["route_pressure", "extraction_pressure"]
		}
	})
	if Dictionary(contract.get("encounter_routing", {})).is_empty():
		failures.append("Phase 4 generation contracts should preserve encounter_routing")
	var room := RUN_GENERATOR_SCRIPT.new().branch_context_for_test(6161, 4, 10, "hazard", "push", contract)
	var branch_context: Dictionary = Dictionary(room.get("branch_context", {}))
	var encounter_preview: Dictionary = Dictionary(branch_context.get("encounter_preview", {}))
	if _string_array_for_test(Array(encounter_preview.get("active_pathology_ids", []))).is_empty():
		failures.append("Phase 4 branch context should expose encounter_preview active_pathology_ids")
	if not Array(branch_context.get("pressure_profile", [])).has("route_pressure"):
		failures.append("Phase 4 branch context pressure_profile should carry anchored encounter pressures")

func _test_phase4_runtime_ecology_encounter_state(failures: Array[String]) -> void:
	var run_state_script = load("res://src/run/run_state.gd")
	if run_state_script == null:
		failures.append("run_state script should load for Phase 4 runtime ecology tests")
		return
	var run_state = run_state_script.new()
	var event_log = EVENT_LOG_SCRIPT.new()
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure"]
		}
	}, 707707, 10)
	manager.current_expedition_constitution = constitution.duplicate(true)
	manager.current_delve_directive = constitution.duplicate(true)
	manager.current_generation_contract = Dictionary(constitution.get("generation_surface", {})).duplicate(true)
	var peer_ids: Array[int] = [2, 3, 4]
	run_state.set_run(707707, [{"slot": 0, "type": "traversal"}], peer_ids, {
		"constitution": constitution,
		"constitution_hash": str(constitution.get("constitution_hash", "")),
		"constitution_summary": Dictionary(constitution.get("constitution_summary", {})).duplicate(true),
		"generation_surface": Dictionary(constitution.get("generation_surface", {})).duplicate(true)
	})
	manager.bind_runtime_context_for_test(run_state, event_log)
	var result := manager.advance_runtime_ecology_for_test(
		manager.ghost_wake_tick_for_test() + 240,
		{2: 6, 3: 4, 4: 2},
		{2: Vector2(6 * 1024.0, 0), 3: Vector2(4 * 1024.0, 0), 4: Vector2(2 * 1024.0, 0)},
		[2, 3, 4],
		9,
		{2: true}
	)
	if Dictionary(result.get("active_encounter_state", {})).is_empty():
		failures.append("Phase 4 runtime ecology should materialize an active_encounter_state")
	if _string_array_for_test(Array(Dictionary(result.get("pathology_state", {})).get("active_family_ids", []))).is_empty():
		failures.append("Phase 4 runtime ecology should materialize active pathology families")
	if Array(result.get("encounter_history", [])).is_empty():
		failures.append("Phase 4 runtime ecology should record encounter_history entries")
	manager.clear_runtime_context_for_test()
	manager.free()
	run_state.free()
	event_log.free()

func _test_phase4_world_memory_encounter_persistence(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure"]
		}
	}, 808808, 10)
	var summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	var updated_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(WORLD_MEMORY_SERVICE_SCRIPT.default_state(), {
		"run_record": {
			"seed": 808808,
			"expedition_constitution": constitution,
			"expedition_constitution_summary": summary,
			"encounter_manifest": Dictionary(constitution.get("encounter_manifest", {})).duplicate(true),
			"pathology_state": Dictionary(constitution.get("pathology_state", {})).duplicate(true),
			"active_encounter_state": {
				"encounter_id": "enc_ghost_corridor_pursuit",
				"anchored_pressures": ["route_pressure", "extraction_pressure"]
			}
		},
		"diagnostics": {
			"inhabitant_pressure": ["ghost pressure"]
		},
		"profile": profile
	})
	if Dictionary(updated_world_memory.get("pathology_memory_state", {})).is_empty():
		failures.append("Phase 4 world memory should expose pathology_memory_state")
	if Dictionary(updated_world_memory.get("encounter_memory_state", {})).is_empty():
		failures.append("Phase 4 world memory should expose encounter_memory_state")
	if _string_array_for_test(Array(Dictionary(updated_world_memory.get("pathology_memory_state", {})).get("active_family_ids", []))).is_empty():
		failures.append("Phase 4 world memory should persist active pathology ids")
	if str(Dictionary(updated_world_memory.get("encounter_memory_state", {})).get("last_active_encounter_id", "")).strip_edges().is_empty():
		failures.append("Phase 4 world memory should persist last_active_encounter_id")

func _test_phase4_truth_layer_disclosure_matrix_contract(failures: Array[String]) -> void:
	var canonical_summary := {
		"protocol_state": "Fracture Protocol",
		"doctrine_label": "Measured Pressure",
		"pressure_line": "Keep the burden readable.",
		"surface_summary": {"lines": ["Rescue geometry is drawing the public answer."]},
		"experiment_surface_lines": ["Stewardship claims are starting to travel faster than extraction talk."],
		"theory_surface_lines": ["An official theory carrier remains active."],
		"theory_statuses": ["official", "rival"],
		"review_surface_lines": ["promotion review kept 1 admissible carrier ready; 1 line stays cooling or contested"],
		"safe_mode_lines": ["safe mode is standing by while active governance remains stable"],
		"explanation_meta_lines": ["meta review stayed bounded to public-safe pressure lines"]
	}
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze({
		"seed": 505506,
		"local_peer_id": 2,
		"item_defs": ["custody_seal"],
		"timeline_public_events": [
			{"event_id": 1, "tick": 10, "room_slot": 3, "actor_peer_id": 2, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}}
		],
		"communication_summary": {"total": 1, "regroup": 1},
		"key_clues": ["Artifact picked up at the threshold."],
		"action_summary": ["The burden stayed visible."],
		"gameplay_signal_snapshot": {"protocol_state": "Fracture Protocol"},
		"expedition_constitution_summary": canonical_summary
	})
	var disclosure_review: Dictionary = Dictionary(diagnostics.get("disclosure_review", {}))
	if int(disclosure_review.get("active_count", 0)) <= 0:
		failures.append("Phase 4 disclosure review should keep active public implications explicit")
	if int(disclosure_review.get("latent_count", 0)) <= 0:
		failures.append("Phase 4 disclosure review should keep latent implications explicit")
	if int(disclosure_review.get("deep_count", 0)) <= 0:
		failures.append("Phase 4 disclosure review should keep deep operator-only implications explicit")
	if str(disclosure_review.get("contradiction_disposition", "")).strip_edges() != "public_contestation":
		failures.append("Phase 4 disclosure review should classify rival theory pressure as public contestation")
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var payload := manager.build_run_start_payload(
		505506,
		[{"slot": 0, "type": "traversal"}],
		[2, 3],
		{"doctrine_label": "Legacy Drift", "surface_summary": {"lines": ["legacy"]}},
		"constitution_payload_hash",
		canonical_summary
	)
	if Dictionary(payload.get("constitution_summary", {})).has("promotion_review") or Dictionary(payload.get("constitution_summary", {})).has("disclosure_review"):
		failures.append("Phase 4 disclosure hardening should not add new structured governance or disclosure objects to constitution_summary")
	manager.free()

func _test_phase5_compiler_and_constitution_apex_contract(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure", "predator rush"]
		}
	}, 909909, 10)
	var summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	for field in ["apex_manifest_ids", "apex_class_ids", "apex_lines", "peak_structure_lines"]:
		if not summary.has(field):
			failures.append("Phase 5 constitution summaries should expose %s" % field)
	for field in ["apex_framework_profile", "apex_manifest", "peak_structure_profile"]:
		if Dictionary(constitution.get(field, {})).is_empty():
			failures.append("Phase 5 constitutions should expose %s" % field)
	if Dictionary(Dictionary(constitution.get("generation_surface", {})).get("apex_routing", {})).is_empty():
		failures.append("Phase 5 generation surfaces should expose apex_routing")
	var compile_metadata: Dictionary = Dictionary(constitution.get("compile_metadata", {}))
	if _string_array_for_test(Array(compile_metadata.get("apex_manifest_ids", []))).is_empty():
		failures.append("Phase 5 compile metadata should expose apex_manifest_ids")
	if _string_array_for_test(Array(compile_metadata.get("apex_class_ids", []))).is_empty():
		failures.append("Phase 5 compile metadata should expose apex_class_ids")

func _test_phase5_branch_context_and_visual_apex_preview(failures: Array[String]) -> void:
	var contract := RUN_GENERATOR_SCRIPT.new().build_generation_contract(10101, {
		"apex_routing": {
			"apex_manifest_ids": ["apex_predator_packmind"],
			"apex_class_ids": ["packmind_apex"],
			"apex_lines": ["Predator packmind pressure is converging on the carrier path."],
			"peak_structure_lines": ["Peak structure keeps spectacle spaced around readable aftermath."],
			"peak_spacing_score": 3
		}
	})
	if Dictionary(contract.get("apex_routing", {})).is_empty():
		failures.append("Phase 5 generation contracts should preserve apex_routing")
	var room := RUN_GENERATOR_SCRIPT.new().branch_context_for_test(10101, 7, 10, "hazard", "collapse", contract)
	var branch_context: Dictionary = Dictionary(room.get("branch_context", {}))
	var apex_preview: Dictionary = Dictionary(branch_context.get("apex_preview", {}))
	if _string_array_for_test(Array(apex_preview.get("apex_manifest_ids", []))).is_empty():
		failures.append("Phase 5 branch context should expose apex_preview apex_manifest_ids")
	if int(apex_preview.get("peak_spacing_score", 0)) < 3:
		failures.append("Phase 5 branch context should retain peak spacing score")
	var governance := VISUAL_GOVERNANCE_SCRIPT.new()
	var packet := governance.room_visual_packet(room)
	if not governance.validate_room_packet(packet).is_empty():
		failures.append("Phase 5 room visual packets should validate with apex_visual_profile present")
	if Dictionary(packet.get("apex_visual_profile", {})).is_empty():
		failures.append("Phase 5 room visual packets should expose apex_visual_profile")

func _test_phase5_runtime_apex_and_local_aftermath(failures: Array[String]) -> void:
	var run_state_script = load("res://src/run/run_state.gd")
	if run_state_script == null:
		failures.append("run_state script should load for Phase 5 runtime apex tests")
		return
	var run_state = run_state_script.new()
	var event_log = EVENT_LOG_SCRIPT.new()
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["predator rush"]
		}
	}, 919191, 10)
	manager.current_expedition_constitution = constitution.duplicate(true)
	manager.current_delve_directive = constitution.duplicate(true)
	manager.current_generation_contract = Dictionary(constitution.get("generation_surface", {})).duplicate(true)
	var peer_ids: Array[int] = [2, 3, 4]
	run_state.set_run(919191, [{"slot": 6, "type": "hazard"}], peer_ids, {
		"constitution": constitution,
		"constitution_hash": str(constitution.get("constitution_hash", "")),
		"constitution_summary": Dictionary(constitution.get("constitution_summary", {})).duplicate(true),
		"generation_surface": Dictionary(constitution.get("generation_surface", {})).duplicate(true)
	})
	manager.bind_runtime_context_for_test(run_state, event_log)
	manager._apply_runtime_encounter_state("predator", 6, 2, "pack")
	if Dictionary(manager.get_active_apex_state()).is_empty():
		failures.append("Phase 5 runtime ecology should materialize an active_apex_state when an apex-linked encounter escalates")
	manager._finalize_active_encounter_state("resolved_for_test")
	if Dictionary(manager.get_local_aftermath()).is_empty():
		failures.append("Phase 5 runtime ecology should materialize LocalAftermath when an apex-linked encounter resolves")
	if Array(manager.get_apex_history()).is_empty():
		failures.append("Phase 5 runtime ecology should record apex_history entries")
	manager.clear_runtime_context_for_test()
	manager.free()
	run_state.free()
	event_log.free()

func _test_phase5_world_aftermath_owner_boundary(failures: Array[String]) -> void:
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var local_aftermath := {
		"aftermath_id": "local_aftermath_apex_predator_packmind_2",
		"source_id": "apex_predator_packmind",
		"source_kind": "apex",
		"affected_room_slots": [6],
		"immediate_route_state": "rerouted",
		"custody_state_delta": "contested",
		"evidence_state_delta": "contained",
		"resource_state_delta": "strained",
		"residual_telegraph_tags": ["custody_pressure", "hazard_pulse"],
		"narrative_residue_tags": ["carrier_strain", "pack_residue"]
	}
	var world_aftermath_refs := controller._build_world_aftermath_refs(local_aftermath, {
		"apex_id": "apex_predator_packmind"
	}, {
		"apex_class_ids": ["packmind_apex"],
		"apex_lines": ["Institutions are rereading the carrier lane through the aftermath."]
	})
	if world_aftermath_refs.is_empty():
		failures.append("Phase 5 runtime/export should still emit derivation-safe world aftermath refs when LocalAftermath exists")
	else:
		var runtime_ref: Dictionary = Dictionary(world_aftermath_refs[0])
		for forbidden_key in ["world_mutation_ids", "residue_records", "prestige_climate_delta", "institutional_response", "continuity_scars", "successor_claims"]:
			if runtime_ref.has(forbidden_key):
				failures.append("Phase 5 runtime/export world aftermath refs should not author final WorldAftermath field %s" % forbidden_key)
		if str(runtime_ref.get("schema_name", "")).strip_edges() != "WorldAftermathRef":
			failures.append("Phase 5 runtime/export world aftermath refs should identify as WorldAftermathRef")
		var derived_world_aftermath := CIVILIZATION_STATE_SERVICE_SCRIPT.build_world_aftermath_records({
			"run_record": {
				"local_aftermath": local_aftermath,
				"active_apex_state": {"apex_id": "apex_predator_packmind"},
				"world_aftermath_refs": world_aftermath_refs,
				"expedition_constitution_summary": {
					"apex_class_ids": ["packmind_apex"],
					"apex_lines": ["Institutions are rereading the carrier lane through the aftermath."]
				}
			},
			"diagnostics": {
				"institutional_pressure_surface": {
					"claim_lines": ["Institutions are rereading the carrier lane through the aftermath."]
				}
			}
		})
		if derived_world_aftermath.is_empty():
			failures.append("Phase 5 continuity owners should derive final WorldAftermath records from runtime refs")
		else:
			var continuity_record: Dictionary = Dictionary(derived_world_aftermath[0])
			for required_key in ["world_mutation_ids", "residue_records", "prestige_climate_delta", "institutional_response", "continuity_scars", "successor_claims"]:
				if not continuity_record.has(required_key):
					failures.append("Phase 5 continuity-derived WorldAftermath records should expose %s" % required_key)
	controller.free()

func _test_phase5_world_aftermath_persistence(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["predator rush"]
		}
	}, 929292, 10)
	var summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	var run_record := {
		"seed": 929292,
		"local_role": "Scavenger",
		"role_result_success": true,
		"outcome_summary": {
			"summary_text": "Apex pressure broke open the return lane.",
			"artifact_result_text": "The route was held.",
			"expedition_success": true
		},
		"stats": {"notes_count": 1, "inspections_count": 1, "pinned_count": 0, "extraction_completed": true},
		"communication_summary": {"total": 2, "danger": 1, "regroup": 1, "artifact": 1},
		"key_clues": ["The pack pressure stayed on the carrier lane."],
		"action_summary": ["The escort line held through the crisis window."],
		"timeline_public_events": [],
		"expedition_constitution": constitution,
		"expedition_constitution_summary": summary,
		"gameplay_signal_snapshot": {
			"protocol_state": "Exposure Protocol",
			"group_model": {
				"dominant_build": "Escort build",
				"group_signals": ["burden-rescue answer"],
				"fault_lines": ["shared burden caution"],
				"model_pressure": ["escort line"]
			}
		},
		"apex_manifest": Dictionary(constitution.get("apex_manifest", {})).duplicate(true),
		"peak_structure_profile": Dictionary(constitution.get("peak_structure_profile", {})).duplicate(true),
		"active_apex_state": {
			"apex_id": "apex_predator_packmind",
			"apex_class_id": "packmind_apex"
		},
		"local_aftermath": {
			"aftermath_id": "local_aftermath_apex_predator_packmind_1",
			"source_id": "apex_predator_packmind",
			"source_kind": "apex",
			"affected_room_slots": [6],
			"immediate_route_state": "rerouted",
			"custody_state_delta": "contested",
			"evidence_state_delta": "contained",
			"resource_state_delta": "strained",
			"residual_telegraph_tags": ["custody_pressure", "hazard_pulse"],
			"narrative_residue_tags": ["carrier_strain", "pack_residue"]
		},
		"world_aftermath_refs": [{
			"schema_name": "WorldAftermathRef",
			"schema_version": 1,
			"aftermath_id": "world_aftermath_apex_predator_packmind",
			"source_id": "apex_predator_packmind",
			"source_kind": "apex",
			"apex_id": "apex_predator_packmind",
			"local_aftermath_id": "local_aftermath_apex_predator_packmind_1",
			"continuity_seed_tags": ["carrier_strain", "pack_residue"],
			"return_pressure_tags": ["custody_pressure", "hazard_pulse"],
			"route_state_hint": "rerouted",
			"successor_hint_ids": ["packmind_apex"]
		}],
		"normalization_mode": "default",
		"equipped_modulation_loadout": []
	}
	var updated_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(WORLD_MEMORY_SERVICE_SCRIPT.default_state(), {
		"run_record": run_record,
		"profile": profile
	})
	if Dictionary(updated_world_memory.get("apex_memory_state", {})).is_empty():
		failures.append("Phase 5 world memory should expose apex_memory_state")
	if Dictionary(updated_world_memory.get("world_aftermath_state", {})).is_empty():
		failures.append("Phase 5 world memory should expose world_aftermath_state")
	if str(Dictionary(updated_world_memory.get("apex_memory_state", {})).get("last_active_apex_id", "")).strip_edges().is_empty():
		failures.append("Phase 5 world memory should persist last_active_apex_id")
	if _string_array_for_test(Array(Dictionary(updated_world_memory.get("world_aftermath_state", {})).get("world_aftermath_ids", []))).is_empty():
		failures.append("Phase 5 world memory should persist world aftermath ids")
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var next_profile: Dictionary = Dictionary(result.get("profile", {}))
	var last_run: Dictionary = Dictionary(next_profile.get("last_run", {}))
	if Dictionary(last_run.get("local_aftermath", {})).is_empty():
		failures.append("Phase 5 profiles should persist local_aftermath on last_run")
	var persisted_world_aftermath := _dict_array_for_test(last_run.get("world_aftermath_refs", []))
	if persisted_world_aftermath.is_empty():
		failures.append("Phase 5 profiles should persist world_aftermath_refs on last_run")
	else:
		var persisted_entry: Dictionary = Dictionary(persisted_world_aftermath[0])
		if str(persisted_entry.get("schema_name", "")).strip_edges() != "WorldAftermath":
			failures.append("Phase 5 profile continuity should persist final WorldAftermath records on last_run")
		if not persisted_entry.has("world_mutation_ids"):
			failures.append("Phase 5 profile continuity should persist continuity-authored WorldAftermath records rather than runtime refs")

func _test_phase5_world_aftermath_shape_contract(failures: Array[String]) -> void:
	var runtime_ref := {
		"schema_name": "WorldAftermathRef",
		"schema_version": 1,
		"aftermath_id": "world_aftermath_shape_runtime",
		"source_id": "apex_shape_runtime",
		"source_kind": "apex",
		"apex_id": "apex_shape_runtime",
		"local_aftermath_id": "local_aftermath_shape_runtime",
		"continuity_seed_tags": ["shape_seed"],
		"return_pressure_tags": ["route_pressure"],
		"route_state_hint": "rerouted",
		"successor_hint_ids": ["threshold_trial_apex"]
	}
	var final_record := {
		"schema_name": "WorldAftermath",
		"schema_version": 1,
		"aftermath_id": "world_aftermath_shape_final",
		"source_id": "apex_shape_final",
		"source_kind": "apex",
		"apex_id": "apex_shape_final",
		"world_mutation_ids": ["wm_shape_final"],
		"residue_records": ["shape residue"],
		"prestige_climate_delta": "steady",
		"institutional_response": "institutions held the line",
		"return_pressure_tags": ["route_pressure"],
		"continuity_scars": ["scar_shape_final"],
		"successor_claims": ["threshold_trial_apex"]
	}
	if CIVILIZATION_STATE_SERVICE_SCRIPT.world_aftermath_ref_entries([runtime_ref]).size() != 1:
		failures.append("Phase 5 shape helpers should accept runtime WorldAftermathRef entries")
	if not CIVILIZATION_STATE_SERVICE_SCRIPT.world_aftermath_ref_entries([final_record]).is_empty():
		failures.append("Phase 5 shape helpers should reject final WorldAftermath records from runtime ref readers")
	if CIVILIZATION_STATE_SERVICE_SCRIPT.world_aftermath_record_entries([final_record]).size() != 1:
		failures.append("Phase 5 shape helpers should accept continuity WorldAftermath records")
	if not CIVILIZATION_STATE_SERVICE_SCRIPT.world_aftermath_record_entries([runtime_ref]).is_empty():
		failures.append("Phase 5 shape helpers should reject runtime WorldAftermathRef entries from continuity record readers")
	var invalid_derived := CIVILIZATION_STATE_SERVICE_SCRIPT.build_world_aftermath_records({
		"run_record": {
			"world_aftermath_refs": [final_record]
		}
	})
	if not invalid_derived.is_empty():
		failures.append("Phase 5 continuity derivation should fail closed when run_record.world_aftermath_refs carries final WorldAftermath records")

func _test_phase6_lifecycle_hardening_compile_contract(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure", "predator rush"],
			"group_model": {
				"model_pressure": ["split answer", "crowded return"]
			}
		}
	}, 939393, 10)
	var lifecycle_registry: Dictionary = Dictionary(constitution.get("lifecycle_registry", {}))
	var family_kinds: Array[String] = []
	for family_raw in Array(lifecycle_registry.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_kind := str(family.get("family_kind", "")).strip_edges()
		if not family_kind.is_empty() and not family_kinds.has(family_kind):
			family_kinds.append(family_kind)
		for field in ["dominance_strain", "throttle_state", "resurrection_priority"]:
			if not family.has(field):
				failures.append("Phase 6 lifecycle families should expose %s" % field)
				break
	for required_kind in ["market", "pathology", "encounter", "apex"]:
		if not family_kinds.has(required_kind):
			failures.append("Phase 6 lifecycle hardening should extend lifecycle_registry with %s families" % required_kind)
	var compile_metadata: Dictionary = Dictionary(constitution.get("compile_metadata", {}))
	if not _string_array_for_test(Array(compile_metadata.get("lifecycle_family_kinds", []))).has("apex"):
		failures.append("Phase 6 compile metadata should surface lifecycle_family_kinds including apex")

func _test_phase6_governance_lifecycle_controls(failures: Array[String]) -> void:
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.default_state()
	var updated := GOVERNANCE_SERVICE_SCRIPT.apply_post_run(
		governance_state,
		{
			"seed": 949494,
			"expedition_constitution": {
				"lifecycle_registry": {
					"families": [
						{
							"family_id": "market_extraction_austerity",
							"family_kind": "market",
							"state": "saturated",
							"heat": 6,
							"saturation": 5,
							"strain": 4,
							"dominance_strain": 5,
							"successor_hint": "market_recovery_weave",
							"throttle_state": "cooling",
							"resurrection_priority": 1
						},
						{
							"family_id": "pathology_pack_hunger",
							"family_kind": "pathology",
							"state": "active",
							"heat": 5,
							"saturation": 4,
							"strain": 5,
							"dominance_strain": 5,
							"successor_hint": "pathology_pack_hunger_successor",
							"throttle_state": "cooling",
							"resurrection_priority": 2
						},
						{
							"family_id": "apex_packmind_apex",
							"family_kind": "apex",
							"state": "active",
							"heat": 4,
							"saturation": 3,
							"strain": 4,
							"dominance_strain": 4,
							"successor_hint": "encounter_pack_surround",
							"throttle_state": "open",
							"resurrection_priority": 3
						}
					]
				}
			}
		},
		{
			"consensus_risk": 3,
			"spectacle_pressure": 3,
			"fairness_flags": ["no_hidden_targeting_required"],
			"dignity_flags": ["spectacle_burden"],
			"review_surface_lines": ["Lifecycle hardening flagged saturation, veto, and meta-collapse risk."]
		},
		{
			"governance_line": "Keep the route legible. Surface: lifecycle cooling."
		},
		{
			"constitution_id": "phase6_governance_test",
			"constitution_hash": "phase6_governance_hash",
			"doctrine_family": "custody_ritual",
			"review_surface_lines": ["Lifecycle hardening is active."],
			"activation_epoch": "fully_active",
			"activation_active_channels": ["constitution", "archive", "world_memory"],
			"activation_dormant_channels": ["safe_mode"],
			"safe_mode_active": false
		}
	)
	for key in [
		"saturation_reports",
		"dominance_strain_reports",
		"throttle_records",
		"fairness_veto_registry",
		"dignity_veto_registry",
		"rollback_registry",
		"exploit_absorption_reports",
		"meta_collapse_reports"
	]:
		if _dict_array_for_test(updated.get(key, [])).is_empty():
			failures.append("Phase 6 governance should populate %s when lifecycle strain and veto pressure are present" % key)
	var hook_set: Dictionary = GOVERNANCE_SERVICE_SCRIPT.build_governance_hook_set(updated, {}, {})
	var trigger_slots: Dictionary = Dictionary(hook_set.get("trigger_slots", {}))
	for key in ["throttle", "fairness_veto", "dignity_veto", "meta_collapse"]:
		if _string_array_for_test(Array(trigger_slots.get(key, []))).is_empty():
			failures.append("Phase 6 governance hook sets should expose %s trigger slots" % key)
	if _string_array_for_test(Array(Dictionary(updated.get("resurrection_priority", {})).get("candidate_ids", []))).is_empty():
		failures.append("Phase 6 governance should expose resurrection_priority candidates")

func _test_phase6_governance_jurisdiction_and_admissibility_contract(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var run_record := _phase7_run_record(979797)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var learned_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(base_state, run_record, diagnostics, {})
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.normalize({
		"activation_state": {
			"epoch": "fully_active",
			"active_channels": ["constitution", "archive", "world_memory"],
			"dormant_channels": ["safe_mode"],
			"safe_mode_active": false,
			"quarantine_ids": []
		},
		"safe_mode_state": {
			"enabled": false,
			"summary_lines": []
		}
	})
	var theory_surface := THEORY_ENGINE_SCRIPT.build_surface(learned_state, {}, governance_state)
	var stewardship_theory: Dictionary = {}
	for theory_raw in _dict_array_for_test(theory_surface.get("theories", [])):
		var theory: Dictionary = Dictionary(theory_raw)
		if str(theory.get("theory_id", "")).strip_edges() == "theory_exp_stewardship_campaign":
			stewardship_theory = theory
			break
	if stewardship_theory.is_empty():
		failures.append("Phase 6 governance review should keep the stewardship campaign theory available for admissibility review")
	else:
		if str(stewardship_theory.get("jurisdiction", "")).strip_edges().is_empty():
			failures.append("Phase 6 governance review should derive a non-empty jurisdiction label")
		if str(stewardship_theory.get("admissibility_status", "")).strip_edges() != "admissible":
			failures.append("Phase 6 governance review should mark strong supported stewardship carriers as admissible")
		if str(stewardship_theory.get("promotion_status", "")).strip_edges() != "eligible":
			failures.append("Phase 6 governance review should mark admissible official carriers as promotion-eligible")
	var promotion_candidates := _string_array_for_test(Array(theory_surface.get("promotion_candidates", [])))
	if not promotion_candidates.has("theory_exp_stewardship_campaign"):
		failures.append("Phase 6 governance review should only surface admissible stewardship theories as promotion candidates")
	var review_surface := GOVERNANCE_SERVICE_SCRIPT.build_review_surface(governance_state, theory_surface)
	var promotion_review: Dictionary = Dictionary(review_surface.get("promotion_review", {}))
	if str(promotion_review.get("summary_line", "")).strip_edges().is_empty():
		failures.append("Phase 6 review surfaces should expose a compact operator-only promotion summary")
	var promotion_line_count := 0
	for line_variant in Array(review_surface.get("lines", [])):
		if str(line_variant).find("promotion review") != -1:
			promotion_line_count += 1
	if promotion_line_count != 1:
		failures.append("Phase 6 review surfaces should add exactly one compact public-safe promotion line")

func _test_phase6_evaluation_dimensions_and_persistence(failures: Array[String]) -> void:
	var evaluation_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.evaluation_schema()
	for required_dimension in ["dignity_stability", "cognitive_budget_stability", "meta_health"]:
		if not _string_array_for_test(Array(evaluation_schema.get("dimension_keys", []))).has(required_dimension):
			failures.append("Phase 6 evaluation schema should include %s" % required_dimension)
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var run_record := _phase7_run_record(959595)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var experiment_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(base_state, run_record, diagnostics, {})
	var learning_records := _dict_array_for_test(Dictionary(experiment_state.get("learning_state", {})).get("evaluation_records", []))
	if learning_records.is_empty():
		failures.append("Phase 6 evaluation dimension hardening should still yield evaluation records")
	else:
		var first_record: Dictionary = Dictionary(learning_records[0])
		var dimensions: Dictionary = Dictionary(first_record.get("dimensions", {}))
		for required_dimension in ["dignity_stability", "cognitive_budget_stability", "meta_health"]:
			if not dimensions.has(required_dimension):
				failures.append("Phase 6 normalized evaluation records should expose %s" % required_dimension)
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure", "predator rush"]
		}
	}, 969696, 10)
	var summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	var updated_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(WORLD_MEMORY_SERVICE_SCRIPT.default_state(), {
		"run_record": {
			"seed": 969696,
			"expedition_constitution": constitution,
			"expedition_constitution_summary": summary
		},
		"diagnostics": diagnostics,
		"profile": profile
	})
	var lifecycle_families := _dict_array_for_test(Dictionary(updated_world_memory.get("lifecycle_registry", {})).get("families", []))
	var preserved_pathology_family := false
	for family_raw in lifecycle_families:
		var family: Dictionary = Dictionary(family_raw)
		if str(family.get("family_kind", "")).strip_edges() == "pathology" and family.has("dominance_strain"):
			preserved_pathology_family = true
			break
	if not preserved_pathology_family:
		failures.append("Phase 6 world memory persistence should retain non-market lifecycle families with hardening fields")

func _test_wave1_inactive_is_not_optional_defaults(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	var experiment_state: Dictionary = Dictionary(profile.get("delvemind_experiment_state", {}))
	for key in ["observation_store", "procedure_store", "theory_store", "judgment_store", "simulation_chambers", "lineage_registry"]:
		if not experiment_state.has(key):
			failures.append("Wave 1 inactive doctrine carriers should still include %s" % key)
	var world_memory: Dictionary = Dictionary(profile.get("world_memory", {}))
	for key in ["factions", "interpretation_regimes", "regions", "world_mutations", "residue_records", "literacy_tracks", "strategy_clusters", "cognitive_field_climate"]:
		if not world_memory.has(key):
			failures.append("Wave 1 inactive civilization defaults should still include %s" % key)
	var cookbook_state: Dictionary = Dictionary(profile.get("cookbook_state", {}))
	for key in ["fragments", "escalation_stage", "contamination_state", "doctrine_stress_state", "unauthorized_theory_links"]:
		if not cookbook_state.has(key):
			failures.append("Wave 1 inactive cookbook defaults should still include %s" % key)

func _test_ontology_engine_and_compiler_bridge(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["world_memory"] = {
		"institutional_order": {
			"legitimacy_pressure": 3,
			"taboo_heat": 2,
			"custody_pressure": 2,
			"burial_pressure": 2,
			"lines": ["Custody rites are being debated openly."]
		},
		"epistemic_order": {
			"revision_pressure": 2,
			"false_canon_pressure": 2,
			"semantic_drift": 1,
			"lines": ["Verification categories are splitting under revision pressure."]
		},
		"ontology_state": {
			"dominant_ontology": "Witness Verification",
			"uncertainty_philosophy": "counterfactual doubt",
			"counterfactual_heat": 2,
			"lines": ["Threshold categories no longer feel settled."]
		},
		"silence_doctrine": {
			"silence_pressure": 2,
			"unclassified_pressure": 1
		},
		"cookbook_shadow": {
			"fragment_heat": 1,
			"redirection_pressure": 1
		},
		"crawl_network_state": {
			"relay_stress": 1,
			"witness_pressure": 1,
			"bottleneck_pressure": 1
		}
	}
	profile["active_crawl"] = {
		"relay_stress": 1,
		"witness_network": ["public watchers"],
		"relay_bottlenecks": ["bridge handoff"],
		"cohort_pressure": ["escort split"],
		"rumor_shock": ["forged answer"],
		"build_memory": ["custody ritual"],
		"doctrine_memory": ["custody_ritual"]
	}
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Intimate Protocol",
		"gameplay_snapshot": {
			"protocol_state": "Intimate Protocol",
			"group_model": {
				"dominant_build": "Ritual build",
				"group_signals": ["ritual answer"],
				"fault_lines": ["burden split"],
				"model_pressure": ["ritual route"]
			},
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure"]
		}
	}
	var world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(profile, session_context)
	var doctrine_family := DOCTRINE_SCHEMA_REGISTRY_SCRIPT.doctrine_family("custody_ritual")
	var doctrine := {
		"id": "custody_ritual",
		"label": "Custody Ritual",
		"focus_tags": Array(doctrine_family.get("focus_tags", [])).duplicate(true)
	}
	var public_doctrine := {
		"protocol_state": "Intimate Protocol",
		"doctrine_family": "custody_ritual",
		"doctrine_label": "Custody Ritual",
		"pressure_line": "Carry the answer through ritual custody.",
		"world_goal": "Keep the route legible under burden.",
		"dominant_minds": ["Archivist", "Warden"],
		"dominant_forces": ["Memory", "Discovery"],
		"dominant_domains": ["artifact_families", "ritual_families"],
		"pacing_profile": "steady",
		"pressure_grammar": ["Delay", "Convergence"],
		"symbolic_motifs": ["Burden Halos", "Threshold Marks"],
		"item_ecology_bias": "burden rescue",
		"group_tension_bias": "measured caution",
		"archive_tone": "memory custody",
		"convergence_axis": "artifact custody"
	}
	var generation_surface := RUN_GENERATOR_SCRIPT.new().build_generation_contract(515151, {
		"doctrine_family": "custody_ritual",
		"constitution_summary": public_doctrine,
		"public_summary": public_doctrine
	})
	var compile_outputs := CONSTITUTION_COMPILER_SCRIPT.compile(
		515151,
		10,
		world_model,
		doctrine,
		{"lines": ["Artifact custody is shaping what the archive will remember."]},
		public_doctrine,
		{
			"pacing_profile": {"id": "steady", "label": "Steady"},
			"active_minds": [{"id": "archivist", "label": "Archivist"}]
		},
		generation_surface,
		{
			"generation": {"witness_exposure": 1, "rescue_geometry": 1, "ritual_frequency": 1},
			"social": {"private_evidence_ratio": 0, "blame_ambiguity": 0, "obligation_pressure": 1, "hidden_role_density": 0, "coalition_visibility": 0},
			"ecology": {"inhabitant_pressure": 0, "stalking_bias": 0, "anomaly_contamination": 0},
			"economy": {"resource_austerity": 0, "recovery_cushion": 1, "commitment_cost": 1, "lure_abundance": 0},
			"culture": {"public_heat_bias": 0, "archive_emphasis": 1}
		},
		{
			"deduction_clarity": 4,
			"ambiguity_quality": 3,
			"fairness_risk": 0,
			"logic_risk": 0
		},
		[],
		{}
	)
	var compile_failures := CONSTITUTION_COMPILER_SCRIPT.validate_compile_output(compile_outputs)
	if not compile_failures.is_empty():
		failures.append("constitution compiler bridge should validate cleanly once ontology routing is embedded: %s" % "; ".join(compile_failures))
	var compiled_doctrine: Dictionary = Dictionary(compile_outputs.get("doctrine", {}))
	if str(compiled_doctrine.get("lineage_id", "")).strip_edges() != "ritual_custody_lineage":
		failures.append("constitution compiler should enrich doctrine outputs with doctrine-family lineage ownership")
	var ontology_snapshot: Dictionary = Dictionary(compile_outputs.get("ontology_snapshot", {}))
	if Array(ontology_snapshot.get("nodes", [])).size() < 6:
		failures.append("ontology engine should emit a materially populated ontology snapshot instead of a thin placeholder")
	if Array(ontology_snapshot.get("lineages", [])).is_empty():
		failures.append("ontology engine should emit lineage groupings for doctrine-aware routing")
	if Array(ontology_snapshot.get("rediscovery_candidates", [])).is_empty():
		failures.append("ontology engine should surface rediscovery candidates when silence pressure suppresses live ritual modes")
	var ontology_routing: Dictionary = Dictionary(Dictionary(compile_outputs.get("generation_surface", {})).get("ontology_routing", {}))
	if Array(ontology_routing.get("dominant_lineages", [])).is_empty():
		failures.append("constitution compiler should route dominant ontology lineages into generation-facing outputs")
	if not Array(ontology_routing.get("route_bias_tags", [])).has("taboo_threshold"):
		failures.append("ontology routing should express taboo thresholds when taboo-class absences are present")
	if not Array(ontology_routing.get("item_bias_tags", [])).has("verification_dispute"):
		failures.append("ontology routing should express verification dispute when stable verification is absent")
	var experiment_node_states := {}
	for node_raw in Array(ontology_snapshot.get("nodes", [])):
		var node: Dictionary = Dictionary(node_raw)
		if str(node.get("domain", "")).strip_edges() != "experiment_families":
			continue
		var node_id := str(node.get("id", "")).strip_edges()
		if not node_id.begins_with("experiment:"):
			continue
		experiment_node_states[node_id.replace("experiment:", "")] = str(node.get("status", "")).strip_edges()
	if str(experiment_node_states.get("custody_foundation", "")) != "foundational":
		failures.append("ontology experiment nodes should preserve foundational family state from the catalog")
	if str(experiment_node_states.get("archive_wonder_residue", "")) != "archival":
		failures.append("ontology experiment nodes should preserve archival family state from the catalog")
	var compile_metadata: Dictionary = Dictionary(compile_outputs.get("compile_metadata", {}))
	if str(compile_metadata.get("lineage_id", "")).strip_edges() != "ritual_custody_lineage":
		failures.append("compile metadata should preserve doctrine lineage identity for traceability")
	if not Array(compile_metadata.get("validation_failures", [])).is_empty():
		failures.append("compile metadata should remain validation-clean for lawful ontology/compiler outputs")
	if str(compile_metadata.get("doctrine_variant_id", "")).strip_edges().is_empty():
		failures.append("compile metadata should preserve doctrine variant identity for traceability")

func _test_generation_contract_narrowing(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"ready_state": {2: true, 3: true, 4: true},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Traversal build",
				"group_signals": ["route control"],
				"fault_lines": ["split caution"],
				"model_pressure": ["route control"],
				"protocol_weighting": "fracture attention"
			}
		}
	}
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 6060, 10)
	var emitted_contract: Dictionary = Dictionary(directive.get("generation_contract", {}))
	if emitted_contract.is_empty():
		failures.append("Delve should emit an explicit generation_contract artifact for the generator boundary")
	var contract: Dictionary = RUN_GENERATOR_SCRIPT.new().build_generation_contract(6060, directive)
	if JSON.stringify(contract) != JSON.stringify(emitted_contract):
		failures.append("run generator should receive the same explicit generation_contract Delve emitted")
	var expected_keys := [
		"seed",
		"protocol_state",
		"doctrine_family",
		"branch_family",
		"dominant_forces",
		"dominant_minds",
		"pacing_profile",
		"pressure_verbs",
		"symbolic_motifs",
		"item_ecology_bias",
		"group_tension_bias",
		"archive_tone",
		"convergence_axis",
		"relationship_routing",
		"relay_routing",
		"cookbook_routing",
		"civilization_routing",
		"market_routing",
		"lifecycle_routing",
		"encounter_routing",
		"apex_routing",
		"ontology_routing"
	]
	for key in expected_keys:
		if not contract.has(key):
			failures.append("generation contract should include %s" % key)
	for key in contract.keys():
		if not expected_keys.has(str(key)):
			failures.append("generation contract should stay schema-bounded and not include extra key %s" % str(key))
	for banned in ["run_identity", "world_goals", "mind_balance", "causal_audit", "control_surfaces", "surface_summary", "public_summary"]:
		if contract.has(banned):
			failures.append("generation contract should not expose host-only field %s" % banned)

	var poisoned := directive.duplicate(true)
	poisoned["run_identity"] = {
		"pacing_profile": {"id": "volatile"},
		"pressure_grammar": [{"id": "scarcity", "label": "Scarcity"}],
		"symbolic_motifs": [{"id": "split_echoes", "label": "Split Echoes"}]
	}
	poisoned["mind_balance"] = {"notes": ["poisoned mind balance"]}
	poisoned["causal_audit"] = {"violations": ["poisoned audit"]}
	poisoned["world_goals"] = ["poisoned world goal"]
	poisoned["control_surfaces"] = {"generation": {"witness_exposure": -2}, "economy": {"resource_austerity": 2}}
	poisoned["surface_summary"] = {"lines": ["poisoned line"], "strongest": [{"label": "poisoned"}]}
	var poisoned_contract: Dictionary = RUN_GENERATOR_SCRIPT.new().build_generation_contract(6060, poisoned)
	if JSON.stringify(contract) != JSON.stringify(poisoned_contract):
		failures.append("generation contract should ignore host-only extras when public-safe directive fields are already present")

	var generator := RUN_GENERATOR_SCRIPT.new()
	var chain_a := generator.generate_layout(6060, 10, directive)
	var chain_b := generator.generate_layout(6060, 10, poisoned)
	if JSON.stringify(chain_a) != JSON.stringify(chain_b):
		failures.append("generation should consume the narrowed contract view instead of host-only directive internals")
	var chain_c := generator.generate_layout(6060, 10, emitted_contract)
	if JSON.stringify(chain_a) != JSON.stringify(chain_c):
		failures.append("generation should accept the explicit generation_contract as the single narrow generation input")
	if not chain_a.is_empty():
		var branch_context: Dictionary = Dictionary(Dictionary(chain_a[0]).get("branch_context", {}))
		var directive_summary: Dictionary = Dictionary(branch_context.get("directive_summary", {}))
		if directive_summary.has("dominant_domains"):
			failures.append("replicated branch context should not carry legacy dominant_domains after GenerationContract narrowing")
		for banned in ["world_goals", "mind_balance", "causal_audit", "control_surfaces", "run_identity"]:
			if branch_context.has(banned) or directive_summary.has(banned):
				failures.append("replicated branch context should not leak %s after GenerationContract narrowing" % banned)

	var item_service := ITEM_SERVICE_SCRIPT.new()
	var spawns_a := item_service.generate_item_spawns(6060, chain_a, directive)
	var spawns_b := item_service.generate_item_spawns(6060, chain_a, poisoned)
	if JSON.stringify(spawns_a) != JSON.stringify(spawns_b):
		failures.append("item generation should consume the narrowed GenerationContract view instead of host-only directive internals")
	var spawns_c := item_service.generate_item_spawns(6060, chain_a, emitted_contract)
	if JSON.stringify(spawns_a) != JSON.stringify(spawns_c):
		failures.append("item generation should accept the explicit generation_contract as its narrow directive boundary")

func _test_constitution_compiler_symbolic_profiles_and_bounds(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"ready_state": {2: true, 3: true, 4: true},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Traversal build",
				"group_signals": ["route control"],
				"fault_lines": ["split caution"],
				"model_pressure": ["route control"],
				"protocol_weighting": "fracture attention"
			},
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure"]
		}
	}
	var constitution_a := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 515151, 10)
	var constitution_b := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 515151, 10)
	for field in [
		"doctrine_family_id",
		"doctrine_variant_id",
		"generation_seed",
		"topology_profile",
		"chamber_grammar_profile",
		"route_profile",
		"item_ecology_profile",
		"pressure_ecology_profile",
		"information_doctrine_profile",
		"pacing_profile",
		"custody_profile",
		"mutation_permissions",
		"symbolic_motifs",
		"fairness_bounds",
		"compile_metadata"
	]:
		if not constitution_a.has(field):
			failures.append("expedition constitution should materialize symbolic compiler field %s" % field)
	if str(constitution_a.get("doctrine_family_id", "")).strip_edges().is_empty():
		failures.append("constitution compiler should emit a non-empty doctrine_family_id")
	if str(constitution_a.get("doctrine_variant_id", "")).strip_edges().is_empty():
		failures.append("constitution compiler should emit a non-empty doctrine_variant_id")
	if str(constitution_a.get("doctrine_variant_id", "")) != str(constitution_b.get("doctrine_variant_id", "")):
		failures.append("constitution compiler should keep doctrine_variant_id deterministic for identical authored inputs")
	if int(constitution_a.get("generation_seed", 0)) != 515151:
		failures.append("constitution compiler should preserve the authored generation_seed in the final constitution")
	var generation_surface: Dictionary = Dictionary(constitution_a.get("generation_surface", {}))
	var topology_profile: Dictionary = Dictionary(constitution_a.get("topology_profile", {}))
	if str(topology_profile.get("branch_family", "")).strip_edges() != str(generation_surface.get("branch_family", "")).strip_edges():
		failures.append("topology_profile should stay aligned with the compiled generation_surface branch family")
	var chamber_profile: Dictionary = Dictionary(constitution_a.get("chamber_grammar_profile", {}))
	if Array(chamber_profile.get("pressure_verbs", [])).is_empty():
		failures.append("chamber_grammar_profile should preserve compiled pressure verbs")
	var route_profile: Dictionary = Dictionary(constitution_a.get("route_profile", {}))
	if Dictionary(route_profile.get("relationship_routing", {})).is_empty():
		failures.append("route_profile should preserve compiled relationship routing")
	var item_profile: Dictionary = Dictionary(constitution_a.get("item_ecology_profile", {}))
	if str(item_profile.get("item_ecology_bias", "")).strip_edges().is_empty():
		failures.append("item_ecology_profile should preserve a compiled item_ecology_bias")
	if str(item_profile.get("item_ecology_bias", "")).strip_edges() != str(generation_surface.get("item_ecology_bias", "")).strip_edges():
		failures.append("item_ecology_profile should stay aligned with the compiled generation_surface item_ecology_bias")
	var pressure_profile: Dictionary = Dictionary(constitution_a.get("pressure_ecology_profile", {}))
	if Array(pressure_profile.get("pressure_verbs", [])).is_empty():
		failures.append("pressure_ecology_profile should preserve compiled pressure verbs")
	var information_profile: Dictionary = Dictionary(constitution_a.get("information_doctrine_profile", {}))
	if not information_profile.has("witness_exposure"):
		failures.append("information_doctrine_profile should preserve compile-owned witness exposure")
	var pacing_profile: Dictionary = Dictionary(constitution_a.get("pacing_profile", {}))
	if str(pacing_profile.get("id", "")).strip_edges().is_empty():
		failures.append("pacing_profile should preserve the compiled pacing identity")
	var custody_profile: Dictionary = Dictionary(constitution_a.get("custody_profile", {}))
	if not bool(custody_profile.get("artifact_centrality", false)):
		failures.append("custody_profile should preserve artifact centrality")
	var mutation_permissions: Dictionary = Dictionary(constitution_a.get("mutation_permissions", {}))
	if not bool(mutation_permissions.get("runtime_non_authority", false)):
		failures.append("mutation_permissions should preserve runtime_non_authority")
	if not bool(mutation_permissions.get("artifact_centrality_required", false)):
		failures.append("mutation_permissions should preserve artifact_centrality_required")
	if Array(mutation_permissions.get("allowed_domains", [])).is_empty():
		failures.append("mutation_permissions should preserve compile-owned allowed_domains")
	var fairness_bounds: Dictionary = Dictionary(constitution_a.get("fairness_bounds", {}))
	if str(fairness_bounds.get("artifact_trust_floor", "")).strip_edges() != "objective_central":
		failures.append("fairness_bounds should preserve artifact_trust_floor")
	if not bool(fairness_bounds.get("role_fairness_required", false)):
		failures.append("fairness_bounds should preserve role_fairness_required")
	if not bool(fairness_bounds.get("runtime_non_mutation_required", false)):
		failures.append("fairness_bounds should preserve runtime_non_mutation_required")
	if not bool(fairness_bounds.get("no_hidden_targeting_required", false)):
		failures.append("fairness_bounds should preserve no_hidden_targeting_required")
	if not Array(fairness_bounds.get("compile_failures", [])).is_empty():
		failures.append("fairness_bounds should remain validation-clean for a lawful authored constitution")
	var compile_metadata: Dictionary = Dictionary(constitution_a.get("compile_metadata", {}))
	if str(compile_metadata.get("doctrine_family_id", "")).strip_edges() != str(constitution_a.get("doctrine_family_id", "")).strip_edges():
		failures.append("compile_metadata should preserve doctrine_family_id traceability")
	if str(compile_metadata.get("doctrine_variant_id", "")).strip_edges() != str(constitution_a.get("doctrine_variant_id", "")).strip_edges():
		failures.append("compile_metadata should preserve doctrine_variant_id traceability")
	if not Array(compile_metadata.get("required_symbolic_fields", [])).has("fairness_bounds"):
		failures.append("compile_metadata should retain the doctrine-required symbolic field registry")
	if not Array(compile_metadata.get("fairness_bound_failures", [])).is_empty():
		failures.append("compile_metadata should not report fairness-bound failures for a lawful authored constitution")

func _test_narrative_pressure_phase5_compilation_and_surfaces(failures: Array[String]) -> void:
	var policy := {
		"generation": {"witness_exposure": 1, "rescue_geometry": 1, "ritual_frequency": 1},
		"social": {"private_evidence_ratio": 0, "blame_ambiguity": 0, "obligation_pressure": 1, "hidden_role_density": 0, "coalition_visibility": 0},
		"ecology": {"inhabitant_pressure": 0, "stalking_bias": 0, "anomaly_contamination": 0},
		"economy": {"resource_austerity": 0, "recovery_cushion": 1, "commitment_cost": 1, "lure_abundance": 0},
		"culture": {"public_heat_bias": 0, "archive_emphasis": 1}
	}
	var simulation := {
		"deduction_clarity": 4,
		"ambiguity_quality": 3,
		"fairness_risk": 0,
		"logic_risk": 0
	}
	var doctrine_family := DOCTRINE_SCHEMA_REGISTRY_SCRIPT.doctrine_family("custody_ritual")
	var doctrine := {
		"id": "custody_ritual",
		"label": "Custody Ritual",
		"focus_tags": Array(doctrine_family.get("focus_tags", [])).duplicate(true)
	}
	var public_doctrine := {
		"protocol_state": "Intimate Protocol",
		"doctrine_family": "custody_ritual",
		"doctrine_label": "Custody Ritual",
		"pressure_line": "Carry the answer through ritual custody.",
		"world_goal": "Keep the route legible under burden.",
		"dominant_minds": ["Archivist", "Warden"],
		"dominant_forces": ["Memory", "Discovery"],
		"dominant_domains": ["artifact_families", "ritual_families"],
		"pacing_profile": "steady",
		"pressure_grammar": ["Delay", "Convergence"],
		"symbolic_motifs": ["Burden Halos", "Threshold Marks"],
		"item_ecology_bias": "burden rescue",
		"group_tension_bias": "measured caution",
		"archive_tone": "memory custody",
		"convergence_axis": "artifact custody"
	}
	var summary := {"lines": ["Carry the answer through ritual custody."]}
	var run_identity := {
		"pacing_profile": {"id": "steady", "label": "Steady"},
		"active_minds": [{"id": "archivist", "label": "Archivist"}]
	}
	var generator := RUN_GENERATOR_SCRIPT.new()
	var generation_surface := generator.build_generation_contract(884422, {
		"doctrine_family": "custody_ritual",
		"constitution_summary": public_doctrine,
		"public_summary": public_doctrine
	})
	var stewardship_world_model := {
		"social_model": {"alliance_stability": 3, "trust_fragility": 1, "rescue_expectation": 3},
		"route_model": {"route_control": 1, "relay_stress": 1},
		"economy_model": {"recovery_appetite": 1, "burden_tolerance": 3},
		"cultural_model": {
			"legitimacy_pressure": 3,
			"custody_pressure": 3,
			"burial_pressure": 3,
			"sacred_pressure": 3,
			"administrative_pressure": 1,
			"orthodoxy_strength": 2,
			"ritual_spread": 2,
			"counterfactual_heat": 1,
			"revision_pressure": 1,
			"semantic_drift": 0,
			"false_canon_pressure": 0,
			"contradiction_heat": 1,
			"rumor_shock_pressure": 0,
			"paranoia_heat": 0,
			"taboo_heat": 0,
			"punitive_heat": 0,
			"hope_heat": 1,
			"practical_pressure": 1,
			"myth_gravity": 3
		},
		"epoch_model": {"phase": "turning", "transition_pressure": 2},
		"doctrine_model": {},
		"archive_legends": 2,
		"crawl_density": 2,
		"world_focus": "custody rites",
		"world_phase": "turning"
	}
	var skeptical_world_model := {
		"social_model": {"alliance_stability": 0, "trust_fragility": 3, "rescue_expectation": 1},
		"route_model": {"route_control": 2, "relay_stress": 2},
		"economy_model": {"recovery_appetite": 2, "burden_tolerance": 0},
		"cultural_model": {
			"legitimacy_pressure": 0,
			"custody_pressure": 0,
			"burial_pressure": 0,
			"sacred_pressure": 0,
			"administrative_pressure": 0,
			"orthodoxy_strength": 0,
			"ritual_spread": 0,
			"counterfactual_heat": 3,
			"revision_pressure": 3,
			"semantic_drift": 3,
			"false_canon_pressure": 3,
			"contradiction_heat": 3,
			"rumor_shock_pressure": 2,
			"paranoia_heat": 2,
			"taboo_heat": 2,
			"punitive_heat": 1,
			"hope_heat": 0,
			"practical_pressure": 2,
			"uncertainty_philosophy": "counterfactual doubt",
			"myth_gravity": 1
		},
		"epoch_model": {"phase": "fracture", "transition_pressure": 3},
		"doctrine_model": {},
		"archive_legends": 1,
		"crawl_density": 3,
		"world_focus": "split records",
		"world_phase": "turning"
	}
	var ontology_snapshot := {
		"public_lines": ["Archive lines are already under review."],
		"dominant_domains": ["artifact_families", "ritual_families"]
	}
	var compile_a := CONSTITUTION_COMPILER_SCRIPT.compile(
		884422,
		10,
		stewardship_world_model,
		doctrine,
		summary,
		public_doctrine,
		run_identity,
		generation_surface,
		policy,
		simulation,
		[],
		{}
	)
	var compile_b := CONSTITUTION_COMPILER_SCRIPT.compile(
		884422,
		10,
		skeptical_world_model,
		doctrine,
		summary,
		public_doctrine,
		run_identity,
		generation_surface,
		policy,
		simulation,
		[],
		{}
	)
	var pressure_a: Dictionary = Dictionary(compile_a.get("narrative_pressure_state", {}))
	var pressure_b: Dictionary = Dictionary(compile_b.get("narrative_pressure_state", {}))
	if pressure_a.is_empty() or pressure_b.is_empty():
		failures.append("Phase 5 compile outputs should emit an explicit narrative_pressure_state")
	var pressure_a_failures := NARRATIVE_PRESSURE_ENGINE_SCRIPT.validate_state(pressure_a)
	var pressure_b_failures := NARRATIVE_PRESSURE_ENGINE_SCRIPT.validate_state(pressure_b)
	if not pressure_a_failures.is_empty() or not pressure_b_failures.is_empty():
		failures.append("narrative pressure states should validate cleanly: %s | %s" % ["; ".join(pressure_a_failures), "; ".join(pressure_b_failures)])
	if str(pressure_a.get("pressure_family", "")) == str(pressure_b.get("pressure_family", "")):
		failures.append("narrative pressure should materially diverge across opposed world-pressure states")
	if str(Dictionary(compile_a.get("generation_surface", {})).get("archive_tone", "")) == str(Dictionary(compile_b.get("generation_surface", {})).get("archive_tone", "")) and str(Dictionary(compile_a.get("generation_surface", {})).get("convergence_axis", "")) == str(Dictionary(compile_b.get("generation_surface", {})).get("convergence_axis", "")):
		failures.append("narrative pressure should lawfully alter authored possibility-space weighting instead of remaining summary-only")
	if not Array(Dictionary(compile_a.get("compile_metadata", {})).get("required_symbolic_fields", [])).has("narrative_pressure_state"):
		failures.append("compile metadata should register narrative_pressure_state as a required symbolic field once Phase 5 is live")
	if str(Dictionary(compile_a.get("compile_metadata", {})).get("narrative_pressure_schema", "")) != "NarrativePressureState":
		failures.append("compile metadata should preserve narrative pressure schema traceability")
	for banned in ["runtime_state", "event_log", "peer_ids", "role_payload"]:
		if JSON.stringify(pressure_a).find("\"%s\"" % banned) != -1 or JSON.stringify(pressure_b).find("\"%s\"" % banned) != -1:
			failures.append("narrative pressure state should remain outside runtime authority and must not expose %s" % banned)
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["world_memory"] = {
		"fascination": {"current_focus": "custody rites", "current_heat": 4, "phase": "turning"},
		"myth_field": {"resonance_count": 2, "active_lines": ["Older rites are coming back into public view."]},
		"cultural_gravity": {"top_label": "Custody rites", "top_gravity": 4}
	}
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Intimate Protocol",
		"gameplay_snapshot": {"protocol_state": "Intimate Protocol"}
	}
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 884422, 10)
	var constitution_summary: Dictionary = Dictionary(constitution.get("constitution_summary", {}))
	if str(constitution_summary.get("narrative_pressure_family", "")).strip_edges().is_empty():
		failures.append("final constitutions should expose public-safe narrative pressure family output")
	if Array(constitution_summary.get("narrative_pressure_lines", [])).is_empty():
		failures.append("final constitutions should expose public-safe narrative pressure lines")
	var run_record := {
		"expedition_constitution_summary": constitution_summary.duplicate(true),
		"timeline_public_events": [],
		"action_summary": [],
		"key_clues": [],
		"communication_summary": {"total": 0, "danger": 0, "regroup": 0, "artifact": 0},
		"narrative_motion_facts": {},
		"gameplay_signal_snapshot": {},
		"branch_summary": {},
		"outcome_summary": {
			"summary_text": "Recovered cleanly",
			"artifact_result_text": "Authentic artifact extracted",
			"artifact_result": "authentic",
			"expedition_success": true,
			"sabotage_success": false
		}
	}
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	if Array(diagnostics.get("narrative_pressure_lines", [])).is_empty():
		failures.append("run diagnostics should preserve public-safe narrative pressure lines once Phase 5 is live")
	var frame := FRAMING_SERVICE_SCRIPT.build_run_frame(run_record, diagnostics, profile)
	var combined_text := "%s %s" % [str(frame.get("governance_line", "")), str(frame.get("world_pull", ""))]
	if Array(diagnostics.get("narrative_pressure_lines", [])).size() > 0 and combined_text.find(str(Array(diagnostics.get("narrative_pressure_lines", []))[0])) == -1:
		failures.append("framing should surface narrative pressure through the existing public-safe interpretation path once Phase 5 is live")

func _test_experimental_ontology_phase6_compilation_and_surfaces(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["world_memory"] = {
		"institutional_order": {
			"legitimacy_pressure": 3,
			"custody_pressure": 3,
			"burial_pressure": 2,
			"sacred_pressure": 2
		},
		"epistemic_order": {
			"orthodoxy_strength": 1,
			"revision_pressure": 3,
			"semantic_drift": 3,
			"false_canon_pressure": 2
		},
		"ontology_state": {
			"counterfactual_heat": 3,
			"dominant_ontology": "custody fracture",
			"uncertainty_philosophy": "counterfactual doubt"
		},
		"interpretation_network": {
			"spread_heat": 2,
			"contradiction_heat": 3,
			"ritual_spread": 2,
			"institutional_campaigns": 1
		},
		"myth_field": {
			"resonance_count": 2,
			"active_lines": ["Older marks keep reopening the archive."]
		},
		"cultural_gravity": {"top_gravity": 3},
		"fascination": {"current_focus": "custody rites", "phase": "turning", "current_heat": 4},
		"crawl_network_state": {"relay_stress": 2, "witness_pressure": 1, "bottleneck_pressure": 1}
	}
	profile["active_crawl"] = {
		"relay_stress": 2,
		"witness_network": ["public watchers"],
		"relay_bottlenecks": ["bridge handoff"],
		"cohort_pressure": ["escort split"],
		"rumor_shock": ["archive split"],
		"build_memory": ["custody ritual"],
		"doctrine_memory": ["custody_ritual"]
	}
	var experiment_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(profile.get("delvemind_experiment_state", {})))
	var experiment_registry := _dict_array_for_test(Dictionary(experiment_state.get("experiments", {})).values())
	if Dictionary(experiment_state.get("hypotheses", {})).size() < 10 or Dictionary(experiment_state.get("experiments", {})).size() < 10:
		failures.append("Phase 6 should ship a materially populated hypothesis and experiment registry")
	for required_state in ["foundational", "active", "recurring", "rare", "dormant", "archival"]:
		var found := false
		for experiment_raw in experiment_registry:
			if str(Dictionary(experiment_raw).get("state", "")) == required_state:
				found = true
				break
		if not found:
			failures.append("Phase 6 registry should include a %s experiment state" % required_state)
	if Dictionary(experiment_state.get("lineage_index", {})).is_empty():
		failures.append("Phase 6 registry should build a lineage index")
	else:
		if Dictionary(Dictionary(experiment_state.get("lineage_index", {})).get("parent_to_branches", {})).is_empty():
			failures.append("Phase 6 lineage index should preserve parent branch relationships")
		if Dictionary(Dictionary(experiment_state.get("lineage_index", {})).get("synthesis_to_children", {})).is_empty():
			failures.append("Phase 6 lineage index should preserve synthesis relationships")
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Intimate Protocol",
		"gameplay_snapshot": {
			"protocol_state": "Intimate Protocol",
			"group_model": {
				"dominant_build": "Ritual build",
				"group_signals": ["ritual answer"],
				"fault_lines": ["shared burden caution"],
				"model_pressure": ["ritual route"]
			}
		}
	}
	var world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(profile, session_context)
	if Dictionary(world_model.get("experiment_state", {})).is_empty():
		failures.append("world model should carry persistent experiment state into Phase 6 compilation")
	if _string_array_for_test(Array(world_model.get("experiment_lines", []))).is_empty():
		failures.append("world model should expose public-safe experiment lines for downstream traceability")
	var doctrine_family := DOCTRINE_SCHEMA_REGISTRY_SCRIPT.doctrine_family("custody_ritual")
	var doctrine := {
		"id": "custody_ritual",
		"label": "Custody Ritual",
		"focus_tags": Array(doctrine_family.get("focus_tags", [])).duplicate(true)
	}
	var public_doctrine := {
		"protocol_state": "Intimate Protocol",
		"doctrine_family": "custody_ritual",
		"doctrine_label": "Custody Ritual",
		"pressure_line": "Carry the answer through ritual custody.",
		"world_goal": "Keep the route legible under burden.",
		"dominant_minds": ["Archivist", "Warden"],
		"dominant_forces": ["Memory", "Discovery"],
		"dominant_domains": ["artifact_families", "ritual_families"],
		"pacing_profile": "steady",
		"pressure_grammar": ["Delay", "Convergence"],
		"symbolic_motifs": ["Burden Halos", "Threshold Marks"],
		"item_ecology_bias": "burden rescue",
		"group_tension_bias": "measured caution",
		"archive_tone": "memory custody",
		"convergence_axis": "artifact custody"
	}
	var generation_surface := RUN_GENERATOR_SCRIPT.new().build_generation_contract(915551, {
		"doctrine_family": "custody_ritual",
		"constitution_summary": public_doctrine,
		"public_summary": public_doctrine
	})
	var ontology_snapshot := ONTOLOGY_ENGINE_SCRIPT.build_snapshot(915551, world_model, doctrine, public_doctrine, generation_surface)
	var ontology_routing := ONTOLOGY_ENGINE_SCRIPT.build_generation_routing(ontology_snapshot, generation_surface, doctrine_family)
	var compiled_a := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.compile_state(
		Dictionary(world_model.get("experiment_state", {})),
		world_model,
		doctrine,
		public_doctrine,
		generation_surface,
		ontology_snapshot,
		ontology_routing
	)
	var compiled_b := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.compile_state(
		Dictionary(world_model.get("experiment_state", {})),
		world_model,
		doctrine,
		public_doctrine,
		generation_surface,
		ontology_snapshot,
		ontology_routing
	)
	if JSON.stringify(compiled_a) != JSON.stringify(compiled_b):
		failures.append("Phase 6 compile state should remain deterministic for identical inputs")
	var compile_failures := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.validate_compile_state(compiled_a)
	if not compile_failures.is_empty():
		failures.append("Phase 6 compile state should validate cleanly: %s" % "; ".join(compile_failures))
	if _string_array_for_test(Array(compiled_a.get("live_experiment_ids", []))).is_empty():
		failures.append("Phase 6 compile state should activate at least one live experiment family")
	if _dict_array_for_test(compiled_a.get("grammar_manifest", [])).is_empty():
		failures.append("Phase 6 compile state should emit an explicit grammar manifest")
	if not Dictionary(compiled_a.get("compile_outputs", {})).has("pressure_input_bias"):
		failures.append("Phase 6 compile state should emit bounded pressure input bias")
	if Dictionary(Dictionary(compiled_a.get("lineage_index", {})).get("rediscovery_hooks", {})).is_empty():
		failures.append("Phase 6 compile state should preserve rediscovery hooks in its lineage index")
	for retired_output in ["legitimacy_stress", "rumor_volatility", "wonder_allocation"]:
		if Dictionary(compiled_a.get("compile_outputs", {})).has(retired_output):
			failures.append("Phase 6 compile state should not expose retired compile output scalar %s" % retired_output)
	for banned in ["runtime_state", "event_log", "peer_ids", "artifact_truth_override"]:
		if JSON.stringify(compiled_a).find("\"%s\"" % banned) != -1:
			failures.append("Phase 6 compile state must not expose runtime-only field %s" % banned)
	var constitution_a := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 915551, 10)
	var constitution_b := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 915551, 10)
	var experimental_state_a: Dictionary = Dictionary(constitution_a.get("experimental_ontology_state", {}))
	var experimental_state_b: Dictionary = Dictionary(constitution_b.get("experimental_ontology_state", {}))
	if experimental_state_a.is_empty():
		failures.append("final constitutions should carry experimental_ontology_state once Phase 6 is live")
	if JSON.stringify(experimental_state_a) != JSON.stringify(experimental_state_b):
		failures.append("constitution experimental_ontology_state should remain deterministic for identical authored inputs")
	if not DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.validate_compile_state(experimental_state_a).is_empty():
		failures.append("constitution experimental_ontology_state should validate cleanly once persisted")
	for retired_output in ["legitimacy_stress", "rumor_volatility", "wonder_allocation"]:
		if Dictionary(experimental_state_a.get("compile_outputs", {})).has(retired_output):
			failures.append("persisted experimental_ontology_state should not retain retired compile output scalar %s" % retired_output)
	var constitution_summary: Dictionary = Dictionary(constitution_a.get("constitution_summary", {}))
	if _string_array_for_test(Array(constitution_summary.get("experiment_surface_lines", []))).is_empty():
		failures.append("constitution summary should surface public-safe experiment lines once Phase 6 is live")
	if _string_array_for_test(Array(constitution_summary.get("experiment_families", []))).is_empty():
		failures.append("constitution summary should surface experiment family labels once Phase 6 is live")
	var compile_metadata: Dictionary = Dictionary(constitution_a.get("compile_metadata", {}))
	if str(compile_metadata.get("experiment_schema", "")) != "DelveMindExperiment":
		failures.append("compile metadata should preserve experiment schema traceability once Phase 6 is live")
	if not Array(compile_metadata.get("required_symbolic_fields", [])).has("experimental_ontology_state"):
		failures.append("compile metadata should register experimental_ontology_state as a required symbolic field")
	if not Array(compile_metadata.get("experiment_validation_failures", [])).is_empty():
		failures.append("compile metadata should not report experiment validation failures for lawful Phase 6 outputs")
	var run_record := {
		"expedition_constitution_summary": constitution_summary.duplicate(true),
		"timeline_public_events": [],
		"action_summary": [],
		"key_clues": [],
		"communication_summary": {"total": 0, "danger": 0, "regroup": 0, "artifact": 0},
		"narrative_motion_facts": {},
		"gameplay_signal_snapshot": {},
		"branch_summary": {},
		"outcome_summary": {
			"summary_text": "Recovered cleanly",
			"artifact_result_text": "Authentic artifact extracted",
			"artifact_result": "authentic",
			"expedition_success": true,
			"sabotage_success": false
		}
	}
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	if _string_array_for_test(Array(diagnostics.get("experiment_surface_lines", []))).is_empty():
		failures.append("run diagnostics should preserve public-safe experiment lines once Phase 6 is live")
	var frame := FRAMING_SERVICE_SCRIPT.build_run_frame(run_record, diagnostics, profile)
	var combined_text := "%s %s" % [str(frame.get("governance_line", "")), str(frame.get("world_pull", ""))]
	var expected_line := ""
	var diagnostic_experiment_lines := _string_array_for_test(Array(diagnostics.get("experiment_surface_lines", [])))
	if not diagnostic_experiment_lines.is_empty():
		expected_line = diagnostic_experiment_lines[0]
	if not expected_line.is_empty() and combined_text.find(expected_line) == -1:
		failures.append("framing should surface public-safe experiment texture through the existing governance/world-pull path")

func _test_phase6_doctrine_vocabulary_and_compile_honesty(failures: Array[String]) -> void:
	var experiment_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.experiment_schema()
	var supported_sections := _string_array_for_test(Array(experiment_schema.get("supported_compile_output_sections", [])))
	for required_section in ["constitution_weighting", "ontology_weighting", "pressure_input_bias", "archive_framing_bias", "public_activation"]:
		if not supported_sections.has(required_section):
			failures.append("Phase 6 cleanup should keep %s as an explicitly supported compile output section" % required_section)
	for retired_output in ["legitimacy_stress", "rumor_volatility", "wonder_allocation"]:
		if supported_sections.has(retired_output):
			failures.append("Phase 6 cleanup should retire %s from supported compile output sections" % retired_output)
	for family_raw in DOCTRINE_SCHEMA_REGISTRY_SCRIPT.experiment_families():
		var family: Dictionary = Dictionary(family_raw)
		var compile_outputs: Dictionary = Dictionary(Dictionary(family.get("experiment", {})).get("compile_outputs", {}))
		for retired_output in ["legitimacy_stress", "rumor_volatility", "wonder_allocation"]:
			if compile_outputs.has(retired_output):
				failures.append("Phase 6 cleanup should retire %s from family %s compile outputs" % [retired_output, str(family.get("id", ""))])
		for section_key in compile_outputs.keys():
			var section := str(section_key).strip_edges()
			if section == "compile_targets":
				continue
			if not supported_sections.has(section):
				failures.append("Phase 6 family %s should only emit supported compile output sections, got %s" % [str(family.get("id", "")), section])

func _test_phase6_persistence_and_lineage_cleanup(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var lineage_index: Dictionary = Dictionary(base_state.get("lineage_index", {}))
	if Dictionary(lineage_index.get("rediscovery_hooks", {})).is_empty():
		failures.append("Phase 6 lineage index should preserve rediscovery hooks for dormant and archival experiments")
	if not _string_array_for_test(Array(Dictionary(lineage_index.get("state_bands", {})).get("archival", []))).has("exp_archive_wonder_residue"):
		failures.append("Phase 6 lineage state bands should preserve archival experiment ids")
	if not _string_array_for_test(Array(Dictionary(lineage_index.get("state_bands", {})).get("dormant", []))).has("exp_taxonomy_dormant"):
		failures.append("Phase 6 lineage state bands should preserve dormant experiment ids")

	var broken_state: Dictionary = base_state.duplicate(true)
	var broken_hypotheses: Dictionary = Dictionary(broken_state.get("hypotheses", {})).duplicate(true)
	var broken_experiments: Dictionary = Dictionary(broken_state.get("experiments", {})).duplicate(true)
	var broken_hypothesis: Dictionary = Dictionary(broken_hypotheses.get("hyp_stewardship_campaign", {})).duplicate(true)
	broken_hypothesis["open_branches"] = ["exp_missing_branch"]
	broken_hypotheses["hyp_stewardship_campaign"] = broken_hypothesis
	var broken_experiment: Dictionary = Dictionary(broken_experiments.get("exp_stewardship_campaign", {})).duplicate(true)
	broken_experiment["lineage_parent_id"] = "exp_missing_parent"
	broken_experiment["branch_ids"] = ["exp_missing_branch"]
	broken_experiment["synthesis_sources"] = ["exp_missing_source"]
	broken_experiment["hypothesis_id"] = "hyp_missing"
	broken_experiments["exp_stewardship_campaign"] = broken_experiment
	broken_state["hypotheses"] = broken_hypotheses
	broken_state["experiments"] = broken_experiments
	var validation_text := "; ".join(DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.validate_state(broken_state))
	for expected_fragment in [
		"open_branches references missing experiment exp_missing_branch",
		"references missing hypothesis hyp_missing",
		"lineage_parent_id exp_missing_parent is missing",
		"branch_id exp_missing_branch is missing",
		"synthesis_source exp_missing_source is missing"
	]:
		if validation_text.find(expected_fragment) == -1:
			failures.append("Phase 6 validation should report %s" % expected_fragment)

	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var before_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(profile.get("delvemind_experiment_state", {})))
	var before_experiment: Dictionary = Dictionary(Dictionary(before_state.get("experiments", {})).get("exp_custody_foundation", {})).duplicate(true)
	var before_hypothesis: Dictionary = Dictionary(Dictionary(before_state.get("hypotheses", {})).get("hyp_custody_foundation", {})).duplicate(true)
	var run_record := {
		"seed": 515151,
		"local_role": "Archivist",
		"role_result_success": true,
		"timeline_public_events": [],
		"action_summary": [],
		"key_clues": [],
		"communication_summary": {"total": 0, "danger": 0, "regroup": 0, "artifact": 0},
		"narrative_motion_facts": {},
		"gameplay_signal_snapshot": {},
		"branch_summary": {},
		"expedition_constitution_summary": {
			"experiment_families": ["Custody Foundation"],
			"experiment_surface_lines": ["Older custody habits are quietly shaping what the route calls important."]
		},
		"outcome_summary": {
			"summary_text": "Recovered cleanly",
			"artifact_result_text": "Authentic artifact extracted",
			"artifact_result": "authentic",
			"expedition_success": true,
			"sabotage_success": false
		}
	}
	var first_apply := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var first_profile: Dictionary = Dictionary(first_apply.get("profile", {}))
	var first_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(first_profile.get("delvemind_experiment_state", {})))
	var first_experiment: Dictionary = Dictionary(Dictionary(first_state.get("experiments", {})).get("exp_custody_foundation", {})).duplicate(true)
	if int(first_experiment.get("manifest_count", 0)) != int(before_experiment.get("manifest_count", 0)) + 1:
		failures.append("Phase 6 persistence continuity should increment experiment manifest_count when a family manifests")
	if int(first_experiment.get("last_manifested_seed", 0)) != 515151:
		failures.append("Phase 6 persistence continuity should preserve last_manifested_seed")
	if str(first_experiment.get("last_manifested_role", "")).strip_edges() != "Archivist":
		failures.append("Phase 6 persistence continuity should preserve last_manifested_role")
	if _string_array_for_test(Array(first_state.get("history_lines", []))).is_empty():
		failures.append("Phase 6 persistence continuity should record a public-safe experiment history line")
	if int(Dictionary(Dictionary(first_state.get("hypotheses", {})).get("hyp_custody_foundation", {})).get("confidence", -1)) != int(before_hypothesis.get("confidence", -2)):
		failures.append("Phase 6 persistence continuity should not mutate hypothesis confidence")
	if JSON.stringify(Dictionary(first_experiment.get("fairness_bounds", {}))) != JSON.stringify(Dictionary(before_experiment.get("fairness_bounds", {}))):
		failures.append("Phase 6 persistence continuity should not mutate experiment fairness bounds")
	var second_apply := PROFILE_SERVICE_SCRIPT.apply_run_record(first_profile, run_record, catalog)
	var second_profile: Dictionary = Dictionary(second_apply.get("profile", {}))
	var second_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(second_profile.get("delvemind_experiment_state", {})))
	var second_experiment: Dictionary = Dictionary(Dictionary(second_state.get("experiments", {})).get("exp_custody_foundation", {})).duplicate(true)
	if int(second_experiment.get("manifest_count", 0)) != int(first_experiment.get("manifest_count", 0)) + 1:
		failures.append("Phase 6 persistence continuity should evolve across runs instead of remaining static storage")

func _phase6_curated_family_map() -> Dictionary:
	var result: Dictionary = {}
	for family_raw in DOCTRINE_SCHEMA_REGISTRY_SCRIPT.experiment_families():
		var family: Dictionary = Dictionary(family_raw).duplicate(true)
		var family_id := str(family.get("id", "")).strip_edges()
		if not family_id.is_empty():
			result[family_id] = family
	return result

func _curated_phenomenon_governance_state() -> Dictionary:
	return GOVERNANCE_SERVICE_SCRIPT.normalize({
		"activation_state": {
			"epoch": "fully_active",
			"active_channels": ["constitution", "archive", "world_memory"],
			"dormant_channels": ["safe_mode"],
			"safe_mode_active": false,
			"quarantine_ids": []
		},
		"safe_mode_state": {
			"enabled": false,
			"summary_lines": []
		},
		"anti_bottleneck_reports": [{
			"report_id": "anti_summary_curated",
			"status": "stable",
			"summary_lines": ["summary-only anti-bottleneck review remained quiet"]
		}, {
			"report_id": "anti_detail_curated",
			"status": "blocked",
			"bottleneck_flags": ["theory_monopoly"],
			"summary_lines": ["detailed anti-bottleneck review found monopoly pressure"]
		}],
		"play_routing_reports": [{
			"report_id": "play_summary_curated",
			"status": "stable",
			"baseline_routes": ["movement", "burden", "witness", "route_choice"],
			"summary_lines": ["summary-only play-routing review stayed compact"]
		}, {
			"report_id": "play_detail_curated",
			"status": "blocked",
			"baseline_routes": ["movement", "burden", "rescue", "witness", "route_choice", "artifact_custody", "hesitation", "extraction", "return"],
			"missing_routes": ["movement", "return"],
			"summary_lines": ["detailed play-routing review lost movement and return"]
		}]
	})

func _phase6_curated_compile_context(governance_state: Dictionary = {}) -> Dictionary:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["world_memory"] = {
		"institutional_order": {
			"legitimacy_pressure": 3,
			"custody_pressure": 3,
			"burial_pressure": 2,
			"sacred_pressure": 2
		},
		"epistemic_order": {
			"orthodoxy_strength": 1,
			"revision_pressure": 3,
			"semantic_drift": 3,
			"false_canon_pressure": 2
		},
		"ontology_state": {
			"counterfactual_heat": 3,
			"dominant_ontology": "custody fracture",
			"uncertainty_philosophy": "counterfactual doubt"
		},
		"interpretation_network": {
			"spread_heat": 2,
			"contradiction_heat": 3,
			"ritual_spread": 2,
			"institutional_campaigns": 1
		},
		"myth_field": {
			"resonance_count": 2,
			"active_lines": ["Older marks keep reopening the archive."]
		},
		"cultural_gravity": {"top_gravity": 3},
		"fascination": {"current_focus": "custody rites", "phase": "turning", "current_heat": 4},
		"crawl_network_state": {"relay_stress": 2, "witness_pressure": 1, "bottleneck_pressure": 1}
	}
	profile["active_crawl"] = {
		"relay_stress": 2,
		"witness_network": ["public watchers"],
		"relay_bottlenecks": ["bridge handoff"],
		"cohort_pressure": ["escort split"],
		"rumor_shock": ["archive split"],
		"build_memory": ["custody ritual"],
		"doctrine_memory": ["custody_ritual"]
	}
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Intimate Protocol",
		"gameplay_snapshot": {
			"protocol_state": "Intimate Protocol",
			"group_model": {
				"dominant_build": "Ritual build",
				"group_signals": ["ritual answer"],
				"fault_lines": ["shared burden caution"],
				"model_pressure": ["ritual route"]
			}
		}
	}
	var world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(profile, session_context)
	if not governance_state.is_empty():
		world_model["governance_state"] = GOVERNANCE_SERVICE_SCRIPT.normalize(governance_state)
	var doctrine_family := DOCTRINE_SCHEMA_REGISTRY_SCRIPT.doctrine_family("custody_ritual")
	var doctrine := {
		"id": "custody_ritual",
		"label": "Custody Ritual",
		"focus_tags": Array(doctrine_family.get("focus_tags", [])).duplicate(true)
	}
	var public_doctrine := {
		"protocol_state": "Intimate Protocol",
		"doctrine_family": "custody_ritual",
		"doctrine_label": "Custody Ritual",
		"pressure_line": "Carry the answer through ritual custody.",
		"world_goal": "Keep the route legible under burden.",
		"dominant_minds": ["Archivist", "Warden"],
		"dominant_forces": ["Memory", "Discovery"],
		"dominant_domains": ["artifact_families", "ritual_families"],
		"pacing_profile": "steady",
		"pressure_grammar": ["Delay", "Convergence"],
		"symbolic_motifs": ["Burden Halos", "Threshold Marks"],
		"item_ecology_bias": "burden rescue",
		"group_tension_bias": "measured caution",
		"archive_tone": "memory custody",
		"convergence_axis": "artifact custody"
	}
	var generation_surface := RUN_GENERATOR_SCRIPT.new().build_generation_contract(915551, {
		"doctrine_family": "custody_ritual",
		"constitution_summary": public_doctrine,
		"public_summary": public_doctrine
	})
	var ontology_snapshot := ONTOLOGY_ENGINE_SCRIPT.build_snapshot(915551, world_model, doctrine, public_doctrine, generation_surface)
	var ontology_routing := ONTOLOGY_ENGINE_SCRIPT.build_generation_routing(ontology_snapshot, generation_surface, doctrine_family)
	return {
		"world_model": world_model,
		"doctrine": doctrine,
		"public_doctrine": public_doctrine,
		"generation_surface": generation_surface,
		"ontology_snapshot": ontology_snapshot,
		"ontology_routing": ontology_routing
	}

func _test_phase6_curated_phenomenon_family_contract(failures: Array[String]) -> void:
	var family_map := _phase6_curated_family_map()
	var normalized_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var normalized_experiments: Dictionary = Dictionary(normalized_state.get("experiments", {})).duplicate(true)
	var reference_fairness := JSON.stringify(Dictionary(Dictionary(family_map.get("archive_wonder_residue", {})).get("experiment", {})).get("fairness_bounds", {}))
	var expected_fields := {
		"palimpsest": {
			"domain": "memory",
			"state": "archival",
			"target_layers": ["archive", "framing", "continuity"],
			"target": "archive",
			"axis": "memory_fidelity",
			"stressor": "contradiction",
			"ontology_condition": "hybrid_lineage_emergence",
			"cultural_medium": "archive_case",
			"time_horizon": "long_arc",
			"observation_contract": "traceable_archive_only",
			"topology_type": "synthesis",
			"expression_mode": "archive_bias",
			"compile_targets": ["archive_framing_bias", "public_activation"],
			"lineage_parent_id": "exp_archive_wonder_residue",
			"synthesis_sources": ["exp_archive_wonder_residue", "exp_fracture_echo"]
		},
		"negative_space": {
			"domain": "negative_space",
			"state": "dormant",
			"target_layers": ["ontology", "archive", "continuity"],
			"target": "ontology",
			"axis": "ambiguity",
			"stressor": "classification_drift",
			"ontology_condition": "missing_verification_classes",
			"cultural_medium": "archive_case",
			"time_horizon": "seasonal",
			"observation_contract": "constitution_trace",
			"topology_type": "branching",
			"expression_mode": "archive_bias",
			"compile_targets": ["ontology_weighting", "archive_framing_bias", "public_activation"],
			"lineage_parent_id": "exp_taxonomy_dormant",
			"synthesis_sources": []
		},
		"echo_literacy": {
			"domain": "memory",
			"state": "rare",
			"target_layers": ["archive", "framing", "continuity"],
			"target": "continuity",
			"axis": "curiosity",
			"stressor": "archive_echo",
			"ontology_condition": "residue_density_spike",
			"cultural_medium": "legend_cluster",
			"time_horizon": "long_arc",
			"observation_contract": "traceable_archive_only",
			"topology_type": "synthesis",
			"expression_mode": "archive_bias",
			"compile_targets": ["pressure_input_bias", "archive_framing_bias", "public_activation"],
			"lineage_parent_id": "exp_ritual_recall",
			"synthesis_sources": ["exp_archive_wonder_residue", "exp_ritual_recall"]
		},
		"contraband_lite": {
			"domain": "public_argument",
			"state": "rare",
			"target_layers": ["pressure", "archive", "framing"],
			"target": "framing",
			"axis": "legitimacy_formation",
			"stressor": "rumor_acceleration",
			"ontology_condition": "contested_categories",
			"cultural_medium": "public_shorthand",
			"time_horizon": "short_cycle",
			"observation_contract": "public_safe_summary",
			"topology_type": "branching",
			"expression_mode": "public_surface",
			"compile_targets": ["public_activation"],
			"lineage_parent_id": "exp_fracture_echo",
			"synthesis_sources": []
		}
	}
	for family_id in expected_fields.keys():
		if not family_map.has(family_id):
			failures.append("Curated phenomenon contract should expose family %s" % family_id)
			continue
		var family: Dictionary = Dictionary(family_map.get(family_id, {})).duplicate(true)
		var experiment: Dictionary = Dictionary(family.get("experiment", {})).duplicate(true)
		var expected: Dictionary = Dictionary(expected_fields.get(family_id, {}))
		if str(family.get("domain", "")).strip_edges() != str(expected.get("domain", "")).strip_edges():
			failures.append("Curated phenomenon family %s should keep domain %s" % [family_id, str(expected.get("domain", ""))])
		if str(family.get("state", "")).strip_edges() != str(expected.get("state", "")).strip_edges():
			failures.append("Curated phenomenon family %s should keep state %s" % [family_id, str(expected.get("state", ""))])
		if JSON.stringify(Array(family.get("target_layers", []))) != JSON.stringify(Array(expected.get("target_layers", []))):
			failures.append("Curated phenomenon family %s should keep target_layers %s" % [family_id, JSON.stringify(expected.get("target_layers", []))])
		for field in ["target", "axis", "stressor", "ontology_condition", "cultural_medium", "time_horizon", "observation_contract", "topology_type", "expression_mode", "lineage_parent_id"]:
			if str(experiment.get(field, "")).strip_edges() != str(expected.get(field, "")).strip_edges():
				failures.append("Curated phenomenon family %s should keep experiment field %s = %s" % [family_id, field, str(expected.get(field, ""))])
		var actual_targets := _string_array_for_test(Array(Dictionary(experiment.get("compile_outputs", {})).get("compile_targets", [])))
		var expected_targets := _string_array_for_test(Array(expected.get("compile_targets", [])))
		actual_targets.sort()
		expected_targets.sort()
		if JSON.stringify(actual_targets) != JSON.stringify(expected_targets):
			failures.append("Curated phenomenon family %s should keep compile_targets %s" % [family_id, JSON.stringify(expected_targets)])
		if JSON.stringify(Array(experiment.get("synthesis_sources", []))) != JSON.stringify(Array(expected.get("synthesis_sources", []))):
			failures.append("Curated phenomenon family %s should keep synthesis_sources %s" % [family_id, JSON.stringify(expected.get("synthesis_sources", []))])
		if not Array(experiment.get("branch_ids", [])).is_empty():
			failures.append("Curated phenomenon family %s should keep branch_ids empty in this bounded pass" % family_id)
		if not Array(Dictionary(family.get("hypothesis", {})).get("open_branches", [])).is_empty():
			failures.append("Curated phenomenon family %s should keep hypothesis open_branches empty in this bounded pass" % family_id)
		if JSON.stringify(Dictionary(experiment.get("fairness_bounds", {}))) != reference_fairness:
			failures.append("Curated phenomenon family %s should copy the shipped fairness bounds verbatim" % family_id)
		var public_lines := _string_array_for_test(Array(family.get("public_lines", [])))
		var experiment_public_lines := _string_array_for_test(Array(experiment.get("public_lines", [])))
		var surface_lines := _string_array_for_test(Array(Dictionary(Dictionary(experiment.get("compile_outputs", {})).get("public_activation", {})).get("surface_lines", [])))
		if JSON.stringify(public_lines) != JSON.stringify(experiment_public_lines) or JSON.stringify(public_lines) != JSON.stringify(surface_lines):
			failures.append("Curated phenomenon family %s should keep family, experiment, and public activation lines aligned" % family_id)
		var normalized_experiment := Dictionary(normalized_experiments.get(str(experiment.get("experiment_id", "")).strip_edges(), experiment)).duplicate(true)
		var experiment_failures := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.validate_experiment(normalized_experiment)
		if not experiment_failures.is_empty():
			failures.append("Curated phenomenon family %s should validate cleanly: %s" % [family_id, "; ".join(experiment_failures)])

func _test_phase6_curated_phenomenon_schema_proof(failures: Array[String]) -> void:
	var experiment_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.experiment_schema()
	var family_map := _phase6_curated_family_map()
	var registry_file := FileAccess.open("res://src/gen/doctrine_schema_registry.gd", FileAccess.READ)
	var registry_text := registry_file.get_as_text() if registry_file != null else ""
	for family_id in ["palimpsest", "negative_space", "echo_literacy", "contraband_lite"]:
		if registry_text.find("\"id\": \"%s\"" % family_id) == -1:
			failures.append("Curated phenomenon fallback registry should mirror family %s" % family_id)
	var schema_fields := {
		"domain": "allowed_domains",
		"target": "allowed_targets",
		"axis": "allowed_axes",
		"stressor": "allowed_stressors",
		"ontology_condition": "allowed_ontology_conditions",
		"cultural_medium": "allowed_cultural_media",
		"time_horizon": "allowed_time_horizons",
		"observation_contract": "allowed_observation_contracts",
		"topology_type": "allowed_topology_types",
		"expression_mode": "allowed_expression_modes"
	}
	for family_id in ["palimpsest", "negative_space", "echo_literacy", "contraband_lite"]:
		var family: Dictionary = Dictionary(family_map.get(family_id, {})).duplicate(true)
		var experiment: Dictionary = Dictionary(family.get("experiment", {})).duplicate(true)
		if family.is_empty() or experiment.is_empty():
			continue
		if not _string_array_for_test(Array(experiment_schema.get("allowed_domains", []))).has(str(family.get("domain", "")).strip_edges()):
			failures.append("Curated phenomenon schema proof should keep family domain %s inside allowed_domains" % str(family.get("domain", "")))
		for field in schema_fields.keys():
			var value := str(experiment.get(field, family.get(field, ""))).strip_edges()
			var allowed := _string_array_for_test(Array(experiment_schema.get(str(schema_fields.get(field, "")), [])))
			if not allowed.has(value):
				failures.append("Curated phenomenon schema proof should keep %s=%s inside %s" % [field, value, str(schema_fields.get(field, ""))])
		var grammar_failures := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT._validate_grammar_slots(experiment, experiment_schema)
		if not grammar_failures.is_empty():
			failures.append("Curated phenomenon schema proof should keep %s grammar-compatible: %s" % [family_id, "; ".join(grammar_failures)])

func _test_phase6_curated_phenomenon_governance_bias_from_persisted_reports(failures: Array[String]) -> void:
	var governance_state := _curated_phenomenon_governance_state()
	var context := _phase6_curated_compile_context(governance_state)
	var world_model: Dictionary = Dictionary(context.get("world_model", {})).duplicate(true)
	var experiments: Dictionary = Dictionary(Dictionary(world_model.get("experiment_state", {})).get("experiments", {})).duplicate(true)
	var negative_trace := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT._governance_bias_trace(Dictionary(experiments.get("exp_negative_space", {})).duplicate(true), world_model)
	var echo_trace := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT._governance_bias_trace(Dictionary(experiments.get("exp_echo_literacy", {})).duplicate(true), world_model)
	var palimpsest_trace := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT._governance_bias_trace(Dictionary(experiments.get("exp_palimpsest", {})).duplicate(true), world_model)
	var contraband_trace := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT._governance_bias_trace(Dictionary(experiments.get("exp_contraband_lite", {})).duplicate(true), world_model)
	if int(negative_trace.get("total_bias", -1)) != 2:
		failures.append("Curated phenomenon governance bias should give negative_space +2 from blocked anti-bottleneck and missing routes")
	if int(echo_trace.get("total_bias", -1)) != 2:
		failures.append("Curated phenomenon governance bias should give echo_literacy +2 from blocked anti-bottleneck and missing routes")
	if int(palimpsest_trace.get("total_bias", -1)) != 0:
		failures.append("Curated phenomenon governance bias should not boost palimpsest")
	if int(contraband_trace.get("total_bias", -1)) != 0:
		failures.append("Curated phenomenon governance bias should not boost contraband_lite")
	if not _string_array_for_test(Array(negative_trace.get("bottleneck_flags", []))).has("theory_monopoly"):
		failures.append("Curated phenomenon governance bias should scan past summary-only anti-bottleneck reports to find bottleneck_flags")
	if not _string_array_for_test(Array(negative_trace.get("missing_routes", []))).has("movement"):
		failures.append("Curated phenomenon governance bias should scan past summary-only play-routing reports to find missing_routes")
	var compiled := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.compile_state(
		Dictionary(world_model.get("experiment_state", {})).duplicate(true),
		world_model,
		Dictionary(context.get("doctrine", {})).duplicate(true),
		Dictionary(context.get("public_doctrine", {})).duplicate(true),
		Dictionary(context.get("generation_surface", {})).duplicate(true),
		Dictionary(context.get("ontology_snapshot", {})).duplicate(true),
		Dictionary(context.get("ontology_routing", {})).duplicate(true)
	)
	var activation_trace: Dictionary = Dictionary(Dictionary(compiled.get("compiler_trace", {})).get("activation_trace", {}))
	if int(Dictionary(Dictionary(activation_trace.get("exp_negative_space", {})).get("governance_bias", {})).get("total_bias", -1)) != 2:
		failures.append("Curated phenomenon compile traces should expose governance_bias on exp_negative_space")
	if int(Dictionary(Dictionary(activation_trace.get("exp_echo_literacy", {})).get("governance_bias", {})).get("total_bias", -1)) != 2:
		failures.append("Curated phenomenon compile traces should expose governance_bias on exp_echo_literacy")

func _test_phase6_curated_phenomenon_cookbook_containment(failures: Array[String]) -> void:
	var family_map := _phase6_curated_family_map()
	for family_id in ["palimpsest", "negative_space", "echo_literacy", "contraband_lite"]:
		var family: Dictionary = Dictionary(family_map.get(family_id, {})).duplicate(true)
		if family.is_empty():
			continue
		var experiment: Dictionary = Dictionary(family.get("experiment", {})).duplicate(true)
		var public_text := "%s %s %s" % [
			JSON.stringify(Array(family.get("public_lines", []))),
			JSON.stringify(Array(experiment.get("public_lines", []))),
			JSON.stringify(Array(Dictionary(Dictionary(experiment.get("compile_outputs", {})).get("public_activation", {})).get("surface_lines", [])))
		]
		var lowered_public := public_text.to_lower()
		for banned_fragment in ["cookbook", "exploit", "cheat", "how to", "must ", "should "]:
			if lowered_public.find(banned_fragment) != -1:
				failures.append("Curated phenomenon public-safe copy should avoid banned fragment %s in %s" % [banned_fragment, family_id])
		var lowered_full := JSON.stringify(family).to_lower()
		for banned_fragment in ["cookbook", "exploit", "cheat"]:
			if lowered_full.find(banned_fragment) != -1:
				failures.append("Curated phenomenon family %s should avoid banned fragment %s" % [family_id, banned_fragment])
	var contraband_experiment: Dictionary = Dictionary(Dictionary(family_map.get("contraband_lite", {})).get("experiment", {})).duplicate(true)
	var contraband_targets := _string_array_for_test(Array(Dictionary(contraband_experiment.get("compile_outputs", {})).get("compile_targets", [])))
	if JSON.stringify(contraband_targets) != JSON.stringify(["public_activation"]):
		failures.append("Curated phenomenon cookbook containment should keep contraband_lite limited to public_activation")
	var contraband_trace := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT._governance_bias_trace(
		contraband_experiment,
		{"governance_state": _curated_phenomenon_governance_state()}
	)
	if int(contraband_trace.get("total_bias", -1)) != 0:
		failures.append("Curated phenomenon cookbook containment should keep contraband_lite out of governance boosts")

func _test_phase6_curated_phenomenon_rarity_and_plurality(failures: Array[String]) -> void:
	var neutral_context := _phase6_curated_compile_context()
	var neutral_compiled := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.compile_state(
		Dictionary(Dictionary(neutral_context.get("world_model", {})).get("experiment_state", {})),
		Dictionary(neutral_context.get("world_model", {})).duplicate(true),
		Dictionary(neutral_context.get("doctrine", {})).duplicate(true),
		Dictionary(neutral_context.get("public_doctrine", {})).duplicate(true),
		Dictionary(neutral_context.get("generation_surface", {})).duplicate(true),
		Dictionary(neutral_context.get("ontology_snapshot", {})).duplicate(true),
		Dictionary(neutral_context.get("ontology_routing", {})).duplicate(true)
	)
	var blocked_context := _phase6_curated_compile_context(_curated_phenomenon_governance_state())
	var blocked_compiled := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.compile_state(
		Dictionary(Dictionary(blocked_context.get("world_model", {})).get("experiment_state", {})),
		Dictionary(blocked_context.get("world_model", {})).duplicate(true),
		Dictionary(blocked_context.get("doctrine", {})).duplicate(true),
		Dictionary(blocked_context.get("public_doctrine", {})).duplicate(true),
		Dictionary(blocked_context.get("generation_surface", {})).duplicate(true),
		Dictionary(blocked_context.get("ontology_snapshot", {})).duplicate(true),
		Dictionary(blocked_context.get("ontology_routing", {})).duplicate(true)
	)
	var neutral_trace: Dictionary = Dictionary(Dictionary(neutral_compiled.get("compiler_trace", {})).get("activation_trace", {}))
	var blocked_trace: Dictionary = Dictionary(Dictionary(blocked_compiled.get("compiler_trace", {})).get("activation_trace", {}))
	if int(Dictionary(neutral_trace.get("exp_negative_space", {})).get("final_score", 0)) >= int(Dictionary(blocked_trace.get("exp_negative_space", {})).get("final_score", 0)):
		failures.append("Curated phenomenon rarity/plurality should raise negative_space score under blocked governance")
	if int(Dictionary(neutral_trace.get("exp_echo_literacy", {})).get("final_score", 0)) >= int(Dictionary(blocked_trace.get("exp_echo_literacy", {})).get("final_score", 0)):
		failures.append("Curated phenomenon rarity/plurality should raise echo_literacy score under blocked governance")
	if int(Dictionary(neutral_trace.get("exp_contraband_lite", {})).get("final_score", 0)) != int(Dictionary(blocked_trace.get("exp_contraband_lite", {})).get("final_score", 0)):
		failures.append("Curated phenomenon rarity/plurality should leave contraband_lite score unchanged under governance biasing")
	if Array(blocked_compiled.get("live_experiment_ids", [])).size() > 3:
		failures.append("Curated phenomenon rarity/plurality should keep top-three selection semantics intact")

func _test_phase6_shell_proof_fast_path(failures: Array[String]) -> void:
	var lobby_file := FileAccess.open("res://src/ui/lobby_controller.gd", FileAccess.READ)
	if lobby_file == null:
		failures.append("Phase 6 proof shell fast path should remain readable in lobby_controller")
	else:
		var lobby_source := lobby_file.get_as_text()
		for required_snippet in [
			"var headless_cli_shell_latched: bool = false",
			"headless_cli_shell_latched = headless_cli_shell_mode_for_test(DisplayServer.get_name(), cli_mode, cli_auto_ready, cli_auto_start)",
			"static func headless_cli_shell_mode_for_test(display_name: String, mode: String, auto_ready: bool, auto_start: bool) -> bool:",
			"return normalized_display.find(\"headless\") != -1 and (not mode.is_empty() or auto_ready or auto_start)"
		]:
			if lobby_source.find(required_snippet) == -1:
				failures.append("Phase 6 proof shell fast path should preserve lobby_controller snippet %s" % required_snippet)
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var emitted_offers: Array[Dictionary] = []
	manager.reconnect_offer_changed.connect(func(offer: Dictionary) -> void:
		emitted_offers.append(offer.duplicate(true))
	)
	var reconnect_offer := manager.build_reconnect_offer_for_test("client", "127.0.0.1", 2456, "proof audit", true)
	manager._set_reconnect_offer(reconnect_offer)
	manager._set_reconnect_offer(reconnect_offer)
	manager.clear_reconnect_offer()
	manager.clear_reconnect_offer()
	if emitted_offers.size() != 2:
		failures.append("Phase 6 proof reconnect fix should only emit when the reconnect offer actually changes")
	elif bool(Dictionary(emitted_offers[0]).get("available", false)) != true or not Dictionary(emitted_offers[1]).is_empty():
		failures.append("Phase 6 proof reconnect fix should emit one concrete offer and one clear event")
	manager.free()

func _phase7_run_record(seed: int, overrides: Dictionary = {}) -> Dictionary:
	var base := {
		"seed": seed,
		"local_role": "Archivist",
		"role_result_success": true,
		"manifested_experiment_ids": ["exp_stewardship_campaign"],
		"live_experiment_ids": ["exp_stewardship_campaign"],
		"live_hypothesis_ids": ["hyp_stewardship_campaign"],
		"timeline_public_events": [
			{"type": "artifact_picked", "tick": 1, "room_id": "vault"},
			{"type": "artifact_dropped", "tick": 2, "room_id": "vault"},
			{"type": "extraction_window_started", "tick": 3, "room_id": "threshold"},
			{"type": "extraction_completed", "tick": 5, "room_id": "threshold"}
		],
		"action_summary": [
			"Picked up the artifact under pressure",
			"Escorted the burden through the extraction window",
			"Closed the route cleanly"
		],
		"key_clues": [
			"Artifact route held through the threshold",
			"Custody marks stayed public",
			"Recovery pressure stayed visible"
		],
		"communication_summary": {"total": 3, "danger": 1, "regroup": 2, "artifact": 1},
		"narrative_motion_facts": {},
		"gameplay_signal_snapshot": {
			"group_model": {
				"dominant_build": "Rescue build",
				"group_signals": ["ritual answer"],
				"fault_lines": ["shared caution"],
				"model_pressure": ["artifact custody"]
			}
		},
		"branch_summary": {},
		"expedition_constitution_summary": {
			"experiment_families": ["Stewardship Campaign"],
			"experiment_surface_lines": ["Stewardship claims are starting to travel faster than extraction talk."],
			"experiment_expression_modes": ["mirror_mode"],
			"experiment_horizons": ["short_cycle"],
			"live_experiment_ids": ["exp_stewardship_campaign"],
			"live_hypothesis_ids": ["hyp_stewardship_campaign"],
			"surface_summary": {"lines": ["Carry the answer carefully."]},
			"protocol_state": "Intimate Protocol",
			"doctrine_family": "custody_ritual",
			"doctrine_label": "Custody Ritual",
			"pressure_line": "Carry the answer through ritual custody.",
			"world_goal": "Keep the route legible under burden.",
			"dominant_minds": ["Archivist"],
			"dominant_forces": ["Memory"],
			"dominant_domains": ["artifact_families"],
			"pacing_profile": "steady",
			"pressure_grammar": ["Delay"],
			"symbolic_motifs": ["Threshold Marks"],
			"item_ecology_bias": "burden stewardship",
			"group_tension_bias": "measured caution",
			"archive_tone": "memory custody",
			"convergence_axis": "artifact custody"
		},
		"outcome_summary": {
			"summary_text": "Recovered cleanly",
			"artifact_result_text": "Authentic artifact extracted",
			"artifact_result": "authentic",
			"expedition_success": true,
			"sabotage_success": false
		}
	}
	for key in overrides.keys():
		base[key] = overrides[key]
	return base

func _phase8_run_record(seed: int, overrides: Dictionary = {}) -> Dictionary:
	var base := _phase7_run_record(seed)
	base["communication_summary"] = {"total": 0, "danger": 0, "regroup": 2, "artifact": 1}
	base["action_summary"] = [
		"Held position while the burden crossed the threshold",
		"Escorted the artifact without breaking cover",
		"Marked the route quietly for the return"
	]
	base["key_clues"] = [
		"inspect marks kept the threshold legible",
		"echo traces proved the burden route stayed open",
		"mark pulses showed the return path held"
	]
	base["timeline_public_events"] = [
		{"type": "artifact_picked", "tick": 1, "room_id": "vault"},
		{"type": "artifact_dropped", "tick": 2, "room_id": "vault"},
		{"type": "extraction_window_started", "tick": 4, "room_id": "threshold"},
		{"type": "extraction_completed", "tick": 6, "room_id": "threshold"}
	]
	var gameplay_snapshot: Dictionary = Dictionary(base.get("gameplay_signal_snapshot", {})).duplicate(true)
	gameplay_snapshot["resource_pressure"] = ["fallback strain", "escort fatigue"]
	var group_model: Dictionary = Dictionary(gameplay_snapshot.get("group_model", {})).duplicate(true)
	group_model["dominant_build"] = "Rescue build"
	group_model["group_signals"] = ["quiet burden answer"]
	group_model["fault_lines"] = []
	group_model["model_pressure"] = ["burden rescue answer"]
	gameplay_snapshot["group_model"] = group_model
	base["gameplay_signal_snapshot"] = gameplay_snapshot
	var expedition_summary: Dictionary = Dictionary(base.get("expedition_constitution_summary", {})).duplicate(true)
	expedition_summary["peak_structure_lines"] = [
		"the burden peak stayed readable without turning into spectacle"
	]
	base["expedition_constitution_summary"] = expedition_summary
	base["local_aftermath"] = {
		"aftermath_id": "local_aftermath_%d" % seed,
		"source_id": "encounter_quiet_hold",
		"source_kind": "encounter",
		"affected_room_slots": [3, 4],
		"immediate_route_state": "threshold stabilized",
		"custody_state_delta": "artifact stayed publicly carried",
		"evidence_state_delta": "threshold marks stayed readable",
		"resource_state_delta": "escort fatigue remained manageable",
		"residual_telegraph_tags": ["quiet_return", "burden_hold"],
		"narrative_residue_tags": ["measured_return", "quiet_pressure"]
	}
	base["world_aftermath_refs"] = [
		{
			"schema_name": "WorldAftermathRef",
			"schema_version": 1,
			"aftermath_id": "world_aftermath_%d" % seed,
			"source_id": "encounter_quiet_hold",
			"source_kind": "encounter",
			"apex_id": "",
			"local_aftermath_id": "local_aftermath_%d" % seed,
			"continuity_seed_tags": ["measured_return", "quiet_pressure"],
			"return_pressure_tags": ["measured_return", "quiet_reentry"],
			"route_state_hint": "threshold stabilized",
			"successor_hint_ids": ["threshold_trial_apex"]
		}
	]
	for key in overrides.keys():
		base[key] = overrides[key]
	return base

func _test_phase7_evaluation_schema_and_owner(failures: Array[String]) -> void:
	var evaluation_schema: Dictionary = DOCTRINE_SCHEMA_REGISTRY_SCRIPT.evaluation_schema()
	for required_dimension in [
		"hypothesis_yield",
		"cultural_richness",
		"ontological_productivity",
		"narrative_resonance",
		"fairness_stability",
		"dignity_stability",
		"cognitive_budget_stability",
		"readability",
		"replay_distinctiveness",
		"long_horizon_branch_value",
		"meta_health"
	]:
		if not _string_array_for_test(Array(evaluation_schema.get("dimension_keys", []))).has(required_dimension):
			failures.append("Phase 7 evaluation schema should include doctrine dimension %s" % required_dimension)
	for required_outcome in [
		"strengthen_hypothesis",
		"weaken_hypothesis",
		"split_hypothesis",
		"synthesize_broader_theory",
		"move_to_recurring",
		"move_to_rare",
		"move_to_dormant",
		"preserve_archival_lineage",
		"elevate_foundational_inquiry"
	]:
		if not _string_array_for_test(Array(evaluation_schema.get("allowed_outcomes", []))).has(required_outcome):
			failures.append("Phase 7 evaluation schema should include doctrine outcome %s" % required_outcome)
	for required_effect in [
		"confidence_delta",
		"recurrence_delta",
		"state_transition",
		"persistence_transition",
		"branch_pressure_family",
		"branch_open_ids",
		"synthesis_experiment_id",
		"synthesis_source_ids",
		"revive_candidate",
		"fairness_vetoed"
	]:
		if not _string_array_for_test(Array(evaluation_schema.get("continuity_effects_required_fields", []))).has(required_effect):
			failures.append("Phase 7 evaluation schema should include nested continuity field %s" % required_effect)
	for required_signature in [
		"story_tone",
		"artifact_result",
		"local_role",
		"build_identity",
		"topology_type",
		"time_horizon",
		"cultural_medium",
		"expression_mode",
		"retellability_score",
		"legend_density_score",
		"revisit_score",
		"interrupted"
	]:
		if not _string_array_for_test(Array(evaluation_schema.get("observation_signature_required_fields", []))).has(required_signature):
			failures.append("Phase 7 evaluation schema should include nested observation field %s" % required_signature)
	var learning_state := DELVEMIND_LEARNING_LOOP_SCRIPT.default_learning_state()
	var learning_failures := DELVEMIND_LEARNING_LOOP_SCRIPT.validate_learning_state(learning_state)
	if not learning_failures.is_empty():
		failures.append("Phase 7 learning owner should validate its default learning state cleanly: %s" % "; ".join(learning_failures))
	var compiler_guidance: Dictionary = Dictionary(learning_state.get("compiler_guidance", {}))
	for key in [
		"preferred_topologies",
		"suppressed_topologies",
		"preferred_horizons",
		"suppressed_horizons",
		"preferred_media",
		"suppressed_media",
		"branch_pressure_families",
		"synthesis_candidates",
		"revive_candidates",
		"accepted_evaluation_ids",
		"evaluation_count",
		"branch_signal_counts",
		"synthesis_signal_counts",
		"revive_signal_counts",
		"bias_basis",
		"public_lines",
		"operator_lines"
	]:
		if not compiler_guidance.has(key):
			failures.append("Phase 7 learning owner should expose compiler_guidance key %s" % key)
	if not Dictionary(compiler_guidance.get("bias_basis", {})).has("topology_averages"):
		failures.append("Phase 7 compiler guidance should carry nested bias_basis trace fields")

func _test_phase7_learning_loop_determinism_and_continuity(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var run_record := _phase7_run_record(616161)
	var before_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(profile.get("delvemind_experiment_state", {})))
	var before_hypothesis: Dictionary = Dictionary(Dictionary(before_state.get("hypotheses", {})).get("hyp_stewardship_campaign", {})).duplicate(true)
	var before_experiment: Dictionary = Dictionary(Dictionary(before_state.get("experiments", {})).get("exp_stewardship_campaign", {})).duplicate(true)
	var first_apply := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var second_apply := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var first_profile: Dictionary = Dictionary(first_apply.get("profile", {}))
	var second_profile: Dictionary = Dictionary(second_apply.get("profile", {}))
	if JSON.stringify(Dictionary(first_profile.get("delvemind_experiment_state", {}))) != JSON.stringify(Dictionary(second_profile.get("delvemind_experiment_state", {}))):
		failures.append("Phase 7 learning updates should remain deterministic for identical profile and run inputs")
	var updated_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(Dictionary(first_profile.get("delvemind_experiment_state", {})))
	var learning_state: Dictionary = Dictionary(updated_state.get("learning_state", {}))
	var learning_records := _dict_array_for_test(learning_state.get("evaluation_records", []))
	if learning_records.is_empty():
		failures.append("Phase 7 should record at least one evaluation record after a manifested experiment run")
	var first_record: Dictionary = Dictionary(learning_records[0]) if not learning_records.is_empty() else {}
	if str(first_record.get("experiment_id", "")).strip_edges() != "exp_stewardship_campaign":
		failures.append("Phase 7 learning should attribute manifested experiments through canonical experiment ids")
	var updated_hypothesis: Dictionary = Dictionary(Dictionary(updated_state.get("hypotheses", {})).get("hyp_stewardship_campaign", {})).duplicate(true)
	var updated_experiment: Dictionary = Dictionary(Dictionary(updated_state.get("experiments", {})).get("exp_stewardship_campaign", {})).duplicate(true)
	if int(updated_hypothesis.get("confidence", -1)) < int(before_hypothesis.get("confidence", -1)):
		failures.append("Phase 7 learning should not weaken a strong stewardship manifestation into lower confidence")
	if str(updated_experiment.get("state", "")).strip_edges() != "recurring":
		failures.append("Phase 7 learning should move a strong active stewardship experiment into recurring state")
	if int(updated_experiment.get("recurrence_weight", -1)) <= int(before_experiment.get("recurrence_weight", -1)):
		failures.append("Phase 7 learning should raise recurrence_weight for a strong recurring-worthy experiment")
	if _string_array_for_test(Array(learning_state.get("public_lines", []))).is_empty():
		failures.append("Phase 7 learning should emit public-safe learning lines after evaluation")
	if _string_array_for_test(Array(Dictionary(learning_state.get("meta_learning", {})).get("accepted_evaluation_ids", []))).is_empty():
		failures.append("Phase 7 learning should track canonical accepted evaluation ids in meta_learning")
	if int(Dictionary(learning_state.get("compiler_guidance", {})).get("evaluation_count", 0)) != learning_records.size():
		failures.append("Phase 7 compiler guidance should keep evaluation_count aligned with canonical evaluation_records")
	if _string_array_for_test(Array(Dictionary(first_profile.get("last_run", {})).get("experiment_learning_lines", []))).is_empty():
		failures.append("Profile continuity should surface Phase 7 learning lines in last_run")
	if not _string_array_for_test(Array(Dictionary(first_profile.get("last_run", {})).get("manifested_experiment_ids", []))).has("exp_stewardship_campaign"):
		failures.append("Profile continuity should preserve canonical manifested_experiment_ids for post-run traceability")

func _test_phase7_promotion_requires_admissibility_evidence(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var experiments := Dictionary(base_state.get("experiments", {})).duplicate(true)
	var stewardship_experiment := Dictionary(experiments.get("exp_stewardship_campaign", {})).duplicate(true)
	stewardship_experiment["state"] = "active"
	experiments["exp_stewardship_campaign"] = stewardship_experiment
	base_state["experiments"] = experiments
	var default_governance := GOVERNANCE_SERVICE_SCRIPT.default_state()
	var theory_surface_without := THEORY_ENGINE_SCRIPT.build_surface(base_state, {}, default_governance)
	var stewardship_without: Dictionary = {}
	for theory_raw in _dict_array_for_test(theory_surface_without.get("theories", [])):
		var theory: Dictionary = Dictionary(theory_raw)
		if str(theory.get("theory_id", "")).strip_edges() == "theory_exp_stewardship_campaign":
			stewardship_without = theory
			break
	if stewardship_without.is_empty():
		failures.append("Phase 7 promotion gating should keep the stewardship theory available before evidence arrives")
	else:
		if str(stewardship_without.get("admissibility_status", "")).strip_edges() != "insufficient":
			failures.append("Phase 7 promotion gating should keep promotion-insufficient theories marked insufficient before evidence arrives")
	if _string_array_for_test(Array(theory_surface_without.get("promotion_candidates", []))).has("theory_exp_stewardship_campaign"):
		failures.append("Phase 7 promotion gating should not surface candidates before admissibility evidence exists")
	var run_record := _phase7_run_record(989898)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var learned_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(base_state, run_record, diagnostics, {})
	var theory_surface_with := THEORY_ENGINE_SCRIPT.build_surface(learned_state, {}, default_governance)
	if not _string_array_for_test(Array(theory_surface_with.get("promotion_candidates", []))).has("theory_exp_stewardship_campaign"):
		failures.append("Phase 7 promotion gating should surface the stewardship carrier once admissibility evidence exists")
	var quarantined_governance := GOVERNANCE_SERVICE_SCRIPT.normalize({
		"activation_state": {
			"epoch": "fully_active",
			"active_channels": ["constitution"],
			"dormant_channels": ["safe_mode"],
			"safe_mode_active": false,
			"quarantine_ids": ["theory_exp_stewardship_campaign"]
		},
		"safe_mode_state": {
			"enabled": false,
			"summary_lines": []
		}
	})
	var theory_surface_quarantined := THEORY_ENGINE_SCRIPT.build_surface(learned_state, {}, quarantined_governance)
	var stewardship_quarantined: Dictionary = {}
	for theory_raw in _dict_array_for_test(theory_surface_quarantined.get("theories", [])):
		var theory: Dictionary = Dictionary(theory_raw)
		if str(theory.get("theory_id", "")).strip_edges() == "theory_exp_stewardship_campaign":
			stewardship_quarantined = theory
			break
	if _string_array_for_test(Array(theory_surface_quarantined.get("promotion_candidates", []))).has("theory_exp_stewardship_campaign"):
		failures.append("Phase 7 promotion gating should remove quarantined theories from promotion candidates")
	if stewardship_quarantined.is_empty():
		failures.append("Phase 7 promotion gating should keep quarantined stewardship theories inspectable for operator review")
	else:
		var promotion_status := str(stewardship_quarantined.get("promotion_status", "")).strip_edges()
		if promotion_status not in ["cooling", "blocked"]:
			failures.append("Phase 7 promotion gating should cool or block quarantined stewardship carriers")

func _test_phase7_immutable_fields_and_invalid_transitions(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var run_record := _phase7_run_record(717171)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var experiment_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(
		base_state,
		run_record,
		diagnostics,
		{}
	)
	var before_experiment: Dictionary = Dictionary(Dictionary(base_state.get("experiments", {})).get("exp_stewardship_campaign", {})).duplicate(true)
	var after_experiment: Dictionary = Dictionary(Dictionary(experiment_state.get("experiments", {})).get("exp_stewardship_campaign", {})).duplicate(true)
	for immutable_field in ["family_id", "program_id", "target", "axis", "stressor", "ontology_condition", "cultural_medium", "time_horizon", "observation_contract", "topology_type", "expression_mode"]:
		if JSON.stringify(after_experiment.get(immutable_field)) != JSON.stringify(before_experiment.get(immutable_field)):
			failures.append("Phase 7 learning should keep experiment field %s immutable" % immutable_field)
	var invalid_record := {
		"evaluation_id": "eval_invalid_transition",
		"run_seed": 1,
		"hypothesis_id": "hyp_custody_foundation",
		"experiment_id": "exp_custody_foundation",
		"family_id": "custody_foundation",
		"dimensions": {
			"hypothesis_yield": 4,
			"cultural_richness": 4,
			"ontological_productivity": 4,
			"narrative_resonance": 4,
			"fairness_stability": 4,
			"readability": 4,
			"replay_distinctiveness": 4,
			"long_horizon_branch_value": 4
		},
		"outcomes": ["strengthen_hypothesis"],
		"supporting_evidence": ["seed_1"],
		"contradicting_evidence": [],
		"continuity_effects": {
			"confidence_delta": 1,
			"recurrence_delta": 0,
			"state_transition": {"from": "foundational", "to": "dormant"},
			"persistence_transition": {"from": "foundational", "to": "dormant"},
			"branch_pressure_family": "",
			"branch_open_ids": [],
			"synthesis_experiment_id": "",
			"synthesis_source_ids": [],
			"revive_candidate": "",
			"fairness_vetoed": false
		},
		"observation_signature": {
			"story_tone": "Quiet",
			"artifact_result": "authentic",
			"local_role": "Archivist",
			"build_identity": "Rescue build",
			"topology_type": "linear",
			"time_horizon": "short_cycle",
			"cultural_medium": "rumor_field",
			"expression_mode": "mirror_mode",
			"retellability_score": 3,
			"legend_density_score": 2,
			"revisit_score": 2,
			"interrupted": false,
			"runtime_state": "illegal"
		},
		"public_trace_lines": ["Illegal"],
		"operator_trace_lines": []
	}
	var invalid_text := "; ".join(DELVEMIND_LEARNING_LOOP_SCRIPT.validate_evaluation_record(
		invalid_record,
		Dictionary(base_state.get("hypotheses", {})),
		Dictionary(base_state.get("experiments", {}))
	))
	if invalid_text.find("state transition foundational -> dormant is not allowed") == -1:
		failures.append("Phase 7 validation should reject invalid foundational state transitions")
	if invalid_text.find("must not expose runtime-only fields") == -1:
		failures.append("Phase 7 validation should reject runtime-only fields in evaluation records")
	var canonical_record := DELVEMIND_LEARNING_LOOP_SCRIPT._normalize_evaluation_record(invalid_record)
	canonical_record["evaluation_id"] = "eval_user_supplied"
	var canonical_text := "; ".join(DELVEMIND_LEARNING_LOOP_SCRIPT.validate_evaluation_record(
		canonical_record,
		Dictionary(base_state.get("hypotheses", {})),
		Dictionary(base_state.get("experiments", {}))
	))
	if canonical_text.find("evaluation_id must match canonical content") == -1:
		failures.append("Phase 7 validation should reject non-canonical supplied evaluation ids")

func _test_phase7_compiler_guidance_and_public_traces(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var run_record := _phase7_run_record(818181, {
		"timeline_public_events": [
			{"type": "artifact_picked", "tick": 1, "room_id": "vault"},
			{"type": "extraction_window_started", "tick": 2, "room_id": "threshold"},
			{"type": "extraction_completed", "tick": 4, "room_id": "threshold"}
		],
		"action_summary": ["Closed the route cleanly", "Kept the burden public"],
		"key_clues": ["Stewardship line held", "The answer stayed readable"],
		"communication_summary": {"total": 2, "danger": 0, "regroup": 1, "artifact": 1},
		"gameplay_signal_snapshot": {
			"group_model": {
				"dominant_build": "Rescue build",
				"group_signals": ["public care"],
				"fault_lines": ["shared caution"],
				"model_pressure": ["artifact custody"]
			}
		}
	})
	var applied := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var updated_profile: Dictionary = Dictionary(applied.get("profile", {}))
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Intimate Protocol",
		"gameplay_snapshot": {
			"protocol_state": "Intimate Protocol",
			"group_model": {
				"dominant_build": "Rescue build",
				"group_signals": ["public care"],
				"fault_lines": ["shared caution"],
				"model_pressure": ["artifact custody"]
			}
		}
	}
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(updated_profile, session_context, 818181, 10)
	var experimental_state: Dictionary = Dictionary(constitution.get("experimental_ontology_state", {}))
	var learning_guidance: Dictionary = Dictionary(experimental_state.get("learning_guidance", {}))
	var creative_governance: Dictionary = Dictionary(constitution.get("creative_governance", Dictionary(experimental_state.get("creative_governance", {}))))
	if learning_guidance.is_empty():
		failures.append("Phase 7 constitution outputs should carry compiler-facing learning_guidance")
	if creative_governance.is_empty():
		failures.append("Phase 7 constitution outputs should carry a creative_governance profile")
	if _string_array_for_test(Array(learning_guidance.get("preferred_topologies", []))).is_empty():
		failures.append("Phase 7 compiler-facing guidance should learn preferred topologies")
	if _string_array_for_test(Array(learning_guidance.get("public_lines", []))).is_empty():
		failures.append("Phase 7 compiler-facing guidance should emit public-safe learning lines")
	if str(Dictionary(creative_governance.get("novelty_envelope", {})).get("active_band", "")).strip_edges().is_empty():
		failures.append("Phase 7 creative_governance should expose a novelty_envelope active_band")
	if _string_array_for_test(Array(creative_governance.get("bounded_surface_ids", []))).is_empty():
		failures.append("Phase 7 creative_governance should expose bounded_surface_ids")
	var constitution_summary: Dictionary = Dictionary(constitution.get("constitution_summary", {}))
	var summary_lines := _string_array_for_test(Array(constitution_summary.get("experiment_surface_lines", [])))
	var learned_public_lines := _string_array_for_test(Array(learning_guidance.get("public_lines", [])))
	var learned_public_line := learned_public_lines[0] if not learned_public_lines.is_empty() else ""
	if not learned_public_line.is_empty() and summary_lines.has(learned_public_line):
		failures.append("Phase 7 constitution summary should keep learned guidance separate from public experiment texture")
	var compile_metadata: Dictionary = Dictionary(constitution.get("compile_metadata", {}))
	if str(compile_metadata.get("evaluation_schema", "")) != "DelveMindEvaluation":
		failures.append("Phase 7 compile metadata should preserve evaluation schema traceability")
	if Dictionary(compile_metadata.get("experiment_learning_bias_trace", {})).is_empty():
		failures.append("Phase 7 compile metadata should expose explicit experiment_learning_bias_trace")
	if str(compile_metadata.get("creative_personality_band", "")).strip_edges().is_empty():
		failures.append("Phase 7 compile metadata should expose creative_personality_band")
	var compiler_trace: Dictionary = Dictionary(constitution.get("compiler_trace", {}))
	var bias_trace: Dictionary = Dictionary(Dictionary(compiler_trace.get("experimental_ontology", {})).get("learning_guidance_bias_trace", {}))
	if bias_trace.is_empty():
		failures.append("Phase 7 compiler trace should expose explicit learning_guidance_bias_trace")
	else:
		var stewardship_trace: Dictionary = Dictionary(bias_trace.get("exp_stewardship_campaign", {}))
		if typeof(stewardship_trace.get("total_bias", null)) not in [TYPE_INT, TYPE_FLOAT]:
			failures.append("Phase 7 compiler trace should expose numeric learned-bias totals per experiment")
		if not (stewardship_trace.get("applied_tokens", []) is Array):
			failures.append("Phase 7 compiler trace should expose applied guidance-bias tokens per experiment")
	if JSON.stringify(experimental_state).find("\"runtime_state\"") != -1:
		failures.append("Phase 7 compiler-facing state must not expose runtime-only fields")
	var cognitive_field_state: Dictionary = Dictionary(constitution.get("cognitive_field_state", {}))
	if _string_array_for_test(Array(cognitive_field_state.get("self_interpretation_trace", []))).is_empty():
		failures.append("Phase 7 cognitive_field_state should expose self_interpretation_trace")
	if _string_array_for_test(Array(cognitive_field_state.get("unknown_space_markers", []))).is_empty():
		failures.append("Phase 7 cognitive_field_state should expose unknown_space_markers")
	var mind_projections := _dict_array_for_test(constitution.get("mind_projections", []))
	if mind_projections.is_empty():
		failures.append("Phase 7 constitutions should continue to expose mind_projections")
	else:
		var first_projection: Dictionary = Dictionary(mind_projections[0])
		if str(first_projection.get("personality_mode", "")).strip_edges().is_empty():
			failures.append("Phase 7 mind projections should expose personality_mode")
		if str(first_projection.get("mind_projection_intent", "")).strip_edges().is_empty():
			failures.append("Phase 7 mind projections should expose mind_projection_intent")
	var world_model := DELVE_WORLD_MODEL_SCRIPT.build_model(updated_profile, session_context)
	if Dictionary(world_model.get("creative_governance", {})).is_empty():
		failures.append("Phase 7 world-model intake should carry creative_governance through the existing DelveMind seam")
	var overview_lines := PROFILE_SERVICE_SCRIPT.build_home_overview_lines(updated_profile, session_context, catalog)
	var diagnostic_lines := PROFILE_SERVICE_SCRIPT.build_last_run_diagnostic_lines(updated_profile)
	if "\n".join(overview_lines).find("Research:") == -1:
		failures.append("Phase 7 product shell should surface learning guidance in home overview lines")
	if "\n".join(diagnostic_lines).find("Research:") == -1:
		failures.append("Phase 7 product shell should surface learning guidance in last-run diagnostics")

func _test_phase7_duplicate_evaluation_dedup_and_meta_consistency(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var run_record := _phase7_run_record(828282)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var first_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(base_state, run_record, diagnostics, {})
	var second_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(first_state, run_record, diagnostics, {})
	var first_learning: Dictionary = Dictionary(first_state.get("learning_state", {}))
	var second_learning: Dictionary = Dictionary(second_state.get("learning_state", {}))
	if JSON.stringify(Array(first_learning.get("evaluation_records", []))) != JSON.stringify(Array(second_learning.get("evaluation_records", []))):
		failures.append("Phase 7 duplicate evaluations should not drift canonical evaluation_records on repeated identical runs")
	if JSON.stringify(Dictionary(first_learning.get("meta_learning", {}))) != JSON.stringify(Dictionary(second_learning.get("meta_learning", {}))):
		failures.append("Phase 7 duplicate evaluations should not drift meta_learning after canonical dedupe")
	if JSON.stringify(Dictionary(first_learning.get("compiler_guidance", {}))) != JSON.stringify(Dictionary(second_learning.get("compiler_guidance", {}))):
		failures.append("Phase 7 duplicate evaluations should not drift compiler_guidance after canonical dedupe")

func _test_phase7_manifestation_identity_and_collision_handling(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var experiments := Dictionary(base_state.get("experiments", {})).duplicate(true)
	var collision_experiment: Dictionary = Dictionary(experiments.get("exp_custody_foundation", {})).duplicate(true)
	collision_experiment["family_label"] = "Stewardship Campaign"
	collision_experiment["public_lines"] = ["Stewardship claims are starting to travel faster than extraction talk."]
	experiments["exp_custody_foundation"] = collision_experiment
	base_state["experiments"] = experiments
	base_state = DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize(base_state)
	var run_record := _phase7_run_record(838383)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var learned_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(base_state, run_record, diagnostics, {})
	var learning_records := _dict_array_for_test(Dictionary(learned_state.get("learning_state", {})).get("evaluation_records", []))
	if learning_records.is_empty():
		failures.append("Phase 7 canonical manifestation attribution should still learn from a canonically identified manifested experiment")
	elif str(Dictionary(learning_records[0]).get("experiment_id", "")).strip_edges() != "exp_stewardship_campaign":
		failures.append("Phase 7 should prefer canonical manifested_experiment_ids over surface-label collisions")
	var invalid_run_record := _phase7_run_record(838384)
	var invalid_summary: Dictionary = Dictionary(invalid_run_record.get("expedition_constitution_summary", {})).duplicate(true)
	invalid_summary["live_experiment_ids"] = ["exp_missing"]
	invalid_run_record["manifested_experiment_ids"] = ["exp_missing"]
	invalid_run_record["live_experiment_ids"] = ["exp_missing"]
	invalid_run_record["expedition_constitution_summary"] = invalid_summary
	var invalid_state := DELVEMIND_LEARNING_LOOP_SCRIPT.apply_post_run_learning(base_state, invalid_run_record, RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(invalid_run_record), {})
	if JSON.stringify(Dictionary(invalid_state.get("hypotheses", {}))) != JSON.stringify(Dictionary(base_state.get("hypotheses", {}))):
		failures.append("Phase 7 should reject invalid canonical manifestation ids without mutating hypothesis continuity")
	var invalid_failures := _string_array_for_test(Array(Dictionary(invalid_state.get("learning_state", {})).get("validation_failures", [])))
	if "\n".join(invalid_failures).find("unknown manifested experiment exp_missing") == -1:
		failures.append("Phase 7 should surface invalid canonical manifested experiment ids as validation failures")

func _test_phase7_malformed_persisted_learning_state_cleanup(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var malformed_learning_state := {
		"evaluation_records": [{
			"evaluation_id": "eval_bad",
			"run_seed": 1,
			"hypothesis_id": "hyp_stewardship_campaign",
			"experiment_id": "exp_stewardship_campaign",
			"family_id": "stewardship_campaign",
			"dimensions": {"hypothesis_yield": 4},
			"outcomes": ["not_allowed"],
			"supporting_evidence": [],
			"contradicting_evidence": [],
			"continuity_effects": {
				"confidence_delta": 0,
				"recurrence_delta": 0,
				"state_transition": {"from": "active", "to": ""},
				"persistence_transition": {"from": "active", "to": "recurring"},
				"branch_pressure_family": "",
				"branch_open_ids": ["exp_missing"],
				"synthesis_experiment_id": "",
				"synthesis_source_ids": [],
				"revive_candidate": "",
				"fairness_vetoed": false
			},
			"observation_signature": {"story_tone": "Quiet"},
			"public_trace_lines": [],
			"operator_trace_lines": []
		}],
		"meta_learning": {
			"topology_effectiveness": {},
			"topology_counts": {},
			"horizon_effectiveness": {},
			"horizon_counts": {},
			"medium_effectiveness": {},
			"medium_counts": {},
			"expression_mode_effectiveness": {},
			"expression_mode_counts": {},
			"noise_signatures": [],
			"accepted_evaluation_ids": ["eval_dup", "", "eval_dup"],
			"branch_signal_counts": {"": 1},
			"synthesis_signal_counts": {},
			"revive_signal_counts": {}
		},
		"compiler_guidance": {
			"preferred_topologies": [],
			"suppressed_topologies": [],
			"preferred_horizons": [],
			"suppressed_horizons": [],
			"preferred_media": [],
			"suppressed_media": [],
			"branch_pressure_families": [],
			"synthesis_candidates": [],
			"revive_candidates": [],
			"accepted_evaluation_ids": ["eval_dup", "eval_dup"],
			"evaluation_count": 0,
			"branch_signal_counts": {},
			"synthesis_signal_counts": {},
			"revive_signal_counts": {},
			"bias_basis": {
				"topology_averages": {"linear": "bad"},
				"horizon_averages": {},
				"medium_averages": {},
				"expression_mode_averages": {},
				"noise_signatures": []
			},
			"public_lines": [],
			"operator_lines": []
		},
		"public_lines": ["Shared line"],
		"operator_lines": ["Shared line"]
	}
	var malformed_failures := "; ".join(DELVEMIND_LEARNING_LOOP_SCRIPT.validate_learning_state(
		malformed_learning_state,
		Dictionary(base_state.get("hypotheses", {})),
		Dictionary(base_state.get("experiments", {}))
	))
	for required_snippet in [
		"accepted_evaluation_ids",
		"evaluation outcome not_allowed is not allowed",
		"state_transition must include non-empty from/to",
		"branch_open_id exp_missing is missing",
		"bias_basis topology_averages linear must remain numeric",
		"compiler_guidance references unknown evaluation_id eval_dup",
		"evaluation_count must match canonical evaluation_records",
		"public_lines must remain distinct from operator_lines"
	]:
		if malformed_failures.find(required_snippet) == -1:
			failures.append("Phase 7 malformed-state validation should surface %s" % required_snippet)

func _test_phase7_branch_synthesis_persistence_honesty(failures: Array[String]) -> void:
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var hypotheses := Dictionary(base_state.get("hypotheses", {}))
	var experiments := Dictionary(base_state.get("experiments", {}))
	var record := DELVEMIND_LEARNING_LOOP_SCRIPT._normalize_evaluation_record({
		"run_seed": 848484,
		"hypothesis_id": "hyp_stewardship_campaign",
		"experiment_id": "exp_stewardship_campaign",
		"family_id": "stewardship_campaign",
		"dimensions": {
			"hypothesis_yield": 4,
			"cultural_richness": 3,
			"ontological_productivity": 4,
			"narrative_resonance": 3,
			"fairness_stability": 4,
			"readability": 3,
			"replay_distinctiveness": 3,
			"long_horizon_branch_value": 4
		},
		"outcomes": ["strengthen_hypothesis", "split_hypothesis", "synthesize_broader_theory", "move_to_recurring"],
		"supporting_evidence": ["seed_848484", "yield_confirmed"],
		"contradicting_evidence": [],
		"continuity_effects": {
			"confidence_delta": 1,
			"recurrence_delta": 1,
			"state_transition": {"from": "active", "to": "recurring"},
			"persistence_transition": {"from": "active", "to": "recurring"},
			"branch_pressure_family": "stewardship_campaign",
			"branch_open_ids": ["exp_fracture_echo"],
			"synthesis_experiment_id": "exp_stewardship_campaign",
			"synthesis_source_ids": ["exp_custody_foundation"],
			"revive_candidate": "",
			"fairness_vetoed": false
		},
		"observation_signature": {
			"story_tone": "Charged",
			"artifact_result": "authentic",
			"local_role": "Archivist",
			"build_identity": "Rescue build",
			"topology_type": "branching",
			"time_horizon": "short_cycle",
			"cultural_medium": "public_shorthand",
			"expression_mode": "mirror_mode",
			"retellability_score": 4,
			"legend_density_score": 3,
			"revisit_score": 3,
			"interrupted": false
		},
		"public_trace_lines": ["Stewardship keeps splitting into readable public arguments."],
		"operator_trace_lines": ["exp_stewardship_campaign branch/synthesis test"]
	})
	var record_failures := DELVEMIND_LEARNING_LOOP_SCRIPT.validate_evaluation_record(record, hypotheses, experiments)
	if not record_failures.is_empty():
		failures.append("Phase 7 branch/synthesis persistence test record should validate cleanly: %s" % "; ".join(record_failures))
		return
	var updated_hypothesis := DELVEMIND_LEARNING_LOOP_SCRIPT._apply_hypothesis_update(
		Dictionary(hypotheses.get("hyp_stewardship_campaign", {})).duplicate(true),
		record
	)
	if not _string_array_for_test(Array(updated_hypothesis.get("open_branches", []))).has("exp_fracture_echo"):
		failures.append("Phase 7 should persist branch_open_ids into hypothesis continuity instead of leaving them as hollow cues")
	var meta_learning := DELVEMIND_LEARNING_LOOP_SCRIPT._apply_meta_learning(
		Dictionary(DELVEMIND_LEARNING_LOOP_SCRIPT.default_learning_state().get("meta_learning", {})).duplicate(true),
		record
	)
	var guidance := DELVEMIND_LEARNING_LOOP_SCRIPT._derive_compiler_guidance(meta_learning, [record], experiments)
	if not _string_array_for_test(Array(guidance.get("branch_pressure_families", []))).has("stewardship_campaign"):
		failures.append("Phase 7 branch signals should produce count-backed branch_pressure_families guidance")
	if not _string_array_for_test(Array(guidance.get("synthesis_candidates", []))).has("exp_stewardship_campaign"):
		failures.append("Phase 7 synthesis signals should produce count-backed synthesis_candidates guidance")
	if int(Dictionary(guidance.get("branch_signal_counts", {})).get("stewardship_campaign", 0)) != 1:
		failures.append("Phase 7 branch guidance should expose explicit branch_signal_counts")
	if int(Dictionary(guidance.get("synthesis_signal_counts", {})).get("exp_stewardship_campaign", 0)) != 1:
		failures.append("Phase 7 synthesis guidance should expose explicit synthesis_signal_counts")

func _test_phase7_summary_only_constitution_normalization_stays_light(failures: Array[String]) -> void:
	var normalized := EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.normalize({
		"seed": 919191,
		"room_count": 10,
		"control_surfaces": {
			"ecology": {
				"inhabitant_pressure": 2,
				"stalking_bias": 1,
				"anomaly_contamination": 1
			}
		},
		"constitution_summary": {},
		"public_summary": {},
		"generation_surface": {},
		"generation_contract": {}
	})
	var experimental_state: Dictionary = Dictionary(normalized.get("experimental_ontology_state", {}))
	if not Array(experimental_state.get("validation_failures", [])).is_empty():
		failures.append("Phase 7 summary-only constitution normalization should not force full experiment compile validation failures into runtime compatibility paths")
	if not _string_array_for_test(Array(Dictionary(normalized.get("constitution_summary", {})).get("live_experiment_ids", []))).is_empty():
		failures.append("Phase 7 summary-only constitution normalization should keep live_experiment_ids empty when no compiled experiment state is present")
	if not _string_array_for_test(Array(Dictionary(normalized.get("public_summary", {})).get("experiment_surface_lines", []))).is_empty():
		failures.append("Phase 7 summary-only constitution normalization should not invent public experiment texture for empty experiment state")

func _test_phase8_quiet_play_diagnostics_and_safety(failures: Array[String]) -> void:
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(_phase8_run_record(818181))
	if _string_array_for_test(Array(diagnostics.get("quiet_play_signals", []))).is_empty():
		failures.append("Phase 8 diagnostics should surface quiet_play_signals for low-communication burden runs")
	if str(diagnostics.get("meaningful_non_action", "")).strip_edges().is_empty():
		failures.append("Phase 8 diagnostics should surface meaningful_non_action for non-performative restraint runs")
	var social_safety_flags := _string_array_for_test(Array(diagnostics.get("social_safety_flags", [])))
	for required_flag in ["quiet_play_viable", "non_performative_viable", "no_public_shaming", "all_ages_readable"]:
		if not social_safety_flags.has(required_flag):
			failures.append("Phase 8 diagnostics should expose social safety flag %s" % required_flag)
	var reputation_band := str(diagnostics.get("reputation_band", "")).strip_edges()
	if reputation_band.is_empty():
		failures.append("Phase 8 diagnostics should surface a reputation_band")
	var institutional_pressure_surface: Dictionary = Dictionary(diagnostics.get("institutional_pressure_surface", {}))
	if _string_array_for_test(Array(institutional_pressure_surface.get("claim_lines", []))).is_empty():
		failures.append("Phase 8 diagnostics should preserve institutional claim lines")
	if _string_array_for_test(Array(institutional_pressure_surface.get("interpretation_lines", []))).is_empty():
		failures.append("Phase 8 diagnostics should preserve institutional interpretation lines")
	if int(diagnostics.get("continuity_burden_score", 0)) <= 0:
		failures.append("Phase 8 diagnostics should raise continuity_burden_score when aftermath and burden remain active")

func _test_phase8_scale_budget_and_stewardship_audit_projection(failures: Array[String]) -> void:
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 6,
		"event_id": 21,
		"event_type": "run_started",
		"room_slot": 0,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	event_log.add_event({
		"tick": 11,
		"event_id": 24,
		"event_type": "artifact_picked",
		"room_slot": 3,
		"actor_peer_id": 2,
		"visibility": "public",
		"meta": {"artifact_id": 1}
	})
	var constitution_summary := {
		"constitution_id": "phase8_scale_budget",
		"activation_epoch": "fully_active",
		"activation_active_channels": ["constitution", "archive", "world_memory"],
		"activation_dormant_channels": ["safe_mode"],
		"safe_mode_active": false,
		"safe_mode_lines": [],
		"explanation_packet_lines": ["Keep the burden public without widening the shell."],
		"review_surface_lines": ["promotion review kept 1 admissible carrier ready"],
		"signal_budget_lines": ["summary budget stays compact"],
		"active_regime_ids": ["market_recovery_weave"],
		"lifecycle_state_ids": ["lifecycle_market_recovery_weave"]
	}
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.normalize({
		"activation_state": {
			"epoch": "fully_active",
			"active_channels": ["constitution", "archive", "world_memory"],
			"dormant_channels": ["safe_mode"],
			"safe_mode_active": false,
			"quarantine_ids": ["theory_echo_lure"]
		},
		"safe_mode_state": {"enabled": false, "summary_lines": []},
		"fairness_trigger_records": [{
			"report_id": "fairness_phase8",
			"status": "warning",
			"summary_lines": ["fairness review remains active"]
		}],
		"dignity_trigger_records": [{
			"report_id": "dignity_phase8",
			"status": "warning",
			"summary_lines": ["dignity review remains active"]
		}],
		"quarantine_registry": [{
			"entry_id": "theory_echo_lure",
			"status": "quarantined",
			"summary_lines": ["echo lure stays quarantined"]
		}]
	})
	var action_snapshot := GOVERNANCE_SERVICE_SCRIPT.build_forensic_action_snapshot(governance_state)
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var bundle := controller.build_forensic_bundle_for_test(
		838383,
		"phase8_scale_budget_hash",
		constitution_summary,
		event_log,
		[],
		"forensic_replay",
		{
			"governance_action_snapshot": action_snapshot,
			"experiment_outcomes": {"manifested_experiment_ids": ["exp_stewardship_campaign"]}
		},
		governance_state
	)
	var bundle_extensions: Dictionary = Dictionary(bundle.get("bundle_extensions", {}))
	var stewardship_review: Dictionary = Dictionary(bundle_extensions.get("phase8_stewardship_review", {}))
	if stewardship_review.is_empty():
		failures.append("Phase 8 scale stewardship should add a compact operator-only stewardship review extension")
	if bundle.has("stewardship_review"):
		failures.append("Phase 8 scale stewardship should keep stewardship review out of the top-level forensic bundle")
	if _string_array_for_test(Array(stewardship_review.get("checked_lens_tags", []))).is_empty():
		failures.append("Phase 8 scale stewardship should record checked lens tags inside the extension")
	if _string_array_for_test(Array(stewardship_review.get("summary_lines", []))).size() > 2:
		failures.append("Phase 8 scale stewardship should keep stewardship summary lines capped at two")
	if _string_array_for_test(Array(stewardship_review.get("warning_tags", []))).size() > 4:
		failures.append("Phase 8 scale stewardship should keep warning tags tightly bounded")
	var continuity_review := Dictionary(WORLD_MEMORY_SERVICE_SCRIPT.build_continuity_review(WORLD_MEMORY_SERVICE_SCRIPT.default_state()))
	if str(continuity_review.get("summary_line", "")).strip_edges().is_empty():
		failures.append("Phase 8 scale stewardship should preserve a compact continuity review summary for downstream readers")
	controller.free()
	event_log.free()

func _test_phase8_legacy_reentry_continuity_surfaces(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, _phase8_run_record(828282), catalog)
	var updated_profile: Dictionary = Dictionary(result.get("profile", {}))
	var legacy_tracks := _dict_array_for_test(updated_profile.get("legacy_tracks", []))
	if legacy_tracks.is_empty():
		failures.append("Phase 8 continuity should persist legacy_tracks on the existing profile owner")
	var reentry_hooks := _dict_array_for_test(updated_profile.get("reentry_hooks", []))
	if reentry_hooks.is_empty():
		failures.append("Phase 8 continuity should persist reentry_hooks on the existing profile owner")
	var last_run: Dictionary = Dictionary(updated_profile.get("last_run", {}))
	if str(last_run.get("legacy_track_id", "")).strip_edges().is_empty():
		failures.append("Phase 8 last_run continuity should expose the canonical legacy_track_id")
	var last_reentry_hook: Dictionary = Dictionary(last_run.get("reentry_hook", {}))
	if str(last_reentry_hook.get("prompt_line", "")).strip_edges().is_empty():
		failures.append("Phase 8 last_run continuity should expose the canonical reentry_hook prompt")

	var home_lines := PROFILE_SERVICE_SCRIPT.build_home_overview_lines(updated_profile, {"connected": true}, catalog)
	var found_home_legacy := false
	var found_home_reentry := false
	for line_variant in home_lines:
		var line := str(line_variant)
		if line.begins_with("Legacy: "):
			found_home_legacy = true
		elif line.begins_with("Reentry: "):
			found_home_reentry = true
	if not found_home_legacy:
		failures.append("Phase 8 home overview should surface the latest legacy track through the existing shell owner")
	if not found_home_reentry:
		failures.append("Phase 8 home overview should surface the latest reentry hook through the existing shell owner")

	var last_run_lines := PROFILE_SERVICE_SCRIPT.build_last_run_diagnostic_lines(updated_profile)
	var found_last_run_quiet_play := false
	var found_last_run_reentry := false
	for line_variant in last_run_lines:
		var line := str(line_variant)
		if line.begins_with("Quiet play: "):
			found_last_run_quiet_play = true
		elif line.begins_with("Reentry: "):
			found_last_run_reentry = true
	if not found_last_run_quiet_play:
		failures.append("Phase 8 last-run diagnostics should surface quiet-play continuity")
	if not found_last_run_reentry:
		failures.append("Phase 8 last-run diagnostics should surface reentry continuity")

	var world_memory := Dictionary(updated_profile.get("world_memory", {}))
	var world_lines := WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory)
	var found_world_legacy := false
	for line_variant in world_lines:
		if str(line_variant).begins_with("Legacy: "):
			found_world_legacy = true
			break
	if not found_world_legacy:
		failures.append("Phase 8 world memory lines should surface legacy memory on the existing continuity owner")

	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(world_memory)
	if _string_array_for_test(Array(civilization_surface.get("institutional_pressure_lines", []))).is_empty():
		failures.append("Phase 8 civilization surfaces should expose institutional pressure lines")
	if _string_array_for_test(Array(civilization_surface.get("quiet_play_lines", []))).is_empty():
		failures.append("Phase 8 civilization surfaces should preserve quiet-play lines")

	var crawl_lines := CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(updated_profile)
	var found_crawl_quiet_play := false
	for line_variant in crawl_lines:
		if str(line_variant).begins_with("Quiet play: "):
			found_crawl_quiet_play = true
			break
	if not found_crawl_quiet_play:
		failures.append("Phase 8 active crawl lines should surface quiet-play carryover")

	var archive_entries := ARCHIVE_SERVICE_SCRIPT.build_dynamic_entries(updated_profile, "archive_cases")
	if archive_entries.is_empty():
		failures.append("Phase 8 continuity should still produce archive case entries on the existing archive owner")
	else:
		var detail := str(Dictionary(archive_entries[0]).get("detail", ""))
		if detail.find("Quiet play: ") == -1 and detail.find("Return pull: ") == -1:
			failures.append("Phase 8 archive case detail should surface quiet-play or return-pull continuity without widening ownership")

func _test_phase9_forensic_bundle_hardening_contract(failures: Array[String]) -> void:
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 4,
		"event_id": 11,
		"event_type": "run_started",
		"room_slot": 0,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	event_log.add_event({
		"tick": 9,
		"event_id": 14,
		"event_type": "artifact_picked",
		"room_slot": 3,
		"actor_peer_id": 2,
		"visibility": "public",
		"meta": {"artifact_id": 1}
	})
	event_log.add_event({
		"tick": 12,
		"event_id": 19,
		"event_type": "notebook_note",
		"room_slot": 3,
		"actor_peer_id": 2,
		"target_peer_id": 2,
		"visibility": "private"
	})
	var constitution_summary := {
		"constitution_id": "phase9_constitution",
		"activation_epoch": "fully_active",
		"activation_active_channels": ["constitution", "archive", "world_memory"],
		"activation_dormant_channels": ["safe_mode"],
		"safe_mode_active": false,
		"safe_mode_lines": [],
		"explanation_packet_lines": ["Carry the answer through the stabilized return."],
		"review_surface_lines": ["Phase 9 forensic hardening is active."],
		"active_regime_ids": ["market_recovery_weave"],
		"lifecycle_state_ids": ["lifecycle_market_recovery_weave"],
		"encounter_manifest_ids": ["encounter_threshold_hold"],
		"apex_manifest_ids": ["apex_threshold_trial"]
	}
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.normalize({
		"activation_state": {
			"epoch": "fully_active",
			"active_channels": ["constitution", "archive", "world_memory"],
			"dormant_channels": ["safe_mode"],
			"safe_mode_active": false,
			"quarantine_ids": ["pathology_echo_lure"]
		},
		"safe_mode_state": {"enabled": false, "summary_lines": []},
		"quarantine_registry": [{
			"entry_id": "pathology_echo_lure",
			"status": "quarantined",
			"summary_lines": ["echo lure remains quarantined from promotion"]
		}],
		"fairness_trigger_records": [{
			"report_id": "fairness_phase9",
			"status": "warning",
			"summary_lines": ["fairness review remains open"]
		}],
		"dignity_trigger_records": [{
			"report_id": "dignity_phase9",
			"status": "warning",
			"summary_lines": ["dignity review remains open"]
		}],
		"rollback_registry": [{
			"report_id": "rollback_phase9",
			"status": "cooling",
			"summary_lines": ["rollback review captured the current doctrine surface"]
		}],
		"dominance_strain_reports": [{
			"report_id": "dominance_phase9",
			"status": "warning",
			"summary_lines": ["one strategy family is pulling too much weight"]
		}],
		"meta_collapse_reports": [{
			"report_id": "collapse_phase9",
			"status": "warning",
			"summary_lines": ["meta collapse risk is rising"]
		}]
	})
	var action_snapshot := GOVERNANCE_SERVICE_SCRIPT.build_forensic_action_snapshot(governance_state)
	var explanation_packet := GOVERNANCE_SERVICE_SCRIPT.build_explanation_packet(
		{
			"artifact_type": "expedition_constitution",
			"constitution_hash": "phase9_constitution_hash"
		},
		Array(constitution_summary.get("explanation_packet_lines", [])),
		Array(constitution_summary.get("review_surface_lines", [])),
		["movement", "burden", "extraction", "return"]
	)
	var hook_set := GOVERNANCE_SERVICE_SCRIPT.build_governance_hook_set(governance_state, constitution_summary, explanation_packet)
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var replay_identity := controller._build_replay_identity(919191, "phase9_constitution_hash", "", event_log)
	var telemetry := controller._build_telemetry_summary(
		[{"type": "artifact_picked"}],
		[{"type": "notebook_note"}],
		explanation_packet,
		hook_set,
		replay_identity,
		"forensic_replay",
		[],
		{},
		{},
		[],
		{},
		[],
		{"aftermath_id": "local_phase9"},
		[{
			"schema_name": "WorldAftermathRef",
			"schema_version": 1,
			"aftermath_id": "world_phase9",
			"source_id": "apex_threshold_trial",
			"source_kind": "apex",
			"apex_id": "apex_threshold_trial",
			"local_aftermath_id": "local_phase9",
			"continuity_seed_tags": ["threshold_residue"],
			"return_pressure_tags": ["route_pressure"],
			"route_state_hint": "rerouted",
			"successor_hint_ids": ["threshold_trial_apex"]
		}],
		{
			"active_regime_ids": ["market_recovery_weave"],
			"active_lifecycle_state_ids": ["lifecycle_market_recovery_weave"],
			"encounter_manifest": {"encounter_ids": ["encounter_threshold_hold"]},
			"apex_manifest": {"apex_ids": ["apex_threshold_trial"]},
			"governance_action_snapshot": action_snapshot,
			"experiment_outcomes": {"manifested_experiment_ids": ["exp_stewardship_campaign"]}
		}
	)
	if _string_array_for_test(Array(telemetry.get("active_regime_ids", []))).is_empty():
		failures.append("Phase 9 telemetry should expose active_regime_ids")
	if _string_array_for_test(Array(telemetry.get("active_lifecycle_state_ids", []))).is_empty():
		failures.append("Phase 9 telemetry should expose active_lifecycle_state_ids")
	if _string_array_for_test(Array(telemetry.get("encounter_manifest_ids", []))).is_empty():
		failures.append("Phase 9 telemetry should expose encounter_manifest_ids")
	if _string_array_for_test(Array(telemetry.get("apex_manifest_ids", []))).is_empty():
		failures.append("Phase 9 telemetry should expose apex_manifest_ids")
	if JSON.stringify(telemetry).find("\"phenomenon_manifest\"") != -1:
		failures.append("Phase 9 telemetry should keep phenomenon_manifest out of the telemetry surface")
	if str(Dictionary(telemetry.get("rollback_action", {})).get("report_id", "")).strip_edges().is_empty():
		failures.append("Phase 9 telemetry should expose rollback_action when governance review is active")
	if str(Dictionary(telemetry.get("quarantine_action", {})).get("report_id", "")).strip_edges().is_empty():
		failures.append("Phase 9 telemetry should expose quarantine_action when quarantine state is active")
	var bundle := controller.build_forensic_bundle_for_test(
		919191,
		"phase9_constitution_hash",
		constitution_summary,
		event_log,
		[],
		"forensic_replay",
		{
			"active_regime_ids": ["market_recovery_weave"],
			"active_lifecycle_state_ids": ["lifecycle_market_recovery_weave"],
			"encounter_manifest": {"encounter_ids": ["encounter_threshold_hold"]},
			"apex_manifest": {"apex_ids": ["apex_threshold_trial"]},
			"local_aftermath": {"aftermath_id": "local_phase9"},
			"world_aftermath_refs": [{
				"schema_name": "WorldAftermathRef",
				"schema_version": 1,
				"aftermath_id": "world_phase9",
				"source_id": "apex_threshold_trial",
				"source_kind": "apex",
				"apex_id": "apex_threshold_trial",
				"local_aftermath_id": "local_phase9",
				"continuity_seed_tags": ["threshold_residue"],
				"return_pressure_tags": ["route_pressure"],
				"route_state_hint": "rerouted",
				"successor_hint_ids": ["threshold_trial_apex"]
			}],
			"governance_action_snapshot": action_snapshot,
			"experiment_outcomes": {"manifested_experiment_ids": ["exp_stewardship_campaign"]}
		},
		governance_state
	)
	for key in [
		"active_regime_ids",
		"active_lifecycle_state_ids",
		"equipped_modulation_loadout",
		"encounter_manifest",
		"apex_manifest",
		"local_aftermath",
		"world_aftermath_refs",
		"explanation_packet_outputs",
		"fairness_triggers",
		"dignity_triggers",
		"dominant_strategy_strain",
		"experiment_outcomes",
		"rollback_action",
		"quarantine_action"
	]:
		if not bundle.has(key):
			failures.append("Phase 9 forensic bundles should expose %s" % key)
	if _string_array_for_test(Array(Dictionary(bundle.get("explanation_packet_outputs", {})).get("summary_lines", []))).is_empty():
		failures.append("Phase 9 forensic bundles should preserve explanation packet outputs")
	if _string_array_for_test(Array(bundle.get("fairness_triggers", []))).is_empty():
		failures.append("Phase 9 forensic bundles should surface fairness trigger ids")
	if str(Dictionary(bundle.get("rollback_action", {})).get("report_id", "")).strip_edges().is_empty():
		failures.append("Phase 9 forensic bundles should surface rollback_action")
	var phase8_extension: Dictionary = Dictionary(Dictionary(bundle.get("bundle_extensions", {})).get("phase8_stewardship_review", {}))
	var phenomenon_extension: Dictionary = Dictionary(Dictionary(bundle.get("bundle_extensions", {})).get("phenomenon_manifest", {}))
	if phase8_extension.is_empty():
		failures.append("Phase 9 forensic bundles should preserve the compact Phase 8 stewardship review extension")
	for required_key in ["summary_lines", "operator_lines", "public_entries", "operator_entries"]:
		if not phenomenon_extension.has(required_key):
			failures.append("Phase 9 forensic bundles should preserve a stable phenomenon_manifest extension key %s" % required_key)
	if bundle.has("stewardship_review"):
		failures.append("Phase 9 forensic bundles should keep stewardship review out of the top-level bundle surface")
	if bundle.has("phenomenon_manifest"):
		failures.append("Phase 9 forensic bundles should keep phenomenon_manifest out of the top-level bundle surface")
	controller.free()
	event_log.free()

func _test_phase9_forensic_bundle_extension_consistency(failures: Array[String]) -> void:
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 5,
		"event_id": 15,
		"event_type": "constitution_mutation",
		"room_slot": 6,
		"actor_peer_id": 2,
		"visibility": "public",
		"meta": {
			"trigger_type": "species_escalation",
			"public_meta": {"species_id": "predator", "mode": "pack", "room_slot": 6}
		}
	})
	var constitution_summary := {
		"constitution_id": "phase9_consistency_constitution",
		"activation_epoch": "fully_active",
		"activation_active_channels": ["constitution", "archive", "world_memory"],
		"activation_dormant_channels": ["safe_mode"],
		"safe_mode_active": false,
		"safe_mode_lines": [],
		"explanation_packet_lines": ["Forensic copies should stay consistent."],
		"review_surface_lines": ["Duplicated bundle payloads should not drift."],
		"encounter_manifest_ids": ["encounter_threshold_hold"],
		"encounter_intent_ids": ["threshold_hold"],
		"encounter_topology_ids": ["threshold_hold"],
		"apex_manifest_ids": ["apex_threshold_trial"],
		"apex_class_ids": ["threshold_trial_apex"]
	}
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var modulation_loadout := [{
		"equivalence_class_id": "notebook_guidance_focus",
		"selected_cosmetic_id": "theme_amber_fieldnotes",
		"collapsed": false
	}]
	var world_aftermath_refs := [{
		"schema_name": "WorldAftermathRef",
		"schema_version": 1,
		"aftermath_id": "world_phase9_consistency",
		"source_id": "apex_threshold_trial",
		"source_kind": "apex",
		"apex_id": "apex_threshold_trial",
		"local_aftermath_id": "local_phase9_consistency",
		"continuity_seed_tags": ["threshold_residue"],
		"return_pressure_tags": ["route_pressure"],
		"route_state_hint": "rerouted",
		"successor_hint_ids": ["threshold_trial_apex"]
	}]
	var bundle := controller.build_forensic_bundle_for_test(
		92929292,
		"phase9_consistency_hash",
		constitution_summary,
		event_log,
		[],
		"forensic_replay",
		{
			"encounter_manifest": {"encounter_ids": ["encounter_threshold_hold"]},
			"apex_manifest": {"apex_ids": ["apex_threshold_trial"]},
			"local_aftermath": {"aftermath_id": "local_phase9_consistency"},
			"world_aftermath_refs": world_aftermath_refs
		},
		{},
		modulation_loadout
	)
	var phase2_extension: Dictionary = Dictionary(Dictionary(bundle.get("bundle_extensions", {})).get("phase2_cosmetic_modulation", {}))
	var phase4_extension: Dictionary = Dictionary(Dictionary(bundle.get("bundle_extensions", {})).get("phase4_encounter_language", {}))
	var phase5_extension: Dictionary = Dictionary(Dictionary(bundle.get("bundle_extensions", {})).get("phase5_apex_aftermath", {}))
	var phase8_extension: Dictionary = Dictionary(Dictionary(bundle.get("bundle_extensions", {})).get("phase8_stewardship_review", {}))
	var phenomenon_extension: Dictionary = Dictionary(Dictionary(bundle.get("bundle_extensions", {})).get("phenomenon_manifest", {}))
	if JSON.stringify(Array(bundle.get("equipped_modulation_loadout", []))) != JSON.stringify(Array(phase2_extension.get("equipped_modulation_loadout", []))):
		failures.append("Phase 9 forensic bundles should keep top-level equipped_modulation_loadout consistent with the Phase 2 extension copy")
	if JSON.stringify(Dictionary(bundle.get("encounter_manifest", {}))) != JSON.stringify(Dictionary(phase4_extension.get("encounter_manifest", {}))):
		failures.append("Phase 9 forensic bundles should keep top-level encounter_manifest consistent with the Phase 4 extension copy")
	if JSON.stringify(Dictionary(bundle.get("apex_manifest", {}))) != JSON.stringify(Dictionary(phase5_extension.get("apex_manifest", {}))):
		failures.append("Phase 9 forensic bundles should keep top-level apex_manifest consistent with the Phase 5 extension copy")
	if JSON.stringify(Dictionary(bundle.get("local_aftermath", {}))) != JSON.stringify(Dictionary(phase5_extension.get("local_aftermath", {}))):
		failures.append("Phase 9 forensic bundles should keep top-level local_aftermath consistent with the Phase 5 extension copy")
	if JSON.stringify(Array(bundle.get("world_aftermath_refs", []))) != JSON.stringify(Array(phase5_extension.get("world_aftermath_refs", []))):
		failures.append("Phase 9 forensic bundles should keep top-level world_aftermath_refs consistent with the Phase 5 extension copy")
	if phase8_extension.is_empty():
		failures.append("Phase 9 forensic bundle extensions should keep the operator-only stewardship review available")
	for required_key in ["summary_lines", "operator_lines", "public_entries", "operator_entries"]:
		if not phenomenon_extension.has(required_key):
			failures.append("Phase 9 forensic bundle extensions should keep stable phenomenon_manifest key %s available" % required_key)
	if bundle.has("stewardship_review"):
		failures.append("Phase 9 forensic bundle extensions should not mirror stewardship review onto a new top-level field")
	if bundle.has("phenomenon_manifest"):
		failures.append("Phase 9 forensic bundle extensions should not mirror phenomenon_manifest onto a new top-level field")
	controller.free()
	event_log.free()

func _test_phase9_curated_phenomenon_manifest_builder_contract(failures: Array[String]) -> void:
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var experiments: Dictionary = Dictionary(base_state.get("experiments", {})).duplicate(true)
	var experimental_ontology_state := {
		"live_experiments": [
			Dictionary(experiments.get("exp_palimpsest", {})).duplicate(true),
			Dictionary(experiments.get("exp_negative_space", {})).duplicate(true),
			Dictionary(experiments.get("exp_stewardship_campaign", {})).duplicate(true)
		],
		"experiment_registry": Array(experiments.values()).duplicate(true)
	}
	var manifest := controller._build_phenomenon_manifest(
		experimental_ontology_state,
		_curated_phenomenon_governance_state(),
		["exp_palimpsest", "exp_negative_space", "exp_stewardship_campaign"]
	)
	var manifest_keys := _string_array_for_test(Array(manifest.keys()))
	manifest_keys.sort()
	if JSON.stringify(manifest_keys) != JSON.stringify(["operator_entries", "operator_lines", "public_entries", "summary_lines"]):
		failures.append("Curated phenomenon manifest builder should expose only summary_lines, operator_lines, public_entries, and operator_entries")
	var public_entries := _dict_array_for_test(manifest.get("public_entries", []))
	var operator_entries := _dict_array_for_test(manifest.get("operator_entries", []))
	if public_entries.size() != 2 or operator_entries.size() != 2:
		failures.append("Curated phenomenon manifest builder should filter to live curated families only")
	for public_entry in public_entries:
		var public_keys := _string_array_for_test(Array(public_entry.keys()))
		public_keys.sort()
		if JSON.stringify(public_keys) != JSON.stringify(["family_id", "family_label", "surface_lines"]):
			failures.append("Curated phenomenon manifest public entries should stay inside the public-safe field set")
		var family_id := str(public_entry.get("family_id", "")).strip_edges()
		if family_id not in ["palimpsest", "negative_space"]:
			failures.append("Curated phenomenon manifest public entries should not include non-curated live families")
	var expected_operator_keys := [
		"anti_bottleneck_status",
		"axis",
		"bottleneck_flags",
		"compile_targets",
		"cultural_medium",
		"experiment_id",
		"expression_mode",
		"family_id",
		"family_label",
		"missing_routes",
		"observation_contract",
		"ontology_condition",
		"play_routing_status",
		"stressor",
		"target",
		"time_horizon",
		"topology_type"
	]
	expected_operator_keys.sort()
	for operator_entry in operator_entries:
		var operator_keys := _string_array_for_test(Array(operator_entry.keys()))
		operator_keys.sort()
		if JSON.stringify(operator_keys) != JSON.stringify(expected_operator_keys):
			failures.append("Curated phenomenon manifest operator entries should stay inside the bounded operator field set")
	var public_json := JSON.stringify(public_entries)
	for banned_fragment in ["compile_targets", "bottleneck_flags", "missing_routes", "anti_bottleneck_status", "play_routing_status"]:
		if public_json.find("\"%s\"" % banned_fragment) != -1:
			failures.append("Curated phenomenon manifest public entries should not leak %s" % banned_fragment)
	var empty_manifest := controller._build_phenomenon_manifest({}, _curated_phenomenon_governance_state(), [])
	var empty_keys := _string_array_for_test(Array(empty_manifest.keys()))
	empty_keys.sort()
	if JSON.stringify(empty_keys) != JSON.stringify(["operator_entries", "operator_lines", "public_entries", "summary_lines"]):
		failures.append("Curated phenomenon manifest builder should keep the manifest key contract stable even when no curated families are live")
	if not _string_array_for_test(Array(Dictionary(empty_manifest).get("summary_lines", []))).is_empty():
		failures.append("Curated phenomenon manifest builder should keep empty summary_lines when no curated families are live")
	if not _dict_array_for_test(Dictionary(empty_manifest).get("public_entries", [])).is_empty():
		failures.append("Curated phenomenon manifest builder should keep empty public_entries when no curated families are live")
	controller.free()

func _test_phase9_curated_phenomenon_manifest_bundle_only(failures: Array[String]) -> void:
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 1,
		"event_id": 1,
		"event_type": "run_started",
		"room_slot": 0,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	var constitution_summary := {
		"constitution_id": "phase9_curated_manifest",
		"activation_epoch": "fully_active",
		"activation_active_channels": ["constitution", "archive", "world_memory"],
		"activation_dormant_channels": ["safe_mode"],
		"safe_mode_active": false,
		"safe_mode_lines": [],
		"explanation_packet_lines": ["Curated phenomenon manifest should stay bundle-only."],
		"review_surface_lines": ["Manifest placement remains bounded."]
	}
	var governance_state := _curated_phenomenon_governance_state()
	var action_snapshot := GOVERNANCE_SERVICE_SCRIPT.build_forensic_action_snapshot(governance_state)
	var explanation_packet := GOVERNANCE_SERVICE_SCRIPT.build_explanation_packet(
		{
			"artifact_type": "expedition_constitution",
			"constitution_hash": "phase9_curated_manifest_hash"
		},
		Array(constitution_summary.get("explanation_packet_lines", [])),
		Array(constitution_summary.get("review_surface_lines", [])),
		["movement", "burden", "return"]
	)
	var hook_set := GOVERNANCE_SERVICE_SCRIPT.build_governance_hook_set(governance_state, constitution_summary, explanation_packet)
	var replay_identity := controller._build_replay_identity(939393, "phase9_curated_manifest_hash", "", event_log)
	var telemetry := controller._build_telemetry_summary(
		[{"type": "run_started"}],
		[],
		explanation_packet,
		hook_set,
		replay_identity,
		"forensic_replay",
		[],
		{},
		{},
		[],
		{},
		[],
		{},
		[],
		{
			"governance_action_snapshot": action_snapshot,
			"experiment_outcomes": {"manifested_experiment_ids": ["exp_palimpsest", "exp_negative_space"]}
		}
	)
	var base_state := DELVEMIND_EXPERIMENT_ENGINE_SCRIPT.normalize({})
	var experiments: Dictionary = Dictionary(base_state.get("experiments", {})).duplicate(true)
	var phenomenon_manifest := controller._build_phenomenon_manifest(
		{
			"live_experiments": [
				Dictionary(experiments.get("exp_palimpsest", {})).duplicate(true),
				Dictionary(experiments.get("exp_negative_space", {})).duplicate(true)
			],
			"experiment_registry": Array(experiments.values()).duplicate(true)
		},
		governance_state,
		["exp_palimpsest", "exp_negative_space"]
	)
	var bundle := controller.build_forensic_bundle_for_test(
		939393,
		"phase9_curated_manifest_hash",
		constitution_summary,
		event_log,
		[],
		"forensic_replay",
		{
			"governance_action_snapshot": action_snapshot,
			"experiment_outcomes": {"manifested_experiment_ids": ["exp_palimpsest", "exp_negative_space"]},
			"phenomenon_manifest": phenomenon_manifest.duplicate(true)
		},
		governance_state
	)
	var bundle_extensions: Dictionary = Dictionary(bundle.get("bundle_extensions", {}))
	var bundle_manifest: Dictionary = Dictionary(bundle_extensions.get("phenomenon_manifest", {})).duplicate(true)
	if bundle_manifest.is_empty():
		failures.append("Curated phenomenon bundle placement should attach phenomenon_manifest under bundle_extensions")
	if bundle.has("phenomenon_manifest"):
		failures.append("Curated phenomenon bundle placement should not mirror phenomenon_manifest onto the top-level forensic bundle")
	if JSON.stringify(telemetry).find("\"phenomenon_manifest\"") != -1:
		failures.append("Curated phenomenon bundle placement should keep telemetry free of phenomenon_manifest")
	if JSON.stringify(Dictionary(bundle.get("explanation_packet_outputs", {}))).find("\"phenomenon_manifest\"") != -1:
		failures.append("Curated phenomenon bundle placement should not mirror phenomenon_manifest into explanation_packet_outputs")
	var synthetic_header := {
		"bundle_id": str(bundle.get("bundle_id", "")),
		"bundle_digest": str(bundle.get("bundle_digest", "")),
		"bundle_schema_version": int(bundle.get("bundle_schema_version", 0)),
		"replay_id": str(bundle.get("replay_id", ""))
	}
	if JSON.stringify(synthetic_header).find("\"phenomenon_manifest\"") != -1:
		failures.append("Curated phenomenon bundle placement should keep forensic bundle headers free of phenomenon_manifest")
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(_phase7_run_record(939393, {
		"telemetry_summary": telemetry.duplicate(true),
		"forensic_bundle": bundle.duplicate(true)
	}))
	if JSON.stringify(diagnostics).find("\"phenomenon_manifest\"") != -1:
		failures.append("Curated phenomenon bundle placement should not mirror phenomenon_manifest into run diagnostics")
	controller.free()
	event_log.free()

func _test_phase9_profile_forensic_persistence_and_world_memory_hash(failures: Array[String]) -> void:
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 4,
		"event_id": 11,
		"event_type": "run_started",
		"room_slot": 0,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	event_log.add_event({
		"tick": 9,
		"event_id": 14,
		"event_type": "artifact_picked",
		"room_slot": 3,
		"actor_peer_id": 2,
		"visibility": "public",
		"meta": {"artifact_id": 1}
	})
	var constitution_summary := {
		"constitution_id": "phase9_profile_constitution",
		"activation_epoch": "fully_active",
		"activation_active_channels": ["constitution", "archive", "world_memory"],
		"activation_dormant_channels": ["safe_mode"],
		"safe_mode_active": false,
		"safe_mode_lines": [],
		"explanation_packet_lines": ["Carry the answer through the stabilized return."],
		"review_surface_lines": ["Phase 9 persistence review is active."],
		"active_regime_ids": ["market_recovery_weave"],
		"lifecycle_state_ids": ["lifecycle_market_recovery_weave"]
	}
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.normalize({
		"rollback_registry": [{
			"report_id": "rollback_profile_phase9",
			"status": "cooling",
			"summary_lines": ["rollback review captured the current doctrine surface"]
		}],
		"quarantine_registry": [{
			"entry_id": "encounter_threshold_hold",
			"status": "quarantined",
			"summary_lines": ["threshold-hold remains quarantined from promotion"]
		}]
	})
	var action_snapshot := GOVERNANCE_SERVICE_SCRIPT.build_forensic_action_snapshot(governance_state)
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var bundle := controller.build_forensic_bundle_for_test(
		929292,
		"phase9_profile_constitution_hash",
		constitution_summary,
		event_log,
		[],
		"forensic_replay",
		{
			"active_regime_ids": ["market_recovery_weave"],
			"active_lifecycle_state_ids": ["lifecycle_market_recovery_weave"],
			"encounter_manifest": {"encounter_ids": ["encounter_threshold_hold"]},
			"apex_manifest": {"apex_ids": ["apex_threshold_trial"]},
			"local_aftermath": {"aftermath_id": "local_profile_phase9"},
			"world_aftermath_refs": [{
				"schema_name": "WorldAftermathRef",
				"schema_version": 1,
				"aftermath_id": "world_profile_phase9",
				"source_id": "apex_threshold_trial",
				"source_kind": "apex",
				"apex_id": "apex_threshold_trial",
				"local_aftermath_id": "local_profile_phase9",
				"continuity_seed_tags": ["threshold_residue"],
				"return_pressure_tags": ["route_pressure"],
				"route_state_hint": "rerouted",
				"successor_hint_ids": ["threshold_trial_apex"]
			}],
			"governance_action_snapshot": action_snapshot,
			"experiment_outcomes": {"manifested_experiment_ids": ["exp_stewardship_campaign"]}
		},
		governance_state
	)
	var replay_identity := controller._build_replay_identity(929292, "phase9_profile_constitution_hash", "", event_log)
	var explanation_packet := GOVERNANCE_SERVICE_SCRIPT.build_explanation_packet(
		{
			"artifact_type": "expedition_constitution",
			"constitution_hash": "phase9_profile_constitution_hash"
		},
		Array(constitution_summary.get("explanation_packet_lines", [])),
		Array(constitution_summary.get("review_surface_lines", [])),
		["movement", "burden", "extraction", "return"]
	)
	var hook_set := GOVERNANCE_SERVICE_SCRIPT.build_governance_hook_set(governance_state, constitution_summary, explanation_packet)
	var telemetry := controller._build_telemetry_summary(
		[{"type": "artifact_picked"}],
		[],
		explanation_packet,
		hook_set,
		replay_identity,
		"forensic_replay",
		[],
		{},
		{},
		[],
		{},
		[],
		{"aftermath_id": "local_profile_phase9"},
		[{
			"schema_name": "WorldAftermathRef",
			"schema_version": 1,
			"aftermath_id": "world_profile_phase9",
			"source_id": "apex_threshold_trial",
			"source_kind": "apex",
			"apex_id": "apex_threshold_trial",
			"local_aftermath_id": "local_profile_phase9",
			"continuity_seed_tags": ["threshold_residue"],
			"return_pressure_tags": ["route_pressure"],
			"route_state_hint": "rerouted",
			"successor_hint_ids": ["threshold_trial_apex"]
		}],
		{
			"active_regime_ids": ["market_recovery_weave"],
			"active_lifecycle_state_ids": ["lifecycle_market_recovery_weave"],
			"encounter_manifest": {"encounter_ids": ["encounter_threshold_hold"]},
			"apex_manifest": {"apex_ids": ["apex_threshold_trial"]},
			"governance_action_snapshot": action_snapshot,
			"experiment_outcomes": {"manifested_experiment_ids": ["exp_stewardship_campaign"]}
		}
	)
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := {
		"lifecycle_registry": {
			"families": [{
				"family_id": "market_recovery_weave",
				"family_kind": "market",
				"state": "active",
				"heat": 3,
				"saturation": 2,
				"strain": 2
			}]
		}
	}
	var run_record := _phase8_run_record(929292, {
		"forensic_bundle": bundle,
		"replay_identity": replay_identity,
		"telemetry_summary": telemetry,
		"expedition_constitution_summary": constitution_summary,
		"expedition_constitution": constitution,
		"experiment_outcomes": {"manifested_experiment_ids": ["exp_stewardship_campaign"]},
		"normalization_mode": "forensic_replay"
	})
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, run_record, catalog)
	var updated_profile: Dictionary = Dictionary(result.get("profile", {}))
	var last_run: Dictionary = Dictionary(updated_profile.get("last_run", {}))
	var header: Dictionary = Dictionary(last_run.get("forensic_bundle_header", {}))
	if str(header.get("bundle_digest", "")).strip_edges() != str(bundle.get("bundle_digest", "")).strip_edges():
		failures.append("Phase 9 profile persistence should preserve the canonical forensic bundle digest on last_run")
	if str(header.get("world_memory_snapshot_hash", "")).strip_edges().is_empty():
		failures.append("Phase 9 profile persistence should attach world_memory_snapshot_hash to the forensic bundle header")
	if str(header.get("replay_id", "")).strip_edges().is_empty():
		failures.append("Phase 9 profile persistence should preserve replay_id on the forensic bundle header")
	if Dictionary(header.get("experiment_outcomes", {})).is_empty():
		failures.append("Phase 9 profile persistence should preserve experiment_outcomes alongside the forensic bundle header")
	if JSON.stringify(header).find("\"phenomenon_manifest\"") != -1:
		failures.append("Phase 9 profile persistence should keep phenomenon_manifest out of the forensic bundle header")
	var history := Array(updated_profile.get("run_history", []))
	if history.is_empty() or str(Dictionary(Dictionary(history[0]).get("forensic_bundle_header", {})).get("world_memory_snapshot_hash", "")).strip_edges().is_empty():
		failures.append("Phase 9 run history should preserve forensic bundle header hashes without creating a second replay owner")
	if not history.is_empty() and JSON.stringify(Dictionary(Dictionary(history[0]).get("forensic_bundle_header", {}))).find("\"phenomenon_manifest\"") != -1:
		failures.append("Phase 9 run history should keep phenomenon_manifest out of persisted forensic bundle headers")
	controller.free()
	event_log.free()

func _test_expedition_constitution_schema_and_hash(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"ready_state": {2: true, 3: true, 4: true},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"group_model": {
				"dominant_build": "Traversal build",
				"group_signals": ["route control"],
				"fault_lines": ["split caution"],
				"model_pressure": ["route control"]
			}
		}
	}
	var constitution_a := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 9091, 10)
	var constitution_b := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 9091, 10)
	if str(constitution_a.get("artifact_type", "")) != "expedition_constitution":
		failures.append("Delve should emit an expedition_constitution artifact as the canonical authored law")
	if str(constitution_a.get("constitution_hash", "")).strip_edges().is_empty():
		failures.append("expedition constitution should carry a deterministic constitution_hash")
	if str(constitution_a.get("constitution_hash", "")) != str(constitution_b.get("constitution_hash", "")):
		failures.append("expedition constitution hash should remain stable for identical inputs")
	if JSON.stringify(Dictionary(constitution_a.get("generation_surface", {}))) != JSON.stringify(Dictionary(constitution_a.get("generation_contract", {}))):
		failures.append("generation_surface should stay aligned with the narrowed generation_contract adapter during migration")
	if Dictionary(constitution_a.get("ontology_snapshot", {})).is_empty():
		failures.append("expedition constitution should carry the ontology snapshot once the ontology engine is live")
	if Dictionary(constitution_a.get("compiler_trace", {})).is_empty():
		failures.append("expedition constitution should carry compiler trace data once the constitution compiler is live")
	if Dictionary(constitution_a.get("compile_metadata", {})).is_empty():
		failures.append("expedition constitution should carry explicit compile_metadata once the constitution compiler is live")
	if str(constitution_a.get("doctrine_family_id", "")).strip_edges().is_empty() or str(constitution_a.get("doctrine_variant_id", "")).strip_edges().is_empty():
		failures.append("expedition constitution should preserve compiler-owned doctrine family and variant ids")
	if Dictionary(constitution_a.get("topology_profile", {})).is_empty() or Dictionary(constitution_a.get("item_ecology_profile", {})).is_empty():
		failures.append("expedition constitution should preserve symbolic topology and item ecology profiles once the compiler is live")
	if Dictionary(constitution_a.get("fairness_bounds", {})).is_empty():
		failures.append("expedition constitution should preserve explicit fairness_bounds once the compiler is live")
	if not bool(Dictionary(constitution_a.get("fairness_bounds", {})).get("runtime_non_mutation_required", false)):
		failures.append("expedition constitution fairness_bounds should preserve runtime_non_mutation_required")
	if not bool(Dictionary(constitution_a.get("mutation_permissions", {})).get("runtime_non_authority", false)):
		failures.append("expedition constitution mutation_permissions should preserve runtime_non_authority")
	if Dictionary(Dictionary(constitution_a.get("generation_surface", {})).get("ontology_routing", {})).is_empty():
		failures.append("compiled generation surface should include ontology_routing once the ontology engine is live")
	if not Array(Dictionary(constitution_a.get("compile_metadata", {})).get("validation_failures", [])).is_empty():
		failures.append("expedition constitution compile_metadata should remain validation-clean for stable authored inputs")
	if str(Dictionary(constitution_a.get("compile_metadata", {})).get("constitution_hash", "")).strip_edges() != str(constitution_a.get("constitution_hash", "")).strip_edges():
		failures.append("compile_metadata should preserve constitution_hash once the final constitution is built")
	if str(Dictionary(constitution_a.get("compile_metadata", {})).get("constitution_id", "")).strip_edges() != str(constitution_a.get("constitution_id", "")).strip_edges():
		failures.append("compile_metadata should preserve constitution_id once the final constitution is built")
	var constitution_summary: Dictionary = Dictionary(constitution_a.get("constitution_summary", {}))
	if str(constitution_summary.get("doctrine_label", constitution_summary.get("doctrine", ""))).strip_edges().is_empty():
		failures.append("expedition constitution should expose a public-safe constitution_summary for runtime and archive adapters")

func _test_runstate_constitution_handoff(failures: Array[String]) -> void:
	var run_state_script = load("res://src/run/run_state.gd")
	if run_state_script == null:
		failures.append("run_state script should load for constitution handoff tests")
		return
	var run_state = run_state_script.new()
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.is_host = true
	var constitution := {
		"artifact_type": "expedition_constitution",
		"constitution_hash": "hash_test_001",
		"constitution_summary": {
			"protocol_state": "Fracture Protocol",
			"doctrine_label": "Measured Pressure",
			"doctrine": "Measured Pressure",
			"surface_summary": {"lines": ["Watch the split"]}
		},
		"public_summary": {
			"protocol_state": "Fracture Protocol",
			"doctrine": "Measured Pressure",
			"surface_summary": {"lines": ["Watch the split"]}
		},
		"generation_surface": {
			"protocol_state": "Fracture Protocol",
			"doctrine_family": "measured_pressure"
		},
		"generation_contract": {
			"protocol_state": "Fracture Protocol",
			"doctrine_family": "measured_pressure"
		},
		"control_surfaces": {
			"ecology": {"inhabitant_pressure": 1}
		}
	}
	manager.current_delve_directive = constitution.duplicate(true)
	if str(manager.get_current_constitution_hash()) != "hash_test_001":
		failures.append("NetworkManager should expose the canonical constitution_hash even through the directive compatibility surface")
	var peer_ids: Array[int] = [1, 2]
	run_state.set_run(4242, [{"slot": 0, "type": "traversal"}], peer_ids, {
		"constitution": manager.get_current_expedition_constitution(),
		"constitution_hash": manager.get_current_constitution_hash(),
		"constitution_summary": manager.get_current_expedition_constitution_summary(),
		"generation_surface": manager.get_current_generation_contract()
	})
	if str(run_state.constitution_hash) != "hash_test_001":
		failures.append("RunState should retain the loaded constitution_hash as the runtime law owner")
	if Dictionary(run_state.get_expedition_constitution()).is_empty():
		failures.append("RunState should retain the loaded expedition constitution as the runtime law owner")
	if JSON.stringify(run_state.generation_surface) != JSON.stringify(Dictionary(constitution.get("generation_surface", {}))):
		failures.append("RunState should retain the narrowed generation surface during run start")
	manager.free()
	run_state.clear()
	run_state.free()

func _test_delve_live_handoff_and_summary(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	profile["account"] = {
		"display_name": "Handoff Delver",
		"public_id": "handoff_delver",
		"xp": 0,
		"level": 1,
		"runs": 0,
		"expedition_wins": 0,
		"sabotage_wins": 0
	}
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"ready_state": {2: true, 3: true, 4: true},
		"gameplay_snapshot": {
			"protocol_state": "Fracture Protocol",
			"player_count": 3,
			"build_identities": ["Traversal build", "Deception build"],
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["ghost pressure"],
			"group_model": {
				"dominant_build": "Traversal build",
				"group_signals": ["route control", "public answer appetite"],
				"model_pressure": ["route-control is starting to look like the shared answer"],
				"fault_lines": ["the group is split between a volatile answer and a rescue answer"]
			}
		}
	}
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 51515, 15)

	var host_nm := NETWORK_MANAGER_SCRIPT.new()
	host_nm.is_host = true
	host_nm.current_delve_directive = directive.duplicate(true)
	host_nm.host_start_run(51515, [{"slot": 0, "type": "traversal"}], [2, 3, 4], host_nm._directive_public_summary(directive))
	if Dictionary(host_nm.current_delve_directive.get("control_surfaces", {})).is_empty():
		failures.append("host run-start handoff should preserve the computed delve directive for host-local runtime access")
	if JSON.stringify(host_nm.get_current_generation_contract()) != JSON.stringify(Dictionary(directive.get("generation_contract", {}))):
		failures.append("host run-start handoff should preserve the explicit generation_contract on the host-private path")
	if host_nm.get_current_inhabitant_pressure_bias() != int(Dictionary(Dictionary(directive.get("control_surfaces", {})).get("ecology", {})).get("inhabitant_pressure", 0)):
		failures.append("host-local delve surface accessors should retain ecology pressure after run start")
	host_nm.free()

	var client_nm := NETWORK_MANAGER_SCRIPT.new()
	client_nm.is_host = false
	var public_summary := client_nm._directive_public_summary(directive)
	client_nm.host_start_run(51515, [{"slot": 0, "type": "traversal"}], [2, 3, 4], public_summary)
	var client_directive := client_nm.get_current_delve_directive()
	if str(client_directive.get("doctrine_label", "")).strip_edges().is_empty():
		failures.append("clients should retain the public-safe delve summary after run start")
	var client_surface_summary: Dictionary = Dictionary(client_directive.get("surface_summary", {}))
	if not client_surface_summary.has("lines"):
		failures.append("clients should retain public-safe surface-summary lines after run start")
	if client_surface_summary.has("clamped") or client_surface_summary.has("strongest"):
		failures.append("clients should only receive line-level surface summaries, not clamped control-surface internals")
	if Array(client_directive.get("dominant_minds", [])).is_empty() or str(client_directive.get("archive_tone", "")).strip_edges().is_empty():
		failures.append("clients should retain the public-safe lattice carryover fields after run start")
	if Array(client_directive.get("dominant_domains", [])).is_empty() or Array(client_directive.get("pressure_grammar", [])).is_empty() or Array(client_directive.get("symbolic_motifs", [])).is_empty():
		failures.append("clients should retain the public-safe authored force/domain/motif tags after run start")
	if str(client_directive.get("item_ecology_bias", "")).strip_edges().is_empty() or str(client_directive.get("group_tension_bias", "")).strip_edges().is_empty() or str(client_directive.get("convergence_axis", "")).strip_edges().is_empty():
		failures.append("clients should retain public-safe item, group, and convergence carryover after run start")
	if client_directive.has("run_identity") or client_directive.has("mind_balance"):
		failures.append("clients should not receive host-only run identity or mind-balance internals")
	if not Dictionary(client_directive.get("control_surfaces", {})).is_empty():
		failures.append("clients should not receive the full delve control-surface policy bundle")
	if not client_nm.get_current_generation_contract().is_empty():
		failures.append("clients should not receive the host-private generation_contract")
	client_nm.free()

func _test_delve_live_control_surface_consumption(failures: Array[String]) -> void:
	var pressure_directive := {
		"control_surfaces": {
			"generation": {
				"witness_exposure": 2,
				"rescue_geometry": -2,
				"loop_probability": 2
			},
			"ecology": {
				"inhabitant_pressure": 2,
				"stalking_bias": 2,
				"anomaly_contamination": 2
			},
			"economy": {
				"resource_austerity": 2,
				"recovery_cushion": -2,
				"commitment_cost": 2,
				"lure_abundance": 2
			}
		}
	}
	var recovery_directive := {
		"control_surfaces": {
			"generation": {
				"witness_exposure": -1,
				"rescue_geometry": 2,
				"loop_probability": -2
			},
			"ecology": {
				"inhabitant_pressure": -1,
				"stalking_bias": -2,
				"anomaly_contamination": -1
			},
			"economy": {
				"resource_austerity": -1,
				"recovery_cushion": 2,
				"commitment_cost": -2,
				"lure_abundance": -2
			}
		}
	}
	var rescue_item_directive := {
		"control_surfaces": {
			"generation": {
				"rescue_geometry": 2
			},
			"economy": {
				"recovery_cushion": 2
			}
		}
	}

	var pressure_nm := NETWORK_MANAGER_SCRIPT.new()
	pressure_nm.current_delve_directive = pressure_directive.duplicate(true)
	pressure_nm.items_by_id = {
		1: {"item_id": 1, "item_def_id": "heavy_boots", "owner_peer_id": 2, "consumed": false},
		2: {"item_id": 2, "item_def_id": "lantern_snuffer", "owner_peer_id": 3, "consumed": false}
	}
	var recovery_nm := NETWORK_MANAGER_SCRIPT.new()
	recovery_nm.current_delve_directive = recovery_directive.duplicate(true)
	recovery_nm.items_by_id = pressure_nm.items_by_id.duplicate(true)
	if pressure_nm.extraction_window_ticks_for_test() <= recovery_nm.extraction_window_ticks_for_test():
		failures.append("live Delve runtime consumption should lengthen extraction windows under harsher pressure bundles")
	if pressure_nm.ghost_wake_tick_for_test() >= recovery_nm.ghost_wake_tick_for_test():
		failures.append("live Delve runtime consumption should wake ghost pressure earlier under stronger stalking pressure")
	if pressure_nm.ghost_speed_per_tick_for_test() <= recovery_nm.ghost_speed_per_tick_for_test():
		failures.append("live Delve runtime consumption should accelerate ghost pressure under stronger ecology pressure")
	if pressure_nm.ghost_hit_radius_for_test() <= recovery_nm.ghost_hit_radius_for_test():
		failures.append("live Delve runtime consumption should widen ghost strike reach under stronger ecology pressure")
	if pressure_nm.noise_trace_interval_for_test(2) >= recovery_nm.noise_trace_interval_for_test(2):
		failures.append("live Delve runtime consumption should shorten artifact noise cadence under stronger stalking pressure")
	var pressure_tick := pressure_nm.ghost_wake_tick_for_test() + 1
	var pressure_active := pressure_nm.advance_ghost_pressure_for_test(pressure_tick, {2: 1, 3: 5}, {2: Vector2(100, 100), 3: Vector2(500, 100)}, [2, 3], 7, {2: true})
	var recovery_active := recovery_nm.advance_ghost_pressure_for_test(pressure_tick, {2: 1, 3: 5}, {2: Vector2(100, 100), 3: Vector2(500, 100)}, [2, 3], 7, {2: true})
	if not bool(pressure_active.get("active", false)) or bool(recovery_active.get("active", false)):
		failures.append("live Delve runtime consumption should change ghost activation timing without widening client payloads")
	pressure_nm.free()
	recovery_nm.free()

	var generator := RUN_GENERATOR_SCRIPT.new()
	var pressure_weights := generator.room_type_weights_for_slot_for_test(6, 15, pressure_directive)
	var recovery_weights := generator.room_type_weights_for_slot_for_test(6, 15, recovery_directive)
	if int(pressure_weights.get("hazard", 0)) <= int(recovery_weights.get("hazard", 0)):
		failures.append("run generation should deepen hazard weighting under stalking and anomaly-heavy control surfaces")
	if int(pressure_weights.get("evidence", 0)) <= int(recovery_weights.get("evidence", 0)):
		failures.append("run generation should deepen evidence weighting under witness and loop-heavy control surfaces")
	if generator.risk_for_slot_for_test(9917, 9, 15, "hazard", pressure_directive) <= generator.risk_for_slot_for_test(9917, 9, 15, "hazard", recovery_directive):
		failures.append("run generation should raise deterministic room risk under harsher control-surface bundles")
	var pressure_chain_a := generator.generate_layout(9917, 15, pressure_directive)
	var pressure_chain_b := generator.generate_layout(9917, 15, pressure_directive)
	if JSON.stringify(pressure_chain_a) != JSON.stringify(pressure_chain_b):
		failures.append("directive-shaped room generation should remain deterministic after deeper control-surface consumption")
	var recovery_chain := generator.generate_layout(9917, 15, recovery_directive)
	if JSON.stringify(pressure_chain_a) == JSON.stringify(recovery_chain):
		failures.append("directive-shaped room generation should materially change under distinct control-surface bundles")

	var item_service := ITEM_SERVICE_SCRIPT.new()
	if item_service.directive_bonus_for_item_for_test("decoy_emitter", pressure_directive) <= item_service.directive_bonus_for_item_for_test("decoy_emitter", recovery_directive):
		failures.append("item service should deepen lure weighting for deception-heavy items under lure-abundance pressure")
	if item_service.directive_bonus_for_item_for_test("zipline_kit", rescue_item_directive) <= item_service.directive_bonus_for_item_for_test("zipline_kit", pressure_directive):
		failures.append("item service should deepen rescue weighting for route-support items under recovery geometry pressure")
	var pressure_spawns_a := item_service.generate_item_spawns(9917, pressure_chain_a, pressure_directive)
	var pressure_spawns_b := item_service.generate_item_spawns(9917, pressure_chain_a, pressure_directive)
	if JSON.stringify(pressure_spawns_a) != JSON.stringify(pressure_spawns_b):
		failures.append("directive-shaped item spawns should remain deterministic after deeper control-surface consumption")
	var recovery_spawns := item_service.generate_item_spawns(9917, recovery_chain, recovery_directive)
	if JSON.stringify(pressure_spawns_a) == JSON.stringify(recovery_spawns):
		failures.append("directive-shaped item spawns should materially change under distinct control-surface bundles")

func _test_branch_and_protocol_weighting_depth(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var exposure_weights := generator.branch_family_weights_for_test({"protocol_state": "Exposure Protocol"})
	var fracture_weights := generator.branch_family_weights_for_test({"protocol_state": "Fracture Protocol"})
	var intimate_weights := generator.branch_family_weights_for_test({"protocol_state": "Intimate Protocol"})
	if int(exposure_weights.get("watcher_steps", 0)) <= int(fracture_weights.get("watcher_steps", 0)):
		failures.append("branch weighting should favor watcher_steps more strongly under Exposure Protocol than Fracture Protocol")
	if int(fracture_weights.get("sundered_span", 0)) <= int(exposure_weights.get("sundered_span", 0)):
		failures.append("branch weighting should favor sundered_span more strongly under Fracture Protocol than Exposure Protocol")
	if int(intimate_weights.get("relay_hollows", 0)) <= int(exposure_weights.get("relay_hollows", 0)):
		failures.append("branch weighting should favor relay_hollows more strongly under Intimate Protocol than Exposure Protocol")
	var relay_room_weights := generator.room_type_weights_for_branch_for_test(6, 15, "relay_hollows", {"protocol_state": "Intimate Protocol"})
	var grave_room_weights := generator.room_type_weights_for_branch_for_test(6, 15, "grave_lattice", {"protocol_state": "Exposure Protocol"})
	if int(relay_room_weights.get("traversal", 0)) <= int(grave_room_weights.get("traversal", 0)):
		failures.append("branch room weighting should make relay_hollows read as a more traversal-led branch than grave_lattice")
	if int(grave_room_weights.get("hazard", 0)) <= int(relay_room_weights.get("hazard", 0)):
		failures.append("branch room weighting should make grave_lattice read as a harsher branch than relay_hollows")
	if int(grave_room_weights.get("evidence", 0)) <= int(relay_room_weights.get("evidence", 0)):
		failures.append("branch room weighting should make grave_lattice push stronger evidence pressure than relay_hollows")
	var fracture_chain_a := generator.generate_layout(4242, 15, {"protocol_state": "Fracture Protocol"})
	var fracture_chain_b := generator.generate_layout(4242, 15, {"protocol_state": "Fracture Protocol"})
	if JSON.stringify(fracture_chain_a) != JSON.stringify(fracture_chain_b):
		failures.append("branch and protocol weighting should remain deterministic for identical seeds and directives")
	var exposure_chain := generator.generate_layout(4242, 15, {"protocol_state": "Exposure Protocol"})
	if JSON.stringify(fracture_chain_a) == JSON.stringify(exposure_chain):
		failures.append("branch and protocol weighting should materially change generated room chains across protocol states")

	var item_service := ITEM_SERVICE_SCRIPT.new()
	var relay_room := {
		"slot": 2,
		"type": "traversal",
		"branch_family_id": "relay_hollows",
		"protocol_state": "Intimate Protocol"
	}
	var grave_room := {
		"slot": 2,
		"type": "evidence",
		"branch_family_id": "grave_lattice",
		"protocol_state": "Exposure Protocol"
	}
	if item_service.directive_bonus_for_item_for_test("timeline_bookmark", {}, relay_room) <= item_service.directive_bonus_for_item_for_test("timeline_bookmark", {}, grave_room):
		failures.append("item generation should favor relay-hollows protocol-aligned tools in intimate rooms")
	if item_service.directive_bonus_for_item_for_test("lantern_snuffer", {}, grave_room) <= item_service.directive_bonus_for_item_for_test("lantern_snuffer", {}, relay_room):
		failures.append("item generation should favor grave-lattice protocol-aligned relics in exposure rooms")
	var relay_chain := [
		{"slot": 0, "type": "traversal", "branch_family_id": "relay_hollows", "protocol_state": "Intimate Protocol"},
		{"slot": 1, "type": "evidence", "branch_family_id": "relay_hollows", "protocol_state": "Intimate Protocol"},
		{"slot": 2, "type": "traversal", "branch_family_id": "relay_hollows", "protocol_state": "Intimate Protocol"},
		{"slot": 3, "type": "hazard", "branch_family_id": "relay_hollows", "protocol_state": "Intimate Protocol"},
		{"slot": 4, "type": "evidence", "branch_family_id": "relay_hollows", "protocol_state": "Intimate Protocol"},
		{"slot": 5, "type": "traversal", "branch_family_id": "relay_hollows", "protocol_state": "Intimate Protocol"}
	]
	var grave_chain := [
		{"slot": 0, "type": "traversal", "branch_family_id": "grave_lattice", "protocol_state": "Exposure Protocol"},
		{"slot": 1, "type": "evidence", "branch_family_id": "grave_lattice", "protocol_state": "Exposure Protocol"},
		{"slot": 2, "type": "traversal", "branch_family_id": "grave_lattice", "protocol_state": "Exposure Protocol"},
		{"slot": 3, "type": "hazard", "branch_family_id": "grave_lattice", "protocol_state": "Exposure Protocol"},
		{"slot": 4, "type": "evidence", "branch_family_id": "grave_lattice", "protocol_state": "Exposure Protocol"},
		{"slot": 5, "type": "traversal", "branch_family_id": "grave_lattice", "protocol_state": "Exposure Protocol"}
	]
	var relay_directive := {
		"protocol_state": "Intimate Protocol",
		"item_ecology_bias": "rescue memory",
		"archive_tone": "memory",
		"convergence_axis": "custody"
	}
	var grave_directive := {
		"protocol_state": "Exposure Protocol",
		"item_ecology_bias": "deception scarcity",
		"archive_tone": "dispute memory",
		"convergence_axis": "fragment"
	}
	var relay_spawns_a := item_service.generate_item_spawns(7331, relay_chain, relay_directive)
	var relay_spawns_b := item_service.generate_item_spawns(7331, relay_chain, relay_directive)
	if JSON.stringify(relay_spawns_a) != JSON.stringify(relay_spawns_b):
		failures.append("branch- and protocol-shaped item generation should remain deterministic")
	var grave_spawns := item_service.generate_item_spawns(7331, grave_chain, grave_directive)
	if JSON.stringify(relay_spawns_a) == JSON.stringify(grave_spawns):
		failures.append("branch and protocol weighting should materially change generated item spawns across room doctrines")

func _test_ordered_next_tier_branch_pressure(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var custody_directive := {
		"protocol_state": "Intimate Protocol",
		"public_summary": _ordered_signal_public_summary_for_test("custody", "Intimate Protocol")
	}
	var scandal_directive := {
		"protocol_state": "Fracture Protocol",
		"public_summary": _ordered_signal_public_summary_for_test("scandal", "Fracture Protocol")
	}
	var custody_weights := generator.branch_family_weights_for_test(custody_directive)
	var scandal_weights := generator.branch_family_weights_for_test(scandal_directive)
	if int(custody_weights.get("relay_hollows", 0)) <= int(scandal_weights.get("relay_hollows", 0)):
		failures.append("next-tier branch pressure should favor relay_hollows under custody-shaped public summaries")
	if int(scandal_weights.get("sundered_span", 0)) <= int(custody_weights.get("sundered_span", 0)):
		failures.append("next-tier branch pressure should favor sundered_span under scandal-shaped public summaries")
	var custody_chain_a := generator.generate_layout(8181, 15, custody_directive)
	var custody_chain_b := generator.generate_layout(8181, 15, custody_directive)
	if JSON.stringify(custody_chain_a) != JSON.stringify(custody_chain_b):
		failures.append("next-tier branch pressure shaping should remain deterministic for identical seeds and summaries")
	var scandal_chain := generator.generate_layout(8181, 15, scandal_directive)
	if JSON.stringify(custody_chain_a) == JSON.stringify(scandal_chain):
		failures.append("next-tier branch pressure shaping should materially change generated room chains across summary modes")
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var custody_room := _ordered_signal_room_for_test("relay_hollows", "Intimate Protocol", _ordered_signal_public_summary_for_test("custody", "Intimate Protocol"), "relay gate")
	var scandal_room := _ordered_signal_room_for_test("relay_hollows", "Intimate Protocol", _ordered_signal_public_summary_for_test("scandal", "Intimate Protocol"), "corridor")
	if item_service.directive_bonus_for_item_for_test("zipline_kit", custody_directive, custody_room) <= item_service.directive_bonus_for_item_for_test("zipline_kit", scandal_directive, scandal_room):
		failures.append("next-tier item weighting should read rescue-custody route rooms differently from scandal-shaped route rooms")
	if item_service.directive_bonus_for_item_for_test("decoy_emitter", scandal_directive, scandal_room) <= item_service.directive_bonus_for_item_for_test("decoy_emitter", custody_directive, custody_room):
		failures.append("next-tier item weighting should favor scandal-shaped route rooms for misdirection tools")

func _test_ordered_next_tier_artifact_ecology_signaling(failures: Array[String]) -> void:
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var timeline_profile := item_service.build_narrative_profile("timeline_bookmark")
	if Array(timeline_profile.get("lineage_hints", [])).is_empty() or Array(timeline_profile.get("branch_markers", [])).is_empty():
		failures.append("item ecology signaling should expose lineage and branch markers for archive-facing items")
	if Array(timeline_profile.get("memory_hints", [])).is_empty() or Array(timeline_profile.get("prestige_indicators", [])).is_empty():
		failures.append("item ecology signaling should expose memory and prestige indicators for archive-facing items")
	var boots_profile := item_service.build_narrative_profile("heavy_boots")
	if Array(boots_profile.get("memory_hints", [])).is_empty() or Array(boots_profile.get("prestige_indicators", [])).is_empty():
		failures.append("item ecology signaling should expose burden-memory and prestige hints for high-pressure items")
	var run_record := _ordered_signal_test_run_record("relay_hollows", "Intimate Protocol", "custody", 7401, "custody")
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	if Array(diagnostics.get("artifact_lineage_hints", [])).is_empty():
		failures.append("diagnostics should retain artifact lineage hints for product interpretation")
	if Array(diagnostics.get("artifact_branch_markers", [])).is_empty():
		failures.append("diagnostics should retain branch-association markers for product interpretation")
	if Array(diagnostics.get("artifact_memory_hints", [])).is_empty():
		failures.append("diagnostics should retain rescue/scandal memory hints for product interpretation")
	if Array(diagnostics.get("artifact_prestige_indicators", [])).is_empty() or str(diagnostics.get("artifact_cultural_association", "")).strip_edges().is_empty():
		failures.append("diagnostics should retain artifact prestige and cultural-association hints for product interpretation")

func _test_ordered_next_tier_crawl_memory_and_archive_signals(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile_a := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile_a["world_memory"] = WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	profile_a["archive_state"] = ARCHIVE_SERVICE_SCRIPT.default_state()
	var run_a := _ordered_signal_test_run_record("relay_hollows", "Intimate Protocol", "custody", 7401, "custody")
	var run_b := _ordered_signal_test_run_record("grave_lattice", "Exposure Protocol", "scandal", 7402, "scandal")
	_apply_ordered_signal_run(profile_a, run_a)
	_apply_ordered_signal_run(profile_a, run_b)
	var crawl_lines := CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(profile_a)
	if crawl_lines.filter(func(line: String) -> bool: return line.begins_with("Artifact echo: ")).is_empty():
		failures.append("crawl continuity should surface artifact ecology signals on the existing shell path")
	var archive_lines := ARCHIVE_SERVICE_SCRIPT.build_archive_lines(profile_a)
	if archive_lines.filter(func(line: String) -> bool: return line.begins_with("Artifact echo: ")).is_empty():
		failures.append("archive lines should surface compact artifact ecology signals")
	if archive_lines.filter(func(line: String) -> bool: return line.begins_with("Branch drift: ")).is_empty():
		failures.append("archive lines should surface compact branch-drift signals")
	var archive_state := Dictionary(profile_a.get("archive_state", {}))
	var cases := Array(archive_state.get("cases", []))
	if cases.is_empty():
		failures.append("ordered next-tier runs should produce archive cases")
	else:
		var latest_case: Dictionary = Dictionary(cases[0])
		if str(latest_case.get("comparison_line", "")).strip_edges().is_empty():
			failures.append("archive comparison should stay populated after repeated signal-aware runs")
		if str(latest_case.get("artifact_signal_line", "")).strip_edges().is_empty():
			failures.append("archive cases should preserve compact artifact-signal summaries")
		if str(latest_case.get("branch_signal_line", "")).strip_edges().is_empty():
			failures.append("archive cases should preserve compact branch-drift summaries")
	var world_lines := WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(Dictionary(profile_a.get("world_memory", {})))
	if world_lines.filter(func(line: String) -> bool: return line.begins_with("Branch drift: ")).is_empty():
		failures.append("world memory lines should surface branch reputation drift")
	if world_lines.filter(func(line: String) -> bool: return line.begins_with("Artifact culture: ")).is_empty():
		failures.append("world memory lines should surface artifact cultural association")
	var profile_b := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile_b["world_memory"] = WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	profile_b["archive_state"] = ARCHIVE_SERVICE_SCRIPT.default_state()
	_apply_ordered_signal_run(profile_b, run_a)
	_apply_ordered_signal_run(profile_b, run_b)
	if JSON.stringify(Dictionary(profile_a.get("archive_state", {}))) != JSON.stringify(Dictionary(profile_b.get("archive_state", {}))):
		failures.append("archive signal shaping should remain deterministic across identical replayed runs")
	if JSON.stringify(Dictionary(profile_a.get("world_memory", {}))) != JSON.stringify(Dictionary(profile_b.get("world_memory", {}))):
		failures.append("world-memory signal shaping should remain deterministic across identical replayed runs")

func _test_read_only_ecology_signal_carryover(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["world_memory"] = WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	profile["archive_state"] = ARCHIVE_SERVICE_SCRIPT.default_state()
	var run_record := _ordered_signal_test_run_record("relay_hollows", "Intimate Protocol", "custody", 7417, "ecology")
	var gameplay_snapshot: Dictionary = Dictionary(run_record.get("gameplay_signal_snapshot", {}))
	gameplay_snapshot["inhabitant_pressure"] = ["ghost pressure", "echo pressure", "artifact watched"]
	run_record["gameplay_signal_snapshot"] = gameplay_snapshot
	var applied := _apply_ordered_signal_run(profile, run_record)
	var diagnostics: Dictionary = Dictionary(applied.get("diagnostics", {}))
	var ecology_highlights := _string_array_for_test(Array(diagnostics.get("ecology_signal_highlights", [])))
	if ecology_highlights.size() < 2 or ecology_highlights[0] != "echo pressure" or ecology_highlights[1] != "artifact watched":
		failures.append("product diagnostics should prioritize new ecology signals ahead of generic ghost pressure")
	var frame: Dictionary = Dictionary(applied.get("frame", {}))
	var inhabitant_line := str(frame.get("inhabitant_line", "")).to_lower()
	if inhabitant_line.find("echo pressure") == -1:
		failures.append("framing should surface the prioritized ecology signal through the existing presence line")
	var crawl_lines := CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(profile)
	var crawl_presence := ""
	for line in crawl_lines:
		if str(line).begins_with("Presence: "):
			crawl_presence = str(line).to_lower()
			break
	if crawl_presence.find("echo pressure") == -1:
		failures.append("crawl carryover should preserve prioritized ecology pressure on the existing shell path")
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(profile, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("ecology carryover requires archive cases to remain available")
	else:
		var archive_detail := str(Dictionary(archive_entries[0]).get("detail", "")).to_lower()
		if archive_detail.find("presence:") == -1 or archive_detail.find("echo pressure") == -1:
			failures.append("archive case detail should surface the prioritized ecology presence without widening payloads")
	var world_memory := Dictionary(applied.get("world_memory", {}))
	var world_has_echo := false
	for bucket in ["branch", "pair", "player", "crawl", "place", "run_shape"]:
		for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, bucket, 3):
			var shadow_tags := _string_array_for_test(Array(Dictionary(entry).get("shadow_tags", [])))
			if shadow_tags.has("echo pressure"):
				world_has_echo = true
				break
		if world_has_echo:
			break
	if not world_has_echo:
		failures.append("world memory should carry prioritized ecology pressure through existing shadow-tag interpretation")

func _test_read_only_predator_signal_carryover(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["world_memory"] = WORLD_MEMORY_SERVICE_SCRIPT.default_state()
	profile["archive_state"] = ARCHIVE_SERVICE_SCRIPT.default_state()
	var run_record := _ordered_signal_test_run_record("grave_lattice", "Exposure Protocol", "custody", 7421, "ecology")
	var gameplay_snapshot: Dictionary = Dictionary(run_record.get("gameplay_signal_snapshot", {}))
	gameplay_snapshot["inhabitant_pressure"] = ["ghost pressure", "predator rush", "predator marked", "artifact watched"]
	run_record["gameplay_signal_snapshot"] = gameplay_snapshot
	var applied := _apply_ordered_signal_run(profile, run_record)
	var diagnostics: Dictionary = Dictionary(applied.get("diagnostics", {}))
	var ecology_highlights := _string_array_for_test(Array(diagnostics.get("ecology_signal_highlights", [])))
	if ecology_highlights.size() < 2 or ecology_highlights[0] != "predator rush" or ecology_highlights[1] != "predator marked":
		failures.append("product diagnostics should prioritize predator ecology signals ahead of generic ghost pressure")
	var frame: Dictionary = Dictionary(applied.get("frame", {}))
	var inhabitant_line := str(frame.get("inhabitant_line", "")).to_lower()
	if inhabitant_line.find("predator rush") == -1:
		failures.append("framing should surface predator pressure through the existing presence line")
	var crawl_lines := CRAWL_SERVICE_SCRIPT.build_active_crawl_lines(profile)
	var crawl_presence := ""
	for line in crawl_lines:
		if str(line).begins_with("Presence: "):
			crawl_presence = str(line).to_lower()
			break
	if crawl_presence.find("predator rush") == -1:
		failures.append("crawl carryover should preserve prioritized predator pressure on the existing shell path")
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(profile, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("predator ecology carryover requires archive cases to remain available")
	else:
		var archive_detail := str(Dictionary(archive_entries[0]).get("detail", "")).to_lower()
		if archive_detail.find("presence:") == -1 or archive_detail.find("predator rush") == -1:
			failures.append("archive case detail should surface the prioritized predator presence without widening payloads")
	var world_memory := Dictionary(applied.get("world_memory", {}))
	var world_has_predator := false
	for bucket in ["branch", "pair", "player", "crawl", "place", "run_shape"]:
		for entry in WORLD_MEMORY_SERVICE_SCRIPT.top_bucket_entries(world_memory, bucket, 3):
			var shadow_tags := _string_array_for_test(Array(Dictionary(entry).get("shadow_tags", [])))
			if shadow_tags.has("predator rush"):
				world_has_predator = true
				break
		if world_has_predator:
			break
	if not world_has_predator:
		failures.append("world memory should carry prioritized predator pressure through existing shadow-tag interpretation")

func _ordered_signal_public_summary_for_test(mode: String, protocol_state: String) -> Dictionary:
	if mode == "scandal":
		return {
			"protocol_state": protocol_state,
			"doctrine": "Examiner Dispute",
			"pressure_line": "Volatile fragmentation with scarcity",
			"world_goal": "Keep the contested answer visible.",
			"dominant_domains": ["Group Tension", "Pressure Grammar", "Archive Interpretation"],
			"dominant_minds": ["Examiner (Primary Author)"],
			"pressure_grammar": ["Fragmentation", "Scarcity"],
			"symbolic_motifs": ["Split Echoes"],
			"item_ecology_bias": "deception scandal scarcity",
			"group_tension_bias": "ambiguous fault pressure",
			"archive_tone": "forensic dispute",
			"convergence_axis": "fragmentation"
		}
	return {
		"protocol_state": protocol_state,
		"doctrine": "Archivist Custody",
		"pressure_line": "Steady convergence with rescue pressure",
		"world_goal": "Keep the carried answer recoverable.",
		"dominant_domains": ["Topology", "Archive Interpretation", "Item Ecology"],
		"dominant_minds": ["Archivist (Primary Author)"],
		"pressure_grammar": ["Convergence", "Compression"],
		"symbolic_motifs": ["Archive Scars"],
		"item_ecology_bias": "rescue burden custody",
		"group_tension_bias": "shared burden caution",
		"archive_tone": "memory custody",
		"convergence_axis": "artifact custody"
	}

func _ordered_signal_branch_context_for_test(branch_family_id: String, protocol_state: String, public_summary: Dictionary, anchor_override: String = "") -> Dictionary:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var branch_family: Dictionary = Dictionary(generator._branch_family_from_id(branch_family_id))
	var symbolic_places := Array(branch_family.get("symbolic_places", []))
	var context := branch_family.duplicate(true)
	context["branch_family_id"] = branch_family_id
	context["branch_family_name"] = str(branch_family.get("display_name", branch_family_id))
	context["slot_band"] = "middle_late"
	context["pressure_profile"] = [
		str(branch_family.get("social_pressure", "")),
		str(branch_family.get("challenge_texture", "")),
		str(branch_family.get("confrontation_climate", "")),
		str(branch_family.get("rescue_climate", "")),
		str(branch_family.get("burden_pressure", ""))
	]
	context["symbolic_anchor"] = anchor_override if not anchor_override.is_empty() else str(symbolic_places[0] if not symbolic_places.is_empty() else "")
	context["doctrine_family"] = "ordered_signal_doctrine"
	context["doctrine_label"] = str(public_summary.get("doctrine", "Ordered Signal Doctrine"))
	context["protocol_state"] = protocol_state
	context["directive_summary"] = public_summary.duplicate(true)
	context["surface_summary"] = {
		"lines": ["Conflict pressure is fraying the public answer."] if str(public_summary.get("convergence_axis", "")).find("fragment") != -1 else ["Rescue geometry is drawing the public answer."]
	}
	context["run_identity_summary"] = {
		"pacing_profile": "volatile" if str(public_summary.get("convergence_axis", "")).find("fragment") != -1 else "steady",
		"pressure_grammar": Array(public_summary.get("pressure_grammar", [])).duplicate(),
		"symbolic_motifs": Array(public_summary.get("symbolic_motifs", [])).duplicate(),
		"dominant_minds": Array(public_summary.get("dominant_minds", [])).duplicate(),
		"convergence_axis": str(public_summary.get("convergence_axis", "balanced")),
		"readability": 2
	}
	context["reputation_seeds"] = [
		str(branch_family.get("social_pressure", "")),
		str(branch_family.get("confrontation_climate", "")),
		str(branch_family.get("rescue_climate", "")),
		str(branch_family.get("burden_pressure", ""))
	]
	return context

func _ordered_signal_room_for_test(branch_family_id: String, protocol_state: String, public_summary: Dictionary, anchor_override: String = "") -> Dictionary:
	return {
		"slot": 4,
		"type": "traversal",
		"branch_family_id": branch_family_id,
		"protocol_state": protocol_state,
		"branch_context": _ordered_signal_branch_context_for_test(branch_family_id, protocol_state, public_summary, anchor_override)
	}

func _ordered_signal_test_run_record(branch_family_id: String, protocol_state: String, mode: String, seed_value: int, tag: String) -> Dictionary:
	var public_summary := _ordered_signal_public_summary_for_test(mode, protocol_state)
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var local_items := _string_array_for_test(["timeline_bookmark", "zipline_kit", "heavy_boots"] if mode == "custody" else ["timeline_bookmark", "decoy_emitter", "lantern_snuffer"])
	var wing_items := _string_array_for_test(["decoy_emitter", "lantern_snuffer"] if mode == "custody" else ["zipline_kit", "heavy_boots"])
	var local_loadout: Dictionary = item_service.resolve_loadout_state(local_items, {
		"tool_counts": {"bomb": 1, "rope": 1},
		"protocol_state": protocol_state,
		"carrying_artifact": true,
		"ghost_active": true
	})
	var wing_loadout: Dictionary = item_service.resolve_loadout_state(wing_items, {
		"tool_counts": {"bomb": 1, "rope": 1},
		"protocol_state": protocol_state,
		"carrying_artifact": false,
		"ghost_active": true
	})
	var local_public_id := "signal_%s" % tag
	var wing_public_id := "wing_%s" % tag
	var branch_context := _ordered_signal_branch_context_for_test(branch_family_id, protocol_state, public_summary)
	var room_chain_summary := [
		{"slot": 0, "type": "traversal", "branch_family_id": branch_family_id, "branch_family_name": str(branch_context.get("branch_family_name", branch_family_id)), "branch_context": branch_context.duplicate(true)},
		{"slot": 1, "type": "evidence", "branch_family_id": branch_family_id, "branch_family_name": str(branch_context.get("branch_family_name", branch_family_id)), "branch_context": branch_context.duplicate(true)},
		{"slot": 2, "type": "hazard", "branch_family_id": branch_family_id, "branch_family_name": str(branch_context.get("branch_family_name", branch_family_id)), "branch_context": branch_context.duplicate(true)}
	]
	var local_model := {
		"peer_id": 2,
		"public_id": local_public_id,
		"display_name": "Signal %s" % tag.capitalize(),
		"item_defs": local_items.duplicate(),
		"active_item_defs": item_service.active_item_ids_for_items(local_items),
		"tool_counts": {"bomb": 1, "rope": 1},
		"carrying_artifact": true,
		"protocol_state": protocol_state,
		"build_identity": str(local_loadout.get("build_identity", "Mixed build")),
		"build_scores": Dictionary(local_loadout.get("build_scores", {})).duplicate(true),
		"behavior_signals": Array(local_loadout.get("behavior_signals", [])).duplicate(),
		"synergy_labels": Array(local_loadout.get("synergy_labels", [])).duplicate(),
		"ritual_hooks": Array(local_loadout.get("ritual_hooks", [])).duplicate(),
		"anomaly_hooks": Array(local_loadout.get("anomaly_hooks", [])).duplicate(),
		"protocol_hooks": Array(local_loadout.get("protocol_hooks", [])).duplicate(),
		"resource_signals": Array(local_loadout.get("resource_signals", [])).duplicate(),
		"feature_scores": Dictionary(local_loadout.get("feature_scores", {})).duplicate(true),
		"feature_signals": Array(local_loadout.get("feature_signals", [])).duplicate(),
		"build_stability": int(local_loadout.get("build_stability", 0)),
		"risk_profile": str(local_loadout.get("risk_profile", "mixed")),
		"model_pressure": Array(local_loadout.get("model_pressure", [])).duplicate(),
		"latent_totals": Dictionary(local_loadout.get("latent_totals", {})).duplicate(true),
		"inhabitant_signals": ["ghost pressure", "artifact watched"]
	}
	var wing_model := {
		"peer_id": 3,
		"public_id": wing_public_id,
		"display_name": "Wing %s" % tag.capitalize(),
		"item_defs": wing_items.duplicate(),
		"active_item_defs": item_service.active_item_ids_for_items(wing_items),
		"tool_counts": {"bomb": 1, "rope": 1},
		"carrying_artifact": false,
		"protocol_state": protocol_state,
		"build_identity": str(wing_loadout.get("build_identity", "Mixed build")),
		"build_scores": Dictionary(wing_loadout.get("build_scores", {})).duplicate(true),
		"behavior_signals": Array(wing_loadout.get("behavior_signals", [])).duplicate(),
		"synergy_labels": Array(wing_loadout.get("synergy_labels", [])).duplicate(),
		"ritual_hooks": Array(wing_loadout.get("ritual_hooks", [])).duplicate(),
		"anomaly_hooks": Array(wing_loadout.get("anomaly_hooks", [])).duplicate(),
		"protocol_hooks": Array(wing_loadout.get("protocol_hooks", [])).duplicate(),
		"resource_signals": Array(wing_loadout.get("resource_signals", [])).duplicate(),
		"feature_scores": Dictionary(wing_loadout.get("feature_scores", {})).duplicate(true),
		"feature_signals": Array(wing_loadout.get("feature_signals", [])).duplicate(),
		"build_stability": int(wing_loadout.get("build_stability", 0)),
		"risk_profile": str(wing_loadout.get("risk_profile", "mixed")),
		"model_pressure": Array(wing_loadout.get("model_pressure", [])).duplicate(),
		"latent_totals": Dictionary(wing_loadout.get("latent_totals", {})).duplicate(true),
		"inhabitant_signals": ["ghost pressure"]
	}
	return {
		"seed": seed_value,
		"local_role": "Scavenger",
		"local_peer_id": 2,
		"item_defs": local_items.duplicate(),
		"room_families": [branch_family_id],
		"peer_identities": {
			"2": {"public_id": local_public_id, "display_name": "Signal %s" % tag.capitalize()},
			"3": {"public_id": wing_public_id, "display_name": "Wing %s" % tag.capitalize()}
		},
		"branch_context_summary": branch_context.duplicate(true),
		"room_chain_summary": room_chain_summary,
		"key_clues": [
			"The branch kept asking for the same answer",
			"The carried object kept changing the public read"
		],
		"action_summary": [
			"A quiet handoff altered the route",
			"The archive mark kept pulling attention forward"
		],
		"communication_summary": {"total": 4 if mode == "custody" else 3, "danger": 1 if mode == "custody" else 2, "regroup": 2 if mode == "custody" else 0, "artifact": 2},
		"timeline_public_events": [
			{"event_id": 1, "tick": 8, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 2, "tick": 14, "room_slot": 1, "actor_peer_id": 2, "event_type": "artifact_dropped", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 3, "tick": 19, "room_slot": 2, "actor_peer_id": 3, "event_type": "artifact_picked", "visibility": "public", "meta": {"artifact_id": 1}},
			{"event_id": 4, "tick": 24, "room_slot": 2, "actor_peer_id": -1, "event_type": "noise_trace", "visibility": "public", "meta": {}},
			{"event_id": 5, "tick": 31, "room_slot": 2, "actor_peer_id": -1, "event_type": "bomb_exploded", "visibility": "public", "meta": {}}
		],
		"narrative_motion_facts": {
			"strong_rooms": {"returns": 2, "threshold_hesitation": 2},
			"room_summaries": {"1": {"revisits": 2}, "2": {"pressure": 2}}
		},
		"gameplay_signal_snapshot": {
			"protocol_state": protocol_state,
			"player_count": 2,
			"peer_models": {
				local_public_id: local_model,
				wing_public_id: wing_model
			},
			"build_identities": [str(local_model.get("build_identity", "")), str(wing_model.get("build_identity", ""))],
			"resource_pressure": Array(local_loadout.get("resource_signals", [])).duplicate(),
			"inhabitant_pressure": ["ghost pressure"],
			"group_model": {
				"dominant_build": str(local_model.get("build_identity", "Mixed build")),
				"group_signals": ["burden-rescue answer", "public answer appetite"] if mode == "custody" else ["public misdirection answer", "spectacle appetite"],
				"fault_lines": ["shared burden caution"] if mode == "custody" else ["ambiguous fault pressure"],
				"model_pressure": Array(local_loadout.get("model_pressure", [])).duplicate(),
				"protocol_weighting": "pair pressure" if protocol_state == "Intimate Protocol" else "isolation pressure"
			}
		},
		"delve_directive_summary": {
			"protocol_state": protocol_state,
			"doctrine_family": "ordered_signal_doctrine",
			"doctrine_label": str(public_summary.get("doctrine", "Ordered Signal Doctrine")),
			"pressure_line": str(public_summary.get("pressure_line", "")),
			"world_goal": str(public_summary.get("world_goal", "")),
			"public_summary": public_summary.duplicate(true),
			"surface_summary": {"lines": Array(Dictionary(branch_context.get("surface_summary", {})).get("lines", [])).duplicate()}
		}
	}

func _apply_ordered_signal_run(profile: Dictionary, run_record: Dictionary) -> Dictionary:
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	var frame := FRAMING_SERVICE_SCRIPT.build_run_frame(run_record, diagnostics, profile)
	var crawl_result := CRAWL_SERVICE_SCRIPT.apply_run(profile, run_record, diagnostics, frame)
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(Dictionary(profile.get("world_memory", {})), {
		"run_record": run_record,
		"diagnostics": diagnostics,
		"frame": frame,
		"crawl_packet": crawl_result.get("crawl_packet", {}),
		"profile": profile
	})
	profile["world_memory"] = world_memory
	profile["archive_state"] = ARCHIVE_SERVICE_SCRIPT.apply_run(Dictionary(profile.get("archive_state", {})), {
		"run_record": run_record,
		"diagnostics": diagnostics,
		"frame": frame,
		"crawl_packet": crawl_result.get("crawl_packet", {}),
		"world_memory": world_memory,
		"archive_state": Dictionary(profile.get("archive_state", {})),
		"profile": profile
	})
	return {
		"diagnostics": diagnostics,
		"frame": frame,
		"crawl_packet": crawl_result.get("crawl_packet", {}),
		"world_memory": world_memory,
		"archive_state": Dictionary(profile.get("archive_state", {})).duplicate(true)
	}

func _string_array_for_test(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	return result

func _dict_array_for_test(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value).duplicate(true))
	return result

func _test_shell_explainability_tightening(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var frame := FRAMING_SERVICE_SCRIPT.build_run_frame(
		{},
		{
			"doctrine_family": "witness_pressure",
			"doctrine_label": "Witness Pressure",
			"doctrine_pressure_line": "Keep the answer socially visible.",
			"doctrine_world_goal": "Keep the route legible.",
			"directive_surface_summary": {"lines": ["Rescue geometry is drawing the public answer."]},
			"run_identity_pacing_profile": "steady",
			"run_identity_dominant_minds": ["Examiner"],
			"run_identity_symbolic_motifs": ["Archive Scars"],
			"run_identity_archive_tone": "Measured",
			"run_identity_convergence_axis": "artifact custody"
		}
	)
	var doctrine_line := str(frame.get("doctrine_line", "")).strip_edges()
	if doctrine_line.find("Witness Pressure: Keep the answer socially visible.") == -1:
		failures.append("shell explainability should keep doctrine carryover sentence-led and readable")
	if doctrine_line.find("Steady pacing") == -1 or doctrine_line.find("Examiner lead") == -1:
		failures.append("shell explainability should keep pacing and dominant-mind carryover visible in doctrine phrasing")
	if doctrine_line.find("|") != -1:
		failures.append("shell explainability should stop relying on pipe-chained doctrine phrasing")
	var governance_line := str(frame.get("governance_line", "")).strip_edges()
	if governance_line.find("Keep the route legible.") == -1 or governance_line.find("Surface: Rescue geometry is drawing the public answer") == -1:
		failures.append("shell explainability should keep governance carryover compact while preserving world-goal and surface context")
	if governance_line.find("Axis: artifact custody") == -1:
		failures.append("shell explainability should keep convergence carryover readable in governance phrasing")
	if governance_line.find("|") != -1:
		failures.append("shell explainability should stop relying on pipe-chained governance phrasing")

	var focus_doctrine := ""
	var focus_governance := ""
	for line in FRAMING_SERVICE_SCRIPT.build_focus_lines(frame):
		if line.begins_with("Doctrine: "):
			focus_doctrine = line
		elif line.begins_with("Governance: "):
			focus_governance = line
	if focus_doctrine.find("|") != -1 or focus_governance.find("|") != -1:
		failures.append("focus-line helpers should reuse the compact doctrine and governance shell phrasing")

	var archive_doctrine := ""
	var archive_governance := ""
	for line in FRAMING_SERVICE_SCRIPT.build_archive_preview_lines(frame):
		if line.begins_with("Doctrine: "):
			archive_doctrine = line
		elif line.begins_with("Pressure line: "):
			archive_governance = line
	if archive_doctrine.find("Witness Pressure: Keep the answer socially visible.") == -1:
		failures.append("archive preview helpers should keep the compact doctrine phrasing on the unified shell path")
	if archive_governance.find("Surface: Rescue geometry is drawing the public answer") == -1:
		failures.append("archive preview helpers should keep the compact governance phrasing on the unified shell path")

	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["last_run"] = {
		"frame": {
			"challenge_attention": "Carry the answer without breaking cover.",
			"doctrine_line": doctrine_line,
			"build_line": "Quiet-hands kit keeps the route recoverable.",
			"inhabitant_line": "Ghost pressure is staying just behind the team.",
			"governance_line": governance_line,
			"ritual_pressure": "The promise still wants a cleaner answer."
		}
	}
	profile["active_crawl"] = {
		"title": "Echo Crawl",
		"promise_pressure": "The promise still wants a cleaner answer.",
		"public_challenge": "Carry the answer without breaking cover.",
		"doctrine_memory": [doctrine_line],
		"governance_memory": [governance_line]
	}
	var home_lines := PROFILE_SERVICE_SCRIPT.build_home_overview_lines(profile, {"connected": true}, catalog)
	var home_build_presence_lines := home_lines.filter(func(line: String) -> bool:
		return line.begins_with("Build / Presence: ") or line.begins_with("Build: ") or line.begins_with("Presence: ")
	)
	var combined_home_line := str(home_build_presence_lines[0]) if home_build_presence_lines.size() == 1 else ""
	if home_build_presence_lines.size() != 1 or not combined_home_line.begins_with("Build / Presence: "):
		failures.append("home overview should collapse build and presence carryover into one compact shell line when both are present")
	if not combined_home_line.is_empty() and combined_home_line.find("Quiet-hands kit keeps the route recoverable.; Ghost pressure is staying just behind the team.") == -1:
		failures.append("home overview should keep the compact combined build/presence wording readable")

	var public_profile := profile.duplicate(true)
	var public_last_run := Dictionary(public_profile.get("last_run", {}))
	var public_frame := Dictionary(public_last_run.get("frame", {}))
	public_frame["build_line"] = ""
	public_frame["inhabitant_line"] = ""
	public_last_run["frame"] = public_frame
	public_profile["last_run"] = public_last_run
	var public_card := PROFILE_SERVICE_SCRIPT.build_public_identity_card(public_profile, catalog)
	if str(public_card.get("build_hint", "")).find("|") != -1 or str(public_card.get("presence_hint", "")).find("|") != -1:
		failures.append("public identity hints should inherit compact doctrine/governance phrasing without pipe chains")

func _test_delve_kernel_stabilization_and_trace(failures: Array[String]) -> void:
	var world_model := {
		"doctrine_model": {
			"doctrine_counts": {"witness_pressure": 4, "burden_chain": 1},
			"stale_doctrines": ["witness_pressure"]
		},
		"cultural_model": {
			"current_focus": "ritual branch",
			"myth_gravity": 6
		},
		"session_model": {
			"protocol_state": "Intimate Protocol",
			"dominant_build": "Ritual build",
			"build_convergence": 2
		},
		"active_crawl": {
			"doctrine_memory": ["witness_pressure"],
			"public_heat": 6
		}
	}
	var planner := {
		"session": ["keep the answer socially visible"]
	}
	var meta := {"stale_doctrines": ["witness_pressure"]}
	var candidates := DOCTRINE_ENGINE_SCRIPT.build_candidates(world_model, {"protocol_state": "Intimate Protocol"}, planner, meta)
	if candidates.is_empty():
		failures.append("doctrine engine should still produce candidates during stabilization")
	else:
		var best := Dictionary(candidates[0])
		if str(best.get("id", "")) == "witness_pressure":
			failures.append("doctrine balancing hooks should resist repeated dominant witness-pressure loops when ritual gravity and build convergence point elsewhere")

	var profile := PROFILE_SERVICE_SCRIPT.normalize_profile({
		"account": {"display_name": "Trace Delver", "public_id": "trace_delver"}
	}, PRODUCT_CATALOG_SCRIPT.load_catalog())
	var session_context := {
		"player_count": 2,
		"peer_ids": [2, 3],
		"protocol_state": "Intimate Protocol",
		"public_cards": {"2": {"public_id": "trace_a", "display_name": "Trace A"}, "3": {"public_id": "trace_b", "display_name": "Trace B"}},
		"gameplay_snapshot": {
			"protocol_state": "Intimate Protocol",
			"build_identities": ["Ritual build"],
			"group_model": {
				"dominant_build": "Ritual build",
				"group_signals": ["ritual answer"],
				"fault_lines": ["shared burden caution"],
				"model_pressure": ["ritual answer"],
				"protocol_weighting": "intimate pressure"
			},
			"resource_pressure": ["fallback strain"],
			"inhabitant_pressure": ["ghost pressure"]
		}
	}
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(profile, session_context, 42424, 15)
	var snapshot := DELVE_DIRECTIVE_INSPECTOR_SCRIPT.build_snapshot(directive)
	if str(snapshot.get("doctrine_family", "")).strip_edges().is_empty():
		failures.append("directive inspector should preserve doctrine family")
	if Dictionary(snapshot.get("mind_influence", {})).is_empty():
		failures.append("directive inspector should expose mind influence weights")
	if Dictionary(snapshot.get("simulation", {})).is_empty():
		failures.append("directive inspector should expose simulation scores")
	if Dictionary(snapshot.get("run_identity", {})).is_empty() or str(snapshot.get("pacing_profile", "")).strip_edges().is_empty():
		failures.append("directive inspector should expose the run identity trace and pacing profile")
	var trace_path := DELVE_DIRECTIVE_INSPECTOR_SCRIPT.write_trace(directive)
	if trace_path.is_empty() or not FileAccess.file_exists(trace_path):
		failures.append("directive inspector should write deterministic trace files for balancing analysis")
	else:
		var trace_file := FileAccess.open(trace_path, FileAccess.READ)
		if trace_file == null:
			failures.append("directive trace file should be readable after being written")
		else:
			var trace_text := trace_file.get_as_text()
			if trace_text.find("\"doctrine_family\"") == -1 or trace_text.find("\"simulation\"") == -1 or trace_text.find("\"run_identity\"") == -1:
				failures.append("directive trace files should preserve doctrine, simulation, and run identity structure")

	var nm := NETWORK_MANAGER_SCRIPT.new()
	nm.current_delve_directive = directive.duplicate(true)
	if nm.get_current_inhabitant_pressure_bias() == 0 and nm.get_current_anomaly_contamination_bias() == 0:
		failures.append("network manager should expose ecology surface hooks for existing inhabitant pressure systems")
	var debug_lines := nm.get_current_delve_directive_debug_lines()
	if debug_lines.is_empty():
		failures.append("network manager should expose directive debug lines for profiling and debug inspection")
	nm.free()

func _test_visual_doctrine_refactor(failures: Array[String]) -> void:
	var governance = VISUAL_GOVERNANCE_SCRIPT.new()
	if not governance.validate_motion_hierarchy().is_empty():
		failures.append("visual governance should preserve a strict motion hierarchy")

	var chain := RUN_GENERATOR_SCRIPT.new().generate_layout(8123, 15)
	var builder = ROOM_BUILDER_SCRIPT.new()
	builder.build_from_chain(chain, 8123)
	var report := builder.build_visual_doctrine_report_for_test()
	var layer_roots := Array(report.get("layer_roots", []))
	for required in ["BackgroundLayer", "MidgroundLayer", "ForegroundLayer", "OverlayLayer", "SecretLayer"]:
		if not layer_roots.has(required):
			failures.append("visual doctrine should create %s" % required)
	var doctrine_failures := Array(report.get("failures", []))
	if not doctrine_failures.is_empty():
		failures.append("visual doctrine report should remain clean, got %s" % JSON.stringify(doctrine_failures))
	if not Array(report.get("doctrine_failures", [])).is_empty():
		failures.append("dedicated doctrine layers should remain visual-only and free of interactables")
	var branch_profile := governance.branch_visual_profile("watcher_steps", "fracture")
	if float(branch_profile.get("macro_irregularity", 0.0)) <= 0.0 or float(branch_profile.get("scar_density", 0.0)) <= 0.0:
		failures.append("branch visual profiles should expose irregularity and scar density for environment doctrine")
	if float(branch_profile.get("anchor_spread", 0.0)) <= 0.0:
		failures.append("branch visual profiles should expose anchor spread for symbol grammar variation")
	if governance.symbol_plate_points("threshold", 0.72).is_empty():
		failures.append("symbol plate points should remain available for entity and carving support shapes")
	var directive := DELVE_KERNEL_SCRIPT.plan_directive(
		PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog()),
		{
			"player_count": 3,
			"peer_ids": [2, 3, 4],
			"protocol_state": "Fracture Protocol",
			"gameplay_snapshot": {
				"protocol_state": "Fracture Protocol",
				"group_model": {
					"dominant_build": "Traversal build",
					"group_signals": ["route control", "public answer appetite"],
					"fault_lines": ["shared caution"],
					"model_pressure": ["route control"]
				}
			}
		},
		9917,
		15
	)
	var directive_chain := RUN_GENERATOR_SCRIPT.new().generate_layout(9917, 15, directive)
	if not directive_chain.is_empty():
		var packet := governance.room_visual_packet(Dictionary(directive_chain[0]))
		if Array(packet.get("symbol_families", [])).is_empty():
			failures.append("directive-shaped visual packets should retain symbolic motif families")
		if Dictionary(Dictionary(Dictionary(directive_chain[0]).get("branch_context", {})).get("run_identity_summary", {})).is_empty():
			failures.append("directive-shaped room chains should retain bounded run identity summaries for visual doctrine")
	var profiles := Dictionary(report.get("profiles", {}))
	if profiles.is_empty():
		failures.append("visual doctrine should retain per-room visual packets")
	else:
		for entry_raw in profiles.values():
			var entry: Dictionary = entry_raw
			var packet := Dictionary(entry.get("packet", {}))
			if not governance.validate_room_packet(packet).is_empty():
				failures.append("stored room visual packets should remain inside visual budgets")
				break
			if int(packet.get("room_slot", -1)) < 0:
				failures.append("room visual packets should retain room slot identity for deterministic motif variation")
				break
			if Array(packet.get("symbol_families", [])).is_empty():
				failures.append("room visual packets should retain symbol families for close-range doctrine carving")
				break
			if Dictionary(packet.get("stagecraft", {})).is_empty():
				failures.append("room visual packets should retain stagecraft cues for social readability")
				break
	var motif_room_a := {
		"slot": 2,
		"type": "traversal",
		"hazard": "none",
		"branch_family_id": "watcher_steps",
		"protocol_state": "Fracture Protocol",
		"branch_context": {
			"id": "watcher_steps",
			"run_identity_summary": {
				"pacing_profile": "steady",
				"pressure_grammar": ["Compression"],
				"symbolic_motifs": ["Threshold Marks"],
				"dominant_minds": ["Examiner (Primary Author)"],
				"convergence_axis": "balanced",
				"readability": 2
			},
			"pressure_profile": ["witness_high", "route_staged_commitment"]
		}
	}
	var motif_room_b: Dictionary = motif_room_a.duplicate(true)
	Dictionary(Dictionary(motif_room_b.get("branch_context", {})).get("run_identity_summary", {}))["symbolic_motifs"] = ["Archive Scars", "Split Echoes"]
	var motif_packet_a := governance.room_visual_packet(motif_room_a)
	var motif_packet_b := governance.room_visual_packet(motif_room_b)
	if JSON.stringify(Dictionary(motif_packet_a.get("stagecraft", {}))) != JSON.stringify(Dictionary(motif_packet_b.get("stagecraft", {}))):
		failures.append("motif changes should not alter visual stagecraft mechanics or room-reading flags")
	var motif_plan_a := builder.build_room_micro_plan_for_test(motif_room_a, 4001)
	var motif_plan_b := builder.build_room_micro_plan_for_test(motif_room_b, 4001)
	if JSON.stringify(Array(motif_plan_a.get("platforms", []))) != JSON.stringify(Array(motif_plan_b.get("platforms", []))):
		failures.append("motif changes should not fabricate or remove traversal platforms")
	if JSON.stringify(Array(motif_plan_a.get("markers", []))) != JSON.stringify(Array(motif_plan_b.get("markers", []))):
		failures.append("motif changes should not fabricate or remove route markers")
	builder.free()

	var fake_background := Node2D.new()
	var nested := Node2D.new()
	fake_background.add_child(nested)
	nested.add_child(Label.new())
	if governance.validate_background_layer(fake_background).is_empty():
		failures.append("background honesty validation should recurse through nested visual layers")
	var hidden_area := Area2D.new()
	nested.add_child(hidden_area)
	var background_failures := governance.validate_background_layer(fake_background)
	if background_failures.filter(func(line: String) -> bool: return line.find("interactable") != -1).is_empty():
		failures.append("background honesty validation should reject nested interactable nodes")
	fake_background.free()
	var fake_doctrine := Node2D.new()
	var doctrine_nested := Node2D.new()
	fake_doctrine.add_child(doctrine_nested)
	doctrine_nested.add_child(StaticBody2D.new())
	var doctrine_layer_failures := governance.validate_doctrine_layer(fake_doctrine)
	if doctrine_layer_failures.filter(func(line: String) -> bool: return line.find("interactable") != -1).is_empty():
		failures.append("doctrine layers should reject any nested mechanical bodies")
	fake_doctrine.free()

	var carrier_profile := governance.artifact_carrier_profile(true)
	if not bool(carrier_profile.get("label_visible", false)):
		failures.append("artifact carriers should remain explicitly labeled")
	if float(carrier_profile.get("halo_energy", 0.0)) <= 0.0 or float(carrier_profile.get("silhouette_emphasis", 1.0)) <= 1.0:
		failures.append("artifact carriers should receive silhouette and halo emphasis")
	if float(carrier_profile.get("crown_energy", 0.0)) <= 0.0 or float(carrier_profile.get("yoke_alpha", 0.0)) <= 0.0:
		failures.append("artifact carriers should expose crown/yoke emphasis for form-led readability")
	var non_carrier := governance.artifact_carrier_profile(false)
	if float(non_carrier.get("halo_energy", 1.0)) != 0.0:
		failures.append("non-carriers should not emit burden halo energy")
	var evidence_profile := governance.evidence_visual_profile(false, true)
	if float(evidence_profile.get("ring_alpha", 0.0)) <= 0.0:
		failures.append("carried artifacts should keep a visible burden ring")
	if float(evidence_profile.get("cradle_alpha", 0.0)) <= 0.0:
		failures.append("carried artifacts should expose burden cradle emphasis")
	var burden_item := governance.item_visual_profile("heavy_boots", "tool")
	if str(burden_item.get("symbol_family", "")) != "burden":
		failures.append("burden-oriented items should expose the burden symbol family")
	if Array(burden_item.get("plate_points", PackedVector2Array())).is_empty():
		failures.append("item visual profiles should expose shaped backing plates")

	var lobby_scene := FileAccess.open("res://scenes/Lobby.tscn", FileAccess.READ)
	if lobby_scene == null:
		failures.append("Lobby scene should be readable for visual shell title validation")
	else:
		var lobby_text := lobby_scene.get_as_text()
		if lobby_text.find("The Delve Protocol") == -1:
			failures.append("Lobby scene should carry the canonical shell title under the visual doctrine")
		if lobby_text.find("theme_override_styles/panel") == -1:
			failures.append("Lobby scene should keep the shell panel styling on the visual doctrine path")
		if lobby_text.find("tab_selected") == -1:
			failures.append("Lobby scene should retain doctrine styling for shell tab emphasis")
		if lobby_text.find("HeaderRule") == -1 or lobby_text.find("ShellRule") == -1:
			failures.append("Lobby scene should preserve authored shell separators for hierarchy framing")

func _test_phase1_visual_signal_compression_contract(failures: Array[String]) -> void:
	var governance = VISUAL_GOVERNANCE_SCRIPT.new()
	var room := {
		"slot": 4,
		"type": "hazard",
		"hazard": "collapse",
		"branch_family_id": "watcher_steps",
		"protocol_state": "Fracture Protocol",
		"branch_context": {
			"id": "watcher_steps",
			"run_identity_summary": {
				"pacing_profile": "volatile",
				"pressure_grammar": ["Exposure", "Fragmentation"],
				"symbolic_motifs": ["Threshold Marks", "Split Echoes"],
				"convergence_axis": "fragmentation"
			},
			"pressure_profile": ["escort_duty", "return_pressure", "relay_overload"]
		}
	}
	var packet := governance.room_visual_packet(room)
	if int(packet.get("packet_schema_version", 0)) < 2:
		failures.append("Phase 1 room visual packets should expose packet_schema_version 2")
	if Dictionary(packet.get("signal_compression_profile", {})).is_empty():
		failures.append("Phase 1 room visual packets should expose signal_compression_profile")
	if _string_array_for_test(Array(packet.get("telegraph_channels", []))).is_empty():
		failures.append("Phase 1 room visual packets should expose telegraph_channels")
	if Array(packet.get("residue_layers", [])).is_empty():
		failures.append("Phase 1 room visual packets should expose residue_layers")
	if not governance.validate_room_packet(packet).is_empty():
		failures.append("Phase 1 room visual packets should remain inside visual doctrine budgets")

func _test_execution_provenance_contract_visibility(failures: Array[String]) -> void:
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(PRODUCT_CATALOG_SCRIPT.load_catalog())
	var session_context := {
		"player_count": 3,
		"peer_ids": [2, 3, 4],
		"protocol_state": "Fracture Protocol",
		"public_cards": {
			"2": {"public_id": "delver_A", "display_name": "Aster"},
			"3": {"public_id": "delver_B", "display_name": "Bram"},
			"4": {"public_id": "delver_C", "display_name": "Cleo"}
		},
		"ready_state": {2: true, 3: true, 4: true}
	}
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, session_context, 20260319, 10)
	var public_summary := EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	var constitution_summary: Dictionary = Dictionary(constitution.get("constitution_summary", {}))
	if int(public_summary.get("provenance_contract_version", 0)) != GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION:
		failures.append("execution provenance contract should expose provenance_contract_version on public summaries")
	if _string_array_for_test(Array(public_summary.get("public_trace_classes", []))).is_empty():
		failures.append("execution provenance contract should expose public_trace_classes on public summaries")
	if _string_array_for_test(Array(public_summary.get("public_surface_tags", []))).is_empty():
		failures.append("execution provenance contract should expose public_surface_tags on public summaries")
	if public_summary.has("private_trace_classes"):
		failures.append("execution provenance contract should keep private_trace_classes out of public summaries")
	if public_summary.has("provenance_source_refs"):
		failures.append("execution provenance contract should keep provenance_source_refs out of public summaries")
	if _string_array_for_test(Array(constitution_summary.get("private_trace_classes", []))).is_empty():
		failures.append("execution provenance contract should retain private_trace_classes on constitution summaries")
	if _string_array_for_test(Array(constitution_summary.get("provenance_source_refs", []))).is_empty():
		failures.append("execution provenance contract should retain provenance_source_refs on constitution summaries")

	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 2,
		"event_id": 1,
		"event_type": "run_started",
		"room_slot": 0,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	event_log.add_event({
		"tick": 4,
		"event_id": 2,
		"event_type": "artifact_picked",
		"room_slot": 1,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var bundle := controller.build_forensic_bundle_for_test(20260319, str(constitution.get("constitution_hash", "")).strip_edges(), constitution_summary, event_log, [])
	if int(bundle.get("provenance_contract_version", 0)) != GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION:
		failures.append("execution provenance contract should carry provenance_contract_version into forensic bundles")
	if _string_array_for_test(Array(bundle.get("public_trace_classes", []))).is_empty():
		failures.append("execution provenance contract should carry public_trace_classes into forensic bundles")
	if _string_array_for_test(Array(bundle.get("private_trace_classes", []))).is_empty():
		failures.append("execution provenance contract should carry private_trace_classes into forensic bundles")
	if _string_array_for_test(Array(bundle.get("provenance_source_refs", []))).is_empty():
		failures.append("execution provenance contract should carry provenance_source_refs into forensic bundles")
	controller.free()
	event_log.free()

func _test_execution_combo_contract_determinism_and_public_projection(failures: Array[String]) -> void:
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var combo_context := {
		"protocol_state": "Exposure Protocol",
		"tool_counts": {"bomb": 1, "rope": 2},
		"carrying_artifact": true,
		"ghost_active": true
	}
	var loadout_a: Dictionary = item_service.resolve_loadout_state(["timeline_bookmark", "lantern_snuffer", "zipline_kit"], combo_context)
	var loadout_b: Dictionary = item_service.resolve_loadout_state(["zipline_kit", "timeline_bookmark", "lantern_snuffer"], combo_context)
	if int(loadout_a.get("combo_contract_version", 0)) != 1:
		failures.append("execution combo contract should expose combo_contract_version on loadout state")
	if str(loadout_a.get("combo_contract_digest", "")).strip_edges().is_empty():
		failures.append("execution combo contract should expose combo_contract_digest on loadout state")
	if str(loadout_a.get("combo_contract_digest", "")).strip_edges() != str(loadout_b.get("combo_contract_digest", "")).strip_edges():
		failures.append("execution combo contract should stay stable across reordered equivalent loadouts")
	if _string_array_for_test(Array(loadout_a.get("combo_family_ids", []))).is_empty():
		failures.append("execution combo contract should expose combo_family_ids on loadout state")
	if _dict_array_for_test(Array(loadout_a.get("combo_entries", []))).is_empty():
		failures.append("execution combo contract should expose combo_entries on loadout state")
	if _string_array_for_test(Array(loadout_a.get("combo_pressure_tags", []))).is_empty():
		failures.append("execution combo contract should expose combo_pressure_tags on loadout state")

	var affordances: Dictionary = item_service.build_runtime_affordances(["timeline_bookmark", "lantern_snuffer", "zipline_kit"], combo_context)
	if str(affordances.get("combo_contract_digest", "")).strip_edges() != str(loadout_a.get("combo_contract_digest", "")).strip_edges():
		failures.append("execution combo contract should propagate the same combo_contract_digest into runtime affordances")

	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.players = [2]
	manager.profile_cards_by_peer = {2: {"public_id": "delver_A", "display_name": "Aster"}}
	manager.items_by_id = {
		1: {"item_id": 1, "item_def_id": "timeline_bookmark", "owner_peer_id": 2, "consumed": false},
		2: {"item_id": 2, "item_def_id": "lantern_snuffer", "owner_peer_id": 2, "consumed": false},
		3: {"item_id": 3, "item_def_id": "zipline_kit", "owner_peer_id": 2, "consumed": false}
	}
	manager.player_room_by_peer = {2: 1}
	manager.ghost_state["active"] = true
	manager.ghost_state["target_peer_id"] = 2
	manager.reset_tool_inventory_for_test([2], 1, 2)
	var snapshot: Dictionary = manager.build_gameplay_signal_snapshot()
	var peer_models: Dictionary = Dictionary(snapshot.get("peer_models", {}))
	var aster: Dictionary = Dictionary(peer_models.get("delver_A", {}))
	if str(aster.get("combo_contract_digest", "")).strip_edges().is_empty():
		failures.append("execution combo contract should project combo_contract_digest into gameplay snapshots")
	if _string_array_for_test(Array(aster.get("combo_family_ids", []))).is_empty():
		failures.append("execution combo contract should project combo_family_ids into gameplay snapshots")
	if _string_array_for_test(Array(aster.get("combo_pressure_tags", []))).is_empty():
		failures.append("execution combo contract should project combo_pressure_tags into gameplay snapshots")
	if aster.has("combo_entries"):
		failures.append("execution combo contract should keep combo_entries out of public gameplay snapshots")
	if JSON.stringify(snapshot).find("\"combo_entries\"") != -1:
		failures.append("execution combo contract should keep raw combo_entries out of public gameplay snapshot payloads")
	manager.free()

func _test_execution_public_fact_extensions_and_diagnostics_contract(failures: Array[String]) -> void:
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 5,
		"event_id": 1,
		"event_type": "run_started",
		"room_slot": 0,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	var gameplay_snapshot := {
		"peer_models": {
			"delver_A": {
				"peer_id": 2,
				"combo_contract_digest": "combo_digest_alpha",
				"combo_family_ids": ["combo_family_private_archive_ritual"],
				"combo_pressure_tags": ["pressure_route_control_answer", "combo_private_archive_ritual"],
				"public_surface_tags": ["combo_private_archive_ritual", "route_memory"]
			}
		}
	}
	var constitution_summary := {
		"constitution_hash": "constitution_alpha",
		"explanation_packet_digest": "packet_alpha",
		"provenance_contract_version": GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION,
		"public_trace_classes": ["artifact", "hazard"],
		"public_surface_tags": ["movement", "burden"]
	}
	var peer_cards := {"2": {"public_id": "delver_A", "display_name": "Aster"}}
	var fact_extensions := controller.build_public_fact_extensions_for_test(event_log, gameplay_snapshot, constitution_summary, peer_cards, 2)
	if fact_extensions.filter(func(line: String) -> bool: return line.begins_with("[PROVENANCE]")).is_empty():
		failures.append("execution fact extensions should emit public provenance lines")
	if fact_extensions.filter(func(line: String) -> bool: return line.begins_with("[COMBO]")).is_empty():
		failures.append("execution fact extensions should emit public combo lines")
	if JSON.stringify(fact_extensions).find("combo_entries") != -1:
		failures.append("execution fact extensions should never leak raw combo_entries")

	var run_record := {
		"seed": 20260319,
		"local_peer_id": 2,
		"peer_identities": peer_cards.duplicate(true),
		"timeline_public_events": [{"event_id": 1, "tick": 5, "room_slot": 0, "actor_peer_id": 2, "event_type": "run_started", "visibility": "public"}],
		"communication_summary": {"total": 0, "danger": 0, "regroup": 0, "artifact": 0},
		"narrative_motion_facts": {},
		"gameplay_signal_snapshot": gameplay_snapshot.duplicate(true),
		"expedition_constitution_summary": constitution_summary.duplicate(true),
		"forensic_bundle": {"bundle_digest": "bundle_alpha", "replay_id": "replay_alpha"},
		"replay_identity": {"replay_id": "replay_alpha"},
		"outcome_summary": {"artifact_continuity_state": "burial", "artifact_continuity_text": "Buried.", "summary_text": "Sabotage success"},
		"provenance_contract_version": GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION,
		"public_trace_classes": ["artifact", "hazard"],
		"private_trace_classes": ["inspection"],
		"public_surface_tags": ["movement", "burden"],
		"provenance_source_refs": ["constitution_summary", "event_log"],
		"combo_contract_version": 1,
		"combo_contract_digest": "combo_digest_alpha",
		"combo_family_ids": ["combo_family_private_archive_ritual"],
		"combo_entries": [{
			"combo_id": "combo_private_archive_ritual",
			"family_id": "combo_family_private_archive_ritual",
			"source_item_ids": ["lantern_snuffer", "timeline_bookmark"],
			"source_hooks": ["ritual_hooks"],
			"context_tags": ["protocol_exposure_protocol"],
			"effect_tags": ["quiet_revision"],
			"public_surface_tags": ["combo_private_archive_ritual"],
			"lifecycle_candidate_id": "combo_family_private_archive_ritual",
			"visibility": "private"
		}],
		"combo_pressure_tags": ["pressure_route_control_answer", "combo_private_archive_ritual"],
		"combo_public_surface_tags": ["combo_private_archive_ritual", "route_memory"]
	}
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	if int(diagnostics.get("provenance_contract_version", 0)) != GOVERNANCE_SERVICE_SCRIPT.PROVENANCE_CONTRACT_VERSION:
		failures.append("execution diagnostics should preserve provenance_contract_version")
	if str(diagnostics.get("combo_contract_digest", "")).strip_edges() != "combo_digest_alpha":
		failures.append("execution diagnostics should preserve combo_contract_digest")
	if _string_array_for_test(Array(diagnostics.get("combo_family_ids", []))).is_empty():
		failures.append("execution diagnostics should preserve combo_family_ids")
	if _string_array_for_test(Array(diagnostics.get("public_trace_classes", []))).is_empty():
		failures.append("execution diagnostics should preserve public_trace_classes")
	controller.free()
	event_log.free()

func _test_execution_lifecycle_registry_combo_and_artifact_adoption(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["run_history"] = [{
		"seed": 4101,
		"diagnostics": {
			"combo_family_ids": ["combo_family_private_archive_ritual"]
		},
		"gameplay_signal_snapshot": {
			"peer_models": {
				"delver_A": {
					"combo_family_ids": ["combo_family_private_archive_ritual"],
					"combo_pressure_tags": ["pressure_route_control_answer"],
					"public_surface_tags": ["combo_private_archive_ritual", "route_memory"]
				}
			}
		},
		"outcome_summary": {
			"artifact_continuity_state": "burial",
			"market_regime_id": "market_balanced_exchange"
		}
	}, {
		"seed": 4102,
		"diagnostics": {
			"combo_family_ids": ["combo_family_private_archive_ritual"]
		},
		"gameplay_signal_snapshot": {
			"peer_models": {
				"delver_B": {
					"combo_family_ids": ["combo_family_private_archive_ritual"],
					"combo_pressure_tags": ["pressure_route_control_answer"],
					"public_surface_tags": ["route_memory"]
				}
			}
		},
		"outcome_summary": {
			"artifact_continuity_state": "successor_emergence",
			"market_regime_id": "market_recovery_weave"
		}
	}]
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"group_model": {"model_pressure": ["route memory"]}
		}
	}, 515151, 10)
	var lifecycle_registry: Dictionary = Dictionary(constitution.get("lifecycle_registry", {}))
	var family_kinds: Array[String] = []
	var combo_family: Dictionary = {}
	var continuity_family: Dictionary = {}
	for family_raw in _dict_array_for_test(lifecycle_registry.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		var family_kind := str(family.get("family_kind", "")).strip_edges()
		if not family_kind.is_empty() and not family_kinds.has(family_kind):
			family_kinds.append(family_kind)
		if family_kind == "combo_family" and str(family.get("family_id", "")) == "combo_family_private_archive_ritual":
			combo_family = family
		elif family_kind == "artifact_continuity" and str(family.get("family_id", "")) == "artifact_continuity_burial":
			continuity_family = family
	for required_kind in ["combo_family", "artifact_continuity"]:
		if not family_kinds.has(required_kind):
			failures.append("M4 lifecycle registry should include %s family kinds in compiler outputs" % required_kind)
	if combo_family.is_empty():
		failures.append("M4 lifecycle registry should emit combo_family entries from recent combo history")
	if continuity_family.is_empty():
		failures.append("M4 lifecycle registry should emit artifact_continuity entries from recent artifact continuity history")
	for family in [combo_family, continuity_family]:
		if family.is_empty():
			continue
		for field in ["source_id", "heat", "cooldown_band", "successor_hint", "routing_tags", "resurrection_priority"]:
			if not family.has(field):
				failures.append("M4 lifecycle families should expose %s" % field)
				break
	var normalized := EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.normalize(constitution)
	var normalized_registry: Dictionary = Dictionary(normalized.get("lifecycle_registry", {}))
	var normalized_kinds: Array[String] = []
	for family_raw in _dict_array_for_test(normalized_registry.get("families", [])):
		var family_kind := str(Dictionary(family_raw).get("family_kind", "")).strip_edges()
		if not family_kind.is_empty() and not normalized_kinds.has(family_kind):
			normalized_kinds.append(family_kind)
	for required_kind in ["combo_family", "artifact_continuity"]:
		if not normalized_kinds.has(required_kind):
			failures.append("M4 lifecycle registry should preserve %s family kinds through schema normalization" % required_kind)

func _test_execution_lifecycle_runtime_bias_and_ev4(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	profile["run_history"] = [{
		"seed": 4201,
		"diagnostics": {"combo_family_ids": ["combo_family_private_archive_ritual"]},
		"gameplay_signal_snapshot": {
			"peer_models": {
				"delver_A": {
					"combo_family_ids": ["combo_family_private_archive_ritual"],
					"combo_pressure_tags": ["pressure_route_control_answer"],
					"public_surface_tags": ["combo_private_archive_ritual", "route_memory"]
				}
			}
		},
		"outcome_summary": {"artifact_continuity_state": "burial", "market_regime_id": "market_balanced_exchange"}
	}, {
		"seed": 4202,
		"diagnostics": {"combo_family_ids": ["combo_family_private_archive_ritual"]},
		"gameplay_signal_snapshot": {
			"peer_models": {
				"delver_A": {
					"combo_family_ids": ["combo_family_private_archive_ritual"],
					"combo_pressure_tags": ["pressure_route_control_answer"],
					"public_surface_tags": ["combo_private_archive_ritual", "route_memory"]
				}
			}
		},
		"outcome_summary": {"artifact_continuity_state": "burial", "market_regime_id": "market_balanced_exchange"}
	}]
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol"
	}, 616161, 10)
	var generation_surface: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.generation_surface(constitution)
	var lifecycle_routing: Dictionary = Dictionary(generation_surface.get("lifecycle_routing", {})).duplicate(true)
	if _dict_array_for_test(lifecycle_routing.get("families", [])).is_empty():
		failures.append("M4 generation surfaces should carry lifecycle_routing families")
		return
	var variant := generation_surface.duplicate(true)
	var variant_routing: Dictionary = Dictionary(variant.get("lifecycle_routing", {})).duplicate(true)
	var variant_families := _dict_array_for_test(variant_routing.get("families", []))
	for index in range(variant_families.size()):
		var family := Dictionary(variant_families[index]).duplicate(true)
		if str(family.get("family_kind", "")).strip_edges() == "combo_family":
			family["heat"] = 7
			family["cooldown_band"] = "deep_cooling"
			variant_families[index] = family
			break
	variant_routing["families"] = variant_families
	variant["lifecycle_routing"] = variant_routing
	var generator := RUN_GENERATOR_SCRIPT.new()
	var control_branch_weights: Dictionary = generator.branch_family_weights_for_test(generation_surface)
	var variant_branch_weights: Dictionary = generator.branch_family_weights_for_test(variant)
	if JSON.stringify(control_branch_weights) == JSON.stringify(variant_branch_weights):
		failures.append("EV4 should change branch weighting when lifecycle combo heat and cooldown band change")
	var control_room_weights: Dictionary = generator.room_type_weights_for_slot_for_test(4, 10, generation_surface)
	var variant_room_weights: Dictionary = generator.room_type_weights_for_slot_for_test(4, 10, variant)
	if JSON.stringify(control_room_weights) == JSON.stringify(variant_room_weights):
		failures.append("EV4 should change room weighting when lifecycle combo heat and cooldown band change")
	var item_service := ITEM_SERVICE_SCRIPT.new()
	var room := {"branch_family_id": "relay_hollows", "protocol_state": "Exposure Protocol"}
	var control_bonus := item_service.directive_bonus_for_item_for_test("zipline_kit", generation_surface, room)
	var variant_bonus := item_service.directive_bonus_for_item_for_test("zipline_kit", variant, room)
	if control_bonus == variant_bonus:
		failures.append("EV4 should change item lifecycle bias when lifecycle combo heat and cooldown band change")

func _test_execution_lifecycle_persistence_and_governance_adoption(failures: Array[String]) -> void:
	var lifecycle_registry := {
		"families": [{
			"family_id": "combo_family_private_archive_ritual",
			"family_kind": "combo_family",
			"source_id": "combo_family_private_archive_ritual",
			"state": "active",
			"heat": 5,
			"saturation": 3,
			"strain": 2,
			"cooling_tags": ["combo_repeat"],
			"cooldown_band": "warming",
			"successor_hint": "combo_family_private_archive_ritual_successor",
			"return_window": "near_horizon",
			"routing_tags": ["route_memory", "artifact_custody"],
			"dominance_strain": 4,
			"throttle_state": "open",
			"resurrection_priority": 3
		}, {
			"family_id": "artifact_continuity_burial",
			"family_kind": "artifact_continuity",
			"source_id": "burial",
			"state": "cooling",
			"heat": 3,
			"saturation": 1,
			"strain": 1,
			"cooling_tags": ["return_window"],
			"cooldown_band": "cooling",
			"successor_hint": "artifact_recovery_weave",
			"return_window": "mid_horizon",
			"routing_tags": ["artifact_custody", "return"],
			"dominance_strain": 2,
			"throttle_state": "cooling",
			"resurrection_priority": 4
		}],
		"active_state_ids": ["combo_family_private_archive_ritual", "artifact_continuity_burial"],
		"lines": ["combo and artifact lifecycle pressure are both live"]
	}
	var run_record := {
		"seed": 717171,
		"expedition_constitution": {"lifecycle_registry": lifecycle_registry},
		"expedition_constitution_summary": {
			"lifecycle_state_ids": ["combo_family_private_archive_ritual", "artifact_continuity_burial"]
		}
	}
	var updated_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run({}, {"run_record": run_record})
	var stored_registry: Dictionary = Dictionary(updated_world_memory.get("lifecycle_registry", {}))
	var stored_combo: Dictionary = {}
	var stored_continuity: Dictionary = {}
	for family_raw in _dict_array_for_test(stored_registry.get("families", [])):
		var family: Dictionary = Dictionary(family_raw)
		if str(family.get("family_id", "")) == "combo_family_private_archive_ritual":
			stored_combo = family
		elif str(family.get("family_id", "")) == "artifact_continuity_burial":
			stored_continuity = family
	for family in [stored_combo, stored_continuity]:
		if family.is_empty():
			failures.append("M4 world memory should persist combo_family and artifact_continuity lifecycle entries")
			continue
		for field in ["source_id", "heat", "cooldown_band", "successor_hint", "routing_tags", "resurrection_priority"]:
			if not family.has(field):
				failures.append("M4 world memory lifecycle entries should keep %s" % field)
				break
	var civilization_state := CIVILIZATION_STATE_SERVICE_SCRIPT.apply_post_run_extensions(updated_world_memory, {"run_record": run_record})
	var lifecycle_states := _dict_array_for_test(civilization_state.get("lifecycle_states", []))
	var found_combo := false
	var found_continuity := false
	for state_raw in lifecycle_states:
		var lifecycle_state: Dictionary = Dictionary(state_raw)
		if str(lifecycle_state.get("state_id", "")) == "combo_family_private_archive_ritual":
			found_combo = str(lifecycle_state.get("cooldown_band", "")) == "warming"
		elif str(lifecycle_state.get("state_id", "")) == "artifact_continuity_burial":
			found_continuity = str(lifecycle_state.get("cooldown_band", "")) == "cooling"
	if not found_combo:
		failures.append("M4 civilization state should keep combo_family lifecycle cooldown bands")
	if not found_continuity:
		failures.append("M4 civilization state should keep artifact_continuity lifecycle cooldown bands")
	var governance_state := GOVERNANCE_SERVICE_SCRIPT.apply_post_run({}, run_record, {"consensus_risk": 0, "spectacle_pressure": 0}, {}, {"constitution_hash": "m4_hash"})
	if _string_array_for_test(Array(Dictionary(governance_state.get("resurrection_priority", {})).get("candidate_ids", []))).find("artifact_continuity_burial") == -1:
		failures.append("M4 governance should read artifact_continuity lifecycle cooling into resurrection_priority")

func _execution_artifact_test_run_record(seed: int, outcome_summary: Dictionary) -> Dictionary:
	return {
		"seed": seed,
		"end_reason": "extraction_objective",
		"local_role": ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER,
		"role_result_success": bool(outcome_summary.get("expedition_success", false)),
		"outcome_summary": outcome_summary.duplicate(true),
		"stats": {"notes_count": 1, "pinned_count": 0, "inspections_count": 1, "extraction_started": true, "extraction_completed": true},
		"stats_lines": [],
		"action_summary": ["The burden crossed the threshold under pressure."],
		"key_clues": ["The return line stayed legible long enough to resolve the carry."],
		"report_path": "user://reports/execution_artifact_%d.txt" % seed,
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
		"replay_identity": {"replay_id": "replay_%d" % seed},
		"forensic_bundle": {"bundle_digest": "bundle_%d" % seed, "replay_id": "replay_%d" % seed},
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

func _execution_encounter_apex_test_run_record(
	seed: int,
	outcome_summary: Dictionary,
	constitution_summary: Dictionary,
	local_aftermath: Dictionary,
	world_aftermath_refs: Array,
	active_apex_state: Dictionary = {}
) -> Dictionary:
	var run_record := _execution_artifact_test_run_record(seed, outcome_summary)
	var merged_world_tags := _string_array_for_test(Array(local_aftermath.get("world_aftermath_tags", [])))
	var merged_consequence_refs := _string_array_for_test(Array(local_aftermath.get("aftermath_consequence_refs", [])))
	for world_ref_raw in world_aftermath_refs:
		var world_ref := Dictionary(world_ref_raw)
		merged_world_tags = _string_array_for_test(merged_world_tags + _string_array_for_test(Array(world_ref.get("world_aftermath_tags", []))))
		merged_consequence_refs = _string_array_for_test(merged_consequence_refs + _string_array_for_test(Array(world_ref.get("aftermath_consequence_refs", []))))
	run_record["expedition_constitution_summary"] = constitution_summary.duplicate(true)
	run_record["local_aftermath"] = local_aftermath.duplicate(true)
	run_record["world_aftermath_refs"] = Array(world_aftermath_refs).duplicate(true)
	run_record["active_apex_state"] = active_apex_state.duplicate(true)
	run_record["encounter_apex_consequence_version"] = int(local_aftermath.get("encounter_apex_consequence_version", 0))
	run_record["encounter_resolution_state"] = str(local_aftermath.get("encounter_resolution_state", "")).strip_edges()
	run_record["apex_resolution_state"] = str(local_aftermath.get("apex_resolution_state", "")).strip_edges()
	run_record["anchored_pressures"] = _string_array_for_test(Array(local_aftermath.get("anchored_pressures", [])))
	run_record["consequence_classes"] = _string_array_for_test(Array(local_aftermath.get("consequence_classes", [])))
	run_record["local_aftermath_tags"] = _string_array_for_test(Array(local_aftermath.get("local_aftermath_tags", [])))
	run_record["world_aftermath_tags"] = merged_world_tags
	run_record["aftermath_consequence_refs"] = merged_consequence_refs
	return run_record

func _test_execution_artifact_consequence_runtime_and_public_projection(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.current_expedition_constitution = {
		"market_regime_state": {
			"regime_id": "market_recovery_weave",
			"carrier_risk_band": "volatile"
		}
	}
	var counterfeit_artifacts := {
		12: {"artifact_id": 12, "room_slot": 7, "spawn_index": 0, "signature": "F0012", "is_forged": true, "owner_peer_id": 2, "world_pos": Vector2.ZERO}
	}
	var runtime_outcome := manager.build_outcome_summary_for_test("extraction_objective", counterfeit_artifacts, {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7})
	for field in [
		"artifact_consequence_version",
		"authenticity_state",
		"custody_chain_summary",
		"burden_band",
		"valuation_band",
		"return_consequence_state",
		"market_regime_id",
		"market_carrier_risk_band",
		"public_consequence_tags",
		"consequence_event_family",
		"encounter_hook_tags",
		"social_hook_tags",
		"return_pressure_tags"
	]:
		if not runtime_outcome.has(field):
			failures.append("M5 runtime artifact consequence should emit %s" % field)
	if int(runtime_outcome.get("artifact_consequence_version", 0)) != ARTIFACT_SERVICE_SCRIPT.ARTIFACT_CONSEQUENCE_VERSION:
		failures.append("M5 runtime artifact consequence should use the artifact owner contract version")
	if str(runtime_outcome.get("consequence_event_family", "")) != "artifact_counterfeit_resolution":
		failures.append("M5 runtime artifact consequence should identify counterfeit extraction through consequence_event_family")
	if str(runtime_outcome.get("market_regime_id", "")) != "market_recovery_weave" or str(runtime_outcome.get("market_carrier_risk_band", "")) != "volatile":
		failures.append("M5 runtime artifact consequence should preserve market regime and carrier risk bands")
	var evidence_service := EVIDENCE_SERVICE_SCRIPT.new()
	var continuity_summary := {
		"state": str(runtime_outcome.get("artifact_continuity_state", "")),
		"text": str(runtime_outcome.get("artifact_continuity_text", "")),
		"unresolved_counterfeit_count": int(runtime_outcome.get("artifact_unresolved_counterfeit_count", 0)),
		"carried_unresolved_count": int(runtime_outcome.get("artifact_carried_unresolved_count", 0)),
		"buried_unresolved_count": int(runtime_outcome.get("artifact_buried_unresolved_count", 0))
	}
	var delegated := evidence_service.build_consequence_contract(
		"extraction_objective",
		counterfeit_artifacts,
		continuity_summary,
		{"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7},
		"market_recovery_weave",
		"volatile"
	)
	if JSON.stringify(runtime_outcome.get("public_consequence_tags", [])) != JSON.stringify(delegated.get("public_consequence_tags", [])):
		failures.append("M5 evidence compatibility should keep artifact consequence tags aligned with artifact_service")
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 9,
		"event_id": 1,
		"event_type": "extraction_completed",
		"room_slot": 7,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	var fact_extensions := controller.build_public_fact_extensions_for_test(event_log, {}, {}, {}, -1, runtime_outcome)
	if fact_extensions.filter(func(line: String) -> bool: return line.begins_with("[CONSEQUENCE]")).is_empty():
		failures.append("M5 public fact extensions should emit public-safe consequence lines")
	var fact_text := JSON.stringify(fact_extensions)
	for forbidden_fragment in ["social_hook_tags", "encounter_hook_tags", "artifact_unresolved_counterfeit_count", "counterfeit_pressure"]:
		if fact_text.find(forbidden_fragment) != -1:
			failures.append("M5 public fact extensions should not leak private/internal consequence fragment %s" % forbidden_fragment)
	controller.free()
	event_log.free()
	manager.free()

func _test_execution_artifact_consequence_persistence_and_ev5(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.current_expedition_constitution = {
		"market_regime_state": {
			"regime_id": "market_balanced_exchange",
			"carrier_risk_band": "contested"
		}
	}
	var authentic_artifacts := {
		12: {"artifact_id": 12, "room_slot": 7, "spawn_index": 0, "signature": "A0012", "is_forged": false, "owner_peer_id": 2, "world_pos": Vector2.ZERO}
	}
	var counterfeit_artifacts := {
		12: {"artifact_id": 12, "room_slot": 7, "spawn_index": 0, "signature": "F0012", "is_forged": true, "owner_peer_id": 2, "world_pos": Vector2.ZERO}
	}
	var control_outcome := manager.build_outcome_summary_for_test("extraction_objective", authentic_artifacts, {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7})
	var variant_outcome := manager.build_outcome_summary_for_test("extraction_objective", counterfeit_artifacts, {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7})
	if str(control_outcome.get("return_consequence_state", "")) == str(variant_outcome.get("return_consequence_state", "")):
		failures.append("EV5 should change return_consequence_state when authenticity changes between authentic and counterfeit extraction")
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 12,
		"event_id": 1,
		"event_type": "extraction_completed",
		"room_slot": 7,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	var control_fact_extensions := controller.build_public_fact_extensions_for_test(event_log, {}, {}, {}, -1, control_outcome)
	var variant_fact_extensions := controller.build_public_fact_extensions_for_test(event_log, {}, {}, {}, -1, variant_outcome)
	if JSON.stringify(control_fact_extensions) == JSON.stringify(variant_fact_extensions):
		failures.append("EV5 should materially change public-safe consequence report lines when authenticity changes")
	controller.free()
	event_log.free()
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var result := PROFILE_SERVICE_SCRIPT.apply_run_record(profile, _execution_artifact_test_run_record(818181, variant_outcome), catalog)
	var next_profile: Dictionary = Dictionary(result.get("profile", {}))
	var last_run: Dictionary = Dictionary(next_profile.get("last_run", {}))
	if str(last_run.get("return_consequence_state", "")) != str(variant_outcome.get("return_consequence_state", "")):
		failures.append("M5 profile persistence should retain return_consequence_state on last_run")
	if _string_array_for_test(Array(last_run.get("public_consequence_tags", []))).find("artifact_counterfeit_resolution") == -1:
		failures.append("M5 profile persistence should retain public_consequence_tags on last_run")
	var world_memory: Dictionary = Dictionary(next_profile.get("world_memory", {}))
	if str(Dictionary(world_memory.get("artifact_consequence_state", {})).get("consequence_event_family", "")) != "artifact_counterfeit_resolution":
		failures.append("M5 world memory should persist artifact consequence event family through the existing owner path")
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(world_memory))
	if world_lines.find("Artifact:") == -1:
		failures.append("M5 world memory lines should surface the public-safe artifact consequence review")
	var archive_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(next_profile, "archive_cases", catalog)
	if archive_entries.is_empty():
		failures.append("M5 archive outputs should still produce archive cases after artifact consequence carryover")
	else:
		var detail := str(Dictionary(archive_entries[0]).get("detail", ""))
		if detail.find("counterfeit return") == -1 and detail.find("Counterfeit artifact extracted") == -1:
			failures.append("M5 archive outputs should carry a public-safe artifact consequence reading")
	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(world_memory)
	if _string_array_for_test(Array(civilization_surface.get("artifact_consequence_tags", []))).find("artifact_counterfeit_resolution") == -1:
		failures.append("M5 civilization outputs should carry public-safe artifact consequence tags")
	var crawl_signature_source := Dictionary(next_profile.get("active_crawl", {}))
	if crawl_signature_source.is_empty():
		var crawl_history := _dict_array_for_test(next_profile.get("crawl_history", []))
		if not crawl_history.is_empty():
			crawl_signature_source = Dictionary(crawl_history[0])
	if _string_array_for_test(Array(crawl_signature_source.get("signature_tags", []))).find("artifact_counterfeit_resolution") == -1:
		failures.append("M5 crawl persistence should absorb public-safe artifact consequence tags without a second system")
	manager.free()

func _test_execution_encounter_apex_consequence_runtime_and_persistence(failures: Array[String]) -> void:
	var catalog := PRODUCT_CATALOG_SCRIPT.load_catalog()
	var profile := PROFILE_SERVICE_SCRIPT.create_default_profile(catalog)
	var constitution := DELVE_KERNEL_SCRIPT.plan_constitution(profile, {
		"player_count": 4,
		"protocol_state": "Exposure Protocol",
		"gameplay_snapshot": {
			"resource_pressure": ["rope reserves"],
			"inhabitant_pressure": ["predator rush", "ghost pressure"]
		}
	}, 626262, 10)
	var constitution_summary: Dictionary = EXPEDITION_CONSTITUTION_SCHEMA_SCRIPT.public_summary(constitution)
	if int(constitution_summary.get("encounter_apex_consequence_version", 0)) != 1:
		failures.append("M6 constitution summaries should expose encounter_apex_consequence_version")
	var encounter_manifest := Dictionary(constitution.get("encounter_manifest", {}))
	var apex_manifest := Dictionary(constitution.get("apex_manifest", {}))
	if int(encounter_manifest.get("encounter_apex_consequence_version", 0)) != 1:
		failures.append("M6 encounter_manifest should expose encounter_apex_consequence_version")
	if int(apex_manifest.get("encounter_apex_consequence_version", 0)) != 1:
		failures.append("M6 apex_manifest should expose encounter_apex_consequence_version")
	var encounters := _dict_array_for_test(encounter_manifest.get("encounters", []))
	var apexes := _dict_array_for_test(apex_manifest.get("apexes", []))
	if encounters.is_empty():
		failures.append("M6 encounter manifests should retain encounter entries")
		return
	if apexes.is_empty():
		failures.append("M6 apex manifests should retain apex entries")
		return
	var encounter_entry: Dictionary = Dictionary(encounters[0])
	var apex_entry: Dictionary = Dictionary(apexes[0])
	if int(encounter_entry.get("encounter_apex_consequence_version", 0)) != 1:
		failures.append("M6 encounter entries should retain encounter_apex_consequence_version")
	if int(apex_entry.get("encounter_apex_consequence_version", 0)) != 1:
		failures.append("M6 apex entries should retain encounter_apex_consequence_version")
	if _string_array_for_test(Array(encounter_entry.get("local_aftermath_tags", []))).is_empty():
		failures.append("M6 encounter entries should retain local_aftermath_tags")
	if _string_array_for_test(Array(encounter_entry.get("world_aftermath_tags", []))).is_empty():
		failures.append("M6 encounter entries should retain world_aftermath_tags")
	if _string_array_for_test(Array(apex_entry.get("world_aftermath_tags", []))).is_empty():
		failures.append("M6 apex entries should retain world_aftermath_tags")

	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.current_expedition_constitution = constitution.duplicate(true)
	manager.current_server_tick = 22
	var counterfeit_artifacts := {
		12: {"artifact_id": 12, "room_slot": 7, "spawn_index": 0, "signature": "F0012", "is_forged": true, "owner_peer_id": 2, "world_pos": Vector2.ZERO}
	}
	manager.artifacts_by_id = counterfeit_artifacts.duplicate(true)
	manager.extraction_room_slot = 7
	manager.player_room_by_peer = {2: 7}
	var outcome_summary := manager.build_outcome_summary_for_test("extraction_objective", counterfeit_artifacts, {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7})
	var encounter_state := {
		"encounter_id": str(encounter_entry.get("encounter_id", "encounter_test")).strip_edges(),
		"room_slot": int(encounter_entry.get("room_slot", 6)),
		"anchored_pressures": Array(encounter_entry.get("anchored_pressures", [])).duplicate(true),
		"consequence_classes": Array(encounter_entry.get("consequence_classes", [])).duplicate(true),
		"pathology_family_ids": Array(encounter_entry.get("pathology_family_ids", [])).duplicate(true),
		"local_aftermath_tags": Array(encounter_entry.get("local_aftermath_tags", [])).duplicate(true),
		"world_aftermath_tags": Array(encounter_entry.get("world_aftermath_tags", [])).duplicate(true)
	}
	var apex_state := {
		"apex_id": str(apex_entry.get("apex_id", "apex_test")).strip_edges(),
		"room_slot": int(apex_entry.get("room_slot", encounter_state.get("room_slot", 6))),
		"anchored_pressures": Array(apex_entry.get("anchored_pressures", [])).duplicate(true),
		"resolution_classes": Array(apex_entry.get("resolution_classes", [])).duplicate(true),
		"telegraph_channels": Array(apex_entry.get("telegraph_channels", [])).duplicate(true),
		"local_aftermath_tags": Array(apex_entry.get("local_aftermath_tags", [])).duplicate(true),
		"world_aftermath_tags": Array(apex_entry.get("world_aftermath_tags", [])).duplicate(true)
	}
	var local_aftermath := manager._build_local_aftermath_record(encounter_state, apex_state, "extraction_objective")
	for field in [
		"encounter_apex_consequence_version",
		"encounter_resolution_state",
		"apex_resolution_state",
		"anchored_pressures",
		"consequence_classes",
		"local_aftermath_tags",
		"world_aftermath_tags",
		"aftermath_consequence_refs"
	]:
		if not local_aftermath.has(field):
			failures.append("M6 runtime aftermath records should expose %s" % field)
	if int(local_aftermath.get("encounter_apex_consequence_version", 0)) != 1:
		failures.append("M6 runtime aftermath records should expose encounter_apex_consequence_version")
	var aftermath_consequence_refs := _string_array_for_test(Array(local_aftermath.get("aftermath_consequence_refs", [])))
	var consequence_family := str(outcome_summary.get("consequence_event_family", "")).strip_edges()
	if consequence_family.is_empty() or aftermath_consequence_refs.find(consequence_family) == -1:
		failures.append("M6 runtime aftermath records should carry the consumed C4 consequence_event_family without renaming")
	var encounter_hook_tags := _string_array_for_test(Array(outcome_summary.get("encounter_hook_tags", [])))
	if not encounter_hook_tags.is_empty() and aftermath_consequence_refs.find(encounter_hook_tags[0]) == -1:
		failures.append("M6 runtime aftermath records should carry consumed C4 encounter_hook_tags into aftermath_consequence_refs")
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var world_aftermath_refs := controller._build_world_aftermath_refs(local_aftermath, {"apex_id": str(apex_state.get("apex_id", ""))}, constitution_summary)
	if world_aftermath_refs.is_empty():
		failures.append("M6 runtime/report owners should derive world_aftermath_refs from LocalAftermath")
		controller.free()
		manager.free()
		return
	var world_aftermath_ref := Dictionary(world_aftermath_refs[0])
	for field in [
		"encounter_apex_consequence_version",
		"encounter_resolution_state",
		"apex_resolution_state",
		"anchored_pressures",
		"consequence_classes",
		"local_aftermath_tags",
		"world_aftermath_tags",
		"aftermath_consequence_refs"
	]:
		if not world_aftermath_ref.has(field):
			failures.append("M6 runtime world aftermath refs should expose %s" % field)
	var run_record := _execution_encounter_apex_test_run_record(
		626262,
		outcome_summary,
		constitution_summary,
		local_aftermath,
		world_aftermath_refs,
		{"apex_id": str(apex_state.get("apex_id", ""))}
	)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	if int(diagnostics.get("encounter_apex_consequence_version", 0)) != int(local_aftermath.get("encounter_apex_consequence_version", 0)):
		failures.append("M6 diagnostics should preserve encounter_apex_consequence_version")
	if str(diagnostics.get("encounter_resolution_state", "")).strip_edges() != str(local_aftermath.get("encounter_resolution_state", "")).strip_edges():
		failures.append("M6 diagnostics should preserve encounter_resolution_state")
	if str(diagnostics.get("apex_resolution_state", "")).strip_edges() != str(local_aftermath.get("apex_resolution_state", "")).strip_edges():
		failures.append("M6 diagnostics should preserve apex_resolution_state")
	if _string_array_for_test(Array(diagnostics.get("world_aftermath_tags", []))).is_empty():
		failures.append("M6 diagnostics should preserve world_aftermath_tags")
	if _string_array_for_test(Array(diagnostics.get("aftermath_consequence_refs", []))).find(consequence_family) == -1:
		failures.append("M6 diagnostics should preserve aftermath_consequence_refs")
	var updated_world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(WORLD_MEMORY_SERVICE_SCRIPT.default_state(), {
		"run_record": run_record,
		"diagnostics": diagnostics,
		"profile": profile
	})
	var persisted_consequence_state := Dictionary(updated_world_memory.get("encounter_apex_consequence_state", {}))
	if int(persisted_consequence_state.get("encounter_apex_consequence_version", 0)) != 1:
		failures.append("M6 world memory should persist encounter_apex_consequence_version")
	if str(persisted_consequence_state.get("encounter_resolution_state", "")).strip_edges() != str(local_aftermath.get("encounter_resolution_state", "")).strip_edges():
		failures.append("M6 world memory should persist encounter_resolution_state")
	if _string_array_for_test(Array(persisted_consequence_state.get("world_aftermath_tags", []))).is_empty():
		failures.append("M6 world memory should persist world_aftermath_tags")
	var world_lines := "\n".join(WORLD_MEMORY_SERVICE_SCRIPT.build_world_lines(updated_world_memory))
	if world_lines.find("Aftermath:") == -1:
		failures.append("M6 world memory lines should expose a compact aftermath consequence line")
	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(updated_world_memory)
	if _string_array_for_test(Array(civilization_surface.get("encounter_apex_consequence_lines", []))).is_empty():
		failures.append("M6 civilization outputs should expose encounter_apex_consequence_lines")
	if _string_array_for_test(Array(civilization_surface.get("aftermath_consequence_refs", []))).find(consequence_family) == -1:
		failures.append("M6 civilization outputs should preserve aftermath_consequence_refs")
	controller.free()
	manager.free()

func _test_execution_encounter_apex_consequence_visibility_and_ev6(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	manager.current_expedition_constitution = {
		"market_regime_state": {
			"regime_id": "market_recovery_weave",
			"carrier_risk_band": "volatile"
		}
	}
	manager.current_server_tick = 33
	var counterfeit_artifacts := {
		12: {"artifact_id": 12, "room_slot": 7, "spawn_index": 0, "signature": "F0012", "is_forged": true, "owner_peer_id": 2, "world_pos": Vector2.ZERO}
	}
	manager.artifacts_by_id = counterfeit_artifacts.duplicate(true)
	manager.extraction_room_slot = 7
	manager.player_room_by_peer = {2: 7}
	var outcome_summary := manager.build_outcome_summary_for_test("extraction_objective", counterfeit_artifacts, {"artifact_id": 12, "owner_peer_id": 2, "room_slot": 7})
	var control_encounter_state := {
		"encounter_id": "encounter_ev6_control",
		"room_slot": 6,
		"anchored_pressures": ["witness_pressure"],
		"consequence_classes": ["escort_break"],
		"pathology_family_ids": ["pathology_pressure"],
		"local_aftermath_tags": ["escort_trace"],
		"world_aftermath_tags": ["route_memory"]
	}
	var variant_encounter_state := control_encounter_state.duplicate(true)
	var variant_pressures := _string_array_for_test(Array(variant_encounter_state.get("anchored_pressures", [])))
	variant_pressures.append("route_pressure")
	variant_encounter_state["anchored_pressures"] = variant_pressures
	var apex_state := {
		"apex_id": "apex_ev6_threshold",
		"room_slot": 6,
		"anchored_pressures": ["custody_pressure"],
		"resolution_classes": ["resource_drain"],
		"telegraph_channels": ["hazard_pulse"],
		"local_aftermath_tags": ["threshold_scars"],
		"world_aftermath_tags": ["institutional_echo"]
	}
	var control_local_aftermath := manager._build_local_aftermath_record(control_encounter_state, apex_state, "extraction_objective")
	var variant_local_aftermath := manager._build_local_aftermath_record(variant_encounter_state, apex_state, "extraction_objective")
	if str(control_local_aftermath.get("immediate_route_state", "")).strip_edges() == str(variant_local_aftermath.get("immediate_route_state", "")).strip_edges():
		failures.append("EV6 should change immediate_route_state when route pressure is introduced into anchored_pressures")
	var consequence_family := str(outcome_summary.get("consequence_event_family", "")).strip_edges()
	var variant_refs := _string_array_for_test(Array(variant_local_aftermath.get("aftermath_consequence_refs", [])))
	if consequence_family.is_empty() or variant_refs.find(consequence_family) == -1:
		failures.append("M6 aftermath_consequence_refs should preserve the consumed C4 consequence_event_family")
	var encounter_hook_tags := _string_array_for_test(Array(outcome_summary.get("encounter_hook_tags", [])))
	if not encounter_hook_tags.is_empty() and variant_refs.find(encounter_hook_tags[0]) == -1:
		failures.append("M6 aftermath_consequence_refs should preserve consumed C4 encounter_hook_tags")
	if _string_array_for_test(Array(variant_local_aftermath.get("world_aftermath_tags", []))).find(str(outcome_summary.get("market_regime_id", ""))) == -1:
		failures.append("M6 world_aftermath_tags should preserve the consumed C4 market_regime_id")
	if _string_array_for_test(Array(variant_local_aftermath.get("world_aftermath_tags", []))).find("carrier_%s" % str(outcome_summary.get("market_carrier_risk_band", ""))) == -1:
		failures.append("M6 world_aftermath_tags should preserve the consumed C4 market_carrier_risk_band")
	var controller := GAME_CONTROLLER_SCRIPT.new()
	var constitution_summary := {
		"constitution_hash": "c5_exec_hash",
		"public_trace_classes": ["artifact", "hazard"],
		"public_surface_tags": ["movement", "burden"],
		"apex_class_ids": ["threshold_trial_apex"]
	}
	var control_world_aftermath_refs := controller._build_world_aftermath_refs(control_local_aftermath, {"apex_id": "apex_ev6_threshold"}, constitution_summary)
	var variant_world_aftermath_refs := controller._build_world_aftermath_refs(variant_local_aftermath, {"apex_id": "apex_ev6_threshold"}, constitution_summary)
	if JSON.stringify(control_world_aftermath_refs) == JSON.stringify(variant_world_aftermath_refs):
		failures.append("EV6 should change world_aftermath_refs when anchored encounter pressures change")
	var event_log := EVENT_LOG_SCRIPT.new()
	event_log.add_event({
		"tick": 12,
		"event_id": 1,
		"event_type": "extraction_completed",
		"room_slot": 6,
		"actor_peer_id": 2,
		"visibility": "public"
	})
	controller.end_payload = {
		"outcome_summary": outcome_summary.duplicate(true),
		"local_aftermath": control_local_aftermath.duplicate(true),
		"world_aftermath_refs": Array(control_world_aftermath_refs).duplicate(true)
	}
	var control_fact_extensions := controller.build_public_fact_extensions_for_test(event_log, {}, constitution_summary, {}, -1, outcome_summary)
	controller.end_payload = {
		"outcome_summary": outcome_summary.duplicate(true),
		"local_aftermath": variant_local_aftermath.duplicate(true),
		"world_aftermath_refs": Array(variant_world_aftermath_refs).duplicate(true)
	}
	var variant_fact_extensions := controller.build_public_fact_extensions_for_test(event_log, {}, constitution_summary, {}, -1, outcome_summary)
	if control_fact_extensions.filter(func(line: String) -> bool: return line.begins_with("[AFTERMATH]")).is_empty():
		failures.append("M6 public fact extensions should emit public-safe aftermath lines")
	if JSON.stringify(control_fact_extensions) == JSON.stringify(variant_fact_extensions):
		failures.append("EV6 should materially change public-safe aftermath report lines when route pressure changes")
	var public_fact_text := JSON.stringify(variant_fact_extensions)
	for forbidden_fragment in ["aftermath_consequence_refs", "phenomenon_manifest", "private_trace_classes", "provenance_source_refs"]:
		if public_fact_text.find(forbidden_fragment) != -1:
			failures.append("M6 public-safe aftermath lines should not leak %s" % forbidden_fragment)
	var run_record := _execution_encounter_apex_test_run_record(
		636363,
		outcome_summary,
		constitution_summary,
		variant_local_aftermath,
		variant_world_aftermath_refs,
		{"apex_id": "apex_ev6_threshold"}
	)
	var diagnostics := RUN_STORY_DIAGNOSTICS_SCRIPT.analyze(run_record)
	if JSON.stringify(diagnostics).find("phenomenon_manifest") != -1:
		failures.append("M6 diagnostics should keep phenomenon_manifest bundle-only")
	var world_memory := WORLD_MEMORY_SERVICE_SCRIPT.apply_run(WORLD_MEMORY_SERVICE_SCRIPT.default_state(), {
		"run_record": run_record,
		"diagnostics": diagnostics
	})
	if JSON.stringify(world_memory).find("phenomenon_manifest") != -1:
		failures.append("M6 world memory should keep phenomenon_manifest bundle-only")
	var civilization_surface := CIVILIZATION_STATE_SERVICE_SCRIPT.build_civilization_surface(world_memory)
	if JSON.stringify(civilization_surface).find("phenomenon_manifest") != -1:
		failures.append("M6 civilization outputs should keep phenomenon_manifest bundle-only")
	controller.free()
	event_log.free()
	manager.free()

func _test_lobby_shell_scene_contract(failures: Array[String]) -> void:
	var file := FileAccess.open("res://scenes/Lobby.tscn", FileAccess.READ)
	if file == null:
		failures.append("Lobby scene should exist for the outer-loop shell")
		return
	var source := file.get_as_text()
	for marker in ["SessionSummary", "ReconnectButton", "ShellTabs", "BannerLabel", "HomeTab", "HeroCard", "QuickStart", "Continue", "LastRun", "RecentRuns", "RunDiagnostics", "ProfileTab", "ProgressSummary", "AchievementSummary", "HistorySummary", "HistoryFocus", "HistoryCompare", "HistoryFilter", "HistorySort", "RunHistoryEntries", "RunHistoryDetail", "CollectionTab", "CollectionSection", "CollectionEntries", "CollectionDetail", "CodexTab", "CodexSection", "CodexEntries", "CodexDetail", "CosmeticsTab", "CosmeticCategory", "CosmeticEntries", "CosmeticPreview", "SettingsTab", "HintModeButton", "VoiceModeButton", "PushToTalkCheck", "MuteVoiceCheck", "ResetSettingsButton", "DataHealth", "ControlsSummary"]:
		if source.find(marker) == -1:
			failures.append("Lobby scene should include product shell node %s" % marker)
