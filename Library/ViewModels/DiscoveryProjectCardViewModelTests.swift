@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class DiscoveryProjectCardViewModelTests: TestCase {
  private let backerCountLabelBoldedString = TestObserver<String, Never>()
  private let backerCountLabelFullString = TestObserver<String, Never>()
  private let goalMetIconHidden = TestObserver<Bool, Never>()
  private let loadProjectTags = TestObserver<[DiscoveryProjectTagPillCellValue], Never>()
  private let percentFundedLabelBoldedString = TestObserver<String, Never>()
  private let percentFundedLabelFullString = TestObserver<String, Never>()
  private let projectBlurbLabelText = TestObserver<String, Never>()
  private let projectImageUrlString = TestObserver<String, Never>()
  private let projectNameLabelText = TestObserver<String, Never>()
  private let tagsCollectionViewHidden = TestObserver<Bool, Never>()

  private let vm: DiscoveryProjectCardViewModelType = DiscoveryProjectCardViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backerCountLabelData.map(first).observe(self.backerCountLabelBoldedString.observer)
    self.vm.outputs.backerCountLabelData.map(second).observe(self.backerCountLabelFullString.observer)
    self.vm.outputs.goalMetIconHidden.observe(self.goalMetIconHidden.observer)
    self.vm.outputs.loadProjectTags.observe(self.loadProjectTags.observer)
    self.vm.outputs.percentFundedLabelData.map(first).observe(self.percentFundedLabelBoldedString.observer)
    self.vm.outputs.percentFundedLabelData.map(second).observe(self.percentFundedLabelFullString.observer)
    self.vm.outputs.projectBlurbLabelText.observe(self.projectBlurbLabelText.observer)
    self.vm.outputs.projectImageURL.map(\.absoluteString).observe(self.projectImageUrlString.observer)
    self.vm.outputs.projectNameLabelText.observe(self.projectNameLabelText.observer)
    self.vm.outputs.tagsCollectionViewHidden.observe(self.tagsCollectionViewHidden.observer)
  }

  func testBackerCountLabelData() {
    let project = Project.template
      |> \.stats.backersCount .~ 315

    self.backerCountLabelBoldedString.assertDidNotEmitValue()
    self.backerCountLabelFullString.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, nil, nil))

    self.backerCountLabelBoldedString.assertValues(["315"])
    self.backerCountLabelFullString.assertValues(["315 backers"])
  }

  func testPercentFundedLabelData_ProjectNotFunded() {
    let project = Project.template
      |> \.stats.goal .~ 1_000
      |> \.stats.pledged .~ 500

    self.percentFundedLabelFullString.assertDidNotEmitValue()
    self.percentFundedLabelBoldedString.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, nil, nil))

    self.percentFundedLabelBoldedString.assertValues(["50%"])
    self.percentFundedLabelFullString.assertValues(["50% funded"])
  }

  func testPercentFundedLabelData_ProjectFunded() {
    let project = Project.template
      |> \.stats.goal .~ 1_000
      |> \.stats.pledged .~ 1_100

    self.percentFundedLabelFullString.assertDidNotEmitValue()
    self.percentFundedLabelBoldedString.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, nil, nil))

    self.percentFundedLabelBoldedString.assertValues(["Goal met"])
    self.percentFundedLabelFullString.assertValues(["Goal met"])
  }

  func testGoalMetIconHidden_ProjectNotFunded() {
    let project = Project.template
      |> \.stats.goal .~ 1_000
      |> \.stats.pledged .~ 500

    self.goalMetIconHidden.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, nil, nil))

    self.goalMetIconHidden.assertValues([true])
  }

  func testGoalMetIconHidden_ProjectFunded() {
    let project = Project.template
      |> \.stats.goal .~ 1_000
      |> \.stats.pledged .~ 2_000

    self.goalMetIconHidden.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, nil, nil))

    self.goalMetIconHidden.assertValues([false])
  }

  func testProjectBlurbLabelText() {
    self.projectBlurbLabelText.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (Project.template, nil, nil))

    self.projectBlurbLabelText.assertValues(["A fun project."])
  }

  func testProjectNameLabelText() {
    self.projectNameLabelText.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (Project.template, nil, nil))

    self.projectNameLabelText.assertValues(["The Project"])
  }

  func testProjectImageURL() {
    self.projectImageUrlString.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (Project.template, nil, nil))

    self.projectImageUrlString.assertValues(["http://www.kickstarter.com/full.jpg"])
  }

  func testTagsCollectionViewHidden_FilteredCategoryIsNil() {
    let project = Project.template
      |> \.staffPick .~ false
      |> \.category .~ .illustration

    self.tagsCollectionViewHidden.assertDidNotEmitValue()
    self.loadProjectTags.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, nil, nil))

    self.tagsCollectionViewHidden.assertValues([false])
    self.loadProjectTags.assertValues([
      [DiscoveryProjectTagPillCellValue(
        type: .grey,
        tagIconImageName: "icon--compass",
        tagLabelText: "Illustration"
      )]
    ])
  }

  func testTagsCollectionViewHidden_WhenProjectIsNotStaffPick_FilteredCategoryIsParentCategory() {
    let project = Project.template
      |> \.staffPick .~ false
      |> \.category .~ .illustration

    self.tagsCollectionViewHidden.assertDidNotEmitValue()
    self.loadProjectTags.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, .art, nil))

    self.tagsCollectionViewHidden.assertValues([false])
    self.loadProjectTags.assertValues([
      [DiscoveryProjectTagPillCellValue(
        type: .grey,
        tagIconImageName: "icon--compass",
        tagLabelText: "Illustration"
      )]
    ])
  }

  func testTagsCollectionViewHidden_WhenProjectIsStaffPick_FilteredCategoryIsParentCategory() {
    let project = Project.template
      |> \.staffPick .~ true
      |> \.category .~ .illustration

    self.tagsCollectionViewHidden.assertDidNotEmitValue()
    self.loadProjectTags.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, .art, nil))

    self.tagsCollectionViewHidden.assertValues([false])
    self.loadProjectTags.assertValues([
      [
        DiscoveryProjectTagPillCellValue(
          type: .green,
          tagIconImageName: "icon--small-k",
          tagLabelText: "Projects We Love"
        ),
        DiscoveryProjectTagPillCellValue(
          type: .grey,
          tagIconImageName: "icon--compass",
          tagLabelText: "Illustration"
        )
      ]
    ])
  }

  func testTagsCollectionViewHidden_WhenProjectIsStaffPick_FilteredCategoryIsProjectCategory() {
    let project = Project.template
      |> \.staffPick .~ true
      |> \.category .~ .illustration

    self.tagsCollectionViewHidden.assertDidNotEmitValue()
    self.loadProjectTags.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, .illustration, nil))

    self.tagsCollectionViewHidden.assertValues([false])
    self.loadProjectTags.assertValues([
      [
        DiscoveryProjectTagPillCellValue(
          type: .green,
          tagIconImageName: "icon--small-k",
          tagLabelText: "Projects We Love"
        )
      ]
    ])
  }

  func testTagsCollectionViewHidden_WhenProjectIsNotStaffPick_FilteredCategoryIsProjectCategory() {
    let project = Project.template
      |> \.staffPick .~ false
      |> \.category .~ .illustration

    self.tagsCollectionViewHidden.assertDidNotEmitValue()
    self.loadProjectTags.assertDidNotEmitValue()

    self.vm.inputs.configure(with: (project, .illustration, nil))

    self.tagsCollectionViewHidden.assertValues([true])
    self.loadProjectTags.assertDidNotEmitValue()
  }
}
