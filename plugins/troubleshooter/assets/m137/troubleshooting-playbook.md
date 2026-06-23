# M137 Troubleshooting Playbook

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

## M137 ALLCAN-DM Center Offset Default After Mainboard Replacement

Knowledge file: `docs/m137/knowledge/allcandm-center-offset-default-after-mainboard-replacement.md`

### First Checks

1. Check ALLCAN-DM center-offset config first after board replacement.
   - `m137-pt-0154`: source analysis says mainboard replacement caused robot ALLCAN-DM center-offset config to return to default.
   - Default center offset made scan failure more likely and caused the robot to oscillate after arrival.
   - Updating the ALLCAN-DM center-offset config to `10` pixels resolved the issue.
2. Confirm physical alignment symptom.
   - Source says station 1 triggered an exception; during forced discharge, the robot moved left a short distance after arriving.
   - This caused robot and lift module position mismatch.
3. Separate DM offset from generic dirty-floor/no-read cases.
   - There is no source evidence of dirty floor code.
   - The known fix is a center-offset calibration value, not floor-code replacement.
4. Keep scheduler context for forced-discharge reproduction.
   - Forced discharge may expose arrival-path and scan-window sensitivity that normal running does not show.
   - Collect command labels and station/slot context before changing software flow.

### Evidence

- Before/after ALLCAN-DM center-offset config, including default value and final `10` pixel value.
- DM image/decode logs around station 1 forced discharge at about `2026-06-11 10:59`.
- Robot localization/motion logs showing arrival, sideways correction, oscillation, and final pose.
- RCS/WRS command timeline for exception trigger and forced-discharge path.
- Mainboard replacement record and config restore checklist.
- Post-fix video or repeated forced-discharge verification after setting the offset to `10` pixels.

### Exclusions

- Do not blame lift mechanical alignment before checking robot camera center-offset after mainboard replacement.
- Do not merge with dirty floor-code loss unless there is image/log evidence of floor-code contamination or low scan count unrelated to center offset.
- Do not treat `system_area: CAN` as proof of CAN fault; this is primarily vision/localization calibration.
- Do not close without repeated station-1 forced-discharge verification after the offset is set to `10` pixels.

### Examples

- `m137-pt-0154`: M137 station 1 exception forced discharge caused the robot to move left after arrival and misalign with the lift module. Source analysis says mainboard replacement left ALLCAN-DM center offset at default, increasing scan failure and arrival oscillation. Updating center offset to `10` pixels solved the problem.

- `m137-pt-0154`: missing DM images/logs, exact before/after config dump, robot motion logs, forced-discharge command timeline, mainboard replacement record, and post-fix verification video.
