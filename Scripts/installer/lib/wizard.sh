#!/usr/bin/env bash

module_selection_wizard() {
  while true; do
    print_line
    log "$(style '1;36' "Module Selection")"
    print_line
    log "Choose each module one by one."
    log "Press Enter to accept the default."
    log "$(style '0;36' "Defaults: core modules enabled (base, gnome-core, gnome-extensions, terminal, media).")"

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
  log "  modules: $(style '1;34' "$MODULES_CSV")"
  if ! confirm "Start now with this plan?"; then
    log "Aborted by user."
    exit 0
  fi
  AUTO_ACCEPT_POST_PLAN=1
}
