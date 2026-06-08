# frozen_string_literal: true

module Menus
  # Menu to toggle certain functionality
  class Toggle < Base
    attr_reader :applications

    def initialize(options:, view:, applications: Applications::Registry.new)
      super(options: options, view: view)
      @applications = applications
    end

    def show
      loop do
        selected = @view.select(**menu_options)
        return { action: :back } if selected.nil?

        handle_selected(selected)
      end
    end

    private

    def handle_selected(selected)
      application_name = selected.gsub(/[^\x21-\x7E]/, '').downcase
      application = applications.all.find { |obj| obj.name == application_name }
      state = application.toggle
      @view.notify("#{application.name.capitalize} #{state}")
    end

    def prompts
      applications.prompts
    end

    def menu_options
      { items: prompts }
    end
  end
end
