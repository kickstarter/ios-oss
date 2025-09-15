# PR size
warn("Big PR") if git.lines_of_code > 500

# SwiftFormat
swiftformat.additional_message = "This PR violates our formatting conventions. Run ./bin/format.sh to fix."
swiftformat.binary_path = "bin/swiftformat"
swiftformat.additional_args = "--config .swiftformat --swiftversion 5"
swiftformat.check_format(fail_on_error: true)

# SwiftLint
swiftlint.binary_path = "bin/swiftlint"
swiftlint.config_file = ".swiftlint.yml"
swiftlint.max_num_violations = 20
swiftlint.lint_files