# CV — Agustin Tomas Larghi

Source for my online résumé, rendered as a modern, two-column, print-friendly page and hosted on **GitHub Pages**.

**Live page:** <https://4gus71n.github.io/CV/CV.html>

---

## Contents

| File | Purpose |
| --- | --- |
| `CV.md` | The CV content — front matter (name, headline, contact, skills, languages) + body (summary, experience). **This is the file you edit.** |
| `_layouts/default.html` | Jekyll layout that turns `CV.md` into the page structure (sidebar + main column). |
| `assets/css/style.css` | All styling: colors, layout, responsive + print rules. |
| `assets/img/profile.jpg` | Profile photo shown in the sidebar. |
| `index.html` | Redirect so `…/CV/` points to `CV.html`. |
| `_config.yml` | Site metadata (title, description, base URL). |
| `deploy.sh` | One-command build + publish script (see below). |

## How it works

This is a **Jekyll** site. GitHub Pages automatically builds `main` on every push and serves the result — so the workflow is: *edit → push → live*.

The page is generated from `CV.md`. Keep everything in the front matter at the top structured as-is; Jekyll feeds it into `_layouts/default.html`:

```yaml
---
name: Agustin Tomas Larghi            # sidebar name
headline: Android · iOS · Mobile …    # subtitle under the name
photo: /assets/img/profile.jpg
contact:
  - type: email
    label: …
    url: mailto:…
skills:
  - name: Languages
    items: [Kotlin, Java, Swift]
languages:
  - name: Spanish
    level: Native
---
```

## Quick start (local)

If you want to preview changes before deploying:

```bash
# 1. Install Ruby + Jekyll + the GitHub Pages gem
gem install github-pages

# 2. Build the site locally (output goes to _site/)
jekyll build --baseurl "/CV"

# 3. Or serve it with live reload at http://localhost:4000/CV/CV.html
jekyll serve --baseurl "/CV"
```

On macOS with Homebrew, the Jekyll binary usually ends up in `~/.gem/ruby/<ver>/bin` — add it to your `PATH` if `jekyll` isn't found:

```bash
export PATH="$HOME/.gem/ruby/3.4.0/bin:/opt/homebrew/opt/ruby/bin:$PATH"
```

## Deploying

The easiest way is the included script — it builds locally (so errors surface before anything is published), commits, pushes, and then confirms the live site is up:

```bash
./deploy.sh                      # commit "Update CV" + push
./deploy.sh "Update headline"    # custom commit message
./deploy.sh --check              # only validate the local build, don't push
```

### Manually

```bash
git add -A
git commit -m "Update CV"
git push origin main
```

GitHub Pages picks it up within a minute or two — you can watch progress under **Actions → pages build and deployment** on the repo.

## Editing tips

- **Text / experience / bullets** → edit `CV.md` body directly.
- **Headline, contact links, skills, languages** → edit the front matter at the top of `CV.md`.
- **Colors & layout** → tweak the CSS variables at the top of `assets/css/style.css` (`--navy-*`, `--accent`, `--sidebar-w`, …).
- **Profile photo** → replace `assets/img/profile.jpg` (square crop works best; the avatar renders as a circle).

## Printing / PDF

The page is print-ready. Use your browser's **Print → Save as PDF** (A4 / Letter) — the sidebar keeps its dark background and each job entry stays on one page.
