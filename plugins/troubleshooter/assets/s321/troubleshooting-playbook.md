# S321 Troubleshooting Playbook

Use this as the human-readable entrypoint before specialist routing.

## Global Process

1. Record exact symptom, timestamp, robot ID, station/location, task/container ID, and available filenames.
2. Classify the case by observed symptom, not by incidental WS/robot/location words.
3. Load the matching knowledge file and traverse the highest-value fault branch first.
4. Mark every branch as `confirmed`, `likely`, `excluded`, or `blocked`.
5. Treat unavailable videos, images, logs, and chat records as missing assets, not analyzed evidence.
6. Stop only at confirmed root cause, sufficient operational conclusion, or excluded branch.

## Route Order

- Reboot, shutdown, charging, low voltage: embedded-software first, then can-bus/scheduler/network.
- Shutdown blocked after robot lock/manual lock: scheduler-traffic first, then embedded state-machine only if logs show command/state failure.
- DM code loss, deviation, angle, collision precursor: robot-motion first, then embedded/can-bus/media.
- Disconnect, AP, MQTT, Kafka, RVS, site-wide service symptoms: network-infra first.
- Lift, tote, fork, arm, PT/PD, quick stop: handling specialist plus embedded/can-bus/media.
- Mechanical scrape, bracket contact, drag-chain sag, rail interference: vision-media first, then robot-motion/hardware evidence; embedded only if motion logs implicate control behavior.
- Task assignment, locks, no-action, deadlock/interlock: scheduler-traffic first.
- Robot ALLCAN-LED or body state lights stuck on initialization color: embedded-software first, then can-bus/media if state-frame or visual evidence exists.
- WLED/HLED/light strip, workstation sensor/display/operator station: workstation; do not classify as Ant only because an Ant was nearby.

## S321 Loading Belt Scan Stop Position Overlap

Knowledge file: `docs/s321/knowledge/loading-belt-scan-stop-position-overlap.md`

### First Checks

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

### Evidence

- Conveyor configuration values for scan stop position and loading-belt stop position.
- Logs around scan event, `parcel receive scan barcode`, `0x02` / `包裹过扫描段`, package head position, and waiting/loading-belt target position.
- Robot mission result and station arrival/pick status for the same parcel ID.
- Video or camera frame showing the parcel stuck on the last feeder/loading segment.
- Post-change retest proving a 5 mm offset lets the parcel cross the scan threshold and proceed to pickup.

### Exclusions

- Do not diagnose RFID/scanner failure when logs show `RFID-mqtt` receive and `parcel receive scan barcode`.
- Do not diagnose robot pickup failure first when the parcel never emits the scan-segment pass event.
- Do not treat a 0.000122 m gap as zero; threshold comparisons can be strict and keep the state machine blocked.
- Do not merge with S321 RFID low-read-rate cases; this case has scan success but position threshold failure.
- Do not claim full closure without post-config retest evidence after the 5 mm offset.

### Examples

- `s321-pt-0137`: parcel `000158096177` / `1778217254335-12` scanned successfully, but because loading-belt stop and scan stop positions were effectively identical, the head stopped at `0.579878 m` while the waiting/scan boundary was `0.580000 m`; `0x02 包裹过扫描段` was not emitted. Source fix is to set loading-belt stop position 5 mm greater than scan stop position.

- `s321-pt-0137`: missing raw full controller log, exact before/after config dump, and post-fix retest artifacts. The visible log and source analysis are enough for a high-value diagnostic rule, but final verification evidence is incomplete.
