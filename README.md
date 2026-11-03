# R for absolute beginners — Coral reef & seagrass edition

*by Aroo Falinirina*

A bilingual (EN/FR), self-study R course built as an **R Markdown website**, with
student login, saved progress, single-attempt scored quizzes and a watermark.
Eleven sessions (≈ 31 h) take students from installing R to a complete analysis
of raw coral cover data, using base R first and introducing `dplyr` / `ggplot2`
(always next to their base R equivalents) at the end. A cheatsheet page lists
every function, and three slide decks (≈ 3 h, in French) support a live presentation.

---

## 1. What is in this folder

```
r-course-beginner/
├── r-course-beginner.Rproj   <- open this in RStudio
├── _site.yml                 <- site settings: navbar, theme, output folder
├── index.Rmd                 <- home page (dashboard + schedule)
├── 00-installation.Rmd … 10-final-project.Rmd   <- the 11 sessions (09 = practice)
├── cheatsheet.Rmd            <- every function of the course, by session
├── assets/
│   ├── config.js             <- THE file to edit: title, author, Google Script URL, attempts, page list
│   ├── course.js             <- login, progress, quizzes, language switch (commented)
│   ├── course.css            <- the look: colours, boxes, quiz, login screen (commented)
│   ├── header.html           <- loads config.js + course.js in every page
│   └── img/*.svg             <- illustrations (bilingual labels)
├── R/
│   ├── build_site.R          <- builds the website into docs/
│   ├── simulate_data.R       <- creates all the datasets in data/
│   ├── course_helpers.R      <- quiz(), q_num(), q_mcq(), q_text(), fig_svg(), dl()
│   └── make_accounts.R       <- generates usernames/passwords for your students
├── data/                     <- the 5 CSV files + a zip (downloadable by students)
├── templates/                <- final_project_template.R (downloadable)
├── slides/                   <- 3 slide decks for a live presentation (see section 7)
├── _intermediate/            <- draft material kept for the intermediate course (not published)
├── apps-script/Code.gs       <- the Google Apps Script "backend" (logins, progress, scores)
└── docs/                     <- THE BUILT WEBSITE (this is what GitHub publishes)
```

**Files in `R/`, `apps-script/`, `slides/`, `_intermediate/` and `README.md` are never published** (see `exclude:` in `_site.yml`).

## 2. Build the site on your computer

1. Open `r-course-beginner.Rproj` in RStudio.
2. Install once: `install.packages(c("rmarkdown", "knitr", "jsonlite", "dplyr", "ggplot2"))`
3. *(Optional)* regenerate the data: `source("R/simulate_data.R")`
4. Build: `source("R/build_site.R")` (recommended: it renders the site **and** adds the
   `.nojekyll` file GitHub needs), or **Build pane → Build Website** / `rmarkdown::render_site()`.
   To rebuild a single page: `rmarkdown::render_site("05-statistics.Rmd")`.
5. Open `docs/index.html` in your browser to check. Without a Google Script URL the
   site runs in **demo mode** (login `demo` / `demo`, progress kept in the browser).

> Quiz answers are **computed by R at build time** from the data (see the hidden
> `answers..` chunks), so if you change the data, the answers update automatically.

## 3. Publish on GitHub Pages

1. Create a free account on <https://github.com> and a **new repository** (e.g. `r-course-reef`).
   GitHub Pages on a free account requires a **public** repository.
2. Upload the project: easiest is **GitHub Desktop** (*File → Add local repository* →
   *Publish repository*), or on the website: *Add file → Upload files* (drag the whole folder).
3. In the repository: **Settings → Pages → Build and deployment → Source: Deploy from a branch**,
   Branch: `main`, Folder: **`/docs`** → Save.
4. After 1–2 minutes the course is online at `https://<your-user-name>.github.io/r-course-reef/`.
5. Every time you change something: rebuild the site, then commit + push (GitHub Desktop:
   *Commit to main* → *Push origin*).

`docs/.nojekyll` (an empty file) must be in `docs/`: it tells GitHub not to
process the site with Jekyll. `rmarkdown::render_site()` deletes it, which is why
`R/build_site.R` re-creates it after each build.

**Want to hide the source (.Rmd files, quiz answers in R code)?** Use two repositories:
a *private* one with the whole project, and a *public* one containing only the
**contents** of `docs/` (published from the root `/`).

## 4. Connect the Google Sheet (logins, progress, scores)

This is what makes the login real and lets students resume on any device, and lets
**you** see their progress and scores.

1. In Google Drive create a new **Google Sheet** (e.g. "R course – students").
2. *Extensions → Apps Script*. Delete the default code and paste the content of
   `apps-script/Code.gs`. Save (disk icon).
3. In the function list at the top select **`setup`** and click **Run**. Accept the
   permissions (it is your own script). Three tabs are created: `students`, `progress`, `scores`.
4. **Deploy → New deployment → ⚙ Select type: Web app**
   - Description: `course backend`
   - Execute as: **Me**
   - Who has access: **Anyone**
   - Click **Deploy**, then copy the **Web app URL** (ends with `/exec`).
5. Paste the URL in `assets/config.js`: `scriptUrl: "https://script.google.com/macros/s/…/exec",`
6. Rebuild the site (or edit `docs/assets/config.js` directly) and push to GitHub.

**If you change `Code.gs` later:** *Deploy → Manage deployments → ✏ Edit → Version: New version → Deploy*.
The URL stays the same.

### Student accounts

- Fill the `students` tab: `username | password | full_name | active`.
- `R/make_accounts.R` generates usernames and passwords from a list of names
  (writes `accounts_to_paste.csv`, which is git-ignored and never published).
- Set `active` to `no` to block an account without deleting its history.

### What you see in the sheet

| Tab | One row per… | Useful columns |
|---|---|---|
| `progress` | student | last page, last section, last update, full state (JSON) |
| `scores` | quiz (first attempt only) | date, student, quiz (`s00`…`s10`, `p1`…`p6`), score, max, answers given |

A pivot table on `scores` (`score` by `username` × `quiz`) gives the grade book.

### Single-attempt quizzes

- `maxAttempts: 1` in `assets/config.js` (change it to allow more attempts).
- Students must confirm before submitting; the quiz is then locked, shows which
  answers were right or wrong, and unlocks the solution.
- The Apps Script also refuses a second score for the same quiz, so the **first**
  score is the official one even if someone tampers with the page.
- **To give one student a new attempt** (e.g. after a connection problem): in the
  Apps Script editor, open `resetQuiz()`, type the username and quiz id, select
  `resetQuiz` and click **Run**. The student logs out and in again.

## 5. How it works (and its limits)

- **Login**: `course.js` shows a login screen and sends username + password to the
  Apps Script, which checks the `students` tab.
- **Progress**: section ticks, last position, language and quiz results are kept in
  one object (`STATE`), saved to the sheet 2 s after each change and when the tab closes.
  On login, the student is sent back to the page and section where they stopped.
- **Quizzes**: `quiz()` in R writes the questions (and answers) as base64 inside the
  page; `course.js` displays them, scores them and saves the result. One attempt per
  quiz; solutions unlock after submission.
- **Watermark**: `course.js` draws "by Aroo Falinirina" as a faint repeated background
  and a signature in the footer (name taken from `config.js`).

**Be aware:** GitHub Pages only serves static files. The login protects the
*progress and scores*, but a determined, technical person could read the page
content (and decode quiz answers) from the public files. For a course this is
usually acceptable; it is not suitable for confidential material or high-stakes exams.
Passwords are stored in your Google Sheet in plain text: give students passwords
that they do not use elsewhere (as `make_accounts.R` does).

## 6. Reuse this project for another course (e.g. socio-economic data)

1. **Data** — rewrite `R/simulate_data.R` with your variables (households, income
   class, fishing gear, village, …). Keep `set.seed()` so answers never change.
2. **Content** — copy a session `.Rmd`, keep the structure (objectives → sections →
   application → quiz → solution) and replace the text and examples.
3. **Pages** — update the list in `assets/config.js` (`pages:`) and the navbar in `_site.yml`.
4. **Look** — change the colour variables at the top of `assets/course.css` (`:root { … }`).
5. **Title / author** — `assets/config.js` (`title`, `author`) and `_site.yml` (`navbar: title`).
6. **Separate backend** — use a new Google Sheet + Apps Script for each course.

### Building blocks you can copy into any page

````markdown
::: en
English text
:::
::: fr
Texte en français
:::

## [English heading]{.en}[Titre en français]{.fr} {#short-id}

::: {.callout .tip}        <!-- also: .warning  .ecology  .try -->
::: en
...
:::
::: fr
...
:::
:::

```{r quiz-example, echo=FALSE}
quiz("s10", list(                                  # unique id per quiz
  q_num("Mean income?", "Revenu moyen ?", answer = 12.5, tol = 0.05),
  q_mcq("Which function...?", "Quelle fonction... ?",
        c("mean()", "sd()"), c("mean()", "sd()"), correct = 1),
  q_text("Which village...?", "Quel village... ?", c("Ifaty"))
))
```

::: {.solution data-quiz="s10"}             <!-- unlocked after quiz s10 is submitted -->
```{r, eval=FALSE}
# solution code
```
:::
````

Add `{.no-track}` after a heading (as on the home page) to exclude a section from
the progress bar.

Several quizzes on one page (as in the practice session): give each a different id
and a title — `quiz("p1", list(...), title_en = "Quiz — Exercise 1", title_fr = "Quiz — Exercice 1")` —
and list the ids in `config.js`: `quizzes: ["p1", "p2", ...]`.

Base R and package code side by side (as in Session 8):

````markdown
:::: compare
::: {.col .base}
R base

```{r}
subset(sg, depth_m < 1)
```
:::
::: {.col .pkg}
dplyr

```{r}
filter(sg, depth_m < 1)
```
:::
::::
````

## 7. Slides for a live presentation

`slides/` contains three decks in French (≈ 1 h each, ~35 slides each):
`part1_sessions0-3`, `part2_sessions4-6`, `part3_sessions7-10`.

- Build them: `source("slides/render_slides.R")`. Each deck is **one self-contained
  .html file**: it works offline and can be copied on a USB key.
- They use a small slide engine (`slides/slides-engine.html` + `slides/slides.css`)
  on top of a normal `html_document`: **no extra package** is needed.
- In the browser: **→ / Space** next, **←** previous, **F** full screen,
  **O** overview of all slides, **N** speaker notes, **Ctrl + P** → PDF (one slide per page).
- Writing slides: `## Title` = one slide; `## Title {.segue}` = section divider;
  `<div class="notes">…</div>` = speaker notes; `::: cols` with `::: {.c .base}` and
  `::: {.c .pkg}` = two columns. Text that is too long is shrunk automatically,
  but keep each slide short.
- Code runs from the project root, so the slides use the same `data/` files as the course.
