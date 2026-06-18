# Troubleshooter

Codex plugin for team-specific fault-tree troubleshooting across projects and product lines.

C134 remains the first named OmniFlow project corpus. Its cases, taxonomy, playbooks, and specialist knowledge stay under `assets/c134/` so future corpora can be added without mixing project-specific assumptions.

## Contents

- `.codex-plugin/plugin.json`: plugin manifest
- `skills/leader`: main issue-packet diagnosis workflow
- `skills/*`: specialist workflows
- `assets/hc-robotics/`: company-level product portfolio and industry context
- `assets/omniflow/`: 慧仓穿云箭 / OmniFlow common product-line context
- `assets/<corpus>/`: publishable corpus taxonomy, playbook, and distilled knowledge files
- `assets/c134/`: C134 OmniFlow project corpus assets
- `scripts/route_issue.py`: lightweight issue-packet router

Training cases, JSONL, source indexes, reports, and asset queues stay in the training repository, not in the published plugin.

## Use

Ask Codex to use `Troubleshooter` on an issue packet, Feishu problem document, field report, or local case/log bundle. Include the project/product line when known.

The leader skill identifies company/product line/project/corpus, classifies the symptom, loads matching knowledge, routes specialist branches, and returns:

- decision
- company/product line/project/corpus
- symptom
- evidence
- fault tree branch status
- root cause or operational conclusion
- next checks
- missing assets
