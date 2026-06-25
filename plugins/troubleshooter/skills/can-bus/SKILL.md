---
name: can-bus
description: Use when diagnosis involves CAN, candump, pcap, CANopen, motor heartbeat, quick stop, TPDO/IO timing, boost-module voltage/current, or device state transitions.
---

# CAN Bus Specialist

## Focus

- CANopen/device state
- motor heartbeat loss
- quick stop and operation enabled transitions
- TPDO/IO timing and missed short pulses
- boost-module voltage/current
- candump/pcap timing around fault

## Checks

- Align CAN timestamps with NXP/system logs.
- Identify exact state transition sequence.
- Separate device-reported state from upper state-machine interpretation.
- For motor PDO evidence, decode and label each plotted signal by CANopen
  object, not by anonymous channel names. Prefer EDS/DBC or captured SDO PDO
  mapping; if unavailable, mark object labels as inferred from CiA402 layout
  and data behavior.
- For motor following-error, stall, overtorque, or current-abnormal cases,
  generate a three-panel evidence chart when raw CAN data exists:
  1. position following: demand versus actual position, with units/counts;
  2. speed response: demand versus actual velocity, with raw or scaled units;
  3. load evidence: torque/current demand versus actual, with raw or scaled
     units.
- Use one shared time axis aligned to the fault window, and mark command
  creation, target write/change, first warning, and fault timestamp.
- For quick stop, inspect whether IO changed, how long it lasted, and whether TPDO mode could miss it.
- For target-reached events, verify whether the motor moved after the event or repeated an old target.
- For low-voltage, correlate battery/boost-module evidence with shutdown or lift failure.

## Output

- exact frame/time evidence when available
- PDO object mapping and chart-format evidence when raw CAN motor data exists
- confirmed/excluded electrical or motor branches
- unknowns caused by missing CAN logs
- next CAN evidence needed
