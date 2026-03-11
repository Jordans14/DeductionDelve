# Items and Synergies

## Item Philosophy
Items in Deduction Delve are systemic, physical tools designed to directly interrogate traversal, platforming physics, and social visibility. The goal is to evolve item mechanics beyond simple stat boosts—each toolkit tangibly alters the deception surface and observable behavior of a player.

## The Vertical Slice Initial Set
To prevent early complexity overload and strictly prove the social-platforming loop, the vertical slice focuses on exactly **6-8 highly legible core items**:
1. **Bomb** (Environment/Lethality): Rigid body, bouncing explosive. Can carve shortcuts or "accidentally" knock players off ledges.
2. **Rope** (Mobility): Deploys a vertical climb mask. Essential for traversal, but dropping one immediately near a trap is highly suspicious.
3. **Lantern Snuffer** (Signal Control): Reduces personal light emission radius. Used to hide evidence pickups in the dark or stalk the squad.
4. **Heavy Boots** (Mobility/Trace): Alters coyote-time and jump distances, but forcefully leaves heavy footprint decals in the cavern dust.
5. **Timeline Bookmark** (Forensics): Drops a physical marker that explicitly pins a precise location/timestamp to the host's event log upon run review.
6. **Decoy Emitter** (Sabotage): Tossable physics object that mimics player movement noise, creating intense confusion during cavern collapses.
7. **Zipline Kit** (Mobility Infrastructure): Deploys a visible lateral route across a room. It is useful traversal, but also a very public clue about who likely shaped the pathing through that space.

## Active Slice Taxonomy
- **Artifacts:** objective items that must be extracted one at a time.
- **Tools:** active-use equipment that creates visible public consequences.
- **Relics:** passive modifiers that alter movement, light, or clue pressure.
- **World Objects:** placed route infrastructure and hazards that become shared evidence in the room.

The current sandbox keeps Grappling Hook intentionally deferred. A true swing tool adds too much room-grammar and determinism risk for the current slice, while Zipline covers the lateral-route fantasy in a host-authoritative, socially readable way.

## Authoring Framework
The slice item definitions now act like a real authoring schema rather than a flat label list. Each item definition should describe:
- **Category:** artifact / tool / relic / world object
- **Archetypes:** organizational families like movement, signal, deception, support, or mobility infrastructure
- **Tags:** short semantic flags used for future content expansion and clue reasoning
- **Spawn Profile:** rarity, quality, room bias, and soft role affinity
- **Evidence Profile:** what public clue the item leaves behind plus its sound/light/clue signature
- **Behavior Profile:** whether it is active or passive, how it sits in inventory, what route pressure it creates, and what placement rules constrain it
- **Synergy Hooks:** stable labels for future interactions without baking brittle hard-coded pair logic into the current slice

## Loot Model
- **Traversal Shafts:** favor movement and mobility-infrastructure tools because they change routes in readable ways.
- **Hazard Chokepoints:** favor risk-facing tools and relics that interact with timing, stability, or noise.
- **Evidence Pockets:** favor tracking, deception, and support items that distort or preserve the story around an artifact.
- The active slice now also shapes item pacing across the run:
  - early spawns bias toward readable route-enablers and forensics support
  - later spawns bias harder toward deception, signal control, and reroute pressure
  - immediate duplicate spawns are intentionally suppressed so runs pick up a clearer identity without adding more content

Rarity and quality should shape how often an item appears and how influential it feels, but they should never create “junk loot.” Every item in the pool should still produce readable public consequences.

## Synergistic Interpretations
The power of items emerges horizontally through social ambiguity.
- **The Suspicious Rope:** A Rope used to bridge a gap is helpful. The exact same Rope deployed downwards toward a pit of spikes could be an innocent mistake in the heat of a jump, or a calculated Veil sabotage route.
- **The Blind Blast:** A Bomb detonation that visually obscures the room with smoke, masking the exact moment an artifact was stolen or corrupted.
- **The Erased Trail:** A Lantern Snuffer combined with standard platforming allows players to sever line-of-sight entirely, leaving the team to argue furiously over exactly who had the proximity to trigger a trap.

## RNG Deployment & Information Rules
- Item loot-tables are resolved completely deterministically relying entirely on substreams of the Host's run seed. 
- **The Core Constraint:** No item exists that provides strict, undeniable proof of guilt. All tools must output probability noise or physically ambiguous traces, strictly forcing the Social Deduction mechanic to remain supreme over simple systemic button-presses.

