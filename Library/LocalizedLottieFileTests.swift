@testable import Library
import XCTest

class LocalizedLottieFileTests: XCTestCase {
  func testReturnsLocalizedLottieFile_ForEachSupportedLanguage() {
    let testBundle = Bundle(for: type(of: self))
    let supportedLanguages: [Language] = [.de, .es, .fr, .ja]
    let fileNames: [OnboardingLotteFileNames] = [
      .welcome,
      .saveProjects,
      .enableNotifications,
      .loginSignup
    ]

    for language in supportedLanguages {
      withEnvironment(language: language) {
        for file in fileNames {
          let result = localizedOnboardingLottieFile(for: file, in: testBundle)
          let expected = "\(file.rawValue)-\(language.rawValue)"

          XCTAssertEqual(
            result,
            expected,
            "Expected Lottie file for \(file) in language \(language) to be \(expected), but got \(result ?? "nil")"
          )
        }
      }
    }
  }
}
