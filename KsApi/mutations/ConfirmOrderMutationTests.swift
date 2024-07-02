import Foundation
@testable import KsApi
import XCTest

final class ConfirmOrderMutationTests: XCTestCase {
  func test_confirmOrderWithMocks_success() {
    let mockService = MockService(completeOrderResult: .success("success"))
    let mutationResult = mockService.completeOrder(projectId: "123", stripePaymentMethodId: "pm_Wkadfk8jkh")
    let observer = CombineTestObserver<String, ErrorEnvelope>()
    observer.observe(mutationResult)

    observer.assertLastValue("success")
  }

  func test_confirmOrderWithMocks_error() {
    let mockService = MockService(completeOrderResult: .failure(ErrorEnvelope.couldNotParseJSON))
    let mutationResult = mockService.completeOrder(projectId: "123", stripePaymentMethodId: "pm_Wkadfk8jkh")
    let observer = CombineTestObserver<String, ErrorEnvelope>()
    observer.observe(mutationResult)

    observer.assertDidFail()
  }
}
