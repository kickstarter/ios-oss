import XCTest
import Result
import ReactiveSwift
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

  internal final class DashboardProjectsDrawerCellViewModelTests: TestCase {
  internal let vm: DashboardProjectsDrawerCellViewModelType = DashboardProjectsDrawerCellViewModel()

  let isCheckmarkHidden = TestObserver<Bool, NoError>()
  let projectNameText = TestObserver<String, NoError>()
  let projectNumberText = TestObserver<String, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.isCheckmarkHidden.observe(self.isCheckmarkHidden.observer)
    self.vm.outputs.projectNameText.observe(self.projectNameText.observer)
    self.vm.outputs.projectNumberText.observe(self.projectNumberText.observer)
  }

  func testConfigureWith() {
    let project = .template |> Project.lens.name .~ "Fart Patrol"
    let project2 = .template |> Project.lens.name .~ "Cat Detectives"

    self.isCheckmarkHidden.assertValueCount(0)
    self.projectNameText.assertValueCount(0)
    self.projectNumberText.assertValueCount(0)

    self.vm.inputs.configureWith(project: project, indexNum: 2, isChecked: true)

    self.isCheckmarkHidden.assertValues([false])
    self.projectNameText.assertValues(["Fart Patrol"])
    self.projectNumberText.assertValues(["Project #3"])

    self.vm.inputs.configureWith(project: project2, indexNum: 1, isChecked: false)

    self.isCheckmarkHidden.assertValues([false, true])
    self.projectNameText.assertValues(["Fart Patrol", "Cat Detectives"])
    self.projectNumberText.assertValues(["Project #3", "Project #2"])
  }
}
