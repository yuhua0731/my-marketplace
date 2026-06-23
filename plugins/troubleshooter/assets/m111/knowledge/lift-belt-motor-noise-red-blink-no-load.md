# M111 Lift Belt Motor Noise And Red Blink Under No-load

source_set: `m111-pt-0032`
case_count: 1 Mini/M111 lift-module belt motor abnormal-noise case
status: runtime routing rules for lift belt motor stutter/noise where the motor still squeaks after the synchronous belt is removed

## Symptoms

- During Mini/M111 feeder or lift-module debugging, the lift-module belt makes abnormal noise while running.
- Continuous script operation exposes intermittent motor stutter / `卡顿`.
- During stutter, the Xinliu motor status light is red blinking / `红色闪烁`.
- After the synchronous belt is removed, controlling the Xinliu motor alone still produces a squeaking / `吱吱声`.

## Fault Tree

1. Separate belt/load path from motor-only path.
   - If abnormal noise disappears after removing the synchronous belt, inspect belt tension, pulley alignment, bearing drag, rubbing guards, and load path.
   - If abnormal noise remains after removing the synchronous belt, prioritize motor body, motor bearing, encoder/commutation, driver, wiring, or motor controller fault.
2. Treat red blinking as a drive-state clue, not only a visual symptom.
   - Capture the exact blink code and same-window driver/CAN/error log before assigning root cause.
   - Red blink during stutter can indicate driver protection, overcurrent, phase/encoder abnormality, stall, or controller error depending on the vendor code table.
3. Inspect mechanical isolation before replacing firmware.
   - Confirm pulley set screw, shaft coupling, motor mount, belt tension, belt path, and adjacent guard clearance.
   - Then run motor unloaded, belt-only, and loaded tests to localize the sound.
4. Inspect electrical/control branch.
   - Check motor power, phase wiring, encoder cable, driver alarms, CANopen state, current/torque trend, speed command, and script command cadence.
5. Verify after component swap or adjustment.
   - A valid repair proof needs no-load motor run, belt-installed run, and continuous script run without stutter/noise/red blink.

## Evidence Needed

- Videos with audio for loaded belt run and no-belt motor-only run.
- Exact motor/driver model, blink-code table, and red-blink pattern.
- Driver/CANopen/alarm logs aligned with the stutter window.
- Motor current/torque/speed command trend during continuous script run.
- Belt tension, pulley alignment, coupling/set-screw, bearing, and guard-clearance inspection.
- Swap test: motor, driver, cable, or belt path replaced one at a time.
- Post-fix retest under the same continuous script.

## Logs And Files To Inspect

- Case body: `cases/needs-assets/m111/0032-RM1vwnQncigtWrk7YsSccB1kn1c-2026-04-03-Mini-M111提升模组皮带电机运行时异响.md`.
- Loaded/belt video: `assets/m111-pt-0032/001-source-PyK6bnq37oYG3AxLXVXcEdyynWh.mov`.
  - QuickTime metadata: 540 x 960, duration about 54.27 s, size 11680228 bytes, AAC audio at about 125 kbps.
  - QuickLook representative frame shows the lift-module belt, pulley/synchronous-wheel area, and adjacent guide structure.
- Motor-only/no-belt video: `assets/m111-pt-0032/002-source-KTUfbpoSMoEzUOxfpKNcIEtNnGg.mov`.
  - QuickTime metadata: 540 x 960, duration about 46.58 s, size 9954076 bytes, AAC audio at about 125 kbps.
  - QuickLook representative frame shows the exposed motor-side pulley/shaft area after belt removal.
- Search terms: `m111-pt-0032`, `Mini M111`, `提升模组皮带电机`, `异响`, `卡顿`, `心流电机`, `红色闪烁`, `同步带`, `拆掉同步带`, `单独控制`, `吱吱声`, `motor red blink`, `stall`, `overcurrent`, `encoder`, `CANopen`, `belt tension`.

## Likely Causes

- Motor internal bearing/rotor/commutation issue, because the source says the squeak remains after the synchronous belt is removed.
- Driver protection or motor controller error during stutter, indicated by red blinking.
- Encoder/phase wiring or feedback issue causing rough commutation under command.
- Belt tension, pulley alignment, or bearing drag can still contribute to the loaded abnormal noise, but should not be the only branch after the no-belt test still squeaks.
- Continuous script command cadence can expose marginal motor/driver faults, especially if acceleration/deceleration or speed commands are aggressive.

## Exclusion Checks

- Do not diagnose only belt tension or conveyor rubbing if the motor-only/no-belt test still produces the abnormal sound.
- Do not diagnose scheduler/conveyor recovery race; this symptom occurs during motor operation/debug script and is tied to motor red blink.
- Do not claim motor replacement is confirmed without a swap test or post-fix retest.
- Do not use video presence alone as audio proof; record whether the abnormal sound was actually heard or only described by source text.
- Do not ignore red-blink code; vendor-specific blink pattern can change the branch from mechanical to electrical/driver.

## Confirmed Examples

- None. `m111-pt-0032` is useful for the isolation method but lacks driver logs, blink-code decoding, and repair proof.

## Unresolved Examples

- `m111-pt-0032`: during Mini M111 lift-module debugging, belt motor made abnormal noise and stuttered during continuous script operation; Xinliu motor status light red-blinked during stutter. After removing the synchronous belt, motor-only control still had a squeaking sound. Local videos are present with audio tracks and representative frames, but audio content, driver logs, blink code, current/torque data, and final repair are missing.

## Specialist Routing

- Start with `mantis-handling` / handling for belt, pulley, bearing, motor mount, and mechanical isolation.
- Add `embedded-software` for motor command cadence, driver alarm state, and controller behavior.
- Add `can-bus` when CANopen/motor-node heartbeat, drive alarm, or SDO status logs are available.
- Add `vision-media` for video frame/audio evidence review.
