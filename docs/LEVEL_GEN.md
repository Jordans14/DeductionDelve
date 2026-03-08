# Level Generation

## Hybrid Grammar
Deduction Delve’s environments utilize a bespoke procedural pipeline requiring the tight, highly lethal vertical platforming logic of *Spelunky* mixed with the distinct, readable, and synergistically designed room encounters of *The Binding of Isaac*. Platforming is not optional visual flavor; traversing and overcoming traversal risk *is* the core challenge.

## The Cavern Pipeline
1. **Global Domain-Warping:** The run is anchored by a single, monolithic Host `run_seed`. Low-frequency noise fields shape organic "ant-farm" style cavern pathways to prevent rigid, predictable grid feelings.
2. **Chunk Categorization:** The total layout breaks down into distinct room slots derived mathematically as substreams of the main seed:
   - *Traversal Drops:* Massive vertical shafts necessitating ropes, anchored scaffolding drops, and safe one-way collision logic.
   - *Hazard Choke-points:* Dense, confined corridors populated with spikes, crushers, and timing gates.
   - *Evidence Pockets:* Highly treacherous dead-end enclaves containing primary deduction objectives.
3. **Architectural Scaffolding Insertion:** Instead of drawing flat, floating boxes, the generator algorithmically drops structural wooden buildings, casting dynamic "legs" directly downwards until they accurately impact the organic cave ground.
4. **Environmental Trace Canvas:** Levels are generated with visual layers intended for disruption—dust particles, dark corners for hiding, and surfaces capable of retaining physical blast marks or footprint decals to enhance social readability.

## Verticality & Traversal Risk
- Platforms, severe vertical jumps, and massive ledge falls are completely deliberate components of the generated geometry. 
- A hazard exists not merely as a damage zone, but deliberately placed where a player is structurally forced to land from a difficult jump. This guarantees that "grabbing the wrong ledge under pressure" or "an accidental trap execution" is always a highly plausible excuse.

## Reliability & Determinism Model
- All room geometries, internal platforms, interactive tools, weaponized hazards, and exact artifact coordinates resolve 100% deterministically from the central Host seed.
- Clients never compute the procedural noise topology locally. The Host computes the cavern mathematically and clients merely ingest the geometry, ensuring absolute collision parity across the entire network boundary.
