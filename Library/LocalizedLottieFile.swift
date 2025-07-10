import Foundation

enum OnboardingLotteFileNames: String {
  case welcome = "onboarding-flow-welcome"
  case appTracking = "onboarding-flow-activity-tracking"
  case enableNotifications = "onboarding-flow-enable-notifications"
  case saveProjects = "onboarding-flow-save-projects"
  case loginSignup = "onboarding-flow-login-signup"
}

/// Returns the correct Lottie filename based on current locale, with fallback to English.
func localizedOnboardingLottieFile(
  for baseName: OnboardingLotteFileNames,
  in bundle: Bundle = .main
) -> String? {
  let langCode = AppEnvironment.current.language.rawValue
  let pathToFile = "\(baseName.rawValue)-\(langCode)"

  /// Check if the file exists
  if bundle.url(
    forResource: "\(baseName.rawValue)-\(langCode)",
    withExtension: "json"
  ) != nil {
    return pathToFile
  }

  /// Fallback to English version in LottieAnimations/en/
  let fallbackPath = "\(baseName.rawValue)-en"
  if bundle.url(forResource: fallbackPath, withExtension: "json") != nil {
    return fallbackPath
  }
  return nil
}
