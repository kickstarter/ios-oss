import KsApi
import Library
import Prelude
import ReactiveSwift
import SwiftUI
import UIKit

private enum Constants {
  static let searchBarWidthFactor = 0.9
  static let estimatedRowHeight = 86.0
  static let footerViewHeight = Styles.grid(15)
  static let searchBarHeight = Styles.grid(8)
}

internal final class SearchViewController: UITableViewController {
  internal let viewModel: SearchViewModelType = SearchViewModel()
  fileprivate let dataSource = SearchDataSource()

  @IBOutlet fileprivate var searchBarContainerView: UIView!

  private lazy var searchBar = { KSRSearchBar() }()
  private var searchBarWidthConstraint: NSLayoutConstraint?

  private let backgroundView = UIView()
  private let searchLoaderIndicator = UIActivityIndicatorView()
  private let showSortAndFilterHeader = MutableProperty<Bool>(false) // Bound to the view model property

  private var sortAndFilterHeader: UIViewController?

  private var searchBarWidth: CGFloat {
    return self.view.bounds.width * Constants.searchBarWidthFactor
  }

  internal static func instantiate() -> SearchViewController {
    return Storyboard.Search.instantiate(SearchViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: Constants.estimatedRowHeight)

    // Hides the bottom border (shadow) of the navigation bar to visually give the search bar more space
    self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
    self.navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = .clear

    _ = [self.searchLoaderIndicator]
      ||> baseActivityIndicatorStyle

    _ = self.tableView
      |> UITableView.lens.keyboardDismissMode .~ .onDrag

    self.searchBarWidthConstraint?.constant = self.searchBarWidth

    self.tableView.sectionHeaderTopPadding = 0
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.searchResults
      .observeForUI()
      .observeValues { [weak self] results in
        self?.dataSource.load(results: results)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.searchLoaderIndicatorIsAnimating
      .observeForUI()
      .observeValues { [weak self] isAnimating in
        guard let _self = self else { return }
        _self.tableView.tableFooterView = isAnimating ? _self.searchLoaderIndicator : nil
        if let footerView = _self.tableView.tableFooterView {
          footerView.frame = CGRect(
            x: footerView.frame.origin.x,
            y: footerView.frame.origin.y,
            width: footerView.frame.size.width,
            height: Constants.footerViewHeight
          )
        }
      }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeValues { [weak self] params, visible in
        if featureSearchNewEmptyState() {
          let data = SearchEmptyStateSearchData(
            query: params.query,
            hasFilters: self?.viewModel.outputs.searchFilters.hasFilters == true
          )
          self?.dataSource.load(data: data, visible: visible)
        } else {
          self?.dataSource.load(params: params, visible: visible)
        }
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] projectId, refTag in
        self?.goTo(projectId: projectId, refTag: refTag)
      }

    self.searchLoaderIndicator.rac.animating = self.viewModel.outputs.searchLoaderIndicatorIsAnimating

    self.viewModel.outputs.showFilters
      .observeForControllerAction()
      .observeValues { [weak self] type in
        if type == .sort {
          // Sort is a special case modal, not part of the root filter view.
          self?.showSort()
          return
        }

        // All other filters go to the same modal.
        self?.showFilters(filterType: type)
      }

    self.showSortAndFilterHeader <~ self.viewModel.outputs.showSortAndFilterHeader
  }

  fileprivate func present(sheet viewController: UIViewController, withHeight _: CGFloat) {
    let presenter = BottomSheetPresenter()
    presenter.present(viewController: viewController, from: self)
  }

  private func configureSubviews() {
    self.tableView.dataSource = self.dataSource

    self.tableView.register(nib: .BackerDashboardProjectCell)
    self.tableView.registerCellClass(SearchResultsCountCell.self)
    self.tableView.registerCellClass(SearchEmptyStateCell.self)

    self.viewModel.inputs.viewDidLoad()

    let pillView = SelectedSearchFiltersHeaderView(
      selectedFilters: self.viewModel.outputs.searchFilters,
      didTapPill: { [weak self] pill in
        self?.viewModel.inputs.tappedButton(forFilterType: pill.filterType)
      }
    )

    let sortAndFilterHeader = UIHostingController(rootView: pillView)
    self.addChild(sortAndFilterHeader)

    self.sortAndFilterHeader = sortAndFilterHeader

    self.searchBar.onTextChange = { [weak self] query in
      self?.viewModel.inputs.searchTextChanged(query)
    }

    self.searchBarContainerView.addSubview(self.searchBar)
  }

  private func setupConstraints() {
    self.searchBar.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.searchBar.leadingAnchor.constraint(equalTo: self.searchBarContainerView.leadingAnchor),
      self.searchBar.trailingAnchor.constraint(equalTo: self.searchBarContainerView.trailingAnchor),
      self.searchBar.topAnchor.constraint(equalTo: self.searchBarContainerView.topAnchor, constant: 2.0),
      self.searchBar.bottomAnchor.constraint(equalTo: self.searchBarContainerView.bottomAnchor)
    ])

    // Set initial width based on current view bounds; updated later in `bindStyles` if needed
    self.searchBarWidthConstraint = self.searchBar.widthAnchor
      .constraint(equalToConstant: self.searchBarWidth)

    NSLayoutConstraint.activate([
      self.searchBar.heightAnchor.constraint(equalToConstant: Constants.searchBarHeight),
      self.searchBarWidthConstraint!
    ])
  }

  fileprivate func showSort() {
    let sortViewModel = SortViewModel(
      sortOptions: self.viewModel.outputs.searchFilters.sort.sortOptions,
      selectedSortOption: self.viewModel.outputs.searchFilters.sort.selectedSort
    )

    let sortView = SortView(
      viewModel: sortViewModel,
      onSelectedSort: { [weak self] sortOption in
        self?.viewModel.inputs.selectedFilter(.sort(sortOption))
      },
      onClosed: { [weak self] in
        self?.dismiss(animated: true)
      }
    )

    let hostingController = UIHostingController(rootView: sortView)
    self.present(sheet: hostingController, withHeight: sortView.dynamicHeight())
  }

  fileprivate func showFilters(filterType: SearchFilterModalType) {
    var filterView = FilterRootView(
      filterType: filterType,
      searchFilters: self.viewModel.outputs.searchFilters
    )
    filterView.onFilter = { [weak self] filterEvent in
      self?.viewModel.inputs.selectedFilter(filterEvent)
    }
    filterView.onSearchedForLocations = { [weak self] locationQuery in
      self?.viewModel.inputs.searchedForLocations(locationQuery)
    }
    filterView.onReset = { [weak self] type in
      self?.viewModel.inputs.resetFilters(for: type)
    }
    filterView.onResults = { [weak self] in
      self?.dismiss(animated: true)
    }
    filterView.onClose = { [weak self] in
      self?.dismiss(animated: true)
    }
    let hostingController = UIHostingController(rootView: filterView)
    self.present(hostingController, animated: true)
  }

  fileprivate func goTo(projectId: Int, refTag: RefTag) {
    let projectParam = Either<Project, any ProjectPageParam>(right: Param.id(projectId))
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: projectParam,
      refInfo: RefInfo(refTag)
    )

    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  internal override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let project = self.dataSource.indexOfProject(forCellAtIndexPath: indexPath) {
      self.viewModel.inputs.tapped(projectAtIndex: project)
    }
  }

  internal override func tableView(
    _: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    if let cell = cell as? SearchEmptyStateCell, cell.delegate == nil {
      cell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }

  override func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == SearchDataSource.Section.projects.rawValue,
          self.showSortAndFilterHeader.value == true else {
      return nil
    }

    return self.sortAndFilterHeader?.view
  }

  private var headerHeight: CGFloat? = nil
  override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard section == SearchDataSource.Section.projects.rawValue,
          self.showSortAndFilterHeader.value == true else {
      return 0
    }

    if self.headerHeight == nil,
       let fittingSize = self.sortAndFilterHeader?.view.systemLayoutSizeFitting(self.view.bounds.size) {
      self.headerHeight = fittingSize.height
    }

    return self.headerHeight ?? 0
  }
}

extension SearchViewController: TabBarControllerScrollable {}

// MARK: - SearchEmptyStateCellDelegate

extension SearchViewController: SearchEmptyStateCellDelegate {
  func searchEmptyStateCellDidTapRemoveAllFiltersButton(
    _: SearchEmptyStateCell
  ) {
    self.viewModel.inputs.resetFilters(for: .allFilters)
  }
}
