import SwiftUI

struct DefaultPortraitFrame: ViewModifier {
  func body(content: Content) -> some View {
    content
      .frame(width: 320, height: 580)
  }
}

extension View {
  func defaultPortraitFrame() -> some View {
    modifier(DefaultPortraitFrame())
  }
}
