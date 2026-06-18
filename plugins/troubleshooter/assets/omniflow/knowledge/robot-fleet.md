# OmniFlow Robot Fleet Knowledge

## Use For

- multiple robot roles interacting in one OmniFlow site
- Ant/Mantis-like handoff issues
- robot availability, assignment, collision, interlock, no-action symptoms

## Common Fault Branches

- scheduler assigned incompatible or stale tasks
- reservation/lock prevents expected movement
- one robot is blocked while another waits on a handoff dependency
- robot state differs between embedded controller and scheduler service
- recovery action cleared only one side of a coupled workflow

## Evidence To Request

- task timeline from scheduler/RCS/RMS/SAS/WAS or equivalent services
- robot IDs, positions, current states, target locations
- local robot logs around the event
- video showing sequence and physical position

## Multi-Fault Recovery Notes

- Long field threads can contain unrelated sequential faults. Keep branches separate until evidence links them.
- In legacy RF systems, an initial communication outage can be followed by robot-specific hardware/config/mechanical faults after recovery.
- Example `c113-0001` contains all of these branches:
  - scheduler command sent;
  - RF gateways disconnected and recovered;
  - one spider/S301 suspected offline;
  - LD2 CANopen `0x8120` / `33056` error passive;
  - motor node `0x3` SDO/enable failure;
  - blown fuse and burnt pull-box motor/connector;
  - duplicate motor ID after replacement;
  - over-tight belt tensioner causing torque alarm.
- Preserve recovery actions as evidence, because replacement, firmware flashing, or mechanical adjustment can introduce new fault modes.
