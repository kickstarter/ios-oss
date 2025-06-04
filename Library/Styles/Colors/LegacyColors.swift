import UIKit

@available(
  *,
  deprecated,
  message: "If you are using a legacy color, you should replace it with an appropriate semantic color from the new design system."
)
public struct LegacyColors {
  public static let ksr_black = LegacyColor(
    "legacy/ksr_black",
    lightMode: UIColor(coreColor: .black),
    darkMode: UIColor(coreColor: .white)
  )

  /// `ksr_white` functions mostly like surface/primary
  public static let ksr_white = LegacyColor(
    "legacy/ksr_white",
    lightMode: UIColor(coreColor: .white),
    darkMode: UIColor(coreColor: .gray_1000)
  )

  public static let ksr_alert = LegacyColor(
    "legacy/ksr_alert",
    lightMode: UIColor.hex(0xA12027),
    darkMode: UIColor(coreColor: .red_500)
  )

  public static let ksr_celebrate_500 = LegacyColor(
    "legacy/ksr_celebrate_500",
    lightMode: UIColor.hex(0xF97B62),
    darkMode: UIColor(coreColor: .orange_06)
  )

  public static let ksr_celebrate_700 = LegacyColor(
    "legacy/ksr_celebrate_700",
    lightMode: UIColor.hex(0xD8503D),
    darkMode: UIColor(coreColor: .orange_03)
  )

  public static let ksr_create_100 = LegacyColor(
    "legacy/ksr_create_100",
    lightMode: UIColor.hex(0xE6FAF1),
    darkMode: UIColor(coreColor: .green_09)
  )

  public static let ksr_create_300 = LegacyColor(
    "legacy/ksr_create_300",
    lightMode: UIColor.hex(0x9BEBC9),
    darkMode: UIColor(coreColor: .green_07)
  )

  public static let ksr_create_500 = LegacyColor(
    "legacy/ksr_create_500",
    lightMode: UIColor(coreColor: .green_05),
    darkMode: UIColor(coreColor: .green_06)
  )

  public static let ksr_create_700 = LegacyColor(
    "legacy/ksr_create_700",
    lightMode: UIColor.hex(0x028858),
    darkMode: UIColor(coreColor: .green_05)
  )

  public struct Background {
    public struct Action {
      /// Most of the buttons in our app used `create_700` as their background color. This has a light mode color equal to `create_700` but the inverted dark mode color of `background/action/primary`. Eventually this can be replaced with `background/action/primary`.
      public static let primary = LegacyColor(
        "legacy/background/action/primary",
        lightMode: UIColor.hex(0x028858),
        darkMode: UIColor(coreColor: .white)
      )

      public struct Primary {
        public static let pressed = LegacyColor(
          "legacy/background/action/primary/pressed",
          lightMode: UIColor.hex(0x015738),
          darkMode: UIColor(coreColor: .gray_300)
        )

        public static let disabled = LegacyColor(
          "legacy/background/action/primary/disabled",
          lightMode: UIColor.hex(0x5DB294),
          darkMode: UIColor(coreColor: .gray_600)
        )
      }
    }

    public static let search = LegacyColor(
      "legacy/background/search",
      lightMode: UIColor.hex(0xF3F3F3),
      darkMode: UIColor.hex(0x2C2C2C)
    )
  }

  public struct Facebook {
    public static let primary = LegacyColor(
      "legacy/facebook/primary",
      lightMode: UIColor.hex(0x1877F2),
      darkMode: UIColor(coreColor: .white)
    )

    public static let pressed = LegacyColor(
      "legacy/facebook/pressed",
      lightMode: UIColor.hex(0x1877F2).mixDarker(0.36),
      darkMode: UIColor(coreColor: .gray_300)
    )

    public static let disabled = LegacyColor(
      "legacy/facebook/disabled",
      lightMode: UIColor.hex(0x1877F2).mixLighter(0.36),
      darkMode: UIColor(coreColor: .gray_600)
    )
  }

  /// `support_100` functions mostly like surface/secondary
  public static let ksr_support_100 = LegacyColor(
    "legacy/ksr_support_100",
    lightMode: UIColor.hex(0xF3F3F3),
    darkMode: UIColor(coreColor: .black)
  )

  public static let ksr_support_200 = LegacyColor(
    "legacy/ksr_support_200",
    lightMode: UIColor.hex(0xE6E6E6),
    darkMode: UIColor(coreColor: .gray_800)
  )

  public static let ksr_support_300 = LegacyColor(
    "legacy/ksr_support_300",
    lightMode: UIColor.hex(0xD1D1D1),
    darkMode: UIColor(coreColor: .gray_700)
  )

  public static let ksr_support_400 = LegacyColor(
    "legacy/ksr_support_400",
    lightMode: UIColor.hex(0x696969),
    darkMode: UIColor.hex(0xA1A1A1)
  )

  public static let ksr_support_500 = LegacyColor(
    "legacy/ksr_support_500",
    lightMode: UIColor.hex(0x464646),
    darkMode: UIColor(coreColor: .gray_550)
  )

  public static let ksr_support_700 = LegacyColor(
    "legacy/ksr_support_700",
    lightMode: UIColor.hex(0x222222),
    darkMode: UIColor(coreColor: .gray_300)
  )

  public static let ksr_trust_100 = LegacyColor(
    "legacy/ksr_trust_100",
    lightMode: UIColor.hex(0xDBE7FF),
    darkMode: UIColor(coreColor: .blue_09)
  )

  public static let ksr_trust_500 = LegacyColor(
    "legacy/ksr_trust_500",
    lightMode: UIColor.hex(0x5555FF),
    darkMode: UIColor(coreColor: .blue_06)
  )

  public static let ksr_trust_700 = LegacyColor(
    "legacy/ksr_trust_700",
    lightMode: UIColor.hex(0x0A007D),
    darkMode: UIColor(coreColor: .blue_03)
  )

  public static let ksr_cell_separator = LegacyColor(
    "legacy/ksr_cell_separator",
    lightMode: UIColor.hex(0xDCDEDD),
    darkMode: UIColor(coreColor: .gray_800)
  )

  public struct Tags {
    public struct Success {
      public static let background = LegacyColor(
        "legacy/tags/success/background",
        lightMode: UIColor.hex(0xEFF8F5),
        darkMode: UIColor(coreColor: .green_02)
      )

      public static let foreground = LegacyColor(
        "legacy/tags/success/foreground",
        lightMode: UIColor.hex(0x028858),
        darkMode: UIColor(coreColor: .black)
      )
    }

    public struct Warn {
      public static let background = LegacyColor(
        "legacy/tags/warn/background",
        lightMode: UIColor.hex(0xFFF2EC),
        darkMode: UIColor.hex(0xFFF2EC)
      )

      public static let foreground = LegacyColor(
        "legacy/tags/warn/foreground",
        lightMode: UIColor.hex(0x696969),
        darkMode: UIColor(coreColor: .black)
      )
    }

    public struct Error {
      public static let background = LegacyColor(
        "legacy/tags/error/background",
        lightMode: UIColor(coreColor: .red_200),
        darkMode: UIColor(coreColor: .red_200)
      )

      public static let foreground = LegacyColor(
        "legacy/tags/error/foreground",
        lightMode: UIColor(coreColor: .red_800),
        darkMode: UIColor(coreColor: .black)
      )
    }
  }

  public struct Project {
    public struct Navigation {
      public static let selected = LegacyColor(
        "legacy/project/navigation/selected",
        lightMode: UIColor.hex(0x5555FF),
        darkMode: UIColor(coreColor: .white)
      )
    }
  }
}
