if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# Load fzf key bindings
if test -f /usr/share/fzf/shell/key-bindings.fish
    source /usr/share/fzf/shell/key-bindings.fish
end
functions -q fzf_key_bindings; and fzf_key_bindings

abbr -a sshserver "ssh user@ip" # edit this or remove it if you don't want it
# Distro-aware updater abbreviation.
if test -f /etc/os-release
    if grep -qiE '(^ID=fedora$|^ID_LIKE=.*fedora)' /etc/os-release
        abbr -a up "sudo dnf upgrade --refresh -y && flatpak update -y && cargo install-update -a"
    else
        abbr -a up "paru -Syu && flatpak update && cargo install-update -a && sudo limine-snapper-sync"
    end
end

fish_add_path $HOME/.local/bin
if command -sq starship
    starship init fish | source
end


# overwrite greeting
function fish_greeting
    if command -sq fastfetch
        fastfetch
    end
end

# OpenClaw Completion
if test -f /home/regueiro/.openclaw/completions/openclaw.fish
    source /home/regueiro/.openclaw/completions/openclaw.fish
end

if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"
end
