# MyCachyOSDotFiles

This repository contains my personal dotfiles and configuration files for CachyOS, including custom setups for my OMEN Transcend Gaming Laptop 14-fb0xxx.

## Table of Contents
- [Keyboard RGB Setup](#keyboard-rgb-setup)
- [Virtualization Setup](#virtualization-setup)

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