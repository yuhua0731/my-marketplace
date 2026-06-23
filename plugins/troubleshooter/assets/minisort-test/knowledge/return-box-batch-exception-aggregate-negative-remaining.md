# Return Box Batch Exception Aggregate Negative Remaining

## Symptoms

- WRS return-box list shows a negative `remaining_delivery_quantity` after batch exception handling.
- The same row may still show positive `on_the_way_quantity` even though remaining parcels were set abnormal.
- In `minisort-test-pt-0028`, return box `0414142813` shows plan `200`, remaining `-1`, on-the-way `1`, recorded `136`, abnormal `64`.

## Fault Tree

- Confirmed branch: the failure happens in WRS return-box batch exception handling.
  - `wrs.log` shows `2026-04-14 17:38:16.018` `POST /api/return-boxes/batch-exception-handling`.
  - Request body is `{"ids":[5],"abnormalReasonId":5}`.
  - `ReturnBoxService` logs `批量异常处理开始，异常原因: 5, 退货箱ID列表: [5]`.
  - Response is `200 (OK)` at `17:38:16.186`.
- Confirmed branch: the UI symptom is aggregate counter corruption, not a robot/device fault.
  - The screenshot shows return box `0414142813`, status `等待投递`, period `week16`, plan `200`, remaining `-1`, on-the-way `1`, recorded `136`, abnormal `64`.
  - The source analysis says after setting all remaining quantities to abnormal, final return-box remaining quantity should be `0`.
- Confirmed branch from source analysis: batch exception subtracts detail remaining sum from the current box remaining value.
  - Source formula: new return-box remaining = current return-box remaining - sum of remaining quantities in all details.
  - When detail remaining sum is greater than current box remaining, the aggregate becomes negative.
  - This operation is only for exception setting, so the aggregate remaining should be forced/recomputed to `0`.
- Evidence-backed branch: SQL updates occur in the same transaction window, but bound values are not visible.
  - `wrs-sql.log` around `17:38:16` shows many inserts into `return_box_sorting_details`.
  - It then updates `return_boxes` with `abnormal_quantity`, `on_the_way_quantity`, `recorded_quantity`, and `remaining_delivery_quantity`.
  - It also updates `return_box_details` with `abnormal_quantity`, `on_the_way_quantity`, `recorded_quantity`, and `remaining_delivery_quantity`.
  - The SQL log uses `?` placeholders, so it proves update paths, not exact written values.

## Diagnostic Rules

- Route WRS negative remaining/on-the-way anomalies to return-box aggregate accounting before robot, CAN, feeder, or physical handling branches.
- For batch abnormal handling, do not update box-level remaining by subtracting detail remaining from a stale or partially updated aggregate.
- After all residual detail quantities are converted to abnormal, recompute box-level counters from details or set semantic terminal counters explicitly:
  - `remaining_delivery_quantity = 0`
  - `on_the_way_quantity = 0` unless there is a still-live WCS delivery ticket
  - abnormal/recorded counts must match the detail-level terminal state.
- Total arithmetic consistency alone is insufficient. In the screenshot, `136 + 64 + (-1) + 1 = 200`, but `remaining=-1` and `on_the_way=1` are semantically invalid after completion/exception handling.
- Preserve operation order: start/end delivery, exception reason query, batch exception request, sorting-detail insert, return-box update, return-box-detail update, then UI reload.

## Evidence Needed

- Bound SQL values or database snapshots before and after `POST /api/return-boxes/batch-exception-handling`.
- Source code diff for the aggregate formula and final fix.
- Unit/integration test covering detail residual sum greater than current box remaining.
- Post-fix UI screenshot or API response proving remaining and on-the-way counters are non-negative and semantically terminal.

## Likely Causes

- Batch exception handling subtracts the sum of detail remaining quantities from the current return-box aggregate instead of recomputing the aggregate from the post-operation detail state.
- The current box aggregate can already be lower than the detail remaining sum because delivery/end-delivery/on-the-way state has partially changed before exception handling.
- On-the-way cleanup is not coupled to terminal exception handling, leaving positive in-flight quantity after all residual detail quantity is treated as abnormal.
- Less likely as primary cause: frontend display formatting, because source analysis and SQL logs point to backend return-box and return-box-detail updates.

## Logs And Files To Inspect

- Case body: `cases/accepted/minisort-test/0028-PgwBwivC2id8iCkmfPrceih6nbh-2026-04-14-WRS系统退货箱订单处理完成后剩余投递量显示异常问题.md`.
- `assets/minisort-test-pt-0028/001-image-db9ce691d50a.jpg`: WRS return-box list screenshot showing `0414142813`, remaining `-1`, on-the-way `1`, recorded `136`, abnormal `64`.
- `assets/minisort-test-pt-0028/002-image-d4d81d4c0af1.png`: log/code screenshot showing `POST /api/return-boxes/batch-exception-handling` and `ReturnBoxService - 批量异常处理开始`.
- `assets/minisort-test-pt-0028/003-source-Q4xhbkr7QoLhvgxVwPLcD9BRn1g.zip`: WRS log bundle.
- Extracted log focus:
  - `logs/wrs.log`, lines around `17:37:21~17:38:24`.
  - `logs/wrs-sql.log`, lines around `17:38:16`.
- Search terms: `0414142813`, `batch-exception-handling`, `批量异常处理开始`, `return_box_sorting_details`, `return_boxes`, `return_box_details`, `remaining_delivery_quantity`, `on_the_way_quantity`, `abnormal_quantity`.

## Exclusion Checks

- Do not diagnose robot delivery failure when the primary evidence is WRS aggregate counter state after a successful batch exception API call.
- Do not route to full-box trigger/CAN gateway mapping unless the symptom is trigger-count UI, MQTT mapping, or full-box sensor configuration.
- Do not route to exception-mouth slow-run or locked-sowing movement timing; this case is WRS data accounting.
- Do not accept total count equality as sufficient; check non-negative counters and operation semantics.
- Do not claim the exact DB values were proven by `wrs-sql.log` unless bound parameters or DB snapshots are available.

## Confirmed Examples

- `minisort-test-pt-0028`: M111 WRS return box `0414142813` had residual undelivered quantity. Batch exception handling with abnormal reason `5` succeeded at `2026-04-14 17:38:16`, then the UI showed remaining `-1` and on-the-way `1`. Source analysis identifies a formula bug: subtracting sum of detail remaining quantities from current box remaining can go negative; for this exception operation, box remaining should be `0`.

## Unresolved Examples

- `minisort-test-pt-0028`: SQL log does not show bound values; no code diff, DB before/after snapshot, automated test, or post-fix screenshot is local.

## Specialist Routing

- Start with `scheduler-traffic` for WRS/backend order, exception workflow, and aggregate state-machine logic.
- Add `embedded-software` only if WCS delivery tickets or device callbacks are still actively changing `on_the_way_quantity`.
- Add `vision-media` only to inspect UI/log screenshots.
