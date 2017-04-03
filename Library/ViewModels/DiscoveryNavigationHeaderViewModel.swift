import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

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
  var animateArrowToDown: Signal<Bool, NoError> { get }

  /// Emits opacity for arrow and whether to animate the change, used for launch transition.
  var arrowOpacityAnimated: Signal<(CGFloat, Bool), NoError> { get }

  /// Emits whether divider label is hidden.
  var dividerIsHidden: Signal<Bool, NoError> { get }

  /// Emits when the filters view controller should be dismissed.
  var dismissDiscoveryFilters: Signal<(), NoError> { get }

  /// Emits a11y label for favorite button.
  var favoriteButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits when favorite button should be enabled, e.g. when filters is closed.
  var favoriteViewIsDimmed: Signal<Bool, NoError> { get }

  /// Emits whether the favorite container view is hidden.
  var favoriteViewIsHidden: Signal<Bool, NoError> { get }

  /// Emits a category id to set gradient view color and whether the view is fullscreen.
  var gradientViewCategoryIdForColor: Signal<(categoryId: Int?, isFullScreen: Bool), NoError> { get }

  /// Emits params for Discovery view controller when filter selected.
  var notifyDelegateFilterSelectedParams: Signal<DiscoveryParams, NoError> { get }

  /// Emits to set the font for primary label and whether it should be bolded or not.
  var primaryLabelFont: Signal<Bool, NoError> { get }

  /// Emits an opacity for primary label and whether to animate the change.
  var primaryLabelOpacityAnimated: Signal<(CGFloat, Bool), NoError> { get }

  /// Emits text for filter label.
  var primaryLabelText: Signal<String, NoError> { get }

  /// Emits to show/hide subcategory label.
  var secondaryLabelIsHidden: Signal<Bool, NoError> { get }

  /// Emits text for subcategory label.
  var secondaryLabelText: Signal<String, NoError> { get }

  /// Emits when discovery filters view controller should be presented.
  var showDiscoveryFilters: Signal<SelectableRow, NoError> { get }

  /// Emits to show an onboarding alert for first time tapping the favorite button with the category name.
  var showFavoriteOnboardingAlert: Signal<String, NoError> { get }

  /// Emits a color for all subviews.
  var subviewColor: Signal<UIColor, NoError> { get }

  /// Emits a11y hint for title button.
  var titleButtonAccessibilityHint: Signal<String, NoError> { get }

  /// Emits a11y label for title button.
  var titleButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits to update heart to selected or not, with animation or not.
  var updateFavoriteButton: Signal<(selected: Bool, animated: Bool), NoError> { get }
}

public protocol DiscoveryNavigationHeaderViewModelType {
  var inputs: DiscoveryNavigationHeaderViewModelInputs { get }
  var outputs: DiscoveryNavigationHeaderViewModelOutputs { get }
}

public final class DiscoveryNavigationHeaderViewModel: DiscoveryNavigationHeaderViewModelType,
  DiscoveryNavigationHeaderViewModelInputs, DiscoveryNavigationHeaderViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let currentParams = Signal.merge(
      self.paramsProperty.signal.skipNil(),
      self.filtersSelectedRowProperty.signal.skipNil().map { $0.params }
    )

    let paramsAndFiltersAreHidden = Signal.merge(
      currentParams.map { ($0, false) },
      currentParams.takeWhen(self.titleButtonTappedProperty.signal).map { ($0, true) }
      )
      .scan(nil) { (data, paramsAndFiltersHidden) -> (params: DiscoveryParams, filtersAreHidden: Bool)? in
        let (params, filtersAreHidden) = paramsAndFiltersHidden
        return (params: params,
                filtersAreHidden: filtersAreHidden ? !(data?.filtersAreHidden ?? true) : true)
      }
      .skipNil()

    let strings = paramsAndFiltersAreHidden.map(first).map(stringsForTitle)
    let categoryId = paramsAndFiltersAreHidden.map(first).map { $0.category?.root?.id }
    let filtersAreHidden = paramsAndFiltersAreHidden.map(second)
    let primaryColor = categoryId.map { discoveryPrimaryColor(forCategoryId: $0) }

    self.animateArrowToDown = filtersAreHidden

    self.dividerIsHidden = strings
      .map { $0.subcategory == nil }
      .skipRepeats()

    self.favoriteViewIsHidden = paramsAndFiltersAreHidden.map(first)
      .map { $0.category == nil }
      .mergeWith(self.viewDidLoadProperty.signal.mapConst(true))
      .skipRepeats()

    self.favoriteViewIsDimmed = paramsAndFiltersAreHidden
      .filter { params, _ in params.category != nil }
      .map { _, filtersAreHidden in !filtersAreHidden }
      .skipRepeats()

    let dismissFiltersSignal = Signal.merge(
      self.filtersSelectedRowProperty.signal.ignoreValues(),
      paramsAndFiltersAreHidden.filter { $0.filtersAreHidden }.skip(first: 1).ignoreValues()
    )

    self.dismissDiscoveryFilters = dismissFiltersSignal
      .ksr_debounce(.milliseconds(400), on: AppEnvironment.current.scheduler)

    self.notifyDelegateFilterSelectedParams = currentParams.skip(first: 1)

    self.primaryLabelFont = paramsAndFiltersAreHidden
      .map { params, filtersAreHidden in
        ((params.category?.isRoot ?? true) && filtersAreHidden)
    }

    self.primaryLabelOpacityAnimated = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((0.0, false)),
      paramsAndFiltersAreHidden
        .map(first)
        .map { ($0.category?.isRoot == .some(false) ? 0.6 : 1.0, true) }
    )

    self.primaryLabelText = strings.map { $0.filter }

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

    self.subviewColor = primaryColor

    let isFullScreen = Signal.merge(
      self.paramsProperty.signal.skipNil().mapConst(false),
      self.showDiscoveryFilters.mapConst(true),
      dismissFiltersSignal.mapConst(false)
    )

    self.gradientViewCategoryIdForColor = Signal.combineLatest(categoryId, isFullScreen)
      .map { (categoryId: $0, isFullScreen: $1) }

    self.titleButtonAccessibilityHint = self.animateArrowToDown
      .map { $0 ? Strings.Opens_filters() : Strings.Closes_filters()
    }

    self.titleButtonAccessibilityLabel = paramsAndFiltersAreHidden
      .map(first)
      .map(accessibilityLabelForTitleButton)

    let categoryIdOnParamsUpdated = currentParams
      .map { $0.category?.id }
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
      .map { $0.selected ? Strings.discovery_favorite_categories_buttons_unfavorite_a11y_label() :
        Strings.discovery_favorite_categories_buttons_favorite_a11y_label() }

    self.showFavoriteOnboardingAlert = strings
      .map { $0.subcategory != nil
        ? Strings.category_name_subcategory_name_saved(
          category_name: $0.filter, subcategory_name: $0.subcategory ??  "")
        :  "\($0.filter) Saved"
      }
      .takeWhen(self.favoriteButtonTappedProperty.signal)
      .filter { _ in
        !AppEnvironment.current.ubiquitousStore.hasSeenFavoriteCategoryAlert ||
        !AppEnvironment.current.userDefaults.hasSeenFavoriteCategoryAlert
      }
      .on(value: { _ in
        AppEnvironment.current.ubiquitousStore.hasSeenFavoriteCategoryAlert = true
        AppEnvironment.current.userDefaults.hasSeenFavoriteCategoryAlert = true
      })

    currentParams
      .takePairWhen(categoryIdOnFavoriteTap.map(isFavoriteCategoryStored(withId:)))
      .observeValues {
        AppEnvironment.current.koala.trackDiscoveryFavoritedCategory(params: $0, isFavorited: $1)
    }

    paramsAndFiltersAreHidden
      .takeWhen(self.titleButtonTappedProperty.signal)
      .filter { $0.filtersAreHidden }
      .map { $0.params }
      .observeValues { AppEnvironment.current.koala.trackDiscoveryModalClosedFilter(params: $0) }
  }
  // swiftlint:enable function_body_length

  fileprivate let paramsProperty = MutableProperty<DiscoveryParams?>(nil)
  public func configureWith(params: DiscoveryParams) {
    self.paramsProperty.value = params
  }
  fileprivate let favoriteButtonTappedProperty = MutableProperty()
  public func favoriteButtonTapped() {
    self.favoriteButtonTappedProperty.value = ()
  }
  fileprivate let filtersSelectedRowProperty = MutableProperty<SelectableRow?>(nil)
  public func filtersSelected(row: SelectableRow) {
    self.filtersSelectedRowProperty.value = row
  }
  fileprivate let titleButtonTappedProperty = MutableProperty()
  public func titleButtonTapped() {
    self.titleButtonTappedProperty.value = ()
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let animateArrowToDown: Signal<Bool, NoError>
  public let arrowOpacityAnimated: Signal<(CGFloat, Bool), NoError>
  public let dividerIsHidden: Signal<Bool, NoError>
  public let dismissDiscoveryFilters: Signal<(), NoError>
  public let favoriteButtonAccessibilityLabel: Signal<String, NoError>
  public let favoriteViewIsDimmed: Signal<Bool, NoError>
  public let favoriteViewIsHidden: Signal<Bool, NoError>
  public let gradientViewCategoryIdForColor: Signal<(categoryId: Int?, isFullScreen: Bool), NoError>
  public let notifyDelegateFilterSelectedParams: Signal<DiscoveryParams, NoError>
  public let primaryLabelFont: Signal<Bool, NoError>
  public let primaryLabelOpacityAnimated: Signal<(CGFloat, Bool), NoError>
  public let primaryLabelText: Signal<String, NoError>
  public let secondaryLabelIsHidden: Signal<Bool, NoError>
  public let secondaryLabelText: Signal<String, NoError>
  public let showDiscoveryFilters: Signal<SelectableRow, NoError>
  public let showFavoriteOnboardingAlert: Signal<String, NoError>
  public let subviewColor: Signal<UIColor, NoError>
  public let titleButtonAccessibilityHint: Signal<String, NoError>
  public let titleButtonAccessibilityLabel: Signal<String, NoError>
  public let updateFavoriteButton: Signal<(selected: Bool, animated: Bool), NoError>

  public var inputs: DiscoveryNavigationHeaderViewModelInputs { return self }
  public var outputs: DiscoveryNavigationHeaderViewModelOutputs { return self }
}

private func stringsForTitle(params: DiscoveryParams) -> (filter: String, subcategory: String?) {
  let filterText: String
  var subcategoryText: String? = nil

  if params.staffPicks == true {
    filterText = Strings.Projects_We_Love()
  } else if params.hasLiveStreams == .some(true) {
    filterText = "Kickstarter Live"
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
      : Strings.Filter_by_subcategory_name_in_category_name(subcategory_name: category.name,
                                                            category_name: category.root?.name ?? "")
  } else if params.recommended == true {
    return Strings.Filter_by_projects_recommended_for_you()
  } else {
    return Strings.Filter_by_all_projects()
  }
}

private func string(forCategoryId id: Int) -> String {
  return RootCategory(categoryId: id).allProjectsString()
}

private func isFavoriteCategoryStored(withId id: Int) -> Bool {
  return AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.index(of: id) != nil ||
  AppEnvironment.current.userDefaults.favoriteCategoryIds.index(of: id) != nil
}

private func toggleStoredFavoriteCategory(withId id: Int) {
  if let index = AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.index(of: id) {
    AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.remove(at: index)
  } else {
    AppEnvironment.current.ubiquitousStore.favoriteCategoryIds.append(id)
  }

  if let index = AppEnvironment.current.userDefaults.favoriteCategoryIds.index(of: id) {
    AppEnvironment.current.userDefaults.favoriteCategoryIds.remove(at: index)
  } else {
    AppEnvironment.current.userDefaults.favoriteCategoryIds.append(id)
  }
}
