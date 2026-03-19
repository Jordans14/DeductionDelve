# Phase 9 Execution Artifact: Hardening, Proof Completion, Rollback / Quarantine Operations

## Scope
- Phase executed: `Phase 9 — Hardening, Proof Completion, Rollback / Quarantine Operations`
- Frozen-plan status: preserved with one repo-truth-local contract correction
- Shadow owners introduced: none
- Parallel authority centers introduced: none

## Updated Owner / Contract Matrix

| Doctrine Domain | Authoritative Owner Files | Subordinate Consumer Files | Extend vs Add | Contracts / Carriers Implemented |
|---|---|---|---|---|
| Runtime forensic bundle / telemetry hardening | `godot/src/run/game_controller.gd` | `godot/src/tests/test_runner.gd`, `godot/src/product/profile_service.gd` | Extend | `ForensicBundleV1` top-level hardening fields `active_regime_ids`, `active_lifecycle_state_ids`, `equipped_modulation_loadout`, `encounter_manifest`, `apex_manifest`, `local_aftermath`, `world_aftermath_refs`, `explanation_packet_outputs`, `fairness_triggers`, `dignity_triggers`, `dominant_strategy_strain`, `experiment_outcomes`, `rollback_action`, `quarantine_action` |
| Governance action hardening | `godot/src/product/governance_service.gd` | `godot/src/run/game_controller.gd`, `godot/src/product/profile_service.gd`, `godot/src/tests/test_runner.gd` | Extend | `build_forensic_action_snapshot(...)`, bounded `rollback_action`, `quarantine_action`, `fairness_triggers`, `dignity_triggers`, `dominant_strategy_strain` |
| Post-run forensic persistence companion | `godot/src/product/profile_service.gd` | `godot/src/tests/test_runner.gd` | Extend | `forensic_bundle_header`, `world_memory_snapshot_hash`, persisted post-run governance-action digest on `last_run` and `run_history` |

## Files Touched
- `godot/src/run/game_controller.gd`
- `godot/src/product/governance_service.gd`
- `godot/src/product/profile_service.gd`
- `godot/src/tests/test_runner.gd`

## Schema / Config Changes Summary
- No schema or config files changed in Phase 9.
- The phase was completed by hardening the existing runtime export path and the existing profile persistence consumer.

## Contracts Implemented

### Runtime Bundle / Telemetry Hardening
- Implemented in `godot/src/run/game_controller.gd`
- Extended telemetry summary with:
  - `active_regime_ids`
  - `active_lifecycle_state_ids`
  - `encounter_manifest_ids`
  - `apex_manifest_ids`
  - `fairness_trigger_ids`
  - `dignity_trigger_ids`
  - `rollback_action`
  - `quarantine_action`
- Extended top-level forensic bundle with:
  - `active_regime_ids`
  - `active_lifecycle_state_ids`
  - `equipped_modulation_loadout`
  - `encounter_manifest`
  - `apex_manifest`
  - `local_aftermath`
  - `world_aftermath_refs`
  - `explanation_packet_outputs`
  - `fairness_triggers`
  - `dignity_triggers`
  - `dominant_strategy_strain`
  - `experiment_outcomes`
  - `rollback_action`
  - `quarantine_action`

### Governance Action Snapshot
- Implemented in `godot/src/product/governance_service.gd`
- Added:
  - `build_forensic_action_snapshot(governance_state)`
  - compact `rollback_action`
  - compact `quarantine_action`
  - `fairness_triggers`
  - `dignity_triggers`
  - `dominant_strategy_strain`
- This remains on the existing governance owner and is consumed by the runtime export path and the post-run profile persistence layer.

### Post-Run Forensic Persistence Companion
- Implemented in `godot/src/product/profile_service.gd`
- Added:
  - `world_memory_snapshot_hash`
  - `forensic_bundle_header`
  - persisted `rollback_action`
  - persisted `quarantine_action`
  - persisted `fairness_trigger_ids`
  - persisted `dignity_trigger_ids`
  - persisted `dominant_strategy_strain`
  - persisted `experiment_outcomes`
- These are stored on:
  - `last_run`
  - `run_history`
- This preserves the canonical runtime-authored bundle while attaching the post-run continuity digest on the existing profile owner.

## Tests Added / Updated
- `godot/src/tests/test_runner.gd`
  - added `_test_phase9_forensic_bundle_hardening_contract(...)`
  - added `_test_phase9_profile_forensic_persistence_and_world_memory_hash(...)`
- The new tests assert:
  - telemetry summary exposes phase-9 hardening fields
  - forensic bundles expose the hardened top-level fields
  - governance action snapshots feed rollback/quarantine/fairness/dignity outputs
  - profile persistence stores `world_memory_snapshot_hash` and the forensic bundle header without creating a second replay owner

## Telemetry Fields Added / Updated
- `TelemetrySummary`
  - `active_regime_ids`
  - `active_lifecycle_state_ids`
  - `encounter_manifest_ids`
  - `apex_manifest_ids`
  - `fairness_trigger_ids`
  - `dignity_trigger_ids`
  - `rollback_action`
  - `quarantine_action`
- `ForensicBundleV1`
  - all phase-9 hardening fields listed above
- `Profile last_run / run_history`
  - `world_memory_snapshot_hash`
  - `forensic_bundle_header`

## Governance / Fairness Checks Added / Updated
- The canonical runtime export now carries bounded fairness, dignity, rollback, and quarantine identifiers through the existing bundle path.
- Governance action summaries remain read-only reflections of the existing governance state and do not widen authority.
- Post-run world-memory hashing was attached only on the existing profile continuity owner and not pushed back into the runtime export as a second authoritative bundle path.

## Verification
- Deterministic suite:
  - `scripts/run_tests.ps1` passed
- Proof path:
  - `scripts/run_headless_proof.ps1` passed
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

## Risk Register Delta
- Reduced rollback / quarantine audit ambiguity by surfacing bounded action snapshots on the canonical export path.
- Reduced forensic incompleteness risk by hardening the bundle with the already-live market / encounter / apex / aftermath / experiment carriers.
- Reduced continuity-audit gap by storing a post-run `world_memory_snapshot_hash` on the existing profile owner.
- Residual bounded risk:
  - runtime bundles cannot directly author post-run continuity mutations that only exist after profile services apply them
  - this is mitigated by the persisted profile companion and documented below as a repo-truth-local correction

## Repo-Truth Correction
- Disproven assumption:
  - the frozen Phase 9 wording assumed `world_memory_snapshot_hash` could be authored directly inside the runtime-owned forensic bundle
- Repo truth that disproved it:
  - `godot/src/run/game_controller.gd` emits the canonical bundle before `godot/src/product/profile_service.gd` applies post-run world-memory mutations
  - the runtime export seam does not own post-run continuity state
- Minimal correction made:
  - the canonical runtime bundle remained authoritative for runtime-known fields
  - `world_memory_snapshot_hash` was persisted as a post-run forensic companion on the existing profile owner in `godot/src/product/profile_service.gd`
  - no second replay/export owner was introduced
