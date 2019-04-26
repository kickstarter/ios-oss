import Prelude
import XCTest
@testable import Library

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
}
