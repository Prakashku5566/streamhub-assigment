# Streamhub QA Automation Assessment

## Overview
This repository contains the complete solution for the Streamhub QA Automation Assessment. It demonstrates full-stack quality assurance capabilities spanning from developing a testable web application (A1) to implementing robust UI automation (A2), API testing edge cases (A3), and complex SQL queries (A4).

## Tech Stack
- **Application:** Vanilla HTML5, CSS3 (Glassmorphism UI), JavaScript, Chart.js
- **Automation Framework:** Playwright, Cucumber (BDD), TypeScript
- **Assertions:** Playwright Test Runner (`expect`)
- **Database Querying (A4):** Standard SQL (PostgreSQL dialect utilizing Window Functions)

## Architecture
The testing architecture follows enterprise best practices:
- **Page Object Model (POM):** UI interactions are abstracted away from test steps for maintainability.
- **Resilient Locators:** Strict reliance on `data-testid` rather than brittle CSS/XPath positional selectors.
- **Decoupled Validation:** Expected outcomes (like EMI mathematical calculations) are computed independently via utility functions (`emiCalculator.ts`) rather than relying on application DOM states.

## Project Structure
```text
streamhub-qa-assessment/
├── app/                      # A1: Custom Web Application (Loan Dashboard)
│   ├── index.html            
│   ├── app.js
│   └── style.css
├── tests/                    # Automation Framework
│   ├── api/                  # A3: API Automation scenarios
│   ├── features/             # A2: Cucumber BDD Feature files
│   ├── pages/                # Page Object Models
│   ├── steps/                # Cucumber Step Definitions
│   ├── utils/                # Helper utilities (Independent EMI calc)
│   └── fixtures/             # JSON Test Data
├── playwright.config.ts      # Playwright execution configuration
├── *.sql                     # A4: Advanced SQL assessment scripts
└── README.md
```

## Application Setup
The A1 Web Application is built with Vanilla Web Technologies to eliminate build-step complexity.
1. Navigate to the `app/` directory.
2. Open `index.html` directly in any modern browser (Chrome/Edge/Firefox).
3. Alternatively, serve via VS Code "Live Server" or Python: `python -m http.server 8000`.

## Test Setup
To set up the automation framework locally:
```bash
# 1. Install project dependencies
npm install

# 2. Install Playwright browsers
npx playwright install
```

## Running Tests
To execute the automated test suite and generate HTML reports:
```bash
npx playwright test
```

## UI Automation
The UI automation (A2) targets the Loan Analytics Dashboard. Key highlights:
- Uses Cucumber for BDD (Behavior-Driven Development) providing readable `Given/When/Then` syntax.
- Data-driven testing scenarios to validate various principal, interest, and tenure inputs.
- Validates that the visual Pie Chart renders appropriately and contains positive numerical data.

## API Automation
The API automation (A3) targets the `JSONPlaceholder` POST `/posts` endpoint. Scenarios covered:
- Exceptionally long payloads (10,000+ characters).
- Unsupported and invisible special characters (Null bytes, Zero-width spaces).
- Missing mandatory schema fields (`userId`).
- Validates that the server responds gracefully (Status < 500) without crashing.

## SQL Tests
Advanced SQL capabilities (A4) are demonstrated in the root `.sql` files:
1. **A4_SQL_RoundTrip.sql:** Uses a self-JOIN to detect fraudulent round-trip transfers (A->B then B->A) within a 24-hour window and 10% amount variance.
2. **A4_SQL_IPL_Streak.sql:** Utilizes advanced Window Functions (`ROW_NUMBER()`, `LAG()`, `PARTITION BY`) via the "Gap and Islands" technique to dynamically find consecutive matching streaks (30+ runs).

## AI Self-Healing
While Playwright provides auto-waiting, our framework's "self-healing" philosophy is baked directly into the locator strategy. By enforcing `data-testid` attributes at the DOM level and decoupling test data from presentation layers, the tests are inherently immune to cosmetic layout shifts and CSS refactoring.

## Test Results
Execution results are automatically saved in the `reports/` directory upon test completion.
- HTML Reports: `reports/html/`
- Logs & Traces: `reports/logs/`

## Screenshots
Screenshots of failures (or manual captures) are configured to be retained automatically by Playwright and are attached directly inside the generated HTML report.

## AI/Claude Code Reflection

### What AI helped with
- Initial Playwright framework structure setup.
- Page Object Model structural generation.
- Cucumber steps and BDD scaffolding.
- SQL query brainstorming and advanced window function syntax.
- Crafting resilient `data-testid` injection.

### What AI got wrong
- Initial assumptions regarding locating chart elements, requiring manual correction to expose hidden numerical fields for true validation.
- Minor discrepancies in combining Cucumber syntax seamlessly with Playwright's native runner without adapter plugins.

### How I validated AI output
Every generated implementation was manually reviewed, integrated into the IDE, and executed against the local application. I ensured the SQL queries logically matched the "Gap and Islands" theory and verified that the API edge cases accurately targeted HTTP 500 boundaries.

## Challenges & Solutions
**Challenge:** Validating Chart.js canvas values via DOM automation. A canvas element does not expose its internal drawing logic (like Principal/Interest amounts) to Playwright text selectors.
**Solution:** Rather than performing brittle visual regression (pixel matching), I updated the application logic (`app.js`) to synchronously output the exact numerical values into visually hidden `<span>` tags with `data-testid` attributes. This allowed Playwright to reliably extract and assert that the chart values are mathematically `> 0`.
