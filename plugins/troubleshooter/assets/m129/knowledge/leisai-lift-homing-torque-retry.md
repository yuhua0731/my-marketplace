# Leisai Lift Homing Torque Retry Failure

## Symptoms

- OmniSort / M129 lift module keeps moving downward during homing until it reaches the physical limit.
- After excessive torque is detected, the lift reverses upward to search for origin, but can stall halfway.
- The issue is tied to the No.1 lift module and Leisai servo/motor control path.

## Fault Tree

1. Start from homing sequence and torque evidence.
   - If logs show repeated homing torque checks or retry limits, prioritize homing firmware/control logic before scheduler task logic.
   - If no torque or homing logs exist, require raw motor/controller logs before confirming this pattern.
2. Check Leisai drive firmware and model.
   - Record drive model, firmware version, communication port, and whether the same version is used on a known-good project.
   - In this case, Motion Studio showed `iSV2-CAN8075`, firmware `1.06`, `IN:6, OUT:3`.
3. Inspect CAN/controlword sequence around homing.
   - Use raw candump when available; screenshot-only CAN evidence is not enough for full decoding.
   - Look for repeated motor command/status frames before and after the downward travel, reverse, and stall.
4. Separate drive firmware bug from mechanical obstruction.
   - If the lift hits the physical limit before reversing and the drive has no persistent alarm, firmware/homing logic remains high-priority.
   - If mechanical jam, sensor damage, or drive alarm is visible, inspect hardware before firmware replacement.
5. Verify remediation with the same homing test.
   - Updating Leisai firmware or replacing the drive with a known-good M123-equivalent software version must be followed by repeated homing attempts without physical-limit impact or mid-travel stall.

## Evidence Needed

- Raw NXP/embedded logs around homing start, torque detection, reverse, retry count, and stall.
- Raw candump or pcap around the fault, not only screenshots.
- Leisai drive model, firmware version, parameter export, and comparison with known-good project configuration.
- Video or photo sequence of the lift moving down, touching physical limit, reversing, and stopping.
- Retest evidence after firmware update or drive replacement.

## Logs And Files To Inspect

- Search terms: `homing`, `home`, `origin`, `torque`, `exception_torque`, `max_homing_retry_count`, `general_functions.c`, `can0`, `28F`, `18F`, `40F`, `60F`, `58F`, `controlword`, `quick stop`, `iSV2-CAN8075`, `Leisai`, `雷赛`, `回原点`, `物理限位`.
- For screenshots, preserve visible timestamps and raw bytes exactly, but mark decoding as provisional unless raw candump is available.

## Likely Causes

- Leisai drive firmware/homing bug is likely when the lift repeatedly moves into the physical limit during homing, torque detection appears in logs, and the source resolution is to update/fix Leisai firmware or replace the drive with a known-good software version.
- Mechanical hard stop impact can be a symptom of wrong homing behavior, not necessarily the root cause.
- A clean Motion Studio alarm page does not exclude homing firmware/control bugs, because the drive may not retain a persistent alarm after the event.

## Exclusion Checks

- If a drive alarm other than `Err000` is active, inspect the alarm reason before applying this rule.
- If torque/current evidence is absent, do not infer this pattern from "回原点失败" alone.
- If the lift fails before downward travel or never reaches the physical limit, inspect origin sensor, wiring, CAN communication, and motion enable sequence.
- If the same drive firmware works after parameter export/import but without firmware replacement, check parameter mismatch before concluding a firmware bug.

## Confirmed Examples

- `m129-pt-0055`: M129 No.1 lift module homing kept moving downward until hitting the physical limit; after excessive torque triggered reverse-up origin search, it could stall halfway.
  - Source resolution: ask Leisai to fix the bug and update M129, or replace the M129 Leisai motor with one using the same software version as M123.
  - Log screenshot at `2026-03-19T10:50:31.530721+0800` repeatedly shows `ERROR general_functions.c:773 torque = -290, exception_torque = 1000, max_homing_retry_count = 2`.
  - CAN screenshot around `2026-03-19 10:47:22` shows repeated `can0 28F [4] 37 07 C0 FE` with related `18F` and `48F` frames.
  - CAN/control screenshot around `2026-03-19 10:46:50` shows repeated `can0 40F [2] 0B 00` and later `60F/58F` frames annotated as command/status values including `0B`, `00`, `80`, `06`, `07`, and `0F`.
  - Motion Studio screenshot shows drive model `iSV2-CAN8075`, firmware `1.06`, `IN:6, OUT:3`.
  - Motion Studio alarm page shows `Err000 / 没有报警`, so no persistent drive alarm is visible in that screenshot.
  - Chat screenshot gives the stop-location clue `1F-b-80-7-F-1F`.

## Unresolved Examples

- `m129-pt-0055`: Raw candump, raw embedded logs, drive parameter export, and post-fix retest logs are not local; available CAN/log evidence is screenshot-based.
- `m129-pt-0055`: The final fixed Leisai firmware version is not stated in the local case body.

## Specialist Routing

- `can-bus`: CANopen/controlword/statusword sequence, raw candump/pcap, motor communication timing.
- `embedded-software`: homing state machine, torque threshold, retry count, firmware branch/version.
- `vision-media`: physical lift movement, limit impact, mid-travel stall, Motion Studio screenshots.
- `scheduler-traffic`: only if homing is triggered by a higher-level task sequence or recovery workflow.
