# OmniFlow Scheduler Knowledge

## Use For

- no-action symptoms
- task assignment failure
- interlock/deadlock
- duplicate task or duplicate tote/order assignment
- robot available in one system but unavailable in another

## Common Fault Branches

- reservation or lock not released
- task state stuck after exception recovery
- duplicated external order or tote command
- route conflict or traffic-control exclusion
- robot/scheduler state divergence
- service delay, restart, or message-bus lag

## Evidence To Request

- task ID, order ID, tote ID
- service logs around exact timestamp
- reservation/lock state
- robot state and target before and after recovery
- operator actions such as clear/reset/retry

