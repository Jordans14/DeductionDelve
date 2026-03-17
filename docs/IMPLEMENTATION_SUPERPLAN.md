# IMPLEMENTATION_SUPERPLAN.md

This document is the execution law for implementing **The Delve Protocol** inside the existing repository.

It assumes:
- the constitution is final and binding,
- the support-doc stack is present,
- the repository is already half-built,
- implementation must continue the existing owner tree rather than restart the game.

This is not a greenfield roadmap.
This is a **repo-specific continuation superplan**.

---

## 0. Source hierarchy and interpretation order

Codex and human implementers must treat the following order as binding:

1. `DEDUCTION_DELVE_CIVILIZATION_SCALE_PROTOCOL_ARCHITECTURE_CONSTITUTION.md`
2. `SYSTEM_CONSTANTS.md`
3. `IMPLEMENTATION_SUPERPLAN.md`
4. `CODEX_EXECUTION_PROMPT.md`
5. `DESIGN_ANCHOR.md`
6. `GAME_VISION.md`
7. `THE_DELVE_PROTOCOL.md`
8. support docs in the constitution-defined read order
9. `MASTER_ARCHITECTURE_CANON.md`
10. `progress.md`
11. live repository truth

If anything conflicts:
- the constitution wins,
- then the constants file,
- then this superplan,
- then the prompt.

This document must never be used to override the constitution.
It exists only to turn the constitution into a safe execution program.
`MASTER_ARCHITECTURE_CANON.md` is preserved as subordinate support material and must not be treated as a co-equal source of implementation authority.

---

## 1. Pre-implementation repo-safety intake

Before Phase 0, perform a strict repo-safety intake.

### Required commands
- `git status --short`
- `git diff --name-only`
- `git diff --name-only --cached`
- `git ls-files --others --exclude-standard`

### Required checks
- ensure no tracked runtime code depends on missing or untracked source files
- ensure no live imports reference absent files
- specifically verify and resolve tracking/coherence for:
  - `godot/src/delve/influence_lattice.gd`
  - `godot/src/delve/delve_directive_inspector.gd`

### Hard rules for repo-safety intake
- do not lose current work
- do not perform broad cleanup
- do not perform portability refactors
- do not rename files or directories
- do not perform formatting passes
- do not perform naming normalization
- do not perform repo-wide documentation rewrites
- only make the repo coherent enough for safe continuation

After the repo-safety intake, proceed immediately to Phase 0.

---

## 2. Absolute implementation laws

### 2.1 Single truth model
Run truth is authoritative.
No other system may modify gameplay truth.

### 2.2 No parallel architecture
Never create:
- a second shell
- a second archive
- a second networking layer
- a second run controller
- a second directive authority
- a second truth model
- a second runtime AI authority
- a shadow relay transport
- a detached narrative browser

### 2.3 Product layer is interpretive only
Archive, crawl memory, diagnostics, framing, profile continuity, and world memory interpret stored run facts and nothing else.

### 2.4 Determinism is non-negotiable
Generation, directive shaping, networking, and public-safe summaries must remain deterministic from explicit inputs.

### 2.5 Traversal-first implementation
Movement, hesitation, rescue, burden, confrontation timing, route choice, and extraction pressure remain the source of meaning.
Implementation must not drift toward meetings, lore browsers, or a conventional loot ladder.

### 2.6 2D side-camera lock
The game is a 2D side-camera platformer.
No implementation wave may introduce:
- volumetric navigation
- free 3D camera behavior
- top-down reinterpretation
- depth-as-mechanical-Z gameplay

### 2.7 Extend existing owners only
Prefer deepening existing files and owner paths.
If a proposed change appears to require a second owner, stop and redesign inside the current owner tree.

### 2.8 One seam at a time
After Phase 0, select exactly one highest-risk live-but-partial seam and work only that seam until it reaches a proof-gated stopping point.

---

## 3. Repo-state assumptions

The repository is already half-built.

### 3.1 Systems already live or significantly present
From current docs and progress history, the repo already contains substantial live or partially live work around:
- host-authoritative traversal and extraction
- hazards and item world spawning
- artifacts, roles, secrecy, and product continuity
- visual governance
- product shell and profile/history flows
- Archive and world-memory interpretation seams
- Delve kernel / influence lattice on the live owner path
- wording safety and public-safe summaries

### 3.2 What this means
Codex must not behave as if it is building:
- the first run controller,
- the first archive,
- the first shell,
- the first networking layer,
- or the first directive system.

Codex is continuing and hardening a live system.

---

## 4. Repository owner map

### Run authority
- `godot/src/run/game_controller.gd` or current live equivalent

### Networking authority
- `godot/src/net/network_manager.gd`

### Generation authority
- `godot/src/gen/run_generator.gd`
- `godot/src/gen/room_builder.gd`
- current generation helpers and consumers already on the live path

### Item authority
- `godot/src/items/item_service.gd`

### Role authority
- `godot/src/roles/role_service.gd`

### Directive authority
- `godot/src/delve/delve_kernel.gd`
- `godot/src/delve/world_model.gd`
- `godot/src/delve/doctrine_engine.gd`
- `godot/src/delve/delve_simulator.gd`
- any live directive-consumer path already verified in `progress.md`

### Visual governance
- `godot/src/visual/visual_governance.gd`

### Product systems
- `godot/src/product/profile_service.gd`
- `godot/src/product/run_story_diagnostics.gd`
- `godot/src/product/crawl_service.gd`
- `godot/src/product/framing_service.gd`
- `godot/src/product/archive_service.gd`
- `godot/src/product/world_memory_service.gd`

### Shell
- `godot/src/ui/lobby_controller.gd`
- existing shell builders and scene contracts

If the repo truth audit finds a different exact path name, preserve the live equivalent rather than inventing a new owner.

---

## 5. Binding implementation-era constants

The following values are binding for the current implementation era and come from `SYSTEM_CONSTANTS.md`:

### 5.1 Standard expedition band
- `1` = Exposure
- `2–3` = Intimate
- `4–7` = Fracture
- `8–12` = Expedition

### 5.2 Current implementation target
- standard expedition size: `8–12`
- target rooms per run: `10–12`
- acceptable variance only when deterministic generation requires it
- target duration: `14–18 minutes`

### 5.3 Carry model
- major artifacts carried at once: `1`
- tools carried at once: `2`
- relics / passive modifiers: bounded stack across the crawl
- world objects: contextual and temporary

### 5.4 Current implementation caution
Future canonical extremes such as rare large expeditions and mythic population ceilings are **not** current implementation targets.
Do not build them early.

---

## 6. Phase 0 — Repository truth audit

Phase 0 is mandatory and may not be skipped.

### 6.1 Required classification
Classify every relevant subsystem as:
- live and authoritative
- live but partial
- scaffolded
- future-phase only

### 6.2 Required audit output
Append a concise entry to `progress.md` covering:
- owner verification
- current active seam
- determinism risks
- truth-boundary risks
- files likely to change next
- why the chosen seam is the highest-risk live-but-partial seam

### 6.3 Phase 0 success condition
No coding wave begins until:
- the repo-safety intake is complete,
- the owner tree is verified,
- the seam classification is written,
- one active seam is selected.

---

## 7. First-wave priority order after Phase 0

After the truth audit, the first active wave must target the highest-risk live-but-partial seam according to this order:

1. Delve boundary coverage and consumer discipline
2. visual governance contract enforcement
3. product framing and Archive truth discipline

These priorities come from the current roadmap and should govern the first practical implementation wave.

---

## 8. Influence lattice implementation contract

The directive layer must remain bounded and pre-run.

### 8.1 Forces
- Trial
- Deception
- Discovery
- Memory
- Risk
- Containment

### 8.2 Interpretive minds
- Examiner
- Trickster
- Archivist
- Cartographer
- Warden

### 8.3 Domains of influence
- topology
- pacing
- pressure grammar
- item ecology
- symbolic motifs
- group tension
- archive interpretation
- convergence vs fragmentation

### 8.4 Hard limits
The Influence Lattice may:
- compute pre-run tendencies
- shape deterministic weighting
- emit host-local full directive bundles
- emit public-safe summaries

The Influence Lattice may not:
- own runtime movement
- author post-start gameplay truth
- widen private payloads to clients
- become a runtime game master

---

## 9. Run identity artifact

Every run must produce a deterministic `RunIdentity` artifact with the fields defined by the constitution and constants:

```text
RunIdentity {
  seed
  protocol_state
  doctrine_family
  dominant_forces
  dominant_minds
  pacing_profile
  pressure_verbs
  symbolic_motifs
  item_ecology_bias
  group_tension_bias
  archive_tone
}
```

Host retains the full artifact.
Clients receive only public-safe carryover fields allowed by the constitution.

---

## 10. Implementation phases

These phases are execution categories, not permission to start everything at once.
Current work remains bounded to one seam at a time.

### Phase 1 — Stabilize live boundaries
Target:
- Delve boundary coverage and consumer discipline
- visual governance contract enforcement
- product framing and Archive truth discipline

Deliverables:
- verified bounded consumers
- no client widening of host-only directive payloads
- no shell drift
- no truth-boundary leaks

Proof gates:
- tests green
- proof green
- wording/public-surface safety preserved

### Phase 2 — Deterministic generation stability
Target:
- generation remains seed deterministic
- branch ideology and pressure grammar stay bounded
- topology ownership remains with generation owners

Deliverables:
- deterministic replay parity
- consumer-safe generation outputs
- no parallel generation layer

### Phase 3 — Networking integrity
Target:
- host-authoritative ENet path remains singular
- state replication remains deterministic
- client receives public-safe summaries only

Deliverables:
- no shadow transport
- no widened directive payload
- no second networking abstraction

### Phase 4 — Crawl continuity and Archive interpretation
Target:
- crawl memory stores run summaries and continuity safely
- Archive compares patterns without rewriting truth
- product systems remain read-only

Deliverables:
- branch echoes
- artifact lineage carryover
- crawl summaries
- product-safe interpretation packets

### Phase 5 — Mechanics deepening
Only once the live seams above are stable.

Target:
- expand gameplay ontology and item/resource definitions safely
- deepen deterministic item interactions through current owners
- avoid dumping system logic into already-dense product owners

Deliverables:
- deterministic synergy-resolution layer
- richer item/interaction taxonomy
- no loot-ladder drift

### Phase 6 — Inhabitant / low-density / adaptive support
Only after mechanics deepening is safe.

Target:
- deepen pressure ecology through current run/network owners
- preserve lattice vs inhabitant separation
- keep adaptive logic deterministic from explicit facts

Deliverables:
- no runtime AI sovereignty
- no combat-first genre drift
- no population-adaptive chaos without proof

### Phase 7 — Forward-compatible relay and protocol-state continuity hooks
Target:
- continuity hooks only
- no full relay recombination implementation yet unless the active wave explicitly reaches that phase safely

Deliverables:
- forward-compatible topology and continuity seams
- no replacement of the current networking model

### Phase 8 — Future-phase systems
Remain guarded unless the roadmap and proof lanes explicitly justify entry:
- relay recombination at scale
- broad inhabitant rosters
- Cookbook fragments / holders / network recognition
- large-population protocol-state behavior
- mythic rare-event population ceilings

---

## 11. Hard stop conditions

Stop and redesign if:
- a proposed feature needs a second owner
- product memory would rewrite run truth
- a client would need private directive payloads
- the shell would need a second UI path
- the Archive would become a detached browser
- future-phase systems are being pulled forward without proof and roadmap justification
- implementation drifts from 2D side-camera platforming into some other spatial model

---

## 12. Documentation update rules

- Update only docs directly touched by the active implementation wave.
- Do not perform repo-wide documentation normalization.
- Do not rewrite the constitution during implementation.
- If a local support doc must be updated, note:
  - which constitutional section it extends
  - why it needed update
  - what it is forbidden to contradict

---

## 13. Proof gates and regression discipline

After each bounded implementation wave, run:
- `./scripts/run_tests.ps1`
- `./scripts/run_headless_proof.ps1`

Every new or modified system must prove:
- determinism under identical seed/state
- host-authoritative stability
- no truth-boundary widening
- no wording/public-surface leak
- no social-deduction integrity regression

If a proof gate fails:
- stop
- identify the minimal failing subsystem
- repair only within existing owner boundaries
- rerun proof before continuing

---

## 14. Completion standard for a seam

A seam is complete only when:
- the target owner path remains singular
- the repo proof lanes are green
- the product/run boundary remains intact
- the shell remains unified
- the architecture still reads truthfully against the constitution
- `progress.md` reflects what actually changed

---

## 15. Final implementation posture

This superplan exists to make Codex and humans behave like continuation engineers, not speculative re-architects.

The default implementation posture is:
- preserve,
- classify,
- deepen one seam,
- prove,
- stop,
- record.

Not:
- expand everywhere,
- normalize the repo,
- rewrite old layers,
- or implement future fantasy early.
