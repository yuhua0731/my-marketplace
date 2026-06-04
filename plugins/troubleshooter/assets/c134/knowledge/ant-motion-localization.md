# C134 Ant Motion Localization Knowledge

source_set: accepted high-priority `Ant/motion-localization`; focused cleanup sample `docs/c134/high-value-sample-cleanup-20260604.md`
case_count: 31
status: refined into motion/localization evidence patterns and route-ready decision rules from high-priority accepted cases

## Symptoms

- DM code lost during straight movement: `c134-0003`, `c134-0011`, `c134-0018`, `c134-0037`, `c134-0352`, `c134-0365`
- visible route deviation or collision after deviation: `c134-0003`, `c134-0015`, `c134-0034`, `c134-0037`, `c134-0038`, `c134-0043`, `c134-0117`, `c134-0120`, `c134-0121`, `c134-0199`, `c134-0219`, `c134-0231`, `c134-0232`, `c134-0276`, `c134-0304`, `c134-0319`, `c134-0323`, `c134-0352`, `c134-0365`
- WS scissor/tote-strip collision with robot-ID mismatch: `c134-0361`
- angle too large / command direction mismatch: `c134-0041`, `c134-0093`, `c134-0101`, `c134-0197`, `c134-0198`, `c134-0208`, `c134-0250`
- short-distance/high-speed command overrun or unreasonable braking: `c134-0304`, `c134-0319`, `c134-0428`
- repeated issue at WS001-3 or same coordinate: `c134-0101`, `c134-0198`, `c134-0208`, `c134-0231`, `c134-0232`

## Fault Tree

1. Confirm whether localization was lost.
   - Look for `DM code lost during linear motion`, continuous `NoRead`, or low scan success.
   - Examples: `c134-0003` and `c134-0037` have `[ERROR]1202#DIFF402_ERROR#MOVER_MOTOR#DM code lost during linear motion`; `c134-0352` has low scan success during rotation and straight-move failure.
   - In downloaded `c134-0003` logs, the event window starts a `LINEAR_EVENT` around `2025-10-21T02:29:00Z`; scan offset grows from `x_offset: -41` to `x_offset: -415` before later correction.
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
   - `c134-0361` has title/assets identifying A-102 but source body says A-111; preserve both and use local image/log filenames as stronger evidence for robot identity.
9. Check whether the attached logs actually cover the deviation.
   - `c134-0015` has downloaded NXP/wormhole logs, but they begin post-boot and mostly show startup/idle state, not the reported deviation sequence.

## Evidence Strength Matrix

| Evidence | Diagnostic strength | Use it for | Do not use it for |
|---|---:|---|---|
| explicit `DM code lost during linear motion` | strong | confirming localization-loss symptom | proving floor dirt without segment evidence |
| repeated `NoRead` followed by `corrected_pose` near event | medium-strong | scan instability / pose-correction branch | final collision cause without video/command context |
| command geometry with angle or tolerance violation | strong | planning/command rejection branch | blaming camera or floor code first |
| short command distance lower than braking distance | strong | impossible stop / overrun branch | floor-code diagnosis unless scan loss also exists |
| same coordinate repeated across robots | medium-strong | local route/floor/WS geometry branch | single-robot hardware cause |
| CAN motor asymmetry, heartbeat, torque/speed abnormality | strong | drivetrain branch | command planning branch alone |
| video showing first physical contact before deviation | strong | external collision/contact as cause | only proving aftermath if deviation starts earlier |
| source robot ID conflicts with filenames/image/logs | strong metadata warning | evidence reconciliation | merging cases silently |

## Evidence Checklist

Use this checklist before assigning a root cause.

1. DM/localization state.
   - Confirm exact `DM code lost during linear motion`, sustained `NoRead`, low scan count, or `corrected_pose`.
   - Dirty floor code is confirmed only when segment inspection, photo, or cleaning recovery matches the event segment.
2. Command geometry.
   - Compare expected/future pose, command distance, orientation tolerance, velocity, acceleration, and cancellation chain.
   - For short corrective moves, compute braking distance before blaming floor code.
   - Treat angle-too-large as either strict direction tolerance or tiny-move angle amplification before merging it with DM-loss cases.
3. Repeated point or WS geometry.
   - If several robots fail at WS001-3 or the same coordinate, prioritize local route/floor/WS geometry over single-robot hardware.
   - At `131847,101499/101500` or `[130847,101500]`, check same-point planning, camera offset, local scan quality, and exit/rotation geometry first.
   - Keep WS as workstation context; do not reclassify WLED/workstation-only symptoms as Ant motion.
4. Drivetrain and repair branch.
   - If commanded correction conflicts with observed deviation, request CAN/motor evidence.
   - After reducer/motor replacement, verify motor subdivision/config and calibration first.
5. Collision ordering and metadata.
   - Treat collision as an outcome unless video/log timing proves external contact happened before deviation.
   - Preserve robot-ID conflicts; route by filenames, image labels, and logs, not by a single contradictory sentence.

## Pattern Library

### Floor-Code / DM-Loss Deviation

Pattern: robot reports DM loss or shows sustained scan/no-read instability before deviation.

- `c134-0037`: A109 deviation/collision; floor code had dust and task failed with `[ERROR]1202#DIFF402_ERROR#MOVER_MOTOR#DM code lost during linear motion`.
- `c134-0003`: A107 reported `[ERROR]1202#DIFF402_ERROR#MOVER_MOTOR#DM code lost duuring linear motion`; downloaded logs show scan-offset growth and correction near the event.
- Diagnostic rule: DM-loss error confirms localization symptom; dirty floor code is confirmed only when segment inspection/photo/cleaning recovery supports it.

### Sparse Reads During Rotation Or WS Exit

Pattern: repeated failures at WS exit/same point with low scan count, `NoRead`, or pose correction.

- `c134-0231` and `c134-0232`: same coordinate `[130847, 101500]` near WS001-3; one A102 case and one A111 case point to same location.
- `c134-0361`: source body says A111, title/assets identify A102; NXP near `2026-02-08T01:07:57Z` shows `NoRead status recovered after 933 occurrences` then `corrected_pose`.
- Diagnostic rule: when same point appears across robots, prioritize local floor/route/WS geometry and preserve robot-ID conflicts explicitly.

### Command Geometry / Angle Tolerance

Pattern: robot is nearly static or making a tiny move; calculated command angle exceeds tolerance.

- `c134-0041`: command angle `10.784297867562598°` exceeded the 10-degree same-direction tolerance; resolution increased tolerance to 45 degrees.
- `c134-0197` and `c134-0250` repeat the same family: small movement or offset makes angle error dominate.
- Diagnostic rule: inspect command start/end, actual pose, camera offset, and tolerance before cleaning floor code.

### Short-Distance High-Speed Stop

Pattern: a command asks the robot to stop or correct position over a distance shorter than physical braking feasibility.

- `c134-0319`: A107 needed to slow from about `2100 mm/s` to 0 over roughly `453 mm` at `500 mm/s^2`; required stopping distance is far larger.
- `c134-0304`: similar to `c134-0319`; RMS logs missing, so use as similar-pattern but not fully closed.
- `c134-0428`: planning used current real velocity instead of theoretical velocity and planned beyond endpoint.
- Diagnostic rule: calculate braking distance before blaming floor code; new diff/planning semantics are the leading branch when geometry is impossible.

### Drivetrain / Calibration After Repair

Pattern: one robot deviates after mechanical repair or despite corrective angular command.

- `c134-0323`: A102 severe deviation after reducer replacement; two walking motors had inconsistent subdivision.
- `c134-0276`: robot computed right-turn angular speed but still deviated left; CAN was off, so obstruction/external-force branch stayed unconfirmed.
- Diagnostic rule: after reducer/motor replacement, verify motor subdivision and calibration; if behavior contradicts commanded correction, request CAN.

### Collision Ordering

Pattern: final state is collision, but root cause may be earlier scan/planning/drivetrain error.

- `c134-0034`, `c134-0037`, `c134-0304`, `c134-0319`, `c134-0352`, `c134-0365`, `c134-0361`.
- Diagnostic rule: classify collision as an outcome unless video shows contact before deviation; then open external-force/contact branch.

### Log Coverage Gap

Pattern: local assets exist, but logs cover startup/idle or a different window.

- `c134-0015`: downloaded NXP/wormhole logs begin post-boot and do not cover reported deviation.
- Diagnostic rule: do not infer a no-fault conclusion from logs that miss the motion window.

## Evidence Needed

- NXP localization/motion logs with DM read/no-read sequence.
- RCS/RMS command-set records: expected state, future state, speed, acceleration, tolerance.
- MQTT command payloads, especially `coordX`, `coordY`, `finalTargetX`, `finalTargetY`, `maxVelocity`, `maxAcceleration`.
- CAN logs for left/right motor status, speed, torque, and obstruction when deviation persists despite corrective angular command.
- video covering the start of deviation, not only final collision.
- floor-code photos and exact route segment coordinates after cleaning status is known.
- robot calibration data: camera offset angle, motor subdivision, reducer/motor replacement history.
- for WS repeated-point cases, workstation ID, exit/entry direction, and exact DM coordinate.

## Logs And Files To Inspect

- `nxp.log`, `nxp_*ANGLE_DIFF_TOO_LARGE*`, robot-specific NXP logs.
- `can2.pcap` when drive symmetry or motor state is suspected.
- RCS/RMS service logs around `robot_command_set.create`.
- Kafka `robot_command.update` and `robot_task` failure messages.
- monitor video with timestamp offset noted.

## Likely Causes

- dirty/contaminated floor code: `c134-0037`, `c134-0038`, `c134-0219`
- scan gap/low DM read success during rotation or straight move: `c134-0003`, `c134-0121`, `c134-0199`, `c134-0231`, `c134-0232`, `c134-0352`, `c134-0365`
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
- If robot ID differs between title/body/assets, keep a metadata-conflict branch and route by the strongest evidence source.

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

- DM/localization symptom confirmed but root cause open: `c134-0003`, `c134-0011`, `c134-0018`, `c134-0199`. Need floor segment condition, scanner health, and command context before final cause.
- Log coverage gap: `c134-0015` has local assets, but logs show startup/idle rather than the reported deviation sequence.
- Segment inspection requested, conclusion missing: `c134-0117`, `c134-0120`.
- WS001-3 repeated-point family: `c134-0101`, `c134-0198`, `c134-0208`, `c134-0231`, `c134-0232`, `c134-0361`. Prioritize coordinate/WS geometry, scan count, rotation state, and RMS payload before single-robot hardware.
- Metadata conflict: `c134-0361` title/assets identify A-102 but source body says A-111; NXP near `2026-02-08T01:07:57Z` shows long `NoRead` recovery and `corrected_pose`, but the direct scissor/tote-strip collision cause is not closed.
- Drivetrain branch unresolved: `c134-0276` suggests one-side motor obstruction or external force, but CAN logging was off.
- Similar-pattern without full closure: `c134-0304` resembles `c134-0319` short-distance high-speed stop, but RMS logs are missing.
- Evidence-window insufficient: `c134-0015`, `c134-0208` show why attached logs must be checked for actual event coverage before concluding no fault.

## Specialist Routing

- `robot-motion`: DM loss, angle-too-large, command geometry, route deviation, collision sequence.
- `embedded-software`: NXP scan sequence, diff402/new diff drive behavior, planning code semantics.
- `can-bus`: motor status, torque/speed symmetry, heartbeat/state when drivetrain issue suspected.
- `scheduler-traffic`: command cancellation, short corrective command generation, route conflict context.
- `vision-media`: floor-code contamination, physical deviation direction, collision ordering, timestamp offsets.
