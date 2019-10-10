import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ManagePledgeSummaryViewModelTests: TestCase {
  private let vm = ManagePledgeSummaryViewModel()

  private let backerNumberText = TestObserver<String, Never>()
  private let backingDateText = TestObserver<String, Never>()
  private let totalAmountText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.backerNumberText.observe(self.backerNumberText.observer)
    self.vm.outputs.backingDateText.observe(self.backingDateText.observer)
    self.vm.outputs.totalAmountText.map { $0.string }
      .observe(self.totalAmountText.observer)
  }

  func testTextOutputsEmitTheCorrectValue() {
    let backing = .template
      |> Backing.lens.sequence .~ 999
      |> Backing.lens.pledgedAt .~ 1_568_666_243
      |> Backing.lens.amount .~ 30
      |> Backing.lens.shippingAmount .~ 7

    let project = Project.template
      |> \.personalization.isBacking .~ true
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.backerNumberText.assertValue("Backer #999")
    self.backingDateText.assertValue("As of September 16, 2019")
    self.totalAmountText.assertValue("$30.00")
  }
}
