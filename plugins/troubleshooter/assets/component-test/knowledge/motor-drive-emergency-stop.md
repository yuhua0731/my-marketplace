# Component Test Motor Drive Emergency Stop Knowledge

source_set: `component-test-pt-0077`, `component-test-pt-0079`
case_count: 2 focused 1000W climb-motor emergency-stop cases
status: runtime routing rules for motor braking/disable behavior under physical emergency stop

## Symptoms

- Mantis/Spider vertical axis carries load, descends, then a physical emergency stop is triggered.
- Drive does not immediately hold/brake; payload continues falling or overspeeding.
- Descending E-stop may generate back EMF/regenerative voltage and drive overvoltage alarms.
- Example `component-test-pt-0077`: Mantis/spider `003`, Flowser/Xinliu `1000W` climb motor, `30KG` load, descending physical E-stop, overvoltage error, about `4cm` slide.
- Example `component-test-pt-0079`: J38A11SP, 30 kg load, descending at about `2201 rpm` when E-stop was triggered; speed rose up to `4153 rpm` before hitting the lower limit block.
- Later empty-load tests still showed delayed stopping at about `2500 rpm` / `2275 rpm` under some parameter/firmware combinations.

## Fault Tree

1. Preserve the mechanical safety sequence first.
   - Record load, direction, speed, acceleration, trigger time, and whether the lower limit block was hit.
   - Do not treat E-stop as proof that the drive entered torque-holding/braking immediately.
2. Check motor/drive parameter set before firmware or mechanism replacement.
   - `component-test-pt-0079` field resolution tested `605A:00 = 2`, `pn00b` back to default `10ms`, and `pn00A 2000 -> 3000`.
   - After `pn00A -> 3000`, empty-load descent at about `2447 rpm` stopped immediately in the visible source record.
3. Correlate NXP disable/enable controlword behavior.
   - Downloaded NXP log `assets/component-test-pt-0079/023-source-OyADb5RPqoFnkUxMrp0c7bYWnPb.log` contains repeated `node402: failed to set control word timeout` and `failed to disable foot motor 1/2/3/4`.
   - The same log later shows `Reset cause: External pin reset` and CANopen stack re-initialization.
4. Check regenerative overvoltage branch for descending E-stop.
   - `component-test-pt-0077` source says descending physical E-stop produced back EMF; detected voltage exceeded threshold and triggered overvoltage warning.
   - No overvoltage module: voltage rose to `90V`, with damage risk.
   - With overvoltage protection module: voltage rose to `82V`, lower but still with optimization margin.
   - If warnings remain after module installation, inspect drive thresholds, deceleration/braking parameters, and module sizing/mounting.
5. Separate four branches:
   - drive braking parameter branch: E-stop command received, but stopping/braking parameter behavior is unsafe;
   - CANopen/controlword branch: NXP cannot disable or command the drive in time;
   - power/reset branch: E-stop or related wiring causes controller/drive reset and invalidates normal disable sequence.
   - regenerative overvoltage branch: descending load energy raises DC bus above threshold during E-stop.
6. Use video and oscilloscope/drive plots for physical confirmation.
   - In this case, videos and drive parameter screenshots are essential evidence; log text alone does not prove whether the payload fell or held.

## Evidence Needed

- Operation video covering the E-stop trigger, load fall/hold, and lower-limit impact.
- NXP log around trigger time, including node402 controlword writes, disable attempts, and reset cause.
- CAN pcap/candump around trigger time for controlword/statusword changes.
- Drive parameter screenshots or export for `605A:00`, `pn00A`, `pn00b`, and braking/deceleration parameters.
- Speed, torque, DC-link voltage, and motor voltage/current curves from the drive tool.
- Overvoltage module specification, wiring, rated clamp/dissipation ability, and mounting plan.
- Before/after DC bus peak captures for no-module versus protected runs, including repeated tests.
- Firmware version used in each test round.

## Logs And Files To Inspect

- `assets/component-test-pt-0079/023-source-OyADb5RPqoFnkUxMrp0c7bYWnPb.log`
- `assets/component-test-pt-0079/019-source-XB3XbLMNfoGlGAxYBNFcQB8Tni5.pcap`
- `assets/component-test-pt-0079/022-source-SmgsbhTSoo5koZxDu8ucnuZEn1e.pcap`
- `assets/component-test-pt-0079/025-source-JVgHbShGAohXvFxYhbhc6tXWnXc.pcap`
- Operation videos under `assets/component-test-pt-0079/`.
- Drive screenshots under `assets/component-test-pt-0079/*.png`.

## Likely Causes

- Unsafe or mismatched emergency-stop/braking parameter set on the WECON 1000W drive.
- Descending load regenerative energy raises DC bus voltage above drive threshold.
- Overvoltage protection module is undersized, poorly mounted, or not paired with correct braking/deceleration parameters.
- Controlword timeout during disable path, causing delayed or failed motor disable.
- Controller/drive external reset during the E-stop window.
- Firmware/drive parameter combination that only partially resolves unloaded behavior and must still be verified under load.

## Exclusion Checks

- If loaded vertical-axis video is missing, do not claim the revised parameter set is safe under load.
- If only peak values such as `90V` and `82V` are visible, do not claim final closure without rated limits, alarm threshold, waveform duration, and repeated retest.
- If overvoltage warning remains after adding a protection module, do not call the module-only fix complete.
- If NXP can set controlword and statusword changes immediately, focus on drive braking parameter behavior rather than CAN timeout.
- If `Reset cause: External pin reset` appears near the event, do not analyze the case as pure drive parameter behavior.
- If the motor stops immediately after `pn00A -> 3000` only in empty-load testing, keep load-bearing verification open.
- Do not collapse lower-limit impact into a mechanical fault until drive braking and disable timing are checked.

## Confirmed Examples

- `component-test-pt-0077`: Flowser/Xinliu 1000W climb motor on Mantis/spider `003`. With `30KG` load descending, physical E-stop caused overvoltage error and about `4cm` slide. Source analysis attributes the alarm to back EMF/regenerative voltage exceeding threshold. Supplier recommended an overvoltage protection module; follow-up comparison records `90V` without the module and `82V` with the module, but notes module installation difficulty and remaining overvoltage warning that may need parameter tuning.
- `component-test-pt-0079`: WECON 1000W motor under physical E-stop. Source text records unsafe descent under 30 kg load, parameter experiments, and a later immediate stop when `pn00A` was changed to `3000` in empty-load testing. NXP evidence includes controlword timeout and external reset markers.

## Unresolved Examples

- `component-test-pt-0077`: local assets are absent; waveform screenshots, voltage/current logs, module specification, exact drive thresholds, final parameter values, and loaded post-fix retest are missing.
- `component-test-pt-0079`: final loaded verification after parameter/firmware changes is not proven by the visible text; treat loaded safety as unresolved until video/logs confirm it.

## Specialist Routing

- `can-bus`: CANopen controlword/statusword timing, SDO/heartbeat, pcap alignment.
- `embedded-software`: NXP reset cause, node402 state machine, firmware version.
- `mantis-handling`: vertical load, fall distance, lower-limit impact, mechanical safety.
- `vision-media`: E-stop video and drive plot screenshots.
