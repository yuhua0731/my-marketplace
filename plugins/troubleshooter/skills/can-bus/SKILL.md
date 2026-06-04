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
- For quick stop, inspect whether IO changed, how long it lasted, and whether TPDO mode could miss it.
- For target-reached events, verify whether the motor moved after the event or repeated an old target.
- For low-voltage, correlate battery/boost-module evidence with shutdown or lift failure.

## Output

- exact frame/time evidence when available
- confirmed/excluded electrical or motor branches
- unknowns caused by missing CAN logs
- next CAN evidence needed
