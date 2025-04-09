import Library
import SwiftUI

internal struct ImagePillButton: View {
  let action: () -> Void
  let image: UIImage
  let isHighlighted: Bool
  var body: some View {
    Button(action: self.action) {
      Image(uiImage: self.image)
        .renderingMode(.template)
        .aspectRatio(1.0, contentMode: .fit)
        .padding(
          EdgeInsets(
            top: Styles.gridHalf(1),
            leading: Styles.gridHalf(1),
            bottom: Styles.gridHalf(1),
            trailing: Styles.gridHalf(1)
          )
        )
    }
    .buttonStyle(SearchFiltersPillStyle(
      isHighlighted: self.isHighlighted,
      shape: Circle()
    ))
  }
}

internal struct DropdownPillButton: View {
  let action: () -> Void
  let title: String
  let isHighlighted: Bool
  var body: some View {
    Button(action: self.action) {
      HStack {
        Text(self.title)
        if let carat = Library.image(named: "arrow-down") {
          Spacer()
          Image(uiImage: carat)
            .renderingMode(.template)
        }
      }
      .padding(EdgeInsets(
        top: Styles.gridHalf(1),
        leading: Styles.grid(1),
        bottom: Styles.gridHalf(1),
        trailing: Styles.grid(1)
      ))
    }
    .buttonStyle(SearchFiltersPillStyle(
      isHighlighted: self.isHighlighted,
      shape: Capsule()
    ))
  }
}
