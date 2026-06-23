# Full-box Exception Unload Delayed Move Slow Run

## Symptoms

- Mini Plus / MiniSort runs in production mode with both stations using locked sowing mode.
- A robot goes to a target grid for throwing, finds the grid full, and the operator clicks check-complete/recover.
- The robot then goes to the exception mouth for throwing, but its movement speed is abnormal or very slow.
- In `minisort-test-pt-0052`, the abnormal window is reported around `14:28:42~14:29:28`, robot `M004L`.

## Fault Tree

1. Confirm the business precondition.
   - Locked sowing mode is enabled on both stations.
   - The robot is handling a full-box recovery path and moving to the exception mouth after check-complete/recover.
2. Compare central-control command parameters with robot movement events.
   - In `minisort-test-pt-0052`, the command screenshot at `2026-03-31T14:28:42.675+0800` shows `position: 2.42`, `speed: 4`, `acc: 3.2`, `dec: 3.2`.
   - If the command speed is normal but the robot still moves slowly, route to robot-side move timing/state-machine evidence before blaming central-control command generation.
3. Inspect move lifecycle timing.
   - The robot log screenshot shows pre-arrival/motion event, `MovementProgress::Move -> terminate`, and `Move::Exit -> terminate` around `14:28:42`.
   - The same screenshot shows a new move starts immediately after `MainController::Idle -> Move`, `cmd_pos 2420000mm`, `seq 984`, and `target: 2420mm`.
   - The slow-run block continues until about `14:29:28` before motion event termination.
4. Inspect PDO/SDO profile velocity timing.
   - Local screenshot shows `pdo profile velocity: 4753` at `2026-03-31 06:28:42.678017850`.
   - It then shows `sdo profile velocity: 4753` at `2026-03-31 06:28:42.719484899`.
   - The source analysis says the SDO speed write occurs after PDO speed setting and uses the same value, so the issue is not a wrong speed number but when move parameters take effect.
5. Check delayed `move` parameter application.
   - Source resolution says all delayed-call move parameters should take effect after the movement-start event.
   - If a delayed move call updates parameters before the movement start event is fully handled, the robot may enter a move state with stale or transitional speed behavior.

## Evidence Needed

- Raw robot log text around `2026-03-31 14:28:42~14:29:28` for `M004L`.
- Central-control dispatch log proving the exception-mouth move command, target, speed, acc, dec, and seq.
- Full robot state-machine log around pre-arrival, terminate, ACK, new move start, movement progress, and final terminate.
- Motor PDO/SDO write log with exact object/index if available, not only screenshot text.
- The whiteboard attached to the source document; it is referenced but not present locally.
- Code diff or firmware version showing the delayed move parameter application fix.
- Post-fix retest video/log proving exception-mouth movement speed is normal after full-box recovery.

## Logs And Files To Inspect

- Robot logs for `M004L`, `MOVE_EVENT`, `HEALTH_EVENT`, `MovementProgress`, `Move::Exit`, `MainController::Idle -> Move`, `cmd_pos`, `target`, and `seq 984`.
- Central-control/zigbee logs for `move_cmd payload`, `position`, `speed`, `acc`, `dec`, and ACK.
- Motor profile velocity logs for `pdo profile velocity` and `sdo profile velocity`.
- Search terms: `minisort-test-pt-0052`, `格口满箱`, `异常口`, `速度异常`, `14:28:42`, `14:29:28`, `M004L`, `seq 984`, `position: 2.42`, `speed:4`, `acc:3.2`, `dec:3.2`, `pdo profile velocity`, `sdo profile velocity`, `MovementProgress`, `延时调用move`.

## Likely Causes

- Robot-side delayed move parameters were applied at the wrong point in the movement lifecycle.
- The exception-mouth move after full-box recovery starts immediately after a pre-arrival/terminate transition, exposing a timing race in parameter application.
- Command values are normal, but robot-side state-machine timing causes the effective motion behavior to be slow.

## Exclusion Checks

- Do not blame central-control command generation if `move_cmd payload` already contains normal `speed`, `acc`, and `dec`.
- Do not treat the SDO write as a wrong-value branch when PDO and SDO profile velocity values are identical.
- Do not route to generic full-box sensor mapping unless the symptom is trigger-count UI/MQTT/CAN gateway mapping failure.
- Do not route to locked-sowing count logic when the main symptom is robot physical movement speed toward the exception mouth.
- Do not close the case without post-fix movement logs or video showing normal exception-mouth speed.

## Confirmed Examples

- `minisort-test-pt-0052`: in production locked-sowing mode, after a full grid is recovered, robot `M004L` moves toward the exception mouth with abnormal speed around `14:28:42~14:29:28`. The command screenshot shows normal `position: 2.42`, `speed: 4`, `acc: 3.2`, `dec: 3.2`; robot logs show slow movement after movement start/terminate transitions; PDO and SDO profile velocity are both `4753`. Source resolution says delayed-call move parameters should take effect after the movement-start event.

## Unresolved Examples

- `minisort-test-pt-0052`: raw logs, source whiteboard, code diff, firmware version, and post-fix retest proof are not local.

## Specialist Routing

- `embedded-software`: primary owner for robot move state-machine timing and PDO/SDO parameter application.
- `scheduler-traffic`: verify central-control command sequence and exception-mouth target only after preserving robot-side logs.
- `vision-media`: use video to confirm the visible slow-run symptom and post-fix speed behavior.
