import Library
import LiveStream
import Prelude
import UIKit

internal final class LiveStreamDiscoveryDataSource: ValueCellDataSource {
  internal func load(liveStreams: [LiveStreamEvent]) {
    self.clearValues()

    liveStreams
      .sorted(comparator:
        LiveStreamEvent.canonicalLiveStreamEventComparator(now: AppEnvironment.current.dateType.init().date)
      )
      .groupedBy(sectionTitle(forLiveStreamEvent:))
      .forEach { title, events in
        guard !events.isEmpty else { return }
        self.appendRow(value: title,
                       cellClass: LiveStreamDiscoveryTitleCell.self,
                       toSection: sectionFor(titleType: title))
        events.forEach { event in
          self.appendRow(value: event,
                         cellClass: LiveStreamDiscoveryLiveNowCell.self,
                         toSection: sectionFor(titleType: title))
        }
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as LiveStreamDiscoveryCell, value as LiveStreamEvent):
      cell.configureWith(value: value)
    case let (cell as LiveStreamDiscoveryLiveNowCell, value as LiveStreamEvent):
      cell.configureWith(value: value)
    case let (cell as LiveStreamDiscoveryTitleCell, value as LiveStreamDiscoveryTitleType):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}

private func sectionTitle(forLiveStreamEvent liveStreamEvent: LiveStreamEvent)
  -> LiveStreamDiscoveryTitleType {
    return liveStreamEvent.liveNow ? .liveNow
      : liveStreamEvent.startDate > AppEnvironment.current.dateType.init().date ? .upcoming
      : .recentlyLive
}

/// The section of the data source that events of this type should be placed in.
private func sectionFor(titleType: LiveStreamDiscoveryTitleType) -> Int {
  switch titleType {
  case .liveNow:
    return 0
  case .recentlyLive:
    return 2
  case .upcoming:
    return 1
  }
}
