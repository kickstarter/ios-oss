@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class TextElementCellViewModelTests: TestCase {
  private let vm: TextViewElementCellViewModelType = TextViewElementCellViewModel()

  private let bodyText = TestObserver<NSAttributedString, Never>()

  private let expectedSampleString = "sample attributed string"
  private let expectedBaseFontSize: CGFloat = 16.0
  private let expectedHeader1FontSize: CGFloat = 28.0
  private let expectedHeader2FontSize: CGFloat = 26.0
  private let expectedHeader3FontSize: CGFloat = 24.0
  private let expectedHeader4FontSize: CGFloat = 22.0
  private let expectedHeader5FontSize: CGFloat = 20.0
  private let expectedHeader6FontSize: CGFloat = 18.0
  private var expectedBaseFont = UIFont.ksr_body()
  private var expectedParagraphStyle = NSMutableParagraphStyle()
  private var expectedHeaderFont = UIFont.ksr_body()
  private var expectedFontAttributes = [NSAttributedString.Key: Any]()

  override func setUp() {
    super.setUp()

    self.expectedBaseFont = UIFont.ksr_body(size: self.expectedBaseFontSize)
    self.expectedParagraphStyle.minimumLineHeight = 22
    self.expectedFontAttributes = [
      NSAttributedString.Key.font: self.expectedBaseFont,
      NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700,
      NSAttributedString.Key.paragraphStyle: self.expectedParagraphStyle
    ]

    self.vm.outputs.attributedText.observe(self.bodyText.observer)
  }

  func testPlainTextElement() {
    let plainTextComponent = TextComponent(
      text: expectedSampleString,
      link: nil,
      styles: []
    )
    let plainTextElement = TextViewElement(components: [plainTextComponent])
    let expectedPlainAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(textElement: plainTextElement)
    self.bodyText.assertValue(expectedPlainAttributedText)
  }

  func testBoldTextElement() {
    let boldTextComponent = TextComponent(
      text: expectedSampleString,
      link: nil,
      styles: [.bold]
    )
    let boldTextElement = TextViewElement(components: [boldTextComponent])

    expectedFontAttributes[NSAttributedString.Key.font] = self.expectedBaseFont.bolded

    let expectedBoldAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(textElement: boldTextElement)
    self.bodyText.assertValue(expectedBoldAttributedText)
  }

  func testItalicTextElement() {
    let italicTextComponent = TextComponent(
      text: expectedSampleString,
      link: nil,
      styles: [.emphasis]
    )
    let italicTextElement = TextViewElement(components: [italicTextComponent])

    expectedFontAttributes[NSAttributedString.Key.font] = self.expectedBaseFont.italicized

    let expectedItalicAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(textElement: italicTextElement)
    self.bodyText.assertValue(expectedItalicAttributedText)
  }

  func testBoldItalicTextElement() {
    let italicTextComponent = TextComponent(
      text: expectedSampleString,
      link: nil,
      styles: [.bold, .emphasis]
    )
    let italicTextElement = TextViewElement(components: [italicTextComponent])

    expectedFontAttributes[NSAttributedString.Key.font] = self.expectedBaseFont.boldItalic

    let expectedItalicAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(textElement: italicTextElement)
    self.bodyText.assertValue(expectedItalicAttributedText)
  }

  func testLinkWithStylesTextElement() {
    let linkWithStylesTextComponent = TextComponent(
      text: expectedSampleString,
      link: "https://ksr.com",
      styles: [.bold, .emphasis, .link]
    )
    let linkWithStylesTextElement = TextViewElement(components: [linkWithStylesTextComponent])

    expectedFontAttributes[NSAttributedString.Key.font] = self.expectedBaseFont.boldItalic
    self.expectedFontAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_create_700
    self.expectedFontAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
    self.expectedFontAttributes[NSAttributedString.Key.link] = NSURL(string: "https://ksr.com")!

    let expectedLinkWithStylesAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(textElement: linkWithStylesTextElement)
    self.bodyText.assertValue(expectedLinkWithStylesAttributedText)
  }

  func testLinkWithNoStylesTextElement() {
    let linkWithNoStylesTextComponent = TextComponent(
      text: expectedSampleString,
      link: "https://ksr.com",
      styles: [.link]
    )
    let linkWithNoStylesTextElement = TextViewElement(components: [linkWithNoStylesTextComponent])

    self.expectedFontAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_create_700
    self.expectedFontAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
    self.expectedFontAttributes[NSAttributedString.Key.link] = NSURL(string: "https://ksr.com")!

    let expectedLinkWithNoStylesAttributedText = NSAttributedString(
      string: expectedSampleString,
      attributes: expectedFontAttributes
    )

    self.vm.inputs.configureWith(textElement: linkWithNoStylesTextElement)
    self.bodyText.assertValue(expectedLinkWithNoStylesAttributedText)
  }

  func testHeaderElements() {
    let headerTypesToFontSizes = [
      TextComponent.TextStyleType.header1: self.expectedHeader1FontSize,
      TextComponent.TextStyleType.header2: self.expectedHeader2FontSize,
      TextComponent.TextStyleType.header3: self.expectedHeader3FontSize,
      TextComponent.TextStyleType.header4: self.expectedHeader4FontSize,
      TextComponent.TextStyleType.header5: self.expectedHeader5FontSize,
      TextComponent.TextStyleType.header6: self.expectedHeader6FontSize
    ]
    _ = headerTypesToFontSizes.map { headerType, fontSize in
      let headerTextComponent = TextComponent(
        text: expectedSampleString,
        link: nil,
        styles: [headerType]
      )
      let headerTextElement = TextViewElement(components: [headerTextComponent])

      self.expectedHeaderFont = UIFont.ksr_body(size: fontSize).bolded
      expectedFontAttributes[NSAttributedString.Key.font] = self.expectedHeaderFont
      self.expectedFontAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_support_700
      self.expectedParagraphStyle.minimumLineHeight = 25
      self.expectedFontAttributes[NSAttributedString.Key.paragraphStyle] = self.expectedParagraphStyle

      let expectedHeaderAttributedText = NSAttributedString(
        string: expectedSampleString,
        attributes: expectedFontAttributes
      )

      self.vm.inputs.configureWith(textElement: headerTextElement)
      self.bodyText.assertLastValue(expectedHeaderAttributedText)
    }
  }

  func testListElement() {
    let expectedBulletStartTextValue = ""
    let expectedFirstListValue = "•  sample attributed string\n"
    let expectedSecondListValue = "•  sample attributed string"

    let listTextComponents = [
      TextComponent(
        text: "",
        link: nil,
        styles: [.bulletStart]
      ),
      TextComponent(
        text: expectedFirstListValue,
        link: "https://ksr.com",
        styles: [.link]
      ),
      TextComponent(
        text: expectedSecondListValue,
        link: nil,
        styles: [.bold]
      ),
      TextComponent(
        text: "",
        link: nil,
        styles: [.bulletEnd]
      )
    ]

    let listTextElement = TextViewElement(components: listTextComponents)

    let baseParagraphStyle = self.expectedParagraphStyle
    let baseFontAttributes = self.expectedFontAttributes

    self.expectedParagraphStyle.headIndent = ("" as NSString)
      .size(withAttributes: self.expectedFontAttributes).width
    self.expectedFontAttributes[NSAttributedString.Key.paragraphStyle] = self.expectedParagraphStyle

    let expectedBulletStartAttributedText = NSAttributedString(
      string: expectedBulletStartTextValue,
      attributes: expectedFontAttributes
    )

    self.expectedParagraphStyle = baseParagraphStyle
    self.expectedFontAttributes[NSAttributedString.Key.foregroundColor] = UIColor.ksr_create_700
    self.expectedFontAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
    self.expectedFontAttributes[NSAttributedString.Key.paragraphStyle] = self.expectedParagraphStyle
    self.expectedFontAttributes[NSAttributedString.Key.link] = NSURL(string: "https://ksr.com")!

    let expectedFirstListAttributedText = NSAttributedString(
      string: expectedFirstListValue,
      attributes: expectedFontAttributes
    )

    self.expectedParagraphStyle = baseParagraphStyle
    self.expectedFontAttributes = baseFontAttributes
    self.expectedFontAttributes[NSAttributedString.Key.paragraphStyle] = self.expectedParagraphStyle
    self.expectedFontAttributes[NSAttributedString.Key.font] = self.expectedBaseFont.bolded

    let expectedSecondListAttributedText = NSAttributedString(
      string: expectedSecondListValue,
      attributes: expectedFontAttributes
    )

    let combinedListAttributedString =
      NSMutableAttributedString(attributedString: expectedBulletStartAttributedText)
    combinedListAttributedString.append(expectedFirstListAttributedText)
    combinedListAttributedString.append(expectedSecondListAttributedText)

    self.vm.inputs.configureWith(textElement: listTextElement)
    self.bodyText.assertValue(combinedListAttributedString)
  }
}
