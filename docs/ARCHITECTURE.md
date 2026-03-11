# Architecture

## Module Responsibilities
- `godot/project.godot`: Global config.
- `godot/scenes/`: Core environments and major entity scenes (`Lobby.tscn`, `Game.tscn`, `Player.tscn`, `Evidence.tscn`).
- `godot/src/net/`: Strict host-authoritative networking, protocol handling, and state replication (`network_manager.gd`).
- `godot/src/run/`: Game state machine, extraction logic, event logging, and evidence services (`game_controller.gd`, `event_log.gd`).
- `godot/src/gen/`: Deterministic room and cavern generation bridging verticality with room scaling (`room_builder.gd`, `run_generator.gd`).
- `godot/src/roles/`: Private role assignment payloads and sabotage affordances (`role_service.gd`).
- `godot/src/items/`: Physics-enabled tools (ropes, bombs) and trace/synergy logic.
- `godot/src/product/`: Local-only persistence, progression, catalog, profile, codex, and cosmetic ownership services.
- `godot/config/`: Data-driven product and cosmetic catalog definitions validated at startup/test time.
- `godot/src/ui/`: Suspicion notebook, end-of-run timeline, and situational HUDs.
- `godot/src/entities/`: Complex state objects (Player rigs, physical Evidence, Hazards, and Environmental Clue Decals).

## System Boundaries
- **Game vs. Lobby:** The Lobby now acts as the product shell: peer discovery, seed assignment, profile surfaces, collection/codex browsing, cosmetic loadout selection, accessibility/settings toggles, and last-run review. The Game scene remains the run-time simulation owner.
- **Physical Clues vs. Logic:** Core logic handles collisions and state (e.g., an artifact is dropped); the visual layer algorithmically renders the *ambiguous physical traces* (e.g., footstep decals, dust trails, or lantern visibility radii) that players use to interpret those states. 
- **Run Truth vs. Product Truth:** The run writes deterministic local summary data at `run_ended`; profile/progression/codex services consume that summary locally and never alter host-authoritative run state.
- **Catalog Truth vs. Runtime Truth:** Product catalog data defines cosmetics, codex entries, mastery ladders, and achievement rules. Runtime code validates and consumes that catalog, but gameplay authority remains in the run/network modules.

## Determinism Boundaries
- **Strictly Deterministic from Seed:** Global cavern generation, artifact spawn locations, hazard configurations, and item tables are entirely locked to the Host's single run seed.
- **Run Sub-Streams:** Any randomness executed mid-run utilizes seed substreams mathematically derived from the central master seed, ensuring no diverging states.

## Authority Boundaries
- **Host Simulation Authority:** Player positioning, physical inventory parsing, hazard pulse states, and interaction validations (`pickup`, `steal`, `forge`) are uniquely owned and processed by the Host.
- **Client Prediction:** Clients predict local lateral motion and jumping for smooth visual feel but yield entirely to the Host's mathematical corrections during latency snaps.
- **Action Validation:** The Host validates physical coordinate proximity, room slots, one-carry limits, and role boundaries before accepting any client input.

## Replay/Debug Expectations
- Systemic actions log strictly to the `EventLog` autoload, forming the definitive, unalterable Source of Truth.
- All entries are timestamped using a deterministic `tick` counter and a monotonic `event_id`.
- Real-world wall-clock times are explicitly withheld to guarantee strict playback reproducibility.
- Local product services may derive diagnostics and retention summaries from run-end payloads, but those diagnostics are read-only interpretations and never rewrite event truth.

## Information Visibility and Secrecy Rules
- **Private Data:** Roles, notebook entries, local inventory intent, and precise sabotage confirmations (e.g., `forge` success) remain strictly on the local Client. The Host routes these securely via `rpc_id`.
- **Public Data:** Physical interactions, hazard state pulses, player positional telemetry, and environmental physical traces (footprints, blast marks).
- **Anonymized Data:** Environmental triggers originating from Veil sabotage are scrubbed (`actor_peer_id = -1`) ensuring the Public Data feed never mechanically breaks plausible deniability.
