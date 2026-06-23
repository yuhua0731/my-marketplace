# M123 Forced Discharge Fails When Idle Robot Is Waiting At Mini Pro Standby Point

source_set: `m123-pt-0017`
case_count: 1 M123 Mini Pro forced-discharge helper-dispatch case
status: runtime routing rules for feeder abnormal recovery where forced discharge fails because the Mini Pro standby/waiting-point robot state is not covered by helper-robot dispatch logic

## Symptoms

- M123 / Mini Pro runs in no-scan feeding mode.
- During normal parcel delivery, the feeder reports an abnormal condition such as `供包机包裹超长`.
- Operator attempts forced discharge / abnormal recovery.
- UI reports `恢复感应输送机失败，等待空闲机器人前来处理`.
- The feeder does not return to origin after forced discharge fails.
- A robot may be idle at a Mini Pro waiting/standby point rather than physically at the station.

## Fault Tree

1. Confirm the feeder abnormal and forced-discharge failure state.
   - In `m123-pt-0017`, the UI screenshot timestamp is `2026-03-18 09:52:34`.
   - The visible toast says `恢复感应输送机失败，等待空闲机器人前来处理`.
   - The exception popup says `供包机包裹超长`, with handling instruction to remove all feeder parcels before recovery.
2. Check helper-robot selection and station reachability.
   - Source analysis says Mini Pro added a waiting point / `等待位`.
   - When a second-layer robot waits at that waiting point, the previous logic for "robot not at station, ask another station robot to assist forced discharge" did not respond.
3. Separate waiting-point state from "no idle robot exists".
   - The UI message asks for an idle robot, but the source says the issue is not absence of robot; it is that the logic did not cover robots waiting at the new Mini Pro standby point.
4. Verify dispatch after code change.
   - Source resolution adds handling logic for a robot at the standby/waiting point so it can go to the station and assist forced discharge when feeder failure occurs.

## Diagnostic Rules

- For M123/Mini Pro forced-discharge failure with `等待空闲机器人前来处理`, inspect whether an idle robot is at a Mini Pro waiting/standby point before concluding no robot is available.
- Search scheduler/RCS logs for helper-robot candidate selection, waiting-point state, station occupancy, forced-discharge task creation, and go-to-station command.
- Confirm whether the failed branch was a feeder abnormal recovery branch, not a sensor length-measurement root cause or a generic robot load failure.
- If a waiting-point robot is available but no assist task is issued, update helper dispatch logic to include waiting-point/standby states.
- Require post-fix evidence that the waiting-point robot goes to the station and forced discharge completes.

## Evidence Needed

- RCS/scheduler logs around `2026-03-18 09:52:33` to `09:52:34`, including station ID, robot candidates, waiting-point state, and task creation.
- Feeder/conveyor logs for the `供包机包裹超长` abnormal and forced-discharge recovery attempt.
- Robot state table showing whether `B0-8` or another second-layer robot was idle/waiting, at station, or locked.
- Before/after code or config change that adds waiting-point handling.
- Post-fix forced-discharge retest with a robot starting from the waiting point.

## Logs And Files To Inspect

- Case body: `cases/accepted/m123/0017-OnPEwecsWire28ktKFLcztVenzf-2026-03-18-M123-Mini-pro强排失败.md`.
- Local image: `assets/m123-pt-0017/001-image-0b656f17a30f.jpg`.
  - 2760 x 1408 JPEG.
  - Shows operation UI at `2026-03-18 09:52:34`, toast `恢复感应输送机失败，等待空闲机器人前来处理`, exception `供包机包裹超长`, and instruction to remove all feeder parcels before recovery.
- Local image: `assets/m123-pt-0017/002-image-1a3ad4ea8c42.jpg`.
  - 913 x 621 JPEG.
  - Shows station/robot layout with `B0-8` highlighted and Mini Pro waiting/stop markers.
- Search terms: `m123-pt-0017`, `M123`, `Mini pro`, `强排失败`, `恢复感应输送机失败`, `等待空闲机器人前来处理`, `供包机包裹超长`, `等待位`, `待机点`, `空闲机器人`, `B0-8`, `强排`, `协助强排`, `供包机不回原点`.

## Likely Causes

- Mini Pro introduced a waiting/standby point state that older forced-discharge helper-robot dispatch logic did not treat as a valid assist candidate.
- Helper dispatch logic only covered robots not at station through other station states, leaving second-layer waiting-point robots ignored.
- The UI therefore continued waiting for an idle robot even though a usable robot existed in a new state/location.

## Exclusion Checks

- Do not diagnose the feeder motor, CAN node, or homing hardware from `供包机不回原点` until helper-robot dispatch and forced-discharge task creation are checked.
- Do not merge with package length undermeasurement unless logs show the package overlength detection itself is false; here the reusable bug is recovery helper dispatch after the abnormal.
- Do not call it no-idle-robot condition until waiting-point robots and station-assist candidates have been enumerated.
- Do not close from UI screenshots alone; scheduler/RCS logs or post-fix retest should prove the waiting-point branch.

## Confirmed Examples

- `m123-pt-0017`: Mini Pro no-scan feeding hit feeder overlength, forced discharge failed, UI reported `恢复感应输送机失败，等待空闲机器人前来处理`, and the feeder did not return to origin. Source analysis says Mini Pro added a waiting point; when a second-layer robot was waiting there, older helper-dispatch logic did not respond. The fix added handling for robots at standby/waiting points so they go to the station to assist forced discharge.

## Unresolved Examples

- `m123-pt-0017`: local assets do not include RCS/scheduler logs, feeder/conveyor logs, exact station ID, raw robot state table, code diff, or post-fix retest proof.

## Specialist Routing

- Start with `scheduler-traffic` for helper-robot candidate selection, waiting-point state, station assist task creation, and recovery lifecycle.
- Add `vision-media` for UI and robot-position screenshot evidence.
- Add `embedded-software` if feeder/conveyor recovery state-machine logs show forced-discharge command rejection or homing failure after helper dispatch succeeds.
