#!/usr/bin/env bash
set -euo pipefail

CURRENT_USERNAME="developer"
SCRIPT_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
SYSTEM_NIX="$REPO_ROOT/modules/core/system.nix"
HOME_DEFAULT_NIX="$REPO_ROOT/modules/home/default.nix"
HYPR_EXEC_ONCE="$REPO_ROOT/modules/home/hyprland/exec-once.nix"
HYPR_BINDS="$REPO_ROOT/modules/home/hyprland/binds.nix"
STEAM_NIX="$REPO_ROOT/modules/core/steam.nix"

if [[ ! -f "$REPO_ROOT/flake.nix" ]]; then
  echo "[ERROR] Please run this script from inside the nixos-config repository" >&2
  exit 1
fi

if command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
  GREEN=$(tput setaf 2)
  CYAN=$(tput setaf 6)
  YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1)
else
  BOLD=""
  RESET=""
  GREEN=""
  CYAN=""
  YELLOW=""
  RED=""
fi

log() {
  local level="$1"
  local color="$2"
  local message="$3"
  printf '%s[%s]%s %s\n' "$color" "$level" "$RESET" "$message"
}

log_info() { log "INFO" "$CYAN" "$1"; }
log_success() { log "OK" "$GREEN" "$1"; }
log_warn() { log "WARN" "$YELLOW" "$1"; }
log_error() { log "ERROR" "$RED" "$1"; }

ensure_whiptail() {
  if command -v whiptail >/dev/null 2>&1; then
    return
  fi

  if [[ -n "${IN_DEV_INSTALL_WIZARD-}" ]]; then
    log_error "whiptail is required but could not be installed via nix-shell"
    exit 1
  fi

  log_info "whiptail not found. attempting to spawn temporary nix-shell with newt"
  IN_DEV_INSTALL_WIZARD=1 nix-shell -p newt --run "bash '$0'"
  exit $?
}

require_clean_repo() {
  if ! git -C "$REPO_ROOT" diff --quiet --ignore-submodules HEAD --; then
    log_warn "Working tree is not clean. The wizard will modify tracked files."
    if ! whiptail --yesno "Proceed even though the working tree has changes?" 9 60 --title "Dirty working tree"; then
      exit 1
    fi
  fi
}

select_host() {
  local hosts=()
  local default=""
  while IFS= read -r -d '' path; do
    local host
    host=$(basename "$(dirname "$path")")
    hosts+=("$host" "$host configuration" "OFF")
    if [[ "$host" == "desktop" ]]; then
      default="$host"
    fi
  done < <(find "$REPO_ROOT/hosts" -maxdepth 2 -name default.nix -print0 | sort -z)

  if [[ ${#hosts[@]} -eq 0 ]]; then
    log_error "No hosts found under hosts/."
    exit 1
  fi

  if [[ -n "$default" ]]; then
    for ((i=2; i<${#hosts[@]}; i+=3)); do
      if [[ "${hosts[i-2]}" == "$default" ]]; then
        hosts[i]="ON"
      fi
    done
  else
    hosts[2]="ON"
  fi

  whiptail --radiolist "Select the host to build" 18 70 8 "${hosts[@]}" 3>&1 1>&2 2>&3
}

prompt_username() {
  local username
  while true; do
    username=$(whiptail --inputbox "System username" 9 60 "$CURRENT_USERNAME" --title "Username" 3>&1 1>&2 2>&3) || exit 1
    if [[ ! $username =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
      whiptail --msgbox "Invalid username: $username" 9 50 --title "Error"
      continue
    fi
    if whiptail --yesno "Use '$username' as the system user?" 9 60 --title "Confirm username"; then
      printf '%s' "$username"
      return
    fi
  done
}

prompt_dev_bundles() {
  local selection
  selection=$(whiptail --checklist "Select development tool bundles" 20 78 10 \
    base "Essential CLI tooling" ON \
    web "JavaScript/TypeScript toolchain" ON \
    python "Python & data tooling" ON \
    cloud "Containers & cloud CLIs" OFF \
    ai "AI assistants and LLM tooling" ON \
    ops "Observability & testing" OFF \
    3>&1 1>&2 2>&3) || exit 1
  printf '%s' "$selection"
}

declare -A DEV_BUNDLES
DEV_BUNDLES[base]="bat fd fzf ripgrep jq just direnv nixpkgs-fmt treefmt"
DEV_BUNDLES[web]="nodejs_20 nodePackages_latest.pnpm yarn typescript deno"
DEV_BUNDLES[python]="python311Full poetry pipx ruff"
DEV_BUNDLES[cloud]="docker docker-compose kubectl kubernetes-helm awscli2 terraform ansible"
DEV_BUNDLES[ai]="aider-chat codex whisper-cpp"
DEV_BUNDLES[ops]="btop htop iotop hyperfine"

ensure_package() {
  local pkg="$1"
  if grep -Fq "    $pkg" "$SYSTEM_NIX"; then
    return
  fi
  sed -i "/environment.systemPackages = with pkgs; \[/a\    $pkg" "$SYSTEM_NIX"
  log_info "Added package '$pkg' to modules/core/system.nix"
}

apply_dev_bundles() {
  local selection="$1"
  local tokens=()
  read -r -a tokens <<< "${selection//\"/}"
  if [[ ${#tokens[@]} -eq 0 ]]; then
    log_warn "No development bundles selected."
    return
  fi
  log_info "Applying development bundles: ${tokens[*]}"
  for token in "${tokens[@]}"; do
    if [[ -z "${DEV_BUNDLES[$token]-}" ]]; then
      log_warn "Unknown bundle '$token' skipped"
      continue
    fi
    for pkg in ${DEV_BUNDLES[$token]}; do
      ensure_package "$pkg"
    done
  done
}

ensure_line_present() {
  local file="$1"
  local expected="$2"
  if grep -Fxq "    $expected" "$file"; then
    return
  fi
  sed -i "s|^    # $expected|    $expected|" "$file"
  if ! grep -Fxq "    $expected" "$file"; then
    log_warn "Could not ensure line '$expected' in $(basename "$file")"
  fi
}

restore_vicinae_binds() {
  if grep -Fq "rofi -show drun" "$HYPR_BINDS"; then
    sed -i "s|rofi -show drun || pkill rofi|vicinae vicinae://toggle|" "$HYPR_BINDS"
  fi
  if ! grep -Fq "vicinae vicinae://toggle" "$HYPR_BINDS"; then
    sed -i "/ghostty --gtk-single-instance=true/a\      \"\\$mainMod, D, exec, vicinae vicinae://toggle\"" "$HYPR_BINDS"
  fi
  if grep -Fq "cliphist list" "$HYPR_BINDS"; then
    sed -i "s|cliphist list .*|vicinae vicinae://extensions/vicinae/clipboard/history|" "$HYPR_BINDS"
  fi
  if ! grep -Fq "vicinae vicinae://extensions/vicinae/clipboard/history" "$HYPR_BINDS"; then
    sed -i "/vicinae vicinae://toggle/a\      \"\\$mainMod, V, exec, vicinae vicinae://extensions/vicinae/clipboard/history\"" "$HYPR_BINDS"
  fi
}

enable_cyberpunk_stack() {
  ensure_line_present "$HOME_DEFAULT_NIX" "./aseprite/aseprite.nix           # pixel art editor"
  ensure_line_present "$HOME_DEFAULT_NIX" "./vicinae/vicinae.nix             # launcher"
  ensure_line_present "$HYPR_EXEC_ONCE" '"vicinae server &"'
  restore_vicinae_binds
  if grep -Fq "enable = false;" "$STEAM_NIX"; then
    sed -i "s/enable = false;/enable = true;/" "$STEAM_NIX"
    log_info "Enabled Steam module"
  fi
}

copy_hardware_config() {
  local host="$1"
  local src="/etc/nixos/hardware-configuration.nix"
  local dest="$REPO_ROOT/hosts/$host/hardware-configuration.nix"
  if ! whiptail --yesno "Copy $src into hosts/$host/?" 9 70 --title "Hardware configuration"; then
    return
  fi
  if [[ ! -f "$src" ]]; then
    log_warn "Hardware configuration not found at $src"
    return
  fi
  if install -Dm0644 "$src" "$dest"; then
    log_success "Copied hardware configuration to hosts/$host/"
  else
    log_error "Failed to copy hardware configuration. Try re-running as root."
  fi
}

update_username() {
  local new_username="$1"
  if [[ "$new_username" == "$CURRENT_USERNAME" ]]; then
    return
  fi
  log_info "Updating configuration to use username '$new_username'"
  find "$REPO_ROOT/hosts" "$REPO_ROOT/modules" "$REPO_ROOT/flake.nix" -type f -print0 |
    xargs -0 sed -i "s/${CURRENT_USERNAME}/${new_username}/g"
}

run_rebuild() {
  local host="$1"
  if ! whiptail --yesno "Run 'nixos-rebuild switch --flake .#$host'?" 9 70 --title "Build system"; then
    return
  fi
  log_info "Starting nixos-rebuild for host '$host'"
  if nixos-rebuild switch --flake "$REPO_ROOT#$host"; then
    log_success "nixos-rebuild completed successfully"
  else
    log_error "nixos-rebuild failed"
  fi
}

main() {
  ensure_whiptail
  require_clean_repo

  whiptail --title "NixOS Developer Installer" --msgbox "Welcome to the cyberpunk developer setup wizard.\n\nThe wizard will help you configure hosts, usernames, development packages (including Codex and Aider), and ensure all themed features remain enabled." 13 70

  local host
  host=$(select_host) || exit 1

  local username
  username=$(prompt_username)

  local bundles
  bundles=$(prompt_dev_bundles)

  update_username "$username"
  apply_dev_bundles "$bundles"
  enable_cyberpunk_stack
  copy_hardware_config "$host"

  whiptail --title "Summary" --msgbox "Host: $host\nUser: $username\nBundles: ${bundles//\"/}" 10 60

  run_rebuild "$host"
}

main "$@"
