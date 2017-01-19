import XCTest
import Prelude
@testable import Kickstarter_Framework
@testable import Library
@testable import LiveStream
@testable import KsApi

final class LiveStreamDiscoveryDataSourceTests: TestCase {
  let dataSource = LiveStreamDiscoveryDataSource()
  let tableView = UITableView()

  func testSomething() {
    XCTAssertTrue(true)
  }

  func testStandard() {
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

    let liveStreams = [
      futureLiveStreamWayFuture,
      pastLiveStreamWayPast,
      currentlyLiveStream,
      pastLiveStreamRecent,
      futureLiveStreamSoon,
      ]

    self.dataSource.load(liveStreams: liveStreams)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))

    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(.liveNow, self.dataSource[IndexPath(row: 0, section: 0)] as? LiveStreamDiscoveryTitleType)
    XCTAssertEqual(currentlyLiveStream, self.dataSource[IndexPath(row: 1, section: 0)] as? LiveStreamEvent)

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(.upcoming,
                   self.dataSource[IndexPath(row: 0, section: 1)] as? LiveStreamDiscoveryTitleType)
    XCTAssertEqual(futureLiveStreamSoon,
                   self.dataSource[IndexPath(row: 1, section: 1)] as? LiveStreamEvent)
    XCTAssertEqual(futureLiveStreamWayFuture,
                   self.dataSource[IndexPath(row: 2, section: 1)] as? LiveStreamEvent)

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(.recentlyLive,
                   self.dataSource[IndexPath(row: 0, section: 2)] as? LiveStreamDiscoveryTitleType)
    XCTAssertEqual(pastLiveStreamRecent,
                   self.dataSource[IndexPath(row: 1, section: 2)] as? LiveStreamEvent)
    XCTAssertEqual(pastLiveStreamWayPast,
                   self.dataSource[IndexPath(row: 2, section: 2)] as? LiveStreamEvent)
  }

  func testWithNoCurrentlyLiveStreams() {
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

    let liveStreams = [
      futureLiveStreamWayFuture,
      pastLiveStreamWayPast,
      pastLiveStreamRecent,
      futureLiveStreamSoon,
      ]

    self.dataSource.load(liveStreams: liveStreams)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))

    XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(.upcoming,
                   self.dataSource[IndexPath(row: 0, section: 1)] as? LiveStreamDiscoveryTitleType)
    XCTAssertEqual(futureLiveStreamSoon,
                   self.dataSource[IndexPath(row: 1, section: 1)] as? LiveStreamEvent)
    XCTAssertEqual(futureLiveStreamWayFuture,
                   self.dataSource[IndexPath(row: 2, section: 1)] as? LiveStreamEvent)

    XCTAssertEqual(3, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(.recentlyLive,
                   self.dataSource[IndexPath(row: 0, section: 2)] as? LiveStreamDiscoveryTitleType)
    XCTAssertEqual(pastLiveStreamRecent,
                   self.dataSource[IndexPath(row: 1, section: 2)] as? LiveStreamEvent)
    XCTAssertEqual(pastLiveStreamWayPast,
                   self.dataSource[IndexPath(row: 2, section: 2)] as? LiveStreamEvent)
  }
}
