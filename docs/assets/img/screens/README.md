# Screenshots to replace the drawn illustrations (Windows)

Put PNG files with **exactly these names** in this folder, then rebuild the site
(`source("R/build_site.R")`): each one replaces its drawing automatically
(function `fig_shot()` in `R/course_helpers.R`). Delete a PNG to go back to the drawing.

Tips: Windows key + Shift + S (Snipping Tool) → "Window" mode; RStudio in English;
crop to the useful part; width 1200–1800 px; no personal information visible
(blur your e-mail, token, real name of other people).

| File name | Session | What to capture |
|---|---|---|
| `git-options.png` | A2 | RStudio: Tools → Global Options… → Git/SVN (with the path to git.exe) |
| `git-terminal-config.png` | A2 | RStudio Terminal (Git Bash) after the three `git config --global` commands and `git config --global --list` |
| `git-github-new.png` | A2 | GitHub: "Create a new repository" page filled in (name, Private, README, .gitignore R) |
| `git-gitlab-new.png` | A2 | GitLab: "Create blank project" page filled in |
| `git-new-project.png` | A2 | RStudio: File → New Project → Version Control → Git → the "Clone Git Repository" dialog filled in |
| `git-pane.png` | A2 | RStudio Git pane with a few files in different states (M, A, ?, D) |
| `git-commit-window.png` | A2 | RStudio "Review Changes" window: files ticked, a commit message, the diff in green/red |
| `git-credential.png` | A2 | The "Connect to GitHub" window of Git Credential Manager at the first Push |
| `git-history.png` | A2 | RStudio Review Changes → History, one commit selected |
| `git-cycle.png` | A2 | (optional: keep the drawing) |
| `rstudio-panes.png` | 0 | RStudio with the four panes (script, console, environment, files) |
