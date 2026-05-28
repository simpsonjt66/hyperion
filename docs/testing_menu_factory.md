To test the `MenuFactory`, you should create a new test file at
`test/hyperion/menu_factory_test.rb`.

Since the factory's job is to instantiate the correct classes with the right
dependencies, the test should verify that:

1. It returns an instance of the expected class for a given route.
2. It correctly extracts the relevant options from the global configuration
   hash.
3. It injects the `view` object.

### Recommended Test: `test/hyperion/menu_factory_test.rb`

```ruby
# frozen_string_literal: true

require 'test_helper'
require 'hyperion/menu_factory'
require 'minitest/mock'

describe Hyperion::MenuFactory do
  let(:mock_options) do
    {
      main_menu: [{ name: 'Apps', command: 'apps' }],
      system_menu: [{ prompt: 'Lock', command: 'lock' }]
    }
  end
  let(:mock_view) { Minitest::Mock.new }

  describe '.build' do
    it 'instantiates the Main menu with correct options' do
      menu = Hyperion::MenuFactory.build(:main, mock_options, mock_view)

      _(menu).must_be_instance_of Menus::Main
      _(menu.instance_variable_get(:@options)).must_equal mock_options[:main_menu]
      _(menu.instance_variable_get(:@view)).must_equal mock_view
    end

    it 'instantiates the System menu with correct options' do
      menu = Hyperion::MenuFactory.build(:system, mock_options, mock_view)

      _(menu).must_be_instance_of Menus::System
      _(menu.instance_variable_get(:@options)).must_equal mock_options[:system_menu]
    end

    it 'returns empty options if options_key is nil' do
      menu = Hyperion::MenuFactory.build(:theme, mock_options, mock_view)

      _(menu).must_be_instance_of Menus::Theme
      _(menu.instance_variable_get(:@options)).must_be_empty
    end

    it 'raises ArgumentError for unknown routes' do
      assert_raises(ArgumentError) do
        Hyperion::MenuFactory.build(:invalid_route, mock_options, mock_view)
      end
    end
  end
end
```

### How to run the tests

You can run this specific test file using `rake` or directly with `ruby`:

```bash
# Using ruby directly
ruby -Ilib:test test/hyperion/menu_factory_test.rb

# Or using rake if configured
rake test TEST=test/hyperion/menu_factory_test.rb
```

### Note on Menu Classes

For this test to pass, your menu classes (like `Menus::Main`) must already have
been updated to inherit from `Menus::Base` and support the
`initialize(options:, view:)` signature. If they are still using the old
`self.show` class method pattern, the factory will fail when calling `.new`.
