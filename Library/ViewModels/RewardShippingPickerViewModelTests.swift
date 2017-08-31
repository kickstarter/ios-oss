// swiftlint:disable force_unwrapping
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

private let locations: [Location] = [
  .usa,
  .canada,
  .greatBritain,
  .australia
]

private let shippingRules = locations
  .enumerated()
  .map { idx, location in
    .template
      |> ShippingRule.lens.location .~ location
      |> ShippingRule.lens.cost .~ Double(idx + 1)
}

private let sortedShippingRules = shippingRules
  .sorted { lhs, rhs in lhs.location.displayableName < rhs.location.displayableName }

internal final class RewardShippingPickerViewModelTests: TestCase {
  fileprivate let vm: RewardShippingPickerViewModelType = RewardShippingPickerViewModel()

  fileprivate let dataSource = TestObserver<[String], NoError>()
  fileprivate let doneButtonAccessibilityHint = TestObserver<String, NoError>()
  fileprivate let notifyDelegateChoseShippingRule = TestObserver<ShippingRule, NoError>()
  fileprivate let notifyDelegateToCancel = TestObserver<(), NoError>()
  fileprivate let selectRow = TestObserver<Int, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dataSource.observe(self.dataSource.observer)
    self.vm.outputs.doneButtonAccessibilityHint.observe(self.doneButtonAccessibilityHint.observer)
    self.vm.outputs.notifyDelegateChoseShippingRule.observe(self.notifyDelegateChoseShippingRule.observer)
    self.vm.outputs.notifyDelegateToCancel.observe(self.notifyDelegateToCancel.observer)
    self.vm.outputs.selectRow.observe(self.selectRow.observer)
  }

  func testDataSource() {
    self.vm.inputs.configureWith(project: .template,
                                 shippingRules: shippingRules,
                                 selectedShippingRule: shippingRules.first!)
    self.vm.inputs.viewDidLoad()

    self.dataSource.assertValues([
      [
        "Australia +$4",
        "Canada +$2",
        "Great Britain +$3",
        "United States +$1"
      ]
    ])
  }

  func testLocalizedDataSource() {
    let localizedRules =
      shippingRules ||> ShippingRule.lens.location..Location.lens.localizedName %~ { "Local " + $0 }

    self.vm.inputs.configureWith(project: .template,
                                 shippingRules: localizedRules,
                                 selectedShippingRule: localizedRules.first!)
    self.vm.inputs.viewDidLoad()

    self.dataSource.assertValues([
      [
        "Local Australia +$4",
        "Local Canada +$2",
        "Local Great Britain +$3",
        "Local United States +$1"
      ]
    ])
  }

  func testDoneButtonAccessibilityHint() {
    let selectedShippingRule = shippingRules.first!

    self.vm.inputs.configureWith(project: .template,
                                 shippingRules: shippingRules,
                                 selectedShippingRule: selectedShippingRule)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.doneButtonAccessibilityHint.assertValues(["Chooses United States for shipping."])
  }

  func testNotifyDelegateChoseShippingRule_MakeNoChoice() {
    let selectedShippingRule = shippingRules.first!

    self.vm.inputs.configureWith(project: .template,
                                 shippingRules: shippingRules,
                                 selectedShippingRule: selectedShippingRule)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.doneButtonTapped()

    self.notifyDelegateChoseShippingRule.assertValues([selectedShippingRule])
  }

  func testNotifyDelegateChoseShippingRule_MakeAChoice() {
    self.vm.inputs.configureWith(project: .template,
                                 shippingRules: shippingRules,
                                 selectedShippingRule: shippingRules.first!)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewWillAppear()

    self.vm.inputs.pickerView(didSelectRow: 2)
    self.vm.inputs.doneButtonTapped()

    self.notifyDelegateChoseShippingRule.assertValues([sortedShippingRules[2]])
  }

  func testNotifyDelegateToCancel() {
    self.vm.inputs.configureWith(project: .template,
                                 shippingRules: shippingRules,
                                 selectedShippingRule: shippingRules.first!)
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateToCancel.assertValueCount(0)

    self.vm.inputs.cancelButtonTapped()

    self.notifyDelegateToCancel.assertValueCount(1)
    self.notifyDelegateChoseShippingRule.assertValueCount(0)
  }

  func testSelectRow() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "AU") {
      self.vm.inputs.configureWith(project: .template,
                                   shippingRules: shippingRules,
                                   selectedShippingRule: sortedShippingRules.last!)
      self.vm.inputs.viewDidLoad()

      self.selectRow.assertValues([])

      self.vm.inputs.viewWillAppear()

      self.selectRow.assertValues([3], "Defaults to the selected shipping location, Australia.")

      self.vm.inputs.pickerView(didSelectRow: 2)

      self.selectRow.assertValues([3], "Changing the row in the UI doesn't cause the row to be reset.")
    }
  }
}
