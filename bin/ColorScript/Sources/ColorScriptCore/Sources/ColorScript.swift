import Foundation

public enum ColorScriptError: Error {
  case fileNotFound(String)
  case cannotWriteToFile(String)
}

public final class ColorScript {
  private let arguments: [String]

  public let inPath = "Resources/Colors.json"
  public let outPath = "../../Library/Styles/Colors.swift"

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  public func run() throws {

    print(self.inPath)
    print(self.outPath)

    var color: Color?
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: self.inPath))
      color = Color(data: data)
      if let prettyColors = color?.prettyColors {
        print("All colors: \n\(prettyColors)")
      }
    } catch {
      throw ColorScriptError.fileNotFound(error.localizedDescription)
    }

    do {
      try color?.staticStringsLines()
        .joined(separator: "\n")
        .write(toFile: self.outPath, atomically: true, encoding: .utf8)
      print("✨ Done regenerating Colors.swift ✨")
    } catch {
      throw ColorScriptError.cannotWriteToFile(error.localizedDescription)
    }
  }
}
