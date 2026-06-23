# M111 WRS Lift Module No Action After Second Scan

source_set: `m111-pt-0039`
case_count: 1 focused M111 WRS/lift no-action case
status: runtime routing rules for scan/delivery followed by lift module no response

## Symptoms

- M111 WRS scan/delivery sequence: after one parcel is routed to an exception slot, the next scan/delivery causes the lift module to receive the parcel but not act.
- The system may show an unresponsive popup about 1 minute later.
- Module UI may still look healthy, with normal voltage and not restarting or locked.

## Fault Tree

1. Build the transaction timeline first.
   - `m111-pt-0039`: at `2026-04-13 15:13:47`, the first parcel was delivered without scanning product barcode.
   - The unread exception slot was on layer 3, but layer 3 had no robot, so the parcel was delivered to the layer-2 exception slot.
   - At `15:13:49`, another scan/delivery was attempted; after the lift module received the parcel, it had no response, and 1 minute later the system showed an unresponsive popup.
2. Check stale state after exception-slot fallback.
   - The previous fallback to layer-2 exception slot may leave stale parcel ownership, destination, reservation, lift busy state, or exception-port state.
   - Treat this as scheduler/service transaction risk before hardware replacement.
3. Interpret module UI state narrowly.
   - Local image shows D002 with RF address `020416169969`, track `水平第2层`, voltage `56.1`, state `完成抛送货品`, restarting `否`, locked `否`.
   - This proves a visible UI state only; it does not prove the controller accepted the next command.
4. Escalate to lift/CAN/RF only after command evidence.
   - If WRS/RCS issued a lift command and no ack/state transition came back, inspect RF/CAN heartbeat, module controller logs, and motor/IO state.
   - If no command was issued, root branch stays in service task/reservation logic.

## Evidence Needed

- WRS/RCS/SAS logs from `2026-04-13 15:13:47` through the 1-minute timeout.
- Lift module controller logs for D002 command send, ack, state transition, and timeout.
- RF/CAN capture or telemetry around D002 if a command was sent but no response returned.
- UI screenshot or log for the exact unresponsive popup.
- Task/order/container/barcode/SKU ID, exception-slot ID, station ID, and robot availability on each layer.
- Physical video or sensor log showing whether the lift received, held, jammed, or released the parcel.

## Logs And Files To Inspect

- `cases/needs-assets/m111/0039-YHSXw3lDRivdmvkzbTdcbHB2nXc-2026-04-13-M111-WRS扫码投递包裹-提升模组接包后无动作.md`
- `assets/m111-pt-0039/001-image-e8122a9ebbba.jpg`
  - `2424x698`, `160904` bytes.
  - Shows D002: RF `020416169969`, `水平第2层`, voltage `56.1`, state `完成抛送货品`, restarting `否`, locked `否`.
- Search terms: `M111`, `WRS`, `扫码投递`, `不扫描商品条码`, `未读异常口`, `第三层没有机器人`, `第二层异常口`, `提升模组接包后无动作`, `系统未响应弹窗`, `D002`, `020416169969`, `完成抛送货品`.

## Likely Causes

- Previous exception-slot fallback or completed-throw state left stale task ownership, reservation, or lift busy state.
- WRS/RCS did not issue the next lift action after the second scan because robot/slot availability or transaction state was inconsistent.
- Lift command was issued but D002 did not acknowledge due to RF/CAN/controller timeout. This branch is unconfirmed without logs.
- Physical parcel state may not match service state, but this is unconfirmed without video or sensors.

## Exclusion Checks

- Do not route to Ant/OmniFlow power because the UI table contains a restarting column.
- Do not route to CAN solely from `system_area: CAN`; require command/ack, heartbeat, RF/CAN, or controller evidence.
- Do not treat `完成抛送货品` as a terminal backend state; verify task locks and parcel ownership.
- Do not blame operator timing until the software contract for back-to-back scan/delivery after exception fallback is checked.
- Do not merge with conveyor recovery race unless logs show manual recovery or error restoration ordering.

## Confirmed Examples

- `m111-pt-0039`: visible text records first parcel at `15:13:47`, exception-slot fallback from layer 3 to layer 2 because no robot existed on layer 3, second scan at `15:13:49`, lift module received parcel but did not act, and a system unresponsive popup appeared about 1 minute later. Local image shows D002 on layer 2 with voltage `56.1`, state `完成抛送货品`, not restarting, and not locked.

## Unresolved Examples

- `m111-pt-0039`: missing service logs, lift controller command/ack timeline, RF/CAN evidence, timeout popup screenshot, task/barcode/container IDs, robot availability, physical video, and final resolution.

## Specialist Routing

- Start with `scheduler-traffic` for WRS/RCS task, reservation, exception-slot fallback, and command issuance.
- Add `vision-media` for UI state evidence and physical parcel/lift video if available.
- Add `embedded-software` or `can-bus` only if command/ack evidence shows module controller or RF/CAN timeout.
