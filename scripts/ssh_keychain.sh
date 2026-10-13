# Load SSH keys into a single shared ssh-agent via keychain. Meant to be
# *sourced*, not executed, so the agent env (SSH_AUTH_SOCK, SSH_AGENT_PID)
# lands in the calling shell. Safe to source from both bash and zsh — the
# array idiom below is compatible with both.
#
# Every private key in ~/.ssh is detected by its "PRIVATE KEY" header, so this
# works no matter how the keys are named on a given machine. keychain starts
# one agent and reuses it across shells, so the passphrase is asked for only on
# the first source after boot; later sources find the keys already loaded and
# prompt for nothing.
#
# Sourcing this from the top of tmux_sessionizer.sh — before any tmux window is
# created — is what makes the prompt happen once, in the launching terminal.
# Otherwise each tmux window's shell sources .zshrc and races to prompt, and the
# command typed ahead via `tmux send-keys` (nvim, lazygit, claude) is swallowed
# by the passphrase prompt instead of running.
ssh_keys=()
for key in "$HOME"/.ssh/*; do
  [ -e "$key" ] || continue
  [ -f "$key" ] || continue
  IFS= read -r header < "$key" || continue
  case "$header" in
    *"PRIVATE KEY"*) ssh_keys+=("$key") ;;
  esac
done
eval "$(keychain --eval --quiet --agents ssh "${ssh_keys[@]}")"
unset ssh_keys key header
