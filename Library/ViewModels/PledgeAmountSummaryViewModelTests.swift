import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeAmountSummaryViewModelTests: TestCase {
  private let vm: PledgeAmountSummaryViewModelType = PledgeAmountSummaryViewModel()

  private let pledgeAmountText = TestObserver<String, Never>()
  private let shippingAmountText = TestObserver<String, Never>()
  private let shippingLocationStackViewIsHidden = TestObserver<Bool, Never>()
  private let shippingLocationText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pledgeAmountText.map { $0.string }
      .observe(self.pledgeAmountText.observer)
    self.vm.outputs.shippingAmountText.map { $0.string }
      .observe(self.shippingAmountText.observer)
    self.vm.outputs.shippingLocationStackViewIsHidden
      .observe(self.shippingLocationStackViewIsHidden.observer)
    self.vm.outputs.shippingLocationText.observe(self.shippingLocationText.observer)
  }

  func testTextOutputsEmitTheCorrectValue() {
    let backing = .template
      |> Backing.lens.sequence .~ 999
      |> Backing.lens.pledgedAt .~ 1_568_666_243.0
      |> Backing.lens.amount .~ 30.0
      |> Backing.lens.shippingAmount .~ 7

    let project = Project.template
      |> \.personalization.isBacking .~ true
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.pledgeAmountText.assertValue("$23.00")
    self.shippingAmountText.assertValue("+$7.00")
    self.shippingLocationText.assertValue("Shipping: United States")
  }

  func testShippingLocationStackViewIsHidden_isFalse_WithShippableRewards() {
    let reward = .template
      |> Reward.lens.shipping.enabled .~ true
    let backing = .template
      |> Backing.lens.reward .~ reward
    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(false)
  }

  func testShippingLocationStackViewIsHidden_isTrue_WhenLocationIdIsNil() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let backing = .template
      |> Backing.lens.locationId .~ nil
      |> Backing.lens.reward .~ reward
    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(true)
  }

  func testShippingLocationStackViewIsHidden_isFalse_WhenLocationIdIsNotNil() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let backing = .template
      |> Backing.lens.locationId .~ 123
      |> Backing.lens.reward .~ reward
    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationStackViewIsHidden.assertValue(false)
  }
}
