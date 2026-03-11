# Testing Strategy

## Philosophy
Testing in Deduction Delve relies heavily on automated, deterministic script validations coupled with focused manual runbooks. Because the game is a platforming/physics hybrid, network synchronization and host-authority are paramount to ensure that "accidents" are actually the fault of the player, not a network lag spike.

## Deterministic Generation Tests
1. **Seed Determinism:** Validating the exact same cavern room topology, hazard configurations, and item/artifact spawns across identical `run_seed` launches.
2. **Substream Integrity:** Ensure that rng calls happening mid-run do not irreversibly fracture the Host's core procedural generation pipeline sequence.

## Network Authority Tests
1. **Cross-Room Guardrails:** Forcing out-of-bounds client interactions (e.g., cross-room steals, picking up evidence far outside legitimate coordinate boundaries) and validating immediate Host rejection.
2. **Action Denial Bounds:** Testing the "One-Carry limit" validation to ensure players cannot hold multiple evidence artifacts simultaneously. 

## Traversal & Hazard Sync Tests
1. **Platforming Interpolation:** Inject artificial latency and command a client to execute complex maneuvers (coyote jumps, scaffolding drop-throughs), ensuring smooth visual prediction and accurate Host mathematical corrections without snapping or stuttering.
2. **Physics Objects Parity:** Throwing a bomb and validating its rigid body arc, bounces, and radius resolve simultaneously on all connected screens based precisely on the Host's calculation tick.

## Item & Synergy Tests
1. **Environmental Trace Application:** Ensure that dropping footprint decals, spawning bomb scorch marks, and altering lantern light radiuses sync and decay deterministically on all clients for accurate social interpretation.

## Role Secrecy Tests
1. **Memory Sandbox Proof:** Validate that no client retains network payload evidence or memory access capable of revealing another peer's secret role string prior to the official game-end payload.

## Evidence Integrity Tests
1. **Forge Anonymity Constraints:** Validate that the public event meta-allowlist strictly filters out private forge hints from `artifact_spawned` broadcasts.

## Suspicion UI & Replay Summary Tests
1. **Timeline Resolution Checks:** Verify the End-of-Run UI perfectly displays the parsed chronological structure of logged host-events, revealing key actions without perfectly, mathematically solving every mystery.
2. **Sabotage Broadcast Scrubbing:** Verify Sabotage events strip all Actor peer IDs before global broadcast (`actor_peer_id = -1`) ensuring the Veil's deniability remains perfectly untracked during the action.

## Product Shell & Progression Tests
1. **Catalog Validation:** Cosmetic/progression catalog definitions should validate structurally so future expansion does not silently drift into unusable data.
2. **Profile Progression Roundtrip:** Applying a deterministic run record should update account XP, mastery XP, codex discoveries, owned cosmetics, and last-run summary without touching any network state.
3. **Lobby Shell Contract:** The Lobby scene must retain its host/join/start automation surface while also exposing product-shell tabs for Home, Profile, Collection, Codex, Cosmetics, and Settings.
4. **Product Depth Helpers:** Progress previews, achievement unlocks, collection/codex detail builders, and cosmetic preview helpers should remain deterministic and pure so the shell can grow without hidden logic drift.
5. **Catalog / Profile Diagnostics:** Validation and run-story summary helpers should stay local-only and must never alter proof markers, host authority, or replay truth.
6. **Reconnect / Session Helpers:** Controlled reconnect offers, runtime-join denial helpers, and session overview builders must stay deterministic and must not bypass host authority.
7. **Room Callout Safety:** Public room callouts must scrub metadata down to safe public fields only and should appear in recap helpers without exposing role-private information.
8. **Interrupted Run Continuity:** Interrupted run records must stay local-only, award no XP/mastery, preserve reconnect-policy review lines, and remain browseable through deterministic history filters.
9. **History Filter Determinism:** Profile history helpers should filter consistently by interruption, role, outcome, story tone, and communication density without mutating saved run truth.
10. **Review Packet Readability:** History/detail helpers should deterministically produce human-readable “why revisit” and continue-guidance text from stored run truth without creating a second replay model.
11. **Browser-State Stability:** Profile browser helpers should preserve the selected run and compare target across ordinary shell refreshes, falling back deterministically only when the selected run leaves the active context.
12. **Compare Target Contrast:** Compare helpers should stay inside the active filter/sort context and pick a deterministic, meaningfully contrasting peer run rather than a random adjacent entry.
13. **Home CTA Priority:** Home command-surface helpers should always expose one dominant next action, one supporting reason, and one optional secondary route based on current session truth.
14. **Voice Seam Honesty:** Voice helper output should remain session-aware and future-ready without implying transport or speaking indicators exist today.
15. **Helper-Only Review Signals:** Run-memory tuning helpers should deterministically expose strongest-run clusters, compare-digest dimensions, and interruption-recovery summaries without leaking that density into player-facing Home/Profile panels.

## Fairness & Readability Manual Playtest Goals
1. **Visual Interpretation Literacy:** Can players distinguish a forged artifact's faint visual trace anomaly from an environmental lighting engine cast shadow? Can players accurately track decay on footprints?
2. **Hazard Accountability:** Does a player feel they died resulting from their own platforming mistake (or an explicitly clever Veil nudge manipulation), rather than from an unfair network desync?
3. **Notebook Usability:** Can a player successfully log an "Alibi" tag via macro while jumping across a lethal chasm without suffering a mechanical disadvantage?
4. **Room Callout Literacy:** Can players use `Danger`, `Regroup`, and `Artifact` callouts while moving without confusing them for hard-proof blame markers?
5. **Reconnect Fallback:** When a client disconnects mid-run or tries to join an active run, do they land back in a useful lobby state with a clear next step instead of a dead-end failure?
6. **Interrupted Run Review:** After a disconnect, does the Profile tab surface the interrupted run, reconnect policy, callout summary, and zero-progression outcome clearly enough that players understand what to do next?
7. **History Browser Flow:** Can a player use the Profile tab filters and sorts to find interrupted, chaotic, or communication-heavy runs quickly and understand why the selected run is worth revisiting?
8. **Home Command Surface:** After a completed or interrupted run, does the Home tab make the strongest next action obvious within one glance?
9. **Large-Text Shell Quality:** Under large-text settings, do Home/Profile panels preserve hierarchy, CTA prominence, and selection clarity without collapsing into adjacent panels?
10. **Compare Usefulness:** When selecting a run in Profile, does the compare panel explain meaningful contrast instead of just repeating another run label?
11. **Communication Policy Clarity:** Do Home/Settings explain how callouts and future voice fit together without implying live voice transport exists?
12. **Run Browser Context:** Does the Profile compare panel explain why the selected run is worth reopening compared with the best in-context peer instead of just repeating adjacent labels?
13. **Home Density Discipline:** Do Home surfaces stay compact and action-first, with `Continue`, `RecentRuns`, and `RunDiagnostics` remaining short enough that Home does not turn into a second review pane?
14. **Honest Continuity Language:** Does the shell use regroup / wait-for-lobby / rejoin-later language without implying persistent party state or rematch reservation that the live session layer does not actually support?
