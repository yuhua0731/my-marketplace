# Feeder Startup App-layer Disconnect

## Symptoms

- OmniSort / M141 startup fails with `开机失败，所有供包机断连`.
- Feeder IP parameters look plausible, for example `10.0.64.131:5000` and `10.0.64.132:5000`.
- ICMP ping to the feeder IPs can still be successful with `0.0% packet loss`.
- The UI may show controller green while the system is not running and all feeders are considered disconnected.
- Site labels may be inconsistent across the UI, source text, and parameter table; in `m141-pt-0167`, title says M141-2, symptom and parameter table say M141-3, and one runtime UI label shows `M135-SITE-1`.

## Fault Tree

1. Confirm the site identity first.
   - Compare source title, URL/site UUID, runtime current-feeder label, parameter key prefix, feeder UUID, and station-control config.
   - If these disagree, fix site binding/config selection before replacing network hardware.
2. Separate IP reachability from application reachability.
   - A successful ping only proves Layer-3 reachability.
   - Test TCP service reachability on the configured port, such as `10.0.64.131:5000` and `10.0.64.132:5000`.
   - Inspect whether the feeder application is listening and accepting the expected protocol.
3. Check feeder mapping and UUID.
   - Verify `SITE-1` / `SITE-2` mapping, `conveyorIP`, `conveyorUuid`, and physical feeder/device labels.
   - A reachable but wrong feeder can still fail application handshake or be rejected by backend logic.
4. Inspect startup sequence and backend logs.
   - Search the raw `sort_conveyor.log`, station-control service logs, and UI/backend logs around the alarm timestamp.
   - Look for connection refused, timeout, handshake failure, UUID mismatch, stale config, or "all conveyors disconnected" aggregation logic.
5. Only then inspect lower network and hardware.
   - If ping or TCP is unstable, inspect ARP/MAC, DHCP lease, route, switch port, cable, VLAN, firewall, or feeder power.
   - If both ping and TCP are stable, prioritize app protocol/config/state-machine branches.

## Evidence Needed

- UI alarm screenshot with exact timestamp.
- Parameter export for `conveyorIP`, `conveyorUuid`, station/site UUID, and feeder count.
- Raw `sort_conveyor.log` and station-control logs covering at least five minutes before and after the alarm.
- TCP port checks for every configured feeder IP/port.
- Feeder-side process/listener status and firewall/routing state.
- ARP/MAC/DHCP/switch-port evidence if TCP or ping is unstable.
- Clear confirmation that the UI, backend config, and physical site all refer to the same M141 site.

## Logs And Files To Inspect

- Search UI/backend/station-control logs for `开机失败`, `所有供包机断连`, `供包机断连`, `conveyor`, `sort_conveyor`, `station_control`, `connect`, `connection refused`, `timeout`, `handshake`, `uuid`, `siteUuid`.
- Search parameter/config exports for `conveyorIP`, `conveyorUuid`, `SITE-1`, `SITE-2`, `10.0.64.131:5000`, `10.0.64.132:5000`, `0x01`, `0x02`.
- Search startup logs for `start can_bus_recv_thread`, `start can_bus_sync_thread`, `allcan4_canopen_IO_init`, and feeder service bind/listen messages.

## Likely Causes

- Application-layer connection failure despite IP reachability: feeder service not listening, wrong port, refused connection, firewall, or handshake failure.
- Site/config mismatch: UI current feeder or site UUID points to a different site than the parameter table being checked.
- UUID/device mapping mismatch: backend connects to a reachable device but rejects it or marks it disconnected because UUID/site does not match.
- Startup ordering race: UI/startup check runs before station-control or feeder service finishes binding or reporting readiness.
- Lower network fault remains possible only if TCP or ping is intermittent, or if ARP/MAC/switch evidence is abnormal.

## Exclusion Checks

- Do not declare network normal from ping alone.
- Do not declare parameters normal until site labels, feeder UUIDs, and current feeder identity match.
- Do not replace switches/cables before checking TCP `:5000`, feeder listener, and backend handshake logs.
- Do not classify as EasyBox stale safety state unless the dominant symptom is stale `一类急停` or `动力电源` after power-cycle.
- Do not claim final root cause from screenshot-only `tail -f` output that starts after the alarm.

## Confirmed Examples

- `m141-pt-0167`: UI reports `开机失败，所有供包机断连` at `2026-06-16 14:13:58`.
  - Parameter screenshot shows `M141-3-SITE-1-conveyorIP` = `10.0.64.131:5000`, `conveyorUuid` = `0x01`, and `M141-3-SITE-2-conveyorIP` = `10.0.64.132:5000`, `conveyorUuid` = `0x02`.
  - Ping screenshot shows both IPs reachable with `0.0% packet loss`.
  - Log screenshot from `/var/log/station_control/sort_conveyor.log` starts around `2026-06-16T14:14:27+0800` and shows CAN threads plus ALLCAN4 IO initialization, but not the earlier feeder connect failure.
  - Site identity is inconsistent: title says M141-2, symptom/parameter table says M141-3, and runtime UI shows current feeder `M135-SITE-1`.

## Unresolved Examples

- `m141-pt-0167` lacks raw service logs, TCP port probes, feeder-side listener status, config export, and recovery/root-cause record; use it as a diagnostic pattern for app-layer/site-binding checks, not as a confirmed root cause.

## Specialist Routing

- `network-infra`: ping/TCP split, ARP/MAC/DHCP/switch-port evidence, VLAN/firewall/route checks, feeder IP/port reachability.
- `embedded-software`: station-control startup, `sort_conveyor.log`, feeder service binding, protocol handshake, config loading, UUID/site validation.
- `scheduler-traffic`: startup/task blocking only after connectivity and feeder service health are proven.
- `vision-media`: UI and parameter screenshot interpretation, including site-label mismatch.
