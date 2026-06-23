# Test Floor Traffic Fault Taxonomy

## Collision Chains

- `omniflow.test_floor.ap_topology_cascade_latency_collision`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: second-floor Ant traffic/collision appears after AP relocation or network topology changes; MQTT command/status latency or disconnects are visible.
  - Primary evidence: source says restoring AP topology and removing the InHand router plus cascaded TP PoE switch stopped recurrence; local assets show synchronized multi-device ping timeouts, `receive time is too long` / `leave time is too long`, delayed A3775 MQTT command status, collision photos, RCS command-status/layout warnings, and MQTT pcap traffic.
  - Primary specialists: `network-infra`, `scheduler-traffic`, `vision-media`; add `robot-motion` only after network delay is excluded.
  - Knowledge: `knowledge/ap-topology-cascade-latency-collision.md`.

- `omniflow.test_floor.ant_reboot_command_cancel_collision`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: one Ant reboots or disappears from heartbeat while a command is active; command is later `CANCELLED` with `failureReason: Rebooted`; another traffic collision follows.
  - Primary evidence: first rebooted robot, active `robotCommandLabel`, command status, UPTIME reset/log discontinuity, heartbeat disappearance, last pose/velocity, scheduler reservation state, and video if available.
  - Primary specialists: `embedded-software`, `robot-motion`, `scheduler-traffic`, `vision-media`; add `can-bus` only when CAN evidence exists.
  - Knowledge: `knowledge/ant-reboot-command-cancel-collision.md`.

- `omniflow.test_floor.dm_camera_link_loss_collision`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: one Ant loses DM/barcode localization and stops near a route node; following robots collide with the stopped robot.
  - Primary evidence: first failed robot, `DM code lost`, `DM LOST`, `FUTURE_STATE_NOT_MATCH`, `gvsp/gvcp poll timeout`, robot command labels, local `lan1` link state, MQTT disconnect/reconnect timing, route node, scheduler reservations, and video if available.
  - Primary specialists: `robot-motion`, `network-infra`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/dm-camera-link-loss-collision-chain.md`.

## Power And Battery Telemetry

- `omniflow.test_floor.boost_module_canopen_preop_battery_stale`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: Ant abnormal power-off while RMS/Kafka still reports stale normal battery, such as `batteryCharge: 58`.
  - Primary evidence: boost-module voltage/SOC collapse, robot-side `can_battery_status`, NXP log cutoff/restart markers, CANopen `0x8110`, NMT `05 -> 7F`, and PDO loss.
  - Primary specialists: `embedded-software`, `can-bus`, `network-infra`, `vision-media`.
  - Knowledge: `knowledge/boost-module-canopen-preop-battery-stale.md`.

## Evidence Status

- Treat AP/topology changes as primary evidence when recurrence disappears after topology rollback.
- Treat synchronized ping loss across many robot/device IPs as shared-infrastructure evidence; exclude hosts that were offline for the entire capture.
- Treat `receive time is too long` and delayed MQTT command status as stronger network/control-plane signals than ordinary ping.
- Treat collision order as unconfirmed until robot logs or scheduler logs identify the first stopped robot.
- Treat `CANCELLED` / `Rebooted` as command outcome evidence; reset cause still needs reset-reason, power, firmware, or CAN evidence.
- Treat monitoring video in blind spots as scene/time evidence only.
- Treat ordinary ping success as insufficient to exclude robot-local DM camera link loss.
- Treat MQTT reconnect and post-reconnect `Missing block(s)` as visibility/recovery evidence, not as proof that the original movement completed safely.
- Treat RMS battery display as unconfirmed when robot-side CAN/Wormhole/boost telemetry disagrees.
- Treat CANopen Pre-operational conclusions as node/channel-specific until pcap mapping is known.
