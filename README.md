# macnav

A Keynav-like application for macOS.

This project aims to replicate the functionality of Keynav, allowing for keyboard-based navigation and interaction with the macOS user interface by dividing the screen into quadrants.

## Features (Planned)
- Screen division into quadrants
- Keyboard shortcuts for selecting quadrants
- Mouse cursor manipulation
- Clicking and other interactions

## Building and Running

### Prerequisites
- macOS (version 12.0 or later, as specified in `Package.swift`)
- Xcode Command Line Tools (for Swift compiler)

### Granting Accessibility Permissions
For `macnav` to capture global keyboard shortcuts, you must grant it accessibility permissions:
1. Open `System Settings > Privacy & Security > Accessibility`.
2. Click the `+` button to add an application.
3. Navigate to the compiled `macnav` executable and add it.
    - If building from the command line (`swift run macnav`), the executable is typically located at `.build/debug/macnav` in your project directory.
    - If building with Xcode, the `.app` bundle will be in your Xcode's DerivedData products directory (e.g., `~/Library/Developer/Xcode/DerivedData/macnav-xxxx/Build/Products/Debug/macnav.app`). You'll need to add the `.app` itself.
4. Ensure the checkbox next to `macnav` (or `macnav.app`) in the list is checked.

*Note: You might need to unlock the settings pane with your administrator password to make these changes.*

### Command Line
1. **Clone the repository (if you haven't already):**
   ```bash
   git clone <repository-url>
   cd macnav
   ```
2. **Build the project:**
   ```bash
   swift build
   ```
3. **Run the application:**
   ```bash
   swift run macnav
   ```
   The application will start, and you should see a message in your terminal (e.g., "macnav application started!").

### Xcode (Optional)
1. **Generate an Xcode project:**
   ```bash
   swift package generate-xcodeproj
   ```
2. **Open the project:**
   Open `macnav.xcodeproj` in Xcode.
3. **Build and Run:**
   Select the `macnav` scheme and a run destination (My Mac), then click the Run button (or press Command+R).

## Usage
- Press **Option+Shift+S** to toggle the display of the screen quadrants.