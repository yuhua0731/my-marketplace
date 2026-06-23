# Baffle Drop Wheel Jam Encoder Abnormal And Motor Short

source_set: `component-test-pt-0135`
case_count: 1 OmniFlow baffle-robot collision/physical jam case with two raw logs and two screenshots
status: runtime routing rules for baffle drop or wheel jam causing encoder abnormality, main-motor CAN emergency, and short-circuit alarm

## Symptoms

- Baffle robot collision or abnormal stop involving two robots.
- Source symptom: CS002 `67S` collided with `45S`, causing abnormal stop.
- Source analysis: `I39B45S` encoder position became abnormal after the event; after abnormal position, `I39B45S` may have collided with `I39B67S`, causing motor short-circuit alarm.
- UI alarm screenshot shows `I39B45S` `ERROR ENCODER ABNORMAL ERROR` at `2026-05-09 01:51:31`, `01:51:32`, and `01:51:36`, followed by `I39B45S` and `I39B67S` hardware alarms at `01:51:40` to `01:51:44`: `主电机CAN总线紧急事件` and `短路`.
- Source follow-up says the baffle dropped, jammed the driving wheel, and the robot was restored.

## Fault Tree

1. Establish physical jam before treating the fault as pure CAN communication loss.
   - Source resolution says `挡板掉落，卡住行走轮导致，已恢复`.
   - If the baffle or debris physically jams the driving wheel, the motor/encoder alarms can be consequence signals rather than the initiating CAN fault.
2. Use encoder abnormal evidence as the first log branch.
   - In `retry-source-OD9ebLeExon7CgxpjjgcTcgbngc.log`, `2026-05-09T01:51:30.964+0800` shows `error_phy_cal_pos[1]`.
   - The same log has 16 `error_phy_cal_pos` lines.
   - Screenshot evidence shows `ERROR ENCODER ABNORMAL ERROR` for `I39B45S` at `01:51:31`, `01:51:32`, and `01:51:36`.
3. Then inspect motor disable / CAN emergency / short branch.
   - `retry-source-OD9...log` shows `2026-05-09T01:51:39.698+0800` `statusword:4920` (`0x1338`) and `main motor disable detected`.
   - `retry-source-TGt...log` shows `2026-05-09T01:51:39.978+0800` `statusword:4664` (`0x1238`) and `main motor disable detected`, then repeated `statusword:4664` and disable detections.
   - The UI alarm screenshot shows `主电机CAN总线紧急事件` and `短路` starting at `01:51:40`.
4. Separate the two robots.
   - `I39B45S` has encoder abnormal alarms before the short/CAN emergency alarms.
   - `I39B67S` appears in later short/CAN emergency alarms after the source-reported collision with `45S`.
   - Do not merge both robots into one electrical root cause without per-robot logs or CAN frames.
5. Verify recovery as mechanical restoration plus CAN/motor state recovery.
   - Both local logs later show startup and CAN motor init returning normal: `CAN_MOTOR_STATE_WAIT_INIT_ON` then `CAN_MOTOR_STATE_NORMAL` around `2026-05-09T09:35`.
   - This supports recoverability after intervention, but does not by itself identify whether any encoder wheel/motor component was replaced.

## Evidence Needed

- Photo or video of the dropped baffle and jammed driving wheel before restoration.
- Physical inspection result for `I39B45S` encoder wheel, encoder sensor, driving wheel, baffle bracket, and harness.
- Per-robot mapping from the two downloaded log files to `I39B45S` and `I39B67S`.
- Raw CAN candump/pcap around `2026-05-09 01:51:30` to `01:51:44`, with node IDs and EMCY/statusword frames.
- Repair details: whether the baffle was reinstalled, encoder wheel adjusted/replaced, motor reset, wiring repaired, or only obstruction cleared.
- Retest evidence after restoration under the same baffle/drive-wheel motion.

## Logs And Files To Inspect

- Search terms: `挡板掉落`, `卡住行走轮`, `ERROR ENCODER ABNORMAL ERROR`, `error_phy_cal_pos`, `physical_calibration_pos`, `statusword:4920`, `statusword:4664`, `statusword:4671`, `main motor disable detected`, `主电机CAN总线紧急事件`, `短路`, `I39B45S`, `I39B67S`, `CAN_MOTOR_STATE_WAIT_INIT_ON`, `CAN_MOTOR_STATE_NORMAL`.
- `assets/component-test-pt-0135/retry-source-OD9ebLeExon7CgxpjjgcTcgbngc.log`: 293,399 lines; contains 16 `error_phy_cal_pos`, 1 `statusword:4920`, 1 `statusword:4664`, and 6 `main motor disable detected` matches.
- `assets/component-test-pt-0135/retry-source-TGtUbsdVdo9Uu8xeRvwcxv7RnBd.log`: 313,114 lines; contains 55 `statusword:4920`, 59 `statusword:4664`, 2 `statusword:4671`, 131 `main motor disable detected`, and 35 `RED_4` matches.
- `assets/component-test-pt-0135/retry-image-001-YsT5bCu0coC7bxxLPtOcipCzn5a.jpg`: debug screenshot around `01:51:30` to `01:51:32`, red box highlights encoder/count jump and stabilization.
- `assets/component-test-pt-0135/retry-image-002-AIxYb8DqIowbLsxXb9Tc18aQnFb.jpg`: alarm screenshot with `I39B45S` encoder abnormal followed by `I39B45S` / `I39B67S` main-motor CAN emergency and short alarms.

## Likely Causes

- Dropped baffle physically jammed the driving wheel, causing encoder position abnormality and motor overload/short alarm.
- `I39B45S` encoder wheel or encoder sensor was disturbed by the jam/collision, causing position calculation to become unreliable before the later alarms.
- Collision or physical interference between `I39B45S` and `I39B67S` propagated motor emergency/short alarms to both robots.
- Less likely as initiating cause without raw CAN evidence: primary CAN bus communication failure. The available evidence puts encoder abnormality and mechanical jam ahead of CAN emergency/short alarms.

## Exclusion Checks

- Do not classify this as only `CAN_MOTOR_ERROR` or motor communication loss when `ERROR ENCODER ABNORMAL ERROR` and physical baffle/wheel jam evidence exist.
- Do not replace motor/CAN parts before inspecting the fallen baffle, driving wheel, encoder wheel, encoder sensor, and nearby harness.
- Do not treat `主电机CAN总线紧急事件` as proof of CAN-layer root cause; motor/drive EMCY can be a consequence of mechanical jam or overload.
- Do not merge `I39B45S` and `I39B67S` into one identical fault branch; analyze the first abnormal robot and collision sequence separately.
- Do not use the 09:35 `CAN_MOTOR_STATE_NORMAL` recovery alone as proof that encoder/mechanical risk is cleared; require physical repair and retest evidence.

## Confirmed Examples

- `component-test-pt-0135`: source says CS002 `67S` collided with `45S` and caused abnormal stop. Source analysis says `I39B45S` had abnormal encoder position and may have collided with `I39B67S`, causing motor short-circuit alarm; it asks to inspect `I39B45S` encoder wheel and encoder. `retry-source-OD9...log` shows `2026-05-09T01:51:30.964+0800` `error_phy_cal_pos[1]`, followed by more `error_phy_cal_pos` lines and `ROBOT_HALT_STATE`. Alarm screenshot shows `I39B45S` `ERROR ENCODER ABNORMAL ERROR` at `01:51:31`, `01:51:32`, and `01:51:36`; at `01:51:40` to `01:51:44`, `I39B45S` and `I39B67S` report `主电机CAN总线紧急事件` and `短路`. `retry-source-OD9...log` shows `statusword:4920` (`0x1338`) and `main motor disable detected` at `01:51:39.698`; `retry-source-TGt...log` shows `statusword:4664` (`0x1238`) and `main motor disable detected` at `01:51:39.978`, then repeated disable detections. Source follow-up says the baffle dropped and jammed the driving wheel, and the issue was restored.

## Unresolved Examples

- `component-test-pt-0135`: local evidence does not include photo/video of the actual fallen baffle or jammed wheel, mapping of each log file to robot label, raw CAN candump/pcap, exact motor node IDs, encoder inspection photos, repair details, or retest duration. The case supports a strong mechanical-jam-first diagnostic branch but does not prove whether encoder hardware was damaged or only obstructed.

## Specialist Routing

- `vision-media`: alarm screenshot, debug screenshot, missing physical photo/video of baffle drop and wheel jam.
- `embedded-software`: `error_phy_cal_pos`, robot state transitions, statusword, motor disable, startup and CAN motor recovery state.
- `can-bus`: CANopen statusword/EMCY interpretation, raw CAN frame request, distinguishing consequence EMCY from CAN-layer root cause.
- `robot-motion`: collision ordering, encoder position reliability, wheel obstruction and physical pose sequence.
- `hardware`: encoder wheel, encoder sensor, baffle bracket, driving wheel, motor and harness inspection.
