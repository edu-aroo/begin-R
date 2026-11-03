/* ============================================================================
   course.js  —  all the interactive behaviour of the course
   ----------------------------------------------------------------------------
   Loaded in the <head> of every page (see _site.yml -> includes -> in_header).
   Main parts (search for "PART" to jump):
     PART 1  Storage & communication with the Google Sheet (or demo mode)
     PART 2  Login screen
     PART 3  Language switch (EN / FR)
     PART 4  Watermark, signature and navbar extras
     PART 5  Sidebar table of contents + "mark as done" + resume position
     PART 6  Quizzes (rendering, scoring, saving)
     PART 7  Small extras (copy buttons, solutions, dashboard)
     PART 8  Start-up
   JavaScript vocabulary for R users:
     const x = 5;      ~  x <- 5 (cannot be re-assigned)
     let x = 5;        ~  x <- 5 (can be re-assigned)
     function f(a){}   ~  f <- function(a){}
     obj.name          ~  obj$name
     array.map(f)      ~  lapply(vector, f)
     document.querySelectorAll(".quiz")  ~ "find every HTML element of class quiz"
   ============================================================================ */

(function () {               // everything inside this wrapper stays private
  "use strict";

  const CFG = window.COURSE_CONFIG;            // defined in config.js
  const DEMO = !CFG.scriptUrl;                 // no URL -> demo mode
  const AUTH_KEY = "rc_auth";                  // sessionStorage key (current tab)

  // The page id is the file name without ".html" ("index" for the home page)
  const PAGE_ID = (location.pathname.split("/").pop() || "index.html")
                    .replace(".html", "") || "index";

  let AUTH = null;     // {user, pass, name} once logged in
  let STATE = null;    // the student's progress object (saved in the sheet)
  let dirty = false;   // true when STATE changed but is not saved yet

  // A new student starts with this empty state
  function emptyState() {
    // a new student keeps the language chosen on the login screen
    const l = document.documentElement.classList.contains("lang-en") ? "en" : "fr";
    return { lang: l, lastPage: null, lastSection: null,
             pages: {}, quizzes: {} };
  }

  /* --------------------------------------------------------------------------
     PART 1 — Storage & communication
     api("login" | "save" | "score", data) returns a Promise (= a value that
     arrives later, like waiting for a download).
     -------------------------------------------------------------------------- */
  async function api(action, data) {
    if (DEMO) return demoApi(action, data);
    // "text/plain" avoids a CORS "preflight" request that Apps Script refuses
    const res = await fetch(CFG.scriptUrl, {
      method: "POST",
      headers: { "Content-Type": "text/plain;charset=utf-8" },
      body: JSON.stringify(Object.assign({ action: action }, data))
    });
    return res.json();
  }

  // Demo mode: same answers as the Google Sheet, but saved in the browser
  function demoApi(action, data) {
    const u = CFG.demoUsers.find(d => d.user === data.user && d.pass === data.pass);
    if (!u) return Promise.resolve({ ok: false, error: "bad_login" });
    const key = "rc_state_" + u.user;
    if (action === "login") {
      let st = null;
      try { st = JSON.parse(localStorage.getItem(key)); } catch (e) {}
      return Promise.resolve({ ok: true, name: u.name, state: st });
    }
    try { localStorage.setItem(key, JSON.stringify(data.state)); } catch (e) {}
    return Promise.resolve({ ok: true });
  }

  // Keep a copy of the state for the next page opened in this tab
  function cacheState() {
    if (STATE) try { sessionStorage.setItem("rc_state_cache", JSON.stringify(STATE)); } catch (e) {}
  }
  window.addEventListener("pagehide", cacheState);

  // Save the state, at most once every 2 seconds ("debounce")
  let saveTimer = null;
  function saveSoon() {
    dirty = true;
    cacheState();
    clearTimeout(saveTimer);
    saveTimer = setTimeout(saveNow, 2000);
  }
  function saveNow() {
    if (!AUTH || !dirty) return;
    dirty = false;
    cacheState();
    setSaveStatus("saving");
    api("save", { user: AUTH.user, pass: AUTH.pass, state: STATE })
      .then(r => setSaveStatus(r.ok ? "saved" : "error"))
      .catch(() => { dirty = true; setSaveStatus("error"); });
  }
  // When the student closes the tab: send the last changes with sendBeacon,
  // which still works while the page is closing.
  window.addEventListener("pagehide", function () {
    if (!AUTH || !dirty) return;
    if (DEMO) { saveNow(); return; }
    const body = JSON.stringify({ action: "save", user: AUTH.user, pass: AUTH.pass, state: STATE });
    navigator.sendBeacon(CFG.scriptUrl, new Blob([body], { type: "text/plain" }));
  });

  /* --------------------------------------------------------------------------
     PART 2 — Login screen
     -------------------------------------------------------------------------- */
  function showLogin() {
    const box = document.createElement("div");
    box.id = "rc-login";
    // Template literal `...${x}...` = paste0("...", x, "...") in R
    box.innerHTML = `
      <div class="rc-login-card">
        <div class="rc-login-wave" aria-hidden="true"></div>
        <h1><span class="en">${CFG.title.en}</span><span class="fr">${CFG.title.fr}</span></h1>
        <p class="rc-login-by">by ${CFG.author}</p>
        <form>
          <label><span class="en">Username</span><span class="fr">Identifiant</span>
            <input name="user" autocomplete="username" required></label>
          <label><span class="en">Password</span><span class="fr">Mot de passe</span>
            <input name="pass" type="password" autocomplete="current-password" required></label>
          <button type="submit"><span class="en">Enter the course</span><span class="fr">Entrer dans le cours</span></button>
          <p class="rc-login-msg" role="alert"></p>
        </form>
        <p class="rc-login-lang">
          <button type="button" data-lang="fr">Français</button> ·
          <button type="button" data-lang="en">English</button>
        </p>
        ${DEMO ? '<p class="rc-demo">Demo mode — user: <b>demo</b> / password: <b>demo</b></p>' : ""}
      </div>`;
    document.body.appendChild(box);
    box.querySelectorAll("[data-lang]").forEach(b =>
      b.addEventListener("click", () => applyLang(b.dataset.lang)));

    const form = box.querySelector("form");
    form.addEventListener("submit", async function (ev) {
      ev.preventDefault();                       // stop the browser reloading the page
      const user = form.user.value.trim().toLowerCase();
      const pass = form.pass.value;
      const msg = box.querySelector(".rc-login-msg");
      msg.innerHTML = t("Checking…", "Vérification…");
      try {
        const r = await api("login", { user: user, pass: pass });
        if (!r.ok) { msg.innerHTML = t("Wrong username or password.", "Identifiant ou mot de passe incorrect."); return; }
        AUTH = { user: user, pass: pass, name: r.name || user };
        sessionStorage.setItem(AUTH_KEY, JSON.stringify(AUTH));
        STATE = Object.assign(emptyState(), r.state || {});
        sessionStorage.setItem("rc_state_cache", JSON.stringify(STATE));
        // Resume: jump to the page and section where the student stopped
        if (STATE.lastPage && STATE.lastPage !== PAGE_ID) {
          location.href = STATE.lastPage + ".html" + (STATE.lastSection ? "#" + STATE.lastSection : "");
          return;
        }
        box.remove();
        start(true);
      } catch (e) {
        msg.innerHTML = t("Cannot reach the server. Check your internet connection.",
                          "Serveur injoignable. Vérifiez votre connexion internet.");
      }
    });
  }

  function logout() {
    saveNow();
    sessionStorage.removeItem(AUTH_KEY);
    sessionStorage.removeItem("rc_state_cache");
    setTimeout(() => location.href = "index.html", 400);
  }

  /* --------------------------------------------------------------------------
     PART 3 — Language switch
     CSS rule (course.css): html.lang-fr .en {display:none} and vice versa.
     -------------------------------------------------------------------------- */
  function currentLang() {
    return document.documentElement.classList.contains("lang-en") ? "en" : "fr";
  }
  function applyLang(lang) {
    const h = document.documentElement;
    h.classList.remove("lang-en", "lang-fr");
    h.classList.add("lang-" + lang);
    h.setAttribute("lang", lang);
    try { localStorage.setItem("rc_lang", lang); } catch (e) {}
    if (STATE && STATE.lang !== lang) { STATE.lang = lang; saveSoon(); }
  }
  // t("English", "Français") -> bilingual snippet for HTML built in JS
  function t(en, fr) { return `<span class="en">${en}</span><span class="fr">${fr}</span>`; }

  /* --------------------------------------------------------------------------
     PART 4 — Watermark, signature, navbar extras
     -------------------------------------------------------------------------- */
  function addWatermark() {
    // An SVG tile with the author name, repeated diagonally in the background
    const svg = `<svg xmlns='http://www.w3.org/2000/svg' width='360' height='220'>
      <text x='20' y='140' transform='rotate(-24 180 110)' font-family='Georgia,serif'
      font-size='20' fill='#0b3d5c' fill-opacity='0.055'>by ${CFG.author}</text></svg>`;
    const wm = document.createElement("div");
    wm.className = "rc-watermark";
    wm.style.backgroundImage = 'url("data:image/svg+xml;utf8,' + encodeURIComponent(svg) + '")';
    document.body.appendChild(wm);

    const foot = document.createElement("footer");
    foot.className = "rc-footer";
    foot.innerHTML = `<span class="rc-sign">by ${CFG.author}</span>
      <span>© ${new Date().getFullYear()} · ${t("Course material — please do not redistribute without permission",
                                                  "Support de cours — merci de ne pas diffuser sans autorisation")}</span>`;
    (document.querySelector(".main-container") || document.body).appendChild(foot);
  }

  function addNavbarExtras() {
    const nav = document.querySelector(".navbar .navbar-collapse") || document.querySelector(".navbar");
    if (!nav) return;
    const ul = document.createElement("ul");
    ul.className = "nav navbar-nav navbar-right rc-nav-extra";
    ul.innerHTML = `
      <li><a href="#" class="rc-lang-btn" title="Language / Langue">${t("FR", "EN")}</a></li>
      <li><span class="rc-user">${AUTH.name}</span><span class="rc-save" data-s=""></span></li>
      <li><a href="#" class="rc-logout">${t("Log out", "Déconnexion")}</a></li>`;
    nav.appendChild(ul);
    ul.querySelector(".rc-lang-btn").addEventListener("click", e => {
      e.preventDefault(); applyLang(currentLang() === "en" ? "fr" : "en");
    });
    ul.querySelector(".rc-logout").addEventListener("click", e => { e.preventDefault(); logout(); });
  }
  function setSaveStatus(s) {
    const el = document.querySelector(".rc-save");
    if (!el) return;
    el.dataset.s = s;
    el.innerHTML = s === "saving" ? t("saving…", "enregistrement…")
                 : s === "saved"  ? t("saved", "enregistré")
                 : t("not saved — check connection", "non enregistré — vérifiez la connexion");
  }

  /* --------------------------------------------------------------------------
     PART 5 — Sidebar table of contents, "mark as done", resume position
     Each "## Title" in the .Rmd becomes <div class="section level2" id="...">.
     -------------------------------------------------------------------------- */
  function pageState() {
    STATE.pages[PAGE_ID] = STATE.pages[PAGE_ID] || { done: [], total: 0 };
    return STATE.pages[PAGE_ID];
  }

  function buildSections() {
    const main = document.querySelector(".main-container");
    const secs = Array.from(main.querySelectorAll("div.section.level2"))
                      .filter(s => !s.classList.contains("no-track"));
    if (!secs.length || PAGE_ID === "index") return;
    const ps = pageState();
    ps.total = secs.length;

    // --- sidebar ---
    const side = document.createElement("nav");
    side.className = "rc-side";
    side.innerHTML = `<div class="rc-side-title">${t("In this session", "Dans cette séance")}</div>
      <div class="rc-progress"><div class="rc-progress-bar"></div></div>
      <div class="rc-progress-label"></div><ol></ol>`;
    const ol = side.querySelector("ol");
    secs.forEach(sec => {
      const h = sec.querySelector("h2");
      const li = document.createElement("li");
      li.dataset.id = sec.id;
      li.innerHTML = `<a href="#${sec.id}">${h.innerHTML}</a>`;   // innerHTML keeps EN/FR spans
      ol.appendChild(li);

      // --- "mark as done" button at the end of the section ---
      const btn = document.createElement("button");
      btn.className = "rc-done-btn";
      btn.addEventListener("click", () => {
        const i = ps.done.indexOf(sec.id);
        if (i === -1) ps.done.push(sec.id); else ps.done.splice(i, 1);
        refresh(); saveSoon();
      });
      sec.appendChild(btn);
      sec._btn = btn;
    });
    document.body.appendChild(side);

    function refresh() {
      secs.forEach(sec => {
        const done = ps.done.indexOf(sec.id) !== -1;
        sec.classList.toggle("rc-is-done", done);
        sec._btn.innerHTML = done ? t("✓ Section done (click to undo)", "✓ Section terminée (cliquer pour annuler)")
                                  : t("Mark this section as done", "Marquer cette section comme terminée");
        side.querySelector(`li[data-id="${sec.id}"]`).classList.toggle("done", done);
      });
      const pct = Math.round(100 * ps.done.length / ps.total);
      side.querySelector(".rc-progress-bar").style.width = pct + "%";
      side.querySelector(".rc-progress-label").innerHTML = pct + " % " + t("completed", "terminé");
    }
    refresh();

    // --- remember the section currently on screen (to resume later) ---
    // IntersectionObserver = "tell me when this element enters the screen"
    const obs = new IntersectionObserver(entries => {
      entries.forEach(en => {
        if (en.isIntersecting) {
          const id = en.target.parentElement.id;
          side.querySelectorAll("li").forEach(li => li.classList.toggle("current", li.dataset.id === id));
          if (STATE.lastSection !== id) { STATE.lastSection = id; saveSoon(); }
        }
      });
    }, { rootMargin: "0px 0px -70% 0px" });
    secs.forEach(sec => obs.observe(sec.querySelector("h2")));
  }

  /* --------------------------------------------------------------------------
     PART 6 — Quizzes
     The R helper quiz() writes <div class="quiz" data-q="BASE64(JSON)">.
     -------------------------------------------------------------------------- */
  function decode(b64) {
    // atob() decodes base64; the TextDecoder handles accents (é, à...)
    const bytes = Uint8Array.from(atob(b64), c => c.charCodeAt(0));
    return JSON.parse(new TextDecoder().decode(bytes));
  }
  function norm(s) { return String(s).trim().toLowerCase().replace(/\s+/g, " "); }
  function toNumber(s) { return parseFloat(String(s).replace(",", ".").replace(/[^0-9.\-eE]/g, "")); }

  // Number of attempts allowed per quiz (config.js: maxAttempts, default 1)
  const MAX_ATTEMPTS = CFG.maxAttempts || 1;

  function buildQuizzes() {
    document.querySelectorAll(".quiz").forEach(el => {
      const id = el.dataset.quizId;
      const qs = decode(el.dataset.q);
      // optional custom title (practice exercises), otherwise the default one
      const title = el.dataset.titleEn
        ? t(el.dataset.titleEn, el.dataset.titleFr)
        : t("Quiz — enter the results of your application work",
            "Quiz — saisissez les résultats de votre travail d'application");
      let html = `<h3 class="rc-quiz-title">${title}</h3>
        <p class="rc-quiz-rule">${MAX_ATTEMPTS === 1
          ? t("<b>One attempt only.</b> Check every answer in your script before submitting: your score is final.",
              "<b>Une seule tentative.</b> Vérifiez chaque réponse dans votre script avant de valider : votre score est définitif.")
          : t(`You have ${MAX_ATTEMPTS} attempts.`, `Vous avez ${MAX_ATTEMPTS} tentatives.`)}</p>
        <ol class="rc-q-list">`;
      qs.forEach((q, i) => {
        html += `<li class="rc-q" data-i="${i}"><div class="rc-q-text">${t(q.en, q.fr)}</div>`;
        if (q.type === "mcq") {
          q.options_en.forEach((o, j) => {
            html += `<label class="rc-opt"><input type="radio" name="${id}-${i}" value="${j}">
                     ${t(o, q.options_fr[j])}</label>`;
          });
        } else {
          html += `<input class="rc-input" type="text" inputmode="${q.type === "num" ? "decimal" : "text"}"
                   placeholder="${q.type === "num" ? "e.g. 12.5" : "…"}">`;
          if (q.hint_en) html += `<div class="rc-hint">${t(q.hint_en, q.hint_fr)}</div>`;
        }
        html += `<div class="rc-feedback"></div></li>`;
      });
      html += `</ol><div class="rc-actions"><button class="rc-submit">${t("Submit my answers", "Valider mes réponses")}</button>
               <button class="rc-cancel" hidden>${t("Go back", "Revenir")}</button></div>
               <p class="rc-warn"></p><div class="rc-score"></div>`;
      el.innerHTML = html;

      // Already done: show the saved answers, the feedback and lock the quiz
      const prev = STATE.quizzes[id];
      if (prev) {
        if (prev.answers) fill(el, qs, prev.answers);
        showFeedback(el, qs, prev.answers || []);
        showScore(el, prev);
        if ((prev.attempts || 1) >= MAX_ATTEMPTS) lockQuiz(el);
      }

      // Two-step submit: 1st click asks for confirmation, 2nd click grades
      const btn = el.querySelector(".rc-submit"), cancel = el.querySelector(".rc-cancel");
      const warn = el.querySelector(".rc-warn");
      let armed = false;
      btn.addEventListener("click", () => {
        if (!armed) {
          const ans = readAnswers(el, qs);
          const empty = ans.filter(a => a === null || String(a).trim() === "").length;
          warn.innerHTML = (empty ? t(`${empty} question(s) not answered. `, `${empty} question(s) sans réponse. `) : "")
            + t("Are you sure? You cannot change your answers afterwards.",
                "Êtes-vous sûr(e) ? Vous ne pourrez plus modifier vos réponses.");
          btn.innerHTML = t("Yes, submit definitively", "Oui, valider définitivement");
          btn.classList.add("rc-armed"); cancel.hidden = false; armed = true;
          return;
        }
        armed = false; cancel.hidden = true; warn.innerHTML = "";
        grade(el, id, qs);
      });
      cancel.addEventListener("click", () => {
        armed = false; cancel.hidden = true; warn.innerHTML = "";
        btn.classList.remove("rc-armed");
        btn.innerHTML = t("Submit my answers", "Valider mes réponses");
      });
    });
  }

  function lockQuiz(el) {
    el.classList.add("rc-locked");
    el.querySelectorAll("input").forEach(i => i.disabled = true);
    el.querySelector(".rc-actions").hidden = true;
  }

  function readAnswers(el, qs) {
    return qs.map((q, i) => {
      const li = el.querySelector(`.rc-q[data-i="${i}"]`);
      if (q.type === "mcq") {
        const r = li.querySelector("input:checked");
        return r ? Number(r.value) : null;
      }
      return li.querySelector(".rc-input").value;
    });
  }
  function fill(el, qs, ans) {
    qs.forEach((q, i) => {
      const li = el.querySelector(`.rc-q[data-i="${i}"]`);
      if (ans[i] === null || ans[i] === undefined) return;
      if (q.type === "mcq") { const r = li.querySelector(`input[value="${ans[i]}"]`); if (r) r.checked = true; }
      else li.querySelector(".rc-input").value = ans[i];
    });
  }
  function isCorrect(q, a) {
    if (a === null || a === undefined || a === "") return false;
    if (q.type === "mcq") return a === q.answer;
    if (q.type === "num") { const x = toNumber(a); return !isNaN(x) && Math.abs(x - q.answer) <= q.tol + 1e-9; }
    return q.answer.map(norm).indexOf(norm(a)) !== -1;
  }

  // Colours each question green / red. The correct value is not shown:
  // the unlocked solution below the quiz explains how to obtain it.
  function showFeedback(el, qs, ans) {
    let score = 0;
    qs.forEach((q, i) => {
      const ok = isCorrect(q, ans[i]);
      if (ok) score++;
      const li = el.querySelector(`.rc-q[data-i="${i}"]`);
      li.classList.remove("ok", "ko"); li.classList.add(ok ? "ok" : "ko");
      li.querySelector(".rc-feedback").innerHTML = ok ? t("Correct", "Correct")
        : t("Incorrect — compare your script with the solution below.",
            "Incorrect — comparez votre script avec la solution ci-dessous.");
    });
    return score;
  }

  function grade(el, id, qs) {
    const ans = readAnswers(el, qs);
    const score = showFeedback(el, qs, ans);
    const prev = STATE.quizzes[id] || { best: 0, attempts: 0 };
    const rec = { score: score, max: qs.length, best: Math.max(prev.best || 0, score),
                  attempts: (prev.attempts || 0) + 1, date: new Date().toISOString(), answers: ans };
    if (!prev.attempts) rec.first = score;           // the official (first) score
    else rec.first = prev.first;
    STATE.quizzes[id] = rec;
    showScore(el, rec);
    if (rec.attempts >= MAX_ATTEMPTS) lockQuiz(el);
    unlockSolutions();
    dirty = true; saveNow();
    // also record the attempt in the "scores" tab of the Google Sheet
    if (!DEMO) api("score", { user: AUTH.user, pass: AUTH.pass, quiz: id, page: PAGE_ID,
                              score: score, max: qs.length, answers: ans }).catch(() => {});
  }
  function showScore(el, rec) {
    const pct = Math.round(100 * rec.score / rec.max);
    el.querySelector(".rc-score").innerHTML = `
      <div class="rc-score-ring" style="--p:${pct}"><span>${rec.score}/${rec.max}</span></div>
      <div>${t("Your score", "Votre score")}: <b>${rec.score}/${rec.max}</b> (${pct} %)
           ${MAX_ATTEMPTS > 1 ? `· ${t("Attempts", "Tentatives")}: ${rec.attempts}/${MAX_ATTEMPTS}` : ""}<br>
           <small>${pct >= 70 ? t("Well done! Read the solution to check the details, then move on.",
                                  "Bravo ! Lisez la solution pour vérifier les détails, puis continuez.")
                               : t("Study the solution carefully and re-do the exercise in your script before moving on.",
                                   "Étudiez attentivement la solution et refaites l'exercice dans votre script avant de continuer.")}</small></div>`;
  }

  /* --------------------------------------------------------------------------
     PART 7 — Extras: solutions, copy buttons, dashboard
     -------------------------------------------------------------------------- */
  // Solutions (::: {.solution data-quiz="s01"} in the .Rmd) stay locked until
  // the student has submitted the quiz once.
  function unlockSolutions() {
    document.querySelectorAll(".solution").forEach(sol => {
      const open = !!STATE.quizzes[sol.dataset.quiz];
      sol.classList.toggle("locked", !open);
      if (!sol.querySelector(".rc-sol-head")) {
        const head = document.createElement("div");
        head.className = "rc-sol-head";
        sol.prepend(head);
        head.addEventListener("click", () => { if (!sol.classList.contains("locked")) sol.classList.toggle("open"); });
      }
      sol.querySelector(".rc-sol-head").innerHTML = open
        ? t("Solution — click to show / hide", "Solution — cliquer pour afficher / masquer")
        : t("Solution (unlocked after you submit the quiz)", "Solution (débloquée après avoir validé le quiz)");
    });
  }

  function addCopyButtons() {
    document.querySelectorAll("pre.r, pre.sourceCode").forEach(pre => {
      if (pre.parentElement.classList.contains("rc-code-wrap")) return;
      const wrap = document.createElement("div");
      wrap.className = "rc-code-wrap";
      pre.parentNode.insertBefore(wrap, pre); wrap.appendChild(pre);
      const b = document.createElement("button");
      b.className = "rc-copy"; b.innerHTML = t("Copy", "Copier");
      b.addEventListener("click", () => {
        navigator.clipboard.writeText(pre.innerText).then(() => {
          b.innerHTML = t("Copied", "Copié"); setTimeout(() => b.innerHTML = t("Copy", "Copier"), 1500);
        });
      });
      wrap.appendChild(b);
    });
  }

  // On index.html, <div id="dashboard"></div> becomes a progress table
  function buildDashboard() {
    const box = document.getElementById("dashboard");
    if (!box) return;
    let rows = "", sumScore = 0, sumMax = 0;
    CFG.pages.forEach(p => {
      const ps = STATE.pages[p.id];
      const pct = ps && ps.total ? Math.round(100 * ps.done.length / ps.total) : 0;
      // a page can have one quiz ("quiz") or several ("quizzes", e.g. the practice session)
      const ids = p.quizzes || (p.quiz ? [p.quiz] : []);
      let ps_ = 0, pm_ = 0, done_ = 0;
      ids.forEach(qid => {
        const q = STATE.quizzes[qid];
        if (q) { const sc = (q.first !== undefined ? q.first : q.score); ps_ += sc; pm_ += q.max; done_++; }
      });
      sumScore += ps_; sumMax += pm_;
      const cell = !done_ ? "—" : `<b>${ps_}/${pm_}</b>` + (ids.length > 1 ? ` <small>(${done_}/${ids.length} quiz)</small>` : "");
      rows += `<tr><td><a href="${p.id}.html">${t(p.en, p.fr)}</a></td><td>${p.hours} h</td>
        <td><div class="rc-mini"><div style="width:${pct}%"></div></div> ${pct} %</td>
        <td>${cell}</td></tr>`;
    });
    const cont = STATE.lastPage && STATE.lastPage !== "index"
      ? `<a class="rc-continue" href="${STATE.lastPage}.html${STATE.lastSection ? "#" + STATE.lastSection : ""}">
           ${t("Continue where you stopped", "Reprendre là où vous vous êtes arrêté")} →</a>`
      : `<a class="rc-continue" href="00-installation.html">${t("Start the course", "Commencer le cours")} →</a>`;
    box.innerHTML = `<p class="rc-hello">${t("Hello", "Bonjour")} <b>${AUTH.name}</b> ·
        ${t("Total quiz score", "Score total aux quiz")}: <b>${sumScore}/${sumMax || "—"}</b></p>${cont}
      <table class="rc-dash"><thead><tr><th>${t("Session", "Séance")}</th><th>${t("Time", "Durée")}</th>
      <th>${t("Progress", "Progression")}</th><th>${t("Quiz score", "Score quiz")}</th></tr></thead>
      <tbody>${rows}</tbody></table>`;
  }

  /* --------------------------------------------------------------------------
     PART 8 — Start-up
     -------------------------------------------------------------------------- */
  function start(fresh) {
    document.documentElement.classList.add("rc-authed");
    applyLang(STATE.lang || currentLang());
    if (PAGE_ID !== "index") STATE.lastPage = PAGE_ID;
    addNavbarExtras();
    buildSections();
    buildQuizzes();
    unlockSolutions();
    addCopyButtons();
    buildDashboard();
    sessionStorage.setItem("rc_state_cache", JSON.stringify(STATE));
    if (fresh || PAGE_ID !== "index") saveSoon();
  }

  // Language must be set immediately (before the page is drawn) to avoid flicker
  let lang0 = CFG.defaultLang || "en";
  try { lang0 = localStorage.getItem("rc_lang") || lang0; } catch (e) {}
  document.documentElement.classList.add("lang-" + lang0);

  document.addEventListener("DOMContentLoaded", function () {
    addWatermark();
    try { AUTH = JSON.parse(sessionStorage.getItem(AUTH_KEY)); } catch (e) { AUTH = null; }
    if (!AUTH) { showLogin(); return; }
    // Already logged in this tab: reuse the cached state, then refresh it
    try { STATE = Object.assign(emptyState(), JSON.parse(sessionStorage.getItem("rc_state_cache"))); }
    catch (e) { STATE = emptyState(); }
    start(false);
  });
})();
