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
      ("Dark Green", .ksr_darkGreen),
      ("Green", .ksr_green),
      ("Light Green", .ksr_lightGreen),
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

  public static var ksr_black: UIColor {
    return .hex(0x000000)
  }

  public static var ksr_blue: UIColor {
    return .hex(0x00a0ff)
  }

  public static var ksr_darkBlue: UIColor {
    return .hex(0x081245)
  }

  public static var ksr_lightBlue: UIColor {
    return .hex(0xe8f6ff)
  }

  public static var ksr_royalBlue: UIColor {
    return .hex(0x00a0ff)
  }

  public static var ksr_clear: UIColor {
    return .clearColor()
  }

  public static var ksr_facebookBlue: UIColor {
    return .hex(0x3b5998)
  }

  public static var ksr_darkGreen: UIColor {
    return .hex(0x25CB68)
  }

  public static var ksr_green: UIColor {
    return .hex(0x2bde73)
  }

  public static var ksr_lightGreen: UIColor {
    return .hex(0xdef7e0)
  }

  public static var ksr_gray: UIColor {
    return .hex(0xd9d9de)
  }

  public static var ksr_blackGray: UIColor {
    return .hex(0x464646)
  }

  public static var ksr_darkGray: UIColor {
    return .hex(0x828587)
  }

  public static var ksr_lightGray: UIColor {
    return .hex(0xf7fafa)
  }

  public static var ksr_mediumGray: UIColor {
    return .hex(0xebebee)
  }

  public static var ksr_offWhite: UIColor {
    return .hex(0xfafafa)
  }

  public static var ksr_mint: UIColor {
    return .hex(0xe3fdf9)
  }

  public static var ksr_pink: UIColor {
    return .hex(0xffecf0)
  }

  public static var ksr_textDefault: UIColor {
    return .hex(0x000000)
  }

  public static var ksr_darkGrayText: UIColor {
    return .hex(0x828587)
  }

  public static var ksr_lightGrayText: UIColor {
    return .hex(0xf7fafa)
  }

  public static var ksr_twitterBlue: UIColor {
    return .hex(0x00aced)
  }

  public static var ksr_white: UIColor {
    return .hex(0xffffff)
  }

  public static var ksr_yellow: UIColor {
    return .hex(0xffffc9)
  }
}
