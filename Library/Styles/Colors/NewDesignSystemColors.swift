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

      public struct Green {
        public static let bolder = SemanticColor(
          "text/accent/green/bolder",
          lightMode: .green_08,
          darkMode: .green_02
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

      public static let primary = SemanticColor(
        "background/action/primary",
        lightMode: .green_06,
        darkMode: .white
      )

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

      public static let secondary = SemanticColor(
        "background/surface/secondary",
        lightMode: .gray_100,
        darkMode: .black
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
