import Foundation
import Prelude
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
  private let estimatedDelivery = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amountCurrencyAndDelivery.map { $0.0 }.observe(self.amount.observer)
    self.vm.outputs.amountCurrencyAndDelivery.map { $0.1 }.observe(self.currency.observer)
    self.vm.outputs.amountCurrencyAndDelivery.map { $0.2 }.observe(self.estimatedDelivery.observer)
  }

  func testAmountCurrencyAndEstimatedDeliveryDate() {
    let estimatedDelivery = 1468527587.32843

    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery

    self.vm.inputs.configureWith(project: project, reward: reward)
    self.vm.inputs.viewDidLoad()

    self.amount.assertValues([10])
    self.currency.assertValues(["$"])
    self.estimatedDelivery.assertValues(
      [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
    )
  }
}
