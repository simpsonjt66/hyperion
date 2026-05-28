# Decisions

Based on the **Coordinator Pattern** and the refactoring goals outlined in
`GEMINI.md`, the options should be loaded at the **top-level entry point**
(currently `bin/hyperion.rb`) and then passed down through the `Navigator` and
`MenuFactory`.

## Recommendation: Load in the "Bootstrap" Phase

You should load the configuration once where the application starts. Here is
why:

1. **Dependency Injection**: By loading the options at the top level, you can
   inject only the _relevant_ subset of configuration into each menu instance.
   This makes the menus easier to test because you can pass in a mock hash
   instead of requiring a real `config.yaml` file to exist on disk.

2. **Single Responsibility**: The `Menus::Base` class should be responsible for
   _displaying_ and _interacting_ with a menu, not for finding or parsing
   configuration files.
3. **Decoupling**: If you put the loading logic in `Base`, every menu becomes
   coupled to the file system and the specific YAML structure. By centralizing
   it, you only have one place to change if you decide to move the config file
   or switch to a different format (like JSON or TOML).

## How it fits the Target Architecture

In the target state, the flow would look like this:

- **`bin/hyperion.rb`**: Loads `config.yaml` into a hash.
- **`Navigator`**: Receives the full options hash.
- **`MenuFactory`**: Uses the options hash to build specific menus.

  ```ruby
  # Example of how the Factory might use the loaded options
  def self.build(route_symbol, all_options)
    menu_config = ROUTES[route_symbol]
    # Extract only the slice this menu needs (e.g., all_options[:main_menu])
    specific_options = all_options[menu_config[:options_key]]
    menu_config[:class].new(options: specific_options, view: Utilities)
  end
  ```

- **`Menus::Base`**: Simply receives `@options` in its constructor and uses
  them.

## Current Status

Currently, files like `lib/hyperion/menus/main.rb` are accessing the global
`OPTIONS` constant directly. To move toward the new architecture, you should:

1. Move the loading logic into a dedicated method/class (or keep it in
   `bin/hyperion.rb` for now).
2. Update the `Navigator` to take the options as an argument.
3. Transition the menus to use the injected `@options` instead of the global
   `OPTIONS`.

In the new design, the "actions" should be encapsulated within the
`handle_selection` method of your menu classes. However, you are correct that
many of your specific menus (like `System`, `Config`, `Terminal`) are doing
almost identical things.

Here is how we can simplify this using the **Coordinator Pattern**:

### 1. Where do actions happen?

The actions happen in the **Menu Instance**.

- The `Navigator` decides _which_ menu to show.
- The `Menu` decides _what happens_ when an item is clicked.
- The `Menu` returns a "Result Hash" (e.g.,
  `{ action: :push, target: :system }`) to the `Navigator` to tell it what to do
  next.

### 2. Do we still need specific classes?

For most of your menus, **no**. You can consolidate them into three main
patterns:

#### A. The `Submenu` Pattern (e.g., `Main`)

A generic menu where selecting an item pushes a new menu onto the stack.

- **Action**: Returns `{ action: :push, target: :some_symbol }`.
- **Requirement**: A `Submenu` class that looks at its options and maps a
  selection to a route symbol.

#### B. The `CommandMenu` Pattern (e.g., `System`, `Terminal`, `Editor`)

A generic menu where selecting an item runs a shell command and then exits or
stays.

- **Action**: Executes `system(command)`.
- **Requirement**: A `CommandMenu` class that takes a command string or a file
  path (for editors) from its injected options.

#### C. The `DynamicMenu` Pattern (e.g., `Theme`, `Apps`)

These are the only ones that **still need specific classes**.

- **Theme**: Needs logic to fetch the list of themes from the filesystem
  (`ThemeList.get`) and identify the current theme. This can't be purely static
  config.
- **Apps**: Doesn't even use `rofi_select` the same way; it launches
  `rofi -show drun` directly.

### Summary of the New Structure

Instead of 12 classes, you would ideally have:

1. **`Menus::Submenu`**: Used for `Main`. Initialized with options that map
   labels to `:symbols`.
2. **`Menus::Command`**: Used for `System`, `Terminal`, `Browser`, `Package`.
   Initialized with options that contain shell commands.
3. **`Menus::Editor`**: Used for `Config`. A specialized command menu that
   handles path expansion and `launch-editor`.
4. **`Menus::Theme`**: A specialized class for dynamic theme selection.
5. **`Menus::Apps`**: A specialized class for the external app launcher.

**The `MenuFactory` would be the place that knows which class to use:**

```ruby
ROUTES = {
  main:   { class: Menus::Submenu, options_key: :main_menu },
  system: { class: Menus::Command, options_key: :system_menu },
  config: { class: Menus::Editor,  options_key: :config_menu },
  theme:  { class: Menus::Theme,   options_key: nil } # Logic is internal
}
```

This way, the `Navigator` stays clean, the `Base` class provides the shared View
logic, and you eliminate 60-70% of the redundant code.

In the proposed Coordinator Pattern for Hyperion, the responsibility for
instantiation is split to achieve decoupling:

1. **`Navigator`** will instantiate (and hold a reference to) the
   **`MenuFactory`**. The Navigator's role is to manage the stack and
   orchestrate the flow, using the factory to resolve symbols into menu objects.
2. **`MenuFactory`** will instantiate the specific **`Menus::Base`** subclasses
   (e.g., `Menus::Main`, `Menus::System`). It will inject the necessary
   dependencies—like the View adapter and specific configuration—into these
   instances.
3. **`Navigator`** will **not** instantiate `Menus::Base` directly. Instead, it
   will receive a fully configured menu instance from the factory and call its
   `#show` method.

### Proposed Flow

```ruby
# bin/hyperion.rb (High-level view)
factory   = Hyperion::MenuFactory.new(config: OPTIONS, view: Utilities)
navigator = Hyperion::Navigator.new(factory: factory)
navigator.run(:main)

# lib/hyperion/navigator.rb
def run(route)
  @stack << route
  while @stack.any?
    # Navigator asks factory for an instance of the menu
    menu = @factory.create(@stack.last)
    result = menu.show # result is { action: :push, target: :system }

    # ... handle navigation logic ...
  end
end
```

This structure ensures that the `Navigator` doesn't need to know how to build a
menu or what its dependencies are; it only needs to know how to ask the factory
for one and how to interpret the standard return hash.

They **inherit** from it.

In the proposed architecture, `Menus::Base` acts as the **parent class** (or
abstract base) that defines the common behavior for all menus.

To clarify the "Injected vs. Inherited" distinction:

### 1. What is Inherited (`Menus::Base`)

The specialized menus (like `Menus::Submenu` or `Menus::Command`) **inherit**
from `Menus::Base`. This gives them:

- A standard `initialize` method.
- The core `#show` loop logic.
- The `#rofi_select` wrapper.
- The shared return structure (`{ action: ..., target: ... }`).

### 2. What is Injected (Dependencies)

The `MenuFactory` **injects** specific dependencies into the constructors of
those subclasses when it creates them. These include:

- **`options`**: The specific piece of `config.yaml` that this menu needs to
  display.
- **`view`**: The View adapter (the code that actually calls `rofi`). By
  injecting this instead of hardcoding it, you can easily swap the real View for
  a "mock" View during testing.

### Summary

- **Inheritance** is used for **shared code** (logic that is the same for every
  menu).
- **Injection** is used for **variable data** (the config and tools that change
  or need to be swapped).

So, you wouldn't "inject" `Menus::Base` into a menu; rather, a menu **is** a
`Menus::Base` (via inheritance).
