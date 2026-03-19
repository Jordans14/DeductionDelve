# Testing

See also: [ARCHITECTURE](d:/DeductionDelve/docs/ARCHITECTURE.md), [NETWORKING](d:/DeductionDelve/docs/NETWORKING.md), [ARCHIVE_SYSTEM](d:/DeductionDelve/docs/ARCHIVE_SYSTEM.md), [PROTOCOL_STATES](d:/DeductionDelve/docs/PROTOCOL_STATES.md).

## Current Test Lanes
- `./scripts/run_tests.ps1`
- `./scripts/run_headless_proof.ps1`

These remain the primary regression gates for gameplay truth, shell continuity, and deterministic product-layer behavior.

## Current Live Test Focus
- host-authoritative networking
- seeded generation determinism
- Delve kernel determinism, constitutions, and trace-safe directive emission
- explicit GenerationContract emission, host-private handoff, and narrow generation/item consumption
- host/client Delve directive handoff and public-summary privacy
- directive-shaped item and generation consumption
- host-runtime Delve control-surface consumption for extraction timing, ghost pressure, and artifact noise cadence
- relationship / obligation / trust routing into generation, route pressure, and extraction timing
- relay / crawl-network routing into branch pressure, witness spread, runtime watch cadence, and extraction return pressure
- cookbook / anti-Protocol routing into branch pressure, item weighting, and runtime watch/extraction behavior
- civilization-family routing into distinct route/item/runtime consequences
- role / deception / artifact-custody runtime pressure and ecology targeting
- bounded inhabitant differentiation across ghost, anomaly echo, predator rush, and protocol-watch containment
- player-guidance packet, live briefing, and shell-summary comprehension output
- expanded role roster consequences across Steward / Bearer / Murmur
- expanded branch-family, item-pool, and bounded ecology breadth across Oath Terraces, Murmur Warrens, Custody Seal, Witness Chime, Echo Lure, Burden Sling, predator modes, and protocol-watch interdiction
- branch-family and protocol-state weighting depth across room generation and item spawning
- next-tier branch-pressure shaping from public-safe domain/archive/item-ecology summaries plus existing branch-context memory seeds
- artifact ecology signaling, crawl-memory comparison, archive signal stability, and world-memory cultural-association carryover
- canonical `constitution_summary` / `expedition_constitution_summary` handoff with `directive_summary` compatibility only
- experimental ontology, learning guidance, and public-safe experiment-surface carryover
- governance review surfaces, explanation packets, and safe-mode public-summary carryover
- quiet-play diagnostics, legacy reentry continuity, forensic bundle hardening, and profile forensic persistence
- visual governance motion hierarchy, room packet budgets, and background honesty
- doctrine-layer visual-only enforcement and motif inertness
- run summary and report safety
- shell helper determinism and compact doctrine/governance carryover on the unified shell path
- profile/archive/world-memory continuity
- Layer-1 wording safety
- product-side stripping of host-only Delve internals before diagnostics, framing, crawl memory, and archive output

## Current Repo-Scoped Wave Coverage
- Wave 2 coverage is already live on the current owner tree through `_test_ontology_engine_and_compiler_bridge`, `_test_constitution_compiler_symbolic_profiles_and_bounds`, `_test_experimental_ontology_phase6_compilation_and_surfaces`, `_test_phase7_learning_loop_determinism_and_continuity`, `_test_phase7_compiler_guidance_and_public_traces`, `_test_phase7_manifestation_identity_and_collision_handling`, `_test_constitution_summary_migration_and_aliases`, and `_test_delve_intelligence_kernel_governance`.
- Wave 3 coverage is already live on the current owner tree through `_test_branch_and_protocol_weighting_depth`, `_test_phase2_constitution_and_visual_normalization_contract`, `_test_phase5_branch_context_and_visual_apex_preview`, `_test_visual_doctrine_refactor`, `_test_runtime_ecology_beyond_ghost`, `_test_predator_rush_and_combat_scaling`, `_test_inhabitant_differentiation_deepening`, `_test_new_item_runtime_and_inhabitant_modes`, `_test_read_only_ecology_signal_carryover`, and `_test_read_only_predator_signal_carryover`.
- Wave 4 coverage is already live on the current owner tree through `_test_institutional_order_carryover_and_delve_intake`, `_test_affective_climate_and_ordinary_labor_carryover`, `_test_interpretation_network_order_and_silence_carryover`, `_test_epoch_state_world_model_and_horizon_carryover`, `_test_cookbook_shadow_and_anti_protocol_carryover`, `_test_cookbook_anti_protocol_embodiment`, `_test_civilization_conflict_embodiment_diverges`, `_test_master_narrative_v3_archive_world_memory_and_progression`, `_test_master_narrative_v3_longform_continuity_and_lobby`, `_test_phase3_world_memory_and_civilization_market_persistence`, `_test_phase4_world_memory_encounter_persistence`, `_test_phase5_world_aftermath_owner_boundary`, `_test_phase5_world_aftermath_persistence`, `_test_phase5_world_aftermath_shape_contract`, `_test_phase8_quiet_play_diagnostics_and_safety`, `_test_phase8_legacy_reentry_continuity_surfaces`, `_test_phase9_forensic_bundle_hardening_contract`, `_test_phase9_forensic_bundle_extension_consistency`, and `_test_phase9_profile_forensic_persistence_and_world_memory_hash`.
- Wave 5 coverage is already live on the current owner tree through `_test_product_catalog_and_profile_progression`, `_test_product_shell_deepening_helpers`, `_test_product_shell_reconnect_history_and_voice_helpers`, `_test_shell_explainability_tightening`, `_test_phase6_shell_proof_fast_path`, `_test_lobby_shell_scene_contract`, and `_test_multimodal_contract_non_authority`.
- Wave 6 coverage is the full proof lane itself: `./scripts/run_tests.ps1`, `./scripts/run_headless_proof.ps1`, `RUN_VERIFY ok=true`, and `REPORT_DIFF ok=true mismatches=0`.

## Current Operational Notes
- the headless proof lane still retains bounded retry for rare transient pre-verify stalls; this is an operational safeguard, not an open current-scope feature gap
- future-phase categories remain separate so this doc does not imply missing current owner-path embodiment where the live repo already has proof coverage

## Future-Phase Test Categories
- large-population protocol-state behavior tests
- broad inhabitant roster expansion tests beyond the current bounded ecology owner path
- relay merge and recombination tests
- Cookbook escalation and anti-Protocol branch-redirection tests beyond the current bounded routing seam

These should be added when the corresponding systems become live implementation work.

## Testing Standard
- deterministic
- proof-compatible
- mechanically authoritative
- product layers read-only relative to run truth
- wording-safe on public surfaces

## Documentation Safety
Test expectations described here are grounded in live implementation status. Future-phase categories are kept separate so this doc does not over-claim what is already in the repo.
