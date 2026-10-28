# Frontend workflow

Read this before any frontend, UI or visual design work, and follow the steps in order.

## Ground rules

- `DESIGN.md` (visual system) and `PRODUCT.md` (audience, purpose, voice) at the repo root are the only design sources of truth. No other theme or design-spec files.
- Tokens live in one code file (for example `src/styles/tokens.css`). `DESIGN.md` names it. Components read tokens; they never hard-code colours, fonts or spacing.
- Every skill below gets one job. Do not let one do another's job.

| Skill | Role | Never |
|---|---|---|
| `design-taste-frontend` (taste) | Art director: direction, idea, palette, type pairing, imagery | Run its full build loop here |
| `imagegen-frontend-web` | Optional image comps | Required, or used by an agent that can't generate images |
| `ui-ux-pro-max` | Systems engineer and validator: token scale, states, contrast, fonts, stack and UX rules | Override taste's palette or type; use `--persist` |
| `impeccable` | Quality gate: deterministic checks and fixes | Use `craft` or `shape` (that would be a second art director) |

## Step 0: product context

If `PRODUCT.md` does not exist, run `/impeccable init` first. It interviews the user and writes `PRODUCT.md`.

## Choose the path

- **New surface** (a new page, screen, flow, or a rebrand): full path below.
- **Change to an existing surface** (a component, a section, a fix): skip to the fast path.

## Full path (new surface)

### 1. Direction: taste

Load `design-taste-frontend`. Let it read the brief, deal its directions and pick one, and find the one-sentence idea. Stop there: do not let it build the page.

Record in `DESIGN.md › Direction`:

- the chosen direction and the one-sentence idea,
- palette and type pairing,
- imagery approach (taste's credited archive photos by default),
- what to avoid.

### 2. Images (optional)

`imagegen-frontend-web` is only for agents that can generate images. Even then, use it only if generated comps or images would beat taste's real archive photos for this surface. It's your call; note the choice in `DESIGN.md › Direction`.

### 3. System: ui-ux-pro-max

Use it to turn the direction into a complete system, not to choose a new look:

- token scale: spacing, radii, shadows, motion timing, interaction states (hover, focus, disabled), dark mode if needed;
- validation: text contrast (4.5:1 minimum), font availability, touch targets, reduced motion;
- stack-specific guidance and, for dashboards, chart types.

Its search script lives at `.agents/skills/ui-ux-pro-max/scripts/search.py`. Run it with `python3` (on Windows, `python` or `py -3`). Examples:

```
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "<product type>" --design-system -f markdown
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "<query>" --domain ux
python3 .agents/skills/ui-ux-pro-max/scripts/search.py "<query>" --stack <stack>
```

Never pass `--persist`. When its suggestions conflict with taste's palette or type, taste wins; only adjust a value to fix a failed check (contrast, legibility), and note why.

Write the result into `DESIGN.md › System` and into the single tokens file.

### 4. Build

Build from `DESIGN.md` and the tokens file, following `docs/agents/coding-standards.md`.

### 5. Gate: impeccable

Run, in order:

1. `npx impeccable detect <changed paths>` (exit 0 = clean, 2 = findings, 1 = could not scan).
2. `/impeccable audit <surface>` for a11y, performance and responsive checks.
3. `/impeccable polish <surface>` for the final pass against `DESIGN.md`.

Fix findings and re-run `detect` until clean, or until each remaining finding is a deliberate choice recorded in `DESIGN.md`.

## Fast path (change to an existing surface)

1. Read `DESIGN.md` and the tokens file.
2. Build the change using existing tokens and components. If the change needs a new token, add it to both `DESIGN.md › System` and the tokens file.
3. Gate: `npx impeccable detect <changed paths>` and `/impeccable polish <the changed area>`.

If the change really alters the look (new direction, new palette), it is not a fast-path change: use the full path.

## Video

Videos reuse `DESIGN.md` for brand. Load the `hyperframes` skill first; it covers the rest.
