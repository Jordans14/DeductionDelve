# Phase 8 Execution Artifact: Legacy, Reentry, Institutional Pressure, Social Resilience

## Scope
- Phase executed: `Phase 8 — Legacy, Reentry, Institutional Pressure, Social Resilience`
- Frozen-plan status: preserved
- Repo-truth correction required: none
- Shadow owners introduced: none
- Parallel authority centers introduced: none

## Updated Owner / Contract Matrix

| Doctrine Domain | Authoritative Owner Files | Subordinate Consumer Files | Extend vs Add | Contracts / Carriers Implemented |
|---|---|---|---|---|
| Quiet play / social resilience diagnostics | `godot/src/product/run_story_diagnostics.gd` | `godot/src/product/profile_service.gd`, `godot/src/product/crawl_service.gd`, `godot/src/product/world_memory_service.gd`, `godot/src/product/civilization_state_service.gd`, `godot/src/product/archive_service.gd`, `godot/src/product/framing_service.gd`, `godot/src/tests/test_runner.gd` | Extend | `quiet_play_signals`, `meaningful_non_action`, `social_safety_flags`, `reputation_band`, `institutional_pressure_surface`, `continuity_burden_score` |
| Legacy / reentry continuity | `godot/src/product/profile_service.gd` | `godot/src/product/crawl_service.gd`, `godot/src/product/world_memory_service.gd`, `godot/src/product/archive_service.gd`, `godot/src/product/framing_service.gd`, `godot/src/tests/test_runner.gd` | Extend | `legacy_tracks`, `reentry_hooks`, `last_run.legacy_track`, `last_run.reentry_hook`, `history.legacy_track_id`, `history.reentry_hook_id` |
| Institutional pressure carryover | `godot/src/product/civilization_state_service.gd`, `godot/src/product/world_memory_service.gd` | `godot/src/product/framing_service.gd`, `godot/src/product/archive_service.gd`, `godot/src/tests/test_runner.gd` | Extend | `institutional_pressure_surface`, `legacy_memory_state`, civilization surface `institutional_pressure_lines`, `reputation_bands`, `quiet_play_lines` |
| Archive / crawl / framing continuity surfacing | `godot/src/product/archive_service.gd`, `godot/src/product/crawl_service.gd`, `godot/src/product/framing_service.gd` | `godot/src/tests/test_runner.gd` | Extend | archive detail lines for quiet play / return pull / institution, crawl carryover lines, frame `quiet_play_line`, `reentry_line`, `social_safety_line`, `institutional_line`, `reputation_line` |

## Files Touched
- `godot/src/product/run_story_diagnostics.gd`
- `godot/src/product/profile_service.gd`
- `godot/src/product/crawl_service.gd`
- `godot/src/product/world_memory_service.gd`
- `godot/src/product/civilization_state_service.gd`
- `godot/src/product/archive_service.gd`
- `godot/src/product/framing_service.gd`
- `godot/src/tests/test_runner.gd`

## Schema / Config Changes Summary
- No schema or config files changed in Phase 8.
- The phase was implemented entirely as additive continuity and diagnostics carriers on the existing product/runtime interpretation seams.

## Contracts Implemented

### Quiet Play / Social Safety Diagnostics
- Implemented in `godot/src/product/run_story_diagnostics.gd`
- Added:
  - `quiet_play_signals`
  - `meaningful_non_action`
  - `social_safety_flags`
  - `reputation_band`
  - `institutional_pressure_surface`
  - `continuity_burden_score`
- These remain derived from stored run facts and public-safe carryover only.

### Legacy Tracks / Reentry Hooks
- Implemented in `godot/src/product/profile_service.gd`
- Added normalized profile arrays:
  - `legacy_tracks`
  - `reentry_hooks`
- Added continuity builders:
  - `_build_phase8_legacy_track(...)`
  - `_build_phase8_reentry_hook(...)`
- Added carryover into:
  - `last_run`
  - `run_history`
  - home overview lines
  - last-run diagnostic lines

### World / Civilization Continuity
- Implemented in `godot/src/product/world_memory_service.gd`
- Added `legacy_memory_state` with:
  - `legacy_track_ids`
  - `reentry_hooks`
  - `reputation_bands`
  - `quiet_play_lines`
  - `social_safety_flags`
  - `institutional_pressure_lines`
  - `lines`
- Implemented in `godot/src/product/civilization_state_service.gd`
- Added normalized `institutional_pressure_surface` carryover and public civilization-surface lines.

### Public-Safe Product Surfaces
- Implemented in:
  - `godot/src/product/crawl_service.gd`
  - `godot/src/product/archive_service.gd`
  - `godot/src/product/framing_service.gd`
- Added bounded, public-safe continuity lines for:
  - quiet play
  - non-performative value
  - institutional pressure
  - reputation
  - reentry pull

## Tests Added / Updated
- `godot/src/tests/test_runner.gd`
  - added `_phase8_run_record(...)`
  - added `_test_phase8_quiet_play_diagnostics_and_safety(...)`
  - added `_test_phase8_legacy_reentry_continuity_surfaces(...)`
- The new tests assert:
  - quiet-play and non-performative diagnostics are emitted for low-communication burden runs
  - social-safety flags remain public-safe and all-ages compatible
  - legacy and reentry carriers persist on the existing profile owner
  - world-memory and civilization surfaces consume the new continuity fields without introducing a second owner
  - crawl, archive, and framing surfaces expose the new continuity lines through existing bounded outputs

## Telemetry Fields Added / Updated
- Added to diagnostics / continuity telemetry:
  - `quiet_play_signals`
  - `meaningful_non_action`
  - `social_safety_flags`
  - `reputation_band`
  - `institutional_pressure_surface.pressure_band`
  - `institutional_pressure_surface.claim_lines`
  - `institutional_pressure_surface.interpretation_lines`
  - `institutional_pressure_surface.quiet_play_lines`
  - `continuity_burden_score`
- Added to profile continuity:
  - `legacy_track_id`
  - `reentry_hook_id`

## Governance / Fairness Checks Added / Updated
- Quiet play is now positively surfaced instead of silently under-counted.
- Non-performative participation is explicitly preserved through `meaningful_non_action`.
- Social-safety flags now make dignity and all-ages readability inspectable on the existing diagnostics owner.
- Institutional interpretation remains plural and carried through the current world-memory/civilization owners instead of collapsing into a single canonical read.
- No new persistence path was introduced; profile, crawl, archive, world memory, and civilization services all remain consumers of stored run facts plus public-safe carryover.

## Verification
- Deterministic suite:
  - `scripts/run_tests.ps1` passed
- Proof path:
  - `scripts/run_headless_proof.ps1` passed
  - `RUN_VERIFY ok=true`
  - `REPORT_DIFF ok=true mismatches=0`

## Risk Register Delta
- Reduced risk of quiet or low-performative players disappearing from continuity framing.
- Reduced risk of reentry prompts becoming generic instead of run-anchored.
- Reduced risk of institutional interpretation collapsing into one official post-run summary.
- Increased bounded shell-budget pressure in last-run diagnostics, mitigated by reprioritizing the existing five-line surface rather than widening it into a second diagnostics path.

## Repo-Truth Notes
- No frozen-plan owner or contract correction was required.
- Two implementation-local corrections were required before the phase closed:
  - `godot/src/product/run_story_diagnostics.gd`
    - fixed the Phase 8 institutional-pressure wiring to read `rescue_answer` and `fault_line` from the existing `belief_state`
    - aligned `_reputation_band(...)` with the live numeric `build_stability` field
  - `godot/src/product/profile_service.gd`
    - reprioritized the existing bounded last-run diagnostics output so Phase 7 research carryover and the new Phase 8 quiet-play / reentry lines all survive the same surface budget
- Those were implementation corrections inside the frozen Phase 8 seam, not plan changes.
