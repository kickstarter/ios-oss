import KsApi
import Library
import SwiftUI

public struct PercentRaisedView: View {
  var buckets: [DiscoveryParams.PercentRaisedBucket]
  @Binding var selectedBucket: DiscoveryParams.PercentRaisedBucket?

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
    static let padding = Spacing_06
    static let spacing = Spacing_06
    static let buttonLabelSpacing = Spacing_02
  }
}

extension DiscoveryParams.PercentRaisedBucket: @retroactive Identifiable {
  public var id: Int {
    return self.rawValue
  }
}
