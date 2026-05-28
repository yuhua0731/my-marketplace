# Codex Review Council

Codex Review Council keeps the normal Codex development flow and adds GitHub Copilot CLI as a second local reviewer only when explicitly requested.

It expects each user to authenticate their own Copilot CLI:

```bash
copilot login
copilot --version
```

Typical prompt:

```text
Use Copilot as a second reviewer for this change.
```
