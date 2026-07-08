# ghostfish 👻🐟

Спецификация и конфиги для красивого, «pinterest-friendly» терминала на Linux.
Собирается из: **[Ghostty](https://ghostty.org)** (терминал) + **[fish](https://fishshell.com)**
(оболочка) + **[fisher](https://github.com/jorgebucaran/fisher)** (менеджер плагинов) +
**[tide](https://github.com/IlanCosman/tide)** (промпт) + **[NerdFonts](https://www.nerdfonts.com)**
(иконки) + **[eza](https://github.com/eza-community/eza)** (замена `ls`).

Это та самая «спека, по которой настраивал» — клонируешь, запускаешь `install.sh`,
выполняешь пару команд с `sudo`, и получаешь такой же терминал.

> **Два слоя красоты — важно понимать разницу.**
> «Красота» терминала делится на два независимых слоя:
>
> - **Слой оболочки** (fish + tide + eza + автоподсказки + подсветка ввода) — работает
>   в **любом** эмуляторе терминала, лишь бы стоял Nerd Font. Не зависит от Ghostty.
> - **Слой эмулятора** (тема, лигатуры, сплиты, прозрачность, GPU-рендер) — свой у
>   каждого терминала.
>
> Поэтому Ghostty **не обязателен**: тот же fish + tide + eza прекрасно живут в
> `xfce4-terminal`, `gnome-terminal`, `kitty` и т.д. Ниже описаны оба пути —
> Ghostty и xfce4-terminal (см. [Вариант без Ghostty](#вариант-без-ghostty-xfce4-terminal)).

---

## Что внутри

| Компонент | Роль | Как ставится |
|-----------|------|--------------|
| Ghostty | GPU-ускоренный терминал-эмулятор | `snap` (`sudo`) |
| fish 4.x | дружелюбная командная оболочка | PPA `fish-shell/release-4` (`sudo`) |
| fisher | менеджер плагинов fish | `install.sh` |
| tide v6 | быстрый информативный промпт | `install.sh` (через fisher) |
| JetBrainsMono Nerd Font | шрифт с иконками (для Ghostty) | `install.sh` → `~/.local/share/fonts` |
| eza | цветной `ls` с иконками и git | `install.sh` → `~/.local/bin` |

> **Зачем fish из PPA, а не из apt.** tide v6 требует свежий fish (4.x), а в apt
> Ubuntu 22.04 лежит fish 3.3. Поэтому fish ставится из официального PPA.

---

## Требования

- Ubuntu 22.04+ с графической оболочкой (Ghostty — GUI-приложение).
- `snap`, `curl`, `unzip`, `fontconfig` (`fc-cache`) — обычно уже есть.
- Архитектура x86_64 (бинарь eza в `install.sh` под неё; для arm64 поправь URL в скрипте).
- **Для Ghostty — GPU с OpenGL ≥ 4.3.** На старых картах Ghostty не стартует
  (см. [Проблемы и решения](#проблемы-и-решения)). В этом случае используй
  вариант с xfce4-terminal.

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

## Вариант без Ghostty: xfce4-terminal

Если Ghostty не подходит (старая видеокарта без OpenGL 4.3, неудобства с раскладкой
для `Ctrl`-сочетаний, просто привычнее штатный терминал XFCE) — весь shell-слой
(fish + tide + eza) работает в `xfce4-terminal` без изменений. Нужны только **шрифт**
и **цвета**.

### Шрифт

В `xfce4-terminal`: **Правка → Настройки → Внешний вид → Шрифт** — выбрать любой
установленный Nerd Font (например `UbuntuMono Nerd Font Mono` или `JetBrainsMono Nerd Font`),
размер по вкусу. Или задать в `~/.config/xfce4/terminal/terminalrc`:

```ini
FontName=UbuntuMono Nerd Font Mono 13
```

### Цвета — палитра far2l (VGA)

В репозитории лежит переносимая цветосхема `config/xfce4-terminal/colorschemes/far2l.theme` —
классическая 16-цветная VGA-палитра как в [far2l](https://github.com/elfmz/far2l)
(чёрный фон, светло-серый текст). Установка:

```sh
mkdir -p ~/.local/share/xfce4/terminal/colorschemes
cp config/xfce4-terminal/colorschemes/far2l.theme ~/.local/share/xfce4/terminal/colorschemes/
```

Затем **Правка → Настройки → Цвета → Предустановленные схемы → far2l VGA**.

> **Тонкость палитры.** У far2l/DOS другая нумерация цветов: индекс 1 — синий,
> 4 — красный. В ANSI наоборот (1 — красный, 4 — синий). В `far2l.theme` цвета уже
> переставлены под ANSI, иначе синий и красный поменялись бы местами. Источник
> оригинальных значений — `~/.config/far2l/palette.ini` (использован foreground-набор,
> он чуть ярче background-набора и лучше читается на тёмном фоне).

Полный эталонный `terminalrc` (шрифт + палитра + прочие настройки) — в
`config/xfce4-terminal/terminalrc`, для справки.

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
│   ├── fish/
│   │   ├── config.fish        # интерактивные настройки (zoxide/fzf — если стоят)
│   │   ├── fish_plugins       # список плагинов для fisher (fisher, tide)
│   │   ├── conf.d/            # env, алиасы, аббревиатуры, пресет tide
│   │   ├── functions/         # функция theme — переключение тем
│   │   └── completions/       # автодополнение для theme
│   └── xfce4-terminal/        # вариант без Ghostty
│       ├── terminalrc         # эталонный конфиг (шрифт + палитра far2l)
│       └── colorschemes/
│           └── far2l.theme    # переносимая VGA-палитра far2l
└── README.md
```

**Как применяются конфиги.** `install.sh` создаёт симлинки из `~/.config` в этот
репозиторий: каталог `ghostty` — целиком, файлы `fish` — пофайлово (чтобы плагины,
которые fisher ставит в `~/.config/fish`, не попадали в репозиторий). Правишь файл
в репозитории — изменение сразу в системе и под версионным контролем.
(Конфиги `xfce4-terminal` `install.sh` пока **не** трогает — ставятся вручную,
см. [Вариант без Ghostty](#вариант-без-ghostty-xfce4-terminal).)

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

**xfce4-terminal**: размер шрифта — `Ctrl + =` / `Ctrl + -` / `Ctrl + 0`;
новая вкладка — `Ctrl+Shift+T`; копировать/вставить — `Ctrl+Shift+C` / `V`.

---

## Размер и шрифт

**Ghostty**: размер — в `config/ghostty/config` (`font-size = 12`) или на лету
`Ctrl + =` / `Ctrl + -`. Сменить шрифт — поправь `font-family` (имя должно совпадать
с установленным Nerd Font; список: `fc-list | grep Nerd`).

**xfce4-terminal**: `FontName` в `terminalrc` или через GUI (Внешний вид → Шрифт).

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

## Проблемы и решения

### Ghostty падает: `error.OpenGLOutdated` / `SurfaceError`

В логе (`ghostty` из терминала) видно:

```
info(opengl): loaded OpenGL 3.3
warning(opengl): OpenGL version is too old. Ghostty requires OpenGL 4.3
warning(gtk_ghostty_surface): surface failed to initialize err=error.SurfaceError
```

**Причина:** видеокарта отдаёт OpenGL ниже 4.3 (например GeForce 210 на nouveau —
максимум 3.3). Длинные `Gtk: Theme parser error` в логе — посторонний шум, к падению
отношения не имеют.

**Обходной путь** — программный рендеринг через Mesa llvmpipe (OpenGL 4.5, на CPU):

```sh
LIBGL_ALWAYS_SOFTWARE=1 ghostty
```

Проверить, что llvmpipe даёт нужную версию: `LIBGL_ALWAYS_SOFTWARE=1 glxinfo | grep "OpenGL core"`.
Минус — рендер на CPU (возможны подтормаживания прокрутки). **Не** ставь
`LIBGL_ALWAYS_SOFTWARE=1` глобально, иначе на CPU уедет весь GUI. Если железо слабое —
проще перейти на [xfce4-terminal](#вариант-без-ghostty-xfce4-terminal).

### Ghostty: `Ctrl+C` не работает при русской раскладке

Особенность GTK4: при не-латинской раскладке `Ctrl+C` шлёт кириллическую «С»,
приложение его не распознаёт (например, не выйти из TUI). Приходится переключать
раскладку на английскую. Надёжного решения нет. В `xfce4-terminal` (движок VTE)
такой проблемы нет — `Ctrl`-сочетания работают при любой раскладке.

### xfce4-terminal: новый шрифт/цвета не подхватываются в новом окне

`xfce4-terminal` по умолчанию работает как **единый процесс-демон**: все окна
открывает один процесс, который держит настройки в памяти с момента своего старта.
Правки `terminalrc` на диске новые окна того же демона могут не подхватить.

**Решение** — заставить перечитать конфиг:

```sh
# Разовое окно свежим процессом (читает terminalrc заново):
xfce4-terminal --disable-server &

# Либо полный перезапуск демона: закрыть ВСЕ окна xfce4-terminal
# и открыть терминал заново.
```

---

## Удаление

Симлинки указывают в этот репозиторий, поэтому достаточно их убрать:

```sh
rm -rf ~/.config/ghostty
rm ~/.config/fish/config.fish ~/.config/fish/fish_plugins
rm ~/.config/fish/conf.d/{env,aliases,abbr,tide}.fish
rm ~/.config/fish/functions/theme.fish ~/.config/fish/completions/theme.fish
# xfce4-terminal: удалить схему far2l и вернуть шрифт/цвета в настройках.
rm -f ~/.local/share/xfce4/terminal/colorschemes/far2l.theme
# при первом запуске install.sh делал бэкапы *.bak.<дата> — верни их при желании.
```
