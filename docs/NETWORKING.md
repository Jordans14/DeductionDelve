# Networking

See also: [ARCHITECTURE](d:/DeductionDelve/docs/ARCHITECTURE.md), [CRAWL_NETWORK_ARCHITECTURE](d:/DeductionDelve/docs/CRAWL_NETWORK_ARCHITECTURE.md), [PROTOCOL_STATES](d:/DeductionDelve/docs/PROTOCOL_STATES.md), [TESTING](d:/DeductionDelve/docs/TESTING.md).

## Current Live Networking Model
- Host-authoritative ENet multiplayer
- clients send intent and render prediction
- host validates movement, hazards, artifact interactions, and run lifecycle
- lobby and shell share the same top-level scene path
- run start remains a single authoritative path; there is no second transport or shadow session layer

## Truth and Privacy
- run truth remains on the authoritative path
- private role and profile identity are selectively disclosed
- public lobby cards are sanitized for shell continuity
- product-side narrative continuity is local and non-authoritative

## Current Live Delve Handoff
- The host builds a gameplay snapshot from active peers, item/loadout state, ghost pressure, and reduced protocol-state labels.
- The host computes the full Delve directive locally before run start and keeps that full bundle for host-local generation, item shaping, and runtime inspection.
- Run start payloads replicate only the public-safe directive summary to clients.
- Clients can receive public-safe authored tags plus line-level surface summary strings, but they do not receive the full control-surface policy bundle, clamped/strongest surface internals, mind-balance notes, or causal-audit payload.

## Current Live Protocol-State Layer
The repo already has a reduced live protocol-state implementation:
- `8+` active peers: `Expedition Protocol`
- `4-7` active peers: `Fracture Protocol`
- `2-3` active peers: `Intimate Protocol`
- `1` active peer: `Exposure Protocol`

These labels currently feed gameplay modeling, AI Delve doctrine selection, item/loadout interpretation, generation context, and visual governance. Full population-adaptive routing remains future-phase work.

## Relay Network Direction
The finalized Delve Protocol design includes relay nodes and relay recombination. That is a future phase. It must extend the current networking model rather than adding a second transport or shadow architecture.

## Population-Adaptive Implications
Protocol states already affect live interpretation and presentation through the reduced label layer. Relay routing, merge behavior, and topology-level recombination are future-phase networking/gameplay expansion work and should remain compatible with the current host-authoritative session model.
