import Library
import SwiftUI

struct FilterSectionButton: View {
  let title: String
  let subtitle: String?

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: FilterRootView.Constants.sectionSpacing) {
        Text(self.title)
          .font(InterFont.headingLG.swiftUIFont())
          .foregroundStyle(Colors.Text.primary.swiftUIColor())
        if let subtitle = self.subtitle {
          Text(subtitle)
            .font(InterFont.bodyMD.swiftUIFont())
            .foregroundStyle(Colors.Text.secondary.swiftUIColor())
        }
      }
      if let icon = Library.image(named: "chevron-right") {
        Spacer()
        Image(uiImage: icon)
          .renderingMode(.template)
          .tint(Colors.Text.primary.swiftUIColor())
      }
    }
  }
}

#if targetEnvironment(simulator)
  #Preview("Filter section button") {
    VStack {
      FilterSectionButton(title: "A filter category", subtitle: "A selected option")
      Divider()
      FilterSectionButton(title: "Another category, with nothing selected", subtitle: nil)
    }
  }
#endif
