@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

internal final class ProjectFAQsDataSourceTests: XCTestCase {
  let dataSource = ProjectFAQsDataSource()
  let tableView = UITableView()

  func testDataSource_LoggedIn() {
    let askAQuestionSection = ProjectFAQsDataSource.Section.askAQuestion.rawValue
    let faqsSection = ProjectFAQsDataSource.Section.faqs.rawValue
    let isExpandedStates = [false, false, false, false]
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]

    withEnvironment(currentUser: .template) {
      self.dataSource.load(projectFAQs: faqs, isExpandedStates: isExpandedStates)

      XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
      XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: faqsSection))
      XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: askAQuestionSection))
      XCTAssertEqual("ProjectFAQsCell", self.dataSource.reusableId(item: 0, section: faqsSection))
      XCTAssertEqual(
        "ProjectFAQsAskAQuestionCell",
        self.dataSource.reusableId(item: 0, section: askAQuestionSection)
      )
    }
  }

  func testDataSource_LoggedOut() {
    let faqsSection = ProjectFAQsDataSource.Section.faqs.rawValue
    let isExpandedStates = [false, false, false, false]
    let faqs = [
      ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
      ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
      ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
      ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
    ]

    self.dataSource.load(projectFAQs: faqs, isExpandedStates: isExpandedStates)

    XCTAssertEqual(2, self.dataSource.numberOfSections(in: self.tableView))
    XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: faqsSection))
    XCTAssertEqual("ProjectFAQsCell", self.dataSource.reusableId(item: 0, section: faqsSection))
  }

  func testEmptyState_LoggedIn() {
    let askAQuestionSection = ProjectFAQsDataSource.Section.askAQuestion.rawValue
    let emptySection = ProjectFAQsDataSource.Section.empty.rawValue
    let isExpandedStates = [false, false, false, false]

    withEnvironment(currentUser: .template) {
      self.dataSource.load(projectFAQs: [], isExpandedStates: isExpandedStates)

      XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))
      XCTAssertEqual(1, self.dataSource.tableView(self.tableView, numberOfRowsInSection: emptySection))
      XCTAssertEqual("ProjectFAQsEmptyStateCell", self.dataSource.reusableId(item: 0, section: emptySection))
      XCTAssertEqual(
        "ProjectFAQsAskAQuestionCell",
        self.dataSource.reusableId(item: 0, section: askAQuestionSection)
      )
    }
  }

  func testEmptyState_LoggedOut() {
    let section = ProjectFAQsDataSource.Section.empty.rawValue
    let isExpandedStates = [false, false, false, false]

    self.dataSource.load(projectFAQs: [], isExpandedStates: isExpandedStates)

    XCTAssertEqual(1, self.dataSource.numberOfSections(in: self.tableView))
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

    self.dataSource.load(projectFAQs: faqs, isExpandedStates: isExpandedStates)

    XCTAssertEqual(self.dataSource.isExpandedValuesForFAQsSection(), isExpandedStates)
  }
}
