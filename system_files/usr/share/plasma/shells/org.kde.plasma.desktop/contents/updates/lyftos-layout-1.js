// Plasma runs each of these once per user, keyed by file name. Editing this
// one changes nothing for past users: ship lyftos-layout-2.js instead.

// Vapor's panel is the Steam Deck desktop layout, so replacing it is the point.
var existing = panels();
for (var i = 0; i < existing.length; i++) {
    existing[i].remove();
}

var panel = new Panel("org.kde.panel");
panel.location = "bottom";
panel.alignment = "left";
panel.hiding = "none";
panel.height = 44;

// Plasma 5.27+ only, and Vapor leaves it floating.
if (typeof panel.floating !== "undefined") {
    panel.floating = false;
}

var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "lyftos-logo-icon");
launcher.reloadConfig();

// Same pins bazzite-pins.js would write. Setting them here means that script
// finds a non-empty value and leaves our panel alone, whichever runs first.
var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "preferred://browser",
    "applications:steam.desktop",
    "applications:net.lutris.Lutris.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:io.github.kolunmi.Bazaar.desktop",
    "applications:io.github.ublue_os.yafti_gtk.desktop",
    "preferred://filemanager"
]);
tasks.writeConfig("showOnlyCurrentDesktop", false);
tasks.reloadConfig();

panel.addWidget("org.kde.plasma.systemtray");

var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
clock.writeConfig("dateFormat", "shortDate");
clock.reloadConfig();

panel.addWidget("org.kde.plasma.showdesktop");
