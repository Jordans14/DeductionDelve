# Roadmap

## Milestone 1 (Current)
- Repo + docs baseline.
- Godot boot to lobby.
- Host/join and multiplayer spawn in test room.
- Basic authoritative movement sync.
- Status: complete in this iteration.

## Milestone 2 (Current Turn Start)
- Seeded run generation on host.
- Client-side rendering from host-provided room chain.
- Determinism smoke test tooling.
- Status: initial version complete in this iteration.

## Milestone 3
- Hidden role assignment (Warden, Veil, Scavenger).
- Evidence artifacts: spawn/pickup/drop/steal.
- At least one sabotage mechanic framed as accident.
- Timeline event feed foundation for reconstruction.
- Status: core implementation complete in current iteration.

## Milestone 4
- Item system with tags + modifiers.
- 15-25 items and at least 5 notable synergies.
- Deception-surface effects (noise, visibility, traces).

## Milestone 5
- Suspicion notebook UI.
- End-of-run timeline and role reveal summary.
- Playable vertical slice with extraction/wipe end conditions.

## Milestone 6: Spelunky-style Core Platforming & Character Rig
- Replace flat single-polygon player with animated segmented limbs / refined geometry.
- Add advanced platforming metrics (coyote time, jump buffer, variable jump height).
- Add responsive player particles (dust trails, jump puffs).

## Milestone 7: Binding of Isaac-style Procedural Rooms
- Refactor room generation to include platforms, gaps, and varied height terrain.
- Use composed polygon obstacles rather than single floor rectangles.
- Implement camera transition bounds per-room matching room coordinates.

## Milestone 8: Lethal Hazards & Isaac-style Health Systems
- Add spikes, dropping blocks, and basic traps inside the procedural rooms.
- Add a 3-heart health system for players with death/spectator states.
- Connect sabotage items to overdrive these traps on command.

## Milestone 9: Active Physics & Visual Polish
- Use RigidBody2D logic for dropped items and evidence so they bounce and react to terrain.
- Add 2D dynamic point lights to players, items, and hazards with shadow-casting terrain.
- Add screen-shake for heavy impacts and hazard triggers.

## Milestone 10: Gameplay Loop Completion & The "Warden" Entity
- Add a persistent chase entity or timer-based stressor if players idle too long.
- Connect health, death, and extraction mechanics to finalize the battle-tested roguelite loop.

## Post-Slice
- Dedicated server option.
- WebSocket relay path and web-client compatibility pass.
- Expanded biomes, role roster, and meta progression.
