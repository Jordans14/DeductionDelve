# UX and UI Design

## Core Philosophy
The UI must be radically minimalist to keep the player's cognitive focus on the physical platforming space and traversable terrain. Suspicion tools must support play without stopping the run. Deduction happens by reading ambiguous traces in the cavern, not the HUD.

## What is On-Screen During Traversal
- **Vitals & Resources:** Clean, highly readable health pips and resource trackers (Ropes, Bombs). 
- **Physical Evidence:** A subtle visual indicator of the currently carried artifact (if any), adhering to the one-carry mechanic to visually confirm squad roles and burdens. 
- **Socially Readable Clues (In-World):** Diegetic tells like footprint decals in dust layers, fluctuating lantern light radiuses, bomb blast scorching, and faint corruption traces on artifacts that exist purely in the physical world.

## What Stays Lightweight During Platforming
The action layer must never obscure traversal vision. Contextual interactive prompts (`[Q] Pick up`, `[R] Steal`, `[F] Forge`) appear functionally as floating text exactly near the object, disappearing the moment the player changes trajectory.

## The Suspicion Notebook (Private vs Public vs Contextual)
- **Private & Local:** The notebook tracking suspects, locations, and odd trap timings is kept entirely private to the local client's RAM.
- **Non-blocking Flow:** Invoked as a highly transparent, non-blocking screen overlay. Players utilize rapid "macro quick-tagging" (e.g., tagging a player as "Alibi" or "Suspect" hitting single shortcut keys) to instantly annotate without interrupting platforming momentum for more than a fraction of a second.

## Information Bounds & Tool Availability
- **Public & Contextual:** The radial ping wheel allows for "Trust Me" or "Danger Here" diegetic pings. Placed physically in the space and heavily contextual based on line of sight.

## End-of-Run Review Experience
- **Sudden Halt:** A dramatic, impactful transition stopping the chaotic cavern run once extraction completes or failure occurs.
- **The Revealing Timeline:** A deeply satisfying, scrollable physical reconstruction (e.g., `Tick 4022: Hazard spike triggered. Tick 4028: P4 died. Tick 4035: P2 picked up Artifact 1.`).
- **Preserving the Mystery:** The timeline clarifies *outcomes* and *major interactions*, but it does NOT perfectly solve every moment. It reveals that a trap fired, but not *why* it fired. It reveals an artifact was forged, but not *where* or *by whom*.
- **Resolution Debate:** Roles are revealed natively alongside the Timeline data. Players use the objective facts to fuel heated debates over ambiguous intent, resulting in wildly different interpretations of the exact same event log.
