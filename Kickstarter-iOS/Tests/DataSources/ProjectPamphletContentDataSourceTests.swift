import XCTest
@testable import Kickstarter_Framework
@testable import Library
@testable import LiveStream
@testable import KsApi
import Prelude

final class ProjectPamphletContentDataSourceTests: TestCase {
  let dataSource = ProjectPamphletContentDataSource()
  let tableView = UITableView()

  func testSubpages_NoLiveStreams() {
    let section = ProjectPamphletContentDataSource.Section.subpages.rawValue

    let project = .template
      |> Project.lens.stats.commentsCount .~ 24
      |> Project.lens.stats.updatesCount .~ 42

    dataSource.load(project: project, liveStreamEvents: [])

    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
    XCTAssertEqual(.comments(24, .first),
                   self.dataSource[IndexPath(row: 0, section: section)] as? ProjectPamphletSubpage)
    XCTAssertEqual(.updates(42, .last),
                   self.dataSource[IndexPath(row: 1, section: section)] as? ProjectPamphletSubpage)
  }

  func testSubpages_LiveStreams_LiveStreamFeatureTurnedOff() {
    let section = ProjectPamphletContentDataSource.Section.subpages.rawValue

    let project = .template
      |> Project.lens.stats.commentsCount .~ 24
      |> Project.lens.stats.updatesCount .~ 42

    let config = .template
      |> Config.lens.features .~ ["ios_live_streams": false]

    withEnvironment(config: config) {
      dataSource.load(project: project, liveStreamEvents: [.template])

      XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
      XCTAssertEqual(.comments(24, .first),
                     self.dataSource[IndexPath(row: 0, section: section)] as? ProjectPamphletSubpage)
      XCTAssertEqual(.updates(42, .last),
                     self.dataSource[IndexPath(row: 1, section: section)] as? ProjectPamphletSubpage)
    }
  }

  func testSubpages_LiveStreams_LiveStreamFeatureTurnedOn() {
    let section = ProjectPamphletContentDataSource.Section.subpages.rawValue

    let currentlyLiveStream = .template
      |> LiveStreamEvent.lens.id .~ 1
      |> LiveStreamEvent.lens.liveNow .~ true
      |> LiveStreamEvent.lens.startDate .~ MockDate().date

    let futureLiveStreamSoon = .template
      |> LiveStreamEvent.lens.id .~ 2
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60 * 60).date

    let futureLiveStreamWayFuture = .template
      |> LiveStreamEvent.lens.id .~ 3
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(48 * 60 * 60).date

    let pastLiveStreamRecent = .template
      |> LiveStreamEvent.lens.id .~ 4
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60).date

    let pastLiveStreamWayPast = .template
      |> LiveStreamEvent.lens.id .~ 5
      |> LiveStreamEvent.lens.liveNow .~ false
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-24 * 60 * 60).date

    let project = .template
      |> Project.lens.stats.commentsCount .~ 24
      |> Project.lens.stats.updatesCount .~ 42

    let liveStreamEvents = [
      futureLiveStreamWayFuture,
      pastLiveStreamWayPast,
      currentlyLiveStream,
      pastLiveStreamRecent,
      futureLiveStreamSoon,
    ]

    let config = .template
      |> Config.lens.features .~ ["ios_live_streams": true]

    withEnvironment(config: config) {
      dataSource.load(project: project, liveStreamEvents: liveStreamEvents)

      XCTAssertEqual(7, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

      XCTAssertEqual(.liveStream(liveStreamEvent: currentlyLiveStream, .first),
                     self.dataSource[IndexPath(row: 0, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStreamEvent: futureLiveStreamSoon, .middle),
                     self.dataSource[IndexPath(row: 1, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStreamEvent: futureLiveStreamWayFuture, .middle),
                     self.dataSource[IndexPath(row: 2, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStreamEvent: pastLiveStreamRecent, .middle),
                     self.dataSource[IndexPath(row: 3, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStreamEvent: pastLiveStreamWayPast, .middle),
                     self.dataSource[IndexPath(row: 4, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.comments(24, .middle),
                     self.dataSource[IndexPath(row: 5, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.updates(42, .last),
                     self.dataSource[IndexPath(row: 6, section: section)] as? ProjectPamphletSubpage)
    }
  }
}
