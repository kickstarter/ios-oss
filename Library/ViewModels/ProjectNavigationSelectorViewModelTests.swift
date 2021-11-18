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
  fileprivate let configureNavigationSelectorUI = TestObserver<[NavigationSection], Never>()
  fileprivate let notifyDelegateProjectNavigationSelectorDidSelect = TestObserver<Int, Never>()
  fileprivate let updateNavigationSelectorUI = TestObserver<Int, Never>()

  fileprivate let emptyProjectProperties = ExtendedProjectProperties(
    environmentalCommitments: [],
    faqs: [],
    risks: "",
    story: "",
    minimumPledgeAmount: 1
  )

  override func setUp() {
    super.setUp()

    self.vm.outputs.animateButtonBottomBorderViewConstraints
      .observe(self.animateButtonBottomBorderViewConstraints.observer)
    self.vm.outputs.configureNavigationSelectorUI
      .observe(self.configureNavigationSelectorUI.observer)
    self.vm.outputs.notifyDelegateProjectNavigationSelectorDidSelect
      .observe(self.notifyDelegateProjectNavigationSelectorDidSelect.observer)
    self.vm.outputs.updateNavigationSelectorUI.observe(self.updateNavigationSelectorUI.observer)
  }

  func testDisplayStrings() {
    XCTAssertEqual(NavigationSection.overview.displayString, "OVERVIEW")
    XCTAssertEqual(NavigationSection.campaign.displayString, "CAMPAIGN")
    XCTAssertEqual(NavigationSection.faq.displayString, "FAQ")
    XCTAssertEqual(NavigationSection.risks.displayString, "RISKS")
    XCTAssertEqual(NavigationSection.environmentalCommitments.displayString, "ENVIRONMENTAL COMMITMENTS")
  }

  func testOutput_animateButtonBottomBorderViewConstraints() {
    self.vm.inputs.configureNavigationSelector(with: self.emptyProjectProperties)

    self.animateButtonBottomBorderViewConstraints.assertDidNotEmitValue()

    self.vm.inputs.buttonTapped(index: 0)

    self.animateButtonBottomBorderViewConstraints.assertValues([0])

    self.vm.inputs.buttonTapped(index: 1)

    self.animateButtonBottomBorderViewConstraints.assertValues([0, 1])
  }

  func testOutput_configureSelectedButtonBottomBorderView() {
    self.vm.inputs.buttonTapped(index: 0)

    self.configureNavigationSelectorUI.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector(with: self.emptyProjectProperties)

    self.configureNavigationSelectorUI.assertDidEmitValue()
  }

  func testOutput_ConfigureNavigationSelectorUI() {
    let projectProperties = ExtendedProjectProperties(
      environmentalCommitments: [
        ProjectEnvironmentalCommitment(
          description: "Environment Commitment 0",
          category: .environmentallyFriendlyFactories,
          id: 0
        ),
        ProjectEnvironmentalCommitment(
          description: "Environment Commitment 1",
          category: .longLastingDesign,
          id: 1
        ),
        ProjectEnvironmentalCommitment(
          description: "Environment Commitment 2",
          category: .reusabilityAndRecyclability,
          id: 2
        )
      ],
      faqs: [],
      risks: "",
      story: "",
      minimumPledgeAmount: 1
    )

    self.vm.inputs.buttonTapped(index: 0)

    self.configureNavigationSelectorUI.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector(with: projectProperties)

    self.configureNavigationSelectorUI.assertValues([NavigationSection.allCases])
  }

  func testOutput_ConfigureNavigationSelectorUI_EmptyEnvironmentalCommitments() {
    self.vm.inputs.buttonTapped(index: 0)

    self.configureNavigationSelectorUI.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector(with: self.emptyProjectProperties)

    self.configureNavigationSelectorUI.assertValues([[.overview, .campaign, .faq, .risks]])
  }

  func testOutput_notifyDelegateProjectNavigationSelectorDidSelect() {
    self.vm.inputs.configureNavigationSelector(with: self.emptyProjectProperties)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0])

    self.vm.inputs.buttonTapped(index: 0)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0, 0])

    self.vm.inputs.buttonTapped(index: 3)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0, 0, 3])
  }

  func testOutput_updateNavigationSelectorUI() {
    self.vm.inputs.configureNavigationSelector(with: self.emptyProjectProperties)

    self.updateNavigationSelectorUI.assertValues([0])

    self.vm.inputs.buttonTapped(index: 0)

    self.updateNavigationSelectorUI.assertValues([0, 0])

    self.vm.inputs.buttonTapped(index: 3)

    self.updateNavigationSelectorUI.assertValues([0, 0, 3])
  }
}
