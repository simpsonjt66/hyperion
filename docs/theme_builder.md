## Project Overview

This is an app that will build theme files for certain applications if they do not currently exist in a theme folder. It ensures that all the apps I use have a common look and feel when I select a new colorscheme. Inspired by, if not completely plagiarized from Omarchy.

The app is built in ruby.

## Core Goals

The app must detect if a file `colors.toml` exists. If it does not, a file called `alacritty.toml` must exist. If it does, then the app builds a `colors.toml` file extracting data from the `alacritty.toml` file.  It then processes a list of template files and builds colorscheme files for the applications in the template.

- Tests if a `colors.toml` file exists.
- Tests if an `alacritty.toml` file exists.
- Builds a `colors.toml` file from the `alacritty.toml` file.
- Applies that `colors.toml` file to various template files.
- Moves those files into the `~/.local/share/hyperion/current/theme/` folder.

## Feature Specifications

### Purpose 
Quickly build colorscheme files for apps that do not have an existing colorscheme file.

### Inputs
- Theme switch

### Outputs
- `colors.toml` file.
- Various applications colorscheme files based on the templates in the templates directory.

### UI Behaviour
- Background process, only user notification is when the full theme switch event is completed.

### Edge Cases  
- No `alacritty.toml` file.
- Present `colors.toml` file and no other application files.

### File/Directory Layout
```text
~/.local/share/hyperion/
       current/
       themes/
       templates/

~/.local/lib/hyperion
       menus/
       utitlities/
       
```

### Future Improvements

```text 
New theme selected
  -->
Checks for presence of colors.toml
  -->
If missing, checks for presence of alacritty.toml
  -->
Extracts colors from alacritty file
  --> 
Builds colors.toml file
  -->
Builds configuration files for all files with templates
  -->
Adds those files to the current theme folder.
```

## TODO/Backlog

- [ ] Move `current.theme` up to parent directory.
- [ ] Decide on location for templates folder.
- [ ] 

### Blocked

- Should it populate the permanent theme folder as well as the transient current theme folder?
- Should it have a transitional state folder like the do in Omarchy? They build a `NextTheme` folder, assemble everything in there, then move it to the `CurrentTheme` folder.
```

