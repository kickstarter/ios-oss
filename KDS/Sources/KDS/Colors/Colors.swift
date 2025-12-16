// swiftlint:disable file_length
import UIKit

// swiftlint:disable:next type_body_length
public struct Colors {
  public static let scrim = SemanticColor(
    "scrim",
    lightMode: .black,
    lightModeAlpha: 0.32,
    darkMode: .black,
    darkModeAlpha: 0.5
  )

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

    public static let placeholder = SemanticColor(
      "text/placeholder",
      lightMode: .gray_600,
      darkMode: .gray_500
    )

    public struct Accent {
      public static let gray = SemanticColor(
        "text/accent/gray",
        lightMode: .gray_1000,
        darkMode: .gray_200
      )

      public static let green = SemanticColor(
        "text/accent/green",
        lightMode: .green_06,
        darkMode: .green_05
      )

      public static let red = SemanticColor(
        "text/accent/red",
        lightMode: .red_600,
        darkMode: .red_500
      )

      public struct Blue {
        public static let bolder = SemanticColor(
          "text/accent/blue/bolder",
          lightMode: .blue_08,
          darkMode: .blue_02
        )
      }

      public struct Green {
        public static let bolder = SemanticColor(
          "text/accent/green/bolder",
          lightMode: .green_08,
          darkMode: .green_02
        )
      }

      public struct Purple {
        public static let bolder = SemanticColor(
          "text/accent/purple/bolder",
          lightMode: .purple_08,
          darkMode: .purple_02
        )
      }

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

      public struct Yellow {
        public static let bolder = SemanticColor(
          "text/accent/yellow/bolder",
          lightMode: .yellow_08,
          darkMode: .yellow_02
        )
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

    public struct Action {
      public static let disabled = SemanticColor(
        "text/action/disabled",
        lightMode: .gray_500,
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

    public static let disabled = SemanticColor(
      "background/disabled",
      lightMode: .gray_400,
      darkMode: .gray_700
    )

    public static let selected = SemanticColor(
      "background/selected",
      lightMode: .gray_900,
      darkMode: .gray_200
    )

    public struct Accent {
      public struct Blue {
        public static let disabled = SemanticColor(
          "background/accent/blue/disabled",
          lightMode: .blue_01,
          darkMode: .blue_10
        )

        public static let subtle = SemanticColor(
          "background/accent/blue/subtle",
          lightMode: .blue_02,
          darkMode: .blue_09
        )
      }

      public struct Gray {
        public static let bold = SemanticColor(
          "background/accent/gray/bold",
          lightMode: .gray_600,
          darkMode: .gray_500
        )

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

        public static let subtle = SemanticColor(
          "background/accent/green/subtle",
          lightMode: .green_02,
          darkMode: .green_08
        )

        public struct Bold {
          public static let pressed = SemanticColor(
            "background/accent/green/bold/pressed",
            lightMode: .green_08,
            darkMode: .green_03
          )
        }
      }

      public struct Purple {
        public static let disabled = SemanticColor(
          "background/accent/purple/disabled",
          lightMode: .purple_01,
          darkMode: .purple_09
        )

        public static let subtle = SemanticColor(
          "background/accent/purple/subtle",
          lightMode: .purple_02,
          darkMode: .purple_08
        )
      }

      public struct Red {
        public static let disabled = SemanticColor(
          "background/accent/red/disabled",
          lightMode: .red_100,
          darkMode: .red_1000
        )

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

      public static let overlaidButton = SemanticColor(
        "background/action/overlaidButton",
        lightMode: .white,
        lightModeAlpha: 0.9,
        darkMode: .gray_900,
        darkModeAlpha: 0.9
      )

      public static let pressed = SemanticColor(
        "background/action/pressed",
        lightMode: .gray_800,
        darkMode: .gray_300
      )

      public static let primary = SemanticColor(
        "background/action/primary",
        lightMode: .green_06,
        darkMode: .white
      )

      public struct OverlaidButton {
        public static let pressed = SemanticColor(
          "background/action/overlaidButton/pressed",
          lightMode: .gray_300,
          lightModeAlpha: 0.9,
          darkMode: .gray_800,
          darkModeAlpha: 0.9
        )
      }

      public struct Primary {
        public static let pressed = SemanticColor(
          "background/action/primary/pressed",
          lightMode: .green_08,
          darkMode: .gray_300
        )

        public static let disabled = SemanticColor(
          "background/action/primary/disabled",
          lightMode: .green_01,
          darkMode: .gray_600
        )
      }
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

    public struct Warning {
      public static let disabled = SemanticColor(
        "background/warning/disabled",
        lightMode: .yellow_01,
        darkMode: .yellow_09
      )

      public static let subtle = SemanticColor(
        "background/warning/subtle",
        lightMode: .yellow_02,
        darkMode: .yellow_08
      )
    }

    public struct Inverse {
      public static let pressed = SemanticColor(
        "background/inverse/pressed",
        lightMode: .gray_300,
        darkMode: .gray_800
      )

      public static let disabled = SemanticColor(
        "background/inverse/disabled",
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

      public static let secondary = SemanticColor(
        "background/surface/secondary",
        lightMode: .gray_100,
        darkMode: .black
      )

      public static let inverse = SemanticColor(
        "background/surface/inverse",
        lightMode: .gray_1000,
        darkMode: .white
      )

      public static let raised = SemanticColor(
        "background/surface/raised",
        lightMode: .white,
        darkMode: .gray_950
      )

      public static let raisedHigher = SemanticColor(
        "background/surface/raisedHigher",
        lightMode: .white,
        darkMode: .gray_900
      )

      public static let overlay = SemanticColor(
        "background/surface/overlay",
        lightMode: .white,
        darkMode: .gray_900
      )
    }
  }

  public struct Brand {
    /// Kickstarter brand green. Inverts to the same brand color in dark mode.
    public static let logo = SemanticColor(
      "brand/logo",
      lightMode: .green_05,
      darkMode: .green_05
    )
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

    public static let disabled = SemanticColor(
      "border/disabled",
      lightMode: .gray_200,
      darkMode: .gray_800
    )

    public static let focus = SemanticColor(
      "border/focus",
      lightMode: .blue_05,
      darkMode: .blue_05
    )

    public static let inverse = SemanticColor(
      "border/inverse",
      lightMode: .white,
      darkMode: .gray_1000
    )

    public static let subtle = SemanticColor(
      "border/subtle",
      lightMode: .gray_300,
      darkMode: .gray_700
    )

    public struct Accent {
      public struct Blue {
        public static let bold = SemanticColor(
          "border/accent/blue/bold",
          lightMode: .blue_08,
          darkMode: .blue_03
        )

        public static let subtle = SemanticColor(
          "border/accent/blue/subtle",
          lightMode: .blue_04,
          darkMode: .blue_06
        )
      }

      public struct Green {
        public static let bold = SemanticColor(
          "border/accent/green/bold",
          lightMode: .green_08,
          darkMode: .green_03
        )

        public static let subtle = SemanticColor(
          "border/accent/green/subtle",
          lightMode: .green_04,
          darkMode: .green_06
        )
      }
    }

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

    public struct Warning {
      public static let bold = SemanticColor(
        "border/warning/bold",
        lightMode: .yellow_08,
        darkMode: .yellow_03
      )

      public static let subtle = SemanticColor(
        "border/warning/subtle",
        lightMode: .yellow_04,
        darkMode: .yellow_06
      )
    }
  }

  public struct Icon {
    public static let danger = SemanticColor(
      "icon/danger",
      lightMode: .red_700,
      darkMode: .red_400
    )

    public static let disabled = SemanticColor(
      "icon/disabled",
      lightMode: .gray_500,
      darkMode: .gray_600
    )

    public static let green = SemanticColor(
      "icon/green",
      lightMode: .green_07,
      darkMode: .green_03
    )

    public static let info = SemanticColor(
      "icon/info",
      lightMode: .blue_07,
      darkMode: .blue_03
    )

    public static let inverse = SemanticColor(
      "icon/inverse",
      lightMode: .gray_300,
      darkMode: .gray_800
    )

    public static let pressed = SemanticColor(
      "icon/pressed",
      lightMode: .gray_550,
      darkMode: .gray_500
    )

    public static let primary = SemanticColor(
      "icon/primary",
      lightMode: .gray_800,
      darkMode: .gray_200
    )

    public static let subtle = SemanticColor(
      "icon/subtle",
      lightMode: .gray_600,
      darkMode: .gray_500
    )

    public static let warning = SemanticColor(
      "icon/warning",
      lightMode: .yellow_07,
      darkMode: .yellow_03
    )

    public struct Danger {
      public static let inverse = SemanticColor(
        "icon/danger/inverse",
        lightMode: .red_200,
        darkMode: .red_800
      )
    }

    public struct Green {
      public static let inverse = SemanticColor(
        "icon/green/inverse",
        lightMode: .green_02,
        darkMode: .green_08
      )
    }
  }
}
