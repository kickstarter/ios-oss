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

  fileprivate var projectAndEmptyRefTag: (Project, RefTag?) {
    var projectWithEmptyExtendedProperties = Project.template

    projectWithEmptyExtendedProperties
      .extendedProjectProperties = ExtendedProjectProperties(
        environmentalCommitments: [],
        faqs: [],
        risks: "",
        story: ProjectStoryElements(htmlViewElements: []),
        minimumPledgeAmount: 1
      )

    return (projectWithEmptyExtendedProperties, nil)
  }

  fileprivate let projectPropertiesWithEnvironmentalCommitments: ExtendedProjectProperties =
    ExtendedProjectProperties(
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
      story: ProjectStoryElements(htmlViewElements: []),
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
    XCTAssertEqual(NavigationSection.overview.displayString, "Overview")
    XCTAssertEqual(NavigationSection.campaign.displayString, "Campaign")
    XCTAssertEqual(NavigationSection.faq.displayString, "FAQ")
    XCTAssertEqual(NavigationSection.risks.displayString, "Risks")
    XCTAssertEqual(NavigationSection.environmentalCommitments.displayString, "Environmental commitments")
  }

  func testOutput_animateButtonBottomBorderViewConstraints() {
    self.vm.inputs.configureNavigationSelector(with: self.projectAndEmptyRefTag)

    self.animateButtonBottomBorderViewConstraints.assertDidNotEmitValue()

    self.vm.inputs.buttonTapped(index: 0)

    self.animateButtonBottomBorderViewConstraints.assertValues([0])

    self.vm.inputs.buttonTapped(index: 1)

    self.animateButtonBottomBorderViewConstraints.assertValues([0, 1])
  }

  func testOutput_configureSelectedButtonBottomBorderView() {
    self.vm.inputs.buttonTapped(index: 0)

    self.configureNavigationSelectorUI.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector(with: self.projectAndEmptyRefTag)

    self.configureNavigationSelectorUI.assertDidEmitValue()
  }

  func testOutput_ConfigureNavigationSelectorUI() {
    var project = Project.template
    project.extendedProjectProperties = self.projectPropertiesWithEnvironmentalCommitments

    self.vm.inputs.buttonTapped(index: 0)

    self.configureNavigationSelectorUI.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector(with: (project, nil))

    self.configureNavigationSelectorUI.assertValues([[.overview, .faq, .risks, .environmentalCommitments]])
  }

  func testOutput_ConfigureNavigationSelectorUI_EmptyEnvironmentalCommitments() {
    self.vm.inputs.buttonTapped(index: 0)

    self.configureNavigationSelectorUI.assertDidNotEmitValue()

    self.vm.inputs.configureNavigationSelector(with: self.projectAndEmptyRefTag)

    self.configureNavigationSelectorUI.assertValues([[.overview, .faq, .risks]])
  }

  func testOutput_ConfigureNavigationSelectorUI_WithStoryOptimizelyFlagOn_ShowsCampaignTab() {
    var project = Project.template
    project.extendedProjectProperties = self.projectPropertiesWithEnvironmentalCommitments

    let optimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: true
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.buttonTapped(index: 0)

      self.configureNavigationSelectorUI.assertDidNotEmitValue()

      self.vm.inputs.configureNavigationSelector(with: (project, nil))

      self.configureNavigationSelectorUI
        .assertValues([[.overview, .campaign, .faq, .risks, .environmentalCommitments]])
    }
  }

  func testOutput_ConfigureNavigationSelectorUI_WithStoryOptimizelyFlagOff_DoesNotShowCampaignTab() {
    var project = Project.template
    project.extendedProjectProperties = self.projectPropertiesWithEnvironmentalCommitments

    let optimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.projectPageStoryTabEnabled.rawValue: false
      ]

    withEnvironment(optimizelyClient: optimizelyClient) {
      self.vm.inputs.buttonTapped(index: 0)

      self.configureNavigationSelectorUI.assertDidNotEmitValue()

      self.vm.inputs.configureNavigationSelector(with: (project, nil))

      self.configureNavigationSelectorUI.assertValues([[.overview, .faq, .risks, .environmentalCommitments]])
    }
  }

  func testOutput_notifyDelegateProjectNavigationSelectorDidSelect() {
    self.vm.inputs.configureNavigationSelector(with: self.projectAndEmptyRefTag)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0])

    self.vm.inputs.buttonTapped(index: 0)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0, 0])

    self.vm.inputs.buttonTapped(index: 3)

    self.notifyDelegateProjectNavigationSelectorDidSelect.assertValues([0, 0, 3])
  }

  func testOutput_updateNavigationSelectorUI() {
    self.vm.inputs.configureNavigationSelector(with: self.projectAndEmptyRefTag)

    self.updateNavigationSelectorUI.assertValues([0])

    self.vm.inputs.buttonTapped(index: 0)

    self.updateNavigationSelectorUI.assertValues([0, 0])

    self.vm.inputs.buttonTapped(index: 3)

    self.updateNavigationSelectorUI.assertValues([0, 0, 3])
  }

  func testOutput_TestSegmentTracking() {
    var project = Project.template
    project.extendedProjectProperties = self.projectPropertiesWithEnvironmentalCommitments

    self.vm.inputs.configureNavigationSelector(with: (project, nil))

    self.vm.inputs.buttonTapped(index: 0)

    self.scheduler.advance()

    XCTAssertTrue(self.segmentTrackingClient.events.isEmpty, "no tracking event")
    XCTAssertTrue(
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String }
        .isEmpty,
      "no tracking data"
    )

    self.vm.inputs.buttonTapped(index: 1)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events, "A project page event is tracked."
    )

    XCTAssertEqual(
      ["campaign"],
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String },
      "The tab selected is tracked in the event."
    )

    self.vm.inputs.buttonTapped(index: 2)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Page Viewed", "Page Viewed"],
      self.segmentTrackingClient.events, "A project page event is tracked."
    )

    XCTAssertEqual(
      ["campaign", "faq"],
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String },
      "The tab selected is tracked in the event."
    )

    self.vm.inputs.buttonTapped(index: 3)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Page Viewed", "Page Viewed", "Page Viewed"],
      self.segmentTrackingClient.events, "A project page event is tracked."
    )

    XCTAssertEqual(
      ["campaign", "faq", "risks"],
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String },
      "The tab selected is tracked in the event."
    )

    self.vm.inputs.buttonTapped(index: 4)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Page Viewed", "Page Viewed", "Page Viewed", "Page Viewed"],
      self.segmentTrackingClient.events, "A project page event is tracked."
    )

    XCTAssertEqual(
      ["campaign", "faq", "risks", "environment"],
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String },
      "The tab selected is tracked in the event."
    )

    self.vm.inputs.buttonTapped(index: 0)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Page Viewed", "Page Viewed", "Page Viewed", "Page Viewed", "Page Viewed"],
      self.segmentTrackingClient.events, "A project page event is tracked."
    )

    XCTAssertEqual(
      ["campaign", "faq", "risks", "environment", "overview"],
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String },
      "The tab selected is tracked in the event."
    )
  }

  func testOutput_TestSegmentTracking_DuplicateSameTabTapsNotTracked() {
    var project = Project.template
    project.extendedProjectProperties = self.projectPropertiesWithEnvironmentalCommitments

    self.vm.inputs.configureNavigationSelector(with: (project, nil))

    self.vm.inputs.buttonTapped(index: 0)
    self.vm.inputs.buttonTapped(index: 0)
    self.vm.inputs.buttonTapped(index: 0)
    self.vm.inputs.buttonTapped(index: 0)

    self.scheduler.advance()

    XCTAssertTrue(self.segmentTrackingClient.events.isEmpty, "no tracking event")
    XCTAssertTrue(
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String }
        .isEmpty,
      "no tracking data"
    )

    self.vm.inputs.buttonTapped(index: 1)
    self.vm.inputs.buttonTapped(index: 1)
    self.vm.inputs.buttonTapped(index: 1)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events, "A project page event is tracked."
    )

    XCTAssertEqual(
      ["campaign"],
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String },
      "The tab selected is tracked in the event."
    )

    self.vm.inputs.buttonTapped(index: 0)
    self.vm.inputs.buttonTapped(index: 0)
    self.vm.inputs.buttonTapped(index: 0)

    self.scheduler.advance()

    XCTAssertEqual(
      ["Page Viewed", "Page Viewed"],
      self.segmentTrackingClient.events, "A project page event is tracked."
    )

    XCTAssertEqual(
      ["campaign", "overview"],
      self.segmentTrackingClient.properties.compactMap { $0["context_section"] as? String },
      "The tab selected is tracked in the event."
    )
  }
}
