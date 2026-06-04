# Design Document

What does an `Application` object look like?

The `Application` object is used to perform actions on a specific external
application.

```ruby
app.name
app.running?
app.toggle
app.start
app.stop
app.restart
```

State is persisted in a file, in `XDG_STATE_HOME/hyperion`

In this instance the `Menu` will show a list of applications, and the current
state of the application, running or not. When selected, the menu will 'toggle'
the external application from it's initial state to the opposite state.

The `Applications` namespace will return all the application objects.

```ruby
module Applications
  def self.all
    [
      Waybar.new,
      Hypridle.new
      Hyprsunset.new
    ]
  end
end
```

# Design Document: Application Management

## Overview

The application currently interacts with several external applications such as:

- Waybar
- Hypridle
- Hyprsunset

The goal is to provide a common interface for managing these applications from
within the menu system.

Initial functionality will focus on:

- Viewing application status
- Starting applications
- Stopping applications
- Restarting applications
- Persisting enabled/disabled state

Future functionality may include:

- Changing fonts
- Changing themes
- Reloading configuration
- Viewing logs
- Changing application-specific settings

---

## Architectural Goals

External applications should encapsulate their own behaviour.

The rest of the application should not need to know:

- How an application is started
- How an application is stopped
- How status is determined
- How application settings are modified

Consumers should interact with application objects through a common interface.

---

## Design Principles

### Explicit Over Dynamic

Applications will be explicitly registered in code.

The application is a personal project with a small number of managed services.

Dynamic discovery introduces unnecessary complexity.

### Behaviour Lives With The Application

Application-specific behaviour belongs in the application class.

Example:

```ruby
Applications::Waybar#change_font
Applications::Hypridle#set_timeout
Applications::Hyprsunset#set_color_temperature
```

The menu system should not contain application-specific logic.

### Common Interface

All managed applications should support a common set of operations.

```ruby
name
running?
start
stop
restart
enabled?
enable
disable
```

---

## Namespace Structure

```ruby
module Applications
end
```

The namespace contains all managed applications.

Example:

```ruby
module Applications
  class Waybar
  end

  class Hypridle
  end

  class Hyprsunset
  end
end
```

---

## Base Application

A common base class may be introduced to share behaviour.

Example:

```ruby
module Applications
  class Base
    def restart
      stop
      start
    end
  end
end
```

Applications inherit from Base when shared behaviour exists.

```ruby
module Applications
  class Waybar < Base
  end
end
```

---

## Application Collection

Applications are exposed through the namespace.

```ruby
module Applications
  def self.all
    [
      Waybar.new,
      Hypridle.new,
      Hyprsunset.new
    ]
  end
end
```

This serves as the application's source of managed applications.

Consumers can iterate through the collection.

```ruby
Applications.all.each do |application|
  puts application.name
end
```

---

## State Persistence

The desired state of each application is persisted.

Example:

```yaml
waybar: true
hypridle: false
hyprsunset: true
```

Meaning:

- true = application should be running
- false = application should not be running

Persisted state is considered the source of truth.

---

## Application Startup

When the application starts:

1. Load persisted state
2. Load all applications from Applications.all
3. Compare desired state with actual state
4. Reconcile differences

Example:

```text
waybar: true

Waybar is not running

Result:
Start Waybar
```

Example:

```text
hypridle: false

Hypridle is running

Result:
Stop Hypridle
```

---

## Menu Interaction

The menu interacts only with application objects.

Example:

```ruby
Applications.all.each do |application|
  menu.add_item(
    application.name,
    enabled: application.enabled?
  )
end
```

When a menu item is selected:

```ruby
application.toggle
```

The menu should not contain:

- process management
- shell commands
- application-specific logic

---

## Future Expansion

Potential future features include:

### Application Settings

```ruby
waybar.change_font(font)
waybar.change_theme(theme)

hypridle.set_timeout(seconds)

hyprsunset.set_color_temperature(value)
```

### Status Reporting

```ruby
application.running?
application.status
```

### Log Viewing

```ruby
application.logs
```

### Configuration Reloading

```ruby
application.reload_configuration
```

---

## Initial Scope

The first implementation should support:

- Applications namespace
- Applications.all
- Waybar application
- Hypridle application
- Hyprsunset application
- Start
- Stop
- Restart
- Running status
- Persisted enabled/disabled state

No additional features should be implemented until the basic application
management workflow is complete.
