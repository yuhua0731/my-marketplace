# S321 Loading Belt Scan Stop Position Overlap

source_set: `s321-pt-0137`
case_count: 1 S321 feeder / scan stop position boundary case
status: runtime routing rules for scan-success parcels stuck on loading belt because scan-stop and loading-stop positions overlap

## Symptoms

- Project/site: `S321-1`.
- At `13:14:12`, parcel `000158023904` is scanned and robot `K16B08SR` picks it away from the station.
- At `13:14:14`, parcel `000158096177` is scanned, robot `K16B22SR` reaches the station, but does not pick the parcel.
- The parcel remains on the loading section / last feeder segment.
- Source analysis says parcel `1778217254335-12` did not send `0x02` / `包裹过扫描段`.
- Resolution: configure `上车段停止位置 > 扫码停止位置` by 5 mm and retest.

## Fault Tree

1. Confirm scan success before diagnosing RFID/scanner.
   - Logs show `RFID-mqtt: receive RFID scan data, upc: 000158096177`.
   - Logs show `parcel receive scan barcode: 158096177`.
2. Confirm robot/station assignment is not the first fault.
   - Logs show `K16B22SR finish mission with result: {"success":true,"code":""}`.
   - The visible symptom is the parcel left on the feeder, not a simple robot arrival failure.
3. Inspect conveyor position thresholds.
   - The package state changes to scan-complete only when the parcel head touches or crosses the scan stop position.
   - If the loading-belt stop position equals the scan stop position, the package can be controlled to stop just short of the scan threshold.
4. Detect epsilon trap.
   - Log evidence at `2026-05-08 16:45:29` shows `package_to_waiting_distance: 0.000122`.
   - `vpoint_waiting_on_loading_belt_in_meter: 0.580000`.
   - `head_position_in_m: 0.579878`.
   - The parcel head is only 0.000122 m short, but still less than the scan-stop boundary, so the package cannot progress to trigger `0x02`.
5. Fix by separating thresholds.
   - Configure loading-belt stop position greater than scan stop position.
   - The source fix uses a 5 mm offset.

## Evidence Needed

- Conveyor configuration values for scan stop position and loading-belt stop position.
- Logs around scan event, `parcel receive scan barcode`, `0x02` / `包裹过扫描段`, package head position, and waiting/loading-belt target position.
- Robot mission result and station arrival/pick status for the same parcel ID.
- Video or camera frame showing the parcel stuck on the last feeder/loading segment.
- Post-change retest proving a 5 mm offset lets the parcel cross the scan threshold and proceed to pickup.

## Logs And Files To Inspect

- Case body: `cases/accepted/s321/0137-XdVgwWakWiT6hokrmH6c5sJfnfP-2026-05-08-S321-1-扫码成功后-包裹停在供包机最后一段.md`.
- Screenshot/log image: `assets/s321-pt-0137/retry-image-001-G9xMbTBFeoScV1xLocTcgmw5nyg.png`.
  - Shows `2026-05-08T13:14:14.358000+0800`, `RFID-mqtt: receive RFID scan data, upc: 000158096177`.
  - Shows `S321-1-SITE-1-CONVEYOR: 1778217254335-12 parcel receive scan barcode: 158096177`.
  - Shows `K16B22SR finish mission with result: {"success":true,"code":""}`.
  - Later shows duplicate scan warning because the parcel already has barcode `158096177`.
- Screenshot/log crop: `assets/s321-pt-0137/retry-image-002-BQWvbLOaPogd5BxD7fccS7GwnFe.jpg`.
  - Shows `manualplace_load_2belt_controller.c:95 package_to_waiting_distance: 0.000122`.
  - Shows `vpoint_waiting_on_loading_belt_in_meter: 0.580000`.
  - Shows `head_position_in_m: 0.579878`.
- Video: `assets/s321-pt-0137/retry-source-F1xzb03UIog6dJxZYnPc22RNngh.mp4`.
  - QuickTime metadata: 2064 x 1160, duration about 13.47 s, size 21687980 bytes.
  - QuickLook representative frame shows the feeder/station area at `2026-05-08 13:14:19`.
- Search terms: `s321-pt-0137`, `S321-1`, `000158096177`, `1778217254335-12`, `0x02`, `包裹过扫描段`, `package_to_waiting_distance`, `0.000122`, `vpoint_waiting_on_loading_belt_in_meter`, `0.580000`, `head_position_in_m`, `0.579878`, `上车段停止位置`, `扫码停止位置`, `K16B22SR`.

## Likely Causes

- Loading-belt stop position and scan stop position are configured equal or too close.
- The conveyor controller stops the parcel with the head position just below the scan-complete threshold.
- The scan-complete state depends on crossing the threshold, so the parcel never emits `0x02 包裹过扫描段`.
- The robot mission can complete or reach station while the parcel state machine still thinks the parcel has not crossed the scan segment.

## Exclusion Checks

- Do not diagnose RFID/scanner failure when logs show `RFID-mqtt` receive and `parcel receive scan barcode`.
- Do not diagnose robot pickup failure first when the parcel never emits the scan-segment pass event.
- Do not treat a 0.000122 m gap as zero; threshold comparisons can be strict and keep the state machine blocked.
- Do not merge with S321 RFID low-read-rate cases; this case has scan success but position threshold failure.
- Do not claim full closure without post-config retest evidence after the 5 mm offset.

## Confirmed Examples

- `s321-pt-0137`: parcel `000158096177` / `1778217254335-12` scanned successfully, but because loading-belt stop and scan stop positions were effectively identical, the head stopped at `0.579878 m` while the waiting/scan boundary was `0.580000 m`; `0x02 包裹过扫描段` was not emitted. Source fix is to set loading-belt stop position 5 mm greater than scan stop position.

## Unresolved Examples

- `s321-pt-0137`: missing raw full controller log, exact before/after config dump, and post-fix retest artifacts. The visible log and source analysis are enough for a high-value diagnostic rule, but final verification evidence is incomplete.

## Specialist Routing

- Start with `embedded-software` for conveyor controller state machine, threshold comparison, and `0x02` event emission.
- Add `scheduler-traffic` for parcel/mission state alignment between scan, conveyor, and robot pickup.
- Add `vision-media` for confirming the parcel is physically stuck on the loading/feeder segment.
