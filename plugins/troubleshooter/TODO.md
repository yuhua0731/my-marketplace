# Troubleshooter TODO

- [ ] Add plugin-native high-similarity case lookup.
  - Publish lightweight, non-raw case anchors under `assets/<corpus>/case-anchors.json`.
  - Suggested fields: `case_id`, `symptom`, `device_family`, `action_phase`, `log_markers`, `recovery_pattern`, `root_cause_status`, `knowledge_file`.
  - Add `scripts/search_similar_cases.py` to query same-corpus and same-product-line anchors.
  - Use results only to support `likely` hypotheses when direct proof is missing; do not treat historical similarity as confirmed root cause.
  - Keep raw cases, logs, attachments, training packs, JSONL, and asset queues out of published plugin assets.
