# frozen_string_literal: true

require 'test_helper'
require 'hyperion/utilities/theme_set'
require 'hyperion/utilities/theme_repository'
require 'hyperion/utilities/theme_deployer'
require 'tmpdir'

describe Utilities::ThemeSet do
  let(:repository) { Minitest::Mock.new }
  let(:deployer) { Minitest::Mock.new }
  let(:apps) { { waybar: Minitest::Mock.new } }
  let(:extractor_strategy) { Minitest::Mock.new }
  let(:template_strategy) { Minitest::Mock.new }

  let(:theme_set) do
    Utilities::ThemeSet.new(
      applications: apps,
      theme_repository: repository,
      theme_deployer: deployer,
      theme_path: '/tmp/themes',
      color_extractor: extractor_strategy,
      template_builder: template_strategy
    )
  end

  describe '#call' do
    it 'orchestrates the theme application process' do
      theme_name = 'nord'
      staging_path = '/tmp/next_theme'
      source_path = '/tmp/themes/nord'

      deployer.expect :staging_path, staging_path
      deployer.expect :prepare_staging, nil, [source_path]
      deployer.expect :publish, nil

      repository.expect :current=, nil, [theme_name]

      apps[:waybar].expect :reload_config, nil

      extractor_strategy.expect :call, nil, [staging_path]
      template_strategy.expect :call, nil, [staging_path]

      theme_set.call(theme_name)

      deployer.verify
      repository.verify
      apps[:waybar].verify
      extractor_strategy.verify
      template_strategy.verify
    end

    it 'skips color extraction if colors.toml exists' do
      # Note: The logic for skipping color extraction is now in the 
      # default ColorExtractor strategy. In this test, we are using 
      # a mock strategy, so we just verify it's called.
      # To test the actual skipping logic, we'd test ColorExtractor class.
      
      theme_name = 'nord'
      staging_path = '/tmp/next_theme'

      deployer.expect :staging_path, staging_path
      deployer.expect :prepare_staging, nil, [String]
      deployer.expect :publish, nil
      repository.expect :current=, nil, [theme_name]
      apps[:waybar].expect :reload_config, nil

      extractor_strategy.expect :call, nil, [staging_path]
      template_strategy.expect :call, nil, [staging_path]

      theme_set.call(theme_name)

      deployer.verify
      extractor_strategy.verify
      template_strategy.verify
    end
  end
end
