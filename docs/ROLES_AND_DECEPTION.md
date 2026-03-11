# Roles and Deception

## Role Philosophy
Roles define how players uniquely interact with the physical cavern, traversal physics, and systemic evidence objects. Deduction occurs continuously through physical play, not abstracted away into isolated voting menus. Every action is observable behavior with multiple interpretations.

1. **Warden (The Investigator):**
   - *Goal:* Secure authentic physical evidence and survive extraction while pinpointing the saboteur through observation.
   - *Mechanics:* Given access to deep forensic interactions. The Warden can physically "Scan" artifacts to receive a **probabilistic authenticity score**. To avoid hard-proof mechanics, this score is intentionally, mathematically inferential and never binary, requiring context to interpret.
   
2. **Veil (The Saboteur):**
   - *Goal:* Poison the squad's extraction attempt with forged evidence or orchestrate lethal accidents without being caught or exiled.
   - *Mechanics:* Highly disruptive manipulation. The Veil can forge evidence manually when physically unobserved. The Veil can also trigger subtle "Action Nudges" on cavern elements (e.g., causing a spike trap to fire slightly ahead of schedule), generating extremely lethal, highly ambiguous platforming "accidents."
   
3. **Scavenger (The Opportunist):**
   - *Goal:* Master of asymmetric information and opportunism. Survives by manipulating routes and benefiting from squad chaos.
   - *Mechanics:* The Scavenger thrives on creating and exploiting profound uncertainty in social dynamics. They reroute artifacts to unauthorized caches, trade false hazard timings, manipulate movement routes to split the party, and intentionally obscure the "truth" simply to ensure their own survival. They are a potent, active agent of confusion, not just a neutral bystander.

## Role Alignment and Scaling
- **Warden** and **Scavenger** are aligned with the expedition. They win when authentic artifacts are extracted and the sabotage plan fails.
- **Veil** is aligned with sabotage. Veils do not automatically know each other in the slice; that keeps plausible deniability readable when lobbies scale upward.
- Recommended deterministic scaling:
  - **1 player:** Warden only (debug/sandbox)
  - **2-8 players:** 1 Warden, 1 Veil, remaining players Scavengers
  - **9+ players:** 1 Warden, 2 Veils, remaining players Scavengers

**Mimic** is intentionally deferred. The current extraction, sabotage, and evidence loops are cleaner without an independent fourth alignment competing with the expedition-vs-sabotage structure.

## Outcome Logic
- **Expedition Success:** an authentic artifact survives the run and completes the extraction window.
- **Sabotage Success:** a counterfeit artifact is extracted, or the expedition fails to extract before the run ends.
- **Personal Survival:** survival matters emotionally and tactically, but it does not currently override team alignment. The slice is cleaner when role victory stays tied to expedition-vs-sabotage outcomes rather than personal scorekeeping.
- **Counterfeit Evidence:** the code still stores counterfeit artifacts under the legacy `is_forged` flag for compatibility, but the player-facing model is cleaner as **authentic** versus **counterfeit** artifacts. Players should understand that “something is wrong with this artifact” without getting hard proof too early.

## Building Plausible Deniability
In this hybrid genre, "Plausible Deniability" must be generated cleanly by the platforming engine's intense risk vectors:
- *Did they drop that bomb exactly on my head intentionally, or because they missed the ledge grab mechanics under pressure?*
- *Did they intentionally grab the faked artifact, or was it a rushed, blind pickup during a hectic cave collapse?*
- *Did they delay extraction to forge an item, or were they simply lost in the lower cavern?*

## Physically Readable Clues
Deduction must come from the environment. Players use distinct, socially readable clues left in the world to accuse and defend:
- **Footprints & Dust:** Traces of who ran toward an artifact cache.
- **Lantern Light Visibility:** Establishing line-of-sight during critical trap triggers.
- **Bomb Blast Marks:** Symmetrical scarring on the environment proving where exactly a physical explosion originated.
- **Artifact Corruption Traces:** Faint, algorithmic visual anomalies on an evidence piece that suggests (but never strictly proves) it has been tampered with.
