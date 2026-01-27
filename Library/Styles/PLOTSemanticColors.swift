import KDS
import UIKit

// This extension contains custom semantic colors for PLOT that are not part of the official Figma design set.
// These colors are all related to KDS badges, but use slightly different colors than the web version.
// Eventually these should be folded into the design system itself, but we need to verify
// the web versus the mobile versions of the badges.

extension Colors {
  public struct PLOT {
    public struct Badge {
      public struct Background {
        public static let green = SemanticColor(
          "plot/badge/background/green",
          lightMode: .green_02,
          darkMode: .green_02
        )

        public static let gray = SemanticColor(
          "plot/badge/background/gray",
          lightMode: .gray_300,
          darkMode: .gray_500
        )

        public static let danger = SemanticColor(
          "plot/badge/background/danger",
          lightMode: .red_200,
          darkMode: .red_300
        )

        public static let yellow = SemanticColor(
          "increment/badge/background/yellow",
          lightMode: .yellow_02,
          darkMode: .yellow_03
        )

        public static let blue = SemanticColor(
          "plot/badge/background/blue",
          lightMode: .blue_03,
          darkMode: .blue_03
        )

        public static let purple = SemanticColor(
          "increment/badge/background/purple",
          lightMode: .purple_03,
          darkMode: .purple_03
        )
      }

      public struct Text {
        public static let green = SemanticColor(
          "plot/badge/text/green",
          lightMode: .green_06,
          darkMode: .green_07
        )

        public static let gray = SemanticColor(
          "plot/badge/text/gray",
          lightMode: .gray_1000,
          darkMode: .gray_1000
        )

        public static let danger = SemanticColor(
          "plot/badge/text/danger",
          lightMode: .red_800,
          darkMode: .red_700
        )

        public static let yellow = SemanticColor(
          "increment/badge/text/yellow",
          lightMode: .yellow_08,
          darkMode: .yellow_08
        )

        public static let blue = SemanticColor(
          "increment/badge/text/blue",
          lightMode: .blue_09,
          darkMode: .blue_09
        )

        public static let purple = SemanticColor(
          "increment/badge/text/purple",
          lightMode: .purple_08,
          darkMode: .purple_08
        )
      }
    }
  }
}
