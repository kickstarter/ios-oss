import KDS
import SwiftUI
import UIKit

extension AdaptiveColor {
  func swiftUIColorResolvedForLightMode() -> Color {
    Color(uiColor: dynamicColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)))
  }

  func swiftUIColorResolvedForDarkMode() -> Color {
    Color(uiColor: dynamicColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)))
  }
}
