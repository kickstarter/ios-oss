@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectEnvironmentalCommitmentsDataSourceTests: XCTestCase {
  let dataSource = ProjectEnvironmentalCommitmentsDataSource()
  let tableView = UITableView()

  func testDataSource() {
    let environmentalCommitmentsSection = ProjectEnvironmentalCommitmentsDataSource.Section
      .environmentalCommitments.rawValue
    let footerSection = ProjectEnvironmentalCommitmentsDataSource.Section.footer.rawValue
    let environmentalCommitments = [
      ProjectEnvironmentalCommitment(
        description: "foo bar",
        category: .environmentallyFriendlyFactories,
        id: 0
      ),
      ProjectEnvironmentalCommitment(description: "hello world", category: .longLastingDesign, id: 1),
      ProjectEnvironmentalCommitment(
        description: "Lorem ipsum",
        category: .reusabilityAndRecyclability,
        id: 2
      ),
      ProjectEnvironmentalCommitment(description: "blah blah blah", category: .sustainableDistribution, id: 3)
    ]

    self.dataSource.load(environmentalCommitments: environmentalCommitments)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      4,
      self.dataSource.tableView(self.tableView, numberOfRowsInSection: environmentalCommitmentsSection)
    )
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: footerSection))
    XCTAssertEqual(
      "ProjectEnvironmentalCommitmentCell",
      self.dataSource.reusableId(item: 0, section: environmentalCommitmentsSection)
    )
    XCTAssertEqual(
      "ProjectEnvironmentalCommitmentFooterCell",
      self.dataSource.reusableId(item: 0, section: footerSection)
    )
  }

  func testDataSource_EmptyEnvironmentalCommitments() {
    let environmentalCommitmentsSection = ProjectEnvironmentalCommitmentsDataSource.Section
      .environmentalCommitments.rawValue
    let footerSection = ProjectEnvironmentalCommitmentsDataSource.Section.footer.rawValue

    self.dataSource.load(environmentalCommitments: [])

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(
      0,
      self.dataSource.tableView(self.tableView, numberOfRowsInSection: environmentalCommitmentsSection)
    )
    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: footerSection))
    XCTAssertNil(self.dataSource.reusableId(item: 0, section: environmentalCommitmentsSection))
    XCTAssertEqual(
      "ProjectEnvironmentalCommitmentFooterCell",
      self.dataSource.reusableId(item: 0, section: footerSection)
    )
  }
}
