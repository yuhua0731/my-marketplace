# Boost Module Fault Taxonomy

## Passive Balance And Low-Cell Protection

- `hc_robotics.boost_module.passive_balance_no_action_low_cell_drain`
  - Product line: `unknown_or_new`; independent boost-module bench/corpus branch.
  - Typical symptom: two cell groups have visible voltage delta, passive balance shows no observable change after idle time, and the board can self-shutdown after overnight powered idle while the low cell drops further.
  - Primary evidence: per-cell voltage before/after, test duration, board sample ID, video or photo of meter readings, balancing current/path measurement, firmware threshold/config, and shutdown threshold.
  - Primary specialists: `boost-module`, `embedded-software`, `vision-media`.
  - Secondary specialists: `can-bus` only when boost telemetry is available.
  - Knowledge: `knowledge/passive-balance-no-action-low-cell-drain.md`.

## Protection Shutdown And Power-Key Latch Failure

- `hc_robotics.boost_module.protection_shutdown_power_key_latch_fail`
  - Product line: `unknown_or_new`; independent boost-module bench/corpus branch.
  - Typical symptom: boost module 1.1 under instantaneous high-power load, for example `400W`, enters protection shutdown while low input/battery voltage still exists, and then the power switch button has no effect or cannot power the board off.
  - Primary evidence: input/output/control rail voltage before and after protection, button signal, latch/enable pin, gate drive, load current, full waveform, and recovery/retest result.
  - Primary specialists: `boost-module`, `embedded-software`, `vision-media`.
  - Secondary specialists: `can-bus` only when boost telemetry is available.
  - Knowledge: `knowledge/protection-shutdown-power-key-latch-fail.md`.

## High-Load Transient Protection Restartable Shutdown

- `hc_robotics.boost_module.high_load_transient_protection_restartable_shutdown`
  - Product line: `unknown_or_new`; independent boost-module bench/corpus branch.
  - Typical symptom: boost module 1.1 under `400W` instantaneous load automatically shuts down while input/battery voltage is still present, for example `4.3V`, and can be manually powered on again.
  - Primary evidence: load-step voltage/current waveform, input/output/control rail measurements, protection threshold/spec, firmware state, and manual restart/recovery result.
  - Primary specialists: `boost-module`, `embedded-software`, `vision-media`.
  - Secondary specialists: `can-bus` only when boost telemetry is available.
  - Knowledge: `knowledge/high-load-transient-protection-restartable.md`.

## Evidence Status

- Keep `needs-assets` cases trainable when visible text and local videos establish a reusable pattern, but mark root cause blocked until board-level thresholds, current path, and firmware state are available.
- Generic words such as `关机`, `电压`, or `异常` are insufficient for routing to Ant/C134 power branches when the corpus is `boost-module`.
- For low-cell tests, under-voltage protection and standby current are safety-critical branches; do not run long idle tests without monitoring the low cell.
- For `无法断电` after protection shutdown, separate output shutdown from actual control/latch rail power-off; a dark load or protected output does not prove the switch path is working.
- For `自行关机` with successful manual restart, prioritize recoverable UVLO/overcurrent/hiccup behavior before power-key latch failure.
