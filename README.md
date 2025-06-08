# macnav

A Keynav-like application for macOS that allows keyboard-based navigation and clicking anywhere on the screen.

This project replicates the functionality of the original Keynav tool, enabling you to quickly navigate to any point on your screen using only keyboard shortcuts. The screen is progressively divided into smaller areas until you reach your target location.

## Features

- ✅ Keynav-style visual overlay with crosshairs
- ✅ Progressive area splitting for precise targeting
- ✅ Area movement without size changes (move actions)
- ✅ Keyboard-only navigation and clicking
- ✅ Global keyboard shortcuts that work across all applications
- ✅ Event interception to prevent key conflicts with other apps
- ✅ Visual feedback with center point highlighting
- ✅ Custom keybinding configuration support

## How It Works

1. **Activate**: Press the global shortcut to show the navigation overlay
2. **Navigate**: Use WASD or HJKL keys to progressively narrow down your target area, or Shift+WASD/HJKL to move the selection
3. **Click**: Press Enter to click at the center of the selected area
4. **Done**: The overlay automatically hides after clicking

Each basic navigation key splits the current area in half:

- **W/K**: Cut to upper half
- **S/J**: Cut to lower half
- **A/H**: Cut to left half
- **D/L**: Cut to right half

Each Shift+navigation key moves the selection area without changing size:

- **Shift+W/K**: Move selection up
- **Shift+S/J**: Move selection down
- **Shift+A/H**: Move selection left
- **Shift+D/L**: Move selection right

## Keyboard Controls

### Global Shortcuts

- **Ctrl+Semicolon**: Toggle the navigation overlay on/off (customizable via .macnav file)

### Default Navigation (when overlay is visible)

#### Area Cutting (splits the selection in half)
- **W** or **K**: Cut to upper half
- **A** or **H**: Cut to left half
- **S** or **J**: Cut to lower half
- **D** or **L**: Cut to right half

#### Area Moving (moves selection without changing size)
- **Shift+W** or **Shift+K**: Move selection up
- **Shift+A** or **Shift+H**: Move selection left
- **Shift+S** or **Shift+J**: Move selection down
- **Shift+D** or **Shift+L**: Move selection right

#### Area Cutting with Control (alternative to basic cutting)
- **Ctrl+W** or **Ctrl+K**: Cut to upper half
- **Ctrl+A** or **Ctrl+H**: Cut to left half
- **Ctrl+S** or **Ctrl+J**: Cut to lower half
- **Ctrl+D** or **Ctrl+L**: Cut to right half

#### Actions
- **Enter** or **Space**: Warp to selected area, left click, and hide overlay
- **1**: Left click at current mouse position
- **2**: Right click at current mouse position
- **3**: Middle click at current mouse position
- **Escape** or **F**: Hide overlay without clicking
- **R**: Reset to full screen
- **M**: Warp mouse cursor to selected area without clicking
- **Q**: Quit application
- **Ctrl+Shift+R**: Reload keybindings from config file

_Note: When the overlay is active, navigation keys are intercepted and won't reach other applications._

## Custom Keybindings

macnav supports custom keybindings through a configuration file, similar to keynav's `.keynavrc`. You can create a `.macnav` file in your home directory to customize the controls.

### Configuration File Format

Create `~/.macnav` with the following format:

```
# Comments start with #
<key> <action>
<key> <action1>,<action2>,<action3>
<modifier+key> <action>
```

Multiple actions can be chained together using commas, following keynav's syntax. For example, `space warp,click 1,end` will first warp the mouse to the selected area, then perform a left click at that position, and finally hide the overlay.

### Available Actions

- `start` - Toggle the overlay on/off (customizable activation shortcut)
- `up`, `down`, `left`, `right` - Cut selection to quadrant (splits in half)
- `move-up`, `move-down`, `move-left`, `move-right` - Move selection area without changing size
- `cut-up`, `cut-down`, `cut-left`, `cut-right` - Cut the selection area (same as basic directional commands)
- `click` - Click at selected area and close overlay (legacy)
- `click 1` - Left click at current mouse position
- `click 2` - Right click at current mouse position
- `click 3` - Middle click at current mouse position
- `end` - Close overlay without clicking
- `reset` - Reset to full screen view
- `warp` - Warp mouse cursor to selected area without clicking
- `quit` - Quit the application
- `reload` - Reload keybindings from .macnav file
- `ignore` - Ignore the key

### Supported Modifiers

- `ctrl+` - Control key
- `shift+` - Shift key
- `alt+` or `option+` - Option/Alt key
- `cmd+` or `super+` - Command key

### Example Configuration

```
# Toggle overlay (keynav default)
ctrl+semicolon start

# Vim-style navigation
h left
j down
k up
l right

# Actions - keynav style with multiple commands
return warp,click 1,end
space warp,click 1,end
escape end
q quit

# Click actions at current mouse position
1 click 1
2 click 2
3 click 3

# Modified keys for cutting
ctrl+w cut-up
ctrl+a cut-left

# Modified keys for moving
shift+w move-up
shift+a move-left

# Other actions
ctrl+c end
```

### Key Names

Use lowercase letters (`a-z`), numbers (`0-9`), or special keys:

- `space`, `return`, `enter`, `escape`, `tab`, `delete`
- `up`, `down`, `left`, `right` (arrow keys)
- `f1`-`f12` (function keys)
- `comma`, `period`, `semicolon`, `quote`, `grave`, `minus`, `equal`
- `leftbracket`, `rightbracket`, `backslash`, `slash`

The configuration file is loaded on startup. You can also reload keybindings during runtime by pressing `Ctrl+R` (or your custom reload binding) while the overlay is active.

### Customizing the Start/Toggle Keybinding

The global shortcut to toggle the overlay can be customized using the `start` action. This allows you to change the activation key from the default `Ctrl+Semicolon` to any combination you prefer:

```
# Examples of custom start keybindings
ctrl+semicolon start           # Default (keynav style)
alt+shift+s start              # Original macnav style
cmd+space start                # Command + Space
f12 start                      # Single function key
ctrl+shift+space start         # Multiple modifiers
```

Multiple start keybindings can be defined if you want several ways to activate the overlay. If no start binding is defined in your `.macnav` file, the default `Ctrl+Semicolon` binding will be used.

## Visual Elements

The overlay displays:

- **Dimmed background**: Covers the entire screen to focus attention
- **Red crosshairs**: Extend across the screen showing the target center
- **Target rectangle**: Red border outlining the current selected area
- **Yellow center dot**: Marks the exact click point

## Building and Running

### Prerequisites

- macOS 12.0 or later
- Xcode Command Line Tools (for Swift compiler)
- **Accessibility permissions** (required for global shortcuts and clicking)

### Granting Accessibility Permissions

For `macnav` to capture global keyboard shortcuts and simulate mouse clicks, you must grant it accessibility permissions:

1. Open **System Settings > Privacy & Security > Accessibility**
2. Click the **+** button to add an application
3. Navigate to the compiled `macnav` executable:
   - Command line build: `.build/debug/macnav` in your project directory
   - Xcode build: Find the app in DerivedData products directory
4. Ensure the checkbox next to `macnav` is checked
5. You may need to unlock with your administrator password

### Command Line Build

```bash
# Clone and navigate to project
git clone <repository-url>
cd macnav

# Build the project
swift build

# Run the application
swift run macnav
```

### Xcode Build (Optional)

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Open in Xcode
open macnav.xcodeproj
```

Then build and run from Xcode using Command+R.

## Usage Example

### Basic Navigation (Area Cutting)
1. **Open any application** (browser, text editor, etc.)
2. **Press Ctrl+Semicolon** - navigation overlay appears
3. **Press A** - cuts to left half of screen
4. **Press W** - cuts to upper half of the left half
5. **Press D** - cuts to right half of that area
6. **Continue cutting** until you reach your desired location
7. **Press Enter** - clicks at that location and hides overlay

### Advanced Navigation (Area Moving)
1. **Press Ctrl+Semicolon** - navigation overlay appears
2. **Press A** then **W** - cut to upper left area
3. **Press Shift+D** - move the selection area to the right without changing size
4. **Press Shift+S** - move the selection area down
5. **Fine-tune position** using more move commands
6. **Press Enter** - clicks at that location and hides overlay

## Troubleshooting

### "Accessibility permissions are not granted"

- Follow the accessibility permissions setup above
- Restart the application after granting permissions

### Navigation keys still type in other applications

- Ensure accessibility permissions are granted
- The app uses CGEventTap to intercept keys when overlay is active

### Click not working

- Verify accessibility permissions include "Control your computer"
- Check that the debug output shows correct coordinates

## Technical Details

- Built with Swift and AppKit
- Uses CGEventTap for global key interception
- Uses CGEvent for simulating mouse clicks
- Requires no external dependencies
