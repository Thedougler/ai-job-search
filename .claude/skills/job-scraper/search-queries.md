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

### BCjobs.ca (Playwright — headless browser required)

WebFetch returns 403. Use Playwright MCP (`browser_navigate` + `browser_snapshot`).

**URL pattern:** `https://www.bcjobs.ca/search-jobs?q=<QUERY>&location=`
**Individual job URLs:** `https://www.bcjobs.ca/jobs/<slug>` (extract from snapshot)

### Craigslist Comox Valley (WebFetch — local trades)

Hyper-local classifieds. Small contractors and independent employers post here and nowhere else. Static HTML, works with WebFetch.

**URL pattern:** `https://comoxvalley.craigslist.org/search/trd?query=<QUERY>` (skilled trades category)
**Alternative category:** `https://comoxvalley.craigslist.org/search/lab?query=<QUERY>` (general labour)
**Individual posting URLs:** `https://comoxvalley.craigslist.org/trd/d/<slug>/<id>.html`

**Salary caveat:** Compensation often shows $0 — this means "not listed", not unpaid. Do not filter Craigslist results on salary; flag as "salary unlisted" instead.

### Talent.com (WebFetch — Canadian aggregator)

Large Canadian job aggregator (formerly Neuvoo). Pulls from employer career portals, so surfaces postings not always on Indeed or Job Bank.

**URL pattern:** `https://ca.talent.com/jobs?k=<KEYWORDS>&l=Courtenay%2C+BC`
**Parameters:** `k` (keywords), `l` (location), `radius` (km, optional), `date` (recency: `1`, `3`, `7`)
**Individual job URLs:** Redirect-based — `https://ca.talent.com/redirect?id=<ID>&...`. Use the full redirect URL as the dedup key.

### WorkBC (Playwright — BC provincial board)

BC government employment portal (~28K listings). Many municipal and small employers post only here. JavaScript SPA — WebFetch returns an empty shell.

**Search flow (Playwright):**
1. `browser_navigate` to `https://www.workbc.ca/search-and-prepare-job/find-jobs`
2. Take `browser_snapshot` to find the search form
3. Fill keyword and location fields, submit
4. Take `browser_snapshot` to extract results

### LinkedIn (WebSearch discovery)

Use WebSearch with `site:linkedin.com/jobs` to find listings, then WebFetch individual URLs.

### General WebSearch (supplementary)

Run broad queries without `site:` filters to catch listings from any board (ZipRecruiter, Glassdoor, company career pages). WebFetch promising individual listing URLs from results.

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

**BCjobs (Playwright):**
- `https://www.bcjobs.ca/search-jobs?q=painter&location=`
- `https://www.bcjobs.ca/search-jobs?q=painting&location=`

**Craigslist Comox Valley (WebFetch):**
- `https://comoxvalley.craigslist.org/search/trd?query=painter`
- `https://comoxvalley.craigslist.org/search/trd?query=painting`

**Talent.com (WebFetch):**
- `https://ca.talent.com/jobs?k=painter&l=Courtenay%2C+BC`
- `https://ca.talent.com/jobs?k=painting+apprentice&l=British+Columbia`

**WorkBC (Playwright):**
- Search: `painter` location: `Courtenay`
- Search: `painting apprentice` location: `British Columbia`

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

**BCjobs (Playwright):**
- `https://www.bcjobs.ca/search-jobs?q=construction+labourer&location=`
- `https://www.bcjobs.ca/search-jobs?q=trades&location=`

**Craigslist Comox Valley (WebFetch):**
- `https://comoxvalley.craigslist.org/search/trd?query=construction`
- `https://comoxvalley.craigslist.org/search/lab?query=labourer`

**Talent.com (WebFetch):**
- `https://ca.talent.com/jobs?k=construction+labourer&l=Courtenay%2C+BC`
- `https://ca.talent.com/jobs?k=trades+helper&l=Courtenay%2C+BC`

**WorkBC (Playwright):**
- Search: `construction labourer` location: `Courtenay`
- Search: `trades helper` location: `Courtenay`

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

**Talent.com (WebFetch):**
- `https://ca.talent.com/jobs?k=junior+developer&l=Canada&date=7`
- `https://ca.talent.com/jobs?k=web+developer+remote&l=Canada&date=7`

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

**Talent.com (WebFetch):**
- `https://ca.talent.com/jobs?k=facilities+maintenance&l=Courtenay%2C+BC`
- `https://ca.talent.com/jobs?k=maintenance+technician&l=Courtenay%2C+BC`

**WorkBC (Playwright):**
- Search: `maintenance` location: `Courtenay`
- Search: `facilities maintenance` location: `Courtenay`

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
