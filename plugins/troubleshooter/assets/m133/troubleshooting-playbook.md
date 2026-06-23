# M133 Troubleshooting Playbook

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

## M133 Scanner Focus, Frontend Scan Result, and Convey-Fail Routing

Knowledge file: `docs/m133/knowledge/scanner-focus-frontend-scan-result-convey-fail.md`

### First Checks

- Physical scanner focus or distance mismatch: likely when small barcodes such as `L 08mil 0.20mm abcde` fail near the feeder but scan when the barcode is closer to the scanner head. Check focus, scan distance, barcode size, angle, motion speed, and lighting before changing conveyor logic.
- Frontend result mapping not aligned with backend scan result: confirmed when backend emits `formateSocketNotice` with `success:true` and `SCAN_SUCCESS`, but the UI shows a red popup or wrong failure state. In this case the source conclusion says the frontend needed the S311 merge.
- Duplicate barcode event displayed as generic error: confirmed when the second scan returns `CONVEYOR_SCAN_BARCODE_EXISTS`. This is a business/result-display path, not a scanner hardware miss.
- Manual scanner trailing-byte truncation: confirmed when raw bytes decode to a full barcode such as `P 12mil 0.30mm abcde`, but unconditional `bytes.slice(0, bytes.length - 1)` changes it to `P 12mil 0.30mm abcd`. If `lastByte` is `101` (`0x65`, `e`), it is valid product data, not a terminator. Strip only trailing `0x0d`, `0x0a`, or `0x00`.
- Nonexistent barcode to convey-fail: confirmed when a barcode such as `123458` is used for mission query and the order lookup returns `ORDER_NOT_FOUND_IN_ORDER_GROUP`, followed by `createMissionByConveyFailAndSet` and mission type `conveyFail`.
- Empty barcode after missed scan: confirmed when a parcel has `barcode:""`, hits `parcel scan timeout`, then mission creation fails with `LACK_PARAMS`, followed by `createMissionByConveyFailAndSet`.
- Barcode-pool or parcel association timing mismatch: likely when `rollerScan` reports one barcode but the arriving/leaving parcel carries a different barcode or empty barcode. Compare `push barcode to pool`, `pull barcode from pool`, parcel UUID, `finish scan`, `parcel arrive`, and `onParcelBeginLeaveEvent` timestamps.

### Evidence

- Source symptom text, exact test barcode, feeder/site ID, and timestamp.
- Scanner result logs: `rollerScan`, `originalBuf`, `push barcode to pool`, `pull barcode from pool`.
- Scanner normalization code and debug output: `normalizeScannerData`, `rollerScanV2.js`, raw hex bytes, decoded `original`, decoded `afterSlice`, `lastByte`, `0x0d`, `0x0a`, `0x00`.
- Frontend/backend result logs: `formateSocketNotice`, `SCAN_SUCCESS`, `CONVEYOR_SCAN_BARCODE_EXISTS`, UI screenshots.
- Parcel flow logs: parcel UUID, `parcel finish scan`, `parcel scan timeout`, `barcode`, `originalBarcode`, `onParcelBeginLeaveEvent`.
- Mission flow logs: `ORDER_NOT_FOUND_IN_ORDER_GROUP`, `LACK_PARAMS`, `createMissionByConveyFailAndSet`, mission type, grid UUID.
- Video or screenshots showing barcode position, scanner distance, screen result, and abnormal-port behavior.

### Exclusions

- Exclude CAN as the main branch unless there are CAN heartbeat, SDO/PDO, node error, or conveyor-controller restart lines in the same failure window.
- Exclude robot motion/localization when the robot receives a deliberate `conveyFail` mission and successfully throws to the configured fail grid.
- Exclude order-system mismatch only after confirming the barcode exists in the active order group and query conditions match.
- Exclude scanner focus when raw/debug bytes contain the full barcode and only the normalized/query barcode loses the final character.
- Exclude frontend-only fault when the backend lacks `SCAN_SUCCESS` or the scanner never reports the barcode.

### Examples

- `m133-pt-0099`: source reports four problems: close-to-feeder barcode scan miss, red popup after successful scan, duplicate scan not reported as existing barcode, and nonexistent package causing later packages to go abnormal. Evidence shows `2026-04-24T17:39:07.550+0800` backend sent `SCAN_SUCCESS` for `L 09mil 0.23mm abcde`; `2026-04-24T17:39:08.105+0800` duplicate scan returned `CONVEYOR_SCAN_BARCODE_EXISTS`; `2026-04-24T17:39:38.442+0800` barcode `123458` failed with `ORDER_NOT_FOUND_IN_ORDER_GROUP`; `2026-04-24T17:39:40.419+0800` empty barcode failed with `LACK_PARAMS`. Both failure paths created `conveyFail` missions to `M133-WALL-A-1-3-1`.
- `m133-pt-0098`: manual scan mode used the automatic scanner as a fixed scanner. Screenshots show active order barcodes such as `P 12mil 0.30mm abcde` and `P 18mil 0.45mm abcde`, while scan-failure events and order queries use truncated values `P 12mil 0.30mm abcd` and `P 18mil 0.45mm abcd`. Debug evidence shows raw hex `502031326d696c20302e33306d6d206162636465` decodes to `P 12mil 0.30mm abcde`, but unconditional slicing removes `lastByte: 101` (`e`), causing `ORDER_NOT_FOUND_IN_ORDER_GROUP` and `createMissionByConveyFailAndSet`. The fix strips only trailing `0x0d`, `0x0a`, or `0x00`.

- `m133-pt-0099`: full video frame-by-frame inspection was not available in local tooling; only visible thumbnails and screenshot evidence were inspected. Supplier focus-adjustment records and the exact S311 frontend diff were not present locally.
- `m133-pt-0098`: raw backend log files, the exact `rollerScanV2.js` commit, and post-fix production logs were not present locally. Video was available, but only QuickLook thumbnail inspection was performed because local `ffmpeg`/`ffprobe` were unavailable.
