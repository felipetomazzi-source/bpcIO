const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

function connection() {
  if (process.env.SAP_URL && process.env.SAP_USER && process.env.SAP_PASSWORD) return process.env;
  const configPath = process.env.BPC_ADT_CONFIG || path.join(process.env.USERPROFILE || process.env.HOME, '.codex/config.toml');
  const config = fs.readFileSync(configPath, 'utf8');
  const section = config.split(/(?=^\[)/m).find(b => /^\[mcp_servers\."?adt"?\.env\]/.test(b));
  if (!section) throw new Error('Set SAP_URL, SAP_USER and SAP_PASSWORD, or configure the ADT MCP.');
  const env = {};
  for (const line of section.split('\n')) {
    const match = line.match(/^(SAP_\w+)\s*=\s*(".*")\s*$/);
    if (match) env[match[1]] = JSON.parse(match[2]);
  }
  return env;
}

function playwright() {
  if (process.env.BPC_PLAYWRIGHT_MODULE) return require(process.env.BPC_PLAYWRIGHT_MODULE);
  try { return require('playwright'); } catch {
    return require(path.join(process.env.APPDATA, 'npm/node_modules/@playwright/cli/node_modules/playwright'));
  }
}

(async () => {
  const env = connection();
  const url = new URL('/sap/bc/ui5_ui5/sap/zbpc_objects/index.html', env.SAP_URL);
  url.searchParams.set('sap-client', env.SAP_CLIENT || '001');
  const browser = await playwright().chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext({ httpCredentials: { username: env.SAP_USER, password: env.SAP_PASSWORD },
    viewport: { width: 1440, height: 1000 }, colorScheme: 'light' });
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => { if (message.text().startsWith('BPC-OPA:')) console.log(message.text()); });
  const results = path.resolve('.test-results'); fs.mkdirSync(results, { recursive: true });
  try {
    const qunit = await context.request.get(new URL('/sap/public/bc/ui5_ui5/resources/sap/ui/thirdparty/qunit.js', url).toString());
    assert.equal(qunit.ok(), true, 'SAP serves its bundled QUnit');
    await page.addInitScript({ content: (await qunit.text()) + '\nQUnit.config.autostart = false;\n' +
      'window.__opaFailures = [];\n' +
      'QUnit.log(function(r) { if (!r.result) window.__opaFailures.push({message:r.message,source:r.source}); });\n' +
      'QUnit.testDone(function(r) { console.log("BPC-OPA: " + r.name + " / passed=" + r.passed + " failed=" + r.failed); });\n' +
      'QUnit.done(function(r) { window.__opaResult = r; });' });
    await page.goto(url.toString(), { waitUntil: 'domcontentloaded' });
    await page.locator('[id$="--dataPreviewTile"]').waitFor({ state: 'visible', timeout: 60000 });
    await page.screenshot({ path: path.join(results, 'hub-desktop.png'), fullPage: true });
    console.log('PASS: live SAP hub renders all four tiles');
    await page.addScriptTag({ path: path.join(__dirname, '../opa5/hub.qunit.js') });
    await page.waitForFunction(() => !!window.__opaResult, null, { timeout: 210000 });
    const opa = await page.evaluate(() => ({ result: window.__opaResult, failures: window.__opaFailures }));
    fs.writeFileSync(path.join(results, 'opa5-results.json'), JSON.stringify(opa, null, 2));
    assert.equal(opa.result.failed, 0, JSON.stringify(opa.failures));
    assert.ok(opa.result.passed >= 10, 'OPA5 must actually execute the journeys');
    console.log('PASS: OPA5 live journeys, ' + opa.result.passed + ' assertions');
    // A fresh app instance exercises real pointer/keyboard input without OPA custom actions.
    await page.goto(url.toString(), { waitUntil: 'domcontentloaded' });
    const previewTile = page.locator('[id$="--dataPreviewTile"]');
    await previewTile.waitFor({ state: 'visible' });
    await page.getByRole('button', { name: 'Switch to dark mode', exact: true }).click();
    await page.waitForFunction(() => sap.ui.getCore().getConfiguration().getTheme() === 'sap_belize_plus' && sap.ui.getCore().isThemeApplied());
    await page.screenshot({ path: path.join(results, 'hub-dark.png'), fullPage: true });
    await page.getByRole('button', { name: 'Switch to light mode', exact: true }).click();
    await page.waitForFunction(() => sap.ui.getCore().getConfiguration().getTheme() === 'sap_belize' && sap.ui.getCore().isThemeApplied());
    console.log('PASS: light/dark theme switching');
    await page.setViewportSize({ width: 390, height: 844 });
    for (const id of ['transportTile', 'gitTile', 'licenseAuditTile', 'dataPreviewTile']) {
      const box = await page.locator('[id$="--' + id + '"]').boundingBox();
      assert.ok(box && box.x >= 0 && box.x + box.width <= 391, id + ' fits the mobile viewport');
    }
    await page.screenshot({ path: path.join(results, 'hub-mobile.png'), fullPage: true });
    console.log('PASS: mobile hub tiles fit a 390px viewport');
    await page.setViewportSize({ width: 1440, height: 1000 });
    await previewTile.focus(); await previewTile.press('Enter');
    const environment = page.locator('[id$="--previewEnvironment"]');
    await environment.waitFor({ state: 'visible' });
    await page.waitForFunction(() => {
      const node = document.querySelector('[id$="--previewEnvironment"]');
      const control = node && sap.ui.getCore().byId(node.id);
      return control && control.getEnabled() && control.getItems().length;
    });
    const environmentName = await page.evaluate(() => sap.ui.getCore().byId(
      document.querySelector('[id$="--previewEnvironment"]').id).getItems()[0].getText());
    await environment.click(); await page.getByRole('option', { name: environmentName, exact: true }).click();
    const model = page.locator('[id$="--dataModel"]');
    await page.waitForFunction(() => {
      const node = document.querySelector('[id$="--dataModel"]');
      const control = node && sap.ui.getCore().byId(node.id);
      return control && control.getItems().length;
    });
    const modelName = await page.evaluate(() => sap.ui.getCore().byId(
      document.querySelector('[id$="--dataModel"]').id).getItems()[0].getText());
    await model.click(); await page.getByRole('option', { name: modelName, exact: true }).click();
    await page.waitForFunction(() => {
      const node = document.querySelector('[id$="--dataModel"]');
      const model = sap.ui.getCore().byId(node.id).getModel('bpc');
      return !!model.getProperty('/dataModel') && !model.getProperty('/dataBusy') && !model.getProperty('/busy');
    });
    const [response] = await Promise.all([
      page.waitForResponse(r => r.url().includes('/zbpc_io/data/export') && (r.request().postData() || '').includes('preview=X')),
      page.getByRole('button', { name: 'Preview data', exact: true }).click()
    ]);
    assert.equal(response.status(), 200, 'Live preview succeeds');
    assert.equal(typeof (await response.json()).truncated, 'boolean');
    await page.locator('[id$="--previewTable"]').waitFor({ state: 'visible' });
    const combo = page.locator('[id$="--dataPage"] .sapMMultiComboBox').first();
    const memberName = await combo.evaluate(node => sap.ui.getCore().byId(node.id).getItems()[0].getText());
    await combo.locator('.sapMComboBoxBaseArrow').click();
    await page.getByRole('option', { name: memberName, exact: true }).click();
    await page.getByText('Leave a dimension empty to include all its members.', { exact: true }).click();
    await page.locator('[id$="--previewTable"]').waitFor({ state: 'hidden' });
    const [filtered] = await Promise.all([
      page.waitForResponse(r => r.url().includes('/zbpc_io/data/export')),
      page.getByRole('button', { name: 'Preview data', exact: true }).click()
    ]);
    assert.equal(filtered.status(), 200);
    const filters = new URLSearchParams(filtered.request().postData());
    assert.ok(Number(filters.get('filterCount')) >= 1, 'Member selection reaches SAP');
    await page.locator('[id$="--previewTable"]').waitFor({ state: 'visible' });
    const memberButton = page.getByRole('button', { name: 'Select members', exact: true }).first();
    await memberButton.click();
    await page.locator('[id$="--hierarchyDialog"]').waitFor({ state: 'visible' });
    await page.getByRole('button', { name: 'Clear all', exact: true }).click();
    await page.getByRole('button', { name: 'Cancel', exact: true }).click();
    await page.locator('[id$="--hierarchyDialog"]').waitFor({ state: 'hidden' });
    assert.equal(await combo.evaluate(node => sap.ui.getCore().byId(node.id).getSelectedKeys().length), 1, 'Cancel preserves applied members');
    await memberButton.click();
    await page.locator('[id$="--hierarchyDialog"] .sapMSF input').fill(memberName.split(' - ')[0]);
    await page.locator('[id$="--hierarchyTree"]').getByText(memberName, { exact: true }).waitFor({ state: 'visible' });
    await page.getByRole('button', { name: 'Clear all', exact: true }).click();
    await page.getByRole('button', { name: 'Apply', exact: true }).click();
    await page.locator('[id$="--hierarchyDialog"]').waitFor({ state: 'hidden' });
    assert.equal(await combo.evaluate(node => sap.ui.getCore().byId(node.id).getSelectedKeys().length), 0, 'Apply commits cleared members');
    await page.getByRole('button', { name: 'Clear all filters', exact: true }).click();
    await page.locator('[id$="--dimensionFilters"] .sapMPanelExpandableIcon').click();
    await combo.waitFor({ state: 'hidden' });
    await page.getByRole('button', { name: 'Preview data', exact: true }).waitFor({ state: 'visible' });
    await page.screenshot({ path: path.join(results, 'preview-collapsed.png'), fullPage: true });
    console.log('PASS: member dialog Apply/Cancel, clear filters and accessible collapsed-panel preview');
    await page.locator('[id$="--dataPage-navButton"]').click();
    console.log('PASS: keyboard tile navigation, real model/member selection and live filtered preview');
    await page.locator('[id$="--gitTile"]').click();
    await page.waitForURL('**/zbpc_git/index.html?sap-client=' + (env.SAP_CLIENT || '001'));
    await page.getByText('bpcGit - Version control for BPC', { exact: true }).waitFor({ state: 'visible' });
    console.log('PASS: BPC Git navigation preserves the SAP client and loads its app');
    assert.deepEqual(errors, [], 'No uncaught browser errors');
  } catch (error) {
    await page.screenshot({ path: path.join(results, 'failure.png'), fullPage: true });
    const state = await page.evaluate(() => {
      const node = document.querySelector('[id$="--dataModel"]');
      const model = node && sap.ui.getCore().byId(node.id).getModel('bpc');
      return { failures: window.__opaFailures, result: window.__opaResult,
        preview: model ? { selectedModel: !!model.getProperty('/dataModel'), busy: model.getProperty('/busy'),
          dataBusy: model.getProperty('/dataBusy'), dimensions: model.getProperty('/dimensions').length } : null };
    });
    fs.writeFileSync(path.join(results, 'failure.json'), JSON.stringify({ ...state, errors }, null, 2));
    throw error;
  } finally { await browser.close(); }
})().catch(error => { console.error(error.message); process.exitCode = 1; });
