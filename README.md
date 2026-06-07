# Hyperion

Hyperion is a specialized menu system and desktop management tool designed for Linux environments, with a primary focus on Hyprland. Built in Ruby, it leverages `rofi` as a user interface to provide a centralized, keyboard-driven workflow for system control, configuration management, and theming.

This is a personal project designed for a specific workflow, but it is structured as an open-source tool.

## Key Features

- **Centralized Launcher**: Access system tools, applications, and configurations from a single `rofi` interface.
- **Dynamic Theming**: Seamlessly switch between themes. Hyperion manages the synchronization of styles across multiple applications (e.g., Alacritty, Waybar, Hyprland, Kitty) using a template-based system.
- **Application Control**: A built-in registry to manage the lifecycle (start/stop/status) of desktop services like `waybar`, `hypridle`, and `hyprsunset`.
- **Configuration Hub**: Quickly open and edit configuration files for various system tools without navigating the filesystem.
- **System Actions**: Standardized interface for power management (reboot, shutdown, logout, lock).
- **Extensible Architecture**: Built on a decoupled Coordinator Pattern, making it easy to add new menus or swap out the UI adapter.

## Core Architecture

Hyperion follows the **Coordinator Pattern** to ensure high decoupling between logic and presentation:

- **Navigator**: The engine that manages the menu stack and handles transitions between routes.
- **MenuFactory**: The central registry for all routes, responsible for instantiating menus with their required dependencies.
- **Menus**: Individual logic units that handle user input and decide on the next action (`:push`, `:back`, `:exit`).
- **View Adapter**: An abstraction layer over the UI. Currently, it implements a `RofiAdapter`, but the architecture allows for swapping this with `fzf`, `gum`, or a GUI.
- **Utilities**: A collection of tools for theme management, file manipulation, and process control.

## Project Structure

```text
├── bin/                # Entry point script (hyperion.rb)
├── lib/                # Core library logic
│   ├── hyperion/
│   │   ├── applications/  # External app definitions
│   │   ├── menus/         # Menu logic classes
│   │   ├── utilities/     # Helper modules (Theming, Font management, etc.)
│   │   └── view/          # UI Adapters (Rofi)
├── config/             # Default configuration files
├── templates/          # Application config templates (.tpl)
├── themes/             # Theme definitions and assets
└── install.sh          # Installation script
```

## Installation

The project includes an `install.sh` script to set up the necessary directories and sync assets.

```bash
# Clone the repository
git clone https://github.com/yourusername/hyperion.git
cd hyperion

# Run the installation script
./install.sh

# Ensure you have the required dependencies (Ruby 3.2+, rofi, etc.)
bundle install
```

The installer provisions:
- Config: `~/.config/hyperion/config.yaml`
- Templates: `~/.local/share/hyperion/templates/`
- Themes: `~/.local/share/hyperion/themes/`

## Usage

Run the main menu:
```bash
bundle exec ruby bin/hyperion.rb
```

Launch a specific route directly:
```bash
bundle exec ruby bin/hyperion.rb system
```

## Configuration

The primary configuration is managed in `~/.config/hyperion/config.yaml`. This file defines the menu structure, prompts, and the commands executed by various launchers.

## Development

Hyperion is built with testability in mind.

### Running Tests
```bash
bundle exec rake test
```

### Adding a New Menu
1. Define the route in `lib/hyperion/menu_factory.rb`.
2. Create the menu class in `lib/hyperion/menus/` (inheriting from `Base`, `PushMenu`, or `Launcher`).
3. (Optional) Add the configuration section in `config/config.yaml`.

## License

MIT
