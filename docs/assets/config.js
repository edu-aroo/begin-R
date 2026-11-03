/* ============================================================================
   config.js  —  THE ONLY FILE YOU NEED TO EDIT TO CONFIGURE THE SITE
   ----------------------------------------------------------------------------
   After editing, re-knit the site (rmarkdown::render_site()) OR edit the copy
   in docs/assets/config.js directly and push it to GitHub.
   ============================================================================ */

window.COURSE_CONFIG = {

  // Course title shown on the login screen (one per language)
  title: {
    en: "R for absolute beginners — Marine ecology edition",
    fr: "R pour grands débutants — Édition Écologie marine"
  },

  // Name used for the watermark and the signature at the bottom of each page
  author: "Aroo Falinirina",

  // Default language when a student opens the site for the first time: "en" or "fr"
  defaultLang: "fr",

  // URL of your Google Apps Script web app (see README, step "Google Sheet").
  // Leave EMPTY ("") to run in DEMO MODE: logins below, progress saved only in
  // the browser. Paste the URL to save logins, progress and scores in your sheet.
  scriptUrl: "https://script.google.com/macros/s/AKfycbxZVpdF5tPaDIiNdPVG6rop6iqcqVZKyhtO0AEe4JRgM7sHos1S2aUc_QCUuo6jDuW3/exec",

  // Only used in DEMO MODE (scriptUrl empty). Real student accounts live in
  // the Google Sheet, never here (this file is public on GitHub!).
  demoUsers: [
    { user: "demo", pass: "demo", name: "Demo Student" }
  ],

  // Number of attempts allowed for each quiz. 1 = the first score is final.
  // (To give one student a new attempt, run resetQuiz() in the Apps Script.)
  maxAttempts: 1,

  // The list of pages, in order. id = file name without ".html".
  // quiz = id used in the quiz() call of that page (quizzes = several ids).
  // hours = suggested duration.
  pages: [
    { id: "00-installation",       quiz: "s00", hours: 1.5, en: "0. Install R, Rtools & RStudio",          fr: "0. Installer R, Rtools et RStudio" },
    { id: "01-first-steps",        quiz: "s01", hours: 2,   en: "1. First steps: objects & functions",      fr: "1. Premiers pas : objets et fonctions" },
    { id: "02-vectors",            quiz: "s02", hours: 3,   en: "2. Vectors & data types",                  fr: "2. Vecteurs et types de données" },
    { id: "03-data-frames",        quiz: "s03", hours: 2,   en: "3. Data frames & importing data",          fr: "3. Data frames et importation" },
    { id: "04-inside-data-frames", quiz: "s04", hours: 3.5, en: "4. Inside a data frame: [ , ], $, columns", fr: "4. Dans un data frame : [ , ], $, colonnes" },
    { id: "05-cleaning",           quiz: "s05", hours: 3,   en: "5. Filtering & cleaning data",             fr: "5. Filtrer et nettoyer les données" },
    { id: "06-statistics",         quiz: "s06", hours: 2.5, en: "6. Descriptive statistics by group",       fr: "6. Statistiques descriptives par groupe" },
    { id: "07-graphics",           quiz: "s07", hours: 3,   en: "7. Graphs with base R",                    fr: "7. Graphiques avec R de base" },
    { id: "08-packages-tidyverse", quiz: "s08", hours: 3.5, en: "8. Packages, dplyr & ggplot2",             fr: "8. Packages, dplyr et ggplot2" },
    { id: "09-practice",           quizzes: ["p1", "p2", "p3", "p4", "p5", "p6"], hours: 3,
                                                          en: "9. Practice session",                       fr: "9. Séance d'exercices" },
    { id: "10-final-project",      quiz: "s10", hours: 4,   en: "10. Final project: coral cover",           fr: "10. Projet final : couverture corallienne" }
  ]
};
