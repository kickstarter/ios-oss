@testable import Library
import Prelude
import XCTest

final class OptimizelyClientTypeTests: TestCase {
  func testVariantForExperiment_NoError() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.experimental.rawValue]

    XCTAssertEqual(
      OptimizelyExperiment.Variant.experimental,
      mockClient.variant(for: .pledgeCTACopy, userId: "123"),
      "Returns the correction variation"
    )
  }

  func testVariantForExperiment_ThrowsError() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: OptimizelyExperiment.Variant.experimental.rawValue]
      |> \.error .~ MockOptimizelyError()

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .pledgeCTACopy, userId: "123"),
      "Returns the control variant if error is thrown"
    )
  }

  func testVariantForExperiment_ExperimentNotFound() {
    let mockClient = MockOptimizelyClient()

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .pledgeCTACopy, userId: "123"),
      "Returns the control variant if experiment key is not found"
    )
  }

  func testVariantForExperiment_UnknownVariant() {
    let mockClient = MockOptimizelyClient()
      |> \.experiments .~
      [OptimizelyExperiment.Key.pledgeCTACopy.rawValue: "other_variant"]

    XCTAssertEqual(
      OptimizelyExperiment.Variant.control,
      mockClient.variant(for: .pledgeCTACopy, userId: "123"),
      "Returns the control variant if the variant is not recognized"
    )
  }
}
