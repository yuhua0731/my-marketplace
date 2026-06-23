# Boost Module High-Load Transient Protection Restartable Shutdown

source_set: `boost-module-pt-0095`
case_count: 1 focused boost-module 1.1 high-load transient shutdown case
status: runtime routing rules for recoverable self-shutdown during 400W transient load

## Symptoms

- Boost module 1.1 sample `A2-06` is tested under `400W` instantaneous load.
- Source says the boost board automatically shuts down while battery output voltage still has `4.3V`.
- Source says the board can be manually powered on again.
- Local scope thumbnail shows CH1 max `33.2V`, CH1 min `-800mV`; CH2 max `-400mA`, CH2 min `-30.0A`; time base `200ms`.
- Local bench thumbnail shows boost board, probe/line connections, load wiring, and a board label visually consistent with `A2-06`.

## Fault Tree

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

## Evidence Needed

- Full waveform or video frames covering load application, shutdown, manual restart, and recovery.
- Schematic/test spec for UVLO, overcurrent, current limit, short-circuit, hiccup/latch-off, and restart policy.
- Firmware version, ADC telemetry, protection state, and event logs.
- Node measurements after shutdown: input, output, control rail, enable/latch pin, gate drive, and current.
- Known-good board comparison under the same `400W` transient and low-input condition.
- Repeated test and post-fix result.

## Logs And Files To Inspect

- Case body: `cases/needs-assets/boost-module/0095-Gl8dw6NkOiqRMUksLxscZk6bnOe-2026-05-27-升压模块1.1-400W瞬时负载-升压板自行关机.md`.
- Scope video: `assets/boost-module-pt-0095/001-source-MaGEb4n3LoRmuvxrw9rcd4oWn7g.mp4`.
- Bench video: `assets/boost-module-pt-0095/002-source-BEPfbQ3yjouboaxVbB9chBuEnab.mov`.
- Search terms: `A2-06`, `升压模块1.1`, `400W瞬时负载`, `升压板自行关机`, `4.3V`, `可手动重新开机`, `33.2V`, `-800mV`, `-30.0A`, `UVLO`, `overcurrent`, `hiccup`, `restart`.

## Likely Causes To Test

- Designed UVLO or overcurrent protection threshold reached during the 400W transient.
- Input droop at the board terminal is lower than the reported battery-side `4.3V`.
- Current-limit/hiccup policy shuts output down but allows manual restart.
- Control rail remains valid, unlike a power-key/latch failure.
- Firmware threshold, blanking time, or recovery policy is too conservative for the intended transient load.

## Exclusion Checks

- Do not merge with passive-balance no-action unless balancing or overnight drain evidence appears.
- Do not merge with power-key latch failure unless the power switch becomes ineffective or rails remain stuck on.
- Do not route independent bench shutdown to Ant/C134 robot power branches.
- Do not treat remaining `4.3V` as abnormal without threshold and measurement-node evidence.
- Do not confirm root cause from a single QuickLook scope thumbnail.

## Confirmed Examples

- None yet. `boost-module-pt-0095` establishes a recoverable protection-shutdown triage path, but root cause remains unresolved because full waveform, thresholds, rail measurements, and retest are missing.

## Unresolved Examples

- `boost-module-pt-0095`: A2-06 boost board self-shuts down during `400W` instantaneous load while source reports battery output still `4.3V`; it can be manually powered on again. QuickLook confirms scope/bench evidence, but full transition waveform, threshold spec, telemetry, and repeated recovery test are not local.

## Specialist Routing

- `boost-module`: primary branch for UVLO, overcurrent, current-limit/hiccup, restart policy, load transient, and known-good comparison.
- `embedded-software`: protection state machine, ADC telemetry, thresholds, and recovery logic.
- `vision-media`: inspect scope video, bench video, probe scale, wiring, and manual restart action.
- `can-bus`: only if the board exposes CAN telemetry for voltage/current/protection state.
