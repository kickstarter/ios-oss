import UIKit

public enum CoreColor: Int {
  case white = 0xFFFFFF
  case black = 0x000000

  case gray_100 = 0xFAFAFA
  case gray_200 = 0xF2F2F2
  case gray_300 = 0xE0E0E0
  case gray_400 = 0xC9C9C9
  case gray_500 = 0xB3B3B3
  case gray_550 = 0x858585
  case gray_600 = 0x636363
  case gray_700 = 0x4D4D4D
  case gray_800 = 0x3C3C3C
  case gray_850 = 0x363636
  case gray_900 = 0x2C2C2C
  case gray_950 = 0x212121
  case gray_1000 = 0x171717

  case green_01 = 0xEBFEF6
  case green_02 = 0xD2FEEB
  case green_03 = 0x79FCC3
  case green_04 = 0x06E584
  case green_05 = 0x05CE78
  case green_06 = 0x037242
  case green_07 = 0x025A34
  case green_08 = 0x024629
  case green_09 = 0x01321D
  case green_10 = 0x011E11

  case yellow_01 = 0xFEFAF0
  case yellow_02 = 0xFDF2D3
  case yellow_03 = 0xF9DD90
  case yellow_04 = 0xF5C43D
  case yellow_05 = 0xE4AA0C
  case yellow_06 = 0x836207
  case yellow_07 = 0x614805
  case yellow_08 = 0x4E3A04
  case yellow_09 = 0x3A2B03
  case yellow_10 = 0x241B02

  case orange_01 = 0xFFF9F5
  case orange_02 = 0xFEEDE2
  case orange_03 = 0xFCD8C0
  case orange_04 = 0xF9BD94
  case orange_05 = 0xF79F64
  case orange_06 = 0xA54709
  case orange_07 = 0x7E3607
  case orange_08 = 0x662C05
  case orange_09 = 0x441E04
  case orange_10 = 0x241002

  case red_100 = 0xFFFAFA
  case red_200 = 0xFEF2F1
  case red_300 = 0xFBDDDB
  case red_400 = 0xF7BBB7
  case red_500 = 0xF39C95
  case red_550 = 0xE5271A
  case red_600 = 0xB81F14
  case red_700 = 0x931910
  case red_800 = 0x73140D
  case red_900 = 0x530E09
  case red_1000 = 0x2E0805

  case purple_01 = 0xFDFBFE
  case purple_02 = 0xF8F3FC
  case purple_03 = 0xEADBF5
  case purple_04 = 0xDCC3EF
  case purple_05 = 0xCBA6E7
  case purple_06 = 0x8936C9
  case purple_07 = 0x6B2A9D
  case purple_08 = 0x582281
  case purple_09 = 0x3F195D
  case purple_10 = 0x210D30

  case blue_01 = 0xFAFAFF
  case blue_02 = 0xF1F1FE
  case blue_03 = 0xDEDEFC
  case blue_04 = 0xC6C6FA
  case blue_05 = 0xAFAFF9
  case blue_06 = 0x4C4CF0
  case blue_07 = 0x1212E2
  case blue_08 = 0x0F0FBD
  case blue_09 = 0x0B0B89
  case blue_10 = 0x050543
}

extension UIColor {
  convenience init(coreColor: CoreColor) {
    let rgbValue = coreColor.rawValue
    self.init(
      red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: Double(rgbValue & 0x0000FF) / 255.0,
      alpha: 1.0
    )
  }
}
