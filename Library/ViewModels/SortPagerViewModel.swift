import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol SortPagerViewModelInputs {
  /// Call with the sorts that the view was configured with.
  func configureWith(sorts: [DiscoveryParams.Sort])

  /// Call when the view controller's didRotateFromInterfaceOrientation method is called.
  func didRotateFromInterfaceOrientation()

  /// Call when a sort is selected from outside this view.
  func select(sort: DiscoveryParams.Sort)

  /// Call when a sort button is tapped.
  func sortButtonTapped(index: Int)

  /// Call when to update the sort style.
  func updateStyle(categoryId: Int?)

  /// Call when the view controller's willRotateToInterfaceOrientation method is called.
  func willRotateToInterfaceOrientation()

  /// Call when the view controller's viewDidAppear method is called.
  func viewDidAppear()

  /// Call when view controller's viewWillAppear method is called.
  func viewWillAppear()
}

public protocol SortPagerViewModelOutputs {
  /// Emits a list of sorts that should be used to create sort buttons.
  var createSortButtons: Signal<[DiscoveryParams.Sort], NoError> { get }

  /// Emits a bool whether the indicator view should be hidden, used for rotation.
  var indicatorViewIsHidden: Signal<Bool, NoError> { get }

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
    let sorts = self.sortsProperty.signal.skipNil()
      .takeWhen(self.viewWillAppearProperty.signal)

    self.createSortButtons = sorts.take(first: 1)

    self.updateSortStyle = Signal.merge(
      sorts.map { ($0, nil, false) }.take(first: 1),
      sorts.takePairWhen(self.updateStyleProperty.signal).map { ($0, $1, true) }
      )
      .map { sorts, id, animated in (categoryId: id, sorts: sorts, animated: animated) }

    let selectedPage = Signal.combineLatest(
      sorts,
      self.selectSortProperty.signal.skipNil()
      )
      .map { sorts, sort in (sorts.index(of: sort) ?? 0, sorts.count) }

    let pageIndex = sorts.mapConst(0)

    self.setSelectedButton = Signal.merge(
      pageIndex.take(first: 1),
      self.sortButtonTappedIndexProperty.signal.skipNil(),
      selectedPage.map { index, _ in index }
      )
      .skipRepeats(==)

    let selectedPageOnRotate = Signal.merge(pageIndex, selectedPage.map(first))
      .takeWhen(self.didRotateProperty.signal)

    self.pinSelectedIndicatorToPage =  Signal.merge(
      pageIndex
        .takeWhen(self.viewDidAppearProperty.signal)
        .take(first: 1)
        .map { ($0, false) },
      selectedPage
        .map { page, _ in (page, true) }
        .skipRepeats(==),
      selectedPageOnRotate
        .map { ($0, false) }
    )

    self.notifyDelegateOfSelectedSort = Signal.combineLatest(
      sorts.take(first: 1),
      self.sortButtonTappedIndexProperty.signal.skipNil()
      )
      .map { sorts, sortIndex in sorts[sortIndex] }

    self.indicatorViewIsHidden = Signal.merge(
      self.viewWillAppearProperty.signal
        .take(first: 1)
        .mapConst(true),
      self.viewDidAppearProperty.signal
        .take(first: 1)
        .mapConst(false)
        .ksr_debounce(.milliseconds(100), on: AppEnvironment.current.scheduler),
      self.willRotateProperty.signal.mapConst(true),
      self.didRotateProperty.signal
        .mapConst(false)
        .ksr_debounce(.milliseconds(100), on: AppEnvironment.current.scheduler)
    )
  }
  // swiftlint:enable function_body_length

  fileprivate let didRotateProperty = MutableProperty()
  public func didRotateFromInterfaceOrientation() {
    self.didRotateProperty.value = ()
  }
  fileprivate let sortsProperty = MutableProperty<[DiscoveryParams.Sort]?>(nil)
  public func configureWith(sorts: [DiscoveryParams.Sort]) {
    self.sortsProperty.value = sorts
  }
  fileprivate let selectSortProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func select(sort: DiscoveryParams.Sort) {
    self.selectSortProperty.value = sort
  }
  fileprivate let sortButtonTappedIndexProperty = MutableProperty<Int?>(nil)
  public func sortButtonTapped(index: Int) {
    self.sortButtonTappedIndexProperty.value = index
  }
  fileprivate let updateStyleProperty = MutableProperty<Int?>(nil)
  public func updateStyle(categoryId: Int?) {
    self.updateStyleProperty.value = categoryId
  }
  fileprivate let willRotateProperty = MutableProperty()
  public func willRotateToInterfaceOrientation() {
    self.willRotateProperty.value = ()
  }
  fileprivate let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  fileprivate let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let createSortButtons: Signal<[DiscoveryParams.Sort], NoError>
  public var indicatorViewIsHidden: Signal<Bool, NoError>
  public let notifyDelegateOfSelectedSort: Signal<DiscoveryParams.Sort, NoError>
  public let pinSelectedIndicatorToPage: Signal<(Int, Bool), NoError>
  public let setSelectedButton: Signal<Int, NoError>
  public let updateSortStyle: Signal<(categoryId: Int?, sorts: [DiscoveryParams.Sort], animated: Bool),
    NoError>

  public var inputs: SortPagerViewModelInputs { return self }
  public var outputs: SortPagerViewModelOutputs { return self }
}
