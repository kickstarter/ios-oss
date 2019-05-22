# PR size
warn("Big PR") if git.lines_of_code > 5

# SwiftLint
swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = 'bin/swiftlint'
swiftlint.lint_files inline_mode: true

# SwiftFormat
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--config Configs/Kickstarter.swiftformat"
swiftformat.check_format
