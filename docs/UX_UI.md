# UX and UI Design

## Core Philosophy
The UI must be radically minimalist to keep the player's cognitive focus on the physical platforming space and traversable terrain. Suspicion tools must support play without stopping the run. Deduction happens by reading ambiguous traces in the cavern, not the HUD.

## Outer-Loop Product Shell
- **Lobby as Hub:** The Lobby is now also the lightweight product shell. It includes profile, mastery, collection, codex, cosmetics, settings, and last-run surfaces without interrupting the host/join/start flow used by multiplayer and proof automation.
- **Fair Progression Surface:** Account rank, role mastery, codex discoveries, notebook themes, banners, and titles are all local and cosmetic-facing. They help identity and retention without changing match power.
- **Post-Run Continuity:** Returning to the lobby should immediately surface the last run's result, earned progression, report path, and next unlock so players have a reason to queue again.
- **Home as Command Surface:** The Home tab should answer "what do I do now?" with one dominant next action, one supporting reason, and one optional secondary route. It should bridge last run, current session state, and replay momentum without turning into a text wall.
- **Session Reliability Surface:** The hub should also show current session state, reconnect availability, and controlled join-denial messaging so a dropped or late client lands back in a useful shell instead of a dead end.
- **Conservative Reconnect Policy:** Mid-run reconnect remains fairness-safe rather than magical. The shell should tell the player whether a reconnect offer is ready now or whether they must wait for the lobby to return, and interrupted runs should be preserved in history without pretending the run was restored.
- **Browsable Depth:** The shell should behave like a real product hub, not a raw debug panel. Collection and codex tabs now support section browsing and detail panes; cosmetics support ownership/equip previews; profile surfaces show next reward previews, milestones, and recent runs.
- **Reviewable History:** The Profile tab should support readable run-history browsing by interruption, role, outcome, story tone, and communication density so players can quickly answer "what happened last time?" without turning history into a debug database.
- **History Browser Rhythm:** The run browser should keep filter, sort, selected run, and compare target stable across ordinary shell refreshes. Labels stay compact and scan-fast; only the selected-run detail packet expands into a richer multi-section review.
- **Compare With Context:** History compare should prefer meaningful contrast inside the active browsing context instead of arbitrary adjacency. Players should be able to tell, at a glance, whether the selected run was more dramatic, more rewarding, more communication-heavy, or interrupted compared with the best peer run in view.
- **Selected Run First:** The selected run should remain the obvious primary object in the Profile tab. Ordinary shell refreshes should preserve selected-run context and compare target when possible instead of bouncing the browser unexpectedly.
- **Selected-Run Emphasis:** Profile run lists should keep the selected run visually obvious (including controller/large-text use) so focus and compare context remain legible under frequent shell refreshes.
- **Why Reopen This Run:** Compare output should help answer "why reopen this run instead of that one?" with brief, contrast-driven lines rather than repeating labels or mirroring the report.
- **Recent Run Curation:** Recent-run surfaces should deliberately curate diverse standout runs such as latest, dramatic, rewarding, and interrupted, avoiding duplicates where history depth allows.
- **Helper-Only Memory Signals:** Strongest-run clusters, interruption-pattern recovery summaries, and richer compare digests should remain helper-only by default for tuning/playtest workflows.
- **Home Action Priority:** The Home tab should privilege one dominant next action, one supporting reason, and one optional secondary route. It should not flatten reconnect, review, and replay momentum into a single undifferentiated summary block.
- **Home Density Discipline:** Home remains action and momentum first. `Continue` should stay to a few short lines, `RecentRuns` should remain a compact strip, and `LastRun` should stay concise rather than expanding into Profile-style multi-section detail.
- **Honest Party Continuity:** The shell may talk about regrouping, continuing with the current lobby, waiting for the host lobby, or rejoining later, but it must not imply real party persistence, rematch reservation, or in-run recovery that the authoritative session layer does not support.
- **Controller-First Flow:** The shell supports shoulder-button tab switching and explicit back behavior (Esc / B) so outer-loop navigation works without relying on mouse-only assumptions.
- **Shell Finish Standard:** Each Home/Profile panel should answer one clear question, preserve obvious scan order under large-text settings, and avoid overlapping purpose with nearby panels.

## What is On-Screen During Traversal
- **Vitals & Resources:** Clean, highly readable health pips and resource trackers (Ropes, Bombs). 
- **Physical Evidence:** A subtle visual indicator of the currently carried artifact (if any), adhering to the one-carry mechanic to visually confirm squad roles and burdens. 
- **Socially Readable Clues (In-World):** Diegetic tells like footprint decals in dust layers, fluctuating lantern light radiuses, bomb blast scorching, and faint corruption traces on artifacts that exist purely in the physical world.
- **Objective Clarity:** The traversal HUD should always surface the current run phase and one concise objective line, such as carrying an Artifact to Extraction or holding the extraction stabilization window.
- **Room Readability:** Room labels, route markers, exposed evidence pedestals, and hazard warning lanes should make the current space legible without turning it into a tutorial wall. Players should be able to read where the safe route, fast route, and public clue surfaces are at a glance.

## What Stays Lightweight During Platforming
The action layer must never obscure traversal vision. Contextual prompts must tell the player what class of object they are interacting with and why it matters: `Take Artifact`, `Take Tool`, `Take Relic`, `Use Zipline Kit`, `Inspect E4`, `Hold Artifact in Extraction`.

## The Suspicion Notebook (Private vs Public vs Contextual)
- **Private & Local:** The notebook tracking suspects, locations, and odd trap timings is kept entirely private to the local client's RAM.
- **Non-blocking Flow:** Invoked as a highly transparent, non-blocking screen overlay. Players utilize rapid "macro quick-tagging" (e.g., tagging a player as "Alibi" or "Suspect" hitting single shortcut keys) to instantly annotate without interrupting platforming momentum for more than a fraction of a second.
- **Readable Support Layer:** The notebook and hint systems should reinforce the active run without becoming a second game. They should answer "what should I do next?" and "what just changed?" in one or two short lines.
- **Platforming-Safe Callouts:** `1`, `2`, and `3` should provide lightweight public room callouts (`Danger`, `Regroup`, `Artifact`) that help teams communicate mid-jump without opening a menu or revealing private role information.
- **Communication Review:** Callouts should remain public-only and anonymous, but the shell and last-run review can summarize how communication shaped the run (`Danger`, `Regroup`, `Artifact`) to support later discussion.

## Information Bounds & Tool Availability
- **Public & Contextual:** The radial ping wheel allows for "Trust Me" or "Danger Here" diegetic pings. Placed physically in the space and heavily contextual based on line of sight.

## End-of-Run Review Experience
- **Sudden Halt:** A dramatic, impactful transition stopping the chaotic cavern run once extraction completes or failure occurs.
- **The Revealing Timeline:** A deeply satisfying, scrollable physical reconstruction (e.g., `Tick 4022: Hazard spike triggered. Tick 4028: P4 died. Tick 4035: P2 picked up Artifact 1.`).
- **Preserving the Mystery:** The timeline clarifies *outcomes* and *major interactions*, but it does NOT perfectly solve every moment. It reveals that a trap fired, but not *why* it fired. It reveals an artifact was forged, but not *where* or *by whom*.
- **Resolution Debate:** Roles are revealed natively alongside the Timeline data. Players use the objective facts to fuel heated debates over ambiguous intent, resulting in wildly different interpretations of the exact same event log.
- **Useful Recap:** The end screen and exported report should clearly state run outcome, artifact result, role result, core stats, action summary, public facts, and private notes without reading like raw debug output.
- **Argument Fuel:** A short `Key Clues` subsection should surface the most socially arguable public route changes, blasts, inspections, and extraction beats without collapsing ambiguity.
- **Room-Scale Memory:** The recap should also help players remember room-local moments like ropes rewriting a route, trap timing pulses, artifact reroutes, and exposed extraction holds so the post-run argument has real anchors.
- **Progression Handoff:** The recap now also feeds the outer-loop profile shell by recording local-only XP, mastery, codex discoveries, and last-run summary data after `run_ended`.
- **Retention Readability:** The last-run surface should also communicate why progress was earned: XP breakdown, newly unlocked cosmetics/milestones, and a short story-density diagnostic to help players remember why the run felt dramatic.
- **Interrupted Run Honesty:** If a session ends because the host disconnects or a runtime join is denied, the shell should surface that as an interrupted run with reconnect policy context instead of awarding progression or pretending it resolved normally.
- **Social Settings Seam:** Voice remains optional and fairness-safe. The shell now supports voice-mode, push-to-talk, and mute settings so future communication features can integrate without rewriting profile/settings data.
- **Communication Policy Surface:** The shell should explain what voice settings mean right now, when room callouts remain the correct platforming-safe fallback, and how future session voice would fit the lobby/run lifecycle without implying that transport already exists.
- **Voice Policy Specificity:** Voice surfaces should explicitly distinguish mode, push-to-talk behavior, mute behavior, and session lifecycle readiness while staying honest that transport is not active yet.
- **Future-Ready, Not Fake-Complete:** The shell can explain how future speaking indicators or live session voice would conceptually fit, but it should never imply that voice transport is already active when only the seam exists.
- **Curated Review, Not Raw Replay:** Home/Profile review surfaces should summarize and curate remembered runs. They must not turn into a second report viewer or replay inspector.
