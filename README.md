# donor-cohort-risk-lab-r

Base-R operator surface for nonprofit, foundation, and mission-driven growth teams reviewing donor retention drift, upgrade softness, recency slippage, and stewardship gaps with synthetic demonstration data.

## What it shows

- real `R` added to the public Kinetic Gain language atlas for donor and audience-risk analysis
- a nonprofit / foundation-ops vertical proof that is statistical, not just dashboard-wrapped
- monetizable donor-health packets, appeal review templates, and fundraising evidence consulting hooks

## Screenshots

![Overview](./screenshots/01-overview.svg)
![Cohort lane](./screenshots/02-cohort-lane.svg)
![Appeal posture](./screenshots/03-appeal-posture.svg)
![Verification](./screenshots/04-verification.svg)

## Routes

- `/`
- `/cohort-lane/`
- `/retention-matrix/`
- `/appeal-posture/`
- `/verification/`
- `/docs/`

## Local development

```powershell
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\run_demo.R
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\generate_site.R
```

## Validation

```powershell
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' test\runtests.R
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\smoke_check.R
& 'C:\Program Files\R\R-4.6.0\bin\Rscript.exe' scripts\render_readme_assets.R
```

## Safety note

This repo uses synthetic demonstration data only. It does not contain real donor records or claim nonprofit compliance certification, audit readiness, or CRM production fitness.

## Why this matters

Kinetic Gain Embedded tie-back:

This repo proves Kinetic Gain can ship statistical donor-cohort operator surfaces in `R`, not just generic RevOps wrappers. The same base-R analysis drives cohort routes, appeal posture, smoke checks, and proof assets, which makes the language-atlas signal real.

## Commercial path

- `Template pack planned`
- `Consulting hook`

This can ladder into donor cohort review packets, fundraising retention decks, stewardship evidence packs, and embedded nonprofit growth-operations work for foundations and mission-driven teams.

---

Part of the [Kinetic Gain operator portfolio](https://kineticgain.com/) · docs: [suite.kineticgain.com](https://suite.kineticgain.com/) · live: [donors.kineticgain.com](https://donors.kineticgain.com/)
