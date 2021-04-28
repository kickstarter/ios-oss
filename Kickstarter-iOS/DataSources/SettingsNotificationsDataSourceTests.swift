@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class SettingsNotificationsDataSourceTests: XCTestCase {
  private let dataSource = SettingsNotificationsDataSource()
  private let tableView = UITableView(frame: .zero)

  func testLoadUser_NonCreator() {
    let user = User.template

    self.dataSource.load(user: user)

    XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
  }

  func testLoadUser_isCreator_pledgeActivityDisabled() {
    let user = User.template |> \.stats.createdProjectsCount .~ 2

    self.dataSource.load(user: user)

    XCTAssertEqual(4, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
  }

  func testLoadUser_isCreator_pledgeActivityEnabled() {
    let user = User.template
      |> \.stats.createdProjectsCount .~ 2
      |> UserAttribute.notification(.pledgeActivity).keyPath .~ true
      |> UserAttribute.notification(.creatorDigest).keyPath .~ true

    self.dataSource.load(user: user)

    XCTAssertEqual(4, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0))
    XCTAssertEqual(2, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 1))
    XCTAssertEqual(5, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 2))
    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: 3))
  }

  func testCellTypeForIndexPath() {
    let user = User.template

    self.dataSource.load(user: user)

    let indexPath0 = IndexPath(item: 0, section: 0)
    let indexPath1 = IndexPath(item: 0, section: 1)
    let indexPath2 = IndexPath(item: 1, section: 1)
    let indexPath3 = IndexPath(item: 0, section: 2)
    let indexPath4 = IndexPath(item: 1, section: 2)
    let indexPath5 = IndexPath(item: 2, section: 2)
    let indexPath6 = IndexPath(item: 3, section: 2)

    XCTAssertEqual(
      SettingsNotificationCellType.marketingUpdate,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath0)
    )
    XCTAssertEqual(
      SettingsNotificationCellType.projectUpdates,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath1)
    )
    XCTAssertEqual(
      SettingsNotificationCellType.projectNotifications,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath2)
    )
    XCTAssertEqual(
      SettingsNotificationCellType.messages,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath3)
    )
    XCTAssertEqual(
      SettingsNotificationCellType.newFollowers,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath4)
    )
    XCTAssertEqual(
      SettingsNotificationCellType.friendBacksProject,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath5)
    )
    XCTAssertEqual(
      SettingsNotificationCellType.commentReplyDigest,
      self.dataSource.cellTypeForIndexPath(indexPath: indexPath6)
    )
  }

  func testSectionTypeForSection() {
    let user = User.template

    self.dataSource.load(user: user)

    let section0 = self.dataSource.sectionType(section: 0, user: user)
    let section1 = self.dataSource.sectionType(section: 1, user: user)
    let section2 = self.dataSource.sectionType(section: 2, user: user)

    XCTAssertEqual(SettingsNotificationSectionType.announcements, section0)
    XCTAssertEqual(SettingsNotificationSectionType.backedProjects, section1)
    XCTAssertEqual(SettingsNotificationSectionType.social, section2)
  }

  func testSectionTypeForSection_isCreator() {
    let user = User.template |> \.stats.createdProjectsCount .~ 2

    self.dataSource.load(user: user)

    let section0 = self.dataSource.sectionType(section: 0, user: user)
    let section1 = self.dataSource.sectionType(section: 1, user: user)
    let section2 = self.dataSource.sectionType(section: 2, user: user)
    let section3 = self.dataSource.sectionType(section: 3, user: user)

    XCTAssertEqual(SettingsNotificationSectionType.announcements, section0)
    XCTAssertEqual(SettingsNotificationSectionType.backedProjects, section1)
    XCTAssertEqual(SettingsNotificationSectionType.creator, section2)
    XCTAssertEqual(SettingsNotificationSectionType.social, section3)
  }

  func testSectionTypeForSection_OutOfBounds() {
    let user = User.template

    self.dataSource.load(user: user)

    let section = self.dataSource.sectionType(section: 3, user: user)

    XCTAssertNil(section)
  }

  func testSectionTypeForSection_OutOfBounds_isCreator() {
    let user = User.template |> \.stats.createdProjectsCount .~ 2

    self.dataSource.load(user: user)

    let section = self.dataSource.sectionType(section: 5, user: user)

    XCTAssertNil(section)
  }
}
