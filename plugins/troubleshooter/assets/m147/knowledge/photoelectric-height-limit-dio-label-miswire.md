# Photoelectric Height-Limit Sensor DIO Label Miswire

## Symptoms

- M147/M149 photoelectric height-limit sensor signal cable is connected to the wrong DIO port.
- The IO signal plug should be connected to `DIO2`, but the actual plug and cable label indicate `DIO3`.
- The fault is a physical labeling/assembly mismatch, not primarily a software, CAN bus, or sensor logic failure.

## Fault Tree

- Confirmed branch: IO address table defines the expected DIO port.
  - `m147-pt-0177` IO table screenshot `M147_IO地址变量表_V01.xlsx` shows node type `ALL CAN-4`, bus `9352 BUS-1`, baud `1MHZ Bit/sec`, `CAN-ID (DEC) = 12`.
  - The same table highlights `DI02` / `DIO2` for `限高光电传感器`.
- Confirmed branch: field cable label points to the wrong DIO port.
  - Local images show cable label `P/N: M001-H5I-224B` and `CONN No.: DIO3`.
  - Source text says the IO-signal plug should be on `DIO2`, but was actually connected to `DIO3`, and the wire label was also `DIO3`.
- Likely branch: assembly or harness-label generation used the wrong connector number, causing technicians to follow the label into the wrong DIO socket.
- Blocked branch: downstream runtime symptom and recurrence scope.
  - No raw IO state log, CAN frame, gateway diagnostic, sensor trigger test, or corrected-label retest is present.

## Evidence Needed

- Corrected harness label or engineering drawing showing the intended connector number.
- Photo after correction showing the height-limit sensor signal cable on `DIO2`.
- IO/gateway log or manual input test proving `DIO2` changes when the height-limit sensor is triggered.
- Whether M149 has the same harness label batch and same IO table mapping.
- Production/QA scope: affected serial numbers, harness part numbers, and whether labels were generated from an old template.

## Logs And Files To Inspect

- `cases/needs-assets/m147/0177-GeQEwtD9wieDBtk03evcQBidn7c-2026-06-18-M147-M149光电限高传感器信号线标签错误导致插错.md`: source body.
- `assets/m147-pt-0177/retry-image-001-FMlYb0t2Uoz6H8xx636cE7ldnHc.png`: cable label visible as `P/N: M001-H5I-224B`, `CONN No.: DIO3`.
- `assets/m147-pt-0177/retry-image-002-UfpzbHhqIoIXZ7xJVL4c0drZnHh.png`: field photo showing `DIO2` and `DIO3` labels near the ALL-CAN-4 board and harness area.
- `assets/m147-pt-0177/retry-image-003-ARvtbe0yqoSae6xwHJqcxTQsnLf.png`: IO address table showing `限高光电传感器` on `DI02`, node `ALL CAN-4`, bus `9352 BUS-1`, `CAN-ID (DEC)=12`.
- Search terms: `限高光电传感器`, `DIO2`, `DIO3`, `CONN No.: DIO3`, `M001-H5I-224B`, `M147_IO地址变量表_V01.xlsx`, `ALL CAN-4`, `9352 BUS-1`, `CAN-ID (DEC) = 12`.

## Likely Causes

- Harness label was printed as `DIO3` while the current IO address table requires `DIO2`.
- Installation followed the incorrect cable label, so the height-limit sensor signal entered the wrong DIO channel.
- Engineering change or project variant mismatch was not propagated to label generation, assembly work instructions, or QA inspection.

## Exclusion Checks

- Do not replace the photoelectric height-limit sensor until IO table, cable label, and physical plug location have been compared.
- Do not call this a CAN electrical fault without CAN/IO state evidence; the visible evidence points to wrong DIO assignment.
- Exclude software configuration only after confirming the running configuration expects the same `DI02` mapping as the IO table.
- Exclude one-off installation error only after checking whether the cable label itself is wrong and whether M149 shares the same label batch.

## Confirmed Examples

- `m147-pt-0177`: visible source says the photoelectric height-limit sensor IO plug should connect to `DIO2`, but was actually connected to `DIO3`, and the wire label was also `DIO3`. Local photos confirm the `DIO3` label and IO table `DI02` mapping.

## Unresolved Examples

- `m147-pt-0177`: final correction photo, IO trigger retest, M149 scope, and raw IO/CAN evidence are not present.

## Specialist Routing

- Start with `vision-media` to compare physical plug, label text, and board socket position.
- Add `can-bus` for ALL-CAN-4 IO channel state only if runtime IO evidence is needed.
- Add `embedded-software` only if the running config or gateway firmware maps the IO table differently.
