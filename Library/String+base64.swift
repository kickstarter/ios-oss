import Foundation

extension String {

  public func toBase64() -> String {
    return Data(self.utf8).base64EncodedString()
  }
}
