#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$HOME/.config-backups/mycachyosdotfiles_$TIMESTAMP"
LOG_FILE="$REPO_ROOT/install.log"

ASSUME_YES=0
DRY_RUN=0
SKIP_PACKAGES=0
MODULES_CSV=""
ASK_EACH_CMD=0
PRESET=""
ASK_MODULE_CONFIRM=1
WIZARD_USED=0
AUTO_ACCEPT_POST_PLAN=0
INSTALL_FLATPAKS=0

DISTRO_ID=""
DISTRO_LIKE=""
PKG_KIND=""

MODULES=(
  "base"
  "gnome"
  "terminal"
  "media"
  "language"
  "virtualization"
)

USE_COLOR=0

FLATPAK_APPS=(
  "app.zen_browser.zen"
  "com.discordapp.Discord"
  "com.github.dynobo.normcap"
  "com.github.iwalton3.jellyfin-media-player"
  "com.github.fabiocolacio.marker"
  "com.mattjakeman.ExtensionManager"
  "com.rtosta.zapzap"
  "net.mkiol.SpeechNote"
  "net.ankiweb.Anki"
  "org.kde.kate"
  "org.kde.kdenlive"
  "org.localsend.localsend_app"
  "org.qbittorrent.qBittorrent"
  "nl.hjdskes.gcolor3"
  "org.gimp.GIMP"
  "cn.xfangfang.wiliwili"
  "com.obsproject.Studio"
)

init_ui() {
  if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    USE_COLOR=1
  fi
}

c() {
  local code="$1"
  if [[ "$USE_COLOR" -eq 1 ]]; then
    printf '\033[%sm' "$code"
  fi
}

style() {
  local code="$1"
  shift
  printf '%s%s%s' "$(c "$code")" "$*" "$(c 0)"
}

COMPLETED_ACTIONS=()
SKIPPED_ACTIONS=()
FAILED_ACTIONS=()
SKIPPED_MODULES=()
COMPLETED_MODULES=()

record_completed() {
  COMPLETED_ACTIONS+=("$1")
}

record_skipped() {
  SKIPPED_ACTIONS+=("$1")
}

record_failed() {
  FAILED_ACTIONS+=("$1")
}

record_module_completed() {
  COMPLETED_MODULES+=("$1")
}

record_module_skipped() {
  SKIPPED_MODULES+=("$1")
}

join_csv() {
  local IFS=","
  printf '%s' "$*"
}

is_core_module() {
  case "$1" in
    base|gnome|terminal|media) return 0 ;;
    *) return 1 ;;
  esac
}

module_description() {
  case "$1" in
    base) echo "icons, wallpapers, fonts, base directories" ;;
    gnome) echo "GNOME tweaks package, shortcuts script, wallpaper, extensions from Scripts/gnome_extensions.txt" ;;
    terminal) echo "fish/kitty/starship/fastfetch setup + configs" ;;
    media) echo "mpv stack packages + mpv config" ;;
    language) echo "ibus + anthy input setup" ;;
    virtualization) echo "libvirt/qemu stack and optional service setup" ;;
    *) echo "custom module" ;;
  esac
}

print_line() {
  printf '%s\n' "============================================================"
}

print_banner() {
  print_line | tee -a "$LOG_FILE"
  printf '%s\n' "$(style '1;36' ' MyCachyOSDotFiles Installer ')" | tee -a "$LOG_FILE"
  print_line | tee -a "$LOG_FILE"
}

print_section() {
  local title="$1"
  print_line | tee -a "$LOG_FILE"
  printf '%s\n' "$(style '1;35' "[SECTION] $title")" | tee -a "$LOG_FILE"
  print_line | tee -a "$LOG_FILE"
}

log() {
  local msg="$*"
  printf '%s\n' "$msg"
  # Save plain text in log file (strip ANSI escapes from styled lines).
  printf '%s\n' "$msg" | sed -E $'s/\x1B\\[[0-9;]*[[:alpha:]]//g' >>"$LOG_FILE"
}

warn() {
  log "$(style '1;33' "[WARN] $*")"
}

die() {
  log "$(style '1;31' "[ERROR] $*")"
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./Scripts/install.sh [options]

Options:
  --yes                 Non-interactive mode (accept prompts)
  --dry-run             Show actions without changing anything
  --skip-packages       Do not install packages
  --modules=a,b,c       Run only selected modules
  --preset=name         Use preset modules: core, full
  --command-prompts     Ask before each underlying command (verbose mode)
  --no-command-prompts  Alias for default behavior (no per-command prompts)
  --help                Show this help

Modules:
  base, gnome, terminal, media, language, virtualization
EOF
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
    gnome) echo "GNOME keybinding script, wallpaper settings" ;;
    terminal) echo "copy configs, chsh, cargo install" ;;
    media) echo "copy mpv config" ;;
    language) echo "start ibus daemon" ;;
    virtualization) echo "module selection and confirmations" ;;
    *) echo "varies" ;;
  esac
}

contains_module() {
  local item="$1"
  local m
  for m in "${MODULES[@]}"; do
    [[ "$m" == "$item" ]] && return 0
  done
  return 1
}

selected_modules() {
  if [[ -z "$MODULES_CSV" ]]; then
    printf '%s\n' "${MODULES[@]}"
    return 0
  fi

  local parsed=()
  local item
  IFS=',' read -r -a parsed <<<"$MODULES_CSV"
  for item in "${parsed[@]}"; do
    item="${item,,}"
    contains_module "$item" || die "Unknown module: $item"
    printf '%s\n' "$item"
  done
}

confirm() {
  local prompt="$1"
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    log "$(style '1;32' "[AUTO-YES] $prompt")"
    return 0
  fi

  local reply norm
  while true; do
    read -r -p "$prompt [y/N]: " reply || true
    norm="${reply,,}"
    case "$norm" in
      y|yes|yy) return 0 ;;
      n|no|nn|"") return 1 ;;
      *)
        log "$(style '1;33' "Please answer with y/yes or n/no.")"
        ;;
    esac
  done
}

confirm_with_default() {
  local prompt="$1"
  local default_yes="$2"

  if [[ "$ASSUME_YES" -eq 1 ]]; then
    log "$(style '1;32' "[AUTO-YES] $prompt")"
    return 0
  fi

  local reply norm suffix
  if [[ "$default_yes" -eq 1 ]]; then
    suffix="[Y/n]"
  else
    suffix="[y/N]"
  fi

  while true; do
    read -r -p "$prompt $suffix: " reply || true
    norm="${reply,,}"
    case "$norm" in
      y|yes|yy) return 0 ;;
      n|no|nn) return 1 ;;
      "")
        if [[ "$default_yes" -eq 1 ]]; then
          return 0
        fi
        return 1
        ;;
      *)
        log "$(style '1;33' "Please answer with y/yes or n/no.")"
        ;;
    esac
  done
}

confirm_action() {
  local action="$1"
  if [[ "$AUTO_ACCEPT_POST_PLAN" -eq 1 ]]; then
    log "$(style '1;32' "[AUTO] Apply action: $action")"
    return 0
  fi
  if confirm "Apply action: $action?"; then
    return 0
  fi
  record_skipped "action:$action"
  return 1
}

module_selection_wizard() {
  while true; do
    print_line
    log "$(style '1;36' "Module Selection")"
    print_line
    log "Choose each module one by one."
    log "Press Enter to accept the default."
    log "$(style '0;36' "Defaults: core modules enabled (base, gnome, terminal, media).")"

    local selected=()
    local i idx mod default_yes
    for (( i=0; i<${#MODULES[@]}; i++ )); do
      idx=$((i + 1))
      mod="${MODULES[$i]}"
      default_yes=0
      if is_core_module "$mod"; then
        default_yes=1
      fi

      if confirm_with_default "[$idx/${#MODULES[@]}] Enable '$mod' ($(module_description "$mod"))?" "$default_yes"; then
        selected+=("$mod")
      fi
    done

    if [[ "${#selected[@]}" -eq 0 ]]; then
      warn "At least one module must be selected."
      continue
    fi

    MODULES_CSV="$(join_csv "${selected[@]}")"
    log "Selected modules: $(style '1;34' "$MODULES_CSV")"
    return 0
  done
}

interactive_wizard() {
  WIZARD_USED=1
  ASK_MODULE_CONFIRM=0

  print_line
  log "$(style '1;36' "Guided Setup")"
  print_line
  log "This wizard will help you choose what to install."

  if confirm "Run in dry-run mode (preview only, no changes)?"; then
    DRY_RUN=1
  fi

  if ! confirm_with_default "Allow system package installation when needed? (sudo)" 1; then
    SKIP_PACKAGES=1
    log "$(style '1;33' "Package install disabled. User-level config actions will still run.")"
  fi

  if confirm_with_default "Install curated Flatpak app bundle?" 0; then
    INSTALL_FLATPAKS=1
  fi

  module_selection_wizard

  print_line
  log "$(style '1;36' "Wizard plan:")"
  log "  dry-run: $(style '1;34' "$([[ "$DRY_RUN" -eq 1 ]] && echo yes || echo no)")"
  log "  install packages: $(style '1;34' "$([[ "$SKIP_PACKAGES" -eq 1 ]] && echo no || echo yes)")"
  log "  install flatpak apps: $(style '1;34' "$([[ "$INSTALL_FLATPAKS" -eq 1 ]] && echo yes || echo no)")"
  if [[ "$ASK_EACH_CMD" -eq 1 ]]; then
    log "  command confirmations: $(style '1;34' "yes (set via flag)")"
  else
    log "  command confirmations: $(style '1;34' "no")"
  fi
  log "  modules: $(style '1;34' "$MODULES_CSV")"
  if ! confirm "Start now with this plan?"; then
    log "Aborted by user."
    exit 0
  fi
  AUTO_ACCEPT_POST_PLAN=1
}

confirm_cmd() {
  local scope="$1"
  local cmd="$2"
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    log "[AUTO-YES][$scope] $cmd"
    return 0
  fi

  print_line
  printf 'About to run (%s):\n' "$scope"
  printf '  %s\n' "$cmd"
  local reply
  read -r -p "Proceed? [y/N]: " reply || true
  case "${reply,,}" in
    y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

run_cmd() {
  local cmd="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN] $cmd"
    record_completed "dry-run:$cmd"
    return 0
  fi

  if [[ "$ASSUME_YES" -eq 0 && "$ASK_EACH_CMD" -eq 1 ]]; then
    if ! confirm_cmd "user" "$cmd"; then
      log "[SKIP] $cmd"
      record_skipped "cmd:$cmd"
      return 0
    fi
  fi

  log "[RUN] $cmd"
  if bash -c "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
    record_completed "cmd:$cmd"
    return 0
  fi
  record_failed "cmd:$cmd"
  warn "Command failed: $cmd"
  return 1
}

run_root_cmd() {
  local cmd="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN][ROOT] $cmd"
    record_completed "dry-run-root:$cmd"
    return 0
  fi

  if [[ "$ASSUME_YES" -eq 0 && "$ASK_EACH_CMD" -eq 1 ]]; then
    if ! confirm_cmd "root" "$cmd"; then
      log "[SKIP][ROOT] $cmd"
      record_skipped "root-cmd:$cmd"
      return 0
    fi
  fi

  if [[ "$EUID" -eq 0 ]]; then
    log "[RUN][ROOT] $cmd"
    if bash -c "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
      record_completed "root-cmd:$cmd"
      return 0
    fi
    record_failed "root-cmd:$cmd"
    warn "Root command failed: $cmd"
    return 1
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    warn "sudo not found; skipping root command: $cmd"
    record_failed "root-cmd(no-sudo):$cmd"
    return 1
  fi

  log "[RUN][sudo] $cmd"
  if sudo bash -c "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
    record_completed "root-cmd:$cmd"
    return 0
  fi
  record_failed "root-cmd:$cmd"
  warn "Root command failed: $cmd"
  return 1
}

backup_path() {
  local target="$1"
  if [[ ! -e "$target" ]]; then
    return 0
  fi

  local rel="${target/#$HOME\//}"
  local dst="$BACKUP_DIR/$rel"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN] Would back up $target -> $dst"
    return 0
  fi

  local parent
  parent="$(dirname "$dst")"
  run_cmd "mkdir -p \"$parent\""
  run_cmd "cp -a \"$target\" \"$dst\""
  log "Backed up $target -> $dst"
}

copy_dir_contents() {
  local src="$1"
  local dst="$2"
  [[ -d "$src" ]] || die "Missing source directory: $src"

  run_cmd "mkdir -p \"$dst\""
  if command -v rsync >/dev/null 2>&1; then
    run_cmd "rsync -a \"$src\"/ \"$dst\"/"
  else
    run_cmd "cp -a \"$src\"/. \"$dst\"/"
  fi
}

copy_tree_as_dir() {
  local src="$1"
  local dst="$2"
  [[ -d "$src" ]] || die "Missing source directory: $src"
  backup_path "$dst"
  run_cmd "mkdir -p \"$(dirname "$dst")\""
  run_cmd "rm -rf \"$dst\""
  run_cmd "cp -a \"$src\" \"$dst\""
}

copy_file_to_dir() {
  local src="$1"
  local dst_dir="$2"
  [[ -f "$src" ]] || die "Missing source file: $src"
  local dst="$dst_dir/$(basename "$src")"
  backup_path "$dst"
  run_cmd "mkdir -p \"$dst_dir\""
  run_cmd "cp -a \"$src\" \"$dst\""
}

detect_distro() {
  [[ -r /etc/os-release ]] || die "Cannot read /etc/os-release"
  # shellcheck disable=SC1091
  . /etc/os-release
  DISTRO_ID="${ID:-unknown}"
  DISTRO_LIKE="${ID_LIKE:-}"

  case "$DISTRO_ID" in
    arch|cachyos|manjaro|endeavouros) PKG_KIND="arch" ;;
    fedora) PKG_KIND="fedora" ;;
    *)
      if [[ "$DISTRO_LIKE" == *"arch"* ]]; then
        PKG_KIND="arch"
      elif [[ "$DISTRO_LIKE" == *"fedora"* ]] || [[ "$DISTRO_LIKE" == *"rhel"* ]]; then
        PKG_KIND="fedora"
      else
        PKG_KIND="unknown"
      fi
      ;;
  esac

  log "Detected distro: id=$DISTRO_ID like=$DISTRO_LIKE pkg_kind=$PKG_KIND"
}

install_packages() {
  local module="$1"
  shift
  local pkgs=("$@")
  [[ "${#pkgs[@]}" -gt 0 ]] || return 0

  if [[ "$SKIP_PACKAGES" -eq 1 ]]; then
    log "Skipping package installation for module '$module' (--skip-packages)."
    return 0
  fi

  if [[ "$PKG_KIND" == "unknown" ]]; then
    warn "Unsupported distro for package auto-install. Module '$module' packages skipped."
    return 0
  fi

  print_line
  log "Package install candidate for module '$module':"
  log "  ${pkgs[*]}"
  if [[ "$AUTO_ACCEPT_POST_PLAN" -eq 0 ]]; then
    if ! confirm "Install these packages now?"; then
      log "Skipped package installation for module '$module'."
      record_skipped "packages:$module"
      return 0
    fi
  else
    log "$(style '1;32' "[AUTO] Install packages for module '$module'")"
  fi

  local cmd=""
  if [[ "$PKG_KIND" == "arch" ]]; then
    cmd="pacman -S --needed ${pkgs[*]}"
  else
    cmd="dnf install -y ${pkgs[*]}"
  fi

  if ! run_root_cmd "$cmd"; then
    warn "Package installation failed/skipped for module '$module'."
    record_failed "packages:$module"
    return 1
  fi

  record_completed "packages:$module"
  return 0
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
  local ext_file="$REPO_ROOT/Scripts/gnome_extensions.txt"
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

  if ! command -v gext >/dev/null 2>&1; then
    warn "gext not found. Install 'gnome-extensions-cli' to enable automated extension install."
    record_skipped "gnome-extensions:missing-gext"
    return 0
  fi

  if ! command -v gnome-extensions >/dev/null 2>&1; then
    warn "gnome-extensions command not found; install/enable GNOME Shell tools."
    record_skipped "gnome-extensions:missing-command"
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

ensure_base_dirs() {
  run_cmd "mkdir -p \"$HOME/.config\" \"$HOME/.local/share/icons\" \"$HOME/.local/share/fonts\" \"$HOME/Pictures/wallpapers\""
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

  if confirm_action "Set Fish as default shell (chsh -s /usr/bin/fish)"; then
    if command -v fish >/dev/null 2>&1 && [[ -x /usr/bin/fish ]]; then
      run_cmd "chsh -s /usr/bin/fish"
    else
      warn "fish is not installed at /usr/bin/fish; skipping chsh."
      record_skipped "action:Set Fish as default shell (missing fish binary)"
    fi
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
    run_root_cmd "virsh net-autostart default" || true
    run_root_cmd "virsh net-start default" || true
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

module_gnome() {
  print_section "Module: gnome"
  install_packages "gnome" gnome-tweaks || true

  if ! is_gnome_session; then
    warn "GNOME session not detected. GNOME-specific actions may fail."
  fi

  if confirm_action "Apply GNOME keybindings/shortcuts script"; then
    run_cmd "\"$REPO_ROOT/Scripts/set_window_workspace_shortcuts.sh\""
  fi

  if confirm_action "Set GNOME wallpaper to ~/Pictures/wallpapers/background"; then
    set_gnome_wallpaper || true
  fi

  if confirm_action "Install GNOME extensions from Scripts/gnome_extensions.txt"; then
    install_gnome_extensions_bundle || true
  fi
}

print_summary() {
  local completed_count skipped_count failed_count
  completed_count="${#COMPLETED_ACTIONS[@]}"
  skipped_count="${#SKIPPED_ACTIONS[@]}"
  failed_count="${#FAILED_ACTIONS[@]}"

  print_line
  log "$(style '1;36' "Summary")"
  print_line
  log "$(style '1;34' "Status       | Count")"
  log "completed    | $(style '1;32' "$completed_count")"
  log "skipped      | $(style '1;33' "$skipped_count")"
  if [[ "$failed_count" -gt 0 ]]; then
    log "failed       | $(style '1;31' "$failed_count")"
  else
    log "failed       | $(style '1;32' "$failed_count")"
  fi

  if [[ "${#COMPLETED_MODULES[@]}" -gt 0 ]]; then
    log "Modules done | $(style '1;32' "$(join_csv "${COMPLETED_MODULES[@]}")")"
  fi
  if [[ "${#SKIPPED_MODULES[@]}" -gt 0 ]]; then
    log "Modules skip | $(style '1;33' "$(join_csv "${SKIPPED_MODULES[@]}")")"
    log "Rerun skipped modules:"
    log "  ./Scripts/install.sh --modules=$(join_csv "${SKIPPED_MODULES[@]}")"
  fi

  if [[ "$failed_count" -gt 0 ]]; then
    log "Failed actions (first 5):"
    local i max
    max=$(( failed_count < 5 ? failed_count : 5 ))
    for (( i=0; i<max; i++ )); do
      log "  - ${FAILED_ACTIONS[$i]}"
    done
  fi

  if [[ "$completed_count" -gt 0 ]]; then
    log "Completed actions (first 8):"
    local i max
    max=$(( completed_count < 8 ? completed_count : 8 ))
    for (( i=0; i<max; i++ )); do
      log "  - ${COMPLETED_ACTIONS[$i]}"
    done
  fi

  if [[ "$skipped_count" -gt 0 ]]; then
    log "Skipped actions (first 8):"
    local i max
    max=$(( skipped_count < 8 ? skipped_count : 8 ))
    for (( i=0; i<max; i++ )); do
      log "  - ${SKIPPED_ACTIONS[$i]}"
    done
  fi

  log ""
  log "$(style '1;36' "Installer finished.")"
  log "Log file: $LOG_FILE"
  log "Backup dir: $BACKUP_DIR"
}

pause_before_exit_if_guided() {
  if [[ "$WIZARD_USED" -eq 1 && "$ASSUME_YES" -eq 0 && -t 0 ]]; then
    echo
    read -r -p "Press Enter to close..." _
  fi
}

main() {
  local show_help=0
  init_ui

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes) ASSUME_YES=1 ;;
      --dry-run) DRY_RUN=1 ;;
      --skip-packages) SKIP_PACKAGES=1 ;;
      --modules=*) MODULES_CSV="${1#*=}" ;;
      --preset=*) PRESET="${1#*=}" ;;
      --command-prompts) ASK_EACH_CMD=1 ;;
      --no-command-prompts) ASK_EACH_CMD=0 ;;
      --help|-h) show_help=1 ;;
      *) die "Unknown argument: $1 (use --help)" ;;
    esac
    shift
  done

  if [[ "$show_help" -eq 1 ]]; then
    usage
    exit 0
  fi

  if [[ -n "$PRESET" && -n "$MODULES_CSV" ]]; then
    die "Use either --preset or --modules, not both."
  fi

  case "$PRESET" in
    "") ;;
    core) MODULES_CSV="base,gnome,terminal,media" ;;
    full) MODULES_CSV="" ;;
    *) die "Unknown preset: $PRESET (use core|full)" ;;
  esac

  : >"$LOG_FILE"
  print_banner
  log "MyCachyOSDotFiles installer started at $(date)"
  log "Repo root: $REPO_ROOT"

  detect_distro

  if [[ "$ASSUME_YES" -eq 0 && -z "$MODULES_CSV" && -z "$PRESET" ]]; then
    interactive_wizard
  fi

  local modules_to_run=()
  mapfile -t modules_to_run < <(selected_modules)

  if [[ "$ASSUME_YES" -eq 0 && "$WIZARD_USED" -eq 0 ]]; then
    print_line
    log "Interactive mode: default answer is No."
    if [[ "$ASK_EACH_CMD" -eq 1 ]]; then
      log "Prompt mode: command-level confirmations enabled."
    else
      log "Prompt mode: action-level confirmations (streamlined default)."
    fi
    print_line
    log "Planned modules:"
    local mod
    for mod in "${modules_to_run[@]}"; do
      log "  - $mod: $(module_description "$mod")"
    done
  fi

  if [[ "$WIZARD_USED" -eq 0 ]]; then
    if ! confirm "Proceed with installer setup in repo '$REPO_ROOT'?"; then
      log "Aborted by user."
      exit 0
    fi
  fi

  local selected
  local idx=0
  local total="${#modules_to_run[@]}"
  for selected in "${modules_to_run[@]}"; do
    idx=$((idx + 1))
    print_line
    log "$(style '1;36' "Module [$idx/$total]:") $(style '1;34' "$selected")"
    log "  Scope: $(module_description "$selected")"
    log "  Requires sudo: $(style '1;33' "$(module_sudo_scope "$selected")")"
    log "  No sudo: $(style '1;32' "$(module_user_scope "$selected")")"
    case "$selected" in
      base)
        if [[ "$ASK_MODULE_CONFIRM" -eq 0 ]] || confirm "Run module: base?"; then
          module_base
          record_module_completed "base"
        else
          record_module_skipped "base"
        fi
        ;;
      gnome)
        if [[ "$ASK_MODULE_CONFIRM" -eq 0 ]] || confirm "Run module: gnome?"; then
          module_gnome
          record_module_completed "gnome"
        else
          record_module_skipped "gnome"
        fi
        ;;
      terminal)
        if [[ "$ASK_MODULE_CONFIRM" -eq 0 ]] || confirm "Run module: terminal?"; then
          module_terminal
          record_module_completed "terminal"
        else
          record_module_skipped "terminal"
        fi
        ;;
      media)
        if [[ "$ASK_MODULE_CONFIRM" -eq 0 ]] || confirm "Run module: media?"; then
          module_media
          record_module_completed "media"
        else
          record_module_skipped "media"
        fi
        ;;
      language)
        if [[ "$ASK_MODULE_CONFIRM" -eq 0 ]] || confirm "Run module: language?"; then
          module_language
          record_module_completed "language"
        else
          record_module_skipped "language"
        fi
        ;;
      virtualization)
        if [[ "$ASK_MODULE_CONFIRM" -eq 0 ]] || confirm "Run module: virtualization?"; then
          module_virtualization
          record_module_completed "virtualization"
        else
          record_module_skipped "virtualization"
        fi
        ;;
      *)
        warn "Skipping unknown selected module: $selected"
        ;;
    esac
  done

  if [[ "$WIZARD_USED" -eq 1 ]]; then
    if [[ "$INSTALL_FLATPAKS" -eq 1 ]]; then
      install_flatpak_bundle || true
    fi
  else
    if confirm_with_default "Install curated Flatpak app bundle?" 0; then
      INSTALL_FLATPAKS=1
      install_flatpak_bundle || true
    fi
  fi

  print_summary
  pause_before_exit_if_guided
}

main "$@"
