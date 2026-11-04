/* ============================================================================
   config.js  —  THE FILE YOU EDIT TO CONFIGURE THE SITE
   ----------------------------------------------------------------------------
   After editing, rebuild (source("R/build_site.R")) OR edit the copy in
   docs/assets/config.js directly, then commit + push to GitHub.
   ============================================================================ */

window.COURSE_CONFIG = {

  // Course title (login screen) — one per language
  title: { en: "R for marine sciences", fr: "R pour les sciences marines" },
  subtitle: { en: "From your first line of code to reproducible analyses",
              fr: "De la première ligne de code aux analyses reproductibles" },

  // Name used for the watermark, the footer and the login screen
  author: "Aroo Falinirina",

  // Course version shown in the footer (describe changes in whats-new.Rmd)
  version: "3.1", versionDate: "2026-11",

  // Default language for a first visit: "en" or "fr"
  defaultLang: "fr",

  // Image behind the login card. Replace the file (same name) or change the path,
  // e.g. "assets/img/my-photo.jpg". A wide image (≥ 1600 px) looks best.
  loginBackground: "assets/img/login-bg.svg",

  // Google Apps Script web-app URL. Empty "" = DEMO MODE (accounts below,
  // progress saved only in the browser).
  scriptUrl: "https://script.google.com/macros/s/AKfycbztElIpQALbZ3ui5ilpfrkvn8xM_FRDD2vbwuYRFDacyhrbiAQ7TmqizWkQIwkPiWGH/exec",

  // DEMO MODE only (real accounts are in the Google Sheet, never here: this file is public)
  demoUsers: [
    { user: "demo",    pass: "demo",    name: "Demo Student", level: "beginner", role: "student" },
    { user: "teacher", pass: "teacher", name: "Demo Teacher", level: "advanced", role: "teacher" }
  ],

  // Quiz rules: attempts per quiz, and the share of the level's total points
  // (best attempt of every quiz, practice quizzes included) needed to open the next level.
  maxAttempts: 2,
  passThreshold: 0.75,

  // Shown in the "you need help" message
  contact: { email: "aroo.madaeducation@gmail.com", facebook: "Aroo Falinirina" },

  // Pages that do not belong to a level (never locked)
  extraPages: ["index", "help", "certificate", "common-errors", "whats-new",
               "cheatsheet", "cheatsheet-intermediate", "advanced"],

  // The levels, in order. Each page: id = file name without ".html";
  // quiz / quizzes = quiz id(s) of the page; hours = suggested duration.
  levels: [
    { id: "beginner", en: "Beginner", fr: "Débutant", pages: [
      { id: "00-installation",       quiz: "s00", hours: 1.5, en: "0. Install R, Rtools & RStudio",           fr: "0. Installer R, Rtools et RStudio" },
      { id: "01-first-steps",        quiz: "s01", hours: 2,   en: "1. First steps: objects & functions",       fr: "1. Premiers pas : objets et fonctions" },
      { id: "02-vectors",            quiz: "s02", hours: 3,   en: "2. Vectors & data types",                   fr: "2. Vecteurs et types de données" },
      { id: "03-data-frames",        quiz: "s03", hours: 2,   en: "3. Data frames & importing data",           fr: "3. Data frames et importation" },
      { id: "04-inside-data-frames", quiz: "s04", hours: 3.5, en: "4. Inside a data frame: [ , ], $, columns", fr: "4. Dans un data frame : [ , ], $, colonnes" },
      { id: "05-cleaning",           quiz: "s05", hours: 3,   en: "5. Filtering & cleaning data",              fr: "5. Filtrer et nettoyer les données" },
      { id: "06-statistics",         quiz: "s06", hours: 2.5, en: "6. Descriptive statistics by group",        fr: "6. Statistiques descriptives par groupe" },
      { id: "07-graphics",           quiz: "s07", hours: 3,   en: "7. Graphs with base R",                     fr: "7. Graphiques avec R de base" },
      { id: "08-packages-tidyverse", quiz: "s08", hours: 3.5, en: "8. Packages, dplyr & ggplot2",              fr: "8. Packages, dplyr et ggplot2" },
      { id: "09-practice", quizzes: ["p1", "p2", "p3", "p4", "p5", "p6"], hours: 3,
                                                            en: "9. Practice session",                       fr: "9. Séance d'exercices" },
      { id: "10-final-project",      quiz: "s10", hours: 4,   en: "10. Final project: coral cover",            fr: "10. Projet final : couverture corallienne" }
    ]},
    { id: "intermediate", en: "Intermediate", fr: "Intermédiaire", pages: [
      { id: "i00-import",        quiz: "i00", hours: 2.5, en: "I0. Importing real-world files",          fr: "I0. Importer des fichiers réels" },
      { id: "i01-dates",         quiz: "i01", hours: 2.5, en: "I1. Dates",                               fr: "I1. Les dates" },
      { id: "i02-reshape",       quiz: "i02", hours: 2.5, en: "I2. Reshaping tables",                    fr: "I2. Restructurer des tableaux" },
      { id: "i03-joins",         quiz: "i03", hours: 3,   en: "I3. Joining tables",                      fr: "I3. Joindre des tableaux" },
      { id: "i04-survey",        quiz: "i04", hours: 3,   en: "I4. Survey data and text",                fr: "I4. Données d'enquête et texte" },
      { id: "i05-loops",         quiz: "i05", hours: 2.5, en: "I5. Conditions and loops",                fr: "I5. Conditions et boucles" },
      { id: "i06-functions",     quiz: "i06", hours: 3,   en: "I6. Writing functions",                   fr: "I6. Écrire des fonctions" },
      { id: "i07-ggplot-1",      quiz: "i07", hours: 3,   en: "I7. Mastering ggplot2 (1)",               fr: "I7. Maîtriser ggplot2 (1)" },
      { id: "i08-ggplot-2",      quiz: "i08", hours: 3,   en: "I8. Mastering ggplot2 (2)",               fr: "I8. Maîtriser ggplot2 (2)" },
      { id: "i09-distributions", quiz: "i09", hours: 3,   en: "I9. Distributions, p-values, transformations", fr: "I9. Distributions, p-values, transformations" },
      { id: "i10-tests",         quiz: "i10", hours: 3.5, en: "I10. Comparing, correlating, choosing a test", fr: "I10. Comparer, corréler, choisir un test" },
      { id: "i11-maps",          quiz: "i11", hours: 2.5, en: "I11. Introduction to maps",               fr: "I11. Introduction aux cartes" },
      { id: "i12-practice", quizzes: ["ip1", "ip2", "ip3", "ip4", "ip5", "ip6"], hours: 3.5,
                                                         en: "I12. Practice session",                   fr: "I12. Séance d'exercices" },
      { id: "i13-final-project", quiz: "i13", hours: 4.5, en: "I13. Final project: sea cucumber farming", fr: "I13. Projet final : élevage d'holothuries" }
    ]},
    { id: "advanced", en: "Advanced", fr: "Avancé", pages: [] }   // coming soon
  ]
};
