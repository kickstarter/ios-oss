import KsApi
import ReactiveCocoa
import Result

public protocol SortPagerViewModelInputs {
  /// Call with the sorts that the view was configured with.
  func configureWith(sorts sorts: [DiscoveryParams.Sort])

  /// Call when a sort is selected from outside this view.
  func select(sort sort: DiscoveryParams.Sort)

  /// Call when a sort button is tapped.
  func sortButtonTapped(index index: Int)
}

public protocol SortPagerViewModelOutputs {
  /// Emits a list of sorts that should be used to create sort buttons.
  var createSortButtons: Signal<[DiscoveryParams.Sort], NoError> { get }

  /// Emits a sort that should be passed on to the view's delegate.
  var notifyDelegateOfSelectedSort: Signal<DiscoveryParams.Sort, NoError> { get }

  /// Emits an index that can be used to pin the indicator view to a particular button view.
  var pinSelectedIndicatorToPage: Signal<Int, NoError> { get }

  /// Emits a value between 0 and 1 that should be used to scroll the scroll view to that percentage.
  var scrollPercentage: Signal<CGFloat, NoError> { get }
}

public protocol SortPagerViewModelType {
  var inputs: SortPagerViewModelInputs { get }
  var outputs: SortPagerViewModelOutputs { get }
}

public final class SortPagerViewModel: SortPagerViewModelType, SortPagerViewModelInputs,
SortPagerViewModelOutputs {

  public init() {
    let sorts = self.sortsProperty.signal.ignoreNil().take(1)

    self.createSortButtons = sorts

    let selectedPage = combineLatest(
      sorts,
      self.selectSortProperty.signal.ignoreNil()
      )
      .map { sorts, sort in (sorts.indexOf(sort) ?? 0, sorts.count) }
      .skipRepeats(==)

    self.scrollPercentage = selectedPage
      .map { page, total in CGFloat(page) / CGFloat(total - 1) }

    self.pinSelectedIndicatorToPage = selectedPage.map { page, _ in page }

    self.notifyDelegateOfSelectedSort = combineLatest(
      sorts,
      self.sortButtonTappedIndexProperty.signal.ignoreNil()
      )
      .map { sorts, sortIndex in sorts[sortIndex] }
  }

  private let sortsProperty = MutableProperty<[DiscoveryParams.Sort]?>(nil)
  public func configureWith(sorts sorts: [DiscoveryParams.Sort]) {
    self.sortsProperty.value = sorts
  }
  private let selectSortProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func select(sort sort: DiscoveryParams.Sort) {
    self.selectSortProperty.value = sort
  }
  private let sortButtonTappedIndexProperty = MutableProperty<Int?>(nil)
  public func sortButtonTapped(index index: Int) {
    self.sortButtonTappedIndexProperty.value = index
  }

  public let createSortButtons: Signal<[DiscoveryParams.Sort], NoError>
  public let notifyDelegateOfSelectedSort: Signal<DiscoveryParams.Sort, NoError>
  public let pinSelectedIndicatorToPage: Signal<Int, NoError>
  public let scrollPercentage: Signal<CGFloat, NoError>

  public var inputs: SortPagerViewModelInputs { return self }
  public var outputs: SortPagerViewModelOutputs { return self }
}
