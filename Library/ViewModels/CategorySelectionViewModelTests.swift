@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CategorySelectionViewModelTests: TestCase {
  private let continueButtonEnabled = TestObserver<Bool, Never>()
  private let dismiss = TestObserver<Void, Never>()
  private let goToCuratedProjects = TestObserver<[KsApi.Category], Never>()
  private let isLoading = TestObserver<Bool, Never>()
  private let loadCategorySectionTitles = TestObserver<[String], Never>()
  private let loadCategorySectionNames = TestObserver<[[String]], Never>()
  private let loadCategorySectionCategories = TestObserver<[[KsApi.Category]], Never>()
  private let postNotification = TestObserver<Notification, Never>()
  private let showErrorMessage = TestObserver<String, Never>()
  private let warningLabelIsHidden = TestObserver<Bool, Never>()
  private let vm: CategorySelectionViewModelType = CategorySelectionViewModel()

  override func setUp() {
    super.setUp()

    self.vm.outputs.continueButtonEnabled.observe(self.continueButtonEnabled.observer)
    self.vm.outputs.dismiss.observe(self.dismiss.observer)
    self.vm.outputs.goToCuratedProjects.observe(self.goToCuratedProjects.observer)
    self.vm.outputs.isLoading.observe(self.isLoading.observer)
    self.vm.outputs.loadCategorySections.map(first).observe(self.loadCategorySectionTitles.observer)
    self.vm.outputs.loadCategorySections.map(second).map { $0.map { $0.map { $0.0 } } }
      .observe(self.loadCategorySectionNames.observer)
    self.vm.outputs.loadCategorySections.map(second).map { $0.map { $0.map { $0.1 } } }
      .observe(self.loadCategorySectionCategories.observer)
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

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.loadCategorySectionTitles.assertDidNotEmitValue()
      self.loadCategorySectionNames.assertDidNotEmitValue()
      self.loadCategorySectionCategories.assertDidNotEmitValue()

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
      self.loadCategorySectionCategories.assertValues([
        [
          [.games, .tabletopGames],
          [.art, .illustration],
          [.filmAndVideo, .documentary]
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
      self.loadCategorySectionCategories.assertValues([
        [
          [.games, .tabletopGames],
          [.art, .illustration],
          [.filmAndVideo, .documentary],
          [unknownCategory, .tabletopGames]
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

      self.vm.inputs.categorySelected(with: (artIndexPath, .art))

      XCTAssertTrue(self.vm.outputs.shouldSelectCell(at: artIndexPath), "All Art Projects is selected")
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: illustrationIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: gamesIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: tabletopIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: filmAndVideoIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: documentaryIndexPath))

      self.vm.inputs.categorySelected(with: (artIndexPath, .art))

      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: artIndexPath), "All Art Projects is de-selected")
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: illustrationIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: gamesIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: tabletopIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: filmAndVideoIndexPath))
      XCTAssertFalse(self.vm.outputs.shouldSelectCell(at: documentaryIndexPath))

      // Select all categories
      self.vm.inputs.categorySelected(with: (artIndexPath, .art))
      self.vm.inputs.categorySelected(with: (illustrationIndexPath, .illustration))
      self.vm.inputs.categorySelected(with: (gamesIndexPath, .games))
      self.vm.inputs.categorySelected(with: (tabletopIndexPath, .tabletopGames))
      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, .filmAndVideo))
      self.vm.inputs.categorySelected(with: (documentaryIndexPath, .documentary))

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

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.continueButtonEnabled.assertValues([false], "Continue button disabled when 0 categories selected")

      self.scheduler.advance()

      self.continueButtonEnabled.assertValues([false])

      self.vm.inputs.categorySelected(with: (tabletopIndexPath, .tabletopGames))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (artIndexPath, .art))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (gamesIndexPath, .games))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (documentaryIndexPath, .documentary))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (illustrationIndexPath, .illustration))

      self.continueButtonEnabled.assertValues([false, true])

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, .filmAndVideo))

      self.continueButtonEnabled.assertValues(
        [false, true, false],
        "Continue button disabled when > 5 categories selected"
      )

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, .filmAndVideo))

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

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.warningLabelIsHidden.assertValues([true])

      self.scheduler.advance()

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (tabletopIndexPath, .tabletopGames))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (artIndexPath, .art))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (gamesIndexPath, .games))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (documentaryIndexPath, .documentary))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (illustrationIndexPath, .illustration))

      self.warningLabelIsHidden.assertValues([true])

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, .filmAndVideo))

      self.warningLabelIsHidden.assertValues(
        [true, false],
        "Warning label shown when > 5 categories selected"
      )

      self.vm.inputs.categorySelected(with: (filmAndVideoIndexPath, .filmAndVideo))

      self.warningLabelIsHidden.assertValues(
        [true, false, true],
        "Warning label hidden when < 5 categories selected"
      )
    }
  }

  func testGoToCuratedProjects() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      // sucbcat: .illustration
      .art,
      // subcat: .tabletop
      .games,
      // subcat: .documentary
      .filmAndVideo
    ])

    let mockKVStore = MockKeyValueStore()

    let artIndexPath = IndexPath(item: 0, section: 0)
    let illustrationIndexPath = IndexPath(item: 1, section: 0)
    let gamesIndexPath = IndexPath(item: 0, section: 1)

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService, userDefaults: mockKVStore) {
      self.vm.inputs.viewDidLoad()
      self.goToCuratedProjects.assertDidNotEmitValue()

      self.scheduler.advance()

      self.vm.inputs.categorySelected(with: (artIndexPath, .art))
      self.vm.inputs.categorySelected(with: (illustrationIndexPath, .illustration))
      self.vm.inputs.categorySelected(with: (gamesIndexPath, .games))

      XCTAssertNil(self.optimizelyClient.trackedEventKey)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)

      XCTAssertNil(mockKVStore.onboardingCategories)
      XCTAssertFalse(mockKVStore.hasCompletedCategoryPersonalizationFlow)

      self.vm.inputs.continueButtonTapped()

      self.goToCuratedProjects.assertValues([
        [.art, .games, .illustration]
      ])

      let categories: [KsApi.Category] = [.art, .games, .illustration]
      let encodedCategories = try? JSONEncoder().encode(categories)

      XCTAssertEqual(encodedCategories, mockKVStore.onboardingCategories)
      XCTAssertTrue(mockKVStore.hasCompletedCategoryPersonalizationFlow)

      XCTAssertEqual("Continue Button Clicked", self.optimizelyClient.trackedEventKey)
      XCTAssertEqual(["Onboarding Continue Button Clicked"], self.trackingClient.events)
      XCTAssertEqual(self.trackingClient.properties(forKey: "context_location"), ["onboarding"])
      assertBaseUserAttributesLoggedOut()
    }
  }

  func testPostNotification() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [
      .art
    ])

    let artIndexPath = IndexPath(item: 0, section: 0)
    let illustrationIndexPath = IndexPath(item: 1, section: 0)

    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.vm.inputs.categorySelected(with: (artIndexPath, .art))
      self.vm.inputs.categorySelected(with: (illustrationIndexPath, .illustration))

      self.postNotification.assertDidNotEmitValue()

      self.vm.inputs.continueButtonTapped()

      self.postNotification.assertValues([Notification(name: .ksr_onboardingCompleted)])
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

  func testDismiss() {
    let categoriesResponse = RootCategoriesEnvelope.init(rootCategories: [.art])
    let mockService = MockService(fetchGraphCategoriesResponse: categoriesResponse)

    withEnvironment(apiService: mockService) {
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.dismiss.assertDidNotEmitValue()

      XCTAssertNil(self.optimizelyClient.trackedEventKey)
      XCTAssertNil(self.optimizelyClient.trackedAttributes)

      self.vm.inputs.skipButtonTapped()

      self.dismiss.assertValueCount(1)

      XCTAssertEqual(self.optimizelyClient.trackedEventKey, "Skip Button Clicked")
      XCTAssertEqual(self.trackingClient.events, ["Onboarding Skip Button Clicked"])
      XCTAssertEqual(self.trackingClient.properties(forKey: "context_location"), ["onboarding"])
      assertBaseUserAttributesLoggedOut()
    }
  }
}
