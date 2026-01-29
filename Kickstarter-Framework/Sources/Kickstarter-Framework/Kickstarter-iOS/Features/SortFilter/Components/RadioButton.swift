import Foundation
import KDS
import Library
import SwiftUI

struct RadioButton: View {
  let isSelected: Bool
  var body: some View {
    ZStack {
      Circle()
        .strokeBorder(
          self.isSelected ? Colors.Border.subtle.swiftUIColor() : Colors.Border.bold.swiftUIColor(),
          lineWidth: Constants.radioButtonOuterBorder
        )

      if self.isSelected {
        Circle()
          .strokeBorder(
            Colors.Background.selected.swiftUIColor(),
            lineWidth: Constants.radioButtonInnerBorder
          )
      }
    }
    .frame(width: Constants.radioButtonSize, height: Constants.radioButtonSize)
  }

  internal enum Constants {
    static let radioButtonSize = Spacing.unit_06
    static let radioButtonOuterBorder: CGFloat = 1.0
    static let radioButtonInnerBorder: CGFloat = 8.0
  }
}
