import XCTest
@testable import Library

final class UITraitCollectionTests: XCTestCase {
  func testIsAccessibilityCategory() {
    var traits = UITraitCollection(preferredContentSizeCategory: .unspecified)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .extraSmall)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .small)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .medium)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .large)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .extraLarge)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .extraExtraLarge)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge)
    XCTAssertFalse(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .accessibilityMedium)
    XCTAssertTrue(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .accessibilityLarge)
    XCTAssertTrue(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
    XCTAssertTrue(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraLarge)
    XCTAssertTrue(traits.ksr_isAccessibilityCategory())

    traits = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
    XCTAssertTrue(traits.ksr_isAccessibilityCategory())
  }
}
