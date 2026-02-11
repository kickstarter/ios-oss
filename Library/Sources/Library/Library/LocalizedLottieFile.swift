import Foundation

/// Returns the correct Lottie filename based on current locale, with fallback to English.
func localizedOnboardingLottieFile(
  for baseName: String,
  in bundle: Bundle
) -> String? {
  let langCode = AppEnvironment.current.language.rawValue
  let pathToFile = "\(baseName)-\(langCode)"

  /// Check if the file exists
  if bundle.url(
    forResource: "\(baseName)-\(langCode)",
    withExtension: "json"
  ) != nil {
    return pathToFile
  }

  /// Fallback to English version in LottieAnimations/en/
  let fallbackPath = "\(baseName)-en"
  if bundle.url(forResource: fallbackPath, withExtension: "json") != nil {
    return fallbackPath
  }

  return nil
}
