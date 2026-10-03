# bpcIO

A SAP BPC workspace with tile navigation to independent tools. **Transport** provides the built-in utility for moving **BPC objects, transaction data and comments** between environments (AppSets) and models. It runs entirely inside SAP as a SAPUI5 app backed by a small ABAP REST service. Objects travel in a portable, gzip-compressed XML archive; data and comments travel as CSV.

## Workspace navigation

The BPCIO home page has four tiles:

- **Transport** opens the existing object, data and comment tools inside BPCIO. Its environment list loads when the tool is first opened; its back button returns to the workspace.
- **BPC Git** navigates in the same browser tab to the separately installed BSP application at `/sap/bc/ui5_ui5/sap/zbpc_git/index.html`, preserving `sap-client`. Browser Back returns to BPCIO. Git retains its own environment selection and authorization.
- **License Audit** opens a dedicated audit module with a start-date picker, Professional/Standard count tiles and user drill-down. It covers all environments in the current SAP client and does not require choosing a Transport environment.
- **Data Preview** lets you select an environment/model and dimension members, then displays stored transaction data in a web table. It uses the same member dropdowns and hierarchy selector as Export Data; empty filters include all members and parent selections expand to base members. The table shows every dimension plus `SIGNEDDATA`, with horizontal scrolling and 50-row display batches. Preview reads one bounded BPC query package, displays at most 1,000 rows and flags partial results. Narrow filters to inspect more specific data; Export Data remains available for a full extract. Preview respects BPC read security and does not change data.

BPC Git must be installed and activated separately. The destination path is configured in `manifest.json` under `sap.ui5.config.bpcGitUrl` (an application path without query parameters). The hub does not load Git code or call its API. ASL is outside this release.

### License audit

The audit calls the same usage functions as SAP report `RSBPCA_NW_AUDIT`: `RSBPCA_GET_USAGE_UNIFIED` for Embedded and `UJ0_GET_USAGE_CLASSIC` for Classic, with `I_F_USAGE_DETAIL` enabled. Results are restricted to the current client and deduplicated by user; Professional takes precedence over Standard across both engines. A selected start date is inclusive and the end date is SAP's current date. Leaving the start date blank explicitly analyses the last 365 days.

The initial totals show **active accounts**. Switch to **inactive accounts** to inspect the separately reported locked, expired or deleted users. SAP's active-account definition is currently unlocked and not expired; it is independent of whether an account had usage in the period. Counts represent SAP's measured usage, not a comparison with purchased license quantities.

Select a count tile to filter the user table, then select a user to inspect the activity code, readable activity label, qualifying activity date, environment and audit source. Last recorded access is calculated separately from the qualifying activity using Classic/Embedded activity records, Classic logon records and Embedded planning usage. Timestamps are shown in UTC where available; date-only records remain date-only, and missing dates say **Not recorded**.

SAP stores the first/latest dates for an activity rather than a full event history. The selected period and retained audit records therefore determine which activity can be shown. The drill-down shows the representative qualifying activity returned by SAP, not every action the user performed.

Authorization matches the report: `S_RS_ADMWB`, `RSADMWBOBJ = Monitor`, `ACTVT = 03`. The backend is isolated in `ZCL_BPC_IO_AUDIT`; the UI uses its own `LicenseAudit` view/controller and loads when its hub tile is opened.

After abapGit pull, activate the new audit class together with the HTTP handler and BSP application. Compare both active and inactive totals against `RSBPCA_NW_AUDIT` for the **same explicit start date and current client**, including a user present in both Classic and Embedded. Check a Professional user whose later access was Standard activity, an account with only a legacy logon date, an empty period, invalid/future dates and a user without BW monitor authorization. Local UI checks run with `node --test tests/license_audit_ui.test.cjs`; SAP runtime acceptance is required after installation.

## Supported objects

| Object | BPC artifact | Notes |
| --- | --- | --- |
| Logic Scripts | `.LGF` script logic files | Content round-trips byte-for-byte (UTF-8/UTF-16 preserved) |
| Data Manager Packages | Package definitions (group, type, chain, script sequence) | Imported/replaced via `cl_ujd_package` |
| Transformation Files | `.TDM` definitions + their `.xls` workbook | Stored in the model's Data Manager `TRANSFORMATIONFILES` folder |
| Conversion Files | `.CDM` definitions + their `.xls` workbook | Stored in the model's Data Manager `CONVERSIONFILES` folder |
| EPM Workbooks | `.XLSM` / `.XLSX` / `.XLS` reports and input schedules | Stored under the model's `EEXCEL\REPORTS` (reports) and `EEXCEL\INPUT SCHEDULES` (input schedules) file-service folders |

## What it does

After choosing an **environment** (remembered per client), the Transport page shows three groups of tiles. The header bar's anchor links (**Transport | Data | Comments**) jump to each group, and a lightbulb toggle switches between the light (`sap_belize`) and dark (`sap_belize_plus`) themes; the choice is remembered in the browser and defaults to the operating system's colour scheme.

### Transport

- **Export Objects** lists the **Logic Scripts**, **Data Manager Packages**, **Transformation Files**, **Conversion Files** and **EPM Workbooks** (reports and input schedules) of a model, grouped by type. A **per-type toggle button** above the list (e.g. `Conversion Files (2/3)`) selects or deselects every object of that type and shows a live selected/total count. The selection is exported to a single compressed XML archive.
- **Import Objects** uploads an archive into a model, shows a side-by-side **comparison** of each uploaded object against the active SAP version, and imports with **Import into BPC**. Every object reports `WRITTEN`, `REPLACED`, `SKIPPED` or `FAILED`, plus a per-type summary.

### Data

- **Export Data** reads a model's stored transaction data as CSV (one column per dimension plus `SIGNEDDATA`). Each dimension can be filtered to selected members; an empty filter includes all members. The export can be **split into multiple files**, one per member of a dimension or one per value of a member property, delivered in a ZIP (at most 200 files).
- **Import Data** writes a CSV, or a ZIP of CSVs, in the Export Data format into a model through the BPC write-back API. The columns are checked against the model's dimensions before anything is sent. Each value **overwrites** the value stored at its intersection; signs are not reversed and default logic does not run. Records are sent in batches of 2,000 and the result lists written and failed records with BPC's messages.

### Comments

- **Export Comments** reads a model's comments as CSV, with the same dimension filters as Export Data (no split).
- **Import Comments** adds comments from a CSV, or a ZIP of CSVs, in the Export Comments format through BPC's comment manager (`CL_UJC_CMTMANAGER->ADD_CMT`), which checks the comment tasks, member write access and work status per comment. A blank member leaves the comment on a partial intersection.
  - Comments that already exist with the **same intersection, author and text are skipped**, so an import can safely be repeated.
  - **Keep original author and date** (on by default) keeps the `USER_ID` and `DATEWRITTEN` columns; otherwise comments are stamped with the importing user and the current time.
  - Comment text may contain line breaks; CSV records are split on quoted fields, not lines.

### Picking members from a hierarchy

On Export Data and Export Comments, dimensions with a hierarchy have a tree button next to their member filter. It opens a member selector modelled on BPC's: the available members as a checkbox tree (choice of hierarchy, e.g. `PARENTH1`, display as ID and/or description, search) and the selected members on the right, where groups show how many base members they hold.

A selected **group** (parent member) stands for the **base members below it** when exporting data, since fact data is stored on base members only. Comment export also keeps the parents themselves, because comments can be attached to parent members. When splitting by member, each selected group becomes one file; without a selection, the split uses base members only.

## Architecture

```
Browser
  SAPUI5 app "BPC Object Manager"  (chorus.bpc.objects)
  /sap/bc/ui5_ui5/sap/zbpc_objects/
        |  JSON over HTTP
        v
ZCL_BPC_IO_HTTP  (ICF handler, implements if_http_extension)
  /sap/bc/zbpc_io/
        |
        v
ZCL_BPC_IO_SERVICE  (business logic, standard BPC APIs)
```

### Backend (ABAP)

- **`ZCL_BPC_IO_HTTP`** — ICF HTTP handler. Routes requests, validates input, and serialises JSON responses.
- **`ZCL_BPC_IO_SERVICE`** — encapsulates all BPC access (environments, models, scripts, packages, transformation/conversion files, EPM workbooks, dimensions and members, transaction data and comments) using the standard BPC APIs: `cl_ujf_file_service_mgr` for Logic Scripts, Data Manager files and EPM workbooks, `cl_ujd_package` for packages, `cl_uja_dim` for members and hierarchies, an RSDRI query for reading data, the write-back API (`cl_ujo_wb_factory`) for writing data, and `cl_ujc_cmtmanager` for adding comments.

### Frontend (SAPUI5)

BSP UI5 application **`ZBPC_OBJECTS`** ("BPC Object Manager"), files under `src/zbpc_objects.wapa.*`:

- `controller/App.controller.js` — screen logic: object export/import and comparison, data and comment export/import, the hierarchy member selector, and the theme toggle.
- `model/Archive.js` — builds and parses the portable archive format, and reads/writes ZIP files.
- `view/App.view.xml` — the screens: the launch page (an `sap.uxap.ObjectPageLayout` with one section per group) and the object, data and import pages.
- `manifest.json`, `Component.js`, `index.html`, `css/style.css` — standard UI5 application scaffolding. `index.html` picks the saved theme before UI5 loads.

### ICF services

- `/sap/bc/zbpc_io/` → `ZCL_BPC_IO_HTTP` (the REST API).
- `/sap/bc/ui5_ui5/sap/zbpc_objects/` → the SAPUI5 app.

## REST API

Base path: `/sap/bc/zbpc_io`

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/environments` | List environments (AppSets) |
| GET | `/licenses/audit?startDate=<YYYYMMDD>` | Current-client Professional/Standard usage and user evidence; blank start defaults to the last 365 days |
| GET | `/models?environment=<appset>` | List models of an environment |
| GET | `/scripts?environment=<appset>&model=<model>` | List Logic Scripts of a model |
| GET | `/script?environment=<appset>&model=<model>&name=<name.LGF>` | Read one Logic Script (content Base64) |
| GET | `/packages?environment=<appset>&model=<model>` | List Data Manager Packages |
| GET | `/package?environment=<appset>&model=<model>&group=<g>&id=<p>` | Read one package definition |
| GET | `/transformations?environment=<appset>&model=<model>` | List transformation files (`.TDM`) |
| GET | `/transformation?environment=<appset>&model=<model>&name=<name.TDM>` | Read one transformation + its workbook |
| GET | `/conversions?environment=<appset>&model=<model>` | List conversion files (`.CDM`) |
| GET | `/conversion?environment=<appset>&model=<model>&name=<name.CDM>` | Read one conversion + its workbook |
| GET | `/workbooks?environment=<appset>&model=<model>` | List EPM workbooks (reports + input schedules) |
| GET | `/workbook?environment=<appset>&model=<model>&folder=<REPORT\|SCHEDULE>&name=<name>` | Read one workbook (content Base64) |
| POST | `/import` | Import Logic Scripts |
| POST | `/packages/import` | Import Data Manager Packages |
| POST | `/transformations/import` | Import transformation files |
| POST | `/conversions/import` | Import conversion files |
| POST | `/workbooks/import` | Import EPM workbooks |
| GET | `/dimensions?environment=<appset>&model=<model>` | List the dimensions of a model |
| GET | `/members?environment=<appset>&model=<model>&dimension=<dim>` | List a dimension's members with their properties and their parent per hierarchy |
| POST | `/data/export` | Read transaction data as CSV |
| POST | `/data/import` | Write a CSV batch of transaction data |
| GET | `/data/comments?environment=<appset>&model=<model>` | Read comments as CSV |
| POST | `/data/comments/import` | Add a CSV batch of comments |

Import requests are `application/x-www-form-urlencoded` with indexed fields:

- **Scripts:** `count`, `name1..nameN`, `content1..contentN` (Base64), `replace`.
- **Packages:** `count`, `groupN`, `idN`, `descriptionN`, `typeN`, `userGroupN`, `chainN`, `teamN`, `scriptN`, `replace`.
- **Transformations/Conversions:** `count`, `nameN`, `contentN` (Base64 definition), `workbookN` (Base64 `.xls`, optional), `replace`.
- **Workbooks:** `count`, `nameN`, `folderN` (`REPORT` or `SCHEDULE`), `contentN` (Base64 `.xlsm`/`.xlsx`/`.xls`), `replace`.

Import responses return a summary plus per-object results:

```json
{ "results": [ { "name": "X.LGF", "action": "WRITTEN", "message": "" } ],
  "changed": 1, "skipped": 0, "failed": 0 }
```

Members come with their properties and, for dimensions with hierarchies, their parent in each hierarchy (a root has no entry):

```json
{ "members": [ { "id": "TECH", "description": "Technology",
                 "properties": { "CURRENCY": "NZD" }, "parents": { "PARENTH1": "CHORUS" } } ] }
```

Data and comment requests take `environment` and `model`, plus:

- **Filters** (`/data/export`, `/data/comments`): `filterCount`, `filterDimension1..N`, `filterMembers1..N` (comma-separated member ids). A dimension without a filter includes all members.
- **Data import:** `csv` (header plus records). Response: `{ "submitted": n, "success": n, "failed": n, "messages": [...] }`.
- **Comment import:** `csv` and `keepAuthor` (`X` keeps `USER_ID` / `DATEWRITTEN`). Response: `{ "submitted": n, "success": n, "skipped": n, "failed": n, "messages": [...] }`.

Exports respond with `{ "csv": "..." }`.

`POST /data/export` also accepts `preview=X`, which uses a bounded 1,001-record query package and returns `{ "csv": "...", "truncated": true|false }`. The extra row detects truncation; the browser displays up to 1,000 rows. Preview shares the existing environment/model and dimension-filter validation. Changing the model, environment or filters hides stale results until Preview data is pressed again. Regression checks: `node --test tests/data_preview_ui.test.cjs`.

License audit returns `{ "client": "001", "startDate": "20260101", "endDate": "20261003", "professional": 0, "standard": 0, "inactiveProfessional": 0, "inactiveStandard": 0, "users": [...] }`. Each user includes `userId`, `license`, `accountStatus`, `source`, `activity`, `activityDate`, `activityTime`, `environment`, `lastAccessDate` and `lastAccessTime`. Dates use `YYYYMMDD`; timestamps are UTC numeric strings, with zero indicating no recorded timestamp. Invalid or future start dates return 400; missing report authorization returns 403. The endpoint is read-only and its response is not cached.

## Archive format

Exports are gzip-compressed XML, named `<environment>_<model>_<timestamp>.xml.gz` (the timestamp is an ISO instant with filesystem-safe characters, so repeated exports of the same environment/model don't collide):

```xml
<bpcExport version="1.0" environment="..." model="..." exportedAt="...">
  <logicScripts>
    <logicScript name="MY_SCRIPT.LGF" encoding="base64" byteLength="123">
      <content>BASE64_CONTENT</content>
    </logicScript>
  </logicScripts>
  <packages>
    <package group="Standard Packages" id="MY_PKG" description="..."
             type="Process Chain" userGroup="0001" chain="/CPMB/..." team="">
      <script>...</script>
    </package>
  </packages>
  <transformations>
    <transformation name="IMPORT.TDM">
      <content>BASE64_CONTENT</content>
      <workbook>BASE64_XLS</workbook>
    </transformation>
  </transformations>
  <conversions>
    <conversion name="CONVERSION.CDM">
      <content>BASE64_CONTENT</content>
      <workbook>BASE64_XLS</workbook>
    </conversion>
  </conversions>
  <workbooks>
    <workbook name="MY_REPORT.XLSM" folder="REPORT" encoding="base64" byteLength="123456">
      <content>BASE64_CONTENT</content>
    </workbook>
  </workbooks>
</bpcExport>
```

Logic Script content is Base64-encoded and preserves the original byte encoding, so scripts round-trip exactly. Transformation/conversion definitions (`.TDM`/`.CDM`) and their paired `.xls` workbooks are also stored Base64-encoded so they round-trip byte-for-byte. EPM Workbooks are stored Base64-encoded with a `folder` attribute of `REPORT` (reports) or `SCHEDULE` (input schedules) that records which library each belongs to.

## CSV formats

Fields are comma-separated; a field holding a comma, a double quote or a line break is wrapped in double quotes, with `""` for a quote. Column order is free on import, but every dimension of the target model must be present.

| File | Columns |
| --- | --- |
| Data | one column per dimension, then `SIGNEDDATA` |
| Comments | one column per dimension, then `SCOMMENT`, `USER_ID`, `DATEWRITTEN` (UTC timestamp `YYYYMMDDhhmmss`), `KEYWORD`, `PRIORITY` |

On comment import only `SCOMMENT` is required besides the dimensions; a blank `USER_ID` or `DATEWRITTEN` falls back to the importing user and the current time.

## Limits

| Resource | Limit |
| --- | --- |
| Logic Scripts per import | 2000 |
| Script content per import | 20 MB (decoded) |
| Packages per import | 1000 |
| Package script content per import | 5 MB (decoded) |
| Transformation/conversion files per import | 1000 |
| Transformation/conversion content per import | 20 MB (decoded, definition + workbook) |
| EPM Workbooks per import | 500 |
| EPM Workbook content per import | 50 MB (decoded; `.xlsm` reports are large) |
| Export size | 50 MB of XML |
| Filter members per data/comment export | 100,000 (all dimensions together) |
| Files per split data export | 200 |
| Data/comment file upload | 100 MB (CSV or ZIP) |
| Data/comment import request | 20 MB of CSV and 50,000 lines (the app sends batches of 2,000 records) |
| Messages per import request | 100 distinct messages |

## Requirements & authorization

- SAP BPC, version for SAP NetWeaver, with the standard BPC APIs available. Developed and validated on BPC 10.1 on SAP NetWeaver 7.52; the ABAP avoids syntax newer than 7.52.
- Importing Logic Scripts requires the same task authorization as the BPC script editor.
- Importing packages requires the same authorization as the BPC package editor.
- Importing transformation/conversion files requires the same authorization as the BPC Data Manager transformation/conversion editors.
- Importing EPM workbooks requires the same authorization as writing report/input-schedule files through the BPC EPM file service.
- Importing data requires the task for sending data from the EPM add-in (`P0038`) and write access to the members; work status locks are respected.
- Importing comments requires a comment task (`P0057` or `P0058`) and write access to the members; work status locks are respected.
- SAPUI5 1.52 or later (served from the SAP UI5 repository), including the `sap.uxap` library. Validated against the 1.52.x runtime; the UI avoids APIs added after 1.52 (for example, `sap.m.List` `groupHeaderFactory`). The dark theme is `sap_belize_plus`, because the Fiori 3 and Horizon dark themes are not part of 1.52.

## Installation

This is an **abapGit** repository. Clone it into an SAP system using abapGit (the Eclipse/ADT ABAP Git plugin or standalone abapGit), then pull into a development package. The package metadata targets component `BW4-BPC` (`DW50000033`).

After activation the app is available at:

- **App:** `/sap/bc/ui5_ui5/sap/zbpc_objects/index.html?sap-client=<client>`
- **API:** `/sap/bc/zbpc_io/`
