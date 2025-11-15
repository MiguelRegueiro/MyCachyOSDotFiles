#!/bin/bash
# Script to set HP Omen keyboard RGB colors to 3835ff

# Wait a bit for the system to be fully loaded
sleep 3

# Set all zones to #3835ff (a nice blueish-purple color)
sudo bash -c 'echo 3835ff > /sys/devices/platform/hp-wmi/rgb_zones/zone00'
sudo bash -c 'echo 3835ff > /sys/devices/platform/hp-wmi/rgb_zones/zone01'
sudo bash -c 'echo 3835ff > /sys/devices/platform/hp-wmi/rgb_zones/zone02'
sudo bash -c 'echo 3835ff > /sys/devices/platform/hp-wmi/rgb_zones/zone03'

echo "HP Omen keyboard colors set to #3835ff"