# Mantis Test Troubleshooting Playbook

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

## CAN2 Fork-Arm Belt Harness Intermittent CANL Fault

Knowledge file: `docs/mantis-test/knowledge/can2-fork-arm-belt-harness-intermittent-canl.md`

### First Checks

- Confirmed branch: resistance instability is mechanically coupled to the left fork arm.
  - Source symptom says CAN2 line resistance frequently jumps in the `60Ω~120Ω` range.
  - Source says pressing/pushing the left fork arm causes obvious CAN2 resistance fluctuation.
  - Local video thumbnail `retry-source-BUxib...mp4` shows a multimeter around `118.5Ω` while the fork-arm area is being manipulated.
- Confirmed branch: ALLCAN termination switch mis-touch was checked and excluded.
  - Source says ALLCAN-8_580 cover was removed and the resistor DIP switch was checked.
  - Pressing/pushing the fork arm did not cause DIP switch mis-touch.
- Confirmed branch: board sockets are stable when the fork-arm communication belt harness is disconnected.
  - Source says after removing ALLCAN-8_580 and side ALLCAN-4_590 covers, disconnecting both ends of the fork-arm communication belt harness, and measuring the sockets while moving the fork arm, resistance at both board sockets was normal and stable.
- Confirmed branch: the harness itself shows intermittent CANL continuity.
  - Source says multimeter continuity test on the fork-arm communication belt harness found CANH normal.
  - Source says CANL beeper became intermittent while the fork arm was pulled back and forth.
  - Source cause: one or more positions inside the fork-arm communication belt harness caused CANL short/unstable continuity when the fork arm moved.
- Resolution branch: replacing the left fork-arm communication belt harness.
  - Follow-up states normal debugging on `2026-06-01`, `2026-06-02`, and `2026-06-11`, then issue closed.

### Evidence

- Full multimeter video/audio or measurement log showing the resistance jump sequence while moving the fork arm.
- Clear photo of the disconnected ALLCAN-8_580 and ALLCAN-4_590 connector points.
- Harness part number, connector pinout, affected CANH/CANL pins, and replacement part record.
- Post-replacement resistance measurement under repeated fork-arm movement.
- CAN traffic/log evidence showing whether communication errors disappeared after harness replacement.

### Exclusions

- Do not blame CAN termination DIP switch if pressing/pushing the fork arm does not touch the ALLCAN-8_580 resistor switch and socket measurements remain stable.
- Do not replace ALLCAN-8_580 or ALLCAN-4_590 before disconnecting the fork-arm harness and measuring board-side socket resistance.
- Do not treat a static normal resistance as sufficient; move the fork arm while measuring because the fault is motion-coupled.
- Do not declare CANH/CANL both faulty if continuity testing shows CANH stable and CANL intermittent.
- Do not close after replacement without dynamic resistance retest and communication retest under fork-arm motion.

### Examples

- `mantis-test-pt-0119`: Mantis 2.6.0 CAN2 resistance jumped between `60Ω` and `120Ω`. Pushing/pressing the left fork arm reproduced instability. ALLCAN-8_580 termination switch mis-touch was excluded. With both ends of the fork-arm communication belt harness disconnected, board socket resistance at ALLCAN-8_580 and ALLCAN-4_590 was normal and stable during fork movement. The harness continuity test found CANH normal but CANL beeper intermittent while moving the fork arm. Replacing the left fork-arm communication belt harness resolved the issue; follow-up on 2026-06-01, 2026-06-02, and 2026-06-11 reported normal debugging/no abnormality.

- `mantis-test-pt-0119`: local assets lack the still image referenced in the source, raw CAN logs, full measurement audio/transcript, exact harness part number, and post-replacement measurement video.

## Mantis Climb Motor Brake Holding Margin

Knowledge file: `docs/mantis-test/knowledge/climb-motor-brake-holding-margin.md`

### First Checks

1. Confirm the issue is brake holding, not software hold.
   - If the unit descends when powered off and manually pressed, inspect brake holding torque and backdrive first.
2. Quantify load margin.
   - Test by load steps and both sides separately.
   - Calculate required brake torque from load, reducer ratio, drum/gear geometry, and side-to-side distribution.
   - A load rate near `96%` indicates insufficient system safety margin even if nominal brake torque appears close.
3. Inspect the worse side.
   - Check brake air gap, brake coil voltage, release/hold timing, wiring, reducer backdrive, mounting, and mechanical load sharing.
4. Compare motor families.
   - Preserve exact 1000W motor vendor, brake torque, rated torque, interface compatibility, and test result.
   - Treat a 1200W upgrade as a mitigation branch until same-condition retest proves it.

### Evidence

- Load-step test table with side, load, displacement, and pass/fail.
- Video with calibrated displacement or ruler/scale.
- Brake holding torque test or motor datasheet with brake torque.
- Reducer ratio, load geometry, and safety-factor calculation.
- Brake air-gap, coil voltage, wiring, and release/hold timing measurements.
- Same-condition retest after 1200W or brake/motor replacement.

### Exclusions

- Do not diagnose CAN, servo control, or scheduler first when power-off manual pressing reproduces descent.
- Do not compare brake torque numbers without reducer ratio and load geometry.
- Do not assume both sides are equivalent if motor 2 descends more obviously.
- Do not mark a 1200W replacement strategy verified without same-load emergency-stop and power-off retest.

### Examples

- `mantis-test-pt-0120`: under `35kg`, Mantis 2.6.0 was not level and descended slowly after emergency stop; motor 2 was more obvious. Power-off manual pressing indicated the climb motor brake did not fully lock, with reducer ratio `10`. The load table records descent on Mantis 2.6 with `1000W 伟创` at `35kg`, but not at lower loads; CS006 1# and CS006 3# show no descent in the table. Follow-up states the 1000W motor load rate reached `96%`, safety margin was insufficient, and 1200W higher-torque compatible motors were being procured for trial.

- `mantis-test-pt-0120`: no calibrated displacement/force measurement, local `1000W 伟创` brake-torque PDF, brake air-gap/coil-voltage data, reducer backdrive calculation, or 1200W retest result is local.

## Climbing Gear-Rack Nylon Wear Noise

Knowledge file: `docs/mantis-test/knowledge/climbing-gear-rack-nylon-wear-noise.md`

### First Checks

- Confirmed branch: abnormal noise is mechanically coupled to the climbing rack/gear pair.
  - `mantis-test-pt-0118` source states the climbing rack and gear were worn.
  - Source states abnormal gear-rack meshing caused the clunking sound.
- Confirmed branch: material pairing is high-risk.
  - Source states rack material was `PA66`.
  - Source states gear material was `MC901`.
  - Source classifies this as all-plastic transmission and nylon-on-nylon friction.
- Supported branch: visible local photos show wear evidence.
  - Gear/shaft/keyway images show reddish-brown abrasion residue, grooves, and wear tracks.
  - Bore/roller photos show additional scoring/dirty wear context around rotating interfaces.
- Likely branch: high-cycle vertical motion accelerates wear and backlash growth.
  - Empty-load `24h` running at `1.5m/s` and `1m/s^2` can expose material-pair durability issues.
  - Increased backlash or tooth-profile wear can make rack/gear teeth impact and produce clunking.
- Secondary branch: alignment, bearing/shaft support, rack straightness, and gear installation can aggravate the same noise and should be checked before closure.
- Exclusion branch: CAN or motor-control faults are not primary unless decoded logs show aligned motor/CAN errors. A raw CAN CSV alone is only context.

### Evidence

- Full video/audio aligned to the moment of `哐哐哐` noise.
- Close-up photos of gear teeth, rack teeth, shaft/keyway, bearings, and mounting/bore areas before and after replacement.
- Gear/rack material spec, hardness/wear-resistance data, and part batch.
- Backlash, tooth wear depth, rack straightness, shaft/bearing play, and installation/alignment measurements.
- Motor current/torque or CAN decoded state during the noise window.
- Same-condition retest after material change: speed, acceleration, load, duration, noise, backlash, and wear state.

### Exclusions

- Do not route to CAN2 harness fault without resistance jump, CANH/CANL continuity issue, heartbeat loss, or decoded CAN fault evidence.
- Do not blame the 1000W motor without current, torque, drive fault, or speed-control evidence.
- Do not treat harness replacement as the cause of mechanical clunking unless the noise changes with harness state or routing interference.
- Do not close the case after material change without same-condition endurance retest and wear/noise comparison.
- Do not infer material or wear severity from file names; use source text, visible photos, measurements, and retest records.

### Examples

- `mantis-test-pt-0118`: 003 Mantis used Xinliu 1000W motor, replaced climbing gear and harness, then ran empty-load `24h` from `05-08 10:00` to `05-09 10:00` at `1.5m/s` and `1m/s^2`. During spider mechanism up/down movement, it produced `哐哐哐` mechanical noise. Source analysis says climbing rack/gear wear caused abnormal meshing and clunking. Source further says PA66 rack plus MC901 gear formed an all-plastic nylon-on-nylon pair with fast wear. Resolution was changing gear material. Local photos show wear residue/grooves on the gear/shaft/keyway and wear/scoring context on nearby rotating interfaces.

- `mantis-test-pt-0118`: no full audio transcript, no timestamped sound frame, no measured wear/backlash, no material certificate, no decoded CAN mapping, and no same-condition post-material-change retest are local.
