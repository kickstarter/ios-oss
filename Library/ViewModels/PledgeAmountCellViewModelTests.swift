@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeAmountCellViewModelTests: TestCase {
  private let vm: PledgeAmountCellViewModelType = PledgeAmountCellViewModel()

  private let amount = TestObserver<String, Never>()
  private let currency = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amount.observe(self.amount.observer)
    self.vm.outputs.currency.observe(self.currency.observer)
  }

  func testAmountAndCurrency() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amount.assertValues(["10"])
    self.currency.assertValues(["$"])

    let project = Project.template
      |> Project.lens.country .~ .jp

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.amount.assertValues(["10", "200"])
    self.currency.assertValues(["$", "¥"])
  }
}
