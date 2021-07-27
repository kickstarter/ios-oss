@testable import KsApi
import XCTest

final class UpdateUserEnvelope_UpdateUserEnvelopeTests: XCTestCase {
  func testUpdateUserAccount_WithUserAcccountMutation_Success() {
    let dict: [String: Any?] = [
      "updateUserAccount": [
        "clientMutationId": nil
      ]
    ]

    let data = GraphAPI.UpdateUserAccountMutation.Data(unsafeResultMap: dict)

    let env = UpdateUserEnvelope.from(data)

    XCTAssertNotNil(env)
    XCTAssertNil(env?.clientMutationId)
  }

  func testUpdateUserAccount_WithUserAcccountMutation_Error() {
    let dict: [String: Any?] = [
      "updateUserAccount": nil
    ]

    let data = GraphAPI.UpdateUserAccountMutation.Data(unsafeResultMap: dict)

    let env = UpdateUserEnvelope.from(data)

    XCTAssertNil(env)
    XCTAssertNil(env?.clientMutationId)
  }
  
  func testUpdateUserProfile_WithUserProfileMutation_Success() {
    let dict: [String: Any?] = [
      "updateUserProfile": [
        "clientMutationId": nil
      ]
    ]

    let data = GraphAPI.UpdateUserProfileMutation.Data(unsafeResultMap: dict)

    let env = UpdateUserEnvelope.from(data)

    XCTAssertNotNil(env)
    XCTAssertNil(env?.clientMutationId)
  }

  func testUpdateUserProfile_WithUserProfileMutation_Error() {
    let dict: [String: Any?] = [
      "updateUserProfile": nil
    ]

    let data = GraphAPI.UpdateUserProfileMutation.Data(unsafeResultMap: dict)

    let env = UpdateUserEnvelope.from(data)

    XCTAssertNil(env)
    XCTAssertNil(env?.clientMutationId)
  }
}
