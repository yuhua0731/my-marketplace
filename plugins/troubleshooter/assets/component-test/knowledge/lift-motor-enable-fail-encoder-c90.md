# Lift Motor Enable Failure With Encoder Er.C90

## Symptoms

- Dual-motor lift or lift-module test system reports lift motor enable failure during operation.
- UI alarm can name one side and motor, for example `D端提升机电机2使能失败`.
- Servo/drive panel displays `Er.C90` or `Er. C90`.
- The fault may appear once and recover after power cycle, which suggests intermittent encoder communication rather than confirmed permanent break.

## Fault Tree

1. Confirm the drive-local alarm.
   - UI `使能失败` is a symptom at the control layer.
   - `Er.C90` on the servo drive maps the failure to encoder communication/disconnected-line branch.
2. Check encoder wiring and connector first.
   - Reseat the encoder cable connector.
   - Measure each encoder signal wire with a multimeter.
   - Move the lift/cable harness while measuring to catch intermittent contact.
3. Check cable model, length, and routing.
   - Confirm the encoder cable model is correct and not too long for the drive/motor pair.
   - Inspect bend radius, strain relief, connector latch, and whether lift motion pulls the cable.
4. Check EMI and grounding.
   - Verify drive grounding and shield termination.
   - Separate encoder cable from motor power cable where possible.
   - Add ferrite ring or grounding mitigation only after preserving the original wiring evidence.
5. Check motor/drive parameters and hardware last.
   - Confirm motor group parameters match the actual motor/encoder.
   - If wiring, cable, grounding, and parameters are excluded, suspect servo drive or encoder hardware.

## Evidence Needed

- UI alarm screenshot with exact time and motor/side label.
- Drive-panel photo showing `Er.C90`.
- Servo manual or vendor fault table mapping `Er.C90`.
- Encoder cable continuity test, including dynamic movement during lift operation.
- Connector close-up before and after reseating.
- Cable model, cable length, routing, shield/grounding, and ferrite-ring state.
- Servo/drive logs or CAN/fieldbus trace around the failure time.
- Retest after reseating or EMI mitigation.

## Logs And Files To Inspect

- `cases/accepted/component-test/0132-M3QIww4AeiLQxJkgn0ccYpAcnZd-2026-05-14-双电机测试库-提升电机使能失败.md`
- `assets/component-test-pt-0132/retry-image-001-IZWDbhsnHouyA2xpINtcc9uonvd.jpg`
- `assets/component-test-pt-0132/retry-image-002-WL2Jb7OmkoyZuax8RsSc8shWnHe.jpg`
- `assets/component-test-pt-0132/retry-image-003-ADTDbsnpWogE6xxkUvkcM8CfnUh.jpg`
- Search terms: `D端提升机电机2使能失败`, `Er.C90`, `Er. C90`, `编码器通信故障`, `编码器线`, `插件松动`, `断电重启`, `磁环`, `驱动器接地`.

## Likely Causes

- Encoder cable connector loosened or intermittent during lift motion.
- Encoder cable experiences EMI from motor power wiring or poor grounding/shielding.
- Encoder cable model, length, bend, or strain relief is unsuitable.
- Motor group parameter mismatch.
- Servo drive or encoder hardware fault after wiring/EMI/parameter branches are excluded.

## Exclusion Checks

- Do not route to generic C134/Mantis reboot/power just because reboot recovery appears in the source text.
- Do not diagnose a software enable-state fault before checking `Er.C90` encoder communication evidence.
- Do not call physical wire break confirmed without continuity or inspection proof.
- Do not replace the servo drive until connector, cable, grounding/shielding, cable length/model, and motor parameters are checked.
- Do not close a one-time recovered fault without repeated lift-motion retest.

## Confirmed Examples

- `component-test-pt-0132`: CS002 dual-motor lift test library reported `D端提升机电机2使能失败` at `2026-05-14 04:48:28`. The drive panel displayed `Er.C90`; the manual image maps `Er.C90` to encoder communication fault/disconnected line. Source says the fault occurred once and recovered after power cycle, preliminarily excluding a permanent encoder signal-line break. The suspected branches were encoder cable connector looseness during lift operation or encoder cable interference; action was to reseat the encoder cable connector, and if it recurs, add a ferrite ring to the motor power line.

## Unresolved Examples

- `component-test-pt-0132`: no raw drive/CAN logs, no continuity test, no connector close-up, no cable model/length, no grounding/shielding measurement, and no repeated retest record are local.

## Specialist Routing

- `embedded-software`: UI alarm, enable-state transition, drive alarm capture, motor parameter consistency.
- `can-bus`: drive/CAN/fieldbus trace only if available; distinguish communication consequence from encoder physical link.
- `vision-media`: UI screenshot, drive panel, manual excerpt, connector/cable routing photos.
- `hardware`: encoder cable, connector, shield/ground, ferrite ring, strain relief, servo drive, and encoder hardware.
