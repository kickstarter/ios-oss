import Library
import KsApi
import ReactiveExtensions
import UIKit

internal final class SearchMessagesViewController: UITableViewController {
  fileprivate let viewModel: MessagesSearchViewModelType = MessagesSearchViewModel()
  fileprivate let dataSource = SearchMessagesDataSource()

  @IBOutlet fileprivate weak var searchTextField: UITextField!
  @IBOutlet fileprivate weak var loadingView: UIActivityIndicatorView!

  internal func configureWith(project: Project?) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 120.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.viewModel.inputs.viewWillDisappear()
  }

  internal override func bindViewModel() {
    self.searchTextField.rac.isFirstResponder = self.viewModel.outputs.showKeyboard
    self.loadingView.rac.animating = self.viewModel.outputs.isSearching

    self.viewModel.outputs.messageThreads
      .observeForControllerAction()
      .observeValues { [weak self] messageThreads in
        self?.dataSource.load(messageThreads: messageThreads)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.emptyStateIsVisible
      .observeForControllerAction()
      .observeValues { [weak self] isVisible in
        self?.dataSource.emptyState(isVisible: isVisible)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToMessageThread
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goTo(messageThread: $0) }
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    if let messageThread = self.dataSource[indexPath] as? MessageThread {
      self.viewModel.inputs.tappedMessageThread(messageThread)
    }
  }

  fileprivate func goTo(messageThread: MessageThread) {
    let vc = MessagesViewController.configuredWith(messageThread: messageThread)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  @IBAction fileprivate func searchTextChanged(_ textField: UITextField) {
    self.viewModel.inputs.searchTextChanged(textField.text)
  }
}

extension SearchMessagesViewController: UITextFieldDelegate {
  internal func textFieldShouldClear(_ textField: UITextField) -> Bool {
    self.viewModel.inputs.clearSearchText()
    return true
  }
}
