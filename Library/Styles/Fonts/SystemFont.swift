import UIKit

enum SystemFont: CustomFont, CaseIterable {
  case title1
  case title2
  case title3
  case headline
  case body
  case callout
  case subhead
  case footnote
  case caption1
  case caption2

  func font(size: CGFloat?) -> UIFont {
    let font = UIFont.preferredFont(
      forTextStyle: self.textStyle,
      compatibleWith: .current
    )
    let descriptor = font.fontDescriptor
    return UIFont(
      descriptor: descriptor,
      size: ceil(font.pointSize / self.defaultSize * (size ?? self.defaultSize))
    )
  }
}

extension SystemFont {
  var defaultSize: CGFloat {
    switch self {
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
    }
  }

  var textStyle: UIFont.TextStyle {
    switch self {
    case .title1: return .title1
    case .title2: return .title2
    case .title3: return .title3
    case .headline: return .headline
    case .body: return .body
    case .callout: return .callout
    case .subhead: return .subheadline
    case .footnote: return .footnote
    case .caption1: return .caption1
    case .caption2: return .caption2
    }
  }
}
