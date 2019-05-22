import XCTest
@testable import Library

final class UIViewAutoLayoutExtensionTests: TestCase {
  func test_insertSubviewInParentAtIndex_oneSubview() {
    let view1 = UIView(frame: .zero)
    let view2 = UIView(frame: .zero)

    let targetView = UIView(frame: .zero)

    targetView.addSubview(view1)

    _ = ksr_insertSubviewInParent(at: 0)(view2, targetView)

    XCTAssertEqual(targetView.subviews.count, 2)
    XCTAssertEqual(targetView.subviews[0], view2)
    XCTAssertEqual(targetView.subviews[1], view1)
  }

  func test_insertSubviewInParentAtIndex_manySubviews() {
    let view1 = UIView(frame: .zero)
    let view2 = UIView(frame: .zero)
    let view3 = UIView(frame: .zero)
    let view4 = UIView(frame: .zero)

    let targetView = UIView(frame: .zero)

    targetView.addSubview(view1)
    targetView.addSubview(view2)
    targetView.addSubview(view3)

    _ = ksr_insertSubviewInParent(at: 1)(view4, targetView)

    XCTAssertEqual(targetView.subviews[1], view4)
    XCTAssertEqual(targetView.subviews.count, 4)
  }

  func testInsertSubviewBelowSubview() {
    let view1 = UIView(frame: .zero)
    let view2 = UIView(frame: .zero)

    let targetView = UIView(frame: .zero)

    targetView.addSubview(view2)

    XCTAssertEqual(targetView.subviews.first, view2)

    _ = ksr_insertSubview(view1, belowSubview: view2)(targetView)

    XCTAssertEqual(targetView.subviews.count, 2)
    XCTAssertEqual(targetView.subviews.first, view1)
    XCTAssertEqual(targetView.subviews.last, view2)
  }
}
