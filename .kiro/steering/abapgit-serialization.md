---
inclusion: fileMatch
fileMatchPattern: 'src/**'
---

# abapGit serialization conventions (src/zbpc_io)

When creating or editing abapGit-exported files under `src/`, preserve SAP's exact
serialization format. abapGit round-trips these bytes, so formatting drift causes
spurious diffs or import problems.

## Metadata XML files
Applies to `*.clas.xml`, `*.sicf.xml`, `*.wapa.xml`, `*.smim.xml`, and
`package.devc.xml` (any file containing `<abapGit ...>`).

- Encode as **UTF-8 with BOM**. The first three bytes MUST be `EF BB BF`.
- Preserve existing line endings.

## ABAP source files
Applies to source files: `*.clas.abap`, `*.prog.abap`, `*.fugr.abap`,
`*.intf.abap`, and any other `*.abap` code file abapGit writes.

- **No BOM.** The first bytes are the code itself (e.g. `CLAS`/`CLASS`, `REPORT`,
  `INTERFACE`). Adding a BOM makes abapGit treat `EF BB BF` as part of the first
  source line → syntax error or spurious diff on import.
- Use **CRLF** line endings throughout.
- **End the file with exactly one trailing CRLF** after the final line
  (e.g. `ENDCLASS.\r\n`). abapGit stores a trailing newline; a file ending in
  `ENDCLASS.` with no newline shows up as a `-1 +1` diff on the last line
  (`\ No newline at end of file`).
- Do NOT pad lines to 255 chars — that fixed-width rule is for `*.wapa.*` content
  files only, never for `.abap` source.

> Caution: the str_replace / file-editing tools and any text normalizer tend to
> strip the trailing newline (and can switch CRLF→LF). After editing a `.abap`
> file, re-check the last bytes and line endings before committing.

## WAPA / BSP content files
Applies to `*.wapa.*` content files (e.g. `*.wapa.controller_-*.js`,
`*.wapa.view_-*.xml`, `*.wapa.model_-*.js`, `*.wapa.css_-*.css`,
`*.wapa.index.html`, `*.wapa.manifest.json`, `*.wapa.component.js`) — but NOT
`*.wapa.xml`, which is a metadata file (see above).

- SAP uses **fixed-width serialization**: every stored line is padded with trailing
  spaces to **exactly 255 characters**.
- **Do NOT trim trailing whitespace** in these files. The trailing spaces are
  required padding, not accidental whitespace.
- When adding new lines, pad each to 255 characters with trailing spaces.
- These content files normally do **not** need a BOM; follow the existing exported
  file's encoding.

## After editing
Compare raw bytes and whitespace conventions with neighboring abapGit-exported
files before considering the change done.

### Validation (PowerShell + python)
```powershell
@'
from pathlib import Path

# Metadata XML: must have BOM
for p in Path("src").rglob("*.xml"):
    data = p.read_bytes()
    if b"<abapGit " in data:
        print(p.name, "BOM:", data.startswith(b"\xef\xbb\xbf"))

# ABAP source: no BOM, must end with a trailing CRLF
for p in Path("src").rglob("*.abap"):
    data = p.read_bytes()
    print(p.name, "BOM:", data.startswith(b"\xef\xbb\xbf"),
          "endsCRLF:", data.endswith(b"\r\n"))

# WAPA content: every line padded to 255, no BOM
for p in Path("src").glob("*.wapa.*"):
    if p.name.endswith(".wapa.xml"):
        continue
    data = p.read_bytes()
    body = data[3:] if data.startswith(b"\xef\xbb\xbf") else data
    lines = body.decode("utf-8").split("\r\n")
    print(p.name, "line lengths:", sorted(set(map(len, lines))),
          "BOM:", data.startswith(b"\xef\xbb\xbf"))
'@ | python -
```

Expected results:
- Metadata XML files → `BOM: True`.
- ABAP source files → `BOM: False` and `endsCRLF: True`.
- WAPA content files → `line lengths: [255]` (all lines exactly 255) and `BOM: False`.

Note: read WAPA line lengths from the raw bytes split on `\r\n` (as above), not via
`read_text(...).splitlines()` — `splitlines()` on already-CRLF text can report a
single huge "line" and hide the real per-line widths.
