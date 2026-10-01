#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

wallpaper=/usr/share/wallpapers/Zoople
test -f "${wallpaper}/metadata.json"
test -f "${wallpaper}/contents/screenshot.png"
test -f "${wallpaper}/contents/images/3840x2160.png"
python3 -c "import json,sys; json.load(open(sys.argv[1]))" "${wallpaper}/metadata.json"

plasma_updates=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates

wallpaper_script="$plasma_updates/lyftos-wallpaper-1.js"
test -f "$wallpaper_script"
grep -qF "\"${wallpaper}/\"" "$wallpaper_script"

layout_script="$plasma_updates/lyftos-layout-1.js"
test -f "$layout_script"
grep -qF 'new Panel("org.kde.panel")' "$layout_script"
grep -qF 'panel.location = "bottom"' "$layout_script"
for widget in kickoff icontasks systemtray digitalclock showdesktop; do
    grep -qF "org.kde.plasma.${widget}" "$layout_script"
done

if [ ! -f "$plasma_updates/bazzite-pins.js" ]; then
    echo "lyftOS WARNING: bazzite-pins.js is missing from the Plasma updates directory" >&2
fi

test -s /usr/share/lyftos/release

icons=/usr/share/icons/hicolor
test -f "$icons/scalable/apps/lyftos-logo.svg"
for size in 16 22 24 32 36 48 96 256; do
    test -f "$icons/${size}x${size}/apps/lyftos-logo-icon.png"
done

test -f /usr/share/plymouth/themes/spinner/watermark.png

os_release=/usr/lib/os-release
test -f "$os_release" && test ! -L "$os_release"

base_version=$(sed -n 's/^VERSION_ID=//p' "$os_release" | tr -d '"')
test -n "$base_version"

set_os_release() {
    if grep -q "^$1=" "$os_release"; then
        sed -i "s|^$1=.*|$1=$2|" "$os_release"
    else
        echo "$1=$2" >> "$os_release"
    fi
}

set_os_release NAME '"lyftOS"'
set_os_release PRETTY_NAME "\"lyftOS (FROM Bazzite ${base_version})\""
set_os_release VARIANT '"lyftOS"'
set_os_release DEFAULT_HOSTNAME '"lyftos"'
set_os_release HOME_URL '"https://github.com/dipilo/lyftos-image"'
set_os_release DOCUMENTATION_URL '"https://github.com/dipilo/lyftos-image/blob/main/README.md"'
set_os_release SUPPORT_URL '"https://github.com/dipilo/lyftos-image/issues"'
set_os_release BUG_REPORT_URL '"https://github.com/dipilo/lyftos-image/issues"'
set_os_release LOGO '"lyftos-logo"'
set_os_release ANSI_COLOR '"0;38;2;0;255;255"'

grep -qE '^ID="?bazzite"?$' "$os_release"
grep -qE "^VERSION_ID=\"?${base_version}\"?$" "$os_release"
grep -q '^PRETTY_NAME="lyftOS ' "$os_release"
cat "$os_release"

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

repo=/etc/yum.repos.d/terra-mesa.repo
test -f "$repo"
sed -i -E 's/^[[:space:]]*enabled[[:space:]]*=.*/enabled=0/' "$repo"
grep -q '^enabled=0$' "$repo"

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
