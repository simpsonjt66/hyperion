# New Archtitecture

Based on the **Coordinator Pattern** refactoring plan and the design documents
in `docs/`, here is how the new `Navigator` and `View` classes would be
structured.

### 1. The View Adapter (`lib/hyperion/view/rofi_adapter.rb`)

Following the `docs/view_adapter_design.md`, the View class acts as a decoupled
wrapper around the UI tool (Rofi). This allows for easier testing by injecting a
mock UI during tests.

```ruby
module Hyperion
  module View
    class RofiAdapter
      def initialize(config = {})
        @config = config
      end

      # Standard interface used by all menus
      def select(items:, prompt: 'Select', current: nil)
        # Delegating to existing logic in Utilities
        Utilities.rofi_select(
          items: items,
          prompt: prompt,
          current: current
        )
      end
    end
  end
end
```

### 2. The New Navigator (`lib/hyperion/navigator.rb`)

The new `Navigator` moves away from class-based stacks and instead manages
**route symbols** (like `:main` or `:system`). It uses the `MenuFactory` to
instantiate the appropriate menu with its dependencies.

```ruby
module Hyperion
  class Navigator
    def initialize(initial_route, options, view)
      @stack = [initial_route]
      @options = options
      @view = view
    end

    def run
      while @stack.any?
        route = @stack.last

        # Instantiate the menu using the factory
        menu = MenuFactory.build(route, @options, @view)

        # All menus now respond to instance method .show
        result = menu.show

        case result[:action]
        when :push
          @stack.push(result[:target])
        when :back
          @stack.pop
        when :exit
          @stack.clear
        else
          @stack.clear
        end
      end
    end
  end
end
```

### How they work together in `bin/hyperion.rb`

In the target state, `bin/hyperion.rb` becomes a thin entry point that sets up
the dependencies and kicks off the navigator:

```ruby
# bin/hyperion.rb (Refactored)
require_relative '../lib/hyperion'

# 1. Load configuration
OPTIONS = YAML.load_file(CONFIG_FILE, symbolize_names: true)

# 2. Initialize dependencies
view = Hyperion::View::RofiAdapter.new
initial_route = (ARGV[0] || 'main').to_sym

# 3. Start navigation
Hyperion::Navigator.new(initial_route, OPTIONS, view).run
```

### Key Improvements

1. **Testability**: You can now test the `Navigator` without opening Rofi by
   passing a `MockView`.
2. **Decoupling**: Menus no longer need to know about each other; they simply
   return a `:target` symbol, and the `Navigator` handles the transition via the
   `MenuFactory`.
3. **Consistency**: Every menu follows the same `initialize(options:, view:)`
   signature.
