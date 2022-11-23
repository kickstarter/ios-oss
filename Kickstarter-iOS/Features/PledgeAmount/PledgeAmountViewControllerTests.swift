@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit

private let regularHeight: CGFloat = 150
private let expandedHeight: CGFloat = 350

final class PledgeAmountViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView() {
    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: .template, reward: .template, 0))

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testView_LargerText() {
    UITraitCollection.allCases.forEach { additionalTraits in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(child: controller, additionalTraits: additionalTraits)
      parent.view.frame.size.height = expandedHeight

      controller.configureWith(value: (project: .template, reward: .template, 0))

      FBSnapshotVerifyView(
        parent.view, identifier: "trait_\(additionalTraits.preferredContentSizeCategory.rawValue)"
      )
    }
  }

  func testView_ShowsCurrencySymbol_NonUS_ProjectCurrency_US_ProjectCountry() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currency .~ Project.Country.ca.currencyCode

    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: project, reward: .template, 0))

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testView_ShowsCurrencySymbol_US_ProjectCurrency_US_ProjectCountry() {
    let project = Project.template
      |> Project.lens.country .~ Project.Country.us
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode

    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: project, reward: .template, 0))

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testView_StepperDecrementButtonDisabled_WhenStepperValueSetToMinimum() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 0

    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: .template, reward: reward, 0))
      controller.stepperValueChanged(UIStepper(frame: .zero) |> \.value .~ 0)
      controller.textFieldDidChange(UITextField(frame: .zero) |> \.text .~ "0")

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testView_StepperIncrementButtonDisabled_WhenStepperValueSetToMaximumStepperValue() {
    let maxValue = PledgeAmountStepperConstants.max

    let stepper = UIStepper(frame: .zero)
      |> \.maximumValue .~ maxValue
      |> \.value .~ maxValue

    let textField = UITextField(frame: .zero)
      |> \.text .~ String(format: "%.0f", maxValue)

    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: .template, reward: .template, 0))
      controller.stepperValueChanged(stepper)
      controller.textFieldDidChange(textField)

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testView_TextColorIsGreenWhenEqualToMinimumPledgeAmount() {
    let reward = Reward.template
      |> Reward.lens.minimum .~ 10

    let stepper = UIStepper(frame: .zero)
      |> \.value .~ 0

    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: .template, reward: reward, 0))
      controller.stepperValueChanged(stepper)

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testView_TextColorIsGreenWhenEqualToMaximumPledgeAmount() {
    let project = Project.template
      |> (Project.lens.country .. Project.Country.lens.maxPledge) .~ 10_000

    let stepper = UIStepper(frame: .zero)
      |> \.maximumValue .~ PledgeAmountStepperConstants.max
      |> \.value .~ 10_000

    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: project, reward: .template, 0))
      controller.stepperValueChanged(stepper)

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }

  func testView_ErrorMessageAppears_And_TextColorIsRedWhenAboveMaximumPledgeAmount() {
    let project = Project.template
      |> (Project.lens.country .. Project.Country.lens.maxPledge) .~ 10_000

    let stepper = UIStepper(frame: .zero)
      |> \.maximumValue .~ PledgeAmountStepperConstants.max
      |> \.value .~ 10_001

    [Device.phone4_7inch, Device.pad].forEach { device in
      let controller = PledgeAmountViewController.instantiate()
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
      parent.view.frame.size.height = regularHeight

      controller.configureWith(value: (project: project, reward: .template, 0))
      controller.stepperValueChanged(stepper)

      FBSnapshotVerifyView(parent.view, identifier: "device_\(device)")
    }
  }
}
