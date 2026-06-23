# Component Test Troubleshooting Playbook

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
- Shutdown blocked after robot lock/manual lock: scheduler-traffic first, then embedded state-machine only if logs show command/state failure.
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Mechanical scrape, bracket contact, drag-chain sag, rail interference: vision-media first, then robot-motion/hardware evidence; embedded only if motion logs implicate control behavior.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## Component Test ALLCAN-DM Dirty Floor-Code Loss Knowledge

Knowledge file: `docs/component-test/knowledge/allcan-dm-dirty-floor-code-loss.md`

### First Checks

1. Confirm whether the failure is a localization/no-read event before analyzing motor or CAN causes.
   - In `component-test-pt-0084`, the NXP failure reason is `DIFF_DRIVE_ERROR#MOVER_MOTOR#DM code lost`.
   - The failure occurs after 3018.990582 mm without barcode update, while the robot was moving about `2001.108643 mm/s`.
2. Compare scan-rate statistics by route direction.
   - Route columns alternate direction. Do not treat every zero as abnormal before checking the active direction.
   - `(100010, 114000)` had only 3 hits across 24 values, with 21 zeros. Nearby rows such as `(100010, 111000)` and `(100010, 110000)` had 19 and 18 total hits.
   - For `component-test-pt-0085`, the failing command column `SMOOTH-2026-04-17T17:44:39.255647-3` covers `(99000,104000)->(99000,138000)` and shows normal reads through `(99000,112000)`, then zeros from `(99000,113000)` through `(99000,138000)`. This points to a route-segment read-gap branch even when the final stop pose looks centered.
3. Inspect the exact floor-code surface.
   - `100010GG114000` photo shows dirt/smear at the lower QR area and a worn label surface.
   - This supports a local readability branch; it does not by itself prove camera hardware failure.
   - In `component-test-pt-0085`, stop photos show the robot roughly centered over/near a floor code, so visible pose does not explain the loss; inspect the upstream route segment instead of only the final stop photo.
4. Check whether reads resume after the DM-lost threshold.
   - In this case, barcode reads resume immediately after the error, around `100014.100,112948.200` and then down toward `100010,111xxx`.
   - Treat this as intermittent route-segment readability loss, not complete camera outage.
5. Verify repair by repeat scan statistics and NXP log.
   - After reprinting/replacing low-success floor codes including `(100010, 114000)`, the follow-up screenshot shows the row mostly restored to `1` or `2` hits.
   - Follow-up NXP log from 2026-04-17 09:04-09:34 contains successful commands and no local `DM LOST` / `DM code lost` match in the checked window.
6. Keep recurrence separate.
   - The source links a later 2026-04-17T17:44 DM-lost stop as a separate case. Do not claim the whole route is fixed from the 30-minute follow-up alone.

### Evidence

- NXP log around the stop timestamp with `DM LOST`, barcode updates, command label, and failure reason.
- Scan-rate CSV or screenshot with route columns and per-code hit counts.
- Clear photo of the exact suspected floor code, not only the displayed stop code.
- Stop-position photos to check whether the robot body is visibly skewed, but do not use them alone to exclude floor-code/read-gap causes.
- Follow-up scan-rate screenshot or CSV after cleaning/reprint/replacement.
- Follow-up NXP log covering repeated passes through the same segment.
- CAN pcap/candump only when motor/CAN branch remains plausible after localization evidence.

### Exclusions

- If the failing code row has normal hit counts in the active direction, do not blame the floor code only from a dirty-looking photo.
- If multiple adjacent codes drop together after reprint, inspect camera exposure, mounting angle, lens cleanliness, lighting, or route geometry.
- If the final stop photo shows a centered robot, do not exclude DM code loss; compare the last valid barcode update with the failed command path.
- If NXP shows no `DM LOST` / `DM code lost`, route to the actual failure reason instead.
- If a pcap is present but the local decoder shows `UNSUPPORTED`, mark CAN evidence blocked; do not use it to confirm or exclude CAN.
- If repair is validated only by a short follow-up window, keep long-run recurrence open.

### Examples

- `component-test-pt-0084`: Ant 3.0 stopped at 2026-04-14T20:21. NXP shows `DM LOST, distance without barcode update: 3018.990582 mm`; command `SMOOTH-2026-04-14T20:20:58.072193-7` failed with `DM code lost`. CSV shows `(100010, 114000)` had only 3 hits across 24 values. Photo of `100010GG114000` shows dirt on the QR area. After reprinting low-success codes, follow-up screenshot shows improved `(100010, 114000)` reads and checked follow-up NXP log shows no DM-lost failure in the sampled 30-minute window.
- `component-test-pt-0085`: Ant 3.0 stopped at 2026-04-17T17:44. NXP log creates command set `A4882-SMOOTH-2026-04-17T17:44:39.255647`; command `-3` is a MOVE from `(99000,104000)` toward `(99000,138000)`. At `2026-04-17T09:44:52Z` the log reports `DM LOST, distance without barcode update: 3019.943833 mm`; at `2026-04-17T09:44:54Z` `SMOOTH-2026-04-17T17:44:39.255647-3` fails with `[WARNING]1202#DIFF_DRIVE_ERROR#MOVER_MOTOR#DM code lost`, and commands `-4` through `-15` are cancelled. The CSV/screenshot shows the failing route column reads through `(99000,112000)` and then zeros from `(99000,113000)` through `(99000,138000)`. Stop-position photos show the robot body roughly centered, supporting the source note that the body did not visibly run off course, but not excluding a route-segment barcode read gap.

- `component-test-pt-0084`: CAN pcap `007-source-NRTebBrJioNMvsxFAGgcvMQqnZe.pcap` was downloaded but local `tcpdump` rendered frames as `UNSUPPORTED`; CAN state transitions remain unreviewed.
- `component-test-pt-0084`: later 2026-04-17T17:44 DM-lost stop is linked as a separate case, so the 2026-04-17 09:30 follow-up does not prove full-route permanent recovery.
- `component-test-pt-0085`: no local photo of the exact upstream floor codes `(99000,113000)` through `(99000,138000)` is present, and no final fix/retest evidence is present beyond the source note `暂无发现异常停机`.

## ALLCAN-DM SD-Card Update Interrupted By Power-Baseboard Secondary Power-On

Knowledge file: `docs/component-test/knowledge/allcan-dm-flash-power-cycle-reset.md`

### First Checks

1. Start with power/reset stability during the update window.
   - `component-test-pt-0056`: source says whole-Mantis power-on triggers secondary power-on from the power baseboard.
   - DM restarts during that event.
   - If the SD-card update has already started, the restart can interrupt the update state.
2. Verify whether the update was done under isolated DM power.
   - Workaround A: use an external 24V power supply to power DM independently.
   - Workaround B: send power-on / power-off commands to the power baseboard to control DM power timing.
3. Treat as field-update process risk.
   - Source says both solutions are cumbersome and temporarily cannot completely solve the problem.
   - A release-ready fix should reduce the field sequence to a reliable, documented, low-step procedure.
4. Keep runtime ALLCAN-DM branches separate.
   - This case is about update-time reset/power sequencing.
   - It does not contain `DM code lost`, scan-rate, floor-code, or navigation failure evidence.

### Evidence

- DM power rail and reset timing during whole-Mantis power-on and the baseboard secondary power-on.
- DM boot/update log or SD-card update progress/failure code.
- Power-baseboard command log showing power-on/power-off timing.
- Exact firmware/update package version and SD-card update steps.
- Confirmation that external 24V or controlled baseboard command sequence lets the same update complete.
- Final validated field procedure or design change; current source says it is not fully solved.

### Exclusions

- Do not blame firmware image, SD-card contents, or update tool first until DM power/reset stability is proven.
- Do not route to ALLCAN-DM dirty floor-code/no-read diagnostics without runtime navigation evidence.
- Do not route to ALLCAN-LED/J-Link flashing diagnostics; this is an ALLCAN-DM SD-card update and power sequencing issue.
- Do not diagnose CAN bus communication failure without CAN logs, heartbeat/SDO errors, or bus captures around the update.
- Do not claim full resolution while the only known methods remain external 24V supply or manual baseboard power commands.

### Examples

- `component-test-pt-0056`: G楼螳螂3.0 and C144 螳螂3.0 need SD-card insertion when updating ALLCAN-DM. After whole-Mantis power-on, the power baseboard performs secondary power-on, DM restarts, and update/flashing becomes abnormal. Current workarounds are external 24V independent DM power or explicit power-baseboard up/down commands to control DM power timing.

- `component-test-pt-0056`: missing power/reset waveform, DM update log, power-baseboard command log, firmware package version, post-workaround success evidence, and final simplified field procedure.

## ALLCAN-LED ESP Flash Tool Crash

Knowledge file: `docs/component-test/knowledge/allcan-led-esp-flash-tool-crash.md`

### First Checks

1. First split: GUI/tool crash versus actual ESP flashing failure.
   - `component-test-pt-0011`: source says the flash tool directly exits and cannot flash ALLCAN-LED `esp` firmware.
   - Video frames show `嵌入式烧录助手` with `Wled-esp8266`, `COM13`, `921600`, address `0x00000000`, device name `ESP8266`, and selected `wled.bin`.
   - Later representative frame no longer shows the GUI and shows the app folder containing `flash_tool.exe`.
2. If direct `esptool.exe` succeeds, prioritize wrapper/runtime.
   - Video background PowerShell shows `esptool.exe --chip esp8266 --port COM13 --baud 460800 write_flash -z 0x0 .\wled.bin`.
   - Visible output includes `Connected to ESP8266 on COM13`, `Hash of data verified`, and `Hard resetting via RTS pin...`.
   - This points away from target hardware as the first branch and toward GUI subprocess handling, argument construction, packaged runtime, or exception handling.
3. Check parameter mismatch.
   - GUI shows baud `921600`, while the visible CLI command uses `--baud 460800`.
   - Confirm which baud the GUI actually passes to `esptool.exe`.
4. Keep J-Link/STM failures separate.
   - ESP8266/WLED flashing uses serial bootloader + `esptool.exe`.
   - J-Link/STM ALLCAN-LED flashing uses SWD/J-Link and has different DLL/verify failure branches.

### Evidence

- Flash-tool stdout/stderr, crash traceback, Windows Event Viewer entry, or dump file.
- Exact GUI action sequence and click-to-crash timestamp.
- Flash tool version, package contents, Python/PyInstaller or GUI framework runtime details.
- Actual command line launched by the GUI, including port, baud, address, and firmware path.
- Direct `esptool.exe` run result from the same machine/board/COM port.
- Target board photo, boot-mode wiring, USB-UART adapter, power source, and post-flash firmware behavior.

### Exclusions

- Do not classify as board/ESP failure if direct `esptool.exe` writes and verifies data on the same port.
- Do not classify as CAN failure; ESP flashing is serial bootloader work.
- Do not reuse J-Link DLL/verify rules unless the failing path is STM/J-Link/SWD.
- Do not accept GUI disappearance alone as root cause; require crash logs for final fix.
- Do not declare success without post-flash firmware behavior, even if esptool reports verified data.

### Examples

- `component-test-pt-0011`: source reports ALLCAN-LED ESP firmware flash tool exits directly. Video frames show the GUI configured for `Wled-esp8266`, `COM13`, `921600`, address `0x00000000`, `ESP8266`, and `wled.bin`; background PowerShell shows direct `esptool.exe` flashing on `COM13` with `--baud 460800`, `Hash of data verified`, and `Hard resetting via RTS pin...`.

- `component-test-pt-0011`: missing crash log, exact GUI-launched command, post-flash target verification, board/adapter photo, and tool version/source.

## ALLCAN-LED Flash Tool J-Link And Verify Failures

Knowledge file: `docs/component-test/knowledge/allcan-led-flash-tool-jlink-verify-failures.md`

### First Checks

- Branch A: host/J-Link runtime environment failure before programming.
  - Source says flashing P2575-A3 LED STM firmware through J-Link reported `Failed to connect to JLink: Expected to be given a valid DLL`.
  - Local screenshot shows flash tool device type `ALLCAN-led`, device names `STM32L431RC` and `M32L4xx_QSPI`, and file/address rows `bootloader.bin` at `0x08000000`, `zephyr.signed.bin` at `0x0800A000`, and `config.bin` at `0x90000000`.
  - The same screenshot background shows PyInstaller loader debug lines and `JLink_x64.dll already exists`, so inspect packaged DLL loading/path first.
- Branch B: programmed data verify failure after write.
  - Source says J02A20MN repeatedly reported `Error while verifying programmed data`.
  - Source says after power-cycling the robot, LED color changes indicated the STM program had actually been burned successfully.
  - Source later says repeated flashing of J02A20MN still reported verify failure.
- Likely hardware/noise branch for verify failure.
  - Source analysis says multiple ALLCAN-LED boards were tested: some flashed successfully, some always reported failure.
  - Source conclusion: actually burned successfully, but content verification failed; current judgment is board-level interference.
- Blocked branch: exact electrical interference and verify-read path.
  - No raw J-Link log, SWD waveform, power rail capture, board revision, or full verify dump is present.

### Evidence

- Raw flash-tool log including J-Link DLL path, J-Link serial, J-Link software version, flash package path, and command line.
- Raw J-Link/JLinkExe log for connect, erase, program, reset, and verify phases.
- Board ID, hardware revision, power source, cable length, connector orientation, and grounding setup for both passing and failing boards.
- Verify-read address range and first mismatch address/data.
- Power rail and reset/SWD signal capture during verify phase.
- Post-flash functional proof: LED behavior, reported firmware version, or successful application boot after power cycle.
- Missing original screenshot for the first DLL error branch if deeper UI details are needed.

### Exclusions

- Do not treat `Expected to be given a valid DLL` as board hardware failure; it occurs before a valid J-Link connection/program sequence.
- Do not treat verify failure as total programming failure if post-power-cycle LED behavior or version check proves the firmware booted.
- Do not declare success only from LED color; require firmware version or application behavior when available.
- Do not blame only the PC/J-Link if some boards consistently fail verify while others succeed under the same host and tool.
- Do not replace boards without checking SWD connection, power stability, ground, fixture contact, cable length, board revision, and verify mismatch address range.

### Examples

- `component-test-pt-0078`: P2575-A3/ALLCAN-LED flashing reported `Failed to connect to JLink: Expected to be given a valid DLL`; changing computer, running flash tool as administrator, changing J-Link hardware, uninstalling J-Link software, restarting software, and repeated flashing did not resolve initially. Later another computer successfully flashed J02A11MN LED. J02A20MN repeatedly reported `Error while verifying programmed data`; after robot power cycle, LED color change suggested STM firmware had actually been flashed. Source analysis says some ALLCAN-LED boards flash successfully while others keep reporting failure, likely because board interference causes verify failure.

- `component-test-pt-0078`: raw J-Link logs, verify mismatch address/data, board revision comparison, power/SWD captures, missing first screenshot asset, and final hardware fix are not present.

## ALLCAN-S CAN Transceiver Failure

Knowledge file: `docs/component-test/knowledge/allcan-s-can-transceiver-failure.md`

### First Checks

1. Confirm basic board power first.
   - Measure MCU 3.3V rail.
   - Measure CAN transceiver 5V rail.
   - If either rail is missing or unstable, resolve power before replacing the CAN transceiver.
2. Confirm CAN scan setup.
   - Use CANAble or equivalent adapter, correct bitrate, wiring, and terminal resistor.
   - If the scan tool finds no node while power rails are normal, prioritize the CAN physical-layer branch.
3. Replace or isolate the CAN transceiver.
   - If replacing the transceiver restores node discovery, treat the transceiver as confirmed failed.
   - If replacement does not restore the node, continue with MCU firmware, CAN termination, wiring, soldering, ESD/overstress, and clock/reset checks.
4. Check version/known-issue context.
   - If the case matches a known ALLCAN-S issue and the source says `V07` fixes it, record hardware/software version and apply the known repair path.
   - Do not assume all ALLCAN-S bus errors are the same V07-fixed issue without power and scan evidence.

### Evidence

- Photos or meter readings for MCU 3.3V and CAN transceiver 5V rails.
- CAN node scan before repair showing no nodes found.
- CAN node scan after repair showing the expected node IDs.
- Board labels, node IDs, hardware version, and firmware/version context.
- Repair record identifying the replaced chip, for example CAN transceiver `U4`.
- Video or screenshot of indicator behavior and scan procedure when available.

### Exclusions

- If MCU 3.3V is absent, do not replace the CAN transceiver before diagnosing power/regulator/MCU power.
- If CAN transceiver 5V is absent, check supply path and connector before declaring chip damage.
- If CANAble bitrate, termination, or wiring is unverified, do not treat "未找到节点" as board failure.
- If only one board fails and replacement does not restore scanning, inspect soldering, connector, MCU firmware, boot state, and oscillator/reset.
- If all nodes are found after repair, do not continue into firmware/CANopen state branches unless application-level communication still fails.

### Examples

- `component-test-pt-0114`: Amazon returned four ALLCAN-S boards with node labels `7`, `8`, `11`, and `12`; after power-on the CAN communication indicator alternated green/orange quickly, described as CAN bus error.
  - Source table: MCU voltage measured at component `U4` pin 5 was `3.29V`, marked pass.
  - Source table and photo: CAN transceiver voltage measured at `U4` pin 3 was `5.32V`, marked pass.
  - Source table: using CANAble with terminal resistor and node scan tool found no node before repair, marked fail.
  - Source resolution: replacing CAN transceiver chip `U4` restored normal behavior.
  - Repair verification screenshot at `1000000 bps` shows nodes found: `8`, `7`, `12`, and `11`, then scan complete.
  - Source states this matched a known issue and `V07` version has fixed it.

- `component-test-pt-0114`: raw CAN scan logs and oscilloscope/CAN waveform captures are not local; pre-repair "no node found" is from source table and video/visual evidence.
- `component-test-pt-0114`: the exact electrical overstress path that damaged the transceivers is not identified locally.

## Baffle Drop Wheel Jam Encoder Abnormal And Motor Short

Knowledge file: `docs/component-test/knowledge/baffle-drop-wheel-jam-encoder-short.md`

### First Checks

1. Establish physical jam before treating the fault as pure CAN communication loss.
   - Source resolution says `挡板掉落，卡住行走轮导致，已恢复`.
   - If the baffle or debris physically jams the driving wheel, the motor/encoder alarms can be consequence signals rather than the initiating CAN fault.
2. Use encoder abnormal evidence as the first log branch.
   - In `retry-source-OD9ebLeExon7CgxpjjgcTcgbngc.log`, `2026-05-09T01:51:30.964+0800` shows `error_phy_cal_pos[1]`.
   - The same log has 16 `error_phy_cal_pos` lines.
   - Screenshot evidence shows `ERROR ENCODER ABNORMAL ERROR` for `I39B45S` at `01:51:31`, `01:51:32`, and `01:51:36`.
3. Then inspect motor disable / CAN emergency / short branch.
   - `retry-source-OD9...log` shows `2026-05-09T01:51:39.698+0800` `statusword:4920` (`0x1338`) and `main motor disable detected`.
   - `retry-source-TGt...log` shows `2026-05-09T01:51:39.978+0800` `statusword:4664` (`0x1238`) and `main motor disable detected`, then repeated `statusword:4664` and disable detections.
   - The UI alarm screenshot shows `主电机CAN总线紧急事件` and `短路` starting at `01:51:40`.
4. Separate the two robots.
   - `I39B45S` has encoder abnormal alarms before the short/CAN emergency alarms.
   - `I39B67S` appears in later short/CAN emergency alarms after the source-reported collision with `45S`.
   - Do not merge both robots into one electrical root cause without per-robot logs or CAN frames.
5. Verify recovery as mechanical restoration plus CAN/motor state recovery.
   - Both local logs later show startup and CAN motor init returning normal: `CAN_MOTOR_STATE_WAIT_INIT_ON` then `CAN_MOTOR_STATE_NORMAL` around `2026-05-09T09:35`.
   - This supports recoverability after intervention, but does not by itself identify whether any encoder wheel/motor component was replaced.

### Evidence

- Photo or video of the dropped baffle and jammed driving wheel before restoration.
- Physical inspection result for `I39B45S` encoder wheel, encoder sensor, driving wheel, baffle bracket, and harness.
- Per-robot mapping from the two downloaded log files to `I39B45S` and `I39B67S`.
- Raw CAN candump/pcap around `2026-05-09 01:51:30` to `01:51:44`, with node IDs and EMCY/statusword frames.
- Repair details: whether the baffle was reinstalled, encoder wheel adjusted/replaced, motor reset, wiring repaired, or only obstruction cleared.
- Retest evidence after restoration under the same baffle/drive-wheel motion.

### Exclusions

- Do not classify this as only `CAN_MOTOR_ERROR` or motor communication loss when `ERROR ENCODER ABNORMAL ERROR` and physical baffle/wheel jam evidence exist.
- Do not replace motor/CAN parts before inspecting the fallen baffle, driving wheel, encoder wheel, encoder sensor, and nearby harness.
- Do not treat `主电机CAN总线紧急事件` as proof of CAN-layer root cause; motor/drive EMCY can be a consequence of mechanical jam or overload.
- Do not merge `I39B45S` and `I39B67S` into one identical fault branch; analyze the first abnormal robot and collision sequence separately.
- Do not use the 09:35 `CAN_MOTOR_STATE_NORMAL` recovery alone as proof that encoder/mechanical risk is cleared; require physical repair and retest evidence.

### Examples

- `component-test-pt-0135`: source says CS002 `67S` collided with `45S` and caused abnormal stop. Source analysis says `I39B45S` had abnormal encoder position and may have collided with `I39B67S`, causing motor short-circuit alarm; it asks to inspect `I39B45S` encoder wheel and encoder. `retry-source-OD9...log` shows `2026-05-09T01:51:30.964+0800` `error_phy_cal_pos[1]`, followed by more `error_phy_cal_pos` lines and `ROBOT_HALT_STATE`. Alarm screenshot shows `I39B45S` `ERROR ENCODER ABNORMAL ERROR` at `01:51:31`, `01:51:32`, and `01:51:36`; at `01:51:40` to `01:51:44`, `I39B45S` and `I39B67S` report `主电机CAN总线紧急事件` and `短路`. `retry-source-OD9...log` shows `statusword:4920` (`0x1338`) and `main motor disable detected` at `01:51:39.698`; `retry-source-TGt...log` shows `statusword:4664` (`0x1238`) and `main motor disable detected` at `01:51:39.978`, then repeated disable detections. Source follow-up says the baffle dropped and jammed the driving wheel, and the issue was restored.

- `component-test-pt-0135`: local evidence does not include photo/video of the actual fallen baffle or jammed wheel, mapping of each log file to robot label, raw CAN candump/pcap, exact motor node IDs, encoder inspection photos, repair details, or retest duration. The case supports a strong mechanical-jam-first diagnostic branch but does not prove whether encoder hardware was damaged or only obstructed.

## Baffle Motor CAN Communication Loss And Recovery Failure

Knowledge file: `docs/component-test/knowledge/baffle-motor-can-communication-loss.md`

### First Checks

1. Separate main walking motor CAN loss from baffle actuator CAN loss.
   - CS002 branch: source says walking motor temperature and voltage data stopped reporting and communication disconnected.
   - S209 branch: baffle motor communication abnormal caused baffle-up command failure.
2. Anchor on the last valid telemetry before the fault.
   - Screenshot evidence shows repeated main motor telemetry such as `main motor temp: 75764, voltage: 27088`, followed by `CAN_MOTOR_ERROR`.
   - Raw-log evidence in `component-test-pt-0087` shows `main motor temp: 76732, voltage: 26689` starting at `2026-04-14T21:06:09.359+0800`, then persisting more than 10,000 times through `2026-04-14T23:59:59.737+0800`.
   - Treat repeated identical telemetry before the error as possible stale data; require raw logs to prove whether the motor was still reporting live values.
3. Inspect command/state transition around the actuator failure.
   - S209 screenshot shows `BAFFLE_RUN_UP_START`, then `set_flow_motor_baffle_turn error`.
   - Recovery screenshot shows `BAFFLE_RUN_RECOVERY`, `retry_baffle_send`, and repeated `lifter sensor block: 181551`.
4. Check wiring and connector branches before firmware changes.
   - Source conclusion explicitly says both issues are motor communication abnormal and motor wiring should be checked.
   - Inspect motor power/CAN connector seating, cable strain, shielding, termination, node connector, and intermittent harness movement.
   - If bus resistance is around `112.4Ω`, do not stop there; the source marked it normal, but the frozen telemetry still requires node-side wiring, connector, power, and raw CAN checks.
5. Use raw logs/CAN frames to decide cause direction.
   - If CAN heartbeat/SDO/PDO stops before command failure, prioritize physical bus or node power.
   - If CAN remains healthy but command returns actuator error, inspect baffle state machine, sensor block, and actuator calibration.
   - If only screenshots exist, keep cause as likely communication/wiring, not confirmed CAN physical-layer failure.

### Evidence

- Raw robot/NXP/shuttle MQTT logs around the fault, not only screenshot snippets.
- CAN candump/pcap around the stop, with heartbeat, PDO/SDO, node ID, and error frames.
- Exact robot IDs, library/project, firmware version, motor node ID, and actuator node ID.
- Photos or inspection notes for motor CAN cable, power cable, connector, terminal resistor, and harness strain points.
- Recovery logs showing whether `BAFFLE_RUN_RECOVERY` succeeds, retries, or fails permanently.
- Retest evidence after cable reseating/replacement or controller/motor swap.
- Bus resistance measurement point and power-off state when measuring resistance.

### Exclusions

- Do not treat screenshots alone as proof of physical CAN-layer failure; require raw CAN/log evidence for confirmation.
- Do not merge CS002 walking-motor communication loss and S209 baffle-up failure into one identical root cause unless wiring or node evidence links them.
- Do not diagnose scheduler/traffic unless commands are valid and motor/CAN telemetry remains healthy.
- Do not replace the baffle motor before checking cable, connector, termination, node power, and recovery logs.
- If telemetry values continue changing normally after the reported failure, inspect state-machine or actuator command errors before CAN wiring.
- If CAN-bus resistance is near the expected value, do not exclude intermittent connector, node power, or single-node communication loss.

### Examples

- `component-test-pt-0086`: visible source text says CS002 `67S` baffle robot stopped abnormally with CAN communication exception; walking motor temperature and voltage data stopped reporting and communication disconnected. Screenshot evidence shows `CAN_MOTOR_ERROR` after repeated `main motor temp: 75764, voltage: 27088`. Source also says S209 `401S` failed to send baffle-up command; screenshot evidence shows `BAFFLE_RUN_UP_START` followed by `set_flow_motor_baffle_turn error`, then recovery state `BAFFLE_RUN_RECOVERY` with repeated `lifter sensor block: 181551`. Source conclusion: both problems are motor communication abnormal and motor wiring should be checked.
- `component-test-pt-0087`: source text says CS002 `67S` baffle robot stopped because of main-motor CAN communication abnormality; main motor temperature and voltage were not updating; recovery failed; bus resistance measured `112.4Ω` and was considered normal. Raw log `004-source-ABBhbAzmEoTmvlxvthtcme3Wnxd.3` shows `2026-04-14T21:06:09.774+0800` `CAN_MOTOR_STATE_SET_ZERO_SPEED`, `21:06:10.794+0800` `CAN_MOTOR_STATE_GET_ZERO_SPEED_STATE`, `21:06:11.613+0800` `CAN_MOTOR_ERROR`, statuswords `5688` (`0x1638`) and `4664` (`0x1238`), then `belt_servo_reset_error` and repeated `servo_reset_error`. The same `main motor temp: 76732, voltage: 26689` value appears 10,375 times through `2026-04-14T23:59:59.737+0800`, supporting stale/frozen telemetry after the CAN fault.

- `component-test-pt-0086`: only screenshots are local. Raw text logs, CAN frames, motor node IDs, cable inspection results, exact repair, and retest evidence are missing. The case supports a high-value motor CAN/wiring diagnostic branch but does not prove the exact electrical failure point.
- `component-test-pt-0087`: raw robot log and resistance photo are local, but raw candump/pcap, node ID, exact connector measurement point, repair action, and retest evidence are still missing.

## Baffle Raise Pause Completion Flag Recovery Failure

Knowledge file: `docs/component-test/knowledge/baffle-raise-pause-completion-flag-recovery.md`

### First Checks

1. Reconstruct the handling sequence before blaming hardware.
   - Look for loading/throw failure, force-unload/recovery, move, baffle-up, pause, resume, and next loading attempt.
   - In `component-test-pt-0117`, the case body reports throw failure followed by recovery, then loading failure because the baffle was raised.
2. Check whether baffle-up is coupled to movement-state completion.
   - If `BeltGateFSM::Up` or equivalent baffle-up transition completes after movement has already been interrupted or paused, verify where the completion flag is set.
   - Completion must be set when the baffle-up state completes, not only while the parent movement state is active.
3. Treat pause/resume as an interleaving branch.
   - Pause during actuator motion can suppress state-specific completion handling if the event is only consumed in the original movement state.
   - Recovery code must either consume late actuator-complete events in pause/recovery states or persist actuator completion independently of the movement state.
4. Separate state-machine defect from communication or mechanical faults.
   - If the baffle motor reports completed `UP`, CAN/motor command path is not the primary suspect.
   - If the next loading fails only because the baffle is raised, inspect state flags and recovery sequencing before motor replacement.
5. Validate with both failure and post-fix evidence.
   - The source resolution is to set completion status when baffle raise state completes.
   - Follow-up says the fix was verified.

### Evidence

- Case body analysis and exact reported timestamp.
- NXP or controller log covering loading fault, recovery/force-unload, next move, baffle-up, and next loading attempt.
- Failure video and post-fix video or representative frames showing baffle position and status light.
- Source diff or firmware trace proving where the baffle-up completion flag is written.
- Pause/resume reproduction where pause is pressed while baffle-up is still moving.
- Raw CAN/candump only if actuator command or feedback timing remains suspect after state-machine review.

### Exclusions

- Do not diagnose baffle motor CAN communication loss solely from repeated `0x6064` SDO errors unless CAN heartbeat/SDO/PDO timing proves the motor failed to execute or report baffle-up.
- Do not diagnose mechanical jam if logs show baffle-up completion and the failure is an incorrect next-state/retry decision.
- Do not blame scheduler/task assignment until embedded handling state and baffle completion flags are proven correct.
- Do not claim fix validation from a single still frame; require source follow-up, log sequence, or repeat test.

### Examples

- `component-test-pt-0117`: source text says throw failure recovery left the baffle raised and caused loading failure. Source analysis identifies pause before baffle-up completion and completion flag being set only in movement state. Source resolution is to set completion when baffle-up state completes. Local NXP log shows loading fault, recovery/force-unload, next loading/move, `BeltGateFSM::Up`, and `Gate status set to: UP` in the inspected window. Follow-up says the fix was verified.

- `component-test-pt-0117`: source diff/commit is absent; pause command is not decoded as readable log text; video was inspected through representative QuickLook frames because local `ffmpeg`/`ffprobe` are unavailable; repeated `0x6064` SDO upload errors remain uncorrelated background evidence.

## Baffle Robot Lift Anti-Pinch And Motor Low-Voltage Stop

Knowledge file: `docs/component-test/knowledge/baffle-robot-lift-anti-pinch-low-voltage.md`

### First Checks

1. Establish the physical sequence first.
   - Use CCTV/video to confirm whether the robot entered the lift area before the anti-pinch event.
   - Use UI event time to anchor the sequence; in this case the event is `2026-04-02 11:35:06`.
2. Correlate robot hardware alarm with lift protection.
   - If a robot alarm occurs within seconds of the lift protection event, inspect motor-power and controller-power branches before treating the lift sensor as the root cause.
   - In this case the hardware alarm is at `2026-04-02 11:35:08`, two seconds after the anti-pinch UI event.
3. Decode the hardware alarm but keep raw evidence limits explicit.
   - Source analysis states `SHUTTLE CAN ERROR 12577` maps to `0x3121`, main-motor low-voltage.
   - Without raw CAN/NXP/controller logs, this code supports a low-voltage branch but does not prove whether the low voltage caused the collision or was caused by collision/stop impact.
4. Inspect power delivery before replacing motion components.
   - Check main-motor power cable looseness, connector seating, cable movement under lift/robot motion, and intermittent voltage drop.
   - Check motherboard power output to the main motor.
5. Separate lift anti-pinch from robot motion root cause.
   - The lift anti-pinch event may be a protection response to physical interference, not the initiating failure.
   - If motion logs show the robot was commanded into the lift envelope, route to scheduler/traffic or motion planning.
   - If power logs show voltage drop before the robot failed to clear the lift, route to CAN/embedded/power.

### Evidence

- UI event screenshot with exact anti-pinch event text and timestamp.
- Robot hardware alarm screenshot or log with robot ID, timestamp, alarm name, and alarm code.
- CCTV/video around at least 30 seconds before and after the anti-pinch event.
- Raw robot/NXP/CAN logs around the event, including motor voltage, controller voltage, CAN state, and motor fault code.
- Physical inspection photos of motor power cable, connector, motherboard output, lift channel clearance, and anti-pinch sensor.
- Repair or retest evidence after tightening cable, replacing cable/connector, or checking motherboard output.

### Exclusions

- Do not treat `D端提升机移动时防夹车触发` as the root cause by itself; it may be a protection result after physical interference.
- Do not conclude motor low voltage caused the collision unless voltage/CAN evidence precedes the physical interference.
- Do not classify as Ant localization only because the source mentions a collision; require DM/pose/path evidence before using DM-code or localization branches.
- Do not replace the lift anti-pinch sensor before checking robot power alarm timing and physical interference.
- If raw CAN/NXP logs are missing, keep CAN state-transition analysis open.

### Examples

- `component-test-pt-0080`: source text says that after CS002 ran for a period, baffle robot `I39B71S` hit the rising-end lift at `11:35`, triggering anti-pinch vehicle protection and stopping equipment. UI screenshot shows `D端提升机移动时防夹车触发` at `2026-04-02 11:35:06`; hardware alarm screenshot shows `I39B71S`, `2026-04-02 11:35:08`, `SHUTTLE CAN ERROR 12577`; source analysis maps `12577 -> 0x3121` to main-motor low-voltage and lists possible causes as loose motor power cable or abnormal motherboard power output.

- `component-test-pt-0080`: available CCTV playback shows the lift aisle and robot position around the event, but the exact contact point is partly occluded by the structure and playback UI. Raw CAN/NXP logs, motor voltage traces, wiring inspection results, motherboard output measurements, and post-repair retest are not local.

## Lift Motor Enable Failure With Encoder Er.C90

Knowledge file: `docs/component-test/knowledge/lift-motor-enable-fail-encoder-c90.md`

### First Checks

1. Confirm the drive-local alarm.
   - UI `使能失败` is a symptom at the control layer.
   - `Er.C90` on the servo drive maps the failure to encoder communication/disconnected-line branch.
2. Check encoder wiring and connector first.
   - Reseat the encoder cable connector.
   - Measure each encoder signal wire with a multimeter.
   - Move the lift/cable harness while measuring to catch intermittent contact.
3. Check cable model, length, and routing.
   - Confirm the encoder cable model is correct and not too long for the drive/motor pair.
   - Inspect bend radius, strain relief, connector latch, and whether lift motion pulls the cable.
4. Check EMI and grounding.
   - Verify drive grounding and shield termination.
   - Separate encoder cable from motor power cable where possible.
   - Add ferrite ring or grounding mitigation only after preserving the original wiring evidence.
5. Check motor/drive parameters and hardware last.
   - Confirm motor group parameters match the actual motor/encoder.
   - If wiring, cable, grounding, and parameters are excluded, suspect servo drive or encoder hardware.

### Evidence

- UI alarm screenshot with exact time and motor/side label.
- Drive-panel photo showing `Er.C90`.
- Servo manual or vendor fault table mapping `Er.C90`.
- Encoder cable continuity test, including dynamic movement during lift operation.
- Connector close-up before and after reseating.
- Cable model, cable length, routing, shield/grounding, and ferrite-ring state.
- Servo/drive logs or CAN/fieldbus trace around the failure time.
- Retest after reseating or EMI mitigation.

### Exclusions

- Do not route to generic C134/Mantis reboot/power just because reboot recovery appears in the source text.
- Do not diagnose a software enable-state fault before checking `Er.C90` encoder communication evidence.
- Do not call physical wire break confirmed without continuity or inspection proof.
- Do not replace the servo drive until connector, cable, grounding/shielding, cable length/model, and motor parameters are checked.
- Do not close a one-time recovered fault without repeated lift-motion retest.

### Examples

- `component-test-pt-0132`: CS002 dual-motor lift test library reported `D端提升机电机2使能失败` at `2026-05-14 04:48:28`. The drive panel displayed `Er.C90`; the manual image maps `Er.C90` to encoder communication fault/disconnected line. Source says the fault occurred once and recovered after power cycle, preliminarily excluding a permanent encoder signal-line break. The suspected branches were encoder cable connector looseness during lift operation or encoder cable interference; action was to reseat the encoder cable connector, and if it recurs, add a ferrite ring to the motor power line.

- `component-test-pt-0132`: no raw drive/CAN logs, no continuity test, no connector close-up, no cable model/length, no grounding/shielding measurement, and no repeated retest record are local.

## Component Test Motor Drive Emergency Stop Knowledge

Knowledge file: `docs/component-test/knowledge/motor-drive-emergency-stop.md`

### First Checks

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

### Evidence

- Operation video covering the E-stop trigger, load fall/hold, and lower-limit impact.
- NXP log around trigger time, including node402 controlword writes, disable attempts, and reset cause.
- CAN pcap/candump around trigger time for controlword/statusword changes.
- Drive parameter screenshots or export for `605A:00`, `pn00A`, `pn00b`, and braking/deceleration parameters.
- Speed, torque, DC-link voltage, and motor voltage/current curves from the drive tool.
- Overvoltage module specification, wiring, rated clamp/dissipation ability, and mounting plan.
- Before/after DC bus peak captures for no-module versus protected runs, including repeated tests.
- Firmware version used in each test round.

### Exclusions

- If loaded vertical-axis video is missing, do not claim the revised parameter set is safe under load.
- If only peak values such as `90V` and `82V` are visible, do not claim final closure without rated limits, alarm threshold, waveform duration, and repeated retest.
- If overvoltage warning remains after adding a protection module, do not call the module-only fix complete.
- If NXP can set controlword and statusword changes immediately, focus on drive braking parameter behavior rather than CAN timeout.
- If `Reset cause: External pin reset` appears near the event, do not analyze the case as pure drive parameter behavior.
- If the motor stops immediately after `pn00A -> 3000` only in empty-load testing, keep load-bearing verification open.
- Do not collapse lower-limit impact into a mechanical fault until drive braking and disable timing are checked.

### Examples

- `component-test-pt-0077`: Flowser/Xinliu 1000W climb motor on Mantis/spider `003`. With `30KG` load descending, physical E-stop caused overvoltage error and about `4cm` slide. Source analysis attributes the alarm to back EMF/regenerative voltage exceeding threshold. Supplier recommended an overvoltage protection module; follow-up comparison records `90V` without the module and `82V` with the module, but notes module installation difficulty and remaining overvoltage warning that may need parameter tuning.
- `component-test-pt-0079`: WECON 1000W motor under physical E-stop. Source text records unsafe descent under 30 kg load, parameter experiments, and a later immediate stop when `pn00A` was changed to `3000` in empty-load testing. NXP evidence includes controlword timeout and external reset markers.

- `component-test-pt-0077`: local assets are absent; waveform screenshots, voltage/current logs, module specification, exact drive thresholds, final parameter values, and loaded post-fix retest are missing.
- `component-test-pt-0079`: final loaded verification after parameter/firmware changes is not proven by the visible text; treat loaded safety as unresolved until video/logs confirm it.

## VH Flowser Motor CAN Heartbeat Loss And Bus Drag-Down

Knowledge file: `docs/component-test/knowledge/vh-flowser-motor-can-heartbeat-loss.md`

### First Checks

1. Separate bus-level unavailability from normal heartbeat timeout.
   - If FlowCAN direct connection cannot communicate with the isolated motor and cannot send messages, prioritize motor-node electrical/CAN-transceiver/protection branches.
   - If the isolated motor communicates but fails only inside the robot harness, prioritize cable, connector, termination, grounding, shielding, and power branches.
2. Treat normal-looking static resistance as insufficient.
   - Source says CAN bus and resistance were measured without abnormality.
   - Local photos show motor terminal/resistance measurements around `3.51kΩ` and `3.52kΩ`, supporting no obvious coil/terminal resistance difference between good and bad motors.
   - Static resistance does not prove the CAN transceiver, TVS/protection path, node power, oscillator, firmware boot state, or intermittent short is healthy.
3. Inspect whether one failed node drags down the whole bus.
   - If plugging the failed motor makes the entire CAN bus unavailable, isolate that node before replacing other bus components.
   - Compare bus behavior with the suspect motor disconnected, with a known-good motor connected, and with FlowCAN directly attached.
4. Inspect the motor controller PCB and CAN front end.
   - Local photos show a `SERVO57 V006_B 20251203` board and visible CAN/front-end ICs, with no obvious burn mark in the photo.
   - No visible burn does not exclude ESD, TVS leakage/short, transceiver damage, solder defect, or firmware/boot failure.
5. Use runtime evidence to decide whether this is environmental overstress or batch/board design.
   - Same-batch recurrence supports a batch/design/protection branch.
   - The previous-batch motor that had run 300 hours but failed after replacement keeps environment/harness/power stress open.
   - The `03-17` replacement with the same CAN chip and TVS protection running normally is retest evidence, but the run duration and final result are not recorded locally.

### Evidence

- Raw NXP/robot/motor logs around `2026-03-12 16:50:22`, `2026-03-13 10:00`, and `2026-03-13 14:00`.
- CAN candump/pcap or FlowCAN logs for direct connection before and after failure.
- Bus voltage/waveform capture for CANH/CANL with suspect motor connected and disconnected.
- Exact CAN bitrate, node ID, firmware version, motor board version, CAN chip part number, and TVS/protection part number.
- Harness/connector photos and notes from S209 `401` vehicle, including power supply, ground, termination, shield, and strain points.
- Repair or teardown result identifying whether the failed part was CAN transceiver, TVS/protection, MCU/boot, connector/solder, power, or mechanical/electrical overstress.
- Retest duration and pass/fail result after the `03-17` replacement.

### Exclusions

- Do not conclude ordinary heartbeat timeout if FlowCAN direct connection to the isolated motor also cannot communicate.
- Do not exclude CAN front-end damage from normal motor winding/terminal resistance or a PCB photo without visible burn.
- Do not blame the whole bus harness until the suspect motor is tested disconnected, directly connected, and compared with a known-good motor.
- Do not treat same-batch recurrence as the only cause; the previous-batch 300-hour motor also failed after installation, so environmental overstress remains open.
- Do not replace multiple robot-side CAN devices before isolating whether one failed motor node drags the bus down.
- Do not claim final root cause without raw CAN/FlowCAN logs, chip-level repair evidence, or retest duration.

### Examples

- `component-test-pt-0088`: source text says S209 `401` vehicle replaced a VH baffle motor at `2026-03-12 16:50:22`; after about 30 minutes, the baffle motor lost connection and logs showed command-send failure. Source says CAN bus and resistance were measured with no abnormality, but FlowCAN direct connection could not communicate with the motor and could not send messages, making the whole CAN bus unavailable. Same-batch replacement reproduced after about 10 minutes at `2026-03-13 10:00`; previous-batch motor reproduced after about 2 minutes at `2026-03-13 14:00`; source notes that the previous-batch motor had run 300 hours before replacement. Local photos show two motor resistance readings around `3.51kΩ` and `3.52kΩ`, and PCB photos show `SERVO57 V006_B 20251203` with no obvious visible burn in the inspected images.

- `component-test-pt-0088`: no raw NXP/robot/motor log, FlowCAN export, candump/pcap, oscilloscope waveform, exact node ID, motor firmware, harness inspection, chip-level failure analysis, or final retest duration is local. The case supports a strong VH/Flowser motor CAN-node failure branch, but does not prove whether the failed point is CAN transceiver, TVS/protection, MCU/firmware boot, connector/solder, harness overstress, or robot-side power/ground.
