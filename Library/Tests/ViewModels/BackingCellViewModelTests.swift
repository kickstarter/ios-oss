import Library
import Prelude
@testable import ReactiveExtensions_TestHelpers
import ReactiveCocoa
import Result
@testable import KsApi

internal final class BackingCellViewModelTests: TestCase {
  private let vm: BackingCellViewModelType = BackingCellViewModel()

  private let pledged = TestObserver<String, NoError>()
  private let reward = TestObserver<String, NoError>()
  private let delivery = TestObserver<String, NoError>()
  private let deliveryAccessibilityLabel = TestObserver<String, NoError>()
  private let rootStackViewAlignment = TestObserver<UIStackViewAlignment, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.pledged.observe(self.pledged.observer)
    self.vm.outputs.reward.observe(self.reward.observer)
    self.vm.outputs.delivery.observe(self.delivery.observer)
    self.vm.outputs.deliveryAccessibilityLabel.observe(self.deliveryAccessibilityLabel.observer)
    self.vm.outputs.rootStackViewAlignment.observe(self.rootStackViewAlignment.observer)
  }

  func testOutputs() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ NSDate().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward
    let estimatedDeliveryOn = NSDate().timeIntervalSince1970

    self.vm.inputs.configureWith(backing: backing, project: Project.template)

    self.pledged.assertValueCount(1)
    self.reward.assertValues([(backing.reward?.description)!])
    self.delivery.assertValueCount(1)
    self.deliveryAccessibilityLabel.assertValues([
      Strings.backing_info_estimated_delivery_date(delivery_date: Format.date(
        secondsInUTC: estimatedDeliveryOn,
        dateStyle: .LongStyle,
        timeStyle: .NoStyle))], "Emits the estimated delivery date for screen reading")
    self.rootStackViewAlignment.assertValues([UIStackViewAlignment.Leading])
  }

  func testRootStackViewAlignment() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ NSDate().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward

    withEnvironment(isVoiceOverRunning: { true }) {
      self.vm.inputs.configureWith(backing: backing, project: Project.template)

      self.rootStackViewAlignment.assertValues([UIStackViewAlignment.Fill])
    }
  }
}
