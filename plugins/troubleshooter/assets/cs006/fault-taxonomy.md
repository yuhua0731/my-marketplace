# CS006 Fault Taxonomy

## Mantis Climb Power Feed

- `omniflow.cs006.mantis_climb_overtorque_rail_power_zero`
  - Product line: OmniFlow / 慧仓穿云箭.
  - Typical symptom: loaded Mantis upward climb emergency-stops with `NODE402 OVERTORQUE` and following error while supercapacitor voltage drops.
  - Primary evidence: load/speed/direction, NXP overtorque/following-error log, capacitor voltage/current waveform, rail-power measurement, cabinet neutral, series-supply polarity, and post-fix retest.
  - Primary specialists: `mantis-handling`, `embedded-software`, `vision-media`.
  - Secondary specialists: `can-bus`, `boost-module`.
  - Knowledge: `knowledge/mantis-climb-overtorque-rail-power-zero.md`.

## Evidence Status

- Treat Mantis climb overtorque under load as a power-feed branch until rail power, neutral wiring, supply polarity, and supercapacitor voltage are checked.
- Generic C134 Mantis load/tote rules do not replace CS006 rail-power evidence.
- `OVERTORQUE` and `following error` are drive symptoms; confirm whether they are caused by external supply collapse before replacing motor hardware.
