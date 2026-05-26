# Current Observations

1. Redundancy: Most menu classes (System, Config, Package, Browser, Editor,
   Terminal) share almost identical logic for fetching options, mapping prompts,
   calling rofi_select, and handling the result.
2. Inconsistent Navigation: Most menus return { action: :back } on
   escape/cancel, but Main returns { action: :exit }.
3. Inconsistent Configuration Keys: The config.yaml uses :name for the main menu
   but :prompt for submenus.
4. Bug Found: In menus/editor.rb, there is a bug where { action: exit } is used
   instead of { action: :exit }. Since exit is a Kernel method, this causes the
   application to terminate immediately rather than returning a status to the
   navigator.
5. Coupling: Menus are tightly coupled to the global OPTIONS constant and the
   Utilities module.

## Proposed Refactorings

1. Core Architecture:
   Menus::Base Introduce a base class to encapsulate the common "fetch -> select
   -> act" pattern. This will reduce boilerplate in each menu file by about
   60-70%.

2. Specialized Menu Handlers Create standard handlers for common actions:
   - CommandMenu: For menus that simply execute a system command (e.g., Browser,
     Editor, Terminal).
   - ConfigMenu: Specifically for opening configuration files in an editor.
   - SubMenu: For menus that navigate to other menu classes.

3. Standardize Navigator
   Move the Navigator class from launcher_helper.rb into
   lib/hyperion/navigator.rb to keep the entry point clean and make the
   navigation logic more robust.

4. Improve Utilities
   - Refactor Utilities::ThemeSet to use instance methods and clearer
     step-by-step logic.
   - Make Utilities.rofi_select more robust (e.g., handling empty item lists).

5. Graceful Config Handling
   Update the base class to handle both :name and
   :prompt keys gracefully, so the existing config.yaml doesn't need immediate
   changes, but remains consistent.

Immediate Fix I noticed a critical bug in menus/editor.rb:

1. Current menus/editor.rb:15 2 { action: exit } # This calls Kernel.exit
   immediately! It should be:{ action: :exit }

To handle sub-menus like Main without maintaining coupling, you can shift the
responsibility of instantiating the next menu to a central coordinator or a
factory.

Here are two ways to solve the "injection in sub-menus" problem:

1. The Coordinator (Router) Pattern In this approach, menus never return a class
   or instance. They return a Symbol or a Command Object representing where they
   want to go. The main loop in launcher_helper.rb then acts as a "Router."

How it would look in Main:

    1 def show
    2   selected = @ui.rofi_select(items: @options.map { |i| i[:name] })
    3   return { action: :exit } if selected.nil?
    4
    5   # Find the metadata for the selection
    6   target_key = @options.find { |i| i[:name] == selected }[:command]
    7
    8   # Return a "route" instead of a class
    9   { action: :push, route: target_key.to_sym }

10 end

How it works in launcher_helper.rb: The launcher maintains a MenuFactory that
knows how to build any menu by its key.

     # The central loop
     stack = [:main] # Start with the main route

     while route = stack.last
       menu = MenuFactory.build(route) # Factory injects OPTIONS[route] and Utilities
       result = menu.show

       case result[:action]
         when :push then stack.push(result[:route])
         when :back then stack.pop
         when :exit then break
       end
     end

1. The Menu Factory Injection
   If you want the menus to stay in control of what they launch, you inject a Factory
   into every menu.

How it would look in Main:

    class Main
      def initialize(options:, factory:)
        @options = options
        @factory = factory
      end

      def show
       # ... selection logic ...

       # Ask the factory to create the instance for the next menu
       # The factory handles the injection of OPTIONS and UI
      next_menu = @factory.build(target_name)

      { action: :push, target: next_menu }
      end
    end

Which one is better? I recommend The Coordinator Pattern (Option 1) for this
project because:

1. Centralized Config: All knowledge of which menu gets which OPTIONS key stays
   in one place (the MenuFactory or Router).
2. Serialized State: It makes it easier to track the "path" of the user (e.g.,
   [:main, :system]) rather than holding a stack of live objects.
3. Ease of Testing: You can test Main by asserting it returns { action: :push,
   route: :system } without actually having to instantiate the System menu
   during the test.

How to implement the Factory? A simple version of the MenuFactory might look
like this:

     module MenuFactory
       # Mapping routes to Classes and their specific OPTIONS key
       ROUTES = {
         main:    { class: Menus::Main,    options: :main_menu },
         system:  { class: Menus::System,  options: :system_menu },
         browser: { class: Menus::Browser, options: :default_browser_menu }
       }

      def self.build(route_key)
        config = ROUTES[route_key]
        config[:class].new(
          options: OPTIONS[config[:options]],
          ui: Utilities
         )
      end
     end

This way, Main doesn't need to know that System exists or that it needs certain
options; it just knows it wants to navigate to :system.

Current Navigator implementation is perfectly suited for this refactoring. In
fact, the "Coordinator" (or Router) pattern I suggested is essentially an
evolution of your existing Navigator class.

Here is how the decoupling would work while preserving your escape/back logic:

1. The MenuFactory (The new "Source of Truth") Instead of every menu knowing
    about the global OPTIONS hash and the Menus module, we move that knowledge
    into a single factory. This factory’s only job is to "build" a menu instance
    with the correct data.

         module MenuFactory
           # Map routes to Classes and their specific OPTIONS key
           ROUTES = {
           main: { class: Menus::Main, options_key: :main_menu },
           system: { class: Menus::System, options_key: :system_menu },
           browser: { class: Menus::Browser, options_key: :default_browser_menu }
           }

           def self.build(route_name)
             config = ROUTES[route_name.to_sym]
             raise "Unknown menu: #{route_name}" unless config

             # Inject only what the menu needs
             config[:class].new(
             options: OPTIONS[config[:options_key]],
             ui: Utilities
             )
           end
         end

1. Updating Navigator in launcher_helper.rb The Navigator remains almost the
    same, but it stores Route Symbols (like :main or :system) on its stack
    instead of Classes. This allows it to use the factory to inject dependencies
    every time a menu is shown.

        class Navigator
          def initialize(start_route)
            @stack = [start_route.to_sym]
          end

          def run
            while @stack.any?
            # The factory handles the injection of OPTIONS and Utilities
            current_menu = MenuFactory.build(@stack.last)
            result = current_menu.show

              case result[:action]
                when :push
                  @stack.push(result[:route]) # Now returns a Symbol, e.g., :system
                when :back
                  @stack.pop
                when :exit
                  @stack.clear
                else
                  @stack.clear
                end
              end
             end
         end

1. How the Menus Change The menus become "Pure" classes. They don't care where
    the data comes from or what UI tool is used.

Old Main.show (Coupled):

    def self.show
      menu_options = OPTIONS[:main_menu] # Tight coupling
      # ...
      target = Menus.const_get(launch_command) # Fragile logic
      { action: :push, target: target }
    end

New Main.show (Decoupled):

    class Main
      def initialize(options:, ui:)
        @options = options
        @ui = ui
      end

      def show
        prompts = @options.map { |item| item[:name] }
        selected = @ui.rofi_select(items: prompts)

        return { action: :exit } if selected.nil? # Esc handling remains same

        # Simply return the symbol for the next menu
        route = @options.find { |item| item[:name] == selected }[:command].downcase.to_sym
        { action: :push, route: route }
      end
     end

Why this is still viable for Escapes: Your existing escape logic relies on the
menu returning :back or :exit when rofi_select returns nil.

- In the decoupled version, the menu still detects the nil from the injected @ui
  and returns the exact same :back or :exit signal.
- The Navigator still manages the @stack the same way.

Key Improvements:

1. No const_get: You no longer need to translate strings to classes inside your
   menus.
2. Safety: launcher_helper.rb no longer does const_get on ARGV[0], which is a
   security and stability improvement.
3. Testability: You can now test your menus by passing in a simple array of
   options and a mock UI, without ever launching Rofi or loading your full YAML
   config.
