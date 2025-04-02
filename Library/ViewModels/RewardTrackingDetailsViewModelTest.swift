@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardTrackingDetailsViewModelTest: TestCase {
  private let vm: RewardTrackingDetailsViewModelType = RewardTrackingDetailsViewModel()

  private var backgroundColor = TestObserver<UIColor, Never>()
  private var cornerRadius = TestObserver<CGFloat, Never>()
  private var rewardTrackingStatus = TestObserver<String, Never>()
  private var rewardTrackingNumber = TestObserver<String, Never>()
  private var trackShipping = TestObserver<URL, Never>()

  private let testTrackingNumber = "1234567890"
  private let testURL = URL(string: "http://ksr.com")!

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundColor.observe(self.backgroundColor.observer)
    self.vm.outputs.cornerRadius.observe(self.cornerRadius.observer)
    self.vm.outputs.rewardTrackingStatus.observe(self.rewardTrackingStatus.observer)
    self.vm.outputs.rewardTrackingNumber.observe(self.rewardTrackingNumber.observer)
    self.vm.outputs.trackShipping.observe(self.trackShipping.observer)
  }

  func testView_BackingDetails_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      style: .backingDetails
    )

    self.vm.inputs.configure(with: data)
    self.backgroundColor.assertLastValue(.ksr_support_200)
    self.cornerRadius.assertLastValue(8.0)
    self.trackShipping.assertDidNotEmitValue()

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingNumber.assertLastValue("Tracking #: 1234567890")
    self.rewardTrackingStatus.assertLastValue("Your reward has been shipped.")
  }

  func testView_Activity_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      style: .activity
    )

    self.vm.inputs.configure(with: data)
    self.backgroundColor.assertLastValue(Colors.Background.surfacePrimary.adaptive())
    self.cornerRadius.assertLastValue(0.0)
    self.trackShipping.assertDidNotEmitValue()

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingNumber.assertLastValue("Tracking #: 1234567890")
    self.rewardTrackingStatus.assertLastValue("Your reward has been shipped.")
  }

  func testTrackingButtonTapped() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL
    )

    self.vm.inputs.configure(with: data)

    self.vm.inputs.trackingButtonTapped()

    self.trackShipping.assertValues([self.testURL])
  }
}
