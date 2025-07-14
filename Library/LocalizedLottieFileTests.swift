@testable import Library
import XCTest

class LocalizedLottieFileTests: XCTestCase {
  func testReturnsLocalizedLottieFile_ForEachSupportedLanguage() {
    let testBundle = Bundle(for: type(of: self))
    let supportedLanguages: [Language] = [.en, .de, .es, .fr, .ja]
    let onboardingItems: [OnboardingItemType] = [
      .welcome,
      .saveProjects,
      .enableNotifications,
      .loginSignUp
    ]

    for language in supportedLanguages {
      withEnvironment(language: language) {
        for type in onboardingItems {
          let result = localizedOnboardingLottieFile(for: type.lottieFileName, in: testBundle)
          let expected = "\(type.lottieFileName)-\(language.rawValue)"

          XCTAssertEqual(
            result,
            expected,
            "Expected Lottie file for \(type.lottieFileName) in language \(language) to be \(expected), but got \(result ?? "nil")"
          )
        }
      }
    }
  }
}
