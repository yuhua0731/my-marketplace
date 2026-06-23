# Mantis Test Fault Taxonomy

## Climbing Gear-Rack Mechanical Wear

- `omniflow.mantis_test.climbing_gear_rack_plastic_pair_wear_noise`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: Mantis spider mechanism makes `哐哐哐` / `哐当哐当` mechanical noise during up/down climbing after endurance running.
  - Primary evidence: climbing rack/gear wear; abnormal gear-rack meshing; rack material `PA66` and gear material `MC901` form an all-plastic nylon-on-nylon transmission pair; local photos show wear residue/grooves/scoring on gear/shaft and nearby rotating interfaces.
  - Primary specialists: `mantis-handling`, `vision-media`.
  - Secondary specialists: `embedded-software`, `can-bus` only when decoded motor/CAN evidence exists.
  - Knowledge: `knowledge/climbing-gear-rack-nylon-wear-noise.md`.

## Fork Arm CAN Harness

- `omniflow.mantis_test.can2_fork_arm_belt_harness_intermittent_canl`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: Mantis 2.6.0 CAN2 resistance jumps between `60Ω` and `120Ω`, especially when the left fork arm is pressed, pushed, or moved.
  - Primary evidence: ALLCAN-8_580 termination switch mis-touch excluded; board-side socket resistance remains stable after disconnecting the fork-arm communication belt harness; harness continuity test shows CANH normal but CANL beeper intermittent during fork-arm movement.
  - Primary specialists: `can-bus`, `mantis-handling`, `vision-media`.
  - Knowledge: `knowledge/can2-fork-arm-belt-harness-intermittent-canl.md`.

## Climb Motor Brake Holding Margin

- `omniflow.mantis_test.climb_motor_brake_holding_margin`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: Mantis 2.6.0 spider/slide descends slowly after emergency stop or power-off under high load; one side or motor can slip more obviously.
  - Primary evidence: load-step table, power-off manual-press video, motor/brake datasheets, reducer ratio, load rate or safety-factor calculation, and same-condition retest after motor/brake change.
  - Primary specialists: `mantis-handling`, `vision-media`.
  - Secondary specialists: `embedded-software`, `can-bus` only when brake/drive command or status logs are available.
  - Knowledge: `knowledge/climb-motor-brake-holding-margin.md`.

## Evidence Status

- For Mantis climbing noise after endurance tests, inspect gear/rack wear, material pairing, backlash, alignment, and bearing/shaft support before replacing motors or boards.
- For Mantis CAN2 resistance anomalies, perform dynamic measurements while moving the fork arm; static resistance can miss intermittent harness faults.
- For Mantis descent after emergency stop or power-off, inspect brake holding torque, reducer ratio, side load sharing, and load safety margin before diagnosing software hold.
- Measure board sockets and the removed harness separately before replacing ALLCAN boards.
- Record CANH/CANL separately; a single intermittent conductor can destabilize the whole CAN2 resistance reading.
