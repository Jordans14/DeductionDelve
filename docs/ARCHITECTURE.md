# Architecture

See also: [THE_DELVE_PROTOCOL](d:/DeductionDelve/docs/THE_DELVE_PROTOCOL.md), [CRAWL_NETWORK_ARCHITECTURE](d:/DeductionDelve/docs/CRAWL_NETWORK_ARCHITECTURE.md), [ARCHIVE_SYSTEM](d:/DeductionDelve/docs/ARCHIVE_SYSTEM.md), [NETWORKING](d:/DeductionDelve/docs/NETWORKING.md), [TESTING](d:/DeductionDelve/docs/TESTING.md).

## Repo Structure
- `godot/project.godot`: global Godot project configuration
- `godot/scenes/`: live scenes, including the current Lobby and Game shell/runtime split
- `godot/src/net/`: host-authoritative networking and session transport
- `godot/src/run/`: authoritative run state, event logging, extraction, evidence, and snapshot export
- `godot/src/gen/`: deterministic room and branch-context generation
- `godot/src/delve/`: AI Delve influence-lattice planning, constitutions, simulation, and tracing
- `godot/src/items/`: item definitions and additive narrative/item-ecology profiles
- `godot/src/visual/`: visual governance, shell symbols, room packet doctrine, and presentation safety
- `godot/src/product/`: local-only progression, profile, archive, framing, crawl continuity, and world memory
- `godot/src/ui/`: shell and in-run UI controllers
- `godot/src/tests/`: deterministic test runner and proof-adjacent validation
- `scripts/`: repo test and headless proof commands

## Status Legend
- `live and authoritative`: currently in use and authoritative for its layer
- `live but partial`: currently in use, but not yet the full finalized design target
- `scaffolded or early`: present in code, but narrow or incomplete
- `future-phase canon`: documented design target, not live implementation

## Narrative/Product Layer vs Run Truth Layer
This boundary is locked.

### Run Truth
Owned by the live run/network/event owners.
- authoritative movement
- hazard state
- artifact state
- role secrecy
- extraction outcomes
- event timeline

### Product Truth
Owned by the product/profile/archive/crawl/world-memory owners.
- local continuity
- archive comparison
- commentary and recap compression
- crawl identity
- world fascination
- cosmetic/progression identity

The product layer must remain:
- read-only relative to run truth
- deterministic from stored run facts plus local memory
- mechanically inert

The supporting doctrine layers must remain:
- AI Delve can read profile continuity, session context, and gameplay signals, then emit bounded directives for existing owners to consume. It does not own movement, hazards, role truth, or end-state authority.
- Visual governance can shape presentation budgets, symbol grammar, shell palettes, and background honesty. It does not change mechanics or leak truth.

## Current Live Owner Map
- Run/export owner: [game_controller.gd](d:/DeductionDelve/godot/src/run/game_controller.gd)
- Network/session owner: [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
- Generation owner: [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd), [room_builder.gd](d:/DeductionDelve/godot/src/gen/room_builder.gd)
- Constitution/compiler owner: [constitution_compiler.gd](d:/DeductionDelve/godot/src/gen/constitution_compiler.gd), [expedition_constitution_schema.gd](d:/DeductionDelve/godot/src/delve/constitution/expedition_constitution_schema.gd)
- Governance owner: [governance_service.gd](d:/DeductionDelve/godot/src/product/governance_service.gd)
- Experiment/learning owners: [delvemind_experiment_engine.gd](d:/DeductionDelve/godot/src/product/delvemind_experiment_engine.gd), [delvemind_learning_loop.gd](d:/DeductionDelve/godot/src/product/delvemind_learning_loop.gd)
- Item owner: [item_service.gd](d:/DeductionDelve/godot/src/items/item_service.gd)
- Role/deception owner: [role_service.gd](d:/DeductionDelve/godot/src/roles/role_service.gd)
- AI Delve owner: [delve_kernel.gd](d:/DeductionDelve/godot/src/delve/delve_kernel.gd), [world_model.gd](d:/DeductionDelve/godot/src/delve/world_model.gd), and supporting files under `godot/src/delve/`
- Civilization / contradiction / cookbook owners: [civilization_state_service.gd](d:/DeductionDelve/godot/src/product/civilization_state_service.gd), [contradiction_engine.gd](d:/DeductionDelve/godot/src/product/contradiction_engine.gd), [cookbook_fragment_service.gd](d:/DeductionDelve/godot/src/product/cookbook_fragment_service.gd)
- Visual governance owner: [visual_governance.gd](d:/DeductionDelve/godot/src/visual/visual_governance.gd)
- Product orchestration owner: [profile_service.gd](d:/DeductionDelve/godot/src/product/profile_service.gd)
- Run-interpretation owner: [run_story_diagnostics.gd](d:/DeductionDelve/godot/src/product/run_story_diagnostics.gd)
- Crawl continuity owner: [crawl_service.gd](d:/DeductionDelve/godot/src/product/crawl_service.gd)
- Framing/broadcast owner: [framing_service.gd](d:/DeductionDelve/godot/src/product/framing_service.gd)
- Archive owner: [archive_service.gd](d:/DeductionDelve/godot/src/product/archive_service.gd)
- World-memory owner: [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd)
- Identity/progression support owners: [profile_identity_state.gd](d:/DeductionDelve/godot/src/product/profile_identity_state.gd), [profile_progression.gd](d:/DeductionDelve/godot/src/product/profile_progression.gd)
- Directive inspection/proof owners: [delve_directive_inspector.gd](d:/DeductionDelve/godot/src/delve/delve_directive_inspector.gd), [test_runner.gd](d:/DeductionDelve/godot/src/tests/test_runner.gd)
- Shell owner: [lobby_controller.gd](d:/DeductionDelve/godot/src/ui/lobby_controller.gd)

## Current-State Map
- Run truth: `live and authoritative`
  Owners: [game_controller.gd](d:/DeductionDelve/godot/src/run/game_controller.gd), [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
  Scope: movement, hazards, extraction, artifacts, item use, ghost pressure, public/private event logging, run export.
- Networking and session: `live and authoritative`
  Owner: [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
  Scope: ENet host authority, lobby readiness, sanitized public cards, run start payloads, role secrecy, reduced live protocol-state labels.
- Generation: `live and authoritative`
  Owners: [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd), [room_builder.gd](d:/DeductionDelve/godot/src/gen/room_builder.gd)
  Scope: deterministic room chain generation, branch context, doctrine/protocol threading into rooms, visual packet consumption.
- Constitution compilation and public-safe summary path: `live and authoritative`
  Owners: [constitution_compiler.gd](d:/DeductionDelve/godot/src/gen/constitution_compiler.gd), [expedition_constitution_schema.gd](d:/DeductionDelve/godot/src/delve/constitution/expedition_constitution_schema.gd)
  Scope: canonical `constitution_summary` / `expedition_constitution_summary`, `compile_metadata`, `fairness_bounds`, `review_surface`, `compiler_trace`, explicit host-private `generation_contract`, and compatibility support for legacy `directive_summary` readers.
- Governance and review surfaces: `live and authoritative`
  Owner: [governance_service.gd](d:/DeductionDelve/godot/src/product/governance_service.gd)
  Scope: activation state, safe-mode lines, review surfaces, hook sets, compression profiles, saturation reports, and forensic action snapshots.
- Experiment and learning: `live and authoritative` for post-run and compile-safe surfaces
  Owners: [delvemind_experiment_engine.gd](d:/DeductionDelve/godot/src/product/delvemind_experiment_engine.gd), [delvemind_learning_loop.gd](d:/DeductionDelve/godot/src/product/delvemind_learning_loop.gd)
  Scope: live experiment and hypothesis state, public-safe experiment lines, continuity learning, and compiler-facing learning guidance. Not live: runtime authority, legality mutation, or adaptive client authority.
- Items and loadout ecology: `live and authoritative`
  Owner: [item_service.gd](d:/DeductionDelve/godot/src/items/item_service.gd)
  Scope: deterministic spawn generation, build identity modeling, synergy signals, protocol-aware loadout interpretation.
- Roles and deception: `live and authoritative`
  Owner: [role_service.gd](d:/DeductionDelve/godot/src/roles/role_service.gd)
  Scope: role assignment, secrecy payloads, role-aligned outcomes.
- Product continuity: `live and authoritative`
  Owners: [profile_service.gd](d:/DeductionDelve/godot/src/product/profile_service.gd), [run_story_diagnostics.gd](d:/DeductionDelve/godot/src/product/run_story_diagnostics.gd), [crawl_service.gd](d:/DeductionDelve/godot/src/product/crawl_service.gd), [framing_service.gd](d:/DeductionDelve/godot/src/product/framing_service.gd), [archive_service.gd](d:/DeductionDelve/godot/src/product/archive_service.gd), [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd)
  Scope: local continuity, framing, archive cases, crawl heat, world memory, shell-safe summaries.
- AI Delve: `live and authoritative`
  Owners: [delve_kernel.gd](d:/DeductionDelve/godot/src/delve/delve_kernel.gd), [world_model.gd](d:/DeductionDelve/godot/src/delve/world_model.gd), [doctrine_engine.gd](d:/DeductionDelve/godot/src/delve/doctrine_engine.gd), [delve_simulator.gd](d:/DeductionDelve/godot/src/delve/delve_simulator.gd), [causal_audit.gd](d:/DeductionDelve/godot/src/delve/causal_audit.gd)
  Scope: builds pre-run Delve shaping from profile continuity, session context, gameplay snapshot, and seed; emits host-private planning state plus the explicit `generation_contract`; contributes to the canonical public-safe constitution summary path consumed by runtime, product, and shell layers.
  Live consumers: [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd), [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd), [item_service.gd](d:/DeductionDelve/godot/src/items/item_service.gd), [run_story_diagnostics.gd](d:/DeductionDelve/godot/src/product/run_story_diagnostics.gd), [framing_service.gd](d:/DeductionDelve/godot/src/product/framing_service.gd), [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd)
  Not live: continuous runtime orchestration, inhabitant roster control, product authority, a second GM layer.
- Visual governance: `live and authoritative` for presentation
  Owner: [visual_governance.gd](d:/DeductionDelve/godot/src/visual/visual_governance.gd)
  Live consumers: [room_builder.gd](d:/DeductionDelve/godot/src/gen/room_builder.gd), [lobby_controller.gd](d:/DeductionDelve/godot/src/ui/lobby_controller.gd), [game_controller.gd](d:/DeductionDelve/godot/src/run/game_controller.gd), [player.gd](d:/DeductionDelve/godot/src/entities/player.gd), [item_pickup.gd](d:/DeductionDelve/godot/src/entities/item_pickup.gd), [evidence.gd](d:/DeductionDelve/godot/src/entities/evidence.gd), [crusher.gd](d:/DeductionDelve/godot/src/entities/crusher.gd), [door.gd](d:/DeductionDelve/godot/src/items/door.gd)
  Scope: motion hierarchy, shell title/symbols/palette, branch/protocol visual packets, item/evidence/carrier styling, background honesty, budget validation.
- Distributed meta-dynamics and world-memory interpretation: `live but partial`
  Owners: [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd), [world_model.gd](d:/DeductionDelve/godot/src/delve/world_model.gd), [profile_progression.gd](d:/DeductionDelve/godot/src/product/profile_progression.gd), [profile_identity_state.gd](d:/DeductionDelve/godot/src/product/profile_identity_state.gd), [profile_service.gd](d:/DeductionDelve/godot/src/product/profile_service.gd), [archive_service.gd](d:/DeductionDelve/godot/src/product/archive_service.gd), [crawl_service.gd](d:/DeductionDelve/godot/src/product/crawl_service.gd), [governance_service.gd](d:/DeductionDelve/godot/src/product/governance_service.gd)
  Scope: distributed fascination, fatigue, cultural gravity, epistemic-order, interpretation-network, public-identity, crawl-identity, compression, and saturation signals. This coverage is real but remains distributed across existing owners rather than a standalone meta-dynamics subsystem.
- Protocol states: `live but partial`
  Owner: [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
  Scope: reduced live labels (`Expedition`, `Fracture`, `Intimate`, `Exposure`) derived from active peer count and consumed by gameplay modeling, Delve doctrine, generation, item ecology, and visual governance.
  Future-phase only: relay routing, recombination, full population-adaptive crawl topology.
- AI inhabitants and bounded ecology: `live but partial`
  Live state: bounded host-authoritative ghost, anomaly echo, predator rush, and protocol-watch differentiation inside the one ecology path owned by [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd) and consumed by [game_controller.gd](d:/DeductionDelve/godot/src/run/game_controller.gd)
  Future-phase canon: broader predator/echo/protocol-agent rosters beyond the current bounded ecology path, as tracked in [ROADMAP](d:/DeductionDelve/docs/ROADMAP.md) and [AI_INHABITANTS](d:/DeductionDelve/docs/AI_INHABITANTS.md)

## Shell Ownership
The shell remains unified.
- Lobby is still the shell owner.
- Collection remains the Collection path.
- Codex has evolved into Archive on the same path.
- No second archive/browser path should be added.

## Key Live Data Flows
- Host session state plus local profile continuity feed [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd), which builds a gameplay snapshot, computes the live expedition constitution before run start, and emits the explicit host-private `generation_contract` plus the canonical public-safe `constitution_summary`.
- The host keeps the full expedition constitution and run-identity trace locally for generation, item shaping, host-local runtime inspection, and balancing, while clients receive only the canonical public-safe constitution summary.
- Legacy `directive_summary` / `delve_directive_summary` remain compatibility aliases of the canonical public-safe constitution summary rather than a competing truth path.
- The public-safe constitution summary can include limited authored carryover such as dominant minds, dominant forces/domains, pacing, pressure grammar, motifs, item/group/archive summaries, convergence axis, and line-level surface summary strings. It must never include host-only `run_identity`, `mind_balance`, or clamped/strongest control-surface internals.
- [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd) keeps the explicit `generation_contract` on the host-private run-start path.
- [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd) consumes that explicit `generation_contract` as its single Delve-facing generation boundary.
- [item_service.gd](d:/DeductionDelve/godot/src/items/item_service.gd) consumes the same narrow contract for item ecology without becoming a second balance owner.
- [run_story_diagnostics.gd](d:/DeductionDelve/godot/src/product/run_story_diagnostics.gd) and [framing_service.gd](d:/DeductionDelve/godot/src/product/framing_service.gd) consume stored run facts plus the public-safe doctrine/governance carryover for shell/archive output.
- [visual_governance.gd](d:/DeductionDelve/godot/src/visual/visual_governance.gd) governs how rooms, shell surfaces, and entity presentations look, but it never writes gameplay state.

## Influence Lattice Contract
- The lattice is deterministic from run seed, session context, expedition composition, and continuity state.
- It authors conditions through weighting, biasing, cadence shaping, and motif selection only.
- Domain influence weights are part of the live owner path: they do not create new facts by themselves, but they now modulate the intensity of the bounded control-surface projection so mind-role composition is not trace-only.
- It must never spawn arbitrary runtime facts, reveal hidden truth layers, or widen client authority.
- Each major lattice decision must affect at least two gameplay-facing systems and one interpretive signal, or it should not exist as live logic.

## Determinism and Proof
- `run_tests.ps1` validates deterministic logic and shell-safe helper behavior.
- `run_headless_proof.ps1` validates multiplayer/proof-lane safety.
- Narrative layers must never alter report facts or host-authoritative gameplay state.

## Design Doctrine vs Current Implementation
The canonical design target is documented in [THE_DELVE_PROTOCOL](d:/DeductionDelve/docs/THE_DELVE_PROTOCOL.md) and related canon docs.

The current live implementation already includes:
- host-authoritative seeded runs
- branch-family context in generation
- live AI Delve directive planning and public-safe doctrine carryover
- live visual governance and background honesty validation
- product-shell continuity and Archive behavior
- deterministic narrative diagnostics, crawl continuity, and world memory

Future phases described in the canon docs must continue extending the same owner tree rather than replacing it.
