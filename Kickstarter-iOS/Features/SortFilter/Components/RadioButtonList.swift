import Library
import SwiftUI

public struct RadioButtonList<Data: Identifiable>: View {
  public struct Configuration {
    let title: String
    let isSelected: Bool
  }

  public let items: [Data]
  public let didSelectItem: (Data) -> Void
  public let itemConfiguration: (Data) -> (Configuration)

  public var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      ForEach(self.items) { item in
        let config = self.itemConfiguration(item)

        Button {
          self.didSelectItem(item)
        } label: {
          HStack(spacing: Constants.buttonLabelSpacing) {
            RadioButton(isSelected: config.isSelected)
            Text(config.title)
              .font(InterFont.bodyLG.swiftUIFont())
              .foregroundStyle(Colors.Text.primary.swiftUIColor())
          }
        }
      }
    }
    .padding(Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

private enum Constants {
  static let padding: CGFloat = 24.0
  static let spacing: CGFloat = 24.0
  static let buttonLabelSpacing: CGFloat = 8.0
}

private struct PreviewItem: Identifiable {
  let id: Int
  let title: String
  let isSelected: Bool
}

#Preview {
  RadioButtonList<PreviewItem>(
    items: [
      PreviewItem(
        id: 1,
        title: "Item One",
        isSelected: false
      ),
      PreviewItem(
        id: 2,
        title: "Item Two",
        isSelected: true
      ),
      PreviewItem(
        id: 3,
        title: "Item Three",
        isSelected: false
      )
    ], didSelectItem: { _ in },
    itemConfiguration: { item in
      RadioButtonList.Configuration(
        title: item.title,
        isSelected: item.isSelected
      )
    }
  )
}
