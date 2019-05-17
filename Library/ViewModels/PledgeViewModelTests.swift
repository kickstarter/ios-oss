import Foundation
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest

@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers

final class PledgeViewModelTests: TestCase {
  private let vm: PledgeViewModelType = PledgeViewModel()

  private let amount = TestObserver<Double, NoError>()
  private let currency = TestObserver<String, NoError>()
  private let isLoggedIn = TestObserver<Bool, NoError>()
  private let estimatedDelivery = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.reloadWithData.map { $0.amount }.observe(self.amount.observer)
    self.vm.outputs.reloadWithData.map { $0.currency }.observe(self.currency.observer)
    self.vm.outputs.reloadWithData.map { $0.isLoggedIn }.observe(self.isLoggedIn.observer)
    self.vm.outputs.reloadWithData.map { $0.delivery }.observe(self.estimatedDelivery.observer)
  }

  func testReloadWithData_loggedOut() {

    let project = Project.template
    let reward = Reward.template

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.isLoggedIn.assertValues([false])
    }
  }

  func testReloadWithData_loggedIn() {
    let estimatedDelivery = 1468527587.32843
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.estimatedDeliveryOn .~ estimatedDelivery

    let user = User.template

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, reward: reward)
      self.vm.inputs.viewDidLoad()

      self.amount.assertValues([10])
      self.currency.assertValues(["$"])
      self.isLoggedIn.assertValues([true])
      self.estimatedDelivery.assertValues(
        [Format.date(secondsInUTC: estimatedDelivery, template: "MMMMyyyy", timeZone: UTCTimeZone)]
      )
    }
  }
}
