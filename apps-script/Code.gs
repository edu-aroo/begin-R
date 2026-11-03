/* ============================================================================
   Code.gs — Google Apps Script "backend" of the course
   ----------------------------------------------------------------------------
   It receives requests from the course website and reads/writes a Google
   Sheet with 3 tabs:
     students : username | password | full_name | active      (YOU fill this)
     progress : username | full_name | last_page | last_section | updated | state_json
     scores   : timestamp | username | full_name | quiz | page | score | max | answers
   HOW TO INSTALL: see README.md, section "Connect the Google Sheet".
   After ANY change to this file: Deploy > Manage deployments > Edit > New version.
   ============================================================================ */

// Run this function ONCE by hand (select "setup" then click Run) to create the tabs
function setup() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const tabs = {
    students: ["username", "password", "full_name", "active"],
    progress: ["username", "full_name", "last_page", "last_section", "updated", "state_json"],
    scores:   ["timestamp", "username", "full_name", "quiz", "page", "score", "max", "answers"]
  };
  Object.keys(tabs).forEach(function (name) {
    let sh = ss.getSheetByName(name);
    if (!sh) sh = ss.insertSheet(name);
    if (sh.getLastRow() === 0) {
      sh.appendRow(tabs[name]);
      sh.getRange(1, 1, 1, tabs[name].length).setFontWeight("bold");
      sh.setFrozenRows(1);
    }
  });
  // an example account, delete it when you add your students
  const st = ss.getSheetByName("students");
  if (st.getLastRow() === 1) st.appendRow(["test01", "reef2026", "Test Student", "yes"]);
}

// Every request from the website arrives here (POST)
function doPost(e) {
  let req;
  try { req = JSON.parse(e.postData.contents); }
  catch (err) { return out({ ok: false, error: "bad_request" }); }

  const student = checkLogin(req.user, req.pass);
  if (!student) return out({ ok: false, error: "bad_login" });

  // LockService prevents two requests writing in the sheet at the same time
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    if (req.action === "login") return out({ ok: true, name: student.name, state: readState(req.user) });
    if (req.action === "save")  { writeState(student, req.state); return out({ ok: true }); }
    if (req.action === "score") { logScore(student, req); return out({ ok: true }); }
    return out({ ok: false, error: "unknown_action" });
  } finally {
    lock.releaseLock();
  }
}

// Opening the URL in a browser simply shows that the script is alive
function doGet() { return out({ ok: true, message: "Course backend is running" }); }

// ---------------------------------------------------------------------------
function out(obj) {   // send a JSON answer back to the website
  return ContentService.createTextOutput(JSON.stringify(obj))
                       .setMimeType(ContentService.MimeType.JSON);
}

function sheet(name) { return SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name); }

// Returns {user, name} if username + password match an active student, else null
function checkLogin(user, pass) {
  if (!user || !pass) return null;
  const rows = sheet("students").getDataRange().getValues();   // 2-D array, like a data.frame
  for (let i = 1; i < rows.length; i++) {                        // i = 1 skips the header
    const u = String(rows[i][0]).trim().toLowerCase();
    const p = String(rows[i][1]);
    const active = String(rows[i][3] || "yes").toLowerCase() !== "no";
    if (u === String(user).trim().toLowerCase() && p === String(pass) && active) {
      return { user: u, name: String(rows[i][2] || u) };
    }
  }
  return null;
}

// Find the row number of a student in the "progress" tab (or -1)
function findRow(sh, user) {
  const col = sh.getRange(1, 1, Math.max(sh.getLastRow(), 1), 1).getValues();
  for (let i = 1; i < col.length; i++) if (String(col[i][0]).toLowerCase() === user) return i + 1;
  return -1;
}

function readState(user) {
  const sh = sheet("progress");
  const r = findRow(sh, user);
  if (r === -1) return null;
  try { return JSON.parse(sh.getRange(r, 6).getValue()); } catch (err) { return null; }
}

function writeState(student, state) {
  const sh = sheet("progress");
  const row = [student.user, student.name, state.lastPage || "", state.lastSection || "",
               new Date(), JSON.stringify(state)];
  const r = findRow(sh, student.user);
  if (r === -1) sh.appendRow(row);
  else sh.getRange(r, 1, 1, row.length).setValues([row]);
}

function logScore(student, req) {
  sheet("scores").appendRow([new Date(), student.user, student.name, req.quiz, req.page,
                             req.score, req.max, JSON.stringify(req.answers)]);
}
