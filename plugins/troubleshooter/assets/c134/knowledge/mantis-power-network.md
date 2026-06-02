# C134 Mantis Power And Network Knowledge

source_set: accepted high-priority `Mantis/power`, `Mantis/network`
case_count: 4
status: draft refined from visible text

## Symptoms

- task issued but no robots move, network normal, FLO no error: `c134-0350`
- Mantis has tote physically but FLO/data says no tote: `c134-0438`
- frequent device disconnect / delayed state delivery: `c134-0150`
- whole-site stop, FLO shows all robots disconnected or no robots after refresh: `c134-0353`

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

## Evidence Needed

- SAS orchestration logs around task issue and 10s scheduling cycle.
- Redis timeout/lock logs and whether scheduling resumes after timeout.
- Mantis NXP/CAN logs for finger motor voltage/position mismatch.
- FLO/data container state versus physical tote state.
- robot MQTT/state timestamps, broker receive timestamps, and pcap from wormhole/AP/server.
- Kafka controller/broker logs, server disk I/O, EFK load.

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

## Exclusion Checks

- Manual Mantis movement works and obstacle avoidance still works: exclude Mantis power as primary, inspect SAS/task orchestration.
- Robot state messages are batched but local robot timestamps are 1s apart: do not classify as robot not reporting.
- Data says no tote after Mantis error but physical tote exists: treat as post-error data inconsistency and follow orphan recovery.
- Whole-site disconnect affects all robots: inspect Kafka/server/network path before individual Mantis hardware.

## Handling Recommendations

- For no-action after task dispatch, collect SAS/Redis logs before restarting SAS; restart may clear evidence.
- Add/verify logging around SAS Redis lock acquire/release paths.
- For Mantis data mismatch, move affected tote to orphan area and rerun inbound process.
- For frequent disconnect, collect simultaneous wormhole and AP/server pcaps plus MQTT batch report.
- For whole-site stop, collect Kafka logs centrally, reduce disk I/O pressure, and plan SSD upgrade/controller-broker separation.

## Confirmed Examples

- `c134-0350`: SAS did not issue Mantis EXTRACT tasks; Redis timeouts preceded scheduler silence; SAS restart restored task dispatch.
- `c134-0438`: Mantis physical/data mismatch after error should be handled by orphan-area recovery; fork ALLCAN-590 IDs `0x14`/`0x15` had no abnormality.
- `c134-0150`: pcap showed retransmissions around `17:30:38`, while robot local state interval remained about 1s.

## Unresolved Examples

- `c134-0350`: exact Redis-lock failure path still needed code or reproduction proof.
- `c134-0353`: visible text contains plan and hypothesis, but not final verified root cause.

## Specialist Routing

- `scheduler-traffic`: SAS task orchestration, Redis lock, no-action despite healthy robots.
- `network-infra`: MQTT batching/retransmission, AP/server path, Kafka/server instability.
- `mantis-handling`: physical tote/data mismatch recovery and finger voltage/position evidence.
- `embedded-software`: Mantis NXP/CAN voltage and finger motor state.
