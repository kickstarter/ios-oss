import GraphAPI
import KsApi
import ReactiveSwift
import UIKit

public protocol SearchFiltersUseCaseType {
  var inputs: SearchFiltersUseCaseInputs { get }
  var uiOutputs: SearchFiltersUseCaseUIOutputs { get }
  var dataOutputs: SearchFiltersUseCaseDataOutputs { get }
}

public protocol SearchFiltersUseCaseInputs {
  /// Call this when the user taps on a button to show one of the sort options.
  func tappedButton(forFilterType: SearchFilterPill.FilterType)
  /// Call this when the clears their query and the sort options should reset.
  func clearedQueryText()
  /// Call this when the user updates a sort or filter option
  func selectedFilter(_ event: SearchFilterEvent)
  /// Call this when the user taps reset on a filter modal
  func resetFilters(for: SearchFilterModalType)
}

public protocol SearchFiltersUseCaseUIOutputs {
  /// Sends a model object which can be used to display all filter options, and a type describing which filters to display.
  var showFilters: Signal<SearchFilterModalType, Never> { get }

  /// An @ObservableObject model which SwiftUI can use to display the search filters modals and header.
  /// Owned and automatically updated by this `SearchFiltersUseCase`.
  var searchFilters: SearchFilters { get }
}

public protocol SearchFiltersUseCaseDataOutputs {
  /// The currently selected sort option. Defaults to `.popular`. Default value only sent after `initialSignal` occurs.
  var selectedSort: Signal<DiscoveryParams.Sort, Never> { get }
  /// The currently selected category. Defaults to nil. Default value only sent after `initialSignal` occurs.
  var selectedCategory: Signal<SearchFiltersCategory, Never> { get }
  /// The currently selected project state. Defaults to `.all`. Default value only sent after `initialSignal` occurs.
  var selectedState: Signal<DiscoveryParams.State, Never> { get }
  /// The currently selected percent raised bucket. Defaults to `nil`. Default value only sent after `initialSignal` occurs.
  var selectedPercentRaisedBucket: Signal<DiscoveryParams.PercentRaisedBucket?, Never> { get }
  /// The currently selected filter location. Defaults to `nil`. Default value only sent after `initialSignal` occurs.
  var selectedLocation: Signal<Location?, Never> { get }
  /// The currently selected amount raised bucket. Defaults to `nil`. Default value only sent after `initialSignal` occurs.
  var selectedAmountRaisedBucket: Signal<DiscoveryParams.AmountRaisedBucket?, Never> { get }
  /// The currently selected goal bucket. Defaults to `nil`. Default value only sent after `initialSignal` occurs.
  var selectedGoalBucket: Signal<DiscoveryParams.GoalBucket?, Never> { get }
  /// The currently selected 'Show Only' toggles. All toggles default to `false`. Default value only sent after `initialSignal` occurs.
  var selectedToggles: Signal<SearchFilterToggles, Never> { get }
}

public final class SearchFiltersUseCase: SearchFiltersUseCaseType, SearchFiltersUseCaseInputs,
  SearchFiltersUseCaseUIOutputs, SearchFiltersUseCaseDataOutputs {
  /// @param initialSignal - An initial signal pulse. Must be sent once for default values of `selectedSort` and `selectedCategory` to emit.
  /// @param categories - A list of possible filter categories. Must be sent for `showCategoryFilters` and `selectedSortOption` to work.

  public init(
    initialSignal: Signal<Void, Never>,
    categories: Signal<[KsApi.Category], Never>,
    defaultLocations: Signal<[KsApi.Location], Never>,
    suggestedLocations: Signal<[KsApi.Location], Never>
  ) {
    self.categoriesProperty <~ categories
    self.defaultLocationsProperty <~ defaultLocations
    self.suggestedLocationsProperty <~ suggestedLocations

    self.selectedSort = self.selectedSortProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedCategory = self.selectedCategoryProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedState = self.selectedStateProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedPercentRaisedBucket = self.selectedPercentRaisedBucketProperty
      .signal(takeInitialValueWhen: initialSignal)
    self.selectedLocation = self.selectedLocationProperty.signal(takeInitialValueWhen: initialSignal)
    self.selectedAmountRaisedBucket = self.selectedAmountRaisedBucketProperty
      .signal(takeInitialValueWhen: initialSignal)
    self.selectedGoalBucket = self.selectedGoalBucketProperty
      .signal(takeInitialValueWhen: initialSignal)

    self.selectedToggles = Signal.combineLatest(
      self.recommendedProperty.signal(takeInitialValueWhen: initialSignal),
      self.savedProjectsProperty.signal(takeInitialValueWhen: initialSignal),
      self.projectsWeLoveProperty.signal(takeInitialValueWhen: initialSignal),
      self.followingProperty.signal(takeInitialValueWhen: initialSignal)
    )
    .map { recommended, saved, pwl, following in
      SearchFilterToggles(
        recommended: recommended,
        savedProjects: saved,
        projectsWeLove: pwl,
        following: following
      )
    }

    self.searchFilters = SearchFilters(
      sort: SearchFilters.SortOptions(
        sortOptions: self.sortOptions,
        selectedSort: self.selectedSortProperty.value
      ),
      category: SearchFilters.CategoryOptions(
        categories: self.categoriesProperty.value,
        selectedCategory: self.selectedCategoryProperty.value
      ),
      projectState: SearchFilters.ProjectStateOptions(
        stateOptions: self.stateOptions,
        selectedProjectState: self.selectedStateProperty.value
      ),
      percentRaised: SearchFilters.PercentRaisedOptions(
        buckets: DiscoveryParams.PercentRaisedBucket.allCases
      ),
      location: SearchFilters.LocationOptions(
        defaultLocations: self.defaultLocationsProperty.value,
        suggestedLocations: self.suggestedLocationsProperty.value
      ),
      amountRaised: SearchFilters.AmountRaisedOptions(
        buckets: DiscoveryParams.AmountRaisedBucket.allCases
      ),
      goal: SearchFilters.GoalOptions(
        buckets: DiscoveryParams.GoalBucket.allCases
      ),
      showOnly: SearchFilters.ShowOnlyOptions(
        recommended: self.recommendedProperty.value,
        savedProjects: self.savedProjectsProperty.value,
        projectsWeLove: self.projectsWeLoveProperty.value,
        following: self.followingProperty.value
      )
    )

    let tappedTogglePill = self.tappedFilterTypeSignal.filter { $0.isToggle }
    let tappedModalPill = self.tappedFilterTypeSignal.filter { !$0.isToggle }

    self.showFilters = tappedModalPill
      .map { pill in
        let modalType = filterModal(toShowForPill: pill)
        return modalType
      }

    tappedTogglePill
      .observeValues { [weak self] pill in
        self?.toggleFilter(ofType: pill)
      }

    Signal.combineLatest(
      self.dataOutputs.selectedSort,
      self.dataOutputs.selectedCategory,
      self.dataOutputs.selectedState,
      self.dataOutputs.selectedPercentRaisedBucket,
      self.dataOutputs.selectedLocation,
      self.dataOutputs.selectedAmountRaisedBucket,
      self.dataOutputs.selectedGoalBucket,
      self.dataOutputs.selectedToggles
    )
    .observeForUI()
    .observeValues { [
      weak searchFilters
    ] sort, category, state, percentRaisedBucket, location, amountRaisedBucket, goalBucket, toggles in
      searchFilters?.update(
        withSort: sort,
        category: category,
        projectState: state,
        percentRaisedBucket: percentRaisedBucket,
        location: location,
        amountRaisedBucket: amountRaisedBucket,
        goalBucket: goalBucket,
        toggles: toggles
      )
    }

    self.categoriesProperty
      .signal
      .observeForUI()
      .observeValues { [weak searchFilters] categories in
        searchFilters?.update(withCategories: categories)
      }

    self.defaultLocationsProperty
      .signal
      .observeForUI()
      .observeValues { [weak searchFilters] locations in
        searchFilters?.update(withDefaultSearchLocations: locations)
      }

    self.suggestedLocationsProperty
      .signal
      .observeForUI()
      .observeValues { [weak searchFilters] locations in
        searchFilters?.update(withSuggestedLocations: locations)
      }
  }

  fileprivate let (tappedFilterTypeSignal, tappedFilterTypeObserver) = Signal<
    SearchFilterPill.FilterType,
    Never
  >
  .pipe()
  public func tappedButton(forFilterType type: SearchFilterPill.FilterType) {
    self.tappedFilterTypeObserver.send(value: type)
  }

  fileprivate let selectedSortProperty = MutableProperty<DiscoveryParams.Sort>(
    SearchFiltersUseCase
      .defaultSortOption
  )
  fileprivate let selectedCategoryProperty = MutableProperty<SearchFiltersCategory>(.none)
  fileprivate let selectedStateProperty = MutableProperty<DiscoveryParams.State>(
    SearchFiltersUseCase
      .defaultStateOption
  )
  fileprivate let selectedPercentRaisedBucketProperty =
    MutableProperty<DiscoveryParams.PercentRaisedBucket?>(nil)
  fileprivate let selectedLocationProperty = MutableProperty<Location?>(nil)
  fileprivate let selectedAmountRaisedBucketProperty =
    MutableProperty<DiscoveryParams.AmountRaisedBucket?>(nil)
  fileprivate let selectedGoalBucketProperty = MutableProperty<DiscoveryParams.GoalBucket?>(nil)

  fileprivate let categoriesProperty = MutableProperty<[KsApi.Category]>([])
  fileprivate let defaultLocationsProperty = MutableProperty<[KsApi.Location]>([])
  fileprivate let suggestedLocationsProperty = MutableProperty<[KsApi.Location]>([])

  fileprivate let recommendedProperty = MutableProperty<Bool>(false)
  fileprivate let savedProjectsProperty = MutableProperty<Bool>(false)
  fileprivate let projectsWeLoveProperty = MutableProperty<Bool>(false)
  fileprivate let followingProperty = MutableProperty<Bool>(false)

  internal static let defaultSortOption = DiscoveryParams.Sort.magic

  fileprivate let sortOptions = [
    DiscoveryParams.Sort.magic, // aka Recommended
    DiscoveryParams.Sort.popular,
    DiscoveryParams.Sort.newest,
    DiscoveryParams.Sort.endingSoon,
    DiscoveryParams.Sort.most_funded,
    DiscoveryParams.Sort.most_backed
  ]

  internal static let defaultStateOption = DiscoveryParams.State.all

  fileprivate let stateOptions = [
    DiscoveryParams.State.all,
    DiscoveryParams.State.live,
    DiscoveryParams.State.late_pledge,
    DiscoveryParams.State.upcoming,
    DiscoveryParams.State.successful
  ]

  public let showFilters: Signal<SearchFilterModalType, Never>

  public let selectedSort: Signal<DiscoveryParams.Sort, Never>
  public let selectedCategory: Signal<SearchFiltersCategory, Never>
  public let selectedState: Signal<DiscoveryParams.State, Never>
  public let selectedPercentRaisedBucket: Signal<DiscoveryParams.PercentRaisedBucket?, Never>
  public let selectedLocation: Signal<Location?, Never>
  public let selectedAmountRaisedBucket: Signal<DiscoveryParams.AmountRaisedBucket?, Never>
  public let selectedGoalBucket: Signal<DiscoveryParams.GoalBucket?, Never>
  public let selectedToggles: Signal<SearchFilterToggles, Never>

  public private(set) var searchFilters: SearchFilters

  public func clearedQueryText() {
    self.resetFilters(for: .allFilters)
    self.resetFilters(for: .sort)
  }

  public func resetFilters(for modal: SearchFilterModalType) {
    switch modal {
    case .allFilters:
      // Sort isn't a filter, so it's not included here.
      self.selectedCategoryProperty.value = .none
      self.selectedStateProperty.value = SearchFiltersUseCase.defaultStateOption
      self.selectedPercentRaisedBucketProperty.value = nil
      self.selectedLocationProperty.value = nil
      self.selectedAmountRaisedBucketProperty.value = nil
      self.selectedGoalBucketProperty.value = nil
      self.followingProperty.value = false
      self.recommendedProperty.value = false
      self.projectsWeLoveProperty.value = false
      self.savedProjectsProperty.value = false
    case .category:
      self.selectedCategoryProperty.value = .none
    case .sort:
      self.selectedSortProperty.value = SearchFiltersUseCase.defaultSortOption
    case .percentRaised:
      self.selectedPercentRaisedBucketProperty.value = nil
    case .location:
      self.selectedLocationProperty.value = nil
    case .amountRaised:
      self.selectedAmountRaisedBucketProperty.value = nil
    case .goal:
      self.selectedGoalBucketProperty.value = nil
    }
  }

  public func selectedFilter(_ event: SearchFilterEvent) {
    switch event {
    case let .sort(sort):
      self.selectedSortProperty.value = sort
    case let .category(selectedCategory):
      self.selectedCategoryProperty.value = selectedCategory
    case let .projectState(state):
      self.selectedStateProperty.value = state
    case let .percentRaised(bucket):
      self.selectedPercentRaisedBucketProperty.value = bucket
    case let .amountRaised(bucket):
      self.selectedAmountRaisedBucketProperty.value = bucket
    case let .goal(bucket):
      self.selectedGoalBucketProperty.value = bucket
    case let .location(location):
      self.selectedLocationProperty.value = location
    case let .recommended(showRecommended):
      self.recommendedProperty.value = showRecommended
    case let .savedProjects(showSavedProjects):
      self.savedProjectsProperty.value = showSavedProjects
    case let .projectsWeLove(showProjectsWeLove):
      self.projectsWeLoveProperty.value = showProjectsWeLove
    case let .following(showFollowing):
      self.followingProperty.value = showFollowing
    }
  }

  internal func toggleFilter(ofType type: SearchFilterPill.FilterType) {
    switch type {
    case .projectsWeLove:
      let pwl = self.projectsWeLoveProperty.value
      self.selectedFilter(.projectsWeLove(!pwl))
    case .saved:
      let saved = self.savedProjectsProperty.value
      self.selectedFilter(.savedProjects(!saved))
    case .following:
      let following = self.followingProperty.value
      self.selectedFilter(.following(!following))
    case .recommended:
      let recommended = self.recommendedProperty.value
      self.selectedFilter(.recommended(!recommended))
    default:
      assert(false, "Only boolean filter types can be toggled directly from the pill bar header.")
    }
  }

  public var inputs: SearchFiltersUseCaseInputs { return self }
  public var uiOutputs: SearchFiltersUseCaseUIOutputs { return self }
  public var dataOutputs: SearchFiltersUseCaseDataOutputs { return self }
}

private func filterModal(toShowForPill pill: SearchFilterPill.FilterType) -> SearchFilterModalType {
  let modalType: SearchFilterModalType
  switch pill {
  case .allFilters:
    modalType = .allFilters
  case .category:
    modalType = .category
  case .sort:
    modalType = .sort
  case .projectState:
    modalType = .allFilters
  case .percentRaised:
    modalType = .percentRaised
  case .location:
    modalType = .location
  case .amountRaised:
    modalType = .amountRaised
  case .goal:
    modalType = .goal
  case .projectsWeLove:
    modalType = .allFilters
  case .saved:
    modalType = .allFilters
  case .following:
    modalType = .allFilters
  case .recommended:
    modalType = .allFilters
  }
  return modalType
}

public enum SearchFilterModalType: Hashable, CaseIterable {
  case allFilters
  case category
  case sort
  case percentRaised
  case location
  case amountRaised
  case goal
}

public enum SearchFilterEvent {
  case sort(DiscoveryParams.Sort)
  case category(SearchFiltersCategory)
  case projectState(DiscoveryParams.State)
  case percentRaised(DiscoveryParams.PercentRaisedBucket)
  case amountRaised(DiscoveryParams.AmountRaisedBucket)
  case goal(DiscoveryParams.GoalBucket)
  case location(Location?)
  case recommended(Bool)
  case savedProjects(Bool)
  case projectsWeLove(Bool)
  case following(Bool)
}

public struct SearchFilterToggles {
  public var recommended: Bool
  public var savedProjects: Bool
  public var projectsWeLove: Bool
  public var following: Bool
}

private extension GraphAPI.LocationsByTermQuery.Data.Locations {}

private extension MutableProperty {
  /// Emits its current value when `takeInitialValueWhen` is sent, and whenever the value changes, too.
  /// Useful for turning a `MutableProperty` with a default value into a `signal`.
  func signal(takeInitialValueWhen initialSignal: Signal<Void, Never>) -> Signal<Value, Never> {
    return Signal.merge(
      self.producer.takeWhen(initialSignal),
      self.signal
    )
  }
}
