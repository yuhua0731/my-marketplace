# Test Floor Traffic Troubleshooting Playbook

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

## Ant Reboot Command Cancel Collision Chain

Knowledge file: `docs/test-floor-traffic/knowledge/ant-reboot-command-cancel-collision.md`

### First Checks

- Confirmed branch: A3766 rebooted or lost runtime continuity while a command was in progress.
  - Screenshot evidence shows command `A3766-S65084-2026-05-06T08:54:29.458Z-command-label-10` is `CANCELLED` at local `2026/5/6 17:30:29`, with `failureReason: Rebooted`.
  - Screenshot evidence shows command-label-9 was `PROCESSING` at local `2026/5/6 16:55:52`.
  - NXP log jumps from `2026-05-06T08:55:21Z` with `UPTIME:13523` to `2026-05-06T09:17:06Z` with `UPTIME:53`, which supports a reboot/log discontinuity.
- Confirmed branch: the active motion command before the log gap was still executing.
  - At `2026-05-06T08:55:19Z`, A3766 receives `robotCommandLabel: A3766-S65084-2026-05-06T08:54:29.458Z-command-label-3`, `robotCommandType: MOVE`.
  - Command target is `coordX: 102000`, `coordY: 108000`, with `maxVelocity: 2000`, `maxAcceleration: 400`, and `obstacleAvoidance: false`.
  - At `2026-05-06T08:55:21Z`, the robot is still moving: `estimation_state` has `v: 677.393799`, and current reference is near `y: 106578`.
- Likely branch: the collision is a consequence of robot disappearance/reboot during traffic execution, not a primary DM localization failure.
  - This case has no captured `DM LOST`, `FUTURE_STATE_NOT_MATCH`, `Link is Down`, or `Link is Up` evidence in the available A3766 log.
- Secondary branch: scheduler/traffic handling after robot heartbeat loss must be checked.
  - If a moving robot reboots or disappears, traffic should retain or protect its last known occupied segment until physical state is confirmed.
  - The visible case does not include scheduler reservation logs, so whether another robot was allowed into the conflict area remains unverified.
- Blocked branch: reboot root cause.
  - Available evidence proves reboot/discontinuity, but not whether it was caused by power, firmware, CAN, watchdog, operator action, network, or collision impact.

### Evidence

- RCS/RMS/SAS scheduler logs around local `2026-05-06 16:55:52` to `16:56:44`, including reservation state, heartbeat timeout handling, and route release.
- Robot heartbeat history for A3766 showing the last heartbeat at local `16:55:52` and reconnection after reboot.
- NXP logs immediately before reset, including boot banner, reset reason, watchdog, hard fault, brownout, CAN fault, and power telemetry.
- CAN candump/pcap around the same window if CAN/power/motor state is suspected.
- Full video frames covering local `16:55:52` to `16:56:44` and the physical collision point.
- Any operator intervention, emergency stop, battery/boost, or hardware inspection notes after the collision.

### Exclusions

- Do not classify as DM camera/link-loss collision unless `DM LOST`, `FUTURE_STATE_NOT_MATCH`, GVSP/GVCP, or `lan1` link-flap evidence appears before the collision.
- Do not classify as pure scheduler fault while A3766 reboot/discontinuity is the strongest available initiating evidence.
- Do not classify as CAN root cause from `system_area: CAN` alone; require CAN frames, CANopen errors, motor heartbeat loss, or reset/power evidence.
- Do not use `CANCELLED / Rebooted` alone to prove why the robot rebooted; it proves command outcome after reboot.
- Do not use the QuickLook video thumbnail to prove collision order; it only confirms scene/time context.

### Examples

- `test-floor-traffic-pt-0108`: A3766 active command sequence `A3766-S65084-2026-05-06T08:54:29.458Z` was in progress near local `16:55:52`; source reports collision at `16:56:44`; screenshots later show command cancellation with `failureReason: Rebooted`; log continuity drops from `UPTIME:13523` at `08:55:21Z` to `UPTIME:53` at `09:17:06Z`.

- `test-floor-traffic-pt-0108`: reboot root cause and scheduler collision-prevention behavior remain unresolved because reset reason, CAN/power evidence, scheduler reservation logs, and full decoded collision video are missing.

## AP Topology Cascade Latency Collision

Knowledge file: `docs/test-floor-traffic/knowledge/ap-topology-cascade-latency-collision.md`

### First Checks

1. Start with topology change.
   - Preserve the exact before/after AP, router, PoE switch, server, and robot subnet paths.
   - If the issue appears after AP relocation or electrical-cabinet network changes, do not start from single-robot hardware.
2. Quantify MQTT/control-plane latency.
   - Compare command status publish times, command set creation, and robot state freshness.
   - Look for `receive time is too long`, delayed `robot/command/status/*`, and stale `robot/state/*`.
   - If ping logs exist, group `timed out` windows by second across robot IPs; synchronized multi-device windows are stronger shared-infrastructure evidence than single-host loss.
3. Inspect cascaded network devices.
   - Extra router/NAT or cascaded PoE switch can add asymmetric routing, buffering, broadcast isolation, or unstable AP uplink behavior.
   - Check whether MQTT broker paths cross multiple subnets such as robot `10.0.64.x`, server `192.168.2.x`, and container `172.24.x.x`.
   - Repeating two-pulse outages, such as a 5-6 second disconnect followed shortly by a 7-8 second disconnect once per hour, should trigger checks for router/switch/AP scheduled jobs, STP/loop reconvergence, ARP/DHCP behavior, watchdogs, or uplink resets.
4. Check scheduler collision protection as the second layer.
   - Delayed robot state can make scheduler reservations stale.
   - Verify whether route/occupancy protection holds segments when robot state is late or disconnected.
5. Validate by rollback/simplification.
   - Restore known-good AP topology, remove added router/switch cascade, and rerun the same multi-robot traffic.
   - Closure requires no recurrence plus latency/disconnect counters returning to normal.

### Evidence

- Before/after network topology diagram, including AP uplink, InHand router, TP PoE switch, broker/server, and robot subnet.
- AP controller logs: client roaming, RSSI, retries, disconnect reason, channel utilization.
- Switch/router logs: port flaps, loops, NAT/firewall, DHCP, ARP, packet drops, queue/buffer stats.
- Pcap decoded by robot ID/topic, including publish-to-consume latency for `robot/state`, `robot/command/status`, and `robot/commandSet/create`.
- Scheduler reservation/route logs around collision.
- Physical collision photos/video and exact robot IDs involved.

### Exclusions

- Do not blame DM camera/link loss unless robot-local DM/GVSP/GVCP/link-flap evidence exists before collision.
- Do not blame reboot unless UPTIME reset, reset reason, or heartbeat disappearance proves it.
- Do not blame a single Ant if many robot topics show latency or network topology rollback removes recurrence.
- Do not blame a single Ant if multiple robot/device IPs time out in the same seconds.
- Do not include hosts that are unreachable for the whole capture as evidence of synchronized outage.
- Do not treat physical collision photos as proof of initiating order.
- Do not call the network fix proven by topology change alone; verify latency/disconnect counters and repeat traffic.

### Examples

- `test-floor-traffic-pt-0059`: second-floor dispatch test environment collision case. Source says after `2026-03-23 14:28`, topology was restored to match the state before AP relocation, and the InHand router plus cascaded TP PoE switch were removed; disconnection had not recurred. Local assets include collision/blocked-scene photos, Wireshark screenshots where A3775 command status goes from `PROCESSING` at `18:01:32.599666` to `COMPLETE_SUCCESS` at `18:01:48.727407`, terminal `receive time is too long` warnings, RCS logs with repeated A2036/A4883 layout warnings, and a pcap carrying MQTT robot state/command traffic.

- `test-floor-traffic-pt-0006`: second-floor dispatch test collision involving `A3767`, `A3775`, and `A2048`. Source says after `2026-03-23 14:28`, topology was restored to the pre-AP-move state and the InHand router plus cascaded TP PoE switch were removed; no disconnection had appeared at source time. Local ping logs show five devices (`10.0.64.126`, `.127`, `.134`, `.135`, `.145`) all timed out in eight synchronized groups: `10:22:04/21`, `11:22:49/23:06`, `12:23:34/23:51`, and `13:24:19/24:36`, with roughly 6-second then 8-second outages. `10.0.64.136` was excluded because it was unreachable from the beginning. The `processing_logic` screenshot shows `A3775` and `A3767` command `leave time is too long` warnings around the same event family.

- `test-floor-traffic-pt-0059`: exact topology diagram, AP/switch/router logs, per-robot pcap latency statistics, and scheduler reservation logs are not local; collision order remains unproven from photos alone.
- `test-floor-traffic-pt-0006`: exact topology diagram, AP/router/switch logs, DHCP/ARP/STP/link counters, robot logs, scheduler reservation logs, and post-rollback monitoring logs are not local; ping logs prove shared outage timing but not which infrastructure device caused it.

## Boost Module Protection With CANopen Pre-op And Stale Battery

Knowledge file: `docs/test-floor-traffic/knowledge/boost-module-canopen-preop-battery-stale.md`

### First Checks

1. Start with the power symptom, not the displayed RMS battery value.
   - If RMS shows normal battery but robot-side CAN, Wormhole, or boost telemetry shows low voltage/SOC collapse, treat the RMS value as suspect.
   - If all robot-side battery sources agree with RMS, look for true sudden load, battery-pack, BMS, or boost-module protection instead of stale communication.
2. Separate real low-voltage protection from telemetry loss.
   - Low cell/pack voltage or boost-module protection can explain the actual shutdown.
   - CANopen Pre-operational can explain why PDO battery data stops refreshing and RMS keeps a stale value.
3. Check NMT state and EMCY/code-analysis evidence.
   - `CO_CANsend()` send buffer full maps to `CO_CAN_ERRTX_OVERFLOW`.
   - `CO_EM_process()` can set `CO_EM_CAN_TX_OVERFLOW` and `CO_EMC_CAN_OVERRUN`.
   - `CO_EMC_CAN_OVERRUN = 0x8110`.
   - With `NMT_CONTROL = 0x2011`, a communication error bit can move NMT from `05` Operational to `7F` Pre-operational.
   - In `7F`, NMT/SDO/Heartbeat/EMCY can still exist, but PDO does not run, so battery PDO may be stale or missing.
4. Check CAN channel and node identity before concluding.
   - One capture can show a heartbeat such as `0x750=7f` while another channel or node still shows `05`.
   - Do not collapse different CAN loops into one state without node/channel mapping.
5. Treat log cutoff as evidence gap, not proof.
   - If NXP/Wormhole logs end before the reported power-off time, they support abnormal termination only as a gap or cutoff, not as a complete final shutdown sequence.

### Evidence

- RMS/Kafka heartbeat near the event, including `batteryCharge`, `connectionStatus`, `mainState`, and `errors`.
- Robot-side battery source: `can_battery_status`, battery PDO, BMS, or boost-module telemetry.
- CAN pcap/candump for the relevant battery/boost loop with timestamps around the transition.
- NXP log around the event and restart, including UPTIME markers.
- Boost-module voltage/current/SOC chart or raw telemetry.
- Video frames around the event if physical power-off, collision, charging-pile entry/exit, or operator action matters.
- Battery/boost-module protection threshold/config when available.

### Exclusions

- If the relevant node remains `05` Operational and battery PDO continues updating through the event, do not use CANopen Pre-operational as the stale-battery explanation.
- If RMS battery matches robot-side battery and the robot still powers off, investigate true power path, battery pack, BMS, boost module, and load transient.
- If logs do not include the final minute, do not claim the exact shutdown order.
- If video only shows the test floor and robots with lights on, use it as scene/time context, not proof of electrical power-off.

### Examples

- `test-floor-traffic-pt-0109`: Ant 3.0 `K17A31AN` abnormal power-off reported at `2026-05-25 13:17:33`.
  - RMS/Kafka screenshot at `2026/5/25 13:17:19` shows `robotLabel: K1731`, `connectionStatus: ONLINE`, `batteryCharge: 58`, `mainState: IDLE`, `errors: []`.
  - Battery chart shows SOC collapse and voltage/current dips; source analysis states actual voltage below `3.2V` triggered boost-module protection.
  - Wormhole log repeatedly reports `can_battery_status: Battery: 19.0%`, conflicting with RMS `58`.
  - Code analysis explains `0x8110` / `CO_EMC_CAN_OVERRUN` and NMT `05 -> 7F`.
  - Retry pcap contains repeated `8110` payloads and `0x750` heartbeats with data `7f`; another pcap shows `0x710`/`0x750` data `05`, so channel/node mapping remains important.
  - NXP and Wormhole logs end near local `13:16:11`, before the reported `13:17:33` power-off, so final shutdown sequence is not directly captured.

- `test-floor-traffic-pt-0109` still has unresolved evidence gaps:
  - The final minute from local `13:16:11` to reported `13:17:33` is absent from NXP/Wormhole logs.
  - Video representative frames show the test-floor scene and robot lights, but do not directly prove the electrical power-off sequence.
  - CAN pcaps show different heartbeat states across captures, so exact CAN channel/node mapping remains required before generalizing the transition timing.

## DM Camera Link Loss Collision Chain

Knowledge file: `docs/test-floor-traffic/knowledge/dm-camera-link-loss-collision-chain.md`

### First Checks

- Confirmed branch: the first stopped robot must be identified before blaming the later collision.
  - In `test-floor-traffic-pt-0008`, source text says A3772 reported `DM code lost` at `01:59:37` and stopped near `N3`.
  - A3767 then executed `A3767-S46169-2026-04-08T17:59:37.818Z-command-label-6` from `N1` toward `N3` and collided with A3772.
  - The monitoring video thumbnail shows the relevant 2F area at `2026-04-09 02:03:28`, but the collision point is a blind spot.
- Confirmed branch: A3772 had local DM/barcode link symptoms before the stop.
  - `011-source-O2T4bo311oT5LOxJuJGcPKybn5e.log` shows `gvsp poll timeout`, `gvcp poll timeout`, `failed to receive success ack`, and barcode heartbeat failures before the final stop.
  - At `2026-04-08T17:59:36Z`, A3772 logs `DM LOST, distance without barcode update: 3005.832722 mm`.
  - At `2026-04-08T17:59:37Z`, A3772 logs `CoordY is not as expected. expected value: 102000, actual value: 103767.265625, tolerance: 100`.
  - A3772 command `A3772-S44142-2026-04-08T17:59:05.997Z-command-label-6` ends with `COMPLETE_FAILURE` for `DIFF402_ERROR#MOVER_MOTOR#DM code lost` and `FUTURE_STATE_NOT_MATCH#CoordY`.
- Confirmed branch: A3772 local `lan1` link flapped during and after the failure window.
  - `010-source-Jv0zbRPa0okCzzxfCs1czK0UnWf.log` shows dense `lan1: Link is Down` / `Link is Up - 100Mbps/Full` events from `2026-04-08T17:59:34Z` through the following minutes.
  - Image evidence also shows the same `lan1` flapping around the event.
- Confirmed branch: A3778 repeated the same failure pattern in `test-floor-traffic-pt-0107`.
  - A3778 command `A3778-S55772-2026-05-05T16:29:51.767Z-command-label-0` starts as `PROCESSING` for a `MOVE` to `coordY=102000`.
  - At `2026-05-05T16:29:58Z`, A3778 logs dense `gvsp poll timeout` and `gvcp poll timeout`; at `16:29:59Z`, barcode heartbeat logs `failed to receive success ack`, `failed to send packet`, and `failed to get heartbeat status`.
  - At `2026-05-05T16:29:59Z`, A3778 logs `DM LOST, distance without barcode update: 3012.835117 mm`.
  - At `2026-05-05T16:30:01Z`, A3778 fails future-state check: `CoordY` expected `102000`, actual `103721.218750`.
  - At `2026-05-05T16:30:01Z`, A3778 reports `COMPLETE_FAILURE` for `DIFF402_ERROR#MOVER_MOTOR#DM code lost` plus `FUTURE_STATE_NOT_MATCH#CoordY`; the following spin command is cancelled.
  - A Wormhole screenshot at `2026-05-06T00:29:58+0800` shows `lan1: Link is Down` and `br-lan: port 1(lan1) entered disabled state`, aligning the robot-local DM timeout with the NXP-Wormhole physical link branch.
- Confirmed branch: MQTT/control-plane visibility can lag the robot-side failure.
  - In `test-floor-traffic-pt-0107`, A3778 logs `MQTT client disconnected -116` at `2026-05-05T16:30:06Z`, reconnects at `16:30:38Z`, then reports `Missing block(s)` and `NoRead status ongoing`.
  - The command-status screenshot shows external `COMPLETE_FAILURE` visible at local `2026/5/6 00:30:39`, after robot-side failure at `00:30:01`.
- Likely branch: scheduler/traffic logic must be checked as the secondary safety layer.
  - The direct initiating fault is A3772 localization/link loss, but A3767 still received or continued a route into the occupied conflict area.
  - Determine whether scheduler knew A3772 was failed near `N3`, whether reservation/future-state occupancy was released incorrectly, and whether the blind spot/route segment had conflict protection.
  - In `test-floor-traffic-pt-0107`, source text says A3769 hit A3778 around `00:30:28`; this needs A3769 route/reservation logs to prove the scheduling branch.
- Excluded branch for this case: broad robot network outage as the primary explanation.
  - Screenshots show ordinary ping to A3767/A3772 IPs around `02:02` with 0% loss and low latency.
  - This does not exclude DM camera local link failure on A3772 `lan1`.

### Evidence

- Exact collision position, route segment, and whether the area is covered by traffic reservation/interlock.
- A3772 robot logs before first stop: DM/barcode, `lan1`, motion, future-state, and command status.
- A3767 command timeline and scheduler decision logs around `2026-04-08T17:59:37Z` to confirm when the route to `N3` was issued.
- A3778 robot logs before first stop: `A3778-S55772`, DM/barcode, `lan1`, MQTT disconnect/reconnect, future-state, and command status.
- A3769 command timeline and scheduler decision logs around local `2026-05-06 00:30:01` to `00:30:39` to confirm why it entered A3778's stopped/conflict area.
- RCS/RMS/SAS reservation state for `N1`, `N2`, `N3`, and the relevant corridor before and after A3772 failure.
- Full video or whiteboard export if physical collision sequence or blind spot boundary matters.
- Hardware swap results: DM camera cable, camera, Wormhole board, switch port, and whether the fault follows the robot or component.

### Exclusions

- Do not treat the last collision robot as root cause until the first failed/stopped robot is identified.
- Do not use successful ping to robot IPs to exclude DM camera link loss; inspect robot-local `lan1`, barcode heartbeat, GVSP/GVCP, and DM read logs.
- Do not blame scheduler first if robot logs show `DM LOST` and `FUTURE_STATE_NOT_MATCH` before the collision; scheduler is the secondary collision-prevention branch.
- Do not treat `MQTT client connected!` after recovery as proof the movement was safe; compare failure time, reconnect time, and command-status publish time.
- Do not treat `Missing block(s)` after reconnect as root cause by itself; it is usually recovery/stale stream evidence after local link loss.
- Do not claim physical link root cause from one event alone; confirm with cable/camera/board swaps and whether lan1 flapping follows the component.
- Do not use blind-spot video as proof of collision order; use logs for order and video only for scene/time support.

### Examples

- `test-floor-traffic-pt-0008`: A3772 reports DM loss and future-state mismatch at `2026-04-08T17:59:36Z` to `17:59:37Z`; A3767 then collides with the stopped robot near `N3` according to the source analysis.
- `test-floor-traffic-pt-0107`: A3778 reports `DM LOST` at `2026-05-05T16:29:59Z`, `FUTURE_STATE_NOT_MATCH#CoordY` and `COMPLETE_FAILURE` at `16:30:01Z`, MQTT disconnect at `16:30:06Z`, reconnect at `16:30:38Z`, then `Missing block(s)`/`NoRead` after reconnect. Source says A3769 hit A3778 during this stale/failure window.

- `test-floor-traffic-pt-0008`: A3772 `lan1` continues to flap after DM camera cable swap, and A3778/A3772 Wormhole board swap was planned. Final component-level root cause is not confirmed in the visible case.
- `test-floor-traffic-pt-0107`: final component-level cause of A3778 `lan1` down is not confirmed; scheduler/RCS logs for A3769 are still needed to prove the secondary collision-prevention failure.
