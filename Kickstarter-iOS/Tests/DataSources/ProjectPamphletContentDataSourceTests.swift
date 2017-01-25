import XCTest
@testable import Kickstarter_Framework
@testable import Library
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

    dataSource.load(project: project)

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
      |> Project.lens.liveStreams .~ [.template]

    let config = .template
      |> Config.lens.features .~ ["ios_live_streams": false]

    withEnvironment(config: config) {
      dataSource.load(project: project)

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
      |> Project.LiveStream.lens.id .~ 1
      |> Project.LiveStream.lens.isLiveNow .~ true
      |> Project.LiveStream.lens.startDate .~ MockDate().timeIntervalSince1970

    let futureLiveStreamSoon = .template
      |> Project.LiveStream.lens.id .~ 2
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + 60 * 60)

    let futureLiveStreamWayFuture = .template
      |> Project.LiveStream.lens.id .~ 3
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 + 48 * 60 * 60)

    let pastLiveStreamRecent = .template
      |> Project.LiveStream.lens.id .~ 4
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 60 * 60)

    let pastLiveStreamWayPast = .template
      |> Project.LiveStream.lens.id .~ 5
      |> Project.LiveStream.lens.isLiveNow .~ false
      |> Project.LiveStream.lens.startDate .~ (MockDate().timeIntervalSince1970 - 24 * 60 * 60)

    let project = .template
      |> Project.lens.stats.commentsCount .~ 24
      |> Project.lens.stats.updatesCount .~ 42
      |> Project.lens.liveStreams .~ [
        futureLiveStreamWayFuture,
        pastLiveStreamWayPast,
        currentlyLiveStream,
        pastLiveStreamRecent,
        futureLiveStreamSoon,
    ]

    let config = .template
      |> Config.lens.features .~ ["ios_live_streams": true]

    withEnvironment(config: config) {
      dataSource.load(project: project)

      XCTAssertEqual(7, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))

      XCTAssertEqual(.liveStream(liveStream: currentlyLiveStream, .first),
                     self.dataSource[IndexPath(row: 0, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStream: futureLiveStreamSoon, .middle),
                     self.dataSource[IndexPath(row: 1, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStream: futureLiveStreamWayFuture, .middle),
                     self.dataSource[IndexPath(row: 2, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStream: pastLiveStreamRecent, .middle),
                     self.dataSource[IndexPath(row: 3, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.liveStream(liveStream: pastLiveStreamWayPast, .middle),
                     self.dataSource[IndexPath(row: 4, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.comments(24, .middle),
                     self.dataSource[IndexPath(row: 5, section: section)] as? ProjectPamphletSubpage)

      XCTAssertEqual(.updates(42, .last),
                     self.dataSource[IndexPath(row: 6, section: section)] as? ProjectPamphletSubpage)
    }
  }
}
