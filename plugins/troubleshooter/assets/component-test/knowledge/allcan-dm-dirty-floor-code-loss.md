# Component Test ALLCAN-DM Dirty Floor-Code Loss Knowledge

source_set: `component-test-pt-0084`, `component-test-pt-0085`
case_count: 2 Ant 3.0 ALLCAN-DM camera stops with NXP logs, scan-rate CSV/screenshots, physical stop photos, floor-code photo, and follow-up evidence
status: runtime routing rules for ALLCAN-DM barcode read gaps causing DM code loss

## Symptoms

- Ant 3.0 stops during ALLCAN-DM navigation with `DM code lost`.
- Stop point may be reported near a neighboring code, not necessarily the worst scanned code.
- Example `component-test-pt-0084`: reported stop code `100010GG111000`, previous stop code `100010GG110000`, while scan statistics identified `(100010, 114000)` as the high-loss code.
- NXP log reports `DM LOST, distance without barcode update: 3018.990582 mm`, then command `SMOOTH-2026-04-14T20:20:58.072193-7` fails with `[WARNING]1202#DIFF_DRIVE_ERROR#MOVER_MOTOR#DM code lost.`
- Example `component-test-pt-0085`: command `SMOOTH-2026-04-17T17:44:39.255647-3` failed with the same `DM code lost` reason after a long route-segment read gap, while stop photos did not show obvious vehicle skew.

## Fault Tree

1. Confirm whether the failure is a localization/no-read event before analyzing motor or CAN causes.
   - In `component-test-pt-0084`, the NXP failure reason is `DIFF_DRIVE_ERROR#MOVER_MOTOR#DM code lost`.
   - The failure occurs after 3018.990582 mm without barcode update, while the robot was moving about `2001.108643 mm/s`.
2. Compare scan-rate statistics by route direction.
   - Route columns alternate direction. Do not treat every zero as abnormal before checking the active direction.
   - `(100010, 114000)` had only 3 hits across 24 values, with 21 zeros. Nearby rows such as `(100010, 111000)` and `(100010, 110000)` had 19 and 18 total hits.
   - For `component-test-pt-0085`, the failing command column `SMOOTH-2026-04-17T17:44:39.255647-3` covers `(99000,104000)->(99000,138000)` and shows normal reads through `(99000,112000)`, then zeros from `(99000,113000)` through `(99000,138000)`. This points to a route-segment read-gap branch even when the final stop pose looks centered.
3. Inspect the exact floor-code surface.
   - `100010GG114000` photo shows dirt/smear at the lower QR area and a worn label surface.
   - This supports a local readability branch; it does not by itself prove camera hardware failure.
   - In `component-test-pt-0085`, stop photos show the robot roughly centered over/near a floor code, so visible pose does not explain the loss; inspect the upstream route segment instead of only the final stop photo.
4. Check whether reads resume after the DM-lost threshold.
   - In this case, barcode reads resume immediately after the error, around `100014.100,112948.200` and then down toward `100010,111xxx`.
   - Treat this as intermittent route-segment readability loss, not complete camera outage.
5. Verify repair by repeat scan statistics and NXP log.
   - After reprinting/replacing low-success floor codes including `(100010, 114000)`, the follow-up screenshot shows the row mostly restored to `1` or `2` hits.
   - Follow-up NXP log from 2026-04-17 09:04-09:34 contains successful commands and no local `DM LOST` / `DM code lost` match in the checked window.
6. Keep recurrence separate.
   - The source links a later 2026-04-17T17:44 DM-lost stop as a separate case. Do not claim the whole route is fixed from the 30-minute follow-up alone.

## Evidence Needed

- NXP log around the stop timestamp with `DM LOST`, barcode updates, command label, and failure reason.
- Scan-rate CSV or screenshot with route columns and per-code hit counts.
- Clear photo of the exact suspected floor code, not only the displayed stop code.
- Stop-position photos to check whether the robot body is visibly skewed, but do not use them alone to exclude floor-code/read-gap causes.
- Follow-up scan-rate screenshot or CSV after cleaning/reprint/replacement.
- Follow-up NXP log covering repeated passes through the same segment.
- CAN pcap/candump only when motor/CAN branch remains plausible after localization evidence.

## Logs And Files To Inspect

- `assets/component-test-pt-0084/006-source-Iyl7bPdz4ouqLMxOBCTcVVeynih.log`
- `assets/component-test-pt-0084/008-source-EPvmbTlC2odFFDxkjxDcThKknub.csv`
- `assets/component-test-pt-0084/004-image-b6f3084b00ac.jpg`
- `assets/component-test-pt-0084/005-image-40a6c0545a67.png`
- `assets/component-test-pt-0084/009-source-DLYYbGofKoyhryxaUkAcvA5Pnie.log`
- `assets/component-test-pt-0084/007-source-NRTebBrJioNMvsxFAGgcvMQqnZe.pcap`
- `assets/component-test-pt-0085/004-source-Be24bRS2GoOZwpxPZYic5ETynde.log`
- `assets/component-test-pt-0085/005-source-FVYNbmU5Go9JYmxi7uYc8mFQn5b.csv`
- `assets/component-test-pt-0085/001-image-5ab48c891ff6.jpg`
- `assets/component-test-pt-0085/002-image-ffce584bfc49.jpg`
- `assets/component-test-pt-0085/003-image-a3af1f997cb6.png`

## Likely Causes

- Dirty, worn, scratched, or poorly pasted floor code causing intermittent ALLCAN-DM barcode no-read.
- Route-segment-specific scan loss that accumulates enough distance without barcode update to trigger DM lost.
- Camera/lighting/pose sensitivity interacting with marginal floor-code quality.
- Less likely but still checkable: motor/CAN behavior after the localization failure, especially if pcap can be decoded and shows abnormal state transitions.

## Exclusion Checks

- If the failing code row has normal hit counts in the active direction, do not blame the floor code only from a dirty-looking photo.
- If multiple adjacent codes drop together after reprint, inspect camera exposure, mounting angle, lens cleanliness, lighting, or route geometry.
- If the final stop photo shows a centered robot, do not exclude DM code loss; compare the last valid barcode update with the failed command path.
- If NXP shows no `DM LOST` / `DM code lost`, route to the actual failure reason instead.
- If a pcap is present but the local decoder shows `UNSUPPORTED`, mark CAN evidence blocked; do not use it to confirm or exclude CAN.
- If repair is validated only by a short follow-up window, keep long-run recurrence open.

## Confirmed Examples

- `component-test-pt-0084`: Ant 3.0 stopped at 2026-04-14T20:21. NXP shows `DM LOST, distance without barcode update: 3018.990582 mm`; command `SMOOTH-2026-04-14T20:20:58.072193-7` failed with `DM code lost`. CSV shows `(100010, 114000)` had only 3 hits across 24 values. Photo of `100010GG114000` shows dirt on the QR area. After reprinting low-success codes, follow-up screenshot shows improved `(100010, 114000)` reads and checked follow-up NXP log shows no DM-lost failure in the sampled 30-minute window.
- `component-test-pt-0085`: Ant 3.0 stopped at 2026-04-17T17:44. NXP log creates command set `A4882-SMOOTH-2026-04-17T17:44:39.255647`; command `-3` is a MOVE from `(99000,104000)` toward `(99000,138000)`. At `2026-04-17T09:44:52Z` the log reports `DM LOST, distance without barcode update: 3019.943833 mm`; at `2026-04-17T09:44:54Z` `SMOOTH-2026-04-17T17:44:39.255647-3` fails with `[WARNING]1202#DIFF_DRIVE_ERROR#MOVER_MOTOR#DM code lost`, and commands `-4` through `-15` are cancelled. The CSV/screenshot shows the failing route column reads through `(99000,112000)` and then zeros from `(99000,113000)` through `(99000,138000)`. Stop-position photos show the robot body roughly centered, supporting the source note that the body did not visibly run off course, but not excluding a route-segment barcode read gap.

## Unresolved Examples

- `component-test-pt-0084`: CAN pcap `007-source-NRTebBrJioNMvsxFAGgcvMQqnZe.pcap` was downloaded but local `tcpdump` rendered frames as `UNSUPPORTED`; CAN state transitions remain unreviewed.
- `component-test-pt-0084`: later 2026-04-17T17:44 DM-lost stop is linked as a separate case, so the 2026-04-17 09:30 follow-up does not prove full-route permanent recovery.
- `component-test-pt-0085`: no local photo of the exact upstream floor codes `(99000,113000)` through `(99000,138000)` is present, and no final fix/retest evidence is present beyond the source note `暂无发现异常停机`.

## Specialist Routing

- `robot-motion`: DM read/no-read sequence, distance without barcode update, speed and route segment.
- `vision-media`: floor-code dirt/scratch/paste quality and follow-up screenshot.
- `embedded-software`: NXP `diff_drive`, command status, state-machine transition, and barcode updates.
- `can-bus`: only after CAN pcap/candump can be decoded or when motor/CAN branch remains plausible.
