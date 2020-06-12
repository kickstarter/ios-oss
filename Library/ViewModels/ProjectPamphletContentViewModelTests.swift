@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ProjectPamphletContentViewModelTests: TestCase {
  fileprivate let vm: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()

  fileprivate let goToBackingProjectParam = TestObserver<Param, Never>()
  fileprivate let goToBackingBackingParam = TestObserver<Param?, Never>()
  fileprivate let goToComments = TestObserver<Project, Never>()
  fileprivate let goToDashboard = TestObserver<Param, Never>()
  fileprivate let goToRewardPledgeProject = TestObserver<Project, Never>()
  fileprivate let goToRewardPledgeReward = TestObserver<Reward, Never>()
  fileprivate let goToUpdates = TestObserver<Project, Never>()
  fileprivate let loadProjectIntoDataSourceCreatorDetailsEnvelope
    = TestObserver<ProjectCreatorDetailsEnvelope?, Never>()
  fileprivate let loadProjectIntoDataSourceCreatorDetailsIsLoading = TestObserver<Bool, Never>()
  fileprivate let loadProjectIntoDataSourceProject = TestObserver<Project, Never>()
  fileprivate let loadProjectIntoDataSourceProjectSummaryItems
    = TestObserver<[ProjectSummaryEnvelope.ProjectSummaryItem], Never>()
  fileprivate let loadProjectIntoDataSourceRefTag = TestObserver<RefTag?, Never>()
  fileprivate let loadMinimalProjectIntoDataSource = TestObserver<Project, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToBacking.map(first).observe(self.goToBackingProjectParam.observer)
    self.vm.outputs.goToBacking.map(second).observe(self.goToBackingBackingParam.observer)
    self.vm.outputs.goToComments.observe(self.goToComments.observer)
    self.vm.outputs.goToDashboard.observe(self.goToDashboard.observer)
    self.vm.outputs.goToRewardPledge.map(first).observe(self.goToRewardPledgeProject.observer)
    self.vm.outputs.goToRewardPledge.map(second).observe(self.goToRewardPledgeReward.observer)
    self.vm.outputs.goToUpdates.observe(self.goToUpdates.observer)
    self.vm.outputs.loadProjectPamphletContentDataIntoDataSource.map { $0.0 }
      .observe(self.loadProjectIntoDataSourceProject.observer)
    self.vm.outputs.loadProjectPamphletContentDataIntoDataSource.map { $0.1 }.map(first)
      .observe(self.loadProjectIntoDataSourceCreatorDetailsEnvelope.observer)
    self.vm.outputs.loadProjectPamphletContentDataIntoDataSource.map { $0.1 }.map(second)
      .observe(self.loadProjectIntoDataSourceCreatorDetailsIsLoading.observer)
    self.vm.outputs.loadProjectPamphletContentDataIntoDataSource.map { $0.2 }
      .observe(self.loadProjectIntoDataSourceProjectSummaryItems.observer)
    self.vm.outputs.loadProjectPamphletContentDataIntoDataSource.map { $0.3 }
      .observe(self.loadProjectIntoDataSourceRefTag.observer)
    self.vm.outputs.loadMinimalProjectIntoDataSource.observe(self.loadMinimalProjectIntoDataSource.observer)
  }

  func testGoToBacking() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template
    let backing = Backing.template
      |> Backing.lens.reward .~ reward

    self.goToBackingProjectParam.assertDidNotEmitValue()
    self.goToBackingBackingParam.assertDidNotEmitValue()

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToBackingProjectParam.assertValues([.slug(project.slug)])
    self.goToBackingBackingParam.assertValues([.id(backing.id)])
  }

  func testGoToComments() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedComments()

    self.goToComments.assertValues([project])
  }

  func testGoToDashboard() {
    let project = Project.template
    let param: Param = .id(project.id)

    self.vm.inputs.tappedViewProgress(of: project)

    self.goToDashboard.assertValue(param)
  }

  func testGoToRewardPledge_LiveProject_NoReward() {
    let project = Project.template
    let reward = Reward.noReward

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_Reward() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_SoldOutReward() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_LiveProject_BackingNoReward() {
    let project = Project.template
    let reward = Reward.noReward
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingReward() {
    let project = Project.template
    let reward = Reward.template
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingSoldOutReward() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.remaining .~ 0
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingNoReward_TapAnotherReward() {
    let reward = Reward.template
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ .noReward
      )

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_LiveProject_BackingReward_TapNoReward() {
    let reward = Reward.noReward
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ .template
      )

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([project])
    self.goToRewardPledgeReward.assertValues([reward])
  }

  func testGoToRewardPledge_NonLiveProject_NoReward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.noReward

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_NonLiveProject_Reward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .left(reward))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_NonLiveProject_BackingNoReward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.noReward
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToRewardPledge_NonLiveProject_BackingReward() {
    let project = Project.template
      |> Project.lens.state .~ .successful
    let reward = Reward.template
    let backing = .template
      |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tapped(rewardOrBacking: .right(backing))

    self.goToRewardPledgeProject.assertValues([])
    self.goToRewardPledgeReward.assertValues([])
  }

  func testGoToUpdates() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, nil))
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.vm.inputs.tappedUpdates()

    self.goToUpdates.assertValues([project])
  }

  func testLoadProjectIntoDataSource_WhenPresentingProject() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, .discovery))
    self.vm.inputs.viewDidLoad()

    self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
    self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
    // navigator controller.
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.loadProjectIntoDataSourceProject
      .assertValues([project], "Load the full project into the data source.")
    self.loadProjectIntoDataSourceRefTag.assertValues([.discovery], "Load the refTag into the data source.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Do not load the minimal version of the project.")

    // End presentation.
    self.vm.inputs.viewWillAppear(animated: false)
    self.vm.inputs.viewDidAppear(animated: false)

    self.loadProjectIntoDataSourceProject
      .assertValues([project], "Nothing new emits when the view is done.")
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery], "Nothing new emits when the view is done."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

    // Simulate a new version of the project coming through
    self.vm.inputs.configureWith(value: (project, .discovery))

    self.loadProjectIntoDataSourceProject.assertValues(
      [project, project], "The new project is loaded into data source"
    )
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "The new refTag is loaded into data source"
    )
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")
  }

  func testLoadProjectIntoDataSource_Swiping() {
    let project = Project.template

    self.vm.inputs.configureWith(value: (project, .discovery))
    self.vm.inputs.viewDidLoad()

    self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
    self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
    self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

    // When swiping the project `animated` will be true.
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.scheduler.advance()

    self.loadProjectIntoDataSourceProject
      .assertValues([project], "The skeleton of the full project loads into the data source.")
    self.loadProjectIntoDataSourceRefTag.assertValues([.discovery], "RefTag is loaded.")
    self.loadMinimalProjectIntoDataSource.assertValues(
      [project], "The minimal version of the project loads into the data source."
    )

    self.vm.inputs.configureWith(value: (project, .discovery))

    self.loadProjectIntoDataSourceProject
      .assertValues([project, project], "Full project emits.")
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "RefTag emits with full project."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits when the view is done.")

    // Swipe the project again
    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectIntoDataSourceProject.assertValues(
      [project, project], "Nothing new emits."
    )
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "Nothing new emits."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")

    self.vm.inputs.viewWillAppear(animated: true)
    self.vm.inputs.viewDidAppear(animated: true)

    self.loadProjectIntoDataSourceProject.assertValues(
      [project, project], "Nothing new emits."
    )
    self.loadProjectIntoDataSourceRefTag.assertValues(
      [.discovery, .discovery], "Nothing new emits."
    )
    self.loadMinimalProjectIntoDataSource.assertValues([project], "Nothing new emits.")
  }

  func testLoadProjectIntoDataSource_CreatorDetailsLoaded_ExperimentalVariant() {
    let project = Project.template

    let envelope = ProjectCreatorDetailsEnvelope(backingsCount: 25, id: "123", launchedProjectsCount: 50)

    let mockService = MockService(fetchProjectCreatorDetailsResult: .success(envelope))

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageConversionCreatorDetails.rawValue: OptimizelyExperiment
          .Variant.variant1.rawValue
      ]

    withEnvironment(apiService: mockService, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, .discovery))
      self.vm.inputs.viewDidLoad()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

      // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
      // navigator controller.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true], "Starts loading.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil], "Emits nil as view appears")
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Load the full project into the data source.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Load the refTag into the data source."
      )
      self.loadMinimalProjectIntoDataSource.assertValues(
        [], "Do not load the minimal version of the project."
      )

      // End presentation.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil])
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Nothing new emits when the view is done.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Nothing new emits when the view is done."
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      // Simulate a new version of the project coming through
      self.vm.inputs.configureWith(value: (project, .discovery))

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true, true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil, nil])
      self.loadProjectIntoDataSourceProject.assertValues(
        [project, project], "The new project is loaded into data source"
      )
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery, .discovery], "The new refTag is loaded into data source"
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      self.scheduler.advance()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues(
        [true, true, false], "isLoading is false"
      )
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues(
        [nil, nil, envelope], "ProjectCreatorDetailsEnvelope is returned"
      )
      self.loadProjectIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery, .discovery, .discovery])
      self.loadMinimalProjectIntoDataSource.assertValues([])
    }
  }

  func testLoadProjectIntoDataSource_CreatorDetailsLoaded_ControlVariant() {
    let project = Project.template

    let envelope = ProjectCreatorDetailsEnvelope(backingsCount: 25, id: "123", launchedProjectsCount: 50)

    let mockService = MockService(fetchProjectCreatorDetailsResult: .success(envelope))

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageConversionCreatorDetails.rawValue: OptimizelyExperiment
          .Variant.control.rawValue
      ]

    withEnvironment(apiService: mockService, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, .discovery))
      self.vm.inputs.viewDidLoad()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

      // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
      // navigator controller.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true], "Starts loading.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil], "Emits nil as view appears")
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Load the full project into the data source.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Load the refTag into the data source."
      )
      self.loadMinimalProjectIntoDataSource.assertValues(
        [], "Do not load the minimal version of the project."
      )

      // End presentation.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil])
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Nothing new emits when the view is done.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Nothing new emits when the view is done."
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      // Simulate a new version of the project coming through
      self.vm.inputs.configureWith(value: (project, .discovery))

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true, true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil, nil])
      self.loadProjectIntoDataSourceProject.assertValues(
        [project, project], "The new project is loaded into data source"
      )
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery, .discovery], "The new refTag is loaded into data source"
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      self.scheduler.advance()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues(
        [true, true, false], "isLoading is false"
      )
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues(
        [nil, nil, nil], "nil is returned for control group"
      )
      self.loadProjectIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery, .discovery, .discovery])
      self.loadMinimalProjectIntoDataSource.assertValues([])
    }
  }

  func testLoadProjectIntoDataSource_CreatorDetailsFailure() {
    let project = Project.template

    let mockService = MockService(fetchProjectCreatorDetailsResult: .failure(.invalidInput))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(value: (project, .discovery))
      self.vm.inputs.viewDidLoad()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

      // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
      // navigator controller.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true], "Starts loading.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil], "Emits nil as view appears")
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Load the full project into the data source.")
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery], "Load the refTag into the data source.")
      self.loadMinimalProjectIntoDataSource.assertValues(
        [], "Do not load the minimal version of the project."
      )

      // End presentation.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil])
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Nothing new emits when the view is done.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Nothing new emits when the view is done."
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      // Simulate a new version of the project coming through
      self.vm.inputs.configureWith(value: (project, .discovery))

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true, true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil, nil])
      self.loadProjectIntoDataSourceProject.assertValues(
        [project, project], "The new project is loaded into data source"
      )
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery, .discovery], "The new refTag is loaded into data source"
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      self.scheduler.advance()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues(
        [true, true, false], "isLoading is false"
      )
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues(
        [nil, nil, nil], "nil is returned"
      )
      self.loadProjectIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery, .discovery, .discovery])
      self.loadMinimalProjectIntoDataSource.assertValues([])
    }
  }

  func testLoadProjectIntoDataSource_CreatorDetailsFailure_ExperimentalVariant() {
    let project = Project.template

    let mockService = MockService(fetchProjectCreatorDetailsResult: .failure(.invalidInput))

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectPageConversionCreatorDetails.rawValue: OptimizelyExperiment
          .Variant.variant1.rawValue
      ]

    withEnvironment(apiService: mockService, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, .discovery))
      self.vm.inputs.viewDidLoad()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

      // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
      // navigator controller.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true], "Starts loading.")
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil], "Emits nil as view appears")
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Load the full project into the data source.")
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery], "Load the refTag into the data source.")
      self.loadMinimalProjectIntoDataSource.assertValues(
        [], "Do not load the minimal version of the project."
      )

      // End presentation.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil])
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Nothing new emits when the view is done.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Nothing new emits when the view is done."
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      // Simulate a new version of the project coming through
      self.vm.inputs.configureWith(value: (project, .discovery))

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues([true, true])
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues([nil, nil])
      self.loadProjectIntoDataSourceProject.assertValues(
        [project, project], "The new project is loaded into data source"
      )
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery, .discovery], "The new refTag is loaded into data source"
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      self.scheduler.advance()

      self.loadProjectIntoDataSourceCreatorDetailsIsLoading.assertValues(
        [true, true, false], "isLoading is false"
      )
      self.loadProjectIntoDataSourceCreatorDetailsEnvelope.assertValues(
        [nil, nil, nil], "nil is returned"
      )
      self.loadProjectIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery, .discovery, .discovery])
      self.loadMinimalProjectIntoDataSource.assertValues([])
    }
  }

  func testLoadProjectIntoDataSource_ProjectSummaryLoaded_ExperimentalVariant() {
    let project = Project.template

    let envelope = ProjectSummaryEnvelope(projectSummary: [
      .init(question: .whatIsTheProject, response: "response-1"),
      .init(question: .whatWillYouDoWithTheMoney, response: "response-2"),
      .init(question: .whoAreYou, response: "response-3")
    ])

    let mockService = MockService(fetchProjectSummaryResult: .success(envelope))

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeMeProjectSummary.rawValue: OptimizelyExperiment.Variant.variant1
          .rawValue
      ]

    withEnvironment(apiService: mockService, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, .discovery))
      self.vm.inputs.viewDidLoad()

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

      // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
      // navigator controller.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[]], "Emits [] as view appears")
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Load the full project into the data source.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Load the refTag into the data source."
      )
      self.loadMinimalProjectIntoDataSource.assertValues(
        [], "Do not load the minimal version of the project."
      )

      // End presentation.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[]])
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Nothing new emits when the view is done.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Nothing new emits when the view is done."
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      // Simulate a new version of the project coming through
      self.vm.inputs.configureWith(value: (project, .discovery))

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[], []])
      self.loadProjectIntoDataSourceProject.assertValues(
        [project, project], "The new project is loaded into data source"
      )
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery, .discovery], "The new refTag is loaded into data source"
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      self.scheduler.advance()

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues(
        [[], [], envelope.projectSummary], "ProjectSummaryEnvelope is returned"
      )
      self.loadProjectIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery, .discovery, .discovery])
      self.loadMinimalProjectIntoDataSource.assertValues([])
    }
  }

  func testLoadProjectIntoDataSource_ProjectSummaryLoaded_Control() {
    let project = Project.template

    let envelope = ProjectSummaryEnvelope(projectSummary: [
      .init(question: .whatIsTheProject, response: "response-1"),
      .init(question: .whatWillYouDoWithTheMoney, response: "response-2"),
      .init(question: .whoAreYou, response: "response-3")
    ])

    let mockService = MockService(fetchProjectSummaryResult: .success(envelope))

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeMeProjectSummary.rawValue: OptimizelyExperiment.Variant.control
          .rawValue
      ]

    withEnvironment(apiService: mockService, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, .discovery))
      self.vm.inputs.viewDidLoad()

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

      // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
      // navigator controller.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[]], "Emits [] as view appears")
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Load the full project into the data source.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Load the refTag into the data source."
      )
      self.loadMinimalProjectIntoDataSource.assertValues(
        [], "Do not load the minimal version of the project."
      )

      // End presentation.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[]])
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Nothing new emits when the view is done.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Nothing new emits when the view is done."
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      // Simulate a new version of the project coming through
      self.vm.inputs.configureWith(value: (project, .discovery))

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[], []])
      self.loadProjectIntoDataSourceProject.assertValues(
        [project, project], "The new project is loaded into data source"
      )
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery, .discovery], "The new refTag is loaded into data source"
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      self.scheduler.advance()

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues(
        [[], [], []], "[] is returned"
      )
      self.loadProjectIntoDataSourceProject.assertValues([project, project, project])
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery, .discovery, .discovery])
      self.loadMinimalProjectIntoDataSource.assertValues([])
    }
  }

  func testLoadProjectIntoDataSource_ProjectSummaryFailure_ExperimentalVariant() {
    let project = Project.template

    let mockService = MockService(fetchProjectSummaryResult: .failure(.invalidInput))

    let optimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeMeProjectSummary.rawValue: OptimizelyExperiment.Variant.variant1
          .rawValue
      ]

    withEnvironment(apiService: mockService, optimizelyClient: optimizelyClient) {
      self.vm.inputs.configureWith(value: (project, .discovery))
      self.vm.inputs.viewDidLoad()

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceProject.assertValues([], "Nothing emits immediately.")
      self.loadProjectIntoDataSourceRefTag.assertValues([], "Nothing emits immediately.")
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing emits immediately.")

      // Begin presentation. When presenting the project `animated` will be false since it is embedded in the
      // navigator controller.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[]], "Emits [] as view appears")
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Load the full project into the data source.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Load the refTag into the data source."
      )
      self.loadMinimalProjectIntoDataSource.assertValues(
        [], "Do not load the minimal version of the project."
      )

      // End presentation.
      self.vm.inputs.viewWillAppear(animated: false)
      self.vm.inputs.viewDidAppear(animated: false)

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[]])
      self.loadProjectIntoDataSourceProject
        .assertValues([project], "Nothing new emits when the view is done.")
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery], "Nothing new emits when the view is done."
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      // Simulate a new version of the project coming through
      self.vm.inputs.configureWith(value: (project, .discovery))

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues([[], []])
      self.loadProjectIntoDataSourceProject.assertValues(
        [project, project], "The new project is loaded into data source"
      )
      self.loadProjectIntoDataSourceRefTag.assertValues(
        [.discovery, .discovery], "The new refTag is loaded into data source"
      )
      self.loadMinimalProjectIntoDataSource.assertValues([], "Nothing new emits when the view is done.")

      self.scheduler.advance()

      self.loadProjectIntoDataSourceProjectSummaryItems.assertValues(
        [[], []], "Nothing new is emitted, no need to reload."
      )
      self.loadProjectIntoDataSourceProject.assertValues([project, project])
      self.loadProjectIntoDataSourceRefTag.assertValues([.discovery, .discovery])
      self.loadMinimalProjectIntoDataSource.assertValues([])
    }
  }
}
