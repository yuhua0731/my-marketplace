# OmniFlow Conveyor Integration Knowledge

## Use For

- OmniFlow connected to conveyors or external logistics equipment
- inbound/outbound handoff delay
- tote arrives but downstream equipment does not act
- upstream equipment sends unexpected state or duplicate command

## Common Fault Branches

- WMS/SAP/customer system task state mismatch
- conveyor ready/busy signal mismatch
- station or PLC IO state not synchronized with scheduler
- duplicate, stale, or missing handoff event
- physical tote present but software state absent, or the reverse

## Evidence To Request

- handoff timestamps across WMS/SAP, scheduler, PLC/conveyor, and robot logs
- IO/sensor state at transfer point
- video of conveyor/station behavior
- current task/order ID and tote ID

