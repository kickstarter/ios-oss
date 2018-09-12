import XCTest
import Prelude
@testable import Kickstarter_Framework
@testable import Library
@testable import KsApi

final class SettingsNotificationsDataSourceTests: XCTestCase {
  private let dataSource = SettingsNotificationsDataSource()
  private let tableView = UITableView(frame: .zero)

  func testLoadUser_NonCreator() {
    let user = User.template

    dataSource.load(user: user)

    XCTAssertEqual(2, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(3, dataSource.tableView(tableView, numberOfRowsInSection: 1))
  }

  func testLoadUser_isCreator_pledgeActivityDisabled() {
    let user = User.template |> User.lens.stats.createdProjectsCount .~ 2

    dataSource.load(user: user)

    XCTAssertEqual(3, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(4, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(3, dataSource.tableView(tableView, numberOfRowsInSection: 2))
  }

  func testLoadUser_isCreator_pledgeActivityEnabled() {
    let user = User.template
      |> User.lens.stats.createdProjectsCount .~ 2
      |> UserAttribute.notification(.pledgeActivity).lens .~ true
      |> UserAttribute.notification(.creatorDigest).lens .~ true

    dataSource.load(user: user)

    XCTAssertEqual(3, dataSource.numberOfSections(in: tableView))
    XCTAssertEqual(2, dataSource.tableView(tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(5, dataSource.tableView(tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(3, dataSource.tableView(tableView, numberOfRowsInSection: 2))
  }

  func testCellTypeForIndexPath() {
    let user = User.template

    dataSource.load(user: user)

    let indexPath0 = IndexPath(item: 0, section: 0)
    let indexPath1 = IndexPath(item: 1, section: 0)
    let indexPath2 = IndexPath(item: 0, section: 1)

    XCTAssertEqual(SettingsNotificationCellType.projectUpdates,
                   dataSource.cellTypeForIndexPath(indexPath: indexPath0))
    XCTAssertEqual(SettingsNotificationCellType.projectNotifications,
                   dataSource.cellTypeForIndexPath(indexPath: indexPath1))
    XCTAssertEqual(SettingsNotificationCellType.messages,
                   dataSource.cellTypeForIndexPath(indexPath: indexPath2))
  }

  func testSectionTypeForSection() {
    let user = User.template

    dataSource.load(user: user)

    let section0 = dataSource.sectionType(section: 0, user: user)
    let section1 = dataSource.sectionType(section: 1, user: user)

    XCTAssertEqual(SettingsNotificationSectionType.backedProjects, section0)
    XCTAssertEqual(SettingsNotificationSectionType.social, section1)
  }

  func testSectionTypeForSection_isCreator() {
    let user = User.template |> User.lens.stats.createdProjectsCount .~ 2

    dataSource.load(user: user)

    let section0 = dataSource.sectionType(section: 0, user: user)
    let section1 = dataSource.sectionType(section: 1, user: user)
    let section2 = dataSource.sectionType(section: 2, user: user)

    XCTAssertEqual(SettingsNotificationSectionType.backedProjects, section0)
    XCTAssertEqual(SettingsNotificationSectionType.creator, section1)
    XCTAssertEqual(SettingsNotificationSectionType.social, section2)
  }

  func testSectionTypeForSection_OutOfBounds() {
    let user = User.template

    dataSource.load(user: user)

    let section = dataSource.sectionType(section: 3, user: user)

    XCTAssertNil(section)
  }

  func testSectionTypeForSection_OutOfBounds_isCreator() {
    let user = User.template |> User.lens.stats.createdProjectsCount .~ 2

    dataSource.load(user: user)

    let section = dataSource.sectionType(section: 5, user: user)

    XCTAssertNil(section)
  }
}
