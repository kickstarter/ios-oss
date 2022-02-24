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

  private let storyViewableElements = ProjectStoryElements(htmlViewElements:
    [
      TextViewElement(components: [
        TextComponent(
          text: "bold and emphasis",
          link: nil,
          styles: [.bold, .emphasis]
        ),
        TextComponent(
          text: "link",
          link: "https://ksr.com",
          styles: [.link]
        )
      ]),
      TextViewElement(components: []),
      ImageViewElement(
        src: "http://imagetest.com",
        href: "https://href.com",
        caption: "caption"
      )
    ])

  private let overviewCreatorHeaderSection = ProjectPageViewControllerDataSource.Section.overviewCreatorHeader
    .rawValue
  private let overviewSection = ProjectPageViewControllerDataSource.Section.overview.rawValue
  private let overviewSubpagesSection = ProjectPageViewControllerDataSource.Section.overviewSubpages.rawValue
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
  private let campaignHeaderSection = ProjectPageViewControllerDataSource.Section
    .campaignHeader.rawValue
  private let campaignSection = ProjectPageViewControllerDataSource.Section.campaign.rawValue

  func testLoadFAQs_LoggedIn() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: self.faqs,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .faq,
        project: project,
        refTag: nil,
        isExpandedStates: [false, false, false, false]
      )
      XCTAssertEqual(9, self.dataSource.numberOfSections(in: self.tableView))

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
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: self.faqs,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: nil) {
      self.dataSource.load(
        navigationSection: .faq,
        project: project,
        refTag: nil,
        isExpandedStates: [false, false, false, false]
      )
      XCTAssertEqual(8, self.dataSource.numberOfSections(in: self.tableView))

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
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .faq,
        project: project,
        refTag: nil
      )
      XCTAssertEqual(9, self.dataSource.numberOfSections(in: self.tableView))

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
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: nil) {
      self.dataSource.load(
        navigationSection: .faq,
        project: project,
        refTag: nil
      )
      XCTAssertEqual(7, self.dataSource.numberOfSections(in: self.tableView))

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
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "These are all the risks and challenges associated with this project. Lorem Ipsum",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .risks,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(12, self.dataSource.numberOfSections(in: self.tableView))

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
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: self.environmentalCommitments,
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .environmentalCommitments,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(15, self.dataSource.numberOfSections(in: self.tableView))

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
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .environmentalCommitments,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(15, self.dataSource.numberOfSections(in: self.tableView))

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

  func testCampaign_WithStoryElements() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(5, self.dataSource.numberOfSections(in: self.tableView))

      // campaign header section
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignHeaderSection)
      )

      // campaign
      XCTAssertEqual(
        3,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignSection)
      )

      XCTAssertEqual(
        "TextViewElementCell",
        self.dataSource.reusableId(item: 0, section: self.campaignSection)
      )
      XCTAssertEqual(
        "ImageViewElementCell",
        self.dataSource.reusableId(item: 2, section: self.campaignSection)
      )
      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.campaignHeaderSection)
      )
    }
  }

  func testOverview() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .overview,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(3, self.dataSource.numberOfSections(in: self.tableView))

      // overviewCreatorHeader
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewCreatorHeaderSection)
      )

      // overview
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSection)
      )

      // overviewSubpages
      XCTAssertEqual(
        2,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.overviewSubpagesSection)
      )

      XCTAssertEqual(
        "ProjectPamphletMainCell",
        self.dataSource.reusableId(item: 0, section: self.overviewSection)
      )
      XCTAssertEqual(
        "ProjectPamphletSubpageCell",
        self.dataSource.reusableId(item: 0, section: self.overviewSubpagesSection)
      )
    }
  }

  func testIsExpandedValuesForFAQsSection() {
    let isExpandedStates = [false, true, false, true]
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: self.faqs,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    self.dataSource.load(
      navigationSection: .faq,
      project: project,
      refTag: nil,
      isExpandedStates: isExpandedStates
    )

    XCTAssertEqual(self.dataSource.isExpandedValuesForFAQsSection(), isExpandedStates)
  }

  func testIndexPathIsCommentsSubpage() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    self.dataSource.load(
      navigationSection: .overview,
      project: project,
      refTag: nil
    )

    XCTAssertEqual(
      self.dataSource
        .indexPathIsCommentsSubpage(IndexPath(row: 0, section: self.overviewSubpagesSection)),
      true
    )
  }

  func testIndexPathIsUpdatesSubpage() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    self.dataSource.load(
      navigationSection: .overview,
      project: project,
      refTag: nil
    )

    XCTAssertEqual(
      self.dataSource
        .indexPathIsUpdatesSubpage(IndexPath(row: 1, section: self.overviewSubpagesSection)),
      true
    )
  }

  func testUpdatingCampaign_WithImageViewElementImage_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )

      let expectedURL = URL(string: "http://imagetest.com")!
      let expectedIndexPath = IndexPath(
        row: 2,
        section: ProjectPageViewControllerDataSource.Section.campaign.rawValue
      )

      guard let noImageData = self.dataSource.imageViewElementWith(
        urls: [expectedURL],
        indexPath: expectedIndexPath
      ) else {
        XCTFail("one image view element should have been loaded.")

        return
      }

      XCTAssertEqual(noImageData.element.src, "http://imagetest.com")
      XCTAssertEqual(noImageData.element.href, "https://href.com")
      XCTAssertEqual(noImageData.element.caption, "caption")

      let expectedImage = UIImage(systemName: "camera")!

      self.dataSource
        .updateImageViewElementWith(
          noImageData.element,
          image: expectedImage,
          indexPath: noImageData.indexPath
        )

      guard let imageData = self.dataSource.imageViewElementWith(
        urls: [expectedURL],
        indexPath: expectedIndexPath
      ) else {
        XCTFail("one image view element should have been loaded.")

        return
      }

      XCTAssertEqual("http://imagetest.com", imageData.element.src)
      XCTAssertEqual(noImageData.element.href, "https://href.com")
      XCTAssertEqual(noImageData.element.caption, "caption")
      XCTAssertEqual(imageData.image, expectedImage)
    }
  }

  func testCampaign_WithImageViewElementRetrieval_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )

      let expectedIndexPath = IndexPath(
        row: 2,
        section: ProjectPageViewControllerDataSource.Section.campaign.rawValue
      )

      let emptyData = self.dataSource.imageViewElementWith(urls: [], indexPath: expectedIndexPath)

      XCTAssertNil(emptyData)

      let expectedURL = URL(string: "http://imagetest.com")!
      let expectedImage = UIImage(systemName: "camera")!

      guard let noImageData = self.dataSource.imageViewElementWith(
        urls: [expectedURL],
        indexPath: expectedIndexPath
      ) else {
        XCTFail("one image view element should be found for matching URL")

        return
      }

      self.dataSource
        .updateImageViewElementWith(
          noImageData.element,
          image: expectedImage,
          indexPath: noImageData.indexPath
        )

      guard let imageData = self.dataSource.imageViewElementWith(
        urls: [expectedURL],
        indexPath: expectedIndexPath
      ) else {
        XCTFail("one image view element should be found for matching URL")

        return
      }

      XCTAssertEqual(imageData.element.src, "http://imagetest.com")
      XCTAssertEqual(imageData.element.href, "https://href.com")
      XCTAssertEqual(imageData.element.caption, "caption")
      XCTAssertEqual(imageData.image, expectedImage)
      XCTAssertEqual(imageData.url, expectedURL)
      XCTAssertEqual(imageData.indexPath, expectedIndexPath)
    }
  }

  func testCampaign_WithImageViewElementPreload_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      guard let imageViewElement = self.storyViewableElements.htmlViewElements.last as? ImageViewElement
      else {
        XCTFail("image view element should exist in story view elements.")

        return
      }

      let expectedImage = UIImage(systemName: "camera")!
      let expectedURL = URL(string: "http://imagetest.com")!
      let expectedIndexPath = IndexPath(
        row: 2,
        section: ProjectPageViewControllerDataSource.Section.campaign.rawValue
      )

      self.dataSource.preloadCampaignImageViewElement(imageViewElement, image: expectedImage)

      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )

      guard let imageData = self.dataSource.imageViewElementWith(
        urls: [expectedURL],
        indexPath: expectedIndexPath
      ) else {
        XCTFail("one image view element should have been loaded.")

        return
      }

      XCTAssertEqual(imageData.element.src, "http://imagetest.com")
      XCTAssertEqual(imageData.element.href, "https://href.com")
      XCTAssertEqual(imageData.element.caption, "caption")
      XCTAssertEqual(imageData.image, expectedImage)
      XCTAssertEqual(imageData.url, expectedURL)
      XCTAssertEqual(imageData.indexPath, expectedIndexPath)
    }
  }

  func testCampaign_IsIndexPathAnImageViewElement_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )

      let textViewIndexPath = IndexPath(
        row: 1,
        section: ProjectPageViewControllerDataSource.Section.campaign
          .rawValue
      )
      let textViewElement = self.dataSource.isIndexPathAnImageViewElement(
        tableView: self.tableView,
        indexPath: textViewIndexPath,
        section: ProjectPageViewControllerDataSource
          .Section.campaign
      )
      XCTAssertFalse(textViewElement)

      let imageViewIndexPath = IndexPath(
        row: 2,
        section: ProjectPageViewControllerDataSource.Section.campaign
          .rawValue
      )
      let imageViewElement = self.dataSource.isIndexPathAnImageViewElement(
        tableView: self.tableView,
        indexPath: imageViewIndexPath,
        section: ProjectPageViewControllerDataSource
          .Section.campaign
      )
      XCTAssertTrue(imageViewElement)
    }
  }
}
