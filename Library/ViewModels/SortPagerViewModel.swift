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

  /// Emits an index that can be used to pin the indicator view to a particular button view.
  var pinSelectedIndicatorToPage: Signal<Int, NoError> { get }

  /// Emits an index of the selected button to update all button selected states.
  var setSelectedButton: Signal<Int, NoError> { get }

  /// Emits a category id to update style on sort change (e.g. filter selection).
  var updateSortStyle: Signal<(categoryId: Int?, sorts: [DiscoveryParams.Sort]), NoError> { get }
}

public protocol SortPagerViewModelType {
  var inputs: SortPagerViewModelInputs { get }
  var outputs: SortPagerViewModelOutputs { get }
}

public final class SortPagerViewModel: SortPagerViewModelType, SortPagerViewModelInputs,
SortPagerViewModelOutputs {

  public init() {
    let sorts = self.sortsProperty.signal.ignoreNil()

    self.createSortButtons = sorts

    let selectedPage = combineLatest(
      sorts,
      self.selectSortProperty.signal.ignoreNil()
      )
      .map { sorts, sort in (sorts.indexOf(sort) ?? 0, sorts.count) }
      .skipRepeats(==)

    self.notifyDelegateOfSelectedSort = combineLatest(
      sorts,
      self.sortButtonTappedIndexProperty.signal.ignoreNil()
      )
      .map { sorts, sortIndex in sorts[sortIndex] }

    self.updateSortStyle = Signal.merge(
      sorts.takeWhen(self.viewWillAppearProperty.signal).map { ($0, nil) }.take(1),
      sorts.takePairWhen(self.updateStyleProperty.signal)
      )
      .map { sorts, id in (categoryId: id, sorts: sorts) }

    let pageIndexOnViewWillAppear = self.viewWillAppearProperty.signal.mapConst(0).take(1)

    self.setSelectedButton = Signal.merge(
      pageIndexOnViewWillAppear,
      self.sortButtonTappedIndexProperty.signal.ignoreNil(),
      selectedPage.map { index, total in index }
    )

    self.pinSelectedIndicatorToPage =  Signal.merge(
      pageIndexOnViewWillAppear,
      selectedPage.map { page, _ in page }
    )
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
  public let pinSelectedIndicatorToPage: Signal<Int, NoError>
  public let setSelectedButton: Signal<Int, NoError>
  public let updateSortStyle: Signal<(categoryId: Int?, sorts: [DiscoveryParams.Sort]), NoError>

  public var inputs: SortPagerViewModelInputs { return self }
  public var outputs: SortPagerViewModelOutputs { return self }
}
