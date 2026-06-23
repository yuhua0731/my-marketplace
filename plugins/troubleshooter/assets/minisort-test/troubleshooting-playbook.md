# Minisort Test Troubleshooting Playbook

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

## Baffle Motor Gear-Ratio Acc/Dec SDO Range Error

Knowledge file: `docs/minisort-test/knowledge/baffle-motor-gear-ratio-accdec-sdo-range.md`

### First Checks

- Confirmed branch: acceleration/deceleration SDO writes exceed the motor object range.
  - Log screenshot shows `conopen_stack: CO_SDOClientDownload error: -10`.
  - The same screenshot shows object `index 6083 sub_index 0 node_id 3 abort code: 1012531699`.
  - It also shows `index 6084 sub_index 0 node_id 3 abort code: 1012531699`.
  - Decimal `1012531699` corresponds to CANopen abort `0x06090031`, parameter value too high.
- Confirmed branch: wrong motor parameter template is used for the baffle motor.
  - Source analysis says the baffle motor reduction ratio is `1:18`.
  - Acceleration/deceleration was configured according to the throw/parabolic motor `1:1` parameter set.
  - This made the acceleration/deceleration subdivision exceed the motor's maximum limit.
- Likely branch: failed parameter writes leave the baffle motor with stale/default motion limits, so the baffle intermittently fails to descend during the throw sequence.
- Blocked branch: exact command-to-motion timeline.
  - No raw CAN dump, full NXP log, motor state sequence, or full video frame review is available locally.

### Evidence

- Raw CANopen SDO log around object `0x6083` and `0x6084` writes, including requested values and motor accepted limits.
- Motor reduction ratio and configured acceleration/deceleration values before and after the fix.
- Full baffle command lifecycle: throw command, baffle-down command, motor enable/state, target reached, timeout or no-motion result.
- Video frames covering the exact failure moment, not only a representative thumbnail.
- Post-fix retest logs showing `0x6083`/`0x6084` writes succeed and 50+ parcels pass without recurrence.

### Exclusions

- Do not replace the baffle motor until `0x6083`/`0x6084` parameter writes and accepted ranges are checked.
- Do not classify as pure mechanical jam unless video or motor current/torque evidence shows obstruction after valid parameters are written.
- Do not blame firmware version solely from the version table; D004's version is context evidence, not root-cause proof.
- Exclude CAN transport only if other SDO writes succeed and the abort is specifically `0x06090031`.
- Exclude this pattern if the abort code is heartbeat loss, timeout, or communication reset instead of value range violation.

### Examples

- `minisort-test-pt-0100`: D004 baffle failed to lower during throw-off with around `5%` probability. Setting baffle motor acceleration/deceleration produced CANopen SDO errors on `6083` and `6084`, abort `1012531699` / `0x06090031`. Source analysis says the baffle motor ratio is `1:18` but was configured with `1:1` throw-motor parameters; changing baffle motor acceleration/deceleration configuration resolved the issue, with 50+ parcels tested without recurrence.

- `minisort-test-pt-0100`: raw CAN dump, exact before/after parameter values, full video failure sequence, and long-run recurrence beyond the first 50+ parcels are not present.

## Conical Screw Belt Edge Baffle Gap Jam

Knowledge file: `docs/minisort-test/knowledge/conical-screw-belt-edge-baffle-gap-jam.md`

### First Checks

- Confirmed branch: the problematic object geometry is head-heavy and directionally unstable.
  - Source text says the screw is `头重脚轻（锥形物品）`.
  - Source text says it easily rotates in place while the robot is running.
  - Photo `001-image-1266516026a2.jpg` shows a long screw on the belt with the head on one end and a narrow threaded shaft.
- Confirmed branch: the failure position is the belt edge / baffle-side boundary.
  - Source text says the object easily slides out to the belt edge during throw-off and gets stuck on the baffle motor.
  - Photo `002-image-2ac66d64435b.jpg` shows the screw head at the right-side belt edge near the metal baffle/guard gap.
- Evidence-backed branch: this is a physical handling and media-inspection pattern, not a CANopen parameter failure.
  - No source text mentions `CO_SDOClientDownload`, `6083`, `6084`, motor ratio, or baffle non-descent.
  - The failure is object pose/geometry entering a mechanical boundary during throw-off.
- Blocked branch: full motion sequence and final remediation.
  - The local video is available, but without `ffmpeg/ffprobe` only a QuickLook representative frame was extracted.
  - The representative frame shows the MiniSort baffle/throwing scene, but not the exact jam instant.
  - Source `Analysis`, `Resolution`, and `Actions Taken` are empty or `unknown`.

### Evidence

- Full frame sequence from before rotation, edge drift, throw-off, and jam.
- Belt width, side-guide/baffle gap size, baffle motor protrusion, and object dimensions/weight distribution.
- Test matrix for cylindrical, boxed, spherical, long, head-heavy, and conical items.
- Before/after evidence for any guide rail, side guard, baffle cover, belt speed, throw timing, or item-orientation fix.
- Whether the failure repeats only for screws/conical objects or for all small long objects.

### Exclusions

- Do not route this to `baffle_motor_gear_ratio_accdec_sdo_range` unless logs show SDO aborts on `6083`/`6084` or the baffle does not descend.
- Do not diagnose scheduler or WRS quantity logic; the symptom is physical object trajectory/jam.
- Do not blame generic belt speed without visual proof of lateral drift, rotation, or a gap capture point.
- Do not claim a fix without a post-fix run using the same screw/conical item class.

### Examples

- `minisort-test-pt-0103`: during Mini drag-chain baffle robot receive/throw testing with screws, the screw was head-heavy and rotated in place while the robot ran. During throw-off it slid toward the belt edge and got stuck near the baffle motor, causing throw failure. Photos show the screw geometry and the screw head positioned at the belt edge near the metal baffle/guard gap.

- `minisort-test-pt-0103`: full video frame sequence, exact jam timestamp, gap dimensions, item dimensions, fix choice, and post-fix retest are not local.

## Conveyor External Error Replay Force Unload

Knowledge file: `docs/minisort-test/knowledge/conveyor-external-error-replay-force-unload.md`

### First Checks

- Confirmed branch: feeder disconnect/reconnect creates an external error at central control.
  - In `minisort-test-pt-0070`, source analysis says the feeder disconnected at about `11:45`.
  - The screenshot shows `2026-06-03T11:45:55.280000+0800 ERROR: M143-SITE-1-CONVEYOR: disconnect`.
  - The same screenshot shows `M143-SITE-1-CONVEYOR: recover` and `set errorCode by server: CONVEYOR RECONNECTED`.
  - Source analysis calls this external error `外部错误0x06` for `供包机断连`.
- Confirmed branch: reset clears central-control error state but the feeder can replay the old external error after the next startup.
  - Source text says test staff reset the system at `13:15` without clicking the force-unload popup.
  - After reset, central control no longer has the `供包机断连` / `外部错误0x06` error-code record.
  - On startup, the feeder sends the same `外部错误0x06` back to central control.
- Confirmed branch: recovery/force-unload cannot close cleanly when the error code is no longer known by central control.
  - Source analysis says the operator clicked error recovery and force unload started.
  - Because central control had no matching `供包机断连` error code, the force-unload state could not end and the robot continued force-unloading.
- Design branch: the preferred durable fix is embedded-side suppression of old external errors across startup.
  - Source lists three options and states that embedded modification makes the old startup-sent external error stop being pushed after the next boot.
  - This produces normal operation: no force unload, no popup, and if an external error happens during operation, feeder disconnect/reconnect can recover automatically without force unload.

### Evidence

- Raw central-control log around `2026-06-03T11:45:47` to `11:45:55`, including complete `errorCode`, popup, recover, and force-unload lines.
- Feeder/embedded log proving whether `外部错误0x06` was persisted and resent after reboot.
- System reset log around `13:15`, including central-control error-state cleanup.
- UI operation record: whether the force-unload popup was ignored, dismissed, or recovered before reset.
- Post-fix retest for all three candidate solutions, especially embedded suppression of startup replay.

### Exclusions

- Do not route to generic M111 conveyor-recovery race only from `Mini`, `供包机`, `恢复`, and `强排`; this is a MiniSort Test stale external-error replay case.
- Do not diagnose feeder motor or belt hardware if logs show disconnect/recover and error-code replay explains the force-unload state.
- Do not treat the vanished popup as recovery; the source says the popup disappeared after system reset while the stale external error still came back.
- Do not choose central-control auto force-unload as a final fix without checking abnormal-mouth force-unload behavior, because source warns parcels delivered within 5 seconds after startup can be force-unloaded incorrectly.
- Do not choose a default-error-code popup fix as final if product behavior requires no unexplained popup after normal reboot.

### Examples

- `minisort-test-pt-0070`: after feeder parameter changes and feeder reboot, test staff reset the system without clicking the force-unload popup. Later, the feeder replayed `外部错误0x06` for `供包机断连`; central control had already cleared that error-code record, so recovery/force unload could not finish and the robot continued force-unloading. Screenshot evidence shows `M143-SITE-1-CONVEYOR: disconnect`, `recover`, `set errorCode by server: CONVEYOR RECONNECTED`, and dispatch error-return lines around `2026-06-03T11:45:55`.

- `minisort-test-pt-0070`: raw logs, embedded retained-error storage, central-control reset cleanup logs, and post-fix retest artifacts are not local.

## Dirty Grid/Shuttle Standby Offset Causing Position Mismatch

Knowledge file: `docs/minisort-test/knowledge/dirty-grid-shuttle-standby-offset-mismatch.md`

### First Checks

1. Start from scheduler command evidence before blaming robot localization.
   - If `setTarget`, `robot_move_command`, `target_reached_event`, and `odom_report_event` agree on the same offset, the robot likely executed the scheduler-commanded coordinate.
   - If command and odom disagree, route to robot-motion/embedded before database cleanup.
2. Compare the commanded standby/load offset with the expected station coordinate.
   - Check station/site, layer, wall, grid/display name, track, and offset together.
   - A valid-looking offset can still belong to a stale grid row from another system.
3. Inspect database grid records for dirty or stale `systemId`.
   - A stale row such as `systemId=M111` can make MiniSort/M123 logic use an offset like `3.117` when the station standby point should be `3.783`.
4. Do not stop after deleting dirty grid rows.
   - Robot standby points can already be materialized in the `shuttle` table when the robot is added.
   - If the `shuttle` standby point still carries the stale offset, re-add/regenerate the robot after grid cleanup.
5. Separate follow-up emergency-handling faults from the original coordinate mismatch.
   - Missing central-control emergency handling after a version merge can block retest, but it is not evidence for the initial map-vs-physical mismatch unless it occurs in the same timeline.

### Evidence

- RCS/dispatch logs around `setTarget`, `robot_move_command`, `target_reached_event`, and `odom_report_event`.
- Expected station standby/load coordinates from the source-of-truth configuration or database.
- Database query results for `grid` and `shuttle` rows by `systemId`, display name, offset, track, station, wall, and robot.
- UI overview screenshot plus physical photo/video showing the map-vs-physical mismatch.
- Post-remediation evidence showing the corrected offset and a successful pickup/retest.

### Exclusions

- If the commanded offset matches the expected station coordinate but physical position is wrong, investigate robot localization, track calibration, encoder/odom, and map geometry.
- If command delivery or ACK is missing, check network/embedded state before database records.
- If only UI screenshots are available, classify database root cause as provisional until raw logs or DB query screenshots/text support it.
- If emergency-stop handling appears after database changes, treat it as a separate branch unless it explains the original timestamped mismatch.

### Examples

- `minisort-test-pt-0064`: During MiniSort Pro no-scan feed testing on `2026-04-30`, the second-layer robot overview position differed from physical position and the second layer could not receive a parcel. UI overview at `2026-04-30 14:24:02` showed robots online/no obvious alarm.
  - Source analysis says parcel `1777529274621-1` should be picked from `M123-SITE-1` and sent to `M123-WALL-B-3-3-1 (B3-11)`.
  - `2026-04-30T14:07:57.335000+0800`: `setTarget` sent `M002L` to `HT1`, offset `3.117`, as an empty standby move.
  - `2026-04-30T14:07:57.341000+0800`: `robot_move_command` for `M002L` used position `3.117`, speed `4`, acc `3.5`, dec `3.5`.
  - `2026-04-30T14:07:57.725000+0800`: `target_reached_event` reported `M002L` at `currentOffset: 3.117`.
  - `2026-04-30T14:07:57.726000+0800`: `odom_report_event` reported `currentPosition/currentOffset: 3.117`.
  - Source conclusion says station-1 standby offset should be `3.783`; `3.117` corresponded to `B0-10` dirty `grid` data with `systemId=M111`.
  - Deleting dirty `grid` rows did not fully fix the case because `shuttle` standby-point data generated when adding the robot still held the stale coordinate; re-adding the robot was required.

- `minisort-test-pt-0064`: Raw database exports are not local; DB evidence comes from the source document's query screenshots/text.
- `minisort-test-pt-0064`: Later retest hit an emergency-stop handling issue after code changes from `sort-mini-v1.0.0` to `sort-mini-v2.0.0`; final full retest evidence is not present locally.

## Full-box Exception Unload Delayed Move Slow Run

Knowledge file: `docs/minisort-test/knowledge/full-box-exception-unload-delayed-move-slow-run.md`

### First Checks

1. Confirm the business precondition.
   - Locked sowing mode is enabled on both stations.
   - The robot is handling a full-box recovery path and moving to the exception mouth after check-complete/recover.
2. Compare central-control command parameters with robot movement events.
   - In `minisort-test-pt-0052`, the command screenshot at `2026-03-31T14:28:42.675+0800` shows `position: 2.42`, `speed: 4`, `acc: 3.2`, `dec: 3.2`.
   - If the command speed is normal but the robot still moves slowly, route to robot-side move timing/state-machine evidence before blaming central-control command generation.
3. Inspect move lifecycle timing.
   - The robot log screenshot shows pre-arrival/motion event, `MovementProgress::Move -> terminate`, and `Move::Exit -> terminate` around `14:28:42`.
   - The same screenshot shows a new move starts immediately after `MainController::Idle -> Move`, `cmd_pos 2420000mm`, `seq 984`, and `target: 2420mm`.
   - The slow-run block continues until about `14:29:28` before motion event termination.
4. Inspect PDO/SDO profile velocity timing.
   - Local screenshot shows `pdo profile velocity: 4753` at `2026-03-31 06:28:42.678017850`.
   - It then shows `sdo profile velocity: 4753` at `2026-03-31 06:28:42.719484899`.
   - The source analysis says the SDO speed write occurs after PDO speed setting and uses the same value, so the issue is not a wrong speed number but when move parameters take effect.
5. Check delayed `move` parameter application.
   - Source resolution says all delayed-call move parameters should take effect after the movement-start event.
   - If a delayed move call updates parameters before the movement start event is fully handled, the robot may enter a move state with stale or transitional speed behavior.

### Evidence

- Raw robot log text around `2026-03-31 14:28:42~14:29:28` for `M004L`.
- Central-control dispatch log proving the exception-mouth move command, target, speed, acc, dec, and seq.
- Full robot state-machine log around pre-arrival, terminate, ACK, new move start, movement progress, and final terminate.
- Motor PDO/SDO write log with exact object/index if available, not only screenshot text.
- The whiteboard attached to the source document; it is referenced but not present locally.
- Code diff or firmware version showing the delayed move parameter application fix.
- Post-fix retest video/log proving exception-mouth movement speed is normal after full-box recovery.

### Exclusions

- Do not blame central-control command generation if `move_cmd payload` already contains normal `speed`, `acc`, and `dec`.
- Do not treat the SDO write as a wrong-value branch when PDO and SDO profile velocity values are identical.
- Do not route to generic full-box sensor mapping unless the symptom is trigger-count UI/MQTT/CAN gateway mapping failure.
- Do not route to locked-sowing count logic when the main symptom is robot physical movement speed toward the exception mouth.
- Do not close the case without post-fix movement logs or video showing normal exception-mouth speed.

### Examples

- `minisort-test-pt-0052`: in production locked-sowing mode, after a full grid is recovered, robot `M004L` moves toward the exception mouth with abnormal speed around `14:28:42~14:29:28`. The command screenshot shows normal `position: 2.42`, `speed: 4`, `acc: 3.2`, `dec: 3.2`; robot logs show slow movement after movement start/terminate transitions; PDO and SDO profile velocity are both `4753`. Source resolution says delayed-call move parameters should take effect after the movement-start event.

- `minisort-test-pt-0052`: raw logs, source whiteboard, code diff, firmware version, and post-fix retest proof are not local.

## Full Box Trigger Number CAN Gateway Mapping

Knowledge file: `docs/minisort-test/knowledge/full-box-trigger-num-can-gateway-mapping.md`

### First Checks

- Confirmed branch: full-box trigger count needs a separate gateway mapping from full-box sensor state.
  - In `minisort-test-pt-0053`, source analysis says the configuration table's `Physical Location ID` needs a `-trigger-num` suffix for the grid/bin number.
  - The downloaded corrected tables contain rows such as `WALL-A-0-1-trigger-num` and `WALL-A-3-1-trigger-num`.
  - These rows use function code `FullBoxTriggersNumber` and MQTT topics such as `/FullBoxTriggersNumber/WALL-A-0-1`.
- Confirmed branch: CAN gateway must generate matching ODTM/mapping records.
  - Source analysis says CAN gateway lacked the corresponding configuration, causing mapping generation failure.
  - `odtm.log` shows later generated rows such as `add_odtm:1-node11-8464-0,/FullBoxTriggersNumber/WALL-A-0-1`.
  - `all.log` shows mapping records such as topic `/FullBoxTriggersNumber/WALL-A-0-1`, `node_id: 11`, `od_index: 0x2110`, `od_sub_index: 0x00`.
- Confirmed branch: the initial UI symptom matches repeated query/publish retry behavior.
  - Source text says opening the trigger window at `19:00:20` took about `8-15` minutes and did not show wall trigger counts.
  - Source text says changing `A0` trigger count at `19:06:01` spun until about `19:15:47`, failed, and had no popup.
  - OCR from screenshot `003-image-8f0b3b2268ac.png` shows repeated `hardwares-mgr: queryFullWatcherTriggersNumber result` from `2026-03-25 19:06` through `19:15`.
- Confirmed branch: after partial update, mapping consistency matters across central control and CAN gateway.
  - Source follow-up says CAN gateway was updated to `V3.0.12`, configuration table was reuploaded, and mapping/relationship table counts matched.
  - Then central control reimported the allcan table, but full-box triggering had no MQTT report and C/D door locking failed.
  - OCR from screenshots shows `responseTopicHookQueueMap not found` for `/CartInPositionStatus/WALL-A-0`, `/CartLockStatus/WALL-A-0`, `/CartInPositionStatus/WALL-B-0`, `/CartLockStatus/WALL-B-0`, `/CartInPositionStatus/WALL-B-3`, and `/CartLockStatus/WALL-B-3`.
  - OCR also shows `DOOR_IS_OPENED` / `ELECTROLOCK_LOCK_FAIL` for `M123-DOOR-A` and `M123-DOOR-B`.
- Resolution branch: after modifying CAN gateway configuration, door locking recovered; after refreshing mapping configuration, full-box triggering recovered.

### Evidence

- Before-fix configuration table showing missing `-trigger-num` rows or missing `FullBoxTriggersNumber` function-code rows.
- CAN gateway version and config diff around update to `V3.0.12`.
- Raw central-control log lines for `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED` and the full request/response payload for editing the trigger count.
- Raw CAN gateway mapping generation logs before and after the fix.
- Mapping table and relationship table row counts before/after refresh.
- Final MQTT evidence showing `/FullBoxTriggersNumber/...` is published when full-box trigger count changes or full-box sensors trigger.

### Exclusions

- Do not diagnose this as only UI frontend slowness if logs show repeated `queryFullWatcherTriggersNumber` or `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED`.
- Do not treat full-box sensor status topics `/FullWatcherForBox/...` as sufficient; trigger-count setting needs `/FullBoxTriggersNumber/...`.
- Do not edit only central-control data if CAN gateway `ODTM` / mapping rows are missing.
- Do not treat door-lock failure as mechanical lock failure until `/CartInPositionStatus`, `/CartLockStatus`, `/DoorLock`, and `/DoorStateSensor` response mappings are verified.
- Do not trust CAN gateway log timestamps blindly when logs include default or stale dates; correlate by topic, node, OD, and source document timeline.

### Examples

- `minisort-test-pt-0053`: Mini Plus full-box sensor trigger configuration opened slowly, did not display seed-wall trigger counts, and changing `A0` trigger count to `2` failed after a long spinner. Source analysis says `Physical Location ID` needed `-trigger-num`; CAN gateway lacked configuration, causing mapping generation failure. Corrected tables include `WALL-A-0-1-trigger-num` / `WALL-A-3-1-trigger-num` with function `FullBoxTriggersNumber`; log bundle later shows `/FullBoxTriggersNumber/WALL-A-0-1` mapped to `node_id 11`, `od_index 0x2110`. After CAN gateway config changes and mapping refresh, door locking and full-box trigger recovered.

- `minisort-test-pt-0053`: before-fix table, raw `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED` line, complete central-control request payload, and post-fix MQTT trigger proof are not local.

## MiniSort IO Address Table CAN Termination Ambiguity

Knowledge file: `docs/minisort-test/knowledge/io-address-table-can-termination-ambiguity.md`

### First Checks

1. Treat as documentation/topology ambiguity first.
   - `minisort-test-pt-0004`: M131 debugging could not determine ALLCAN-4 terminal-resistor switch state from the manual or IO address table.
   - Source says `1-1` and `1-2` are the same CAN bus but were separated, causing misunderstanding.
2. CAN hardware risk is downstream.
   - Wrong termination instructions can create later CAN instability or node-discovery confusion.
   - This case has no runtime CAN logs, heartbeat loss, or SDO error evidence.
3. Resolution pattern.
   - Add clear ALLCAN-4 terminal-resistor on/off instructions to the IO definition table.
   - Put same-CAN-line node configuration descriptions in the same sheet.

### Evidence

- Editable `M131_IO地址变量表_V01.xlsx` and updated version diff.
- Physical CAN topology diagram for `9352-1` / `9352-2`.
- ALLCAN-4 DIP switch mapping: switch position, termination on/off, and node role.
- Review checklist proving same-bus nodes are grouped or explicitly cross-referenced.
- Field-debug confirmation that the revised table removes the ambiguity.

### Exclusions

- Do not route to runtime CAN failure without CAN captures, heartbeat loss, SDO aborts, or node scan errors.
- Do not route to generic Mini/M123 scheduler issues from the word `迷你播`.
- Do not treat a screenshot as sufficient documentation proof; use the actual spreadsheet for final validation.
- Do not let sheet naming imply separate buses when the nodes are on one physical CAN line.

### Examples

- `minisort-test-pt-0004`: M131 debugging found that both the debugging manual and IO address table failed to clarify ALLCAN-4 terminal-resistor DIP state. The IO table also split `1#9352 BUS-1-1` and `1#9352 BUS-1-2` into separate tabs despite being the same CAN line. Resolution was to add ALLCAN-4 terminal-resistor on/off instructions and place same-CAN-line node configuration in the same sheet.

- `minisort-test-pt-0004`: missing actual `.xlsx`, before/after diff, topology diagram, and field validation after documentation update.

## Locked Robot Blocks System Shutdown

Knowledge file: `docs/minisort-test/knowledge/locked-robot-blocks-system-shutdown.md`

### First Checks

1. Confirm this is a shutdown workflow/state issue.
   - If UI is responsive and drive/controller indicators are still visible, do not start with hardware power failure.
   - Find the backend shutdown request and first blocking step.
2. Check robot lock state.
   - Identify locked robot IDs and whether they are expected to move to shutdown/parking position.
   - Determine whether locked robots are excluded from dispatch but still counted in shutdown barriers.
3. Check robot state consistency.
   - A robot that is locked and initializing/idle may be unable to accept park/shutdown commands.
   - Compare locked robot state with other running robots at the same timestamp.
4. Check product behavior policy.
   - MiniSort Pro should either reject shutdown with a clear prompt, safely unlock/park, or force-stop after safe-state checks.
   - Silent hanging means the lock state is not handled as a first-class shutdown precondition.
5. Validate the fix by reproduction.
   - Lock the same class of robot, request shutdown, and verify terminal state or explicit prompt.

### Evidence

- Backend shutdown logs from the exact click time.
- Robot lock/unlock event logs, locked robot IDs, and caller.
- Robot state timeline for locked and unlocked robots.
- Shutdown state-machine or scheduler barrier logs.
- Product requirement for shutdown behavior when robots are locked.
- Post-fix retest showing either completed shutdown or a clear actionable prompt.

### Exclusions

- Exclude power-hardware failure when the UI is responsive and normal system indicators are visible.
- Exclude generic robot offline branch unless the locked robot is also disconnected or heartbeat-lost.
- Exclude CAN/embedded root cause until logs show command delivery, state-machine, heartbeat, or actuator errors.
- Exclude normal shutdown delay only after checking whether the same robot remains locked/initializing across the waiting period.
- Do not remove the lock-state precondition from the diagnosis; this case is about shutdown under locked-robot state.

### Examples

- `minisort-test-pt-0065`: MiniSort Pro self-test mode locked other robots, ran for 2 minutes, then shutdown at `2026-05-06 15:29` failed. Source analysis says `M002L` was locked and Mini Pro did not yet support this robot-lock scenario well. Screenshot at `2026-05-06 16:07:55` shows `M002L` grey/initializing while the rest of the visible robots are running.

- `minisort-test-pt-0065`: shutdown backend logs, lock event logs, exact blocking state-machine step, and post-fix retest are not local.

## MiniSort NXP MAC Source Mismatch During Robot Initialization

Knowledge file: `docs/minisort-test/knowledge/nxp-mac-source-mismatch.md`

### First Checks

1. Separate representation mismatch from true identity mismatch.
   - DHCP/ARP values may appear as colon-separated MACs such as `02:04:a0:a1:31:c8`.
   - NXP/RCS values may appear as `02:04:9F:31:A1:C8` or compact forms such as `02049F31A1C8`.
   - Determine whether the difference is formatting, byte conversion, locally administered address derivation, or a real robot mismatch.
2. Validate physical robot identity.
   - For each robot, record physical label, expected IP, live DHCP lease, live `arp -a`, direct NXP `net iface`, and RCS-discovered address.
   - If two robots appear crossed, verify from direct terminal on each physical robot before changing bindings.
3. Check stale cache/lease branch.
   - DHCP leases and ARP cache can lag behind robot swaps or IP reuse.
   - Clear DHCP/ARP cache or renew leases before treating mismatch as permanent identity fault.
4. Check initialization-script source-of-truth.
   - Use the MAC/address format consumed by the initialization script and downstream RCS/robot discovery path.
   - Document the accepted source and conversion rule so field teams do not mix DHCP, ARP, NXP, and RCS values.

### Evidence

- Original screenshots or raw exports for DHCP lease table, `arp -a`, NXP `net iface`, and RCS scan discovery.
- Exact initialization script name, expected MAC format, and command input.
- Physical robot label/serial verification for `K02A17MN`, `K02A20MN`, and `K02A11MN`.
- Timestamp-aligned DHCP and ARP cache state after lease renewal or cache flush.
- Final correction or retest showing the initialization command targets the intended robot.

### Exclusions

- Do not diagnose CAN failure without CAN communication evidence; this is address/identity mapping.
- Do not route to Ant/C134 power or network from incidental `重启` text in screenshot descriptions.
- Do not rely on one source alone when DHCP/ARP, NXP, and RCS disagree.
- Do not update bindings until physical robot identity and live `net iface` / RCS scan agree.
- Do not treat embedded image alt text as final proof; request/download the original screenshots or exports for final closure.

### Examples

- `minisort-test-pt-0097`: during CS007 `K02A17MN` baffle robot debugging, an initialization script needed NXP MAC. The source compares DHCP Server, NXP `net iface`, RCS scan discovery, and industrial PC `arp -a`. Visible text shows address differences such as `02:04:a0:a1:31:c8` versus `02:04:9F:31:A1:C8` / `02049F31A1C8`, and notes possible cross-use between `K02A20MN` and `K02A11MN`.

- `minisort-test-pt-0097`: original screenshots, raw exports, script details, conversion rule, final root cause, and retest are missing.

## Return Box Batch Exception Aggregate Negative Remaining

Knowledge file: `docs/minisort-test/knowledge/return-box-batch-exception-aggregate-negative-remaining.md`

### First Checks

- Confirmed branch: the failure happens in WRS return-box batch exception handling.
  - `wrs.log` shows `2026-04-14 17:38:16.018` `POST /api/return-boxes/batch-exception-handling`.
  - Request body is `{"ids":[5],"abnormalReasonId":5}`.
  - `ReturnBoxService` logs `批量异常处理开始，异常原因: 5, 退货箱ID列表: [5]`.
  - Response is `200 (OK)` at `17:38:16.186`.
- Confirmed branch: the UI symptom is aggregate counter corruption, not a robot/device fault.
  - The screenshot shows return box `0414142813`, status `等待投递`, period `week16`, plan `200`, remaining `-1`, on-the-way `1`, recorded `136`, abnormal `64`.
  - The source analysis says after setting all remaining quantities to abnormal, final return-box remaining quantity should be `0`.
- Confirmed branch from source analysis: batch exception subtracts detail remaining sum from the current box remaining value.
  - Source formula: new return-box remaining = current return-box remaining - sum of remaining quantities in all details.
  - When detail remaining sum is greater than current box remaining, the aggregate becomes negative.
  - This operation is only for exception setting, so the aggregate remaining should be forced/recomputed to `0`.
- Evidence-backed branch: SQL updates occur in the same transaction window, but bound values are not visible.
  - `wrs-sql.log` around `17:38:16` shows many inserts into `return_box_sorting_details`.
  - It then updates `return_boxes` with `abnormal_quantity`, `on_the_way_quantity`, `recorded_quantity`, and `remaining_delivery_quantity`.
  - It also updates `return_box_details` with `abnormal_quantity`, `on_the_way_quantity`, `recorded_quantity`, and `remaining_delivery_quantity`.
  - The SQL log uses `?` placeholders, so it proves update paths, not exact written values.

### Evidence

- Bound SQL values or database snapshots before and after `POST /api/return-boxes/batch-exception-handling`.
- Source code diff for the aggregate formula and final fix.
- Unit/integration test covering detail residual sum greater than current box remaining.
- Post-fix UI screenshot or API response proving remaining and on-the-way counters are non-negative and semantically terminal.

### Exclusions

- Do not diagnose robot delivery failure when the primary evidence is WRS aggregate counter state after a successful batch exception API call.
- Do not route to full-box trigger/CAN gateway mapping unless the symptom is trigger-count UI, MQTT mapping, or full-box sensor configuration.
- Do not route to exception-mouth slow-run or locked-sowing movement timing; this case is WRS data accounting.
- Do not accept total count equality as sufficient; check non-negative counters and operation semantics.
- Do not claim the exact DB values were proven by `wrs-sql.log` unless bound parameters or DB snapshots are available.

### Examples

- `minisort-test-pt-0028`: M111 WRS return box `0414142813` had residual undelivered quantity. Batch exception handling with abnormal reason `5` succeeded at `2026-04-14 17:38:16`, then the UI showed remaining `-1` and on-the-way `1`. Source analysis identifies a formula bug: subtracting sum of detail remaining quantities from current box remaining can go negative; for this exception operation, box remaining should be `0`.

- `minisort-test-pt-0028`: SQL log does not show bound values; no code diff, DB before/after snapshot, automated test, or post-fix screenshot is local.
