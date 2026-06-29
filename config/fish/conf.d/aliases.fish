# ── Алиасы ───────────────────────────────────────────────────

# eza как замена ls (если установлен; иначе остаётся системный ls).
if type -q eza
    set -l _eza_flags --group-directories-first --icons=auto
    alias ls "eza $_eza_flags"
    alias ll "eza $_eza_flags -l --git --header"
    alias la "eza $_eza_flags -la --git --header"
    alias lt "eza $_eza_flags --tree --level=2"
    alias tree "eza $_eza_flags --tree"
end

# bat как cat с подсветкой (бинарь может называться bat или batcat).
if type -q bat
    alias cat bat
else if type -q batcat
    alias cat batcat
    alias bat batcat
end
