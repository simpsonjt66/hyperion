# test/hyperion/menus/base_test.rb
require 'test_helper'
require 'hyperion/menus/base'
require 'minitest/mock'

describe 'Menus::Base' do
  let(:options) { [{ prompt: 'Test Option', command: 'test_cmd' }] }
  let(:mock_ui) { Minitest::Mock.new }

  let(:menu) { Menus::Base.new(options: options, ui: mock_ui) }

  it 'initializes with options and ui' do
    mock_ui.expect(:==, true, [mock_ui])
    _(menu.instance_variable_get(:@options)).must_equal options
    _(menu.instance_variable_get(:@ui)).must_equal mock_ui
  end

  describe '#show' do
    it 'returns :back when selection is nil (escape)' do
      mock_ui.expect :rofi_select, nil, [{ items: ['Test Option'] }]

      result = menu.show

      assert_equal :back, result[:action]
      mock_ui.verify
    end
  end
end
