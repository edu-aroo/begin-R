/* ============================================================================
   config.js  —  THE FILE YOU EDIT TO CONFIGURE THE SITE
   ----------------------------------------------------------------------------
   After editing, rebuild (source("R/build_site.R")) OR edit the copy in
   docs/assets/config.js directly, then commit + push to GitHub.
   ============================================================================ */

window.COURSE_CONFIG = {

  // Course title (login screen) — one per language
  title: { en: "R4Marine Research - R Programming for Marine Sciences Research", fr: "R4Marine Research - Programmation en R pour la Recherche en Sciences Marines" },
  subtitle: { en: "From your first line of code to reproducible analyses",
              fr: "De la première ligne de code aux analyses reproductibles" },

  // Name used for the watermark, the footer and the login screen
  author: "Aroo Falinirina",

  // Course version shown in the footer (describe changes in whats-new.Rmd)
  version: "4.5", versionDate: "2026-11",

  // Default language for a first visit: "en" or "fr"
  defaultLang: "fr",

  // Image behind the login card. Replace the file (same name) or change the path,
  // e.g. "assets/img/my-photo.jpg". A wide image (≥ 1600 px) looks best.
  loginBackground: "assets/img/login-bg.svg",

  // Google Apps Script web-app URL. Empty "" = DEMO MODE (accounts below,
  // progress saved only in the browser).
  scriptUrl: "https://script.google.com/macros/s/AKfycby8yxnrz1WL1btgTNRBQQ8nCjBu9DdIYQRAee3TzIvYSilO28HnVCEWBpckwNHvx4qP/exec",

  // DEMO MODE only (real accounts are in the Google Sheet, never here: this file is public)
  demoUsers: [
    { user: "demo",    pass: "demo",    name: "Demo Student", level: "beginner, intermediate, advanced", role: "student" },
    { user: "teacher", pass: "teacher", name: "Demo Teacher", level: "advanced", role: "teacher" }
  ],

  // Quiz rules: attempts per quiz, and the share of the level's total points
  // (best attempt of every quiz, practice quizzes included) needed to open the next level.
  maxAttempts: 2,
  passThreshold: 0.75,

  // Message and Bible verse shown on the certificate page of each level
  // (on the page only, not printed on the certificate PDF). Edit freely.
  certificateMessages: {
    beginner: {
      en: "Your first step into R! Remember, every expert was once a beginner. You earned this achievement through your willingness to learn. Keep going!",
      fr: "Votre premier pas dans R ! N'oubliez pas : tout expert a d'abord été débutant. Vous avez obtenu cette réussite grâce à votre envie d'apprendre. Continuez !",
      verse_en: "Not unto us, O LORD, not unto us, but unto thy name give glory, for thy mercy, and for thy truth's sake.",
      ref_en: "Psalm 115:1 (KJV)",
      verse_fr: "Non pas à nous, Éternel, non pas à nous, mais à ton nom donne gloire, à cause de ta bonté, à cause de ta fidélité !",
      ref_fr: "Psaume 115:1 (Louis Segond 1910)"
    },
    intermediate: {
      en: "Congratulations! You are no longer just following instructions; you are developing your own skills. Remember, the real achievement is not knowing every command, but knowing how to find your way when you don't know the answer.",
      fr: "Félicitations ! Vous ne vous contentez plus de suivre des instructions : vous développez vos propres compétences. N'oubliez pas : la vraie réussite n'est pas de connaître chaque commande, mais de savoir trouver votre chemin quand vous ne connaissez pas la réponse.",
      verse_en: "But by the grace of God I am what I am: and his grace which was bestowed upon me was not in vain; but I laboured more abundantly than they all: yet not I, but the grace of God which was with me.",
      ref_en: "1 Corinthians 15:10 (KJV)",
      verse_fr: "Par la grâce de Dieu je suis ce que je suis, et sa grâce envers moi n'a pas été vaine ; loin de là, j'ai travaillé plus qu'eux tous, non pas moi toutefois, mais la grâce de Dieu qui est avec moi.",
      ref_fr: "1 Corinthiens 15:10 (Louis Segond 1910)"
    },
    advanced: {
      en: "You made it! This achievement is entirely yours. I shared knowledge, guidance, and a few tricks along the way, but your determination, patience, and hard work made this journey possible. You should be incredibly proud of yourself. And remember: mastering R doesn't mean knowing everything; it means never stopping learning!",
      fr: "Vous y êtes arrivé ! Cette réussite vous appartient entièrement. J'ai partagé des connaissances, des conseils et quelques astuces en chemin, mais ce sont votre détermination, votre patience et votre travail qui ont rendu ce parcours possible. Vous pouvez être vraiment fier de vous. Et n'oubliez pas : maîtriser R ne veut pas dire tout savoir, mais ne jamais cesser d'apprendre !",
      verse_en: "I can do all things through Christ which strengtheneth me.",
      ref_en: "Philippians 4:13 (KJV)",
      verse_fr: "Je puis tout par celui qui me fortifie.",
      ref_fr: "Philippiens 4:13 (Louis Segond 1910)"
    }
  },

  // Shown in the "you need help" message
  contact: { email: "aroo.madaeducation@gmail.com", facebook: "Aroo Falinirina" },

  // Pages that do not belong to a level (never locked)
  extraPages: ["index", "help", "certificate", "common-errors", "whats-new",
               "cheatsheet", "cheatsheet-intermediate", "cheatsheet-advanced", "advanced"],

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
    // Add  inProgress: true  to a level that is still being written: it can be studied,
    // but gives no certificate / "level passed" until the line is removed.
    { id: "advanced", en: "Advanced", fr: "Avancé", pages: [
      { id: "a00-project",  quiz: "a00", hours: 2.5, en: "A0. Organising a reproducible project", fr: "A0. Organiser un projet reproductible" },
      { id: "a01-renv",     quiz: "a01", hours: 2,   en: "A1. Package versions with renv",        fr: "A1. Versions des packages avec renv" },
      { id: "a02-git",      quiz: "a02", hours: 3.5, en: "A2. Git, GitHub and GitLab",            fr: "A2. Git, GitHub et GitLab" },
      { id: "a03-rmarkdown", quiz: "a03", hours: 3,  en: "A3. Reports with R Markdown",           fr: "A3. Rapports avec R Markdown" },
      { id: "a04-params",   quiz: "a04", hours: 3,   en: "A4. Parameterised and automatic reports", fr: "A4. Rapports paramétrés et automatiques" },
      { id: "a05-sf",       quiz: "a05", hours: 3.5, en: "A5. Vector GIS data with sf",           fr: "A5. Données SIG vecteur avec sf" },
      { id: "a06-terra",    quiz: "a06", hours: 3,   en: "A6. Rasters with terra",                fr: "A6. Rasters avec terra" },
      { id: "a07-maps",     quiz: "a07", hours: 3,   en: "A7. Thematic maps (ggplot2, sf, tmap)", fr: "A7. Cartes thématiques (ggplot2, sf, tmap)" },
      { id: "a08-quarto",   quiz: "a08", hours: 3.5, en: "A8. Quarto (1): cross-references and citations", fr: "A8. Quarto (1) : renvois et citations" },
      { id: "a09-publish",  quiz: "a09", hours: 3,   en: "A9. Quarto (2): PDF and publishing",    fr: "A9. Quarto (2) : PDF et publication" },
      { id: "a10-practice", quizzes: ["ap1", "ap2", "ap3", "ap4", "ap5", "ap6"], hours: 3.5,
                                                     en: "A10. Practice session",                  fr: "A10. Séance d'exercices" },
      { id: "a11-final-project", quiz: "a11", hours: 5, en: "A11. Final project: the 2026 reports", fr: "A11. Projet final : les rapports 2026" }
    ]}
  ]
};
