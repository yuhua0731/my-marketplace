# C134 Ant Motion Localization Knowledge

source_set: accepted high-priority `Ant/motion-localization`
case_count: 26
status: draft refined from visible text

## Symptoms

- DM code lost during straight movement: `c134-0011`, `c134-0018`, `c134-0037`, `c134-0352`, `c134-0365`
- visible route deviation or collision after deviation: `c134-0034`, `c134-0037`, `c134-0038`, `c134-0043`, `c134-0117`, `c134-0120`, `c134-0121`, `c134-0219`, `c134-0231`, `c134-0232`, `c134-0276`, `c134-0304`, `c134-0319`, `c134-0323`, `c134-0352`, `c134-0365`
- angle too large / command direction mismatch: `c134-0041`, `c134-0093`, `c134-0101`, `c134-0197`, `c134-0198`, `c134-0250`
- short-distance/high-speed command overrun or unreasonable braking: `c134-0304`, `c134-0319`, `c134-0428`
- repeated issue at WS001-3 or same coordinate: `c134-0101`, `c134-0198`, `c134-0231`, `c134-0232`

## Fault Tree

1. Confirm whether localization was lost.
   - Look for `DM code lost during linear motion`, continuous `NoRead`, or low scan success.
   - Examples: `c134-0037` has `[ERROR]1202#DIFF402_ERROR#MOVER_MOTOR#DM code lost during linear motion`; `c134-0352` has low scan success during rotation and straight-move failure.
2. Inspect floor-code condition and route segment.
   - Dirty/contaminated DM code caused deviation in `c134-0037`, `c134-0038`, `c134-0219`.
   - Repeated requests to inspect specific segments appear in `c134-0117`, `c134-0120`.
3. Check whether scanner reads are sparse during rotation or WS exit.
   - `c134-0121`: scan result gap caused over-rotation.
   - `c134-0231`: at `[130847, 101500]`, rotation scanned only once.
   - `c134-0232`: at `[130847, 101500]`, rotation was not in place before DM loss.
4. Check command geometry and orientation tolerance.
   - `c134-0041`: command travel angle `10.784297867562598°` exceeded the 10-degree same-direction tolerance; resolution increased tolerance to 45 degrees.
   - `c134-0197` repeats the `c134-0041` pattern.
   - `c134-0250`: small move distance `45.136349 mm` plus X offset `15.2 mm` produced angle difference `20.67942192°`.
5. Check repeated target commands and same-point planning.
   - `c134-0101`: two MOVE commands had the same target position and caused planning failure.
   - `c134-0198`: several commands targeted `131847, 101499`; one success followed by repeated failures.
6. Check speed, braking distance, and command cancellation.
   - `c134-0319`: new command tried to stop from about `2133 mm/s` over `429 mm` with acceleration `500 mm/s^2`; required braking distance was far larger.
   - `c134-0304`: similar case, A-B actual distance `246 mm`; required braking distance `(2100-0)^2/(2*500)=4410 mm`.
   - `c134-0428`: trapezoidal planning used current real velocity instead of theoretical velocity, causing planned route to exceed endpoint.
7. Check mechanical/electrical drive symmetry.
   - `c134-0276`: robot computed right-turn angular speed but still deviated left; possible one-side motor obstruction or external force; CAN log was off.
   - `c134-0323`: severe deviation after reducer replacement; two walking motors had inconsistent subdivision, new motor subdivision was not changed.
8. Separate collision aftermath from primary cause.
   - Collisions in `c134-0034`, `c134-0037`, `c134-0304`, `c134-0319`, `c134-0352`, `c134-0365` are consequences unless logs/video prove external impact preceded deviation.

## Evidence Needed

- NXP localization/motion logs with DM read/no-read sequence.
- RCS/RMS command-set records: expected state, future state, speed, acceleration, tolerance.
- MQTT command payloads, especially `coordX`, `coordY`, `finalTargetX`, `finalTargetY`, `maxVelocity`, `maxAcceleration`.
- CAN logs for left/right motor status, speed, torque, and obstruction when deviation persists despite corrective angular command.
- video covering the start of deviation, not only final collision.
- floor-code photos and exact route segment coordinates after cleaning status is known.
- robot calibration data: camera offset angle, motor subdivision, reducer/motor replacement history.

## Logs And Files To Inspect

- `nxp.log`, `nxp_*ANGLE_DIFF_TOO_LARGE*`, robot-specific NXP logs.
- `can2.pcap` when drive symmetry or motor state is suspected.
- RCS/RMS service logs around `robot_command_set.create`.
- Kafka `robot_command.update` and `robot_task` failure messages.
- monitor video with timestamp offset noted.

## Likely Causes

- dirty/contaminated floor code: `c134-0037`, `c134-0038`, `c134-0219`
- scan gap/low DM read success during rotation or straight move: `c134-0121`, `c134-0231`, `c134-0232`, `c134-0352`, `c134-0365`
- command direction/tolerance too strict near static state: `c134-0041`, `c134-0197`
- repeated same target or very short corrective move after offset: `c134-0101`, `c134-0198`, `c134-0250`
- impossible braking/short-distance command planning: `c134-0304`, `c134-0319`, `c134-0428`
- camera offset or drive calibration issue: `c134-0250`
- motor/reducer parameter mismatch: `c134-0323`
- one-side motor obstruction or external force: suspected in `c134-0276`, unconfirmed because CAN logging was off

## Exclusion Checks

- If DM reads remain healthy through the event, do not label it floor-code loss; inspect command geometry and drivetrain.
- If command distance is shorter than required braking distance, prioritize planning/tolerance over floor dirt.
- If the robot calculates corrective angular speed opposite to observed deviation, request CAN/motor evidence before blaming floor code.
- If multiple robots fail at the same coordinate, prioritize floor code/route geometry over a single robot fault.
- If one robot deviates after motor/reducer replacement, verify motor subdivision and calibration before changing global route logic.
- If collision is observed after deviation, do not use collision as root cause unless video shows external contact first.

## Handling Recommendations

- For DM loss, clean and re-photo the exact route segment, then rerun or inspect DM read sequence.
- For WS exit/short moves, inspect command start/end coordinates, actual pose, tolerance, speed, and braking feasibility before recovery.
- Avoid issuing very short stop/correction commands at high speed; enforce minimum braking distance or use theoretical planning values.
- For angle-too-large at tiny moves, prefer corrected planning semantics and camera offset calibration over repeated manual clear.
- Keep CAN logging enabled during suspected drivetrain deviation; without it, motor obstruction remains unconfirmed.
- After replacing reducer/motor, verify both walking motors have matching subdivision/config before production.

## Confirmed Examples

- `c134-0037`: A109 deviation/collision with A105; floor code had dust; task failed with `DM code lost during linear motion`; resolution was cleaning floor code.
- `c134-0041`: movement direction check used 10-degree tolerance and rejected `10.784297867562598°`; resolution was increasing tolerance to 45 degrees.
- `c134-0219`: A106 deviation; cleaning floor code solved it.
- `c134-0323`: A102 severe deviation after reducer replacement; two walking motors had inconsistent subdivision.
- `c134-0428`: planning used real speed instead of theoretical speed; route exceeded endpoint; resolution was to use theoretical values for planning.

## Unresolved Examples

- `c134-0011`, `c134-0018`: DM loss visible, root cause not confirmed in visible text.
- `c134-0117`, `c134-0120`: specific floor-code segments requested for inspection; conclusion missing.
- `c134-0231`, `c134-0232`: same coordinate `[130847, 101500]` DM read/rotation issue; root cause unresolved.
- `c134-0276`: possible motor obstruction or external force; CAN log disabled.
- `c134-0304`: similar to `c134-0319`, but RMS logs missing.

## Specialist Routing

- `robot-motion`: DM loss, angle-too-large, command geometry, route deviation, collision sequence.
- `embedded-software`: NXP scan sequence, diff402/new diff drive behavior, planning code semantics.
- `can-bus`: motor status, torque/speed symmetry, heartbeat/state when drivetrain issue suspected.
- `scheduler-traffic`: command cancellation, short corrective command generation, route conflict context.
- `vision-media`: floor-code contamination, physical deviation direction, collision ordering, timestamp offsets.
