import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library

final class ProjectFooterViewModelTests: TestCase {
  private let vm: ProjectFooterViewModelType = ProjectFooterViewModel()

  private let backedProjectsLabelText = TestObserver<String, NoError>()
  private let categoryButtonTitle = TestObserver<String, NoError>()
  private let createdProjectsLabelText = TestObserver<String, NoError>()
  private let creatorImageUrl = TestObserver<NSURL?, NoError>()
  private let creatorNameLabelText = TestObserver<String, NoError>()
  private let keepReadingHidden = TestObserver<Bool, NoError>()
  private let locationButtonTitle = TestObserver<String, NoError>()
  private let notifyDelegateToExpandDescription = TestObserver<(), NoError>()
  private let updatesLabelText = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backedProjectsLabelText.observe(self.backedProjectsLabelText.observer)
    self.vm.outputs.categoryButtonTitle.observe(self.categoryButtonTitle.observer)
    self.vm.outputs.createdProjectsLabelText.observe(self.createdProjectsLabelText.observer)
    self.vm.outputs.creatorImageUrl.observe(self.creatorImageUrl.observer)
    self.vm.outputs.creatorNameLabelText.observe(self.creatorNameLabelText.observer)
    self.vm.outputs.keepReadingHidden.observe(self.keepReadingHidden.observer)
    self.vm.outputs.locationButtonTitle.observe(self.locationButtonTitle.observer)
    self.vm.outputs.notifyDelegateToExpandDescription.observe(self.notifyDelegateToExpandDescription.observer)
    self.vm.outputs.updatesLabelText.observe(self.updatesLabelText.observer)
  }

  func testBackedProjectsLabel() {
    self.vm.inputs.configureWith(project:
      .template
        |> (Project.lens.creator • User.lens.stats • User.Stats.lens.backedProjectsCount) .~ 2
    )
    self.vm.inputs.viewDidLoad()

    self.backedProjectsLabelText.assertValues(
      [Strings.social_following_friend_projects_count_backed(backed_count: 2)]
    )
  }

  func testBackedProjectsLabelWithBadData() {
    self.vm.inputs.configureWith(project:
      .template
        |> (Project.lens.creator • User.lens.stats • User.Stats.lens.backedProjectsCount) .~ nil
    )
    self.vm.inputs.viewDidLoad()

    self.backedProjectsLabelText.assertValues(
      [Strings.social_following_friend_projects_count_backed(backed_count: 0)]
    )
  }

  func testCategoryLabel() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.categoryButtonTitle.assertValues([project.category.name])
  }

  func testFirstCreatedProjectsLabel() {
    self.vm.inputs.configureWith(project:
      .template
        |> (Project.lens.creator • User.lens.stats • User.Stats.lens.createdProjectsCount) .~ 1
    )
    self.vm.inputs.viewDidLoad()

    self.createdProjectsLabelText.assertValues(["First created"])
  }

  func testCreatedProjectsLabelWithBadData() {
    self.vm.inputs.configureWith(project:
      .template
        |> (Project.lens.creator • User.lens.stats • User.Stats.lens.createdProjectsCount) .~ nil
    )
    self.vm.inputs.viewDidLoad()

    self.createdProjectsLabelText.assertValues(["First created"])
  }

  func testRepeatCreatorCreatedProjectsLabel() {
    self.vm.inputs.configureWith(project:
      .template
        |> (Project.lens.creator • User.lens.stats • User.Stats.lens.createdProjectsCount) .~ 2
    )
    self.vm.inputs.viewDidLoad()

    self.createdProjectsLabelText.assertValues(
      [Strings.social_following_friend_projects_count_created(created_count: 2)]
    )
  }

  func testCreatorImageUrl() {
    self.vm.inputs.configureWith(project: .template)
    self.vm.inputs.viewDidLoad()

    self.creatorImageUrl.assertValueCount(1)
  }

  func testCreatorNameLabel() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.creatorNameLabelText.assertValues([project.creator.name])
  }

  func testDescriptionExpansion() {
    self.vm.inputs.configureWith(project: .template)
    self.vm.inputs.viewDidLoad()

    self.keepReadingHidden.assertValues([false])
    self.notifyDelegateToExpandDescription.assertValueCount(0)

    self.vm.inputs.keepReadingButtonTapped()

    self.keepReadingHidden.assertValues([false, true])
    self.notifyDelegateToExpandDescription.assertValueCount(1)

    self.vm.inputs.keepReadingButtonTapped()

    self.keepReadingHidden.assertValues([false, true])
    self.notifyDelegateToExpandDescription.assertValueCount(1)
  }

  func testLocationLabel() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.locationButtonTitle.assertValues([project.location.displayableName])
  }

  func testLocationLabel_Empty_Location() {
    let project = .template |> Project.lens.location .~ .none
    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.locationButtonTitle.assertValues(["Earth"])
  }

  func testUpdatesLabel() {
    self.vm.inputs.configureWith(project:
      .template
        |> Project.lens.stats.updatesCount .~ 2
    )
    self.vm.inputs.viewDidLoad()

    self.updatesLabelText.assertValues(["2 updates"])
  }

  func testUpdatesLabelWithBadData() {
    self.vm.inputs.configureWith(project:
      .template
        |> Project.lens.stats.updatesCount .~ nil
    )
    self.vm.inputs.viewDidLoad()

    self.updatesLabelText.assertValues(["0 updates"])
  }
}
