import XCTest
import Result
import ReactiveCocoa
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardProjectsDrawerViewModelTests: TestCase {
  internal let vm: DashboardProjectsDrawerViewModelType = DashboardProjectsDrawerViewModel()

  let projectsDrawerData = TestObserver<[ProjectsDrawerData], NoError>()
  let notifyDelegateToCloseDrawer = TestObserver<(), NoError>()
  let notifyDelegateDidAnimateOut = TestObserver<(), NoError>()
  let notifyDelegateProjectCellTapped = TestObserver<Project, NoError>()
  let focusScreenReaderOnFirstProject = TestObserver<(), NoError>()

  let project1 = .template |> Project.lens.id .~ 4
  let project2 = .template |> Project.lens.id .~ 6
  let data1 = [ProjectsDrawerData(project: .template |> Project.lens.id .~ 4, indexNum: 0, isChecked: true)]
  let data2 = [
    ProjectsDrawerData(
      project: .template |> Project.lens.id .~ 4,
      indexNum: 0,
      isChecked: true),
    ProjectsDrawerData(
      project: .template |> Project.lens.id .~ 6,
      indexNum: 1,
      isChecked: false)
  ]

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.projectsDrawerData.observe(self.projectsDrawerData.observer)
    self.vm.outputs.notifyDelegateToCloseDrawer.observe(self.notifyDelegateToCloseDrawer.observer)
    self.vm.outputs.notifyDelegateDidAnimateOut.observe(self.notifyDelegateDidAnimateOut.observer)
    self.vm.outputs.notifyDelegateProjectCellTapped.observe(self.notifyDelegateProjectCellTapped.observer)
    self.vm.outputs.focusScreenReaderOnFirstProject.observe(self.focusScreenReaderOnFirstProject.observer)
  }

  func testConfigureWith() {
    self.vm.inputs.configureWith(data: data1)

    self.projectsDrawerData.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.projectsDrawerData.assertValues([data1])

    self.vm.inputs.configureWith(data: data2)

    self.projectsDrawerData.assertValueCount(1)

    self.vm.inputs.viewDidLoad()

    self.projectsDrawerData.assertValues([data1, data2])
  }

  func testProjectTapped() {
    self.vm.inputs.configureWith(data: data1)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateProjectCellTapped.assertValueCount(0)

    self.vm.inputs.projectCellTapped(project1)

    self.notifyDelegateProjectCellTapped.assertValues([project1])
  }

  func testAnimateOut_OnBackgroundTapped() {
    self.vm.inputs.configureWith(data: data1)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.animateInCompleted()

    self.notifyDelegateToCloseDrawer.assertValueCount(0)

    self.vm.inputs.backgroundTapped()

    self.notifyDelegateToCloseDrawer.assertValueCount(1)
    self.notifyDelegateDidAnimateOut.assertValueCount(0)

    self.vm.inputs.animateOutCompleted()

    self.notifyDelegateToCloseDrawer.assertValueCount(1, "Drawer close does not emit")
    self.notifyDelegateDidAnimateOut.assertValueCount(1, "Notify delegate animate out complete emits")
  }

  func testAnimateIn_FocusOnFirstProject() {
    self.vm.inputs.configureWith(data: data1)
    self.vm.inputs.viewDidLoad()

    self.focusScreenReaderOnFirstProject.assertValueCount(0)

    self.vm.inputs.animateInCompleted()

    self.focusScreenReaderOnFirstProject.assertValueCount(1)
  }
}
