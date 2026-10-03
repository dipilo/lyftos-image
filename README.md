# lyftOS

A gaming-first Linux desktop that aims to be approachable on day one and to have no ceiling afterwards. lyftOS is a small, independently maintained layer on top of [Bazzite](https://bazzite.gg/), built and shipped as a signed [bootc](https://github.com/bootc-dev/bootc) image.

## Built on Bazzite

lyftOS derives from `ghcr.io/ublue-os/bazzite:stable` and deliberately adds as little as possible. The gaming stack, kernel, Mesa, Steam integration, driver work, Flatpak setup, Homebrew, and Distrobox all come from [Bazzite](https://github.com/ublue-os/bazzite) and the [Universal Blue](https://universal-blue.org/) project — that work is theirs, not ours. lyftOS was created from [ublue-os/image-template](https://github.com/ublue-os/image-template), Bazzite's [recommended route](https://docs.bazzite.gg/Advanced/creating_custom_image/) for derived images.

What lyftOS adds on top is visible in [`build_files/`](build_files/), plus the files under [`system_files/`](system_files). Branding replaces the inherited Vapor/VGUI splash artwork and sets login and lock-screen backgrounds. Problems with games, drivers, or the desktop that reproduce on plain Bazzite belong upstream, not here.

## Supported hardware

| | |
| --- | --- |
| Target | x86-64 desktop, AMD GPU, UEFI |
| Tested | **Nothing yet** |

Intel and NVIDIA GPUs, laptops, handhelds, and controllers beyond a basic gamepad are out of scope until they are independently tested. An AMD-only prototype is not a promise about other hardware.

## Trying it

Two channels. `stable` only ever contains an image somebody has booted and tested — a `testing` digest, re-tagged unchanged once it passes. `testing` is whatever `main` built most recently. Neither exists until CI has published one.

```bash
# verify the signature before you install anything
cosign verify --key cosign.pub ghcr.io/dipilo/lyftos-image:testing

# on an existing bootc system (Bazzite, Bluefin, Aurora, Fedora Atomic)
sudo bootc switch ghcr.io/dipilo/lyftos-image:testing
systemctl reboot
```

Channels move; a digest does not. Once a build works on your hardware, pin it — every release note lists the digest it published:

```bash
sudo bootc switch ghcr.io/dipilo/lyftos-image@sha256:<digest>
```

Installer media (ISO and qcow2) is built by **Actions → Build disk images**. It
installs by pulling the selected channel from GHCR during installation, so that
channel has to be publicly pullable first.

### Getting back

An update replaces the whole image as a new deployment and leaves the previous one on disk, so the way back is a reboot rather than a repair session:

```bash
sudo bootc rollback
systemctl reboot
```

The previous deployment is also in the boot menu at startup, which is the path
to take when the current one does not reach a desktop.

A rollback restores the operating system only. Your home directory, Flatpak applications, Homebrew packages, and Distrobox containers live outside the image and are never reverted — which is also why reinstalling does not mean rebuilding your setup. Back up your own files.

## Repository contents

```text
Containerfile            # FROM the pinned Bazzite base, then runs build.sh
build_files/build.sh     # everything lyftOS changes about the image
system_files/            # image-owned defaults and assets, copied to /
disk_config/             # bootc-image-builder configs for qcow2 and the KDE ISO
.github/workflows/       # build, promote, disk images, base image updates
Justfile                 # local build, rechunk, and VM recipes
image-template.env       # image name, description, channel
cosign.pub               # public key images are signed with
```

## Building it yourself

You need a Linux machine (or a bootc system) with `podman`, `just`, and `jq`.
Builds do not work on Windows; a VM or WSL is the way in from a Windows
workstation, and the ISO still has to be booted somewhere else.

```bash
git clone https://github.com/dipilo/lyftos-image.git
cd lyftos-image

just build                 # build the container image
just ostree-rechunk        # optional: smaller update deltas
just build-qcow2           # build a VM disk
just run-vm-qcow2          # boot that disk

just lint && just format   # shellcheck and shfmt
just check                 # Justfile syntax, also run in CI
```

`just` reads its settings from [`image-template.env`](image-template.env). The full recipe list is in the
[upstream template README](https://github.com/ublue-os/image-template#justfile-documentation), which these recipes come from unchanged.

### Building your own image from lyftOS

Derive from a digest, not a tag, so your image does not change under you:

```dockerfile
FROM ghcr.io/dipilo/lyftos-image@sha256:<digest-from-a-release-note>
```

Host-level changes need more care than anything in your home directory. Flatpak, Homebrew, and Distrobox cover applications without rebuilding the OS; a derived image is for kernel, driver, and system service changes, and you are responsible for signing, testing, and being able to roll it back.

### Signing

CI signs every pushed image with [cosign](https://docs.sigstore.dev/cosign/)
using the `SIGNING_SECRET` repository secret. `cosign.pub` is committed;
`cosign.key` is ignored by git and must never be committed. Signature
verification gates promotion and installer builds, so a build without a valid
signature cannot reach users.

## Contributing

- Keep the lyftOS layer small, and keep each phase in its own testable commit. The order is baseline → identity → Plasma presets → Hyprland → first-run → Fractal → recipe tooling → installer.
- Do not add a performance tweak because it is described as one. Measure frame times and regressions against the Bazzite baseline first, and ship it as an optional profile rather than a default.
- Changes that alter what users see need a boot test, not just a green build. Say what hardware you tested on.
- A digest reaches `stable` only after it boots, logs in, runs a game through Steam, and rolls back cleanly on named hardware. **Actions → Promote image** re-tags that exact digest; it never rebuilds and never re-signs.
- Anything that touches a user's `~/.config` must be selective, reversible, and must not overwrite settings the user changed themselves.

## Project history

lyftOS began as a fork of Bazzite at [dipilo/lyftOS](https://github.com/dipilo/lyftOS), which is kept online and
unchanged for its history — four lyftOS commits as of `102e5161` (25 September 2026). This repository is a fresh start from the image template with unrelated history, so that lyftOS maintains a small layer instead of a patched copy of Bazzite's build pipeline. Changes are ported from the old fork only where they have a demonstrated purpose.

## License and attribution

Code in this repository is [Apache-2.0](LICENSE).

The Zoople wallpaper is original work by me, the project author and ships under the same license; no third-party artwork is included. Whether artwork should eventually carry terms separate from the code is still open, and has to be
settled before anyone redistributes a derived image.

Bazzite and the Universal Blue images are the work of their own projects and carry their own licenses. lyftOS is not affiliated with or endorsed by Valve, Microsoft, or Apple; "Windows-familiar" and "Mac-familiar" describe layout familiarity only.
