# Archive System

See also: [THE_DELVE_PROTOCOL](d:/DeductionDelve/docs/THE_DELVE_PROTOCOL.md), [NARRATIVE_WORLD_BIBLE](d:/DeductionDelve/docs/NARRATIVE_WORLD_BIBLE.md), [COOKBOOK_SYSTEM](d:/DeductionDelve/docs/COOKBOOK_SYSTEM.md).

## Archive Role
The Archive is both:
- the public cultural memory surface
- the deterministic interpretive layer behind that same surface

It records not only what happened, but how crawls, branches, items, pairs, crews, and legends are being culturally interpreted.

There is no second archive owner or hidden gameplay-authority archive in the live repo.

## Archive Surfaces
The Archive should surface:
- recent crawl cases
- branch echoes
- item-lineage interpretations
- relationship and crew echoes
- world fascination topics
- shorthand references once a story becomes culturally dense enough

The live implementation already routes Archive behavior through the existing Codex shell path rather than a parallel UI.

## Behavioral Pattern Analysis
The Archive compares:
- current incident
- prior echo
- current myth layer
- what pattern matters
- what to watch next

The Archive must remain concise and useful. It should not become a lore dump or encyclopedia wall.

## Current Live Data Path
- [profile_service.gd](d:/DeductionDelve/godot/src/product/profile_service.gd) applies stored run records.
- [run_story_diagnostics.gd](d:/DeductionDelve/godot/src/product/run_story_diagnostics.gd) derives diagnostics from run facts plus public-safe Delve carryover only; host-only internals are stripped before product interpretation.
- [framing_service.gd](d:/DeductionDelve/godot/src/product/framing_service.gd) compresses those diagnostics into compact shell-safe doctrine/governance lines reused by Home, Crawl, and Archive outputs.
- [archive_service.gd](d:/DeductionDelve/godot/src/product/archive_service.gd), [crawl_service.gd](d:/DeductionDelve/godot/src/product/crawl_service.gd), and [world_memory_service.gd](d:/DeductionDelve/godot/src/product/world_memory_service.gd) keep continuity on the existing shell path.
- The current live path now also carries compact artifact-lineage, branch-drift, prestige, and cultural-association hints through diagnostics, crawl memory, archive comparison, and world-memory interpretation on that same read-only owner path.
- Hidden Delve causal audits and private control-surface details must not leak onto public surfaces.

## Myth Formation
The Archive helps transform:
- run events into retellable stories
- repeated patterns into myths
- cooled myths into relic echoes
- inversions into meaningful new interpretations

## Crawl Identity Recording
The Archive should record:
- crawl signatures
- turning points
- residue
- branch pressure
- challenge pull
- public heat
- later reinterpretive weight

## Archive Archaeology
Archive archaeology is the practice of noticing:
- present events that resemble older incidents
- branches repeating social shapes
- item stories changing meaning over time
- myths cooling, reviving, or being displaced
- branch reputations hardening or softening across runs
- carried objects drifting from utility into cultural markers

## Current Live Implementation Note
The current repo already has an Archive service on the Codex path. The live implementation now deepens that same path with compact comparison lines, crawl identity carryover, branch reputation drift, and artifact cultural association without introducing a second archive surface or a second truth model.
