# MiniSort IO Address Table CAN Termination Ambiguity

source_set: `minisort-test-pt-0004`
case_count: 1 focused IO/CAN documentation quality case
status: runtime routing rules for ALLCAN-4 terminal-resistor and same-bus node table ambiguity

## Symptoms

- Debugging manual or IO address variable table does not state whether ALLCAN-4 terminal-resistor DIP switch should be on or off.
- `9352-1` and `9352-2` node connection descriptions are hard to understand.
- Same physical CAN line is split into separate tabs such as `1#9352 BUS-1-1` and `1#9352 BUS-1-2`, making it look like two buses.

## Fault Tree

1. Treat as documentation/topology ambiguity first.
   - `minisort-test-pt-0004`: M131 debugging could not determine ALLCAN-4 terminal-resistor switch state from the manual or IO address table.
   - Source says `1-1` and `1-2` are the same CAN bus but were separated, causing misunderstanding.
2. CAN hardware risk is downstream.
   - Wrong termination instructions can create later CAN instability or node-discovery confusion.
   - This case has no runtime CAN logs, heartbeat loss, or SDO error evidence.
3. Resolution pattern.
   - Add clear ALLCAN-4 terminal-resistor on/off instructions to the IO definition table.
   - Put same-CAN-line node configuration descriptions in the same sheet.

## Evidence Needed

- Editable `M131_IO地址变量表_V01.xlsx` and updated version diff.
- Physical CAN topology diagram for `9352-1` / `9352-2`.
- ALLCAN-4 DIP switch mapping: switch position, termination on/off, and node role.
- Review checklist proving same-bus nodes are grouped or explicitly cross-referenced.
- Field-debug confirmation that the revised table removes the ambiguity.

## Logs And Files To Inspect

- `cases/accepted/minisort-test/0004-AAYzwTg4uiHbeZkiOOBcurx9nsc-2026-04-01-迷你播IO地址变量表问题.md`
- `assets/minisort-test-pt-0004/001-image-711d31beb87b.png`
  - `1928x1616`, `514499` bytes.
  - Shows `M131_IO地址变量表_V01.xlsx`, visible IO configuration rows, and sheet tabs `说明`, `1#9352 BUS-1-1`, `1#9352 BUS-1-2`.
- Search terms: `M131`, `IO地址变量表`, `ALLCAN-4`, `终端电阻`, `拨码开关`, `9352-1`, `9352-2`, `1#9352 BUS-1-1`, `1#9352 BUS-1-2`, `同一条CAN线`, `同一个sheet页`.

## Likely Causes

- IO address table omitted terminal-resistor state instructions for ALLCAN-4.
- Table organization split one CAN bus across multiple sheets, making topology ambiguous.
- Debugging material optimized for signal listing but not for wiring/topology decisions.

## Exclusion Checks

- Do not route to runtime CAN failure without CAN captures, heartbeat loss, SDO aborts, or node scan errors.
- Do not route to generic Mini/M123 scheduler issues from the word `迷你播`.
- Do not treat a screenshot as sufficient documentation proof; use the actual spreadsheet for final validation.
- Do not let sheet naming imply separate buses when the nodes are on one physical CAN line.

## Confirmed Examples

- `minisort-test-pt-0004`: M131 debugging found that both the debugging manual and IO address table failed to clarify ALLCAN-4 terminal-resistor DIP state. The IO table also split `1#9352 BUS-1-1` and `1#9352 BUS-1-2` into separate tabs despite being the same CAN line. Resolution was to add ALLCAN-4 terminal-resistor on/off instructions and place same-CAN-line node configuration in the same sheet.

## Unresolved Examples

- `minisort-test-pt-0004`: missing actual `.xlsx`, before/after diff, topology diagram, and field validation after documentation update.

## Specialist Routing

- Start with `can-bus` for CAN topology, termination, node grouping, and bus role.
- Add `embedded-software` only when IO mapping affects controller behavior or generated configuration.
- Add `vision-media` for screenshot/table review, but request editable source files for final documentation validation.
