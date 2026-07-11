Here's the full command with both changes folded in:

```markdown
---
description: Hand the current plan to Codex CLI to implement in the background, poll until done without timing out, then review the result
argument-hint: [optional path-to-plan-file]
allowed-tools: Bash, Read, Grep, Glob
---

A plan has already been drafted. Your job: hand it to Codex CLI for implementation, wait for it to finish without letting any single Bash call time out, then review the result yourself.

## Step 0 — Identify the plan

- If $ARGUMENTS is non-empty, treat it as a file path and use that plan.
- Otherwise, default to the plan you most recently drafted earlier in this conversation. Don't go searching the repo for a plan file — the plan in your own context is the one I mean.
- If that plan hasn't been written to disk yet, write it now:
  - `mkdir -p .claude/plans`
  - Pick a short-task-name: 2-4 words, lowercase, hyphenated, describing the task (e.g. `add-rate-limiting`, `fix-auth-redirect`).
  - Write the plan to `.claude/plans/<short-task-name>.md`. If a plan from this same conversation was already written to disk earlier in this session, reuse that exact path instead of creating a new one.
- Only ask me where the plan is if neither of the above applies — i.e. no argument was given and you have no plan from this conversation to fall back on.

## Step 1 — Launch Codex in the background

Create a unique scratch directory for this run's log and PID file (not the repo — keeps it out of git entirely):

```bash
RUN_DIR=$(mktemp -d -t codex-implement-XXXXXX)
nohup codex exec --sandbox workspace-write --skip-git-repo-check \
  "Implement the plan described in the file at: <plan path from Step 0>. Follow it exactly, make the smallest reasonable changes, and add tests where appropriate." \
  > "$RUN_DIR/codex_run.log" 2>&1 &
echo $! > "$RUN_DIR/codex.pid"
```

Confirm the PID file was written and tell me the PID, which plan you're using, and its path.

## Step 2 — Poll until it's done

Never run one long blocking sleep. Instead, repeat short checks like this, with a short sleep (20-30s) between them:

```bash
if kill -0 $(cat "$RUN_DIR/codex.pid") 2>/dev/null; then echo "still running"; else echo "done"; fi
tail -n 20 "$RUN_DIR/codex_run.log"
```

Keep calling this yourself, check after check, until the process is no longer running. Don't ask for permission to keep going — just keep polling. Give me a brief one-line status update every few checks (e.g. "still running, ~4 min elapsed") so I know you're not stuck, but don't dump the full log every time.

## Step 3 — Confirm how it finished

Once the PID is gone, print the last ~50 lines of `"$RUN_DIR/codex_run.log"`. If Codex failed, crashed, or errored out, stop here and report what happened instead of proceeding to review.

## Step 4 — Review the result

If Codex finished successfully:
1. Run `git status` and `git diff` to see everything it changed.
2. Compare the diff against the plan at `.claude/plans/<short-task-name>.md` — flag anything planned but not implemented, and anything implemented but not in the plan.
3. Review the actual code for correctness, edge cases, and consistency with the rest of the codebase.
4. If tests exist, run them and report pass/fail. If the plan called for tests and none were added, note that.
5. Summarize: what was done, what concerns you, what (if anything) needs follow-up.

Do not commit anything — just report back.

## Extra notes

Note that Codex running in background will probably bet blocked on environment limits (its sandbox couldn't reach Postgres to run tests, and .git iwll read-only so cannot  commit).
This is expected, so work around that or don't worry Codex about these tasks.

