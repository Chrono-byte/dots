---
name: no-comments
description: "Review comments, remove accepted noise, identify code that should express its constraints, and offer in-scope encodings. Use for no-comments or a comment review."
disable-model-invocation: true
---

# No comments

Review comments using the bundled [comment review rules](references/comment-review.md). Use an independent reviewer and act on accepted findings.

## Scope

Use the caller's files or diff. Otherwise use the current diff against the base branch, default `main`, including the working tree.

## Steps

1. Read `references/comment-review.md` and launch one native Pi subagent using the available Pi subagent tool. Give it a self-contained prompt containing the scope, baseline diff command, exact path to these rules, and a read-only constraint: do not edit files. Require a proposed patch, evidence for exceptions, and in-scope refactor flags. Do not assume a named Comment Sicko agent, Cursor agent registry, or `subagent_type` exists. If delegation is unavailable, apply the same rules in a separate read-only review pass and disclose that limitation.
2. Inspect its report and proposed patch before applying deletions. Treat the reviewer’s claims as untrusted until checked against the scoped code. Reject application-code edits, scope escapes, exception-protected deletions, misstated `MUST KILL` reasons, and flags that treat kept intentional code as guilty. Reshape flags on our-code surprises stay actionable. Do not restore those comments. A keep survives only with proof it is about something we cannot change. Audit missed scoped lint and TypeScript suppressions. Correctness or safety suppressions stay actionable `MUST KILL`s. Restore deletions only with exact exceptions and scoped proof. Before accepting thin `IMPORTANT` or `do not remove` kills or keeps, run `/skill:how` or `/skill:why` on their symbol. If a kill is ambiguous, do not restore. If a keep is refuted or still ambiguous, delete it. Discard a rejected proposed patch and rerun once with the failure named. Reject a second, report it open, and fail `/skill:no-comments`.
3. Fix trivial accepted flags directly by deleting a dead path, dropping a parameter, or using the real API. If any fix needs a shape, run `/skill:architect` once for the accepted set and surrounding code. Stop at the sketch. Architect shapes. Step 4 implements.
4. Implement the smallest root-cause fix in scope. Remove every named workaround. If the root cause is out of scope, land the smallest in-scope fix and report the rest open. The **principle-fix-root-causes** and **principle-redesign-from-first-principles** skills guide intent only. Neither authorizes widening the fence nor fixing instances outside it. Never bolt on symptom guards.
5. Constraint comments say `do not remove`, `do not change wording`, or `talk to X before changing`. Leave keeps about things we cannot change. Offer the cheapest in-scope type, runtime, test, or CI lint. Wait for interactive approval. Unattended and eval require caller pre-approval. If approved, encode then delete. Otherwise delete, report the constraint open, and sketch out-of-scope work.
6. Report the deletion count, restored comments, reruns, architect sketch, fixes, encoding offers, encodings, unenforced constraints, and other open work.
