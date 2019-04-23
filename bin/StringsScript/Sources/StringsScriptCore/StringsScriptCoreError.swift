import Foundation

enum StringsScriptCoreError: Error, LocalizedError {
  case errorDecodingLocalesFromJSON
  case errorFetchingStringsFromServer(String)
  case stringNotFound(String)
  case unknownError(String)

  var errorDescription: String? {
    switch self {
    case .errorDecodingLocalesFromJSON:
      return "Error decoding locales from JSON"
    case .errorFetchingStringsFromServer(let message):
      return "Error fetching strings from server: \(message)"
    case .stringNotFound(let lineNumber):
      return "String not found. Line: \(lineNumber)"
    case .unknownError(let error):
      return "Unknown error: \(error)"
    }
  }
}
