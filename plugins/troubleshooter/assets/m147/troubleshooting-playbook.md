# M147 Troubleshooting Playbook

Use this as the human-readable entrypoint before specialist routing.

## Global Process

1. Record exact symptom, timestamp, robot ID, station/location, task/container ID, and available filenames.
2. Classify the case by observed symptom, not by incidental WS/robot/location words.
3. Load the matching knowledge file and traverse the highest-value fault branch first.
4. Mark every branch as `confirmed`, `likely`, `excluded`, or `blocked`.
5. Treat unavailable videos, images, logs, and chat records as missing assets, not analyzed evidence.
6. Stop only at confirmed root cause, sufficient operational conclusion, or excluded branch.

## Route Order

- Reboot, shutdown, charging, low voltage: embedded-software first, then can-bus/scheduler/network.
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## Concave Parcel Multi-Parcel Detection

Knowledge file: `docs/m147/knowledge/concave-parcel-multi-parcel.md`

### First Checks

- Confirmed branch: product geometry can mimic multi-parcel evidence.
  - In `m147-pt-0147`, the source says a concave parcel entered station 2 lift at `15:45:25` and reported conveyor multi-parcel.
  - The source also says the upper-car light curtain triggered only once.
  - Downloaded video thumbnail shows a long carton with a concave/damaged edge profile, not an obvious second parcel.
- Likely branch: detection window or downstream sensor pair interprets the concavity as two objects.
  - Check whether multi-parcel logic uses multiple light curtains, duration gaps, height profile, or lift entry timing.
- Blocked branch: full video timeline and sensor logs.
  - Videos are downloaded, but no matching IO/sensor timestamp log is present in the case.

### Evidence

- Full IO timeline for upper-car light curtain, lift-entry light curtain, multi-parcel sensor, and conveyor speed.
- Parcel size, concavity direction, edge deformation, and orientation during entry.
- Alarm timestamp and whether the same parcel repeats the alarm under rotated orientation.
- Video frame sequence synchronized with sensor timestamps.

### Exclusions

- Exclude true two-parcel condition only if upstream and lift-entry sensor timelines both show one continuous object and video confirms one parcel.
- Exclude pure software false alarm only after checking parcel orientation and sensor timing.
- Exclude upstream light curtain as sole evidence; the multi-parcel decision may use a downstream sensor or duration heuristic.

### Examples

- None. `m147-pt-0147` remains `needs-assets` because IO logs were not present.

- `m147-pt-0147`: station 2 concave parcel caused multi-parcel alarm; source claims upper-car light curtain triggered once, but root cause needs IO timeline confirmation.

## Multi-Site Same-Floor Dispatch

Knowledge file: `docs/m147/knowledge/multi-site-same-floor-dispatch.md`

### First Checks

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

### Evidence

- Exact site arrival timeline: parcel UUID, `arriveDate`, `siteUuid`, `trackName`, `targetFloor`, `sampleWallId`, and assigned `shuttleUuid`.
- Robot action timeline: `pre_arrive_load_point`, `dispatchingShuttleOnShuttleArrive`, `goto load point`, `setDispatchShuttleInfo`, `hasShuttleDispatching`.
- Area configuration: managed walls, standby wall, standby point, `originPoint`, and wall order in config.
- For simultaneous arrivals, preserve both site states before any filter/sort.

### Exclusions

- Exclude robot hardware fault if robot receives and executes `goto load point` commands but is redirected by service logic.
- Exclude pure path blockage only after checking whether the path request was generated from the correct standby/site target.
- Exclude parcel sensor fault if both parcels have valid `parcel arrive`, `isArrive`, and destination records.
- Do not decide from a single site log; compare both `M147-SITE-1` and `M147-SITE-2` at the same timestamp.

### Examples

- `m147-pt-0146`: multi-wall M147 layout caused wrong standby point selection; fix removed the first-wall-as-standby limitation.
- `m147-pt-0148`: simultaneous site arrivals on HT2 made K24A14MN switch between site 2 and site 1; source analysis points to incorrect site filtering / `hasShuttleDispatching`.

- `m147-pt-0148`: exact code fix is not recorded in the source case.

## Photoelectric Height-Limit Sensor DIO Label Miswire

Knowledge file: `docs/m147/knowledge/photoelectric-height-limit-dio-label-miswire.md`

### First Checks

- Confirmed branch: IO address table defines the expected DIO port.
  - `m147-pt-0177` IO table screenshot `M147_IO地址变量表_V01.xlsx` shows node type `ALL CAN-4`, bus `9352 BUS-1`, baud `1MHZ Bit/sec`, `CAN-ID (DEC) = 12`.
  - The same table highlights `DI02` / `DIO2` for `限高光电传感器`.
- Confirmed branch: field cable label points to the wrong DIO port.
  - Local images show cable label `P/N: M001-H5I-224B` and `CONN No.: DIO3`.
  - Source text says the IO-signal plug should be on `DIO2`, but was actually connected to `DIO3`, and the wire label was also `DIO3`.
- Likely branch: assembly or harness-label generation used the wrong connector number, causing technicians to follow the label into the wrong DIO socket.
- Blocked branch: downstream runtime symptom and recurrence scope.
  - No raw IO state log, CAN frame, gateway diagnostic, sensor trigger test, or corrected-label retest is present.

### Evidence

- Corrected harness label or engineering drawing showing the intended connector number.
- Photo after correction showing the height-limit sensor signal cable on `DIO2`.
- IO/gateway log or manual input test proving `DIO2` changes when the height-limit sensor is triggered.
- Whether M149 has the same harness label batch and same IO table mapping.
- Production/QA scope: affected serial numbers, harness part numbers, and whether labels were generated from an old template.

### Exclusions

- Do not replace the photoelectric height-limit sensor until IO table, cable label, and physical plug location have been compared.
- Do not call this a CAN electrical fault without CAN/IO state evidence; the visible evidence points to wrong DIO assignment.
- Exclude software configuration only after confirming the running configuration expects the same `DI02` mapping as the IO table.
- Exclude one-off installation error only after checking whether the cable label itself is wrong and whether M149 shares the same label batch.

### Examples

- `m147-pt-0177`: visible source says the photoelectric height-limit sensor IO plug should connect to `DIO2`, but was actually connected to `DIO3`, and the wire label was also `DIO3`. Local photos confirm the `DIO3` label and IO table `DI02` mapping.

- `m147-pt-0177`: final correction photo, IO trigger retest, M149 scope, and raw IO/CAN evidence are not present.
