@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategorySelectionViewModelTests: TestCase {
  private let loadCategorySections = TestObserver<[KsApi.Category], Never>()

  private let vm: CategorySelectionViewModelType = CategorySelectionViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadCategorySections.observe(self.loadCategorySections.observer)
  }

  func testLoadCategorySections() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      .art,
      .games,
      .filmAndVideo
    ])

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.loadCategorySections.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCategorySections.assertValues([[.art, .games, .filmAndVideo]])
    }
  }
}
