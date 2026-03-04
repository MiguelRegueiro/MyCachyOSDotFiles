# 🚀 MyCachyOSDotFiles

<div align="center">

<img src="screenshots/screenshot-terminal-blur.png" alt="My GNOME Desktop with Kitty Terminal on CachyOS" width="48%"/>

<img src="screenshots/screenshot-nautilus-blur.png" alt="My GNOME Desktop with Nautilus File Manager on CachyOS" width="48%"/>

</div>

<br>

Custom dotfiles and system tweaks for CachyOS (Arch-based).

This setup is tailored for CachyOS, but many parts work on other Arch-based systems and GNOME setups.

---

## 🚀 Install

```bash
git clone https://github.com/MiguelRegueiro/MyCachyOSDotFiles
cd MyCachyOSDotFiles
./Scripts/install.sh
```

Test mode (no changes):

```bash
./Scripts/install.sh --dry-run
```

The installer is the main entrypoint for this repo. Manual commands are optional and mainly useful for fine-tuning.

## 🧭 Installer Workflow (What It Does)

The script follows this order:

1. Detect distro (Fedora vs Arch-based/CachyOS package mapping).
2. Guided setup asks:
   - dry-run or real run
   - whether package installs are allowed
   - whether curated Flatpaks should be installed
   - which modules to run
3. Shows a plan summary.
4. If root actions are needed:
   - requests sudo once (`sudo -v`)
   - keeps sudo session alive during run
5. Runs selected modules.
6. Backs up existing files before overwriting config.
7. Prints final summary (`completed / skipped / failed`) and backup/log paths.

### Modules

- `base`
  - Creates `~/.config`, icon/font dirs, wallpaper dir
  - Copies `icons/`, `wallpapers/`, `Fonts/`
  - Refreshes font cache (`fc-cache -fv`)

- `gnome`
  - Installs GNOME packages: `gnome-tweaks`, `gnome-extensions-app`
  - Applies keyboard/workspace shortcuts and launcher keybinds
  - Sets fixed workspaces: `dynamic-workspaces=false`, `num-workspaces=5`
  - Sets GNOME look defaults:
    - dark mode (`prefer-dark`)
    - icon theme: `MacTahoe-dark`
    - cursor theme: `Bibata-Modern-Classic`
  - Sets wallpaper to `~/Pictures/wallpapers/background`
  - Installs Flatpak `com.mattjakeman.ExtensionManager`
  - Installs GNOME extensions from `Scripts/installer/data/gnome_extensions.txt`
    - primary method: GNOME Shell D-Bus install
    - fallback: `gext` (`gnome-extensions-cli`)
    - then enables each extension
  - Applies extension defaults:
    - TopHat: left panel, numeric CPU/RAM, RAM absolute units, hide disk/fs
    - Blur My Shell: blur apps enabled, whitelist `kitty` + `org.gnome.Nautilus`, opaque focused window disabled

- `terminal`
  - Installs packages: `fish`, `kitty`, `fastfetch`, `fzf`, `btop`, `cargo`
  - Copies configs: `fish/`, `kitty/`, `fastfetch/`, `starship.toml`
  - Sets Fish as default shell
  - Sets distro-aware Fish `up` abbreviation:
    - Fedora-like: `dnf upgrade + flatpak update + cargo install-update -a`
    - Arch/CachyOS: `paru -Syu + flatpak update + cargo install-update -a + limine-snapper-sync`
  - Installs:
    - `cargo-update` (`cargo install cargo-update`)
    - `runin` (`cargo install runin`)
    - Starship via official installer:
      `curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"`

- `media`
  - Installs media packages (Fedora/Arch-specific mapping)
  - Copies MPV config

- `language`
  - Installs `ibus` + `ibus-anthy`
  - Optional `ibus-daemon -drx`

- `virtualization`
  - Installs libvirt/QEMU stack (Fedora/Arch-specific mapping)
  - Optional group add, libvirtd enable/start, default network setup

Optional curated Flatpak bundle can be installed as a separate installer step.

---

## 🧱 Detailed Configs

### GNOME Desktop Environment

<details>
<summary><strong>Show section</strong></summary>

Recommended way:

```bash
./Scripts/install.sh
```

GNOME module configures:
- Traditional Alt+Tab behavior (windows, not app groups)
- Battery percentage in top bar
- Workspace shortcuts (`Super+1-5`, `Super+Shift+1-5`)
- Fixed 5 workspaces (dynamic workspaces disabled)
- App launchers (`Super+E`, `Super+Enter`, etc.)
- `Super+Q` for close-window
- Theme defaults (dark mode, icon theme, cursor theme)
- Extension defaults (TopHat + Blur My Shell)

Manual `gsettings` (optional, for incremental changes):

```bash
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
gsettings set org.gnome.desktop.interface show-battery-percentage true
```

Shortcut mapping used:

| Shortcut       | Application          | Command |
|----------------|----------------------|---------|
| `Super + E`    | Files (Nautilus)     | `nautilus --new-window` |
| `Super + Enter`| Kitty Terminal       | `kitty` |
| `Super + R`    | Btop                 | `kitty -e btop` |
| `Super + B`    | Zen Browser          | `flatpak run app.zen_browser.zen` |
| `Super + F9`   | OCR (NormCap)        | `/usr/bin/flatpak run com.github.dynobo.normcap` |
| `Super + Q`    | Close Active Window  | Closes the currently focused window |

Visual style:

1. Enable GNOME module in installer.
2. Optional: customize extension UUID list in `Scripts/installer/data/gnome_extensions.txt`.
3. Re-run GNOME module to apply updated extension list and defaults.

Included themes (`icons/`):

| Component  | Theme                 | Installation |
| ---------- | --------------------- | ------------ |
| Icon Theme | MacTahoe-dark         | Copy to `~/.local/share/icons/` |
| Cursor     | Bibata-Modern-Classic | Copy to `~/.local/share/icons/` |

Install icons:

```bash
cp -r icons/* ~/.local/share/icons/
```

Install fonts:

```bash
mkdir -p ~/.local/share/fonts
cp -r Fonts/* ~/.local/share/fonts/
fc-cache -fv
```

Included fonts:
- `Kaiti.ttf` and `yumin.ttf` (language learning)
- `Fonts/NerdFonts/*` (terminal)

Wallpaper:
- Default: `wallpapers/background`
- Set via desktop context menu (“Change Background”)

GNOME extensions / Blur My Shell preview:

<div align="center">
  <img src="screenshots/extensions-view.png" alt="GNOME Extensions via Extension Manager" width="48%"/>
  <img src="screenshots/blur-MyShell-config.png" alt="Blur My Shell Configuration" width="48%"/>
</div>

</details>

### Terminal & CLI Tools

<details>
<summary><strong>Show section</strong></summary>

This setup uses Kitty + Fish + Starship + Fastfetch. The installer handles package installation and config copy.

- Kitty
  - Config: `~/.config/kitty/kitty.conf`
  - Highlights: Wayland support, transparency/blur, borderless window, font resize shortcuts
- Fish
  - Set default shell: `chsh -s /usr/bin/fish`
  - Config: `~/.config/fish/config.fish`
  - Includes `fzf` key bindings and `up` abbreviation
  - Rust CLI updater used by `up`: `cargo install cargo-update` (adds `cargo install-update -a` to update installed Cargo binaries in one command)
- Starship
  - Install (official): `curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"`
  - Config: `~/.config/starship.toml`
- Fastfetch
  - Config: `~/.config/fastfetch/config.jsonc`

Distro notes:

- Fish `up` abbreviation is distro-aware in this repo and works out-of-the-box for both Fedora-like and Arch/CachyOS systems.
- CachyOS/Arch path includes `sudo limine-snapper-sync`; Fedora path does not.
- Fastfetch image/logo in this setup is CachyOS-themed.
- If you are not on CachyOS, update `~/.config/fastfetch/config.jsonc` logo/image to match your distro.

</details>

### Software & Applications

<details>
<summary><strong>Show section</strong></summary>

Virtualization (QEMU/KVM):

Recommended: enable the `virtualization` module in installer.

Manual path (Arch example):

1. Install packages:
   ```bash
   sudo pacman -S qemu-full virt-manager virt-viewer dnsmasq libguestfs ebtables vde2 openbsd-netcat libvirt edk2-ovmf swtpm
   ```
2. Add your user to groups:
   ```bash
   sudo usermod -aG libvirt,kvm $USER
   ```
3. Enable services:
   ```bash
   sudo systemctl enable --now libvirtd.socket
   sudo systemctl enable --now libvirtd.service
   ```
4. Configure default network:
   ```bash
   sudo virsh net-autostart default
   sudo virsh net-start default
   ```
5. Verify in Virt-Manager.

Utilities, media, language:

- NormCap (OCR)
  - Install: `flatpak install flathub com.github.dynobo.normcap`
  - Launch shortcut in this setup: `Super+F9`
- MPV immersion config
  - Install dependencies (Arch example):
    ```bash
    sudo pacman -S mpv ffmpeg
    sudo pacman -S libva-intel-driver libva-utils mesa-vdpau-drivers
    ```
  - Copy config:
    ```bash
    cp -r mpv/ ~/.config/
    ```
- Japanese input (IBus + Anthy)
  - Install (Arch example): `sudo pacman -S ibus-anthy ibus`
  - Add method in `ibus-setup`
  - Start daemon: `ibus-daemon -drx`

Other Flatpaks:

```bash
flatpak install flathub net.ankiweb.Anki app.zen_browser.zen net.mkiol.SpeechNote org.qbittorrent.qBittorrent
```

Optional extras:

- Anki add-ons:
  1. Zoom for Anki 24 (`1923741581`)
  2. Review Heatmap (`1771074083`)
- SpeechNote voices:
  - Recommended: Kokoro `af_heart`
  - Voice list: https://huggingface.co/hexgrad/Kokoro-82M/blob/main/VOICES.md#american-english
  - Dark mode reference:
    ![SpeechNote Dark Mode](screenshots/speachnote.png)

</details>

### Connectivity

<details>
<summary><strong>Show section</strong></summary>

SSH alias examples:

For Fish (`~/.config/fish/config.local.fish`):

```fish
abbr -a sshserver "ssh username@hostname"
```

For Bash (`~/.bashrc`):

```bash
alias sshserver='ssh username@hostname'
source ~/.bashrc
```

Optional (personal workflow): I also use [SSH Watchdog](https://extensions.gnome.org/extension/9343/ssh-watchdog/) (a small GNOME extension I made) to monitor/manage SSH sessions in GNOME Shell.

</details>

---

## 🟦 CachyOS

### System Optimization & Monitoring

<details>
<summary><strong>Show section</strong></summary>

Swappiness (recommended for high-RAM systems):

1. Check current value: `sysctl vm.swappiness`
2. Set in `/etc/sysctl.conf`: `vm.swappiness = 10`
3. Apply: `sudo sysctl -p`
4. Verify: `cat /proc/sys/vm/swappiness`

Performance tools:
- MangoHud: `MANGOHUD=1`
- Steam launch option: `MANGOHUD=1 gamemoderun %command%`
- Btop install: `sudo pacman -S btop`

</details>

### Hardware & Storage

<details>
<summary><strong>Show section</strong></summary>

External NTFS game drive:

1. Find UUID: `sudo blkid`
2. Create mount point: `sudo mkdir -p /mnt/gamedrive`
3. Add to `/etc/fstab`:
   ```
   UUID=YOUR_UUID_HERE  /mnt/gamedrive  ntfs-3g  uid=1000,gid=1000,rw,exec,umask=000,nofail,x-gvfs-show  0  0
   ```

</details>

---

## 🎮 HP Omen

<details>
<summary><strong>Show section</strong></summary>

This uses the `hp-omen-linux-module` workflow for keyboard RGB control.

1. Clone:
   ```bash
   git clone https://github.com/ranisalt/hp-omen-linux-module
   cd hp-omen-linux-module
   ```
2. Switch to a compatible branch (example): `git checkout rebase-6.15`
3. Install via DKMS:
   ```bash
   sudo dkms remove hp-omen-wmi/0.6.2 --all
   sudo dkms add .
   sudo dkms build hp-omen-wmi/0.6.15
   sudo dkms install hp-omen-wmi/0.6.15
   ```
4. Reload module and verify zones:
   ```bash
   sudo modprobe -r hp-wmi && sudo modprobe hp-wmi
   ls -la /sys/devices/platform/hp-wmi/rgb_zones/
   ```
5. Write color values:
   - Example: `sudo bash -c 'echo 3835ff > /sys/devices/platform/hp-wmi/rgb_zones/zone00'`

Included helper script:

```bash
./Scripts/set_omen_colors_blue.sh
```

</details>

---

## ℹ️ Reference

### How to Use This Repo

1. Clone: `git clone https://github.com/MiguelRegueiro/MyCachyOSDotFiles`
2. Run `./Scripts/install.sh` and select the modules you want.
3. Keep private values local (for example personal SSH aliases) instead of committing them.
4. Re-run installer anytime; existing config is backed up before overwrite.
5. Use `--dry-run` to test changes before applying.

### 📄 License & Third-Party Assets

- Repo-level configuration/scripts are licensed under [LICENSE](LICENSE).
- Third-party bundled assets (fonts/icons/wallpapers/logos) may use different licenses.
- Third-party assets are not claimed as repository-authored work.
- Upstream notices bundled with themes are preserved (for example `icons/MacTahoe/COPYING` and `icons/MacTahoe/AUTHORS`).

### Notes & Compatibility

- These configs were built for CachyOS but installer logic supports Fedora and Arch-based systems.
- Some parts may require extra packages such as `ntfs-3g`, `gamemode`, or `mangohud`.
