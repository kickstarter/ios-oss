import Foundation
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest

@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let amount = TestObserver<Double, NoError>()
  private let currency = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountAndCurrency.map { $0.0 }.observe(self.amount.observer)
    self.vm.outputs.amountAndCurrency.map { $0.1 }.observe(self.currency.observer)
  }

  func testAmountAndCurrencyViewDidLoad() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.amount.assertValues([10])
    self.currency.assertValues(["$"])
  }
}
