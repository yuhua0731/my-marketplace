# M004 Troubleshooting Playbook

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
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## ALLCANDM Dense Center Offset Causing Shuttle Home Fail

Knowledge file: `docs/m004/knowledge/allcandm-dense-center-offset-shuttle-home-fail.md`

### First Checks

1. Start from the alarm context, not only the alarm label.
   - `回原点时编码器异常` can be a downstream symptom of failed DM/barcode decoding at a special feeder position.
   - If the robot is at a feeder position with lower-than-normal code placement, inspect camera decoding geometry before replacing encoder or drive hardware.
2. Compare feeder-position code height with normal track code height.
   - Feeder/conveyor positions can place barcode strips lower than the regular track.
   - If the decode window center line does not cover the bright/valid band of the code, the robot can fail homing/localization.
3. Read ALLCANDM dense-center-offset config.
   - Use `protocol_config.py --key AllCANDM/dense_center_offset`.
   - If the value is `0` and the feeder-position code is lower than normal, adjust the offset and retest.
4. Verify by repeated startup/homing at the same station.
   - The fix is not proven until the robot can home at the feeder position without `SHUTTLE_HOME_FAIL` / encoder abnormal alarm.

### Evidence

- UI alarm screenshot with robot ID, alarm text, voltage, and exact time.
- Physical photo showing robot position relative to feeder/conveyor code strips.
- Camera decode image with upper/lower bright rows and center line.
- Config readout for `AllCANDM/dense_center_offset` before and after adjustment.
- Retest evidence after adjusting offset.
- Raw robot/NXP logs if the alarm continues after config adjustment.

### Exclusions

- If `AllCANDM/dense_center_offset` is already set correctly and decode images show the code centered, inspect encoder, motor, drive, CAN, and homing state-machine logs.
- If the alarm happens away from feeder/conveyor code strips, do not apply this rule solely from the alarm text.
- If voltage is low or power is unstable, resolve power before interpreting decode behavior.
- If `SCAN OUT OF AREA` or barcode read errors appear in the event list, include the DM decode branch even when the popup says encoder abnormal.

### Examples

- `m004-pt-0071`: MiniSort Pro self-test startup at `2026-05-06 17:05:54`; `M004R` alarmed at `2026-05-06 17:07:03`.
  - UI screenshot shows `SHUTTLE_HOME_FAIL` for `M004R`.
  - UI screenshot also shows `回原点时编码器异常`, `M004R`, voltage `54.74V`, time `2026-05-06 17:07:03`.
  - Physical photo shows the robot at the feeder/conveyor area with dense side barcode strips; source states feeder-position codes are lower than normal track codes.
  - Decode debug image shows `Upper: row 203 (value: 183.6)`, `Lower: row 289 (value: 152.5)`, and a marked center line.
  - Config screenshot shows command `python3 protocol_config.py --key AllCANDM/dense_center_offset`, key `AllCANDM/dense_center_offset`, value `0`.
  - Source resolution: adjust camera horizontal/dense decode center-line offset, then retest.

- `m004-pt-0071`: raw NXP/robot logs and post-adjustment retest logs are not local.
- `m004-pt-0071`: the final adjusted offset value is not visible in local assets.

## ALLCANDM Seam Crop Causing Moving Marker Detection Alarm

Knowledge file: `docs/m004/knowledge/allcandm-seam-crop-marker-detection.md`

### First Checks

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

### Evidence

- Physical or video proof of M004R position at the seam when the alarm occurred.
- Raw camera frame and crop rectangle before decode, not only annotated screenshots.
- Decode algorithm/config version, including whether horizontal-strip mode or dense-center offset is enabled.
- Before/after evidence after changing crop/center-line logic or offset.
- Full NXP/robot log around UI alarm local `2026-05-06 16:11:14` and debug log time `2026-05-06T08:23:02Z`.
- If the alarm remains after decode correction, then collect CAN/motor/marker state logs.

### Exclusions

- Exclude true CAN/motor fault only after checking for CANopen errors, motor heartbeat loss, or drive alarms; do not infer CAN from `system_area: CAN`.
- Exclude scanner hardware fault if decode fails only at seam/height-transition positions and normal positions decode successfully.
- Exclude UI-only false alarm if NXP/debug logs do not show `datamatrix decode failed`.
- Exclude the M004R seam branch if physical/video evidence shows the robot was not near a seam or code-height discontinuity.

### Examples

- `m004-pt-0072`: MiniSort Pro no-scan loading mode; after locking `M004R`, UI immediately reports `移动时标记点检测异常`. Source analysis points to `M004R` decode failure. Attached debug image shows `dmenc: datamatrix decode failed`; annotated decode image shows upper row `203`, lower row `289`, and seam-related row selection that can crop the code.

- `m004-pt-0072`: whether M004R was physically at the seam is not confirmed in local assets; final code/config change and retest result are not visible.
