# Job Application Assistant for Nick Davenock

<!-- SETUP: This file is populated by running /setup -->
<!-- After running /setup, all [PLACEHOLDER] tokens will be replaced with your actual information -->

## Role
This repo is a job application workspace. Claude acts as a career advisor and application assistant for Nick Davenock, helping with:
1. **Job fit evaluation** - Assess job postings against your profile (skills, experience, behavioral traits)
2. **CV tailoring** - Adapt existing CV templates (LaTeX/moderncv) to target specific roles
3. **Cover letter writing** - Draft targeted cover letters using existing templates (LaTeX)
4. **Interview preparation** - Prepare answers, questions, and talking points for interviews
5. **Career strategy** - Advise on positioning and personal branding

## Candidate Profile

<!-- This section is auto-populated by /setup. You can also fill it in manually. -->

### Identity
- **Name:** Nick Davenock
- **Location:** Courtenay, BC, Canada (Comox Valley or remote only)
- **Languages:** English (native)
- **Status:** Employed - Painter at Trinity Painting
- **LinkedIn headline:** "Lifelong learner"

### Education
- **Computer Science (partial)** (2012-2014) - Vancouver Island University
  - Coursework in programming, databases, web development

### Professional Experience
- **Painter and Decorator** (2025 - Present) - **Trinity Painting** (Courtenay, BC)
  - Commercial and residential painting; Red Seal apprenticeship in progress
- **Painter and Decorator** (Jan 2024 - 2025) - **Trademark Painting inc** (Courtenay, BC)
  - Large-scale commercial projects; 8 months on NIC Student Dormitories (3 buildings, 4 floors)
  - Co-led crew on Courtenay Public Library roof restoration
  - Worked with minimal supervision, full painter responsibilities
- **Front Desk Receptionist** (Jan 2023 - Sep 2024) - **H&R Block** (Courtenay, BC)
  - Front desk operations, client scheduling, document management
- **Sales Associate** (Jan 2022 - Jan 2023) - **Shaw Communications** (Courtenay, BC)
  - Telecom product sales, customer retention tracking
- **Sales Associate** (Oct 2017 - Dec 2021) - **The Source / Bell Canada** (Port Alberni, BC)
  - Achieved highest month-over-month growth of any location in BC
  - 3-person team: store operations, inventory, cash management
- **Sales Associate** (Feb 2017 - Oct 2017) - **Cloverdale Paints** (Port Alberni, BC)
  - Customer paint consulting, B2B relationship building
- **Slot Attendant** (Oct 2013 - Feb 2016) - **Chances Rimrock** (Port Alberni, BC)
  - Cash handling, security and accounting procedures

### Technical Skills
- **Primary:** Commercial painting, surface preparation, wood finishing, spray application
- **Secondary:** Python, HTML5, Git, Docker, Linux, DevOps, MySQL, web design
- **Domain:** Construction/trades, retail sales, customer service
- **Software:** Google Suite, MS Office, POS systems, CI/CD tools

### Certifications
- **WHMIS** - completed
- **Fall Protection** - completed
- **Red Seal (Painter)** - in progress

### Publications
None

### Awards
None

### Behavioral Profile
- **Self-directed** - Works independently with minimal supervision; takes full ownership of tasks
- **Hands-on learner** - Gravitates toward practical, tangible work with visible outcomes
- **Strengths:** Reliability, independence, technical problem-solving, progressive responsibility
- **Growth areas:** Formal credentials (CS degree incomplete, Red Seal in progress)
- **Thrives in:** Small teams, clear scope, autonomy, hands-on work

### What Excites You
- Tangible, skilled trade work with visible results
- Learning and progressing toward journeyman-level craft

### Target Sectors
- Construction/Trades: painting contractors, commercial builders
- Tech (remote): software development, DevOps, IT

### Deal-breakers
- Below $23/hr
- Sales roles
- Relocation outside Comox Valley (unless fully remote)
- Requires driver's license or own vehicle (no car)

## Multi-User Setup

`master` is the clean framework template — no personal data ever lives on it.
Every user, including the repo owner, works on their own branch.

**On session start, check the current branch:**
```bash
git branch --show-current
```

If on `master`, do not proceed. Ask the user for their name and create or
switch to their personal branch:
```bash
git checkout -b user/<firstname-lastname>   # e.g. user/nick-davenock
# or if it already exists:
git checkout user/<firstname-lastname>
```

**Branch conventions:**
- All CV files, cover letters, and CLAUDE.md profile edits stay on the
  user's branch — never commit personal data to `master`
- `/setup` populates CLAUDE.md on the user's branch only
- `/reset` (wipe profile) operates on the current branch only
- To onboard a new user: stay on `master`, create their branch, switch to it,
  then run `/setup`
- **After completing any operation**, commit and push to the remote as the final step.
- Use the `gh` CLI for all GitHub operations (viewing PRs, checking CI runs, creating issues): `gh pr list`, `gh run list`, etc.

## Repo Structure
- `cv/` - LaTeX CV variants (moderncv template, banking style)
- `cover_letters/` - LaTeX cover letters (custom cover.cls template)
- `.claude/skills/` - AI skill definitions for the application workflow
- `.agents/skills/` - Job search CLI tools

## Workflow for New Job Applications
1. User provides a job posting (URL or text)
2. **Always evaluate fit first**: skills match, experience match, behavioral/culture match. Present this assessment to the user before proceeding.
3. If good fit: create targeted CV (`cv/main_<company>.tex`) and cover letter (`cover_letters/cover_<company>_<role>.tex`)
4. **Verify both documents** (see Verification Checklist below)
5. Prepare interview talking points based on the role requirements and your strengths

**Important:** When mentioning agentic coding or AI tooling in CVs/cover letters, explicitly reference **Claude Code** by name.

## Verification Checklist
After creating or updating a CV or cover letter, re-read the generated file and verify **all** of the following before presenting to the user. Report the results as a pass/fail checklist.

### Factual accuracy
- [ ] All claims match actual profile (CLAUDE.md / candidate profile) - no fabricated skills, experience, or achievements
- [ ] Job titles, dates, company names, and locations are correct
- [ ] Contact details are correct
- [ ] All company-specific claims (partnerships, products, technology, expansions) have been independently verified via WebFetch/WebSearch - do not trust reviewer agent research without verification

### Targeting
- [ ] Profile statement / opening paragraph is tailored to the specific role (not generic)
- [ ] Skills and experience bullets are reframed to match the job requirements
- [ ] Key job requirements are addressed (with gaps acknowledged where relevant)
- [ ] Nice-to-have requirements are highlighted where there is a match

### Consistency
- [ ] CV follows the standard 2-page moderncv/banking format
- [ ] Cover letter uses cover.cls template and established structure
- [ ] Tone is consistent across CV and cover letter
- [ ] No contradictions between CV and cover letter content

### Quality
- [ ] No LaTeX syntax errors (balanced braces, correct commands)
- [ ] No spelling or grammar errors
- [ ] Agentic coding / AI tooling references mention **Claude Code** by name
- [ ] Cover letter is addressed to the correct person (or "Dear Hiring Manager" if unknown)
- [ ] Cover letter fits approximately one page

### Compiled PDF verification (MANDATORY - never skip)
Both documents MUST be compiled and visually inspected via the Read tool on the PDF output. "Looks fine in the .tex" is not acceptable - LaTeX page-break decisions are unpredictable. Iterate until these all pass:
- [ ] CV compiled with **lualatex** (pdflatex often fails on modern MiKTeX with fontawesome5 font-expansion errors). Cover letter compiled with **xelatex** (cover.cls requires fontspec).
- [ ] **CV is exactly 2 pages** - not 1, not 3
- [ ] **No orphaned `\cventry` titles** - a job/education title must never sit at the bottom of a page with its bullets spilling to the next page. Use `\needspace{5\baselineskip}` before each `\cventry` to prevent this, and `\enlargethispage{2-3\baselineskip}` to rescue a trailing section that just barely spills
- [ ] **Cover letter is exactly 1 page** - signature block must fit with the body, never overflow
- [ ] **Cover letter bullet font matches body font** - `\lettercontent{}` must not wrap `\begin{itemize}...\end{itemize}` (the command's trailing `\\` errors on `\end{itemize}`, and moving itemize outside loses the Raleway font). Standard pattern: close `\lettercontent{}`, then wrap the list in `{\raggedright\fontspec[Path = OpenFonts/fonts/raleway/]{Raleway-Medium}\fontsize{11pt}{13pt}\selectfont \begin{itemize}...\end{itemize}\par}`
