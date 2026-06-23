# C134 Troubleshooting Playbook

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
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## C134 Ant Power Knowledge

Knowledge file: `docs/c134/knowledge/ant-power.md`

### First Checks

1. Confirm whether this is real power loss.
   - Check battery trend before the event, not only battery after manual recovery.
   - Strong evidence: battery falls to 0% or below shutdown threshold for 3 min; example `c134-0019`.
   - If battery remains normal near reboot, continue to reboot/system-storage/network branches.
2. Check charging dispatch and charging-point ownership.
   - Robot may not charge while still in an unfinished task; example `c134-0223`.
   - Robot can be blocked if a charged robot releases reservation before physically leaving the pile; example `c134-0095`.
   - Robot can drain after no new command for hours; example `c134-0099`.
3. Check reboot evidence.
   - Use `UPTIME` reset in system/wormhole logs and NXP restart markers.
   - Asset-backed examples: `c134-0012` (`2026-01-31T01:22:57Z`, lift-time reboot, NXP 0 KB), `c134-0036` (`2025-11-21T02:31:00Z`), `c134-0058` (`2025-12-05T02:23:51Z`), `c134-0066` (`2025-12-10T01:15:18Z`), `c134-0067` (`2025-12-11T01:03:48Z`), `c134-0068` (`2025-12-13T00:44:17Z`), `c134-0071` (`2025-12-16T02:13:54Z`), `c134-0072` (`2025-12-19T06:18:18Z`), `c134-0083` (`2025-12-24T10:28:20Z`), `c134-0124` (two reboots at `2026-01-06T02:08:43Z` and `02:11:53Z`), `c134-0126` (two reboots at `2026-01-07T05:52:12Z` and `05:58:29Z`), `c134-0174` (two reboots at `2026-01-06T04:10:50Z` and `04:16:41Z`), `c134-0176` (`2026-01-06T03:54:55Z`), `c134-0225` (`2026-02-03T00:38:53Z`), `c134-0235` (`2026-02-10T01:22:42Z`), `c134-0280` (`2026-04-11T07:43:05Z`), `c134-0281` (`2026-04-15T01:08:35Z`), `c134-0282` (`2026-04-19T01:45:24Z`), `c134-0285` (`2026-04-20T01:08:13Z`), `c134-0286` (`2026-04-23T04:52:52Z`), `c134-0287` (`2026-04-29T05:11:42Z`), `c134-0312` (`2026-04-16T07:06:10Z`), `c134-0338` (`2026-04-07T04:07:47Z`), `c134-0341` (`2026-04-09T07:18:36Z`, system-only), `c134-0345` (`2026-04-05T01:04:36Z`), `c134-0347` (`2026-04-03T05:58:43Z`), `c134-0372` (`2026-02-05T09:59:46Z`), `c134-0374` (`2026-02-06T02:13:33Z`), `c134-0383` (`2026-02-07T08:25:47Z`), `c134-0414` (two shutdown/reboot events while/after charging), `c134-0412`/`c134-0437` (`2026-01-26T11:06:11Z`).
   - Examples: `c134-0239` at `[2026-03-09T12:41:55+0800][UPTIME:31]`; `c134-0334` at `[2026-03-31T12:00:36+0800][UPTIME:31]`.
   - If logs begin only after reboot, mark root cause unknown and request earlier system log; examples `c134-0192`, `c134-0236`, `c134-0260`.
   - If logs show continuous `UPTIME` through the reported window, do not confirm reboot; examples `c134-0070`, `c134-0144`.
   - If exported logs are concatenated or not chronological, do not bind low-uptime lines to the reported event without timestamp-order validation; examples `c134-0145`, `c134-0178`.
   - If logs confirm reboot but no pre-reset fatal/panic/low-voltage marker exists, keep cause unknown and route to CAN/BMS/boost-module inspection.
   - If a screenshot confirms `NODE402_ERROR#...#under voltage` but only service logs are available, accept the under-voltage symptom while keeping BMS/boost/root cause unknown; example `c134-0024`.
4. Check storage/overlay/SD-card health.
   - Overlay full or SD-card mount/log loss can explain repeated A-105 reboot; examples `c134-0298`, `c134-0299`.
5. Check wireless/network correlation, but do not overclaim.
   - `wwanX`/`phy1-sta0` disconnects appear in several reboot cases.
   - `c134-0242` explicitly says two A107 reboots had no NIC disconnect.
   - Treat NIC/MQTT disconnect as a branch needing timing correlation, not a confirmed reboot cause; `c134-0372` has MQTT errors before reboot but causality remains unproven.
6. Check service-side causes before classifying as robot power.
   - RVS no response caused FLO no-device display in `c134-0221`.
   - SAS/Redis failure caused no robot action after inventory task in `c134-0333`.
   - Wrong MQTT HOST caused repeated command/mode behavior in `c134-0313`.
7. Check motor/emergency-stop state for startup failure.
   - `c134-0409`: motor 2 stopped heartbeat after `2025-12-15T21:48:06.782346337+0800`; recovery rule is stop moving, re-hit E-stop, wait 2s, release.
8. Check normal-status false leads.
   - `c134-0050`: blue light after normal startup is expected, no fault.
   - `c134-0193`: frequent self-check failure attributed to gyro initialization; fixed by newer firmware.

### Evidence

- NXP log covering at least 5 min before and after event.
- system/wormhole log covering at least 30 min before and after event.
- battery percentage/current/voltage trend, especially around low-battery threshold.
- BMS/boost-module CAN frames across at least 60s before the `UPTIME` drop and first 60s after restart.
- FLO/Kafka robot state and command status near event.
- charging pile reservation/release events and robot physical departure time.
- network logs for `wwan0`, `wwan1`, `phy1-sta0`, AP packet loss, ping reachability.
- storage checks: overlay usage, SD-card mount history, missing/rotated logs.
- video/screenshot only as timing and physical-state support, not as root-cause proof.

### Exclusions

- Battery is normal near reboot: exclude pure low-voltage shutdown; continue storage/system/network.
- Battery is low-ish but stable, for example 26-36% before reboot: keep low-voltage as a branch but do not mark confirmed without BMS/boost evidence.
- `UPTIME` did not reset: exclude reboot; inspect application/service state instead.
- FLO shows UNKNOWN but robot blue light is normal after startup: do not classify as hardware failure without logs.
- NIC disconnect is not time-aligned with reboot or absent in same robot sequence: do not conclude network caused reboot.
- FLO no-device/no-action affects many robots while IO/IOCS still works: inspect RVS/SAS/Redis before robot-side power.
- Logs start after the event: mark root cause unknown and request pre-event local logs.
- Logs cover the reported window but `UPTIME` is continuous: mark the reboot report unconfirmed and verify event date/time.
- Screenshots only or explicitly no logs: accept as low-confidence operational evidence only; example `c134-0151`.

### Examples

- `c134-0019`: A110 battery fell from 24% to 0%; boost module low-battery shutdown after sustained below-threshold condition; charging not dispatched in time.
- `c134-0095`: A103 released charging reservation before leaving charge 2; A104 was assigned the same pile and blocked.
- `c134-0193`: A102 self-check failure due to gyro initialization; fixed in new firmware.
- `c134-0299`: A105 reboot with overlay full and SD-card log loss; resolution was SD-card replacement.
- `c134-0409`: A111 initialization failed because motor 2 stopped heartbeat; recovery procedure tied to E-stop/motor protection state.

- Confirmed reboot, cause unknown: repeated restart cases with `UPTIME` reset/startup markers but no pre-reset fatal, BMS/CAN, boost-module, storage, or charger-contact proof. Representative IDs: `c134-0012`, `c134-0036`, `c134-0124`, `c134-0235`, `c134-0286`, `c134-0372`, `c134-0414`.
- Pre-window/log-window gap: source reports reboot, but logs start after boot, are 0 KB, or miss the pre-reset period. Representative IDs: `c134-0009`, `c134-0064`, `c134-0065`, `c134-0192`, `c134-0236`, `c134-0260`, `c134-0426`.
- Continuous-uptime contradiction: logs cover the reported window but do not show a reboot; verify source time/date before diagnosing hardware. Examples: `c134-0070`, `c134-0144`.
- Non-chronological package: low-uptime lines exist but exported logs are concatenated/messy, so do not bind them to the reported event until timestamp order is validated. Examples: `c134-0145`, `c134-0178`, `c134-0422`.
- Abrupt SOC drop near reboot/charging: BMS/boost/charging-power is the leading branch, but root cause remains unconfirmed without CAN/BMS or charger-contact evidence. Examples: `c134-0122`, `c134-0123`, `c134-0124`, `c134-0126`, `c134-0143`, `c134-0174`, `c134-0414`.
- Screenshot-only or no-logs reports: accept operational symptom, keep cause unknown. Examples: `c134-0024`, `c134-0147`, `c134-0151`.
- Network/service correlation not causality: frequent NIC/MQTT failures may precede reboot or FLO disappearance, but need AP/server/firmware/CAN timing proof before claiming cause. Examples: `c134-0243`, `c134-0372`.
- Weak duplicate pointer: source only says "same as previous" or lacks usable evidence; keep as low-information training only. Example: `c134-0346`.

## C134 Ant Motion Localization Knowledge

Knowledge file: `docs/c134/knowledge/ant-motion-localization.md`

### First Checks

1. Confirm whether localization was lost.
   - Look for `DM code lost during linear motion`, continuous `NoRead`, or low scan success.
   - Examples: `c134-0003` and `c134-0037` have `[ERROR]1202#DIFF402_ERROR#MOVER_MOTOR#DM code lost during linear motion`; `c134-0352` has low scan success during rotation and straight-move failure.
   - In downloaded `c134-0003` logs, the event window starts a `LINEAR_EVENT` around `2025-10-21T02:29:00Z`; scan offset grows from `x_offset: -41` to `x_offset: -415` before later correction.
2. Inspect floor-code condition and route segment.
   - Dirty/contaminated DM code caused deviation in `c134-0037`, `c134-0038`, `c134-0219`.
   - Repeated requests to inspect specific segments appear in `c134-0117`, `c134-0120`.
3. Check whether scanner reads are sparse during rotation or WS exit.
   - `c134-0121`: scan result gap caused over-rotation.
   - `c134-0231`: at `[130847, 101500]`, rotation scanned only once.
   - `c134-0232`: at `[130847, 101500]`, rotation was not in place before DM loss.
4. Check command geometry and orientation tolerance.
   - `c134-0041`: command travel angle `10.784297867562598°` exceeded the 10-degree same-direction tolerance; resolution increased tolerance to 45 degrees.
   - `c134-0197` repeats the `c134-0041` pattern.
   - `c134-0250`: small move distance `45.136349 mm` plus X offset `15.2 mm` produced angle difference `20.67942192°`.
5. Check repeated target commands and same-point planning.
   - `c134-0101`: two MOVE commands had the same target position and caused planning failure.
   - `c134-0198`: several commands targeted `131847, 101499`; one success followed by repeated failures.
6. Check speed, braking distance, and command cancellation.
   - `c134-0319`: new command tried to stop from about `2133 mm/s` over `429 mm` with acceleration `500 mm/s^2`; required braking distance was far larger.
   - `c134-0304`: similar case, A-B actual distance `246 mm`; required braking distance `(2100-0)^2/(2*500)=4410 mm`.
   - `c134-0428`: trapezoidal planning used current real velocity instead of theoretical velocity, causing planned route to exceed endpoint.
7. Check mechanical/electrical drive symmetry.
   - `c134-0276`: robot computed right-turn angular speed but still deviated left; possible one-side motor obstruction or external force; CAN log was off.
   - `c134-0323`: severe deviation after reducer replacement; two walking motors had inconsistent subdivision, new motor subdivision was not changed.
8. Separate collision aftermath from primary cause.
   - Collisions in `c134-0034`, `c134-0037`, `c134-0304`, `c134-0319`, `c134-0352`, `c134-0365` are consequences unless logs/video prove external impact preceded deviation.
   - `c134-0361` has title/assets identifying A-102 but source body says A-111; preserve both and use local image/log filenames as stronger evidence for robot identity.
9. Check whether the attached logs actually cover the deviation.
   - `c134-0015` has downloaded NXP/wormhole logs, but they begin post-boot and mostly show startup/idle state, not the reported deviation sequence.

### Evidence

- NXP localization/motion logs with DM read/no-read sequence.
- RCS/RMS command-set records: expected state, future state, speed, acceleration, tolerance.
- MQTT command payloads, especially `coordX`, `coordY`, `finalTargetX`, `finalTargetY`, `maxVelocity`, `maxAcceleration`.
- CAN logs for left/right motor status, speed, torque, and obstruction when deviation persists despite corrective angular command.
- video covering the start of deviation, not only final collision.
- floor-code photos and exact route segment coordinates after cleaning status is known.
- robot calibration data: camera offset angle, motor subdivision, reducer/motor replacement history.
- for WS repeated-point cases, workstation ID, exit/entry direction, and exact DM coordinate.

### Exclusions

- If DM reads remain healthy through the event, do not label it floor-code loss; inspect command geometry and drivetrain.
- If command distance is shorter than required braking distance, prioritize planning/tolerance over floor dirt.
- If the robot calculates corrective angular speed opposite to observed deviation, request CAN/motor evidence before blaming floor code.
- If multiple robots fail at the same coordinate, prioritize floor code/route geometry over a single robot fault.
- If one robot deviates after motor/reducer replacement, verify motor subdivision and calibration before changing global route logic.
- If collision is observed after deviation, do not use collision as root cause unless video shows external contact first.
- If robot ID differs between title/body/assets, keep a metadata-conflict branch and route by the strongest evidence source.

### Examples

- `c134-0037`: A109 deviation/collision with A105; floor code had dust; task failed with `DM code lost during linear motion`; resolution was cleaning floor code.
- `c134-0041`: movement direction check used 10-degree tolerance and rejected `10.784297867562598°`; resolution was increasing tolerance to 45 degrees.
- `c134-0219`: A106 deviation; cleaning floor code solved it.
- `c134-0323`: A102 severe deviation after reducer replacement; two walking motors had inconsistent subdivision.
- `c134-0428`: planning used real speed instead of theoretical speed; route exceeded endpoint; resolution was to use theoretical values for planning.

- DM/localization symptom confirmed but root cause open: `c134-0003`, `c134-0011`, `c134-0018`, `c134-0199`. Need floor segment condition, scanner health, and command context before final cause.
- Log coverage gap: `c134-0015` has local assets, but logs show startup/idle rather than the reported deviation sequence.
- Segment inspection requested, conclusion missing: `c134-0117`, `c134-0120`.
- WS001-3 repeated-point family: `c134-0101`, `c134-0198`, `c134-0208`, `c134-0231`, `c134-0232`, `c134-0361`. Prioritize coordinate/WS geometry, scan count, rotation state, and RMS payload before single-robot hardware.
- Metadata conflict: `c134-0361` title/assets identify A-102 but source body says A-111; NXP near `2026-02-08T01:07:57Z` shows long `NoRead` recovery and `corrected_pose`, but the direct scissor/tote-strip collision cause is not closed.
- Drivetrain branch unresolved: `c134-0276` suggests one-side motor obstruction or external force, but CAN logging was off.
- Similar-pattern without full closure: `c134-0304` resembles `c134-0319` short-distance high-speed stop, but RMS logs are missing.
- Evidence-window insufficient: `c134-0015`, `c134-0208` show why attached logs must be checked for actual event coverage before concluding no fault.

## C134 Ant Network Knowledge

Knowledge file: `docs/c134/knowledge/ant-network.md`

### First Checks

1. Scope the disconnect first.
   - One robot only: inspect robot NIC, wormhole, MQTT, NXP, board.
   - Many/all robots: inspect AP/uplink/server/Kafka before robot hardware.
2. Check ping reachability by both IPs.
   - Both IPs unreachable points to NIC/AP/link/board branch; examples `c134-0252`, `c134-0256`.
   - Both IPs reachable but FLO disconnects points to MQTT/NXP-to-wormhole path; example `c134-0228`.
3. Correlate NXP MQTT disconnect with wormhole/NIC logs.
   - `c134-0252`: MQTT disconnect at `[2026-02-22T13:28:44+0800]`; wormhole shows `phy1-sta0` AP loss at `[2026-02-22T13:28:32+0800]`.
   - `c134-0228`: NXP shows MQTT disconnect at `[2026-02-03T16:22:46+0800]`, wormhole has no NIC disconnect and both IPs ping.
4. Check dual-NIC state and failover.
   - `c134-0157`: IP `10.0.64.116` had no packets from before `2026-01-21T12:52:39.700277000+0800`; the other NIC still carried MQTT until later full loss.
   - `c134-0252`: known NIC1 switching stuck issue can prevent both NICs from reconnecting after NIC2/AP loss.
5. Check hardware if both NICs fail or repeat on same robot.
   - `c134-0283`: both NICs disconnected at `[2026-04-19T03:23:28Z][UPTIME:5919]`; resolution was replacing layer-3 board.
   - `c134-0284`: NIC2 then NIC1 disconnected; same resolution.
6. For whole-site short disconnect, test physical network path.
   - `c134-0227`: ping AP and EasyBox simultaneously; if both drop, suspect fiber transceiver/fiber/cable/switch path.
   - Replacement of a pair of transceivers on `2026-02-06 11:45` stopped observed loss through `2026-02-09 08:40:49`.
7. For whole-site service disconnect, inspect server disk I/O and Kafka.
   - `c134-0337`: high disk I/O caused Kafka controller election failure and restart; stopping EFK reduced pressure, root fix was replacing HDD with SSD.
8. If network loss follows robot reboot/UNKNOWN, split root cause.
   - `c134-0027`: last pre-reboot command succeeded in `IDLE`; robot rebooted to `UNKNOWN`, could not move to charge, then voltage dropped below `4.0v`.
9. If a robot is reported disconnected but the status light looks normal, verify UPTIME before accepting the visual inference.
   - `c134-0139`: field text said green light preliminarily excluded reboot, but wormhole UPTIME dropped from `2029` to `29` at `[2026-01-13T00:51:05Z]` and NXP dropped to `[UPTIME:39]`.

### Evidence

- ping results for both robot IPs with timestamps.
- wormhole/system logs around NIC/AP events: `wwan*`, `phy1-sta0`, reconnect/disconnect.
- NXP MQTT disconnect timestamps and keepAlive timeout evidence.
- dumpcap/pcap from robot NICs and AP/uplink side.
- AP, EasyBox, switch/uplink ping monitoring for site-wide events.
- server disk I/O, Kafka controller/broker logs, EFK load for whole-site disconnects.
- robot board replacement/repair history for repeated same-robot dual-NIC loss.
- screenshots alone are enough for weak routing examples but not for root cause.

### Exclusions

- Both robot IPs ping but MQTT is broken: do not blame AP/uplink first; inspect NXP/wormhole/MQTT.
- One NIC down but the other still carries MQTT: do not treat as full robot disconnect until both paths fail or MQTT keepAlive expires.
- Whole-site FLO disconnect with server symptoms: inspect Kafka/RVS/SAS and disk I/O before AP hardware.
- Whole-site ping drops to both AP and EasyBox: suspect upstream physical path, not AP-only.
- Reboot before disconnect: classify power/system root separately; network may be consequence.
- Green light or UI status after the fact does not exclude reboot; check UPTIME reset.
- Screenshot-only whole-site events should route to AP/EasyBox/server/Kafka checks, but root cause stays unknown.
- Missing wormhole NIC event at disconnect time: keep root cause unknown unless pcap or NXP evidence closes the path.

### Examples

- `c134-0227`: whole-site short disconnect correlated with AP/EasyBox loss; replacing one pair of transceivers stopped observed packet loss.
- `c134-0252`: NIC2 AP loss plus known NIC1 switching stuck caused full disconnect; fix branch is failover bug.
- `c134-0283`, `c134-0284`: repeated A107 NIC disconnects resolved by replacing layer-3 board.
- `c134-0337`: whole-site disconnect came from Kafka controller election failure under high disk I/O; root fix was HDD to SSD.
- `c134-0139`: reported A-111 disconnect actually has UPTIME-reset evidence around `2026-01-13T00:51:05Z`; root cause unknown.

- `c134-0002`: dumpcap last communication with A108 at `13点21分19秒`; another NIC had disconnected the previous night; exact cause unresolved.
- `c134-0157`: NIC1 was already down, MQTT later broke on remaining path, then NXP rebooted; exact first cause unresolved.
- `c134-0228`: both IPs ping, no wormhole NIC disconnect, NXP MQTT disconnected; NXP-wormhole internal cause unknown.
- `c134-0256`: both IPs unreachable, NXP MQTT disconnected, no wormhole event; needs dual-NIC redundancy validation.
- `c134-0167`: A-107 disconnected and ping failed at `2026-01-24 08:27`; screenshots only.
- `c134-0370`: whole-site short disconnect at `2026-02-05 09:16`; screenshot only.
- `c134-0371`: whole-site disconnect/slow operation at `2026-02-05 13:38` and `15:00`; screenshots only.

## C134 Ant Load Handling Knowledge

Knowledge file: `docs/c134/knowledge/ant-load-handling.md`

### First Checks

1. Confirm whether the robot or upper system raised the error.
   - `c134-0048`: visible text says the lift failure was not robot-reported; wormhole reboot occurred near the event.
   - If FLO has no error but robot does not move, inspect command/reservation/task state first.
2. Check task/container state before mechanical diagnosis.
   - `c134-0047`: A108 was cleared at 18:09, A109 began going for container 1045 10 seconds later, and the container was TPed to A108 only at 18:14; A109 then found no tote.
   - `c134-0196`: A112 stayed under WS001-2 because WAS believed it still had `WorkerTask`; more WAS logging was needed.
3. Check command flow and reservation blocking.
   - `c134-0152`: A109 moved to `(130847,105831)`, rotated to 0 degrees, then received no new command; A101’s legal exit reservation overlapped A109 state reservation by about 8 mm.
   - `c134-0206`: A111 stayed under `WS001-2`/box `100905`; RMS logged reservation intersection with A107 and `Commands created for A-111 are invalid`.
   - `c134-0249` is same pattern as `c134-0152`.
   - `c134-0055`: after A-106 extracted `TOTE-H-200585` at `2026-02-02T13:28:08.580Z`, RMS generated MOVE/EXIT-style commands with `liftHeight: 0`; robot reboot was excluded, so task/state flow is the leading branch.
4. Check load sensor timing and physical tote seating.
   - `c134-0084`: FLO failed lift/extract with `FUTURE_STATE_NOT_MATCH#LoadSensor#Expected: true#Actual: false`; photos show abnormal tote seating at `A3-S2-B10`.
   - `c134-0094`: FLO failed extracting `TOTE-L-600138` at `A2-S2-B12-PT1` with `FUTURE_STATE_NOT_MATCH#LoadSensor#Expected: true#Actual: false`; robot logs are unavailable.
   - `c134-0102`: A105 was lifted but load sensor was not triggered; manual sensor test was normal.
   - `c134-0160`: A-102 NXP log at `2026-01-21T08:11:22Z` confirms `LoadSensor` expected true/actual false and `COMPLETE_FAILURE`.
   - `c134-0169`: FLO screenshot shows A-101 movement failure with `FUTURE_STATE_NOT_MATCH#LoadSensor#Expected: true#Actual: false`; wormhole logs were unavailable.
   - `c134-0170`: FLO notification shows A-112 moving-state `FUTURE_STATE_NOT_MATCH#LoadSensor#Expected: true#Actual: false`; wormhole logs were unavailable.
   - `c134-0171`: A-108 full NXP/CAN/wormhole set shows repeated `node402 e.type 10` load-sensor input transitions; root cause is not closed.
   - `c134-0181`: manual check said sensor and tote were normal while software reported abnormal state; use as intermittent/false-positive branch.
   - `c134-0444`: A112/A104 repeated sensor-state error; suspected tote was blocked by limit block for at least 1s before seating; MQTT/candump sensor checks were normal, excluding hardware.
5. Check mechanical interference at PT/PD/WS.
   - `c134-0194`: A105 exited PT after picking, did not reach position cleanly, lowered lift, tote interfered with PT sheet metal and tilted; load sensor changed triggered to untriggered.
   - `c134-0216`: photo suggested the tote may have been raised/padded by the picking station.
   - `c134-0086`: photo shows tilted/not normally seated tote at `A2-S2-B9`; exact contact point needs video/logs.
   - `c134-0230`: WS002-3 load-sensor harness was visibly broken; source says Ant scissor mechanism interfered with and tore the harness.
6. Check power supply during lift.
   - `c134-0180`: lift reported low voltage; buzzer indicated boost-module abnormality; tote weight around 25 kg was below nominal 30 kg, so branch moved to robot supply capability.
7. Check MQTT/config before blaming lift hardware.
   - `c134-0100`: A112 MQTT disconnected at `[2025-12-09T18:20:30+0800]` and did not recover before hard reboot.
   - `c134-0254`: wrong MQTT HOST caused duplicate commands; resetting to `10.0.64.108` was needed.
8. Check repeated PT location issues.
   - `c134-0098`, `c134-0102`, `c134-0194`, `c134-0216` cluster around A1-S2-B2/PT or nearby transfer points; inspect local geometry, tote seating, sensor timing, and route/pose.
9. If handling failure is mixed with reboot/buzzer claims, verify log coverage first.
   - `c134-0061`: A-105 place failure report around `14:40`; wormhole/NXP UPTIME reset appears later around `14:46:54`/`14:47:05`, relation unresolved.
   - `c134-0237`: A111 lift failure/five beeps at `WS002-2`; system logs show post-event restarts at `04:58:34Z` and `05:04:47Z`, but CAN1/CAN2 are unavailable and scissor damage is only a field hypothesis.
   - `c134-0340`: A109 indicator-off/five-beep report at `13:07`; NXP covers the window, but provided system log has no reboot marker.
   - `c134-0378`: report says A-105 rebooted with five buzzer sounds at `18:38`, but downloaded logs end at `18:34:51` with continuous UPTIME; reboot not confirmed.
10. For empty-PT or post-TP anomalies, inspect container ownership and demand state.
   - `c134-0401`: A104 faulted raised at empty `A2-S2-B9` PT; WAS shows `TOTE-L-600035` moved to that PT and still present in WS002 demand state after manual/TP handling, but final root cause is unresolved.
   - `c134-0020`: A110 no-action at WS002-2 was recovered by TP/reboot/clear; robot logs mainly show successful post-recovery commands, so upper-system pre-recovery state remains the missing branch.

### Evidence

- FLO/Kafka task, subtask, command, and command-update records.
- WAS/RCS reservation logs, especially overlap and `WorkerTask` state.
- MQTT command and host config.
- NXP lift/load-sensor logs and candump/CAN sensor state.
- video showing tote seating, scissor lift motion, PT/PD contact, and sensor trigger timing.
- physical inspection of PT/PD sheet metal, limit blocks, tote placement, picking-station height, and scissor mechanism.
- battery/boost-module CAN data during lift if buzzer or low-voltage appears.
- exact log coverage end time when an event is reported near the edge of the downloaded window.
- clear/manual intervention records when behavior changes from workstation handling to returning the tote.

### Exclusions

- Manual sensor test normal plus MQTT/candump normal: do not replace sensor first; inspect tote seating and timing.
- FLO no error and robot stopped after completed move/rotation: inspect missing next command and reservation, not lift hardware.
- Error happened after manual TP/clear sequence: verify container ownership/state before physical root cause.
- Tote weight below rating but low-voltage/buzzer present: inspect boost module and supply rather than overload alone.
- Wrong MQTT host or disconnect present: resolve communication/config branch before mechanical debugging.
- Photo/video shows tote tilt or PT contact: classify mechanical interference unless logs prove actuator failure first.
- If logs stop before the reported lift/reboot time, do not mark reboot confirmed.
- If a workstation harness is damaged by Ant scissor motion, keep both workstation sensor and robot mechanical-clearance branches open.

### Examples

- `c134-0152`: A109 received no new command after move/rotation; A101 and A109 reservations overlapped by about 8 mm.
- `c134-0206`: A111 no-action at WS001-2 was explained by invalid command generation from reservation intersection with A107.
- `c134-0180`: lift reported low voltage and boost-module abnormality branch; tote weight was below nominal capacity.
- `c134-0196`: robot waited because WAS still believed a `WorkerTask` existed.
- `c134-0254`: MQTT HOST was wrong; setting it back to `10.0.64.108` addressed duplicate-command cause.
- `c134-0444`: sensor hardware excluded by MQTT and candump checks; likely delayed tote seating against limit block.
- `c134-0230`: WS002-3 sensor harness was physically broken; operational root cause is Ant scissor interference with harness routing.

- `c134-0047`: container/task timing issue visible, final software cause unresolved.
- `c134-0020`: post-recovery robot logs show successful commands after reboot/clear; original no-action cause missing without pre-recovery upper-system logs.
- `c134-0084`: load-sensor expected/actual mismatch plus tilted tote photos; PT geometry/tote seating likely branch, not confirmed.
- `c134-0094`: A-107 FLO load-sensor mismatch during PT extraction; logs/video unavailable.
- `c134-0086`: A-104 tote tilt photo; exact PT contact point and actuator state unresolved.
- `c134-0098`: repeated A105 failure at A1-S2-B2 with scissor noise; conclusion missing.
- `c134-0102`: load sensor mismatch with normal manual test; physical/timing cause unresolved.
- `c134-0190`, `c134-0215`: PT pick failures lack visible root-cause text.
- `c134-0216`: suspected picking-station height/tote geometry, not confirmed.
- `c134-0061`: A-105 place failure plus later UPTIME reset; exact causal relationship unresolved.
- `c134-0237`: lift failure/five beeps plus confirmed post-event reboot markers; mechanical damage unconfirmed because CAN logs are unavailable.
- `c134-0340`: lift/buzzer/indicator-off report; available logs do not confirm reboot or root cause.
- `c134-0378`: A-105 lift-time reboot/buzzer report; downloaded logs stop before event, so reboot is unconfirmed.
- `c134-0401`: empty-PT pick after TP/manual state changes; WAS/SAS suggest container/demand mismatch but direct A104 command failure root cause is not closed.
- `c134-0160`: A-102 NXP confirms load-sensor mismatch while moving; CAN/physical cause unresolved.
- `c134-0169`: A-101 FLO screenshot confirms load-sensor mismatch while moving; wormhole logs unavailable.
- `c134-0170`: A-112 FLO notification confirms load-sensor mismatch while moving; robot logs unavailable.
- `c134-0171`: A-108 full log set shows load-sensor transitions; root cause unresolved.
- `c134-0181`: A-101 manual check normal but software reported sensor abnormal; intermittent/state-timing cause unresolved.
- `c134-0055`: A-106 no-lift report at `WS001-2` with `TOTE-H-200585`; NXP/system exclude reboot and RMS shows no obvious lift-at-WS command in the relevant post-extract sequence, but workstation/clear-flow root cause remains unresolved.

## C134 Mantis Load Handling Knowledge

Knowledge file: `docs/c134/knowledge/mantis-load-handling.md`

### First Checks

1. Confirm physical state versus database/task state.
   - If tote is already in target but task failed, inspect command completion and sensor mismatch; examples `c134-0267`, `c134-0269`.
   - If Mantis has tote but no deposit action, inspect SAS target selection; `c134-0311` saw `No PDs or Tunnels available`.
2. Check quick stop and motor-state sequence.
   - `c134-0267`: pull motor entered quick stop while static/retracted; upper `HSM_Main` did not see IO change; motor returned to operation enabled and repeated old target-reached, causing premature command complete.
   - `c134-0272`, `c134-0274`: quick stop triggered near X about `14445`/`14447` during horizontal move.
3. Check whether IO pulse was too short for current TPDO mode.
   - `c134-0267`: IO state `60FD` used TPDO type `0x01`, one sync frame every `10ms`; IO change shorter than `10ms` could be missed by NXP.
   - Branch fix: TPDO transmission type `0xFE` event-triggered plus motor firmware support for timed reporting.
4. Check command target/state and offset config.
   - `c134-0351`: rest position offset y `-7` led to current y `11341`, load access node offset y `-6` expected EXTEND y `11342`; 1 mm mismatch caused expected/actual error.
   - `c134-0316` reports similar `coordY Expected: 11342 Actual 11341` without logs.
   - `c134-0140`: RMS shows `EXTEND` blocked by `coordY - Expected: 18068 Actual: 18067`; manual move to Bay1 recovered operation.
   - `c134-0186`, `c134-0187`: M3 offset biased toward B3; needed adjustment toward B1, sometimes location-specific rather than global.
5. Check finger command and sensor state.
   - `c134-0296`: pull task failed before fork extension; inspect `ARTICULATE_FINGERS` command and nearby rest/load positions.
   - `c134-0305`: `FINGER_MOTOR_RIGHT4 Expected: 9000 Actual: 4150` and `UNABLE_TO_REACH_TARGET_STATE`.
   - `c134-0364`: finger motors 3/4 stalled at same time, likely finger hit tote.
6. Check mechanical interference and torque.
   - `c134-0362`: fork torque jumped to about 200%, speed dropped, tote tail lifted and finger position was disturbed.
   - `c134-0318`: abnormal pull torque exceeded 200%, normal pull torque is within 50%; suspected PT sheet-metal deformation.
   - `c134-0317`: repeated B2 PT pull failures with no obvious resistance manually; weight did not exceed 30 kg.
7. Check logs before concluding.
   - `c134-0079`: RMS logs incomplete; could not locate arm retract/task-complete logs.
   - `c134-0308`, `c134-0316`: no RMS logs; mark blocked and wait for reproduction.
8. If filenames and robot label say Mantis, reclassify even when the initial case extraction says Ant.
   - `c134-0195`: source/assets say `A2巷道螳螂`, wormhole/NXP identify `M-A2-S1-1`; NXP only shows startup `canopen_stack`/`node_led` errors, not the full pull sequence.
9. If Mantis task failure is mixed with Ant aisle occupancy or避让, route scheduler/traffic first.
   - `c134-0054`: M1避让 for A-106, then immediately took a pull/deposit task and returned toward a path blocked by A-104; A-106 NXP showed command success, so embedded failure was not the primary branch.
   - `c134-0026`: Mantis pull failure was followed by left-right shaking and an Ant stopped below; computer-side manual mode let the Ant leave, then Mantis auto recovered. SAS logs show reservation/mode churn and conflicts such as selected target already reserved by an Ant.
10. For front-load-sensor deposit failures, correlate UI/video, GPIO, CAN, and container state.
   - `c134-0386`: FLO showed M-A2-S1-1 deposit/unload failed for `TOTE-L-600431`; WAS later logged `container.orphaned` from `M-A2-S1-1`; NXP sampled GPIO transitions but no direct `COMPLETE_FAILURE` line proving root cause.
11. For `ARM_MOTOR_SINGLE#following error`, separate motor/driver fault from external load.
   - `c134-0010`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55299`; NXP recorded `node402 fault history recorded: ARM_MOTOR_SINGLE#following error, 55299` and `MoveArms -> FaultReaction`; source notes `A2-S2-B5-PT1` had not replaced sheet metal, and photo shows tote skew/contact risk.
   - `c134-0155`: UI and NXP both show `ARM_MOTOR_SINGLE#following error, 55347`; photo shows tote not fully pulled into the access area.
   - `c134-0085`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55344`; CAN1 was 0KB and unavailable.
   - `c134-0096`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55386`; CAN pcaps are available but NXP/wormhole are not, so external load versus motor branch remains unresolved.
   - `c134-0141`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55355`; photo shows tote skew/tilt at `A2-S2-B2`, making external load/PT geometry a high-value branch.
   - `c134-0204`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55490`; photo shows tote visibly skewed/tilted at `A2-S2-B5`.
   - `c134-0205`: UI error `[ERROR]1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 10277`; source reports tote skew at `A3-S2-B12-PT`.
   - `c134-0153`: PDA/NXP show repeated `ARM_MOTOR_SINGLE#following error` values `10217` and `10245`.
   - `c134-0154`: NXP shows repeated `ARM_MOTOR_SINGLE#following error` values `55317` and `55423`; field photo shows tote partly in the access area.
   - `c134-0172`: UI and NXP both show `ARM_MOTOR_SINGLE#following error, 55388`; photo shows tote partly in the access/pull area.
   - `c134-0289`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55225`; field inspection found no abnormal interference but measured Mantis托箱面 about 1 mm higher than the access-position托箱面.
   - `c134-0327`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55405`; field inspection found the tote partly riding on the limit strip/限位条.
   - `c134-0369`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 55272`; source preliminary judgment was tote skew.
   - `c134-0229`: UI error `1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55341`; field photo showed tote partly on the B1-side挡边, making mechanical load/interference a high-value branch.
   - `c134-0076`: UI error `1102#NODE402_ERROR#ARM_MOTOR_SINGLE#following error, 55214`; NXP/wormhole at failure time were 0KB, so backend logs alone cannot prove motor hardware failure.
   - `c134-0357`: NXP records `ARM_MOTOR_SINGLE#following error, 10307` and `MoveArms -> FaultReaction`; photo shows tote in access/pull area, but exact contact/load cause is unresolved.
12. For `ARM_MOTOR_SINGLE#stall`, inspect physical obstruction and excessive load first.
   - `c134-0156`: UI showed `1102#NODE402_ERROR#ARM_MOTOR_SINGLE#stall`; NXP recorded `node402 fault history recorded: ARM_MOTOR_SINGLE#stall, 56614` and `MoveArms -> FaultReaction`; photo shows tote close to side guide/access mechanism.
13. For deposit/unload following error, inspect shelf/tote clearance before motor hardware.
   - `c134-0270`: UI/NXP show `ARM_MOTOR_SINGLE#following error, 10260` while depositing `TOTE-H-101665`; field inspection found tote bottom interfered with shelf crossbeam/横梁.
   - `c134-0259`: source concludes Mantis plane was lower than shelf/storage position at `B7-L15-T4`; adjust Mantis deposit height before chasing motor hardware.
   - `c134-0434`: FLO shows `M-A1-S1-1` `ARM_MOTOR_SINGLE#following error, 55259` while extracting `TOTE-H-100281`; source says `A1-S2-B4` pick position needs lowering `6MM`, so height/access geometry is the first branch.
   - `c134-0430`: FLO shows `M-A2-S1-1` `ARM_MOTOR_SINGLE#following error, 10040` while extracting `TOTE-L-600316`; source says `A2-S2-B6` whole pick is biased toward `B1`, matching offset/external-load before motor-hardware diagnosis.
14. For command-cache errors, inspect RCS/RMS command lifecycle before hardware.
   - `c134-0013`: `"Could not get RobotCommand ... from local commands dictionary"` while mechanism had not extended; clear plus reset arms recovered.
15. For anti-pinch sensor mismatches, verify physical obstruction and IO mapping.
   - `c134-0008`: UI showed `antiPinchSensors front - Expected: False Actual: True`; field text said fork was not blocked and tote was not clamped.
   - `c134-0425`: NXP confirmed `PIN_SENSOR_ANTIPINCH_RIGHT is not as expected. expected value: false, actual value: true` and `FUTURE_STATE_NOT_MATCH#PIN_SENSOR_ANTIPINCH_RIGHT#Expected: false#Actual: true`; repeated GPIO toggles support sensor/IO instability branch.
   - `c134-0431`: backend state showed `antiPinchSensors.left=true` while `M-A3-S2-2` was idle/no obstacle and task failed with `[WARNING]FUTURE_STATE_NOT_MATCH#PIN_SENSOR_ANTIPINCH_LEFT#Expected: false#Actual: true`; fault-time NXP/wormhole logs were 0 B.
   - `c134-0303`: FLO screenshot marked `Anti-pinch Rear`; field inspection found fork looseness, and later maintenance suspected belt pressure-block looseness causing belt looseness.
16. For image/text-only pull-offset cases, accept the operational offset conclusion but keep the root cause bounded.
   - `c134-0368`: `A2-S2-B12-L10-T3` pull failed; arm biased toward `B13`; source action was adjusting pull offset toward `B1` about `7mm`.
   - `c134-0432`: `A2-S2-B6` 13:13 pull failed; whole pick biased toward `B1`; same location recurred in `c134-0430` at 18:53 with FLO following error.
   - `c134-0435`: title says `M-A3-S2-1`, body says `M-A2-S2-1`; `A3-S2-B5-L5-T4` pull failed and source action was adjusting toward `B1` by `3-4mm`. Preserve the robot-label conflict.

### Evidence

- RMS/RCS command-set lifecycle with command index and timestamps.
- NXP logs for HSM, node402, quick stop, target reached, state mismatch.
- CAN logs for pull motor, fork, finger motors, `60FD` IO, TPDO timing.
- SAS task/container and available shelf/PD/tunnel selection logs.
- access node and accessNodeOffset config for rest, load, deposit points.
- torque curves for pull/fork/finger motors.
- video/photo showing tote position, fork extension, finger position, PT/PD deformation/interference.
- photos/videos showing sensor panel state, fork looseness, belt pressure-block condition, and belt tension.
- robot label from wormhole/MQTT when title text is ambiguous.
- UI screenshots for exact FLO/Fleet errors such as `ARM_MOTOR_SINGLE#following error`, `ARM_MOTOR_SINGLE#stall`, `antiPinchSensors front`, and missing `RobotCommand`.

### Exclusions

- Tote is already in target location: do not assume pull failed physically; inspect premature command complete and sensor mismatch.
- No metal interference visible after clear: still inspect quick stop and motor state; quick stop may have been transient.
- Expected/actual coordinate differs by 1 mm at A2: inspect offset config before hardware.
- Torque >200%: prioritize physical interference, deformation, or tote/finger contact.
- No RMS logs: classify as unresolved and request reproduction logs; do not invent conclusion.
- Same task has no available PD/tunnel: route to scheduler/traffic, not Mantis actuator first.
- Startup `failed to sdo client download` or LED-type errors are evidence, but not enough to prove the tote-skew root cause without the command/pull window.
- A Mantis traffic deadlock with successful device commands should not be treated as a Mantis actuator fault first.
- If Mantis shaking clears only after an Ant below leaves, inspect reservations, mode changes, and shared access-zone occupancy before motor hardware.
- UI says front load sensor error: verify against video and CAN/GPIO mapping before replacing the sensor.
- UI says `ARM_MOTOR_SINGLE#following error`: inspect tote skew,挡边 contact, and arm load before concluding motor/driver failure.
- Source says Mantis plane is lower than shelf/货位: measure and adjust deposit height/access-node offset before motor debugging.
- UI says `ARM_MOTOR_SINGLE#stall`: inspect physical obstruction, tote side-guide contact, and torque/current before concluding motor/driver failure.
- UI says missing `RobotCommand`: inspect command lifecycle/local dictionary/cache first; mechanical inspection is secondary if the mechanism did not move.
- `coordY` differs by 1 mm before `EXTEND`: inspect access-node/offset generation and tolerance before replacing Mantis hardware.
- Left anti-pinch true with no physical neighbor/obstacle: inspect sensor, wiring, IO mapping, and debounce before concluding scheduler failure.
- Right/top anti-pinch future-state mismatch during arm movement: inspect GPIO pulse timing, wiring, IO mapping, and physical obstruction before replacing arm motor hardware.
- Rear anti-pinch trigger with field-visible fork/belt looseness: inspect mechanical mounting and belt pressure block before replacing sensor/electronics.
- Image/text-only offset recommendations are operationally useful but not enough to prove motor, driver, or firmware root cause.
- `ARM_MOTOR_SINGLE#following error` with a field offset/height recommendation should be routed through geometry/load checks before replacing motor hardware.

### Examples

- `c134-0267`: quick stop, missed short IO event risk, stale target-reached after operation enabled, and premature complete explain tote placed but command failure.
- `c134-0351`: `coordY` mismatch `11341` vs expected `11342` traced to offset `-7` versus `-6`.
- `c134-0140`: `coordY` mismatch `18067` vs expected `18068` blocked `EXTEND`; manual move to Bay1 recovered operation.
- `c134-0311`: two Ant deposit tasks were generated when only one A2 position was available, leaving Mantis with tote and no deposit path.
- `c134-0362`: high fork torque/interference lifted tote tail, disturbed fingers, and left tote partly on Mantis.
- `c134-0364`: tote not placed correctly and finger motors 3/4 stalled, likely finger hit tote.
- `c134-0054`: M1/A-104/A-106 deadlock was operationally explained by Mantis避让/task sequencing and blocked return path.
- `c134-0026`: Mantis shaking plus stopped Ant below was operationally recovered by computer-side manual mode allowing the Ant to leave; logs point to scheduler/reservation/mode interaction, not confirmed motor fault.
- `c134-0013`: missing local `RobotCommand` caused extraction/load failure before mechanism extension; clear plus reset arms recovered.
- `c134-0270`: deposit/unload following error `10260` was operationally explained by tote-bottom interference with shelf crossbeam/横梁.
- `c134-0259`: A2 `B7-L15-T4` deposit failure was operationally attributed to Mantis plane lower than the shelf position; recommended action was adjusting Mantis deposit height.
- `c134-0303`: FLO marked `Anti-pinch Rear`; field inspection found fork looseness and likely belt pressure-block looseness, making mechanical maintenance the primary branch.
- `c134-0368`: `A2-S2-B12-L10-T3` pull failure was operationally attributed to arm bias toward `B13`; recommended offset correction was toward `B1` about `7mm`.
- `c134-0430` and `c134-0432`: repeated `A2-S2-B6` M2 pull failures were operationally attributed to pick offset bias toward `B1`; `c134-0430` additionally records `ARM_MOTOR_SINGLE#following error, 10040`.
- `c134-0434`: `A1-S2-B4` M1 pull failure records `ARM_MOTOR_SINGLE#following error, 55259`; source action was lowering the pick position by `6MM`.
- `c134-0435`: `A3-S2-B5-L5-T4` pull failure source action was adjusting toward `B1` by `3-4mm`; robot label remains inconsistent between title and body.

- `c134-0079`: missing RMS logs block task sequence analysis.
- `c134-0308`: no RMS logs; only similar to prior A2 offset/state issue.
- `c134-0316`: failed task and 1 mm EXTEND mismatch observed, but logs rolled off.
- `c134-0317`, `c134-0318`: repeated B2 PT failures suggest mechanical/torque issue; exact root cause not confirmed.
- `c134-0195`: A2 pull failure with skewed tote; NXP only has startup `canopen_stack`/`node_led` errors and MQTT label `M-A2-S1-1`, so root cause remains unresolved.
- `c134-0386`: M2 deposit/unload failed for `TOTE-L-600431`; source claims front load sensor error and logs show later orphaned tote state, but sensor/CAN root cause is unresolved.
- `c134-0008`: front anti-pinch expected/actual mismatch was visible and recovered after initialize, but sensor hardware versus transient signal remains unproven.
- `c134-0431`: left anti-pinch false trigger/stuck true caused `FUTURE_STATE_NOT_MATCH`; sensor hardware, wiring, IO mapping, and debounce branch remains unresolved because NXP/wormhole logs were 0 B.
- `c134-0425`: right anti-pinch false trigger caused `FUTURE_STATE_NOT_MATCH`; NXP confirms sensor mismatch and GPIO toggles, but exact physical versus electrical cause remains unresolved.
- `c134-0076`: `ARM_MOTOR_SINGLE#following error, 55214`; fault-time NXP/wormhole logs were 0KB, so root cause remains unresolved.
- `c134-0085`: `ARM_MOTOR_SINGLE#following error, 55344`; CAN1 was 0KB, so motor/driver versus external-load branch remains unresolved.
- `c134-0096`: `ARM_MOTOR_SINGLE#following error, 55386`; CAN pcaps and images exist, but NXP/wormhole logs are absent and decoded CAN/physical cause remains unresolved.
- `c134-0141`: `ARM_MOTOR_SINGLE#following error, 55355`; photo shows tote skew at `A2-S2-B2`, but NXP/CAN/RMS are absent.
- `c134-0204`: `ARM_MOTOR_SINGLE#following error, 55490`; photo shows tote skew at `A2-S2-B5`, but NXP/CAN/RMS are absent.
- `c134-0205`: `ARM_MOTOR_SINGLE#following error, 10277`; source reports tote skew at `A3-S2-B12-PT`, but NXP/CAN/RMS are absent.
- `c134-0010`: `ARM_MOTOR_SINGLE#following error, 55299`; NXP confirms `MoveArms -> FaultReaction`, and source/photo suggest PT sheet-metal or tote skew/contact branch, but exact cause remains unresolved.
- `c134-0153`: repeated following errors `10217` and `10245`; exact physical/CAN cause remains unresolved.
- `c134-0154`: repeated following errors `55317` and `55423`; photo shows incomplete pull, but exact physical or motor cause remains unresolved.
- `c134-0155`: `ARM_MOTOR_SINGLE#following error, 55347`; NXP confirms fault history and photo shows incomplete pull, but exact physical or motor cause remains unresolved.
- `c134-0156`: `ARM_MOTOR_SINGLE#stall, 56614`; NXP confirms stall and photo shows side-guide/contact risk, but exact obstruction or hardware cause remains unresolved.
- `c134-0172`: `ARM_MOTOR_SINGLE#following error, 55388`; NXP confirms fault history and photo shows tote in access area, but exact cause remains unresolved.
- `c134-0229`: `ARM_MOTOR_SINGLE#following error, 55341` with tote partly on B1-side挡边; likely external load/interference branch, but exact motor/CAN proof remains unresolved.
- `c134-0289`: `ARM_MOTOR_SINGLE#following error, 55225`; field found no direct interference but about 1 mm height mismatch, so cause remains unresolved.
- `c134-0327`: `ARM_MOTOR_SINGLE#following error, 55405`; tote partly riding on limit strip/限位条 is strong physical evidence, but CAN torque proof is not closed.
- `c134-0357`: `ARM_MOTOR_SINGLE#following error, 10307`; NXP confirms fault transition and photo shows tote in access area, but physical/CAN root cause remains unresolved.
- `c134-0369`: `ARM_MOTOR_SINGLE#following error, 55272`; source observed tote skew, but exact contact point/CAN proof remains unresolved.
- `c134-0217`: `A2-S2-B2` PT取箱失败 with complete CAN/NXP assets; NXP text search found no node402 fault/following-error string, so RMS/FLO error and CAN decoding are still needed.
- `c134-0168`: `A3-S2-B9` pull failure with only images; source says No.2 Mantis could not be connected, so logs could not be extracted.
- `c134-0303`: NXP/wormhole were 0KB, so firmware/CAN branch is not closed even though mechanical evidence is strong.
- `c134-0368`, `c134-0430`, `c134-0432`, `c134-0434`, `c134-0435`: no NXP/CAN/RMS/SAS logs were provided, so motor/driver/firmware root cause is not closed.

## C134 Mantis Power And Network Knowledge

Knowledge file: `docs/c134/knowledge/mantis-power-network.md`

### First Checks

1. Separate robot-side power from scheduler/service failure.
   - `c134-0350`: Mantis could move in manual mode and Ants still avoided obstacles, so robot power/motion was not primary; SAS did not issue EXTRACT tasks.
2. Inspect SAS task orchestration and Redis.
   - `c134-0350`: SAS schedules every 10s; at `2026-03-28T04:00:34.741` and `04:00:45.258` Redis read timed out, then orchestration logs stopped. Suspected Redis lock not released around `RobotOrchestrationService.kt` after line 120.
3. If Mantis data state mismatches physical tote state after error, follow recovery process.
   - `c134-0438`: after Mantis error, tote data inaccurate is expected; move problem tote to orphan area and rerun inbound flow.
   - Embedded branch: at UTC `2026-01-26T05:18:52Z`, finger motor position mismatch and four finger motor voltages were instantly pulled low; fork-side ALLCAN-590 IDs `0x14` and `0x15` were normal.
4. For frequent disconnect/delay, prove whether packets are lost or batched/retransmitted.
   - `c134-0150`: A105 and A101 state messages around `2026-01-26 17:30:37-17:30:41` showed combined packets; robot still met 1s reporting period.
   - pcap from two wormholes showed retransmission around 17:30:38, pointing to wormhole-to-AP or server-side network path.
5. For whole-site stop, inspect Kafka/server before individual robot network.
   - `c134-0353`: all robots disconnected/no robots after refresh, then partial recovery; action plan was collect Kafka logs to EFK, widen controller timeout, split controller/broker, and replace HDD with SSD in similar environments.
6. For Mantis `Unknown` after reported reboot, prove reboot from local uptime and boot markers before diagnosing cause.
   - `c134-0182`: NXP changed from `2026-01-05T10:07:44Z [UPTIME:351586]` to `2026-01-05T10:09:12Z [UPTIME:39] *** Booting Zephyr OS build 120b940a00e8 ***`; FLO showed `M-A3-S2-2` `Unknown` and failed deposit/unload tasks for `TOTE-H-200050`.
   - `c134-0053`: NXP changed from uptime `[87:06:09.836]` before the event to a boot marker and later `[00:07:29.961]`; Wormhole also showed DHCP/DHCPACK around `Mon Feb 2 07:06:54 2026`.
   - `c134-0277`: NXP started at `2026-03-17T21:49:46Z [00:00:30.141]`, then initialized `M-A3-S2-1` from `HsmMain::Unknown -> Init`; file names say `A1巷道`, but NXP `robotLabel` says `M-A3-S2-1`.
   - `c134-0253`: FLO screenshot showed `M-A3-S2-1` `Unknown` and CAN files at `2026/2/24 8:26` were 0KB, but NXP uptime was continuous from `2026-02-22T17:20:21Z [00:00:30.141]` to `2026-02-24T00:24:07Z [31:04:07.408]`; do not claim an event-time reboot from this log alone.

### Evidence

- SAS orchestration logs around task issue and 10s scheduling cycle.
- Redis timeout/lock logs and whether scheduling resumes after timeout.
- Mantis NXP/CAN logs for finger motor voltage/position mismatch.
- FLO/data container state versus physical tote state.
- robot MQTT/state timestamps, broker receive timestamps, and pcap from wormhole/AP/server.
- Kafka controller/broker logs, server disk I/O, EFK load.
- NXP boot markers, uptime before/after the reported event, and `HsmMain::Unknown -> Init` initialization sequence.
- Wormhole DHCP, dumpcap restart, and CAN capture file-number resets.
- FLO screenshots for exact robot label, `Unknown` state, active failed task, tote ID, and mode.
- 0KB CAN/NXP/wormhole files as missing-evidence signals rather than negative proof.

### Exclusions

- Manual Mantis movement works and obstacle avoidance still works: exclude Mantis power as primary, inspect SAS/task orchestration.
- Robot state messages are batched but local robot timestamps are 1s apart: do not classify as robot not reporting.
- Data says no tote after Mantis error but physical tote exists: treat as post-error data inconsistency and follow orphan recovery.
- Whole-site disconnect affects all robots: inspect Kafka/server/network path before individual Mantis hardware.
- FLO `Unknown` alone does not prove reboot; require NXP low uptime/boot marker, Wormhole restart/DHCP, or power evidence.
- Startup `canopen_stack`/`node_led` errors after boot are not root cause unless they precede and explain the reset.
- If NXP uptime is continuous through the reported window, classify the report as unconfirmed reboot or log gap.

### Examples

- `c134-0350`: SAS did not issue Mantis EXTRACT tasks; Redis timeouts preceded scheduler silence; SAS restart restored task dispatch.
- `c134-0438`: Mantis physical/data mismatch after error should be handled by orphan-area recovery; fork ALLCAN-590 IDs `0x14`/`0x15` had no abnormality.
- `c134-0150`: pcap showed retransmissions around `17:30:38`, while robot local state interval remained about 1s.
- `c134-0053`: FLO showed `M-A3-S2-1` `Unknown`; NXP uptime dropped from 87h to post-boot minutes and Wormhole showed DHCP reconnect around the event.
- `c134-0182`: `M-A3-S2-2` deposit/unload failure for `TOTE-H-200050`; NXP proved reboot from `[UPTIME:351586]` to `[UPTIME:39]`.
- `c134-0277`: nighttime reboot/Unknown report; NXP low uptime and initialization sequence prove reboot/initialization, with robotLabel `M-A3-S2-1`.

- `c134-0350`: exact Redis-lock failure path still needed code or reproduction proof.
- `c134-0353`: visible text contains plan and hypothesis, but not final verified root cause.
- `c134-0053`, `c134-0182`, `c134-0277`: reset source remains unknown; current evidence proves reboot but not power, firmware, or network root cause.
- `c134-0253`: event-time reboot is not proven because NXP uptime is continuous through the reported 2026-02-24 08:21 CST window; CAN files were 0KB.

## C134 Workstation WLED Knowledge

Knowledge file: `docs/c134/knowledge/workstation-wled.md`

### First Checks

1. Confirm this is workstation equipment.
   - WLED/HLED/light-strip, station light command, grid/sensor display, and WS full-box prompts belong to workstation.
   - Do not classify as Ant only because an Ant carried a tote away from WS001/WS002.
2. Align real event time, monitor time, and service log time.
   - Video can be offset from actual time; example `c134-0300` notes monitor time was about 25-26 seconds fast.
3. Check whether this is reboot, delay, wrong color, or missed cue.
   - Reboot: all/partial WLED modules reset or color falls back unexpectedly.
   - Delay: light command exists but execution waits behind another station queue.
   - Wrong/missing cue: UI/task is normal but the physical light/sensor signal is absent or misleading.
4. For delay, inspect station light-command queue isolation.
   - `c134-0110` and `c134-0149` show WS002 light delay tied to queued commands; separating station queues is the confirmed fix in `c134-0110`.
5. For reboot, inspect WLED module power/network/reset evidence.
   - Need module screenshots/video, WLED status page/export if available, station controller logs, and power-cycle timing.
   - Visible text alone is usually insufficient to prove root cause.
6. For sensor/operator-cue cases, inspect physical sensor state and UI prompt mapping.
   - `c134-0439` indicates full-box sensor trigger was not obvious enough, causing operators to identify the wrong picking position.
   - `c134-0292` reports `WS002-1` photoelectric/light-curtain sensor abnormal flashing while the paired sensor stayed red/triggered; classify as workstation sensor/electrical/alignment first.

### Evidence

- Exact station and cell: WS001/WS002, workstation index, grid/cell index.
- Exact event time and monitor offset.
- Video covering before/after station task completion or sensor trigger.
- Station task logs and light-control logs with queue size, stationId, workstationIndex, tote label, and on/off command.
- WLED/HLED module status screenshots, reset time, module count affected, and power/network state.
- For sensor issues: sensor indicator state, physical trigger condition, UI prompt/screenshot, operator action timeline.

### Exclusions

- If the only symptom is WLED/HLED/light strip behavior, exclude Ant power/motion unless robot logs also show reboot, motion error, or task failure.
- If Ant leaves the station normally and only the light changes incorrectly, start with workstation light-control logs.
- If a WS location appears in an Ant motion/load symptom, keep the case in Ant motion/load unless WLED/HLED or station sensor behavior is the observed failure.
- If video time is offset, do not align logs by video timestamp without correcting the offset.
- If visible text lists images/video only, mark branch `blocked` until local media is available.

### Examples

- `c134-0110`: WS002 light delay after task completion; logs showed 1号工作台 light command queued and affecting 2号工作台; resolution was splitting 1号 and 2号 workstation light commands into separate queues.
- `c134-0149`: WS002 light delay over 4s; logs include queued lighting control messages and queue sizes around task transition.
- `c134-0439`: full-box sensor trigger was not obvious, causing misidentification of WS001 picking position; recommendation was red constant light after return button when full-box sensor is triggered.

- `c134-0106`, `c134-0108`, `c134-0109`, `c134-0114`, `c134-0115`, `c134-0116`, `c134-0191`, `c134-0300`, `c134-0349`: WLED/HLED reboot symptoms need local video/module/controller evidence or exact log correlation.
- `c134-0211`, `c134-0212`, `c134-0213`, `c134-0214`: light-strip abnormal color after robot self-check; robot operation/FLO may be normal, but local light module evidence is missing.
- `c134-0292`: WS002-1 light-curtain/photoelectric sensor abnormal flashing; controller/electrical/alignment evidence still needed.

## C134 Scheduler Traffic Knowledge

Knowledge file: `docs/c134/knowledge/scheduler-traffic.md`

### First Checks

1. Build the command timeline before robot-side diagnosis.
   - Preserve the exact `robotCommandLabel`, task label, expected state, future state, target coordinates, velocity, and acceleration.
   - Example `c134-0447`: command `A-103-S2182292-2026-06-12T06:58:58.173Z-0`.
2. Compare expected pose, future pose, and MOVE target geometry.
   - In `c134-0447`, expected state is near `118719,99000`, but command target is `118656,104226`.
   - The X coordinate shifts by `-63 mm` while Y moves about `+5226 mm`, creating a slight diagonal instead of staying on the `x=118719` DM line.
3. Check whether NXP executed the command it received.
   - `c134-0447` NXP received `MOVE_EVENT: 118656, 104226`.
   - The robot trajectory followed the command line; relative error to the command line stayed small before DM loss.
4. Interpret DM loss as possible downstream evidence.
   - In `c134-0447`, DM reads progressed on `118719GG099000`, `118719GG100000`, `118719GG100750`, then became continuous `NoRead`.
   - Since the command line drifted away from the DM-code line, scanner loss is more consistent with bad MOVE geometry than dirty floor code or vehicle runout.
5. Escalate to RMS/path-planning root cause when command geometry is invalid.
   - Check map node conversion, scheduler-to-robot coordinate transform, path segment generation, and any offset injected between expected state and future state.

### Evidence

- RCS/RMS command records with `expectedState`, `futureState`, `coordX`, `coordY`, `finalTargetX`, `finalTargetY`, `maxVelocity`, and `maxAcceleration`.
- NXP log proving the robot received the same target as the service command.
- DM read/no-read sequence before fault.
- Actual pose samples before fault to compare against the command line.
- Map/path segment definition for the expected DM line.
- Any coordinate transform, offset, or map-node conversion logs around the command-generation window.

### Exclusions

- If the NXP target differs from RCS/RMS target, inspect command transport or translation before path planning.
- If expected state, future state, and MOVE target are all aligned to the same DM line, do not use this branch; inspect floor code, scanner, drivetrain, and braking feasibility.
- If trajectory deviates significantly from the received command line, inspect robot-side motion/localization or drivetrain.
- If DM loss begins before the bad command segment, do not treat the scheduler command as the first cause.
- Do not classify the case as dirty floor code only because `DM_LOST` appears; compare command geometry first.

### Examples

- `c134-0447`: A-103 stopped at `2026-06-12 14:59`. RCS/RMS generated a target `118656,104226` from expected state near `118719,99000`; NXP received and followed that target, then lost DM reads after moving away from the `x=118719` DM line.

- `c134-0447`: exact RMS/path-planning defect is not closed. Follow up on why `futureState.coordX = 118656` was generated instead of a DM-line-aligned target.
