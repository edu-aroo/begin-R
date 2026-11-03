/* ============================================================================
   config.js  —  THE ONLY FILE YOU NEED TO EDIT TO CONFIGURE THE SITE
   ----------------------------------------------------------------------------
   After editing, re-knit the site (rmarkdown::render_site()) OR edit the copy
   in docs/assets/config.js directly and push it to GitHub.
   ============================================================================ */

window.COURSE_CONFIG = {

  // Course title shown on the login screen (one per language)
  title: {
    en: "R for absolute beginners — Coral reef & seagrass edition",
    fr: "R pour grands débutants — Édition récifs coralliens & herbiers"
  },

  // Name used for the watermark and the signature at the bottom of each page
  author: "Aroo Falinirina",

  // Default language when a student opens the site for the first time: "en" or "fr"
  defaultLang: "fr",

  // URL of your Google Apps Script web app (see README, step "Google Sheet").
  // Leave EMPTY ("") to run in DEMO MODE: logins below, progress saved only in
  // the browser. Paste the URL to save logins, progress and scores in your sheet.
  scriptUrl: "",

  // Only used in DEMO MODE (scriptUrl empty). Real student accounts live in
  // the Google Sheet, never here (this file is public on GitHub!).
  demoUsers: [
    { user: "demo", pass: "demo", name: "Demo Student" }
  ],

  // The list of pages, in order. id = file name without ".html".
  // quiz = id used in the quiz() call of that page. hours = suggested duration.
  pages: [
    { id: "00-installation",   quiz: "s00", hours: 1.5, en: "0. Install R, Rtools & RStudio",       fr: "0. Installer R, Rtools et RStudio" },
    { id: "01-first-steps",    quiz: "s01", hours: 2,   en: "1. First steps: objects & functions",   fr: "1. Premiers pas : objets et fonctions" },
    { id: "02-vectors",        quiz: "s02", hours: 2.5, en: "2. Vectors & data types",               fr: "2. Vecteurs et types de données" },
    { id: "03-data-frames",    quiz: "s03", hours: 2.5, en: "3. Data frames & importing data",       fr: "3. Data frames et importation" },
    { id: "04-cleaning",       quiz: "s04", hours: 3,   en: "4. Selecting, filtering & cleaning",    fr: "4. Sélectionner, filtrer et nettoyer" },
    { id: "05-statistics",     quiz: "s05", hours: 2.5, en: "5. Descriptive statistics by group",    fr: "5. Statistiques descriptives par groupe" },
    { id: "06-graphics",       quiz: "s06", hours: 3,   en: "6. Graphs with base R",                 fr: "6. Graphiques avec R de base" },
    { id: "07-functions",      quiz: "s07", hours: 2.5, en: "7. Conditions, loops & your own functions", fr: "7. Conditions, boucles et fonctions" },
    { id: "08-tidyverse",      quiz: "s08", hours: 3,   en: "8. First look at dplyr & ggplot2",      fr: "8. Premiers pas avec dplyr et ggplot2" },
    { id: "09-final-project",  quiz: "s09", hours: 4,   en: "9. Final project: coral cover",         fr: "9. Projet final : couverture corallienne" }
  ]
};
