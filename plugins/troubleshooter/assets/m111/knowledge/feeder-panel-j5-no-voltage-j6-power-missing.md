# M111 Feeder Panel J5 No Voltage From Missing J6 Power Wiring

source_set: `m111-pt-0034`
case_count: 1 Mini/M111 feeder-panel voltage and IO-definition mismatch case
status: runtime routing rules for feeder overheight sensor wiring where the IO table points to CAN node 11 / panel J5 but the panel has no output voltage because its J6 power feed is not wired

## Symptoms

- Mini/M111 feeder or parcel conveyor panel retrofit adds an overheight detection sensor / `超高检测传感器`.
- The IO definition says the sensor should be installed on CAN node 11 feeder conveyor panel J5.
- After insertion into J5, the sensor has no voltage display and multimeter measurement shows no voltage output at the port.
- Field drawing review finds the panel J6 port has no power wire; the workaround is to connect the overheight sensor to the CAN node 10 panel.
- The IO definition / CANIO location mapping needs correction so ALLCAN-4 attached device positions are not misleading.

## Fault Tree

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

## Diagnostic Rules

- For `J5没有电压`, `没有电压显示`, or overheight sensor no-voltage symptoms on Mini/M111 feeder panels, inspect panel power-feed wiring first, especially J6/V+/V- power input.
- If the ALLCAN-4 board LEDs are on but the target sensor port has no voltage, do not assume the sensor is faulty; measure the exact port and trace its upstream feed.
- Compare three sources before changing software: IO definition table, electrical drawing, and physical panel/node label.
- If IO table says CAN node 11 but the powered panel is CAN node 10, record both node IDs and fix the device-location mapping; a temporary node-10 connection is not a final documentation fix.
- Route this separately from `omnisort.conveyor_recovery_race` and `omnisort.m111.feeder_sensor_position_package_slide_multi_package`; those require recovery timing or package-tracing/sensor-position evidence.

## Evidence Needed

- IO definition table before/after correction, including CAN node, panel connector, and device-location description.
- Electrical drawing showing the J5 sensor connector and J6 power-feed relationship.
- Multimeter photos or measurement record for J5 V+/V-, J6 input, and the alternate CAN node 10 panel.
- CANIO input-state log or test output proving the sensor toggles after the workaround or wiring correction.
- Final corrected wiring or table revision and post-fix sensor validation.

## Logs And Files To Inspect

- Case body: `cases/accepted/m111/0034-IrHKwlkO1in28Pkn8OicrXChntc-2026-04-03-Mini-M111新增供包机-供包机输送面板没有电压问题.md`.
- Local image: `assets/m111-pt-0034/001-image-c25004a8c1c3.jpg`.
  - 3024 x 4032 JPEG.
  - Shows an HC ROBOTICS ALLCAN-4 board / parcel conveyor panel area with multiple connected harnesses and active red/green LEDs.
- Local image: `assets/m111-pt-0034/002-image-c9599982727d.jpg`.
  - 1080 x 1440 JPEG.
  - Shows `PARCEL CONVEYOR PANEL`, visible `J4 V-/V+`, `J8 48V-/48V+`, CAN state LED, and connected panel harnesses.
- Search terms: `m111-pt-0034`, `Mini M111`, `新增供包机`, `供包机输送面板`, `J5`, `J6`, `没有电压`, `万用表`, `超高检测传感器`, `can节点11`, `can节点10`, `allcan4`, `ALLCAN-4`, `io表`, `CANIO`, `设备位置说明`.

## Likely Causes

- Missing panel power feed: J6 not wired, leaving the target J5 sensor connector without output voltage.
- IO definition table points the overheight sensor to a panel/node location that is not actually powered in the installed harness.
- Electrical drawing, field wiring, and CANIO device-location documentation are out of sync.

## Exclusion Checks

- Exclude overheight sensor failure only after measuring voltage at J5 and verifying sensor behavior on a known-powered input.
- Exclude package-tracing sensor-position config if the immediate symptom is no port voltage before any package movement.
- Exclude conveyor recovery race if there is no recovery timestamp sequence, force discharge, load failure, or throw failure.
- Exclude CAN bus communication as primary if the panel node is alive and LEDs are on but the specific sensor connector lacks power.
- Do not close with a temporary node-10 connection unless IO table and wiring documentation are corrected or explicitly tracked.

## Confirmed Examples

- `m111-pt-0034`: IO table said the overheight detection sensor should connect to CAN node 11 feeder conveyor panel J5. After insertion, the sensor had no voltage display; field multimeter measurement found no voltage output. Drawing review found panel J6 had no power wire. The temporary action was connecting the sensor to the CAN node 10 ALLCAN-4 panel, and the follow-up was to rework CANIO / ALLCAN-4 device-location descriptions.

## Unresolved Examples

- `m111-pt-0034`: local assets do not include the IO table, electrical drawing, multimeter reading photo, CANIO state log, or post-fix validation after documentation correction.

## Specialist Routing

- Start with `embedded-software` for IO definition, CANIO mapping, device-location table, and input-state validation.
- Add `can-bus` for ALLCAN-4 node identity, node 10/node 11 mapping, CANIO state, and panel node reachability.
- Use `vision-media` for panel connector/photo inspection.
- Add handling/mechanical review only if the sensor location or harness routing cannot physically match the drawing.
