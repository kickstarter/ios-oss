@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class OptimizelyClientTypeTests: TestCase {
  func testVariantForExperiment_NoError() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    XCTAssertEqual(
      OptimizelyExperiment.Variant.variant1,
      mockClient.variant(for: .pledgeCTACopy),
      "Returns the correction variation"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_ThrowsError() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]
      |> \.error .~ MockOptimizelyError()

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .pledgeCTACopy),
      "Returns the control variant if error is thrown"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_ExperimentNotFound() {
    let mockClient = MockOptimizelyClient()

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .pledgeCTACopy),
      "Returns the control variant if experiment key is not found"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_UnknownVariant() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: "other_variant"]

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .pledgeCTACopy),
      "Returns the control variant if the variant is not recognized"
    )
    XCTAssertTrue(mockClient.activatePathCalled)
    XCTAssertFalse(mockClient.getVariantPathCalled)
  }

  func testVariantForExperiment_NoError_LoggedIn_IsAdmin() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.variant1.rawValue]

    let user = User.template |> User.lens.isAdmin .~ true

    withEnvironment(currentUser: user) {
      XCTAssertEqual(
        OptimizelyExperiment.Variant.variant1,
        mockClient.variant(for: .pledgeCTACopy),
        "Returns the correction variation"
      )
      XCTAssertFalse(mockClient.activatePathCalled)
      XCTAssertTrue(mockClient.getVariantPathCalled)
    }
  }
}
