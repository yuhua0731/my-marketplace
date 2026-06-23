# Mantis Climb Motor Brake Holding Margin

## Symptoms

- Mantis 2.6.0 spider/slide descends slowly after emergency stop or power-off.
- Left/right sides are not level under load.
- Manual pressing after power-off shows the climb motor brake does not fully lock.
- The symptom is worse near high load, for example `35kg`, and one motor side can be more obvious.

## Fault Tree

1. Confirm the issue is brake holding, not software hold.
   - If the unit descends when powered off and manually pressed, inspect brake holding torque and backdrive first.
2. Quantify load margin.
   - Test by load steps and both sides separately.
   - Calculate required brake torque from load, reducer ratio, drum/gear geometry, and side-to-side distribution.
   - A load rate near `96%` indicates insufficient system safety margin even if nominal brake torque appears close.
3. Inspect the worse side.
   - Check brake air gap, brake coil voltage, release/hold timing, wiring, reducer backdrive, mounting, and mechanical load sharing.
4. Compare motor families.
   - Preserve exact 1000W motor vendor, brake torque, rated torque, interface compatibility, and test result.
   - Treat a 1200W upgrade as a mitigation branch until same-condition retest proves it.

## Evidence Needed

- Load-step test table with side, load, displacement, and pass/fail.
- Video with calibrated displacement or ruler/scale.
- Brake holding torque test or motor datasheet with brake torque.
- Reducer ratio, load geometry, and safety-factor calculation.
- Brake air-gap, coil voltage, wiring, and release/hold timing measurements.
- Same-condition retest after 1200W or brake/motor replacement.

## Logs And Files To Inspect

- `cases/accepted/mantis-test/0120-Vk8LwVHXhixTcak12lucYCrhnee-2026-05-27-Mantis-2.6.0-爬升电机抱闸无法完全抱死问题.md`
- `assets/mantis-test-pt-0120/retry-source-LkwLbjg7MothESxuMBBcoo8OnYf.mp4`
- `assets/mantis-test-pt-0120/retry-source-I4v4bkYnDoRS7QxxE60c2u63n8f.pdf`
- `assets/mantis-test-pt-0120/retry-source-MdEsbmTEqobWLmxGy9Hc5kS2nRe.pdf`
- Search terms: `爬升电机抱闸`, `无法完全抱死`, `急停`, `下坠`, `35kg`, `2号电机`, `减速器速比`, `抱闸力矩`, `负载率 96%`, `1200瓦`.

## Likely Causes

- 1000W motor/brake/reducer combination has insufficient safety margin for Mantis 2.6 high-load brake holding.
- One side brake or reducer has worse holding due to air-gap, wiring, coil voltage, brake tolerance, or load-sharing imbalance.
- Mechanical geometry or reducer backdrive raises required holding torque beyond available brake margin.

## Exclusion Checks

- Do not diagnose CAN, servo control, or scheduler first when power-off manual pressing reproduces descent.
- Do not compare brake torque numbers without reducer ratio and load geometry.
- Do not assume both sides are equivalent if motor 2 descends more obviously.
- Do not mark a 1200W replacement strategy verified without same-load emergency-stop and power-off retest.

## Confirmed Examples

- `mantis-test-pt-0120`: under `35kg`, Mantis 2.6.0 was not level and descended slowly after emergency stop; motor 2 was more obvious. Power-off manual pressing indicated the climb motor brake did not fully lock, with reducer ratio `10`. The load table records descent on Mantis 2.6 with `1000W 伟创` at `35kg`, but not at lower loads; CS006 1# and CS006 3# show no descent in the table. Follow-up states the 1000W motor load rate reached `96%`, safety margin was insufficient, and 1200W higher-torque compatible motors were being procured for trial.

## Unresolved Examples

- `mantis-test-pt-0120`: no calibrated displacement/force measurement, local `1000W 伟创` brake-torque PDF, brake air-gap/coil-voltage data, reducer backdrive calculation, or 1200W retest result is local.

## Specialist Routing

- `mantis-handling`: brake, reducer, climb mechanism, load sharing, side-to-side levelness.
- `vision-media`: video inspection and calibrated displacement evidence.
- `embedded-software`: estop state and motor/brake command timing only if logs are available.
- `can-bus`: only if drive/CAN brake or motor status frames are available.
