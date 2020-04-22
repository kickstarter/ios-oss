# PR size
warn("Big PR") if git.lines_of_code > 500

# SwiftFormat
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--config .swiftformat --swiftversion 5"
swiftformat.exclude = %w(Library/Strings.swift Library/Styles/Colors.swift)
swiftformat.check_format
