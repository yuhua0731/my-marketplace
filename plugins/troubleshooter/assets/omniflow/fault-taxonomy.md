# OmniFlow Fault Taxonomy

scope: common fault taxonomy for 慧仓穿云箭 / OmniFlow projects

## Product-Line Areas

- `omniflow.scheduler`: task assignment, reservation, route lock, no-action, duplicate task, interlock/deadlock
- `omniflow.mobile_robot.motion`: localization, path deviation, angle error, collision sequence, floor-code/marker issues
- `omniflow.mobile_robot.power`: reboot, shutdown, low voltage, charging, power module, startup/self-check
- `omniflow.mobile_robot.network`: robot disconnect, MQTT/RVS/Kafka/client connection, AP coverage
- `omniflow.handling`: rack/tote handling, fork/arm/finger/actuator, PT/PD transfer, tote presence
- `omniflow.workstation`: workstation sensors, lights, WLED/HLED, operator station task state
- `omniflow.embedded`: firmware state machine, logs, IO, sensors, CAN, motor/control module state
- `omniflow.infrastructure`: server, AP, NIC, disk I/O, EFK/logging, site-wide disconnect
- `omniflow.media_physical`: video/image-observed pose, tote placement, rack interference, floor/obstacle state

## Classification Rule

Classify from observed symptom first, then use logs/video/config to confirm or exclude branches. If a case only gives a location such as WS, PT, PD, aisle, or rack area, do not treat the location as root cause.

