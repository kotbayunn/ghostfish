function theme --description 'переключить тему Ghostty (ghostfish)'
    set -l dir $HOME/.config/ghostty/themes

    # Список доступных тем = themes/*.conf, кроме служебного current.conf.
    set -l names
    for f in $dir/*.conf
        set -l n (string replace -r '\.conf$' '' (path basename $f))
        test $n = current; and continue
        set -a names $n
    end

    # Текущая активная тема (по симлинку current.conf).
    set -l active ''
    if test -L $dir/current.conf
        set active (string replace -r '\.conf$' '' (path basename (readlink $dir/current.conf)))
    end

    # Без аргумента — показать список и подсказку.
    if test (count $argv) -eq 0
        echo 'Доступные темы Ghostty:'
        for n in $names
            if test $n = $active
                set_color green; echo "  ● $n (активна)"; set_color normal
            else
                echo "  ○ $n"
            end
        end
        echo 'Использование: theme <имя> — затем Ctrl+Shift+, для применения'
        return 0
    end

    set -l choice $argv[1]
    if not contains -- $choice $names
        echo "Неизвестная тема: $choice" >&2
        echo "Доступно: $names" >&2
        return 1
    end

    ln -sf $choice.conf $dir/current.conf
    set_color green
    echo "Тема → $choice. Нажми Ctrl+Shift+, чтобы применить (reload_config)."
    set_color normal
end
