const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const root = 'system_files/usr/share/plasma/';
const template = fs.readFileSync(root + 'layout-templates/org.lyftos.desktop.windowsPanel/contents/layout.js', 'utf8');
const update = fs.readFileSync(root + 'shells/org.kde.plasma.desktop/contents/updates/lyftos-layout-1.js', 'utf8');

function session(fail = false) {
    const old = { removed: false, remove() { this.removed = true; } };
    const panels = [old];
    const context = vm.createContext({
        panels: () => panels.slice(),
        Panel: function () {
            this.widgets = [];
            this.addWidget = type => {
                const widget = { type, config: {}, writeConfig(k, v) { this.config[k] = v; }, reloadConfig() {} };
                this.widgets.push(widget);
                return widget;
            };
            panels.push(this);
        },
        loadTemplate: id => {
            assert.equal(id, 'org.lyftos.desktop.windowsPanel');
            if (!fail) vm.runInContext(template, context);
        },
    });
    return { old, panels, context };
}

const manual = session();
vm.runInContext(template, manual.context);
assert.equal(manual.old.removed, false);
assert.equal(manual.panels[1].widgets.length, 5);
assert.equal(manual.panels[1].location, 'bottom');

const initial = session();
vm.runInContext(update, initial.context);
assert.equal(initial.old.removed, true);
assert.equal(initial.panels.length, 2);

const missing = session(true);
vm.runInContext(update, missing.context);
assert.equal(missing.old.removed, false);
console.log('Panel layout: manual addition, initial layout, and missing-template checks passed.');
