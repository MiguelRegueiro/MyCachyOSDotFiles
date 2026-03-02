source /usr/share/cachyos-fish-config/cachyos-config.fish

# Load fzf key bindings
fzf_key_bindings

abbr -a up "paru -Syu && flatpak update && sudo limine-snapper-sync"

starship init fish | source

if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end


# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
