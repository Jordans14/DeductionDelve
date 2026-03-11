extends SceneTree

const NET_HELPERS_SCRIPT = preload("res://src/tests/net_manager_test_helpers.gd")
const NETWORK_MANAGER_SCRIPT = preload("res://src/net/network_manager.gd")
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")
const ROOM_BUILDER_SCRIPT = preload("res://src/gen/room_builder.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")
const EVENT_LOG_SCRIPT = preload("res://src/run/event_log.gd")
const CRUSHER_SCRIPT = preload("res://src/entities/crusher.gd")
const ITEM_SERVICE_SCRIPT = preload("res://src/items/item_service.gd")
const PRODUCT_CATALOG_SCRIPT = preload("res://src/product/product_catalog.gd")
const PROFILE_SERVICE_SCRIPT = preload("res://src/product/profile_service.gd")

func _init() -> void:
	var failures: Array[String] = []
	_test_seed_determinism(failures)
	_test_room_count_bounds(failures)
	_test_room_archetype_scope_lock(failures)
	_test_room_pacing_and_item_replayability(failures)
	_test_room_interior_microplans_and_exposed_spawns(failures)
	_test_role_scaling_and_alignment(failures)
	_test_role_secrecy_payload(failures)
	_test_artifact_signature_determinism(failures)
	_test_artifact_ownership_logic(failures)
	_test_public_sabotage_anonymity(failures)
	_test_one_carry_rule(failures)
	_test_spelunky_tool_inventory_authority(failures)
	_test_forge_determinism(failures)
	_test_public_meta_allowlist(failures)
	_test_event_id_determinism(failures)
	_test_warden_check_determinism(failures)
	_test_pickup_denied_cross_room(failures)
	_test_steal_denied_cross_room(failures)
	_test_room_builder_indicator_visual_only(failures)
	_test_crusher_trap_determinism_and_room_mapping(failures)
	_test_core_item_sandbox_alignment_and_use(failures)
	_test_artifact_outcome_logic(failures)
	_test_ghost_pressure_determinism(failures)
	_test_run_end_tick_determinism(failures)
	_test_extraction_objective_end_reason(failures)
	_test_role_reveal_secrecy_until_end(failures)
	_test_end_payload_contract(failures)
	_test_inspection_autonote_private_and_throttled(failures)
	_test_notebook_pin_private_and_export_ordering(failures)
	_test_notebook_filters_copy_and_sections(failures)
	_test_run_report_stats_action_summary_and_hint_logic(failures)
	_test_product_catalog_and_profile_progression(failures)
	_test_product_shell_deepening_helpers(failures)
	_test_session_reliability_and_callout_helpers(failures)
	_test_product_shell_reconnect_history_and_voice_helpers(failures)
	_test_between_runs_productization_browser_and_cta_helpers(failures)
	_test_lobby_shell_scene_contract(failures)

	if failures.is_empty():
		print("[PASS] Milestone tests passed.")
		quit(0)
		return

	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)

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
	if payload.size() != 1:
		failures.append("role payload should contain exactly one key")
	if not payload.has("role"):
		failures.append("role payload missing role field")
	if payload.has("roles_by_peer"):
		failures.append("role payload leaked full role map field")
	var role_name := str(payload.get("role", ""))
	if role_name not in [ROLE_SERVICE_SCRIPT.ROLE_WARDEN, ROLE_SERVICE_SCRIPT.ROLE_VEIL, ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER]:
		failures.append("role payload contains invalid role '%s'" % role_name)

func _test_role_scaling_and_alignment(failures: Array[String]) -> void:
	var service := ROLE_SERVICE_SCRIPT.new()
	var midsize := service.role_counts_for_player_count(5)
	if int(midsize.get("warden", 0)) != 1 or int(midsize.get("veil", 0)) != 1 or int(midsize.get("scavenger", 0)) != 3:
		failures.append("role scaling should keep one Warden, one Veil, and fill the rest with Scavengers for midsize lobbies")
	var large := service.role_counts_for_player_count(10)
	if int(large.get("veil", 0)) != 2:
		failures.append("role scaling should add a second Veil only in large lobbies")
	if service.alignment_for_role(ROLE_SERVICE_SCRIPT.ROLE_VEIL) != ROLE_SERVICE_SCRIPT.ALIGNMENT_SABOTEUR:
		failures.append("Veil should align to the saboteur team")
	if service.alignment_for_role(ROLE_SERVICE_SCRIPT.ROLE_WARDEN) != ROLE_SERVICE_SCRIPT.ALIGNMENT_EXPEDITION:
		failures.append("Warden should align to the expedition team")
	if not service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_WARDEN, true, false):
		failures.append("Warden should win when the expedition succeeds")
	if not service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_VEIL, false, true):
		failures.append("Veil should win when sabotage succeeds")
	if service.role_wins(ROLE_SERVICE_SCRIPT.ROLE_SCAVENGER, false, true):
		failures.append("Scavenger should not win off sabotage success")

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
	var expected_ids: Array[String] = ["lantern_snuffer", "heavy_boots", "timeline_bookmark", "decoy_emitter", "zipline_kit"]
	if JSON.stringify(item_service.ITEM_IDS) != JSON.stringify(expected_ids):
		failures.append("item sandbox should align to the design-anchor pickup set")
	var def_failures := item_service.validate_item_defs()
	if not def_failures.is_empty():
		failures.append("item metadata definitions should remain complete for the active sandbox")
	if item_service.get_light_scale_for_items(["lantern_snuffer"]) >= 1.0:
		failures.append("lantern snuffer should deterministically reduce local light scale")
	if item_service.move_speed_multiplier_for_items(["heavy_boots"]) >= 1.0 or item_service.jump_velocity_multiplier_for_items(["heavy_boots"]) >= 1.0:
		failures.append("heavy boots should deterministically trade mobility for trace pressure")
	if item_service.footprint_scale_for_items(["heavy_boots"]) <= 1.0:
		failures.append("heavy boots should amplify footprint readability")
	if not item_service.is_active_use_item("timeline_bookmark") or not item_service.is_active_use_item("decoy_emitter") or not item_service.is_active_use_item("zipline_kit"):
		failures.append("timeline bookmark, decoy emitter, and zipline kit should be active-use items")
	if item_service.is_active_use_item("lantern_snuffer") or item_service.is_active_use_item("heavy_boots"):
		failures.append("lantern snuffer and heavy boots should remain passive sandbox items")
	if item_service.get_category("zipline_kit") != "tool":
		failures.append("zipline kit should remain a tool-category mobility item")
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
		if str(Dictionary(event.get("meta", {})).get("label", "")).find("rerouted E99 to room 4") != -1:
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
	var stalled_outcome := manager.build_outcome_summary_for_test("tick_limit", authentic)
	if not bool(stalled_outcome.get("sabotage_success", false)):
		failures.append("tick-limit failure should count as sabotage success in the clarified outcome model")
	manager.free()

func _test_ghost_pressure_determinism(failures: Array[String]) -> void:
	var manager := NETWORK_MANAGER_SCRIPT.new()
	var inactive := manager.advance_ghost_pressure_for_test(100, {1: 1, 2: 5}, {1: Vector2(100, 100), 2: Vector2(500, 100)}, [1, 2], 7)
	if bool(inactive.get("active", false)):
		failures.append("ghost pressure should stay inactive before the wake tick")
	var active := manager.advance_ghost_pressure_for_test(manager.GHOST_WAKE_TICK + 1, {1: 1, 2: 5}, {1: Vector2(100, 100), 2: Vector2(500, 100)}, [1, 2], 7, {1: true})
	if not bool(active.get("active", false)):
		failures.append("ghost pressure should activate deterministically after the wake tick")
	if int(active.get("target_peer_id", -1)) != 1:
		failures.append("ghost pressure should prioritize the straggling carrier deterministically")
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
	var hold_tick: int = 120 + int(manager.EXTRACTION_WINDOW_TICKS)
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
	if action_text.find("Inspected E4") == -1:
		failures.append("action summary should include inspected artifact lines")
	if action_text.find("Note: SUSPECT:") == -1:
		failures.append("action summary should include notebook note lines with tags")
	if action_text.find("Extraction completed") == -1:
		failures.append("action summary should include extraction completion lines")
	if action_text.find("Bomb blast left a scorch mark") == -1:
		failures.append("action summary should surface bomb blast forensic recap lines")
	if action_text.find("Evidence rerouted") == -1 or action_text.find("decoy trail") == -1:
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
	if stats_text.find("Inspections: 1 (E:1)") == -1:
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
		"stats_lines": ["Notes: 3 (Pinned: 1)", "Inspections: 2 (E:1)", "Extraction: Completed"],
		"action_summary": ["Inspected E4 (room 3)", "Extraction completed"],
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
		if str(first_item.get("detail", "")).find("Public evidence:") == -1:
			failures.append("collection detail entries should explain the item's public evidence")
	var codex_entries := PROFILE_SERVICE_SCRIPT.build_codex_entries(profile, "roles", catalog)
	if codex_entries.is_empty():
		failures.append("codex entries should expose role pages for the product shell")
	else:
		var role_detail := str(Dictionary(codex_entries[0]).get("detail", ""))
		if role_detail.find("\n") == -1:
			failures.append("codex role detail should include a readable title and description")
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
		"stats_lines": ["Notes: 1 (Pinned: 0)", "Inspections: 0 (E:0)", "Extraction: -"],
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

func _test_lobby_shell_scene_contract(failures: Array[String]) -> void:
	var file := FileAccess.open("res://scenes/Lobby.tscn", FileAccess.READ)
	if file == null:
		failures.append("Lobby scene should exist for the outer-loop shell")
		return
	var source := file.get_as_text()
	for marker in ["SessionSummary", "ReconnectButton", "ShellTabs", "BannerLabel", "HomeTab", "HeroCard", "QuickStart", "Continue", "LastRun", "RecentRuns", "RunDiagnostics", "ProfileTab", "ProgressSummary", "AchievementSummary", "HistorySummary", "HistoryFocus", "HistoryCompare", "HistoryFilter", "HistorySort", "RunHistoryEntries", "RunHistoryDetail", "CollectionTab", "CollectionSection", "CollectionEntries", "CollectionDetail", "CodexTab", "CodexSection", "CodexEntries", "CodexDetail", "CosmeticsTab", "CosmeticCategory", "CosmeticEntries", "CosmeticPreview", "SettingsTab", "HintModeButton", "VoiceModeButton", "PushToTalkCheck", "MuteVoiceCheck", "ResetSettingsButton", "DataHealth", "ControlsSummary"]:
		if source.find(marker) == -1:
			failures.append("Lobby scene should include product shell node %s" % marker)
