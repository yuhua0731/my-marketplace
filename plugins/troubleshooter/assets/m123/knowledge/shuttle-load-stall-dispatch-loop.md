# Shuttle Load Stall And Dispatch Loop

## Symptoms

- Mini / OmniSort robot has a parcel after loading but does not leave the station, or the UI shows a robot stuck at a site with parcel.
- Logs repeatedly send go-to-target commands on the same track/offset while another robot or opposite site remains involved.
- Station screenshots show one robot carrying a parcel and another robot adjacent or opposite on the same station group.

## Fault Tree

- Confirmed branch: station/dispatch state must be reconstructed before blaming the robot.
  - In `m123-pt-0142`, visible image shows `11MN` with parcel at the station and `17MN` adjacent.
  - UI screenshot shows `K02A11MN` highlighted and multiple station cells in stalled states.
  - Downloaded logs contain repeated `send go to target command。target trackName：HT0，target offset: 3.023` lines and repeated references to `K02A11MN` as the opposite shuttle.
- Likely branch: service-side dispatch loop or stale opposite-site occupancy.
  - Logs around `2026-06-12T09:18:47+0800` show `K02A17MN` lifecycle from load to leave, while `oppositeShuttle: K02A11MN` stays in status `133`.
  - Repeated commands alone are not proof of robot motion failure; first inspect dispatch reservation, opposite-site state, and site parcel ownership.
- Possible branch: scanner/network side effect blocks site state cleanup.
  - The same log stream repeatedly reports `M123-SITE-1 rollerScan: Error: connect EHOSTUNREACH 10.0.64.171:9004`.
- Blocked branch: source/log time mismatch.
  - Case text says the event was around `16:30:35`, while the downloaded gzip log excerpt is around `09:18`. Treat the log as evidence for a similar failure window until the exact matching log is confirmed.

## Evidence Needed

- Exact matching log window for the reported `16:30:35` symptom.
- Robot IDs for the physical stalled parcel: `K02A11MN` versus `K02A17MN`.
- Station state for both sides: `M123-SITE-1`, `M123-SITE-2`, `dispatchShuttleInfo`, `oppositeShuttle`, `parcelUuid`, and current floor.
- Scanner / rollerScan reachability and whether scan failure blocks mission creation or site cleanup.

## Logs And Files To Inspect

- Local case: `cases/needs-assets/m123/0142-GufYwDRQ9i9Qh6kE42WcnWRLnzg-2026-06-12-M123-迷你播Pro-生产模式下11MN机器人接货后没有离开站点.md`.
- Local assets: `assets/m123-pt-0142/retry-source-R2lVbovFroj8RXxCn6kcjVWmnoe.gz`, `assets/m123-pt-0142/retry-image-001-DYIzbERZDoHLtuxRUjMc4cK0nMh.png`, `assets/m123-pt-0142/retry-image-002-FPlBby2IboEKOex0UF2coIkanpb.jpg`.
- Search log terms: `oppositeShuttle`, `dispatchShuttleInfo`, `action at site is not over`, `begin leave site`, `rollerScan`, `EHOSTUNREACH`, `send go to target command`.

## Likely Causes

- Stale opposite-shuttle reservation or site occupancy prevents the intended robot from leaving or receiving a valid next command.
- A scanner/network error blocks a service transition, leaving the UI in a stalled state while commands keep repeating.
- Test or production mode auto mission creation assigns a mission before parcel ownership is attached, creating `parcel: undefined` ambiguity.

## Exclusion Checks

- Do not call it a motor or drive fault if logs show successful `set target` / `leave site` for the robot under inspection.
- Do not treat repeated `send go to target` as root cause; classify it as a symptom until reservation and site state explain why commands repeat.
- Do not merge `11MN` and `17MN` evidence: physical image, UI state, and logs may refer to different robots in the same station pair.

## Confirmed Examples

- None. `m123-pt-0142` remains `needs-assets` because the exact reported time window is not yet aligned with the downloaded log.

## Unresolved Examples

- `m123-pt-0142`: 11MN physically carried a parcel and did not leave the station; available logs show repeated dispatch commands and scanner reachability errors, but exact root cause is not confirmed.

## Specialist Routing

- Start with `scheduler-traffic` for reservation, mission, and command lifecycle.
- Add `network-infra` if `rollerScan` or station device reachability errors line up with the stall.
- Add `vision-media` only to confirm which robot physically has the parcel.
