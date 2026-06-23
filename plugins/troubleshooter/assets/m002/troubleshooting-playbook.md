# M002 Troubleshooting Playbook

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
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## M002 ALLCAN Node Reboot And SDO Timeout Knowledge

Knowledge file: `docs/m002/knowledge/allcan-node-reboot-sdo-timeout.md`

### First Checks

1. Align NXP SDO failure time with CAN node state.
   - `m002-pt-0131`: source says NXP SDO send failed at `2026-05-12T15:25:09Z`.
   - CAN log starts around `2026-05-12T15:25:07Z`; by `15:25:32Z`, node 16 had no heartbeat and ALLCAN-4 was already pre-operational.
2. Treat missing heartbeat as a node-health signal, not only a bus-noise signal.
   - If a single node has no heartbeat while adjacent nodes continue, inspect that ALLCAN board, its 24V supply, connector, and reset history.
3. If PDO is invalid after reboot, expect SDO fallback or stale upper state.
   - Visible source conclusion for `m002-pt-0131`: node had likely rebooted earlier, PDO was invalid, and state could only be read through SDO.
4. For finger motor weak output, separate communication from motor/drive/load.
   - `m002-pt-0133`: 2号拨指电机 current and torque are small, speed is very slow, and other finger motors do not show the same abnormality.
   - This pattern is not enough to prove mechanical obstruction; check command, drive state, supply voltage, and motor wiring first.
5. Compare repeated events.
   - Multiple recurrence windows in the same day should be treated as board/power/wiring instability until proven otherwise.

### Evidence

- NXP logs covering SDO timeout and node402/CANopen state.
- CAN pcap/candump covering at least 30 seconds before and after the first SDO timeout.
- Heartbeat sequence for node 16 and adjacent nodes.
- ALLCAN board power input and 24V rail measurement during initialization and movement.
- Connector photos and board mounting/wiring inspection.
- Finger motor current, torque, speed, position, and command target curves.

### Exclusions

- If all nodes lose heartbeat together, inspect shared bus/power before blaming node 16.
- If node 16 heartbeat is normal before and after the event, do not use the reboot/PDO branch.
- If SDO timeout appears before CAN capture starts, mark exact reboot timing as unknown.
- If only one finger motor has low current/torque while others are normal, do not classify as global CAN bus failure without heartbeat or SDO evidence.
- Do not treat pre-operational state as root cause by itself; determine why the node rebooted or failed to enter operational.

### Examples

- `m002-pt-0131`: SDO timeout at `2026-05-12T15:25:09Z`; source analysis reports node 16 missing heartbeat by `15:25:32Z`, ALLCAN-4 pre-operational, and PDO invalid after likely reboot.
- `m002-pt-0133`: 2号拨指电机 weak current/torque and slow speed, while other finger motors looked normal.

- `m002-pt-0131`: exact reboot trigger is unresolved because the capture starts near the event and does not show the full reset cause.
- `m002-pt-0133`: root cause of weak finger-motor output remains unresolved without full NXP/CAN waveform alignment.
