import KsApi
import Library
import SwiftUI

struct DefaultLocationsList: View {
  let defaultLocations: [Location]
  @Binding var selectedLocation: Location?

  func buttonLabel(title: String, isSelected: Bool) -> some View {
    HStack(spacing: LocationView.Constants.buttonLabelSpacing) {
      RadioButton(isSelected: isSelected)
      Text(title)
        .font(InterFont.bodyLG.swiftUIFont())
        .foregroundStyle(Colors.Text.primary.swiftUIColor())
    }
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: LocationView.Constants.spacing) {
      Button {
        self.selectedLocation = nil
      } label: {
        // FIXME: MBL-2343 Add translations
        self.buttonLabel(
          title: "FPO: Anywhere",
          isSelected: self.selectedLocation.isNil
        )
      }
      ForEach(self.defaultLocations) { item in
        Button {
          self.selectedLocation = item
        } label: {
          self.buttonLabel(
            title: item.displayableName,
            isSelected: self.selectedLocation?.id == item.id
          )
        }
      }
    }
    .padding(LocationView.Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

extension Location: @retroactive Identifiable {}
