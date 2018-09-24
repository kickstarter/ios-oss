import KsApi
import Library
import Prelude
import UIKit

internal final class SearchViewController: UITableViewController {
  internal let viewModel: SearchViewModelType = SearchViewModel()
  fileprivate let dataSource = SearchDataSource()

  @IBOutlet fileprivate weak var cancelButton: UIButton!
  @IBOutlet fileprivate weak var centeringStackView: UIStackView!
  @IBOutlet fileprivate weak var innerSearchStackView: UIStackView!
  @IBOutlet fileprivate weak var searchBarContainerView: UIView!
  @IBOutlet fileprivate weak var searchIconImageView: UIImageView!
  @IBOutlet fileprivate weak var searchStackView: UIStackView!
  @IBOutlet fileprivate weak var searchStackViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var searchTextField: UITextField!
  @IBOutlet fileprivate weak var searchTextFieldHeightConstraint: NSLayoutConstraint!

  private let backgroundView = UIView()
  private let popularLoaderIndicator = UIActivityIndicatorView()
  private let searchLoaderIndicator = UIActivityIndicatorView()

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

    self.cancelButton.addTarget(self,
                                action: #selector(cancelButtonPressed),
                                for: .touchUpInside)

    self.searchTextField.addTarget(self,
                                   action: #selector(searchTextChanged(_:)),
                                   for: .editingChanged)

    self.searchTextField.addTarget(self,
                                   action: #selector(searchTextEditingDidEnd),
                                   for: .editingDidEndOnExit)

    self.searchBarContainerView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(searchBarContainerTapped))
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
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_500
      |> UIButton.lens.titleLabel.font .~ .ksr_callout(size:15)
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.discovery_search_cancel() }

    _ = self.searchBarContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .ksr_grey_300

    _ = self.searchIconImageView
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_400
      |> UIImageView.lens.image .~ image(named: "search-icon")

    _ = self.searchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.innerSearchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.searchTextField
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.textColor .~ .ksr_text_dark_grey_500

    self.searchTextField.attributedPlaceholder = NSAttributedString(
      string: Strings.tabbar_search(),
      attributes: [NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_500]
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
        self?.updateProjectPlaylist(projects)
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
        _self.tableView.tableHeaderView = isAnimating ? _self.searchLoaderIndicator :  nil
        if let headerView = _self.tableView.tableHeaderView {
          headerView.frame = CGRect(x: headerView.frame.origin.x,
                                    y: headerView.frame.origin.y,
                                    width: headerView.frame.size.width,
                                    height: Styles.grid(15))
        }
    }

    self.viewModel.outputs.popularLoaderIndicatorIsAnimating
      .observeForUI()
      .observeValues { [weak self] isAnimating in
        guard let _self = self else { return }
        _self.tableView.tableHeaderView = isAnimating ? _self.popularLoaderIndicator :  nil
        if let headerView = _self.tableView.tableHeaderView {
          headerView.frame = CGRect(x: headerView.frame.origin.x,
                                    y: headerView.frame.origin.y,
                                    width: headerView.frame.size.width,
                                    height: Styles.grid(15))
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
      .observeValues { [weak self] project, projects, refTag in
        self?.goTo(project: project, projects: projects, refTag: refTag)
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

    self.viewModel.outputs.scrollToProjectRow
      .observeForControllerAction()
      .observeValues { [weak self] in self?.scrollToProjectRow($0) }
  }

  private func scrollToProjectRow(_ row: Int) {
    self.tableView.scrollToRow(at: self.dataSource.indexPath(forProjectRow: row), at: .top, animated: false)
  }

  fileprivate func goTo(project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func changeSearchFieldFocus(focus: Bool, animated: Bool) {
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

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let project = self.dataSource[indexPath] as? Project else {
      return
    }

    self.viewModel.inputs.tapped(project: project)
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  private func updateProjectPlaylist(_ playlist: [Project]) {
    guard let navigator = self.presentedViewController as? ProjectNavigatorViewController else { return }
    navigator.updatePlaylist(playlist)
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
}

extension SearchViewController: UITextFieldDelegate {
  internal func textFieldDidBeginEditing(_ textField: UITextField) {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }

  internal func textFieldShouldClear(_ textField: UITextField) -> Bool {
    self.viewModel.inputs.clearSearchText()
    return true
  }
}

extension SearchViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at index: Int) {
    self.viewModel.inputs.transitionedToProject(at: index, outOf: self.dataSource.numberOfItems())
  }
}
