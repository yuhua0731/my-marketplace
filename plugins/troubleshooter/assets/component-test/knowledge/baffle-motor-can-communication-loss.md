# Baffle Motor CAN Communication Loss And Recovery Failure

source_set: `component-test-pt-0086`, `component-test-pt-0087`
case_count: 2 baffle robot CAN communication cases with log screenshots, one raw text log, and CAN-bus resistance photo
status: runtime routing rules for baffle robot / baffle motor CAN communication loss, failed baffle-up command, and recovery failure

## Symptoms

- Baffle robot stops abnormally with CAN communication exception during operation.
- Main walking motor temperature and voltage telemetry stop or become stale.
- Baffle-up command fails with a flow/baffle motor error.
- Recovery is attempted but fails or enters a repeated recovery state.
- Example `component-test-pt-0086`: CS002 library `67S` baffle robot had CAN communication abnormal stop; S209 library `401S` failed sending baffle-up command; source conclusion says both are motor communication abnormal and motor wiring should be checked.
- Example `component-test-pt-0087`: CS002 `67S` baffle robot had main-motor CAN communication abnormal stop; main motor telemetry froze at `main motor temp: 76732, voltage: 26689`; recovery failed; bus resistance measured `112.4Ω`.

## Fault Tree

1. Separate main walking motor CAN loss from baffle actuator CAN loss.
   - CS002 branch: source says walking motor temperature and voltage data stopped reporting and communication disconnected.
   - S209 branch: baffle motor communication abnormal caused baffle-up command failure.
2. Anchor on the last valid telemetry before the fault.
   - Screenshot evidence shows repeated main motor telemetry such as `main motor temp: 75764, voltage: 27088`, followed by `CAN_MOTOR_ERROR`.
   - Raw-log evidence in `component-test-pt-0087` shows `main motor temp: 76732, voltage: 26689` starting at `2026-04-14T21:06:09.359+0800`, then persisting more than 10,000 times through `2026-04-14T23:59:59.737+0800`.
   - Treat repeated identical telemetry before the error as possible stale data; require raw logs to prove whether the motor was still reporting live values.
3. Inspect command/state transition around the actuator failure.
   - S209 screenshot shows `BAFFLE_RUN_UP_START`, then `set_flow_motor_baffle_turn error`.
   - Recovery screenshot shows `BAFFLE_RUN_RECOVERY`, `retry_baffle_send`, and repeated `lifter sensor block: 181551`.
4. Check wiring and connector branches before firmware changes.
   - Source conclusion explicitly says both issues are motor communication abnormal and motor wiring should be checked.
   - Inspect motor power/CAN connector seating, cable strain, shielding, termination, node connector, and intermittent harness movement.
   - If bus resistance is around `112.4Ω`, do not stop there; the source marked it normal, but the frozen telemetry still requires node-side wiring, connector, power, and raw CAN checks.
5. Use raw logs/CAN frames to decide cause direction.
   - If CAN heartbeat/SDO/PDO stops before command failure, prioritize physical bus or node power.
   - If CAN remains healthy but command returns actuator error, inspect baffle state machine, sensor block, and actuator calibration.
   - If only screenshots exist, keep cause as likely communication/wiring, not confirmed CAN physical-layer failure.

## Evidence Needed

- Raw robot/NXP/shuttle MQTT logs around the fault, not only screenshot snippets.
- CAN candump/pcap around the stop, with heartbeat, PDO/SDO, node ID, and error frames.
- Exact robot IDs, library/project, firmware version, motor node ID, and actuator node ID.
- Photos or inspection notes for motor CAN cable, power cable, connector, terminal resistor, and harness strain points.
- Recovery logs showing whether `BAFFLE_RUN_RECOVERY` succeeds, retries, or fails permanently.
- Retest evidence after cable reseating/replacement or controller/motor swap.
- Bus resistance measurement point and power-off state when measuring resistance.

## Logs And Files To Inspect

- Search terms: `CAN_MOTOR_ERROR`, `CAN通讯异常`, `通讯断开`, `main motor temp`, `voltage`, `BAFFLE_RUN_UP_START`, `set_flow_motor_baffle_turn error`, `BAFFLE_RUN_RECOVERY`, `retry_baffle_send`, `lifter sensor block`, `baffle_send_target_position`, `flow_motor_baffle_stop_pos`.
- CS002 / `67S` logs around `2026-04-13T06:19:35+0800` to `2026-04-13T06:19:39+0800`.
- CS002 / `67S` logs around `2026-04-14T21:06:09+0800` to `2026-04-14T21:06:13+0800`, then later lines proving whether telemetry stays frozen.
- S209 / `401S` logs around `2026-04-12T13:40:34+0800` to `2026-04-12T13:40:37+0800`.
- Raw CAN frames if available, especially heartbeat loss, bus-off, SDO timeout, PDO stop, and node reset markers.
- Search terms: `belt_servo_reset_error`, `servo_reset_error`, `statusword:5688`, `statusword:4664`, `76732, voltage: 26689`, `112.4`.

## Likely Causes

- Loose, intermittent, or damaged motor CAN wiring/connector.
- Motor node power or ground interruption causing telemetry stop and CAN error.
- Baffle actuator CAN communication loss during baffle-up command.
- Recovery loop blocked by stale sensor state such as repeated `lifter sensor block`.
- Servo reset failure after CAN motor error, shown by `belt_servo_reset_error` and repeated `servo_reset_error`.
- Less likely without raw evidence: firmware state-machine bug or command sequencing issue after communication recovers.

## Exclusion Checks

- Do not treat screenshots alone as proof of physical CAN-layer failure; require raw CAN/log evidence for confirmation.
- Do not merge CS002 walking-motor communication loss and S209 baffle-up failure into one identical root cause unless wiring or node evidence links them.
- Do not diagnose scheduler/traffic unless commands are valid and motor/CAN telemetry remains healthy.
- Do not replace the baffle motor before checking cable, connector, termination, node power, and recovery logs.
- If telemetry values continue changing normally after the reported failure, inspect state-machine or actuator command errors before CAN wiring.
- If CAN-bus resistance is near the expected value, do not exclude intermittent connector, node power, or single-node communication loss.

## Confirmed Examples

- `component-test-pt-0086`: visible source text says CS002 `67S` baffle robot stopped abnormally with CAN communication exception; walking motor temperature and voltage data stopped reporting and communication disconnected. Screenshot evidence shows `CAN_MOTOR_ERROR` after repeated `main motor temp: 75764, voltage: 27088`. Source also says S209 `401S` failed to send baffle-up command; screenshot evidence shows `BAFFLE_RUN_UP_START` followed by `set_flow_motor_baffle_turn error`, then recovery state `BAFFLE_RUN_RECOVERY` with repeated `lifter sensor block: 181551`. Source conclusion: both problems are motor communication abnormal and motor wiring should be checked.
- `component-test-pt-0087`: source text says CS002 `67S` baffle robot stopped because of main-motor CAN communication abnormality; main motor temperature and voltage were not updating; recovery failed; bus resistance measured `112.4Ω` and was considered normal. Raw log `004-source-ABBhbAzmEoTmvlxvthtcme3Wnxd.3` shows `2026-04-14T21:06:09.774+0800` `CAN_MOTOR_STATE_SET_ZERO_SPEED`, `21:06:10.794+0800` `CAN_MOTOR_STATE_GET_ZERO_SPEED_STATE`, `21:06:11.613+0800` `CAN_MOTOR_ERROR`, statuswords `5688` (`0x1638`) and `4664` (`0x1238`), then `belt_servo_reset_error` and repeated `servo_reset_error`. The same `main motor temp: 76732, voltage: 26689` value appears 10,375 times through `2026-04-14T23:59:59.737+0800`, supporting stale/frozen telemetry after the CAN fault.

## Unresolved Examples

- `component-test-pt-0086`: only screenshots are local. Raw text logs, CAN frames, motor node IDs, cable inspection results, exact repair, and retest evidence are missing. The case supports a high-value motor CAN/wiring diagnostic branch but does not prove the exact electrical failure point.
- `component-test-pt-0087`: raw robot log and resistance photo are local, but raw candump/pcap, node ID, exact connector measurement point, repair action, and retest evidence are still missing.

## Specialist Routing

- `can-bus`: CAN heartbeat/SDO/PDO loss, node power, termination, connector, and raw candump/pcap timing.
- `embedded-software`: robot state transitions, stale telemetry, `CAN_MOTOR_ERROR`, baffle command state, and recovery loop.
- `vision-media`: screenshot evidence, connector photos, wiring inspection photos, and physical harness routing.
- `mantis-handling`: only for baffle/lift actuator mechanics after communication and sensor evidence are checked.
