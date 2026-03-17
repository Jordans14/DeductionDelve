# Protocol States

See also: [THE_DELVE_PROTOCOL](d:/DeductionDelve/docs/THE_DELVE_PROTOCOL.md), [CRAWL_NETWORK_ARCHITECTURE](d:/DeductionDelve/docs/CRAWL_NETWORK_ARCHITECTURE.md), [AI_INHABITANTS](d:/DeductionDelve/docs/AI_INHABITANTS.md).

## Overview
Protocol states describe how the Delve shifts experimental conditions based on active population density.

The repo already has a reduced live implementation inside [network_manager.gd](d:/DeductionDelve/godot/src/net/network_manager.gd):
- `Expedition Protocol`: `8+` active peers
- `Fracture Protocol`: `4-7` active peers
- `Intimate Protocol`: `2-3` active peers
- `Exposure Protocol`: `1` active peer

These labels are already consumed by gameplay modeling, AI Delve doctrine selection, generation context, item/loadout interpretation, and visual governance.

Relay routing, recombination, and deeper topology-level protocol behavior remain future-phase work layered on top of the current host-authoritative architecture.

The protocol profiles below describe the intended behavior envelope. Today, only the reduced live labels and the current consumers above are implemented.

## Expedition Protocol (8-12 players)
- Broad witness pressure
- High relay density
- Strong public spectacle
- Branches test crowd behavior, information spread, and visible coordination

## Fracture Protocol (4-7 players)
- Splits become more meaningful
- Branch commitment costs rise
- Relay recombination becomes more selective
- Rescue and rivalry patterns become easier to track culturally

## Intimate Protocol (2-3 players)
- Burdens and pair dynamics dominate interpretation
- AI pressure becomes more legible
- Combat and rescue decisions become sharply consequential
- Archive and world culture focus on behavior under low social cover

## Exposure Protocol (1 player)
- Isolation becomes the pressure condition
- Environmental and inhabitant pressure scale upward
- The Delve's pattern-awareness is felt more strongly
- Solo myths and anti-Protocol echoes become unusually significant

## Design Use
Protocol states are not a second ruleset. They are a framework for:
- environmental pressure scaling
- social density interpretation
- relay behavior
- inhabitant mix
- challenge framing
- Archive and broadcast emphasis
