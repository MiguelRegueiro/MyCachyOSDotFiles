#!/usr/bin/env bash

module_description() {
  case "$1" in
    base) echo "icons, wallpapers, fonts, base directories" ;;
    gnome-core) echo "GNOME package + core desktop settings (keybindings, workspaces, theme, wallpaper)" ;;
    gnome-extensions) echo "GNOME extension manager, extension install/enable, and extension defaults (best effort)" ;;
    gnome) echo "legacy alias for gnome-core + gnome-extensions" ;;
    terminal) echo "fish/kitty/starship/fastfetch setup + configs" ;;
    media) echo "mpv stack packages + mpv config" ;;
    flatpaks) echo "curated Flatpak application bundle" ;;
    language) echo "ibus + anthy input setup" ;;
    virtualization) echo "libvirt/qemu stack and optional service setup" ;;
    *) echo "custom module" ;;
  esac
}

module_sudo_scope() {
  case "$1" in
    base) echo "none" ;;
    gnome-core) echo "package install (optional)" ;;
    gnome-extensions) echo "flatpak install (optional), optional pip dependency install" ;;
    gnome) echo "package install (optional), flatpak install (optional), optional pip dependency install" ;;
    terminal) echo "package install (optional)" ;;
    media) echo "package install (optional)" ;;
    flatpaks) echo "flatpak package install (if missing)" ;;
    language) echo "package install (optional)" ;;
    virtualization) echo "package install, usermod, systemctl, virsh (optional)" ;;
    *) echo "varies" ;;
  esac
}

module_user_scope() {
  case "$1" in
    base) echo "copy icons/wallpapers/fonts, font cache refresh" ;;
    gnome-core) echo "GNOME keybindings, launchers, workspaces, theme, wallpaper settings" ;;
    gnome-extensions) echo "install/enable GNOME extensions and apply extension defaults (best effort)" ;;
    gnome) echo "legacy alias: runs gnome-core and gnome-extensions" ;;
    terminal) echo "copy configs, chsh, cargo install" ;;
    media) echo "copy mpv config" ;;
    flatpaks) echo "flatpak remote add + flatpak install (user scope)" ;;
    language) echo "start ibus daemon" ;;
    virtualization) echo "module selection and confirmations" ;;
    *) echo "varies" ;;
  esac
}

gsettings_key_supported() {
  local schema="$1"
  local key="$2"
  local schema_dir="${3:-}"

  local out=""
  if [[ -n "$schema_dir" ]]; then
    out="$(gsettings --schemadir "$schema_dir" writable "$schema" "$key" 2>/dev/null || true)"
  else
    out="$(gsettings writable "$schema" "$key" 2>/dev/null || true)"
  fi

  case "$out" in
    true|false) return 0 ;;
    *) return 1 ;;
  esac
}

set_gsettings_safe() {
  local schema="$1"
  local key="$2"
  local value="$3"
  local schema_dir="${4:-}"

  if ! gsettings_key_supported "$schema" "$key" "$schema_dir"; then
    if [[ -n "$schema_dir" ]]; then
      warn "Skipping gsettings set; missing schema/key: schema='$schema' key='$key' schemadir='$schema_dir'"
    else
      warn "Skipping gsettings set; missing schema/key: schema='$schema' key='$key'"
    fi
    record_skipped "gsettings-missing:$schema:$key"
    return 0
  fi

  if [[ -n "$schema_dir" ]]; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" \"$key\" $value" || true
  else
    run_cmd_soft "gsettings set \"$schema\" \"$key\" $value" || true
  fi
  return 0
}

apply_gnome_shortcuts_from_installer() {
  local wm_schema="org.gnome.desktop.wm.keybindings"
  local media_schema="org.gnome.settings-daemon.plugins.media-keys"
  local base_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

  # Workspace move shortcuts (Super+Shift+1..5)
  set_gsettings_safe "$wm_schema" "move-to-workspace-1" "\"['<Shift><Super>1']\""
  set_gsettings_safe "$wm_schema" "move-to-workspace-2" "\"['<Shift><Super>2']\""
  set_gsettings_safe "$wm_schema" "move-to-workspace-3" "\"['<Shift><Super>3']\""
  set_gsettings_safe "$wm_schema" "move-to-workspace-4" "\"['<Shift><Super>4']\""
  set_gsettings_safe "$wm_schema" "move-to-workspace-5" "\"['<Shift><Super>5']\""

  # Workspace switch shortcuts (Super+1..5)
  set_gsettings_safe "$wm_schema" "switch-to-workspace-1" "\"['<Super>1']\""
  set_gsettings_safe "$wm_schema" "switch-to-workspace-2" "\"['<Super>2']\""
  set_gsettings_safe "$wm_schema" "switch-to-workspace-3" "\"['<Super>3']\""
  set_gsettings_safe "$wm_schema" "switch-to-workspace-4" "\"['<Super>4']\""
  set_gsettings_safe "$wm_schema" "switch-to-workspace-5" "\"['<Super>5']\""
  # Use a fixed workspace count instead of GNOME dynamic workspaces.
  set_gsettings_safe "org.gnome.mutter" "dynamic-workspaces" "false"
  set_gsettings_safe "org.gnome.desktop.wm.preferences" "num-workspaces" "5"

  # Traditional Alt+Tab behavior
  set_gsettings_safe "$wm_schema" "switch-windows" "\"['<Alt>Tab']\""
  set_gsettings_safe "$wm_schema" "switch-windows-backward" "\"['<Shift><Alt>Tab']\""
  set_gsettings_safe "$wm_schema" "switch-applications" "\"[]\""
  set_gsettings_safe "$wm_schema" "switch-applications-backward" "\"[]\""

  # Battery percentage
  set_gsettings_safe "org.gnome.desktop.interface" "show-battery-percentage" "true"
  # Prefer dark appearance for GNOME-supported apps/themes.
  set_gsettings_safe "org.gnome.desktop.interface" "color-scheme" "'prefer-dark'"
  # Theme defaults
  set_gsettings_safe "org.gnome.desktop.interface" "cursor-theme" "'Bibata-Modern-Classic'"
  set_gsettings_safe "org.gnome.desktop.interface" "icon-theme" "'MacTahoe-dark'"

  # Custom launcher slots
  set_gsettings_safe "$media_schema" "custom-keybindings" "\"['$base_path/custom0/', '$base_path/custom1/', '$base_path/custom2/', '$base_path/custom3/', '$base_path/custom4/', '$base_path/custom5/']\""

  # Super+E: Files
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom0/" "name" "'files'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom0/" "command" "'nautilus --new-window'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom0/" "binding" "'<Super>e'"

  # Super+Enter: Kitty
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom1/" "name" "'kitty'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom1/" "command" "'kitty'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom1/" "binding" "'<Super>Return'"

  # Super+R: Btop
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom2/" "name" "'btop'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom2/" "command" "'kitty -e btop'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom2/" "binding" "'<Super>r'"

  # Super+B: Zen Browser
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom3/" "name" "'zen'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom3/" "command" "'flatpak run app.zen_browser.zen'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom3/" "binding" "'<Super>b'"

  # Super+F9: NormCap
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom4/" "name" "'Ocr'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom4/" "command" "'/usr/bin/flatpak run com.github.dynobo.normcap'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom4/" "binding" "'<Super>F9'"

  # Super+ç: Runin in Kitty
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom5/" "name" "'runin'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom5/" "command" "'kitty -e runin'"
  set_gsettings_safe "${media_schema}.custom-keybinding:$base_path/custom5/" "binding" "'<Super>ccedilla'"

  # Super+Q close window
  set_gsettings_safe "$wm_schema" "close" "\"['<Super>q']\""
  # Power actions
  set_gsettings_safe "org.gnome.settings-daemon.plugins.media-keys" "shutdown" "\"['<Shift><Super>l']\""
  set_gsettings_safe "org.gnome.settings-daemon.plugins.media-keys" "reboot" "\"['<Shift><Super>p']\""
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

install_gnome_extension_manager_flatpak() {
  if ! ensure_flatpak_available; then
    warn "Flatpak unavailable; cannot install GNOME Extension Manager."
    return 1
  fi
  run_cmd "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
  run_cmd "flatpak install -y flathub com.mattjakeman.ExtensionManager"
  record_completed "flatpak:gnome-extension-manager"
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

  local gext_cmd=""
  if command -v gext >/dev/null 2>&1; then
    gext_cmd="gext"
  elif [[ -x "$HOME/.local/bin/gext" ]]; then
    gext_cmd="$HOME/.local/bin/gext"
  fi
  if [[ -z "$gext_cmd" && "$SKIP_PACKAGES" -eq 0 ]]; then
    log "gext missing. Installing gnome-extensions-cli with pip (user install)..."
    if [[ "$PKG_KIND" == "arch" ]]; then
      install_packages "gnome-extensions-cli-deps" python-pip || true
    else
      install_packages "gnome-extensions-cli-deps" python3-pip || true
    fi
    run_cmd_soft "python3 -m pip install --user --upgrade gnome-extensions-cli" || true
    if command -v gext >/dev/null 2>&1; then
      gext_cmd="gext"
    elif [[ -x "$HOME/.local/bin/gext" ]]; then
      gext_cmd="$HOME/.local/bin/gext"
    fi
  fi

  local extension_dir="$HOME/.local/share/gnome-shell/extensions"
  local uuid
  local failed_count=0
  for uuid in "${uuids[@]}"; do
    local installed=0

    # Primary path: GNOME Shell D-Bus API install by UUID.
    if command -v gdbus >/dev/null 2>&1 && is_gnome_session; then
      run_cmd_soft "gdbus call --session --dest org.gnome.Shell.Extensions --object-path /org/gnome/Shell/Extensions --method org.gnome.Shell.Extensions.InstallRemoteExtension \"$uuid\"" || true
      if [[ "$DRY_RUN" -eq 1 ]]; then
        installed=1
      else
        local tries=0
        while [[ "$tries" -lt 20 ]]; do
          if gnome-extensions info "$uuid" >/dev/null 2>&1; then
            installed=1
            break
          fi
          sleep 1
          tries=$((tries + 1))
        done
      fi
    fi

    # Fallback path: gext if D-Bus install didn't register extension.
    if [[ "$installed" -eq 0 && -n "$gext_cmd" ]]; then
      if run_cmd_soft "\"$gext_cmd\" --filesystem install \"$uuid\""; then
        installed=1
      elif run_cmd_soft "\"$gext_cmd\" install \"$uuid\""; then
        installed=1
      fi
    fi

    if [[ "$DRY_RUN" -eq 0 ]]; then
      if gnome-extensions info "$uuid" >/dev/null 2>&1; then
        installed=1
      elif gnome-extensions list | grep -qx "$uuid"; then
        installed=1
      elif [[ -d "$extension_dir/$uuid" ]]; then
        installed=1
      fi
    fi

    if [[ "$DRY_RUN" -eq 0 && "$installed" -eq 0 ]]; then
      warn "Failed to install extension: $uuid"
      record_failed "gnome-extension:$uuid"
      failed_count=$((failed_count + 1))
      continue
    fi

    run_cmd_soft "gnome-extensions enable \"$uuid\"" || true
  done

  if [[ "$failed_count" -gt 0 ]]; then
    warn "$failed_count extension(s) could not be installed."
  fi

  record_completed "gnome-extensions:bundle"
}

configure_tophat_defaults() {
  local schema_dir="$HOME/.local/share/gnome-shell/extensions/tophat@fflewddur.github.io/schemas"
  local schema="org.gnome.shell.extensions.tophat"

  if [[ ! -d "$schema_dir" ]]; then
    warn "TopHat schema directory not found; skipping TopHat defaults."
    return 1
  fi

  local keys
  if ! keys="$(gsettings --schemadir "$schema_dir" list-keys "$schema" 2>/dev/null)"; then
    warn "TopHat schema not readable; skipping TopHat defaults."
    return 1
  fi

  if echo "$keys" | grep -qx "position-in-panel"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" position-in-panel 'left'" || true
  fi
  if echo "$keys" | grep -qx "cpu-display"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" cpu-display 'numeric'" || true
  fi
  if echo "$keys" | grep -qx "mem-display"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" mem-display 'numeric'" || true
  fi
  if echo "$keys" | grep -qx "mem-abs-units"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" mem-abs-units true" || true
  fi
  if echo "$keys" | grep -qx "show-disk"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" show-disk false" || true
  fi
  if echo "$keys" | grep -qx "show-fs"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" show-fs false" || true
  fi

  record_completed "gnome:tophat-defaults"
  return 0
}

configure_blur_my_shell_defaults() {
  local schema_dir="$HOME/.local/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas"
  local schema="org.gnome.shell.extensions.blur-my-shell.applications"

  if [[ ! -d "$schema_dir" ]]; then
    warn "Blur My Shell schema directory not found; skipping Blur My Shell defaults."
    return 1
  fi

  local keys
  if ! keys="$(gsettings --schemadir "$schema_dir" list-keys "$schema" 2>/dev/null)"; then
    warn "Blur My Shell schema not readable; skipping Blur My Shell defaults."
    return 1
  fi

  if echo "$keys" | grep -qx "blur"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" blur true" || true
  fi
  if echo "$keys" | grep -qx "enable-all"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" enable-all false" || true
  fi
  if echo "$keys" | grep -qx "whitelist"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" whitelist \"['kitty', 'org.gnome.Nautilus']\"" || true
  fi
  if echo "$keys" | grep -qx "dynamic-opacity"; then
    run_cmd_soft "gsettings --schemadir \"$schema_dir\" set \"$schema\" dynamic-opacity false" || true
  fi

  record_completed "gnome:blur-my-shell-defaults"
  return 0
}

set_default_fish_shell_if_available() {
  local fish_path
  fish_path="$(command -v fish || true)"
  if [[ -z "$fish_path" || ! -x "$fish_path" ]]; then
    warn "fish is not installed; skipping default shell change."
    return 0
  fi

  local current_shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7 || true)"
  if [[ "$current_shell" == "$fish_path" ]]; then
    log "Fish is already the default shell for $USER."
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

ensure_rust_build_deps() {
  if [[ "$RUST_BUILD_DEPS_READY" -eq 1 ]]; then
    return 0
  fi
  if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
    return 0
  fi

  if [[ "$PKG_KIND" == "fedora" ]]; then
    install_packages "terminal-rust-deps" openssl-devel pkgconf-pkg-config gcc make || true
  elif [[ "$PKG_KIND" == "arch" ]]; then
    install_packages "terminal-rust-deps" openssl pkgconf base-devel || true
  fi
  RUST_BUILD_DEPS_READY=1
}

ensure_cargo_binary_on_path() {
  local bin="$1"
  if command -v "$bin" >/dev/null 2>&1; then
    return 0
  fi
  if [[ -x "$HOME/.cargo/bin/$bin" ]]; then
    run_cmd "mkdir -p \"$HOME/.local/bin\""
    run_cmd "ln -sf \"$HOME/.cargo/bin/$bin\" \"$HOME/.local/bin/$bin\""
  fi
  command -v "$bin" >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/$bin" ]] || [[ -x "$HOME/.cargo/bin/$bin" ]]
}

ensure_cargo_update_available() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN] Would ensure cargo-update is available"
    return 0
  fi

  if ensure_cargo_binary_on_path "cargo-install-update"; then
    return 0
  fi
  if ! command -v cargo >/dev/null 2>&1; then
    warn "cargo not found; cannot install cargo-update."
    return 1
  fi

  ensure_rust_build_deps
  run_cmd "cargo install cargo-update"
  ensure_cargo_binary_on_path "cargo-install-update"
}

ensure_runin_available() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN] Would ensure runin is available"
    return 0
  fi

  ensure_fd_available || true
  if ensure_cargo_binary_on_path "runin"; then
    return 0
  fi
  if ! command -v cargo >/dev/null 2>&1; then
    warn "cargo not found; cannot install runin."
    return 1
  fi

  ensure_rust_build_deps
  run_cmd "cargo install runin"
  ensure_fd_available || true
  ensure_cargo_binary_on_path "runin"
}

ensure_fd_available() {
  if command -v fd >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$SKIP_PACKAGES" -eq 0 ]]; then
    if [[ "$PKG_KIND" == "fedora" ]]; then
      install_packages "terminal-fd" fd-find || true
    elif [[ "$PKG_KIND" == "arch" ]]; then
      install_packages "terminal-fd" fd || true
    fi
  fi

  if command -v fd >/dev/null 2>&1; then
    return 0
  fi

  if command -v fdfind >/dev/null 2>&1; then
    run_cmd "mkdir -p \"$HOME/.local/bin\""
    run_cmd "ln -sf \"$(command -v fdfind)\" \"$HOME/.local/bin/fd\""
  fi

  command -v fd >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/fd" ]]
}

ensure_starship_available() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN] Would ensure starship is available"
    return 0
  fi

  if command -v starship >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    warn "curl is required to install starship via official installer."
    return 1
  fi

  run_cmd "mkdir -p \"$HOME/.local/bin\""
  run_cmd "curl -sS https://starship.rs/install.sh | sh -s -- -y -b \"$HOME/.local/bin\""

  if command -v starship >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/starship" ]]; then
    record_completed "terminal:starship-installed"
    return 0
  fi

  warn "starship installation did not produce a runnable binary."
  return 1
}

is_gnome_session() {
  [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] || [[ "${DESKTOP_SESSION:-}" == *gnome* ]]
}

set_gnome_wallpaper() {
  local src="$HOME/Pictures/wallpapers/background"
  local schema="org.gnome.desktop.background"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    local uri="file://$src"
    set_gsettings_safe "$schema" "picture-uri" "\"$uri\""
    set_gsettings_safe "$schema" "picture-uri-dark" "\"$uri\""
    return 0
  fi

  if [[ ! -f "$src" ]]; then
    warn "Wallpaper file not found at $src"
    return 1
  fi

  local uri="file://$src"
  set_gsettings_safe "$schema" "picture-uri" "\"$uri\""
  set_gsettings_safe "$schema" "picture-uri-dark" "\"$uri\""
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
  if [[ "$PKG_KIND" == "fedora" ]]; then
    install_packages "terminal" fish kitty fastfetch fzf btop cargo fd-find || true
  else
    install_packages "terminal" fish kitty fastfetch fzf btop cargo fd || true
  fi

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
    if ! ensure_cargo_update_available; then
      record_failed "terminal:cargo-update"
    fi
  fi

  if confirm_action "Install runin (cargo install runin)"; then
    if ! ensure_runin_available; then
      record_failed "terminal:runin"
    fi
  fi

  if ! ensure_starship_available; then
    record_failed "terminal:starship"
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

module_flatpaks() {
  print_section "Module: flatpaks"
  install_flatpak_bundle || true
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

module_gnome_core() {
  print_section "Module: gnome-core"
  install_packages "gnome-core" gnome-tweaks gnome-extensions-app || true

  if ! is_gnome_session; then
    warn "GNOME session not detected. GNOME-specific actions may fail."
  fi

  if confirm_action "Apply GNOME keybindings/shortcuts from installer"; then
    apply_gnome_shortcuts_from_installer || true
  fi

  if confirm_action "Set GNOME wallpaper to ~/Pictures/wallpapers/background"; then
    set_gnome_wallpaper || true
  fi
}

module_gnome_extensions() {
  print_section "Module: gnome-extensions"
  if ! is_gnome_session; then
    warn "GNOME session not detected. Extension install/default actions may fail."
  fi

  if confirm_action "Install GNOME Extension Manager (Flatpak)"; then
    install_gnome_extension_manager_flatpak || true
  fi

  if confirm_action "Install GNOME extensions from Scripts/installer/data/gnome_extensions.txt"; then
    install_gnome_extensions_bundle || true
  fi

  if confirm_action "Configure TopHat defaults (left panel, CPU %, RAM GB, hide disk)"; then
    configure_tophat_defaults || true
  fi

  if confirm_action "Configure Blur My Shell defaults (Kitty/Nautilus blur, no opaque focused window)"; then
    configure_blur_my_shell_defaults || true
  fi
}

module_gnome() {
  warn "Module 'gnome' is a legacy alias. Running gnome-core and gnome-extensions."
  module_gnome_core
  module_gnome_extensions
}
