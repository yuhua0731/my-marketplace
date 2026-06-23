# Lift Home Sensor Sheetmetal Gap Misalignment

## Symptoms

- Ant 3.0 lift homes downward, completes origin search, then moves upward about `10mm`.
- Front and rear lift origin sensors disagree, for example `inductiveSensorFront: true` and `inductiveSensorRear: false`.
- Front origin sensor orange light may be on while rear origin sensor orange light is off.

## Fault Tree

1. Confirm the sensor state mismatch against physical indicators.
   - `ant-3-test-pt-0124` MQTT/state screenshot shows `inductiveSensorFront: true` and `inductiveSensorRear: false`.
   - Source says front origin sensor is triggered and rear origin sensor is not triggered.
2. Inspect sensor-target gap before software/CAN diagnosis.
   - Source says front origin sensor to slider gap is small enough to trigger.
   - Source says rear origin sensor to slider gap is too large and cannot trigger.
3. Check design margin against stable sensor range.
   - Follow-up report says design gap is `2.5mm`.
   - The selected GX-H8A-P sensor maximum working distance is `2.5mm`, but stable detection range is only `0~2.1mm`.
   - This makes the design effectively zero-margin.
4. Check sheet-metal and assembly tolerance stack.
   - Report/table says sheet-metal bending and angle errors can make real gaps vary from about `0.4~2.1mm`.
   - Too-small gap around `0.3mm` can collide with and damage the sensor probe.
   - Too-large gap greater than `2.1mm` can cause missed or intermittent trigger.
5. Check dual-side height datum and coupling slip.
   - Embedded sheet records front/rear sensor measured heights `23.77mm` and `27mm`.
   - Report says assembly datum is not unified and dual-side height calibration is missing.
   - Report also records insufficient coupling clamping redundancy as a contributing factor.

## Evidence Needed

- Raw robot/NXP log for lift homing and sensor sampling.
- Measurement record for front/rear sensor height, sensor-target gap, bend angle, and sheet-metal critical dimensions.
- Sensor model/spec sheet for stable detection range, not only maximum working distance.
- Before/after photos of sensor-target gap after rework.
- Repeated initialization/homing retest proving both sensors trigger consistently.
- Drawing revision, tolerance control plan, and assembly fixture/calibration work instruction.

## Logs And Files To Inspect

- Case body: `cases/accepted/ant-3-test/0124-P4cQwFUCsirR4NkhQ6hch1UNn0e-2026-05-16-蚂蚁3.0举升机构原点传感器触发异常.md`.
- Follow-up doc: `OgvWdfGDAowYSaxC9hBcHQ9Jnzh`, `蚂蚁 3.0 下原点传感器未触发问题分析报告`.
- Embedded sheet: `FzfxsN7QDhJjyptQg8ackXUgnKc`, sheet `jFFKzd`.
- Local images: `assets/ant-3-test-pt-0124/retry-image-001-G7jUb8rY7oXyNNxVu7Zcr0UfnGc.jpg`, `retry-image-002-NQbIbIvMooNF2fx7cSOcEMDGnBe.png`, `retry-image-003-VoUEbr54ZoJ31ex7kVCcA4eWnJh.png`, `retry-image-004-BbZubBfWYo8BI9xTYrxc7paZn8c.png`.
- Search terms: `inductiveSensorFront`, `inductiveSensorRear`, `下原点传感器`, `前原点传感器`, `后原点传感器`, `塔式钣金件折弯尺寸`, `2.5mm`, `0~2.1mm`, `1.5~2.0mm`, `23.77mm`, `27mm`, `双侧传感器不同步`.

## Likely Causes

- Zero-margin sensor gap design uses the maximum working distance as the nominal design value.
- Sheet-metal bending, bend-angle, and dimension-chain errors move the target outside the stable sensing range.
- Assembly datum mismatch leaves front and rear sensor heights inconsistent.
- Coupling slip or insufficient clamping redundancy can worsen dual-side synchronization and sensor timing.

## Exclusion Checks

- Do not diagnose MQTT reporting or firmware state-machine error if physical front/rear gap explains the state mismatch.
- Do not route to ALLCAN power, DM camera, or boost-module branches unless logs show aligned power/CAN/camera symptoms.
- Do not accept max sensing distance as normal design margin; use stable detection range.
- Do not rework only one side without measuring both front/rear heights and gaps.
- Do not close without post-rework measurement and repeated homing validation.

## Confirmed Examples

- `ant-3-test-pt-0124`: after initialization and upward `10mm` movement, front origin sensor triggered while rear origin sensor did not. MQTT showed `inductiveSensorFront: true`, `inductiveSensorRear: false`. Source inspection found the rear sensor gap too large. Follow-up report identified design gap `2.5mm` versus stable range `0~2.1mm`, sheet-metal/assembly tolerance stack, and front/rear height mismatch (`23.77mm` vs `27mm`) as combined causes. Recommendation was to redesign gap to `1.5~2.0mm`, increase machining control, and add unified assembly datum/calibration tooling.

## Unresolved Examples

- `ant-3-test-pt-0124`: no raw robot log, no final drawing revision, no after-rework measurement, and no repeated homing retest record are local.

## Specialist Routing

- Start with `robot-motion` for lift homing sequence, dual-side synchronization, and origin behavior.
- Add `vision-media` for sensor-target gap photos and mechanical model inspection.
- Add `embedded-software` for MQTT state, sensor sampling, and homing state-machine evidence.
- Add `can-bus` only if physical gap is corrected but sensor/CAN state remains inconsistent.
