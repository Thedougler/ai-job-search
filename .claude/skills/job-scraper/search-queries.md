# Search Queries for Job Scraper

## Search Sites

Primary (Canadian job market):
- **indeed.ca** - largest Canadian job board
- **linkedin.com/jobs** - LinkedIn job listings (filter: Canada / BC)
- **bcjobs.ca** - BC-specific job board (strong for Vancouver Island / Comox Valley)
- **glassdoor.ca** - Glassdoor Canada (reviews + listings)

Secondary (company career pages via Google):
- Direct Google searches with `site:` filters for known target companies

## Query Categories

Queries are grouped by priority. Each query should be combined with location terms (e.g. "Courtenay", "Comox Valley", "BC", "remote") where the site supports it. Given the small local market, include "remote" as a modifier in tech queries.

### Priority 1: Painting / Trades (Local)

These match the strongest and most desired career direction.

```
site:indeed.ca "painter" "Courtenay" OR "Comox Valley"
site:indeed.ca "commercial painter" "British Columbia"
site:indeed.ca "painter and decorator" BC
site:indeed.ca "painting apprentice" BC
site:bcjobs.ca painter
site:bcjobs.ca "trades" "painter"
site:linkedin.com/jobs "painter" "British Columbia"
site:indeed.ca "painting labourer" BC OR "Comox Valley"
```

### Priority 2: Construction / General Trades (Local)

Adjacent trades roles that could leverage painting and physical work experience.

```
site:indeed.ca "construction labourer" "Courtenay" OR "Comox Valley"
site:indeed.ca "trades helper" BC
site:indeed.ca "finishing trades" BC
site:bcjobs.ca construction Comox
site:indeed.ca "general labourer" "Courtenay" OR "Campbell River" OR "Nanaimo"
```

### Priority 3: Remote Tech / Developer

Secondary search leveraging CS background and development skills.

```
site:indeed.ca "junior developer" remote Canada
site:indeed.ca "web developer" remote Canada
site:indeed.ca "python developer" remote Canada
site:linkedin.com/jobs "junior developer" Canada remote
site:linkedin.com/jobs "junior web developer" Canada remote
site:indeed.ca "junior devops" remote Canada
site:indeed.ca "IT support" remote Canada
site:indeed.ca "technical support" remote Canada
```

### Priority 4: Broader / Hybrid

Wider net for roles combining technical aptitude with hands-on work.

```
site:indeed.ca "technical specialist" "Courtenay" OR "Comox Valley" OR remote
site:indeed.ca "facilities maintenance" "Courtenay" OR "Comox Valley"
site:linkedin.com/jobs "entry level developer" Canada remote
site:indeed.ca "help desk" remote Canada
```

## Location Filter

When evaluating results, verify the job location is within reasonable distance or offers remote work:
- Courtenay / Comox Valley (ideal -- local)
- Campbell River (acceptable -- ~1hr drive north)
- Nanaimo (acceptable -- ~1.5hr drive south)
- Victoria (borderline -- ~3hr, only if hybrid/mostly-remote)
- Vancouver (remote only -- ferry commute not viable daily)
- Canada-wide (remote only)

**Minimum wage:** $23/hr. Flag any posting below this threshold.

## Date Filter

Only include jobs posted within the last 14 days, or with an application deadline that has not yet passed. If a posting date cannot be determined, include it but flag as "date unknown".

## Adapting Queries

If the user specifies a focus area, select queries from the matching category and also generate 2-3 custom queries for that focus. For example:
- "/scrape painting" -> Priority 1 queries only
- "/scrape tech" -> Priority 3 queries only
- "/scrape all" -> all priority categories
