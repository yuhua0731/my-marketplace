# OmniFlow Legacy RF And CAN Knowledge

source_cases: `c113-0001`
company_manual_archive: `assets/hc-robotics/knowledge/motor-manuals.md`
status: accepted training pattern from Feishu thread, UART logs, and LD2 CANopen manual

## Use For

- legacy RF-version OmniFlow projects such as C113
- Spyder/Ladder/Ant no-self-check after UI start
- scheduler command present but robot does not act
- messenger/ZMQ/RF gateway delivery questions
- LD2 CANopen motor errors including decimal `33056` / hex `0x8120`
- mixed communication, hardware, motor-ID, and mechanical recovery faults

## Diagnostic Layers

1. UI/scheduler command.
   - Prove the command exists by exact topic, timestamp, `robot_id`, `cmd_id`, `action`, `target`, and `message_id`.
   - In `c113-0001`, scheduler sent `/robot/cmd/104` at `2026-04-28 14:05:23.466`, `action=2`, `target=1025`, `message_id=1498686573892337664`.
2. Messenger/ZMQ path.
   - C113 RF version uses ZMQ and messenger; do not assume MQTT/Wi-Fi first.
   - Search messenger logs for the scheduler `message_id`, `/robot/cmd/<id>`, and robot delivery/online state.
3. RF gateway path.
   - Check gateway online state, power, NIC/link, and RF gateway logs.
   - In `c113-0001`, gateways `10.0.64.165` and `10.0.64.166` were disconnected and recovered after cabinet/UPS power-cycle.
4. Robot online/IP state.
   - If gateway recovers but one robot still does not act, check DHCP lease, debug-module ping, robot IP mapping, and whether the device ever came online.
   - In `c113-0001`, S301 was suspected offline; a lease record alone was not proof of current online state.
5. CANopen motor path.
   - Decode emergency/error codes before classifying software state-machine failure.
   - `33056` decimal is `0x8120`; LD2 CANopen manual maps `0x8120` to `错误被动模式` / error passive mode, alarm code `902`.
   - Error passive indicates CAN bus communication errors accumulated enough for the drive to enter passive state.
6. Hardware/config/mechanical path.
   - CAN passive and SDO failures can be caused by connector damage, motor/drive fault, wrong node ID, baud mismatch, termination, cable/shield/ground issues, or adjacent node failures.
   - Field recovery can introduce new faults: wrong motor ID, unflashed firmware, over-tight belt, or damaged connector.

## Evidence Strength Matrix

| Evidence | Strength | Use it for | Do not use it for |
|---|---|---|---|
| scheduler `/robot/cmd/<id>` with exact `message_id` | strong | exclude UI/scheduler-not-sent branch | proving robot received the command |
| messenger says robot lost | medium | delivery path or robot-online branch | CAN root cause by itself |
| both RF gateways disconnected | strong | RF path outage | individual motor fault |
| gateway recovers after UPS/cabinet power-cycle | strong | power/NIC/gateway branch | proof every robot is healthy |
| debug-module ping fails for one robot | medium | offline/IP/device branch | exact hardware root cause |
| UART `si446x CRC error` | medium | RF quality/noise branch | primary root cause without delivery timing |
| `canopen_stack: failed to sdo client download` to node `0x3` | strong | CANopen device communication branch | RF gateway outage |
| LD2 `0x8120` / decimal `33056` | strong | CAN error passive mode | scheduler/UI fault |
| burnt motor/connector or blown fuse | strong | hardware branch | pure software branch |
| duplicate motor ID | strong | configuration branch | physical CAN wiring unless persistent after correction |
| over-tight belt tensioner and alarm clears after adjustment | strong | mechanical over-torque branch | CAN passive root cause for other phases |

## Pattern Library

- Command sent but no self-check on RF version:
  - prove scheduler command;
  - inspect messenger/ZMQ delivery;
  - inspect RF gateway online state;
  - only then inspect robot-side CAN/firmware.
- RF gateway outage:
  - if multiple RF gateways drop together and recover after UPS/cabinet power-cycle, treat it as communication infrastructure/power path, not robot firmware.
- LD2 `33056`:
  - convert decimal to hex: `33056 = 0x8120`;
  - manual meaning: `错误被动模式` / CAN error passive mode, alarm `902`;
  - inspect CAN_H/CAN_L, termination, shield/ground, connector, node ID, baud rate, motor power, and adjacent nodes.
- Node `0x3` enable failure:
  - `failed to sdo client download (node_id 3, index 6040, sub_index 0)` and `failed to motor enable 0x3` point to drive communication/controlword path.
- Multi-fault thread:
  - separate original fault from recovery-introduced faults; one thread may include RF outage, offline robot, burnt motor, duplicate ID, and mechanical over-torque.

## Motor Manual Lookup

- Motor manuals are company-wide, not C113-specific. Use `assets/hc-robotics/knowledge/motor-manuals.md` for the global archive.
- For this C113 case, the 雷赛/LD2 manual from that archive confirmed `0x8120` = `错误被动模式` / CAN error passive mode.

## Handling Recommendations

- Preserve command timestamp and `message_id`; it is the bridge between scheduler and messenger logs.
- Do not restart/power-cycle before recording RF gateway state if evidence is needed.
- For LD2 `0x8120`, request:
  - matching vendor manual from the motor manual archive;
  - CAN wiring photos;
  - measured resistance between CAN_H/CAN_L with power off;
  - connector continuity;
  - node ID/baud screenshots;
  - list of recently replaced motors/boards;
  - whether alarm follows the motor, cable, board, or physical position.
- After motor replacement, verify ID labels and object dictionary access before running full initialization.
- After mechanical adjustment, rerun initialization and distinguish torque alarms from CAN passive alarms.

## Specialist Routing

- `network-infra`: RF gateway disconnect, gateway NIC/power, robot ping/IP/DHCP, messenger/ZMQ delivery.
- `embedded-software`: UART logs, firmware startup, SDO failures, state transitions, RF chip errors.
- `can-bus`: LD2 emergency code decoding, CAN passive, node ID, SDO abort, bus wiring/termination.
- `robot-motion`: only after communication and motor-control layers are healthy and motion still behaves abnormally.
- `vision-media`: burnt connector, belt tensioner, motor labels, board photos, indicator lights.
