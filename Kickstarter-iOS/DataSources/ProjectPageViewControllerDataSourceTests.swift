@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ProjectPageViewControllerDataSourceTests: XCTestCase {
  private let dataSource = ProjectPageViewControllerDataSource()

  private let tableView = UITableView()

  private let environmentalCommitments = [
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

  private let faqs = [
    ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
    ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
    ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
    ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
  ]

  private let overviewSection = ProjectPageViewControllerDataSource.Section.overview.rawValue
  private let campaignSection = ProjectPageViewControllerDataSource.Section.campaign.rawValue
  private let faqsHeaderSection = ProjectPageViewControllerDataSource.Section.faqsHeader.rawValue
  private let faqsEmptySection = ProjectPageViewControllerDataSource.Section.faqsEmpty.rawValue
  private let faqsSection = ProjectPageViewControllerDataSource.Section.faqs.rawValue
  private let faqsAskAQuestionSection = ProjectPageViewControllerDataSource.Section.faqsAskAQuestion.rawValue
  private let risksHeaderSection = ProjectPageViewControllerDataSource.Section
    .risksHeader.rawValue
  private let risksSection = ProjectPageViewControllerDataSource.Section
    .risks.rawValue
  private let risksDisclaimerSection = ProjectPageViewControllerDataSource.Section
    .risksDisclaimer.rawValue
  private let environmentalCommitmentsHeaderSection = ProjectPageViewControllerDataSource.Section
    .environmentalCommitmentsHeader.rawValue
  private let environmentalCommitmentsSection = ProjectPageViewControllerDataSource.Section
    .environmentalCommitments.rawValue
  private let environmentalCommitmentsDisclaimerSection = ProjectPageViewControllerDataSource.Section
    .environmentalCommitmentsDisclaimer.rawValue

  func testLoadFAQs_LoggedIn() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [],
      faqs: self.faqs,
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .faq,
        projectProperties: projectProperties,
        isExpandedStates: [false, false, false, false]
      )
      XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.tableView))

      // overview
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // campaign
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      // faqsHeader
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsHeaderSection)
      )

      // faqsEmpty
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsEmptySection)
      )

      // faqs
      XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsSection))

      // faqsAskAQuestion
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsAskAQuestionSection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.faqsHeaderSection)
      )
      XCTAssertEqual(
        "ProjectFAQsCell",
        self.dataSource.reusableId(item: 0, section: self.faqsSection)
      )
      XCTAssertEqual(
        "ProjectFAQsAskAQuestionCell",
        self.dataSource.reusableId(item: 0, section: self.faqsAskAQuestionSection)
      )
    }
  }

  func testLoadFAQs_LoggedOut() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [],
      faqs: self.faqs,
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    withEnvironment(currentUser: nil) {
      self.dataSource.load(
        navigationSection: .faq,
        projectProperties: projectProperties,
        isExpandedStates: [false, false, false, false]
      )
      XCTAssertEqual(5, self.dataSource.numberOfSections(in: self.tableView))

      // overview
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // campaign
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      // faqsHeader
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsHeaderSection)
      )

      // faqsEmpty
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsEmptySection)
      )

      // faqs
      XCTAssertEqual(4, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsSection))

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.faqsHeaderSection)
      )
      XCTAssertEqual(
        "ProjectFAQsCell",
        self.dataSource.reusableId(item: 0, section: self.faqsSection)
      )
    }
  }

  func testLoadFAQs_EmptyState_LoggedIn() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [],
      faqs: [],
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .faq,
        projectProperties: projectProperties
      )
      XCTAssertEqual(6, self.dataSource.numberOfSections(in: self.tableView))

      // overview
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // campaign
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      // faqsHeader
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsHeaderSection)
      )

      // faqsEmpty
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsEmptySection)
      )

      // faqs
      XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsSection))

      // faqsAskAQuestion
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsAskAQuestionSection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.faqsHeaderSection)
      )
      XCTAssertEqual(
        "ProjectFAQsEmptyStateCell",
        self.dataSource.reusableId(item: 0, section: self.faqsEmptySection)
      )
      XCTAssertEqual(
        "ProjectFAQsAskAQuestionCell",
        self.dataSource.reusableId(item: 0, section: self.faqsAskAQuestionSection)
      )
    }
  }

  func testLoadFAQs_EmptyState_LoggedOut() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [],
      faqs: [],
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    withEnvironment(currentUser: nil) {
      self.dataSource.load(
        navigationSection: .faq,
        projectProperties: projectProperties
      )
      XCTAssertEqual(4, self.dataSource.numberOfSections(in: self.tableView))

      // overview
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // campaign
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      // faqsHeader
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsHeaderSection)
      )

      // faqsEmpty
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsEmptySection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.faqsHeaderSection)
      )
      XCTAssertEqual(
        "ProjectFAQsEmptyStateCell",
        self.dataSource.reusableId(item: 0, section: self.faqsEmptySection)
      )
    }
  }

  func testRisks() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [],
      faqs: [],
      risks: "These are all the risks and challenges associated with this project. Lorem Ipsum",
      story: "",
      minimumPledgeAmount: 1
    )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .risks,
        projectProperties: projectProperties,
        isExpandedStates: nil
      )
      XCTAssertEqual(9, self.dataSource.numberOfSections(in: self.tableView))

      // overview
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // campaign
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      // faqsHeader
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsHeaderSection)
      )

      // faqsEmpty
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsEmptySection)
      )

      // faqs
      XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsSection))

      // faqsAskAQuestion
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsAskAQuestionSection)
      )

      // risksHeader
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksHeaderSection)
      )

      // risks
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksSection)
      )

      // risksDisclaimer
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksDisclaimerSection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.risksHeaderSection)
      )
      XCTAssertEqual(
        "ProjectRisksCell",
        self.dataSource.reusableId(item: 0, section: self.risksSection)
      )
      XCTAssertEqual(
        "ProjectRisksDisclaimerCell",
        self.dataSource.reusableId(item: 0, section: self.risksDisclaimerSection)
      )
    }
  }

  func testLoadEnvironmentalCommitments() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: self.environmentalCommitments,
      faqs: [],
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .environmentalCommitments,
        projectProperties: projectProperties,
        isExpandedStates: nil
      )
      XCTAssertEqual(12, self.dataSource.numberOfSections(in: self.tableView))

      // overview
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // campaign
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      // faqsHeader
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsHeaderSection)
      )

      // faqsEmpty
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsEmptySection)
      )

      // faqs
      XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsSection))

      // faqsAskAQuestion
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsAskAQuestionSection)
      )

      // risksHeader
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksHeaderSection)
      )

      // risks
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksSection)
      )

      // risksDisclaimer
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksDisclaimerSection)
      )

      // environmentCommitmentsHeader
      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.environmentalCommitmentsHeaderSection)
      )

      // environmentalCommitments
      XCTAssertEqual(
        4,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.environmentalCommitmentsSection)
      )

      // environmentalCommitmentsDisclaimer
      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.environmentalCommitmentsDisclaimerSection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsHeaderSection)
      )
      XCTAssertEqual(
        "ProjectEnvironmentalCommitmentCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsSection)
      )
      XCTAssertEqual(
        "ProjectEnvironmentalCommitmentDisclaimerCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsDisclaimerSection)
      )
    }
  }

  func testLoadEnvironmentalCommitments_EmptyState() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [],
      faqs: [],
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .environmentalCommitments,
        projectProperties: projectProperties,
        isExpandedStates: nil
      )
      XCTAssertEqual(12, self.dataSource.numberOfSections(in: self.tableView))

      // overview
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // campaign
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      // faqsHeader
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsHeaderSection)
      )

      // faqsEmpty
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsEmptySection)
      )

      // faqs
      XCTAssertEqual(0, self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsSection))

      // faqsAskAQuestion
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.faqsAskAQuestionSection)
      )

      // risksHeader
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksHeaderSection)
      )

      // risks
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksSection)
      )

      // risksDisclaimer
      XCTAssertEqual(
        0,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.risksDisclaimerSection)
      )

      // environmentCommitmentsHeader
      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.environmentalCommitmentsHeaderSection)
      )

      // environmentalCommitments
      XCTAssertEqual(
        0,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.environmentalCommitmentsSection)
      )

      // environmentalCommitmentsDisclaimer
      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.environmentalCommitmentsDisclaimerSection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsHeaderSection)
      )
      XCTAssertEqual(
        "ProjectEnvironmentalCommitmentDisclaimerCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsDisclaimerSection)
      )
    }
  }

  func testIsExpandedValuesForFAQsSection() {
    let isExpandedStates = [false, true, false, true]
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [],
      faqs: self.faqs,
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    self.dataSource.load(
      navigationSection: .faq,
      projectProperties: projectProperties,
      isExpandedStates: isExpandedStates
    )

    XCTAssertEqual(self.dataSource.isExpandedValuesForFAQsSection(), isExpandedStates)
  }
}
