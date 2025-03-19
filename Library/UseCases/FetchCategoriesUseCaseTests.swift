@testable import KsApi
import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FetchCategoriesUseCaseTests: TestCase {
  private var useCase: FetchCategoriesUseCase!
  private let categories = TestObserver<[KsApi.Category], Never>()
  private let loadingIndicatorIsVisible = TestObserver<Bool, Never>()
  private let (initialSignal, initialObserver) = Signal<Void, Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = FetchCategoriesUseCase(initialSignal: self.initialSignal)
    self.useCase.dataOutputs.categories.observe(self.categories.observer)
    self.useCase.uiOutputs.loadingIndicatorIsVisible.observe(self.loadingIndicatorIsVisible.observer)
  }

  override func tearDown() {
    super.tearDown()

    AppEnvironment.current.cache.removeAllObjects()
  }

  func test_emptyCache_fetchesCategories_AndShowsLoadingIndicator() {
    self.categories.assertDidNotEmitValue()
    self.loadingIndicatorIsVisible.assertDidNotEmitValue()

    let response = RootCategoriesEnvelope(rootCategories: [
      .art,
      .filmAndVideo,
      .illustration,
      .documentary
    ])

    withEnvironment(apiService: MockService(fetchGraphCategoriesResult: .success(response))) {
      self.initialObserver.send(value: ())

      self.loadingIndicatorIsVisible.assertLastValue(true, "Loading should start when categories are loading")
      self.categories.assertDidNotEmitValue()

      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

      XCTAssertEqual(self.categories.lastValue?.count, 4, "Categories in root category response should load")
      self.loadingIndicatorIsVisible.assertLastValue(false, "Loading should stop when categories are loaded")
    }
  }

  func test_cachedCategories_returnsCachedCategories() {
    self.categories.assertDidNotEmitValue()
    self.loadingIndicatorIsVisible.assertDidNotEmitValue()

    let cachedCategories = [
      Category.art,
      Category.filmAndVideo,
      Category.games
    ]

    AppEnvironment.current.cache[KSCache.ksr_discoveryFiltersCategories] = cachedCategories

    self.initialObserver.send(value: ())

    self.loadingIndicatorIsVisible.assertDidNotEmitValue()
    self.categories.assertDidEmitValue()
    XCTAssertEqual(self.categories.lastValue?.count, 3, "Categories should load directly from cache")
  }

  func test_fetchError_loadsCategories_WhenInitialSignalSentAgain() {
    self.categories.assertDidNotEmitValue()
    self.loadingIndicatorIsVisible.assertDidNotEmitValue()

    withEnvironment(apiService: MockService(fetchGraphCategoriesResult: .failure(
      ErrorEnvelope
        .couldNotParseErrorEnvelopeJSON
    ))) {
      self.initialObserver.send(value: ())

      self.loadingIndicatorIsVisible.assertLastValue(true, "Loading should start when categories are loading")
      self.categories.assertDidNotEmitValue()

      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

      self.categories.assertDidNotEmitValue()
      self.loadingIndicatorIsVisible.assertLastValue(false)
    }

    let response = RootCategoriesEnvelope(rootCategories: [
      .art,
      .filmAndVideo,
      .illustration,
      .documentary
    ])

    withEnvironment(apiService: MockService(fetchGraphCategoriesResult: .success(response))) {
      self.initialObserver.send(value: ())

      self.loadingIndicatorIsVisible.assertLastValue(true, "Loading should start when categories are loading")
      self.categories.assertDidNotEmitValue()

      self.scheduler.advance(by: AppEnvironment.current.apiDelayInterval)

      self.categories.assertDidEmitValue()
      self.loadingIndicatorIsVisible.assertLastValue(false)
    }
  }
}
