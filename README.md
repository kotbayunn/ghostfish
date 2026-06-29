# ghostfish 👻🐟

Спецификация и конфиги для красивого, «pinterest-friendly» терминала на Linux.
Собирается из: **[Ghostty](https://ghostty.org)** (терминал) + **[fish](https://fishshell.com)**
(оболочка) + **[fisher](https://github.com/jorgebucaran/fisher)** (менеджер плагинов) +
**[tide](https://github.com/IlanCosman/tide)** (промпт) + **[NerdFonts](https://www.nerdfonts.com)**
(иконки) + **[eza](https://github.com/eza-community/eza)** (замена `ls`).

Это та самая «спека, по которой настраивал» — клонируешь, запускаешь `install.sh`,
выполняешь пару команд с `sudo`, и получаешь такой же терминал.

---

## Что внутри

| Компонент | Роль | Как ставится |
|-----------|------|--------------|
| Ghostty | GPU-ускоренный терминал-эмулятор | `snap` (`sudo`) |
| fish 4.x | дружелюбная командная оболочка | PPA `fish-shell/release-4` (`sudo`) |
| fisher | менеджер плагинов fish | `install.sh` |
| tide v6 | быстрый информативный промпт | `install.sh` (через fisher) |
| JetBrainsMono Nerd Font | шрифт с иконками | `install.sh` → `~/.local/share/fonts` |
| eza | цветной `ls` с иконками и git | `install.sh` → `~/.local/bin` |

> **Зачем fish из PPA, а не из apt.** tide v6 требует свежий fish (4.x), а в apt
> Ubuntu 22.04 лежит fish 3.3. Поэтому fish ставится из официального PPA.

---

## Требования

- Ubuntu 22.04+ с графической оболочкой (Ghostty — GUI-приложение).
- `snap`, `curl`, `unzip`, `fontconfig` (`fc-cache`) — обычно уже есть.
- Архитектура x86_64 (бинарь eza в `install.sh` под неё; для arm64 поправь URL в скрипте).

---

## Установка

```sh
git clone https://github.com/kotbayunn/ghostfish.git
cd ghostfish

# 1. Системные пакеты (нужен sudo).
sudo snap install ghostty --classic
sudo add-apt-repository -y ppa:fish-shell/release-4
sudo apt update && sudo apt install -y fish

# 2. Конфиги + eza + шрифт + fisher/tide.
./install.sh

# 3. (по желанию) сделать fish логин-шеллом.
chsh -s "$(command -v fish)"
```

`install.sh` идемпотентен — повторный запуск ничего не ломает. Если запустить его
**до** установки fish, он поставит eza/шрифт и подскажет команды `sudo`; после
установки fish запусти `./install.sh` ещё раз — он доустановит tide.

После установки открой **Ghostty** и (один раз) донастрой промпт:

```sh
tide configure
```

> Для иконок в Ghostty используется шрифт `JetBrainsMono Nerd Font` — он уже
> прописан в конфиге и ставится скриптом. Если терминал был открыт до установки
> шрифта — перезапусти его.

---

## Структура репозитория

```
ghostfish/
├── install.sh                 # идемпотентный установщик (симлинки + eza + шрифт + fisher)
├── config/
│   ├── ghostty/
│   │   ├── config             # основной конфиг Ghostty
│   │   └── themes/            # спокойные темы, переключаются функцией theme
│   │       ├── catppuccin-mocha.conf   (по умолчанию)
│   │       ├── tokyonight-moon.conf
│   │       ├── gruvbox-dark.conf
│   │       ├── rose-pine.conf
│   │       ├── nord.conf
│   │       ├── kanagawa-wave.conf
│   │       └── everforest-soft.conf
│   └── fish/
│       ├── config.fish        # интерактивные настройки (zoxide/fzf — если стоят)
│       ├── fish_plugins       # список плагинов для fisher (fisher, tide)
│       ├── conf.d/            # env, алиасы, аббревиатуры, пресет tide
│       ├── functions/         # функция theme — переключение тем
│       └── completions/       # автодополнение для theme
└── README.md
```

**Как применяются конфиги.** `install.sh` создаёт симлинки из `~/.config` в этот
репозиторий: каталог `ghostty` — целиком, файлы `fish` — пофайлово (чтобы плагины,
которые fisher ставит в `~/.config/fish`, не попадали в репозиторий). Правишь файл
в репозитории — изменение сразу в системе и под версионным контролем.

---

## Темы

Семь спокойных тёмных палитр, переключение — функцией `theme`:

```sh
theme              # показать список и активную тему
theme nord         # выбрать тему
# затем в Ghostty: Ctrl+Shift+,  — перечитать конфиг (reload_config)
```

Под капотом `theme` переставляет симлинк `themes/current.conf`, а основной конфиг
подключает его строкой `config-file = themes/current.conf`. Полный список встроенных
тем Ghostty: `ghostty +list-themes`. Чтобы добавить свою — положи
`themes/<имя>.conf` со строкой `theme = <Название>`.

---

## Промпт (tide)

Стартовый вид задаётся в `conf.d/tide.fish` один раз (маркер не даёт перезатереть
ручную настройку): воздушный промпт, путь + git слева, статус/время/версии справа,
транзиентный режим. Полная перенастройка стиля — интерактивным мастером:

```sh
tide configure      # lean / rainbow / classic, цвета, иконки, одна/две строки
```

---

## Утилиты и горячие клавиши

**eza** (алиасы в `conf.d/aliases.fish`): `ls`, `ll`, `la`, `lt` (дерево, 2 уровня), `tree`.

**Аббревиатуры fish** (`conf.d/abbr.fish`, раскрываются по пробелу/Enter):
`gs ga gc gca gco gp gl gd glog` (git), `.. ... ....` (вверх по дереву), `c` (clear).

**Ghostty** (`config`):

| Клавиши | Действие |
|---------|----------|
| `Ctrl` + `=` / `-` / `0` | размер шрифта больше / меньше / сброс |
| `Ctrl+Shift+,` | перечитать конфиг (после смены темы) |
| `Ctrl+Shift+E` / `O` | разделить окно вправо / вниз |
| `Ctrl+Shift+←↑↓→` | переход между сплитами |
| `Ctrl+Shift+C` / `V` | копировать / вставить |

---

## Размер и шрифт

Размер шрифта — в `config/ghostty/config` (`font-size = 12`) или на лету клавишами
`Ctrl + =` / `Ctrl + -`. Сменить шрифт — поправь `font-family` (имя должно совпадать
с установленным Nerd Font; список: `fc-list | grep Nerd`).

---

## Опционально: fzf и zoxide

Конфиг fish уже готов их подхватить (`config.fish`), но сами они не ставятся.
Чтобы добавить:

```sh
sudo apt install -y fzf       # либо свежий с GitHub
# zoxide:
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

После установки `fzf` даёт `Ctrl+R` (история) и `Ctrl+T` (файлы), `zoxide` — умный
`cd` по частоте (`z <часть-пути>`).

---

## Удаление

Симлинки указывают в этот репозиторий, поэтому достаточно их убрать:

```sh
rm -rf ~/.config/ghostty
rm ~/.config/fish/config.fish ~/.config/fish/fish_plugins
rm ~/.config/fish/conf.d/{env,aliases,abbr,tide}.fish
rm ~/.config/fish/functions/theme.fish ~/.config/fish/completions/theme.fish
# при первом запуске install.sh делал бэкапы *.bak.<дата> — верни их при желании.
```
