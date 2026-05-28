---
name: hyperion-refactor
description:
  Specialized guidance for refactoring the Hyperion Ruby CLI, focusing on the
  Coordinator Pattern, dependency injection, and menu decoupling.
---

# Hyperion Refactor Skill

This skill provides procedural knowledge for refactoring Hyperion's menu and
navigation system.

## Coordinator Pattern Workflow

When refactoring a menu or the navigator, follow these steps:

1. **Identify the Route**: Define a unique symbol for the menu (e.g., `:system`,
   `:package`).
2. **Update the Factory**: Add the route to `MenuFactory::ROUTES` in
   `lib/hyperion/menu_factory.rb`.
3. **Decouple the Menu**:
   - Ensure the menu class inherits from `Menus::Base` (once implemented).
   - Change class methods (`self.show`) to instance methods (`show`).
   - Use `@options` and `@view` instead of `OPTIONS` and `Utilities`.
4. **Standardize Actions**:
   - Return `{ action: :push, route: :target_route }` for submenus.
   - Return `{ action: :back }` for cancellations (nil selection).
   - Return `{ action: :exit }` for the main menu's exit.
5. **Update Navigator**: Ensure the navigator handles the `:route` symbol
   instead of raw classes.

## Reference Materials

- [COORDINATOR_PATTERN.md](references/COORDINATOR_PATTERN.md): Detailed
  explanation of the pattern.
- [MENU_MIGRATION.md](references/MENU_MIGRATION.md): Step-by-step guide for
  migrating an old menu.

## Quality Standards

- No direct access to global `OPTIONS`.
- No direct access to `Utilities` from within menu logic (inject it).
- All rofi selections must handle `nil` (Escape key).
- Unit tests should mock the `view` object.
