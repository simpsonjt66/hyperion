# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-06-07

### Added
- Initial release of Hyperion menu system.
- **Coordinator Pattern**: Implemented `Navigator` and `MenuFactory` for decoupled navigation logic.
- **Rofi Integration**: Added `View::RofiAdapter` for a keyboard-driven UI.
- **Dynamic Theming**: Created `Utilities::ThemeSet` and supporting utilities to synchronize styles across Alacritty, Waybar, Hyprland, and Kitty.
- **Application Registry**: Added management for `waybar`, `hypridle`, and `hyprsunset`.
- **Menu Suite**: Implemented `Main`, `System`, `Config`, `Package`, `Theme`, `Font`, and `Screenshot` menus.
- **Template System**: Introduced `.tpl` based configuration generation for various desktop applications.
- **Installation Script**: Added `install.sh` for XDG-compliant asset deployment.
- **Testing Suite**: Initial unit tests for `MenuFactory`, `Navigator`, and core application logic.
- **Documentation**: Comprehensive `README.md` and architecture guidelines in `GEMINI.md`.
