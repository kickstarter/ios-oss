import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift
import Result
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let amount = TestObserver<Double, NoError>()
  private let currency = TestObserver<String, NoError>()
  private let estimatedDelivery = TestObserver<String, NoError>()
  private let shippingLocation = TestObserver<String, NoError>()
  private let shippingAmount = TestObserver<String, NoError>()
  private let isLoggedIn = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.map { $0.amount }.observe(self.amount.observer)
    self.vm.outputs.reloadWithData.map { $0.currency }.observe(self.currency.observer)
    self.vm.outputs.reloadWithData.map { $0.delivery }.observe(self.estimatedDelivery.observer)
    self.vm.outputs.reloadWithData.map { $0.shipping }.map { $0.location }
      .observe(self.shippingLocation.observer)
    self.vm.outputs.reloadWithData.map { $0.shipping }.map { $0.amount }.skipNil().map { $0.string }
      .observe(self.shippingAmount.observer)
    self.vm.outputs.reloadWithData.map { $0.isLoggedIn }.observe(self.isLoggedIn.observer)
  }

  func testReloadWithData_loggedOut() {
    let estimatedDelivery = 1_468_527_587.32843
    let project = Project.template
    let reward = Reward.template |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.amount.assertValues([10])
      self.currency.assertValues(["$"])
      self.estimatedDelivery.assertValues(
        [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
      )
      self.shippingLocation.assertValues(["Brooklyn"])
      self.shippingAmount.assertValues(["+$7.50"])
      self.isLoggedIn.assertValues([false])
    }
  }

  func testReloadWithData_loggedIn() {
    let estimatedDelivery = 1_468_527_587.32843
    let project = Project.template
    let reward = Reward.template |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery
    let user = User.template

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.amount.assertValues([10])
      self.currency.assertValues(["$"])
      self.estimatedDelivery.assertValues(
        [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
      )
      self.shippingLocation.assertValues(["Brooklyn"])
      self.shippingAmount.assertValues(["+$7.50"])
      self.isLoggedIn.assertValues([true])
    }
  }
}
