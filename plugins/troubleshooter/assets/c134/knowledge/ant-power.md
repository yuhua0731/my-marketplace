# C134 Ant Power Knowledge

source_set: accepted high-priority `Ant/power`; focused cleanup sample `docs/c134/high-value-sample-cleanup-20260604.md`
case_count: 95
status: refined into evidence-strength patterns and route-ready decision rules from high-priority accepted cases

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

## Evidence Strength Matrix

Use the strongest available evidence first; do not let the issue title decide the branch.

| Evidence | Diagnostic strength | Use it for | Do not use it for |
|---|---:|---|---|
| `UPTIME` drop plus boot/startup lines | strong | confirming reboot/shutdown timing | proving the root cause by itself |
| Battery/SOC falls to 0% or below shutdown threshold for minutes | strong | confirming low-battery shutdown branch | proving why charging was missed |
| Abrupt SOC drop across reboot, but no BMS/CAN frames | medium | leading BMS/boost/charging-power branch | final hardware root cause |
| `NODE402_ERROR#...#under voltage` screenshot | medium | confirming UI symptom and affected node | proving battery/BMS/boost cause |
| Logs start only after startup | weak | proving post-event window exists | confirming pre-reset cause |
| Continuous `UPTIME` through report window | strong negative | excluding reboot in that window | excluding all operator-visible faults |
| RVS/SAS/Redis/MQTT service errors | strong for service branch | explaining no-device/no-action/mode loops | proving robot power failure |
| NIC/MQTT disconnect near reboot | medium | network correlation branch | reboot causality without timing proof |

## Decision Checklist

Use this order to avoid turning every restart-like report into the same unresolved case.

1. `UPTIME` continuity.
   - Discontinuous: confirm reboot timing, then look for pre-reset fatal/panic, BMS/boost, storage, or service correlation.
   - Continuous through the reported window: exclude reboot in that window and verify date/time or operator wording.
   - Missing pre-window: mark `log-window-gap`; request earlier NXP/system logs instead of guessing hardware.
2. Battery and voltage evidence.
   - Sustained SOC below shutdown threshold confirms low-battery shutdown, then inspect charging dispatch/reservation separately.
   - Abrupt SOC drop across reboot makes BMS/boost/charging contact the leading branch, but final cause still needs CAN/BMS/charger evidence.
   - `under voltage` screenshot confirms the UI/motor-node symptom only; service logs alone cannot prove electrical root cause.
3. Charging workflow.
   - If the robot is carrying a tote or has an unfinished task, check whether charge dispatch is intentionally suppressed.
   - If another robot is assigned to an occupied charger, verify reservation release happens after physical departure.
4. Service-side false leads.
   - RVS no response, SAS/Redis failure, or wrong MQTT host can explain FLO no-device/no-action/mode loops without robot power loss.
   - Network/MQTT errors before reboot are correlation until timing, firmware, and CAN/BMS evidence close causality.
5. Hardware/storage branch.
   - Overlay full, SD-card mount/log loss, motor heartbeat loss, or post-maintenance init failures route to embedded-software/CAN before charging logic.

## Pattern Library

### Confirmed Low-Battery Shutdown

Pattern: battery trend crosses the shutdown threshold before the robot powers off.

- `c134-0019`: A110 battery dropped from 24% to 0% between 19:00 and 20:00; boost module shut down after sustained low battery. The operational cause was missed charging dispatch.
- Diagnostic rule: after confirming shutdown, inspect scheduling/charging dispatch separately; the battery symptom and dispatch cause are two different layers.

### Charging Dispatch Or Reservation Gap

Pattern: robot needs charging but task/reservation state prevents timely charge.

- `c134-0095`: A103 released charge-2 reservation before physically leaving; A104 was assigned the same pile and blocked.
- `c134-0223`: robots waiting with unfinished/carrying state did not charge in time.
- Diagnostic rule: charge-point reservation must be released after physical departure, not just after charge completion.

### Reboot Confirmed, Cause Unknown

Pattern: `UPTIME` reset and startup markers confirm reboot, but no pre-reset fatal, BMS, or CAN evidence closes the cause.

- Use this bucket for many repeated restart cases instead of expanding every unresolved ID.
- Representative cases: `c134-0012`, `c134-0036`, `c134-0124`, `c134-0414`, `c134-0422`.
- Diagnostic rule: if only reboot timing is confirmed, route to embedded-software first, then CAN/BMS/boost if power symptoms or SOC drop exist.

### Abrupt SOC Drop During Or Near Charging

Pattern: reboot/shutdown is confirmed and SOC changes far more than normal discharge.

- `c134-0124`: two reboots around `2026-01-06T02:08:43Z` and `02:11:53Z`; battery changed from 83 to 55 in logs, source says 78% to 53%.
- `c134-0414`: two events around `2026-01-01T04:22:21Z` and `04:45:05Z`; first event has 97 to 69 SOC drop.
- Diagnostic rule: BMS/boost/charging contact becomes the leading branch, but final cause needs CAN/BMS or charger-contact evidence.

### Log Window Disproves Reported Reboot

Pattern: source says reboot, but downloaded logs cover the window and `UPTIME` is continuous.

- `c134-0070`: NXP and wormhole cover 08:50-09:20 China time; no `UPTIME` drop.
- `c134-0144`: NXP and wormhole cover the reported window; no `UPTIME` drop despite source saying reboot with buzzer.
- Diagnostic rule: mark reboot unconfirmed and verify source time/date before searching for hardware cause.

### Screenshot-Only Under-Voltage

Pattern: UI confirms a motor/node under-voltage error, but service logs cannot explain voltage source.

- `c134-0024`: screenshot confirms A-109 `1102#NODE402_ERROR#MOVER_MOTOR_LEFT#under voltage`; SAS only shows task/availability context.
- Diagnostic rule: accept the symptom; keep BMS/boost/electrical root cause unknown without NXP/CAN/BMS.

### Storage/Overlay Reboot

Pattern: repeated reboot plus storage/overlay abnormality.

- `c134-0299`: A105 reboot at WS002-2; overlay full and SD-card abnormality were linked, resolved by SD-card replacement.
- Diagnostic rule: check overlay usage, mount health, and missing/rotated logs before swapping unrelated power parts.

### Motor Heartbeat / E-Stop Recovery

Pattern: startup/init failure after motor heartbeat disappears.

- `c134-0409`: motor 2 stopped heartbeat after `2025-12-15T21:48:06.782346337+0800`; soft reboot could not recover.
- Diagnostic rule: if E-stop is released while the robot is still moving/pushed, motor protection can enter a bad state; stop, re-hit E-stop, wait 2s, release.

### Service-Side False Power Leads

Pattern: operator sees no devices/no action/mode loops, but robot-side power evidence is absent.

- `c134-0221`: RVS no response caused FLO no-device display; restarting RVS recovered.
- `c134-0333`: SAS/Redis connection failure caused no robot action after inventory task.
- `c134-0313`: wrong MQTT HOST caused repeated command/mode behavior.
- Diagnostic rule: if multiple robots/UI state are affected or service logs show Redis/RVS/MQTT failure, resolve service branch before robot power.

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

- Confirmed reboot, cause unknown: repeated restart cases with `UPTIME` reset/startup markers but no pre-reset fatal, BMS/CAN, boost-module, storage, or charger-contact proof. Representative IDs: `c134-0012`, `c134-0036`, `c134-0124`, `c134-0235`, `c134-0286`, `c134-0372`, `c134-0414`.
- Pre-window/log-window gap: source reports reboot, but logs start after boot, are 0 KB, or miss the pre-reset period. Representative IDs: `c134-0009`, `c134-0064`, `c134-0065`, `c134-0192`, `c134-0236`, `c134-0260`, `c134-0426`.
- Continuous-uptime contradiction: logs cover the reported window but do not show a reboot; verify source time/date before diagnosing hardware. Examples: `c134-0070`, `c134-0144`.
- Non-chronological package: low-uptime lines exist but exported logs are concatenated/messy, so do not bind them to the reported event until timestamp order is validated. Examples: `c134-0145`, `c134-0178`, `c134-0422`.
- Abrupt SOC drop near reboot/charging: BMS/boost/charging-power is the leading branch, but root cause remains unconfirmed without CAN/BMS or charger-contact evidence. Examples: `c134-0122`, `c134-0123`, `c134-0124`, `c134-0126`, `c134-0143`, `c134-0174`, `c134-0414`.
- Screenshot-only or no-logs reports: accept operational symptom, keep cause unknown. Examples: `c134-0024`, `c134-0147`, `c134-0151`.
- Network/service correlation not causality: frequent NIC/MQTT failures may precede reboot or FLO disappearance, but need AP/server/firmware/CAN timing proof before claiming cause. Examples: `c134-0243`, `c134-0372`.
- Weak duplicate pointer: source only says "same as previous" or lacks usable evidence; keep as low-information training only. Example: `c134-0346`.

## Specialist Routing

- `embedded-software`: reboot markers, NXP/system logs, firmware startup, storage/overlay, motor heartbeat.
- `network-infra`: NIC/AP disconnects, MQTT host, RVS/SAS/Redis/Kafka service symptoms.
- `scheduler-traffic`: charging task dispatch, pile reservation release, unfinished task blocking charge.
- `vision-media`: verify physical charging-pile blocking, robot movement before E-stop release, monitor timestamp offsets.
