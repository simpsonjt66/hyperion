# UI Adapter Design & TDD Strategy

This document captures the design rationale for injecting a UI adapter into Hyperion's menu classes to facilitate Test-Driven Development (TDD) and ensure the system remains decoupled from specific UI implementations (like `rofi`).

## The Problem
Menus currently call `Utilities.rofi_select` directly. This makes it impossible to unit test menus without actually triggering a Rofi window, and it tightly couples the business logic of a menu to a specific CLI tool.

## The Solution: UI Adapter Pattern
Instead of calling a global utility, every menu receives a `ui` object during initialization. This object acts as a thin adapter that provides a consistent interface.

### 1. The Interface
The `ui` object must respond to a `.select` method:

```ruby
# Example of a Rofi Adapter instance
module UI
  class RofiAdapter
    def initialize(config = {})
      @config = config
    end

    def select(items:, prompt: 'Select', current: nil)
      Utilities.rofi_select(
        items: items, 
        prompt: prompt, 
        current: current
      )
    end
  end
end
```

### 2. Dependency Injection in `Menus::Base`
The base class accepts the adapter and uses it in the "Select" phase of the "Fetch -> Select -> Act" pattern.

```ruby
module Menus
  class Base
    def initialize(options:, ui:)
      @options = options
      @ui = ui
    end

    def show
      items = fetch_items 
      selected = @ui.select(items: items, prompt: "Choose an option")
      
      return { action: :back } if selected.nil?
      handle_selection(selected)
    end
  end
end
```

## Why Instance Methods over Class Methods?

For TDD, **instances are superior to class methods** for several reasons:

1.  **Isolated Testing:** You can pass a "Mock" or "Double" object into the menu during a test without affecting the global state of the application or other tests.
2.  **Duck Typing:** `Menus::Base` doesn't care if it's a `RofiAdapter`, an `FzfAdapter`, or a `MockUI`. It only cares that the object responds to `.select`.
3.  **State Management:** Instances allow you to store session-specific configuration (like themes or timeout settings) without polluting global constants.

## TDD Example
Using an instance-based adapter makes testing edge cases (like pressing Escape) trivial:

```ruby
# A simple mock for testing
class MockUI
  attr_accessor :stubbed_selection

  def select(items:, **_args)
    @stubbed_selection
  end
end

def test_menu_returns_back_on_escape
  ui = MockUI.new
  ui.stubbed_selection = nil # Simulate Escape/Cancel
  
  menu = Menus::Base.new(options: [], ui: ui)
  result = menu.show
  
  assert_equal :back, result[:action]
end
```

## Future Proofing
If Hyperion ever switches to another UI tool (e.g., `fzf` or `gum`), only a new adapter needs to be written. The logic within the `Menus` module remains completely untouched.
