# M141 Fault Taxonomy

## Feeder Startup Connectivity

- `omnisort.m141.feeder_startup_app_layer_disconnect`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: startup fails with `开机失败，所有供包机断连` even though configured feeder IPs respond to ping.
  - Primary evidence: UI alarm timestamp, `conveyorIP` / `conveyorUuid` parameters, ping/TCP checks, `sort_conveyor.log`, station-control logs, feeder service listener state, site/current-feeder identity.
  - Primary specialists: `network-infra`, `embedded-software`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/feeder-startup-app-layer-disconnect.md`.

## Safety And Power Recovery

- `omnisort.m141.easybox_power_cycle_safety_state_stale`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: after incoming power is cut and restored, physical emergency-stop/door-lock state is normal but UI still shows class-1 emergency stop or power fault red.
  - Primary evidence: EasyBox/CAN Gateway reboot/update state, line-stick cart electromagnetic-force/safety-lock UI, power/emergency-stop UI indicators, feeder CAN heartbeat and conveyor events.
  - Primary specialists: `embedded-software`, `can-bus`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/easybox-power-cycle-safety-state-stale.md`.

## Evidence Status

- Treat ping success as IP-layer evidence only; it does not prove feeder service, TCP port, or application handshake health.
- Treat M141/M135/M141-2/M141-3 label mismatches as blocking evidence until the active site, config, and physical feeder mapping are reconciled.
- Treat motor/CAN heartbeat loss during intentional incoming-power cut as consequence until it persists after power and safety-state refresh.
- Treat UI red emergency-stop state as unconfirmed physical emergency stop until door lock, emergency-stop button, and safety-lock input state are checked.
- Treat screenshots and videos as UI-state evidence only; raw EasyBox/CAN logs are needed for frame-level reporting conclusions.
