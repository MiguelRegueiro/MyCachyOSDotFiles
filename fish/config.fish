if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# Load fzf key bindings
if functions -q fzf_key_bindings
    fzf_key_bindings
else if test -f /usr/share/fzf/shell/key-bindings.fish
    source /usr/share/fzf/shell/key-bindings.fish
    if functions -q fzf_key_bindings
        fzf_key_bindings
    end
end

abbr -a up "paru -Syu && flatpak update && cargo install-update -a && sudo limine-snapper-sync"

starship init fish | source

if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end


# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
