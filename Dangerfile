# PR size
warn("Big PR") if git.lines_of_code > 350

# SwiftLint
swiftlint.binary_path = 'bin/swiftlint'
swiftlint.config_file = '.swiftlint.yml'
swiftlint.strict = true
swiftlint.lint_files inline_mode: true

# SwiftFormat
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--config .swiftformat --swiftversion 4.2"
swiftformat.check_format
