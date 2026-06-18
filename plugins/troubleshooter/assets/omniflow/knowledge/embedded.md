# OmniFlow Embedded Knowledge

## Use For

- firmware startup/self-check
- reboot, uptime reset, low voltage
- IO/sensor/motor/controller state
- CAN/candump/pcap evidence
- robot-side MQTT/client behavior

## Common Fault Branches

- firmware state-machine transition failure
- sensor or IO state mismatch
- CAN device heartbeat/state/fault transition
- power module or voltage instability
- logging/storage/overlay/SD-card issue
- robot-side network client disconnect

## Evidence To Request

- embedded logs around exact event time
- CAN/candump/pcap if motor/device state matters
- firmware version and config
- startup markers, uptime markers, self-check result
- sensor/IO state and recovery action

## CANopen/LD2 Notes

- `error_code` values in `node402`/CANopen events may be vendor or CANopen emergency codes passed through from the device; convert decimal to hex before lookup.
- When a motor error appears, first identify the motor vendor/model and query the motor manual archive: https://hcrobots.feishu.cn/wiki/wikcnLfdEU41gdhbyzfl8q2TEYc?from=from_copylink
- `33056` decimal is `0x8120`. In the LD2 CANopen manual, `0x8120` means `错误被动模式` / error passive mode, alarm code `902`.
- Treat `0x8120` as CAN communication quality evidence: inspect CAN_H/CAN_L, termination, shield/ground, connectors, node ID, baud rate, motor power, and adjacent nodes.
- `failed to sdo client download (node_id 3, index 6040, sub_index 0)` plus `failed to motor enable 0x3` points to the drive controlword/SDO path, not UI or scheduler.
- RF chip messages such as `si446x: CRC error` and `rf: si446x_recv() failed! ret -1` are RF quality/delivery signals; do not collapse them into CAN motor faults unless timing proves the same branch.
