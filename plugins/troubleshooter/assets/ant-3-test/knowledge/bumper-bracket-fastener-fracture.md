# Ant 3.0 Bumper Bracket Fastener Fracture

source_set: `ant-3-test-pt-0126`
case_count: 1 focused Ant 3.0 bumper bracket fastener case
status: runtime routing rules for visible bumper bracket screw/fastener fracture with unresolved root cause

## Symptoms

- Ant 3.0 bumper bracket fixed screw is reported broken.
- Robot label identifies `ANT-3.0.0-4G`, `SN: K17A14AN`, `MFG Date: 2026/05/12`.
- Local bracket photo shows the bumper/bracket fastening area, red witness-paint marks on multiple screws, and one visually abnormal fastening/boss area.

## Fault Tree

1. Confirm the actual failed object.
   - Screw shank fractured.
   - Threaded insert or standoff pulled out.
   - Bracket boss or aluminum plate cracked.
   - Fastener loosened or missing and was reported as broken.
2. Inspect impact and load path.
   - Look for bumper contact marks, bracket bending, surrounding deformation, task collision history, transport/drop history, and bumper-trigger records.
   - A single oblique photo does not prove collision or fatigue.
3. Inspect assembly process.
   - Check screw size, grade, thread engagement, washer stack, threadlocker, torque standard, torque record, and witness-paint movement.
   - Check whether the screw bottoms out before clamping the bracket.
4. Inspect design and batch risk.
   - Compare bracket edge distance, boss wall thickness, screw preload, expected bumper impact load, and vibration environment.
   - If the same fastening location fails on multiple Ant 3.0 units, treat it as design/process fleet risk.
5. Use logs as supporting context only.
   - Motion/task logs can support collision/impact timing.
   - Embedded/CAN/power logs are not primary evidence unless they show aligned bumper, emergency-stop, reset, or motion-event timing.

## Evidence Needed

- Close-up of failed screw, fracture surface, threaded insert, bracket boss, and removed failed part.
- Screw specification: size, grade, engagement length, washer, threadlocker, and torque standard.
- Assembly torque record and witness-paint before/after comparison.
- Collision, bumper-hit, emergency-stop, transport, or vibration history around the failure.
- CAD/drawing or bracket load path for the bumper bracket.
- Same-batch Ant 3.0 inspection result.
- Repair action and post-repair impact/vibration/operation retest.

## Logs And Files To Inspect

- Case body: `cases/needs-assets/ant-3-test/0126-Xzb9w0sh6iThYgk3kEOcfYxrnwg-2026-05-19-Ant-3.0.0-K17A14AN-保险杠支架固定螺丝断裂.md`.
- Robot label image: `assets/ant-3-test-pt-0126/retry-image-001-SS6FbABRzoZbU1xzHxscpgJ8nSe.png`.
- Bracket image: `assets/ant-3-test-pt-0126/retry-image-002-Q2cuby5Emo3qb2xWycrcTWh2nug.jpg`.
- Search terms: `K17A14AN`, `ANT-3.0.0-4G`, `保险杠支架`, `固定螺丝断裂`, `红漆标记`, `MFG Date: 2026/05/12`, `02:04:9F:C9:14:BD`, `torque`, `thread engagement`, `witness paint`, `bumper impact`.

## Likely Causes To Test

- Collision or bumper impact overload.
- Vibration or repeated low-speed contact causing clamp loss and fatigue.
- Over-torque, under-torque, wrong screw grade, too-short engagement, missing washer/threadlocker, or bottomed screw.
- Bracket boss/edge distance/load-path design margin insufficient.
- Same-batch assembly or process issue.

## Exclusion Checks

- Do not route to CAN, ALLCAN, boost, DM camera, or embedded reset unless logs show aligned electrical or software symptoms.
- Do not confirm collision from the bracket photo alone.
- Do not confirm over-torque from red paint or screw-head appearance alone.
- Do not treat a replacement screw as sufficient closure without checking adjacent screws, bracket deformation, and repeat operation.
- Do not close fleet risk until same-batch Ant 3.0 units or the same bracket location are inspected.

## Confirmed Examples

- None yet. `ant-3-test-pt-0126` is useful for the physical-structure triage path, but root cause remains unresolved because fracture close-up, torque/process evidence, collision history, repair action, and retest are missing.

## Unresolved Examples

- `ant-3-test-pt-0126`: visible text names `K17A14AN` and `保险杠支架固定螺丝断裂`; local images confirm robot identity and bracket fastening area. Missing fracture close-up, torque/process evidence, collision history, repair action, and retest prevent confirmed root cause.

## Specialist Routing

- `vision-media`: inspect bracket photos, fastener close-ups, witness-paint movement, deformation, and same-batch comparison photos.
- `robot-motion`: correlate with task collision, bumper trigger, emergency stop, transport, or impact history if logs exist.
- `embedded-software`: inspect event logs for timing context only; this is not primarily a firmware/CAN/power branch.
