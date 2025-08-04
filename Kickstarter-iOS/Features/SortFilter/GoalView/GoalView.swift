import KsApi
import Library
import SwiftUI

public struct GoalView: View {
  var buckets: [DiscoveryParams.GoalBucket]
  @Binding var selectedBucket: DiscoveryParams.GoalBucket?

  public var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      ForEach(self.buckets) { bucket in
        Button {
          self.selectedBucket = bucket
        } label: {
          HStack(spacing: Constants.buttonLabelSpacing) {
            RadioButton(isSelected: bucket == self.selectedBucket)
            Text(bucket.title)
              .font(InterFont.bodyLG.swiftUIFont())
              .foregroundStyle(Colors.Text.primary.swiftUIColor())
          }
        }
      }
    }
    .padding(Constants.padding)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }

  internal enum Constants {
    static let padding = Spacing.unit_06
    static let spacing = Spacing.unit_06
    static let buttonLabelSpacing = Spacing.unit_02
  }
}

extension DiscoveryParams.GoalBucket: @retroactive Identifiable {
  public var id: Int {
    return self.rawValue
  }
}
