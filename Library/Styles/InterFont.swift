import UIKit

public enum KSRFontStyle: CustomFont, CaseIterable {
  // Old Design System
  case title1, title2, title3, headline, body, callout, subhead, footnote, caption1, caption2

  // New Design System
  case heading2XL, headingXL, headingLG, headingMD, headingSM, headingXS
  case bodyXL, bodyLG, bodyMD, bodySM, bodyXS, bodyXXS

  public func font(size: CGFloat? = nil) -> UIFont {
    return UIFont.customFont(with: self, size: size)
  }
}

extension KSRFontStyle: CustomFontConfigurable {
  var fontName: String {
    switch self {
    case .heading2XL, .headingXL, .headingLG, .headingMD, .headingSM,
         .headingXS: return "Inter-Regular_Medium"
    case .headline: return "Inter-Regular_SemiBold"
    default: return "Inter-Regular"
    }
  }

  var boldFontName: String {
    switch self {
    case .heading2XL, .headingXL, .headingLG, .headingMD, .headingSM, .headingXS: return "Inter-Regular_Bold"
    case .headline: return "Inter-Regular_ExtraBold"
    default: return "Inter-SemiBold"
    }
  }

  var defaultSize: CGFloat {
    switch self {
    // Old Design System
    case .title1: return 28
    case .title2: return 22
    case .title3: return 20
    case .headline: return 17
    case .body: return 17
    case .callout: return 16
    case .subhead: return 15
    case .footnote: return 13
    case .caption1: return 12
    case .caption2: return 11

    // New Design System
    case .heading2XL: return 24
    case .headingXL: return 20
    case .headingLG: return 16
    case .headingMD: return 14
    case .headingSM: return 12
    case .headingXS: return 11
    case .bodyXL: return 20
    case .bodyLG: return 16
    case .bodyMD: return 14
    case .bodySM: return 12
    case .bodyXS: return 11
    case .bodyXXS: return 10
    }
  }

  var textStyle: UIFont.TextStyle {
    switch self {
    // Old Design System
    case .title1: return .title1
    case .title2: return .title2
    case .title3: return .title3
    case .headline: return .headline
    case .body: return .body
    case .callout: return .callout
    case .subhead: return .subheadline
    case .footnote: return .footnote
    case .caption1: return .caption1
    case .caption2: return .caption1

    // New Desing System
    case .heading2XL: return .largeTitle
    case .headingXL: return .title1
    case .headingLG: return .title2
    case .headingMD: return .title3
    case .headingSM: return .headline
    case .headingXS: return .subheadline
    case .bodyXL: return .body
    case .bodyLG: return .callout
    case .bodyMD: return .footnote
    case .bodySM: return .caption1
    case .bodyXS, .bodyXXS: return .caption1
    }
  }
}
