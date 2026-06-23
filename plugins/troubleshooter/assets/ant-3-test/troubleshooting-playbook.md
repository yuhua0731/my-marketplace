# Ant 3 Test Troubleshooting Playbook

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
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## Ant 3.0 ALLCAN Power And DM Camera Knowledge

Knowledge file: `docs/ant-3-test/knowledge/allcan-power-and-dm-camera.md`

### First Checks

1. Separate DM decode performance from ALLCAN power reset.
   - `ant-3-test-pt-0082` / `0083` contain DM camera stop/decode investigation; source notes ALLCAN-DM decode speed averages near `25 ms`, Huaray camera near `22 ms`, and some high-speed MOVE windows lose scan results.
   - `ant-3-test-pt-0127` is a power/reset case, not a decode-speed case.
2. For ALLCAN/camera simultaneous communication errors, inspect 24V rail first.
   - `ant-3-test-pt-0127`: oscilloscope captured CAN1 24V output dropping from `24.4V` to `8.8V` for `10ms` during initialization.
   - Power board reboot was mostly excluded by comparison; ALLCAN-4 itself rebooted during initialization.
3. Inspect mechanical mounting and exposed copper before replacing software.
   - `ant-3-test-pt-0127` final cause: ALLCAN-4 mounting-area trace/exposed copper shorted to vehicle body through a copper standoff.
   - Fix: replace ALLCAN-4.
4. If boost-module output overcurrent appears under slope/load, separate boost capacity from downstream short/load.
   - `ant-3-test-pt-0128` has 30 kg climbing/boost-module overcurrent assets; review boost voltage/current and downstream ALLCAN/motor load before classifying as boost board defect.
5. For DM camera stop, inspect both decode timing and robot-motion command context.
   - If DM no-read occurs at high speed, compare scan result count, `decode_time`, speed, command path, and braking route.
   - Do not blame ALLCAN-DM solely from one no-read unless Huaray/other camera comparison and CAN timing support it.

### Evidence

- Oscilloscope capture of CAN/ALLCAN 24V rail during initialization and movement.
- ALLCAN board mounting photos, screw/standoff contact points, and exposed copper inspection.
- NXP log around ALLCAN/camera communication errors and reset markers.
- CAN pcap showing heartbeat/state before and after ALLCAN reboot.
- Camera decode-time statistics, scan-result counts per DM code, robot speed, and route context.
- Boost-module voltage/current logs under load, especially 30 kg slope/climb tests.

### Exclusions

- If 24V stays stable during initialization, do not use the ALLCAN mounting-short branch.
- If ALLCAN-4 and camera both reset together, inspect shared power/board first before decode algorithm.
- If only scan count drops while power and heartbeat are stable, route to vision/media + robot-motion decode branch.
- If Huaray camera works at the same DM code and speed, treat ALLCAN-DM performance or integration as higher probability.
- If boost overcurrent occurs only under 30 kg slope test, preserve load/slope condition; do not extrapolate to no-load behavior.

### Examples

- `ant-3-test-pt-0127`: ALLCAN-4 and Huaray camera communication errors during initialization; CAN1 24V dropped from `24.4V` to `8.8V` for `10ms`; final cause was exposed copper near ALLCAN-4 mounting area shorting through copper standoff; ALLCAN-4 replacement was the recorded action.
- `ant-3-test-pt-0083`: high-speed ALLCAN-DM investigation records decode-time statistics and missing scan results in MOVE windows; source does not reduce it to board power failure.

- `ant-3-test-pt-0128`: boost-module output overcurrent under 30 kg climbing still needs full boost voltage/current and downstream load analysis before being promoted to confirmed root cause.
- `ant-3-test-pt-0082`: no abnormal stop reproduced in visible text; scan-rate optimization remains open.

## Ant 3.0 ALLCAN-4 Copper Standoff Insulation Short

Knowledge file: `docs/ant-3-test/knowledge/allcan4-copper-standoff-insulation-short.md`

### First Checks

1. Treat physical spark/smoke as a hardware safety branch first.
   - `ant-3-test-pt-0125`: power cabin smoked and ALLCAN-4 was confirmed burned.
   - A replacement ALLCAN-4 sparked again when lift motor rotation began during `init+move`.
2. Inspect board mounting and insulation before software or CAN protocol.
   - The recorded cause says the ALLCAN-4 fixed-hole position used a copper standoff.
   - The copper standoff pressed through the ALLCAN-4 insulation layer and exposed internal routing.
   - The recorded fix was replacing the copper standoff with nylon material.
3. Separate static supply voltage from motion-coupled short.
   - Static input was recorded as `25.0V` and other electrical parts were reported normal.
   - A local short can still appear only during lift motor start, vibration, board flex, or harness movement.
4. Treat "can run normally" as risk masking.
   - `ant-3-test-pt-0125` says another Ant sparked during initialization but could run.
   - The source suspected 10 recently debugged Ant robots might all have the same spark symptom.
5. Keep CAN evidence as confirmation/follow-up.
   - Missing CAN logs mean heartbeat/NMT/reset behavior is unknown.
   - Do not route this primarily as a CAN protocol fault unless physical inspection excludes mounting short.

### Evidence

- Close-up photo of ALLCAN-4 mounting hole, copper standoff, insulation damage, exposed trace, and burn point.
- Continuity/insulation-resistance measurement from standoff/frame to the exposed ALLCAN-4 trace or board ground.
- Oscilloscope or power-rail capture during `init+move` and lift motor start.
- CAN pcap/candump around the spark, including heartbeat/NMT/state before and after the event.
- NXP/system logs around lift homing, move command, reset markers, and ALLCAN communication state.
- Post-fix evidence: nylon standoff installed, repeated `init+move`/lift-motion retest, and same-batch fleet inspection result.

### Exclusions

- Do not start with firmware, CANopen state, or ALLCAN protocol when there is visible spark/smoke and a recorded mounting-insulation cause.
- Do not clear the issue only because ALLCAN-4 static input voltage is `25.0V`.
- Do not treat normal robot operation after sparking as proof of safety.
- Do not use a missing board photo as confirmed visual evidence; record it as a gap until downloaded.
- Do not merge this with ALLCAN-DM decode-speed/no-read cases unless evidence shows the same power or mounting short branch.
- Do not close fleet risk until the suspected same-batch Ant robots are inspected or retested.

### Examples

- `ant-3-test-pt-0125`: Ant 3.0 `K7A30AN` smoked in the power cabin after `init+move`; ALLCAN-4 was confirmed burned. After board replacement, ALLCAN-4 sparked again when the lift motor started rotating. Visible follow-up records the cause as a copper standoff pressing through the ALLCAN-4 insulation layer and exposing internal routing. The fix was replacing the copper standoff with nylon material.

- `ant-3-test-pt-0125`: missing original board image, raw CAN/NXP logs, oscilloscope/power-rail capture, before/after standoff photos, and same-batch fleet retest result.

## Ant 3.0 Bumper Bracket Fastener Fracture

Knowledge file: `docs/ant-3-test/knowledge/bumper-bracket-fastener-fracture.md`

### First Checks

1. Confirm the actual failed object.
   - Screw shank fractured.
   - Threaded insert or standoff pulled out.
   - Bracket boss or aluminum plate cracked.
   - Fastener loosened or missing and was reported as broken.
2. Inspect impact and load path.
   - Look for bumper contact marks, bracket bending, surrounding deformation, task collision history, transport/drop history, and bumper-trigger records.
   - A single oblique photo does not prove collision or fatigue.
3. Inspect assembly process.
   - Check screw size, grade, thread engagement, washer stack, threadlocker, torque standard, torque record, and witness-paint movement.
   - Check whether the screw bottoms out before clamping the bracket.
4. Inspect design and batch risk.
   - Compare bracket edge distance, boss wall thickness, screw preload, expected bumper impact load, and vibration environment.
   - If the same fastening location fails on multiple Ant 3.0 units, treat it as design/process fleet risk.
5. Use logs as supporting context only.
   - Motion/task logs can support collision/impact timing.
   - Embedded/CAN/power logs are not primary evidence unless they show aligned bumper, emergency-stop, reset, or motion-event timing.

### Evidence

- Close-up of failed screw, fracture surface, threaded insert, bracket boss, and removed failed part.
- Screw specification: size, grade, engagement length, washer, threadlocker, and torque standard.
- Assembly torque record and witness-paint before/after comparison.
- Collision, bumper-hit, emergency-stop, transport, or vibration history around the failure.
- CAD/drawing or bracket load path for the bumper bracket.
- Same-batch Ant 3.0 inspection result.
- Repair action and post-repair impact/vibration/operation retest.

### Exclusions

- Do not route to CAN, ALLCAN, boost, DM camera, or embedded reset unless logs show aligned electrical or software symptoms.
- Do not confirm collision from the bracket photo alone.
- Do not confirm over-torque from red paint or screw-head appearance alone.
- Do not treat a replacement screw as sufficient closure without checking adjacent screws, bracket deformation, and repeat operation.
- Do not close fleet risk until same-batch Ant 3.0 units or the same bracket location are inspected.

### Examples

unknown

- `ant-3-test-pt-0126`: visible text names `K17A14AN` and `保险杠支架固定螺丝断裂`; local images confirm robot identity and bracket fastening area. Missing fracture close-up, torque/process evidence, collision history, repair action, and retest prevent confirmed root cause.

## Lift Home Sensor Sheetmetal Gap Misalignment

Knowledge file: `docs/ant-3-test/knowledge/lift-home-sensor-sheetmetal-gap-misalignment.md`

### First Checks

1. Confirm the sensor state mismatch against physical indicators.
   - `ant-3-test-pt-0124` MQTT/state screenshot shows `inductiveSensorFront: true` and `inductiveSensorRear: false`.
   - Source says front origin sensor is triggered and rear origin sensor is not triggered.
2. Inspect sensor-target gap before software/CAN diagnosis.
   - Source says front origin sensor to slider gap is small enough to trigger.
   - Source says rear origin sensor to slider gap is too large and cannot trigger.
3. Check design margin against stable sensor range.
   - Follow-up report says design gap is `2.5mm`.
   - The selected GX-H8A-P sensor maximum working distance is `2.5mm`, but stable detection range is only `0~2.1mm`.
   - This makes the design effectively zero-margin.
4. Check sheet-metal and assembly tolerance stack.
   - Report/table says sheet-metal bending and angle errors can make real gaps vary from about `0.4~2.1mm`.
   - Too-small gap around `0.3mm` can collide with and damage the sensor probe.
   - Too-large gap greater than `2.1mm` can cause missed or intermittent trigger.
5. Check dual-side height datum and coupling slip.
   - Embedded sheet records front/rear sensor measured heights `23.77mm` and `27mm`.
   - Report says assembly datum is not unified and dual-side height calibration is missing.
   - Report also records insufficient coupling clamping redundancy as a contributing factor.

### Evidence

- Raw robot/NXP log for lift homing and sensor sampling.
- Measurement record for front/rear sensor height, sensor-target gap, bend angle, and sheet-metal critical dimensions.
- Sensor model/spec sheet for stable detection range, not only maximum working distance.
- Before/after photos of sensor-target gap after rework.
- Repeated initialization/homing retest proving both sensors trigger consistently.
- Drawing revision, tolerance control plan, and assembly fixture/calibration work instruction.

### Exclusions

- Do not diagnose MQTT reporting or firmware state-machine error if physical front/rear gap explains the state mismatch.
- Do not route to ALLCAN power, DM camera, or boost-module branches unless logs show aligned power/CAN/camera symptoms.
- Do not accept max sensing distance as normal design margin; use stable detection range.
- Do not rework only one side without measuring both front/rear heights and gaps.
- Do not close without post-rework measurement and repeated homing validation.

### Examples

- `ant-3-test-pt-0124`: after initialization and upward `10mm` movement, front origin sensor triggered while rear origin sensor did not. MQTT showed `inductiveSensorFront: true`, `inductiveSensorRear: false`. Source inspection found the rear sensor gap too large. Follow-up report identified design gap `2.5mm` versus stable range `0~2.1mm`, sheet-metal/assembly tolerance stack, and front/rear height mismatch (`23.77mm` vs `27mm`) as combined causes. Recommendation was to redesign gap to `1.5~2.0mm`, increase machining control, and add unified assembly datum/calibration tooling.

- `ant-3-test-pt-0124`: no raw robot log, no final drawing revision, no after-rework measurement, and no repeated homing retest record are local.
