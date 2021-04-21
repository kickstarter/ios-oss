import Foundation
import PerimeterX

extension PerimeterXClient {
  static var mock: PerimeterXClient = PerimeterXClient(
    manager: MockPerimeterXManager(),
    dateType: ApiMockDate.self
  )
}

struct MockPerimeterXBlockResponse: PerimeterXBlockResponseType {
  var blockType: PXBlockType

  var type: PXBlockType {
    return self.blockType
  }

  func displayCaptcha(on _: UIViewController?) {}
}

final class MockPerimeterXManager: PerimeterXManagerType {
  var headers: [AnyHashable: Any] = ["PX-AUTH-TEST": "foobar"]
  var responseType: PerimeterXBlockResponseType?
  var vid: String = "test-vid-id"

  func getVid() -> String! {
    return self.vid
  }

  func httpHeaders() -> [AnyHashable: Any]! {
    return self.headers
  }

  func checkError(_: [AnyHashable: Any]!) -> PerimeterXBlockResponseType? {
    return self.responseType
  }
}
