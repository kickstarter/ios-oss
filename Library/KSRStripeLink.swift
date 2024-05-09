import Foundation

public class KSRStripeLink {
  // Link gives us a label like "Visa 1234"; reformat it to match our UI
  public static func formatLinkLabel(_ label: String) -> String? {
    do {
      // Find 4 digits in the string
      let regex = try NSRegularExpression(pattern: "\\d{4}")
      let matches = regex.matches(
        in: label,
        range: NSRange(location: 0, length: label.count)
      )

      guard let match = matches.first else {
        return nil
      }

      guard let range = Range(match.range, in: label) else {
        return nil
      }

      let lastFour = label[range]
      return "•••• \(lastFour)"

    } catch {
      return nil
    }
  }
}
