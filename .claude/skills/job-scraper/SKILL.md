---
name: job-scraper
description: Scrapes Canadian job sites for new positions matching your profile. Deduplicates across runs. Triggers on job scrape, find jobs, search jobs, new jobs, job search, scrape jobs, /scrape
---

# Job Scraper

Searches Canadian job boards using targeted queries, deduplicates against previously seen jobs and the application tracker, and presents new matches with a quick fit assessment.

## Fetch Tools

Three tools are available for fetching web content. Choose by **task**, not by site:

| Task | Tool | Why |
|------|------|-----|
| **Search results pages** | **WebFetch** | Need HTML structure to extract job cards, links, `jk=` keys |
| **JS-rendered search pages** | **Playwright** (`mcp__playwright__*`) | BCjobs.ca, WorkBC return empty HTML to bots — headless browser required |
| **Individual job postings** | **defuddle-fetch** (`mcp__defuddle-fetch__*`) | Strips nav/ads/footers, returns clean job description markdown. Lower token cost than raw HTML. Use for any individual posting URL from any source |

**Decision rule:** Use WebFetch/Playwright to get the **list** of jobs. Use defuddle-fetch to **read** a specific job posting. If defuddle-fetch is unavailable or returns an error, fall back to WebFetch for individual postings.

## Invocation

- "Find new jobs" / "Scrape for jobs" / "Any new positions?" / `/scrape`
- Focus area: `/scrape painting` or `/scrape tech`
- All categories: `/scrape broad`

## Execution Steps

### Step 0: Load State

1. Read `job_scraper/seen_jobs.json` (create with `{"seen": {}}` if missing)
2. Read `job_search_tracker.csv` to extract already-applied companies+roles
3. Read `search-queries.md` (this directory) for source URLs and queries

### Step 1: Fetch Sources

Run the top 2 priority categories by default; all categories if "broad" was specified. If the user specified a focus area, prioritize the matching category.

**Use the Agent tool to fetch multiple sources in parallel** — one agent per source URL or WebSearch query. This dramatically reduces wall-clock time.

#### Source A: Job Bank Canada (primary — best structured data)

WebFetch the Job Bank search URLs from `search-queries.md`. Job Bank returns well-structured listings with individual job URLs, salaries, locations, and distance from the search center.

**Critical:** Job Bank URLs must use the `mid=` (municipality ID) parameter for geographic filtering — without it, results span all of Canada. The `d=` parameter sets radius in km. See `search-queries.md` for the correct municipality IDs.

Extract from each result: title, company, location, salary, date posted, distance, and the individual posting URL (pattern: `https://www.jobbank.gc.ca/jobsearch/jobposting/<ID>`). Use defuddle-fetch on individual posting URLs for clean job descriptions when evaluating fit.

#### Source B: Indeed Canada (primary — largest volume)

WebFetch the Indeed search URLs from `search-queries.md`. Indeed returns listing cards with title, company, location, and salary.

**Indeed URL extraction:** Indeed search pages embed job keys in the HTML. When parsing results, look for job card links containing `/viewjob?jk=` or `/rc/clk?jk=` or `data-jk` attributes. Build individual job URLs as `https://ca.indeed.com/viewjob?jk=<KEY>`.

**Sponsored/ad listings** use `pagead/clk` URLs instead of `/viewjob?jk=` — these can't be converted to stable individual URLs. Fall back to a composite dedup key of `company_title_location` for these.

**If Indeed returns a CAPTCHA or login wall:** skip it and note in output. Do not retry.

#### Source C: BCjobs.ca (Playwright only — WebFetch returns 403)

BCjobs.ca blocks raw HTTP requests. Use Playwright headless browser:

1. Navigate to `https://www.bcjobs.ca/search-jobs?q=<QUERY>&location=` (note: `/search-jobs` not `/search`)
2. Take a `browser_snapshot` to extract listing cards
3. Each listing shows: title, company, location, date posted
4. Individual job URLs follow pattern: `https://www.bcjobs.ca/jobs/<slug>`
5. Use defuddle-fetch on individual job URLs (`https://www.bcjobs.ca/jobs/<slug>`) for clean job descriptions

**Important:** BCjobs has low volume for trades — expect 0-5 results per query. Don't spend multiple queries if the first returns nothing relevant.

#### Source D: Craigslist Comox Valley (WebFetch — local trades)

WebFetch the Craigslist trades category search URLs from `search-queries.md`. Craigslist returns static HTML with listings in `<li>` elements containing title, location, compensation, and posting URL.

**Individual posting URLs:** `https://comoxvalley.craigslist.org/trd/d/<slug>/<id>.html` — use defuddle-fetch on these for clean posting content.

**Salary handling:** Compensation frequently shows $0 — this means "not listed", not unpaid. Do not filter Craigslist results on salary. Flag as "salary unlisted" instead.

**Volume:** Expect 5-15 results per query. Craigslist skews toward small contractors and independent employers — these postings rarely appear on Indeed or Job Bank.

#### Source E: Talent.com (WebFetch — Canadian aggregator)

WebFetch the Talent.com search URLs from `search-queries.md`. Talent.com returns listing cards with job title, company, location, and salary.

**Individual job URLs:** Talent.com uses redirect-based URLs — `https://ca.talent.com/redirect?id=<ID>&...`. Store the full redirect URL as the dedup key. These redirect to the original employer posting. Use defuddle-fetch on the redirect URL to read the clean job description from the employer's site.

#### Source F: WorkBC (Playwright — BC provincial board)

WorkBC is a JavaScript SPA — WebFetch returns an empty shell. Use Playwright headless browser (same approach as BCjobs):

1. `browser_navigate` to `https://www.workbc.ca/search-and-prepare-job/find-jobs`
2. Take `browser_snapshot` to locate the search form
3. Fill keyword and location fields using `browser_fill_form` or `browser_click` + `browser_type`
4. Submit and take `browser_snapshot` to extract results
5. Extract: title, company, location, salary, posting URL

**Volume:** WorkBC has ~28K total listings across BC. Many municipal employers and small contractors post only here.

#### Source G: General WebSearch (supplementary discovery)

Run broad WebSearch queries (without `site:` filters) to catch listings from boards not covered by Sources A-F — ZipRecruiter, Glassdoor, company career pages, etc.:
```
painter jobs Courtenay BC 2026
construction labourer Comox Valley BC hiring
```

Use defuddle-fetch on individual listing URLs from results for clean content. **Most results will be aggregator/category pages — skip those.**

#### Source H: LinkedIn (secondary — WebSearch discovery)

Use WebSearch: `site:linkedin.com/jobs "painter" "British Columbia"`

Then defuddle-fetch individual LinkedIn job URLs for clean job descriptions.

### Step 2: Parse & Deduplicate

For each job found across all sources:
1. Extract: **title**, **company**, **location**, **salary**, **date posted**, **URL**, **source site**
2. Skip if the URL or `company+title` combo exists in `seen_jobs.json`
3. Skip if the company+role appears in `job_search_tracker.csv`
4. Skip jobs with expired deadlines or marked as closed
5. Skip jobs outside the geographic range (see Location Filter in `search-queries.md`)
6. Skip jobs below $23/hr minimum

### Step 3: Quick Fit Assessment

For each new job, rapid fit check (NOT the full evaluation — just a signal):

- **High**: Role directly involves core skills (painting, trades, hands-on tech)
- **Medium**: Role is adjacent to experience (construction, maintenance, entry-level dev)
- **Low**: Role requires significant skills not held

### Step 4: Store

Add ALL fetched jobs (new and skipped) to `seen_jobs.json`:
```json
{
  "seen": {
    "<url_or_company_title_key>": {
      "title": "...",
      "company": "...",
      "location": "...",
      "url": "...",
      "source": "jobbank|indeed|bcjobs|craigslist|talent|workbc|linkedin",
      "first_seen": "YYYY-MM-DD",
      "salary": "...",
      "fit": "high/medium/low",
      "status": "new/skipped/evaluated"
    }
  }
}
```

### Step 5: Present Results

```
## New Job Matches - YYYY-MM-DD

Found X new positions (Y high, Z medium, W low match).
Sources checked: Job Bank (N), Indeed (N), BCjobs (N), Craigslist (N), Talent.com (N), WorkBC (N)

| # | Fit | Title | Company | Location | Salary | Source | URL |
|---|-----|-------|---------|----------|--------|--------|-----|
| 1 | High | ... | ... | ... | ... | Job Bank | [Link](...) |

### High-Match Highlights
For each high-match job:
- Why it matches
- Key requirements to check
- Any red flags (distance, low pay, etc.)
```

After presenting, ask:
> "Want me to evaluate any of these in detail? Give me the number(s)."

If the user picks a number, invoke the **job-application-assistant** skill.

### Step 6: Update Tracker (Optional)

If the user decides to apply, add a row to `job_search_tracker.csv`.

## Important Rules

1. **Never fabricate job postings.** Only present jobs from actual fetch results.
2. **Respect deduplication.** Always check seen_jobs.json AND job_search_tracker.csv.
3. **Geographic filter.** Skip jobs outside commute range (see search-queries.md).
4. **WebFetch Indeed directly.** `site:indeed.ca` WebSearch queries return category pages, not listings.
5. **WebFetch Job Bank directly.** Always use `mid=` parameter for location filtering.
6. **Playwright for BCjobs.** WebFetch returns 403 — use headless browser via Playwright MCP.
7. **Parallel fetches.** Use the Agent tool to fetch multiple sources concurrently.
8. **Report source failures.** If a source returns CAPTCHA/403/error, note it and continue with other sources.
9. **Right tool for the task.** WebFetch/Playwright for search results pages (need HTML structure). defuddle-fetch for individual job postings (clean markdown, lower tokens). Fall back to WebFetch if defuddle-fetch is unavailable.
10. **Craigslist salary = $0 means unlisted.** Never filter Craigslist results on salary — $0 is the default when compensation isn't specified. Flag as "salary unlisted".
11. **WorkBC requires Playwright.** JS SPA — WebFetch returns empty HTML. Same headless browser approach as BCjobs.
12. **Talent.com redirect URLs.** Individual job links are redirect URLs (`/redirect?id=...`). Store the full redirect URL as the dedup key.
