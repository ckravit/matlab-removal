#!/usr/bin/env bash
set -euo pipefail

EXECUTE=false

if [[ "${1:-}" != "" && "${1:-}" != "--execute" ]]; then
  echo "ERROR: Unknown argument: $1"
  echo "Usage: sudo $0 [--execute]"
  exit 1
fi

if [[ "${1:-}" == "--execute" ]]; then
  EXECUTE=true
fi

if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: Run with sudo/root."
  echo "Usage: sudo $0 [--execute]"
  exit 1
fi

run() {
  if [[ "$EXECUTE" == true ]]; then
    echo "RUN: $*"
    "$@"
  else
    echo "DRY-RUN: $*"
  fi
}

remove_path() {
  local path="$1"
  if compgen -G "$path" >/dev/null; then
    while IFS= read -r match; do
      run rm -rf -- "$match"
    done < <(compgen -G "$path")
  else
    echo "SKIP: $path"
  fi
}

echo "MATLAB removal script"
echo "Mode: $([[ "$EXECUTE" == true ]] && echo EXECUTE || echo DRY-RUN)"
echo

# Stop/disable services if present
run systemctl stop matlab-proxy || true
run systemctl disable matlab-proxy || true

# System install locations
remove_path "/usr/local/bin/matlab*"
remove_path "/usr/local/bin/MATLAB*"
remove_path "/usr/local/matlab*"
remove_path "/usr/local/MATLAB*"
remove_path "/usr/share/matlab*"
remove_path "/usr/share/MATLAB*"
remove_path "/opt/MathWorks"
remove_path "/opt/mathworks"

# System launchers/icons/menu entries
remove_path "/usr/share/applications/matlab*.desktop"
remove_path "/usr/share/applications/MATLAB*.desktop"
remove_path "/usr/share/applications/mw-*"
remove_path "/usr/share/mate/desktop-directories/mate-matlab*"
remove_path "/usr/share/icons/hicolor/*/apps/matlab*"
remove_path "/usr/share/icons/hicolor/*/apps/MATLAB*"

# systemd service
remove_path "/etc/systemd/system/matlab-proxy.service"
remove_path "/etc/systemd/system/multi-user.target.wants/matlab-proxy.service"

# Profile hooks
remove_path "/etc/profile.d/mw_context_tag.sh"
remove_path "/etc/profile.d/mlm_def.sh"
remove_path "/etc/profile.d/MSH-postinstall.sh"
remove_path "/etc/profile.d/mhlmvars.sh"

# Skeleton/default user files
remove_path "/etc/skel/.matlab"
remove_path "/etc/skel/.MathWorks"
remove_path "/etc/skel/.MATLABConnector"
remove_path "/etc/skel/Desktop/matlab.desktop"
remove_path "/etc/skel/Documents/MATLAB"

# Root user remnants
remove_path "/root/.matlab"
remove_path "/root/.MathWorks"
remove_path "/root/.MATLABConnector"
remove_path "/root/.local/bin/matlab*"
remove_path "/root/.local/lib/python3.*/site-packages/matlab*"
remove_path "/root/.local/share/applications/mw-*"
remove_path "/root/.local/share/applications/matlab*"


# User home cleanup
for base in /home /home/AD; do
  [[ -d "$base" ]] || continue

  for user_home in "$base"/*; do
    [[ -d "$user_home" ]] || continue
    [[ "$user_home" == "/home/AD" ]] && continue

    remove_path "$user_home/Desktop/matlab.desktop"
    remove_path "$user_home/Documents/MATLAB"
    remove_path "$user_home/.matlab"
    remove_path "$user_home/.MathWorks"
    remove_path "$user_home/.MATLABConnector"
    remove_path "$user_home/.local/bin/matlab*"
    remove_path "$user_home/.local/lib/python3.*/site-packages/matlab*"
    remove_path "$user_home/.local/share/applications/mw-*"
    remove_path "$user_home/.local/share/applications/matlab*"
  done
done

run systemctl daemon-reload
run systemctl reset-failed matlab-proxy 2>/dev/null || true

echo
echo "Done."
echo
echo "Suggested follow-up checks:"
echo "  dpkg -l | grep -Ei 'matlab|mathworks'"
echo "  sudo find /etc /opt /usr/local /usr/share \\( -iname '*matlab*' -o -iname '*mathworks*' \\)"
if [[ "$EXECUTE" != true ]]; then
  echo "This was a dry run. To actually remove files, run:"
  echo "sudo $0 --execute"
fi
