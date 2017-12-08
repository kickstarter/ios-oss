import Foundation

extension String {

  func toBase64() -> String {
    return Data(self.utf8).base64EncodedString()
  }
}
