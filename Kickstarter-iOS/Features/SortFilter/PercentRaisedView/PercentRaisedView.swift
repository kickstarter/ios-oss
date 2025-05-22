import KsApi
import Library
import SwiftUI

public struct PercentRaisedView: View {
  var buckets: [DiscoveryParams.PercentRaisedBucket]
  @Binding var selectedBucket: DiscoveryParams.PercentRaisedBucket?

  // FIXME: MBL-2348 Bring this page up to design spec
  public var body: some View {
    VStack {
      ForEach(self.buckets) { bucket in
        Button {
          self.selectedBucket = bucket
        } label: {
          Text(bucket.title)
        }
        .buttonStyle(.borderedProminent)
        .tint(bucket == self.selectedBucket ? .red : .blue)
      }
    }
  }
}

extension DiscoveryParams.PercentRaisedBucket: @retroactive Identifiable {
  public var id: Int {
    return self.hashValue
  }
}
