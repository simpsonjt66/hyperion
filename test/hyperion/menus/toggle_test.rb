# frozen_string_literal: true

require 'test_helper'
require 'lib/hyperion/menus/toggle'

describe Menus::Toggle do
  let(:fake_view) { Minitest::Mock.new }
  let(:toggle_menu) { Menus::Toggle.new(options: nil, view: fake_view) }

  it 'initializes with new' do
    assert_instance_of Menus::Toggle, toggle_menu
  end
end
