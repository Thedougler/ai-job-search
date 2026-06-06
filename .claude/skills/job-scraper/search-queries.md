# Search Queries for Job Scraper

## Source Configuration

### Job Bank Canada (WebFetch — primary)

Government of Canada job board. Best structured data: salary, location, distance, individual URLs.

**URL pattern:** `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=<QUERY>&mid=<MID>&d=<DISTANCE_KM>&sort=M`

**Municipality IDs (mid=):**
- `22332` — Courtenay, BC (primary)
- `22703` — Comox, BC
- `21179` — Campbell River, BC
- `21839` — Nanaimo, BC

**Distance (d=):** Use `50` for local, `100` for broader Vancouver Island, `200` for all of BC coast.

### Indeed Canada (WebFetch — primary)

Largest volume of Canadian job listings. Fetch search result pages directly.

**URL pattern:** `https://ca.indeed.com/<SLUG>` (see queries below)

**Individual job URLs:** Extract `jk=` keys from search results HTML. Build as `https://ca.indeed.com/viewjob?jk=<KEY>`.

### BCjobs.ca (unreliable — skip)

Direct WebFetch returns 403. `site:bcjobs.ca` WebSearch returns only category pages, never individual listings. Do not spend time on this source.

### LinkedIn (WebSearch discovery)

Use WebSearch with `site:linkedin.com/jobs` to find listings, then WebFetch individual URLs.

### General WebSearch (supplementary)

Run broad queries without `site:` filters to catch listings from any board (WorkBC, ZipRecruiter, Glassdoor, company career pages). WebFetch promising individual listing URLs from results.

---

## Query Categories

### Priority 1: Painting / Trades (Local)

**Job Bank (WebFetch):**
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=painter&mid=22332&d=100&sort=M`
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=painter+decorator&mid=22332&d=100&sort=M`
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=painting+apprentice&mid=22332&d=200&sort=M`

**Indeed (WebFetch):**
- `https://ca.indeed.com/Painting-jobs-in-Comox-Valley,-BC`
- `https://ca.indeed.com/q-painter-decorator-l-british-columbia-jobs.html`
- `https://ca.indeed.com/q-painting-apprentice-l-british-columbia-jobs.html`

**General WebSearch:**
- `painter jobs Courtenay Comox Valley BC 2026`
- `painting apprentice Vancouver Island BC hiring`

### Priority 2: Construction / General Trades (Local)

**Job Bank (WebFetch):**
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=construction+labourer&mid=22332&d=100&sort=M`
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=labourer&mid=22332&d=100&sort=M`
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=trades+helper&mid=22332&d=100&sort=M`

**Indeed (WebFetch):**
- `https://ca.indeed.com/Construction-Labourer-jobs-in-Comox-Valley,-BC`
- `https://ca.indeed.com/Labour-jobs-in-Courtenay,-BC`
- `https://ca.indeed.com/q-trades-helper-l-british-columbia-jobs.html`

**General WebSearch:**
- `construction labourer Courtenay Comox Valley BC 2026`
- `trades helper Vancouver Island BC hiring`

### Priority 3: Remote Tech / Developer

**Job Bank (WebFetch):**
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=junior+developer&mid=22332&d=200&sort=M`
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=web+developer&mid=22332&d=200&sort=M`
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=IT+support&mid=22332&d=200&sort=M`

**Indeed (WebFetch):**
- `https://ca.indeed.com/q-junior-developer-l-remote-jobs.html`
- `https://ca.indeed.com/q-remote-junior-software-developer-jobs.html`
- `https://ca.indeed.com/q-remote-technical-support-jobs.html`

**LinkedIn (WebSearch):**
- `site:linkedin.com/jobs "junior developer" Canada remote`
- `site:linkedin.com/jobs "junior web developer" Canada remote`

### Priority 4: Broader / Hybrid

**Job Bank (WebFetch):**
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=maintenance&mid=22332&d=100&sort=M`
- `https://www.jobbank.gc.ca/jobsearch/jobsearch?searchstring=facilities+maintenance&mid=22332&d=50&sort=M`

**Indeed (WebFetch):**
- `https://ca.indeed.com/q-facilities-maintenance-l-courtenay,-bc-jobs.html`
- `https://ca.indeed.com/q-help-desk-l-remote-jobs.html`

---

## Location Filter

When evaluating results, verify the job is within range or remote:
- Courtenay / Comox Valley — ideal (local)
- Campbell River — acceptable (~1hr north)
- Nanaimo — acceptable (~1.5hr south)
- Victoria — borderline (~3hr, only if hybrid/mostly-remote)
- Vancouver — remote only (ferry commute not viable daily)
- Canada-wide — remote only

**Minimum wage:** $23/hr. Flag any posting below this threshold.

## Date Filter

Only include jobs posted within the last 14 days, or with an unexpired application deadline. If posting date can't be determined, include but flag as "date unknown".

## Adapting Queries

If the user specifies a focus:
- `/scrape painting` → Priority 1 only
- `/scrape construction` → Priority 2 only
- `/scrape tech` → Priority 3 only
- `/scrape broad` or `/scrape all` → all priorities
- Custom focus → generate 2-3 queries per source for that topic using the URL patterns above
