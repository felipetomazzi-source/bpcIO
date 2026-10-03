const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

function setup() {
  let methods, request, resolve;
  const values = { environment: 'ENV', dataModel: 'MODEL', dataMode: 'preview', dataBusy: false, busy: false };
  const table = { columns: [], unbindItems() {}, destroyColumns() { this.columns = []; },
    addColumn(c) { this.columns.push(c); }, bindItems(binding) { this.binding = binding; } };
  function Control(options) { Object.assign(this, options); }
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../src/zbpc_objects.wapa.model_-preview.js'), 'utf8'), {
    sap: { ui: { define(deps, factory) { methods = factory(Control, Control, Control); } } }, Promise
  });
  const controller = Object.assign({}, methods, {
    _get: key => values[key], _set: (key, value) => { values[key] = value; },
    _dataFilters: () => [{ dimension: 'ENTITY', members: ['BASE1', 'BASE2'] }],
    _request: (resource, params, method) => {
      request = { resource, params, method };
      return new Promise(r => { resolve = r; });
    },
    byId: () => table, _error: error => { values.error = error.message; }
  });
  const finish = async csv => {
    resolve({ csv });
    await new Promise(r => setImmediate(r));
  };
  return { controller, values, table, finish, request: () => request };
}

test('CSV parsing preserves commas, escaped quotes, line breaks, BOM and numeric strings', () => {
  const s = setup();
  const records = s.controller._parsePreviewCsv('\uFEFFENTITY,SIGNEDDATA\r\n"A,""B""\nC",-1.2500\r\n');
  assert.equal(records[1][0], 'A,"B"\nC');
  assert.equal(records[1][1], '-1.2500');
  assert.throws(() => s.controller._parsePreviewCsv('A,SIGNEDDATA\n"unclosed,1'), /quoted/);
});

test('preview sends member filters and renders dimension columns with the stored amount', async () => {
  const s = setup(); s.controller.onPreviewData();
  const req = s.request();
  assert.equal(req.resource, 'data/export'); assert.equal(req.method, 'POST');
  assert.equal(req.params.preview, 'X'); assert.equal(req.params.filterMembers1, 'BASE1,BASE2');
  await s.finish('ENTITY,SIGNEDDATA\r\nBASE1,-123.45\r\n');
  assert.equal(s.values.previewRows[0].c1, '-123.45');
  assert.equal(s.values.previewLoaded, true); assert.equal(s.values.dataBusy, false);
  assert.equal(s.table.columns[1].hAlign, 'End');
});

test('large results are capped and clearly marked; empty results still show columns', async () => {
  const s = setup(); s.controller.onPreviewData();
  await s.finish('ENTITY,SIGNEDDATA\n' + Array.from({ length: 1001 }, (_, i) => 'E' + i + ',1').join('\n'));
  assert.equal(s.values.previewRows.length, 1000); assert.match(s.values.dataStatus, /first 1,000/);
  s.controller.onPreviewData(); await s.finish('ENTITY,SIGNEDDATA\r\n');
  assert.equal(s.values.previewRows.length, 0); assert.equal(s.values.previewLoaded, true);
  assert.equal(s.table.columns.length, 2);
});

test('changing filters discards a late preview response', async () => {
  const s = setup(); s.controller.onPreviewData(); s.controller.onPreviewFiltersChange();
  await s.finish('ENTITY,SIGNEDDATA\nOLD,1');
  assert.equal(s.values.previewLoaded, false); assert.equal(s.values.previewRows.length, 0);
  assert.equal(s.values.dataBusy, false);
});

test('malformed rows produce an error without displaying partial data', async () => {
  const s = setup(); s.controller.onPreviewData(); await s.finish('ENTITY,SIGNEDDATA\nBAD,1,EXTRA');
  assert.match(s.values.error, /Invalid data row/); assert.equal(s.values.previewLoaded, false);
});
