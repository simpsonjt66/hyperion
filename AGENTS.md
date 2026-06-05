# AGENTS.md

## What this is

Hyperion is a Ruby CLI tool for managing Linux desktop theming and config (Hyprland, Alacritty, Kitty, Waybar, rofi). It presents a rofi-based menu UI and lives outside Rails.

## Key commands

```bash
bundle install            # via bin/setup
bundle exec rake test     # run ALL tests
bin/console               # IRB with the gem loaded
bin/hyperion.rb           # run the CLI (needs ~/.config/hyperion/config.yaml)
bundle exec rake install  # install gem locally
```

Testing uses **Minitest** (not RSpec) — `describe`/`it` blocks with `assert_equal`, `refute_nil`, `assert_raises`. Run a single file: `bundle exec ruby -Itest test/hyperion/navigator_test.rb`.

Prettier is configured (`.prettierrc`) for formatting — run with `npx prettier --write` on supported files.

## Architecture

`bin/hyperion.rb` is the entrypoint. It loads YAML from `~/.config/hyperion/config.yaml` (symbolized keys), then starts a `Navigator` with an initial route symbol (default `:main`).

### Flow

```
Navigator (stack of route symbols)
  -> MenuFactory.build(route, options_hash, view)
    -> Menu instance (constructed with options:, view:)
      -> menu.show returns { action: :push/:back/:exit, target: symbol }
```

### Menu hierarchy

```
Menus::Base (constructor: options:, view:)
  +-- Menus::PushMenu  (handle_selection returns { action: :push, target: <command>.downcase.to_sym })
  |     Main, Default
  +-- Menus::Launcher  (handle_selection executes command, returns { action: :exit })
  |     Editor, Browser, Terminal, Screenshot
  +-- direct subclasses (override handle_selection or show themselves)
        System, Config, Package, Theme, Font, Apps
```

Menus **must** return a hash with an `:action` key (`:push`/`:back`/`:exit`). Use symbols, not bare `exit`.

### Config YAML (`~/.config/hyperion/config.yaml`)

Keys mirror route symbols: `main_menu`, `system_menu`, `config_menu`, `screenshot_menu`, `package_menu`, `default_menu`, `default_editor_menu`, `default_browser_menu`, `default_terminal_menu`. Menu items have `prompt` and `command` keys; system items may have `confirm`.

## Important details

- Uses `toml-rb` gem (loaded as `require 'toml-rb'`).
- The `View`/`RofiAdapter` calls `rofi -dmenu`, `notify-send`, `confirm-dialog`, `xdg-terminal-exec`, `launch-editor`, `uwsm-app`. These must be on `$PATH`.
- rofi theme files expected at `~/.config/rofi/themes/system-menu.rasi` and `app-launcher.rasi`.
- Themes live in `themes/` (project root) at dev time; runtime symlinks via `$XDG_DATA_HOME/hyperion/themes` and `.../current/theme`.
- `Utilities` module defines paths (`HYPERION_PATH`, `THEME_PATH`, `CURRENT_THEME_PATH`) based on `$XDG_DATA_HOME`.
- `Applications::Registry` manages toggles for Waybar, Hypridle, Hyprsunset using `pgrep`/`pkill` and `uwsm-app`.
- `FontManager` reads/updates Kitty font and writes to `$HYPERION_PATH/current/font.current`.
- CI runs `bundle exec rake` (Ruby 4.0.1) on push/PR to `main`.
- `sig/hyperion.rbs` exists but is minimal — not enforced.

## Ongoing refactoring

`GEMINI.md` and `docs/refactoring.md` document a move toward the Coordinator pattern already partially implemented. Key facts:
- `MenuFactory` and `Navigator` already extracted to `lib/hyperion/`.
- All menus use instance methods (not `self.show`) and constructor injection (`options:`, `view:`).
- `Menus::Base` is the shared base with `#show` calling `#handle_selection`.
- Inconsistency still exists in config YAML keys (`:name` vs `:prompt`) — handle both.
