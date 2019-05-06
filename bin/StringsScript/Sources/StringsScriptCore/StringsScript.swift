import Foundation

enum StringsScriptError: Error, LocalizedError {
  case genericError(String)
  case insufficientArguments
  case writeToFileError(String)

  var errorDescription: String? {
    switch self {
    case .genericError(let message):
      return message
    case .insufficientArguments:
      return "Insufficient arguments"
    case .writeToFileError(let message):
      return "Failed to write to file with error: \(message)"
    }
  }
}

public final class StringsScript {
  private let arguments: [String]

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }

  public func run() throws {
    guard self.arguments.count > 2 else {
      throw StringsScriptError.insufficientArguments
    }

    let writePath = self.arguments[1]
    let localesRootPath = self.arguments[2]
    let strings = Strings()

    let stringsByLocale = try strings.deserialize(strings.fetchStringsByLocale())

    try strings.localePathsAndContents(with: localesRootPath, stringsByLocale: stringsByLocale)
      .forEach { path, content in
        do {
          try content.write(toFile: path, atomically: true, encoding: .utf8)
          print("✅ Localized strings written to: \(path)")
        } catch {
          throw StringsScriptError.writeToFileError("\(error.localizedDescription) \nLine: \(#line)")
        }
    }

    do {
      try strings.staticStringsFileContents(stringsByLocale: stringsByLocale).write(toFile: writePath,
                                                    atomically: true,
                                                    encoding: .utf8)
      print("✅ Strings written to: \(writePath)")
    } catch {
      throw StringsScriptError.writeToFileError("\(error.localizedDescription) \nLine: \(#line)")
    }
  }
}
