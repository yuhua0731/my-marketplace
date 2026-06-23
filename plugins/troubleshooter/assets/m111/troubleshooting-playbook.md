# M111 Troubleshooting Playbook

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

## Baffle Added Drag Chain Bracket Interference

Knowledge file: `docs/m111/knowledge/baffle-added-drag-chain-bracket-interference.md`

### First Checks

1. Start with mechanical envelope and mounting access.
   - In `m111-pt-0058`, the source states the drag-chain fixed hole was blocked by the added baffle component.
   - The failure is a physical installability problem, not an initial software, CAN, or scheduling symptom.
2. Confirm whether the old bracket design is incompatible with the new mechanism.
   - Source analysis states: `原拖链支架与挡板机构不匹配，无法固定安装`.
   - Local image `001-image-125a4ca25d1d.png` shows a new metal drag-chain bracket and the original black bracket side by side with different geometry and hole layout.
3. Inspect cable and drag-chain routing after the fix.
   - Local image `002-image-5310d42b0f2d.jpg` shows the new bracket installed near the baffle-side structure, drag chain, and cables.
   - Representative video frame shows close-up inspection around the cable/drag-chain mounting area.
4. Confirm resolution by replacement.
   - Source action says `重新设计并下单拖链支架`.
   - Source follow-up says `更换新拖链支架后问题已解决`.
5. Do a full motion-cycle clearance check before closing a repeated field issue.
   - A static image can prove installability but not full travel clearance, cable bend radius, or scrape-free operation.

### Evidence

- Before image/video showing the blocked mounting hole and the interfering baffle component.
- After image/video showing the new bracket installed and the drag chain fixed.
- CAD or drawing overlay for old bracket, new bracket, baffle component, mounting hole, cable route, and fastener access.
- Bracket part number, revision, and BOM/change notice.
- Full robot/baffle travel video or clearance measurement after replacement.
- Cable bend-radius and pinch/scrape inspection after repeated movement.

### Exclusions

- Do not diagnose CAN, firmware, scheduler, or workstation logic from a blocked mounting hole.
- Do not classify this as baffle actuator behavior unless logs or motion evidence show actuator state failure after mechanical installation succeeds.
- Do not close as solved from a redesigned bracket alone; verify installation, cable routing, bend radius, and full travel clearance.
- Do not generalize the new bracket to all M111 variants without checking baffle revision, robot side, hole pattern, and drag-chain route.

### Examples

- `m111-pt-0058`: after adding a baffle to an M111 drag-chain robot, the baffle blocked the drag-chain fixed hole. Source analysis says the original bracket did not match the baffle mechanism. A redesigned drag-chain bracket was ordered; after replacing the new bracket, the problem was resolved. Local images show new/old bracket geometry comparison and the post-fix installation area.

- `m111-pt-0058`: exact missing initial annotated interference image, CAD/BOM revision, part number, and full motion-cycle clearance proof are not local.

## Baffle Robot Boot CAN Sync Loss After Firmware Update

Knowledge file: `docs/m111/knowledge/baffle-robot-boot-can-sync-loss.md`

### First Checks

- Confirmed branch: CANopen communication to motor node 1 is not completing.
  - `retry-source-DFRxbVBeFobzBYxrXWycfXXAnvh.log` contains `15113` lines of `CO_SDOclientUpload error: -11`.
  - `15097` lines target `index 6064 sub_index 0 node_id 1 abort code: 84148224`.
  - Abort code `84148224` is `0x05040000`, consistent with CANopen SDO timeout.
- Likely branch: firmware update exposed a CANopen boot/sync/initialization incompatibility.
  - The case source explicitly ties the symptom to `更新固件`.
  - The same log contains repeated bootloader/reboot markers, `Proceed to reset all nodes`, and node heartbeat timeouts for nodes `1`, `2`, and `3`.
- Likely branch: motor node 1 does not reach a stable operational state before the application reads object `0x6064`.
  - The failing object `0x6064` is the CANopen position actual value.
  - Repeated reads every about 100 ms should be treated as a diagnostic symptom, not as proof that position feedback is the root cause.
- Excluded branch: orange flashing alone proves firmware defect.
  - Orange flashing is only a state indicator for CAN sync loss; it must be paired with logs or CAN frames.
- Blocked branch: video-confirmed LED sequence and physical boot timing.
  - Local MOV exists, but this environment has no `ffmpeg`/`ffprobe`, and ImageMagick cannot decode it without ffmpeg.

### Evidence

- Raw CAN frames or candump/pcap from boot through the first orange flashing state.
- Exact firmware version, commit, build target, object dictionary/EDS, node-ID map, bitrate, SYNC producer settings, and heartbeat timeout settings.
- Successful-boot comparison log from the same robot and same firmware.
- Confirmation that `retry-source-CS3tbdsMToP1k3xf5ntcysFXnSc.hex` is the exact firmware flashed to the failing device.
- Decodable video frames or onsite observation showing boot sequence, LED state changes, and timing relative to log timestamps.
- Wiring, termination, power-rail, and node-1 motor/controller inspection if the failure remains after firmware rollback or config correction.

### Exclusions

- Exclude pure network/MQTT fault only if CANopen SDO timeout and node heartbeat loss are absent; `mqtt_service: iface ... not ready` appears during boot but is not the strongest symptom here.
- Exclude LED-board/display fault only if logs and CAN frames show normal SYNC, heartbeat, and SDO reads while the LED still flashes orange.
- Exclude motor position sensor fault only if node 1 is operational and CAN transport is healthy but object `0x6064` returns invalid position values.
- Exclude firmware regression only after reproducing both old and new firmware with the same hardware, node-ID map, and CAN capture.

### Examples

- `m111-pt-0116`: after firmware update, M111 baffle robot probabilistically failed to boot and flashed orange. Log from `2026-05-07T08:30:35Z` through `09:39:34Z` repeatedly reports `CO_SDOclientUpload error: -11, index 6064 sub_index 0 node_id 1 abort code: 84148224`; the same log includes bootloader/reboot markers and node heartbeat timeout events.

- `m111-pt-0116`: root cause remains unresolved because raw CAN frames, firmware version mapping, successful-boot comparison, and decodable video evidence are missing.

## Conveyor Recovery Race After Load Failure

Knowledge file: `docs/m111/knowledge/conveyor-recovery-race.md`

### First Checks

- Confirmed branch: recovery ordering race.
  - In `m111-pt-0037`, conveyor overheight was restored at `2026-04-10 14:58:05`, robot throw failure was restored at `14:58:08`, and robot load failure was reported at `14:58:14`.
  - Visible source states the lift was still on floor 1 when conveyor overheight was restored, then rose to floor 2 before the robot reported load error.
- Likely branch: missing interlock between conveyor recovery and robot load-failure acknowledgement.
  - Do not allow conveyor/lift recovery to advance floor or force-discharge while the paired robot station action is still unresolved.
- Blocked branch: media-only confirmation of exact lift movement.
  - Videos were downloaded, but source text already carries the key timing and fix statement.

### Evidence

- Operator recovery timestamps for conveyor error and robot error.
- Robot ID, site number, lift floor, parcel physical location before and after recovery.
- RCS / conveyor state-machine logs around `restore error`, `load fail`, `throw fail`, `force throw`, and lift floor transition.
- Video is useful to confirm physical floor/parcel state, but must not replace state-machine timestamps.

### Exclusions

- Exclude pure sensor fault only if logs show the state machine advanced before any sensor inconsistency.
- Exclude robot hardware fault if the robot correctly reports throw/load failure and the bad behavior occurs during conveyor recovery.
- Exclude operator error only if the software explicitly permits the recovery sequence without guarding parcel ownership.

### Examples

- `m111-pt-0037`: two parcels with same destination. Simulated robot throw failure, conveyor overheight, then load failure. The source says code was modified and the issue was fixed.

- None in this knowledge file.

## M111 Feeder Panel J5 No Voltage From Missing J6 Power Wiring

Knowledge file: `docs/m111/knowledge/feeder-panel-j5-no-voltage-j6-power-missing.md`

### First Checks

1. Confirm whether the symptom is port power absence, not package-flow logic.
   - In `m111-pt-0034`, the source says the J5 port had no voltage after the overheight sensor was connected.
   - The field measured the port with a multimeter and found no voltage output.
   - Do not start from conveyor recovery, multi-package, package slide, or load/throw failure unless those alarms are present in the same timeline.
2. Trace the panel power feed before replacing the sensor.
   - The source conclusion is that the panel J6 port was not connected to a power wire.
   - If J6 is not fed, downstream V+/V- or sensor VCC/GND pins on the panel can be unpowered even when the ALLCAN-4 board itself has LEDs.
3. Cross-check IO definition against physical wiring and drawing.
   - The IO table mapped the overheight sensor to CAN node 11 panel J5.
   - The workable field workaround was connecting the sensor to the CAN node 10 panel instead.
   - Treat this as an IO table / wiring drawing / physical harness consistency problem before diagnosing firmware.
4. Verify after remap or wiring correction.
   - Confirm J5 V+/V- or sensor VCC/GND with a meter.
   - Confirm sensor state changes at the CANIO input after wiring or node mapping is corrected.
   - Update the IO definition so ALLCAN-4-connected device location descriptions match the installed panel.

### Evidence

- IO definition table before/after correction, including CAN node, panel connector, and device-location description.
- Electrical drawing showing the J5 sensor connector and J6 power-feed relationship.
- Multimeter photos or measurement record for J5 V+/V-, J6 input, and the alternate CAN node 10 panel.
- CANIO input-state log or test output proving the sensor toggles after the workaround or wiring correction.
- Final corrected wiring or table revision and post-fix sensor validation.

### Exclusions

- Exclude overheight sensor failure only after measuring voltage at J5 and verifying sensor behavior on a known-powered input.
- Exclude package-tracing sensor-position config if the immediate symptom is no port voltage before any package movement.
- Exclude conveyor recovery race if there is no recovery timestamp sequence, force discharge, load failure, or throw failure.
- Exclude CAN bus communication as primary if the panel node is alive and LEDs are on but the specific sensor connector lacks power.
- Do not close with a temporary node-10 connection unless IO table and wiring documentation are corrected or explicitly tracked.

### Examples

- `m111-pt-0034`: IO table said the overheight detection sensor should connect to CAN node 11 feeder conveyor panel J5. After insertion, the sensor had no voltage display; field multimeter measurement found no voltage output. Drawing review found panel J6 had no power wire. The temporary action was connecting the sensor to the CAN node 10 ALLCAN-4 panel, and the follow-up was to rework CANIO / ALLCAN-4 device-location descriptions.

- `m111-pt-0034`: local assets do not include the IO table, electrical drawing, multimeter reading photo, CANIO state log, or post-fix validation after documentation correction.

## Feeder Sensor Position Causes Package Slide Or Multi-Package Alarms

Knowledge file: `docs/m111/knowledge/feeder-sensor-position-package-slide-multi-package.md`

### First Checks

- Confirmed branch: light-curtain position configuration.
  - In `m111-pt-0035`, source resolution says the issue was fixed by changing `/etc/station_config/sensor.json`.
  - Feeder log contains `42136` occurrences of `package infeed error skip, sensors[0].length_sensor_state 0`.
  - The same feeder log ends with `sensors[0] LENGTH_SENSOR_ERROR`, `sensors[1] LENGTH_SENSOR_ERROR`, `sensors[2] LENGTH_SENSOR_ERROR`, followed by `LOADING_ERROR`.
- Likely branch: physical light-curtain order/position does not match configured section boundaries.
  - This can make normal parcel movement look like slide, duplicate package, missing length sensor, or impossible infeed state.
- Downstream branch: conveyor recovery waits for a shuttle and then force unloads.
  - Central control reports `RECOVER_CONVEYOR_ERROR_WAITING_SHUTTLE_AT_SITE` until robot `013` is present at `M111-SITE-1`.
  - Once `shuttlesInSameTrackLength: 1`, the site changes to force throw/unload and later clears `CONVEYOR_EVENT_0X01` or `CONVEYOR_EVENT_0X09`.

### Evidence

- Before/after `/etc/station_config/sensor.json`.
- Feeder log before and after correction.
- Error-code mapping for `CONVEYOR_EVENT_0X01` / `CONVEYOR_EVENT_0X09` to UI alarms.
- Video frames or onsite observation showing the parcel crossing the relevant light curtains.
- Physical measurement or photo of light-curtain positions.

### Exclusions

- Exclude robot 013 as primary cause if feeder sensor-state errors precede or coincide with the slide/multi-package alarm and config correction resolves it.
- Exclude generic conveyor recovery race when the initial symptom is package-tracing misclassification from sensor position.
- Exclude pure sensor hardware failure only after checking config-to-physical alignment and verifying sensor state changes at the controller input.
- Exclude workstation/WLED routing; feeder light curtain and conveyor recovery evidence belongs to handling/embedded/scheduler branches.

### Examples

- `m111-pt-0035`: no-scan infeed through the first feeder section produced `供包机包裹滑动`; using the second section produced `供包机多包`; source fix was changing `/etc/station_config/sensor.json`. Feeder log showed high-frequency `sensors[0].length_sensor_state 0` and later multi-sensor `LENGTH_SENSOR_ERROR`; central control showed conveyor recovery and short force-unload windows around robot `013`.

- None in this knowledge file.

## M111 Lift Belt Motor Noise And Red Blink Under No-load

Knowledge file: `docs/m111/knowledge/lift-belt-motor-noise-red-blink-no-load.md`

### First Checks

1. Separate belt/load path from motor-only path.
   - If abnormal noise disappears after removing the synchronous belt, inspect belt tension, pulley alignment, bearing drag, rubbing guards, and load path.
   - If abnormal noise remains after removing the synchronous belt, prioritize motor body, motor bearing, encoder/commutation, driver, wiring, or motor controller fault.
2. Treat red blinking as a drive-state clue, not only a visual symptom.
   - Capture the exact blink code and same-window driver/CAN/error log before assigning root cause.
   - Red blink during stutter can indicate driver protection, overcurrent, phase/encoder abnormality, stall, or controller error depending on the vendor code table.
3. Inspect mechanical isolation before replacing firmware.
   - Confirm pulley set screw, shaft coupling, motor mount, belt tension, belt path, and adjacent guard clearance.
   - Then run motor unloaded, belt-only, and loaded tests to localize the sound.
4. Inspect electrical/control branch.
   - Check motor power, phase wiring, encoder cable, driver alarms, CANopen state, current/torque trend, speed command, and script command cadence.
5. Verify after component swap or adjustment.
   - A valid repair proof needs no-load motor run, belt-installed run, and continuous script run without stutter/noise/red blink.

### Evidence

- Videos with audio for loaded belt run and no-belt motor-only run.
- Exact motor/driver model, blink-code table, and red-blink pattern.
- Driver/CANopen/alarm logs aligned with the stutter window.
- Motor current/torque/speed command trend during continuous script run.
- Belt tension, pulley alignment, coupling/set-screw, bearing, and guard-clearance inspection.
- Swap test: motor, driver, cable, or belt path replaced one at a time.
- Post-fix retest under the same continuous script.

### Exclusions

- Do not diagnose only belt tension or conveyor rubbing if the motor-only/no-belt test still produces the abnormal sound.
- Do not diagnose scheduler/conveyor recovery race; this symptom occurs during motor operation/debug script and is tied to motor red blink.
- Do not claim motor replacement is confirmed without a swap test or post-fix retest.
- Do not use video presence alone as audio proof; record whether the abnormal sound was actually heard or only described by source text.
- Do not ignore red-blink code; vendor-specific blink pattern can change the branch from mechanical to electrical/driver.

### Examples

- None. `m111-pt-0032` is useful for the isolation method but lacks driver logs, blink-code decoding, and repair proof.

- `m111-pt-0032`: during Mini M111 lift-module debugging, belt motor made abnormal noise and stuttered during continuous script operation; Xinliu motor status light red-blinked during stutter. After removing the synchronous belt, motor-only control still had a squeaking sound. Local videos are present with audio tracks and representative frames, but audio content, driver logs, blink code, current/torque data, and final repair are missing.

## M111 WRS Lift Module No Action After Second Scan

Knowledge file: `docs/m111/knowledge/wrs-lift-module-no-action-after-second-scan.md`

### First Checks

1. Build the transaction timeline first.
   - `m111-pt-0039`: at `2026-04-13 15:13:47`, the first parcel was delivered without scanning product barcode.
   - The unread exception slot was on layer 3, but layer 3 had no robot, so the parcel was delivered to the layer-2 exception slot.
   - At `15:13:49`, another scan/delivery was attempted; after the lift module received the parcel, it had no response, and 1 minute later the system showed an unresponsive popup.
2. Check stale state after exception-slot fallback.
   - The previous fallback to layer-2 exception slot may leave stale parcel ownership, destination, reservation, lift busy state, or exception-port state.
   - Treat this as scheduler/service transaction risk before hardware replacement.
3. Interpret module UI state narrowly.
   - Local image shows D002 with RF address `020416169969`, track `水平第2层`, voltage `56.1`, state `完成抛送货品`, restarting `否`, locked `否`.
   - This proves a visible UI state only; it does not prove the controller accepted the next command.
4. Escalate to lift/CAN/RF only after command evidence.
   - If WRS/RCS issued a lift command and no ack/state transition came back, inspect RF/CAN heartbeat, module controller logs, and motor/IO state.
   - If no command was issued, root branch stays in service task/reservation logic.

### Evidence

- WRS/RCS/SAS logs from `2026-04-13 15:13:47` through the 1-minute timeout.
- Lift module controller logs for D002 command send, ack, state transition, and timeout.
- RF/CAN capture or telemetry around D002 if a command was sent but no response returned.
- UI screenshot or log for the exact unresponsive popup.
- Task/order/container/barcode/SKU ID, exception-slot ID, station ID, and robot availability on each layer.
- Physical video or sensor log showing whether the lift received, held, jammed, or released the parcel.

### Exclusions

- Do not route to Ant/OmniFlow power because the UI table contains a restarting column.
- Do not route to CAN solely from `system_area: CAN`; require command/ack, heartbeat, RF/CAN, or controller evidence.
- Do not treat `完成抛送货品` as a terminal backend state; verify task locks and parcel ownership.
- Do not blame operator timing until the software contract for back-to-back scan/delivery after exception fallback is checked.
- Do not merge with conveyor recovery race unless logs show manual recovery or error restoration ordering.

### Examples

- `m111-pt-0039`: visible text records first parcel at `15:13:47`, exception-slot fallback from layer 3 to layer 2 because no robot existed on layer 3, second scan at `15:13:49`, lift module received parcel but did not act, and a system unresponsive popup appeared about 1 minute later. Local image shows D002 on layer 2 with voltage `56.1`, state `完成抛送货品`, not restarting, and not locked.

- `m111-pt-0039`: missing service logs, lift controller command/ack timeline, RF/CAN evidence, timeout popup screenshot, task/barcode/container IDs, robot availability, physical video, and final resolution.

## M111 WRS Timeout Rollback Versus Physical Parcel Delivery Divergence

Knowledge file: `docs/m111/knowledge/wrs-timeout-rollback-physical-parcel-divergence.md`

### First Checks

1. Build the WRS/RCS parcel ownership timeline.
   - `m111-pt-0104`: at `13:36:50`, two consecutive parcels were delivered to the feeder.
   - The first parcel had a simulated robot loading failure.
   - The second parcel stopped on the feeder belt while the first parcel remained unresolved.
2. Check WRS timeout rollback semantics.
   - Source analysis says WRS rolls back return-box pending/sorting quantity when a parcel times out.
   - During the unresolved robot load failure, the second parcel timed out at WRS layer and the remaining delivery count recovered from 42 to 44.
3. Check whether RCS still physically routes the timed-out parcel.
   - After the load-failure recovery, source says the first parcel was forced to an exception slot.
   - The second parcel then physically went to the normal target slot.
   - This creates a logical/physical split: WRS already rolled back the count, but RCS still treats the parcel as deliverable.
4. Validate timeout propagation and throw-time enforcement.
   - Source resolution adds timeout-duration injection when adding the barcode, tells RCS the parcel timeout duration, and makes RCS check timeout before throwing; timed-out parcels should go to exception.

### Evidence

- WRS logs around `13:36:50` through the 4-minute timeout and recovery.
- RCS/conveyor logs for the first and second parcel IDs/barcodes, including load-failure recovery, force-discharge, and final slot.
- Exact before/after UI values for remaining delivery count, in-transit count, recorded count, and abnormal count.
- Barcode add request payload showing timeout duration after the fix.
- RCS throw-decision log proving timed-out parcels are redirected to exception after the fix.
- Full video review or frame sequence of the two parcels if physical movement is disputed.

### Exclusions

- Exclude pure UI display defect only after WRS/RCS logs show counts and parcel states are correct internally.
- Exclude physical sensor package-tracing fault unless logs show the second parcel's physical presence/state is wrong before WRS timeout.
- Exclude generic conveyor recovery ordering race if the only mismatch is WRS timeout rollback versus later physical delivery; this branch needs count rollback and timeout evidence.
- Exclude operator recovery error if the system contract permits recovery while a timed-out parcel can still be delivered normally.

### Examples

- `m111-pt-0104`: two parcels were sent to the feeder at `13:36:50`; the first parcel simulated load failure and the second stopped on the belt. After about 4 minutes, WRS restored remaining delivery count from `42` to `44`. After robot load-failure recovery, the first parcel went to exception by force discharge, while the second was delivered to a normal target slot. The source fix injects timeout duration when adding the barcode and makes RCS check timeout before throwing, sending timed-out parcels to exception.

- `m111-pt-0104`: local assets do not include WRS/RCS logs, exact parcel/barcode IDs for both physical parcels, add-barcode payload diff, or post-fix throw-decision logs.
