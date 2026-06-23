# Problem Tracking Unknown Troubleshooting Playbook

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

## Actuator Non-lock Barcode Pool Stale Display

Knowledge file: `docs/problem-tracking-unknown/knowledge/actuator-non-lock-barcode-pool-stale-display.md`

### First Checks

1. Confirm this is not scanner read failure.
   - The case says scan succeeds and parcel delivery succeeds.
   - The defect is stale UI/state after delivery, not missing scanner input.
2. Confirm actuator + non-lock mode.
   - Screenshot evidence shows the UI toggle/state marked `非锁定`.
   - This mode should not keep the consumed barcode as a locked seed after delivery.
3. Inspect barcode-pool consumption.
   - Code screenshot shows `tryToPullProductBarcodeFromPool`.
   - When `this.productBarcodePool.length` is non-zero, added logic checks `businessInstance.isActuator && this.productBarcodePool[0].isFromLock`.
   - If true, it logs `not order group mode, skip pull product barcode from pool` and returns before `this.productBarcodePool[0].qty--`.
4. Separate lock-mode retention from non-lock cleanup.
   - Lock-mode or order-group behavior may intentionally preserve a barcode.
   - Non-lock actuator delivery should consume/decrement or clear the delivered barcode so the next UI state is `未扫到条码`.
5. Verify after repair.
   - Reproduce with actuator non-lock scan, successful delivery, then check the upload/result panel, scan record, pool length, first pool entry `qty`, and `isFromLock`.

### Evidence

- UI screenshot or video showing actuator mode, `非锁定`, delivered barcode, and expected no-barcode state after delivery.
- Frontend/backend logs or debug output around scan success, delivery success, and barcode-pool update.
- Source diff or code review for `tryToPullProductBarcodeFromPool`.
- Runtime values for `businessInstance.isActuator`, `productBarcodePool[0].isFromLock`, `productBarcodePool[0].qty`, and pool length.
- Post-fix retest showing barcode clears after delivery in non-lock mode and still behaves correctly in lock/order-group modes.

### Exclusions

- Do not diagnose scanner hardware, focus, serial framing, or barcode format when the same evidence says scan succeeded and delivery succeeded.
- Do not merge with actuator lock-mode "scan succeeds but barcode not displayed" defects unless the failure is the same post-delivery stale barcode state.
- Do not treat `未扫到条码` text alone as scan failure; in this case it is the expected cleared state after delivery.
- Do not claim the fix is verified without a post-fix non-lock delivery retest.
- Do not assume OmniSort project/corpus from UI alone; source metadata keeps product line and project unknown.

### Examples

- `problem-tracking-unknown-pt-0112`: actuator non-lock mode, barcode `123455` remains visible after successful parcel delivery. Code screenshot shows `tryToPullProductBarcodeFromPool` returns before `qty--` when actuator mode and `isFromLock` are true.

- `problem-tracking-unknown-pt-0112`: missing raw app logs, full source diff, runtime variable dump, and post-fix retest. Root cause confidence is medium because the visible code path matches the symptom, but final verification is absent.

## Charging Pile Green Fast Blink During Ant Auto-Charge

Knowledge file: `docs/problem-tracking-unknown/knowledge/charging-pile-green-fast-blink.md`

### First Checks

- Likely branch: charging session handshake or pile-side charge state is not sustained.
  - `problem-tracking-unknown-pt-0060` reports repeated green fast blink across `J33A49CS`, `J33A50CS`, `J33A51CS`, and `J33A52CS`.
  - `problem-tracking-unknown-pt-0061` reports `J33A52CS` green fast blink after about 15 minutes, then recurrence about 1 minute after restarting the Ant.
  - Restart recovery is a reset symptom, not proof of root cause.
- Likely branch: real charge current is intermittent or absent in part of the session.
  - `0060` robot logs show mixed SOC trends: examples include `49 -> 48`, `49 -> 48`, `49 -> 48`, `38 -> 40`, and `38 -> 45`.
  - `0061` normal position logs show nearly flat SOC: `005-source-LrEQb00YLoVYUwxENDCcZNjhnef.log` stays `74 -> 74`; `009-source-B6cWbocjno7mHJxI2oQcMUTGnkf.log` stays about `82 -> 83`.
  - `0061` Wormhole CAN battery extraction also conflicts by session: `006-source-O3nZbwZd3oghtfxje1fcgvVbnZc.log` rises `73.5% -> 90.6%`, while `010-source-RtaKbVyYGoYrucxhxcxcFNlHnzf.log` falls `86.9% -> 82.6%`.
- Possible branch: robot-side BMS/CAN reporting or charge protocol compatibility contributes.
  - The symptom is not isolated to one pile or one robot: `0060` names `A3778`, `A2055`, `A2046`, `A3772`, and `A3763`.
  - `A3763` reportedly changed five charging piles before scheduling started and still saw abnormal green blink.
- Possible branch: pile-side hardware, contact, power output, or controller state issue.
  - Video thumbnails confirm the robot is physically at the charging pile and green indicator state is visible.
  - Pile-side voltage/current/controller logs are not present, so this branch remains unconfirmed.
- Blocked branch: raw CAN pcap decoding.
  - `0061` pcap files are present and `tcpdump` reads PCAP-NG timestamps, but current local tooling reports payload type as `UNSUPPORTED`; frame-level CAN meaning is not decoded.

### Evidence

- Exact timestamp window, pile ID, robot ID, and whether the robot was docked or already leaving.
- Charging pile controller logs, charger output voltage/current, relay/contact state, and internal error code around green fast blink.
- Robot BMS/CAN battery status aligned with the same window as the visible LED state.
- Decoded CAN frames for charge handshake, BMS state, charger request/response, and current limit.
- Representative video frames showing LED pattern before normal charge, at fast blink, after reboot, and after recurrence.
- Mechanical/contact evidence: robot dock alignment, charging brush/contact condition, pile connector, and cable/grounding state.

### Exclusions

- Do not diagnose a single bad pile if the same robot reproduces across several piles.
- Do not diagnose a single bad robot if multiple robots reproduce on multiple piles.
- Do not use green LED state alone as proof of charge current; compare with SOC/current/voltage trends.
- Do not treat charge recovery after reboot as root cause; it only proves state reset changes behavior.
- Do not trust a pcap filename as decoded CAN evidence; decode frames and align them to the LED/SOC window.
- Do not merge flat position-log SOC and Wormhole CAN SOC without checking robot ID and timestamp alignment.

### Examples

- None. These cases confirm a repeated symptom pattern and useful diagnostic branches, but not a final root cause.

- `problem-tracking-unknown-pt-0060`: repeated green fast blink after 1 to 15 minutes across several piles and robots. Robot-side SOC trends include slow charge, flat charge, and drops; charger-side logs/current/voltage are missing.
- `problem-tracking-unknown-pt-0061`: `J33A52CS` repeats green fast blink after 15 minutes and after Ant restart. Logs show conflicting SOC trends by source; pcap files are present but not decoded with available local tooling.

## Rail Power Alarm Flood After Power Cut

Knowledge file: `docs/problem-tracking-unknown/knowledge/rail-power-alarm-flood-after-power-cut.md`

### First Checks

1. Confirm expected power state.
   - If动力电源 is intentionally off for maintenance/test, raw rail-power status may be expected but should be gated or deduplicated.
   - If rail power should be energized, treat as possible real rail power fault.
2. Separate true rail fault from transient startup alarm.
   - True fault: rail supply voltage/current/status remains abnormal after startup stabilization.
   - Transient: startup sampling occurs before rail power/status debounce is stable, then self-clears.
   - Alarm-policy defect: repeated polling creates a new event every `30S` during intentional power-off.
3. Inspect alarm lifecycle.
   - Check whether backend creates a new alarm row for every poll instead of updating an active alarm.
   - Check clear/close timing, suppression windows, maintenance mode, and startup grace period.
4. Verify product/site identity.
   - Source says `M141-2`; screenshot shows `M123-SITE-2`. Resolve this before assigning project-specific root cause.
5. Preserve safety behavior.
   - Suppression/deduplication must not hide real rail power failures after power should be restored.

### Evidence

- Backend alarm/event create/update/clear logs around `2026-06-08 13:44:41` and `2026-06-16 15:39:00`.
- Rail power supply 1/2 voltage/current/status telemetry around power cut, startup, and self-clear.
- Startup sequence timing and status debounce rules.
- Requirement document `SORT设备操作界面新增需求` (`Dga2doPApopCULxHOeaczJpqn8g`).
- Proof of the stated `30S` reporting interval in backend logs.
- Product/site confirmation for `M141-2` versus `M123-SITE-2`.
- Before/after verification showing intentional power-off alarms are deduplicated or gated while real faults still alarm.

### Exclusions

- Do not suppress alarms when rail power is expected to be energized and remains abnormal after a grace period.
- Do not classify as confirmed hardware failure from the screenshot alone.
- Do not diagnose scheduler queue, CAN, or network from the UI event text alone.
- Do not treat `174085` as the count caused by this issue; it only proves the event table is large.
- Do not assign to M141 or M123 project until source/screenshot identity conflict is resolved.

### Examples

- None yet. `problem-tracking-unknown-pt-0163` establishes the alarm lifecycle triage path, but root cause remains unresolved without backend alarm logs and rail telemetry.

- `problem-tracking-unknown-pt-0163`: source reports M141-2 probabilistically raises `导轨供电电源1、2异常` after动力电切断 and startup, then self-closes; screenshots show rail power 1/2 alarms and dense event rows. Missing backend logs, rail telemetry, requirement doc, and site identity resolution keep cause unconfirmed.

## System Reset Queue Lock Race Produces QUEUE RESET

Knowledge file: `docs/problem-tracking-unknown/knowledge/system-reset-queue-lock-race.md`

### First Checks

1. Treat as reset-vs-queue-lock timing first.
   - `problem-tracking-unknown-pt-0176`: mains power was manually disconnected at about `15:54`, then reconnected.
   - Source analysis says system reset clears queue data.
   - If a task is being pushed into the queue for lock operation during reset, lock failure can report `QUEUE RESET`.
2. Separate test-task alarm policy from production behavior.
   - Source resolution: suppress alarm information for test tasks to avoid misunderstanding.
   - This is valid only when the task is confirmed as a test task and the reset/power-cut action is intentional.
3. Production branch remains actionable.
   - If `QUEUE RESET` appears without a deliberate reset/power-cut window, investigate queue persistence, task lifecycle, scheduler restart, duplicate lock attempts, and order-state recovery.
4. Exclude unrelated domains.
   - This evidence is not a CAN failure by itself.
   - Do not route to network/AP merely because generic text contains `impact` or UI context.

### Evidence

- Reset/power-cut timestamp and system startup/reset log.
- Queue clear event and task enqueue/lock attempt log around the same window.
- Task/order ID and whether it is a test task or production task.
- UI alarm screenshot or frontend log with exact `QUEUE RESET` timestamp.
- Post-change verification showing only confirmed test-task reset alarms are suppressed/downgraded.

### Exclusions

- Do not diagnose CAN fault without heartbeat, SDO, NMT, or bus-error evidence in the same timestamp window.
- Do not diagnose network/AP fault without real disconnect, MQTT, ping, AP roaming, or service-communication evidence.
- Do not suppress production `QUEUE RESET` without proving intentional reset and test-task context.
- Do not use the screenshot alone to prove backend queue clear or lock timing; require logs for confirmation.
- Do not treat every reset-recovered queue alarm as harmless; repeated production alarms need scheduler/queue recovery analysis.

### Examples

- `problem-tracking-unknown-pt-0176`: during shuttle-mode self-run, incoming mains power was manually disconnected at about `15:54` and later reconnected. UI showed `异常：QUEUE RESET`, timestamp `2026-06-17 15:54:06`. Source analysis says reset clears queue data; when task queue locking is in progress, reset-caused lock failure reports this error. Resolution is to suppress alarm information for test tasks.

- `problem-tracking-unknown-pt-0176`: missing backend queue logs, reset logs, exact task/order ID, product/project confirmation, and post-change validation.

## Wormhole Low-temperature Reboot LAN Unreachable

Knowledge file: `docs/problem-tracking-unknown/knowledge/wormhole-low-temp-reboot-lan-unreachable.md`

### First Checks

1. Separate CAN fixture success from LAN boot failure.
   - If CAN command send succeeds before the wait period, do not diagnose CAN first.
   - Focus on the post-reboot LAN bring-up window.
2. Confirm expected network target.
   - Verify whether `192.168.40.1` is still the expected LAN bridge or management IP after the tested firmware/config.
   - Check static IP, bridge name, interface names, DSA port names, and management network route.
3. Inspect firmware/config migration risk.
   - For OpenWrt images, inspect metadata before testing.
   - If the image reports `image 1.1, device 1.0` or `Config cannot be migrated from swconfig to DSA`, wipe/rebuild config or explicitly verify the migrated network config.
4. Compare successful and failed cold boots.
   - Capture serial console, kernel `dmesg`, `logread`, netifd, PHY/link, and DSA switch logs from a successful cycle and a failed cycle.
   - Find the first divergence before deciding hardware or software root cause.
5. Only then inspect low-temperature hardware branches.
   - Check PHY/switch cold start, MT7621 reset/clock, power rails, flash/config read, connector/interface board, and cable/link LEDs.
   - Low temperature is a stress condition, not a root cause by itself.

### Evidence

- Temperature chamber setpoint and actual board temperature for successful and failed cycles.
- Reboot cycle number, command sent, wait time, and exact connectivity-check timestamps.
- Serial console logs from successful and failed cycles.
- OpenWrt `dmesg`, `logread`, netifd, `/etc/config/network`, `ip addr`, `bridge link`, `ethtool` or equivalent PHY/link status.
- ARP/ping/packet capture from the test PC side.
- Firmware image metadata and whether config was wiped or migrated.
- Power rail, reset, and clock measurements under low temperature if logs point to hardware boot instability.

### Exclusions

- Do not classify as CAN bus failure when the visible test shows CAN command success and the failure is in LAN connectivity.
- Do not claim hardware low-temperature defect without failed-cycle boot/link/power evidence.
- Do not claim OpenWrt firmware defect from image metadata alone; treat it as a high-priority branch requiring config and boot-log verification.
- Do not accept a single successful ping before the next reboot as proof that failed cycles have no issue.
- Do not keep using `192.168.40.1` as target without confirming expected IP after firmware/config changes.

### Examples

- `problem-tracking-unknown-pt-0090`: Wormhole baseboard `P2672-A2-WORMHOLE1-1` with interface board `P2674-A1-MANTIS-LINK`.
  - Source reports `-15°` repeated power-cycle testing: the 42nd reboot failed, then the 24th reboot after another power-on failed again.
  - Source reports `-5°` cold reboot testing: the 20th reboot also failed.
  - Screenshot at `2026-05-19 20:51:20` starts checking `192.168.40.1`; three failures occur by `20:51:35`, then the script terminates.
  - Screenshot at `2026-05-20 16:48:13` starts checking `192.168.40.1`; three failures occur by `16:48:28`, then the script terminates.
  - Screenshot at `2026-05-21 15:29:03` starts checking `192.168.40.1`; three failures occur by `15:29:18`, then the script terminates.
  - Attached firmware is `u-boot legacy uImage, MIPS OpenWrt Linux-6.12.74`, OpenWrt `25.12.2`, target `ramips/mt7621`, board `wormhole_mt7621`.
  - Firmware metadata warns `image 1.1, device 1.0`, force/wipe required, and config cannot migrate from `swconfig` to `DSA`.

- `problem-tracking-unknown-pt-0090` lacks failed-cycle serial logs, OpenWrt logs, netifd/DSA/PHY status, device config, PC-side packet capture, chamber telemetry, and hardware measurements. Use it as a diagnostic pattern, not a confirmed root cause.
