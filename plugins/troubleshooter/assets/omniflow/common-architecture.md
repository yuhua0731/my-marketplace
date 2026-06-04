# OmniFlow Common Architecture

scope: product-line architecture for 慧仓穿云箭 / OmniFlow

## Common System Blocks

- storage rack / high-density 3D warehouse body
- mobile robots for tote movement and ground transport
- handling robots or mechanisms for rack-side operations when present
- conveyor or external logistics interface
- workstation / goods-to-person picking station
- WMS/SAP/customer system integration
- scheduler and traffic-control services
- robot embedded controllers, sensors, IO, CAN, and network clients
- site network, APs, MQTT/Kafka/service infrastructure

## Diagnostic Layers

1. business workflow: inbound, outbound, picking, buffering, replenishment
2. task/scheduler layer: orders, reservations, locks, robot availability
3. robot behavior layer: motion, localization, handling, power, connectivity
4. device/control layer: firmware state, sensors, IO, CAN, motor states
5. physical layer: tote placement, rack/track/station geometry, obstacles, damage
6. infrastructure layer: AP, server, message bus, disk/EFK/logging pressure

## C134 Relationship

C134 is an OmniFlow project corpus. C134's Ant, Mantis, workstation, scheduler, and network knowledge can inform other OmniFlow projects, but only as reusable patterns. Confirm site-specific facts before applying them.

