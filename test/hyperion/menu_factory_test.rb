# frozen_string_literal: true

require 'test_helper'
require 'hyperion/menu_factory'
require 'minitest/mock'

describe Hyperion::MenuFactory do
  let(:options_hash) do
    {
      main_menu: [{ prompt: 'Main Item' }],
      system_menu: [{ prompt: 'System Item' }],
      config_menu: [{ prompt: 'Config Item' }],
      package_menu: [{ prompt: 'Package Item' }],
      default_menu: [{ prompt: 'Default Item' }],
      default_editor_menu: [{ prompt: 'Editor Item' }],
      default_browser_menu: [{ prompt: 'Browser Item' }],
      default_terminal_menu: [{ prompt: 'Terminal Item' }]
    }
  end
  let(:mock_view) { Object.new }

  describe '.build' do
    it 'raises ArgumentError for unknown routes' do
      assert_raises(ArgumentError) do
        Hyperion::MenuFactory.build(:invalid_route, options_hash, mock_view)
      end
    end

    it 'instantiates the correct class for a given route' do
      # Testing with :main as a representative case
      mock_instance = Object.new

      Menus::Main.stub :new, mock_instance do
        result = Hyperion::MenuFactory.build(:main, options_hash, mock_view)
        assert_same mock_instance, result
      end
    end

    it 'passes the correct options and view to the menu constructor' do
      # Testing with :system to verify options_key mapping
      Menus::System.stub :new, lambda { |args|
        assert_equal options_hash[:system_menu], args[:options]
        assert_same mock_view, args[:view]
        'mock_system_instance'
      } do
        result = Hyperion::MenuFactory.build(:system, options_hash, mock_view)
        assert_equal 'mock_system_instance', result
      end
    end

    it 'passes an empty array if options_key is nil' do
      # Testing with :apps which has options_key: nil
      Menus::Apps.stub :new, lambda { |args|
        assert_equal [], args[:options]
        assert_same mock_view, args[:view]
        'mock_apps_instance'
      } do
        result = Hyperion::MenuFactory.build(:apps, options_hash, mock_view)
        assert_equal 'mock_apps_instance', result
      end
    end

    it 'passes nil if options_key is present but missing from options_hash' do
      # This test documents current behavior
      Menus::Main.stub :new, lambda { |args|
        assert_nil args[:options]
        'mock_main_instance'
      } do
        result = Hyperion::MenuFactory.build(:main, {}, mock_view)
        assert_equal 'mock_main_instance', result
      end
    end

    it 'verifies that all ROUTES are correctly mapped' do
      Hyperion::MenuFactory::ROUTES.each do |route, config|
        menu_class = config[:class]

        # Stub the specific class's .new method
        menu_class.stub :new, 'mock_instance' do
          result = Hyperion::MenuFactory.build(route, options_hash, mock_view)
          assert_equal 'mock_instance', result
        end
      end
    end
  end

  describe 'ROUTES constant' do
    it 'is a frozen hash' do
      assert Hyperion::MenuFactory::ROUTES.frozen?
      assert_instance_of Hash, Hyperion::MenuFactory::ROUTES
    end

    it 'contains expected keys' do
      expected_keys = %i[main system config package default editor browser terminal apps font theme]
      assert_equal expected_keys.sort, Hyperion::MenuFactory::ROUTES.keys.sort
    end
  end
end
