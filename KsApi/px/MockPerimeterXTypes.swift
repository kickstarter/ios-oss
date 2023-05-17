import Foundation
import PerimeterX

extension PerimeterXClient {
  static var mock: PerimeterXClient = PerimeterXClient(
    manager: MockPerimeterXManager(),
    dateType: ApiMockDate.self
  )
}

struct MockPerimeterXBlockResponse: PerimeterXBlockResponseType {
  func displayCaptcha(on _: PerimeterXClientType, vc _: UIViewController?) {}

  var blockType: PXBlockType

  var type: PXBlockType {
    return self.blockType
  }
}

final class MockPerimeterXManager: PerimeterXManagerType {
  var headers: [AnyHashable: Any] = ["PX-AUTH-TEST": "foobar"]
  var responseType: PerimeterXBlockResponseType?
  var vid: String = "test-vid-id"

  func start(_: String!) {}

  func getVid() -> String! {
    return self.vid
  }

  func httpHeaders() -> [AnyHashable: Any]! {
    return self.headers
  }

  func checkError(_: [AnyHashable: Any]!) -> PerimeterXBlockResponseType? {
    return self.responseType
  }

  func handle(_: PXBlockResponse!, with _: UIViewController!, captchaSuccess _: PXCompletionBlock!) {}
}
