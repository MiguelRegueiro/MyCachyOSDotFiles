source /usr/share/cachyos-fish-config/cachyos-config.fish

# Load fzf key bindings
fzf_key_bindings

abbr -a sshserver "ssh regueiro@100.108.179.88"
abbr -a up "paru -Syu && flatpak update && sudo limine-snapper-sync"

starship init fish | source


# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
