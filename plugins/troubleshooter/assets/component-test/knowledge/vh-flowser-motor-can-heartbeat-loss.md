# VH Flowser Motor CAN Heartbeat Loss And Bus Drag-Down

source_set: `component-test-pt-0088`
case_count: 1 VH / Flowser baffle motor heartbeat-loss case with four local inspection photos and no raw CAN/log attachment
status: runtime routing rules for VH/Flowser motor heartbeat loss, FlowCAN direct-connection failure, and motor-node bus drag-down

## Symptoms

- VH 心流 / Flowser baffle motor loses heartbeat after short runtime.
- Replacing the motor with same-batch or previous-batch motors reproduces the fault within minutes to tens of minutes.
- Source says CAN bus and bus resistance were measured with no abnormality, but FlowCAN direct connection could not communicate and could not send messages to the motor.
- Source says the whole CAN bus became unavailable.
- Example `component-test-pt-0088`: S209 library `401` vehicle changed a VH baffle motor at `2026-03-12 16:50:22`; after about 30 minutes the baffle motor lost connection. On `2026-03-13 10:00`, another same-batch throw motor failed after about 10 minutes. On `2026-03-13 14:00`, a previous-batch throw motor that had previously run 300 hours faulted after about 2 minutes. On `03-17`, a motor using the same CAN chip and TVS protection was replaced and was still running at the time of the source note.

## Fault Tree

1. Separate bus-level unavailability from normal heartbeat timeout.
   - If FlowCAN direct connection cannot communicate with the isolated motor and cannot send messages, prioritize motor-node electrical/CAN-transceiver/protection branches.
   - If the isolated motor communicates but fails only inside the robot harness, prioritize cable, connector, termination, grounding, shielding, and power branches.
2. Treat normal-looking static resistance as insufficient.
   - Source says CAN bus and resistance were measured without abnormality.
   - Local photos show motor terminal/resistance measurements around `3.51kΩ` and `3.52kΩ`, supporting no obvious coil/terminal resistance difference between good and bad motors.
   - Static resistance does not prove the CAN transceiver, TVS/protection path, node power, oscillator, firmware boot state, or intermittent short is healthy.
3. Inspect whether one failed node drags down the whole bus.
   - If plugging the failed motor makes the entire CAN bus unavailable, isolate that node before replacing other bus components.
   - Compare bus behavior with the suspect motor disconnected, with a known-good motor connected, and with FlowCAN directly attached.
4. Inspect the motor controller PCB and CAN front end.
   - Local photos show a `SERVO57 V006_B 20251203` board and visible CAN/front-end ICs, with no obvious burn mark in the photo.
   - No visible burn does not exclude ESD, TVS leakage/short, transceiver damage, solder defect, or firmware/boot failure.
5. Use runtime evidence to decide whether this is environmental overstress or batch/board design.
   - Same-batch recurrence supports a batch/design/protection branch.
   - The previous-batch motor that had run 300 hours but failed after replacement keeps environment/harness/power stress open.
   - The `03-17` replacement with the same CAN chip and TVS protection running normally is retest evidence, but the run duration and final result are not recorded locally.

## Evidence Needed

- Raw NXP/robot/motor logs around `2026-03-12 16:50:22`, `2026-03-13 10:00`, and `2026-03-13 14:00`.
- CAN candump/pcap or FlowCAN logs for direct connection before and after failure.
- Bus voltage/waveform capture for CANH/CANL with suspect motor connected and disconnected.
- Exact CAN bitrate, node ID, firmware version, motor board version, CAN chip part number, and TVS/protection part number.
- Harness/connector photos and notes from S209 `401` vehicle, including power supply, ground, termination, shield, and strain points.
- Repair or teardown result identifying whether the failed part was CAN transceiver, TVS/protection, MCU/boot, connector/solder, power, or mechanical/electrical overstress.
- Retest duration and pass/fail result after the `03-17` replacement.

## Logs And Files To Inspect

- Search terms: `VH心流电机心跳丢失`, `心流电机`, `FlowCAN`, `无法通讯`, `无法给电机发送消息`, `整条CAN总线不可用`, `电机失联`, `心跳丢失`, `FCST-24SS`, `SERVO57`, `V006_B`, `TJA`, `TVS`, `同一批次`, `上一批次`, `运行300小时`.
- Local images:
  - `assets/component-test-pt-0088/001-image-9a683d6e61c2.jpg`: motor resistance/terminal measurement, meter reads about `3.51kΩ`, EXIF `2026:03:13 10:58:39`.
  - `assets/component-test-pt-0088/002-image-907fdd81f98f.jpg`: similar motor measurement, meter reads about `3.52kΩ`, EXIF `2026:03:13 10:57:57`.
  - `assets/component-test-pt-0088/003-image-29be87b79c36.jpg`: motor PCB side with connector and front-end components, EXIF `2026:03:13 11:01:34`.
  - `assets/component-test-pt-0088/004-image-8031f34920a3.jpg`: PCB label `SERVO57 V006_B 20251203`, EXIF `2026:03:13 11:00:25`.
- Check whether source logs contain generic motor heartbeat strings such as `heartbeat timeout`, `CAN_MOTOR_ERROR`, `node timeout`, `SDO timeout`, `bus off`, `error passive`, or FlowCAN scan failure.

## Likely Causes

- Failed motor CAN transceiver or TVS/protection path that prevents direct FlowCAN communication.
- Suspect motor node pulling CANH/CANL or node power in a way that makes the whole bus unavailable.
- Harness, connector, power, ground, or termination issue on S209 `401` that damages or destabilizes multiple motors after replacement.
- Batch/design weakness in VH/Flowser motor CAN front-end protection under robot electrical environment.
- Less likely without raw evidence: pure application heartbeat bug, because FlowCAN direct connection also failed according to source text.

## Exclusion Checks

- Do not conclude ordinary heartbeat timeout if FlowCAN direct connection to the isolated motor also cannot communicate.
- Do not exclude CAN front-end damage from normal motor winding/terminal resistance or a PCB photo without visible burn.
- Do not blame the whole bus harness until the suspect motor is tested disconnected, directly connected, and compared with a known-good motor.
- Do not treat same-batch recurrence as the only cause; the previous-batch 300-hour motor also failed after installation, so environmental overstress remains open.
- Do not replace multiple robot-side CAN devices before isolating whether one failed motor node drags the bus down.
- Do not claim final root cause without raw CAN/FlowCAN logs, chip-level repair evidence, or retest duration.

## Confirmed Examples

- `component-test-pt-0088`: source text says S209 `401` vehicle replaced a VH baffle motor at `2026-03-12 16:50:22`; after about 30 minutes, the baffle motor lost connection and logs showed command-send failure. Source says CAN bus and resistance were measured with no abnormality, but FlowCAN direct connection could not communicate with the motor and could not send messages, making the whole CAN bus unavailable. Same-batch replacement reproduced after about 10 minutes at `2026-03-13 10:00`; previous-batch motor reproduced after about 2 minutes at `2026-03-13 14:00`; source notes that the previous-batch motor had run 300 hours before replacement. Local photos show two motor resistance readings around `3.51kΩ` and `3.52kΩ`, and PCB photos show `SERVO57 V006_B 20251203` with no obvious visible burn in the inspected images.

## Unresolved Examples

- `component-test-pt-0088`: no raw NXP/robot/motor log, FlowCAN export, candump/pcap, oscilloscope waveform, exact node ID, motor firmware, harness inspection, chip-level failure analysis, or final retest duration is local. The case supports a strong VH/Flowser motor CAN-node failure branch, but does not prove whether the failed point is CAN transceiver, TVS/protection, MCU/firmware boot, connector/solder, harness overstress, or robot-side power/ground.

## Specialist Routing

- `can-bus`: FlowCAN direct-connection failure, heartbeat loss, CANH/CANL waveform, bus drag-down, node isolation, transceiver/TVS branch.
- `embedded-software`: motor heartbeat timeout strings, command-send failure, node boot state, firmware/version, and retry behavior.
- `vision-media`: motor resistance photos, PCB/component photos, connector/harness inspection photos.
- `hardware`: chip-level repair, TVS/transceiver/MCU/power-front-end failure analysis.
