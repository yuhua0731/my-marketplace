# Troubleshooter

Codex plugin for C134 fault-tree troubleshooting.

## Contents

- `.codex-plugin/plugin.json`: plugin manifest
- `skills/leader`: main issue-packet diagnosis workflow
- `skills/*`: specialist workflows
- `assets/c134/`: taxonomy, plugin spec, asset intake plan, and C134 knowledge files
- `scripts/route_issue.py`: lightweight issue-packet router

## Use

Ask Codex to use `Troubleshooter` on a C134 issue packet, Feishu problem document, or local case/log bundle.

The leader skill classifies the symptom, loads matching knowledge, routes specialist branches, and returns:

- decision
- symptom
- evidence
- fault tree branch status
- root cause or operational conclusion
- next checks
- missing assets
