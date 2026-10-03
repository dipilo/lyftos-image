#!/bin/bash

set -ouex pipefail

for path in /usr/libexec/ublue-motd /usr/share/yafti/yafti.yml \
    /usr/share/applications/io.github.ublue_os.yafti_gtk.desktop \
    /etc/skel/.config/autostart/bazzite-portal.desktop; do
    test -s "$path"
    rpm -qf "$path" || true
done

# Review inherited setup actions when the pinned base changes.
sha256sum -c /ctx/branding-upstream.sha256

# Keep the base theme's QML and dependencies; overlay our static settings below.
if [ -d /usr/share/sddm/themes/breeze ]; then
    mkdir -p /usr/share/sddm/themes/lyftos
    cp -a /usr/share/sddm/themes/breeze/. /usr/share/sddm/themes/lyftos/
fi

for theme in com.valve.vapor.desktop com.valve.vgui.desktop; do
    test -f "/usr/share/plasma/look-and-feel/${theme}/contents/splash/Splash.qml"
    grep -qF 'images/bazzite_logo.svgz' "/usr/share/plasma/look-and-feel/${theme}/contents/splash/Splash.qml"
done

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /
chmod 0755 /usr/libexec/ublue-motd

for theme in com.valve.vapor.desktop com.valve.vgui.desktop; do
    gzip -t "/usr/share/plasma/look-and-feel/${theme}/contents/splash/images/bazzite_logo.svgz"
done

wallpaper=/usr/share/wallpapers/Zoople
test -f "${wallpaper}/metadata.json"
test -f "${wallpaper}/contents/screenshot.png"
test -f "${wallpaper}/contents/images/3840x2160.png"
for resolution in 1920x1080 2560x1440 1920x1200 2560x1600; do
    test -s "${wallpaper}/contents/images/${resolution}.png"
done
jq -e . "${wallpaper}/metadata.json" > /dev/null

plasma_updates=/usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates

wallpaper_script="$plasma_updates/lyftos-wallpaper-1.js"
test -f "$wallpaper_script"
grep -qF "\"${wallpaper}/\"" "$wallpaper_script"

layout_script="$plasma_updates/lyftos-layout-1.js"
test -f "$layout_script"
grep -qF 'loadTemplate("org.lyftos.desktop.windowsPanel")' "$layout_script"
panel_template=/usr/share/plasma/layout-templates/org.lyftos.desktop.windowsPanel
jq -e '.KPackageStructure == "Plasma/LayoutTemplate" and .KPlugin.Id == "org.lyftos.desktop.windowsPanel"' "$panel_template/metadata.json" > /dev/null
grep -qF 'new Panel("org.kde.panel")' "$panel_template/contents/layout.js"
grep -qF 'panel.location = "bottom"' "$panel_template/contents/layout.js"
for widget in kickoff icontasks systemtray digitalclock showdesktop; do
    grep -qF "org.kde.plasma.${widget}" "$panel_template/contents/layout.js"
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
set_os_release PRETTY_NAME '"lyftOS"'
set_os_release BOOTLOADER_NAME '"lyftOS"'
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
grep -qxF 'PRETTY_NAME="lyftOS"' "$os_release"
grep -qxF 'BOOTLOADER_NAME="lyftOS"' "$os_release"
cat "$os_release"

# grub2-mkconfig also reads the distributor from system-release.
printf 'lyftOS release %s\n' "$base_version" > /etc/system-release

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

sh -n /usr/libexec/ublue-motd
sh -n /usr/share/lyftos/motd/env.sh
test -s /usr/share/lyftos/motd/welcome.txt
test -s /usr/share/lyftos/motd/tips.txt
command -v shuf
command -v timeout
command -v bootc
command -v gtk4-launch
portal_program=$(readlink -f "$(command -v yafti_gtk.py)")
grep -q "^APP_TITLE = 'Bazzite Portal'$" "$portal_program"
# Yafti ignores the YAML title for its window and regenerated autostart entry.
sed -i -e 's/Bazzite Portal/lyftOS Portal/g' \
    -e 's/Helps you setup Bazzite/Helps you set up lyftOS/g' "$portal_program"
grep -q "^APP_TITLE = 'lyftOS Portal'$" "$portal_program"
if grep -qF 'Bazzite Portal' "$portal_program"; then
    echo 'lyftOS ERROR: inherited Portal window branding remains' >&2
    exit 1
fi
grep -qF '/usr/share/lyftos/motd/welcome.txt' /usr/libexec/ublue-motd
grep -qF 'Name=lyftOS Portal' /usr/share/applications/io.github.ublue_os.yafti_gtk.desktop
grep -qxF 'title: lyftOS Portal' /usr/share/yafti/yafti.yml
if grep -qE '\b(brh|bazzite-rollback-helper)\b|rpm-ostree rebase|ujust verify-image' /usr/share/yafti/yafti.yml; then
    echo 'lyftOS ERROR: Portal contains an upstream image-switch action' >&2
    exit 1
fi

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

# Plymouth runs from the initramfs, which the base image built before our overlay.
# Match Bazzite's generic initramfs flags and use the image's installed kernel.
plymouth-set-default-theme spinner
kernel_version=$(dnf5 repoquery --installed --queryformat='%{evr}.%{arch}' kernel)
test -n "$kernel_version"
test -f "/usr/lib/modules/${kernel_version}/vmlinuz"
initramfs="/usr/lib/modules/${kernel_version}/initramfs.img"
dracut --no-hostonly --kver "$kernel_version" --reproducible --zstd \
    --add ostree --add fido2 --force "$initramfs"
chmod 0600 "$initramfs"

# Fail the build if the early-boot image still contains the inherited watermark.
embedded_watermark=$(mktemp)
lsinitrd --file usr/share/plymouth/themes/spinner/watermark.png "$initramfs" > "$embedded_watermark"
cmp /usr/share/plymouth/themes/spinner/watermark.png "$embedded_watermark"
rm -f "$embedded_watermark"
