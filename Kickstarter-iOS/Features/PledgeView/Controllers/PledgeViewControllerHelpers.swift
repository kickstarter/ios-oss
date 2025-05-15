import KsApi
import Library
import UIKit

struct PledgeViewControllerHelpers {
  static func attributedLearnMoreText() -> NSAttributedString? {
    guard let trustLink = HelpType.trust.url(
      withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
    )?.absoluteString else { return nil }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 2

    let attributedLine1String = Strings.Kickstarter_is_not_a_store()
      .attributed(
        with: UIFont.ksr_footnote(),
        foregroundColor: LegacyColors.ksr_support_400.uiColor(),
        attributes: [.paragraphStyle: paragraphStyle],
        bolding: [Strings.Kickstarter_is_not_a_store()]
      )

    let line2String = Strings.Its_a_way_to_bring_creative_projects_to_life_Learn_more_about_accountability(
      trust_link: trustLink
    )

    guard let attributedLine2String = try? NSMutableAttributedString(
      data: Data(line2String.utf8),
      options: [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
      ],
      documentAttributes: nil
    ) else { return nil }

    let attributes: String.Attributes = [
      .font: UIFont.ksr_footnote(),
      .foregroundColor: LegacyColors.ksr_support_400.uiColor(),
      .paragraphStyle: paragraphStyle,
      .underlineStyle: 0
    ]

    let fullRange = (attributedLine2String.string as NSString).range(of: attributedLine2String.string)
    attributedLine2String.addAttributes(attributes, range: fullRange)

    let attributedString = attributedLine1String + NSAttributedString(string: "\n") + attributedLine2String

    return attributedString
  }
}
