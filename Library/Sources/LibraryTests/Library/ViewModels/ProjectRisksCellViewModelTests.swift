@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ProjectRisksCellViewModelTests: TestCase {
  let vm: ProjectRisksCellViewModelType = ProjectRisksCellViewModel()

  private let descriptionLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
  }

  func testOutput_DescriptionLabelText() {
    self.vm.inputs.configureWith(value: "Hello World")

    self.descriptionLabelText.assertValues(["Hello World"])
  }
}
