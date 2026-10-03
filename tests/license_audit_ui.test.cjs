const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

function setup() {
  let controller, request;
  const errors = [];
  const dialog = { opened: false, open() { this.opened = true; }, close() { this.opened = false; } };
  function JSONModel(data) { this.data = data; }
  JSONModel.prototype.setSizeLimit = function () {};
  JSONModel.prototype.setProperty = function (key, value) { this.data[key.slice(1)] = value; };
  JSONModel.prototype.getProperty = function (key) { return this.data[key.slice(1)]; };
  const jQuery = {
    sap: { getUriParameters: () => ({ get: () => '001' }) },
    ajax(options) { request = options; return { abort() { options.error({}, 'abort'); } }; }
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../src/zbpc_objects.wapa.controller_-licenseaudit.controller.js'), 'utf8'), {
    sap: { ui: { define(deps, factory) {
      controller = factory({ extend: (name, methods) => methods }, JSONModel, { error: text => errors.push(text) }, jQuery);
    } } }
  });
  controller.getView = () => ({ setModel() {} });
  controller.byId = id => id === 'userDialog' ? dialog : { getDateValue: () => new Date(2026, 0, 1) };
  controller.onInit();
  const data = {
    startDate: '20260101', endDate: '20261003', client: '001',
    professional: 1, standard: 1, inactiveProfessional: 1, inactiveStandard: 0,
    users: [
      { userId: 'PRO', license: 'Professional', accountStatus: 'Active', activity: 'STD_P_DIM_MANAGE',
        activityDate: '20260110', activityTime: '20260110123456', lastAccessDate: '20261002', lastAccessTime: '20261002150000', environment: 'ENV' },
      { userId: 'STD', license: 'Standard', accountStatus: 'Active', activity: '',
        activityDate: '20260901', activityTime: '0', lastAccessDate: '20260901', lastAccessTime: '0' },
      { userId: 'LOCKED', license: 'Professional', accountStatus: 'Inactive', activity: 'EBD_P_APPL_MANAGE',
        activityDate: '20260501', activityTime: '0', lastAccessDate: '20260501', lastAccessTime: '0' }
    ]
  };
  return { controller, dialog, errors, data, request: () => request };
}

test('loads SAP audit defaults and preserves the SAP client', () => {
  const s = setup();
  assert.equal(s.request().url, '/sap/bc/zbpc_io/licenses/audit');
  assert.equal(s.request().data['sap-client'], '001');
  assert.equal(s.request().data.startDate, '');
  s.request().success(s.data); s.request().complete();
  assert.equal(s.controller._model.data.startDate, '20260101');
  assert.equal(s.controller._model.data.busy, false);
  assert.equal(s.controller._model.data.rows.length, 2);
});

test('tile drill-down separates active/inactive users and keeps last access distinct from qualifying activity', () => {
  const s = setup(); s.request().success(s.data);
  s.controller.onProfessional();
  assert.equal(s.controller._model.data.rows.length, 1);
  const user = s.controller._model.data.rows[0];
  assert.equal(user.lastAccess, '2026-10-02 15:00:00 UTC');
  assert.equal(user.qualifyingDate, '2026-01-10 12:34:56 UTC');
  assert.equal(user.activity, 'STD_P_DIM_MANAGE');
  s.controller.onUserPress({ getSource: () => ({ getBindingContext: () => ({ getObject: () => user }) }) });
  assert.equal(s.dialog.opened, true);
  assert.equal(s.controller._model.data.selected.userId, 'PRO');
  s.controller._model.setProperty('/accountStatus', 'Inactive'); s.controller.onFilter();
  assert.equal(s.controller._model.data.rows[0].userId, 'LOCKED');
  assert.equal(s.controller._model.data.standard, 0);
  s.controller.onStandard(); assert.equal(s.controller._model.data.rows.length, 0);
});

test('search filters users without changing measured totals; unknown timestamps remain unknown', () => {
  const s = setup(); s.request().success(s.data);
  s.controller._model.setProperty('/search', 'dim manage'); s.controller.onFilter();
  assert.equal(s.controller._model.data.rows.length, 1);
  assert.equal(s.controller._model.data.professional, 1);
  assert.equal(s.controller._model.data.standard, 1);
  assert.equal(s.controller._time('00000000', '0'), 'Not recorded');
  assert.equal(s.controller._time('20260901', '0'), '2026-09-01');
});

test('date changes hide stale results and SAP errors do not appear as zero usage', () => {
  const s = setup(); s.request().success(s.data); s.request().complete();
  s.controller.onStartDateChange();
  assert.equal(s.controller._model.data.loaded, false);
  assert.equal(s.controller._model.data.rows.length, 0);
  s.controller.onAnalyse();
  s.request().error({ responseJSON: { error: { message: 'BPC access denied' } } }, 'error');
  s.request().complete();
  assert.deepEqual(s.errors, ['BPC access denied']);
  assert.equal(s.controller._model.data.loaded, false);
  assert.equal(s.controller._model.data.busy, false);
});

test('destroying the view aborts the request and suppresses late responses', () => {
  const s = setup(); s.controller.onExit(); s.request().success(s.data);
  assert.equal(s.controller._model.data.loaded, false);
  assert.deepEqual(s.errors, []);
});

test('invalid date entry cannot silently run the default analysis', () => {
  const s = setup(); s.request().complete();
  s.controller.onStartDateChange({ getParameter: () => false });
  s.controller.onAnalyse();
  assert.deepEqual(s.errors, ['Choose a valid start date.']);
  assert.equal(s.controller._model.data.busy, false);
});
