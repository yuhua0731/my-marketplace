# C134 Ant Load Handling Knowledge

source_set: accepted high-priority `Ant/load-handling`
case_count: 32
status: draft refined from visible text

## Symptoms

- lift/raise failure or buzzer during load action: `c134-0048`, `c134-0078`, `c134-0180`, `c134-0237`, `c134-0254`, `c134-0340`, `c134-0444`
- PT/PD pick or place failure: `c134-0047`, `c134-0084`, `c134-0086`, `c134-0094`, `c134-0098`, `c134-0102`, `c134-0190`, `c134-0194`, `c134-0215`, `c134-0216`, `c134-0401`
- robot reaches workstation but does not lift or continue, FLO has no error: `c134-0020`, `c134-0152`, `c134-0196`, `c134-0206`, `c134-0249`
- place/lift handling symptom with nearby or alleged reboot: `c134-0061`, `c134-0237`, `c134-0378`
- MQTT/network interruption presenting as handling failure: `c134-0100`, `c134-0254`
- load sensor state mismatch: `c134-0084`, `c134-0094`, `c134-0102`, `c134-0160`, `c134-0169`, `c134-0170`, `c134-0171`, `c134-0181`, `c134-0194`, `c134-0444`
- workstation sensor harness damaged by Ant scissor interference: `c134-0230`

## Fault Tree

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

## Evidence Needed

- FLO/Kafka task, subtask, command, and command-update records.
- WAS/RCS reservation logs, especially overlap and `WorkerTask` state.
- MQTT command and host config.
- NXP lift/load-sensor logs and candump/CAN sensor state.
- video showing tote seating, scissor lift motion, PT/PD contact, and sensor trigger timing.
- physical inspection of PT/PD sheet metal, limit blocks, tote placement, picking-station height, and scissor mechanism.
- battery/boost-module CAN data during lift if buzzer or low-voltage appears.
- exact log coverage end time when an event is reported near the edge of the downloaded window.

## Logs And Files To Inspect

- `nxp.log`, lift/sensor-specific robot logs.
- candump/CAN for load sensor, boost module, lift motor, buzzer/voltage events.
- RCS/RMS `robot_command_set.create`, `robot_command.update`, reservation intersection logs.
- WAS logs for `WorkerTask` and workstation state.
- MQTT logs and `MQTT HOST` config.
- monitor video around lift start, tote contact, and recovery.

## Likely Causes

- stale or incorrect container/task state: `c134-0047`, `c134-0196`
- reservation/state overlap preventing next command: `c134-0152`, `c134-0249`
- tote not seated or temporarily blocked, sensor timing mismatch: `c134-0102`, `c134-0444`
- mechanical interference with PT/PD/workstation geometry: `c134-0086`, `c134-0194`, `c134-0216`, `c134-0230`
- lift power/boost-module abnormality under load: `c134-0180`
- MQTT disconnect or wrong MQTT host causing handling symptoms: `c134-0100`, `c134-0254`
- robot reboot near task/lift window: `c134-0048`
- post-handling reboot with unresolved relation: `c134-0061`
- log-window mismatch for reported lift-time reboot/buzzer: `c134-0378`

## Exclusion Checks

- Manual sensor test normal plus MQTT/candump normal: do not replace sensor first; inspect tote seating and timing.
- FLO no error and robot stopped after completed move/rotation: inspect missing next command and reservation, not lift hardware.
- Error happened after manual TP/clear sequence: verify container ownership/state before physical root cause.
- Tote weight below rating but low-voltage/buzzer present: inspect boost module and supply rather than overload alone.
- Wrong MQTT host or disconnect present: resolve communication/config branch before mechanical debugging.
- Photo/video shows tote tilt or PT contact: classify mechanical interference unless logs prove actuator failure first.
- If logs stop before the reported lift/reboot time, do not mark reboot confirmed.
- If a workstation harness is damaged by Ant scissor motion, keep both workstation sensor and robot mechanical-clearance branches open.

## Handling Recommendations

- Preserve exact command/task/container labels before clearing or TP operations.
- For no-action at WS/PT, check reservations and pending WorkerTask/state before moving the robot manually.
- For load sensor mismatch, compare physical seating video with candump/MQTT sensor transition timing.
- For repeated A1-S2-B2/PT issues, inspect local PT geometry and tote alignment as a cluster, not isolated robot faults.
- For lift buzzer/low voltage, collect boost-module CAN data during the failed lift before swapping parts.
- After returning/repaired robots, verify MQTT HOST is `10.0.64.108` at C134 unless redundancy mode changes.
- For buzzer during lift, collect BMS/boost CAN and NXP/system logs covering the exact second.

## Confirmed Examples

- `c134-0152`: A109 received no new command after move/rotation; A101 and A109 reservations overlapped by about 8 mm.
- `c134-0206`: A111 no-action at WS001-2 was explained by invalid command generation from reservation intersection with A107.
- `c134-0180`: lift reported low voltage and boost-module abnormality branch; tote weight was below nominal capacity.
- `c134-0196`: robot waited because WAS still believed a `WorkerTask` existed.
- `c134-0254`: MQTT HOST was wrong; setting it back to `10.0.64.108` addressed duplicate-command cause.
- `c134-0444`: sensor hardware excluded by MQTT and candump checks; likely delayed tote seating against limit block.
- `c134-0230`: WS002-3 sensor harness was physically broken; operational root cause is Ant scissor interference with harness routing.

## Unresolved Examples

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

## Blocked Asset-Backed Needs-Assets

- `c134-0055`: A-106 did not lift at `WS001-2` with `TOTE-H-200585`; local NXP/system logs show no reboot and lift capability earlier, but missing RMS/gz logs block command/state root cause.

## Specialist Routing

- `robot-motion`: pose/route deviation that causes PT/PD contact or bad lift point.
- `embedded-software`: lift control, load sensor, boost module, CAN/candump, NXP logs.
- `scheduler-traffic`: task/container ownership, reservations, WorkerTask state, command gaps.
- `network-infra`: MQTT disconnect, wrong MQTT host, duplicate commands.
- `vision-media`: tote seating, PT/PD interference, scissor tilt, sensor timing from video.
