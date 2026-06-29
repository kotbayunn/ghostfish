#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  ghostfish — установщик красивого терминала
#  Ghostty + fish + fisher + tide + NerdFont + eza
#
#  Идемпотентен: повторный запуск ничего не ломает.
#  sudo сам НЕ вызывает — команды для системных пакетов печатает
#  в конце, чтобы их выполнить вручную.
#
#  Использование:  ./install.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

# Версии скачиваемых артефактов (обновлять здесь).
EZA_VERSION="v0.23.4"
NERDFONT_VERSION="v3.4.0"
NERDFONT_NAME="JetBrainsMono"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/config"
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_BIN="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts"
TS="$(date +%Y%m%d-%H%M%S)"

# ── вывод ────────────────────────────────────────────────────
c_info()  { printf '\033[34m▸\033[0m %s\n' "$*"; }
c_ok()    { printf '\033[32m✔\033[0m %s\n' "$*"; }
c_warn()  { printf '\033[33m!\033[0m %s\n' "$*"; }
c_step()  { printf '\n\033[1;35m== %s ==\033[0m\n' "$*"; }

# Создать симлинк src → dst с бэкапом существующего реального файла.
link() {
    local src="$1" dst="$2"
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        c_ok "уже связано: ${dst/#$HOME/\~}"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        mv "$dst" "$dst.bak.$TS"
        c_warn "сохранил прежнее: ${dst/#$HOME/\~}.bak.$TS"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    c_ok "связал: ${dst/#$HOME/\~} → ${src/#$HOME/\~}"
}

# ── 1. Симлинки конфигов ─────────────────────────────────────
c_step "Конфиги (симлинки)"

# Ghostty — каталог целиком (внутри только наши файлы).
link "$CONFIG_SRC/ghostty" "$XDG_CONFIG/ghostty"

# Активная тема по умолчанию — Catppuccin Mocha (если ещё не выбрана).
THEMES_DIR="$CONFIG_SRC/ghostty/themes"
if [[ ! -L "$THEMES_DIR/current.conf" ]]; then
    ln -sf "catppuccin-mocha.conf" "$THEMES_DIR/current.conf"
    c_ok "тема по умолчанию: Catppuccin Mocha"
else
    c_ok "тема уже выбрана: $(basename "$(readlink "$THEMES_DIR/current.conf")" .conf)"
fi

# fish — пофайлово, чтобы плагины fisher не попадали в репозиторий.
mkdir -p "$XDG_CONFIG/fish/conf.d" "$XDG_CONFIG/fish/functions" "$XDG_CONFIG/fish/completions"
link "$CONFIG_SRC/fish/config.fish"            "$XDG_CONFIG/fish/config.fish"
link "$CONFIG_SRC/fish/fish_plugins"           "$XDG_CONFIG/fish/fish_plugins"
for f in "$CONFIG_SRC"/fish/conf.d/*.fish; do
    link "$f" "$XDG_CONFIG/fish/conf.d/$(basename "$f")"
done
link "$CONFIG_SRC/fish/functions/theme.fish"   "$XDG_CONFIG/fish/functions/theme.fish"
link "$CONFIG_SRC/fish/completions/theme.fish" "$XDG_CONFIG/fish/completions/theme.fish"

# ── 2. eza (замена ls) ───────────────────────────────────────
c_step "eza"
if command -v eza >/dev/null 2>&1; then
    c_ok "eza уже установлен: $(eza --version | head -1)"
else
    c_info "скачиваю eza $EZA_VERSION → $LOCAL_BIN"
    mkdir -p "$LOCAL_BIN"
    tmp="$(mktemp -d)"
    url="https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
    if curl -fsSL "$url" -o "$tmp/eza.tar.gz"; then
        tar -xzf "$tmp/eza.tar.gz" -C "$tmp"
        install -m 0755 "$tmp/eza" "$LOCAL_BIN/eza"
        c_ok "eza установлен: $("$LOCAL_BIN/eza" --version | head -1)"
    else
        c_warn "не удалось скачать eza — проверь сеть или версию EZA_VERSION"
    fi
    rm -rf "$tmp"
fi

# ── 3. JetBrainsMono Nerd Font ───────────────────────────────
c_step "NerdFont ($NERDFONT_NAME)"
if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    c_ok "шрифт уже установлен"
else
    c_info "скачиваю $NERDFONT_NAME Nerd Font $NERDFONT_VERSION → $FONT_DIR"
    mkdir -p "$FONT_DIR/$NERDFONT_NAME"
    tmp="$(mktemp -d)"
    url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERDFONT_VERSION}/${NERDFONT_NAME}.zip"
    if curl -fsSL "$url" -o "$tmp/font.zip"; then
        unzip -oq "$tmp/font.zip" -d "$FONT_DIR/$NERDFONT_NAME" -x "*.txt" "*.md"
        fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
        c_ok "шрифт установлен и кэш обновлён"
    else
        c_warn "не удалось скачать шрифт — проверь сеть или версию NERDFONT_VERSION"
    fi
    rm -rf "$tmp"
fi

# ── 4. fisher + плагины (tide) ───────────────────────────────
c_step "fisher + tide"
if command -v fish >/dev/null 2>&1; then
    if ! fish -c 'functions -q fisher' 2>/dev/null; then
        c_info "ставлю fisher"
        fish -c '
            curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
            and fisher install jorgebucaran/fisher
        '
    fi
    c_info "синхронизирую плагины из fish_plugins (tide и пр.)"
    fish -c 'fisher update' && c_ok "плагины установлены" || c_warn "fisher update завершился с ошибкой"
    c_info "tide установлен. Для тонкой настройки стиля запусти: tide configure"
else
    c_warn "fish не найден — пропускаю fisher/tide (см. шаги с sudo ниже)"
fi

# ── 5. Системные пакеты (требуют sudo — выполни вручную) ──────
c_step "Системные пакеты (sudo)"
need_sudo=0
if ! command -v ghostty >/dev/null 2>&1; then
    need_sudo=1
    echo "  Ghostty не установлен:"
    echo "      sudo snap install ghostty --classic"
fi
if ! command -v fish >/dev/null 2>&1; then
    need_sudo=1
    echo "  fish не установлен (нужна свежая версия для tide v6):"
    echo "      sudo add-apt-repository -y ppa:fish-shell/release-4"
    echo "      sudo apt update && sudo apt install -y fish"
    echo "  затем сделать fish логин-шеллом (по желанию):"
    echo "      chsh -s \$(command -v fish)"
    echo "  и повторно запустить ./install.sh — он доустановит tide."
fi
if [[ $need_sudo -eq 0 ]]; then
    c_ok "все системные пакеты на месте"
fi

c_step "Готово"
echo "Открой Ghostty. Если устанавливал fish только что — сначала выполни"
echo "блок sudo выше и запусти ./install.sh повторно."
echo "Переключение тем:   theme            (список)"
echo "                    theme nord       (выбрать) → Ctrl+Shift+, применить"
echo "Настройка промпта:  tide configure"
