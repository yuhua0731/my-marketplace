# Ant 3.0 ALLCAN Power And DM Camera Knowledge

source_set: `ant-3-test-pt-0127`, `ant-3-test-pt-0082`, `ant-3-test-pt-0083`, `ant-3-test-pt-0128`
case_count: 4 focused Ant 3.0 ALLCAN/DM camera/power cases
status: runtime routing rules for ALLCAN board reboot, DM camera decode, and boost-module power symptoms

## Symptoms

- Ant 3.0 stops abnormally while using ALLCAN-DM camera.
- ALLCAN-4 and camera report communication errors during initialization.
- ALLCAN-4 power indicator briefly drops/restarts; camera bottom fill light turns off.
- DM decode or scan rate is unstable at high speed.
- Boost or 24V power rail abnormality appears under load or initialization.

## Fault Tree

1. Separate DM decode performance from ALLCAN power reset.
   - `ant-3-test-pt-0082` / `0083` contain DM camera stop/decode investigation; source notes ALLCAN-DM decode speed averages near `25 ms`, Huaray camera near `22 ms`, and some high-speed MOVE windows lose scan results.
   - `ant-3-test-pt-0127` is a power/reset case, not a decode-speed case.
2. For ALLCAN/camera simultaneous communication errors, inspect 24V rail first.
   - `ant-3-test-pt-0127`: oscilloscope captured CAN1 24V output dropping from `24.4V` to `8.8V` for `10ms` during initialization.
   - Power board reboot was mostly excluded by comparison; ALLCAN-4 itself rebooted during initialization.
3. Inspect mechanical mounting and exposed copper before replacing software.
   - `ant-3-test-pt-0127` final cause: ALLCAN-4 mounting-area trace/exposed copper shorted to vehicle body through a copper standoff.
   - Fix: replace ALLCAN-4.
4. If boost-module output overcurrent appears under slope/load, separate boost capacity from downstream short/load.
   - `ant-3-test-pt-0128` has 30 kg climbing/boost-module overcurrent assets; review boost voltage/current and downstream ALLCAN/motor load before classifying as boost board defect.
5. For DM camera stop, inspect both decode timing and robot-motion command context.
   - If DM no-read occurs at high speed, compare scan result count, `decode_time`, speed, command path, and braking route.
   - Do not blame ALLCAN-DM solely from one no-read unless Huaray/other camera comparison and CAN timing support it.

## Evidence Needed

- Oscilloscope capture of CAN/ALLCAN 24V rail during initialization and movement.
- ALLCAN board mounting photos, screw/standoff contact points, and exposed copper inspection.
- NXP log around ALLCAN/camera communication errors and reset markers.
- CAN pcap showing heartbeat/state before and after ALLCAN reboot.
- Camera decode-time statistics, scan-result counts per DM code, robot speed, and route context.
- Boost-module voltage/current logs under load, especially 30 kg slope/climb tests.

## Logs And Files To Inspect

- `assets/ant-3-test-pt-0127/` board photos, oscilloscope screenshots, CAN/NXP logs.
- `assets/ant-3-test-pt-0082/` and `assets/ant-3-test-pt-0083/` DM camera screenshots/logs.
- `assets/ant-3-test-pt-0128/retry-source-*.log`
- `assets/ant-3-test-pt-0128/retry-source-*.pcap`
- Videos under the same asset directories for stop/restart timing.

## Likely Causes

- Exposed copper or mounting/standoff short causing ALLCAN-4 power drop and reboot.
- 24V rail transient dip during ALLCAN initialization.
- ALLCAN-DM decode timing insufficient or unstable at specific high-speed MOVE windows.
- Boost-module output overcurrent under load or downstream short/load branch.
- Camera fill-light/power loss caused by ALLCAN/24V instability, not camera decode itself.

## Exclusion Checks

- If 24V stays stable during initialization, do not use the ALLCAN mounting-short branch.
- If ALLCAN-4 and camera both reset together, inspect shared power/board first before decode algorithm.
- If only scan count drops while power and heartbeat are stable, route to vision/media + robot-motion decode branch.
- If Huaray camera works at the same DM code and speed, treat ALLCAN-DM performance or integration as higher probability.
- If boost overcurrent occurs only under 30 kg slope test, preserve load/slope condition; do not extrapolate to no-load behavior.

## Confirmed Examples

- `ant-3-test-pt-0127`: ALLCAN-4 and Huaray camera communication errors during initialization; CAN1 24V dropped from `24.4V` to `8.8V` for `10ms`; final cause was exposed copper near ALLCAN-4 mounting area shorting through copper standoff; ALLCAN-4 replacement was the recorded action.
- `ant-3-test-pt-0083`: high-speed ALLCAN-DM investigation records decode-time statistics and missing scan results in MOVE windows; source does not reduce it to board power failure.

## Unresolved Examples

- `ant-3-test-pt-0128`: boost-module output overcurrent under 30 kg climbing still needs full boost voltage/current and downstream load analysis before being promoted to confirmed root cause.
- `ant-3-test-pt-0082`: no abnormal stop reproduced in visible text; scan-rate optimization remains open.

## Specialist Routing

- `can-bus`: ALLCAN heartbeat/state, 24V rail, boost-module voltage/current, pcap timing.
- `embedded-software`: NXP reset and camera/ALLCAN communication state.
- `vision-media`: DM decode statistics, scan result count, camera comparison.
- `robot-motion`: speed/path/braking context around DM no-read.
