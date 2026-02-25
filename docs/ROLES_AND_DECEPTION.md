# Roles And Deception

## Role Set (Vertical Slice)
1. Warden (Investigator): gains forensic interactions and clue interpretation bonuses.
2. Veil (Saboteur): can alter hazard timing and forge selective evidence.
3. Scavenger (Neutral/Greedy): maximizes personal extraction value, may collaborate situationally.

## Current Milestone 3 Implementation
- Host assigns roles on run start using seeded deterministic assignment.
- Each client receives only a private payload containing its own role string.
- Role reveal UI now shows `Your role: ...` in run HUD.
- Veil-only actions implemented:
  - Forge artifact (creates fake signature).
  - Hazard timing nudge sabotage (plausible accident).
- Hardening pass:
  - public hazard timeline entries are anonymous (`actor_peer_id = -1`).
  - sabotage confirmation is private to Veil; public event does not identify cause.
  - forge confirmation is private; public artifact spawn events contain no forge hints.

## Warden Check v0 (Inference, Not Proof)
- Input action: `T` while playing as `Warden`.
- Scope: checks nearest artifact within short range (ground or carried).
- Host validates Warden role + same room slot before resolving.
- Output: private timeline event `warden_check_result` with a deterministic `score` (0-100).
- Public trace: optional factual event `evidence_checked` with empty metadata.
- Guarantee: score is intentionally ambiguous and never maps to a hard forged/real verdict.

## Hidden Information Model
- Hidden: exact role, private item inventory, intent, some interaction timestamps.
- Public-ish: position sightings, dropped artifacts, environmental state changes.
- Contested: artifact authenticity, cause-of-death interpretation, witness credibility.

## Information Economy
- Production:
  - Hazard traces (trigger logs, residue, footprints).
  - Artifact drops (echo logs, rune receipts, mechanical fragments).
  - Witness moments (line-of-sight, emote/ping timing).
- Withholding:
  - Hide/stash evidence.
  - Delay reporting.
  - Route team away from scene.
- Forging/poisoning:
  - Saboteur crafts counterfeit artifacts with imperfect signatures.
  - Context poison by moving valid evidence away from origin.

## Plausible Deniability Channels
- Trap triggers that could be accidental.
- Resource starvation caused by "bad routing."
- Timing windows where multiple players could have acted.

## Counterplay
- Warden scans can validate consistency (not certainty).
- Map reconstruction tools correlate room hazard state transitions.
- Itemized counter-forensics (trace seals, anti-forge lens).
- Current hook: timeline records hazard-state changes as facts, not guilt markers.
- Artifact logistics pressure: each player can carry at most one artifact at a time.

## Soft Communication Tools
- Quick pings: danger, wait, witness, trust-me, regroup.
- Emotes: shrug, point, deny, confirm.
- Body-language cues: hesitation at trap edges, route avoidance, evidence carrying stance.
- Optional hooks: future text/voice channels consume same event feed and suspicion notes.
