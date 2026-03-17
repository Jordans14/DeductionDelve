# SYSTEM_CONSTANTS.md

This document binds the implementation constants that the design architecture leaves conceptual.

It removes final ambiguity while preserving the architecture’s intended feel, pacing, fairness, and long-horizon ambition.

---

## 1. Current implementation targets

These values are binding for the **current implementation era**.

### 1.1 Standard expedition band
- canonical standard expedition size: **8–12 players**
- reduced live protocol-state labels remain:
  - `Exposure`: `1`
  - `Intimate`: `2–3`
  - `Fracture`: `4–7`
  - `Expedition`: `8–12`

### 1.2 Run length target
- target rooms per run: **10–12**
- acceptable variance band: **8–14** only when deterministic generation and branch context require it
- target duration: **14–18 minutes**
- acceptable variance band: **12–20 minutes** only when generation and pacing still preserve readability, extraction pressure, and burden meaning

### 1.3 Crawl structure
- crawls are **indefinite by design**
- crawls should naturally segment into chapters through:
  - branch divergence
  - Archive turning points
  - major artifact discoveries
  - repeated pressure signatures
  - crawl-memory reframing
- players may bank, leave, return, and deepen later without destroying crawl identity

### 1.4 Carry model
- major artifacts carried at once: **1**
- tools carried at once: **2**
- relics / passive modifiers: stack across the crawl under bounded effect rules
- world objects: contextual and temporary, not persistent burden-stack inventory

### 1.5 Current item-distribution arc
Each run should bias item placement through three phases.

#### Early phase
- traversal tools
- navigation aids
- basic survival / route-support equipment

#### Mid phase
- ambiguous artifacts
- burden modifiers
- route-decision pressure objects
- confrontation and rescue stressors

#### Late phase
- extraction-pressure items
- rescue-opportunity items
- end-state confrontation or deception pressure items

Duplicate suppression should apply when meaningful alternatives exist.

### 1.6 Run end conditions
A run may end by:
1. authentic artifact extraction
2. counterfeit / corrupted extraction
3. total expedition collapse / wipe
4. protocol-enforced closure where constitutionally allowed
5. hard interruption / disconnect termination
6. artifact irrecoverability state resolution through the irrecoverability doctrine

### 1.7 Determinism
Generation and doctrine shaping must remain deterministic from:
- run seed
- session context
- expedition composition
- continuity state
- stored facts used for interpretation

---

## 2. Future canonical extremes (not for current implementation wave)

These values are canonically allowed but are **not current implementation targets**.

### 2.1 Rare large expeditions
- rare event target: **24–32 players**
- exceptional, not baseline

### 2.2 Mythic expedition ceiling
- mythic extreme future event ceiling: **64–128 players**
- extremely rare
- not a current matchmaking or baseline implementation target
- must not be used to justify early broad-population architecture

### 2.3 Relay-scale population adaptation
- relay recombination at scale remains future-phase
- topology-level population adaptation remains future-phase
- large-population pressure differences remain future-phase until the current reduced-label live layer is stabilized

### 2.4 Cookbook scale
- Cookbook fragments, holders, network recognition, anti-Protocol descent, and collapse events remain future-phase
- no current implementation wave should treat Cookbook as baseline progression

---

## 3. Interpretation rules for implementing agents

- If a constant is listed under **Current implementation targets**, it may guide current implementation work.
- If a constant is listed under **Future canonical extremes**, it may inform architecture compatibility only.
- Future canonical extremes must not be implemented early unless the active wave explicitly reaches that phase safely and constitutionally.
- If a live support doc or roadmap note is more restrictive than a future canonical extreme, the more restrictive current-wave rule wins.
