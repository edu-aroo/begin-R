# make_git_svgs.py — draws the Windows-style illustrations of Session A2 (Git with RStudio)
# Run: python3 R/svg/make_git_svgs.py   -> writes assets/img/git-*.svg
# UI texts are in English (RStudio, GitHub and GitLab menus); notes are bilingual (class en / fr).
import os, html
OUT = "assets/img"
F = 'font-family="Segoe UI, Source Sans 3, Arial, Helvetica, sans-serif"'
MONO = 'font-family="Consolas, JetBrains Mono, DejaVu Sans Mono, monospace"'
ACC = "#d9694a"; OCEAN = "#0b3d5c"; LAG = "#1b7f8c"; GREY = "#5d6b75"; LINE = "#c9d3d8"
def e(t): return html.escape(t, quote=True)

def svg(w, h, body, label):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" role="img" aria-label="{e(label)}" {F}>\n{body}\n</svg>\n'

def window(x, y, w, h, title, icon=None):
    """A Windows 11 style window: white title bar, minimise / maximise / close on the right."""
    s = f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="8" fill="#fff" stroke="#8a969c" stroke-width="1.5"/>'
    s += f'<rect x="{x}" y="{y}" width="{w}" height="32" rx="8" fill="#f3f3f3"/><rect x="{x}" y="{y+24}" width="{w}" height="8" fill="#f3f3f3"/>'
    s += f'<line x1="{x}" y1="{y+32}" x2="{x+w}" y2="{y+32}" stroke="#dcdcdc"/>'
    if icon: s += f'<rect x="{x+12}" y="{y+9}" width="14" height="14" rx="3" fill="{icon}"/>'
    s += f'<text x="{x+(34 if icon else 14)}" y="{y+21}" font-size="13" fill="#222">{e(title)}</text>'
    cx = x + w
    s += f'<text x="{cx-104}" y="{y+21}" font-size="13" fill="#333">&#x2014;</text>'
    s += f'<rect x="{cx-66}" y="{y+11}" width="10" height="10" fill="none" stroke="#333"/>'
    s += f'<text x="{cx-28}" y="{y+22}" font-size="15" fill="#333">&#x2715;</text>'
    return s

def note(n, x, y, en, fr, tx=None, ty=None, anchor="start", w=None):
    """Numbered orange bubble at (x, y) and its bilingual note at (tx, ty)."""
    s = f'<circle cx="{x}" cy="{y}" r="11" fill="{ACC}"/><text x="{x}" y="{y+4.5}" text-anchor="middle" font-size="13" font-weight="700" fill="#fff">{n}</text>'
    if tx is not None:
        s += f'<text class="en" x="{tx}" y="{ty}" font-size="13" fill="{OCEAN}" text-anchor="{anchor}">{lines(en, tx)}</text>'
        s += f'<text class="fr" x="{tx}" y="{ty}" font-size="13" fill="{OCEAN}" text-anchor="{anchor}">{lines(fr, tx)}</text>'
    return s

def lines(t, x):
    parts = t.split("|")
    return "".join(f'<tspan x="{x}" dy="{0 if i == 0 else 16}">{e(p)}</tspan>' for i, p in enumerate(parts))

def button(x, y, w, label, fill="#fff", col="#222", stroke="#b5b5b5", bold=False):
    fw = ' font-weight="600"' if bold else ''
    return (f'<rect x="{x}" y="{y}" width="{w}" height="26" rx="4" fill="{fill}" stroke="{stroke}"/>'
            f'<text x="{x+w/2}" y="{y+17}" text-anchor="middle" font-size="12.5" fill="{col}"{fw}>{e(label)}</text>')

def field(x, y, w, value, label=None, mono=False):
    s = ""
    if label: s += f'<text x="{x}" y="{y-6}" font-size="12.5" fill="#333">{e(label)}</text>'
    s += f'<rect x="{x}" y="{y}" width="{w}" height="26" rx="3" fill="#fff" stroke="#9e9e9e"/>'
    s += f'<text x="{x+8}" y="{y+17}" font-size="12.5" fill="#111" {MONO if mono else ""}>{e(value)}</text>'
    return s

def check(x, y, label, on=True):
    s = f'<rect x="{x}" y="{y}" width="14" height="14" rx="2" fill="{"#0067c0" if on else "#fff"}" stroke="#555"/>'
    if on: s += f'<path d="M{x+3} {y+7} l3 3 l6 -7" stroke="#fff" stroke-width="2" fill="none"/>'
    return s + f'<text x="{x+22}" y="{y+12}" font-size="12.5" fill="#222">{e(label)}</text>'

def radio(x, y, label, on=False):
    s = f'<circle cx="{x+7}" cy="{y+7}" r="7" fill="#fff" stroke="#555"/>'
    if on: s += f'<circle cx="{x+7}" cy="{y+7}" r="3.5" fill="#0067c0"/>'
    return s + f'<text x="{x+22}" y="{y+12}" font-size="12.5" fill="#222">{e(label)}</text>'

files = {}

# 1. Global Options -> Git/SVN -------------------------------------------------------------
b = window(20, 20, 640, 360, "Options", icon="#75aadb")
items = ["General", "Code", "Console", "Appearance", "Pane Layout", "Packages", "R Markdown", "Python", "Sweave", "Spelling", "Git/SVN", "Publishing", "Terminal", "Accessibility", "Copilot"]
for i, it in enumerate(items):
    yy = 74 + i * 19
    if it == "Git/SVN":
        b += f'<rect x="28" y="{yy-14}" width="130" height="20" fill="#cce4f7"/>'
    b += f'<text x="40" y="{yy}" font-size="12.5" fill="#222">{e(it)}</text>'
b += '<line x1="165" y1="52" x2="165" y2="372" stroke="#ddd"/>'
b += check(182, 62, "Enable version control interface for RStudio projects")
b += field(182, 108, 330, "C:/Program Files/Git/bin/git.exe", "Git executable:", mono=True) + button(522, 108, 70, "Browse...")
b += field(182, 160, 330, "(Not Found)", "SVN executable:", mono=True)
b += f'<text x="182" y="226" font-size="12.5" fill="#0067c0" text-decoration="underline">Create SSH Key...</text>'
b += button(450, 340, 64, "OK", fill="#0067c0", col="#fff", stroke="#0067c0") + button(520, 340, 64, "Cancel") + button(590, 340, 60, "Apply")
b += note(1, 150, 260, "", "") + note(2, 600, 121, "", "")
b += note(1, 690, 70, "Tools → Global Options… → Git/SVN", "Tools → Global Options… → Git/SVN", 708, 75)
b += note(2, 690, 120, "Path to git.exe: filled automatically|after installing Git for Windows.|Empty? Browse to C:/Program Files/Git/bin/|then restart RStudio.", "Chemin de git.exe : rempli tout seul|après installation de Git for Windows.|Vide ? Browse vers C:/Program Files/Git/bin/|puis redémarrez RStudio.", 708, 125)
b += note(3, 690, 230, "Tools → Global Options… → Terminal:|\"New terminals open with: Git Bash\"", "Tools → Global Options… → Terminal :|« New terminals open with: Git Bash »", 708, 235)
b += note(3, 150, 298, "", "")
files["git-options"] = svg(1000, 400, b, "RStudio Global Options, Git/SVN")

# 2. First configuration in the Terminal -----------------------------------------------------
b = window(20, 20, 760, 300, "RStudio", icon="#75aadb")
tabs = ["Console", "Terminal", "Background Jobs"]
x = 30
for t in tabs:
    w = 9 * len(t) + 24
    b += f'<rect x="{x}" y="58" width="{w}" height="26" fill="{"#fff" if t == "Terminal" else "#eef1f3"}" stroke="#ccd"/><text x="{x+12}" y="76" font-size="12.5" fill="#222">{t}</text>'
    x += w + 2
b += f'<text x="{x+10}" y="76" font-size="12" fill="{GREY}">Terminal 1 (Git Bash) ▾</text>'
b += '<rect x="30" y="86" width="740" height="222" fill="#fff" stroke="#ccd"/>'
lines_t = [("#3a8a3a", "Fara@LAPTOP MINGW64 ~/Documents/R/reef-monitoring (main)"),
           ("#111", "$ git config --global user.name \"Fara Rasoa\""),
           ("#111", "$ git config --global user.email \"fara@example.org\""),
           ("#111", "$ git config --global init.defaultBranch main"),
           ("#111", "$ git config --global --list"),
           ("#555", "user.name=Fara Rasoa"), ("#555", "user.email=fara@example.org"), ("#555", "init.defaultbranch=main"),
           ("#111", "$ ")]
for i, (c, t) in enumerate(lines_t):
    b += f'<text x="42" y="{110 + i * 22}" font-size="13" fill="{c}" {MONO}>{e(t)}</text>'
b += note(1, 800, 105, "Tools → Terminal → New Terminal|(Alt + Shift + R). Once per computer.", "Tools → Terminal → New Terminal|(Alt + Maj + R). Une fois par ordinateur.", 818, 110)
b += note(2, 800, 170, "Your name and the e-mail of|your GitHub / GitLab account.", "Votre nom et l'e-mail de votre|compte GitHub / GitLab.", 818, 175)
b += note(3, 800, 235, "--list checks what Git knows.", "--list vérifie ce que Git a retenu.", 818, 240)
files["git-terminal-config"] = svg(1060, 340, b, "First Git configuration in the RStudio Terminal")

# 3. GitHub: create a repository ------------------------------------------------------------
b = window(20, 20, 640, 470, "Create a new repository - GitHub — Microsoft Edge", icon="#24292f")
b += '<rect x="21" y="53" width="638" height="30" fill="#f6f8fa"/><text x="40" y="73" font-size="12" fill="#57606a">github.com/new</text>'
b += f'<text x="50" y="112" font-size="20" font-weight="600" fill="#1f2328">Create a new repository</text>'
b += field(50, 148, 140, "fara-rasoa ▾", "Owner *") + f'<text x="198" y="166" font-size="18" fill="#57606a">/</text>' + field(212, 148, 250, "reef-monitoring", "Repository name *", mono=True)
b += field(50, 204, 412, "Coral reef monitoring of the three MPAs", "Description (optional)")
b += radio(50, 246, "Public — anyone on the internet can see it") + radio(50, 270, "Private — you choose who can see and commit", on=True)
b += check(50, 306, "Add a README file") + field(50, 346, 170, "Add .gitignore: R ▾") + field(232, 346, 170, "Choose a license: None ▾")
b += button(50, 400, 160, "Create repository", fill="#1f883d", col="#fff", stroke="#1a7f37", bold=True)
b += note(1, 480, 160, "", "") + note(2, 480, 270, "", "") + note(3, 480, 314, "", "") + note(4, 225, 413, "", "")
b += note(1, 690, 120, "Profile picture → Your repositories → New|(or the + button, top right). Short name,|no spaces: it will be the project folder.", "Photo de profil → Your repositories → New|(ou le bouton +, en haut à droite). Nom court,|sans espaces : ce sera le dossier du projet.", 708, 125)
b += note(2, 690, 205, "Private: only you and the people you invite.|Free accounts: GitHub Pages needs Public.", "Private : vous seul et les personnes invitées.|Compte gratuit : GitHub Pages demande Public.", 708, 210)
b += note(3, 690, 270, "Tick README + .gitignore template R:|the repository is ready to be cloned.", "Cochez README + modèle .gitignore R :|le dépôt est prêt à être cloné.", 708, 275)
b += note(4, 690, 335, "Then Code ▾ → HTTPS → copy the address|https://github.com/fara-rasoa/reef-monitoring.git", "Puis Code ▾ → HTTPS → copiez l'adresse|https://github.com/fara-rasoa/reef-monitoring.git", 708, 340)
files["git-github-new"] = svg(1060, 510, b, "Create a new repository on GitHub")

# 4. GitLab: create a project ---------------------------------------------------------------
b = window(20, 20, 640, 470, "Create blank project · GitLab — Microsoft Edge", icon="#fc6d26")
b += '<rect x="21" y="53" width="638" height="30" fill="#fafafa"/><text x="40" y="73" font-size="12" fill="#57606a">gitlab.com/projects/new#blank_project</text>'
b += f'<text x="50" y="112" font-size="20" font-weight="600" fill="#28272d">Create blank project</text>'
b += field(50, 148, 412, "reef-monitoring", "Project name", mono=True)
b += field(50, 204, 200, "gitlab.com/fara-rasoa/ ▾", "Project URL") + field(262, 204, 200, "reef-monitoring", "Project slug", mono=True)
b += f'<text x="50" y="258" font-size="12.5" fill="#333">Visibility Level</text>'
b += radio(50, 268, "Private", on=True) + radio(50, 292, "Internal") + radio(50, 316, "Public")
b += f'<text x="50" y="358" font-size="12.5" fill="#333">Project Configuration</text>' + check(50, 368, "Initialize repository with a README")
b += button(50, 410, 140, "Create project", fill="#1f75cb", col="#fff", stroke="#1f75cb", bold=True) + button(200, 410, 80, "Cancel")
b += note(1, 480, 160, "", "") + note(2, 480, 290, "", "") + note(3, 480, 376, "", "") + note(4, 300, 423, "", "")
b += note(1, 690, 120, "New project (+ button) → Create blank project.|The slug is the folder and the address.", "New project (bouton +) → Create blank project.|Le slug est le dossier et l'adresse.", 708, 125)
b += note(2, 690, 205, "Private projects can still have a website|(GitLab Pages, Session A9).", "Un projet privé peut quand même avoir un site|(GitLab Pages, séance A9).", 708, 210)
b += note(3, 690, 270, "Tick it: the project can be cloned at once.|Add the .gitignore later from RStudio.", "Cochez : le projet peut être cloné tout de suite.|Ajoutez le .gitignore ensuite depuis RStudio.", 708, 275)
b += note(4, 690, 335, "Then Code ▾ → Clone with HTTPS → copy|https://gitlab.com/fara-rasoa/reef-monitoring.git", "Puis Code ▾ → Clone with HTTPS → copiez|https://gitlab.com/fara-rasoa/reef-monitoring.git", 708, 340)
files["git-gitlab-new"] = svg(1060, 510, b, "Create a blank project on GitLab")

# 5. RStudio: New Project -> Version Control -> Git ------------------------------------------
b = window(20, 20, 300, 300, "New Project Wizard", icon="#75aadb")
b += f'<text x="40" y="82" font-size="14" font-weight="600" fill="#222">Create Project</text>'
for i, (t, sel) in enumerate([("New Directory", False), ("Existing Directory", False), ("Version Control", True)]):
    yy = 100 + i * 56
    b += f'<rect x="40" y="{yy}" width="260" height="46" rx="4" fill="{"#cce4f7" if sel else "#fff"}" stroke="#ccc"/><text x="58" y="{yy+28}" font-size="13.5" fill="#222">{t}</text>'
b += f'<text x="340" y="180" font-size="26" fill="{GREY}">→</text>'
b += window(370, 20, 300, 300, "New Project Wizard", icon="#75aadb")
b += f'<text x="390" y="82" font-size="14" font-weight="600" fill="#222">Create Project from Version Control</text>'
for i, (t, sel) in enumerate([("Git", True), ("Subversion", False)]):
    yy = 100 + i * 56
    b += f'<rect x="390" y="{yy}" width="260" height="46" rx="4" fill="{"#cce4f7" if sel else "#fff"}" stroke="#ccc"/><text x="408" y="{yy+28}" font-size="13.5" fill="#222">{t}</text>'
b += f'<text x="690" y="180" font-size="26" fill="{GREY}">→</text>'
b += window(720, 20, 420, 300, "New Project Wizard", icon="#75aadb")
b += f'<text x="740" y="82" font-size="14" font-weight="600" fill="#222">Clone Git Repository</text>'
b += field(740, 112, 380, "https://github.com/fara-rasoa/reef-monitoring.git", "Repository URL:", mono=True)
b += field(740, 166, 380, "reef-monitoring", "Project directory name:", mono=True)
b += field(740, 220, 300, "~/Documents/R", "Create project as subdirectory of:", mono=True) + button(1048, 220, 72, "Browse...")
b += check(740, 262, "Open in new session", on=False)
b += button(930, 288, 110, "Create Project", fill="#0067c0", col="#fff", stroke="#0067c0") + button(1048, 288, 72, "Cancel")
b += note(1, 30, 345, "File → New Project… → Version Control", "File → New Project… → Version Control", 48, 350)
b += note(2, 380, 345, "→ Git", "→ Git", 398, 350)
b += note(3, 730, 345, "Paste the HTTPS address; the folder name fills itself;|choose where to store it (avoid OneDrive folders);|Create Project: RStudio downloads (clones) the|repository and opens it as an R project with a Git tab.",
          "Collez l'adresse HTTPS ; le nom du dossier se remplit seul ;|choisissez où le ranger (évitez les dossiers OneDrive) ;|Create Project : RStudio télécharge (clone) le|dépôt et l'ouvre comme projet R avec un onglet Git.", 748, 350)
files["git-new-project"] = svg(1160, 420, b, "RStudio New Project Wizard: clone a Git repository")

# 6. The Git pane -------------------------------------------------------------------------------
b = window(20, 20, 560, 330, "RStudio — reef-monitoring", icon="#75aadb")
x = 30
for t in ["Environment", "History", "Connections", "Git", "Tutorial"]:
    w = 8.2 * len(t) + 22
    b += f'<rect x="{x}" y="58" width="{w}" height="24" fill="{"#fff" if t == "Git" else "#eef1f3"}" stroke="#ccd"/><text x="{x+11}" y="75" font-size="12.5" fill="#222" font-weight="{600 if t == "Git" else 400}">{t}</text>'
    x += w + 2
b += '<rect x="30" y="84" width="540" height="30" fill="#f7f8f9" stroke="#ccd"/>'
tb = [("Diff", 40), ("Commit", 92), ("Pull", 160), ("Push", 214), ("History", 268), ("More ▾", 336)]
for t, xx in tb:
    col = {"Pull": "#2b6cb0", "Push": "#2f855a"}.get(t, "#333")
    sym = {"Pull": "⬇ ", "Push": "⬆ ", "History": "🕘 ", "Commit": "✔ ", "Diff": "≠ "}.get(t, "")
    b += f'<text x="{xx}" y="104" font-size="12.5" fill="{col}">{sym}{t}</text>'
b += f'<text x="430" y="104" font-size="12.5" fill="#333">⎇ main ▾</text><text x="545" y="104" font-size="14" fill="#333">⟳</text>'
b += f'<text x="40" y="142" font-size="12" fill="{GREY}">Staged</text><text x="100" y="142" font-size="12" fill="{GREY}">Status</text><text x="160" y="142" font-size="12" fill="{GREY}">Path</text>'
rows = [(False, "M", "#c27a00", "R/02_clean.R"), (True, "A", "#2f855a", "R/03_analysis.R"), (False, "D", "#c53030", "R/old_test.R"),
        (False, "?", "#7b8a93", "notes_field.txt"), (False, "R", "#6b46c1", "R/01_import.R ← import.R")]
for i, (st, s, c, p) in enumerate(rows):
    yy = 152 + i * 26
    b += f'<rect x="44" y="{yy}" width="14" height="14" fill="{"#0067c0" if st else "#fff"}" stroke="#555"/>'
    if st: b += f'<path d="M47 {yy+7} l3 3 l6 -7" stroke="#fff" stroke-width="2" fill="none"/>'
    b += f'<rect x="104" y="{yy-1}" width="18" height="17" rx="3" fill="{c}"/><text x="113" y="{yy+12}" text-anchor="middle" font-size="12" font-weight="700" fill="#fff">{s}</text>'
    b += f'<text x="160" y="{yy+12}" font-size="12.5" fill="#222" {MONO}>{e(p)}</text>'
b += note(1, 64, 122, "", "") + note(2, 196, 122, "", "") + note(3, 300, 122, "", "") + note(4, 500, 122, "", "") + note(5, 84, 284, "", "")
b += note(1, 610, 50, "Diff / Commit: open the Review Changes window.", "Diff / Commit : ouvrent la fenêtre Review Changes.", 628, 55)
b += note(2, 610, 90, "Pull (blue): get the commits of the others.|Push (green): send your commits online.", "Pull (bleu) : récupérer les commits des autres.|Push (vert) : envoyer vos commits en ligne.", 628, 95)
b += note(3, 610, 145, "History: every commit; More ▾: Revert,|Ignore, Shell… (right-click works too).", "History : tous les commits ; More ▾ : Revert,|Ignore, Shell… (le clic droit marche aussi).", 628, 150)
b += note(4, 610, 200, "Current branch; the menu creates or|changes branch.", "Branche actuelle ; le menu crée ou|change de branche.", 628, 205)
b += note(5, 610, 255, "Status: M modified · A added (new, staged) ·|D deleted · ? not followed yet (untracked) ·|R renamed. Tick \"Staged\" to put a change|in the next commit.",
          "Statut : M modifié · A ajouté (nouveau, indexé) ·|D supprimé · ? pas encore suivi (untracked) ·|R renommé. Cochez « Staged » pour mettre une|modification dans le prochain commit.", 628, 260)
files["git-pane"] = svg(1000, 370, b, "The Git pane of RStudio")

# 7. Review Changes / Commit window -------------------------------------------------------------
b = window(20, 20, 820, 470, "RStudio: Review Changes", icon="#75aadb")
b += f'<text x="34" y="70" font-size="12.5" fill="#333">◉ Changes   ○ History</text><text x="230" y="70" font-size="12.5" fill="#333">⎇ main ▾</text>'
b += f'<text x="470" y="70" font-size="12.5" fill="#2b6cb0">⬇ Pull</text><text x="530" y="70" font-size="12.5" fill="#2f855a">⬆ Push</text>'
b += '<rect x="30" y="82" width="400" height="160" fill="#fff" stroke="#ccd"/>'
b += f'<text x="40" y="100" font-size="12" fill="{GREY}">Staged  Status  Path</text>'
for i, (st, s, c, p) in enumerate([(True, "M", "#c27a00", "R/02_clean.R"), (True, "A", "#2f855a", "R/03_analysis.R"), (False, "?", "#7b8a93", "notes_field.txt")]):
    yy = 110 + i * 26
    b += f'<rect x="46" y="{yy}" width="14" height="14" fill="{"#0067c0" if st else "#fff"}" stroke="#555"/>'
    if st: b += f'<path d="M49 {yy+7} l3 3 l6 -7" stroke="#fff" stroke-width="2" fill="none"/>'
    b += f'<rect x="96" y="{yy-1}" width="18" height="17" rx="3" fill="{c}"/><text x="105" y="{yy+12}" text-anchor="middle" font-size="12" font-weight="700" fill="#fff">{s}</text>'
    b += f'<text x="140" y="{yy+12}" font-size="12.5" fill="#222" {MONO}>{p}</text>'
b += f'<text x="440" y="100" font-size="12.5" fill="#333">Commit message</text>'
b += '<rect x="440" y="106" width="390" height="100" fill="#fff" stroke="#9e9e9e"/>'
b += f'<text x="448" y="126" font-size="12.5" fill="#111" {MONO}>Remove duplicated transects of 2026</text>'
b += check(440, 216, "Amend previous commit", on=False) + button(760, 212, 70, "Commit", fill="#e9e9e9")
b += '<rect x="30" y="252" width="800" height="226" fill="#fff" stroke="#ccd"/>'
b += f'<text x="40" y="270" font-size="12" fill="{GREY}">R/02_clean.R    Show ◉ Staged ○ Unstaged    Context 5 line ▾</text>'
diff = [(None, "@@ -3,6 +3,7 @@"), (" ", "old <- read.csv(here(\"data\", \"raw\", \"reef_monitoring.csv\"))"),
        (" ", "new <- read.csv(here(\"data\", \"raw\", \"reef_monitoring_2026.csv\"))"),
        ("-", "new$site_id <- toupper(new$site_id)"), ("+", "new <- distinct(new)                 # rows typed twice"),
        ("+", "new$site_id <- toupper(new$site_id)"), (" ", "all <- bind_rows(old, new)")]
for i, (k, t) in enumerate(diff):
    yy = 290 + i * 24
    if k == "+": b += f'<rect x="31" y="{yy-15}" width="798" height="22" fill="#e6ffec"/>'
    if k == "-": b += f'<rect x="31" y="{yy-15}" width="798" height="22" fill="#ffebe9"/>'
    b += f'<text x="44" y="{yy}" font-size="12.5" fill="{"#57606a" if k is None else "#111"}" {MONO}>{e((k or "") + " " + t)}</text>'
b += button(600, 450, 110, "Stage selection") + button(716, 450, 110, "Discard selection")
b += note(1, 30, 118, "", "") + note(2, 640, 160, "", "") + note(3, 795, 202, "", "") + note(4, 30, 330, "", "") + note(5, 600, 66, "", "")
b += note(1, 870, 60, "Tick the files that go together|in this commit (Staged).", "Cochez les fichiers qui vont|ensemble dans ce commit (Staged).", 888, 65)
b += note(2, 870, 120, "A short sentence saying WHY,|e.g. \"Remove duplicated transects\".", "Une phrase courte qui dit POURQUOI,|ex. « Supprime les transects en double ».", 888, 125)
b += note(3, 870, 180, "Commit: the snapshot is saved on|YOUR computer only. A window|confirms it; close it.", "Commit : l'instantané est enregistré sur|VOTRE ordinateur seulement. Une fenêtre|le confirme ; fermez-la.", 888, 185)
b += note(4, 870, 260, "Check the changes: green = added,|red = removed. \"Discard\" undoes a|change that was not committed.", "Vérifiez les changements : vert = ajouté,|rouge = supprimé. « Discard » annule une|modification non validée.", 888, 265)
b += note(5, 870, 340, "Then Push to send the commits|online (and Pull first if you|work with others).", "Puis Push pour envoyer les commits|en ligne (et Pull d'abord si vous|travaillez à plusieurs).", 888, 345)
files["git-commit-window"] = svg(1160, 510, b, "RStudio Review Changes window")

# 8. Git Credential Manager (Windows) ---------------------------------------------------------
b = window(20, 20, 420, 290, "Connect to GitHub", icon="#24292f")
b += f'<text x="230" y="96" text-anchor="middle" font-size="18" font-weight="600" fill="#1f2328">GitHub</text>'
b += f'<text x="230" y="124" text-anchor="middle" font-size="13" fill="#57606a">Sign in</text>'
b += f'<text x="140" y="154" font-size="12.5" fill="#0067c0" font-weight="600">Browser/Device</text><text x="260" y="154" font-size="12.5" fill="#57606a">Token</text>'
b += '<line x1="130" y1="160" x2="245" y2="160" stroke="#0067c0" stroke-width="2"/>'
b += button(120, 182, 220, "Sign in with your browser", fill="#1f883d", col="#fff", stroke="#1a7f37", bold=True)
b += button(120, 220, 220, "Sign in with a code")
b += f'<text x="230" y="280" text-anchor="middle" font-size="12" fill="#57606a">Don\'t have an account? Sign up</text>'
b += note(1, 350, 195, "", "")
b += note(1, 470, 80, "Windows only asks once: the first Push (or Pull|of a private repository) opens this window of|Git Credential Manager (installed with Git).|Sign in in the browser, authorise, done:|the password is kept safely by Windows.",
          "Windows ne le demande qu'une fois : le premier Push|(ou Pull d'un dépôt privé) ouvre cette fenêtre de|Git Credential Manager (installé avec Git).|Connectez-vous dans le navigateur, autorisez, c'est fait :|le mot de passe est gardé en sécurité par Windows.", 488, 85)
b += note(2, 470, 200, "GitLab: the same window says \"Connect to GitLab\".|A token also works (Token tab): see below.", "GitLab : la même fenêtre dit « Connect to GitLab ».|Un jeton marche aussi (onglet Token) : voir plus bas.", 488, 205)
files["git-credential"] = svg(900, 330, b, "Git Credential Manager sign-in window on Windows")

# 9. History viewer ------------------------------------------------------------------------------
b = window(20, 20, 820, 380, "RStudio: Review Changes", icon="#75aadb")
b += f'<text x="34" y="70" font-size="12.5" fill="#333">○ Changes   ◉ History</text><text x="230" y="70" font-size="12.5" fill="#333">⎇ main ▾    (all commits) ▾    Filter by File...</text>'
b += '<rect x="30" y="82" width="800" height="150" fill="#fff" stroke="#ccd"/>'
b += f'<text x="40" y="100" font-size="12" fill="{GREY}">Subject                                                     Author              Date          SHA</text>'
hist = [("Explain the order of the scripts in the README", "Fara Rasoa", "2025-05-12", "cb39eea"),
        ("Boxplots of coral cover per year", "Fara Rasoa", "2025-05-12", "e0ed893"),
        ("Lower the bleaching threshold to 20 %", "Hery Nirina", "2025-05-09", "4a5c8d0"),
        ("Flag severe bleaching", "Hery Nirina", "2025-05-05", "8c390f6"),
        ("Add the cleaning script", "Fara Rasoa", "2025-05-02", "06d0e2b")]
for i, (s, a, d, h) in enumerate(hist):
    yy = 122 + i * 22
    if i == 2: b += f'<rect x="31" y="{yy-15}" width="798" height="21" fill="#cce4f7"/>'
    b += f'<text x="40" y="{yy}" font-size="12.5" fill="#222">{e(s)}</text><text x="475" y="{yy}" font-size="12.5" fill="#222">{a}</text><text x="625" y="{yy}" font-size="12.5" fill="#222">{d}</text><text x="740" y="{yy}" font-size="12.5" fill="#222" {MONO}>{h}</text>'
b += '<rect x="30" y="240" width="800" height="150" fill="#fff" stroke="#ccd"/>'
b += f'<text x="40" y="258" font-size="12" fill="{GREY}">SHA 4a5c8d0 · Author Hery Nirina · Date 2025-05-09   R/03_bleaching.R   (View file @ 4a5c8d0)</text>'
for i, (k, t) in enumerate([("-", "bleach_threshold <- 30   # % of colonies bleached = severe"), ("+", "bleach_threshold <- 20   # changed after the meeting with the MPA managers"), (" ", "reef$severe <- reef$bleached_pct >= bleach_threshold")]):
    yy = 286 + i * 24
    if k == "+": b += f'<rect x="31" y="{yy-15}" width="798" height="22" fill="#e6ffec"/>'
    if k == "-": b += f'<rect x="31" y="{yy-15}" width="798" height="22" fill="#ffebe9"/>'
    b += f'<text x="44" y="{yy}" font-size="12.5" fill="#111" {MONO}>{e(k + " " + t)}</text>'
b += note(1, 160, 66, "", "") + note(2, 30, 166, "", "") + note(3, 760, 258, "", "")
b += note(1, 870, 60, "Git pane → History (clock icon),|or Changes/History at the top.", "Panneau Git → History (icône horloge),|ou Changes/History en haut.", 888, 65)
b += note(2, 870, 130, "One line per commit: what, who, when,|and its code (SHA). Click a commit…", "Une ligne par commit : quoi, qui, quand,|et son code (SHA). Cliquez sur un commit…", 888, 135)
b += note(3, 870, 210, "…to see what it changed. \"View file\"|shows the whole file as it was then.|\"Filter by File\" keeps the commits of|one file.", "…pour voir ce qu'il a changé. « View file »|montre le fichier entier tel qu'il était.|« Filter by File » garde les commits|d'un seul fichier.", 888, 215)
files["git-history"] = svg(1160, 420, b, "RStudio Git history viewer")

# 10. The daily cycle ---------------------------------------------------------------------------
steps = [("⬇ Pull", "#2b6cb0", "when you start working", "quand vous commencez"),
         ("✎ Edit, save, run", "#3c4a52", "your scripts and reports", "vos scripts et rapports"),
         ("✔ Stage + Commit", "#c27a00", "after each logical step that works", "après chaque étape logique qui marche"),
         ("⬆ Push", "#2f855a", "end of session (Pull just before)", "fin de séance (Pull juste avant)")]
b = ""
for i, (t, c, en, fr) in enumerate(steps):
    x = 20 + i * 235
    b += f'<rect x="{x}" y="40" width="205" height="70" rx="12" fill="#fff" stroke="{c}" stroke-width="2.5"/>'
    b += f'<text x="{x+102}" y="72" text-anchor="middle" font-size="17" font-weight="700" fill="{c}">{e(t)}</text>'
    b += f'<text class="en" x="{x+102}" y="96" text-anchor="middle" font-size="12" fill="{GREY}">{e(en)}</text><text class="fr" x="{x+102}" y="96" text-anchor="middle" font-size="12" fill="{GREY}">{e(fr)}</text>'
    if i < 3: b += f'<text x="{x+212}" y="82" font-size="20" fill="{GREY}">→</text>'
b += f'<path d="M 125 112 C 125 160, 830 160, 830 112" fill="none" stroke="{GREY}" stroke-dasharray="5 4"/>'
b += f'<text class="en" x="477" y="168" text-anchor="middle" font-size="12.5" fill="{GREY}">Commit often (many small commits) · push at least once per work session · always pull before pushing</text>'
b += f'<text class="fr" x="477" y="168" text-anchor="middle" font-size="12.5" fill="{GREY}">Validez souvent (beaucoup de petits commits) · poussez au moins une fois par séance de travail · toujours pull avant push</text>'
files["git-cycle"] = svg(960, 185, b, "The daily Git cycle in RStudio")

os.makedirs(OUT, exist_ok=True)
for name, s in files.items():
    with open(os.path.join(OUT, name + ".svg"), "w", encoding="utf-8") as f:
        f.write(s)
print("written:", ", ".join(files))
