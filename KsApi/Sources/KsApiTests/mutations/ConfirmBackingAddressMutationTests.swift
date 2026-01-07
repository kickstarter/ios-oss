import Foundation
@testable import KsApi
import XCTest

final class ConfirmBackingAddressMutationTests: XCTestCase {
  func test_confirmBackingAddressWithMocks_success() {
    let mockService = MockService(confirmBackingAddressResult: .success(true))
    let mutationResult = mockService.confirmBackingAddress(
      backingId: "QmFja2luZy0x",
      addressId: "QWRkcmVzcy0x"
    )
    let observer = CombineTestObserver<Bool, ErrorEnvelope>()
    observer.observe(mutationResult)

    observer.assertLastValue(true)
  }

  func test_confirmBackingAddressWithMocks_failure() {
    let mockService = MockService(confirmBackingAddressResult: .success(false))
    let mutationResult = mockService.confirmBackingAddress(
      backingId: "QmFja2luZy0x",
      addressId: "QWRkcmVzcy0x"
    )
    let observer = CombineTestObserver<Bool, ErrorEnvelope>()
    observer.observe(mutationResult)

    observer.assertLastValue(false)
  }

  func test_confirmBackingAddressWithMocks_error() {
    let mockService = MockService(confirmBackingAddressResult: .failure(ErrorEnvelope.couldNotParseJSON))
    let mutationResult = mockService.confirmBackingAddress(
      backingId: "QmFja2luZy0x",
      addressId: "QWRkcmVzcy0x"
    )
    let observer = CombineTestObserver<Bool, ErrorEnvelope>()
    observer.observe(mutationResult)
    observer.assertDidFail()
  }
}
