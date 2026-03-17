
# THE DELVE PROTOCOL
## FINAL CANONICAL ARCHITECTURE DOCTRINE
### Single-Document Codex Source-of-Truth

**Document status:** FINAL  
**Intended consumer:** Codex  
**Purpose:** This document is the single authoritative architecture doctrine for planning and implementation of the full DelveMind constitutional, ecological, cultural, and experimental system for The Delve Protocol.  
**Interpretation policy:** Codex must not infer missing architecture outside this document. Where a choice is not explicitly permitted here, it is disallowed until added to doctrine.

---

# 0. DOCUMENT MANDATE

This document defines the complete architecture for The Delve Protocol at the level required for Codex to:

1. form an implementation plan,
2. sequence work correctly,
3. avoid parallel architecture,
4. preserve runtime fairness and determinism,
5. preserve host-authoritative simulation truth,
6. implement DelveMind as a lawful world-model intelligence rather than a runtime god-object.

This document is not a pitch deck, lore essay, or vague design manifesto.  
It is a **binding systems doctrine**.

The architecture here must be interpreted with the following strict priority:

1. **Runtime legality and determinism**
2. **Core gameplay clarity and fairness**
3. **Constitutional AI authorship**
4. **Ontological ecology**
5. **Cultural simulation**
6. **Narrative pressure**
7. **DelveMind experimentation and learning**

Where any lower layer conflicts with a higher layer, the higher layer wins.

---

# 1. EXECUTIVE SUMMARY

The Delve Protocol is a multiplayer expedition game built on the fusion of:

- traversal/platforming pressure,
- artifact extraction,
- item/build ecology,
- social deduction,
- continuity memory,
- archive interpretation,
- long-horizon world evolution,
- AI-authored constitutional possibility space.

The game is **not** built around runtime AI improvisation.  
The game is built around **pre-authored constitutional possibility space** executed by a deterministic runtime.

The decisive architecture rule is:

> **DelveMind authors possibility space. Runtime executes lawful truth.**

This means:

- DelveMind defines the authored conditions of expeditions.
- Runtime resolves what actually happens.
- Cultural systems interpret results afterward.
- DelveMind learns from those lawful outcomes and authors future conditions.

DelveMind may influence:
- constitutions,
- ecology weighting,
- ontology evolution,
- cultural climates,
- narrative pressure,
- experimental lineages.

DelveMind may not influence:
- runtime legality,
- authoritative outcomes,
- physics,
- hidden player punishment,
- artifact core objective status,
- core skill validity.

---

# 2. NON-NEGOTIABLE GLOBAL LAWS

## 2.1 Runtime Truth Law

All runtime truth is owned by the host-authoritative simulation.

Runtime truth includes:
- player position,
- interaction validation,
- hazard state,
- artifact custody,
- extraction state,
- role boundaries,
- event log truth,
- lawful outcome resolution.

No DelveMind or product-layer system may rewrite or override runtime truth once a run begins.

## 2.2 Determinism Law

Runs must remain deterministic from seed and lawful substreams.

No experiment, cultural system, ontology mutation, or pressure engine may introduce non-deterministic runtime divergence.

## 2.3 Artifact Centrality Law

Artifacts remain the core objective economy of the game.

Artifacts may become:
- debated,
- scandalized,
- culturally reinterpreted,
- classified differently,
- politically regulated,
- narratively controversial.

Artifacts may not become:
- mechanically meaningless,
- globally untrustworthy for long spans,
- non-central to extraction,
- invalid as core objective anchors.

## 2.4 Skill Preservation Law

No macro-system may invalidate learned lawful play.

Players must retain stable mastery in:
- movement,
- traversal,
- hazard reading,
- extraction logic,
- evidence interpretation principles,
- social reasoning patterns.

The world may change meaning and context.  
It may not arbitrarily revoke core competence.

## 2.5 Legibility Floor Law

No live experiment or pressure configuration may reduce the game below a socially arguable and mechanically readable threshold.

Ambiguity is allowed.  
Arbitrariness is forbidden.

## 2.6 Non-Sadism Law

DelveMind may test humanity’s interpretive behavior.  
It may not torment players by breaking reality, secretly targeting individuals, or producing invisible punishments.

## 2.7 Separation Law

The following layers must remain separate:

- Runtime truth layer
- Product/continuity layer
- Cultural simulation layer
- DelveMind experiment layer

Each may read from the layers beneath according to this doctrine.  
No layer may illegitimately become a second simulation authority.

---

# 3. CORE GAME IDENTITY

The Delve Protocol must remain recognizably this game at all times:

- hazardous traversal under pressure,
- artifacts as objective anchors,
- tools and relics shaping route and interpretation,
- public clues plus private suspicion,
- social deduction without hard mechanical guilt proof,
- continuity memory and archive meaning after runs,
- DelveMind-authoring of conditions, not forced outcomes.

Any implementation that over-weights outer-loop simulation while weakening expedition play is architecturally wrong.

---

# 4. ARCHITECTURE STACK

The full architecture stack is:

```text
DelveMind Learning Loop
↓
Experiment Grammar and Evaluation Engine
↓
DelveMind Experimental Ontology
↓
Narrative Pressure Ecosystem
↓
Cultural Simulation Ecosystems
↓
Ontological Ecology Engine
↓
Expedition Constitution Evolution
↓
Runtime Simulation Ecology
↓
Host-Authoritative Deterministic Truth
```

## 4.1 Stack meanings

### Host-Authoritative Deterministic Truth
The actual lawful runtime of the game.

### Runtime Simulation Ecology
The concrete playable expedition systems:
- traversal,
- hazards,
- artifacts,
- tools,
- relics,
- pressure,
- roles,
- extraction,
- evidence.

### Expedition Constitution Evolution
The symbolic structure DelveMind compiles to author expedition possibility space.

### Ontological Ecology Engine
The evolving ecology of categories, lineages, niches, hybridizations, and rediscoveries.

### Cultural Simulation Ecosystems
The world outside and around the delve:
- institutions,
- publics,
- markets,
- belief systems,
- legitimacy flows,
- rumor, archive, and memory systems.

### Narrative Pressure Ecosystem
The balancing engine for macro-scale civilizational motion.

### DelveMind Experimental Ontology
The hypothesis and experiment space through which DelveMind tests humanity.

### Experiment Grammar and Evaluation Engine
The symbolic system that generates, compiles, expresses, evaluates, and persists experiments.

### DelveMind Learning Loop
The layer that updates hypotheses, experiment weights, recurrence, and branching.

---

# 5. REPOSITORY AND SYSTEM OWNERSHIP MAP

This section is mandatory and binding. Codex must use it to place systems correctly and avoid parallel architecture.

## 5.1 Existing runtime repo boundaries

The current repo already establishes these major domains:

- `godot/src/net/` → networking, authority, protocol handling
- `godot/src/run/` → run state machine, extraction, evidence, event log
- `godot/src/gen/` → generation and room/cavern building
- `godot/src/roles/` → roles and role-related affordances
- `godot/src/items/` → tools, relic interactions, item ecology implementation
- `godot/src/entities/` → players, evidence, hazards, trace-bearing entities
- `godot/src/ui/` → HUD, notebook, recap, situation surfaces
- `godot/src/product/` → persistence, codex, catalog, continuity, profile, diagnostics
- `godot/config/` → validated data/config catalogs

## 5.2 New ownership map for the full architecture

### Runtime authority systems (existing runtime owners)
These remain runtime-owned and must not be rehomed:
- `godot/src/net/network_manager.gd`
- `godot/src/run/game_controller.gd`
- `godot/src/run/event_log.gd`
- `godot/src/run/evidence_service.gd`
- `godot/src/gen/run_generator.gd`
- `godot/src/gen/room_builder.gd`
- `godot/src/items/*`
- `godot/src/entities/*`
- `godot/src/roles/*`

### New pre-run / generation-facing systems
These belong under generation and may influence authored possibility space, but not runtime truth:
- `godot/src/gen/constitution_compiler.gd`
- `godot/src/gen/ontology_engine.gd`
- `godot/src/gen/narrative_pressure_engine.gd`

### New product / continuity / simulation systems
These belong under product and must remain outside runtime authority:
- `godot/src/product/cultural_simulation.gd`
- `godot/src/product/legitimacy_engine.gd`
- `godot/src/product/rumor_engine.gd`
- `godot/src/product/archive_interpretation_engine.gd`
- `godot/src/product/delvemind_experiment_engine.gd`
- `godot/src/product/delvemind_learning_loop.gd`

### Data/config ownership
These belong in config/data files and must be schema-validated:
- `godot/config/constitution_schema.json`
- `godot/config/ontology_schema.json`
- `godot/config/experiment_schema.json`
- `godot/config/cultural_actor_schema.json`
- `godot/config/narrative_pressure_schema.json`
- `godot/config/doctrine_family_catalog.json`
- `godot/config/experiment_family_catalog.json`

## 5.3 Ownership prohibitions

Codex must not:
- move DelveMind into runtime authority owners,
- place cultural simulation in `net` or `run`,
- create a second event-log truth model,
- create a second artifact legality path,
- create a hidden runtime AI resolver,
- bypass the constitution compiler with ad-hoc direct generation hacks.

---

# 6. DATA MODEL DEFINITIONS

These are the canonical core data shapes. Codex must use them directly or preserve their semantics exactly.

## 6.1 Expedition Constitution

```text
ExpeditionConstitution {
    constitution_id
    doctrine_family_id
    doctrine_variant_id
    generation_seed
    topology_profile
    chamber_grammar_profile
    route_profile
    item_ecology_profile
    pressure_ecology_profile
    information_doctrine_profile
    pacing_profile
    custody_profile
    mutation_permissions
    continuity_hooks
    symbolic_motifs
    fairness_bounds
    compile_metadata
}
```

## 6.2 Ontology Node

```text
OntologyNode {
    node_id
    category_type
    lineage_id
    parent_node_id
    child_node_ids[]
    niche_id
    state                // emerging, stable, fragmenting, declining, dormant, rediscovered
    hybrid_sources[]
    taboo_state
    rediscovery_weight
    mutation_permissions
    category_tags[]
    cultural_labels[]
}
```

## 6.3 Ontology Lineage

```text
OntologyLineage {
    lineage_id
    lineage_type         // artifact, chamber, pressure, ritual, doctrine, experiment, taxonomy, etc.
    origin_node_id
    current_node_ids[]
    extinct_node_ids[]
    dormant_node_ids[]
    hybrid_descendants[]
    fitness_profile
    recurrence_weight
}
```

## 6.4 Cultural Actor

```text
CulturalActor {
    actor_id
    actor_type           // institution, public, market, archive school, certifier, regulator, faith group, etc.
    name_key
    legitimacy_profile
    influence_profile
    belief_profile
    memory_profile
    resilience_profile
    adaptation_rate
    energy_profile
    schism_risk
    alliance_edges[]
    rivalry_edges[]
    dependency_edges[]
    revival_hooks
}
```

## 6.5 Belief State

```text
BeliefState {
    belief_id
    domain
    claim
    confidence
    emotional_investment
    institutional_backing
    public_adoption
    controversy
    inertia
    mutation_paths[]
}
```

## 6.6 Narrative Pressure State

```text
NarrativePressureState {
    stability
    disruption
    authority
    skepticism
    fear
    curiosity
    certainty
    ambiguity
    ritual
    innovation
    extraction
    stewardship
    momentum
    resonance
    cascade_risk
}
```

## 6.7 Hypothesis

```text
Hypothesis {
    hypothesis_id
    domain
    thesis
    confidence
    target_layers[]         // runtime-adjacent behavior, institutions, publics, ontology, archive, etc.
    target_populations[]
    supporting_evidence_ids[]
    contradicting_evidence_ids[]
    open_branches[]
    dormancy_state
    recurrence_weight
    foundational_flag
}
```

## 6.8 Experiment

```text
Experiment {
    experiment_id
    family_id
    program_id
    hypothesis_id
    topology_type
    target
    axis
    stressor
    ontology_condition
    cultural_medium
    time_horizon
    observation_contract
    fairness_bounds
    state                  // active, recurring, rare, dormant, archival, foundational
    expression_mode
    compile_outputs
    fitness_scores
    lineage_parent_id
    branch_ids[]
    synthesis_sources[]
}
```

## 6.9 Experiment Evaluation Record

```text
ExperimentEvaluationRecord {
    experiment_id
    hypothesis_support
    cultural_richness
    ontological_productivity
    narrative_resonance
    fairness_score
    readability_score
    replay_distinctiveness
    branch_opened
    dormancy_recommended
    rarity_recommended
    recurrence_recommended
    notes
}
```

---

# 7. RUNTIME SIMULATION ECOLOGY

The runtime is the playable expedition layer. It is ecological in structure but deterministic in execution.

## 7.1 Runtime ecological objects

All major runtime entities belong to lineages and ecological classes:

- Artifact lineages
- Chamber lineages
- Pressure lineages
- Tool lineages
- Relic lineages
- Ritual affordance lineages
- Evidence trace lineages
- Transformation lineages

## 7.2 Runtime ecological capabilities

Each runtime lineage may support:
- emergence,
- stabilization,
- mutation,
- hybridization,
- decline,
- dormancy,
- rediscovery,
- misclassification.

However, runtime expression of these capabilities must be compiled through lawful constitution outputs and may not mutate illegally during a run.

## 7.3 Runtime hybridization rule

Hybridization is allowed at the authored possibility-space layer. Runtime may execute hybrid forms only if:
- constitution compiler permits them,
- fairness bounds approve them,
- readability floor remains above threshold.

## 7.4 Runtime truth boundaries

Runtime-owned truth includes:
- player actions,
- hazard states,
- event ordering,
- extraction lifecycle,
- artifact custody,
- role-limited actions,
- physical traces.

The runtime may expose traces and ambiguity. It may not expose direct guilt proof through macro-systems.

---

# 8. EXPEDITION CONSTITUTION EVOLUTION

The expedition constitution is the symbolic contract that defines what an expedition can lawfully be.

## 8.1 Constitution purpose

A constitution does not describe a single level layout.  
It describes the lawful authored space for:
- topology,
- ecology,
- item/pressure distributions,
- information conditions,
- pacing,
- mutation allowances,
- continuity hooks.

## 8.2 Constitution inheritance

Constitutions must belong to doctrine families and support inheritance:

```text
DoctrineFamily
→ Constitution
→ Variant
→ Mutation Variant
→ Rediscovered Variant
```

Constitutions are not disposable single-use objects. They are evolving species inside authored possibility space.

## 8.3 Constitution fitness

Each constitution should track:
- replay richness,
- social deduction richness,
- fairness stability,
- ontological productivity,
- narrative resonance,
- implementation reliability.

Low-fitness constitutions are not deleted.  
They become rarer or dormant.

## 8.4 Constitution persistence law

No constitution family is erased simply because newer ones are stronger.  
The system prefers high-fitness constitutions while preserving low-frequency recurrence, archival persistence, and rediscovery potential.

---

# 9. ONTOLOGICAL ECOLOGY ENGINE

This engine governs the ecology of categories themselves.

## 9.1 Core principle

Everything important in the architecture must belong to ontology, and ontology must behave ecologically rather than statically.

Categories are not merely labels. They are living participants in:
- competition,
- adoption,
- fragmentation,
- hybridization,
- taboo,
- memory,
- rediscovery.

## 9.2 Ontology domains

The engine must support at least these category domains:
- artifact families,
- chamber families,
- pressure families,
- doctrine families,
- ritual families,
- transformation families,
- taxonomy classes,
- experiment families,
- verification classes,
- residue classes.

## 9.3 Ontological lifecycle

Categories must support this lifecycle:

```text
birth
→ expansion
→ stabilization
→ contestation
→ fragmentation
→ decline
→ dormancy
→ rediscovery
```

Not all categories pass through all stages linearly. The engine may branch or skip stages, but must preserve ecological semantics.

## 9.4 Ontological niches

Every category occupies one or more niches.  
Examples:
- verification niche,
- traversal pressure niche,
- archive classification niche,
- civic trust niche,
- ritual legitimacy niche.

Categories competing for the same niche may:
- displace one another,
- coexist,
- hybridize,
- split into public-specific forms.

## 9.5 Ontological competition

Different categories or interpretations may compete over:
- legitimacy,
- archive indexing,
- public adoption,
- doctrine use,
- preparation culture.

This is not just vocabulary drift. It must have systemic consequences.

## 9.6 Ontological hybridization

Nodes may hybridize when constitution, pressure, and ecology conditions permit.  
Hybridization may occur between:
- chamber and pressure lineages,
- artifact and ritual lineages,
- doctrine and taxonomy lineages,
- experiment and ontology lineages.

Hybridization must remain legible and fairness-safe.

## 9.7 Negative space support

The ontology engine must support absence as an authored condition:
- extinct classes,
- taboo classes,
- missing verification methods,
- dormant ritual modes,
- categories known only through residue.

Absence must create cultural workarounds, myth, substitution, or longing, not merely content removal.

---

# 10. CULTURAL SIMULATION ECOSYSTEMS

This layer models civilization’s relationship to the delve.

## 10.1 Scope

The cultural simulation must model:
- institutions,
- publics,
- belief systems,
- archive schools,
- certifiers,
- regulators,
- markets,
- contraband networks,
- faith communities,
- operator cultures,
- local populations.

## 10.2 Parallel publics

The simulation must preserve distinct publics, not flatten them into one audience.

At minimum, the architecture must support:
- expedition/operator public,
- archive/intellectual public,
- faith/ritual public,
- civic/regulatory public,
- market/contraband public,
- spectator/media public,
- local-zone public.

Each public differs in:
- what it remembers,
- what it sensationalizes,
- what it forgives,
- what it denies,
- what it canonizes,
- what it considers legitimate.

## 10.3 Legitimacy economy

The cultural simulation must support legitimacy as a contested, multi-source economy.

Legitimacy sources include:
- predictive success,
- historical prestige,
- public popularity,
- moral authority,
- institutional power,
- ritual tradition,
- technical competence.

Legitimacy may be:
- gained,
- borrowed,
- concentrated,
- fragmented,
- revoked,
- partially restored.

## 10.4 Actor evolution

Cultural actors may:
- split,
- reform,
- radicalize,
- decline,
- revive,
- rebrand,
- merge,
- survive underground.

Institutions must behave like evolving species, not static menu entries.

## 10.5 Cultural energy

Each actor and ecosystem has cultural energy that affects:
- activity,
- spread,
- interpretive aggression,
- adoption velocity,
- resilience under shock.

Energy may be driven by:
- scandal,
- wonder,
- discovery,
- lesion exposure,
- civic action,
- public fixation.

## 10.6 Ecosystem resilience

Each interpretive ecosystem must track resilience.  
Low resilience means shocks propagate quickly.  
High resilience means institutions absorb contradictions without collapse.

## 10.7 Rumor simulation

Rumors are not text flavor. They are dynamic information objects with:
- source class,
- spread velocity,
- emotional charge,
- contradiction risk,
- half-life,
- institutional adoption chance,
- resurfacing triggers.

## 10.8 Archive interpretation

The archive stores truth-derived interpretations, not raw truth rewrite.

Archive systems may:
- relabel,
- recategorize,
- increase/decrease confidence,
- cross-link runs differently,
- elevate alternative summaries.

Archive systems may not:
- alter authoritative event truth,
- fabricate runtime outcomes.

## 10.9 Memory lesions

The cultural simulation must support rare, high-gravity memory lesions:
- stable absences,
- missing canonical records,
- unresolved famous contradictions,
- partial but formative records.

Lesions must be rare and consequential, not ambient noise.

---

# 11. NARRATIVE PRESSURE ECOSYSTEM

This engine governs macro-scale civilizational motion while preserving core-loop stability.

## 11.1 Pressure pairs

The architecture must model at minimum these ecological tensions:

- stability ↔ disruption
- authority ↔ skepticism
- fear ↔ curiosity
- certainty ↔ ambiguity
- ritual ↔ innovation
- extraction ↔ stewardship

These are not single sliders to maximize. They are balancing tensions.

## 11.2 Pressure function

Narrative pressure may influence:
- what experiments express strongly,
- what constitutions are favored,
- what publics are activated,
- what categories split or stabilize,
- what archive disputes intensify,
- what wonder allocation is appropriate.

Narrative pressure may not alter runtime legality.

## 11.3 Pressure cascades

The engine must support cascades:
- legitimacy shock → taxonomy war → rumor spread → civic reaction → archive reinterpretation
- discovery wave → wonder surge → public fascination → institutional appropriation
- lesion surfacing → archive rupture → prestige collapse → rediscovery cycle

## 11.4 Narrative resonance

Events that resonate with prior legends, lesions, scandals, or failures may gain amplified impact.  
This creates gravity wells and historical memory without runtime distortion.

## 11.5 Cultural momentum

The engine must track civilizational momentum:
- how fast change is occurring,
- whether the culture is sluggish, brittle, accelerating, or exhausted.

Momentum affects expression pacing, not mechanics.

## 11.6 Pressure safety law

No pressure configuration may:
- create multi-year core-loop instability,
- tank artifact trust below the core-loop floor,
- collapse legibility below threshold,
- produce ambient incoherence.

Macro volatility belongs in interpretation and culture, not in mechanical reality.

---

# 12. DELVEMIND EXPERIMENTAL ONTOLOGY

DelveMind is not running a finite catalog of tests.  
It maintains a living experiment space.

## 12.1 Core principle

DelveMind forms hypotheses about humanity under delve conditions.

It does not merely “generate content.”  
It conducts bounded civilizational inquiry.

## 12.2 What DelveMind may test

The experimental ontology must be able to test:
- trust formation,
- authority dependence,
- ambiguity tolerance,
- curiosity vs fear,
- ritual dependence,
- stewardship vs greed,
- classification hunger,
- epistemic humility,
- public divergence,
- memory discipline,
- legitimacy formation,
- wonder receptivity,
- resilience under scandal,
- institutional overreach,
- civilizational misuse of partially reliable systems.

## 12.3 Experiment families

Experiments may belong to families such as:
- authority experiments,
- trust experiments,
- ritual experiments,
- counterfeit experiments,
- taxonomy experiments,
- memory experiments,
- wonder experiments,
- stewardship experiments,
- public fracture experiments,
- negative-space experiments.

These are not fixed templates. They are organizing lineages.

## 12.4 Experiment programs

A family may spawn medium-horizon programs.

Example pattern:
- family: authority
- program: certification reliance under counterfeit pressure

Programs may recur, branch, pause, synthesize, or reappear.

## 12.5 Experiment states

Experiments must not be deleted merely because stronger experiments exist.

Canonical states:
- active
- recurring
- rare
- dormant
- archival
- foundational

This persistence law is mandatory.

## 12.6 Experiment topologies

The engine must support at least:
- linear,
- branching,
- nested,
- recursive,
- convergent,
- oscillatory experiments.

## 12.7 Experiment lineage

Experiments must support:
- ancestry,
- branch history,
- synthesis history,
- recurrence weights,
- rediscovery hooks.

This allows DelveMind to build long-horizon lines of inquiry rather than disconnected seasonal gimmicks.

---

# 13. EXPERIMENT GRAMMAR

Experiments are generated symbolically through grammar slots.

## 13.1 Core grammar

```text
Experiment :=
    Target
    + Axis
    + Stressor
    + Ontological Condition
    + Cultural Medium
    + Time Horizon
    + Observation Contract
    + Fairness Bounds
```

## 13.2 Target slot

Possible targets include:
- operators,
- institutions,
- publics,
- archive systems,
- taxonomy systems,
- artifact careers,
- ontology itself,
- mixed civilizational layers.

## 13.3 Axis slot

Possible axes include:
- trust,
- authority dependence,
- ambiguity tolerance,
- curiosity,
- fear,
- ritual reliance,
- stewardship,
- greed,
- legitimacy formation,
- classification hunger,
- wonder receptivity,
- memory fidelity.

## 13.4 Stressor slot

Possible stressors include:
- contradiction,
- scarcity,
- lesion surfacing,
- counterfeit pressure,
- taxonomy split,
- rediscovery,
- hybridization,
- prestige shock,
- rumor acceleration,
- fossil activation,
- anomaly cluster,
- public schism.

## 13.5 Ontological condition slot

Possible conditions include:
- stable categories,
- contested categories,
- missing verification classes,
- taboo category activation,
- category split,
- niche overcrowding,
- hybrid lineage emergence,
- fossil density increase,
- rediscovered extinct categories.

## 13.6 Cultural medium slot

Possible media include:
- archive framing,
- rumor ecology,
- civic response,
- public naming,
- legend pressure,
- market reaction,
- codex conflict,
- chamber reputation drift.

## 13.7 Time horizon slot

Possible horizons:
- expedition,
- run cluster,
- season,
- era.

## 13.8 Observation contract slot

Observation must use lawful signals only.  
Potential channels include:
- extraction behavior,
- verification use,
- legitimacy movement,
- archive relabeling,
- rumor uptake,
- public divergence,
- category adoption,
- canonized failure formation,
- wonder retention.

## 13.9 Fairness bounds slot

Each experiment must declare:
- artifact trust floor,
- mechanic legibility floor,
- strategic readability floor,
- role fairness requirement,
- runtime non-mutation requirement,
- no-hidden-targeting requirement.

---

# 14. EXPERIMENT COMPILER AND EXPRESSION PLANNER

## 14.1 Purpose

The grammar creates symbolic experiments.  
The compiler turns them into lawful system-facing outputs.

## 14.2 Compile targets

The compiler may output into:
- constitution weighting,
- ontology weighting,
- artifact career pressure,
- public activation,
- archive framing bias,
- legitimacy stress,
- rumor volatility,
- pressure ecosystem bias,
- wonder allocation.

## 14.3 Expression modes

The planner must support:
- whisper mode,
- fracture mode,
- crisis mode,
- renaissance mode,
- fossil mode,
- mirror mode.

These modes define how strongly and where an experiment manifests.

## 14.4 Non-forcing rule

DelveMind does not force outcomes.  
It shapes authored possibility and interpretive conditions only.  
All runtime outcomes remain lawful and player-driven.

This rule must appear in code comments, planning notes, and execution docs exactly.

---

# 15. EVALUATION ENGINE

The evaluation engine assesses experiment outcomes and architectural health.

## 15.1 Evaluation dimensions

Every live experiment should be scored on:
- hypothesis yield,
- cultural richness,
- ontological productivity,
- narrative resonance,
- fairness stability,
- readability,
- replay distinctiveness,
- long-horizon branch value.

## 15.2 Evaluation outputs

Possible outcomes:
- strengthen hypothesis,
- weaken hypothesis,
- split hypothesis,
- synthesize into broader theory,
- move experiment to recurring,
- move experiment to rare,
- move experiment to dormant,
- preserve as archival lineage,
- elevate to foundational inquiry.

## 15.3 Anti-noise law

An experiment that produces turbulence without insight is low-fitness, even if it is novel.

## 15.4 Fairness veto

Any experiment that violates fairness floors must be prevented from going live, regardless of theoretical richness.

---

# 16. DELVEMIND LEARNING LOOP

This is the final research loop.

```text
Hypothesis
→ Experiment Design
→ Compile
→ Expedition / Culture Expression
→ Observation
→ Evaluation
→ Hypothesis Update
→ Branch / Synthesize / Recur / Dormancy
```

## 16.1 Meta-learning

DelveMind must also learn about its own research method, including:
- which topologies yield useful results,
- which horizons are too slow or too volatile,
- which publics best expose certain axes,
- which pressure combinations create noise,
- when rediscovering dormant experiments is better than generating new ones.

## 16.2 Self-critique

DelveMind must be allowed to weaken its own assumptions.  
It is not omniscient.  
Its model of humanity must remain revisable.

---

# 17. IMPLEMENTATION ORDER (STRICT)

Codex must obey this build order.

## Phase 1 — Ownership and schema groundwork
Deliver:
- system ownership comments/doc sync,
- base schema files,
- validation harnesses,
- no runtime behavior changes yet.

## Phase 2 — Ontology Engine
Deliver:
- ontology node/lineage structures,
- niche support,
- category lifecycle support,
- persistence/rediscovery semantics.

Do not build experimental logic before ontology exists.

## Phase 3 — Constitution Compiler
Deliver:
- symbolic constitution data structures,
- doctrine inheritance,
- compile outputs for generation-facing systems,
- fairness-bound enforcement.

Do not wire runtime AI decisions here.

## Phase 4 — Cultural Simulation
Deliver:
- actor models,
- legitimacy networks,
- rumor framework,
- archive interpretation structures,
- public divergence support.

Keep this in product/non-runtime layers.

## Phase 5 — Narrative Pressure Ecosystem
Deliver:
- pressure state model,
- momentum/resonance/cascade support,
- safe macro weighting outputs,
- no runtime legality mutation.

## Phase 6 — Experimental Ontology + Grammar
Deliver:
- hypothesis structures,
- experiment structures,
- grammar slots,
- topology support,
- persistence states,
- compile integration points.

## Phase 7 — Evaluation Engine + Learning Loop
Deliver:
- observation aggregation,
- evaluation records,
- branch/synthesis logic,
- recurrence and dormancy logic,
- meta-learning support.

## Phase 8 — Integration and tooling
Deliver:
- developer-facing inspection tools,
- schema validation commands,
- doctrine traceability surfaces,
- fairness gate tests,
- non-parallel architecture verification.

---

# 18. TESTING AND VALIDATION REQUIREMENTS

## 18.1 Runtime protection tests
Prove:
- no experiment can alter runtime legality,
- no ontology or pressure layer mutates host truth,
- event log remains definitive truth source.

## 18.2 Schema tests
Validate:
- experiment schema,
- hypothesis schema,
- ontology schema,
- actor schema,
- pressure schema.

## 18.3 Layer separation tests
Prove:
- product/cultural systems do not become runtime authorities,
- generation systems do not bypass compiler law,
- runtime does not silently consume unvalidated cultural data as truth.

## 18.4 Fairness tests
Prove:
- artifact trust floor preserved,
- mechanic legibility floor preserved,
- no hidden player targeting,
- skill validity preserved.

## 18.5 Persistence tests
Prove:
- experiments do not disappear,
- dormant/rare/archival states work,
- old lineages can recur lawfully.

## 18.6 Explainability tests
Prove:
- a live experiment can be inspected symbolically,
- a constitution can be inspected symbolically,
- cultural shifts can be traced to lawful causes rather than ad-hoc magic.

---

# 19. CODEX EXECUTION COMMANDMENTS

These are binding.

## 19.1 Do not create parallel architecture
Extend live owners. Do not create duplicate truth paths.

## 19.2 Do not merge DelveMind into runtime
DelveMind is not a runtime authority.

## 19.3 Do not implement hidden forcing logic
No forced outcomes, no behind-the-scenes cheating.

## 19.4 Do not collapse the game into abstract simulation
Expeditions remain primary. Culture is reactive and steering-aware, not the replacement for play.

## 19.5 Do not delete weak experiments
Reduce weight, do not erase lineages.

## 19.6 Do not allow macro systems to break artifact centrality
Artifacts always remain core objective anchors.

## 19.7 Do not allow category systems to become decorative
Ontology must have systemic consequence.

## 19.8 Do not implement incomplete lower layers by guessing future upper layers
Respect implementation order.

---

# 20. PROHIBITED ANTI-PATTERNS

Codex must not introduce any of the following:

- runtime AI arbitration,
- second event truth models,
- direct cultural-to-runtime legality mutation,
- season-wide “nothing is trustworthy” gameplay collapse,
- hidden per-player bias systems,
- category churn with no effect,
- lore-only cultural simulation,
- experiment deletion by replacement,
- vague magic state blobs with no schema,
- parallel archive systems,
- duplicate constitution compilers,
- forcing language that implies DelveMind chooses outcomes instead of conditions.

---

# 21. FINAL DEFINITION

The DelveMind system for The Delve Protocol is:

> **A lawful, symbolic, multi-layer world-model intelligence that authors expedition constitutions, evolves ontological ecologies, simulates civilizational interpretation, balances narrative pressures, generates and evaluates experiments about humanity under delve conditions, preserves those experiments as persistent lineages of inquiry, and learns from their outcomes without ever violating runtime determinism, host authority, artifact centrality, fairness, or core gameplay legibility.**

That is the final architecture.

---

# 22. FINAL LAUNCH CONDITION FOR CODEX

Codex may treat this document as fully authoritative and implementation-ready only if it obeys all of the following:

- Use this document as the single source-of-truth.
- Do not invent contradictory architecture.
- Respect the ownership map exactly.
- Respect the implementation order exactly.
- Respect runtime protection laws absolutely.
- Preserve the ecology/experiment philosophy at every layer.
- Prefer inspectable symbolic systems over opaque magic behavior.
- Preserve old experiments as persistent lineages.
- Keep expeditions primary and culture secondary but powerful.
- Never force outcomes.

---

# 23. END STATE

When implemented correctly, this architecture produces:

- a deterministic, fair multiplayer expedition game,
- AI-authored but lawful expedition variety,
- evolving ontological categories,
- living cultural interpretation,
- shifting narrative pressure without mechanical incoherence,
- DelveMind as a real civilizational research intelligence,
- continuity and memory that matter,
- long-horizon change without core-loop decay,
- a game world that learns without cheating.

This is the final canonical doctrine.

---
