# UX and UI

## Lobby UI
- Host/Join controls and transport selection label.
- Player list with ready states.
- Seed display before launch.

## In-Run HUD (Slice)
- Health/resource strip.
- Carried evidence indicator.
- Ping wheel shortcut + quick emote buttons.
- Suspicion notebook toggle.
- Current debug HUD implementation:
  - `Your role: ...`
  - `Carrying: E#` or `None`
  - interaction prompt line near carry HUD:
    - `Q: Pick up E#`
    - `E: Drop`
    - `R: Steal E#`
    - `F: Forge`, `G: Sabotage` (Veil)
    - `T: Check` (Warden)
  - scrolling timeline event list (sorted by tick + event_id)
  - private Warden check results shown as timeline entries with score
  - local-only denial feedback in status bar for rejected actions (about 1.2s), e.g. `Denied: wrong_room`

## Suspicion Tools
- Lightweight notebook rows:
  - `event`, `who`, `where`, `confidence`, `notes`.
- Supports uncertainty flags (possible/likely/contested).
- Timeline bookmarks from major events (death, sabotage trace, artifact pickup).

## Non-Verbal Tell Presentation
- Footprint decals in certain terrain.
- Glow/noise aura overlays from item effects.
- Evidence-carrying silhouette marker within short range.
- Current implementation: players carrying evidence show a visible `EV` marker above avatar.
- Hazard readability upgrade: each room now has a small hazard indicator that flashes (`!`) on hazard pulse events for that slot.
- Indicator is network-driven by pulse events and visual-only (does not alter simulation).
- Reliability: indicator decay processing is explicitly enabled in room builder `_ready`.

## End-of-Run Screen
- Outcome: extraction success/failure.
- Event timeline (timestamped critical actions).
- Role reveal and personal performance summary.
- "What was known vs guessed" recap cues.
- Current v0 implementation:
  - hidden during run, shown after host-authoritative end trigger.
  - displays `RUN COMPLETE`, run seed, end reason (`extraction_objective` or `tick_limit`), role reveal list, and per-player evidence summary.
  - compact timeline shown with a simple "show more/less" toggle via `TAB`.
