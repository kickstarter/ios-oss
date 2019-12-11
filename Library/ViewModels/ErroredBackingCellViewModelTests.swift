@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest


final class ErroredBackingCellViewModelTests: TestCase {

  private let vm: ErroredBackingCellViewModelType = ErroredBackingCellViewModel()

  private let projectName = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.projectName.observe(self.projectName.observer)
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
