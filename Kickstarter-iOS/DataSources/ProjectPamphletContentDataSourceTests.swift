@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ProjectPamphletContentDataSourceTests: TestCase {
  let dataSource = ProjectPamphletContentDataSource()
  let tableView = UITableView()

  func testViewProgressSectionRows_UserIsCreatorOfProject() {
    let viewProgressSection = ProjectPamphletContentDataSource.Section.creatorHeader.rawValue

    let user = User.template
    let project = Project.template
      |> Project.lens.creator .~ user

    withEnvironment(currentUser: user) {
      self.dataSource.load(data: (project, .discovery))

      XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: viewProgressSection))
    }
  }

  func testViewProgressSectionRows_UserIsNotCreatorOfProject() {
    let viewProgressSection = ProjectPamphletContentDataSource.Section.creatorHeader.rawValue

    let user = User.template
      |> \.id .~ 123
    let project = Project.template

    withEnvironment(currentUser: user) {
      self.dataSource.load(data: (project, .discovery))

      XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: viewProgressSection))
    }
  }

  private func assertSectionIsShown(_ config: Config) {
    let releaseBundle = MockBundle(
      bundleIdentifier: KickstarterBundleIdentifier.release.rawValue,
      lang: "en"
    )
    withEnvironment(config: config, mainBundle: releaseBundle) {
      self.dataSource.load(data: (.template, .discovery))

      XCTAssertEqual(8, self.dataSource.numberOfSections(in: self.tableView))
    }
  }
}
