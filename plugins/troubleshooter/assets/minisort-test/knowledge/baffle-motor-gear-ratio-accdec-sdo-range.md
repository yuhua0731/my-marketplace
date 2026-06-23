# Baffle Motor Gear-Ratio Acc/Dec SDO Range Error

## Symptoms

- Mini drag-chain baffle robot intermittently fails to lower the baffle during parcel throwing.
- Example symptom: at `09:52:43`, robot `D004` had a roughly `5%` probability that the baffle did not descend during throw-off.
- The failure can appear mechanical at first, but the stronger evidence is motor parameter write failure during acceleration/deceleration configuration.

## Fault Tree

- Confirmed branch: acceleration/deceleration SDO writes exceed the motor object range.
  - Log screenshot shows `conopen_stack: CO_SDOClientDownload error: -10`.
  - The same screenshot shows object `index 6083 sub_index 0 node_id 3 abort code: 1012531699`.
  - It also shows `index 6084 sub_index 0 node_id 3 abort code: 1012531699`.
  - Decimal `1012531699` corresponds to CANopen abort `0x06090031`, parameter value too high.
- Confirmed branch: wrong motor parameter template is used for the baffle motor.
  - Source analysis says the baffle motor reduction ratio is `1:18`.
  - Acceleration/deceleration was configured according to the throw/parabolic motor `1:1` parameter set.
  - This made the acceleration/deceleration subdivision exceed the motor's maximum limit.
- Likely branch: failed parameter writes leave the baffle motor with stale/default motion limits, so the baffle intermittently fails to descend during the throw sequence.
- Blocked branch: exact command-to-motion timeline.
  - No raw CAN dump, full NXP log, motor state sequence, or full video frame review is available locally.

## Evidence Needed

- Raw CANopen SDO log around object `0x6083` and `0x6084` writes, including requested values and motor accepted limits.
- Motor reduction ratio and configured acceleration/deceleration values before and after the fix.
- Full baffle command lifecycle: throw command, baffle-down command, motor enable/state, target reached, timeout or no-motion result.
- Video frames covering the exact failure moment, not only a representative thumbnail.
- Post-fix retest logs showing `0x6083`/`0x6084` writes succeed and 50+ parcels pass without recurrence.

## Logs And Files To Inspect

- `cases/accepted/minisort-test/0100-LJn6wuWIeiRW0pkTjiucUaAUn2b-2026-04-15-Mini拖链档板机器人-抛货时档板不下降问题.md`: source body.
- `assets/minisort-test-pt-0100/001-image-95dd88cdbfb5.png`: robot version table, including `D004`, RF/network `02049F31A1C8`, serial `SRW400 2.0.0`, `stm-commit 514a24`, `stm-tag 2.0.8`.
- `assets/minisort-test-pt-0100/002-image-fec036229550.png`: log snippet at `2026-04-15T02:47:49Z`, `UPTIME:65607`, `CO_SDOClientDownload error: -10`, `index 6083`, `index 6084`, `node_id 3`, `abort code: 1012531699`.
- `assets/minisort-test-pt-0100/003-source-P8Zeb0TDCo468fxqLuectzLinWf.mp4`: 16.276s H.264/AAC video; QuickLook representative frame shows monitor time `2026-04-15 09:52:49` and the Mini robot lane, but full frame extraction was unavailable locally.
- Search terms: `挡板不下降`, `抛货`, `D004`, `CO_SDOClientDownload error`, `6083`, `6084`, `0x06090031`, `1012531699`, `node_id 3`, `减速比`, `1:18`, `1:1`, `加减速`.

## Likely Causes

- Baffle motor uses a `1:18` reduction ratio but receives acceleration/deceleration parameters intended for a `1:1` throw/parabolic motor.
- CANopen objects `0x6083` and `0x6084` reject out-of-range values, so the motor does not receive the intended motion profile.
- Intermittent baffle non-descent occurs when the throw sequence depends on a baffle-down movement configured with invalid or stale acceleration/deceleration limits.

## Exclusion Checks

- Do not replace the baffle motor until `0x6083`/`0x6084` parameter writes and accepted ranges are checked.
- Do not classify as pure mechanical jam unless video or motor current/torque evidence shows obstruction after valid parameters are written.
- Do not blame firmware version solely from the version table; D004's version is context evidence, not root-cause proof.
- Exclude CAN transport only if other SDO writes succeed and the abort is specifically `0x06090031`.
- Exclude this pattern if the abort code is heartbeat loss, timeout, or communication reset instead of value range violation.

## Confirmed Examples

- `minisort-test-pt-0100`: D004 baffle failed to lower during throw-off with around `5%` probability. Setting baffle motor acceleration/deceleration produced CANopen SDO errors on `6083` and `6084`, abort `1012531699` / `0x06090031`. Source analysis says the baffle motor ratio is `1:18` but was configured with `1:1` throw-motor parameters; changing baffle motor acceleration/deceleration configuration resolved the issue, with 50+ parcels tested without recurrence.

## Unresolved Examples

- `minisort-test-pt-0100`: raw CAN dump, exact before/after parameter values, full video failure sequence, and long-run recurrence beyond the first 50+ parcels are not present.

## Specialist Routing

- Start with `can-bus` for CANopen SDO objects `0x6083`/`0x6084`, abort decoding, and node `3`.
- Add `embedded-software` for parameter template selection, motor config write sequence, and state-machine handling after SDO failure.
- Add handling specialist for baffle mechanical movement only after parameter writes are valid.
- Add `vision-media` for video proof of baffle state and throw timing.
