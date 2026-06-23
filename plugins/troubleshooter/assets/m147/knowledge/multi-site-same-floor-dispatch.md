# Multi-Site Same-Floor Dispatch

## Symptoms

- Mini / OmniSort has two conveyors or lift modules reaching the same floor close together.
- One robot moves between two sites or appears undecided instead of serving the parcel already waiting.
- In no-scan feed mode, the parcel reaches the last belt segment and the lift reaches the target floor, but the robot does not pick up.
- Site selection depends on multiple walls, sample wall IDs, standby points, and `hasShuttleDispatching`.

## Fault Tree

- Confirmed branch: standby wall assumption fails on M147 multi-wall layout.
  - In `m147-pt-0146`, K24A14MN should pick site 2 parcel `1781686035666-1` at `M147-SITE-2`, but standby point selection used the first configured managed wall.
  - The case analysis states M147 has multiple walls on one side and previous logic assumed the first managed wall must be the standby wall.
  - Fix commit: `e17c711: fix: 修正添加机器人的时候选取待机点错误的问题`.
- Confirmed branch: simultaneous same-floor arrivals expose site filtering / ordering error.
  - In `m147-pt-0148`, site 2 parcel `1781768354310-21` arrived at `2026-06-18T15:39:24.170000+0800`; site 1 parcel `1781768360147-20` arrived at `15:39:27.927000+0800`.
  - K24A14MN reached site 2 at `15:39:27.958000+0800`, then `dispatchingShuttleOnShuttleArrive` reassigned it toward site 1.
  - The source analysis says the filtered candidate sites contained only site 1, and points to an incorrect `hasShuttleDispatching` judgment.
- Likely branch: parcel-arrival ranking is computed after an incorrect site filter.
  - If filtering removes the current valid site, sorting by `arriveDate` cannot recover the correct target.
- Blocked branch: raw log window mismatch.
  - Downloaded gzip logs are available, but the directly searched timestamps did not align cleanly with the source analysis window; use the source screenshots/text as the primary evidence for this distilled rule.

## Evidence Needed

- Exact site arrival timeline: parcel UUID, `arriveDate`, `siteUuid`, `trackName`, `targetFloor`, `sampleWallId`, and assigned `shuttleUuid`.
- Robot action timeline: `pre_arrive_load_point`, `dispatchingShuttleOnShuttleArrive`, `goto load point`, `setDispatchShuttleInfo`, `hasShuttleDispatching`.
- Area configuration: managed walls, standby wall, standby point, `originPoint`, and wall order in config.
- For simultaneous arrivals, preserve both site states before any filter/sort.

## Logs And Files To Inspect

- Local cases:
  - `cases/accepted/m147/0146-XsvowMmwGiPp5Iksb9McnM2znHg-2026-06-17-M147-迷你播Pro-上包不扫码模式机器人不接包问题.md`
  - `cases/accepted/m147/0148-M510wHiaQiBELxkuuvIcWI8Gnqg-2026-06-18-M147-迷你播Pro-两个提升模组同时到达同一层，机器人在站点之间左右摇摆.md`
- Local assets:
  - `assets/m147-pt-0146/`
  - `assets/m147-pt-0148/retry-source-Fb8WbjzOeoxtfNxxnDwcMgE1nsf.gz`
  - `assets/m147-pt-0148/retry-source-OSRkbPNpWoZTZuxwiezcoSFzncf.mov`
- Search terms: `dispatchingShuttleOnShuttleArrive`, `hasShuttleDispatching`, `arriveDateFurthestSite`, `goto load point`, `standby point`, `sampleWallId`, `siteDataRaw`.

## Likely Causes

- The first managed wall in configuration is treated as the standby wall, which is invalid for layouts where one side has multiple wall groups.
- Site candidate filtering excludes the current valid site because `hasShuttleDispatching` or current-site occupancy is computed from stale or wrong-scope dispatch data.
- Arrival-date comparison is applied after filtering, so the system chooses the wrong site even when the earlier parcel is known.

## Exclusion Checks

- Exclude robot hardware fault if robot receives and executes `goto load point` commands but is redirected by service logic.
- Exclude pure path blockage only after checking whether the path request was generated from the correct standby/site target.
- Exclude parcel sensor fault if both parcels have valid `parcel arrive`, `isArrive`, and destination records.
- Do not decide from a single site log; compare both `M147-SITE-1` and `M147-SITE-2` at the same timestamp.

## Confirmed Examples

- `m147-pt-0146`: multi-wall M147 layout caused wrong standby point selection; fix removed the first-wall-as-standby limitation.
- `m147-pt-0148`: simultaneous site arrivals on HT2 made K24A14MN switch between site 2 and site 1; source analysis points to incorrect site filtering / `hasShuttleDispatching`.

## Unresolved Examples

- `m147-pt-0148`: exact code fix is not recorded in the source case.

## Specialist Routing

- Start with `scheduler-traffic` for site filtering, dispatch reservations, and robot command lifecycle.
- Add handling specialist for lift floor and parcel physical state.
- Add `vision-media` only to confirm the robot physically moves between sites.
