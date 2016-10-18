import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol SortPagerViewModelInputs {
  /// Call with the sorts that the view was configured with.
  func configureWith(sorts sorts: [DiscoveryParams.Sort])

  /// Call when the view controller's didRotateFromInterfaceOrientation method is called.
  func didRotateFromInterfaceOrientation()

  /// Call when a sort is selected from outside this view.
  func select(sort sort: DiscoveryParams.Sort)

  /// Call when a sort button is tapped.
  func sortButtonTapped(index index: Int)

  /// Call when to update the sort style.
  func updateStyle(categoryId categoryId: Int?)

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

  // swiftlint:disable function_body_length
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

    let pageIndex = sorts.mapConst(0)

    self.setSelectedButton = Signal.merge(
      pageIndex.take(1),
      self.sortButtonTappedIndexProperty.signal.ignoreNil(),
      selectedPage.map { index, total in index }
      )
      .skipRepeats(==)

    let selectedPageOnRotate = Signal.merge(pageIndex, selectedPage.map(first))
      .takeWhen(self.didRotateProperty.signal)

    self.pinSelectedIndicatorToPage =  Signal.merge(
      pageIndex
        .takeWhen(self.viewDidAppearProperty.signal)
        .take(1)
        .map { ($0, false) },
      selectedPage
        .map { page, _ in (page, true) }
        .skipRepeats(==),
      selectedPageOnRotate
        .map { ($0, false) }
    )

    self.notifyDelegateOfSelectedSort = combineLatest(
      sorts.take(1),
      self.sortButtonTappedIndexProperty.signal.ignoreNil()
      )
      .map { sorts, sortIndex in sorts[sortIndex] }

    self.indicatorViewIsHidden = Signal.merge(
      self.viewWillAppearProperty.signal
        .take(1)
        .mapConst(true),
      self.viewDidAppearProperty.signal
        .take(1)
        .mapConst(false)
        .ksr_debounce(0.1, onScheduler: AppEnvironment.current.scheduler),
      self.willRotateProperty.signal.mapConst(true),
      self.didRotateProperty.signal
        .mapConst(false)
        .ksr_debounce(0.1, onScheduler: AppEnvironment.current.scheduler)
    )
  }
  // swiftlint:enable function_body_length

  private let didRotateProperty = MutableProperty()
  public func didRotateFromInterfaceOrientation() {
    self.didRotateProperty.value = ()
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
  private let willRotateProperty = MutableProperty()
  public func willRotateToInterfaceOrientation() {
    self.willRotateProperty.value = ()
  }
  private let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  private let viewWillAppearProperty = MutableProperty()
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
