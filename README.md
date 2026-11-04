# R for marine sciences

*by Aroo Falinirina* — version 3.1 (2026-11)

A bilingual (EN/FR), self-study R course built as an **R Markdown website**, with
student login, saved progress, scored quizzes, levels that unlock, certificates
and a watermark. All data are **simulated**, each with a description of how it
was "collected".

| Level | Sessions | Topics | Status |
|---|---|---|---|
| Beginner | 0–10 (≈ 31 h) | install R, vectors, data frames, cleaning, descriptive statistics, base R graphs, dplyr/ggplot2; coral & seagrass data | done |
| Intermediate | I0–I13 (≈ 41 h) | real files (Excel), dates, reshaping, joins, survey data, loops, functions, ggplot2, distributions & p-values, tests (t, Wilcoxon, χ², Fisher, Pearson, Spearman), maps; seaweed and sea-cucumber farming, water quality, household survey | done |
| Advanced | — | reproducible projects (renv, Git), R Markdown/Quarto reports, sf/terra/tmap | coming soon |

Each level has a practice session, a final project, a cheatsheet page, three slide
decks (≈ 3 h, in French) and a printable PDF kit (kept in the project, not published).

---

## 1. What is in this folder

```
r-course-beginner/
├── r-course-beginner.Rproj   <- open this in RStudio
├── _site.yml                 <- navbar, theme, output folder (docs/), files never published
├── index.Rmd                 <- home page: one dashboard per level
├── 00-installation.Rmd … 10-final-project.Rmd     <- Beginner (09 = practice)
├── i00-import.Rmd … i13-final-project.Rmd         <- Intermediate (i12 = practice)
├── advanced.Rmd              <- "coming soon" page
├── cheatsheet.Rmd, cheatsheet-intermediate.Rmd    <- one cheatsheet per level
├── help.Rmd, certificate.Rmd, common-errors.Rmd, whats-new.Rmd
├── assets/
│   ├── config.js             <- THE file to edit: title, author, Google Script URL, levels, pages
│   ├── course.js             <- login, progress, quizzes, levels, certificates (commented)
│   ├── course.css            <- the look (commented)
│   ├── quiz_index.json/.js   <- list of all quizzes and their points (built by R/build_site.R)
│   └── img/*.svg             <- illustrations; img/login-bg.svg = login background
├── R/
│   ├── build_site.R          <- builds the website into docs/ (USE THIS)
│   ├── course_helpers.R      <- quiz(), q_num(), q_mcq(), q_text(), fig_svg(), dl()
│   ├── simulate_data.R       <- Beginner datasets
│   ├── simulate_intermediate.R  <- Intermediate datasets
│   ├── beginner_pipeline.R   <- checkpoint tables of Sessions 3–6 (B03…B06)
│   ├── intermediate_pipeline.R  <- cleaning steps of I0–I4 + write_checkpoints()
│   ├── answers_i12.R, answers_i13.R  <- hidden quiz answers of the practice / project
│   ├── make_accounts.R       <- usernames + passwords for your students
│   └── make_pdf_kit.R        <- printable PDF kit, with watermark
├── data/                     <- CSV/XLSX files + zips; data/checkpoints/ = clean tables per session
├── templates/                <- check_setup.R, final project templates (downloadable)
├── slides/                   <- 6 slide decks (3 per level), see section 8
├── pdf_kit/                  <- pdf.css + the PDFs you generate (never published)
├── apps-script/Code.gs       <- the Google Apps Script "backend"
└── docs/                     <- THE BUILT WEBSITE (what GitHub publishes)
```

`R/`, `apps-script/`, `slides/`, `pdf_kit/`, `_intermediate/` and `README.md` are **never published** (`exclude:` in `_site.yml`).

## 2. Build the site

1. Open `r-course-beginner.Rproj` in RStudio.
2. Install once:
   `install.packages(c("rmarkdown", "knitr", "jsonlite", "readxl", "dplyr", "tidyr", "lubridate", "stringr", "ggplot2", "patchwork"))`
   (optional: `"sf"` for the map preview in I11, `"pagedown"` for the PDF kit).
3. *(Optional)* regenerate the data: `source("R/simulate_data.R")`, `source("R/simulate_intermediate.R")`,
   then the checkpoint files: `source("R/beginner_pipeline.R"); write_checkpoints_beginner()` and
   `source("R/intermediate_pipeline.R"); write_checkpoints()`.
4. Build: **`source("R/build_site.R")`**. It renders every page, rebuilds the quiz
   index (`assets/quiz_index.*`, needed for levels and certificates) and re-creates
   `docs/.nojekyll`. To check one page only: `rmarkdown::render_site("i10-tests.Rmd")`
   — but always finish with a full build before publishing.
5. Open `docs/index.html`. Without a Google Script URL the site runs in **demo mode**:
   `demo` / `demo` (student, beginner) and `teacher` / `teacher` (sees everything, answers not recorded).

> Quiz answers are **computed by R at build time** from the data (hidden `answers` chunks),
> so if you change the data, the answers follow.

## 3. Publish on GitHub Pages

1. Repository → **Settings → Pages → Deploy from a branch**, Branch `main`, Folder **`/docs`**.
2. After each change: full build → commit → push.
3. Keep `docs/.nojekyll` (re-created by `R/build_site.R`).

## 4. Google Sheet backend (logins, progress, scores, levels)

### First installation

1. New Google Sheet → *Extensions → Apps Script* → paste `apps-script/Code.gs` → Save.
2. At the top of `Code.gs`, set **`SITE_URL`** to the address of your site
   (e.g. `"https://edu-aroo.github.io/begin-R/"`, with the final `/`). The script
   reads `assets/quiz_index.json` there to check the 75 % rule. Check `ALERT_EMAIL`.
3. Run **`setup`** (accept the permissions), then **`installTriggers`** (weekly backup + dashboard refresh).
4. *Deploy → New deployment → Web app* — Execute as **Me**, access **Anyone** → copy the URL (`…/exec`).
5. Paste it in `assets/config.js` → `scriptUrl: "…/exec"`, rebuild, push.
6. Run **`testQuizIndex`**: the log must show the number of quizzes found on the site.

### Upgrading from v2 or v3.0 (students already registered)

1. Replace the code by the new `Code.gs`, set `SITE_URL`, then run **`setup`** again:
   it **adds** the missing tabs and columns and never deletes rows.
2. Run `installTriggers`.
3. *Deploy → Manage deployments → ✏ → Version: New version → Deploy* (the URL stays the same).
4. Students keep their beginner progress and scores (page and quiz ids did not change).

### Tabs of the sheet

| Tab | Content |
|---|---|
| `students` | `username, password, full_name, active, level, role, email, facebook, phone, open_pages` |
| `progress` | one row per student: last page, last update, full state (JSON) |
| `scores` | one row per attempt (max 2 per quiz): date, student, quiz, score, max, answers, attempt |
| `certificates` | one row per level passed: verification code, date, student, level, % |
| `alerts` | one row per student and session where 75 % can no longer be reached: name, level, session, %, contacts |
| `dashboard` | refreshed automatically: % per level, status, sessions where help is needed, contacts |

- **Accounts**: `R/make_accounts.R` creates usernames and passwords (`accounts_to_paste.csv`, never published).
- **`active`** = `no` blocks an account without deleting its history.
- **`level`**: empty or `beginner` = normal path. Write `intermediate` (or `advanced`) to **give direct access** to a level.
- **`role`**: `teacher` sees all levels and solutions; teacher answers are never recorded.
- **`email`, `facebook`, `phone`**: copied into the e-mails you receive.
- **`open_pages`**: sessions you open by hand, separated by commas (file names without `.html`), e.g. `02-vectors` or `06-statistics, i04-survey`.

### Rules of the sessions and levels

- 2 attempts per quiz; the **best** counts. The solution opens after the 2nd attempt or full marks.
- **Sessions open one after the other**: a session opens when the quiz of the previous session reaches **≥ 75 %**.
  A practice session (09, I12) counts as one session: its six quizzes must all be done and reach 75 % **together**.
  Sessions a student had already started before v3.1 stay open.
- A **level** is passed when all its quizzes are done with ≥ 75 % of the level's total points. The next level opens,
  a **certificate** is created (`certificates` tab) and **you receive an e-mail** (name, level, %, certificate code, contacts).
- When 75 % can no longer be reached on a session (both attempts used), the student is sent to the **help page**
  (your message and contacts) and **you receive one e-mail** for that session (`alerts` tab).
  After talking with them, either run **`resetQuiz`** (2 new attempts: type the username and quiz id in the function,
  then Run) or write the **next** session in their `open_pages` cell. The student logs out and in again.
- `level` = `intermediate` (or `advanced`) opens that level directly; the sessions of lower levels are then all open.

`maxAttempts` / `passThreshold` in `config.js` and `MAX_ATTEMPTS` / `PASS` in `Code.gs` must stay identical (2 and 0.75).

## 5. How it works (and its limits)

- `course.js` shows the login screen, keeps one `STATE` object per student (pages, sections,
  quizzes), saves it to the sheet 2 s after each change and when the tab closes, and resumes
  at the last page and section.
- `quiz()` writes the questions and answers (base64) in the page; `course.js` grades them.
- Pages of a locked level show a lock card with the current %.
- Watermark "by Aroo Falinirina" on every page; on the login page only a small signature at the bottom.

**Be aware:** GitHub Pages serves static files. The login protects *progress and scores*,
but a technical person can read the pages and decode the answers. Fine for a course, not for
high-stakes exams. Passwords are stored in plain text in your sheet: give passwords used nowhere else.

## 6. Change the look and texts

- Title, subtitle, author, version, contacts, levels and pages: `assets/config.js`.
- Login background: replace `assets/img/login-bg.svg`, or put any image (`.jpg`, `.png`) in
  `assets/img/` and change `loginBackground` in `config.js`.
- Colours: variables at the top of `assets/course.css`.
- New version: add a section at the top of `whats-new.Rmd` and change `version` in `config.js`.

## 7. Add a session or a level (e.g. the Advanced level, or a socio-economic course)

1. Copy a session `.Rmd` and keep its structure: objectives → **simulated context** (how the data were
   collected, what type of data) → sections → application work → hints → quiz → solution.
2. File name prefix decides the level of its quizzes: `i…` = intermediate, `a…` = advanced, digits = beginner.
3. Quiz ids must be unique (`a00`, `a01`, `ap1`…). Never rename an id once students have used it.
4. Add the page to `levels` in `assets/config.js` and to the navbar in `_site.yml`.
5. Full build with `R/build_site.R` (updates the quiz index), push.

Building blocks:

````markdown
## [English heading]{.en}[Titre en français]{.fr} {#short-id}

::: {.callout .ecology}      <!-- also: .tip  .warning  .try -->
::: en
English text
:::
::: fr
Texte en français
:::
:::

::: hint                      <!-- becomes a "Hint" button; free, costs no points -->
::: en
...
:::
::: fr
...
:::
:::

```{r quiz, echo=FALSE}
quiz("a01", list(
  q_num("Mean income?", "Revenu moyen ?", answer = a1, tol = 0.05),
  q_mcq("Which function?", "Quelle fonction ?", c("mean()", "sd()"), c("mean()", "sd()"), correct = 1),
  q_text("Which village?", "Quel village ?", a2)
))
```

::: {.solution data-quiz="a01"}
```{r, eval=FALSE}
# solution code
```
:::
````

Several quizzes on one page: different ids + `title_en` / `title_fr`, and list them in
`config.js` (`quizzes: ["ap1", "ap2"]`). Base R and package side by side: `::: compare`
with `::: {.col .base}` and `::: {.col .pkg}`. Figures: `` `r fig_svg("name", "caption EN", "légende FR")` ``.

## 8. Slides

`slides/` contains six decks in French (≈ 1 h each): `part1_sessions0-3`, `part2_sessions4-6`,
`part3_sessions7-10` (Beginner) and `int1_sessions_I0-I4`, `int2_sessions_I5-I8`, `int3_sessions_I9-I13` (Intermediate).

- Build: `source("slides/render_slides.R")`. Each deck is **one self-contained .html** (works offline).
- Keys: **→ / Space** next, **←** previous, **F** full screen, **O** overview, **N** speaker notes, **Ctrl + P** → PDF.
- `## Title` = one slide; `## Title {.segue}` = section divider; `<div class="notes">` = notes.

## 9. PDF kit (for selected students)

```r
source("R/make_pdf_kit.R")
make_pdf_kit("beginner", "fr")                         # without solutions
make_pdf_kit("intermediate", "en", solutions = TRUE)
```

Needs `pagedown` and Google Chrome (or Chromium). PDFs go to `pdf_kit/<level>/<lang>/`,
with the watermark on every page. They are git-ignored and never published: quizzes stay online
so that progress is kept.

## 10. For students

`templates/check_setup.R` checks R, RStudio, packages and data files for a level (change `LEVEL`
at the top). It can be downloaded from the home page and from Session I0.
