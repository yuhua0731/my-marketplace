# M137 Fault Taxonomy

## `omnisort.m137.allcandm_center_offset_default_after_mainboard_replacement`

- Product line: `omnisort`
- Corpus: `m137`
- Primary specialists: `robot-motion`, `vision-media`
- Secondary specialists: `scheduler-traffic`, `embedded-software`, `can-bus`
- Runtime knowledge: `m137/knowledge/allcandm-center-offset-default-after-mainboard-replacement.md`
- Pattern: after mainboard replacement, ALLCAN-DM center-offset config returns to default; during station forced discharge the robot can scan poorly, oscillate after arrival, move slightly sideways, and misalign with the lift module. Restore calibrated center offset, for this case `10` pixels, before treating it as lift mechanical alignment or generic CAN failure.
