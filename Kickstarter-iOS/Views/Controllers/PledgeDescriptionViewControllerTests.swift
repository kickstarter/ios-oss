@testable import Kickstarter_Framework
import Library
import UIKit
import XCTest

final class PledgeDescriptionViewControllerTests: XCTestCase {
  func testSimultaneousGestureRecognizers() {
    let vc = PledgeDescriptionViewController.instantiate()
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: nil, action: nil)
    let tapGestureRecognizer = UITapGestureRecognizer(target: nil, action: nil)
    let otherGestureRecognizer = UIGestureRecognizer(target: nil, action: nil)

    XCTAssertEqual(
      true,
      vc.gestureRecognizer(
        longPressGestureRecognizer, shouldRecognizeSimultaneouslyWith: tapGestureRecognizer
      )
    )

    XCTAssertEqual(
      false,
      vc.gestureRecognizer(
        longPressGestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer
      )
    )
  }
}
