# The Delve Protocol

The Delve Protocol is a social exploration game built around a living labyrinth experiment where players descend through dynamic crawl networks, survive dangerous branches, and uncover the hidden nature of the Delve itself.

## Repository Scope
- `godot/`: live Godot project and current playable implementation
- `docs/`: canonical design doctrine, implementation architecture, testing guidance, and future-phase expansion references
- `scripts/`: test and proof automation

## Current State
- The live repo currently implements a host-authoritative traversal-first social deduction slice with deterministic generation, role secrecy, artifacts, sabotage pressure, and a unified shell.
- A live AI Delve directive layer now reads local profile continuity plus session/gameplay context to shape run setup and public-safe doctrine carryover without owning run truth.
- A live visual governance layer now owns shell symbols/palette, room visual packets, entity presentation contracts, motion hierarchy, and background honesty without altering mechanics.
- The current next-tier live layer now also deepens deterministic branch personality, item ecology signaling, crawl identity comparison, and compact Archive/world-memory carryover on the same owner paths.
- The finalized game identity is **The Delve Protocol**. Some doctrine described in the docs is a future implementation phase and is marked as such.
- Documentation is intentionally split between:
  - current implementation ownership and constraints
  - finalized design targets to build toward without rewriting the owner tree

## Canonical Design Docs
- [THE_DELVE_PROTOCOL](d:/DeductionDelve/docs/THE_DELVE_PROTOCOL.md)
- [NARRATIVE_WORLD_BIBLE](d:/DeductionDelve/docs/NARRATIVE_WORLD_BIBLE.md)
- [CRAWL_NETWORK_ARCHITECTURE](d:/DeductionDelve/docs/CRAWL_NETWORK_ARCHITECTURE.md)
- [PROTOCOL_STATES](d:/DeductionDelve/docs/PROTOCOL_STATES.md)
- [AI_INHABITANTS](d:/DeductionDelve/docs/AI_INHABITANTS.md)
- [ARCHIVE_SYSTEM](d:/DeductionDelve/docs/ARCHIVE_SYSTEM.md)
- [COOKBOOK_SYSTEM](d:/DeductionDelve/docs/COOKBOOK_SYSTEM.md)

## Implementation Docs
- [ARCHITECTURE](d:/DeductionDelve/docs/ARCHITECTURE.md)
- [GAME_VISION](d:/DeductionDelve/docs/GAME_VISION.md)
- [MECHANICS](d:/DeductionDelve/docs/MECHANICS.md)
- [CORE_LOOPS](d:/DeductionDelve/docs/CORE_LOOPS.md)
- [LEVEL_GEN](d:/DeductionDelve/docs/LEVEL_GEN.md)
- [ROLES_AND_DECEPTION](d:/DeductionDelve/docs/ROLES_AND_DECEPTION.md)
- [ITEMS_AND_SYNERGIES](d:/DeductionDelve/docs/ITEMS_AND_SYNERGIES.md)
- [NETWORKING](d:/DeductionDelve/docs/NETWORKING.md)
- [UX_UI](d:/DeductionDelve/docs/UX_UI.md)
- [TESTING](d:/DeductionDelve/docs/TESTING.md)
- [ROADMAP](d:/DeductionDelve/docs/ROADMAP.md)
- [DESIGN_ANCHOR](d:/DeductionDelve/docs/DESIGN_ANCHOR.md)

## Working Rules
- Current gameplay truth remains authoritative in the existing run/network owner tree.
- Product/narrative layers remain read-only and deterministic relative to run truth.
- Documentation for future phases must not contradict the current owner model or imply duplicate systems.

## Validation
- Run tests: `./scripts/run_tests.ps1`
- Run headless proof: `./scripts/run_headless_proof.ps1`
- The proof lane now uses bounded retry to recover from rare transient pre-verify stalls instead of hanging indefinitely.
