# ALLCANDM Dense Center Offset Causing Shuttle Home Fail

## Symptoms

- OmniSort / MiniSort Pro in self-test mode reports `SHUTTLE_HOME_FAIL` or `回原点时编码器异常`.
- The alarm can appear during startup/homing at a feeder/conveyor position rather than during normal track travel.
- The affected robot may be reported as a specific shuttle, for example `M004R`, with normal voltage.

## Fault Tree

1. Start from the alarm context, not only the alarm label.
   - `回原点时编码器异常` can be a downstream symptom of failed DM/barcode decoding at a special feeder position.
   - If the robot is at a feeder position with lower-than-normal code placement, inspect camera decoding geometry before replacing encoder or drive hardware.
2. Compare feeder-position code height with normal track code height.
   - Feeder/conveyor positions can place barcode strips lower than the regular track.
   - If the decode window center line does not cover the bright/valid band of the code, the robot can fail homing/localization.
3. Read ALLCANDM dense-center-offset config.
   - Use `protocol_config.py --key AllCANDM/dense_center_offset`.
   - If the value is `0` and the feeder-position code is lower than normal, adjust the offset and retest.
4. Verify by repeated startup/homing at the same station.
   - The fix is not proven until the robot can home at the feeder position without `SHUTTLE_HOME_FAIL` / encoder abnormal alarm.

## Evidence Needed

- UI alarm screenshot with robot ID, alarm text, voltage, and exact time.
- Physical photo showing robot position relative to feeder/conveyor code strips.
- Camera decode image with upper/lower bright rows and center line.
- Config readout for `AllCANDM/dense_center_offset` before and after adjustment.
- Retest evidence after adjusting offset.
- Raw robot/NXP logs if the alarm continues after config adjustment.

## Logs And Files To Inspect

- Search terms: `SHUTTLE_HOME_FAIL`, `回原点时编码器异常`, `M004R`, `AllCANDM/dense_center_offset`, `dense_center_offset`, `protocol_config.py`, `Upper row`, `Lower row`, `中心线`, `供包机位置`, `横条解码中心线偏移`, `SCAN OUT OF AREA`.
- Inspect camera/debug images before interpreting the problem as a true encoder hardware failure.

## Likely Causes

- `AllCANDM/dense_center_offset` not adapted to feeder-position barcode height is likely when a robot at feeder position fails homing/encoding and the config value is `0`.
- Local barcode placement/height difference is likely when the same robot works on normal track but fails at feeder/conveyor position.
- True encoder or drive failure is less likely when the source evidence points to camera decode geometry and the configured offset is default.

## Exclusion Checks

- If `AllCANDM/dense_center_offset` is already set correctly and decode images show the code centered, inspect encoder, motor, drive, CAN, and homing state-machine logs.
- If the alarm happens away from feeder/conveyor code strips, do not apply this rule solely from the alarm text.
- If voltage is low or power is unstable, resolve power before interpreting decode behavior.
- If `SCAN OUT OF AREA` or barcode read errors appear in the event list, include the DM decode branch even when the popup says encoder abnormal.

## Confirmed Examples

- `m004-pt-0071`: MiniSort Pro self-test startup at `2026-05-06 17:05:54`; `M004R` alarmed at `2026-05-06 17:07:03`.
  - UI screenshot shows `SHUTTLE_HOME_FAIL` for `M004R`.
  - UI screenshot also shows `回原点时编码器异常`, `M004R`, voltage `54.74V`, time `2026-05-06 17:07:03`.
  - Physical photo shows the robot at the feeder/conveyor area with dense side barcode strips; source states feeder-position codes are lower than normal track codes.
  - Decode debug image shows `Upper: row 203 (value: 183.6)`, `Lower: row 289 (value: 152.5)`, and a marked center line.
  - Config screenshot shows command `python3 protocol_config.py --key AllCANDM/dense_center_offset`, key `AllCANDM/dense_center_offset`, value `0`.
  - Source resolution: adjust camera horizontal/dense decode center-line offset, then retest.

## Unresolved Examples

- `m004-pt-0071`: raw NXP/robot logs and post-adjustment retest logs are not local.
- `m004-pt-0071`: the final adjusted offset value is not visible in local assets.

## Specialist Routing

- `robot-motion`: DM/barcode localization, homing at feeder position, camera center-line geometry.
- `vision-media`: physical robot/code-strip position and decode debug images.
- `embedded-software`: config read/write via `protocol_config.py`, homing state-machine, alarm translation.
- `can-bus`: only if encoder/CAN evidence remains after decode-offset checks.
