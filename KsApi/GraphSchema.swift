import Foundation
import Prelude

// MARK: - Base Query Types

extension Never: CustomStringConvertible {
  public var description: String {
    fatalError()
  }
}

public func decodeBase64(_ input: String) -> String? {
  return Data(base64Encoded: input)
    .flatMap { String(data: $0, encoding: .utf8) }
}

public func decompose(id: String) -> Int? {
  return decodeBase64(id)
    .flatMap { id -> Int? in
      let pair = id.split(separator: "-", maxSplits: 1)
      return pair.last.flatMap { Int($0) }
    }
}

public func encodeToBase64(_ input: String) -> String {
  return Data(input.utf8).base64EncodedString()
}

public struct GraphResponseError: Decodable {
  public let message: String
}

public enum GraphError: Error {
  case invalidInput
  case invalidJson(responseString: String?)
  case requestError(Error, URLResponse?)
  case emptyResponse(URLResponse?)
  case decodeError(GraphResponseError)
  case jsonDecodingError(responseString: String?, error: Error?)
}
