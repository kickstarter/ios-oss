import Library
import XCTest

final class HelpTypeTests: XCTestCase {
  func testAccessibilityTraits() {
    XCTAssertEqual(HelpType.helpCenter.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.contact.accessibilityTraits, UIAccessibilityTraits.button)
    XCTAssertEqual(HelpType.howItWorks.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.terms.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.privacy.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.cookie.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.trust.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.accessibility.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.community.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.environment.accessibilityTraits, UIAccessibilityTraits.link)
  }

  func testHelpTypeFromUrl() {
    var url = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    url.appendPathComponent("help/community")

    XCTAssertEqual(HelpType.helpType(from: url), .community)
  }

  func testHelpTypeFromUrl_Nil() {
    var url = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    url.appendPathComponent("foobar")

    XCTAssertNil(HelpType.helpType(from: url))
  }

  func testTitle() {
    XCTAssertEqual(HelpType.accessibility.title, Strings.Accessibility_statement())
    XCTAssertEqual(HelpType.community.title, "")
    XCTAssertEqual(HelpType.contact.title, Strings.profile_settings_about_contact())
    XCTAssertEqual(HelpType.cookie.title, Strings.profile_settings_about_cookie())
    XCTAssertEqual(HelpType.helpCenter.title, Strings.Help_center())
    XCTAssertEqual(HelpType.howItWorks.title, Strings.profile_settings_about_how_it_works())
    XCTAssertEqual(HelpType.privacy.title, Strings.profile_settings_about_privacy())
    XCTAssertEqual(HelpType.terms.title, Strings.profile_settings_about_terms())
    XCTAssertEqual(HelpType.trust.title, "")
    XCTAssertEqual(HelpType.environment.title, "")
  }

  func testUrlWithBaseUrl() {
    let baseURL = AppEnvironment.current.apiService.serverConfig.webBaseUrl

    XCTAssertEqual(
      HelpType.accessibility.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/accessibility")!
    )
    XCTAssertEqual(
      HelpType.community.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/help/community")!
    )
    XCTAssertNil(HelpType.contact.url(withBaseUrl: baseURL))
    XCTAssertEqual(
      HelpType.cookie.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/cookies")!
    )
    XCTAssertEqual(
      HelpType.helpCenter.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/help")!
    )
    XCTAssertEqual(
      HelpType.howItWorks.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/about")!
    )
    XCTAssertEqual(
      HelpType.privacy.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/privacy")!
    )
    XCTAssertEqual(
      HelpType.terms.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/terms-of-use")!
    )
    XCTAssertEqual(
      HelpType.trust.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/trust")!
    )
    XCTAssertEqual(
      HelpType.environment.url(withBaseUrl: baseURL),
      URL(string: "https://www.kickstarter.com/environment")!
    )
  }
}
