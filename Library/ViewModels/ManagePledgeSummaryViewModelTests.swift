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
  private let pledgeAmountText = TestObserver<String, Never>()
  private let shippingAmountText = TestObserver<String, Never>()
  private let shippingLocationStackViewIsHidden = TestObserver<Bool, Never>()
  private let shippingLocationText = TestObserver<String, Never>()
  private let totalAmountText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.backerNumberText.observe(self.backerNumberText.observer)
    self.vm.outputs.backingDateText.observe(self.backingDateText.observer)
    self.vm.outputs.pledgeAmountText.map { $0.string }
      .observe(self.pledgeAmountText.observer)
    self.vm.outputs.shippingAmountText.map { $0.string }
      .observe(self.shippingAmountText.observer)
    self.vm.outputs.shippingLocationStackViewIsHidden
      .observe(self.shippingLocationStackViewIsHidden.observer)
    self.vm.outputs.shippingLocationText.observe(self.shippingLocationText.observer)
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

    self.backerNumberText.assertValue("Backer #999")
    self.backingDateText.assertValue("As of September 16, 2019")
    self.pledgeAmountText.assertValue("$30.00")
    self.shippingAmountText.assertValue("+$7.00")
    self.shippingLocationText.assertValue("Shipping: United States")
    self.totalAmountText.assertValue("$37.00")
  }

  func testShippingLocationStackViewIsHidden_isFalse_WithShippableRewards() {
    let reward = .template
      |> Reward.lens.shipping.enabled .~ true
    let backing = .template
      |> Backing.lens.reward .~ reward
    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)

    self.shippingLocationStackViewIsHidden.assertValue(false)
  }

  func testShippingLocationStackViewIsHidden_isTrue_WithNoReward() {
    let backing = .template
      |> Backing.lens.reward .~ Reward.noReward
    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)

    self.shippingLocationStackViewIsHidden.assertValue(true)
  }

  func testShippingLocationStackViewIsHidden_isTrue_WithNoShippableRewards() {
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ false
    let backing = .template
      |> Backing.lens.reward .~ reward
    let project = Project.template
      |> \.personalization.backing .~ backing

    self.vm.inputs.configureWith(project)

    self.shippingLocationStackViewIsHidden.assertValue(true)
  }
}
