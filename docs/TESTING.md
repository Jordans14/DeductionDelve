# Testing

## Testing Strategy
- Keep tests lightweight and runnable from PowerShell scripts.
- Combine manual runbooks with in-project deterministic checks.

## Required Tests
1. Lobby + spawn smoke test.
2. Seed determinism test.
3. Multiplayer join + sync test (2 clients).
4. Role secrecy payload test.
5. Artifact signature determinism test.
6. Artifact ownership sync logic test.
7. Public sabotage anonymity test.
8. One-carry host rule test (pickup/steal denied while carrying).
9. Forge determinism-from-counter test (no tick dependency).
10. Public event meta allowlist test.
11. Event ID monotonic determinism test.
12. Warden check score determinism test.
13. Cross-room pickup denial test.
14. Unknown event-type allowlist drop test.
15. Cross-room steal denial test.
16. RoomBuilder visual-only indicator guard test.
17. Run end tick determinism test.
18. Extraction objective end-reason determinism test.
19. Role reveal secrecy-until-end test.
20. End payload data-contract test.
21. Extraction readiness window determinism + public meta allowlist test.

## Manual Runbook: Lobby + Spawn Smoke
1. Run `scripts/run_host.ps1`.
2. Run `scripts/run_client.ps1` one or more times.
3. In host window, confirm player list updates and ready states.
4. Start run and verify all players spawn and can move.
5. Confirm host movement/state replicates correctly to clients.

## Manual Runbook: Seed Determinism
1. Start host with explicit seed.
2. Launch run twice with same seed.
3. Check generation log output for identical room sequence.

## Manual Runbook: Multiplayer Join + Sync
1. Host starts server at `127.0.0.1:2456`.
2. Two clients join.
3. Move players and verify positions converge after short delay.
4. Disconnect/reconnect one client and confirm resync.

## Manual Runbook: Milestone 3 (Roles, Evidence, Sabotage, Timeline)
1. Launch host + 2 clients.
2. Ready all players and start run.
3. Verify each window shows `Your role: ...` in HUD.
4. Verify windows do not show other players' roles anywhere in UI.
5. Move near an evidence object (green square), press `Q` to pick up.
6. Verify carrier shows `EV` above player and HUD updates `Carrying: E#`.
7. Press `E` to drop and confirm object returns to ground.
8. Have a second player approach carrier and press `R` to steal.
9. If local role is `Veil`, press `F` to forge an artifact in current room.
10. If local role is `Veil`, press `G` to trigger hazard timing nudge.
11. Verify timeline list receives events:
   - `artifact_picked` / `artifact_dropped` / `artifact_stolen`
   - `artifact_forged` (private to actor) and `artifact_spawned` (public, no forge hint)
   - `hazard_state_changed` (public anonymous event, no sabotage-specific metadata)
12. Verify one-carry rule:
   - while carrying one artifact, attempts to pickup or steal another are denied.
13. Join as/with a Warden and press `T` near an artifact:
   - verify a private timeline event `warden_check_result` appears with score.
   - verify no binary forged/real UI verdict appears.
14. Trigger hazard pulses (cycle or sabotage) and verify `!` indicator flashes in the correct room slot.
15. Attempt to pick up artifact from different room slot and verify host denies interaction.
16. Attempt steal across mismatched room slots and verify host denies interaction.
17. Press any invalid interaction (wrong role/no target/wrong room) and verify temporary status text `Denied: ...` appears for about 1.2s.
18. Trigger hazard pulse and verify `!` indicator flashes and then decays without affecting run state.
19. Continue run until host tick limit is reached and verify end screen appears on all clients.
20. While carrying an artifact, reach the last room slot and verify run ends with reason `extraction_objective`.
21. Confirm `extraction_window_started` appears before `extraction_completed`.
21. Verify end screen shows seed, role reveals, and evidence summary rows.
22. Verify role map is not visible before run end.
23. Press `N`, enter a short suspicion note, and verify it appears only in the local notebook / `YOUR NOTES` feed.

## Automated Headless Proof
- Command:
  - `.\scripts\run_headless_proof.ps1`
- Expected markers:
  - `TIMELINE_EVENT ... type=sabotage_camera_jam ...`
  - `TIMELINE_EVENT ... type=extraction_window_started ...`
  - `RUN_VERIFY ok=true checks=5 failures=0`
  - `REPORT_DIFF ok=true mismatches=0`

## Script Entry Points
- `scripts/run_host.ps1` launches game as host.
- `scripts/run_client.ps1` launches game as client.
- `scripts/run_tests.ps1` executes deterministic generation checks and prints pass/fail.
- Current test script includes Milestone 3 unit-style checks in `godot/src/tests/test_runner.gd`.

## Command Examples (Windows PowerShell)
- Host: `.\scripts\run_host.ps1 -GodotExe "D:\Godot\Godot_v4.x.exe" -Port 2456 -Seed 1337`
- Clients: `.\scripts\run_client.ps1 -GodotExe "D:\Godot\Godot_v4.x.exe" -Address 127.0.0.1 -Port 2456 -Count 2`
- Tests: `.\scripts\run_tests.ps1 -GodotExe "D:\Godot\Godot_v4.x.exe"`
- Auto-detect: scripts now search common `D:\` locations first (`D:\Godot`, `D:\Tools`, `D:\Apps`), then PATH.

## Known Gaps
- No full headless CI yet.
- No packet-level fuzz test in vertical slice.
