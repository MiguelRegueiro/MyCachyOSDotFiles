# 🚀 MyCachyOSDotFiles

<div align="center">

<img src="screenshots/screenshot-terminal-blur.png" alt="My GNOME Desktop with Kitty Terminal on CachyOS" width="48%"/>

<img src="screenshots/screenshot-nautilus-blur.png" alt="My GNOME Desktop with Nautilus File Manager on CachyOS" width="48%"/>

</div>

<br>

**Custom dotfiles and system tweaks for CachyOS** (Arch-based).

This setup is **specifically tailored for CachyOS**, though many configurations will work on **other Arch-based distributions**. Some tools and configurations are universal. I even use most of these tools on other Arch-based systems, so this guide can serve as a reference for **any Arch-based GNOME setup**.

With this setup, you can:

* ✨ Enhance your **GNOME desktop**
* 💻 Improve your **terminal experience**
* 🎮 Optimize your system for **gaming**
* 🌐 Set up **remote access**
* 📝 Support **language learning**
* 🎇 **Many** other goodies

💡 **Tip:** You're free to pick and choose the tools, configs, and themes you like. This is my personal setup guide—tweak anything, swap things out, or follow it exactly as I do. **Make it your own!**

---

## 🚀 Quick Start

Get up and running quickly with these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/MiguelRegueiro/MyCachyOSDotFiles
   cd MyCachyOSDotFiles
   ```

2. **Install prerequisite tools:**
   ```bash
   sudo pacman -S gnome-tweaks
   ```

3. **Run the automated setup script:**
   ```bash
   ./Scripts/set_window_workspace_shortcuts.sh
   ```

4. **Install themes:**
   ```bash
   cp -r icons/* ~/.local/share/icons/
   ```

5. **Copy configuration files:**
   ```bash
   cp -r kitty/ ~/.config/
   cp -r fish/ ~/.config/
   cp -r fastfetch/ ~/.config/
   cp starship.toml ~/.config/
   cp -r mpv/ ~/.config/
   ```

---

<details>
<summary><h2>📦 Summary of the Included Configurations</h2></summary>

### 🎛️ Terminal

* 🐱 **Kitty** terminal setup with transparency and blur effects
* ⭐ **Starship prompt** with custom Catppuccin styling
* 🐟 **Fish Shell** with useful abbreviations for common commands

### 🎮 Gaming

* 🛠️ **MangoHud** fixes for better in-game overlays
* 🔌 **NTFS** game **drive auto-mount** for seamless access and steam compatibility
* 🔧 **Btop** for a lightweight system monitor

### 🖥️ GNOME

* 🔄 Tweaked **Alt+Tab** behavior & battery indicator in top bar
* ⌨️ Custom Keyboard Shortcuts
* 🎨 **MacTahoe icons** + **Bibata cursor** for a sleek UI
* 🖼️ Included **wallpaper**: `wallpapers/background`
* 🧩 Essential **GNOME extensions** [View recommended extensions in Extension Manager →](#extension-manager-open)

### 🛠️ Tools

* 🎬 **MPV** player **configuration** for language immersion
* 📋 **Fastfetch** with custom logo display
* 📦 **Anki** and other **Flatpak** tools
* ✨ **Custom cursors and icons** for enhanced visual experience (see installation instructions below)
* 🅰️ **Fonts** for language learning and development (see installation instructions below)
* 🛠️ **Scripts** for system automation and customization (see descriptions below)

</details>

---

## Table of Contents
- [⚙️ Swappiness Configuration](#swappiness-configuration)
- [🌐 Virtualization Setup](#virtualization-setup)
- [🎮 Keyboard RGB Setup](#keyboard-rgb-setup)
- [🔤 Japanese Keyboard Layout](#japanese-keyboard-layout)
- [Terminal & CLI Tools](#terminal--cli-tools)
- [Performance Monitoring](#performance-monitoring)
- [GNOME Desktop Tweaks](#gnome-desktop-tweaks)
- [External Game Drive Setup (NTFS)](#external-game-drive-setup-ntfs)
- [Remote Access (SSH)](#remote-access-ssh)
- [MPV Language Immersion Configuration](#mpv-language-immersion-configuration)
- [OCR Tool (NormCap)](#ocr-tool-normcap)
- [Anki and other Flatpak tools](#anki-and-other-flatpak-tools)

---

<details>
<summary><h2>⬛ Terminal & CLI Tools</h2></summary>

✨ This setup combines **Kitty**, **Fish**, and **Starship** to create a **fast, modern, and highly customizable terminal experience**:

- **Kitty** → Clean, GPU-accelerated terminal with transparency and blur effects
- **Fish** → Intuitive shell with autosuggestions & syntax highlighting for effortless commands
- **Starship** → Sleek, informative prompt with Git status, environments, execution time, and more
- **Fastfetch** → System information tool with custom CachyOS branding

🚀 The result is a **minimal yet powerful workflow** optimized for **productivity, readability, and daily use**.

### 🔹 Kitty Terminal

* Config: `~/.config/kitty/kitty.conf`
* Features:
  - Wayland support with transparent background and blur
  - Custom Cherry Midnight Modern theme with carefully selected colors
  - Font size adjustment shortcuts (Ctrl+Shift+Plus/Minus)
  - Direct copy/paste without Shift modifier
  - Custom key bindings for efficiency
  - Background opacity set to 0.87 with 32px blur
  - Font size set to 11.5 for optimal readability
  - Hide window decorations for borderless experience
  - Sync to monitor enabled for smoother animations

### 🔹 Fish Shell

* Install:
  ```bash
  sudo pacman -S fish
  ```

* Set as default shell:
  ```bash
  chsh -s /usr/bin/fish
  ```

* Config: `~/.config/fish/config.fish`
* Features:
  - Loads CachyOS-specific configurations
  - Includes fzf key bindings for fuzzy finding
  - Custom abbreviations for common commands:
    - `sshserver` for connecting to remote server
    - `up` for updating system with paru, flatpak, and limine sync
  - Integrates with starship prompt

### 🔹 Starship Prompt

* Install:
  ```bash
  curl -sS https://starship.rs/install.sh | sh
  ```

* Config: `~/.config/starship.toml`
* Features:
  - Custom Catppuccin-inspired color palette
  - Powerline-style prompt with color segments
  - Shows OS, username, directory, Git status, programming languages, and time
  - Includes command duration for long-running commands
  - Custom character symbols for success and error states

### 🔹 Fastfetch

* Install:
  ```bash
  sudo pacman -S fastfetch
  ```

* Config: `~/.config/fastfetch/config.jsonc`
* Features:
  - Custom CachyOS logo display using PNG image
  - Colored output organized by categories (hardware, OS info, system stats)
  - System age calculation showing days since installation
  - Detailed hardware information (CPU, GPU, Memory, Disk)
  - OS and Kernel information
  - Package count and shell information
  - Battery status display
  - Custom color scheme with blue accents

#### 🖥️ Desktop with Terminal

A look at my customized GNOME desktop with `kitty` terminal open:

![My GNOME Desktop with Kitty](screenshots/screenshot-terminal-blur.png)

</details>

---

<details>
<summary><h2>📊 Performance Monitoring</h2></summary>

### 🔸 MangoHud (for gaming overlays)

* Enable:
  ```bash
  MANGOHUD=1
  ```

* Enable per-game:
  ```bash
  MANGOHUD=1 gamemoderun %command%
  ```

* GPU selection (via GOverlay):
  * Go to **Visual Settings**
  * Set correct PCI GPU (e.g. `1:00.0` for NVIDIA)

### 🔸 Btop (system resources monitor)
* Install:
  ```bash
  sudo pacman -S btop
  ```

</details>

---

<details>
<summary><h2>💻 GNOME Desktop Tweaks</h2></summary>

### 🛠️ Automated Configuration Script

The easiest way to configure all GNOME settings, keyboard shortcuts, and behavior fixes is to use the included automation script:

```bash
./Scripts/set_window_workspace_shortcuts.sh
```

This script will automatically configure:
- Traditional Alt+Tab behavior (switching individual windows, not grouped by app)
- Show battery percentage in the top bar
- Workspace management shortcuts (Super+1-5 to switch, Super+Shift+1-5 to move windows)
- Custom application launchers (Super+E, Super+Enter, etc.)
- Window closing shortcut (Super+Q)
- And more GNOME optimizations

### ♣️ Manual Behavior Fixes

If you prefer to configure settings manually, here are the key gsettings commands:

**Restore traditional Alt+Tab (individual windows, not grouped by app):**

```bash
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
```

**Show battery percentage in top bar:**

```bash
gsettings set org.gnome.desktop.interface show-battery-percentage true
```

### ⌨️ Custom Keyboard Shortcuts

The script sets up these convenient keyboard shortcuts:

| Shortcut       | Application          | Command                          |
|----------------|----------------------|----------------------------------|
| `Super + E`    | Files (Nautilus)     | `nautilus --new-window`          |
| `Super + Enter`| Kitty Terminal       | `kitty`                          |
| `Super + R`    | Btop                 | `kitty -e btop`                  |
| `Super + B`    | Zen Browser          | `flatpak run app.zen_browser.zen`|
| `Super + F9`   | OCR                  | `/usr/bin/flatpak run com.github.dynobo.normcap`|
| `Super + Q`    | Close Active Window  | Closes the currently focused window |

### 🔧 How to Set These Shortcuts Manually

If you prefer to set these up manually:

1. Open **Settings** → **Keyboard** → **Keyboard Shortcuts**
2. Scroll down and click **"View and Customize Shortcuts"**
3. Select **"Custom Shortcuts"** in the sidebar
4. Click the **+** button to add each shortcut

### 🎨 Visual Style

#### 🛠️ Prerequisites
1. Install required tools:
   ```bash
   sudo pacman install gnome-tweaks
   ```
2. Enable **User Themes** extension:
   - Open Extensions app (`gnome-extensions-app`)
   - Search for "User Themes"
   - Enable the extension

#### 🔸 Included Themes

All themes are included in this repository in the `icons/` directory:

| Component  | Theme                 | Installation Instructions                                                 |
| ---------- | --------------------- | ------------------------------------------------------------------------- |
| Icon Theme | MacTahoe              | Copy from `icons/` to `~/.local/share/icons/`                            |
| Cursor     | Bibata-Modern-Classic | Copy from `icons/` to `~/.local/share/icons/`                            |

To install all included themes at once:
```bash
cp -r icons/* ~/.local/share/icons/
```

After installation, select your themes in GNOME Tweaks:
- Open **GNOME Tweaks**
- Navigate to "Appearance" tab
- Select your cursor and icon themes from the dropdowns


#### 🅰️ Installing Custom Fonts

To install the custom fonts included in this repository:

1. Create the fonts directory if it doesn't exist:
   ```bash
   mkdir -p ~/.local/share/fonts
   ```

2. Copy the font files from this repository:
   ```bash
   cp -r Fonts/* ~/.local/share/fonts/
   ```

3. Update the font cache:
   ```bash
   fc-cache -fv
   ```

The fonts included are:
- **Kaiti.ttf**: Chinese calligraphy-style font for language learning
- **yumin.ttf**: Japanese Mincho font for language learning
- **NerdFonts/**: Contains developer-focused Nerd Fonts:
  - HackNerdFont-Regular.ttf
  - JetBrainsMonoNerdFont-Regular.ttf

#### 🛠️ Available Scripts

This repository includes useful automation scripts in the `Scripts/` directory:

1. **set_omen_colors_blue.sh**:
   - Sets HP Omen keyboard RGB colors to a blueish-purple (#3835ff)
   - Automatically runs after system startup to restore keyboard colors
   - Usage: `./Scripts/set_omen_colors_blue.sh`

2. **set_window_workspace_shortcuts.sh**:
   - Configures GNOME keyboard shortcuts for enhanced productivity
   - Sets up workspace management shortcuts (Super+1-5 to switch, Super+Shift+1-5 to move windows)
   - Configures custom application launchers (Super+E for files, Super+Enter for terminal, etc.)
   - Enables battery percentage display in the status bar
   - **Note:** This script may contain references to tools (Yazi, Neovim) that are no longer actively used in this setup
   - Usage: `./Scripts/set_window_workspace_shortcuts.sh`

### 🖼️ Included Wallpaper
![Default Wallpaper](background)

Located in `wallpapers/background` - set as your desktop background for the complete look.

**To set wallpaper:**
1. Right-click desktop → "Change Background"
2. Select "Pictures" tab
3. Locate and select `wallpapers/background`
4. Select your new wallpaper

</details>

---

<details>
<summary><h2>🎮 External Game Drive Setup (NTFS)</h2></summary>

### Use Case: Mounting a 2TB M.2 external drive for Steam game storage

1. Find UUID of the drive:
   ```bash
   sudo blkid
   ```

2. Add this to `/etc/fstab` (replace `xxxx-...` with actual UUID):
   ```bash
   UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /mnt/gamedrive  ntfs-3g  uid=1000,gid=1000,rw,exec,umask=000,nofail,x-gvfs-show  0  0
   ```

3. Create mount point:
   ```bash
   sudo mkdir -p /mnt/gamedrive
   ```

> ⚠️ **Backup your `/etc/fstab`** before editing. Mistakes can prevent your system from booting.
> Do this with caution and at your own risk.

</details>

---

<details>
<summary><h2>🌐 Remote Access (SSH) to your server using tailscale or similar</h2></summary>

**Once your computer and server are connected to your VPN:**
Add this to your config.fish:
```bash
    abbr -a sshserver "ssh username@hostname"
```

<details>
<summary><h3>Or if using bash:</h3></summary>
Set up an SSH alias for convenience. Add this to `~/.bashrc`:

```bash
alias sshserver='ssh username@hostname'
```

Apply changes:

```bash
source ~/.bashrc
```

</details>
</details>

---

<details>
<summary><h2>🎥 MPV Language Immersion Configuration</h2></summary>

**Enhanced media playback for language learning** with automatic playback, and language-specific presets.

### 📌 Installation Paths
| Installation Type | Config Location                          |
|-------------------|-----------------------------------------|
| Native Linux      | `~/.config/mpv/`                        |
| Flatpak           | `~/.var/app/io.mpv.Mpv/config/mpv/`     |
| Windows           | `%APPDATA%\mpv\`                        |

### **1️⃣ Install Native MPV (Recommended)**
```bash
# Install MPV with full codec support
sudo pacman -S mpv ffmpeg

# For hardware acceleration (Intel/NVIDIA/AMD):
sudo pacman -S libva-intel-driver libva-utils mesa-vdpau-drivers
```

### **2️⃣ Configuration File Locations**
#### **Native Installation Paths**:
```
~/.config/mpv/
├── mpv.conf           # Main config
├── input.conf        # Keybindings
└── scripts/          # Custom Lua scripts
```

### **3️⃣ Install Language Immersion Config**
```bash
# Create config directory
mkdir -p ~/.config/mpv
```

### 🌍 Language Support
Pre-configured for optimal experience with:
- 日本語 (Japanese)
- 简体中文 (Chinese Simplified)
- Português (Portuguese)
- Русский (Russian)
- English
- Español (Spanish)

### ✨ Key Features
- **Autoplay functionality** for immersion sessions
- **Language-specific presets**:
  - Preferred audio tracks
  - Subtitle styling
- **Smart pause/resume** behavior

> Note: This is a personalized configuration that may need adjustment for your specific language learning needs.

</details>

---

<details>
<summary><h2>📋 OCR Tool (NormCap)</h2></summary>
✨ Optical Character Recognition for Easy Text Capture

NormCap is a cross-platform OCR tool that lets you quickly capture text from anywhere on your screen.

🔹 **Installation**
```bash
# Install via Flatpak (recommended)
flatpak install flathub com.github.dynobo.normcap
```

🔹 **Usage**
1. Launch NormCap using the keyboard shortcut: `Super + F9`
2. Select an area on your screen containing text
3. Text is automatically copied to your clipboard
4. Paste anywhere you need the text

🔹 **Features**
- ✅ Captures text from images, videos, PDFs, etc.
- ✅ Supports multiple languages
- ✅ Automatically copies to clipboard
- ✅ Lightweight and fast
- ✅ Cross-platform (Linux, Windows, macOS)

> 💡 **Important**
> Go to 💻 GNOME Desktop Tweaks and then ⌨️ Custom Keyboard Shortcuts to add a shortcut for the OCR
</details>

---

<details>
<summary><h2>📦 Anki and other Flatpak tools</h2></summary>
✨ Useful applications installed via Flatpak.

✅ Anki: Powerful spaced repetition flashcards
✅ Zen Browser: Minimalist, distraction-free browsing
✅ SpeechNote: Quick voice notes and transcription
✅ qBittorrent: Powerful, ad-free torrent client

🔹 **Installation**

```bash
# Anki - Flashcards
flatpak install flathub net.ankiweb.Anki

# Zen Browser - Lightweight web browser
flatpak install flathub app.zen_browser.zen

# SpeechNote - Voice note-taking
flatpak install flathub net.mkiol.SpeechNote

# qBittorrent - Torrent client
flatpak install flathub org.qbittorrent.qBittorrent
```

<details>
<summary><h2>🌠 Recommended Anki Add-ons</h2></summary>
Enhance your Anki experience with these popular add-ons.

🔹 **Add-ons & Installation**

1. **Zoom for Anki 24**
   Add-on ID: `1923741581`
   *Allows you to zoom in/out on cards for better readability.*

2. **Review Heatmap**
   Add-on ID: `1771074083`
   *Visualizes your review activity with a heatmap for tracking streaks and performance.*

🔹 **How to Install Add-ons**

1. Open Anki
2. Go to `Tools → Add-ons → Get Add-ons`
3. Enter the add-on ID and click **OK**
4. Restart Anki to activate the add-on
</details>

<details>
<summary><h2>🎤 Recommended SpeechNote Voices and how to set up darkmode</h2></summary>
Enhance your SpeechNote experience with high-quality voices.

🔹 **Recommended Voices**

1. **Kokoro Voices**
   *American English recommended:* `af_heart`
   [View all Kokoro voices and ratings](https://huggingface.co/hexgrad/Kokoro-82M/blob/main/VOICES.md#american-english)
   *Features:*
   ✅ Natural-sounding TTS
   ✅ Wide variety of voice styles
   ✅ Supports multiple languages
   ✅ Highly rated by users

🔹 **Dark Mode Settings**

![SpeechNote Dark Mode](screenshots/speachnote.png)

> 💡 Tip: Experiment with different Kokoro voices for note-taking variety and clarity.
</details>
</details>

---

<details>
<summary><h2>🛠️ How to Use This Repo</h2></summary>

1. Clone:
   ```bash
   git clone https://github.com/MiguelRegueiro/MyCachyOSDotFiles
   ```

2. Copy over desired configs to:
   * `~/.config/kitty/`
   * `~/.config/starship.toml`
   * `~/.config/fish/config.fish`
   * `~/.config/fastfetch/`
   * etc.

3. Apply GNOME settings:
> 💡 **Important**
> Go to 💻 GNOME Desktop Tweaks for this step

4. Install the desired tools
</details>

---

<details>
<summary><h2>📸 Extensions and BlurMyShell settings</h2></summary>

#### Extension Manager View

A preview of all installed GNOME extensions inside **Extension Manager**:

![GNOME Extensions via Extension Manager](screenshots/extensions-view.png)

#### Blur My Shell Configuration

Configuration for blurred apps in GNOME:

![Blur My Shell Configuration](screenshots/blur-MyShell-config.png)

</details>

---

<details>
<summary><h2>⚠️ Notes & Compatibility</h2></summary>

* These configs were built and tested on **CachyOS**, but most will work on:
  * Arch Linux
  * Other systemd-based distros using GNOME
* Some parts (like `fstab`, MangoHud) require additional packages like:
  * `ntfs-3g`
  * `gamemode`
  * `mangohud`
</details>

---

<details>
<summary><h2>⚙️ Swappiness Configuration</h2></summary>

✨ Optimizing memory management for systems with large amounts of RAM.

Large RAM systems (32GB+) benefit from lower swappiness values to prevent unnecessary disk swapping when sufficient RAM is available.

🔹 **Problem:**
- System was configured with swappiness set to 150, which is too aggressive for a system with 32GB RAM
- High swappiness causes the kernel to swap to disk too aggressively even when ample RAM is available
- This can cause reduced performance on systems with large amounts of RAM
- Note: This was the default setting on my system, which is unusually high (typical defaults are 60)

🔹 **Solution:**
1. Check current swappiness value:
   ```bash
   cat /proc/sys/vm/swappiness
   # Or use sysctl
   sysctl vm.swappiness
   ```

2. Find where swappiness is configured (likely in /etc/sysctl.conf or related files):
   ```bash
   sudo grep -r "swappiness" /etc/
   ```

3. Edit /etc/sysctl.conf to set an appropriate swappiness value:
   ```bash
   sudo nvim /etc/sysctl.conf
   ```
   Add or modify the line to:
   ```
   vm.swappiness = 10
   ```
   (Value between 1-10 is appropriate for systems with large RAM)

4. Apply the changes immediately without reboot:
   ```bash
   sudo sysctl -p
   ```

5. Verify the new value is applied:
   ```bash
   cat /proc/sys/vm/swappiness
   # Should now show 10
   ```

🔹 **Details:**
- Swappiness is a kernel parameter that controls how aggressively the kernel swaps memory to disk
- Value ranges from 0-200, where:
  - 0 = Avoid swapping as much as possible
  - 10 = Very conservative, only swap when necessary (recommended for large RAM systems)
  - 60 = Default value on many distributions
  - Higher values = More aggressive swapping
- For systems with 32GB RAM like this OMEN laptop, a value of 10 is appropriate
- The setting in /etc/sysctl.conf will persist across reboots

🔹 **Troubleshooting:**
- If swappiness resets after reboot, verify /etc/sysctl.conf is being read during boot
- Check for other sysctl configuration files that might override the setting in /etc/sysctl.d/
- Ensure the line `vm.swappiness = 10` doesn't appear multiple times with different values in sysctl configuration files

This configuration helps optimize memory usage on systems with large amounts of RAM by reducing unnecessary swapping to disk.

</details>

---

<details>
<summary><h2>🌐 Virtualization Setup</h2></summary>

✨ Setting up QEMU/KVM virtualization environment on CachyOS for VM management.

Complete virtualization stack with QEMU, KVM, and Virt-Manager for creating and managing virtual machines.

🔹 **Installation:**
Install the required virtualization packages:
```bash
sudo pacman -S qemu-full virt-manager virt-viewer dnsmasq bridge-utils libguestfs ebtables vde2 openbsd-netcat
```

🔹 **Initial Setup:**
1. Start the libvirt daemon:
   ```bash
   sudo systemctl start libvirtd
   ```

2. Verify the service is running:
   ```bash
   systemctl status libvirtd
   ```

3. Add your user to the required groups for virtualization:
   ```bash
   sudo usermod -aG libvirt libvirt-qemu kvm qemu $USER
   ```
   Note: You'll need to log out and log back in for the group changes to take effect.

4. Start and enable iptables service (required for some network configurations):
   ```bash
   sudo systemctl start iptables.service
   sudo systemctl enable iptables.service
   ```

5. Restart the libvirtd service to apply all changes:
   ```bash
   sudo systemctl restart libvirtd.service
   ```

Once these steps are completed, you can use Virt-Manager to create and manage virtual machines with full hardware acceleration support.

</details>

---

<details>
<summary><h2>🎮 Keyboard RGB Setup</h2></summary>

✨ HP OMEN RGB keyboard control setup for Linux systems.

Control RGB lighting zones on HP OMEN laptops with custom kernel modules for full customization.

🔹 **Problem:**
- HP Omen laptop RGB keyboard control not working with standard Linux hp-wmi module
- Need to install custom hp-omen-linux-module to control RGB zones
- Module failed to build with kernel 6.17.7-5-cachyos due to API changes

🔹 **Solution Steps:**
1. Clone the repository:
   ```bash
   git clone https://github.com/ranisalt/hp-omen-linux-module
   cd hp-omen-linux-module
   ```

2. Check available branches to find one compatible with your kernel:
   ```bash
   git branch -a
   # Look for branches matching your kernel version or newer
   ```

3. Switch to a more recent rebase branch:
   ```bash
   git checkout rebase-6.15  # Works for kernel 6.17.7
   ```

4. Remove old DKMS module (if exists):
   ```bash
   sudo dkms remove hp-omen-wmi/0.6.2 --all
   ```

5. Add the new module to DKMS:
   ```bash
   sudo dkms add .
   ```

6. Build and install the updated module:
   ```bash
   sudo dkms build hp-omen-wmi/0.6.15
   sudo dkms install hp-omen-wmi/0.6.15
   ```

7. Reload the module to make RGB zones available:
   ```bash
   sudo modprobe -r hp-wmi
   sudo modprobe hp-wmi
   ```

8. Verify the RGB zones are now available:
   ```bash
   ls -la /sys/devices/platform/hp-wmi/rgb_zones/
   # Should show zone00, zone01, zone02, zone03
   ```

🔹 **Usage:**
To control the RGB zones:
- Zone 0: `sudo bash -c 'echo RRGGBB > /sys/devices/platform/hp-wmi/rgb_zones/zone00'`
- Zone 1: `sudo bash -c 'echo RRGGBB > /sys/devices/platform/hp-wmi/rgb_zones/zone01'`
- Zone 2: `sudo bash -c 'echo RRGGBB > /sys/devices/platform/hp-wmi/rgb_zones/zone02'`
- Zone 3: `sudo bash -c 'echo RRGGBB > /sys/devices/platform/hp-wmi/rgb_zones/zone03'`

Examples:
- This color is the one I chose (3835ff): `sudo bash -c 'echo 3835ff > /sys/devices/platform/hp-wmi/rgb_zones/zone00'`
- Blue: `sudo bash -c 'echo 0000FF > /sys/devices/platform/hp-wmi/rgb_zones/zone00'`
- Red: `sudo bash -c 'echo FF0000 > /sys/devices/platform/hp-wmi/rgb_zones/zone00'`
- Cyan: `sudo bash -c 'echo 00FFFF > /sys/devices/platform/hp-wmi/rgb_zones/zone00'`

🔹 **Persistence:**
- Colors MAY persist after reboot (observed behavior can vary by system)
- The module WILL automatically load after reboot since it's installed via DKMS
- On some systems colors persist automatically, on others you may need to set them again
- To ensure colors are set automatically at boot, create a systemd service or startup script

🔹 **Troubleshooting:**
- If RGB zones don't appear, try: `sudo modprobe -r hp-wmi && sudo modprobe hp-wmi`
- Check your laptop is detected as HP Omen: `sudo dmidecode -t system | grep -i "omen"`
- Verify module loaded: `lsmod | grep hp_wmi`

DKMS automatically manages rebuilding the module on kernel updates, so this setup should continue working after kernel updates.

🔹 **Automation:**
I've included a script `set_omen_colors.sh` that automatically sets all keyboard zones to the color I chose (3835ff) after system startup. You can run it manually or set it up to run automatically at boot.

</details>

---

<details>
<summary><h2>🔤 Japanese Keyboard Layout</h2></summary>

✨ Japanese input method setup with hiragana support for language learning.

Configure IBus with Anthy engine for Japanese input with hiragana, katakana, and kanji conversion.

🔹 **Installation:**
Install the required packages for Japanese input method:
```bash
sudo pacman -S ibus-anthy ibus
```

🔹 **Initial Setup:**
1. Start the IBus daemon:
   ```bash
   ibus-daemon -drx
   ```
   Or enable and start the systemd service:
   ```bash
   systemctl --user enable --now ibus.service
   ```

2. Add IBus to your startup applications to automatically start on login

3. Configure IBus to include Japanese (Anthy) input method:
   - Run `ibus-setup` to open the configuration window
   - Click on "Input Method" tab
   - Add "Japanese (Anthy)" from the list of available input methods
   - Set the input method to hiragana as default

4. Log out and log back in for the changes to take effect, or restart your session

🔹 **Usage:**
- Use `Super + Space` (or configured key combination) to switch between input methods
- When Japanese (Anthy) is active, you'll be able to type in hiragana
- Type hiragana and press space to convert to kanji if needed

🔹 **Alternative Configuration:**
You can also manually set the input method to hiragana through the IBus preferences menu after installation.

</details>

---