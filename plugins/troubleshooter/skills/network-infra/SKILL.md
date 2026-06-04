---
name: network-infra
description: Use when diagnosis involves robot/device disconnect, AP, NIC, dual-NIC failover, MQTT, RVS, Kafka, server, EasyBox, ping, pcap, EFK, disk I/O, or whole-site disconnects.
---

# Network Infrastructure Specialist

## Focus

- single robot versus whole-site scope
- both robot IPs pingable or not
- NIC/AP/EasyBox/uplink path
- MQTT disconnect and keepAlive
- RVS/Kafka/server symptoms
- disk I/O and EFK pressure
- pcap/dumpcap correlation

## Checks

- Scope first: one robot, one area, or whole site.
- Compare both robot IPs, MQTT, wormhole logs, NXP logs, and ping.
- If both IPs ping but MQTT breaks, inspect robot internal MQTT/NXP/wormhole path.
- If AP and EasyBox both drop, suspect upstream physical path.
- If whole site stops, inspect Kafka/server/disk I/O before individual robots.
- Preserve exact IPs and timestamps.

## Output

- connectivity scope
- network path branch status
- robot versus site/server conclusion
- missing pcap/ping/log evidence
