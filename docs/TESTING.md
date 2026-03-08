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

## Fairness & Readability Manual Playtest Goals
1. **Visual Interpretation Literacy:** Can players distinguish a forged artifact's faint visual trace anomaly from an environmental lighting engine cast shadow? Can players accurately track decay on footprints?
2. **Hazard Accountability:** Does a player feel they died resulting from their own platforming mistake (or an explicitly clever Veil nudge manipulation), rather than from an unfair network desync?
3. **Notebook Usability:** Can a player successfully log an "Alibi" tag via macro while jumping across a lethal chasm without suffering a mechanical disadvantage?
