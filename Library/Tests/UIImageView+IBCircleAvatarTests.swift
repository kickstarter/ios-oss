import XCTest
@testable import Library
import UIKit

final class UIImage_IBCircleAvatarTests : XCTestCase {

  func testCircleAvatar() {
    let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))

    XCTAssertEqual(0.0, imageView.layer.cornerRadius)
    XCTAssertEqual(false, imageView.layer.masksToBounds)

    imageView.circleAvatar = true

    XCTAssertEqual(0.0, imageView.layer.cornerRadius)
    XCTAssertEqual(false, imageView.layer.masksToBounds)

    imageView.layoutSubviews()

    XCTAssertEqual(50.0, imageView.layer.cornerRadius)
    XCTAssertEqual(true, imageView.layer.masksToBounds)

    imageView.circleAvatar = false

    XCTAssertEqual(50.0, imageView.layer.cornerRadius)
    XCTAssertEqual(true, imageView.layer.masksToBounds)

    imageView.layoutSubviews()

    XCTAssertEqual(0.0, imageView.layer.cornerRadius)
    XCTAssertEqual(false, imageView.layer.masksToBounds)
  }
}
