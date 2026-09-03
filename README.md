# CV — Agustin Tomas Larghi

Source for my online résumé, built with **RenderCV** and hosted on **GitHub Pages**.

**Live page:** <https://4gus71n.github.io/CV/CV.html>
**PDF:** <https://4gus71n.github.io/CV/CV.pdf>
**Plain text / Markdown:** <https://4gus71n.github.io/CV/CV.md>

---

## How it works

**`rendercv.yaml` is the single source of truth** — everything about the CV lives there
(name, headline, contact, summary, experience, skills, design theme).

On every push to `main`, a GitHub Action (`.github/workflows/render-cv.yml`) runs
RenderCV to generate `CV.html`, `CV.md` and `CV.pdf`, then deploys them to GitHub
Pages. So the workflow is: *edit YAML → push → site auto-updates*.

```
rendercv.yaml  ──(RenderCV, in CI)──▶  CV.html  +  CV.md  +  CV.pdf  ──▶  GitHub Pages
```

## Contents

| File | Purpose |
| --- | --- |
| `rendercv.yaml` | **The CV content.** Name, headline, contact, summary, experience, skills, theme. **This is the file you edit.** |
| `.github/workflows/render-cv.yml` | GitHub Action that renders the YAML and deploys to Pages on every push. |
| `CV.html` / `CV.md` / `CV.pdf` | Generated output (updated automatically by CI — don't hand-edit). |
| `assets/img/profile.jpg` | Profile photo referenced by `rendercv.yaml`. |
| `index.html` | Redirect so `…/CV/` points to `CV.html`. |
| `deploy.sh` | Optional local helper to render + push (see below). |

## Editing the CV

Edit `rendercv.yaml`. The structure is:

```yaml
cv:
  name: Agustin Tomas Larghi
  headline: Senior Mobile Engineer · Team Lead · Android · iOS · 14+ years
  email: agustin.tomas.larghi@gmail.com
  photo: assets/img/profile.jpg
  sections:
    Summary:          # free-text section
      - paragraph one…
    Experience:       # experience entries
      - company: Signos
        position: Senior Mobile Engineer · Team Lead
        start_date: 2023-04
        end_date: present
        highlights:
          - bullet point…
    Skills:           # one-line entries
      - label: Languages
        details: Kotlin, Java, Swift
design:
  theme: engineeringresumes   # ATS-first, single column
```

- Dates are `YYYY-MM` (or `YYYY-MM-DD`, `YYYY`). Use `present` for ongoing roles.
- Markdown is supported inside summaries and highlights.
- Section names are arbitrary — add/reorder sections freely.
- The active theme is `engineeringresumes` (r/EngineeringResumes best practices).
  Built-in alternatives: `classic`, `sb2nov`, `moderncv`, `harvard`, `engineeringclassic`, etc.

## Previewing locally

```bash
# 1. Install RenderCV
pip install "rendercv[full]"

# 2. Render (outputs land in rendercv_output/)
rendercv render rendercv.yaml
```

This produces `agustin_tomas_larghi_CV.pdf` and `.html` — open them to review.

## Deploying

Just commit and push — CI renders and deploys automatically:

```bash
git add -A
git commit -m "Update CV"
git push origin main
```

Watch progress under **Actions → Render CV and Deploy** on the repo.

### Optional: local helper script

```bash
./deploy.sh                      # render locally, commit "Update CV", push
./deploy.sh "Update headline"    # custom commit message
./deploy.sh --check              # only render locally, don't push
```

## Editing tips

- **Headline / contact / links** → top of `rendercv.yaml`.
- **Skills** → `Skills` section (one-line entries).
- **Profile photo** → replace `assets/img/profile.jpg` (square crop; renders top-left in the PDF header).
- **Look & feel** → change `design.theme`, or tweak the `design:` block (colors, fonts, margins are all configurable — see the commented defaults in `rendercv new`).
- **Don't edit `CV.html` / `CV.md` / `CV.pdf` by hand** — CI regenerates them from the YAML.

## ATS / printing

The `engineeringresumes` theme is built from r/EngineeringResumes best practices:
single column, no tables or icons in the body, parseable headings — so it survives
both ATS scanners and human review. `CV.pdf` prints cleanly on a single page.
