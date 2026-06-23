# M137 ALLCAN-DM Center Offset Default After Mainboard Replacement

source_set: `m137-pt-0154`
case_count: 1 focused M137 station forced-discharge alignment case
status: runtime routing rules for ALLCAN-DM center-offset default causing scan failure and arrival oscillation

## Symptoms

- M137 station forced discharge after an exception causes the robot to move a short distance sideways after reaching the station.
- Robot and lift module become misaligned.
- The behavior may appear as arrival oscillation or slight lateral drift.
- The case is especially relevant after mainboard replacement or camera/ALLCAN-DM configuration restore.

## Fault Tree

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

## Evidence Needed

- Before/after ALLCAN-DM center-offset config, including default value and final `10` pixel value.
- DM image/decode logs around station 1 forced discharge at about `2026-06-11 10:59`.
- Robot localization/motion logs showing arrival, sideways correction, oscillation, and final pose.
- RCS/WRS command timeline for exception trigger and forced-discharge path.
- Mainboard replacement record and config restore checklist.
- Post-fix video or repeated forced-discharge verification after setting the offset to `10` pixels.

## Logs And Files To Inspect

- `cases/accepted/m137/0154-J5gxwRqFsiXzVjk8glBcFlmEnEe-2026-06-11-M137-站点-1-触发异常执行强排后-机器人与提升模组位置偏移-未对齐.md`
- `assets/m137-pt-0154/retry-source-Urv6bJqmWoTj6jxsHIVcrFnsnUe.mov`
  - H.264/AAC, `9.433999999999999s`, `720x1280`, `3532976` bytes.
  - Representative frames show station/lift-conveyor area and a small sample/parcel moving near the belt centerline; frames do not quantify robot lateral offset.
- Search terms: `M137`, `站点1`, `强排`, `往左再走一小段`, `位置没对齐`, `ALLCAN-DM`, `中心偏移`, `默认值`, `主板更换`, `扫码失败`, `到位后震荡`, `10像素`.

## Likely Causes

- ALLCAN-DM center-offset calibration was lost or reset to default during mainboard replacement.
- Default offset reduced DM scan reliability at station arrival, causing post-arrival correction/oscillation.
- Forced-discharge station path exposed the calibration error because robot/lift alignment tolerance was tight.

## Exclusion Checks

- Do not blame lift mechanical alignment before checking robot camera center-offset after mainboard replacement.
- Do not merge with dirty floor-code loss unless there is image/log evidence of floor-code contamination or low scan count unrelated to center offset.
- Do not treat `system_area: CAN` as proof of CAN fault; this is primarily vision/localization calibration.
- Do not close without repeated station-1 forced-discharge verification after the offset is set to `10` pixels.

## Confirmed Examples

- `m137-pt-0154`: M137 station 1 exception forced discharge caused the robot to move left after arrival and misalign with the lift module. Source analysis says mainboard replacement left ALLCAN-DM center offset at default, increasing scan failure and arrival oscillation. Updating center offset to `10` pixels solved the problem.

## Unresolved Examples

- `m137-pt-0154`: missing DM images/logs, exact before/after config dump, robot motion logs, forced-discharge command timeline, mainboard replacement record, and post-fix verification video.

## Specialist Routing

- Start with `robot-motion` and `vision-media` for DM center offset, scan failure, arrival pose, and oscillation.
- Add `scheduler-traffic` for exception and forced-discharge command sequence.
- Add `embedded-software` / `can-bus` only to verify config application, ALLCAN-DM telemetry, or camera/CAN communication state.
