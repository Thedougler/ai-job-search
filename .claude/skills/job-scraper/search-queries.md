# Search Queries for Job Scraper

<!-- SETUP: Customize these queries based on your skills, target roles, and location -->

## Search Sites

Primary (Canadian job market):
- **indeed.ca** - largest Canadian job board
- **linkedin.com/jobs** - LinkedIn job listings (filter: Canada / BC)
- **jobbank.gc.ca** - Government of Canada Job Bank
- **bcjobs.ca** - BC-specific job board (strong for Vancouver Island / Comox Valley)
- **glassdoor.ca** - Glassdoor Canada (reviews + listings)

Secondary (company career pages via Google):
- Direct Google searches with `site:` filters for known target companies

## Query Categories

Queries are grouped by priority. Each query should be combined with your location terms (e.g. "Courtenay", "Comox Valley", "BC", "remote") where the site supports it. Given the small local market, include "remote" as a modifier in most queries.

### Priority 1: [YOUR_PRIMARY_ROLE_TYPE]

These match your strongest and most desired career direction.

```
site:indeed.ca "[YOUR_PRIMARY_JOB_TITLE]" "British Columbia" OR remote
site:ca.indeed.com "[YOUR_PRIMARY_JOB_TITLE]" BC remote
site:linkedin.com/jobs "[YOUR_PRIMARY_JOB_TITLE]" Canada remote
site:jobbank.gc.ca "[YOUR_PRIMARY_JOB_TITLE]" "British Columbia"
```

### Priority 2: [YOUR_DOMAIN_EXPERTISE]

These match your domain expertise.

```
site:indeed.ca [YOUR_DOMAIN_KEYWORD_1] BC OR remote
site:indeed.ca [YOUR_DOMAIN_KEYWORD_2] Canada remote
site:linkedin.com/jobs [YOUR_DOMAIN_KEYWORD_1] Canada
site:bcjobs.ca [YOUR_DOMAIN_KEYWORD_1]
```

### Priority 3: [YOUR_ADJACENT_ROLE_TYPE]

Adjacent roles you could pivot into.

```
site:indeed.ca "[YOUR_ADJACENT_TITLE_1]" [YOUR_KEY_SKILL] BC OR remote
site:indeed.ca "[YOUR_ADJACENT_TITLE_2]" [YOUR_KEY_SKILL] Canada remote
```

### Priority 4: Broader Technical / Consulting

Wider net for general technical roles.

```
site:indeed.ca [YOUR_KEY_SKILL] developer BC OR remote
site:linkedin.com/jobs "[YOUR_KEY_SKILL] developer" Canada remote
site:indeed.ca "technical consultant" [YOUR_DOMAIN] Canada
```

## Location Filter

When evaluating results, verify the job location is within reasonable distance or offers remote work. Define acceptable areas:
- Courtenay / Comox Valley (ideal — local)
- Nanaimo, Campbell River (acceptable — ~1hr drive)
- Victoria (borderline — ~3hr, only if hybrid/mostly-remote)
- Vancouver (remote only — ferry commute not viable daily)
- Canada-wide (remote only)

## Date Filter

Only include jobs posted within the last 14 days, or with an application deadline that has not yet passed. If a posting date cannot be determined, include it but flag as "date unknown".

## Adapting Queries

If the user specifies a focus area, select queries from the matching category and also generate 2-3 custom queries for that focus. For example:
- "/scrape [focus_area]" -> relevant category queries + custom focus-specific queries
