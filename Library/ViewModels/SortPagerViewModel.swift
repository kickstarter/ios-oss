import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol SortPagerViewModelInputs {
  /// Call with the sorts that the view was configured with.
  func configureWith(sorts sorts: [DiscoveryParams.Sort])

  /// Call when a sort is selected from outside this view.
  func select(sort sort: DiscoveryParams.Sort)

  /// Call when a sort button is tapped.
  func sortButtonTapped(index index: Int)

  /// Call when to update the sort style.
  func updateStyle(categoryId categoryId: Int?)

  /// Call when view controller's viewWillAppear method is called.
  func viewWillAppear()
}

public protocol SortPagerViewModelOutputs {
  /// Emits a list of sorts that should be used to create sort buttons.
  var createSortButtons: Signal<[DiscoveryParams.Sort], NoError> { get }

  /// Emits a sort that should be passed on to the view's delegate.
  var notifyDelegateOfSelectedSort: Signal<DiscoveryParams.Sort, NoError> { get }

  /// Emits an index to pin the indicator view to a particular button view and whether to animate it.
  var pinSelectedIndicatorToPage: Signal<(Int, Bool), NoError> { get }

  /// Emits an index of the selected button to update all button selected states.
  var setSelectedButton: Signal<Int, NoError> { get }

  /// Emits a category id to update style on sort change (e.g. filter selection).
  var updateSortStyle: Signal<(categoryId: Int?, sorts: [DiscoveryParams.Sort], animated: Bool),
    NoError> { get }
}

public protocol SortPagerViewModelType {
  var inputs: SortPagerViewModelInputs { get }
  var outputs: SortPagerViewModelOutputs { get }
}

public final class SortPagerViewModel: SortPagerViewModelType, SortPagerViewModelInputs,
SortPagerViewModelOutputs {

  public init() {
    let sorts = self.sortsProperty.signal.ignoreNil()
      .takeWhen(self.viewWillAppearProperty.signal)

    self.createSortButtons = sorts.take(1)

    self.updateSortStyle = Signal.merge(
      sorts.map { ($0, nil, false) }.take(1),
      sorts.takePairWhen(self.updateStyleProperty.signal).map { ($0, $1, true) }
      )
      .map { sorts, id, animated in (categoryId: id, sorts: sorts, animated: animated) }

    let selectedPage = combineLatest(
      sorts,
      self.selectSortProperty.signal.ignoreNil()
      )
      .map { sorts, sort in (sorts.indexOf(sort) ?? 0, sorts.count) }
      .skipRepeats(==)

    let pageIndex = sorts.mapConst(0)

    self.setSelectedButton = Signal.merge(
      pageIndex.take(1),
      self.sortButtonTappedIndexProperty.signal.ignoreNil(),
      selectedPage.map { index, total in index }
    )

    self.pinSelectedIndicatorToPage =  Signal.merge(
      pageIndex.map { ($0, false) }.take(1),
      selectedPage.map { page, _ in (page, true) }
    )

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
  private let updateStyleProperty = MutableProperty<Int?>(nil)
  public func updateStyle(categoryId categoryId: Int?) {
    self.updateStyleProperty.value = categoryId
  }
  private let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let createSortButtons: Signal<[DiscoveryParams.Sort], NoError>
  public let notifyDelegateOfSelectedSort: Signal<DiscoveryParams.Sort, NoError>
  public let pinSelectedIndicatorToPage: Signal<(Int, Bool), NoError>
  public let setSelectedButton: Signal<Int, NoError>
  public let updateSortStyle: Signal<(categoryId: Int?, sorts: [DiscoveryParams.Sort], animated: Bool),
    NoError>

  public var inputs: SortPagerViewModelInputs { return self }
  public var outputs: SortPagerViewModelOutputs { return self }
}
