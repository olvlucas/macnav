#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="macnav"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    echo "Usage: $0 [OPTIONS] VERSION"
    echo ""
    echo "Prepare a new release of $APP_NAME"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message"
    echo "  -d, --dry-run  Perform a dry run without making changes"
    echo "  -f, --force    Force release without confirmation"
    echo ""
    echo "VERSION:"
    echo "  Semantic version number (e.g., 1.0.0, 1.2.3-beta.1)"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0"
    echo "  $0 --dry-run 1.1.0"
    echo "  $0 --force 1.0.1"
}

validate_version() {
    local version="$1"
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
        log_error "Invalid version format: $version"
        log_error "Expected format: X.Y.Z or X.Y.Z-suffix (e.g., 1.0.0, 1.2.3-beta.1)"
        exit 1
    fi
}

check_git_status() {
    if [[ -n $(git status --porcelain) ]]; then
        log_error "Working directory is not clean. Please commit or stash your changes."
        exit 1
    fi

    local branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$branch" != "main" ]] && [[ "$branch" != "master" ]]; then
        log_warning "You are not on the main branch (current: $branch)"
        if [[ "$FORCE" != "true" ]]; then
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi
}

update_version_file() {
    local new_version="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would update VERSION file to: $new_version"
        return
    fi

    echo "$new_version" > "$VERSION_FILE"
    log_success "Updated VERSION file to: $new_version"
}

update_changelog() {
    local new_version="$1"
    local current_date=$(date +%Y-%m-%d)

    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        log_warning "CHANGELOG.md not found, skipping changelog update"
        return
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would update CHANGELOG.md for version: $new_version"
        return
    fi

    # Replace [Unreleased] with the new version
    sed -i.bak "s/## \[Unreleased\]/## [Unreleased]\n\n## [$new_version] - $current_date/" "$CHANGELOG_FILE"
    rm "$CHANGELOG_FILE.bak"

    log_success "Updated CHANGELOG.md for version: $new_version"
}

build_and_test() {
    log_info "Building and testing..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would run: make clean && make test && make build"
        return
    fi

    cd "$PROJECT_ROOT"
    make clean
    make test
    make build

    log_success "Build and tests completed successfully"
}

create_git_tag() {
    local version="$1"
    local tag_name="v$version"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create git tag: $tag_name"
        return
    fi

    git add VERSION CHANGELOG.md
    git commit -m "chore: bump version to $version"
    git tag -a "$tag_name" -m "Release $version"

    log_success "Created git tag: $tag_name"
    log_info "To push the release, run:"
    log_info "  git push origin main && git push origin $tag_name"
}

# Parse command line arguments
DRY_RUN=false
FORCE=false
VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [[ -z "$VERSION" ]]; then
                VERSION="$1"
            else
                log_error "Too many arguments"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$VERSION" ]]; then
    log_error "Version number is required"
    usage
    exit 1
fi

validate_version "$VERSION"

# Main execution
log_info "Preparing release for $APP_NAME v$VERSION"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warning "DRY RUN MODE - No changes will be made"
fi

# Pre-flight checks
cd "$PROJECT_ROOT"
check_git_status

# Get current version
if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    log_info "Current version: $CURRENT_VERSION"
fi

# Confirmation
if [[ "$FORCE" != "true" ]] && [[ "$DRY_RUN" != "true" ]]; then
    echo
    echo "Release Summary:"
    echo "  App: $APP_NAME"
    echo "  Version: $VERSION"
    echo "  Current: ${CURRENT_VERSION:-"unknown"}"
    echo
    read -p "Proceed with release? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Release cancelled"
        exit 0
    fi
fi

# Execute release steps
log_info "Starting release process..."

update_version_file "$VERSION"
update_changelog "$VERSION"
build_and_test

if [[ "$DRY_RUN" != "true" ]]; then
    create_git_tag "$VERSION"

    echo
    log_success "Release v$VERSION prepared successfully!"
    echo
    log_info "Next steps:"
    log_info "1. Review the changes:"
    log_info "   git show HEAD"
    log_info "   git show v$VERSION"
    log_info "2. Push the release:"
    log_info "   git push origin main && git push origin v$VERSION"
    log_info "3. GitHub Actions will automatically create the release artifacts"
else
    log_success "Dry run completed successfully!"
fi