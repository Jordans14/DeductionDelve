# Architecture

## Module Responsibilities
- `godot/project.godot`: Global config.
- `godot/scenes/`: Core environments and major entity scenes (`Lobby.tscn`, `Game.tscn`, `Player.tscn`, `Evidence.tscn`).
- `godot/src/net/`: Strict host-authoritative networking, protocol handling, and state replication (`network_manager.gd`).
- `godot/src/run/`: Game state machine, extraction logic, event logging, and evidence services (`game_controller.gd`, `event_log.gd`).
- `godot/src/gen/`: Deterministic room and cavern generation bridging verticality with room scaling (`room_builder.gd`, `run_generator.gd`).
- `godot/src/roles/`: Private role assignment payloads and sabotage affordances (`role_service.gd`).
- `godot/src/items/`: Physics-enabled tools (ropes, bombs) and trace/synergy logic.
- `godot/src/ui/`: Suspicion notebook, end-of-run timeline, and situational HUDs.
- `godot/src/entities/`: Complex state objects (Player rigs, physical Evidence, Hazards, and Environmental Clue Decals).

## System Boundaries
- **Game vs. Lobby:** The Lobby orchestrates peer discovery and seed assignment. Over upon transition to the Game scene, which drives physics and simulation.
- **Physical Clues vs. Logic:** Core logic handles collisions and state (e.g., an artifact is dropped); the visual layer algorithmically renders the *ambiguous physical traces* (e.g., footstep decals, dust trails, or lantern visibility radii) that players use to interpret those states. 

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

## Information Visibility and Secrecy Rules
- **Private Data:** Roles, notebook entries, local inventory intent, and precise sabotage confirmations (e.g., `forge` success) remain strictly on the local Client. The Host routes these securely via `rpc_id`.
- **Public Data:** Physical interactions, hazard state pulses, player positional telemetry, and environmental physical traces (footprints, blast marks).
- **Anonymized Data:** Environmental triggers originating from Veil sabotage are scrubbed (`actor_peer_id = -1`) ensuring the Public Data feed never mechanically breaks plausible deniability.
