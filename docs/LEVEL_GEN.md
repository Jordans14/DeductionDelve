# Level Generation

## Run Structure
- One biome in vertical slice.
- 12 room variants defined in current scaffold; run draws 8 rooms for the chain payload.
- Branching limited to one optional side room for first slice readability.

## Room Grammar
- Room sockets: `left`, `right`, `up`, `down`.
- Types:
  - Traversal room.
  - Hazard room.
  - Encounter room.
  - Evidence cache room.
  - Recovery/shop room.
- Constraints:
  - Never place two high-lethality hazards back-to-back early.
  - Ensure at least one safe regroup space every 3 rooms.

## Seed Strategy
- Host generates `run_seed` in lobby.
- Host/server resolves room order, hazard variants, item spawns, artifact spawns.
- Clients receive concrete layout payload; clients do not roll gameplay RNG.
- Milestone 3 implementation: evidence artifacts spawn deterministically from run seed + room slots.

## Scaling
- Deeper rooms increase hazard complexity, not only damage.
- Evidence spawn frequency decays slightly late-run to increase contest pressure.

## Nondeterminism Controls
- Central RNG service with explicit call sites.
- Stable iteration order for spawn lists.
- Replayable generation log for debug/seed tests.
- Hazard readability indicator timing is client-visual only and not part of authoritative generation or simulation.
