# Ant 3.0 ALLCAN-4 Copper Standoff Insulation Short

source_set: `ant-3-test-pt-0125`
case_count: 1 focused Ant 3.0 ALLCAN-4 spark/smoke case
status: runtime routing rules for ALLCAN-4 mounting-insulation short during initialization/lift movement

## Symptoms

- Ant 3.0 ALLCAN-4 component sparks, smokes, or burns.
- The first symptom can occur after `init+move`, after lift homing, or when the lift motor starts rotating.
- Static ALLCAN-4 input voltage may look normal, for example `25.0V`.
- Robot function may still appear normal after visible sparking.
- Multiple same-batch Ant robots may show the same spark symptom without obvious functional alarms.

## Fault Tree

1. Treat physical spark/smoke as a hardware safety branch first.
   - `ant-3-test-pt-0125`: power cabin smoked and ALLCAN-4 was confirmed burned.
   - A replacement ALLCAN-4 sparked again when lift motor rotation began during `init+move`.
2. Inspect board mounting and insulation before software or CAN protocol.
   - The recorded cause says the ALLCAN-4 fixed-hole position used a copper standoff.
   - The copper standoff pressed through the ALLCAN-4 insulation layer and exposed internal routing.
   - The recorded fix was replacing the copper standoff with nylon material.
3. Separate static supply voltage from motion-coupled short.
   - Static input was recorded as `25.0V` and other electrical parts were reported normal.
   - A local short can still appear only during lift motor start, vibration, board flex, or harness movement.
4. Treat "can run normally" as risk masking.
   - `ant-3-test-pt-0125` says another Ant sparked during initialization but could run.
   - The source suspected 10 recently debugged Ant robots might all have the same spark symptom.
5. Keep CAN evidence as confirmation/follow-up.
   - Missing CAN logs mean heartbeat/NMT/reset behavior is unknown.
   - Do not route this primarily as a CAN protocol fault unless physical inspection excludes mounting short.

## Evidence Needed

- Close-up photo of ALLCAN-4 mounting hole, copper standoff, insulation damage, exposed trace, and burn point.
- Continuity/insulation-resistance measurement from standoff/frame to the exposed ALLCAN-4 trace or board ground.
- Oscilloscope or power-rail capture during `init+move` and lift motor start.
- CAN pcap/candump around the spark, including heartbeat/NMT/state before and after the event.
- NXP/system logs around lift homing, move command, reset markers, and ALLCAN communication state.
- Post-fix evidence: nylon standoff installed, repeated `init+move`/lift-motion retest, and same-batch fleet inspection result.

## Logs And Files To Inspect

- `cases/needs-assets/ant-3-test/0125-SpUjwlPGQiFKhbkSoK7cjhQPnxg-2026-05-18-蚂蚁3.0-ALLCAN-4元器件打火冒烟.md`
- `assets/ant-3-test-pt-0125/retry-source-MH3wbe8z8ojPu5xZ4NNcKxtLncc.mp4`
  - H.264/AAC, `5.710548752834467s`, `540x960`, `1299414` bytes.
  - QuickLook representative frame shows the power-cabin board/wiring area and a red/orange light or glow near the lower board area.
- Missing `image.png`: source alt text says the board is marked `V1.2.2`, `ID:0x10`, `Baud rate:1M`, and a black component is circled.
- Search terms: `K7A30AN`, `ALLCAN-4`, `元器件打火`, `冒烟`, `烧毁`, `init+move`, `举升机构`, `原点对零`, `举升电机转动瞬间`, `25.0V`, `铜螺柱`, `尼龙材质`, `绝缘层压破`, `漏出了内部走线`.

## Likely Causes

- Copper standoff or metal mounting hardware compresses the ALLCAN-4 insulation layer and contacts or exposes internal routing.
- Motion, vibration, lift motor startup current, or board flex turns marginal insulation damage into visible spark/smoke.
- Same-batch assembly with copper standoffs can create latent fleet-level fire/electrical risk even when robot function appears normal.

## Exclusion Checks

- Do not start with firmware, CANopen state, or ALLCAN protocol when there is visible spark/smoke and a recorded mounting-insulation cause.
- Do not clear the issue only because ALLCAN-4 static input voltage is `25.0V`.
- Do not treat normal robot operation after sparking as proof of safety.
- Do not use a missing board photo as confirmed visual evidence; record it as a gap until downloaded.
- Do not merge this with ALLCAN-DM decode-speed/no-read cases unless evidence shows the same power or mounting short branch.
- Do not close fleet risk until the suspected same-batch Ant robots are inspected or retested.

## Confirmed Examples

- `ant-3-test-pt-0125`: Ant 3.0 `K7A30AN` smoked in the power cabin after `init+move`; ALLCAN-4 was confirmed burned. After board replacement, ALLCAN-4 sparked again when the lift motor started rotating. Visible follow-up records the cause as a copper standoff pressing through the ALLCAN-4 insulation layer and exposing internal routing. The fix was replacing the copper standoff with nylon material.

## Unresolved Examples

- `ant-3-test-pt-0125`: missing original board image, raw CAN/NXP logs, oscilloscope/power-rail capture, before/after standoff photos, and same-batch fleet retest result.

## Specialist Routing

- `can-bus`: confirm whether ALLCAN heartbeat/NMT/reset changes occur around the spark; inspect pcap/candump if available.
- `embedded-software`: check NXP/system logs for lift state, reset markers, and command timing, but only after physical safety branch is handled.
- `vision-media`: inspect board photos/videos for standoff, insulation, exposed trace, burn point, and post-fix nylon hardware.
