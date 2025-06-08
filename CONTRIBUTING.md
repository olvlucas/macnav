# Contributing to macnav

Thank you for your interest in contributing to macnav! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Getting Started

### Prerequisites

- macOS 12.0 or later
- Xcode Command Line Tools
- Swift 5.9 or later
- Git

### Development Setup

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/macnav.git
   cd macnav
   ```

3. Build the project:
   ```bash
   make build
   ```

4. Run tests to ensure everything works:
   ```bash
   make test
   ```

5. Grant accessibility permissions for testing:
   - Open System Settings → Privacy & Security → Accessibility
   - Add the built binary from `.build/release/macnav`

## Making Changes

### Branch Naming

- Feature branches: `feature/description-of-feature`
- Bug fixes: `bugfix/description-of-fix`
- Documentation: `docs/description-of-changes`

### Commit Messages

Follow conventional commit format:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `refactor:` for code refactoring
- `test:` for adding tests
- `chore:` for maintenance tasks

Example: `feat: add grid navigation mode`

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run specific test
swift test --filter TestName
```

### Manual Testing

1. Build the application: `make build`
2. Run the binary: `.build/release/macnav`
3. Test the overlay with `Ctrl+Semicolon`
4. Verify all keyboard shortcuts work as expected
5. Test with different applications and screen configurations

### Test Coverage

- All new features should include appropriate tests
- Bug fixes should include regression tests
- Aim for high test coverage of core functionality

## Code Style

### Swift Style Guidelines

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions focused and small
- Use proper error handling

### Code Formatting

- Use 4 spaces for indentation
- Maximum line length: 120 characters
- Use trailing commas in multi-line arrays/dictionaries
- Group imports alphabetically

### Documentation

- Add documentation comments (`///`) for public methods
- Include parameter descriptions and return values
- Provide usage examples for complex functions

## Submitting Changes

### Pull Request Process

1. Ensure your code follows the style guidelines
2. Update documentation if needed
3. Add tests for new functionality
4. Ensure all tests pass
5. Update CHANGELOG.md if appropriate
6. Create a pull request with:
   - Clear title and description
   - Reference any related issues
   - Screenshots/videos for UI changes

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] Manual testing completed
- [ ] Added tests for new functionality

## Screenshots/Videos
(If applicable)

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
```

## Reporting Issues

### Bug Reports

Include the following information:
- macOS version
- macnav version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots/videos if helpful
- Console output if relevant

### Feature Requests

Include:
- Clear description of the feature
- Use cases and benefits
- Possible implementation approaches
- Any relevant examples from other tools

### Security Issues

For security vulnerabilities, please email directly rather than creating a public issue.

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

### Enforcement

Unacceptable behavior may result in temporary or permanent exclusion from the project community.

## Development Tips

### Debugging

- Use print statements for quick debugging
- Run with verbose output: `.build/release/macnav --verbose`
- Check Console.app for system-level logs

### Key Binding Testing

- Test custom `.macnav` configurations
- Verify modifier key combinations work correctly
- Test edge cases like rapid key presses

### Performance

- Profile with Instruments for performance issues
- Monitor memory usage during long sessions
- Test on older hardware when possible

## Getting Help

- Check existing issues and discussions
- Ask questions in GitHub issues
- Review the documentation thoroughly
- Look at similar projects for inspiration

Thank you for contributing to macnav!