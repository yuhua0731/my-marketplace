# M129 Fault Taxonomy

## Lift Homing And Servo Control

- `omnisort.m129.leisai_lift_homing_torque_retry_failure`
  - Product line: OmniSort / 慧仓闪电播.
  - Typical symptom: No.1 lift module keeps moving downward during homing until physical limit, then reverses upward and can stall halfway.
  - Primary evidence: homing torque/retry log lines, Leisai drive model/firmware, CAN/controlword/status screenshots or raw candump, and source resolution pointing to Leisai firmware fix or known-good drive software replacement.
  - Primary specialists: `can-bus`, `embedded-software`, `vision-media`, `scheduler-traffic`.
  - Knowledge: `knowledge/leisai-lift-homing-torque-retry.md`.

## Evidence Status

- Treat screenshot CAN bytes as useful triage evidence, but require raw candump/pcap for exact protocol decoding.
- Treat `Err000 / 没有报警` in Motion Studio as "no persistent alarm visible", not proof that homing control was healthy.
- Do not diagnose all lift homing failures as Leisai firmware bugs; require torque/retry evidence, drive version context, or matching remediation.
