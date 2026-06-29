# Автодополнение имён тем для функции theme.
complete -c theme -f -a "(
    for f in \$HOME/.config/ghostty/themes/*.conf
        set -l n (string replace -r '\.conf\$' '' (path basename \$f))
        test \$n = current; and continue
        echo \$n
    end
)"
