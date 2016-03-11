import XCTest
@testable import Library
import UIKit

final class CircleAvatarImageViewTests : XCTestCase {

  func testCircleAvatar() {
    let imageView = CircleAvatarImageView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
    imageView.layoutSubviews()

    XCTAssertEqual(50.0, imageView.layer.cornerRadius)
    XCTAssertEqual(true, imageView.layer.masksToBounds)

    imageView.frame.size = CGSize(width: 200.0, height: 200.0)
    imageView.layoutSubviews()

    XCTAssertEqual(100.0, imageView.layer.cornerRadius)
    XCTAssertEqual(true, imageView.layer.masksToBounds)
  }
}
