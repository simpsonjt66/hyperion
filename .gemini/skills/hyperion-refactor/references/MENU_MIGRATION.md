# Menu Migration Guide

Follow this guide to migrate an old "coupled" menu to the new decoupled
architecture.

## Step 1: Initialize the class

Ensure the class can be initialized with `options` and `view`.

```ruby
class MyMenu < Menus::Base
  def initialize(options:, view:)
    @options = options
    @view = view
  end
end
```

## Step 2: Convert `show` to an instance method

Change `def self.show` to `def show`.

## Step 3: Replace Globals

- Replace `OPTIONS[:key]` with `@options`.
- Replace `Utilities.rofi_select` with `@view.rofi_select`.

## Step 4: Handle Selection

The `rofi_select` method returns `nil` if the user cancels. Ensure this is
handled.

```ruby
def show
  selected = @view.rofi_select(items: @options.map { |i| i[:name] })
  return { action: :back } if selected.nil?

  # Logic to determine next route
  { action: :push, route: :new_route }
end
```

## Step 5: Register in Factory

Add the entry to `lib/hyperion/menu_factory.rb`.
