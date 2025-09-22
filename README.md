# macnav

A Keynav-like application for macOS that allows keyboard-based navigation and clicking anywhere on the screen.

<div align="center">
  <img src="https://github.com/user-attachments/assets/50b5f6fe-9e97-4232-8c01-1eded44ee3cb" alt="macnav demo">
</div>

This project replicates the functionality of the original Keynav tool, enabling you to quickly navigate to any point on your screen using only keyboard shortcuts. The screen is progressively divided into smaller areas until you reach your target location.

## Features

- ✅ Keynav-style visual overlay with crosshairs
- ✅ Progressive area splitting for precise targeting
- ✅ Area movement without size changes (move actions)
- ✅ Keyboard-only navigation and clicking
- ✅ Global keyboard shortcuts that work across all applications
- ✅ Event interception to prevent key conflicts with other apps
- ✅ Visual feedback with center point highlighting
- ✅ Cursor zoom functionality for precise targeting (keynav-style)
- ✅ Custom keybinding configuration support
- ✅ Multi-monitor support with intelligent screen detection

## How It Works

1. **Activate**: Press the global shortcut to show the navigation overlay
2. **Navigate**: Use WASD or HJKL keys to progressively narrow down your target area, or Shift+WASD/HJKL to move the selection
3. **Zoom** (optional): Press C to create a zoom overlay around your current selection for more precise targeting
4. **Click**: Press Enter to click at the center of the selected area
5. **Done**: The overlay automatically hides after clicking

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

#### Monitor Switching (multi-monitor setups)
- **Ctrl+Shift+A** or **Ctrl+Shift+H**: Switch to monitor to the left
- **Ctrl+Shift+D** or **Ctrl+Shift+L**: Switch to monitor to the right
- **Ctrl+Shift+W** or **Ctrl+Shift+K**: Switch to monitor above
- **Ctrl+Shift+S** or **Ctrl+Shift+J**: Switch to monitor below

#### Scrolling Actions
- **Up Arrow**: Scroll up at current mouse position
- **Down Arrow**: Scroll down at current mouse position
- **U**: Scroll up at current mouse position
- **Ctrl+U**: Scroll up at current mouse position (vim-style)
- **Ctrl+D**: Scroll down at current mouse position (vim-style)

#### Cursor Zoom
- **C** or **Period**: Create a zoom overlay centered around current selection (200x200 default)
- Custom zoom sizes can be configured in `.macnav` file (e.g., `c cursorzoom 300 250`)

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
- `monitor-left` - Switch to monitor to the left
- `monitor-right` - Switch to monitor to the right
- `monitor-up` - Switch to monitor above
- `monitor-down` - Switch to monitor below
- `ignore` - Ignore the key
- `scroll-up` - Scroll up at current mouse position
- `scroll-down` - Scroll down at current mouse position
- `cursorzoom` - Create a zoom overlay centered around current selection with specified width and height

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

# Monitor switching (for multi-monitor setups)
ctrl+shift+a monitor-left
ctrl+shift+h monitor-left
ctrl+shift+d monitor-right
ctrl+shift+l monitor-right
ctrl+shift+w monitor-up
ctrl+shift+k monitor-up
ctrl+shift+s monitor-down
ctrl+shift+j monitor-down

# Scroll actions
up scroll-up
down scroll-down
u scroll-up
ctrl+u scroll-up
ctrl+d scroll-down

# Cursor zoom - create zoom overlay around current selection
c cursorzoom 200 200
period cursorzoom 300 250

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

## Installation

### Download from GitHub Releases (Recommended)

The easiest way to install macnav is to download a pre-built release:

1. Go to the [Releases page](https://github.com/olvlucas/macnav/releases)
2. Download the latest release:
   - **macnav-X.X.X.dmg** - Drag and drop installer (recommended for most users)
   - **macnav-X.X.X-macos.zip** - Contains the app bundle
   - **macnav-X.X.X-macos.tar.gz** - Contains the command-line binary

#### Using the DMG (Recommended)
1. Download and open the `.dmg` file
2. Drag `macnav.app` to your Applications folder
3. **Right-click** on the app and select **"Open"** (bypasses Gatekeeper warning)
4. Grant accessibility permissions when prompted

#### Using the ZIP Archive
1. Download and extract the `.zip` file
2. Move `macnav.app` to your Applications folder
3. **Right-click** on the app and select **"Open"** (bypasses Gatekeeper warning)
4. Grant accessibility permissions when prompted

### Command Line Installation

If you prefer command-line tools or want to build from source:

#### Install via Make (requires source code)
```bash
# Clone the repository
git clone https://github.com/olvlucas/macnav.git
cd macnav

# Build and install to /usr/local/bin
make install

# Run from anywhere
macnav
```

#### Install Binary Only
```bash
# Download and extract the binary
curl -L https://github.com/olvlucas/macnav/releases/latest/download/macnav-X.X.X-macos.tar.gz | tar xz

# Move to your PATH
sudo mv macnav /usr/local/bin/

# Run from anywhere
macnav
```

### Homebrew (Future)

Homebrew support is planned for future releases:
```bash
# Coming soon
brew install macnav
```

### Requirements

- **macOS 12.0 or later** (supports both Intel and Apple Silicon Macs)
- **Accessibility permissions** (required for global shortcuts and clicking)

### Granting Permissions

⚠️ **Important**: macnav requires accessibility permissions to function properly.

After installation, you'll need to grant accessibility permissions:

1. **Launch macnav** (it will prompt for permissions)
2. Open **System Settings → Privacy & Security → Accessibility**
3. Click the **+** button to add an application
4. Navigate to and select:
   - **App Bundle**: `/Applications/macnav.app`
   - **Command Line**: `/usr/local/bin/macnav`
5. Ensure the checkbox next to macnav is **checked**
6. **Restart macnav** if it was already running

### Verification

To verify installation is working:
1. **Launch macnav**
2. **Press Ctrl+Semicolon** - you should see the navigation overlay
3. **Test navigation** with WASD or HJKL keys
4. **Press Escape** to hide the overlay

## Building from Source

### Prerequisites

- macOS 12.0 or later
- Xcode Command Line Tools (for Swift compiler)
- Git (for cloning the repository)

### Build Instructions

#### Command Line Build

```bash
# Clone the repository
git clone https://github.com/olvlucas/macnav.git
cd macnav

# Build the project (creates universal binary)
make build

# Create app bundle
make bundle

# Install to /usr/local/bin (optional)
make install

# Run the application
swift run macnav
# OR
./.build/apple/Products/Release/macnav
```

#### Xcode Build (Optional)

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Open in Xcode
open macnav.xcodeproj
```

Then build and run from Xcode using Command+R.

#### Development

For development with automatic rebuilding:

```bash
# Run tests
make test

# Clean build artifacts
make clean

# Build release version
make release

# Check dependencies
make check-deps
```

**Note**: After building from source, remember to grant accessibility permissions as described in the Installation section above.

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

## Multi-Monitor Support

macnav intelligently detects and supports multiple monitor setups, allowing seamless navigation across screens using keyboard shortcuts.

### How Multi-Monitor Detection Works

- **Initial placement**: When you first activate macnav, it appears on the monitor containing your mouse cursor
- **Intelligent switching**: Use `Ctrl+Shift` + directional keys to move to adjacent monitors
- **Spatial awareness**: The system detects monitor positions and finds the closest screen in the specified direction
- **Persistent navigation**: Once you switch to a monitor, subsequent navigation stays relative to that screen until you switch again

### Multi-Monitor Navigation

1. **Activate macnav** on your current monitor with `Ctrl+Semicolon`
2. **Switch monitors** using:
   - `Ctrl+Shift+A` or `Ctrl+Shift+H` - Move to left monitor
   - `Ctrl+Shift+D` or `Ctrl+Shift+L` - Move to right monitor
   - `Ctrl+Shift+W` or `Ctrl+Shift+K` - Move to monitor above
   - `Ctrl+Shift+S` or `Ctrl+Shift+J` - Move to monitor below
3. **Navigate normally** within the selected monitor using WASD/HJKL keys
4. **Click and close** with Enter, or switch to another monitor

### Supported Monitor Layouts

- ✅ **Side-by-side**: Horizontal monitor arrangements
- ✅ **Stacked**: Vertical monitor arrangements
- ✅ **Mixed layouts**: Complex arrangements with monitors in different positions
- ✅ **Any number of monitors**: Works with 2+ monitor setups

## Troubleshooting

### "macnav is damaged and can't be opened" (Gatekeeper Warning)

This is a common macOS security warning for unsigned applications downloaded from the internet.

**Solution 1: Right-click Override (Recommended)**
1. Click **"Cancel"** on the warning dialog
2. **Right-click** on `macnav.app` in Finder
3. Select **"Open"** from the context menu
4. Click **"Open"** in the new dialog that appears
5. macOS will remember this choice for future launches

**Solution 2: Remove Quarantine Attribute**
```bash
# Remove the quarantine flag
xattr -d com.apple.quarantine /path/to/macnav.app
```

**Solution 3: System Settings**
1. Go to **System Settings → Privacy & Security**
2. Look for a message about macnav being blocked
3. Click **"Open Anyway"**

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
