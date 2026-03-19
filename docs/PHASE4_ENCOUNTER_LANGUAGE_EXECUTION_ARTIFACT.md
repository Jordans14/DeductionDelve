# Phase 4 Execution Artifact

## Freeze Status
- Frozen-spec rule preserved.
- No repo-truth correction was required for Phase 4 owner or contract assumptions.
- No parallel authority centers were introduced for combat, replay, continuity, aftermath, or governance.

## Updated Owner / Contract Matrix

### Combat Encounter Language
- Authoritative owners:
  - [constitution_compiler.gd](d:/DeductionDelve/godot/src/gen/constitution_compiler.gd)
  - [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd)
  - [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
  - [game_controller.gd](d:/DeductionDelve/godot/src/run/game_controller.gd)
  - [event_log.gd](d:/DeductionDelve/godot/src/run/event_log.gd)
  - [expedition_constitution_schema.gd](d:/DeductionDelve/godot/src/delve/constitution/expedition_constitution_schema.gd)
- Subordinate consumers:
  - [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd)
  - [run_story_diagnostics.gd](d:/DeductionDelve/godot/src/product/run_story_diagnostics.gd)
  - [framing_service.gd](d:/DeductionDelve/godot/src/product/framing_service.gd)
  - [test_runner.gd](d:/DeductionDelve/godot/src/tests/test_runner.gd)
- Contracts established:
  - constitution `encounter_language_profile`
  - constitution `encounter_manifest`
  - generation-surface `encounter_routing`
  - public-summary `encounter_lines`
  - public-summary `encounter_manifest_ids`
  - public-summary `encounter_intent_ids`
  - public-summary `encounter_topology_ids`
  - run-state `active_encounter_state`
  - run-state `encounter_history`
  - run-record `encounter_manifest`
  - forensic bundle extension `phase4_encounter_language`
- Acceptance result:
  - encounter language now compiles through the existing constitution and generation owners
  - runtime ecology materializes active encounter state on the current network/run authority path
  - encounter data exports through the canonical run/export seam instead of a detached combat system

### Expedition-First Encounter Anchors
- Authoritative owners:
  - [constitution_compiler.gd](d:/DeductionDelve/godot/src/gen/constitution_compiler.gd)
  - [run_generator.gd](d:/DeductionDelve/godot/src/gen/run_generator.gd)
  - [expedition_constitution_schema.gd](d:/DeductionDelve/godot/src/delve/constitution/expedition_constitution_schema.gd)
- Subordinate consumers:
  - [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
  - [event_log.gd](d:/DeductionDelve/godot/src/run/event_log.gd)
  - [test_runner.gd](d:/DeductionDelve/godot/src/tests/test_runner.gd)
- Contracts established:
  - fixed anchor set `custody_pressure`, `route_pressure`, `regroup_pressure`, `extraction_pressure`, `evidence_pressure`, `burden_pressure`
  - encounter manifest field `anchored_pressures`
  - generation routing field `anchored_pressures`
  - compiler validation for non-empty, allowed-only anchor sets
  - branch-context `encounter_preview`
  - branch-context `pressure_profile` encounter anchor carry-through
- Acceptance result:
  - every compiled encounter continues to be tied to expedition pressure
  - no detached action-only encounter path was introduced

### Pathology Architecture
- Authoritative owners:
  - [constitution_compiler.gd](d:/DeductionDelve/godot/src/gen/constitution_compiler.gd)
  - [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
  - [run_state.gd](d:/DeductionDelve/godot/src/run/run_state.gd)
  - [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd)
  - [expedition_mutation_engine.gd](d:/DeductionDelve/godot/src/run/expedition_mutation_engine.gd)
  - [expedition_constitution_schema.gd](d:/DeductionDelve/godot/src/delve/constitution/expedition_constitution_schema.gd)
- Subordinate consumers:
  - [game_controller.gd](d:/DeductionDelve/godot/src/run/game_controller.gd)
  - [event_log.gd](d:/DeductionDelve/godot/src/run/event_log.gd)
  - [test_runner.gd](d:/DeductionDelve/godot/src/tests/test_runner.gd)
- Contracts established:
  - constitution `pathology_profile`
  - constitution `pathology_state`
  - public-summary `active_pathology_ids`
  - public-summary `pathology_lines`
  - run-state `pathology_state`
  - world-memory `pathology_memory_state`
  - world-memory `encounter_memory_state`
- Acceptance result:
  - live ecology species now map into declarative pathology families without replacing the existing authority path
  - runtime ecology updates shared pathology state through the existing run state only
  - world memory persists Phase 4 encounter/pathology residue without adding a new memory owner

### Runtime Mutation / Trace Integration
- Authoritative owners:
  - [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd)
  - [expedition_mutation_engine.gd](d:/DeductionDelve/godot/src/run/expedition_mutation_engine.gd)
  - [event_log.gd](d:/DeductionDelve/godot/src/run/event_log.gd)
- Subordinate consumers:
  - [game_controller.gd](d:/DeductionDelve/godot/src/run/game_controller.gd)
  - [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd)
- Contracts established:
  - `species_escalation` mutations now carry `encounter_id`, `intent_id`, `topology_id`, `anchored_pressures`, `pathology_family_ids`
  - encounter-facing event-log helper `encounter_events()`
  - gameplay snapshot fields `active_pathology_ids` and `active_encounter_state`
- Acceptance result:
  - Phase 4 encounter pressure remains visible through existing mutation and event logging seams
  - no shadow trace or replay path was introduced

## Schema / Config Changes Summary
- [constitution_schema.json](d:/DeductionDelve/godot/config/constitution_schema.json)
  - added `encounter_language_profile`, `encounter_manifest`, `pathology_profile`, and `pathology_state` to required constitution sections
  - added `encounter_routing` to required generation-surface keys
  - added Phase 4 symbolic/public summary keys:
    - `active_pathology_ids`
    - `pathology_lines`
    - `encounter_lines`
    - `encounter_manifest_ids`
    - `encounter_intent_ids`
    - `encounter_topology_ids`

## Tests Added / Updated
- Added:
  - `_test_phase4_compiler_and_constitution_encounter_contract`
  - `_test_phase4_generation_contract_and_branch_context`
  - `_test_phase4_runtime_ecology_encounter_state`
  - `_test_phase4_world_memory_encounter_persistence`
- Updated:
  - generation-contract narrowing expectation now includes `encounter_routing`
  - Phase 4 branch-context test now reads the nested `branch_context` payload returned by the existing room-generation seam
  - Phase 4 runtime ecology test now passes a typed `Array[int]` into `run_state.set_run()`
- Verification run:
  - first `scripts/run_tests.ps1` pass timed out at 184s without reporting a concrete assertion failure
  - reran `scripts/run_tests.ps1` with a longer timeout and it passed
  - `scripts/run_headless_proof.ps1` passed

## Telemetry Fields Added / Updated
- Additive run-record fields:
  - `encounter_manifest`
  - `pathology_profile`
  - `pathology_state`
  - `active_encounter_state`
  - `encounter_history`
- Additive telemetry-summary fields:
  - `active_encounter_id`
  - `active_pathology_count`
  - `encounter_history_count`
- Additive forensic-bundle fields under `bundle_extensions.phase4_encounter_language`:
  - `encounter_manifest_ids`
  - `encounter_intent_ids`
  - `encounter_topology_ids`
  - `active_pathology_ids`
  - `active_encounter_state`
  - `encounter_history`
  - `encounter_manifest`
  - `pathology_profile`
  - `pathology_state`
- Additive world-memory fields:
  - `pathology_memory_state`
  - `encounter_memory_state`

## Governance / Fairness Checks Added / Updated
- Compiler validation now rejects encounter definitions without at least one allowed expedition-pressure anchor.
- Encounter/public summary normalization stays additive and deterministic inside the existing constitution schema owner.
- Runtime ecology updates encounter/pathology state only through [run_state.gd](d:/DeductionDelve/godot/src/run/run_state.gd) and the canonical event/mutation path.
- No detached combat scoring, loot ladder, XP rail, or second export path was introduced.
- Mutation tracing now preserves public/private trace classes inside the existing mutation engine rather than adding parallel combat telemetry.

## Risk Register Delta
- Detached-combat risk reduced:
  - encounter compilation, runtime execution, and export all stay on existing generation/network/run owners
- Expedition-anchor drift risk reduced:
  - compiler validation now enforces non-empty allowed-only anchor sets
- Readability risk increased slightly but bounded:
  - encounter and pathology summary lines add public-surface pressure language, but compression and deterministic summary limits remain in force
- Continuity duplication risk controlled:
  - world-memory encounter/pathology persistence was added to the existing continuity owner only

## Repo-Truth Correction Status
- No frozen-plan owner or contract correction was required.
- Two local implementation consistency fixes were required before the phase closed:
  - [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd): renamed a reserved local identifier in the new pathology-pressure loop so the script parsed cleanly
  - [expedition_constitution_schema.gd](d:/DeductionDelve/godot/src/delve/constitution/expedition_constitution_schema.gd): added the missing `_merge_limited()` helper already implied by the new summary-merging logic
