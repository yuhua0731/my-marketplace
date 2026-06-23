# MOXA Switch Robot Link Loss

## Symptoms

- M123 / OmniSort robot loses network after being connected through a newly added MOXA switch.
- The robot stops during shuttle mode and reports `END CMD TIMEOUT ERROR`; body light strip can stay red.
- Server-side long ping to the affected robot returns `Destination Host Unreachable` for hours.
- A same-server control ping to an added test PC remains normal, excluding a site-wide server-network outage.
- Moving the robot network cable back to the original TP-LINK switch can restore stable multi-day operation.

## Fault Tree

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

## Evidence Needed

- Raw `/var/log/ping-monitor/*.log` text for `10.0.64.103` and `10.0.64.123` around `2026-06-16 22:05` through `2026-06-17 08:30`.
- MOXA switch model, firmware, running configuration, VLAN/QoS/BSP/loop-protection/STP settings, and per-port counters for the robot port.
- Physical port mapping for robot `J42A67MN`, robot/endpoint `103`, labels `M13` / `M15`, original TP-LINK port, and the test PC.
- Robot `103` / wormhole logs around first unreachable time, including link up/down, IP address, DHCP/static config, ARP table, and reset history.
- Ping/ARP/traceroute from both directions: server to robot, robot to server, server to PC, PC to server, and if possible PC to robot on the same switch segment.

## Logs And Files To Inspect

- Case body: `cases/accepted/m123/0149-B03Rw7myJi4jfOkILUTcHdZVnNh-2026-06-10-M123-连接MOXA交换机后机器人断网问题.md`.
- `assets/m123-pt-0149/retry-image-001-Fw6HbtN3ToT4OuxeetVcQ1NQnRf.jpg`: physical MOXA EDS-series switch wiring inspected; green robot/network cables with labels including `M13` and `M15` are visible.
- `assets/m123-pt-0149/retry-image-002-VZETbyG88oqrTkx93KqcXnwknae.png`: OCR/visual inspection shows `grep ' 22:05:' /var/log/ping-monitor/*.log`, repeated `Destination Host Unreachable` from `10.0.64.108`, and successful replies from `10.0.64.123`.
- `assets/m123-pt-0149/retry-image-003-ST95b7TdWoiGg4xU1mFcJ3s2ncy.png`: OCR/visual inspection shows `grep ' 08:30:' /var/log/ping-monitor/*.log`, repeated `Destination Host Unreachable` from `10.0.64.108`, and successful replies from `10.0.64.123`.
- Search terms: `END CMD TIMEOUT ERROR`, `Destination Host Unreachable`, `10.0.64.108`, `10.0.64.103`, `10.0.64.123`, `MOXA`, `TP-LINK`, `qos`, `bsp`, `虫洞断连`, `J42A67MN`, `KO2A11MN`.

## Likely Causes

- MOXA-specific port or switch behavior isolated the robot link while the server and another endpoint remained reachable.
- Robot-side wormhole or robot NIC became unreachable after operating behind the MOXA switch, requiring board reset.
- Physical port/cable/label mapping or negotiation issue affected the robot path, not the whole M123 network.
- Switch features such as QoS, BSP/loop protection, STP, VLAN, storm control, or industrial switch defaults may need explicit verification instead of assuming plug-and-play equivalence with the original TP-LINK switch.

## Exclusion Checks

- Do not call this a server `108` outage if `108 -> 10.0.64.123` remains stable while `108 -> 10.0.64.103` is unreachable.
- Do not call this a whole-site network outage if only the robot path fails and the test PC path is normal.
- Do not treat disabling MOXA `qos` and `bsp` as a fix when the issue reproduces after disabling them.
- Do not close as generic robot fault until the same robot/port/cable comparison across MOXA and TP-LINK is recorded.
- Do not infer MOXA root cause from topology correlation alone; require switch config/logs/counters or packet evidence for final root cause.

## Confirmed Examples

- `m123-pt-0149`: M123 added a MOXA switch. Robot `J42A67MN` stopped at `2026-06-10 02:13:57` with `END CMD TIMEOUT ERROR`, ping failed, and wormhole disconnected. After moving the network cable back to the original TP-LINK switch, 48 hours of weekend running had no robot disconnect. Moving back to MOXA after disabling `qos` and `bsp` reproduced the issue; long ping from `10.0.64.108` to robot `103` became `Destination Host Unreachable` from about `2026-06-16 22:05` through `2026-06-17 08:30`, while `10.0.64.123` test PC stayed reachable.

## Unresolved Examples

- `m123-pt-0149`: exact MOXA-side mechanism remains unresolved because only screenshots of ping output are local; raw logs, switch configuration, per-port counters, and robot/wormhole logs are missing.

## Specialist Routing

- Start with `network-infra` for switch topology, port state, ARP/ping reachability, VLAN/QoS/BSP/STP/loop protection, and endpoint isolation.
- Add `embedded-software` for robot/wormhole logs and reset behavior if link-state or board reboot evidence exists.
- Add `scheduler-traffic` only after network reachability is restored or excluded, because `END CMD TIMEOUT ERROR` can be an upstream symptom of robot communication loss.
- Add `vision-media` only to confirm physical cabling, labels, and port mapping from photos.
