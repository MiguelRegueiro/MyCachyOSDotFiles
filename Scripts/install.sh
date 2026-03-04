#!/usr/bin/env bash

set -euo pipefail

SCRIPTS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPTS_DIR/.." && pwd)"
INSTALLER_ROOT="$SCRIPTS_DIR/installer"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$HOME/.config-backups/mycachyosdotfiles_$TIMESTAMP"
LOG_FILE="$REPO_ROOT/install.log"

# shellcheck source=/dev/null
source "$INSTALLER_ROOT/lib/common.sh"
# shellcheck source=/dev/null
source "$INSTALLER_ROOT/lib/modules.sh"
# shellcheck source=/dev/null
source "$INSTALLER_ROOT/lib/wizard.sh"
# shellcheck source=/dev/null
source "$INSTALLER_ROOT/lib/summary.sh"

main() {
  local show_help=0
  trap stop_sudo_keepalive EXIT INT TERM
  init_ui
  load_flatpak_apps

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

  local requires_root=0
  if [[ "$SKIP_PACKAGES" -eq 0 ]] || [[ "$INSTALL_FLATPAKS" -eq 1 ]]; then
    requires_root=1
  fi
  local mod
  for mod in "${modules_to_run[@]}"; do
    if [[ "$mod" == "virtualization" ]]; then
      requires_root=1
      break
    fi
  done

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

  if [[ "$requires_root" -eq 1 ]]; then
    ensure_sudo_ready
    start_sudo_keepalive
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
