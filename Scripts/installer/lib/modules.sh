#!/usr/bin/env bash

module_description() {
  case "$1" in
    base) echo "icons, wallpapers, fonts, base directories" ;;
    gnome) echo "GNOME tweaks package, shortcuts script, wallpaper, extensions from Scripts/installer/data/gnome_extensions.txt" ;;
    terminal) echo "fish/kitty/starship/fastfetch setup + configs" ;;
    media) echo "mpv stack packages + mpv config" ;;
    language) echo "ibus + anthy input setup" ;;
    virtualization) echo "libvirt/qemu stack and optional service setup" ;;
    *) echo "custom module" ;;
  esac
}

module_sudo_scope() {
  case "$1" in
    base) echo "none" ;;
    gnome) echo "package install (optional)" ;;
    terminal) echo "package install (optional)" ;;
    media) echo "package install (optional)" ;;
    language) echo "package install (optional)" ;;
    virtualization) echo "package install, usermod, systemctl, virsh (optional)" ;;
    *) echo "varies" ;;
  esac
}

module_user_scope() {
  case "$1" in
    base) echo "copy icons/wallpapers/fonts, font cache refresh" ;;
    gnome) echo "GNOME keybindings, launchers, wallpaper settings" ;;
    terminal) echo "copy configs, chsh, cargo install" ;;
    media) echo "copy mpv config" ;;
    language) echo "start ibus daemon" ;;
    virtualization) echo "module selection and confirmations" ;;
    *) echo "varies" ;;
  esac
}

apply_gnome_shortcuts_from_installer() {
  local wm_schema="org.gnome.desktop.wm.keybindings"
  local media_schema="org.gnome.settings-daemon.plugins.media-keys"
  local base_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

  # Workspace move shortcuts (Super+Shift+1..5)
  run_cmd "gsettings set $wm_schema move-to-workspace-1 \"['<Shift><Super>1']\""
  run_cmd "gsettings set $wm_schema move-to-workspace-2 \"['<Shift><Super>2']\""
  run_cmd "gsettings set $wm_schema move-to-workspace-3 \"['<Shift><Super>3']\""
  run_cmd "gsettings set $wm_schema move-to-workspace-4 \"['<Shift><Super>4']\""
  run_cmd "gsettings set $wm_schema move-to-workspace-5 \"['<Shift><Super>5']\""

  # Workspace switch shortcuts (Super+1..5)
  run_cmd "gsettings set $wm_schema switch-to-workspace-1 \"['<Super>1']\""
  run_cmd "gsettings set $wm_schema switch-to-workspace-2 \"['<Super>2']\""
  run_cmd "gsettings set $wm_schema switch-to-workspace-3 \"['<Super>3']\""
  run_cmd "gsettings set $wm_schema switch-to-workspace-4 \"['<Super>4']\""
  run_cmd "gsettings set $wm_schema switch-to-workspace-5 \"['<Super>5']\""

  # Traditional Alt+Tab behavior
  run_cmd "gsettings set $wm_schema switch-windows \"['<Alt>Tab']\""
  run_cmd "gsettings set $wm_schema switch-windows-backward \"['<Shift><Alt>Tab']\""
  run_cmd "gsettings set $wm_schema switch-applications \"[]\""
  run_cmd "gsettings set $wm_schema switch-applications-backward \"[]\""

  # Battery percentage
  run_cmd "gsettings set org.gnome.desktop.interface show-battery-percentage true"

  # Custom launcher slots
  run_cmd "gsettings set $media_schema custom-keybindings \"['$base_path/custom0/', '$base_path/custom1/', '$base_path/custom2/', '$base_path/custom3/', '$base_path/custom4/', '$base_path/custom5/']\""

  # Super+E: Files
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom0/ name 'files'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom0/ command 'nautilus --new-window'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom0/ binding '<Super>e'"

  # Super+Enter: Kitty
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom1/ name 'kitty'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom1/ command 'kitty'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom1/ binding '<Super>Return'"

  # Super+R: Btop
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom2/ name 'btop'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom2/ command 'kitty -e btop'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom2/ binding '<Super>r'"

  # Super+B: Zen Browser
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom3/ name 'zen'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom3/ command 'flatpak run app.zen_browser.zen'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom3/ binding '<Super>b'"

  # Super+F9: NormCap
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom4/ name 'Ocr'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom4/ command '/usr/bin/flatpak run com.github.dynobo.normcap'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom4/ binding '<Super>F9'"

  # Super+ç: Runin in Kitty
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom5/ name 'runin'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom5/ command 'kitty -e runin'"
  run_cmd "gsettings set ${media_schema}.custom-keybinding:$base_path/custom5/ binding '<Super>ccedilla'"

  # Super+Q close window
  run_cmd "gsettings set $wm_schema close \"['<Super>q']\""
}

ensure_base_dirs() {
  run_cmd "mkdir -p \"$HOME/.config\" \"$HOME/.local/share/icons\" \"$HOME/.local/share/fonts\" \"$HOME/Pictures/wallpapers\""
}

ensure_flatpak_available() {
  if command -v flatpak >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
    warn "Flatpak is not installed and package installation is disabled."
    return 1
  fi

  if [[ "$PKG_KIND" == "unknown" ]]; then
    warn "Cannot auto-install flatpak on unsupported distro."
    return 1
  fi

  local cmd=""
  if [[ "$PKG_KIND" == "arch" ]]; then
    cmd="pacman -S --needed flatpak"
  else
    cmd="dnf install -y flatpak"
  fi

  log "$(style '1;36' "Flatpak is missing. Installing flatpak package...")"
  run_root_cmd "$cmd"
}

install_flatpak_bundle() {
  print_section "Flatpak apps"
  log "Curated apps count: ${#FLATPAK_APPS[@]}"

  if ! ensure_flatpak_available; then
    record_failed "flatpak:missing"
    return 1
  fi

  run_cmd "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
  run_cmd "flatpak install -y flathub ${FLATPAK_APPS[*]}"
  record_completed "flatpak:bundle"
}

install_gnome_extensions_bundle() {
  local ext_file="$INSTALLER_ROOT/data/gnome_extensions.txt"
  # Backward compatibility if old path is still used in local setup.
  if [[ ! -f "$ext_file" && -f "$SCRIPTS_DIR/gnome_extensions.txt" ]]; then
    ext_file="$SCRIPTS_DIR/gnome_extensions.txt"
  fi

  print_section "GNOME extensions"

  if [[ ! -f "$ext_file" ]]; then
    warn "Extensions file not found: $ext_file"
    record_skipped "gnome-extensions:file-missing"
    return 0
  fi

  local uuids=()
  mapfile -t uuids < <(sed -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' "$ext_file" | awk 'NF && $1 !~ /^#/')
  if [[ "${#uuids[@]}" -eq 0 ]]; then
    warn "No extension UUIDs configured in $ext_file"
    record_skipped "gnome-extensions:empty-list"
    return 0
  fi

  if ! command -v gnome-extensions >/dev/null 2>&1; then
    warn "gnome-extensions command not found; skipping extension enable step."
    return 0
  fi

  if ! command -v gext >/dev/null 2>&1; then
    warn "gext is unavailable; enabling only extensions that are already installed."
    local preinstalled_uuid
    for preinstalled_uuid in "${uuids[@]}"; do
      if gnome-extensions info "$preinstalled_uuid" >/dev/null 2>&1; then
        run_cmd "gnome-extensions enable \"$preinstalled_uuid\"" || true
      else
        warn "Extension not installed yet: $preinstalled_uuid"
      fi
    done
    record_completed "gnome-extensions:enable-preinstalled"
    return 0
  fi

  local uuid
  for uuid in "${uuids[@]}"; do
    if run_cmd "gext install \"$uuid\""; then
      run_cmd "gnome-extensions enable \"$uuid\"" || true
    else
      warn "Failed to install extension: $uuid"
      record_failed "gnome-extension:$uuid"
    fi
  done

  record_completed "gnome-extensions:bundle"
}

set_default_fish_shell_if_available() {
  local fish_path
  fish_path="$(command -v fish || true)"
  if [[ -z "$fish_path" || ! -x "$fish_path" ]]; then
    warn "fish is not installed; skipping default shell change."
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    run_cmd "chsh -s \"$fish_path\""
    FISH_SHELL_CHANGED=1
    return 0
  fi

  # Ensure fish path is present in /etc/shells when possible.
  if ! grep -qxF "$fish_path" /etc/shells 2>/dev/null; then
    run_root_cmd_soft "grep -qxF \"$fish_path\" /etc/shells || echo \"$fish_path\" >> /etc/shells" || true
  fi

  if run_cmd "chsh -s \"$fish_path\""; then
    FISH_SHELL_CHANGED=1
  fi
}

is_gnome_session() {
  [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] || [[ "${DESKTOP_SESSION:-}" == *gnome* ]]
}

set_gnome_wallpaper() {
  local src="$HOME/Pictures/wallpapers/background"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    local uri="file://$src"
    run_cmd "gsettings set org.gnome.desktop.background picture-uri \"$uri\""
    run_cmd "gsettings set org.gnome.desktop.background picture-uri-dark \"$uri\""
    return 0
  fi

  if [[ ! -f "$src" ]]; then
    warn "Wallpaper file not found at $src"
    return 1
  fi

  local uri="file://$src"
  run_cmd "gsettings set org.gnome.desktop.background picture-uri \"$uri\""
  run_cmd "gsettings set org.gnome.desktop.background picture-uri-dark \"$uri\""
}

module_base() {
  print_section "Module: base"
  ensure_base_dirs

  if confirm_action "Copy icons to ~/.local/share/icons"; then
    copy_dir_contents "$REPO_ROOT/icons" "$HOME/.local/share/icons"
  fi

  if [[ -d "$REPO_ROOT/themes" ]] && confirm_action "Copy themes to ~/.themes"; then
    copy_dir_contents "$REPO_ROOT/themes" "$HOME/.themes"
  fi

  if confirm_action "Copy wallpapers to ~/Pictures/wallpapers"; then
    copy_dir_contents "$REPO_ROOT/wallpapers" "$HOME/Pictures/wallpapers"
  fi

  if confirm_action "Copy fonts to ~/.local/share/fonts and refresh font cache"; then
    copy_dir_contents "$REPO_ROOT/Fonts" "$HOME/.local/share/fonts"
    run_cmd "fc-cache -fv"
  fi
}

module_terminal() {
  print_section "Module: terminal"
  install_packages "terminal" fish kitty starship fastfetch fzf btop cargo || true

  if confirm_action "Copy Fish config to ~/.config/fish"; then
    copy_tree_as_dir "$REPO_ROOT/fish" "$HOME/.config/fish"
  fi
  if confirm_action "Copy Kitty config to ~/.config/kitty"; then
    copy_tree_as_dir "$REPO_ROOT/kitty" "$HOME/.config/kitty"
  fi
  if confirm_action "Copy Fastfetch config to ~/.config/fastfetch"; then
    copy_tree_as_dir "$REPO_ROOT/fastfetch" "$HOME/.config/fastfetch"
  fi
  if confirm_action "Copy starship.toml to ~/.config"; then
    copy_file_to_dir "$REPO_ROOT/starship.toml" "$HOME/.config"
  fi

  if confirm_action "Set Fish as default shell"; then
    set_default_fish_shell_if_available
  fi

  if confirm_action "Install cargo-update (cargo install cargo-update)"; then
    if command -v cargo >/dev/null 2>&1; then
      run_cmd "cargo install cargo-update"
    else
      warn "cargo not found; skipping cargo-update install."
    fi
  fi

  if confirm_action "Install runin (cargo install runin)"; then
    if command -v cargo >/dev/null 2>&1; then
      run_cmd "cargo install runin"
    else
      warn "cargo not found; skipping runin install."
    fi
  fi
}

module_media() {
  print_section "Module: media"

  if [[ "$PKG_KIND" == "arch" ]]; then
    install_packages "media" mpv ffmpeg libva-utils mesa-vdpau-drivers libva-intel-driver || true
  elif [[ "$PKG_KIND" == "fedora" ]]; then
    install_packages "media" mpv ffmpeg libva-utils libva-vdpau-driver intel-media-driver || true
  else
    warn "Unknown distro package mapping for media module."
  fi

  if confirm_action "Copy MPV config to ~/.config/mpv"; then
    copy_tree_as_dir "$REPO_ROOT/mpv" "$HOME/.config/mpv"
  fi
}

module_language() {
  print_section "Module: language"
  install_packages "language" ibus ibus-anthy || true

  if confirm_action "Start IBus daemon now (ibus-daemon -drx)"; then
    run_cmd "ibus-daemon -drx"
  fi
}

module_virtualization() {
  print_section "Module: virtualization"
  if [[ "$PKG_KIND" == "arch" ]]; then
    install_packages "virtualization" qemu-full virt-manager virt-viewer dnsmasq libguestfs ebtables vde2 openbsd-netcat libvirt edk2-ovmf swtpm || true
  elif [[ "$PKG_KIND" == "fedora" ]]; then
    install_packages "virtualization" @virtualization virt-manager virt-viewer libvirt swtpm || true
  else
    warn "Unknown distro package mapping for virtualization module."
  fi

  if confirm_action "Add user '$USER' to libvirt and kvm groups"; then
    run_root_cmd "usermod -aG libvirt,kvm \"$USER\"" || true
  fi

  if confirm_action "Enable and start libvirtd service/socket"; then
    run_root_cmd "systemctl enable --now libvirtd.socket" || true
    run_root_cmd "systemctl enable --now libvirtd.service" || true
  fi

  if confirm_action "Autostart and start default libvirt network"; then
    if check_root_cmd "virsh net-info default"; then
      run_root_cmd_soft "virsh net-autostart default" || true
      if check_root_cmd "virsh net-info default | grep -qi 'Active:.*yes'"; then
        warn "libvirt default network is already active; skipping net-start."
        record_skipped "virtualization:default-network-already-active"
      else
        run_root_cmd_soft "virsh net-start default" || true
      fi
    else
      warn "libvirt default network is not defined; skipping autostart/start."
      record_skipped "virtualization:default-network-missing"
    fi
  fi
}

module_gnome() {
  print_section "Module: gnome"
  if [[ "$PKG_KIND" == "fedora" ]]; then
    install_packages "gnome" gnome-tweaks gnome-extensions-cli || true
  elif [[ "$PKG_KIND" == "arch" ]]; then
    install_packages "gnome" gnome-tweaks || true
  else
    install_packages "gnome" gnome-tweaks || true
  fi

  if ! is_gnome_session; then
    warn "GNOME session not detected. GNOME-specific actions may fail."
  fi

  if confirm_action "Apply GNOME keybindings/shortcuts from installer"; then
    apply_gnome_shortcuts_from_installer
  fi

  if confirm_action "Set GNOME wallpaper to ~/Pictures/wallpapers/background"; then
    set_gnome_wallpaper || true
  fi

  if confirm_action "Install GNOME extensions from Scripts/installer/data/gnome_extensions.txt"; then
    install_gnome_extensions_bundle || true
  fi
}
