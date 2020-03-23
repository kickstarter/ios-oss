@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class LandingPageStatsViewModelTests: TestCase {
  fileprivate let descriptionLabelText = TestObserver<String, Never>()
  fileprivate let quantityLabelIsHidden = TestObserver<Bool, Never>()
  fileprivate let quantityLabelText = TestObserver<String, Never>()
  fileprivate let titleLabelText = TestObserver<String, Never>()
  fileprivate let viewModel: LandingPageStatsViewModelType = LandingPageStatsViewModel()

  override func setUp() {
    super.setUp()
    self.viewModel.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.viewModel.outputs.quantityLabelIsHidden.observe(self.quantityLabelIsHidden.observer)
    self.viewModel.outputs.quantityLabelText.observe(self.quantityLabelText.observer)
    self.viewModel.outputs.titleLabelText.observe(self.titleLabelText.observer)
  }

  func testCardInfo() {
    let successfulProjectsCard = LandingPageCardType.successfulProjects

    self.viewModel.inputs.configure(with: successfulProjectsCard)

    self.descriptionLabelText.assertValue(
      "Successful projects have been created on Kickstarter."
    )
    self.quantityLabelText.assertValue("177,000+")
    self.quantityLabelIsHidden.assertValue(false)
    self.titleLabelText.assertValue("Guide creators to success")
  }

  func testQuantityLabel_IsHidden() {
    let allOrNothingCard = LandingPageCardType.allOrNothing

    self.viewModel.inputs.configure(with: allOrNothingCard)

    // allOrNothing doesn't have a quantity value, thus the label should be hidden.
    self.quantityLabelIsHidden.assertValue(true)
  }
}
