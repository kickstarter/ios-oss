import Foundation
@testable import KsApi
@testable import Library
import PassKit
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class ConfirmDetailsViewModelTests: TestCase {
  private let vm: ConfirmDetailsViewModelType = ConfirmDetailsViewModel()

  private let configureLocalPickupViewWithData = TestObserver<PledgeLocalPickupViewData, Never>()

  private let configureShippingSummaryViewWithData = TestObserver<PledgeShippingSummaryViewData, Never>()

  private let configureShippingLocationViewWithDataProject = TestObserver<Project, Never>()
  private let configureShippingLocationViewWithDataReward = TestObserver<Reward, Never>()
  private let configureShippingLocationViewWithDataShowAmount = TestObserver<Bool, Never>()

  private let localPickupViewHidden = TestObserver<Bool, Never>()

  private let pledgeAmountViewHidden = TestObserver<Bool, Never>()
  private let shippingLocationViewHidden = TestObserver<Bool, Never>()
  private let shippingSummaryViewHidden = TestObserver<Bool, Never>()
  private let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureShippingLocationViewWithData.map { $0.project }
      .observe(self.configureShippingLocationViewWithDataProject.observer)
    self.vm.outputs.configureShippingLocationViewWithData.map { $0.reward }
      .observe(self.configureShippingLocationViewWithDataReward.observer)
    self.vm.outputs.configureShippingLocationViewWithData.map { $0.showAmount }
      .observe(self.configureShippingLocationViewWithDataShowAmount.observer)

    self.vm.outputs.configureShippingSummaryViewWithData
      .observe(self.configureShippingSummaryViewWithData.observer)

    self.vm.outputs.localPickupViewHidden.observe(self.localPickupViewHidden.observer)

    self.vm.outputs.pledgeAmountViewHidden.observe(self.pledgeAmountViewHidden.observer)

    self.vm.outputs.shippingLocationViewHidden.observe(self.shippingLocationViewHidden.observer)
    self.vm.outputs.shippingSummaryViewHidden.observe(self.shippingSummaryViewHidden.observer)
  }
}
