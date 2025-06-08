# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2024-01-XX

### Added
- Initial release of macnav
- Keynav-style visual overlay with crosshairs for precise screen navigation
- Progressive area splitting for targeting specific screen locations
- Area movement without size changes (move actions)
- Keyboard-only navigation and clicking functionality
- Global keyboard shortcuts that work across all applications
- Event interception to prevent key conflicts with other apps
- Visual feedback with center point highlighting
- Custom keybinding configuration support via `.macnav` file
- Support for multiple action chaining (e.g., `warp,click 1,end`)
- Vim-style navigation keys (HJKL) alongside WASD
- Multiple click types (left, right, middle) at current mouse position
- Reset functionality to return to full screen view
- Mouse cursor warping without clicking
- Reload keybindings during runtime
- Comprehensive documentation and usage examples

### Keyboard Controls
- **Global Toggle**: Ctrl+Semicolon (customizable)
- **Area Cutting**: W/A/S/D or H/J/K/L to split selection areas
- **Area Moving**: Shift+WASD/HJKL to move selection without changing size
- **Actions**: Enter/Space to click, M to warp, R to reset, Q to quit
- **Click Types**: 1/2/3 for left/right/middle click at current mouse position

### Technical Features
- Built with Swift and AppKit for native macOS performance
- Uses CGEventTap for reliable global key interception
- Uses CGEvent for precise mouse simulation
- Requires macOS 12.0 or later
- No external dependencies
- Accessibility permissions integration for security compliance