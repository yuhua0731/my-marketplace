# C134 Ant Power Knowledge

source_set: accepted high-priority `Ant/power`
case_count: 26
status: draft refined from visible text

## Symptoms

- robot shuts down while moving: `c134-0019`, `c134-0040`
- low-battery robot does not reach charging pile: `c134-0019`, `c134-0040`, `c134-0099`, `c134-0223`
- reboot at charging pile/rest position/running/WS: `c134-0236`, `c134-0239`, `c134-0240`, `c134-0242`, `c134-0243`, `c134-0260`, `c134-0261`, `c134-0298`, `c134-0299`, `c134-0321`, `c134-0324`, `c134-0328`, `c134-0334`, `c134-0346`, `c134-0419`
- blue light after reboot/UNKNOWN: `c134-0050`, `c134-0419`
- startup/self-check failure: `c134-0193`, `c134-0409`
- UI shows no devices or no robot action after task dispatch: `c134-0221`, `c134-0333`
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
   - Examples: `c134-0239` at `[2026-03-09T12:41:55+0800][UPTIME:31]`; `c134-0334` at `[2026-03-31T12:00:36+0800][UPTIME:31]`.
   - If logs begin only after reboot, mark root cause unknown and request earlier system log; examples `c134-0236`, `c134-0260`.
4. Check storage/overlay/SD-card health.
   - Overlay full or SD-card mount/log loss can explain repeated A-105 reboot; examples `c134-0298`, `c134-0299`.
5. Check wireless/network correlation, but do not overclaim.
   - `wwanX`/`phy1-sta0` disconnects appear in several reboot cases.
   - `c134-0242` explicitly says two A107 reboots had no NIC disconnect.
   - Treat NIC disconnect as a branch needing timing correlation, not a confirmed reboot cause.
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
- FLO/Kafka robot state and command status near event.
- charging pile reservation/release events and robot physical departure time.
- network logs for `wwan0`, `wwan1`, `phy1-sta0`, AP packet loss, ping reachability.
- storage checks: overlay usage, SD-card mount history, missing/rotated logs.
- video/screenshot only as timing and physical-state support, not as root-cause proof.

## Logs And Files To Inspect

- `nxp.log`, robot-specific `A-xxx_nxp_*`
- `system.log`, `wormhole.log`, robot-specific `A-xxx_system_*`
- CAN/pcap when motor heartbeat or boost-module state matters: `can2.pcap`
- service logs: RVS, SAS, Redis, Kafka, MQTT host/config
- charging scheduler/reservation records

## Likely Causes

- low-battery shutdown because charging task was not dispatched in time: `c134-0019`, `c134-0040`, `c134-0099`
- charging-design gap: robot carrying tote/in unfinished task does not go charge: `c134-0223`
- charging pile reservation released too early: `c134-0095`
- SD-card/overlay storage abnormality: `c134-0298`, `c134-0299`
- log-download gap hiding pre-reboot evidence: `c134-0236`, `c134-0260`
- firmware gyro initialization issue: `c134-0193`
- motor protection/heartbeat loss after E-stop recovery while moving: `c134-0409`
- upstream service/config issue, not robot power: `c134-0221`, `c134-0313`, `c134-0333`

## Exclusion Checks

- Battery is normal near reboot: exclude pure low-voltage shutdown; continue storage/system/network.
- `UPTIME` did not reset: exclude reboot; inspect application/service state instead.
- FLO shows UNKNOWN but robot blue light is normal after startup: do not classify as hardware failure without logs.
- NIC disconnect is not time-aligned with reboot or absent in same robot sequence: do not conclude network caused reboot.
- FLO no-device/no-action affects many robots while IO/IOCS still works: inspect RVS/SAS/Redis before robot-side power.
- Logs start after the event: mark root cause unknown and request pre-event local logs.

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

- `c134-0236`, `c134-0260`: pre-reboot logs missing due to download gap; root cause unknown.
- `c134-0239`, `c134-0240`, `c134-0261`, `c134-0321`, `c134-0328`, `c134-0334`: reboot confirmed by `UPTIME` reset; visible text does not prove root cause.
- `c134-0243`: frequent NIC disconnects on A107/A112/A109 observed; causality to reboot not confirmed.
- `c134-0346`: only marked same as previous reboot; evidence insufficient.

## Specialist Routing

- `embedded-software`: reboot markers, NXP/system logs, firmware startup, storage/overlay, motor heartbeat.
- `network-infra`: NIC/AP disconnects, MQTT host, RVS/SAS/Redis/Kafka service symptoms.
- `scheduler-traffic`: charging task dispatch, pile reservation release, unfinished task blocking charge.
- `vision-media`: verify physical charging-pile blocking, robot movement before E-stop release, monitor timestamp offsets.
