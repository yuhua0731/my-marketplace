# Boost Module Troubleshooting Playbook

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
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## Boost Module High-Load Transient Protection Restartable Shutdown

Knowledge file: `docs/boost-module/knowledge/high-load-transient-protection-restartable.md`

### First Checks

1. Separate recoverable protection shutdown from latch/power-key failure.
   - `boost-module-pt-0095` can be manually powered on again.
   - Do not use the `boost-module-pt-0092` stuck power-key branch unless the switch becomes ineffective or rails stay latched on.
2. Verify the measured `4.3V` node.
   - Confirm whether it is pack output, board input, cell group voltage, or post-protection rail.
   - Measure input and output at board terminals during shutdown and restart.
3. Reconstruct the 400W transient.
   - Capture voltage/current waveform around load step, protection trigger, output collapse, and manual restart.
   - Preserve probe scale, current polarity, and time base; thumbnail shows a large current transient down to `-30.0A`.
4. Inspect protection thresholds and recovery policy.
   - Check UVLO, overcurrent, short-circuit, inrush/current limit, blanking time, thermal guard, hiccup/latch-off mode, and minimum restart voltage.
5. Compare samples.
   - Compare `A2-06` with `A2-08` and a known-good board under the same 400W load, battery voltage, firmware, wiring, and probe setup.

### Evidence

- Full waveform or video frames covering load application, shutdown, manual restart, and recovery.
- Schematic/test spec for UVLO, overcurrent, current limit, short-circuit, hiccup/latch-off, and restart policy.
- Firmware version, ADC telemetry, protection state, and event logs.
- Node measurements after shutdown: input, output, control rail, enable/latch pin, gate drive, and current.
- Known-good board comparison under the same `400W` transient and low-input condition.
- Repeated test and post-fix result.

### Exclusions

- Do not merge with passive-balance no-action unless balancing or overnight drain evidence appears.
- Do not merge with power-key latch failure unless the power switch becomes ineffective or rails remain stuck on.
- Do not route independent bench shutdown to Ant/C134 robot power branches.
- Do not treat remaining `4.3V` as abnormal without threshold and measurement-node evidence.
- Do not confirm root cause from a single QuickLook scope thumbnail.

### Examples

- None yet. `boost-module-pt-0095` establishes a recoverable protection-shutdown triage path, but root cause remains unresolved because full waveform, thresholds, rail measurements, and retest are missing.

- `boost-module-pt-0095`: A2-06 boost board self-shuts down during `400W` instantaneous load while source reports battery output still `4.3V`; it can be manually powered on again. QuickLook confirms scope/bench evidence, but full transition waveform, threshold spec, telemetry, and repeated recovery test are not local.

## Boost Module Passive Balance No-Action And Low-Cell Drain

Knowledge file: `docs/boost-module/knowledge/passive-balance-no-action-low-cell-drain.md`

### First Checks

1. Confirm the measurement setup before classifying the board.
   - Measure both cell groups at the cell terminals and at the board sense/input terminals.
   - Confirm meter range/calibration, probe contact, polarity, and whether the board is actually powered.
2. Decide whether passive balancing should be enabled.
   - Need design spec: balance-enable voltage, delta threshold, minimum cell voltage, UVLO threshold, thermal limits, and firmware state.
   - A `0.4V` delta is a strong field signal, but the case is still blocked if the enable thresholds are unknown.
3. Check whether the balancing path is acting.
   - Measure balancing resistor/MOS voltage drop, resistor temperature, and board input/standby current.
   - If the balancing path has no voltage drop/current while the firmware says enabled, suspect hardware path failure.
   - If firmware says disabled, inspect thresholds, low-cell protection, and state-machine gating.
4. Separate balance no-action from overnight cell drain.
   - If both cells drop while balancing does not change their delta, inspect board standby load and shutdown thresholds.
   - If the low cell drops near `1.8V`, prioritize under-voltage protection risk before extended balance tests.
5. Compare with a known-good module under the same cells, wiring, voltage delta, duration, and firmware version.

### Evidence

- Board firmware version and balancing strategy thresholds.
- Schematic or test spec for passive-balance enable, UVLO, and shutdown behavior.
- Cell voltage at cell terminals and board terminals before, during, and after test.
- Balancing resistor/MOS voltage drop, temperature, and current.
- Board standby/input current while powered idle.
- CAN/serial/debug logs or ADC telemetry showing sampled cell voltages and balance command state.
- Known-good board comparison with the same battery pack.

### Exclusions

- Do not route independent boost-module bench tests to Ant/C134 robot reboot branches just because the word `关机` appears.
- Do not conclude hardware failure until balancing enable thresholds and current path are measured.
- Do not conclude firmware failure until hardware balance path and sense wiring are verified.
- Do not treat a self-shutdown as normal without the exact shutdown threshold and cell voltage at the transition.
- Do not continue overnight tests on a low cell near `2.1V` without UVLO and discharge-current monitoring.

### Examples

- `boost-module-pt-0096`: A2-11 started around battery 1 = `2.1V`, battery 2 = `2.5V`, delta `0.4V`. After connecting to the boost module and idling for half an hour, visible text and video frames show no meaningful voltage change. After overnight power-on, the boost board self-shut down and the cells were reported around `1.8V` and `2.3V`; the table later records `2026/05/29 13:30` as `1.87/2.34` and `16:50` as `2.07/2.39`.

- `boost-module-pt-0096`: root cause remains blocked by missing firmware thresholds, balance-path current/voltage-drop measurements, standby-current data, UVLO transition timing, and known-good board comparison.

## Boost Module Protection Shutdown Power-Key Latch Failure

Knowledge file: `docs/boost-module/knowledge/protection-shutdown-power-key-latch-fail.md`

### First Checks

1. Separate protection shutdown from user power-off.
   - Protection can disable boost/load output while MCU/control/latch rails remain alive.
   - A power-key failure means the switch signal, latch circuit, firmware state, or backfeed path must be checked separately.
2. Reconstruct rail state after protection.
   - Measure battery/input voltage, boost output, MCU/control rail, enable/latch pin, gate drive, and current before and after button press.
   - Confirm what `4.6V` measures: pack output, board input, cell group sum, or another node.
3. Inspect UVLO/overcurrent/protection thresholds.
   - Check UVLO, overcurrent, short-circuit, hiccup/latched-off strategy, and minimum voltage required for button detection.
   - If the control rail falls into an invalid range, the MCU may ignore or mis-sample the button.
4. Inspect hardware power-key and latch path.
   - Check button contact, debounce, pull-up/down, enable MOS/latch transistor, discharge path, and whether the key is hard power-cut or firmware command.
5. Inspect load transient and recovery path.
   - Preserve the 400W transient profile, input voltage, current peak, and recovery timing.
   - Compare with a known-good board under the same load and voltage.

### Evidence

- Full waveform or video frames covering load application, protection shutdown, button press, and post-button rail state.
- Schematic/test spec for power-key, latch/enable, UVLO, overcurrent, discharge path, and protection recovery.
- Firmware version, ADC telemetry, protection state, and button event logs.
- Node measurements after protection: input, output, MCU rail, enable/latch pin, gate drive, and load current.
- Known-good board comparison under the same `400W` transient and low-input condition.
- Recovery method and repeated post-fix test.

### Exclusions

- Do not merge with passive-balance no-action unless balance thresholds or cell-drain behavior are present.
- Do not route independent bench tests to Ant/C134 robot reboot branches just because the symptom says `无法断电`.
- Do not conclude button hardware failure without measuring the button signal and latch/enable rails.
- Do not conclude firmware failure until hardware latch, backfeed, and rail validity are checked.
- Do not treat a dark output as full power-off; verify control rail and latch state.

### Examples

- None yet. `boost-module-pt-0092` establishes a reusable triage path, but root cause remains unresolved because the full waveform, rail measurements, thresholds, and recovery test are missing.

- `boost-module-pt-0092`: A2-08 boost board enters protection shutdown during `400W` instantaneous load while the source reports battery output still at `4.6V`; afterward the power switch button is ineffective. QuickLook confirms bench/scope evidence, but full transition waveform, button/latch measurements, firmware thresholds, and retest are not local.
