# ── Стартовый пресет tide ────────────────────────────────────
# Применяется ОДИН раз — при первом запуске после установки tide.
# Маркер ghostfish_tide_applied не даёт перезатирать твою ручную
# настройку через `tide configure`.
#
# Здесь заданы только стабильные, «безопасные» переменные (списки
# элементов и булевы флаги) — без хардкода hex-цветов, чтобы вид
# наследовал палитру выбранной темы. Тонкая настройка стиля
# (lean / rainbow / classic, цвета, иконки, одна/две строки):
#   tide configure

if status is-interactive
    and functions -q tide
    and not set -q ghostfish_tide_applied

    # Пустая строка перед промптом — больше воздуха.
    set -U tide_prompt_add_newline_before true
    # Отступы вокруг сегментов.
    set -U tide_prompt_pad_items true
    # «Призрачный» транзиентный промпт: прошлые строки сворачиваются.
    set -U tide_prompt_transient_enabled true

    # Левый промпт — только суть: путь и git.
    set -U tide_left_prompt_items pwd git
    # Правый промпт — статус, длительность команды, контекст и версии.
    set -U tide_right_prompt_items status cmd_duration context jobs node go python rustc time

    # Показывать длительность команды от 3 секунд.
    set -U tide_cmd_duration_threshold 3000

    set -U ghostfish_tide_applied 1
end
