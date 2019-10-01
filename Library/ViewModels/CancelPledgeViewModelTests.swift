import Foundation
@testable import Library
@testable import KsApi
import Prelude
import XCTest
import ReactiveExtensions_TestHelpers

final class CancelPledgeViewModelTests: TestCase {
  private let vm: CancelPledgeViewModelType = CancelPledgeViewModel()

  private let cancellationDetailsTextLabelAmount = TestObserver<String, Never>()
  private let cancellationDetailsTextLabelProjectName = TestObserver<String, Never>()
  private let popCancelPledgeViewController = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cancellationDetailsTextLabelValue.map(first)
      .observe(self.cancellationDetailsTextLabelAmount.observer)
    self.vm.outputs.cancellationDetailsTextLabelValue.map(second)
      .observe(self.cancellationDetailsTextLabelProjectName.observer)
    self.vm.outputs.popCancelPledgeViewController.observe(self.popCancelPledgeViewController.observer)
  }

  func testConfigureCancelPledgeView() {
    let backing = Backing.template
      |> Backing.lens.amount .~ 5
    let project = Project.cosmicSurgery
      |> Project.lens.country .~ Project.Country.us

    self.vm.inputs.configure(with: project, backing: backing)
    self.vm.inputs.viewDidLoad()

    self.cancellationDetailsTextLabelAmount.assertValues(["$5"])
    self.cancellationDetailsTextLabelProjectName.assertValues(["Cosmic Surgery"])
  }

  func testGoBackButtonTapped() {
    self.vm.inputs.configure(with: Project.template, backing: Backing.template)

    self.popCancelPledgeViewController.assertDidNotEmitValue()

    self.vm.inputs.goBackButtonTapped()

    self.popCancelPledgeViewController.assertValueCount(1)
  }
}
