import XCTest
@testable import Library
@testable import LiveStream
@testable import Kickstarter_Framework
@testable import KsApi
import Prelude

final class LiveStreamChatDataSourceTests: TestCase {
  let dataSource = LiveStreamChatDataSource()
  let tableView = UITableView()

  func testDataSource_Append() {
    let chatMessages = (1...5)
      .map(String.init)
      .map { .template |> LiveStreamChatMessage.lens.id .~ $0 }

    let indexPaths = chatMessages.map {
      self.dataSource.appendRow(value: $0, cellClass:
        LiveStreamChatMessageCell.self, toSection: 0)
    }

    XCTAssertEqual(0, indexPaths[0].row)
    XCTAssertEqual(1, indexPaths[1].row)
    XCTAssertEqual(2, indexPaths[2].row)
    XCTAssertEqual(3, indexPaths[3].row)
    XCTAssertEqual(4, indexPaths[4].row)

    XCTAssertEqual(0, indexPaths[0].section)
    XCTAssertEqual(0, indexPaths[1].section)
    XCTAssertEqual(0, indexPaths[2].section)
    XCTAssertEqual(0, indexPaths[3].section)
    XCTAssertEqual(0, indexPaths[4].section)

    XCTAssertEqual(5, indexPaths.count)
    XCTAssertEqual("1", (self.dataSource[IndexPath(row: 0, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("2", (self.dataSource[IndexPath(row: 1, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("3", (self.dataSource[IndexPath(row: 2, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("4", (self.dataSource[IndexPath(row: 3, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("5", (self.dataSource[IndexPath(row: 4, section: 0)] as? LiveStreamChatMessage)?.id)
  }

  func testDataSource_Prepend() {
    let chatMessages = (1...5)
      .map(String.init)
      .map { .template |> LiveStreamChatMessage.lens.id .~ $0 }

    let indexPaths = chatMessages.map {
      self.dataSource.prependRow(value: $0, cellClass:
        LiveStreamChatMessageCell.self, toSection: 0)
    }

    XCTAssertEqual(0, indexPaths[0].row)
    XCTAssertEqual(0, indexPaths[1].row)
    XCTAssertEqual(0, indexPaths[2].row)
    XCTAssertEqual(0, indexPaths[3].row)
    XCTAssertEqual(0, indexPaths[4].row)

    XCTAssertEqual(0, indexPaths[0].section)
    XCTAssertEqual(0, indexPaths[1].section)
    XCTAssertEqual(0, indexPaths[2].section)
    XCTAssertEqual(0, indexPaths[3].section)
    XCTAssertEqual(0, indexPaths[4].section)

    XCTAssertEqual(5, indexPaths.count)
    XCTAssertEqual("5", (self.dataSource[IndexPath(row: 0, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("4", (self.dataSource[IndexPath(row: 1, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("3", (self.dataSource[IndexPath(row: 2, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("2", (self.dataSource[IndexPath(row: 3, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("1", (self.dataSource[IndexPath(row: 4, section: 0)] as? LiveStreamChatMessage)?.id)
  }

  func testDataSource_AddMessages() {
    let chatMessages = (1...5)
      .map(String.init)
      .map { .template |> LiveStreamChatMessage.lens.id .~ $0 }

    let indexPaths = self.dataSource.add(chatMessages, toSection: 0)

    XCTAssertEqual(0, indexPaths[0].row)
    XCTAssertEqual(0, indexPaths[1].row)
    XCTAssertEqual(0, indexPaths[2].row)
    XCTAssertEqual(0, indexPaths[3].row)
    XCTAssertEqual(0, indexPaths[4].row)

    XCTAssertEqual(0, indexPaths[0].section)
    XCTAssertEqual(0, indexPaths[1].section)
    XCTAssertEqual(0, indexPaths[2].section)
    XCTAssertEqual(0, indexPaths[3].section)
    XCTAssertEqual(0, indexPaths[4].section)

    XCTAssertEqual(5, indexPaths.count)
    XCTAssertEqual("5", (self.dataSource[IndexPath(row: 0, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("4", (self.dataSource[IndexPath(row: 1, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("3", (self.dataSource[IndexPath(row: 2, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("2", (self.dataSource[IndexPath(row: 3, section: 0)] as? LiveStreamChatMessage)?.id)
    XCTAssertEqual("1", (self.dataSource[IndexPath(row: 4, section: 0)] as? LiveStreamChatMessage)?.id)
  }
}
