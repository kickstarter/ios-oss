// swiftlint:disable force_unwrapping
import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

typealias ProjectMessageThread = (Project, MessageThread)

func == (lhs: ProjectMessageThread, rhs: ProjectMessageThread) -> Bool {
  return lhs.0 == rhs.0 && lhs.1 == rhs.1
}

internal final class DashboardViewModelTests: TestCase {
  internal let vm: DashboardViewModelType = DashboardViewModel()
  internal let fundingStats = TestObserver<[ProjectStatsEnvelope.FundingDateStats], NoError>()
  internal let project = TestObserver<Project, NoError>()
  internal let referrerCumulativeStats = TestObserver<ProjectStatsEnvelope.CumulativeStats, NoError>()
  internal let referrerStats = TestObserver<[ProjectStatsEnvelope.ReferrerStats], NoError>()
  internal let rewardStats = TestObserver<[ProjectStatsEnvelope.RewardStats], NoError>()
  internal let videoStats = TestObserver<ProjectStatsEnvelope.VideoStats, NoError>()
  internal let animateOutProjectsDrawer = TestObserver<(), NoError>()
  internal let dismissProjectsDrawer = TestObserver<(), NoError>()
  internal let presentProjectsDrawer = TestObserver<[ProjectsDrawerData], NoError>()
  internal let updateTitleViewData = TestObserver<DashboardTitleViewData, NoError>()
  internal let focusScreenReaderOnTitleView = TestObserver<(), NoError>()
  internal let goToMessageThread = TestObserver<Project, NoError>()

  let project1 = Project.template
  let project2 = .template |> Project.lens.id .~ 4

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.fundingData.map { stats, _ in stats }.observe(self.fundingStats.observer)
    self.vm.outputs.project.observe(self.project.observer)
    self.vm.outputs.referrerData
      .map { cumulative, _, _ in cumulative }
      .observe(self.referrerCumulativeStats.observer)
    self.vm.outputs.referrerData.map { _, _, stats in stats }.observe(self.referrerStats.observer)
    self.vm.outputs.rewardData.map { stats, _ in stats }.observe(self.rewardStats.observer)
    self.vm.outputs.videoStats.observe(self.videoStats.observer)
    self.vm.outputs.dismissProjectsDrawer.observe(self.dismissProjectsDrawer.observer)
    self.vm.outputs.presentProjectsDrawer.observe(self.presentProjectsDrawer.observer)
    self.vm.outputs.animateOutProjectsDrawer.observe(self.animateOutProjectsDrawer.observer)
    self.vm.outputs.updateTitleViewData.observe(self.updateTitleViewData.observer)
    self.vm.outputs.focusScreenReaderOnTitleView.observe(self.focusScreenReaderOnTitleView.observer)
    self.vm.outputs.goToMessageThread.map { $0.0 }.observe(self.goToMessageThread.observer)
  }

  func testDashboardTracking() {
    let project1 = .template |> Project.lens.id .~ 0
    let project2 = .template |> Project.lens.id .~ 1
    let projects = [project1, project2]

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      self.vm.inputs.viewWillAppear(animated: false)

      self.project.assertValueCount(0)
      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance()

      // View tracks on first appearance
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View"], self.trackingClient.events)
      XCTAssertEqual([0, 0], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.viewWillAppear(animated: true)
      self.scheduler.advance()

      // View doesn't track on appearing animated
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View"], self.trackingClient.events)
      XCTAssertEqual([0, 0], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      // View tracks on unanimated appearance
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.showHideProjectsDrawer()

      // Showed project switcher
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.`switch`(toProject: .id(project2.id))

      // Switched project. Don't track Dash view or closed switcher.
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate"],
                     self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.viewWillAppear(animated: true)

      // Don't track Dashboard View on animated viewing
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate"],
                     self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      // Track new project next time view appears unanimated
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      // Track View next time view appears unanimated
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard", "Dashboard View"],
                     self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.showHideProjectsDrawer()

      // Showed project switcher.
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard", "Dashboard View",
        "Showed Project Switcher"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.showHideProjectsDrawer()

      // Closed project switcher.
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard", "Dashboard View",
        "Showed Project Switcher", "Closed Project Switcher"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.showHideProjectsDrawer()

      // Showed project switcher.
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard", "Dashboard View",
        "Showed Project Switcher", "Closed Project Switcher", "Showed Project Switcher"],
                     self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.showHideProjectsDrawer()

      // Closed project switcher.
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard", "Dashboard View",
        "Showed Project Switcher", "Closed Project Switcher", "Showed Project Switcher",
        "Closed Project Switcher"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      // Showed project switcher.
      self.vm.inputs.showHideProjectsDrawer()

      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard", "Dashboard View",
        "Showed Project Switcher", "Closed Project Switcher", "Showed Project Switcher",
        "Closed Project Switcher", "Showed Project Switcher"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.`switch`(toProject: .id(project1.id))

      // Switch projects.
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard",
        "Dashboard View", "Showed Project Switcher", "Switched Projects", "Creator Project Navigate",
        "Viewed Project Dashboard", "Dashboard View", "Viewed Project Dashboard", "Dashboard View",
        "Showed Project Switcher", "Closed Project Switcher", "Showed Project Switcher",
        "Closed Project Switcher", "Showed Project Switcher", "Switched Projects",
        "Creator Project Navigate"], self.trackingClient.events)
      XCTAssertEqual([0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))
    }
  }

  func testScreenReaderFocus() {
    let projects = [Project.template]

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      self.focusScreenReaderOnTitleView.assertValueCount(0)

      self.vm.inputs.viewWillAppear(animated: false)

      self.focusScreenReaderOnTitleView.assertValueCount(1)

      self.vm.inputs.viewWillAppear(animated: false)

      self.focusScreenReaderOnTitleView.assertValueCount(2)
    }
  }

  func testProject() {
    let projects = (0...4).map { .template |> Project.lens.id .~ $0 }
    let titleViewData = DashboardTitleViewData(drawerState: DrawerState.closed,
                                               isArrowHidden: false,
                                               currentProjectIndex: 0)

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      self.vm.inputs.viewWillAppear(animated: false)

      self.project.assertValueCount(0)
      self.updateTitleViewData.assertValueCount(0)
      XCTAssertEqual([], self.trackingClient.events)

      self.scheduler.advance()

      self.project.assertValues([.template |> Project.lens.id .~ 0])
      self.updateTitleViewData.assertValues([titleViewData], "Update title data")
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View"], self.trackingClient.events)
      XCTAssertEqual([0, 0], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.fundingStats.assertValueCount(1)

      let updatedProjects = (0...4).map {
        .template
          |> Project.lens.id .~ $0
          |> Project.lens.name %~ { $0 + " (updated)" }
      }

      withEnvironment(apiService: MockService(fetchProjectsResponse: updatedProjects)) {
        self.vm.inputs.viewWillAppear(animated: false)
        self.scheduler.advance()

        self.project.assertValueCount(2)
        XCTAssertEqual("\(projects[0].name) (updated)", self.project.values.last!.name)

        self.fundingStats.assertValueCount(2)
      }
    }
  }

  func testTitleData_ForOneProject() {
    let projects = [Project.template]
    let titleViewData = DashboardTitleViewData(drawerState: DrawerState.closed,
                                               isArrowHidden: true,
                                               currentProjectIndex: 0)

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      self.vm.inputs.viewWillAppear(animated: false)

      self.updateTitleViewData.assertValueCount(0)

      self.scheduler.advance()

      self.updateTitleViewData.assertValues([titleViewData], "Update title data")
    }
  }

  func testProjectStatsEmit() {
    let projects = [Project.template]
    let projects2 = projects + [.template |> Project.lens.id .~ 5]

    let statsEnvelope = .template
      |> ProjectStatsEnvelope.lens.cumulativeStats .~ .template
      |> ProjectStatsEnvelope.lens.fundingDistribution .~ [.template]
      |> ProjectStatsEnvelope.lens.referralDistribution .~ [.template]
      |> ProjectStatsEnvelope.lens.rewardDistribution .~ [.template, .template]
      |> ProjectStatsEnvelope.lens.videoStats .~ .template

    let statsEnvelope2 = .template
      |> ProjectStatsEnvelope.lens.cumulativeStats .~ .template
      |> ProjectStatsEnvelope.lens.fundingDistribution .~ [.template]
      |> ProjectStatsEnvelope.lens.referralDistribution .~ [.template, .template, .template]
      |> ProjectStatsEnvelope.lens.rewardDistribution .~ [.template]
      |> ProjectStatsEnvelope.lens.videoStats .~ nil

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects,
      fetchProjectStatsResponse: statsEnvelope)) {
      self.vm.inputs.viewWillAppear(animated: false)

      self.videoStats.assertValueCount(0)
      self.fundingStats.assertValueCount(0)
      self.referrerCumulativeStats.assertValueCount(0)
      self.referrerStats.assertValueCount(0)
      self.rewardStats.assertValueCount(0)

      self.scheduler.advance()

      self.fundingStats.assertValues([[.template]], "Funding stats emitted.")
      self.referrerCumulativeStats.assertValues([.template], "Cumulative stats emitted.")
      self.referrerStats.assertValues([[.template]], "Referrer stats emitted.")
      self.rewardStats.assertValues([[.template, .template]], "Reward stats emitted.")
      self.videoStats.assertValues([.template], "Video stats emitted.")

      withEnvironment(apiService: MockService(fetchProjectsResponse: projects2,
        fetchProjectStatsResponse: statsEnvelope2)) {
        self.vm.inputs.viewWillAppear(animated: false)
        self.scheduler.advance()

        self.fundingStats.assertValues([[.template], [.template]], "Funding stats emitted.")
        self.referrerCumulativeStats.assertValues([.template, .template], "Cumulative stats emitted.")
        self.referrerStats.assertValues([[.template], [.template, .template, .template]],
                                        "Referrer stats emitted.")
        self.rewardStats.assertValues([[.template, .template], [.template]], "Reward stats emitted.")
        self.videoStats.assertValues([.template], "Video stats does not emit")
      }
    }
  }

  func testDeepLink() {
    let projects = (0...4).map { .template |> Project.lens.id .~ $0 }

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      self.vm.inputs.`switch`(toProject: .id(projects.last!.id))
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      self.project.assertValues([projects.last!])
    }
  }

  func testGoToThread() {
    let projects = (0...4).map { .template |> Project.lens.id .~ $0 }
    let thread = MessageThread.template

    let firstProject = projects[0]
    let threadProj = projects[1]

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      self.project.assertValues([])

      self.vm.inputs.messageThreadNavigated(projectId: .id(threadProj.id), messageThread: thread)
      self.project.assertValues([])

      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      self.goToMessageThread.assertValues([threadProj], "Go to message thread emitted")
      self.project.assertValues([firstProject, threadProj], "Thread project is selected")

      self.vm.inputs.viewWillDisappear()
      self.scheduler.advance()

      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      self.goToMessageThread.assertValues([threadProj],
                                          "Go to message thread not emitted again when view appears")

      self.project.assertValues([firstProject, threadProj, firstProject, threadProj], "Keep previeiosly selected project when view Appers")

    }
  }

  func testProjectsDrawer_OpenClose() {
    let project1 = Project.template
    let project2 = .template |> Project.lens.id .~ 4
    let projects = [project1, project2]
    let projectData1 = ProjectsDrawerData(project: project1, indexNum: 0, isChecked: true)
    let projectData2 = ProjectsDrawerData(project: project2, indexNum: 1, isChecked: false)

    let titleViewDataClosed1 = DashboardTitleViewData(drawerState: DrawerState.closed,
                                                      isArrowHidden: false,
                                                      currentProjectIndex: 0)

    let titleViewDataOpen1 = DashboardTitleViewData(drawerState: DrawerState.open,
                                                    isArrowHidden: false,
                                                    currentProjectIndex: 0)

    let titleViewDataClosed2 = DashboardTitleViewData(drawerState: DrawerState.closed,
                                                      isArrowHidden: false,
                                                      currentProjectIndex: 1)

    let titleViewDataOpen2 = DashboardTitleViewData(drawerState: DrawerState.open,
                                                    isArrowHidden: false,
                                                    currentProjectIndex: 1)

    withEnvironment(apiService: MockService(fetchProjectsResponse: projects)) {
      self.vm.inputs.viewWillAppear(animated: false)
      self.scheduler.advance()

      self.updateTitleViewData.assertValues([titleViewDataClosed1], "Update title with closed data")

      self.vm.inputs.showHideProjectsDrawer()

      self.updateTitleViewData.assertValues([titleViewDataClosed1, titleViewDataOpen1],
        "Update title with open data")
      self.presentProjectsDrawer.assertValues([[projectData1, projectData2]])
      self.dismissProjectsDrawer.assertValueCount(0)
      self.animateOutProjectsDrawer.assertValueCount(0)
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Showed Project Switcher"],
                     self.trackingClient.events)
      XCTAssertEqual([1, 1, 1], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.showHideProjectsDrawer()

      self.updateTitleViewData.assertValues([titleViewDataClosed1, titleViewDataOpen1, titleViewDataClosed1],
        "Update title with closed data")
      self.animateOutProjectsDrawer.assertValueCount(1)
      self.dismissProjectsDrawer.assertValueCount(0)
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Showed Project Switcher",
        "Closed Project Switcher"],
                     self.trackingClient.events)
      XCTAssertEqual([1, 1, 1, 1], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.dashboardProjectsDrawerDidAnimateOut()

      self.dismissProjectsDrawer.assertValueCount(1)

      self.vm.inputs.showHideProjectsDrawer()

      self.updateTitleViewData.assertValues([titleViewDataClosed1, titleViewDataOpen1, titleViewDataClosed1,
        titleViewDataOpen1], "Update title with open data")
      self.presentProjectsDrawer.assertValues([[projectData1, projectData2], [projectData1, projectData2]])
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Showed Project Switcher",
        "Closed Project Switcher", "Showed Project Switcher"], self.trackingClient.events)
      XCTAssertEqual([1, 1, 1, 1, 1], self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.`switch`(toProject: .id(project2.id))

      self.updateTitleViewData.assertValues([titleViewDataClosed1, titleViewDataOpen1, titleViewDataClosed1,
        titleViewDataOpen1, titleViewDataClosed2], "Update title with closed data")
      self.animateOutProjectsDrawer.assertValueCount(2, "Animate out drawer emits")
      self.dismissProjectsDrawer.assertValueCount(1, "Dismiss drawer does not emit")
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Showed Project Switcher",
        "Closed Project Switcher", "Showed Project Switcher", "Switched Projects",
        "Creator Project Navigate"], self.trackingClient.events)
      XCTAssertEqual([1, 1, 1, 1, 1, 4, 4],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.dashboardProjectsDrawerDidAnimateOut()

      self.dismissProjectsDrawer.assertValueCount(2)

      self.vm.inputs.showHideProjectsDrawer()

      self.updateTitleViewData.assertValues([titleViewDataClosed1, titleViewDataOpen1, titleViewDataClosed1,
        titleViewDataOpen1, titleViewDataClosed2, titleViewDataOpen2], "Update title with open data")
      self.presentProjectsDrawer.assertValues([[projectData1, projectData2], [projectData1, projectData2],
        [projectData1, projectData2]])
      self.animateOutProjectsDrawer.assertValueCount(2, "Animate out drawer emits")
      self.dismissProjectsDrawer.assertValueCount(2, "Dismiss drawer does not emit")
      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Showed Project Switcher",
        "Closed Project Switcher", "Showed Project Switcher", "Switched Projects",
        "Creator Project Navigate", "Showed Project Switcher"], self.trackingClient.events)
      XCTAssertEqual([1, 1, 1, 1, 1, 4, 4, 4],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))

      self.vm.inputs.showHideProjectsDrawer()

      XCTAssertEqual(["Viewed Project Dashboard", "Dashboard View", "Showed Project Switcher",
        "Closed Project Switcher", "Showed Project Switcher", "Switched Projects",
        "Creator Project Navigate", "Showed Project Switcher", "Closed Project Switcher"],
                     self.trackingClient.events)
      XCTAssertEqual([1, 1, 1, 1, 1, 4, 4, 4, 4],
                     self.trackingClient.properties(forKey: "project_pid", as: Int.self))
    }
  }

}
