---
name: boost-module
description: Use when diagnosing HC Robotics boost-module bench tests, passive balancing, cell-voltage imbalance, under-voltage shutdown, standby drain, boost output current, or boost-board hardware/firmware thresholds.
---

# Boost Module Specialist

## Focus

- passive balancing enable/disable behavior
- cell-voltage imbalance and low-cell protection
- boost-board idle current and overnight drain
- balancing resistor/MOS/sense-path measurements
- firmware thresholds, ADC telemetry, UVLO, and shutdown state
- known-good board comparison

## Checks

1. Record module sample ID, firmware version, wiring setup, cell voltages, test duration, load state, and exact measurement points.
2. Verify whether the reported cell delta should enable balancing according to the design spec.
3. Measure balance path current or voltage drop before replacing hardware.
4. Measure standby/input current when the board is powered but idle.
5. Confirm UVLO/shutdown threshold and the cell voltage at transition.
6. Compare against a known-good module with the same cells and firmware.

## Output

- confirmed measurement facts and setup
- balance-enable branch: expected, disabled by threshold, active but weak, or hardware-open
- shutdown/drain branch: standby load, UVLO, or unknown
- missing thresholds, logs, measurements, and comparison data
