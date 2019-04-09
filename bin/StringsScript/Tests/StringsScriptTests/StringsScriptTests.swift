import XCTest
@testable import StringsScriptCore
import class Foundation.Bundle

// swiftlint:disable line_length
final class StringsScriptTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  func testStringsScript_run_throwsErrorWithInsufficientArguments() {
    let stringsScript = StringsScript(arguments: [String]())

    do {
      try stringsScript.run()

      XCTFail("Script should fail with insufficient number of arguments")
    } catch {
      XCTAssertEqual(StringsScriptError.insufficientArguments.localizedDescription, error.localizedDescription)
    }
  }

  func testStringsFileContents() {
    let subject = Strings()

    let strings = ["Add_attachments": "Add attachments…"]
    let content = subject.stringsFileContents(strings)
    XCTAssertEqual(content, "\"Add_attachments\" = \"Add attachments…\";")
  }

  func testLocalePathsAndContents() {

    let stringsByLocale = ["fr": ["Kickstarter_is_not_a_store": "Kickstarter n\'est pas un magasin."]]
    let strings = Strings()
    let localePath = "Kickstarter-iOS/Locales"

    if let (locale, content) = strings.localePathsAndContents(with: localePath,
                                                              stringsByLocale: stringsByLocale).first {
      XCTAssertEqual(locale, "Kickstarter-iOS/Locales/fr.lproj/Localizable.strings")
      XCTAssertEqual(content, "\"Kickstarter_is_not_a_store\" = \"Kickstarter n\'est pas un magasin.\";")
    } else {
      XCTFail("Locale and content cannot be nil")
    }
  }

  func testDeserialize() {
    let serializedDic =
      ["locales": ["de": ["A_successfully_funded_project_will_collect_your_pledge_in_its_native_currency": "Nach erfolgreicher Finanzierung des Projekts wird dein Finanzierungsbeitrag in der WU00e4hrung des Erstellungslandes abgebucht. Bis dahin kU00f6nnen nur ungefU00e4hre BetrU00e4ge angezeigt werden."]]]

    let finalDictionary = ["de": ["A_successfully_funded_project_will_collect_your_pledge_in_its_native_currency": "Nach erfolgreicher Finanzierung des Projekts wird dein Finanzierungsbeitrag in der WU00e4hrung des Erstellungslandes abgebucht. Bis dahin kU00f6nnen nur ungefU00e4hre BetrU00e4ge angezeigt werden."]]

    let subject = Strings()
    XCTAssertEqual(finalDictionary, try subject.deserialize(serializedDic as [String: AnyObject]))
  }

  func testStaticStringsFileContents() {
    let stringsByLocale = [
      "Base": [
        "Are_you_sure_you_wish_to_remove_this_card": "Are you sure you wish to remove this card from your payment method options?"
      ],
      "fr": [
        "Are_you_sure_you_wish_to_remove_this_card": "Êtes-vous certain de vouloir supprimer cette carte de vos moyens de paiement ?"
      ]
    ]
    let strings = Strings()

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
     - **fr**: "Êtes-vous certain de vouloir supprimer cette carte de vos moyens de paiement ?"
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
    XCTAssertEqual(generatedString, try? strings.staticStringsFileContents(stringsByLocale: stringsByLocale))
  }
}
