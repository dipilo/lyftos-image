var lyftosPanels = panels();
for (var i = 0; i < lyftosPanels.length; i++) {
    var widgets = lyftosPanels[i].widgets();
    for (var j = 0; j < widgets.length; j++) {
        var widget = widgets[j];
        if (widget.type !== "org.kde.plasma.kickoff" &&
            widget.type !== "org.kde.plasma.kicker" &&
            widget.type !== "org.kde.plasma.kickerdash") {
            continue;
        }
        widget.currentConfigGroup = ["General"];
        var icon = widget.readConfig("icon", "");
        if (icon === "" || /^(start-here|bazzite|fedora|distributor-logo|steamdeck)/.test(icon)) {
            widget.writeConfig("icon", "lyftos-logo-icon");
            widget.reloadConfig();
        }
    }
}

var lockConfig = new ConfigFile("kscreenlockerrc", "Greeter");
var lockPlugin = new ConfigFile(lockConfig, "Wallpaper");
var lockImagePlugin = new ConfigFile(lockPlugin, "org.kde.image");
var lockWallpaper = new ConfigFile(lockImagePlugin, "General");
var lockImage = lockWallpaper.readEntry("Image");
if (!lockImage || /^(file:\/\/)?\/usr\/share\/(wallpapers\/convergence\.jxl|backgrounds\/default\.jxl)$/.test(lockImage)) {
    lockWallpaper.writeEntry("Image", "file:///usr/share/wallpapers/Zoople/contents/images/3840x2160.png");
    lockWallpaper.writeEntry("PreviewImage", "file:///usr/share/wallpapers/Zoople/contents/images/3840x2160.png");
}
