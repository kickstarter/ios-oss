@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ProjectRisksDisclaimerCellViewModelTests: TestCase {
  let vm: ProjectRisksDisclaimerCellViewModelType = ProjectRisksDisclaimerCellViewModel()

  private let notifyDelegateDescriptionLabelTapped = TestObserver<URL, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.notifyDelegateDescriptionLabelTapped
      .observe(self.notifyDelegateDescriptionLabelTapped.observer)
  }

  func testOutput_NotifyDelegateDescriptionLabelTapped() {
    let url = HelpType.trust.url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl)!

    self.vm.inputs.descriptionLabelTapped(url: url)

    self.notifyDelegateDescriptionLabelTapped.assertValues([url])
  }
}
