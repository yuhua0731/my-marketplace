# C134 Ant Power Knowledge

source_set: accepted high-priority `Ant/power`
case_count: 95
status: draft refined from visible text and first asset-backed reboot logs

## Symptoms

- robot shuts down while moving: `c134-0019`, `c134-0040`
- low-battery robot does not reach charging pile: `c134-0019`, `c134-0040`, `c134-0099`, `c134-0223`
- reboot at charging pile/rest position/running/WS/lift: `c134-0012`, `c134-0035`, `c134-0036`, `c134-0057`, `c134-0058`, `c134-0063`, `c134-0064`, `c134-0065`, `c134-0066`, `c134-0067`, `c134-0068`, `c134-0070`, `c134-0071`, `c134-0072`, `c134-0081`, `c134-0082`, `c134-0083`, `c134-0088`, `c134-0090`, `c134-0091`, `c134-0104`, `c134-0122`, `c134-0123`, `c134-0124`, `c134-0125`, `c134-0126`, `c134-0127`, `c134-0143`, `c134-0144`, `c134-0145`, `c134-0146`, `c134-0147`, `c134-0148`, `c134-0151`, `c134-0163`, `c134-0166`, `c134-0174`, `c134-0176`, `c134-0177`, `c134-0178`, `c134-0192`, `c134-0225`, `c134-0226`, `c134-0235`, `c134-0236`, `c134-0239`, `c134-0240`, `c134-0242`, `c134-0243`, `c134-0260`, `c134-0261`, `c134-0280`, `c134-0281`, `c134-0282`, `c134-0285`, `c134-0286`, `c134-0287`, `c134-0298`, `c134-0299`, `c134-0312`, `c134-0321`, `c134-0324`, `c134-0328`, `c134-0334`, `c134-0338`, `c134-0341`, `c134-0345`, `c134-0346`, `c134-0347`, `c134-0372`, `c134-0374`, `c134-0383`, `c134-0412`, `c134-0414`, `c134-0419`, `c134-0426`, `c134-0437`
- blue light after reboot/UNKNOWN: `c134-0050`, `c134-0419`
- startup/self-check failure: `c134-0001`, `c134-0193`, `c134-0409`
- UI shows no devices or no robot action after task dispatch: `c134-0221`, `c134-0333`
- UI motor under-voltage fault: `c134-0024`
- repeated mode/error behavior from wrong MQTT host: `c134-0313`

## Fault Tree

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

## Evidence Needed

- NXP log covering at least 5 min before and after event.
- system/wormhole log covering at least 30 min before and after event.
- battery percentage/current/voltage trend, especially around low-battery threshold.
- BMS/boost-module CAN frames across at least 60s before the `UPTIME` drop and first 60s after restart.
- FLO/Kafka robot state and command status near event.
- charging pile reservation/release events and robot physical departure time.
- network logs for `wwan0`, `wwan1`, `phy1-sta0`, AP packet loss, ping reachability.
- storage checks: overlay usage, SD-card mount history, missing/rotated logs.
- video/screenshot only as timing and physical-state support, not as root-cause proof.

## Logs And Files To Inspect

- `nxp.log`, robot-specific `A-xxx_nxp_*`
- `system.log`, `wormhole.log`, robot-specific `A-xxx_system_*`
- CAN/pcap when motor heartbeat or boost-module state matters: `can2.pcap`
- For asset-backed reboot cases, inspect both `can1.pcap` and `can2.pcap`; note data gaps such as `c134-0081` CAN1 being 0 KB in the source note.
- service logs: RVS, SAS, Redis, Kafka, MQTT host/config
- charging scheduler/reservation records

## Likely Causes

- low-battery shutdown because charging task was not dispatched in time: `c134-0019`, `c134-0040`, `c134-0099`
- charging-design gap: robot carrying tote/in unfinished task does not go charge: `c134-0223`
- charging pile reservation released too early: `c134-0095`
- SD-card/overlay storage abnormality: `c134-0298`, `c134-0299`
- log-download gap hiding pre-reboot evidence: `c134-0236`, `c134-0260`
- firmware gyro initialization issue: `c134-0193`
- CANopen/node init failure after power-module replacement: `c134-0001` has `failed to motor init 0x3`, `failed to ToF init 0x24`, and INIT `COMPLETE_FAILURE` with `DEVICE_INIT_FAIL#LIFTER_MOTOR` and `DEVICE_INIT_FAIL#SENSOR_TOF`.
- motor protection/heartbeat loss after E-stop recovery while moving: `c134-0409`
- upstream service/config issue, not robot power: `c134-0221`, `c134-0313`, `c134-0333`
- battery/BMS/charging-power instability when SOC drops abruptly across reboot: leading branch for `c134-0122`, `c134-0123`, `c134-0124`, `c134-0126`, `c134-0143`, `c134-0174`, and `c134-0414`, still requiring CAN/BMS proof.

## Exclusion Checks

- Battery is normal near reboot: exclude pure low-voltage shutdown; continue storage/system/network.
- Battery is low-ish but stable, for example 26-36% before reboot: keep low-voltage as a branch but do not mark confirmed without BMS/boost evidence.
- `UPTIME` did not reset: exclude reboot; inspect application/service state instead.
- FLO shows UNKNOWN but robot blue light is normal after startup: do not classify as hardware failure without logs.
- NIC disconnect is not time-aligned with reboot or absent in same robot sequence: do not conclude network caused reboot.
- FLO no-device/no-action affects many robots while IO/IOCS still works: inspect RVS/SAS/Redis before robot-side power.
- Logs start after the event: mark root cause unknown and request pre-event local logs.
- Logs cover the reported window but `UPTIME` is continuous: mark the reboot report unconfirmed and verify event date/time.
- Screenshots only or explicitly no logs: accept as low-confidence operational evidence only; example `c134-0151`.

## Handling Recommendations

- For low battery, first recover safely, then verify why charging was not scheduled or reachable.
- For charging pile conflicts, release reservation only after the robot physically leaves the charging position.
- For repeated A-105 style reboot with overlay full/log loss, check SD-card mount and replace SD card if recurrence matches `c134-0299`.
- For E-stop recovery after motion, ensure the Ant is fully stationary; if motor heartbeat is lost, re-hit E-stop, wait 2s, release.
- For service-side no-action/no-device, restart only the implicated service after collecting logs; do not file as Ant power unless robot-side evidence exists.

## Confirmed Examples

- `c134-0019`: A110 battery fell from 24% to 0%; boost module low-battery shutdown after sustained below-threshold condition; charging not dispatched in time.
- `c134-0095`: A103 released charging reservation before leaving charge 2; A104 was assigned the same pile and blocked.
- `c134-0193`: A102 self-check failure due to gyro initialization; fixed in new firmware.
- `c134-0299`: A105 reboot with overlay full and SD-card log loss; resolution was SD-card replacement.
- `c134-0409`: A111 initialization failed because motor 2 stopped heartbeat; recovery procedure tied to E-stop/motor protection state.

## Unresolved Examples

- `c134-0012`: lift-time reboot confirmed by system UPTIME reset to 32 at `2026-01-31T01:22:57Z`; NXP was 0 KB, so BMS/boost/lift root cause unknown.
- `c134-0192`, `c134-0236`, `c134-0260`: pre-reboot logs missing due to download gap; root cause unknown.
- `c134-0035`, `c134-0036`, `c134-0005`, `c134-0057`, `c134-0058`, `c134-0063`, `c134-0066`, `c134-0067`, `c134-0068`, `c134-0071`, `c134-0072`, `c134-0081`, `c134-0082`, `c134-0083`, `c134-0088`, `c134-0090`, `c134-0091`, `c134-0104`, `c134-0127`, `c134-0146`, `c134-0148`, `c134-0163`, `c134-0166`, `c134-0176`, `c134-0177`, `c134-0225`, `c134-0226`, `c134-0235`, `c134-0032`, `c134-0280`, `c134-0281`, `c134-0282`, `c134-0285`, `c134-0286`, `c134-0287`, `c134-0312`, `c134-0338`, `c134-0341`, `c134-0345`, `c134-0347`, `c134-0372`, `c134-0374`, `c134-0383`, `c134-0412`, `c134-0437`: reboot confirmed by `UPTIME` reset and startup markers; root cause remains unknown without CAN/BMS/boost-module proof.
- `c134-0122`, `c134-0123`, `c134-0124`, `c134-0126`, `c134-0143`, `c134-0174`, `c134-0414`: reboot with abrupt SOC drop after charging/near charge pile; battery/BMS/charging-power branch is strongest but not final without CAN/BMS confirmation.
- `c134-0064`, `c134-0065`, `c134-0426`, `c134-0009`: source reports reboot/found-after-reboot, but downloaded logs start after boot or lack the pre-reset marker; useful for training log-window-gap handling.
- `c134-0070`, `c134-0144`: complete downloaded logs show continuous `UPTIME`; reported reboot is not confirmed and source date/time must be checked.
- `c134-0125`: charging-pile reboot with four buzzer alarms; available logs show post-boot/startup material but not the exact pre-reset marker for reported `12点45分左右`.
- `c134-0145`, `c134-0178`: A107 reboot reports with messy concatenated logs; low-uptime lines exist in package but exact event-time reset remains uncertain.
- `c134-0024`: screenshot confirms A-109 `1102#NODE402_ERROR#MOVER_MOTOR_LEFT#under voltage`; SAS logs give only task/availability context, so BMS/boost/electrical root cause remains unknown.
- `c134-0422`: A-107 offline screenshot plus low-uptime/startup lines in NXP/system logs; package is non-chronological/concatenated, so exact event-time reset remains uncertain.
- `c134-0147`, `c134-0151`: source says no logs available; screenshots show A107 UI/asset absence only, so root cause remains unknown.
- `c134-0239`, `c134-0240`, `c134-0261`, `c134-0321`, `c134-0328`, `c134-0334`: reboot confirmed by `UPTIME` reset; visible text does not prove root cause.
- `c134-0243`: frequent NIC disconnects on A107/A112/A109 observed; causality to reboot not confirmed.
- `c134-0372`: A102 disappeared from FLO; MQTT/network errors preceded reboot, but the causal path from network failure to reboot is not proven.
- `c134-0346`: only marked same as previous reboot; evidence insufficient.

## Specialist Routing

- `embedded-software`: reboot markers, NXP/system logs, firmware startup, storage/overlay, motor heartbeat.
- `network-infra`: NIC/AP disconnects, MQTT host, RVS/SAS/Redis/Kafka service symptoms.
- `scheduler-traffic`: charging task dispatch, pile reservation release, unfinished task blocking charge.
- `vision-media`: verify physical charging-pile blocking, robot movement before E-stop release, monitor timestamp offsets.
