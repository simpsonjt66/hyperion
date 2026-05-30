# test/hyperion/menus/base_test.rb
require 'test_helper'
require 'hyperion/menus/base'
require 'minitest/mock'

# Mock class for testing Base
class MockMenu < Menus::Base
  def handle_selection(_selected)
    { action: :exit }
  end
end

describe 'Menus::Base' do
  let(:options) { [{ prompt: 'Test Option', command: 'test_cmd' }] }
  let(:mock_view) { Minitest::Mock.new }

  let(:menu) { MockMenu.new(options: options, view: mock_view) }

  it 'initializes with options and view' do
    mock_view.expect(:==, true, [mock_view])
    _(menu.instance_variable_get(:@options)).must_equal options
    _(menu.instance_variable_get(:@view)).must_equal mock_view
  end

  describe '#show' do
    it 'returns :back when selection is nil (escape)' do
      mock_view.expect :select, nil do |**kwargs|
        kwargs[:items] == ['Test Option'] && kwargs[:prompt] == 'Choose an option'
      end

      result = menu.show

      assert_equal :back, result[:action]
      mock_view.verify
    end

    it 'calls handle_selection and returns its result when selection is made' do
      mock_view.expect :select, 'Test Option' do |**kwargs|
        kwargs[:items] == ['Test Option']
      end

      result = menu.show

      assert_equal :exit, result[:action]
      mock_view.verify
    end
  end
end
