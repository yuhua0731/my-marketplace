# OmniFlow Network Knowledge

## Use For

- robot disconnect
- AP/EasyBox/NIC failover
- MQTT/RVS/Kafka connection symptoms
- site-wide disconnect or service instability

## Common Fault Branches

- individual robot network issue
- AP coverage or roaming issue
- site/server service disruption
- message bus lag or disconnect
- server disk/EFK/logging pressure affecting service behavior

## Evidence To Request

- affected robot/device list
- disconnect/reconnect timestamps
- AP, ping, MQTT/Kafka/RVS logs
- scope: one robot, one area, one robot type, or whole site
- server resource and disk/logging status

## Legacy RF Version Notes

- For C113/legacy RF versions, do not assume MQTT/Wi-Fi first. The delivery chain is `scheduler -> messenger/ZMQ -> RF gateway -> robot`.
- A scheduler `/robot/cmd/<id>` log only proves the upper layer issued the request; it does not prove messenger/RF/robot delivery.
- If multiple RF gateways disconnect together, check cabinet/UPS power, gateway NIC/link, and RF gateway process before robot firmware.
- Preserve exact command timestamp and `message_id`; use them to search messenger and RF gateway logs.
- Example `c113-0001`: `/robot/cmd/104` was sent at `2026-04-28 14:05:23.466`, but two RF gateways `10.0.64.165` and `10.0.64.166` were later found disconnected and recovered after cabinet/UPS power-cycle.
