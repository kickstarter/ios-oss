import UIKit

public struct KSColor {
  public static let Black = UIColor.blackColor()
  public static let Blue = UIColor(red:0.0, green:0.63, blue:1.0, alpha:1.0)
  public static let BlueDark = UIColor(red:0.03, green:0.07, blue:0.27, alpha:1.0)
  public static let BlueLight = UIColor(red:0.91, green:0.96, blue:1.0, alpha:1.0)
  public static let BlueRoyal = UIColor(red:0.95, green:0.46, blue:0.18, alpha:1.0)
  public static let Green = UIColor(red:0.17, green:0.87, blue:0.45, alpha:1.0)
  public static let Gray = UIColor(red:0.85, green:0.85, blue:0.87, alpha:1.0)
  public static let GrayBlack = UIColor(white:0.27, alpha:1.0)
  public static let GrayDark = UIColor(red:0.51, green:0.52, blue:0.53, alpha:1.0)
  public static let GrayLight = UIColor(red:0.97, green:0.98, blue:0.98, alpha:1.0)
  public static let GrayMedium = UIColor(red:0.92, green:0.92, blue:0.93, alpha:1.0)
  public static let OffWhite = UIColor(white:0.98, alpha:1.0)
  public static let Mint = UIColor(red:0.89, green:0.99, blue:0.98, alpha:1.0)
  public static let Pink = UIColor(red:1.0, green:0.93, blue:0.94, alpha:1.0)
  public static let TextDark = UIColor(red:0.06, green:0.13, blue:0.02, alpha:1.0)
  public static let TextLight = UIColor.whiteColor()
  public static let White = UIColor.whiteColor()
  public static let Yellow = UIColor(red:0.92, green:0.92, blue:0.93, alpha:1.0)
}

public struct CategoryColor {
  public static let Art = UIColor(red:1.0, green:0.74, blue:0.67, alpha:1.0)
  public static let ArtSecondary = UIColor(red:0.97, green:0.67, blue:0.58, alpha:1.0)
  public static let Comics = UIColor(red:1.0, green:0.98, blue:0.47, alpha:1.0)
  public static let ComicsSecondary = UIColor(red:1.0, green:0.9, blue:0.31, alpha:1.0)
  public static let Crafts = UIColor(red:1.0, green:0.51, blue:0.67, alpha:1.0)
  public static let CraftsSecondary = UIColor(red:0.89, green:0.37, blue:0.55, alpha:1.0)
  public static let Dance = UIColor(red:0.65, green:0.58, blue:0.98, alpha:1.0)
  public static let DanceSecondary = UIColor(red:0.4, green:0.34, blue:0.67, alpha:1.0)
  public static let Design = UIColor(red:0.15, green:0.32, blue:1.0, alpha:1.0)
  public static let DesignSecondary = UIColor(red:0.1, green:0.21, blue:0.65, alpha:1.0)
  public static let Fashion = UIColor(red:1.0, green:0.62, blue:0.84, alpha:1.0)
  public static let FashionSecondary = UIColor(white:0.09, alpha:1.0)
  public static let Film = UIColor(red:1.0, green:0.35, blue:0.43, alpha:1.0)
  public static let FilmSecondary = UIColor(red:0.81, green:0.24, blue:0.31, alpha:1.0)
  public static let Food = UIColor(red:1.0, green:0.21, blue:0.26, alpha:1.0)
  public static let FoodSecondary = UIColor(red:0.82, green:0.17, blue:0.21, alpha:1.0)
  public static let Games = UIColor(red:0.0, green:0.79, blue:0.67, alpha:1.0)
  public static let GamesSecondary = UIColor(red:0.0, green:0.65, blue:0.55, alpha:1.0)
  public static let Journalism = UIColor(red:0.07, green:0.74, blue:0.92, alpha:1.0)
  public static let JournalismSecondary = UIColor(red:0.06, green:0.66, blue:0.82, alpha:1.0)
  public static let Music = UIColor(red:0.65, green:1.0, blue:0.83, alpha:1.0)
  public static let MusicSecondary = UIColor(red:0.37, green:0.9, blue:0.64, alpha:1.0)
  public static let Photography = UIColor(red:0.0, green:0.89, blue:0.9, alpha:1.0)
  public static let PhotographySecondary = UIColor(red:0.0, green:0.83, blue:0.84, alpha:1.0)
  public static let Publishing = UIColor(red:0.89, green:0.86, blue:0.82, alpha:1.0)
  public static let PublishingSecondary = UIColor(red:0.82, green:0.8, blue:0.75, alpha:1.0)
  public static let Technology = UIColor(red:0.39, green:0.59, blue:0.99, alpha:1.0)
  public static let TechnologySecondary = UIColor(red:0.2, green:0.42, blue:0.86, alpha:1.0)
  public static let Theater = UIColor(red:1.0, green:0.49, blue:0.37, alpha:1.0)
  public static let TheaterSecondary = UIColor(red:0.91, green:0.32, blue:0.29, alpha:1.0)

}

public struct SocialColor {
  public static let FacebookBlue = UIColor(red:0.23, green:0.35, blue:0.6, alpha:1.0)
  public static let TwitterBlue = UIColor(red:0.0, green:0.67, blue:0.93, alpha:1.0)
}

public extension UIColor {
  class func textPrimary() -> UIColor {
    return KSColor.Black
  }

  class func textSecondary() -> UIColor {
    return KSColor.GrayDark
  }

  class func textSecondaryLight() -> UIColor {
    return KSColor.GrayLight
  }

  class func accent() -> UIColor {
    return KSColor.Green
  }

  class func windowBackground() -> UIColor {
    return KSColor.White
  }

  class func discoveryPrimary() -> UIColor {
    return KSColor.BlueDark
  }

  class func discoverySecondary() -> UIColor {
    return KSColor.Black
  }

  class func discoveryBackground() -> UIColor {
    return KSColor.GrayLight
  }
}