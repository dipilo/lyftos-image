// Plasma runs each of these once per user, keyed by file name. Editing this
// one changes nothing for past users: ship lyftos-wallpaper-2.js instead.

var lyftosWallpaper = "/usr/share/wallpapers/Zoople/";

var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    var desktop = allDesktops[i];
    desktop.wallpaperPlugin = "org.kde.image";
    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktop.writeConfig("Image", lyftosWallpaper);
}
