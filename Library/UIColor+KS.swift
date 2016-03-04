import UIKit

public struct _Color {
  public static let Black = UIColor.redColor()


}

public enum KSColor {
  case Black
  case Blue
  case BlueDark
  case BlueLight
  case BlueRoyal
  case Green
  case Gray
  case GrayBlack
  case GrayDark
  case GrayLight
  case GrayMedium
  case OffWhite
  case Mint
  case Pink
  case TextDark
  case TextLight
  case White
  case Yellow

  var color: UIColor {
    switch self {
    case .Black: return UIColor.blackColor()
    case .Blue: return UIColor(red:0.0, green:0.63, blue:1.0, alpha:1.0)
    case .BlueDark: return UIColor(red:0.03, green:0.07, blue:0.27, alpha:1.0)
    case .BlueLight: return UIColor(red:0.91, green:0.96, blue:1.0, alpha:1.0)
    case .BlueRoyal: return UIColor(red:0.95, green:0.46, blue:0.18, alpha:1.0)
    case .Green: return UIColor(red:0.17, green:0.87, blue:0.45, alpha:1.0)
    case .Gray: return UIColor(red:0.85, green:0.85, blue:0.87, alpha:1.0)
    case .GrayBlack: return UIColor(white:0.27, alpha:1.0)
    case .GrayDark: return UIColor(red:0.51, green:0.52, blue:0.53, alpha:1.0)
    case .GrayLight: return UIColor(red:0.97, green:0.98, blue:0.98, alpha:1.0)
    case .GrayMedium: return UIColor(red:0.92, green:0.92, blue:0.93, alpha:1.0)
    case .OffWhite: return UIColor(white:0.98, alpha:1.0)
    case .Mint: return UIColor(red:0.89, green:0.99, blue:0.98, alpha:1.0)
    case .Pink: return UIColor(red:1.0, green:0.93, blue:0.94, alpha:1.0)
    case .TextDark: return UIColor(red:0.06, green:0.13, blue:0.02, alpha:1.0)
    case .TextLight: return UIColor.whiteColor()
    case .White: return UIColor.whiteColor()
    case .Yellow: return UIColor(red:0.92, green:0.92, blue:0.93, alpha:1.0)
    }
  }
}

public enum CategoryColor {
  case Art
  case ArtSecondary
  case Comics
  case ComicsSecondary
  case Crafts
  case CraftsSecondary
  case Dance
  case DanceSecondary
  case Design
  case DesignSecondary
  case Fashion
  case FashionSecondary
  case Film
  case FilmSecondary
  case Food
  case FoodSecondary
  case Games
  case GamesSecondary
  case Journalism
  case JournalismSecondary
  case Music
  case MusicSecondary
  case Photography
  case PhotographySecondary
  case Publishing
  case PublishingSecondary
  case Technology
  case TechnologySecondary
  case Theater
  case TheaterSecondary

  var color: UIColor {
    switch self {
    case .Art: return UIColor(red:1.0, green:0.74, blue:0.67, alpha:1.0)
    case .ArtSecondary: return UIColor(red:0.97, green:0.67, blue:0.58, alpha:1.0)
    case .Comics: return UIColor(red:1.0, green:0.98, blue:0.47, alpha:1.0)
    case .ComicsSecondary: return UIColor(red:1.0, green:0.9, blue:0.31, alpha:1.0)
    case .Crafts: return UIColor(red:1.0, green:0.51, blue:0.67, alpha:1.0)
    case .CraftsSecondary: return UIColor(red:0.89, green:0.37, blue:0.55, alpha:1.0)
    case .Dance: return UIColor(red:0.65, green:0.58, blue:0.98, alpha:1.0)
    case .DanceSecondary: return UIColor(red:0.4, green:0.34, blue:0.67, alpha:1.0)
    case .Design: return UIColor(red:0.15, green:0.32, blue:1.0, alpha:1.0)
    case .DesignSecondary: return UIColor(red:0.1, green:0.21, blue:0.65, alpha:1.0)
    case .Fashion: return UIColor(red:1.0, green:0.62, blue:0.84, alpha:1.0)
    case .FashionSecondary: return UIColor(white:0.09, alpha:1.0)
    case .Film: return UIColor(red:1.0, green:0.35, blue:0.43, alpha:1.0)
    case .FilmSecondary: return UIColor(red:0.81, green:0.24, blue:0.31, alpha:1.0)
    case .Food: return UIColor(red:1.0, green:0.21, blue:0.26, alpha:1.0)
    case .FoodSecondary: return UIColor(red:0.82, green:0.17, blue:0.21, alpha:1.0)
    case .Games: return UIColor(red:0.0, green:0.79, blue:0.67, alpha:1.0)
    case .GamesSecondary: return UIColor(red:0.0, green:0.65, blue:0.55, alpha:1.0)
    case .Journalism: return UIColor(red:0.07, green:0.74, blue:0.92, alpha:1.0)
    case .JournalismSecondary: return UIColor(red:0.06, green:0.66, blue:0.82, alpha:1.0)
    case .Music: return UIColor(red:0.65, green:1.0, blue:0.83, alpha:1.0)
    case .MusicSecondary: return UIColor(red:0.37, green:0.9, blue:0.64, alpha:1.0)
    case .Photography: return UIColor(red:0.0, green:0.89, blue:0.9, alpha:1.0)
    case .PhotographySecondary: return UIColor(red:0.0, green:0.83, blue:0.84, alpha:1.0)
    case .Publishing: return UIColor(red:0.89, green:0.86, blue:0.82, alpha:1.0)
    case .PublishingSecondary: return UIColor(red:0.82, green:0.8, blue:0.75, alpha:1.0)
    case .Technology: return UIColor(red:0.39, green:0.59, blue:0.99, alpha:1.0)
    case .TechnologySecondary: return UIColor(red:0.2, green:0.42, blue:0.86, alpha:1.0)
    case .Theater: return UIColor(red:1.0, green:0.49, blue:0.37, alpha:1.0)
    case .TheaterSecondary: return UIColor(red:0.91, green:0.32, blue:0.29, alpha:1.0)
    }
  }
}

public enum SocialColor {
  case FacebookBlue
  case TwitterBlue

  var color: UIColor {
    switch self {
    case .FacebookBlue: return UIColor(red:0.23, green:0.35, blue:0.6, alpha:1.0)
    case .TwitterBlue: return UIColor(red:0.0, green:0.67, blue:0.93, alpha:1.0)
    }
  }
}

public extension UIColor {
  class func textPrimary() -> UIColor {
    return KSColor.Black.color
  }

  class func textSecondary() -> UIColor {
    return KSColor.GrayDark.color
  }

  class func textSecondaryLight() -> UIColor {
    return KSColor.GrayLight.color
  }

  class func accent() -> UIColor {
    return KSColor.Green.color
  }

  class func windowBackground() -> UIColor {
    return KSColor.White.color
  }

  class func discoveryPrimary() -> UIColor {
    return KSColor.BlueDark.color
  }

  class func discoverySecondary() -> UIColor {
    return KSColor.Black.color
  }

  class func discoveryBackground() -> UIColor {
    return KSColor.GrayLight.color
  }
}