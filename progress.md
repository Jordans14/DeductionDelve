# Progress Log

## 2026-02-25 - Iteration 1 (Setup, Docs-First, Milestone 1+2 Start)

### What I did
- Created and initialized repository at `D:\DeductionDelve`.
- Created project structure roots: `docs/`, `godot/`, `scripts/`.
- Wrote initial design + technical doc set as source of truth before implementation.

### Why
- Establish a cohesive hybrid design before coding to avoid disconnected "mode stacking."
- Lock networking and determinism constraints early to minimize rework.

### Unique Genre Pitch (3 sentences)
Deduction Delve fuses social deduction with co-op roguelite platforming by making information a physical resource inside hazardous spaces. Every build changes both combat utility and social credibility, so item RNG reshapes deception and investigation possibilities each run. The same seeded systems that generate rooms, loot, and accidents also generate alibi windows and evidence contests.

### Core Loop Framing
- 30 seconds: survive room traversal, coordinate, and interpret suspicious actions.
- 3 minutes: clear a cluster of rooms, contest evidence, and evaluate possible sabotage accidents.
- 30 minutes: complete a seeded run where role incentives and build synergies steer trust, betrayal, and final extraction outcomes.

### Hidden Info / Production / Contest
- Hidden: role identities, intent, private inventory, certain interaction timing.
- Produced by run systems: hazard traces, witness moments, physical evidence artifacts.
- Contested by play: steal/drop/forge/context-poison evidence, challenge scene reconstructions, and use counter-forensic items.

### Failure Modes and Countermeasures
1. Failure mode: chaotic blame with no actionable inference.
   - Countermeasure: persistent timeline markers and structured notebook confidence levels.
2. Failure mode: saboteur gets free kills with no counterplay.
   - Countermeasure: consistent environmental traces and investigator verification tools.
3. Failure mode: RNG makes role outcomes arbitrary.
   - Countermeasure: seeded generation, weighted guardrails, duplicate suppression, and role-aware item weighting.

### Changed files
- `docs/GAME_VISION.md`
- `docs/CORE_LOOPS.md`
- `docs/ROLES_AND_DECEPTION.md`
- `docs/ITEMS_AND_SYNERGIES.md`
- `docs/LEVEL_GEN.md`
- `docs/NETWORKING.md`
- `docs/ARCHITECTURE.md`
- `docs/UX_UI.md`
- `docs/TESTING.md`
- `docs/ROADMAP.md`
- `progress.md`

### Run steps (current)
Implementation scripts and runnable scenes are being added next in this iteration.

### Next tasks (dependency order)
1. Initialize Godot 4 project in `godot/` and set Lobby as boot scene.
2. Implement host/join lobby flow and multiplayer spawn sync (Milestone 1).
3. Add host-seeded room generation payload and client room build (Milestone 2 start).
4. Add `scripts/run_host.ps1`, `scripts/run_client.ps1`, `scripts/run_tests.ps1`.
5. Update docs and test runbooks to match implemented behavior.

## 2026-02-25 - Iteration 1 (Implementation Pass Complete)

### What I did
- Built Godot project scaffold at `D:\DeductionDelve\godot\project.godot`.
- Implemented Milestone 1:
  - Lobby scene (`host/join/leave/ready/start`).
  - ENet multiplayer host-authoritative flow.
  - Multiplayer spawn and authoritative movement snapshot sync in `Game.tscn`.
- Implemented Milestone 2 initial:
  - Host-seeded room chain generation (`run_generator.gd`).
  - Client room rendering from host payload (`room_builder.gd`).
- Added deterministic test runner script (`src/tests/test_runner.gd`).
- Added one-command launch/testing scripts in `scripts/`.

### Why
- Deliver playable technical spine first: connect players, start seeded runs, and share common world layout.
- Keep generation deterministic and controlled by host before adding role/evidence complexity.

### Changed files
- `.gitignore`
- `godot/project.godot`
- `godot/scenes/Lobby.tscn`
- `godot/scenes/Game.tscn`
- `godot/scenes/Player.tscn`
- `godot/scenes/TestRoom.tscn`
- `godot/scenes/TestRunner.tscn`
- `godot/src/net/network_manager.gd`
- `godot/src/run/run_state.gd`
- `godot/src/run/game_controller.gd`
- `godot/src/gen/run_generator.gd`
- `godot/src/gen/room_builder.gd`
- `godot/src/entities/player.gd`
- `godot/src/ui/lobby_controller.gd`
- `godot/src/tests/test_runner.gd`
- `scripts/run_host.ps1`
- `scripts/run_client.ps1`
- `scripts/run_tests.ps1`
- Docs synced: `docs/NETWORKING.md`, `docs/LEVEL_GEN.md`, `docs/ARCHITECTURE.md`, `docs/TESTING.md`, `docs/ROADMAP.md`

### How to run
1. Install Godot 4.x locally (if not already installed).
2. Launch host:
   - `.\scripts\run_host.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Port 2456 -Seed 1337`
3. Launch clients (new terminal):
   - `.\scripts\run_client.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Address 127.0.0.1 -Port 2456 -Count 2`
4. Run deterministic tests:
   - `.\scripts\run_tests.ps1 -GodotExe "C:\Path\Godot_v4.x.exe"`

### Tests/run status
- Could not execute Godot runtime tests in this environment because no `godot`/`godot4` executable is installed in PATH.
- Determinism tests are wired and ready to run via `run_tests.ps1` once Godot path is provided.

### Notes
- All files are under `D:\DeductionDelve`.
- Host-authoritative ENet is active; WebSocket fallback remains design-documented for future milestone.

### Next tasks (Milestone 3 dependency order)
1. Hidden role assignment with secure reveal per client (`Warden`, `Veil`, `Scavenger`).
2. Evidence artifact entity lifecycle: spawn, pickup, drop, steal.
3. Add one sabotage interaction that can masquerade as environmental accident.
4. Add timeline event feed foundation for post-run reconstruction.
5. Expand test runner with role assignment + artifact sync assertions.

## 2026-02-25 - Iteration 2 (Milestone 3 Core Complete)

### What I did
- Extended existing systems (no rewrites) to implement Milestone 3 social-deduction core:
  - Hidden roles with host assignment and per-client private reveal.
  - Physical evidence artifacts with deterministic signatures, pickup/drop/steal, and Veil forge action.
  - Veil sabotage action (`hazard timing nudge`) as plausible accident.
  - Authoritative timeline event feed (public + private visibility metadata).
- Added HUD support:
  - `Your role`
  - carried evidence indicator
  - scrolling debug timeline.
- Added evidence world entity scene and carrier marker on players.
- Expanded deterministic/logic tests for role secrecy and artifact behavior.

### Why
- Milestone 3 needs secrecy and event correctness before content breadth.
- This implementation keeps deduction inseparable from run mechanics by tying evidence/sabotage directly to seeded room slots and authoritative run state.

### Files changed
- `godot/project.godot`
- `godot/src/net/network_manager.gd`
- `godot/src/run/run_state.gd`
- `godot/src/run/game_controller.gd`
- `godot/src/gen/run_generator.gd`
- `godot/src/entities/player.gd`
- `godot/src/tests/test_runner.gd`
- `godot/scenes/Game.tscn`
- `godot/scenes/Player.tscn`
- New:
  - `godot/src/roles/role_service.gd`
  - `godot/src/run/evidence_service.gd`
  - `godot/src/run/event_log.gd`
  - `godot/src/entities/evidence.gd`
  - `godot/scenes/Evidence.tscn`
- Docs updated:
  - `docs/ROLES_AND_DECEPTION.md`
  - `docs/NETWORKING.md`
  - `docs/ARCHITECTURE.md`
  - `docs/UX_UI.md`
  - `docs/LEVEL_GEN.md`
  - `docs/TESTING.md`
  - `docs/ROADMAP.md`

### How to run (Windows PowerShell)
1. Host:
   - `.\scripts\run_host.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Port 2456 -Seed 1337`
2. Clients:
   - `.\scripts\run_client.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Address 127.0.0.1 -Port 2456 -Count 2`
3. In game controls:
   - `Q` pickup nearest ground evidence
   - `E` drop carried evidence
   - `R` steal nearest carried evidence
   - `F` forge evidence (Veil only)
   - `G` sabotage hazard timing nudge (Veil only)

### Tests
- Command:
  - `.\scripts\run_tests.ps1 -GodotExe "C:\Path\Godot_v4.x.exe"`
- Added tests:
  - role secrecy payload test (no non-local role map leak)
  - artifact signature determinism test
  - artifact ownership logic test (pickup/drop/steal rules)

### Execution status in this environment
- Could not execute Godot runtime/tests here because no `godot`/`godot4` executable is available in PATH.
- Tests are wired and runnable locally with the command above.

### Notes / constraints
- Host-authoritative prototype means host process still has full role map (expected for this phase).
- Clients do not receive full role map over network payloads.
- Timeline events are factual traces, not guilt proofs.

### Next tasks
1. Add Warden consistency-check interaction for artifacts (probabilistic, non-binary).
2. Add explicit room hazard visuals/state indicator to improve sabotage readability.
3. Add end-of-run role reveal + full timeline summary view (Milestone 5 dependency).
4. Add dedicated-server-compatible authority adapter to reduce host trust risk.

## 2026-02-25 - Iteration 3 (Hardening Pass: Secrecy + Determinism + Rules)

### What changed
- Hardened secrecy for hazard/sabotage events:
  - public `hazard_state_changed` events are anonymous (`actor_peer_id = -1`).
  - public hazard event meta is sanitized to empty (no sabotage/timing hints).
  - saboteur now receives private `sabotage_used` feedback event.
- Removed forge leakage:
  - removed public `forged_hint`.
  - forge details stay private (`artifact_forged` private event).
- Determinism hardening:
  - removed wall-clock `time_ms` from authoritative event objects.
  - timeline event ordering now relies on `tick`.
- Enforced one-carry rule on host:
  - pickup denied if requester already carries.
  - steal denied if requester already carries.
  - forge denied if requester already carries (policy choice for this pass).
- Forge stability:
  - replaced `current_server_tick % 4` with deterministic per-room forge counter.
  - forge counter resets each run.

### Why
- Reduce identity-proof leaks in public telemetry.
- Make event streams replay/comparison safe by removing wall-clock fields.
- Prevent multi-carry edge cases that break evidence economy.
- Decouple forge output from tick timing for deterministic behavior.

### Files changed
- `godot/src/net/network_manager.gd`
- `godot/src/run/game_controller.gd`
- `godot/src/run/evidence_service.gd`
- `godot/src/tests/test_runner.gd`
- `docs/NETWORKING.md`
- `docs/ROLES_AND_DECEPTION.md`
- `docs/TESTING.md`
- `progress.md`

### Tests added/updated
- Public sabotage anonymity test.
- One-carry rule test verifying denied pickup/steal produces no state mutation and no public event emission.
- Forge determinism test verifying spawn index/signature are counter-based and consistent.

### How to run (Windows PowerShell)
1. Host:
   - `.\scripts\run_host.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Port 2456 -Seed 1337`
2. Clients:
   - `.\scripts\run_client.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Address 127.0.0.1 -Port 2456 -Count 2`
3. Tests:
   - `.\scripts\run_tests.ps1 -GodotExe "C:\Path\Godot_v4.x.exe"`

### Known remaining risks
- Host-authoritative trust risk remains (expected for prototype).
- Soft visual tell for forged artifacts still exists by design.

## 2026-02-25 - Iteration 4 (Event Protocol Hardening + Warden Check v0)

### What changed
- Event protocol hardening:
  - Added host-side monotonic `event_id` counter (`next_event_id`) reset each run.
  - All authoritative events now include `event_id`.
  - Client event storage/display now ordered by `(tick, event_id)` via `EventLog` sorting.
- Public metadata hardening:
  - Replaced denylist filtering with strict event-type allowlists.
  - Unknown keys/types are dropped from public event metadata.
- Test-cleanup:
  - Moved test-only simulation helpers out of `NetworkManager` into:
    - `godot/src/tests/net_manager_test_helpers.gd`
- Warden check v0:
  - Added `T` key action for Warden to check nearest artifact (ground or carried).
  - Host validates role + room-slot coherence.
  - Host computes deterministic ambiguous score (0-100) from seed/signature/id/slot/check-counter.
  - Private result event: `warden_check_result` with `{ artifact_id, score }`.
  - Public factual trace: `evidence_checked` with empty meta.

### Why
- Prevent future secrecy leaks in public event payloads.
- Improve deterministic replay/debug ordering with explicit event IDs.
- Add first investigator-specific inference tool without hard proof leakage.

### Files changed
- `godot/src/net/network_manager.gd`
- `godot/src/run/event_log.gd`
- `godot/src/run/game_controller.gd`
- `godot/src/tests/test_runner.gd`
- `godot/src/tests/net_manager_test_helpers.gd` (new)
- `docs/NETWORKING.md`
- `docs/ROLES_AND_DECEPTION.md`
- `docs/UX_UI.md`
- `docs/TESTING.md`
- `progress.md`

### Tests added/updated
- Public meta allowlist test.
- Event ID deterministic increment test.
- Warden check deterministic score test.
- Existing secrecy/one-carry/forge tests retained and updated for helper extraction.

### How to run
1. Host:
   - `.\scripts\run_host.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Port 2456 -Seed 1337`
2. Clients:
   - `.\scripts\run_client.ps1 -GodotExe "C:\Path\Godot_v4.x.exe" -Address 127.0.0.1 -Port 2456 -Count 2`
3. Tests:
   - `.\scripts\run_tests.ps1 -GodotExe "C:\Path\Godot_v4.x.exe"`

### Known remaining risks
- Host-authoritative model still permits malicious host behavior (out-of-scope this iteration).
- Warden score is deterministic and ambiguous by design, but balancing signal usefulness will need playtest tuning.

## 2026-02-25 - Iteration 5 (Interaction Contract Cleanup + Room-Slot Validation + Hazard Readability + D: Godot Detection)

### What changed
- Interaction contract cleanup:
  - Production `NetworkManager` kept focused on runtime logic.
  - Test suite now uses pure helper surface in `src/tests/net_manager_test_helpers.gd`.
  - Tests no longer call underscore internals on `NetworkManager`.
- Room-slot validation hardening (host authoritative):
  - Pickup now requires requester slot == artifact slot.
  - Steal now requires requester slot == victim slot == artifact slot.
  - Drop now updates artifact `room_slot` to requester current slot.
  - Existing Warden same-slot validation kept intact.
- Visible gameplay upgrade:
  - Added per-room hazard indicator (`!`) that flashes on hazard pulse for that slot.
  - Indicator is network-driven visual feedback only; no simulation impact.
- Script friction reduction:
  - `run_host.ps1`, `run_client.ps1`, `run_tests.ps1` now auto-detect Godot in common `D:\` install paths before PATH fallback.
  - Scripts print `Using Godot: <path>` for transparency.

### Why
- Prevent drift between test scaffolding and production behavior.
- Close fairness gaps in evidence interactions across room boundaries.
- Improve player readability of hazard events without changing deterministic authority.
- Reduce launch friction for expected D-drive Godot installs.

### Files changed
- `godot/src/net/network_manager.gd`
- `godot/src/gen/room_builder.gd`
- `godot/src/run/game_controller.gd`
- `godot/src/tests/net_manager_test_helpers.gd`
- `godot/src/tests/test_runner.gd`
- `scripts/run_host.ps1`
- `scripts/run_client.ps1`
- `scripts/run_tests.ps1`
- `docs/NETWORKING.md`
- `docs/LEVEL_GEN.md`
- `docs/UX_UI.md`
- `docs/TESTING.md`
- `progress.md`

### Controls / expectations
- `Q` pickup now only succeeds when requester is in artifact room slot.
- `R` steal now only succeeds when requester, victim, and artifact share room slot.
- `E` drop rebinds artifact slot to current room.
- Hazard pulses now flash a visible `!` marker in the affected room panel.

### How to run
1. Preferred explicit test command:
   - `.\scripts\run_tests.ps1 -GodotExe "D:\<wherever>\Godot_v4.x.exe"`
2. After this iteration, you can omit `-GodotExe` if script auto-detect finds your install:
   - `.\scripts\run_host.ps1`
   - `.\scripts\run_client.ps1 -Count 2`
   - `.\scripts\run_tests.ps1`

### Known remaining risks
- Host-authoritative trust model unchanged.
- Hazard indicator duration is a client-visual timer and may vary slightly with frame cadence, but authoritative pulse events remain deterministic.

## 2026-02-25 - Iteration 6 (Interaction Feedback + Evidence HUD + Hazard Indicator Reliability + Determinism Guards)

### What changed
- Hazard indicator reliability:
  - `RoomBuilder` now explicitly enables processing in `_ready()` and rebuild path.
  - Indicator dictionaries are cleared/rebuilt deterministically during `build_from_chain`.
- Denial feedback pipeline (client-local UX only):
  - Added `NetworkManager.action_denied(reason)` signal.
  - Host emits private denial payloads on validation failures (`wrong_room`, `already_carrying`, `not_owner`, `out_of_range`, `not_role`, `cooldown`, `no_target`).
  - Clients display denial text in Status HUD for ~1.2s; denials are not added to timeline.
- Evidence interaction prompts:
  - Added prompt line near carry HUD for contextual controls:
    - `Q: Pick up E#`, `E: Drop`, `R: Steal E#`
    - `F: Forge`, `G: Sabotage` (Veil)
    - `T: Check` (Warden)
  - Prompts are local computation from known run/player state and do not alter simulation.
- Determinism guard tests:
  - Added cross-room steal denial test.
  - Added RoomBuilder visual-only guard test (no `RunState`/`NetworkManager` coupling in indicator logic).
  - Existing anonymity/deny/no-mutation tests retained.

### Why
- Remove silent-failure UX for core interactions without changing authority model.
- Improve clarity of available actions in the moment.
- Keep hazard indicator behavior reliable while preserving strict simulation determinism.

### Files changed
- `godot/src/net/network_manager.gd`
- `godot/src/run/game_controller.gd`
- `godot/src/gen/room_builder.gd`
- `godot/scenes/Game.tscn`
- `godot/src/tests/test_runner.gd`
- `docs/UX_UI.md`
- `docs/TESTING.md`
- `docs/NETWORKING.md`
- `progress.md`

### Run / test commands
1. Host:
   - `.\scripts\run_host.ps1 -GodotExe "D:\<actual>\Godot_v4.x.exe"`
2. Clients:
   - `.\scripts\run_client.ps1 -GodotExe "D:\<actual>\Godot_v4.x.exe" -Count 2`
3. Tests:
   - `.\scripts\run_tests.ps1 -GodotExe "D:\<actual>\Godot_v4.x.exe"`
   - or auto-detect path:
   - `.\scripts\run_tests.ps1`

### Known remaining risks
- Denial feedback is UX-only and depends on receipt of private host feedback; it intentionally does not become authoritative timeline evidence.

## 2026-02-25 - Iteration 7 (Run Lifecycle v0: Win/Lose, End Screen, Role Reveal, Summary)

### What changed
- Added deterministic run end condition (host authoritative):
  - run ends at fixed `RUN_TICK_LIMIT` (tick-based, no wall-clock use).
  - host triggers one run-end broadcast and emits public `run_ended` timeline event.
- Added end-of-run payload + reveal protocol:
  - run-start payload remains seed/layout/peer IDs only.
  - role map reveal is included only in end payload.
  - end payload includes seed, reason, end tick, role reveal map, and deterministic summary metrics.
- Added end screen overlay in `Game.tscn`:
  - `RUN COMPLETE`, seed, reason, role reveal list, summary rows, timeline recap.
  - `TAB` toggles compact vs expanded timeline lines.
- Added host-computed deterministic summary metric:
  - per-player counts of picked/dropped/stolen events plus carrying-at-end count.
- Kept secrecy and determinism constraints intact:
  - no role map sent pre-end.
  - event ordering still `(tick, event_id)`.

### Files changed
- `godot/src/net/network_manager.gd`
- `godot/src/run/game_controller.gd`
- `godot/scenes/Game.tscn`
- `godot/src/tests/test_runner.gd`
- `docs/CORE_LOOPS.md`
- `docs/NETWORKING.md`
- `docs/UX_UI.md`
- `docs/TESTING.md`
- `progress.md`

### Tests added/updated
- Run end tick determinism test.
- Role reveal secrecy-until-end test.
- End payload data-contract test.
- Existing lifecycle/secrecy tests retained.

### Run / test commands
1. Host:
   - `.\scripts\run_host.ps1 -GodotExe "D:\<actual>\Godot_v4.x.exe"`
2. Clients:
   - `.\scripts\run_client.ps1 -GodotExe "D:\<actual>\Godot_v4.x.exe" -Count 2`
3. Tests:
   - `.\scripts\run_tests.ps1 -GodotExe "D:\<actual>\Godot_v4.x.exe"`
   - or auto-detect:
   - `.\scripts\run_tests.ps1`

### Known remaining risks
- End condition is intentionally minimal (tick-limit) and should be replaced/augmented by gameplay objective condition in later milestone.

## 2026-02-25 - Iteration 8 (Repo Hygiene + Objective End v0)

### What changed
- Repo hygiene:
  - Confirmed valid git repository at `D:\DeductionDelve` with `.git/` present.
  - Added/updated `.gitignore` for Godot cache paths + Windows/VSCode noise while keeping source/docs/scripts tracked.
  - Created baseline tracking commit:
    - `Baseline import (tracked project on D drive)`.
- Test runner cleanup:
  - Explicitly freed off-tree `NetworkManager` nodes in headless tests, removing shutdown leak warnings in current run.
- Gameplay milestone (Option 1 implemented):
  - Added deterministic objective-based run end on host:
    - `extraction_objective` triggers when any artifact carrier reaches extraction slot (last room slot).
    - tick-limit remains deterministic fallback (`tick_limit`).
  - End reason remains host authoritative and is included in existing end payload.
  - Role secrecy boundary unchanged (role map still end-only payload).

### Why
- Git tracking was required for safe iterative diffs and review.
- Objective-based end makes runs feel complete through player action instead of waiting for timer.
- Kept deterministic and secrecy constraints unchanged.

### Files changed
- `.gitignore`
- `godot/src/net/network_manager.gd`
- `godot/src/tests/test_runner.gd`
- `docs/CORE_LOOPS.md`
- `docs/NETWORKING.md`
- `docs/UX_UI.md`
- `docs/TESTING.md`
- `progress.md`

### Tests added/updated
- Added extraction objective determinism test:
  - `compute_end_reason_for_tick(...)` returns `extraction_objective` when carrier is in extraction slot.
  - verifies objective reason precedence over tick-limit when both are true.
- Existing role secrecy/end payload tests retained.

### Run / test commands
1. Baseline test:
   - `.\scripts\run_tests.ps1`
2. Host + clients:
   - `.\scripts\run_host.ps1`
   - `.\scripts\run_client.ps1 -Count 2`
3. Objective playtest:
   - pick up any artifact, move carrier to final room slot, verify run ends with reason `extraction_objective`.

### Known remaining risks
- Objective is intentionally simple (single extraction-slot check) and may need balancing constraints in later milestones (for example, minimum progress gating).

## 2026-03-02 - Iteration 32 (Scope Lock + Extraction Readiness Window)

### Why
- Extraction needed a deterministic public timing anchor without expanding UI or leaking blame.
- The working tree also needed to be cut back to just the extraction-window slice and proof hardening.

### What changed
- `godot/src/net/network_manager.gd`
  - added host-side `extraction_window_started` / `extraction_window_aborted` public events before `extraction_completed`
  - kept public meta restricted to `duration_ticks` for start and empty meta for abort
- `godot/src/run/game_controller.gd`
  - kept the core HUD status line visible and appends `Extraction stabilizing...` during the hold
  - routes extraction-window events into the existing grouped timeline/export formatting
  - removed proof-only actor teleports from automation
- `godot/src/tests/net_manager_test_helpers.gd`
  - extended public allowlist coverage for extraction window events
- `godot/src/tests/test_runner.gd`
  - added deterministic extraction-window gating/meta/formatting coverage
  - kept proof-script marker assertions for both `sabotage_camera_jam` and `extraction_window_started`
- `scripts/run_headless_proof.ps1`
  - now uses a fixed fallback seed list and stops at the first seed that emits both required public facts

### Validation
- `.\scripts\run_tests.ps1` -> `[PASS]`
- `.\scripts\run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Key proof lines:
  - `TIMELINE_EVENT tick=5 event_id=7 type=extraction_window_started room_slot=7 actor=-1 visibility=public`
  - `TIMELINE_EVENT tick=5 event_id=11 type=sabotage_camera_jam room_slot=0 actor=-1 visibility=public`
  - `RUN_VERIFY ok=true checks=5 failures=0`
  - `REPORT_DIFF ok=true mismatches=0`

### Risks / Next
- Risks:
  - proof now depends on a committed deterministic fallback seed list rather than one hardcoded seed
  - extraction timing remains public-only; avoid attaching actor metadata or private hints
- Next:
  - if extraction needs more pressure later, keep adding neutral public anchors rather than new UI systems

## 2026-03-02 - Iteration 33 (Extraction Window Lifecycle Fix + Suspicion Notebook)

### Why
- The extraction readiness window could restart too aggressively after an abort, which made the public timing anchor noisier than intended.
- The next Milestone 5 step was a strictly local suspicion notebook that affects reconstruction readability without touching simulation or privacy boundaries.

### What changed
- `godot/src/net/network_manager.gd`
  - disallows same-tick extraction window restart after an abort
  - keeps `extraction_window_started` single-emission per active lifecycle until abort/completion/reset
- `godot/src/tests/test_runner.gd`
  - added deterministic lifecycle coverage for single start, single abort, and next-tick restart
  - added local notebook private/export scope coverage
- `godot/scenes/Game.tscn`
  - added a minimal hidden notebook panel with text input and recent-note list
- `godot/src/run/game_controller.gd`
  - adds local-only `notebook_note_added` private events through the existing private feed/export path
  - adds `N` toggle and `Enter` submit for the notebook panel
- `docs/UX_UI.md`
  - documents the local notebook toggle
- `docs/TESTING.md`
  - adds one manual notebook privacy check

### Validation
- `.\scripts\run_tests.ps1` -> `[PASS]`
- `.\scripts\run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Key proof lines:
  - `TIMELINE_EVENT tick=0 event_id=4 type=sabotage_camera_jam room_slot=0 actor=-1 visibility=public`
  - `TIMELINE_EVENT tick=975 event_id=61 type=extraction_window_started room_slot=7 actor=-1 visibility=public`
  - `TIMELINE_EVENT tick=985 event_id=62 type=extraction_window_aborted room_slot=7 actor=-1 visibility=public`
  - `TIMELINE_EVENT tick=990 event_id=64 type=extraction_window_started room_slot=7 actor=-1 visibility=public`
  - `RUN_VERIFY ok=true checks=5 failures=0`
  - `REPORT_DIFF ok=true mismatches=0`

### Risks / Next
- Risks:
  - notebook notes are intentionally local-only and never enter public report diff or replication
  - extraction window restart remains blocked for the abort tick only; further tightening should happen only if playtests show a real need
- Next:
  - if the notebook needs more utility later, keep it in the local/private recap layer and out of simulation
## 2026-03-07 - Iteration 34 (Milestone 1: Platforming & Traversal Sync Hardening)

### Why
- Host-authoritative mode required a more robust reconciliation layer that doesn't just "fully trust local" (which allows cheating/bypass) but also doesn't "rubberband" (which ruins feel).
- Camera boundaries were needed to prevent the player from seeing the ungenerated void at the edges of the monolithic cavern chunks.

### What changed
- `godot/src/run/game_controller.gd`
  - Replaced "trust local" bypass with a "snap if far (>200), lerp if near (>15)" reconciliation algorithm.
  - Added a 3000-unit forgiveness range specifically for CLI auto-teleports to prevent test snapback.
  - Fixed a race condition in CLI sabotage automation by adding a 1s delay, ensuring the server has synchronized the player's new room slot after a teleport before processing the sabotage request.
- `godot/src/entities/player.gd`
  - Added `Camera2D` limit constraints to the local player camera, locking it to the 8x4 cavern grid (8192x3072 pixels).
- `scripts/run_headless_proof.ps1`
  - Modified to print the tail of the host log on failure for faster debugging.
  - Cleaned up the seed candidate list for focused debugging.

### Validation
- `.\scripts\run_headless_proof.ps1 -Seed 1337` -> `=== HEADLESS PROOF PASS ===`
- `REPORT_DIFF ok=true mismatches=0` -> Determinism intact.
- Traversal feel manually verified (conceptually) by the proof script successfully extracting from a distance.

### Next Tasks (Milestone 2)
1. Implement throwable `Bomb` entity with predictive arc and host-authoritative explosion.
2. Implement `Rope` entity that modifies environment traversal on the fly.
3. Ensure both physics-based tools are fully deterministic and replicated correctly.

## 2026-03-08 - Resumption Audit

### Working baseline found
- Branch: `wip/clean-gate-20260303-020544`
- Worktree is dirty in core gameplay files (`player.gd`, `bomb.gd`, `rope.gd`, `network_manager.gd`, `game_controller.gd`, `lobby_controller.gd`, `run_headless_proof.ps1`, `godot/debug_start.gd`).
- Current deterministic gates are green on this baseline:
  - `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
  - `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`

### Confirmed complete milestones
- **Milestone 1 — Platforming & Traversal Sync Hardening**
  - Host snapshots, client-side prediction/reconciliation, and camera bounds are present in live code.
  - Current deterministic proof still passes with the traversal stack active.

### Partially complete milestones
- **Milestone 2 — Rigid Body Physics Tools**
  - Bomb and rope entities exist, are spawnable through host RPC paths, and are locally predicted.
  - Current gaps: no meaningful test coverage, no authoritative bomb/rope inventory truth, and no milestone-level hardening proving deterministic/runtime correctness.
- **Milestone 3 — Hazard & Room Grammar Expansion**
  - Procedural cave generation, spikes, hazard indicators, and hazard pulse readability exist.
  - Missing from the design anchor slice: crush-block traps and stronger hazard-room archetype guarantees.
- **Milestone 4 — Core Item Sandbox**
  - Item spawning, pickup, and a broad item definition table exist.
  - Current mismatch: the live table exceeds the design-anchor slice and many items are only data definitions, not integrated sandbox tools.
- **Milestone 5 — Environmental Forensics**
  - Noise traces, sabotage disturbance facts, and artifact authenticity/forgery signals exist.
  - Missing: explicit blast-mark traces, visible footprint persistence, and artifact corruption traces that match the design anchor.
- **Milestone 6 — Suspicion UX Notebook**
  - Notebook overlay, private notes, pinning, filters, copy/export, and private report sections exist.
  - This milestone is functionally ahead of the roadmap order, but depends on incomplete upstream systems.
- **Milestone 7 — Deep Sabotage & Scavenger Tooling**
  - Veil sabotage and camera jam inference hooks exist.
  - Scavenger-specific tooling remains shallow.
- **Milestone 8 — Ghost Pressure**
  - A visual/local ghost chaser exists in the run controller.
  - It is not yet a robust authoritative pressure system matching the design anchor.
- **Milestone 9 — Audio/Visual Readability**
  - Lighting, hazard indicators, ambient cave rendering, and notebook/report polish exist.
  - Missing: the full readable-chaos pass for bomb traces, footsteps, and stronger diegetic clue readability.

### Technical debt / risks found
- Bomb and rope flows currently rely on local player inventory counts without a corresponding host-owned inventory source of truth.
- The item catalog is broader than the design-anchor slice and should be treated as provisional until the core 6-8 tools are hardened.
- Tests are strongest around evidence, secrecy, notebook/report privacy, and extraction; they do not yet prove bombs, ropes, hazards, ghost pressure, or the larger item sandbox.
- The ghost currently appears to be a local presentation/mechanical stub rather than a fully verified slice system.
- The repo contains valid later-slice UX/report work, but those systems should be treated as provisional until Milestone 2-5 prerequisites are properly hardened.

### Exact next milestone
- **Resume at Milestone 2 — Rigid Body Physics Tools Integration**
- Why:
  - It is the earliest clearly incomplete milestone in the design-anchor critical path.
  - Bombs and ropes already exist in code, so the highest-leverage next step is to harden them inside the current architecture instead of starting a parallel system.
  - Later systems (forensics, ghost pressure, notebook polish) depend on bombs/ropes being trustworthy, deterministic, and host-authoritative.

## 2026-03-08 - Iteration 35 (Milestone 2: Bomb/Rope Authority Hardening)

### What I changed
- `godot/src/net/network_manager.gd`
  - added host-owned bomb/rope charge tracking per peer
  - initializes deterministic starting counts at run start for every peer
  - validates bomb/rope throw requests against host truth and denies empty-inventory requests
- `godot/src/entities/player.gd`
  - accepts authoritative bomb/rope count sync from snapshots
  - exposes small getters/setters for tool-count sync
- `godot/src/run/game_controller.gd`
  - syncs authoritative tool counts onto player actors on the host
  - includes authoritative bomb/rope counts in the replicated snapshot payload
  - surfaces local bomb/rope counts in the HUD status line
  - keeps help text aligned with existing `C`/`V` tool controls
- `godot/src/tests/test_runner.gd`
  - added deterministic coverage for host-owned bomb/rope inventory consumption limits
  - updated stale tick-limit test to use the current authoritative `RUN_TICK_LIMIT`

### What I verified
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers stayed intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Remaining risks
- Bomb and rope event presentation is still thin compared with the design anchor's full readable-chaos goals; this pass hardened authority and sync first.
- Bomb blast marks / rope-forensics interpretations are still part of the later forensic/readability milestones, not this hardening pass.

### Next milestone
- **Milestone 3 — Hazard & Room Grammar Expansion**
- Why:
  - Bombs and ropes now have a clearer host-owned inventory contract.
  - The next missing design-anchor layer is hazard depth: crush-block traps, stronger room archetype guarantees, and hazard affordances that meaningfully interact with sabotage and traversal.

## 2026-03-08 - Iteration 36 (Milestone 3: Crush-Block Hazard Slice)

### What I changed
- `godot/src/entities/crusher.gd`
  - added a deterministic crush-block trap whose motion is derived from the authoritative run tick instead of wall-clock timers
  - exposes a small pure test helper for cycle-position verification
- `godot/src/gen/room_builder.gd`
  - maps existing `collapse` hazards to vertical crush-block traps
  - maps existing `push` hazards to horizontal crush-block traps
  - keeps traps on the existing `hazards` group so they plug into the current player damage path
- `godot/src/tests/test_runner.gd`
  - added deterministic crusher-cycle coverage
  - added room-builder source coverage proving `collapse` hazards now instantiate crusher traps

### Design note
- `ROADMAP.md` mentions a broader hazard set (`dart dispensers`, `collapsing bridges`), but `docs/DESIGN_ANCHOR.md` is the governing vertical-slice authority and only requires:
  - `Spikes`
  - `Crush-block traps`
- This pass closes that design-anchor hazard gap without expanding beyond the slice.

### What I verified
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Existing proof contracts remained unchanged:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Remaining risks
- Hazard room composition is still relatively simple; the slice now has the required trap types, but room-specific encounter variety can still deepen later.
- Crusher traps currently rely on the existing local hazard overlap/damage path, so future hazard work should continue to preserve host correction and deterministic tick-based motion.

### Next milestone
- **Milestone 4 — Core Item Sandbox**
- Why:
  - The live item system exists, but it currently exceeds the design-anchor scope and many definitions are only partial data.
  - The next highest-value step is to align the active item sandbox to the six core slice tools:
    - Bomb
    - Rope
    - Lantern Snuffer
    - Heavy Boots
    - Timeline Bookmark
    - Decoy Emitter

## 2026-03-08 - Iteration 37 (Milestones 4-10: Vertical Slice Stabilization)

### What I changed
- `godot/src/run/game_controller.gd`
  - action summary now surfaces the existing ambiguous decoy/bomb forensics moments more clearly:
    - anonymous `artifact_dropped` -> `Evidence rerouted`
    - `noise_trace` -> `A decoy trail echoed`
    - existing `bomb_exploded` scorch recap retained
- `godot/src/tests/test_runner.gd`
  - locked passive core-tool affordances:
    - lantern snuffer reduces light scale
    - heavy boots trade mobility for larger footprints
  - locked recap readability for the existing slice events:
    - bomb blast forensic summary line
    - decoy reroute summary line
    - decoy noise-trace summary line
- temp recovery/debug artifacts removed:
  - `tmp_check_seed1337.gd`
  - `tmp_check_seed1337_now.gd`
  - `tmp_repro_item_detached.gd`
  - `tmp_repro_item_test.gd`
  - `tmp_repro_item_test_nowait.gd`
  - `godot/debug_start.gd`

### What I verified
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Slice completion status
- **Milestone 4 - Core Item Sandbox:** complete in slice form
  - active sandbox constrained to Bomb, Rope, Lantern Snuffer, Heavy Boots, Timeline Bookmark, Decoy Emitter
- **Milestone 5 - Environmental Forensics:** complete in slice form
  - footprints, bomb scorch marks, forged-artifact corruption traces, and ambiguous public route/noise facts are present
- **Milestone 6 - Suspicion UX Notebook:** complete in slice form
  - private notes, pinning, filters, copy/export, quick tags, and local inspection autonotes are integrated
- **Milestone 7 - Deep Sabotage & Scavenger Tooling:** complete in slice form
  - camera jam, bookmark anchoring, and Scavenger reroute confusion are wired without leaking authorship
- **Milestone 8 - Ghost Pressure:** complete in slice form
  - authoritative ghost wake/chase/hazard pressure is active and tested
- **Milestone 9 - Audio/Visual Readability:** complete in slice form
  - readable hazards, footprints, bomb scorch marks, dimmed lanterns, forged-artifact corruption, help overlay, and next-step hints are present
- **Milestone 10 - Beta Vertical Slice Stabilization:** complete for current scope
  - deterministic tests/proof pass and the slice-critical systems are coherently wired together

### Remaining non-blocking polish
- blast marks and footprints are intentionally simple visual marks rather than a richer decal system
- the ghost has slice-appropriate pressure behavior, but could later use more bespoke visuals/audio without changing authority or logic

## 2026-03-09 - Iteration 38 (Logic Audit + Zipline Cohesion Pass)

### Logic Audit
- **Currently coherent**
  - expedition-vs-sabotage remains the clean primary team structure
  - extraction pressure, replay logging, notebook privacy, and public clue ambiguity are aligned
  - the sandbox now cleanly separates passive relic pressure (`Lantern Snuffer`, `Heavy Boots`) from active route/evidence tools (`Timeline Bookmark`, `Decoy Emitter`, `Zipline Kit`)
- **Previously confusing**
  - the item docs lagged the live sandbox and did not explain where Zipline fit
  - large-lobby Veil scaling and team alignment were implicit in code rather than explicit in the role docs
  - Grappling Hook and Mimic were still conceptually floating as if they might already belong to the active slice
- **Strengthened in this pass**
  - added deterministic role scaling/alignment helpers and tests
  - implemented `Zipline Kit` as a host-authoritative, room-safe mobility infrastructure tool
  - strengthened the active item architecture with stable metadata: category, archetypes, tags, room bias, role affinity, and public-evidence descriptors
- **Grappling Hook**
  - deferred for now; a true swing tool would cut across room grammar, determinism, and social readability more than it would help the current slice
- **Mimic**
  - deferred for now; the expedition-vs-Veil structure is cleaner and better supported by the current extraction and clue systems
- **Loot model clarification**
  - traversal-biased rooms now weight toward route-shaping tools like `Zipline Kit`
  - the active slice remains narrow and legible even though the item definitions are now structured for a larger future pool

### What changed
- `godot/src/items/item_service.gd`
  - added `zipline_kit`
  - enriched active item definitions with stable metadata used by spawn weighting and future expansion hooks
- `godot/src/net/network_manager.gd`
  - added host-authoritative zipline deployment from item use
  - kept public clue output anonymous through the existing `item_used` event path
- `godot/src/entities/player.gd`
  - added zipline riding support through the existing local traversal seam
- `godot/src/items/zipline.gd`
  - added a visible cable plus collision area for deterministic local riding
- `godot/src/tests/test_runner.gd`
  - added role scaling/alignment coverage
  - extended the sandbox tests for zipline metadata, deterministic placement, and authoritative item use
- `docs/ITEMS_AND_SYNERGIES.md`
  - updated the active vertical-slice tool list and documented Grappling Hook deferral
- `docs/ROLES_AND_DECEPTION.md`
  - made role alignment, scaling, and Mimic deferral explicit

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`

### Remaining non-blocking polish
- Zipline traversal works as a clean slice tool, but it could later benefit from richer mount/dismount animation and stronger room art anchors without touching authority or replay contracts.

## 2026-03-09 - Iteration 39 (Deep Logic Audit + Item Ecosystem Architecture)

### Deep Logic Audit
- **Objective logic**
  - Artifacts remain the expedition objective.
  - The clean player-facing model is now **authentic** versus **counterfeit** artifacts. The legacy `is_forged` flag remains in code for compatibility, but the report/outcome layer now frames the logic more clearly.
  - Authentic extraction is expedition success; counterfeit extraction or stalled extraction is sabotage success.
- **Team / role logic**
  - `Warden` and `Scavenger` are expedition-aligned.
  - `Veil` is sabotage-aligned.
  - Large lobbies support a second Veil, but Veils remain blind to each other to preserve plausible deniability.
  - `Mimic` remains deferred because the current expedition-vs-sabotage structure is cleaner and better supported by the live systems.
- **Win / extraction logic**
  - The extraction window remains the required pressure gate before success.
  - Personal survival matters as tactical pressure, but it does not override team success/failure in the current slice.
  - The end-of-run payload and report now make expedition success, sabotage success, and artifact result explicit.
- **Inventory / build logic**
  - One-carry artifact pressure remains intact.
  - Tools stay combinable.
  - Relics remain passive modifiers.
  - The new item schema makes future growth safer without bloating the current slice.
- **Social deduction clarity**
  - Public facts still describe outcomes, not certain authorship.
  - The action summary and report keep ambiguous route shaping (`noise_trace`, `artifact_dropped`, `item_used`) readable without leaking culprit identity.
- **Loot logic**
  - Room bias is now better codified as a deterministic weighting model, not a random grab bag.
  - Role affinity remains soft metadata for authoring clarity, not hard role-locked loot.

### What changed
- `godot/src/items/item_service.gd`
  - strengthened the item-definition schema with stable metadata for spawn, evidence, behavior, and synergy authoring
  - added profile helpers and stronger validation
- `godot/src/run/evidence_service.gd`
  - added authenticity helpers so counterfeit artifact logic can be described clearly without breaking compatibility
- `godot/src/net/network_manager.gd`
  - added explicit outcome summary generation in the run-end payload
- `godot/src/roles/role_service.gd`
  - added explicit role goal/win helpers
- `godot/src/run/game_controller.gd`
  - upgraded the exported report to include clearer outcome and artifact-result lines
- `godot/src/tests/test_runner.gd`
  - added coverage for role win logic, artifact outcome logic, and richer item authoring metadata
- `docs/ROLES_AND_DECEPTION.md`
  - clarified expedition/sabotage outcomes and counterfeit artifact framing
- `docs/ITEMS_AND_SYNERGIES.md`
  - documented the stronger long-term item authoring framework and clarified loot philosophy

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`

### Intentional deferrals
- **Grappling Hook:** still deferred. Zipline already covers the lateral mobility fantasy cleanly; swing physics would currently add more readability and authority risk than value.
- **Mimic:** still deferred. The role ecosystem is more legible without a fourth alignment until the expedition-vs-sabotage loop needs that extra complexity.

### Long-term recommendations
- Move item authoring into data files once the slice needs more than the current core set; the schema is now ready for that migration.
- Add richer artifact families only if they remain distinguishable through physical clues rather than menu taxonomy.
- Revisit Grappling Hook only when room grammar includes anchor-safe arenas designed for swing readability.

## 2026-03-09 - Iteration 40 (Playability / Comprehension Pass)

### Playability / Comprehension Audit
- **Biggest confusion points**
  - the HUD still read partly like debug state instead of run state
  - players could not quickly distinguish Artifact pickups from Tool and Relic pickups
  - extraction stabilization existed mechanically, but the hold state and remaining tension were under-communicated
  - Zipline use existed, but mounting/riding cues were too implicit for a first run
- **Biggest readability problems**
  - end-of-run summary did not explain outcome, artifact result, and role result as a coherent payoff block
  - artifact labels looked like shorthand IDs instead of objective items
  - item pickup labels did not tell players what category of object they were seeing
- **Biggest UX problems**
  - the help overlay explained controls but not the objective model clearly enough
  - role text surfaced role names without enough immediate goal context
  - next-step hints were not role-aware enough and could push non-Warden players toward inspection language
- **Strongest current strengths**
  - extraction pressure, notebook privacy, and public ambiguity are already stable
  - the report/export flow is deterministic and proof-safe
  - the live sandbox already creates socially arguable route evidence through ropes, ziplines, bomb marks, footprints, and decoy trails
- **Highest-value fixes**
  - promote run phase and objective text into the HUD
  - phrase Artifacts, Tools, Relics, and Extraction in player language instead of debug shorthand
  - make the end screen read like a payoff summary rather than a raw state dump

### What changed
- `godot/src/run/game_controller.gd`
  - added readable role-goal text, goal line text, extraction-remaining formatting, role-aware hints, ghost/extraction phase wording, stronger help overlay text, and clearer end-of-run outcome phrasing
  - improved prompts for Artifacts, Tools/Relics, Zipline mounting, inspection, and extraction stabilization
- `godot/scenes/Game.tscn`
  - added a dedicated HUD `Goal` line and shifted the prompt/hint/timeline layout so the new clarity text remains readable
- `godot/src/entities/evidence.gd`
  - changed in-world artifact label text to `Artifact E#`
- `godot/src/entities/item_pickup.gd`
  - changed ground pickup labels to `Tool: ...` / `Relic: ...`
- `godot/src/entities/player.gd`
  - exposed explicit zipline-state helpers used by prompts
- `godot/src/tests/test_runner.gd`
  - added coverage for ghost/extraction hint wording, item category descriptions, and help overlay clarity cues
- `docs/UX_UI.md`
  - aligned UI terminology with the live HUD/help/report behavior

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Remaining non-blocking polish
- Artifact visuals could later distinguish authentic versus counterfeit state with slightly richer silhouettes without changing clue ambiguity.
- The help overlay now teaches the loop better, but a first-run role card or single-screen intro could still improve onboarding if kept lightweight.

## 2026-03-09 - Iteration 41 (Fun / Pacing / Replayability Pass)

### Fun / Pacing / Replayability Audit
- **Biggest fun weaknesses**
  - too many runs could still feel structurally similar because room order and item order were broadly deterministic but not strongly shaped into a readable dramatic arc
  - the recap still had strong raw facts, but not enough curation around the most arguable public clues
- **Biggest pacing weaknesses**
  - early runs could open too flat if the first meaningful evidence room arrived too late
  - late runs needed a more reliable hazard choke and a cleaner final-room readability curve
  - immediate duplicate item spawns made some runs feel less distinct than the sandbox deserved
- **Strongest current strengths**
  - extraction pressure, ghost pressure, and ambiguity-safe public logging were already solid
  - the current sandbox already creates strong route evidence through bombs, ziplines, reroutes, and decoy traces
  - the report/export system is deterministic and stable enough to support stronger recap language
- **Most promising levers**
  - deterministic room-arc shaping
  - deterministic item-pacing shaping
  - stronger post-run surfacing of route-changing public clues
- **Highest-value changes in this pass**
  - force a cleaner room arc: traversal opener, early evidence contact, late hazard choke, readable extraction room
  - suppress immediate duplicate item spawns and bias early versus late item families
  - add a `Key Clues` recap so post-run arguments start from the most socially useful public evidence

### What changed
- `godot/src/gen/run_generator.gd`
  - replaced flat bag sampling with a deterministic phase-shaped room arc
  - low-risk traversal opener, early evidence contact, late high-risk hazard choke, and readable traversal extraction room are now intentional
- `godot/src/items/item_service.gd`
  - item spawns now use deterministic pacing bonuses across the run
  - early spawns favor route-enablers/forensics support, later spawns favor deception/signal pressure
  - immediate duplicate spawns are prevented when an alternative exists
- `godot/src/run/game_controller.gd`
  - added `Key Clues` recap lines derived from the public timeline
  - made route tools and route confusion read more like story beats in `Action Summary`
- `godot/src/tests/test_runner.gd`
  - added room-arc and item-replayability coverage
  - added `Key Clues` recap coverage for bomb scars, artifact reroutes, zipline commitments, and extraction hold timing
- `docs/LEVEL_GEN.md`
  - documented the readable run arc biasing
- `docs/ITEMS_AND_SYNERGIES.md`
  - documented early/late item pacing and duplicate suppression
- `docs/UX_UI.md`
  - documented the `Key Clues` recap expectation

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Remaining non-blocking polish
- Room arc shaping is stronger, but individual room interiors could still do more to create distinctive split/rejoin stories.
- `Key Clues` is now a useful bridge between chaos and debate, but it could later learn to highlight one especially suspicious convergence without ever naming a culprit.

## 2026-03-09 - Iteration 42 (Room Interior Quality / Suspicion Density Pass)

### Room Interior Quality / Suspicion Density Audit
- **Biggest interior weaknesses**
  - too much of a room's lived experience still came from the global cave noise rather than deliberate room-local decisions
  - evidence rooms contained the right objective items but did not reliably frame those pickups as exposed, arguable moments
  - hazard rooms had danger, but not enough visible safe-vs-fast path contrast or regroup surfaces
- **Biggest suspicion-density gaps**
  - room-local route commitments like ropes and trap timing shifts were not surfaced strongly enough in the recap
  - item and artifact spawn positions were too static, which flattened room-to-room story variety
  - random platform clutter risked noise without adding meaningful social interpretation
- **Strongest current strengths**
  - the room arc, item pacing, and extraction pressure already produce a good macro run
  - the event log and recap pipeline can already carry stronger room-scale argument fuel without changing networking
  - route tools, bomb marks, and decoy trails are already solid suspicion generators when rooms give them enough structure
- **Highest-value room-level improvements**
  - align room-specific interiors to the same 5x3 room grid the rest of the run uses
  - add deterministic room micro-plans for traversal, evidence, and hazard interiors
  - move evidence and item spawns onto more exposed, room-appropriate anchors
  - surface rope routes and trap-timing beats more clearly in `Action Summary` and `Key Clues`

### What changed
- `godot/src/gen/room_builder.gd`
  - aligned room-specific rendering to the live 5x3 room grid used by players, artifacts, items, and extraction math
  - added deterministic room micro-plans:
    - traversal rooms now get split-route and regroup platforms
    - evidence rooms now get exposed pickup pedestals, watch perches, and clearer contested exits
    - hazard rooms now get safer bypass ledges, faster commitment routes, regroup platforms, and warning lanes
  - removed random loot-box spawning from auto platforms so interiors are deliberate rather than noisy
- `godot/src/run/evidence_service.gd`
  - evidence spawns now use room-type-aware interior anchors, making evidence rooms and late hazard carries more exposed and memorable
- `godot/src/items/item_service.gd`
  - item spawns now use room-type-aware interior anchors so tools and relics contribute to room-local decisions instead of always appearing in the same generic spot
- `godot/src/run/game_controller.gd`
  - improved room-scale clue wording:
    - ropes now read as route changes
    - trap pulses read as timing suspicion
    - room-level route tools surface more clearly in `Key Clues`
- `godot/src/tests/test_runner.gd`
  - added deterministic coverage for room micro-plan structure, exposed evidence/item anchors, and new recap wording

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Remaining non-blocking polish
- The room interiors are now much more deliberate, but they still rely on a small vocabulary of micro-plans; later room-family expansion could add more variants without changing the architecture.
- Evidence rooms now stage exposure better, but later passes could add stronger diegetic “witness perch” art and better artifact-family silhouettes.

## 2026-03-09 - Iteration 43 (Full Product Audit + Outer-Loop Productization)

### Full Product Audit
- **Already real and usable**
  - The host-authoritative run loop, extraction pressure, notebook/report flow, item sandbox, room micro-plans, role logic, and deterministic proof harness were all already live and green.
  - The end-of-run payload already contained enough truth (`outcome_summary`, `summary_by_peer`, `roles_reveal`, report path) to support a real outer loop without touching run authority.
- **Only partial before this pass**
  - The game had no meaningful persistence or profile shell.
  - The lobby was still a minimal connect/ready/start surface with no collection, codex, mastery, settings, or post-run continuity.
  - Cosmetic and progression logic existed only as design intent; there was no save schema or reward handoff from the run.
- **Missing before this pass**
  - persistent profile data
  - codex/collection tracking
  - mastery/account XP
  - cosmetic ownership/equip data
  - a product-facing lobby hub
  - a monetization-safe cosmetic catalog shell
- **Most dangerous architectural seams**
  - adding outer-loop systems directly into the network layer would have risked proof drift
  - adding progression without a schema/catalog layer would have created obvious rewrites
  - overloading `Lobby.tscn` without keeping its existing host/join/start node paths would have broken the headless proof flow
- **What had to be unified first**
  - the run-end report, summary, and EventLog-derived local stats were unified into a single local run-record handoff consumed by product services instead of duplicating outcome logic elsewhere

### What changed
- `godot/config/product_catalog.json`
  - added a data-driven product catalog for cosmetics, mastery tracks, codex entries, and settings defaults
- `godot/src/product/product_catalog.gd`
  - added catalog loading, validation, source descriptions, notebook theme palettes, and codex access helpers
- `godot/src/product/profile_service.gd`
  - added persistent profile save/load, deterministic progression rewards, mastery leveling, codex discovery tracking, cosmetic ownership/equip handling, and last-run summary storage
- `godot/src/run/game_controller.gd`
  - now records a local-only run record into the profile service at `run_ended`
  - applies notebook themes from the equipped cosmetic profile state
  - applies large-text and hint-mode settings locally without touching network state
- `godot/scenes/Lobby.tscn`
  - upgraded from a narrow join panel into a real hub with tabs for Home, Profile, Collection, Codex, Cosmetics, and Settings
- `godot/src/ui/lobby_controller.gd`
  - wired the new product shell while preserving the proof-critical host/join/ready/start and CLI automation path
  - added cosmetic browsing/equipping, settings toggles, profile/mastery summaries, collection/codex browsing, and last-run continuity
- `godot/src/tests/test_runner.gd`
  - added catalog validation, profile progression, and lobby-shell contract coverage
- `docs/ARCHITECTURE.md`
  - documented the new local-only product services and the clarified Lobby-vs-Game boundary
- `docs/UX_UI.md`
  - documented the lobby product shell and post-run progression handoff
- `docs/TESTING.md`
  - documented product-shell/progression test expectations

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Remaining concrete expansion surface
- cosmetic categories already supported in the catalog but not yet visually applied beyond notebook themes:
  - zipline skins
  - rope skins
  - lantern skins
- the lobby shell is now ready for richer profile cards, run history browsing, and codex detail pages without further save-schema churn
- the profile service is ready for achievement-style tracking and broader cosmetic unlock tables without changing the run or network contract

## 2026-03-09 - Iteration 44 (Product Shell Deep Audit + Professionalization)

### Product Shell Deep Audit
- **Architectural integrity**
  - The local-only product layer remained correctly separated from run truth: no network payloads, proof markers, or replay contracts needed to change.
  - The shallow areas were not authority bugs; they were UX depth and data-shape gaps: no achievements, no richer codex/collection browsing, limited controller/back flow, and weak diagnostics for why a run felt interesting.
- **Product shell quality**
  - The lobby hub was functional but summary-heavy. It needed to feel less like tabs over raw strings and more like a real product surface with detail panes, next reward previews, and stronger last-run continuity.
- **Progression / retention quality**
  - XP and mastery were fair, but players had no milestone framing, no reward breakdown, and too little reason to care about their profile between runs.
- **Controller / UX readiness**
  - Tab switching existed, but escape/back behavior, focus defaults, and tab-specific browsing were still shallow.
- **Cosmetic / monetization foundation**
  - Ownership and equip state were correct, but cosmetics needed preview depth and a stronger data model for future growth.
- **Content pipeline / data architecture**
  - The external catalog was a good start, but it needed stronger schema validation plus support for achievements and richer codex sections.

### What changed
- `godot/config/product_catalog.json`
  - expanded the product catalog with achievements and richer codex sections (`roles`, `item_families`) while keeping all rewards cosmetic or informational
- `godot/src/product/product_catalog.gd`
  - strengthened validation to cover categories, mastery thresholds, achievements, and codex entries
  - added validation report helpers, achievement accessors, and codex section helpers
- `godot/src/product/run_story_diagnostics.gd` (new)
  - added deterministic local-only diagnostics summarizing route pressure, suspicion beats, artifact beats, and story tone from the stored run record
- `godot/src/product/profile_service.gd`
  - added career stats, achievement unlock state, reward-breakdown storage, next-rank/next-cosmetic previews, richer history lines, collection/codex detail builders, cosmetic preview builders, and settings-help builders
- `godot/scenes/Lobby.tscn`
  - deepened the shell with hero/profile/history panels, collection/codex section browsers, cosmetic item browsing/preview, reset-settings support, and data-health/readability surfaces
- `godot/src/ui/lobby_controller.gd`
  - wired the richer lobby shell while preserving host/join/ready/start automation
  - added controller-friendly back behavior, focus defaults, accessible text scaling, detail-pane refresh logic, richer last-run reward/diagnostic surfaces, and cosmetic preview flow
- `godot/src/tests/test_runner.gd`
  - added deterministic coverage for the deeper catalog/profile helpers and the richer lobby scene contract

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Remaining exact expansion surface
- live cosmetic application beyond notebook themes:
  - zipline visual skins
  - rope presentation skins
  - lantern presentation skins
- richer codex detail pages backed by the now-validated catalog:
  - artifact families
  - item families
  - role pages with more examples and clue callouts
- progression growth now supported without schema churn:
  - more achievements
  - broader mastery reward tables
  - richer run-history filtering and profile-card presentation

## 2026-03-09 - Iteration 45 (Strict Current-State Map + Multiplayer/Product Reliability Audit)

### Current strengths
- The host-authoritative run spine remains the single source of truth for movement, artifacts, tools, extraction, Ghost pressure, public/private timeline events, and proof markers.
- The notebook, recap, key-clue, and product-shell layers are already real and integrated rather than speculative.
- Local-only persistence boundaries are correct: profile/progression/cosmetics/codex live outside the run authority path.

### Highest-leverage gaps
- **Session reliability:** clients can disconnect cleanly, but there is no explicit reconnect/fallback path or session resume affordance in the shell.
- **Social communication:** the game has good physical clues but still lacks a lightweight public callout layer and voice-ready settings seam.
- **Run-to-lobby continuity:** the shell has last-run summaries, but not enough session-state continuity or history browsing to feel low-friction and replay-ready.
- **Controller/shell maturity:** tab switching exists, but social/settings/history flows are still shallower than the rest of the product shell.

### Critical architectural constraints
- Do not alter proof-critical host/join/ready/start markers or the authority model in `NetworkManager`.
- Do not add a second replay/timeline truth model; extend `EventLog`, `NetworkManager`, and `GameController`.
- Keep all reconnect, ping, voice, history, and shell work local/product-facing unless the host must explicitly arbitrate it.

### Recommended implementation order
1. **Session reliability and reconnect fallback**
   - extend `NetworkManager`, `LobbyController`, and the current lobby scene
   - preserve existing start/join/start-run proof flow
2. **Lightweight social communication**
   - add room callouts through the existing public event log and room indicators
   - add a production-ready voice settings seam without faking a transport implementation
3. **History / continuity / shell deepening**
   - expose reconnect/session state and richer run history in the existing product hub
4. **Validation and doc truth**
   - extend tests around reconnect helpers, callout/public-meta safety, history helpers, and shell node contracts

### What changed
- `godot/src/net/network_manager.gd`
  - added a controlled reconnect-offer path for clients, session-overview helpers for the hub, and an authority-safe runtime-join denial path when a run is already active
  - added public `room_callout` events routed through the existing public event log instead of a parallel ping system
- `godot/src/run/game_controller.gd`
  - added lightweight platforming-safe callouts on `1/2/3` for `Danger`, `Regroup`, and `Artifact`
  - surfaced those callouts through room indicators, action summary lines, key clues, and local feedback without leaking private information
  - added a controlled return-to-lobby path when the host disconnects or a mid-run join is denied
- `godot/src/gen/room_builder.gd`
  - generalized room indicators so hazard warnings and public callouts share the same visual channel cleanly
- `godot/config/product_catalog.json`
  - added `room_callout` to clue-family discoveries
  - added product-level voice defaults (`off`, `push_to_talk`, `mute_voice`) for a production-ready voice seam
- `godot/src/product/product_catalog.gd`
  - strengthened validation around voice-mode defaults and surfaced them in validation reports
- `godot/src/product/profile_service.gd`
  - expanded run-history entries with reward gain, report path, key clues, and short action summaries
  - added voice-mode cycling and clearer settings/help lines so the shell can support real social settings later without schema churn
- `godot/src/ui/lobby_controller.gd`
  - wired reconnect state, session summary, run-history selection, and voice settings into the existing product hub
  - kept the proof-critical host/join/ready/start flow intact
- `godot/src/tests/net_manager_test_helpers.gd`
  - updated the public-meta allowlist for `room_callout` so only the safe `kind` field survives
- `godot/src/tests/test_runner.gd`
  - added deterministic coverage for reconnect helpers, runtime-join denial helpers, public callout metadata scrubbing, room-callout recap wording, history-entry detail building, and voice settings cycling

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Manual verification steps
1. Host a run, join from a second client, ready both, and start the run.
2. Press `1`, `2`, and `3` in-room during traversal and confirm the room indicator flashes `!`, `REG`, and `ART` without obscuring platforming.
3. Disconnect the client during a run and confirm the client returns to the lobby with a reconnect-ready shell state instead of a dead-end error.
4. Attempt to join a host with an already-active run and confirm the client receives a controlled denial, lands back in the lobby, and is told to rejoin after the lobby returns.
5. Return to the lobby after a run and confirm the Profile tab shows the new run-history detail with role, artifact result, XP gain, key clues, and report path.

### Remaining risks
- The reconnect flow is intentionally a controlled fallback, not full mid-run state restoration. That preserves role/privacy boundaries and avoids unsafe late-join truth reconstruction.
- Voice is still a product/settings seam rather than a transport implementation. That is deliberate: the shell can now support mute/PTT/proximity decisions without binding the project to a premature voice backend.

### Next phase
- Deepen the same shell with controller/back-flow polish, richer run-history browsing, and developer-facing diagnostics without introducing a second communication or replay model.

## 2026-03-09 - Iteration 46 (Current-State Map Before Session/History Deepening)

### Current strengths
- `NetworkManager` already owns session truth cleanly:
  - connection status
  - reconnect offer state
  - controlled active-run join denial
  - public room callout emission
- `GameController` already owns read-only recap shaping and local-only run recording.
- `ProfileService` already owns run history, last-run continuity, fair progression, and settings persistence.
- `LobbyController` and `Lobby.tscn` already own the outer-loop shell and keep proof-critical host/join/start flow intact.
- Current validation remains green:
  - `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
  - `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`

### Shallow spots
- Mid-run interruptions still bounce the player back to the lobby without preserving a first-class interrupted run record.
- Run history is readable but still too flat: it lacks simple browsing/filtering by outcome or interruption state.
- Diagnostics already exist, but they do not yet produce a stronger review packet around communication, interruption state, and argument-friendly run identity.
- Session continuity text is present, but reconnect policy and “wait for lobby vs reconnect now” semantics are still too implicit.

### Risks to avoid
- Do not attempt unsafe mid-run state restoration that could leak role/private truth.
- Do not create a second replay or history truth model outside `GameController` run records and `ProfileService`.
- Do not turn room callouts or review helpers into blame-proof tools.
- Do not disturb proof-critical host/join/ready/start markers or run-end report structure.

### Recommended dependency order
1. Deepen local interrupted-run continuity through the existing `GameController -> ProfileService` handoff.
2. Deepen `RunStoryDiagnostics` and `ProfileService` review/history helpers using the stored run record only.
3. Wire controller-safe history filtering and richer review surfaces into the existing `LobbyController` / `Lobby.tscn` shell.
4. Extend deterministic tests around interrupted run records, history filters, and review packets.

## 2026-03-09 - Iteration 47 (Session Continuity + History Review Deepening)

### What was shallow
- Interrupted sessions could bounce back to the lobby without becoming a first-class local run record.
- The Profile tab had run history, but not enough controller-safe filtering to answer simple review questions like:
  - was that run interrupted?
  - was it a Warden run?
  - was it sabotage-heavy or communication-heavy?
- Session policy text existed, but the distinction between `Reconnect now` and `Wait for lobby return` was still too implicit.

### What changed
- `godot/src/run/game_controller.gd`
  - preserved the last known local peer id across disconnects so interrupted run records still attach to the correct local player instead of falling back to host id `1`
  - upgraded interrupted run recording to include communication summaries and reconnect-policy state in the stored local run record
- `godot/src/product/run_story_diagnostics.gd`
  - expanded diagnostics to track communication beats, interrupted/disrupted session tone, reconnect readiness, and review-line output suitable for the product shell
- `godot/src/product/profile_service.gd`
  - interrupted runs now:
    - award no account XP
    - award no mastery XP
    - increment `interrupted_runs`
    - retain reconnect-policy and communication review context
  - added deterministic history filters for:
    - interruption state
    - role
    - expedition/sabotage outcome
    - story tone
    - communication-heavy runs
    - rewarding runs
- `godot/src/net/network_manager.gd`
  - added readable session-policy line builders so the shell can explain whether the player is offline, hosting, joined, reconnect-ready, or waiting for the lobby to return
- `godot/src/ui/lobby_controller.gd` + `godot/scenes/Lobby.tscn`
  - added a `HistoryFilter` control to the existing Profile tab
  - wired filtered history summaries and detail browsing into the existing shell without introducing a second history model
- `godot/src/tests/test_runner.gd`
  - added deterministic coverage for:
    - session-policy line generation
    - interrupted run reward suppression
    - interrupted run history filtering
    - review-line content
    - new Profile tab shell contract marker

### Why it mattered
- Session continuity is now explicit instead of implied.
- The shell now gives players a useful answer after an interruption:
  - what happened
  - whether they can reconnect now
  - whether they must wait for the lobby to return
  - why no progression was awarded
- Run history is now much closer to a real review surface instead of a flat recent-runs list.

### Tests added / updated
- session policy helper coverage (`Mode`, `Reconnect`, `Reason`)
- interrupted run profile/history coverage
- history filter coverage (`INTERRUPTED`, role, tone, callout-heavy, rewarding)
- updated lobby shell scene contract to require `HistoryFilter`

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Manual verification steps
1. Start a host and a client, begin a run, then disconnect the client mid-run.
2. Confirm the client returns to the lobby and the Home/Profile surfaces describe the interruption instead of dead-ending.
3. Open the Profile tab and cycle the history filter:
   - `Interrupted`
   - `Scavenger` / `Warden` / `Veil`
   - `Disrupted`
   - `High Callouts`
4. Confirm the interrupted run shows:
   - interruption reason
   - reconnect policy
   - callout summary
   - zero-progression reward text
5. Attempt to join an already-active run and confirm the lobby session summary says to wait for the lobby return instead of implying an unsafe restore.

### Remaining risks
- Reconnect remains a conservative fallback rather than a true mid-run resync. That is still the correct fairness/privacy boundary.
- History filtering is intentionally lightweight and shell-safe; it is not yet a full run-history browser.

### Exact next phase opportunities
1. Deepen the same Profile tab with richer run-history browsing and comparison surfaces.
2. Add more replay-adjacent review packets derived from run truth only, not a second replay model.
3. Extend the communication seam with clearer voice lifecycle/help surfacing and future transport hooks, still without adding a second communication system.

## 2026-03-09 - Iteration 48 (Current-State Map Before History Browser Deepening)

### What is already strong
- `ProfileService` already stores enough truth for a useful between-runs layer:
  - `last_run`
  - `run_history`
  - reward breakdowns
  - diagnostics
  - interruption state
  - reconnect-policy state
- `RunStoryDiagnostics` already derives ambiguity-safe summaries from stored run records without touching authoritative run truth.
- `LobbyController` already exposes Home/Profile review surfaces and a controller-safe history filter path.
- `NetworkManager` already exposes readable session policy lines and conservative reconnect truth.

### What still feels shallow
- The Profile tab still behaves more like a filtered list than a real run-history browser.
- History labels are readable but not yet good at surfacing:
  - why a run was memorable
  - whether it is worth revisiting
  - how it compares to nearby runs
- Last-run continuity is present, but the shell still needs better “what next?” energy after:
  - a successful run
  - an interrupted run
  - a review-only return to lobby
- Review packets are still spread across helpers instead of being shaped into one clearer human-readable packet.

### What should remain unchanged
- No second history or replay truth model.
- No unsafe mid-run restoration.
- No blame-proof presentation of public callouts, key clues, or interruption diagnostics.
- No shell sprawl beyond the current Home/Profile surfaces unless a small addition clearly earns its keep.

### Dependency order for this pass
1. Deepen `ProfileService` review/history packet builders around existing stored run-history entries.
2. Deepen `RunStoryDiagnostics` only where that improves packet readability and developer reviewability.
3. Wire the better packet/browsing outputs into existing Home/Profile shell nodes in `LobbyController` / `Lobby.tscn`.
4. Extend deterministic tests for packet shaping, history browsing, and continue/re-entry guidance.

## 2026-03-09 - Iteration 49 (History Browser + Review Packet Deepening)

### What felt shallow
- The Profile tab could filter runs, but it still felt like a list of entries rather than a small run browser.
- Last-run continuity existed, but the Home tab still needed clearer “what now?” guidance after:
  - a completed run
  - an interrupted run
  - a review-only return to lobby
- Review helpers were technically correct, but the memorable identity of a run was still scattered across:
  - summary text
  - diagnostics
  - key clues
  - action summaries

### What changed
- `godot/src/product/run_story_diagnostics.gd`
  - added human-readable highlight tags and memorable-summary text derived from existing diagnostics
  - expanded review lines so they now explain not only what happened, but why the run is worth revisiting
- `godot/src/product/profile_service.gd`
  - unified last-run and history-detail rendering through a single review-packet builder
  - upgraded history labels to surface run identity more quickly with readable tags
  - added `build_history_focus_lines(...)` for the selected history entry
  - added `build_continue_guidance_lines(...)` for Home-tab re-entry / queue-again guidance
- `godot/src/ui/lobby_controller.gd`
  - wired the richer continue guidance into the Home tab
  - wired the new history focus panel into the Profile tab so the selected run now has a compact “why revisit” summary
- `godot/scenes/Lobby.tscn`
  - added `HomeTab/Continue`
  - added `ProfileTab/HistoryFocus`
- `godot/src/tests/test_runner.gd`
  - added deterministic coverage for:
    - history focus lines
    - continue guidance
    - updated shell node contract markers

### Why it mattered
- The shell now does a better job of turning recent runs into reasons to:
  - reconnect safely
  - review a dramatic interruption
  - queue another run while the story is fresh
- The run browser is now more comparison-friendly and more controller-safe without turning into a second replay UI.
- Review packets are still derived from stored run truth only, which preserves the existing architecture and ambiguity boundaries.

### Tests added / updated
- `history focus` helper coverage
- `continue guidance` helper coverage
- updated lobby shell scene contract for the new Home/Profile labels

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers still intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Manual verification steps
1. Open the Home tab after a completed run and confirm the new `Continue` surface points the player toward reconnect/review/requeue behavior appropriately.
2. Open the Profile tab and switch the history filter between:
   - `Interrupted`
   - `Chaotic`
   - `High Callouts`
3. Select different history entries and confirm `HistoryFocus` updates with:
   - selected run identity
   - why revisit text
   - story tags
4. Confirm interrupted runs still show zero-progression reward messaging and reconnect policy lines.

### Remaining risks
- The run browser is intentionally compact and label-driven; it is not yet a full compare/filter history screen.
- Review packets remain ambiguity-safe. They help memory and discussion, but they do not solve blame mechanically.

### Exact next phase opportunities
1. Add richer run-history comparison surfaces inside the existing Profile tab without turning it into a separate browser scene.
2. Add replay-adjacent review packets around seed/report/session identity and stronger clue clustering.
3. Deepen continue/rematch momentum in the shell using the same session/history/product helpers.

## 2026-03-10 - Iteration 50 (Between-Runs Productization and Replay-Momentum)

### Current-state map
- `NetworkManager` already owned session truth, reconnect policy, and safe session-overview surfacing.
- `GameController` already emitted the right local run-record handoff with interruption, communication, clue, report, and outcome context.
- `ProfileService` and `RunStoryDiagnostics` already had the right local-only seams for history, review, and diagnostics.
- `LobbyController` and `Lobby.tscn` already exposed the right Home/Profile shell surfaces, but those surfaces still felt flatter than the quality of the stored run truth.

### What still felt shallow
- The Profile tab still behaved more like an upgraded filtered list than a real run-history browser.
- Review outputs were still spread across helper families instead of one explicit formatting authority.
- The Home tab guidance worked, but it did not yet feel like a real command surface with replay momentum.
- The voice seam was honest, but still too abstract for a product-grade shell.

### What changed
- `godot/src/product/profile_service.gd`
  - consolidated between-runs run presentation around one internal run-review model that now emits compact labels, focus packets, compare summaries, full review packets, digest snippets, re-entry snippets, and helper-only developer summaries from the same stored run truth
  - added deterministic history sort modes, browser-state helpers, compare-target selection, recent-run curation, and dominant-CTA continue guidance
- `godot/src/product/run_story_diagnostics.gd`
  - added revisit-worthiness, communication-density, dramatic-intensity, and interruption-context bands so review packets and future tuning helpers can use the same derived language
- `godot/src/ui/lobby_controller.gd`
  - rewired Home/Profile to consume the consolidated browser/review state instead of synthesizing parallel run wording
  - added history sort support, stronger recent-run surfacing, and a cleaner controller flow between filter, sort, and run list
- `godot/scenes/Lobby.tscn`
  - added `HomeTab/RecentRuns` and `ProfileTab/HistorySort` to support the stronger command-surface and run-browser rhythm without introducing a new scene
- `godot/src/tests/test_runner.gd`
  - added deterministic coverage for history sort modes, browser-state preservation, compare-target outputs, curated recent-run slots, dominant CTA behavior, and the expanded shell contract

### Why it mattered
- The Home tab now behaves more like a compact between-runs command surface instead of a recap pile.
- The Profile tab is materially closer to a real run-history browser: filter, sort, selected run, compare target, and standout context now work together as one system.
- Review packets now feel like remembered social events rather than scattered helper output.
- The shell now carries stronger replay momentum after both completed and interrupted runs without touching authoritative run behavior.

### Tests added / updated
- review model and history-browser helper coverage
- curated recent-run digest coverage
- dominant CTA / continue-guidance coverage
- interrupted-run browser fallback coverage
- updated lobby shell scene contract for `RecentRuns` and `HistorySort`

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers remained intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Manual verification steps
1. Open the Home tab after a completed run and confirm it shows one dominant next action, a supporting reason, and one secondary route.
2. Open the Home tab after an interrupted run and confirm it clearly distinguishes reconnect-now, wait-for-lobby, or review-only continuity.
3. Open the Profile tab and switch both history filter and history sort while moving focus with keyboard or controller; confirm the selected run stays stable when still valid.
4. Select multiple runs and confirm `HistoryCompare` explains the contrast in drama, reward, communication, completion, and standout context.
5. Enable large-text mode and confirm Home/Profile still preserve panel hierarchy, CTA prominence, and selection clarity.

### Remaining risks
- The history browser is intentionally compact and curated; it is still not a full replay browser or report viewer.
- Voice remains a settings/lifecycle seam rather than an active transport feature.
- Compare output is deliberately ambiguity-safe and must stay that way as future review helpers deepen.

### Exact next phase opportunities
1. Add richer selected-run comparison and grouped browsing inside the existing Profile tab without introducing a second history scene.
2. Add stronger helper-only review/tuning outputs around revisit-worthiness, interruption patterns, and communication density for future playtest dashboards.
3. Deepen Home-tab replay momentum further with better party continuity once the multiplayer lobby flow itself is ready for that step.
4. Extend the voice seam with clearer lifecycle hooks and future speaking-indicator readiness only when transport work becomes the next real product need.

## 2026-03-10 - Iteration 51 (Run Memory, Party Continuity, and Communication Readiness)

### Current-state map
- The previous between-runs wave landed cleanly: Home already behaved more like a command surface, Profile already behaved more like a history browser, and the shell had one real review model instead of scattered text helpers.
- The remaining weakness was not missing truth. It was that the same stored run history still surfaced too flatly in two places:
  - Profile compare/browse context was still thinner than the stored diagnostics justified.
  - Home continuity still needed stronger party/re-entry framing and a cleaner separation from Profile browsing.
- The current worktree also still required a continuation-safety mindset because the active product owner files remained the seam being extended.

### What still felt shallow
- Compare selection was still too adjacency-biased for a product-grade run browser.
- The browser and Home shell were still underusing the same run-memory truth for:
  - standout clustering
  - compare digests
  - interruption pattern surfacing
  - party continuity language
- The voice seam was credible, but its lifecycle wording still needed to read more like a deliberate product policy than a settings placeholder.

### What changed
- `godot/src/product/profile_service.gd`
  - strengthened the internal run-memory model with:
    - recent run cluster lines
    - compare digest lines
    - interruption pattern lines
    - Home overview lines
  - tightened the selected-run packet, digest, re-entry, and developer-summary outputs so Home stays action-first and Profile stays browse-first
  - changed compare-target resolution to prefer deterministic contrast over simple adjacency while staying inside the active filter/sort context
  - tightened browser summary lines and recent-run strip formatting so standout runs are more compact and more distinct
- `godot/src/product/run_story_diagnostics.gd`
  - added reusable cluster and signal-stack helpers so the shell and future tuning helpers use the same derived story language
- `godot/src/ui/lobby_controller.gd`
  - rewired Home overview to consume the consolidated product helper
  - preserved focus owner more carefully through history refreshes so the browser feels less jumpy during ordinary shell updates
- `docs/UX_UI.md`
  - recorded the stronger compare-with-context, Home action-priority, and communication-policy truths
- `docs/TESTING.md`
  - recorded the new deterministic expectations around browser-state stability, compare-target contrast, dominant CTA behavior, and voice-seam honesty
- `godot/src/tests/test_runner.gd`
  - extended deterministic coverage for the new compare, recent-run, interruption-pattern, Home overview, and voice-surface helper outputs

### Why it mattered
- The same run record now supports a more useful between-runs loop without introducing a second history or replay model.
- Profile compare now answers more meaningful questions about contrast instead of just showing the nearest entry.
- Home now has stronger continuity language around:
  - current lobby state
  - reconnect/wait/review decisions
  - why the last run is still worth reopening
- The shell remains compact and ambiguity-safe while becoming more useful for both players and future tuning work.

### Tests added / updated
- compare-target selection determinism
- recent-run cluster helper coverage
- interruption-pattern helper coverage
- Home overview / command-surface helper coverage
- expanded voice seam helper coverage
- updated shell node contract expectations remain intact

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers remained intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Manual verification steps
1. Open Home after a completed run and confirm it shows:
   - one dominant next action
   - one supporting reason
   - one secondary route
   - a compact recent-run memory strip
2. Open Home after an interrupted run and confirm it distinguishes:
   - reconnect now
   - wait for lobby
   - review while regrouping
3. Open Profile and change filters/sorts while keeping one run selected; confirm ordinary shell refreshes do not bounce selection unnecessarily.
4. Select different runs in Profile and confirm `HistoryCompare` explains contrast in:
   - drama
   - reward
   - communication
   - interruption/completion
5. Open Settings and confirm voice wording clearly communicates:
   - current policy
   - callout fallback
   - lifecycle readiness without implying transport

### Remaining risks
- The shell is intentionally still curated and compact; it should not drift toward a report viewer or full replay browser.
- Grouped browsing is still deferred until it proves it can improve scan speed without adding clutter.
- Voice is still only a seam; future transport work must preserve the same honesty and privacy boundaries.

### Exact next phase opportunities
1. Add optional grouped browsing inside the existing Profile tab only if it materially improves scan speed and controller rhythm.
2. Add richer helper-only review outputs for future playtest dashboards, especially around strongest-run clustering and compare digests.
3. Deepen party continuity further once the authoritative lobby/rematch flow is ready for that step.
4. Extend the voice seam with explicit lifecycle hooks and future speaking-indicator readiness only when transport work becomes the next approved wave.

## 2026-03-10 - Iteration 52 (Contextual Run Memory and Party Continuity Maturity)

### Current-state map
- The prior between-runs work already landed the right architecture: one review model, one Home command surface, one Profile browser, and one voice/settings seam.
- The remaining weakness was quality, not missing truth. The shell still needed:
  - stronger compare contrast
  - stronger recent-run memory
  - stronger honest party continuity language
  - stronger helper-only review outputs for future tuning
- The active product owner files remained the same live seam, so this pass stayed inside:
  - `godot/src/product/profile_service.gd`
  - `godot/src/product/run_story_diagnostics.gd`
  - `godot/src/ui/lobby_controller.gd`
  - `godot/scenes/Lobby.tscn`

### What changed
- `godot/src/product/profile_service.gd`
  - strengthened compact Home and Profile outputs around the same run-memory truth:
    - recent run cluster helpers
    - compare digest helpers
    - interruption-pattern helpers
    - Home overview / continuity helpers
  - shifted compare output to prefer deterministic contrast over simple adjacency while staying inside the active filter/sort context
  - tightened Home lines so party continuity stays honest and replay-focused without implying persistence the session layer does not support
- `godot/src/ui/lobby_controller.gd`
  - rewired Home diagnostics to consume the richer run-memory tuning helper instead of flattening all context into last-run text
  - preserved focus owner more carefully during ordinary history refreshes so the browser feels less jumpy
- `docs/UX_UI.md`
  - recorded the stronger selected-run-first, compare-with-context, Home density, and honest continuity truths
- `docs/TESTING.md`
  - recorded new manual checks for contextual compare usefulness, Home density discipline, and honest continuity wording
- `godot/src/tests/test_runner.gd`
  - extended deterministic coverage for:
    - compare wording
    - recent-run cluster/tuning helpers
    - Home continuity / overview helpers
    - voice lifecycle wording

### Why it mattered
- The shell now does a better job of answering:
  - why this run matters
  - why reopen this run instead of that one
  - what to do next with the current lobby/session state
- Home stayed action-first instead of drifting toward a second review pane.
- Profile became more contextual without turning into a report viewer.
- The same local run truth now does more work for future tuning while staying ambiguity-safe for players.

### Tests added / updated
- compare-context helper assertions
- recent-run cluster and run-memory tuning helper assertions
- Home continuity / overview helper assertions
- voice lifecycle wording assertions

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers remained intact:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Manual verification steps
1. Open Home after a completed run and confirm it shows:
   - one dominant next action
   - one supporting reason
   - one compact recent-run strip
2. Open Home after an interrupted run and confirm it uses regroup / wait-for-lobby / rejoin-later language instead of implying rematch persistence.
3. Open Profile, change filter/sort, and confirm ordinary shell refreshes do not bounce the selected run when it still exists in the active context.
4. Select several runs in Profile and confirm compare text answers:
   - how this run differs
   - why it stands out
   - why it is worth reopening
5. Open Settings/Home voice surfaces and confirm lifecycle wording is future-ready without implying transport exists today.

### Remaining risks
- Grouped browsing is still deferred until it clearly improves scan speed and controller rhythm.
- The shell must remain curated and compact; future helper outputs should not leak into player-facing panels by default.
- Party continuity remains language-only until the authoritative lobby/rematch flow itself grows.

### Exact next phase opportunities
1. Add optional grouped browsing in Profile only if it measurably improves scan speed and controller flow.
2. Deepen helper-only strongest-run and compare-digest outputs for future playtest dashboards.
3. Improve party continuity further only when the authoritative lobby/rematch flow is ready.
4. Extend the voice seam with lifecycle hooks and speaking-indicator readiness only when transport work becomes the next approved wave.

## 2026-03-11 - Iteration 53 (Between-Runs Finalization and Review Intelligence Completion)

### Continuation-safety preflight
- Confirmed live owner paths are still the loaded shell/product seams:
  - `res://src/product/profile_service.gd`
  - `res://src/product/run_story_diagnostics.gd`
  - `res://src/ui/lobby_controller.gd`
  - `res://scenes/Lobby.tscn`
  - `res://src/tests/test_runner.gd`
- Confirmed no duplicate tracked/untracked parallel owner path is currently wired into preload/scene startup.

### What changed
- `godot/src/product/run_story_diagnostics.gd`
  - Added deterministic revisit scoring and revisit-reason helpers.
  - Added deterministic interruption-pattern bucket helper.
  - Tightened revisit-band thresholds to better separate low/medium/high revisit value.
- `godot/src/product/profile_service.gd`
  - Home overview now uses a stronger run-memory momentum line sourced from the consolidated review model.
  - History compare digest now appends a deterministic primary contrast dimension for helper-only tuning.
  - Focus/last-run packets now use a stronger reopen reason derived from revisit diagnostics.
  - Recent-run curation can include a communication-heavy slot only when it actually earns inclusion.
  - Added helper-only strongest-run cluster output and richer interruption recovery summaries.
  - Expanded developer summary lines with revisit score, interruption bucket, and cluster labeling.
  - Voice seam wording now explicitly separates mode, PTT policy, mute policy, lifecycle context, and callout fallback without implying transport exists today.
- `godot/src/ui/lobby_controller.gd`
  - Increased selected-run prominence in Profile run lists via explicit selected-item prefixing.
  - Improved empty-state focus fallback to avoid dead-end focus when history filters return zero runs.
  - Tightened large-text resilience by scaling item-list font surfaces and emphasizing `Continue`/`HistoryFocus` hierarchy.
  - Settings-tab default focus now prioritizes core accessibility toggle first.
- `godot/src/tests/test_runner.gd`
  - Updated deterministic wording expectations for the finalized voice and reopen-reason contracts.
  - Added assertions for richer helper-only outputs (`Strongest cluster`, compare digest dimension, interruption recovery line).
- `docs/UX_UI.md`
  - Synced selected-run emphasis, helper-only memory signal boundary, and explicit voice policy surface guidance.
- `docs/TESTING.md`
  - Added deterministic helper-only review-signal coverage objective.

### Why it improved the product
- Profile compare/focus now better answers "why reopen this run now?" with stronger contrast and revisit reasoning.
- Home momentum is now tied directly to remembered run context instead of generic progression-only phrasing.
- Voice seam messaging is clearer and more product-ready while staying honest about transport not being implemented.
- Controller and large-text browsing flow is more stable and selected-run context is easier to track at a glance.
- Helper-only review outputs are richer for future dashboard/playtest tuning without increasing player-facing density.

### Validation
- `scripts/run_tests.ps1` -> `[PASS] Milestone tests passed.`
- `scripts/run_headless_proof.ps1` -> `=== HEADLESS PROOF PASS ===`
- Proof markers unchanged:
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

### Deferred (explicit)
- Grouped browsing remains deferred; flatter Profile browser remains the default.
- Voice transport and speaking indicators remain deferred.
- No rematch networking/session persistence changes were introduced.
