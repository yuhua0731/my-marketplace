# AP Topology Cascade Latency Collision

## Symptoms

- Second-floor test environment has Ant multi-robot traffic/collision after AP relocation or network topology changes.
- Robot command/status MQTT messages are delayed or stale.
- Terminal/log screenshots may show `receive time is too long`.
- Ping logs may show synchronized packet loss across multiple robot/device IPs, often as short back-to-back outage windows.
- Removing an added router/cascaded PoE switch or restoring the previous AP topology stops the disconnection recurrence.

## Fault Tree

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

## Evidence Needed

- Before/after network topology diagram, including AP uplink, InHand router, TP PoE switch, broker/server, and robot subnet.
- AP controller logs: client roaming, RSSI, retries, disconnect reason, channel utilization.
- Switch/router logs: port flaps, loops, NAT/firewall, DHCP, ARP, packet drops, queue/buffer stats.
- Pcap decoded by robot ID/topic, including publish-to-consume latency for `robot/state`, `robot/command/status`, and `robot/commandSet/create`.
- Scheduler reservation/route logs around collision.
- Physical collision photos/video and exact robot IDs involved.

## Logs And Files To Inspect

- RCS logs for `receive time is too long`, `RobotCommand not found`, command status delay, robot state freshness, and route/reservation decisions.
- Pcap filters: `tcp port 1883`, `robot/command/status`, `robot/state`, `robot/commandSet/create`, robot IDs, broker IPs, and AP/server subnets.
- Ping logs for synchronized `timed out` windows across `10.0.64.x` robot/device IPs. Exclude always-offline hosts before claiming a global outage.
- Network docs for `AP 未挪动前`, `映翰通路由器`, `TP PoE 交换机`, and `二楼测试环境拓扑图`.

## Likely Causes

- AP relocation changed wireless coverage, roaming, or uplink path.
- InHand router plus cascaded TP PoE switch introduced unstable or delayed MQTT path.
- Multi-subnet/NAT/container path caused asymmetric routing or buffering under load.
- Shared network infrastructure generated periodic short outages across many robots, for example hourly router/switch/AP control-plane events or link reconvergence.
- Scheduler did not sufficiently protect traffic when robot state/command status was delayed.

## Exclusion Checks

- Do not blame DM camera/link loss unless robot-local DM/GVSP/GVCP/link-flap evidence exists before collision.
- Do not blame reboot unless UPTIME reset, reset reason, or heartbeat disappearance proves it.
- Do not blame a single Ant if many robot topics show latency or network topology rollback removes recurrence.
- Do not blame a single Ant if multiple robot/device IPs time out in the same seconds.
- Do not include hosts that are unreachable for the whole capture as evidence of synchronized outage.
- Do not treat physical collision photos as proof of initiating order.
- Do not call the network fix proven by topology change alone; verify latency/disconnect counters and repeat traffic.

## Confirmed Examples

- `test-floor-traffic-pt-0059`: second-floor dispatch test environment collision case. Source says after `2026-03-23 14:28`, topology was restored to match the state before AP relocation, and the InHand router plus cascaded TP PoE switch were removed; disconnection had not recurred. Local assets include collision/blocked-scene photos, Wireshark screenshots where A3775 command status goes from `PROCESSING` at `18:01:32.599666` to `COMPLETE_SUCCESS` at `18:01:48.727407`, terminal `receive time is too long` warnings, RCS logs with repeated A2036/A4883 layout warnings, and a pcap carrying MQTT robot state/command traffic.

- `test-floor-traffic-pt-0006`: second-floor dispatch test collision involving `A3767`, `A3775`, and `A2048`. Source says after `2026-03-23 14:28`, topology was restored to the pre-AP-move state and the InHand router plus cascaded TP PoE switch were removed; no disconnection had appeared at source time. Local ping logs show five devices (`10.0.64.126`, `.127`, `.134`, `.135`, `.145`) all timed out in eight synchronized groups: `10:22:04/21`, `11:22:49/23:06`, `12:23:34/23:51`, and `13:24:19/24:36`, with roughly 6-second then 8-second outages. `10.0.64.136` was excluded because it was unreachable from the beginning. The `processing_logic` screenshot shows `A3775` and `A3767` command `leave time is too long` warnings around the same event family.

## Unresolved Examples

- `test-floor-traffic-pt-0059`: exact topology diagram, AP/switch/router logs, per-robot pcap latency statistics, and scheduler reservation logs are not local; collision order remains unproven from photos alone.
- `test-floor-traffic-pt-0006`: exact topology diagram, AP/router/switch logs, DHCP/ARP/STP/link counters, robot logs, scheduler reservation logs, and post-rollback monitoring logs are not local; ping logs prove shared outage timing but not which infrastructure device caused it.

## Specialist Routing

- `network-infra`: AP/router/switch topology, MQTT latency, pcap, subnet path, disconnect recurrence.
- `scheduler-traffic`: stale robot state, reservation release/hold behavior, traffic protection under delayed state.
- `vision-media`: collision photos and physical scene.
- `robot-motion`: only if logs show path/pose/localization error after network delay is excluded.
