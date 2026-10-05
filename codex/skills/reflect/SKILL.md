---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
---

# Reflect

Read the `# budget` line from the harness’s pstack model configuration along with the role values. Apply its effort target through the delegation tool’s supported reasoning setting; preserve valid model IDs and inherit the parent model for `auto` or `inherit-parent`.


Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

Invoke when the user says "reflect" or "$reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent locates its session under `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` (or `~/.codex/archived_sessions/`). Inspect newest files first, require `session_meta.payload.cwd` to equal the current workspace, parse entries by type, and match the opening user prompt. If no transcript resolves, write a tight session digest and pass that instead.

### 2. Spawn three reviewers in parallel

One message, three subagent delegation calls, a general-purpose subagent, with `model` set as below, agent mode (file-editing prohibited for read-only work). Reviewers need MCP access for context lookups (tickets, chat threads, observability traces referenced in the transcript). Keep MCP access available, and prohibit file edits through the prompt for read-only roles.

Each reviewer and the synthesizer name a role line in the `pstack-models.md` rule and a default. Set `model` to that line's value, or to the default if the rule or the line is missing. Leave `model` unset when the value is `auto` or `inherit-parent`. If the subagent/delegation tool rejects a slug, use the default and say so. If it rejects the default, use the closest valid slug of the same family from its error message.

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `gpt-5.6-sol` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `gpt-5.6-sol` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `gpt-5.6-sol` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the subagent result.

### 3. Synthesize

One subagent delegation call, a general-purpose subagent, with `model` from the `reflect judgment, divergent, synthesizer` line (default `gpt-5.6-sol`), agent mode (file-editing prohibited for read-only work). The synthesizer's quality check includes spot-verifying citations, which can require MCP access. Keep MCP access available, and prohibit file edits through the prompt for read-only roles. Use `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. The synthesizer returns a structured Accepted / Rejected / Backlog list.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to Codex’s skill-authoring conventions and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `create-skill` and run its description-optimization loop.
- `new skill via create-skill: <kebab-name>`: hand creation to `create-skill`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
