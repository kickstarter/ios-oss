import UIKit

public struct Colors2 {
  public struct text {
    public static let primary = SemanticColor(
      "text/primary",
      lightMode: .grey_1000,
      darkMode: .grey_100
    )

    public static let secondary = SemanticColor(
      "text/secondary",
      lightMode: .grey_700,
      darkMode: .grey_400
    )

    public struct accent {
      public struct red {
        public static let disabled = SemanticColor(
          "text/accent/red/disabled",
          lightMode: .red_700,
          darkMode: .red_400
        )
      }
    }
  }

  public struct surface {
    public static let primary = SemanticColor(
      "surface/primary",
      lightMode: .white,
      darkMode: .grey_1000
    )
  }
}
