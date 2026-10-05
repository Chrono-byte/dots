---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your available models and writes an always-applied rule that overrides the skill defaults. Use for /skill:setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

Write `~/.pi/agent/pstack-models.md`, a pstack configuration file that every pstack orchestration skill reads before choosing models.

## Steps

### 1. Detect available models

Enumerate the model identifiers accepted by the Pi subagent/delegation tool in this session. That is the dependable source. If the harness exposes a models API or CLI that lists the user's entitled models, prefer it for completeness. If you cannot detect any, ask the user to paste the slugs they have access to. Never write a real slug you have not confirmed is available. The aliases `inherit-parent` and `auto` are always valid even though they are not detected slugs.

### 2. Load current state

The default role-to-model mapping is the rule shape shown in step 5 below. If `~/.pi/agent/pstack-models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer ask_user over free text. Offer these four options with these exact labels, and name the current budget when the rule records one.

- `unlimited — keep max`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Preserve configured model families, panel lists, and aliases. `unlimited` keeps each role's current effort; `large`, `medium`, and `small` target `xhigh`, `high`, and `medium`. When the harness exposes a separate reasoning setting, keep the model ID unchanged and pass the target through that supported setting when delegating. Only rewrite an effort suffix when the live catalog actually lists such model IDs. If the target is unavailable, use the closest supported effort at or below it. `inherit-parent` and `auto` inherit the parent model. Record the budget alongside the role lines so consuming skills can apply it.

**(c) Show the roles and confirm.** Show every role with its model, marking any real slug not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model, which is how Auto users stay on Auto) as the options. Prefer ask_user over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every real slug written must be in the detected set. `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again.

### 5. Write the rule

Write `~/.pi/agent/pstack-models.md` with a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels poteto-mode uses. Overwrite the whole file so re-runs stay idempotent. Shape:

```
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit the subagent model override). Alias entries in a panel list still count toward its fan-out.
# budget: unlimited (max)
feature, refactoring: openai-codex/gpt-5.6-luna
bug-fix: openai-codex/gpt-5.6-luna
perf-issue: openai-codex/gpt-5.6-luna
hillclimb: openai-codex/gpt-5.6-luna
judgment and prose: openai-codex/gpt-5.6-sol
hardest tasks: openai-codex/gpt-5.6-sol
how explorer: openai-codex/gpt-5.6-luna
how explainer: openai-codex/gpt-5.6-sol
why investigators: openai-codex/gpt-5.6-luna
why synthesizer: openai-codex/gpt-5.6-sol
reflect tooling: openai-codex/gpt-5.6-sol
reflect judgment, divergent, synthesizer: openai-codex/gpt-5.6-sol
arena runners: openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-luna
arena cross-judge pool: openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-luna
swarm workers: openai-codex/gpt-5.6-luna
architect runners: openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-luna
interrogate reviewers: openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-sol, openai-codex/gpt-5.6-luna
```

### 6. Confirm

Tell the user the configuration was written. Pstack skills read it when invoked; it is not a harness-wide always-applied rule. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /skill:create-verification-skill." On yes, invoke `/skill:create-verification-skill` (resolves wherever pstack is installed: workspace, user, or plugin). On no, move on without pushing.
