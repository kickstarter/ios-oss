@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class ErroredBackingViewViewModelTests: TestCase {
  private let vm: ErroredBackingViewViewModelType = ErroredBackingViewViewModel()

  private let notifyDelegateManageButtonTapped = TestObserver<GraphBacking, Never>()
  private let projectName = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateManageButtonTapped.observe(self.notifyDelegateManageButtonTapped.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
  }

  func testNotifyDelegateManageButtonTapped_Emits_WhenButtonIsTapped() {
    let backing = GraphBacking.template

    self.vm.inputs.configure(with: backing)

    self.notifyDelegateManageButtonTapped.assertDidNotEmitValue()

    self.vm.inputs.manageButtonTapped()

    self.notifyDelegateManageButtonTapped.assertValue(backing)
  }

  func testErroredBackings() {
    let project = GraphBacking.Project.template
      |> \.name .~ "Awesome tabletop collection"

    let backing = GraphBacking.template
      |> \.project .~ project

    self.projectName.assertDidNotEmitValue()

    self.vm.inputs.configure(with: backing)

    self.projectName.assertValue("Awesome tabletop collection")
  }
}
