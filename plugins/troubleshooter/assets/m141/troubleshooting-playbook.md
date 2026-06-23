# M141 Troubleshooting Playbook

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

## EasyBox Power-cycle Safety State Stale

Knowledge file: `docs/m141/knowledge/easybox-power-cycle-safety-state-stale.md`

### First Checks

1. Start from the recovery state after power returns, not only from the initial motor/CAN alarms.
   - If controller/feeder indicators are green but `动力电源` or `一类急停` remains red, inspect the safety-state reporting path.
   - If all devices are offline, diagnose power/network first before stale safety state.
2. Separate real emergency-stop state from stale imported node state.
   - Check whether the physical emergency-stop button is pressed, whether the door is locked, and whether safety-lock/electromagnetic-force inputs are actually triggered.
   - If physical inputs are normal but UI still shows red, suspect stale state in EasyBox/CAN Gateway or imported EasyBox table nodes.
3. Check whether EasyBox also powered off.
   - If EasyBox loses power, it may not emit a change event on reboot because the imported node state did not change while it was offline.
   - On reboot, EasyBox should actively query all imported node states and report them once.
4. Review the changed safety logic.
   - In branch `I-1472-mini-power-status-as-power-stop-signal`, power-supply feedback was treated as an emergency-stop signal.
   - This changes the recovery flow: door lock can fail before power is restored, and the user may need to restore power with the blue button before locking the door again.
5. Validate the fix with gateway version and reboot behavior.
   - `CAN Gateway 1.0` / EasyBox version `V3.1.4` is the confirmed fix path in `m141-pt-0171`.
   - After update/restart, verify that emergency-stop button and safety-lock states are refreshed accurately.

### Evidence

- UI event timeline around power loss and recovery.
- Physical emergency-stop, door-lock, electromagnetic-force, and safety-lock state at recovery time.
- EasyBox/CAN Gateway version and reboot/update records.
- Logs or screenshots showing feeder CAN heartbeat loss and conveyor error codes.
- Operator recovery sequence: door lock, blue power button, refresh status, one-key apply/release electromagnetic force.
- Raw EasyBox/CAN logs if available; screenshots alone confirm UI state but not frame-level CAN timing.

### Exclusions

- If the physical emergency-stop is still pressed or the door is not actually locked, do not classify as stale state.
- If EasyBox/CAN Gateway remains offline, diagnose network/power for the gateway first.
- If version is already updated and reboot-time state report is confirmed, inspect upper-system state clearing and UI refresh logic.
- If raw CAN/EasyBox logs are missing, do not claim exact frame-level missed report timing.

### Examples

- `m141-pt-0171`: M141-3 cut incoming power at `2026-06-16 15:34`, reconnected at `15:36`, and class-1 emergency stop could not recover by `16:42`.
  - Event UI shows `2026-06-16 15:34:39` `电机报错`, `15:34:44` `供包机CAN节点心跳丢失`, and `15:34:54/55` `导轨供电电源1/2异常`.
  - Debug page at `2026-06-16 16:37:14` shows line-stick cart electromagnetic-force, position, and safety-lock states as triggered.
  - Runtime overview at `2026-06-16 16:41:29` shows `动力电源` red and `一类急停` red while feeder and controller indicators are green.
  - Log screenshot shows `M141-3-SITE-2-CONVEYOR` `CONVEYOR_EVENT_0X03` and `M141-3-SITE-1_CONVEYOR` `CONVEYOR_EVENT_0X0F`.
  - Chat analysis states EasyBox also powered off; after EasyBox powers on, the mobile rack electromagnetic-force state had not changed, so it did not actively report. The proposed rule is to query imported EasyBox table nodes on power-up and report once.
  - Resolution screenshot confirms `CAN Gateway 1.0` current version `V3.1.4`; source text says updating EasyBox to `3.1.4` and restarting can correctly refresh emergency-stop button state.

- `m141-pt-0171` lacks raw EasyBox/CAN logs, so the exact missed CAN/report frame timing is not confirmed.
- The case confirms behavior for M141-3 and EasyBox/CAN Gateway `3.1.4`; verify the same power-cycle query/report behavior before generalizing to other M141 stations or older gateway versions.

## Feeder Startup App-layer Disconnect

Knowledge file: `docs/m141/knowledge/feeder-startup-app-layer-disconnect.md`

### First Checks

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

### Evidence

- UI alarm screenshot with exact timestamp.
- Parameter export for `conveyorIP`, `conveyorUuid`, station/site UUID, and feeder count.
- Raw `sort_conveyor.log` and station-control logs covering at least five minutes before and after the alarm.
- TCP port checks for every configured feeder IP/port.
- Feeder-side process/listener status and firewall/routing state.
- ARP/MAC/DHCP/switch-port evidence if TCP or ping is unstable.
- Clear confirmation that the UI, backend config, and physical site all refer to the same M141 site.

### Exclusions

- Do not declare network normal from ping alone.
- Do not declare parameters normal until site labels, feeder UUIDs, and current feeder identity match.
- Do not replace switches/cables before checking TCP `:5000`, feeder listener, and backend handshake logs.
- Do not classify as EasyBox stale safety state unless the dominant symptom is stale `一类急停` or `动力电源` after power-cycle.
- Do not claim final root cause from screenshot-only `tail -f` output that starts after the alarm.

### Examples

- `m141-pt-0167`: UI reports `开机失败，所有供包机断连` at `2026-06-16 14:13:58`.
  - Parameter screenshot shows `M141-3-SITE-1-conveyorIP` = `10.0.64.131:5000`, `conveyorUuid` = `0x01`, and `M141-3-SITE-2-conveyorIP` = `10.0.64.132:5000`, `conveyorUuid` = `0x02`.
  - Ping screenshot shows both IPs reachable with `0.0% packet loss`.
  - Log screenshot from `/var/log/station_control/sort_conveyor.log` starts around `2026-06-16T14:14:27+0800` and shows CAN threads plus ALLCAN4 IO initialization, but not the earlier feeder connect failure.
  - Site identity is inconsistent: title says M141-2, symptom/parameter table says M141-3, and runtime UI shows current feeder `M135-SITE-1`.

- `m141-pt-0167` lacks raw service logs, TCP port probes, feeder-side listener status, config export, and recovery/root-cause record; use it as a diagnostic pattern for app-layer/site-binding checks, not as a confirmed root cause.
