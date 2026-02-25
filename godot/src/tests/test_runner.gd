extends SceneTree

const NET_HELPERS_SCRIPT = preload("res://src/tests/net_manager_test_helpers.gd")
const NETWORK_MANAGER_SCRIPT = preload("res://src/net/network_manager.gd")
const RUN_GENERATOR_SCRIPT = preload("res://src/gen/run_generator.gd")
const ROLE_SERVICE_SCRIPT = preload("res://src/roles/role_service.gd")
const EVIDENCE_SERVICE_SCRIPT = preload("res://src/run/evidence_service.gd")

func _init() -> void:
	var failures: Array[String] = []
	_test_seed_determinism(failures)
	_test_room_count_bounds(failures)
	_test_role_secrecy_payload(failures)
	_test_artifact_signature_determinism(failures)
	_test_artifact_ownership_logic(failures)
	_test_public_sabotage_anonymity(failures)
	_test_one_carry_rule(failures)
	_test_forge_determinism(failures)
	_test_public_meta_allowlist(failures)
	_test_event_id_determinism(failures)
	_test_warden_check_determinism(failures)
	_test_pickup_denied_cross_room(failures)
	_test_steal_denied_cross_room(failures)
	_test_room_builder_indicator_visual_only(failures)
	_test_run_end_tick_determinism(failures)
	_test_extraction_objective_end_reason(failures)
	_test_role_reveal_secrecy_until_end(failures)
	_test_end_payload_contract(failures)

	if failures.is_empty():
		print("[PASS] Milestone tests passed.")
		quit(0)
		return

	for failure in failures:
		push_error("[FAIL] %s" % failure)
	quit(1)

func _test_seed_determinism(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var a := generator.generate_layout(424242, 8)
	var b := generator.generate_layout(424242, 8)
	if JSON.stringify(a) != JSON.stringify(b):
		failures.append("same seed produced different room chains")

func _test_room_count_bounds(failures: Array[String]) -> void:
	var generator := RUN_GENERATOR_SCRIPT.new()
	var chain := generator.generate_layout(99, 8)
	if chain.size() != 8:
		failures.append("room chain size expected 8 got %d" % chain.size())

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

func _test_artifact_signature_determinism(failures: Array[String]) -> void:
	var evidence := EVIDENCE_SERVICE_SCRIPT.new()
	var sig_a := evidence.real_signature(4242, 5, 3, 1)
	var sig_b := evidence.real_signature(4242, 5, 3, 1)
	if sig_a != sig_b:
		failures.append("real signature not deterministic")

	var chain := RUN_GENERATOR_SCRIPT.new().generate_layout(777, 8)
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

func _test_run_end_tick_determinism(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	var progression: Array[int] = [100, 450, 999, 1400, 1799, 1800, 1850]
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
	if trigger_a != 1800 or trigger_b != 1800:
		failures.append("run end should deterministically trigger at tick limit")
	manager.free()

func _test_extraction_objective_end_reason(failures: Array[String]) -> void:
	var manager = NETWORK_MANAGER_SCRIPT.new()
	manager.extraction_room_slot = 7
	manager.player_room_by_peer = {2: 7}
	manager.artifacts_by_id = {
		1: {"artifact_id": 1, "owner_peer_id": 2, "room_slot": 4},
		2: {"artifact_id": 2, "owner_peer_id": 0, "room_slot": 7}
	}
	var reason := manager.compute_end_reason_for_tick(120)
	if reason != "extraction_objective":
		failures.append("objective end should trigger when carrier reaches extraction room slot")
	if manager.compute_end_reason_for_tick(1800) != "extraction_objective":
		failures.append("objective end should take precedence over tick-limit when both true")
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
