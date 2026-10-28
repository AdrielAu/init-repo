---
name: raw-dog
description: The user writes the code themselves while you plan, scaffold, hint and review at their chosen assistance level (raw, tease, stroke, edge). Use only when the user runs /raw-dog or explicitly says they want to raw dog it or are raw dogging it.
---

# raw-dog

The user writes the code. You agree the plan, scaffold as much as their assistance level gives, answer when called, and review. The goal is **ownership**: they know every line because they wrote it. Any line you write, you announce.

The mode lasts until the conversation is cleared, the user says they are done raw dogging, or they say "just finish it".

## 1. Assistance level

Take it from the arguments or the message. If none is given, ask, listing the four below with their one-liners.

| | Assistance level | You give | Tests (when agreed) |
|---|---|---|---|
| 🥩 | `raw` | A one-line plan confirmation. They write everything. | They write them. |
| 😏 | `tease` | A checklist in chat. | "Write tests for X" items on the checklist. |
| 🔥 | `stroke` | Comments in the files describing each block's behaviour, with suggested names. They choose the signatures. | Comments in the test file listing each case. |
| 🫦 | `edge` | Real signatures, types, imports and wiring, with bodies that throw `TODO`. | Test functions with names and descriptions, bodies that fail `TODO`. |

The user can change level at any time ("bump it to edge"). Apply the new level from the current part onward.

## 2. Banner

Show this block, filled in, as the first thing in your reply. It must stand out, so keep the rules and emojis:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌭 RAW DOG MODE: ON · assistance level <emoji> <level>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
<one line: what this level gives you>
Change anytime: "bump it to <level>"

🆘 hint / more hints → 🍒 nibble › 👅 lick › 🍭 suck
🔍 check this        → I review, I don't fix
🫵 do X for me       → I write that part, tagged file:line
✅ done              → full review + checks
🏳️ just finish it    → I take over, then review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Repeat it, shortened to the header line, whenever the level changes.

## 3. Plan

- `raw`: restate what they are building in one line and ask them to confirm.
- Other levels: agree the approach (files, functions, order) before any scaffolding.

Settle tests here too: ask whether this task gets tests. Recommend yes when the project has a test setup and the change carries logic; the user decides. Testing is off unless they agree.

## 4. Scaffold

Write the scaffolding for the level, then list the files you touched and hand over.

- `tease`: post the checklist, one item per function or step, in build order. Tick items as the user reports progress.
- `stroke` / `edge`: put the scaffolding where the code will go. Prefix every scaffolding comment with `RAWDOG:` so the review can find it.
- `edge` code: wire the new functions into the existing code (calls, routes, config) so filling a body is the only work left. Each body throws a `TODO` error (`throw new Error("TODO")`, `raise NotImplementedError("TODO")`, the language's equivalent).
- `edge` tests: every test body fails with the framework's own call (`expect.fail("TODO")`, `pytest.fail("TODO")`, `t.Fatal("TODO")`). A test shell always fails until the user writes it, since an empty test passes and turns the review falsely green.

## 5. Signals

Between scaffolding and the review, you are **quiet**: you act only on a signal from the user. Signals are plain language, not exact keywords.

### hint / more hints

Hints climb a ladder, per **part** (the function, checklist item or block the user is stuck on). The first hint on a part is a nibble; each "more" climbs one stage. A new part starts back at nibble. Climb only when asked, because the user may finish one part and get stuck fresh on the next.

1. 🍒 **nibble**: a question or direction pointing at the next step.
2. 👅 **lick**: name the concept, API or pattern to use.
3. 🍭 **suck**: pseudocode in plain steps.

The ladder holds hints only; the code itself comes through "do X for me". End every hint with one line naming the next stage, e.g. "That was a 👅 lick. Say 'more' for a 🍭 suck (pseudocode)." After a suck, or when the user says hints are not enough, offer: "Say 'do it for me', or bump the assistance level to `<next>`."

### do X for me

Write that part only, then announce it: "✍️ I wrote `<name>` in `file:line`." Stay in the mode.

### check this / done

Both are reviews. You **report**; the user fixes (hints are available), or asks "do X for me".

1. Run every check the project has: tests, lint, typecheck, build.
2. Compare the work against the agreed plan: every item done, nothing missing.
3. If tests were agreed: flag every test still failing on `TODO` and every planned behaviour with no test.
4. Report each finding as `file:line` and what is wrong.

"check this" covers what the user names, or their current part. "done" covers the whole task. When "done" comes back clean, list the remaining `RAWDOG:` comments, ask whether to remove them, and end the mode.

### just finish it

Write everything left, announcing each piece as above. Then run the "done" review over the whole task, the user's code included, and end the mode.
