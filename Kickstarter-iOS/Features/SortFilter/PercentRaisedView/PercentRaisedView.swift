import KsApi
import Library
import SwiftUI

public struct PercentRaisedView: View {
  var buckets: [DiscoveryParams.PercentRaisedBucket]
  @Binding var selectedBucket: DiscoveryParams.PercentRaisedBucket?

  public var body: some View {
    RadioButtonList<DiscoveryParams.PercentRaisedBucket>(
      items: self.buckets,
      didSelectItem: { bucket in
        self.selectedBucket = bucket
      },
      itemConfiguration: { bucket in
        RadioButtonList.Configuration(
          title: bucket.title,
          isSelected: bucket == self.selectedBucket
        )
      }
    )
  }
}

extension DiscoveryParams.PercentRaisedBucket: @retroactive Identifiable {
  public var id: Int {
    return self.hashValue
  }
}
