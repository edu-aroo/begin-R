# R for absolute beginners — Coral reef & seagrass edition

*by Aroo Falinirina*

A bilingual (EN/FR), self-study R course built as an **R Markdown website**, with
student login, saved progress, scored quizzes and a watermark. Ten sessions
(≈ 26 h) take students from installing R to a complete analysis of raw coral
cover data, using base R first and introducing `dplyr` / `ggplot2` at the end.

---

## 1. What is in this folder

```
r-course-beginner/
├── r-course-beginner.Rproj   <- open this in RStudio
├── _site.yml                 <- site settings: navbar, theme, output folder
├── index.Rmd                 <- home page (dashboard + schedule)
├── 00-installation.Rmd … 09-final-project.Rmd   <- the 10 sessions
├── assets/
│   ├── config.js             <- THE file to edit: title, author, Google Script URL, page list
│   ├── course.js             <- login, progress, quizzes, language switch (commented)
│   ├── course.css            <- the look: colours, boxes, quiz, login screen (commented)
│   ├── header.html           <- loads config.js + course.js in every page
│   └── img/*.svg             <- illustrations (bilingual labels)
├── R/
│   ├── simulate_data.R       <- creates all the datasets in data/
│   ├── course_helpers.R      <- quiz(), q_num(), q_mcq(), q_text(), fig_svg(), dl()
│   └── make_accounts.R       <- generates usernames/passwords for your students
├── data/                     <- the 4 CSV files + a zip (downloadable by students)
├── templates/                <- final_project_template.R (downloadable)
├── apps-script/Code.gs       <- the Google Apps Script "backend" (logins, progress, scores)
└── docs/                     <- THE BUILT WEBSITE (this is what GitHub publishes)
```

**Files in `R/`, `apps-script/`, `README.md` are never published** (see `exclude:` in `_site.yml`).

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
| `scores` | quiz attempt | date, student, quiz (`s00`…`s09`), score, max, answers given |

A pivot table on `scores` (max of `score` by `username` × `quiz`) gives the grade book.

## 5. How it works (and its limits)

- **Login**: `course.js` shows a login screen and sends username + password to the
  Apps Script, which checks the `students` tab.
- **Progress**: section ticks, last position, language and quiz results are kept in
  one object (`STATE`), saved to the sheet 2 s after each change and when the tab closes.
  On login, the student is sent back to the page and section where they stopped.
- **Quizzes**: `quiz()` in R writes the questions (and answers) as base64 inside the
  page; `course.js` displays them, scores them and saves the result. Solutions unlock
  after the first attempt. Students can retry; the best score is kept.
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
