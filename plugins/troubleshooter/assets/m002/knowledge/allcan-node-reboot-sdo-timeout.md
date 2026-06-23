# M002 ALLCAN Node Reboot And SDO Timeout Knowledge

source_set: `m002-pt-0131`, `m002-pt-0133`
case_count: 2 M002 single-depth Mantis CAN/motor cases
status: runtime routing rules for ALLCAN node heartbeat loss, SDO timeout, and finger-motor weak-output symptoms

## Symptoms

- ALLCAN communication failure causes Mantis abnormal stop.
- NXP reports motor communication failure or SDO timeout.
- CAN evidence shows an ALLCAN node in pre-operational state or missing heartbeat.
- Example `m002-pt-0131`: `2026-05-12T02:56:23Z` 5号电机通讯失败，SDO超时; `2026-05-12T15:25:09Z` same issue recurred.
- Example `m002-pt-0133`: 2号拨指电机 expected/actual mismatch, actual can reach `9000`, but current and torque are small and speed is slow.

## Fault Tree

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

## Evidence Needed

- NXP logs covering SDO timeout and node402/CANopen state.
- CAN pcap/candump covering at least 30 seconds before and after the first SDO timeout.
- Heartbeat sequence for node 16 and adjacent nodes.
- ALLCAN board power input and 24V rail measurement during initialization and movement.
- Connector photos and board mounting/wiring inspection.
- Finger motor current, torque, speed, position, and command target curves.

## Logs And Files To Inspect

- `assets/m002-pt-0131/retry-source-LmFsbdjllodS9qxQrjqc5XLunQg.log`
- `assets/m002-pt-0131/retry-source-Smr0bvjINo7XSwxJ9nBcwyDbnm1.log`
- `assets/m002-pt-0131/retry-source-*.pcap`
- `assets/m002-pt-0133/` downloaded logs/images when inspecting the finger-motor branch.

## Likely Causes

- ALLCAN-4 or related node reboot before the observed SDO failure.
- Node 16 heartbeat loss or pre-operational state after reset.
- PDO invalid after node reboot, forcing unreliable SDO reads.
- Board power, connector, mounting, or wiring instability.
- For `m002-pt-0133`, weak motor output or drive/wiring issue on a single finger motor.

## Exclusion Checks

- If all nodes lose heartbeat together, inspect shared bus/power before blaming node 16.
- If node 16 heartbeat is normal before and after the event, do not use the reboot/PDO branch.
- If SDO timeout appears before CAN capture starts, mark exact reboot timing as unknown.
- If only one finger motor has low current/torque while others are normal, do not classify as global CAN bus failure without heartbeat or SDO evidence.
- Do not treat pre-operational state as root cause by itself; determine why the node rebooted or failed to enter operational.

## Confirmed Examples

- `m002-pt-0131`: SDO timeout at `2026-05-12T15:25:09Z`; source analysis reports node 16 missing heartbeat by `15:25:32Z`, ALLCAN-4 pre-operational, and PDO invalid after likely reboot.
- `m002-pt-0133`: 2号拨指电机 weak current/torque and slow speed, while other finger motors looked normal.

## Unresolved Examples

- `m002-pt-0131`: exact reboot trigger is unresolved because the capture starts near the event and does not show the full reset cause.
- `m002-pt-0133`: root cause of weak finger-motor output remains unresolved without full NXP/CAN waveform alignment.

## Specialist Routing

- `can-bus`: heartbeat, pre-operational state, SDO timeout, PDO validity.
- `embedded-software`: NXP CANopen stack and state-machine interpretation.
- `mantis-handling`: finger motor target/state mismatch and physical load check.
- `network-infra`: not primary unless evidence shows host-side communication loss beyond CAN.
