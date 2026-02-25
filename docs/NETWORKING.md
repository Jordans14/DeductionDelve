# Networking

## Transport Targets
- Primary (desktop): `ENetMultiplayerPeer` (UDP).
- Secondary (web fallback): `WebSocketMultiplayerPeer`.
- Current implementation status: ENet path implemented in Milestone 1/2 scaffold, WebSocket path documented only.

## Authority Model
- Phase 1-2: host-authoritative peer for rapid iteration.
- Host owns:
  - Lobby roster/readiness/start.
  - Role assignment.
  - Run seed and all generation decisions.
  - Spawn approvals and key state transitions.

## Replication Strategy
- Sync intent/events and important state, not per-pixel transforms.
- Client sends input vectors + interaction requests.
- Host validates and rebroadcasts authoritative snapshots/events.
- Milestone 3 RPC model:
  - Client -> host requests: pickup/drop/steal/forge/sabotage.
  - Host validates ownership/range/room-slot/role.
  - Host -> all: authoritative artifact state + public timeline events.
  - Host -> single client: private role reveal and private forge feedback.
  - Host -> single client: private UI denial feedback for rejected actions (not added to factual timeline).
  - Host -> all on run end: end payload with seed + role reveals + deterministic summary metrics.

## Hardening Rules (Current)
- Public hazard state events are anonymous:
  - `actor_peer_id` is always `-1`.
  - public meta is empty and never contains sabotage-specific keys.
- Forge secrecy:
  - no public `forged_hint` metadata is emitted.
  - forge confirmation is private to the saboteur event feed.
- Deterministic event ordering:
  - authoritative timeline events use `tick` plus monotonic `event_id`.
  - wall-clock event fields are excluded from network events and replay comparisons.
  - run lifecycle uses host-side deterministic tick-limit end condition.
- One-carry rule (host-enforced):
  - pickup denied if requester already carries an artifact.
  - steal denied if requester already carries an artifact.
  - forge denied if requester already carries an artifact.
  - pickup additionally requires requester room slot equals artifact room slot.
  - steal additionally requires requester, victim, and artifact room slots all match.
  - drop updates artifact `room_slot` to requester current slot on drop.

## Public Event Meta Allowlists
- Host filters public metadata by strict allowlist per event type:
  - `artifact_spawned`: `artifact_id`
  - `artifact_picked`: `artifact_id`
  - `artifact_dropped`: `artifact_id`
  - `artifact_stolen`: `artifact_id`, `from_peer`
  - `hazard_state_changed`: empty
  - `run_started`: `seed`
  - `evidence_checked`: empty
  - `run_ended`: empty
- Unknown event types or unlisted keys resolve to empty metadata.
- Unit tests now validate this logic through pure helper APIs rather than internal NetworkManager methods.

## Web Constraints
- Web clients cannot host ENet; they connect via WebSocket relay/server path.
- Keep packet schema transport-agnostic (`Dictionary` payload format).
- No reliance on local filesystem features in networking layer.

## Anti-Cheat Assumptions (Slice)
- Trust boundary: clients are untrusted for RNG/loot/role truth.
- Host can still be dishonest in host-authoritative mode; acceptable for prototype.
- Future dedicated server milestone mitigates host tampering.
- Role secrecy boundary:
  - `host_start_run` payload contains seed/layout/peer list only.
  - Role map stays host-side; per-client reveal payload has only `{ role: ... }`.

## Bandwidth Principles
- 10-20 Hz state snapshots for player movement.
- Event-based messages for item/evidence/role actions.
- Compress repeated identifiers (integer IDs).

## Run Lifecycle v0
- End condition: host ends run when `tick >= RUN_TICK_LIMIT`.
- Role-map reveal is transmitted only in end payload, never in run-start payload.
- End payload includes:
  - `seed`
  - `reason`
  - `end_tick`
  - `roles_reveal`
  - `summary_by_peer`
