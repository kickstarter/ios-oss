@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategorySelectionViewModelTests: TestCase {
  private let continueButtonEnabled = TestObserver<Bool, Never>()
  private let goToCuratedProjects = TestObserver<[Int], Never>()
  private let isLoading = TestObserver<Bool, Never>()
  private let loadCategorySectionTitles = TestObserver<[String], Never>()
  private let loadCategorySectionNames = TestObserver<[[String]], Never>()
  private let loadCategorySectionCategoryIds = TestObserver<[[Int]], Never>()
  private let postNotification = TestObserver<Notification, Never>()
  private let showErrorMessage = TestObserver<String, Never>()
  private let warningLabelIsHidden = TestObserver<Bool, Never>()
  private let vm: CategorySelectionViewModelType = CategorySelectionViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.continueButtonEnabled.observe(self.continueButtonEnabled.observer)
    self.vm.outputs.goToCuratedProjects.observe(self.goToCuratedProjects.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.loadCategorySections.map(first).observe(self.loadCategorySectionTitles.observer)
    self.vm.outputs.loadCategorySections.map(second).map { $0.map { $0.map { $0.0 } } }
      .observe(self.loadCategorySectionNames.observer)
    self.vm.outputs.loadCategorySections.map(second).map { $0.map { $0.map { $0.1 } } }
      .observe(self.loadCategorySectionCategoryIds.observer)
    self.vm.outputs.postNotification.observe(self.postNotification.observer)
    self.vm.outputs.showErrorMessage.observe(self.showErrorMessage.observer)
    self.vm.outputs.warningLabelIsHidden.observe(self.warningLabelIsHidden.observer)
  }

  func testLoadCategorySections() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      .art,
      .games,
      .filmAndVideo
    ])

    let artId = Category.art.intID ?? 0
    let illustrationId = Category.illustration.intID ?? 0
    let gamesId = Category.games.intID ?? 0
    let tabletopId = Category.tabletopGames.intID ?? 0
    let filmAndVideoId = Category.filmAndVideo.intID ?? 0
    let documentaryId = Category.documentary.intID ?? 0

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.loadCategorySectionTitles.assertDidNotEmitValue()
      self.loadCategorySectionNames.assertDidNotEmitValue()
      self.loadCategorySectionCategoryIds.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCategorySectionTitles.assertValues([["Games", "Art", "Film & Video"]])
      self.loadCategorySectionNames.assertValues([
        [
          ["All Games Projects", "Tabletop Games"],
          ["All Art Projects", "Illustration"],
          ["All Film & Video Projects", "Documentary"]
        ]
      ])
      self.loadCategorySectionCategoryIds.assertValues([
        [
          [gamesId, tabletopId],
          [artId, illustrationId],
          [filmAndVideoId, documentaryId]
        ]
      ])
    }
  }

  func testLoadCategoriesSections_WithUnrecognizedCategoryId() {
    let unknownCategory = Category.games
      |> \.id .~ Category.tabletopGames.id
      |> \.name .~ "Cool Stuff"

    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      unknownCategory,
      .art,
      .games,
      .filmAndVideo
    ])

    let artId = Category.art.intID ?? 0
    let illustrationId = Category.illustration.intID ?? 0
    let gamesId = Category.games.intID ?? 0
    let tabletopId = Category.tabletopGames.intID ?? 0
    let filmAndVideoId = Category.filmAndVideo.intID ?? 0
    let documentaryId = Category.documentary.intID ?? 0
    let unknownId = Category.tabletopGames.intID ?? 0

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.loadCategorySectionTitles.assertDidNotEmitValue()
      self.loadCategorySectionNames.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCategorySectionTitles.assertValues([["Games", "Art", "Film & Video", "Cool Stuff"]])
      self.loadCategorySectionNames.assertValues([
        [
          ["All Games Projects", "Tabletop Games"],
          ["All Art Projects", "Illustration"],
          ["All Film & Video Projects", "Documentary"],
          ["All Cool Stuff Projects", "Tabletop Games"]
        ]
      ])
      self.loadCategorySectionCategoryIds.assertValues([
        [
          [gamesId, tabletopId],
          [artId, illustrationId],
          [filmAndVideoId, documentaryId],
          [unknownId, tabletopId]
        ]
      ])
    }
  }

  func testCategorySelected() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      // sucbcat: .illustration
      .art,
      // subcat: .tabletop
      .games,
      // subcat: .documentary
      .filmAndVideo
    ])

    let artIndexPath = IndexPath(item: 0, section: 0)
    let illustrationIndexPath = IndexPath(item: 1, section: 0)
    let gamesIndexPath = IndexPath(item: 0, section: 1)
    let tabletopIndexPath = IndexPath(item: 1, section: 1)
    let filmAndVideoIndexPath = IndexPath(item: 0, section: 2)
    let documentaryIndexPath = IndexPath(item: 1, section: 2)

    let artId = Category.art.intID ?? 0
    let illustrationId = Category.illustration.intID ?? 0
    let gamesId = Category.games.intID ?? 0
    let tabletopId = Category.tabletopGames.intID ?? 0
    let filmAndVideoId = Category.filmAndVideo.intID ?? 0
    let documentaryId = Category.documentary.intID ?? 0

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: artIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: illustrationIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: gamesIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: tabletopIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: filmAndVideoIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: documentaryIndexPath))

      self.vm.inputs.categorySelected(with: (artIndexPath, artId))

      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: artIndexPath), "All Art Projects is selected")
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: illustrationIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: gamesIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: tabletopIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: filmAndVideoIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: documentaryIndexPath))

      self.vm.inputs.categorySelected(with: (artIndexPath, artId))

      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: artIndexPath), "All Art Projects is de-selected")
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: illustrationIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: gamesIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: tabletopIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: filmAndVideoIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: documentaryIndexPath))

      // Select all categories
      self.vm.inputs.categorySelected(with: (artIndexPath, artId))
      self.vm.inputs.categorySelected(with: (illustrationIndexPath, illustrationId))
      self.vm.inputs.categorySelected(with: (gamesIndexPath, gamesId))
      self.vm.inputs.categorySelected(with: (tabletopIndexPath, tabletopId))
      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, filmAndVideoId))
      self.vm.inputs.categorySelected(with: (documentaryIndexPath, documentaryId))

      // All categories selected
      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: artIndexPath))
      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: illustrationIndexPath))
      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: gamesIndexPath))
      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: tabletopIndexPath))
      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: filmAndVideoIndexPath))
      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: documentaryIndexPath))
    }
  }

  func testContinueButtonEnabled() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      // sucbcat: .illustration
      .art,
      // subcat: .tabletop
      .games,
      // subcat: .documentary
      .filmAndVideo
    ])

    let artIndexPath = IndexPath(item: 0, section: 0)
    let illustrationIndexPath = IndexPath(item: 1, section: 0)
    let gamesIndexPath = IndexPath(item: 0, section: 1)
    let tabletopIndexPath = IndexPath(item: 1, section: 1)
    let filmAndVideoIndexPath = IndexPath(item: 0, section: 2)
    let documentaryIndexPath = IndexPath(item: 1, section: 2)

    let artId = Category.art.intID ?? 0
    let illustrationId = Category.illustration.intID ?? 0
    let gamesId = Category.games.intID ?? 0
    let tabletopId = Category.tabletopGames.intID ?? 0
    let filmAndVideoId = Category.filmAndVideo.intID ?? 0
    let documentaryId = Category.documentary.intID ?? 0

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.continueButtonEnabled.assertValues([false], "Continue button disabled when 0 categories selected")

      self.scheduler.advance()

      self.continueButtonEnabled.assertValues([false])

      self.vm.inputs.categorySelected(with: (tabletopIndexPath, tabletopId))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (artIndexPath, artId))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (gamesIndexPath, gamesId))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (documentaryIndexPath, documentaryId))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (illustrationIndexPath, illustrationId))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, filmAndVideoId))

      self.continueButtonEnabled.assertValues(
        [false, true, false],
        "Continue button disabled when > 5 categories selected"
      )

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, filmAndVideoId))

      self.continueButtonEnabled.assertValues(
        [false, true, false, true],
        "Continue button enabled when < 5 categories selected"
      )
    }
  }

  func testWarningLabelIsHidden() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      // sucbcat: .illustration
      .art,
      // subcat: .tabletop
      .games,
      // subcat: .documentary
      .filmAndVideo
    ])

    let artIndexPath = IndexPath(item: 0, section: 0)
    let illustrationIndexPath = IndexPath(item: 1, section: 0)
    let gamesIndexPath = IndexPath(item: 0, section: 1)
    let tabletopIndexPath = IndexPath(item: 1, section: 1)
    let filmAndVideoIndexPath = IndexPath(item: 0, section: 2)
    let documentaryIndexPath = IndexPath(item: 1, section: 2)

    let artId = Category.art.intID ?? 0
    let illustrationId = Category.illustration.intID ?? 0
    let gamesId = Category.games.intID ?? 0
    let tabletopId = Category.tabletopGames.intID ?? 0
    let filmAndVideoId = Category.filmAndVideo.intID ?? 0
    let documentaryId = Category.documentary.intID ?? 0

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.warningLabelIsHidden.assertValues([true])

      self.scheduler.advance()

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (tabletopIndexPath, tabletopId))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (artIndexPath, artId))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (gamesIndexPath, gamesId))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (documentaryIndexPath, documentaryId))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (illustrationIndexPath, illustrationId))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, filmAndVideoId))

      self.warningLabelIsHidden.assertValues(
        [true, false],
        "Warning label shown when > 5 categories selected"
      )

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, filmAndVideoId))

      self.warningLabelIsHidden.assertValues(
        [true, false, true],
        "Warning label hidden when < 5 categories selected"
      )
    }
  }

  func testGoToCuratedProjects_Emits_WhenContinueButtonIsTapped() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      // sucbcat: .illustration
      .art,
      // subcat: .tabletop
      .games,
      // subcat: .documentary
      .filmAndVideo
    ])

    let artIndexPath = IndexPath(item: 0, section: 0)
    let illustrationIndexPath = IndexPath(item: 1, section: 0)
    let gamesIndexPath = IndexPath(item: 0, section: 1)

    let artId = Category.art.intID ?? 0
    let illustrationId = Category.illustration.intID ?? 0
    let gamesId = Category.games.intID ?? 0

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.goToCuratedProjects.assertDidNotEmitValue()

      self.scheduler.advance()

      self.vm.inputs.categorySelected(with: (artIndexPath, artId))
      self.vm.inputs.categorySelected(with: (illustrationIndexPath, illustrationId))
      self.vm.inputs.categorySelected(with: (gamesIndexPath, gamesId))

      self.vm.inputs.continueButtonTapped()

      self.goToCuratedProjects.assertValues([
        [artId, gamesId, illustrationId]
      ])
    }
  }

  func testPostNotification() {
    let mockKVStore = MockKeyValueStore()

    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      .art
    ])

    let artIndexPath = IndexPath(item: 0, section: 0)
    let illustrationIndexPath = IndexPath(item: 1, section: 0)
    let artId = Category.art.intID ?? 0
    let illustrationId = Category.illustration.intID ?? 0

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService, userDefaults: mockKVStore) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.categorySelected(with: (artIndexPath, artId))
      self.vm.inputs.categorySelected(with: (illustrationIndexPath, illustrationId))

      self.postNotification.assertDidNotEmitValue()
      XCTAssertEqual([], mockKVStore.onboardingCategoryIds)
      XCTAssertFalse(mockKVStore.hasCompletedCategoryPersonalizationFlow)

      self.vm.inputs.continueButtonTapped()

      self.postNotification.assertValueCount(1)
      XCTAssertEqual([artId, illustrationId], mockKVStore.onboardingCategoryIds)
      XCTAssertTrue(mockKVStore.hasCompletedCategoryPersonalizationFlow)
    }
  }

  func testShowErrorMessage() {
    let mockService = MockService(fetchGraphCategoriesError: .invalidInput)

    withEnvironment(apiService: mockService) {
      self.showErrorMessage.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showErrorMessage.assertValue("Something went wrong.")
    }
  }

  func testIsLoading() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [.art])

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.isLoading.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.isLoading.assertValues([true])

      self.scheduler.advance()

      self.isLoading.assertValues([true, false])
    }
  }
}
