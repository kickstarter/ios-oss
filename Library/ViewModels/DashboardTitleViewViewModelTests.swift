@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class DashboardTitleViewViewModelTests: TestCase {
  internal let vm: DashboardTitleViewViewModelType = DashboardTitleViewViewModel()

  let hideArrow = TestObserver<Bool, Never>()
  let notifyDelegateShowHideProjectsDrawer = TestObserver<(), Never>()
  let titleText = TestObserver<String, Never>()
  let titleButtonIsEnabled = TestObserver<Bool, Never>()
  let updateArrowState = TestObserver<DrawerState, Never>()
  let titleAccessibilityLabel = TestObserver<String, Never>()
  let titleAccessibilityHint = TestObserver<String, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.hideArrow.observe(self.hideArrow.observer)
    self.vm.outputs.notifyDelegateShowHideProjectsDrawer
      .observe(self.notifyDelegateShowHideProjectsDrawer.observer)
    self.vm.outputs.titleText.observe(self.titleText.observer)
    self.vm.outputs.titleButtonIsEnabled.observe(self.titleButtonIsEnabled.observer)
    self.vm.outputs.updateArrowState.observe(self.updateArrowState.observer)
    self.vm.outputs.titleAccessibilityLabel.observe(self.titleAccessibilityLabel.observer)
    self.vm.outputs.titleAccessibilityHint.observe(self.titleAccessibilityHint.observer)
  }

  func testTitleText() {
    withEnvironment(apiService: MockService(fetchProjectsResponse: [.template])) {
      self.titleText.assertValueCount(0)

      self.vm.inputs.updateData(DashboardTitleViewData(
        drawerState: .closed, isArrowHidden: true,
        currentProjectIndex: 0
      ))

      self.titleText.assertValues(["Project #1"])
    }
  }

  func testDrawerState_OneProject() {
    self.hideArrow.assertValueCount(0)
    self.titleButtonIsEnabled.assertValueCount(0)

    self.vm.inputs.updateData(DashboardTitleViewData(
      drawerState: .closed, isArrowHidden: true,
      currentProjectIndex: 0
    ))

    self.hideArrow.assertValues([true])
    self.titleButtonIsEnabled.assertValues([false])
    self.updateArrowState.assertValueCount(0)
    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(0)
    self.titleAccessibilityLabel.assertValueCount(0)
    self.titleAccessibilityHint.assertValueCount(0)
  }

  func testDrawerState_MultipleProjects() {
    self.hideArrow.assertValueCount(0)
    self.titleButtonIsEnabled.assertValueCount(0)
    self.updateArrowState.assertValueCount(0)
    self.titleAccessibilityLabel.assertValueCount(0)
    self.titleAccessibilityHint.assertValueCount(0)

    self.vm.inputs.updateData(DashboardTitleViewData(
      drawerState: .closed, isArrowHidden: false,
      currentProjectIndex: 0
    ))

    self.hideArrow.assertValues([false])
    self.titleButtonIsEnabled.assertValues([true])
    self.updateArrowState.assertValues([DrawerState.closed])
    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(0)
    self.titleAccessibilityLabel.assertValues(["Dashboard, Project #1"])
    self.titleAccessibilityHint.assertValues(["Opens list of projects."])

    self.vm.inputs.titleButtonTapped()

    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(1)

    self.vm.inputs.updateData(DashboardTitleViewData(
      drawerState: .open, isArrowHidden: false,
      currentProjectIndex: 0
    ))

    self.titleText.assertValues(["Project #1", "Project #1"])
    self.updateArrowState.assertValues([DrawerState.closed, DrawerState.open])
    self.titleAccessibilityLabel.assertValues(["Dashboard, Project #1", "Dashboard, Project #1"])
    self.titleAccessibilityHint.assertValues(["Opens list of projects.", "Closes list of projects."])

    self.vm.inputs.titleButtonTapped()

    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(2)

    self.vm.inputs.updateData(DashboardTitleViewData(
      drawerState: .closed, isArrowHidden: false,
      currentProjectIndex: 0
    ))

    self.titleText.assertValues(["Project #1", "Project #1", "Project #1"])
    self.updateArrowState.assertValues([DrawerState.closed, DrawerState.open, DrawerState.closed])
    self.titleAccessibilityLabel.assertValues([
      "Dashboard, Project #1", "Dashboard, Project #1",
      "Dashboard, Project #1"
    ])
    self.titleAccessibilityHint.assertValues([
      "Opens list of projects.", "Closes list of projects.",
      "Opens list of projects."
    ])

    self.vm.inputs.titleButtonTapped()

    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(3)

    self.vm.inputs.updateData(DashboardTitleViewData(
      drawerState: .open, isArrowHidden: false,
      currentProjectIndex: 0
    ))

    self.titleText.assertValues(["Project #1", "Project #1", "Project #1", "Project #1"])
    self.updateArrowState.assertValues([
      DrawerState.closed, DrawerState.open, DrawerState.closed,
      DrawerState.open
    ])
    self.titleAccessibilityLabel.assertValues([
      "Dashboard, Project #1", "Dashboard, Project #1",
      "Dashboard, Project #1", "Dashboard, Project #1"
    ])
    self.titleAccessibilityHint.assertValues([
      "Opens list of projects.", "Closes list of projects.",
      "Opens list of projects.", "Closes list of projects."
    ])

    self.vm.inputs.updateData(DashboardTitleViewData(
      drawerState: .closed, isArrowHidden: false,
      currentProjectIndex: 2
    ))

    self.titleText.assertValues(["Project #1", "Project #1", "Project #1", "Project #1", "Project #3"])
    self.updateArrowState.assertValues([
      DrawerState.closed, DrawerState.open, DrawerState.closed,
      DrawerState.open, DrawerState.closed
    ])
    self.titleAccessibilityLabel.assertValues([
      "Dashboard, Project #1", "Dashboard, Project #1",
      "Dashboard, Project #1", "Dashboard, Project #1", "Dashboard, Project #3"
    ])
    self.titleAccessibilityHint.assertValues([
      "Opens list of projects.", "Closes list of projects.",
      "Opens list of projects.", "Closes list of projects.", "Opens list of projects."
    ])
  }
}
