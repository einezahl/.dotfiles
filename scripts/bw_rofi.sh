#!/usr/bin/env bash
# Keyboard-driven Bitwarden picker built on the official `bw` CLI.
#
# Flow on Super+a:
#   1. If no cached session (or timed out): prompt for master password in rofi,
#      run `bw unlock`, cache the returned session token in libsecret.
#   2. Pipe `bw list items` through rofi to pick a login entry.
#   3. Show an action menu: auto-type, copy password, copy username, copy TOTP,
#      sync, lock.
#
# Session storage: the libsecret keyring (same backing store as gnome-keyring /
# kwallet). Decrypted automatically when you log in to your session. Cleared
# explicitly via the "lock" action or after BW_ROFI_TIMEOUT seconds.
set -euo pipefail

SESSION_TIMEOUT="${BW_ROFI_TIMEOUT:-21600}"   # 6 hours
CLIP_TIMEOUT="${BW_ROFI_CLIP:-30}"            # seconds

ATTR_APP=bw-rofi
TS_FILE="$HOME/.cache/bw-rofi/session_ts"
mkdir -p "$(dirname "$TS_FILE")"

notify() {
    command -v notify-send >/dev/null && notify-send -t 3000 "Bitwarden" "$*" || true
}

die() { notify "$*"; exit 1; }

ask_password() {
    rofi -dmenu -password -p "Bitwarden master password" -lines 0 < /dev/null
}

load_session() {
    local now ts
    [[ -f "$TS_FILE" ]] || return 1
    now=$(date +%s); ts=$(<"$TS_FILE")
    (( now - ts < SESSION_TIMEOUT )) || return 1
    secret-tool lookup application "$ATTR_APP" 2>/dev/null
}

save_session() {
    printf '%s' "$1" | secret-tool store --label="bw-rofi session" application "$ATTR_APP"
    date +%s > "$TS_FILE"
}

clear_session() {
    secret-tool clear application "$ATTR_APP" 2>/dev/null || true
    rm -f "$TS_FILE"
}

unlock_vault() {
    local pw token
    pw=$(ask_password) || exit 0
    [[ -z "$pw" ]] && exit 0
    token=$(BW_ROFI_PW="$pw" bw unlock --passwordenv BW_ROFI_PW --raw 2>/dev/null) \
        || die "Could not unlock vault (wrong password or not logged in)"
    save_session "$token"
    printf '%s' "$token"
}

clear_clipboard_later() {
    ( sleep "$CLIP_TIMEOUT" && printf '' | xclip -selection clipboard -i ) >/dev/null 2>&1 &
    disown
}

BW_SESSION="$(load_session || unlock_vault)"
export BW_SESSION

items_json=$(bw list items 2>/dev/null) || die "Could not list vault items"
labels=$(printf '%s' "$items_json" \
    | jq -r '[.[] | select(.type==1)] | to_entries[] | "\(.value.name) [\(.value.login.username // "—")]"')

[[ -z "$labels" ]] && die "No login entries in vault"

selected_index=$(printf '%s' "$labels" | rofi -dmenu -i -p "Vault" -format 'i')
[[ -z "$selected_index" ]] && exit 0

id=$(printf '%s' "$items_json" \
    | jq -r --argjson i "$selected_index" '[.[] | select(.type==1)][$i].id')

action=$(printf 'type-user-pass\ncopy-password\ncopy-username\ncopy-totp\nsync\nlock\n' \
    | rofi -dmenu -i -p "Action")

case "$action" in
    type-user-pass)
        user=$(bw get username "$id" 2>/dev/null || true)
        pw=$(bw get password "$id")
        sleep 0.2
        if [[ -n "$user" ]]; then
            xdotool type --delay 12 -- "$user"
            xdotool key Tab
        fi
        xdotool type --delay 12 -- "$pw"
        ;;
    copy-password)
        bw get password "$id" | xclip -selection clipboard -i
        clear_clipboard_later
        notify "Password copied — clears in ${CLIP_TIMEOUT}s"
        ;;
    copy-username)
        bw get username "$id" | xclip -selection clipboard -i
        clear_clipboard_later
        notify "Username copied"
        ;;
    copy-totp)
        bw get totp "$id" | xclip -selection clipboard -i
        clear_clipboard_later
        notify "TOTP copied — clears in ${CLIP_TIMEOUT}s"
        ;;
    sync)
        bw sync >/dev/null && notify "Vault synced"
        ;;
    lock)
        clear_session
        bw lock >/dev/null
        notify "Vault locked"
        ;;
esac
