import UIKit

extension UIColor {
  public static var ksr_allColors: [(name: String, color: UIColor)] {
    return [
      ("Black", .ksr_black),
      ("Blue", .ksr_blue),
      ("Dark Blue", .ksr_darkBlue),
      ("Light Blue", .ksr_lightBlue),
      ("Royal Blue", .ksr_royalBlue),
      ("Clear", .ksr_clear),
      ("Facebook Blue", .ksr_facebookBlue),
      ("Golden Bell", .ksr_goldenBell),
      ("Coral", .ksr_coral(weight: 400)),
      ("Green", .ksr_green(weight: 400)),
      ("Grey", .ksr_grey(weight: 400)),
      ("Navy", .ksr_navy(weight: 400)),
      ("Teal", .ksr_orange(weight: 400)),
      ("Teal", .ksr_peach(weight: 400)),
      ("Sage", .ksr_sage(weight: 400)),
      ("Red", .ksr_red(weight: 500)),
      ("Teal", .ksr_teal(weight: 400)),
      ("Violet", .ksr_violet(weight: 400)),
      ("Gray", .ksr_gray),
      ("Black Gray", .ksr_blackGray),
      ("Dark Gray", .ksr_darkGray),
      ("Light Gray", .ksr_lightGray),
      ("Medium Gray", .ksr_mediumGray),
      ("Off White", .ksr_offWhite),
      ("Mint", .ksr_mint),
      ("Pink", .ksr_pink),
      ("Text Default", .ksr_textDefault),
      ("Dark Gray Text", .ksr_darkGrayText),
      ("Light Gray Text", .ksr_lightGrayText),
      ("Twitter Blue", .ksr_twitterBlue),
      ("White", .ksr_white),
      ("Yellow", .ksr_yellow)
    ]
  }

  public static func ksr_coral(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200:            return .hex(0xF0E9EF)
    case 300, 400:            return .hex(0xFE8485)
    case 500:                 return .hex(0xF46969)
    case 600:                 return .hex(0xFE446B)
    case 700, 800, 900:       return .hex(0x4A0A3F)
    default:
      fatalError()
    }
  }

  public static func ksr_green(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200:            return .hex(0xe5f3e9)
    case 300:                 return .hex(0xceebd7)
    case 400:                 return .hex(0x2bde73)
    case 500:                 return .hex(0x25cb68)
    case 600, 700, 800, 900:  return .hex(0x05af3c)
    default:
      fatalError()
    }
  }

  public static func ksr_grey(weight weight: Int) -> UIColor {
    switch weight {
    case 100:                     return .hex(0xFBFBFA)
    case 200:                     return .hex(0xF7F7F6)
    case 300:                     return .hex(0xF2F2F2)
    case 400:                     return .hex(0xEDEDED)
    case 500, 600, 700, 800, 900: return .hex(0xDCDEDD)
    default:
      fatalError()
    }
  }

  public static func ksr_navy(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200:                return .hex(0xF7F7F9)
    case 300:                     return .hex(0xEFEFF3)
    case 350:                     return .hex(0xEBEEF2)
    case 400:                     return .hex(0xDBDEE7)
    case 500:                     return .hex(0x95959E)
    case 600:                     return .hex(0x6B7180)
    case 700:                     return .hex(0x062340)
    case 800, 900:                return .hex(0x020621)
    default:
      fatalError()
    }
  }

  public static func ksr_orange(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200, 300:            return .hex(0xE8E1CE)
    case 400:                      return .hex(0xF7AA1A)
    case 500, 600, 700, 800, 900:  return .hex(0xE58111)
    default:
      fatalError()
    }
  }

  public static func ksr_peach(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200, 300:            return .hex(0xF4E9D8)
    case 350:                      return .hex(0xF6E3D8)
    case 400:                      return .hex(0xF4DACC)
    case 500, 600:                 return .hex(0xFF6A59)
    case 700, 800, 900:            return .hex(0xFD4616)
    default:
      fatalError()
    }
  }

  public static func ksr_red(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200, 300, 400, 500, 600, 700, 800, 900:
      return .hex(0xEF0707)
    default:
      fatalError()
    }
  }

  public static func ksr_sage(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200, 300:           return .hex(0xE6EBE2)
    case 400:                     return .hex(0xD1E4DE)
    case 500, 600, 700, 800, 900: return .hex(0xD7DED9)
    default:
      fatalError()
    }
  }

  public static func ksr_teal(weight weight: Int) -> UIColor {
    switch weight {
    case 100, 200, 300:       return .hex(0x96D8DB)
    case 400:                 return .hex(0x2DBECF)
    case 500:                 return .hex(0x21ABBB)
    case 600, 700, 800, 900:  return .hex(0x122C49)
    default:
      fatalError()
    }
  }

  public static func ksr_violet(weight weight: Int) -> UIColor {
    switch weight {
    case 100:                 return .hex(0xF8F9FD)
    case 200:                 return .hex(0xE3ECFA)
    case 300:                 return .hex(0xCACDF6)
    case 400:                 return .hex(0xD4C2F2)
    case 500:                 return .hex(0x997EF2)
    case 600, 700, 800:       return .hex(0x504083)
    case 850:                 return .hex(0x392B84)
    case 900:                 return .hex(0x0B055E)
    default:
      fatalError()
    }
  }

  @available(*, deprecated=1.0)
  public static var ksr_black: UIColor {
    return .hex(0x000000)
  }

  @available(*, deprecated=1.0)
  public static var ksr_blue: UIColor {
    return .hex(0x00a0ff)
  }

  @available(*, deprecated=1.0)
  public static var ksr_darkBlue: UIColor {
    return .hex(0x081245)
  }

  @available(*, deprecated=1.0)
  public static var ksr_lightBlue: UIColor {
    return .hex(0xe8f6ff)
  }

  @available(*, deprecated=1.0)
  public static var ksr_royalBlue: UIColor {
    return .hex(0x00a0ff)
  }

  public static var ksr_clear: UIColor {
    return .clearColor()
  }

  public static var ksr_facebookBlue: UIColor {
    return .hex(0x3b5998)
  }

  @available(*, deprecated=1.0)
  public static var ksr_goldenBell: UIColor {
    return .hex(0xD79211)
  }

  @available(*, deprecated=1.0)
  public static var ksr_gray: UIColor {
    return .hex(0xd9d9de)
  }

  @available(*, deprecated=1.0)
  public static var ksr_blackGray: UIColor {
    return .hex(0x464646)
  }

  @available(*, deprecated=1.0)
  public static var ksr_darkGray: UIColor {
    return .hex(0x828587)
  }

  @available(*, deprecated=1.0)
  public static var ksr_lightGray: UIColor {
    return .hex(0xf7fafa)
  }

  @available(*, deprecated=1.0)
  public static var ksr_mediumGray: UIColor {
    return .hex(0xebebee)
  }

  @available(*, deprecated=1.0)
  public static var ksr_offWhite: UIColor {
    return .hex(0xfafafa)
  }

  @available(*, deprecated=1.0)
  public static var ksr_mint: UIColor {
    return .hex(0xe3fdf9)
  }

  @available(*, deprecated=1.0)
  public static var ksr_pink: UIColor {
    return .hex(0xffecf0)
  }

  @available(*, deprecated=1.0)
  public static var ksr_textDefault: UIColor {
    return .hex(0x000000)
  }

  @available(*, deprecated=1.0)
  public static var ksr_darkGrayText: UIColor {
    return .hex(0x828587)
  }

  @available(*, deprecated=1.0)
  public static var ksr_lightGrayText: UIColor {
    return .hex(0xf7fafa)
  }

  public static var ksr_twitterBlue: UIColor {
    return .hex(0x00aced)
  }

  @available(*, deprecated=1.0)
  public static var ksr_white: UIColor {
    return .hex(0xffffff)
  }

  @available(*, deprecated=1.0)
  public static var ksr_yellow: UIColor {
    return .hex(0xffffc9)
  }
}
