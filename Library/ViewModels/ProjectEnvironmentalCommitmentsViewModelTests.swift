@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ProjectEnvironmentalCommitmentsViewModelTests: TestCase {
  fileprivate let vm: ProjectEnvironmentalCommitmentsViewModelType =
    ProjectEnvironmentalCommitmentsViewModel()

  fileprivate let loadEnvironmentalCommitments = TestObserver<[ProjectEnvironmentalCommitment], Never>()
  fileprivate let showHelpWebViewController = TestObserver<HelpType, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.loadEnvironmentalCommitments.observe(self.loadEnvironmentalCommitments.observer)
    self.vm.outputs.showHelpWebViewController.observe(self.showHelpWebViewController.observer)
  }

  func testOutput_loadEnvironmentalCommitments() {
    let environmentalCommitments = [
      ProjectEnvironmentalCommitment(
        description: "foo bar",
        category: .environmentallyFriendlyFactories,
        id: 0
      ),
      ProjectEnvironmentalCommitment(description: "hello world", category: .longLastingDesign, id: 1),
      ProjectEnvironmentalCommitment(
        description: "Lorem ipsum",
        category: .reusabilityAndRecyclability,
        id: 2
      ),
      ProjectEnvironmentalCommitment(description: "blah blah blah", category: .sustainableDistribution, id: 3)
    ]

    self.vm.inputs.configureWith(environmentalCommitments: environmentalCommitments)

    self.loadEnvironmentalCommitments.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.loadEnvironmentalCommitments.assertDidEmitValue()
  }

  func testOutput_ShowHelpWebViewController() {
    let environmentalCommitments = [
      ProjectEnvironmentalCommitment(
        description: "foo bar",
        category: .environmentallyFriendlyFactories,
        id: 0
      ),
      ProjectEnvironmentalCommitment(description: "hello world", category: .longLastingDesign, id: 1),
      ProjectEnvironmentalCommitment(
        description: "Lorem ipsum",
        category: .reusabilityAndRecyclability,
        id: 2
      ),
      ProjectEnvironmentalCommitment(description: "blah blah blah", category: .sustainableDistribution, id: 3)
    ]
    let url = URL(string: "https://www.kickstarter.com/environment")!

    self.vm.inputs.configureWith(environmentalCommitments: environmentalCommitments)

    self.showHelpWebViewController.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.showHelpWebViewController.assertDidNotEmitValue()

    self.vm.inputs.projectEnvironmentalCommitmentFooterCellDidTapURL(url)

    self.showHelpWebViewController.assertValues([.environment])
  }

  func testOutput_ShowHelpWebViewController_FaultyURL() {
    let environmentalCommitments = [
      ProjectEnvironmentalCommitment(
        description: "foo bar",
        category: .environmentallyFriendlyFactories,
        id: 0
      ),
      ProjectEnvironmentalCommitment(description: "hello world", category: .longLastingDesign, id: 1),
      ProjectEnvironmentalCommitment(
        description: "Lorem ipsum",
        category: .reusabilityAndRecyclability,
        id: 2
      ),
      ProjectEnvironmentalCommitment(description: "blah blah blah", category: .sustainableDistribution, id: 3)
    ]
    let url = URL(string: "https://www.foobar.com/")!

    self.vm.inputs.configureWith(environmentalCommitments: environmentalCommitments)

    self.showHelpWebViewController.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.showHelpWebViewController.assertDidNotEmitValue()

    self.vm.inputs.projectEnvironmentalCommitmentFooterCellDidTapURL(url)

    self.showHelpWebViewController.assertDidNotEmitValue()
  }
}
