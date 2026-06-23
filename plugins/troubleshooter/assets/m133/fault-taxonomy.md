# M133 Fault Taxonomy

M133 belongs to OmniSort / 慧仓闪电播. Classify by observed failure chain, not by broad labels such as CAN when scanner, frontend, or business-flow evidence is stronger.

## Scanner And Feeder Input

- `scanner_focus_or_distance_mismatch`: barcode is readable only at a narrower physical distance, or small labels fail near the feeder surface.
- `manual_scan_trailing_byte_truncation`: manual/fixed scanner mode reads a full barcode, but parser normalization strips a valid final byte such as `0x65` (`e`) instead of only CR/LF/NUL terminators.
- `barcode_pool_association_timing`: scanned barcode, barcode pool, and parcel UUID do not align across `push barcode to pool`, `pull barcode from pool`, scan finish, and parcel leave.
- `scan_timeout_empty_barcode`: parcel reaches leave/mission creation with `barcode:""` after scan timeout.

## Frontend Result Handling

- `frontend_scan_success_display_mismatch`: backend reports `SCAN_SUCCESS` but UI shows red popup or failure.
- `duplicate_barcode_result_mapping`: backend returns `CONVEYOR_SCAN_BARCODE_EXISTS`; verify whether UI should show a specific duplicate-barcode state instead of generic error.

## Convey-Fail Mission Flow

- `order_not_found_convey_fail`: barcode lookup returns `ORDER_NOT_FOUND_IN_ORDER_GROUP`, then `createMissionByConveyFailAndSet` creates a `conveyFail` mission.
- `lack_params_convey_fail`: empty barcode or missing mission parameters return `LACK_PARAMS`, then create a `conveyFail` mission.
- `expected_abnormal_grid_throw`: robot carries an explicit `conveyFail` mission to the configured abnormal/fail grid; do not treat this as robot dispatch root cause by default.

## Lower Priority Branches

- `can_or_controller_fault`: use only when same-window logs show CAN heartbeat loss, SDO/PDO failure, conveyor-controller restart, or node-state errors.
- `robot_motion_fault`: use only when robot movement, arrival, loading, or throw logs fail independently of a deliberate convey-fail mission.
