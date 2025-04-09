import KsApi
import Library
import Prelude
import ReactiveSwift
import SwiftUI
import UIKit

internal final class SearchViewController: UITableViewController {
  internal let viewModel: SearchViewModelType = SearchViewModel()
  fileprivate let dataSource = SearchDataSource()

  @IBOutlet fileprivate var cancelButton: UIButton!
  @IBOutlet fileprivate var centeringStackView: UIStackView!
  @IBOutlet fileprivate var innerSearchStackView: UIStackView!
  @IBOutlet fileprivate var searchBarContainerView: UIView!
  @IBOutlet fileprivate var searchIconImageView: UIImageView!
  @IBOutlet fileprivate var searchStackView: UIStackView!
  @IBOutlet fileprivate var searchStackViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var searchTextField: UITextField!
  @IBOutlet fileprivate var searchTextFieldHeightConstraint: NSLayoutConstraint!

  private let backgroundView = UIView()
  private let searchLoaderIndicator = UIActivityIndicatorView()
  private let showSortAndFilterHeader = MutableProperty<Bool>(false) // Bound to the view model property
  private var sortAndFilterHeader = FilterBadgeView<DiscoveryParams.Sort, KsApi.Category>(frame: .zero)

  internal static func instantiate() -> SearchViewController {
    return Storyboard.Search.instantiate(SearchViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.tableView.register(nib: .BackerDashboardProjectCell)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.cancelButton.addTarget(
      self,
      action: #selector(SearchViewController.cancelButtonPressed),
      for: .touchUpInside
    )

    self.searchTextField.addTarget(
      self,
      action: #selector(SearchViewController.searchTextChanged(_:)),
      for: .editingChanged
    )

    self.searchTextField.addTarget(
      self,
      action: #selector(SearchViewController.searchTextEditingDidEnd),
      for: .editingDidEndOnExit
    )

    self.searchBarContainerView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(SearchViewController.searchBarContainerTapped))
    )

    self.searchTextField.delegate = self

    self.sortAndFilterHeader.sortButton.addTarget(
      self,
      action: #selector(SearchViewController.sortButtonTapped),
      for: .touchUpInside
    )

    self.sortAndFilterHeader.categoryButton.addTarget(
      self,
      action: #selector(SearchViewController.categoryButtonTapped),
      for: .touchUpInside
    )

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 86)

    _ = [self.searchLoaderIndicator]
      ||> baseActivityIndicatorStyle

    _ = self.cancelButton
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_support_400
      |> UIButton.lens.titleLabel.font .~ .ksr_callout(size: 15)
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.discovery_search_cancel() }

    _ = self.searchBarContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .ksr_support_100

    _ = self.searchIconImageView
      |> UIImageView.lens.tintColor .~ .ksr_support_400
      |> UIImageView.lens.image .~ image(named: "search-icon")

    _ = self.searchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.innerSearchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.searchTextField
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.textColor .~ .ksr_support_400

    self.searchTextField.attributedPlaceholder = NSAttributedString(
      string: Strings.tabbar_search(),
      attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400]
    )

    _ = self.tableView
      |> UITableView.lens.keyboardDismissMode .~ .onDrag

    self.searchTextFieldHeightConstraint.constant = Styles.grid(5)
    self.searchStackViewWidthConstraint.constant = self.view.frame.size.width * 0.8

    self.tableView.sectionHeaderTopPadding = 0
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.projectsAndTitle
      .observeForUI()
      .observeValues { [weak self] showTitle, projects in
        self?.dataSource.load(projects: projects, withDiscoverTitle: showTitle)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.searchLoaderIndicatorIsAnimating
      .observeForUI()
      .observeValues { [weak self] isAnimating in
        guard let _self = self else { return }
        _self.tableView.tableHeaderView = isAnimating ? _self.searchLoaderIndicator : nil
        if let headerView = _self.tableView.tableHeaderView {
          headerView.frame = CGRect(
            x: headerView.frame.origin.x,
            y: headerView.frame.origin.y,
            width: headerView.frame.size.width,
            height: Styles.grid(15)
          )
        }
      }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeValues { [weak self] params, visible in
        self?.dataSource.load(params: params, visible: visible)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] projectId, refTag in
        self?.goTo(projectId: projectId, refTag: refTag)
      }

    self.searchTextField.rac.text = self.viewModel.outputs.searchFieldText
    self.searchTextField.rac.isFirstResponder = self.viewModel.outputs.resignFirstResponder.mapConst(false)

    self.searchLoaderIndicator.rac.animating = self.viewModel.outputs.searchLoaderIndicatorIsAnimating

    self.viewModel.outputs.changeSearchFieldFocus
      .observeForControllerAction() // NB: don't change this until we figure out the deadlock problem.
      .observeValues { [weak self] in
        self?.changeSearchFieldFocus(focus: $0, animated: $1)
      }

    self.viewModel.outputs.showSort
      .observeForControllerAction()
      .observeValues { [weak self] sheet in
        self?.showSort(sheet)
      }

    self.viewModel.outputs.showCategoryFilters
      .observeForControllerAction()
      .observeValues { [weak self] sheet in
        self?.showCategories(sheet)
      }

    self.showSortAndFilterHeader <~ self.viewModel.outputs.showSortAndFilterHeader

    self.viewModel.outputs.categoryPillTitle
      .observeForUI()
      .observeValues { [weak self] title in
        self?.sortAndFilterHeader.setCategoryTitle(title)
      }

    self.viewModel.outputs.isSortPillHighlighted
      .observeForUI()
      .observeValues { [weak self] highlighted in
        self?.sortAndFilterHeader.highlightSortButton(highlighted)
      }

    self.viewModel.outputs.isCategoryPillHighlighted
      .observeForUI()
      .observeValues { [weak self] highlighted in
        self?.sortAndFilterHeader.highlightCategoryButton(highlighted)
      }
  }

  fileprivate func present(sheet viewController: UIViewController, withHeight _: CGFloat) {
    let presenter = BottomSheetPresenter()
    presenter.present(viewController: viewController, from: self)
  }

  fileprivate func showSort(_ sheet: SearchSortSheet) {
    let sortViewModel = SortViewModel(
      sortOptions: sheet.sortOptions,
      selectedSortOption: sheet.selectedOption
    )

    let sortView = SortView(
      viewModel: sortViewModel,
      onSelectedSort: { [weak self] sortOption in
        self?.viewModel.inputs.selectedSortOption(sortOption)
      },
      onClosed: { [weak self] in
        self?.dismiss(animated: true)
      }
    )

    let hostingController = UIHostingController(rootView: sortView)
    self.present(sheet: hostingController, withHeight: sortView.dynamicHeight())
  }

  fileprivate func showCategories(_ sheet: SearchFilterCategoriesSheet) {
    let viewModel = FilterCategoryViewModel(with: sheet.categories)
    if let selectedCategory = sheet.selectedCategory {
      viewModel.selectCategory(selectedCategory)
    }

    let filterView = FilterCategoryView(
      viewModel: viewModel,
      onSelectedCategory: { [weak self] category in
        self?.viewModel.inputs.selectedCategory(category)
      },
      onResults: { [weak self] in
        self?.dismiss(animated: true)
      },
      onClose: { [weak self] in
        self?.dismiss(animated: true)
      }
    )

    let hostingController = UIHostingController(rootView: filterView)
    self.present(hostingController, animated: true)
  }

  fileprivate func goTo(projectId: Int, refTag: RefTag) {
    let projectParam = Either<Project, Param>(right: Param.id(projectId))
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: projectParam,
      refInfo: RefInfo(refTag)
    )

    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func changeSearchFieldFocus(focus: Bool, animated _: Bool) {
    if focus {
      self.cancelButton.isHidden = false

      self.centeringStackView.alignment = .fill

      if !self.searchTextField.isFirstResponder {
        self.searchTextField.becomeFirstResponder()
      }
    } else {
      self.cancelButton.isHidden = true

      self.centeringStackView.alignment = .center

      if self.searchTextField.isFirstResponder {
        self.searchTextField.resignFirstResponder()
      }
    }
  }

  internal override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.viewModel.inputs.tapped(projectAtIndex: indexPath.row)
  }

  internal override func tableView(
    _: UITableView,
    willDisplay _: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
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

    return self.sortAndFilterHeader
  }

  private var headerHeight: CGFloat? = nil
  override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard section == SearchDataSource.Section.projects.rawValue,
          self.showSortAndFilterHeader.value == true else {
      return 0
    }

    if self.headerHeight == nil {
      let fittingSize = self.sortAndFilterHeader.systemLayoutSizeFitting(self.view.bounds.size)
      self.headerHeight = fittingSize.height
    }

    return self.headerHeight ?? 0
  }

  @objc fileprivate func searchTextChanged(_ textField: UITextField) {
    self.viewModel.inputs.searchTextChanged(textField.text ?? "")
  }

  @objc fileprivate func searchTextEditingDidEnd() {
    self.viewModel.inputs.searchTextEditingDidEnd()
  }

  @objc fileprivate func cancelButtonPressed() {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @objc fileprivate func searchBarContainerTapped() {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }

  @objc fileprivate func sortButtonTapped() {
    self.viewModel.inputs.tappedSort()
  }

  @objc fileprivate func categoryButtonTapped() {
    self.viewModel.inputs.tappedCategoryFilter()
  }
}

extension SearchViewController: UITextFieldDelegate {
  internal func textFieldDidBeginEditing(_: UITextField) {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }

  internal func textFieldShouldClear(_: UITextField) -> Bool {
    self.viewModel.inputs.clearSearchText()
    return true
  }
}

extension SearchViewController: TabBarControllerScrollable {}
