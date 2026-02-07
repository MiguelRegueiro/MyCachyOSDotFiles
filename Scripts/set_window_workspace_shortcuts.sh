#!/bin/bash

# Script to set up GNOME keyboard shortcuts for moving windows to workspaces and switching between workspaces
# Uses Mod+Shift+Number (Super+Shift+Number) to move windows to workspaces 1-5
# Uses Mod+Number (Super+Number) to switch to workspaces 1-5
# Also configures window switching behavior, application launchers and interface settings

# Define an elegant blue-themed color palette
DARK_BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
BRIGHT_BLUE='\033[1;36m'  # Cyan-blue for highlights
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DARK_GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${DARK_BLUE}"
echo "  ╔══════════════════════════════════════════════════════════════════════════╗"
echo "  ║                    GNOME Keybindings Configuration Tool                  ║"
echo "  ╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${LIGHT_BLUE}Modifying GNOME keybindings to Regueiro's shortcuts...${NC}"

# Define the keybinding schema
SCHEMA="org.gnome.desktop.wm.keybindings"

# Set up shortcuts for moving windows to workspaces 1-5 (Mod+Shift+Number)
gsettings set $SCHEMA move-to-workspace-1 "['<Shift><Super>1']"
gsettings set $SCHEMA move-to-workspace-2 "['<Shift><Super>2']"
gsettings set $SCHEMA move-to-workspace-3 "['<Shift><Super>3']"
gsettings set $SCHEMA move-to-workspace-4 "['<Shift><Super>4']"
gsettings set $SCHEMA move-to-workspace-5 "['<Shift><Super>5']"

# Set up shortcuts for switching to workspaces 1-5 (Mod+Number)
gsettings set $SCHEMA switch-to-workspace-1 "['<Super>1']"
gsettings set $SCHEMA switch-to-workspace-2 "['<Super>2']"
gsettings set $SCHEMA switch-to-workspace-3 "['<Super>3']"
gsettings set $SCHEMA switch-to-workspace-4 "['<Super>4']"
gsettings set $SCHEMA switch-to-workspace-5 "['<Super>5']"

# Configure window switching behavior to use traditional Alt+Tab
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"

# Enable showing battery percentage in the status bar
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Configure custom application launchers
# Create paths for custom keybindings if they don't exist
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/']"

# Super+E: Files (Nautilus)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'files'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'nautilus --new-window'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>e'

# Super+Enter: Kitty Terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'kitty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'kitty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>Return'

# Super+D: Yazi File Manager
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'yazi'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'kitty -e yazi'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>d'

# Super+W: Neovim
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'nvim'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'kitty -e nvim'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>w'

# Super+R: Btop
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ name 'btop'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ command 'kitty -e btop'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ binding '<Super>r'

# Super+B: Zen Browser
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ name 'zen'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ command 'flatpak run app.zen_browser.zen'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ binding '<Super>b'

# Super+F9: OCR (Normcap)
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ name 'Ocr'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ command '/usr/bin/flatpak run com.github.dynobo.normcap'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ binding '<Super>F9'

# Set up Super+Q to close the active window
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

echo -e "${DARK_BLUE}"
echo "  ╔══════════════════════════════════════════════════════════════════════════╗"
echo "  ║                              SUCCESS!                                    ║"
echo "  ║                      Keybindings updated successfully.                   ║"
echo "  ╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${LIGHT_BLUE}📋 Summary of changes:${NC}"
echo ""
echo -e "  ${DARK_BLUE}📍 Workspace Management:${NC}"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Mod+Shift+1-5${NC}: Move window to workspace 1-5"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Mod+1-5${NC}: Switch to workspace 1-5"
echo ""
echo -e "  ${DARK_BLUE}⌨️  Window Management:${NC}"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+Q${NC}: Close active window" # Add this line
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Alt+Tab${NC}: Switch between windows (traditional)"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Shift+Alt+Tab${NC}: Switch between windows in reverse"
echo ""
echo -e "  ${DARK_BLUE}🚀 Application Launchers:${NC}"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+E${NC}: Files (Nautilus)"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+Enter${NC}: Kitty Terminal"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+D${NC}: Yazi File Manager"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+W${NC}: Neovim"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+R${NC}: Btop"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+B${NC}: Zen Browser"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Super+F9${NC}: OCR (Normcap)"
echo ""
echo -e "  ${DARK_BLUE}⚙️  System Settings:${NC}"
echo -e "    ${WHITE}•${NC} ${BRIGHT_BLUE}Show battery percentage${NC}: Enabled"
echo ""
echo -e "${DARK_BLUE}💡 Tip:${NC} ${GRAY}For immediate effect, log out and back in${NC}"
echo -e "      ${GRAY}or restart GNOME Shell (Alt+F2, type 'r', press Enter).${NC}"
echo ""
