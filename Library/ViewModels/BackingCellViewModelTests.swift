@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift

internal final class BackingCellViewModelTests: TestCase {
  fileprivate let vm: BackingCellViewModelType = BackingCellViewModel()

  private let backingInfoButtonIsHidden = TestObserver<Bool, Never>()
  fileprivate let delivery = TestObserver<String, Never>()
  fileprivate let pledged = TestObserver<String, Never>()
  fileprivate let reward = TestObserver<String, Never>()
  fileprivate let rootStackViewAlignment = TestObserver<UIStackView.Alignment, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backingInfoButtonIsHidden.observe(self.backingInfoButtonIsHidden.observer)
    self.vm.outputs.pledged.observe(self.pledged.observer)
    self.vm.outputs.reward.observe(self.reward.observer)
    self.vm.outputs.delivery.observe(self.delivery.observer)
    self.vm.outputs.rootStackViewAlignment.observe(self.rootStackViewAlignment.observer)
  }

  func testOutputs() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ Date().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward

    self.backingInfoButtonIsHidden.assertValueCount(0)
    self.pledged.assertValueCount(0)

    self.vm.inputs.configureWith(backing: backing, project: Project.template, isFromBacking: true)

    self.backingInfoButtonIsHidden.assertValues([true])
    self.pledged.assertValueCount(1)
    self.reward.assertValues([(backing.reward?.description)!])
    self.delivery.assertValues([
      Strings.backing_info_estimated_delivery_date(
        delivery_date:
        Format.date(
          secondsInUTC: reward.estimatedDeliveryOn!, template: DateFormatter.monthYear, timeZone: UTCTimeZone
        )
      )
    ], "Emits the estimated delivery date")

    self.rootStackViewAlignment.assertValues([UIStackView.Alignment.leading])
  }

  func testRootStackViewAlignment() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ Date().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward

    withEnvironment(isVoiceOverRunning: { true }) {
      self.vm.inputs.configureWith(backing: backing, project: Project.template, isFromBacking: true)

      self.rootStackViewAlignment.assertValues([UIStackView.Alignment.fill])
    }
  }

  func testShowBackingInfoButton() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ Date().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward

    self.backingInfoButtonIsHidden.assertValueCount(0)

    self.vm.inputs.configureWith(backing: backing, project: Project.template, isFromBacking: false)

    self.backingInfoButtonIsHidden.assertValues([false])
  }
}
