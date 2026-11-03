# Frontend workflow

Read this before any frontend, UI or visual design work, and follow the steps in order.

## Ground rules

- `DESIGN.md` (visual system) and `PRODUCT.md` (audience, purpose, voice) at the repo root are the only design sources of truth. No other theme or design-spec files.
- Tokens live in one code file (for example `src/styles/tokens.css`). `DESIGN.md` names it. Components read tokens; they never hard-code colours, fonts or spacing.
- Every skill below gets one job. Do not let one do another's job.

| Skill | Role | Never |
|---|---|---|
| `design-taste-frontend` (taste) | Art director and builder: direction, copy, build, browser checks, screenshot review | Run its full build loop for a small change |
| `imagegen-frontend-web` | Optional image comps | Required, or used by an agent that can't generate images |
| Emil Kowalski's skills | Second gate: reviews taste's motion and tests worst-case data. Also mobile feel and motion on edits | Choose the direction, palette or type; drive motion during a taste build; decide whether something should animate |
| `impeccable` | Third gate: deterministic checks and fixes | Use `craft` or `shape` (that would be a second art director) |

### Emil Kowalski's skills

`review-animations` doesn't load automatically. When a step below names it, read `.agents/skills/review-animations/SKILL.md` and follow it.

| Skill | Use it when |
|---|---|
| `review-animations` | Second gate: reviewing taste's motion. Also checking motion changed on the fast path |
| `break-ui` | Second gate: testing components that render real or user-supplied data |
| `emil-design-eng`, `animate` | Fast path only: changing or adding motion, since taste isn't driving |
| `mobile-native` | The surface is used on phones and has touch, full-screen layouts or fixed bars |
| `animation-performance` | An animation drops frames |
| `improve-animations`, `find-animation-opportunities` | The user asks for a motion audit or asks where motion would help |

### What Emil decides about motion

Emil's skills decide how motion moves, never whether it should exist. Their advice to delete or reduce motion because it lacks a purpose or runs too often does not apply here, on pages or app screens, so fix how that motion moves instead. Only remove motion if the user asks.

- **Speed:** UI motion such as hovers, presses, menus, modals and toasts stays under 300ms. This limit doesn't apply to showpiece motion: heroes, reveals, loops, taste's signature move and scroll scenes.
- **Feel:** apply his easing, springs, interruption and transform origins everywhere.
- **Performance and access:** fix dropped frames and include reduced-motion fallbacks. If an animation can't run smoothly after fixes, ask the user what to do.

## Step 0: product context

If `PRODUCT.md` does not exist, run `/impeccable init` first. It interviews the user and writes `PRODUCT.md`.

## Choose the path

- **New surface** (a new page, screen or flow) or **new direction** (a rebrand, a new palette): full path. This is the slow one, about 30 to 45 minutes.
- **Restyle** (same content and stack, new look or a tired page): restyle path.
- **Edit** (a component, a section, a fix, a revision): fast path. Do not draw a direction or start taste's build loop.

If unsure, use the cheapest path that fits, and move up only if the change really alters the look.

## Full path

Load `design-taste-frontend` and follow its run from start to finish. For dashboards, admin, settings and other app screens, use its app-screen route (`draw.mjs --app`, `inspect.mjs --app`).

Taste does not know about this repo's design files, so add these three things to its run.

### 1. Record the plan

After taste has drawn a direction, found the idea and drafted the copy, record in `DESIGN.md › Direction`:

- the chosen direction and the one-sentence idea,
- palette and type pairing,
- imagery approach (taste's credited archive photos by default),
- what to avoid.

`imagegen-frontend-web` is only for agents that can generate images. Even then, use it only if generated comps or images would beat taste's real archive photos for this surface. It's your call; note the choice in `DESIGN.md › Direction`.

### 2. Put tokens in one place

When taste starts its build with tokens, write them to the single tokens file, following `docs/agents/coding-standards.md`. Record the scale in `DESIGN.md › System`, including interaction states and dark mode if needed.

Taste builds the motion on its own; Emil's animation skills review it afterwards. Use `mobile-native` where the table above says it applies.

### 3. First gate: taste

Run taste's checks in the order it gives: `lint.mjs`, `inspect.mjs`, `scenes.mjs` if the page has scroll scenes, then the screenshot critique (three rounds at most). Inspect the production build if there is a build step. Fix every `FAIL`. A `FAIL` may only stay if the check does not suit this surface and the reason is recorded in `DESIGN.md`.

### 4. Second gate: Emil

1. Run `review-animations` on the motion taste built. It only reports, so apply the fixes yourself, following "What Emil decides about motion". Re-review once. Record anything still blocked, and why, in `DESIGN.md`.
2. Run `break-ui` on components that render real data. Skip it for static pages. Its demo-data toggle is dev-only and must not ship.

If these fixes touched the layout or motion, re-run `inspect.mjs` once.

### 5. Third gate: impeccable

Run, in order:

1. `npx impeccable detect <changed paths>` (exit 0 = clean, 2 = findings, 1 = could not scan).
2. `/impeccable audit <surface>` for a11y, performance and responsive checks.
3. `/impeccable polish <surface>` for the final pass against `DESIGN.md`.

Fix findings and re-run `detect` until clean, or until each remaining finding is a deliberate choice recorded in `DESIGN.md`. Impeccable fixes defects; it does not change the direction. If its changes touched the layout, re-run taste's `inspect.mjs` once.

## Restyle path

1. Load `design-taste-frontend` and use its redesign route: record the "before" with `inspect.mjs <url> --out .taste-skill/before`, lint the source and write the critique.
2. Keep the stack and content. Make changes in taste's order: type, colour, frame, states, then stock components.
3. Update `DESIGN.md` and the tokens file to match.
4. Run all three gates from the full path.

## Fast path

1. Read `DESIGN.md` and the tokens file.
2. Build the change using existing tokens and components. If the change needs a new token, add it to both `DESIGN.md › System` and the tokens file. If it adds or changes motion, load `emil-design-eng` or `animate`.
3. If the change is visible, load taste only for its house rules and run `inspect.mjs` once. Fix what this change caused, and mention anything older instead of fixing it. No draw, no critique rounds. Skip this step for changes with no visual effect.
4. If the change touched motion, run `review-animations` on the diff. If it changed how a component renders data, run `break-ui` on that component. Skip both otherwise.
5. Gate: `npx impeccable detect <changed paths>` and `/impeccable polish <the changed area>`.

If the change really alters the look, it is not a fast-path change: use the restyle path, or the full path for a new direction.

## Video

Videos reuse `DESIGN.md` for brand. Load the `hyperframes` skill first; it covers the rest.
