# Delve Protocol — Repo-Aligned Codex Continuation Implementation Charter (v1.1)

## Purpose

This charter translates the Delve Protocol Constitutional Superstructure into a **continuation-safe implementation law** for the live `Jordans14/DeductionDelve` repository.

It supersedes any greenfield interpretation of the older implementation charter.

This charter assumes:

- the repository is already materially implemented
- the live owner tree is authoritative
- the repo must be extended through continuation seams, not rebuilt from layered scratch
- deterministic tests and headless proof are hard gates

---

## 0. Prime Directive

Codex must not treat this repository as a fresh architecture build.

Codex must treat it as a **live, half-to-late stage constitutional codebase** with active owner seams, migration adapters, and validated proof lanes.

The first responsibility is not invention.
The first responsibility is **repo-truth continuation**.

---

## 1. Repo-Truth First

Before planning or implementation, Codex must establish repo truth from the current repository state.

Required first-pass reads:

1. `progress.md`
2. `docs/ARCHITECTURE.md`
3. `docs/IMPLEMENTATION_SUPERPLAN.md`
4. `docs/THE_DELVE_PROTOCOL.md`
5. `docs/ROADMAP.md`
6. `docs/TESTING.md`
7. `docs/CODEX_EXECUTION_PROMPT.md`
8. the active live owner files relevant to the seam being touched

Required repo-safety intake:

- `git status --short`
- `git diff --name-only`
- `git diff --name-only --cached`
- `git ls-files --others --exclude-standard`

Codex must determine:

- what is live and preserve
- what is live-but-partial and can be deepened
- what is scaffolded
- what is future-phase only

Codex may not begin broad work until this intake is complete.

---

## 2. Canonical Owner Law

The repo already has a live owner tree. Codex must preserve it.

### Canonical active owners

- **Run/runtime truth**
  - `godot/src/net/network_manager.gd`
  - `godot/src/run/game_controller.gd`
  - `godot/src/run/run_state.gd`

- **Generation**
  - `godot/src/gen/run_generator.gd`
  - `godot/src/gen/room_builder.gd`

- **Delve / constitution / compiler / doctrine**
  - `godot/src/delve/*`
  - `godot/src/gen/constitution_compiler.gd`
  - `godot/src/gen/ontology_engine.gd`
  - `godot/src/gen/narrative_pressure_engine.gd`
  - doctrine schema/catalog files under `godot/config/`

- **Items / ecology**
  - `godot/src/items/item_service.gd`
  - `godot/src/items/item_synergy_service.gd`

- **Roles**
  - `godot/src/roles/role_service.gd`

- **Product continuity / interpretation**
  - `godot/src/product/*`

- **Visual doctrine**
  - `godot/src/visual/visual_governance.gd`
  - existing visual consumers

- **Unified shell**
  - `godot/src/ui/lobby_controller.gd`
  - `godot/scenes/Lobby.tscn`

- **Validation**
  - `godot/src/tests/test_runner.gd`
  - `scripts/run_tests.ps1`
  - `scripts/run_headless_proof.ps1`

### Hard rule

Do not create a second owner where one already exists.

---

## 3. Continuation-Safe Implementation Rules

### Rule A — No greenfield rebuilds
Do not plan the repository as though it still needs its initial substrate, truth pipeline, concept system, intervention engine, or Delve layer built from scratch.

### Rule B — No parallel systems
Do not create:

- a second truth path
- a second intervention path
- a second shell
- a second archive
- a second networking model
- a second runtime authority path
- a second Delve planner path
- a second replay/history model
- a second visual doctrine path

### Rule C — Extend, do not restart
If a live owner exists, deepen it.
Only replace or reroute when the repo audit proves the current owner is broken.

### Rule D — Preserve host authority
Host/runtime truth remains authoritative.
No product, archive, experiment, or learning owner may mutate live runtime authority.

### Rule E — Preserve public-safe boundaries
Clients and product/archive readers may receive only the lawful public-safe summary surfaces.
Host-only directive, constitution, control-surface, experiment, and learning internals must remain bounded.

### Rule F — Preserve proof safety
All changes must keep:

- deterministic unit/integration tests green
- headless proof green
- host/client report parity intact

---

## 4. Current Live Architecture Baseline

Codex must assume the following are already materially live in the repo:

- bounded pre-run Delve kernel path
- constitution spine and explicit constitution artifact flow
- explicit GenerationContract handoff
- ontology engine
- constitution compiler
- visual governance
- narrative pressure engine
- experimental ontology / grammar
- evaluation / learning loop
- reserve ecology activation
- mutation routing
- artifact naming migration
- unified shell / profile / archive continuity path
- deterministic proof lane

Codex must therefore plan from a **post-foundational repo state**, not a foundational one.

---

## 5. Constitutional Hierarchy in Repo Terms

Use the constitutional superstructure as the conceptual north star, but translate it through repo reality.

### Highest practical implementation order

1. **Repo truth**
2. **Owner preservation**
3. **Boundary correctness**
4. **Proof safety**
5. **Seam selection**
6. **Bounded implementation**
7. **Regression validation**
8. **Doc reconciliation only where touched**

Not:

1. invent layers
2. build abstractions
3. later discover repo conflicts

---

## 6. Seam Selection Law

After repo-truth intake, Codex must choose exactly one bounded seam unless the active prompt explicitly authorizes a multi-seam wave.

The seam must be selected by this order:

1. highest-risk live-but-partial seam
2. owner-safe continuation opportunity
3. strongest constitutional leverage
4. lowest risk of parallel authority or proof breakage

Each chosen seam must declare:

- current owner
- why that owner is lawful
- what is already live
- what remains partial
- what will not be touched
- exact files expected to change
- exact validations to rerun

---

## 7. Constitution / Compiler / Delve Law

The repo already uses a Delve/constitution/compiler path.

Codex must preserve these rules:

- Delve remains bounded and pre-run in authoritative full form
- constitution artifacts remain canonical over thinner adapter summaries
- generation and item ecology consume the narrow generation/constitution contract, not ad hoc planner internals
- experiments and learning remain symbolic, compiler-facing, and non-runtime-authoritative
- product-facing interpretation remains read-only relative to run truth

---

## 8. Product / Experiment / Learning Law

The repo already contains experiment and learning owners.

Codex must preserve:

- no runtime gameplay authority inside experiment or learning owners
- no adaptive live balance that bypasses the compiler/constitution path
- no secret player targeting
- no second archive or second continuity model
- no widening of hidden ontology into player-facing surfaces

These systems may:
- persist continuity
- evaluate manifested experiment records
- emit compiler-facing guidance
- generate public-safe interpretation lines

They may not:
- mutate live legality
- alter runtime truth directly
- become a second gameplay director

---

## 9. Visual Governance Law

Visual governance is already live and bounded.

Codex must preserve:

- presentation-only law
- background honesty
- motion hierarchy
- readability budgets
- shell continuity on the existing shell path

No visual work may create gameplay authority or a second presentation architecture.

---

## 10. Mutation / Reserve Ecology / Artifact Law

The repo already contains live migration-era systems here.

Codex must assume:

- reserve ecology is materially live
- mutation routing is materially live
- artifact naming is canonically preferred over evidence naming on the hot path
- compatibility adapters still exist and must be reduced carefully, not ripped out blindly

Any new work in these areas must:
- stay in current owners
- preserve determinism
- preserve migration compatibility where still needed
- avoid widening state or duplicating taxonomy

---

## 11. Documentation Law

Docs must follow repo truth, not replace it.

Codex may update docs only when:

- the touched seam makes existing wording factually wrong
- a validation/proof instruction changed
- a current-state claim drifted from code

Codex may not use an implementation wave as an excuse for repo-wide documentation churn.

---

## 12. Validation Gates

Every bounded wave must end with:

- `./scripts/run_tests.ps1`
- `./scripts/run_headless_proof.ps1`

Minimum required checks before stopping:

1. owner boundaries preserved
2. no new parallel authority path
3. no widened private/public leak
4. deterministic tests green
5. proof lane green
6. touched docs reconciled if needed
7. `progress.md` appended with a concise truth report

If any gate fails, Codex must repair within the same owner tree before continuing.

---

## 13. Output Contract for Codex

For every planning or implementation wave, Codex must output:

1. **Pre-edit repo truth**
   - current seam
   - owner map
   - live vs partial vs deferred classification

2. **Planned scope**
   - exact files
   - exact reasons
   - explicit out-of-scope items

3. **Execution**
   - what changed
   - why lawful
   - truth-boundary considerations
   - risks introduced or preserved

4. **Validation**
   - tests run
   - proof status
   - remaining deferred debt

---

## 14. Final Continuation Command

Build Delve from the repository that exists, not from the architecture you wish were still unbuilt.

Be:

- stricter than the docs
- smaller than the temptation to redesign
- more loyal to owner truth than abstraction
- more afraid of parallelism than incompleteness
- slower to widen authority than to deepen an existing seam
