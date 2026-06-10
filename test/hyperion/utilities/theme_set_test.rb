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

   let(:theme_set) do
     Utilities::ThemeSet.new(
       applications: apps,
       theme_repository: repository,
       theme_deployer: deployer,
       theme_path: '/tmp/themes'
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

       extractor_mock = Minitest::Mock.new
       extractor_mock.expect :extract, nil

       template_mock = Minitest::Mock.new
       template_mock.expect :build_config_files, nil

       # We need to stub the lambdas
       theme_set.instance_variable_set(:@color_extractor, ->(path) {
         assert_equal staging_path, path
         extractor_mock
       })
       theme_set.instance_variable_set(:@template_builder, ->(path) {
         assert_equal staging_path, path
         template_mock
       })

       # Mock File.exist? for colors.toml check
       File.stub :exist?, false do
         theme_set.call(theme_name)
       end

       deployer.verify
       repository.verify
       apps[:waybar].verify
       extractor_mock.verify
       template_mock.verify
     end

     it 'skips color extraction if colors.toml exists' do
       theme_name = 'nord'
       staging_path = '/tmp/next_theme'

       deployer.expect :staging_path, staging_path
       deployer.expect :prepare_staging, nil, [String]
       deployer.expect :publish, nil
       repository.expect :current=, nil, [theme_name]
       apps[:waybar].expect :reload_config, nil

       template_mock = Minitest::Mock.new
       template_mock.expect :build_config_files, nil

       theme_set.instance_variable_set(:@template_builder, ->(_) { template_mock })

       # Mock File.exist? to return true for colors.toml
       original_exist = File.method(:exist?)
       File.stub :exist?, ->(path) { path.end_with?('colors.toml') ? true : original_exist.call(path) } do
         theme_set.call(theme_name)
       end

       deployer.verify
       template_mock.verify
     end
   end
 end
