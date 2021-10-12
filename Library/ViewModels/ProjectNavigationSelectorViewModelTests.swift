@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class ProjectNavigationSelectorViewModelTests: TestCase {
  fileprivate let vm: ProjectNavigationSelectorViewModelType = ProjectNavigationSelectorViewModel()

  fileprivate let animateButtonBottomBorderViewConstraints = TestObserver<Int, Never>()
  fileprivate let configureSelectedButtonBottomBorderView = TestObserver<Void, Never>()
  fileprivate let createButtons = TestObserver<[NavigationSection], Never>()
  fileprivate let notifyDelegateProjectNavigationSelectorDidSelect = TestObserver<Int, Never>()
  fileprivate let updateNavigationSelectorUI = TestObserver<Int, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.animateButtonBottomBorderViewConstraints
      .observe(self.animateButtonBottomBorderViewConstraints.observer)
    self.vm.outputs.configureSelectedButtonBottomBorderView
      .observe(self.configureSelectedButtonBottomBorderView.observer)
    self.vm.outputs.createButtons.observe(self.createButtons.observer)
    self.vm.outputs.notifyDelegateProjectNavigationSelectorDidSelect
      .observe(self.notifyDelegateProjectNavigationSelectorDidSelect.observer)
    self.vm.outputs.updateNavigationSelectorUI.observe(self.updateNavigationSelectorUI.observer)
  }

  func testDisplayStrings() {
    XCTAssertEqual(NavigationSection.overview.displayString, "OVERVIEW")
    XCTAssertEqual(NavigationSection.campaign.displayString, "CAMPAIGN")
    XCTAssertEqual(NavigationSection.faq.displayString, "FAQ")
    XCTAssertEqual(NavigationSection.environmentalCommitments.displayString, "ENVIRONMENTAL COMMITMENTS")
  }

  func testOutput_animateButtonBottomBorderViewConstraints() {
    self.vm.inputs.configureNavigationSelector()

    self.animateButtonBottomBorderViewConstraints.assertDidNotEmitValue()

    self.vm.inputs.buttonTapped(index: 0)

    self.animateButtonBottomBorderViewConstraints.assertValues([0])

    self.vm.inputs.buttonTapped(index: 1)

    self.animateButtonBottomBorderViewConstraints.assertValues([0, 1])
  }

  func testOutput_configureSelectedButtonBottomBorderView() {
    self.vm.inputs.buttonTapped(index: 0)

    self.configureSelectedButtonBottomBorderView.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector()

    self.configureSelectedButtonBottomBorderView.assertDidEmitValue()
  }

  func testOutput_createButtons() {
    self.vm.inputs.buttonTapped(index: 0)

    self.createButtons.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector()

    self.createButtons.assertValues([NavigationSection.allCases])
  }

  func testOutput_notifyDelegateProjectNavigationSelectorDidSelect() {
    self.vm.inputs.configureNavigationSelector()

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0])

    self.vm.inputs.buttonTapped(index: 0)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0, 0])

    self.vm.inputs.buttonTapped(index: 3)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0, 0, 3])
  }

  func testOutput_updateNavigationSelectorUI() {
    self.vm.inputs.configureNavigationSelector()

    self.updateNavigationSelectorUI.assertValues([0])

    self.vm.inputs.buttonTapped(index: 0)

    self.updateNavigationSelectorUI.assertValues([0, 0])

    self.vm.inputs.buttonTapped(index: 3)

    self.updateNavigationSelectorUI.assertValues([0, 0, 3])
  }
}
