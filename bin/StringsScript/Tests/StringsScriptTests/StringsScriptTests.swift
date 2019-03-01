import XCTest
import StringsScriptCore
import class Foundation.Bundle

final class StringsScriptTests: XCTestCase {

  var subject: Strings?

  override func setUp() {
    super.setUp()
    self.subject = Strings()
  }

  func testStringsFileContents()  {
    let strings = ["Save": "Save"]
    let content = self.subject?.stringsFileContents(strings)
    XCTAssertEqual(content, "\"Save\" = \"Save\";")
  }

  func testLocalePathsAndContents() {

    let dic = ["fr": ["Kickstarter_is_not_a_store": "Kickstarter n\'est pas un magasin."]]

    self.subject?.stringsByLocale = dic
    if let (locale, content) = self.subject?.localePathsAndContents().first {
      XCTAssertEqual(locale, "../../Kickstarter-iOS/Locales/fr.lproj/Localizable.strings")
      XCTAssertEqual(content, "\"Kickstarter_is_not_a_store\" = \"Kickstarter n\'est pas un magasin.\";")
    } else {
      XCTFail("Locale and content cannot be nil")
    }
  }

  func testStaticStringsFileContents() {
    let dic = ["Base":
      ["Are_you_sure_you_wish_to_remove_this_card" : "Are you sure you wish to remove this card from your payment method options?"]]

    self.subject?.stringsByLocale = dic
    let generatedString =
  """
  //=======================================================================
  //
  // This file is computer generated from Localizable.strings. Do not edit.
  //
  //=======================================================================

  // swiftlint:disable valid_docs
  // swiftlint:disable line_length
  public enum Strings {
    /**
     "Are you sure you wish to remove this card from your payment method options?"

     - **en**: "Are you sure you wish to remove this card from your payment method options?"
    */
    public static func Are_you_sure_you_wish_to_remove_this_card() -> String {
      return localizedString(
        key: "Are_you_sure_you_wish_to_remove_this_card",
        defaultValue: "Are you sure you wish to remove this card from your payment method options?",
        count: nil,
        substitutions: [:]
      )
    }
  }

  """
    XCTAssertEqual(generatedString, try? self.subject?.staticStringsFileContents())
  }
}
