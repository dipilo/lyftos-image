var panel = new Panel("org.kde.panel");
panel.location = "bottom";
panel.alignment = "left";
panel.hiding = "none";
panel.height = 44;

// Plasma 5.27+ only, Vapor leaves it floating.
if (typeof panel.floating !== "undefined") {
    panel.floating = false;
}

var launcher = panel.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "lyftos-logo-icon");
launcher.reloadConfig();

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
