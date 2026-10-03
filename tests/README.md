# UI testing

Run the local controller regression checks:

```powershell
node --test tests/data_preview_ui.test.cjs tests/license_audit_ui.test.cjs
```

Run the authenticated browser suite against the installed SAP application:

```powershell
node tests/browser/live-ui.cjs
```

The runner uses Playwright's Chromium with the installed Chrome channel. It resolves the `playwright` package locally, from `BPC_PLAYWRIGHT_MODULE`, or from the installed global `@playwright/cli` package on Windows. Chrome and Playwright must be installed before running.

Authentication comes from `SAP_URL`, `SAP_USER`, `SAP_PASSWORD` and optional `SAP_CLIENT`, or the existing `adt` MCP environment section in the personal Codex configuration. Set `BPC_ADT_CONFIG` to use another configuration file. Credentials stay in memory and are supplied through Playwright HTTP authentication; they are not written into test files, output or browser storage snapshots.

The suite opens the real SAP BSP application and loads SAP's bundled QUnit and OPA5 libraries. `opa5/hub.qunit.js` is injected by Playwright, so no test page or test libraries need to be deployed into the BSP application. OPA5 covers hub tiles, Transport navigation, model data preview, filter refresh, License Audit count drill-down and navigation back to the hub. The separate Playwright checks use pointer and keyboard input for theme switching, mobile tile layout, environment/model/member selection, live preview requests and navigation to BPC Git with the SAP client preserved.

Tests use the first authorized environment/model and read its data. Results may be empty. They do not import data, commit Git content, change repository configuration or modify BPC objects. At least one accessible environment/model with members and BW monitor authorization for License Audit are required.

Screenshots and OPA5 assertion results are saved under `.test-results/`, which is ignored by Git. Failure screenshots may contain the data currently displayed in the SAP app. The suite fails on OPA assertions, missing test execution, browser exceptions or failed preview requests.
