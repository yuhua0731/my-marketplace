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

