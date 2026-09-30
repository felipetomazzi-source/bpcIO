# bpcIO

A simple SAP BPC web application for **exporting and importing BPC objects** between environments (AppSets) and models. It runs entirely inside SAP as a SAPUI5 app backed by a small ABAP REST service, and moves objects through a portable, gzip-compressed XML archive.

## Supported objects

| Object | BPC artifact | Notes |
| --- | --- | --- |
| Logic Scripts | `.LGF` script logic files | Content round-trips byte-for-byte (UTF-8/UTF-16 preserved) |
| Data Manager Packages | Package definitions (group, type, chain, script sequence) | Imported/replaced via `cl_ujd_package` |
| Transformation Files | `.TDM` definitions + their `.xls` workbook | Stored in the model's Data Manager `TRANSFORMATIONFILES` folder |
| Conversion Files | `.CDM` definitions + their `.xls` workbook | Stored in the model's Data Manager `CONVERSIONFILES` folder |
| EPM Workbooks | `.XLSM` / `.XLSX` / `.XLS` reports and input schedules | Stored under the model's `EEXCEL\REPORTS` (reports) and `EEXCEL\INPUT SCHEDULES` (input schedules) file-service folders |

## What it does

- Lists the available **environments** (AppSets) and **models**.
- Lists the **Logic Scripts**, **Data Manager Packages**, **Transformation Files**, **Conversion Files** and **EPM Workbooks** (reports and input schedules) of a model.
- Objects are grouped by type in the browse list. Above the list, a **per-type toggle button** for each type (e.g. `Conversion Files (2/3)`) selects or deselects every object of that type in one click and shows a live selected/total count.
- **Exports** a selection of objects to a single compressed XML archive.
- **Imports** an archive back into a model with **Import into BPC**, with a side-by-side **comparison** of the uploaded version versus the active SAP version.
- Reports the result of every object on import: `WRITTEN`, `REPLACED`, `SKIPPED`, or `FAILED`, plus a per-type summary of how many were written, skipped and failed.

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
- **`ZCL_BPC_IO_SERVICE`** — encapsulates all BPC access (environments, models, scripts, packages, transformation/conversion files, EPM workbooks) using the standard BPC APIs (`cl_ujf_file_service_mgr` for Logic Scripts, Data Manager files and EPM workbooks, `cl_ujd_package` for packages).

### Frontend (SAPUI5)

BSP UI5 application **`ZBPC_OBJECTS`** ("BPC Object Manager"), files under `src/zbpc_objects.wapa.*`:

- `controller/App.controller.js` — screen logic: data loading, export, upload/import and comparison flows.
- `model/Archive.js` — builds and parses the portable archive format.
- `view/App.view.xml` — the screen layout.
- `manifest.json`, `Component.js`, `index.html`, `css/style.css` — standard UI5 application scaffolding.

### ICF services

- `/sap/bc/zbpc_io/` → `ZCL_BPC_IO_HTTP` (the REST API).
- `/sap/bc/ui5_ui5/sap/zbpc_objects/` → the SAPUI5 app.

## REST API

Base path: `/sap/bc/zbpc_io`

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/environments` | List environments (AppSets) |
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

## Requirements & authorization

- SAP BPC (BW/4HANA) with the standard BPC APIs available.
- Importing Logic Scripts requires the same task authorization as the BPC script editor.
- Importing packages requires the same authorization as the BPC package editor.
- Importing transformation/conversion files requires the same authorization as the BPC Data Manager transformation/conversion editors.
- Importing EPM workbooks requires the same authorization as writing report/input-schedule files through the BPC EPM file service.
- SAPUI5 1.52 or later (served from the SAP UI5 repository). Validated against the 1.52.x runtime shipped with BPC 2021.8 web client; the UI avoids APIs added after 1.52 (for example, `sap.m.List` `groupHeaderFactory`).

## Installation

This is an **abapGit** repository. Clone it into an SAP system using abapGit (the Eclipse/ADT ABAP Git plugin or standalone abapGit), then pull into a development package. The package metadata targets component `BW4-BPC` (`DW50000033`).

After activation the app is available at:

- **App:** `/sap/bc/ui5_ui5/sap/zbpc_objects/index.html?sap-client=<client>`
- **API:** `/sap/bc/zbpc_io/`