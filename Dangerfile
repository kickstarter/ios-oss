# PR size
warn("Big PR") if git.lines_of_code > 500

# SwiftFormat
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--config .swiftformat --swiftversion 5"
swiftformat.exclude = %w(Library/Strings.swift Library/Styles/Colors.swift)
swiftformat.check_format

# SwiftLint
swiftlint.binary_path = "bin/swiftlint"
swiftlint.config_file = ".swiftlint.yml"
# delete me
swiftlint.max_num_violations = 20
swiftlint.lint_all_files = true
# delete me
swiftlint.lint_files