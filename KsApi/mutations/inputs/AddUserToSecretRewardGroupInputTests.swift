@testable import KsApi
import XCTest

final class AddUserToSecretRewardGroupInputTests: XCTestCase {
  func testAddUserToSecretRewardGroupInputDictionary() {
    let input = AddUserToSecretRewardGroupInput(
      projectId: "project-id",
      secretRewardToken: "secret-token"
    )

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["projectId"] as? String, "project-id")
    XCTAssertEqual(inputDictionary["secretRewardToken"] as? String, "secret-token")
  }
}
