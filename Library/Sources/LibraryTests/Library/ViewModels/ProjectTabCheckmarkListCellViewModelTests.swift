@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectTabCheckmarkListCellViewModelTests: TestCase {
  fileprivate let vm: ProjectTabCheckmarkListCellViewModelType =
    ProjectTabCheckmarkListCellViewModel()

  fileprivate let categoryLabelText = TestObserver<String, Never>()
  fileprivate let descriptionOptionsText = TestObserver<[String], Never>()

  private let fundingOptions = ProjectTabFundingOptions(
    fundingForAiAttribution: true,
    fundingForAiConsent: true,
    fundingForAiOption: true
  )

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.categoryLabelText.observe(self.categoryLabelText.observer)
    self.vm.outputs.descriptionOptionsText.observe(self.descriptionOptionsText.observer)
  }

  func testOutput_CategoryLabelText() {
    self.vm.inputs.configureWith(value: self.fundingOptions)

    self.categoryLabelText.assertValues(["My project seeks funding for AI technology."])
  }

  func testOutput_DescriptionLabelsText() {
    self.vm.inputs.configureWith(value: self.fundingOptions)

    self.descriptionOptionsText
      .assertValues([[
        "For the database or source that I will use or will create, the consent of the persons whose works or information are incorporated has been or will be obtained.",
        "The owners of these works are or will be receiving credit for their work.",
        "There is or will be an opt-in or opt-out for those owners."
      ]])
  }
}
