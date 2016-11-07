import KsApi
import Library
import Prelude
import UIKit

internal final class SearchViewController: UITableViewController {
  private let viewModel: SearchViewModelType = SearchViewModel()
  private let dataSource = SearchDataSource()

  @IBOutlet private weak var cancelButton: UIButton!
  @IBOutlet private var searchBarCenterConstraint: NSLayoutConstraint!
  @IBOutlet private weak var searchBarContainerView: UIView!
  @IBOutlet private var searchBarLeadingConstraint: NSLayoutConstraint!
  @IBOutlet private var searchBarTrailingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var searchIconImageView: UIImageView!
  @IBOutlet private weak var searchStackView: UIStackView!
  @IBOutlet private weak var searchTextField: UITextField!

  internal static func instantiate() -> SearchViewController {
    return Storyboard.Search.instantiate(SearchViewController)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = self.dataSource
  }

  internal override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    self.cancelButton.addTarget(self,
                                action: #selector(cancelButtonPressed),
                                forControlEvents: .TouchUpInside)

    self.searchTextField.addTarget(self,
                                   action: #selector(searchTextChanged(_:)),
                                   forControlEvents: .EditingChanged)

    self.searchTextField.addTarget(self,
                                   action: #selector(searchTextEditingDidEnd),
                                   forControlEvents: .EditingDidEndOnExit)

    self.searchBarContainerView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(searchBarContainerTapped))
    )

    self.searchTextField.delegate = self

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle(estimatedRowHeight: 160)
      |> SearchViewController.lens.view.backgroundColor .~ .ksr_grey_200

    self.cancelButton
      |> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_text_navy_700
      |> UIButton.lens.titleLabel.font .~ .ksr_callout(size:16)

    self.searchBarContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ .ksr_grey_200

    self.searchIconImageView
      |> UIImageView.lens.tintColor .~ .ksr_navy_500
      |> UIImageView.lens.image .~ image(named: "search-icon")

    self.searchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    self.searchTextField
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.textColor .~ .ksr_text_navy_700
      |> UITextField.lens.placeholder %~ { _ in Strings.tabbar_search() }

    self.tableView
      |> UITableView.lens.keyboardDismissMode .~ .OnDrag

    self.navigationController
      ?|> UINavigationController.lens.navigationBar.barTintColor .~ .whiteColor()

    self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  internal override func bindViewModel() {

    self.viewModel.outputs.projects
      .observeForControllerAction()
      .observeNext { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.isPopularTitleVisible
      .observeForControllerAction()
      .observeNext { [weak self] visible in
        self?.dataSource.popularTitle(isVisible: visible)
        self?.tableView.reloadData()
    }

    self.searchTextField.rac.text = self.viewModel.outputs.searchFieldText
    self.searchTextField.rac.isFirstResponder = self.viewModel.outputs.resignFirstResponder.mapConst(false)

    self.viewModel.outputs.changeSearchFieldFocus
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.changeSearchFieldFocus(focus: $0, animated: $1)
    }
  }

  private func changeSearchFieldFocus(focus focus: Bool, animated: Bool) {
    UIView.animateWithDuration(0.2 * (animated ? 1.0 : 0.0)) {
      if focus {
        self.searchBarCenterConstraint.active = false
        self.searchBarLeadingConstraint.active = true
        self.searchBarTrailingConstraint.active = true
        self.cancelButton.hidden = false
        self.searchTextField.becomeFirstResponder()
      } else {
        self.searchBarCenterConstraint.active = true
        self.searchBarLeadingConstraint.active = false
        self.searchBarTrailingConstraint.active = false
        self.cancelButton.hidden = true
        self.searchTextField.resignFirstResponder()
      }
      self.view.layoutIfNeeded()
    }
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let project = self.dataSource[indexPath] as? Project else {
      return
    }

    let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: .search)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  @objc private func searchTextChanged(textField: UITextField) {
    self.viewModel.inputs.searchTextChanged(textField.text ?? "")
  }

  @objc private func searchTextEditingDidEnd() {
    self.viewModel.inputs.searchTextEditingDidEnd()
  }

  @objc private func cancelButtonPressed() {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @objc private func searchBarContainerTapped() {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }
}

extension SearchViewController: UITextFieldDelegate {
  internal func textFieldDidBeginEditing(textField: UITextField) {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }

  internal func textFieldShouldClear(textField: UITextField) -> Bool {
    self.viewModel.inputs.clearSearchText()
    return true
  }
}
