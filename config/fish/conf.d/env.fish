# ── Окружение и PATH ─────────────────────────────────────────

# ~/.local/bin — туда install.sh кладёт eza и другие бинари.
# fish_add_path идемпотентен: повторно путь не задвоится.
fish_add_path -g $HOME/.local/bin

# Редактор по умолчанию.
set -gx EDITOR nano
set -gx VISUAL nano

# Тема подсветки для bat (cat с подсветкой).
set -gx BAT_THEME ansi

# eza: показывать иконки и группировать каталоги первыми задаётся
# в алиасах (conf.d/aliases.fish), цвета берутся из LS_COLORS/темы.
