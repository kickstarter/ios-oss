import AVFoundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class ProjectPageViewControllerDataSourceTests: XCTestCase {
  private let dataSource = ProjectPageViewControllerDataSource()
  private let tableView = UITableView()

  private let expectedTime = CMTime(seconds: 123.4, preferredTimescale: CMTimeScale(1))
  private let projectTabFundingOptions = ProjectTabFundingOptions(
    fundingForAiAttribution: true,
    fundingForAiConsent: true,
    fundingForAiOption: true
  )

  private let generationDisclosure = ProjectTabGenerationDisclosure(
    consent: "consent", details: "details"
  )

  private let generatedByAIOtherDetails = ProjectTabCategoryDescription(
    description: "other",
    category: .aiDisclosureOtherDetails,
    id: 4
  )

  private var useOfAIDisclosure: ProjectAIDisclosure {
    ProjectAIDisclosure(
      id: 1,
      funding: self.projectTabFundingOptions,
      generationDisclosure: self.generationDisclosure,
      involvesAi: true,
      involvesFunding: true,
      involvesGeneration: true,
      involvesOther: true,
      otherAiDetails: self.generatedByAIOtherDetails
    )
  }

  private let environmentalCommitments = [
    ProjectTabCategoryDescription(
      description: "foo bar",
      category: .environmentallyFriendlyFactories,
      id: 0
    ),
    ProjectTabCategoryDescription(description: "hello world", category: .longLastingDesign, id: 1),
    ProjectTabCategoryDescription(
      description: "Lorem ipsum",
      category: .reusabilityAndRecyclability,
      id: 2
    ),
    ProjectTabCategoryDescription(description: "blah blah blah", category: .sustainableDistribution, id: 3)
  ]

  private let faqs = [
    ProjectFAQ(answer: "Answer 1", question: "Question 1", id: 0, createdAt: nil),
    ProjectFAQ(answer: "Answer 2", question: "Question 2", id: 1, createdAt: nil),
    ProjectFAQ(answer: "Answer 3", question: "Question 3", id: 2, createdAt: nil),
    ProjectFAQ(answer: "Answer 4", question: "Question 4", id: 3, createdAt: nil)
  ]

  private let storyViewableElements = ProjectStoryElements(
    htmlViewElements:
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
      ),
      AudioVideoViewElement(
        sourceURLString: "https://source.com",
        thumbnailURLString: "https://thumbnail.com",
        seekPosition: .zero
      ),
      ExternalSourceViewElement(
        embeddedURLString: "https://externalsource.com",
        embeddedURLContentHeight: 123
      )
    ]
  )

  private let overviewCreatorHeaderSection = ProjectPageViewControllerDataSource.Section.overviewCreatorHeader
    .rawValue
  private let overviewSection = ProjectPageViewControllerDataSource.Section.overview.rawValue
  private let overviewSubpagesSection = ProjectPageViewControllerDataSource.Section.overviewSubpages.rawValue
  private let overviewReportProject = ProjectPageViewControllerDataSource.Section.overviewReportProject
    .rawValue
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
  private let useOfAIDisclosureHeaderSection = ProjectPageViewControllerDataSource.Section.aiDisclosureHeader
    .rawValue
  private let useOfAIDisclosureFundingSection = ProjectPageViewControllerDataSource.Section
    .aiDisclosureFunding.rawValue
  private let useOfAIDisclosureGeneratedSection = ProjectPageViewControllerDataSource.Section
    .aiDisclosureGenerated.rawValue
  private let useOfAIDisclosureOtherDetailsSection = ProjectPageViewControllerDataSource.Section
    .aiDisclosureOtherDetails.rawValue
  private let useOfAIDisclosureDisclaimerSection = ProjectPageViewControllerDataSource.Section
    .aiDisclosureDisclaimer.rawValue

  func testLoadFAQs_LoggedIn() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: self.faqs,
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .faq,
        project: project,
        refTag: nil,
        isExpandedStates: [false, false, false, false]
      )
      XCTAssertEqual(11, self.dataSource.numberOfSections(in: self.tableView))

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
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: nil) {
      self.dataSource.load(
        navigationSection: .faq,
        project: project,
        refTag: nil,
        isExpandedStates: [false, false, false, false]
      )
      XCTAssertEqual(10, self.dataSource.numberOfSections(in: self.tableView))

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
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .faq,
        project: project,
        refTag: nil
      )
      XCTAssertEqual(11, self.dataSource.numberOfSections(in: self.tableView))

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
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: nil) {
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
        aiDisclosure: nil,
        risks: "These are all the risks and challenges associated with this project. Lorem Ipsum",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .risks,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(14, self.dataSource.numberOfSections(in: self.tableView))

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

  func testUseOfAI_AllSectionsShown_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: self.useOfAIDisclosure,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .aiDisclosure,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(19, self.dataSource.numberOfSections(in: self.tableView))

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureHeaderSection)
      )

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureFundingSection)
      )

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureGeneratedSection)
      )

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureOtherDetailsSection)
      )

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureDisclaimerSection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureHeaderSection)
      )
      XCTAssertEqual(
        "ProjectTabDisclaimerCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureDisclaimerSection)
      )
      XCTAssertEqual(
        "ProjectTabCheckmarkListCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureFundingSection)
      )

      XCTAssertEqual(
        "ProjectTabAIGenerationCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureGeneratedSection)
      )

      XCTAssertEqual(
        "ProjectTabCategoryDescriptionCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureOtherDetailsSection)
      )
    }
  }

  func testUseOfAI_NoFundingAndDetailsSection_Success() {
    var updatedUseOfAIDisclosure = self.useOfAIDisclosure

    updatedUseOfAIDisclosure.involvesFunding = false
    updatedUseOfAIDisclosure.generationDisclosure =
      ProjectTabGenerationDisclosure(consent: "consent", details: nil)

    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: updatedUseOfAIDisclosure,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .aiDisclosure,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(19, self.dataSource.numberOfSections(in: self.tableView))

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureHeaderSection)
      )

      XCTAssertEqual(
        0,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureFundingSection)
      )

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureGeneratedSection)
      )

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureOtherDetailsSection)
      )

      XCTAssertEqual(
        1,
        self.dataSource
          .tableView(self.tableView, numberOfRowsInSection: self.useOfAIDisclosureDisclaimerSection)
      )

      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureHeaderSection)
      )
      XCTAssertEqual(
        "ProjectTabDisclaimerCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureDisclaimerSection)
      )
      XCTAssertNil(
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureFundingSection)
      )

      XCTAssertEqual(
        "ProjectTabAIGenerationCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureGeneratedSection)
      )

      XCTAssertEqual(
        "ProjectTabCategoryDescriptionCell",
        self.dataSource.reusableId(item: 0, section: self.useOfAIDisclosureOtherDetailsSection)
      )
    }
  }

  func testLoadEnvironmentalCommitments() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: self.environmentalCommitments,
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .environmentalCommitments,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(22, self.dataSource.numberOfSections(in: self.tableView))

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
        "ProjectTabCategoryDescriptionCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsSection)
      )
      XCTAssertEqual(
        "ProjectTabDisclaimerCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsDisclaimerSection)
      )
    }
  }

  func testLoadEnvironmentalCommitments_EmptyState() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .environmentalCommitments,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(22, self.dataSource.numberOfSections(in: self.tableView))

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
        "ProjectTabDisclaimerCell",
        self.dataSource.reusableId(item: 0, section: self.environmentalCommitmentsDisclaimerSection)
      )
    }
  }

  func testCampaign_WithStoryElements() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(7, self.dataSource.numberOfSections(in: self.tableView))

      // campaign header section
      XCTAssertEqual(
        1,
        self.dataSource.tableView(self.tableView, numberOfRowsInSection: self.campaignHeaderSection)
      )

      // campaign
      XCTAssertEqual(
        5,
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
        "AudioVideoViewElementCell",
        self.dataSource.reusableId(item: 3, section: self.campaignSection)
      )
      XCTAssertEqual(
        "ExternalSourceViewElementCell",
        self.dataSource.reusableId(item: 4, section: self.campaignSection)
      )
      XCTAssertEqual(
        "ProjectHeaderCell",
        self.dataSource.reusableId(item: 0, section: self.campaignHeaderSection)
      )
    }
  }

  func testOverview() {
    let project = Project.template
      |> \.displayPrelaunch .~ false
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .overview,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )
      XCTAssertEqual(5, self.dataSource.numberOfSections(in: self.tableView))

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
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
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
      |> \.displayPrelaunch .~ false
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
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
      |> \.displayPrelaunch .~ false
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
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
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
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
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
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
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      guard let imageViewElement = self.storyViewableElements.htmlViewElements[2] as? ImageViewElement
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

  func testCampaign_WithAudioVideoViewElementPreload_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )
    let image = UIImage(systemName: "camera")!

    withEnvironment(currentUser: .template) {
      guard let audioVideoViewElement = self.storyViewableElements
        .htmlViewElements[3] as? AudioVideoViewElement
      else {
        XCTFail("audio video view element should exist in story view elements.")

        return
      }

      let expectedIndexPath = IndexPath(
        row: 3,
        section: ProjectPageViewControllerDataSource.Section.campaign.rawValue
      )

      self.dataSource
        .preloadCampaignAudioVideoViewElement(audioVideoViewElement, player: AVPlayer(), image: image)

      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )

      guard let updatedItem = self.dataSource
        .items(in: expectedIndexPath.section)[expectedIndexPath.row] as? (
          value: (AudioVideoViewElement, AVPlayer, UIImage),
          reusableId: String
        ) else {
        XCTFail("audio video view element should exist")

        return
      }

      XCTAssertEqual(updatedItem.value.0.sourceURLString, "https://source.com")
      XCTAssertEqual(updatedItem.value.0.thumbnailURLString, "https://thumbnail.com")
      XCTAssertEqual(updatedItem.value.0.seekPosition, .zero)
      XCTAssertNotNil(updatedItem.value.1)
      XCTAssertNotNil(updatedItem.value.2)
    }
  }

  func testCampaign_IsIndexPathAnImageViewElement_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
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

  func testCampaign_ImageViewElementURL_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
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

      let textViewElementURL = self.dataSource.imageViewElementURL(
        tableView: self.tableView,
        indexPath: textViewIndexPath
      )

      XCTAssertNil(textViewElementURL)

      let imageViewIndexPath = IndexPath(
        row: 2,
        section: ProjectPageViewControllerDataSource.Section.campaign
          .rawValue
      )

      let imageViewElementURL = self.dataSource.imageViewElementURL(
        tableView: self.tableView,
        indexPath: imageViewIndexPath
      )!
      let url = URL(string: "https://href.com")!

      XCTAssertEqual(imageViewElementURL, url)
    }
  }

  func testCampaign_AudioVideoViewElementWithNoPlayer_Updated_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )
    let camera = UIImage(systemName: "camera")!

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )

      let audioVideoViewIndexPath = IndexPath(
        row: 3,
        section: ProjectPageViewControllerDataSource.Section.campaign
          .rawValue
      )
      var audioVideoViewElementWithNoPlayer = self.dataSource.audioVideoViewElementWithNoPlayer(
        tableView: self.tableView,
        indexPath: audioVideoViewIndexPath,
        section: ProjectPageViewControllerDataSource
          .Section.campaign
      )

      XCTAssertNotNil(audioVideoViewElementWithNoPlayer)

      self.dataSource
        .updateAudioVideoViewElementWith(
          audioVideoViewElementWithNoPlayer!.0,
          player: AVPlayer(),
          thumbnailImage: camera,
          indexPath: audioVideoViewElementWithNoPlayer!.1
        )

      audioVideoViewElementWithNoPlayer = self.dataSource.audioVideoViewElementWithNoPlayer(
        tableView: self.tableView,
        indexPath: audioVideoViewIndexPath,
        section: ProjectPageViewControllerDataSource
          .Section.campaign
      )

      XCTAssertNil(audioVideoViewElementWithNoPlayer)
    }
  }

  func testCampaign_AudioVideoViewElementWithNoSeektime_Updated_Success() {
    let project = Project.template
      |> \.extendedProjectProperties .~ ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        aiDisclosure: nil,
        risks: "",
        story: self.storyViewableElements,
        minimumPledgeAmount: 1,
        projectNotice: nil
      )

    withEnvironment(currentUser: .template) {
      self.dataSource.load(
        navigationSection: .campaign,
        project: project,
        refTag: nil,
        isExpandedStates: nil
      )

      let audioVideoViewIndexPath = IndexPath(
        row: 3,
        section: ProjectPageViewControllerDataSource.Section.campaign
          .rawValue
      )

      let audioVideoViewElementWithNoPlayer = self.dataSource.audioVideoViewElementWithNoPlayer(
        tableView: self.tableView,
        indexPath: audioVideoViewIndexPath,
        section: ProjectPageViewControllerDataSource
          .Section.campaign
      )

      self.dataSource
        .updateAudioVideoViewElementWith(
          audioVideoViewElementWithNoPlayer!.0,
          player: AVPlayer(),
          thumbnailImage: nil,
          indexPath: audioVideoViewElementWithNoPlayer!.1
        )

      self.dataSource.updateAudioVideoViewElementSeektime(
        with: self.expectedTime,
        tableView: self.tableView,
        indexPath: audioVideoViewIndexPath
      )
      guard let updatedItem = self.dataSource
        .items(
          in: audioVideoViewIndexPath
            .section
        )[audioVideoViewIndexPath.row] as? (
          value: (AudioVideoViewElement, AVPlayer, UIImage?),
          reusableId: String
        )
      else {
        XCTFail("audio video view element should exist")

        return
      }

      XCTAssertEqual(
        updatedItem.value.0.seekPosition,
        self.expectedTime
      )
    }
  }
}
