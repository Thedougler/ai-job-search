# Job Scraper

**name:** job-scraper
**description:** Scrapes Canadian job sites for new positions matching your profile. Deduplicates across runs. Triggers on: job scrape, find jobs, search jobs, new jobs, job search, scrape jobs, /scrape
**allowed-tools:** Read, Write, Edit, Glob, Grep, WebFetch, WebSearch, Agent, AskUserQuestion

---

## How It Works

This skill searches Canadian job boards using targeted queries based on your profile, deduplicates against previously seen jobs and the application tracker, and presents new matches with a quick fit assessment.

## Invocation

The user triggers this skill by saying things like:
- "Find new jobs"
- "Scrape for jobs"
- "Any new positions?"
- "/scrape"

Optional arguments:
- A focus area, e.g. "/scrape data science" or "/scrape geophysics"
- "broad" to run all search categories, e.g. "/scrape broad"

---

## Execution Steps

### Step 0: Load State

1. Read `job_scraper/seen_jobs.json` (create if missing - start with `{"seen": {}}`)
2. Read `job_search_tracker.csv` to extract already-applied companies+roles
3. Read `search-queries.md` (this directory) for the search strategy

### Step 1: Search

> **Important:** `WebSearch` with `site:indeed.ca` queries returns category/index pages, NOT individual listings — Google does not index Indeed's individual job posting pages. Always use `WebFetch` on Indeed search URLs directly to get actual listings.

**For Indeed/BCjobs (primary — use WebFetch directly):**

Fetch these URLs directly with `WebFetch` and extract the listing cards from the HTML. Run the top 3 priority categories by default; all categories if "broad" was specified.

Priority 1 — Painting/Trades (local):
- `https://ca.indeed.com/Painting-jobs-in-Comox-Valley,-BC`
- `https://ca.indeed.com/q-painter-decorator-l-british-columbia-jobs.html`
- `https://www.bcjobs.ca/search?q=painter&location=comox+valley`

Priority 2 — Construction/Trades (local):
- `https://ca.indeed.com/Construction-Labourer-jobs-in-Comox-Valley,-BC`
- `https://ca.indeed.com/Labour-jobs-in-Courtenay,-BC`

Priority 3 — Remote Tech:
- `https://ca.indeed.com/q-junior-developer-l-remote-jobs.html`
- `https://ca.indeed.com/q-remote-junior-software-developer-jobs.html`
- `https://ca.indeed.com/q-remote-technical-support-jobs.html`

**For LinkedIn (secondary — WebSearch works for discovery):**

Use `WebSearch` with queries like `site:linkedin.com/jobs "painter" "British Columbia"` to surface individual LinkedIn job URLs, then `WebFetch` each to extract details.

If the user specified a focus area, prioritize the matching category's URLs.

### Step 2: Fetch & Parse

For each Indeed/BCjobs fetch from Step 1:
- Parse the HTML response for job listing cards (title, company, location, salary, date posted, URL)
- If the response is a redirect or login wall, note it and skip that source
- Extract: **job title**, **company**, **location**, **posting date** (or "N days ago"), **URL**, **salary** (if shown)
- Skip if the URL or company+title combo already exists in `seen_jobs.json`
- Skip if the company+role already appears in `job_search_tracker.csv`
- For any promising individual posting found, optionally `WebFetch` the direct posting URL to get full requirements and deadline

### Step 3: Quick Fit Assessment

For each new job, do a rapid fit check (NOT the full evaluation from `04-job-evaluation.md` - just a quick signal):

- **High match**: Role directly involves your core skills
- **Medium match**: Role is adjacent to your experience
- **Low match**: Role requires significant skills you lack

### Step 4: Deduplicate & Store

1. Add ALL fetched jobs (new and skipped) to `seen_jobs.json` with structure:
```json
{
  "seen": {
    "<url_or_company_title_key>": {
      "title": "...",
      "company": "...",
      "url": "...",
      "first_seen": "YYYY-MM-DD",
      "fit": "high/medium/low",
      "status": "new/skipped/evaluated"
    }
  }
}
```
2. Only present jobs NOT already in the seen list or tracker.

### Step 5: Present Results

Present new jobs in a table sorted by fit (high first):

```
## New Job Matches - YYYY-MM-DD

Found X new positions (Y high, Z medium, W low match).

| # | Fit | Title | Company | Location | Deadline | URL |
|---|-----|-------|---------|----------|----------|-----|
| 1 | High | ... | ... | ... | ... | [Link](...) |

### High-Match Highlights
For each high-match job, add 2-3 bullet points:
- Why it matches your profile
- Key requirements to check
- Any red flags
```

After presenting, ask:
> "Want me to evaluate any of these in detail? Just give me the number(s)."

If the user picks a number, invoke the **job-application-assistant** skill workflow (fit evaluation first, then CV + cover letter if approved).

### Step 6: Update Tracker (Optional)

If the user decides to apply to any job, add a row to `job_search_tracker.csv`.

---

## Important Rules

1. **Never fabricate job postings.** Only present jobs found via actual WebSearch/WebFetch results.
2. **Respect deduplication.** Always check seen_jobs.json AND job_search_tracker.csv before presenting.
3. **Focus on configured geographic area.** Skip jobs that require relocation or are clearly outside commute range.
4. **Only open positions.** Skip postings with expired deadlines or those marked as closed.
5. **WebFetch Indeed directly.** `site:indeed.ca` WebSearch queries return category pages, not listings — use WebFetch on the search URLs in Step 1 to get actual job cards.
6. **Be efficient with follow-up fetches.** Pre-filter from listing cards before fetching individual posting pages.
7. **Parallel fetches.** Use the Agent tool or parallel WebFetch calls to fetch multiple search pages at once.
