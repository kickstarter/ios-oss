@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ImageViewElementCellViewModelTests: TestCase {
  private let vm: ImageViewElementCellViewModelType = ImageViewElementCellViewModel()

  private let captionText = TestObserver<NSAttributedString?, Never>()
  private let image = TestObserver<UIImage?, Never>()

  private let expectedImage = UIImage(systemName: "camera")!
  private let expectedSampleString = "sample attributed string"
  private let expectedBaseFontSize: CGFloat = 12.0
  private var expectedBaseFont = UIFont.ksr_body()
  private var expectedParagraphStyle = NSMutableParagraphStyle()
  private var expectedFontAttributes = [NSAttributedString.Key: Any]()

  override func setUp() {
    super.setUp()

    self.expectedBaseFont = UIFont.ksr_body(size: self.expectedBaseFontSize).italicized
    self.expectedParagraphStyle.minimumLineHeight = 22
    self.expectedFontAttributes = [
      NSAttributedString.Key.font: self.expectedBaseFont,
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400,
      NSAttributedString.Key.paragraphStyle: self.expectedParagraphStyle
    ]

    self.vm.outputs.attributedText.observe(self.captionText.observer)
    self.vm.outputs.image.observe(self.image.observer)
  }

  func testPlainAttributedTextElement_Success() {
    let nonLinkCaptionImageViewElement = ImageViewElement(
      src: "https://image.com",
      href: nil,
      caption: expectedSampleString
    )
    let expectedNonLinkAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(imageElement: nonLinkCaptionImageViewElement, image: nil)
    self.captionText.assertValue(expectedNonLinkAttributedText)
  }

  func testLinkTextElement_Success() {
    let linkCaptionImageViewElement = ImageViewElement(
      src: "https://image.com",
      href: "https://link.com",
      caption: expectedSampleString
    )

    expectedFontAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
    self.expectedFontAttributes[NSAttributedString.Key.link] = URL(string: "https://link.com")!
    self.expectedFontAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_create_700

    let expectedLinkAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(imageElement: linkCaptionImageViewElement, image: nil)
    self.captionText.assertValue(expectedLinkAttributedText)
  }

  func testImageViewElementData_Success() {
    let dataImageViewElement = ImageViewElement(
      src: "https://image.com",
      href: "https://link.com",
      caption: expectedSampleString
    )

    self.vm.inputs.configureWith(imageElement: dataImageViewElement, image: nil)

    self.image.assertLastValue(nil)

    self.vm.inputs.configureWith(imageElement: dataImageViewElement, image: self.expectedImage)

    self.image.assertLastValue(self.expectedImage)
  }
}
