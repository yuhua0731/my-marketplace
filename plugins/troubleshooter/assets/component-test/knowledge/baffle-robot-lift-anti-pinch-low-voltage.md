# Baffle Robot Lift Anti-Pinch And Motor Low-Voltage Stop

source_set: `component-test-pt-0080`
case_count: 1 baffle robot / lift collision case with UI screenshots, hardware alarm screenshot, physical photo, and CCTV playback
status: runtime routing rules for lift anti-pinch stops correlated with shuttle CAN low-voltage alarms

## Symptoms

- A baffle robot or shuttle collides with, interferes with, or enters the travel envelope of a lift.
- The lift reports anti-pinch vehicle protection while moving, for example `D端提升机移动时防夹车触发`.
- The robot reports a hardware/CAN alarm in the same window.
- Example `component-test-pt-0080`: I39B71S hit the rising-end lift during operation; the UI shows `D端提升机移动时防夹车触发` at `2026-04-02 11:35:06`; hardware alarm screenshot shows `I39B71S`, `2026-04-02 11:35:08`, `SHUTTLE CAN ERROR 12577`; source analysis maps `12577 -> 0x3121` as main-motor low-voltage.

## Fault Tree

1. Establish the physical sequence first.
   - Use CCTV/video to confirm whether the robot entered the lift area before the anti-pinch event.
   - Use UI event time to anchor the sequence; in this case the event is `2026-04-02 11:35:06`.
2. Correlate robot hardware alarm with lift protection.
   - If a robot alarm occurs within seconds of the lift protection event, inspect motor-power and controller-power branches before treating the lift sensor as the root cause.
   - In this case the hardware alarm is at `2026-04-02 11:35:08`, two seconds after the anti-pinch UI event.
3. Decode the hardware alarm but keep raw evidence limits explicit.
   - Source analysis states `SHUTTLE CAN ERROR 12577` maps to `0x3121`, main-motor low-voltage.
   - Without raw CAN/NXP/controller logs, this code supports a low-voltage branch but does not prove whether the low voltage caused the collision or was caused by collision/stop impact.
4. Inspect power delivery before replacing motion components.
   - Check main-motor power cable looseness, connector seating, cable movement under lift/robot motion, and intermittent voltage drop.
   - Check motherboard power output to the main motor.
5. Separate lift anti-pinch from robot motion root cause.
   - The lift anti-pinch event may be a protection response to physical interference, not the initiating failure.
   - If motion logs show the robot was commanded into the lift envelope, route to scheduler/traffic or motion planning.
   - If power logs show voltage drop before the robot failed to clear the lift, route to CAN/embedded/power.

## Evidence Needed

- UI event screenshot with exact anti-pinch event text and timestamp.
- Robot hardware alarm screenshot or log with robot ID, timestamp, alarm name, and alarm code.
- CCTV/video around at least 30 seconds before and after the anti-pinch event.
- Raw robot/NXP/CAN logs around the event, including motor voltage, controller voltage, CAN state, and motor fault code.
- Physical inspection photos of motor power cable, connector, motherboard output, lift channel clearance, and anti-pinch sensor.
- Repair or retest evidence after tightening cable, replacing cable/connector, or checking motherboard output.

## Logs And Files To Inspect

- Search terms: `D端提升机移动时防夹车触发`, `防夹车`, `上升端提升机`, `I39B71S`, `SHUTTLE CAN ERROR 12577`, `12577`, `0x3121`, `主电机`, `电压低`, `供电线松动`, `主板供电输出异常`.
- UI/event records around `2026-04-02 11:35:06`.
- Robot hardware alarm records around `2026-04-02 11:35:08`.
- CAN/NXP logs for motor voltage and state transitions if available.
- CCTV frames covering the robot position in the lift aisle before, during, and after the anti-pinch event.

## Likely Causes

- Loose main-motor power wire or connector causing intermittent low voltage and loss of normal motion/clearance.
- Abnormal motherboard power output to the main motor.
- Collision or lift protection causing a secondary voltage/CAN alarm after physical interference.
- Less likely without motion logs: scheduler or route command placing the robot inside the lift movement envelope.
- Less likely without sensor evidence: lift anti-pinch sensor false trigger.

## Exclusion Checks

- Do not treat `D端提升机移动时防夹车触发` as the root cause by itself; it may be a protection result after physical interference.
- Do not conclude motor low voltage caused the collision unless voltage/CAN evidence precedes the physical interference.
- Do not classify as Ant localization only because the source mentions a collision; require DM/pose/path evidence before using DM-code or localization branches.
- Do not replace the lift anti-pinch sensor before checking robot power alarm timing and physical interference.
- If raw CAN/NXP logs are missing, keep CAN state-transition analysis open.

## Confirmed Examples

- `component-test-pt-0080`: source text says that after CS002 ran for a period, baffle robot `I39B71S` hit the rising-end lift at `11:35`, triggering anti-pinch vehicle protection and stopping equipment. UI screenshot shows `D端提升机移动时防夹车触发` at `2026-04-02 11:35:06`; hardware alarm screenshot shows `I39B71S`, `2026-04-02 11:35:08`, `SHUTTLE CAN ERROR 12577`; source analysis maps `12577 -> 0x3121` to main-motor low-voltage and lists possible causes as loose motor power cable or abnormal motherboard power output.

## Unresolved Examples

- `component-test-pt-0080`: available CCTV playback shows the lift aisle and robot position around the event, but the exact contact point is partly occluded by the structure and playback UI. Raw CAN/NXP logs, motor voltage traces, wiring inspection results, motherboard output measurements, and post-repair retest are not local.

## Specialist Routing

- `vision-media`: CCTV sequence, robot/lift physical position, lift channel clearance, visible collision or obstruction.
- `can-bus`: `SHUTTLE CAN ERROR 12577`, `0x3121`, motor low-voltage and CAN state timing if raw frames/logs are available.
- `embedded-software`: robot hardware alarm mapping, motor fault handling, controller state around low-voltage.
- `robot-motion`: only if command/pose logs show the robot was routed into the lift envelope or failed to clear it.
- `scheduler-traffic`: only if task allocation or lift/robot interlock timing caused both devices to occupy the same space.
