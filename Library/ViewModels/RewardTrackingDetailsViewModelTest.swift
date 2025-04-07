@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardTrackingDetailsViewModelTest: TestCase {
  private let vm: RewardTrackingDetailsViewModelType = RewardTrackingDetailsViewModel()

  private var rewardTrackingStatus = TestObserver<String, Never>()
  private var rewardTrackingNumber = TestObserver<String, Never>()
  private var trackShipping = TestObserver<URL, Never>()
  private var shippingDays = TestObserver<String, Never>()

  private let testTrackingNumber = "1234567890"
  private let testURL = URL(string: "http://ksr.com")!
  // Mocked shipping date: 2 days ago from the current mock date
  private lazy var shippingDate: TimeInterval = {
    MockDate().addingTimeInterval(-2 * 24 * 60 * 60).timeIntervalSince1970
  }()

  override func setUp() {
    super.setUp()

    self.vm.outputs.rewardTrackingStatus.observe(self.rewardTrackingStatus.observer)
    self.vm.outputs.rewardTrackingNumber.observe(self.rewardTrackingNumber.observer)
    self.vm.outputs.trackShipping.observe(self.trackShipping.observer)
    self.vm.outputs.shippingDays.observe(self.shippingDays.observer)
  }

  func testView_BackingDetails_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      shippingDate: self.shippingDate
    )

    self.vm.inputs.configure(with: data)
    self.trackShipping.assertDidNotEmitValue()

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingNumber.assertLastValue("Tracking #: 1234567890")
    self.rewardTrackingStatus.assertLastValue("Your reward has been shipped.")
  }

  func testView_Activity_Style() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      shippingDate: self.shippingDate
    )

    self.vm.inputs.configure(with: data)
    self.trackShipping.assertDidNotEmitValue()

    // TODO: Replace with localized string once translations are available. [MBL-2271](https://kickstarter.atlassian.net/browse/MBL-2271)
    self.rewardTrackingNumber.assertLastValue("Tracking #: 1234567890")
    self.rewardTrackingStatus.assertLastValue("Your reward has been shipped.")
    self.shippingDays.assertLastValue("2 days ago")
  }

  func testTrackingButtonTapped() {
    let data = RewardTrackingDetailsViewData(
      trackingNumber: self.testTrackingNumber,
      trackingURL: self.testURL,
      shippingDate: self.shippingDate
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.trackingButtonTapped()

    self.trackShipping.assertValues([self.testURL])
  }
}
