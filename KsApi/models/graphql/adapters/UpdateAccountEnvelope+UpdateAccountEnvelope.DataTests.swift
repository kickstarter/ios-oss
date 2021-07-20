@testable import KsApi
import XCTest

final class UpdateAccountEnvelope_UpdateAccountEnvelopeTests: XCTestCase {
  func testUpdateUserAccount_Success() {
    let dict: [String: Any?] = [
      "updateUserAccount": [
        "clientMutationId": nil
      ]
    ]
    
    let data = GraphAPI.UpdateUserAccountMutation.Data(unsafeResultMap: dict)
    
    let env = UpdateAccountEnvelope.from(data)
    
    XCTAssertNotNil(env)
    XCTAssertNil(env?.clientMutationId)
  }
  
  func testUpdateUserAccount_Error() {
    let dict: [String: Any?] = [
      "updateUserAccount": nil
    ]
    
    let data = GraphAPI.UpdateUserAccountMutation.Data(unsafeResultMap: dict)
    
    let env = UpdateAccountEnvelope.from(data)
    
    XCTAssertNil(env)
    XCTAssertNil(env?.clientMutationId)
  }
}
