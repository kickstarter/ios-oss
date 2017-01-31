import Library
import LiveStream
import Prelude
import UIKit

internal final class LiveStreamDiscoveryDataSource: ValueCellDataSource {
  internal func load(liveStreams: [LiveStreamEvent]) {
    self.clearValues()

    sorted(liveStreamEvents: liveStreams)
      .groupedBy(sectionTitle(forLiveStreamEvent:))
      .forEach { title, events in
        guard !events.isEmpty else { return }
        self.appendRow(value: title,
                       cellClass: LiveStreamDiscoveryTitleCell.self,
                       toSection: sectionFor(titleType: title))
        events.forEach { event in
          self.appendRow(value: event,
                         cellClass: LiveStreamDiscoveryCell.self,
                         toSection: sectionFor(titleType: title))
        }
    }
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as LiveStreamDiscoveryCell, value as LiveStreamEvent):
      cell.configureWith(value: value)
    case let (cell as LiveStreamDiscoveryTitleCell, value as LiveStreamDiscoveryTitleType):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized combo: \(cell), \(value)")
    }
  }
}

private func sorted(liveStreamEvents: [LiveStreamEvent]) -> [LiveStreamEvent] {

  let now = AppEnvironment.current.dateType.init().date

  // Compares two live streams, putting live ones first.
  let currentlyLiveStreamsFirstComparator = Prelude.Comparator<LiveStreamEvent> { lhs, rhs in
    switch (lhs.liveNow, rhs.liveNow) {
    case (true, false):                 return .lt
    case (false, true):                 return .gt
    case (true, true), (false, false):  return .eq
    }
  }

  // Compares two live streams, putting the future ones first.
  let futureLiveStreamsFirstComparator = Prelude.Comparator<LiveStreamEvent> { lhs, rhs in
    lhs.startDate > now && rhs.startDate > now || lhs.startDate < now && rhs.startDate < now
      ? .eq : lhs.startDate < rhs.startDate ? .gt
      : .lt
  }

  // Compares two live streams, putting soon-to-be-live first and way-back past last.
  let startDateComparator = Prelude.Comparator<LiveStreamEvent> { lhs, rhs in
    lhs.startDate > now
      ? (lhs.startDate == rhs.startDate ? .eq : lhs.startDate < rhs.startDate ? .lt: .gt)
      : (lhs.startDate == rhs.startDate ? .eq : lhs.startDate < rhs.startDate ? .gt: .lt)
  }

  // Sort by:
  //   * live streams first
  //   * then future streams first and past streams last
  //   * future streams sorted by start date asc, past streams sorted by start date desc

  return liveStreamEvents.sorted(
    comparator: currentlyLiveStreamsFirstComparator
      <> futureLiveStreamsFirstComparator
      <> startDateComparator
  )
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
