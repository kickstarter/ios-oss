import UIKit

public struct Colors {
  public struct Text {
    public static let primary = SemanticColor(
      "text/primary",
      lightMode: .gray_1000,
      darkMode: .gray_100
    )

    public static let secondary = SemanticColor(
      "text/secondary",
      lightMode: .gray_700,
      darkMode: .gray_400
    )

    public static let disabled = SemanticColor(
      "text/disabled",
      lightMode: .gray_500,
      darkMode: .gray_600
    )

    public struct Accent {
      public static let red = SemanticColor(
        "text/accent/red",
        lightMode: .red_600,
        darkMode: .red_500
      )

      public struct Red {
        public static let disabled = SemanticColor(
          "text/accent/red/disabled",
          lightMode: .red_400,
          darkMode: .red_700
        )

        public static let bolder = SemanticColor(
          "text/accent/red/bolder",
          lightMode: .red_800,
          darkMode: .red_200
        )

        public struct Inverse {
          public static let disabled = SemanticColor(
            "text/accent/red/disabled/inverse",
            lightMode: .red_200,
            darkMode: .red_800
          )
        }
      }
    }

    public struct Inverse {
      public static let primary = SemanticColor(
        "text/inverse/primary",
        lightMode: .white,
        darkMode: .gray_1000
      )

      public static let disabled = SemanticColor(
        "text/inverse/disabled",
        lightMode: .gray_200,
        darkMode: .gray_900
      )
    }
  }

  public struct Background {
    public static let action = SemanticColor(
      "background/action",
      lightMode: .gray_1000,
      darkMode: .gray_100
    )

    public static let selected = SemanticColor(
      "background/selected",
      lightMode: .gray_900,
      darkMode: .gray_200
    )

    public struct Accent {
      public struct Gray {
        public static let disabled = SemanticColor(
          "background/accent/gray/disabled",
          lightMode: .gray_100,
          darkMode: .gray_850
        )

        public static let subtle = SemanticColor(
          "background/accent/gray/subtle",
          lightMode: .gray_200,
          darkMode: .gray_800
        )
      }

      public struct Green {
        public static let bold = SemanticColor(
          "background/accent/green/bold",
          lightMode: .green_06,
          darkMode: .green_05
        )

        public static let disabled = SemanticColor(
          "background/accent/green/disabled",
          lightMode: .green_01,
          darkMode: .green_09
        )

        public struct Bold {
          public static let pressed = SemanticColor(
            "background/accent/green/bold/pressed",
            lightMode: .green_08,
            darkMode: .green_03
          )
        }
      }

      public struct Red {
        public static let subtle = SemanticColor(
          "background/accent/red/subtle",
          lightMode: .red_200,
          darkMode: .red_900
        )
      }
    }

    public struct Action {
      public static let disabled = SemanticColor(
        "background/action/disabled",
        lightMode: .gray_500,
        darkMode: .gray_600
      )

      public static let pressed = SemanticColor(
        "background/action/pressed",
        lightMode: .gray_800,
        darkMode: .gray_300
      )
    }

    public struct Danger {
      public static let bold = SemanticColor(
        "background/danger/bold",
        lightMode: .red_600,
        darkMode: .red_500
      )

      public static let disabled = SemanticColor(
        "background/danger/disabled",
        lightMode: .red_400,
        darkMode: .red_1000
      )

      public static let subtle = SemanticColor(
        "background/danger/subtle",
        lightMode: .red_200,
        darkMode: .red_1000
      )

      public struct Bold {
        public static let pressed = SemanticColor(
          "background/danger/bold/pressed",
          lightMode: .red_800,
          darkMode: .red_300
        )
      }
    }

    public struct Inverse {
      public static let pressed = SemanticColor(
        "background/inverse/disabled",
        lightMode: .gray_300,
        darkMode: .gray_800
      )

      public static let disabled = SemanticColor(
        "background/inverse/pressed",
        lightMode: .gray_200,
        darkMode: .gray_850
      )
    }

    public struct Surface {
      public static let primary = SemanticColor(
        "background/surface/primary",
        lightMode: .white,
        darkMode: .gray_1000
      )
    }
  }

  public struct Border {
    public static let active = SemanticColor(
      "border/active",
      lightMode: .gray_700,
      darkMode: .gray_100
    )

    public static let bold = SemanticColor(
      "border/bold",
      lightMode: .gray_400,
      darkMode: .gray_550
    )

    public static let subtle = SemanticColor(
      "border/subtle",
      lightMode: .gray_300,
      darkMode: .gray_700
    )

    public struct Danger {
      public static let bold = SemanticColor(
        "border/danger/bold",
        lightMode: .red_800,
        darkMode: .red_300
      )

      public static let subtle = SemanticColor(
        "border/danger/subtle",
        lightMode: .red_400,
        darkMode: .red_600
      )
    }
  }

  public struct Icon {
    public static let green = SemanticColor(
      "icon/green",
      lightMode: .green_07,
      darkMode: .green_03
    )

    public static let danger = SemanticColor(
      "icon/danger",
      lightMode: .red_700,
      darkMode: .red_400
    )

    public static let primary = SemanticColor(
      "icon/primary",
      lightMode: .gray_800,
      darkMode: .gray_200
    )
  }
}

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

  public static let ksr_white = LegacyColor(
    "legacy/ksr_white",
    lightMode: UIColor(coreColor: .white),
    darkMode: UIColor(coreColor: .black)
  )

  public static let ksr_alert = LegacyColor(
    "legacy/ksr_alert",
    lightMode: UIColor.hex(0xA12027),
    darkMode: UIColor(coreColor: .red_500)
  )

  public static let ksr_celebrate_100 = LegacyColor(
    "legacy/ksr_celebrate_100",
    lightMode: UIColor.hex(0xFFF2EC),
    darkMode: UIColor(coreColor: .orange_09)
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
    lightMode: UIColor.hex(0x05CE78),
    darkMode: UIColor(coreColor: .green_06)
  )

  public static let ksr_create_700 = LegacyColor(
    "legacy/ksr_create_700",
    lightMode: UIColor.hex(0x028858),
    darkMode: UIColor(coreColor: .green_03)
  )

  public static let ksr_support_100 = LegacyColor(
    "legacy/ksr_support_100",
    lightMode: UIColor.hex(0xF3F3F3),
    darkMode: UIColor(coreColor: .gray_900)
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
    darkMode: UIColor(coreColor: .gray_600)
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
}
