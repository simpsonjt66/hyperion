# Hyperion Project Context & Refactoring Guide

## Project Overview

Hyperion is a Ruby-based CLI tool designed for managing system-wide themes
(Alacritty, Hyprland, Kitty, Waybar, etc.) on Linux. It uses `rofi` for menu
selection and provides a modular architecture for different configuration areas.

## Core Mandates & Conventions

- **Language**: Ruby
- **CLI Interaction**: Uses `Utilities.rofi_select` (via `rofi -dmenu`) for all
  user choices.
- **Navigation**: Managed by a `Navigator` class using a stack of menus.
- **Error Handling**: Menus should return a hash with an `:action` key (`:push`,
  `:back`, `:exit`).
- **Style**: Adhere to standard Ruby conventions (snake_case, 2-space
  indentation).
- **Execution**: Always use `bundle exec` (e.g., `bundle exec rake test`) to
  ensure dependencies are correctly loaded.

## Current Refactoring Plan

The project is undergoing a major refactoring to move from a tightly coupled
architecture to a decoupled, factory-based "Coordinator Pattern".

### Key Objectives

1. **Decoupling**: Menus should not access global constants like `OPTIONS` or
   the `Utilities` module directly.
2. **Standardization**: Use a `MenuFactory` to inject dependencies (`options`,
   `view`) into menu instances.
3. **Redundancy Reduction**: Implement `Menus::Base` to encapsulate common rofi
   selection logic.
4. **Bug Fixes**: Address critical bugs like the one in `Menus::Editor` where
   `exit` was called as a method instead of returned as a symbol.

### Architecture (Target State)

- **`MenuFactory`**: The central point for instantiating menus with their
  specific configuration.
- **`Navigator`**: Stores a stack of _route symbols_ (e.g., `:main`, `:system`)
  rather than class references.
- **`Menus::Base`**: Provides a standard interface for menus.

### Known Issues to Fix

- `lib/hyperion/menus/editor.rb`: `{ action: exit }` should be
  `{ action: :exit }`.
- `Main` menu uses `self.show` (class method) while the target architecture uses
  instance methods.
- Inconsistent config keys: `:name` vs `:prompt`.

## Future Tasks

- [ ] Move `Navigator` from `bin/hyperion.rb` to `lib/hyperion/navigator.rb`.
- [ ] Implement `MenuFactory` in `lib/hyperion/menu_factory.rb`.
- [ ] Refactor all menu classes to inherit from `Menus::Base` and use instance
      methods.
- [ ] Standardize the configuration YAML structure.
