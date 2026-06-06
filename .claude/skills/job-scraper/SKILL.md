---
name: job-scraper
description: Scrapes Canadian job sites for new positions matching your profile. Deduplicates across runs. Triggers on job scrape, find jobs, search jobs, new jobs, job search, scrape jobs, /scrape
---

# Job Scraper

Searches Canadian job boards using targeted queries, deduplicates against previously seen jobs and the application tracker, and presents new matches with a quick fit assessment.

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

Extract from each result: title, company, location, salary, date posted, distance, and the individual posting URL (pattern: `https://www.jobbank.gc.ca/jobsearch/jobposting/<ID>`).

#### Source B: Indeed Canada (primary — largest volume)

WebFetch the Indeed search URLs from `search-queries.md`. Indeed returns listing cards with title, company, location, and salary.

**Indeed URL extraction:** Indeed search pages embed job keys in the HTML. When parsing results, look for job card links containing `/viewjob?jk=` or `/rc/clk?jk=` or `data-jk` attributes. Build individual job URLs as `https://ca.indeed.com/viewjob?jk=<KEY>`.

**Sponsored/ad listings** use `pagead/clk` URLs instead of `/viewjob?jk=` — these can't be converted to stable individual URLs. Fall back to a composite dedup key of `company_title_location` for these.

**If Indeed returns a CAPTCHA or login wall:** skip it and note in output. Do not retry.

#### Source C: General WebSearch (supplementary discovery)

Run broad WebSearch queries (without `site:` filters) to catch listings from boards not covered by Sources A/B — WorkBC, ZipRecruiter, Glassdoor, company career pages, etc. Example queries:
```
painter jobs Courtenay BC 2026
construction labourer Comox Valley BC hiring
```

WebFetch any individual listing URLs from results. **Most results will be aggregator/category pages — skip those.** This source has low yield but occasionally surfaces listings not on Job Bank or Indeed.

**BCjobs.ca is unreliable:** direct WebFetch returns 403, and `site:bcjobs.ca` WebSearch only returns category pages, not individual listings. Do not spend time on it.

#### Source D: LinkedIn (secondary — WebSearch discovery)

Use WebSearch: `site:linkedin.com/jobs "painter" "British Columbia"`

Then WebFetch individual LinkedIn job URLs to extract details.

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
      "source": "jobbank|indeed|bcjobs|linkedin",
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
Sources checked: Job Bank (N results), Indeed (N results), BCjobs (N results)

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

1. **Never fabricate job postings.** Only present jobs from actual WebFetch/WebSearch results.
2. **Respect deduplication.** Always check seen_jobs.json AND job_search_tracker.csv.
3. **Geographic filter.** Skip jobs outside commute range (see search-queries.md).
4. **WebFetch Indeed directly.** `site:indeed.ca` WebSearch queries return category pages, not listings.
5. **WebFetch Job Bank directly.** Always use `mid=` parameter for location filtering.
6. **WebSearch for BCjobs.** Direct fetch returns 403 — discover via WebSearch, then fetch individual listing URLs.
7. **Parallel fetches.** Use the Agent tool to fetch multiple sources concurrently.
8. **Report source failures.** If a source returns CAPTCHA/403/error, note it and continue with other sources.
