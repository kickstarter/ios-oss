import Foundation
import KsApi

internal enum MockPXBlockType: String {
  case captcha
  case valid
}

internal class MockPerimeterXClient: PerimeterXClientType {
  var handleErrorCalled: Bool = false
  var pxblockType: MockPXBlockType?

  func headers() -> [String: String] {
    return ["PX-AUTH-TEST": "foobar"]
  }

  func handleError(blockResponse: HTTPURLResponse, and _: Data) -> Bool {
    if blockResponse.statusCode == 403 {
      self.pxblockType = .captcha
      self.handleErrorCalled = true
      return true
    }
    self.pxblockType = .valid
    return false
  }
}
