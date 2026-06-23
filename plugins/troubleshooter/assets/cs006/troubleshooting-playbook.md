# Cs006 Troubleshooting Playbook

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

## Mantis Climb Overtorque From Zero Rail Power

Knowledge file: `docs/cs006/knowledge/mantis-climb-overtorque-rail-power-zero.md`

### First Checks

1. Confirm the load and motion profile.
   - Record load, direction, speed, acceleration, vertical distance, and whether capacitor lead-out or test wiring changed.
   - Upward climb under load is a stronger rail-power stress condition than descent.
2. Check external/rail power before motor replacement.
   - Measure rail-power voltage at the cabinet, rail, pickup, module input, and during climb.
   - Inspect cabinet neutral line, supply polarity, series-supply wiring, and rail pickup/contact.
   - If actual rail supply is `0V`, overtorque/following error is likely a consequence of supply collapse and capacitor depletion.
3. Correlate supercapacitor voltage with motor fault timing.
   - If capacitor voltage drops while current rises and motor reports overtorque/following error, treat power feed as the first branch.
   - Use raw NXP/CAN and waveform data when available to align voltage dip, torque warning, and fault reaction.
4. Verify after correction.
   - Correct neutral/polarity/rail-power wiring.
   - Repeat the same loaded upward climb and record rail voltage, capacitor voltage/current, and NXP/CAN logs.

### Evidence

- Raw NXP log around overtorque/following error.
- CAN/drive pcap/candump or fault frames around the climb fault.
- Oscilloscope waveform export for capacitor voltage/current and rail supply.
- Cabinet/rail wiring photos before and after correction.
- Measured rail-power voltage at cabinet output, rail, pickup, and module input.
- Same-condition retest after wiring correction: load, speed, acceleration, direction, voltage/current, and fault status.

### Exclusions

- Do not replace climbing motor, drive, or controller before verifying rail power and cabinet wiring.
- Do not treat `NODE402 OVERTORQUE` as proof of mechanical overload if rail supply is absent.
- Do not conclude CAN root cause from fault reaction screenshots without CAN frames.
- Do not use descent success to clear power-feed risk; upward loaded climb has different energy demand.
- Do not close without same-condition loaded upward climb retest after wiring correction.

### Examples

- `cs006-pt-0001`: CS006-001 tested a 35kg Mantis at `1.5m/s`, acceleration `1.0m/ss`, vertical displacement `0~6600mm`. Descent on `2026-04-02` did not show the issue; upward climb on `2026-04-03` emergency-braked and NXP reported motor following error. Local log screenshot shows repeated `NODE402 OVERTORQUE`, `dual402 following error`, and `FaultReaction`. Oscilloscope photo supports capacitor voltage dropping during climb. Source resolution found G-floor CS006 cabinet neutral not connected and two series `29V` rail supplies wired in opposite positive/negative directions, making actual rail power `0V`; after adjustment, later testing had no abnormality.

- `cs006-pt-0001`: no raw NXP log, CAN/drive trace, waveform export, wiring photos, exact rail voltage measurement record, or same-condition post-fix retest log is local.
