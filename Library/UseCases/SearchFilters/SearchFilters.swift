import Combine
import KsApi
import SwiftUI

/// A model that SwiftUI can use to display Search Filters modals.
///
/// Also creates `SearchFilterPill`s from the selected filters,
/// for the `SearchFiltersHeaderView`.
///
/// This object is read-only outside of the `Library-iOS` Framework.
/// `SearchFiltersUseCase` owns and updates this object.
public class SearchFilters: ObservableObject {
  public struct CategoryOptions {
    public var categories: [KsApi.Category]
    public var selectedCategory: SearchFiltersCategory
  }

  public struct SortOptions {
    public let sortOptions: [DiscoveryParams.Sort]
    public var selectedSort: DiscoveryParams.Sort
  }

  public struct ProjectStateOptions {
    public let stateOptions: [DiscoveryParams.State]
    public var selectedProjectState: DiscoveryParams.State
  }

  public struct PercentRaisedOptions {
    public let buckets: [DiscoveryParams.PercentRaisedBucket]
    public var selectedBucket: DiscoveryParams.PercentRaisedBucket?
  }

  public struct LocationOptions {
    public var defaultLocations: [Location]
    public var suggestedLocations: [Location]
    public var selectedLocation: Location?
  }

  public struct AmountRaisedOptions {
    public let buckets: [DiscoveryParams.AmountRaisedBucket]
    public var selectedBucket: DiscoveryParams.AmountRaisedBucket?
  }

  public struct GoalOptions {
    public let buckets: [DiscoveryParams.GoalBucket]
    public var selectedBucket: DiscoveryParams.GoalBucket?
  }

  public struct ShowOnlyOptions {
    public var recommended: Bool
    public var savedProjects: Bool
    public var projectsWeLove: Bool
    public var following: Bool
  }

  public private(set) var category: CategoryOptions
  public private(set) var sort: SortOptions
  public private(set) var projectState: ProjectStateOptions
  public private(set) var percentRaised: PercentRaisedOptions
  public private(set) var location: LocationOptions
  public private(set) var amountRaised: AmountRaisedOptions
  public private(set) var goal: GoalOptions
  public private(set) var showOnly: ShowOnlyOptions

  public fileprivate(set) var pills: [SearchFilterPill]

  public let objectWillChange = ObservableObjectPublisher()

  public var filterCount: Int {
    // Note that sort is a special case and is not included in
    // reset or the filter count functionality.
    [
      self.hasCategory,
      self.hasProjectState,
      self.hasPercentRaised,
      self.hasLocation,
      self.hasAmountRaised,
      self.hasGoal,
      self.showOnly.following,
      self.showOnly.projectsWeLove,
      self.showOnly.recommended,
      self.showOnly.savedProjects
    ]
    .count(where: { $0 == true })
  }

  public var hasFilters: Bool {
    self.filterCount > 0
  }

  var hasCategory: Bool {
    switch self.category.selectedCategory {
    case .none:
      return false
    case .rootCategory:
      return true
    case .subcategory:
      return true
    }
  }

  var hasProjectState: Bool {
    return self.projectState.selectedProjectState != SearchFiltersUseCase.defaultStateOption
  }

  var hasSort: Bool {
    return self.sort.selectedSort != SearchFiltersUseCase.defaultSortOption
  }

  var hasPercentRaised: Bool {
    return self.percentRaised.selectedBucket != nil
  }

  var hasLocation: Bool {
    return self.location.selectedLocation != nil
  }

  var hasAmountRaised: Bool {
    return self.amountRaised.selectedBucket != nil
  }

  var hasGoal: Bool {
    return self.goal.selectedBucket != nil
  }

  init(
    sort: SortOptions,
    category: CategoryOptions,
    projectState: ProjectStateOptions,
    percentRaised: PercentRaisedOptions,
    location: LocationOptions,
    amountRaised: AmountRaisedOptions,
    goal: GoalOptions,
    showOnly: ShowOnlyOptions
  ) {
    self.sort = sort
    self.category = category
    self.projectState = projectState
    self.percentRaised = percentRaised
    self.location = location
    self.amountRaised = amountRaised
    self.goal = goal
    self.showOnly = showOnly

    self.pills = []
    self.updatePills()
  }

  func update(
    withSort sort: DiscoveryParams.Sort,
    category: SearchFiltersCategory,
    projectState: DiscoveryParams.State,
    percentRaisedBucket: DiscoveryParams.PercentRaisedBucket?,
    location: Location?,
    amountRaisedBucket: DiscoveryParams.AmountRaisedBucket?,
    goalBucket: DiscoveryParams.GoalBucket?,
    toggles: SearchFilterToggles
  ) {
    self.objectWillChange.send()

    self.sort.selectedSort = sort
    self.category.selectedCategory = category
    self.projectState.selectedProjectState = projectState
    self.percentRaised.selectedBucket = percentRaisedBucket
    self.location.selectedLocation = location
    self.amountRaised.selectedBucket = amountRaisedBucket
    self.goal.selectedBucket = goalBucket
    self.showOnly.recommended = toggles.recommended
    self.showOnly.savedProjects = toggles.savedProjects
    self.showOnly.projectsWeLove = toggles.projectsWeLove
    self.showOnly.following = toggles.following

    self.updatePills()
  }

  func update(
    withCategories categories: [KsApi.Category]
  ) {
    self.objectWillChange.send()
    self.category.categories = categories
  }

  func update(
    withDefaultSearchLocations locations: [Location]
  ) {
    self.objectWillChange.send()
    self.location.defaultLocations = locations
  }

  func update(
    withSuggestedLocations locations: [Location]
  ) {
    self.objectWillChange.send()
    self.location.suggestedLocations = locations
  }

  public func has(filter type: SearchFilterModalType) -> Bool {
    switch type {
    case .allFilters:
      return self.hasFilters
    case .category:
      return self.hasCategory
    case .sort:
      return self.hasSort
    case .percentRaised:
      return self.hasPercentRaised
    case .location:
      return self.hasLocation
    case .amountRaised:
      return self.hasAmountRaised
    case .goal:
      return self.hasGoal
    }
  }

  public func canReset(filter type: SearchFilterModalType) -> Bool {
    return self.has(filter: type)
  }

  private func updatePills() {
    var pills: [SearchFilterPill] = []

    if let sortIcon = Library.image(named: "icon-sort")?.withRenderingMode(.alwaysTemplate) {
      pills.append(SearchFilterPill(
        isHighlighted: self.hasSort,
        filterType: .sort,
        buttonType: .image(sortIcon)
      ))
    }

    if let filterIcon = Library.image(named: "icon-filters")?.withRenderingMode(.alwaysTemplate) {
      pills.append(SearchFilterPill(
        isHighlighted: self.hasFilters,
        filterType: .allFilters,
        buttonType: .image(filterIcon),
        count: self.filterCount
      ))
    }

    let selectedCategory = self.category.selectedCategory.category
    let categoryPillTitle = selectedCategory?.name ?? Strings.Category()

    pills.append(SearchFilterPill(
      isHighlighted: self.hasCategory,
      filterType: .category,
      buttonType: .dropdown(categoryPillTitle)
    ))

    let projectStatePillTitle = self.hasProjectState ? self.projectState.selectedProjectState.title : Strings
      .Project_status()

    pills.append(
      SearchFilterPill(
        isHighlighted: self.hasProjectState,
        filterType: .projectState,
        buttonType: .dropdown(projectStatePillTitle)
      )
    )

    if featureSearchFilterByLocation() {
      let locationTitle = self.location.selectedLocation?.displayableName ?? Strings.Location()
      pills.append(
        SearchFilterPill(
          isHighlighted: self.hasLocation,
          filterType: .location,
          buttonType: .dropdown(locationTitle)
        )
      )
    }

    if featureSearchFilterByShowOnlyToggles() && AppEnvironment.current.currentUser.isSome {
      pills.append(
        SearchFilterPill(
          isHighlighted: self.showOnly.recommended,
          filterType: .recommended,
          buttonType: .toggle(Strings.Show_only_recommended_for_you())
        )
      )
    }

    let percentRaisedTitle = self.percentRaised.selectedBucket?.pillTitle ?? Strings.Percentage_raised()
    pills.append(
      SearchFilterPill(
        isHighlighted: self.hasPercentRaised,
        filterType: .percentRaised,
        buttonType: .dropdown(percentRaisedTitle)
      )
    )

    if featureSearchFilterByAmountRaised() {
      let amountRaisedTitle = self.amountRaised.selectedBucket?.pillTitle ?? Strings.Amount_raised()
      pills.append(
        SearchFilterPill(
          isHighlighted: self.hasAmountRaised,
          filterType: .amountRaised,
          buttonType: .dropdown(amountRaisedTitle)
        )
      )
    }

    if featureSearchFilterByShowOnlyToggles() {
      if let pwlIcon = Library.image(named: "icon-pwl") {
        pills.append(
          SearchFilterPill(
            isHighlighted: self.showOnly.projectsWeLove,
            filterType: .projectsWeLove,
            buttonType: .toggleWithImage(Strings.Show_only_projects_we_love(), pwlIcon)
          )
        )
      }

      if featureSearchFilterByGoal() {
        let goalTitle = self.goal.selectedBucket?.pillTitle ?? Strings.Goal()
        pills.append(
          SearchFilterPill(
            isHighlighted: self.hasGoal,
            filterType: .goal,
            buttonType: .dropdown(goalTitle)
          )
        )
      }

      if AppEnvironment.current.currentUser.isSome {
        pills.append(
          SearchFilterPill(
            isHighlighted: self.showOnly.savedProjects,
            filterType: .saved,
            buttonType: .toggle(Strings.Show_only_saved_pill_title())
          )
        )
        pills.append(
          SearchFilterPill(
            isHighlighted: self.showOnly.following,
            filterType: .following,
            buttonType: .toggle(Strings.Show_only_following())
          )
        )
      }
    }

    self.pills = pills
  }
}
