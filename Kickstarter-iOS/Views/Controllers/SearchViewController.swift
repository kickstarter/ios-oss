import KsApi
import Library
import Prelude
import UIKit

internal final class SearchViewController: UITableViewController {
  fileprivate let viewModel: SearchViewModelType = SearchViewModel()
  fileprivate let dataSource = SearchDataSource()

  @IBOutlet fileprivate weak var cancelButton: UIButton!
  @IBOutlet fileprivate var searchBarCenterConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var searchBarContainerView: UIView!
  @IBOutlet fileprivate var searchBarLeadingConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var searchBarTrailingConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var searchIconImageView: UIImageView!
  @IBOutlet fileprivate weak var searchStackView: UIStackView!
  @IBOutlet fileprivate weak var searchTextField: UITextField!

  internal static func instantiate() -> SearchViewController {
    return Storyboard.Search.instantiate(SearchViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.dataSource
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
      |> SearchViewController.lens.view.backgroundColor .~ .ksr_grey_200

    _ = self.cancelButton
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_navy_700
      |> UIButton.lens.titleLabel.font .~ .ksr_callout(size:16)
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.discovery_search_cancel() }

    _ = self.searchBarContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .ksr_grey_200

    _ = self.searchIconImageView
      |> UIImageView.lens.tintColor .~ .ksr_navy_500
      |> UIImageView.lens.image .~ image(named: "search-icon")

    _ = self.searchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.searchTextField
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.textColor .~ .ksr_text_navy_700
      |> UITextField.lens.placeholder %~ { _ in Strings.tabbar_search() }

    _ = self.tableView
      |> UITableView.lens.keyboardDismissMode .~ .onDrag

    _ = self.navigationController
      ?|> UINavigationController.lens.navigationBar.barTintColor .~ .white

    _ = self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  internal override func bindViewModel() {

    self.viewModel.outputs.projects
      .observeForControllerAction()
      .observeValues { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.isPopularTitleVisible
      .observeForControllerAction()
      .observeValues { [weak self] visible in
        self?.dataSource.popularTitle(isVisible: visible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, projects, refTag in
        self?.goTo(project: project, projects: projects, refTag: refTag)
    }

    self.searchTextField.rac.text = self.viewModel.outputs.searchFieldText
    self.searchTextField.rac.isFirstResponder = self.viewModel.outputs.resignFirstResponder.mapConst(false)

    self.viewModel.outputs.changeSearchFieldFocus
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.changeSearchFieldFocus(focus: $0, animated: $1)
    }
  }

  fileprivate func goTo(project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func changeSearchFieldFocus(focus: Bool, animated: Bool) {
    UIView.animate(withDuration: 0.2 * (animated ? 1.0 : 0.0), animations: {
      if focus {
        self.searchBarCenterConstraint.isActive = false
        self.searchBarLeadingConstraint.isActive = true
        self.searchBarTrailingConstraint.isActive = true
        self.cancelButton.isHidden = false
        self.searchTextField.becomeFirstResponder()
      } else {
        self.searchBarCenterConstraint.isActive = true
        self.searchBarLeadingConstraint.isActive = false
        self.searchBarTrailingConstraint.isActive = false
        self.cancelButton.isHidden = true
        self.searchTextField.resignFirstResponder()
      }
      self.view.layoutIfNeeded()
    })
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

  }
}
