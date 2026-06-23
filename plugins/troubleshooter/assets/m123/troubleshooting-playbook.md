# M123 Troubleshooting Playbook

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
- Shutdown blocked after robot lock/manual lock: scheduler-traffic first, then embedded state-machine only if logs show command/state failure.
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Mechanical scrape, bracket contact, drag-chain sag, rail interference: vision-media first, then robot-motion/hardware evidence; embedded only if motion logs implicate control behavior.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## Dirty DM Code Causing Shuttle Home Fail

Knowledge file: `docs/m123/knowledge/dirty-dm-code-shuttle-home-fail.md`

### First Checks

- Confirmed branch: align UI alarm, robot ID, and timestamp.
  - In `m123-pt-0129`, M003R reports `SHUTTLE_HOME_FAIL` at `2026-05-09 15:17:13`.
  - The same event also reports `回原点时编码器异常`, robot `M003R`, voltage `55.02V`.
- Confirmed branch: inspect the DM/barcode image before declaring encoder hardware failure.
  - Local DM image shows the code strip around `C0002360`, `C0002400`, and `C0002440`.
  - Source analysis states the startup failure was caused by dirty DM codes.
- Confirmed branch: cleaning the barcode restored normal operation.
  - Source states `清洁条码后恢复正常`.
- Likely branch: dirty or low-contrast DM code causes localization/homing decode failure, which surfaces as `SHUTTLE_HOME_FAIL` or encoder abnormality.
- Related branch: dense-center offset or camera geometry can cause similar alarm text, but that requires center-line/config evidence. Do not merge this contamination case with offset cases.

### Evidence

- Raw robot/NXP logs around the alarm timestamp.
- DM camera decode debug output before cleaning, including confidence, decode result, and any `SCAN OUT OF AREA` or read failure.
- Before/after DM code photos under the same lighting/camera exposure.
- Repeated startup/homing retest after cleaning.
- Maintenance record identifying contamination type, cleaning method, and whether more DM strips are affected.

### Exclusions

- Do not route to M004 `dense_center_offset` solely from `SHUTTLE_HOME_FAIL` or `回原点时编码器异常`.
- Do not replace encoder or motor before checking DM code cleanliness and decode images.
- Do not treat normal-looking UI voltage as proof of power health beyond this event; it only makes low-voltage root cause less likely here.
- Do not close a repeat issue without post-clean repeated homing/startup retest.

### Examples

- `m123-pt-0129`: M003R failed startup at `2026-05-09 15:17:13` with `SHUTTLE_HOME_FAIL` and `回原点时编码器异常`; UI showed `55.02V`. The source says inspection found dirty DM codes, and cleaning the barcode restored normal operation. Local DM image shows nearby code labels `C0002360`, `C0002400`, and `C0002440`.

- `m123-pt-0129`: no raw robot log, no decode confidence frame, no post-clean image, and no repeated retest count are local.

## Feeder Light Curtain Length Undermeasure Stop Outside

Knowledge file: `docs/m123/knowledge/feeder-light-curtain-length-undermeasure-stop-outside.md`

### First Checks

1. Confirm the physical stop-position symptom before changing scheduler or shuttle logic.
   - In `m123-pt-0031`, local image `001-image-dbd465b94af6.jpg` shows a soft, wrinkled package stopped near/outside the station light curtain / outlet area.
2. Compare source-estimated physical length with package-tracking length.
   - Source text says the actual package was around `30cm`.
   - Local raw log shows `pack_num: 20` measured as `0.186613`, then `pack_id: 20` passed sensor 2 as `0.168598` and sensor 1 as `0.202229`.
3. Inspect trigger quality before blaming downstream station state.
   - The same package sequence contains `abnormal trigger, sensor_id: 3, pkt len: 0.000000`.
   - The sequence also contains `light on scan_trigger_on() failed`.
4. Treat package shape and light-curtain geometry as a likely branch.
   - Soft or wrinkled bags can shorten effective beam-blocking duration, split the trigger, or let edges pass inconsistently.
   - Sensor alignment, debounce/filtering, speed estimate, and sampling cadence can amplify this into a short measured length.
5. Check whether the undermeasured length feeds stop-distance or loading-time logic.
   - If the controller calculates stop position from a short length, the physical package can stop outside the intended light-curtain boundary.
6. Mark final root cause as blocked when the stop-time window, IO waveform, or reproduction is missing.
   - In `m123-pt-0031`, the local `sort_conveyor.log` jumps from `17:29:59.071087` to `17:40:14.029448`, so it does not contain the source-reported `17:30:35` stop moment.

### Evidence

- Case body and source screenshot showing physical stop position.
- Raw `sort_conveyor.log` lines for the same package number across sensors 3/2/1/0.
- Exact stop-time log window covering the moment the package stopped outside the light curtain.
- Light-curtain IO waveform or sampled state transitions for each sensor.
- Conveyor speed, length-calculation parameters, debounce/filter config, and sensor alignment/calibration.
- Representative video frames showing package shape and the moment it crosses each light curtain.
- Reproduction with the same package and at least one control package of known length.

### Exclusions

- Do not diagnose shuttle dispatch or stale opposite-site state unless logs show parcel already on a shuttle or station reservation/dispatch loop.
- Do not diagnose MOXA, MQTT, or robot network faults without robot disconnect, broker discovery, or ping evidence.
- Do not diagnose CAN/power-cycle recovery from later heartbeat/PDO errors outside the package stop window.
- Do not call the light curtain hardware failed from one screenshot; require repeated package-specific trigger evidence, IO waveform, or swap/calibration proof.
- Do not claim root cause from source annotations alone; match the screenshot values with raw log lines when available.

### Examples

- `m123-pt-0031`: source reports a `~30cm` package stopped outside the light curtain. Local raw log for `pack_num: 20` shows `0.186613`, then sensor 2 `0.168598`, sensor 1 `0.202229`, plus `abnormal trigger, sensor_id: 3` and `light on scan_trigger_on() failed`. Local image/video evidence shows a soft wrinkled package in the station feeder/lift area.

- `m123-pt-0031`: final mechanism is evidence-limited because the exact `17:30:35` stop-time log window, sensor IO waveform, sensor config, conveyor speed/config, and repeated reproduction result are not local.

## M123 Forced Discharge Fails When Idle Robot Is Waiting At Mini Pro Standby Point

Knowledge file: `docs/m123/knowledge/forced-discharge-idle-waiting-point-robot-dispatch.md`

### First Checks

1. Confirm the feeder abnormal and forced-discharge failure state.
   - In `m123-pt-0017`, the UI screenshot timestamp is `2026-03-18 09:52:34`.
   - The visible toast says `恢复感应输送机失败，等待空闲机器人前来处理`.
   - The exception popup says `供包机包裹超长`, with handling instruction to remove all feeder parcels before recovery.
2. Check helper-robot selection and station reachability.
   - Source analysis says Mini Pro added a waiting point / `等待位`.
   - When a second-layer robot waits at that waiting point, the previous logic for "robot not at station, ask another station robot to assist forced discharge" did not respond.
3. Separate waiting-point state from "no idle robot exists".
   - The UI message asks for an idle robot, but the source says the issue is not absence of robot; it is that the logic did not cover robots waiting at the new Mini Pro standby point.
4. Verify dispatch after code change.
   - Source resolution adds handling logic for a robot at the standby/waiting point so it can go to the station and assist forced discharge when feeder failure occurs.

### Evidence

- RCS/scheduler logs around `2026-03-18 09:52:33` to `09:52:34`, including station ID, robot candidates, waiting-point state, and task creation.
- Feeder/conveyor logs for the `供包机包裹超长` abnormal and forced-discharge recovery attempt.
- Robot state table showing whether `B0-8` or another second-layer robot was idle/waiting, at station, or locked.
- Before/after code or config change that adds waiting-point handling.
- Post-fix forced-discharge retest with a robot starting from the waiting point.

### Exclusions

- Do not diagnose the feeder motor, CAN node, or homing hardware from `供包机不回原点` until helper-robot dispatch and forced-discharge task creation are checked.
- Do not merge with package length undermeasurement unless logs show the package overlength detection itself is false; here the reusable bug is recovery helper dispatch after the abnormal.
- Do not call it no-idle-robot condition until waiting-point robots and station-assist candidates have been enumerated.
- Do not close from UI screenshots alone; scheduler/RCS logs or post-fix retest should prove the waiting-point branch.

### Examples

- `m123-pt-0017`: Mini Pro no-scan feeding hit feeder overlength, forced discharge failed, UI reported `恢复感应输送机失败，等待空闲机器人前来处理`, and the feeder did not return to origin. Source analysis says Mini Pro added a waiting point; when a second-layer robot was waiting there, older helper-dispatch logic did not respond. The fix added handling for robots at standby/waiting points so they go to the station to assist forced discharge.

- `m123-pt-0017`: local assets do not include RCS/scheduler logs, feeder/conveyor logs, exact station ID, raw robot state table, code diff, or post-fix retest proof.

## MOXA Switch Robot Link Loss

Knowledge file: `docs/m123/knowledge/moxa-switch-robot-link-loss.md`

### First Checks

- Confirmed branch: the failure is strongly correlated with the MOXA path, not the whole M123 network.
  - In `m123-pt-0149`, a newly added MOXA switch preceded robot `J42A67MN` stopping at `2026-06-10 02:13:57` with `END CMD TIMEOUT ERROR`.
  - After swapping `J42A67MN` and `KO2A11MN` positions and moving the cable back to the original TP-LINK switch, the site ran continuously for 48 hours without robot disconnect.
  - On `2026-06-16 11:16`, MOXA `qos` and `bsp` were disabled and the robot cable was moved back to MOXA; the issue reproduced at `2026-06-16 15:30:13`.
- Confirmed branch: compare a robot-path ping with a same-server control endpoint before blaming the server or global LAN.
  - Source analysis deployed a test PC `10.0.64.123` and monitored server `10.0.64.108` to PC `123` plus server `108` to lost robot `103`.
  - Screenshot OCR shows `2026-06-16 22:05:15` onward, `From 10.0.64.108 ... Destination Host Unreachable` for the robot path.
  - The same screenshot shows `64 bytes from 10.0.64.123` around `22:05:00` to `22:05:06`.
  - Another screenshot shows robot-path `Destination Host Unreachable` still present around `2026-06-17 08:30`, while PC `10.0.64.123` replies with `ttl=128`.
- Likely branch: MOXA port, VLAN, loop/guard, QoS/BSP side effect, negotiation, cable/port, or robot-side wormhole link state caused a per-robot/per-port outage.
- Blocked branch: exact root cause is not frame-level confirmed because the local evidence lacks switch config, port counters, MOXA event logs, packet captures, and robot/wormhole logs.

### Evidence

- Raw `/var/log/ping-monitor/*.log` text for `10.0.64.103` and `10.0.64.123` around `2026-06-16 22:05` through `2026-06-17 08:30`.
- MOXA switch model, firmware, running configuration, VLAN/QoS/BSP/loop-protection/STP settings, and per-port counters for the robot port.
- Physical port mapping for robot `J42A67MN`, robot/endpoint `103`, labels `M13` / `M15`, original TP-LINK port, and the test PC.
- Robot `103` / wormhole logs around first unreachable time, including link up/down, IP address, DHCP/static config, ARP table, and reset history.
- Ping/ARP/traceroute from both directions: server to robot, robot to server, server to PC, PC to server, and if possible PC to robot on the same switch segment.

### Exclusions

- Do not call this a server `108` outage if `108 -> 10.0.64.123` remains stable while `108 -> 10.0.64.103` is unreachable.
- Do not call this a whole-site network outage if only the robot path fails and the test PC path is normal.
- Do not treat disabling MOXA `qos` and `bsp` as a fix when the issue reproduces after disabling them.
- Do not close as generic robot fault until the same robot/port/cable comparison across MOXA and TP-LINK is recorded.
- Do not infer MOXA root cause from topology correlation alone; require switch config/logs/counters or packet evidence for final root cause.

### Examples

- `m123-pt-0149`: M123 added a MOXA switch. Robot `J42A67MN` stopped at `2026-06-10 02:13:57` with `END CMD TIMEOUT ERROR`, ping failed, and wormhole disconnected. After moving the network cable back to the original TP-LINK switch, 48 hours of weekend running had no robot disconnect. Moving back to MOXA after disabling `qos` and `bsp` reproduced the issue; long ping from `10.0.64.108` to robot `103` became `Destination Host Unreachable` from about `2026-06-16 22:05` through `2026-06-17 08:30`, while `10.0.64.123` test PC stayed reachable.

- `m123-pt-0149`: exact MOXA-side mechanism remains unresolved because only screenshots of ping output are local; raw logs, switch configuration, per-port counters, and robot/wormhole logs are missing.

## MQTT Broker Inflight Robot Discovery

Knowledge file: `docs/m123/knowledge/mqtt-broker-inflight-robot-discovery.md`

### First Checks

- Confirmed branch: separate IP reachability from application discovery.
  - In `m123-pt-0136`, source text says two robots cannot be found by the M123 mini-pro system, while all wormhole IP addresses can be entered/viewed in `DHCCP_SERVER`.
  - This excludes a simple "all robot network unreachable" explanation and moves the next checks to MQTT broker registration, retained/session state, and central-control discovery flow.
- Confirmed branch: the source resolution is broker-side flow control.
  - Source text states: `将调整mosquitoo max_inflight_messages 为300 重启mqtt的broker后恢复`.
  - Preserve the source typo `mosquitoo`, but treat the component as `mosquitto` / MQTT broker unless local config proves another broker.
- Confirmed branch: UI alarm list aligns with startup/reset symptoms, not with per-robot ping failure.
  - Local screenshot shows repeated entries from `2026-05-11 16:57:51` to `18:52:14`.
  - The visible abnormal text is `解除急停后启动，该问题发生。请检查机器人电源状态`; multiple handling rows show `RESET SYSTEM`.
- Likely branch: the default or previous MQTT `max_inflight_messages` setting constrained unacknowledged QoS messages during multi-robot registration/startup, causing robot discovery or state propagation failure.
- Blocked branch: exact broker mechanism is not frame-level confirmed because local evidence lacks broker config, broker logs, MQTT client IDs/topics, and before/after message metrics.

### Evidence

- Mosquitto configuration before/after changing `max_inflight_messages` to `300`.
- Broker restart log, service name, version, and timestamp matching recovery.
- MQTT broker logs around robot add/startup: client connect/disconnect, inflight queue, dropped messages, retained/session state, subscriptions, and QoS.
- Central-control discovery logs for the two missing robots: robot IDs, MAC/IP, client ID, topics, and state transition.
- DHCP/wormhole evidence proving the missing robots' IPs were reachable before broker restart.
- Before/after screenshot or API output showing the two robots reappeared after broker change.

### Exclusions

- Do not diagnose robot IP/network unreachable solely from "中控搜索不到机器人" if DHCP/wormhole IP access works.
- Do not treat repeated `RESET SYSTEM` as the root cause; it is an operational recovery action or alarm handling symptom unless logs prove reboot causality.
- Do not route to station dispatch/load-stall knowledge from `M123` alone; require station, parcel, `oppositeShuttle`, or dispatch-loop evidence.
- Do not claim `max_inflight_messages=300` as universally correct; record robot count, QoS, broker version, and message rate before turning it into a default.
- Do not close the case without broker logs or before/after discovery proof when the issue recurs.

### Examples

- `m123-pt-0136`: M123 mini-pro system could not find two robots; `DHCCP_SERVER` showed wormhole IPs were enterable. After adjusting `mosquitoo` / mosquitto `max_inflight_messages` to `300` and restarting the MQTT broker, the source says the system recovered. The local screenshot shows repeated startup/reset alarms on `2026-05-11`, including `解除急停后启动，该问题发生。请检查机器人电源状态` and `RESET SYSTEM`.

- `m123-pt-0136`: remains evidence-limited because local assets do not include MQTT config/logs, central-control discovery logs, missing robot IDs, or before/after robot list.

## Server Status Bit Power-cycle Conveyor Reinit

Knowledge file: `docs/m123/knowledge/server-status-bit-power-cycle-conveyor-reinit.md`

### First Checks

1. Reconstruct the power-cycle timeline before treating the feeder as a standalone motor failure.
   - In `m123-pt-0141`, source text records door-lock drive-power cut at `13:04:19`, successful restart at `13:21:10`, both feeders not homing, station 2 motor error recoverable, and station 1 CAN heartbeat loss not recoverable until `9352` restart.
   - Local log `assets/m123-pt-0141/retry-source-EcmKbfXCyoJe3dxThICcP1pHnUe.log` shows multiple node heartbeat timeouts around `2026-06-05T13:04:26` to `13:04:29`, then `PDO disable failed` and `sys shutdown enter disable state` at `13:05:07`.
2. Check whether central control sent the server power-state transition.
   - Protocol screenshot `retry-image-004-VnDnbZ6KcomnEfxuExacwpbwnvh.png` defines `server status bit1` as power state: `0: 紧急停止`, `1: 良好`.
   - Source analysis states that during drive-power loss, central control did not set `server status bit1` to `0`, so the feeder could not detect the power-state change and reinitialize peripherals.
3. Separate expected power-cut CAN fallout from the recovery blocker.
   - Heartbeat timeouts during the power-loss window can be a consequence of drive-power cut.
   - A persistent unrecoverable `供包机CAN节点心跳丢失` after restart points to stale recovery state or missing reinitialization, not necessarily a broken CAN device.
4. Compare recoverable motor error versus non-recoverable heartbeat loss.
   - UI screenshot `retry-image-002-YQspbLHPGoR17bxqQ84cydaCn2b.jpg` shows `2026-06-05 13:21:10` errors: `供包机电机错误` and `供包机CAN节点心跳丢失`.
   - Source text says station 2 recovered after motor-error recovery, while station 1 heartbeat loss could not recover until `9352` restart.
5. Validate recovery by service restart and subsequent homing.
   - Local log shows `sys running enter enable state` at `2026-06-05T13:21:11`, `homing complete, target reached`, `position origin reached`, then one `SDO response error` / `can_bus_SDO_write()` at `13:21:12`.
   - Screenshot `retry-image-001-JwwVbtBiboOPyjxunsxciEDunLc.jpg` shows the upper system at `13:21:10` entering running, detecting `M123-SITE-1-CONVEYOR: receive-conveyor-error: CONVEYOR_EVENT_0X0F`, `DOOR-B open`, and clearing site package caches.

### Evidence

- Raw central-control or sort-conveyor lines proving the actual `server status bit1` value before, during, and after the power cut.
- Exact command/process identity for `9352` and its restart log.
- CAN heartbeat or candump trace showing whether nodes resumed after `9352` restart.
- Confirmation that station 1 and station 2 run the same feeder firmware/config before comparing recovery behavior.

### Exclusions

- Do not diagnose a damaged motor or CAN board only from heartbeat loss during the power-cut window.
- Do not treat station 2's recoverable motor error as identical to station 1's unrecoverable heartbeat loss; compare post-recovery behavior.
- Do not claim bit1 root cause as frame-level confirmed unless raw status-write logs or protocol frames are available.
- Do not route this to C134/Mantis power knowledge from the word `重启`; this is an OmniSort M123 feeder/conveyor power-state reinit case.

### Examples

- `m123-pt-0141`: source timeline and screenshots show door-lock drive-power interruption, restart at `13:21:10`, feeder motor error plus CAN heartbeat loss, and recovery only after `9352` restart. Local log confirms 13:04 heartbeat timeouts, 13:05 shutdown-disable transition, and 13:21 homing/re-enable activity.

- `m123-pt-0141`: raw `server status bit1` write/read logs and `9352` restart logs are missing, so the bit1 mechanism is source-analysis-supported but not frame-level confirmed locally.

## Shuttle Load Stall And Dispatch Loop

Knowledge file: `docs/m123/knowledge/shuttle-load-stall-dispatch-loop.md`

### First Checks

- Confirmed branch: station/dispatch state must be reconstructed before blaming the robot.
  - In `m123-pt-0142`, visible image shows `11MN` with parcel at the station and `17MN` adjacent.
  - UI screenshot shows `K02A11MN` highlighted and multiple station cells in stalled states.
  - Downloaded logs contain repeated `send go to target command。target trackName：HT0，target offset: 3.023` lines and repeated references to `K02A11MN` as the opposite shuttle.
- Likely branch: service-side dispatch loop or stale opposite-site occupancy.
  - Logs around `2026-06-12T09:18:47+0800` show `K02A17MN` lifecycle from load to leave, while `oppositeShuttle: K02A11MN` stays in status `133`.
  - Repeated commands alone are not proof of robot motion failure; first inspect dispatch reservation, opposite-site state, and site parcel ownership.
- Possible branch: scanner/network side effect blocks site state cleanup.
  - The same log stream repeatedly reports `M123-SITE-1 rollerScan: Error: connect EHOSTUNREACH 10.0.64.171:9004`.
- Blocked branch: source/log time mismatch.
  - Case text says the event was around `16:30:35`, while the downloaded gzip log excerpt is around `09:18`. Treat the log as evidence for a similar failure window until the exact matching log is confirmed.

### Evidence

- Exact matching log window for the reported `16:30:35` symptom.
- Robot IDs for the physical stalled parcel: `K02A11MN` versus `K02A17MN`.
- Station state for both sides: `M123-SITE-1`, `M123-SITE-2`, `dispatchShuttleInfo`, `oppositeShuttle`, `parcelUuid`, and current floor.
- Scanner / rollerScan reachability and whether scan failure blocks mission creation or site cleanup.

### Exclusions

- Do not call it a motor or drive fault if logs show successful `set target` / `leave site` for the robot under inspection.
- Do not treat repeated `send go to target` as root cause; classify it as a symptom until reservation and site state explain why commands repeat.
- Do not merge `11MN` and `17MN` evidence: physical image, UI state, and logs may refer to different robots in the same station pair.

### Examples

- None. `m123-pt-0142` remains `needs-assets` because the exact reported time window is not yet aligned with the downloaded log.

- `m123-pt-0142`: 11MN physically carried a parcel and did not leave the station; available logs show repeated dispatch commands and scanner reachability errors, but exact root cause is not confirmed.
