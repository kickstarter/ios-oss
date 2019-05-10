import XCTest
@testable import Library

final class UIViewAutoLayoutExtensionTests: TestCase {
  func test_insertSubviewInParentAtIndex_oneSubview() {
    let view1 = UIView(frame: .zero)
    let view2 = UIView(frame: .zero)

    _ = (view2, view1)

    _ = ksr_insertSubviewInParent(at: 0)(view2, view1)

    XCTAssertEqual(view1.subviews.count, 1)
    XCTAssertEqual(view1.subviews[0], view2)
  }
}
