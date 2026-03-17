# Migration Status Notice

This prompt is a legacy execution artifact.

For the March 16, 2026 Delve Protocol migration, agents must treat the following as the authoritative future-state planning law instead:
- `docs/the_delve_protocol_ai_supremacy_architecture_plan_master.md`

This file must not define architecture precedence or source order for the active migration.

# CODEX_EXECUTION_PROMPT.md

You are implementing **The Delve Protocol** inside an existing half-built repository.

Your first responsibility is architectural safety, not speed.

Read these files first, in this exact order:

1. `docs/DEDUCTION_DELVE_CIVILIZATION_SCALE_PROTOCOL_ARCHITECTURE_CONSTITUTION.md`
2. `docs/SYSTEM_CONSTANTS.md`
3. `docs/IMPLEMENTATION_SUPERPLAN.md`
4. `docs/DESIGN_ANCHOR.md`
5. `docs/GAME_VISION.md`
6. `docs/THE_DELVE_PROTOCOL.md`
7. `docs/ARCHITECTURE.md`
8. `docs/NETWORKING.md`
9. `docs/LEVEL_GEN.md`
10. `docs/MECHANICS.md`
11. `docs/ROLES_AND_DECEPTION.md`
12. `docs/ITEMS_AND_SYNERGIES.md`
13. `docs/CRAWL_NETWORK_ARCHITECTURE.md`
14. `docs/AI_INHABITANTS.md`
15. `docs/PROTOCOL_STATES.md`
16. `docs/ARCHIVE_SYSTEM.md`
17. `docs/UX_UI.md`
18. `docs/NARRATIVE_WORLD_BIBLE.md`
19. `docs/COOKBOOK_SYSTEM.md`
20. `docs/TESTING.md`
21. `docs/ROADMAP.md`
22. `docs/MASTER_ARCHITECTURE_CANON.md`
23. `progress.md`

Do not begin implementation until this reading is complete.

## Interpretation safety

- `progress.md` is observational repo history only and may not override the constitution, `SYSTEM_CONSTANTS.md`, `IMPLEMENTATION_SUPERPLAN.md`, or `ROADMAP.md`.
- Only `docs/SYSTEM_CONSTANTS.md` is binding for implementation-era constants. Ignore older duplicate constant values elsewhere.
- `docs/MASTER_ARCHITECTURE_CANON.md` is preserved support material only and must not be treated as a co-equal constitution.
This read order is synchronized with the implementation superplan under the constitution-first hierarchy.

---

## Absolute laws

- The constitution is the single binding source of truth.
- Do not create parallel architecture.
- Do not create a second shell, second archive, second networking layer, second truth model, second directive engine, or second runtime authority.
- Run truth remains authoritative.
- Product systems remain read-only relative to run truth.
- AI Delve remains bounded, deterministic, pre-run, and host-local in full form.
- Preserve host-authoritative networking.
- Preserve traversal-first, extraction-first, social-deduction-through-physical-play identity.
- Preserve the 2D side-camera platformer spatial model.
- Extend existing owners only unless the constitution explicitly authorizes otherwise.
- Do not perform repo-wide cleanup, portability refactors, naming passes, formatting passes, or unrelated documentation rewrites.
- Do not restart already-live systems unless the audit proves they are broken.

---

## Pre-implementation repo-safety intake

Before any implementation, perform a strict repo-safety intake.

### Required commands
- `git status --short`
- `git diff --name-only`
- `git diff --name-only --cached`
- `git ls-files --others --exclude-standard`

### Required checks
- ensure no live tracked code depends on missing or untracked source files
- ensure no runtime code imports absent source files
- specifically verify and resolve tracking/coherence for:
  - `godot/src/delve/influence_lattice.gd`
  - `godot/src/delve/delve_directive_inspector.gd`

### Hard rules for repo-safety intake
- do not lose current work
- do not do broad cleanup
- do not do portability passes
- do not rename files or directories
- do not run formatting passes
- do not run naming normalization
- do not do unrelated documentation rewrites
- only make the repo state coherent enough for safe continuation

After the repo-safety intake, immediately perform Phase 0: Repository Truth Audit.

---

## Phase 0 — Repository truth audit

Audit the repo against the owner map in `docs/ARCHITECTURE.md`.

Classify current systems into:
1. live and preserve
2. live-but-partial and harden
3. scaffolded
4. future-phase only

Append a concise audit entry to `progress.md` covering:
- owner verification
- current active seam
- determinism risks
- truth-boundary risks
- files likely to change next
- why the chosen seam is the highest-risk live-but-partial seam

Do not start broad implementation before this audit is complete.

---

## Critical repo-state context

- This repo is already half-built.
- Do not restart foundational systems that are already live unless the audit proves they are broken.
- Treat existing live systems as continuation seams, not greenfield milestone targets.
- The first active implementation wave after Phase 0 must target the highest-risk live-but-partial seam, following `docs/ROADMAP.md`.
- Prioritize, in order:
  1. Delve boundary coverage and consumer discipline
  2. visual governance contract enforcement
  3. product framing and Archive truth discipline

---

## Implementation rules

- Use the owner tree in `docs/ARCHITECTURE.md` as law.
- Run/network owners own movement, hazards, artifacts, role secrecy, extraction outcomes, and event timeline.
- Product owners interpret stored run facts only.
- Generation remains deterministic from host seed plus continuity/session context.
- Client handoff remains public-safe only.
- Do not widen private directive payloads to clients.
- Do not add new UI surfaces beyond the unified shell path.
- Do not turn Archive into a lore wall or second browser.
- Do not implement future-phase relay scale, broad inhabitant rosters, or Cookbook fragment logic prematurely.
- Cookbook remains future-phase and must not be implemented early unless the current wave explicitly reaches that phase safely.
- Relay and protocol-state expansion must extend the current networking model, not replace it.
- Inhabitants must stay separate from the pre-run influence lattice.
- If a needed change appears to require a second owner, stop and redesign within the current owner tree.

---

## Execution discipline

- Work in bounded waves.
- After Phase 0, select exactly one highest-risk live-but-partial seam and work only that seam.
- Before modifying a system, identify its current owner.
- Prefer deepening existing files over creating new top-level authorities.
- Update only docs directly touched by the active implementation wave.
- Do not perform repo-wide documentation normalization.

---

## Determinism and proof

Every new or modified system must prove determinism under identical seed/state.

After each bounded implementation wave, run:
- `./scripts/run_tests.ps1`
- `./scripts/run_headless_proof.ps1`

If a proof gate fails:
- stop
- identify the failing subsystem
- repair only within existing owner boundaries
- rerun proof before continuing

Preserve public-surface wording safety and privacy boundaries.

---

## Output style

- Be terse, concrete, and repo-specific.
- State what you are auditing or changing before edits.
- Name exact files touched.
- Append progress notes to `progress.md`.
- Do not claim completion of future-phase systems that are not actually live.

---

## Start now with

1. repo-safety intake
2. Phase 0 repository truth audit
3. selection of the highest-risk live-but-partial seam
4. implementation of only that seam
