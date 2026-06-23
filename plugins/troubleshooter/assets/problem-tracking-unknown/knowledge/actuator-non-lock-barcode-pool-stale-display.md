# Actuator Non-lock Barcode Pool Stale Display

source_set: `problem-tracking-unknown-pt-0112`
case_count: 1 actuator-mode scanner UI / barcode-pool state case
status: runtime routing rules for actuator non-lock mode after successful scan and delivery

## Symptoms

- The system is in actuator mode.
- The scan mode is configured as non-lock / `非锁定`.
- A barcode scan succeeds and the parcel is delivered successfully.
- Expected UI state after delivery: the scan panel returns to no-barcode / `未扫到条码`.
- Actual UI state: the delivered parcel barcode, for example `123455`, remains visible in the upload/result panel or scan record area.
- Visible source analysis calls it `代码Bug` and points to `tryToPullProductBarcodeFromPool`.

## Fault Tree

1. Confirm this is not scanner read failure.
   - The case says scan succeeds and parcel delivery succeeds.
   - The defect is stale UI/state after delivery, not missing scanner input.
2. Confirm actuator + non-lock mode.
   - Screenshot evidence shows the UI toggle/state marked `非锁定`.
   - This mode should not keep the consumed barcode as a locked seed after delivery.
3. Inspect barcode-pool consumption.
   - Code screenshot shows `tryToPullProductBarcodeFromPool`.
   - When `this.productBarcodePool.length` is non-zero, added logic checks `businessInstance.isActuator && this.productBarcodePool[0].isFromLock`.
   - If true, it logs `not order group mode, skip pull product barcode from pool` and returns before `this.productBarcodePool[0].qty--`.
4. Separate lock-mode retention from non-lock cleanup.
   - Lock-mode or order-group behavior may intentionally preserve a barcode.
   - Non-lock actuator delivery should consume/decrement or clear the delivered barcode so the next UI state is `未扫到条码`.
5. Verify after repair.
   - Reproduce with actuator non-lock scan, successful delivery, then check the upload/result panel, scan record, pool length, first pool entry `qty`, and `isFromLock`.

## Evidence Needed

- UI screenshot or video showing actuator mode, `非锁定`, delivered barcode, and expected no-barcode state after delivery.
- Frontend/backend logs or debug output around scan success, delivery success, and barcode-pool update.
- Source diff or code review for `tryToPullProductBarcodeFromPool`.
- Runtime values for `businessInstance.isActuator`, `productBarcodePool[0].isFromLock`, `productBarcodePool[0].qty`, and pool length.
- Post-fix retest showing barcode clears after delivery in non-lock mode and still behaves correctly in lock/order-group modes.

## Logs And Files To Inspect

- Case body: `cases/accepted/problem-tracking-unknown/0112-RrLdwDX5sivkOMkn5Uicjbvsn7e-2026-04-24-执行器模式下扫描条码-非锁定模式不生效.md`.
- Video: `assets/problem-tracking-unknown-pt-0112/retry-source-PcPvbWgvfoMso3xtzuscpZn3nNg.mov`.
  - QuickTime metadata: 960 x 540, duration about 70.2 s, size 11128164 bytes.
  - QuickLook representative frame shows 操作台1 with `123455`, scan records including `123455`, and 操作台2 showing `未条码`.
- Screenshot: `assets/problem-tracking-unknown-pt-0112/retry-image-001-F9fabLRYCorZjUxzROPcWxxnnnf.jpg`.
  - Shows UI time `2026-04-24 13:57:45`, `非锁定`, barcode `123455`, and annotation that the delivered parcel should not keep scan state.
- Code screenshot: `assets/problem-tracking-unknown-pt-0112/retry-image-002-QlNmbfuqMoWQHWxZGUlc0H5Bnff.png`.
  - Shows `tryToPullProductBarcodeFromPool`, actuator / `isFromLock` branch, warning text, early `return`, and skipped `qty--`.
- Search terms: `problem-tracking-unknown-pt-0112`, `执行器模式`, `非锁定`, `未扫到条码`, `123455`, `tryToPullProductBarcodeFromPool`, `productBarcodePool`, `isFromLock`, `businessInstance.isActuator`, `skip pull product barcode from pool`, `qty--`.

## Likely Causes

- Actuator non-lock path reuses lock-mode retention logic and returns before consuming the barcode pool entry.
- `isFromLock` is set or retained unexpectedly for a barcode that should be consumed in non-lock actuator mode.
- Frontend display state is bound to the stale first barcode-pool entry instead of the post-delivery scan state.
- The code path treats actuator mode like non-order-group lock preservation without checking the configured non-lock mode.

## Exclusion Checks

- Do not diagnose scanner hardware, focus, serial framing, or barcode format when the same evidence says scan succeeded and delivery succeeded.
- Do not merge with actuator lock-mode "scan succeeds but barcode not displayed" defects unless the failure is the same post-delivery stale barcode state.
- Do not treat `未扫到条码` text alone as scan failure; in this case it is the expected cleared state after delivery.
- Do not claim the fix is verified without a post-fix non-lock delivery retest.
- Do not assume OmniSort project/corpus from UI alone; source metadata keeps product line and project unknown.

## Confirmed Examples

- `problem-tracking-unknown-pt-0112`: actuator non-lock mode, barcode `123455` remains visible after successful parcel delivery. Code screenshot shows `tryToPullProductBarcodeFromPool` returns before `qty--` when actuator mode and `isFromLock` are true.

## Unresolved Examples

- `problem-tracking-unknown-pt-0112`: missing raw app logs, full source diff, runtime variable dump, and post-fix retest. Root cause confidence is medium because the visible code path matches the symptom, but final verification is absent.

## Specialist Routing

- Start with `scheduler-traffic` for workflow state, scan-to-delivery lifecycle, and barcode-pool consumption.
- Add `vision-media` for UI screenshot/video state confirmation.
- Add `embedded-software` only if device-side scan or actuator controller logs contradict the successful scan/delivery premise.
