@testable import Kickstarter_Framework
@testable import Library
import XCTest

final class HelpDataSourceTests: XCTestCase {
  private let dataSource = HelpDataSource()
  private let tableView = UITableView(frame: .zero)

  func testConfigureRows() {
    self.dataSource.configureRows()

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
  }

  func testCellTypeForIndexPath_validIndexPath() {
    self.dataSource.configureRows()

    let indexPath0 = IndexPath(item: 0, section: 0)
    let indexPath1 = IndexPath(item: 1, section: 0)
    let indexPath2 = IndexPath(item: 0, section: 1)
    let indexPath3 = IndexPath(item: 1, section: 1)
    let indexPath4 = IndexPath(item: 2, section: 1)

    XCTAssertEqual(HelpType.helpCenter, self.dataSource.cellTypeForIndexPath(indexPath: indexPath0))
    XCTAssertEqual(HelpType.contact, self.dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(HelpType.terms, self.dataSource.cellTypeForIndexPath(indexPath: indexPath2))
    XCTAssertEqual(HelpType.privacy, self.dataSource.cellTypeForIndexPath(indexPath: indexPath3))
    XCTAssertEqual(HelpType.cookie, self.dataSource.cellTypeForIndexPath(indexPath: indexPath4))
  }
}
