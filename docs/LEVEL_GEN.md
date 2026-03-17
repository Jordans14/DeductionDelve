# Level Generation

See also: [CRAWL_NETWORK_ARCHITECTURE](d:/DeductionDelve/docs/CRAWL_NETWORK_ARCHITECTURE.md), [PROTOCOL_STATES](d:/DeductionDelve/docs/PROTOCOL_STATES.md), [AI_INHABITANTS](d:/DeductionDelve/docs/AI_INHABITANTS.md), [MECHANICS](d:/DeductionDelve/docs/MECHANICS.md).

## Current Live Generation
The current repo generates deterministic room chains from a host seed and already includes authored branch-family context carried through:
- room type
- hazard type
- branch family
- protocol state
- doctrine family
- pressure profile
- symbolic anchor
- micro-plan markers

The live branch-family roster now includes:
- Watcher Steps
- Sundered Span
- Relay Hollows
- Grave Lattice
- Forge Veins
- Oath Terraces
- Murmur Warrens

## Current Live Delve Shaping
- [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd) computes a full Delve directive before run start.
- Delve now emits an explicit host-private `generation_contract` from that directive.
- [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd) carries that contract through the host-private run-start path.
- [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd) consumes the explicit `generation_contract` when building the room chain.
- [item_service.gd](d:/DeductionDelve/godot/src/items/item_service.gd) consumes the same narrow contract so room pressure and item ecology stay aligned.
- Host runtime consumers now use those same host-only control surfaces to shape extraction hold duration, ghost wake/speed/reach, and artifact noise cadence without widening any replicated payloads.
- This remains deterministic from seed plus session/profile inputs. It is not a runtime truth rewrite.

## Current Live Influence Lattice In Generation
- Topology remains owned by [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd), but branch-family weighting and room-type weighting now respond to dominant pressure verbs, pacing profile, convergence vs fragmentation pressure, and symbolic motifs.
- Room-type weighting and room risk also consume loop, witness, stalking, anomaly, rescue, and austerity pressure through the same deterministic generation owner path.
- Branch families now materially bias room mixes instead of only annotating branch context, and reduced protocol labels now apply stronger deterministic room-weight pressure without introducing a parallel runtime planner.
- Item spawning now consumes authored branch affinities and protocol affinities from the same room-chain truth so branch choice, protocol pressure, and item ecology stay aligned.
- Branch selection and room shaping now also read the public-safe Delve summary's dominant domains, archive tone, convergence axis, and item-ecology summary so route identity can deepen without widening any replicated payloads.
- Item weighting now deepens through the existing `branch_context` memory seeds, symbolic anchors, slot bands, and surface-summary lines already present on the room chain; no new replicated branch-context lane was added.
- Branch context now carries a bounded run-identity summary plus public-safe directive/surface lines so later owners can read pacing, motifs, and dominant authorship without receiving host-only internals.
- Pressure profiles now include pacing and pressure-grammar tags in addition to branch ideology, which makes authored cadence visible to later diagnostics without creating runtime intervention logic.

## Branch Ideology
Branch families represent pressure styles rather than mere biome names. Their authored context should inform:
- social pressure style
- challenge texture
- confrontation climate
- rescue climate
- burden pressure
- witness pressure
- route commitment
- regroup friction
- escape bandwidth
- symbolic place identity

## Current Live Visual Governance In Generation
- [room_builder.gd](d:/DeductionDelve/godot/src/gen/room_builder.gd) turns each room into a visual packet through [visual_governance.gd](d:/DeductionDelve/godot/src/visual/visual_governance.gd).
- Visual packets currently govern branch/protocol palette, symbol families, stagecraft flags, visual budgets, and background honesty rules.
- Doctrine-driven carvings, route cues, and stagecraft overlays now render through a dedicated visual-only room layer so motif expression stays mechanically inert.
- Symbolic motifs from the lattice can add bounded close-range symbol families and small pacing/pressure adjustments inside those same honesty and budget limits.
- Background layers must not contain reachable paths, interactables, artifacts, or informative labels.

## Crawl Network Direction
The finalized design extends the current room-chain model into a crawl network of run nodes, relay nodes, branch gates, echo chambers, and collapse zones. That is a future implementation phase and should extend the current deterministic generation owner path.

## Environmental Pressure
Rooms and branches should be interpretable as:
- standoff spaces
- burden corridors
- rescue chambers
- temptation routes
- ritual thresholds

The current implementation already threads some of that meaning through branch context, doctrine shaping, and visual packets. Future generation work should deepen those readings inside the same deterministic owner path.
