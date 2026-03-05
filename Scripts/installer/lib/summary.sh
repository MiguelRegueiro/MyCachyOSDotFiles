#!/usr/bin/env bash

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
  if [[ "$FISH_SHELL_CHANGED" -eq 1 ]]; then
    log "$(style '1;36' "Note: default shell changed to fish.")"
    log "Open a new terminal session (or log out/in) for the change to fully apply."
    log ""
  fi

  log "$(style '1;36' "Installer finished.")"
  log "User: ${USER:-unknown}"
  log "Home: ${HOME:-unknown}"
  log "Log file: $LOG_FILE"
  log "Backup dir: $BACKUP_DIR"
}

pause_before_exit_if_guided() {
  if [[ "$WIZARD_USED" -eq 1 && "$ASSUME_YES" -eq 0 && -t 0 ]]; then
    echo
    read -r -p "Press Enter to close..." _
  fi
}
