sap.ui.require(["sap/ui/test/Opa5", "sap/ui/test/opaQunit", "sap/ui/test/actions/Press"], function (Opa5, opaTest, Press) {
  "use strict";
  Opa5.extendConfig({ autoWait: true, timeout: 45, pollingInterval: 200 });
  function wait(options) { return new Opa5().waitFor(options); }
  function press(id) { return wait({ id: new RegExp("--" + id + "$"), actions: new Press() }); }
  function selectFirst(control) {
    var item = control.getItems()[0];
    control.setSelectedKey(item.getKey());
    control.fireChange({ selectedItem: item });
  }
  QUnit.module("Live SAP BPCIO journeys");

  opaTest("Hub exposes all four tools", function () {
    ["transportTile", "gitTile", "licenseAuditTile", "dataPreviewTile"].forEach(function (id) {
      wait({ id: new RegExp("--" + id + "$"), success: function (controls) {
        Opa5.assert.strictEqual(controls.length, 1, id + " is visible");
      } });
    });
  });

  opaTest("Transport navigation returns to the hub", function () {
    press("transportTile");
    wait({ id: /--launchPage$/, success: function () { Opa5.assert.ok(true, "Transport opened"); } });
    press("launchPage-navButton");
    wait({ id: /--dataPreviewTile$/, success: function () { Opa5.assert.ok(true, "Returned to hub"); } });
  });

  opaTest("Preview loads a model, refreshes member filters and returns to the hub", function () {
    press("dataPreviewTile");
    wait({ id: /--previewEnvironment$/, check: function (controls) {
      return controls[0].getItems().length > 0 && controls[0].getEnabled();
    }, actions: selectFirst });
    wait({ id: /--dataModel$/, check: function (controls) {
      return controls[0].getItems().length > 0;
    }, actions: selectFirst });
    wait({ controlType: "sap.m.Button", matchers: function (button) {
      return button.getText() === "Preview data";
    }, actions: new Press() });
    wait({ id: /--previewTable$/, success: function (controls) {
      var table = controls[0];
      Opa5.assert.ok(table.getColumns().some(function (column) {
        return column.getHeader().getText() === "SIGNEDDATA";
      }), "Preview includes the stored signed amount");
      Opa5.assert.ok(table.getModel("bpc").getProperty("/previewRows").length <= 1000, "Preview respects its row limit");
    } });
    wait({ controlType: "sap.m.MultiComboBox", matchers: function (control) {
      return control.getItems().length > 0;
    }, actions: function (controls) {
      // OPA custom action for a dynamic member key; real browser selection is also tested by Playwright.
      var control = Array.isArray(controls) ? controls[0] : controls;
      control.setSelectedKeys([control.getItems()[0].getKey()]);
      control.fireSelectionFinish({ selectedItems: [control.getItems()[0]] });
    }, success: function (controls) {
      Opa5.assert.notOk(controls[0].getModel("bpc").getProperty("/previewLoaded"), "Changing members hides the stale preview");
    } });
    wait({ controlType: "sap.m.Button", matchers: function (button) {
      return button.getText() === "Preview data";
    }, actions: new Press() });
    wait({ id: /--previewTable$/, success: function () { Opa5.assert.ok(true, "Filtered preview refreshed"); } });
    press("dataPage-navButton");
    wait({ id: /--dataPreviewTile$/, success: function () { Opa5.assert.ok(true, "Preview returns to the hub"); } });
  });

  opaTest("License audit loads and count tiles drill down", function () {
    press("licenseAuditTile");
    wait({ id: /--professionalTile$/, actions: new Press(), success: function (controls) {
      Opa5.assert.strictEqual(controls[0].getModel("audit").getProperty("/license"), "Professional", "Professional drill-down applied");
    } });
    wait({ id: /--standardTile$/, actions: new Press(), success: function (controls) {
      Opa5.assert.strictEqual(controls[0].getModel("audit").getProperty("/license"), "Standard", "Standard drill-down applied");
    } });
    press("licenseAuditPage-navButton");
    wait({ id: /--gitTile$/, success: function () { Opa5.assert.ok(true, "Audit returns to the hub"); } });
  });
  QUnit.start();
});
