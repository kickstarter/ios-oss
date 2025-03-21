import KsApi
import Library
import Prelude
import ReactiveSwift
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
  private let popularLoaderIndicator = UIActivityIndicatorView()
  private let searchLoaderIndicator = UIActivityIndicatorView()
  private let showSortAndFilterHeader = MutableProperty<Bool>(false) // Bound to the view model property
  private var currentSortAndFilterHeader: PlaceholderSortFilterView? = nil

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

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 86)

    _ = [self.searchLoaderIndicator, self.popularLoaderIndicator]
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
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.projects
      .observeForUI()
      .observeValues { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.isPopularTitleVisible
      .observeForUI()
      .observeValues { [weak self] visible in
        self?.dataSource.popularTitle(isVisible: visible)
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

    self.viewModel.outputs.popularLoaderIndicatorIsAnimating
      .observeForUI()
      .observeValues { [weak self] isAnimating in
        guard let _self = self else { return }
        _self.tableView.tableHeaderView = isAnimating ? _self.popularLoaderIndicator : nil
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
    self.popularLoaderIndicator.rac.animating = self.viewModel.outputs.popularLoaderIndicatorIsAnimating

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
  }

  fileprivate func showSort(_ sheet: SearchSortSheet) {
    let controller = UIAlertController(title: "Pick a sort", message: nil, preferredStyle: .actionSheet)

    for (idx, name) in sheet.sortNames.enumerated() {
      controller.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
        self.viewModel.inputs.selectedSortOption(atIndex: idx)
      }))
    }

    controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    controller.popoverPresentationController?.sourceView = self.currentSortAndFilterHeader

    present(controller, animated: true)
  }

  fileprivate func showCategories(_ sheet: SearchFilterCategoriesSheet) {
    let controller = UIAlertController(title: "Pick a category", message: nil, preferredStyle: .actionSheet)

    for (idx, name) in sheet.categoryNames.enumerated() {
      controller.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
        self.viewModel.inputs.selectedCategory(atIndex: idx)
      }))
    }

    controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    controller.popoverPresentationController?.sourceView = self.currentSortAndFilterHeader

    present(controller, animated: true)
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
    self.currentSortAndFilterHeader = nil

    guard section == SearchDataSource.Section.projects.rawValue,
          self.showSortAndFilterHeader.value == true else {
      return nil
    }

    let header = PlaceholderSortFilterView()
    header.sortButton.addTarget(
      self,
      action: #selector(SearchViewController.sortButtonTapped),
      for: .touchUpInside
    )
    header.categoryButton.addTarget(
      self,
      action: #selector(SearchViewController.categoryButtonTapped),
      for: .touchUpInside
    )

    self.currentSortAndFilterHeader = header

    return header
  }

  override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard section == SearchDataSource.Section.projects.rawValue,
          self.showSortAndFilterHeader.value == true else {
      return 0
    }

    return PlaceholderSortFilterView.headerHeight
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

// FIXME: MBL-2175. This will be a much nicer view. For now, a placeholder!
private class PlaceholderSortFilterView: UIView {
  static let headerHeight: CGFloat = 30.0
  internal var sortButton = UIButton()
  internal var categoryButton = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = .ksr_white

    self.sortButton.setTitle("Sort", for: .normal)
    self.sortButton.setTitleColor(.ksr_create_500, for: .normal)
    self.sortButton.setBackgroundColor(.ksr_white, for: .normal)
    self.sortButton.layer.borderColor = UIColor.ksr_create_100.cgColor
    self.sortButton.layer.borderWidth = 1.0
    self.sortButton.layer.cornerRadius = Self.headerHeight / 2

    self.categoryButton.setTitle("Category", for: .normal)
    self.categoryButton.setTitleColor(.ksr_create_500, for: .normal)
    self.categoryButton.setBackgroundColor(.ksr_white, for: .normal)
    self.categoryButton.layer.borderColor = UIColor.ksr_create_100.cgColor
    self.categoryButton.layer.borderWidth = 1.0
    self.categoryButton.layer.cornerRadius = Self.headerHeight / 2

    let stackView = UIStackView(arrangedSubviews: [self.sortButton, self.categoryButton])
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = Styles.grid(1)

    self.addSubview(stackView)
    let _ = ksr_constrainViewToEdgesInParent()(stackView, self)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    assert(false, "Unimplemented")
  }
}
