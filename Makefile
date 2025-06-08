# macnav Makefile

# Variables
APP_NAME = macnav
VERSION = $(shell cat VERSION)
BUILD_DIR = .build
# Detect binary location based on build type
ifeq ($(CI),true)
    RELEASE_DIR = $(BUILD_DIR)/release
    BINARY_PATH = $(RELEASE_DIR)/$(APP_NAME)
else
    RELEASE_DIR = $(BUILD_DIR)/apple/Products/Release
    BINARY_PATH = $(RELEASE_DIR)/$(APP_NAME)
endif
APP_BUNDLE = $(APP_NAME).app

# Build configurations
# Use single arch in CI, universal binary locally
ifeq ($(CI),true)
    SWIFT_BUILD_FLAGS = -c release
else
    SWIFT_BUILD_FLAGS = -c release --arch arm64 --arch x86_64
endif

.PHONY: all build clean test release install uninstall bundle dmg help

# Default target
all: build

# Build the application
build:
	@echo "Building $(APP_NAME) v$(VERSION)..."
	swift build $(SWIFT_BUILD_FLAGS)
	@echo "Build complete! Binary at: $(BINARY_PATH)"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf $(BUILD_DIR)
	rm -rf $(APP_BUNDLE)
	rm -f $(APP_NAME).dmg
	@echo "Clean complete."

# Run tests
test:
	@echo "Running tests..."
	swift test

# Create release build and bundle
release: clean build bundle
	@echo "Release v$(VERSION) created successfully!"
	@echo "App bundle: $(APP_BUNDLE)"

# Install to /usr/local/bin (for command line usage)
install: build
	@echo "Installing $(APP_NAME) to /usr/local/bin..."
	@if [ -f "$(BINARY_PATH)" ]; then \
		cp "$(BINARY_PATH)" /usr/local/bin/$(APP_NAME); \
		chmod +x /usr/local/bin/$(APP_NAME); \
		echo "Installed $(APP_NAME) to /usr/local/bin/$(APP_NAME)"; \
	else \
		echo "Error: Binary not found at $(BINARY_PATH)"; \
		echo "Please run 'make build' first"; \
		exit 1; \
	fi

# Uninstall from /usr/local/bin
uninstall:
	@echo "Uninstalling $(APP_NAME)..."
	@if [ -f "/usr/local/bin/$(APP_NAME)" ]; then \
		rm /usr/local/bin/$(APP_NAME); \
		echo "Uninstalled $(APP_NAME) from /usr/local/bin"; \
	else \
		echo "$(APP_NAME) not found in /usr/local/bin"; \
	fi

# Create macOS app bundle
bundle: build
	@echo "Creating app bundle..."
	@echo "Looking for binary at: $(BINARY_PATH)"
	@if [ ! -f "$(BINARY_PATH)" ]; then \
		echo "Binary not found at $(BINARY_PATH), searching..."; \
		FOUND_BINARY=$$(find $(BUILD_DIR) -name $(APP_NAME) -type f | head -1); \
		if [ -n "$$FOUND_BINARY" ]; then \
			echo "Found binary at: $$FOUND_BINARY"; \
			mkdir -p $(APP_BUNDLE)/Contents/MacOS; \
			mkdir -p $(APP_BUNDLE)/Contents/Resources; \
			cp "$$FOUND_BINARY" $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME); \
		else \
			echo "Error: Could not find $(APP_NAME) binary in $(BUILD_DIR)"; \
			find $(BUILD_DIR) -name "$(APP_NAME)*" -type f || true; \
			exit 1; \
		fi; \
	else \
		mkdir -p $(APP_BUNDLE)/Contents/MacOS; \
		mkdir -p $(APP_BUNDLE)/Contents/Resources; \
		cp $(BINARY_PATH) $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME); \
	fi
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > $(APP_BUNDLE)/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<plist version="1.0">' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '<dict>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>CFBundleExecutable</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>$(APP_NAME)</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>CFBundleIdentifier</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>com.macnav.$(APP_NAME)</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>CFBundleName</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>$(APP_NAME)</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>CFBundleVersion</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>$(VERSION)</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>CFBundleShortVersionString</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>$(VERSION)</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>CFBundleInfoDictionaryVersion</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>6.0</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>CFBundlePackageType</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>APPL</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>LSMinimumSystemVersion</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>12.0</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>LSApplicationCategoryType</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<string>public.app-category.utilities</string>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>NSHighResolutionCapable</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<true/>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<key>LSUIElement</key>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '	<true/>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '</dict>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo '</plist>' >> $(APP_BUNDLE)/Contents/Info.plist
	@echo "App bundle created: $(APP_BUNDLE)"

# Create DMG for distribution (requires create-dmg: brew install create-dmg)
dmg: bundle
	@echo "Creating DMG..."
	@if ! command -v create-dmg >/dev/null 2>&1; then \
		echo "Error: create-dmg not found. Install with: brew install create-dmg"; \
		exit 1; \
	fi
	@if [ -f "$(APP_BUNDLE)/Contents/Resources/AppIcon.icns" ]; then \
		create-dmg \
			--volname "$(APP_NAME) $(VERSION)" \
			--volicon "$(APP_BUNDLE)/Contents/Resources/AppIcon.icns" \
			--window-pos 200 120 \
			--window-size 600 400 \
			--icon-size 100 \
			--icon "$(APP_BUNDLE)" 175 190 \
			--hide-extension "$(APP_BUNDLE)" \
			--app-drop-link 425 190 \
			"$(APP_NAME)-$(VERSION).dmg" \
			"$(APP_BUNDLE)"; \
	else \
		create-dmg \
			--volname "$(APP_NAME) $(VERSION)" \
			--window-pos 200 120 \
			--window-size 600 400 \
			--icon-size 100 \
			--icon "$(APP_BUNDLE)" 175 190 \
			--hide-extension "$(APP_BUNDLE)" \
			--app-drop-link 425 190 \
			"$(APP_NAME)-$(VERSION).dmg" \
			"$(APP_BUNDLE)"; \
	fi
	@echo "DMG created: $(APP_NAME)-$(VERSION).dmg"

# Check if required tools are available
check-deps:
	@echo "Checking dependencies..."
	@command -v swift >/dev/null 2>&1 || { echo "Error: Swift not found"; exit 1; }
	@echo "✓ Swift found"
	@command -v xcodebuild >/dev/null 2>&1 || { echo "Warning: Xcode not found (optional)"; }
	@echo "✓ Dependencies checked"

# Display help
help:
	@echo "macnav Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build      - Build the application in release mode"
	@echo "  clean      - Clean all build artifacts"
	@echo "  test       - Run the test suite"
	@echo "  bundle     - Create macOS app bundle"
	@echo "  dmg        - Create DMG for distribution (requires create-dmg)"
	@echo "  release    - Clean, build, and bundle (full release)"
	@echo "  install    - Install binary to /usr/local/bin"
	@echo "  uninstall  - Remove binary from /usr/local/bin"
	@echo "  check-deps - Check if required tools are available"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Version: $(VERSION)"