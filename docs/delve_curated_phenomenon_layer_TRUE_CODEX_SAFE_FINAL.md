# Delve Protocol — Curated Phenomenon Layer
## True Final Repo-Grounded Planning Charter for Codex

**Status:** Final planning artifact  
**Audience:** Codex in **planning mode first**, then implementation  
**Purpose:** Add the Curated Phenomenon Layer cleanly inside the current repo reality without schema guessing, parallel systems, runtime mutation, or doctrine drift.

---

# 1. Read this first

This document is intentionally written to be:

- **repo-grounded**
- **planning-safe**
- **owner-aware**
- **schema-cautious**
- **implementation-directive, not design-theory**

It is **not** a drop-in JSON patch.
It is **not** a replacement for repo scanning.
It is **not** permission to invent new systems, new runtime logic, or a parallel manifestation engine.

This document exists to make Codex do the right thing:

1. scan the current repo state,
2. identify the exact live owners and schema shapes,
3. mirror the existing shapes precisely,
4. produce a bounded implementation plan,
5. and only then implement.

---

# 2. Verified repo-grounded baseline

The following points are the current grounding assumptions for this pass.

## 2.1 DelveMind already exists and is not the target of this pass
Do **not** redesign, re-explain, or re-architect DelveMind.

Assume the current project already has:
- hypothesis formation
- experiment selection
- compile-time shaping
- contradiction tracking
- governance response
- recurrence / learning logic

This pass is about **using existing DelveMind surfaces properly**, not adding DelveMind capabilities.

## 2.2 The experiment family catalog is the lawful content extension surface
The repo already contains a live experiment family catalog at:

```text
godot/config/experiment_family_catalog.json
```

That catalog already uses a rich family structure including:
- top-level family metadata
- nested `hypothesis`
- nested `experiment`
- `compile_outputs`
- `compile_targets`
- `fairness_bounds`
- `public_lines`
- recurrence/state metadata

This pass must extend that **existing family ecology** only.

## 2.3 Contradiction / governance outputs already exist
The repo already contains a live contradiction engine and governance schema.

For this pass, Codex must treat the current contradiction-engine outputs as the operative source of truth for biasing linkage:
- `anti_bottleneck_report`
- `play_routing_report`
- `meta_reflection_report`

The current contradiction engine emits:
- `anti_bottleneck_report.status`
- `anti_bottleneck_report.bottleneck_flags`
- `play_routing_report.status`
- `play_routing_report.missing_routes`

Do not invent a new governance pipeline for this work.

## 2.4 Forensic bundle extensions already exist
The governance schema already requires forensic bundles to include:

```text
bundle_extensions
```

This means the correct attachment strategy for the new phenomenon manifest is:

> extend the existing forensic bundle through `bundle_extensions`

Do **not** create a separate reporting subsystem.

## 2.5 Allowed report statuses are broader than current contradiction output
The governance schema allows report statuses like:
- stable
- cooling
- warning
- quarantined

However, the currently verified contradiction-engine path relevant to this pass emits:
- blocked
- stable

Therefore:

- do **not** casually add a new `warning` path in this pass
- do **not** assume every schema enum is already live in the owner path you are touching
- use the current emitting owner behavior as the primary planning basis unless a verified adjacent owner already normalizes these states safely

That distinction matters.

---

# 3. What this pass is actually adding

This pass adds a **Curated Phenomenon Layer** consisting of:

## 3.1 Four new experiment families
- **Palimpsest**
- **Negative Space**
- **Echo Literacy**
- **Contraband-lite**

## 3.2 One forensic bundle extension
- **phenomenon_manifest**

## 3.3 One governance linkage
- anti-bottleneck / route-coverage outputs influencing **next-run experiment-family selection biasing only**

---

# 4. Hard implementation law

Everything in this charter is constrained by the following non-negotiables.

## 4.1 No parallel systems
Do not create:
- a phenomenon engine
- a hidden doctrine-path engine
- a new anomaly subsystem
- a faction layer
- a separate summary stack
- a new runtime reaction service

Everything must reuse existing repo surfaces.

## 4.2 No runtime mutation
This pass must not:
- mutate authoritative gameplay rules
- alter extraction rules
- alter artifact custody rules
- alter win conditions
- add player-specific hidden perception
- add buffs/debuffs
- add runtime-only secret mechanics

All effects must remain compile-time, framing-bound, or forensic/governance-bound.

## 4.3 No cookbook side-door escalation
These families are **not** Cookbook.
They must not:
- generate cookbook fragments directly
- become cookbook progression side doors
- imply exploit privilege
- culturally frame Cookbook as the only meaningful literacy

## 4.4 Public-safe only
Any player-facing surfacing from this pass must remain:
- epistemic
- non-instructional
- non-imperative
- non-guarantee-bearing
- non-faction-labeling

---

# 5. The critical planning rule

Codex must **not** treat this document’s example semantics as literal schema truth.

Instead, for each new family, Codex must:

1. scan the current live family catalog,
2. find the nearest existing family or blend of families to mirror structurally,
3. mirror that exact live shape,
4. then map the semantic intent from this document into that verified shape.

This is the only correct way to keep the implementation:
- schema-safe
- repo-real
- impossible to misinterpret
- free from parallel architecture drift

---

# 6. Family-level semantic contracts

These are **semantic requirements**, not fake guaranteed schema dumps.

Codex must translate them into the exact current family shape it finds in the repo.

---

## 6.1 Palimpsest

### Role
Palimpsest is the archive/continuity contradiction family.

It should represent:
- revision scars
- overwritten but still legible continuity
- unresolved archive reconciliation
- compression residue that remains readable

### It should feel like
- the archive carries revision pressure
- something was overwritten but not fully erased
- continuity is layered, not cleanly settled

### It must surface through existing lawful outputs only
Preferred outputs:
- `archive_framing_bias`
- `public_activation`

Allowed only if the mirrored live family safely supports it:
- bounded `pressure_input_bias`

### It must not
- imply a guaranteed exploit
- imply archive readers are the “real players”
- turn contradiction into nihilism
- become a direct cookbook feeder

### Suggested live-family mirror zone
Codex should mirror whichever current family or family blend is nearest to:
- archive contradiction
- fracture/interpretation pressure
- taxonomy/memory drift
- continuity residue

---

## 6.2 Negative Space

### Role
Negative Space is the structured absence / omission family.

It should represent:
- meaningful non-appearance
- missing verification paths
- absent methods / omitted possibilities
- negative-space pressure becoming interpretable

### It should feel like
- something expected failed to arrive cleanly
- omission itself has weight
- the archive is indexing what was not recovered

### It must surface through existing lawful outputs only
Preferred outputs:
- `archive_framing_bias`
- `public_activation`

Allowed only if the mirrored live family safely supports it:
- bounded `ontology_weighting`

### It must not
- promise hidden content
- imply deterministic absence farming
- look like dev oversight
- imply guaranteed secret payoff

### Suggested live-family mirror zone
Codex should mirror whichever current family or family blend is nearest to:
- taxonomy dormancy
- rediscovery bias
- missing verification
- absent category pressure
- archive omission language

---

## 6.3 Echo Literacy

### Role
Echo Literacy is the repetition / residue-reading family.

It should represent:
- recurrence becoming legible
- route rhyme
- repeated hesitation / threshold / return patterns
- residue that survived compression strongly enough to matter

### It should feel like
- the route is repeating itself in a meaningful way
- recurrence is becoming literacy, not coincidence
- some things are rhyming across the run

### It must surface through existing lawful outputs only
Preferred outputs:
- `archive_framing_bias`
- `public_activation`

Allowed only if the mirrored live family safely supports it:
- bounded `pressure_input_bias`

### It must not
- imply bug-state discovery
- become direct tactical advantage
- flatten recurrence into a solved trick

### Suggested live-family mirror zone
Codex should mirror whichever current family or family blend is nearest to:
- wonder residue
- ritual recall
- archive echo
- repetition-oriented residue families

---

## 6.4 Contraband-lite

### Role
Contraband-lite is the bounded rumor / unofficial-interpretation family.

It is **not** Cookbook.
It is **not** an exploit path.
It is **not** a doctrine-state escalation ladder.

It should represent:
- unverified circulating interpretations
- public plurality without sovereignty
- counterfeit meaning pressure
- unofficial readings that move socially but do not become law

### It should feel like
- some readings are circulating outside official indexing
- unofficial interpretations are moving faster than the archive will settle them
- plurality is alive but bounded

### It must surface through existing lawful outputs only
Preferred outputs:
- `public_activation`

Allowed only if the mirrored live family safely supports it:
- `archive_framing_bias`

Keep this family the most tightly bounded of the four.

### It must not
- create cookbook fragments
- alter doctrine state directly
- alter artifact rules
- imply endorsed cheating
- become the center of the entire interpretive ecology

### Suggested live-family mirror zone
Codex should mirror whichever current family or family blend is nearest to:
- public argument
- rumor field
- fracture echo
- split legitimacy
- public-safe divergence

### Required containment note
If an explicit validator or fairness-bound flag is needed to guarantee non-coupling with Cookbook, Codex must reuse the nearest existing fairness / validation pattern already used in the repo. Do **not** create a new subsystem just for this one family.

---

# 7. Family structure rule

Codex must not hand-author a “new schema variant” for these families.

For each of the four families, Codex must:
- find the nearest existing family shape,
- preserve the full current top-level / hypothesis / experiment field structure,
- preserve the compile-output structure used by the mirrored family,
- preserve the same validation expectations as the mirrored family.

This includes:
- top-level metadata
- recurrence/state fields
- `public_lines`
- full `hypothesis` shape
- full `experiment` shape
- `fairness_bounds`
- `compile_outputs`
- `compile_targets`

If the mirrored family includes fields beyond the minimum semantic requirements in this charter, Codex should preserve them in the new families as well unless there is a proven owner-safe reason not to.

---

# 8. Phenomenon manifest

## 8.1 What it is
A new **phenomenon_manifest** payload describing the curated family manifestations that occurred.

## 8.2 Where it goes
It must be attached through the existing forensic bundle extension pathway.

The preferred placement is:

- existing forensic bundle
- existing `bundle_extensions`
- new `phenomenon_manifest` extension payload

Codex must verify the exact owner and insertion point during planning mode before editing.

## 8.3 Why it exists
It should let DelveMind:
- learn from these bounded manifestations
- preserve internal relevance
- emit safe public summaries
- avoid factionizing the player community

## 8.4 Public/internal split
The manifest must preserve a strict split.

### Public-safe portion
May include:
- family identity
- low-detail severity / exposure language
- safe summary lines
- safe tags

### Internal portion
May include:
- signal basis
- compile surfaces used
- outcome / divergence profile
- cooling / retain / suppress result
- governance relevance

## 8.5 Never expose publicly
Do not publicly expose:
- thresholds
- signal formulas
- hidden trigger names
- next-run implications
- cookbook coupling
- exploit instructions

## 8.6 Owner-neutral implementation requirement
If the existing forensic bundle or public/operator split already has a preferred pattern for public-safe vs internal-only data, Codex must reuse that exact pattern instead of creating a new one.

---

# 9. Governance linkage

This is the part that protects the game from epistemic bottlenecking.

## 9.1 Problem being solved
Without a governance linkage, the system can drift toward a state where:
- Cookbook-adjacent interpretation dominates advanced play culture
- rupture/exploit literacy looks like the only meaningful literacy
- other bounded phenomenon families become secondary or decorative

That is the failure mode this linkage is meant to prevent.

## 9.2 Inputs that must be reused
Use only the existing live outputs already present in the contradiction/governance path:
- `anti_bottleneck_report.status`
- `anti_bottleneck_report.bottleneck_flags`
- `play_routing_report.missing_routes`

## 9.3 Scope of effect
This linkage must affect:
- **next-run experiment-family selection / scoring biasing only**

It must not:
- alter the active run
- mutate runtime rules
- retroactively suppress already manifested content
- become public-facing doctrine messaging

## 9.4 Correct implementation target
The correct target is:
- existing **next-run family scoring / selection logic**
- existing learning / guidance / experiment bias pathway

The wrong target is:
- permanent hard-editing of catalog config
- active-run rule mutation
- a new governance subsystem
- public-facing anti-cookbook logic

## 9.5 Desired bias effect
When current contradiction/governance state indicates a bottleneck or routing blockage, Codex should bias next-run family selection so that:
- dominant-family repetition is reduced
- underrepresented safe phenomenon families become more likely
- especially:
  - Negative Space
  - Echo Literacy
- embodied route coverage remains protected through `missing_routes`

## 9.6 Important caution
Do **not** implement this by blunt permanent mutation of static `recurrence_weight` fields unless the repo already uses those fields dynamically as live scoring inputs in the exact owner path Codex verifies.

The preferred approach is:
> feed the current anti-bottleneck / routing outputs into the existing family scoring / selection layer

That is the repo-safe way to do it.

---

# 10. Compile-output restriction

This pass should remain narrow.

## 10.1 Preferred compile surfaces
Prefer to keep these families bounded to:
- `archive_framing_bias`
- `public_activation`

And only use:
- `pressure_input_bias`
- `ontology_weighting`

when the mirrored live family already proves that use is valid and lawful.

## 10.2 Avoid unnecessary breadth
Even if the broader catalog supports outputs like `constitution_weighting`, do not use that output in this pass unless Codex can justify it by direct owner mirroring from the nearest live family and show that it stays bounded and non-disruptive.

Default preference:
- framing first
- hinted weighting second
- never runtime mutation

---

# 11. Public language rules

All new public text for these families must be:

- interpretive
- non-directive
- non-reward-promising
- non-exploit-teaching
- non-faction-labeling

## Good examples
- “The archive is leaving ink where it should have left silence.”
- “Something expected has failed to appear cleanly enough to matter.”
- “Something in the run is repeating with more intent than comfort.”
- “Some readings are trading hands without becoming law.”

## Bad examples
- “Return here for hidden value.”
- “This is the real way to read the Delve.”
- “Players who notice this can break the system.”
- “Follow the unofficial path.”

---

# 12. Validation and testing requirements

Codex must plan validation for all of the following.

## 12.1 Catalog/registry shape validation
Verify the four new families:
- match the exact current live family shape
- pass existing family loader / registry expectations
- preserve required nested structure
- preserve lawful compile targets and fairness bounds

## 12.2 Compile-output legality
Verify:
- only existing compile outputs are used
- no forbidden outputs are invented
- no runtime mutation hooks are introduced
- no hidden targeting is introduced

## 12.3 Phenomenon manifest safety
Verify:
- `phenomenon_manifest` is attached through the existing forensic bundle extension path
- public-safe portion omits hidden mechanics
- internal portion preserves learning value
- no duplicate summary subsystem is created

## 12.4 Governance linkage correctness
Verify:
- current contradiction outputs influence next-run family selection only
- no public leakage occurs
- no active-run mutation occurs
- route coverage remains protected

## 12.5 Cookbook containment
Verify:
- Contraband-lite does not generate cookbook fragments
- none of the four families mutate cookbook state directly
- none of the four families create a secret exploit progression layer

## 12.6 Saturation / rarity behavior
Verify:
- the four families do not saturate ordinary play
- no single family becomes the default advanced literacy
- the broader interpretive ecology remains plural

---

# 13. Explicit failure modes Codex must guard against

## 13.1 Factionization
No player-facing:
- family labels
- “you are a Palimpsest player” framing
- rank ladders
- secret path branding

## 13.2 Cookbook monoculture
Do not let this pass make the game feel like:
- Cookbook is the only real literacy
- everything else is decorative
- rupture is the only way to touch truth

## 13.3 Archive elitism
Do not let archive-facing families imply:
- only deep readers understand the game
- ordinary embodied play is spiritually secondary

## 13.4 Absence farming
Do not let Negative Space imply:
- guaranteed hidden content
- deterministic secret omission routes
- “the missing thing is always more important than the present thing”

## 13.5 Rumor collapse
Do not let Contraband-lite become:
- a rumor meta
- reverse-official orthodoxy
- a Cookbook substitute

## 13.6 Parallel architecture drift
Do not solve any of this by building a new subsystem outside:
- experiment family catalog
- current family selection/scoring
- forensic bundle extension
- existing governance linkage

---

# 14. Codex planning sequence

Codex must follow this order.

## Step 1 — scan
Locate and verify the live owners for:
- experiment family catalog
- family validation / normalization / registry
- family selection / scoring / recurrence logic
- contradiction engine outputs
- governance consumer(s)
- forensic bundle builder
- forensic bundle extension owner(s)
- relevant tests

## Step 2 — mirror selection
For each of the four new families:
- identify the nearest existing live family or family blend to mirror structurally
- document which current family shapes are being used as references

## Step 3 — bounded change plan
Produce an implementation plan that specifies:
- exact owner files
- exact insertion points
- exact family additions
- exact manifest extension point
- exact governance linkage point
- exact tests to add/update

## Step 4 — explicit non-drift certification
The plan must explicitly certify that the implementation:
- creates no parallel systems
- creates no runtime mutation
- keeps effects compile-time / framing-time / forensic-time only
- does not create a cookbook side-door system

Only after all of that should Codex edit code.

---

# 15. Final directive to Codex

Treat this as a **bounded, additive, repo-shaped extension**.

Do not:
- redesign DelveMind
- invent new systems
- overfit fake JSON from a planning document
- mutate runtime authority
- create faction logic

Do:
- mirror the exact live family shape from the repo
- add the four phenomenon families semantically
- attach `phenomenon_manifest` through the existing forensic bundle extension path
- wire anti-bottleneck / route outputs into next-run family selection biasing
- keep everything public-safe, bounded, and non-factionizing

---

# 16. Intended outcome

At the end of this pass, the repo should gain:

- four new bounded experiment families
- a forensic phenomenon manifest extension
- a governance linkage that preserves epistemic plurality
- no new runtime systems
- no faction ladders
- no cookbook side-door progression
- no architecture drift

That is the full intended outcome.
