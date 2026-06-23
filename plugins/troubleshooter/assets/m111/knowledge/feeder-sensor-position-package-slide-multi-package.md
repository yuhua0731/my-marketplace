# Feeder Sensor Position Causes Package Slide Or Multi-Package Alarms

## Symptoms

- Mini / M111 feeder in no-scan infeed mode reports `供包机包裹滑动` after a parcel passes the first light curtain.
- Directly using the second feeder section reports `供包机多包`.
- After conveyor recovery, the shuttle may briefly enter force throw/unload while the site waits for the conveyor error to clear.

## Fault Tree

- Confirmed branch: light-curtain position configuration.
  - In `m111-pt-0035`, source resolution says the issue was fixed by changing `/etc/station_config/sensor.json`.
  - Feeder log contains `42136` occurrences of `package infeed error skip, sensors[0].length_sensor_state 0`.
  - The same feeder log ends with `sensors[0] LENGTH_SENSOR_ERROR`, `sensors[1] LENGTH_SENSOR_ERROR`, `sensors[2] LENGTH_SENSOR_ERROR`, followed by `LOADING_ERROR`.
- Likely branch: physical light-curtain order/position does not match configured section boundaries.
  - This can make normal parcel movement look like slide, duplicate package, missing length sensor, or impossible infeed state.
- Downstream branch: conveyor recovery waits for a shuttle and then force unloads.
  - Central control reports `RECOVER_CONVEYOR_ERROR_WAITING_SHUTTLE_AT_SITE` until robot `013` is present at `M111-SITE-1`.
  - Once `shuttlesInSameTrackLength: 1`, the site changes to force throw/unload and later clears `CONVEYOR_EVENT_0X01` or `CONVEYOR_EVENT_0X09`.

## Diagnostic Rules

- For `供包机包裹滑动` or `供包机多包`, check `/etc/station_config/sensor.json` before replacing sensors, motors, or robot hardware.
- Search feeder logs for `package infeed error skip`, `length_sensor_state 0`, `LENGTH_SENSOR_ERROR`, and `LOADING_ERROR`.
- Compare configured sensor positions with actual first/second feeder section geometry, light-curtain mounting order, and parcel travel direction.
- If recovery shows force throw/unload, inspect whether it follows a conveyor error and shuttle-arrival wait; do not treat force unload as the first root cause.
- Require before/after config diff or post-fix log evidence before closing the case as confirmed.

## Evidence Needed

- Before/after `/etc/station_config/sensor.json`.
- Feeder log before and after correction.
- Error-code mapping for `CONVEYOR_EVENT_0X01` / `CONVEYOR_EVENT_0X09` to UI alarms.
- Video frames or onsite observation showing the parcel crossing the relevant light curtains.
- Physical measurement or photo of light-curtain positions.

## Logs And Files To Inspect

- Feeder package-tracing log: `package_tracing.c`, `manualpace_load_lift_2belt_controller.c`.
- Central-control log: `CONVEYOR_EVENT_0X01`, `CONVEYOR_EVENT_0X09`, `RECOVER_CONVEYOR_ERROR_WAITING_SHUTTLE_AT_SITE`, `change to force throw`, `change to force unload`.
- Robot log only after feeder evidence is checked: `SEND_UDP_COMMAND_TIMEOUT`, CANopen SDO errors, stop-force-unload command results.

## Likely Causes

- `/etc/station_config/sensor.json` light-curtain positions do not match the physical feeder section geometry.
- Sensor order or section boundary config causes package tracing to see impossible length-sensor transitions.
- Conveyor recovery waits for a shuttle before clearing the event, which makes force throw/unload visible as a downstream symptom.

## Exclusion Checks

- Exclude robot 013 as primary cause if feeder sensor-state errors precede or coincide with the slide/multi-package alarm and config correction resolves it.
- Exclude generic conveyor recovery race when the initial symptom is package-tracing misclassification from sensor position.
- Exclude pure sensor hardware failure only after checking config-to-physical alignment and verifying sensor state changes at the controller input.
- Exclude workstation/WLED routing; feeder light curtain and conveyor recovery evidence belongs to handling/embedded/scheduler branches.

## Confirmed Examples

- `m111-pt-0035`: no-scan infeed through the first feeder section produced `供包机包裹滑动`; using the second section produced `供包机多包`; source fix was changing `/etc/station_config/sensor.json`. Feeder log showed high-frequency `sensors[0].length_sensor_state 0` and later multi-sensor `LENGTH_SENSOR_ERROR`; central control showed conveyor recovery and short force-unload windows around robot `013`.

## Unresolved Examples

- None in this knowledge file.

## Specialist Routing

- Start with `embedded-software` for feeder package-tracing and sensor config.
- Add `scheduler-traffic` for conveyor recovery, site waiting, and force-unload state transitions.
- Use `vision-media` to confirm physical sensor/parcel crossing order.
- Use `can-bus` only if sensor-state errors remain after config alignment or robot recovery errors dominate the timeline.
