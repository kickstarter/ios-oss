@testable import Library
import Prelude
import XCTest

final class UIStackViewTests: XCTestCase {
  func testAddArrangedSubviewsToStackView() {
    let firstView = UIView(frame: .zero)
    let secondView = UIView(frame: .zero)
    let thirdView = UIView(frame: .zero)
    let stackView = UIStackView(frame: .zero)

    _ = ([firstView, secondView, thirdView], stackView)
      |> ksr_addArrangedSubviewsToStackView()

    XCTAssertEqual(firstView, stackView.arrangedSubviews[0])
    XCTAssertEqual(secondView, stackView.arrangedSubviews[1])
    XCTAssertEqual(thirdView, stackView.arrangedSubviews[2])
  }

  func testSetCustomSpacing() {
    let afterView = UIView(frame: .zero)
    let stackView = UIStackView(frame: .zero)

    stackView.addArrangedSubview(afterView)

    _ = (afterView, stackView)
      |> ksr_setCustomSpacing(10)

    XCTAssertEqual(10, stackView.customSpacing(after: afterView))
  }

  func testSetBackgroundColor() {
    let subview = UIView(frame: .zero)
    let stackView = UIStackView(frame: .zero)

    XCTAssertEqual(0, stackView.subviews.count)

    stackView.addArrangedSubview(subview)

    XCTAssertEqual(1, stackView.subviews.count)

    _ = stackView
      |> ksr_setBackgroundColor(.ksr_black)

    XCTAssertEqual(2, stackView.subviews.count)
    XCTAssertEqual(UIColor.ksr_black, stackView.subviews[0].backgroundColor)

    _ = stackView
      |> ksr_setBackgroundColor(.ksr_black)

    XCTAssertEqual(2, stackView.subviews.count, "setBackgroundColor is idempotent")
    XCTAssertEqual(UIColor.ksr_black, stackView.subviews[0].backgroundColor)
  }
}
