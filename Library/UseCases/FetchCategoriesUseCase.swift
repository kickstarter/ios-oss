import KsApi
import ReactiveSwift

public protocol FetchCategoriesUseCaseType {
  var uiOutputs: FetchCategoriesUseCaseUIOutputs { get }
  var dataOutputs: FetchCategoriesUseCaseDataOutputs { get }
}

public protocol FetchCategoriesUseCaseUIOutputs {
  /// Emits whether the categories are loading for the activity indicator view.
  var loadingIndicatorIsVisible: Signal<Bool, Never> { get }
}

public protocol FetchCategoriesUseCaseDataOutputs {
  /// Emits the list of categories, either from cache or from the network
  var categories: Signal<[Category], Never> { get }
}

public final class FetchCategoriesUseCase: FetchCategoriesUseCaseType, FetchCategoriesUseCaseUIOutputs,
  FetchCategoriesUseCaseDataOutputs {
  public var uiOutputs: FetchCategoriesUseCaseUIOutputs { return self }
  public var dataOutputs: FetchCategoriesUseCaseDataOutputs { return self }

  public init(initialSignal: Signal<Void, Never>) {
    let loaderIsVisible = MutableProperty(false)

    let cachedCats = initialSignal
      .map(cachedCategories)

    let categoriesEvent = cachedCats
      .filter { $0?.isEmpty != .some(false) }
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchGraphCategories()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(starting: {
            loaderIsVisible.value = true
          })
          .map { (envelope: RootCategoriesEnvelope) in envelope.rootCategories }
          .materialize()
      }

    self.loadingIndicatorIsVisible = Signal.merge(
      loaderIsVisible.signal,
      categoriesEvent.values().mapConst(false),
      categoriesEvent.errors().mapConst(false)
    )

    self.categories = Signal.merge(
      cachedCats.skipNil(),
      categoriesEvent.values()
    ).on(value: { cache(categories:) }())
  }

  public let loadingIndicatorIsVisible: Signal<Bool, Never>
  public let categories: Signal<[Category], Never>
}

private func cachedCategories() -> [KsApi.Category]? {
  return AppEnvironment.current
    .cache[KSCache.ksr_discoveryFiltersCategories] as? [KsApi.Category]
}

private func cache(categories: [KsApi.Category]) {
  AppEnvironment.current.cache[KSCache.ksr_discoveryFiltersCategories] = categories
}
