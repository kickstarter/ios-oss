@testable import Library
import Prelude
import UIKit
import XCTest

final class CheckoutStylesTests: XCTestCase {
  func testCheckoutAdaptableStackViewStyle() {
    let stackView = UIStackView(frame: .zero)

    _ = stackView |> checkoutAdaptableStackViewStyle(false)

    XCTAssertEqual(UIStackView.Alignment.center, stackView.alignment)
    XCTAssertEqual(NSLayoutConstraint.Axis.horizontal, stackView.axis)
    XCTAssertEqual(UIStackView.Distribution.fill, stackView.distribution)
    XCTAssertEqual(0, stackView.spacing)

    _ = stackView |> checkoutAdaptableStackViewStyle(true)

    XCTAssertEqual(UIStackView.Alignment.leading, stackView.alignment)
    XCTAssertEqual(NSLayoutConstraint.Axis.vertical, stackView.axis)
    XCTAssertEqual(UIStackView.Distribution.equalSpacing, stackView.distribution)
    XCTAssertEqual(6, stackView.spacing)
  }

  func testCheckoutBackgroundStyle() {
    let view = UIView(frame: .zero)

    _ = view |> checkoutBackgroundStyle

    XCTAssertEqual(view.backgroundColor, UIColor.ksr_grey_300)
  }

  func testCheckoutStackViewStyle() {
    let stackView = UIStackView(frame: .zero)

    _ = stackView |> checkoutStackViewStyle

    XCTAssertEqual(NSLayoutConstraint.Axis.vertical, stackView.axis)
    XCTAssertEqual(true, stackView.isLayoutMarginsRelativeArrangement)
    XCTAssertEqual(UIEdgeInsets(top: 12, left: 24, bottom: 18, right: 24), stackView.layoutMargins)
    XCTAssertEqual(9, stackView.spacing)
  }

  func testCheckoutTitleLabelStyle() {
    let label = UILabel(frame: .zero)

    _ = label |> checkoutTitleLabelStyle

    XCTAssertEqual(true, label.adjustsFontForContentSizeCategory)
    XCTAssertEqual(UIFont.ksr_headline(size: 15), label.font)
    XCTAssertEqual(0, label.numberOfLines)
  }
}
