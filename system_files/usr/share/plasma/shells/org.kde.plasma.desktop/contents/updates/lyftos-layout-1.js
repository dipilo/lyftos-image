var existing = panels();
loadTemplate("org.lyftos.desktop.windowsPanel");
if (panels().length > existing.length) {
    for (var i = 0; i < existing.length; i++) {
        existing[i].remove();
    }
}
