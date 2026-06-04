# Feature: Toggle functionality off and on from the menu

## Problem

The user can turn certain functionality off and on. Either to restart it or have
it not interfere with their workflow. The user can to do that from the existing
menu application.

## User Story

- As a user, I want to to restart `waybar` to accept a change I made to it.

- As a user, I want to to turn off `waybar` to allow another application to run
  full screen.

- As a user, I want to turn off `hypridle` to allow me to watch a video
  uninterrupted.

- As a user, I want to turn off `hypridle` to allow a system upgrade to complete
  without system suspending.

- As a user, I want to turn on the sunset feature of `hyprsunset` to reduce the
  amount of blue light on my laptop display.

## Success Criteria

- Can turn off and on `waybar` or any other bar that I may use in the future.
- Can turn off and on `hyprsunset` to change the colors of my laptop screen.
- Can turn off and on the timer that locks the screen and suspends the system.

## Out of scope

## Behaviour

When `waybar` is selected The status bar at the top of my laptop screen turns
off.

When I reboot my laptop, the last status should be preserved.

When `hyprsunset` is selected The color depth of my laptop display changes.

When `hypridle` is selected The timer that locks my screen when it expires is
suspended.

### Domain Model

- Toggleable
- Service
- Service State

### Domain objects

Application

Examples:

- Waybar
- Hypridle
- Hyprsunset

An application can:

- start
- stop
- restart
- report status

Some applications may also:

- change font
- change theme
- change timeout
- change colour temperature

### Nouns

- Service
- Process
- State
- Toggle

### Verbs

- toggle
- switch
- start
- stop
- change
- persist

### Implementation

Manage external applications from a menu.

### Acceptance Tests

- [ ] User can view all toggleable services.
- [ ] User can see whether each service is enabled or disabled.
- [ ] User can toggle a service.
- [ ] User can restart a service.
- [ ] Service state survives a reboot.
- [ ] Adding a new service requires minimal code change.

### UI

Services

- [x] Waybar
- [ ] Hypridle
- [x] Hyprsunset

Select Waybar

Result:

- Waybar Stops
- Menu Updates

- [ ] Waybar
- [ ] Hypridle
- [x] Hyprsunset

### Architectural Goal

External applications should encapsulate their own behaviour.

The rest of the application should not need to know how Waybar, Hypridle, or
Hyprsunset are started, stopped, configured, or queried.

All interactions should occur through application objects.### Notes

### Notes

The thinking that this functionality has exposed, is that any external
application I interact with, should have it's own class. Then any actions needed
to be taken on the class could be implemented there. Restarting, changing fonts,
checking status. I need a namespace for where the applications will live.

`Hyprland autostart` will need to review the toggle states of the applications
on restart.

Waybar

- start
- stop
- restart
- change font
- change theme

Hyprsunset

- start
- stop
- restart
- change color temperature

Hypridle

- start
- stop
- restart
- change timeout

## Future Features

- Restart service
- View service status
- View logs
- Reload configuration
- Change service settings

### Open Questions

- How is state persisted?
- Is the application the source of truth?
- Or is the running process the source of truth?
