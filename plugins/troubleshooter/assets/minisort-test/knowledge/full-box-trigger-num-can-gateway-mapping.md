# Full Box Trigger Number CAN Gateway Mapping

## Symptoms

- Mini Plus / MiniSort central control opens the full-box sensor trigger window very slowly.
- Full-box trigger count for seed walls does not render correctly; color may stay transparent when it should show orange for one sensor triggering full-box.
- Editing a wall trigger count, such as changing `A0` to `2`, spins for minutes and then fails without a popup.
- Central-control logs can show `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED`.
- After CAN gateway and table changes, a related regression can appear: full-box trigger has no MQTT message, door lock fails, and `responseTopicHookQueueMap not found` appears for cart/door topics.

## Fault Tree

- Confirmed branch: full-box trigger count needs a separate gateway mapping from full-box sensor state.
  - In `minisort-test-pt-0053`, source analysis says the configuration table's `Physical Location ID` needs a `-trigger-num` suffix for the grid/bin number.
  - The downloaded corrected tables contain rows such as `WALL-A-0-1-trigger-num` and `WALL-A-3-1-trigger-num`.
  - These rows use function code `FullBoxTriggersNumber` and MQTT topics such as `/FullBoxTriggersNumber/WALL-A-0-1`.
- Confirmed branch: CAN gateway must generate matching ODTM/mapping records.
  - Source analysis says CAN gateway lacked the corresponding configuration, causing mapping generation failure.
  - `odtm.log` shows later generated rows such as `add_odtm:1-node11-8464-0,/FullBoxTriggersNumber/WALL-A-0-1`.
  - `all.log` shows mapping records such as topic `/FullBoxTriggersNumber/WALL-A-0-1`, `node_id: 11`, `od_index: 0x2110`, `od_sub_index: 0x00`.
- Confirmed branch: the initial UI symptom matches repeated query/publish retry behavior.
  - Source text says opening the trigger window at `19:00:20` took about `8-15` minutes and did not show wall trigger counts.
  - Source text says changing `A0` trigger count at `19:06:01` spun until about `19:15:47`, failed, and had no popup.
  - OCR from screenshot `003-image-8f0b3b2268ac.png` shows repeated `hardwares-mgr: queryFullWatcherTriggersNumber result` from `2026-03-25 19:06` through `19:15`.
- Confirmed branch: after partial update, mapping consistency matters across central control and CAN gateway.
  - Source follow-up says CAN gateway was updated to `V3.0.12`, configuration table was reuploaded, and mapping/relationship table counts matched.
  - Then central control reimported the allcan table, but full-box triggering had no MQTT report and C/D door locking failed.
  - OCR from screenshots shows `responseTopicHookQueueMap not found` for `/CartInPositionStatus/WALL-A-0`, `/CartLockStatus/WALL-A-0`, `/CartInPositionStatus/WALL-B-0`, `/CartLockStatus/WALL-B-0`, `/CartInPositionStatus/WALL-B-3`, and `/CartLockStatus/WALL-B-3`.
  - OCR also shows `DOOR_IS_OPENED` / `ELECTROLOCK_LOCK_FAIL` for `M123-DOOR-A` and `M123-DOOR-B`.
- Resolution branch: after modifying CAN gateway configuration, door locking recovered; after refreshing mapping configuration, full-box triggering recovered.

## Evidence Needed

- Before-fix configuration table showing missing `-trigger-num` rows or missing `FullBoxTriggersNumber` function-code rows.
- CAN gateway version and config diff around update to `V3.0.12`.
- Raw central-control log lines for `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED` and the full request/response payload for editing the trigger count.
- Raw CAN gateway mapping generation logs before and after the fix.
- Mapping table and relationship table row counts before/after refresh.
- Final MQTT evidence showing `/FullBoxTriggersNumber/...` is published when full-box trigger count changes or full-box sensors trigger.

## Logs And Files To Inspect

- Case body: `cases/accepted/minisort-test/0053-IFAvwCj6QiAbcPk9Hi4c2iJ4n5c-2026-03-25-Mini-Plus-中控增加满箱传感器触发窗口配置--界面修改墙内满箱触发数量失败问题.md`.
- `assets/minisort-test-pt-0053/001-image-25f1b47006dd.jpg`: UI inspected; full-box trigger config window at `2026-03-25 19:05`, A wall visible, transparent/incorrect trigger-count display.
- `assets/minisort-test-pt-0053/002-image-4934ab6358a1.png`: UI inspected; `A0` selected and trigger count `2` chosen.
- `assets/minisort-test-pt-0053/003-image-8f0b3b2268ac.png`: central-control log screenshot inspected; repeated `queryFullWatcherTriggersNumber` until `19:15`.
- `assets/minisort-test-pt-0053/004-image-6b088964b805.png`: door-lock log screenshot inspected; `POST /api//hardware/electro-lock/control`, `DOOR_IS_OPENED`, and `ELECTROLOCK_LOCK_FAIL` for `M123-DOOR-A` and `M123-DOOR-B`.
- `assets/minisort-test-pt-0053/005-image-f5a856a8cc90.png`: log screenshot inspected; `responseTopicHookQueueMap not found` for cart status topics and `SEND_URGENT_FAILED` for urgent stop.
- `assets/minisort-test-pt-0053/006-source-EHl0bN8IpohoGsxRHDFcjRdPnlP.xlsx`: corrected A0-side table inspected via XLSX XML; row `42` contains `WALL-A-0-1-trigger-num`, `FullBoxTriggersNumber`, `/FullBoxTriggersNumber/WALL-A-0-1`.
- `assets/minisort-test-pt-0053/007-source-AXaUbdMpAoNXOdxtXEDcPSqOnFg.xlsx`: corrected A3-side table inspected via XLSX XML; row `42` contains `WALL-A-3-1-trigger-num`, `FullBoxTriggersNumber`, `/FullBoxTriggersNumber/WALL-A-3-1`.
- `assets/minisort-test-pt-0053/008-source-NQbVbNDtbowNw0xtpNScQM3Dncc.zip`: log bundle inspected; `odtm.log` contains `add_odtm:1-node11-8464-0,/FullBoxTriggersNumber/WALL-A-0-1`; `all.log` contains topic `/FullBoxTriggersNumber/WALL-A-0-1`, `node_id: 11`, `od_index: 0x2110`.

## Likely Causes

- `FullBoxTriggersNumber` mapping was missing or generated from an incorrect physical-location ID, so central control could not query/update trigger-count topics for wall bins.
- CAN gateway and central-control allcan configuration were not refreshed together, leaving mapping and relationship tables inconsistent.
- After gateway update, cart/door lock topics also lacked response-topic hook mappings until CAN gateway configuration was corrected and mappings were regenerated.
- The long UI loading and silent edit failure are symptoms of publish/query retry exhaustion, not a pure frontend display bug.

## Exclusion Checks

- Do not diagnose this as only UI frontend slowness if logs show repeated `queryFullWatcherTriggersNumber` or `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED`.
- Do not treat full-box sensor status topics `/FullWatcherForBox/...` as sufficient; trigger-count setting needs `/FullBoxTriggersNumber/...`.
- Do not edit only central-control data if CAN gateway `ODTM` / mapping rows are missing.
- Do not treat door-lock failure as mechanical lock failure until `/CartInPositionStatus`, `/CartLockStatus`, `/DoorLock`, and `/DoorStateSensor` response mappings are verified.
- Do not trust CAN gateway log timestamps blindly when logs include default or stale dates; correlate by topic, node, OD, and source document timeline.

## Confirmed Examples

- `minisort-test-pt-0053`: Mini Plus full-box sensor trigger configuration opened slowly, did not display seed-wall trigger counts, and changing `A0` trigger count to `2` failed after a long spinner. Source analysis says `Physical Location ID` needed `-trigger-num`; CAN gateway lacked configuration, causing mapping generation failure. Corrected tables include `WALL-A-0-1-trigger-num` / `WALL-A-3-1-trigger-num` with function `FullBoxTriggersNumber`; log bundle later shows `/FullBoxTriggersNumber/WALL-A-0-1` mapped to `node_id 11`, `od_index 0x2110`. After CAN gateway config changes and mapping refresh, door locking and full-box trigger recovered.

## Unresolved Examples

- `minisort-test-pt-0053`: before-fix table, raw `PUBLISH_FAIL_MAX_RETRY_TIMES_EXCEEDED` line, complete central-control request payload, and post-fix MQTT trigger proof are not local.

## Specialist Routing

- Start with `scheduler-traffic` for central-control UI/API, mapping table, relationship table, and retry behavior.
- Add `network-infra` for MQTT publish/query timeout and response-topic hook failures.
- Add `embedded-software` / `can-bus` for CAN gateway config, ODTM generation, node/OD mapping, and gateway version.
- Add `workstation` only if physical WLED/HLED workstation hardware behavior is directly involved; in this case the main evidence is wall sensor/door/cart mapping.
