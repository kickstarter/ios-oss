import Library
import Prelude
@testable import ReactiveExtensions_TestHelpers
import ReactiveSwift
import Result
@testable import KsApi

internal final class BackingCellViewModelTests: TestCase {
  fileprivate let vm: BackingCellViewModelType = BackingCellViewModel()

  fileprivate let pledged = TestObserver<String, NoError>()
  fileprivate let reward = TestObserver<String, NoError>()
  fileprivate let delivery = TestObserver<String, NoError>()
  fileprivate let deliveryAccessibilityLabel = TestObserver<String, NoError>()
  fileprivate let rootStackViewAlignment = TestObserver<UIStackViewAlignment, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pledged.observe(self.pledged.observer)
    self.vm.outputs.reward.observe(self.reward.observer)
    self.vm.outputs.delivery.observe(self.delivery.observer)
    self.vm.outputs.rootStackViewAlignment.observe(self.rootStackViewAlignment.observer)
  }

  func testOutputs() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ Date().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward

    self.vm.inputs.configureWith(backing: backing, project: Project.template)

    self.pledged.assertValueCount(1)
    self.reward.assertValues([(backing.reward?.description)!])
    self.delivery.assertValues([
      Strings.backing_info_estimated_delivery_date(delivery_date:
        Format.date(
          secondsInUTC: reward.estimatedDeliveryOn!, dateFormat: "MMMM yyyy", timeZone: UTCTimeZone
        )
      )], "Emits the estimated delivery date")

    self.rootStackViewAlignment.assertValues([UIStackViewAlignment.leading])
  }

  func testRootStackViewAlignment() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ Date().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward

    withEnvironment(isVoiceOverRunning: { true }) {
      self.vm.inputs.configureWith(backing: backing, project: Project.template)

      self.rootStackViewAlignment.assertValues([UIStackViewAlignment.fill])
    }
  }
}
