# Coordinator Pattern in Hyperion

The Coordinator (or Router) pattern decouples the menu logic from the navigation flow. 

## Structure

1. **Route Symbols**: Every menu is identified by a symbol (e.g., `:main`, `:system`).
2. **Navigator**: Holds a stack of these symbols.
3. **MenuFactory**: Responsible for converting a symbol into a fully initialized menu object.

## Advantages

- **Decoupling**: Menus don't need to know about other menu classes or global configuration.
- **Testing**: Menus can be unit-tested in isolation by mocking the injected `ui` and `options`.
- **Flexibility**: The navigation logic (push/pop) is centralized in the `Navigator`.

## Implementation Detail

```ruby
module MenuFactory
  ROUTES = {
    main: { class: Menus::Main, options_key: :main_menu },
    # ...
  }

  def self.build(route_name, options_hash, ui_module)
    config = ROUTES[route_name]
    config[:class].new(options: options_hash[config[:options_key]], ui: ui_module)
  end
end
```
