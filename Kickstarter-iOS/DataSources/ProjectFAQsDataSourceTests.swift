@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectFAQsDataSourceTests: XCTestCase {
  let dataSource = ProjectFAQsDataSource()
  let tableView = UITableView()

  func testDataSource() {
    withEnvironment {
      let section = ProjectFAQsDataSource.Section.faqs.rawValue
      let isExpandedStates = [false, false, false, false]
      let faqs = [
        ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
        ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
        ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
        ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
      ]
      let project = Project.template
        |> Project.lens.extendedProjectProperties .~ ExtendedProjectProperties(
          environmentalCommitments: [],
          faqs: faqs,
          risks: "",
          story: "",
          minimumPledgeAmount: 1
        )

      self.dataSource.load(project: project, isExpandedStates: isExpandedStates)

      XCTAssertEqual(section + 1, self.dataSource.numberOfSections(in: tableView))
      XCTAssertEqual(4, self.dataSource.tableView(tableView, numberOfRowsInSection: section))
      XCTAssertEqual("ProjectFAQsCell", self.dataSource.reusableId(item: 0, section: section))
    }
  }

  func testEmptyState() {
    let section = ProjectFAQsDataSource.Section.empty.rawValue
    let isExpandedStates = [false, false, false, false]
    let project = Project.template
      |> Project.lens.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    self.dataSource.load(project: project, isExpandedStates: isExpandedStates)

    XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: section))
    XCTAssertEqual("ProjectFAQsEmptyStateCell", self.dataSource.reusableId(item: 0, section: section))
  }

  func testIsExpandedValuesForFAQsSection() {
    let isExpandedStates = [false, true, false, true]
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]
    let project = Project.template
      |> Project.lens.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: faqs,
        risks: "",
        story: "",
        minimumPledgeAmount: 1
      )

    self.dataSource.load(project: project, isExpandedStates: isExpandedStates)

    XCTAssertEqual(self.dataSource.isExpandedValuesForFAQsSection(), isExpandedStates)
  }
}
