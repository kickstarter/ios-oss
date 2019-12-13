import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol DiscoveryNavigationHeaderViewModelInputs {
  /// Call to configure with Discovery params.
  func configureWith(params: DiscoveryParams)

  /// Call when favorite category button is tapped.
  func favoriteButtonTapped()

  /// Call when params have been selected from the filters menu.
  func filtersSelected(row: SelectableRow)

  /// Call when title button is tapped.
  func titleButtonTapped()

  /// Call when the view controller view loads.
  func viewDidLoad()
}

public protocol DiscoveryNavigationHeaderViewModelOutputs {
  /// Emits to animate arrow image down or up.
  var animateArrowToDown: Signal<Bool, Never> { get }

  /// Emits opacity for arrow and whether to animate the change, used for launch transition.
  var arrowOpacityAnimated: Signal<(CGFloat, Bool), Never> { get }

  /// Emits when debug container view should be shown/hidden, depending if build is Beta/Debug or Release.
  var debugContainerViewIsHidden: Signal<Bool, Never> { get }

  /// Emits when the debug image view should dim
  var debugImageViewIsDimmed: Signal<Bool, Never> { get }

  /// Emits whether divider label is hidden.
  var dividerIsHidden: Signal<Bool, Never> { get }

  /// Emits when the filters view controller should be dismissed.
  var dismissDiscoveryFilters: Signal<(), Never> { get }

  /// Emits when the Explore label should be shown/hidden after filter is selected.
  var exploreLabelIsHidden: Signal<Bool, Never> { get }

  /// Emits a11y label for favorite button.
  var favoriteButtonAccessibilityLabel: Signal<String, Never> { get }

  /// Emits when favorite button should be enabled, e.g. when filters is closed.
  var favoriteViewIsDimmed: Signal<Bool, Never> { get }

  /// Emits whether the favorite container view is hidden.
  var favoriteViewIsHidden: Signal<Bool, Never> { get }

  /// Emits params for Discovery view controller when filter selected.
  var notifyDelegateFilterSelectedParams: Signal<DiscoveryParams, Never> { get }

  /// Emits to set the font for primary label and whether it should be bolded or not.
  var primaryLabelFont: Signal<Bool, Never> { get }

  /// Emits an opacity for primary label and whether to animate the change.
  var primaryLabelOpacityAnimated: Signal<(CGFloat, Bool), Never> { get }

  /// Emits text for filter label.
  var primaryLabelText: Signal<String, Never> { get }

  /// Emits to show/hide subcategory label.
  var secondaryLabelIsHidden: Signal<Bool, Never> { get }

  /// Emits text for subcategory label.
  var secondaryLabelText: Signal<String, Never> { get }

  /// Emits when discovery filters view controller should be presented.
  var showDiscoveryFilters: Signal<SelectableRow, Never> { get }

  /// Emits to show an onboarding alert for first time tapping the favorite button with the category name.
  var showFavoriteOnboardingAlert: Signal<String, Never> { get }

  /// Emits a11y hint for title button.
  var titleButtonAccessibilityHint: Signal<String, Never> { get }

  /// Emits a11y label for title button.
  var titleButtonAccessibilityLabel: Signal<String, Never> { get }

  /// Emits to update heart to selected or not, with animation or not.
  var updateFavoriteButton: Signal<(selected: Bool, animated: Bool), Never> { get }
}

public protocol DiscoveryNavigationHeaderViewModelType {
  var inputs: DiscoveryNavigationHeaderViewModelInputs { get }
  var outputs: DiscoveryNavigationHeaderViewModelOutputs { get }
}

public final class DiscoveryNavigationHeaderViewModel: DiscoveryNavigationHeaderViewModelType,
  DiscoveryNavigationHeaderViewModelInputs, DiscoveryNavigationHeaderViewModelOutputs {
  public init() {
    let currentParams = Signal.merge(
      self.paramsProperty.signal.skipNil().skipRepeats(),
      self.filtersSelectedRowProperty.signal.skipNil().map { $0.params }
    )

    let paramsAndFiltersAreHidden = Signal.merge(
      currentParams.map { ($0, false) },
      currentParams.takeWhen(self.titleButtonTappedProperty.signal).map { ($0, true) }
    )
    .scan(nil) { (data, paramsAndFiltersHidden) -> (params: DiscoveryParams, filtersAreHidden: Bool)? in
      let (params, filtersAreHidden) = paramsAndFiltersHidden
      return (
        params: params,
        filtersAreHidden: filtersAreHidden ? !(data?.filtersAreHidden ?? true) : true
      )
    }
    .skipNil()

    let strings = paramsAndFiltersAreHidden.map(first).map(stringsForTitle)
    let filtersAreHidden = paramsAndFiltersAreHidden.map(second)

    self.animateArrowToDown = filtersAreHidden

    self.dividerIsHidden = strings
      .map { $0.subcategory == nil }
      .skipRepeats()

    self.exploreLabelIsHidden = self.filtersSelectedRowProperty.signal.map {
      shouldHideLabel($0?.params)
    }

    self.debugContainerViewIsHidden = self.viewDidLoadProperty.signal
      .map { DiscoveryNavigationHeaderViewModel.canShowBetaTools(environment: AppEnvironment.current) }
      .negate()

    self.favoriteViewIsHidden = paramsAndFiltersAreHidden.map(first)
      .map { $0.category == nil }
      .mergeWith(self.viewDidLoadProperty.signal.mapConst(true))
      .skipRepeats()

    self.favoriteViewIsDimmed = paramsAndFiltersAreHidden
      .filter { params, _ in params.category != nil }
      .map { _, filtersAreHidden in !filtersAreHidden }
      .skipRepeats()

    self.debugImageViewIsDimmed = self.debugContainerViewIsHidden
      .takePairWhen(filtersAreHidden)
      .filter { debugContainerIsHidden, _ in isFalse(debugContainerIsHidden) }
      .map(second)
      .negate()

    let dismissFiltersSignal = Signal.merge(
      self.filtersSelectedRowProperty.signal.ignoreValues(),
      paramsAndFiltersAreHidden.filter { $0.filtersAreHidden }.skip(first: 1).ignoreValues()
    )

    self.dismissDiscoveryFilters = dismissFiltersSignal
      .ksr_debounce(.milliseconds(400), on: AppEnvironment.current.scheduler)

    self.notifyDelegateFilterSelectedParams = currentParams.skip(first: 1)

    self.primaryLabelFont = paramsAndFiltersAreHidden
      .map { params, filtersAreHidden in
        (params.category?.isRoot ?? true) && filtersAreHidden
      }

    self.primaryLabelOpacityAnimated = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((0.0, false)),
      paramsAndFiltersAreHidden
        .map(first)
        .map { ($0.category?.isRoot == .some(false) ? 0.6 : 1.0, true) }
    )

    self.primaryLabelText = strings.map { filter in
      filter.filter
    }

    self.secondaryLabelIsHidden = strings
      .map { $0.subcategory == nil }
      .skipRepeats()

    self.secondaryLabelText = strings.map { $0.subcategory ?? "" }

    self.arrowOpacityAnimated = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((0.0, false)),
      self.secondaryLabelText.signal.mapConst((1.0, true)).take(first: 1)
    )

    let rowForFilters = Signal.merge(
      self.paramsProperty.signal.skipNil().map { SelectableRow(isSelected: true, params: $0) },
      self.filtersSelectedRowProperty.signal.skipNil()
    )

    self.showDiscoveryFilters = rowForFilters
      .takeWhen(paramsAndFiltersAreHidden.filter { !$0.filtersAreHidden })

    self.titleButtonAccessibilityHint = self.animateArrowToDown
      .map { $0 ? Strings.Opens_filters() : Strings.Closes_filters()
      }

    self.titleButtonAccessibilityLabel = paramsAndFiltersAreHidden
      .map(first)
      .map(accessibilityLabelForTitleButton)

    let categoryIdOnParamsUpdated = currentParams
      .map { $0.category?.intID }
      .skipNil()

    let categoryIdOnFavoriteTap = categoryIdOnParamsUpdated
      .takeWhen(self.favoriteButtonTappedProperty.signal)
      .on(value: { toggleStoredFavoriteCategory(withId: $0) })

    self.updateFavoriteButton = Signal.merge(
      categoryIdOnParamsUpdated.map { ($0, false) },
      categoryIdOnFavoriteTap.map { ($0, true) }
    )
    .map { id, animated in (selected: isFavoriteCategoryStored(withId: id), animated: animated) }

    self.favoriteButtonAccessibilityLabel = self.updateFavoriteButton
      .map {
        $0.selected
          ? Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label()
          : Strings.discovery_favorite_categories_buttons_favorite_a11y_label()
      }

    self.showFavoriteOnboardingAlert = strings
      .map { Strings.category_name_saved(category_name: $0.subcategory ?? $0.filter) }
      .takeWhen(self.favoriteButtonTappedProperty.signal)
      .filter { _ in
        !AppEnvironment.current.ubiquitousStore.hasSeenFavoriteCategoryAlert ||
          !AppEnvironment.current.userDefaults.hasSeenFavoriteCategoryAlert
      }
      .on(value: { _ in
        AppEnvironment.current.ubiquitousStore.hasSeenFavoriteCategoryAlert = true
        AppEnvironment.current.userDefaults.hasSeenFavoriteCategoryAlert = true
      })
  }

  fileprivate let paramsProperty = MutableProperty<DiscoveryParams?>(nil)
  public func configureWith(params: DiscoveryParams) {
    self.paramsProperty.value = params
  }

  fileprivate let favoriteButtonTappedProperty = MutableProperty(())
  public func favoriteButtonTapped() {
    self.favoriteButtonTappedProperty.value = ()
  }

  fileprivate let filtersSelectedRowProperty = MutableProperty<SelectableRow?>(nil)
  public func filtersSelected(row: SelectableRow) {
    self.filtersSelectedRowProperty.value = row
  }

  fileprivate let titleButtonTappedProperty = MutableProperty(())
  public func titleButtonTapped() {
    self.titleButtonTappedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private static func canShowBetaTools(environment: Environment) -> Bool {
    return environment.mainBundle.isAlpha || environment.mainBundle.isBeta || environment.mainBundle.isDebug
  }

  public let animateArrowToDown: Signal<Bool, Never>
  public let arrowOpacityAnimated: Signal<(CGFloat, Bool), Never>
  public let debugContainerViewIsHidden: Signal<Bool, Never>
  public let debugImageViewIsDimmed: Signal<Bool, Never>
  public let dismissDiscoveryFilters: Signal<(), Never>
  public let dividerIsHidden: Signal<Bool, Never>
  public let exploreLabelIsHidden: Signal<Bool, Never>
  public let favoriteButtonAccessibilityLabel: Signal<String, Never>
  public let favoriteViewIsDimmed: Signal<Bool, Never>
  public let favoriteViewIsHidden: Signal<Bool, Never>
  public let notifyDelegateFilterSelectedParams: Signal<DiscoveryParams, Never>
  public let primaryLabelFont: Signal<Bool, Never>
  public let primaryLabelOpacityAnimated: Signal<(CGFloat, Bool), Never>
  public let primaryLabelText: Signal<String, Never>
  public let secondaryLabelIsHidden: Signal<Bool, Never>
  public let secondaryLabelText: Signal<String, Never>
  public let showDiscoveryFilters: Signal<SelectableRow, Never>
  public let showFavoriteOnboardingAlert: Signal<String, Never>
  public let titleButtonAccessibilityHint: Signal<String, Never>
  public let titleButtonAccessibilityLabel: Signal<String, Never>
  public let updateFavoriteButton: Signal<(selected: Bool, animated: Bool), Never>

  public var inputs: DiscoveryNavigationHeaderViewModelInputs { return self }
  public var outputs: DiscoveryNavigationHeaderViewModelOutputs { return self }
}

private func shouldHideLabel(_ params: DiscoveryParams?) -> Bool {
  guard let params = params else { return true }

  return stringsForTitle(params: params).0 != Strings.All_Projects()
}

private func stringsForTitle(params: DiscoveryParams) -> (filter: String, subcategory: String?) {
  let filterText: String
  var subcategoryText: String?

  if params.staffPicks == true {
    filterText = Strings.Projects_We_Love()
  } else if params.starred == true {
    filterText = Strings.Saved()
  } else if params.social == true {
    filterText = Strings.Following()
  } else if let category = params.category {
    filterText = category.isRoot ? string(forCategoryId: category.id) : category.root?.name ?? ""
    subcategoryText = category.isRoot ? nil : category.name
  } else if params.recommended == true {
    filterText = Strings.Recommended_For_You()
  } else {
    filterText = Strings.All_Projects()
  }
  return (filter: filterText, subcategory: subcategoryText)
}

private func accessibilityLabelForTitleButton(params: DiscoveryParams) -> String {
  if params.staffPicks == true {
    return Strings.Filter_by_projects_we_love()
  } else if params.starred == true {
    return Strings.Filter_by_saved_projects()
  } else if params.social == true {
    return Strings.Filter_by_projects_backed_by_friends()
  } else if let category = params.category {
    return category.isRoot
      ? Strings.Filter_by_category_name(category_name: category.name)
      : Strings.Filter_by_subcategory_name_in_category_name(
        subcategory_name: category.name,
        category_name: category.root?.name ?? ""
      )
  } else if params.recommended == true {
    return Strings.Filter_by_projects_recommended_for_you()
  } else {
    return Strings.Filter_by_all_projects()
  }
}

private func string(forCategoryId id: String) -> String {
  return RootCategory(categoryId: id).allProjectsString()
}

private func isFavoriteCategoryStored(withId id: Int) -> Bool {
  return AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.firstIndex(of: id) != nil ||
    AppEnvironment.current.userDefaults.favoriteCategoryIds.firstIndex(of: id) != nil
}

private func toggleStoredFavoriteCategory(withId id: Int) {
  if let index = AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.firstIndex(of: id) {
    AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.remove(at: index)
  } else {
    AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.append(id)
  }

  if let index = AppEnvironment.current.userDefaults.favoriteCategoryIds.firstIndex(of: id) {
    AppEnvironment.current.userDefaults.favoriteCategoryIds.remove(at: index)
  } else {
    AppEnvironment.current.userDefaults.favoriteCategoryIds.append(id)
  }
}
