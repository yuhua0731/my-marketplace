# Dirty Grid/Shuttle Standby Offset Causing Position Mismatch

## Symptoms

- OmniSort / MiniSort Pro overview position differs from the physical robot position.
- Upper/lower layer robot does not receive parcel even though the UI may show no alarm.
- Dispatch logs can show the robot reached the commanded target offset, while the commanded offset is not the station's expected physical standby/load position.
- The symptom can appear during no-scan feed/pickup tests around a specific station, for example `M123-SITE-1`.

## Fault Tree

1. Start from scheduler command evidence before blaming robot localization.
   - If `setTarget`, `robot_move_command`, `target_reached_event`, and `odom_report_event` agree on the same offset, the robot likely executed the scheduler-commanded coordinate.
   - If command and odom disagree, route to robot-motion/embedded before database cleanup.
2. Compare the commanded standby/load offset with the expected station coordinate.
   - Check station/site, layer, wall, grid/display name, track, and offset together.
   - A valid-looking offset can still belong to a stale grid row from another system.
3. Inspect database grid records for dirty or stale `systemId`.
   - A stale row such as `systemId=M111` can make MiniSort/M123 logic use an offset like `3.117` when the station standby point should be `3.783`.
4. Do not stop after deleting dirty grid rows.
   - Robot standby points can already be materialized in the `shuttle` table when the robot is added.
   - If the `shuttle` standby point still carries the stale offset, re-add/regenerate the robot after grid cleanup.
5. Separate follow-up emergency-handling faults from the original coordinate mismatch.
   - Missing central-control emergency handling after a version merge can block retest, but it is not evidence for the initial map-vs-physical mismatch unless it occurs in the same timeline.

## Evidence Needed

- RCS/dispatch logs around `setTarget`, `robot_move_command`, `target_reached_event`, and `odom_report_event`.
- Expected station standby/load coordinates from the source-of-truth configuration or database.
- Database query results for `grid` and `shuttle` rows by `systemId`, display name, offset, track, station, wall, and robot.
- UI overview screenshot plus physical photo/video showing the map-vs-physical mismatch.
- Post-remediation evidence showing the corrected offset and a successful pickup/retest.

## Logs And Files To Inspect

- Search terms: `setTarget`, `target_reached_event`, `odom_report_event`, `robot_move_command`, `currentOffset`, `currentPosition`, `M002L`, `M002R`, `M123-SITE-1`, `M123-WALL-B-3-3-1`, `B0-10`, `B3-11`, `3.117`, `3.783`, `systemId`, `M111`, `grid`, `shuttle`, `待机点`, `重新添加机器人`, `1777529274621-1`, `SYSTEM_FAILURE_DETECTED`, `STATE_EMERGENCY`, `recover from urgent stop`.
- Prefer dispatch/RCS logs for commanded offset and reached offset.
- Use images/video only to confirm physical mismatch or UI state; they do not prove the database root cause.

## Likely Causes

- Dirty `grid` data or wrong `systemId` is likely when scheduler commands a consistent offset that is not the expected station coordinate.
- Stale `shuttle` standby-point data is likely when deleting dirty grid rows does not change robot behavior.
- Robot localization is less likely when command, ACK, reached event, and odom all agree on the same wrong offset.

## Exclusion Checks

- If the commanded offset matches the expected station coordinate but physical position is wrong, investigate robot localization, track calibration, encoder/odom, and map geometry.
- If command delivery or ACK is missing, check network/embedded state before database records.
- If only UI screenshots are available, classify database root cause as provisional until raw logs or DB query screenshots/text support it.
- If emergency-stop handling appears after database changes, treat it as a separate branch unless it explains the original timestamped mismatch.

## Confirmed Examples

- `minisort-test-pt-0064`: During MiniSort Pro no-scan feed testing on `2026-04-30`, the second-layer robot overview position differed from physical position and the second layer could not receive a parcel. UI overview at `2026-04-30 14:24:02` showed robots online/no obvious alarm.
  - Source analysis says parcel `1777529274621-1` should be picked from `M123-SITE-1` and sent to `M123-WALL-B-3-3-1 (B3-11)`.
  - `2026-04-30T14:07:57.335000+0800`: `setTarget` sent `M002L` to `HT1`, offset `3.117`, as an empty standby move.
  - `2026-04-30T14:07:57.341000+0800`: `robot_move_command` for `M002L` used position `3.117`, speed `4`, acc `3.5`, dec `3.5`.
  - `2026-04-30T14:07:57.725000+0800`: `target_reached_event` reported `M002L` at `currentOffset: 3.117`.
  - `2026-04-30T14:07:57.726000+0800`: `odom_report_event` reported `currentPosition/currentOffset: 3.117`.
  - Source conclusion says station-1 standby offset should be `3.783`; `3.117` corresponded to `B0-10` dirty `grid` data with `systemId=M111`.
  - Deleting dirty `grid` rows did not fully fix the case because `shuttle` standby-point data generated when adding the robot still held the stale coordinate; re-adding the robot was required.

## Unresolved Examples

- `minisort-test-pt-0064`: Raw database exports are not local; DB evidence comes from the source document's query screenshots/text.
- `minisort-test-pt-0064`: Later retest hit an emergency-stop handling issue after code changes from `sort-mini-v1.0.0` to `sort-mini-v2.0.0`; final full retest evidence is not present locally.

## Specialist Routing

- `scheduler-traffic`: station assignment, standby/load target selection, grid/shuttle database records, task timeline.
- `robot-motion`: only after comparing commanded offset with expected physical coordinate, or when command and odom disagree.
- `embedded-software`: robot state, ACK/reached event, emergency-stop follow-up behavior.
- `vision-media`: UI overview and physical position mismatch confirmation.
- `network-infra`: only when command/ACK/log delivery is missing or inconsistent.
