# M123 Fault Taxonomy

## DM Code And Homing

- `omnisort.m123.dirty_dm_code_shuttle_home_fail`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M123/MiniSort Pro startup fails with `SHUTTLE_HOME_FAIL` and/or `回原点时编码器异常`; robot voltage can be normal.
  - Primary evidence: UI alarm timestamp/robot ID, physical robot location, DM camera image, source-confirmed dirty DM code, and recovery after cleaning the barcode.
  - Primary specialists: `vision-media`, `robot-motion`, `embedded-software`.
  - Knowledge: `knowledge/dirty-dm-code-shuttle-home-fail.md`.

## Power-cycle And Conveyor Reinit

- `omnisort.m123.server_status_bit_power_cycle_conveyor_reinit`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: after drive-power or door-lock power interruption and restart, feeder/conveyor does not home; UI reports feeder motor error and CAN heartbeat loss.
  - Primary evidence: power-cycle timeline, `server status bit1` protocol definition, feeder/conveyor logs around shutdown and re-enable, UI error list, CAN heartbeat and SDO/PDO errors.
  - Primary specialists: `embedded-software`, `can-bus`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/server-status-bit-power-cycle-conveyor-reinit.md`.

## Feeder Light Curtain Length Measurement

- `omnisort.m123.feeder_light_curtain_length_undermeasure_stop_outside`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M123 feeder/loading module stops a package outside the light curtain or outlet boundary while package-tracking length is much shorter than the physical package.
  - Primary evidence: physical stop-position image/video, source-estimated package length, raw `sort_conveyor` lines for `validation new package`, `package passed sensor_id`, `pkt len`, `abnormal trigger`, and `scan_trigger_on/off` near the same `pack_num` / `pack_id`.
  - Primary specialists: `embedded-software`, `vision-media`, `can-bus`, `scheduler-traffic`.
  - Knowledge: `knowledge/feeder-light-curtain-length-undermeasure-stop-outside.md`.

## Station Dispatch And Load State

- `omnisort.shuttle_load_stall`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: shuttle has parcel after loading but does not leave station, or UI shows stale station/opposite-shuttle involvement.
  - Primary evidence: station UI, `oppositeShuttle`, `dispatchShuttleInfo`, repeated go-to-target commands, scanner reachability.
  - Primary specialists: `scheduler-traffic`, `network-infra`, `vision-media`.
  - Knowledge: `knowledge/shuttle-load-stall-dispatch-loop.md`.

- `omnisort.m123.forced_discharge_idle_waiting_point_robot_dispatch`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M123/Mini Pro feeder abnormal recovery / forced discharge fails with `恢复感应输送机失败，等待空闲机器人前来处理` while a robot is idle at a Mini Pro waiting/standby point.
  - Primary evidence: UI overlength/forced-discharge failure, robot layout showing waiting-point robot such as `B0-8`, scheduler/RCS helper-candidate selection, and source fix adding waiting-point handling.
  - Primary specialists: `scheduler-traffic`, `vision-media`, `embedded-software`.
  - Knowledge: `knowledge/forced-discharge-idle-waiting-point-robot-dispatch.md`.

## MOXA Switch Robot Link Loss

- `omnisort.m123.moxa_switch_robot_link_loss`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: robot disconnects or reports `END CMD TIMEOUT ERROR` after being connected through a newly added MOXA switch; server ping to robot returns `Destination Host Unreachable` while a same-server test PC ping remains normal.
  - Primary evidence: before/after topology comparison between MOXA and original TP-LINK, server-to-robot and server-to-PC long-ping logs, physical port mapping, switch config/logs/counters, and robot/wormhole link logs.
  - Primary specialists: `network-infra`, `embedded-software`, `vision-media`, `scheduler-traffic`.
  - Knowledge: `knowledge/moxa-switch-robot-link-loss.md`.

## MQTT Broker Robot Discovery

- `omnisort.m123.mqtt_broker_inflight_robot_discovery`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: M123 central control cannot find/search some robots although wormhole IPs are reachable in DHCP/DHCCP server context; startup alarms may show `解除急停后启动，该问题发生。请检查机器人电源状态`.
  - Primary evidence: robot IP/DHCP reachability, central-control discovery logs, MQTT broker config/logs, `max_inflight_messages` before/after, and recovery after broker restart.
  - Primary specialists: `network-infra`, `embedded-software`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/mqtt-broker-inflight-robot-discovery.md`.

## Evidence Status

- For M123 startup/homing failure with DM-related alarm text, inspect barcode cleanliness and camera decode image before replacing encoder/motor hardware.
- Treat power-cut heartbeat loss as expected consequence until it persists after power-state transition and reinitialization.
- Treat `server status bit1` explanations as source analysis unless raw status-write logs or frames are available.
- Treat short feeder length measurements as evidence for a measurement/trigger-quality branch only after matching source annotations with raw `sort_conveyor` lines.
- Do not close light-curtain stop-position cases without exact stop-time logs, sensor IO waveform/config, or repeated reproduction when final root cause is requested.
- Treat MOXA-vs-TP-LINK topology correlation as strong diagnostic evidence, but require switch config/logs/counters or packet capture before claiming the exact switch-side mechanism.
- Treat `max_inflight_messages=300` as source-proven recovery for `m123-pt-0136`, not a universal broker default without robot-count and MQTT traffic evidence.
- Treat generic words such as `重启`, `报错`, `异常`, or `CAN` as insufficient for cross-corpus routing.
- For Mini Pro forced-discharge failures, distinguish "no idle robot exists" from "idle robot exists at the new waiting/standby point but is not selected by helper-dispatch logic".
