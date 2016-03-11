import UIKit.UIColor
import UIKit.UIFont

enum FontStyle: String {
  case Headline
  case Subhead
  case Body
  case Footnote
  case Caption1
  case Caption2
}

enum Weight: String {
  case Default
  case Medium
}

enum Color: String {
  case Black
  case Blue
  case BlueDark
  case BlueLight
  case BlueRoyal
  case Clear
  case Green
  case GreenLight
  case Gray
  case GrayBlack
  case GrayDark
  case GrayLight
  case GrayMedium
  case OffWhite
  case Mint
  case Pink
  case TextDefault
  case TextDarkGray
  case TextLightGray
  case White
  case Yellow

  enum Category: String {
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
  }

  enum Social:String {
    case FacebookBlue
    case TwitterBlue
  }
}

extension FontStyle {
  func toUIFont() -> UIFont {
    switch self {
    case .Headline:
      return UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    case .Subhead:
      return UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    case .Body:
      return UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    case .Footnote:
      return UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    case .Caption1:
      return UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    case .Caption2:
      return UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
    }
  }

  #if TARGET_OS_TV
  static let mismatchedFont = UIFont(name: "Courier New", size: 15.0)
  #else
  static let mismatchedFont = UIFont(name: "Marker Felt", size: 15.0)
  #endif
}

extension Color: Equatable {
  func toUIColor() -> UIColor {
    switch self {
    case .Black:          return .hex(0x000000)
    case .Blue:           return .hex(0x00a0ff)
    case .BlueDark:       return .hex(0x081245)
    case .BlueLight:      return .hex(0xe8f6ff)
    case .BlueRoyal:      return .hex(0x00a0ff)
    case .Clear:          return .clearColor()
    case .Green:          return .hex(0x2bde73)
    case .GreenLight:     return .hex(0xdef7e0)
    case .Gray:           return .hex(0xd9d9de)
    case .GrayBlack:      return .hex(0x464646)
    case .GrayDark:       return .hex(0x828587)
    case .GrayLight:      return .hex(0xf7fafa)
    case .GrayMedium:     return .hex(0xebebee)
    case .OffWhite:       return .hex(0xfafafa)
    case .Mint:           return .hex(0xe3fdf9)
    case .Pink:           return .hex(0xffecf0)
    case .TextDefault:    return .hex(0x000000)
    case .TextDarkGray:   return .hex(0x828587)
    case .TextLightGray:  return .hex(0xf7fafa)
    case .White:          return .hex(0xffffff)
    case .Yellow:         return .hex(0xffffc9)
    }
  }

  #if TARGET_OS_TV
  static let mismatchedColor = UIColor.redColor()
  #else
  static let mismatchedColor = UIColor.redColor()
  #endif
}

extension Color.Category: Equatable {
  func toUIColor() -> UIColor {
    switch self {
    case .Art:                  return .hex(0xffbdab)
    case .ArtSecondary:         return .hex(0xf7aa94)
    case .Comics:               return .hex(0xfffb78)
    case .ComicsSecondary:      return .hex(0xffe54f)
    case .Crafts:               return .hex(0xff81ac)
    case .CraftsSecondary:      return .hex(0xe35f8c)
    case .Dance:                return .hex(0xa695f9)
    case .DanceSecondary:       return .hex(0x6556ac)
    case .Design:               return .hex(0x2752ff)
    case .DesignSecondary:      return .hex(0x1935a6)
    case .Fashion:              return .hex(0xff9fd6)
    case .FashionSecondary:     return .hex(0x171717)
    case .Film:                 return .hex(0xff596e)
    case .FilmSecondary:        return .hex(0xcf3c4e)
    case .Food:                 return .hex(0xff3642)
    case .FoodSecondary:        return .hex(0xd12c36)
    case .Games:                return .hex(0x00c9ab)
    case .GamesSecondary:       return .hex(0x00a68d)
    case .Journalism:           return .hex(0x12bcea)
    case .JournalismSecondary:  return .hex(0x10a8d0)
    case .Music:                return .hex(0xa5ffd3)
    case .MusicSecondary:       return .hex(0x5ee5a3)
    case .Photography:          return .hex(0x00e3e5)
    case .PhotographySecondary: return .hex(0x00d4d6)
    case .Publishing:           return .hex(0xe2dcd0)
    case .PublishingSecondary:  return .hex(0xd1ccc0)
    case .Technology:           return .hex(0x6396fc)
    case .TechnologySecondary:  return .hex(0x326bdb)
    case .Theater:              return .hex(0xff7d5f)
    case .TheaterSecondary:     return .hex(0xe8514b)
    }
  }
}

extension Color.Social: Equatable {
  func toUIColor() -> UIColor {
    switch self {
    case .FacebookBlue: return .hex(0x3b5998)
    case .TwitterBlue:  return .hex(0x00aced)
    }
  }
}
