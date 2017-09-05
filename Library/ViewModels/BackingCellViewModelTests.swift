// swiftlint:disable force_unwrapping
import Library
import Prelude
@testable import ReactiveExtensions_TestHelpers
import ReactiveSwift
import Result
@testable import KsApi

internal final class BackingCellViewModelTests: TestCase {
  fileprivate let vm: BackingCellViewModelType = BackingCellViewModel()

  private let backingInfoButtonIsHidden = TestObserver<Bool, NoError>()
  fileprivate let delivery = TestObserver<String, NoError>()
  fileprivate let pledged = TestObserver<String, NoError>()
  fileprivate let reward = TestObserver<String, NoError>()
  fileprivate let rootStackViewAlignment = TestObserver<UIStackViewAlignment, NoError>()

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
      Strings.backing_info_estimated_delivery_date(delivery_date:
        Format.date(
          secondsInUTC: reward.estimatedDeliveryOn!, template: "MMMMyyyy", timeZone: UTCTimeZone
        )
      )], "Emits the estimated delivery date")

    self.rootStackViewAlignment.assertValues([UIStackViewAlignment.leading])
  }

  func testRootStackViewAlignment() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ Date().timeIntervalSince1970
    let backing = .template |> Backing.lens.reward .~ reward

    withEnvironment(isVoiceOverRunning: const(true)) {
      self.vm.inputs.configureWith(backing: backing, project: Project.template, isFromBacking: true)

      self.rootStackViewAlignment.assertValues([UIStackViewAlignment.fill])
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
