# PR size
warn("Big PR") if git.lines_of_code > 5

# SwiftLint
swiftlint.lint_files inline_mode: true

# SwiftFormat
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--indent 2 --self insert --commas inline --ranges nospace --patternlet inline --disable void"
swiftformat.check_format
