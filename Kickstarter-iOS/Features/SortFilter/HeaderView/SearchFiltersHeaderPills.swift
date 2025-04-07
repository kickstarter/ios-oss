import Library
import SwiftUI

internal struct ImagePillLabel: View {
  let image: UIImage
  var body: some View {
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
}

internal struct DropdownPillLabel: View {
  let title: String
  var body: some View {
    HStack {
      Text(self.title)
      Spacer()
      Image("arrow-down", bundle: Bundle.main)
        .renderingMode(.template)
    }
    .padding(EdgeInsets(
      top: Styles.gridHalf(1),
      leading: Styles.grid(1),
      bottom: Styles.gridHalf(1),
      trailing: Styles.grid(1)
    ))
  }
}
