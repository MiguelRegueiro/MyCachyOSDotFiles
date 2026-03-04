#!/usr/bin/env bash

# Shared state defaults
ASSUME_YES=${ASSUME_YES:-0}
DRY_RUN=${DRY_RUN:-0}
SKIP_PACKAGES=${SKIP_PACKAGES:-0}
MODULES_CSV=${MODULES_CSV:-""}
ASK_EACH_CMD=${ASK_EACH_CMD:-0}
PRESET=${PRESET:-""}
ASK_MODULE_CONFIRM=${ASK_MODULE_CONFIRM:-1}
WIZARD_USED=${WIZARD_USED:-0}
AUTO_ACCEPT_POST_PLAN=${AUTO_ACCEPT_POST_PLAN:-0}
INSTALL_FLATPAKS=${INSTALL_FLATPAKS:-0}
ROOT_ACTIONS_ALLOWED=${ROOT_ACTIONS_ALLOWED:-1}
FISH_SHELL_CHANGED=${FISH_SHELL_CHANGED:-0}

DISTRO_ID=${DISTRO_ID:-""}
DISTRO_LIKE=${DISTRO_LIKE:-""}
PKG_KIND=${PKG_KIND:-""}

USE_COLOR=${USE_COLOR:-0}

MODULES=(
  "base"
  "gnome"
  "terminal"
  "media"
  "language"
  "virtualization"
)

FLATPAK_APPS=()

COMPLETED_ACTIONS=()
SKIPPED_ACTIONS=()
FAILED_ACTIONS=()
SKIPPED_MODULES=()
COMPLETED_MODULES=()

load_flatpak_apps() {
  local list_file="$INSTALLER_ROOT/data/flatpaks.txt"
  if [[ -f "$list_file" ]]; then
    mapfile -t FLATPAK_APPS < <(sed -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' "$list_file" | awk 'NF && $1 !~ /^#/')
  fi
}

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

record_completed() { COMPLETED_ACTIONS+=("$1"); }
record_skipped() { SKIPPED_ACTIONS+=("$1"); }
record_failed() { FAILED_ACTIONS+=("$1"); }
record_module_completed() { COMPLETED_MODULES+=("$1"); }
record_module_skipped() { SKIPPED_MODULES+=("$1"); }

join_csv() {
  local IFS=",";
  printf '%s' "$*"
}

is_core_module() {
  case "$1" in
    base|gnome|terminal|media) return 0 ;;
    *) return 1 ;;
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
  printf '%s\n' "$msg" | sed -E $'s/\x1B\[[0-9;]*[[:alpha:]]//g' >>"$LOG_FILE"
}

warn() { log "$(style '1;33' "[WARN] $*")"; }


die() {
  log "$(style '1;31' "[ERROR] $*")"
  exit 1
}

usage() {
  cat <<'USAGE'
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
USAGE
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
      *) log "$(style '1;33' "Please answer with y/yes or n/no.")" ;;
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
        [[ "$default_yes" -eq 1 ]] && return 0 || return 1
        ;;
      *) log "$(style '1;33' "Please answer with y/yes or n/no.")" ;;
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

confirm_cmd() {
  local scope="$1"
  local cmd="$2"
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    log "$(style '1;32' "[AUTO-YES][$scope] $cmd")"
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
  if [[ "$ROOT_ACTIONS_ALLOWED" -eq 0 ]]; then
    warn "Root actions are disabled for this run; skipping: $cmd"
    return 1
  fi

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

run_root_cmd_soft() {
  local cmd="$1"
  if [[ "$ROOT_ACTIONS_ALLOWED" -eq 0 ]]; then
    warn "Root actions are disabled for this run; skipping: $cmd"
    return 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[DRY-RUN][ROOT] $cmd"
    record_completed "dry-run-root:$cmd"
    return 0
  fi

  if [[ "$EUID" -eq 0 ]]; then
    log "[RUN][ROOT] $cmd"
    if bash -c "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
      record_completed "root-cmd:$cmd"
      return 0
    fi
    warn "Root command failed (continuing): $cmd"
    return 1
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    warn "sudo not found; skipping root command: $cmd"
    return 1
  fi

  log "[RUN][sudo] $cmd"
  if sudo bash -c "$cmd" 2>&1 | tee -a "$LOG_FILE"; then
    record_completed "root-cmd:$cmd"
    return 0
  fi
  warn "Root command failed (continuing): $cmd"
  return 1
}

check_root_cmd() {
  local cmd="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi

  if [[ "$EUID" -eq 0 ]]; then
    bash -c "$cmd" >/dev/null 2>&1
    return $?
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    return 1
  fi

  sudo bash -c "$cmd" >/dev/null 2>&1
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

# Distro / package logic

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

  local pkg
  local failed_pkgs=()
  local installed_count=0
  for pkg in "${pkgs[@]}"; do
    local cmd=""
    if [[ "$PKG_KIND" == "arch" ]]; then
      cmd="pacman -S --needed \"$pkg\""
    else
      cmd="dnf install -y \"$pkg\""
    fi

    if run_root_cmd_soft "$cmd"; then
      installed_count=$((installed_count + 1))
    else
      failed_pkgs+=("$pkg")
    fi
  done

  if [[ "${#failed_pkgs[@]}" -gt 0 ]]; then
    warn "Some packages for module '$module' failed or were unavailable: ${failed_pkgs[*]}"
    if [[ "$installed_count" -gt 0 ]]; then
      record_completed "packages:$module:partial"
    else
      record_failed "packages:$module:none-installed"
    fi
    return 0
  fi

  record_completed "packages:$module"
}

ensure_sudo_ready() {
  if [[ "$DRY_RUN" -eq 1 ]] || [[ "$EUID" -eq 0 ]]; then
    return 0
  fi
  if [[ "$ROOT_ACTIONS_ALLOWED" -eq 0 ]]; then
    return 1
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    die "sudo is required for selected root actions but is not installed."
  fi

  print_line
  log "$(style '1;36' "Privilege check")"
  log "A sudo password prompt may appear once before execution starts."
  if sudo -v; then
    log "$(style '1;32' "Sudo credentials ready.")"
    return 0
  fi

  die "Failed to authenticate with sudo. Re-run with package installation disabled or fix sudo access."
}
