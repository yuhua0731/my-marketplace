# S321 Fault Taxonomy

## Feeder And Scan Position Boundary

- `omnisort.s321.loading_belt_scan_stop_position_overlap`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: scan succeeds, robot reaches or finishes mission, but the parcel remains on the loading/last feeder segment.
  - Primary evidence: `0x02 包裹过扫描段` missing; `package_to_waiting_distance` is tiny but positive; `head_position_in_m` is just less than `vpoint_waiting_on_loading_belt_in_meter`.
  - Primary specialists: `embedded-software`, `scheduler-traffic`, `vision-media`.
  - Knowledge: `knowledge/loading-belt-scan-stop-position-overlap.md`.

## Evidence Status

- Treat scan-success logs as exclusion evidence against RFID/scanner read failure.
- Treat millimeter-level position gaps as meaningful when the state machine uses strict threshold crossing.
- Do not merge scan-success position-boundary failures with RFID low-read-rate cases.
