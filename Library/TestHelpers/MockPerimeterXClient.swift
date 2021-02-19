import Foundation

internal class MockPerimeterXClient: PerimeterXClientType {
  func headers() -> [String: String] {
    return ["PX-AUTH-TEST": "foobar"]
  }

  func handleError(blockResponse _: HTTPURLResponse, and _: Data) {}
}
