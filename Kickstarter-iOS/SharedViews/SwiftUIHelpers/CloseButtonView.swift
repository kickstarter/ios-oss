import KDS
import Library
import SwiftUI

/// A SwiftUI close button with liquid glass effect.
///
/// This view is designed to be used within UIKit views via UIHostingController.
struct CloseButtonView: View {
  let onClose: () -> Void

  var body: some View {
    Button(action: self.onClose) {
      Image(uiImage: image(named: "icon--cross") ?? UIImage())
        .renderingMode(.template)
        .foregroundColor(Color(LegacyColors.ksr_support_700.uiColor()))
        .frame(width: 20, height: 20)
    }
    .frame(width: 44, height: 44)
    .contentShape(Circle())
    .glassedEffect(in: Circle(), interactive: true)
    .accessibilityLabel(Strings.accessibility_projects_buttons_close())
    .accessibilityHint(Strings.Closes_project())
  }
}
