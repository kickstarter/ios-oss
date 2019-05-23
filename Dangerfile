# PR size
warn("Big PR") if git.lines_of_code > 350

# SwiftLint
swiftlint.binary_path = 'bin/swiftlint'
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files fail_on_error: true
swiftlint.lint_files inline_mode: true

# SwiftFormat
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--config Configs/Kickstarter.swiftformat --swiftversion 4.2"
swiftformat.check_format
