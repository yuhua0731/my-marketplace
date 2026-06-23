# ALLCANDM Seam Crop Causing Moving Marker Detection Alarm

## Symptoms

- MiniSort Pro in no-scan loading mode reports `移动时标记点检测异常` immediately after locking robot `M004R`.
- The UI popup can show normal voltage, for example `54.71V`, while the alarm is marker/DM detection rather than drive power.
- NXP/debug screenshot shows `dmenc: datamatrix decode failed`.
- Decode debug image shows upper/lower bright-row selection around a floor seam or code-height discontinuity.

## Fault Tree

- Confirmed branch: DataMatrix decode fails during movement/lock flow.
  - `m004-pt-0072` source analysis says `M004R解码失败`.
  - Screenshot `002-image-6cac87b6238b.png` highlights `dmenc: datamatrix decode failed` at `2026-05-06T08:23:02Z`.
- Confirmed branch: horizontal-strip decode can choose wrong bright rows when the robot is near a seam.
  - Source states current M123 ALLCAN-DM horizontal-strip decode folds the image and finds the whitest two rows in the two image halves as the DM code range.
  - At the seam, code height is not uniform, so the whitest rows can be selected incorrectly and the crop can cut into the DM code.
  - Debug image shows `Upper: row 203 (value: 183.6)`, `Lower: row 289 (value: 152.5)`, and a center line crossing a code region near the seam.
- Likely branch: `移动时标记点检测异常` is a downstream UI alarm from DM decode/crop failure, not a true motor/CAN fault.
  - No local CAN frame, motor heartbeat, or drive fault evidence is present for this case.
- Blocked branch: exact physical confirmation that M004R was at the seam.
  - Source explicitly asks to confirm whether M004R was at the seam at that time.

## Evidence Needed

- Physical or video proof of M004R position at the seam when the alarm occurred.
- Raw camera frame and crop rectangle before decode, not only annotated screenshots.
- Decode algorithm/config version, including whether horizontal-strip mode or dense-center offset is enabled.
- Before/after evidence after changing crop/center-line logic or offset.
- Full NXP/robot log around UI alarm local `2026-05-06 16:11:14` and debug log time `2026-05-06T08:23:02Z`.
- If the alarm remains after decode correction, then collect CAN/motor/marker state logs.

## Logs And Files To Inspect

- `assets/m004-pt-0072/001-image-8108657fcdbe.png`: UI popup `移动时标记点检测异常`, robot `M004R`, voltage `54.71V`, time `2026-05-06 16:11:14`.
- `assets/m004-pt-0072/002-image-6cac87b6238b.png`: NXP/debug snippet with `dmenc: datamatrix decode failed`.
- `assets/m004-pt-0072/003-image-bc5ab98fc5c8.jpg`: annotated decode image showing row `203`, row `289`, center line, and seam/code-height discontinuity.
- Search terms: `移动时标记点检测异常`, `datamatrix decode failed`, `dmenc`, `M004R`, `横条解码`, `接缝`, `最白的两行`, `Upper: row 203`, `Lower: row 289`, `中心线`, `AllCANDM/dense_center_offset`.

## Likely Causes

- Horizontal-strip decode row selection is confused by seam brightness or uneven code height.
- Crop window cuts into the DataMatrix code, so decoding fails while the UI surfaces a marker-detection alarm.
- Decode offset/center-line logic is tuned for normal track code geometry but not for seam/transition positions.

## Exclusion Checks

- Exclude true CAN/motor fault only after checking for CANopen errors, motor heartbeat loss, or drive alarms; do not infer CAN from `system_area: CAN`.
- Exclude scanner hardware fault if decode fails only at seam/height-transition positions and normal positions decode successfully.
- Exclude UI-only false alarm if NXP/debug logs do not show `datamatrix decode failed`.
- Exclude the M004R seam branch if physical/video evidence shows the robot was not near a seam or code-height discontinuity.

## Confirmed Examples

- `m004-pt-0072`: MiniSort Pro no-scan loading mode; after locking `M004R`, UI immediately reports `移动时标记点检测异常`. Source analysis points to `M004R` decode failure. Attached debug image shows `dmenc: datamatrix decode failed`; annotated decode image shows upper row `203`, lower row `289`, and seam-related row selection that can crop the code.

## Unresolved Examples

- `m004-pt-0072`: whether M004R was physically at the seam is not confirmed in local assets; final code/config change and retest result are not visible.

## Specialist Routing

- Start with `vision-media` for raw camera frame, seam position, code-height discontinuity, and crop window.
- Add `robot-motion` for marker/DM localization during lock or movement.
- Add `embedded-software` for ALLCAN-DM decode algorithm, crop logic, and config.
- Use `can-bus` only if CANopen or motor evidence remains after the decode branch is checked.
