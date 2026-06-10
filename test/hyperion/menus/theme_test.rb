# frozen_string_literal: true

require 'test_helper'
require 'hyperion/menus/theme'
require 'hyperion/utilities/theme_repository'

describe Menus::Theme do
  let(:view) { Minitest::Mock.new }
  let(:theme_set) { Minitest::Mock.new }
  let(:repository) { Minitest::Mock.new }
  let(:menu) do
    Menus::Theme.new(
      view: view,
      theme_set: theme_set,
      theme_repository: repository,
      options: []
    )
  end

  describe '#show' do
    it 'displays themes from the repository and sets the selected theme' do
      themes = { 'Nord' => 'nord', 'Catppuccin' => 'catppuccin' }
      repository.expect :all, themes
      repository.expect :all, themes
      repository.expect :all, themes
      repository.expect :current, 'nord'
      repository.expect :current, 'nord'

      view.expect :select, 'Catppuccin', items: themes.keys, current: 'Nord', prompt: 'Select'
      view.expect :notify, nil, ['Theme set to Catppuccin']

      theme_set.expect :call, nil, ['catppuccin']

      result = menu.show

      assert_equal({ action: :exit }, result)
      view.verify
      theme_set.verify
      repository.verify
    end

    it 'returns back action if selection is cancelled' do
      themes = { 'Nord' => 'nord' }
      repository.expect :all, themes
      repository.expect :all, themes
      repository.expect :current, 'nord'
      repository.expect :current, 'nord'

      view.expect :select, nil, items: themes.keys, current: 'Nord', prompt: 'Select'

      result = menu.show

      assert_equal({ action: :back }, result)
      view.verify
    end
  end
end
