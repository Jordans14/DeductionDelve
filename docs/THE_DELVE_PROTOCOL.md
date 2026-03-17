# The Delve Protocol

See also: [ARCHITECTURE](d:/DeductionDelve/docs/ARCHITECTURE.md), [NARRATIVE_WORLD_BIBLE](d:/DeductionDelve/docs/NARRATIVE_WORLD_BIBLE.md), [CRAWL_NETWORK_ARCHITECTURE](d:/DeductionDelve/docs/CRAWL_NETWORK_ARCHITECTURE.md), [PROTOCOL_STATES](d:/DeductionDelve/docs/PROTOCOL_STATES.md), [AI_INHABITANTS](d:/DeductionDelve/docs/AI_INHABITANTS.md), [ARCHIVE_SYSTEM](d:/DeductionDelve/docs/ARCHIVE_SYSTEM.md), [COOKBOOK_SYSTEM](d:/DeductionDelve/docs/COOKBOOK_SYSTEM.md), [UX_UI](d:/DeductionDelve/docs/UX_UI.md).

## Game Overview
The Delve Protocol is a traversal-first social exploration and deduction game set inside a world-spanning labyrinth. Players descend through linked crawls, survive hostile branches, carry burdens, improvise rescues, and interpret each other through physical behavior rather than abstract meeting systems.

## Core Fantasy
- Enter a living expedition culture rather than a disconnected match queue.
- Survive dangerous descents where movement, hesitation, burden, rescue, confrontation, and extraction pressure generate the story.
- Return to a shell that remembers crawls, rivalries, rescues, failures, and cultural fascination.

## The Experiment
At the deepest hidden layer, the Delve Protocol is a planetary-scale behavioral experiment. Public-facing culture does not explain that truth directly. Layer-1-facing language frames the world as an expedition program, a labyrinth, an Archive, a broadcast culture, and a set of escalating challenges.

## Living Labyrinth Graph
The labyrinth is not a single linear dungeon. It is a crawl network made of run nodes, branch gates, relay nodes, echo chambers, and collapse zones. See [CRAWL_NETWORK_ARCHITECTURE](d:/DeductionDelve/docs/CRAWL_NETWORK_ARCHITECTURE.md).

## Relay Node Network
Relay nodes recombine players from different active descents. They are part of the long-term finalized design and should be understood as an extension of the current authoritative networking model, not a second networking architecture. The live codebase still uses a host-authoritative lobby/run model while preserving this future direction.

## Population-Adaptive Protocol
Protocol states shift based on active player density. The social and environmental pressures of an 8-12 player expedition differ from those of a solo exposure descent. See [PROTOCOL_STATES](d:/DeductionDelve/docs/PROTOCOL_STATES.md).

The live repo already uses reduced protocol-state labels for doctrine, generation context, item/loadout interpretation, and visual governance. Full relay-topology adaptation remains future-phase.

## Branch Ideologies
Branches represent distinct experimental conditions. They shape route commitment, burden pressure, witness pressure, rescue climate, confrontation climate, and symbolic place identity. The current implementation already carries branch-family context inside generation and product memory; future phases deepen that into full crawl-network branch ecology. See [LEVEL_GEN](d:/DeductionDelve/docs/LEVEL_GEN.md).

## Current Live AI Delve
A live AI Delve directive layer now operates as a bounded Influence Lattice. The host reads profile continuity, session context, gameplay modeling, and seed state; computes a deterministic run identity; and projects that identity into control surfaces for existing owners to consume. It extends the existing owner tree; it is not a second truth model or a continuous runtime replacement for live run authority.

## Influence Lattice
The live lattice authors tendencies rather than runtime facts.
- It computes a deterministic Primal Force profile across `Trial`, `Deception`, `Discovery`, `Memory`, `Risk`, and `Containment`.
- It activates an interpretive mind roster consisting of `Examiner`, `Trickster`, `Archivist`, `Cartographer`, and `Warden`.
- It assigns temporary run roles such as `Primary Author`, `Countervoice`, `Witness`, `Patron`, `Saboteur`, `Warden`, and `Substrate` so influence remains legible instead of blending into a single weight.
- It lands influence through bounded domains: topology, pacing, pressure grammar, item ecology, symbolic language, group tension, archive interpretation, and convergence vs fragmentation pressure.
- It emits a mandatory Run Identity Summary for host/debug/test use and a reduced public-safe summary for clients and shell/product carryover.

## Readability And Restraint
The live lattice enforces a readability budget.
- A run exposes one pacing profile, a small number of dominant pressure verbs, one or two dominant minds, and a limited motif set.
- Some runs stay restrained, cold, or sparse rather than loudly theatrical.
- Symbolic expression is always honesty-bound. It may suggest active forces and minds, but it must not reveal hidden truth or fabricate interactable world state.
- The client handoff remains public-safe, but it now carries limited authored interpretation such as dominant minds, dominant forces/domains, pacing, pressure grammar, motifs, item ecology bias, group tension bias, archive tone, and convergence axis.

## Current Live Visual Governance
A live visual governance layer now governs room packets, shell symbols, motion hierarchy, palette discipline, and background honesty. It exists to keep presentation legible and doctrine-coherent without leaking truth or changing mechanics.

## AI Inhabitants
Predators, Echoes, and Protocol Agents inhabit the labyrinth as pressure tools rather than generic enemies. See [AI_INHABITANTS](d:/DeductionDelve/docs/AI_INHABITANTS.md).

## The Archive
The Archive is a public cultural memory surface with an interpretive function on that same path. It records runs, crawls, myths, attention cycles, and behavioral echoes without exposing hidden truth too early. See [ARCHIVE_SYSTEM](d:/DeductionDelve/docs/ARCHIVE_SYSTEM.md).

## The Delve Anarchist's Cookbook
The Delve Anarchist's Cookbook is an extremely rare anti-Protocol myth that emerges through anomaly-linked fragments. It is not a normal inventory item and should not be documented or implemented as one. See [COOKBOOK_SYSTEM](d:/DeductionDelve/docs/COOKBOOK_SYSTEM.md).

## Design Pillars
- Experiment-driven world
- Living crawl network
- Relay recombination
- Population-adaptive protocol
- Environmental pressure scaling
- Branch ideology
- AI inhabitants
- Cultural memory
- Anti-Protocol endgame
