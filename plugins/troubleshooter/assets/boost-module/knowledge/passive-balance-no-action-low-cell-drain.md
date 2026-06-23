# Boost Module Passive Balance No-Action And Low-Cell Drain

## Symptoms

- Boost module 1.1 passive balancing appears inactive during idle testing.
- Two cell groups show a visible voltage delta, for example battery 1 around `2.1V` and battery 2 around `2.5V`.
- After connecting the pack to the boost module and leaving it powered on for about half an hour, cell voltages do not visibly change.
- After overnight powered idle, the boost board can self-shutdown while the low cell drops further, for example to about `1.8V`.

## Fault Tree

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

## Evidence Needed

- Board firmware version and balancing strategy thresholds.
- Schematic or test spec for passive-balance enable, UVLO, and shutdown behavior.
- Cell voltage at cell terminals and board terminals before, during, and after test.
- Balancing resistor/MOS voltage drop, temperature, and current.
- Board standby/input current while powered idle.
- CAN/serial/debug logs or ADC telemetry showing sampled cell voltages and balance command state.
- Known-good board comparison with the same battery pack.

## Logs And Files To Inspect

- `cases/needs-assets/boost-module/0096-IfDtw7Ovyi5koJkqX3OcsSG5naf-2026-05-28-升压模块1.1被动平衡功能异常.md`
- `assets/boost-module-pt-0096/001-source-Obnabx4BaoF1UkxobxAcWYT8nCd.mov`
- `assets/boost-module-pt-0096/002-source-BeUwb6m1coEqCvxABXvc5k2vnRg.mov`
- `assets/boost-module-pt-0096/003-source-Cg3ObvXmdoWbvaxxtbqcezCCnTb.MOV`
- Search terms: `被动平衡`, `静置半小时`, `电压无变化`, `升压板自行关机`, `A2-11`, `2.1V`, `2.5V`, `1.8V`, `2.3V`, `0.4V`.

## Likely Causes

- Passive balancing was not enabled because of firmware thresholds, low-cell guard conditions, thermal/idle state gating, or missing enable command.
- Balancing current is too small to produce an observable voltage change over the tested half-hour.
- Balancing resistor/MOS or sense path is open, misassembled, or not driven.
- Board standby load drains the cells during long powered idle, and shutdown occurs only after the low cell has dropped further.
- Measurement point or wiring setup does not reflect the intended balance path.

## Exclusion Checks

- Do not route independent boost-module bench tests to Ant/C134 robot reboot branches just because the word `关机` appears.
- Do not conclude hardware failure until balancing enable thresholds and current path are measured.
- Do not conclude firmware failure until hardware balance path and sense wiring are verified.
- Do not treat a self-shutdown as normal without the exact shutdown threshold and cell voltage at the transition.
- Do not continue overnight tests on a low cell near `2.1V` without UVLO and discharge-current monitoring.

## Confirmed Examples

- `boost-module-pt-0096`: A2-11 started around battery 1 = `2.1V`, battery 2 = `2.5V`, delta `0.4V`. After connecting to the boost module and idling for half an hour, visible text and video frames show no meaningful voltage change. After overnight power-on, the boost board self-shut down and the cells were reported around `1.8V` and `2.3V`; the table later records `2026/05/29 13:30` as `1.87/2.34` and `16:50` as `2.07/2.39`.

## Unresolved Examples

- `boost-module-pt-0096`: root cause remains blocked by missing firmware thresholds, balance-path current/voltage-drop measurements, standby-current data, UVLO transition timing, and known-good board comparison.

## Specialist Routing

- `boost-module`: primary branch for passive balancing, UVLO, standby drain, board-level measurements, and known-good comparison.
- `embedded-software`: firmware state, ADC telemetry, balance-enable logic, and shutdown thresholds.
- `can-bus`: only if the boost module exposes CAN telemetry or state frames for voltage/current/balance commands.
- `vision-media`: inspect meter videos, wiring, probe contact, board setup, and visible measurements.
