# Feeder Light Curtain Length Undermeasure Stop Outside

## Symptoms

- OmniSort / M123 feeder or loading module stops a package outside the light curtain or outlet boundary.
- Source or logs show package length measured much shorter than the actual physical package.
- The package may be soft, wrinkled, bag-like, semi-transparent, or otherwise irregular.
- `sort_conveyor` package tracking logs contain `pkt len`, `abnormal trigger`, or `scan_trigger_on()` / `scan_trigger_off()` errors near the same package.

## Fault Tree

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

## Evidence Needed

- Case body and source screenshot showing physical stop position.
- Raw `sort_conveyor.log` lines for the same package number across sensors 3/2/1/0.
- Exact stop-time log window covering the moment the package stopped outside the light curtain.
- Light-curtain IO waveform or sampled state transitions for each sensor.
- Conveyor speed, length-calculation parameters, debounce/filter config, and sensor alignment/calibration.
- Representative video frames showing package shape and the moment it crosses each light curtain.
- Reproduction with the same package and at least one control package of known length.

## Logs And Files To Inspect

- Case body: `cases/accepted/m123/0031-FxxlwxQ4uimW2akKbR8cOXt7nzg-2026-04-01-Mini-Plus-M123二号站点供包机包裹停止位置超出光幕.md`.
- Local images: `assets/m123-pt-0031/001-image-dbd465b94af6.jpg`, `assets/m123-pt-0031/002-image-38a1daf5971e.png`.
- Local video: `assets/m123-pt-0031/003-source-UdvLbLfaPoG7QyxWsNkcoPsLnce.mp4`.
- Local log bundle: `assets/m123-pt-0031/004-source-Lm20b2JQkoRMKRxNjSkcr13Dnkc.zip`.
- Search terms: `validation new package`, `package passed sensor_id`, `pack_num`, `pack_id`, `pkt len`, `abnormal trigger`, `scan_trigger_on`, `scan_trigger_off`, `warning loading_time`, `LOADING_WAITING`, `lift step`.

## Likely Causes

- Package shape or material creates unstable light-curtain blocking, causing the measured length to be shorter than the real package.
- Sensor 3 edge quality, alignment, debounce/filtering, or sampling is unstable, especially when `abnormal trigger` appears before the downstream measurements.
- Conveyor speed or length conversion is wrong or not aligned with the actual package crossing interval.
- Stop-distance or loading-state logic trusts the short measured length and stops the package beyond the light-curtain boundary.

## Exclusion Checks

- Do not diagnose shuttle dispatch or stale opposite-site state unless logs show parcel already on a shuttle or station reservation/dispatch loop.
- Do not diagnose MOXA, MQTT, or robot network faults without robot disconnect, broker discovery, or ping evidence.
- Do not diagnose CAN/power-cycle recovery from later heartbeat/PDO errors outside the package stop window.
- Do not call the light curtain hardware failed from one screenshot; require repeated package-specific trigger evidence, IO waveform, or swap/calibration proof.
- Do not claim root cause from source annotations alone; match the screenshot values with raw log lines when available.

## Confirmed Examples

- `m123-pt-0031`: source reports a `~30cm` package stopped outside the light curtain. Local raw log for `pack_num: 20` shows `0.186613`, then sensor 2 `0.168598`, sensor 1 `0.202229`, plus `abnormal trigger, sensor_id: 3` and `light on scan_trigger_on() failed`. Local image/video evidence shows a soft wrinkled package in the station feeder/lift area.

## Unresolved Examples

- `m123-pt-0031`: final mechanism is evidence-limited because the exact `17:30:35` stop-time log window, sensor IO waveform, sensor config, conveyor speed/config, and repeated reproduction result are not local.

## Specialist Routing

- Start with `embedded-software` for package-tracking length calculation, state machine, and stop-position logic.
- Add `vision-media` to inspect package shape, physical stop position, and representative frames.
- Add `can-bus` only if motor/sensor node errors line up with the same package crossing window.
- Add `scheduler-traffic` only if station reservation, shuttle handoff, or package ownership evidence appears after the measurement issue is resolved.

