import UIKit

// This extension contains custom semantic colors that are not part of the official Figma design set.
// These colors are used for specific UI elements, like badges in the payment schedule component,
// which are not yet defined in the core Design System. This structure helps organize and
// isolate non-standard colors from the rest of the shared semantic palette.

extension Colors {
  public struct Custom {
    public struct Badge {
      public struct Background {
        public static let collected = SemanticColor(
          "custom/badge/background/collected",
          lightMode: .green_02,
          darkMode: .green_02
        )

        public static let canceled = SemanticColor(
          "custom/badge/background/canceled",
          lightMode: .gray_300,
          darkMode: .gray_500
        )

        public static let errored = SemanticColor(
          "custom/badge/background/errored",
          lightMode: .red_200,
          darkMode: .red_300
        )

        public static let authentication = SemanticColor(
          "increment/badge/background/authentication",
          lightMode: .yellow_02,
          darkMode: .yellow_03
        )

        public static let scheduled = SemanticColor(
          "custom/badge/background/scheduled",
          lightMode: .blue_03,
          darkMode: .blue_03
        )

        public static let refunded = SemanticColor(
          "increment/badge/background/refunded",
          lightMode: .purple_03,
          darkMode: .purple_03
        )
      }

      public struct Text {
        public static let collected = SemanticColor(
          "custom/badge/text/collected",
          lightMode: .green_06,
          darkMode: .green_07
        )

        public static let canceled = SemanticColor(
          "custom/badge/text/canceled",
          lightMode: .gray_1000,
          darkMode: .gray_1000
        )

        public static let errored = SemanticColor(
          "custom/badge/text/errored",
          lightMode: .red_800,
          darkMode: .red_700
        )

        public static let authentication = SemanticColor(
          "increment/badge/text/authentication",
          lightMode: .yellow_08,
          darkMode: .yellow_08
        )

        public static let scheduled = SemanticColor(
          "increment/badge/text/scheduled",
          lightMode: .blue_09,
          darkMode: .blue_09
        )

        public static let refunded = SemanticColor(
          "increment/badge/text/refunded",
          lightMode: .purple_08,
          darkMode: .purple_08
        )
      }
    }
  }
}
