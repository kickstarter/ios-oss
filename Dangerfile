# PR size
warn("Big PR") if git.lines_of_code > 5

# SwiftLint
swiftlint.lint_files inline_mode: true

# SwiftFormat
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--config Configs/Kickstarter.swiftformat"
swiftformat.check_format
