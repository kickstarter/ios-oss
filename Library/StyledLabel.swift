import UIKit.UILabel

@IBDesignable
public class StyledLabel: UILabel {
  enum Style: String {
    case TextPrimary = "TextPrimary"
    case TextSecondary = "TextSecondary"
    case TextWhite = "TextWhite"
    case CaptionPrimary = "CaptionPrimary"
    case CaptionPrimaryMedium = "CaptionPrimaryMedium"
    case CaptionSecondary = "CaptionSecondary"
    case CaptionSecondaryMedium = "CaptionSecondaryMedium"
    case BodyPrimary = "BodyPrimary"
    case BodyPrimaryMedium = "BodyPrimaryMedium"
    case BodySecondary = "BodySecondary"
    case BodyWhite = "BodyWhite"
    case SubheadPrimary = "SubheadPrimary"
    case SubheadPrimaryMedium = "SubheadPrimaryMedium"
    case SubheadSecondaryMedium = "SubheadSecondaryMedium"
    case Headline = "Headline"
    case HeadlineEditorial = "HeadlineEditorial"
    case SubheadEditorial = "SubheadEditorial"
    case SubheadEditorialMedium = "SubheadEditorialMedium"
  }

  enum Size: CGFloat {
    case Normal = 15.0
    case Body = 14.0
    case Caption = 12.0
    case Headline = 18.0
    case HeadlineEditorial = 22.0
    case Subhead = 16.0
    case SubheadEditorial = 20.0
  }

  @IBInspectable
  public var style: String {
    set(value) {
      var color = UIColor.textPrimary()
      var weight = UIFontWeightRegular
      var size = Size.Normal.rawValue

      if let styled = Style(rawValue: value) {
        switch styled {
        case .TextPrimary: break
        case .TextSecondary:
          color = UIColor.textSecondary()
        case .TextWhite:
          color = KSColor.White.color
        case .CaptionPrimary:
          size = Size.Caption.rawValue
        case .CaptionPrimaryMedium:
          size = Size.Caption.rawValue
          weight = UIFontWeightMedium
        case .CaptionSecondary:
          color = UIColor.textSecondary()
          size = Size.Caption.rawValue
        case .CaptionSecondaryMedium:
          color = UIColor.textSecondary()
          size = Size.Caption.rawValue
          weight = UIFontWeightMedium
        case .BodyPrimary:
          size = Size.Body.rawValue
        case .BodyPrimaryMedium:
          size = Size.Body.rawValue
          weight = UIFontWeightMedium
        case .BodySecondary:
          color = UIColor.textSecondary()
          size = Size.Body.rawValue
        case .BodyWhite:
          color = KSColor.White.color
          size = Size.Body.rawValue
        case .SubheadPrimary:
          size = Size.Subhead.rawValue
        case .SubheadPrimaryMedium:
          size = Size.Subhead.rawValue
          weight = UIFontWeightMedium
        case .SubheadSecondaryMedium:
          color = UIColor.textSecondary()
          weight = UIFontWeightMedium
        case .Headline:
          size = Size.Headline.rawValue
          weight = UIFontWeightMedium
        case .HeadlineEditorial:
          size = Size.HeadlineEditorial.rawValue
          weight = UIFontWeightMedium
        case .SubheadEditorial:
          size = Size.SubheadEditorial.rawValue
        case .SubheadEditorialMedium:
          size = Size.SubheadEditorial.rawValue
          weight = UIFontWeightMedium
        }
      }

      self.font = UIFont.systemFontOfSize(size, weight: weight)
      self.textColor = color
    }

    get {
      return self.style
    }
  }
}

