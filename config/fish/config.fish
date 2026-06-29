# ─────────────────────────────────────────────────────────────
#  fish — основной конфиг ghostfish
#  Порядок загрузки fish: conf.d/*.fish → config.fish → functions/
#  Поэтому переменные/PATH/abbr/aliases вынесены в conf.d/,
#  а здесь — только интерактивные настройки.
# ─────────────────────────────────────────────────────────────

# Всё интерактивное — внутри гарда, чтобы не мешать скриптам,
# scp/rsync и не-интерактивным сессиям (см. fish FAQ).
if status is-interactive
    # Пустое приветствие — чистый старт без баннера.
    set -g fish_greeting

    # zoxide — умный cd по частоте (если установлен).
    if type -q zoxide
        zoxide init fish | source
    end

    # fzf — клавиши Ctrl+R / Ctrl+T / Alt+C (если установлен).
    if type -q fzf
        fzf --fish | source
    end
end
