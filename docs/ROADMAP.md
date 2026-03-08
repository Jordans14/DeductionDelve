# Roadmap

## Cross-Doc Alignment Summary
- **Intended Genre Identity:** A tense cooperative extraction platformer where *Spelunky*-style traversal risk and *Isaac*-style item synergies generate the plausible deniability required for true Social Deduction. 
- **Core Player Loop:** Navigate procedural caves → Survive physics-based hazards → Interact with physical evidence → Make inferences based on platforming behavior, environmental traces, and timeline facts → Extract.
- **Determinism Philosophy:** The Host owns the infallible mathematical truth of the physics sandbox. The central run seed dictates every aspect of the map layout and RNG sub-streams entirely.
- **Host Authority Model:** Clients are dumb predictive terminals; the Host maintains rigid network authority boundaries for all interactions, drops, and collisions.

## Anti-Scope-Creep Rules
1. **No External Mini-games:** All deduction and gameplay must arise organically from physical play, platforming, and traversing the cavern.
2. **No Abstract Voting:** We do not pause the run for "Emergency Meetings" or UI-driven debate rounds. Narrative flow is unbroken.
3. **No Hard-Proof Investigation Tools:** All deduction tools rely on probabilistic inference. Do not build mechanics that definitively brand players "Guilty" or "Innocent."
4. **Platforming is Core:** Traversal is the game. Do not dilute the focus by turning the game into a pure action-combat roguelite or endless RPG.

## Open Questions / Design Risks
1. **Pacing vs Paranoia:** Can we ensure the platforming is fast and lethal enough to be fun, but paced enough that players have physical time to observe each other's suspicious behavior?
2. **Item Synergy Balance:** Will tool combinations (e.g., jump-buffs + stealth) inevitably create an edge-case that accidentally breaks network synchronization or trivially exposes the Veil?
3. **The Ambiguity Threshold:** Ensuring the Warden’s “probabilistic scan” feels genuinely useful to use without removing reasonable doubt and ruining plausible deniability.

---

## 10-Milestone Finish Plan (From Current State)

### Milestone 1: Platforming & Traversal Sync Hardening
Prioritize securing buttery-smooth client prediction and Host-authoritative correction for the existing advanced cave traversal mechanics. Finalize seamless camera transitions across cavern boundaries.

### Milestone 2: Rigid-Body Physics Tools Integration
Implement fully synced physical interaction items that alter the structural environment: Throwable Bombs (using predictive arcs and terrain destruction) and deployable Ropes (dynamically modifying climbable collision masks).

### Milestone 3: Lethal Hazard & Room Grammar Expansion
Expand the procedural room generation to feature deep, lethal traps including crush-blocks, dart dispensers, and collapsing bridges. Guarantee all traps possess inputs for the Veil's "timing nudge" sabotage mechanic.

### Milestone 4: The 8-Item Core Sandbox
To avoid early complexity overload, implement a highly focused initial Vertical Slice item set of exactly 6–8 tools demonstrating core manipulation:
1. Signal Control (e.g., Lantern Snuffer)
2. Mobility Change (e.g., Heavy Boots)
3. Environment Manipulation (e.g., Bomb Expander)
4. Forensics (e.g., Timeline Bookmark)
Rigorously validate these before expanding.

### Milestone 5: Forensic Traces & Environmental Tells
Flesh out the socially readable environmental clues: dust trails, footprint persistence, bomb blast marks, and visual corruption on manipulated artifacts. Dial in the Warden's scanning probability algorithms.

### Milestone 6: The Suspicion UX Overhaul
Replace the debug HUD completely. Convert the notebook tracking tool into a sleek, highly transparent diegetic overlay featuring rapid macro quick-tagging, allowing players to instantly log alibis without pausing platforming flow.

### Milestone 7: Deep Sabotage & Scavenger Tooling
Enhance Veil tools (decoy ping emitters, fake footprints) to manipulate environmental tells. Empower the Scavenger with tools to reroute artifacts and exploit confusion symmetrically.

### Milestone 8: AI Extraction Pressure ("The Ghost")
Develop a relentless, pathfinding "Warden Ghost" entity that aggressively hunts dawdling players late in the run. This enforces the Escalating Pressure arc, preventing infinite loitering and forcing messy platforming showdowns naturally.

### Milestone 9: Audio-Visual Diegetic Polish
Execute a comprehensive aesthetics pass. Implement dynamic point lighting, shadow casting, ambient biome color grading, and critical audio cues (exact bomb bounce echoes) to allow nuanced tracking through lighting and sound.

### Milestone 10: Beta Vertical Slice & Playtest Hardening
Execute extensive external network fuzz tests, patch desync vectors, nail the final end-of-run replay screens (ensuring key events are revealed but mystery remains), and launch the locked vertical slice for major external playtesting.
