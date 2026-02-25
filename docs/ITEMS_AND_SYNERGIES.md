# Items And Synergies

## Item Taxonomy
- Mobility: dash charge, wall grip, rope range.
- Signal: noise dampening, light masking, aura bloom.
- Forensics: trace scanner, artifact verifier, timeline marker.
- Sabotage: trap overclock, decoy ping, fake footprint kit.
- Survival: heal burst, shield pulse, hazard insulation.

## Data Model
- Each item has:
  - `tags`: behavioral categories used by synergy combinators.
  - `mods`: numeric or boolean stat/effect changes.
  - `social_surface_delta`: how it changes visibility/noise/traces/alibi plausibility.

## Guardrails
- No item provides hard guilt proof.
- High deception power pairs with clear counter-item or tell.
- Max stack limits on stealth/noise suppression.

## Planned Vertical Slice Item Count
- 18 initial items (within required 15-25).

## Planned Noticeable Synergies (5+)
1. `shadow` + `silence` -> "Ghost Route": reduced footsteps, but leaves rare cold residue.
2. `forensic` + `signal` -> "Echo Triangulation": clearer event timeline markers.
3. `sabotage` + `mobility` -> "Slip Setup": fast trap priming after ledge traversal.
4. `survival` + `trace` -> "Last Stand Record": auto-drop authenticated death fragment.
5. `decoy` + `light` -> "False Spotlight": fake witness cue with low-duration glow.

## RNG Policy
- Seeded pools by biome tier and run stage.
- Duplicate protection by recent-pick memory.
- Role-aware but not role-exclusive weighting to preserve uncertainty.
