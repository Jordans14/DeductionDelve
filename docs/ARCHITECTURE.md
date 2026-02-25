# Architecture

## Godot Project Layout
- `godot/project.godot`
- `godot/scenes/`
  - `Lobby.tscn`
  - `Game.tscn`
  - `TestRoom.tscn`
  - `TestRunner.tscn`
- `godot/src/`
  - `net/` networking peers, protocol, lobby state.
  - `run/` run state machine, seed ownership.
  - `gen/` room graph and seeded generation.
  - `roles/` role assignment/effects.
  - `items/` item definitions + synergy resolution.
  - `ui/` HUD, suspicion notebook, timeline.
  - `entities/` player, evidence, hazards.

## New Milestone 3 Modules
- `src/roles/role_service.gd`:
  - deterministic role assignment and private reveal payload builder.
- `src/run/evidence_service.gd`:
  - deterministic evidence spawn/signature logic and ownership validation helpers.
- `src/run/event_log.gd` (autoload `EventLog`):
  - authoritative timeline event storage and UI feed signal.
- `src/entities/evidence.gd` + `scenes/Evidence.tscn`:
  - physical evidence objects rendered in world and carried by players.

## Core State Flow
1. Boot -> Lobby scene.
2. Host sets transport and opens session.
3. Clients join and ready up.
4. Host chooses seed and sends `run_init`.
5. Game scene loads and constructs room layout from host payload.
6. Host drives authoritative state updates/events.

## Determinism Boundaries
- Deterministic:
  - Room selection/order from seed.
  - Spawn tables and initial placements from seed.
- Authoritative simulation:
  - Player state, item picks, artifact ownership.
- Non-deterministic but controlled:
  - Network latency/order handled by host truth and sequence numbers.

## Scene/Node Principles
- Keep nodes small and composable.
- Data-first definitions for roles/items/rooms.
- Event bus style signals for UI updates and timeline feed.

## Milestone 1 Scope
- Network lobby (host/join/ready/start).
- Multiplayer spawn in single test room.
- Basic movement sync with host authority.
- Status: implemented in current scaffold (`Lobby.tscn`, `Game.tscn`, `network_manager.gd`, `game_controller.gd`).

## Milestone 2 Scope
- Host-side seeded room chain generation.
- Client scene build from host room payload.
- Status: initial implementation complete via `run_generator.gd` and `room_builder.gd`.

## Milestone 3 Scope
- Hidden role assignment with per-client private reveal.
- Physical evidence lifecycle (spawn/pickup/drop/steal/forge).
- Veil sabotage action (hazard timing nudge) with timeline trace.
- Timeline foundation with public/private visibility metadata.
- Status: implemented in current iteration.
