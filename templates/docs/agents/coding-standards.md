# Coding standards

Read this before any code change. It merges Karpathy-inspired guidelines (multica-ai/andrej-karpathy-skills) with Ponytail (DietrichGebert/ponytail). Where they disagree, the rule marked **Overrides** wins.

## 1. Think before coding

- Read the code the change touches and trace the real flow before choosing a solution.
- State your assumptions. If the request is ambiguous, list the readings and ask; do not pick one silently.
- If a simpler approach exists than the one asked for, say so before building.
- If you are confused, stop and name what is unclear.

## 2. Simplicity first

Write the minimum that solves the task. Nothing speculative: no unrequested features, no single-use abstractions, no configurability nobody asked for.

Before writing new code, stop at the first rung that holds:

1. Does this need to exist at all?
2. Is it already in this codebase? Reuse it.
3. Does the standard library do it?
4. Is there a native platform feature (browser, OS, framework)?
5. Does an already-installed dependency do it? Do not add a new dependency for this.
6. Can it be one line?
7. Only then: the minimum code that works.

Test: would a senior engineer call this overcomplicated? If so, cut it.

**Overrides (never cut, whatever the rungs say):**

- Validation at trust boundaries (user input, network, files, env).
- Handling for data loss and real failure modes.
- Security (injection, auth, secrets, path traversal).
- Accessibility.

"No error handling for impossible cases" still applies, but only to cases that are actually impossible, not merely unlikely.

## 3. Surgical changes

- Touch only what the task needs. Every changed line should trace to the request.
- Match the existing style, even if you would do it differently.
- Do not refactor, reformat or "improve" adjacent code. Mention unrelated problems instead of fixing them.
- Clean up only what your change orphaned (imports, variables, functions). Leave pre-existing dead code unless asked.

## 4. Goal-driven execution

- Turn the task into a check you can run: "add validation" becomes "write tests for bad input, then make them pass"; "fix the bug" becomes "reproduce it in a test, then fix".
- Any logic with a branch, a loop, a parser, money or security leaves at least one small test behind.
- For multi-step work, state a short plan with a check per step, then loop until each check passes.

## 5. Reporting

End every reply that changed code with:

- what you skipped or did not check,
- any risk the user should know about.

Mark deliberate shortcuts in code with a `shortcut:` comment saying when to revisit it.

## Tools for this

- `/ponytail-review` reviews the current diff (bugs, security, load, missing tests, what to cut).
- `/ponytail-audit` runs the same checks across the whole repo, most important first.
- `/ponytail-debt` collects the `shortcut:` comments into a ledger.
- Matt Pocock's skills cover the wider loop: `tdd`, `diagnosing-bugs`, `code-review`, `codebase-design`.
