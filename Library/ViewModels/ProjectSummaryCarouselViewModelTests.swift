import Foundation
@testable import KsApi
import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class ProjectSummaryCarouselViewModelViewModelTests: TestCase {
  private let vm: ProjectSummaryCarouselViewModelType = ProjectSummaryCarouselViewModel()

  private let loadProjectSummaryItemsIntoDataSource
    = TestObserver<[ProjectSummaryEnvelope.ProjectSummaryItem], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadProjectSummaryItemsIntoDataSource
      .observe(self.loadProjectSummaryItemsIntoDataSource.observer)
  }

  func testLoadProjectSummaryItemsIntoDataSource() {
    self.loadProjectSummaryItemsIntoDataSource.assertDidNotEmitValue()

    let items = [
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatIsTheProject,
        response: "Test copy 1"
      ),
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatWillYouDoWithTheMoney,
        response: "Test copy 2"
      ),
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whoAreYou,
        response: "Test copy 3"
      )
    ]

    self.vm.inputs.configure(with: items)

    self.loadProjectSummaryItemsIntoDataSource.assertValues([items])
  }
}
