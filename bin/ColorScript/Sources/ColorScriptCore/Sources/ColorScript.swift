// swiftlint:disable force_try
import Foundation

public enum ColorScriptError: Error {
  case missingArguments
}

public final class ColorScript {
  private let arguments: [String]

  public let inPath = "Resources/Colors.json"
  public let outPath = "Resources/Colors.swift"

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  public func run() throws {

    print(inPath)
    print(outPath)

    let data = try! Data(contentsOf: URL(fileURLWithPath: inPath))
    let color = Color(data: data)

    print("All colors: \n\(color.prettyColors)")

    try! color.staticStringsLines()
      .joined(separator: "\n")
      .write(toFile: outPath, atomically: true, encoding: .utf8)

    print("✨ Done regenerating Colors.swift ✨")
  }
}
