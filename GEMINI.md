# Hyperion Project Guidelines

## Core Architecture: Coordinator Pattern

Hyperion uses a "Coordinator Pattern" to decouple menu logic, navigation, and presentation.

### 1. `Navigator` (`lib/hyperion/navigator.rb`)
- **Role**: Orchestrates the flow of the application.
- **Responsibility**: Manages a stack of _route symbols_. It uses the `MenuFactory` to build the actual menu object for the current route and executes its `show` method.
- **Transitions**: Decisions are based on the action returned by the menu (`:push`, `:back`, `:exit`).

### 2. `MenuFactory` (`lib/hyperion/menu_factory.rb`)
- **Role**: The central registry for all application routes.
- **Responsibility**: Instantiates menus with their required dependencies (`options`, `view`, etc.).
- **Mandate**: All new menus MUST be registered in the `ROUTES` constant.

### 3. `Menus` (`lib/hyperion/menus/`)
- **Base Class**: All menus MUST inherit from `Menus::Base`.
- **Specialized Classes**:
    - `PushMenu`: Use for menus that primarily navigate to other routes (e.g., `Main`, `Default`).
    - `Launcher`: Use for menus that execute external commands and exit (e.g., `Editor`, `Browser`).
- **Mandate**: Menus MUST NOT access global constants (`OPTIONS`) or the `Utilities` module directly. All external dependencies (config, utilities, adapters) MUST be injected via the constructor (usually handled in `MenuFactory`).

### 4. `ViewAdapter` (`lib/hyperion/view/rofi_adapter.rb`)
- **Role**: Abstracts the UI layer.
- **Responsibility**: Implements the `select`, `confirm`, and `execute` interface.
- **Benefit**: Allows swapping `rofi` for another UI (e.g., `fzf` or a GUI) without changing menu logic.

---

## Development Workflows

### Adding a New Menu
1. **Define Route**: Add a new symbol and its configuration (class, options key) to `Hyperion::MenuFactory::ROUTES`.
2. **Add Config**: Add the corresponding section to `config/config.yaml`.
3. **Implement Class**: Create the class in `lib/hyperion/menus/`.
    - If it's a simple list of sub-menus, inherit from `PushMenu`.
    - If it executes commands, inherit from `Launcher`.
    - Otherwise, inherit from `Base` and override `handle_selection(selected)`.
4. **Dependency Injection**: If the menu needs a utility (e.g., `ThemeSet`), add it as an optional parameter to the constructor and pass it in `MenuFactory.build`.

### Refactoring Guidelines
- **Surgical Updates**: When modifying a menu, ensure it follows the latest instance-method patterns.
- **Decoupling**: Actively remove any direct `Utilities::X` calls from menus and replace them with injected objects.
- **Standardization**: Use `:prompt` for menu items in `config.yaml` and code.

---

## Testing & Validation

- **Execution**: Always use `bundle exec` to run tests and scripts.
- **Command**: `bundle exec rake test`.
- **Bug Fixes**: You MUST reproduce any reported bug with a new test case in the `test/` directory before applying a fix.
- **Linting**: Ensure code adheres to standard Ruby style (snake_case, 2-space indentation).

---

## Current Priorities & Future Tasks

- [ ] **Refactor `Menus::Theme`**: Currently violates decoupling by accessing `Utilities` directly. It should be refactored to use dependency injection.
- [ ] **Standardize Utilities**: Migrate legacy class methods in `Utilities` to instance methods to facilitate better testing and injection.
- [ ] **Menu Context**: Enhance `MenuFactory` to support passing context (like the current theme) to menus that need it.
- [ ] **View Flexibility**: Ensure all system interactions (e.g., notifications) go through the `@view` adapter.
