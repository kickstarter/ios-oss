import XCTest
@testable import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
import Models
@testable import Models_TestHelpers
import ReactiveCocoa
import Result

final class ProjectMainCellViewModelTest: TestCase {
  let vm: ProjectMainCellViewModelType = ProjectMainCellViewModel()

  let projectName = TestObserver<String, NoError>()
  let stateHidden = TestObserver<Bool, NoError>()
  let progressHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.stateHidden.observe(self.stateHidden.observer)
    self.vm.outputs.progressHidden.observe(self.progressHidden.observer)
  }

  func testStateBannerAndProgress() {
    let liveProject = ProjectFactory.live()
    self.vm.inputs.project(liveProject)

    self.projectName.assertValues([liveProject.name])
    self.stateHidden.assertValues([true])
    self.progressHidden.assertValues([false])

    let successfulProject = ProjectFactory.successful
    self.vm.inputs.project(successfulProject)

    self.stateHidden.assertValues([true, false])
    self.progressHidden.assertValues([false, true])
  }
}
