@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

private let regularHeight: CGFloat = 150
private let expandedHeight: CGFloat = 350

final class PledgeAmountViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: .template, reward: .template, 0))

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView"
        )
      }
    }
  }

  func testView_ShowsCurrencySymbol_NonUS_ProjectCurrency_US_ProjectCountry() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.projectCurrency .~ Project.Country.ca.currencyCode
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: project, reward: .template, 0))

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView_ShowsCurrencySymbol_NonUS_ProjectCurrency_US_ProjectCountry"
        )
      }
    }
  }

  func testView_ShowsCurrencySymbol_US_ProjectCurrency_US_ProjectCountry() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.projectCurrency .~ Project.Country.us.currencyCode
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: project, reward: .template, 0))

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView_ShowsCurrencySymbol_US_ProjectCurrency_US_ProjectCountry"
        )
      }
    }
  }

  func testView_StepperDecrementButtonDisabled_WhenStepperValueSetToMinimum() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 0
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: .template, reward: reward, 0))
        controller.stepperValueChanged(UIStepper(frame: .zero) |> \.value .~ 0)
        controller.textFieldDidChange(UITextField(frame: .zero) |> \.text .~ "0")

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView_StepperDecrementButtonDisabled_WhenStepperValueSetToMinimum"
        )
      }
    }
  }

  func testView_StepperIncrementButtonDisabled_WhenStepperValueSetToMaximumStepperValue() {
    let maxValue = PledgeAmountStepperConstants.max

    let stepper = UIStepper(frame: .zero)
      |> \.maximumValue .~ maxValue
      |> \.value .~ maxValue

    let textField = UITextField(frame: .zero)
      |> \.text .~ String(format: "%.0f", maxValue)

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: .template, reward: .template, 0))
        controller.stepperValueChanged(stepper)
        controller.textFieldDidChange(textField)

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView_StepperIncrementButtonDisabled_WhenStepperValueSetToMaximumStepperValue"
        )
      }
    }
  }

  func testView_TextColorIsGreenWhenEqualToMinimumPledgeAmount() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 10

    let stepper = UIStepper(frame: .zero)
      |> \.value .~ 0

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: .template, reward: reward, 0))
        controller.stepperValueChanged(stepper)

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView_TextColorIsGreenWhenEqualToMinimumPledgeAmount"
        )
      }
    }
  }

  func testView_TextColorIsGreenWhenEqualToMaximumPledgeAmount() {
    let project = Project.template
      |> (Project.lens.country .. Project.Country.lens.maxPledge) .~ 10_000

    let stepper = UIStepper(frame: .zero)
      |> \.maximumValue .~ PledgeAmountStepperConstants.max
      |> \.value .~ 10_000

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: project, reward: .template, 0))
        controller.stepperValueChanged(stepper)

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView_TextColorIsGreenWhenEqualToMaximumPledgeAmount"
        )
      }
    }
  }

  func testView_ErrorMessageAppears_And_TextColorIsRedWhenAboveMaximumPledgeAmount() {
    let project = Project.template
      |> (Project.lens.country .. Project.Country.lens.maxPledge) .~ 10_000

    let stepper = UIStepper(frame: .zero)
      |> \.maximumValue .~ PledgeAmountStepperConstants.max
      |> \.value .~ 10_001

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "GMT")!

    forEachScreenshotType { type in
      withEnvironment(
        calendar: calendar,
        language: type.language,
        locale: type.locale,
        mainBundle: self.mainBundle
      ) {
        let controller = PledgeAmountViewController.instantiate()
        controller.configureWith(value: (project: project, reward: .template, 0))
        controller.stepperValueChanged(stepper)

        let size = self.snapshotSize(for: type)

        self.stabilizeForSnapshot(controller)

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: size,
          perceptualPrecision: 0.98,
          testName: "testView_ErrorMessageAppears_And_TextColorIsRedWhenAboveMaximumPledgeAmount"
        )
      }
    }
  }

  private func stabilizeForSnapshot(_ controller: UIViewController) {
    self.allowLayoutPass()
    controller.view.layoutIfNeeded()
    controller.view.endEditing(true)

    if let textField = controller.view.firstTextField() {
      textField.resignFirstResponder()
      textField.tintColor = .clear
      textField.selectedTextRange = nil
    }

    self.allowLayoutPass()
    controller.view.layoutIfNeeded()
  }

  private func snapshotSize(for type: ScreenshotType) -> CGSize {
    let height = type.contentSizeCategory.isAccessibilityCategory ? expandedHeight : regularHeight
    return CGSize(
      width: type.device.deviceSize(in: type.orientation).width,
      height: height
    )
  }
}

private extension UIView {
  func firstTextField() -> UITextField? {
    if let textField = self as? UITextField {
      return textField
    }

    for subview in self.subviews {
      if let textField = subview.firstTextField() {
        return textField
      }
    }

    return nil
  }
}
