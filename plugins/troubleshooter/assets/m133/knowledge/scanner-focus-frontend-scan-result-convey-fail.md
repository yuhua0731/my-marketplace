# M133 Scanner Focus, Frontend Scan Result, and Convey-Fail Routing

## Scope

Use this when an M133 / OmniSort feeder case involves scanner miss, wrong scan-success UI, duplicate barcode handling, manual-scan barcode truncation, `SCAN OUT OF AREA`, `CONVEYOR_SCAN_BARCODE_EXISTS`, empty barcode, or parcels sent to a convey-fail / abnormal grid.

This pattern is not primarily a CAN fault unless raw CAN or conveyor-node evidence is present. Treat it as a scanner input, frontend result mapping, parcel-barcode association, and scheduler/convey-fail workflow issue first.

## Symptoms

- Barcode near the feeder is not scanned, but can be scanned when it is closer to the scanner head.
- Backend reports scan success while the UI displays a red popup or failure state.
- Continuous duplicate scan returns an error state instead of a clear "barcode already exists" state.
- Manual/fixed scanner mode shows a barcode scanned, but the event list or logs show the final valid character missing, such as active order `P 12mil 0.30mm abcde` queried as `P 12mil 0.30mm abcd`.
- Nonexistent or empty barcode causes parcels to be sent to the abnormal / convey-fail grid.
- Logs show `SCAN OUT OF AREA`, `CONVEYOR_SCAN_BARCODE_EXISTS`, `ORDER_NOT_FOUND_IN_ORDER_GROUP`, `LACK_PARAMS`, or `createMissionByConveyFailAndSet`.

## Fault Tree

- Physical scanner focus or distance mismatch: likely when small barcodes such as `L 08mil 0.20mm abcde` fail near the feeder but scan when the barcode is closer to the scanner head. Check focus, scan distance, barcode size, angle, motion speed, and lighting before changing conveyor logic.
- Frontend result mapping not aligned with backend scan result: confirmed when backend emits `formateSocketNotice` with `success:true` and `SCAN_SUCCESS`, but the UI shows a red popup or wrong failure state. In this case the source conclusion says the frontend needed the S311 merge.
- Duplicate barcode event displayed as generic error: confirmed when the second scan returns `CONVEYOR_SCAN_BARCODE_EXISTS`. This is a business/result-display path, not a scanner hardware miss.
- Manual scanner trailing-byte truncation: confirmed when raw bytes decode to a full barcode such as `P 12mil 0.30mm abcde`, but unconditional `bytes.slice(0, bytes.length - 1)` changes it to `P 12mil 0.30mm abcd`. If `lastByte` is `101` (`0x65`, `e`), it is valid product data, not a terminator. Strip only trailing `0x0d`, `0x0a`, or `0x00`.
- Nonexistent barcode to convey-fail: confirmed when a barcode such as `123458` is used for mission query and the order lookup returns `ORDER_NOT_FOUND_IN_ORDER_GROUP`, followed by `createMissionByConveyFailAndSet` and mission type `conveyFail`.
- Empty barcode after missed scan: confirmed when a parcel has `barcode:""`, hits `parcel scan timeout`, then mission creation fails with `LACK_PARAMS`, followed by `createMissionByConveyFailAndSet`.
- Barcode-pool or parcel association timing mismatch: likely when `rollerScan` reports one barcode but the arriving/leaving parcel carries a different barcode or empty barcode. Compare `push barcode to pool`, `pull barcode from pool`, parcel UUID, `finish scan`, `parcel arrive`, and `onParcelBeginLeaveEvent` timestamps.

## Evidence Needed

- Source symptom text, exact test barcode, feeder/site ID, and timestamp.
- Scanner result logs: `rollerScan`, `originalBuf`, `push barcode to pool`, `pull barcode from pool`.
- Scanner normalization code and debug output: `normalizeScannerData`, `rollerScanV2.js`, raw hex bytes, decoded `original`, decoded `afterSlice`, `lastByte`, `0x0d`, `0x0a`, `0x00`.
- Frontend/backend result logs: `formateSocketNotice`, `SCAN_SUCCESS`, `CONVEYOR_SCAN_BARCODE_EXISTS`, UI screenshots.
- Parcel flow logs: parcel UUID, `parcel finish scan`, `parcel scan timeout`, `barcode`, `originalBarcode`, `onParcelBeginLeaveEvent`.
- Mission flow logs: `ORDER_NOT_FOUND_IN_ORDER_GROUP`, `LACK_PARAMS`, `createMissionByConveyFailAndSet`, mission type, grid UUID.
- Video or screenshots showing barcode position, scanner distance, screen result, and abnormal-port behavior.

## Logs And Files To Inspect

- Case source text and screenshots around feeder tests, scanner UI, and abnormal-port behavior.
- Scanner logs and parser code: `rollerScan`, `originalBuf`, `normalizeScannerData`, `rollerScanV2.js`, `TextDecoder`, `lastByte`, `product barcode pool`, `push barcode to pool`, `pull barcode from pool`.
- Frontend/backend notice logs: `formateSocketNotice`, `SCAN_SUCCESS`, `CONVEYOR_SCAN_BARCODE_EXISTS`.
- Parcel and scheduler logs: `parcel finish scan`, `parcel scan timeout`, `onParcelBeginLeaveEvent`, `ORDER_NOT_FOUND_IN_ORDER_GROUP`, `LACK_PARAMS`, `createMissionByConveyFailAndSet`, `conveyFail`.
- Video evidence for barcode distance, focus, angle, label size, package motion, and screen state.

## Likely Causes

- Scanner focus or distance is wrong when small barcodes fail close to the feeder but read closer to the scanner.
- Frontend code is stale or missing the expected scan-result handling when backend `SCAN_SUCCESS` becomes a red popup.
- Duplicate-barcode UX is wrong when `CONVEYOR_SCAN_BARCODE_EXISTS` is surfaced as a generic scan failure.
- Manual-scan normalization strips a valid final character when code removes the last byte unconditionally instead of checking for trailing CR/LF/NUL terminators.
- Bad or missing barcode data is expected to become `conveyFail` when order lookup fails or mission creation lacks parameters.
- Barcode-pool timing or parcel association is suspect when a scan result and the parcel's `barcode` / `originalBarcode` disagree.

## Diagnostic Rules

- Do not diagnose robot dispatch as the first cause when the feeder creates `conveyFail` missions from `ORDER_NOT_FOUND_IN_ORDER_GROUP` or `LACK_PARAMS`; the scheduler is carrying a feeder/business failure result.
- If backend reports `SCAN_SUCCESS` but the UI shows failure, check frontend version/merge state before adjusting scanner hardware.
- If duplicate scan returns `CONVEYOR_SCAN_BARCODE_EXISTS`, separate the expected duplicate-barcode UX from scanner recognition quality.
- If an order contains `abcde` but the event list, mission query, or failure log uses `abcd`, inspect scanner byte normalization before changing order data or scanner focus. A printable `lastByte` such as `101` (`0x65`, `e`) must be retained.
- For manual/fixed scanner mode, compare raw hex, full decoded barcode, post-normalization barcode, and `details.product.barcode` in the order lookup.
- If missed scan creates `barcode:""` and `LACK_PARAMS`, verify scanner placement/focus and package timing before investigating mission allocation.
- If an invalid barcode goes to the abnormal grid, confirm whether that is expected `nofind` behavior rather than a fault.

## Exclusion Checks

- Exclude CAN as the main branch unless there are CAN heartbeat, SDO/PDO, node error, or conveyor-controller restart lines in the same failure window.
- Exclude robot motion/localization when the robot receives a deliberate `conveyFail` mission and successfully throws to the configured fail grid.
- Exclude order-system mismatch only after confirming the barcode exists in the active order group and query conditions match.
- Exclude scanner focus when raw/debug bytes contain the full barcode and only the normalized/query barcode loses the final character.
- Exclude frontend-only fault when the backend lacks `SCAN_SUCCESS` or the scanner never reports the barcode.

## Confirmed Examples

- `m133-pt-0099`: source reports four problems: close-to-feeder barcode scan miss, red popup after successful scan, duplicate scan not reported as existing barcode, and nonexistent package causing later packages to go abnormal. Evidence shows `2026-04-24T17:39:07.550+0800` backend sent `SCAN_SUCCESS` for `L 09mil 0.23mm abcde`; `2026-04-24T17:39:08.105+0800` duplicate scan returned `CONVEYOR_SCAN_BARCODE_EXISTS`; `2026-04-24T17:39:38.442+0800` barcode `123458` failed with `ORDER_NOT_FOUND_IN_ORDER_GROUP`; `2026-04-24T17:39:40.419+0800` empty barcode failed with `LACK_PARAMS`. Both failure paths created `conveyFail` missions to `M133-WALL-A-1-3-1`.
- `m133-pt-0098`: manual scan mode used the automatic scanner as a fixed scanner. Screenshots show active order barcodes such as `P 12mil 0.30mm abcde` and `P 18mil 0.45mm abcde`, while scan-failure events and order queries use truncated values `P 12mil 0.30mm abcd` and `P 18mil 0.45mm abcd`. Debug evidence shows raw hex `502031326d696c20302e33306d6d206162636465` decodes to `P 12mil 0.30mm abcde`, but unconditional slicing removes `lastByte: 101` (`e`), causing `ORDER_NOT_FOUND_IN_ORDER_GROUP` and `createMissionByConveyFailAndSet`. The fix strips only trailing `0x0d`, `0x0a`, or `0x00`.

## Unresolved Examples

- `m133-pt-0099`: full video frame-by-frame inspection was not available in local tooling; only visible thumbnails and screenshot evidence were inspected. Supplier focus-adjustment records and the exact S311 frontend diff were not present locally.
- `m133-pt-0098`: raw backend log files, the exact `rollerScanV2.js` commit, and post-fix production logs were not present locally. Video was available, but only QuickLook thumbnail inspection was performed because local `ffmpeg`/`ffprobe` were unavailable.

## Specialist Routing

- `scheduler-traffic`: parcel-barcode association, order lookup, `conveyFail` mission creation, abnormal-grid routing.
- `vision-media`: scanner distance/focus, barcode size and position, UI red popup, package movement near feeder.
- `embedded-software`: scanner input parsing, socket notice generation, backend scan-result event flow.
- `can-bus`: only if same-window evidence shows CAN heartbeat, SDO/PDO, or conveyor-node communication failures.
