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
  private let shippingLocation = TestObserver<String, NoError>()
  private let shippingAmount = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountCurrencyAndShipping.map { $0.0 }.observe(self.amount.observer)
    self.vm.outputs.amountCurrencyAndShipping.map { $0.1 }.observe(self.currency.observer)
    self.vm.outputs.amountCurrencyAndShipping.map { $0.2 }.map { $0.0 }
      .observe(self.shippingLocation.observer)
    self.vm.outputs.amountCurrencyAndShipping.map { $0.2 }.map { $0.1 }.skipNil().map { $0.string }
      .observe(self.shippingAmount.observer)
  }

  func testAmountCurrencyAndShipping() {
    let project = Project.template
    let reward = Reward.template

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.amount.assertValues([10])
    self.currency.assertValues(["$"])
    self.shippingLocation.assertValues(["Brooklyn"])
    self.shippingAmount.assertValues(["$7.50"])
  }
}
