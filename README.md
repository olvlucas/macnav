# macnav

A Keynav-like application for macOS that allows keyboard-based navigation and clicking anywhere on the screen.

This project replicates the functionality of the original Keynav tool, enabling you to quickly navigate to any point on your screen using only keyboard shortcuts. The screen is progressively divided into smaller areas until you reach your target location.

## Features

- ✅ Keynav-style visual overlay with crosshairs
- ✅ Progressive area splitting for precise targeting
- ✅ Keyboard-only navigation and clicking
- ✅ Global keyboard shortcuts that work across all applications
- ✅ Event interception to prevent key conflicts with other apps
- ✅ Visual feedback with center point highlighting

## How It Works

1. **Activate**: Press the global shortcut to show the navigation overlay
2. **Navigate**: Use WASD or HJKL keys to progressively narrow down your target area
3. **Click**: Press Enter to click at the center of the selected area
4. **Done**: The overlay automatically hides after clicking

Each navigation key splits the current area in half:

- **W/K** (Up): Select the upper half
- **S/J** (Down): Select the lower half
- **A/H** (Left): Select the left half
- **D/L** (Right): Select the right half

## Keyboard Controls

### Global Shortcuts

- **Option+Shift+S**: Toggle the navigation overlay on/off

### Default Navigation (when overlay is visible)

- **W** or **K**: Move to upper half
- **A** or **H**: Move to left half
- **S** or **J**: Move to lower half
- **D** or **L**: Move to right half
- **Enter** or **Space**: Click at the center of selected area and hide overlay
- **Escape** or **F**: Hide overlay without clicking
- **R**: Reset to full screen
- **Q**: Quit application

_Note: When the overlay is active, navigation keys are intercepted and won't reach other applications._

## Custom Keybindings

macnav supports custom keybindings through a configuration file, similar to keynav's `.keynavrc`. You can create a `.macnav` file in your home directory to customize the controls.

### Configuration File Format

Create `~/.macnav` with the following format:

```
# Comments start with #
<key> <action>
<modifier+key> <action>
```

### Available Actions

- `up`, `down`, `left`, `right` - Move selection in quadrants
- `click` - Click at selected area and close overlay
- `end` - Close overlay without clicking
- `reset` - Reset to full screen view
- `warp` - Warp to selected area
- `cut-up`, `cut-down`, `cut-left`, `cut-right` - Cut the selection area (planned)
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
# Vim-style navigation
h left
j down
k up
l right

# Actions
return click
space click
escape end
q quit

# Modified keys
shift+w cut-up
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

1. **Open any application** (browser, text editor, etc.)
2. **Press Option+Shift+S** - navigation overlay appears
3. **Press A** - selects left half of screen
4. **Press W** - selects upper half of the left half
5. **Press D** - selects right half of that area
6. **Continue navigating** until you reach your desired location
7. **Press Enter** - clicks at that location and hides overlay

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
