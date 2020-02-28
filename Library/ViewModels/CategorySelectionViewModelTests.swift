@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategorySelectionViewModelTests: TestCase {
  private let loadCategorySectionTitles = TestObserver<[String], Never>()
  private let loadCategorySectionData = TestObserver<[[(String, PillCellStyle)]], Never>()
  private let vm: CategorySelectionViewModelType = CategorySelectionViewModel()

  override func setUp() {
    super.setUp()

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

      XCTAssertEqual(3, self.loadCategorySectionData.lastValue?.count)
      XCTAssertEqual(["All Games Projects", "Tabletop Games"],
                     self.loadCategorySectionData.lastValue?[0].map { $0.0 })
      XCTAssertEqual(["All Art Projects", "Illustration"],
                     self.loadCategorySectionData.lastValue?[1].map { $0.0 })
      XCTAssertEqual(["All Film & Video Projects", "Documentary"],
                     self.loadCategorySectionData.lastValue?[2].map { $0.0 })
      XCTAssertEqual([PillCellStyle.grey, PillCellStyle.grey],
                     self.loadCategorySectionData.lastValue?.first?.map { $0.1 })
      XCTAssertEqual([PillCellStyle.grey, PillCellStyle.grey],
                     self.loadCategorySectionData.lastValue?[1].map { $0.1 })
      XCTAssertEqual([PillCellStyle.grey, PillCellStyle.grey],
                     self.loadCategorySectionData.lastValue?[2].map { $0.1 })
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

      XCTAssertEqual(4, self.loadCategorySectionData.lastValue?.count)
      XCTAssertEqual(["All Games Projects", "Tabletop Games"],
                     self.loadCategorySectionData.lastValue?[0].map { $0.0 })
      XCTAssertEqual(["All Art Projects", "Illustration"],
                     self.loadCategorySectionData.lastValue?[1].map { $0.0 })
      XCTAssertEqual(["All Film & Video Projects", "Documentary"],
                     self.loadCategorySectionData.lastValue?[2].map { $0.0 })
      XCTAssertEqual(["All Cool Stuff Projects", "Tabletop Games"],
                     self.loadCategorySectionData.lastValue?[3].map { $0.0 })

      XCTAssertEqual([PillCellStyle.grey, PillCellStyle.grey],
                     self.loadCategorySectionData.lastValue?.first?.map { $0.1 })
      XCTAssertEqual([PillCellStyle.grey, PillCellStyle.grey],
                     self.loadCategorySectionData.lastValue?[1].map { $0.1 })
      XCTAssertEqual([PillCellStyle.grey, PillCellStyle.grey],
                     self.loadCategorySectionData.lastValue?[2].map { $0.1 })
      XCTAssertEqual([PillCellStyle.grey, PillCellStyle.grey],
                     self.loadCategorySectionData.lastValue?[3].map { $0.1 })
    }
  }
}
