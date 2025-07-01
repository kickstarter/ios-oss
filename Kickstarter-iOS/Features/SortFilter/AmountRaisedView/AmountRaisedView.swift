import KsApi
import Library
import SwiftUI

public struct AmountRaisedView: View {
  var buckets: [DiscoveryParams.AmountRaisedBucket]
  @Binding var selectedBucket: DiscoveryParams.AmountRaisedBucket?

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
    static let padding: CGFloat = 24.0
    static let spacing: CGFloat = 24.0
    static let buttonLabelSpacing: CGFloat = 8.0
  }
}

extension DiscoveryParams.AmountRaisedBucket: @retroactive Identifiable {
  public var id: Int {
    return self.rawValue
  }
}
