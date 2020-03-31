import Foundation
import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class ProjectSummaryCarouselViewModelViewModelTests: TestCase {
  private let vm: ProjectSummaryCarouselViewModelType = ProjectSummaryCarouselViewModel()

  private let loadProjectSummaryItemsIntoDataSource = TestObserver<[ProjectSummaryItem], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadProjectSummaryItemsIntoDataSource
      .observe(self.loadProjectSummaryItemsIntoDataSource.observer)
  }

  func testLoadProjectSummaryItemsIntoDataSource() {
    self.loadProjectSummaryItemsIntoDataSource.assertDidNotEmitValue()

    let items: [ProjectSummaryItem] = [1, 2, 3]

    self.vm.inputs.configure(with: items)

    self.loadProjectSummaryItemsIntoDataSource.assertValues([items])
  }
}
