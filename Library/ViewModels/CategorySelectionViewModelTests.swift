@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategorySelectionViewModelTests: TestCase {
  private let goToCuratedProjects = TestObserver<Void, Never>()
  private let loadCategorySectionTitles = TestObserver<[String], Never>()
  private let loadCategorySectionData = TestObserver<[[String]], Never>()
  private let vm: CategorySelectionViewModelType = CategorySelectionViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToCuratedProjects.observe(self.goToCuratedProjects.observer)
    self.vm.outputs.loadCategorySections.map(first).observe(self.loadCategorySectionTitles.observer)
    self.vm.outputs.loadCategorySections.map(second).observe(self.loadCategorySectionData.observer)
  }

  func testLoadCategorySections() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      .art,
      .games,
      .filmAndVideo
    ])

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.loadCategorySectionTitles.assertDidNotEmitValue()
      self.loadCategorySectionData.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCategorySectionTitles.assertValues([["Games", "Art", "Film & Video"]])
      self.loadCategorySectionData.assertValues([
        [
          ["All Games Projects", "Tabletop Games"],
          ["All Art Projects", "Illustration"],
          ["All Film & Video Projects", "Documentary"]
        ]
      ])
    }
  }

  func testLoadCategoriesSections_WithUnrecognizedCategoryId() {
    let unknownCategory = Category.games
      |> \.id .~ "xyz"
      |> \.name .~ "Cool Stuff"

    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      unknownCategory,
      .art,
      .games,
      .filmAndVideo
    ])

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.loadCategorySectionTitles.assertDidNotEmitValue()
      self.loadCategorySectionData.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCategorySectionTitles.assertValues([["Games", "Art", "Film & Video", "Cool Stuff"]])
      self.loadCategorySectionData.assertValues([
        [
          ["All Games Projects", "Tabletop Games"],
          ["All Art Projects", "Illustration"],
          ["All Film & Video Projects", "Documentary"],
          ["All Cool Stuff Projects", "Tabletop Games"]
        ]
      ])
    }
  }

  func testGoToCuratedProjects_Emits_WhenContinueButtonIsTapped() {
    self.goToCuratedProjects.assertDidNotEmitValue()

    self.vm.inputs.continueButtonTapped()

    self.goToCuratedProjects.assertValueCount(1)
  }

  func testHasSeenCategoryPersonalizationFlowPropertyIsSet() {
    let mockKVStore = MockKeyValueStore()
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      .art,
      .games,
      .filmAndVideo
    ])

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService, userDefaults: mockKVStore) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      XCTAssertTrue(mockKVStore.hasSeenCategoryPersonalizationFlow)
    }
  }
}
