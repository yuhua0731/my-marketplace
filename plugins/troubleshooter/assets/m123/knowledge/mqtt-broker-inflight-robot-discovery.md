# MQTT Broker Inflight Robot Discovery

## Symptoms

- M123 / OmniSort central control cannot discover or search some robots after all robots are added.
- Robot wormhole IP addresses are reachable or enterable from `DHCCP_SERVER` / DHCP server context, so the fault is not simply "robot IP unreachable".
- Startup after emergency-stop release reports repeated alarm summaries such as `解除急停后启动，该问题发生。请检查机器人电源状态`.
- Restart/reset actions clear the immediate alarm, but the fleet registration/discovery issue points to broker-side message flow.

## Fault Tree

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

## Evidence Needed

- Mosquitto configuration before/after changing `max_inflight_messages` to `300`.
- Broker restart log, service name, version, and timestamp matching recovery.
- MQTT broker logs around robot add/startup: client connect/disconnect, inflight queue, dropped messages, retained/session state, subscriptions, and QoS.
- Central-control discovery logs for the two missing robots: robot IDs, MAC/IP, client ID, topics, and state transition.
- DHCP/wormhole evidence proving the missing robots' IPs were reachable before broker restart.
- Before/after screenshot or API output showing the two robots reappeared after broker change.

## Logs And Files To Inspect

- Case body: `cases/needs-assets/m123/0136-Ub7SwS1Ndi52HMkGng8caNulnkc-2026-05-11-M123中控搜索不到机器人.md`.
- `assets/m123-pt-0136/retry-image-001-ZXt0bSwXhoWtQ0xtL2xcEXcPnof.png`: UI alarm list inspected visually and with OCR; rows span `2026-05-11 16:57:51` to `18:52:14`, abnormal text says `解除急停后启动，该问题发生。请检查机器人电源状态`, and handling includes `RESET SYSTEM`.
- Search terms: `m123-pt-0136`, `M123中控搜索不到机器人`, `DHCCP_SERVER`, `DHCP_SERVER`, `虫洞IP`, `mosquitoo`, `mosquitto`, `max_inflight_messages`, `mqtt broker`, `RESET SYSTEM`, `解除急停后启动`, `请检查机器人电源状态`.

## Likely Causes

- MQTT broker inflight limit too low for the current robot count or startup burst, blocking or delaying registration/state messages.
- Broker retained/session/subscription state stuck until broker restart.
- Central control depends on MQTT discovery/state topics even when robot IP/DHCP reachability is normal.
- Less likely as primary cause: robot power or physical network outage, because source says all wormhole IP addresses could be entered and broker setting/restart restored the issue.

## Exclusion Checks

- Do not diagnose robot IP/network unreachable solely from "中控搜索不到机器人" if DHCP/wormhole IP access works.
- Do not treat repeated `RESET SYSTEM` as the root cause; it is an operational recovery action or alarm handling symptom unless logs prove reboot causality.
- Do not route to station dispatch/load-stall knowledge from `M123` alone; require station, parcel, `oppositeShuttle`, or dispatch-loop evidence.
- Do not claim `max_inflight_messages=300` as universally correct; record robot count, QoS, broker version, and message rate before turning it into a default.
- Do not close the case without broker logs or before/after discovery proof when the issue recurs.

## Confirmed Examples

- `m123-pt-0136`: M123 mini-pro system could not find two robots; `DHCCP_SERVER` showed wormhole IPs were enterable. After adjusting `mosquitoo` / mosquitto `max_inflight_messages` to `300` and restarting the MQTT broker, the source says the system recovered. The local screenshot shows repeated startup/reset alarms on `2026-05-11`, including `解除急停后启动，该问题发生。请检查机器人电源状态` and `RESET SYSTEM`.

## Unresolved Examples

- `m123-pt-0136`: remains evidence-limited because local assets do not include MQTT config/logs, central-control discovery logs, missing robot IDs, or before/after robot list.

## Specialist Routing

- Start with `network-infra` for MQTT broker, DHCP/wormhole reachability, robot discovery, and application-layer network state.
- Add `embedded-software` if robot-side MQTT client, NXP/wormhole logs, or reboot/power-state evidence is available.
- Add `scheduler-traffic` only if robots are discovered but not assigned tasks or not transitioning in scheduler state.
- Add `vision-media` only for UI screenshot verification, not root-cause analysis.
