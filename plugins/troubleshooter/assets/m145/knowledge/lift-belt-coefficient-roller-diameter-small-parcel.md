# Lift Belt Coefficient And Roller Diameter Mismatch

## Symptoms

- OmniSort / M145 has abnormal small-parcel feeding or throwing logic.
- The lift-module belt stops or finishes early while feeding a minimum-size parcel.
- Small parcels may fail to reach the robot, or parcel length measurement becomes biased.
- The lift-module belt and feeder belt receive the same speed command, but their actual belt speeds differ.

## Fault Tree

1. Confirm the visible feeding symptom with a minimum-size parcel.
   - Check whether the parcel leaves the lift module too late, stops before reaching the robot, or is measured shorter/longer than expected.
   - Preserve the command speed, test mode, parcel size, and affected library/site.
2. Measure actual belt speed instead of trusting the configured coefficient.
   - Use the same speed command for the lift-module belt and feeder belt.
   - Measure both belts with a tachometer or equivalent tool and compare in the same unit.
   - In `m145-pt-0166`, the lift-module reading is `35.525 m/min` (`0.592 m/s`) and the feeder reading is `48.795 m/min` (`0.813 m/s`).
3. Check whether the difference can be explained by reducer ratio.
   - Source chat says the lift-module reducer ratio is about `0.7` and the feeder ratio is about `0.71`; another screenshot says `14:20` vs `20:28`.
   - That small ratio difference does not explain a roughly 25% actual belt-speed gap.
4. Check roller diameter and mechanical coefficient.
   - Source chat says the lift-module roller diameter changed from `φ38` before M129 to `φ30` after M131.
   - Diameter ratio `30/38 = 0.789` is close to the measured speed ratio `35.525/48.795 = 0.728`.
   - If the lift-module coefficient stayed the same as the feeder coefficient after the roller diameter changed, commanded speed and actual belt speed diverge.
5. Validate correction at the production-library level.
   - Increase or recalibrate the lift-module belt coefficient according to mechanical parameters.
   - Apply the coefficient to all production libraries using this roller configuration.
   - Re-test minimum-size parcels and length measurement after the coefficient update.

## Evidence Needed

- Raw before/after mechanical parameter or coefficient configuration.
- Controller or scheduler logs showing the commanded speed used for both belts.
- Tachometer measurement method, calibration, contact point, and repeated readings.
- Post-fix video/log proving minimum-size parcels reach the robot and length measurement is normal.
- List of production libraries that share the `φ30` lift-module roller configuration.

## Logs And Files To Inspect

- Mechanical parameter/config files for lift-module belt coefficient and feeder belt coefficient.
- Versioned design/BOM or change records for lift-module roller diameter.
- Feeding task logs around minimum-size parcels, length measurement, and belt command speed.
- Search terms: `M145`, `最小包裹`, `供包逻辑异常`, `提升模组`, `供包机`, `皮带系数`, `滚筒直径`, `φ38`, `φ30`, `35.525`, `48.795`, `0.6m/s`, `0.8m/s`, `包裹测长偏差`, `小包裹到不了机器人`.

## Likely Causes

- Lift-module roller diameter changed, but the lift-module belt coefficient was not recalibrated.
- Feeder and lift-module belt coefficients were kept identical even though their roller diameters differ.
- Production libraries inherited stale mechanical parameters after hardware changes.

## Exclusion Checks

- Do not blame feeder logic or scheduler sequencing before verifying actual belt speed under the same command.
- Do not treat reducer ratio as the root cause when the ratio difference is close to 1:1 and cannot explain the measured speed gap.
- Do not assume the coefficient is correct because the configuration file uses the same value for lift and feeder belts.
- Do not call the fix complete until minimum-size parcel delivery and length measurement are re-tested after coefficient update.
- If only screenshots are available, record missing raw config/log/post-fix evidence.

## Confirmed Examples

- `m145-pt-0166`: source says M145 minimum-parcel feeding ends early. Under the same speed command, tachometer images show `35.525 m/min` on the lift-module belt and `48.795 m/min` on the feeder belt. Source analysis says the lift-module belt is about 25% slower; reducer ratios are close, but the lift-module roller changed from `φ38` to `φ30`. Resolution is to increase the lift-module belt coefficient and update all production libraries using the affected mechanical parameters.

## Unresolved Examples

- `m145-pt-0166`: raw before/after coefficient config, command logs, tachometer calibration/repeated readings, and post-fix parcel-delivery proof are not present in local assets.

## Specialist Routing

- `vision-media`: inspect parcel movement video, tachometer screenshots, and before/after feeding validation.
- `embedded-software`: inspect belt command speed, parameter loading, and runtime coefficient use.
- `scheduler-traffic`: inspect feeding sequence only after mechanical speed mismatch is checked.
