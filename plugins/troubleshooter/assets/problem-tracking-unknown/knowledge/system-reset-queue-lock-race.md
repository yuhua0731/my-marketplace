# System Reset Queue Lock Race Produces QUEUE RESET

source_set: `problem-tracking-unknown-pt-0176`
case_count: 1 system reset / task-queue alarm case
status: runtime routing rules for `QUEUE RESET` after deliberate power cut or system reset

## Symptoms

- System is running shuttle-mode self-run or a test workflow.
- Incoming mains power is deliberately cut, then reconnected after several minutes.
- UI notification reports `异常：QUEUE RESET`.
- Popup may show `RETRY CREATE TEST ORDER`, `已知晓`, and a timestamp such as `2026-06-17 15:54:06`.

## Fault Tree

1. Treat as reset-vs-queue-lock timing first.
   - `problem-tracking-unknown-pt-0176`: mains power was manually disconnected at about `15:54`, then reconnected.
   - Source analysis says system reset clears queue data.
   - If a task is being pushed into the queue for lock operation during reset, lock failure can report `QUEUE RESET`.
2. Separate test-task alarm policy from production behavior.
   - Source resolution: suppress alarm information for test tasks to avoid misunderstanding.
   - This is valid only when the task is confirmed as a test task and the reset/power-cut action is intentional.
3. Production branch remains actionable.
   - If `QUEUE RESET` appears without a deliberate reset/power-cut window, investigate queue persistence, task lifecycle, scheduler restart, duplicate lock attempts, and order-state recovery.
4. Exclude unrelated domains.
   - This evidence is not a CAN failure by itself.
   - Do not route to network/AP merely because generic text contains `impact` or UI context.

## Evidence Needed

- Reset/power-cut timestamp and system startup/reset log.
- Queue clear event and task enqueue/lock attempt log around the same window.
- Task/order ID and whether it is a test task or production task.
- UI alarm screenshot or frontend log with exact `QUEUE RESET` timestamp.
- Post-change verification showing only confirmed test-task reset alarms are suppressed/downgraded.

## Logs And Files To Inspect

- `cases/accepted/problem-tracking-unknown/0176-J96PwQrI0i8k9KkvMlxchKAsntg-2026-06-17断市电会报QUEUE-RESET报错.md`
- `assets/problem-tracking-unknown-pt-0176/retry-image-001-YjuLbVJN0om5dVxo0iocnYvKntb.png`
  - PNG, `2818 x 1556`, RGBA.
  - Shows `异常：QUEUE RESET`, `发生时间：2026-06-17 15:54:06`, and `RETRY CREATE TEST ORDER`.
- Search terms: `QUEUE RESET`, `断市电`, `进线电源`, `重置系统`, `清空队列数据`, `锁定操作`, `测试任务`, `RETRY CREATE TEST ORDER`, `屏蔽告警信息`.

## Likely Causes

- Intentional system reset clears queue state while a test task lock is in progress.
- UI alarm policy does not distinguish expected test-reset race from actionable production queue failure.
- Queue lock failure is surfaced as a generic exception instead of a scoped test/reset notice.

## Exclusion Checks

- Do not diagnose CAN fault without heartbeat, SDO, NMT, or bus-error evidence in the same timestamp window.
- Do not diagnose network/AP fault without real disconnect, MQTT, ping, AP roaming, or service-communication evidence.
- Do not suppress production `QUEUE RESET` without proving intentional reset and test-task context.
- Do not use the screenshot alone to prove backend queue clear or lock timing; require logs for confirmation.
- Do not treat every reset-recovered queue alarm as harmless; repeated production alarms need scheduler/queue recovery analysis.

## Confirmed Examples

- `problem-tracking-unknown-pt-0176`: during shuttle-mode self-run, incoming mains power was manually disconnected at about `15:54` and later reconnected. UI showed `异常：QUEUE RESET`, timestamp `2026-06-17 15:54:06`. Source analysis says reset clears queue data; when task queue locking is in progress, reset-caused lock failure reports this error. Resolution is to suppress alarm information for test tasks.

## Unresolved Examples

- `problem-tracking-unknown-pt-0176`: missing backend queue logs, reset logs, exact task/order ID, product/project confirmation, and post-change validation.

## Specialist Routing

- Start with `scheduler-traffic` for queue, lock, task lifecycle, and reset recovery.
- Add `embedded-software` for reset/power-cycle timing and service startup order.
- Add `vision-media` for UI popup/screenshot confirmation.
- Add `network-infra` only when real service disconnect evidence exists.
