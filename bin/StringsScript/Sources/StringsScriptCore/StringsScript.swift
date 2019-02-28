import Foundation

enum StringsScriptError: Error {
  case genericError(String)
  case writeToFileError(String)
}

public final class StringsScript {
  private let arguments: [String]

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  public func run() throws {

    let strings = Strings()

    do {
      try strings.localePathsAndContents().forEach { path, content in
        do {
          try content.write(toFile: path, atomically: true, encoding: .utf8)
          print("Content written to: \(path)")
        } catch {
          throw StringsScriptError.writeToFileError("Error: \(error)\nLine: \(#line)")
        }
      }
    } catch {
      throw StringsScriptError.genericError("Error: \(error)\nLine: \(#line)")
    }

    do {
      try strings.staticStringsFileContents().write(toFile: "../../Library/Strings.swift",
                                                    atomically: true,
                                                    encoding: .utf8)
      print("Contents written to: Library/Strings.swift")
    } catch {
      throw StringsScriptError.writeToFileError("Error: \(error) Line: \(#line)")
    }
  }
}
