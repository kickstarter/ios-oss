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
    // swiftlint:disable force_try force_cast force_unwrapping
//    guard arguments.count > 2 else {
//      throw ColorScriptError.missingArguments
//    }

    print(inPath)
    print(outPath)

    let data = try! Data(contentsOf: URL(fileURLWithPath: inPath))
    let c = Color(data: data)

    print("All colors: \n\(c.prettyColors)")

    try! c.staticStringsLines()
      .joined(separator: "\n")
      .write(toFile: outPath, atomically: true, encoding: .utf8)

    print("✨ Done regenerating Colors.swift ✨")
  }
}
