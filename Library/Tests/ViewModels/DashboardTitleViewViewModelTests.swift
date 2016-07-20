import XCTest
import Result
import ReactiveCocoa
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardTitleViewViewModelTests: TestCase {
  internal let vm: DashboardTitleViewViewModelType = DashboardTitleViewViewModel()

  let hideArrow = TestObserver<Bool, NoError>()
  let notifyDelegateShowHideProjectsDrawer = TestObserver<(), NoError>()
  let titleText = TestObserver<String, NoError>()
  let titleButtonIsEnabled = TestObserver<Bool, NoError>()
  let updateArrowState = TestObserver<DrawerState, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.hideArrow.observe(hideArrow.observer)
    self.vm.outputs.notifyDelegateShowHideProjectsDrawer
      .observe(notifyDelegateShowHideProjectsDrawer.observer)
    self.vm.outputs.titleText.observe(titleText.observer)
    self.vm.outputs.titleButtonIsEnabled.observe(titleButtonIsEnabled.observer)
    self.vm.outputs.updateArrowState.observe(updateArrowState.observer)
  }

  func testTitleText() {
    withEnvironment(apiService: MockService(fetchProjectsResponse: [.template])) {
      self.titleText.assertValueCount(0)

      self.vm.inputs.updateData(DashboardTitleViewData(drawerState: .closed, isArrowHidden: true,
        currentProjectIndex: 0))

      self.titleText.assertValues(["Project #1"])
    }
  }

  func testDrawerState_OneProject() {
    self.hideArrow.assertValueCount(0)
    self.titleButtonIsEnabled.assertValueCount(0)

    self.vm.inputs.updateData(DashboardTitleViewData(drawerState: .closed, isArrowHidden: true,
      currentProjectIndex: 0))

    self.hideArrow.assertValues([true])
    self.titleButtonIsEnabled.assertValues([false])
    self.updateArrowState.assertValueCount(0)
    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(0)
  }

  func testDrawerState_MultipleProjects() {
    self.hideArrow.assertValueCount(0)
    self.titleButtonIsEnabled.assertValueCount(0)
    self.updateArrowState.assertValueCount(0)

    self.vm.inputs.updateData(DashboardTitleViewData(drawerState: .closed, isArrowHidden: false,
      currentProjectIndex: 0))

    self.hideArrow.assertValues([false])
    self.titleButtonIsEnabled.assertValues([true])
    self.updateArrowState.assertValues([DrawerState.closed])
    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(0)

    self.vm.inputs.titleTapped()

    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(1)

    self.vm.inputs.updateData(DashboardTitleViewData(drawerState: .open, isArrowHidden: false,
      currentProjectIndex: 0))

    self.titleText.assertValues(["Project #1", "Project #1"])
    self.updateArrowState.assertValues([DrawerState.closed, DrawerState.open])

    self.vm.inputs.titleTapped()

    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(2)

    self.vm.inputs.updateData(DashboardTitleViewData(drawerState: .closed, isArrowHidden: false,
      currentProjectIndex: 0))

    self.titleText.assertValues(["Project #1", "Project #1", "Project #1"])
    self.updateArrowState.assertValues([DrawerState.closed, DrawerState.open, DrawerState.closed])

    self.vm.inputs.titleTapped()

    self.notifyDelegateShowHideProjectsDrawer.assertValueCount(3)

    self.vm.inputs.updateData(DashboardTitleViewData(drawerState: .open, isArrowHidden: false,
      currentProjectIndex: 0))

    self.titleText.assertValues(["Project #1", "Project #1", "Project #1", "Project #1"])
    self.updateArrowState.assertValues([DrawerState.closed, DrawerState.open, DrawerState.closed,
      DrawerState.open])

    self.vm.inputs.updateData(DashboardTitleViewData(drawerState: .closed, isArrowHidden: false,
      currentProjectIndex: 2))

    self.titleText.assertValues(["Project #1", "Project #1", "Project #1", "Project #1", "Project #3"])
    self.updateArrowState.assertValues([DrawerState.closed, DrawerState.open, DrawerState.closed,
      DrawerState.open, DrawerState.closed])
  }
}
