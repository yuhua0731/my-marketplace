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

