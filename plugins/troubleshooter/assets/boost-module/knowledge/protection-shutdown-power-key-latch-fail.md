# Boost Module Protection Shutdown Power-Key Latch Failure

source_set: `boost-module-pt-0092`
case_count: 1 focused boost-module 1.1 protection shutdown and power-key failure case
status: runtime routing rules for high-load protection shutdown followed by ineffective power switch

## Symptoms

- Boost module 1.1 sample `A2-08` is tested under instantaneous high-power `400W` load.
- Source says battery output still had `4.6V` when the module entered protection shutdown.
- After protection shutdown, the boost-module power switch button has no effect and the switch cannot power the module off.
- Local video thumbnail shows a bench setup with exposed board, wiring/load connection, and hand-held switch/button.
- Local scope thumbnail shows CH1 around max `38.4V`, min `24.8V`; CH2 around max `17.2A`, min `-400mA`; time base `200ms`.

## Fault Tree

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

## Evidence Needed

- Full waveform or video frames covering load application, protection shutdown, button press, and post-button rail state.
- Schematic/test spec for power-key, latch/enable, UVLO, overcurrent, discharge path, and protection recovery.
- Firmware version, ADC telemetry, protection state, and button event logs.
- Node measurements after protection: input, output, MCU rail, enable/latch pin, gate drive, and load current.
- Known-good board comparison under the same `400W` transient and low-input condition.
- Recovery method and repeated post-fix test.

## Logs And Files To Inspect

- Case body: `cases/needs-assets/boost-module/0092-XSgfwvHy8iykxmkSnV7crRxan4f-2026-05-26-升压模块1.1无法断电问题.md`.
- Bench video: `assets/boost-module-pt-0092/001-source-TAHJbjs2IodiKrxtmhwc4wc9nmd.mov`.
- Scope video: `assets/boost-module-pt-0092/002-source-F3I7bUXdGoakpzx1OH9cD23lnJh.mp4`.
- Search terms: `A2-08`, `升压模块1.1无法断电`, `400W`, `4.6V`, `保护停机`, `电源开关按钮无作用`, `开关无法断电`, `38.4V`, `24.8V`, `17.2A`, `-400mA`, `UVLO`, `latch`, `enable`, `power key`.

## Likely Causes To Test

- Low-voltage or overcurrent protection latches the board in a state where firmware still runs but refuses or misses key-off.
- Control rail falls below valid logic level, causing the MCU/button circuit to mis-sample the key.
- Hardware latch, enable MOS/transistor, or discharge path remains on after a key-off request.
- Backfeed from load/scope/test wiring keeps part of the board powered.
- Protection recovery strategy lacks a valid path for low-input, high-load shutdown state.

## Exclusion Checks

- Do not merge with passive-balance no-action unless balance thresholds or cell-drain behavior are present.
- Do not route independent bench tests to Ant/C134 robot reboot branches just because the symptom says `无法断电`.
- Do not conclude button hardware failure without measuring the button signal and latch/enable rails.
- Do not conclude firmware failure until hardware latch, backfeed, and rail validity are checked.
- Do not treat a dark output as full power-off; verify control rail and latch state.

## Confirmed Examples

- None yet. `boost-module-pt-0092` establishes a reusable triage path, but root cause remains unresolved because the full waveform, rail measurements, thresholds, and recovery test are missing.

## Unresolved Examples

- `boost-module-pt-0092`: A2-08 boost board enters protection shutdown during `400W` instantaneous load while the source reports battery output still at `4.6V`; afterward the power switch button is ineffective. QuickLook confirms bench/scope evidence, but full transition waveform, button/latch measurements, firmware thresholds, and retest are not local.

## Specialist Routing

- `boost-module`: primary branch for UVLO, overcurrent, latch/enable hardware, switch path, load transient, and known-good comparison.
- `embedded-software`: protection state machine, key-event sampling, ADC telemetry, thresholds, and recovery logic.
- `vision-media`: inspect bench video, scope video, button action, wiring, and possible backfeed path.
- `can-bus`: only if the board exposes CAN telemetry for voltage/current/protection state.
