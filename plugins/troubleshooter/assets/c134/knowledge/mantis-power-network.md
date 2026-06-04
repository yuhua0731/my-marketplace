# C134 Mantis Power And Network Knowledge

source_set: accepted high-priority `Mantis/power`, `Mantis/network`
case_count: 8
status: refined into evidence-strength patterns from visible text

## Symptoms

- task issued but no robots move, network normal, FLO no error: `c134-0350`
- Mantis has tote physically but FLO/data says no tote: `c134-0438`
- frequent device disconnect / delayed state delivery: `c134-0150`
- whole-site stop, FLO shows all robots disconnected or no robots after refresh: `c134-0353`
- Mantis FLO `Unknown` after reported reboot or task failure: `c134-0053`, `c134-0182`, `c134-0253`, `c134-0277`
- NXP uptime drops to seconds/minutes with Zephyr boot marker: `c134-0053`, `c134-0182`, `c134-0277`
- suspected reboot with 0KB CAN logs but continuous NXP uptime through the reported window: `c134-0253`

## Fault Tree

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

## Evidence Strength Matrix

| Evidence | Diagnostic strength | Use it for | Do not use it for |
|---|---|---|---|
| manual Mantis movement works and Ant avoidance works | strong | exclude robot power as primary | scheduler root cause without SAS logs |
| SAS/Redis timeout followed by orchestration silence | strong | scheduler/lock branch | robot network fault |
| physical tote present but data says absent after Mantis error | strong | orphan recovery / state mismatch | hardware fault by itself |
| MQTT/pcap batching with robot timestamps still 1s apart | strong | network retransmission/path branch | robot-reporting-period loss |
| whole-site stop with Kafka/server symptoms | strong | server/service branch | individual Mantis diagnosis |
| low uptime / Zephyr boot / `Unknown -> Init` | strong | confirmed reboot | reset source |
| continuous NXP uptime through reported window | strong exclusion | unconfirmed reboot/log gap | proof nothing happened |
| 0KB CAN/NXP/wormhole files | weak/blocking | asset request | negative proof |

## Pattern Library

- Scheduler no-action with healthy robots: `c134-0350`; SAS Redis lock/timeout evidence beats power/network guesses.
- Post-error physical/data mismatch: `c134-0438`; use orphan-area recovery and inspect finger/fork evidence only for the original error.
- State batching/retransmission: `c134-0150`; compare robot local timestamps, broker timestamps, and pcap.
- Whole-site Kafka/server failure: `c134-0353`; collect Kafka/disk/EFK evidence before robot-specific work.
- Mantis reboot/Unknown confirmed: `c134-0053`, `c134-0182`, `c134-0277`; reboot proof is not reset-cause proof.
- Unknown screenshot/log gap: `c134-0253`; continuous uptime blocks a reboot conclusion despite 0KB CAN files.
- Robot label conflict: `c134-0277`; preserve NXP `robotLabel` over title/folder wording.

## Evidence Needed

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

## Logs And Files To Inspect

- SAS `RobotOrchestrationService`, `SpyderOrchestrationService`, Redis/Jedis stack traces.
- Mantis NXP/CAN for finger motors and ALLCAN-590 status.
- MQTT batch reports and simultaneous reports.
- wormhole pcap, AP/server side pcap if available.
- Kafka and EFK logs for controller election or broker instability.

## Likely Causes

- SAS scheduling stuck after Redis timeout/lock abnormality: `c134-0350`
- expected container/data mismatch after Mantis fault recovery: `c134-0438`
- network retransmission or batching between wormhole/AP/server, not robot state-period loss: `c134-0150`
- Kafka/server instability during whole-site stop: `c134-0353`
- confirmed Mantis reboot with unknown reset source: `c134-0053`, `c134-0182`, `c134-0277`
- suspected reboot/log gap only, not confirmed by NXP uptime: `c134-0253`

## Exclusion Checks

- Manual Mantis movement works and obstacle avoidance still works: exclude Mantis power as primary, inspect SAS/task orchestration.
- Robot state messages are batched but local robot timestamps are 1s apart: do not classify as robot not reporting.
- Data says no tote after Mantis error but physical tote exists: treat as post-error data inconsistency and follow orphan recovery.
- Whole-site disconnect affects all robots: inspect Kafka/server/network path before individual Mantis hardware.
- FLO `Unknown` alone does not prove reboot; require NXP low uptime/boot marker, Wormhole restart/DHCP, or power evidence.
- Startup `canopen_stack`/`node_led` errors after boot are not root cause unless they precede and explain the reset.
- If NXP uptime is continuous through the reported window, classify the report as unconfirmed reboot or log gap.

## Handling Recommendations

- For no-action after task dispatch, collect SAS/Redis logs before restarting SAS; restart may clear evidence.
- Add/verify logging around SAS Redis lock acquire/release paths.
- For Mantis data mismatch, move affected tote to orphan area and rerun inbound process.
- For frequent disconnect, collect simultaneous wormhole and AP/server pcaps plus MQTT batch report.
- For whole-site stop, collect Kafka logs centrally, reduce disk I/O pressure, and plan SSD upgrade/controller-broker separation.
- For Mantis reboot reports, preserve NXP and Wormhole logs before reboot/initialize/clear operations.
- Record both UTC log time and local CST report time; many cases use FLO screenshots in CST and NXP logs in UTC.

## Confirmed Examples

- `c134-0350`: SAS did not issue Mantis EXTRACT tasks; Redis timeouts preceded scheduler silence; SAS restart restored task dispatch.
- `c134-0438`: Mantis physical/data mismatch after error should be handled by orphan-area recovery; fork ALLCAN-590 IDs `0x14`/`0x15` had no abnormality.
- `c134-0150`: pcap showed retransmissions around `17:30:38`, while robot local state interval remained about 1s.
- `c134-0053`: FLO showed `M-A3-S2-1` `Unknown`; NXP uptime dropped from 87h to post-boot minutes and Wormhole showed DHCP reconnect around the event.
- `c134-0182`: `M-A3-S2-2` deposit/unload failure for `TOTE-H-200050`; NXP proved reboot from `[UPTIME:351586]` to `[UPTIME:39]`.
- `c134-0277`: nighttime reboot/Unknown report; NXP low uptime and initialization sequence prove reboot/initialization, with robotLabel `M-A3-S2-1`.

## Unresolved Examples

- `c134-0350`: exact Redis-lock failure path still needed code or reproduction proof.
- `c134-0353`: visible text contains plan and hypothesis, but not final verified root cause.
- `c134-0053`, `c134-0182`, `c134-0277`: reset source remains unknown; current evidence proves reboot but not power, firmware, or network root cause.
- `c134-0253`: event-time reboot is not proven because NXP uptime is continuous through the reported 2026-02-24 08:21 CST window; CAN files were 0KB.

## Specialist Routing

- `scheduler-traffic`: SAS task orchestration, Redis lock, no-action despite healthy robots.
- `network-infra`: MQTT batching/retransmission, AP/server path, Kafka/server instability.
- `mantis-handling`: physical tote/data mismatch recovery and finger voltage/position evidence.
- `embedded-software`: Mantis NXP/CAN voltage and finger motor state.
