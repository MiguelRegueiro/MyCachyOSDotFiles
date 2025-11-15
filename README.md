# MyCachyOSDotFiles

This repository contains my personal dotfiles and configuration files for CachyOS, including custom setups for my OMEN Transcend Gaming Laptop 14-fb0xxx.

## Table of Contents
- [Swappiness Configuration](#swappiness-configuration)
- [Virtualization Setup](#virtualization-setup)
- [Keyboard RGB Setup](#keyboard-rgb-setup)
- [Japanese Keyboard Layout](#japanese-keyboard-layout)

## Swappiness Configuration

<details>
<summary>Click here to expand and see details about swappiness configuration for optimal memory management</summary>

### Swappiness Configuration for Systems with Large RAM

#### PROBLEM:
- System was configured with swappiness set to 150, which is too aggressive for a system with 32GB RAM
- High swappiness causes the kernel to swap to disk too aggressively even when ample RAM is available
- This can cause reduced performance on systems with large amounts of RAM
- Note: This was the default setting on my system, which is unusually high (typical defaults are 60)

#### SOLUTION:
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

#### DETAILS:
- Swappiness is a kernel parameter that controls how aggressively the kernel swaps memory to disk
- Value ranges from 0-200, where:
  - 0 = Avoid swapping as much as possible
  - 10 = Very conservative, only swap when necessary (recommended for large RAM systems)
  - 60 = Default value on many distributions
  - Higher values = More aggressive swapping
- For systems with 32GB RAM like this OMEN laptop, a value of 10 is appropriate
- The setting in /etc/sysctl.conf will persist across reboots

#### TROUBLESHOOTING:
- If swappiness resets after reboot, verify /etc/sysctl.conf is being read during boot
- Check for other sysctl configuration files that might override the setting in /etc/sysctl.d/
- Ensure the line `vm.swappiness = 10` doesn't appear multiple times with different values in sysctl configuration files

This configuration helps optimize memory usage on systems with large amounts of RAM by reducing unnecessary swapping to disk.

</details>

## Virtualization Setup

<details>
<summary>Click here to expand and see details about virtualization setup</summary>

### Virtualization Setup for CachyOS

#### Installation:
Install the required virtualization packages:
```bash
sudo pacman -S qemu-full virt-manager virt-viewer dnsmasq bridge-utils libguestfs ebtables vde2 openbsd-netcat
```

#### Initial Setup:
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

## Keyboard RGB Setup

<details>
<summary>Click here to expand and see details about RGB keyboard control for OMEN laptops</summary>

### HP OMEN RGB Keyboard Control Setup - Working Solution

#### PROBLEM:
- HP Omen laptop RGB keyboard control not working with standard Linux hp-wmi module
- Need to install custom hp-omen-linux-module to control RGB zones
- Module failed to build with kernel 6.17.7-5-cachyos due to API changes

#### SOLUTION STEPS:
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

#### USAGE:
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

#### PERSISTENCE:
- Colors MAY persist after reboot (observed behavior can vary by system)
- The module WILL automatically load after reboot since it's installed via DKMS
- On some systems colors persist automatically, on others you may need to set them again
- To ensure colors are set automatically at boot, create a systemd service or startup script

#### TROUBLESHOOTING:
- If RGB zones don't appear, try: `sudo modprobe -r hp-wmi && sudo modprobe hp-wmi`
- Check your laptop is detected as HP Omen: `sudo dmidecode -t system | grep -i "omen"`
- Verify module loaded: `lsmod | grep hp_wmi`

DKMS automatically manages rebuilding the module on kernel updates, so this setup should continue working after kernel updates.

#### Automation:
I've included a script `set_omen_colors.sh` that automatically sets all keyboard zones to the color I chose (3835ff) after system startup. You can run it manually or set it up to run automatically at boot.

</details>

## Japanese Keyboard Layout

<details>
<summary>Click here to expand and see details about Japanese keyboard layout setup with hiragana input</summary>

### Japanese Input Method Setup

#### Installation:
Install the required packages for Japanese input method:
```bash
sudo pacman -S ibus-anthy ibus
```

#### Initial Setup:
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

#### Usage:
- Use `Super + Space` (or configured key combination) to switch between input methods
- When Japanese (Anthy) is active, you'll be able to type in hiragana
- Type hiragana and press space to convert to kanji if needed

#### Alternative Configuration:
You can also manually set the input method to hiragana through the IBus preferences menu after installation.

</details>